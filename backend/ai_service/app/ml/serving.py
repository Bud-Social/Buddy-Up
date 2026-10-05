"""Model serving layer.

`load_preferred(name)` loads the INT8 ONNX artifact from AI_MODEL_CACHE_DIR if
present, otherwise falls back to the torch factory. This keeps the CPU-only
serving path fast while preserving the old behavior when no artifact is deployed.
"""
import logging
import re
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
        inputs = self.session.get_inputs()
        self.input_name = inputs[0].name
        self.input_names = [i.name for i in inputs]

    def predict(self, input_array: np.ndarray) -> np.ndarray:
        """Run inference on a numpy array shaped as the model expects."""
        return self.session.run(None, {self.input_name: input_array})[0]

    def predict_dict(self, inputs: dict) -> list:
        """Run inference with an explicit {input_name: array} mapping.

        Needed for multi-input models like toxicity 2.0.0
        (input_ids + attention_mask).
        """
        return self.session.run(None, inputs)


def onnx_available() -> bool:
    try:
        import onnxruntime  # noqa: F401
        return True
    except ImportError:
        return False


_SEMVER_RE = re.compile(r'(\d+)(?:\.(\d+))?(?:\.(\d+))?')


def _version_key(version: str) -> tuple[int, int, int]:
    """'1.2.0' / '2.0' / '3' -> comparable tuple (unknown -> (0, 0, 0))."""
    m = _SEMVER_RE.search(version or '')
    if not m:
        return (0, 0, 0)
    return tuple(int(g or 0) for g in m.groups())


def _load_active_versions() -> dict[str, str]:
    """Return {name: version} pushed from Django via /models/sync (best-effort)."""
    import json as _json

    try:
        cache = Path(settings.model_cache_dir or '')
        state = cache / 'active_models.json'
        if state.exists():
            data = _json.loads(state.read_text())
            if isinstance(data, dict):
                return {str(k): str(v) for k, v in data.items()}
    except (ValueError, OSError):
        pass
    return {}


def artifact_path(name: str, version: str | None = None) -> Path | None:
    """Return the ONNX artifact for `name` in the cache dir, if present.

    Resolution order (highest priority first):
      1. versioned files    <name>-<semver>_int8.onnx / <name>-<semver>.onnx
                            (prefer highest version, then _int8 over plain)
      2. versioned dirs     <name>/<version>/model_int8.onnx | model.onnx
      3. unversioned alias  <name>_int8.onnx, then <name>.onnx (legacy)

    When `version` is None the active version from active_models.json is
    honoured first; otherwise the highest version on disk wins. Pass an
    explicit version to pin (e.g. rollback to 1.0.0 while 2.0.0 file exists).
    """
    cache = Path(settings.model_cache_dir or '')
    pinned = version or _load_active_versions().get(name)

    # 1) versioned files, e.g. workout_forecast-1.2.0_int8.onnx
    candidates: list[tuple[tuple[int, int, int], bool, Path, str]] = []
    for p in cache.glob(f'{name}-*.onnx'):
        # Skip external-data sidecars (foo.onnx.data) — glob only matches .onnx.
        stem = p.name[len(name) + 1:-len('.onnx')]
        is_int8 = stem.endswith('_int8')
        ver = stem[:-len('_int8')] if is_int8 else stem
        candidates.append((_version_key(ver), is_int8, p, ver))

    # 2) versioned dirs, e.g. workout_forecast/1.2.0/model_int8.onnx
    model_dir = cache / name
    if model_dir.is_dir():
        for vdir in model_dir.iterdir():
            if not vdir.is_dir():
                continue
            for is_int8, fname in ((True, 'model_int8.onnx'), (False, 'model.onnx')):
                p = vdir / fname
                if p.exists():
                    candidates.append((_version_key(vdir.name), is_int8, p, vdir.name))
                    break

    if candidates:
        if pinned:
            pinned_matches = [c for c in candidates if c[3] == pinned]
            if pinned_matches:
                pinned_matches.sort(key=lambda c: (c[0], c[1]), reverse=True)
                return pinned_matches[0][2]
        candidates.sort(key=lambda c: (c[0], c[1]), reverse=True)
        return candidates[0][2]

    # 3) unversioned aliases (legacy flat layout)
    for suffix in ('_int8.onnx', '.onnx'):
        candidate = cache / f'{name}{suffix}'
        if candidate.exists():
            return candidate
    return None


def load_preferred(name: str, torch_factory, *args, version: str | None = None, **kwargs):
    """Load model by name: prefer ONNX artifact, else torch factory.

    `version` pins an exact artifact version (rollback support); when omitted
    the active version from active_models.json is honoured.
    """
    cached = ModelRegistry.get(name)
    if cached is not None:
        return cached

    path = artifact_path(name, version=version)
    if path is not None:
        try:
            model = OnnxModel(str(path))
            ModelRegistry.register(name, model)
            logger.info('Loaded ONNX artifact for %s (%s)', name, path)
            return model
        except Exception as exc:  # noqa: BLE001
            logger.warning('Failed to load ONNX artifact %s: %s — using torch', path, exc)

    model = torch_factory(*args, **kwargs)
    ModelRegistry.register(name, model)
    return model
