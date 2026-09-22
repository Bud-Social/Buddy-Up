"""Tests for the public waitlist signup (apps.waitlist)."""

from unittest import mock

from django.test import TestCase
from rest_framework import status
from rest_framework.test import APIClient

from apps.waitlist.models import WaitlistEntry


# Keep the Sheets mirror off for these tests even when the environment
# (e.g. a docker container with GOOGLE_SHEETS_WEBHOOK_URL set) provides it —
# otherwise a signup test would POST a junk row to the real spreadsheet.
@mock.patch.dict('os.environ', {'GOOGLE_SHEETS_WEBHOOK_URL': ''})
class WaitlistSignupTests(TestCase):
    def setUp(self):
        self.client = APIClient()

    def test_create_signup_returns_201(self):
        res = self.client.post('/api/v1/waitlist/', {
            'email': 'Early@Example.com', 'name': 'Early Bird', 'country': 'Kenya',
        }, format='json')
        assert res.status_code == status.HTTP_201_CREATED
        body = res.json()
        assert body['success'] is True
        assert body['data']['email'] == 'early@example.com'
        assert body['data']['country'] == 'Kenya'
        assert WaitlistEntry.objects.count() == 1

    def test_country_is_required(self):
        res = self.client.post('/api/v1/waitlist/', {
            'email': 'nocountry@example.com',
        }, format='json')
        assert res.status_code == status.HTTP_400_BAD_REQUEST

    def test_duplicate_email_is_idempotent(self):
        WaitlistEntry.objects.create(email='dup@example.com', source='landing', country='Kenya')
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
        WaitlistEntry.objects.create(email='a@example.com', source='landing', country='Kenya')
        res = self.client.get('/api/v1/waitlist/')
        assert res.status_code in (
            status.HTTP_401_UNAUTHORIZED, status.HTTP_403_FORBIDDEN,
        )


class SheetsMirrorTests(TestCase):
    """The Google Sheets relay runs server-side with a hidden webhook URL."""

    def setUp(self):
        self.client = APIClient()

    @mock.patch.dict('os.environ', {'GOOGLE_SHEETS_WEBHOOK_URL': 'https://script.example/exec'})
    @mock.patch('apps.waitlist.sheets.threading.Thread')
    @mock.patch('apps.waitlist.sheets.requests.post')
    def test_signup_mirrors_to_sheets(self, post_mock, thread_mock):
        # Run the mirror's daemon-thread target inline so the assertion is
        # deterministic (no race with the real thread scheduler).
        class _InlineThread:
            def __init__(self, target, args=(), **_kw):
                self._target, self._args = target, args

            def start(self):
                self._target(*self._args)

        thread_mock.side_effect = _InlineThread
        res = self.client.post('/api/v1/waitlist/', {
            'email': 'mirror@example.com', 'name': 'Mirror', 'country': 'Kenya',
        }, format='json')
        assert res.status_code == status.HTTP_201_CREATED
        args, kwargs = post_mock.call_args
        assert args[0] == 'https://script.example/exec'
        assert kwargs['data'] == {
            'email': 'mirror@example.com', 'name': 'Mirror',
            'country': 'Kenya', 'source': 'landing',
            'interest': 'user', 'metadata': '{}',
        }

    @mock.patch.dict('os.environ', {'GOOGLE_SHEETS_WEBHOOK_URL': ''})
    @mock.patch('apps.waitlist.sheets.requests.post')
    def test_no_mirror_when_unset(self, post_mock):
        res = self.client.post('/api/v1/waitlist/', {
            'email': 'nomirror@example.com', 'country': 'Kenya',
        }, format='json')
        assert res.status_code == status.HTTP_201_CREATED
        post_mock.assert_not_called()

    @mock.patch.dict('os.environ', {'GOOGLE_SHEETS_WEBHOOK_URL': 'https://script.example/exec'})
    @mock.patch('apps.waitlist.sheets.requests.post', side_effect=Exception('boom'))
    def test_mirror_failure_does_not_break_signup(self, post_mock):
        res = self.client.post('/api/v1/waitlist/', {
            'email': 'flaky@example.com', 'country': 'Kenya',
        }, format='json')
        assert res.status_code == status.HTTP_201_CREATED
        assert WaitlistEntry.objects.filter(email='flaky@example.com').exists()
