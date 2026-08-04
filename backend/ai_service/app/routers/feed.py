from typing import Any

from fastapi import APIRouter
from pydantic import BaseModel

from ..feed_ranking_engine import rank_feed, record_feedback

router = APIRouter()


class RankRequest(BaseModel):
    user_id: str
    candidates: list[dict[str, Any]]
    bandit: bool = True


class RankResponse(BaseModel):
    ranked: list[dict[str, Any]]
    count: int


class FeedbackRequest(BaseModel):
    user_id: str
    arm_key: str
    reward: float
    context: dict[str, Any] = {}


class FeedbackResponse(BaseModel):
    user_id: str
    arm_key: str
    reward: float
    exploited_steps: int


@router.post('/rank', response_model=RankResponse)
async def rank_feed_endpoint(req: RankRequest):
    ranked = rank_feed(req.user_id, req.candidates, bandit=req.bandit)
    return RankResponse(ranked=ranked, count=len(ranked))


@router.post('/feedback', response_model=FeedbackResponse)
async def feedback_endpoint(req: FeedbackRequest):
    result = record_feedback(req.user_id, req.arm_key, req.context, req.reward)
    return FeedbackResponse(**result)
