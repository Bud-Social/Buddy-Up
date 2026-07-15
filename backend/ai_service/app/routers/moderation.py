from fastapi import APIRouter, HTTPException, UploadFile, File, Form
from pydantic import BaseModel

from ..moderation_engine import analyze_image, analyze_text

router = APIRouter()


class ModerationResult(BaseModel):
    is_nsfw: bool
    confidence: float
    labels: list[str]
    action: str
    method: str = 'model'


class TextModerationResult(BaseModel):
    is_toxic: bool
    toxicity_score: float
    categories: dict
    label: str = 'not_toxic'
    action: str = 'approve'
    method: str = 'model'


@router.post('/image', response_model=ModerationResult)
async def moderate_image(file: UploadFile = File(...)):
    if not file.content_type or not file.content_type.startswith('image/'):
        raise HTTPException(status_code=400, detail='File must be an image')

    contents = await file.read()
    result = await analyze_image(contents)

    return ModerationResult(
        is_nsfw=result['is_nsfw'],
        confidence=result['confidence'],
        labels=result['labels'],
        action=result['action'],
        method=result.get('method', 'model'),
    )


@router.post('/text', response_model=TextModerationResult)
async def moderate_text(text: str = Form(...)):
    result = await analyze_text(text)

    return TextModerationResult(
        is_toxic=result['is_toxic'],
        toxicity_score=result['toxicity_score'],
        categories=result['categories'],
        label=result.get('label', 'not_toxic'),
        action=result['action'],
        method=result.get('method', 'model'),
    )
