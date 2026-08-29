from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [('analytics', '0002_bodymetric_scale_photo_url')]

    operations = [
        migrations.AddField(model_name='activityrecord', name='source_event_id', field=models.CharField(max_length=120, null=True, blank=True)),
        migrations.AddField(model_name='activityrecord', name='provenance', field=models.JSONField(default=dict, blank=True)),
        migrations.AddField(model_name='activityrecord', name='is_paused', field=models.BooleanField(default=False)),
        migrations.AddField(model_name='activityrecord', name='paused_at', field=models.DateTimeField(null=True, blank=True)),
        migrations.AddField(model_name='activityrecord', name='total_pause_seconds', field=models.PositiveIntegerField(default=0)),
        migrations.AddField(model_name='workoutlog', name='source_event_id', field=models.CharField(max_length=120, null=True, blank=True)),
        migrations.AddField(model_name='workoutlog', name='provenance', field=models.JSONField(default=dict, blank=True)),
        migrations.AddField(model_name='meallog', name='source_event_id', field=models.CharField(max_length=120, null=True, blank=True)),
        migrations.AddField(model_name='meallog', name='provenance', field=models.JSONField(default=dict, blank=True)),
        migrations.AlterField(model_name='meallog', name='meal_type', field=models.CharField(max_length=20, choices=[('breakfast', 'Breakfast'), ('lunch', 'Lunch'), ('dinner', 'Dinner'), ('snack', 'Snack'), ('drink', 'Drink'), ('other', 'Other')], default='other')),
        migrations.AddConstraint(model_name='activityrecord', constraint=models.UniqueConstraint(fields=('user', 'source_event_id'), name='analytics_activity_source_event_unique')),
        migrations.AddConstraint(model_name='workoutlog', constraint=models.UniqueConstraint(fields=('user', 'source_event_id'), name='analytics_workout_source_event_unique')),
        migrations.AddConstraint(model_name='meallog', constraint=models.UniqueConstraint(fields=('user', 'source_event_id'), name='analytics_meal_source_event_unique')),
    ]
