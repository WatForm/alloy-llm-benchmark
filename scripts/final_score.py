#!/usr/bin/env python3
"""Compute a weighted final score from a benchmark scores.txt report."""

from __future__ import annotations

import argparse
from dataclasses import dataclass, field
from pathlib import Path
import re


SYNTAX_WEIGHT = 10.0
SEMANTIC_WEIGHT = 90.0
RINGERT_WEIGHT = 0.20
COMPOSAT_WEIGHT = 0.50
GENERAL_WEIGHT = 0.30

MODEL_RE = re.compile(r"^Model: (.+)$")
SYNTAX_RE = re.compile(r"^  Syntax attempts score: (\d+)/(\d+)")
SCOPE_RE = re.compile(r"^\s+scope_(\d+): (\d+)/(\d+)")


@dataclass
class ScopeScore:
    score: int = 0
    maximum: int = 0

    def add(self, score: int, maximum: int) -> None:
        self.score += score
        self.maximum += maximum


@dataclass
class ModelScore:
    name: str
    syntax_score: int | None = None
    syntax_maximum: int | None = None
    components: dict[str, dict[int, ScopeScore]] = field(
        default_factory=lambda: {"ringert": {}, "composat": {}, "general": {}}
    )


def component_from_line(line: str) -> str | None:
    if "Ringert (SemDiff implication):" in line:
        return "ringert"
    if "CompoSAT instances" in line:
        return "composat"
    if "General instances" in line:
        return "general"
    return None


def parse_scores(path: Path) -> list[ModelScore]:
    models: list[ModelScore] = []
    current_model: ModelScore | None = None
    current_component: str | None = None

    for line in path.read_text(encoding="utf-8").splitlines():
        model_match = MODEL_RE.match(line)
        if model_match:
            current_model = ModelScore(model_match.group(1))
            models.append(current_model)
            current_component = None
            continue

        if current_model is None:
            continue

        syntax_match = SYNTAX_RE.match(line)
        if syntax_match:
            current_model.syntax_score = int(syntax_match.group(1))
            current_model.syntax_maximum = int(syntax_match.group(2))
            current_component = None
            continue

        component = component_from_line(line)
        if component is not None:
            current_component = component
            continue

        scope_match = SCOPE_RE.match(line)
        if scope_match and current_component is not None:
            scope = int(scope_match.group(1))
            score = int(scope_match.group(2))
            maximum = int(scope_match.group(3))
            scope_score = current_model.components[current_component].setdefault(scope, ScopeScore())
            scope_score.add(score, maximum)

    return models


def syntax_fraction(model: ModelScore) -> float:
    if model.syntax_score is None or model.syntax_maximum is None:
        raise ValueError(f"missing syntax score for model {model.name}")
    if model.syntax_maximum == 0:
        return 1.0
    return model.syntax_score / model.syntax_maximum


def component_fraction(model: ModelScore, component: str) -> float:
    scope_fractions = [
        scope_score.score / scope_score.maximum
        for scope_score in model.components[component].values()
        if scope_score.maximum > 0
    ]
    if not scope_fractions:
        return 1.0
    return sum(scope_fractions) / len(scope_fractions)


def model_final_score(model: ModelScore) -> float:
    semantic_fraction = (
        RINGERT_WEIGHT * component_fraction(model, "ringert")
        + COMPOSAT_WEIGHT * component_fraction(model, "composat")
        + GENERAL_WEIGHT * component_fraction(model, "general")
    )
    return SYNTAX_WEIGHT * syntax_fraction(model) + SEMANTIC_WEIGHT * semantic_fraction


def final_score(models: list[ModelScore]) -> float:
    if not models:
        raise ValueError("score report contains no models")
    return sum(model_final_score(model) for model in models) / len(models)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("scores", type=Path, help="Path to scores.txt produced by scripts/score.py")
    parser.add_argument(
        "output",
        type=Path,
        nargs="?",
        help="Output file. Defaults to final_score.txt next to the input scores file.",
    )
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()

    output = args.output if args.output is not None else args.scores.with_name("final_score.txt")
    models = parse_scores(args.scores)
    score = final_score(models)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(f"{score:.1f}\n", encoding="utf-8")
    print(f"{score:.1f}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())