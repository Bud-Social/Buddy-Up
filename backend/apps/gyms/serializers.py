from rest_framework import serializers
from .models import Gym, GymMembership, GymCategory, GymCategoryPricing, JoinRequest, GymInvite, GymSchedulePost, GymReview, GymDonation


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

    class Meta:
        model = Gym
        fields = [
            'id', 'name', 'handle', 'description', 'logo_url', 'cover_url',
            'category', 'categories', 'access_type', 'subscription_type',
            'monthly_fee_artifacts', 'join_fee_artifacts', 'category_pricing',
            'is_verified', 'is_reviews_enabled', 'is_donations_enabled',
            'average_rating', 'review_count', 'recent_reviewers',
            'rules', 'tags', 'member_count', 'active_today',
            'location_city', 'location_country',
            'owner_data', 'membership_role', 'is_member',
            'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'member_count', 'is_verified', 'created_at', 'updated_at']

    def get_owner_data(self, obj):
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
        # mock implementation
        return obj.member_count // 10 if obj.member_count else 0

    def get_average_rating(self, obj):
        from django.db.models import Avg
        if not obj.is_reviews_enabled:
            return 0
        avg = obj.reviews.aggregate(Avg('rating'))['rating__avg']
        return round(avg, 1) if avg else 0

    def get_review_count(self, obj):
        return obj.reviews.count()

    def get_recent_reviewers(self, obj):
        recent = obj.reviews.select_related('reviewer').order_by('-created_at')[:3]
        return [{
            'user_id': str(r.reviewer.user_id),
            'username': r.reviewer.username,
            'display_name': r.reviewer.display_name,
            'avatar_url': r.reviewer.avatar_url,
        } for r in recent]


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
            'name', 'handle', 'description', 'category', 'category_ids',
            'access_type', 'subscription_type',
            'monthly_fee_artifacts', 'join_fee_artifacts',
            'rules', 'tags', 'location_city', 'location_country',
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


class GymSchedulePostSerializer(serializers.ModelSerializer):
    author_data = serializers.SerializerMethodField()

    is_enrolled = serializers.SerializerMethodField()
    enrollment_count = serializers.IntegerField(source='slots_taken', read_only=True)

    class Meta:
        model = GymSchedulePost
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
        from .models import ScheduleSlotEnrollment
        return ScheduleSlotEnrollment.objects.filter(schedule_post=obj, member=request.user.profile, is_active=True).exists()

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


from .models import ScheduleSlotEnrollment

class ScheduleSlotEnrollmentSerializer(serializers.ModelSerializer):
    member_data = serializers.SerializerMethodField()
    schedule_post_data = serializers.SerializerMethodField()

    class Meta:
        model = ScheduleSlotEnrollment
        fields = ['id', 'schedule_post', 'schedule_post_data', 'member_data',
                  'recurrence', 'recurrence_end_date', 'reminder_minutes', 'is_active', 'created_at']
        read_only_fields = ['id', 'member_data', 'schedule_post_data', 'created_at']

    def get_member_data(self, obj):
        return {
            'user_id': str(obj.member.user_id),
            'username': obj.member.username,
            'display_name': obj.member.display_name,
            'avatar_url': obj.member.avatar_url,
        }

    def get_schedule_post_data(self, obj):
        sp = obj.schedule_post
        return {
            'id': str(sp.id),
            'title': sp.title,
            'activity_type': sp.activity_type,
            'start_time': sp.start_time.isoformat() if sp.start_time else None,
        }


class CreateEnrollmentSerializer(serializers.Serializer):
    recurrence = serializers.ChoiceField(choices=['none', 'weekly', 'monthly', 'yearly'], default='none')
    recurrence_end_date = serializers.DateField(required=False, allow_null=True)
    reminder_minutes = serializers.ListField(child=serializers.IntegerField(min_value=1), default=list)
