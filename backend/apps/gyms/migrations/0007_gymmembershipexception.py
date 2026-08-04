# Generated manually for GymMembershipException model.

import django.db.models.deletion
import uuid
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("gyms", "0006_gymschedulepost_linked_live_and_more"),
        ("profiles", "0002_profile_saved_payment_methods"),
    ]

    operations = [
        migrations.CreateModel(
            name="GymMembershipException",
            fields=[
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("updated_at", models.DateTimeField(auto_now=True)),
                (
                    "id",
                    models.UUIDField(
                        default=uuid.uuid4,
                        editable=False,
                        primary_key=True,
                        serialize=False,
                    ),
                ),
                ("discount_pct", models.IntegerField(default=100)),
                ("reason", models.CharField(blank=True, default="", max_length=200)),
                ("expires_at", models.DateTimeField(blank=True, null=True)),
                ("is_active", models.BooleanField(default=True)),
                (
                    "gym",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name="membership_exceptions",
                        to="gyms.gym",
                    ),
                ),
                (
                    "member",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name="gym_membership_exceptions",
                        to="profiles.profile",
                    ),
                ),
                (
                    "created_by",
                    models.ForeignKey(
                        blank=True,
                        null=True,
                        on_delete=django.db.models.deletion.SET_NULL,
                        related_name="created_gym_membership_exceptions",
                        to="profiles.profile",
                    ),
                ),
            ],
            options={
                "db_table": "gyms_membership_exception",
                "unique_together": {("gym", "member")},
            },
        ),
    ]
