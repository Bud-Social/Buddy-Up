"""HF model quantization + caching layer (CPU INT8).

`load_preferred_hf(name, factory)` mirrors `ml/serving.load_preferred` for
HuggingFace models: if a cached dynamic-int8 state_dict exists in
AI_MODEL_CACHE_DIR it loads the fresh fp32 skeleton, quantizes in-place, and
restores the cached weights; otherwise it quantizes and persists them.

`quantize_dynamic_torch` is the "highest compression for speed" path on CPU:
Linear weights are quantized to qint8 (~4x memory cut) with acceptable latency
gains. Generation models (Florence-2, SpeechT5) keep this torch path; CLIP and
T5 additionally expose clean ONNX exports.
"""
import logging
import threading
from pathlib import Path
from typing import Any, Callable

import torch

from ..config import settings
from ..model_registry import ModelRegistry

logger = logging.getLogger(__name__)

_LOAD_LOCKS: dict[str, threading.Lock] = {}
_LOCK_GUARD = threading.Lock()


def quantize_dynamic_torch(model: torch.nn.Module) -> torch.nn.Module:
    """Quantize Linear layers to qint8 in-place for CPU serving."""
    return torch.ao.quantization.quantize_dynamic(
        model,
        {torch.nn.Linear},
        dtype=torch.qint8,
        inplace=True,
    )


def _cache_path(name: str) -> Path:
    cache = Path(settings.model_cache_dir or '')
    return cache / f'{name}_int8.pt'


def _cached_state_dict(name: str) -> dict[str, Any] | None:
    path = _cache_path(name)
    if not path.exists():
        return None
    try:
        return torch.load(path, map_location='cpu', weights_only=True)
    except Exception as exc:  # noqa: BLE001
        logger.warning('Failed to load cached int8 state for %s: %s', name, exc)
        return None


def load_preferred_hf(name: str, factory: Callable[[], torch.nn.Module], **kwargs) -> torch.nn.Module:
    """Load an HF model: registry → cached int8 → fresh quantize + persist."""
    cached = ModelRegistry.get(name)
    if cached is not None:
        return cached

    with _LOCK_GUARD:
        lock = _LOAD_LOCKS.setdefault(name, threading.Lock())
    with lock:
        cached = ModelRegistry.get(name)
        if cached is not None:
            return cached

        state = _cached_state_dict(name)
        model = factory(**kwargs)
        try:
            quantize_dynamic_torch(model)
        except Exception as exc:  # noqa: BLE001
            logger.warning('Dynamic quantization failed for %s (%s) — serving fp32', name, exc)
            ModelRegistry.register(name, model)
            return model

        if state is not None:
            try:
                model.load_state_dict(state)
                logger.info('Loaded cached int8 weights for %s', name)
            except Exception as exc:  # noqa: BLE001
                logger.warning('Cached int8 weights mismatch for %s (%s) — using freshly quantized', name, exc)
        else:
            try:
                _cache_path(name).parent.mkdir(parents=True, exist_ok=True)
                torch.save(model.state_dict(), _cache_path(name))
                logger.info('Cached int8 weights for %s at %s', name, _cache_path(name))
            except Exception as exc:  # noqa: BLE001
                logger.warning('Failed to persist int8 weights for %s: %s', name, exc)

        ModelRegistry.register(name, model)
        return model
