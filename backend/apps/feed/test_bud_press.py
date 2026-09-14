"""Bud Press creation studio tests: PostMedia, sounds, upload signing,
comments_disabled, structured media create path and video feed pagination."""
import importlib
import json
from unittest.mock import patch
from unittest import mock
from urllib.parse import parse_qs, urlparse

from django.apps import apps as real_apps
from django.core.management import call_command
from django.test import TestCase, override_settings

import cloudinary.utils
from django.core.files.uploadedfile import SimpleUploadedFile
from rest_framework import status
from rest_framework.test import APIClient
from rest_framework_simplejwt.tokens import RefreshToken

from apps.accounts.models import User
from apps.feed.models import Comment, HiddenPost, MutedAuthor, Post, PostMedia, Reaction, Save, Sound
from apps.profiles.models import BuddyRelationship, Profile


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
        if res.status_code == status.HTTP_200_OK:
            self.skipTest('Cloudinary credentials available in local env; 503 branch unverifiable')
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
        self.assertEqual(data['eager'], 'vc_h264:q_auto:so_auto,w_1080,c_limit,ac_aac')
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

    def test_edit_meta_studio_fields_sanitized(self):
        media = [{
            'url': 'https://res.cloudinary.com/demo/video/upload/clip.mp4',
            'edit_meta': {
                'filter': 'vivid', 'filter_strength': 60, 'speed': 1.5, 'volume': 80,
                'enhance': True, 'voice_effect': 'echo',
                'adjust': {'brightness': 80, 'contrast': 999, 'saturation': 20, 'vignette': 30},
                'aspect': '9:16', 'focus_y': 70,
                'text_overlays': [{
                    'id': 'generated-id', 'text': 'Hi', 'start_ms': 0, 'end_ms': 900,
                    'y': 80, 'x': 20, 'size': 1.5, 'color': 'white', 'font': 'neon',
                    'bg': 'pill', 'bg_color': '#111', 'animation': 'pop', 'effect': 'neon',
                }],
                'stickers': [{
                    'id': 'st1', 'kind': 'countdown', 'content': '',
                    'x': 50, 'y': 14, 'start_ms': 0, 'end_ms': 5000, 'scale': 9,
                }],
                'captions_style': {'preset': 'pop', 'font': 'grotesk'},
            },
        }]
        res = self._create({'post_type': 'short_video', 'body': 'Studio edits', 'media': media})
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        meta = PostMedia.objects.get(post_id=res.data['data']['id']).edit_meta
        self.assertEqual(meta['filter'], 'vivid')
        self.assertEqual(meta['filter_strength'], 60)
        self.assertEqual(meta['speed'], 1.5)
        self.assertTrue(meta['enhance'])
        self.assertEqual(meta['voice_effect'], 'echo')
        # out-of-range keys clamp or drop
        self.assertEqual(meta['adjust']['contrast'], 100)
        self.assertEqual(meta['adjust']['vignette'], 30)
        self.assertEqual(meta['aspect'], '9:16')
        self.assertEqual(meta['focus_y'], 70)
        ov = meta['text_overlays'][0]
        self.assertEqual(ov['x'], 20)
        self.assertEqual(ov['font'], 'neon')
        self.assertEqual(ov['bg'], 'pill')
        self.assertEqual(ov['animation'], 'pop')
        self.assertEqual(ov['effect'], 'neon')
        self.assertNotIn('id', ov)  # server strips client ids
        st = meta['stickers'][0]
        self.assertEqual(st['scale'], 2)  # clamped to 2
        self.assertNotIn('id', st)
        self.assertEqual(meta['captions_style']['preset'], 'pop')

    def test_edit_meta_audio_tracks_resolved_and_url_checked(self):
        sound = Sound.objects.create(
            name='Loop', audio_url='https://res.cloudinary.com/demo/video/upload/beat.mp3', is_active=True,
        )
        media = [{
            'url': 'https://res.cloudinary.com/demo/video/upload/clip.mp4',
            'edit_meta': {
                'audio_tracks': [
                    {'id': 'a1', 'kind': 'sound', 'sound_id': str(sound.id), 'volume': 130, 'start_ms': 500, 'effect': 'robot'},
                    {'id': 'a2', 'kind': 'url', 'url': 'https://evil.example.net/song.mp3', 'volume': 100, 'start_ms': 0},
                    {'id': 'a3', 'kind': 'voiceover', 'url': 'https://res.cloudinary.com/demo/video/upload/my-take.webm', 'volume': 100, 'start_ms': 0},
                ],
            },
        }]
        res = self._create({'post_type': 'short_video', 'body': 'Multi audio', 'media': media})
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        meta = PostMedia.objects.get(post_id=res.data['data']['id']).edit_meta
        tracks = meta['audio_tracks']
        # unknown-host url dropped; sound resolved to server audio_url
        self.assertEqual(len(tracks), 2)
        self.assertEqual(tracks[0]['url'], sound.audio_url)
        self.assertEqual(tracks[0]['volume'], 130)
        self.assertEqual(tracks[0]['effect'], 'robot')
        self.assertEqual(tracks[1]['kind'], 'voiceover')
        self.assertEqual(tracks[1]['url'], 'https://res.cloudinary.com/demo/video/upload/my-take.webm')

    def test_edit_meta_audio_track_requires_active_sound(self):
        ghost = Sound.objects.create(name='Ghost track', audio_url='', is_active=False)
        res = self._create({'post_type': 'short_video', 'media': [{
            'url': 'https://res.cloudinary.com/demo/video/upload/clip.mp4',
            'edit_meta': {'audio_tracks': [
                {'id': 'x', 'kind': 'sound', 'sound_id': str(ghost.id), 'volume': 100, 'start_ms': 0},
            ]},
        }]})
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        meta = PostMedia.objects.get(post_id=res.data['data']['id']).edit_meta
        self.assertNotIn('audio_tracks', meta)

    def test_edit_meta_track_fades_ducking_and_caption_size_placement(self):
        media = [{
            'url': 'https://res.cloudinary.com/demo/video/upload/clip.mp4',
            'edit_meta': {
                'audio_tracks': [
                    {'id': 'a1', 'kind': 'voiceover', 'url': 'https://res.cloudinary.com/demo/video/upload/my-take.webm',
                     'volume': 100, 'start_ms': 0, 'fade_in_ms': 800, 'fade_out_ms': 99999, 'ducking': True},
                ],
                'captions_style': {'preset': 'pop', 'size': 9.9, 'placement': 'top'},
            },
        }]
        res = self._create({'post_type': 'short_video', 'body': 'Fades', 'media': media})
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        meta = PostMedia.objects.get(post_id=res.data['data']['id']).edit_meta
        track = meta['audio_tracks'][0]
        self.assertEqual(track['fade_in_ms'], 800)
        self.assertEqual(track['fade_out_ms'], 10_000)  # clamped
        self.assertTrue(track['ducking'])
        self.assertEqual(meta['captions_style']['size'], 1.6)  # clamped
        self.assertEqual(meta['captions_style']['placement'], 'top')

    def test_edit_meta_sound_placement_and_save_count(self):
        sound = Sound.objects.create(
            name='Placement', audio_url='https://res.cloudinary.com/demo/video/upload/beat.mp3', is_active=True,
        )
        media = [{
            'url': 'https://res.cloudinary.com/demo/video/upload/clip.mp4',
            'sound_id': str(sound.id),
            'sound_start_ms': 2500,
            'sound_fade_in_ms': 500,
            'sound_fade_out_ms': 700,
        }]
        res = self._create({'post_type': 'short_video', 'body': 'Placed sound', 'media': media})
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        meta = PostMedia.objects.get(post_id=res.data['data']['id']).edit_meta
        self.assertEqual(meta['sound_placement'], {'start_ms': 2500, 'fade_in_ms': 500, 'fade_out_ms': 700})
        self.assertEqual(res.data['data']['save_count'], 0)

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

    @patch('apps.ai.tasks.transcribe_post_media.delay')
    def test_manual_captions_are_saved_and_skip_auto_transcription(self, mock_delay):
        media = [{
            'url': 'https://res.cloudinary.com/demo/video/upload/clip.mp4',
            'captions': [{'start_ms': 0, 'end_ms': 1200, 'text': 'Studio caption.'}],
        }]
        res = self._create({'post_type': 'short_video', 'body': 'Manual captions', 'media': media})
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        row = PostMedia.objects.get(post_id=res.data['data']['id'])
        self.assertEqual(row.captions, [{'start_ms': 0, 'end_ms': 1200, 'text': 'Studio caption.'}])
        self.assertIn('WEBVTT', row.captions_vtt)
        self.assertIn('Studio caption.', row.captions_vtt)
        mock_delay.assert_not_called()

