from rest_framework import viewsets, mixins, status
from rest_framework.decorators import action
from rest_framework.permissions import IsAdminUser, IsAuthenticated
from rest_framework.response import Response
from django.utils import timezone

from .models import VerificationDocument, VerificationSubmission
from .serializers import (
    VerificationDocumentSerializer, VerificationSubmissionSerializer,
    VerificationReviewSerializer,
)


class VerificationDocumentViewSet(
    mixins.CreateModelMixin,
    mixins.RetrieveModelMixin,
    mixins.ListModelMixin,
    viewsets.GenericViewSet,
):
    queryset = VerificationDocument.objects.all()
    serializer_class = VerificationDocumentSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        qs = super().get_queryset()
        if not self.request.user.is_staff:
            qs = qs.filter(profile__user=self.request.user)
        return qs

    def perform_create(self, serializer):
        serializer.save(profile=self.request.user.profile)


class VerificationSubmissionViewSet(
    mixins.CreateModelMixin,
    mixins.RetrieveModelMixin,
    mixins.ListModelMixin,
    viewsets.GenericViewSet,
):
    queryset = VerificationSubmission.objects.prefetch_related('documents').all()
    serializer_class = VerificationSubmissionSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        qs = super().get_queryset()
        if not self.request.user.is_staff:
            qs = qs.filter(profile__user=self.request.user)
        return qs

    def perform_create(self, serializer):
        profile = self.request.user.profile
        submission = serializer.save(profile=profile, status='draft')
        document_ids = serializer.validated_data.get('document_ids', [])
        if document_ids:
            docs = VerificationDocument.objects.filter(
                id__in=document_ids, profile=profile,
            )
            submission.documents.add(*docs)

    @action(detail=True, methods=['post'])
    def submit(self, request, pk=None):
        submission = self.get_object()
        if submission.profile.user != request.user:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        if submission.status != 'draft':
            return Response({'detail': 'Already submitted.'}, status=status.HTTP_400_BAD_REQUEST)

        submission.status = 'submitted'
        submission.submitted_at = timezone.now()
        submission.save(update_fields=['status', 'submitted_at'])

        submission.documents.filter(status='pending').update(status='pending')
        return Response(VerificationSubmissionSerializer(submission).data)

    @action(detail=True, methods=['post'], permission_classes=[IsAdminUser])
    def review(self, request, pk=None):
        submission = self.get_object()
        serializer = VerificationReviewSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        action = serializer.validated_data['action']
        now = timezone.now()

        if action == 'approve':
            submission.status = 'approved'
            profile = submission.profile
            if submission.verification_type == 'id':
                profile.verification_status = 'id'
            elif submission.verification_type == 'trainer':
                profile.verification_status = 'trainer'
            elif submission.verification_type == 'practitioner':
                profile.verification_status = 'practitioner'
            profile.save(update_fields=['verification_status'])

            doc_ids = serializer.validated_data.get('document_ids', [])
            docs = submission.documents.all()
            if doc_ids:
                docs = docs.filter(id__in=doc_ids)
            docs.update(status='approved', reviewed_by=request.user, reviewed_at=now)

        elif action == 'reject':
            submission.status = 'rejected'
            rejection_reason = serializer.validated_data.get('rejection_reason', '')
            doc_ids = serializer.validated_data.get('document_ids', [])
            docs = submission.documents.all()
            if doc_ids:
                docs = docs.filter(id__in=doc_ids)
            docs.update(
                status='rejected', rejection_reason=rejection_reason,
                reviewed_by=request.user, reviewed_at=now,
            )

        submission.reviewed_by = request.user
        submission.reviewed_at = now
        submission.save(update_fields=['status', 'reviewed_by', 'reviewed_at'])

        return Response(VerificationSubmissionSerializer(submission).data)
