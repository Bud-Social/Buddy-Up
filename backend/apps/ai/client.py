"""Shared HTTP helpers for calls to the AI microservice.

The service enforces a shared X-API-Key when AI_API_KEY is configured on
either side; production must set it on both. Local dev with no key keeps
the legacy open behaviour.
"""
import logging

from django.conf import settings

logger = logging.getLogger(__name__)


def ai_service_url() -> str:
    return getattr(settings, 'AI_SERVICE_URL', 'http://localhost:8003').rstrip('/')


def ai_service_headers(extra: dict | None = None) -> dict:
    headers = dict(extra or {})
    api_key = getattr(settings, 'AI_API_KEY', '')
    if api_key:
        headers['X-API-Key'] = api_key
    return headers


def ai_post(url: str, *args, **kwargs):
    """requests.post with the AI service auth header injected."""
    import requests
    kwargs['headers'] = {**ai_service_headers(), **(kwargs.get('headers') or {})}
    return requests.post(url, *args, **kwargs)


def ai_get(url: str, *args, **kwargs):
    """requests.get with the AI service auth header injected."""
    import requests
    kwargs['headers'] = {**ai_service_headers(), **(kwargs.get('headers') or {})}
    return requests.get(url, *args, **kwargs)
