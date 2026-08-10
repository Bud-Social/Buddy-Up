import asyncio
import logging

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from ..summarize_engine import summarize

logger = logging.getLogger(__name__)

router = APIRouter()


class SummarizeRequest(BaseModel):
    text: str
    max_length: int = 150


class SummarizeResult(BaseModel):
    summary: str
    model: str
    truncated: bool
    input_chars: int
    output_chars: int


@router.post('', response_model=SummarizeResult)
async def summarize_text(req: SummarizeRequest):
    result = await asyncio.to_thread(summarize, req.text, req.max_length)
    if 'error' in result:
        raise HTTPException(status_code=400, detail=result['error'])
    return SummarizeResult(**result)
