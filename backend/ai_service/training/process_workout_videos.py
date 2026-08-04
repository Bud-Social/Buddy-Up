"""Extract pose-keypoint sequences from the local workout-video datasets.

Scans ``data/Work out vids dataset */`` for ``.mp4`` files, groups them by
exercise class (inferred from the folder layout), runs MediaPipe PoseLandmarker
to emit the 17-joint keypoint contract and normalises each frame
(shoulder-width = 1, origin = hip midpoint) so train and serve agree.

Writes the standard form-training inputs::

    data/processed/forms/manifest.csv
    data/processed/forms/normalised.json
    data/processed/forms/joint_spec.json

Usage::

    python training/process_workout_videos.py                # BUDDY_SCALE aware
    python training/process_workout_videos.py --max-videos-per-class 5 --frames 24

``BUDDY_SCALE`` (smoke/demo/full) controls videos-per-class when the flag is not
given: smoke=1, demo=8, full=all. The pose model ``pose_landmarker_lite.task``
is auto-downloaded once into ``ai_service/tools/`` (network required).
"""
from __future__ import annotations

import argparse
import json
import os
import random
import time
from pathlib import Path

import cv2
import numpy as np

ROOT = Path(__file__).resolve().parent.parent / 'data'
OUT = ROOT / 'processed' / 'forms'
TOOLS = Path(__file__).resolve().parent.parent / 'tools'
POSE_MODEL_URL = ('https://storage.googleapis.com/mediapipe-models/pose_landmarker/'
                  'pose_landmarker_lite/float16/1/pose_landmarker_lite.task')

JOINT_NAMES = [
    'nose', 'neck', 'r_shoulder', 'l_shoulder', 'r_elbow', 'l_elbow',
    'r_wrist', 'l_wrist', 'r_hip', 'l_hip', 'r_knee', 'l_knee',
    'r_ankle', 'l_ankle', 'r_heel', 'l_heel', 'r_foot',
]
N_JOINTS = len(JOINT_NAMES)
MAX_DECODE = 1200  # cap frames decoded per video (~40 s @ 30 fps)

# MediaPipe PoseLandmark indices for the 17-joint contract. 'neck' is the
# shoulder midpoint and is computed after extraction.
MP_IDX = {
    'nose': 0,
    'r_shoulder': 12, 'l_shoulder': 11,
    'r_elbow': 14, 'l_elbow': 13,
    'r_wrist': 16, 'l_wrist': 15,
    'r_hip': 24, 'l_hip': 23,
    'r_knee': 26, 'l_knee': 25,
    'r_ankle': 28, 'l_ankle': 27,
    'r_heel': 30, 'l_heel': 29,
    'r_foot': 32,
}

# Directory names that are packaging/wrappers rather than exercise classes.
_WRAPPER = {
    'raw_data', 'test', 'verified_data', 'synthetic_dataset', 'data-btc',
    'data_btc_10s', 'data_btc', 'final_kaggle_with_additional_video',
    'my_test_video_1', 'similar_dataset',
}


def _scale_videos_per_class() -> int:
    scale = os.environ.get('BUDDY_SCALE', 'demo')
    return {'smoke': 1, 'demo': 8, 'full': 10 ** 9}[scale]


def class_for_video(path: Path) -> str:
    parent = path.parent
    if parent.name.endswith('_img_labels') or parent.name in _WRAPPER:
        return parent.parent.name
    return parent.name


def find_videos() -> list[tuple[Path, str]]:
    """Return sorted [(video_path, class_name)] across all workout datasets."""
    found: dict[str, Path] = {}
    for dataset in sorted(ROOT.glob('Work out vids dataset *')):
        for vid in sorted(dataset.rglob('*.mp4')):
            cls = class_for_video(vid).strip()
            if cls and cls not in _WRAPPER:
                key = f'{cls}\x00{vid}'
                found[key] = vid
    return [(v, k.split('\x00')[0]) for k, v in sorted(found.items())]


def _ensure_pose_model() -> Path:
    import urllib.request

    TOOLS.mkdir(parents=True, exist_ok=True)
    path = TOOLS / 'pose_landmarker_lite.task'
    if not path.exists():
        print(f'[workout_videos] downloading pose model -> {path}')
        urllib.request.urlretrieve(POSE_MODEL_URL, path)
    return path


def _extract_landmarker():
    from mediapipe.tasks import python as mp_python
    from mediapipe.tasks.python import vision

    model = _ensure_pose_model()
    return vision.PoseLandmarker.create_from_options(
        vision.PoseLandmarkerOptions(
            base_options=mp_python.BaseOptions(model_asset_path=str(model)),
            running_mode=vision.RunningMode.VIDEO,
            min_pose_detection_confidence=0.5,
            min_pose_presence_confidence=0.5,
            num_poses=1,
        )
    )


def _to_17(landmarks, visibility: float) -> list:
    """Map a MediaPipe 33-landmark list to the 17-joint contract."""
    idx = {k: (landmarks[i] if landmarks[i].visibility >= visibility else None)
           for k, i in MP_IDX.items()}
    out = []
    for name in JOINT_NAMES:
        if name == 'neck':
            rs, ls = idx.get('r_shoulder'), idx.get('l_shoulder')
            if rs and ls:
                out.append([(rs.x + ls.x) / 2, (rs.y + ls.y) / 2,
                            min(rs.visibility, ls.visibility)])
            else:
                out.append([0.0, 0.0, 0.0])
        else:
            lm = idx.get(name)
            out.append([lm.x, lm.y, lm.visibility] if lm else [0.0, 0.0, 0.0])
    return out


