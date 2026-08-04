"""Feed ranking engine: two-tower-style content scoring + LinUCB bandit.

Two components:
1. Content score = dot(user preference vector, normalised post features).
2. LinUCB contextual bandit per (user, author) arm -> explore/exploit balance.

Django's `for_you` tab POSTs candidates to `/api/v1/feed/rank` and gets back the
same list re-ranked with `ml_score` + `explore`. If the AI service is down, Django
falls back to its existing rank Case — this engine is additive.
"""
import logging
import math
import time
from typing import Any

import numpy as np

logger = logging.getLogger(__name__)

# Hyper-parameters
DIM = 10
ALPHA = 1.0  # UCB exploration coefficient
LAMBDA_REG = 1.0  # ridge regularisation
PREF_LR = 0.1  # preference-vector learning rate
BLEND_WEIGHT = 0.5  # content vs bandit blend (rest = content score)

# Post feature layout (keep order stable — vectors are positional)
_REL_WEIGHTS = {'buddy': 1.0, 'gym': 0.75, 'following': 0.5, 'none': 0.0}
_TYPE_WEIGHTS = {'workout_log': 0.3, 'meal': 0.2, 'moment': 0.1, 'text': 0.05}

# In-memory per-user state: {user_id: {'prefs': np.ndarray}}
_PREFS: dict[str, Any] = {}
# LinUCB state: {(user_id, arm_key): {'A': ndarray, 'b': ndarray, 'count': int}}
_BANDITS: dict[tuple[str, str], dict[str, Any]] = {}


def _features(candidate: dict, now: float | None = None) -> np.ndarray:
    """Normalise a candidate post into a fixed-length feature vector."""
    now = now or time.time()
    rel = _REL_WEIGHTS.get(str(candidate.get('relationship', 'none')), 0.0)
    ptype = _TYPE_WEIGHTS.get(str(candidate.get('post_type', 'text')), 0.05)

    reactions = float(candidate.get('reactions', 0) or 0)
    comments = float(candidate.get('comments', 0) or 0)
    saves = float(candidate.get('saves', 0) or 0)
    engagement = math.tanh((3 * reactions + 2 * comments + 4 * saves) / 50.0)

    age_hours = float(candidate.get('age_hours', 24) or 24)
    recency = math.exp(-age_hours / 24.0)

    trust = float(candidate.get('author_trust', 0.5) or 0.5)
    affinity = float(candidate.get('author_affinity', 0.0) or 0.0)
    has_media = 1.0 if candidate.get('has_media') else 0.0
    is_video = 1.0 if candidate.get('is_video') else 0.0

    return np.array([
        rel,           # 0 relationship weight
        engagement,    # 1 engagement
        recency,       # 2 recency
        has_media,     # 3 media
        is_video,      # 4 video
        trust,         # 5 author trust
        affinity,      # 6 author affinity
        ptype,         # 7 post type
        min(age_hours / 168.0, 1.0),  # 8 normalised age
        1.0,           # 9 bias term
    ], dtype=np.float64)


def _user_prefs(user_id: str) -> np.ndarray:
    if user_id not in _PREFS:
        _PREFS[user_id] = np.array([0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5])
    return _PREFS[user_id]


def _content_score(feat: np.ndarray, prefs: np.ndarray) -> float:
    score = float(np.dot(prefs, feat))
    return 0.0 if math.isnan(score) else max(0.0, min(score, 1.0))


class LinUCB:
    """Contextual bandit with UCB exploration (per user+arm stored matrices)."""

    @staticmethod
    def _state(user_id: str, arm_key: str) -> dict[str, Any]:
        key = (user_id, arm_key)
        if key not in _BANDITS:
            _BANDITS[key] = {
                'A': np.eye(DIM) * LAMBDA_REG,
                'b': np.zeros(DIM),
                'count': 0,
            }
        return _BANDITS[key]

    @staticmethod
    def predict(user_id: str, arm_key: str, context: np.ndarray) -> float:
        state = LinUCB._state(user_id, arm_key)
        try:
            a_inv = np.linalg.inv(state['A'])
        except np.linalg.LinAlgError:
            a_inv = np.linalg.inv(state['A'] + np.eye(DIM) * 1e-6)
        theta = a_inv @ state['b']
        mean = float(theta @ context)
        bonus = ALPHA * float(np.sqrt(max(context @ a_inv @ context, 0.0)))
        return float(np.clip(mean + bonus, 0.0, 1.0))

    @staticmethod
    def update(user_id: str, arm_key: str, context: np.ndarray, reward: float) -> None:
        state = LinUCB._state(user_id, arm_key)
        state['A'] = state['A'] + np.outer(context, context)
        state['b'] = state['b'] + float(np.clip(reward, 0.0, 1.0)) * context
        state['count'] += 1


def _arm_key(candidate: dict) -> str:
    return str(candidate.get('author_id') or candidate.get('post_id') or 'unknown')


def rank_feed(user_id: str, candidates: list[dict], bandit: bool = True) -> list[dict]:
    """Re-rank candidate posts. Returns input dicts augmented with ML fields."""
    prefs = _user_prefs(user_id)
    ranked = []
    now = time.time()

    for cand in candidates:
        feat = _features(cand, now)
        content = _content_score(feat, prefs)
        arm_key = _arm_key(cand)

        if bandit:
            ucb = LinUCB.predict(user_id, arm_key, feat)
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
    LinUCB.update(user_id, arm_key, feat, reward)

    prefs = _user_prefs(user_id)
    _PREFS[user_id] = prefs + PREF_LR * (float(np.clip(reward, 0.0, 1.0)) - 0.5) * feat

    state = LinUCB._state(user_id, arm_key)
    return {
        'user_id': user_id,
        'arm_key': arm_key,
        'reward': float(reward),
        'exploited_steps': state['count'],
    }