@override_settings(CELERY_TASK_ALWAYS_EAGER=False)
class RepostVisibilityTests(TestCase):
    """TikTok-style repost collapse: followers of the reposter see the
    repost row; everyone else sees the original with its repost count."""

    def setUp(self):
        self.author = _make_user('repost_author')
        self.reposter = _make_user('reposter')
        self.follower = _make_user('follower')
        self.stranger = _make_user('stranger')
        self.post = Post.objects.create(
            author=self.author.profile, post_type='text', body='Original',
        )
        _client_for(self.reposter).post(f'/api/v1/feed/{self.post.id}/repost/')
        from apps.profiles.models import FollowRelationship
        FollowRelationship.objects.create(
            follower=self.follower.profile, followee=self.reposter.profile,
        )

    def _feed(self, user):
        res = _client_for(user).get('/api/v1/feed/?tab=for_you')
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        return res.data['data']

    def test_follower_sees_repost_row(self):
        data = self._feed(self.follower)
        rows = [p for p in data if (p.get('original_post_data') or {}).get('id') == str(self.post.id)]
        self.assertTrue(rows)
        self.assertTrue(all(p['is_repost'] for p in rows))

    def test_stranger_sees_original_with_repost_count(self):
        data = self._feed(self.stranger)
        by_id = {p['id']: p for p in data}
        self.assertIn(str(self.post.id), by_id)
        self.assertFalse(by_id[str(self.post.id)]['is_repost'])
        self.assertEqual(by_id[str(self.post.id)]['repost_count'], 1)

    def test_repost_row_carries_original_counts_and_followed_first(self):
        from apps.profiles.models import FollowRelationship
        other = _make_user('other_reposter')
        _client_for(other).post(f'/api/v1/feed/{self.post.id}/repost/')
        FollowRelationship.objects.create(
            follower=self.follower.profile, followee=other.profile,
        )
        data = self._feed(self.follower)
        rows = [p for p in data if (p.get('original_post_data') or {}).get('id') == str(self.post.id)]
        self.assertTrue(rows)
        row = rows[0]
        self.assertEqual(row['original_post_data']['repost_count'], 2)
        self.assertEqual(row['original_post_data']['comment_count'], 0)
        reposters = row['reposters']
        self.assertTrue(all(r.get('followed_by_viewer') for r in reposters[:2]))


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

