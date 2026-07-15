from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("profiles", "0002_profile_saved_payment_methods"),
    ]

    operations = [
        migrations.AddField(
            model_name="profile",
            name="locked_balance",
            field=models.JSONField(default=dict),
        ),
    ]
