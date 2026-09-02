"""Bud Press creation studio tests: PostMedia, sounds, upload signing,
comments_disabled, structured media create path and video feed pagination."""
import importlib
import json
from unittest.mock import patch
from urllib.parse import parse_qs, urlparse

from django.apps import apps as real_apps
from django.core.management import call_command
from django.test import TestCase, override_settings

import cloudinary.utils
from rest_framework import status
from rest_framework.test import APIClient
from rest_framework_simplejwt.tokens import RefreshToken

from apps.accounts.models import User
from apps.feed.models import Post, PostMedia, Sound
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


@override_settings(CELERY_TASK_ALWAYS_EAGER=False)
class UploadSignTests(TestCase):
    def setUp(self):
        self.user = _make_user('uploader')
        self.client = _client_for(self.user)
        self.url = '/api/v1/uploads/sign/'

    def test_unconfigured_returns_503(self):
        res = self.client.post(self.url, {'resource_type': 'image', 'filename': 'a.jpg'}, format='json')
        self.assertEqual(res.status_code, status.HTTP_503_SERVICE_UNAVAILABLE)
        self.assertEqual(res.data['message'], 'Direct upload unavailable; use legacy media upload')

    @override_settings(
        CLOUDINARY_CLOUD_NAME='demo-cloud',
        CLOUDINARY_API_KEY='key123',
        CLOUDINARY_API_SECRET='secret123',
    )
    def test_configured_signature_is_deterministic(self):
        res = self.client.post(self.url, {'resource_type': 'video', 'filename': 'clip.mp4'}, format='json')
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = res.data['data']
        self.assertEqual(data['cloud_name'], 'demo-cloud')
        self.assertEqual(data['api_key'], 'key123')
        self.assertEqual(data['resource_type'], 'video')
        self.assertEqual(data['eager'], 'vc_h264:q_auto:so_auto,w_1080,c_limit')
        self.assertEqual(data['upload_url'], 'https://api.cloudinary.com/v1_1/demo-cloud/video/upload')
        self.assertRegex(data['folder'], r'^buddyup/posts/uploader/\d{6}$')
        expected = cloudinary.utils.api_sign_request(
            {'folder': data['folder'], 'timestamp': data['timestamp'], 'eager': data['eager']},
            'secret123',
        )
        self.assertEqual(data['signature'], expected)

    @override_settings(
        CLOUDINARY_CLOUD_NAME='demo-cloud',
        CLOUDINARY_API_KEY='key123',
        CLOUDINARY_API_SECRET='secret123',
    )
    def test_image_eager_transform(self):
        res = self.client.post(self.url, {'resource_type': 'image', 'filename': 'a.JPG'}, format='json')
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.data['data']['eager'], 'f_auto,q_auto:good,w_1440,c_limit')

    def test_invalid_resource_type_422(self):
        res = self.client.post(self.url, {'resource_type': 'audio', 'filename': 'a.mp3'}, format='json')
        self.assertEqual(res.status_code, status.HTTP_422_UNPROCESSABLE_ENTITY)

    @override_settings(
        CLOUDINARY_CLOUD_NAME='demo-cloud',
        CLOUDINARY_API_KEY='key123',
        CLOUDINARY_API_SECRET='secret123',
    )
    def test_disallowed_extension_422(self):
        res = self.client.post(self.url, {'resource_type': 'image', 'filename': 'evil.exe'}, format='json')
        self.assertEqual(res.status_code, status.HTTP_422_UNPROCESSABLE_ENTITY)
        res = self.client.post(self.url, {'resource_type': 'video', 'filename': 'clip.gif'}, format='json')
        self.assertEqual(res.status_code, status.HTTP_422_UNPROCESSABLE_ENTITY)

    def test_requires_auth(self):
        res = APIClient().post(self.url, {'resource_type': 'image', 'filename': 'a.jpg'}, format='json')
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)


