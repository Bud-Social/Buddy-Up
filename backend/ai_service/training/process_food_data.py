"""Food-101 label patching + processing (Phase A).

Why a patch: the serving ViT emits ImageNet-1k category names, not Food-101
indices, and NUTRITION_DB keys are coarser than the 101 classes. This script
maps every Food-101 class onto a nutrition key (+ macro bucket), writes a
patched label map and a class-balanced train/test manifest under
``data/processed/food``, and validates that no class is missing.

DVC stage (dvc.yaml -> process-food)::

    dvc repro process-food   # or: python training/process_food_data.py

Outputs
-------
data/processed/food/
├── food101_label_map.csv     # class, nutrition_key, bucket
├── train.csv                 # image_path, class, nutrition_key, bucket
└── test.csv
"""
import argparse
import csv
from pathlib import Path

from buddy_data import food101, food101_splits
from food101_labels import FOOD101_LABELS, ALL_FOOD101_CLASSES, macros_for_class

PROCESSED = Path(__file__).resolve().parent.parent / 'data' / 'processed' / 'food'


def _write_map(out: Path) -> None:
    with open(out, 'w', newline='') as fh:
        writer = csv.DictWriter(fh, fieldnames=['class', 'nutrition_key', 'bucket', 'calories', 'protein', 'carbs', 'fat'])
        writer.writeheader()
        for cls in sorted(ALL_FOOD101_CLASSES):
            key, bucket = FOOD101_LABELS[cls]
            m = macros_for_class(cls)
            writer.writerow({
                'class': cls,
                'nutrition_key': key,
                'bucket': bucket,
                'calories': m['calories'],
                'protein': m['protein'],
                'carbs': m['carbs'],
                'fat': m['fat'],
            })


def _write_split(root: Path, out: Path, split_name: str) -> int:
    images = root / 'images'
    with open(out, 'w', newline='') as fh:
        writer = csv.DictWriter(fh, fieldnames=['image_path', 'class', 'nutrition_key', 'bucket'])
        writer.writeheader()
        count = 0
        for rel in food101_splits()[split_name]:
            cls = rel.split('/')[-1]
            key, bucket = FOOD101_LABELS[cls]
            img = images / f'{rel}.jpg'
            if img.exists():
                writer.writerow({
                    'image_path': str(img),
                    'class': cls,
                    'nutrition_key': key,
                    'bucket': bucket,
                })
                count += 1
    return count


def main():
    parser = argparse.ArgumentParser(description='Process + patch Food-101 data')
    parser.add_argument('--dry-run', action='store_true', help='Validate only, do not write')
    args = parser.parse_args()

    root = food101()
    splits = food101_splits()

    missing = ALL_FOOD101_CLASSES - set(FOOD101_LABELS)
    if missing:
        raise SystemExit(f'Missing label patches for: {sorted(missing)}')
    if len(FOOD101_LABELS) != 101:
        raise SystemExit(f'Expected 101 labels, got {len(FOOD101_LABELS)}')

    if args.dry_run:
        print(f'Food-101 OK: {len(splits["train"])} train, {len(splits["test"])} test rows')
        return

    PROCESSED.mkdir(parents=True, exist_ok=True)
    _write_map(PROCESSED / 'food101_label_map.csv')
    n_train = _write_split(root, PROCESSED / 'train.csv', 'train')
    n_test = _write_split(root, PROCESSED / 'test.csv', 'test')
    print(f'Wrote {PROCESSED}')
    print(f'  label_map: {len(ALL_FOOD101_CLASSES)} classes')
    print(f'  train: {n_train} rows')
    print(f'  test:  {n_test} rows')


if __name__ == '__main__':
    main()
