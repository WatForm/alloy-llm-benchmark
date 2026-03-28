#!/usr/bin/env python3
"""Score generated Alloy models against references and instances.

Usage:
    python score.py <outputs_dir> <models_dir> <instances_dir> [report_output]
"""

import os
import re
import shutil
import subprocess
import sys
import tempfile
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime
from collections import defaultdict
from pathlib import Path


TIMEOUT_SECONDS = 300
COMPOSAT_TIMEOUT_SECONDS = 300
SOLVER = "sat4j"


def parse_parallelism_env(var_name: str, default: int) -> int:
    raw = os.environ.get(var_name)
    if raw is None:
        return max(1, default)
    try:
        return max(1, int(raw))
    except ValueError:
        return max(1, default)


DEFAULT_MODEL_WORKERS = min(4, max(1, os.cpu_count() or 1))
MODEL_WORKERS = parse_parallelism_env("SCORE_MODEL_WORKERS", DEFAULT_MODEL_WORKERS)
PROGRESS_ENABLED = os.environ.get("SCORE_QUIET", "0") != "1"


def progress(message: str) -> None:
    if PROGRESS_ENABLED:
        print(f"[{datetime.now().strftime('%H:%M:%S')}] {message}", flush=True)


def run_command(cmd: list[str], cwd: Path | None = None, timeout: int = TIMEOUT_SECONDS) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        cmd,
        capture_output=True,
        text=True,
        timeout=timeout,
        check=False,
        cwd=str(cwd) if cwd else None,
    )


def java_major_version(java_bin: Path) -> int | None:
    try:
        result = run_command([str(java_bin), "-version"], timeout=30)
    except Exception:
        return None

    output = (result.stderr or "") + (result.stdout or "")
    match = re.search(r'version "(\d+)(?:\.(\d+))?', output)
    if not match:
        return None

    major = int(match.group(1))
    if major == 1 and match.group(2):
        return int(match.group(2))
    return major


def require_java_for_version(
    major: int,
    tool_name: str,
    require_javac: bool = False,
) -> tuple[Path, Path | None]:
    env_name = f"JAVA_HOME_{major}"
    env_home = os.environ.get(env_name)
    if not env_home:
        raise RuntimeError(
            f"{env_name} is required for {tool_name}. "
            f"Set it first, for example: export {env_name}=\"/path/to/jdk-{major}\""
        )

    java_bin = Path(env_home) / "bin" / "java"
    if not java_bin.exists() or not os.access(java_bin, os.X_OK):
        raise RuntimeError(f"{env_name} does not point to a valid Java binary: {java_bin}")

    detected_major = java_major_version(java_bin)
    if detected_major != major:
        raise RuntimeError(
            f"Java {major} is required for {tool_name}. "
            f"Current {env_name}: {env_home}. This resolves to Java {detected_major}."
        )

    javac_bin: Path | None = None
    if require_javac:
        javac_bin = Path(env_home) / "bin" / "javac"
        if not javac_bin.exists() or not os.access(javac_bin, os.X_OK):
            raise RuntimeError(f"{env_name} does not provide a valid javac binary: {javac_bin}")

    return java_bin, javac_bin


def resolve_alloy_tmpdir() -> Path:
    alloy_tmpdir = os.environ.get("ALLOY_TMPDIR")
    if alloy_tmpdir:
        return Path(alloy_tmpdir)

    tmpdir = os.environ.get("TMPDIR")
    if tmpdir:
        return Path(tmpdir.rstrip("/")) / "alloy-benchmark"

    return Path("/tmp/alloy-benchmark")


