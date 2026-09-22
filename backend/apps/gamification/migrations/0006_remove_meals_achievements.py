# Remove nutrition/meals-logged achievements (MealLog feature removed).

from django.db import migrations

MEALS_ACHIEVEMENT_CODES = (
    'meals_10',            # Clean Eater (bronze, one-off)
    'daily_meals_3',       # Clean Fuel (daily)
    'monthly_meals_30',    # Meal Prep Pro (monthly)
    'quarterly_meals_90',  # Nutrition Nerd (quarterly)
)


def delete_meals_achievements(apps, schema_editor):
    AchievementDefinition = apps.get_model('gamification', 'AchievementDefinition')
    UserAchievement = apps.get_model('gamification', 'UserAchievement')
    definitions = AchievementDefinition.objects.filter(code__in=MEALS_ACHIEVEMENT_CODES)
    UserAchievement.objects.filter(definition__in=definitions).delete()
    definitions.delete()


class Migration(migrations.Migration):

    dependencies = [
        ('gamification', '0005_seed_periodic'),
    ]

    operations = [
        migrations.RunPython(delete_meals_achievements, migrations.RunPython.noop),
    ]
