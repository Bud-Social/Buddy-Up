"""Model serving layer.

`load_preferred(name)` loads the INT8 ONNX artifact from AI_MODEL_CACHE_DIR if
present, otherwise falls back to the torch factory. This keeps the CPU-only
serving path fast while preserving the old behavior when no artifact is deployed.
"""
import logging
from pathlib import Path

import numpy as np

from ..config import settings
from ..model_registry import ModelRegistry

logger = logging.getLogger(__name__)


class OnnxModel:
    """Minimal ONNX Runtime session wrapper (CPU provider)."""

    def __init__(self, path: str):
        import onnxruntime as ort

        self.path = path
        self.session = ort.InferenceSession(
            path,
            providers=['CPUExecutionProvider'],
        )
        self.input_name = self.session.get_inputs()[0].name

    def predict(self, input_array: np.ndarray) -> np.ndarray:
        """Run inference on a numpy array shaped as the model expects."""
        return self.session.run(None, {self.input_name: input_array})[0]


def onnx_available() -> bool:
    try:
        import onnxruntime  # noqa: F401
        return True
    except ImportError:
        return False


def artifact_path(name: str) -> Path | None:
    """Return the ONNX artifact for `name` in the cache dir, if present."""
    cache = Path(settings.model_cache_dir or '')
    for suffix in ('_int8.onnx', '.onnx'):
        candidate = cache / f'{name}{suffix}'
        if candidate.exists():
            return candidate
    return None


def load_preferred(name: str, torch_factory, *args, **kwargs):
    """Load model by name: prefer ONNX artifact, else torch factory."""
    cached = ModelRegistry.get(name)
    if cached is not None:
        return cached

    path = artifact_path(name)
    if path is not None:
        try:
            model = OnnxModel(str(path))
            ModelRegistry.register(name, model)
            logger.info('Loaded ONNX artifact for %s (%s)', name, path)
            return model
        except Exception as exc:
            logger.warning('Failed to load ONNX artifact %s: %s — using torch', path, exc)

    model = torch_factory(*args, **kwargs)
    ModelRegistry.register(name, model)
    return model
