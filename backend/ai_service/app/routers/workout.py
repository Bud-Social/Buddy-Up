from fastapi import APIRouter
from pydantic import BaseModel

from ..workout_engine import WorkoutAnalysis

router = APIRouter()


class WorkoutEntry(BaseModel):
    workout_log_data: dict | None = None


class WorkoutRequest(BaseModel):
    history: list[WorkoutEntry]


@router.post('/analyze')
async def analyze_workouts(req: WorkoutRequest):
    raw = [e.model_dump() for e in req.history]
    engine = WorkoutAnalysis(raw)
    result = engine.analyze()
    return result
