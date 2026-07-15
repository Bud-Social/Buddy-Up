import logging
from datetime import datetime, timedelta
from typing import Any

logger = logging.getLogger(__name__)

ACHIEVEMENTS = [
    {'id': 'first_workout', 'label': 'First Workout', 'icon': '🏋️', 'condition': 'workouts>=1'},
    {'id': 'week_streak', 'label': 'Week Warrior', 'icon': '🔥', 'condition': 'streak>=7'},
    {'id': 'month_streak', 'label': 'Monthly Dedication', 'icon': '💪', 'condition': 'streak>=30'},
    {'id': 'volume_1000', 'label': 'Lifting Off', 'icon': '🏋️', 'condition': 'total_volume>=1000'},
    {'id': 'volume_10000', 'label': 'Heavy Lifter', 'icon': '🦍', 'condition': 'total_volume>=10000'},
    {'id': 'workouts_10', 'label': 'Getting Started', 'icon': '📈', 'condition': 'workouts>=10'},
    {'id': 'workouts_50', 'label': 'Regular', 'icon': '⭐', 'condition': 'workouts>=50'},
    {'id': 'workouts_100', 'label': 'Century Club', 'icon': '🏆', 'condition': 'workouts>=100'},
    {'id': 'exercises_5', 'label': 'Variety Seeker', 'icon': '🎯', 'condition': 'unique_exercises>=5'},
    {'id': 'exercises_15', 'label': 'Exercise Explorer', 'icon': '🧭', 'condition': 'unique_exercises>=15'},
]


def analyze_health_insights(data: dict) -> dict:
    workouts = data.get('workouts', [])
    meals = data.get('meals', [])
    streak_data = data.get('streak', {})
    period = data.get('period', 'weekly')
    now = datetime.utcnow()

    workout_summary = _summarize_workouts(workouts, period)
    streak_summary = _summarize_streak(streak_data)
    meal_summary = _summarize_meals(meals, period)
    achievements = _check_achievements(workout_summary, streak_summary)
    narrative = _generate_narrative(period, workout_summary, streak_summary, meal_summary, achievements)

    return {
        'period': period,
        'generated_at': now.isoformat(),
        'workout_summary': workout_summary,
        'streak_summary': streak_summary,
        'meal_summary': meal_summary,
        'achievements': achievements,
        'narrative': narrative,
    }


def _summarize_workouts(workouts: list[dict], period: str) -> dict:
    total_workouts = len(workouts)
    total_volume = 0
    unique_exercises = set()
    per_exercise: dict[str, dict] = {}

    for w in workouts:
        log = w.get('workout_log_data', {}) if isinstance(w, dict) else w
        if isinstance(log, dict):
            exercise = log.get('exercise', 'Unknown')
            sets = log.get('sets', 1)
            reps = log.get('reps', 1)
            weight = log.get('weight', 0)
            volume = sets * reps * weight
            total_volume += volume
            unique_exercises.add(exercise)
            if exercise not in per_exercise:
                per_exercise[exercise] = {'count': 0, 'total_volume': 0}
            per_exercise[exercise]['count'] += 1
            per_exercise[exercise]['total_volume'] += volume

    most_trained = max(per_exercise.items(), key=lambda x: x[1]['count']) if per_exercise else (None, None)
    highest_volume = max(per_exercise.items(), key=lambda x: x[1]['total_volume']) if per_exercise else (None, None)

    return {
        'total_workouts': total_workouts,
        'total_volume': total_volume,
        'unique_exercises': len(unique_exercises),
        'exercise_names': sorted(unique_exercises),
        'most_trained_exercise': most_trained[0] if most_trained[0] else None,
        'most_trained_count': most_trained[1]['count'] if most_trained[1] else 0,
        'highest_volume_exercise': highest_volume[0] if highest_volume[0] else None,
        'highest_volume_amount': highest_volume[1]['total_volume'] if highest_volume[1] else 0,
    }


def _summarize_streak(streak: dict) -> dict:
    days = streak.get('days', 0)
    longest = streak.get('longest_streak', days)
    return {
        'current_streak': days,
        'longest_streak': max(days, longest),
        'is_active': days > 0,
    }


def _summarize_meals(meals: list[dict], period: str) -> dict:
    total_meals = len(meals)
    total_calories = 0
    meal_types = set()

    for m in meals:
        log = m.get('meal_data', {}) if isinstance(m, dict) else m
        if isinstance(log, dict):
            if log.get('calories'):
                total_calories += log['calories']
            if log.get('meal_type'):
                meal_types.add(log['meal_type'])

    return {
        'total_meals_logged': total_meals,
        'total_calories_estimated': total_calories,
        'unique_meal_types': sorted(meal_types),
    }


def _check_achievements(workout: dict, streak: dict) -> list[dict]:
    unlocked = []
    total_volume = workout.get('total_volume', 0)
    total_workouts = workout.get('total_workouts', 0)
    unique_exercises = workout.get('unique_exercises', 0)
    current_streak = streak.get('current_streak', 0)

    checks = {
        'workouts': total_workouts,
        'streak': current_streak,
        'total_volume': total_volume,
        'unique_exercises': unique_exercises,
    }

    candidates = [
        ('first_workout', 'workouts>=1'),
        ('week_streak', 'streak>=7'),
        ('month_streak', 'streak>=30'),
        ('volume_1000', 'total_volume>=1000'),
        ('volume_10000', 'total_volume>=10000'),
        ('workouts_10', 'workouts>=10'),
        ('workouts_50', 'workouts>=50'),
        ('workouts_100', 'workouts>=100'),
        ('exercises_5', 'unique_exercises>=5'),
        ('exercises_15', 'unique_exercises>=15'),
    ]

    for ach in ACHIEVEMENTS:
        for cid, cond_str in candidates:
            if ach['id'] == cid:
                key = cond_str.split('>=')[0]
                val = int(cond_str.split('>=')[1])
                if checks.get(key, 0) >= val:
                    unlocked.append(ach)
                break

    return unlocked


def _generate_narrative(
    period: str,
    workout: dict,
    streak: dict,
    meals: dict,
    achievements: list[dict],
) -> str:
    parts = []
    period_label = 'this week' if period == 'weekly' else 'this month'

    w = workout.get('total_workouts', 0)
    if w == 0:
        return f'No workout data recorded {period_label}. Start logging to get insights!'

    parts.append(f'You completed {w} workout(s) {period_label}')

    vol = workout.get('total_volume', 0)
    if vol > 0:
        parts.append(f'with a total volume of {vol:,.0f} kg')

    top_ex = workout.get('most_trained_exercise')
    if top_ex:
        count = workout.get('most_trained_count', 0)
        parts.append(f'Your most frequent exercise was {top_ex} ({count} session(s))')

    streak_days = streak.get('current_streak', 0)
    if streak_days >= 7:
        parts.append(f'🔥 You\'re on a {streak_days}-day streak — keep it going!')
    elif streak_days >= 3:
        parts.append(f'You\'re building momentum with a {streak_days}-day streak')
    elif streak_days > 0:
        parts.append(f'Current streak: {streak_days} day(s)')

    meal_count = meals.get('total_meals_logged', 0)
    if meal_count > 0:
        cals = meals.get('total_calories_estimated', 0)
        parts.append(f'{meal_count} meal(s) logged averaging {cals // max(meal_count, 1):,} cal each')

    if achievements:
        ach_strs = [f'{a["icon"]} {a["label"]}' for a in achievements[:3]]
        parts.append(f'Achievements: {", ".join(ach_strs)}')

    return '. '.join(parts) + '.'
