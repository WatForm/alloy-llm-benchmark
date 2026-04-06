#!/usr/bin/env python3
"""Batch-generate Alloy outputs from English descriptions.

Usage:
	python3 scripts/main.py trialRun1/descriptions trialRun1/outputs
"""

import argparse
from concurrent.futures import ThreadPoolExecutor, as_completed
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

from syntax_utils import check_syntax, require_java_for_version


PROMPT_PREFIX_PATH = "prompts/english-alloy-prefix.txt"
PROMPT_SUFFIX_PATH = "prompts/english-alloy-suffix.txt"
MAX_PARALLEL_REQUESTS = 5
MAX_GENERATION_ATTEMPTS = 3


def parse_args() -> argparse.Namespace:
	parser = argparse.ArgumentParser(
		description="Generate Alloy responses for all description files in a folder"
	)
	parser.add_argument(
		"descriptions_dir",
		help="Folder containing .md description files",
	)
	parser.add_argument(
		"outputs_dir",
		help="Folder where model responses will be written",
	)
	return parser.parse_args()


def run_command(cmd: list[str], cwd: Path) -> None:
	result = subprocess.run(cmd, check=False, cwd=str(cwd), capture_output=True, text=True)
	if result.returncode != 0:
		error_parts = [
			f"Command failed with exit code {result.returncode}: {' '.join(cmd)}",
		]
		if result.stdout:
			error_parts.append(f"stdout:\n{result.stdout.strip()}")
		if result.stderr:
			error_parts.append(f"stderr:\n{result.stderr.strip()}")
		raise RuntimeError("\n".join(error_parts))


def build_repair_prompt(base_prompt: str, attempts: list[dict]) -> str:
	lines: list[str] = [base_prompt.rstrip(), "", "# Repair Task", ""]
	lines.append(
		"Your previous Alloy output was syntactically invalid. Produce a corrected Alloy model."
	)
	lines.append("Return only valid Alloy code, with no markdown fences and no extra explanation.")
	lines.append("")
	lines.append("## Previous Attempts And Syntax Errors")

	for item in attempts:
		lines.append("")
		lines.append(f"### Attempt {item['attempt']} Output")
		lines.append("```alloy")
		lines.append(item["text"].rstrip())
		lines.append("```")
		lines.append("")
		lines.append(f"### Attempt {item['attempt']} Syntax Error")
		lines.append(item["syntax_message"].rstrip())

	lines.append("")
	lines.append("Please fix the syntax issues and return a complete Alloy model.")
	return "\n".join(lines) + "\n"


def process_description(
	idx: int,
	total: int,
	desc_file: Path,
	outputs_dir: Path,
	prefix_file: Path,
	suffix_file: Path,
	scripts_dir: Path,
	repo_root: Path,
	diff_jar: Path,
	java17_bin: Path,
) -> tuple[str, int, bool]:
	name = desc_file.stem
	output_file = outputs_dir / f"{name}.als"

	with tempfile.NamedTemporaryFile(mode="w", suffix=".txt", delete=False) as tmp_prompt:
		prompt_file = Path(tmp_prompt.name)

	try:
		print(f"[{idx}/{total}] Building prompt for {desc_file.name}")
		run_command(
			[
				sys.executable,
				str(scripts_dir / "wrapper.py"),
				str(prefix_file),
				str(desc_file),
				str(suffix_file),
				str(prompt_file),
			],
			cwd=repo_root,
		)
		base_prompt = prompt_file.read_text(encoding="utf-8")

		attempts: list[dict] = []
		syntax_ok = False
		final_attempt = 0

		for attempt in range(1, MAX_GENERATION_ATTEMPTS + 1):
			final_attempt = attempt
			attempt_output_file = outputs_dir / f"{name}.attempt{attempt}.als"

			if attempt == 1:
				current_prompt = base_prompt
			else:
				current_prompt = build_repair_prompt(base_prompt, attempts)

			prompt_file.write_text(current_prompt, encoding="utf-8")

			print(
				f"[{idx}/{total}] Calling model for {output_file.name} "
				f"(attempt {attempt}/{MAX_GENERATION_ATTEMPTS})"
			)
			run_command(
				[
					sys.executable,
					str(scripts_dir / "openAI.py"),
					str(prompt_file),
					str(attempt_output_file),
				],
				cwd=repo_root,
			)

			attempt_text = attempt_output_file.read_text(encoding="utf-8", errors="replace")
			score, syntax_msg = check_syntax(attempt_output_file, diff_jar, java17_bin)
			syntax_ok = score == 1
			attempts.append(
				{
					"attempt": attempt,
					"text": attempt_text,
					"syntax_message": syntax_msg,
				}
			)

			if syntax_ok:
				print(f"[{idx}/{total}] {name}: syntax valid on attempt {attempt}")
				break

			if attempt < MAX_GENERATION_ATTEMPTS:
				print(f"[{idx}/{total}] {name}: syntax invalid on attempt {attempt}; retrying with error feedback")

		final_output_file = outputs_dir / f"{name}.attempt{final_attempt}.als"
		shutil.copyfile(final_output_file, output_file)
		print(f"[{idx}/{total}] Final output for {name} -> {output_file.name} (from attempt {final_attempt})")

	finally:
		prompt_file.unlink(missing_ok=True)

	return name, final_attempt, syntax_ok


