from fastapi import APIRouter
from pydantic import BaseModel

from ..meal_plan_engine import personalise_meal_plan

router = APIRouter()


class PersonaliseRequest(BaseModel):
    profile_summary: str
    goals: str
    dietary_preferences: list[str]
    allergies: list[str]
    calorie_target: int | None = None
    plan_template: dict | None = None


class PersonaliseResponse(BaseModel):
    adjusted_portions: bool
    substitutions: list[dict]
    macro_summary: dict
    shopping_list: list[str]
    notes: str


@router.post('/personalise', response_model=PersonaliseResponse)
async def personalise_meal_plan_endpoint(req: PersonaliseRequest):
    result = await personalise_meal_plan(req.model_dump())
    return PersonaliseResponse(**result)