def normalise(frames: list) -> list:
    """Shoulder-width = 1, origin at hip midpoint (matches serving contract)."""
    out = []
    for frame in frames:
        rs, ls = frame[2], frame[3]
        rhip, lhip = frame[8], frame[9]
        width = float(np.hypot(rs[0] - ls[0], rs[1] - ls[1]))
        if width < 1e-4:
            continue
        cx = (rhip[0] + lhip[0]) / 2.0
        cy = (rhip[1] + lhip[1]) / 2.0
        out.append([[(x - cx) / width, (y - cy) / width, s] for (x, y, s) in frame])
    return out


def process_video(landmarker, vid: Path, frames_per_video: int,
                  min_frames: int, ts0: int) -> tuple[list | None, int]:
    """Decode sequentially (robust across codecs), sample frames evenly.

    Returns (normalised keypoint frames | None, last_used_timestamp). The
    timestamp counter is passed in so it stays monotonic across videos — the
    shared PoseLandmarker rejects out-of-order VIDEO-mode timestamps.
    """
    import mediapipe as mp

    cap = cv2.VideoCapture(str(vid))
    rgb_frames = []
    while True:
        ok, frame = cap.read()
        if not ok or len(rgb_frames) >= MAX_DECODE:
            break
        rgb_frames.append(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
    cap.release()
    total = len(rgb_frames)
    if total == 0:
        return None, ts0

    step = max(1, total // frames_per_video)
    picked = rgb_frames[::step][:frames_per_video]
    raw, ts = [], ts0
    for rgb in picked:
        ts += 33
        res = landmarker.detect_for_video(
            mp.Image(image_format=mp.ImageFormat.SRGB, data=rgb), ts)
        if res.pose_landmarks:
            raw.append(_to_17(res.pose_landmarks[0], visibility=0.4))
    if len(raw) < min_frames:
        return None, ts
    norm = normalise(raw)
    if len(norm) < min_frames:
        return None, ts
    return norm, ts


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--max-videos-per-class', type=int, default=None,
                    help='cap videos per exercise class (default: BUDDY_SCALE aware)')
    ap.add_argument('--frames', type=int, default=24, help='frames sampled per video')
    ap.add_argument('--min-frames', type=int, default=5,
                    help='drop videos with fewer pose frames than this')
    args = ap.parse_args()

    cap_per_class = args.max_videos_per_class or _scale_videos_per_class()
    videos = find_videos()
    by_class: dict[str, list[Path]] = {}
    for vid, cls in videos:
        by_class.setdefault(cls, []).append(vid)

    classes = sorted(by_class)
    print(f'[workout_videos] datasets: {len(classes)} classes, '
          f'{len(videos)} videos | cap {cap_per_class}/class | frames {args.frames}')
    rng = random.Random(42)
    chosen = []
    for cls in classes:
        pool = by_class[cls]
        picked = pool if cap_per_class >= len(pool) else rng.sample(pool, cap_per_class)
        for vid in picked:
            chosen.append((cls, vid))

    landmarker = _extract_landmarker()
    rows, skipped, errors, t0, ts = [], 0, 0, time.time(), 0
    for i, (cls, vid) in enumerate(chosen, 1):
        try:
            frames, ts = process_video(landmarker, vid, args.frames,
                                       args.min_frames, ts)
        except Exception as exc:  # noqa: BLE001 — one bad video must not kill the run
            errors += 1
            print(f'  !! {vid.name}: {exc}')
            continue
        if frames is None:
            skipped += 1
            continue
        rows.append({
            'video_id': vid.stem,
            'exercise': cls,
            'label': 'good',
            'num_frames': len(frames),
            'normalised': frames,
        })
        if i % 20 == 0 or i == len(chosen):
            print(f'  [{i}/{len(chosen)}] ok={len(rows)} skip={skipped} '
                  f'err={errors} ({time.time() - t0:.0f}s)')

    if not rows:
        raise SystemExit('No usable keypoint sequences produced — aborting.')

    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / 'joint_spec.json').write_text(json.dumps({
        'joints': N_JOINTS,
        'joint_names': JOINT_NAMES,
        'normalisation': 'shoulder_width=1, origin=hip_midpoint',
        'pose_source': 'mediapipe pose_landmarker_lite',
        'videos_per_class_cap': cap_per_class,
    }, indent=2))

    import csv

    with open(OUT / 'manifest.csv', 'w', newline='') as fh:
        writer = csv.DictWriter(fh, fieldnames=['video_id', 'exercise', 'label', 'num_frames'])
        writer.writeheader()
        for r in rows:
            writer.writerow({k: r[k] for k in ('video_id', 'exercise', 'label', 'num_frames')})

    with open(OUT / 'normalised.json', 'w') as fh:
        json.dump(rows, fh)

    dist = {}
    for r in rows:
        dist[r['exercise']] = dist.get(r['exercise'], 0) + 1
    print(f'[workout_videos] wrote {OUT}')
    print(f'  sequences: {len(rows)} | skipped {skipped} | errors {errors} | '
          f'{time.time() - t0:.0f}s')
    print(f'  per-class: {dict(sorted(dist.items()))}')


if __name__ == '__main__':
    main()
