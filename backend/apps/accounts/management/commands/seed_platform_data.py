from django.core.management.base import BaseCommand
from django.utils import timezone
from datetime import timedelta
import random

from apps.accounts.models import User
from apps.profiles.models import Profile, FollowRelationship, BuddyRelationship
from apps.gyms.models import Gym, GymMembership
from apps.sessions.models import TrainerProfile, Availability
from apps.marketplace.models import (
    MarketplaceEvent, MealPlan, TrainingProgramme, Product
)
from apps.feed.models import Post, Comment, Reaction

class Command(BaseCommand):
    help = 'Seeds the platform with initial data for testing and development'

    def handle(self, *args, **kwargs):
        self.stdout.write('Starting data seeding...')

        # --- 1. Target Users ---
        target_emails = [
            'jmbngugimbugua@gmail.com',
            'johnndichu.w@gmail.com',
            'jameskiach7@gmail.com',
            'rockcerion42c@gmail.com'
        ]
        
        target_profiles = []
        for i, email in enumerate(target_emails):
            username = email.split('@')[0]
            display_name = username.replace('.', ' ').replace('_', ' ').title()
            
            user, created = User.objects.get_or_create(
                email=email,
                defaults={'is_active': True, 'email_verified': True}
            )
            if created:
                user.set_password('password123')
                user.save()
            
            # High balance
            balance = {
                'dumbbell': 5500,
                'barbell': 500,
                'burpee': 200,
                'squat': 50,
                'sprint': 10,
                'pr': 5,
                'champion': 2
            }
            
            profile, _ = Profile.objects.update_or_create(
                user=user,
                defaults={
                    'username': username,
                    'display_name': display_name,
                    'role': 'user' if i > 1 else 'trainer',
                    'bio': f'Fitness enthusiast and platform early adopter. Loves pushing limits.',
                    'artifact_balance': balance,
                    'verification_status': 'email',
                    'location_city': 'Nairobi' if i % 2 == 0 else 'London',
                    'location_country': 'Kenya' if i % 2 == 0 else 'UK',
                }
            )
            target_profiles.append(profile)
            self.stdout.write(self.style.SUCCESS(f'Created/Updated target user: {email}'))

        # --- 2. Additional Users & Trainers ---
        roles = ['user', 'user', 'user', 'trainer', 'practitioner']
        additional_profiles = []
        for i in range(1, 15):
            role = random.choice(roles)
            email = f'user{i}_{role}@example.com'
            user, _ = User.objects.get_or_create(
                email=email,
                defaults={'is_active': True, 'email_verified': True}
            )
            user.set_password('password123')
            user.save()
            
            balance = {'dumbbell': random.randint(100, 1000), 'barbell': random.randint(0, 50)}
            profile, _ = Profile.objects.update_or_create(
                user=user,
                defaults={
                    'username': f'user{i}_{role}',
                    'display_name': f'Demo {role.title()} {i}',
                    'role': role,
                    'bio': f'Just a regular {role} trying to stay fit.',
                    'artifact_balance': balance,
                    'verification_status': 'email' if role == 'user' else 'trainer',
                }
            )
            additional_profiles.append(profile)

        all_profiles = target_profiles + additional_profiles
        trainers = [p for p in all_profiles if p.role == 'trainer']

        # --- 3. Gyms ---
        gyms_data = [
            {'name': 'Iron Palace', 'category': 'strength', 'city': 'Nairobi'},
            {'name': 'Zen Flow Yoga', 'category': 'yoga', 'city': 'London'},
            {'name': 'Urban Fitness', 'category': 'fitness', 'city': 'Nairobi'},
            {'name': 'CrossFit Central', 'category': 'mixed', 'city': 'London'},
            {'name': 'Cardio Core', 'category': 'cardio', 'city': 'New York'}
        ]
        
        gyms = []
        for i, g_data in enumerate(gyms_data):
            owner = random.choice(target_profiles + additional_profiles)
            gym, _ = Gym.objects.get_or_create(
                handle=f"gym-{i+1}",
                defaults={
                    'name': g_data['name'],
                    'description': f"Welcome to {g_data['name']}. The best {g_data['category']} gym.",
                    'category': g_data['category'],
                    'location_city': g_data['city'],
                    'access_type': 'public' if i % 2 == 0 else 'private',
                    'monthly_fee_artifacts': {'dumbbell': 500} if i % 2 == 0 else {},
                    'is_verified': True
                }
            )
            GymMembership.objects.get_or_create(gym=gym, member=owner, defaults={'role': 'owner', 'subscription_active': True})
            gyms.append(gym)
            
            # Add members
            for p in random.sample(all_profiles, min(5, len(all_profiles))):
                GymMembership.objects.get_or_create(gym=gym, member=p, defaults={'role': 'member', 'subscription_active': True})

        self.stdout.write(self.style.SUCCESS(f'Created {len(gyms)} gyms.'))

        # --- 4. Trainer Profiles ---
        for t in trainers:
            t_prof, _ = TrainerProfile.objects.get_or_create(
                profile=t,
                defaults={
                    'specialties': ['Weight Loss', 'Strength Training', 'HIIT'],
                    'years_experience': random.randint(2, 10),
                    'session_types': ['1on1_live', 'group_live', 'async'],
                    'pricing': {'1on1_live': {'dumbbell': 100}, 'group_live': {'dumbbell': 50}},
                    'average_rating': round(random.uniform(3.5, 5.0), 1),
                    'review_count': random.randint(5, 50)
                }
            )
            # Add availability
            for day in range(1, 6): # Mon-Fri
                Availability.objects.get_or_create(
                    trainer=t_prof,
                    day_of_week=day,
                    start_time='09:00:00',
                    defaults={'end_time': '17:00:00'}
                )
        self.stdout.write(self.style.SUCCESS(f'Created {len(trainers)} trainer profiles.'))

        # --- 5. Marketplace Content ---
        # Events
        for i in range(5):
            MarketplaceEvent.objects.get_or_create(
                title=f"Fitness Bootcamp {i+1}",
                creator=random.choice(trainers),
                defaults={
                    'description': "Join us for an intense bootcamp session.",
                    'event_type': 'online' if i % 2 == 0 else 'in_person',
                    'start_datetime': timezone.now() + timedelta(days=i+5),
                    'end_datetime': timezone.now() + timedelta(days=i+5, hours=2),
                    'ticket_price_artifacts': {'dumbbell': 50} if i % 2 != 0 else {},
                    'is_free': i % 2 == 0,
                    'category': 'Bootcamp',
                    'gym': random.choice(gyms) if i % 2 != 0 else None
                }
            )
            
        # Meal Plans
        for i in range(5):
            MealPlan.objects.get_or_create(
                title=f"Healthy Diet Plan {i+1}",
                creator=random.choice(trainers),
                defaults={
                    'diet_type': random.choice([c[0] for c in MealPlan.DIET_TYPES]),
                    'description': "A comprehensive meal plan.",
                    'price_artifacts': {'dumbbell': 200},
                    'duration_weeks': 4
                }
            )
            
        # Programmes
        for i in range(5):
            TrainingProgramme.objects.get_or_create(
                title=f"Strength Builder {i+1}",
                creator=random.choice(trainers),
                defaults={
                    'category': 'Strength',
                    'description': "Build muscle and strength.",
                    'price_artifacts': {'dumbbell': 300},
                    'duration_weeks': 8
                }
            )

        # Products
        for i in range(5):
            Product.objects.get_or_create(
                name=f"Whey Protein {i+1}",
                defaults={
                    'brand': 'Optimum Nutrition',
                    'category': 'supplement',
                    'description': "High quality protein.",
                    'affiliate_url': 'https://example.com/product',
                    'price_display': '$29.99',
                    'recommended_by': random.choice(trainers)
                }
            )
        self.stdout.write(self.style.SUCCESS('Created marketplace items.'))

        # --- 6. Posts & Interactions ---
        for i in range(15):
            author = random.choice(all_profiles)
            post, _ = Post.objects.get_or_create(
                author=author,
                body=f"Just crushed my workout today! Feeling great 💪 #fitness #workout{i}",
                defaults={
                    'post_type': 'text',
                    'visibility': 'public',
                }
            )
            
            # Add some comments and reactions
            for _ in range(random.randint(1, 4)):
                commenter = random.choice(all_profiles)
                if commenter != author:
                    Comment.objects.get_or_create(
                        post=post,
                        author=commenter,
                        defaults={'body': "Awesome job! Keep it up 🔥"}
                    )
                    Reaction.objects.get_or_create(
                        post=post,
                        author=commenter,
                        defaults={'reaction_type': random.choice(['🔥', '❤️', '👏', '💪'])}
                    )

        self.stdout.write(self.style.SUCCESS('Created feed posts and interactions.'))
        self.stdout.write(self.style.SUCCESS('Successfully seeded all platform data!'))
