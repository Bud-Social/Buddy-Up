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
