from django.test import TestCase, override_settings
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
    def test_limit_param_caps_results(self, _post):
        for i in range(6):
            u = User.objects.create_user(email=f'extra{i}@example.com', password='TestPass123!')
            Profile.objects.create(user=u, username=f'extra{i}', display_name=f'Extra {i}')
        response = self.client.get('/api/v1/profiles/recommendations/', {'limit': 4})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertLessEqual(len(response.data['data']), 4)
        response = self.client.get('/api/v1/profiles/recommendations/', {'limit': 'abc'})
        self.assertEqual(response.status_code, status.HTTP_200_OK)

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


@override_settings(DEBUG=True)
class SeedBuddySearchVarietyTests(TestCase):
    """The generic seed path must produce genuinely varied rows, otherwise
    Find-a-Buddy filtering has nothing to filter on in dev."""

    @classmethod
    def setUpTestData(cls):
        for i in range(16):
            user = User.objects.create_user(email=f'seed{i}@example.com', password='TestPass123!')
            Profile.objects.create(user=user, username=f'seed{i}', display_name=f'Seed {i}')

    def setUp(self):
        from io import StringIO
        self.out = StringIO()

    def _seed(self, *args):
        from django.core.management import call_command
        call_command('seed_buddy_search', *args, stdout=self.out)

    def _rows(self):
        from .models import BuddySearchProfile
        return list(BuddySearchProfile.objects.order_by('profile__username'))

    def test_generic_seed_produces_varied_rows(self):
        self._seed('--count', '14', '--seed', '7')
        rows = self._rows()
        self.assertEqual(len(rows), 14)
        # Every field that feeds a filter must actually vary.
        self.assertEqual(len({tuple(r.intents) for r in rows}), 14)
        self.assertGreaterEqual(len({tuple(r.modes) for r in rows}), 4)
        self.assertGreaterEqual(len({r.pace for r in rows}), 4)
        self.assertEqual(len({r.neighbourhood for r in rows}), 10)
        self.assertGreaterEqual(len({r.age_band for r in rows}), 6)
        self.assertGreaterEqual(len({r.bio for r in rows}), 10)
        self.assertGreaterEqual(len({tuple(r.goals) for r in rows}), 10)

    def test_generic_rows_use_only_valid_intents(self):
        from .models import BuddySearchProfile
        self._seed('--count', '16', '--seed', '3')
        allowed = set(BuddySearchProfile.INTENT_CHOICES)
        for row in self._rows():
            self.assertTrue(set(row.intents) <= allowed, row.intents)
            self.assertTrue(set(row.modes) <= set(BuddySearchProfile.MODE_CHOICES), row.modes)
            # The search-profile serializer requires a description for 'other'.
            if 'other' in row.intents:
                self.assertTrue(row.custom_intent)

    def test_seeded_fields_fit_their_columns(self):
        self._seed('--count', '16', '--seed', '11')
        for row in self._rows():
            self.assertLessEqual(len(row.bio), 140)
            self.assertLessEqual(len(row.custom_intent), 100)
            self.assertLessEqual(len(row.pace), 20)
            self.assertLessEqual(len(row.neighbourhood), 100)
            self.assertLessEqual(len(row.age_band), 10)

    def test_neighbourhood_filter_is_repeatable_and_narrowing(self):
        self._seed('--count', '4', '--neighbourhood', 'Westlands', '--neighbourhood', 'karen')
        rows = self._rows()
        self.assertEqual(len(rows), 4)
        self.assertEqual(
            sorted(r.neighbourhood for r in rows), ['Karen', 'Karen', 'Westlands', 'Westlands'],
        )

    def test_unknown_neighbourhood_is_rejected(self):
        from django.core.management.base import CommandError
        with self.assertRaisesMessage(CommandError, 'Unknown neighbourhood'):
            self._seed('--count', '2', '--neighbourhood', 'Nakuru')

    def test_coords_cluster_near_the_assigned_neighbourhood(self):
        from apps.profiles.management.commands.seed_buddy_search import haversine_km
        self._seed('--count', '10', '--seed', '5',
                   '--neighbourhood', 'Karen', '--radius-km', '2')
        for row in self._rows():
            distance = haversine_km(-1.3300, 36.7100, float(row.latitude), float(row.longitude))
            self.assertLessEqual(distance, 2.0)

    def test_same_seed_reproduces_the_same_coordinates(self):
        self._seed('--count', '8', '--seed', '99')
        first = sorted((r.profile.username, str(r.latitude), str(r.longitude)) for r in self._rows())
        self._seed('--count', '8', '--seed', '99', '--overwrite')
        second = sorted((r.profile.username, str(r.latitude), str(r.longitude)) for r in self._rows())
        self.assertEqual(first, second)

    def test_dry_run_writes_nothing(self):
        from .models import BuddySearchProfile
        self._seed('--dry-run', '--count', '8')
        self.assertEqual(BuddySearchProfile.objects.count(), 0)
        self.assertIn('DRY-RUN', self.out.getvalue())

    def test_dry_run_prints_the_varied_fields(self):
        self._seed('--dry-run', '--count', '12')
        out = self.out.getvalue()
        self.assertEqual(out.count('would create:'), 12)
        self.assertIn('intents=', out)
        self.assertIn('pace=', out)
        self.assertIn('Westlands', out)
        self.assertIn('Karen', out)
        self.assertIn('bio:', out)

    def test_second_run_without_overwrite_seeds_a_disjoint_batch(self):
        from .models import BuddySearchProfile
        self._seed('--count', '6')
        first = set(BuddySearchProfile.objects.values_list('profile__username', flat=True))
        self.out.truncate(0)
        self.out.seek(0)
        self._seed('--count', '6')
        second = set(BuddySearchProfile.objects.values_list('profile__username', flat=True))
        # Already-seeded profiles are excluded, so batch two does not reuse
        # or overwrite batch one.
        self.assertEqual(len(second), 12)
        self.assertEqual(first & second, first)
        self.assertNotEqual(first, second)
        self.assertIn('created:', self.out.getvalue())

    def test_overwrite_is_required_to_touch_existing_rows(self):
        from .models import BuddySearchProfile
        self._seed('--count', '6')
        before = {r.profile.username: r.neighbourhood for r in BuddySearchProfile.objects.all()}
        self._seed('--count', '6', '--overwrite')
        after = {r.profile.username: r.neighbourhood for r in BuddySearchProfile.objects.all()}
        self.assertEqual(len(after), 6)
        self.assertEqual(set(after), set(before))

    def test_overwrite_updates_in_place(self):
        from .models import BuddySearchProfile
        self._seed('--count', '6')
        self.out.truncate(0)
        self.out.seek(0)
        self._seed('--count', '6', '--neighbourhood', 'Runda', '--overwrite')
        self.assertEqual(BuddySearchProfile.objects.count(), 6)
        self.assertEqual({r.neighbourhood for r in self._rows()}, {'Runda'})
        self.assertEqual(self.out.getvalue().count('updated:'), 6)

    def test_explicit_intent_restricts_the_pool(self):
        self._seed('--count', '6', '--intent', 'walk', '--intent', 'run')
        for row in self._rows():
            self.assertIn(row.intents[0], ('walk', 'run'))

    def test_staff_and_private_profiles_are_never_seeded(self):
        staff = User.objects.create_user(email='boss@example.com', password='TestPass123!', is_staff=True)
        Profile.objects.create(user=staff, username='boss', display_name='Boss')
        hidden_user = User.objects.create_user(email='hidden@example.com', password='TestPass123!')
        hidden = Profile.objects.create(user=hidden_user, username='hidden', display_name='Hidden')
        hidden.privacy_level = 'private'
        hidden.save()

        self._seed('--count', '30')
        usernames = {r.profile.username for r in self._rows()}
        self.assertNotIn('boss', usernames)
        self.assertNotIn('hidden', usernames)


