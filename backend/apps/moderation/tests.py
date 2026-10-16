from django.test import TestCase
from rest_framework.test import APIClient
from rest_framework import status
from datetime import date
from unittest.mock import patch, MagicMock
from common.utils import hash_dob
from apps.accounts.models import User
from apps.profiles.models import Profile
from apps.moderation.models import ContentFlag, ModerationAction, ModerationAppeal
from apps.notifications.models import Notification
from apps.verification.models import VerificationSubmission, VerificationDocument


class PolicyModerationTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(email='mod@example.com', password='TestPass123!')
        self.user.dob_hash = hash_dob(date(2000, 6, 15))
        self.user.save()
        self.profile = Profile.objects.create(user=self.user, username='moduser', display_name='Mod User')
        self.client.force_authenticate(self.user)

    def _make_flag(self, reason, content_type='feed.post', severity='medium'):
        return ContentFlag.objects.create(
            content_type=content_type,
            content_id='11111111-1111-1111-1111-111111111111',
            content_preview='test content',
            flag_reason=reason,
            severity=severity,
            source='ai',
            confidence=0.9,
        )

    def test_medical_claim_flag_reason_created(self):
        flag = self._make_flag('medical_claim', severity='high')
        self.assertEqual(flag.flag_reason, 'medical_claim')
        self.assertEqual(flag.severity, 'high')

    def test_undisclosed_sponsor_flag_reason_created(self):
        flag = self._make_flag('undisclosed_sponsor', severity='medium')
        self.assertEqual(flag.flag_reason, 'undisclosed_sponsor')

    @patch('apps.moderation.tasks.requests.post')
    def test_policy_text_task_skips_practitioner_medical_flag(self, mock_post):
        """A verified practitioner's medical-claim wording must not be flagged."""
        from apps.moderation.tasks import moderate_policy_text
        practitioner = User.objects.create_user(email='doc@example.com', password='TestPass123!')
        Profile.objects.create(user=practitioner, username='docuser', display_name='Doc User', role='practitioner')
        practitioner.profile.verification_status = 'practitioner'
        practitioner.profile.save()

        mock_resp = MagicMock()
        mock_resp.status_code = 200
        mock_resp.json.return_value = {'has_medical_claim': True, 'risk_level': 'high', 'action': 'flag'}
        mock_post.return_value = mock_resp

        moderate_policy_text('feed.post', '22222222-2222-2222-2222-222222222222', 'This diet cures diabetes',
                             author_is_practitioner=True)
        self.assertEqual(ContentFlag.objects.filter(flag_reason='medical_claim').count(), 0)

    @patch('apps.moderation.tasks.requests.post')
    def test_policy_text_task_flags_undisclosed_sponsor_for_any_author(self, mock_post):
        from apps.moderation.tasks import moderate_policy_text

        def fake_post(url, data=None, **kwargs):
            resp = MagicMock()
            resp.status_code = 200
            if url.endswith('/api/v1/policy/health-claims'):
                resp.json.return_value = {'has_medical_claim': False, 'risk_level': 'low', 'action': 'allow'}
            elif url.endswith('/api/v1/policy/sponsorship'):
                resp.json.return_value = {
                    'is_promotional': True, 'has_disclosure': False,
                    'disclosure_compliant': False, 'action': 'flag',
                }
            else:
                resp.json.return_value = {}
            return resp

        mock_post.side_effect = fake_post
        moderate_policy_text('feed.post', '33333333-3333-3333-3333-333333333333',
                             'This brand sent me their new protein powder, use my code for 20% off',
                             author_is_practitioner=False)
        flag = ContentFlag.objects.filter(flag_reason='undisclosed_sponsor').first()
        self.assertIsNotNone(flag)
        self.assertEqual(flag.severity, 'medium')

    def test_moderation_stats_includes_new_reasons(self):
        self._make_flag('medical_claim')
        self._make_flag('undisclosed_sponsor')
        staff = User.objects.create_user(email='staffmod@example.com', password='TestPass123!', is_staff=True)
        self.client.force_authenticate(staff)
        resp = self.client.get('/api/v1/moderation/content-flags/stats/')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        by_reason = resp.data['data']['by_reason']
        self.assertEqual(by_reason['medical_claim'], 1)
        self.assertEqual(by_reason['undisclosed_sponsor'], 1)


