"""HF model quantization + caching layer (CPU INT8).

`load_preferred_hf(name, factory)` mirrors `ml/serving.load_preferred` for
HuggingFace models: if a cached dynamic-int8 state_dict exists in
AI_MODEL_CACHE_DIR it loads the fresh fp32 skeleton, quantizes in-place, and
restores the cached weights; otherwise it quantizes and persists them.

`quantize_dynamic_torch` is the "highest compression for speed" path on CPU:
Linear weights are quantized to qint8 (~4x memory cut) with acceptable latency
gains. Generation models (Florence-2, SpeechT5) keep this torch path; CLIP and
T5 additionally expose clean ONNX exports.

Transfer-learning notebook convention (see training/train_template.py):
every notebook's final cell calls `load_backbone` → train → `export_onnx`
→ `log_run`, so artifacts and TrainingRun dashboard rows are uniform:

    from app.ml.hf_utils import load_backbone, export_onnx, log_run
    model, tokenizer = load_backbone('google/vit-base-patch16-224', num_labels=2)
    ... train with transformers.Trainer on Kaggle GPU ...
    export_onnx(model, dummy_inputs, 'models/nsfw_classifier-2.0.0.onnx')
    log_run(model_name='nsfw_classifier', version='2.0.0', scenario='full',
            framework='pytorch', metrics={'accuracy': 0.97}, gpu='kaggle-t4x2')
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


def load_backbone(model_id: str, num_labels: int | None = None,
                  trust_remote_code: bool = False):
    """Load an HF backbone for transfer learning + its matching tokenizer.

    Sequence/classification models get a fresh head when ``num_labels`` is
    given; otherwise the pretrained head is kept (feature-extractor mode).
    Returns ``(model, tokenizer)`` on CPU — move to GPU in the notebook.
    """
    from transformers import AutoModel, AutoModelForImageClassification, AutoModelForSequenceClassification, AutoTokenizer

    tokenizer = AutoTokenizer.from_pretrained(model_id, trust_remote_code=trust_remote_code)
    if num_labels is not None:
        try:
            model = AutoModelForSequenceClassification.from_pretrained(
                model_id, num_labels=num_labels, trust_remote_code=trust_remote_code)
        except (ValueError, OSError):
            model = AutoModelForImageClassification.from_pretrained(
                model_id, num_labels=num_labels, trust_remote_code=trust_remote_code,
                ignore_mismatched_sizes=True)
    else:
        model = AutoModel.from_pretrained(model_id, trust_remote_code=trust_remote_code)
    logger.info('Loaded backbone %s (labels=%s)', model_id, num_labels)
    return model, tokenizer


def export_onnx(model, dummy_inputs, path: str, opset: int = 17) -> str:
    """Export a fine-tuned HF model to ONNX (opset 17, dynamic batch).

    Thin wrapper over :func:`ml.export.export_torch_to_onnx` with the
    input/output naming the serving layer expects for HF sequence and
    vision classifiers. ``dummy_inputs`` is the tuple passed to forward
    (e.g. ``(input_ids, attention_mask)`` or ``(pixel_values,)``).
    """
    from .export import export_torch_to_onnx

    return export_torch_to_onnx(model, dummy_inputs, path, opset=opset)


def log_run(model_name: str, version: str = '1.0.0', scenario: str = 'full',
            framework: str = 'pytorch', metrics: dict | None = None,
            artifact_path: str = '', n_classes: int | None = None,
            duration_seconds: float | None = None, gpu: str = '',
            status: str = 'completed', error: str = '',
            admin_url: str = 'http://localhost:8002',
            username: str = '', password: str = '') -> dict:
    """Persist a training run to the Django dashboard (TrainingRun row).

    Called as the final cell of every training notebook so AdminDashboard
    shows every attempt with metrics + artifact. Auth: Django staff session
    or basic auth via username/password; without credentials the payload is
    printed for manual entry and an empty dict is returned.
    """
    import json
    import urllib.request

    payload = {
        'model_name': model_name, 'version': version, 'scenario': scenario,
        'framework': framework, 'metrics': metrics or {},
        'artifact_path': artifact_path, 'n_classes': n_classes,
        'status': status, 'source': 'notebook',
        'duration_seconds': duration_seconds, 'gpu': gpu, 'error': error,
    }
    url = admin_url.rstrip('/') + '/api/v1/admin/dashboard/log-training/'
    req = urllib.request.Request(
        url, data=json.dumps(payload).encode(),
        headers={'Content-Type': 'application/json'}, method='POST')
    if username and password:
        import base64
        creds = base64.b64encode(f'{username}:{password}'.encode()).decode()
        req.add_header('Authorization', f'Basic {creds}')
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            body = json.loads(resp.read().decode())
            logger.info('Logged training run %s %s', model_name, version)
            return body
    except Exception as exc:  # noqa: BLE001 — never fail training on logging
        logger.warning('Could not log training run (%s); payload:\n%s', exc,
                       json.dumps(payload, indent=1)[:2000])
        return {}
