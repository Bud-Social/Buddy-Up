import io
import logging

from fastapi import APIRouter, File, UploadFile, Form, HTTPException
from pydantic import BaseModel

from ..form_analyzer_engine import analyze_form, analyze_form_video

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
    if not file.content_type:
        raise HTTPException(status_code=400, detail='File content type missing')

    contents = await file.read()

    if file.content_type.startswith('image/'):
        result = analyze_form(contents, exercise)
    elif file.content_type.startswith('video/'):
        result = analyze_form_video(contents, exercise)
    else:
        raise HTTPException(status_code=400, detail='File must be an image or video')

    if 'error' in result:
        raise HTTPException(status_code=400, detail=result.get('error', 'Analysis failed'))

    return result
