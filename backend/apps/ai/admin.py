from django.contrib import admin

from .models import AIPredictionJob, ModelMetadata, APIKey


@admin.register(AIPredictionJob)
class AIPredictionJobAdmin(admin.ModelAdmin):
    list_display = ['id', 'task', 'status', 'model_version', 'created_at', 'completed_at']
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
