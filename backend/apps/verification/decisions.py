"""Category applications and two-person verification decisions.

Why this module exists
----------------------
A verification decision is the highest-consequence write in this app. It sets
``Profile.verification_status``, it sets ``Gym.is_verified``, and for the
professional types it grants the ``Profile.role`` that every trainer- and
practitioner-only surface is gated on. It used to be a single POST by a single
member of staff who could also be the applicant, so ``requester == approver``
and ``applicant == reviewer`` were both reachable.

The separation-of-duties machinery for exactly this already exists in
``apps.governance`` as ``AccountActionRequest(action='verification_decision')``
— an action choice that had been declared but never raised by anything. This
module raises it rather than reimplementing a second, weaker queue:

* :func:`raise_decision_request` writes the row with the same kwarg shape
  ``apps.governance.views`` uses at its own call sites.
* :func:`apply_decision` settles that row and performs the effect, once.

The rules enforced here mirror ``apps.governance.views._DecisionView`` one for
one — requester != approver, a settled request is 409, reject requires a note,
and the approver holds the action's scope *at approval time* — because a
reimplemented subset of an invariant is how the invariant quietly stops holding.

Known gap (reported, not worked around)
---------------------------------------
``apps.governance.views.ApprovalApproveView._apply`` has side-effect branches
for ``ban``, ``suspension`` and ``staff_role_grant`` only. ``verification_decision``
falls through to its "carried out in the owning app" no-op branch, so approving
a verification request through the *governance* approvals endpoint would stamp
``applied_at`` without applying anything. The owner of ``apps/governance`` needs
to add a branch there that calls :func:`apply_decision`. Until then, the
verification decide endpoint below is the only path that settles these requests,
and it refuses a request whose ``applied_at`` is already set rather than
applying an effect a second time.
"""
import logging

from django.db import transaction
from django.utils import timezone

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Vocabulary
# ---------------------------------------------------------------------------

# The AccountActionRequest action this app owns. Governance maps it to the
# 'shops.certifications' scope, which is what a Verification Regulator holds.
DECISION_ACTION = 'verification_decision'

# Types a member of the public may apply for, and the route that takes them.
#
# Deliberately excludes `id` (identity, not professional standing — the multistep
# wizard at /verification/submissions/ owns it), and `shop`/`gym` (verification
# of a *business*, which the existing submission flow already covers and which
# flips Gym.is_verified rather than granting a person anything). Pointing those
# at the wrong endpoint would strand a business verification in a queue meant
# for personal certifications.
CATEGORY_APPLICATION_TYPES = (
    'trainer', 'practitioner', 'distributor', 'gym_owner', 'shop_owner', 'delivery_partner',
)

CATEGORY_APPLICATION_PATH = '/api/v1/verification/category-applications/'

# Fields an application of each type must carry, validated before a submission
# row is ever created.
#
# The point is that an incomplete application is refused at the door. The
# alternative — accept it and fail during review — burns a reviewer's time, and
# worse, produces a queue where the reason for rejection is "applicant forgot a
# field" rather than anything about the applicant.
REQUIRED_FIELDS_BY_TYPE = {
    'trainer': (
        'credential_title', 'credential_issuer', 'credential_id',
        'issued_date', 'scope_of_practice',
    ),
    'practitioner': (
        'credential_title', 'credential_issuer', 'credential_id',
        'issued_date', 'scope_of_practice',
    ),
    'distributor': ('credential_title', 'credential_issuer', 'credential_id'),
    'gym_owner': ('credential_title', 'credential_issuer', 'credential_id'),
    'shop_owner': ('credential_title', 'credential_issuer', 'credential_id'),
    'delivery_partner': ('credential_title', 'credential_issuer', 'credential_id'),
}

# Every category application needs supporting evidence on file. A credential
# number with no document behind it is not reviewable, and this app cannot
# judge a scanned certificate itself.
REQUIRES_DOCUMENT_TYPES = frozenset(CATEGORY_APPLICATION_TYPES)

# Types that must name the gym they are applying to run.
REQUIRES_GYM_TYPES = frozenset({'gym_owner'})

