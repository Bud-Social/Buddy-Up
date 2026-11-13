"""Tests for buddy meetups and their ratings.

A meetup is with one other person. Once it has happened, each side rates
it on its own, and the rating only reaches the other person after a few
days.
"""

from datetime import timedelta

from django.test import TestCase
from django.utils import timezone
from rest_framework.test import APIClient
from rest_framework import status

from apps.accounts.models import User
from apps.profiles.models import BuddyMeetup, BuddyMeetupRating, Profile


def _make_user(username, email):
    user = User.objects.create_user(email=email, password='TestPass123!')
    profile = Profile.objects.create(
        user=user, username=username, display_name=username.title(),
    )
    return user, profile


class MeetupTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user_a, self.profile_a = _make_user('meeta', 'meeta@example.com')
        self.user_b, self.profile_b = _make_user('meetb', 'meetb@example.com')
        self.client.force_authenticate(self.user_a)

    def _create_meetup(self, **kwargs):
        meetup = BuddyMeetup.objects.create(
            created_by=self.profile_a, **kwargs,
        )
        meetup.participants.set([self.profile_a, self.profile_b])
        return meetup

    def test_planning_a_meetup(self):
        resp = self.client.post('/api/v1/profiles/buddies/meetups/', {
            'username': 'meetb',
            'place': 'Karen',
            'note': 'Saturday morning run',
        }, format='json')
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED)
        self.assertEqual(resp.data['data']['state'], 'planned')
        self.assertEqual(resp.data['data']['partner_username'], 'meetb')
        self.assertEqual(resp.data['data']['place'], 'Karen')

    def test_planning_a_meetup_with_yourself_is_refused(self):
        resp = self.client.post('/api/v1/profiles/buddies/meetups/', {
            'username': 'meeta',
        }, format='json')
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)

    def test_meetups_are_listed_for_their_participants(self):
        self._create_meetup()
        resp = self.client.get('/api/v1/profiles/buddies/meetups/')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertEqual(len(resp.data['data']), 1)

        # Somebody else cannot see it.
        other = APIClient()
        other.force_authenticate(self.user_b)
        mine = other.get('/api/v1/profiles/buddies/meetups/')
        self.assertEqual(len(mine.data['data']), 1)

        stranger_user, _ = _make_user('stranger', 'stranger@example.com')
        stranger = APIClient()
        stranger.force_authenticate(stranger_user)
        theirs = stranger.get('/api/v1/profiles/buddies/meetups/')
        self.assertEqual(len(theirs.data['data']), 0)

    def test_marking_a_meetup_as_met(self):
        meetup = self._create_meetup()
        resp = self.client.post(
            f'/api/v1/profiles/buddies/meetups/{meetup.id}/status/',
            {'action': 'met'}, format='json',
        )
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertEqual(resp.data['data']['state'], 'met')

    def test_a_meetup_cannot_be_rated_before_it_happened(self):
        meetup = self._create_meetup()
        resp = self.client.post(
            f'/api/v1/profiles/buddies/meetups/{meetup.id}/rate/',
            {'score': 5}, format='json',
        )
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)

    def test_each_side_rates_independently(self):
        meetup = self._create_meetup(state='met')
        resp = self.client.post(
            f'/api/v1/profiles/buddies/meetups/{meetup.id}/rate/',
            {'score': 5, 'note': 'Great run'}, format='json',
        )
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED)
        self.assertEqual(resp.data['data']['my_rating']['score'], 5)
        self.assertEqual(resp.data['data']['average_score'], 5)
        # The other side has not rated yet, so there is one rating.
        self.assertEqual(resp.data['data']['rating_count'], 1)

        other = APIClient()
        other.force_authenticate(self.user_b)
        resp = other.post(
            f'/api/v1/profiles/buddies/meetups/{meetup.id}/rate/',
            {'score': 4, 'note': 'Good chat'}, format='json',
        )
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED)

    def test_rating_twice_is_refused(self):
        meetup = self._create_meetup(state='met')
        self.client.post(
            f'/api/v1/profiles/buddies/meetups/{meetup.id}/rate/',
            {'score': 5}, format='json',
        )
        again = self.client.post(
            f'/api/v1/profiles/buddies/meetups/{meetup.id}/rate/',
            {'score': 4}, format='json',
        )
        self.assertEqual(again.status_code, status.HTTP_409_CONFLICT)

    def test_a_rating_reaches_the_other_person_after_three_days(self):
        meetup = self._create_meetup(state='met')
        self.client.post(
            f'/api/v1/profiles/buddies/meetups/{meetup.id}/rate/',
            {'score': 5, 'note': 'Great run'}, format='json',
        )

        other = APIClient()
        other.force_authenticate(self.user_b)
        resp = other.get(f'/api/v1/profiles/buddies/meetups/{meetup.id}/')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)

        # The rating is there, but not yet readable — only that one is
        # pending.
        ratings = resp.data['data']['ratings']
        self.assertEqual(len(ratings), 1)
        self.assertTrue(ratings[0].get('pending'))
        self.assertNotIn('score', ratings[0])
        self.assertNotIn('note', ratings[0])
        self.assertIsNone(resp.data['data']['average_score'])

        # Three days later it opens.
        BuddyMeetupRating.objects.filter(meetup=meetup).update(
            visible_at=timezone.now() - timedelta(minutes=1),
        )
        resp = other.get(f'/api/v1/profiles/buddies/meetups/{meetup.id}/')
        ratings = resp.data['data']['ratings']
        self.assertEqual(len(ratings), 1)
        self.assertFalse(ratings[0].get('pending'))
        self.assertEqual(ratings[0]['score'], 5)
        self.assertEqual(ratings[0]['note'], 'Great run')
        self.assertEqual(resp.data['data']['average_score'], 5)

    def test_the_rater_always_sees_their_own_rating(self):
        meetup = self._create_meetup(state='met')
        self.client.post(
            f'/api/v1/profiles/buddies/meetups/{meetup.id}/rate/',
            {'score': 3, 'note': 'It was fine'}, format='json',
        )
        resp = self.client.get(f'/api/v1/profiles/buddies/meetups/{meetup.id}/')
        self.assertEqual(resp.data['data']['my_rating']['score'], 3)

    def test_the_average_only_counts_revealed_ratings(self):
        meetup = self._create_meetup(state='met')
        self.client.post(
            f'/api/v1/profiles/buddies/meetups/{meetup.id}/rate/',
            {'score': 5}, format='json',
        )
        other = APIClient()
        other.force_authenticate(self.user_b)
        other.post(
            f'/api/v1/profiles/buddies/meetups/{meetup.id}/rate/',
            {'score': 1}, format='json',
        )

        # Each side can see their own rating, so each average counts one
        # rating — not the other's, which is still waiting.
        resp = self.client.get(f'/api/v1/profiles/buddies/meetups/{meetup.id}/')
        self.assertEqual(resp.data['data']['average_score'], 5.0)
        self.assertEqual(resp.data['data']['rating_count'], 1)

        resp = other.get(f'/api/v1/profiles/buddies/meetups/{meetup.id}/')
        self.assertEqual(resp.data['data']['average_score'], 1.0)
        self.assertEqual(resp.data['data']['rating_count'], 1)

        # Once both are revealed the average is of both.
        BuddyMeetupRating.objects.filter(meetup=meetup).update(
            visible_at=timezone.now() - timedelta(minutes=1),
        )
        resp = self.client.get(f'/api/v1/profiles/buddies/meetups/{meetup.id}/')
        self.assertEqual(resp.data['data']['average_score'], 3.0)
        self.assertEqual(resp.data['data']['rating_count'], 2)

    def test_a_score_is_kept_to_one_and_five(self):
        meetup = self._create_meetup(state='met')
        resp = self.client.post(
            f'/api/v1/profiles/buddies/meetups/{meetup.id}/rate/',
            {'score': 9}, format='json',
        )
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)

    def test_a_stranger_cannot_rate_a_meetup(self):
        meetup = self._create_meetup(state='met')
        stranger_user, _ = _make_user('nosy', 'nosy@example.com')
        stranger = APIClient()
        stranger.force_authenticate(stranger_user)
        resp = stranger.post(
            f'/api/v1/profiles/buddies/meetups/{meetup.id}/rate/',
            {'score': 1}, format='json',
        )
        self.assertEqual(resp.status_code, status.HTTP_404_NOT_FOUND)


