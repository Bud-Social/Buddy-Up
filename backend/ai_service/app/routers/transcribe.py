import asyncio
import logging

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from .. import transcribe_engine

logger = logging.getLogger(__name__)

router = APIRouter()


class TranscribeRequest(BaseModel):
    media_url: str


@router.post('/transcribe')
async def transcribe(req: TranscribeRequest):
    try:
        result = await asyncio.to_thread(transcribe_engine.transcribe, req.media_url)
    except ImportError as exc:
        raise HTTPException(status_code=503, detail=f'Transcription unavailable: {exc}') from exc
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    except Exception as exc:  # noqa: BLE001
        logger.warning('Transcription failed for %s: %s', req.media_url, exc)
        raise HTTPException(status_code=503, detail=f'Transcription failed: {exc}') from exc
    return result
