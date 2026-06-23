from rest_framework import serializers
from .models import BuddyLive


class BuddyLiveSerializer(serializers.ModelSerializer):
    host_data = serializers.SerializerMethodField()
    viewer_count = serializers.SerializerMethodField()
    is_joined = serializers.SerializerMethodField()

    class Meta:
        model = BuddyLive
        fields = [
            'id', 'title', 'live_type', 'category', 'access', 'artifact_fee',
            'gym_id', 'status', 'started_at', 'ended_at', 'viewer_peak',
            'replay_url', 'replay_saved', 'co_hosts', 'scheduled_for',
            'is_recurring', 'recurrence_rule', 'equipment_list',
            'host_data', 'viewer_count', 'is_joined',
            'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'status', 'started_at', 'ended_at', 'viewer_peak', 'created_at', 'updated_at']

    def get_host_data(self, obj):
        return {
            'user_id': str(obj.host.user_id),
            'username': obj.host.username,
            'display_name': obj.host.display_name,
            'avatar_url': obj.host.avatar_url,
            'verification_status': obj.host.verification_status,
        }

    def get_viewer_count(self, obj):
        return obj.viewer_peak

    def get_is_joined(self, obj):
        request = self.context.get('request')
        if not (request and request.user.is_authenticated):
            return False
        return False  # TODO: track live viewers in Redis


class CreateLiveSerializer(serializers.ModelSerializer):
    class Meta:
        model = BuddyLive
        fields = [
            'title', 'live_type', 'category', 'access', 'artifact_fee',
            'gym_id', 'co_hosts', 'scheduled_for', 'is_recurring',
            'recurrence_rule', 'equipment_list',
        ]

    def validate_title(self, value):
        if len(value) > 80:
            raise serializers.ValidationError('Title must be 80 characters or fewer.')
        return value


class RandomDropRequestSerializer(serializers.Serializer):
    activity_type = serializers.ChoiceField(choices=[
        'weights', 'cardio', 'hiit', 'yoga', 'pilates', 'crossfit',
        'martial_arts', 'swimming', 'running', 'cycling', 'other',
    ])
    duration = serializers.ChoiceField(choices=[15, 30, 45])
    fee = serializers.ChoiceField(choices=['free', 'dumbbell_1', 'barbell_1'], default='free')
