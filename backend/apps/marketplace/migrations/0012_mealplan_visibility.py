# Hand-written for MealPlan.visibility (audience scope for meal plan products).

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('marketplace', '0011_alter_marketplaceevent_category'),
    ]

    operations = [
        migrations.AddField(
            model_name='mealplan',
            name='visibility',
            field=models.CharField(
                choices=[('public', 'Public'), ('buddies', 'Buddies Only'), ('private', 'Only Me')],
                default='public',
                max_length=15,
            ),
        ),
    ]
