from fastapi import APIRouter

from ..model_registry import ModelRegistry

router = APIRouter()


@router.get('/health')
async def health_check():
    return {
        'status': 'ok',
        'models_loaded': ModelRegistry.list_models(),
    }
