from datetime import timedelta

from django.core.management.base import BaseCommand
from django.utils import timezone

from apps.profiles.models import Profile
from apps.marketplace.models import MarketplaceEvent, Product, MealPlan, TrainingProgramme


class Command(BaseCommand):
    help = 'Seed sample marketplace content for an existing creator profile.'

    def add_arguments(self, parser):
        parser.add_argument(
            '--username',
            type=str,
            required=True,
            help='Username of the creator profile to use when seeding sample marketplace content.',
        )

    def handle(self, *args, **options):
        username = options['username']
        profile = Profile.objects.filter(username=username).first()
        if not profile:
            self.stderr.write(self.style.ERROR(f'Profile not found for username: {username}'))
            return

        now = timezone.now()

        event, _ = MarketplaceEvent.objects.get_or_create(
            title='Sunrise HIIT Session',
            creator=profile,
            defaults={
                'description': 'A high-energy beginner-friendly morning workout to kickstart your week.',
                'cover_image_url': 'https://images.unsplash.com/photo-1554284126-4b111a53f4fb?auto=format&fit=crop&w=1200&q=80',
                'event_type': 'in_person',
                'location': 'Downtown Studio',
                'start_datetime': now + timedelta(days=5, hours=8),
                'end_datetime': now + timedelta(days=5, hours=9),
                'timezone': 'UTC',
                'capacity': 25,
                'ticket_price_artifacts': {'dumbbell': 3},
                'is_free': False,
                'is_published': True,
                'tags': ['fitness', 'hiit', 'community'],
                'category': 'fitness',
            },
        )

        product, _ = Product.objects.get_or_create(
            name='Performance Resistance Bands',
            affiliate_url='https://shop.example.com/resistance-bands',
            defaults={
                'brand': 'BuddyFit',
                'description': 'A durable set of resistance bands for strength training and full-body mobility.',
                'category': 'equipment',
                'image_url': 'https://images.unsplash.com/photo-1599058917212-679562200477?auto=format&fit=crop&w=1200&q=80',
                'price_display': '2 dumbbells',
                'recommended_by': profile,
                'is_active': True,
                'click_count': 0,
            },
        )

        meal_plan, _ = MealPlan.objects.get_or_create(
            title='Balanced Meal Plan for Active Adults',
            creator=profile,
            defaults={
                'description': 'A 4-week, balanced meal plan designed for active adults looking to maintain energy and build lean muscle.',
                'diet_type': 'balanced',
                'duration_weeks': 4,
                'calorie_range': '1800-2200',
                'price_artifacts': {'dumbbell': 4},
                'preview_day': {'breakfast': 'Oatmeal with fruits', 'lunch': 'Grilled chicken salad', 'dinner': 'Salmon and quinoa'},
                'full_plan': {'week1': 'Balanced meals with lean proteins and vegetables'},
                'shopping_list': ['chicken breast', 'salmon', 'quinoa', 'spinach', 'oats'],
                'is_published': True,
                'purchase_count': 0,
                'average_rating': 4.7,
                'review_count': 8,
            },
        )

        programme, _ = TrainingProgramme.objects.get_or_create(
            title='8-Week Strength and Conditioning Programme',
            creator=profile,
            defaults={
                'description': 'A progressive programme focused on strength, conditioning, and recovery for trainers and athletes.',
                'category': 'strength',
                'duration_weeks': 8,
                'price_artifacts': {'dumbbell': 6},
                'is_published': True,
                'purchase_count': 0,
            },
        )

        self.stdout.write(self.style.SUCCESS('Marketplace seed content created successfully.'))
        self.stdout.write(f'Event: {event.title}')
        self.stdout.write(f'Product: {product.name}')
        self.stdout.write(f'Meal Plan: {meal_plan.title}')
        self.stdout.write(f'Programme: {programme.title}')
