#!/usr/bin/env python3
"""Detect duplicate Alloy XML instances after stripping run metadata."""

from __future__ import annotations

import argparse
import hashlib
import re
from pathlib import Path
import xml.etree.ElementTree as ET


IGNORED_INSTANCE_ATTRIBUTES = {"command", "filename", "maxseq"}


def natural_path_key(path: Path) -> list[object]:
    return [int(part) if part.isdigit() else part for part in re.split(r"(\d+)", str(path))]


def xml_files_under(root: Path) -> list[Path]:
    if not root.exists():
        return []
    return sorted(root.glob("**/*.xml"), key=natural_path_key)


def scope_number(scope_dir: Path) -> int | None:
    match = re.fullmatch(r"scope_(\d+)", scope_dir.name)
    if not match:
        return None
    return int(match.group(1))


def canonical_element(element: ET.Element) -> str:
    attrs = " ".join(f'{key}="{value}"' for key, value in sorted(element.attrib.items()))
    text = (element.text or "").strip()
    children = "".join(canonical_element(child) for child in element)
    return f"<{element.tag} {attrs}>{text}{children}</{element.tag}>"


def canonical_instance_text(path: Path) -> str:
    root = ET.parse(path).getroot()
    instance = root.find("instance")
    element = instance if instance is not None else root

    if instance is not None:
        for attribute in IGNORED_INSTANCE_ATTRIBUTES:
            instance.attrib.pop(attribute, None)
    else:
        root.attrib.pop("builddate", None)

    return canonical_element(element)


def instance_fingerprint(path: Path) -> str:
    return hashlib.sha256(canonical_instance_text(path).encode("utf-8")).hexdigest()


def load_seen_hashes(prior_root: Path | None, current_scope: int) -> set[str]:
    seen: set[str] = set()
    if prior_root is None or not prior_root.exists():
        return seen

    for scope_dir in sorted(prior_root.glob("scope_*"), key=natural_path_key):
        existing_scope = scope_number(scope_dir)
        if existing_scope is None or existing_scope >= current_scope:
            continue
        for xml_file in xml_files_under(scope_dir):
            seen.add(instance_fingerprint(xml_file))

    return seen


def select_unique_instance_files(
    files: list[Path],
    seen_hashes: set[str],
    limit: int | None = None,
) -> tuple[list[Path], list[str], int]:
    selected: list[Path] = []
    selected_hashes: list[str] = []
    local_seen = set(seen_hashes)
    duplicate_count = 0

    for xml_file in sorted(files, key=natural_path_key):
        fingerprint = instance_fingerprint(xml_file)
        if fingerprint in local_seen:
            duplicate_count += 1
            continue

        local_seen.add(fingerprint)
        selected.append(xml_file)
        selected_hashes.append(fingerprint)

        if limit is not None and len(selected) >= limit:
            break

    return selected, selected_hashes, duplicate_count


def split_unique_instance_files(
    files: list[Path],
    seen_hashes: set[str],
    limit: int | None = None,
) -> tuple[list[Path], list[Path]]:
    kept: list[Path] = []
    removed: list[Path] = []
    local_seen = set(seen_hashes)

    for xml_file in sorted(files, key=natural_path_key):
        fingerprint = instance_fingerprint(xml_file)
        if fingerprint in local_seen or (limit is not None and len(kept) >= limit):
            removed.append(xml_file)
            continue

        local_seen.add(fingerprint)
        kept.append(xml_file)

    return kept, removed


def remove_empty_dirs(root: Path) -> None:
    if not root.exists():
        return
    for directory in sorted((path for path in root.rglob("*") if path.is_dir()), key=natural_path_key, reverse=True):
        try:
            directory.rmdir()
        except OSError:
            pass


def command_select(args: argparse.Namespace) -> int:
    seen_hashes = load_seen_hashes(args.prior_root, args.current_scope)
    files = [Path(file_name) for file_name in args.files]
    selected, _, _ = select_unique_instance_files(files, seen_hashes, args.limit)
    for xml_file in selected:
        print(xml_file)
    return 0


def command_dedup_scope(args: argparse.Namespace) -> int:
    seen_hashes = load_seen_hashes(args.prior_root, args.current_scope)
    files = xml_files_under(args.scope_dir)
    limit = args.limit if args.limit and args.limit > 0 else None
    kept, removed = split_unique_instance_files(files, seen_hashes, limit)

    if args.delete:
        for xml_file in removed:
            xml_file.unlink(missing_ok=True)
        remove_empty_dirs(args.scope_dir)

    print(f"generated={len(files)} kept={len(kept)} removed={len(removed)}")
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    subparsers = parser.add_subparsers(dest="command", required=True)

    select = subparsers.add_parser("select", help="Print unique XML files not seen in lower scopes.")
    select.add_argument("--limit", type=int, required=True)
    select.add_argument("--prior-root", type=Path, required=True)
    select.add_argument("--current-scope", type=int, required=True)
    select.add_argument("files", nargs="*")
    select.set_defaults(func=command_select)

    dedup_scope = subparsers.add_parser("dedup-scope", help="Remove duplicate XML files from one scope.")
    dedup_scope.add_argument("--prior-root", type=Path, required=True)
    dedup_scope.add_argument("--current-scope", type=int, required=True)
    dedup_scope.add_argument("--scope-dir", type=Path, required=True)
    dedup_scope.add_argument("--limit", type=int, default=0)
    dedup_scope.add_argument("--delete", action="store_true")
    dedup_scope.set_defaults(func=command_dedup_scope)

    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())