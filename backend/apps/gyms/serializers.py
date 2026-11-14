from rest_framework import serializers
from .models import (
    AttendanceRecord, Gym, GymMembership, GymCategory, GymCategoryPricing,
    GymOnboardingChecklist, JoinRequest, GymInvite, GymRoutinePost, GymReview,
    GymDonation, GymMembershipException, RoutineSlotEnrollment, VenueLocation,
    GymMedia, GymOnlineCoach, GymTrainerEndorsement, RegisteredGymProfile,
)


class GymCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = GymCategory
        fields = ['id', 'name', 'display_name', 'icon', 'is_active']


class GymCategoryPricingSerializer(serializers.ModelSerializer):
    category_name = serializers.CharField(source='category.display_name', read_only=True)

    class Meta:
        model = GymCategoryPricing
        fields = [
            'id', 'category', 'category_name',
            'fee_per_day', 'fee_per_week', 'fee_per_month', 'fee_per_year',
            'is_free',
        ]


class GymSerializer(serializers.ModelSerializer):
    owner_data = serializers.SerializerMethodField()
    membership_role = serializers.SerializerMethodField()
    is_member = serializers.SerializerMethodField()
    active_today = serializers.SerializerMethodField()
    average_rating = serializers.SerializerMethodField()
    review_count = serializers.SerializerMethodField()
    recent_reviewers = serializers.SerializerMethodField()
    categories = GymCategorySerializer(many=True, read_only=True)
    category_pricing = GymCategoryPricingSerializer(many=True, read_only=True)
    delivery_modes = serializers.SerializerMethodField()
    followed_members = serializers.SerializerMethodField()
    followed_members_count = serializers.SerializerMethodField()
    location_summary = serializers.SerializerMethodField()
    registration_status = serializers.SerializerMethodField()
    online_coaches_count = serializers.SerializerMethodField()

    class Meta:
        model = Gym
        fields = [
            'id', 'name', 'handle', 'description', 'logo_url', 'cover_url',
            'category', 'content_rating', 'categories', 'access_type',
            'subscription_type',
            'monthly_fee_artifacts', 'join_fee_artifacts', 'category_pricing',
            'is_verified', 'is_reviews_enabled', 'is_donations_enabled',
            'average_rating', 'review_count', 'recent_reviewers',
            'rules', 'tags', 'member_count', 'active_today',
            'location_city', 'location_country', 'delivery_modes',
            'offers_online_coaching', 'coaching_types', 'online_coaches_count',
            'followed_members', 'followed_members_count', 'location_summary',
            'registration_status',
            'owner_data', 'membership_role', 'is_member',
            'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'member_count', 'is_verified', 'created_at', 'updated_at']

    # ── Followed members ─────────────────────────────────────────────────
    def _followed_ids(self):
        """Profile ids the viewer follows, cached for the whole list.

        One query per response rather than one per gym card.
        """
        cache = self.context.setdefault('_followed_ids', None)
        if cache is not None:
            return cache
        request = self.context.get('request')
        if not (request and request.user.is_authenticated):
            cache = []
        else:
            cache = list(
                request.user.profile.following.values_list('followee_id', flat=True)
            )
        self.context['_followed_ids'] = cache
        return cache

    def _followed_member_rows(self, obj):
        cache = self.context.setdefault('_followed_cache', {})
        key = obj.pk
        if key in cache:
            return cache[key]
        followed = self._followed_ids()
        if not followed:
            cache[key] = []
            return []
        memberships = (
            GymMembership.objects
            .filter(gym=obj, subscription_active=True, member_id__in=followed)
            .select_related('member')
            .order_by('-created_at')
        )
        rows = [{
            'user_id': str(m.member.user_id),
            'username': m.member.username,
            'display_name': m.member.display_name,
            'avatar_url': m.member.avatar_url,
        } for m in memberships]
        cache[key] = rows
        return rows

    def get_followed_members(self, obj):
        return self._followed_member_rows(obj)[:5]

    def get_followed_members_count(self, obj):
        return len(self._followed_member_rows(obj))

    # ── Location summary ─────────────────────────────────────────────────
    def _active_venues(self, obj):
        cache = self.context.setdefault('_venue_cache', {})
        key = obj.pk
        if key not in cache:
            cache[key] = [v for v in obj.venues.all() if v.is_active]
        return cache[key]

    def get_location_summary(self, obj):
        venues = self._active_venues(obj)
        cities = []
        for venue in venues:
            city = (venue.city or '').strip()
            if city and city not in cities:
                cities.append(city)
        nearest = self.context.get('distance_km_by_gym', {}).get(str(obj.pk))
        if nearest is None and venues:
            lat = self.context.get('viewer_lat')
            lng = self.context.get('viewer_lng')
            if lat is not None and lng is not None:
                from common.geo import haversine_km
                distances = []
                for venue in venues:
                    if venue.latitude is None or venue.longitude is None:
                        continue
                    try:
                        distances.append(haversine_km(
                            lat, lng, float(venue.latitude), float(venue.longitude),
                        ))
                    except (TypeError, ValueError):
                        continue
                nearest = min(distances) if distances else None
        return {
            'has_physical': bool(venues),
            'venue_count': len(venues),
            'cities': cities[:3],
            'nearest_km': round(nearest, 1) if nearest is not None else None,
        }

    def get_registration_status(self, obj):
        try:
            return obj.registered_profile.status
        except RegisteredGymProfile.DoesNotExist:
            return 'unverified'

    def get_online_coaches_count(self, obj):
        return obj.online_coaches.filter(is_available=True).count()

    def get_delivery_modes(self, obj):
        has_physical = getattr(obj, 'has_physical', None)
        has_virtual = getattr(obj, 'has_virtual', None)
        if has_physical is None:
            has_physical = obj.venues.filter(is_active=True).exists()
        if has_virtual is None:
            has_virtual = obj.routine_posts.filter(
                location_mode__in=['online', 'hybrid'],
            ).exists()
        modes = []
        if has_physical:
            modes.append('physical')
        if has_virtual:
            modes.append('virtual')
        if has_physical and has_virtual:
            modes.append('hybrid')
        return modes

    def _viewer_is_member(self, obj):
        """True when the requesting viewer holds an active membership here.

        Rosters (owners, reviewers) are member-only for non-public gyms;
        `member_count` stays visible to everyone as the count signal.
        """
        request = self.context.get('request')
        if not (request and request.user.is_authenticated):
            return False
        return GymMembership.objects.filter(
            gym=obj, member=request.user.profile, subscription_active=True
        ).exists()

    def _roster_visible(self, obj):
        # Public gyms intentionally expose their roster; private/secret ones
        # only ever expose it to active members.
        if obj.access_type == 'public':
            return True
        return self._viewer_is_member(obj)

    def get_owner_data(self, obj):
        if not self._roster_visible(obj):
            return []
        owners = GymMembership.objects.filter(gym=obj, role__in=['owner', 'co_owner']).select_related('member')
        return [{
            'user_id': str(om.member.user_id),
            'username': om.member.username,
            'display_name': om.member.display_name,
            'avatar_url': om.member.avatar_url,
            'role': om.role,
        } for om in owners]

    def get_membership_role(self, obj):
        request = self.context.get('request')
        if not (request and request.user.is_authenticated):
            return None
        try:
            membership = GymMembership.objects.get(gym=obj, member=request.user.profile)
            return membership.role
        except GymMembership.DoesNotExist:
            return None

    def get_is_member(self, obj):
        request = self.context.get('request')
        if not (request and request.user.is_authenticated):
            return False
        return GymMembership.objects.filter(
            gym=obj, member=request.user.profile, subscription_active=True
        ).exists()

    def get_active_today(self, obj):
        from .models import RoutineSlotEnrollment
        return RoutineSlotEnrollment.objects.filter(
            routine_post__gym=obj, is_active=True
        ).values('member').distinct().count()

    def get_average_rating(self, obj):
        from django.db.models import Avg
        if not obj.is_reviews_enabled:
            return 0
        avg = obj.reviews.aggregate(Avg('rating'))['rating__avg']
        return round(avg, 1) if avg else 0

    def get_review_count(self, obj):
        return obj.reviews.count()

    def get_recent_reviewers(self, obj):
        if not self._roster_visible(obj):
            return []
        recent = obj.reviews.select_related('reviewer').order_by('-created_at')[:3]
        return [{
            'user_id': str(r.reviewer.user_id),
            'username': r.reviewer.username,
            'display_name': r.reviewer.display_name,
            'avatar_url': r.reviewer.avatar_url,
        } for r in recent]


class GymDetailSerializer(GymSerializer):
    """Gym payload with the heavier detail-only collections."""

    gallery = serializers.SerializerMethodField()
    online_coaches = serializers.SerializerMethodField()

    class Meta(GymSerializer.Meta):
        fields = GymSerializer.Meta.fields + ['gallery', 'online_coaches']

    def get_gallery(self, obj):
        rows = obj.media.all()[:12]
        return [{
            'id': str(item.id),
            'kind': item.kind,
            'file_url': item.file_url,
            'thumbnail_url': item.thumbnail_url,
            'caption': item.caption,
        } for item in rows]

    def get_online_coaches(self, obj):
        rows = obj.online_coaches.select_related('coach').all()[:20]
        return [{
            'id': str(row.id),
            'user_id': str(row.coach.user_id),
            'username': row.coach.username,
            'display_name': row.coach.display_name,
            'avatar_url': row.coach.avatar_url,
            'verification_status': row.coach.verification_status,
            'specialties': row.specialties or [],
            'is_available': row.is_available,
            'note': row.note,
        } for row in rows]


class CategoryPricingInputSerializer(serializers.Serializer):
    category = serializers.IntegerField()
    fee_per_day = serializers.DecimalField(max_digits=10, decimal_places=2, required=False, allow_null=True)
    fee_per_week = serializers.DecimalField(max_digits=10, decimal_places=2, required=False, allow_null=True)
    fee_per_month = serializers.DecimalField(max_digits=10, decimal_places=2, required=False, allow_null=True)
    fee_per_year = serializers.DecimalField(max_digits=10, decimal_places=2, required=False, allow_null=True)
    is_free = serializers.BooleanField(default=False)


class CreateGymSerializer(serializers.ModelSerializer):
    category_ids = serializers.ListField(
        child=serializers.IntegerField(), write_only=True, required=False
    )
    category_pricing = CategoryPricingInputSerializer(many=True, required=False)

    class Meta:
        model = Gym
        fields = [
            'name', 'handle', 'description', 'category', 'content_rating',
            'category_ids', 'logo_url', 'cover_url',
            'access_type', 'subscription_type',
            'monthly_fee_artifacts', 'join_fee_artifacts',
            'rules', 'tags', 'location_city', 'location_country',
            'offers_online_coaching', 'coaching_types',
            'category_pricing',
        ]

    def validate_name(self, value):
        if len(value) < 3 or len(value) > 60:
            raise serializers.ValidationError('Gym name must be between 3 and 60 characters.')
        if Gym.objects.filter(name__iexact=value).exists():
            raise serializers.ValidationError('A gym with this name already exists.')
        return value

    def validate_handle(self, value):
        if len(value) < 3 or len(value) > 60:
            raise serializers.ValidationError('Handle must be between 3 and 60 characters.')
        if not value.replace('_', '').isalnum():
            raise serializers.ValidationError('Handle may only contain letters, numbers, and underscores.')
        if Gym.objects.filter(handle__iexact=value).exists():
            raise serializers.ValidationError('This handle is already taken.')
        return value.lower()

    category = serializers.CharField(required=False, allow_blank=True, default='')

    def validate_category_pricing(self, value):
        if not value:
            return value
        for entry in value:
            if not entry.get('is_free') and not any([
                entry.get('fee_per_day'), entry.get('fee_per_week'),
                entry.get('fee_per_month'), entry.get('fee_per_year'),
            ]):
                raise serializers.ValidationError(
                    'Each pricing entry must have at least one fee or be marked as free.'
                )
        return value

    def create(self, validated_data):
        category_ids = validated_data.pop('category_ids', [])
        pricing_data = validated_data.pop('category_pricing', [])
        category = validated_data.pop('category', '')
        derived = ','.join(
            GymCategory.objects.filter(id__in=category_ids).values_list('name', flat=True)
        ) or category or 'other'
        validated_data['category'] = derived
        gym = Gym.objects.create(**validated_data)
        if category_ids:
            valid_ids = GymCategory.objects.filter(id__in=category_ids, is_active=True).values_list('id', flat=True)
            gym.categories.set(valid_ids)
        valid_category_ids = set(GymCategory.objects.values_list('id', flat=True))
        for entry in pricing_data:
            cat_id = entry.get('category')
            if cat_id in valid_category_ids:
                GymCategoryPricing.objects.create(gym=gym, **entry)
        return gym


class GymMembershipSerializer(serializers.ModelSerializer):
    member_data = serializers.SerializerMethodField()

    class Meta:
        model = GymMembership
        fields = ['id', 'gym_id', 'member_id', 'role', 'subscription_active',
                   'subscription_expires_at', 'member_data', 'created_at']
        read_only_fields = ['id', 'created_at']

    def get_member_data(self, obj):
        return {
            'user_id': str(obj.member.user_id),
            'username': obj.member.username,
            'display_name': obj.member.display_name,
            'avatar_url': obj.member.avatar_url,
            'verification_status': obj.member.verification_status,
        }


class JoinRequestSerializer(serializers.ModelSerializer):
    requester_data = serializers.SerializerMethodField()

    class Meta:
        model = JoinRequest
        fields = ['id', 'gym_id', 'requester', 'requester_data', 'message',
                   'status', 'reviewed_by', 'reviewed_at', 'created_at']
        read_only_fields = ['id', 'gym_id', 'status', 'reviewed_by', 'reviewed_at', 'created_at']

    def get_requester_data(self, obj):
        return {
            'user_id': str(obj.requester.user_id),
            'username': obj.requester.username,
            'display_name': obj.requester.display_name,
            'avatar_url': obj.requester.avatar_url,
        }


class CreateJoinRequestSerializer(serializers.ModelSerializer):
    class Meta:
        model = JoinRequest
        fields = ['message']
        extra_kwargs = {'message': {'required': False, 'allow_blank': True}}


class ApproveRejectSerializer(serializers.Serializer):
    status = serializers.ChoiceField(choices=['approved', 'rejected'])


class GymInviteSerializer(serializers.ModelSerializer):
    invited_user_data = serializers.SerializerMethodField()
    invited_by_data = serializers.SerializerMethodField()

    class Meta:
        model = GymInvite
        fields = ['id', 'gym_id', 'invited_user', 'invited_user_data',
                   'invited_by', 'invited_by_data', 'status', 'created_at']
        read_only_fields = ['id', 'gym_id', 'invited_by', 'status', 'created_at']

    def get_invited_user_data(self, obj):
        return {
            'user_id': str(obj.invited_user.user_id),
            'username': obj.invited_user.username,
            'display_name': obj.invited_user.display_name,
            'avatar_url': obj.invited_user.avatar_url,
        }

    def get_invited_by_data(self, obj):
        return {
            'user_id': str(obj.invited_by.user_id),
            'username': obj.invited_by.username,
            'display_name': obj.invited_by.display_name,
        }


class CreateInviteSerializer(serializers.Serializer):
    username = serializers.CharField(max_length=150, required=False, allow_blank=True)
    email = serializers.EmailField(required=False, allow_blank=True)

    def validate(self, data):
        if not data.get('username') and not data.get('email'):
            raise serializers.ValidationError("Either username or email must be provided.")
        return data


class HandleCheckSerializer(serializers.Serializer):
    candidate = serializers.CharField(max_length=60, min_length=3)

    def validate_candidate(self, value):
        if not value.replace('_', '').isalnum():
            raise serializers.ValidationError('Handle may only contain letters, numbers, and underscores.')
        return value.lower()


class GymRoutinePostSerializer(serializers.ModelSerializer):
    author_data = serializers.SerializerMethodField()

    is_enrolled = serializers.SerializerMethodField()
    enrollment_count = serializers.IntegerField(source='slots_taken', read_only=True)

    class Meta:
        model = GymRoutinePost
        fields = ['id', 'gym_id', 'author', 'author_data', 'title', 'content', 
                  'activity_type', 'custom_activity_type', 'location_mode', 
                  'start_time', 'end_time', 'recurrence', 'recurrence_end_date',
                  'recurrence_days', 'max_slots', 'enrollment_count', 'is_enrolled', 'timezone',
                  'linked_live_id', 'created_at']
        read_only_fields = ['id', 'gym_id', 'author', 'created_at']

    def get_is_enrolled(self, obj):
        request = self.context.get('request')
        if not (request and request.user.is_authenticated):
            return False
        return obj.enrollments.filter(member=request.user.profile, is_active=True).exists()

    def get_author_data(self, obj):
        return {
            'user_id': str(obj.author.user_id),
            'username': obj.author.username,
            'display_name': obj.author.display_name,
            'avatar_url': obj.author.avatar_url,
        }


class GymReviewSerializer(serializers.ModelSerializer):
    reviewer_data = serializers.SerializerMethodField()
    replied_by_data = serializers.SerializerMethodField()

    class Meta:
        model = GymReview
        fields = ['id', 'gym_id', 'reviewer', 'reviewer_data', 'rating', 'comment', 
                  'reply_text', 'replied_by', 'replied_by_data', 'replied_at', 'created_at']
        read_only_fields = ['id', 'gym_id', 'reviewer', 'replied_by', 'replied_at', 'created_at']

    def get_reviewer_data(self, obj):
        return {
            'user_id': str(obj.reviewer.user_id),
            'username': obj.reviewer.username,
            'display_name': obj.reviewer.display_name,
            'avatar_url': obj.reviewer.avatar_url,
        }
        
    def get_replied_by_data(self, obj):
        if not obj.replied_by:
            return None
        return {
            'user_id': str(obj.replied_by.user_id),
            'username': obj.replied_by.username,
            'display_name': obj.replied_by.display_name,
            'avatar_url': obj.replied_by.avatar_url,
        }


class GymDonationSerializer(serializers.ModelSerializer):
    donor_data = serializers.SerializerMethodField()

    class Meta:
        model = GymDonation
        fields = ['id', 'gym_id', 'donor', 'donor_data', 'amount', 'message', 'created_at']
        read_only_fields = ['id', 'gym_id', 'donor', 'created_at']

    def get_donor_data(self, obj):
        return {
            'user_id': str(obj.donor.user_id),
            'username': obj.donor.username,
            'display_name': obj.donor.display_name,
            'avatar_url': obj.donor.avatar_url,
        }


class RoutineSlotEnrollmentSerializer(serializers.ModelSerializer):
    member_data = serializers.SerializerMethodField()
    routine_post_data = serializers.SerializerMethodField()

    class Meta:
        model = RoutineSlotEnrollment
        fields = ['id', 'routine_post', 'routine_post_data', 'member_data',
                  'recurrence', 'recurrence_end_date', 'reminder_minutes', 'is_active', 'created_at']
        read_only_fields = ['id', 'member_data', 'routine_post_data', 'created_at']

    def get_member_data(self, obj):
        return {
            'user_id': str(obj.member.user_id),
            'username': obj.member.username,
            'display_name': obj.member.display_name,
            'avatar_url': obj.member.avatar_url,
        }

    def get_routine_post_data(self, obj):
        sp = obj.routine_post
        return {
            'id': str(sp.id),
            'title': sp.title,
            'activity_type': sp.activity_type,
            'start_time': sp.start_time.isoformat() if sp.start_time else None,
        }


class DonationInputSerializer(serializers.Serializer):
    artifact_type = serializers.ChoiceField(choices=['dumbbell', 'barbell', 'burpee', 'squat', 'sprint', 'pr', 'champion'], default='dumbbell')
    quantity = serializers.IntegerField(min_value=1, required=False, allow_null=True)
    message = serializers.CharField(max_length=500, required=False, allow_blank=True, default='')
    amount = serializers.FloatField(min_value=0, default=0)


class ReviewReplyInputSerializer(serializers.Serializer):
    reply_text = serializers.CharField(max_length=1000)


class ManageMemberRoleSerializer(serializers.Serializer):
    role = serializers.ChoiceField(
        choices=['member', 'trainer', 'moderator'], required=False, allow_null=True,
    )


class CreateEnrollmentSerializer(serializers.Serializer):
    recurrence = serializers.ChoiceField(choices=['none', 'weekly', 'monthly', 'yearly'], default='none')
    recurrence_end_date = serializers.DateField(required=False, allow_null=True)
    reminder_minutes = serializers.ListField(child=serializers.IntegerField(min_value=1), default=list)


class GymMembershipExceptionSerializer(serializers.ModelSerializer):
    member_data = serializers.SerializerMethodField()

    class Meta:
        model = GymMembershipException
        fields = ['id', 'gym_id', 'member', 'member_data', 'discount_pct', 'reason',
                  'expires_at', 'is_active', 'created_at']
        read_only_fields = ['id', 'gym_id', 'member', 'created_at']

    def get_member_data(self, obj):
        return {
            'user_id': str(obj.member.user_id),
            'username': obj.member.username,
            'display_name': obj.member.display_name,
            'avatar_url': obj.member.avatar_url,
            'verification_status': obj.member.verification_status,
        }


class CreateMembershipExceptionSerializer(serializers.Serializer):
    member_id = serializers.UUIDField(required=False)
    username = serializers.CharField(max_length=150, required=False, allow_blank=True)
    discount_pct = serializers.IntegerField(min_value=0, max_value=100, default=100)
    reason = serializers.CharField(max_length=200, required=False, allow_blank=True, default='')
    expires_at = serializers.DateTimeField(required=False, allow_null=True)
    is_active = serializers.BooleanField(default=True)

    def validate(self, data):
        if not data.get('member_id') and not data.get('username'):
            raise serializers.ValidationError('Either member_id or username must be provided.')
        return data


class MembershipCheckoutSerializer(serializers.Serializer):
    discount_code = serializers.CharField(max_length=50, required=False, allow_blank=True)


class GymOnboardingChecklistSerializer(serializers.ModelSerializer):
    class Meta:
        model = GymOnboardingChecklist
        fields = ['completed_steps', 'notes', 'completed_at', 'created_at', 'updated_at']
        read_only_fields = ['completed_at', 'created_at', 'updated_at']


class VenueLocationSerializer(serializers.ModelSerializer):
    class Meta:
        model = VenueLocation
        fields = ['id', 'name', 'address', 'city', 'country', 'latitude', 'longitude',
                  'instructions', 'is_primary', 'is_active', 'created_at']
        read_only_fields = ['id', 'created_at']


class AttendanceRecordSerializer(serializers.ModelSerializer):
    member_username = serializers.CharField(source='member.username', read_only=True)

    class Meta:
        model = AttendanceRecord
        fields = ['id', 'member', 'member_username', 'routine_post', 'venue', 'status',
                  'checked_in_at', 'checked_out_at', 'source', 'notes', 'created_at']
        read_only_fields = ['id', 'created_at']


# ---------------------------------------------------------------------------
# Phase A: registration, gallery, online coaching, endorsements
# ---------------------------------------------------------------------------

class GymMediaSerializer(serializers.ModelSerializer):
    uploaded_by_data = serializers.SerializerMethodField()

    class Meta:
        model = GymMedia
        fields = ['id', 'gym_id', 'kind', 'file_url', 'thumbnail_url', 'caption',
                  'uploaded_by_data', 'created_at']
        read_only_fields = ['id', 'gym_id', 'uploaded_by_data', 'created_at']

    def get_uploaded_by_data(self, obj):
        if not obj.uploaded_by:
            return None
        return {
            'user_id': str(obj.uploaded_by.user_id),
            'username': obj.uploaded_by.username,
            'display_name': obj.uploaded_by.display_name,
            'avatar_url': obj.uploaded_by.avatar_url,
        }


class RegisteredGymProfileSerializer(serializers.ModelSerializer):
    gym_id = serializers.UUIDField(read_only=True)
    registration_documents = serializers.SerializerMethodField()

    class Meta:
        model = RegisteredGymProfile
        fields = [
            'id', 'gym_id', 'legal_name', 'registration_number', 'country',
            'tax_id', 'website', 'contact_email', 'contact_phone',
            'status', 'rejection_reason', 'submitted_at', 'reviewed_at',
            'registration_documents', 'created_at', 'updated_at',
        ]
        read_only_fields = [
            'id', 'gym_id', 'status', 'rejection_reason', 'submitted_at',
            'reviewed_at', 'registration_documents', 'created_at', 'updated_at',
        ]

    def get_registration_documents(self, obj):
        from apps.verification.models import VerificationSubmission
        submission = (
            VerificationSubmission.objects
            .filter(gym=obj.gym, verification_type='gym')
            .prefetch_related('documents')
            .order_by('-created_at')
            .first()
        )
        if submission is None:
            return []
        return [{
            'id': str(doc.id),
            'document_type': doc.document_type,
            'status': doc.status,
            'rejection_reason': doc.rejection_reason,
            'created_at': doc.created_at,
        } for doc in submission.documents.all()]


class SubmitRegistrationSerializer(serializers.ModelSerializer):
    """Business metadata written by the gym's owner before review."""

    class Meta:
        model = RegisteredGymProfile
        fields = ['legal_name', 'registration_number', 'country', 'tax_id',
                  'website', 'contact_email', 'contact_phone']

    def validate_legal_name(self, value):
        if not value.strip():
            raise serializers.ValidationError('Legal business name is required.')
        return value.strip()

    def validate_registration_number(self, value):
        value = (value or '').strip()
        if not value:
            raise serializers.ValidationError('Registration number is required.')
        return value


class GymOnlineCoachSerializer(serializers.ModelSerializer):
    coach_data = serializers.SerializerMethodField()

    class Meta:
        model = GymOnlineCoach
        fields = ['id', 'gym_id', 'coach', 'coach_data', 'specialties',
                  'is_available', 'note', 'created_at']
        read_only_fields = ['id', 'gym_id', 'coach', 'coach_data', 'created_at']

    def get_coach_data(self, obj):
        return {
            'user_id': str(obj.coach.user_id),
            'username': obj.coach.username,
            'display_name': obj.coach.display_name,
            'avatar_url': obj.coach.avatar_url,
            'verification_status': obj.coach.verification_status,
        }


class OnlineCoachingUpdateSerializer(serializers.Serializer):
    offers_online_coaching = serializers.BooleanField(required=False)
    coaching_types = serializers.ListField(
        child=serializers.CharField(max_length=40), required=False, default=list,
    )

    def validate_coaching_types(self, value):
        cleaned = []
        for item in value:
            item = (item or '').strip()
            if item and item not in cleaned:
                cleaned.append(item)
        if len(cleaned) > 20:
            raise serializers.ValidationError('At most 20 coaching types.')
        return cleaned


class AddOnlineCoachSerializer(serializers.Serializer):
    username = serializers.CharField(max_length=150, required=False, allow_blank=True)
    user_id = serializers.UUIDField(required=False)
    specialties = serializers.ListField(
        child=serializers.CharField(max_length=40), required=False, default=list,
    )
    is_available = serializers.BooleanField(default=True)
    note = serializers.CharField(max_length=240, required=False, allow_blank=True, default='')

    def validate(self, data):
        if not data.get('username') and not data.get('user_id'):
            raise serializers.ValidationError('Either username or user_id is required.')
        return data


class GymTrainerEndorsementSerializer(serializers.ModelSerializer):
    trainer_data = serializers.SerializerMethodField()

    class Meta:
        model = GymTrainerEndorsement
        fields = ['id', 'gym_id', 'trainer', 'trainer_data', 'note',
                  'is_active', 'created_at']
        read_only_fields = ['id', 'gym_id', 'trainer', 'trainer_data', 'created_at']

    def get_trainer_data(self, obj):
        return {
            'user_id': str(obj.trainer.user_id),
            'username': obj.trainer.username,
            'display_name': obj.trainer.display_name,
            'avatar_url': obj.trainer.avatar_url,
            'verification_status': obj.trainer.verification_status,
        }


class CreateEndorsementSerializer(serializers.Serializer):
    username = serializers.CharField(max_length=150, required=False, allow_blank=True)
    user_id = serializers.UUIDField(required=False)
    verification_type = serializers.ChoiceField(
        choices=['trainer', 'practitioner'], default='trainer',
    )
    note = serializers.CharField(max_length=240, required=False, allow_blank=True, default='')

    def validate(self, data):
        if not data.get('username') and not data.get('user_id'):
            raise serializers.ValidationError('Either username or user_id is required.')
        return data


class GymAnnouncementSerializer(serializers.Serializer):
    title = serializers.CharField(max_length=150)
    body = serializers.CharField(max_length=2000)
    notify_members = serializers.BooleanField(default=True)