def main() -> int:
	args = parse_args()

	repo_root = Path(__file__).resolve().parent.parent
	scripts_dir = Path(__file__).resolve().parent

	descriptions_dir = (repo_root / args.descriptions_dir).resolve()
	outputs_dir = (repo_root / args.outputs_dir).resolve()
	prefix_file = (repo_root / PROMPT_PREFIX_PATH).resolve()
	suffix_file = (repo_root / PROMPT_SUFFIX_PATH).resolve()
	diff_jar = (repo_root / "scoring" / "alloy-diff.jar").resolve()

	if not descriptions_dir.exists() or not descriptions_dir.is_dir():
		print(f"Error: descriptions directory not found: {descriptions_dir}")
		return 1
	if not prefix_file.exists():
		print(f"Error: prefix file not found: {prefix_file}")
		return 1
	if not suffix_file.exists():
		print(f"Error: suffix file not found: {suffix_file}")
		return 1
	if not diff_jar.exists():
		print(f"Error: alloy-diff.jar not found: {diff_jar}")
		return 1

	try:
		java17_bin, _ = require_java_for_version(17, "generation syntax checks")
	except RuntimeError as exc:
		print(f"Error: {exc}")
		return 1

	outputs_dir.mkdir(parents=True, exist_ok=True)

	description_files = sorted(descriptions_dir.glob("*.md"))
	if not description_files:
		print(f"No .md files found in {descriptions_dir}")
		return 0

	total = len(description_files)
	print(f"Found {total} description files")
	workers = min(MAX_PARALLEL_REQUESTS, total)
	print(
		f"Running with up to {workers} parallel request(s), "
		f"and up to {MAX_GENERATION_ATTEMPTS} generation attempt(s) per file"
	)

	failures: list[str] = []
	with ThreadPoolExecutor(max_workers=workers) as executor:
		future_to_name = {
			executor.submit(
				process_description,
				idx,
				total,
				desc_file,
				outputs_dir,
				prefix_file,
				suffix_file,
				scripts_dir,
				repo_root,
				diff_jar,
				java17_bin,
			): desc_file.name
			for idx, desc_file in enumerate(description_files, start=1)
		}

		for future in as_completed(future_to_name):
			file_name = future_to_name[future]
			try:
				finished_name, final_attempt, syntax_ok = future.result()
				status = "syntax-valid" if syntax_ok else "syntax-invalid"
				print(f"Completed: {finished_name}.als (final attempt {final_attempt}, {status})")
			except Exception as exc:
				error_msg = f"Failed for {file_name}: {exc}"
				failures.append(error_msg)
				print(error_msg)

	if failures:
		print("\nOne or more files failed:")
		for msg in failures:
			print(f"- {msg}")
		return 1

	print(f"Done. Wrote {total} outputs to {outputs_dir}")
	return 0


if __name__ == "__main__":
	raise SystemExit(main())
