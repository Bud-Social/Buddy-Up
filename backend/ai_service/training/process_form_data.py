"""Pose-keypoint manifest processing for the form analyzer (Phase B).

CONTRACT NOTE (smallest-correct-fix): training/process_workout_videos.py
normalises frames *during extraction* (shoulder-width = 1, origin = hip
midpoint) and writes data/processed/forms/normalised.json directly — there is
no separate raw manifest.json step, so this script no longer re-normalises
(which would double-scale the coordinates). It now consumes that processed
output via buddy_data.keypoints(), validates the 17-joint contract, and
(re)publishes the manifest views (manifest.csv + joint_spec.json).

LABEL CAVEAT: extraction writes the placeholder label 'good' for every video —
the current data is exercise-class, not form-quality. Real form training needs
trainer labels ('good' / 'slight_misalignment' / 'bad'); this script warns when
only placeholders are present.

DVC stage (dvc.yaml -> process-forms)::

    dvc repro process-forms   # or: python training/process_form_data.py
"""
import argparse
import csv
import json
from pathlib import Path

from buddy_data import keypoints

PROCESSED = Path(__file__).resolve().parent.parent / 'data' / 'processed' / 'forms'

JOINT_NAMES = [
    'nose', 'neck', 'r_shoulder', 'l_shoulder', 'r_elbow', 'l_elbow',
    'r_wrist', 'l_wrist', 'r_hip', 'l_hip', 'r_knee', 'l_knee',
    'r_ankle', 'l_ankle', 'r_heel', 'l_heel', 'r_foot',
]

VALID_LABELS = {'good', 'slight_misalignment', 'bad'}


def process(records, dry_run: bool = False):
    """Validate processed keypoint sequences + (re)write the manifest views."""
    if not records:
        raise SystemExit('Empty keypoint sequence set')

    rows = []
    for rec in records:
        norm = rec.get('normalised') or []
        if not norm:
            print(f"  !! {rec.get('video_id')}: no frames — skipping")
            continue
        if any(len(frame) != 17 for frame in norm):
            raise SystemExit(f'{rec["video_id"]}: expected 17 joints per frame')
        if rec.get('label') not in VALID_LABELS:
            raise SystemExit(f'{rec["video_id"]}: invalid label {rec.get("label")!r}')
        rows.append({
            'video_id': rec['video_id'],
            'exercise': rec['exercise'],
            'label': rec['label'],
            'num_frames': len(norm),
            'normalised': norm,
        })

    exercises = {r['exercise'] for r in rows}
    labels = {r['label'] for r in rows}
    if dry_run:
        print(f'Keypoints OK: {len(rows)} videos, exercises={sorted(exercises)}, '
              f'labels={sorted(labels)}')
        return

    if labels == {'good'}:
        print('WARNING: all labels are the extraction placeholder "good" — '
              'this is exercise-class data, not form-quality. Trainer labels '
              'are required before training a real form scorer.')

    PROCESSED.mkdir(parents=True, exist_ok=True)
    (PROCESSED / 'joint_spec.json').write_text(json.dumps({
        'joints': 17,
        'joint_names': JOINT_NAMES,
        'normalisation': 'shoulder_width=1, origin=hip_midpoint',
    }, indent=2))

    with open(PROCESSED / 'manifest.csv', 'w', newline='') as fh:
        writer = csv.DictWriter(fh, fieldnames=['video_id', 'exercise', 'label', 'num_frames'])
        writer.writeheader()
        for r in rows:
            writer.writerow({k: r[k] for k in ('video_id', 'exercise', 'label', 'num_frames')})

    print(f'Wrote {PROCESSED} manifest views '
          f'({len(rows)} videos, exercises={sorted(exercises)})')


def main():
    parser = argparse.ArgumentParser(description='Process keypoint sequences for form analysis')
    parser.add_argument('--dry-run', action='store_true')
    args = parser.parse_args()
    process(keypoints(), dry_run=args.dry_run)


if __name__ == '__main__':
    main()
