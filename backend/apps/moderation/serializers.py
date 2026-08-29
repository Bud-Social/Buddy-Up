from rest_framework import serializers

from .models import ModerationReport, ContentFlag, ModerationAction, ModerationAppeal


class ModerationReportSerializer(serializers.ModelSerializer):
    sla_due_at = serializers.SerializerMethodField()
    sla_breached = serializers.SerializerMethodField()

    class Meta:
        model = ModerationReport
        fields = ['id', 'reporter', 'target_user', 'reason', 'description',
                   'content_url', 'status', 'assigned_to', 'resolved_at',
                   'resolution_note', 'sla_due_at', 'sla_breached', 'created_at']
        read_only_fields = ['id', 'status', 'assigned_to', 'resolved_at', 'created_at']

    def get_sla_due_at(self, obj):
        from django.utils import timezone
        hours = 4 if obj.reason in ('violence', 'nudity', 'adult_ungated') else 24
        return (obj.created_at + timezone.timedelta(hours=hours)).isoformat()

    def get_sla_breached(self, obj):
        if obj.status in ('resolved', 'dismissed'):
            return False
        from django.utils import timezone
        hours = 4 if obj.reason in ('violence', 'nudity', 'adult_ungated') else 24
        return timezone.now() > obj.created_at + timezone.timedelta(hours=hours)


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


class ModerationAppealSerializer(serializers.ModelSerializer):
    class Meta:
        model = ModerationAppeal
        fields = [
            'id', 'action', 'appellant', 'reason', 'status', 'reviewer',
            'reviewed_at', 'resolution_note', 'created_at',
        ]
        read_only_fields = [
            'id', 'appellant', 'status', 'reviewer', 'reviewed_at',
            'resolution_note', 'created_at',
        ]


class ModerationAppealReviewSerializer(serializers.Serializer):
    decision = serializers.ChoiceField(choices=['approve', 'deny', 'review'])
    resolution_note = serializers.CharField(max_length=1500)
