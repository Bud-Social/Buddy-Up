from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import User, OTPToken, DeviceSession, AccountEvent, AccountStanding


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    list_display = ['email', 'is_active', 'is_staff', 'created_at', 'email_verified']
    list_filter = ['is_active', 'is_staff', 'is_adult', 'email_verified']
    search_fields = ['email', 'phone']
    ordering = ['-created_at']
    fieldsets = (
        (None, {'fields': ('email', 'password')}),
        ('Personal', {'fields': ('phone', 'phone_verified', 'email_verified', 'dob_hash', 'is_adult')}),
        ('Permissions', {'fields': ('is_active', 'is_staff', 'is_superuser', 'groups')}),
        ('Deletion', {'fields': ('deleted_at', 'deletion_type')}),
        ('Consent', {'fields': ('consent_log',)}),
        ('Social', {'fields': ('google_id', 'apple_id')}),
        # totp_secret is deliberately absent. The seed is a second factor: it
        # is stored encrypted (accounts.crypto.EncryptedCharField), and
        # rendering it in a change form would hand it to anyone who can open
        # the admin, plus to every admin log, form-history and autocomplete
        # payload. Enable/disable TOTP through the API, which verifies the
        # user first.
        ('2FA', {'fields': ('totp_enabled',)}),
        ('Login throttling', {'fields': ('failed_login_count', 'locked_until')}),
    )
    readonly_fields = ('failed_login_count', 'locked_until')
    add_fieldsets = (
        (None, {'fields': ('email', 'password1', 'password2')}),
    )


@admin.register(OTPToken)
class OTPTokenAdmin(admin.ModelAdmin):
    list_display = ['user', 'channel', 'is_used', 'expires_at', 'created_at']
    list_filter = ['channel', 'is_used']


@admin.register(DeviceSession)
class DeviceSessionAdmin(admin.ModelAdmin):
    list_display = ['user', 'device_name', 'ip_address', 'is_active', 'last_active']
    list_filter = ['is_active']


@admin.register(AccountStanding)
class AccountStandingAdmin(admin.ModelAdmin):
    """Read-only by design.

    Standing is the record that makes a moderation decision irreversible for
    the person it is served to. If it were editable in the admin, flipping
    `state` here would be a second, unaudited way to lift a ban — bypassing
    ``lift_standing_action`` and the AccountEvent it writes. Staff who need
    to lift a standing call the service (governance approval flow) so the
    action stays attributable.
    """

    list_display = ['user', 'state', 'permanent', 'suspended_until', 'is_moderation_action', 'issued_by', 'issued_at']
    list_filter = ['state', 'permanent', 'is_moderation_action']
    search_fields = ['user__email', 'action_id', 'reason']
    ordering = ['-issued_at']
    readonly_fields = [
        'user', 'state', 'reason', 'action_id', 'suspended_until',
        'permanent', 'is_moderation_action', 'issued_by', 'issued_at',
        'created_at', 'updated_at',
    ]

    def has_add_permission(self, request):
        return False

    def has_change_permission(self, request, obj=None):
        return False

    def has_delete_permission(self, request, obj=None):
        return False


@admin.register(AccountEvent)
class AccountEventAdmin(admin.ModelAdmin):
    list_display = ['user', 'event_type', 'ip_address', 'created_at']
    list_filter = ['event_type']
    ordering = ['-created_at']
