from django.contrib import admin

from .models import GuardianLink


@admin.register(GuardianLink)
class GuardianLinkAdmin(admin.ModelAdmin):
    list_display = [
        'id', 'guardian', 'teen', 'status', 'invite_email', 'accepted_at', 'created_at',
    ]
    list_filter = ['status']
    search_fields = ['invite_email', 'guardian__email', 'teen__email']
    ordering = ['-created_at']
    readonly_fields = ['invite_token_hash']
