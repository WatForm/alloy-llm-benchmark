#!/usr/bin/env python3
"""Shared Alloy syntax-check helpers used by generation and scoring."""

from __future__ import annotations

import os
import re
import subprocess
from pathlib import Path


TIMEOUT_SECONDS = 300
DEFAULT_SOLVER = "sat4j"


def run_command(
    cmd: list[str],
    cwd: Path | None = None,
    timeout: int = TIMEOUT_SECONDS,
) -> subprocess.CompletedProcess[str]:
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


def check_syntax(
    model_file: Path,
    diff_jar: Path,
    java17_bin: Path,
    solver: str = DEFAULT_SOLVER,
) -> tuple[int, str]:
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
        solver,
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
