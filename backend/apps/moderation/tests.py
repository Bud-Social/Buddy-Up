from django.test import TestCase
from django.utils import timezone
from rest_framework.test import APIClient
from rest_framework import status
from datetime import date
from unittest.mock import patch, MagicMock
from common.utils import hash_dob
from apps.accounts.models import User
from apps.profiles.models import Profile
from apps.moderation.models import ContentFlag
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

    def test_trainer_review_sets_profile_status(self):
        user_client = APIClient()
        user_client.force_authenticate(self.user)
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
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        sub.refresh_from_db()
        self.profile.refresh_from_db()
        self.assertEqual(sub.status, 'approved')
        self.assertEqual(self.profile.verification_status, 'trainer')
        self.assertEqual(sub.documents.first().status, 'approved')

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
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
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
