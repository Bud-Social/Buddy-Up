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

    def test_gym_lead_requires_gym_details(self):
        res = self.client.post('/api/v1/waitlist/', {
            'email': 'gym@example.com', 'name': 'Founder', 'country': 'Kenya',
            'interest': 'gym', 'metadata': {},
        }, format='json')
        assert res.status_code == status.HTTP_400_BAD_REQUEST

    def test_gym_lead_with_details_returns_201(self):
        res = self.client.post('/api/v1/waitlist/', {
            'email': 'gym@example.com', 'name': 'Founder', 'country': 'Kenya',
            'interest': 'gym',
            'metadata': {'gym_name': 'Iron House', 'city': 'Nairobi',
                         'gym_type': 'hybrid', 'onboard_coaches': True},
        }, format='json')
        assert res.status_code == status.HTTP_201_CREATED
        body = res.json()
        assert body['data']['interest'] == 'gym'
        assert body['data']['metadata']['gym_name'] == 'Iron House'

    def test_trainer_lead_requires_city(self):
        res = self.client.post('/api/v1/waitlist/', {
            'email': 'coach@example.com', 'country': 'Kenya',
            'interest': 'trainer', 'metadata': {'role': 'trainer'},
        }, format='json')
        assert res.status_code == status.HTTP_400_BAD_REQUEST

    def test_trainer_lead_with_details_returns_201(self):
        res = self.client.post('/api/v1/waitlist/', {
            'email': 'coach@example.com', 'country': 'Kenya',
            'interest': 'trainer',
            'metadata': {'role': 'practitioner', 'city': 'Kisumu',
                         'specialties': ['yoga'], 'virtual': True},
        }, format='json')
        assert res.status_code == status.HTTP_201_CREATED
        assert res.json()['data']['interest'] == 'trainer'

    def test_corporate_lead_requires_company_and_city(self):
        res = self.client.post('/api/v1/waitlist/', {
            'email': 'hr@acme.co', 'country': 'Kenya',
            'interest': 'corporate', 'metadata': {},
        }, format='json')
        assert res.status_code == status.HTTP_400_BAD_REQUEST

    def test_corporate_lead_with_details_returns_201(self):
        res = self.client.post('/api/v1/waitlist/', {
            'email': 'hr@acme.co', 'country': 'Kenya',
            'interest': 'corporate',
            'metadata': {'company_name': 'Acme Ltd', 'city': 'Nairobi',
                         'team_size': '11–50', 'packages': ['challenges']},
        }, format='json')
        assert res.status_code == status.HTTP_201_CREATED
        assert res.json()['data']['interest'] == 'corporate'

    def test_organiser_supplier_distributor_leads(self):
        cases = [
            ('organiser', {'brand': 'Nairobi Run Club', 'city': 'Nairobi',
                           'event_types': ['fitness'], 'audience': '50–200'}),
            ('supplier', {'business': 'FitFuel', 'city': 'Nairobi',
                          'categories': ['supplements'], 'has_shop': False}),
            ('distributor', {'business': 'GymEquip EA', 'city': 'Nairobi',
                             'coverage': 'Kenya', 'offerings': 'Machines'}),
        ]
        for i, (interest, metadata) in enumerate(cases):
            res = self.client.post('/api/v1/waitlist/', {
                'email': f'lead{i}@example.com', 'country': 'Kenya',
                'interest': interest, 'metadata': metadata,
            }, format='json')
            assert res.status_code == status.HTTP_201_CREATED, res.json()
            assert res.json()['data']['interest'] == interest

    def test_supplier_lead_requires_business_and_city(self):
        res = self.client.post('/api/v1/waitlist/', {
            'email': 'shop@example.com', 'country': 'Kenya',
            'interest': 'supplier', 'metadata': {},
        }, format='json')
        assert res.status_code == status.HTTP_400_BAD_REQUEST


