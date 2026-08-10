import asyncio
import logging

from fastapi import APIRouter, HTTPException
from fastapi.responses import Response
from pydantic import BaseModel

from ..tts_engine import list_speakers, synthesize

logger = logging.getLogger(__name__)

router = APIRouter()


class TTSRequest(BaseModel):
    text: str
    speaker: str | None = None


class SpeakersResult(BaseModel):
    speakers: list[str]
    default: str


@router.post('/synthesize')
async def synthesize_speech(req: TTSRequest):
    result = await asyncio.to_thread(synthesize, req.text, req.speaker)
    if 'error' in result:
        raise HTTPException(status_code=503, detail=result['error'])
    return Response(
        content=result['audio_bytes'],
        media_type=result['media_type'],
        headers={
            'X-Speaker': result['speaker'],
            'X-Sample-Rate': str(result['sample_rate']),
            'X-Model': result['model'],
        },
    )


@router.get('/speakers', response_model=SpeakersResult)
async def speakers():
    from ..config import settings

    return SpeakersResult(speakers=list_speakers(), default=settings.tts_default_speaker or 'slt')
