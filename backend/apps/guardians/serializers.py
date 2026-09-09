from rest_framework import serializers


def _person(user):
    """{username, display_name, avatar_url} for a User via its Profile."""
    try:
        profile = user.profile
    except Exception:  # noqa: BLE001 — profiles are provisioned lazily
        profile = None
    return {
        'username': profile.username if profile else '',
        'display_name': profile.display_name if profile else '',
        'avatar_url': profile.avatar_url if profile else '',
    }


class GuardianLinkSerializer(serializers.Serializer):
    id = serializers.IntegerField(read_only=True)
    role = serializers.SerializerMethodField()
    status = serializers.CharField(read_only=True)
    invite_email = serializers.EmailField(read_only=True)
    permissions = serializers.JSONField(read_only=True)
    created_at = serializers.DateTimeField(read_only=True)
    accepted_at = serializers.DateTimeField(read_only=True)
    teen = serializers.SerializerMethodField()
    guardian = serializers.SerializerMethodField()
    hard_deletion_scheduled = serializers.SerializerMethodField()

    def get_role(self, obj):
        request = self.context.get('request')
        if request is not None and obj.teen_id == request.user.id:
            return 'teen'
        return 'guardian'

    def get_teen(self, obj):
        return _person(obj.teen)

    def get_guardian(self, obj):
        return _person(obj.guardian)

    def get_hard_deletion_scheduled(self, obj):
        return obj.teen.hard_delete_at.isoformat() if obj.teen.hard_delete_at else None


class GuardianInviteInputSerializer(serializers.Serializer):
    teen_email = serializers.EmailField()
    teen_name = serializers.CharField(
        max_length=50, required=False, allow_blank=True, default='',
    )
    teen_dob = serializers.DateField(
        input_formats=['%Y-%m-%d'], required=False, allow_null=True, default=None,
    )


class GuardianPermissionsInputSerializer(serializers.Serializer):
    allow_direct_messages = serializers.BooleanField(required=False)
    allow_spends = serializers.BooleanField(required=False)


class GuardianAcceptInviteInputSerializer(serializers.Serializer):
    invite_token = serializers.CharField()
    new_password = serializers.CharField(min_length=1)
