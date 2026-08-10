"""Redis-backed LinUCB bandit storage for feed ranking (Sprint B1).

Moves bandit state from in-memory dicts to Redis so models survive restarts
and work across multiple AI-service workers.
"""
import json
import logging
import math
from typing import Any

import numpy as np
import redis

from django.conf import settings

logger = logging.getLogger(__name__)

# Redis key prefixes
PREFS_PREFIX = "feed:prefs:"
BANDIT_PREFIX = "feed:bandit:"

# Hyper-parameters (must match feed_ranking_engine.py)
DIM = 10
LAMBDA_REG = 1.0

# Redis connection pool (singleton)
_redis_pool: redis.ConnectionPool | None = None


def _get_redis() -> redis.Redis:
    """Get Redis client from shared connection pool."""
    global _redis_pool
    if _redis_pool is None:
        _redis_pool = redis.ConnectionPool.from_url(
            settings.REDIS_URL,
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


# --- Public API (mirrors feed_ranking_engine.py internal functions) ---


def get_user_prefs(user_id: str) -> np.ndarray:
    """Load user preference vector from Redis, or create default."""
    r = _get_redis()
    key = _prefs_key(user_id)
    data = r.get(key)
    if data is None:
        # Default neutral preference vector
        prefs = np.full(DIM, 0.5, dtype=np.float64)
        r.set(key, _encode_vector(prefs))
        return prefs
    return _decode_vector(data)


def save_user_prefs(user_id: str, prefs: np.ndarray) -> None:
    """Persist user preference vector to Redis."""
    r = _get_redis()
    r.set(_prefs_key(user_id), _encode_vector(prefs))


def get_bandit_state(user_id: str, arm_key: str) -> dict[str, Any]:
    """Load LinUCB state (A, b, count) from Redis, or create default."""
    r = _get_redis()
    key = _bandit_key(user_id, arm_key)
    data = r.get(key)
    if data is None:
        return {
            'A': np.eye(DIM) * LAMBDA_REG,
            'b': np.zeros(DIM, dtype=np.float64),
            'count': 0,
        }
    state = json.loads(data)
    return {
        'A': _decode_matrix(state['A']),
        'b': _decode_vector(state['b']),
        'count': state['count'],
    }


def save_bandit_state(user_id: str, arm_key: str, state: dict[str, Any]) -> None:
    """Persist LinUCB state to Redis."""
    r = _get_redis()
    key = _bandit_key(user_id, arm_key)
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
        a_inv = np.linalg.inv(state['A'] + np.eye(DIM) * 1e-6)
    theta = a_inv @ state['b']
    mean = float(theta @ context)
    bonus = alpha * float(np.sqrt(max(context @ a_inv @ context, 0.0)))
    return float(np.clip(mean + bonus, 0.0, 1.0))


def update_bandit(user_id: str, arm_key: str, context: np.ndarray, reward: float) -> None:
    """Update LinUCB matrices with observed reward."""
    state = get_bandit_state(user_id, arm_key)
    state['A'] = state['A'] + np.outer(context, context)
    state['b'] = state['b'] + float(np.clip(reward, 0.0, 1.0)) * context
    state['count'] += 1
    save_bandit_state(user_id, arm_key, state)


def get_bandit_stats(user_id: str, arm_key: str) -> dict[str, Any]:
    """Get current bandit state for debugging/monitoring."""
    state = get_bandit_state(user_id, arm_key)
    return {
        'user_id': user_id,
        'arm_key': arm_key,
        'count': state['count'],
    }


def list_user_bandits(user_id: str) -> list[dict[str, Any]]:
    """List all bandits for a user (for admin/debug)."""
    r = _get_redis()
    pattern = f"{BANDIT_PREFIX}{user_id}:*"
    keys = r.keys(pattern)
    results = []
    for key in keys:
        arm_key = key.split(':', 2)[-1]
        state = get_bandit_state(user_id, arm_key)
        results.append({
            'arm_key': arm_key,
            'count': state['count'],
        })
    return results


def reset_user_state(user_id: str) -> None:
    """Delete all bandit/pref state for a user (for testing/admin)."""
    r = _get_redis()
    r.delete(_prefs_key(user_id))
    pattern = f"{BANDIT_PREFIX}{user_id}:*"
    keys = r.keys(pattern)
    if keys:
        r.delete(*keys)