"""Achievement evaluation engine.

Computes live metric values for a profile from existing platform data
(analytics tracking tables, feed posts, lives attendance, gyms) and
unlocks achievements whose threshold has been reached. Evaluation is
idempotent and cheap enough to run lazily on fetch as well as after
relevant events.
"""
import logging

from django.db.models import Sum
from django.db.models.functions import Coalesce
from django.db import models as db_models
from django.utils import timezone

from apps.analytics.models import ActivityRecord, WorkoutLog, MealLog, BodyMetric
from apps.feed.models import Post
from apps.lives.models import LiveAttendee

from .models import AchievementDefinition, UserAchievement

logger = logging.getLogger(__name__)


def period_start(period: str):
    """Start datetime for an achievement evaluation window."""
    import datetime
    now = timezone.now()
    today = now.date()
    return {
        'daily': datetime.datetime.combine(today, datetime.time.min, tzinfo=datetime.timezone.utc),
        'weekly': now - timezone.timedelta(days=today.weekday()),
        'monthly': datetime.datetime(today.year, today.month, 1, tzinfo=datetime.timezone.utc),
        'quarterly': datetime.datetime(
            today.year, ((today.month - 1) // 3) * 3 + 1, 1, tzinfo=datetime.timezone.utc),
        'yearly': datetime.datetime(today.year, 1, 1, tzinfo=datetime.timezone.utc),
    }.get(period)


def compute_metrics(profile, since=None) -> dict:
    """Return the full metrics dict for a profile.

    Every key here is a potential achievement ``metric``. When ``since`` is
    provided only activity at/after that instant counts (period windows);
    cumulative metrics like streak_days always read all-time.
    """
    def windowed(qs, ts_field):
        qs = qs.filter(**{f'{ts_field}__gte': since}) if since else qs
        return qs

    activities = windowed(ActivityRecord.objects.filter(user=profile), 'started_at')
    workouts = windowed(WorkoutLog.objects.filter(user=profile), 'performed_at')
    meals = windowed(MealLog.objects.filter(user=profile), 'created_at')

    total_distance_m = activities.aggregate(v=Coalesce(Sum('distance_meters'), 0.0))['v'] or 0.0
    total_duration_s = activities.aggregate(v=Coalesce(Sum('duration_seconds'), 0))['v'] or 0
    total_steps = activities.aggregate(v=Coalesce(Sum('steps'), 0))['v'] or 0

    return {
        'activities_total': activities.count(),
        'activities_distance_km': round(total_distance_m / 1000.0, 3),
        'activities_duration_hours': round(total_duration_s / 3600.0, 3),
        'activities_steps': int(total_steps),
        'workouts_logged': workouts.count(),
        'meals_logged': meals.count(),
        'body_metrics_logged': BodyMetric.objects.filter(user=profile).count(),
        'posts_created': windowed(Post.objects.filter(author=profile), 'created_at').count(),
        'lives_attended': LiveAttendee.objects.filter(user=profile).count(),
    }


METRIC_LABELS = {
    'activities_total': 'activities completed',
    'activities_distance_km': 'km tracked',
    'activities_duration_hours': 'hours active',
    'activities_steps': 'steps tracked',
    'workouts_logged': 'workouts logged',
    'meals_logged': 'meals logged',
    'body_metrics_logged': 'body check-ins',
    'posts_created': 'posts created',
    'lives_attended': 'lives attended',
}


def evaluate_profile(profile) -> list:
    """Evaluate all active definitions for a profile.

    Returns the list of newly earned UserAchievement instances. Existing
    earned achievements are never revoked or re-awarded.
    """
    metrics = compute_metrics(profile)
    definitions = AchievementDefinition.objects.filter(is_active=True)
    existing = {
        ua.definition_id: ua
        for ua in UserAchievement.objects.filter(profile=profile)
    }
    now = timezone.now()
    newly_earned = []

    # Cache one metrics dict per distinct evaluation window.
    metrics_cache = {'all_time': metrics}

    def metrics_for(definition):
        period = getattr(definition, 'period', 'all_time')
        if period == 'all_time':
            return metrics
        if period not in metrics_cache:
            metrics_cache[period] = compute_metrics(profile, since=period_start(period))
        return metrics_cache[period]

    for definition in definitions:
        value = float(metrics_for(definition).get(definition.metric, 0))
        current = existing.get(definition.id)

        if definition.threshold <= 0:
            continue

        if current is not None and current.earned_at:
            # Already unlocked — refresh progress only.
            if current.progress != value:
                current.progress = value
                current.save(update_fields=['progress'])
            continue

        if current is None:
            current = UserAchievement(profile=profile, definition=definition)

        current.progress = value
        if value >= definition.threshold:
            current.earned_at = now
            newly_earned.append(current)
        current.save()

    return newly_earned


def profile_achievement_payload(profile, period: str | None = None) -> dict:
    """Full payload for GET /achievements/: definitions + user state.

    ``period`` filters to one window ('daily'…'yearly'); None returns all.
    """
    from .serializers import AchievementDefinitionSerializer

    evaluate_profile(profile)

    definitions = AchievementDefinition.objects.filter(is_active=True)
    if period and period != 'all_time':
        definitions = definitions.filter(
            db_models.Q(period=period) | db_models.Q(period='all_time'),
        )
    user_map = {
        ua.definition_id: ua
        for ua in UserAchievement.objects.filter(profile=profile).select_related('definition')
    }

    items = []
    for d in definitions:
        ua = user_map.get(d.id)
        items.append({
            **AchievementDefinitionSerializer(d).data,
            'earned': bool(ua and ua.earned_at),
            'earned_at': ua.earned_at.isoformat() if (ua and ua.earned_at) else None,
            'progress': ua.progress if ua else 0,
            'progress_pct': min(
                100, round(100 * ((ua.progress if ua else 0) / d.threshold), 1),
            ) if d.threshold > 0 else 0,
        })

    earned_count = sum(1 for i in items if i['earned'])
    return {
        'items': items,
        'summary': {'total': len(items), 'earned': earned_count},
    }