class BuddyAgeBandTests(TestCase):
    """The age band comes from the account, so nobody is asked again."""

    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(email='band@example.com', password='TestPass123!')
        self.profile = Profile.objects.create(
            user=self.user, username='band', display_name='Band',
            date_of_birth='1995-05-05',
        )
        self.client.force_authenticate(self.user)

    def test_the_band_is_derived_from_the_accounts_birthday(self):
        resp = self.client.put('/api/v1/profiles/me/search-profile/', {
            'intents': ['walk'],
            'bio': 'Early riser',
        }, format='json')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertEqual(resp.data['data']['age_band'], '30–34')
        self.assertTrue(resp.data['data']['has_birthday'])

    def test_an_account_without_a_birthday_is_asked_once(self):
        self.profile.date_of_birth = ''
        self.profile.save(update_fields=['date_of_birth'])
        resp = self.client.get('/api/v1/profiles/me/search-profile/')
        self.assertFalse(resp.data['data']['has_birthday'])

        resp = self.client.put('/api/v1/profiles/me/search-profile/', {
            'intents': ['walk'],
            'dob': '1995-05-05',
        }, format='json')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertEqual(resp.data['data']['age_band'], '30–34')

    def test_another_users_profile_does_not_say_whether_they_have_a_birthday(self):
        other_user = User.objects.create_user(email='otherband@example.com', password='TestPass123!')
        other = Profile.objects.create(
            user=other_user, username='otherband', display_name='Other',
            date_of_birth='1990-01-01',
        )
        from .models import BuddySearchProfile
        BuddySearchProfile.objects.create(profile=other, intents=['walk'])
        resp = self.client.get(f'/api/v1/profiles/{other.username}/search-profile/')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertNotIn('has_birthday', resp.data['data'])
