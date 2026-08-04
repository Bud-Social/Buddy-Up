"""Push ModelMetadata state to the AI service (Sprint C2 canary/rollback).

Django is the source of truth for which model version is active. Flipping
`is_active` (or editing a row) pushes the full active set to the AI service's
`/api/v1/models/sync` endpoint, which updates its internal registry so the next
request loads the promoted artifact.
"""
import logging

import requests
from django.conf import settings

logger = logging.getLogger(__name__)


def push_model_metadata() -> tuple[int, dict | None]:
    """Send all ModelMetadata rows to the AI service.

    Returns (count_synced, response_json). Count is 0 and response is None if
    the AI service is unreachable (degraded — serving falls back to its own
    defaults).
    """
    from .models import ModelMetadata

    rows = list(ModelMetadata.objects.all().values(
        'name', 'version', 'artifact_path', 'is_active',
    ))
    if not rows:
        return 0, None

    url = f'{settings.AI_SERVICE_URL}/api/v1/models/sync'
    try:
        resp = requests.post(url, json={'models': rows}, timeout=10)
        resp.raise_for_status()
        return len(rows), resp.json()
    except requests.RequestException as exc:
        logger.warning('Model metadata sync to AI service failed: %s', exc)
        return 0, None
