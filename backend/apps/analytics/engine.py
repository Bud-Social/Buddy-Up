"""Aggregation engine for the comprehensive user analytics feature.

Pulls from dedicated tracking models plus existing platform data
(feed workout posts, live attendance, wallet transactions,
marketplace/session purchases) to produce per-category summaries and a
single comprehensive report payload.
"""
import json
import logging
from collections import Counter, defaultdict
from datetime import timedelta

from django.db.models import Sum, Avg, Count
from django.utils import timezone
from .models import ActivityRecord, WorkoutLog, BodyMetric
from apps.feed.models import Post
from apps.lives.models import LiveAttendee
from apps.wallet.models import ArtifactTransaction
from apps.ai.client import ai_post

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


def summarize_countdowns(profile, cutoff):
    """Countdown streaks, check-in cadence and the reset history.

    Reads the countdown event stream rather than the counters alone: a reset
    clears the counter but not the history, and the history is where the
    interesting numbers live — how long each streak lasted, how regularly
    the user checked in, and how many times they started over.
    """
    from apps.countdowns.models import CountdownEvent, UserCountdown

    countdowns = list(UserCountdown.objects.filter(user=profile))
    if not countdowns:
        return {
            'count': 0,
            'active_count': 0,
            'total_checkins': 0,
            'total_resets': 0,
            'total_completions': 0,
            'current_streak_units': 0,
            'longest_streak_units': 0,
            'total_streak_days': 0,
            'by_countdown': [],
            'recent_events': [],
            'resets': [],
            'cadence': {},
        }

    countdown_ids = [c.id for c in countdowns]
    events = list(
        CountdownEvent.objects.filter(countdown_id__in=countdown_ids)
        .order_by('-occurred_at')
    )
    if cutoff:
        events = [e for e in events if e.occurred_at >= cutoff]

    checkins = [e for e in events if e.event_type in ('checkin', 'auto_advance')]
    resets = [e for e in events if e.event_type == 'reset']
    completions = [e for e in events if e.event_type == 'complete']

    # ── Per countdown ────────────────────────────────────────────────────────
    by_countdown = []
    for c in countdowns:
        own = [e for e in events if e.countdown_id == c.id]
        own_checkins = [e for e in own if e.event_type in ('checkin', 'auto_advance')]
        own_resets = [e for e in own if e.event_type == 'reset']
        # The longest this countdown ever ran: the biggest run length seen
        # on the stream, plus the run that is still going.
        run_lengths = [e.run_elapsed_seconds for e in own] + [c.run_elapsed_seconds]
        longest = max(run_lengths) if run_lengths else 0
        unit_seconds = UserCountdown.UNIT_SECONDS.get(c.unit, UserCountdown.UNIT_SECONDS['days'])
        by_countdown.append({
            'id': str(c.id),
            'reason': c.display_reason,
            'icon': c.display_icon,
            'unit': c.unit,
            'countdown_type': c.countdown_type,
            'current_count': c.current_count,
            'target_count': c.target_count,
            'elapsed_units': c.elapsed_units,
            'longest_run_units': round(longest / unit_seconds, 1),
            'checkins': len(own_checkins),
            'resets': len(own_resets),
            'completed': bool(c.completed_at),
            'is_active': c.is_active,
            'last_event_at': own[0].occurred_at.isoformat() if own else None,
        })

    # ── Cadence: how regularly the user checks in ───────────────────────────
    gaps = sorted(e.elapsed_seconds for e in checkins if e.elapsed_seconds > 0)
    median_gap = gaps[len(gaps) // 2] if gaps else None
    on_time = 0
    for c in countdowns:
        unit_seconds = UserCountdown.UNIT_SECONDS.get(c.unit, UserCountdown.UNIT_SECONDS['days'])
        on_time += sum(1 for e in checkins if e.countdown_id == c.id and e.elapsed_seconds >= unit_seconds)

    # ── The resets ──────────────────────────────────────────────────────────
    resets_view = []
    for e in resets:
        countdown = next((c for c in countdowns if c.id == e.countdown_id), None)
        resets_view.append({
            'id': str(e.id),
            'countdown_id': str(e.countdown_id),
            'reason': countdown.display_reason if countdown else '',
            'occurred_at': e.occurred_at.isoformat(),
            'run_elapsed_seconds': e.run_elapsed_seconds,
            'run_elapsed_units': round(
                e.run_elapsed_seconds / UserCountdown.UNIT_SECONDS.get(
                    e.unit, UserCountdown.UNIT_SECONDS['days'],
                ), 1,
            ),
            'count_after': e.count_after,
        })

    recent_events = [{
        'id': str(e.id),
        'countdown_id': str(e.countdown_id),
        'event_type': e.event_type,
        'count_after': e.count_after,
        'elapsed_seconds': e.elapsed_seconds,
        'run_elapsed_seconds': e.run_elapsed_seconds,
        'unit': e.unit,
        'occurred_at': e.occurred_at.isoformat(),
    } for e in events[:50]]

    longest_run = max((b['longest_run_units'] for b in by_countdown), default=0)
    return {
        'count': len(countdowns),
        'active_count': sum(1 for c in countdowns if c.is_active and not c.completed_at),
        'total_checkins': len(checkins),
        'total_resets': len(resets),
        'total_completions': len(completions),
        'current_streak_units': sum(b['elapsed_units'] for b in by_countdown),
        'longest_streak_units': longest_run,
        'total_streak_days': round(longest_run, 1),
        'by_countdown': by_countdown,
        'recent_events': recent_events,
        'resets': resets_view[:50],
        'cadence': {
            'median_gap_seconds': median_gap,
            'on_time_checkins': on_time,
            'late_checkins': max(0, len(checkins) - on_time),
        },
    }


def summarize_activity(profile, cutoff):
    """Walking/running/hiking tracker summaries.

    More than a set of totals: the records, the trends and the shape of the
    sessions, so the analytics page can show how the week went and not just
    how much was done in total.
    """
    qs = ActivityRecord.objects.filter(user=profile)
    if cutoff:
        qs = qs.filter(started_at__gte=cutoff)

    total_distance = qs.aggregate(d=Sum('distance_meters'))['d'] or 0.0
    total_duration = qs.aggregate(d=Sum('duration_seconds'))['d'] or 0
    total_calories = qs.aggregate(c=Sum('calories_burned'))['c'] or 0.0
    total_steps = qs.aggregate(s=Sum('steps'))['s'] or 0
    total_climb = qs.aggregate(c=Sum('elevation_gain_m'))['c'] or 0.0

    by_type = list(
        qs.values('activity_type').annotate(
            count=Count('id'),
            distance=Sum('distance_meters'),
            duration=Sum('duration_seconds'),
            calories=Sum('calories_burned'),
        ).order_by('-distance')
    )
    for entry in by_type:
        entry['label'] = dict(ActivityRecord.ACTIVITY_TYPES).get(entry['activity_type'], entry['activity_type'])
        entry['distance_km'] = round((entry['distance'] or 0) / 1000, 2)
        entry['duration_minutes'] = round((entry['duration'] or 0) / 60, 1)

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
        'total_climb_m': round(total_climb, 1),
        'avg_pace': round(avg_pace, 1) if avg_pace else None,
        'by_type': by_type,
        'recent': recent,
        **_activity_detail(profile, cutoff),
    }


