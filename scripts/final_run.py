#!/usr/bin/env python3
"""Run, score, and summarize the complete final benchmark campaign.

The default campaign runs every model alias configured in scripts/llm.py three
times. Work is resumable: completed generation, scoring, and final-score phases
are detected from their artifacts, while incomplete generation retries only the
descriptions that do not yet have a final .als output.
"""

from __future__ import annotations

import argparse
import csv
from datetime import datetime
import fcntl
import hashlib
import json
import os
from pathlib import Path
import re
import selectors
import shlex
import shutil
import subprocess
import sys
import tempfile
import time
from typing import TextIO

from final_score import final_score, parse_scores
from llm import MODEL_CONFIGS, PROVIDER_KEY_FILES
from syntax_utils import require_java_for_version


DEFAULT_RUN_COUNT = 3
DEFAULT_PHASE_ATTEMPTS = 3
DEFAULT_CAMPAIGN_PASSES = 2
DEFAULT_RETRY_DELAY_SECONDS = 30.0
DEFAULT_HEARTBEAT_SECONDS = 60.0
DEFAULT_SCORE_WORKERS = 4
MANIFEST_VERSION = 1
OVERALL_RE = re.compile(r"^OVERALL TOTAL: (\d+)/(\d+)$", re.MULTILINE)
FINAL_SCORE_RE = re.compile(r"^\d+(?:\.\d+)?$")


def timestamp() -> str:
    return datetime.now().astimezone().isoformat(timespec="seconds")


def atomic_write_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(f".{path.name}.tmp")
    temporary.write_text(text, encoding="utf-8")
    os.replace(temporary, path)


def atomic_write_json(path: Path, value: object) -> None:
    atomic_write_text(path, json.dumps(value, indent=2, sort_keys=True) + "\n")


class CampaignLog:
    def __init__(self, path: Path) -> None:
        path.parent.mkdir(parents=True, exist_ok=True)
        self._handle = path.open("a", encoding="utf-8")

    def close(self) -> None:
        self._handle.close()

    def emit(self, message: str, phase_log: TextIO | None = None) -> None:
        line = f"[{timestamp()}] {message}"
        print(line, flush=True)
        self._handle.write(line + "\n")
        self._handle.flush()
        if phase_log is not None:
            phase_log.write(line + "\n")
            phase_log.flush()


class PhaseFailure(RuntimeError):
    pass


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--root",
        type=Path,
        default=Path("finalRun"),
        help="Campaign output directory, relative to the repository root by default.",
    )
    parser.add_argument(
        "--runs",
        type=int,
        default=DEFAULT_RUN_COUNT,
        help=f"Runs per model for a new campaign (default: {DEFAULT_RUN_COUNT}).",
    )
    parser.add_argument(
        "--models",
        nargs="+",
        choices=sorted(MODEL_CONFIGS),
        help="Run only these aliases. A new campaign records only the selected aliases.",
    )
    parser.add_argument(
        "--run-numbers",
        nargs="+",
        type=int,
        help="Run only these run numbers; useful for targeted recovery.",
    )
    parser.add_argument(
        "--python",
        type=Path,
        help="Python executable for child scripts. Defaults to venv/bin/python when present.",
    )
    parser.add_argument(
        "--score-workers",
        type=int,
        default=DEFAULT_SCORE_WORKERS,
        help=f"SCORE_MODEL_WORKERS value (default: {DEFAULT_SCORE_WORKERS}).",
    )
    parser.add_argument(
        "--phase-attempts",
        type=int,
        default=DEFAULT_PHASE_ATTEMPTS,
        help=f"Attempts per failed generation/scoring phase (default: {DEFAULT_PHASE_ATTEMPTS}).",
    )
    parser.add_argument(
        "--campaign-passes",
        type=int,
        default=DEFAULT_CAMPAIGN_PASSES,
        help=f"Passes over incomplete jobs (default: {DEFAULT_CAMPAIGN_PASSES}).",
    )
    parser.add_argument(
        "--retry-delay-seconds",
        type=float,
        default=DEFAULT_RETRY_DELAY_SECONDS,
        help=f"Base delay between phase retries (default: {DEFAULT_RETRY_DELAY_SECONDS}).",
    )
    parser.add_argument(
        "--heartbeat-seconds",
        type=float,
        default=DEFAULT_HEARTBEAT_SECONDS,
        help=f"Progress heartbeat interval for quiet subprocesses (default: {DEFAULT_HEARTBEAT_SECONDS}).",
    )
    parser.add_argument(
        "--allow-input-changes",
        action="store_true",
        help="Resume even if benchmark inputs differ from the campaign manifest.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print the planned jobs and exit without creating files or making API calls.",
    )
    parser.add_argument(
        "--preflight-only",
        action="store_true",
        help="Validate all prerequisites and exit without creating a campaign.",
    )
    parser.add_argument(
        "--summarize-only",
        action="store_true",
        help="Rebuild summaries from existing reports without running generation or scoring.",
    )
    return parser


