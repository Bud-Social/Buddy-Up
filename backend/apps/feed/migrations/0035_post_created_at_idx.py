from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('feed', '0034_save_gym_save_unique_gym_save'),
    ]

    operations = [
        migrations.AddIndex(
            model_name='post',
            index=models.Index(fields=['created_at'], name='feed_post_created_at_idx'),
        ),
    ]
