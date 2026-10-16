from datetime import timedelta

from django.utils import timezone
from rest_framework import serializers

from .models import (
    Commendation, ContentFlag, ModerationAction, ModerationAppeal,
    ModerationReport,
)


#: Reasons that carry a 4-hour response target instead of 24. Violence, sexual
#: content and ungated adult material are the ones where a slow answer is part
#: of the harm, so they are not allowed to sit in a queue overnight.
URGENT_REASONS = frozenset({'violence', 'nudity', 'adult_ungated'})
URGENT_SLA_HOURS = 4
STANDARD_SLA_HOURS = 24


def sla_hours_for(report):
    return URGENT_SLA_HOURS if report.reason in URGENT_REASONS else STANDARD_SLA_HOURS


def sla_due_at_for(report):
    """Pure-Python, zero queries.

    Deliberately not a database annotation. An interval expression is not
    portable to every backend this project runs against, and the whole
    computation reads two already-loaded columns (``created_at`` and
    ``reason``). Annotating it would buy nothing and cost portability — the
    per-row cost that actually threatens a list endpoint is the extra query per
    row, and this has none. ``ModerationAssignmentTests`` pins the query count.
    """
    return report.created_at + timedelta(hours=sla_hours_for(report))


def sla_breached_for(report, now=None):
    if report.status in ('resolved', 'dismissed'):
        return False
    return (now or timezone.now()) > sla_due_at_for(report)


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
        return sla_due_at_for(obj).isoformat()

    def get_sla_breached(self, obj):
        return sla_breached_for(obj)


class ModerationReportActionSerializer(serializers.Serializer):
    action = serializers.ChoiceField(choices=[
        'investigate', 'resolve', 'dismiss',
    ])
    resolution_note = serializers.CharField(required=False, allow_blank=True)


class ModerationReportAssignSerializer(serializers.Serializer):
    """Assign or unassign a report.

    ``assigned_to`` is a UUID of a staff user, or ``null`` to unassign. Omitting
    it entirely is an error rather than an implicit unassign: a client that
    drops the field by accident should not silently drop the report back into
    the unassigned pile.
    """

    assigned_to = serializers.UUIDField(allow_null=True)
    note = serializers.CharField(required=False, allow_blank=True, max_length=500)


class ContentFlagSerializer(serializers.ModelSerializer):
    class Meta:
        model = ContentFlag
        fields = ['id', 'flag_reason', 'severity', 'confidence', 'source',
                   'content_type', 'content_id', 'content_preview',
                   # What the model said, and what it did *not* look at. The
                   # console renders both; `bias_assessed: false` is the field
                   # that stops "no bias signal" reading as "no bias found".
                   'ai_explanation', 'ai_method', 'bias_assessed',
                   'is_actioned', 'action_taken', 'created_at']
        read_only_fields = ['id', 'created_at', 'ai_explanation', 'ai_method', 'bias_assessed']


class ContentFlagActionSerializer(serializers.Serializer):
    """Moderator action on a ContentFlag (Sprint B3)."""
    action = serializers.ChoiceField(choices=['approve', 'remove', 'escalate'])
    note = serializers.CharField(required=False, allow_blank=True, max_length=500)


class ModerationActionSerializer(serializers.ModelSerializer):
    content_type_display = serializers.SerializerMethodField()
    is_reversed = serializers.BooleanField(read_only=True)
    reversed_by_moderator = serializers.SerializerMethodField()

    class Meta:
        model = ModerationAction
        fields = ['id', 'action', 'moderator', 'report', 'target_user',
                   'reason', 'duration_days', 'content_type', 'content_type_display',
                   'content_id', 'is_reversed', 'reversed_by', 'reversed_at',
                   'reversal_reason', 'reversed_by_moderator', 'created_at']
        read_only_fields = [
            'id', 'moderator', 'report', 'target_user', 'duration_days',
            'content_type', 'content_id', 'reversed_by', 'reversed_at',
            'reversal_reason', 'created_at',
        ]

    def get_content_type_display(self, obj):
        from .takedown import CONTENT_HANDLERS
        handler = CONTENT_HANDLERS.get(obj.content_type)
        return handler.label if handler else ''

    def get_reversed_by_moderator(self, obj):
        """Who undid this action.

        ``reversed_by`` is a self FK to the ``action_reversed`` row, so the
        moderator who performed the reversal lives on *that* row. Surfacing it
        here saves a client a second request to answer "who did this".
        """
        if obj.reversed_by_id is None:
            return None
        moderator = getattr(obj.reversed_by, 'moderator', None)
        if moderator is None:
            return None
        return {
            'id': str(moderator.pk),
            'email': moderator.email,
            'action_id': str(obj.reversed_by_id),
        }


