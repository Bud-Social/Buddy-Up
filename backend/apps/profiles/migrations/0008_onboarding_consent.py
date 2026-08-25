# Hand-written for onboarding gate + consent records.

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('profiles', '0007_profile_content_rating'),
    ]

    operations = [
        migrations.AddField(
            model_name='profile',
            name='onboarding_completed',
            field=models.BooleanField(default=True),
        ),
        migrations.AddField(
            model_name='profile',
            name='terms_version',
            field=models.CharField(blank=True, max_length=20),
        ),
        migrations.AddField(
            model_name='profile',
            name='terms_accepted_at',
            field=models.DateTimeField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name='profile',
            name='marketing_consent',
            field=models.BooleanField(default=False),
        ),
    ]
