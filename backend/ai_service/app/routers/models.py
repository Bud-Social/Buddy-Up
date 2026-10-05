"""Model registry status + control endpoints (Sprint C2).

Exposes what the AI service has loaded and lets Django `ModelMetadata` canary/
rollback flow force a reload after flipping `is_active`. Django pushes its DB
truth here via `/sync`; inactive models are unloaded so the next request loads
the promoted artifact.
"""
import json
import re
from pathlib import Path

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from ..config import settings
from ..model_registry import ModelRegistry
from ..ml.serving import artifact_path

_VERSIONED_RE = re.compile(r'^(?P<name>.+)-(?P<ver>\d+(?:\.\d+){0,2})(?P<int8>_int8)?\.onnx$')


def _canonical_name(path: Path) -> str:
    """Map an artifact file to its registry key.

    versioned  toxicity_classifier-2.0.0_int8.onnx -> toxicity_classifier
    legacy    toxicity_classifier_int8.onnx         -> toxicity_classifier
    """
    m = _VERSIONED_RE.match(path.name)
    if m:
        return m.group('name')
    name = path.name
    if name.endswith('_int8.onnx'):
        return name[:-len('_int8.onnx')]
    if name.endswith('.onnx'):
        return name[:-len('.onnx')]
    return name

router = APIRouter()

STATE_FILE = 'active_models.json'


def _state_path() -> Path:
    cache = Path(settings.model_cache_dir or '.')
    return cache / STATE_FILE


def _load_active_versions() -> dict[str, str]:
    """Return {name: version} for models Django has marked active."""
    path = _state_path()
    if not path.exists():
        return {}
    try:
        return json.loads(path.read_text())
    except (ValueError, OSError):
        return {}


def _save_active_versions(mapping: dict[str, str]) -> None:
    path = _state_path()
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(mapping, indent=2))


class ModelStatus(BaseModel):
    name: str
    loaded: bool
    artifact: str | None = None


class ModelsResponse(BaseModel):
    models: list[ModelStatus]
    cache_dir: str


class ReloadRequest(BaseModel):
    name: str


class ReloadResponse(BaseModel):
    name: str
    reloaded: bool


class SyncItem(BaseModel):
    name: str
    version: str
    artifact_path: str = ''
    is_active: bool = True


class SyncRequest(BaseModel):
    models: list[SyncItem]


class SyncResponse(BaseModel):
    accepted: int
    active: list[str]
    inactive: list[str]


@router.get('', response_model=ModelsResponse)
async def list_models():
    loaded = set(ModelRegistry.list_models())
    # Union loaded names with any ONNX artifacts present in the cache dir
    # (flat files + versioned <name>/<version>/model[_int8].onnx layout).
    cache = Path(settings.model_cache_dir or '')
    artifact_names: set[str] = set()
    if cache.exists():
        artifact_names = {_canonical_name(p) for p in cache.glob('*.onnx')}
        for model_file in cache.glob('*/model*.onnx'):
            artifact_names.add(model_file.parent.name)

    names = sorted(loaded | artifact_names)
    return ModelsResponse(
        models=[
            ModelStatus(name=n, loaded=n in loaded, artifact=str(artifact_path(n)) if artifact_path(n) else None)
            for n in names
        ],
        cache_dir=str(cache),
    )


@router.post('/sync', response_model=SyncResponse)
async def sync_metadata(req: SyncRequest):
    """Apply Django's ModelMetadata truth: set active versions and unload
    inactive models so the next request reloads the promoted artifact."""
    active: dict[str, str] = {}
    inactive: list[str] = []
    for item in req.models:
        if item.is_active:
            active[item.name] = item.version
        else:
            inactive.append(item.name)

    _save_active_versions(active)

    # Unload anything not active so serving lazy-loads the current artifact.
    for name in list(ModelRegistry.list_models()):
        if name not in active:
            ModelRegistry.unload(name)

    return SyncResponse(accepted=len(req.models), active=sorted(active), inactive=sorted(inactive))


@router.get('/active', response_model=dict[str, str])
async def active_versions():
    """Return the active {name: version} map pushed from Django."""
    return _load_active_versions()


@router.post('/reload', response_model=ReloadResponse)
async def reload_model(req: ReloadRequest):
    """Unload a model so the next request loads the current artifact (canary/rollback)."""
    reloaded = ModelRegistry.unload(req.name)
    if not reloaded:
        raise HTTPException(status_code=404, detail=f'Model {req.name} is not loaded')
    return ReloadResponse(name=req.name, reloaded=True)
