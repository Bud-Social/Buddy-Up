import json
import logging

import redis.asyncio as aioredis
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from ..config import settings
from ..embedding_engine import embed_text, find_top_matches

logger = logging.getLogger(__name__)

router = APIRouter()


class EmbeddingResult(BaseModel):
    vector: list[float]
    model: str
    dimension: int


class MatchRequest(BaseModel):
    profile_id: str
    top_k: int = 20


class MatchResult(BaseModel):
    profile_id: str
    score: float


class MatchResponse(BaseModel):
    matches: list[MatchResult]


async def _get_redis():
    return aioredis.from_url(settings.redis_url, decode_responses=True)


def _profile_key(profile_id: str) -> str:
    return f'profile_embedding:{profile_id}'


@router.post('/text', response_model=EmbeddingResult)
async def text_embedding(text: str):
    vector, dimension = await embed_text(text)
    return EmbeddingResult(
        vector=vector,
        model='sentence-transformers/all-MiniLM-L6-v2',
        dimension=dimension,
    )


@router.post('/store', status_code=204)
async def store_embedding(profile_id: str, vector: list[float]):
    r = await _get_redis()
    key = _profile_key(profile_id)
    await r.set(key, json.dumps(vector))
    await r.sadd('profile_embedding:all', profile_id)


@router.delete('/store/{profile_id}', status_code=204)
async def delete_embedding(profile_id: str):
    r = await _get_redis()
    key = _profile_key(profile_id)
    await r.delete(key)
    await r.srem('profile_embedding:all', profile_id)


@router.post('/match', response_model=MatchResponse)
async def match_profiles(req: MatchRequest):
    r = await _get_redis()
    query_key = _profile_key(req.profile_id)
    query_raw = await r.get(query_key)
    if not query_raw:
        raise HTTPException(status_code=404, detail='Profile embedding not found. Generate it first via /text + /store.')

    query_vec = json.loads(query_raw)
    all_ids = await r.smembers('profile_embedding:all')
    if not all_ids:
        return MatchResponse(matches=[])

    candidates = {}
    for pid in all_ids:
        if pid == req.profile_id:
            continue
        raw = await r.get(_profile_key(pid))
        if raw:
            candidates[pid] = json.loads(raw)

    top = await find_top_matches(query_vec, candidates, top_k=req.top_k)
    return MatchResponse(matches=[MatchResult(**m) for m in top])
