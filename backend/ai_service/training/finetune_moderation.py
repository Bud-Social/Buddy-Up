#!/usr/bin/env python3
"""Fine-tune a pretrained text encoder for Buddy-Up binary moderation.

The output uses the service-compatible two-class target (clean / violation).
It starts from a pretrained encoder rather than the deployed ONNX file: ONNX
artifacts are inference-only and cannot be fine-tuned safely.
"""
from __future__ import annotations

import argparse
import inspect
import json
import os
from pathlib import Path

# This trainer intentionally uses PyTorch.  The repository also has
# TensorFlow/Keras 3 installed for its vision notebooks; without these flags
# Transformers may import its legacy TF integration and fail before the torch
# classes below are loaded (Keras 3 requires the separate tf-keras package).
# Set them before *any* transformers import. This script has no TensorFlow
# execution path, so forcing PyTorch avoids inheriting a conflicting USE_TF=1.
os.environ["USE_TF"] = "0"
os.environ["USE_FLAX"] = "0"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--data-dir", type=Path, default=Path("data/prepared"))
    parser.add_argument("--output-dir", type=Path, default=Path("outputs/moderation-toxicity"))
    parser.add_argument("--base-model", default="unitary/toxic-bert", help="HF model ID or local pretrained checkpoint")
    parser.add_argument("--epochs", type=float, default=1.0)
    parser.add_argument("--batch-size", type=int, default=16)
    parser.add_argument("--max-length", type=int, default=128)
    parser.add_argument("--max-train-samples", type=int, default=0, help="0 uses all rows")
    parser.add_argument("--seed", type=int, default=42)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    try:
        from datasets import load_dataset
        from transformers import (AutoConfig, AutoModelForSequenceClassification, AutoTokenizer,
                                  DataCollatorWithPadding, Trainer, TrainingArguments)
    except ImportError as exc:
        raise SystemExit("Install training dependencies first: pip install -r requirements-training.txt") from exc
    data_files = {split: str(args.data_dir / f"moderation_{split}.csv") for split in ("train", "validation", "test")}
    missing = [path for path in data_files.values() if not Path(path).is_file()]
    if missing:
        raise SystemExit(f"Prepared data missing: {missing}. Run prepare_synthetic_datasets.py first.")
    dataset = load_dataset("csv", data_files=data_files)
    if args.max_train_samples:
        dataset["train"] = dataset["train"].select(range(min(args.max_train_samples, len(dataset["train"]))))
    tokenizer = AutoTokenizer.from_pretrained(args.base_model)
    # Toxic-BERT's source checkpoint is multi-label (six independent scores).
    # Buddy-Up has one mutually-exclusive binary target, so retaining the
    # source ``problem_type`` would incorrectly select BCE for [batch, 2]
    # logits and [batch] class IDs. Build an explicit single-label config.
    config = AutoConfig.from_pretrained(
        args.base_model, num_labels=2, id2label={0: "clean", 1: "violation"},
        label2id={"clean": 0, "violation": 1},
        problem_type="single_label_classification",
    )
    model = AutoModelForSequenceClassification.from_pretrained(
        args.base_model, config=config, ignore_mismatched_sizes=True,
    )

    def tokenize(batch):
        tokenized = tokenizer(batch["text"], truncation=True, max_length=args.max_length)
        tokenized["labels"] = [int(value) for value in batch["is_violation"]]
        return tokenized

    tokenized = dataset.map(tokenize, batched=True, remove_columns=dataset["train"].column_names)
    training_args = TrainingArguments(
        output_dir=str(args.output_dir), num_train_epochs=args.epochs,
        per_device_train_batch_size=args.batch_size, per_device_eval_batch_size=args.batch_size,
        eval_strategy="epoch", save_strategy="epoch", load_best_model_at_end=True,
        metric_for_best_model="eval_loss", logging_steps=100, seed=args.seed,
        report_to=[], fp16=False, dataloader_pin_memory=False,
    )
    # Transformers 4 calls this argument ``tokenizer``; Transformers 5 renamed
    # it to ``processing_class``. Support both so the pinned project stack and
    # newer environments produce the same checkpoint.
    trainer_kwargs = {
        "model": model,
        "args": training_args,
        "train_dataset": tokenized["train"],
        "eval_dataset": tokenized["validation"],
        "data_collator": DataCollatorWithPadding(tokenizer=tokenizer),
    }
    processor_parameter = "processing_class" if "processing_class" in inspect.signature(Trainer.__init__).parameters else "tokenizer"
    trainer_kwargs[processor_parameter] = tokenizer
    trainer = Trainer(**trainer_kwargs)
    trainer.train()
    metrics = trainer.evaluate(tokenized["test"], metric_key_prefix="test")
    args.output_dir.mkdir(parents=True, exist_ok=True)
    trainer.save_model(str(args.output_dir / "checkpoint"))
    tokenizer.save_pretrained(str(args.output_dir / "checkpoint"))
    (args.output_dir / "metrics.json").write_text(json.dumps(metrics, indent=2) + "\n")
    print(json.dumps({"base_model": args.base_model, "checkpoint": str(args.output_dir / "checkpoint"), "metrics": metrics}, indent=2))


if __name__ == "__main__":
    main()
