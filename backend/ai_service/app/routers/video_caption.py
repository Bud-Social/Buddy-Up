import asyncio
import logging

from fastapi import APIRouter, File, Form, HTTPException, UploadFile
from pydantic import BaseModel

from ..video_caption_engine import describe_workout_video

logger = logging.getLogger(__name__)

router = APIRouter()


class CaptionResult(BaseModel):
    description: str
    frames_used: int
    model: str
    exercise: str


@router.post('/describe', response_model=CaptionResult)
async def describe_video(
    file: UploadFile = File(...),
    exercise: str = Form('auto'),
):
    if not file.content_type or not file.content_type.startswith('video/'):
        raise HTTPException(status_code=400, detail='File must be a video')

    contents = await file.read()
    result = await asyncio.to_thread(describe_workout_video, contents, exercise)
    if 'error' in result:
        raise HTTPException(status_code=400, detail=result['error'])

    return CaptionResult(
        description=result['description'],
        frames_used=result['frames_used'],
        model=result['model'],
        exercise=result['exercise'],
    )
