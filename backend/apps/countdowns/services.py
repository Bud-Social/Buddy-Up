"""Countdown services.

The automatic countdowns advance from signals raised elsewhere in the app —
a logged walk, a gym check-in. Those callers use
:func:`advance_matching_countdowns` directly, so an advance happens as a
consequence of the user's activity rather than something they can poke.
"""

from __future__ import annotations

import logging

from django.db import transaction

from .models import UserCountdown

logger = logging.getLogger(__name__)

#: Signals the app raises. The frontend offers these when an automatic
#: countdown is created.
KNOWN_SIGNALS = (
    'activity_walk',
    'activity_run',
    'activity_cycle',
    'activity_hike',
    'gym_checkin',
    'workout_logged',
)


def advance_matching_countdowns(profile, signal: str, amount: int = 1) -> list[str]:
    """Advance every automatic countdown of ``profile`` bound to ``signal``.

    Returns the ids of the countdowns that moved. A countdown that has
    reached its target stops advancing — its completion is already recorded.
    """
    if not signal:
        return []

    qs = UserCountdown.objects.filter(
        user=profile,
        is_active=True,
        countdown_type='automatic',
        auto_advance_signal=signal,
    ).select_related('template')

    advanced: list[str] = []
    with transaction.atomic():
        for obj in qs:
            try:
                obj.advance(amount=amount, signal=signal)
            except Exception:  # noqa: BLE001 — one bad countdown must not stop the rest
                logger.warning('could not advance countdown %s for %s', obj.id, signal, exc_info=True)
                continue
            advanced.append(str(obj.id))
    return advanced
