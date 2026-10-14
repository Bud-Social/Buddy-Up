from rest_framework import serializers

from django.utils import timezone

from apps.gyms.models import Gym
from .decisions import (
    CATEGORY_APPLICATION_PATH, CATEGORY_APPLICATION_TYPES,
    REQUIRES_DOCUMENT_TYPES, REQUIRES_GYM_TYPES, REQUIRED_FIELDS_BY_TYPE,
)
from .models import VerificationDocument, VerificationSubmission


# The scope-of-practice vocabulary lives on the model field; read it rather than
# restating it, so the two cannot drift.
SCOPE_OF_PRACTICE_CHOICES = VerificationSubmission._meta.get_field(
    'scope_of_practice',
).choices


def approval_state_for(submission):
    """The latest governance decision request for ``submission``, or None.

    Imported lazily: governance pulls in the staff/scope machinery, and this
    serializer is on the read path of the review queue and of a user's own
    "my applications" list, both of which should not fail because the
    governance tables are not migrated yet.
    """
    try:
        from apps.governance.models import AccountActionRequest
    except Exception:  # pragma: no cover - governance app unavailable
        return None

    row = (
        AccountActionRequest.objects
        .filter(action='verification_decision')
        .filter(**{'payload__submission_id': str(submission.id)})
        .order_by('-created_at')
        .first()
    )
    if row is None:
        return None

    payload = row.payload or {}
    return {
        'id': str(row.id),
        'status': row.status,
        'decision': payload.get('decision'),
        'required_scope': row.requires_scope,
        'requested_by_profile': row.requested_by_profile,
        'requested_at': row.created_at,
        'decided_by': (getattr(row.decided_by, 'email', None) if row.decided_by_id else None),
        'decided_at': row.decided_at,
        'decision_note': row.decision_note,
        'applied_at': row.applied_at,
    }


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

    # Is a second approver already on this submission? Surfaces on the review
    # queue so a reviewer does not start work on an application that already has
    # a decision in flight, and on "my applications" so the applicant can see
    # their application is with an approver rather than simply ignored.
    approval_state = serializers.SerializerMethodField()
    pending_approval = serializers.SerializerMethodField()

    class Meta:
        model = VerificationSubmission
        fields = ['id', 'profile', 'verification_type', 'status', 'documents',
                   'document_ids', 'notes', 'gym', 'gym_handle', 'gym_name',
                   'reviewed_by', 'reviewed_at',
                   'submitted_at', 'created_at',
                   'current_step', 'completed_steps', 'face_match_status',
                   'face_match_score',
'credential_title', 'credential_issuer', 'credential_id',
                    'issued_date', 'scope_of_practice',
                    'approval_state', 'pending_approval']
        read_only_fields = ['id', 'profile', 'status', 'documents',
                            'reviewed_by', 'reviewed_at', 'created_at',
                            'current_step', 'completed_steps', 'face_match_status',
                            'face_match_score']

    def _approval_state(self, obj):
        if not hasattr(obj, '_cached_approval_state'):
            obj._cached_approval_state = approval_state_for(obj)
        return obj._cached_approval_state

    def get_approval_state(self, obj):
        """The decision that was requested, whether still pending or applied."""
        return self._approval_state(obj)

    def get_pending_approval(self, obj):
        """Non-None exactly while a second approver is still owed."""
        state = self._approval_state(obj)
        return state if state and state['status'] == 'pending' else None

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


class VerificationDecisionSerializer(serializers.Serializer):
    """Input for the *second* approver's call.

    Named separately from :class:`VerificationReviewSerializer` because the two
    are different acts: the review call raises a request and applies nothing,
    this one settles it. The `note` is what the applicant reads, so it is
    required on rejection here — the same rule governance applies to its own
    reject.
    """
    action = serializers.ChoiceField(choices=['approve', 'reject'])
    note = serializers.CharField(required=False, allow_blank=True, default='', max_length=1000)