class ModerationActionCreateSerializer(serializers.Serializer):
    """Input for a staff-initiated disciplinary action.

    Only ``warning``, ``user_suspended`` and ``user_banned`` are accepted here.
    ``content_removed`` is not: it needs a ``ContentFlag`` to say *which* content,
    and it is taken through ``POST /content-flags/{id}/act/`` so the flag and the
    removal cannot drift apart. ``report_dismissed``, ``escalated`` and
    ``action_reversed`` are server-owned outcomes, never client input.
    """

    REQUESTABLE = ('warning', 'user_suspended', 'user_banned')

    action = serializers.ChoiceField(choices=REQUESTABLE)
    target_user = serializers.UUIDField()
    reason = serializers.CharField(max_length=1500)
    duration_days = serializers.IntegerField(required=False, allow_null=True, min_value=1)
    report = serializers.UUIDField(required=False, allow_null=True)

    def validate(self, attrs):
        user_model = self.context['user_model']
        target = user_model.objects.filter(pk=attrs['target_user']).first()
        if target is None:
            raise serializers.ValidationError({'target_user': 'No such user.'})
        if target.pk == self.context['request'].user.pk:
            raise serializers.ValidationError({
                'target_user': 'You cannot issue a moderation action against your own account.',
            })
        if target.is_superuser:
            raise serializers.ValidationError({
                'target_user': 'Moderation actions cannot be issued against a superuser account.',
            })

        # A ban is permanent by definition, so a duration on it is either a
        # mistake or an attempt to make a ban expire. Refuse rather than quietly
        # dropping the field — a moderator who thinks they set 30 days has
        # actually banned someone forever.
        if attrs['action'] == 'user_banned':
            if attrs.get('duration_days'):
                raise serializers.ValidationError({
                    'duration_days': 'A ban is permanent and takes no duration. '
                                     'Use user_suspended for a time-limited action.',
                })
            attrs['duration_days'] = None
        elif attrs['action'] == 'user_suspended' and attrs.get('duration_days') is None:
            # `accounts.services` would accept a duration-less suspension as
            # "indefinite until lifted", which is a decision with no end date
            # and no way for the user to see when it expires. Require the term.
            raise serializers.ValidationError({
                'duration_days': 'A suspension requires a duration in whole days. '
                                 'For an open-ended action, escalate it instead.',
            })
        elif attrs['action'] == 'warning':
            # A warning changes no access state, so it has no term.
            attrs['duration_days'] = None

        attrs['_target'] = target
        return attrs


class ModerationActionReverseSerializer(serializers.Serializer):
    reason = serializers.CharField(max_length=1500)


class CommendationSerializer(serializers.ModelSerializer):
    category_display = serializers.CharField(source='get_category_display', read_only=True)

    class Meta:
        model = Commendation
        fields = ['id', 'recipient', 'issued_by', 'category', 'category_display',
                  'message', 'visible_to_recipient', 'created_at']
        read_only_fields = ['id', 'issued_by', 'visible_to_recipient', 'created_at']


class CommendationCreateSerializer(serializers.ModelSerializer):
    recipient = serializers.UUIDField()

    class Meta:
        model = Commendation
        fields = ['recipient', 'category', 'message']
        extra_kwargs = {'message': {'max_length': 500}}

    def validate_recipient(self, value):
        from apps.profiles.models import Profile
        profile = Profile.objects.filter(pk=value).first()
        if profile is None:
            raise serializers.ValidationError('No such profile.')
        if profile.user_id == self.context['request'].user.pk:
            raise serializers.ValidationError('You cannot commend your own account.')
        return profile


class CommendationRevokeSerializer(serializers.Serializer):
    reason = serializers.CharField(required=False, allow_blank=True, max_length=500)


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