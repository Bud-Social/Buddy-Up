import logging
import os
import uuid

from django.core.files.storage import default_storage
from django.core.files.base import ContentFile

from rest_framework import viewsets, mixins, status
from rest_framework.decorators import action
from rest_framework.parsers import FormParser, MultiPartParser
from rest_framework.permissions import IsAdminUser, IsAuthenticated
from rest_framework.response import Response
from django.utils import timezone

from .models import VerificationDocument, VerificationSubmission
from .serializers import (
    VerificationDocumentSerializer, VerificationSubmissionSerializer,
    VerificationReviewSerializer,
)
from .services import run_face_match

logger = logging.getLogger(__name__)

ID_FLOW_STEPS = ['id_document', 'selfie_liveness', 'face_match', 'review']
ID_DOC_TYPES = {'id_card', 'passport', 'drivers_license'}


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
        verification_type = serializer.validated_data.get('verification_type')
        # Multistep ID flow starts at step 1; other types have no wizard.
        initial_step = 'id_document' if verification_type == 'id' else ''
        submission = serializer.save(profile=profile, status='draft', current_step=initial_step)
        document_ids = serializer.validated_data.get('document_ids', [])
        if document_ids:
            docs = VerificationDocument.objects.filter(
                id__in=document_ids, profile=profile,
            )
            submission.documents.add(*docs)

    @action(detail=True, methods=['post'])
    def start(self, request, pk=None):
        """(Re)start the multistep ID flow for this draft submission."""
        submission = self.get_object()
        if submission.verification_type != 'id':
            return Response(
                {'detail': 'Multistep flow only applies to ID verification.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        if submission.status != 'draft':
            return Response({'detail': 'Already submitted.'}, status=status.HTTP_400_BAD_REQUEST)
        submission.current_step = 'id_document'
        submission.completed_steps = []
        submission.face_match_status = 'pending'
        submission.face_match_score = None
        submission.save(update_fields=[
            'current_step', 'completed_steps', 'face_match_status', 'face_match_score',
        ])
        return Response(VerificationSubmissionSerializer(submission).data)

    @action(detail=True, methods=['post'], parser_classes=[MultiPartParser, FormParser])
    def upload_step(self, request, pk=None):
        """Upload the artifact for the current wizard step.

        Multipart fields:
        - ``file``: the image (required)
        - ``step``: 'id_document' | 'selfie_liveness' (required)
        - ``document_type``: id_card | passport | drivers_license (ID step only)
        """
        submission = self.get_object()
        if submission.verification_type != 'id' or submission.status != 'draft':
            return Response({'detail': 'Not an active ID verification draft.'}, status=status.HTTP_400_BAD_REQUEST)

        step = request.data.get('step')
        if step not in ('id_document', 'selfie_liveness'):
            return Response({'detail': 'Invalid step.'}, status=status.HTTP_400_BAD_REQUEST)
        if submission.current_step != step:
            return Response(
                {'detail': f'Expected step "{submission.current_step}" — complete steps in order.'},
                status=status.HTTP_409_CONFLICT,
            )

        upload = request.FILES.get('file')
        if upload is None:
            return Response({'detail': 'No file provided.'}, status=status.HTTP_400_BAD_REQUEST)
        if upload.size > 10 * 1024 * 1024:
            return Response({'detail': 'File too large (max 10 MB).'}, status=status.HTTP_400_BAD_REQUEST)

        if step == 'id_document':
            document_type = request.data.get('document_type', 'id_card')
            if document_type not in ID_DOC_TYPES:
                return Response({'detail': 'Invalid document type.'}, status=status.HTTP_400_BAD_REQUEST)
        else:
            document_type = 'selfie'

        ext = os.path.splitext(upload.name)[1].lower() or '.jpg'
        filename = f'verification/{submission.profile_id}/{step}/{uuid.uuid4().hex}{ext}'
        try:
            saved = default_storage.save(filename, ContentFile(upload.read()))
            file_url = request.build_absolute_uri(default_storage.url(saved))
        except Exception:
            logger.exception('Failed to store verification upload')
            return Response({'detail': 'Upload failed.'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        doc = VerificationDocument.objects.create(
            profile=submission.profile,
            document_type=document_type,
            file_url=file_url,
        )
        submission.documents.add(doc)
        if step not in submission.completed_steps:
            submission.completed_steps = [*submission.completed_steps, step]

        face_result = None
        if step == 'selfie_liveness':
            # Face-match the selfie against the first ID document on file.
            id_doc = submission.documents.filter(document_type__in=ID_DOC_TYPES).first()
            if id_doc:
                match_status, score = run_face_match(id_doc.file_url, doc.file_url)
                submission.face_match_status = match_status
                submission.face_match_score = score
                if 'face_match' not in submission.completed_steps:
                    submission.completed_steps = [*submission.completed_steps, 'face_match']
                face_result = {'status': match_status, 'score': score}

        remaining = [s for s in ('id_document', 'selfie_liveness') if s not in submission.completed_steps]
        submission.current_step = remaining[0] if remaining else 'review'
        submission.save(update_fields=[
            'completed_steps', 'current_step', 'face_match_status', 'face_match_score',
        ])
        return Response({
            **VerificationSubmissionSerializer(submission).data,
            'uploaded_document': VerificationDocumentSerializer(doc).data,
            'face_match': face_result,
        })

    @action(detail=True, methods=['post'])
    def submit(self, request, pk=None):
        submission = self.get_object()
        if submission.profile.user != request.user:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        if submission.status != 'draft':
            return Response({'detail': 'Already submitted.'}, status=status.HTTP_400_BAD_REQUEST)

        if submission.verification_type == 'id':
            required = {'id_document', 'selfie_liveness'}
            missing = required - set(submission.completed_steps or [])
            if missing:
                return Response(
                    {'detail': f'Incomplete ID verification — missing steps: {sorted(missing)}.'},
                    status=status.HTTP_400_BAD_REQUEST,
                )

        submission.status = 'submitted'
        submission.submitted_at = timezone.now()
        if submission.verification_type == 'id':
            submission.current_step = 'done'
            submission.save(update_fields=['status', 'submitted_at', 'current_step'])
        else:
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
            elif submission.verification_type == 'shop':
                profile.verification_status = 'shop'
            elif submission.verification_type == 'gym':
                profile.verification_status = 'gym'
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
