#!/usr/bin/env python3
"""Turn repository synthetic CSVs into training-ready, split CSV contracts.

This is deliberately dependency-free and streams input files, so it can run on
the 500k-row moderation data on a laptop. Outputs are placed under the chosen
``--output-dir`` and never modify the source datasets.
"""
from __future__ import annotations

import argparse
import csv
import json
from collections import Counter
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[3]
DEFAULT_SOURCE = REPO_ROOT / "data" / "synthetic"


def split_csv(source: Path, output_dir: Path, name: str, fields: list[str], split_field: str = "dataset_split") -> dict:
    """Write train/validation/test CSVs with only the listed fields."""
    writers, handles, counts = {}, [], Counter()
    try:
        for split in ("train", "validation", "test"):
            handle = (output_dir / f"{name}_{split}.csv").open("w", newline="", encoding="utf-8")
            handles.append(handle)
            writer = csv.DictWriter(handle, fieldnames=fields, lineterminator="\n")
            writer.writeheader()
            writers[split] = writer
        with source.open(newline="", encoding="utf-8") as handle:
            for row in csv.DictReader(handle):
                split = row.get(split_field, "")
                if split not in writers:
                    continue
                writers[split].writerow({field: row.get(field, "") for field in fields})
                counts[split] += 1
    finally:
        for handle in handles:
            handle.close()
    return dict(counts)


def create_tabular_training_sets(source: Path, output_dir: Path) -> dict:
    """Create directly trainable tabular contracts for existing non-vision tasks."""
    specs = {
        "nutrition_calories": ("meals_and_benefits.csv", ["protein_g", "carbohydrates_g", "fat_g", "meal_type", "dietary_style", "calories_kcal"]),
        "feed_engagement": ("post_activity_data.csv", ["post_type", "activity_type", "dwell_seconds", "source"]),
        "workout_catalog": ("workouts_and_benefits.csv", ["category", "body_area", "duration_minutes", "sets", "repetitions", "estimated_calories", "difficulty"]),
    }
    summary = {}
    for name, (filename, fields) in specs.items():
        input_file = source / filename
        target = output_dir / f"{name}.csv"
        rows = 0
        with input_file.open(newline="", encoding="utf-8") as read_handle, target.open("w", newline="", encoding="utf-8") as write_handle:
            writer = csv.DictWriter(write_handle, fieldnames=fields, lineterminator="\n")
            writer.writeheader()
            for row in csv.DictReader(read_handle):
                writer.writerow({field: row[field] for field in fields})
                rows += 1
        summary[name] = {"rows": rows, "path": str(target)}
    return summary


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-dir", type=Path, default=DEFAULT_SOURCE)
    parser.add_argument("--output-dir", type=Path, default=Path("data/prepared"))
    args = parser.parse_args()
    source, output = args.source_dir.resolve(), args.output_dir.resolve()
    required = ["moderation_training_data.csv", "meals_and_benefits.csv", "post_activity_data.csv", "workouts_and_benefits.csv"]
    missing = [name for name in required if not (source / name).is_file()]
    if missing:
        parser.error(f"missing source files in {source}: {', '.join(missing)}")
    output.mkdir(parents=True, exist_ok=True)
    moderation = split_csv(source / "moderation_training_data.csv", output, "moderation", ["text", "is_violation", "policy_label", "severity", "enforcement_action"])
    summary = {
        "source_dir": str(source),
        "moderation": {"rows_by_split": moderation, "label": "is_violation", "text_column": "text"},
        "tabular": create_tabular_training_sets(source, output),
        "not_prepared": {
            "nsfw_classifier": "requires labelled image files; synthetic CSV text cannot train a vision model",
            "form_analyzer": "requires labelled pose sequences or workout videos",
            "matching_embeddings": "requires real consented user-item interaction labels",
        },
    }
    (output / "manifest.json").write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
