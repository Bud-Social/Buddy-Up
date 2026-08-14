"""Aggregation engine for the comprehensive user analytics feature.

Pulls from dedicated tracking models plus existing platform data
(feed workout/meal posts, live attendance, wallet transactions,
marketplace/session purchases) to produce per-category summaries and a
single comprehensive report payload.
"""
import json
import logging
from collections import Counter, defaultdict
from datetime import timedelta

from django.db.models import Sum, Avg, Count
from django.utils import timezone
from .models import ActivityRecord, WorkoutLog, MealLog, BodyMetric
from apps.feed.models import Post
from apps.lives.models import LiveAttendee
from apps.wallet.models import ArtifactTransaction

logger = logging.getLogger(__name__)


def _as_dict(value):
    """Coerce a JSONField value (dict or JSON-encoded string) into a dict."""
    if isinstance(value, str):
        try:
            parsed = json.loads(value)
            return parsed if isinstance(parsed, dict) else {}
        except (ValueError, TypeError):
            return {}
    return value if isinstance(value, dict) else {}


PERIOD_DAYS = {
    'week': 7,
    'month': 30,
    'quarter': 90,
    'year': 365,
    'all': None,
}


def json_safe(value):
    """Recursively convert datetimes/UUIDs to strings so summaries are JSON-safe."""
    if hasattr(value, 'isoformat') and not isinstance(value, (int, float)):
        return value.isoformat()
    if isinstance(value, (dict,)):
        return {k: json_safe(v) for k, v in value.items()}
    if isinstance(value, (list, tuple)):
        return [json_safe(v) for v in value]
    if isinstance(value, (int, float, str, bool)) or value is None:
        return value
    return str(value)


def period_cutoff(period):
    days = PERIOD_DAYS.get(period, 30)
    if days is None:
        return None
    return timezone.now() - timedelta(days=days)


def _period_filter(queryset, cutoff, field='created_at'):
    return queryset.filter(**{f'{field}__gte': cutoff}) if cutoff else queryset


def summarize_workouts(profile, cutoff):
    """Workouts from the dedicated tracker + legacy feed workout_log posts."""
    from_post = _period_filter(
        Post.objects.filter(author=profile, post_type='workout_log', workout_log_data__isnull=False),
        cutoff,
    )
    workout_count = _period_filter(WorkoutLog.objects.filter(user=profile), cutoff).count()
    total_count = workout_count + from_post.count()

    types = Counter()
    calories = 0.0
    for wl in WorkoutLog.objects.filter(user=profile) if not cutoff else WorkoutLog.objects.filter(user=profile, created_at__gte=cutoff):
        types[wl.get_workout_type_display()] += 1
        calories += (wl.calories_burned or 0)
    for p in from_post:
        data = _as_dict(p.workout_log_data)
        types[data.get('exercise', 'Workout')] += 1
        calories += (data.get('calories') or 0)

    volume = 0.0
    exercises = Counter()
    for wl in WorkoutLog.objects.filter(user=profile):
        if wl.sets and wl.reps and wl.weight_kg:
            volume += wl.sets * wl.reps * wl.weight_kg
        if wl.exercise:
            exercises[wl.exercise] += 1

    by_type = [{'label': k, 'count': v} for k, v in types.most_common()]

    recent = list(
        WorkoutLog.objects.filter(user=profile).order_by('-performed_at')[:10]
        .values('performed_at', 'workout_type', 'exercise', 'duration_minutes', 'calories_burned')
    )
    return {
        'count': total_count,
        'total_calories_burned': round(calories, 1),
        'total_volume': round(volume, 1),
        'by_type': by_type,
        'most_trained': exercises.most_common(1)[0][0] if exercises else None,
        'recent': recent,
    }


def summarize_activity(profile, cutoff):
    """Walking/running/hiking tracker summaries."""
    qs = ActivityRecord.objects.filter(user=profile)
    if cutoff:
        qs = qs.filter(started_at__gte=cutoff)

    total_distance = qs.aggregate(d=Sum('distance_meters'))['d'] or 0.0
    total_duration = qs.aggregate(d=Sum('duration_seconds'))['d'] or 0
    total_calories = qs.aggregate(c=Sum('calories_burned'))['c'] or 0.0
    total_steps = qs.aggregate(s=Sum('steps'))['s'] or 0

    by_type = list(
        qs.values('activity_type').annotate(
            count=Count('id'),
            distance=Sum('distance_meters'),
            duration=Sum('duration_seconds'),
        ).order_by('-distance')
    )
    for entry in by_type:
        entry['label'] = dict(ActivityRecord.ACTIVITY_TYPES).get(entry['activity_type'], entry['activity_type'])
        entry['distance_km'] = round((entry['distance'] or 0) / 1000, 2)

    recent = list(
        qs.order_by('-started_at')[:10].values(
            'id', 'activity_type', 'started_at', 'duration_seconds',
            'distance_meters', 'avg_pace', 'calories_burned', 'route',
        )
    )
    for entry in recent:
        entry['distance_km'] = round((entry['distance_meters'] or 0) / 1000, 2)

    avg_pace = qs.exclude(avg_pace__isnull=True).aggregate(a=Avg('avg_pace'))['a']
    return {
        'count': qs.count(),
        'total_distance_km': round(total_distance / 1000, 2),
        'total_duration_seconds': total_duration,
        'total_calories_burned': round(total_calories, 1),
        'total_steps': total_steps,
        'avg_pace': round(avg_pace, 1) if avg_pace else None,
        'by_type': by_type,
        'recent': recent,
    }


