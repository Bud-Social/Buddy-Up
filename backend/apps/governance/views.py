"""Governance endpoints: staff roles, two-person approvals, the audit trail,
and the assistance console.

Mounted at ``/api/v1/governance/``. Every view is ``ScopedPlatformAdmin`` with a
declared scope, so the same allow-list that guards the admin portal guards the
ability to change it — a support agent cannot grant themselves the role that
would let them approve payouts.

Conventions match ``apps.admin_portal`` exactly: the
``{success, data, message, errors, pagination}`` envelope,
``common.pagination.PageNumberPagination``, validated filters that 400 on an
unknown value rather than returning a list that reads as "no data".

The separation-of-duties rules live here rather than in the model because they
need the acting user, and they are the whole point of this app:

* The requester cannot approve, reject or cancel their own request — on every
   decide call, 403.
* An approver must hold the action's scope *at approval time*, not at request
   time.
* An approved request applies its effect exactly once. A second decide on a
   settled request is 409, never a silent success.
* Reject and cancel both require a note.

Audit coverage
--------------
Every mutating view in this file mixes in ``GovernanceAuditMixin``, so each
successful write lands in ``AdminActionLog`` whether or not the author
remembered. The email console is the one deliberate exception: it is audited
inside ``apps.governance.emails.send_templated_email`` instead, because the
audit row has to exist for sends that never came through HTTP.
"""
import csv
from datetime import timedelta

from django.db import transaction
from django.http import HttpResponse
from django.shortcuts import get_object_or_404
from django.utils import timezone
from django.utils.dateparse import parse_date, parse_datetime
from rest_framework import status, views
from rest_framework.response import Response

from common.pagination import PageNumberPagination

from .audit import GovernanceAuditMixin
from .emails import resolve_template, send_templated_email
from .models import AccountActionRequest, AdminActionLog, EmailLog, StaffRole
from .permissions import ScopedPlatformAdmin
from .serializers import (
    AccountActionRequestCreateSerializer,
    AccountActionRequestSerializer,
    AdminActionLogSerializer,
    DecisionSerializer,
    EmailLogSerializer,
    StaffEmailSendSerializer,
    StaffRoleSerializer,
    StaffRoleUpdateSerializer,
    StaffRoleWriteSerializer,
)
from .serializers import display_name_of
from .services import has_scope, record_admin_action


# A dotted verb: lowercase alphanumerics, dot-separated. The shape every app
# writes into AdminActionLog.action is checked against this before it is
# accepted as a filter, so a typo is a 400 naming the expected grammar rather
# than an empty list that reads as "nothing happened".
import re as _re

ACTION_VERB_RE = _re.compile(r'^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)*$')
TARGET_TYPE_RE = _re.compile(r'^[a-z][a-z0-9_]*$')
_BARE_DATE_RE = _re.compile(r'^\d{4}-\d{2}-\d{2}$')

# Per-staff ceiling on queued/sent emails, per rolling hour. Separate from, and
# much tighter than, the ``otp`` DRF throttle scope: the throttle is per-IP and
# a whole office can share one NAT address, whereas this counts what *this
# account* has queued. It is a hard ceiling in the view because a throttle
# scope lives in settings, which this app does not own.
STAFF_EMAIL_HOURLY_CEILING = 20


class GovernanceView(views.APIView):
    """Envelope + pagination helpers, mirroring ``admin_portal.PortalView``."""

    @staticmethod
    def ok(data=None, message='OK', status_code=status.HTTP_200_OK, pagination=None):
        return Response(
            {
                'success': True,
                'data': data,
                'message': message,
                'errors': None,
                'pagination': pagination,
            },
            status=status_code,
        )

    @staticmethod
    def fail(message, status_code=status.HTTP_400_BAD_REQUEST, errors=None):
        return Response(
            {
                'success': False,
                'data': None,
                'message': message,
                'errors': errors,
                'pagination': None,
            },
            status=status_code,
        )

    def paginate(self, request, queryset, serializer_class, **serializer_kwargs):
        paginator = PageNumberPagination()
        page = paginator.paginate_queryset(queryset, request)
        data = serializer_class(page, many=True, **serializer_kwargs).data
        return self.ok(data, pagination={
            'count': paginator.page.paginator.count,
            'next': paginator.get_next_link(),
            'previous': paginator.get_previous_link(),
        })


# ---------------------------------------------------------------------------
# Staff roles
# ---------------------------------------------------------------------------

def _staff_role_queryset():
    return (
        StaffRole.objects
        .select_related('user', 'user__profile', 'granted_by')
        .order_by('-created_at')
    )


