from rest_framework import serializers
from .models import BuddyLive, LiveAttendee


class EndLiveInputSerializer(serializers.Serializer):
    save_replay = serializers.BooleanField(default=False)


class CoHostInputSerializer(serializers.Serializer):
    username = serializers.CharField()


class RecordingChunkInputSerializer(serializers.Serializer):
    chunk_index = serializers.IntegerField(min_value=0)


class BuddyLiveSerializer(serializers.ModelSerializer):
    host = serializers.SerializerMethodField()
    viewer_count = serializers.SerializerMethodField()
    is_joined = serializers.SerializerMethodField()
    has_rsvped = serializers.SerializerMethodField()
    rsvp_count = serializers.SerializerMethodField()

    class Meta:
        model = BuddyLive
        fields = [
            'id', 'title', 'live_type', 'category', 'access', 'artifact_fee',
            'gym_id', 'status', 'started_at', 'ended_at', 'viewer_peak',
            'replay_url', 'replay_saved', 'co_hosts', 'scheduled_for',
            'is_recurring', 'recurrence_rule', 'equipment_list',
            'host', 'viewer_count', 'is_joined', 'has_rsvped', 'rsvp_count',
            'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'status', 'started_at', 'ended_at', 'viewer_peak', 'created_at', 'updated_at']

    def get_host(self, obj):
        return {
            'user_id': str(obj.host.user_id),
            'username': obj.host.username,
            'display_name': obj.host.display_name,
            'avatar_url': obj.host.avatar_url,
            'verification_status': obj.host.verification_status,
        }

    def get_viewer_count(self, obj):
        return getattr(obj, 'viewer_count_cache', obj.viewer_peak)

    def get_is_joined(self, obj):
        request = self.context.get('request')
        if not (request and request.user.is_authenticated):
            return False
        from django.core.cache import cache
        try:
            return cache.sismember(f'live_viewers:{obj.id}', str(request.user.profile.user_id))
        except (AttributeError, TypeError):
            return False

    def get_has_rsvped(self, obj):
        request = self.context.get('request')
        if not (request and request.user.is_authenticated):
            return False
        return obj.rsvps.filter(user=request.user.profile).exists()

    def get_rsvp_count(self, obj):
        return obj.rsvps.count()


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


class LiveAttendeeSerializer(serializers.ModelSerializer):
    display_name = serializers.CharField(source='user.display_name', read_only=True)
    avatar_url = serializers.URLField(source='user.avatar_url', read_only=True)
    username = serializers.CharField(source='user.username', read_only=True)

    class Meta:
        model = LiveAttendee
        fields = ['id', 'live', 'user', 'role', 'display_name', 'avatar_url', 'username', 'joined_at', 'left_at']
        read_only_fields = ['id', 'joined_at']
