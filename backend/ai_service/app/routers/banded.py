from fastapi import APIRouter, File, HTTPException, UploadFile
from pydantic import BaseModel

from ..banded_engine import (
    BandedUnavailable,
    act_rl_jepa,
    act_rl_nlp,
    classify_image_vision,
    classify_text_nlp,
    embed_recsys_items,
    score_multimodal,
)

router = APIRouter()


class TextIn(BaseModel):
    text: str


class LabelOut(BaseModel):
    label: str
    confidence: float
    method: str


class VisionOut(BaseModel):
    label: str
    confidence: float
    action: str
    method: str


class EmbeddingsIn(BaseModel):
    embeddings: list[list[float]]


class MultimodalOut(BaseModel):
    top_class: list[int]
    confidence: list[float]
    method: str


class ItemIdsIn(BaseModel):
    item_ids: list[int]


class ItemVectorsOut(BaseModel):
    vectors: list[list[float]]
    dim: int
    method: str


class ActionOut(BaseModel):
    action: int
    probs: list[float]
    method: str


class ObsIn(BaseModel):
    obs: list[float]


def _or_503(fn, *args):
    try:
        return fn(*args)
    except BandedUnavailable as exc:
        raise HTTPException(status_code=503, detail=str(exc))


@router.post('/nlp/classify', response_model=LabelOut)
async def banded_nlp_classify(req: TextIn):
    return _or_503(classify_text_nlp, req.text)


@router.post('/vision/classify', response_model=VisionOut)
async def banded_vision_classify(file: UploadFile = File(...)):
    if not file.content_type or not file.content_type.startswith('image/'):
        raise HTTPException(status_code=400, detail='File must be an image')
    return _or_503(classify_image_vision, await file.read())


@router.post('/multimodal/score', response_model=MultimodalOut)
async def banded_multimodal_score(req: EmbeddingsIn):
    try:
        return _or_503(score_multimodal, req.embeddings)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc))


@router.post('/recsys/embed', response_model=ItemVectorsOut)
async def banded_recsys_embed(req: ItemIdsIn):
    if not req.item_ids:
        raise HTTPException(status_code=400, detail='item_ids must not be empty')
    return _or_503(embed_recsys_items, req.item_ids)


@router.post('/rl-nlp/act', response_model=ActionOut)
async def banded_rl_nlp_act(req: TextIn):
    return _or_503(act_rl_nlp, req.text)


@router.post('/rl-jepa/act', response_model=ActionOut)
async def banded_rl_jepa_act(req: ObsIn):
    try:
        return _or_503(act_rl_jepa, req.obs)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc))


# Form-encoded alias so the moderation pipeline can fan out cheaply.
@router.post('/vision/classify-form', response_model=VisionOut)
async def banded_vision_classify_form(file: UploadFile = File(...)):
    return await banded_vision_classify(file)
