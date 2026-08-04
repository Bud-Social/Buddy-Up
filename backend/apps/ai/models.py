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
    ]

    id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    task = models.CharField(max_length=40, choices=TASK_CHOICES)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    input_data = models.JSONField(default=dict)
    output_data = models.JSONField(default=dict, blank=True)
    error_message = models.TextField(blank=True)
    model_version = models.CharField(max_length=50, blank=True)
    started_at = models.DateTimeField(null=True, blank=True)
    completed_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'ai_prediction_job'
        indexes = [
            models.Index(fields=['task', 'status']),
            models.Index(fields=['-created_at']),
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
