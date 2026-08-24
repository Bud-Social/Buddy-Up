# Hand-written for Poll.min_selections / max_selections (multi-select bounds).

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('feed', '0010_alter_post_unique_together'),
    ]

    operations = [
        migrations.AddField(
            model_name='poll',
            name='min_selections',
            field=models.PositiveSmallIntegerField(default=1),
        ),
        migrations.AddField(
            model_name='poll',
            name='max_selections',
            field=models.PositiveSmallIntegerField(default=1),
        ),
    ]
