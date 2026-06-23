from rest_framework import serializers
from .models import Gym, GymMembership


class GymSerializer(serializers.ModelSerializer):
    owner_data = serializers.SerializerMethodField()
    membership_role = serializers.SerializerMethodField()
    is_member = serializers.SerializerMethodField()
    active_today = serializers.SerializerMethodField()

    class Meta:
        model = Gym
        fields = [
            'id', 'name', 'handle', 'description', 'logo_url', 'cover_url',
            'category', 'access_type', 'subscription_type',
            'monthly_fee_artifacts', 'join_fee_artifacts',
            'is_verified', 'rules', 'tags', 'member_count', 'active_today',
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
        return 0


class CreateGymSerializer(serializers.ModelSerializer):
    class Meta:
        model = Gym
        fields = [
            'name', 'handle', 'description', 'category', 'access_type',
            'subscription_type', 'monthly_fee_artifacts', 'join_fee_artifacts',
            'rules', 'tags', 'location_city', 'location_country',
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


class JoinRequestSerializer(serializers.Serializer):
    message = serializers.CharField(max_length=200, required=False, allow_blank=True)
