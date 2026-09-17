from unittest.mock import MagicMock, patch

from django.test import SimpleTestCase, TestCase, override_settings

import requests

from apps.accounts.models import User
from apps.feed.models import Post, PostMedia
from apps.profiles.models import Profile

from .models import AIPredictionJob
from .serializers import AIPredictionJobSerializer
from .tasks import transcribe_post_media
from .utils import segments_to_vtt


class AIPredictionMetadataTests(SimpleTestCase):
    def test_serializer_exposes_safety_and_quality_metadata(self):
        self.assertIn('safety_notice', AIPredictionJobSerializer.Meta.fields)
        self.assertIn('confidence', AIPredictionJobSerializer.Meta.fields)
        self.assertEqual(AIPredictionJob._meta.get_field('safety_notice').default, 'AI output is informational only, not medical advice.')


def _make_video_media(url='https://cdn.example.com/talk.mp4'):
    user = User.objects.create_user(
        email='transcriber@example.com', password='TestPass123!',
        dob_hash='x' * 64, is_adult=True,
    )
    profile = Profile.objects.create(user=user, username='transcriber', display_name='Transcriber')
    post = Post.objects.create(author=profile, post_type='short_video', media_urls=[url])
    return PostMedia.objects.create(post=post, order=0, media_type='video', url=url)


class SegmentsToVttTests(SimpleTestCase):
    def test_renders_webvtt_cues(self):
        vtt = segments_to_vtt([
            {'start_ms': 0, 'end_ms': 1500, 'text': 'Welcome back.'},
            {'start_ms': 1500, 'end_ms': 63500, 'text': 'Let us train.'},
        ])
        self.assertTrue(vtt.startswith('WEBVTT'))
        self.assertIn('00:00:00.000 --> 00:00:01.500', vtt)
        self.assertIn('00:00:01.500 --> 00:01:03.500', vtt)
        self.assertIn('Welcome back.', vtt)

    def test_skips_empty_segments(self):
        vtt = segments_to_vtt([{'start_ms': 0, 'end_ms': 1000, 'text': ''}])
        self.assertEqual(vtt, 'WEBVTT\n')


@override_settings(CELERY_TASK_ALWAYS_EAGER=False)
class TranscribePostMediaTaskTests(TestCase):
    def test_transcribe_writes_captions_and_vtt_and_job(self):
        media = _make_video_media()
        ai_payload = {
            'segments': [
                {'start_ms': 0, 'end_ms': 1500, 'text': 'Welcome back.'},
                {'start_ms': 1500, 'end_ms': 3000, 'text': 'Let us train.'},
            ],
            'language': 'en',
            'duration_ms': 3000,
        }
        response = MagicMock(status_code=200)
        response.json.return_value = ai_payload
        with patch('apps.ai.tasks.requests.post', return_value=response) as mock_post, \
                patch('apps.moderation.tasks.moderate_text_content.delay') as mock_moderate:
            transcribe_post_media.apply(args=[str(media.id)])

        mock_post.assert_called_once()
        self.assertIn('/api/v1/transcribe', mock_post.call_args.args[0])
        media.refresh_from_db()
        self.assertEqual(media.captions, ai_payload['segments'])
        self.assertIn('WEBVTT', media.captions_vtt)
        self.assertIn('00:00:00.000 --> 00:00:01.500', media.captions_vtt)
        self.assertIn('Welcome back.', media.captions_vtt)

        job = AIPredictionJob.objects.filter(task='transcription').latest('created_at')
        self.assertEqual(job.status, 'completed')
        self.assertEqual(job.output_data['segments'], 2)
        # Transcript is sent onward to text moderation.
        mock_moderate.assert_called_once_with(
            'feed.postmedia', str(media.id), 'Welcome back. Let us train.',
        )

    def test_transcribe_failure_marks_job_failed_after_retries(self):
        media = _make_video_media()
        with patch('apps.ai.tasks.requests.post', side_effect=requests.RequestException('boom')):
            transcribe_post_media.apply(args=[str(media.id)])
        media.refresh_from_db()
        self.assertEqual(media.captions, [])
        self.assertEqual(media.captions_vtt, '')
        job = AIPredictionJob.objects.filter(task='transcription').latest('created_at')
        self.assertEqual(job.status, 'failed')
        self.assertIn('boom', job.error_message)

    def test_missing_post_media_is_a_noop(self):
        transcribe_post_media.apply(args=['00000000-0000-0000-0000-000000000000'])
        self.assertEqual(AIPredictionJob.objects.filter(task='transcription').count(), 0)

    def test_manual_captions_are_preserved(self):
        media = _make_video_media()
        manual = [{'start_ms': 0, 'end_ms': 1000, 'text': 'Studio caption.'}]
        media.captions = manual
        media.captions_vtt = segments_to_vtt(manual)
        media.save(update_fields=['captions', 'captions_vtt'])
        with patch('apps.ai.tasks.requests.post') as mock_post:
            transcribe_post_media.apply(args=[str(media.id)])
        mock_post.assert_not_called()
        media.refresh_from_db()
        self.assertEqual(media.captions, manual)
        self.assertEqual(AIPredictionJob.objects.filter(task='transcription').count(), 0)