class StaffRoleListCreateView(GovernanceAuditMixin, GovernanceView):
    """List role assignments, or request a new one.

    The scope is ``users`` — the same scope that governs editing a user. A role
    assignment is a bigger change than a profile edit, but it is the *same
    domain*, and inventing a second scope only for this route would mean two
    names for one permission decision.
    """

    permission_classes = [ScopedPlatformAdmin.for_scope('users')]

    audit_action = 'staff_roles.grant_requested'
    audit_target_type = 'staff_role'
    audit_target_id_param = ''

    def audit_after(self, request, response):
        data = (response.data or {}).get('data') if isinstance(response.data, dict) else None
        if not isinstance(data, dict):
            return None
        return {
            'role': data.get('role'),
            'scopes': data.get('effective_scopes'),
            'status': data.get('status'),
            'user': (data.get('user') or {}).get('email') if isinstance(data.get('user'), dict) else None,
        }

    def audit_summary(self, request, response):
        if response.status_code == status.HTTP_202_ACCEPTED:
            return 'Requested a staff role change (needs a second approver).'
        return 'Granted or replaced a staff role.'

    def get(self, request):
        queryset = _staff_role_queryset()

        role = (request.query_params.get('role') or '').strip()
        if role:
            valid = [c[0] for c in StaffRole.ROLE_CHOICES]
            if role not in valid:
                return self.fail(
                    f'Unknown role: {role!r}. Must be one of: {valid}.'
                )
            queryset = queryset.filter(role=role)

        revoked = (request.query_params.get('revoked') or '').strip().lower()
        if revoked in ('true', '1', 'yes'):
            queryset = queryset.filter(revoked_at__isnull=False)
        elif revoked in ('false', '0', 'no'):
            queryset = queryset.filter(revoked_at__isnull=True)

        return self.paginate(request, queryset, StaffRoleSerializer)

    def post(self, request):
        serializer = StaffRoleWriteSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data
        target = data['_user']

        # Self-grant is refused outright, before the approval path is even
        # considered. Routing it to approval would be worse than useless: the
        # request would sit there needing a second person, and if that second
        # person is the same account on another device it is the same actor.
        if target.pk == request.user.pk:
            return self.fail(
                'You cannot grant yourself a staff role. Role changes need another '
                'administrator to approve, so ask one to raise the request.',
                status_code=status.HTTP_403_FORBIDDEN,
            )

        existing = StaffRole.objects.filter(user=target).first()

        # `admin` is the widest role: it carries every scope in ALL_SCOPES, so
        # granting it is the same act as removing all scope limits. It is gated
        # behind approval like any other grant, but the narrow roles are applied
        # directly so routine staffing does not need a second person.
        if not data.get('requires_second', True):
            return self._apply_grant(request, target, data, existing)

        approval = AccountActionRequest.objects.create(
            action='staff_role_grant',
            target_user=target,
            payload={
                'role': data['role'],
                'scopes': data.get('scopes') or [],
                'notes': data.get('notes') or '',
            },
            requested_by=request.user,
            requested_by_profile=display_name_of(request.user),
            requires_second=True,
        )
        return self.ok(
            AccountActionRequestSerializer(approval).data,
            message=(
                'Role change requires a second approver. The request has been '
                'raised and nothing has been applied yet.'
            ),
            status_code=status.HTTP_202_ACCEPTED,
        )

    @transaction.atomic
    def _apply_grant(self, request, target, data, existing):
        if existing:
            existing.role = data['role']
            existing.scopes = data.get('scopes') or []
            existing.notes = data.get('notes') or ''
            existing.granted_by = request.user
            existing.granted_at = timezone.now()
            existing.revoked_at = None
            existing.save()
            message = 'Staff role updated.'
        else:
            existing = StaffRole.objects.create(
                user=target,
                role=data['role'],
                scopes=data.get('scopes') or [],
                notes=data.get('notes') or '',
                granted_by=request.user,
                granted_at=timezone.now(),
            )
            message = 'Staff role granted.'
        return self.ok(
            StaffRoleSerializer(existing).data,
            message=message,
            status_code=status.HTTP_201_CREATED,
        )


