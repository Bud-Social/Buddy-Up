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
from datetime import date
from unittest import mock

from django.test import TestCase
from rest_framework import status
from rest_framework.test import APIClient

from apps.accounts.models import User
from apps.profiles.models import Profile
from common.utils import hash_dob

from .models import ALL_SCOPES, AccountActionRequest, StaffRole

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
        """
        import apps.admin_portal.views as portal_views

        declared = set()
        for name in dir(portal_views):
            view = getattr(portal_views, name)
            if not isinstance(view, type):
                continue
            for permission in getattr(view, 'permission_classes', ()):
                # permission_classes holds classes, so walk the class's own mro.
                for klass in getattr(permission, '__mro__', ()):
                    if klass.__name__.startswith('ScopedPlatformAdmin['):
                        declared.add(klass.required_scope)
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