def check_syntax(model_file: Path, diff_jar: Path, java17_bin: Path) -> tuple[int, str]:
    if not model_file.exists():
        return 0, f"Missing generated file: {model_file}"

    cmd = [
        str(java17_bin),
        "-cp",
        str(diff_jar),
        "org.alloytools.alloy.diff.ModuleDiff",
        str(model_file),
        str(model_file),
        "SemDiff",
        "1",
        "false",
        SOLVER,
    ]

    try:
        result = run_command(cmd)
    except subprocess.TimeoutExpired:
        return 0, "Syntax check timed out"
    except Exception as exc:
        return 0, f"Syntax check failed: {exc}"

    output = (result.stdout or "") + (result.stderr or "")
    if result.returncode == 0 and "The two modules are equivalent for the given scope." in output:
        return 1, "OK"

    details = output.strip()
    return 0, details if details else "Syntax check failed"


def semdiff_implication_holds(
    left_model: Path,
    right_model: Path,
    scope: int,
    diff_jar: Path,
    java17_bin: Path,
) -> tuple[bool, str]:
    """Return True when SemDiff finds no counterexample for right_model => left_model."""
    cmd = [
        str(java17_bin),
        "-cp",
        str(diff_jar),
        "org.alloytools.alloy.diff.ModuleDiff",
        str(left_model),
        str(right_model),
        "SemDiff",
        str(scope),
        "false",
        SOLVER,
    ]

    try:
        result = run_command(cmd)
    except subprocess.TimeoutExpired:
        return False, "Timed out"
    except Exception as exc:
        return False, str(exc)

    output = (result.stdout or "") + (result.stderr or "")
    output = output.strip()
    equivalent = "The two modules are equivalent for the given scope." in output
    return equivalent, output.splitlines()[-1] if output else "No output"


def compile_instance_checker(scripts_dir: Path, alloy_jar_620: Path, javac17_bin: Path) -> tuple[bool, str]:
    java_file = scripts_dir / "InstanceChecker.java"
    cmd = [str(javac17_bin), "-cp", str(alloy_jar_620), str(java_file)]

    try:
        result = run_command(cmd, cwd=scripts_dir)
    except subprocess.TimeoutExpired:
        return False, "javac timed out"
    except Exception as exc:
        return False, str(exc)

    if result.returncode == 0:
        return True, "OK"

    details = (result.stderr or result.stdout).strip()
    return False, details if details else "javac failed"


def check_instance_valid(
    model_file: Path,
    xml_file: Path,
    scripts_dir: Path,
    alloy_jar_620: Path,
    java17_bin: Path,
) -> tuple[bool, str]:
    cmd = [
        str(java17_bin),
        "-cp",
        f"{scripts_dir}{os.pathsep}{alloy_jar_620}",
        "InstanceChecker",
        str(model_file),
        str(xml_file),
    ]

    try:
        result = run_command(cmd, cwd=scripts_dir)
    except subprocess.TimeoutExpired:
        return False, "Timed out"
    except Exception as exc:
        return False, str(exc)

    output = ((result.stdout or "") + (result.stderr or "")).strip()
    return result.returncode == 0, output.splitlines()[-1] if output else "No output"


def discover_instances_by_scope(instances_root: Path, model_name: str) -> dict[int, list[Path]]:
    grouped: dict[int, list[Path]] = defaultdict(list)
    pattern = f"**/{model_name}/scope_*/{model_name}/instance_*.xml"

    for xml_path in sorted(instances_root.glob(pattern)):
        scope_folder = xml_path.parent.parent.name
        match = re.fullmatch(r"scope_(\d+)", scope_folder)
        if not match:
            continue
        scope = int(match.group(1))
        grouped[scope].append(xml_path)

    return dict(sorted(grouped.items(), key=lambda item: item[0]))


def strip_run_and_check_commands(model_text: str) -> str:
    filtered = []
    for line in model_text.splitlines():
        if re.match(r"^\s*(run|check)\b", line):
            continue
        filtered.append(line)
    return "\n".join(filtered).rstrip() + "\n"