class StaffRoleDetailView(GovernanceAuditMixin, GovernanceView):
    """Read, narrow, or revoke one role assignment.

    DELETE revokes rather than deletes. The row is the audit trail for who was
    given what and by whom; dropping it would answer "who had payout access last
    March" with silence.
    """

    permission_classes = [ScopedPlatformAdmin.for_scope('users')]

    # One verb, not three: the row records *which* role was touched and the
    # before/after carries what moved. Splitting PATCH into ``staff_roles.update``
    # and DELETE into ``staff_roles.revoke`` would double the filter vocabulary
    # for a distinction the ``after`` block already makes.
    audit_action = 'staff_roles.revoke'
    audit_target_type = 'staff_role'

    def audit_before(self, request, response):
        row = self._audited_row
        if row is None:
            return None
        return {'role': row.role, 'scopes': list(row.scopes or []), 'revoked_at': None}

    def audit_after(self, request, response):
        row = self._audited_row
        if row is None:
            return None
        return {
            'role': row.role,
            'scopes': list(row.scopes or []),
            'revoked_at': row.revoked_at.isoformat() if row.revoked_at else None,
        }

    def audit_summary(self, request, response):
        if request.method == 'DELETE':
            reason = str((request.data or {}).get('notes') or '').strip()
            base = 'Revoked a staff role. The holder now has no scopes.'
            return f'{base} Reason: {reason}' if reason else base
        return 'Narrowed or replaced a staff role.'

    @property
    def _audited_row(self):
        """The role row as it stands *after* the handler ran, for the delta.

        Re-read rather than captured before the handler: the point of ``after``
        is the state the operator actually produced, and a value stashed at
        entry would be the state they were trying to leave. Revoke keeps the
        row, so this is still readable after a DELETE.
        """
        if not hasattr(self, '_audited_row_cache'):
            kwargs = (getattr(getattr(self, 'request', None), 'parser_context', None) or {})
            pk = (kwargs.get('kwargs') or {}).get('pk')
            self._audited_row_cache = StaffRole.objects.filter(pk=pk).first() if pk else None
        return self._audited_row_cache

    def get(self, request, pk):
        return self.ok(StaffRoleSerializer(self._get(pk)).data)

    def patch(self, request, pk):
        role_row = self._get(pk)
        serializer = StaffRoleUpdateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        if role_row.user_id == request.user.pk:
            return self.fail(
                'You cannot change your own staff role. Ask another administrator.',
                status_code=status.HTTP_403_FORBIDDEN,
            )
        if role_row.revoked_at is not None:
            return self.fail(
                'This role has already been revoked and cannot be edited. '
                'Grant a fresh role instead.',
                status_code=status.HTTP_409_CONFLICT,
            )

        fields = []
        for field in ('role', 'scopes', 'notes'):
            if field in data:
                setattr(role_row, field, data[field])
                fields.append(field)
        if fields:
            role_row.save(update_fields=fields + ['updated_at'])
        role_row.refresh_from_db()
        return self.ok(StaffRoleSerializer(role_row).data, message='Staff role updated.')

    def delete(self, request, pk):
        role_row = self._get(pk)
        # An operator prompted for a revoke reason must not have it silently
        # dropped, so it is persisted on the row and surfaced in the audit.
        reason = str((request.data or {}).get('notes') or '').strip()[:200]
        if reason:
            role_row.notes = reason
        if role_row.user_id == request.user.pk:
            return self.fail(
                'You cannot revoke your own staff role. Ask another administrator.',
                status_code=status.HTTP_403_FORBIDDEN,
            )
        if role_row.revoked_at is not None:
            return self.fail(
                'This role was already revoked.',
                status_code=status.HTTP_409_CONFLICT,
            )
        role_row.revoked_at = timezone.now()
        role_row.save(update_fields=['revoked_at', 'updated_at'] + (['notes'] if reason else []))
        role_row.refresh_from_db()
        return self.ok(
            StaffRoleSerializer(role_row).data,
            message='Staff role revoked. The holder now has no scopes until re-granted.',
        )

    @staticmethod
    def _get(pk):
        return get_object_or_404(_staff_role_queryset(), pk=pk)


# ---------------------------------------------------------------------------
# Approvals
# ---------------------------------------------------------------------------

def _approval_queryset():
    return (
        AccountActionRequest.objects
        .select_related('target_user', 'target_user__profile', 'requested_by',
                        'decided_by')
        .order_by('-created_at')
    )


def _filtered_approvals(request):
    queryset = _approval_queryset()
    params = request.query_params

    status_filter = (params.get('status') or '').strip()
    if status_filter:
        valid = [c[0] for c in AccountActionRequest.STATUS_CHOICES]
        if status_filter not in valid:
            return None, f'Unknown status: {status_filter!r}. Must be one of: {valid}.'
        queryset = queryset.filter(status=status_filter)

    action_filter = (params.get('action') or '').strip()
    if action_filter:
        valid = [c[0] for c in AccountActionRequest.ACTION_CHOICES]
        if action_filter not in valid:
            return None, f'Unknown action: {action_filter!r}. Must be one of: {valid}.'
        queryset = queryset.filter(action=action_filter)

    target_filter = (params.get('target_user') or '').strip()
    if target_filter:
        queryset = queryset.filter(target_user_id=target_filter)

    mine = (params.get('mine') or '').strip().lower()
    if mine in ('true', '1', 'yes'):
        queryset = queryset.filter(requested_by=request.user)
    elif mine in ('false', '0', 'no'):
        queryset = queryset.exclude(requested_by=request.user)

    return queryset, None


class ApprovalListView(GovernanceView):
    """The pending queue plus everything already settled.

    ``mine=true`` narrows to requests this operator raised, which is how they
    track one they are waiting on.
    """

    permission_classes = [ScopedPlatformAdmin.for_scope('users.read')]

    def get(self, request):
        queryset, error = _filtered_approvals(request)
        if error:
            return self.fail(error)
        return self.paginate(request, queryset, AccountActionRequestSerializer)


class ApprovalDetailView(GovernanceView):
    permission_classes = [ScopedPlatformAdmin.for_scope('users.read')]

    def get(self, request, pk):
        approval = get_object_or_404(_approval_queryset(), pk=pk)
        return self.ok(AccountActionRequestSerializer(approval).data)


