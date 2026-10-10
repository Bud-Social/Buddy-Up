from django.contrib import admin

from .models import AccountActionRequest, StaffRole


@admin.register(StaffRole)
class StaffRoleAdmin(admin.ModelAdmin):
    list_display = ['user', 'role', 'is_active', 'granted_by', 'granted_at', 'revoked_at']
    list_filter = ['role', 'revoked_at']
    search_fields = ['user__email', 'user__profile__display_name', 'notes']
    list_select_related = ['user', 'granted_by']
    readonly_fields = ['id', 'created_at', 'updated_at']

    def is_active(self, obj):
        return obj.revoked_at is None
    is_active.boolean = True


@admin.register(AccountActionRequest)
class AccountActionRequestAdmin(admin.ModelAdmin):
    list_display = [
        'id', 'action', 'status', 'target_user', 'requested_by_profile',
        'requested_by', 'decided_by', 'decided_at', 'applied_at', 'created_at',
    ]
    list_filter = ['action', 'status', 'requires_second']
    search_fields = ['target_user__email', 'requested_by_profile', 'decision_note']
    list_select_related = ['target_user', 'requested_by', 'decided_by']
    readonly_fields = [
        'id', 'action', 'target_user', 'payload', 'requested_by',
        'requested_by_profile', 'decided_by', 'decided_at', 'applied_at',
        'created_at', 'updated_at',
    ]

    def has_add_permission(self, request):
        # Requests come from the API, which stamps requested_by / requires_second
        # together. Adding one by hand in the admin would produce a row that
        # never had a requester, defeating the audit.
        return False
