"""Tests for the video card endpoints (feed + community).

The endpoints hand the browser's rendered card chrome to ffmpeg, which
composites the post's whole clip — sound intact — into it. The render runs
off the request thread, so the tests drive the job lifecycle directly.
"""
from unittest import mock

from django.core.files.uploadedfile import SimpleUploadedFile
from django.test import TestCase
from rest_framework.test import APIClient

from apps.accounts.models import User
from apps.feed.models import Post, PostMedia
from apps.messaging.models import CommunityPost, Conversation
from apps.profiles.models import Profile
from common.video_card import new_job_id


def _png_bytes():
    import io

    from PIL import Image

    buf = io.BytesIO()
    Image.new('RGBA', (1080, 1350), (11, 15, 13, 255)).save(buf, format='PNG')
    return buf.getvalue()


def _png_file(name='base.png'):
    return SimpleUploadedFile(name, _png_bytes(), content_type='image/png')


def _render_file(data: bytes):
    """A file standing in for a finished render."""
    import tempfile
    from pathlib import Path

    path = Path(tempfile.mkdtemp()) / 'card.mp4'
    path.write_bytes(data)
    return path


class VideoCardEndpointTests(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            email='videocard@example.com', password='TestPass123!',
            dob_hash='x' * 64, is_adult=True,
        )
        self.profile = Profile.objects.create(
            user=self.user, username='videocard', display_name='Video Card',
        )
        self.client = APIClient()
        self.client.force_authenticate(self.user)

        self.post = Post.objects.create(
            author=self.profile,
            post_type='short_video',
            body='A clip with sound',
            media_urls=['https://res.cloudinary.com/demo/video/upload/clip.mp4'],
        )
        PostMedia.objects.create(
            post=self.post,
            media_type='video',
            url='https://res.cloudinary.com/demo/video/upload/clip.mp4',
        )

    def test_start_returns_a_job_and_the_status_endpoint_reports_pending(self):
        with mock.patch('common.video_card.submit_video_card') as submit:
            res = self.client.post(
                f'/api/v1/feed/{self.post.id}/video-card/',
                {
                    'base': _png_file('base.png'),
                    'over': _png_file('over.png'),
                    'rect': '48,150,984,780',
                    'radius': '36',
                },
                format='multipart',
            )
        self.assertEqual(res.status_code, 202)
        self.assertEqual(res.data['data']['status'], 'pending')
        submit.assert_called_once()

    def test_start_rejects_a_post_without_video(self):
        text_post = Post.objects.create(
            author=self.profile, post_type='text', body='no video here',
        )
        res = self.client.post(
            f'/api/v1/feed/{text_post.id}/video-card/',
            {'base': _png_file(), 'rect': '48,150,984,780'},
            format='multipart',
        )
        self.assertEqual(res.status_code, 404)

    def test_start_rejects_a_missing_artwork(self):
        res = self.client.post(
            f'/api/v1/feed/{self.post.id}/video-card/',
            {'rect': '48,150,984,780'},
            format='multipart',
        )
        self.assertEqual(res.status_code, 400)

    def test_start_rejects_a_rect_outside_the_canvas(self):
        res = self.client.post(
            f'/api/v1/feed/{self.post.id}/video-card/',
            {'base': _png_file(), 'rect': '0,0,9999,9999'},
            format='multipart',
        )
        self.assertEqual(res.status_code, 400)

    def test_status_endpoint_returns_the_rendered_file(self):
        job_id = new_job_id()
        rendered = _render_file(b'video')
        with mock.patch(
            'common.video_card.video_card_status',
            return_value={'status': 'ready', 'size': 5},
        ), mock.patch(
            'common.video_card.video_card_path', return_value=rendered
        ):
            res = self.client.get(f'/api/v1/feed/{self.post.id}/video-card/{job_id}/')
        self.assertEqual(res.status_code, 200)
        self.assertEqual(res['Content-Type'], 'video/mp4')
        self.assertIn(f'buddyup_{self.post.id}.mp4', res['Content-Disposition'])
        b''.join(res.streaming_content)
        rendered.unlink(missing_ok=True)

    def test_status_endpoint_reports_pending(self):
        job_id = new_job_id()
        with mock.patch(
            'common.video_card.video_card_status', return_value={'status': 'pending'}
        ):
            res = self.client.get(f'/api/v1/feed/{self.post.id}/video-card/{job_id}/')
        self.assertEqual(res.status_code, 202)
        self.assertEqual(res.data['data']['status'], 'pending')

    def test_status_endpoint_reports_failure(self):
        job_id = new_job_id()
        with mock.patch(
            'common.video_card.video_card_status',
            return_value={'status': 'failed', 'error': 'no ffmpeg'},
        ):
            res = self.client.get(f'/api/v1/feed/{self.post.id}/video-card/{job_id}/')
        self.assertEqual(res.status_code, 503)
        self.assertIn('no ffmpeg', res.data['message'])

    def test_status_endpoint_rejects_an_unknown_job(self):
        res = self.client.get(f'/api/v1/feed/{self.post.id}/video-card/nope/')
        self.assertEqual(res.status_code, 404)


class CommunityVideoCardEndpointTests(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            email='communitycard@example.com', password='TestPass123!',
            dob_hash='x' * 64, is_adult=True,
        )
        self.profile = Profile.objects.create(
            user=self.user, username='communitycard', display_name='Community Card',
        )
        self.client = APIClient()
        self.client.force_authenticate(self.user)

        self.conv = Conversation.objects.create(
            group_name='Card Community', is_group=True,
            is_community=True, is_public=True, created_by=self.profile,
        )
        self.post = CommunityPost.objects.create(
            conversation=self.conv,
            author=self.profile,
            body='A community clip',
            media_url='https://res.cloudinary.com/demo/video/upload/clip.mp4',
        )

    def test_start_returns_a_job(self):
        with mock.patch('common.video_card.submit_video_card') as submit:
            res = self.client.post(
                f'/api/v1/messaging/communities/{self.conv.id}/posts/{self.post.id}/video-card/',
                {'base': _png_file(), 'rect': '48,150,984,780'},
                format='multipart',
            )
        self.assertEqual(res.status_code, 202)
        submit.assert_called_once()

    def test_start_rejects_a_post_without_video(self):
        text_post = CommunityPost.objects.create(
            conversation=self.conv, author=self.profile, body='no video',
        )
        res = self.client.post(
            f'/api/v1/messaging/communities/{self.conv.id}/posts/{text_post.id}/video-card/',
            {'base': _png_file(), 'rect': '48,150,984,780'},
            format='multipart',
        )
        self.assertEqual(res.status_code, 404)

    def test_status_endpoint_returns_the_rendered_file(self):
        job_id = new_job_id()
        rendered = _render_file(b'video')
        with mock.patch(
            'common.video_card.video_card_status',
            return_value={'status': 'ready', 'size': 5},
        ), mock.patch(
            'common.video_card.video_card_path', return_value=rendered
        ):
            res = self.client.get(
                f'/api/v1/messaging/communities/{self.conv.id}/posts/{self.post.id}/video-card/{job_id}/'
            )
        self.assertEqual(res.status_code, 200)
        self.assertEqual(res['Content-Type'], 'video/mp4')
        b''.join(res.streaming_content)
        rendered.unlink(missing_ok=True)
