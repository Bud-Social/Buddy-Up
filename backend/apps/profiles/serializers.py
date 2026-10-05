from rest_framework import serializers
from django.db.models import Q
from .models import (
    Profile, BuddyRelationship, FollowRelationship, BlockRelationship,
    BuddySearchProfile,
)
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
    # Interests/goals live on the user's preferences JSON — surfaced so other
    # members can see them (profile pages, discover cards) for buddy matching.
    preferences = serializers.SerializerMethodField()

    class Meta:
        model = Profile
        fields = [
            'user_id', 'username', 'display_name', 'bio', 'avatar_url', 'cover_url',
            'pronouns', 'location_city', 'location_country', 'role',
            'verification_status', 'privacy_level', 'streak_days',
            'artifact_balance', 'external_link', 'content_rating',
            'workout_schedule', 'preferences',
            'show_active_status', 'is_anonymous_posting',
            'onboarding_completed', 'terms_accepted_at', 'marketing_consent',
            'buddy_count', 'following_count', 'follower_count', 'gym_count', 'post_count',
            'is_buddy', 'is_following', 'buddy_status', 'is_blocked',
            'creator_balance', 'creator_display_name',
            'created_at', 'updated_at',
        ]
        read_only_fields = ['user_id', 'streak_days', 'artifact_balance', 'creator_balance', 'created_at', 'updated_at']

    def to_representation(self, instance):
        """Absolutise media URLs so clients never resolve '/media/…'
        against their own origin (Vercel) — a guaranteed 404."""
        from common.utils import absolute_media_url
        data = super().to_representation(instance)
        request = self.context.get('request')
        for field in ('avatar_url', 'cover_url'):
            if data.get(field):
                data[field] = absolute_media_url(request, data[field])
        return data

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

    def get_preferences(self, obj):
        prefs = getattr(obj.user, 'preferences', None) or {}
        # Only expose the interest-related keys, never anything sensitive.
        allowed = ('primary_goal', 'activity_level', 'preferred_workouts',
                   'dietary_preference', 'preferred_time', 'custom_interests')
        return {k: prefs[k] for k in allowed if k in prefs}


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


# Canonical onboarding vocabularies plus the aliases clients have shipped
# (Flutter display labels, older snake_case variants). Both forms are accepted
# and normalized to the canonical values before storage.
_GOAL_ALIASES = {
    'lose_weight': 'weight_loss', 'build_muscle': 'muscle_gain',
    'improve_endurance': 'endurance', 'general_fitness': 'general_wellness',
    'fitness': 'general_wellness',
}
_LEVEL_ALIASES = {'extremely_active': 'athlete', 'extreme': 'athlete'}
_WORKOUT_ALIASES = {
    'weightlifting': 'weights', 'weight_training': 'weights',
    'boxing': 'martial_arts', 'dance': 'other',
    'calisthenics': 'other', 'hike': 'hiking', 'stroll': 'walk',
    'dog_walk': 'walk',
}
_DIET_ALIASES = {'mediterranean': 'other', 'no_preference': 'none'}
_TIME_ALIASES = {'late_night': 'night', 'anytime': 'flexible'}