def score_output_instances_against_reference(
    model_name: str,
    generated_model: Path,
    reference_model: Path,
    max_scope: int,
    scripts_dir: Path,
    alloy_jar_620: Path,
    composat_jar: Path,
    java8_bin: Path,
    java17_bin: Path,
    composat_tmpdir: Path,
) -> dict:
    if max_scope <= 0:
        progress(f"[{model_name}] output=>original: no reference scopes found; skipping CompoSAT generation.")
        return {
            "score": 0,
            "max": 0,
            "by_scope": [],
            "timed_out": False,
            "timeout_scope": None,
            "notes": ["No reference scopes found; skipped output-instance generation."],
        }

    if not generated_model.exists():
        progress(f"[{model_name}] output=>original: generated model missing at {generated_model}")
        return {
            "score": 0,
            "max": 0,
            "by_scope": [{"scope": scope, "score": 0, "max": 0} for scope in range(1, max_scope + 1)],
            "timed_out": False,
            "timeout_scope": None,
            "notes": [f"Generated model is missing: {generated_model}"],
        }

    try:
        base_model_text = strip_run_and_check_commands(generated_model.read_text(encoding="utf-8"))
    except Exception as exc:
        progress(f"[{model_name}] output=>original: failed reading generated model for CompoSAT: {exc}")
        return {
            "score": 0,
            "max": 0,
            "by_scope": [{"scope": scope, "score": 0, "max": 0} for scope in range(1, max_scope + 1)],
            "timed_out": False,
            "timeout_scope": None,
            "notes": [f"Could not read generated model for CompoSAT: {exc}"],
        }

    total_score = 0
    total_max = 0
    by_scope: list[dict] = []
    notes: list[str] = []
    timed_out = False
    timeout_scope = None
    timeout_scopes: list[int] = []

    with tempfile.TemporaryDirectory(prefix=f"composat_score_{model_name}_") as temp_dir:
        temp_path = Path(temp_dir)
        progress(
            f"[{model_name}] output=>original: running CompoSAT sequentially across {max_scope} scope(s)"
        )

        for scope in range(1, max_scope + 1):
            progress(f"[{model_name}] output=>original: CompoSAT scope_{scope}/{max_scope} starting")

            scope_model = temp_path / f"{model_name}_scope_{scope}.als"
            scope_model.write_text(base_model_text + f"run {{}} for {scope}\n", encoding="utf-8")

            scope_out = temp_path / "instances" / f"scope_{scope}"
            scope_out.mkdir(parents=True, exist_ok=True)

            cmd = [
                str(java8_bin),
                f"-Djava.io.tmpdir={composat_tmpdir}",
                "-jar",
                str(composat_jar),
                "batch",
                "--files",
                str(scope_model),
                "--command",
                "0",
                "--mode",
                "coverage",
                "--symmetry",
                "2000",
                "--out",
                str(scope_out),
            ]

            try:
                result = run_command(cmd, timeout=COMPOSAT_TIMEOUT_SECONDS)
            except subprocess.TimeoutExpired:
                timed_out = True
                timeout_scope = scope
                timeout_scopes = [scope]
                timeout_note = (
                    f"scope_{scope}: CompoSAT timed out after {COMPOSAT_TIMEOUT_SECONDS}s; remaining scopes skipped."
                )
                notes.append(timeout_note)
                progress(f"[{model_name}] output=>original: {timeout_note}")
                shutil.rmtree(scope_out, ignore_errors=True)
                break
            except Exception as exc:
                err_note = f"scope_{scope}: CompoSAT invocation failed: {exc}"
                notes.append(err_note)
                progress(f"[{model_name}] output=>original: {err_note}")
                by_scope.append({"scope": scope, "score": 0, "max": 0})
                continue

            output = ((result.stdout or "") + (result.stderr or "")).strip()
            if result.returncode != 0:
                detail = output.splitlines()[-1] if output else "No output"
                exit_note = f"scope_{scope}: CompoSAT exited with code {result.returncode} ({detail})"
                notes.append(exit_note)
                progress(f"[{model_name}] output=>original: {exit_note}")

            xml_files = sorted(scope_out.glob("**/instance_*.xml"))
            progress(
                f"[{model_name}] output=>original: CompoSAT scope_{scope} done; generated {len(xml_files)} instance(s)"
            )

            scope_max = len(xml_files)
            scope_valid = 0
            progress(
                f"[{model_name}] output=>original: scope_{scope} generated {scope_max} instance(s); validating against reference"
            )

            for idx, xml_file in enumerate(xml_files, start=1):
                valid, _ = check_instance_valid(
                    reference_model,
                    xml_file,
                    scripts_dir,
                    alloy_jar_620,
                    java17_bin,
                )
                if valid:
                    scope_valid += 1
                if idx % 25 == 0 or idx == scope_max:
                    progress(
                        f"[{model_name}] output=>original: scope_{scope} validated {idx}/{scope_max} instance(s)"
                    )

            total_score += scope_valid
            total_max += scope_max
            by_scope.append({"scope": scope, "score": scope_valid, "max": scope_max})
            progress(
                f"[{model_name}] output=>original: scope_{scope} complete with {scope_valid}/{scope_max} valid"
            )

    return {
        "score": total_score,
        "max": total_max,
        "by_scope": by_scope,
        "timed_out": timed_out,
        "timeout_scope": timeout_scope,
        "timeout_scopes": timeout_scopes,
        "notes": notes,
    }


