"""Raw Redis access for sorted-set operations.

Django's cache API (``django.core.cache.backends.redis.RedisCache``) exposes
only get/set/delete — no ``zadd``/``zrangebyscore``/``zrem``. Features that
need sorted sets (random-drop matching pool, ranked feed) use this helper to
get a real redis-py client instead of calling cache methods that don't exist.
"""
import logging

import redis
from django.conf import settings

logger = logging.getLogger(__name__)


def get_raw_redis():
    """Return a redis-py client for REDIS_URL, or None when unavailable."""
    url = getattr(settings, 'REDIS_URL', '')
    if not url:
        return None
    try:
        return redis.Redis.from_url(url)
    except Exception:  # noqa: BLE001 — caller decides how to degrade
        logger.warning('Could not create Redis client from REDIS_URL')
        return None
