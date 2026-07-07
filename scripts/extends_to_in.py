#!/usr/bin/env python3
"""Rewrite Alloy ``extends`` subsignatures into semantically equivalent ``in`` subsets.

Motivation
----------
The Ringert / alloy-diff (``ModuleDiff``) comparison crashes with

    java.lang.RuntimeException: Cannot merge PrimSig and SubsetSig with same name: this/<Sig>

whenever one module declares a signature with ``extends`` (a ``PrimSig``) and the
other declares the same-named signature with ``in`` (a ``SubsetSig``). Normalising
both modules so that every ``extends`` becomes an equivalent ``in`` makes the two
modules mergeable again, so Ringert can produce a meaningful result.

Transformation
--------------
For every declaration of the form::

    sig A1, A2 extends A { ... }

we emit::

    sig A1, A2 in A { ... }

and, to preserve the semantics that ``extends`` guarantees, we append facts:

* Disjointness of siblings -- ``extends`` subsignatures of the same parent are
  mutually disjoint::

      fact { no A1 & A2 }

* Exhaustiveness of an abstract parent -- an ``abstract`` signature has no atoms
  outside its extending subsignatures, i.e. the parent equals the union of its
  direct ``extends`` children (this constraint is lost once the children become
  ``in`` subsets, because ``abstract`` has no effect on a signature with no
  extending subsignatures)::

      fact { A = A1 + A2 }

In addition, any multiplicity qualifier (``one`` / ``lone`` / ``some``) on a
signature that becomes an ``in`` subset is lifted into an explicit fact. SemDiff
ignores multiplicity keywords on subset signatures (it only honours them on
primary/``extends`` signatures), so ``one sig Root in Directory`` would otherwise
lose its "exactly one" constraint::

      sig Root in Directory {}
      fact { one Root }

(The ``abstract`` qualifier is also dropped from a converted signature, because
``abstract`` is illegal on a subset signature; its meaning is preserved by the
exhaustiveness fact above.)

Comments are stripped from the emitted output; the transformed file is intended
for tool consumption (SemDiff), not for humans.

Usage
-----
    python extends_to_in.py <input.als> [output.als]

If ``output.als`` is omitted the result is written to stdout.
"""

from __future__ import annotations

import re
import sys
from collections import OrderedDict


# Alloy identifiers: a letter/underscore followed by word chars or apostrophes.
# (Module-qualified names such as ``util/ordering`` are not used as sig/parent
# names in these benchmarks, so a simple identifier pattern is sufficient.)
_IDENT = r"[A-Za-z_][A-Za-z0-9_']*"
_QUAL = r"(?:abstract|one|lone|some|private|var)"

# Multiplicity qualifiers that SemDiff ignores on subset signatures and that we
# therefore lift into explicit facts.
_MULT_QUALS = ("one", "lone", "some")

# A signature declaration header, up to (and including) an optional
# ``extends`` / ``in`` clause. The body ``{ ... }`` (if any) is left untouched.
_SIG_DECL_RE = re.compile(
    r"(?P<quals>(?:" + _QUAL + r"\s+)*)"
    r"\bsig\b\s+"
    r"(?P<names>" + _IDENT + r"(?:\s*,\s*" + _IDENT + r")*)"
    r"(?:\s+(?P<rel>extends|in)\s+"
    r"(?P<parent>" + _IDENT + r"(?:\s*\+\s*" + _IDENT + r")*))?"
)

_EXTENDS_KEYWORD_RE = re.compile(r"\bextends\b")


def strip_comments(text: str) -> str:
    """Remove Alloy block (``/* */``) and line (``//`` and ``--``) comments."""
    # Block comments first.
    text = re.sub(r"/\*.*?\*/", " ", text, flags=re.DOTALL)
    # Line comments: cut at the first ``//`` or ``--`` on each line.
    out_lines = []
    for line in text.split("\n"):
        cut = len(line)
        idx_slash = line.find("//")
        if idx_slash != -1:
            cut = min(cut, idx_slash)
        idx_dash = line.find("--")
        if idx_dash != -1:
            cut = min(cut, idx_dash)
        out_lines.append(line[:cut])
    return "\n".join(out_lines)


