from django.contrib import admin

from .models import Alarm, AlarmShare, AlarmSound, AlarmSuggestion


@admin.register(AlarmSound)
class AlarmSoundAdmin(admin.ModelAdmin):
    list_display = ['id', 'owner', 'name', 'source', 'visibility',
                    'duration_ms', 'created_at']
    list_filter = ['source', 'visibility']
    search_fields = ['name', 'owner__username', 'owner__display_name']
    list_select_related = ['owner']
    readonly_fields = ['id', 'created_at', 'updated_at']


@admin.register(Alarm)
class AlarmAdmin(admin.ModelAdmin):
    list_display = ['id', 'owner', 'time', 'days_mask', 'label',
                    'sound', 'enabled', 'created_at']
    list_filter = ['enabled']
    search_fields = ['label', 'owner__username', 'owner__display_name']
    list_select_related = ['owner', 'sound']
    readonly_fields = ['id', 'created_at', 'updated_at']


@admin.register(AlarmShare)
class AlarmShareAdmin(admin.ModelAdmin):
    list_display = ['id', 'sound', 'sender', 'recipient', 'status', 'created_at']
    list_filter = ['status']
    search_fields = ['sender__username', 'recipient__username', 'sound__name']
    list_select_related = ['sound', 'sender', 'recipient']
    readonly_fields = ['id', 'created_at', 'updated_at']


@admin.register(AlarmSuggestion)
class AlarmSuggestionAdmin(admin.ModelAdmin):
    list_display = ['id', 'sender', 'recipient', 'title', 'status', 'created_at']
    list_filter = ['status']
    search_fields = ['title', 'sender__username', 'recipient__username']
    list_select_related = ['sender', 'recipient']
    readonly_fields = ['id', 'created_at', 'updated_at']