@override_settings(DEBUG=True)
class SeedBuddySearchEmailPathTests(TestCase):
    """--emails keeps its original flat-pool behaviour and username derivation."""

    def setUp(self):
        from io import StringIO
        self.out = StringIO()

    def _seed(self, *args):
        from django.core.management import call_command
        call_command('seed_buddy_search', *args, stdout=self.out)

    def _search(self, email):
        from .models import BuddySearchProfile
        return BuddySearchProfile.objects.get(profile__user__email=email)

    def test_new_account_gets_the_original_flat_defaults(self):
        self._seed('--emails', 'fresh@example.com')
        row = self._search('fresh@example.com')
        self.assertEqual(row.profile.username, 'fresh')
        self.assertEqual(row.intents, ['walk'])
        self.assertEqual(row.modes, ['in_person'])
        self.assertEqual(row.bio, 'Easy morning walks before work.')
        self.assertEqual(row.goals, ['consistency'])
        self.assertEqual(row.age_band, '18-24')
        self.assertEqual(row.neighbourhood, 'Nairobi')
        self.assertEqual(row.pace, '')

    def test_email_path_ignores_the_generic_rich_pools(self):
        self._seed('--emails', 'flat2@example.com', '--neighbourhood', 'Karen')
        row = self._search('flat2@example.com')
        self.assertEqual(row.neighbourhood, 'Nairobi')
        self.assertEqual(row.pace, '')

    def test_profile_suffix_tags_created_usernames(self):
        self._seed('--emails', 'a1@example.com')
        self._seed('--emails', 'a1@example.com', '--profile-suffix', 'b2')
        self.assertEqual(self._search('a1@example.com').profile.username, 'a1')

        self._seed('--emails', 'a2@example.com', '--profile-suffix', 'b2')
        self.assertEqual(self._search('a2@example.com').profile.username, 'a2b2')

    def test_username_suffix_is_sanitized_and_length_capped(self):
        self._seed('--emails', 'a3@example.com', '--profile-suffix', 'B 2!')
        username = self._search('a3@example.com').profile.username
        self.assertEqual(username, 'a3b2')
        self.assertLessEqual(len(username), 30)

    def test_other_intent_still_gets_the_original_custom_intent(self):
        self._seed('--emails', 'a4@example.com', '--intent', 'other')
        self.assertEqual(self._search('a4@example.com').custom_intent, 'Open to sunrise walks + coffee.')

    def test_email_path_dry_run_writes_nothing(self):
        from .models import BuddySearchProfile
        self._seed('--emails', 'a5@example.com', '--dry-run')
        self.assertEqual(BuddySearchProfile.objects.count(), 0)
        self.assertIn('DRY-RUN', self.out.getvalue())
