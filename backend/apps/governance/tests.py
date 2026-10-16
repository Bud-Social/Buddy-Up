"""Tests for governance: scope enforcement and two-person approval.

The two things worth the most tests here are (a) that a role without a scope is
actually stopped, and (b) that the separation-of-duties rules hold on *every*
decide verb, not just approve. Both are the kind of thing that degrades silently
— a permission class that stops reading ``scope`` fails open, and a missing 403
in the reject path lets a requester bury their own request.

``apply_standing_action`` is patched at its source module
(``apps.accounts.services``) so these tests assert the *call* — argument
vocabulary, actor, source tag — rather than a side effect that belongs to
another app's tests.
"""
from datetime import date, timedelta
from unittest import mock

import csv
import io

from contextlib import contextmanager

from django.core.cache import cache
from django.test import TestCase
from django.utils import timezone
from rest_framework import status
from rest_framework.test import APIClient, APIRequestFactory

from apps.accounts.models import User
from apps.profiles.models import Profile
from common.utils import hash_dob

from .models import (
    ALL_SCOPES,
    AccountActionRequest,
    AdminActionLog,
    EmailLog,
    StaffRole,
)
from .views import STAFF_EMAIL_HOURLY_CEILING, AuditExportView

PREFIX = '/api/v1/governance'
PORTAL = '/api/v1/portal'


def _make_user(email, username, **extra):
    user = User.objects.create_user(email=email, password='TestPass123!', **extra)
    user.dob_hash = hash_dob(date(1995, 5, 5))
    user.save(update_fields=['dob_hash'])
    Profile.objects.create(user=user, username=username, display_name=username.title())
    return user


def _grant(user, role, scopes=None):
    return StaffRole.objects.create(
        user=user, role=role, scopes=scopes or [], granted_by=None,
    )


def _accounts_services_stub():
    """``apps.accounts.services`` as a module object, creating it if absent.

    The account-action hook is owned by another app working in parallel, so the
    module may not exist when these tests run. These tests care about the *call*
    governance makes, not the other app's implementation, so a stub module is
    enough — and it means these tests pass whether or not the real function has
    landed yet.
    """
    import sys
    import types

    module = sys.modules.get('apps.accounts.services')
    if module is None:
        module = types.ModuleType('apps.accounts.services')
        sys.modules['apps.accounts.services'] = module
        # Also register on the package, so `from apps.accounts import services`
        # in the view resolves to the same object.
        import apps.accounts
        apps.accounts.services = module
    return module