class ApprovalRequestCreateView(GovernanceAuditMixin, GovernanceView):
    """Raise a request. This is how a ban or suspension is initiated.

    The target of a ban obviously cannot approve it, and the moderator who
    decided to ban cannot be the second pair of eyes either, so this endpoint is
    the only entry point to the action.
    """

    permission_classes = [ScopedPlatformAdmin.for_scope('users.read')]

    audit_action = 'approvals.request'
    audit_target_type = 'account_action_request'
    audit_target_id_param = ''

    def audit_after(self, request, response):
        data = (response.data or {}).get('data') if isinstance(response.data, dict) else None
        if not isinstance(data, dict):
            return None
        # The payload's `reason` is operator-written justification and belongs in
        # the trail — it is not one of the redacted key names, and an approval
        # with no recorded reason is undefendable. The free-text fields of
        # `ban`/`suspension` payloads are reason/duration_days only, but the
        # scrubber still runs over whatever a future payload adds.
        return {
            'approval_id': data.get('id'),
            'action': data.get('action'),
            'status': data.get('status'),
            'target_user': (data.get('target_user') or {}).get('email')
            if isinstance(data.get('target_user'), dict) else None,
            'payload': data.get('payload'),
        }

    def audit_summary(self, request, response):
        data = (response.data or {}).get('data') if isinstance(response.data, dict) else None
        action = (data or {}).get('action') if isinstance(data, dict) else None
        return f'Raised a {action or "governance"} request for a second approver.'

    def post(self, request):
        serializer = AccountActionRequestCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        target = data['_target']
        required_scope = data['_required_scope']

        if not has_scope(request.user, required_scope):
            return self.fail(
                f'Raising a {data["action"]!r} request requires the '
                f'{required_scope!r} scope, which your role does not include.',
                status_code=status.HTTP_403_FORBIDDEN,
            )

        if target.pk == request.user.pk:
            return self.fail(
                'You cannot raise a governance action against your own account.',
                status_code=status.HTTP_403_FORBIDDEN,
            )

        # A ban against a superuser, or a staff-role change against a superuser,
        # is refused rather than queued: it would have to be approved by someone
        # who outranks both parties, and this platform has no such third party.
        if target.is_superuser:
            return self.fail(
                'Governance actions cannot be raised against a superuser account.',
                status_code=status.HTTP_403_FORBIDDEN,
            )

        approval = AccountActionRequest.objects.create(
            action=data['action'],
            target_user=target,
            payload=data.get('payload') or {},
            requested_by=request.user,
            requested_by_profile=display_name_of(request.user),
            requires_second=data.get('requires_second', True),
        )
        return self.ok(
            AccountActionRequestSerializer(approval).data,
            message=(
                'Request raised. Nothing has been applied — it needs approval '
                'by a different member of staff.'
            ),
            status_code=status.HTTP_201_CREATED,
        )


class _DecisionView(GovernanceAuditMixin, GovernanceView):
    """Shared decide plumbing: approve / reject / cancel.

    Each subclass names a target status and whether it applies an effect. The
    order of the checks below is the order of the rules' importance: the
    self-approval rule is checked before anything that could vary, so the same
    operator gets the same 403 every time regardless of request state.
    """

    permission_classes = [ScopedPlatformAdmin.for_scope('users.read')]

    target_status = None
    requires_note = False

    # ``approvals.decide`` rather than one verb per outcome: the outcome is the
    # single most interesting field on the row and it is already in `after`, so
    # three verbs would make "everything decided" need three filter queries.
    audit_action = 'approvals.decide'
    audit_target_type = 'account_action_request'

    def audit_after(self, request, response):
        data = (response.data or {}).get('data') if isinstance(response.data, dict) else None
        if not isinstance(data, dict):
            return None
        return {
            'approval_id': data.get('id'),
            'action': data.get('action'),
            'status': data.get('status'),
            'decision_note': data.get('decision_note'),
            'applied_at': data.get('applied_at'),
            'effect': data.get('effect'),
        }

    def audit_summary(self, request, response):
        data = (response.data or {}).get('data') if isinstance(response.data, dict) else None
        action = (data or {}).get('action') if isinstance(data, dict) else None
        return f'{self.target_status or "Decided"} a {action or "governance"} request.'

    def post(self, request, pk):
        approval = get_object_or_404(_approval_queryset(), pk=pk)

        # Rule 1, on every decide call and before any state is inspected.
        if approval.requested_by_id == request.user.pk:
            return self.fail(
                'The person who raised this request cannot be the one who decides it. '
                'Two-person approval requires a different member of staff.',
                status_code=status.HTTP_403_FORBIDDEN,
            )

        # Rule 2: a settled request is 409, never silently re-applied.
        if approval.status != 'pending':
            return self.fail(
                f'This request was already {approval.status} '
                f'({"you" if approval.decided_by_id == request.user.pk else approval.decided_by or "someone else"}'
                f'{" on " + approval.decided_at.isoformat() if approval.decided_at else ""}). '
                'It cannot be decided again.',
                status_code=status.HTTP_409_CONFLICT,
            )

        serializer = DecisionSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        note = (serializer.validated_data.get('note') or '').strip()

        # Rule 3: reject and cancel must say why.
        if self.requires_note and not note:
            return self.fail(
                f'A {self.target_status} decision requires a note explaining the '
                'reasoning. This is the record the target will see in an appeal.',
                status_code=status.HTTP_400_BAD_REQUEST,
                errors={'note': ['Required.']},
            )

        # Rule 4: the approver holds the scope *now*, not when it was requested.
        required = approval.requires_scope
        if self.target_status == 'approved' and required and not has_scope(request.user, required):
            return self.fail(
                f'Approving a {approval.action!r} request requires the {required!r} '
                'scope, which your role does not include.',
                status_code=status.HTTP_403_FORBIDDEN,
            )

        return self._settle(request, approval, note)

    def _settle(self, request, approval, note):
        approval.status = self.target_status
        approval.decided_by = request.user
        approval.decided_at = timezone.now()
        if note:
            approval.decision_note = note
        approval.save(update_fields=[
            'status', 'decided_by', 'decided_at', 'decision_note', 'updated_at',
        ])
        return self.ok(
            AccountActionRequestSerializer(approval).data,
            message=f'Request {self.target_status}.',
        )


