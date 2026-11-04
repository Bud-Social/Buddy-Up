from django.contrib import admin
from .models import CountdownTemplate, UserCountdown


@admin.register(CountdownTemplate)
class CountdownTemplateAdmin(admin.ModelAdmin):
    list_display = ['code', 'title', 'unit', 'default_target', 'is_active', 'sort_order']
    list_filter = ['unit', 'is_active']
    search_fields = ['code', 'title', 'description']
    list_editable = ['is_active', 'sort_order']


@admin.register(UserCountdown)
class UserCountdownAdmin(admin.ModelAdmin):
    list_display = ['user', 'display_reason', 'countdown_type', 'unit', 'current_count', 'target_count', 'is_active']
    list_filter = ['countdown_type', 'unit', 'is_active', 'template']
    search_fields = ['user__username', 'user__email', 'custom_reason', 'template__title']
    list_editable = ['is_active']
    raw_id_fields = ['user', 'template']
