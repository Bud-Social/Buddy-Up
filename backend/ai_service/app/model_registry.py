import logging
import sys
import threading
import time
from typing import Any

import torch


logger = logging.getLogger(__name__)


def _detect_device() -> torch.device:
    if torch.cuda.is_available():
        device = torch.device('cuda')
        logger.info('Using CUDA device: %s', torch.cuda.get_device_name(0))
    elif (
        sys.platform == 'darwin'
        and hasattr(torch.backends, 'mps')
        and torch.backends.mps.is_available()
    ):
        device = torch.device('mps')
        logger.info('Using Apple MPS (Metal Performance Shaders)')
    else:
        device = torch.device('cpu')
        logger.info('No GPU detected — falling back to CPU')
    return device


DEVICE = _detect_device()


class ModelRegistry:
    _models: dict[str, Any] = {}
    _last_used: dict[str, float] = {}
    _lock = threading.Lock()

    @classmethod
    def register(cls, name: str, model: Any) -> None:
        cls._models[name] = model
        cls._last_used[name] = time.monotonic()
        logger.info('Registered model: %s', name)

    @classmethod
    def get(cls, name: str) -> Any | None:
        model = cls._models.get(name)
        if model is not None:
            cls._last_used[name] = time.monotonic()
        return model

    @classmethod
    def list_models(cls) -> list[str]:
        return list(cls._models.keys())

    @classmethod
    def unload(cls, name: str) -> bool:
        model = cls._models.pop(name, None)
        cls._last_used.pop(name, None)
        if model is not None:
            if hasattr(model, 'to'):
                model.to('cpu')
            del model
            if torch.cuda.is_available():
                torch.cuda.empty_cache()
            logger.info('Unloaded model: %s', name)
            return True
        return False

    @classmethod
    def unload_idle(cls, ttl: float = 900) -> list[str]:
        """Unload models untouched for `ttl` seconds to keep RAM bounded."""
        cutoff = time.monotonic() - ttl
        stale = [
            name
            for name, last in cls._last_used.items()
            if last < cutoff and cls._models.get(name) is not None
        ]
        for name in stale:
            cls.unload(name)
        if stale:
            logger.info('Unloaded %d idle model(s): %s', len(stale), stale)
        return stale

    @classmethod
    def unload_all(cls) -> None:
        for name in list(cls._models.keys()):
            cls.unload(name)
        logger.info('All models unloaded')
