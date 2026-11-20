"""Countdown services.

The automatic countdowns advance from signals raised elsewhere in the app —
a logged walk, a gym check-in. Those callers use
:func:`advance_matching_countdowns` directly, so an advance happens as a
consequence of the user's activity rather than something they can poke.
"""

from __future__ import annotations

import logging
from datetime import time, timedelta

from django.db import transaction
from django.db.models import Max
from django.utils import timezone

from .models import UserCountdown

logger = logging.getLogger(__name__)

#: How far back the routine detector looks, and how many separate days of the
#: same activity count as a habit. Three different days is a pattern; three
#: sessions in one afternoon is not.
AUTO_ROUTINE_WINDOW_DAYS = 14
AUTO_ROUTINE_MIN_DAYS = 3

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


# ── Routine auto-detection ───────────────────────────────────────────────────
#
# A habit is the same activity on three separate days within a fortnight.
# When that happens the app offers a routine automatically instead of waiting
# for the user to build one by hand. Detection is strictly opt-out: it never
# touches an existing routine, never deletes anything, and never fails the
# activity that triggered it.

def _time_bucket(hour: int) -> str:
    if 5 <= hour < 12:
        return 'Morning'
    if 12 <= hour < 17:
        return 'Afternoon'
    if 17 <= hour < 22:
        return 'Evening'
    return 'Late'


def _next_sort_order(profile) -> int:
    from .models import Routine

    current = Routine.objects.filter(user=profile).aggregate(
        value=Max('sort_order'),
    )['value']
    return (current or 0) + 1


def _average(values: list[float]) -> float | None:
    usable = [value for value in values if value and value > 0]
    if not usable:
        return None
    return sum(usable) / len(usable)


def _build_auto_routine(profile, routine_type, local_times, *, distances=(), steps=(), durations=()):
    """Create the routine that the detected pattern implies."""
    from .models import Routine

    label = dict(Routine.ROUTINE_TYPES).get(routine_type, routine_type.title())
    minutes = [dt.hour * 60 + dt.minute for dt in local_times]
    avg_minutes = int(sum(minutes) / len(minutes))
    avg_minutes = round(avg_minutes / 15) * 15 % (24 * 60)
    at = time(avg_minutes // 60, avg_minutes % 60)

    if routine_type in ('walk',) and _average(list(steps)) is not None:
        target = max(500, round(_average(list(steps)) / 100) * 100)
        unit = 'steps'
    elif _average(list(distances)) is not None:
        target = max(1, round(_average(list(distances))))
        unit = 'km'
    else:
        target = max(5, round(_average(list(durations)) or 30))
        unit = 'min'

    days = sorted({dt.weekday() for dt in local_times})

    return Routine.objects.create(
        user=profile,
        type=routine_type,
        name=f'{_time_bucket(avg_minutes // 60)} {label}',
        target=target,
        unit=unit,
        days=days,
        time_of_day=at,
        activation='week',
        tracking='app',
        sort_order=_next_sort_order(profile),
        auto_generated=True,
    )


def maybe_create_activity_routine(activity):
    """Offer a routine when the user repeats the same activity.

    Returns the created routine, or ``None`` when there is no pattern (or the
    user opted out, or a routine for that activity already exists).
    """
    from apps.analytics.models import ActivityRecord
    from .models import Routine

    profile = activity.user
    if not getattr(profile, 'auto_routines_enabled', True):
        return None
    if Routine.objects.filter(
        user=profile, type=activity.activity_type, is_active=True,
    ).exists():
        return None

    since = timezone.now() - timedelta(days=AUTO_ROUTINE_WINDOW_DAYS)
    records = list(ActivityRecord.objects.filter(
        user=profile,
        activity_type=activity.activity_type,
        started_at__gte=since,
    ))
    local_times = [timezone.localtime(r.started_at) for r in records]
    if len({dt.date() for dt in local_times}) < AUTO_ROUTINE_MIN_DAYS:
        return None

    return _build_auto_routine(
        profile,
        activity.activity_type,
        local_times,
        distances=[(r.distance_meters or 0) / 1000 for r in records],
        steps=[r.steps or 0 for r in records],
        durations=[(r.duration_seconds or 0) / 60 for r in records],
    )


def maybe_create_workout_routine(log):
    """The strength-training equivalent: three logging days is a routine."""
    from apps.analytics.models import WorkoutLog
    from .models import Routine

    profile = log.user
    if not getattr(profile, 'auto_routines_enabled', True):
        return None
    if Routine.objects.filter(
        user=profile, type='workout', is_active=True,
    ).exists():
        return None

    since = timezone.now() - timedelta(days=AUTO_ROUTINE_WINDOW_DAYS)
    logs = list(WorkoutLog.objects.filter(
        user=profile,
        performed_at__gte=since,
    ))
    local_times = [timezone.localtime(log.performed_at) for log in logs if log.performed_at]
    if len({dt.date() for dt in local_times}) < AUTO_ROUTINE_MIN_DAYS:
        return None

    return _build_auto_routine(
        profile,
        'workout',
        local_times,
        durations=[log.duration_minutes or 0 for log in logs],
    )
