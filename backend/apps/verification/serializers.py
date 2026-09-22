from rest_framework import serializers

from apps.gyms.models import Gym
from .models import VerificationDocument, VerificationSubmission


def _is_internal_file_ref(file_url):
    """True when file_url references our own storage instead of a public URL."""
    return bool(file_url) and not file_url.startswith(('http://', 'https://'))


class VerificationDocumentSerializer(serializers.ModelSerializer):
    # Legacy field kept for compatibility. New uploads store an internal
    # storage reference which is never directly fetchable — the value points
    # at the access-audited retrieve endpoint instead.
    file_url = serializers.SerializerMethodField()

    class Meta:
        model = VerificationDocument
        fields = ['id', 'profile', 'document_type', 'file_url', 'status',
                   'rejection_reason', 'reviewed_at', 'expires_at',
                   'purge_after', 'purged_at', 'created_at']
        read_only_fields = ['id', 'profile', 'status', 'rejection_reason',
                            'reviewed_at', 'purge_after', 'purged_at', 'created_at']

    def get_file_url(self, obj):
        if _is_internal_file_ref(obj.file_url):
            return f'/api/v1/verification/documents/{obj.id}/'
        return obj.file_url or ''


class VerificationSubmissionSerializer(serializers.ModelSerializer):
    documents = VerificationDocumentSerializer(many=True, read_only=True)
    document_ids = serializers.ListField(
        child=serializers.UUIDField(), write_only=True, required=False,
    )
    gym = serializers.PrimaryKeyRelatedField(
        queryset=Gym.objects.all(), required=False, allow_null=True,
    )
    gym_handle = serializers.CharField(write_only=True, required=False, allow_blank=True)
    gym_name = serializers.CharField(source='gym.name', read_only=True)

    class Meta:
        model = VerificationSubmission
        fields = ['id', 'profile', 'verification_type', 'status', 'documents',
                   'document_ids', 'notes', 'gym', 'gym_handle', 'gym_name',
                   'reviewed_by', 'reviewed_at',
                   'submitted_at', 'created_at',
                   'current_step', 'completed_steps', 'face_match_status',
                   'face_match_score',
                   'credential_title', 'credential_issuer', 'credential_id',
                   'issued_date', 'scope_of_practice']
        read_only_fields = ['id', 'profile', 'status', 'documents',
                            'reviewed_by', 'reviewed_at', 'created_at',
                            'current_step', 'completed_steps', 'face_match_status',
                            'face_match_score']

    def validate(self, attrs):
        verification_type = attrs.get(
            'verification_type', getattr(self.instance, 'verification_type', None),
        )
        handle = (attrs.pop('gym_handle', '') or '').strip()
        gym = attrs.get('gym')
        if handle:
            if verification_type != 'gym':
                raise serializers.ValidationError(
                    {'gym_handle': 'Gym handle only applies to gym verification.'},
                )
            try:
                gym = Gym.objects.get(handle__iexact=handle)
            except Gym.DoesNotExist:
                raise serializers.ValidationError(
                    {'gym_handle': 'No gym found with that handle.'},
                )
            attrs['gym'] = gym
        if gym is not None and verification_type != 'gym':
            raise serializers.ValidationError(
                {'gym': 'Gym link only applies to gym verification.'},
            )
        return attrs


class VerificationReviewSerializer(serializers.Serializer):
    action = serializers.ChoiceField(choices=['approve', 'reject'])
    rejection_reason = serializers.CharField(required=False, allow_blank=True, max_length=500)
    document_ids = serializers.ListField(
        child=serializers.UUIDField(), required=False,
    )
