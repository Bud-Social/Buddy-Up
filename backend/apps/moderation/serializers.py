from rest_framework import serializers

from .models import ModerationReport, ContentFlag, ModerationAction


class ModerationReportSerializer(serializers.ModelSerializer):
    class Meta:
        model = ModerationReport
        fields = ['id', 'reporter', 'target_user', 'reason', 'description',
                   'content_url', 'status', 'assigned_to', 'resolved_at',
                   'resolution_note', 'created_at']
        read_only_fields = ['id', 'status', 'assigned_to', 'resolved_at', 'created_at']


class ModerationReportActionSerializer(serializers.Serializer):
    action = serializers.ChoiceField(choices=[
        'investigate', 'resolve', 'dismiss',
    ])
    resolution_note = serializers.CharField(required=False, allow_blank=True)


class ContentFlagSerializer(serializers.ModelSerializer):
    class Meta:
        model = ContentFlag
        fields = ['id', 'flag_reason', 'severity', 'confidence', 'source',
                   'content_type', 'content_id', 'content_preview',
                   'is_actioned', 'action_taken', 'created_at']
        read_only_fields = ['id', 'created_at']


class ContentFlagActionSerializer(serializers.Serializer):
    """Moderator action on a ContentFlag (Sprint B3)."""
    action = serializers.ChoiceField(choices=['approve', 'remove', 'escalate'])
    note = serializers.CharField(required=False, allow_blank=True, max_length=500)


class ModerationActionSerializer(serializers.ModelSerializer):
    class Meta:
        model = ModerationAction
        fields = ['id', 'action', 'moderator', 'report', 'target_user',
                   'reason', 'duration_days', 'created_at']
        read_only_fields = ['id', 'moderator', 'created_at']
