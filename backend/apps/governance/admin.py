from django.contrib import admin

from .models import AccountActionRequest, AdminActionLog, EmailLog, StaffRole


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


@admin.register(AdminActionLog)
class AdminActionLogAdmin(admin.ModelAdmin):
    """Read-only by construction.

    An audit trail that can be edited through the admin is not an audit trail.
    The only mutation allowed is deleting old rows, and even that is a decision
    someone has to make deliberately rather than a stray keystroke.
    """

    list_display = [
        'created_at', 'action', 'actor_email', 'target_type', 'target_id', 'summary',
    ]
    list_filter = ['action', 'target_type']
    search_fields = ['actor_email', 'target_id', 'summary', 'request_id']
    list_select_related = ['actor']
    readonly_fields = [
        f.name for f in AdminActionLog._meta.fields
    ]
    date_hierarchy = 'created_at'

    def has_add_permission(self, request):
        return False

    def has_change_permission(self, request, obj=None):
        return False


@admin.register(EmailLog)
class EmailLogAdmin(admin.ModelAdmin):
    """Also read-only: the status transition belongs to the worker, not a human."""

    list_display = [
        'created_at', 'status', 'recipient_email', 'subject', 'template_key',
        'sent_by_email', 'error',
    ]
    list_filter = ['status', 'template_key', 'related_object_type']
    search_fields = ['recipient_email', 'subject', 'sent_by_email', 'dedupe_key']
    list_select_related = ['recipient_user', 'sent_by']
    readonly_fields = [
        f.name for f in EmailLog._meta.fields
    ]
    date_hierarchy = 'created_at'

    def has_add_permission(self, request):
        return False

    def has_change_permission(self, request, obj=None):
        return False