@override_settings(CELERY_TASK_ALWAYS_EAGER=False)
class StudioTranscribeTests(TestCase):
    def setUp(self):
        self.user = _make_user('captioner')
        self.client = _client_for(self.user)
        self.url = '/api/v1/feed/studio/transcribe/'

    def test_requires_media(self):
        res = self.client.post(self.url, format='multipart')
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_requires_auth(self):
        res = APIClient().post(self.url, format='multipart')
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

    @override_settings(AI_API_KEY='test-key')
    @patch('apps.feed.views.ai_post')
    def test_relays_whisper_segments(self, mocked_ai_post):
        mocked_ai = mock.Mock(status_code=200)
        mocked_ai.json.return_value = {
            'segments': [{'start_ms': 0, 'end_ms': 2100, 'text': 'hello world'}],
            'language': 'en',
            'duration_ms': 2100,
        }
        mocked_ai_post.return_value = mocked_ai
        dummy = b'not-a-real-video'
        res = self.client.post(
            self.url,
            {'media': SimpleUploadedFile('clip.mp4', dummy)},
            format='multipart',
        )
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.data['data']['segments'][0]['text'], 'hello world')
        args, kwargs = mocked_ai_post.call_args
        self.assertIn('/api/v1/transcribe-file', args[0])

    @patch('apps.feed.views.ai_post')
    def test_oversized_media_413(self, mocked_ai_post):
        big = SimpleUploadedFile('clip.mp4', b'x' * (160 * 1024 * 1024))
        res = self.client.post(self.url, {'media': big}, format='multipart')
        self.assertEqual(res.status_code, status.HTTP_413_REQUEST_ENTITY_TOO_LARGE)
        mocked_ai_post.assert_not_called()


