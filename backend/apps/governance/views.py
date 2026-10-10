"""Governance endpoints: staff roles and two-person approvals.

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
"""
from django.db import transaction
from django.shortcuts import get_object_or_404
from django.utils import timezone
from rest_framework import status, views
from rest_framework.response import Response

from common.pagination import PageNumberPagination

from .models import AccountActionRequest, StaffRole
from .permissions import ScopedPlatformAdmin
from .serializers import (
    AccountActionRequestCreateSerializer,
    AccountActionRequestSerializer,
    DecisionSerializer,
    StaffRoleSerializer,
    StaffRoleUpdateSerializer,
    StaffRoleWriteSerializer,
)
from .serializers import display_name_of
from .services import has_scope


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


class StaffRoleListCreateView(GovernanceView):
    """List role assignments, or request a new one.

    The scope is ``users`` — the same scope that governs editing a user. A role
    assignment is a bigger change than a profile edit, but it is the *same
    domain*, and inventing a second scope only for this route would mean two
    names for one permission decision.
    """

    permission_classes = [ScopedPlatformAdmin.for_scope('users')]

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


class StaffRoleDetailView(GovernanceView):
    """Read, narrow, or revoke one role assignment.

    DELETE revokes rather than deletes. The row is the audit trail for who was
    given what and by whom; dropping it would answer "who had payout access last
    March" with silence.
    """

    permission_classes = [ScopedPlatformAdmin.for_scope('users')]

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
        role_row.save(update_fields=['revoked_at', 'updated_at'])
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


class ApprovalRequestCreateView(GovernanceView):
    """Raise a request. This is how a ban or suspension is initiated.

    The target of a ban obviously cannot approve it, and the moderator who
    decided to ban cannot be the second pair of eyes either, so this endpoint is
    the only entry point to the action.
    """

    permission_classes = [ScopedPlatformAdmin.for_scope('users.read')]

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


class _DecisionView(GovernanceView):
    """Shared decide plumbing: approve / reject / cancel.

    Each subclass names a target status and whether it applies an effect. The
    order of the checks below is the order of the rules' importance: the
    self-approval rule is checked before anything that could vary, so the same
    operator gets the same 403 every time regardless of request state.
    """

    permission_classes = [ScopedPlatformAdmin.for_scope('users.read')]

    target_status = None
    requires_note = False

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
