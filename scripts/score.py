#!/usr/bin/env python3
"""Score generated Alloy models against references and instances.

Usage:
    python score.py <outputs_dir> <models_dir> <instances_dir> <general_instances_dir> [report_output]
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

from instance_dedup import select_unique_instance_files
from syntax_utils import check_syntax, require_java_for_version


TIMEOUT_SECONDS = 900
COMPOSAT_TIMEOUT_SECONDS = 900
GENERAL_INSTANCE_TIMEOUT_SECONDS = 900
DEFAULT_GENERAL_OUTPUT_INSTANCE_COUNT = 10
MAX_GENERAL_CANDIDATE_MULTIPLIER = 10
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


def resolve_alloy_tmpdir() -> Path:
    alloy_tmpdir = os.environ.get("ALLOY_TMPDIR")
    if alloy_tmpdir:
        return Path(alloy_tmpdir)

    tmpdir = os.environ.get("TMPDIR")
    if tmpdir:
        return Path(tmpdir.rstrip("/")) / "alloy-benchmark"

    return Path("/tmp/alloy-benchmark")


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
    return equivalent, output


# ModuleDiff raises this when the two modules declare a same-named signature one
# way with ``extends`` (a PrimSig) and the other way with ``in`` (a SubsetSig).
PRIMSIG_SUBSETSIG_MERGE_ERROR = "Cannot merge PrimSig and SubsetSig with same name"


def normalize_extends_to_in(source_model: Path, dest_model: Path, scripts_dir: Path) -> bool:
    """Rewrite ``extends`` subsignatures as equivalent ``in`` subsets for SemDiff.

    Runs scripts/extends_to_in.py so that a model whose reference/output disagree
    on ``extends`` vs ``in`` can still be compared by ModuleDiff (which otherwise
    crashes merging a PrimSig against a same-named SubsetSig). Returns True when
    the transformed file was written.
    """
    cmd = [sys.executable, str(scripts_dir / "extends_to_in.py"), str(source_model), str(dest_model)]
    try:
        result = run_command(cmd)
    except subprocess.TimeoutExpired:
        return False
    except Exception:
        return False
    return result.returncode == 0 and dest_model.exists()


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


def compile_instance_generator(scripts_dir: Path, alloy_jar_620: Path, javac17_bin: Path) -> tuple[bool, str]:
    java_file = scripts_dir / "InstanceGenerator.java"
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
    direct_model_root = instances_root / model_name
    search_root = direct_model_root if direct_model_root.exists() else instances_root
    pattern = f"scope_*/{model_name}/instance_*.xml" if direct_model_root.exists() else f"**/{model_name}/scope_*/{model_name}/instance_*.xml"

    for xml_path in sorted(search_root.glob(pattern)):
        scope_folder = xml_path.parent.parent.name
        match = re.fullmatch(r"scope_(\d+)", scope_folder)
        if not match:
            continue
        scope = int(match.group(1))
        grouped[scope].append(xml_path)

    return dict(sorted(grouped.items(), key=lambda item: item[0]))


def discover_general_instances_by_scope(general_instances_root: Path, model_name: str) -> dict[int, list[Path]]:
    grouped: dict[int, list[Path]] = defaultdict(list)
    direct_model_root = general_instances_root / model_name
    search_root = direct_model_root if direct_model_root.exists() else general_instances_root
    pattern = "scope_*/*.xml" if direct_model_root.exists() else f"**/{model_name}/scope_*/*.xml"

    for xml_path in sorted(search_root.glob(pattern)):
        scope_folder = xml_path.parent.name
        match = re.fullmatch(r"scope_(\d+)", scope_folder)
        if not match:
            continue

        # InstanceGenerator output names are usually <model>-instance-<scope>-<idx>.xml.
        if not xml_path.name.startswith(f"{model_name}-instance-"):
            continue

        scope = int(match.group(1))
        grouped[scope].append(xml_path)

    return dict(sorted(grouped.items(), key=lambda item: item[0]))


def discover_output_attempts(outputs_dir: Path, model_name: str) -> list[tuple[int, Path]]:
    attempts: list[tuple[int, Path]] = []
    pattern = re.compile(rf"{re.escape(model_name)}\.attempt(\d+)\.als$")
    for path in sorted(outputs_dir.glob(f"{model_name}.attempt*.als")):
        match = pattern.fullmatch(path.name)
        if not match:
            continue
        attempts.append((int(match.group(1)), path))
    return sorted(attempts, key=lambda item: item[0])


def pick_final_generated_model(outputs_dir: Path, model_name: str) -> tuple[Path, list[tuple[int, Path]]]:
    attempts = discover_output_attempts(outputs_dir, model_name)
    if attempts:
        return attempts[-1][1], attempts
    return outputs_dir / f"{model_name}.als", []


def compute_syntax_attempt_score(
    model_name: str,
    attempts: list[tuple[int, Path]],
    final_model: Path,
    diff_jar: Path,
    java17_bin: Path,
) -> dict:
    # Legacy runs may only have model.als; treat that as a single attempt.
    if not attempts:
        syntax_score, syntax_msg = check_syntax(final_model, diff_jar, java17_bin)
        tries_score = 3 if syntax_score == 1 else 0
        return {
            "score": tries_score,
            "max": 3,
            "first_valid_attempt": 1 if syntax_score == 1 else None,
            "attempt_count": 1,
            "attempts": [
                {
                    "attempt": 1,
                    "file": str(final_model),
                    "syntax_ok": syntax_score == 1,
                    "message": syntax_msg,
                }
            ],
            "final_syntax_ok": syntax_score == 1,
            "final_syntax_message": syntax_msg,
        }

    attempt_rows: list[dict] = []
    first_valid_attempt = None
    final_syntax_ok = False
    final_syntax_message = "Missing final attempt"

    for attempt_num, attempt_path in attempts:
        syntax_score, syntax_msg = check_syntax(attempt_path, diff_jar, java17_bin)
        syntax_ok = syntax_score == 1
        attempt_rows.append(
            {
                "attempt": attempt_num,
                "file": str(attempt_path),
                "syntax_ok": syntax_ok,
                "message": syntax_msg,
            }
        )
        if first_valid_attempt is None and syntax_ok:
            first_valid_attempt = attempt_num
        if attempt_path == final_model:
            final_syntax_ok = syntax_ok
            final_syntax_message = syntax_msg

    if first_valid_attempt is None:
        tries_score = 0
    else:
        tries_score = max(0, 4 - first_valid_attempt)

    progress(
        f"[{model_name}] syntax attempts: first valid attempt={first_valid_attempt}, tries score {tries_score}/3"
    )

    return {
        "score": tries_score,
        "max": 3,
        "first_valid_attempt": first_valid_attempt,
        "attempt_count": len(attempt_rows),
        "attempts": attempt_rows,
        "final_syntax_ok": final_syntax_ok,
        "final_syntax_message": final_syntax_message,
    }


def strip_run_and_check_commands(model_text: str) -> str:
    filtered = []
    for line in model_text.splitlines():
        if re.match(r"^\s*(run|check)\b", line):
            continue
        filtered.append(line)
    return "\n".join(filtered).rstrip() + "\n"


def select_unique_generated_instances(
    xml_files: list[Path],
    seen_hashes: set[str],
    limit: int | None = None,
) -> tuple[list[Path], list[str], int]:
    selected, selected_hashes, duplicate_count = select_unique_instance_files(xml_files, seen_hashes, limit)
    return selected, selected_hashes, duplicate_count


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
    seen_instance_hashes: set[str] = set()

    with tempfile.TemporaryDirectory(prefix=f"composat_score_{model_name}_") as temp_dir:
        temp_path = Path(temp_dir)
        progress(
            f"[{model_name}] output=>original: running CompoSAT sequentially across {max_scope} scope(s)"
        )

        for scope in range(1, max_scope + 1):
            progress(f"[{model_name}] output=>original: CompoSAT scope_{scope}/{max_scope} starting")

            scope_model = temp_path / f"{model_name}_scope_{scope}.als"
            scope_model.write_text(base_model_text + f"run {{}} for {scope} but 4 int\n", encoding="utf-8")

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

            selected_xml_files, selected_hashes, duplicate_count = select_unique_generated_instances(
                xml_files,
                seen_instance_hashes,
            )
            seen_instance_hashes.update(selected_hashes)
            if duplicate_count:
                notes.append(f"scope_{scope}: discarded {duplicate_count} duplicate CompoSAT instance(s).")
            scope_max = len(selected_xml_files)
            scope_valid = 0
            progress(
                f"[{model_name}] output=>original: scope_{scope} kept {scope_max}/{len(xml_files)} "
                "unique instance(s); validating against reference"
            )

            for idx, xml_file in enumerate(selected_xml_files, start=1):
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


def score_output_general_instances_against_reference(
    model_name: str,
    generated_model: Path,
    reference_model: Path,
    max_scope: int,
    reference_general_counts_by_scope: dict[int, int],
    scripts_dir: Path,
    alloy_jar_620: Path,
    java17_bin: Path,
) -> dict:
    if max_scope <= 0:
        progress(f"[{model_name}] output=>original (general): no reference scopes found; skipping generation.")
        return {
            "score": 0,
            "max": 0,
            "by_scope": [],
            "timed_out": False,
            "timeout_scope": None,
            "timeout_scopes": [],
            "notes": ["No reference general scopes found; skipped output-instance generation."],
        }

    if not generated_model.exists():
        progress(f"[{model_name}] output=>original (general): generated model missing at {generated_model}")
        return {
            "score": 0,
            "max": 0,
            "by_scope": [{"scope": scope, "score": 0, "max": 0} for scope in range(1, max_scope + 1)],
            "timed_out": False,
            "timeout_scope": None,
            "timeout_scopes": [],
            "notes": [f"Generated model is missing: {generated_model}"],
        }

    total_score = 0
    total_max = 0
    by_scope: list[dict] = []
    notes: list[str] = []
    timed_out = False
    timeout_scope = None
    timeout_scopes: list[int] = []
    seen_instance_hashes: set[str] = set()

    with tempfile.TemporaryDirectory(prefix=f"general_score_{model_name}_") as temp_dir:
        temp_path = Path(temp_dir)
        temp_model = temp_path / f"{model_name}.als"

        try:
            temp_model.write_text(generated_model.read_text(encoding="utf-8"), encoding="utf-8")
        except Exception as exc:
            progress(f"[{model_name}] output=>original (general): failed preparing temp model: {exc}")
            return {
                "score": 0,
                "max": 0,
                "by_scope": [{"scope": scope, "score": 0, "max": 0} for scope in range(1, max_scope + 1)],
                "timed_out": False,
                "timeout_scope": None,
                "timeout_scopes": [],
                "notes": [f"Could not read generated model for general instance generation: {exc}"],
            }

        progress(
            f"[{model_name}] output=>original (general): running InstanceGenerator sequentially across {max_scope} scope(s)"
        )

        for scope in range(1, max_scope + 1):
            requested_instances = max(
                1,
                reference_general_counts_by_scope.get(scope, DEFAULT_GENERAL_OUTPUT_INSTANCE_COUNT),
            )
            progress(
                f"[{model_name}] output=>original (general): scope_{scope}/{max_scope} starting "
                f"(requesting up to {requested_instances})"
            )

            selected_xml_files: list[Path] = []
            selected_hashes: list[str] = []
            xml_files: list[Path] = []
            duplicate_count = 0
            exhausted = False
            generation_failed = False
            multiplier = 2

            while True:
                candidate_limit = requested_instances * multiplier
                progress(
                    f"[{model_name}] output=>original (general): scope_{scope} generating up to "
                    f"{candidate_limit} candidates ({multiplier}x)"
                )

                for stale in temp_path.glob(f"{model_name}-instance-{scope}-*.xml"):
                    stale.unlink(missing_ok=True)

                cmd = [
                    str(java17_bin),
                    "-cp",
                    f"{scripts_dir}{os.pathsep}{alloy_jar_620}",
                    "InstanceGenerator",
                    str(temp_model),
                    str(scope),
                    str(candidate_limit),
                ]

                try:
                    result = run_command(cmd, cwd=scripts_dir, timeout=GENERAL_INSTANCE_TIMEOUT_SECONDS)
                except subprocess.TimeoutExpired:
                    timed_out = True
                    timeout_scope = scope
                    timeout_scopes = [scope]
                    timeout_note = (
                        f"scope_{scope}: InstanceGenerator timed out after {GENERAL_INSTANCE_TIMEOUT_SECONDS}s; "
                        "remaining scopes skipped."
                    )
                    notes.append(timeout_note)
                    progress(f"[{model_name}] output=>original (general): {timeout_note}")
                    for stale in temp_path.glob(f"{model_name}-instance-{scope}-*.xml"):
                        stale.unlink(missing_ok=True)
                    generation_failed = True
                    break
                except Exception as exc:
                    err_note = f"scope_{scope}: InstanceGenerator invocation failed: {exc}"
                    notes.append(err_note)
                    progress(f"[{model_name}] output=>original (general): {err_note}")
                    by_scope.append({"scope": scope, "score": 0, "max": 0})
                    generation_failed = True
                    break

                output = ((result.stdout or "") + (result.stderr or "")).strip()
                if result.returncode != 0:
                    detail = output.splitlines()[-1] if output else "No output"
                    exit_note = f"scope_{scope}: InstanceGenerator exited with code {result.returncode} ({detail})"
                    notes.append(exit_note)
                    progress(f"[{model_name}] output=>original (general): {exit_note}")

                xml_files = sorted(temp_path.glob(f"{model_name}-instance-{scope}-*.xml"))
                selected_xml_files, selected_hashes, duplicate_count = select_unique_generated_instances(
                    xml_files,
                    seen_instance_hashes,
                    requested_instances,
                )
                progress(
                    f"[{model_name}] output=>original (general): scope_{scope} generated {len(xml_files)} "
                    f"instance(s), kept {len(selected_xml_files)} unique new instance(s)"
                )

                if len(selected_xml_files) >= requested_instances:
                    break
                if len(xml_files) < candidate_limit:
                    exhausted = True
                    break
                if multiplier >= MAX_GENERAL_CANDIDATE_MULTIPLIER:
                    exhausted = True
                    notes.append(
                        f"scope_{scope}: stopped after reaching {MAX_GENERAL_CANDIDATE_MULTIPLIER}x "
                        "general instance candidate limit."
                    )
                    break

                multiplier += 1

            if generation_failed:
                if timed_out:
                    break
                continue

            seen_instance_hashes.update(selected_hashes)

            if duplicate_count:
                notes.append(f"scope_{scope}: discarded {duplicate_count} duplicate general instance(s).")
            if exhausted and len(selected_xml_files) < requested_instances:
                notes.append(
                    f"scope_{scope}: InstanceGenerator exhausted after {len(xml_files)} candidate(s); "
                    f"kept {len(selected_xml_files)} unique new instance(s)."
                )

            scope_max = len(selected_xml_files)
            scope_valid = 0
            for idx, xml_file in enumerate(selected_xml_files, start=1):
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
                        f"[{model_name}] output=>original (general): scope_{scope} validated {idx}/{scope_max}"
                    )

            total_score += scope_valid
            total_max += scope_max
            by_scope.append({"scope": scope, "score": scope_valid, "max": scope_max})
            progress(
                f"[{model_name}] output=>original (general): scope_{scope} complete with {scope_valid}/{scope_max} valid"
            )

            for stale in temp_path.glob(f"{model_name}-instance-{scope}-*.xml"):
                stale.unlink(missing_ok=True)

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
    outputs_dir: Path,
    generated_model: Path,
    output_attempts: list[tuple[int, Path]],
    reference_model: Path,
    composat_instances_root: Path,
    general_instances_root: Path,
    scripts_dir: Path,
    diff_jar: Path,
    alloy_jar_620: Path,
    composat_jar: Path,
    java17_bin: Path,
    java8_bin: Path,
    composat_tmpdir: Path,
) -> dict:
    progress(f"[{model_name}] start scoring")
    progress(f"[{model_name}] syntax attempt scoring starting")
    syntax_attempt_score = compute_syntax_attempt_score(
        model_name,
        output_attempts,
        generated_model,
        diff_jar,
        java17_bin,
    )
    final_syntax_valid = syntax_attempt_score["final_syntax_ok"]
    progress(
        f"[{model_name}] syntax attempt score result: "
        f"{syntax_attempt_score['score']}/{syntax_attempt_score['max']}"
    )
    composat_instances_by_scope = discover_instances_by_scope(composat_instances_root, model_name)
    general_instances_by_scope = discover_general_instances_by_scope(general_instances_root, model_name)
    composat_max_scope = max(composat_instances_by_scope.keys(), default=0)
    general_max_scope = max(general_instances_by_scope.keys(), default=0)
    ringert_max_scope = max(composat_max_scope, general_max_scope)
    ringert_scopes = list(range(1, ringert_max_scope + 1))
    total_reference_composat_instances = sum(len(v) for v in composat_instances_by_scope.values())
    total_reference_general_instances = sum(len(v) for v in general_instances_by_scope.values())
    progress(
        f"[{model_name}] discovered CompoSAT reference instances: {total_reference_composat_instances} "
        f"across {len(composat_instances_by_scope)} scope(s); max scope {composat_max_scope}"
    )
    progress(
        f"[{model_name}] discovered general reference instances: {total_reference_general_instances} "
        f"across {len(general_instances_by_scope)} scope(s); max scope {general_max_scope}"
    )
    progress(
        f"[{model_name}] Ringert will run to max scope {ringert_max_scope} (max of CompoSAT/general)"
    )

    ringert_original_to_output_by_scope: list[dict] = []
    ringert_output_to_original_by_scope: list[dict] = []
    original_composat_instance_by_scope: list[dict] = []
    original_general_instance_by_scope: list[dict] = []

    ringert_original_to_output_score = 0
    ringert_output_to_original_score = 0

    # If Ringert triggers extends->in normalization, subsequent instance-check
    # passes must use the normalized model files too (otherwise they still trip
    # the same PrimSig/SubsetSig mismatch). The reference-side (original=>output)
    # pass would also need to re-generate its instances from the normalized
    # reference. `normalization_dir_holder` keeps the TemporaryDirectory alive
    # past the Ringert block so those later passes can read the files.
    normalization_dir_holder: list = []
    normalized_reference: Path | None = None
    normalized_generated: Path | None = None

    if final_syntax_valid:
        # When ModuleDiff crashes trying to merge a PrimSig against a same-named
        # SubsetSig (an ``extends`` vs ``in`` mismatch between the two models), we
        # retry the comparison on ``extends``->``in`` normalized copies of both
        # models. The copies are built lazily on the first crash and reused for
        # every scope.
        normalization = {"tried": False, "dir": None, "map": {}}

        def ringert_implies(left: Path, right: Path, scope: int) -> bool:
            if normalization["tried"]:
                left = normalization["map"].get(left, left)
                right = normalization["map"].get(right, right)
                equivalent, _ = semdiff_implication_holds(left, right, scope, diff_jar, java17_bin)
                return equivalent

            equivalent, output = semdiff_implication_holds(left, right, scope, diff_jar, java17_bin)
            if PRIMSIG_SUBSETSIG_MERGE_ERROR not in output:
                return equivalent

            # First PrimSig/SubsetSig crash: build normalized copies once.
            normalization["tried"] = True
            tmp = tempfile.TemporaryDirectory(prefix=f"extends2in_{model_name}_")
            normalization["dir"] = tmp
            tmp_path = Path(tmp.name)
            mapping: dict[Path, Path] = {}
            for tag, original in (("reference", reference_model), ("generated", generated_model)):
                dest = tmp_path / f"{tag}_{original.name}"
                if normalize_extends_to_in(original, dest, scripts_dir):
                    mapping[original] = dest
            normalization["map"] = mapping
            progress(
                f"[{model_name}] Ringert: PrimSig/SubsetSig merge error; "
                f"retrying on extends->in normalized models"
            )

            left_n = mapping.get(left, left)
            right_n = mapping.get(right, right)
            if left_n is left and right_n is right:
                # Normalization unavailable; keep the (crash) result.
                return equivalent
            equivalent, _ = semdiff_implication_holds(left_n, right_n, scope, diff_jar, java17_bin)
            return equivalent

        for scope in ringert_scopes:
            progress(f"[{model_name}] Ringert scope_{scope}/{ringert_max_scope}: checking implications")
            output_implies_original_ok = ringert_implies(reference_model, generated_model, scope)
            original_implies_output_ok = ringert_implies(generated_model, reference_model, scope)

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

        if normalization["dir"] is not None:
            normalization_dir_holder.append(normalization["dir"])
            normalized_reference = normalization["map"].get(reference_model)
            normalized_generated = normalization["map"].get(generated_model)
    else:
        progress(f"[{model_name}] final attempt syntax invalid; Ringert and instance checks will score 0 where applicable")
        for scope in ringert_scopes:
            ringert_output_to_original_by_scope.append({"scope": scope, "score": 0, "max": 1})
            ringert_original_to_output_by_scope.append({"scope": scope, "score": 0, "max": 1})

    original_composat_instance_score = 0
    original_composat_instance_max = 0

    if final_syntax_valid and normalized_reference is not None and normalized_generated is not None:
        progress(
            f"[{model_name}] original=>output (CompoSAT): regenerating instances from normalized reference"
        )
        original_composat_result = score_output_instances_against_reference(
            model_name=model_name,
            generated_model=normalized_reference,
            reference_model=normalized_generated,
            max_scope=composat_max_scope,
            scripts_dir=scripts_dir,
            alloy_jar_620=alloy_jar_620,
            composat_jar=composat_jar,
            java8_bin=java8_bin,
            java17_bin=java17_bin,
            composat_tmpdir=composat_tmpdir,
        )
        original_composat_instance_score = original_composat_result["score"]
        original_composat_instance_max = original_composat_result["max"]
        original_composat_instance_by_scope = original_composat_result["by_scope"]
    else:
        for scope, xml_files in composat_instances_by_scope.items():
            scope_valid = 0
            scope_max = len(xml_files)
            progress(
                f"[{model_name}] original=>output (CompoSAT): scope_{scope} validating {scope_max} instance(s)"
            )
            for idx, xml in enumerate(xml_files, start=1):
                if final_syntax_valid:
                    valid, _ = check_instance_valid(generated_model, xml, scripts_dir, alloy_jar_620, java17_bin)
                    if valid:
                        scope_valid += 1
                if idx % 25 == 0 or idx == scope_max:
                    progress(
                        f"[{model_name}] original=>output (CompoSAT): scope_{scope} validated {idx}/{scope_max} instance(s)"
                    )
                # Invalid syntax means all instances count as invalid (score remains 0).
            original_composat_instance_score += scope_valid
            original_composat_instance_max += scope_max
            original_composat_instance_by_scope.append({"scope": scope, "score": scope_valid, "max": scope_max})
            progress(
                f"[{model_name}] original=>output (CompoSAT): scope_{scope} complete with {scope_valid}/{scope_max} valid"
            )

    original_general_instance_score = 0
    original_general_instance_max = 0

    if final_syntax_valid and normalized_reference is not None and normalized_generated is not None:
        progress(
            f"[{model_name}] original=>output (general): regenerating instances from normalized reference"
        )
        original_general_result = score_output_general_instances_against_reference(
            model_name=model_name,
            generated_model=normalized_reference,
            reference_model=normalized_generated,
            max_scope=general_max_scope,
            reference_general_counts_by_scope={
                scope: len(xml_files) for scope, xml_files in general_instances_by_scope.items()
            },
            scripts_dir=scripts_dir,
            alloy_jar_620=alloy_jar_620,
            java17_bin=java17_bin,
        )
        original_general_instance_score = original_general_result["score"]
        original_general_instance_max = original_general_result["max"]
        original_general_instance_by_scope = original_general_result["by_scope"]
    else:
        for scope, xml_files in general_instances_by_scope.items():
            scope_valid = 0
            scope_max = len(xml_files)
            progress(
                f"[{model_name}] original=>output (general): scope_{scope} validating {scope_max} instance(s)"
            )
            for idx, xml in enumerate(xml_files, start=1):
                if final_syntax_valid:
                    valid, _ = check_instance_valid(generated_model, xml, scripts_dir, alloy_jar_620, java17_bin)
                    if valid:
                        scope_valid += 1
                if idx % 25 == 0 or idx == scope_max:
                    progress(
                        f"[{model_name}] original=>output (general): scope_{scope} validated {idx}/{scope_max}"
                    )

            original_general_instance_score += scope_valid
            original_general_instance_max += scope_max
            original_general_instance_by_scope.append({"scope": scope, "score": scope_valid, "max": scope_max})
            progress(
                f"[{model_name}] original=>output (general): scope_{scope} complete with {scope_valid}/{scope_max} valid"
            )

    output_composat_instance_result = score_output_instances_against_reference(
        model_name=model_name,
        generated_model=normalized_generated if normalized_generated is not None else generated_model,
        reference_model=normalized_reference if normalized_reference is not None else reference_model,
        max_scope=composat_max_scope,
        scripts_dir=scripts_dir,
        alloy_jar_620=alloy_jar_620,
        composat_jar=composat_jar,
        java8_bin=java8_bin,
        java17_bin=java17_bin,
        composat_tmpdir=composat_tmpdir,
    )
    progress(
        f"[{model_name}] output=>original (CompoSAT) summary: "
        f"{output_composat_instance_result['score']}/{output_composat_instance_result['max']}"
    )

    output_general_instance_result = score_output_general_instances_against_reference(
        model_name=model_name,
        generated_model=normalized_generated if normalized_generated is not None else generated_model,
        reference_model=normalized_reference if normalized_reference is not None else reference_model,
        max_scope=general_max_scope,
        reference_general_counts_by_scope={
            scope: len(xml_files) for scope, xml_files in general_instances_by_scope.items()
        },
        scripts_dir=scripts_dir,
        alloy_jar_620=alloy_jar_620,
        java17_bin=java17_bin,
    )
    progress(
        f"[{model_name}] output=>original (general) summary: "
        f"{output_general_instance_result['score']}/{output_general_instance_result['max']}"
    )

    ringert_original_to_output_max = len(ringert_scopes)
    ringert_output_to_original_max = len(ringert_scopes)

    total_score = (
        syntax_attempt_score["score"]
        + ringert_original_to_output_score
        + ringert_output_to_original_score
        + original_composat_instance_score
        + original_general_instance_score
        + output_composat_instance_result["score"]
        + output_general_instance_result["score"]
    )
    total_max = (
        syntax_attempt_score["max"]
        + ringert_original_to_output_max
        + ringert_output_to_original_max
        + original_composat_instance_max
        + original_general_instance_max
        + output_composat_instance_result["max"]
        + output_general_instance_result["max"]
    )

    for tmp in normalization_dir_holder:
        tmp.cleanup()

    progress(f"[{model_name}] finished with total {total_score}/{total_max}")

    return {
        "model": model_name,
        "outputs_dir": str(outputs_dir),
        "generated_file": str(generated_model),
        "reference_file": str(reference_model),
        "syntax_attempts": syntax_attempt_score,
        "directions": {
            "original_to_output": {
                "ringert": {
                    "score": ringert_original_to_output_score,
                    "max": ringert_original_to_output_max,
                    "by_scope": ringert_original_to_output_by_scope,
                },
                "composat_instances": {
                    "score": original_composat_instance_score,
                    "max": original_composat_instance_max,
                    "by_scope": original_composat_instance_by_scope,
                },
                "general_instances": {
                    "score": original_general_instance_score,
                    "max": original_general_instance_max,
                    "by_scope": original_general_instance_by_scope,
                },
            },
            "output_to_original": {
                "ringert": {
                    "score": ringert_output_to_original_score,
                    "max": ringert_output_to_original_max,
                    "by_scope": ringert_output_to_original_by_scope,
                },
                "composat_instances": output_composat_instance_result,
                "general_instances": output_general_instance_result,
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
    lines.append(f"General instance generation timeout per scope: {GENERAL_INSTANCE_TIMEOUT_SECONDS}s")
    lines.append(f"Model scoring parallelism: {MODEL_WORKERS} worker(s)")
    lines.append("")

    grand_score = 0
    grand_max = 0

    for result in results:
        lines.append(f"Model: {result['model']}")
        lines.append(f"  Generated: {result['generated_file']}")
        lines.append(f"  Reference: {result['reference_file']}")
        syntax_attempts = result["syntax_attempts"]
        lines.append(
            f"  Syntax attempts score: {syntax_attempts['score']}/{syntax_attempts['max']} "
            f"(first valid attempt: {syntax_attempts['first_valid_attempt']})"
        )
        lines.append(
            f"  Final attempt syntax valid: {'yes' if syntax_attempts['final_syntax_ok'] else 'no'}"
        )
        if syntax_attempts["final_syntax_message"] != "OK":
            lines.append(f"  Final attempt syntax detail: {syntax_attempts['final_syntax_message']}")
        lines.append("  Attempt history:")
        for attempt in syntax_attempts["attempts"]:
            lines.append(
                f"    attempt_{attempt['attempt']}: "
                f"{'OK' if attempt['syntax_ok'] else 'INVALID'} ({attempt['file']})"
            )
            if not attempt["syntax_ok"] and attempt["message"]:
                lines.append(f"      detail: {attempt['message']}")

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
            f"{original_to_output['composat_instances']['score']}/{original_to_output['composat_instances']['max']}"
        )
        for scope_row in original_to_output["composat_instances"]["by_scope"]:
            lines.append(
                f"      scope_{scope_row['scope']}: {scope_row['score']}/{scope_row['max']}"
            )
        lines.append(
            "    General instances from original model checked on output model: "
            f"{original_to_output['general_instances']['score']}/{original_to_output['general_instances']['max']}"
        )
        for scope_row in original_to_output["general_instances"]["by_scope"]:
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
            f"{output_to_original['composat_instances']['score']}/{output_to_original['composat_instances']['max']}"
        )
        for scope_row in output_to_original["composat_instances"]["by_scope"]:
            lines.append(
                f"      scope_{scope_row['scope']}: {scope_row['score']}/{scope_row['max']}"
            )
        if output_to_original["composat_instances"].get("timed_out"):
            timeout_scopes = output_to_original["composat_instances"].get("timeout_scopes") or []
            if timeout_scopes:
                formatted_scopes = ", ".join(f"scope_{scope}" for scope in timeout_scopes)
                lines.append(
                    f"    TIMEOUT: CompoSAT hit the {COMPOSAT_TIMEOUT_SECONDS}s limit at {formatted_scopes}."
                )
            else:
                timeout_scope = output_to_original["composat_instances"].get("timeout_scope")
                lines.append(
                    f"    TIMEOUT: CompoSAT hit the {COMPOSAT_TIMEOUT_SECONDS}s limit at scope_{timeout_scope}."
                )
        for note in output_to_original["composat_instances"].get("notes", []):
            lines.append(f"    Note: {note}")

        lines.append(
            "    General instances from output model checked on original model: "
            f"{output_to_original['general_instances']['score']}/{output_to_original['general_instances']['max']}"
        )
        for scope_row in output_to_original["general_instances"]["by_scope"]:
            lines.append(
                f"      scope_{scope_row['scope']}: {scope_row['score']}/{scope_row['max']}"
            )
        if output_to_original["general_instances"].get("timed_out"):
            timeout_scopes = output_to_original["general_instances"].get("timeout_scopes") or []
            if timeout_scopes:
                formatted_scopes = ", ".join(f"scope_{scope}" for scope in timeout_scopes)
                lines.append(
                    f"    TIMEOUT: InstanceGenerator hit the {GENERAL_INSTANCE_TIMEOUT_SECONDS}s limit at {formatted_scopes}."
                )
            else:
                timeout_scope = output_to_original["general_instances"].get("timeout_scope")
                lines.append(
                    f"    TIMEOUT: InstanceGenerator hit the {GENERAL_INSTANCE_TIMEOUT_SECONDS}s limit at scope_{timeout_scope}."
                )
        for note in output_to_original["general_instances"].get("notes", []):
            lines.append(f"    Note: {note}")

        lines.append(f"  TOTAL: {result['total']['score']}/{result['total']['max']}")
        lines.append("")

        grand_score += result["total"]["score"]
        grand_max += result["total"]["max"]

    lines.append("=" * 80)
    lines.append(f"OVERALL TOTAL: {grand_score}/{grand_max}")
    return "\n".join(lines) + "\n"


def main() -> int:
    if len(sys.argv) not in (5, 6):
        print(
            "Usage: python score.py <outputs_dir> <models_dir> <instances_dir> <general_instances_dir> [report_output]",
            file=sys.stderr,
        )
        return 1

    outputs_dir = Path(sys.argv[1]).resolve()
    models_dir = Path(sys.argv[2]).resolve()
    instances_dir = Path(sys.argv[3]).resolve()
    general_instances_dir = Path(sys.argv[4]).resolve()
    report_output = Path(sys.argv[5]).resolve() if len(sys.argv) == 6 else outputs_dir / "scores.txt"

    progress("Starting benchmark scoring run")
    progress(f"outputs_dir={outputs_dir}")
    progress(f"models_dir={models_dir}")
    progress(f"instances_dir={instances_dir}")
    progress(f"general_instances_dir={general_instances_dir}")
    progress(f"report_output={report_output}")
    progress(f"Model-level parallel workers={MODEL_WORKERS}")

    repo_root = Path(__file__).resolve().parent.parent
    scripts_dir = Path(__file__).resolve().parent
    scoring_dir = repo_root / "scoring"

    diff_jar = scoring_dir / "alloy-diff.jar"
    alloy_jar_620 = scoring_dir / "org.alloytools.alloy.dist-6.2.0.jar"
    composat_jar = scoring_dir / "CompoSAT.jar"

    progress("Checking required input paths and jar files")
    for path in [outputs_dir, models_dir, instances_dir, general_instances_dir, diff_jar, alloy_jar_620, composat_jar]:
        if not path.exists():
            print(f"Error: missing required path: {path}", file=sys.stderr)
            return 1

    try:
        progress("Resolving Java toolchains")
        java17_bin, javac17_bin = require_java_for_version(
            17,
            "alloy-diff, InstanceChecker, and InstanceGenerator",
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

    progress("Compiling InstanceGenerator.java")
    compiled, compile_msg = compile_instance_generator(scripts_dir, alloy_jar_620, javac17_bin)
    if not compiled:
        print(f"Error compiling InstanceGenerator.java: {compile_msg}", file=sys.stderr)
        return 1
    progress("InstanceGenerator compilation complete")

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
        generated_model, output_attempts = pick_final_generated_model(outputs_dir, model_name)
        if output_attempts:
            progress(
                f"[{model_name}] scoring final attempt file {generated_model.name} "
                f"from {len(output_attempts)} recorded attempt(s)"
            )
        else:
            progress(f"[{model_name}] no attempt history found; scoring legacy file {generated_model.name}")
        result = score_one_model(
            model_name=model_name,
            outputs_dir=outputs_dir,
            generated_model=generated_model,
            output_attempts=output_attempts,
            reference_model=reference_model,
            composat_instances_root=instances_dir,
            general_instances_root=general_instances_dir,
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