def _split_names(names: str) -> list[str]:
    return [n.strip() for n in names.split(",") if n.strip()]


def transform(text: str) -> str:
    """Return ``text`` with all ``extends`` subsignatures rewritten as ``in`` subsets."""
    clean = strip_comments(text)

    abstract_sigs: set[str] = set()
    # parent -> ordered list of direct children declared via ``extends``.
    extends_children: "OrderedDict[str, list[str]]" = OrderedDict()
    # Facts lifting subset-signature multiplicities (one/lone/some) that SemDiff
    # ignores on subset signatures.
    multiplicity_facts: list[str] = []

    def rewrite_decl(match: "re.Match[str]") -> str:
        quals = (match.group("quals") or "").split()
        names = _split_names(match.group("names"))
        rel = match.group("rel")
        parent = match.group("parent")

        if "abstract" in quals:
            abstract_sigs.update(names)

        # Top-level signatures (no extends/in clause) are left untouched.
        if rel is None:
            return match.group(0)

        if rel == "extends" and parent is not None:
            parent_name = parent.strip()
            bucket = extends_children.setdefault(parent_name, [])
            for name in names:
                if name not in bucket:
                    bucket.append(name)

        kept_quals: list[str] = []
        for qual in quals:
            if qual in _MULT_QUALS:
                # SemDiff ignores multiplicity on subset sigs; lift to a fact.
                for name in names:
                    multiplicity_facts.append(f"fact {{ {qual} {name} }}")
            elif qual == "abstract":
                # Illegal on a subset signature; meaning preserved by the
                # exhaustiveness fact emitted for abstract parents.
                continue
            else:
                kept_quals.append(qual)

        prefix = "".join(qual + " " for qual in kept_quals)
        return f"{prefix}sig {', '.join(names)} in {parent.strip()}"

    rewritten = _SIG_DECL_RE.sub(rewrite_decl, clean)
    # Safety net: convert any stragglers the declaration regex may have missed so
    # that no ``extends`` keyword survives to trigger the merge crash.
    rewritten = _EXTENDS_KEYWORD_RE.sub("in", rewritten)

    facts: list[str] = []

    # Disjointness of siblings that shared a parent via ``extends``.
    for parent, children in extends_children.items():
        if len(children) < 2:
            continue
        conjuncts = []
        for i in range(len(children)):
            for j in range(i + 1, len(children)):
                conjuncts.append(f"no {children[i]} & {children[j]}")
        facts.append(
            "fact { // extends->in: disjoint children of "
            + parent
            + "\n  "
            + "\n  ".join(conjuncts)
            + "\n}"
        )

    # Exhaustiveness for abstract parents: parent = union of its extends children.
    for parent, children in extends_children.items():
        if parent in abstract_sigs and children:
            facts.append(
                "fact { // extends->in: abstract "
                + parent
                + " partitioned by its children\n  "
                + parent
                + " = "
                + " + ".join(children)
                + "\n}"
            )

    result = rewritten.rstrip() + "\n"
    appended = multiplicity_facts + facts
    if appended:
        result += "\n" + "\n".join(appended) + "\n"
    return result


def main(argv: list[str]) -> int:
    if len(argv) < 2 or len(argv) > 3:
        sys.stderr.write("Usage: python extends_to_in.py <input.als> [output.als]\n")
        return 2

    input_path = argv[1]
    try:
        with open(input_path, "r", encoding="utf-8") as handle:
            source = handle.read()
    except OSError as exc:
        sys.stderr.write(f"Failed to read {input_path}: {exc}\n")
        return 1

    transformed = transform(source)

    if len(argv) == 3:
        try:
            with open(argv[2], "w", encoding="utf-8") as handle:
                handle.write(transformed)
        except OSError as exc:
            sys.stderr.write(f"Failed to write {argv[2]}: {exc}\n")
            return 1
    else:
        sys.stdout.write(transformed)
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
