from django.contrib import admin

from .models import ModerationReport, ContentFlag, ModerationAction


@admin.register(ModerationReport)
class ModerationReportAdmin(admin.ModelAdmin):
    list_display = ['id', 'reason', 'status', 'target_user', 'reporter',
                    'assigned_to', 'created_at', 'resolved_at']
    list_filter = ['status', 'reason']
    search_fields = ['description', 'resolution_note']
    readonly_fields = ['id', 'created_at', 'updated_at']
    list_select_related = ['reporter', 'target_user', 'assigned_to']


@admin.register(ContentFlag)
class ContentFlagAdmin(admin.ModelAdmin):
    list_display = ['id', 'flag_reason', 'severity', 'confidence', 'content_type',
                    'content_id', 'is_actioned', 'created_at']
    list_filter = ['flag_reason', 'severity', 'is_actioned']
    search_fields = ['content_preview']


@admin.register(ModerationAction)
class ModerationActionAdmin(admin.ModelAdmin):
    list_display = ['id', 'action', 'moderator', 'target_user', 'reason',
                    'duration_days', 'created_at']
    list_filter = ['action']
    search_fields = ['reason']
    list_select_related = ['moderator', 'target_user']
