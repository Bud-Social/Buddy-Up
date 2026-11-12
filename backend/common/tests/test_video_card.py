"""Tests for the branded video card composer (common/video_card.py).

The composer is what turns a post's clip into a shareable video: the whole
clip, fitted so the shot stays visible, with its original audio track.
"""
import io
import os
import shutil
import subprocess
import tempfile
import unittest
from unittest import mock

from django.test import SimpleTestCase

from common.video_card import (
    VideoCardError,
    compose_video_card,
    new_job_id,
    parse_radius,
    parse_rect,
    submit_video_card,
    trim_start_seconds,
    video_card_path,
    video_card_response,
    video_card_status,
)


def _ffmpeg() -> str | None:
    system = shutil.which('ffmpeg')
    if system:
        return system
    try:
        import imageio_ffmpeg

        return imageio_ffmpeg.get_ffmpeg_exe()
    except Exception:
        return None


def _png(width: int, height: int, rgba=(20, 40, 30, 255)) -> bytes:
    from PIL import Image

    buf = io.BytesIO()
    Image.new('RGBA', (width, height), rgba).save(buf, format='PNG')
    return buf.getvalue()


class RectParsingTests(SimpleTestCase):
    def test_parses_valid_rect(self):
        self.assertEqual(parse_rect('48,150,984,780'), (48, 150, 984, 780))

    def test_rejects_missing_or_malformed_rect(self):
        for value in (None, '', 'abc', '1,2,3', '48,150,984'):
            with self.assertRaises(VideoCardError):
                parse_rect(value)

    def test_rejects_rect_outside_the_canvas(self):
        with self.assertRaises(VideoCardError):
            parse_rect('0,0,2000,1350')
        with self.assertRaises(VideoCardError):
            parse_rect('-10,0,100,100')
        with self.assertRaises(VideoCardError):
            parse_rect('0,0,0,100')


class TrimStartTests(SimpleTestCase):
    """A card starts where the post starts, and never stops early."""

    def test_no_trim_starts_at_the_beginning(self):
        self.assertIsNone(trim_start_seconds(None))
        self.assertIsNone(trim_start_seconds(0))

    def test_a_trimmed_start_becomes_an_offset(self):
        self.assertAlmostEqual(trim_start_seconds(1500), 1.5)

    def test_a_negative_start_is_clamped(self):
        self.assertIsNone(trim_start_seconds(-500))


class RadiusParsingTests(SimpleTestCase):
    def test_defaults_to_the_media_radius(self):
        self.assertEqual(parse_radius(None), 36)
        self.assertEqual(parse_radius('not-a-number'), 36)

    def test_clamps_to_a_sane_range(self):
        self.assertEqual(parse_radius('12'), 12)
        self.assertEqual(parse_radius('-5'), 0)
        self.assertEqual(parse_radius('9999'), 200)


class VideoCardResponseTests(SimpleTestCase):
    def test_response_carries_an_attachment(self):
        import tempfile
        from pathlib import Path

        path = Path(tempfile.mkdtemp()) / 'card.mp4'
        path.write_bytes(b'12345')
        response = video_card_response(path, 'post-id')
        self.assertEqual(response['Content-Type'], 'video/mp4')
        self.assertIn('buddyup_post-id.mp4', response['Content-Disposition'])


