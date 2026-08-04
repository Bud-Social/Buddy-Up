"""Pose-keypoint sequence processing for the form analyzer (Phase B).

Consumes raw keypoint sequences + trainer quality labels and writes a
normalized manifest under ``data/processed/forms``. Normalisation follows the
serving contract (shoulder-width + hip-centre, joints as x/y/score) so train
and serve agree on input layout.

DVC stage (dvc.yaml -> process-forms)::

    dvc repro process-forms   # or: python training/process_form_data.py

Raw input contract (data/raw/keypoints/manifest.json)
-----------------------------------------------------
[
  {"video_id": "...", "exercise": "squat",
   "joints": 17,
   "frames": [[[x,y,score], ...x17] x N],   # N frames per video
   "label": "good" | "slight_misalignment" | "bad"}
]
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


def _normalise_frames(frames, joints: int) -> list:
    """Scale/centre each frame: shoulder width = 1, origin at hip midpoint."""
    import math

    out = []
    for frame in frames:
        coords = [(j[0], j[1]) for j in frame] if len(frame[0]) >= 2 else list(frame)
        try:
            rs = coords[joints - 9]
            ls = coords[joints - 10]
            rhip = coords[joints - 4]
            lhip = coords[joints - 3]
        except IndexError:
            continue
        width = math.dist(rs, ls) or 1.0
        cx = (rhip[0] + lhip[0]) / 2.0
        cy = (rhip[1] + lhip[1]) / 2.0
        norm = [((x - cx) / width, (y - cy) / width, s) for (x, y, *s) in frame]
        out.append(norm)
    return out


def process(root: Path, dry_run: bool = False):
    manifest_file = root / 'manifest.json'
    if not manifest_file.exists():
        raise SystemExit(f'Missing {manifest_file} — see data/README.md keypoints contract')

    records = json.loads(manifest_file.read_text())
    if not records:
        raise SystemExit('Empty keypoint manifest')

    rows = []
    for rec in records:
        joints = rec.get('joints', len(rec['frames'][0]))
        if joints != 17:
            raise SystemExit(f'{rec["video_id"]}: expected 17 joints, got {joints}')
        if not rec.get('frames'):
            raise SystemExit(f'{rec["video_id"]}: no frames')
        norm = _normalise_frames(rec['frames'], joints)
        rows.append({
            'video_id': rec['video_id'],
            'exercise': rec['exercise'],
            'label': rec['label'],
            'num_frames': len(norm),
            'normalised': norm,
        })

    exercises = {r['exercise'] for r in rows}
    if dry_run:
        print(f'Keypoints OK: {len(rows)} videos, exercises={sorted(exercises)}')
        return

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

    with open(PROCESSED / 'normalised.json', 'w') as fh:
        json.dump(rows, fh)

    print(f'Wrote {PROCESSED}')
    print(f'  videos: {len(rows)}, exercises={sorted(exercises)}')


def main():
    parser = argparse.ArgumentParser(description='Process keypoint sequences for form analysis')
    parser.add_argument('--dry-run', action='store_true')
    args = parser.parse_args()
    process(keypoints(), dry_run=args.dry_run)


if __name__ == '__main__':
    main()