def score_one_model(
    model_name: str,
    generated_model: Path,
    reference_model: Path,
    instances_root: Path,
    scripts_dir: Path,
    diff_jar: Path,
    alloy_jar_620: Path,
    composat_jar: Path,
    java17_bin: Path,
    java8_bin: Path,
    composat_tmpdir: Path,
) -> dict:
    progress(f"[{model_name}] start scoring")
    progress(f"[{model_name}] syntax check starting")
    syntax_score, syntax_msg = check_syntax(generated_model, diff_jar, java17_bin)
    progress(f"[{model_name}] syntax check result: {syntax_score}/1")
    instances_by_scope = discover_instances_by_scope(instances_root, model_name)
    max_scope = max(instances_by_scope.keys(), default=0)
    ringert_scopes = list(range(1, max_scope + 1))
    total_reference_instances = sum(len(v) for v in instances_by_scope.values())
    progress(
        f"[{model_name}] discovered {total_reference_instances} reference instance(s) across "
        f"{len(instances_by_scope)} scope(s); max scope {max_scope}"
    )

    ringert_original_to_output_by_scope: list[dict] = []
    ringert_output_to_original_by_scope: list[dict] = []
    original_instance_by_scope: list[dict] = []

    ringert_original_to_output_score = 0
    ringert_output_to_original_score = 0

    if syntax_score == 1:
        for scope in ringert_scopes:
            progress(f"[{model_name}] Ringert scope_{scope}/{max_scope}: checking implications")
            output_implies_original_ok, _ = semdiff_implication_holds(
                reference_model,
                generated_model,
                scope,
                diff_jar,
                java17_bin,
            )
            original_implies_output_ok, _ = semdiff_implication_holds(
                generated_model,
                reference_model,
                scope,
                diff_jar,
                java17_bin,
            )

            ringert_output_to_original_score += int(output_implies_original_ok)
            ringert_original_to_output_score += int(original_implies_output_ok)

            ringert_output_to_original_by_scope.append(
                {"scope": scope, "score": int(output_implies_original_ok), "max": 1}
            )
            ringert_original_to_output_by_scope.append(
                {"scope": scope, "score": int(original_implies_output_ok), "max": 1}
            )
            progress(
                f"[{model_name}] Ringert scope_{scope}: original=>output={int(original_implies_output_ok)}/1, "
                f"output=>original={int(output_implies_original_ok)}/1"
            )
    else:
        progress(f"[{model_name}] syntax invalid; Ringert and instance checks will score 0 where applicable")
        for scope in ringert_scopes:
            ringert_output_to_original_by_scope.append({"scope": scope, "score": 0, "max": 1})
            ringert_original_to_output_by_scope.append({"scope": scope, "score": 0, "max": 1})

    original_instance_score = 0
    original_instance_max = 0

    for scope, xml_files in instances_by_scope.items():
        scope_valid = 0
        scope_max = len(xml_files)
        progress(
            f"[{model_name}] original=>output: scope_{scope} validating {scope_max} reference instance(s)"
        )
        for idx, xml in enumerate(xml_files, start=1):
            if syntax_score == 1:
                valid, _ = check_instance_valid(generated_model, xml, scripts_dir, alloy_jar_620, java17_bin)
                if valid:
                    scope_valid += 1
            if idx % 25 == 0 or idx == scope_max:
                progress(
                    f"[{model_name}] original=>output: scope_{scope} validated {idx}/{scope_max} instance(s)"
                )
            # Invalid syntax means all instances count as invalid (score remains 0).
        original_instance_score += scope_valid
        original_instance_max += scope_max
        original_instance_by_scope.append({"scope": scope, "score": scope_valid, "max": scope_max})
        progress(
            f"[{model_name}] original=>output: scope_{scope} complete with {scope_valid}/{scope_max} valid"
        )

    output_instance_result = score_output_instances_against_reference(
        model_name=model_name,
        generated_model=generated_model,
        reference_model=reference_model,
        max_scope=max_scope,
        scripts_dir=scripts_dir,
        alloy_jar_620=alloy_jar_620,
        composat_jar=composat_jar,
        java8_bin=java8_bin,
        java17_bin=java17_bin,
        composat_tmpdir=composat_tmpdir,
    )
    progress(
        f"[{model_name}] output=>original summary: "
        f"{output_instance_result['score']}/{output_instance_result['max']}"
    )

    ringert_original_to_output_max = len(ringert_scopes)
    ringert_output_to_original_max = len(ringert_scopes)

    total_score = (
        syntax_score
        + ringert_original_to_output_score
        + ringert_output_to_original_score
        + original_instance_score
        + output_instance_result["score"]
    )
    total_max = (
        1
        + ringert_original_to_output_max
        + ringert_output_to_original_max
        + original_instance_max
        + output_instance_result["max"]
    )

    progress(f"[{model_name}] finished with total {total_score}/{total_max}")

    return {
        "model": model_name,
        "generated_file": str(generated_model),
        "reference_file": str(reference_model),
        "syntax": {"score": syntax_score, "max": 1, "message": syntax_msg},
        "directions": {
            "original_to_output": {
                "ringert": {
                    "score": ringert_original_to_output_score,
                    "max": ringert_original_to_output_max,
                    "by_scope": ringert_original_to_output_by_scope,
                },
                "instances": {
                    "score": original_instance_score,
                    "max": original_instance_max,
                    "by_scope": original_instance_by_scope,
                },
            },
            "output_to_original": {
                "ringert": {
                    "score": ringert_output_to_original_score,
                    "max": ringert_output_to_original_max,
                    "by_scope": ringert_output_to_original_by_scope,
                },
                "instances": output_instance_result,
            },
        },
        "total": {"score": total_score, "max": total_max},
    }


