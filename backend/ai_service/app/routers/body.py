from fastapi import APIRouter, HTTPException, UploadFile, File
from pydantic import BaseModel

from ..weight_engine import read_scale_weight

router = APIRouter()


class WeightReading(BaseModel):
    weight_kg: float | None = None
    weight_lb: float | None = None
    unit: str = 'kg'
    confidence: float = 0.0
    raw_text: str = ''
    method: str = 'florence-2'


@router.post('/read-weight', response_model=WeightReading)
async def read_weight_endpoint(file: UploadFile = File(...)):
    if not file.content_type or not file.content_type.startswith('image/'):
        raise HTTPException(status_code=400, detail='File must be an image')

    contents = await file.read()
    result = read_scale_weight(contents)
    return WeightReading(**result)
