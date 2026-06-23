from django.test import TestCase
from rest_framework.test import APIClient
from rest_framework import status
from datetime import date
from common.utils import hash_dob
from apps.accounts.models import User
from apps.profiles.models import Profile


class WalletTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(email='wallet@example.com', password='TestPass123!')
        self.user.dob_hash = hash_dob(date(2000, 6, 15))
        self.user.save()
        self.profile = Profile.objects.create(user=self.user, username='walletuser', display_name='Wallet User')

        login_res = self.client.post('/api/v1/auth/login/',
            {'email': 'wallet@example.com', 'password': 'TestPass123!'}, format='json')
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {login_res.data["data"]["access"]}')

    def test_get_balance(self):
        response = self.client.get('/api/v1/wallet/balance/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('balance', response.data['data'])
        self.assertIn('total_label', response.data['data'])

    def test_purchase_artifacts(self):
        data = {'artifact_type': 'dumbbell', 'quantity': 10, 'payment_method': 'stripe'}
        response = self.client.post('/api/v1/wallet/purchase/', data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.profile.refresh_from_db()
        self.assertEqual(self.profile.artifact_balance.get('dumbbell', 0), 10)

    def test_get_bundles(self):
        response = self.client.get('/api/v1/wallet/bundles/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIsInstance(response.data['data'], list)
