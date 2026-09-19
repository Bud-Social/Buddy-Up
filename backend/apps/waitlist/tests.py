"""Tests for the public waitlist signup (apps.waitlist)."""

from django.test import TestCase
from rest_framework import status
from rest_framework.test import APIClient

from apps.waitlist.models import WaitlistEntry


class WaitlistSignupTests(TestCase):
    def setUp(self):
        self.client = APIClient()

    def test_create_signup_returns_201(self):
        res = self.client.post('/api/v1/waitlist/', {
            'email': 'Early@Example.com', 'name': 'Early Bird',
        }, format='json')
        assert res.status_code == status.HTTP_201_CREATED
        body = res.json()
        assert body['success'] is True
        assert body['data']['email'] == 'early@example.com'
        assert WaitlistEntry.objects.count() == 1

    def test_duplicate_email_is_idempotent(self):
        WaitlistEntry.objects.create(email='dup@example.com', source='landing')
        res = self.client.post('/api/v1/waitlist/', {
            'email': 'DUP@example.com',
        }, format='json')
        assert res.status_code == status.HTTP_200_OK
        assert res.json()['success'] is True
        assert WaitlistEntry.objects.count() == 1

    def test_invalid_email_rejected(self):
        res = self.client.post('/api/v1/waitlist/', {
            'email': 'not-an-email',
        }, format='json')
        assert res.status_code == status.HTTP_400_BAD_REQUEST

    def test_list_requires_staff(self):
        WaitlistEntry.objects.create(email='a@example.com', source='landing')
        res = self.client.get('/api/v1/waitlist/')
        assert res.status_code in (
            status.HTTP_401_UNAUTHORIZED, status.HTTP_403_FORBIDDEN,
        )
