from rest_framework import serializers

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

    class Meta:
        model = VerificationSubmission
        fields = ['id', 'profile', 'verification_type', 'status', 'documents',
                   'document_ids', 'notes', 'reviewed_by', 'reviewed_at',
                   'submitted_at', 'created_at',
                   'current_step', 'completed_steps', 'face_match_status',
                   'face_match_score',
                   'credential_title', 'credential_issuer', 'credential_id',
                   'issued_date', 'scope_of_practice']
        read_only_fields = ['id', 'profile', 'status', 'documents',
                            'reviewed_by', 'reviewed_at', 'created_at',
                            'current_step', 'completed_steps', 'face_match_status',
                            'face_match_score']


class VerificationReviewSerializer(serializers.Serializer):
    action = serializers.ChoiceField(choices=['approve', 'reject'])
    rejection_reason = serializers.CharField(required=False, allow_blank=True, max_length=500)
    document_ids = serializers.ListField(
        child=serializers.UUIDField(), required=False,
    )