class CategoryApplicationSerializer(serializers.Serializer):
    """Apply for an elevated role. Produces a `submitted` VerificationSubmission.

    A plain ``Serializer``, not a ``ModelSerializer``, for the same reason
    ``apps.governance.StaffRoleWriteSerializer`` is one: applying for a role is
    not editing a row. It stamps ``status='submitted'`` and ``submitted_at``,
    links evidence the applicant already uploaded, and must never let the caller
    write ``profile``, ``status``, ``reviewed_by`` or ``reviewed_at``.

    Validation is per-category and up front. An application missing its
    credential number is refused here rather than discovered during review,
    where the only honest outcome is a rejection for an administrative reason.
    """
    category = serializers.ChoiceField(choices=CATEGORY_APPLICATION_TYPES)
    credential_title = serializers.CharField(max_length=120, required=False, allow_blank=True)
    credential_issuer = serializers.CharField(max_length=200, required=False, allow_blank=True)
    credential_id = serializers.CharField(max_length=120, required=False, allow_blank=True)
    issued_date = serializers.DateField(required=False, allow_null=True)
    scope_of_practice = serializers.ChoiceField(
        choices=SCOPE_OF_PRACTICE_CHOICES, required=False, allow_blank=True,
    )
    gym_handle = serializers.CharField(required=False, allow_blank=True)
    document_ids = serializers.ListField(
        child=serializers.UUIDField(), required=False, default=list,
    )
    notes = serializers.CharField(required=False, allow_blank=True, max_length=1000)

    def validate(self, attrs):
        category = attrs['category']

        # "Missing" is spelled twice because the required fields have two
        # shapes: every one is a string except ``issued_date``, which is a date
        # and arrives as None when absent.
        missing = []
        for field in REQUIRED_FIELDS_BY_TYPE[category]:
            value = attrs.get(field)
            if value is None or (isinstance(value, str) and not value.strip()):
                missing.append(field)
        if missing:
            raise serializers.ValidationError({
                field: [f'Required to apply for {category!r}.'] for field in missing
            })

        # Evidence. The documents already exist (uploaded through
        # /api/v1/verification/documents/) and are matched against the
        # applicant's own profile, so an application cannot cite somebody
        # else's document.
        document_ids = attrs.get('document_ids') or []
        if category in REQUIRES_DOCUMENT_TYPES and not document_ids:
            raise serializers.ValidationError({
                'document_ids': [
                    f'Supporting evidence is required to apply for {category!r}. '
                    'Upload the document first, then reference its id here.',
                ],
            })
        if document_ids:
            owned = VerificationDocument.objects.filter(
                id__in=document_ids, profile=self.context['profile'],
            ).values_list('id', flat=True)
            owned = {str(d) for d in owned}
            foreign = sorted({str(d) for d in document_ids} - owned)
            if foreign:
                raise serializers.ValidationError({
                    'document_ids': [f'Unknown document(s): {foreign}.'],
                })

        gym = None
        if category in REQUIRES_GYM_TYPES:
            handle = (attrs.get('gym_handle') or '').strip()
            if not handle:
                raise serializers.ValidationError({
                    'gym_handle': [f'Required to apply for {category!r}.'],
                })
            gym = Gym.objects.filter(handle__iexact=handle).first()
            if gym is None:
                raise serializers.ValidationError({
                    'gym_handle': ['No gym found with that handle.'],
                })
        attrs['_gym'] = gym

        return attrs

    def create(self, validated_data):
        gym = validated_data.pop('_gym', None)
        document_ids = validated_data.pop('document_ids', []) or []
        validated_data.pop('gym_handle', None)
        # `category` is the client-facing name for the model column
        # `verification_type`; pop it rather than letting it reach the constructor.
        category = validated_data.pop('category')
        # The applicant, never the caller-supplied one. This serializer has no
        # `profile` field at all, so there is nothing for a client to override.
        profile = self.context['profile']

        submission = VerificationSubmission.objects.create(
            profile=profile,
            gym=gym,
            verification_type=category,
            # Straight to `submitted`: this endpoint is the application, and a
            # draft a reviewer could never see is just a discarded POST.
            status='submitted',
            submitted_at=timezone.now(),
            **validated_data,
        )
        if document_ids:
            submission.documents.set(
                VerificationDocument.objects.filter(
                    id__in=document_ids, profile=profile,
                )
            )
        return submission

    def to_representation(self, instance):
        # Rendered with the submission serializer so a freshly-created
        # application looks exactly like the one the applicant will fetch back
        # from "my applications" — including the approval state.
        return VerificationSubmissionSerializer(instance).data