class TranscribeSsrfGuardTests(SimpleTestCase):
    """The transcription URL-fetcher rejects non-public / oversized targets."""

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        import importlib.util
        from pathlib import Path
        engine_path = Path(__file__).resolve().parents[2] / 'ai_service' / 'app' / 'urlguard.py'
        spec = importlib.util.spec_from_file_location('buddyup_urlguard', engine_path)
        cls.engine = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(cls.engine)

    def _guard(self, url):
        return self.engine.assert_public_http_url(url)

    def test_rejects_non_http_schemes(self):
        with self.assertRaises(ValueError):
            self._guard('file:///etc/passwd')

    def test_rejects_localhost_by_name(self):
        with patch('socket.getaddrinfo') as getaddr:
            getaddr.return_value = [(2, 1, 6, '', ('127.0.0.1', 0))]
            with self.assertRaises(ValueError):
                self._guard('https://localhost/clip.mp4')

    def test_rejects_private_addresses(self):
        with patch('socket.getaddrinfo') as getaddr:
            getaddr.return_value = [(2, 1, 6, '', ('10.0.0.5', 0))]
            with self.assertRaises(ValueError):
                self._guard('https://internal.example/clip.mp4')

    def test_rejects_metadata_link_local(self):
        with patch('socket.getaddrinfo') as getaddr:
            getaddr.return_value = [(2, 1, 6, '', ('169.254.169.254', 0))]
            with self.assertRaises(ValueError):
                self._guard('https://metadata.example/latest/meta-data')

    def test_allows_public_address(self):
        with patch('socket.getaddrinfo') as getaddr:
            getaddr.return_value = [(2, 1, 6, '', ('93.184.216.34', 0))]
            # Must not raise.
            self._guard('https://res.cloudinary.com/demo/video/upload/clip.mp4')


def _banded_user():
    from django.contrib.auth import get_user_model

    return get_user_model().objects.create_user(
        email='banded@example.com', password='TestPass123!',
    )


class BandedViewSetTests(TestCase):
    def setUp(self):
        from rest_framework.test import APIClient

        self.client = APIClient()
        self.client.force_authenticate(user=_banded_user())

    def _mock_ok(self, payload):
        resp = MagicMock()
        resp.json.return_value = payload
        return patch('apps.ai.views.ai_post', return_value=resp)

    def test_nlp_classify_records_completed_job(self):
        from apps.ai.models import AIPredictionJob

        out = {'label': 'meirl', 'confidence': 0.95, 'method': 'banded_nlp_best'}
        with self._mock_ok(out):
            r = self.client.post('/api/v1/ai/banded/nlp-classify/', {'text': 'meirl'})
        self.assertEqual(r.status_code, 200)
        self.assertEqual(r.json()['label'], 'meirl')
        job = AIPredictionJob.objects.get(pk=r.json()['job_id'])
        self.assertEqual((job.task, job.status), ('banded_nlp', 'completed'))
        self.assertEqual(job.confidence, 0.95)

    def test_nlp_classify_rejects_empty_text(self):
        r = self.client.post('/api/v1/ai/banded/nlp-classify/', {'text': '  '})
        self.assertEqual(r.status_code, 400)

    def test_vision_classify_requires_file(self):
        r = self.client.post('/api/v1/ai/banded/vision-classify/', {})
        self.assertEqual(r.status_code, 400)

    def test_service_outage_marks_job_failed(self):
        from apps.ai.models import AIPredictionJob

        with patch('apps.ai.views.ai_post', side_effect=ConnectionError('down')):
            r = self.client.post('/api/v1/ai/banded/rl-jepa-act/',
                                 {'obs': [0.1] * 48}, format='json')
        self.assertEqual(r.status_code, 503)
        job = AIPredictionJob.objects.get(pk=r.json()['job_id'])
        self.assertEqual((job.task, job.status), ('banded_rl_traj', 'failed'))

    def test_rl_nlp_act_ok(self):
        out = {'action': 3, 'probs': [0.2, 0.1, 0.2, 0.5], 'method': 'rl_nlp_policy'}
        with self._mock_ok(out):
            r = self.client.post('/api/v1/ai/banded/rl-nlp-act/', {'text': 'hi'})
        self.assertEqual(r.status_code, 200)
        self.assertEqual(r.json()['action'], 3)


class RegisterBandedModelsTests(TestCase):
    def test_registers_six_models_idempotently(self):
        from django.core.management import call_command

        from apps.ai.models import ModelMetadata

        call_command('register_banded_models')
        call_command('register_banded_models')
        names = set(ModelMetadata.objects.values_list('name', flat=True))
        for expected in ('banded_nlp_best', 'banded_vision_best', 'multimodal_fuse',
                         'recsys_item_emb', 'rl_nlp_policy', 'rl_jepa_policy'):
            self.assertIn(expected, names)
        row = ModelMetadata.objects.get(name='banded_nlp_best')
        self.assertTrue(row.is_active)
        self.assertEqual(row.metrics['bagged_acc'], 0.963)
