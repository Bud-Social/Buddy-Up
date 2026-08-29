import logging

from celery import shared_task
from django.utils import timezone

logger = logging.getLogger(__name__)

EVENT_NAME_RE = None  # compiled lazily


def _event_name_valid(name: str) -> bool:
    global EVENT_NAME_RE
    if EVENT_NAME_RE is None:
        import re
        EVENT_NAME_RE = re.compile(r'^[a-z][a-z0-9_.]{2,63}$')
    return bool(EVENT_NAME_RE.match(name or ''))


def build_event_rows(events, actor_profile=None):
    """Validate + convert raw client event dicts into AnalyticsEvent rows.

    Returns (rows, skipped_count). Events without consent.analytics=true are
    skipped; malformed names/sizes are skipped. Never raises for bad events.
    """
    from .models import AnalyticsEvent

    rows = []
    skipped = 0
    for event in events[:200]:
        try:
            if not isinstance(event, dict):
                skipped += 1
                continue
            name = str(event.get('event_name') or '')
            if not _event_name_valid(name):
                skipped += 1
                continue
            consent = event.get('consent') or {}
            if not (consent.get('analytics') is True or consent.get('analytics') == 'true'):
                skipped += 1
                continue
            properties = event.get('properties') or {}
            if not isinstance(properties, dict):
                properties = {}
            rows.append(AnalyticsEvent(
                event_name=name[:64],
                event_version=int(event.get('event_version') or 1),
                occurred_at=event.get('occurred_at'),
                actor=actor_profile,
                anonymous_id=str(event.get('anonymous_id') or '')[:128],
                session_id=str(event.get('session_id') or '')[:64],
                platform=str(event.get('platform') or '')[:16],
                surface=str(event.get('surface') or '')[:32],
                object_type=str(event.get('object_type') or '')[:32],
                object_id=str(event.get('object_id') or '')[:64],
                properties=properties,
                consent={'analytics': True},
                schema_version=int(event.get('schema_version') or 1),
            ))
        except Exception:  # noqa: BLE001 — one bad event never rejects the batch
            skipped += 1
    return rows, skipped


@shared_task
def record_events(events, actor_user_id=None):
    """Persist a batch of behavioral events (fire-and-forget friendly)."""
    from apps.profiles.models import Profile
    from .models import AnalyticsEvent

    actor = None
    if actor_user_id:
        actor = Profile.objects.filter(user_id=actor_user_id).first()
    rows, skipped = build_event_rows(events or [], actor_profile=actor)
    if rows:
        AnalyticsEvent.objects.bulk_create(rows)
    return {'accepted': len(rows), 'skipped': skipped}


def server_event(event_name, *, actor=None, object_type='', object_id='', properties=None, surface=''):
    """Build one server-side event dict (for recommendation exposures etc.)."""
    return {
        'event_name': event_name,
        'occurred_at': timezone.now().isoformat(),
        'surface': surface,
        'object_type': object_type,
        'object_id': str(object_id or ''),
        'properties': properties or {},
        'consent': {'analytics': True},
    }
