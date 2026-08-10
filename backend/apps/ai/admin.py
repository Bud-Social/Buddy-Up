from django.contrib import admin

from .models import AIPredictionJob, ModelMetadata, APIKey, TrainingRun


@admin.register(AIPredictionJob)
class AIPredictionJobAdmin(admin.ModelAdmin):
    list_display = ['id', 'task', 'status', 'model_version', 'result_url', 'created_at', 'completed_at']
    list_filter = ['task', 'status']
    search_fields = ['task', 'error_message']
    readonly_fields = ['id', 'created_at', 'updated_at']


@admin.register(ModelMetadata)
class ModelMetadataAdmin(admin.ModelAdmin):
    list_display = ['name', 'version', 'framework', 'is_active', 'created_at']
    list_filter = ['framework', 'is_active']
    search_fields = ['name', 'description']


@admin.register(APIKey)
class APIKeyAdmin(admin.ModelAdmin):
    list_display = ['label', 'is_active', 'last_used_at', 'expires_at', 'created_at']
    list_filter = ['is_active']
    search_fields = ['label']


@admin.register(TrainingRun)
class TrainingRunAdmin(admin.ModelAdmin):
    list_display = ['model_name', 'version', 'scenario', 'framework', 'status',
                    'duration_seconds', 'created_at']
    list_filter = ['framework', 'status', 'scenario']
    search_fields = ['model_name', 'version', 'error']
    readonly_fields = ['id', 'created_at', 'updated_at']
