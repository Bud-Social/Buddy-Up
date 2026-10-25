"""Bud Press studio captions persistence: POST/GET /feed/studio/captions/<item_id>/."""
from django.test import TestCase
from rest_framework import status
from rest_framework.test import APIClient
from rest_framework_simplejwt.tokens import RefreshToken

from apps.accounts.models import User
from apps.feed.models import StudioCaption
from apps.profiles.models import Profile


def _client_for(user):
    client = APIClient()
    refresh = RefreshToken.for_user(user)
    client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')
    return client


def _make_user(username):
    user = User.objects.create_user(
        email=f'{username}@example.com', password='TestPass123!',
        dob_hash='x' * 64, is_adult=True,
    )
    Profile.objects.create(user=user, username=username, display_name=username.title())
    return user


class StudioCaptionsTests(TestCase):
    def setUp(self):
        self.user = _make_user('captioner')
        self.client = _client_for(self.user)
        self.item_id = 'clip-1111-2222-3333'
        self.url = f'/api/v1/feed/studio/captions/{self.item_id}/'

    def test_get_returns_empty_before_save(self):
        res = self.client.get(self.url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.data['data']['item_id'], self.item_id)
        self.assertEqual(res.data['data']['captions'], [])

    def test_post_saves_and_get_returns_captions(self):
        captions = [
            {'start_ms': 0, 'end_ms': 2000, 'text': 'hello'},
            {'start_ms': 2000, 'end_ms': 4000, 'text': 'world'},
        ]
        res = self.client.post(self.url, {'captions': captions}, format='json')
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.data['data']['item_id'], self.item_id)
        self.assertEqual(res.data['data']['captions'], captions)

        get_res = self.client.get(self.url)
        self.assertEqual(get_res.data['data']['captions'], captions)
        self.assertEqual(
            StudioCaption.objects.filter(user=self.user.profile, item_id=self.item_id).count(),
            1,
        )

    def test_post_updates_existing_captions_for_same_item(self):
        self.client.post(
            self.url,
            {'captions': [{'start_ms': 0, 'end_ms': 1000, 'text': 'one'}]},
            format='json',
        )
        res = self.client.post(
            self.url,
            {'captions': [{'start_ms': 0, 'end_ms': 2000, 'text': 'two'}]},
            format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(
            res.data['data']['captions'],
            [{'start_ms': 0, 'end_ms': 2000, 'text': 'two'}],
        )
        self.assertEqual(
            StudioCaption.objects.filter(user=self.user.profile, item_id=self.item_id).count(),
            1,
        )

    def test_post_rejects_invalid_payload(self):
        res = self.client.post(self.url, {'captions': 'not-a-list'}, format='json')
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        # Backwards timing and empty text are dropped rather than rejecting
        # the whole request — consistent with media[].captions validation.
        res = self.client.post(
            self.url,
            {'captions': [{'start_ms': 1000, 'end_ms': 500, 'text': 'backwards'}]},
            format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.data['data']['captions'], [])
        res = self.client.post(
            self.url, {'captions': [{'start_ms': 0, 'end_ms': 1000, 'text': ''}]},
            format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.data['data']['captions'], [])

    def test_requires_authentication(self):
        client = APIClient()
        res = client.get(self.url)
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)
        res = client.post(self.url, {'captions': []}, format='json')
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_users_see_only_their_own_captions(self):
        other = _make_user('other')
        other_client = _client_for(other)
        self.client.post(
            self.url,
            {'captions': [{'start_ms': 0, 'end_ms': 1000, 'text': 'mine'}]},
            format='json',
        )
        res = other_client.get(self.url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.data['data']['captions'], [])
