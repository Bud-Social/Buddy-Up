import pytest
from rest_framework.test import APIClient
from rest_framework_simplejwt.tokens import RefreshToken
from tests.factories import (
    UserFactory, ProfileFactory, TrainerProfileFactory,
    AvailabilityFactory, BookingSessionFactory, GymFactory,
    GymMembershipFactory, PostFactory,
)


@pytest.fixture
def api_client():
    return APIClient()


@pytest.fixture
def user():
    return UserFactory()


@pytest.fixture
def profile(user):
    return ProfileFactory(user=user)


@pytest.fixture
def trainer_user():
    return UserFactory(email='trainer@test.com')


@pytest.fixture
def trainer_profile(trainer_user):
    return ProfileFactory(user=trainer_user, username='trainer1', display_name='Trainer One', role='trainer')


@pytest.fixture
def trainer(trainer_profile):
    t = TrainerProfileFactory(profile=trainer_profile)
    AvailabilityFactory(trainer=t)
    return t


@pytest.fixture
def auth_client(api_client, user):
    refresh = RefreshToken.for_user(user)
    api_client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')
    return api_client


@pytest.fixture
def trainer_auth_client(api_client, trainer_user):
    refresh = RefreshToken.for_user(trainer_user)
    api_client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')
    return api_client


@pytest.fixture
def booking(trainer, profile):
    return BookingSessionFactory(
        client=profile,
        trainer=trainer.profile,
        status='confirmed',
    )


@pytest.fixture
def gym():
    return GymFactory()


@pytest.fixture
def gym_membership(gym, profile):
    return GymMembershipFactory(gym=gym, member=profile)


@pytest.fixture
def post(profile):
    return PostFactory(author=profile)
