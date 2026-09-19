from rest_framework import serializers

from apps.profiles.models import Profile

from .models import Alarm, AlarmShare, AlarmSound, AlarmSuggestion, usable_sound_ids

MAX_SOUND_BYTES = 2 * 1024 * 1024  # ~30s cap; also enforced client-side.


def profile_summary(profile):
    """Small public card the frontend renders for senders."""
    if profile is None:
        return None
    return {
        'profile_id': str(profile.pk),
        'username': profile.username,
        'display_name': profile.display_name,
        'avatar_url': profile.avatar_url,
    }


class AlarmSoundSerializer(serializers.ModelSerializer):
    # File upload (multipart) or external link (JSON). File takes precedence.
    audio = serializers.FileField(required=False, allow_null=True, write_only=True)
    audio_url = serializers.URLField(required=False, allow_blank=True)
    owner = serializers.PrimaryKeyRelatedField(read_only=True)
    is_mine = serializers.SerializerMethodField()

    class Meta:
        model = AlarmSound
        fields = ['id', 'owner', 'name', 'source', 'audio', 'audio_url',
                  'duration_ms', 'visibility', 'is_mine',
                  'created_at', 'updated_at']
        read_only_fields = ['id', 'owner', 'created_at', 'updated_at']

    def validate_audio(self, value):
        if value is None:
            return value
        content_type = getattr(value, 'content_type', '') or ''
        if not content_type.startswith('audio/'):
            raise serializers.ValidationError('Only audio files are allowed.')
        if value.size > MAX_SOUND_BYTES:
            raise serializers.ValidationError('Audio file too large (max 2 MB).')
        return value

    def validate(self, attrs):
        # File takes precedence over any submitted link.
        if attrs.get('audio'):
            attrs['audio_url'] = ''
        return attrs

    def to_representation(self, instance):
        data = super().to_representation(instance)
        if instance.audio:
            try:
                data['audio_url'] = instance.audio.url
            except (ValueError, AttributeError):
                data['audio_url'] = instance.audio.name or ''
        return data

    def get_is_mine(self, instance):
        request = self.context.get('request')
        profile = getattr(getattr(request, 'user', None), 'profile', None)
        return bool(profile is not None and instance.owner_id == profile.pk)


class AlarmSerializer(serializers.ModelSerializer):
    # <input type="time"> needs HH:MM; the model stores a full TimeField.
    time = serializers.TimeField(format='%H:%M')

    class Meta:
        model = Alarm
        fields = ['id', 'time', 'days_mask', 'label', 'sound',
                  'enabled', 'snooze_minutes', 'created_at', 'updated_at']
        read_only_fields = ['id', 'created_at', 'updated_at']

    def validate_days_mask(self, value):
        if not 0 <= value <= 127:
            raise serializers.ValidationError('days_mask must be between 0 and 127.')
        return value

    def validate_sound(self, value):
        if value is None:
            return value
        request = self.context.get('request')
        if request is None or not request.user.is_authenticated:
            return value
        profile = request.user.profile
        if value.owner_id != profile.pk and value.pk not in usable_sound_ids(profile):
            raise serializers.ValidationError(
                'Sound must be one you own or one a buddy shared with you.',
            )
        return value

    def to_representation(self, instance):
        # Write path takes a sound PK; read path embeds the sound object
        # the AlarmCenter UI renders (name + audio_url).
        data = super().to_representation(instance)
        data['sound'] = (AlarmSoundSerializer(
            instance.sound, context=self.context).data
            if instance.sound_id else None)
        return data


class AlarmShareSerializer(serializers.ModelSerializer):
    sender = serializers.PrimaryKeyRelatedField(read_only=True)
    sound_name = serializers.CharField(source='sound.name', read_only=True)

    class Meta:
        model = AlarmShare
        fields = ['id', 'sound', 'sound_name', 'sender', 'recipient',
                  'status', 'created_at', 'updated_at']
        read_only_fields = ['id', 'sender', 'status', 'created_at', 'updated_at']

    def to_representation(self, instance):
        data = super().to_representation(instance)
        data['sound'] = AlarmSoundSerializer(
            instance.sound, context=self.context).data
        data['sender'] = profile_summary(instance.sender)
        return data


class AlarmSuggestionSerializer(serializers.ModelSerializer):
    sender = serializers.PrimaryKeyRelatedField(read_only=True)
    recipient = serializers.PrimaryKeyRelatedField(read_only=True)
    # Spec'd create payload uses {recipient_profile_id, title, note?, url?}.
    recipient_profile_id = serializers.PrimaryKeyRelatedField(
        queryset=Profile.objects.all(), source='recipient', write_only=True,
    )

    class Meta:
        model = AlarmSuggestion
        fields = ['id', 'sender', 'recipient', 'recipient_profile_id',
                  'title', 'note', 'url', 'status', 'created_at', 'updated_at']
        read_only_fields = ['id', 'sender', 'recipient', 'status',
                            'created_at', 'updated_at']

    def to_representation(self, instance):
        data = super().to_representation(instance)
        data['sender'] = profile_summary(instance.sender)
        return data
