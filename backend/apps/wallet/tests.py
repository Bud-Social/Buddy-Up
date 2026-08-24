from django.test import TestCase
from rest_framework.test import APIClient
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken
from datetime import date
from common.utils import hash_dob
from apps.accounts.models import User
from apps.profiles.models import Profile
from apps.wallet.models import ArtifactTransaction


class WalletTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(email='wallet@example.com', password='TestPass123!')
        self.user.dob_hash = hash_dob(date(2000, 6, 15))
        self.user.email_verified = True
        self.user.save()
        self.profile = Profile.objects.create(user=self.user, username='walletuser', display_name='Wallet User')

        refresh = RefreshToken.for_user(self.user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')

    def test_get_balance(self):
        response = self.client.get('/api/v1/wallet/balance/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('balance', response.data['data'])
        self.assertIn('total_label', response.data['data'])

    def test_purchase_artifacts(self):
        data = {'artifact_type': 'dumbbell', 'quantity': 10, 'payment_method': 'card'}
        response = self.client.post('/api/v1/wallet/purchase/initialize/', data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['data']['amount'], 1.0)
        self.assertTrue(ArtifactTransaction.objects.filter(user=self.profile, transaction_type='purchase').exists())

    def test_get_bundles(self):
        response = self.client.get('/api/v1/wallet/bundles/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIsInstance(response.data['data'], list)


class FlutterwaveWebhookSecurityTests(TestCase):
    """The webhook must fail closed and only credit verified successful charges."""

    def setUp(self):
        from django.test import override_settings
        self.override = override_settings(FLUTTERWAVE_WEBHOOK_HASH='test-secret-hash')
        self.override.enable()
        self.addCleanup(self.override.disable)

        self.client = APIClient()
        self.user = User.objects.create_user(email='hook@example.com', password='TestPass123!')
        self.profile = Profile.objects.create(user=self.user, username='hookuser', display_name='Hook User')
        self.tx = ArtifactTransaction.objects.create(
            user=self.profile,
            transaction_type='purchase',
            artifact_type='dumbbell',
            quantity=10,
            direction='credit',
            status='pending',
            tx_ref='BU-TEST-REF-1',
            fiat_amount=1.00,
            fiat_currency='USD',
        )
        self.url = '/api/v1/wallet/flutterwave-webhook/'
        self.payload = {
            'event': 'charge.completed',
            'data': {
                'id': 987654,
                'tx_ref': 'BU-TEST-REF-1',
                'status': 'successful',
                'amount': 1.00,
                'currency': 'USD',
            },
        }

    def _post_signed(self):
        return self.client.post(
            self.url, data=self.payload, format='json', HTTP_VERIF_HASH='test-secret-hash',
        )

    def test_rejects_when_hash_not_configured(self):
        from django.test import override_settings
        with override_settings(FLUTTERWAVE_WEBHOOK_HASH=''):
            resp = self.client.post(self.url, data=self.payload, format='json', HTTP_VERIF_HASH='')
            self.assertEqual(resp.status_code, status.HTTP_503_SERVICE_UNAVAILABLE)
        self.tx.refresh_from_db()
        self.assertEqual(self.tx.status, 'pending')

    def test_rejects_bad_signature(self):
        resp = self.client.post(self.url, data=self.payload, format='json', HTTP_VERIF_HASH='wrong')
        self.assertEqual(resp.status_code, status.HTTP_403_FORBIDDEN)
        self.tx.refresh_from_db()
        self.assertEqual(self.tx.status, 'pending')

    def test_successful_charge_credits_once(self):
        balance_before = ArtifactTransaction.objects.filter(
            user=self.profile, transaction_type='purchase', status='completed',
        ).count()
        resp = self._post_signed()
        self.assertEqual(resp.status_code, 200)
        self.tx.refresh_from_db()
        self.assertEqual(self.tx.status, 'completed')
        self.assertEqual(self.tx.flutterwave_id, '987654')

        # Replay: already completed -> no double credit, no crash.
        resp2 = self._post_signed()
        self.assertEqual(resp2.status_code, 200)
        balance_after = ArtifactTransaction.objects.filter(
            user=self.profile, transaction_type='purchase', status='completed',
        ).count()
        self.assertEqual(balance_before + 1, balance_after)

    def test_ignores_unsuccessful_charge(self):
        self.payload['data']['status'] = 'failed'
        resp = self._post_signed()
        self.assertEqual(resp.status_code, 200)
        self.tx.refresh_from_db()
        self.assertEqual(self.tx.status, 'pending')

    def test_rejects_amount_mismatch(self):
        self.payload['data']['amount'] = 0.01
        resp = self._post_signed()
        self.assertEqual(resp.status_code, 400)
        self.tx.refresh_from_db()
        self.assertEqual(self.tx.status, 'pending')