def resolve_repo_path(repo_root: Path, value: Path) -> Path:
    return value.resolve() if value.is_absolute() else (repo_root / value).resolve()


def resolve_child_python(repo_root: Path, requested: Path | None) -> Path:
    if requested is not None:
        candidate = resolve_repo_path(repo_root, requested)
    else:
        venv_python = repo_root / "venv" / "bin" / "python"
        candidate = venv_python if venv_python.exists() else Path(sys.executable)
    if not candidate.exists() or not os.access(candidate, os.X_OK):
        raise RuntimeError(f"Python executable is unavailable: {candidate}")
    # Do not call resolve() here: venv/bin/python is normally a symlink, and
    # invoking its resolved system target bypasses the virtual environment's
    # installed packages.
    return candidate.absolute()


def description_files(repo_root: Path) -> list[Path]:
    return sorted((repo_root / "benchmark" / "descriptions").glob("*.md"))


def reference_model_files(repo_root: Path) -> list[Path]:
    return sorted((repo_root / "benchmark" / "models").glob("*.als"))


def validate_repo_layout(repo_root: Path) -> list[Path]:
    descriptions = description_files(repo_root)
    references = reference_model_files(repo_root)
    if not descriptions:
        raise RuntimeError("No benchmark descriptions were found")
    if not references:
        raise RuntimeError("No benchmark reference models were found")

    description_names = {path.stem for path in descriptions}
    reference_names = {path.stem for path in references}
    if description_names != reference_names:
        only_descriptions = sorted(description_names - reference_names)
        only_references = sorted(reference_names - description_names)
        raise RuntimeError(
            "Description/reference model names differ exactly (including case). "
            f"Descriptions only: {only_descriptions}; references only: {only_references}"
        )

    required = [
        repo_root / "scripts" / "main.py",
        repo_root / "scripts" / "score.py",
        repo_root / "scripts" / "final_score.py",
        repo_root / "benchmark" / "instances",
        repo_root / "benchmark" / "generalInstances",
        repo_root / "scoring" / "alloy-diff.jar",
        repo_root / "scoring" / "CompoSAT.jar",
        repo_root / "scoring" / "org.alloytools.alloy.dist-6.2.0.jar",
        repo_root / "prompts" / "english-alloy-prefix.txt",
        repo_root / "prompts" / "english-alloy-suffix.txt",
    ]
    missing = [str(path) for path in required if not path.exists()]
    if missing:
        raise RuntimeError(f"Missing required benchmark paths: {missing}")
    return descriptions


def validate_runtime(
    repo_root: Path,
    child_python: Path,
    models: list[str],
) -> None:
    providers = {MODEL_CONFIGS[model]["provider"] for model in models}
    for provider in sorted(providers):
        key_path = repo_root / "secret" / PROVIDER_KEY_FILES[provider]
        if not key_path.exists() or not key_path.read_text(encoding="utf-8").strip():
            raise RuntimeError(f"Missing or empty {provider} API key: {key_path}")

    if "openai" in providers:
        result = subprocess.run(
            [str(child_python), "-c", "import openai"],
            cwd=repo_root,
            capture_output=True,
            text=True,
            check=False,
        )
        if result.returncode != 0:
            raise RuntimeError(
                f"The OpenAI package is unavailable in {child_python}: {result.stderr.strip()}"
            )

    require_java_for_version(17, "generation and scoring", require_javac=True)
    require_java_for_version(8, "CompoSAT scoring")


