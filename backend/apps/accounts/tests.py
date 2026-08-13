from django.test import TestCase
from django.contrib.auth import authenticate
from rest_framework.test import APIClient
from rest_framework import status
from datetime import date
from .models import User, OTPToken, DeviceSession
from apps.profiles.models import Profile
from common.utils import hash_dob, calculate_age


class AuthTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.register_url = '/api/v1/auth/register/'
        self.login_url = '/api/v1/auth/login/'
        self.refresh_url = '/api/v1/auth/token/refresh/'

    def test_register_user_creates_account(self):
        data = {
            'email': 'test@example.com',
            'password': 'TestPass123!',
            'dob': '2000-06-15',
            'username': 'testuser',
            'display_name': 'Test User',
            'role': 'user',
            'accepted_terms': True,
            'accepted_privacy': True,
            'accepted_guidelines': True,
            'is_16_plus': True,
        }
        response = self.client.post(self.register_url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(response.data['success'])
        self.assertIn('registration_token', response.data['data'])
        self.assertTrue(User.objects.filter(email='test@example.com').exists())
        self.assertTrue(Profile.objects.filter(username='testuser').exists())

        user = User.objects.get(email='test@example.com')
        self.assertFalse(user.email_verified)
        otp = OTPToken.objects.get(user=user, channel='email', is_used=False).code
        verify_data = {
            'registration_token': response.data['data']['registration_token'],
            'otp': otp,
        }
        verify_res = self.client.post(
            '/api/v1/auth/verify-registration-otp/', verify_data, format='json')
        self.assertEqual(verify_res.status_code, status.HTTP_200_OK)
        self.assertIn('access', verify_res.data['data'])
        self.assertIn('refresh', verify_res.data['data'])
        user.refresh_from_db()
        self.assertTrue(user.email_verified)

    def test_register_under_16_blocked(self):
        today = date.today()
        dob = date(today.year - 15, 6, 15)
        data = {
            'email': 'young@example.com',
            'password': 'TestPass123!',
            'dob': dob.isoformat(),
            'username': 'younguser',
            'display_name': 'Young User',
            'role': 'user',
            'accepted_terms': True,
            'accepted_privacy': True,
            'accepted_guidelines': True,
            'is_16_plus': True,
        }
        response = self.client.post(self.register_url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertFalse(User.objects.filter(email='young@example.com').exists())

    def test_login_with_valid_credentials(self):
        user = User.objects.create_user(email='login@example.com', password='TestPass123!')
        user.dob_hash = hash_dob(date(2000, 6, 15))
        user.is_adult = True
        user.email_verified = True
        user.save()
        Profile.objects.create(user=user, username='loginuser', display_name='Login User')

        data = {'email': 'login@example.com', 'password': 'TestPass123!'}
        response = self.client.post(self.login_url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data['success'])
        self.assertTrue(response.data['data']['require_otp'])
        self.assertIn('login_token', response.data['data'])

        otp = OTPToken.objects.get(user=user, channel='email', is_used=False).code
        verify_data = {
            'login_token': response.data['data']['login_token'],
            'otp': otp,
        }
        verify_res = self.client.post(
            '/api/v1/auth/verify-login-otp/', verify_data, format='json')
        self.assertEqual(verify_res.status_code, status.HTTP_200_OK)
        self.assertIn('access', verify_res.data['data'])

    def test_login_with_wrong_password(self):
        user = User.objects.create_user(email='wrong@example.com', password='CorrectPass1!')
        user.dob_hash = hash_dob(date(2000, 6, 15))
        user.save()
        Profile.objects.create(user=user, username='wronguser', display_name='Wrong User')

        data = {'email': 'wrong@example.com', 'password': 'WrongPass1!'}
        response = self.client.post(self.login_url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_token_refresh(self):
        user = User.objects.create_user(email='refresh@example.com', password='TestPass123!')
        user.dob_hash = hash_dob(date(2000, 6, 15))
        user.is_adult = True
        user.email_verified = True
        user.save()
        Profile.objects.create(user=user, username='refreshuser', display_name='Refresh User')

        login_data = {'email': 'refresh@example.com', 'password': 'TestPass123!'}
        login_res = self.client.post(self.login_url, login_data, format='json')
        self.assertTrue(login_res.data['data']['require_otp'])
        otp = OTPToken.objects.get(user=user, channel='email', is_used=False).code
        verify_data = {
            'login_token': login_res.data['data']['login_token'],
            'otp': otp,
        }
        login_verified = self.client.post(
            '/api/v1/auth/verify-login-otp/', verify_data, format='json')
        refresh_token = login_verified.data['data']['refresh']

        refresh_data = {'refresh': refresh_token}
        response = self.client.post(self.refresh_url, refresh_data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('access', response.data['data'])

    def test_otp_created_on_register(self):
        data = {
            'email': 'otp@example.com',
            'password': 'TestPass123!',
            'dob': '2000-06-15',
            'username': 'otpuser',
            'display_name': 'OTP User',
            'role': 'user',
            'accepted_terms': True,
            'accepted_privacy': True,
            'accepted_guidelines': True,
            'is_16_plus': True,
        }
        self.client.post(self.register_url, data, format='json')
        user = User.objects.get(email='otp@example.com')
        self.assertTrue(OTPToken.objects.filter(user=user, channel='email').exists())


class AgeGateTests(TestCase):
    def test_16_years_exact_allowed(self):
        age = calculate_age(date(2010, 6, 23))
        self.assertEqual(age, 16)

    def test_15_years_blocked(self):
        age = calculate_age(date(2011, 6, 23))
        self.assertLess(age, 16)

    def test_25_years_allowed(self):
        age = calculate_age(date(1999, 6, 23))
        self.assertGreaterEqual(age, 16)