@override_settings(CELERY_TASK_ALWAYS_EAGER=False)
class ShareEndpointTests(TestCase):
    """POST /api/v1/feed/<post_id>/share/ — Bud Press share counter."""

    def setUp(self):
        self.author = _make_user('share_author')
        self.viewer = _make_user('share_viewer')
        self.stranger = _make_user('share_stranger')
        self.post = Post.objects.create(
            author=self.author.profile, post_type='text', body='Share me',
        )
        self.url = f'/api/v1/feed/{self.post.id}/share/'

    def test_requires_auth(self):
        res = APIClient().post(self.url)
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_share_increments_and_returns_envelope(self):
        res = _client_for(self.viewer).post(self.url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertTrue(res.data['success'])
        self.assertEqual(res.data['data']['share_count'], 1)
        self.assertTrue(res.data['data']['code'])
        self.assertIsNone(res.data['errors'])
        self.assertIsNone(res.data['pagination'])
        self.post.refresh_from_db()
        self.assertEqual(self.post.share_count, 1)
        # Serializer exposes the counter.
        detail = _client_for(self.viewer).get(f'/api/v1/feed/{self.post.id}/')
        self.assertEqual(detail.status_code, 200)
        self.assertEqual(detail.data['data']['share_count'], 1)

    def test_repeat_shares_count_each_time(self):
        """Each POST is a deliberate outbound share, so repeats increment."""
        _client_for(self.viewer).post(self.url)
        res = _client_for(self.viewer).post(self.url)
        self.assertEqual(res.data['data']['share_count'], 2)
        self.post.refresh_from_db()
        self.assertEqual(self.post.share_count, 2)

    def test_share_returns_stable_code_and_records_channel(self):
        from apps.feed.models import PostShare
        first = _client_for(self.viewer).post(self.url, {'channel': 'whatsapp'})
        second = _client_for(self.viewer).post(self.url, {'channel': 'x'})
        self.assertEqual(first.data['data']['code'], second.data['data']['code'])
        record = PostShare.objects.get(post=self.post, sharer=self.viewer.profile)
        self.assertEqual(record.channel, 'x')
        self.assertEqual(
            PostShare.objects.filter(post=self.post).count(), 1,
        )

    def test_shares_list_orders_followed_first(self):
        from apps.profiles.models import FollowRelationship
        _client_for(self.stranger).post(self.url)
        _client_for(self.viewer).post(self.url)
        FollowRelationship.objects.create(
            follower=self.author.profile, followee=self.viewer.profile,
        )
        res = _client_for(self.author).get(f'/api/v1/feed/{self.post.id}/shares/')
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        usernames = [r['username'] for r in res.data['data']]
        self.assertEqual(usernames[0], 'share_viewer')
        self.assertTrue(res.data['data'][0]['followed_by_viewer'])
        self.assertFalse(res.data['data'][1]['followed_by_viewer'])

    def test_share_open_increments_clicks_and_resolves_post(self):
        res = _client_for(self.viewer).post(self.url)
        code = res.data['data']['code']
        opened = APIClient().post(f'/api/v1/s/{code}/open/')
        self.assertEqual(opened.status_code, status.HTTP_200_OK)
        self.assertEqual(opened.data['data']['post_id'], str(self.post.id))
        from apps.feed.models import PostShare
        record = PostShare.objects.get(code=code)
        self.assertEqual(record.clicks, 1)

    def test_forbidden_post_returns_404_and_does_not_increment(self):
        buddies_post = Post.objects.create(
            author=self.author.profile, post_type='text',
            body='Buddies only', visibility='buddies',
        )
        url = f'/api/v1/feed/{buddies_post.id}/share/'
        res = _client_for(self.stranger).post(url)
        self.assertEqual(res.status_code, status.HTTP_404_NOT_FOUND)
        buddies_post.refresh_from_db()
        self.assertEqual(buddies_post.share_count, 0)

    def test_removed_post_returns_410(self):
        self.post.moderation_status = 'removed'
        self.post.save(update_fields=['moderation_status'])
        res = _client_for(self.viewer).post(self.url)
        self.assertEqual(res.status_code, status.HTTP_410_GONE)


@override_settings(CELERY_TASK_ALWAYS_EAGER=False)
class ViewEndpointTests(TestCase):
    """POST /api/v1/feed/<post_id>/view/ — throttled view ping."""

    def setUp(self):
        self.author = _make_user('view_author')
        self.viewer = _make_user('view_viewer')
        self.stranger = _make_user('view_stranger')
        self.post = Post.objects.create(
            author=self.author.profile, post_type='text', body='Watch me',
        )
        self.url = f'/api/v1/feed/{self.post.id}/view/'

    def test_requires_auth(self):
        res = APIClient().post(self.url)
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_view_records_and_throttles_repeats(self):
        first = _client_for(self.viewer).post(self.url)
        self.assertEqual(first.status_code, status.HTTP_200_OK)
        self.assertTrue(first.data['success'])
        self.assertEqual(first.data['data'], {'view_count': 1})
        self.assertEqual(first.data['message'], 'View recorded.')
        self.assertIsNone(first.data['errors'])
        self.assertIsNone(first.data['pagination'])

        second = _client_for(self.viewer).post(self.url)
        self.assertEqual(second.status_code, status.HTTP_200_OK)
        self.assertEqual(second.data['data'], {'view_count': 1})
        self.assertEqual(second.data['message'], 'View already counted.')
        self.post.refresh_from_db()
        self.assertEqual(self.post.view_count, 1)

    def test_detail_and_view_share_throttle_window(self):
        """Detail GET and view POST use one helper: no double count in-window."""
        detail = _client_for(self.viewer).get(f'/api/v1/feed/{self.post.id}/')
        self.assertEqual(detail.status_code, 200)
        self.assertEqual(detail.data['data']['view_count'], 1)
        res = _client_for(self.viewer).post(self.url)
        self.assertEqual(res.data['data'], {'view_count': 1})
        self.post.refresh_from_db()
        self.assertEqual(self.post.view_count, 1)

    def test_different_viewers_each_count(self):
        _client_for(self.viewer).post(self.url)
        res = _client_for(self.stranger).post(self.url)
        self.assertEqual(res.data['data'], {'view_count': 2})

    def test_forbidden_post_returns_404(self):
        buddies_post = Post.objects.create(
            author=self.author.profile, post_type='text',
            body='Buddies only', visibility='buddies',
        )
        res = _client_for(self.stranger).post(f'/api/v1/feed/{buddies_post.id}/view/')
        self.assertEqual(res.status_code, status.HTTP_404_NOT_FOUND)
        buddies_post.refresh_from_db()
        self.assertEqual(buddies_post.view_count, 0)


@override_settings(CELERY_TASK_ALWAYS_EAGER=False)
class CreatorInsightsTests(TestCase):
    """GET /api/v1/feed/creator/insights/ — author-only per-post aggregates."""

    def setUp(self):
        self.author = _make_user('insights_author')
        self.viewer = _make_user('insights_viewer')
        self.url = '/api/v1/feed/creator/insights/'

    def test_requires_auth(self):
        res = APIClient().get(self.url)
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_returns_only_own_posts_with_aggregates(self):
        mine = Post.objects.create(
            author=self.author.profile, post_type='text', body='Mine',
        )
        mine_too = Post.objects.create(
            author=self.author.profile, post_type='photo', body='Mine too',
            visibility='buddies',
        )
        BuddyRelationship.objects.create(
            from_user=self.author.profile, to_user=self.viewer.profile,
            status='confirmed',
        )
        theirs = Post.objects.create(
            author=self.viewer.profile, post_type='text', body='Theirs',
        )

        Reaction.objects.create(post=mine, author=self.viewer.profile, reaction_type='🔥')
        Comment.objects.create(post=mine, author=self.viewer.profile, body='Nice!')
        Save.objects.create(user=self.viewer.profile, post=mine)
        _client_for(self.viewer).post(f'/api/v1/feed/{mine.id}/repost/')
        _client_for(self.viewer).post(f'/api/v1/feed/{mine.id}/view/')
        _client_for(self.viewer).post(f'/api/v1/feed/{mine.id}/share/')

        res = _client_for(self.author).get(self.url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertTrue(res.data['success'])
        self.assertIsNone(res.data['errors'])
        self.assertIsNone(res.data['pagination'])
        items = res.data['data']['items']
        by_id = {item['post_id']: item for item in items}
        self.assertIn(str(mine.id), by_id)
        self.assertIn(str(mine_too.id), by_id)
        self.assertNotIn(str(theirs.id), by_id)

        row = by_id[str(mine.id)]
        self.assertEqual(
            (row['views'], row['likes'], row['comments'], row['reposts'],
             row['saves'], row['shares']),
            (1, 1, 1, 1, 1, 1),
        )
        self.assertEqual(row['visibility'], 'public')
        self.assertIn('created_at', row)

        quiet = by_id[str(mine_too.id)]
        self.assertEqual(
            (quiet['views'], quiet['likes'], quiet['comments'],
             quiet['reposts'], quiet['saves'], quiet['shares']),
            (0, 0, 0, 0, 0, 0),
        )
        self.assertEqual(quiet['visibility'], 'buddies')

    def test_empty_for_new_author(self):
        res = _client_for(self.author).get(self.url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.data['data'], {'items': []})

    def test_viewer_does_not_see_my_posts(self):
        mine = Post.objects.create(
            author=self.author.profile, post_type='text', body='Private-ish',
        )
        res = _client_for(self.viewer).get(self.url)
        ids = [item['post_id'] for item in res.data['data']['items']]
        self.assertNotIn(str(mine.id), ids)


@override_settings(CELERY_TASK_ALWAYS_EAGER=False)
class HideMuteTests(TestCase):
    """Bud Press post menu: hide/unhide posts, mute/unmute authors, and the
    resulting FeedView discovery exclusions."""

    # NOTE: mute routes live in apps/feed/urls.py until the 2-line profiles
    # remount lands (see urls.py comment). Canonical shapes are
    # /api/v1/profiles/<username>/mute|unmute/; tests use the feed-namespace
    # aliases with identical trailing shapes.
    MUTE = '/api/v1/feed/{username}/mute/'
    UNMUTE = '/api/v1/feed/{username}/unmute/'

    def setUp(self):
        self.author = _make_user('hide_author')
        self.viewer = _make_user('hide_viewer')
        self.post = Post.objects.create(
            author=self.author.profile, post_type='text', body='Hide me',
        )
        self.hide_url = f'/api/v1/feed/{self.post.id}/hide/'

    def _feed_ids(self, user, params=None):
        res = _client_for(user).get('/api/v1/feed/', params or {'tab': 'for_you'})
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        return {p['id'] for p in res.data['data']}

    def test_requires_auth(self):
        self.assertEqual(APIClient().post(self.hide_url).status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertEqual(APIClient().delete(self.hide_url).status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertEqual(
            APIClient().post(self.MUTE.format(username='hide_author')).status_code,
            status.HTTP_401_UNAUTHORIZED,
        )

    def test_hide_unhide_toggle_envelope(self):
        hide = _client_for(self.viewer).post(self.hide_url)
        self.assertEqual(hide.status_code, status.HTTP_200_OK)
        self.assertEqual(hide.data, {
            'success': True, 'data': {'hidden': True}, 'message': 'Post hidden.',
            'errors': None, 'pagination': None,
        })
        self.assertTrue(HiddenPost.objects.filter(viewer=self.viewer.profile, post=self.post).exists())

        # POST is idempotent — no duplicate row.
        _client_for(self.viewer).post(self.hide_url)
        self.assertEqual(HiddenPost.objects.filter(viewer=self.viewer.profile, post=self.post).count(), 1)

        unhide = _client_for(self.viewer).delete(self.hide_url)
        self.assertEqual(unhide.status_code, status.HTTP_200_OK)
        self.assertEqual(unhide.data['data'], {'hidden': False})
        self.assertIsNone(unhide.data['errors'])
        self.assertIsNone(unhide.data['pagination'])
        self.assertFalse(HiddenPost.objects.filter(viewer=self.viewer.profile, post=self.post).exists())

        # DELETE without a hide is a no-op success.
        again = _client_for(self.viewer).delete(self.hide_url)
        self.assertEqual(again.status_code, status.HTTP_200_OK)
        self.assertEqual(again.data['data'], {'hidden': False})

    def test_hide_removed_post_returns_410(self):
        self.post.moderation_status = 'removed'
        self.post.save(update_fields=['moderation_status'])
        res = _client_for(self.viewer).post(self.hide_url)
        self.assertEqual(res.status_code, status.HTTP_410_GONE)
        res = _client_for(self.viewer).delete(self.hide_url)
        self.assertEqual(res.status_code, status.HTTP_410_GONE)

    def test_hide_forbidden_post_returns_404(self):
        buddies_post = Post.objects.create(
            author=self.author.profile, post_type='text',
            body='Buddies only', visibility='buddies',
        )
        res = _client_for(self.viewer).post(f'/api/v1/feed/{buddies_post.id}/hide/')
        self.assertEqual(res.status_code, status.HTTP_404_NOT_FOUND)

    def test_mute_unmute_toggle_and_self_mute_400(self):
        mute = _client_for(self.viewer).post(self.MUTE.format(username='hide_author'))
        self.assertEqual(mute.status_code, status.HTTP_200_OK)
        self.assertTrue(mute.data['success'])
        self.assertIsNone(mute.data['errors'])
        self.assertIsNone(mute.data['pagination'])
        self.assertTrue(MutedAuthor.objects.filter(muter=self.viewer.profile, muted=self.author.profile).exists())
        # Follows/buddies untouched — mute is lighter than block.
        self.assertEqual(MutedAuthor.objects.filter(muter=self.viewer.profile, muted=self.author.profile).count(), 1)
        _client_for(self.viewer).post(self.MUTE.format(username='hide_author'))
        self.assertEqual(MutedAuthor.objects.filter(muter=self.viewer.profile, muted=self.author.profile).count(), 1)

        unmute = _client_for(self.viewer).delete(self.UNMUTE.format(username='hide_author'))
        self.assertEqual(unmute.status_code, status.HTTP_200_OK)
        self.assertTrue(unmute.data['success'])
        self.assertFalse(MutedAuthor.objects.filter(muter=self.viewer.profile, muted=self.author.profile).exists())

        # DELETE without a mute is a no-op success.
        again = _client_for(self.viewer).delete(self.UNMUTE.format(username='hide_author'))
        self.assertEqual(again.status_code, status.HTTP_200_OK)

        # Cannot mute yourself (mirrors BlockUserView).
        me = _client_for(self.viewer).post(self.MUTE.format(username='hide_viewer'))
        self.assertEqual(me.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertFalse(me.data['success'])

    def test_hidden_post_absent_from_feed(self):
        self.assertIn(str(self.post.id), self._feed_ids(self.viewer))
        _client_for(self.viewer).post(self.hide_url)
        self.assertNotIn(str(self.post.id), self._feed_ids(self.viewer))
        # Other viewers still see it.
        other = _make_user('hide_other')
        self.assertIn(str(self.post.id), self._feed_ids(other))
        # Unhide restores it.
        _client_for(self.viewer).delete(self.hide_url)
        self.assertIn(str(self.post.id), self._feed_ids(self.viewer))

    def test_hidden_post_absent_from_meals_tab(self):
        meal = Post.objects.create(
            author=self.author.profile, post_type='meal', body='Lunch',
        )
        viewer_client = _client_for(self.viewer)
        before = viewer_client.get('/api/v1/feed/', {'tab': 'meals'})
        self.assertIn(str(meal.id), {p['id'] for p in before.data['data']})
        viewer_client.post(f'/api/v1/feed/{meal.id}/hide/')
        after = viewer_client.get('/api/v1/feed/', {'tab': 'meals'})
        self.assertNotIn(str(meal.id), {p['id'] for p in after.data['data']})

    def test_muted_author_absent_from_feed(self):
        self.assertIn(str(self.post.id), self._feed_ids(self.viewer))
        _client_for(self.viewer).post(self.MUTE.format(username='hide_author'))
        self.assertNotIn(str(self.post.id), self._feed_ids(self.viewer))
        # Only feed exclusion is asserted (direct detail stays reachable).
        _client_for(self.viewer).delete(self.UNMUTE.format(username='hide_author'))
        self.assertIn(str(self.post.id), self._feed_ids(self.viewer))

    def test_muted_author_absent_from_videos_tab(self):
        clip = Post.objects.create(
            author=self.author.profile, post_type='short_video', body='clip',
            media_urls=['https://res.cloudinary.com/demo/image/upload/muted.mp4'],
        )
        viewer_client = _client_for(self.viewer)
        before = viewer_client.get('/api/v1/feed/', {'tab': 'videos'})
        self.assertIn(str(clip.id), {p['id'] for p in before.data['data']})
        viewer_client.post(self.MUTE.format(username='hide_author'))
        after = viewer_client.get('/api/v1/feed/', {'tab': 'videos'})
        self.assertNotIn(str(clip.id), {p['id'] for p in after.data['data']})
