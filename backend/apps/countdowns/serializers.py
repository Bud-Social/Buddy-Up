from rest_framework import serializers
from .models import CountdownEvent, CountdownTemplate, UserCountdown, Routine
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
    class Meta:
        model = Routine
        fields = [
            'id', 'type', 'name', 'target', 'unit', 'days', 'streak',
            'completed_today', 'is_active', 'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']
