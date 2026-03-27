#!/usr/bin/env python3
"""Score generated Alloy models against references and instances.

Usage:
    python score.py <outputs_dir> <models_dir> <instances_dir>
"""

import re
import subprocess
import sys
import tempfile
from collections import defaultdict
from pathlib import Path


TIMEOUT_SECONDS = 300
SOLVER = "sat4j"


def run_command(cmd: list[str], cwd: Path | None = None, timeout: int = TIMEOUT_SECONDS) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        cmd,
        capture_output=True,
        text=True,
        timeout=timeout,
        check=False,
        cwd=str(cwd) if cwd else None,
    )


def check_syntax(model_file: Path, diff_jar: Path) -> tuple[int, str]:
    if not model_file.exists():
        return 0, f"Missing generated file: {model_file}"

    cmd = [
        "java",
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


def semdiff_equivalent(left_model: Path, right_model: Path, scope: int, diff_jar: Path) -> tuple[bool, str]:
    cmd = [
        "java",
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


def compile_instance_checker(scripts_dir: Path, alloy_jar_620: Path) -> tuple[bool, str]:
    java_file = scripts_dir / "InstanceChecker.java"
    cmd = ["javac", "-cp", str(alloy_jar_620), str(java_file)]

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


def check_instance_valid(model_file: Path, xml_file: Path, scripts_dir: Path, alloy_jar_620: Path) -> tuple[bool, str]:
    cmd = [
        "java",
        "-cp",
        f"{scripts_dir}:{alloy_jar_620}",
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


def score_one_model(
    model_name: str,
    generated_model: Path,
    reference_model: Path,
    instances_root: Path,
    scripts_dir: Path,
    diff_jar: Path,
    alloy_jar_620: Path,
) -> dict:
    syntax_score, syntax_msg = check_syntax(generated_model, diff_jar)
    instances_by_scope = discover_instances_by_scope(instances_root, model_name)

    semdiff_by_scope: list[dict] = []
    instance_by_scope: list[dict] = []
    semdiff_score = 0
    semdiff_max = 0
    instance_score = 0
    instance_max = 0

    if syntax_score == 1:
        for scope in instances_by_scope.keys():
            forward_ok, _ = semdiff_equivalent(reference_model, generated_model, scope, diff_jar)
            backward_ok, _ = semdiff_equivalent(generated_model, reference_model, scope, diff_jar)
            s = int(forward_ok) + int(backward_ok)
            semdiff_score += s
            semdiff_max += 2
            semdiff_by_scope.append({"scope": scope, "score": s, "max": 2})
    else:
        for scope in instances_by_scope.keys():
            semdiff_max += 2
            semdiff_by_scope.append({"scope": scope, "score": 0, "max": 2})

    for scope, xml_files in instances_by_scope.items():
        scope_valid = 0
        for xml in xml_files:
            if syntax_score == 1:
                valid, _ = check_instance_valid(generated_model, xml, scripts_dir, alloy_jar_620)
                if valid:
                    scope_valid += 1
            # Invalid syntax means all instances count as invalid (score remains 0).
        scope_max = len(xml_files)
        instance_score += scope_valid
        instance_max += scope_max
        instance_by_scope.append({"scope": scope, "score": scope_valid, "max": scope_max})

    total_score = syntax_score + semdiff_score + instance_score
    total_max = 1 + semdiff_max + instance_max

    return {
        "model": model_name,
        "generated_file": str(generated_model),
        "reference_file": str(reference_model),
        "syntax": {"score": syntax_score, "max": 1, "message": syntax_msg},
        "semdiff": {"score": semdiff_score, "max": semdiff_max, "by_scope": semdiff_by_scope},
        "instances": {"score": instance_score, "max": instance_max, "by_scope": instance_by_scope},
        "total": {"score": total_score, "max": total_max},
    }


def build_report(results: list[dict]) -> str:
    lines: list[str] = []
    lines.append("Alloy Benchmark Scoring Report")
    lines.append("=" * 80)
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

        lines.append(
            f"  SemDiff (bidirectional, all scopes): {result['semdiff']['score']}/{result['semdiff']['max']}"
        )
        for scope_row in result["semdiff"]["by_scope"]:
            lines.append(
                f"    scope_{scope_row['scope']}: {scope_row['score']}/{scope_row['max']}"
            )

        lines.append(
            f"  Instance Validity (all scopes): {result['instances']['score']}/{result['instances']['max']}"
        )
        for scope_row in result["instances"]["by_scope"]:
            lines.append(
                f"    scope_{scope_row['scope']}: {scope_row['score']}/{scope_row['max']}"
            )

        lines.append(f"  TOTAL: {result['total']['score']}/{result['total']['max']}")
        lines.append("")

        grand_score += result["total"]["score"]
        grand_max += result["total"]["max"]

    lines.append("=" * 80)
    lines.append(f"OVERALL TOTAL: {grand_score}/{grand_max}")
    return "\n".join(lines) + "\n"


def main() -> int:
    if len(sys.argv) != 4:
        print(
            "Usage: python score.py <outputs_dir> <models_dir> <instances_dir>",
            file=sys.stderr,
        )
        return 1

    outputs_dir = Path(sys.argv[1]).resolve()
    models_dir = Path(sys.argv[2]).resolve()
    instances_dir = Path(sys.argv[3]).resolve()

    repo_root = Path(__file__).resolve().parent.parent
    scripts_dir = Path(__file__).resolve().parent
    scoring_dir = repo_root / "scoring"

    diff_jar = scoring_dir / "alloy-diff.jar"
    alloy_jar_620 = scoring_dir / "org.alloytools.alloy.dist-6.2.0.jar"

    for path in [outputs_dir, models_dir, instances_dir, diff_jar, alloy_jar_620]:
        if not path.exists():
            print(f"Error: missing required path: {path}", file=sys.stderr)
            return 1

    compiled, compile_msg = compile_instance_checker(scripts_dir, alloy_jar_620)
    if not compiled:
        print(f"Error compiling InstanceChecker.java: {compile_msg}", file=sys.stderr)
        return 1

    reference_models = sorted(models_dir.glob("*.als"))
    if not reference_models:
        print(f"Error: no .als files found in models dir: {models_dir}", file=sys.stderr)
        return 1

    results: list[dict] = []
    for reference_model in reference_models:
        model_name = reference_model.stem
        generated_model = outputs_dir / f"{model_name}.als"
        result = score_one_model(
            model_name=model_name,
            generated_model=generated_model,
            reference_model=reference_model,
            instances_root=instances_dir,
            scripts_dir=scripts_dir,
            diff_jar=diff_jar,
            alloy_jar_620=alloy_jar_620,
        )
        results.append(result)

    report_text = build_report(results)
    report_file = outputs_dir / "scores.txt"
    report_file.write_text(report_text, encoding="utf-8")

    print(report_text)
    print(f"Wrote report to: {report_file}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
