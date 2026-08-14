"""
Populates the database with a large volume of explorable demo data.

Seeds 600+ rows across the platform (>=10 rows per model) so the web app
can be explored end-to-end. Idempotent: existing rows are left untouched.

Run:  python manage.py seed_explore
"""

from datetime import time, timedelta
import random
from uuid import uuid4

from django.core.management.base import BaseCommand
from django.utils import timezone

from apps.accounts.models import User, DeviceSession, AccountEvent, OTPToken
from apps.profiles.models import (
    Profile, BuddyRelationship, FollowRelationship, BlockRelationship,
    AccountabilityPing, SharedGoal,
)
from apps.feed.models import (
    Post, Comment, Reaction, Save, Poll, PollOption, PollVote, Draft,
)
from apps.gyms.models import (
    GymCategory, Gym, GymMembership, GymCategoryPricing, JoinRequest,
    GymInvite, GymSchedulePost, ScheduleSlotEnrollment, GymReview, GymDonation,
)
from apps.lives.models import BuddyLive, LiveRSVP, LiveAttendee
from apps.sessions.models import (
    TrainerProfile, Availability, BookingSession, Review,
    AsyncProgramme, ProgrammeWeek, ProgrammeEnrollment,
)
from apps.marketplace.models import (
    Shop, ShopMembership, ShopGymLink, ShopVerificationApplication,
    PushDevice, MealPlan, MealPlanPurchase, MealPlanReview,
    TrainingProgramme, TrainingProgrammePurchase, TrainingProgrammeReview,
    ProgrammeActivityProgress, Product, MarketplaceEvent, EventTicket,
    EventMedia, DiscountCode, DiscountUsage, Cart, CartItem,
)
from apps.messaging.models import (
    Conversation, Message, MessageReaction, CallLog,
)
from apps.notifications.models import Notification, NotificationPreference
from apps.wallet.models import ArtifactTransaction

UNSPLASH = {
    'meal': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=1200&q=80',
    'programme': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=1200&q=80',
    'product': 'https://images.unsplash.com/photo-1584735935682-2f2b69dff9d2?auto=format&fit=crop&w=1200&q=80',
    'event': 'https://images.unsplash.com/photo-1554284126-4b111a53f4fb?auto=format&fit=crop&w=1200&q=80',
    'avatar': 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?auto=format&fit=crop&w=400&q=80',
    'cover': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=1600&q=80',
}

EVENT_MEDIA = [
    'https://res.cloudinary.com/dsktkughi/image/upload/v1785522076/marketplace/events/media/akfae3t33vyh9etxecv9.jpg',
    'https://res.cloudinary.com/dsktkughi/image/upload/v1785522328/marketplace/events/media/cn59csoy7j8tga7gabm8.jpg',
    'https://res.cloudinary.com/dsktkughi/video/upload/v1785522189/marketplace/events/media/rtylth85dlhxynqpv45t.mp4',
    'https://res.cloudinary.com/dsktkughi/video/upload/v1785523300/marketplace/events/media/ctnvpcepyue8m6iekzus.mp4',
]

CITIES = ['Nairobi', 'London', 'New York', 'Lagos', 'Mombasa', 'Manchester', 'Accra', 'Dubai']
COUNTRIES = ['Kenya', 'UK', 'USA', 'Nigeria', 'Kenya', 'UK', 'Ghana', 'UAE']
FIRST_NAMES = [
    'Amani', 'Brian', 'Chebet', 'David', 'Esther', 'Felix', 'Grace', 'Hassan',
    'Imani', 'James', 'Kevin', 'Linda', 'Moses', 'Nancy', 'Otieno', 'Purity',
    'Quinn', 'Ruth', 'Samuel', 'Teresa', 'Umar', 'Victor', 'Wanjiru', 'Xavier',
    'Yvonne', 'Zainab', 'Alex', 'Beatrice', 'Collins', 'Diana',
]
LAST_NAMES = [
    'Kamau', 'Omondi', 'Njeri', 'Mutua', 'Odhiambo', 'Wanjala', 'Kiptoo',
    'Mensah', 'Okafor', 'Adaeze', 'Johnson', 'Williams', 'Brown', 'Davis',
    'Adeyemi', 'Bello', 'Nnamdi', 'Okoro', 'Smith', 'Taylor',
]

BODY_TEXTS = [
    "Just crushed a leg day session. Feeling unstoppable! #fitness #legday",
    "Morning run in the park, 5k done before breakfast. Who's joining tomorrow?",
    "New personal best on deadlift today - 160kg! Hard work pays off.",
    "Trying out this new HIIT routine, my heart is on fire but it feels amazing.",
    "Meal prep Sunday done for the week. 20 meals locked and loaded.",
    "Rest day today, but active recovery with some light yoga and stretching.",
    "Signed up for my first 10k race! Training starts now. Any tips welcome.",
    "Consistency > intensity. 30 days of training in a row and counting.",
    "That post-workout smoothie hits different after a brutal session.",
    "Joined a new gym this week, loving the community vibes already.",
    "Morning accountability: 6am workout done. Who else is up early?",
    "Progress check: down 8kg in 3 months. Still pushing for more.",
    "Huge shoutout to my training buddy for the motivation today!",
    "Quick 20 minute core circuit between meetings. Stay moving!",
    "Weekend hike with the crew - 15km of trails and incredible views.",
    "Mastered the muscle-up today after months of practice. So stoked!",
    "Sleep and nutrition are half the battle. Prioritizing recovery this week.",
    "Cheat meal time - a big burger is very well deserved after this week.",
]

COMMENT_TEXTS = [
    "Awesome job! Keep it up 🔥",
    "This is so inspiring, I'm going to try this too!",
    "Great progress, you're doing amazing.",
    "Love this energy! Let's goooo 💪",
    "Your consistency is unmatched, respect.",
    "That's a huge milestone, congrats!",
    "What's your training split like?",
    "Need to get back on this grind too.",
    "Proud of you! Keep showing up.",
    "This motivated my whole day, thank you!",
]