# What ``Profile.verification_status`` becomes when a submission of each type is
# approved. Reproduces the exact strings the single-approver `review` action
# used to write, extended with the three new types.
VERIFICATION_STATUS_BY_TYPE = {
    'id': 'id',
    'trainer': 'trainer',
    'practitioner': 'practitioner',
    'distributor': 'distributor',
    'shop': 'shop',
    'gym': 'gym',
    'gym_owner': 'gym_owner',
    'shop_owner': 'shop_owner',
    'delivery_partner': 'delivery_partner',
}

# Types whose approval also grants ``Profile.role``. Until registration stopped
# accepting a role, `role` was set by the client and this never happened — which
# is why approval has to write both halves now, or a correctly-verified trainer
# would fail the corrected permission class that demands both.
ROLE_ON_APPROVAL = {
    'trainer': 'trainer',
    'practitioner': 'practitioner',
    'distributor': 'distributor',
}

# Submission states a decision may be requested from. `draft` is excluded: a
# draft has not been submitted and reviewing it is a category error, not a
# review.
REVIEWABLE_SUBMISSION_STATUSES = ('submitted', 'under_review')


class DecisionError(Exception):
    """A rule was violated. Carries the HTTP status and message for the view."""

    def __init__(self, message, status_code=400):
        super().__init__(message)
        self.message = message
        self.status_code = status_code


# ---------------------------------------------------------------------------
# Raising the request
# ---------------------------------------------------------------------------

def raise_decision_request(
    *, submission, decision, actor, rejection_reason='', document_ids=None,
):
    """Create the pending ``AccountActionRequest`` for a decision. Apply nothing.

    Returns the new request row. Every rule below is checked *before* the row is
    written, so a refused request leaves no trace in the queue — a queue full of
    requests that can never be raised again is worse than an error message.

    ``governance`` is imported lazily and by module attribute, matching how
    ``apps.governance.views`` reaches into ``apps.accounts``: this app is
    imported by profiles-adjacent code that governance also imports, and a
    top-level import would make that cycle import-order dependent.
    """
    from apps.governance.models import AccountActionRequest
    from apps.governance.serializers import display_name_of
    from apps.governance.services import has_scope

    if decision not in ('approve', 'reject'):
        raise DecisionError(f'Unknown decision: {decision!r}. Must be approve or reject.', 400)

    if submission.status not in REVIEWABLE_SUBMISSION_STATUSES:
        raise DecisionError(
            f'This submission is {submission.status}; only a submitted application '
            'can be sent for review.',
            409,
        )

    # Separation of duties, first and unvarying: the person the decision is
    # about can never be the person asking for it. Checked here rather than at
    # decide time as well, because a staff member reviewing their own
    # application is a mistake worth catching at the point they make it.
    if submission.profile.user_id == actor.pk:
        raise DecisionError(
            'You cannot submit a decision on your own application. Verification '
            'decisions require a second, independent approver.',
            403,
        )

    # Mirrors apps.governance.views.ApprovalRequestCreateView: an action cannot be
    # raised against a superuser, because it would need an approver who outranks
    # both parties and this platform has no such third party.
    if submission.profile.user.is_superuser:
        raise DecisionError(
            'Verification decisions cannot be raised against a superuser account.',
            403,
        )

    required_scope = AccountActionRequest.ACTION_SCOPES.get(DECISION_ACTION)
    if not has_scope(actor, required_scope):
        raise DecisionError(
            f'Sending a verification decision for review requires the '
            f'{required_scope!r} scope, which your role does not include.',
            403,
        )

    if decision == 'reject' and not (rejection_reason or '').strip():
        raise DecisionError(
            'A rejection requires a note explaining the reasoning. This is the '
            'record the applicant will read.',
            400,
        )

    existing = AccountActionRequest.objects.filter(
        action=DECISION_ACTION, status='pending',
    ).filter(**{'payload__submission_id': str(submission.id)}).first()
    if existing is not None:
        raise DecisionError(
            'A review decision for this application is already in flight and is '
            'awaiting a second approver.',
            409,
        )

    return AccountActionRequest.objects.create(
        action=DECISION_ACTION,
        target_user=submission.profile.user,
        payload={
            'submission_id': str(submission.id),
            'verification_type': submission.verification_type,
            'decision': decision,
            'rejection_reason': rejection_reason or '',
            'document_ids': [str(d) for d in (document_ids or [])],
        },
        requested_by=actor,
        requested_by_profile=display_name_of(actor),
        requires_second=True,
    )


