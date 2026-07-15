import factory
from datetime import date, timedelta
from django.utils import timezone
from django.contrib.auth.hashers import make_password
from common.utils import hash_dob
from apps.accounts.models import User
from apps.profiles.models import Profile, BuddyRelationship, FollowRelationship
from apps.sessions.models import TrainerProfile, Availability, BookingSession, Review, AsyncProgramme, ProgrammeWeek, ProgrammeEnrollment
from apps.gyms.models import Gym, GymMembership
from apps.feed.models import Post, Comment, Reaction
from apps.wallet.models import ArtifactTransaction
from apps.notifications.models import Notification


class UserFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = User

    email = factory.Sequence(lambda n: f'user{n}@example.com')
    password = factory.PostGenerationMethodCall('set_password', 'TestPass123!')
    dob_hash = hash_dob(date(2000, 6, 15))
    email_verified = True
    is_adult = True
    is_active = True


class ProfileFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = Profile
        django_get_or_create = ('user',)

    user = factory.SubFactory(UserFactory)
    username = factory.Sequence(lambda n: f'user{n}')
    display_name = factory.Sequence(lambda n: f'User {n}')
    role = 'user'
    verification_status = 'email'
    privacy_level = 'public'
    artifact_balance = {'dumbbell': 100, 'barbell': 50}
    bio = ''

    @factory.post_generation
    def ensure_user_dob(obj, create, extracted, **kwargs):
        if create and not obj.user.dob_hash:
            obj.user.dob_hash = hash_dob(date(2000, 6, 15))
            obj.user.save(update_fields=['dob_hash'])


class TrainerProfileFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = TrainerProfile

    profile = factory.SubFactory(ProfileFactory, role='trainer')
    specialties = ['yoga', 'hiit']
    certifications = []
    years_experience = 5
    languages = ['en']
    session_types = ['1on1_live']
    pricing = {'1on1_live_60': {'dumbbell': 10}}
    average_rating = 0.0
    review_count = 0
    total_sessions_completed = 0


class AvailabilityFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = Availability

    trainer = factory.SubFactory(TrainerProfileFactory)
    day_of_week = 1
    start_time = '09:00'
    end_time = '17:00'
    buffer_minutes = 0
    is_active = True


class BookingSessionFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = BookingSession

    client = factory.SubFactory(ProfileFactory)
    trainer = factory.SubFactory(ProfileFactory, role='trainer')
    session_type = '1on1_live'
    status = 'confirmed'
    scheduled_at = factory.LazyFunction(lambda: timezone.now() + timedelta(hours=24))
    duration_minutes = 60
    artifact_fee = {'dumbbell': 10}
    notes = ''
    escrow_tx_id = ''


class ReviewFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = Review

    session = factory.SubFactory(BookingSessionFactory)
    client = factory.SubFactory(ProfileFactory)
    trainer = factory.SubFactory(ProfileFactory, role='trainer')
    rating = 5
    body = 'Great session!'


class AsyncProgrammeFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = AsyncProgramme

    trainer = factory.SubFactory(ProfileFactory, role='trainer')
    title = factory.Sequence(lambda n: f'Programme {n}')
    description = 'A great programme'
    duration_weeks = 8
    price_artifacts = {'dumbbell': 6}
    is_active = True


class ProgrammeWeekFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = ProgrammeWeek

    programme = factory.SubFactory(AsyncProgrammeFactory)
    week_number = factory.Sequence(lambda n: n + 1)
    title = factory.Sequence(lambda n: f'Week {n + 1}')
    description = 'Workout week'
    exercises = []


class ProgrammeEnrollmentFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = ProgrammeEnrollment

    programme = factory.SubFactory(AsyncProgrammeFactory)
    client = factory.SubFactory(ProfileFactory)
    completed_weeks = []
    progress_pct = 0.0


class GymFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = Gym

    name = factory.Sequence(lambda n: f'Gym {n}')
    handle = factory.Sequence(lambda n: f'gym{n}')
    access_type = 'public'
    subscription_type = 'free'
    rules = ''
    tags = []
    member_count = 0
    is_verified = False
    is_reviews_enabled = True
    is_donations_enabled = True


class GymMembershipFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = GymMembership

    gym = factory.SubFactory(GymFactory)
    member = factory.SubFactory(ProfileFactory)
    role = 'member'
    subscription_active = True


class PostFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = Post

    author = factory.SubFactory(ProfileFactory)
    post_type = 'text'
    body = factory.Sequence(lambda n: f'Post body {n}')
    visibility = 'public'
    moderation_status = 'clean'
    is_deleted = False


class CommentFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = Comment

    post = factory.SubFactory(PostFactory)
    author = factory.SubFactory(ProfileFactory)
    body = 'Great post!'


class ReactionFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = Reaction

    post = factory.SubFactory(PostFactory)
    author = factory.SubFactory(ProfileFactory)
    reaction_type = 'fire'


class ArtifactTransactionFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = ArtifactTransaction

    user = factory.SubFactory(ProfileFactory)
    transaction_type = 'purchase'
    artifact_type = 'dumbbell'
    quantity = 10
    direction = 'credit'
    status = 'completed'


class NotificationFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = Notification

    recipient = factory.SubFactory(ProfileFactory)
    notification_type = 'post_reaction'
    title = 'New notification'
    body = 'You have a new notification'