def summarize_nutrition(profile, cutoff):
    """Meal intake from the tracker + legacy feed meal posts."""
    from_post = _period_filter(
        Post.objects.filter(author=profile, post_type='meal', meal_data__isnull=False),
        cutoff,
    )
    qs = MealLog.objects.filter(user=profile)
    if cutoff:
        qs = qs.filter(logged_at__gte=cutoff)

    total_meals = qs.count() + from_post.count()
    total_calories = qs.aggregate(c=Sum('calories'))['c'] or 0.0
    total_protein = qs.aggregate(p=Sum('protein_g'))['p'] or 0.0
    total_carbs = qs.aggregate(c=Sum('carbs_g'))['c'] or 0.0
    total_fat = qs.aggregate(f=Sum('fat_g'))['f'] or 0.0

    for p in from_post:
        data = _as_dict(p.meal_data)
        total_calories += (data.get('calories') or 0)

    by_type = list(
        qs.values('meal_type').annotate(
            count=Count('id'),
            calories=Sum('calories'),
        ).order_by('-count')
    )
    for entry in by_type:
        entry['label'] = dict(MealLog.MEAL_TYPES).get(entry['meal_type'], entry['meal_type'])
        entry['calories'] = round(entry['calories'] or 0, 1)

    avg_daily = round(total_calories / 7, 1) if cutoff and cutoff > timezone.now() - timedelta(days=14) and total_meals else None

    recent = list(
        qs.order_by('-logged_at')[:10].values(
            'id', 'meal_type', 'food_name', 'description', 'calories',
            'protein_g', 'carbs_g', 'fat_g', 'photo_url', 'logged_at',
        )
    )
    return {
        'count': total_meals,
        'total_calories': round(total_calories, 1),
        'total_protein_g': round(total_protein, 1),
        'total_carbs_g': round(total_carbs, 1),
        'total_fat_g': round(total_fat, 1),
        'by_type': by_type,
        'avg_daily_calories': avg_daily,
        'recent': recent,
    }


def summarize_body(profile, cutoff=None):
    """Weight / body-composition progress."""
    metrics = BodyMetric.objects.filter(user=profile).order_by('measured_at')
    first = metrics.first()
    latest = metrics.last()

    series = list(metrics.values('id', 'weight_kg', 'body_fat_pct', 'measured_at', 'photo_url', 'scale_photo_url'))
    weight_change = round((latest.weight_kg - first.weight_kg), 1) if first and latest else None
    return {
        'count': metrics.count(),
        'start_weight_kg': first.weight_kg if first else None,
        'latest_weight_kg': latest.weight_kg if latest else None,
        'weight_change_kg': weight_change,
        'latest_body_fat_pct': latest.body_fat_pct if latest else None,
        'series': series,
    }


def summarize_lives(profile, cutoff):
    """Live sessions joined + time spent."""
    qs = LiveAttendee.objects.filter(user=profile, role='attendee')
    if cutoff:
        qs = qs.filter(joined_at__gte=cutoff)

    total_seconds = 0
    joined_count = qs.count()
    for attendee in qs:
        if attendee.left_at:
            total_seconds += max((attendee.left_at - attendee.joined_at).total_seconds(), 0)

    by_type = Counter()
    for attendee in qs.select_related('live'):
        if attendee.live:
            by_type[attendee.live.get_live_type_display()] += 1

    return {
        'joined_count': joined_count,
        'total_duration_seconds': total_seconds,
        'by_type': [{'label': k, 'count': v} for k, v in by_type.most_common()],
    }


def summarize_spending(profile, cutoff):
    """Wallet activity: gifting, programme/product purchases, live expenses."""
    qs = ArtifactTransaction.objects.filter(user=profile, status='completed')
    if cutoff:
        qs = qs.filter(created_at__gte=cutoff)

    category_quantities = defaultdict(int)
    category_counts = Counter()
    for t in qs:
        category_quantities[t.transaction_type] += t.quantity
        category_counts[t.transaction_type] += 1

    def _fmt(category):
        return {
            'category': category,
            'quantity': category_quantities[category],
            'count': category_counts[category],
            'label': dict(ArtifactTransaction.TRANSACTION_TYPES).get(category, category),
        }

    sent_categories = ('tip_sent', 'gift_sent', 'live_fee', 'session_fee', 'gym_subscription', 'marketplace')
    return {
        'gifts_sent': _fmt('gift_sent'),
        'gifts_received': _fmt('gift_received'),
        'tips_sent': _fmt('tip_sent'),
        'tips_received': _fmt('tip_received'),
        'live_fees': _fmt('live_fee'),
        'gym_subscriptions': _fmt('gym_subscription'),
        'session_fees': _fmt('session_fee'),
        'marketplace_spend': _fmt('marketplace'),
        'total_transactions': qs.count(),
        'total_artifacts_spent': sum(category_quantities[c] for c in sent_categories),
        'breakdown': [_fmt(c) for c, _ in category_counts.most_common()],
    }


