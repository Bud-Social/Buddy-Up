from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("ai", "0001_initial"),
    ]

    operations = [
        migrations.CreateModel(
            name="TrainingRun",
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
                ("model_name", models.CharField(max_length=100)),
                ("version", models.CharField(default="1.0.0", max_length=50)),
                (
                    "scenario",
                    models.CharField(
                        blank=True,
                        choices=[
                            ("smoke", "Smoke"),
                            ("demo", "Demo"),
                            ("full", "Full"),
                            ("", "Default"),
                        ],
                        default="",
                        max_length=20,
                    ),
                ),
                ("framework", models.CharField(default="tensorflow", max_length=50)),
                ("artifact_path", models.CharField(blank=True, max_length=500)),
                ("metrics", models.JSONField(blank=True, default=dict)),
                ("n_classes", models.IntegerField(blank=True, null=True)),
                (
                    "status",
                    models.CharField(
                        choices=[
                            ("running", "Running"),
                            ("completed", "Completed"),
                            ("failed", "Failed"),
                        ],
                        default="completed",
                        max_length=20,
                    ),
                ),
                (
                    "source",
                    models.CharField(
                        choices=[
                            ("notebook", "Notebook"),
                            ("cli", "CLI"),
                            ("ci", "CI"),
                        ],
                        default="notebook",
                        max_length=20,
                    ),
                ),
                ("duration_seconds", models.FloatField(blank=True, null=True)),
                ("gpu", models.CharField(blank=True, max_length=50)),
                ("error", models.TextField(blank=True)),
            ],
            options={
                "db_table": "ai_training_run",
                "ordering": ["-created_at"],
            },
        ),
        migrations.AddIndex(
            model_name="trainingrun",
            index=models.Index(
                fields=["model_name", "version"],
                name="ai_train_run_model_ver_idx",
            ),
        ),
        migrations.AddIndex(
            model_name="trainingrun",
            index=models.Index(
                fields=["-created_at"],
                name="ai_train_run_created_idx",
            ),
        ),
    ]