@override_settings(CELERY_TASK_ALWAYS_EAGER=False)
class CreateStructuredMediaTests(TestCase):
    def setUp(self):
        self.user = _make_user('creator')
        self.client = _client_for(self.user)
        self.url = '/api/v1/feed/create/'

    def _create(self, payload, format='json'):
        return self.client.post(self.url, payload, format=format)

    def test_media_list_creates_postmedia_rows_in_order(self):
        media = [
            {'url': 'https://res.cloudinary.com/demo/image/upload/cover.jpg', 'alt_text': 'Cover', 'width': 800, 'height': 600},
            {'url': 'https://res.cloudinary.com/demo/video/upload/clip.mp4', 'duration_ms': 32000},
        ]
        res = self._create({'post_type': 'photo', 'body': 'Structured', 'media': media})
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        post = Post.objects.get(id=res.data['data']['id'])
        rows = list(post.media.all())
        self.assertEqual([r.url for r in rows], [m['url'] for m in media])
        self.assertEqual([r.media_type for r in rows], ['image', 'video'])
        self.assertEqual(rows[0].alt_text, 'Cover')
        self.assertEqual(rows[0].width, 800)
        self.assertEqual(rows[1].duration_ms, 32000)
        # Legacy mirror stays in sync for feed queries.
        self.assertEqual(post.media_urls, [m['url'] for m in media])
        # Serializer exposes media + comments_disabled.
        self.assertEqual([m['url'] for m in res.data['data']['media']], [m['url'] for m in media])
        self.assertIn('comments_disabled', res.data['data'])

    def test_media_json_string_via_multipart(self):
        media = [{'url': 'https://res.cloudinary.com/demo/image/upload/a.png'}]
        res = self._create(
            {'post_type': 'photo', 'body': 'Multipart', 'media': json.dumps(media)},
            format='multipart',
        )
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        post = Post.objects.get(id=res.data['data']['id'])
        self.assertEqual(post.media.count(), 1)
        self.assertEqual(post.media.first().media_type, 'image')

    def test_sound_usage_incremented_and_volume_stored(self):
        sound = Sound.objects.create(
            name='Beat', audio_url='https://res.cloudinary.com/demo/video/upload/beat.mp3', is_active=True,
        )
        media = [{'url': 'https://res.cloudinary.com/demo/video/upload/clip.mp4', 'sound_id': str(sound.id), 'sound_volume': 42}]
        res = self._create({'post_type': 'short_video', 'body': 'With sound', 'media': media})
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        row = PostMedia.objects.get(post_id=res.data['data']['id'])
        self.assertEqual(row.sound_id, sound.id)
        self.assertEqual(row.sound_volume, 42)
        sound.refresh_from_db()
        self.assertEqual(sound.usage_count, 1)

    def test_inactive_or_unknown_sound_rejected(self):
        sound = Sound.objects.create(name='Ghost', audio_url='', is_active=False)
        res = self._create({'post_type': 'short_video', 'media': [
            {'url': 'https://res.cloudinary.com/demo/video/upload/clip.mp4', 'sound_id': str(sound.id)},
        ]})
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

        res = self._create({'post_type': 'short_video', 'media': [
            {'url': 'https://res.cloudinary.com/demo/video/upload/clip.mp4', 'sound_id': '00000000-0000-0000-0000-000000000000'},
        ]})
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(sound.usage_count, 0)

    def test_invalid_media_rejected(self):
        # disallowed extension
        res = self._create({'post_type': 'photo', 'media': [{'url': 'https://example.com/a.exe'}]})
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        # missing url
        res = self._create({'post_type': 'photo', 'media': [{'alt_text': 'no url'}]})
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        # bad volume
        res = self._create({'post_type': 'photo', 'media': [
            {'url': 'https://res.cloudinary.com/demo/image/upload/a.png', 'sound_volume': 150},
        ]})
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_more_than_twelve_items_rejected(self):
        media = [{'url': f'https://res.cloudinary.com/demo/image/upload/{i}.png'} for i in range(13)]
        res = self._create({'post_type': 'photo', 'media': media})
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_legacy_media_urls_still_works_and_creates_postmedia(self):
        res = self._create({
            'post_type': 'photo',
            'body': 'Legacy',
            'media_urls': ['https://res.cloudinary.com/demo/image/upload/legacy.mp4', 'https://res.cloudinary.com/demo/image/upload/legacy.jpg'],
        })
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        post = Post.objects.get(id=res.data['data']['id'])
        rows = list(post.media.all())
        self.assertEqual([r.url for r in rows], post.media_urls)
        self.assertEqual([r.media_type for r in rows], ['video', 'image'])

    def test_media_wins_over_media_urls(self):
        res = self._create({
            'post_type': 'photo',
            'body': 'Dedupe',
            'media': [{'url': 'https://res.cloudinary.com/demo/image/upload/winner.png'}],
            'media_urls': ['https://res.cloudinary.com/demo/image/upload/loser.png'],
        })
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        post = Post.objects.get(id=res.data['data']['id'])
        self.assertEqual([r.url for r in post.media.all()], ['https://res.cloudinary.com/demo/image/upload/winner.png'])
        self.assertEqual(post.media_urls, ['https://res.cloudinary.com/demo/image/upload/winner.png'])

    @patch('apps.ai.tasks.transcribe_post_media.delay')
    def test_video_media_triggers_transcription(self, mock_delay):
        media = [
            {'url': 'https://res.cloudinary.com/demo/image/upload/talk.mp4'},
            {'url': 'https://res.cloudinary.com/demo/image/upload/pic.png'},
        ]
        res = self._create({'post_type': 'short_video', 'body': 'Captions', 'media': media})
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        post = Post.objects.get(id=res.data['data']['id'])
        video_rows = [r for r in post.media.all() if r.media_type == 'video']
        self.assertEqual(len(video_rows), 1)
        mock_delay.assert_called_once_with(str(video_rows[0].id))


