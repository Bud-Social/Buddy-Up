from django.test import TestCase
from rest_framework.test import APIClient
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken
from datetime import date
from common.utils import hash_dob
from apps.accounts.models import User
from .models import (
    Profile, BuddyRelationship, FollowRelationship, BlockRelationship,
    RecommendationFeedback,
)
from unittest.mock import patch


class BuddySystemTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user_a = User.objects.create_user(email='a@example.com', password='TestPass123!')
        self.user_a.dob_hash = hash_dob(date(2000, 6, 15))
        self.user_a.is_adult = True
        self.user_a.save()
        self.profile_a = Profile.objects.create(user=self.user_a, username='usera', display_name='User A')

        self.user_b = User.objects.create_user(email='b@example.com', password='TestPass123!')
        self.user_b.dob_hash = hash_dob(date(2000, 6, 15))
        self.user_b.is_adult = True
        self.user_b.save()
        self.profile_b = Profile.objects.create(user=self.user_b, username='userb', display_name='User B')

        self.login_response = None
        self.token = RefreshToken.for_user(self.user_a).access_token
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {self.token}')

    def test_send_buddy_request(self):
        response = self.client.post('/api/v1/profiles/userb/buddy/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(BuddyRelationship.objects.filter(
            from_user=self.profile_a, to_user=self.profile_b, status='pending'
        ).exists())

    def test_accept_buddy_request(self):
        BuddyRelationship.objects.create(from_user=self.profile_b, to_user=self.profile_a, status='pending')
        response = self.client.post('/api/v1/profiles/userb/buddy/accept/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(BuddyRelationship.objects.filter(
            from_user=self.profile_b, to_user=self.profile_a, status='confirmed'
        ).exists())

    def test_decline_buddy_request(self):
        BuddyRelationship.objects.create(from_user=self.profile_b, to_user=self.profile_a, status='pending')
        response = self.client.post('/api/v1/profiles/userb/buddy/decline/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(BuddyRelationship.objects.filter(
            from_user=self.profile_b, to_user=self.profile_a, status='declined'
        ).exists())

    def test_cannot_buddy_self(self):
        response = self.client.post('/api/v1/profiles/usera/buddy/')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_follow_user(self):
        response = self.client.post('/api/v1/profiles/userb/follow/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(FollowRelationship.objects.filter(
            follower=self.profile_a, followee=self.profile_b
        ).exists())

    def test_unfollow_user(self):
        FollowRelationship.objects.create(follower=self.profile_a, followee=self.profile_b)
        response = self.client.delete('/api/v1/profiles/userb/follow/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertFalse(FollowRelationship.objects.filter(
            follower=self.profile_a, followee=self.profile_b
        ).exists())

    def test_block_user(self):
        response = self.client.post('/api/v1/profiles/userb/block/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(BlockRelationship.objects.filter(
            blocker=self.profile_a, blocked=self.profile_b
        ).exists())

    def test_block_removes_buddy(self):
        BuddyRelationship.objects.create(from_user=self.profile_a, to_user=self.profile_b, status='confirmed')
        self.client.post('/api/v1/profiles/userb/block/')
        self.assertFalse(BuddyRelationship.objects.filter(
            from_user=self.profile_a, to_user=self.profile_b
        ).exists())


class ProfileTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(email='profile@example.com', password='TestPass123!')
        self.user.dob_hash = hash_dob(date(2000, 6, 15))
        self.user.email_verified = True
        self.user.save()
        self.profile = Profile.objects.create(user=self.user, username='profileuser', display_name='Profile User',
                                               bio='Test bio', location_city='Nairobi')

        refresh = RefreshToken.for_user(self.user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')

    def test_get_my_profile(self):
        response = self.client.get('/api/v1/profiles/me/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['data']['username'], 'profileuser')
        self.assertEqual(response.data['data']['bio'], 'Test bio')

    def test_update_profile(self):
        response = self.client.patch('/api/v1/profiles/me/', {'bio': 'Updated bio'}, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.profile.refresh_from_db()
        self.assertEqual(self.profile.bio, 'Updated bio')

    def test_get_public_profile(self):
        response = self.client.get('/api/v1/profiles/profileuser/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['data']['display_name'], 'Profile User')


class RecommendationTests(TestCase):
    def setUp(self):
        self.viewer_user = User.objects.create_user(
            email='viewer@example.com', password='TestPass123!',
        )
        self.viewer = Profile.objects.create(
            user=self.viewer_user, username='viewer', display_name='Viewer',
            location_city='Nairobi',
        )
        self.target_user = User.objects.create_user(
            email='target@example.com', password='TestPass123!',
        )
        self.target = Profile.objects.create(
            user=self.target_user, username='target', display_name='Target',
            location_city='Nairobi',
        )
        token = RefreshToken.for_user(self.viewer_user).access_token
        self.client = APIClient()
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {token}')

    @patch('requests.post', side_effect=RuntimeError('AI unavailable'))
    def test_fallback_recommendations_include_explanation(self, _post):
        response = self.client.get('/api/v1/profiles/recommendations/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['data'][0]['explanation']['code'], 'same_city')

    @patch('requests.post', side_effect=RuntimeError('AI unavailable'))
    def test_feedback_excludes_target_and_is_updatable(self, _post):
        url = '/api/v1/profiles/recommendations/feedback/'
        response = self.client.post(url, {
            'target_user_id': str(self.target.user_id), 'feedback': 'not_interested',
        }, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(RecommendationFeedback.objects.count(), 1)

        response = self.client.get('/api/v1/profiles/recommendations/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['data'], [])

        response = self.client.post(url, {
            'target_user_id': str(self.target.user_id), 'feedback': 'helpful',
        }, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        feedback = RecommendationFeedback.objects.get()
        self.assertEqual(feedback.feedback, 'helpful')
        # History is append-only: the earlier 'not_interested' is preserved.
        self.assertEqual(
            [h['feedback'] for h in feedback.history],
            ['not_interested', 'helpful'],
        )

    @patch('requests.post', side_effect=RuntimeError('AI unavailable'))
    def test_recommendations_record_exposure_events(self, _post):
        from apps.analytics.models import AnalyticsEvent
        response = self.client.get('/api/v1/profiles/recommendations/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        exposures = AnalyticsEvent.objects.filter(event_name='recommendation.item_impression')
        self.assertEqual(exposures.count(), response.data and len(response.data['data']))
        first = exposures.order_by('properties').first()
        self.assertIsNotNone(first)
        self.assertIn('rank', first.properties)
        self.assertIn('batch_id', first.properties)


class OnboardingNormalizationTests(TestCase):
    """Both display labels and alias values normalize to canonical choices."""

    def setUp(self):
        self.user = User.objects.create_user(email='onb@example.com', password='TestPass123!')
        self.profile = Profile.objects.create(user=self.user, username='onbuser', display_name='Onb User')
        self.client = APIClient()
        self.client.force_authenticate(self.user)

    def _post(self, payload):
        return self.client.post(
            '/api/v1/profiles/onboarding/',
            {**payload, 'terms_version': '2026-08-v1'},
            format='json',
        )

    def _canonical_payload(self):
        return {
            'primary_goal': ['weight_loss'],
            'activity_level': 'moderately_active',
            'preferred_workouts': ['running'],
            'dietary_preference': 'none',
            'preferred_time': 'morning',
        }

    def test_canonical_values_accepted(self):
        response = self._post(self._canonical_payload())
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(self.user.preferences['primary_goal'], ['weight_loss'])

    def test_flutter_labels_and_aliases_accepted(self):
        payload = self._canonical_payload()
        payload.update({
            'primary_goal': ['Lose Weight', 'Build Muscle', 'Improve Endurance', 'General Fitness'],
            'activity_level': 'Extremely Active',
            'preferred_workouts': ['Weightlifting', 'Boxing', 'Running'],
            'dietary_preference': 'Mediterranean',
            'preferred_time': 'Late Night',
        })
        response = self._post(payload)
        self.assertEqual(response.status_code, status.HTTP_200_OK, response.data)
        prefs = self.user.preferences
        self.assertEqual(prefs['primary_goal'], ['weight_loss', 'muscle_gain', 'endurance', 'general_wellness'])
        self.assertEqual(prefs['activity_level'], 'athlete')
        self.assertEqual(prefs['preferred_workouts'], ['weights', 'martial_arts', 'running'])
        self.assertEqual(prefs['dietary_preference'], 'other')
        self.assertEqual(prefs['preferred_time'], 'night')

    def test_truly_unknown_value_still_rejected(self):
        payload = self._canonical_payload()
        payload['activity_level'] = 'couch_potato'
        response = self._post(payload)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