@unittest.skipUnless(_ffmpeg(), 'ffmpeg is not available')
class ComposeVideoCardTests(SimpleTestCase):
    """The composer needs a real clip, so a tiny synthetic one is generated."""

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.source_path = cls._make_source()

    @classmethod
    def _make_source(cls) -> str:
        """A 2-second clip with a colour and a tone, so audio is present."""
        tmpdir = tempfile.mkdtemp()
        path = os.path.join(tmpdir, 'source.mp4')
        subprocess.run(
            [
                _ffmpeg(), '-y', '-hide_banner', '-loglevel', 'error',
                '-f', 'lavfi', '-i', 'testsrc=size=320x240:rate=10:duration=2',
                '-f', 'lavfi', '-i', 'sine=frequency=440:duration=2',
                '-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-c:a', 'aac',
                '-shortest', '-f', 'mp4', path,
            ],
            stdout=subprocess.DEVNULL, stderr=subprocess.PIPE, check=True,
        )
        return path

    def _compose(self, **kwargs):
        """Compose with the synthetic source standing in for the download."""
        with mock.patch(
            'common.video_card._resolve_source_input', return_value=self.source_path
        ):
            return compose_video_card(
                'https://example.invalid/source.mp4',
                _png(1080, 1350),
                _png(1080, 1350, (0, 0, 0, 0)),
                (48, 150, 984, 780),
                **kwargs,
            )

    def test_composes_the_whole_clip_with_its_audio(self):
        data = self._compose()
        self.assertTrue(data)
        self.assertIn(b'ftyp', data[:32])

        probe = subprocess.run(
            [_ffprobe(), '-v', 'error', '-show_entries',
             'stream=codec_type', '-of', 'default=noprint_wrappers=1', '-'],
            input=data, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        )
        self.assertIn(b'video', probe.stdout)
        self.assertIn(b'audio', probe.stdout)

    def test_embeds_the_link_as_metadata(self):
        data = self._compose(link='https://buddyup.fit/videos?start=abc')
        probe = subprocess.run(
            [_ffprobe(), '-v', 'error', '-show_entries',
             'format_tags=description', '-of', 'default=noprint_wrappers=1', '-'],
            input=data, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        )
        self.assertIn(b'buddyup.fit/videos?start=abc', probe.stdout)

    def _duration(self, data: bytes) -> float:
        probe = subprocess.run(
            [_ffprobe(), '-v', 'error', '-show_entries',
             'format=duration', '-of', 'default=noprint_wrappers=1:nokey=1', '-'],
            input=data, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        )
        return float(probe.stdout.decode().strip())

    def test_keeps_the_whole_source_when_the_post_was_not_trimmed(self):
        # The synthetic source is two seconds long.
        self.assertAlmostEqual(self._duration(self._compose()), 2.0, delta=0.3)

    def test_starts_where_the_post_starts(self):
        data = self._compose(trim_start_ms=500)
        self.assertAlmostEqual(self._duration(data), 1.5, delta=0.3)

    def test_reports_a_missing_source_clearly(self):
        with self.assertRaises(VideoCardError):
            compose_video_card(
                '',
                _png(1080, 1350),
                None,
                (48, 150, 984, 780),
            )


class VideoCardJobTests(SimpleTestCase):
    """The render runs off the request thread; the client polls for it."""

    def test_job_reports_ready_with_the_rendered_file(self):
        job_id = new_job_id()
        with mock.patch('common.video_card._render_pool') as pool:
            submit_video_card(job_id, lambda: b'video-bytes')
            pool.submit.assert_called_once()

            # Run the submitted work the way the worker thread would.
            work = pool.submit.call_args[0][0]
            work()

        self.assertEqual(video_card_status(job_id)['status'], 'ready')
        path = video_card_path(job_id)
        self.assertIsNotNone(path)
        self.assertEqual(path.read_bytes(), b'video-bytes')

    def test_job_reports_failure_with_the_reason(self):
        job_id = new_job_id()
        with mock.patch('common.video_card._render_pool') as pool:
            submit_video_card(job_id, lambda: 1 / 0)
            work = pool.submit.call_args[0][0]
            work()

        status = video_card_status(job_id)
        self.assertEqual(status['status'], 'failed')
        self.assertIn('division', status['error'].lower())

    def test_unknown_job_has_no_status(self):
        self.assertIsNone(video_card_status('does-not-exist'))
        self.assertIsNone(video_card_path('does-not-exist'))


def _ffprobe() -> str:
    probe = shutil.which('ffprobe')
    if probe:
        return probe
    try:
        import imageio_ffmpeg

        return imageio_ffmpeg.get_ffmpeg_exe().replace('ffmpeg', 'ffprobe')
    except Exception:
        return 'ffprobe'
