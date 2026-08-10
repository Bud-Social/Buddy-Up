from uuid import uuid4

from django.db import models

from common.models import TimestampedModel


class AIPredictionJob(TimestampedModel):
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('processing', 'Processing'),
        ('completed', 'Completed'),
        ('failed', 'Failed'),
    ]
    TASK_CHOICES = [
        ('food_recognition', 'Food Recognition'),
        ('text_moderation', 'Text Moderation'),
        ('image_moderation', 'Image Moderation'),
        ('embedding', 'Embedding'),
        ('meal_plan_personalisation', 'Meal Plan Personalisation'),
        ('meal_plan_personalise', 'Meal Plan Personalise'),
        ('workout_analysis', 'Workout Analysis'),
        ('health_insights', 'Health Insights'),
        ('form_analyzer', 'Form Analyzer'),
        ('feed_ranking', 'Feed Ranking'),
        ('video_description', 'Workout Video Description'),
        ('summarization', 'Text Summarization'),
        ('text_to_speech', 'Text To Speech'),
        ('visual_search_embedding', 'Visual Search Embedding'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    task = models.CharField(max_length=40, choices=TASK_CHOICES)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    input_data = models.JSONField(default=dict)
    output_data = models.JSONField(default=dict, blank=True)
    error_message = models.TextField(blank=True)
    model_version = models.CharField(max_length=50, blank=True)
    result_url = models.URLField(blank=True)  # e.g. generated TTS audio
    started_at = models.DateTimeField(null=True, blank=True)
    completed_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'ai_prediction_job'
        indexes = [
            models.Index(fields=['task', 'status'], name='ai_pred_job_task_status_idx'),
            models.Index(fields=['-created_at'], name='ai_pred_job_created_idx'),
        ]
        ordering = ['-created_at']

    def __str__(self):
        return f'{self.task} [{self.status}]'


class ModelMetadata(TimestampedModel):
    name = models.CharField(max_length=100, unique=True)
    version = models.CharField(max_length=50)
    description = models.TextField(blank=True)
    framework = models.CharField(max_length=50, default='pytorch')
    input_schema = models.JSONField(default=dict, blank=True)
    output_schema = models.JSONField(default=dict, blank=True)
    metrics = models.JSONField(default=dict, blank=True)
    artifact_path = models.CharField(max_length=500, blank=True)
    is_active = models.BooleanField(default=True)

    class Meta:
        db_table = 'ai_model_metadata'
        unique_together = ('name', 'version')

    def __str__(self):
        return f'{self.name}:{self.version}'


class TrainingRun(TimestampedModel):
    """One execution of a training notebook / pipeline.

    Persisted via POST /api/v1/admin/dashboard/log-training/ so the ML
    dashboard can show every training attempt (smoke/demo/full) with its
    final metrics and artifact, without depending on an on-disk logs dir.
    """
    STATUS_CHOICES = [
        ('running', 'Running'),
        ('completed', 'Completed'),
        ('failed', 'Failed'),
    ]
    SOURCE_CHOICES = [
        ('notebook', 'Notebook'),
        ('cli', 'CLI'),
        ('ci', 'CI'),
    ]
    SCENARIO_CHOICES = [
        ('smoke', 'Smoke'),
        ('demo', 'Demo'),
        ('full', 'Full'),
        ('', 'Default'),
    ]

    model_name = models.CharField(max_length=100)
    version = models.CharField(max_length=50, default='1.0.0')
    scenario = models.CharField(max_length=20, choices=SCENARIO_CHOICES, blank=True, default='')
    framework = models.CharField(max_length=50, default='tensorflow')
    artifact_path = models.CharField(max_length=500, blank=True)
    metrics = models.JSONField(default=dict, blank=True)
    n_classes = models.IntegerField(null=True, blank=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='completed')
    source = models.CharField(max_length=20, choices=SOURCE_CHOICES, default='notebook')
    duration_seconds = models.FloatField(null=True, blank=True)
    gpu = models.CharField(max_length=50, blank=True)
    error = models.TextField(blank=True)

    class Meta:
        db_table = 'ai_training_run'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['model_name', 'version'], name='ai_train_run_model_ver_idx'),
            models.Index(fields=['-created_at'], name='ai_train_run_created_idx'),
        ]

    def __str__(self):
        return f'{self.model_name}:{self.version} [{self.status}]'


class APIKey(TimestampedModel):
    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    key_hash = models.CharField(max_length=128, unique=True)
    label = models.CharField(max_length=100)
    is_active = models.BooleanField(default=True)
    last_used_at = models.DateTimeField(null=True, blank=True)
    expires_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'ai_api_key'

    def __str__(self):
        return self.label
