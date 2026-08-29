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


class VideoFormAnalysisResult(BaseModel):
    """Video analysis schema — mirrors analyze_form_video's aggregate output.

    `form_score` is the image-schema alias of `avg_form_score` so clients can
    read one field across image and video responses.
    """

    exercise: str
    video: bool = True
    frames_analyzed: int
    avg_form_score: int
    min_form_score: int
    max_form_score: int
    best_frame: int
    worst_frame: int
    top_issues: list[dict]
    feedback: list[str]
    issues: list[str]
    form_score: int


@router.post('/analyze', response_model=FormAnalysisResult | VideoFormAnalysisResult)
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

    if result.get('video'):
        return VideoFormAnalysisResult(**result, form_score=result['avg_form_score'])
    return FormAnalysisResult(**result)
