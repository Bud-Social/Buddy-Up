from datetime import time, timedelta
from django.core.management.base import BaseCommand
from django.utils import timezone

from apps.profiles.models import Profile
from apps.sessions.models import TrainerProfile, Availability, BookingSession


class Command(BaseCommand):
    help = 'Seed sample session data for existing trainer profiles.'

    def add_arguments(self, parser):
        parser.add_argument(
            '--trainer',
            type=str,
            help='Username of an existing trainer profile. If omitted, all trainer/practitioner profiles are used.',
        )

    def handle(self, *args, **options):
        trainer_username = options.get('trainer')
        profiles_qs = Profile.objects.filter(role__in=['trainer', 'practitioner'])
        if trainer_username:
            profiles_qs = profiles_qs.filter(username=trainer_username)

        if not profiles_qs.exists():
            self.stderr.write(self.style.ERROR('No trainer/practitioner profiles found. Create some first.'))
            return

        now = timezone.now()

        for profile in profiles_qs:
            trainer, created = TrainerProfile.objects.get_or_create(
                profile=profile,
                defaults={
                    'specialties': ['strength_training', 'nutrition'],
                    'certifications': [{'name': 'Certified Personal Trainer', 'issuer': 'ACE', 'year': 2023}],
                    'years_experience': 5,
                    'languages': ['English'],
                    'session_types': ['1on1_live', 'group_live'],
                    'pricing': {'1on1_live_60': {'dumbbell': 5}, 'group_live_60': {'dumbbell': 3}},
                    'average_rating': 4.5,
                    'review_count': 12,
                    'total_sessions_completed': 45,
                },
            )
            if created:
                self.stdout.write(self.style.SUCCESS(f'Created TrainerProfile for {profile.username}'))

            days = list(range(7))
            for day in days:
                _, slot_created = Availability.objects.get_or_create(
                    trainer=trainer,
                    day_of_week=day,
                    start_time=time(9, 0),
                    defaults={
                        'end_time': time(17, 0),
                        'buffer_minutes': 15,
                        'is_active': True,
                    },
                )
                if slot_created:
                    self.stdout.write(f'  Availability: day {day} 09:00-17:00')

            client = Profile.objects.filter(role='user').first()
            if client and not BookingSession.objects.filter(trainer=profile).exists():
                BookingSession.objects.create(
                    client=client,
                    trainer=profile,
                    session_type='1on1_live',
                    status='confirmed',
                    scheduled_at=now + timedelta(days=2, hours=10),
                    duration_minutes=60,
                    artifact_fee={'dumbbell': 5},
                    notes='Looking forward to our session!',
                )
                self.stdout.write(f'  Created sample booking by {client.username}')

            completed_client = Profile.objects.filter(role='user').exclude(id=client.id if client else None).first()
            if completed_client and not BookingSession.objects.filter(trainer=profile, status='completed').exists():
                BookingSession.objects.create(
                    client=completed_client,
                    trainer=profile,
                    session_type='group_live',
                    status='completed',
                    scheduled_at=now - timedelta(days=7, hours=10),
                    duration_minutes=60,
                    artifact_fee={'dumbbell': 3},
                    completed_at=now - timedelta(days=7),
                )
                self.stdout.write(f'  Created completed booking by {completed_client.username}')

        self.stdout.write(self.style.SUCCESS('Sessions seed data created successfully.'))