def campaign_input_files(repo_root: Path) -> list[Path]:
    paths: list[Path] = []
    for relative in [
        "benchmark/descriptions",
        "benchmark/models",
        "benchmark/instances",
        "benchmark/generalInstances",
    ]:
        paths.extend(path for path in (repo_root / relative).rglob("*") if path.is_file())
    for relative in [
        "prompts/english-alloy-prefix.txt",
        "prompts/english-alloy-suffix.txt",
        "scripts/llm.py",
        "scripts/main.py",
        "scripts/score.py",
        "scripts/final_score.py",
        "scripts/InstanceChecker.java",
        "scripts/InstanceGenerator.java",
        "scripts/extends_to_in.py",
        "scripts/instance_dedup.py",
        "scoring/alloy-diff.jar",
        "scoring/CompoSAT.jar",
        "scoring/org.alloytools.alloy.dist-6.2.0.jar",
    ]:
        paths.append(repo_root / relative)
    return sorted(set(paths), key=lambda path: str(path.relative_to(repo_root)))


def input_digest(repo_root: Path) -> str:
    digest = hashlib.sha256()
    for path in campaign_input_files(repo_root):
        relative = str(path.relative_to(repo_root)).encode("utf-8")
        digest.update(len(relative).to_bytes(4, "big"))
        digest.update(relative)
        with path.open("rb") as handle:
            while chunk := handle.read(1024 * 1024):
                digest.update(chunk)
    return digest.hexdigest()


def build_manifest(
    models: list[str],
    runs: int,
    descriptions: list[Path],
    child_python: Path,
    digest: str,
) -> dict:
    return {
        "version": MANIFEST_VERSION,
        "created_at": timestamp(),
        "models": models,
        "model_configs": {model: MODEL_CONFIGS[model] for model in models},
        "runs_per_model": runs,
        "description_names": [path.stem for path in descriptions],
        "python": str(child_python),
        "input_sha256": digest,
    }


def load_manifest(path: Path) -> dict:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise RuntimeError(f"Cannot read campaign manifest {path}: {error}") from error
    if value.get("version") != MANIFEST_VERSION:
        raise RuntimeError(f"Unsupported campaign manifest version in {path}")
    return value


def validate_manifest(
    manifest: dict,
    descriptions: list[Path],
    current_digest: str,
    allow_input_changes: bool,
) -> None:
    expected_names = [path.stem for path in descriptions]
    problems: list[str] = []
    if manifest.get("description_names") != expected_names:
        problems.append("description list changed")
    for model in manifest.get("models", []):
        if model not in MODEL_CONFIGS:
            problems.append(f"model alias removed: {model}")
        elif manifest.get("model_configs", {}).get(model) != MODEL_CONFIGS[model]:
            problems.append(f"model configuration changed: {model}")
    if manifest.get("input_sha256") != current_digest:
        problems.append("benchmark input digest changed")
    if problems and not allow_input_changes:
        raise RuntimeError(
            "Refusing to mix changed inputs into an existing campaign: "
            + "; ".join(problems)
            + ". Use --allow-input-changes only after reviewing the differences."
        )


def run_streamed_command(
    command: list[str],
    cwd: Path,
    env: dict[str, str],
    log_path: Path,
    label: str,
    heartbeat_seconds: float,
    campaign_log: CampaignLog,
) -> tuple[int, float]:
    log_path.parent.mkdir(parents=True, exist_ok=True)
    start = time.monotonic()
    with log_path.open("a", encoding="utf-8") as phase_log:
        campaign_log.emit(f"[{label}] command: {shlex.join(command)}", phase_log)
        process = subprocess.Popen(
            command,
            cwd=cwd,
            env=env,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            encoding="utf-8",
            errors="replace",
            bufsize=1,
        )
        if process.stdout is None:
            raise RuntimeError("Unable to capture subprocess output")

        selector = selectors.DefaultSelector()
        selector.register(process.stdout, selectors.EVENT_READ)
        last_output = time.monotonic()
        try:
            while selector.get_map():
                events = selector.select(timeout=min(5.0, heartbeat_seconds))
                if events:
                    for key, _ in events:
                        line = key.fileobj.readline()
                        if line:
                            campaign_log.emit(f"[{label}] {line.rstrip()}", phase_log)
                            last_output = time.monotonic()
                        else:
                            selector.unregister(key.fileobj)
                elif process.poll() is not None:
                    break

                now = time.monotonic()
                if now - last_output >= heartbeat_seconds:
                    elapsed = now - start
                    campaign_log.emit(
                        f"[{label}] heartbeat: subprocess still running after {elapsed / 60:.1f} min",
                        phase_log,
                    )
                    last_output = now
        except KeyboardInterrupt:
            campaign_log.emit(f"[{label}] interrupted; terminating child process", phase_log)
            process.terminate()
            try:
                process.wait(timeout=10)
            except subprocess.TimeoutExpired:
                process.kill()
            raise
        finally:
            selector.close()

        return_code = process.wait()
        elapsed = time.monotonic() - start
        campaign_log.emit(
            f"[{label}] exit={return_code}; elapsed={elapsed / 60:.1f} min",
            phase_log,
        )
        return return_code, elapsed


