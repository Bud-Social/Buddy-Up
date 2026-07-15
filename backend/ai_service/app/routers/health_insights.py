from fastapi import APIRouter
from pydantic import BaseModel

from ..health_insights_engine import analyze_health_insights

router = APIRouter()


class HealthInsightsRequest(BaseModel):
    workouts: list[dict] = []
    meals: list[dict] = []
    streak: dict = {}
    period: str = 'weekly'


@router.post('/analyze')
async def analyze(req: HealthInsightsRequest):
    return analyze_health_insights(req.model_dump())
