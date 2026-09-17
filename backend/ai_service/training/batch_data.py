"""Shared real-data batch loader for the banded-ensemble notebooks.

A *batch* is a small, disk-budgeted slice of real data materialised by
``training/data_agent.py`` under ``data/batches/<task>/batch_<id>/``::

    manifest.json   {task, batch_id, source, created, n, ...task meta...}
    tensors.pt      plain torch tensors (loadable with weights_only=True)

Notebooks read the batch pointed to by the ``BUDDY_BATCH`` env var and fall
back to deterministic synthetic data when it is unset, so every notebook runs
anywhere (CI, Kaggle, laptop) with or without real data::

    from batch_data import has_batch, batch_meta, load_tensors

    if has_batch():
        m = batch_meta()          # dims, classes, source lineage
        blob = load_tensors('X', 'y', 'val_X', 'val_y')
    else:
        ... synthetic fallback ...

The hash tokenizers below are deliberately dependency-free (no HF tokenizer
download): ``hash_tokenize`` maps words to ``[0, vocab)`` by md5, and
``hash_embed`` maps each word to a fixed random direction. Same text always
gives the same ids, on any machine.
"""

from __future__ import annotations

import hashlib
import json
import os
import re
from pathlib import Path

_WORD = re.compile(r"[a-z0-9']+")


def batch_dir() -> Path | None:
    """Directory pointed to by BUDDY_BATCH, or None when unset/invalid."""
    raw = os.environ.get("BUDDY_BATCH", "").strip()
    if not raw:
        return None
    cand = Path(raw).expanduser()
    if (cand / "manifest.json").is_file() and (cand / "tensors.pt").is_file():
        return cand
    return None


def has_batch() -> bool:
    return batch_dir() is not None


def batch_meta() -> dict:
    d = batch_dir()
    if d is None:
        raise FileNotFoundError(
            "BUDDY_BATCH is not set to a valid batch dir "
            "(expected <dir>/manifest.json + tensors.pt). "
            "Fetch one with: python training/data_agent.py fetch --task <name>"
        )
    return json.loads((d / "manifest.json").read_text())


def load_tensors(*names: str) -> dict:
    """Load named tensors from the active batch (CPU, weights_only=True)."""
    import torch

    d = batch_dir()
    if d is None:
        raise FileNotFoundError("no active BUDDY_BATCH")
    blob = torch.load(d / "tensors.pt", map_location="cpu", weights_only=True)
    missing = [n for n in names if n not in blob]
    if missing:
        raise KeyError(f"batch {d} has no tensors {missing}; has {sorted(blob)}")
    return {n: blob[n] for n in names}


def hash_tokenize(texts, vocab: int = 2000, seqlen: int = 32):
    """Word-hash token ids, shape (len(texts), seqlen), LongTensor."""
    import torch

    rows = []
    for t in texts:
        toks = _WORD.findall(str(t).lower())[:seqlen]
        row = [int(hashlib.md5(w.encode()).hexdigest(), 16) % vocab for w in toks]
        row += [0] * (seqlen - len(row))
        rows.append(row)
    return torch.tensor(rows, dtype=torch.long)


def hash_embed(texts, dim: int = 16, vocab: int = 2000, seed: int = 7, max_words: int = 24):
    """Mean of fixed random word-directions, shape (len(texts), dim)."""
    import torch

    g = torch.Generator().manual_seed(seed)
    proj = torch.randn(vocab, dim, generator=g)
    out = []
    for t in texts:
        toks = _WORD.findall(str(t).lower())[:max_words] or ["_empty_"]
        idx = [int(hashlib.md5(w.encode()).hexdigest(), 16) % vocab for w in toks]
        out.append(proj[idx].mean(0))
    return torch.stack(out)