def expected_final_outputs(run_dir: Path, descriptions: list[Path]) -> list[Path]:
    return [run_dir / f"{description.stem}.als" for description in descriptions]


def missing_descriptions(run_dir: Path, descriptions: list[Path]) -> list[Path]:
    return [
        description
        for description, output in zip(descriptions, expected_final_outputs(run_dir, descriptions))
        if not output.is_file()
    ]


def report_is_complete(report: Path, model_count: int, outputs: list[Path]) -> bool:
    if not report.is_file() or any(not output.is_file() for output in outputs):
        return False
    if report.stat().st_mtime < max(output.stat().st_mtime for output in outputs):
        return False
    text = report.read_text(encoding="utf-8", errors="replace")
    return text.count("Model: ") == model_count and OVERALL_RE.search(text) is not None


def final_score_is_complete(path: Path, report: Path) -> bool:
    if not path.is_file() or path.stat().st_mtime < report.stat().st_mtime:
        return False
    return FINAL_SCORE_RE.fullmatch(path.read_text(encoding="utf-8").strip()) is not None


def update_job_state(state_path: Path, job_key: str, **values: object) -> None:
    if state_path.exists():
        try:
            state = json.loads(state_path.read_text(encoding="utf-8"))
        except json.JSONDecodeError:
            state = {}
    else:
        state = {}
    state.setdefault("jobs", {}).setdefault(job_key, {}).update(values)
    state["updated_at"] = timestamp()
    atomic_write_json(state_path, state)


def generate_missing_outputs(
    model: str,
    run_number: int,
    run_dir: Path,
    descriptions: list[Path],
    child_python: Path,
    repo_root: Path,
    env: dict[str, str],
    args: argparse.Namespace,
    campaign_log: CampaignLog,
) -> float:
    total_elapsed = 0.0
    for attempt in range(1, args.phase_attempts + 1):
        missing = missing_descriptions(run_dir, descriptions)
        if not missing:
            return total_elapsed

        campaign_log.emit(
            f"[{model}/run-{run_number}/generation] phase attempt {attempt}/{args.phase_attempts}; "
            f"{len(missing)} description(s) missing"
        )
        with tempfile.TemporaryDirectory(prefix="alloy-final-descriptions-") as temp_name:
            subset_dir = Path(temp_name)
            for description in missing:
                shutil.copy2(description, subset_dir / description.name)
            command = [
                str(child_python),
                str(repo_root / "scripts" / "main.py"),
                str(subset_dir),
                str(run_dir),
                "--model",
                model,
            ]
            return_code, elapsed = run_streamed_command(
                command,
                repo_root,
                env,
                run_dir / "generation.log",
                f"{model}/run-{run_number}/generation",
                args.heartbeat_seconds,
                campaign_log,
            )
            total_elapsed += elapsed

        missing_after = missing_descriptions(run_dir, descriptions)
        if not missing_after:
            return total_elapsed
        campaign_log.emit(
            f"[{model}/run-{run_number}/generation] exit={return_code}; "
            f"still missing {[path.name for path in missing_after]}"
        )
        if attempt < args.phase_attempts:
            delay = args.retry_delay_seconds * attempt
            campaign_log.emit(
                f"[{model}/run-{run_number}/generation] retrying missing outputs in {delay:.0f}s"
            )
            time.sleep(delay)

    missing = [path.name for path in missing_descriptions(run_dir, descriptions)]
    raise PhaseFailure(f"generation exhausted retries; missing outputs: {missing}")


