from django.db import migrations

SEED = [
    # (code, title, description, icon, tier, category, metric, threshold)
    ('first_activity', 'First Steps', 'Complete your first tracked activity.', '👣', 'bronze', 'activity', 'activities_total', 1),
    ('activities_10', 'Getting Moving', 'Complete 10 tracked activities.', '🚶', 'bronze', 'activity', 'activities_total', 10),
    ('activities_50', 'Road Warrior', 'Complete 50 tracked activities.', '🏃', 'silver', 'activity', 'activities_total', 50),
    ('activities_100', 'Centurion', 'Complete 100 tracked activities.', '🏅', 'gold', 'activity', 'activities_total', 100),
    ('distance_10km', 'Double Digits', 'Track 10 km of movement in total.', '📏', 'bronze', 'activity', 'activities_distance_km', 10),
    ('distance_42km', 'Marathon Distance', 'Track a marathon\'s worth of distance (42 km).', '🥇', 'gold', 'activity', 'activities_distance_km', 42),
    ('distance_100km', 'Century Rider', 'Track 100 km of movement in total.', '💯', 'platinum', 'activity', 'activities_distance_km', 100),
    ('hours_10', 'Time on Feet', 'Accumulate 10 hours of tracked activity.', '⏱️', 'silver', 'consistency', 'activities_duration_hours', 10),
    ('steps_100k', 'Step Machine', 'Record 100,000 steps across tracked activities.', '👟', 'gold', 'activity', 'activities_steps', 100000),
    ('workouts_5', 'Iron Habit', 'Log 5 structured workouts.', '🏋️', 'bronze', 'activity', 'workouts_logged', 5),
    ('workouts_25', 'Gym Regular', 'Log 25 structured workouts.', '💪', 'silver', 'activity', 'workouts_logged', 25),
    ('meals_10', 'Clean Eater', 'Log 10 meals.', '🥗', 'bronze', 'nutrition', 'meals_logged', 10),
    ('body_checkins_5', 'Know Your Numbers', 'Record 5 body metric check-ins.', '⚖️', 'bronze', 'nutrition', 'body_metrics_logged', 5),
    ('posts_1', 'Hello World', 'Share your first post.', '👋', 'bronze', 'social', 'posts_created', 1),
    ('posts_25', 'Community Voice', 'Create 25 posts.', '📣', 'silver', 'social', 'posts_created', 25),
    ('lives_1', 'Front Row', 'Attend your first live session.', '🎟️', 'bronze', 'live', 'lives_attended', 1),
    ('lives_10', 'Live Regular', 'Attend 10 live sessions.', '🔥', 'silver', 'live', 'lives_attended', 10),
]


def seed_definitions(apps, schema_editor):
    AchievementDefinition = apps.get_model('gamification', 'AchievementDefinition')
    for order, row in enumerate(SEED):
        code, title, description, icon, tier, category, metric, threshold = row
        AchievementDefinition.objects.update_or_create(
            code=code,
            defaults={
                'title': title,
                'description': description,
                'icon': icon,
                'tier': tier,
                'category': category,
                'metric': metric,
                'threshold': threshold,
                'sort_order': order,
                'is_active': True,
            },
        )


def unseed(apps, schema_editor):
    AchievementDefinition = apps.get_model('gamification', 'AchievementDefinition')
    codes = [row[0] for row in SEED]
    AchievementDefinition.objects.filter(code__in=codes).delete()


class Migration(migrations.Migration):

    dependencies = [
        ('gamification', '0001_initial'),
    ]

    operations = [
        migrations.RunPython(seed_definitions, unseed),
    ]
