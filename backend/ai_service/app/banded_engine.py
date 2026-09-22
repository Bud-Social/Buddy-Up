"""Inference engine for the six banded-ensemble research models.

Each model was trained by its notebook in ``notebooks/banded_*.ipynb`` /
``multimodal_*`` / ``rl_*`` (PyTorch, real BuddyUp Fit + public batches) and
exported to ONNX in the model cache dir. Artifacts resolve through
``ml.serving.artifact_path`` (unversioned ``<name>.onnx`` aliases), so a
``ModelMetadata`` row flip + file drop is all a promotion takes.

Model cards (inputs are exactly what the notebooks exported):
  banded_nlp_best   int64 token ids (1, 32), vocab 2000  -> jokes-vs-meirl logits
  banded_vision_best float32 image (N, 3, 32, 32)/255     -> Neutral-vs-NSFW logits
  multimodal_fuse   float32 fused embedding (N, 320)     -> 10-way logits
  recsys_item_emb   int64 item ids (N,)                  -> 32-dim item vectors
  rl_nlp_policy     int64 token ids (N, 16), vocab 500   -> 4 action logits
  rl_jepa_policy    float32 obs (N, 48)                  -> 2 action logits

Text tokenization is the same dependency-free word-hash used at training
time (see training/batch_data.py) so train/serve skew is zero by construction.
"""

import hashlib
import logging
import re

import numpy as np

from .ml.serving import OnnxModel, artifact_path

logger = logging.getLogger(__name__)

_WORD = re.compile(r"[a-z0-9']+")

NLP_VOCAB, NLP_SEQLEN = 2000, 32
NLP_CLASSES = ['jokes', 'meirl']
VISION_CLASSES = ['Neutral', 'NSFW']
RL_NLP_VOCAB, RL_NLP_SEQLEN, RL_NLP_ACTIONS = 500, 16, 4
RL_JEPA_OBS, RL_JEPA_ACTIONS = 48, 2


class BandedUnavailable(RuntimeError):
    """Raised when the ONNX artifact for a banded model is not deployed."""


def _require(name: str) -> OnnxModel:
    from .model_registry import ModelRegistry

    cached = ModelRegistry.get(name)
    if cached is not None:
        return cached
    path = artifact_path(name)
    if path is None:
        raise BandedUnavailable(
            f"artifact for {name!r} not found in the model cache dir; "
            "train it (notebooks/banded_*.ipynb) and drop the .onnx file, "
            "then register a ModelMetadata row."
        )
    model = OnnxModel(str(path))
    ModelRegistry.register(name, model)
    logger.info('Loaded banded artifact %s (%s)', name, path)
    return model


def _softmax(logits: np.ndarray) -> np.ndarray:
    z = logits - logits.max(axis=-1, keepdims=True)
    e = np.exp(z)
    return e / e.sum(axis=-1, keepdims=True)


def hash_tokenize(texts: list[str], vocab: int, seqlen: int) -> np.ndarray:
    """Word-hash token ids, shape (len(texts), seqlen), int64. Same as training."""
    rows = []
    for t in texts:
        toks = _WORD.findall(str(t).lower())[:seqlen]
        row = [int(hashlib.md5(w.encode()).hexdigest(), 16) % vocab for w in toks]
        row += [0] * (seqlen - len(row))
        rows.append(row)
    return np.asarray(rows, dtype=np.int64)


def classify_text_nlp(text: str) -> dict:
    """Domain-classify a post title with the banded NLP ensemble head."""
    if not text or not text.strip():
        return {'label': NLP_CLASSES[1], 'confidence': 0.0, 'method': 'empty'}
    logits = _require('banded_nlp_best').predict(
        hash_tokenize([text], NLP_VOCAB, NLP_SEQLEN)
    )
    probs = _softmax(np.asarray(logits, dtype=np.float64))[0]
    top = int(probs.argmax())
    return {
        'label': NLP_CLASSES[top],
        'confidence': round(float(probs[top]), 4),
        'probs': {c: round(float(p), 4) for c, p in zip(NLP_CLASSES, probs)},
        'method': 'banded_nlp_best',
    }


def classify_image_vision(image_bytes: bytes) -> dict:
    """Cheap Neutral-vs-NSFW pre-filter (32px banded vision head).

    Complements the NudeNet path in moderation_engine: fast, offline, and
    trained on BuddyUp Fit's own NSFW corpus. Escalate to NudeNet on 'flag'.
    """
    from io import BytesIO

    from PIL import Image

    try:
        img = Image.open(BytesIO(image_bytes)).convert('RGB').resize((32, 32))
    except Exception:  # noqa: BLE001
        return {'label': 'Neutral', 'confidence': 0.0, 'action': 'approve',
                'method': 'error'}
    arr = np.asarray(img, dtype=np.float32).transpose(2, 0, 1)[None] / 255.0
    logits = _require('banded_vision_best').predict(arr)
    probs = _softmax(np.asarray(logits, dtype=np.float64))[0]
    top = int(probs.argmax())
    return {
        'label': VISION_CLASSES[top],
        'confidence': round(float(probs[top]), 4),
        'action': 'flag' if top == 1 and probs[top] >= 0.5 else 'approve',
        'method': 'banded_vision_best',
    }


def score_multimodal(embeddings: list[list[float]]) -> dict:
    """Score precomputed 320-dim fused embeddings with the JEPA head."""
    arr = np.asarray(embeddings, dtype=np.float32)
    if arr.ndim != 2 or arr.shape[1] != 320:
        raise ValueError('embeddings must be an (N, 320) array')
    logits = _require('multimodal_fuse').predict(arr)
    probs = _softmax(np.asarray(logits, dtype=np.float64))
    return {
        'top_class': [int(p.argmax()) for p in probs],
        'confidence': [round(float(p.max()), 4) for p in probs],
        'method': 'multimodal_fuse',
    }


def embed_recsys_items(item_ids: list[int]) -> dict:
    """Item-tower vectors for FAISS indexing (matches matching_embeddings lane)."""
    arr = np.asarray(item_ids, dtype=np.int64)
    vecs = np.asarray(_require('recsys_item_emb').predict(arr), dtype=np.float32)
    return {'vectors': vecs.tolist(), 'dim': vecs.shape[1],
            'method': 'recsys_item_emb'}


def act_rl_nlp(text: str) -> dict:
    """Coaching-cue / reply action from the RL+NLP bandit policy."""
    logits = _require('rl_nlp_policy').predict(
        hash_tokenize([text or ''], RL_NLP_VOCAB, RL_NLP_SEQLEN)
    )
    probs = _softmax(np.asarray(logits, dtype=np.float64))[0]
    return {
        'action': int(probs.argmax()),
        'probs': [round(float(p), 4) for p in probs],
        'method': 'rl_nlp_policy',
    }


def act_rl_jepa(obs: list[float]) -> dict:
    """Latent-policy action from a 48-dim world-model observation."""
    arr = np.asarray([obs], dtype=np.float32)
    if arr.shape != (1, RL_JEPA_OBS):
        raise ValueError(f'obs must have length {RL_JEPA_OBS}')
    logits = _require('rl_jepa_policy').predict(arr)
    probs = _softmax(np.asarray(logits, dtype=np.float64))[0]
    return {
        'action': int(probs.argmax()),
        'probs': [round(float(p), 4) for p in probs],
        'method': 'rl_jepa_policy',
    }
