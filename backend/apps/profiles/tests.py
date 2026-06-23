from django.test import TestCase
from rest_framework.test import APIClient
from rest_framework import status
from datetime import date
from common.utils import hash_dob
from apps.accounts.models import User
from .models import Profile, BuddyRelationship, FollowRelationship, BlockRelationship


class BuddySystemTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user_a = User.objects.create_user(email='a@example.com', password='TestPass123!')
        self.user_a.dob_hash = hash_dob(date(2000, 6, 15))
        self.user_a.is_adult = True
        self.user_a.save()
        self.profile_a = Profile.objects.create(user=self.user_a, username='usera', display_name='User A')

        self.user_b = User.objects.create_user(email='b@example.com', password='TestPass123!')
        self.user_b.dob_hash = hash_dob(date(2000, 6, 15))
        self.user_b.is_adult = True
        self.user_b.save()
        self.profile_b = Profile.objects.create(user=self.user_b, username='userb', display_name='User B')

        self.login_response = self.client.post('/api/v1/auth/login/',
            {'email': 'a@example.com', 'password': 'TestPass123!'}, format='json')
        self.token = self.login_response.data['data']['access']
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {self.token}')

    def test_send_buddy_request(self):
        response = self.client.post(f'/api/v1/profiles/userb/buddy/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(BuddyRelationship.objects.filter(
            from_user=self.profile_a, to_user=self.profile_b, status='pending'
        ).exists())

    def test_accept_buddy_request(self):
        BuddyRelationship.objects.create(from_user=self.profile_b, to_user=self.profile_a, status='pending')
        response = self.client.post(f'/api/v1/profiles/userb/buddy/accept/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(BuddyRelationship.objects.filter(
            from_user=self.profile_b, to_user=self.profile_a, status='confirmed'
        ).exists())

    def test_decline_buddy_request(self):
        BuddyRelationship.objects.create(from_user=self.profile_b, to_user=self.profile_a, status='pending')
        response = self.client.post(f'/api/v1/profiles/userb/buddy/decline/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(BuddyRelationship.objects.filter(
            from_user=self.profile_b, to_user=self.profile_a, status='declined'
        ).exists())

    def test_cannot_buddy_self(self):
        response = self.client.post(f'/api/v1/profiles/usera/buddy/')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_follow_user(self):
        response = self.client.post(f'/api/v1/profiles/userb/follow/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(FollowRelationship.objects.filter(
            follower=self.profile_a, followee=self.profile_b
        ).exists())

    def test_unfollow_user(self):
        FollowRelationship.objects.create(follower=self.profile_a, followee=self.profile_b)
        response = self.client.delete(f'/api/v1/profiles/userb/follow/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertFalse(FollowRelationship.objects.filter(
            follower=self.profile_a, followee=self.profile_b
        ).exists())

    def test_block_user(self):
        response = self.client.post(f'/api/v1/profiles/userb/block/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(BlockRelationship.objects.filter(
            blocker=self.profile_a, blocked=self.profile_b
        ).exists())

    def test_block_removes_buddy(self):
        BuddyRelationship.objects.create(from_user=self.profile_a, to_user=self.profile_b, status='confirmed')
        self.client.post(f'/api/v1/profiles/userb/block/')
        self.assertFalse(BuddyRelationship.objects.filter(
            from_user=self.profile_a, to_user=self.profile_b
        ).exists())


class ProfileTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(email='profile@example.com', password='TestPass123!')
        self.user.dob_hash = hash_dob(date(2000, 6, 15))
        self.user.save()
        self.profile = Profile.objects.create(user=self.user, username='profileuser', display_name='Profile User',
                                               bio='Test bio', location_city='Nairobi')

        login_res = self.client.post('/api/v1/auth/login/',
            {'email': 'profile@example.com', 'password': 'TestPass123!'}, format='json')
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {login_res.data["data"]["access"]}')

    def test_get_my_profile(self):
        response = self.client.get('/api/v1/profiles/me/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['data']['username'], 'profileuser')
        self.assertEqual(response.data['data']['bio'], 'Test bio')

    def test_update_profile(self):
        response = self.client.patch('/api/v1/profiles/me/', {'bio': 'Updated bio'}, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.profile.refresh_from_db()
        self.assertEqual(self.profile.bio, 'Updated bio')

    def test_get_public_profile(self):
        response = self.client.get('/api/v1/profiles/profileuser/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['data']['display_name'], 'Profile User')
