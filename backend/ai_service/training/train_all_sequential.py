#!/usr/bin/env python3
"""Prepare every available synthetic training contract, then train sequentially.

Only moderation has a compatible pretrained, trainable base checkpoint. The
other shipped models are ONNX inference artifacts or require image/video or
consented interaction data; they are recorded as blocked rather than silently
being replaced with unrelated models.
"""
from __future__ import annotations

import argparse
import importlib.util
import os
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parent


def run(command: list[str], dry_run: bool) -> None:
    print("+", " ".join(command), flush=True)
    if not dry_run:
        # The only implemented fine-tune is PyTorch-based. Keep this explicit
        # for child processes so a TensorFlow/Keras 3 installation cannot make
        # Transformers load its optional legacy TF adapter.
        env = os.environ.copy()
        env["USE_TF"] = "0"
        env["USE_FLAX"] = "0"
        subprocess.run(command, check=True, env=env)


def require_finetune_dependencies() -> None:
    """Fail before data preparation when the Trainer runtime is incomplete."""
    missing = [name for name in ("torch", "transformers", "datasets", "accelerate")
               if importlib.util.find_spec(name) is None]
    if missing:
        raise SystemExit(
            "Missing fine-tuning dependencies: " + ", ".join(missing) + ". "
            "Install them with: python -m pip install -r requirements-training.txt"
        )


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-dir", type=Path, default=Path("../../data/synthetic"))
    parser.add_argument("--prepared-dir", type=Path, default=Path("data/prepared"))
    parser.add_argument("--output-dir", type=Path, default=Path("outputs/moderation-toxicity"))
    parser.add_argument("--base-model", default="unitary/toxic-bert")
    parser.add_argument("--epochs", type=float, default=1.0)
    parser.add_argument("--batch-size", type=int, default=16)
    parser.add_argument("--prepare-only", action="store_true")
    parser.add_argument("--skip-prepare", action="store_true",
                        help="Reuse an existing prepared dataset directory.")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()
    prepare = [sys.executable, str(ROOT / "prepare_synthetic_datasets.py"), "--source-dir", str(args.source_dir), "--output-dir", str(args.prepared_dir)]
    if not args.skip_prepare:
        run(prepare, args.dry_run)
    if args.prepare_only:
        return
    if not args.dry_run:
        require_finetune_dependencies()
    fine_tune = [sys.executable, str(ROOT / "finetune_moderation.py"), "--data-dir", str(args.prepared_dir), "--output-dir", str(args.output_dir), "--base-model", args.base_model, "--epochs", str(args.epochs), "--batch-size", str(args.batch_size)]
    run(fine_tune, args.dry_run)
    print("Completed: moderation transfer fine-tune. Blocked model requirements are in the prepared manifest.")


if __name__ == "__main__":
    main()