#: The distance bands a session is counted into, for the distribution chart.
DISTANCE_BANDS = [
    (1000, 'Under 1 km'),
    (3000, '1–3 km'),
    (5000, '3–5 km'),
    (10000, '5–10 km'),
    (21097, '10–21 km'),
    (42195, 'Half marathon'),
    (float('inf'), 'Beyond'),
]


def _activity_detail(profile, cutoff):
    """The records, trends and shape of a user's activity."""
    qs = ActivityRecord.objects.filter(user=profile)
    if cutoff:
        qs = qs.filter(started_at__gte=cutoff)

    rows = list(qs.values(
        'id', 'activity_type', 'started_at', 'duration_seconds',
        'distance_meters', 'avg_pace', 'avg_speed_kmh', 'calories_burned',
        'steps', 'elevation_gain_m', 'route',
    ))

    # ── Records ─────────────────────────────────────────────────────────────
    records = {
        'longest_distance_km': 0,
        'longest_distance_id': None,
        'longest_duration_seconds': 0,
        'longest_duration_id': None,
        'fastest_pace': None,
        'fastest_pace_id': None,
        'biggest_climb_m': 0,
        'biggest_climb_id': None,
        'most_steps': 0,
        'most_steps_id': None,
    }
    for row in rows:
        km = (row['distance_meters'] or 0) / 1000
        if km > records['longest_distance_km']:
            records['longest_distance_km'] = round(km, 2)
            records['longest_distance_id'] = row['id']
        if (row['duration_seconds'] or 0) > records['longest_duration_seconds']:
            records['longest_duration_seconds'] = row['duration_seconds']
            records['longest_duration_id'] = row['id']
        pace = row['avg_pace']
        if pace and (records['fastest_pace'] is None or pace < records['fastest_pace']):
            records['fastest_pace'] = round(pace, 1)
            records['fastest_pace_id'] = row['id']
        if (row['elevation_gain_m'] or 0) > records['biggest_climb_m']:
            records['biggest_climb_m'] = round(row['elevation_gain_m'], 1)
            records['biggest_climb_id'] = row['id']
        if (row['steps'] or 0) > records['most_steps']:
            records['most_steps'] = row['steps']
            records['most_steps_id'] = row['id']

    # ── Weekly trend ─────────────────────────────────────────────────────────
    weeks = defaultdict(lambda: {'count': 0, 'distance': 0.0, 'duration': 0, 'pace_weighted': 0.0, 'pace_weight': 0})
    days = defaultdict(int)
    for row in rows:
        started = row['started_at']
        if not started:
            continue
        week = started.strftime('%G-W%V')
        bucket = weeks[week]
        bucket['count'] += 1
        bucket['distance'] += (row['distance_meters'] or 0) / 1000
        bucket['duration'] += (row['duration_seconds'] or 0) / 60
        if row['avg_pace']:
            # Weighted by distance, so a short fast run does not outvote a
            # long slow one.
            weight = max((row['distance_meters'] or 0) / 1000, 0.1)
            bucket['pace_weighted'] += row['avg_pace'] * weight
            bucket['pace_weight'] += weight
        days[started.date().isoformat()] += 1

    weekly = []
    for week in sorted(weeks):
        bucket = weeks[week]
        weekly.append({
            'week': week,
            'count': bucket['count'],
            'distance_km': round(bucket['distance'], 2),
            'duration_minutes': round(bucket['duration'], 1),
            'avg_pace': round(bucket['pace_weighted'] / bucket['pace_weight'], 1) if bucket['pace_weight'] else None,
        })

    # ── Distribution by distance ─────────────────────────────────────────────
    distribution = [{'band': label, 'count': 0} for _, label in DISTANCE_BANDS]
    for row in rows:
        metres = row['distance_meters'] or 0
        for index, (limit, label) in enumerate(DISTANCE_BANDS):
            if metres < limit:
                distribution[index]['count'] += 1
                break

    # ── The sessions worth showing with their routes ─────────────────────────
    gallery = [
        {
            'id': row['id'],
            'activity_type': row['activity_type'],
            'started_at': row['started_at'].isoformat() if row['started_at'] else None,
            'distance_km': round((row['distance_meters'] or 0) / 1000, 2),
            'duration_minutes': round((row['duration_seconds'] or 0) / 60, 1),
            'route_points': len(row['route'] or []),
            'route': (row['route'] or [])[:400],
        }
        for row in sorted(
            rows,
            key=lambda r: r['distance_meters'] or 0,
            reverse=True,
        )[:8] if row['route']
    ]

    # ── Goals ────────────────────────────────────────────────────────────────
    goals = _activity_goals(profile, cutoff, rows)

    return {
        'records': records,
        'weekly': weekly,
        'distribution': distribution,
        'calendar': [{'date': day, 'count': count} for day, count in sorted(days.items())],
        'days_active': len(days),
        'gallery': gallery,
        'goals': goals,
    }


