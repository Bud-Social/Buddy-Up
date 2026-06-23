from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import User, OTPToken, DeviceSession, AccountEvent


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
        ('2FA', {'fields': ('totp_enabled', 'totp_secret')}),
    )
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


@admin.register(AccountEvent)
class AccountEventAdmin(admin.ModelAdmin):
    list_display = ['user', 'event_type', 'ip_address', 'created_at']
    list_filter = ['event_type']
    ordering = ['-created_at']
