from rest_framework import serializers

from .models import VerificationDocument, VerificationSubmission


class VerificationDocumentSerializer(serializers.ModelSerializer):
    class Meta:
        model = VerificationDocument
        fields = ['id', 'profile', 'document_type', 'file_url', 'status',
                   'rejection_reason', 'reviewed_at', 'expires_at', 'created_at']
        read_only_fields = ['id', 'profile', 'status', 'rejection_reason',
                            'reviewed_at', 'created_at']


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
                   'credential_title', 'credential_issuer', 'credential_id',
                   'issued_date', 'scope_of_practice']
        read_only_fields = ['id', 'profile', 'status', 'documents',
                            'reviewed_by', 'reviewed_at', 'created_at']


class VerificationReviewSerializer(serializers.Serializer):
    action = serializers.ChoiceField(choices=['approve', 'reject'])
    rejection_reason = serializers.CharField(required=False, allow_blank=True, max_length=500)
    document_ids = serializers.ListField(
        child=serializers.UUIDField(), required=False,
    )