def run_phase_with_retries(
    phase: str,
    model: str,
    run_number: int,
    command: list[str],
    completion_check,
    log_path: Path,
    child_env: dict[str, str],
    repo_root: Path,
    args: argparse.Namespace,
    campaign_log: CampaignLog,
) -> float:
    total_elapsed = 0.0
    for attempt in range(1, args.phase_attempts + 1):
        label = f"{model}/run-{run_number}/{phase}"
        campaign_log.emit(f"[{label}] phase attempt {attempt}/{args.phase_attempts}")
        return_code, elapsed = run_streamed_command(
            command,
            repo_root,
            child_env,
            log_path,
            label,
            args.heartbeat_seconds,
            campaign_log,
        )
        total_elapsed += elapsed
        if return_code == 0 and completion_check():
            return total_elapsed
        campaign_log.emit(
            f"[{label}] incomplete after exit={return_code}"
        )
        if attempt < args.phase_attempts:
            delay = args.retry_delay_seconds * attempt
            campaign_log.emit(f"[{label}] retrying in {delay:.0f}s")
            time.sleep(delay)
    raise PhaseFailure(f"{phase} exhausted {args.phase_attempts} attempt(s)")


def score_report_values(report: Path) -> tuple[float, str]:
    exact_score = final_score(parse_scores(report))
    overall_match = OVERALL_RE.search(report.read_text(encoding="utf-8", errors="replace"))
    if overall_match is None:
        raise ValueError(f"Missing OVERALL TOTAL in {report}")
    return exact_score, f"{overall_match.group(1)}/{overall_match.group(2)}"


def collect_campaign_results(root: Path, manifest: dict) -> dict[str, list[dict]]:
    results: dict[str, list[dict]] = {}
    for model in manifest["models"]:
        model_results: list[dict] = []
        for run_number in range(1, manifest["runs_per_model"] + 1):
            run_dir = root / model / f"run-{run_number}"
            report = run_dir / "scores.txt"
            if not report.is_file():
                model_results.append({"run": run_number, "status": "pending"})
                continue
            try:
                exact_score, raw_overall = score_report_values(report)
            except (OSError, ValueError, ZeroDivisionError) as error:
                model_results.append(
                    {"run": run_number, "status": "invalid-report", "error": str(error)}
                )
                continue
            model_results.append(
                {
                    "run": run_number,
                    "status": "complete",
                    "score": round(exact_score, 10),
                    "display_score": f"{exact_score:.1f}",
                    "raw_overall": raw_overall,
                    "scores_file": str(report.relative_to(root)),
                    "final_score_file": str((run_dir / "final_score.txt").relative_to(root)),
                }
            )
        results[model] = model_results
    return results


def write_summaries(root: Path, manifest: dict) -> dict[str, list[dict]]:
    results = collect_campaign_results(root, manifest)
    summary_json: dict[str, object] = {
        "updated_at": timestamp(),
        "runs_per_model": manifest["runs_per_model"],
        "models": {},
    }
    top_lines = [
        "Final Alloy benchmark campaign",
        f"Updated: {timestamp()}",
        "",
        "Model | "
        + " | ".join(
            [
                *[f"Run {number}" for number in range(1, manifest["runs_per_model"] + 1)],
                "Average",
            ]
        ),
        "--- | "
        + " | ".join("---:" for _ in range(manifest["runs_per_model"] + 1)),
    ]
    csv_rows: list[list[str]] = [
        [
            "model",
            *[
                f"run_{number}"
                for number in range(1, manifest["runs_per_model"] + 1)
            ],
            "average",
        ]
    ]

    for model in manifest["models"]:
        rows = results[model]
        completed = [row for row in rows if row["status"] == "complete"]
        average = (
            sum(float(row["score"]) for row in completed) / len(completed)
            if completed
            else None
        )
        final_average = average if len(completed) == manifest["runs_per_model"] else None
        displays = [
            f"{row['display_score']} ({row['raw_overall']})"
            if row["status"] == "complete"
            else row["status"]
            for row in rows
        ]
        average_display = f"{final_average:.1f}" if final_average is not None else "pending"
        top_lines.append(f"{model} | " + " | ".join(displays + [average_display]))
        csv_rows.append(
            [
                model,
                *[
                    row["display_score"] if row["status"] == "complete" else ""
                    for row in rows
                ],
                average_display if final_average is not None else "",
            ]
        )

        model_lines = [
            f"Model: {model}",
            f"API model: {manifest['model_configs'][model]['api_model']}",
            "",
        ]
        for row in rows:
            if row["status"] == "complete":
                model_lines.append(
                    f"Run {row['run']}: {row['display_score']}/100 "
                    f"(raw overall {row['raw_overall']})"
                )
            else:
                model_lines.append(f"Run {row['run']}: {row['status']}")
        model_lines.extend(
            [
                "",
                f"Completed runs: {len(completed)}/{manifest['runs_per_model']}",
                f"Average final score: {average_display}/100" if final_average is not None else "Average final score: pending",
            ]
        )
        atomic_write_text(root / model / "summary.txt", "\n".join(model_lines) + "\n")
        summary_json["models"][model] = {
            "runs": rows,
            "completed_runs": len(completed),
            "average_score": round(final_average, 1) if final_average is not None else None,
        }

    atomic_write_text(root / "summary.txt", "\n".join(top_lines) + "\n")
    csv_path = root / "summary.csv"
    temporary_csv = csv_path.with_name(f".{csv_path.name}.tmp")
    with temporary_csv.open("w", encoding="utf-8", newline="") as handle:
        csv.writer(handle).writerows(csv_rows)
    os.replace(temporary_csv, csv_path)
    atomic_write_json(root / "summary.json", summary_json)
    return results


