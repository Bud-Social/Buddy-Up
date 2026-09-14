"""Populate the local database with real, playable data:
synthesized CC0-style sound tracks + demo users and text posts so the
Bud Press studio and feed are not empty. Idempotent."""
import io
import math
import random
import struct
import wave

from django.conf import settings
from django.core.files.base import ContentFile
from django.core.management.base import BaseCommand
from django.db import transaction

from apps.accounts.models import User
from apps.feed.models import Post, PostMedia, Sound
from apps.profiles.models import Profile

SR = 44100

TRACK_SPECS = [
    # (name, artist, seconds, chord root, pattern)
    ('Emerald Dawn', 'BuddyUp Studio', 12.0, 55.0, 'lift'),
    ('Neon Pulse', 'DJ Kilo', 14.0, 65.4, 'four'),
    ('Iron Progress', 'The Liftmasters', 15.0, 49.0, 'hard'),
    ('Sunset Zen', 'Mellow Bud', 18.0, 61.7, 'chill'),
    ('Gym Trap', '808 Crew', 13.0, 43.7, 'trap'),
    ('Viral Pop', 'The Hooks', 12.0, 58.3, 'pop'),
    ('Deep Focus', 'Lo-Fi Loop', 16.0, 51.9, 'chill'),
    ('Fight Night', 'Pulsewave', 14.0, 46.2, 'hard'),
]

BPM = {'lift': 120, 'four': 126, 'hard': 128, 'chill': 84, 'trap': 140, 'pop': 118}


def synth_track(seconds: float, root: float, pattern: str) -> bytes:
    """Render a short procedural music loop: chord plucks + kick + hats."""
    bpm = BPM[pattern]
    beat = 60.0 / bpm
    bar = 4 * beat
    total = int(SR * seconds)
    out = [0.0] * total

    # I–IV–v–VI-style major/mixed progression intervals
    floats = [1.0, 1.2599, 1.4983, 1.3348, 1.4983, 1.1892]
    progression = [0, 2, 3, 1]
    n_bars = max(1, int(math.ceil(seconds / bar)))
    for b in range(n_bars):
        chord_root = root * floats[progression[b % len(progression)]]
        for i, mult in enumerate([2.0, 3.0, 4.0, 2.5]):
            freq = chord_root * mult
            start = int(b * bar + i * (bar / 4))
            length = int(SR * (bar / 4) * (0.9 if pattern != 'chill' else 0.95))
            for p in range(length):
                idx = start + p
                if idx >= total:
                    break
                t = p / SR
                env = math.exp(-t * (5.0 if pattern != 'chill' else 3.0))
                val = math.sin(2 * math.pi * freq * t) * 0.22
                val += math.sin(2 * math.pi * freq * 2 * t) * 0.08
                out[idx] += val * env

    # kick on downbeats (2 per bar for chill, 4 otherwise)
    k_len = int(SR * 0.16)
    kick_stride = beat * (2 if pattern == 'chill' else 1)
    t_i = 0.0
    while t_i < seconds:
        start = int(SR * t_i)
        for p in range(k_len):
            idx = start + p
            if idx >= total:
                break
            t = p / SR
            env = math.exp(-t * 22)
            freq = 110 * math.exp(-t * 30) + 42
            out[idx] += math.sin(2 * math.pi * freq * t) * 0.9 * env
        t_i += kick_stride

    # hats on the off-beats
    rng = random.Random(int(root * 100))
    h_len = int(SR * 0.05)
    t_i = beat / 2
    while t_i < seconds:
        start = int(SR * t_i)
        for p in range(h_len):
            idx = start + p
            if idx >= total:
                break
            out[idx] += (rng.random() * 2 - 1) * 0.12 * math.exp(-p / SR * 60)
        t_i += beat / 2

    peak = max(1e-6, max(abs(v) for v in out))
    gain = min(1.0, 0.88 / peak)
    frames = struct.pack('<%dh' % total, *(
        int(max(-32000.0, min(32000.0, v * gain * 32000))) for v in out
    ))

    buf = io.BytesIO()
    with wave.Wave_write(buf) as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(SR)
        f.writeframes(frames)
    return buf.getvalue()


def _media_url_builder():
    base = (getattr(settings, 'PUBLIC_API_URL', '') or '').rstrip('/')
    if base:
        return lambda path: f'{base}/media/{path}'
    if getattr(settings, 'DEBUG', False):
        return lambda path: f'http://localhost:8002/media/{path}'
    return lambda path: f'/media/{path}'


def _local_media_storage():
    """Bypass any CDN-backed default storage: ecosystem audio ships as
    raw local files so Django/DEBUG dev-serves them."""
    from django.core.files.storage import FileSystemStorage
    return FileSystemStorage(location=str(settings.MEDIA_ROOT))


