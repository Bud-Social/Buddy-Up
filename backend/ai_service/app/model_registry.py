import logging
import sys
from typing import Any

import torch

from .config import settings

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

    @classmethod
    def register(cls, name: str, model: Any) -> None:
        cls._models[name] = model
        logger.info('Registered model: %s', name)

    @classmethod
    def get(cls, name: str) -> Any | None:
        return cls._models.get(name)

    @classmethod
    def list_models(cls) -> list[str]:
        return list(cls._models.keys())

    @classmethod
    def unload(cls, name: str) -> bool:
        model = cls._models.pop(name, None)
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
    def unload_all(cls) -> None:
        for name in list(cls._models.keys()):
            cls.unload(name)
        logger.info('All models unloaded')
