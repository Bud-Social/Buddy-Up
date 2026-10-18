import logging
import os
import uuid

from django.core.files.storage import default_storage
from django.core.files.base import ContentFile

from rest_framework import viewsets, mixins, status, views
from rest_framework.decorators import action
from rest_framework.parsers import FormParser, MultiPartParser
from rest_framework.permissions import IsAdminUser, IsAuthenticated
from rest_framework.response import Response
from django.utils import timezone
from django.core import signing
from django.http import FileResponse
from django.shortcuts import get_object_or_404

from .models import (
    VerificationDocument, VerificationDocumentAccess, VerificationSubmission,
)
from .decisions import (
    CATEGORY_APPLICATION_TYPES, DecisionError,
    apply_decision, raise_decision_request,
)
from .serializers import (
    CategoryApplicationSerializer, VerificationDocumentSerializer,
    VerificationSubmissionSerializer, VerificationReviewSerializer,
    VerificationDecisionSerializer,
)
from .services import run_face_match

logger = logging.getLogger(__name__)

ID_FLOW_STEPS = ['id_document', 'selfie_liveness', 'face_match', 'review']
ID_DOC_TYPES = {'id_card', 'passport', 'drivers_license'}
#: Credential evidence for the professional-badge path (trainer/practitioner),
#: which has no wizard step to hang a multipart action on.
CREDENTIAL_DOC_TYPES = {'certificate', 'practitioner_id', 'credential'}

# Only these extensions are ever copied from a client-supplied upload name;
# the stored filename itself is always server-generated (uuid-based).
ALLOWED_UPLOAD_EXTENSIONS = {'.jpg', '.jpeg', '.png', '.webp', '.heic', '.heif'}


def _is_internal_file_ref(file_url):
    """True when file_url references our own storage instead of a public URL."""
    return bool(file_url) and not file_url.startswith(('http://', 'https://'))


def _audited_document_url(document_id):
    """Path of the access-audited retrieve endpoint for a document."""
    return f'/api/v1/verification/documents/{document_id}/'


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

    def retrieve(self, request, *args, **kwargs):
        document = self.get_object()
        VerificationDocumentAccess.objects.create(
            document=document,
            actor=request.user,
            purpose=(request.query_params.get('purpose') or 'view verification document')[:120],
            request_id=getattr(request, 'request_id', ''),
            ip_address=self._client_ip(request),
        )
        file_ref = document.file_url or ''
        if _is_internal_file_ref(file_ref):
            # Internal storage reference: prefer a short-lived signed URL when
            # object storage is configured, otherwise stream the bytes here.
            from common.s3_utils import generate_presigned_url
            presigned = generate_presigned_url(file_ref, expiration_seconds=300)
            if presigned:
                data = VerificationDocumentSerializer(document, context={'request': request}).data
                data['file_url'] = presigned
                return Response(data)
            return self._stream_document(document, file_ref)
        return super().retrieve(request, *args, **kwargs)

    def _stream_document(self, document, file_ref):
        import mimetypes

        try:
            file_handle = default_storage.open(file_ref, 'rb')
        except (FileNotFoundError, IOError, OSError):
            logger.warning('Verification document file missing document_id=%s', document.id)
            return Response(
                {'detail': 'Document file is no longer available.'},
                status=status.HTTP_404_NOT_FOUND,
            )
        content_type = mimetypes.guess_type(file_ref)[0] or 'application/octet-stream'
        response = FileResponse(file_handle, content_type=content_type)
        # Filename is always the server-generated document id — never user input.
        response['Content-Disposition'] = f'inline; filename="{document.id}"'
        response['X-Content-Type-Options'] = 'nosniff'
        return response

    @staticmethod
    def _client_ip(request):
        forwarded = request.META.get('HTTP_X_FORWARDED_FOR', '')
        return (forwarded.split(',')[0].strip() if forwarded else request.META.get('REMOTE_ADDR')) or None


class VerificationDocumentAccessView(views.APIView):
    """Issue and redeem a short-lived, auditable document access grant."""
    permission_classes = [IsAuthenticated]

    def post(self, request, pk):
        document = get_object_or_404(VerificationDocument, id=pk)
        if not request.user.is_staff and document.profile.user_id != request.user.id:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        token = signing.dumps({'document_id': str(document.id), 'user_id': str(request.user.id)}, salt='verification-document-access')
        return Response({'token': token, 'expires_in': 300})

    def get(self, request, pk):
        token = request.query_params.get('token', '')
        try:
            payload = signing.loads(token, salt='verification-document-access', max_age=300)
        except signing.BadSignature:
            return Response({'detail': 'Invalid or expired access grant.'}, status=status.HTTP_403_FORBIDDEN)
        if payload.get('document_id') != str(pk) or (not request.user.is_staff and payload.get('user_id') != str(request.user.id)):
            return Response({'detail': 'Invalid or expired access grant.'}, status=status.HTTP_403_FORBIDDEN)
        document = get_object_or_404(VerificationDocument, id=pk)
        VerificationDocumentAccess.objects.create(
            document=document, actor=request.user, purpose='signed document access',
            request_id=getattr(request, 'request_id', ''), ip_address=VerificationDocumentViewSet._client_ip(request),
        )
        file_url = document.file_url
        if _is_internal_file_ref(file_url):
            # Never disclose an internal storage path — point at the audited
            # retrieve endpoint instead.
            file_url = _audited_document_url(document.id)
        return Response({'file_url': file_url, 'expires_in': 300})


