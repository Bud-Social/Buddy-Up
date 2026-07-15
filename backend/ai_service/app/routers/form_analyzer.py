import io
import logging

from fastapi import APIRouter, File, UploadFile, Form, HTTPException
from pydantic import BaseModel

from ..form_analyzer_engine import analyze_form

logger = logging.getLogger(__name__)

router = APIRouter()


class FormAnalysisResult(BaseModel):
    exercise: str
    form_score: int
    feedback: list[str]
    issues: list[str]


@router.post('/analyze', response_model=FormAnalysisResult)
async def analyze_workout_form(
    file: UploadFile = File(...),
    exercise: str = Form('auto'),
):
    if not file.content_type or not file.content_type.startswith('image/'):
        raise HTTPException(status_code=400, detail='File must be an image')

    contents = await file.read()
    result = analyze_form(contents, exercise)

    if 'error' in result:
        raise HTTPException(status_code=400, detail=result.get('error', 'Analysis failed'))

    return result