from rest_framework import serializers
from .models import (
    CountdownEvent, CountdownTemplate, UserCountdown, Routine,
    RoutineCheckIn, RoutineHighlight,
)
from .services import KNOWN_SIGNALS


class CountdownTemplateSerializer(serializers.ModelSerializer):
    class Meta:
        model = CountdownTemplate
        fields = [
            'id', 'code', 'title', 'description', 'unit', 'default_target',
            'icon', 'color', 'is_active', 'sort_order', 'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class CountdownEventSerializer(serializers.ModelSerializer):
    """One entry in a countdown's stream."""

    class Meta:
        model = CountdownEvent
        fields = [
            'id', 'countdown', 'event_type', 'count_after', 'elapsed_seconds',
            'run_elapsed_seconds', 'unit', 'note', 'occurred_at',
        ]
        read_only_fields = fields


class UserCountdownSerializer(serializers.ModelSerializer):
    template_detail = CountdownTemplateSerializer(source='template', read_only=True)
    days_since_start = serializers.ReadOnlyField()
    display_reason = serializers.ReadOnlyField()
    display_icon = serializers.ReadOnlyField()
    elapsed_units = serializers.ReadOnlyField()
    run_started_at = serializers.ReadOnlyField()
    run_elapsed_seconds = serializers.ReadOnlyField()
    next_checkin_at = serializers.SerializerMethodField()

    class Meta:
        model = UserCountdown
        fields = [
            'id', 'template', 'template_detail', 'custom_reason', 'countdown_type',
            'unit', 'current_count', 'target_count', 'start_date',
            'last_checkin_at', 'last_auto_advance_at', 'auto_advance_signal',
            'is_active', 'completed_at', 'days_since_start', 'display_reason',
            'display_icon', 'created_at', 'updated_at',
            # Streak window + when the next check-in opens.
            'elapsed_units', 'run_started_at', 'run_elapsed_seconds',
            'next_checkin_at', 'last_reset_at',
        ]
        read_only_fields = [
            'id', 'current_count', 'last_checkin_at', 'last_auto_advance_at',
            'completed_at', 'days_since_start',
            'display_reason', 'display_icon', 'created_at', 'updated_at',
            'elapsed_units', 'run_started_at', 'run_elapsed_seconds',
            'next_checkin_at', 'last_reset_at',
        ]

    def get_next_checkin_at(self, obj):
        """When the next manual check-in unlocks (null when it is open)."""
        unlock = obj.next_checkin_at()
        return unlock.isoformat() if unlock else None

    def validate(self, attrs):
        template = attrs.get('template') or getattr(self.instance, 'template', None)
        custom_reason = attrs.get('custom_reason') or getattr(self.instance, 'custom_reason', '')
        if not template and not custom_reason:
            raise serializers.ValidationError({
                'custom_reason': 'A custom reason is required when no template is selected.',
            })

        # An automatic countdown only advances when something in the app
        # raises its signal, so the signal is part of what it *is*. A manual
        # one is advanced by the user and must not carry one.
        countdown_type = (
            attrs.get('countdown_type')
            or getattr(self.instance, 'countdown_type', 'manual')
        )
        signal = attrs.get('auto_advance_signal')
        if signal is None:
            signal = getattr(self.instance, 'auto_advance_signal', '') or ''

        if countdown_type == 'automatic':
            if not signal:
                raise serializers.ValidationError({
                    'auto_advance_signal': 'An automatic countdown needs a signal to advance on.',
                })
            if signal not in KNOWN_SIGNALS:
                raise serializers.ValidationError({
                    'auto_advance_signal': f'Unknown signal. Choose one of: {", ".join(KNOWN_SIGNALS)}.',
                })
        elif signal:
            raise serializers.ValidationError({
                'auto_advance_signal': 'Only automatic countdowns carry a signal.',
            })

        return attrs


class RoutineSerializer(serializers.ModelSerializer):
    display_name = serializers.CharField(read_only=True)
    type_label = serializers.SerializerMethodField()
    highlights = serializers.SerializerMethodField()
    checkin_count = serializers.SerializerMethodField()

    name = serializers.CharField(required=False, allow_blank=True, max_length=120)

    class Meta:
        model = Routine
        fields = [
            'id', 'type', 'type_label', 'custom_name', 'display_name', 'name',
            'target', 'unit', 'days', 'target_day', 'time_of_day',
            'reminder_minutes', 'activation', 'tracking', 'sort_order',
            'streak', 'completed_today', 'last_checkin_at', 'is_active',
            'checkin_count', 'highlights', 'created_at', 'updated_at',
        ]
        read_only_fields = [
            'id', 'streak', 'completed_today', 'last_checkin_at',
            'checkin_count', 'highlights', 'created_at', 'updated_at',
        ]

    def get_type_label(self, obj):
        return dict(Routine.ROUTINE_TYPES).get(obj.type, obj.type)

    def get_checkin_count(self, obj):
        return obj.check_ins.count()

    def get_highlights(self, obj):
        # Only used by the routine detail; the list view keeps the payload
        # small by not loading media for every row.
        if not self.context.get('include_highlights'):
            return []
        return RoutineHighlightSerializer(obj.highlights.all()[:30], many=True).data

    def validate_days(self, value):
        if not isinstance(value, list):
            raise serializers.ValidationError('days must be a list of weekday indexes.')
        cleaned = []
        for day in value:
            try:
                day = int(day)
            except (TypeError, ValueError):
                raise serializers.ValidationError('days must be integers.')
            if day < 0 or day > 6:
                raise serializers.ValidationError('Weekday indexes run 0 (Monday) to 6 (Sunday).')
            if day not in cleaned:
                cleaned.append(day)
        return sorted(cleaned)

    def validate_target_day(self, value):
        if value is None:
            return value
        if value < 0 or value > 6:
            raise serializers.ValidationError('target_day runs 0 (Monday) to 6 (Sunday).')
        return value

    def validate_reminder_minutes(self, value):
        if value is None:
            return []
        if not isinstance(value, list):
            raise serializers.ValidationError('reminder_minutes must be a list of minutes.')
        cleaned = []
        for minute in value:
            try:
                minute = int(minute)
            except (TypeError, ValueError):
                raise serializers.ValidationError('Reminder minutes must be integers.')
            if minute < 0 or minute > 1440:
                raise serializers.ValidationError('Reminder minutes must be between 0 and 1440.')
            if minute not in cleaned:
                cleaned.append(minute)
        return sorted(cleaned)

    def validate(self, attrs):
        routine_type = attrs.get('type') or getattr(self.instance, 'type', None)
        custom_name = attrs.get('custom_name')
        if custom_name is None:
            custom_name = self.instance.custom_name if self.instance else ''
        custom_name = (custom_name or '').strip()

        name = attrs.get('name')
        if name is None:
            name = self.instance.name if self.instance else ''
        name = name.strip()

        if routine_type == 'other' and not custom_name and not name:
            raise serializers.ValidationError({
                'custom_name': 'Name your custom routine.',
            })
        if not name:
            attrs['name'] = custom_name or dict(Routine.ROUTINE_TYPES).get(routine_type, 'Routine')
        return attrs


class RoutineCheckInSerializer(serializers.ModelSerializer):
    class Meta:
        model = RoutineCheckIn
        fields = ['id', 'routine', 'value', 'note', 'source', 'occurred_at', 'created_at']
        read_only_fields = ['id', 'routine', 'created_at']


class RoutineHighlightSerializer(serializers.ModelSerializer):
    class Meta:
        model = RoutineHighlight
        fields = [
            'id', 'routine', 'kind', 'file_url', 'thumbnail_url',
            'caption', 'duration_ms', 'created_at',
        ]
        read_only_fields = ['id', 'routine', 'created_at']


class RoutineReorderSerializer(serializers.Serializer):
    ordered_ids = serializers.ListField(child=serializers.UUIDField(), allow_empty=False)
