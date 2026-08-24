# Hand-written for Draft: location coords, poll min/max, meal/progress payloads.

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('feed', '0011_poll_min_max_selections'),
    ]

    operations = [
        migrations.AddField(
            model_name='draft',
            name='location_lat',
            field=models.FloatField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name='draft',
            name='location_lng',
            field=models.FloatField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name='draft',
            name='poll_min_selections',
            field=models.PositiveSmallIntegerField(default=1),
        ),
        migrations.AddField(
            model_name='draft',
            name='poll_max_selections',
            field=models.PositiveSmallIntegerField(default=1),
        ),
        migrations.AddField(
            model_name='draft',
            name='meal_data',
            field=models.JSONField(blank=True, default=dict),
        ),
        migrations.AddField(
            model_name='draft',
            name='progress_data',
            field=models.JSONField(blank=True, default=dict),
        ),
    ]
