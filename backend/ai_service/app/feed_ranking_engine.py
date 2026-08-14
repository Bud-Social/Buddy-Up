"""Feed ranking engine: two-tower-style content scoring + LinUCB bandit.

Two components:
1. Content score = dot(user preference vector, normalised post features).
2. LinUCB contextual bandit per (user, author) arm -> explore/exploit balance.

Django's `for_you` tab POSTs candidates to `/api/v1/feed/rank` and gets back the
same list re-ranked with `ml_score` + `explore`. If the AI service is down, Django
falls back to its existing rank Case — this engine is additive.

Bandit state is now persisted in Redis (shared across workers, survives restarts).
See `apps.feed.redis_bandit` for the storage layer.
"""
import logging
import math
import time

import numpy as np

from app.redis_bandit import (
    get_user_prefs,
    save_user_prefs,
    predict_bandit,
    update_bandit,
    get_bandit_stats,
    _features as _redis_features,
)

logger = logging.getLogger(__name__)

# Hyper-parameters (must match redis_bandit.py)
DIM = 10
ALPHA = 1.0  # UCB exploration coefficient
PREF_LR = 0.1  # preference-vector learning rate
BLEND_WEIGHT = 0.5  # content vs bandit blend (rest = content score)

# Post feature layout (keep order stable — vectors are positional)
_REL_WEIGHTS = {'buddy': 1.0, 'gym': 0.75, 'following': 0.5, 'none': 0.0}
_TYPE_WEIGHTS = {'workout_log': 0.3, 'meal': 0.2, 'moment': 0.1, 'text': 0.05}


def _features(candidate: dict, now: float | None = None) -> np.ndarray:
    """Normalise a candidate post into a fixed-length feature vector.

    Delegates to the shared implementation in redis_bandit to keep
    feature engineering consistent across Django and AI service.
    """
    return _redis_features(candidate, now)


def _content_score(feat: np.ndarray, prefs: np.ndarray) -> float:
    score = float(np.dot(prefs, feat))
    return 0.0 if math.isnan(score) else max(0.0, min(score, 1.0))


def _arm_key(candidate: dict) -> str:
    return str(candidate.get('author_id') or candidate.get('post_id') or 'unknown')


def rank_feed(user_id: str, candidates: list[dict], bandit: bool = True) -> list[dict]:
    """Re-rank candidate posts. Returns input dicts augmented with ML fields."""
    prefs = get_user_prefs(user_id)
    ranked = []
    now = time.time()

    for cand in candidates:
        feat = _features(cand, now)
        content = _content_score(feat, prefs)
        arm_key = _arm_key(cand)

        if bandit:
            ucb = predict_bandit(user_id, arm_key, feat)
            ml_score = BLEND_WEIGHT * ucb + (1 - BLEND_WEIGHT) * content
            explore = ucb > content + 0.1
        else:
            ucb = 0.0
            ml_score = content
            explore = False

        out = dict(cand)
        out['ml_score'] = round(float(np.clip(ml_score, 0.0, 1.0)), 4)
        out['ucb_score'] = round(ucb, 4)
        out['explore'] = explore
        out['arm_key'] = arm_key
        ranked.append(out)

    ranked.sort(key=lambda c: (-c.get('is_pinned', 0), -c['ml_score']))
    return ranked


def record_feedback(user_id: str, arm_key: str, context: dict, reward: float) -> dict:
    """Update bandit matrices and the user preference vector from a reward."""
    feat = _features(context)
    update_bandit(user_id, arm_key, feat, reward)

    prefs = get_user_prefs(user_id)
    new_prefs = prefs + PREF_LR * (float(np.clip(reward, 0.0, 1.0)) - 0.5) * feat
    save_user_prefs(user_id, new_prefs)

    stats = get_bandit_stats(user_id, arm_key)
    return {
        'user_id': user_id,
        'arm_key': arm_key,
        'reward': float(reward),
        'exploited_steps': stats['count'],
    }