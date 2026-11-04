from rest_framework import serializers
from .models import CountdownTemplate, UserCountdown


class CountdownTemplateSerializer(serializers.ModelSerializer):
    class Meta:
        model = CountdownTemplate
        fields = [
            'id', 'code', 'title', 'description', 'unit', 'default_target',
            'icon', 'color', 'is_active', 'sort_order', 'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class UserCountdownSerializer(serializers.ModelSerializer):
    template_detail = CountdownTemplateSerializer(source='template', read_only=True)
    days_since_start = serializers.ReadOnlyField()
    display_reason = serializers.ReadOnlyField()
    display_icon = serializers.ReadOnlyField()

    class Meta:
        model = UserCountdown
        fields = [
            'id', 'template', 'template_detail', 'custom_reason', 'countdown_type',
            'unit', 'current_count', 'target_count', 'start_date',
            'last_checkin_at', 'last_auto_advance_at', 'auto_advance_signal',
            'is_active', 'completed_at', 'days_since_start', 'display_reason',
            'display_icon', 'created_at', 'updated_at',
        ]
        read_only_fields = [
            'id', 'current_count', 'last_checkin_at', 'last_auto_advance_at',
            'auto_advance_signal', 'completed_at', 'days_since_start',
            'display_reason', 'display_icon', 'created_at', 'updated_at',
        ]

    def validate(self, attrs):
        template = attrs.get('template') or getattr(self.instance, 'template', None)
        custom_reason = attrs.get('custom_reason') or getattr(self.instance, 'custom_reason', '')
        if not template and not custom_reason:
            raise serializers.ValidationError({
                'custom_reason': 'A custom reason is required when no template is selected.',
            })
        return attrs
