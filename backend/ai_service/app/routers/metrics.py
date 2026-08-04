from fastapi import APIRouter

from ..monitoring import get_metrics

router = APIRouter()


@router.get('/metrics')
async def metrics():
    return get_metrics()