# ---------------------------------------------------------------------------
# Settling the request and applying the effect
# ---------------------------------------------------------------------------

def apply_decision(*, request_row, actor, note=''):
    """Settle ``request_row`` and apply its effect exactly once.

    Mirrors ``apps.governance.views.ApprovalApproveView``: the settle and the
    effect share one transaction, the row is re-read ``select_for_update`` so two
    concurrent approvals cannot both clear the ``applied_at`` guard, and an
    already-applied request is refused rather than silently re-applied.

    Raises :class:`DecisionError` for every rule the shared governance checks
    enforce; the caller turns that into a response.
    """
    from apps.governance.models import AccountActionRequest
    from apps.governance.services import has_scope

    # Rule 1: the requester cannot decide. Same wording as governance's, because
    # the same operator reading the same refusal in two places should get one
    # explanation.
    if request_row.requested_by_id == actor.pk:
        raise DecisionError(
            'The person who raised this request cannot be the one who decides it. '
            'Two-person approval requires a different member of staff.',
            403,
        )

    # Rule 2: a settled request is 409, never a silent success.
    if request_row.status != 'pending':
        raise DecisionError(
            f'This request was already {request_row.status}. It cannot be decided '
            'again.',
            409,
        )

    payload = request_row.payload or {}
    decision = payload.get('decision')
    note = (note or '').strip()

    # Rule 3: a rejection must say why.
    if decision == 'reject' and not note:
        raise DecisionError(
            'A rejection requires a note explaining the reasoning. This is the '
            'record the applicant will read.',
            400,
        )

    # Rule 4: the approver holds the scope *now*, not when it was requested.
    if decision == 'approve':
        required = AccountActionRequest.ACTION_SCOPES.get(DECISION_ACTION)
        if not has_scope(actor, required):
            raise DecisionError(
                f'Approving a verification decision requires the {required!r} '
                'scope, which your role does not include.',
                403,
            )

    with transaction.atomic():
        locked = AccountActionRequest.objects.select_for_update().filter(
            pk=request_row.pk,
        ).first()
        if locked is None:
            raise DecisionError('This request no longer exists.', 404)

        # The effect-once guard. Also catches the governance gap documented in
        # the module docstring: a request approved through the governance
        # approvals endpoint carries applied_at without anything having been
        # applied, and re-applying on top of that would be guessing.
        if locked.applied_at is not None:
            raise DecisionError(
                'This request has already been approved and its effect recorded '
                'as applied. It will not be applied a second time.',
                409,
            )

        # Re-check under the lock: the settle rules above were evaluated against
        # a row that a concurrent approver may have settled since.
        if locked.status != 'pending':
            raise DecisionError(
                f'This request was already {locked.status}. It cannot be decided '
                'again.',
                409,
            )

        locked.status = 'approved' if decision == 'approve' else 'rejected'
        locked.decided_by = actor
        locked.decided_at = timezone.now()
        if note:
            locked.decision_note = note
        locked.save(update_fields=[
            'status', 'decided_by', 'decided_at', 'decision_note', 'updated_at',
        ])

        try:
            effect = _apply_effect(locked, actor, decision)
        except Exception as exc:
            # Roll the settle back by restoring pending so the request stays
            # decidable. A failed apply that left the row reading "approved"
            # would be a lie: the approver would believe the verification
            # happened.
            logger.exception('verification_decision_apply_failed request=%s', locked.pk)
            locked.status = 'pending'
            locked.decided_by = None
            locked.decided_at = None
            locked.decision_note = ''
            locked.save(update_fields=[
                'status', 'decided_by', 'decided_at', 'decision_note', 'updated_at',
            ])
            raise DecisionError(
                f'Could not apply this decision: {exc} The request has been left '
                'pending and nothing was changed.',
                400,
            ) from exc

        locked.applied_at = timezone.now()
        locked.save(update_fields=['applied_at', 'updated_at'])

    locked.refresh_from_db()
    return locked, effect


