"""Tests for checking in at a gym.

A gym visit is what a "gym attendance" countdown follows, so both ways of
recording one — a member checking themselves in, and the gym marking a
member present — have to raise it.
"""

from datetime import timedelta

from django.test import TestCase
from django.utils import timezone
from rest_framework.test import APIClient
from rest_framework import status

from apps.accounts.models import User
from apps.countdowns.models import CountdownTemplate, UserCountdown
from apps.gyms.models import AttendanceRecord, Gym, GymMembership
from apps.profiles.models import Profile


class GymCheckInTests(TestCase):
    def setUp(self):
        self.owner_user = User.objects.create_user(email='checkin-owner@example.com', password='TestPass123!')
        self.owner = Profile.objects.create(
            user=self.owner_user, username='checkin-owner', display_name='Owner',
        )
        self.gym = Gym.objects.create(name='Checkin Gym', handle='checkingym', category='fitness')
        GymMembership.objects.create(gym=self.gym, member=self.owner, role='owner')

        self.member_user = User.objects.create_user(email='checkin-member@example.com', password='TestPass123!')
        self.member = Profile.objects.create(
            user=self.member_user, username='checkin-member', display_name='Member',
        )
        GymMembership.objects.create(
            gym=self.gym, member=self.member, role='member', subscription_active=True,
        )

        self.client = APIClient()
        self.client.force_authenticate(self.member_user)

        self.template = CountdownTemplate.objects.create(
            code='gym_attendance', title='Gym Attendance', unit='days',
            description='Consecutive days with a gym visit.', icon='🏋️', color='#3b82f6',
            default_target=0, sort_order=4,
        )

    def _countdown(self, signal='gym_checkin'):
        return UserCountdown.objects.create(
            user=self.member, template=self.template,
            countdown_type='automatic', unit='days',
            auto_advance_signal=signal, current_count=0,
        )

    def test_a_member_can_check_in(self):
        resp = self.client.post('/api/v1/gyms/checkingym/check-in/', format='json')
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED)
        record = AttendanceRecord.objects.get(gym=self.gym, member=self.member)
        self.assertEqual(record.source, 'member')
        self.assertEqual(record.status, 'checked_in')

    def test_a_non_member_cannot_check_in(self):
        other = User.objects.create_user(email='checkin-outsider@example.com', password='TestPass123!')
        outsider = Profile.objects.create(user=other, username='checkin-outsider', display_name='Outsider')
        resp = APIClient().post('/api/v1/gyms/checkingym/check-in/', format='json')
        self.assertEqual(resp.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertFalse(AttendanceRecord.objects.filter(member=outsider).exists())

    def test_a_member_cannot_check_in_twice_in_a_day(self):
        self.client.post('/api/v1/gyms/checkingym/check-in/', format='json')
        second = self.client.post('/api/v1/gyms/checkingym/check-in/', format='json')
        self.assertEqual(second.status_code, status.HTTP_409_CONFLICT)
        self.assertIn('already checked in', second.data['message'])
        self.assertEqual(AttendanceRecord.objects.filter(member=self.member).count(), 1)

    def test_checking_in_opens_again_after_the_gap(self):
        AttendanceRecord.objects.create(
            gym=self.gym, member=self.member, status='checked_in',
            checked_in_at=timezone.now() - timedelta(hours=21),
        )
        resp = self.client.post('/api/v1/gyms/checkingym/check-in/', format='json')
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED)

    def test_the_status_endpoint_says_when_you_can_check_in(self):
        resp = self.client.get('/api/v1/gyms/checkingym/check-in/')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertTrue(resp.data['data']['can_check_in'])
        self.assertTrue(resp.data['data']['is_member'])

        self.client.post('/api/v1/gyms/checkingym/check-in/', format='json')
        resp = self.client.get('/api/v1/gyms/checkingym/check-in/')
        self.assertFalse(resp.data['data']['can_check_in'])
        self.assertIsNotNone(resp.data['data']['next_check_in_at'])

    def test_checking_in_advances_a_gym_attendance_countdown(self):
        countdown = self._countdown()
        resp = self.client.post('/api/v1/gyms/checkingym/check-in/', format='json')
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED)
        countdown.refresh_from_db()
        self.assertEqual(countdown.current_count, 1)
        self.assertTrue(countdown.events.filter(event_type='auto_advance').exists())

    def test_a_gym_marking_a_member_present_also_advances_it(self):
        owner_client = APIClient()
        owner_client.force_authenticate(self.owner_user)
        resp = owner_client.post('/api/v1/gyms/checkingym/attendance/', {
            'member': str(self.member.user_id), 'status': 'checked_in',
        }, format='json')
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED)

        countdown = self._countdown()
        owner_client.post('/api/v1/gyms/checkingym/attendance/', {
            'member': str(self.member.user_id), 'status': 'checked_in',
        }, format='json')
        countdown.refresh_from_db()
        self.assertEqual(countdown.current_count, 1)