def _normalize_onboarding_value(raw, aliases):
    """Casefold/snake-case a client value, then map known aliases to canonical."""
    value = str(raw).strip().casefold().replace('-', '_').replace(' ', '_')
    value = aliases.get(value, value)
    return value


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
        'martial_arts', 'swimming', 'running', 'cycling', 'walk',
        'hiking', 'gym', 'other',
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
    # Free-text interests ("Other" categories). Persisted inside preferences.
    custom_interests = serializers.CharField(max_length=200, required=False, allow_blank=True)
    # Optional password setup — lets Google/Apple sign-ups also log in with
    # email + password. Only applied when the account has no password yet.
    new_password = serializers.CharField(min_length=8, write_only=True, required=False, allow_blank=True)

    def validate_new_password(self, value):
        if not value:
            return value
        from django.contrib.auth.password_validation import validate_password
        validate_password(value)
        return value

    def to_internal_value(self, data):
        # Accept display labels ("Lose Weight") and alias values
        # ("lose_weight") from any client before field validation runs.
        data = dict(data)
        goal_aliases = {**_GOAL_ALIASES}
        level_aliases = {**_LEVEL_ALIASES}
        workout_aliases = {**_WORKOUT_ALIASES}
        diet_aliases = {**_DIET_ALIASES}
        time_aliases = {**_TIME_ALIASES}

        def squash(value, aliases):
            return _normalize_onboarding_value(value, aliases)

        if 'primary_goal' in data and data['primary_goal'] is not None:
            goals = data['primary_goal']
            if isinstance(goals, str):
                goals = [goals]
            data['primary_goal'] = [squash(g, goal_aliases) for g in goals]
        if 'activity_level' in data and data['activity_level']:
            data['activity_level'] = squash(data['activity_level'], level_aliases)
        if 'preferred_workouts' in data and data['preferred_workouts'] is not None:
            workouts = data['preferred_workouts']
            if isinstance(workouts, str):
                workouts = [workouts]
            data['preferred_workouts'] = [squash(w, workout_aliases) for w in workouts]
        if 'dietary_preference' in data and data['dietary_preference']:
            data['dietary_preference'] = squash(data['dietary_preference'], diet_aliases)
        if 'preferred_time' in data and data['preferred_time']:
            data['preferred_time'] = squash(data['preferred_time'], time_aliases)
        return super().to_internal_value(data)


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


class BuddySearchProfileSerializer(serializers.ModelSerializer):
    # Opt-in DOB (YYYY-MM-DD): hashed + banded, never stored or returned.
    dob = serializers.DateField(write_only=True, required=False)

    class Meta:
        model = BuddySearchProfile
        fields = [
            'intents', 'custom_intent', 'modes', 'bio', 'goals',
            'age_band', 'photos', 'neighbourhood',
            'latitude', 'longitude', 'location_updated_at',
            'search_radius_km', 'available_now', 'available_until', 'pace',
            'visibility', 'incognito', 'dob',
            'created_at', 'updated_at',
        ]
        read_only_fields = ['age_band', 'location_updated_at', 'created_at', 'updated_at']

    def validate_intents(self, value):
        allowed = set(BuddySearchProfile.INTENT_CHOICES)
        bad = [v for v in (value or []) if v not in allowed]
        if bad:
            raise serializers.ValidationError(f'Unknown intents: {bad}')
        return value

    def validate_modes(self, value):
        allowed = set(BuddySearchProfile.MODE_CHOICES)
        bad = [v for v in (value or []) if v not in allowed]
        if bad:
            raise serializers.ValidationError(f'Unknown modes: {bad}')
        return value

    def validate_visibility(self, value):
        allowed = [c[0] for c in BuddySearchProfile.VISIBILITY_CHOICES]
        if value not in allowed:
            raise serializers.ValidationError(f'Choose from {allowed}.')
        return value

    def validate_photos(self, value):
        photos = value or []
        if len(photos) > 4:
            raise serializers.ValidationError('Up to 4 search profile photos.')
        return photos

    def validate(self, attrs):
        if 'other' in (attrs.get('intents') or []) and not (attrs.get('custom_intent') or getattr(self.instance, 'custom_intent', '')):
            raise serializers.ValidationError({'custom_intent': 'Describe what you are looking for.'})
        dob = attrs.pop('dob', None)
        if dob is not None:
            from datetime import date as _date
            from common.utils import age_band_label, calculate_age, hash_dob
            age = calculate_age(dob)
            if age < 16:
                raise serializers.ValidationError({'dob': 'Must be 16 or older.'})
            attrs['dob_hash'] = hash_dob(dob)
            attrs['age_band'] = age_band_label(age)
        return attrs
