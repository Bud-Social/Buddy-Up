# Seed windowed (daily/weekly/monthly/quarterly/yearly) achievements.

from django.db import migrations


def seed_periodic(apps, schema_editor):
    AchievementDefinition = apps.get_model('gamification', 'AchievementDefinition')
    catalog = [
        # daily
        ('daily_workout_1', 'Daily Rep', 'Log 1 workout today', '💪', 'activity', 'workouts_logged', 1, 'daily', 'bronze', 10),
        ('daily_meals_3', 'Clean Fuel', 'Log 3 meals today', '🥗', 'nutrition', 'meals_logged', 3, 'daily', 'bronze', 11),
        ('daily_distance_2', 'Lunchtime Stroll', 'Track 2 km on foot today', '👣', 'activity', 'activities_distance_km', 2, 'daily', 'bronze', 12),
        # weekly
        ('weekly_workouts_3', 'Consistency Kick', '3 workouts this week', '🏋️', 'activity', 'workouts_logged', 3, 'weekly', 'bronze', 20),
        ('weekly_workouts_5', 'Five-Timer', '5 workouts this week', '🔥', 'consistency', 'workouts_logged', 5, 'weekly', 'silver', 21),
        ('weekly_distance_15', 'Weekly Warrior', '15 km tracked this week', '🗺️', 'activity', 'activities_distance_km', 15, 'weekly', 'silver', 22),
        ('weekly_steps_35k', 'Step Machine', '35,000 steps this week', '👟', 'activity', 'activities_steps', 35000, 'weekly', 'gold', 23),
        ('weekly_posts_2', 'Share the Grind', 'Share 2 posts this week', '📣', 'social', 'posts_created', 2, 'weekly', 'bronze', 24),
        # monthly
        ('monthly_workouts_12', 'Twelve Rounds', '12 workouts this month', '🏆', 'activity', 'workouts_logged', 12, 'monthly', 'gold', 30),
        ('monthly_distance_50', '50K Club', '50 km tracked this month', '🚩', 'activity', 'activities_distance_km', 50, 'monthly', 'gold', 31),
        ('monthly_meals_30', 'Meal Prep Pro', 'Log 30 meals this month', '🍱', 'nutrition', 'meals_logged', 30, 'monthly', 'silver', 32),
        # quarterly
        ('quarterly_workouts_30', 'Quarter Horse', '30 workouts in a quarter', '🐎', 'consistency', 'workouts_logged', 30, 'quarterly', 'gold', 40),
        ('quarterly_meals_90', 'Nutrition Nerd', 'Log 90 meals in a quarter', '📊', 'nutrition', 'meals_logged', 90, 'quarterly', 'platinum', 41),
        # yearly
        ('yearly_workouts_100', 'Century Training', '100 workouts this year', '💯', 'activity', 'workouts_logged', 100, 'yearly', 'platinum', 50),
    ]
    for i, (code, title, desc, icon, category, metric, threshold, period, tier, sort) in enumerate(catalog):
        AchievementDefinition.objects.update_or_create(
            code=code,
            defaults=dict(
                title=title, description=desc, icon=icon, category=category,
                metric=metric, threshold=float(threshold), period=period,
                tier=tier, sort_order=sort, is_active=True,
            ),
        )


class Migration(migrations.Migration):

    dependencies = [
        ('gamification', '0004_achievementdefinition_period'),
    ]

    operations = [
        migrations.RunPython(seed_periodic, migrations.RunPython.noop),
    ]
