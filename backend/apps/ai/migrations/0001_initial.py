import uuid

import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name="AIPredictionJob",
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
                (
                    "task",
                    models.CharField(
                        choices=[
                            ("food_recognition", "Food Recognition"),
                            ("text_moderation", "Text Moderation"),
                            ("image_moderation", "Image Moderation"),
                            ("embedding", "Embedding"),
                            ("meal_plan_personalisation", "Meal Plan Personalisation"),
                            ("meal_plan_personalise", "Meal Plan Personalise"),
                            ("workout_analysis", "Workout Analysis"),
                            ("health_insights", "Health Insights"),
                            ("form_analyzer", "Form Analyzer"),
                            ("feed_ranking", "Feed Ranking"),
                        ],
                        max_length=40,
                    ),
                ),
                (
                    "status",
                    models.CharField(
                        choices=[
                            ("pending", "Pending"),
                            ("processing", "Processing"),
                            ("completed", "Completed"),
                            ("failed", "Failed"),
                        ],
                        default="pending",
                        max_length=20,
                    ),
                ),
                ("input_data", models.JSONField(default=dict)),
                ("output_data", models.JSONField(blank=True, default=dict)),
                ("error_message", models.TextField(blank=True)),
                ("model_version", models.CharField(blank=True, max_length=50)),
                ("started_at", models.DateTimeField(blank=True, null=True)),
                ("completed_at", models.DateTimeField(blank=True, null=True)),
            ],
            options={
                "db_table": "ai_prediction_job",
                "ordering": ["-created_at"],
            },
        ),
        migrations.CreateModel(
            name="ModelMetadata",
            fields=[
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("updated_at", models.DateTimeField(auto_now=True)),
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                ("name", models.CharField(max_length=100, unique=True)),
                ("version", models.CharField(max_length=50)),
                ("description", models.TextField(blank=True)),
                ("framework", models.CharField(default="pytorch", max_length=50)),
                ("input_schema", models.JSONField(blank=True, default=dict)),
                ("output_schema", models.JSONField(blank=True, default=dict)),
                ("metrics", models.JSONField(blank=True, default=dict)),
                ("artifact_path", models.CharField(blank=True, max_length=500)),
                ("is_active", models.BooleanField(default=True)),
            ],
            options={
                "db_table": "ai_model_metadata",
            },
        ),
        migrations.CreateModel(
            name="APIKey",
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
                ("key_hash", models.CharField(max_length=128, unique=True)),
                ("label", models.CharField(max_length=100)),
                ("is_active", models.BooleanField(default=True)),
                ("last_used_at", models.DateTimeField(blank=True, null=True)),
                ("expires_at", models.DateTimeField(blank=True, null=True)),
            ],
            options={
                "db_table": "ai_api_key",
            },
        ),
        migrations.AddIndex(
            model_name="aipredictionjob",
            index=models.Index(fields=["task", "status"], name="ai_pred_job_task_status_idx"),
        ),
        migrations.AddIndex(
            model_name="aipredictionjob",
            index=models.Index(fields=["-created_at"], name="ai_pred_job_created_idx"),
        ),
        migrations.AlterUniqueTogether(
            name="modelmetadata",
            unique_together={("name", "version")},
        ),
    ]
