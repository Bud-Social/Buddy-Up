from datetime import timedelta
import random

from django.core.management.base import BaseCommand
from django.utils import timezone

from apps.accounts.models import User
from apps.profiles.models import Profile
from apps.gyms.models import Gym, GymMembership
from apps.sessions.models import TrainerProfile, Availability
from apps.marketplace.models import (
    Shop, ShopMembership, MarketplaceEvent, EventMedia, MealPlan,
    TrainingProgramme, Product, DiscountCode,
)
from apps.feed.models import Post, Comment, Reaction

# ---------------------------------------------------------------------------
# Static assets (Cloudinary URLs already uploaded for the demo events).
# ---------------------------------------------------------------------------
EVENT_IMG_1 = 'https://res.cloudinary.com/dsktkughi/image/upload/v1785522076/marketplace/events/media/akfae3t33vyh9etxecv9.jpg'
EVENT_IMG_2 = 'https://res.cloudinary.com/dsktkughi/image/upload/v1785522328/marketplace/events/media/cn59csoy7j8tga7gabm8.jpg'
EVENT_VID_1 = 'https://res.cloudinary.com/dsktkughi/video/upload/v1785522189/marketplace/events/media/rtylth85dlhxynqpv45t.mp4'
EVENT_VID_2 = 'https://res.cloudinary.com/dsktkughi/video/upload/v1785523300/marketplace/events/media/ctnvpcepyue8m6iekzus.mp4'
EVENT_PROMO = 'https://res.cloudinary.com/dsktkughi/video/upload/v1785522286/marketplace/events/media/tqm2io5lt1qpm3vc6hmo.mp4'

UNSPLASH = {
    'meal': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=1200&q=80',
    'programme': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=1200&q=80',
    'product': 'https://images.unsplash.com/photo-1584735935682-2f2b69dff9d2?auto=format&fit=crop&w=1200&q=80',
    'event': 'https://images.unsplash.com/photo-1554284126-4b111a53f4fb?auto=format&fit=crop&w=1200&q=80',
}


