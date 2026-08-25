# Pinned / dismissed flags for notification list actions.

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('notifications', '0005_alter_notification_notification_type'),
    ]

    operations = [
        migrations.AddField(
            model_name='notification',
            name='is_pinned',
            field=models.BooleanField(default=False),
        ),
        migrations.AddField(
            model_name='notification',
            name='is_dismissed',
            field=models.BooleanField(default=False),
        ),
    ]