@override_settings(CELERY_TASK_ALWAYS_EAGER=False)
class CommentsDisabledTests(TestCase):
    def setUp(self):
        self.user = _make_user('poster')
        self.other = _make_user('commenter')
        self.post = Post.objects.create(
            author=self.user.profile, post_type='text', body='No comments',
            comments_disabled=True,
        )
        self.open_post = Post.objects.create(
            author=self.user.profile, post_type='text', body='Talk away',
        )

    def test_disabled_post_returns_403(self):
        res = _client_for(self.other).post(
            f'/api/v1/feed/{self.post.id}/comments/', {'body': 'Hey!'}, format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)
        self.assertEqual(res.data['message'], 'Comments are turned off for this post.')

    def test_open_post_accepts_comments(self):
        res = _client_for(self.other).post(
            f'/api/v1/feed/{self.open_post.id}/comments/', {'body': 'Hey!'}, format='json',
        )
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_flag_exposed_by_serializer(self):
        res = _client_for(self.other).get(f'/api/v1/feed/{self.post.id}/')
        self.assertEqual(res.status_code, 200)
        self.assertTrue(res.data['data']['comments_disabled'])


@override_settings(CELERY_TASK_ALWAYS_EAGER=False)
class SoundsApiTests(TestCase):
    def setUp(self):
        self.user = _make_user('listener')
        self.client = _client_for(self.user)
        self.list_url = '/api/v1/sounds/'
        Sound.objects.create(name='Alpha Beat', audio_url='https://res.cloudinary.com/demo/image/upload/a.mp3', usage_count=5)
        Sound.objects.create(name='Beta Beat', audio_url='https://res.cloudinary.com/demo/image/upload/b.mp3', usage_count=99)
        Sound.objects.create(name='Hidden Beat', audio_url='', is_active=False)

    def test_list_returns_active_results_envelope(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, 200)
        results = res.data['data']['results']
        self.assertEqual(len(results), 2)
        names = {s['name'] for s in results}
        self.assertNotIn('Hidden Beat', names)

    def test_list_search_and_trending_ordering(self):
        res = self.client.get(self.list_url, {'q': 'beta'})
        self.assertEqual([s['name'] for s in res.data['data']['results']], ['Beta Beat'])

        res = self.client.get(self.list_url, {'ordering': 'trending'})
        self.assertEqual(
            [s['name'] for s in res.data['data']['results']],
            ['Beta Beat', 'Alpha Beat'],
        )

    def test_use_increments_usage_count(self):
        sound = Sound.objects.get(name='Alpha Beat')
        url = f'/api/v1/sounds/{sound.id}/use/'
        res = self.client.post(url)
        self.assertEqual(res.status_code, 200)
        self.assertEqual(res.data['data']['usage_count'], 6)
        self.client.post(url)
        sound.refresh_from_db()
        self.assertEqual(sound.usage_count, 7)

    def test_create_original_sound(self):
        res = self.client.post(self.list_url, {
            'name': 'My Voiceover',
            'audio_url': 'https://res.cloudinary.com/demo/image/upload/voice.mp3',
            'duration_ms': 15000,
        }, format='json')
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        sound = Sound.objects.get(name='My Voiceover')
        self.assertEqual(sound.source, 'original')
        self.assertTrue(sound.is_active)
        self.assertEqual(sound.duration_ms, 15000)


