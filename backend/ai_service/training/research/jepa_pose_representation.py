"""JEPA pose-representation proof of concept (RESEARCH LANE).

Goal: learn a self-supervised representation over unlabelled workout video
(I-JEPA / VICReg-style) and check whether it beats the supervised baseline for
downstream exercise detection and form scoring.

This is intentionally a skeleton — gate on v1 user video data before investing.

Run: python training/research/jepa_pose_representation.py --data-dir ../data/raw/videos

Background:
- JEPA (Joint-Embedding Predictive Architecture) learns representations by
  predicting missing/contextual patches in embedding space, no labels required.
- I-JEPA: Image-based JEPA (ViT encoder + predictor over masked patches).
- VICReg: variance-invariance-covariance regularization — simpler, stable.
- Pose variant: keypoint coordinates are 2D signals; treat them as a sequence
  and train a small transformer encoder with a contrastive/predictive objective.
"""
import argparse
from pathlib import Path


def parse_args():
    p = argparse.ArgumentParser(description='JEPA pose POC (research)')
    p.add_argument('--data-dir', required=True, help='dir of unlabelled pose/video files')
    p.add_argument('--out-dir', default='../models/research/jepa_pose')
    p.add_argument('--backbone', default='i-jepa', choices=['i-jepa', 'vicreg'])
    p.add_argument('--epochs', type=int, default=50)
    p.add_argument('--batch-size', type=int, default=64)
    return p.parse_args()


def main():
    args = parse_args()
    data_dir = Path(args.data_dir)
    if not data_dir.exists():
        raise SystemExit(f'Data dir not found: {data_dir}. Add unlabelled video first.')

    # 1. Extract pose keypoint sequences (MediaPipe) from raw video -> dataset.
    # 2. Pretrain encoder with the chosen objective (i-jepa masked prediction or
    #    vicreg loss) over keypoint sequences. No labels required.
    # 3. Freeze encoder, train a linear probe for downstream tasks:
    #      - exercise detection (10-class)
    #      - per-joint form error regression (scaled MSE)
    # 4. Compare against the supervised baseline (form_analyzer_engine).
    # 5. Decision gate: adopt as backbone only if probe beats baseline.

    raise NotImplementedError(
        f'{args.backbone} pretraining pipeline. '
        'Design decisions: ViT-S encoder on keypoint embeddings, '
        'temporal masking, EMA teacher (I-JEPA) or VICReg covariance term.'
    )


if __name__ == '__main__':
    main()