def execute_job(
    model: str,
    run_number: int,
    root: Path,
    descriptions: list[Path],
    manifest: dict,
    child_python: Path,
    repo_root: Path,
    child_env: dict[str, str],
    args: argparse.Namespace,
    campaign_log: CampaignLog,
) -> bool:
    run_dir = root / model / f"run-{run_number}"
    run_dir.mkdir(parents=True, exist_ok=True)
    job_key = f"{model}/run-{run_number}"
    state_path = root / "progress.json"
    outputs = expected_final_outputs(run_dir, descriptions)
    report = run_dir / "scores.txt"
    final_score_path = run_dir / "final_score.txt"
    started_at = timestamp()
    update_job_state(state_path, job_key, status="running", started_at=started_at)
    campaign_log.emit(f"[{job_key}] starting or resuming")

    try:
        generation_elapsed = 0.0
        if missing_descriptions(run_dir, descriptions):
            generation_elapsed = generate_missing_outputs(
                model,
                run_number,
                run_dir,
                descriptions,
                child_python,
                repo_root,
                child_env,
                args,
                campaign_log,
            )
        else:
            campaign_log.emit(f"[{job_key}] generation already complete; skipping")
        update_job_state(
            state_path,
            job_key,
            generation="complete",
            generated_outputs=len(outputs),
            generation_elapsed_seconds=round(generation_elapsed, 3),
        )

        if not report_is_complete(report, len(descriptions), outputs):
            # Old CompoSAT extracts about 155 MB of native libraries into its
            # Java temp directory on every invocation and does not remove
            # them.  Give each run a private temp directory so those extracts
            # cannot accumulate across the campaign.  Clearing it before a
            # retry also recovers cleanly from a killed or disk-full scorer.
            scoring_tmp_dir = run_dir / ".alloy-tmp"
            shutil.rmtree(scoring_tmp_dir, ignore_errors=True)
            scoring_env = child_env.copy()
            scoring_env["ALLOY_TMPDIR"] = str(scoring_tmp_dir)
            score_command = [
                str(child_python),
                str(repo_root / "scripts" / "score.py"),
                str(run_dir),
                str(repo_root / "benchmark" / "models"),
                str(repo_root / "benchmark" / "instances"),
                str(repo_root / "benchmark" / "generalInstances"),
                str(report),
            ]
            try:
                scoring_elapsed = run_phase_with_retries(
                    "scoring",
                    model,
                    run_number,
                    score_command,
                    lambda: report_is_complete(report, len(descriptions), outputs),
                    run_dir / "scoring.log",
                    scoring_env,
                    repo_root,
                    args,
                    campaign_log,
                )
            finally:
                shutil.rmtree(scoring_tmp_dir, ignore_errors=True)
        else:
            scoring_elapsed = 0.0
            campaign_log.emit(f"[{job_key}] scoring already complete and current; skipping")
        update_job_state(
            state_path,
            job_key,
            scoring="complete",
            scoring_elapsed_seconds=round(scoring_elapsed, 3),
        )

        if not final_score_is_complete(final_score_path, report):
            final_command = [
                str(child_python),
                str(repo_root / "scripts" / "final_score.py"),
                str(report),
                str(final_score_path),
            ]
            final_elapsed = run_phase_with_retries(
                "final-score",
                model,
                run_number,
                final_command,
                lambda: final_score_is_complete(final_score_path, report),
                run_dir / "final-score.log",
                child_env,
                repo_root,
                args,
                campaign_log,
            )
        else:
            final_elapsed = 0.0
            campaign_log.emit(f"[{job_key}] final score already complete and current; skipping")

        exact_score, raw_overall = score_report_values(report)
        update_job_state(
            state_path,
            job_key,
            status="complete",
            generation="complete",
            scoring="complete",
            final_score="complete",
            score=round(exact_score, 10),
            display_score=f"{exact_score:.1f}",
            raw_overall=raw_overall,
            final_score_elapsed_seconds=round(final_elapsed, 3),
            completed_at=timestamp(),
            error=None,
        )
        campaign_log.emit(
            f"[{job_key}] COMPLETE: final={exact_score:.1f}/100; raw={raw_overall}"
        )
        write_summaries(root, manifest)
        return True
    except (OSError, ValueError, PhaseFailure, subprocess.SubprocessError) as error:
        update_job_state(
            state_path,
            job_key,
            status="failed",
            failed_at=timestamp(),
            error=str(error),
        )
        campaign_log.emit(f"[{job_key}] FAILED: {error}")
        write_summaries(root, manifest)
        return False


