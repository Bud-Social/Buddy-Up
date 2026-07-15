from fastapi import APIRouter, HTTPException, UploadFile, File
from pydantic import BaseModel

from ..food_engine import recognize_food

router = APIRouter()


class FoodItem(BaseModel):
    item: str
    confidence: float
    nutrition: dict


class FoodRecognitionResult(BaseModel):
    items: list[FoodItem]
    total_calories: float
    total_protein: float
    total_carbs: float
    total_fat: float
    health_benefits: list[str]
    method: str = 'model'


@router.post('/recognize', response_model=FoodRecognitionResult)
async def recognize_food_endpoint(file: UploadFile = File(...)):
    if not file.content_type or not file.content_type.startswith('image/'):
        raise HTTPException(status_code=400, detail='File must be an image')

    contents = await file.read()
    items_data = await recognize_food(contents)

    items = [
        FoodItem(item=it['item'], confidence=it['confidence'], nutrition=it['nutrition'])
        for it in items_data
    ]

    total_calories = sum(it['nutrition'].get('calories', 0) * it['confidence'] for it in items_data)
    total_protein = sum(it['nutrition'].get('protein', 0) * it['confidence'] for it in items_data)
    total_carbs = sum(it['nutrition'].get('carbs', 0) * it['confidence'] for it in items_data)
    total_fat = sum(it['nutrition'].get('fat', 0) * it['confidence'] for it in items_data)

    health_benefits = []
    seen = set()
    for it in items_data:
        for benefit in it['nutrition'].get('health_benefits', []):
            if benefit not in seen:
                health_benefits.append(benefit)
                seen.add(benefit)

    return FoodRecognitionResult(
        items=items,
        total_calories=round(total_calories, 1),
        total_protein=round(total_protein, 1),
        total_carbs=round(total_carbs, 1),
        total_fat=round(total_fat, 1),
        health_benefits=health_benefits,
        method='model',
    )
