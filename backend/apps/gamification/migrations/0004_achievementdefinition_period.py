from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('gamification', '0002_seed_definitions'),
    ]

    operations = [
        migrations.AddField(
            model_name='achievementdefinition',
            name='period',
            field=models.CharField(
                choices=[
                    ('all_time', 'All Time'), ('daily', 'Daily'), ('weekly', 'Weekly'),
                    ('monthly', 'Monthly'), ('quarterly', 'Quarterly'), ('yearly', 'Yearly'),
                ],
                default='all_time', max_length=12,
            ),
        ),
    ]