def summarize_programmes(profile, cutoff):
    """Programme/product purchases + async progress."""
    from apps.marketplace.models import TrainingProgrammePurchase, MealPlanPurchase
    from apps.sessions.models import ProgrammeEnrollment

    programme_purchases = TrainingProgrammePurchase.objects.filter(buyer=profile)
    meal_plan_purchases = MealPlanPurchase.objects.filter(buyer=profile)
    if cutoff:
        programme_purchases = programme_purchases.filter(created_at__gte=cutoff)
        meal_plan_purchases = meal_plan_purchases.filter(created_at__gte=cutoff)

    enrolments = ProgrammeEnrollment.objects.filter(client=profile)
    progress_avg = enrolments.aggregate(a=Avg('progress_pct'))['a']
    return {
        'programmes_purchased': programme_purchases.count(),
        'meal_plans_purchased': meal_plan_purchases.count(),
        'active_enrolments': enrolments.filter(progress_pct__lt=100).count(),
        'completed_enrolments': enrolments.filter(progress_pct__gte=100).count(),
        'avg_progress_pct': round(progress_avg, 1) if progress_avg is not None else None,
    }


def build_summary(profile, period='all'):
    cutoff = period_cutoff(period)
    workouts = summarize_workouts(profile, cutoff)
    activity = summarize_activity(profile, cutoff)
    nutrition = summarize_nutrition(profile, cutoff)
    body = summarize_body(profile)
    lives = summarize_lives(profile, cutoff)
    spending = summarize_spending(profile, cutoff)
    programmes = summarize_programmes(profile, cutoff)

    return json_safe({
        'period': period,
        'user': {
            'username': profile.username,
            'display_name': profile.display_name,
            'avatar_url': profile.avatar_url,
            'streak_days': profile.streak_days,
        },
        'workouts': workouts,
        'activity': activity,
        'nutrition': nutrition,
        'body': body,
        'lives': lives,
        'spending': spending,
        'programmes': programmes,
    })


def _call_ai_service(endpoint: str, files: dict, timeout: int = 30):
    """POST an image to the AI microservice and return the JSON payload or None."""
    import requests
    from django.conf import settings

    url = f'{settings.AI_SERVICE_URL}{endpoint}'
    try:
        resp = requests.post(url, files=files, timeout=timeout)
        resp.raise_for_status()
        return resp.json()
    except Exception as exc:  # noqa: BLE001
        logger.warning('AI service call %s failed: %s', endpoint, exc)
        return None


def read_weight_from_photo(request, photo) -> dict | None:
    """Send a scale-display photo to the AI service and parse the weight."""
    data = _call_ai_service(
        '/api/v1/body/read-weight',
        files={'file': (photo.name, photo.read(), photo.content_type or 'image/jpeg')},
    )
    if data is None:
        return None
    from apps.ai.audit import audit_ai_call
    audit_ai_call('weight_read', input_data={'filename': photo.name}, output_data=data)
    return {
        'weight_kg': data.get('weight_kg'),
        'weight_lb': data.get('weight_lb'),
        'unit': data.get('unit', 'kg'),
        'confidence': data.get('confidence', 0.0),
        'method': data.get('method', ''),
    }


def analyze_meal_photo(request, photo) -> dict | None:
    """Send a meal photo to the AI service and extract nutrition details."""
    data = _call_ai_service(
        '/api/v1/food/recognize',
        files={'file': (photo.name, photo.read(), photo.content_type or 'image/jpeg')},
    )
    if data is None or not data.get('items'):
        return None
    from apps.ai.audit import audit_ai_call
    audit_ai_call('meal_analyze', input_data={'filename': photo.name}, output_data=data)

    top = data['items'][0]
    nutrition = top.get('nutrition', {}) or {}
    return {
        'food_name': top.get('item'),
        'calories': round(float(data.get('total_calories', nutrition.get('calories', 0) or 0)), 1),
        'protein_g': round(float(data.get('total_protein', nutrition.get('protein', 0) or 0)), 1),
        'carbs_g': round(float(data.get('total_carbs', nutrition.get('carbs', 0) or 0)), 1),
        'fat_g': round(float(data.get('total_fat', nutrition.get('fat', 0) or 0)), 1),
    }