@mock.patch.dict('os.environ', {'GOOGLE_SHEETS_WEBHOOK_URL': ''})
class MirrorRoutingTests(TestCase):
    def test_user_interest_routes_to_users_sheet(self):
        from apps.waitlist.sheets import resolve_mirror_target
        with mock.patch.dict('os.environ', {
            'GOOGLE_SHEETS_WEBHOOK_URL': 'https://users.example/exec',
            'CONS_ALL_SHEETS': 'https://cons.example/exec',
            'SHEETS_MIRROR_KEY': 'secret',
        }):
            url, key = resolve_mirror_target('user')
            assert url == 'https://users.example/exec'
            assert key == ''

    def test_segment_interests_route_to_consolidated_sheet_with_key(self):
        from apps.waitlist.sheets import resolve_mirror_target
        with mock.patch.dict('os.environ', {
            'GOOGLE_SHEETS_WEBHOOK_URL': 'https://users.example/exec',
            'CONS_ALL_SHEETS': 'https://cons.example/exec',
            'SHEETS_MIRROR_KEY': 'secret',
        }):
            for interest in ('gym', 'trainer', 'corporate', 'organiser',
                             'supplier', 'distributor', 'partnership',
                             'investor'):
                url, key = resolve_mirror_target(interest)
                assert url == 'https://cons.example/exec', interest
                assert key == 'secret', interest

    def test_consolidated_falls_back_to_users_sheet_when_unset(self):
        from apps.waitlist.sheets import resolve_mirror_target
        with mock.patch.dict('os.environ', {
            'GOOGLE_SHEETS_WEBHOOK_URL': 'https://users.example/exec',
            'CONS_ALL_SHEETS': '',
            'SHEETS_MIRROR_KEY': 'secret',
        }):
            url, key = resolve_mirror_target('gym')
            assert url == 'https://users.example/exec'
            assert key == ''

    def test_unknown_interest_falls_back_to_users_sheet(self):
        from apps.waitlist.sheets import resolve_mirror_target
        with mock.patch.dict('os.environ', {
            'GOOGLE_SHEETS_WEBHOOK_URL': 'https://users.example/exec',
            'CONS_ALL_SHEETS': 'https://cons.example/exec',
            'SHEETS_MIRROR_KEY': 'secret',
        }):
            url, key = resolve_mirror_target('something-new')
            assert url == 'https://users.example/exec'
            assert key == ''


@mock.patch.dict('os.environ', {'GOOGLE_SHEETS_WEBHOOK_URL': ''})
class PublicIntakeTests(TestCase):
    def setUp(self):
        self.client = APIClient()

    def test_suggestion_create_returns_201(self):
        res = self.client.post('/api/v1/waitlist/suggestions/', {
            'title': 'Corporate step challenge',
            'description': 'Let companies run month-long step challenges.',
            'category': 'gyms',
            'email': 'fan@example.com',
        }, format='json')
        assert res.status_code == status.HTTP_201_CREATED
        assert res.json()['success'] is True

    def test_suggestion_requires_title_and_description(self):
        res = self.client.post('/api/v1/waitlist/suggestions/', {
            'title': '',
        }, format='json')
        assert res.status_code == status.HTTP_400_BAD_REQUEST

    def test_suggestion_list_requires_staff(self):
        res = self.client.get('/api/v1/waitlist/suggestions/')
        assert res.status_code in (
            status.HTTP_401_UNAUTHORIZED, status.HTTP_403_FORBIDDEN,
        )

    def test_contact_create_returns_201(self):
        res = self.client.post('/api/v1/waitlist/contact/', {
            'name': 'Alex', 'email': 'alex@example.com', 'topic': 'gyms',
            'subject': 'Partner onboarding',
            'message': 'We run three branches in Nairobi.',
        }, format='json')
        assert res.status_code == status.HTTP_201_CREATED
        assert res.json()['success'] is True

    def test_contact_requires_message(self):
        res = self.client.post('/api/v1/waitlist/contact/', {
            'name': 'Alex', 'email': 'alex@example.com',
        }, format='json')
        assert res.status_code == status.HTTP_400_BAD_REQUEST

    def test_contact_list_requires_staff(self):
        res = self.client.get('/api/v1/waitlist/contact/')
        assert res.status_code in (
            status.HTTP_401_UNAUTHORIZED, status.HTTP_403_FORBIDDEN,
        )

    def test_career_create_returns_201(self):
        res = self.client.post('/api/v1/waitlist/careers/', {
            'name': 'Wanjiku', 'email': 'wanjiku@example.com',
            'role': 'Founding Mobile Engineer',
            'portfolio_url': 'https://example.com/work',
            'message': '5 years of Flutter and fitness apps.',
        }, format='json')
        assert res.status_code == status.HTTP_201_CREATED
        assert res.json()['success'] is True

    def test_career_requires_role_and_message(self):
        res = self.client.post('/api/v1/waitlist/careers/', {
            'name': 'Wanjiku', 'email': 'wanjiku@example.com',
        }, format='json')
        assert res.status_code == status.HTTP_400_BAD_REQUEST

    def test_career_list_requires_staff(self):
        res = self.client.get('/api/v1/waitlist/careers/')
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