class ApprovalApproveView(_DecisionView):
    """Approve, then apply the effect exactly once.

    The apply is inside the same transaction as the status write, and the row is
    re-read with ``select_for_update`` semantics so two concurrent approvals
    cannot both pass the ``applied_at is None`` check and apply twice.
    """

    target_status = 'approved'

    @transaction.atomic
    def post(self, request, pk):
        response = super().post(request, pk)
        if response.status_code != status.HTTP_200_OK:
            # A rejection from the shared checks — nothing was written.
            return response

        approval = AccountActionRequest.objects.select_for_update().get(pk=pk)

        if approval.applied_at is not None:
            return self.fail(
                'This request was already approved and its effect has already been '
                'applied. It will not be applied a second time.',
                status_code=status.HTTP_409_CONFLICT,
            )

        try:
            detail = self._apply(request, approval)
        except Exception as exc:
            # Roll the status back to pending so the request is still decidable.
            # A failed apply that left the row reading "approved" would be a lie:
            # the approver would believe the ban happened.
            approval.status = 'pending'
            approval.decided_by = None
            approval.decided_at = None
            approval.decision_note = ''
            approval.save(update_fields=[
                'status', 'decided_by', 'decided_at', 'decision_note', 'updated_at',
            ])
            return self.fail(
                f'Could not apply this action: {exc} '
                'The request has been left pending and nothing was changed.',
                status_code=status.HTTP_400_BAD_REQUEST,
            )

        approval.applied_at = timezone.now()
        approval.save(update_fields=['applied_at', 'updated_at'])
        approval.refresh_from_db()

        data = AccountActionRequestSerializer(approval).data
        data['effect'] = detail
        return self.ok(data, message=f'Request approved and applied. {detail}')

    def _apply(self, request, approval):
        """Perform the effect. Returns a human-readable description.

        Only ban and suspension have a real side effect here. The other actions
        are recorded approvals that a human carries out in the owning app —
        marking them applied is correct (the decision *is* the deliverable) and
        says so in the response rather than implying a system change.
        """
        payload = approval.payload or {}
        reason = str(payload.get('reason') or '').strip()

        if approval.action in ('ban', 'suspension'):
            # Imported lazily and by module attribute: apps.accounts.services is
            # owned by another app, and a top-level import would couple this
            # app's import graph to a module that may not exist yet. The ImportError
            # is caught by the caller's rollback and reported as a 400.
            from apps.accounts import services as accounts_services

            apply_standing_action = getattr(
                accounts_services, 'apply_standing_action', None
            )
            if apply_standing_action is None:
                raise RuntimeError(
                    'apps.accounts.services.apply_standing_action is unavailable.'
                )

            # Maps onto ModerationAction.ACTION_CHOICES. Spelled out rather than
            # built by string surgery — 'user_suspensioned' is neither a word nor
            # a valid action, and a typo here would raise inside the other app.
            action = {'ban': 'user_banned', 'suspension': 'user_suspended'}[approval.action]

            apply_standing_action(
                target_user_id=approval.target_user_id,
                action=action,
                reason=reason,
                duration_days=payload.get('duration_days'),
                actor=request.user,
                source=f'governance:{approval.id}',
            )
            verb = 'banned' if approval.action == 'ban' else 'suspended'
            duration = payload.get('duration_days')
            tail = f' for {duration} day(s)' if duration else ''
            return f'The account has been {verb}{tail}.'

        if approval.action == 'staff_role_grant':
            role = payload.get('role')
            scopes = payload.get('scopes') or []
            previous = StaffRole.objects.filter(user=approval.target_user).first()
            before = (
                {'role': previous.role, 'scopes': list(previous.scopes or [])}
                if previous else None
            )
            StaffRole.objects.update_or_create(
                user=approval.target_user,
                defaults={
                    'role': role,
                    'scopes': scopes,
                    'notes': payload.get('notes') or '',
                    'granted_by': request.user,
                    'granted_at': timezone.now(),
                    'revoked_at': None,
                },
            )
            # The approve view's own mixin row records the *decision*; this
            # records the *effect*. A role change is the single most
            # consequential thing governance does, and "approved" is not an
            # answer to "who now has payout access".
            record_admin_action(
                actor=request.user,
                action='staff_roles.grant',
                summary=f'Applied the {role} role for {approval.target_user.email} via approval.',
                target_type='staff_role',
                target_id=str(StaffRole.objects.filter(user=approval.target_user)
                              .values_list('id', flat=True).first() or ''),
                before=before,
                after={'role': role, 'scopes': list(scopes or [])},
                request=request,
            )
            return f'The {role} role is now active for {approval.target_user.email}.'

        return (
            'The approval is recorded. This action is carried out in the owning '
            'app by the operator; no automatic change was made.'
        )


