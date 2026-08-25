"""Tests for the achievements (gamification) system."""
from datetime import timedelta

from django.test import TestCase
from django.utils import timezone
from rest_framework.test import APIClient
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken

from apps.accounts.models import User
from apps.analytics.models import ActivityRecord
from apps.gamification.models import AchievementDefinition, UserAchievement
from apps.profiles.models import Profile
from .services import compute_metrics, evaluate_profile


def _make_user(email):
    user = User.objects.create_user(email=email, password='TestPass123!')
    user.dob_hash = 'x' * 64
    user.is_adult = True
    user.email_verified = True
    user.save()
    return Profile.objects.create(user=user, username=email.split('@')[0], display_name='Tester')


def _make_activity(profile, distance_m=1000.0, duration_s=600):
    return ActivityRecord.objects.create(
        user=profile,
        activity_type='run',
        source='gps',
        started_at=timezone.now(),
        duration_seconds=duration_s,
        distance_meters=distance_m,
    )


class AchievementServiceTests(TestCase):
    def setUp(self):
        self.profile = _make_user('achiever@test.com')

    def test_seed_definitions_loaded(self):
        codes = set(AchievementDefinition.objects.values_list('code', flat=True))
        self.assertIn('first_activity', codes)
        self.assertIn('distance_100km', codes)
        self.assertGreaterEqual(AchievementDefinition.objects.filter(is_active=True).count(), 15)

    def test_compute_metrics_counts(self):
        _make_activity(self.profile)
        _make_activity(self.profile, distance_m=2000.0)
        metrics = compute_metrics(self.profile)
        self.assertEqual(metrics['activities_total'], 2)
        self.assertAlmostEqual(metrics['activities_distance_km'], 3.0)

    def test_evaluate_unlocks_and_is_idempotent(self):
        _make_activity(self.profile)
        earned = evaluate_profile(self.profile)
        earned_codes = {ua.definition.code for ua in earned}
        # 1 activity + 1 km → unlocks first_activity only (1km < 10km).
        self.assertIn('first_activity', earned_codes)
        self.assertNotIn('distance_10km', earned_codes)

        # Idempotent: re-running does not duplicate awards.
        evaluate_profile(self.profile)
        self.assertEqual(
            UserAchievement.objects.filter(
                profile=self.profile, definition__code='first_activity',
            ).count(), 1,
        )
        first = UserAchievement.objects.get(profile=self.profile, definition__code='first_activity')
        self.assertIsNotNone(first.earned_at)

    def test_progress_tracked_without_unlock(self):
        _make_activity(self.profile, distance_m=5000.0)  # 5km — not enough for 42km badge
        evaluate_profile(self.profile)
        ua = UserAchievement.objects.get(profile=self.profile, definition__code='distance_42km')
        self.assertIsNone(ua.earned_at)
        self.assertAlmostEqual(ua.progress, 5.0)


class AchievementsEndpointTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.profile = _make_user('endpoint@test.com')
        refresh = RefreshToken.for_user(self.profile.user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')

    def test_list_payload_shape(self):
        _make_activity(self.profile)
        res = self.client.get('/api/v1/achievements/')
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = res.json()['data']
        self.assertGreaterEqual(data['summary']['total'], 15)
        first_item = next(i for i in data['items'] if i['code'] == 'first_activity')
        self.assertTrue(first_item['earned'])
        self.assertEqual(first_item['progress_pct'], 100.0)

    def test_requires_auth(self):
        client = APIClient()
        res = client.get('/api/v1/achievements/')
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_post_evaluate_endpoint(self):
        res = self.client.post('/api/v1/achievements/')
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertIsInstance(res.json()['data']['newly_earned'], list)
