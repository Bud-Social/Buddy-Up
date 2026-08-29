from datetime import date

from django.test import TestCase
from rest_framework.test import APIClient
from rest_framework_simplejwt.tokens import RefreshToken

from apps.accounts.models import User
from apps.profiles.models import Profile
from common.utils import hash_dob
from .models import AttendanceRecord, Gym, GymMembership


class PartnerReadinessTests(TestCase):
    def setUp(self):
        user = User.objects.create_user(email='partner@example.com', password='TestPass123!')
        user.dob_hash = hash_dob(date(1990, 1, 1))
        user.email_verified = True
        user.save(update_fields=['dob_hash', 'email_verified'])
        self.profile = Profile.objects.create(user=user, username='partner', display_name='Partner')
        self.gym = Gym.objects.create(name='Partner Gym', handle='partnergym', category='fitness')
        GymMembership.objects.create(gym=self.gym, member=self.profile, role='owner')
        self.client = APIClient()
        refresh = RefreshToken.for_user(user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')

    def test_checklist_completion_and_metrics(self):
        response = self.client.patch('/api/v1/gyms/partnergym/onboarding-checklist/', {
            'completed_steps': ['profile', 'venue', 'schedule', 'invite_members'],
        }, format='json')
        self.assertEqual(response.status_code, 200)
        self.assertIsNotNone(response.data['data']['completed_at'])
        response = self.client.post('/api/v1/gyms/partnergym/attendance/', {
            'member': str(self.profile.user_id), 'status': 'checked_in',
        }, format='json')
        self.assertEqual(response.status_code, 201)
        self.assertEqual(AttendanceRecord.objects.filter(gym=self.gym).count(), 1)
        response = self.client.get('/api/v1/gyms/partnergym/partner-metrics/')
        self.assertEqual(response.data['data']['check_ins_30d'], 1)

    def test_member_csv_export(self):
        response = self.client.get('/api/v1/gyms/partnergym/members.csv')
        self.assertEqual(response.status_code, 200)
        self.assertIn('username,email,display_name,role,subscription_active', response.content.decode())
