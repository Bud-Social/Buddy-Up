import logging

logger = logging.getLogger(__name__)

GOAL_TRAINER_MAP = {
    'weight_loss': ['nutrition', 'cardio', 'hiit'],
    'muscle_gain': ['strength_training', 'bodybuilding', 'powerlifting'],
    'endurance': ['running', 'cycling', 'swimming'],
    'flexibility': ['yoga', 'pilates', 'stretching'],
    'general_wellness': ['holistic_fitness', 'yoga', 'walking'],
    'nutrition': ['nutrition', 'dietetics', 'meal_planning'],
    'sports_performance': ['sports_specific', 'agility', 'strength_and_conditioning'],
    'rehabilitation': ['physical_therapy', 'corrective_exercise', 'rehab'],
    'mental_health': ['yoga', 'meditation', 'mindfulness'],
}

GOAL_GYM_CATEGORY_MAP = {
    'weight_loss': ['Cardio', 'HIIT', 'Circuit Training'],
    'muscle_gain': ['Strength', 'Powerlifting', 'Bodybuilding'],
    'endurance': ['Cardio', 'Running', 'Cycling'],
    'flexibility': ['Yoga', 'Pilates', 'Dance'],
    'general_wellness': ['General Fitness', 'Yoga', 'Swimming'],
    'nutrition': ['Wellness', 'Holistic Health'],
    'sports_performance': ['Sports Performance', 'Athletic Training'],
    'rehabilitation': ['Physical Therapy', 'Rehab'],
    'mental_health': ['Yoga', 'Meditation', 'Wellness'],
}

WORKOUT_PLAN_TEMPLATES = {
    'weight_loss': {
        'frequency': '4-5 days/week',
        'focus': 'Circuit training + steady state cardio',
        'sample_split': ['Full Body Circuit', 'HIIT Cardio', 'Active Recovery', 'Full Body Circuit', 'LISS Cardio'],
    },
    'muscle_gain': {
        'frequency': '4-5 days/week',
        'focus': 'Progressive overload on compound lifts',
        'sample_split': ['Chest/Triceps', 'Back/Biceps', 'Legs', 'Shoulders/Abs', 'Full Body'],
    },
    'endurance': {
        'frequency': '5-6 days/week',
        'focus': 'Zone 2 base building + interval work',
        'sample_split': ['Long Slow Run', 'Tempo Run', 'Cross Train', 'Intervals', 'Long Slow Run', 'Recovery'],
    },
    'flexibility': {
        'frequency': '5-6 days/week',
        'focus': 'Dynamic stretching + mobility drills',
        'sample_split': ['Full Body Flow', 'Upper Body Focus', 'Lower Body Focus', 'Full Body Flow', 'Restorative'],
    },
    'general_wellness': {
        'frequency': '3-4 days/week',
        'focus': 'Mixed modalities for overall health',
        'sample_split': ['Strength', 'Cardio', 'Yoga/Stretch', 'Active Recreation'],
    },
    'sports_performance': {
        'frequency': '5-6 days/week',
        'focus': 'Sport-specific drills + S&C',
        'sample_split': ['Sport Skills', 'Strength', 'Agility/Plyos', 'Sport Skills', 'Strength', 'Recovery'],
    },
    'rehabilitation': {
        'frequency': '3-4 days/week',
        'focus': 'Corrective exercises + gradual loading',
        'sample_split': ['Mobility/Flexibility', 'Stabilization', 'Strength Foundation', 'Active Recovery'],
    },
    'mental_health': {
        'frequency': '3-5 days/week',
        'focus': 'Mind-body connection + stress reduction',
        'sample_split': ['Yoga Flow', 'Walking/Hiking', 'Meditation + Stretch', 'Dance/Cardio', 'Restorative Yoga'],
    },
}

ACTIVITY_LEVEL_ADJUSTMENT = {
    'sedentary': 'Start with 2-3 low-impact sessions per week. Focus on building consistency.',
    'lightly_active': 'Progress to 3-4 sessions per week. Gradually increase intensity.',
    'moderately_active': 'Maintain 4-5 sessions per week. Introduce periodization.',
    'very_active': 'Optimize with 5-6 sessions per week. Focus on recovery and periodization.',
    'athlete': 'Advanced programming with 6+ sessions. Sport-specific periodization.',
}

