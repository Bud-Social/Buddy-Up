from rest_framework import serializers
from zoneinfo import ZoneInfo
from .models import Notification, NotificationPreference


class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = ['id', 'notification_type', 'title', 'body', 'metadata', 'is_read',
                   'is_pinned', 'created_at', 'priority', 'aggregation_count',
                   'expires_at', 'delivery_status', 'delivered_at']


class NotificationPreferenceSerializer(serializers.ModelSerializer):
    class Meta:
        model = NotificationPreference
        fields = [
            'push_enabled', 'email_enabled', 'in_app_enabled',
            'quiet_hours_start', 'quiet_hours_end',
            'timezone', 'category_frequency',
            'buddy_request_push', 'buddy_accepted_push', 'new_follower_push',
            'comment_push', 'live_starting_push', 'session_reminder_push',
            'streak_milestone_push', 'accountability_ping_push',
            'programme_reminder_push', 'meal_reminder_push', 'shop_cert_push', 'new_purchase_push',
        ]

    def validate_timezone(self, value):
        try:
            ZoneInfo(value)
        except Exception:
            raise serializers.ValidationError('Use a valid IANA timezone, such as Africa/Nairobi.')
        return value
