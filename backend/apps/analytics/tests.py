from django.test import SimpleTestCase, TestCase
from rest_framework.test import APIClient
from rest_framework import status

from apps.accounts.models import User
from apps.profiles.models import Profile

from .models import AnalyticsEvent
from .serializers import ActivityRecordSerializer


class AnalyticsValidationTests(SimpleTestCase):
    def test_rejects_negative_activity_values(self):
        serializer = ActivityRecordSerializer(data={'duration_seconds': -1})
        self.assertFalse(serializer.is_valid())


class SummaryContractTests(TestCase):
    """The summary response must always include every section key the
    clients read unconditionally — a missing key crashes the apps."""

    def setUp(self):
        self.user = User.objects.create_user(email='summary@example.com', password='TestPass123!')
        self.profile = Profile.objects.create(user=self.user, username='summaryuser', display_name='Summary User')
        self.client = APIClient()
        self.client.force_authenticate(self.user)

    def test_summary_includes_nutrition_block(self):
        from . import engine
        summary = engine.build_summary(self.profile, 'month')
        self.assertIn('nutrition', summary)
        for key in ('count', 'total_calories', 'total_protein_g',
                    'total_carbs_g', 'total_fat_g', 'by_type',
                    'avg_daily_calories', 'recent'):
            self.assertIn(key, summary['nutrition'])

    def test_summary_endpoint_returns_nutrition(self):
        resp = self.client.get('/api/v1/analytics/summary/', {'period': 'month'})
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertIn('nutrition', resp.data['data'])


class EventIngestionTests(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(email='events@example.com', password='TestPass123!')
        self.profile = Profile.objects.create(user=self.user, username='eventsuser', display_name='Events User')
        self.client = APIClient()
        self.client.force_authenticate(self.user)

    def _post(self, events, **overrides):
        payload = {'events': events, **overrides}
        return self.client.post('/api/v1/analytics/events/', payload, format='json')

    def test_batch_accepted_and_stored(self):
        resp = self._post([
            {'event_name': 'feed.post_impression', 'object_type': 'post', 'object_id': 'abc',
             'properties': {'feed_tab': 'for_you', 'rank': 3}, 'consent': {'analytics': True}},
            {'event_name': 'feed.tab_selected', 'properties': {'feed_tab': 'videos'}, 'consent': {'analytics': True}},
        ])
        self.assertEqual(resp.status_code, status.HTTP_202_ACCEPTED)
        self.assertEqual(resp.data['data']['accepted'], 2)
        self.assertEqual(AnalyticsEvent.objects.count(), 2)
        event = AnalyticsEvent.objects.get(event_name='feed.post_impression')
        self.assertEqual(event.actor, self.profile)
        self.assertEqual(event.properties['rank'], 3)

    def test_missing_consent_is_skipped_not_stored(self):
        resp = self._post([
            {'event_name': 'feed.loaded', 'properties': {}},
            {'event_name': 'feed.loaded', 'properties': {}, 'consent': {'analytics': False}},
        ])
        self.assertEqual(resp.status_code, status.HTTP_202_ACCEPTED)
        self.assertEqual(resp.data['data']['skipped'], 2)
        self.assertEqual(AnalyticsEvent.objects.count(), 0)

    def test_invalid_event_name_rejected(self):
        resp = self._post([{'event_name': 'Bad Name!', 'consent': {'analytics': True}}])
        self.assertEqual(resp.data['data']['skipped'], 1)
        self.assertEqual(AnalyticsEvent.objects.count(), 0)

    def test_oversized_batch_rejected(self):
        resp = self._post([
            {'event_name': 'feed.loaded', 'consent': {'analytics': True}},
        ] * 51)
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)

    def test_anonymous_requires_anonymous_id(self):
        client = APIClient()
        resp = client.post('/api/v1/analytics/events/', {'events': [
            {'event_name': 'feed.loaded', 'consent': {'analytics': True}},
        ]}, format='json')
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)

        resp = client.post('/api/v1/analytics/events/', {
            'anonymous_id': 'anon-123',
            'events': [{'event_name': 'feed.loaded', 'consent': {'analytics': True}}],
        }, format='json')
        self.assertEqual(resp.status_code, status.HTTP_202_ACCEPTED)
        self.assertEqual(AnalyticsEvent.objects.filter(anonymous_id='anon-123').count(), 1)
