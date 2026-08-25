from rest_framework import serializers
from django.db.models import Q
from .models import Profile, BuddyRelationship, FollowRelationship, BlockRelationship
from apps.gyms.models import GymMembership


class ProfileSerializer(serializers.ModelSerializer):
    buddy_count = serializers.SerializerMethodField()
    following_count = serializers.SerializerMethodField()
    follower_count = serializers.SerializerMethodField()
    gym_count = serializers.SerializerMethodField()
    post_count = serializers.SerializerMethodField()
    is_buddy = serializers.SerializerMethodField()
    is_following = serializers.SerializerMethodField()
    buddy_status = serializers.SerializerMethodField()
    is_blocked = serializers.SerializerMethodField()

    class Meta:
        model = Profile
        fields = [
            'user_id', 'username', 'display_name', 'bio', 'avatar_url', 'cover_url',
            'pronouns', 'location_city', 'location_country', 'role',
            'verification_status', 'privacy_level', 'streak_days',
            'artifact_balance', 'external_link', 'content_rating',
            'workout_schedule',
            'show_active_status', 'is_anonymous_posting',
            'onboarding_completed', 'terms_accepted_at', 'marketing_consent',
            'buddy_count', 'following_count', 'follower_count', 'gym_count', 'post_count',
            'is_buddy', 'is_following', 'buddy_status', 'is_blocked',
            'creator_balance', 'creator_display_name',
            'created_at', 'updated_at',
        ]
        read_only_fields = ['user_id', 'streak_days', 'artifact_balance', 'creator_balance', 'created_at', 'updated_at']

    def get_buddy_count(self, obj):
        return BuddyRelationship.objects.filter(
            (Q(from_user=obj) | Q(to_user=obj)),
            status='confirmed'
        ).count()

    def get_following_count(self, obj):
        return FollowRelationship.objects.filter(follower=obj).count()

    def get_follower_count(self, obj):
        return FollowRelationship.objects.filter(followee=obj).count()

    def get_gym_count(self, obj):
        return GymMembership.objects.filter(member=obj, subscription_active=True).count()

    def get_post_count(self, obj):
        return 0

    def _get_request_user(self):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return request.user.profile
        return None

    def get_is_buddy(self, obj):
        viewer = self._get_request_user()
        if not viewer or viewer == obj:
            return False
        return BuddyRelationship.objects.filter(
            (Q(from_user=viewer, to_user=obj) |
             Q(from_user=obj, to_user=viewer)),
            status='confirmed'
        ).exists()

    def get_is_following(self, obj):
        viewer = self._get_request_user()
        if not viewer or viewer == obj:
            return False
        return FollowRelationship.objects.filter(follower=viewer, followee=obj).exists()

    def get_buddy_status(self, obj):
        viewer = self._get_request_user()
        if not viewer or viewer == obj:
            return None
        try:
            br = BuddyRelationship.objects.get(
                (Q(from_user=viewer, to_user=obj) |
                 Q(from_user=obj, to_user=viewer))
            )
            return br.status
        except BuddyRelationship.DoesNotExist:
            return None

    def get_is_blocked(self, obj):
        viewer = self._get_request_user()
        if not viewer:
            return False
        if viewer == obj:
            return False
        return BlockRelationship.objects.filter(
            (Q(blocker=viewer, blocked=obj) |
             Q(blocker=obj, blocked=viewer))
        ).exists()


class ProfileUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Profile
        fields = [
            'display_name', 'bio', 'avatar_url', 'cover_url', 'pronouns',
            'location_city', 'location_country', 'external_link',
            'content_rating',
            'workout_schedule', 'show_active_status', 'is_anonymous_posting',
            'privacy_level', 'creator_display_name',
        ]


class OnboardingSerializer(serializers.Serializer):
    primary_goal = serializers.MultipleChoiceField(choices=[
        'weight_loss', 'muscle_gain', 'endurance', 'flexibility',
        'general_wellness', 'nutrition', 'sports_performance',
        'rehabilitation', 'mental_health',
    ])
    activity_level = serializers.ChoiceField(choices=[
        'sedentary', 'lightly_active', 'moderately_active', 'very_active', 'athlete',
    ])
    preferred_workouts = serializers.MultipleChoiceField(choices=[
        'weights', 'cardio', 'hiit', 'yoga', 'pilates', 'crossfit',
        'martial_arts', 'swimming', 'running', 'cycling', 'other',
    ])
    dietary_preference = serializers.ChoiceField(choices=[
        'none', 'vegan', 'vegetarian', 'keto', 'paleo', 'halal', 'kosher',
        'gluten_free', 'other',
    ])
    preferred_time = serializers.ChoiceField(choices=[
        'early_morning', 'morning', 'afternoon', 'evening', 'night', 'flexible',
    ])
    discovery_source = serializers.CharField(max_length=100, required=False, allow_blank=True)
    # Consent — required; recorded on the profile with a version + timestamp.
    terms_version = serializers.CharField(max_length=20, min_length=3)
    marketing_consent = serializers.BooleanField(required=False, default=False)
    # Profile essentials collected during onboarding.
    display_name = serializers.CharField(min_length=2, max_length=50, required=False)
    username = serializers.RegexField(
        r'^[a-zA-Z0-9_]{3,30}$', required=False,
        error_messages={'invalid': '3–30 characters; letters, numbers and underscores only.'},
    )
    location_city = serializers.CharField(max_length=100, required=False, allow_blank=True)
    bio = serializers.CharField(max_length=200, required=False, allow_blank=True)


class BuddyRequestSerializer(serializers.Serializer):
    username = serializers.CharField(max_length=30)


class PingMessageSerializer(serializers.Serializer):
    message = serializers.CharField(
        max_length=100, required=False, allow_blank=True,
        default="How's your workout going? 💪",
    )


class ProfileSearchSerializer(serializers.Serializer):
    q = serializers.CharField(max_length=200, required=False, allow_blank=True)
    role = serializers.ChoiceField(choices=Profile.ROLE_CHOICES, required=False)
    location = serializers.CharField(max_length=100, required=False, allow_blank=True)
