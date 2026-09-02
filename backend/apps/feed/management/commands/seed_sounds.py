import json
from pathlib import Path

from django.core.management.base import BaseCommand

from apps.feed.models import Sound

SEED_FILE = Path(__file__).resolve().parent.parent.parent / 'sounds_seed.json'


class Command(BaseCommand):
    help = 'Seed curated CC0 sounds for Bud Press (idempotent by name+artist).'

    def handle(self, *args, **options):
        if not SEED_FILE.exists():
            self.stderr.write(f'Seed file not found: {SEED_FILE}')
            return

        entries = json.loads(SEED_FILE.read_text())
        created = skipped = 0
        for entry in entries:
            audio_url = entry.get('audio_url') or ''
            _, was_created = Sound.objects.get_or_create(
                name=entry['name'],
                artist=entry.get('artist', ''),
                defaults={
                    'audio_url': audio_url,
                    'duration_ms': entry.get('duration_ms'),
                    'source': 'curated',
                    'license': entry.get('license', 'CC0'),
                    # No audio yet — mark inactive so it stays out of the
                    # picker until the upload lands.
                    'is_active': bool(audio_url),
                },
            )
            if was_created:
                created += 1
            else:
                skipped += 1
        self.stdout.write(
            f'Seeded {created} sounds ({skipped} already present, pending upload: '
            f'{Sound.objects.filter(source="curated", is_active=False).count()}).'
        )
