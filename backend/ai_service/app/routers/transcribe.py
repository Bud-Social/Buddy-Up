import asyncio
import logging
import os
import tempfile

from fastapi import APIRouter, File, HTTPException, UploadFile
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


@router.post('/transcribe-file')
async def transcribe_file(file: UploadFile = File(...)):
    """Upload-in-place transcription (studio captions): browser → Django → us.

    Keeps audio off the public internet: Django streams the picked video to
    us over the internal network and we hand the temp file to whisper.
    """
    suffix = os.path.splitext(file.filename or '')[1] or '.mp4'
    fd, tmp_path = tempfile.mkstemp(prefix='studio_transcribe_', suffix=suffix)
    os.close(fd)
    try:
        while True:
            chunk = await file.read(1024 * 1024)
            if not chunk:
                break
            with open(tmp_path, 'ab') as fh:
                fh.write(chunk)
        result = await asyncio.to_thread(transcribe_engine.transcribe_path, tmp_path)
    except ImportError as exc:
        raise HTTPException(status_code=503, detail=f'Transcription unavailable: {exc}') from exc
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    except Exception as exc:  # noqa: BLE001
        logger.warning('File transcription failed: %s', exc)
        raise HTTPException(status_code=503, detail=f'Transcription failed: {exc}') from exc
    finally:
        if os.path.exists(tmp_path):
            os.unlink(tmp_path)
        await file.close()
    return result