def build_report(results: list[dict]) -> str:
    lines: list[str] = []
    lines.append("Alloy Benchmark Scoring Report")
    lines.append("=" * 80)
    lines.append("SemDiff direction note: ModuleDiff <left> <right> SemDiff reports equivalent when right => left.")
    lines.append(f"CompoSAT timeout per scope: {COMPOSAT_TIMEOUT_SECONDS}s")
    lines.append(f"Model scoring parallelism: {MODEL_WORKERS} worker(s)")
    lines.append("")

    grand_score = 0
    grand_max = 0

    for result in results:
        lines.append(f"Model: {result['model']}")
        lines.append(f"  Generated: {result['generated_file']}")
        lines.append(f"  Reference: {result['reference_file']}")
        lines.append(f"  Syntax: {result['syntax']['score']}/{result['syntax']['max']}")
        if result["syntax"]["message"] != "OK":
            lines.append(f"  Syntax detail: {result['syntax']['message']}")

        original_to_output = result["directions"]["original_to_output"]
        output_to_original = result["directions"]["output_to_original"]

        lines.append("  Direction: original => output")
        lines.append(
            f"    Ringert (SemDiff implication): "
            f"{original_to_output['ringert']['score']}/{original_to_output['ringert']['max']}"
        )
        for scope_row in original_to_output["ringert"]["by_scope"]:
            lines.append(
                f"      scope_{scope_row['scope']}: {scope_row['score']}/{scope_row['max']}"
            )
        lines.append(
            "    CompoSAT instances from original model checked on output model: "
            f"{original_to_output['instances']['score']}/{original_to_output['instances']['max']}"
        )
        for scope_row in original_to_output["instances"]["by_scope"]:
            lines.append(
                f"      scope_{scope_row['scope']}: {scope_row['score']}/{scope_row['max']}"
            )

        lines.append("  Direction: output => original")
        lines.append(
            f"    Ringert (SemDiff implication): "
            f"{output_to_original['ringert']['score']}/{output_to_original['ringert']['max']}"
        )
        for scope_row in output_to_original["ringert"]["by_scope"]:
            lines.append(
                f"      scope_{scope_row['scope']}: {scope_row['score']}/{scope_row['max']}"
            )

        lines.append(
            "    CompoSAT instances from output model checked on original model: "
            f"{output_to_original['instances']['score']}/{output_to_original['instances']['max']}"
        )
        for scope_row in output_to_original["instances"]["by_scope"]:
            lines.append(
                f"      scope_{scope_row['scope']}: {scope_row['score']}/{scope_row['max']}"
            )
        if output_to_original["instances"].get("timed_out"):
            timeout_scopes = output_to_original["instances"].get("timeout_scopes") or []
            if timeout_scopes:
                formatted_scopes = ", ".join(f"scope_{scope}" for scope in timeout_scopes)
                lines.append(
                    f"    TIMEOUT: CompoSAT hit the {COMPOSAT_TIMEOUT_SECONDS}s limit at {formatted_scopes}."
                )
            else:
                timeout_scope = output_to_original["instances"].get("timeout_scope")
                lines.append(
                    f"    TIMEOUT: CompoSAT hit the {COMPOSAT_TIMEOUT_SECONDS}s limit at scope_{timeout_scope}."
                )
        for note in output_to_original["instances"].get("notes", []):
            lines.append(f"    Note: {note}")

        lines.append(f"  TOTAL: {result['total']['score']}/{result['total']['max']}")
        lines.append("")

        grand_score += result["total"]["score"]
        grand_max += result["total"]["max"]

    lines.append("=" * 80)
    lines.append(f"OVERALL TOTAL: {grand_score}/{grand_max}")
    return "\n".join(lines) + "\n"