class ApprovalRejectView(_DecisionView):
    target_status = 'rejected'
    requires_note = True


class ApprovalCancelView(_DecisionView):
    """Withdraw a request.

    Available to a second person as well as the requester, because an operator
    who raised a request in error should not be the only one who can clear it.
    """

    target_status = 'cancelled'
    requires_note = True


# ---------------------------------------------------------------------------
# The audit trail
# ---------------------------------------------------------------------------

def _audit_queryset():
    return AdminActionLog.objects.select_related('actor').order_by('-created_at')


def _filtered_audit(request, *, required_target_type=False):
    """Apply the shared audit filters. Returns ``(queryset, error_message)``.

    Every filter validates its *shape* rather than its membership. ``action`` and
    ``target_type`` are an open vocabulary declared by whichever app performed
    the action — ``admin_portal`` writes ``orders.status_change``, which this app
    has never heard of and must not reject — so there is no list to check
    membership against. What there *is* is a grammar (a dotted lowercase verb, a
    lowercase word), and a value that does not match it is a typo. A typo gets a
    400 naming the grammar; a well-formed verb nobody has written yet gets an
    honest empty list.
    """
    queryset = _audit_queryset()
    params = request.query_params

    action = (params.get('action') or '').strip()
    if action:
        if not ACTION_VERB_RE.match(action):
            return None, (
                f'Malformed action filter: {action!r}. Expected a dotted lowercase '
                "verb such as 'users.suspend', 'orders.status_change' or 'emails.send'."
            )
        queryset = queryset.filter(action=action)

    target_type = (params.get('target_type') or '').strip()
    if target_type:
        if not TARGET_TYPE_RE.match(target_type):
            return None, (
                f'Malformed target_type filter: {target_type!r}. Expected a '
                "lowercase word such as 'user', 'order' or 'staff_role'."
            )
        queryset = queryset.filter(target_type=target_type)

    target_id = (params.get('target_id') or '').strip()
    if target_id:
        queryset = queryset.filter(target_id=target_id[:64])

    actor = (params.get('actor') or '').strip()
    if actor:
        from uuid import UUID

        try:
            UUID(actor)
        except (ValueError, AttributeError, TypeError):
            return None, f'Malformed actor filter: {actor!r}. Expected a user id.'
        queryset = queryset.filter(actor_id=actor)

    for param, lookup, is_upper_bound in (
        ('date_from', 'created_at__gte', False),
        ('date_to', 'created_at__lte', True),
    ):
        raw = (params.get(param) or '').strip()
        if not raw:
            continue
        parsed = _parse_boundary(raw, upper_bound=is_upper_bound)
        if parsed is None:
            return None, (
                f'Malformed {param} filter: {raw!r}. Expected YYYY-MM-DD or an '
                'ISO-8601 datetime.'
            )
        queryset = queryset.filter(**{lookup: parsed})

    if required_target_type and not (params.get('target_type') or '').strip():
        return None, (
            'target_type is required. The timeline is a history of one thing; '
            "without it you are asking for every action this platform has taken."
        )

    return queryset, None


def _parse_boundary(raw, *, upper_bound=False):
    """Parse a date filter into an aware datetime, or None if unparseable.

    ``parse_datetime`` happily reads a bare ``2026-03-04`` and returns it at
    midnight, so a naive "try datetime then date" chain would quietly narrow
    ``date_to`` to the first instant of the day and drop everything that
    happened during the day the operator was asking about. A bare date is
    therefore detected as a bare date and widened deliberately.
    """
    from datetime import datetime as dt_datetime
    from datetime import time as dt_time

    raw = raw.strip()
    if _BARE_DATE_RE.match(raw):
        day = parse_date(raw)
        boundary = dt_time.max if upper_bound else dt_time.min
        return timezone.make_aware(
            dt_datetime.combine(day, boundary), timezone.get_default_timezone(),
        )

    parsed = parse_datetime(raw)
    if parsed is None:
        return None
    if timezone.is_naive(parsed):
        parsed = timezone.make_aware(parsed, timezone.get_default_timezone())
    return parsed


class AuditListView(GovernanceView):
    """Every audit row, newest first, with the filters operators actually use.

    Scope is ``users.read`` rather than something stricter: a support agent who
    can read a user can see what other staff did to that user, and a trail you
    cannot read is a trail you cannot rely on.
    """

    permission_classes = [ScopedPlatformAdmin.for_scope('users.read')]

    def get(self, request):
        queryset, error = _filtered_audit(request)
        if error:
            return self.fail(error)
        return self.paginate(request, queryset, AdminActionLogSerializer)