class GovernanceTestBase(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.superuser = _make_user('root@example.com', 'root',
                                    is_staff=True, is_superuser=True)
        self.operator = _make_user('operator@example.com', 'operator', is_staff=True)
        self.member = _make_user('member@example.com', 'member')

        # Two distinct staff: one raises a request, one approves it.
        #
        # The requester holds users.write via a stored scope on top of the
        # 'support' defaults — raising a ban request needs the scope even though
        # the ban itself will be applied by someone else. Keeping them on
        # 'support' means the two-person split is doing real work: the requester
        # could have applied the ban directly through the portal and did not.
        self.requester = _make_user('requester@example.com', 'requester', is_staff=True)
        self.approver = _make_user('approver@example.com', 'approver', is_staff=True)
        _grant(self.requester, 'support', scopes=['users.write'])
        _grant(self.approver, 'admin')


# ---------------------------------------------------------------------------
# Scope enforcement
# ---------------------------------------------------------------------------

class ScopeEnforcementTests(GovernanceTestBase):
    """A role without the scope must be stopped, at 403, naming the scope."""

    def setUp(self):
        super().setUp()
        _grant(self.operator, 'finance')
        self.client.force_authenticate(self.operator)

    def test_missing_scope_is_403_and_names_the_scope(self):
        # finance holds orders.write + wallet.*; the users list needs users.read.
        response = self.client.get(f'{PORTAL}/users/')
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
        self.assertIn('users.read', response.data['message'])
        self.assertIn('finance', response.data['message'])

    def test_correct_scope_is_allowed(self):
        response = self.client.get(f'{PORTAL}/orders/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data['success'])

    def test_detail_route_scope_is_enforced_too(self):
        # UserDetailView declares 'users', which finance does not hold.
        response = self.client.get(f'{PORTAL}/users/{self.member.id}/')
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
        self.assertIn('users', response.data['message'])

    def test_staff_without_a_role_keeps_full_access(self):
        """The back-compat branch: no StaffRole row means unrestricted."""
        plain = _make_user('plainstaff@example.com', 'plainstaff', is_staff=True)
        self.client.force_authenticate(plain)

        self.assertEqual(
            self.client.get(f'{PORTAL}/users/').status_code, status.HTTP_200_OK
        )
        self.assertEqual(
            self.client.get(f'{PORTAL}/orders/').status_code, status.HTTP_200_OK
        )

    def test_superuser_always_passes_even_with_a_narrow_role(self):
        _grant(self.superuser, 'support')
        self.client.force_authenticate(self.superuser)
        for path in (f'{PORTAL}/users/', f'{PORTAL}/orders/', f'{PORTAL}/wallet/reconciliation/'):
            with self.subTest(path=path):
                self.assertEqual(
                    self.client.get(path).status_code, status.HTTP_200_OK
                )

    def test_non_staff_is_403_without_scope_detail(self):
        self.client.force_authenticate(self.member)
        response = self.client.get(f'{PORTAL}/users/')
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
        # A non-staff caller learns nothing about the scope vocabulary.
        self.assertNotIn('users.read', response.data['message'])

    def test_anonymous_is_401(self):
        self.client.force_authenticate(None)
        self.assertEqual(
            self.client.get(f'{PORTAL}/users/').status_code, status.HTTP_401_UNAUTHORIZED
        )

    def test_revoked_role_removes_every_scope(self):
        """Revocation must not fall through to the permissive no-role branch.

        It is tempting to treat "has a row, but it is revoked" the same as "has no
        row" — the row grants nothing either way. That would be a privilege
        escalation: the only way to lock someone out would be to also delete
        their row, and deleting is what revoke exists to avoid.
        """
        row = _grant(_make_user('revoked@example.com', 'revoked', is_staff=True),
                     'admin')
        row.revoked_at = row.granted_at
        row.save(update_fields=['revoked_at'])

        self.client.force_authenticate(row.user)
        response = self.client.get(f'{PORTAL}/users/')
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
        self.assertIn('revoked', response.data['message'])

    def test_stored_scopes_widen_but_do_not_replace_the_role_defaults(self):
        finance = _make_user('wide@example.com', 'wide', is_staff=True)
        _grant(finance, 'finance', scopes=['users.read'])

        self.client.force_authenticate(finance)
        # From DEFAULT_SCOPES_BY_ROLE — not in the stored list.
        self.assertEqual(
            self.client.get(f'{PORTAL}/orders/').status_code, status.HTTP_200_OK
        )
        # From the stored extras.
        self.assertEqual(
            self.client.get(f'{PORTAL}/users/').status_code, status.HTTP_200_OK
        )
        # Still not held: nothing grants users.write.
        response = self.client.get(f'{PORTAL}/users/{self.member.id}/')
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)


class ScopeDefinitionTests(TestCase):
    """The scope table itself — the thing every check depends on."""

    @staticmethod
    def _declared_route_scopes():
        """Every scope actually declared by a portal view's permission_classes.

        Collected from the view classes, not by grepping the source: for_scope()
        builds an anonymous subclass per call, so the scope is only visible on the
        ``permission_classes`` attribute of a view.

        Scans both modules that serve ``/api/v1/portal/``. The platform
        analytics routes are portal routes but live in ``apps.analytics``
        (they own the models and the query code), so reading only
        ``admin_portal`` would report the analytics scopes as undeclared and
        flag them as the dead privilege this test exists to catch.
        """
        import apps.admin_portal.views as portal_views
        import apps.analytics.platform_views as analytics_views

        declared = set()
        for module in (portal_views, analytics_views):
          for name in dir(module):
            view = getattr(module, name)
            if not isinstance(view, type):
                continue
            for permission in getattr(view, 'permission_classes', ()):
                # permission_classes holds classes, so walk the class's own mro.
                # Match structurally rather than by class name: for_scope()
                # mints an anonymous subclass whose name embeds the declaring
                # class, so a subclass of ScopedPlatformAdmin that renames
                # itself would otherwise read as undeclared.
                if not any(
                    getattr(klass, '__name__', '') == 'ScopedPlatformAdmin'
                    for klass in getattr(permission, '__mro__', ())
                ):
                    continue
                scope = getattr(permission, 'required_scope', None)
                if scope:
                    declared.add(scope)
        return declared

    def test_every_route_scope_is_in_all_scopes(self):
        """A route declaring an unregistered scope is unreachable for any role.

        The drift is silent in production — the route just always 403s — so it is
        pinned here instead of left to a code review to notice.
        """
        declared = self._declared_route_scopes()
        self.assertTrue(declared, 'no scoped permissions found in admin_portal.views')
        self.assertEqual(declared - set(ALL_SCOPES), set())

    def test_all_scopes_has_no_entry_no_route_uses(self):
        """The reverse drift: a registered scope nothing checks.

        An unused ALL_SCOPES entry is a back-compat privilege for role-less staff
        with nothing behind it, which is worth knowing about.
        """
        self.assertEqual(set(ALL_SCOPES) - self._declared_route_scopes(), set())

    def test_the_governance_itself_is_scoped(self):
        """Governance must not be the way around its own scope enforcement."""
        import apps.governance.views as governance_views

        scoped = set()
        for name in dir(governance_views):
            view = getattr(governance_views, name)
            if not isinstance(view, type):
                continue
            for permission in getattr(view, 'permission_classes', ()):
                for klass in getattr(permission, '__mro__', ()):
                    if klass.__name__.startswith('ScopedPlatformAdmin['):
                        scoped.add(klass.required_scope)
        self.assertTrue(scoped, 'a governance view is not scope-checked')
        self.assertTrue(scoped <= set(ALL_SCOPES))

    def test_every_role_has_default_scopes(self):
        from .models import DEFAULT_SCOPES_BY_ROLE
        for choice, _label in StaffRole.ROLE_CHOICES:
            self.assertIn(choice, DEFAULT_SCOPES_BY_ROLE)

    def test_role_scopes_are_all_known(self):
        """Every scope a role hands out must be a scope this platform knows.

        The moderator role holds ``moderation.*`` and support holds
        ``users.write-lite`` — neither is in ALL_SCOPES, because no route reads
        them yet. Those are tracked in UNROUTED_SCOPES, so the check stays
        meaningful instead of being loosened to "anything goes".
        """
        from .models import DEFAULT_SCOPES_BY_ROLE, KNOWN_SCOPES

        for role, scopes in DEFAULT_SCOPES_BY_ROLE.items():
            with self.subTest(role=role):
                self.assertEqual(scopes - set(KNOWN_SCOPES), set())


class EffectiveScopesTests(GovernanceTestBase):
    """``effective_scopes`` is the single source of truth; test it directly."""

    def test_admin_holds_every_scope(self):
        from .services import effective_scopes, has_scope

        admin = _make_user('full@example.com', 'full', is_staff=True)
        _grant(admin, 'admin')
        self.assertEqual(effective_scopes(admin), set(ALL_SCOPES))
        self.assertTrue(has_scope(admin, 'wallet.reconcile'))

    def test_non_staff_and_none_hold_nothing(self):
        from .services import effective_scopes, has_scope

        self.assertEqual(effective_scopes(self.member), set())
        self.assertEqual(effective_scopes(None), set())
        self.assertFalse(has_scope(self.member, 'users.read'))

    def test_empty_scope_string_is_never_held(self):
        from .services import has_scope
        self.assertFalse(has_scope(self.superuser, ''))
        self.assertFalse(has_scope(self.superuser, None))

    def test_malformed_stored_scopes_do_not_raise(self):
        from .services import effective_scopes

        odd = _make_user('odd@example.com', 'odd', is_staff=True)
        _grant(odd, 'support', scopes=['users.read', 7, None, {'a': 1}, 'orders.read'])
        scopes = effective_scopes(odd)
        self.assertIn('users.read', scopes)
        self.assertIsInstance(scopes, set)

    def test_moderator_role_does_not_hold_users_write(self):
        from .services import effective_scopes, has_scope

        mod = _make_user('mod@example.com', 'mod', is_staff=True)
        _grant(mod, 'moderator')
        self.assertTrue(has_scope(mod, 'moderation.reports.read'))
        self.assertFalse(has_scope(mod, 'users.write'))
        self.assertFalse(has_scope(mod, 'wallet.reconcile'))
        self.assertTrue(effective_scopes(mod))


# ---------------------------------------------------------------------------
# Two-person approval
# ---------------------------------------------------------------------------

class TwoPersonApprovalTests(GovernanceTestBase):
    def setUp(self):
        super().setUp()
        self.accounts_services = _accounts_services_stub()

    def _raise(self, action='ban', target=None, **extra):
        payload = {'reason': 'Repeated fraud after two warnings', **extra.pop('payload', {})}
        return self.client.post(
            f'{PREFIX}/approvals/request/',
            {
                'action': action,
                'target_user': str((target or self.member).id),
                'payload': payload,
            },
            format='json',
        )

    # -- raising ---------------------------------------------------------

    def test_request_is_created_pending_with_a_name_snapshot(self):
        self.client.force_authenticate(self.requester)
        response = self._raise()
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

        approval = AccountActionRequest.objects.get(pk=response.data['data']['id'])
        self.assertEqual(approval.status, 'pending')
        self.assertTrue(approval.requires_second)
        self.assertIsNone(approval.decided_by)
        self.assertEqual(approval.requested_by, self.requester)
        # Survives the account row.
        self.assertEqual(approval.requested_by_profile, 'Requester')

    def test_requester_must_hold_the_actions_scope(self):
        weak = _make_user('weak@example.com', 'weak', is_staff=True)
        _grant(weak, 'support')  # no users.write
        self.client.force_authenticate(weak)

        response = self._raise()
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
        self.assertIn('users.write', response.data['message'])

    def test_ban_requires_a_reason(self):
        self.client.force_authenticate(self.requester)
        response = self.client.post(
            f'{PREFIX}/approvals/request/',
            {'action': 'ban', 'target_user': str(self.member.id), 'payload': {}},
            format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_cannot_raise_against_yourself_or_a_superuser(self):
        self.client.force_authenticate(self.requester)
        self.assertEqual(
            self._raise(target=self.requester).status_code,
            status.HTTP_403_FORBIDDEN,
        )
        self.assertEqual(
            self._raise(target=self.superuser).status_code,
            status.HTTP_403_FORBIDDEN,
        )

    # -- self-approval ---------------------------------------------------

    def test_self_approval_is_403_on_every_decide_verb(self):
        self.client.force_authenticate(self.requester)
        pk = self._raise().data['data']['id']

        for verb in ('approve', 'reject', 'cancel'):
            with self.subTest(verb=verb):
                response = self.client.post(
                    f'{PREFIX}/approvals/{pk}/{verb}/',
                    {'note': 'looks fine to me'},
                    format='json',
                )
                self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
                self.assertIn('cannot be the one who decides', response.data['message'])

        approval = AccountActionRequest.objects.get(pk=pk)
        self.assertEqual(approval.status, 'pending')
        self.assertIsNone(approval.applied_at)

    # -- approver scope --------------------------------------------------

    def test_approver_without_the_actions_scope_is_403(self):
        self.client.force_authenticate(self.requester)
        pk = self._raise().data['data']['id']

        unrelated = _make_user('shoprel@example.com', 'shoprel', is_staff=True)
        _grant(unrelated, 'verification_regulator')  # no users.write
        self.client.force_authenticate(unrelated)

        response = self.client.post(f'{PREFIX}/approvals/{pk}/approve/', {}, format='json')
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
        self.assertIn('users.write', response.data['message'])
        self.assertEqual(
            AccountActionRequest.objects.get(pk=pk).status, 'pending'
        )

    def test_payout_needs_orders_write_not_users_write(self):
        """The approver's required scope follows the action, not a global default."""
        # Raising a payout needs orders.write, so the requester for *this* test
        # holds it. The default requester (support + users.write) could not raise
        # one, and that is checked separately by
        # test_requester_must_hold_the_actions_scope.
        payer = _make_user('payer@example.com', 'payer', is_staff=True)
        _grant(payer, 'support', scopes=['users.write', 'orders.write'])
        self.client.force_authenticate(payer)
        pk = self._raise(action='payout', payload={'amount': 5000}).data['data']['id']

        finance_only = _make_user('fin@example.com', 'fin', is_staff=True)
        _grant(finance_only, 'support', scopes=['users.write'])  # wrong scope
        self.client.force_authenticate(finance_only)
        denied = self.client.post(f'{PREFIX}/approvals/{pk}/approve/', {}, format='json')
        self.assertEqual(denied.status_code, status.HTTP_403_FORBIDDEN)
        self.assertIn('orders.write', denied.data['message'])

        self.client.force_authenticate(self.approver)  # admin: has orders.write
        allowed = self.client.post(f'{PREFIX}/approvals/{pk}/approve/', {}, format='json')
        self.assertEqual(allowed.status_code, status.HTTP_200_OK)

    # -- apply-once ------------------------------------------------------

    def test_ban_approve_calls_apply_standing_action_exactly_once(self):
        self.client.force_authenticate(self.requester)
        pk = self._raise(payload={'duration_days': None}).data['data']['id']

        target = 'apps.accounts.services.apply_standing_action'
        with mock.patch(target) as apply_action:
            self.client.force_authenticate(self.approver)
            response = self.client.post(
                f'{PREFIX}/approvals/{pk}/approve/',
                {'note': 'Evidence reviewed'},
                format='json',
            )

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        apply_action.assert_called_once()
        kwargs = apply_action.call_args.kwargs
        self.assertEqual(kwargs['target_user_id'], self.member.id)
        self.assertEqual(kwargs['action'], 'user_banned')
        self.assertEqual(kwargs['reason'], 'Repeated fraud after two warnings')
        self.assertEqual(kwargs['actor'], self.approver)
        self.assertEqual(kwargs['source'], f'governance:{pk}')

        approval = AccountActionRequest.objects.get(pk=pk)
        self.assertEqual(approval.status, 'approved')
        self.assertIsNotNone(approval.applied_at)
        self.assertEqual(approval.decided_by, self.approver)

    def test_suspension_maps_to_user_suspended_and_passes_duration(self):
        self.client.force_authenticate(self.requester)
        pk = self._raise(action='suspension', payload={'duration_days': 7}).data['data']['id']

        with mock.patch.object(
            self.accounts_services, 'apply_standing_action'
        ) as apply_action:
            self.client.force_authenticate(self.approver)
            response = self.client.post(f'{PREFIX}/approvals/{pk}/approve/', {}, format='json')

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(apply_action.call_args.kwargs['action'], 'user_suspended')
        self.assertEqual(apply_action.call_args.kwargs['duration_days'], 7)

    def test_second_decide_is_409_not_a_silent_reapply(self):
        self.client.force_authenticate(self.requester)
        pk = self._raise().data['data']['id']

        with mock.patch.object(
            self.accounts_services, 'apply_standing_action'
        ) as apply_action:
            self.client.force_authenticate(self.approver)
            first = self.client.post(f'{PREFIX}/approvals/{pk}/approve/', {}, format='json')
            second = self.client.post(f'{PREFIX}/approvals/{pk}/approve/', {}, format='json')

        self.assertEqual(first.status_code, status.HTTP_200_OK)
        self.assertEqual(second.status_code, status.HTTP_409_CONFLICT)
        self.assertIn('already', second.data['message'])
        apply_action.assert_called_once()  # the whole point

    def test_reject_then_approve_is_409(self):
        self.client.force_authenticate(self.requester)
        pk = self._raise().data['data']['id']

        self.client.force_authenticate(self.approver)
        rejected = self.client.post(
            f'{PREFIX}/approvals/{pk}/reject/', {'note': 'Insufficient evidence'}, format='json'
        )
        self.assertEqual(rejected.status_code, status.HTTP_200_OK)

        third = _make_user('third@example.com', 'third', is_staff=True)
        _grant(third, 'admin')
        self.client.force_authenticate(third)
        response = self.client.post(f'{PREFIX}/approvals/{pk}/approve/', {}, format='json')
        self.assertEqual(response.status_code, status.HTTP_409_CONFLICT)

    def test_failed_apply_leaves_the_request_pending(self):
        self.client.force_authenticate(self.requester)
        pk = self._raise().data['data']['id']

        with mock.patch.object(
            self.accounts_services, 'apply_standing_action',
            side_effect=ValueError('unknown action'),
        ):
            self.client.force_authenticate(self.approver)
            response = self.client.post(f'{PREFIX}/approvals/{pk}/approve/', {}, format='json')

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('unknown action', response.data['message'])

        approval = AccountActionRequest.objects.get(pk=pk)
        self.assertEqual(approval.status, 'pending')
        self.assertIsNone(approval.decided_by)
        self.assertIsNone(approval.applied_at)

        # And it is still decidable afterwards.
        self.client.force_authenticate(self.approver)
        retry = self.client.post(f'{PREFIX}/approvals/{pk}/approve/', {}, format='json')
        self.assertEqual(retry.status_code, status.HTTP_200_OK)

    def test_missing_apply_standing_action_reports_clearly(self):
        """A missing hook must degrade into a readable 400, request still pending.

        Not an AttributeError escaping as a 500. The accounts-side
        ``apply_standing_action`` is owned by another app and may not be there
        yet; a half-deployed pair should refuse cleanly, not crash the approver's
        request.
        """
        self.client.force_authenticate(self.requester)
        pk = self._raise().data['data']['id']

        real = self.accounts_services.__dict__.pop('apply_standing_action', None)
        try:
            self.client.force_authenticate(self.approver)
            response = self.client.post(
                f'{PREFIX}/approvals/{pk}/approve/', {}, format='json'
            )
        finally:
            if real is not None:
                self.accounts_services.apply_standing_action = real

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('pending', response.data['message'])
        self.assertEqual(
            AccountActionRequest.objects.get(pk=pk).status, 'pending'
        )

    # -- notes -----------------------------------------------------------

    def test_reject_requires_a_note(self):
        self.client.force_authenticate(self.requester)
        pk = self._raise().data['data']['id']
        self.client.force_authenticate(self.approver)

        blank = self.client.post(f'{PREFIX}/approvals/{pk}/reject/', {}, format='json')
        self.assertEqual(blank.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('note', blank.data['message'])

        whitespace = self.client.post(
            f'{PREFIX}/approvals/{pk}/reject/', {'note': '   '}, format='json'
        )
        self.assertEqual(whitespace.status_code, status.HTTP_400_BAD_REQUEST)

        with_note = self.client.post(
            f'{PREFIX}/approvals/{pk}/reject/', {'note': 'No fraud shown'}, format='json'
        )
        self.assertEqual(with_note.status_code, status.HTTP_200_OK)
        self.assertEqual(AccountActionRequest.objects.get(pk=pk).status, 'rejected')

    def test_cancel_requires_a_note(self):
        self.client.force_authenticate(self.requester)
        pk = self._raise().data['data']['id']
        self.client.force_authenticate(self.approver)

        blank = self.client.post(f'{PREFIX}/approvals/{pk}/cancel/', {}, format='json')
        self.assertEqual(blank.status_code, status.HTTP_400_BAD_REQUEST)

        ok = self.client.post(
            f'{PREFIX}/approvals/{pk}/cancel/', {'note': 'Wrong account id'}, format='json'
        )
        self.assertEqual(ok.status_code, status.HTTP_200_OK)
        self.assertEqual(AccountActionRequest.objects.get(pk=pk).status, 'cancelled')


# ---------------------------------------------------------------------------
# Staff role endpoints
# ---------------------------------------------------------------------------

class StaffRoleTests(GovernanceTestBase):
    def setUp(self):
        super().setUp()
        self.client.force_authenticate(self.approver)  # admin: holds 'users'

    def test_grant_requiring_second_approval_applies_nothing(self):
        response = self.client.post(
            f'{PREFIX}/staff-roles/',
            {'user': str(self.requester.id), 'role': 'finance',
             'scopes': [], 'requires_second': True},
            format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_202_ACCEPTED)

        approval = AccountActionRequest.objects.get()
        self.assertEqual(approval.action, 'staff_role_grant')
        self.assertEqual(approval.target_user, self.requester)
        self.assertEqual(approval.payload['role'], 'finance')
        self.assertEqual(approval.status, 'pending')
        # Nothing applied yet — the existing row is untouched.
        self.assertEqual(StaffRole.objects.get(user=self.requester).role, 'support')

    def test_approved_staff_role_grant_activates_the_role(self):
        self.client.post(
            f'{PREFIX}/staff-roles/',
            {'user': str(self.requester.id), 'role': 'finance', 'requires_second': True},
            format='json',
        )
        approval = AccountActionRequest.objects.get()

        self.client.force_authenticate(self.superuser)
        response = self.client.post(
            f'{PREFIX}/approvals/{approval.id}/approve/', {'note': 'Approved'}, format='json'
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(StaffRole.objects.get(user=self.requester).role, 'finance')
        self.assertEqual(StaffRole.objects.get(user=self.requester).granted_by, self.superuser)

    def test_grant_without_second_approval_applies_directly(self):
        response = self.client.post(
            f'{PREFIX}/staff-roles/',
            {'user': str(self.requester.id), 'role': 'logistics', 'requires_second': False},
            format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(StaffRole.objects.get(user=self.requester).role, 'logistics')
        self.assertEqual(AccountActionRequest.objects.count(), 0)

    def test_granting_yourself_a_role_is_403(self):
        response = self.client.post(
            f'{PREFIX}/staff-roles/',
            {'user': str(self.approver.id), 'role': 'admin', 'requires_second': False},
            format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
        self.assertIn('cannot grant yourself', response.data['message'])
        self.assertEqual(StaffRole.objects.get(user=self.approver).role, 'admin')

    def test_cannot_patch_or_revoke_your_own_role(self):
        row = StaffRole.objects.get(user=self.approver)
        for verb, body in (('patch', {'role': 'support'}), ('delete', None)):
            with self.subTest(verb=verb):
                method = getattr(self.client, verb)
                kwargs = {'format': 'json'} if body else {}
                response = method(
                    f'{PREFIX}/staff-roles/{row.id}/', data=body, **kwargs
                )
                self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    def test_list_and_detail(self):
        response = self.client.get(f'{PREFIX}/staff-roles/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('pagination', response.data)

        row = StaffRole.objects.get(user=self.requester)
        detail = self.client.get(f'{PREFIX}/staff-roles/{row.id}/')
        self.assertEqual(detail.status_code, status.HTTP_200_OK)
        self.assertEqual(detail.data['data']['role'], 'support')
        self.assertIn('users.read', detail.data['data']['default_scopes'])

    def test_list_filters_are_validated(self):
        self.assertEqual(
            self.client.get(f'{PREFIX}/staff-roles/?role=nope').status_code,
            status.HTTP_400_BAD_REQUEST,
        )
        self.assertEqual(
            self.client.get(f'{PREFIX}/staff-roles/?role=finance').status_code,
            status.HTTP_200_OK,
        )

    def test_unknown_scope_is_rejected_at_write_time(self):
        """A typo would otherwise be a silent no-op that 403s later."""
        response = self.client.post(
            f'{PREFIX}/staff-roles/',
            {'user': str(self.requester.id), 'role': 'support',
             'scopes': ['users.readd'], 'requires_second': False},
            format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('users.readd', str(response.data))

    def test_delete_revokes_and_blocks_double_revoke(self):
        row = StaffRole.objects.get(user=self.requester)
        first = self.client.delete(f'{PREFIX}/staff-roles/{row.id}/')
        self.assertEqual(first.status_code, status.HTTP_200_OK)
        self.assertIsNotNone(first.data['data']['revoked_at'])
        # The row survives as the audit trail.
        self.assertTrue(StaffRole.objects.filter(pk=row.id).exists())

        second = self.client.delete(f'{PREFIX}/staff-roles/{row.id}/')
        self.assertEqual(second.status_code, status.HTTP_409_CONFLICT)

    def test_cannot_role_a_non_staff_user(self):
        response = self.client.post(
            f'{PREFIX}/staff-roles/',
            {'user': str(self.member.id), 'role': 'support', 'requires_second': False},
            format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_role_endpoints_need_the_users_scope(self):
        support_only = _make_user('sup@example.com', 'sup', is_staff=True)
        _grant(support_only, 'support')  # users.read but not 'users'
        self.client.force_authenticate(support_only)
        response = self.client.get(f'{PREFIX}/staff-roles/')
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)


class ApprovalListTests(GovernanceTestBase):
    def setUp(self):
        super().setUp()
        self.client.force_authenticate(self.approver)
        for i in range(3):
            target = _make_user(f'm{i}@example.com', f'm{i}')
            AccountActionRequest.objects.create(
                action='ban' if i % 2 else 'payout',
                target_user=target,
                requested_by=self.requester,
                requested_by_profile='Requester',
                status='pending' if i else 'approved',
            )

    def test_filters(self):
        self.assertEqual(
            self.client.get(f'{PREFIX}/approvals/?status=pending').data['pagination']['count'],
            2,
        )
        self.assertEqual(
            self.client.get(f'{PREFIX}/approvals/?action=payout').data['pagination']['count'],
            2,
        )
        self.assertEqual(
            self.client.get(f'{PREFIX}/approvals/?mine=false').data['pagination']['count'],
            3,
        )
        # `mine` filters on the *acting* user. Every row here was raised by
        # self.requester, so the counts flip when the acting user does.
        self.assertEqual(
            self.client.get(f'{PREFIX}/approvals/?mine=true').data['pagination']['count'],
            0,
        )
        self.client.force_authenticate(self.requester)
        self.assertEqual(
            self.client.get(f'{PREFIX}/approvals/?mine=true').data['pagination']['count'],
            3,
        )

    def test_target_user_filter(self):
        approval = AccountActionRequest.objects.filter(status='pending').first()
        self.client.force_authenticate(self.approver)
        matched = self.client.get(
            f'{PREFIX}/approvals/?target_user={approval.target_user_id}'
        )
        self.assertEqual(matched.data['pagination']['count'], 1)

    def test_bad_filter_values_are_400(self):
        for query in ('?status=nope', '?action=nope'):
            with self.subTest(query=query):
                response = self.client.get(f'{PREFIX}/approvals/{query}')
                self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
                self.assertIn('Must be one of', response.data['message'])

    def test_detail(self):
        approval = AccountActionRequest.objects.first()
        response = self.client.get(f'{PREFIX}/approvals/{approval.id}/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['data']['id'], str(approval.id))

    def test_approvals_need_users_read(self):
        from .services import has_scope

        # An admin approver holds users.read via ALL_SCOPES; a role without it
        # cannot even see the queue.
        narrow = _make_user('nar@example.com', 'nar', is_staff=True)
        _grant(narrow, 'finance', scopes=[])
        self.assertFalse(has_scope(narrow, 'users.read'))

        self.client.force_authenticate(narrow)
        self.assertEqual(
            self.client.get(f'{PREFIX}/approvals/').status_code,
            status.HTTP_403_FORBIDDEN,
        )


# ---------------------------------------------------------------------------
# Audit trail
# ---------------------------------------------------------------------------

class AuditWriterTests(GovernanceTestBase):
    """``record_admin_action`` itself — the one function every app calls."""

    def test_snapshots_the_actor_email_and_survives_the_account(self):
        from .models import AdminActionLog
        from .services import record_admin_action

        row = record_admin_action(
            actor=self.operator, action='users.suspend',
            summary='Suspended a member.', target_type='user', target_id=str(self.member.id),
        )
        self.assertIsNotNone(row)
        self.assertEqual(row.actor, self.operator)
        self.assertEqual(row.actor_email, 'operator@example.com')

        # Deleting the staff account must not delete the evidence that it acted.
        self.operator.delete()
        row.refresh_from_db()
        self.assertIsNone(row.actor)
        self.assertEqual(row.actor_email, 'operator@example.com')
        self.assertTrue(AdminActionLog.objects.filter(pk=row.pk).exists())

    def test_reads_request_metadata_when_a_request_is_supplied(self):
        self.client.force_authenticate(self.approver)
        request = self.client.post(
            f'{PREFIX}/staff-roles/',
            {'user': str(self.requester.id), 'role': 'logistics', 'requires_second': False},
            format='json', HTTP_X_REQUEST_ID='audit-check-123',
            HTTP_USER_AGENT='GovernanceTestAgent/1.0',
        )
        self.assertEqual(request.status_code, status.HTTP_201_CREATED)

        row = AdminActionLog.objects.filter(action='staff_roles.grant_requested').first()
        self.assertIsNotNone(row)
        self.assertEqual(row.request_id, 'audit-check-123')
        self.assertEqual(row.user_agent, 'GovernanceTestAgent/1.0')
        self.assertEqual(row.actor, self.approver)
        self.assertEqual(row.actor_email, 'approver@example.com')

    def test_survives_a_missing_request_and_a_missing_actor(self):
        """Total by design: an audit gap must never 500 a real mutation."""
        from .services import record_admin_action

        row = record_admin_action(action='system.sweep', summary='No actor, no request.')
        self.assertIsNotNone(row)
        self.assertIsNone(row.actor)
        self.assertEqual(row.actor_email, '')
        self.assertEqual(row.request_id, '')
        self.assertIsNone(row.ip_address)
        self.assertEqual(record_admin_action(action='system.sweep', summary='x').actor, None)

    def test_redacts_secrets_bodies_and_gps_from_before_and_after(self):
        """The privacy contract, enforced rather than documented."""
        from .services import record_admin_action

        row = record_admin_action(
            actor=self.operator, action='users.update', summary='Profile edited.',
            before={'refresh_token': 'secret-refresh', 'Body': 'my private message'},
            after={
                'access_token': 'secret-access',
                'password': 'hunter2',
                'totp_secret': 'JBSWY3DP',
                'otp_code': '123456',
                'latitude': 51.5072,
                'longitude': -0.1276,
                'message_body': 'dear support, ...',
                'role': 'support',
                'email': 'member@example.com',
            },
        )

        after = row.after
        for key in ('access_token', 'password', 'totp_secret', 'otp_code',
                    'latitude', 'longitude', 'message_body'):
            with self.subTest(key=key):
                self.assertEqual(after[key], '[redacted]')
        # A state delta and the one identifier an audit genuinely needs survive.
        self.assertEqual(after['role'], 'support')
        self.assertEqual(after['email'], 'member@example.com')
        # Case- and separator-insensitive matching.
        self.assertEqual(row.before['Body'], '[redacted]')
        self.assertEqual(row.before['refresh_token'], '[redacted]')

    def test_truncates_an_oversized_payload_rather_than_storing_it(self):
        from .services import record_admin_action

        row = record_admin_action(
            actor=self.operator, action='users.update', summary='x',
            after={'notes': 'y' * 5000, 'history': list(range(500))},
        )
        self.assertLessEqual(len(row.after['notes']), 501)
        self.assertLessEqual(len(row.after['history']), 50)

    def test_never_raises_on_a_write_failure(self):
        """A failed audit write is logged, not raised: the mutation already applied."""
        from .models import AdminActionLog
        from .services import record_admin_action

        with mock.patch.object(
            AdminActionLog.objects, 'create', side_effect=RuntimeError('db is down')
        ):
            self.assertIsNone(
                record_admin_action(actor=self.operator, action='users.suspend', summary='x')
            )


class GovernanceAuditCoverageTests(GovernanceTestBase):
    """Every mutating governance route writes exactly one row."""

    def setUp(self):
        super().setUp()
        self.client.force_authenticate(self.approver)  # admin: holds 'users' and users.read

    def test_staff_role_grant_is_audited(self):
        response = self.client.post(
            f'{PREFIX}/staff-roles/',
            {'user': str(self.requester.id), 'role': 'logistics', 'requires_second': False},
            format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

        row = AdminActionLog.objects.filter(action='staff_roles.grant_requested').first()
        self.assertIsNotNone(row)
        self.assertEqual(row.actor, self.approver)
        self.assertEqual(row.after['role'], 'logistics')

    def test_staff_role_revoke_is_audited_with_the_before_state(self):
        role_row = StaffRole.objects.get(user=self.requester)
        response = self.client.delete(f'{PREFIX}/staff-roles/{role_row.id}/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)

        row = AdminActionLog.objects.filter(action='staff_roles.revoke').first()
        self.assertIsNotNone(row)
        self.assertEqual(row.target_id, str(role_row.id))
        self.assertEqual(row.before['role'], 'support')
        self.assertIsNone(row.before['revoked_at'])
        self.assertIsNotNone(row.after['revoked_at'])

    def test_approval_request_is_audited(self):
        requester = _make_user('req2@example.com', 'req2', is_staff=True)
        _grant(requester, 'support', scopes=['users.write'])
        self.client.force_authenticate(requester)

        response = self.client.post(
            f'{PREFIX}/approvals/request/',
            {'action': 'ban', 'target_user': str(self.member.id),
             'payload': {'reason': 'Fraud'}},
            format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

        row = AdminActionLog.objects.filter(action='approvals.request').first()
        self.assertIsNotNone(row)
        self.assertEqual(row.after['action'], 'ban')
        self.assertEqual(row.actor, requester)

    def test_every_decide_verb_is_audited(self):
        """approve, reject and cancel are three separate events, each with its
        own row. Each verb needs its own fresh request: a settled one is a 409
        by design."""
        for verb, expected in (('approve', 'approved'), ('reject', 'rejected'),
                                ('cancel', 'cancelled')):
            with self.subTest(verb=verb):
                AdminActionLog.objects.filter(action='approvals.decide').delete()
                self.client.force_authenticate(self.requester)
                raised = self.client.post(
                    f'{PREFIX}/approvals/request/',
                    {'action': 'ban', 'target_user': str(self.member.id),
                     'payload': {'reason': 'Fraud'}},
                    format='json',
                )
                pk = raised.data['data']['id']

                self.client.force_authenticate(self.approver)
                response = self.client.post(
                    f'{PREFIX}/approvals/{pk}/{verb}/',
                    {'note': 'reviewed'}, format='json',
                )
                self.assertEqual(response.status_code, status.HTTP_200_OK)
                row = AdminActionLog.objects.filter(action='approvals.decide').get()
                self.assertEqual(row.after['status'], expected)
                self.assertEqual(row.actor, self.approver)

    def test_approved_role_grant_records_both_the_decision_and_the_effect(self):
        """A role change is recorded twice on purpose: the call and the effect."""
        self.client.post(
            f'{PREFIX}/staff-roles/',
            {'user': str(self.requester.id), 'role': 'finance', 'requires_second': True},
            format='json',
        )
        approval = AccountActionRequest.objects.get()
        self.client.force_authenticate(self.superuser)
        response = self.client.post(
            f'{PREFIX}/approvals/{approval.id}/approve/', {'note': 'ok'}, format='json'
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)

        self.assertTrue(AdminActionLog.objects.filter(action='approvals.decide').exists())
        effect = AdminActionLog.objects.filter(action='staff_roles.grant').first()
        self.assertIsNotNone(effect)
        self.assertEqual(effect.after['role'], 'finance')
        self.assertEqual(effect.before['role'], 'support')

    def test_a_rejected_mutation_is_not_audited(self):
        """4xx changed nothing, so logging it would bury the real events."""
        before = AdminActionLog.objects.count()
        response = self.client.post(
            f'{PREFIX}/staff-roles/',
            {'user': str(self.approver.id), 'role': 'admin', 'requires_second': False},
            format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
        self.assertEqual(AdminActionLog.objects.count(), before)

    def test_a_read_is_not_audited(self):
        before = AdminActionLog.objects.count()
        self.client.get(f'{PREFIX}/staff-roles/')
        self.assertEqual(AdminActionLog.objects.count(), before)


class AuditReadTests(GovernanceTestBase):
    """The four recall endpoints."""

    def setUp(self):
        super().setUp()
        self.client.force_authenticate(self.approver)
        self.member_one = AdminActionLog.objects.create(
            actor=self.approver, actor_email='approver@example.com',
            action='users.suspend', target_type='user', target_id=str(self.member.id),
            summary='Suspended, first action', before={'is_active': True},
            after={'is_active': False},
        )
        self.member_two = AdminActionLog.objects.create(
            actor=self.requester, actor_email='requester@example.com',
            action='users.reinstate', target_type='user', target_id=str(self.member.id),
            summary='Reinstated, second action',
        )
        self.other = AdminActionLog.objects.create(
            actor=self.approver, actor_email='approver@example.com',
            action='orders.status_change', target_type='order', target_id='order-42',
            summary='Shipped an order',
        )

    def test_list_is_newest_first(self):
        response = self.client.get(f'{PREFIX}/audit/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        ids = [row['id'] for row in response.data['data']]
        self.assertEqual(len(ids), 3)
        self.assertEqual(ids[0], str(self.other.id))
        self.assertEqual(ids[-1], str(self.member_one.id))

    def test_filters(self):
        cases = {
            'action': ('?action=users.suspend', [self.member_one]),
            'target_type': ('?target_type=order', [self.other]),
            'target_id': (f'?target_type=user&target_id={self.member.id}',
                          [self.member_one, self.member_two]),
            'actor': (f'?actor={self.requester.id}', [self.member_two]),
        }
        for name, (query, expected) in cases.items():
            with self.subTest(filter=name):
                response = self.client.get(f'{PREFIX}/audit/{query}')
                self.assertEqual(response.status_code, status.HTTP_200_OK)
                self.assertEqual(
                    response.data['pagination']['count'], len(expected)
                )

    def test_date_filters(self):
        today = timezone.now().date().isoformat()
        self.assertEqual(
            self.client.get(f'{PREFIX}/audit/?date_from={today}').data['pagination']['count'], 3
        )
        self.assertEqual(
            self.client.get(f'{PREFIX}/audit/?date_to={today}').data['pagination']['count'], 3
        )
        self.assertEqual(
            self.client.get(f'{PREFIX}/audit/?date_from=2099-01-01').data['pagination']['count'], 0
        )

    def test_malformed_filters_are_400_not_an_empty_list(self):
        """A typo that returned [] would read as "nothing happened"."""
        for query in (
            '?action=not a verb', '?action=Users.Suspend', '?target_type=User',
            '?actor=not-a-uuid', '?date_from=yesterday', '?date_to=soon',
        ):
            with self.subTest(query=query):
                response = self.client.get(f'{PREFIX}/audit/{query}')
                self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
                self.assertIn('message', response.data)

    def test_detail_returns_before_and_after(self):
        response = self.client.get(f'{PREFIX}/audit/{self.member_one.id}/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.data['data']
        self.assertEqual(data['before'], {'is_active': True})
        self.assertEqual(data['after'], {'is_active': False})
        self.assertEqual(data['action'], 'users.suspend')

    def test_timeline_is_chronological_for_one_object(self):
        response = self.client.get(
            f'{PREFIX}/audit/timeline/?target_type=user&target_id={self.member.id}'
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(
            [row['id'] for row in response.data['data']],
            [str(self.member_one.id), str(self.member_two.id)],
        )

    def test_timeline_requires_a_target_type(self):
        """Without it, "the timeline" means every action ever taken."""
        response = self.client.get(f'{PREFIX}/audit/timeline/')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('target_type is required', response.data['message'])

    def test_audit_reads_need_users_read(self):
        from .services import has_scope

        narrow = _make_user('nar2@example.com', 'nar2', is_staff=True)
        _grant(narrow, 'finance', scopes=[])
        self.assertFalse(has_scope(narrow, 'users.read'))

        self.client.force_authenticate(narrow)
        for path in (f'{PREFIX}/audit/', f'{PREFIX}/audit/{self.other.id}/',
                     f'{PREFIX}/audit/timeline/?target_type=user'):
            with self.subTest(path=path):
                self.assertEqual(
                    self.client.get(path).status_code, status.HTTP_403_FORBIDDEN
                )

    def test_audit_reads_are_never_non_staff(self):
        self.client.force_authenticate(self.member)
        self.assertEqual(
            self.client.get(f'{PREFIX}/audit/').status_code, status.HTTP_403_FORBIDDEN
        )


class AuditExportTests(GovernanceTestBase):
    """CSV export, mirroring ``apps.gyms.views.GymMemberCSVView``."""

    def setUp(self):
        super().setUp()
        self.client.force_authenticate(self.approver)
        AdminActionLog.objects.create(
            actor=self.approver, actor_email='approver@example.com',
            action='users.suspend', target_type='user', target_id=str(self.member.id),
            summary='Suspended "Bob", the fraudster',
            before={'note': 'first, second'},
            after={'note': 'third'},
        )

    def _csv(self, query=''):
        response = self.client.get(f'{PREFIX}/audit/export/{query}')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response['Content-Type'], 'text/csv')
        self.assertTrue(response['Content-Disposition'].startswith('attachment;'))
        self.assertIn('admin-audit-', response['Content-Disposition'])
        return list(csv.reader(io.StringIO(response.content.decode('utf-8'))))

    def test_headers_and_row_count(self):
        rows = self._csv()
        self.assertEqual(rows[0], AuditExportView.COLUMNS)
        self.assertEqual(len(rows), 2)
        self.assertEqual(rows[1][2], 'users.suspend')
        self.assertEqual(rows[1][3], 'approver@example.com')

    def test_commas_and_quotes_are_escaped_not_column_shifting(self):
        """A summary with a comma and a quote must not move a cell across."""
        rows = self._csv()
        self.assertEqual(len(rows[1]), len(AuditExportView.COLUMNS))
        self.assertEqual(rows[1][6], 'Suspended "Bob", the fraudster')
        self.assertEqual(rows[1][7], "{'note': 'first, second'}")

    def test_the_export_honours_the_same_filters_as_the_list(self):
        AdminActionLog.objects.create(
            actor=self.approver, action='orders.status_change',
            target_type='order', target_id='o-1', summary='Shipped',
        )
        rows = self._csv('?target_type=order')
        self.assertEqual(len(rows), 2)
        self.assertEqual(rows[1][2], 'orders.status_change')

    def test_a_malformed_filter_is_400_not_a_file(self):
        response = self.client.get(f'{PREFIX}/audit/export/?action=NOT A VERB')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)


# ---------------------------------------------------------------------------
# Assistance console
# ---------------------------------------------------------------------------

class AssistanceConsoleTestBase(GovernanceTestBase):
    """Django's send_mail is patched at the source module.

    The console's contract is what ends up in ``EmailLog``, not what SMTP did,
    so the assertions are about the recorded outcome. Patching
    ``django.core.mail.EmailMultiAlternatives.send`` is also what makes the
    "failed then resent" test possible without a real broker.
    """

    def setUp(self):
        super().setUp()
        # The DRF throttle scopes live in the process-local cache and survive
        # between tests in a run; a leftover 'otp' count from an accounts test
        # would make a console test 429 for the wrong reason.
        cache.clear()
        self.client.force_authenticate(self.approver)

    @staticmethod
    def _send(**overrides):
        payload = {
            'email': 'member@example.com',
            'subject': 'About your account',
            'body': 'We reviewed your case and the charge has been reversed.',
        }
        payload.update(overrides)
        return payload

    @contextmanager
    def _mailer(self, side_effect=None):
        """Capture what the worker sent, without a broker.

        Patching ``send`` on the class means the mock is reached as a plain
        attribute lookup, so ``self`` is *not* passed. The side effect takes the
        message explicitly to recover it.
        """
        sent = []

        def _send(message, *args, **kwargs):
            sent.append(message)
            if side_effect is not None:
                raise side_effect

        with mock.patch('django.core.mail.EmailMultiAlternatives.send', _send):
            yield sent


class EmailServiceTests(AssistanceConsoleTestBase):
    """``send_templated_email`` and the task behind it."""

    def test_queues_a_log_then_marks_it_sent_and_audits_the_send(self):
        from .emails import send_templated_email

        with self._mailer() as sent:
            log = send_templated_email(
                to_email=self.member.email,
                subject='About your account',
                template_key='staff_message',
                context={'staff_name': 'Approver', 'body': 'Your charge was reversed.'},
                sent_by=self.approver,
            )
            # Queued is written *before* the worker is handed anything.
            self.assertEqual(len(sent), 1)
            log.refresh_from_db()
            self.assertEqual(log.status, 'sent')
            self.assertEqual(log.recipient_user, self.member)
            self.assertEqual(log.sent_by, self.approver)
            self.assertEqual(log.sent_by_email, 'approver@example.com')
            self.assertTrue(log.body_preview)
            self.assertLessEqual(len(log.body_preview), 500)

        audit = AdminActionLog.objects.filter(action='emails.send').first()
        self.assertIsNotNone(audit)
        self.assertEqual(audit.actor, self.approver)
        self.assertEqual(audit.after['template_key'], 'staff_message')
        self.assertEqual(audit.after['recipient_email'], 'member@example.com')
        # The subject may be recorded; the body never is.
        self.assertNotIn('body', audit.after)

    def test_the_sent_message_carries_the_staff_name_logo_and_reply_to(self):
        """The template contract: a named human, the logo, and a reply address."""
        from .emails import send_templated_email

        with self._mailer() as sent:
            send_templated_email(
                to_email=self.member.email, subject='About your account',
                template_key='staff_message',
                context={'staff_name': 'Casey Support', 'body': 'Your charge was reversed.'},
                sent_by=self.approver,
            )
            message = sent[0]

        self.assertEqual(message.to, [self.member.email])
        self.assertEqual(message.subject, 'About your account')
        self.assertTrue(message.reply_to)
        html = message.alternatives[0][0]
        self.assertEqual(message.alternatives[0][1], 'text/html')
        self.assertIn('Casey Support', html)
        self.assertIn('Your charge was reversed.', html)
        self.assertIn(message.reply_to[0], html)
        self.assertIn('icon-512.png', html)  # the logo, as the OTP email has it
        # Staff-authored text is escaped, not injected.
        self.assertNotIn('<script>', html)

    def test_staff_text_in_a_message_body_is_escaped(self):
        from .emails import send_templated_email

        with self._mailer() as sent:
            send_templated_email(
                to_email=self.member.email, subject='Hi',
                template_key='staff_message',
                context={'staff_name': 'Casey', 'body': '<script>alert(1)</script>'},
                sent_by=self.approver,
            )
            html = sent[0].alternatives[0][0]
        self.assertNotIn('<script>alert(1)</script>', html)
        self.assertIn('&lt;script&gt;', html)

    def test_delivery_failure_retries_then_marks_failed(self):
        """The retry the other tasks in this codebase are missing."""
        from .emails import deliver_templated_email

        log = EmailLog.objects.create(
            recipient_user=self.member, recipient_email=self.member.email,
            subject='About your account', template_key='staff_message',
            sent_by=self.approver,
        )
        with mock.patch('django.core.mail.EmailMultiAlternatives.send') as send:
            send.side_effect = OSError('SMTP blip')
            # Stand in for the last of max_retries, so this *is* the final try.
            original_retries = deliver_templated_email.request.retries
            deliver_templated_email.request.retries = deliver_templated_email.max_retries
            try:
                with mock.patch.object(deliver_templated_email, 'retry',
                                       side_effect=RuntimeError('exhausted')) as retry:
                    with self.assertRaises(RuntimeError):
                        deliver_templated_email(str(log.id))
                    self.assertEqual(retry.call_count, 1)
            finally:
                deliver_templated_email.request.retries = original_retries

        log.refresh_from_db()
        self.assertEqual(log.status, 'failed')
        self.assertIn('SMTP blip', log.error)
        # And the failure is itself an audit event, not only a log row.
        self.assertTrue(AdminActionLog.objects.filter(action='emails.send_failed').exists())

    def test_a_transient_failure_does_not_mark_failed_before_the_last_attempt(self):
        """A 'failed' row next to a message about to be delivered teaches staff
        to ignore the log, so the row is only marked on the final attempt."""
        from .emails import deliver_templated_email

        log = EmailLog.objects.create(
            recipient_user=self.member, recipient_email=self.member.email,
            subject='About your account', template_key='staff_message',
        )
        with mock.patch('django.core.mail.EmailMultiAlternatives.send') as send:
            send.side_effect = OSError('SMTP blip')
            with mock.patch.object(deliver_templated_email, 'retry',
                                   side_effect=RuntimeError('retrying')):
                with self.assertRaises(RuntimeError):
                    deliver_templated_email(str(log.id))

        log.refresh_from_db()
        self.assertEqual(log.status, 'queued')  # still in flight

    def test_an_unregistered_template_key_fails_without_retrying(self):
        from .emails import deliver_templated_email

        log = EmailLog.objects.create(
            recipient_user=self.member, recipient_email=self.member.email,
            subject='x', template_key='../../etc/passwd',
        )
        self.assertIsNone(deliver_templated_email(str(log.id)))
        log.refresh_from_db()
        self.assertEqual(log.status, 'failed')
        self.assertIn('Unregistered template', log.error)

    def test_a_purged_log_row_is_a_silent_no_op(self):
        from .emails import deliver_templated_email

        self.assertIsNone(deliver_templated_email(
            '00000000-0000-0000-0000-000000000000'
        ))

    def test_a_dedupe_key_suppresses_a_second_live_attempt(self):
        from .emails import send_templated_email

        with self._mailer() as sent:
            first = send_templated_email(
                to_email=self.member.email, subject='Password reset',
                template_key='staff_message', context={'body': 'x'},
                dedupe_key='password_reset:abc',
            )
            second = send_templated_email(
                to_email=self.member.email, subject='Password reset',
                template_key='staff_message', context={'body': 'x'},
                dedupe_key='password_reset:abc',
            )
            self.assertEqual(len(sent), 1)

        first.refresh_from_db()
        self.assertEqual(first.status, 'sent')
        # The suppressed duplicate is still *visible*, with a reason — a dedupe
        # that vanished would look like a message we forgot to send.
        self.assertEqual(second.status, 'skipped')
        self.assertIn('Suppressed', second.error)

    def test_a_context_that_cannot_cross_the_broker_fails_at_queue_time(self):
        """Better a visible error now than an empty staff name in an inbox."""
        from .emails import send_templated_email

        with self._mailer():
            with self.assertRaises(ValueError):
                send_templated_email(
                    to_email=self.member.email, subject='x',
                    template_key='staff_message', context='not a dict',
                )
            with self.assertRaises(ValueError):
                send_templated_email(
                    to_email=self.member.email, subject='x',
                    template_key='staff_message',
                    context={'body': 'x' * 20_000},
                )
        self.assertEqual(EmailLog.objects.count(), 0)

    def test_a_non_primitive_context_value_is_stringified_not_dropped(self):
        from .emails import send_templated_email

        with self._mailer() as sent:
            send_templated_email(
                to_email=self.member.email, subject='x',
                template_key='staff_message',
                context={'staff_name': self.member, 'body': 'Hi', 'when': timezone.now()},
            )
            html = sent[0].alternatives[0][0]
        self.assertIn(self.member.email, html)  # the User, rendered as its address
        self.assertIn('Hi', html)

    def test_a_failed_attempt_does_not_block_its_own_retry(self):
        """Otherwise the resend endpoint would be unreachable exactly when it
        is most wanted."""
        from .emails import dedupe_blocks

        EmailLog.objects.create(
            recipient_email=self.member.email, subject='x',
            dedupe_key='k', status='failed',
        )
        self.assertFalse(dedupe_blocks('k'))
        EmailLog.objects.create(
            recipient_email=self.member.email, subject='x', dedupe_key='k', status='queued',
        )
        self.assertTrue(dedupe_blocks('k'))


class EmailSendEndpointTests(AssistanceConsoleTestBase):
    def test_send_writes_a_queued_row_and_an_audit_entry(self):
        with self._mailer():
            response = self.client.post(
                f'{PREFIX}/emails/send/', self._send(), format='json'
            )
        self.assertEqual(response.status_code, status.HTTP_202_ACCEPTED)

        log = EmailLog.objects.get()
        self.assertEqual(log.status, 'sent')  # eager worker already delivered
        self.assertEqual(log.recipient_email, 'member@example.com')
        self.assertEqual(log.sent_by, self.approver)
        self.assertEqual(response.data['data']['id'], str(log.id))

        audit = AdminActionLog.objects.filter(action='emails.send').get()
        self.assertEqual(audit.actor, self.approver)
        self.assertEqual(audit.actor_email, 'approver@example.com')
        self.assertEqual(audit.after['email_log_id'], str(log.id))

    def test_a_user_id_recipient_is_accepted_and_resolved(self):
        with self._mailer():
            response = self.client.post(
                f'{PREFIX}/emails/send/',
                {'user_id': str(self.member.id), 'subject': 'Hi', 'body': 'Hello there.'},
                format='json',
            )
        self.assertEqual(response.status_code, status.HTTP_202_ACCEPTED)
        self.assertEqual(EmailLog.objects.get().recipient_user, self.member)

    def test_an_unregistered_address_is_refused(self):
        """The hard rule: this console cannot become a relay for arbitrary mail."""
        response = self.client.post(
            f'{PREFIX}/emails/send/',
            self._send(email='stranger@not-a-user.example'), format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('No account is registered', str(response.data['errors']))
        self.assertEqual(EmailLog.objects.count(), 0)
        self.assertEqual(AdminActionLog.objects.filter(action='emails.send').count(), 0)

    def test_a_bulk_payload_is_refused_outright(self):
        """No list field exists, and unknown keys are a 400 rather than ignored."""
        response = self.client.post(
            f'{PREFIX}/emails/send/',
            {**self._send(), 'recipients': ['a@example.com', 'b@example.com']},
            format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('recipients', str(response.data['errors']))
        self.assertEqual(EmailLog.objects.count(), 0)

    def test_cc_and_bcc_are_refused_too(self):
        for field in ('cc', 'bcc', 'to'):
            with self.subTest(field=field):
                response = self.client.post(
                    f'{PREFIX}/emails/send/',
                    {**self._send(), field: 'spy@elsewhere.example'}, format='json',
                )
                self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_a_deleted_account_cannot_be_messaged(self):
        self.member.deleted_at = timezone.now()
        self.member.save(update_fields=['deleted_at'])
        response = self.client.post(
            f'{PREFIX}/emails/send/', self._send(), format='json'
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(EmailLog.objects.count(), 0)

    def test_the_recipient_must_be_given_and_not_ambiguous(self):
        for payload, expected in (
            ({'subject': 'a', 'body': 'b'}, 'user_id'),
            ({'user_id': str(self.member.id), 'email': 'member@example.com',
              'subject': 'a', 'body': 'b'}, 'not both'),
        ):
            with self.subTest(payload=payload):
                response = self.client.post(
                    f'{PREFIX}/emails/send/', payload, format='json'
                )
                self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
                self.assertIn(expected, str(response.data['errors']))

    def test_sending_needs_users_read(self):
        from .services import has_scope

        narrow = _make_user('nar3@example.com', 'nar3', is_staff=True)
        _grant(narrow, 'finance', scopes=[])
        self.assertFalse(has_scope(narrow, 'users.read'))

        self.client.force_authenticate(narrow)
        response = self.client.post(f'{PREFIX}/emails/send/', self._send(), format='json')
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
        self.assertEqual(EmailLog.objects.count(), 0)

    def test_a_non_staff_caller_cannot_use_the_console(self):
        self.client.force_authenticate(self.member)
        self.assertEqual(
            self.client.post(f'{PREFIX}/emails/send/', self._send(), format='json').status_code,
            status.HTTP_403_FORBIDDEN,
        )

    def test_the_send_endpoint_reuses_an_existing_throttle_scope(self):
        """An invented scope name is not a rate limit, it is the absence of one."""
        from .emails import EMAIL_TEMPLATES  # noqa: F401  (import sanity)
        from .views import EmailResendView, StaffEmailSendView

        from django.conf import settings

        known = set(settings.REST_FRAMEWORK['DEFAULT_THROTTLE_RATES'])
        for view in (StaffEmailSendView, EmailResendView):
            with self.subTest(view=view.__name__):
                self.assertIn(view.throttle_scope, known)


class EmailRateCeilingTests(AssistanceConsoleTestBase):
    @staticmethod
    def _log(sent_by, status, minutes_ago=5, index=0):
        return EmailLog.objects.create(
            recipient_email='member@example.com',
            subject=f'x{index}',
            sent_by=sent_by,
            status=status,
            created_at=timezone.now() - timedelta(minutes=minutes_ago),
        )

    def _fill_the_ceiling(self, sent_by, status='sent'):
        """Fill the hourly window with ``STAFF_EMAIL_HOURLY_CEILING`` live rows."""
        for index in range(STAFF_EMAIL_HOURLY_CEILING):
            self._log(sent_by, status, index=index)

    def test_the_per_staff_ceiling_trips(self):
        self._fill_the_ceiling(self.approver)
        live = EmailLog.objects.filter(sent_by=self.approver, status__in=['queued', 'sent'])
        self.assertEqual(live.count(), STAFF_EMAIL_HOURLY_CEILING)

        with self._mailer():
            response = self.client.post(
                f'{PREFIX}/emails/send/', self._send(), format='json'
            )
        self.assertEqual(response.status_code, status.HTTP_429_TOO_MANY_REQUESTS)
        self.assertIn(str(STAFF_EMAIL_HOURLY_CEILING), response.data['message'])
        # Nothing was queued: the ceiling refuses, it does not silently drop.
        self.assertEqual(EmailLog.objects.count(), STAFF_EMAIL_HOURLY_CEILING)
        self.assertEqual(AdminActionLog.objects.filter(action='emails.send').count(), 0)

    def test_failed_and_skipped_rows_do_not_count_against_the_ceiling(self):
        """A ceiling that punished a worker for its failures would train staff
        to stop retrying."""
        for index in range(STAFF_EMAIL_HOURLY_CEILING):
            self._log(self.approver, 'failed', index=index)
            self._log(self.approver, 'skipped', index=index)

        with self._mailer():
            response = self.client.post(
                f'{PREFIX}/emails/send/', self._send(), format='json'
            )
        self.assertEqual(response.status_code, status.HTTP_202_ACCEPTED)

    def test_the_ceiling_counts_this_account_only(self):
        """A shared office IP must not be one operator's problem."""
        self._fill_the_ceiling(self.requester)
        with self._mailer():
            response = self.client.post(
                f'{PREFIX}/emails/send/', self._send(), format='json'
            )
        self.assertEqual(response.status_code, status.HTTP_202_ACCEPTED)

    def test_the_ceiling_window_expires(self):
        self._log(self.approver, 'sent', minutes_ago=180)
        with self._mailer():
            response = self.client.post(
                f'{PREFIX}/emails/send/', self._send(), format='json'
            )
        self.assertEqual(response.status_code, status.HTTP_202_ACCEPTED)

    def test_resend_is_covered_by_the_same_ceiling(self):
        failed = self._log(self.approver, 'failed')
        self._fill_the_ceiling(self.approver)
        with self._mailer():
            response = self.client.post(
                f'{PREFIX}/emails/{failed.id}/resend/', {}, format='json'
            )
        self.assertEqual(response.status_code, status.HTTP_429_TOO_MANY_REQUESTS)


class EmailLogTests(AssistanceConsoleTestBase):
    def test_the_delivery_log_filters(self):
        EmailLog.objects.create(
            recipient_user=self.member, recipient_email=self.member.email,
            subject='Delivered', status='sent', sent_by=self.approver,
        )
        EmailLog.objects.create(
            recipient_user=self.member, recipient_email=self.member.email,
            subject='Broken', status='failed', sent_by=self.requester,
        )
        EmailLog.objects.create(
            recipient_email='someone-else@example.com', subject='Other',
            status='queued', sent_by=self.requester,
        )

        cases = {
            '?status=failed': 1,
            '?status=sent': 1,
            '?recipient_email=member@example.com': 2,
            f'?sent_by={self.requester.id}': 2,
            '?recipient_email=nobody@example.com': 0,
        }
        for query, expected in cases.items():
            with self.subTest(query=query):
                response = self.client.get(f'{PREFIX}/emails/log/{query}')
                self.assertEqual(response.status_code, status.HTTP_200_OK)
                self.assertEqual(response.data['pagination']['count'], expected)

    def test_bad_filters_are_400(self):
        for query in ('?status=nope', '?sent_by=not-a-uuid'):
            with self.subTest(query=query):
                self.assertEqual(
                    self.client.get(f'{PREFIX}/emails/log/{query}').status_code,
                    status.HTTP_400_BAD_REQUEST,
                )

    def test_the_log_never_returns_a_full_body(self):
        with self._mailer():
            self.client.post(
                f'{PREFIX}/emails/send/',
                self._send(body='A' * 4000), format='json',
            )
        response = self.client.get(f'{PREFIX}/emails/log/')
        preview = response.data['data'][0]['body_preview']
        self.assertLessEqual(len(preview), 500)
        self.assertNotIn('A' * 501, str(response.data))

    def test_the_delivery_log_needs_users_read(self):
        self.client.force_authenticate(self.member)
        self.assertEqual(
            self.client.get(f'{PREFIX}/emails/log/').status_code,
            status.HTTP_403_FORBIDDEN,
        )


class EmailResendTests(AssistanceConsoleTestBase):
    def _failed(self, **kwargs):
        return EmailLog.objects.create(
            recipient_user=self.member, recipient_email=self.member.email,
            subject='About your account', template_key='staff_message',
            sent_by=self.approver, status='failed', error='SMTP blip', **kwargs,
        )

    def test_a_failed_send_can_be_resent(self):
        original = self._failed(dedupe_key='retry-me')
        with self._mailer() as sent:
            response = self.client.post(
                f'{PREFIX}/emails/{original.id}/resend/', {}, format='json'
            )
            self.assertEqual(response.status_code, status.HTTP_202_ACCEPTED)
            self.assertEqual(len(sent), 1)

        resent = EmailLog.objects.exclude(pk=original.pk).get()
        self.assertEqual(resent.status, 'sent')
        self.assertEqual(resent.recipient_email, original.recipient_email)
        self.assertEqual(resent.dedupe_key, 'retry-me')
        self.assertEqual(resent.error, '')  # a fresh row, not the old failure

    def test_only_a_failed_send_can_be_resent(self):
        """Re-sending a delivered message is a duplicate nobody asked for."""
        for status_value in ('sent', 'queued', 'skipped'):
            with self.subTest(status=status_value):
                original = self._failed()
                original.status = status_value
                original.save(update_fields=['status'])

                with self._mailer() as sent:
                    response = self.client.post(
                        f'{PREFIX}/emails/{original.id}/resend/', {}, format='json'
                    )
                    self.assertEqual(
                        response.status_code, status.HTTP_409_CONFLICT
                    )
                    self.assertEqual(len(sent), 0)

    def test_resend_works_when_a_later_attempt_already_was_sent(self):
        original = self._failed(dedupe_key='dup')
        EmailLog.objects.create(
            recipient_email=self.member.email, subject='x',
            dedupe_key='dup', status='sent',
        )
        with self._mailer() as sent:
            response = self.client.post(
                f'{PREFIX}/emails/{original.id}/resend/', {}, format='json'
            )
            self.assertEqual(response.status_code, status.HTTP_202_ACCEPTED)
            self.assertEqual(len(sent), 0)  # deduped, not re-delivered
        self.assertEqual(EmailLog.objects.order_by('created_at').last().status, 'skipped')

    def test_resend_audits_against_the_operator_who_pressed_the_button(self):
        original = self._failed()
        with self._mailer():
            self.client.post(f'{PREFIX}/emails/{original.id}/resend/', {}, format='json')
        audit = AdminActionLog.objects.filter(action='emails.send').get()
        self.assertEqual(audit.actor, self.approver)

    def test_resend_requires_the_users_read_scope(self):
        original = self._failed()
        self.client.force_authenticate(self.member)
        self.assertEqual(
            self.client.post(f'{PREFIX}/emails/{original.id}/resend/', {}, format='json').status_code,
            status.HTTP_403_FORBIDDEN,
        )


class StaffRoleRevokeReasonTests(TestCase):
    """An operator prompted for a revoke reason must not have it dropped."""

    def setUp(self):
        self.admin = User.objects.create_user(
            email='revoke-admin@example.com', password='TestPass123!', is_staff=True,
        )
        self.holder = Profile.objects.create(
            user=User.objects.create_user(email='revoke-holder@example.com', password='TestPass123!'),
            username='revoke-holder',
        )
        self.role = StaffRole.objects.create(
            user=self.holder.user, role='moderator', scopes=['orders.read'],
        )
        self.client = APIClient()
        self.client.force_authenticate(user=self.admin)

    def test_revoke_reason_is_persisted_and_audited(self):
        res = self.client.delete(
            f'/api/v1/governance/staff-roles/{self.role.id}/',
            {'notes': 'Moved to the support team.'}, format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_200_OK, res.content)
        self.role.refresh_from_db()
        self.assertEqual(self.role.notes, 'Moved to the support team.')
        self.assertIsNotNone(self.role.revoked_at)

        entries = AdminActionLog.objects.filter(action='staff_roles.revoke')
        self.assertEqual(entries.count(), 1)
        self.assertIn('Moved to the support team.', entries.first().summary)

    def test_revoke_without_a_reason_still_works(self):
        res = self.client.delete(f'/api/v1/governance/staff-roles/{self.role.id}/')
        self.assertEqual(res.status_code, status.HTTP_200_OK, res.content)
        self.role.refresh_from_db()
        self.assertIsNotNone(self.role.revoked_at)
        self.assertEqual(self.role.notes, '')

    def test_revoked_role_grants_no_scopes(self):
        self.client.delete(
            f'/api/v1/governance/staff-roles/{self.role.id}/',
            {'notes': 'done'}, format='json',
        )
        from apps.governance.services import effective_scopes
        self.assertEqual(effective_scopes(self.holder.user), set())


class ApprovalApplyBranchSafetyTests(TestCase):
    """No branch of ``ApprovalApproveView._apply`` may raise NameError.

    A bare undefined name in this method is a 500 that fires *after* the
    approval row is stamped applied, so the decision is unrecoverable and the
    two-person trail is corrupted. One branch (verification_decision) already
    shipped exactly that way, so every branch is now swept on purpose.
    """

    ACTIONS = [
        'verification_decision',
        'staff_role_grant',
        'platform_suspend',
        'unknown_future_action',
    ]

    def setUp(self):
        self.requester = User.objects.create_user(
            email='branch-requester@example.com', password='TestPass123!', is_staff=True,
        )
        self.approver = User.objects.create_user(
            email='branch-approver@example.com', password='TestPass123!', is_staff=True,
        )
        self.target = User.objects.create_user(
            email='branch-target@example.com', password='TestPass123!',
        )

    def _apply(self, action):
        from apps.governance.models import AccountActionRequest
        from apps.governance.views import ApprovalApproveView

        approval = AccountActionRequest.objects.create(
            action=action,
            target_user=self.target,
            payload={'reason': 'swept by the branch-safety test'},
            requested_by=self.requester,
            decision_note='second approver signed off',
        )
        request = APIRequestFactory().post('/')
        request.user = self.approver

        try:
            return ApprovalApproveView()._apply(request, approval)
        except NameError as exc:  # pragma: no cover - the regression itself
            self.fail(f'_apply raised NameError on action={action!r}: {exc}')
        except Exception as exc:  # noqa: BLE001 - domain errors are fine here
            # The point of the sweep is name resolution, not the domain result.
            self.assertNotIsInstance(exc, NameError)

    def test_no_action_branch_raises_name_error(self):
        for action in self.ACTIONS:
            with self.subTest(action=action):
                self._apply(action)

    def test_verification_decision_uses_the_approvers_own_note(self):
        """The effect must carry the approval's decision_note, never a stray local."""
        from apps.governance.models import AccountActionRequest
        from apps.governance.views import ApprovalApproveView

        seen = {}

        class _Recorder:
            @staticmethod
            def apply_decision(request_row, actor, note):
                seen['note'] = note
                seen['actor'] = actor
                return True, 'verification approved'

        with mock.patch(
            'apps.verification.decisions.apply_decision',
            _Recorder.apply_decision,
            create=True,
        ):
            approval = AccountActionRequest.objects.create(
                action='verification_decision',
                target_user=self.target,
                payload={},
                requested_by=self.requester,
                decision_note='documents looked legitimate',
            )
            request = APIRequestFactory().post('/')
            request.user = self.approver

            result = ApprovalApproveView()._apply(request, approval)

        self.assertIn('verification approved', result)
        self.assertEqual(seen['note'], 'documents looked legitimate')
        self.assertEqual(seen['actor'], self.approver)


class StaffRoleNotificationTests(GovernanceTestBase):
    """A staff authority change must reach the person it happened to.

    Governance's only other signal is the audit log, which the holder has no
    reason to read. These tests exist because every grant/revoke path wrote the
    row and notified nobody.
    """

    def setUp(self):
        super().setUp()
        self.client.force_authenticate(self.approver)

    def _notifications_for(self, user, notification_type):
        from apps.notifications.models import Notification

        return list(
            Notification.objects.filter(
                recipient__user=user, notification_type=notification_type,
            ).order_by('created_at')
        )

    def test_direct_grant_notifies_the_holder(self):
        self.client.post(
            f'{PREFIX}/staff-roles/',
            {'user': str(self.requester.id), 'role': 'logistics', 'requires_second': False},
            format='json',
        )
        notes = self._notifications_for(self.requester, 'staff_role_granted')
        self.assertEqual(len(notes), 1, [n.title for n in notes])
        self.assertEqual(notes[0].metadata['role'], 'logistics')
        self.assertEqual(notes[0].metadata['previous_role'], 'support')
        self.assertIn('logistics', notes[0].title)

    def test_approval_applied_grant_notifies_with_the_before_role(self):
        self.client.post(
            f'{PREFIX}/staff-roles/',
            {'user': str(self.requester.id), 'role': 'finance', 'requires_second': True},
            format='json',
        )
        approval = AccountActionRequest.objects.get()

        self.client.force_authenticate(self.superuser)
        self.client.post(
            f'{PREFIX}/approvals/{approval.id}/approve/', {'note': 'Approved'}, format='json'
        )

        notes = self._notifications_for(self.requester, 'staff_role_granted')
        self.assertEqual(len(notes), 1, [n.title for n in notes])
        self.assertEqual(notes[0].metadata['role'], 'finance')
        self.assertEqual(notes[0].metadata['previous_role'], 'support')

    def test_requesting_a_grant_notifies_nobody_yet(self):
        """202 means nothing has happened. Announcing it would be a lie."""
        self.client.post(
            f'{PREFIX}/staff-roles/',
            {'user': str(self.requester.id), 'role': 'finance', 'requires_second': True},
            format='json',
        )
        self.assertEqual(self._notifications_for(self.requester, 'staff_role_granted'), [])

    def test_revoke_notifies_the_holder_with_the_reason(self):
        row = StaffRole.objects.get(user=self.requester)
        response = self.client.delete(
            f'{PREFIX}/staff-roles/{row.id}/',
            {'notes': 'Left the operations team.'},
            format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)

        notes = self._notifications_for(self.requester, 'staff_role_revoked')
        self.assertEqual(len(notes), 1, [n.title for n in notes])
        self.assertIn('Left the operations team.', notes[0].body)

    def test_narrowing_a_role_notifies_the_holder(self):
        row = StaffRole.objects.get(user=self.requester)
        response = self.client.patch(
            f'{PREFIX}/staff-roles/{row.id}/', {'role': 'support'}, format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)

        notes = self._notifications_for(self.requester, 'staff_role_granted')
        self.assertEqual(len(notes), 1, [n.title for n in notes])
        self.assertEqual(notes[0].metadata['previous_role'], 'support')

    def test_a_refused_self_revoke_notifies_nobody(self):
        """The guard must fire before anything is written or announced."""
        row = StaffRole.objects.get(user=self.approver)
        response = self.client.delete(f'{PREFIX}/staff-roles/{row.id}/', format='json')
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
        self.assertEqual(self._notifications_for(self.approver, 'staff_role_revoked'), [])


class StaffInvitationTests(TestCase):
    """Invitation -> accept -> working staff account.

    This is the path that did not exist. ``StaffRole`` could not be granted to
    anybody who was not already ``is_staff``, and nothing set ``is_staff``, so
    staff onboarding required editing the database by hand. The one real staff
    account is still the evidence: ``is_superuser`` with no ``StaffRole`` row.
    """

    PREFIX = '/api/v1/governance'

    def setUp(self):
        from apps.accounts.models import User
        from apps.profiles.models import Profile

        self.User = User
        self.Profile = Profile
        self.inviter = _make_user('inviter@example.com', 'inviter', is_staff=True, is_superuser=True)
        _grant(self.inviter, 'admin')
        self.approver = _make_user('second@example.com', 'second', is_staff=True)
        _grant(self.approver, 'admin')
        self.client = APIClient()
        self.client.force_authenticate(self.inviter)

    def _make_invitee(self, email='newhire@example.com'):
        user = _make_user(email, 'newhire')
        self.assertFalse(user.is_staff, 'fixture must start as a non-staff account')
        return user

    def _invite(self, email='newhire@example.com', **overrides):
        payload = {'email': email, 'role': 'support'}
        payload.update(overrides)
        return self.client.post(f'{self.PREFIX}/staff-invitations/', payload, format='json')

    def _accept(self, token, user):
        accept = APIClient()
        accept.force_authenticate(user)
        return accept.post(f'{self.PREFIX}/staff-invitations/accept/{token}/', {}, format='json')

    # --- creating ---

    def test_invite_with_second_approval_sends_nothing(self):
        response = self._invite()
        self.assertEqual(response.status_code, status.HTTP_202_ACCEPTED, response.data)

        from apps.governance.models import StaffInvitation

        invitation = StaffInvitation.objects.get()
        self.assertEqual(invitation.status, 'pending')
        self.assertEqual(invitation.role, 'support')
        self.assertTrue(AccountActionRequest.objects.filter(
            action='staff_invitation', status='pending').exists())

    def test_second_approver_is_what_releases_the_email(self):
        self._invite()
        from apps.governance.models import StaffInvitation

        approval = AccountActionRequest.objects.get(action='staff_invitation')

        self.client.force_authenticate(self.approver)
        response = self.client.post(
            f'{self.PREFIX}/approvals/{approval.id}/approve/', {'note': 'ok'}, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK, response.data)
        self.assertIn('emailed', response.data['message'])

        # Still pending: nobody is staff until the invitee accepts.
        self.assertEqual(StaffInvitation.objects.get().status, 'pending')

    def test_direct_invite_skips_the_queue_when_asked(self):
        response = self._invite(requires_second=False)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED, response.data)
        self.assertEqual(AccountActionRequest.objects.count(), 0)

    def test_you_cannot_invite_yourself(self):
        response = self._invite(email='inviter@example.com', requires_second=False)
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    def test_two_pending_invitations_for_one_address_are_refused(self):
        self.assertEqual(self._invite(requires_second=False).status_code, status.HTTP_201_CREATED)
        second = self._invite(requires_second=False)
        self.assertEqual(second.status_code, status.HTTP_400_BAD_REQUEST)

    def test_an_existing_staff_address_is_refused_with_the_right_pointer(self):
        response = self._invite(email='second@example.com', requires_second=False)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('already has a staff account', str(response.data).lower())

    def test_unknown_scopes_are_refused(self):
        response = self._invite(requires_second=False, scopes=['not.a.scope'])
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    # --- accepting ---

    def test_accepting_sets_is_staff_and_creates_the_role(self):
        """The two writes that make the account usable."""
        self._invite(requires_second=False)
        from apps.governance.models import StaffInvitation

        invitation = StaffInvitation.objects.get()
        invitee = self._make_invitee()

        response = self._accept(invitation.token, invitee)
        self.assertEqual(response.status_code, status.HTTP_200_OK, response.data)

        invitee.refresh_from_db()
        self.assertTrue(invitee.is_staff, 'accepting an invitation is what sets is_staff')

        role = StaffRole.objects.get(user=invitee)
        self.assertEqual(role.role, 'support')
        self.assertIsNone(role.revoked_at)

        invitation.refresh_from_db()
        self.assertEqual(invitation.status, 'accepted')
        self.assertEqual(invitation.accepted_by, invitee)

    def test_accepting_notifies_the_new_staff_member(self):
        self._invite(requires_second=False)
        from apps.governance.models import StaffInvitation

        invitation = StaffInvitation.objects.get()
        invitee = self._make_invitee()
        self._accept(invitation.token, invitee)

        from apps.notifications.models import Notification

        notes = list(Notification.objects.filter(
            recipient__user=invitee, notification_type='staff_role_granted'))
        self.assertEqual(len(notes), 1, [n.title for n in notes])
        self.assertEqual(notes[0].metadata['role'], 'support')
        self.assertEqual(notes[0].metadata['via'], 'staff_invitation')

    def test_the_token_alone_cannot_mint_an_administrator(self):
        """The security property. A leaked link must not be a credential."""
        self._invite(email='newhire@example.com', role='admin', requires_second=False)
        from apps.governance.models import StaffInvitation

        invitation = StaffInvitation.objects.get()
        attacker = _make_user('attacker@evil.com', 'attacker')

        response = self._accept(invitation.token, attacker)
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

        attacker.refresh_from_db()
        self.assertFalse(attacker.is_staff)
        self.assertFalse(StaffRole.objects.filter(user=attacker).exists())
        self.assertEqual(StaffInvitation.objects.get().status, 'pending')

    def test_accepting_requires_authentication(self):
        self._invite(requires_second=False)
        from apps.governance.models import StaffInvitation

        token = StaffInvitation.objects.get().token
        response = APIClient().post(
            f'{self.PREFIX}/staff-invitations/accept/{token}/', {}, format='json')
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_an_invitation_cannot_be_accepted_twice(self):
        self._invite(requires_second=False)
        from apps.governance.models import StaffInvitation

        invitation = StaffInvitation.objects.get()
        invitee = self._make_invitee()
        self.assertEqual(self._accept(invitation.token, invitee).status_code, status.HTTP_200_OK)

        again = self._accept(invitation.token, invitee)
        self.assertEqual(again.status_code, status.HTTP_409_CONFLICT)

    def test_a_revoked_invitation_is_refused(self):
        self._invite(requires_second=False)
        from apps.governance.models import StaffInvitation

        invitation = StaffInvitation.objects.get()
        self.client.delete(f'{self.PREFIX}/staff-invitations/{invitation.id}/')

        invitee = self._make_invitee()
        response = self._accept(invitation.token, invitee)
        self.assertEqual(response.status_code, status.HTTP_409_CONFLICT)

        invitee.refresh_from_db()
        self.assertFalse(invitee.is_staff)

    def test_an_expired_invitation_is_refused(self):
        from datetime import timedelta

        from django.utils import timezone

        from apps.governance.models import StaffInvitation

        self._invite(requires_second=False)
        invitation = StaffInvitation.objects.get()
        StaffInvitation.objects.filter(pk=invitation.pk).update(
            expires_at=timezone.now() - timedelta(days=1))

        invitee = self._make_invitee()
        response = self._accept(invitation.token, invitee)
        self.assertEqual(response.status_code, status.HTTP_410_GONE)
        invitee.refresh_from_db()
        self.assertFalse(invitee.is_staff)

    def test_the_public_read_says_why_without_granting_anything(self):
        self._invite(requires_second=False)
        from apps.governance.models import StaffInvitation

        invitation = StaffInvitation.objects.get()
        response = APIClient().get(
            f'{self.PREFIX}/staff-invitations/accept/{invitation.token}/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['data']['email'], 'newhire@example.com')
        self.assertTrue(response.data['data']['is_live'])
        # Critically: the read never hands back the role row or a usable token.
        self.assertNotIn('token', response.data['data'])

    def test_the_public_read_never_exposes_whether_an_account_exists(self):
        self._invite(requires_second=False)
        from apps.governance.models import StaffInvitation

        token = StaffInvitation.objects.get().token
        response = APIClient().get(f'{self.PREFIX}/staff-invitations/accept/{token}/')
        self.assertNotIn('has_account', response.data['data'])

    def test_an_unknown_token_is_a_404(self):
        response = APIClient().get(
            f'{self.PREFIX}/staff-invitations/accept/'
            '11111111-1111-1111-1111-111111111111/')
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    # --- staff-side management ---

    def test_staff_can_list_invitations_without_the_token(self):
        self._invite(requires_second=False)
        response = self.client.get(f'{self.PREFIX}/staff-invitations/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertNotIn('token', response.data['data'][0])

    def test_a_non_staff_user_cannot_list_or_invite(self):
        self.client.force_authenticate(_make_user('nobody@example.com', 'nobody'))
        self.assertEqual(
            self.client.get(f'{self.PREFIX}/staff-invitations/').status_code,
            status.HTTP_403_FORBIDDEN)
        self.assertEqual(self._invite().status_code, status.HTTP_403_FORBIDDEN)

    def test_revoking_an_accepted_invitation_refuses_and_says_why(self):
        """Accepting granted access; pretending a revoke undoes it would be a lie."""
        self._invite(requires_second=False)
        from apps.governance.models import StaffInvitation

        invitation = StaffInvitation.objects.get()
        self._accept(invitation.token, self._make_invitee())

        response = self.client.delete(f'{self.PREFIX}/staff-invitations/{invitation.id}/')
        self.assertEqual(response.status_code, status.HTTP_409_CONFLICT)
        self.assertIn('staff role', str(response.data).lower())

    def test_regranting_a_staff_user_changes_the_role_not_a_second_link(self):
        """A re-promotion goes through the staff-role endpoint, not a new invite."""
        self._invite(requires_second=False)
        from apps.governance.models import StaffInvitation

        invitation = StaffInvitation.objects.get()
        invitee = self._make_invitee()
        self._accept(invitation.token, invitee)

        response = self._invite(email='newhire@example.com', requires_second=False)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('already has a staff account', str(response.data).lower())