class SeedSoundsTests(TestCase):
    def test_seed_sounds_idempotent_and_pending_upload_inactive(self):
        call_command('seed_sounds')
        first_count = Sound.objects.count()
        self.assertEqual(first_count, 15)
        self.assertTrue(all(s.source == 'curated' for s in Sound.objects.all()))
        self.assertTrue(all(s.license == 'CC0' for s in Sound.objects.all()))
        # No audio uploaded yet — everything is marked inactive/pending.
        self.assertTrue(all(not s.is_active for s in Sound.objects.all()))

        call_command('seed_sounds')
        self.assertEqual(Sound.objects.count(), first_count)


@override_settings(CELERY_TASK_ALWAYS_EAGER=False)
class BudPressVideosPaginationTests(TestCase):
    def setUp(self):
        self.user = _make_user('viewer')
        self.client = _client_for(self.user)
        for i in range(25):
            Post.objects.create(
                author=self.user.profile,
                post_type='short_video',
                body=f'clip {i}',
                media_urls=[f'https://res.cloudinary.com/demo/image/upload/clip{i}.mp4'],
            )

    def test_cursor_pagination_pages_through_videos(self):
        res = self.client.get('/api/v1/feed/', {'tab': 'videos'})
        self.assertEqual(res.status_code, 200)
        page_one = res.data['data']
        self.assertEqual(len(page_one), 20)
        next_link = res.data['pagination']['next']
        self.assertTrue(next_link)

        cursor = parse_qs(urlparse(next_link).query)['cursor'][0]
        res_two = self.client.get('/api/v1/feed/', {'tab': 'videos', 'cursor': cursor})
        self.assertEqual(res_two.status_code, 200)
        page_two = res_two.data['data']
        self.assertEqual(len(page_two), 5)
        self.assertIsNone(res_two.data['pagination']['next'])
        ids_one = {p['id'] for p in page_one}
        ids_two = {p['id'] for p in page_two}
        self.assertFalse(ids_one & ids_two)
        self.assertEqual(len(ids_one | ids_two), 25)

    def test_invalid_cursor_rejected(self):
        res = self.client.get('/api/v1/feed/', {'tab': 'videos', 'cursor': 'bogus'})
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


class PostMediaBackfillTests(TestCase):
    """The 0015 data migration converts legacy media_urls into PostMedia rows."""

    def test_backfill_creates_rows_preserving_order_and_type(self):
        migration = importlib.import_module(
            'apps.feed.migrations.0015_backfill_postmedia_from_media_urls')
        backfill_post_media = migration.backfill_post_media

        user = _make_user('backfiller')
        post = Post.objects.create(
            author=user.profile,
            post_type='photo',
            media_urls=[
                'https://res.cloudinary.com/demo/image/upload/a.mp4?sig=1',
                'https://res.cloudinary.com/demo/image/upload/b.jpg',
                'https://res.cloudinary.com/demo/image/upload/c.mp3',
            ],
        )
        self.assertEqual(post.media.count(), 0)

        backfill_post_media(real_apps, None)

        rows = list(post.media.all())
        self.assertEqual(
            [r.url for r in rows],
            ['https://res.cloudinary.com/demo/image/upload/a.mp4?sig=1', 'https://res.cloudinary.com/demo/image/upload/b.jpg',
             'https://res.cloudinary.com/demo/image/upload/c.mp3'],
        )
        self.assertEqual([r.media_type for r in rows], ['video', 'image', 'audio'])
        self.assertEqual([r.order for r in rows], [0, 1, 2])

        # Idempotent: a second pass must not duplicate rows.
        backfill_post_media(real_apps, None)
        self.assertEqual(post.media.count(), 3)
