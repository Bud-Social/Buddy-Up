"""Redis-backed LinUCB bandit storage for feed ranking (Sprint B1).

Bandit state persisted in Redis so models survive restarts and work across
multiple AI-service workers.
"""
import json
import logging
import os
from typing import Any

import numpy as np
import redis

logger = logging.getLogger(__name__)

# Redis key prefixes
PREFS_PREFIX = "feed:prefs:"
BANDIT_PREFIX = "feed:bandit:"

# Hyper-parameters (must match Django's redis_bandit.py)
DIM = 10
LAMBDA_REG = 1.0

# Redis connection pool (singleton)
_redis_pool: redis.ConnectionPool | None = None


def _get_redis_url() -> str:
    """Get Redis URL from environment or Django settings."""
    return os.environ.get('REDIS_URL', 'redis://redis:6379/0')


def _get_redis() -> redis.Redis:
    """Get Redis client from shared connection pool."""
    global _redis_pool
    if _redis_pool is None:
        _redis_pool = redis.ConnectionPool.from_url(
            _get_redis_url(),
            max_connections=20,
            decode_responses=True,
        )
    return redis.Redis(connection_pool=_redis_pool)


def _prefs_key(user_id: str) -> str:
    return f"{PREFS_PREFIX}{user_id}"


def _bandit_key(user_id: str, arm_key: str) -> str:
    return f"{BANDIT_PREFIX}{user_id}:{arm_key}"


def _encode_matrix(mat: np.ndarray) -> str:
    """Encode numpy matrix to JSON string for Redis storage."""
    return json.dumps(mat.tolist())


def _decode_matrix(data: str) -> np.ndarray:
    """Decode JSON string back to numpy matrix."""
    return np.array(json.loads(data), dtype=np.float64)


def _encode_vector(vec: np.ndarray) -> str:
    """Encode numpy vector to JSON string for Redis storage."""
    return json.dumps(vec.tolist())


def _decode_vector(data: str) -> np.ndarray:
    """Decode JSON string back to numpy vector."""
    return np.array(json.loads(data), dtype=np.float64)


# --- Public API ---


def get_user_prefs(user_id: str) -> np.ndarray:
    """Load user preference vector from Redis, or create default."""
    r = _get_redis()
    key = f"{PREFS_PREFIX}{user_id}"
    data = r.get(key)
    if data is None:
        prefs = np.full(10, 0.5, dtype=np.float64)
        r.set(key, json.dumps(prefs.tolist()))
        return prefs
    return np.array(json.loads(data), dtype=np.float64)


def save_user_prefs(user_id: str, prefs: np.ndarray) -> None:
    """Persist user preference vector to Redis."""
    r = _get_redis()
    r.set(f"{PREFS_PREFIX}{user_id}", json.dumps(prefs.tolist()))


def get_bandit_state(user_id: str, arm_key: str) -> dict[str, Any]:
    """Load LinUCB state (A, b, count) from Redis, or create default."""
    r = _get_redis()
    key = f"{BANDIT_PREFIX}{user_id}:{arm_key}"
    data = r.get(key)
    if data is None:
        return {
            'A': np.eye(10) * 1.0,
            'b': np.zeros(10, dtype=np.float64),
            'count': 0,
        }
    state = json.loads(data)
    return {
        'A': np.array(state['A'], dtype=np.float64),
        'b': np.array(state['b'], dtype=np.float64),
        'count': state['count'],
    }


def save_bandit_state(user_id: str, arm_key: str, state: dict[str, Any]) -> None:
    """Persist LinUCB state to Redis."""
    r = _get_redis()
    key = f"{BANDIT_PREFIX}{user_id}:{arm_key}"
    r.set(key, json.dumps({
        'A': state['A'].tolist(),
        'b': state['b'].tolist(),
        'count': state['count'],
    }))


def predict_bandit(user_id: str, arm_key: str, context: np.ndarray, alpha: float = 1.0) -> float:
    """Compute LinUCB UCB score for a context."""
    state = get_bandit_state(user_id, arm_key)
    try:
        a_inv = np.linalg.inv(state['A'])
    except np.linalg.LinAlgError:
        a_inv = np.linalg.inv(state['A'] + np.eye(10) * 1e-6)
    theta = a_inv @ state['b']
    mean = float(theta @ context)
    bonus = alpha * float(np.sqrt(max(context @ a_inv @ context, 0.0)))
    return float(np.clip(mean + bonus, 0.0, 1.0))


def _user_lock(user_id: str):
    """Distributed lock so concurrent feedback can't clobber RMW state."""
    r = _get_redis()
    return r.lock(f"lock:bandit:{user_id}", timeout=5, blocking_timeout=2)


def update_bandit(user_id: str, arm_key: str, context: np.ndarray, reward: float) -> None:
    """Update LinUCB matrices with observed reward (locked read-modify-write)."""
    lock = _user_lock(user_id)
    try:
        acquired = lock.acquire(blocking=True)
    except Exception:  # noqa: BLE001 — Redis lock unavailable: degrade to best-effort
        acquired = True
    try:
        state = get_bandit_state(user_id, arm_key)
        state['A'] = state['A'] + np.outer(context, context)
        state['b'] = state['b'] + float(np.clip(reward, 0.0, 1.0)) * context
        state['count'] += 1
        save_bandit_state(user_id, arm_key, state)
    finally:
        if acquired:
            try:
                lock.release()
            except Exception:  # noqa: BLE001
                pass


def get_bandit_stats(user_id: str, arm_key: str) -> dict[str, Any]:
    """Get current bandit state for debugging/monitoring."""
    state = get_bandit_state(user_id, arm_key)
    return {
        'user_id': user_id,
        'arm_key': arm_key,
        'count': state['count'],
    }


# Re-export for backward compatibility
def _features(candidate: dict, now: float | None = None):
    """Normalise a candidate post into a fixed-length feature vector.

    This is a minimal duplicate of the Django feature engineering.
    """
    import time
    _REL_WEIGHTS = {'buddy': 1.0, 'gym': 0.75, 'following': 0.5, 'none': 0.0}
    _TYPE_WEIGHTS = {'workout_log': 0.3, 'meal': 0.2, 'moment': 0.1, 'text': 0.05}

    now = now or time.time()
    rel = _REL_WEIGHTS.get(str(candidate.get('relationship', 'none')), 0.0)
    ptype = _TYPE_WEIGHTS.get(str(candidate.get('post_type', 'text')), 0.05)

    reactions = float(candidate.get('reactions', 0) or 0)
    comments = float(candidate.get('comments', 0) or 0)
    saves = float(candidate.get('saves', 0) or 0)
    engagement = __import__('math').tanh((3 * reactions + 2 * comments + 4 * saves) / 50.0)

    age_hours = float(candidate.get('age_hours', 24) or 24)
    recency = __import__('math').exp(-age_hours / 24.0)

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