class AuditExportView(GovernanceView):
    """CSV of the current filter, for an incident review or a compliance pack.

    Same shape as ``apps.gyms.views.GymMemberCSVView``: stdlib ``csv`` writing
    into an ``HttpResponse``, ``Content-Disposition: attachment``. The JSON
    columns are serialised to their string form here so a value containing a
    comma or a quote cannot shift a column — ``csv.writer`` quotes those cells
    itself, and the escaping test pins that.
    """

    permission_classes = [ScopedPlatformAdmin.for_scope('users.read')]

    COLUMNS = [
        'id', 'created_at', 'action', 'actor_email', 'target_type', 'target_id',
        'summary', 'before', 'after', 'request_id', 'ip_address', 'user_agent',
    ]

    # A CSV of an unbounded table is a denial-of-service primitive with a
    # download button. The console never needs more than a quarter of a year of
    # actions in one file.
    MAX_ROWS = 50_000

    def get(self, request):
        queryset, error = _filtered_audit(request)
        if error:
            return self.fail(error)

        queryset = queryset[: self.MAX_ROWS]
        stamp = timezone.now().strftime('%Y%m%d-%H%M%S')
        response = HttpResponse(content_type='text/csv')
        response['Content-Disposition'] = f'attachment; filename="admin-audit-{stamp}.csv"'

        writer = csv.writer(response)
        writer.writerow(self.COLUMNS)
        for row in queryset.iterator(chunk_size=500):
            writer.writerow([
                str(getattr(row, column, '') or '') for column in self.COLUMNS
            ])
        return response


class AuditTimelineView(GovernanceView):
    """Chronological history of one object: "what happened to this thing?".

    The inverse of the list view — oldest first, because the question being
    asked is "what sequence of events led here", and reading that backwards is
    the work the view exists to save.
    """

    permission_classes = [ScopedPlatformAdmin.for_scope('users.read')]

    def get(self, request):
        queryset, error = _filtered_audit(request, required_target_type=True)
        if error:
            return self.fail(error)

        queryset = queryset.order_by('created_at')
        paginator = PageNumberPagination()
        page = paginator.paginate_queryset(queryset, request)
        data = AdminActionLogSerializer(page, many=True).data
        return self.ok(data, pagination={
            'count': paginator.page.paginator.count,
            'next': paginator.get_next_link(),
            'previous': paginator.get_previous_link(),
        })


class AuditDetailView(GovernanceView):
    """One row, with its full before/after.

    This is the "recall the details of any action" endpoint: whatever a summary
    line left out, the delta is here.
    """

    permission_classes = [ScopedPlatformAdmin.for_scope('users.read')]

    def get(self, request, pk):
        row = get_object_or_404(_audit_queryset(), pk=pk)
        return self.ok(AdminActionLogSerializer(row).data)


# ---------------------------------------------------------------------------
# The assistance console
# ---------------------------------------------------------------------------

class StaffEmailSendView(GovernanceView):
    """Send one message from staff to one registered user.

    Not audited by ``GovernanceAuditMixin``: the audit row is written inside
    ``apps.governance.emails.send_templated_email``, which is also where sends
    that never came through HTTP get their row. Auditing here as well would give
    two rows for one message, and two rows for one message is how an audit trail
    stops agreeing with itself.

    Abuse controls, all of them load-bearing:

    * ``users.read`` scope — a support agent can message a user about their
      account; nobody else needs to.
    * One recipient, enforced by the serializer's schema (see
      ``StaffEmailSendSerializer``): no list field exists, and unknown keys such
      as ``recipients`` are a 400 rather than a silent no-op. No bulk, no
      broadcast, no cc.
    * The recipient must be a registered, non-deleted account. An address that
      matches no user is refused.
    * ``throttle_scope = 'otp'`` — an existing DRF scope, so no settings change
      is needed. An unrecognised scope name would silently mean *unthrottled*.
    * ``STAFF_EMAIL_HOURLY_CEILING`` — a hard per-staff-hour cap on top of the
      per-IP throttle, counted from ``EmailLog`` rather than from the throttle
      cache, so it survives a cache flush and counts what this *account* queued
      rather than what one office's NAT address sent.
    * The audit entry and the ``EmailLog`` row are both written synchronously,
      before the worker is handed the message.
    """

    permission_classes = [ScopedPlatformAdmin.for_scope('users.read')]

    # 'otp' is 10/h in production. Reusing it rather than inventing a scope is
    # the point: a scope this app does not own cannot be added here, and a
    # misspelled scope is not a rate limit, it is no rate limit at all.
    throttle_scope = 'otp'

    def post(self, request):
        serializer = StaffEmailSendSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        recipient = data['_recipient']

        window_start = timezone.now() - timedelta(hours=1)
        recent = EmailLog.objects.filter(
            sent_by=request.user, status__in=['queued', 'sent'], created_at__gte=window_start,
        ).count()
        if recent >= STAFF_EMAIL_HOURLY_CEILING:
            return self.fail(
                f'You have queued {recent} messages in the last hour. The ceiling '
                f'is {STAFF_EMAIL_HOURLY_CEILING} per hour — if you genuinely need '
                'to send more than that, escalate to an administrator rather '
                'than working around this.',
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            )

        staff_name = display_name_of(request.user) or request.user.email
        log = send_templated_email(
            to_email=data['_to_email'],
            subject=data['subject'],
            template_key='staff_message',
            context={
                'staff_name': staff_name,
                'body': data['_body'],
            },
            sent_by=request.user,
            related_object_type=data.get('related_object_type') or 'user',
            related_object_id=data.get('related_object_id') or str(recipient.pk),
            request=request,
        )

        return self.ok(
            EmailLogSerializer(log).data,
            message=(
                'Message queued for delivery. It is recorded against your staff '
                'account whether or not it arrives.'
            ),
            status_code=status.HTTP_202_ACCEPTED,
        )