def _apply_effect(request_row, actor, decision):
    """Perform the decision on the submission and the profile. Returns a string.

    This is the code that did not run before the second approval existed. It is
    called only from :func:`apply_decision`, inside its transaction, once a
    requester other than the actor has signed off.
    """
    from apps.verification.models import VerificationSubmission

    payload = request_row.payload or {}
    submission_id = payload.get('submission_id')
    submission = VerificationSubmission.objects.select_for_update().filter(
        pk=submission_id,
    ).select_related('profile').first()
    if submission is None:
        raise DecisionError('The submission this request refers to no longer exists.', 404)

    # A submission the effect already settled is a double-apply even when
    # applied_at was somehow unset. Belt and braces with the guard above, and
    # the thing that actually protects the profile write.
    if submission.status in ('approved', 'rejected'):
        raise DecisionError(
            f'This submission is already {submission.status}. A decision cannot '
            'be applied to it twice.',
            409,
        )

    now = timezone.now()
    rejection_reason = str(payload.get('rejection_reason') or '').strip()
    note = (request_row.decision_note or '').strip()
    # The applicant reads the approver's note. For a rejection that is the
    # approver's reason; the requester's draft reason is a fallback for the
    # path where the note was left empty on approve.
    applicant_reason = note or rejection_reason

    if decision == 'approve':
        submission.status = 'approved'
        profile = submission.profile
        fields = []

        new_status = VERIFICATION_STATUS_BY_TYPE.get(submission.verification_type)
        if new_status is None:
            raise DecisionError(
                f'Unknown verification type: {submission.verification_type!r}.',
                400,
            )
        profile.verification_status = new_status
        fields.append('verification_status')

        # The role half of the pair. Registration no longer sets a role, so
        # approval is the only thing that can — without this a verified trainer
        # would have verification_status='trainer' and role='user', and would
        # fail the very permission class that is supposed to admit them.
        new_role = ROLE_ON_APPROVAL.get(submission.verification_type)
        if new_role is not None and profile.role != new_role:
            profile.role = new_role
            fields.append('role')

        if fields:
            profile.save(update_fields=fields + ['updated_at'])

        # Only a `gym` verification certifies the business. A `gym_owner`
        # application verifies the *person*; it does not verify the gym, which
        # would let anyone become a gym owner and thereby verify it in one step.
        if submission.verification_type == 'gym' and submission.gym_id:
            from apps.gyms.models import Gym
            Gym.objects.filter(id=submission.gym_id).update(is_verified=True)

        _settle_documents(submission, 'approved', actor, now, payload)
        return f'The {submission.verification_type} application was approved.'

    submission.status = 'rejected'
    _settle_documents(submission, 'rejected', actor, now, payload, applicant_reason)
    return 'The application was rejected.'


def _settle_documents(submission, status, actor, now, payload, reason=''):
    """Mark the submission's documents decided, optionally narrowing the set.

    The narrowing is the requester's `document_ids` from the review call — a
    reviewer who accepts the certification but rejects the proof of address
    settles only the documents they looked at. ``status='approved'`` documents
    are marked approved; ``rejected`` ones carry the applicant's reason.
    """
    document_ids = payload.get('document_ids') or []
    documents = submission.documents.all()
    if document_ids:
        documents = documents.filter(id__in=document_ids)

    updates = {'status': status, 'reviewed_by': actor, 'reviewed_at': now}
    if status == 'rejected':
        updates['rejection_reason'] = reason or ''
    documents.update(**updates)

    submission.reviewed_by = actor
    submission.reviewed_at = now
    submission.save(update_fields=['status', 'reviewed_by', 'reviewed_at', 'updated_at'])

    # Start a shorter post-decision retention clock if policy asks for it.
    import os
    retention_days = int(os.environ.get('VERIFICATION_POST_REVIEW_RETENTION_DAYS', '30'))
    submission.documents.filter(purged_at__isnull=True).update(
        purge_after=now + timezone.timedelta(days=retention_days),
    )
