import random
from datetime import timedelta
from django.utils import timezone
from django.core.management.base import BaseCommand
from django.db import transaction

from apps.profiles.models import Profile
from apps.sessions.models import TrainerProfile, BookingSession

class Command(BaseCommand):
    help = 'Populate database with mock session data'

    def handle(self, *args, **kwargs):
        self.stdout.write('Starting session population...')

        profiles = list(Profile.objects.all())
        if len(profiles) < 2:
            self.stdout.write(self.style.ERROR('Need at least 2 profiles to populate sessions.'))
            return

        with transaction.atomic():
            # 1. Ensure we have some trainers
            trainers = []
            trainer_profiles = profiles[:3]  # Take up to 3 as trainers
            for p in trainer_profiles:
                if p.role not in ['trainer', 'practitioner']:
                    p.role = 'trainer'
                    p.verification_status = 'trainer'
                    p.save(update_fields=['role', 'verification_status'])
                
                tp, created = TrainerProfile.objects.get_or_create(
                    profile=p,
                    defaults={
                        'specialties': ['Strength Training', 'Yoga', 'HIIT'],
                        'certifications': [{'name': 'ACE Certified Personal Trainer', 'issuer': 'ACE', 'year': 2020}],
                        'years_experience': 5,
                        'session_types': ['1on1_live', 'in_person'],
                        'pricing': {'dumbbell': {'artifact_type': 'dumbbell', 'quantity': 10}}
                    }
                )
                trainers.append(tp)

            # 2. Create some sessions
            session_types = ['1on1_live', 'in_person']
            statuses = ['pending', 'confirmed', 'completed']
            now = timezone.now()

            clients = [p for p in profiles if p not in trainer_profiles]
            if not clients:
                clients = profiles # fallback if all are trainers

            for i in range(15):
                trainer = random.choice(trainers).profile
                client = random.choice(clients)
                if trainer == client:
                    continue

                status = random.choice(statuses)
                if status == 'completed':
                    scheduled_at = now - timedelta(days=random.randint(1, 30))
                    completed_at = scheduled_at + timedelta(minutes=60)
                else:
                    scheduled_at = now + timedelta(days=random.randint(1, 30))
                    completed_at = None

                BookingSession.objects.create(
                    client=client,
                    trainer=trainer,
                    session_type=random.choice(session_types),
                    status=status,
                    scheduled_at=scheduled_at,
                    duration_minutes=60,
                    artifact_fee={'dumbbell': 10},
                    completed_at=completed_at
                )

        self.stdout.write(self.style.SUCCESS('Successfully populated sessions!'))