TIME_MAP = {
    'early_memory': 'Morning workouts suit fat burning and consistency.',
    'morning': 'Morning workouts boost metabolism and mood for the day.',
    'afternoon': 'Afternoon is ideal for peak strength and performance.',
    'evening': 'Evening workouts can relieve stress and improve sleep.',
    'night': 'Late workouts are fine if they don't disrupt sleep quality.',
    'flexible': 'Varying workout times keeps your body adapting.',
}


def generate_onboarding_plan(preferences: dict) -> dict:
    goals = preferences.get('primary_goal', [])
    activity = preferences.get('activity_level', 'moderately_active')
    workouts = preferences.get('preferred_workouts', [])
    diet = preferences.get('dietary_preference', 'none')
    pref_time = preferences.get('preferred_time', 'flexible')

    primary_goal = goals[0] if goals else 'general_wellness'

    trainer_specialties = set()
    gym_categories = set()
    for g in goals:
        trainer_specialties.update(GOAL_TRAINER_MAP.get(g, []))
        gym_categories.update(GOAL_GYM_CATEGORY_MAP.get(g, []))

    plan_template = WORKOUT_PLAN_TEMPLATES.get(primary_goal, WORKOUT_PLAN_TEMPLATES['general_wellness'])
    activity_advice = ACTIVITY_LEVEL_ADJUSTMENT.get(activity, ACTIVITY_LEVEL_ADJUSTMENT['moderately_active'])
    time_advice = TIME_MAP.get(pref_time, TIME_MAP['flexible'])

    buddy_match_reason = _buddy_match_reason(goals, workouts)
    meal_plan_recommendation = _meal_plan_recommendation(goals, diet)

    return {
        'primary_goal': primary_goal,
        'recommended_trainer_specialties': sorted(trainer_specialties),
        'recommended_gym_categories': sorted(gym_categories),
        'suggested_workout_plan': {
            'frequency': plan_template['frequency'],
            'focus': plan_template['focus'],
            'sample_split': plan_template['sample_split'],
        },
        'activity_level_advice': activity_advice,
        'time_preference_advice': time_advice,
        'buddy_matching_hint': buddy_match_reason,
        'meal_plan_recommendation': meal_plan_recommendation,
        'recommended_dietary_tags': _dietary_tags(goals, diet),
    }


def _buddy_match_reason(goals: list[str], workouts: list[str]) -> str:
    if not goals and not workouts:
        return 'Find buddies with similar availability and location.'
    goal_str = ' and '.join(goals[:2]) if goals else 'fitness'
    workout_str = ' and '.join(workouts[:2]) if workouts else 'various'
    return f'Look for buddies who share your {goal_str} goals and enjoy {workout_str}.'


def _meal_plan_recommendation(goals: list[str], diet: str) -> str:
    diet_map = {
        'vegan': 'Explore plant-based high-protein meal plans.',
        'vegetarian': 'Vegetarian meal plans with complete protein sources.',
        'keto': 'Keto-friendly high-fat meal plans.',
        'paleo': 'Whole-food paleo meal plans.',
        'halal': 'Halal-certified meal plans.',
        'kosher': 'Kosher meal plans.',
        'gluten_free': 'Gluten-free meal plans.',
        'none': None,
    }
    if diet in diet_map and diet_map[diet]:
        return diet_map[diet]
    if 'weight_loss' in goals:
        return 'Calorie-conscious meal plans with macro tracking.'
    if 'muscle_gain' in goals:
        return 'High-protein muscle-building meal plans.'
    if 'nutrition' in goals:
        return 'Balanced nutrient-dense meal plans.'
    return 'Explore meal plans aligned with your dietary preference.'


def _dietary_tags(goals: list[str], diet: str) -> list[str]:
    tags = []
    if diet and diet != 'none':
        tags.append(diet.replace('_', ' ').title())
    if 'weight_loss' in goals:
        tags.append('Low Calorie')
    if 'muscle_gain' in goals:
        tags.append('High Protein')
    if 'nutrition' in goals:
        tags.append('Nutrient Dense')
    return tags
