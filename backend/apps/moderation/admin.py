from django.contrib import admin

from .models import Commendation, ContentFlag, ModerationAction, ModerationAppeal, ModerationReport


@admin.register(ModerationReport)
class ModerationReportAdmin(admin.ModelAdmin):
    list_display = ['id', 'reason', 'status', 'target_user', 'reporter',
                    'assigned_to', 'created_at', 'resolved_at']
    list_filter = ['status', 'reason']
    search_fields = ['description', 'resolution_note']
    readonly_fields = ['id', 'created_at', 'updated_at']
    list_select_related = ['reporter', 'target_user', 'assigned_to']
    autocomplete_fields = ['assigned_to']


@admin.register(ContentFlag)
class ContentFlagAdmin(admin.ModelAdmin):
    list_display = ['id', 'flag_reason', 'severity', 'confidence', 'content_type',
                    'content_id', 'is_actioned', 'created_at']
    list_filter = ['flag_reason', 'severity', 'is_actioned']
    search_fields = ['content_preview']


@admin.register(ModerationAction)
class ModerationActionAdmin(admin.ModelAdmin):
    list_display = ['id', 'action', 'moderator', 'target_user', 'reason',
                    'duration_days', 'content_type', 'is_reversed', 'created_at']
    list_filter = ['action']
    search_fields = ['reason', 'reversal_reason']
    list_select_related = ['moderator', 'target_user', 'reversed_by']
    autocomplete_fields = ['moderator', 'target_user', 'reversed_by']
    readonly_fields = ['id', 'created_at', 'updated_at']


@admin.register(ModerationAppeal)
class ModerationAppealAdmin(admin.ModelAdmin):
    list_display = ['id', 'action', 'appellant', 'status', 'reviewer', 'created_at']
    list_filter = ['status']
    readonly_fields = ['id', 'created_at', 'updated_at']
    list_select_related = ['action', 'appellant', 'reviewer']


@admin.register(Commendation)
class CommendationAdmin(admin.ModelAdmin):
    list_display = ['id', 'recipient', 'issued_by', 'category',
                    'visible_to_recipient', 'created_at']
    list_filter = ['category', 'visible_to_recipient']
    search_fields = ['message']
    readonly_fields = ['id', 'created_at', 'updated_at']
    list_select_related = ['recipient', 'issued_by']