def main() -> int:
    if len(sys.argv) not in (4, 5):
        print(
            "Usage: python score.py <outputs_dir> <models_dir> <instances_dir> [report_output]",
            file=sys.stderr,
        )
        return 1

    outputs_dir = Path(sys.argv[1]).resolve()
    models_dir = Path(sys.argv[2]).resolve()
    instances_dir = Path(sys.argv[3]).resolve()
    report_output = Path(sys.argv[4]).resolve() if len(sys.argv) == 5 else outputs_dir / "scores.txt"

    progress("Starting benchmark scoring run")
    progress(f"outputs_dir={outputs_dir}")
    progress(f"models_dir={models_dir}")
    progress(f"instances_dir={instances_dir}")
    progress(f"report_output={report_output}")
    progress(f"Model-level parallel workers={MODEL_WORKERS}")

    repo_root = Path(__file__).resolve().parent.parent
    scripts_dir = Path(__file__).resolve().parent
    scoring_dir = repo_root / "scoring"

    diff_jar = scoring_dir / "alloy-diff.jar"
    alloy_jar_620 = scoring_dir / "org.alloytools.alloy.dist-6.2.0.jar"
    composat_jar = scoring_dir / "CompoSAT.jar"

    progress("Checking required input paths and jar files")
    for path in [outputs_dir, models_dir, instances_dir, diff_jar, alloy_jar_620, composat_jar]:
        if not path.exists():
            print(f"Error: missing required path: {path}", file=sys.stderr)
            return 1

    try:
        progress("Resolving Java toolchains")
        java17_bin, javac17_bin = require_java_for_version(
            17,
            "alloy-diff and InstanceChecker",
            require_javac=True,
        )
        java8_bin, _ = require_java_for_version(8, "CompoSAT")
    except RuntimeError as exc:
        print(f"Error: {exc}", file=sys.stderr)
        return 1

    progress(f"Using Java 17 binary: {java17_bin}")
    progress(f"Using Java 8 binary: {java8_bin}")

    if javac17_bin is None:
        print("Error: unable to resolve javac for Java 17", file=sys.stderr)
        return 1

    composat_tmpdir = resolve_alloy_tmpdir()
    composat_tmpdir.mkdir(parents=True, exist_ok=True)
    progress(f"Using CompoSAT tmpdir: {composat_tmpdir}")

    progress("Compiling InstanceChecker.java")
    compiled, compile_msg = compile_instance_checker(scripts_dir, alloy_jar_620, javac17_bin)
    if not compiled:
        print(f"Error compiling InstanceChecker.java: {compile_msg}", file=sys.stderr)
        return 1
    progress("InstanceChecker compilation complete")

    reference_models = sorted(models_dir.glob("*.als"))
    if not reference_models:
        print(f"Error: no .als files found in models dir: {models_dir}", file=sys.stderr)
        return 1
    progress(f"Found {len(reference_models)} model(s) to score")

    workers = min(MODEL_WORKERS, len(reference_models))
    progress(f"Using {workers} active model worker(s)")

    def run_one_model(model_idx: int, reference_model: Path) -> dict:
        model_name = reference_model.stem
        progress(f"Model {model_idx}/{len(reference_models)}: {model_name}")
        generated_model = outputs_dir / f"{model_name}.als"
        result = score_one_model(
            model_name=model_name,
            generated_model=generated_model,
            reference_model=reference_model,
            instances_root=instances_dir,
            scripts_dir=scripts_dir,
            diff_jar=diff_jar,
            alloy_jar_620=alloy_jar_620,
            composat_jar=composat_jar,
            java17_bin=java17_bin,
            java8_bin=java8_bin,
            composat_tmpdir=composat_tmpdir,
        )
        progress(
            f"Model {model_idx}/{len(reference_models)} complete: {model_name} total "
            f"{result['total']['score']}/{result['total']['max']}"
        )
        return result

    results: list[dict] = []
    if workers == 1:
        for model_idx, reference_model in enumerate(reference_models, start=1):
            results.append(run_one_model(model_idx, reference_model))
    else:
        indexed_results: list[dict | None] = [None] * len(reference_models)
        with ThreadPoolExecutor(max_workers=workers) as executor:
            futures = {
                executor.submit(run_one_model, idx + 1, reference_model): idx
                for idx, reference_model in enumerate(reference_models)
            }
            for future in as_completed(futures):
                idx = futures[future]
                model_name = reference_models[idx].stem
                try:
                    indexed_results[idx] = future.result()
                except Exception as exc:
                    print(f"Error: scoring failed for model {model_name}: {exc}", file=sys.stderr)
                    return 1

        results = [result for result in indexed_results if result is not None]

    progress("Building final report")
    report_text = build_report(results)
    report_file = report_output / "scores.txt" if report_output.is_dir() else report_output
    report_file.parent.mkdir(parents=True, exist_ok=True)
    report_file.write_text(report_text, encoding="utf-8")
    progress(f"Report written to {report_file}")

    print(report_text)
    print(f"Wrote report to: {report_file}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
