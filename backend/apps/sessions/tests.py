from datetime import date, timedelta
from django.test import TestCase
from django.utils import timezone
from rest_framework.test import APIClient
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken
from common.utils import hash_dob
from apps.accounts.models import User
from apps.profiles.models import Profile
from .models import TrainerProfile, Availability, BookingSession, AsyncProgramme, ProgrammeEnrollment


def _auth_client(client, email='client@test.com', password='TestPass123!'):
    user = User.objects.get(email=email)
    refresh = RefreshToken.for_user(user)
    client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')


def _setup_trainer():
    trainer_user = User.objects.create_user(email='trainer@test.com', password='TestPass123!')
    trainer_user.dob_hash = hash_dob(date(1990, 1, 1))
    trainer_user.email_verified = True
    trainer_user.save()
    trainer_profile = Profile.objects.create(
        user=trainer_user, username='trainer1', display_name='Trainer One', role='trainer',
        artifact_balance={'dumbbell': 100, 'barbell': 50},
    )
    tp = TrainerProfile.objects.create(
        profile=trainer_profile,
        specialties=['yoga', 'hiit'],
        years_experience=5,
        pricing={'1on1_live_60': {'dumbbell': 10}},
    )
    Availability.objects.create(trainer=tp, day_of_week=1, start_time='09:00', end_time='17:00')
    return trainer_user, trainer_profile, tp


class TrainerTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(email='client@test.com', password='TestPass123!')
        self.user.dob_hash = hash_dob(date(2000, 6, 15))
        self.user.email_verified = True
        self.user.save()
        self.profile = Profile.objects.create(
            user=self.user, username='client1', display_name='Client One',
            artifact_balance={'dumbbell': 100},
        )
        _auth_client(self.client)
        self.trainer_user, self.trainer_profile, self.tp = _setup_trainer()

    def test_list_trainers(self):
        response = self.client.get('/api/v1/sessions/trainers/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(len(response.data['data']) >= 1)

    def test_list_trainers_filter_by_specialty(self):
        response = self.client.get('/api/v1/sessions/trainers/?specialty=yoga')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(len(response.data['data']) >= 1)

    def test_list_trainers_no_match(self):
        response = self.client.get('/api/v1/sessions/trainers/?specialty=unknown_sport')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data['data']), 0)

    def test_trainer_detail(self):
        response = self.client.get(f'/api/v1/sessions/trainers/{self.trainer_profile.username}/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['data']['specialties'], ['yoga', 'hiit'])

    def test_get_availability(self):
        response = self.client.get(f'/api/v1/sessions/trainers/{self.trainer_profile.username}/availability/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(len(response.data['data']) >= 1)

    def test_my_availability_post(self):
        _auth_client(self.client, email='trainer@test.com')
        response = self.client.post('/api/v1/sessions/my-availability/', {
            'day_of_week': 2, 'start_time': '10:00', 'end_time': '14:00',
        }, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)


class TrainerDiscoveryFilterTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(email='client@test.com', password='TestPass123!')
        self.user.dob_hash = hash_dob(date(2000, 6, 15))
        self.user.email_verified = True
        self.user.save()
        self.profile = Profile.objects.create(
            user=self.user, username='client1', display_name='Client One',
            artifact_balance={'dumbbell': 100},
        )
        _auth_client(self.client)
        self.trainer_user, self.trainer_profile, self.tp = _setup_trainer()
        self.trainer_profile.location_city = 'Nairobi'
        self.trainer_profile.location_country = 'Kenya'
        self.trainer_profile.save(update_fields=['location_city', 'location_country'])

    def _usernames(self, params):
        res = self.client.get('/api/v1/sessions/trainers/', params)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        return [t['profile_data']['username'] for t in res.data['data']]

    def test_virtual_filter_matches_remote_session_types(self):
        # No explicit flag, but offers 1:1 live sessions.
        self.tp.session_types = ['1on1_live']
        self.tp.save(update_fields=['session_types'])
        self.assertIn('trainer1', self._usernames({'virtual': 'true'}))

    def test_virtual_flag(self):
        self.tp.is_virtual = True
        self.tp.save(update_fields=['is_virtual'])
        self.assertIn('trainer1', self._usernames({'virtual': 'true'}))

    def test_mobile_filter_excludes_by_default(self):
        self.assertNotIn('trainer1', self._usernames({'mobile': 'true'}))
        self.tp.is_mobile = True
        self.tp.save(update_fields=['is_mobile'])
        self.assertIn('trainer1', self._usernames({'mobile': 'true'}))

    def test_location_filter(self):
        self.assertIn('trainer1', self._usernames({'location': 'Nairobi'}))
        self.assertNotIn('trainer1', self._usernames({'location': 'Lagos'}))

    def test_verified_filter(self):
        self.assertNotIn('trainer1', self._usernames({'verified': 'true'}))
        self.trainer_profile.verification_status = 'trainer'
        self.trainer_profile.save(update_fields=['verification_status'])
        self.assertIn('trainer1', self._usernames({'verified': 'true'}))

    def test_gym_affiliation_filter(self):
        from apps.gyms.models import Gym, GymMembership
        gym = Gym.objects.create(
            name='Affiliated Gym', handle='affiliated-gym', category='fitness',
            access_type='public',
        )
        GymMembership.objects.create(
            gym=gym, member=self.trainer_profile, role='trainer',
        )
        self.assertIn('trainer1', self._usernames({'gym': 'affiliated-gym'}))
        self.assertNotIn('trainer1', self._usernames({'gym': 'other-gym'}))

    def test_affiliated_gyms_exposed(self):
        from apps.gyms.models import Gym, GymMembership
        gym = Gym.objects.create(
            name='Affiliated Gym', handle='affiliated-gym', category='fitness',
            access_type='public',
        )
        GymMembership.objects.create(
            gym=gym, member=self.trainer_profile, role='trainer',
        )
        res = self.client.get('/api/v1/sessions/trainers/')
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        entry = [t for t in res.data['data']
                 if t['profile_data']['username'] == 'trainer1'][0]
        self.assertEqual(entry['affiliated_gyms'],
                         [{'handle': 'affiliated-gym', 'name': 'Affiliated Gym'}])


class BookingTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(email='client@test.com', password='TestPass123!')
        self.user.dob_hash = hash_dob(date(2000, 6, 15))
        self.user.email_verified = True
        self.user.save()
        self.profile = Profile.objects.create(
            user=self.user, username='client1', display_name='Client One',
            artifact_balance={'dumbbell': 100},
        )
        _auth_client(self.client)
        self.trainer_user, self.trainer_profile, self.tp = _setup_trainer()

    def test_book_session_success(self):
        response = self.client.post(f'/api/v1/sessions/book/{self.trainer_profile.username}/', {
            'session_type': '1on1_live',
            'scheduled_at': (timezone.now() + timedelta(days=2)).isoformat(),
            'duration_minutes': 60,
        }, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data['data']['status'], 'confirmed')

    def test_book_session_insufficient_balance(self):
        self.profile.artifact_balance = {'dumbbell': 0}
        self.profile.save(update_fields=['artifact_balance'])
        response = self.client.post(f'/api/v1/sessions/book/{self.trainer_profile.username}/', {
            'session_type': '1on1_live',
            'scheduled_at': (timezone.now() + timedelta(days=2)).isoformat(),
            'duration_minutes': 60,
        }, format='json')
        self.assertEqual(response.status_code, status.HTTP_402_PAYMENT_REQUIRED)

    def test_overlapping_booking_rejected(self):
        start = timezone.now() + timedelta(days=2)
        first = self.client.post(f'/api/v1/sessions/book/{self.trainer_profile.username}/', {
            'session_type': '1on1_live',
            'scheduled_at': start.isoformat(),
            'duration_minutes': 60,
        }, format='json')
        self.assertEqual(first.status_code, status.HTTP_201_CREATED)
        clash = self.client.post(f'/api/v1/sessions/book/{self.trainer_profile.username}/', {
            'session_type': '1on1_live',
            'scheduled_at': (start + timedelta(minutes=30)).isoformat(),
            'duration_minutes': 60,
        }, format='json')
        self.assertEqual(clash.status_code, status.HTTP_409_CONFLICT)
        # Abutting the first booking is fine.
        ok = self.client.post(f'/api/v1/sessions/book/{self.trainer_profile.username}/', {
            'session_type': '1on1_live',
            'scheduled_at': (start + timedelta(minutes=60)).isoformat(),
            'duration_minutes': 60,
        }, format='json')
        self.assertEqual(ok.status_code, status.HTTP_201_CREATED)

    def test_book_then_start_then_complete_then_review(self):
        # Book
        book_res = self.client.post(f'/api/v1/sessions/book/{self.trainer_profile.username}/', {
            'session_type': '1on1_live',
            'scheduled_at': (timezone.now() + timedelta(days=2)).isoformat(),
            'duration_minutes': 60,
        }, format='json')
        self.assertEqual(book_res.status_code, status.HTTP_201_CREATED)
        booking_id = book_res.data['data']['id']

        # Start as trainer
        _auth_client(self.client, email='trainer@test.com')
        start_res = self.client.post(f'/api/v1/sessions/bookings/{booking_id}/', {'action': 'start'}, format='json')
        self.assertEqual(start_res.status_code, status.HTTP_200_OK)
        self.assertEqual(BookingSession.objects.get(id=booking_id).status, 'in_progress')

        # Complete as trainer
        complete_res = self.client.post(f'/api/v1/sessions/bookings/{booking_id}/', {'action': 'complete'}, format='json')
        self.assertEqual(complete_res.status_code, status.HTTP_200_OK)
        self.assertEqual(BookingSession.objects.get(id=booking_id).status, 'completed')

        # Review as client
        _auth_client(self.client)
        review_res = self.client.post(f'/api/v1/sessions/bookings/{booking_id}/review/', {
            'rating': 5, 'body': 'Great session!',
        }, format='json')
        self.assertEqual(review_res.status_code, status.HTTP_201_CREATED)
        self.assertEqual(review_res.data['data']['rating'], 5)

    def test_cancel_by_client_full_refund(self):
        book_res = self.client.post(f'/api/v1/sessions/book/{self.trainer_profile.username}/', {
            'session_type': '1on1_live',
            'scheduled_at': (timezone.now() + timedelta(days=3)).isoformat(),
            'duration_minutes': 60,
        }, format='json')
        booking_id = book_res.data['data']['id']

        cancel_res = self.client.post(f'/api/v1/sessions/bookings/{booking_id}/', {'action': 'cancel'}, format='json')
        self.assertEqual(cancel_res.status_code, status.HTTP_200_OK)
        self.assertEqual(cancel_res.data['data']['refund_pct'], 1.0)
        self.assertEqual(BookingSession.objects.get(id=booking_id).status, 'cancelled_by_client')

    def test_cancel_by_trainer_full_refund(self):
        book_res = self.client.post(f'/api/v1/sessions/book/{self.trainer_profile.username}/', {
            'session_type': '1on1_live',
            'scheduled_at': (timezone.now() + timedelta(days=3)).isoformat(),
            'duration_minutes': 60,
        }, format='json')
        booking_id = book_res.data['data']['id']

        _auth_client(self.client, email='trainer@test.com')
        cancel_res = self.client.post(f'/api/v1/sessions/bookings/{booking_id}/', {'action': 'cancel'}, format='json')
        self.assertEqual(cancel_res.status_code, status.HTTP_200_OK)
        self.assertEqual(BookingSession.objects.get(id=booking_id).status, 'cancelled_by_trainer')

    def test_my_bookings(self):
        self.client.post(f'/api/v1/sessions/book/{self.trainer_profile.username}/', {
            'session_type': '1on1_live',
            'scheduled_at': (timezone.now() + timedelta(days=2)).isoformat(),
            'duration_minutes': 60,
        }, format='json')

        response = self.client.get('/api/v1/sessions/my/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(len(response.data['data']) >= 1)

    def test_booking_detail_unauthorized(self):
        book_res = self.client.post(f'/api/v1/sessions/book/{self.trainer_profile.username}/', {
            'session_type': '1on1_live',
            'scheduled_at': (timezone.now() + timedelta(days=2)).isoformat(),
            'duration_minutes': 60,
        }, format='json')
        booking_id = book_res.data['data']['id']

        other_user = User.objects.create_user(email='other@test.com', password='TestPass123!')
        other_user.dob_hash = hash_dob(date(2000, 1, 1))
        other_user.email_verified = True
        other_user.save()
        Profile.objects.create(user=other_user, username='other', display_name='Other')
        _auth_client(self.client, email='other@test.com')

        response = self.client.get(f'/api/v1/sessions/bookings/{booking_id}/')
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    def test_recurring_booking_charges_each_child_and_records_evidence(self):
        response = self.client.post(f'/api/v1/sessions/book/{self.trainer_profile.username}/', {
            'session_type': '1on1_live',
            'scheduled_at': (timezone.now() + timedelta(days=2)).isoformat(),
            'duration_minutes': 60, 'recurrence_pattern': 'weekly', 'recurring_weeks': 3,
        }, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(BookingSession.objects.filter(client=self.profile).count(), 3)
        self.assertEqual(BookingSession.objects.filter(client=self.profile).exclude(escrow_tx_id='').count(), 3)
        booking_id = response.data['data']['id']
        _auth_client(self.client, email='trainer@test.com')
        self.client.post(f'/api/v1/sessions/bookings/{booking_id}/', {
            'action': 'start',
        }, format='json')
        response = self.client.post(f'/api/v1/sessions/bookings/{booking_id}/', {
            'action': 'complete', 'evidence': {'attendance': 'confirmed'},
        }, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(BookingSession.objects.get(id=booking_id).completion_evidence['attendance'], 'confirmed')


class TrainerReviewsTest(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(email='client@test.com', password='TestPass123!')
        self.user.dob_hash = hash_dob(date(2000, 6, 15))
        self.user.email_verified = True
        self.user.save()
        self.profile = Profile.objects.create(
            user=self.user, username='client1', display_name='Client One',
            artifact_balance={'dumbbell': 100},
        )
        _auth_client(self.client)
        self.trainer_user, self.trainer_profile, self.tp = _setup_trainer()

        book_res = self.client.post(f'/api/v1/sessions/book/{self.trainer_profile.username}/', {
            'session_type': '1on1_live',
            'scheduled_at': (timezone.now() + timedelta(days=2)).isoformat(),
            'duration_minutes': 60,
        }, format='json')
        booking_id = book_res.data['data']['id']
        _auth_client(self.client, email='trainer@test.com')
        self.client.post(f'/api/v1/sessions/bookings/{booking_id}/', {'action': 'start'}, format='json')
        self.client.post(f'/api/v1/sessions/bookings/{booking_id}/', {'action': 'complete'}, format='json')
        _auth_client(self.client)

    def test_get_trainer_reviews(self):
        response = self.client.get(f'/api/v1/sessions/trainers/{self.trainer_profile.username}/reviews/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)


class ProgrammeTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(email='client@test.com', password='TestPass123!')
        self.user.dob_hash = hash_dob(date(2000, 6, 15))
        self.user.email_verified = True
        self.user.save()
        self.profile = Profile.objects.create(
            user=self.user, username='client1', display_name='Client One',
        )
        _auth_client(self.client)
        self.trainer_user, self.trainer_profile, self.tp = _setup_trainer()

        self.programme = AsyncProgramme.objects.create(
            trainer=self.trainer_profile, title='Test Programme',
            description='A test', duration_weeks=4, is_active=True,
        )
        from .models import ProgrammeWeek
        for w in range(1, 5):
            ProgrammeWeek.objects.create(
                programme=self.programme, week_number=w,
                title=f'Week {w}', description=f'Week {w} content',
            )

    def test_list_programmes(self):
        response = self.client.get('/api/v1/sessions/programmes/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(len(response.data['data']) >= 1)

    def test_enroll_in_programme(self):
        response = self.client.post(f'/api/v1/sessions/programmes/{self.programme.id}/enroll/', format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data['data']['enrolled'])

    def test_list_programme_weeks(self):
        response = self.client.get(f'/api/v1/sessions/programmes/{self.programme.id}/weeks/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data['data']), 4)

    def test_complete_week_and_check_progress(self):
        self.client.post(f'/api/v1/sessions/programmes/{self.programme.id}/enroll/', format='json')

        complete_res = self.client.post(
            f'/api/v1/sessions/programmes/{self.programme.id}/weeks/1/complete/', format='json')
        self.assertEqual(complete_res.status_code, status.HTTP_200_OK)
        self.assertEqual(complete_res.data['data']['progress_pct'], 25)

        # Complete all weeks
        for w in range(2, 5):
            self.client.post(f'/api/v1/sessions/programmes/{self.programme.id}/weeks/{w}/complete/', format='json')

        enroll = ProgrammeEnrollment.objects.get(client=self.profile, programme=self.programme)
        self.assertEqual(enroll.progress_pct, 100)

    def test_my_enrollments(self):
        self.client.post(f'/api/v1/sessions/programmes/{self.programme.id}/enroll/', format='json')
        response = self.client.get('/api/v1/sessions/my-enrollments/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(len(response.data['data']) >= 1)
