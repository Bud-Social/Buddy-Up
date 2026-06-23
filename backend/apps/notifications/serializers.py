from rest_framework import serializers
from .models import Notification, NotificationPreference


class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = ['id', 'notification_type', 'title', 'body', 'metadata', 'is_read', 'created_at']


class NotificationPreferenceSerializer(serializers.ModelSerializer):
    class Meta:
        model = NotificationPreference
        fields = [
            'push_enabled', 'email_enabled', 'in_app_enabled',
            'quiet_hours_start', 'quiet_hours_end',
            'buddy_request_push', 'buddy_accepted_push', 'new_follower_push',
            'comment_push', 'live_starting_push', 'session_reminder_push',
            'streak_milestone_push', 'accountability_ping_push',
        ]
