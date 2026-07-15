from fastapi import APIRouter
from pydantic import BaseModel

from ..onboarding_engine import generate_onboarding_plan

router = APIRouter()


class OnboardingPreferences(BaseModel):
    primary_goal: list[str] = []
    activity_level: str = 'moderately_active'
    preferred_workouts: list[str] = []
    dietary_preference: str = 'none'
    preferred_time: str = 'flexible'


@router.post('/personalise')
async def personalise_onboarding(prefs: OnboardingPreferences):
    return generate_onboarding_plan(prefs.model_dump())
