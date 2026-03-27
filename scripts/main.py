#!/usr/bin/env python3
"""Batch-generate Alloy outputs from English descriptions.

Usage:
	python3 scripts/main.py trialRun1/descriptions trialRun1/outputs
"""

import argparse
from concurrent.futures import ThreadPoolExecutor, as_completed
import subprocess
import sys
import tempfile
from pathlib import Path


PROMPT_PREFIX_PATH = "prompts/english-alloy-prefix.txt"
PROMPT_SUFFIX_PATH = "prompts/english-alloy-suffix.txt"
MAX_PARALLEL_REQUESTS = 5


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


def process_description(
	idx: int,
	total: int,
	desc_file: Path,
	outputs_dir: Path,
	prefix_file: Path,
	suffix_file: Path,
	scripts_dir: Path,
	repo_root: Path,
) -> str:
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

		print(f"[{idx}/{total}] Calling model and writing {output_file.name}")
		run_command(
			[
				sys.executable,
				str(scripts_dir / "openAI.py"),
				str(prompt_file),
				str(output_file),
			],
			cwd=repo_root,
		)
	finally:
		prompt_file.unlink(missing_ok=True)

	return name


def main() -> int:
	args = parse_args()

	repo_root = Path(__file__).resolve().parent.parent
	scripts_dir = Path(__file__).resolve().parent

	descriptions_dir = (repo_root / args.descriptions_dir).resolve()
	outputs_dir = (repo_root / args.outputs_dir).resolve()
	prefix_file = (repo_root / PROMPT_PREFIX_PATH).resolve()
	suffix_file = (repo_root / PROMPT_SUFFIX_PATH).resolve()

	if not descriptions_dir.exists() or not descriptions_dir.is_dir():
		print(f"Error: descriptions directory not found: {descriptions_dir}")
		return 1
	if not prefix_file.exists():
		print(f"Error: prefix file not found: {prefix_file}")
		return 1
	if not suffix_file.exists():
		print(f"Error: suffix file not found: {suffix_file}")
		return 1

	outputs_dir.mkdir(parents=True, exist_ok=True)

	description_files = sorted(descriptions_dir.glob("*.md"))
	if not description_files:
		print(f"No .md files found in {descriptions_dir}")
		return 0

	total = len(description_files)
	print(f"Found {total} description files")
	workers = min(MAX_PARALLEL_REQUESTS, total)
	print(f"Running with up to {workers} parallel request(s)")

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
			): desc_file.name
			for idx, desc_file in enumerate(description_files, start=1)
		}

		for future in as_completed(future_to_name):
			file_name = future_to_name[future]
			try:
				finished_name = future.result()
				print(f"Completed: {finished_name}.als")
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