class VerificationReviewTests(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(email='verify@example.com', password='TestPass123!')
        self.user.dob_hash = hash_dob(date(2000, 6, 15))
        self.user.save()
        self.profile = Profile.objects.create(user=self.user, username='verifyuser', display_name='Verify User')
        self.admin = User.objects.create_superuser(email='vadmin@example.com', password='TestPass123!')

    def _second_staff(self, email):
        """A distinct staff account. Two-person rule needs two real people."""
        other = User.objects.create_superuser(email=email, password='TestPass123!')
        client = APIClient()
        client.force_authenticate(other)
        return client

    def _settle(self, sub, client, action='approve', **extra):
        return client.post(
            f'/api/v1/verification/submissions/{sub.id}/decide/',
            {'action': action, **extra}, format='json',
        )

    def test_trainer_review_sets_profile_status(self):
        """review/ only raises the request; decide/ is what lands the effect."""
        doc = VerificationDocument.objects.create(
            profile=self.profile, document_type='certification', file_url='https://example.com/cert.pdf')
        sub = VerificationSubmission.objects.create(
            profile=self.profile, verification_type='trainer', status='submitted',
            credential_title='Certified Personal Trainer', credential_issuer='REPs Kenya',
            credential_id='REP-12345', scope_of_practice='general_fitness')
        sub.documents.add(doc)

        admin_client = APIClient()
        admin_client.force_authenticate(self.admin)
        resp = admin_client.post(f'/api/v1/verification/submissions/{sub.id}/review/',
            {'action': 'approve'}, format='json')
        self.assertEqual(resp.status_code, status.HTTP_202_ACCEPTED)

        # review() moves it to under_review and writes nothing else -- that is
        # the whole point of splitting the two calls.
        sub.refresh_from_db()
        self.profile.refresh_from_db()
        doc.refresh_from_db()
        self.assertEqual(sub.status, 'under_review')
        self.assertEqual(self.profile.verification_status, 'none')
        self.assertNotEqual(doc.status, 'approved')

        second = self._second_staff('vadmin2@example.com')
        decided = self._settle(sub, second)
        self.assertEqual(decided.status_code, status.HTTP_200_OK)

        sub.refresh_from_db()
        self.profile.refresh_from_db()
        doc.refresh_from_db()
        self.assertEqual(sub.status, 'approved')
        self.assertEqual(self.profile.verification_status, 'trainer')
        self.assertEqual(doc.status, 'approved')

    def test_one_staff_cannot_approve_their_own_review(self):
        """The requester settling their own request must be refused."""
        doc = VerificationDocument.objects.create(
            profile=self.profile, document_type='certification', file_url='https://example.com/cert.pdf')
        sub = VerificationSubmission.objects.create(
            profile=self.profile, verification_type='trainer', status='submitted',
            credential_title='Certified Personal Trainer', credential_issuer='REPs Kenya',
            credential_id='REP-12345', scope_of_practice='general_fitness')
        sub.documents.add(doc)

        admin_client = APIClient()
        admin_client.force_authenticate(self.admin)
        admin_client.post(f'/api/v1/verification/submissions/{sub.id}/review/',
                          {'action': 'approve'}, format='json')

        resp = self._settle(sub, admin_client)
        self.assertNotEqual(resp.status_code, status.HTTP_200_OK)

        sub.refresh_from_db()
        self.profile.refresh_from_db()
        self.assertNotEqual(sub.status, 'approved')
        self.assertEqual(self.profile.verification_status, 'none')

        # ...and a genuinely independent approver can still settle it.
        second = self._second_staff('vadmin3@example.com')
        self.assertEqual(self._settle(sub, second).status_code, status.HTTP_200_OK)
        sub.refresh_from_db()
        self.profile.refresh_from_db()
        self.assertEqual(sub.status, 'approved')
        self.assertEqual(self.profile.verification_status, 'trainer')

    def test_shop_review_sets_shop_status(self):
        doc = VerificationDocument.objects.create(
            profile=self.profile, document_type='certification', file_url='https://example.com/biz.pdf')
        sub = VerificationSubmission.objects.create(
            profile=self.profile, verification_type='shop', status='submitted',
            credential_title='Fit Supplies Ltd', credential_issuer='Registrar of Companies',
            credential_id='REG-98765')
        sub.documents.add(doc)

        admin_client = APIClient()
        admin_client.force_authenticate(self.admin)
        resp = admin_client.post(f'/api/v1/verification/submissions/{sub.id}/review/',
            {'action': 'approve'}, format='json')
        self.assertEqual(resp.status_code, status.HTTP_202_ACCEPTED)

        sub.refresh_from_db()
        self.profile.refresh_from_db()
        self.assertEqual(sub.status, 'under_review')
        self.assertEqual(self.profile.verification_status, 'none')

        second = self._second_staff('shopadmin2@example.com')
        decided = self._settle(sub, second)
        self.assertEqual(decided.status_code, status.HTTP_200_OK)

        sub.refresh_from_db()
        self.profile.refresh_from_db()
        self.assertEqual(sub.status, 'approved')
        self.assertEqual(self.profile.verification_status, 'shop')

    def test_non_admin_cannot_review(self):
        doc = VerificationDocument.objects.create(
            profile=self.profile, document_type='id_card', file_url='https://example.com/id.jpg')
        sub = VerificationSubmission.objects.create(
            profile=self.profile, verification_type='id', status='submitted')
        sub.documents.add(doc)

        user_client = APIClient()
        user_client.force_authenticate(self.user)
        resp = user_client.post(f'/api/v1/verification/submissions/{sub.id}/review/',
            {'action': 'approve'}, format='json')
        self.assertEqual(resp.status_code, status.HTTP_403_FORBIDDEN)
        sub.refresh_from_db()
        self.assertEqual(sub.status, 'submitted')


class ModerationAppealTests(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(email='appeal@example.com', password='TestPass123!')
        Profile.objects.create(user=self.user, username='appealuser', display_name='Appeal User')
        self.admin = User.objects.create_superuser(email='appealadmin@example.com', password='TestPass123!')
        self.action = ModerationAction.objects.create(
            action='user_suspended',
            moderator=self.admin,
            target_user=self.user,
            reason='Automated abuse threshold',
        )

    def test_user_can_appeal_own_action_and_admin_can_reverse(self):
        client = APIClient()
        client.force_authenticate(self.user)
        response = client.post('/api/v1/moderation/appeals/', {
            'action': str(self.action.id),
            'reason': 'This was a false positive; please review the conversation context.',
        }, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        appeal = ModerationAppeal.objects.get(id=response.data['id'])

        self.user.is_active = False
        self.user.save(update_fields=['is_active'])
        admin_client = APIClient()
        admin_client.force_authenticate(self.admin)
        response = admin_client.post(
            f'/api/v1/moderation/appeals/{appeal.id}/review/',
            {'decision': 'approve', 'resolution_note': 'Account activity was legitimate.'},
            format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        appeal.refresh_from_db()
        self.user.refresh_from_db()
        self.assertEqual(appeal.status, 'approved')
        self.assertTrue(self.user.is_active)
        self.assertTrue(ModerationAction.objects.filter(
            action='action_reversed', target_user=self.user,
        ).exists())


class ModerationReportVisibilityTests(TestCase):
    """A report is private to its reporter; only staff see the full queue."""

    def setUp(self):
        from apps.moderation.models import ModerationReport

        self.client = APIClient()
        self.reporter = User.objects.create_user(email='reporter@example.com', password='TestPass123!')
        Profile.objects.create(user=self.reporter, username='reporter', display_name='Reporter')
        self.other = User.objects.create_user(email='other@example.com', password='TestPass123!')
        Profile.objects.create(user=self.other, username='other', display_name='Other')
        self.target = User.objects.create_user(email='target@example.com', password='TestPass123!')
        Profile.objects.create(user=self.target, username='target', display_name='Target')
        self.staff = User.objects.create_user(
            email='modstaff@example.com', password='TestPass123!', is_staff=True,
        )

        self.report = ModerationReport.objects.create(
            reporter=self.reporter,
            target_user=self.target,
            reason='harassment',
            description='Private detail that must not leak.',
            resolution_note='Internal moderator note.',
        )

    def _list(self, user):
        client = APIClient()
        client.force_authenticate(user)
        response = client.get('/api/v1/moderation/reports/')
        self.assertEqual(response.status_code, status.HTTP_200_OK, response.data)
        return response.data

    def test_non_staff_cannot_see_another_users_report(self):
        data = self._list(self.other)
        self.assertEqual(data.get('count', len(data.get('results', []))), 0)

    def test_reporter_sees_only_their_own_reports(self):
        data = self._list(self.reporter)
        results = data.get('results', data)
        self.assertEqual(len(results), 1)
        self.assertEqual(str(results[0]['id']), str(self.report.id))

    def test_non_staff_cannot_retrieve_another_users_report(self):
        client = APIClient()
        client.force_authenticate(self.other)
        response = client.get(f'/api/v1/moderation/reports/{self.report.id}/')
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_staff_sees_every_report(self):
        data = self._list(self.staff)
        results = data.get('results', data)
        self.assertEqual(len(results), 1)
        self.assertEqual(str(results[0]['id']), str(self.report.id))


# ---------------------------------------------------------------------------
# Enforcement, two-person approval, takedown, reversal, assignment, commendations
# ---------------------------------------------------------------------------

def _user(email, username, *, staff=False, superuser=False):
    user = User.objects.create_user(email=email, password='TestPass123!')
    if staff:
        user.is_staff = True
    if superuser:
        user.is_superuser = True
    user.save()
    profile = Profile.objects.create(
        user=user, username=username, display_name=username.title(),
    )
    return user, profile


class ModerationActionEnforcementBase(TestCase):

    def setUp(self):
        self.moderator, self.moderator_profile = _user(
            'enf.mod@example.com', 'enfmod', staff=True,
        )
        self.second_approver, self.second_profile = _user(
            'enf.approver@example.com', 'enfapprover', staff=True,
        )
        self.target, self.target_profile = _user('enf.target@example.com', 'enftarget')

        self.mod_client = APIClient()
        self.mod_client.force_authenticate(self.moderator)
        self.approver_client = APIClient()
        self.approver_client.force_authenticate(self.second_approver)

    def _act(self, client, **payload):
        payload.setdefault('target_user', str(self.target.pk))
        return client.post('/api/v1/moderation/actions/', payload, format='json')

    def _notifications_for(self, user):
        from apps.notifications.models import Notification
        return list(Notification.objects.filter(recipient__user_id=user.pk))


class WarningNotificationTests(ModerationActionEnforcementBase):
    """A warning must be visible to the person who received it."""

    def test_warning_creates_the_action(self):
        response = self._act(self.mod_client, action='warning', reason='Third harassment report.')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED, response.data)
        row = ModerationAction.objects.get(id=response.data['data']['id'])
        self.assertEqual(row.action, 'warning')
        self.assertEqual(row.moderator_id, self.moderator.pk)
        self.assertEqual(row.target_user_id, self.target.pk)
        self.assertEqual(row.reason, 'Third harassment report.')

    def test_warning_notifies_the_user_with_the_reason(self):
        self._act(self.mod_client, action='warning', reason='Third harassment report.')
        notes = self._notifications_for(self.target)
        self.assertEqual(len(notes), 1, [n.notification_type for n in notes])
        note = notes[0]
        self.assertEqual(note.notification_type, 'moderation_warning')
        self.assertEqual(note.body, 'Third harassment report.')
        self.assertEqual(note.metadata['action'], 'warning')
        self.assertTrue(note.metadata['can_appeal'])

    def test_warning_pushes_to_devices_as_well_as_the_in_app_row(self):
        """create_notification alone does not reach a device token."""
        from unittest import mock

        from apps.marketplace.models import PushDevice
        PushDevice.objects.create(
            profile=self.target_profile, platform='web', token='{}', is_active=True,
        )
        with mock.patch('apps.marketplace.tasks._send_push_to_device') as send:
            self._act(self.mod_client, action='warning', reason='Push me.')

        # Both transports fire: the in-app row exists...
        self.assertEqual(len(self._notifications_for(self.target)), 1)
        # ...and the device push was actually dispatched, which is what
        # create_notification alone does not do.
        self.assertTrue(send.called, 'the device push was never dispatched')
        self.assertEqual(send.call_args[0][0], 'web')

    def test_non_staff_cannot_issue_actions(self):
        client = APIClient()
        client.force_authenticate(self.target)
        response = self._act(client, action='warning', reason='I warned myself.')
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
        self.assertFalse(ModerationAction.objects.filter(action='warning').exists())


class TwoPersonApprovalTests(ModerationActionEnforcementBase):
    """A ban is requested by one person and granted by another."""

    def _ban_payload(self, **overrides):
        payload = {
            'action': 'user_banned',
            'target_user': str(self.target.pk),
            'reason': 'Repeated sale of banned supplements.',
        }
        payload.update(overrides)
        return payload

    def test_ban_is_not_applied_by_one_person(self):
        from apps.accounts.models import AccountStanding

        response = self._act(self.mod_client, **self._ban_payload())
        self.assertEqual(response.status_code, status.HTTP_202_ACCEPTED, response.data)
        self.assertFalse(response.data['data']['applied'])

        # The audit row exists...
        row = ModerationAction.objects.get(action='user_banned')
        self.assertEqual(row.target_user_id, self.target.pk)
        # ...and a pending governance request exists...
        self.assertTrue(response.data['data']['approval']['id'])
        # ...but nothing about the account changed.
        self.assertFalse(AccountStanding.objects.filter(user=self.target).exists())
        self.target.refresh_from_db()
        self.assertTrue(self.target.is_active)
        self.assertEqual(self._notifications_for(self.target), [])

    def test_ban_applies_after_a_second_distinct_approver(self):
        from apps.accounts.models import AccountStanding

        response = self._act(self.mod_client, **self._ban_payload())
        approval_id = response.data['data']['approval']['id']

        approve = self.approver_client.post(
            f'/api/v1/governance/approvals/{approval_id}/approve/',
            {'note': 'Confirmed with the compliance team.'}, format='json',
        )
        self.assertEqual(approve.status_code, status.HTTP_200_OK, approve.data)

        standing = AccountStanding.objects.get(user=self.target)
        self.assertEqual(standing.state, AccountStanding.STATE_BANNED)
        self.assertTrue(standing.permanent)
        self.assertIsNotNone(standing.action_id)
        self.assertTrue(standing.action_id.startswith(('governance:', 'moderation:')))
        self.target.refresh_from_db()
        self.assertFalse(self.target.is_active)

        # And the user is told, with an appeal pointer.
        notes = self._notifications_for(self.target)
        self.assertEqual([n.notification_type for n in notes], ['moderation_ban'])
        self.assertEqual(notes[0].metadata['permanent'], True)
        self.assertIsNone(notes[0].metadata['suspended_until'])
        self.assertTrue(notes[0].metadata['can_appeal'])
        self.assertIn('appeal_path', notes[0].metadata)

    def test_the_requester_cannot_approve_their_own_ban(self):
        response = self._act(self.mod_client, **self._ban_payload())
        approval_id = response.data['data']['approval']['id']

        self_approve = self.mod_client.post(
            f'/api/v1/governance/approvals/{approval_id}/approve/',
            {'note': 'Approving my own ban.'}, format='json',
        )
        self.assertEqual(self_approve.status_code, status.HTTP_403_FORBIDDEN)
        from apps.accounts.models import AccountStanding
        self.assertFalse(AccountStanding.objects.filter(user=self.target).exists())

    def test_suspension_carries_the_duration_through_to_the_standing(self):
        from apps.accounts.models import AccountStanding

        response = self._act(
            self.mod_client, action='user_suspended', duration_days=7,
            reason='Payment fraud under investigation.',
        )
        self.assertEqual(response.status_code, status.HTTP_202_ACCEPTED, response.data)
        row = ModerationAction.objects.get(action='user_suspended')
        self.assertEqual(row.duration_days, 7)

        approve = self.approver_client.post(
            f"/api/v1/governance/approvals/{response.data['data']['approval']['id']}/approve/",
            {'note': 'Approved.'}, format='json',
        )
        self.assertEqual(approve.status_code, status.HTTP_200_OK, approve.data)
        standing = AccountStanding.objects.get(user=self.target)
        self.assertEqual(standing.state, AccountStanding.STATE_SUSPENDED)
        self.assertIsNotNone(standing.suspended_until)
        self.assertFalse(standing.permanent)

        notes = self._notifications_for(self.target)
        self.assertEqual(notes[0].notification_type, 'moderation_suspension')
        self.assertEqual(notes[0].metadata['duration_days'], 7)
        self.assertIsNotNone(notes[0].metadata['suspended_until'])

    def test_suspension_without_a_duration_is_refused(self):
        response = self._act(
            self.mod_client, action='user_suspended', reason='No end date given.',
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('duration_days', response.data['errors'])

    def test_a_ban_cannot_carry_a_duration(self):
        response = self._act(
            self.mod_client, action='user_banned', duration_days=30,
            reason='Ban with a pretend expiry.',
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('duration_days', response.data['errors'])

    def test_pending_approvals_are_surfaced_on_the_queue(self):
        response = self._act(self.mod_client, **self._ban_payload())
        approval_id = response.data['data']['approval']['id']

        queue = self.mod_client.get('/api/v1/moderation/content-flags/pending-approvals/')
        self.assertEqual(queue.status_code, status.HTTP_200_OK)
        self.assertEqual(queue.data['count'], 1)
        entry = queue.data['data'][0]
        self.assertEqual(entry['id'], approval_id)
        self.assertEqual(entry['governance_action'], 'ban')
        self.assertEqual(entry['target_user'], str(self.target.pk))
        self.assertTrue(entry['requires_second'])
        self.assertEqual(
            entry['moderation_action_id'],
            response.data['data']['moderation_action']['id'],
        )


class StandingActionDelegationTests(ModerationActionEnforcementBase):
    """Moderation delegates the effect; it never writes is_active itself."""

    def test_apply_uses_the_moderation_action_id_as_the_source(self):
        from apps.accounts.models import AccountStanding
        from apps.moderation.services import apply_standing_action_for_row

        row = ModerationAction.objects.create(
            action='user_suspended', moderator=self.moderator,
            target_user=self.target, reason='Chargeback fraud.', duration_days=14,
        )
        apply_standing_action_for_row(row, actor=self.moderator)

        standing = AccountStanding.objects.get(user=self.target)
        self.assertEqual(standing.action_id, f'moderation:{row.id}')
        self.assertEqual(standing.state, AccountStanding.STATE_SUSPENDED)
        self.assertFalse(standing.permanent)
        self.assertIsNotNone(standing.suspended_until)
        self.assertEqual(standing.issued_by_id, self.moderator.pk)
        self.target.refresh_from_db()
        self.assertFalse(self.target.is_active)

    def test_apply_does_not_double_apply_when_governance_already_did(self):
        """Governance owns the effect. Moderation must not write it twice."""
        from apps.accounts.models import AccountEvent, AccountStanding
        from apps.accounts.services import apply_standing_action as accounts_apply
        from apps.moderation.services import apply_standing_action_for_row
        from apps.governance.models import AccountActionRequest

        row = ModerationAction.objects.create(
            action='user_banned', moderator=self.moderator,
            target_user=self.target, reason='Confirmed fraud.',
        )
        approval = AccountActionRequest.objects.create(
            action='ban', target_user=self.target, payload={'reason': 'Confirmed fraud.'},
            requested_by=self.moderator, requires_second=True,
        )
        # Exactly what governance's ApprovalApproveView._apply does.
        accounts_apply(
            target_user_id=self.target.pk, action='user_banned',
            reason='Confirmed fraud.', duration_days=None, actor=self.second_approver,
            source=f'governance:{approval.id}',
        )
        events_before = AccountEvent.objects.filter(
            user=self.target, event_type='account_banned',
        ).count()

        apply_standing_action_for_row(row, actor=self.moderator, approval=approval)

        standing = AccountStanding.objects.get(user=self.target)
        self.assertEqual(standing.action_id, f'governance:{approval.id}')
        self.assertEqual(
            AccountEvent.objects.filter(user=self.target, event_type='account_banned').count(),
            events_before,
            'moderation re-applied a standing governance had already applied',
        )

    def test_an_unknown_action_is_refused(self):
        from apps.moderation.services import request_standing_action
        with self.assertRaises(ValueError):
            request_standing_action(
                action='warning', target_user=self.target,
                reason='not a standing action', moderator=self.moderator,
            )


class ContentTakedownTests(ModerationActionEnforcementBase):
    """One test per supported content type, plus the failure contract."""

    def _flag(self, content_type, content_id):
        return ContentFlag.objects.create(
            content_type=content_type, content_id=str(content_id),
            flag_reason='toxic', severity='high', source='test', confidence=0.9,
            content_preview='test content',
        )

    def _remove(self, flag):
        return self.mod_client.post(
            f'/api/v1/moderation/content-flags/{flag.id}/act/',
            {'action': 'remove', 'note': 'Policy violation.'}, format='json',
        )

    def _make_post(self):
        from apps.feed.models import Post
        return Post.objects.create(
            author=self.target_profile, post_type='text', body='buy my thing',
        )

    def test_feed_post_takedown(self):
        post = self._make_post()
        response = self._remove(self._flag('feed.post', post.id))
        self.assertEqual(response.status_code, status.HTTP_200_OK, response.data)
        post.refresh_from_db()
        self.assertEqual(post.moderation_status, 'removed')
        self.assertIn('moderation_status=removed', response.data['data']['effect'])

        row = ModerationAction.objects.get(action='content_removed')
        self.assertEqual(row.content_type, 'feed.post')
        self.assertEqual(row.content_id, str(post.id))
        self.assertEqual(row.target_user_id, self.target.pk)

        notes = self._notifications_for(self.target)
        self.assertEqual(notes[0].notification_type, 'moderation_content_removed')

    def test_feed_comment_takedown(self):
        from apps.feed.models import Comment
        post = self._make_post()
        comment = Comment.objects.create(post=post, author=self.target_profile, body='spam')
        response = self._remove(self._flag('feed.comment', comment.id))
        self.assertEqual(response.status_code, status.HTTP_200_OK, response.data)
        self.assertFalse(Comment.objects.filter(id=comment.id).exists())
        self.assertIn('cannot be restored', response.data['data']['effect'])

    def test_marketplace_product_takedown(self):
        from apps.marketplace.models import Product
        product = Product.objects.create(
            name='Pre-workout', brand='Acme', category='supplement',
            affiliate_url='https://example.com/p', recommended_by=self.target_profile,
        )
        response = self._remove(self._flag('marketplace.product', product.id))
        self.assertEqual(response.status_code, status.HTTP_200_OK, response.data)
        product.refresh_from_db()
        self.assertFalse(product.is_active)
        self.assertIn('is_active=False', response.data['data']['effect'])

    def test_gym_takedown_marks_it_inactive(self):
        from apps.gyms.models import Gym
        gym = Gym.objects.create(name='Takedown Gym', handle='takedowngym', category='fitness')
        response = self._remove(self._flag('gym', gym.id))
        self.assertEqual(response.status_code, status.HTTP_200_OK, response.data)
        gym.refresh_from_db()
        self.assertTrue(gym.is_deleted)
        self.assertIsNotNone(gym.deleted_at)

    def test_gym_schedule_post_takedown(self):
        from apps.gyms.models import Gym, GymSchedulePost
        gym = Gym.objects.create(name='Schedule Gym', handle='schedgym', category='fitness')
        slot = GymSchedulePost.objects.create(
            gym=gym, author=self.target_profile, title='HIIT', activity_type='hiit',
        )
        response = self._remove(self._flag('gyms.schedule_post', slot.id))
        self.assertEqual(response.status_code, status.HTTP_200_OK, response.data)
        self.assertFalse(GymSchedulePost.objects.filter(id=slot.id).exists())

    def test_community_post_takedown(self):
        from apps.messaging.models import CommunityPost, Conversation
        conversation = Conversation.objects.create(is_group=True, group_name='Run Club', is_community=True)
        cpost = CommunityPost.objects.create(
            conversation=conversation, author=self.target_profile, body='scam',
        )
        response = self._remove(self._flag('messaging.community_post', cpost.id))
        self.assertEqual(response.status_code, status.HTTP_200_OK, response.data)
        self.assertFalse(CommunityPost.objects.filter(id=cpost.id).exists())

    def test_marketplace_event_unpublishes(self):
        from datetime import timedelta

        from django.utils import timezone as djtz

        from apps.marketplace.models import MarketplaceEvent
        start = djtz.now() + timedelta(days=1)
        event = MarketplaceEvent.objects.create(
            creator=self.target_profile, title='Sprint Club', category='fitness',
            start_datetime=start, end_datetime=start + timedelta(hours=2),
        )
        response = self._remove(self._flag('marketplace.event', event.id))
        self.assertEqual(response.status_code, status.HTTP_200_OK, response.data)
        event.refresh_from_db()
        self.assertFalse(event.is_published)
        self.assertIn('is_published=False', response.data['data']['effect'])

    def test_a_failed_takedown_does_not_mark_the_flag_actioned(self):
        """The whole point: a takedown that failed must not record as done."""
        from apps.feed.models import Post

        flag = self._flag('feed.post', '00000000-0000-0000-0000-000000000000')
        response = self._remove(flag)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertFalse(response.data['success'])
        self.assertFalse(response.data['data']['takedown_performed'])

        flag.refresh_from_db()
        self.assertFalse(flag.is_actioned, 'the flag was recorded as handled despite failing')
        self.assertFalse(ModerationAction.objects.filter(action='content_removed').exists())
        self.assertFalse(Post.objects.filter(
            id='00000000-0000-0000-0000-000000000000').exists())

    def test_an_unexpected_error_also_leaves_the_flag_open(self):
        from unittest import mock

        post = self._make_post()
        flag = self._flag('feed.post', post.id)
        with mock.patch(
            'apps.moderation.takedown.FeedPostHandler.remove',
            side_effect=RuntimeError('database on fire'),
        ):
            response = self._remove(flag)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('database on fire', response.data['message'])
        flag.refresh_from_db()
        self.assertFalse(flag.is_actioned)
        post.refresh_from_db()
        self.assertEqual(post.moderation_status, 'clean')

    def test_an_unsupported_content_type_is_reported_not_swallowed(self):
        flag = self._flag('lives.stream', '1234')
        response = self._remove(flag)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('lives.stream', response.data['message'])
        flag.refresh_from_db()
        self.assertFalse(flag.is_actioned)

    def test_escalate_is_not_a_warning(self):
        flag = self._flag('feed.post', self._make_post().id)
        response = self.mod_client.post(
            f'/api/v1/moderation/content-flags/{flag.id}/act/',
            {'action': 'escalate', 'note': 'Senior review please.'}, format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK, response.data)
        self.assertFalse(ModerationAction.objects.filter(action='warning').exists())
        row = ModerationAction.objects.get(action='escalated')
        self.assertIn('second review', row.reason)
        # Escalation is internal: the flagged user hears nothing.
        self.assertEqual(self._notifications_for(self.target), [])
        flag.refresh_from_db()
        self.assertFalse(flag.is_actioned)

    def test_approve_clears_the_flag_marker(self):
        from apps.feed.models import Post
        post = self._make_post()
        Post.objects.filter(id=post.id).update(moderation_status='flagged')
        flag = self._flag('feed.post', post.id)
        response = self.mod_client.post(
            f'/api/v1/moderation/content-flags/{flag.id}/act/',
            {'action': 'approve', 'note': 'Looks fine.'}, format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK, response.data)
        post.refresh_from_db()
        self.assertEqual(post.moderation_status, 'clean')


class ModerationReversalTests(ModerationActionEnforcementBase):
    def _removed_post(self):
        from apps.feed.models import Post
        post = Post.objects.create(author=self.target_profile, post_type='text', body='bad')
        flag = ContentFlag.objects.create(
            content_type='feed.post', content_id=str(post.id), flag_reason='toxic',
            severity='high', source='test', confidence=0.9,
        )
        self.mod_client.post(
            f'/api/v1/moderation/content-flags/{flag.id}/act/',
            {'action': 'remove', 'note': 'Spam.'}, format='json',
        )
        return post

    def test_reversal_restores_content_and_stamps_the_reversal_fields(self):

        post = self._removed_post()
        post.refresh_from_db()
        self.assertEqual(post.moderation_status, 'removed')

        row = ModerationAction.objects.get(action='content_removed')
        response = self.mod_client.post(
            f'/api/v1/moderation/actions/{row.id}/reverse/',
            {'reason': 'Flagged by mistake.'}, format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK, response.data)

        post.refresh_from_db()
        self.assertEqual(post.moderation_status, 'clean')

        row.refresh_from_db()
        self.assertIsNotNone(row.reversed_by_id)
        self.assertEqual(row.reversed_by.moderator_id, self.moderator.pk)
        self.assertEqual(row.reversed_by.action, 'action_reversed')
        self.assertIsNotNone(row.reversed_at)
        self.assertEqual(row.reversal_reason, 'Flagged by mistake.')
        self.assertTrue(row.is_reversed)

        self.assertTrue(ModerationAction.objects.filter(action='action_reversed').exists())
        notes = list(
            Notification.objects.filter(
                recipient__user_id=self.target.pk,
                notification_type='moderation_action_reversed',
            )
        )
        self.assertEqual(len(notes), 1, [n.notification_type for n in
                                         self._notifications_for(self.target)])
        self.assertEqual(notes[0].metadata['original_action'], 'content_removed')
        self.assertEqual(notes[0].metadata['reason'], 'Flagged by mistake.')

    def test_reversing_twice_is_a_conflict(self):
        self._removed_post()
        row = ModerationAction.objects.get(action='content_removed')
        first = self.mod_client.post(
            f'/api/v1/moderation/actions/{row.id}/reverse/',
            {'reason': 'First.'}, format='json',
        )
        self.assertEqual(first.status_code, status.HTTP_200_OK)
        second = self.mod_client.post(
            f'/api/v1/moderation/actions/{row.id}/reverse/',
            {'reason': 'Second.'}, format='json',
        )
        self.assertEqual(second.status_code, status.HTTP_409_CONFLICT)

    def test_reversal_of_a_hard_deleted_type_says_it_cannot(self):
        from apps.gyms.models import Gym, GymSchedulePost
        gym = Gym.objects.create(name='Gone Gym', handle='gonegym', category='fitness')
        slot = GymSchedulePost.objects.create(
            gym=gym, author=self.target_profile, title='Class', activity_type='hiit',
        )
        flag = ContentFlag.objects.create(
            content_type='gyms.schedule_post', content_id=str(slot.id),
            flag_reason='toxic', severity='high', source='test',
        )
        self.mod_client.post(
            f'/api/v1/moderation/content-flags/{flag.id}/act/',
            {'action': 'remove'}, format='json',
        )
        row = ModerationAction.objects.get(action='content_removed')
        response = self.mod_client.post(
            f'/api/v1/moderation/actions/{row.id}/reverse/',
            {'reason': 'Undo please.'}, format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_409_CONFLICT)
        self.assertIn('cannot be undone', response.data['message'])
        row.refresh_from_db()
        self.assertFalse(row.is_reversed)

    def test_reversing_a_suspension_lifts_the_standing_properly(self):
        from apps.accounts.models import AccountStanding
        from apps.accounts.services import apply_standing_action

        row = ModerationAction.objects.create(
            action='user_suspended', moderator=self.moderator,
            target_user=self.target, reason='Fraud review.', duration_days=3,
        )
        apply_standing_action(
            target_user_id=self.target.pk, action='user_suspended',
            reason='Fraud review.', duration_days=3, actor=self.moderator,
        )
        self.target.refresh_from_db()
        self.assertFalse(self.target.is_active)

        response = self.mod_client.post(
            f'/api/v1/moderation/actions/{row.id}/reverse/',
            {'reason': 'Appeal upheld.'}, format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK, response.data)
        standing = AccountStanding.objects.get(user=self.target)
        self.assertEqual(standing.state, AccountStanding.STATE_CLEAR)
        self.assertFalse(standing.permanent)
        self.assertFalse(standing.is_moderation_action)
        self.target.refresh_from_db()
        self.assertTrue(self.target.is_active)
        row.refresh_from_db()
        self.assertTrue(row.is_reversed)

    def test_approved_appeal_reverses_through_the_standing_service(self):
        """Regression: the appeal path used to set is_active directly, which the
        next standing read undid."""
        from apps.accounts.models import AccountStanding
        from apps.accounts.services import apply_standing_action, get_standing_object

        row = ModerationAction.objects.create(
            action='user_banned', moderator=self.moderator,
            target_user=self.target, reason='Confirmed fraud.',
        )
        apply_standing_action(
            target_user_id=self.target.pk, action='user_banned',
            reason='Confirmed fraud.', actor=self.moderator,
        )
        appeal = ModerationAppeal.objects.create(
            action=row, appellant=self.target, reason='That was my business partner.',
        )
        response = self.mod_client.post(
            f'/api/v1/moderation/appeals/{appeal.id}/review/',
            {'decision': 'approve', 'resolution_note': 'Legitimate trade.'}, format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK, response.data)
        standing = get_standing_object(self.target)
        self.assertEqual(standing.state, AccountStanding.STATE_CLEAR)
        self.target.refresh_from_db()
        self.assertTrue(self.target.is_active)


class ModerationAssignmentTests(TestCase):
    def setUp(self):
        from apps.moderation.models import ModerationReport

        self.staff, _ = _user('assign.mod@example.com', 'assignmod', staff=True)
        self.other_staff, _ = _user('assign.other@example.com', 'assignother', staff=True)
        self.reporter, _ = _user('assign.rep@example.com', 'assignrep')
        self.target, _ = _user('assign.target@example.com', 'assigntarget')

        self.mine = ModerationReport.objects.create(
            reporter=self.reporter, target_user=self.target, reason='spam',
        )
        self.theirs = ModerationReport.objects.create(
            reporter=self.reporter, target_user=self.target, reason='harassment',
        )
        self.unassigned = ModerationReport.objects.create(
            reporter=self.reporter, target_user=self.target, reason='other',
        )
        self.mine.assigned_to = self.staff
        self.mine.save(update_fields=['assigned_to'])
        self.theirs.assigned_to = self.other_staff
        self.theirs.save(update_fields=['assigned_to'])

        self.client = APIClient()
        self.client.force_authenticate(self.staff)

    def _ids(self, params):
        response = self.client.get('/api/v1/moderation/reports/', params)
        self.assertEqual(response.status_code, status.HTTP_200_OK, response.data)
        results = response.data.get('results', response.data)
        return {str(row['id']) for row in results}

    def test_assigned_to_me(self):
        self.assertEqual(self._ids({'assigned_to': 'me'}), {str(self.mine.id)})

    def test_assigned_to_a_specific_user(self):
        self.assertEqual(
            self._ids({'assigned_to': str(self.other_staff.pk)}), {str(self.theirs.id)},
        )

    def test_unassigned(self):
        self.assertEqual(self._ids({'unassigned': 'true'}), {str(self.unassigned.id)})

    def test_unassigned_false_returns_only_assigned(self):
        self.assertEqual(
            self._ids({'unassigned': 'false'}), {str(self.mine.id), str(self.theirs.id)},
        )

    def test_no_filter_returns_everything(self):
        self.assertEqual(len(self._ids({})), 3)

    def test_bad_assigned_to_is_a_400(self):
        response = self.client.get('/api/v1/moderation/reports/', {'assigned_to': 'nonsense'})
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_assign_endpoint_assigns_and_unassigns(self):
        response = self.client.post(
            f'/api/v1/moderation/reports/{self.unassigned.id}/assign/',
            {'assigned_to': str(self.staff.pk)}, format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK, response.data)
        self.unassigned.refresh_from_db()
        self.assertEqual(self.unassigned.assigned_to_id, self.staff.pk)
        self.assertIn('sla_due_at', response.data['data'])
        self.assertIn('sla_breached', response.data['data'])

        response = self.client.post(
            f'/api/v1/moderation/reports/{self.unassigned.id}/assign/',
            {'assigned_to': None}, format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK, response.data)
        self.unassigned.refresh_from_db()
        self.assertIsNone(self.unassigned.assigned_to_id)

    def test_cannot_assign_to_a_non_staff_user(self):
        response = self.client.post(
            f'/api/v1/moderation/reports/{self.unassigned.id}/assign/',
            {'assigned_to': str(self.target.pk)}, format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_non_staff_cannot_assign(self):
        client = APIClient()
        client.force_authenticate(self.reporter)
        response = client.post(
            f'/api/v1/moderation/reports/{self.unassigned.id}/assign/',
            {'assigned_to': str(self.staff.pk)}, format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    def test_sla_fields_are_present_and_correct(self):
        from datetime import timedelta

        from apps.moderation.models import ModerationReport

        rows = self._ids({})
        urgent = ModerationReport.objects.create(
            reporter=self.reporter, target_user=self.target, reason='violence',
        )
        response = self.client.get('/api/v1/moderation/reports/', {'page_size': 100})
        data = {str(r['id']): r for r in response.data.get('results', response.data)}
        self.assertIn(str(urgent.id), rows | set(data))

        # Standard reason -> 24h, urgent reason -> 4h.
        self.assertEqual(
            data[str(self.unassigned.id)]['sla_due_at'],
            (self.unassigned.created_at + timedelta(hours=24)).isoformat(),
        )
        self.assertEqual(
            data[str(urgent.id)]['sla_due_at'],
            (urgent.created_at + timedelta(hours=4)).isoformat(),
        )
        self.assertFalse(data[str(urgent.id)]['sla_breached'])

    def test_sla_breaches_after_the_deadline(self):
        from datetime import timedelta

        from django.utils import timezone as djtz

        from apps.moderation.models import ModerationReport

        stale = ModerationReport.objects.create(
            reporter=self.reporter, target_user=self.target, reason='violence',
        )
        ModerationReport.objects.filter(id=stale.id).update(
            created_at=djtz.now() - timedelta(hours=6),
        )
        response = self.client.get('/api/v1/moderation/reports/', {'page_size': 100})
        data = {str(r['id']): r for r in response.data.get('results', response.data)}
        self.assertTrue(data[str(stale.id)]['sla_breached'])

    def test_a_resolved_report_is_never_breached(self):
        from datetime import timedelta

        from django.utils import timezone as djtz

        from apps.moderation.models import ModerationReport

        stale = ModerationReport.objects.create(
            reporter=self.reporter, target_user=self.target,
            reason='violence', status='resolved', resolved_at=djtz.now(),
        )
        ModerationReport.objects.filter(id=stale.id).update(
            created_at=djtz.now() - timedelta(days=3),
        )
        response = self.client.get('/api/v1/moderation/reports/', {'page_size': 100})
        data = {str(r['id']): r for r in response.data.get('results', response.data)}
        self.assertFalse(data[str(stale.id)]['sla_breached'])

    def test_the_list_is_not_an_n_plus_one(self):
        """SLA is computed per row, so pin the query count as flat in row count."""
        from apps.moderation.models import ModerationReport

        for i in range(10):
            ModerationReport.objects.create(
                reporter=self.reporter, target_user=self.target, reason='spam',
            )
        # One query for the page. The SLA fields are computed in Python from two
        # already-loaded columns, so growing the result set must not grow the
        # query count.
        with self.assertNumQueries(1):
            response = self.client.get('/api/v1/moderation/reports/', {'page_size': 100})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data.get('results', response.data)), 13)


class CommendationTests(TestCase):
    def setUp(self):
        self.staff, self.staff_profile = _user('comm.staff@example.com', 'commstaff', staff=True)
        self.recipient, self.recipient_profile = _user('comm.to@example.com', 'commto')
        self.bystander, self.bystander_profile = _user('comm.by@example.com', 'commby')

        self.staff_client = APIClient()
        self.staff_client.force_authenticate(self.staff)
        self.recipient_client = APIClient()
        self.recipient_client.force_authenticate(self.recipient)
        self.bystander_client = APIClient()
        self.bystander_client.force_authenticate(self.bystander)

    def _issue(self, **overrides):
        payload = {
            'recipient': str(self.recipient.pk),
            'category': 'helpful',
            'message': 'Answered my beginner question at 6am.',
        }
        payload.update(overrides)
        return self.staff_client.post(
            '/api/v1/moderation/commendations/', payload, format='json',
        )

    def test_staff_can_issue_and_the_recipient_is_notified(self):
        response = self._issue()
        self.assertEqual(response.status_code, status.HTTP_201_CREATED, response.data)
        notes = Notification.objects.filter(recipient=self.recipient_profile)
        self.assertEqual(notes.count(), 1)
        self.assertEqual(notes.first().notification_type, 'commendation_received')
        self.assertIn('Answered my beginner question', notes.first().body)

    def test_a_non_staff_user_cannot_issue(self):
        response = self.bystander_client.post(
            '/api/v1/moderation/commendations/',
            {'recipient': str(self.recipient.pk), 'category': 'helpful', 'message': 'me'},
            format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    def test_recipient_can_delete_their_own(self):
        commendation = self._issue().data['data']
        response = self.recipient_client.delete(
            f"/api/v1/moderation/commendations/{commendation['id']}/",
        )
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
        from apps.moderation.models import Commendation
        self.assertFalse(Commendation.objects.filter(id=commendation['id']).exists())

    def test_a_bystander_cannot_delete_someone_elses(self):
        commendation = self._issue().data['data']
        response = self.bystander_client.delete(
            f"/api/v1/moderation/commendations/{commendation['id']}/",
        )
        self.assertIn(response.status_code, (
            status.HTTP_403_FORBIDDEN, status.HTTP_404_NOT_FOUND,
        ))
        from apps.moderation.models import Commendation
        self.assertTrue(Commendation.objects.filter(id=commendation['id']).exists())

    def test_revoke_hides_it_without_deleting(self):
        commendation = self._issue().data['data']
        response = self.staff_client.post(
            f"/api/v1/moderation/commendations/{commendation['id']}/revoke/",
            {'reason': 'Issued against the wrong person.'}, format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK, response.data)
        from apps.moderation.models import Commendation
        row = Commendation.objects.get(id=commendation['id'])
        self.assertFalse(row.visible_to_recipient)

        listing = self.recipient_client.get('/api/v1/moderation/commendations/')
        results = listing.data.get('results', listing.data)
        self.assertEqual([r['id'] for r in results], [])

    def test_only_staff_may_revoke(self):
        commendation = self._issue().data['data']
        response = self.recipient_client.post(
            f"/api/v1/moderation/commendations/{commendation['id']}/revoke/",
            {}, format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    def test_message_length_is_capped(self):
        response = self._issue(message='x' * 501)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)


class NotificationPreferenceCoverageTests(TestCase):
    """Every moderation/commendation notification type has an opt-out column.

    ``create_notification`` reads ``getattr(prefs, f'{type}_push', None)`` and
    treats the ``None`` a missing column returns as "push". So a type with no
    column is pushed to every user on the platform with no way to stop it.
    """

    TYPES = [
        'moderation_warning', 'moderation_content_removed', 'moderation_suspension',
        'moderation_ban', 'moderation_action_reversed', 'commendation_received',
    ]

    def test_every_type_is_declared(self):
        from apps.notifications.models import Notification
        declared = {c[0] for c in Notification.TYPE_CHOICES}
        for notification_type in self.TYPES:
            self.assertIn(notification_type, declared)

    def test_every_type_fits_the_column(self):
        from apps.notifications.models import Notification
        field = Notification._meta.get_field('notification_type')
        for notification_type in self.TYPES:
            self.assertLessEqual(
                len(notification_type), field.max_length,
                f'{notification_type} does not fit in {field.max_length} characters',
            )

    def test_every_type_has_a_preference_column(self):
        from apps.notifications.models import NotificationPreference
        names = {f.name for f in NotificationPreference._meta.get_fields()}
        for notification_type in self.TYPES:
            self.assertIn(f'{notification_type}_push', names)


class CeleryScheduleRegistrationTests(TestCase):
    """`auto_flag_expired_reports` exists; nothing schedules it.

    Pinning the current state on purpose. Registering it means editing
    ``config/celery.py`` or ``config/settings/base.py``, which this app does not
    own — and ``config.test_celery_schedule.BeatScheduleMergeTests`` asserts the
    effective schedule equals settings-plus-config exactly, so adding a key from
    an AppConfig would break that test rather than satisfy it.
    """

    def test_the_task_exists(self):
        from apps.moderation.tasks import auto_flag_expired_reports
        self.assertTrue(callable(auto_flag_expired_reports))

    def test_the_task_is_not_in_the_beat_schedule(self):
        from config.celery import app
        schedule = app.conf.beat_schedule
        tasks = {entry.get('task') for entry in schedule.values()}
        self.assertNotIn('apps.moderation.tasks.auto_flag_expired_reports', tasks)