class EmailLogListView(GovernanceView):
    """The delivery log. Filterable by outcome, recipient and sender."""

    permission_classes = [ScopedPlatformAdmin.for_scope('users.read')]

    def get(self, request):
        queryset = EmailLog.objects.select_related('recipient_user', 'sent_by').order_by('-created_at')
        params = request.query_params

        status_filter = (params.get('status') or '').strip()
        if status_filter:
            valid = [c[0] for c in EmailLog.STATUS_CHOICES]
            if status_filter not in valid:
                return self.fail(f'Unknown status: {status_filter!r}. Must be one of: {valid}.')
            queryset = queryset.filter(status=status_filter)

        recipient_email = (params.get('recipient_email') or '').strip()
        if recipient_email:
            queryset = queryset.filter(recipient_email__iexact=recipient_email)

        sent_by = (params.get('sent_by') or '').strip()
        if sent_by:
            from uuid import UUID

            try:
                UUID(sent_by)
            except (ValueError, AttributeError, TypeError):
                return self.fail(f'Malformed sent_by filter: {sent_by!r}. Expected a user id.')
            queryset = queryset.filter(sent_by_id=sent_by)

        return self.paginate(request, queryset, EmailLogSerializer)


class EmailResendView(GovernanceView):
    """Requeue a delivery that failed.

    Only ``failed``. Re-sending a ``sent`` message would be a duplicate the user
    did not ask for; re-sending a ``queued`` one duplicates the retry the worker
    is already doing; re-sending a ``skipped`` one re-runs a dedupe suppression
    and gets skipped again.

    The same dedupe discipline applies, and it is the reason resend can work at
    all: ``dedupe_blocks`` only counts ``queued`` and ``sent`` rows, so a key
    whose only previous attempt failed does not block a retry. The resend gets
    the same ``dedupe_key`` and the same single-recipient schema as the original
    — a failed row carries the recipient and subject forward, and the body is not
    re-sent because it was never stored in full.

    Not audited by the mixin: ``send_templated_email`` writes the row, which
    is what keeps "one message, one audit entry" true.
    """

    permission_classes = [ScopedPlatformAdmin.for_scope('users.read')]

    throttle_scope = 'otp'

    def post(self, request, pk):
        original = get_object_or_404(EmailLog.objects.select_related('sent_by'), pk=pk)

        if original.status != 'failed':
            return self.fail(
                f'Only a failed message can be resent; this one is '
                f'{original.status}. A sent message resending would be a duplicate '
                'the user did not ask for, and a queued one is already being '
                'retried by the worker.',
                status_code=status.HTTP_409_CONFLICT,
            )

        template_key = original.template_key or 'staff_message'
        if resolve_template(template_key) is None:
            return self.fail(
                f'Cannot resend: template {template_key!r} is not registered.',
                status_code=status.HTTP_409_CONFLICT,
            )

        recent = EmailLog.objects.filter(
            sent_by=request.user, status__in=['queued', 'sent'],
            created_at__gte=timezone.now() - timedelta(hours=1),
        ).count()
        if recent >= STAFF_EMAIL_HOURLY_CEILING:
            return self.fail(
                f'You have queued {recent} messages in the last hour. The ceiling '
                f'is {STAFF_EMAIL_HOURLY_CEILING} per hour.',
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            )

        log = send_templated_email(
            to_email=original.recipient_email,
            subject=original.subject,
            template_key=template_key,
            context={
                'staff_name': display_name_of(request.user) or request.user.email,
                # The body was deliberately not stored — only a 500-char preview.
                # A resend re-renders from what we have; a staff member wanting
                # to resend the exact original wording should send a new one.
                'body': original.body_preview,
            },
            sent_by=request.user,
            related_object_type=original.related_object_type,
            related_object_id=original.related_object_id,
            dedupe_key=original.dedupe_key,
            request=request,
        )
        return self.ok(
            EmailLogSerializer(log).data,
            message='Requeued for delivery.',
            status_code=status.HTTP_202_ACCEPTED,
        )
