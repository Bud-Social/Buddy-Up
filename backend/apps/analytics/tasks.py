"""Scheduled analytics maintenance: daily rollups and event retention.

Two jobs, both daily, both idempotent, both safe to re-run by hand.

``rollup_daily_platform_metrics``
    Recomputes ``analytics.DailyPlatformMetric`` for a range of days. The writer
    is a full re-aggregate of each day (``update_or_create``, never an
    increment), so the task is convergent: running it twice produces the same
    numbers, a late-arriving row is picked up by the next run, and two workers
    racing produce the same value rather than a doubled one.

``purge_expired_analytics_events``
    Hard-deletes ``AnalyticsEvent`` rows past the retention window. Follows the
    pattern in ``apps.verification.tasks.purge_expired_verification_documents``:
    bounded batches ordered by the cutoff so the delete is index-friendly and a
    single run cannot hold a long lock on a hot table.

The retention window is a setting, not a constant, because it is a policy
decision (see ``ANALYTICS_EVENT_RETENTION_DAYS`` in config/settings/base.py).
"""
import datetime as dt
import logging

from celery import shared_task
from django.conf import settings
from django.utils import timezone

from . import platform_metrics as metrics

logger = logging.getLogger(__name__)

#: Default when the setting is absent (an old settings module, a fresh checkout).
DEFAULT_RETENTION_DAYS = 180
DEFAULT_PURGE_BATCH = 5000
DEFAULT_LOOKBACK_DAYS = 7


def retention_days():
    return int(getattr(settings, 'ANALYTICS_EVENT_RETENTION_DAYS', DEFAULT_RETENTION_DAYS))


@shared_task(name='apps.analytics.tasks.rollup_daily_platform_metrics')
def rollup_daily_platform_metrics(days=None, backfill=False, start=None):
    """Recompute daily platform metrics.

    Args:
        days: how many days back from today, inclusive of today (default
            ``ANALYTICS_ROLLUP_LOOKBACK_DAYS``, 7). Overlapping the window on
            every run is deliberate: it repairs a missed beat and picks up rows
            written late, without needing a separate "catch-up" code path.
        backfill: when True, walk from the earliest row of the source tables
            (bounded by ``ANALYTICS_MAX_RANGE_DAYS``) instead of ``days``. This
            is a one-off, expensive operation — it aggregates every day from the
            beginning — so it is opt-in and never part of the beat schedule.
        start: ISO date to begin a backfill from. Implies nothing on its own;
            combined with ``backfill`` it skips the earliest-row scan.

    Returns a counts dict. Never raises for a bad metric: a single failing spec
    is logged and the rest still run, because one broken metric must not stop
    the other nineteen from rolling up.
    """
    today = timezone.now().date()
    if backfill:
        first = (
            dt.date.fromisoformat(start) if start
            else _earliest_source_day() or (today - dt.timedelta(days=1))
        )
        last = today - dt.timedelta(days=1)  # today is partial; served live
        span = (last - first).days + 1
        cap = metrics.MAX_RANGE_DAYS
        if span > cap:
            first = last - dt.timedelta(days=cap - 1)
            logger.warning(
                'rollup_backfill_clamped from=%s span=%s cap=%s', first, span, cap,
            )
    else:
        lookback = int(days if days is not None else
                       getattr(settings, 'ANALYTICS_ROLLUP_LOOKBACK_DAYS',
                               DEFAULT_LOOKBACK_DAYS))
        last = today - dt.timedelta(days=1)
        first = last - dt.timedelta(days=max(0, lookback - 1))

    if last < first:
        return {'days': 0, 'rows': 0, 'metrics': 0, 'errors': {}}

    specs = [spec for spec in metrics.METRIC_SPECS.values() if spec.windowed]
    written = 0
    errors = {}
    day = first
    while day <= last:
        for spec in specs:
            try:
                metrics.write_daily_metric(spec, day)
                written += 1
            except Exception as exc:  # noqa: BLE001 — one metric never stops the rest
                errors[f'{spec.key}:{day.isoformat()}'] = str(exc)
                logger.exception('rollup_metric_failed metric=%s date=%s', spec.key, day)
        day += dt.timedelta(days=1)

    result = {
        'days': (last - first).days + 1,
        'from': first.isoformat(),
        'to': last.isoformat(),
        'rows': written,
        'metrics': len(specs),
        'errors': errors,
    }
    logger.info('platform_rollup_completed %s', result)
    return result


def _earliest_source_day():
    """The oldest date any rollable source table has a row for, or None."""
    from django.db.models import Min

    candidates = []
    for spec in metrics.METRIC_SPECS.values():
        if not spec.windowed or spec.aggregate == 'distinct':
            continue
        model = metrics._model_for(spec)
        field = metrics._date_expr(spec)
        try:
            value = model.objects.aggregate(first=Min(field))['first']
        except Exception:  # noqa: BLE001
            continue
        if value is not None:
            candidates.append(value.date())
    return min(candidates) if candidates else None


@shared_task(name='apps.analytics.tasks.purge_expired_analytics_events')
def purge_expired_analytics_events(limit=None, days=None):
    """Hard-delete behavioral events older than the retention window.

    Why it exists: ``AnalyticsEvent`` is the fastest-growing table in the
    platform — every client event lands here forever. Three beat entries
    (account sweep, OTP cleanup, session cleanup) never touched it. Behavioral
    events are *not* the durable record of anything: orders, posts, sessions and
    notifications all have their own tables, so deleting an event loses a
    ranking signal and nothing else.

    Ordering by ``occurred_at`` is only an optimisation: rows with a null
    ``occurred_at`` are ordered by ``received_at`` through a Coalesce, which
    keeps the delete on an indexed column rather than doing a full scan.

    GDPR: this is retention, not erasure. A user who exercises their right to
    erasure needs their events deleted regardless of age — that is
    ``apps.accounts``' job and currently does **not** cover AnalyticsEvent (see
    the report in the hand-off notes); this task only ages rows out.
    """
    from .models import AnalyticsEvent

    window_days = int(days if days is not None else retention_days())
    batch = int(limit if limit is not None else
                getattr(settings, 'ANALYTICS_EVENT_PURGE_BATCH', DEFAULT_PURGE_BATCH))
    cutoff = timezone.now() - dt.timedelta(days=window_days)
    old = AnalyticsEvent.objects.filter(
        received_at__lt=cutoff,
    ).order_by('received_at')[:batch]
    ids = list(old.values_list('id', flat=True))
    deleted = 0
    if ids:
        deleted, _ = AnalyticsEvent.objects.filter(id__in=ids).delete()
    logger.info(
        'analytics_event_purge cutoff=%s deleted=%s retention_days=%s',
        cutoff.isoformat(), deleted, window_days,
    )
    return {'deleted': deleted, 'cutoff': cutoff.isoformat(), 'retention_days': window_days}