class Command(BaseCommand):
    help = 'Seed demo users, text posts and synthesized CC0 sound tracks (idempotent).'

    @transaction.atomic
    def handle(self, *args, **options):
        if Sound.objects.filter(source='curated', is_active=True).exists() is False:
            created = self._seed_sound_library()
            self.stdout.write(f'Synthesized {created} sound tracks.')
        else:
            self.stdout.write('Sound library already populated — skipping.')

        self._seed_demo_users_and_posts()
        self.stdout.write(
            f'Demo data ready. counts: '
            f'sounds={Sound.objects.filter(is_active=True).count()} '
            f'users={User.objects.count()} posts={Post.objects.count()}'
        )

    def _seed_sound_library(self) -> int:
        media_of = _media_url_builder()
        created = 0
        for name, artist, seconds, root, pattern in TRACK_SPECS:
            sound, was_created = Sound.objects.get_or_create(
                name=name, artist=artist,
                defaults={'source': 'curated', 'license': 'Synthesized (no license needed)'},
            )
            if not was_created and sound.audio_url:
                continue
            content = synth_track(seconds, root, pattern)
            path = _local_media_storage().save(
                f'sounds/{name.lower().replace(" ", "-")}.wav', ContentFile(content),
            )
            sound.audio_url = media_of(path)
            sound.duration_ms = int(seconds * 1000)
            sound.usage_count = 40 + (int(abs(root) * 17) % 900)
            sound.is_active = True
            sound.save()
            self.stdout.write(f'  + {name} — {artist} ({seconds:.0f}s) → {path}')
            created += 1
        return created

    DEMO_USERS = [
        ('demo.peter', 'Peter Trainer', 'trainer', 'Certified strength coach. Form > ego. 🔥 #fitness'),
        ('demo.jane', 'Jane Lifts', 'trainer', 'Powerlifting + sleep. Progressive overload always. #gym'),
        ('demo.mike', 'Mike Runs', 'user', 'Just here to show up every day. 💪 #running'),
        ('demo.zuri', 'Zuri Wellness', 'practitioner', 'Holistic wellness. Breathe. Move. Recover. 🌿'),
        ('demo.nova', 'Nova Gains', 'user', 'Mechanical failure wins the monster set… eat, sleep, repeat. #gym'),
    ]

    POST_BODIES = [
        'Just hit my 7th session this week. Consistency beats motivation. #gym #buddyup',
        'New PR on deadlift today! The progress tracker feature is 🔥 #progress #strength',
        'Morning run + smoothie = the perfect reset. Who else trains before 7am? #running #meals',
        'Meal prep Sunday: 40g protein per bowl, 20 minutes of cooking. Recipes in bio! 🥡 #meals',
        'Push day recap: 5 sets chest, 4 shoulders, 3 triceps. Add me as a workout buddy! 💪 #gym #buddyup',
        'Deepboxing leg day so you don\'t have to. Quads destroyed but feeling great #fitness #gym',
        'Sleep is your best performance enhancer. 8 hours or nothing. #wellness #recovery',
        'Hydration check: 3.2L today. The new health-insights page shows a chart — neat! #wellness',
    ]

    def _seed_demo_users_and_posts(self) -> int:
        created_posts = 0
        active_sounds = list(Sound.objects.filter(is_active=True).order_by('-usage_count')[:4])
        for idx, (username, display, role, bio) in enumerate(self.DEMO_USERS):
            email = f'{username}@demo.buddyup'
            user = User.objects.filter(email=email).first()
            if not user:
                user = User.objects.create_user(
                    email=email, password='Demo1234!',
                    dob_hash='d' * 64, is_adult=True,
                )
            profile = getattr(user, 'profile', None) or Profile.objects.create(
                user=user, username=username, display_name=display,
            )
            try:
                profile.role = role
                profile.display_name = display
                profile.bio = bio
                profile.save()
            except Exception:
                pass

            body = self.POST_BODIES[idx % len(self.POST_BODIES)]
            if not Post.objects.filter(author=profile, body=body).exists():
                Post.objects.create(author=profile, post_type='text', body=body, visibility='public')
                created_posts += 1

            # Give the local Bud Press feed playable demo media as well as
            # text posts. The audio rows exercise SoundPicker and the feed
            # player without requiring copyrighted video assets.
            if idx < len(active_sounds):
                sound = active_sounds[idx]
                audio_body = f'{sound.name} — demo sound from {sound.artist}. Tap to listen. #budpress #sound'
                audio_post, audio_created = Post.objects.get_or_create(
                    author=profile,
                    body=audio_body,
                    defaults={'post_type': 'short_video', 'visibility': 'public'},
                )
                if audio_created:
                    PostMedia.objects.create(
                        post=audio_post,
                        order=0,
                        media_type='audio',
                        url=sound.audio_url,
                        duration_ms=sound.duration_ms,
                        sound=sound,
                        sound_volume=85,
                    )
                    created_posts += 1
        return created_posts
