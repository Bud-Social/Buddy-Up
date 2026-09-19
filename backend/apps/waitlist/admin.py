from django.contrib import admin

from .models import WaitlistEntry


@admin.register(WaitlistEntry)
class WaitlistEntryAdmin(admin.ModelAdmin):
    list_display = ('email', 'name', 'source', 'created_at')
    search_fields = ('email', 'name')
    readonly_fields = ('created_at',)