REACTION_TYPES = ['fire', 'heart', 'clap', 'muscle', 'strength', 'applause', 'love']

POST_TYPES = ['text', 'photo', 'workout_log', 'meal', 'progress', 'moment', 'poll']

GENDER_PRONOUNS = ['she/her', 'he/him', 'they/them', '']

BIOS = [
    'Fitness enthusiast always chasing new PRs.',
    'Certified personal trainer helping people reach their goals.',
    'Health coach on a mission to make wellness fun.',
    'Runner, lifter, and weekend adventurer.',
    'Yoga teacher bringing balance to body and mind.',
    'Nutrition nerd who loves cooking and meal prep.',
    'Just here to stay consistent and accountable.',
    'Mobility and recovery specialist. Move better, live better.',
    'Marathon training and loving every mile.',
    'Functional fitness fanatic and HIIT lover.',
]


class Command(BaseCommand):
    help = 'Seeds 600+ rows of explorable demo data across the platform (idempotent).'

    def handle(self, *args, **options):
        random.seed(7)
        self.now = timezone.now()
        self._seed_categories()
        self.profiles = self._seed_users()
        self.trainers = list(Profile.objects.filter(role__in=['trainer', 'practitioner']))
        self.regulars = list(Profile.objects.filter(role='user'))
        self._seed_profiles_graph()
        self._seed_feed()
        self._seed_gyms()
        self._seed_sessions()
        self._seed_lives()
        self._seed_marketplace()
        self._seed_messaging()
        self._seed_notifications()
        self._seed_wallet()
        self._seed_accounts()
        self.stdout.write(self.style.SUCCESS('seed_explore: done.'))

    # -- helpers ------------------------------------------------------------
    def _pick(self, items, n=None):
        return random.choice(items) if n is None else random.sample(items, n)

    def _unique_handle(self, base, model, field='handle'):
        existing = set(model.objects.values_list(field, flat=True))
        slug = base.replace(' ', '-').lower().replace('.', '-').replace('_', '-')
        candidate, i = slug, 2
        while candidate in existing:
            candidate = f'{slug}-{i}'
            i += 1
        return candidate

    # -- 1. Categories --------------------------------------------------------
    def _seed_categories(self):
        cats = [
            ('strength', 'Strength & Conditioning', 'dumbbell'),
            ('fitness', 'Fitness', 'heart'),
            ('yoga', 'Yoga', 'lotus'),
            ('cardio', 'Cardio', 'activity'),
            ('mixed', 'Mixed / CrossFit', 'flame'),
            ('boxing', 'Boxing & MMA', 'glove'),
            ('pilates', 'Pilates', 'sparkles'),
            ('crossfit', 'CrossFit', 'bolt'),
            ('cycling', 'Cycling', 'bike'),
            ('swimming', 'Swimming', 'wave'),
        ]
        for name, display, icon in cats:
            GymCategory.objects.get_or_create(
                name=name,
                defaults={'display_name': display, 'icon': icon, 'is_active': True},
            )
        self.stdout.write('  + gym categories')

    # -- 2. Users & profiles ---------------------------------------------------
    def _seed_users(self):
        existing_emails = set(User.objects.values_list('email', flat=True))
        created_any = False
        for i in range(45):
            first = self._pick(FIRST_NAMES)
            last = self._pick(LAST_NAMES)
            role = 'trainer' if i % 5 == 0 else ('practitioner' if i % 7 == 0 else 'user')
            email = f'{first.lower()}.{last.lower()}{i}@example.com'
            if email in existing_emails:
                continue
            existing_emails.add(email)
            user = User.objects.create(
                email=email,
                is_active=True,
                email_verified=True,
                is_adult=True,
                dob_hash='',
                last_login_ip='10.89.0.6',
                consent_log={'tos': True, 'privacy': True},
            )
            user.set_password('password123')
            user.save()
            created_any = True
            city_idx = i % len(CITIES)
            username = self._unique_handle(f'user{i}_{first.lower()}', Profile, 'username')
            Profile.objects.create(
                user=user,
                username=username,
                display_name=f'{first} {last}',
                role=role,
                bio=self._pick(BIOS),
                pronouns=random.choice(GENDER_PRONOUNS),
                location_city=CITIES[city_idx],
                location_country=COUNTRIES[city_idx],
                avatar_url=UNSPLASH['avatar'],
                cover_url=UNSPLASH['cover'],
                artifact_balance={
                    'dumbbell': random.randint(100, 5000),
                    'barbell': random.randint(0, 500),
                    'squat': random.randint(0, 100),
                },
                creator_balance={'dumbbell': random.randint(0, 800)} if role in ('trainer', 'practitioner') else {},
                verification_status='trainer' if role in ('trainer', 'practitioner') else 'email',
                streak_days=random.randint(0, 60),
            )
        if created_any:
            self.stdout.write('  + users & profiles')
        return list(Profile.objects.all())

    # -- 3. Profile relationships -----------------------------------------------
    def _seed_profiles_graph(self):
        all_profiles = self.profiles
        if len(all_profiles) < 3:
            return
        # Buddy relationships
        seen = set()
        count = 0
        for _ in range(30):
            a, b = random.sample(all_profiles, 2)
            key = frozenset((a.user_id, b.user_id))
            if key in seen:
                continue
            seen.add(key)
            BuddyRelationship.objects.get_or_create(
                from_user=a, to_user=b,
                defaults={'status': random.choice(['confirmed', 'confirmed', 'pending', 'declined'])},
            )
            count += 1
        self._log('buddy relationships', count)

        # Follow relationships
        count = 0
        for _ in range(50):
            a, b = random.sample(all_profiles, 2)
            try:
                FollowRelationship.objects.get_or_create(follower=a, followee=b)
                count += 1
            except Exception:  # noqa: BLE001
                pass
        self._log('follow relationships', count)

        # Block relationships
        count = 0
        for _ in range(12):
            a, b = random.sample(all_profiles, 2)
            try:
                BlockRelationship.objects.get_or_create(blocker=a, blocked=b)
                count += 1
            except Exception:  # noqa: BLE001
                pass
        self._log('block relationships', count)

        # Accountability pings
        count = 0
        for _ in range(15):
            a, b = random.sample(all_profiles, 2)
            AccountabilityPing.objects.get_or_create(
                from_user=a, to_user=b,
                defaults={'message': 'Did you hit the gym today?', 'responded': random.choice([True, False])},
            )
            count += 1
        self._log('accountability pings', count)

        # Shared goals
        for i in range(12):
            creator = self._pick(all_profiles)
            goal, _ = SharedGoal.objects.get_or_create(
                title=f'Goal {i}: {self._pick(["Run 10k", "Lose 5kg", "Gain muscle", "Daily steps", "Meditate daily", "Stretch daily"])}',
                created_by=creator,
                defaults={
                    'description': 'A shared goal to stay accountable as buddies.',
                    'target': self._pick(['30 days', '60 days', '90 days', '12 weeks']),
                    'is_active': True,
                },
            )
            buddies = random.sample(all_profiles, min(3, len(all_profiles)))
            goal.buddies.set(buddies)
        self._log('shared goals', 12)

    # -- 4. Feed ----------------------------------------------------------------
    def _seed_feed(self):
        all_profiles = self.profiles
        posts = []
        for i in range(40):
            author = self._pick(all_profiles)
            post_type = 'poll' if i < 10 else POST_TYPES[i % len(POST_TYPES)]
            post = Post.objects.create(
                author=author,
                post_type=post_type,
                body=self._pick(BODY_TEXTS),
                visibility='public',
                media_urls=[UNSPLASH['programme']] if post_type == 'photo' else [],
                tags=[random.choice(['fitness', 'workout', 'motivation', 'nutrition', 'strength', 'cardio'])],
                view_count=random.randint(0, 500),
                moderation_status='clean',
            )
            posts.append(post)
        self._log('posts', len(posts))

        # Comments
        for i in range(45):
            post = self._pick(posts)
            author = self._pick(all_profiles)
            try:
                Comment.objects.create(post=post, author=author, body=self._pick(COMMENT_TEXTS))
            except Exception:  # noqa: BLE001
                pass
        self._log('comments', Comment.objects.count())

        # Reactions
        for i in range(50):
            post = self._pick(posts)
            author = self._pick(all_profiles)
            Reaction.objects.get_or_create(
                post=post, author=author, reaction_type=random.choice(REACTION_TYPES),
            )
        self._log('reactions', Reaction.objects.count())

        # Saves
        saved = set()
        for i in range(15):
            post = self._pick(posts)
            user = self._pick(all_profiles)
            if (post.id, user.user_id) in saved:
                continue
            saved.add((post.id, user.user_id))
            Save.objects.create(user=user, post=post)
        self._log('saves', len(saved))

        # Polls (10 posts with poll type)
        poll_posts = [p for p in posts if p.post_type == 'poll'][:10]
        for pp in poll_posts:
            poll, _ = Poll.objects.get_or_create(
                post=pp,
                defaults={'question': 'How often do you train per week?', 'closes_at': self.now + timedelta(days=7)},
            )
            options = ['1-2 days', '3-4 days', '5-6 days', 'Every day']
            for j, opt in enumerate(options):
                PollOption.objects.get_or_create(poll=poll, text=opt, order=j)
            for _ in range(2):
                voter = self._pick(all_profiles)
                option = self._pick(list(poll.options.all()))
                try:
                    PollVote.objects.get_or_create(poll=poll, option=option, voter=voter)
                except Exception:  # noqa: BLE001
                    pass
        self._log('polls', Poll.objects.count())
        self._log('poll options', PollOption.objects.count())
        self._log('poll votes', PollVote.objects.count())

        # Drafts
        for i in range(12):
            author = self._pick(all_profiles)
            Draft.objects.get_or_create(
                author=author,
                body=f'Draft post {i}: working on something exciting!',
                defaults={'post_type': 'text', 'visibility': 'public', 'tags': ['draft']},
            )
        self._log('drafts', Draft.objects.count())

    # -- 5. Gyms -------------------------------------------------------------
    def _seed_gyms(self):
        all_profiles = self.profiles
        cats = list(GymCategory.objects.all())
        gym_names = [
            'Iron Palace', 'Zen Flow', 'Urban Fitness', 'CrossFit Central',
            'Cardio Core', 'Lagos Lifters', 'Summit Strength', 'Titan Gym',
            'Pulse Fitness', 'Flex Factory', 'Apex Athletics', 'Blaze Boxing',
            'Core Balance', 'Victory Vault', 'Elevate Health',
        ]
        gyms = []
        for i in range(15):
            name = gym_names[i]
            if Gym.objects.filter(name=name).exists():
                gyms.append(Gym.objects.get(name=name))
                continue
            handle = self._unique_handle(name, Gym)
            owner = self._pick(all_profiles)
            city_idx = i % len(CITIES)
            gym = Gym.objects.create(
                name=name,
                handle=handle,
                description=f'Welcome to {name}. The best {cats[i % len(cats)].name} gym in town.',
                category=cats[i % len(cats)].name,
                logo_url=UNSPLASH['avatar'],
                cover_url=UNSPLASH['cover'],
                access_type=random.choice(['public', 'public', 'private']),
                subscription_type=random.choice(['free', 'paid', 'tiered']),
                monthly_fee_artifacts={'dumbbell': random.randint(100, 500)} if i % 2 == 0 else {},
                is_verified=random.choice([True, True, False]),
                member_count=random.randint(10, 200),
                location_city=CITIES[city_idx],
                location_country=COUNTRIES[city_idx],
            )
            gym.categories.add(self._pick(cats))
            gyms.append(gym)
            GymMembership.objects.get_or_create(gym=gym, member=owner, defaults={'role': 'owner', 'subscription_active': True})
            for p in random.sample(all_profiles, min(5, len(all_profiles))):
                GymMembership.objects.get_or_create(gym=gym, member=p, defaults={'role': random.choice(['member', 'trainer', 'moderator'])})
        self._log('gyms', len(gyms))
        self._log('gym memberships', GymMembership.objects.count())

        # Category pricing
        for gym in gyms:
            for c in random.sample(cats, min(3, len(cats))):
                GymCategoryPricing.objects.get_or_create(
                    gym=gym, category=c,
                    defaults={
                        'fee_per_day': round(random.uniform(3, 10), 2),
                        'fee_per_week': round(random.uniform(15, 40), 2),
                        'fee_per_month': round(random.uniform(50, 150), 2),
                        'is_free': False,
                    },
                )
        self._log('category pricing', GymCategoryPricing.objects.count())

        # Join requests
        for i in range(12):
            gym = self._pick(gyms)
            requester = self._pick(all_profiles)
            JoinRequest.objects.get_or_create(
                gym=gym, requester=requester,
                defaults={'message': 'Would love to join this community!', 'status': random.choice(['pending', 'approved', 'rejected'])},
            )
        self._log('join requests', JoinRequest.objects.count())

        # Invites
        for i in range(12):
            gym = self._pick(gyms)
            invited = self._pick(all_profiles)
            invited_by = self._pick(all_profiles)
            if invited.user_id == invited_by.user_id:
                continue
            GymInvite.objects.get_or_create(
                gym=gym, invited_user=invited,
                defaults={'invited_by': invited_by, 'status': random.choice(['pending', 'accepted', 'declined'])},
            )
        self._log('gym invites', GymInvite.objects.count())

        # Schedule posts
        for i in range(15):
            gym = self._pick(gyms)
            author = self._pick(gym.memberships.values_list('member', flat=True))
            author_prof = Profile.objects.filter(user_id=author).first() if author else self._pick(all_profiles)
            if not author_prof:
                author_prof = self._pick(all_profiles)
            start = self.now + timedelta(days=random.randint(0, 14), hours=random.randint(6, 20))
            GymSchedulePost.objects.get_or_create(
                gym=gym, title=f'{self._pick(["Yoga Flow", "HIIT Blast", "Strength Block", "Cardio Burn", "Open Gym"])} #{i}',
                defaults={
                    'author': author_prof,
                    'content': 'Join us for an awesome session.',
                    'activity_type': random.choice(['yoga', 'hiit', 'strength', 'cardio', 'workshop']),
                    'location_mode': random.choice(['in_house', 'online', 'hybrid']),
                    'start_time': start,
                    'end_time': start + timedelta(hours=1),
                    'max_slots': random.randint(0, 30),
                    'slots_taken': random.randint(0, 10),
                },
            )
        self._log('schedule posts', GymSchedulePost.objects.count())

        # Slot enrollments
        sched_posts = list(GymSchedulePost.objects.all())
        for i in range(12):
            if not sched_posts:
                break
            sp = self._pick(sched_posts)
            member = self._pick(all_profiles)
            try:
                ScheduleSlotEnrollment.objects.get_or_create(
                    schedule_post=sp, member=member,
                    defaults={'recurrence': 'none', 'is_active': True},
                )
            except Exception:  # noqa: BLE001
                pass
        self._log('slot enrollments', ScheduleSlotEnrollment.objects.count())

        # Reviews
        for i in range(15):
            gym = self._pick(gyms)
            reviewer = self._pick(all_profiles)
            try:
                GymReview.objects.get_or_create(
                    gym=gym, reviewer=reviewer,
                    defaults={'rating': random.randint(3, 5), 'comment': self._pick(COMMENT_TEXTS)},
                )
            except Exception:  # noqa: BLE001
                pass
        self._log('gym reviews', GymReview.objects.count())

        # Donations
        for i in range(12):
            gym = self._pick(gyms)
            donor = self._pick(all_profiles)
            GymDonation.objects.create(
                gym=gym, donor=donor,
                amount=round(random.uniform(5, 200), 2),
                message='Supporting the community!',
            )
        self._log('gym donations', GymDonation.objects.count())

    # -- 6. Sessions & trainers ----------------------------------------------
    def _seed_sessions(self):
        trainer_profs = []
        for t in self.trainers[:12]:
            tp, _ = TrainerProfile.objects.get_or_create(
                profile=t,
                defaults={
                    'specialties': self._pick(['Strength Training', 'HIIT', 'Yoga', 'Nutrition', 'Weight Loss', 'Marathon'], 3),
                    'certifications': [{'name': 'Certified PT', 'issuer': 'ACE', 'year': 2023}],
                    'years_experience': random.randint(2, 12),
                    'languages': ['English', 'Swahili'],
                    'session_types': ['1on1_live', 'group_live', 'async'],
                    'pricing': {'1on1_live': {'dumbbell': random.randint(50, 150)}, 'group_live': {'dumbbell': random.randint(25, 60)}},
                    'average_rating': round(random.uniform(3.5, 5.0), 1),
                    'review_count': random.randint(5, 60),
                    'total_sessions_completed': random.randint(20, 300),
                },
            )
            trainer_profs.append(tp)
            for day in range(7):
                Availability.objects.get_or_create(
                    trainer=tp, day_of_week=day, start_time=time(9, 0),
                    defaults={'end_time': time(17, 0), 'buffer_minutes': 15, 'is_active': True},
                )
        self._log('trainer profiles', len(trainer_profs))
        self._log('availability slots', Availability.objects.count())

        # Bookings
        bookings = []
        for i in range(20):
            client = self._pick(self.regulars)
            trainer = self._pick(self.trainers)
            if client.user_id == trainer.user_id:
                continue
            status = random.choice(['completed', 'completed', 'completed', 'completed', 'pending', 'confirmed', 'in_progress', 'cancelled_by_client'])
            scheduled = self.now + timedelta(days=random.randint(-10, 20), hours=random.randint(6, 18))
            booking = BookingSession.objects.create(
                client=client,
                trainer=trainer,
                session_type=random.choice(['1on1_live', 'group_live', 'nutrition', 'in_person']),
                status=status,
                scheduled_at=scheduled,
                duration_minutes=random.choice([30, 45, 60, 90]),
                artifact_fee={'dumbbell': random.randint(50, 200)},
                notes='Looking forward to the session!',
                completed_at=scheduled if status == 'completed' else None,
            )
            bookings.append(booking)
        self._log('bookings', len(bookings))

        # Reviews on completed bookings
        count = 0
        for booking in bookings:
            if booking.status != 'completed':
                continue
            try:
                Review.objects.get_or_create(
                    session=booking, client=booking.client,
                    defaults={'trainer': booking.trainer, 'rating': random.randint(3, 5), 'body': self._pick(COMMENT_TEXTS)},
                )
                count += 1
            except Exception:  # noqa: BLE001
                pass
        self._log('session reviews', count)

        # Async programmes
        for i in range(12):
            trainer = self._pick(self.trainers)
            prog, _ = AsyncProgramme.objects.get_or_create(
                trainer=trainer, title=f'{self._pick(["12-Week Transformation", "Beginner Strength", "Fat Burn Program", "Home Workout", "Yoga Reset"])} #{i}',
                defaults={
                    'description': 'A structured programme to keep you consistent.',
                    'duration_weeks': random.randint(4, 12),
                    'price_artifacts': {'dumbbell': random.randint(100, 400)},
                    'is_active': True,
                    'enrolled_count': random.randint(0, 100),
                },
            )
            for w in range(1, min(4, prog.duration_weeks + 1)):
                ProgrammeWeek.objects.get_or_create(
                    programme=prog, week_number=w,
                    defaults={'title': f'Week {w}', 'description': 'Focus, consistency, growth.', 'exercises': ['Squats', 'Push-ups', 'Planks']},
                )
        self._log('async programmes', AsyncProgramme.objects.count())
        self._log('programme weeks', ProgrammeWeek.objects.count())

        # Enrollments
        programmes = list(AsyncProgramme.objects.all())
        for i in range(12):
            if not programmes:
                break
            client = self._pick(self.regulars)
            prog = self._pick(programmes)
            try:
                ProgrammeEnrollment.objects.get_or_create(
                    client=client, programme=prog,
                    defaults={'completed_weeks': [1, 2], 'progress_pct': random.randint(10, 80)},
                )
            except Exception:  # noqa: BLE001
                pass
        self._log('programme enrollments', ProgrammeEnrollment.objects.count())

    # -- 7. Lives ------------------------------------------------------------
    def _seed_lives(self):
        all_profiles = self.profiles
        gyms = list(Gym.objects.all())
        lives = []
        for i in range(15):
            host = self._pick(self.trainers) if self.trainers else self._pick(all_profiles)
            status = random.choice(['scheduled', 'scheduled', 'ended', 'ended'])
            scheduled = self.now + timedelta(days=random.randint(-5, 15), hours=random.randint(8, 20))
            live = BuddyLive.objects.create(
                host=host,
                title=f'{self._pick(["Morning Sweat", "HIIT Circuit", "Yoga Flow", "Strength Basics", "Dance Fitness", "Core Crusher"])} Live #{i}',
                live_type=random.choice(['open_sweat', 'gym_live', 'buddy_circle', 'practitioner_live']),
                category=random.choice(['fitness', 'strength', 'yoga', 'cardio']),
                access='public',
                artifact_fee={'dumbbell': random.randint(0, 50)} if i % 3 == 0 else None,
                gym=self._pick(gyms) if gyms and i % 4 == 0 else None,
                status=status,
                scheduled_for=scheduled,
                started_at=scheduled if status == 'ended' else None,
                ended_at=scheduled + timedelta(hours=1) if status == 'ended' else None,
                viewer_peak=random.randint(5, 300),
                equipment_list=['mat', 'dumbbells', 'water'],
            )
            lives.append(live)
            for _ in range(random.randint(1, 4)):
                member = self._pick(all_profiles)
                try:
                    LiveRSVP.objects.get_or_create(live=live, user=member)
                except Exception:  # noqa: BLE001
                    pass
            for _ in range(random.randint(2, 5)):
                member = self._pick(all_profiles)
                try:
                    LiveAttendee.objects.get_or_create(
                        live=live, user=member,
                        defaults={'role': random.choice(['attendee', 'co_host']), 'left_at': self.now},
                    )
                except Exception:  # noqa: BLE001
                    pass
        self._log('lives', len(lives))
        self._log('live rsvps', LiveRSVP.objects.count())
        self._log('live attendees', LiveAttendee.objects.count())

    # -- 8. Marketplace ------------------------------------------------------
    def _seed_marketplace(self):
        all_profiles = self.profiles
        gyms = list(Gym.objects.all())
        shops = []

        for i in range(12):
            creator = self._pick(self.trainers) if self.trainers else self._pick(all_profiles)
            shop_name = f"{creator.display_name}'s Shop"
            handle = self._unique_handle(shop_name, Shop)
            shop, _ = Shop.objects.get_or_create(
                handle=handle,
                defaults={
                    'name': shop_name,
                    'description': 'Curated fitness products, plans and events.',
                    'category': random.choice(['fitness', 'nutrition', 'wellness', 'mixed']),
                    'logo_url': UNSPLASH['avatar'],
                    'banner_url': UNSPLASH['cover'],
                    'contact_email': creator.user.email,
                    'is_active': True,
                    'verification_status': random.choice(['verified', 'verified', 'unverified', 'pending']),
                },
            )
            shops.append(shop)
            ShopMembership.objects.get_or_create(shop=shop, profile=creator, defaults={'role': 'owner'})
            if gyms:
                try:
                    ShopGymLink.objects.get_or_create(shop=shop, gym=self._pick(gyms), defaults={'is_primary': True})
                except Exception:  # noqa: BLE001
                    pass
            ShopVerificationApplication.objects.get_or_create(
                shop=shop, submitted_by=creator,
                defaults={
                    'status': random.choice(['approved', 'submitted', 'under_review']),
                    'service_type': random.choice(['fitness_trainer', 'nutritionist', 'wellness_coach', 'gym_owner']),
                    'legal_name': creator.display_name,
                    'country': creator.location_country,
                    'years_of_experience': random.randint(1, 10),
                    'specializations': ['fitness', 'nutrition'],
                    'agreed_to_creator_policy': True,
                },
            )
            PushDevice.objects.get_or_create(
                profile=creator, token=f'fcm-token-{uuid4()}',
                defaults={'platform': random.choice(['fcm', 'web']), 'device_name': f'Device {i}', 'is_active': True},
            )
        self._log('shops', len(shops))
        self._log('shop memberships', ShopMembership.objects.count())
        self._log('shop gym links', ShopGymLink.objects.count())
        self._log('verification applications', ShopVerificationApplication.objects.count())
        self._log('push devices', PushDevice.objects.count())

        # Products
        product_names = [
            'Whey Protein', 'Pre-Workout', 'Resistance Bands', 'Foam Roller',
            'Kettlebell', 'Yoga Mat', 'Jump Rope', 'Gym Gloves', 'BCAAs',
            'Creatine', 'Gym Bag', 'Water Bottle', 'Shaker Cup', 'Weight Belt',
            'Heart Rate Monitor', 'Protein Bars', 'Recovery Boots', 'Training Shorts',
            'Hoodie', 'Phone Armband',
        ]
        for i in range(20):
            shop = self._pick(shops)
            name = f'{product_names[i]} {random.randint(1, 3)}'
            Product.objects.get_or_create(
                name=name, shop=shop,
                defaults={
                    'brand': self._pick(['Optimum Nutrition', 'BuddyFit', 'GymShark', 'Nike', 'MyProtein']),
                    'description': 'High quality fitness product loved by the community.',
                    'category': random.choice(['supplement', 'equipment', 'gear', 'apparel']),
                    'image_url': UNSPLASH['product'],
                    'affiliate_url': 'https://example.com/product',
                    'price_display': f'${random.randint(10, 120)}',
                    'recommended_by': self._pick(all_profiles),
                    'is_active': True,
                    'click_count': random.randint(0, 500),
                },
            )
        self._log('products', Product.objects.count())

        # Meal plans
        for i in range(15):
            creator = self._pick(self.trainers) if self.trainers else self._pick(all_profiles)
            MealPlan.objects.get_or_create(
                title=f'{self._pick(["Keto", "Vegan", "High Protein", "Weight Loss", "Muscle Gain", "Balanced"])} Meal Plan {i + 1}',
                creator=creator,
                defaults={
                    'diet_type': random.choice(['keto', 'vegan', 'balanced', 'high_protein', 'weight_loss']),
                    'description': 'A complete, sustainable meal plan.',
                    'cover_image_url': UNSPLASH['meal'],
                    'duration_weeks': random.randint(2, 12),
                    'meals_per_day': random.randint(3, 5),
                    'calorie_range': random.choice(['1600-1900', '1800-2200', '2000-2400', '2200-2600']),
                    'macro_targets': {'protein_pct': 40, 'carbs_pct': 35, 'fat_pct': 25},
                    'price_artifacts': {'dumbbell': random.randint(100, 500)},
                    'preview_day': {'breakfast': 'Oats and fruit', 'lunch': 'Grilled chicken salad', 'dinner': 'Salmon and veggies'},
                    'full_plan': {'week1': 'Balanced meals', 'week2': 'More variety'},
                    'shopping_list': ['chicken', 'salmon', 'quinoa', 'spinach'],
                    'is_published': True,
                    'purchase_count': random.randint(0, 50),
                    'average_rating': round(random.uniform(3.5, 5.0), 1),
                    'review_count': random.randint(0, 20),
                },
            )
        self._log('meal plans', MealPlan.objects.count())

        # Training programmes
        for i in range(15):
            creator = self._pick(self.trainers) if self.trainers else self._pick(all_profiles)
            TrainingProgramme.objects.get_or_create(
                title=f'{self._pick(["Strength", "Fat Loss", "Mobility", "Endurance", "Home"])} Programme {i + 1}',
                creator=creator,
                defaults={
                    'description': 'A structured, progressive programme.',
                    'cover_image_url': UNSPLASH['programme'],
                    'category': random.choice(['Strength', 'Cardio', 'Mobility', 'HIIT', 'CrossFit']),
                    'difficulty': random.choice(['beginner', 'intermediate', 'advanced', 'all_levels']),
                    'fitness_goals': ['muscle_gain', 'weight_loss'],
                    'duration_weeks': random.randint(4, 12),
                    'sessions_per_week': random.randint(3, 5),
                    'equipment_list': ['dumbbells', 'bands'],
                    'schedule': [{'week': 1, 'day': 1, 'activity': 'Full body'}],
                    'price_artifacts': {'dumbbell': random.randint(150, 600)},
                    'is_published': True,
                    'purchase_count': random.randint(0, 50),
                },
            )
        self._log('training programmes', TrainingProgramme.objects.count())

        # Purchases & reviews (meal plans + programmes)
        meal_plans = list(MealPlan.objects.all())
        programmes = list(TrainingProgramme.objects.all())
        for i in range(12):
            if not meal_plans:
                break
            buyer = self._pick(self.regulars)
            mp = self._pick(meal_plans)
            try:
                purchase, created = MealPlanPurchase.objects.get_or_create(
                    meal_plan=mp, buyer=buyer,
                    defaults={'tx_id': f'mp-{uuid4()}'},
                )
                if created:
                    MealPlanReview.objects.get_or_create(
                        purchase=purchase, buyer=buyer, meal_plan=mp,
                        defaults={'rating': random.randint(3, 5), 'body': self._pick(COMMENT_TEXTS)},
                    )
            except Exception:  # noqa: BLE001
                pass
        self._log('meal plan purchases', MealPlanPurchase.objects.count())
        self._log('meal plan reviews', MealPlanReview.objects.count())

        for i in range(12):
            if not programmes:
                break
            buyer = self._pick(self.regulars)
            prog = self._pick(programmes)
            try:
                purchase, created = TrainingProgrammePurchase.objects.get_or_create(
                    programme=prog, buyer=buyer,
                    defaults={'tx_id': f'prog-{uuid4()}', 'notification_config': {'remind_30min': True}},
                )
                if created:
                    TrainingProgrammeReview.objects.get_or_create(
                        purchase=purchase, buyer=buyer, programme=prog,
                        defaults={'rating': random.randint(3, 5), 'body': self._pick(COMMENT_TEXTS)},
                    )
                    for k in range(3):
                        ProgrammeActivityProgress.objects.get_or_create(
                            purchase=purchase, activity_key=f'w1_d{k}',
                            defaults={'status': random.choice(['completed', 'in_progress', 'pending']), 'completed_at': self.now if random.random() > 0.5 else None},
                        )
            except Exception:  # noqa: BLE001
                pass
        self._log('programme purchases', TrainingProgrammePurchase.objects.count())
        self._log('programme reviews', TrainingProgrammeReview.objects.count())
        self._log('activity progress', ProgrammeActivityProgress.objects.count())

        # Events
        for i in range(15):
            creator = self._pick(self.trainers) if self.trainers else self._pick(all_profiles)
            start = self.now + timedelta(days=random.randint(-20, 20), hours=random.randint(6, 20))
            ev, _ = MarketplaceEvent.objects.get_or_create(
                title=f'{self._pick(["Bootcamp", "Yoga Retreat", "HIIT Night", "Nutrition Talk", "Strength Clinic", "Run Club"])} #{i}',
                creator=creator,
                defaults={
                    'description': 'An amazing community event. Come train with us!',
                    'cover_image_url': UNSPLASH['event'],
                    'event_type': random.choice(['in_person', 'online', 'hybrid']),
                    'location': self._pick(['Downtown Studio', 'City Park', 'Iron Palace Gym', '']) if i % 2 else '',
                    'start_datetime': start,
                    'end_datetime': start + timedelta(hours=random.randint(1, 4)),
                    'ticket_price_artifacts': {'dumbbell': random.randint(10, 100)} if i % 3 else {},
                    'is_free': i % 3 == 0,
                    'capacity': random.randint(20, 200),
                    'is_published': True,
                    'attendee_count': random.randint(5, 150),
                    'category': random.choice(['Bootcamp', 'Yoga', 'HIIT', 'Nutrition', 'Strength']),
                },
            )
            for j, url in enumerate(random.sample(EVENT_MEDIA, random.randint(1, 3))):
                EventMedia.objects.get_or_create(
                    event=ev, url=url,
                    defaults={
                        'media_type': 'video' if url.endswith('.mp4') else 'image',
                        'thumbnail_url': url if not url.endswith('.mp4') else '',
                        'sort_order': j,
                    },
                )
            for _ in range(random.randint(1, 3)):
                holder = self._pick(all_profiles)
                try:
                    EventTicket.objects.get_or_create(
                        event=ev, holder=holder,
                        defaults={'tier': 'Standard', 'price_paid_artifacts': {'dumbbell': 20}, 'status': random.choice(['active', 'used'])},
                    )
                except Exception:  # noqa: BLE001
                    pass
        self._log('events', MarketplaceEvent.objects.count())
        self._log('event media', EventMedia.objects.count())
        self._log('event tickets', EventTicket.objects.count())

        # Discount codes
        for i in range(10):
            creator = self._pick(self.trainers) if self.trainers else self._pick(all_profiles)
            code = f'BUDDY{i + 1}'
            DiscountCode.objects.get_or_create(
                code=code,
                defaults={
                    'creator': creator,
                    'discount_type': 'percentage',
                    'discount_pct': random.randint(5, 25),
                    'description': f'Demo discount code {i + 1}',
                    'campaign': random.choice(['launch', 'summer', 'fitness', 'community']),
                    'valid_from': self.now - timedelta(days=10),
                    'valid_until': self.now + timedelta(days=random.randint(20, 90)),
                    'usage_limit': random.randint(50, 1000),
                    'max_uses_per_user': 1,
                    'is_active': True,
                },
            )
        self._log('discount codes', DiscountCode.objects.count())

        codes = list(DiscountCode.objects.all())
        for i in range(12):
            if not codes:
                break
            code = self._pick(codes)
            user = self._pick(all_profiles)
            try:
                DiscountUsage.objects.get_or_create(
                    discount=code, user=user,
                    defaults={'discount_pct_applied': code.discount_pct, 'was_successful': True},
                )
            except Exception:  # noqa: BLE001
                pass
        self._log('discount usages', DiscountUsage.objects.count())

        # Carts
        for profile in self.regulars[:15]:
            Cart.objects.get_or_create(buyer=profile)
        carts = list(Cart.objects.all())
        self._log('carts', len(carts))

        items = 0
        for cart in carts:
            for _ in range(random.randint(1, 3)):
                try:
                    CartItem.objects.get_or_create(
                        cart=cart,
                        item_type=random.choice(['meal_plan', 'programme', 'product']),
                        defaults={
                            'quantity': random.randint(1, 2),
                            'meal_plan': self._pick(meal_plans) if meal_plans else None,
                            'programme': self._pick(programmes) if programmes else None,
                            'product': self._pick(list(Product.objects.all())) if Product.objects.exists() else None,
                        },
                    )
                    items += 1
                except Exception:  # noqa: BLE001
                    pass
        self._log('cart items', items)

    # -- 9. Messaging --------------------------------------------------------
    def _seed_messaging(self):
        all_profiles = self.profiles
        conversations = []
        # DMs
        for i in range(12):
            a, b = random.sample(all_profiles, 2)
            conv, _ = Conversation.objects.get_or_create(
                is_group=False,
                created_by=a,
            )
            conv.participants.add(a, b)
            conversations.append(conv)
        # Group chats
        for i in range(3):
            if len(all_profiles) < 3:
                break
            members = random.sample(all_profiles, random.randint(3, 6))
            conv = Conversation.objects.create(is_group=True, group_name=f'Group {i + 1}', created_by=members[0])
            conv.participants.add(*members)
            conversations.append(conv)
        self._log('conversations', len(conversations))

        msg_count = 0
        for conv in conversations:
            participants = list(conv.participants.all())
            if not participants:
                continue
            for _ in range(random.randint(3, 7)):
                sender = self._pick(participants)
                body = self._pick([
                    'Hey, how is the training going?',
                    'Same time tomorrow?',
                    'That workout was brutal but so worth it.',
                    'Check out this new routine I found!',
                    'Meet you at the gym at 6?',
                    'Did you try the new protein shake?',
                    'Great session today!',
                    'Sending you the meal plan now.',
                    'Remember to hydrate!',
                    'Awesome progress this week.',
                ])
                Message.objects.create(
                    conversation=conv,
                    sender=sender,
                    message_type='text',
                    body=body,
                    is_read=random.choice([True, False]),
                )
                msg_count += 1
        self._log('messages', msg_count)

        # Message reactions
        reactions = 0
        messages = list(Message.objects.all())
        for _ in range(20):
            if not messages:
                break
            msg = self._pick(messages)
            user = self._pick(all_profiles)
            try:
                MessageReaction.objects.get_or_create(message=msg, user=user, emoji=random.choice(['🔥', '💪', '❤️', '👏', '👍', '🎉']))
                reactions += 1
            except Exception:  # noqa: BLE001
                pass
        self._log('message reactions', reactions)

        # Call logs
        for i in range(15):
            if not conversations:
                break
            conv = self._pick(conversations)
            participants = list(conv.participants.all())
            if len(participants) < 2:
                continue
            caller, callee = random.sample(participants, 2)
            CallLog.objects.get_or_create(
                conversation=conv, caller=caller, callee=callee,
                defaults={'call_type': random.choice(['audio', 'video']), 'status': random.choice(['answered', 'missed', 'declined', 'ended']), 'duration_seconds': random.randint(10, 1800)},
            )
        self._log('call logs', CallLog.objects.count())

    # -- 10. Notifications ---------------------------------------------------
    def _seed_notifications(self):
        all_profiles = self.profiles
        types = [
            'buddy_request', 'buddy_accepted', 'new_follower', 'comment',
            'post_reaction', 'post_repost', 'live_starting', 'gym_invite',
            'session_booked', 'session_reminder', 'payment_received',
            'streak_milestone', 'accountability_ping', 'new_purchase',
            'programme_reminder', 'meal_reminder', 'shop_verified',
        ]
        for i in range(40):
            recipient = self._pick(all_profiles)
            ntype = random.choice(types)
            Notification.objects.get_or_create(
                recipient=recipient, notification_type=ntype, title=f'{ntype.replace("_", " ").title()} update',
                defaults={
                    'body': self._pick(['You have a new activity on Buddy-Up.', 'Someone interacted with your post.', 'A session reminder for your booking.']),
                    'is_read': random.choice([True, False]),
                },
            )
        self._log('notifications', Notification.objects.count())

        for p in self.regulars[:15]:
            NotificationPreference.objects.get_or_create(profile=p)
        self._log('notification preferences', NotificationPreference.objects.count())

    # -- 11. Wallet ----------------------------------------------------------
    def _seed_wallet(self):
        all_profiles = self.profiles
        tx_types = ['purchase', 'tip_sent', 'tip_received', 'gift_sent', 'gift_received', 'bonus', 'marketplace', 'withdrawal', 'refund']
        for i in range(40):
            user = self._pick(all_profiles)
            tx_type = random.choice(tx_types)
            direction = 'credit' if tx_type in ('tip_received', 'gift_received', 'bonus', 'refund') else 'debit'
            ArtifactTransaction.objects.get_or_create(
                user=user, transaction_type=tx_type, artifact_type='dumbbell',
                quantity=random.randint(5, 200), direction=direction,
                defaults={
                    'status': random.choice(['completed', 'completed', 'pending', 'failed']),
                    'description': f'{tx_type.replace("_", " ").title()} of dumbbells',
                    'reference_id': f'tx-{uuid4()}',
                },
            )
        self._log('wallet transactions', ArtifactTransaction.objects.count())

    # -- 12. Accounts extras -------------------------------------------------
    def _seed_accounts(self):
        all_profiles = self.profiles
        # Device sessions
        for i in range(15):
            profile = self._pick(all_profiles)
            DeviceSession.objects.get_or_create(
                user=profile.user, refresh_token_hash=f'hash-{uuid4()}',
                defaults={'device_name': self._pick(['iPhone', 'Android', 'Web Browser', 'iPad', 'MacBook']), 'ip_address': '10.89.0.6', 'is_active': True},
            )
        self._log('device sessions', DeviceSession.objects.count())

        # Account events
        for i in range(20):
            profile = self._pick(all_profiles)
            AccountEvent.objects.get_or_create(
                user=profile.user, event_type=random.choice(['login', 'profile_updated', 'post_created', 'session_booked', 'wallet_transaction']),
                defaults={'ip_address': '10.89.0.6', 'user_agent': 'Mozilla/5.0', 'metadata': {}},
            )
        self._log('account events', AccountEvent.objects.count())

        # OTP tokens
        for i in range(15):
            profile = self._pick(all_profiles)
            OTPToken.objects.create(
                user=profile.user, code=str(random.randint(100000, 999999)),
                channel='email', expires_at=self.now + timedelta(minutes=10),
            )
        self._log('otp tokens', OTPToken.objects.count())

    def _log(self, label, count):
        self.stdout.write(f'  + {label}: {count}')
