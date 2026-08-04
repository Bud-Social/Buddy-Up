import json
import logging

import redis.asyncio as aioredis
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from ..config import settings
from ..embedding_engine import embed_text, find_top_matches, build_index, search_index, FaissIndex

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


class IndexRequest(BaseModel):
    index_name: str
    vectors: list[dict]


class IndexResponse(BaseModel):
    index_name: str
    vectors: int
    dimension: int | None = None
    method: str = 'faiss'


class IndexSearchRequest(BaseModel):
    index_name: str
    query: list[float]
    top_k: int = 20


class IndexSearchResult(BaseModel):
    id: str
    score: float


class IndexSearchResponse(BaseModel):
    matches: list[IndexSearchResult]


class IndexListResponse(BaseModel):
    indexes: list[str]


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


@router.post('/index/build', response_model=IndexResponse)
async def build_index_endpoint(req: IndexRequest):
    result = await build_index(req.index_name, req.vectors)
    return IndexResponse(
        index_name=result.get('index_name', req.index_name),
        vectors=result.get('vectors', 0),
        dimension=result.get('dimension'),
        method=result.get('method', 'faiss'),
    )


@router.post('/index/search', response_model=IndexSearchResponse)
async def search_index_endpoint(req: IndexSearchRequest):
    matches = await search_index(req.index_name, req.query, top_k=req.top_k)
    return IndexSearchResponse(matches=[IndexSearchResult(**m) for m in matches])


@router.get('/index', response_model=IndexListResponse)
async def list_indexes():
    return IndexListResponse(indexes=FaissIndex.list_indexes())
