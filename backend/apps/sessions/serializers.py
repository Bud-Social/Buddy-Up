from rest_framework import serializers
from .models import (
    TrainerProfile, Availability, BookingSession, Review, AsyncProgramme, ProgrammeWeek, ProgrammeEnrollment
)


class TrainerProfileSerializer(serializers.ModelSerializer):
    profile_data = serializers.SerializerMethodField()

    class Meta:
        model = TrainerProfile
        fields = ['profile_id', 'specialties', 'certifications', 'years_experience',
                   'languages', 'session_types', 'pricing', 'average_rating',
                   'review_count', 'total_sessions_completed', 'profile_data']

    def get_profile_data(self, obj):
        return {
            'username': obj.profile.username,
            'display_name': obj.profile.display_name,
            'avatar_url': obj.profile.avatar_url,
            'bio': obj.profile.bio,
            'location_city': obj.profile.location_city,
            'location_country': obj.profile.location_country,
            'verification_status': obj.profile.verification_status,
        }


class AvailabilitySerializer(serializers.ModelSerializer):
    class Meta:
        model = Availability
        fields = ['id', 'trainer_id', 'day_of_week', 'start_time', 'end_time',
                   'buffer_minutes', 'is_active']


class BookingSerializer(serializers.ModelSerializer):
    client_data = serializers.SerializerMethodField()
    trainer_data = serializers.SerializerMethodField()

    class Meta:
        model = BookingSession
        fields = ['id', 'client_id', 'trainer_id', 'session_type', 'status',
                   'scheduled_at', 'duration_minutes', 'artifact_fee', 'notes',
                   'client_data', 'trainer_data', 'completed_at', 'cancelled_at',
                   'created_at']

    def get_client_data(self, obj):
        return {
            'username': obj.client.username,
            'display_name': obj.client.display_name,
            'avatar_url': obj.client.avatar_url,
        }

    def get_trainer_data(self, obj):
        return {
            'username': obj.trainer.username,
            'display_name': obj.trainer.display_name,
            'avatar_url': obj.trainer.avatar_url,
            'verification_status': obj.trainer.verification_status,
        }


class CreateBookingSerializer(serializers.Serializer):
    session_type = serializers.ChoiceField(choices=BookingSession.SESSION_TYPES)
    scheduled_at = serializers.DateTimeField()
    duration_minutes = serializers.IntegerField(min_value=15, max_value=180)
    notes = serializers.CharField(max_length=300, required=False, allow_blank=True)


class ReviewSerializer(serializers.ModelSerializer):
    client_data = serializers.SerializerMethodField()

    class Meta:
        model = Review
        fields = ['id', 'session_id', 'client_id', 'trainer_id', 'rating', 'body',
                   'client_data', 'created_at']
        read_only_fields = ['id', 'created_at']

    def get_client_data(self, obj):
        return {
            'username': obj.client.username,
            'display_name': obj.client.display_name,
            'avatar_url': obj.client.avatar_url,
        }


class ProgrammeSerializer(serializers.ModelSerializer):
    trainer_data = serializers.SerializerMethodField()

    class Meta:
        model = AsyncProgramme
        fields = ['id', 'trainer_id', 'title', 'description', 'duration_weeks',
                   'price_artifacts', 'is_active', 'enrolled_count', 'trainer_data',
                   'created_at']

    def get_trainer_data(self, obj):
        return {
            'username': obj.trainer.username,
            'display_name': obj.trainer.display_name,
            'avatar_url': obj.trainer.avatar_url,
        }