class Command(BaseCommand):
    help = (
        'Populates the database with demo users, gyms, trainer profiles, shops, '
        'marketplace content, events (with media) and feed posts. Idempotent - '
        'safe to run multiple times. Run after `python manage.py migrate` on a '
        'fresh database.'
    )

    def handle(self, *args, **options):
        random.seed(42)
        now = timezone.now()
        self._users_and_profiles()
        trainers = list(Profile.objects.filter(role='trainer'))
        all_profiles = list(Profile.objects.all())
        self._gyms(all_profiles)
        self._trainers(trainers)
        self._shops(trainers)
        self._products(trainers)
        self._meal_plans(trainers)
        self._programmes(trainers)
        self._events(trainers, now)
        self._discount_codes(trainers)
        self._feed(all_profiles)
        self.stdout.write(self.style.SUCCESS('populate_db: done.'))

    # -- 1. Users & profiles -------------------------------------------------
    def _users_and_profiles(self):
        target_emails = [
            'jmbngugimbugua@gmail.com',
            'johnndichu.w@gmail.com',
            'jameskiach7@gmail.com',
            'rockcerion42c@gmail.com',
        ]
        high_balance = {
            'dumbbell': 5500, 'barbell': 500, 'burpee': 200, 'squat': 50,
            'sprint': 10, 'pr': 5, 'champion': 2,
        }
        for i, email in enumerate(target_emails):
            username = email.split('@')[0]
            user, created = User.objects.get_or_create(
                email=email, defaults={'is_active': True, 'email_verified': True})
            if created:
                user.set_password('password123')
                user.save()
            Profile.objects.update_or_create(
                user=user,
                defaults={
                    'username': username,
                    'display_name': username.replace('.', ' ').replace('_', ' ').title(),
                    'role': 'trainer' if i < 2 else 'user',
                    'bio': 'Fitness enthusiast and platform early adopter. Loves pushing limits.',
                    'artifact_balance': dict(high_balance),
                    'creator_balance': {'dumbbell': 320},
                    'verification_status': 'email',
                    'location_city': 'Nairobi' if i % 2 == 0 else 'London',
                    'location_country': 'Kenya' if i % 2 == 0 else 'UK',
                })
            self.stdout.write(self.style.SUCCESS(f'  + user: {email}'))

        roles = ['user', 'user', 'user', 'trainer', 'practitioner']
        for i in range(1, 15):
            role = random.choice(roles)
            email = f'user{i}_{role}@example.com'
            user, _ = User.objects.get_or_create(
                email=email, defaults={'is_active': True, 'email_verified': True})
            user.set_password('password123')
            user.save()
            Profile.objects.update_or_create(
                user=user,
                defaults={
                    'username': f'user{i}_{role}',
                    'display_name': f'Demo {role.title()} {i}',
                    'role': role,
                    'bio': f'Just a regular {role} trying to stay fit.',
                    'artifact_balance': {'dumbbell': random.randint(100, 1000), 'barbell': random.randint(0, 50)},
                    'creator_balance': {'dumbbell': 150} if role == 'trainer' else {},
                    'verification_status': 'email' if role == 'user' else 'trainer',
                })

    # -- 2. Gyms -------------------------------------------------------------
    def _gyms(self, all_profiles):
        gyms_data = [
            {'name': 'Iron Palace', 'category': 'strength', 'city': 'Nairobi'},
            {'name': 'Zen Flow Yoga', 'category': 'yoga', 'city': 'London'},
            {'name': 'Urban Fitness', 'category': 'fitness', 'city': 'Nairobi'},
            {'name': 'CrossFit Central', 'category': 'mixed', 'city': 'London'},
            {'name': 'Cardio Core', 'category': 'cardio', 'city': 'New York'},
        ]
        for i, g in enumerate(gyms_data):
            owner = random.choice(all_profiles)
            gym, created = Gym.objects.get_or_create(
                handle=f'gym-{i + 1}',
                defaults={
                    'name': g['name'],
                    'description': f"Welcome to {g['name']}. The best {g['category']} gym.",
                    'category': g['category'],
                    'location_city': g['city'],
                    'access_type': 'public' if i % 2 == 0 else 'private',
                    'monthly_fee_artifacts': {'dumbbell': 500} if i % 2 == 0 else {},
                    'is_verified': True,
                })
            if created:
                self.stdout.write(self.style.SUCCESS(f'  + gym: {g["name"]}'))
            GymMembership.objects.get_or_create(
                gym=gym, member=owner,
                defaults={'role': 'owner', 'subscription_active': True})
            for p in random.sample(all_profiles, min(5, len(all_profiles))):
                GymMembership.objects.get_or_create(
                    gym=gym, member=p,
                    defaults={'role': 'member', 'subscription_active': True})

    # -- 3. Trainer profiles & availability ----------------------------------
    def _trainers(self, trainers):
        for t in trainers:
            t_prof, created = TrainerProfile.objects.get_or_create(
                profile=t,
                defaults={
                    'specialties': ['Weight Loss', 'Strength Training', 'HIIT'],
                    'years_experience': random.randint(2, 10),
                    'session_types': ['1on1_live', 'group_live', 'async'],
                    'pricing': {'1on1_live': {'dumbbell': 100}, 'group_live': {'dumbbell': 50}},
                    'average_rating': round(random.uniform(3.5, 5.0), 1),
                    'review_count': random.randint(5, 50),
                })
            if created:
                self.stdout.write(self.style.SUCCESS(f'  + trainer: {t.user.email}'))
            for day in range(1, 6):
                Availability.objects.get_or_create(
                    trainer=t_prof, day_of_week=day, start_time='09:00:00',
                    defaults={'end_time': '17:00:00'})

    # -- 4. Shops (one per trainer) ------------------------------------------
    def _shops(self, trainers):
        for t in trainers:
            handle = f"{t.username}-shop".replace('.', '-').replace('_', '-')
            shop, created = Shop.objects.get_or_create(
                handle=handle,
                defaults={
                    'name': f"{t.display_name}'s Shop",
                    'description': f'Curated fitness products from {t.display_name}.',
                    'category': 'fitness',
                    'logo_url': '',
                    'contact_email': t.user.email,
                    'is_active': True,
                })
            if created:
                self.stdout.write(self.style.SUCCESS(f'  + shop: {shop.name}'))
            ShopMembership.objects.get_or_create(
                shop=shop, profile=t, defaults={'role': 'owner'})

    # -- 5. Products (attached to shops) -------------------------------------
    def _products(self, trainers):
        products = [
            ('Whey Protein 1', 'supplement', '$29.99', 'High quality protein powder for post-workout recovery.'),
            ('Whey Protein 2', 'supplement', '$29.99', 'High quality protein powder for post-workout recovery.'),
            ('Whey Protein 3', 'supplement', '$29.99', 'High quality protein powder for post-workout recovery.'),
            ('Whey Protein 4', 'supplement', '$29.99', 'High quality protein powder for post-workout recovery.'),
            ('Whey Protein 5', 'supplement', '$29.99', 'High quality protein powder for post-workout recovery.'),
        ]
        shops = list(Shop.objects.all())
        if not shops:
            return
        for name, category, price, description in products:
            shop = random.choice(shops)
            Product.objects.get_or_create(
                name=name, shop=shop,
                defaults={
                    'brand': 'Optimum Nutrition',
                    'category': category,
                    'description': description,
                    'affiliate_url': 'https://example.com/product',
                    'image_url': UNSPLASH['product'],
                    'price_display': price,
                    'is_active': True,
                    'click_count': 0,
                })

    # -- 6. Meal plans --------------------------------------------------------
    def _meal_plans(self, trainers):
        for i in range(5):
            trainer = random.choice(trainers)
            MealPlan.objects.get_or_create(
                title=f'Healthy Diet Plan {i + 1}',
                creator=trainer,
                defaults={
                    'diet_type': random.choice([c[0] for c in MealPlan.DIET_TYPES]),
                    'description': 'A comprehensive meal plan.',
                    'cover_image_url': UNSPLASH['meal'],
                    'price_artifacts': {'dumbbell': 200},
                    'duration_weeks': 4,
                    'meals_per_day': 3,
                    'calorie_range': '1800-2200',
                    'is_published': True,
                    'purchase_count': random.randint(0, 20),
                    'average_rating': round(random.uniform(3.5, 5.0), 1),
                    'review_count': random.randint(0, 10),
                })

    # -- 7. Programmes --------------------------------------------------------
    def _programmes(self, trainers):
        for i in range(5):
            trainer = random.choice(trainers)
            TrainingProgramme.objects.get_or_create(
                title=f'Strength Builder {i + 1}',
                creator=trainer,
                defaults={
                    'category': 'Strength',
                    'description': 'Build muscle and strength.',
                    'cover_image_url': UNSPLASH['programme'],
                    'price_artifacts': {'dumbbell': 300},
                    'duration_weeks': 8,
                    'sessions_per_week': 3,
                    'is_published': True,
                    'purchase_count': random.randint(0, 15),
                })

    # -- 8. Events (12 past bootcamps + 5 upcoming with media) ---------------
    def _events(self, trainers, now):
        trainers = list(trainers)
        for title_no in range(1, 6):
            for j, trainer in enumerate(trainers[:2]):
                start = now - timedelta(days=20 - title_no + j)
                MarketplaceEvent.objects.get_or_create(
                    title=f'Fitness Bootcamp {title_no}',
                    creator=trainer,
                    defaults={
                        'description': 'Join us for an intense bootcamp session.',
                        'event_type': 'online' if title_no % 2 == 0 else 'in_person',
                        'location': '' if title_no % 2 == 0 else 'Downtown Studio',
                        'start_datetime': start,
                        'end_datetime': start + timedelta(hours=2),
                        'ticket_price_artifacts': {'dumbbell': 50} if title_no % 2 != 0 else {},
                        'is_free': title_no % 2 == 0,
                        'category': 'Bootcamp',
                        'capacity': 50,
                        'is_published': True,
                        'attendee_count': random.randint(5, 45),
                    })

        upcoming = [
            dict(
                title='Fitness Bootcamp 6',
                creator=trainers[0], event_type='online', location='', days=3, hour=10,
                category='Bootcamp', capacity=50, is_free=True,
                ticket_price_artifacts={}, ticket_tiers=[], early_bird=False,
                agenda=[
                    {'time': '10:00', 'title': 'Warm-up', 'description': 'Mobility and dynamic stretches', 'speaker': 'Trainer'},
                    {'time': '10:15', 'title': 'Main circuit', 'description': '5 rounds of full-body strength + cardio', 'speaker': 'Trainer'},
                    {'time': '10:50', 'title': 'Cool down', 'description': 'Stretching and Q&A', 'speaker': 'Trainer'},
                ],
                cancellation_policy='Free event: cancel anytime up to 1 hour before start.',
                media=[EVENT_IMG_1, EVENT_IMG_2, EVENT_VID_1], promo=EVENT_PROMO,
            ),
            dict(
                title='Morning Yoga Flow',
                creator=trainers[1], event_type='in_person', location='Buddy-Up Studio, 12 Fitness Lane',
                days=5, hour=7, category='Yoga', capacity=25, is_free=False,
                ticket_price_artifacts={'buddy_token': 10},
                ticket_tiers=[
                    {'name': 'General', 'price_artifacts': {'buddy_token': 10}, 'capacity': 20, 'description': 'Standard entry'},
                    {'name': 'Mat + Towel', 'price_artifacts': {'buddy_token': 15}, 'capacity': 5, 'description': 'Includes mat and towel rental'},
                ],
                early_bird=True, early_bird_deadline_days=3,
                early_bird_price_artifacts={'buddy_token': 7},
                agenda=[
                    {'time': '07:00', 'title': 'Breath work', 'description': 'Pranayama and intention setting', 'speaker': 'Instructor'},
                    {'time': '07:10', 'title': 'Vinyasa flow', 'description': 'Sun salutations and standing poses', 'speaker': 'Instructor'},
                    {'time': '07:45', 'title': 'Hip openers', 'description': 'Deep stretches and relaxation', 'speaker': 'Instructor'},
                ],
                cancellation_policy='Full refund up to 24 hours before start. Within 24 hours, refunds are issued as store credit.',
                media=[EVENT_IMG_2, EVENT_IMG_1, EVENT_VID_2], promo='',
            ),
            dict(
                title='HIIT Challenge Night',
                creator=trainers[2], event_type='online', location='',
                days=7, hour=18, category='HIIT', capacity=100, is_free=False,
                ticket_price_artifacts={'buddy_token': 15},
                ticket_tiers=[
                    {'name': 'Standard', 'price_artifacts': {'buddy_token': 15}, 'capacity': 80, 'description': 'Live participation + replay'},
                    {'name': 'VIP', 'price_artifacts': {'buddy_token': 30}, 'capacity': 20, 'description': '1:1 form check with the coach'},
                ],
                early_bird=True, early_bird_deadline_days=5,
                early_bird_price_artifacts={'buddy_token': 10},
                agenda=[
                    {'time': '18:00', 'title': 'Warm-up', 'description': 'Dynamic mobility circuit', 'speaker': 'Coach'},
                    {'time': '18:20', 'title': 'Challenge 1', 'description': '10 min AMRAP', 'speaker': 'Coach'},
                    {'time': '18:50', 'title': 'Challenge 2', 'description': 'Partner-style intervals', 'speaker': 'Coach'},
                    {'time': '19:15', 'title': 'Final sprint + cooldown', 'description': 'Leaderboard reveal', 'speaker': 'Coach'},
                ],
                cancellation_policy='Refunds accepted until 6 hours before start.',
                media=[EVENT_IMG_1, EVENT_VID_1], promo=EVENT_PROMO,
            ),
            dict(
                title='Nutrition Masterclass',
                creator=trainers[0], event_type='online', location='',
                days=10, hour=12, category='Nutrition', capacity=0, is_free=True,
                ticket_price_artifacts={}, ticket_tiers=[], early_bird=False,
                agenda=[
                    {'time': '12:00', 'title': 'Macro basics', 'description': 'Protein, carbs, fats - how much is enough', 'speaker': 'Nutritionist'},
                    {'time': '12:30', 'title': 'Meal prep in practice', 'description': 'Live demo of a week of meals', 'speaker': 'Nutritionist'},
                    {'time': '13:10', 'title': 'Q&A', 'description': 'Open floor for your questions', 'speaker': 'Nutritionist'},
                ],
                cancellation_policy='Free event: no cancellation needed.',
                media=[EVENT_IMG_2, EVENT_VID_2], promo='',
            ),
            dict(
                title='Strength & Conditioning Workshop',
                creator=trainers[1], event_type='in_person', location='Iron House Gym, 3 Power Road',
                days=12, hour=9, category='Strength', capacity=20, is_free=False,
                ticket_price_artifacts={'gym_day_pass': 1},
                ticket_tiers=[
                    {'name': 'General', 'price_artifacts': {'gym_day_pass': 1}, 'capacity': 20, 'description': 'Workshop + gym access for the day'},
                ],
                early_bird=False,
                agenda=[
                    {'time': '09:00', 'title': 'Lift technique', 'description': 'Squat, bench, deadlift breakdown', 'speaker': 'Coach'},
                    {'time': '10:00', 'title': 'Strength block', 'description': 'Main lifts with feedback', 'speaker': 'Coach'},
                    {'time': '10:40', 'title': 'Finisher', 'description': 'Conditioning circuit', 'speaker': 'Coach'},
                ],
                cancellation_policy='Full refund up to 48 hours before start.',
                media=[EVENT_IMG_1, EVENT_IMG_2, EVENT_VID_2], promo='',
            ),
        ]

        for spec in upcoming:
            start = now.replace(hour=spec['hour'], minute=0, second=0, microsecond=0) + timedelta(days=spec['days'])
            ev, created = MarketplaceEvent.objects.get_or_create(
                title=spec['title'], creator=spec['creator'],
                defaults={
                    'description': spec.get('description', ''),
                    'event_type': spec['event_type'],
                    'location': spec['location'],
                    'start_datetime': start,
                    'end_datetime': start + timedelta(hours=2),
                    'category': spec['category'],
                    'capacity': spec['capacity'],
                    'is_free': spec['is_free'],
                    'ticket_price_artifacts': spec['ticket_price_artifacts'],
                    'ticket_tiers': spec['ticket_tiers'],
                    'early_bird_enabled': spec['early_bird'],
                    'early_bird_deadline': start - timedelta(days=spec.get('early_bird_deadline_days', 2)) if spec['early_bird'] else None,
                    'early_bird_price_artifacts': spec.get('early_bird_price_artifacts', {}),
                    'agenda': spec['agenda'],
                    'cancellation_policy': spec['cancellation_policy'],
                    'cover_image_url': spec['media'][0],
                    'gallery_urls': spec['media'][1:],
                    'promo_video_url': spec['promo'],
                    'is_published': True,
                })
            if created:
                self.stdout.write(self.style.SUCCESS(f"  + event: {spec['title']}"))
            self._event_media(ev, spec['media'], spec['promo'])

    def _event_media(self, event, urls, promo):
        if event.media.count() == 0:
            for i, url in enumerate(urls):
                media_type = 'video' if url.lower().endswith(('.mp4', '.webm', '.mov')) else 'image'
                EventMedia.objects.create(
                    event=event, media_type=media_type, url=url,
                    thumbnail_url=url if media_type == 'image' else '',
                    alt_text='' if media_type == 'video' else 'cover',
                    sort_order=i)

    # -- 9. Discount codes ----------------------------------------------------
    def _discount_codes(self, trainers):
        creator = trainers[0]
        codes = [
            dict(code='LAUNCH10', discount_type='percentage', discount_pct=10,
                 description='10% off for early adopters', campaign='launch',
                 valid_until_days=60, usage_limit=500),
            dict(code='SUMMER15', discount_type='percentage', discount_pct=15,
                 description='Summer promo - 15% off everything', campaign='summer',
                 valid_until_days=90, usage_limit=1000),
            dict(code='FREEPASS', discount_type='fixed_artifacts', discount_pct=0,
                 discount_artifacts={'gym_day_pass': 1},
                 description='Free day pass with any purchase', campaign='gyms',
                 valid_until_days=30, usage_limit=200),
        ]
        for c in codes:
            DiscountCode.objects.get_or_create(
                code=c['code'],
                defaults={
                    'creator': creator,
                    'discount_type': c['discount_type'],
                    'discount_pct': c['discount_pct'],
                    'discount_artifacts': c.get('discount_artifacts', {}),
                    'code_type': 'text',
                    'description': c['description'],
                    'campaign': c['campaign'],
                    'valid_from': timezone.now(),
                    'valid_until': timezone.now() + timedelta(days=c['valid_until_days']),
                    'usage_limit': c['usage_limit'],
                    'max_uses_per_user': 1,
                    'min_purchase_artifacts': {'dumbbell': 0},
                    'is_active': True,
                })
        self.stdout.write(self.style.SUCCESS(f'  + discount codes for {creator.user.email}'))

    # -- 10. Feed posts --------------------------------------------------------
    def _feed(self, all_profiles):
        for i in range(15):
            author = random.choice(all_profiles)
            post, _ = Post.objects.get_or_create(
                author=author,
                body=f"Just crushed my workout today! Feeling great. #fitness #workout{i}",
                defaults={'post_type': 'text', 'visibility': 'public'},
            )
            for _ in range(random.randint(1, 4)):
                commenter = random.choice(all_profiles)
                if commenter != author:
                    Comment.objects.get_or_create(
                        post=post, author=commenter,
                        defaults={'body': 'Awesome job! Keep it up'})
                    Reaction.objects.get_or_create(
                        post=post, author=commenter,
                        defaults={'reaction_type': random.choice(['fire', 'heart', 'clap', 'muscle'])})