def job_is_complete(
    model: str,
    run_number: int,
    root: Path,
    descriptions: list[Path],
) -> bool:
    run_dir = root / model / f"run-{run_number}"
    outputs = expected_final_outputs(run_dir, descriptions)
    report = run_dir / "scores.txt"
    final_path = run_dir / "final_score.txt"
    return report_is_complete(report, len(descriptions), outputs) and final_score_is_complete(
        final_path, report
    )


def print_dry_run(root: Path, models: list[str], run_numbers: list[int]) -> None:
    print(f"Campaign root: {root}")
    print(f"Models ({len(models)}): {', '.join(models)}")
    print(f"Runs: {', '.join(map(str, run_numbers))}")
    print(f"Planned jobs: {len(models) * len(run_numbers)}")
    print("Execution order is round-robin by run number:")
    for run_number in run_numbers:
        for model in models:
            print(f"  {root / model / f'run-{run_number}'}")


def main() -> int:
    args = build_parser().parse_args()
    if args.runs < 1:
        raise SystemExit("--runs must be at least 1")
    if args.phase_attempts < 1 or args.campaign_passes < 1:
        raise SystemExit("--phase-attempts and --campaign-passes must be at least 1")
    if args.score_workers < 1:
        raise SystemExit("--score-workers must be at least 1")
    if args.heartbeat_seconds <= 0 or args.retry_delay_seconds < 0:
        raise SystemExit("Heartbeat must be positive and retry delay cannot be negative")

    repo_root = Path(__file__).resolve().parent.parent
    root = resolve_repo_path(repo_root, args.root)
    child_python = resolve_child_python(repo_root, args.python)
    descriptions = validate_repo_layout(repo_root)
    requested_models = args.models or list(MODEL_CONFIGS)
    requested_run_numbers = args.run_numbers or list(range(1, args.runs + 1))
    if len(set(requested_models)) != len(requested_models):
        raise SystemExit("--models contains duplicates")
    if len(set(requested_run_numbers)) != len(requested_run_numbers):
        raise SystemExit("--run-numbers contains duplicates")
    if any(number < 1 or number > args.runs for number in requested_run_numbers):
        raise SystemExit(f"--run-numbers must be between 1 and {args.runs}")

    if args.dry_run:
        print_dry_run(root, requested_models, requested_run_numbers)
        return 0

    if args.summarize_only:
        manifest_path = root / "manifest.json"
        if not manifest_path.exists():
            raise SystemExit(f"Campaign manifest not found: {manifest_path}")
        manifest = load_manifest(manifest_path)
        write_summaries(root, manifest)
        print(f"Summaries rebuilt under {root}")
        return 0

    validate_runtime(repo_root, child_python, requested_models)
    if args.preflight_only:
        print(
            f"Preflight OK: {len(requested_models)} model(s), {len(descriptions)} descriptions, "
            f"Python={child_python}"
        )
        return 0

    root.mkdir(parents=True, exist_ok=True)
    lock_path = root / ".campaign.lock"
    with lock_path.open("a+", encoding="utf-8") as lock_handle:
        try:
            fcntl.flock(lock_handle.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            print(f"Another final-run process already holds {lock_path}", file=sys.stderr)
            return 2

        campaign_log = CampaignLog(root / "orchestrator.log")
        try:
            manifest_path = root / "manifest.json"
            current_digest = input_digest(repo_root)
            if manifest_path.exists():
                manifest = load_manifest(manifest_path)
                validate_manifest(
                    manifest,
                    descriptions,
                    current_digest,
                    args.allow_input_changes,
                )
                campaign_models = list(manifest["models"])
                run_count = int(manifest["runs_per_model"])
                if args.models:
                    unknown = sorted(set(args.models) - set(campaign_models))
                    if unknown:
                        raise RuntimeError(f"Models are not part of this campaign: {unknown}")
                    selected_models = args.models
                else:
                    selected_models = campaign_models
                if args.run_numbers:
                    if any(number > run_count for number in args.run_numbers):
                        raise RuntimeError(
                            f"Run numbers exceed existing campaign size {run_count}: {args.run_numbers}"
                        )
                    selected_run_numbers = args.run_numbers
                else:
                    selected_run_numbers = list(range(1, run_count + 1))
                campaign_log.emit(f"Resuming campaign at {root}")
            else:
                if any(root.iterdir()):
                    allowed = {
                        lock_path.name,
                        "orchestrator.log",
                        ".manifest.json.tmp",
                    }
                    unexpected = sorted(path.name for path in root.iterdir() if path.name not in allowed)
                    if unexpected:
                        raise RuntimeError(
                            f"Refusing to start a new campaign in non-empty {root}: {unexpected}"
                        )
                campaign_models = requested_models
                run_count = args.runs
                selected_models = campaign_models
                selected_run_numbers = requested_run_numbers
                manifest = build_manifest(
                    campaign_models,
                    run_count,
                    descriptions,
                    child_python,
                    current_digest,
                )
                atomic_write_json(manifest_path, manifest)
                campaign_log.emit(
                    f"Created campaign at {root}: {len(campaign_models)} model(s) x "
                    f"{run_count} run(s)"
                )

            for model in campaign_models:
                (root / model).mkdir(parents=True, exist_ok=True)
            write_summaries(root, manifest)

            child_env = os.environ.copy()
            child_env["PYTHONUNBUFFERED"] = "1"
            child_env["SCORE_MODEL_WORKERS"] = str(args.score_workers)
            planned_jobs = [
                (model, run_number)
                for run_number in selected_run_numbers
                for model in selected_models
            ]

            for campaign_pass in range(1, args.campaign_passes + 1):
                incomplete = [
                    job
                    for job in planned_jobs
                    if not job_is_complete(job[0], job[1], root, descriptions)
                ]
                if not incomplete:
                    break
                campaign_log.emit(
                    f"Campaign pass {campaign_pass}/{args.campaign_passes}: "
                    f"{len(incomplete)} incomplete job(s)"
                )
                for model, run_number in incomplete:
                    execute_job(
                        model,
                        run_number,
                        root,
                        descriptions,
                        manifest,
                        child_python,
                        repo_root,
                        child_env,
                        args,
                        campaign_log,
                    )

            write_summaries(root, manifest)
            incomplete = [
                f"{model}/run-{run_number}"
                for model, run_number in planned_jobs
                if not job_is_complete(model, run_number, root, descriptions)
            ]
            if incomplete:
                campaign_log.emit(f"Campaign ended with incomplete jobs: {incomplete}")
                return 1

            all_campaign_complete = all(
                job_is_complete(model, run_number, root, descriptions)
                for model in campaign_models
                for run_number in range(1, run_count + 1)
            )
            if all_campaign_complete:
                atomic_write_text(
                    root / "COMPLETE",
                    f"Completed {len(campaign_models) * run_count} jobs at {timestamp()}\n",
                )
                campaign_log.emit(
                    f"CAMPAIGN COMPLETE: {len(campaign_models) * run_count} run(s)"
                )
            else:
                campaign_log.emit("Selected recovery jobs complete; full campaign remains incomplete")
            return 0
        except (OSError, RuntimeError, ValueError) as error:
            campaign_log.emit(f"FATAL: {error}")
            return 1
        finally:
            campaign_log.close()


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, RuntimeError, ValueError) as error:
        print(f"Error: {error}", file=sys.stderr)
        raise SystemExit(1)