class VerificationDocumentUploadView(views.APIView):
    """Multipart upload for a credential document that is not part of the ID wizard.

    The wizard has its own multipart action (`submissions/<id>/upload_step/`),
    but the professional-badge form has no submission to hang a step on yet. It
    used to work around that by uploading the bytes to the messaging attachment
    endpoint and then POSTing the resulting *URL* as `file_url` -- and
    `file_url` is a SerializerMethodField on the document serializer, so DRF
    discarded it. The result was a VerificationDocument row with an empty
    `file_url` pointing at nothing, while the actual image sat in a separate
    messaging storage prefix that no reviewer path ever reads. The application
    looked complete and carried no evidence.

    Storing here keeps the bytes on the same reviewed-and-purged path as every
    other verification document.
    """

    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def post(self, request):
        upload = request.FILES.get('file')
        if upload is None:
            return Response({'detail': 'No file provided.'}, status=status.HTTP_400_BAD_REQUEST)
        if upload.size > 10 * 1024 * 1024:
            return Response({'detail': 'File too large (max 10 MB).'}, status=status.HTTP_400_BAD_REQUEST)

        document_type = (request.data.get('document_type') or '').strip()
        allowed = ID_DOC_TYPES | CREDENTIAL_DOC_TYPES
        if document_type not in allowed:
            return Response(
                {'detail': f'Invalid document type. Must be one of: {sorted(allowed)}.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        ext = os.path.splitext(upload.name)[1].lower()
        if ext not in ALLOWED_UPLOAD_EXTENSIONS:
            ext = '.jpg'

        profile = request.user.profile
        # Profile's primary key is the `user` OneToOne, not `id`.
        filename = f'verification/{profile.user_id}/{document_type}/{uuid.uuid4().hex}{ext}'
        try:
            saved = default_storage.save(filename, ContentFile(upload.read()))
        except Exception:
            logger.exception('Failed to store verification credential upload')
            return Response({'detail': 'Upload failed.'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        doc = VerificationDocument.objects.create(
            profile=profile,
            document_type=document_type,
            file_url=saved,
            purge_after=timezone.now() + timezone.timedelta(
                days=int(os.environ.get('VERIFICATION_DOCUMENT_RETENTION_DAYS', '90')),
            ),
        )
        return Response(
            {'success': True, 'data': VerificationDocumentSerializer(doc).data,
             'message': 'Document uploaded.', 'errors': None, 'pagination': None},
            status=status.HTTP_201_CREATED,
        )


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

        ext = os.path.splitext(upload.name)[1].lower()
        if ext not in ALLOWED_UPLOAD_EXTENSIONS:
            ext = '.jpg'
        # Server-generated filename: the client-supplied name never reaches
        # storage, and the stored reference is internal (never a public URL).
        filename = f'verification/{submission.profile_id}/{step}/{uuid.uuid4().hex}{ext}'
        try:
            saved = default_storage.save(filename, ContentFile(upload.read()))
        except Exception:
            logger.exception('Failed to store verification upload')
            return Response({'detail': 'Upload failed.'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        doc = VerificationDocument.objects.create(
            profile=submission.profile,
            document_type=document_type,
            # Internal storage reference only — the bytes are served through
            # the audited retrieve endpoint, never via a public media URL.
            file_url=saved,
            # ID/selfie evidence is retained long enough for review and appeal,
            # then purged by the scheduled retention task.
            purge_after=timezone.now() + timezone.timedelta(
                days=int(os.environ.get('VERIFICATION_DOCUMENT_RETENTION_DAYS', '90')),
            ),
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
        """Ask for a decision on this submission. Applies nothing.

        This used to approve in one call — one staff member decided, wrote
        ``Profile.verification_status``, flipped ``Gym.is_verified``, and could
        be the applicant. It now only raises
        ``AccountActionRequest(action='verification_decision')`` and returns 202:
        a *different* member of staff must call :meth:`decide` before anything
        changes. Two-person only; there is deliberately no single-approver
        bypass, because the setting that would gate one lives in
        ``config/settings.py`` which this app does not own.

        Staff with no ``StaffRole`` row still resolve to every scope
        (``apps.governance.services.effective_scopes`` branch 5), so the
        existing single staff account can still raise and approve requests — it
        simply cannot do both on the same submission.
        """
        submission = self.get_object()
        serializer = VerificationReviewSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        try:
            approval = raise_decision_request(
                submission=submission,
                decision=data['action'],
                actor=request.user,
                rejection_reason=data.get('rejection_reason', ''),
                document_ids=data.get('document_ids') or [],
            )
        except DecisionError as exc:
            return Response({'detail': exc.message}, status=exc.status_code)

        # `under_review` says "a decision is with an approver", which is true and
        # is not the same claim as `reviewed_by`/`reviewed_at`. Those two fields
        # stay empty until the second person decides — the reviewer who raised
        # the request has reviewed nothing.
        submission.status = 'under_review'
        submission.save(update_fields=['status', 'updated_at'])

        return Response(
            {
                **VerificationSubmissionSerializer(submission).data,
                'approval_request': {
                    'id': str(approval.id),
                    'status': approval.status,
                    'requested_by_profile': approval.requested_by_profile,
                    'required_scope': approval.requires_scope,
                    'created_at': approval.created_at,
                },
            },
            status=status.HTTP_202_ACCEPTED,
        )

    @action(detail=True, methods=['post'], permission_classes=[IsAdminUser])
    def decide(self, request, pk=None):
        """The second, independent approver settles the pending request.

        Mirrors ``apps.governance.views.ApprovalApproveView`` rule for rule, and
        applies the effect inside the same transaction as the settle. Only this
        endpoint applies anything — see the "Known gap" note in
        ``apps.verification.decisions``.
        """
        submission = self.get_object()

        from apps.governance.models import AccountActionRequest

        approval = (
            AccountActionRequest.objects
            .filter(action='verification_decision')
            .filter(**{'payload__submission_id': str(submission.id)})
            .order_by('-created_at')
            .first()
        )
        if approval is None:
            return Response(
                {'detail': (
                    'No verification decision has been requested for this '
                    'application. Call review/ first.'
                )},
                status=status.HTTP_404_NOT_FOUND,
            )

        serializer = VerificationDecisionSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        try:
            settled, effect = apply_decision(
                request_row=approval,
                actor=request.user,
                note=serializer.validated_data.get('note') or '',
            )
        except DecisionError as exc:
            return Response({'detail': exc.message}, status=exc.status_code)

        submission.refresh_from_db()
        return Response({
            **VerificationSubmissionSerializer(submission).data,
            'approval': {
                'id': str(settled.id),
                'status': settled.status,
                'decision_note': settled.decision_note,
                'decided_by': request.user.email,
                'decided_at': settled.decided_at,
                'applied_at': settled.applied_at,
                'effect': effect,
            },
        })


class CategoryApplicationView(views.APIView):
    """Apply for an elevated role: POST here, then track it in "my applications".

    The route that ``RegisterSerializer`` points an elevated-role registration
    at, so the message it rejects with is a working path rather than a dead end.
    """

    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = CategoryApplicationSerializer(
            data=request.data, context={'request': request, 'profile': request.user.profile},
        )
        serializer.is_valid(raise_exception=True)
        submission = serializer.save()
        return Response(
            serializer.to_representation(submission),
            status=status.HTTP_201_CREATED,
        )


class MyApplicationsView(views.APIView):
    """This applicant's own applications, with the decision and the reviewer's note.

    Scoped to ``request.user.profile`` unconditionally — including for staff,
    who get their own applications here rather than the whole queue (that is
    the review endpoint, gated on ``IsAdminUser``).
    """

    permission_classes = [IsAuthenticated]

    def get(self, request):
        queryset = (
            VerificationSubmission.objects
            .filter(profile__user=request.user)
            .prefetch_related('documents')
            .order_by('-created_at')
        )
        category = (request.query_params.get('category') or '').strip()
        if category:
            if category not in CATEGORY_APPLICATION_TYPES:
                return Response(
                    {'detail': (
                        f'Unknown category: {category!r}. Must be one of: '
                        f'{sorted(CATEGORY_APPLICATION_TYPES)}.'
                    )},
                    status=status.HTTP_400_BAD_REQUEST,
                )
            queryset = queryset.filter(verification_type=category)

        data = VerificationSubmissionSerializer(queryset, many=True).data
        return Response({'count': len(data), 'results': data})


class VerificationPolicyView(views.APIView):
    """The retention policy a user is shown before they upload an ID.

    Public and unauthenticated on purpose: the disclosure has to be readable on
    the upload screen before anyone has an account or a submission to fetch.

    The numbers are read from the same environment variables the purge task uses,
    so the copy a user reads cannot drift from what actually happens to their
    file. That drift is not hypothetical -- the UI previously asserted documents
    are "stored securely and only visible to the verification team", with no
    mention of deletion at all, while the purge task deleted the file 30 days
    after every decision.
    """

    permission_classes = []

    def get(self, request):
        document_days = int(os.environ.get('VERIFICATION_DOCUMENT_RETENTION_DAYS', '90'))
        post_review_days = int(os.environ.get('VERIFICATION_POST_REVIEW_RETENTION_DAYS', '30'))
        return Response({
            'document_retention_days': document_days,
            'post_review_retention_days': post_review_days,
            'storage': 'Uploaded files are stored on private storage, not in the app database.',
            'access': 'Only staff reviewing the submission can open a document, and every open is written to an audit record.',
            'deletion': (
                f'The file is deleted {post_review_days} days after a decision is made on your '
                f'application, or {document_days} days after upload if no decision is made. '
                'Only non-identifying metadata is kept after deletion.'
            ),
        })