#: The daily target for each kind of activity.
ACTIVITY_GOALS = {
    'walk': {'value': 5000, 'unit': 'steps'},
    'run': {'value': 2, 'unit': 'km'},
    'hike': {'value': 5, 'unit': 'km'},
    'cycle': {'value': 10, 'unit': 'km'},
}


def _activity_goals(profile, cutoff, rows):
    """How the user is doing against each kind's daily goal."""
    goals = []
    for kind, goal in ACTIVITY_GOALS.items():
        kind_rows = [r for r in rows if r['activity_type'] == kind]
        if not kind_rows:
            continue
        if goal['unit'] == 'steps':
            reached = sum(r['steps'] or 0 for r in kind_rows)
        else:
            reached = sum((r['distance_meters'] or 0) / 1000 for r in kind_rows)
        goals.append({
            'activity_type': kind,
            'label': dict(ActivityRecord.ACTIVITY_TYPES).get(kind, kind),
            'target': goal['value'],
            'unit': goal['unit'],
            'reached': round(reached, 2),
            'sessions': len(kind_rows),
            'pct': min(100, round(reached / goal['value'] * 100)) if goal['value'] else 0,
        })
    return goals


def summarize_body(profile, cutoff=None):
    """Weight / body-composition progress from tracked body metrics."""
    metrics = BodyMetric.objects.filter(user=profile).order_by('measured_at')
    first = metrics.first()
    latest = metrics.last()

    series = list(metrics.values('id', 'weight_kg', 'body_fat_pct', 'measured_at', 'photo_url', 'scale_photo_url'))
    series.sort(key=lambda s: s['measured_at'])

    weighted = [s for s in series if s.get('weight_kg')]
    first = weighted[0] if weighted else first
    latest = weighted[-1] if weighted else latest

    weight_change = round((latest['weight_kg'] - first['weight_kg']), 1) if first and latest else None
    return {
        'count': metrics.count(),
        'start_weight_kg': (first or {}).get('weight_kg'),
        'latest_weight_kg': (latest or {}).get('weight_kg'),
        'weight_change_kg': weight_change,
        'latest_body_fat_pct': (latest or {}).get('body_fat_pct'),
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


def summarize_nutrition(profile, cutoff):
    """Nutrition log totals.

    The MealLog model was deliberately removed (migration 0005) along with
    the meals achievements, so there is no per-meal data to aggregate. The
    key is still returned — with honest zeros — because the web Overview /
    Report tabs and Flutter read ``summary.nutrition`` unconditionally, and
    a missing key crashes them. When meal logging returns, aggregate here.
    """
    return {
        'count': 0,
        'total_calories': 0,
        'total_protein_g': 0,
        'total_carbs_g': 0,
        'total_fat_g': 0,
        'by_type': [],
        'avg_daily_calories': None,
        'recent': [],
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


def summarize_routines(profile, cutoff):
    """Routine categories, cadence and which routines are actually running.

    ``RoutineCheckIn`` is the completion record for both in-app and manual
    routines, so the same numbers cover off-app habits.
    """
    from apps.countdowns.models import Routine, RoutineCheckIn

    routines = list(Routine.objects.filter(user=profile, is_active=True))
    checkins = RoutineCheckIn.objects.filter(routine__user=profile)
    if cutoff:
        checkins = checkins.filter(occurred_at__gte=cutoff)

    by_category = Counter()
    by_tracking = Counter()
    for row in checkins.values('routine__type', 'routine__tracking').annotate(count=Count('id')):
        by_category[row['routine__type']] += row['count']
        by_tracking[row['routine__tracking']] += row['count']

    labels = dict(Routine.ROUTINE_TYPES)
    return {
        'active_routines': len(routines),
        'total_checkins': checkins.count(),
        'by_category': [
            {'category': key, 'label': labels.get(key, key), 'count': by_category[key]}
            for key in labels if by_category.get(key)
        ],
        'by_tracking': [
            {'tracking': key, 'count': by_tracking[key]}
            for key in ('app', 'manual') if by_tracking.get(key)
        ],
    }


def build_summary(profile, period='all'):
    cutoff = period_cutoff(period)
    workouts = summarize_workouts(profile, cutoff)
    activity = summarize_activity(profile, cutoff)
    countdowns = summarize_countdowns(profile, cutoff)
    body = summarize_body(profile)
    lives = summarize_lives(profile, cutoff)
    spending = summarize_spending(profile, cutoff)
    programmes = summarize_programmes(profile, cutoff)
    nutrition = summarize_nutrition(profile, cutoff)
    routines = summarize_routines(profile, cutoff)

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
        'countdowns': countdowns,
        'body': body,
        'lives': lives,
        'spending': spending,
        'programmes': programmes,
        'nutrition': nutrition,
        'routines': routines,
    })


def _call_ai_service(endpoint: str, files: dict, timeout: int = 30):
    """POST an image to the AI microservice and return the JSON payload or None."""
    from django.conf import settings

    url = f'{settings.AI_SERVICE_URL}{endpoint}'
    try:
        resp = ai_post(url, files=files, timeout=timeout)
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
    audit_ai_call('weight_read', input_data={'filename': photo.name}, output_data=data,
                  metadata={k: data.get(k) for k in ('confidence', 'correction', 'fallback_used', 'fallback_reason', 'cost_usd', 'latency_ms')})
    return {
        'weight_kg': data.get('weight_kg'),
        'weight_lb': data.get('weight_lb'),
        'unit': data.get('unit', 'kg'),
        'confidence': data.get('confidence', 0.0),
        'method': data.get('method', ''),
        'safety_notice': 'AI output is informational only, not medical advice.',
    }
