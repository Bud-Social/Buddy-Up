from datetime import date, timedelta
from django.test import TestCase
from django.utils import timezone
from rest_framework.test import APIClient
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken
from common.utils import hash_dob
from apps.accounts.models import User
from apps.profiles.models import Profile
from .models import Gym, GymCategory, GymMembership, JoinRequest, GymInvite, GymSchedulePost, GymReview, ScheduleSlotEnrollment


class GymCrudTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(email='owner@test.com', password='TestPass123!')
        self.user.dob_hash = hash_dob(date(2000, 6, 15))
        self.user.email_verified = True
        self.user.save()
        self.profile = Profile.objects.create(
            user=self.user, username='gymowner', display_name='Gym Owner',
        )
        refresh = RefreshToken.for_user(self.user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')

        self.cat = GymCategory.objects.create(name='fitness', display_name='Fitness', is_active=True)

    def test_create_gym(self):
        response = self.client.post('/api/v1/gyms/create/', {
            'name': 'Test Gym',
            'handle': 'testgym',
            'category': 'fitness',
            'access_type': 'public',
            'subscription_type': 'free',
            'category_ids': [self.cat.id],
        }, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data['data']['name'], 'Test Gym')
        self.assertTrue(Gym.objects.filter(handle='testgym').exists())

    def test_create_gym_duplicate_handle(self):
        self.client.post('/api/v1/gyms/create/', {
            'name': 'First Gym', 'handle': 'dup',
            'category': 'fitness', 'access_type': 'public', 'subscription_type': 'free',
        }, format='json')
        response = self.client.post('/api/v1/gyms/create/', {
            'name': 'Second Gym', 'handle': 'dup',
            'category': 'fitness', 'access_type': 'public', 'subscription_type': 'free',
        }, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_check_handle_available(self):
        response = self.client.get('/api/v1/gyms/check-handle/?candidate=newhandle')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data['data']['available'])

    def test_check_handle_taken(self):
        Gym.objects.create(name='Existing', handle='taken', category='fitness', access_type='public')
        response = self.client.get('/api/v1/gyms/check-handle/?candidate=taken')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertFalse(response.data['data']['available'])
        self.assertIsNotNone(response.data['data']['suggested'])

    def test_get_gym_detail(self):
        gym = Gym.objects.create(name='Detail Gym', handle='detailgym', category='fitness', access_type='public')
        GymMembership.objects.create(gym=gym, member=self.profile, role='owner')
        response = self.client.get('/api/v1/gyms/detailgym/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['data']['name'], 'Detail Gym')

    def test_update_gym(self):
        gym = Gym.objects.create(name='Update Gym', handle='updategym', category='fitness', access_type='public')
        GymMembership.objects.create(gym=gym, member=self.profile, role='owner')
        response = self.client.patch('/api/v1/gyms/updategym/', {'description': 'Updated'}, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['data']['description'], 'Updated')

    def test_delete_gym(self):
        gym = Gym.objects.create(name='Delete Gym', handle='deletegym', category='fitness', access_type='public')
        GymMembership.objects.create(gym=gym, member=self.profile, role='owner')
        response = self.client.delete('/api/v1/gyms/deletegym/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        gym.refresh_from_db()
        self.assertTrue(gym.is_deleted)

    def test_list_gyms(self):
        Gym.objects.create(name='List Gym', handle='listgym', category='fitness', access_type='public')
        response = self.client.get('/api/v1/gyms/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(len(response.data['data']) >= 1)

    def test_list_gyms_search(self):
        Gym.objects.create(name='Searchable Gym', handle='searchgym', category='fitness', access_type='public')
        response = self.client.get('/api/v1/gyms/?q=Searchable')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(len(response.data['data']) >= 1)


class GymMembershipTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.owner_user = User.objects.create_user(email='owner@test.com', password='TestPass123!')
        self.owner_user.dob_hash = hash_dob(date(2000, 6, 15))
        self.owner_user.email_verified = True
        self.owner_user.save()
        self.owner_profile = Profile.objects.create(
            user=self.owner_user, username='gymowner', display_name='Gym Owner',
        )
        self.gym = Gym.objects.create(name='Member Gym', handle='membergym', category='fitness', access_type='public')
        GymMembership.objects.create(gym=self.gym, member=self.owner_profile, role='owner')

        self.member_user = User.objects.create_user(email='member@test.com', password='TestPass123!')
        self.member_user.dob_hash = hash_dob(date(2000, 6, 15))
        self.member_user.email_verified = True
        self.member_user.save()
        self.member_profile = Profile.objects.create(
            user=self.member_user, username='gymmember', display_name='Gym Member',
        )

    def _auth_as(self, email):
        user = User.objects.get(email=email)
        refresh = RefreshToken.for_user(user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')

    def test_join_public_gym(self):
        self._auth_as('member@test.com')
        response = self.client.post('/api/v1/gyms/membergym/join/', format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(GymMembership.objects.filter(gym=self.gym, member=self.member_profile).exists())

    def test_join_already_member(self):
        self._auth_as('member@test.com')
        self.client.post('/api/v1/gyms/membergym/join/', format='json')
        response = self.client.post('/api/v1/gyms/membergym/join/', format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_leave_gym(self):
        self._auth_as('member@test.com')
        self.client.post('/api/v1/gyms/membergym/join/', format='json')
        response = self.client.post('/api/v1/gyms/membergym/leave/', format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_list_members(self):
        self._auth_as('member@test.com')
        self.client.post('/api/v1/gyms/membergym/join/', format='json')
        self._auth_as('owner@test.com')
        response = self.client.get('/api/v1/gyms/membergym/members/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(len(response.data['data']) >= 1)

    def test_manage_member_role(self):
        self._auth_as('member@test.com')
        self.client.post('/api/v1/gyms/membergym/join/', format='json')
        self._auth_as('owner@test.com')
        response = self.client.post(f'/api/v1/gyms/membergym/members/{self.member_profile.user_id}/',
            {'role': 'moderator'}, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_remove_member(self):
        self._auth_as('member@test.com')
        self.client.post('/api/v1/gyms/membergym/join/', format='json')
        self._auth_as('owner@test.com')
        response = self.client.delete(f'/api/v1/gyms/membergym/members/{self.member_profile.user_id}/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)


class GymJoinRequestTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.owner_user = User.objects.create_user(email='owner@test.com', password='TestPass123!')
        self.owner_user.dob_hash = hash_dob(date(2000, 6, 15))
        self.owner_user.email_verified = True
        self.owner_user.save()
        self.owner_profile = Profile.objects.create(
            user=self.owner_user, username='gymowner', display_name='Gym Owner',
        )
        self.gym = Gym.objects.create(name='Private Gym', handle='privategym', category='fitness', access_type='private')
        GymMembership.objects.create(gym=self.gym, member=self.owner_profile, role='owner')

        self.requester_user = User.objects.create_user(email='requester@test.com', password='TestPass123!')
        self.requester_user.dob_hash = hash_dob(date(2000, 6, 15))
        self.requester_user.email_verified = True
        self.requester_user.save()
        self.requester_profile = Profile.objects.create(
            user=self.requester_user, username='requester', display_name='Requester',
        )

    def _auth_as(self, email):
        user = User.objects.get(email=email)
        refresh = RefreshToken.for_user(user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')

    def test_request_to_join_private_gym(self):
        self._auth_as('requester@test.com')
        response = self.client.post('/api/v1/gyms/privategym/join/', {'message': 'Please let me in'}, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(JoinRequest.objects.filter(gym=self.gym, requester=self.requester_profile).exists())

    def test_approve_join_request(self):
        self._auth_as('requester@test.com')
        self.client.post('/api/v1/gyms/privategym/join/', format='json')
        req = JoinRequest.objects.get(gym=self.gym, requester=self.requester_profile)

        self._auth_as('owner@test.com')
        response = self.client.patch(f'/api/v1/gyms/privategym/join-requests/{req.id}/',
            {'status': 'approved'}, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(GymMembership.objects.filter(gym=self.gym, member=self.requester_profile).exists())

    def test_reject_join_request(self):
        self._auth_as('requester@test.com')
        self.client.post('/api/v1/gyms/privategym/join/', format='json')
        req = JoinRequest.objects.get(gym=self.gym, requester=self.requester_profile)

        self._auth_as('owner@test.com')
        response = self.client.patch(f'/api/v1/gyms/privategym/join-requests/{req.id}/',
            {'status': 'rejected'}, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertFalse(GymMembership.objects.filter(gym=self.gym, member=self.requester_profile).exists())


class GymInviteTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.owner_user = User.objects.create_user(email='owner@test.com', password='TestPass123!')
        self.owner_user.dob_hash = hash_dob(date(2000, 6, 15))
        self.owner_user.email_verified = True
        self.owner_user.save()
        self.owner_profile = Profile.objects.create(
            user=self.owner_user, username='gymowner', display_name='Gym Owner',
        )
        self.gym = Gym.objects.create(name='Invite Gym', handle='invitegym', category='fitness', access_type='public')
        GymMembership.objects.create(gym=self.gym, member=self.owner_profile, role='owner')

        self.invited_user = User.objects.create_user(email='invited@test.com', password='TestPass123!')
        self.invited_user.dob_hash = hash_dob(date(2000, 6, 15))
        self.invited_user.email_verified = True
        self.invited_user.save()
        self.invited_profile = Profile.objects.create(
            user=self.invited_user, username='invited', display_name='Invited User',
        )

    def _auth_as(self, email):
        user = User.objects.get(email=email)
        refresh = RefreshToken.for_user(user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')

    def test_send_invite(self):
        self._auth_as('owner@test.com')
        response = self.client.post('/api/v1/gyms/invitegym/invite/',
            {'username': 'invited'}, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(GymInvite.objects.filter(gym=self.gym, invited_user=self.invited_profile).exists())

    def test_accept_invite(self):
        self._auth_as('owner@test.com')
        invite_res = self.client.post('/api/v1/gyms/invitegym/invite/',
            {'username': 'invited'}, format='json')
        invite_id = invite_res.data['data']['id']

        self._auth_as('invited@test.com')
        response = self.client.post(f'/api/v1/gyms/invitegym/invites/{invite_id}/accept/', format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(GymMembership.objects.filter(gym=self.gym, member=self.invited_profile).exists())

    def test_decline_invite(self):
        self._auth_as('owner@test.com')
        invite_res = self.client.post('/api/v1/gyms/invitegym/invite/',
            {'username': 'invited'}, format='json')
        invite_id = invite_res.data['data']['id']

        self._auth_as('invited@test.com')
        response = self.client.post(f'/api/v1/gyms/invitegym/invites/{invite_id}/decline/', format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)


class GymSchedulePostTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(email='owner@test.com', password='TestPass123!')
        self.user.dob_hash = hash_dob(date(2000, 6, 15))
        self.user.email_verified = True
        self.user.save()
        self.profile = Profile.objects.create(
            user=self.user, username='gymowner', display_name='Gym Owner',
        )
        self.gym = Gym.objects.create(name='Schedule Gym', handle='schedulegym', category='fitness', access_type='public')
        GymMembership.objects.create(gym=self.gym, member=self.profile, role='owner')

        refresh = RefreshToken.for_user(self.user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')

    def test_create_schedule_post(self):
        response = self.client.post('/api/v1/gyms/schedulegym/schedule-posts/', {
            'title': 'Morning Yoga',
            'activity_type': 'yoga',
            'location_mode': 'in_house',
            'start_time': (timezone.now() + timedelta(days=1)).isoformat(),
            'end_time': (timezone.now() + timedelta(days=1, hours=1)).isoformat(),
        }, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(GymSchedulePost.objects.filter(gym=self.gym, title='Morning Yoga').exists())

    def test_list_schedule_posts(self):
        GymSchedulePost.objects.create(
            gym=self.gym, author=self.profile, title='Test Class',
            activity_type='yoga', location_mode='in_house',
        )
        response = self.client.get('/api/v1/gyms/schedulegym/schedule-posts/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(len(response.data['data']) >= 1)

    def test_update_schedule_post(self):
        post = GymSchedulePost.objects.create(
            gym=self.gym, author=self.profile, title='Original',
            activity_type='yoga', location_mode='in_house',
        )
        response = self.client.patch(f'/api/v1/gyms/schedulegym/schedule-posts/{post.id}/',
            {'title': 'Updated Title'}, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['data']['title'], 'Updated Title')

    def test_delete_schedule_post(self):
        post = GymSchedulePost.objects.create(
            gym=self.gym, author=self.profile, title='To Delete',
            activity_type='yoga', location_mode='in_house',
        )
        response = self.client.delete(f'/api/v1/gyms/schedulegym/schedule-posts/{post.id}/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertFalse(GymSchedulePost.objects.filter(id=post.id).exists())

    def test_enroll_in_schedule_post(self):
        post = GymSchedulePost.objects.create(
            gym=self.gym, author=self.profile, title='Enroll Class',
            activity_type='yoga', location_mode='in_house', max_slots=10,
        )
        response = self.client.post(f'/api/v1/gyms/schedulegym/schedule-posts/{post.id}/enroll/', format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(ScheduleSlotEnrollment.objects.filter(schedule_post=post, member=self.profile).exists())

    def test_unenroll_from_schedule_post(self):
        post = GymSchedulePost.objects.create(
            gym=self.gym, author=self.profile, title='Unenroll Class',
            activity_type='yoga', location_mode='in_house',
        )
        self.client.post(f'/api/v1/gyms/schedulegym/schedule-posts/{post.id}/enroll/', format='json')
        response = self.client.delete(f'/api/v1/gyms/schedulegym/schedule-posts/{post.id}/enroll/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)


class GymReviewTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.owner_user = User.objects.create_user(email='owner@test.com', password='TestPass123!')
        self.owner_user.dob_hash = hash_dob(date(2000, 6, 15))
        self.owner_user.email_verified = True
        self.owner_user.save()
        self.owner_profile = Profile.objects.create(
            user=self.owner_user, username='gymowner', display_name='Gym Owner',
        )
        self.gym = Gym.objects.create(name='Review Gym', handle='reviewgym', category='fitness', access_type='public')
        GymMembership.objects.create(gym=self.gym, member=self.owner_profile, role='owner')

        self.member_user = User.objects.create_user(email='member@test.com', password='TestPass123!')
        self.member_user.dob_hash = hash_dob(date(2000, 6, 15))
        self.member_user.email_verified = True
        self.member_user.save()
        self.member_profile = Profile.objects.create(
            user=self.member_user, username='reviewer', display_name='Reviewer',
        )
        GymMembership.objects.create(gym=self.gym, member=self.member_profile, role='member')

    def _auth_as(self, email):
        user = User.objects.get(email=email)
        refresh = RefreshToken.for_user(user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')

    def test_create_review(self):
        self._auth_as('member@test.com')
        response = self.client.post('/api/v1/gyms/reviewgym/reviews/', {
            'rating': 5, 'comment': 'Great gym!',
        }, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(GymReview.objects.filter(gym=self.gym, reviewer=self.member_profile).exists())

    def test_list_reviews(self):
        GymReview.objects.create(
            gym=self.gym, reviewer=self.member_profile, rating=4, comment='Nice',
        )
        self._auth_as('member@test.com')
        response = self.client.get('/api/v1/gyms/reviewgym/reviews/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(len(response.data['data']) >= 1)

    def test_reply_to_review(self):
        self._auth_as('member@test.com')
        review_res = self.client.post('/api/v1/gyms/reviewgym/reviews/', {
            'rating': 4, 'comment': 'Good',
        }, format='json')
        review_id = review_res.data['data']['id']

        self._auth_as('owner@test.com')
        response = self.client.post(f'/api/v1/gyms/reviewgym/reviews/{review_id}/reply/',
            {'reply_text': 'Thank you!'}, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['data']['reply_text'], 'Thank you!')


class GymDonationTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(email='member@test.com', password='TestPass123!')
        self.user.dob_hash = hash_dob(date(2000, 6, 15))
        self.user.email_verified = True
        self.user.save()
        self.profile = Profile.objects.create(
            user=self.user, username='donor', display_name='Donor',
            artifact_balance={'dumbbell': 100},
        )
        self.gym = Gym.objects.create(name='Donation Gym', handle='donationgym',
                                       category='fitness', access_type='public', is_donations_enabled=True)
        GymMembership.objects.create(gym=self.gym, member=self.profile, role='member')

        refresh = RefreshToken.for_user(self.user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')

    def test_donate_artifacts(self):
        response = self.client.post('/api/v1/gyms/donationgym/donate/', {
            'artifact_type': 'dumbbell', 'quantity': 10, 'message': 'Keep it up!',
        }, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.profile.refresh_from_db()
        self.assertEqual(self.profile.artifact_balance.get('dumbbell', 0), 90)

    def test_donate_insufficient_balance(self):
        response = self.client.post('/api/v1/gyms/donationgym/donate/', {
            'artifact_type': 'dumbbell', 'quantity': 999, 'message': '',
        }, format='json')
        self.assertEqual(response.status_code, status.HTTP_402_PAYMENT_REQUIRED)



class GymDiscoveryFilterTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(email='finder@test.com', password='TestPass123!')
        self.user.dob_hash = hash_dob(date(2000, 6, 15))
        self.user.email_verified = True
        self.user.save()
        self.profile = Profile.objects.create(
            user=self.user, username='gymfinder', display_name='Gym Finder',
        )
        refresh = RefreshToken.for_user(self.user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')

        from .models import VenueLocation
        self.physical = Gym.objects.create(
            name='Nairobi Iron House', handle='nairobi-iron', category='fitness',
            access_type='public', is_verified=True,
            location_city='Nairobi', location_country='Kenya',
        )
        VenueLocation.objects.create(
            gym=self.physical, name='Main floor', city='Nairobi', country='Kenya',
            latitude='-1.292100', longitude='36.821900', is_primary=True, is_active=True,
        )
        GymReview.objects.create(gym=self.physical, reviewer=self.profile, rating=5)

        self.virtual = Gym.objects.create(
            name='Cloud Strength Club', handle='cloud-strength', category='fitness',
            access_type='public',
        )
        GymSchedulePost.objects.create(
            gym=self.virtual, author=self.profile, title='Online HIIT',
            activity_type='hiit', location_mode='online',
        )

        self.hybrid = Gym.objects.create(
            name='Hybrid Athletics', handle='hybrid-athletics', category='fitness',
            access_type='public', location_city='Nairobi', location_country='Kenya',
        )
        VenueLocation.objects.create(
            gym=self.hybrid, name='Westlands branch', city='Nairobi', country='Kenya',
            latitude='-1.263400', longitude='36.802800', is_active=True,
        )
        GymSchedulePost.objects.create(
            gym=self.hybrid, author=self.profile, title='Hybrid strength',
            activity_type='strength', location_mode='hybrid',
        )

        self.far = Gym.objects.create(
            name='Lagos Lift Lab', handle='lagos-lift', category='fitness',
            access_type='public', location_city='Lagos', location_country='Nigeria',
        )
        VenueLocation.objects.create(
            gym=self.far, name='Ikeja branch', city='Lagos', country='Nigeria',
            latitude='6.524400', longitude='3.379200', is_active=True,
        )

    def _handles(self, params):
        res = self.client.get('/api/v1/gyms/', params)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        return [g['handle'] for g in res.json()['data']]

    def test_delivery_virtual_includes_hybrid(self):
        handles = self._handles({'delivery': 'virtual'})
        self.assertIn('cloud-strength', handles)
        self.assertIn('hybrid-athletics', handles)
        self.assertNotIn('nairobi-iron', handles)

    def test_delivery_hybrid_requires_both(self):
        self.assertEqual(set(self._handles({'delivery': 'hybrid'})), {'hybrid-athletics'})

    def test_verified_only(self):
        self.assertEqual(set(self._handles({'verified': 'true'})), {'nairobi-iron'})

    def test_min_rating(self):
        self.assertEqual(set(self._handles({'min_rating': '4'})), {'nairobi-iron'})

    def test_nearby_nairobi(self):
        handles = self._handles({'lat': '-1.2921', 'lng': '36.8219', 'radius_km': '50'})
        self.assertIn('nairobi-iron', handles)
        self.assertIn('hybrid-athletics', handles)
        self.assertNotIn('lagos-lift', handles)
        self.assertNotIn('cloud-strength', handles)

    def test_city_country_filters(self):
        self.assertIn('lagos-lift', self._handles({'city': 'Lagos'}))
        self.assertNotIn('lagos-lift', self._handles({'country': 'Kenya'}))

    def test_delivery_modes_exposed(self):
        res = self.client.get('/api/v1/gyms/', {'q': 'Hybrid Athletics'})
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        modes = res.json()['data'][0]['delivery_modes']
        self.assertIn('physical', modes)
        self.assertIn('virtual', modes)
        self.assertIn('hybrid', modes)
