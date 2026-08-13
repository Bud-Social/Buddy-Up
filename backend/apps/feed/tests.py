from django.test import TestCase
from django.utils import timezone
from rest_framework.test import APIClient
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken
from datetime import date
from common.utils import hash_dob
from apps.accounts.models import User
from apps.profiles.models import Profile
from .models import Post, Comment, Reaction


class FeedTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(email='feed@example.com', password='TestPass123!')
        self.user.dob_hash = hash_dob(date(2000, 6, 15))
        self.user.email_verified = True
        self.user.save()
        self.profile = Profile.objects.create(user=self.user, username='feeduser', display_name='Feed User')

        refresh = RefreshToken.for_user(self.user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')

    def test_create_text_post(self):
        data = {'post_type': 'text', 'body': 'Hello BuddyUp! 💪', 'visibility': 'public'}
        response = self.client.post('/api/v1/feed/create/', data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(Post.objects.count(), 1)
        self.assertEqual(Post.objects.first().body, 'Hello BuddyUp! 💪')

    def test_create_workout_log(self):
        data = {
            'post_type': 'workout_log',
            'body': 'Great session!',
            'workout_log_data': {'exercise': 'Deadlift', 'sets': 3, 'reps': 10, 'calories': 200},
            'visibility': 'public',
        }
        response = self.client.post('/api/v1/feed/create/', data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        post = Post.objects.first()
        self.assertEqual(post.workout_log_data['exercise'], 'Deadlift')

    def test_get_feed(self):
        Post.objects.create(author=self.profile, post_type='text', body='Post 1', visibility='public')
        Post.objects.create(author=self.profile, post_type='text', body='Post 2', visibility='public')
        response = self.client.get('/api/v1/feed/?tab=for_you')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data['data']), 2)

    def test_add_reaction(self):
        post = Post.objects.create(author=self.profile, post_type='text', body='React to me', visibility='public')
        response = self.client.post(f'/api/v1/feed/{post.id}/react/', {'reaction_type': 'fire'}, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(Reaction.objects.filter(post=post, author=self.profile, reaction_type='fire').exists())

    def test_add_comment(self):
        post = Post.objects.create(author=self.profile, post_type='text', body='Comment on me', visibility='public')
        response = self.client.post(f'/api/v1/feed/{post.id}/comments/', {'body': 'Great post!'}, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(Comment.objects.count(), 1)
        self.assertEqual(Comment.objects.first().body, 'Great post!')

    def test_repost_post(self):
        post = Post.objects.create(author=self.profile, post_type='text', body='Repost me', visibility='public')
        response = self.client.post(f'/api/v1/feed/{post.id}/repost/', {'quote_body': 'Check this out!'}, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(Post.objects.count(), 2)
        repost = Post.objects.exclude(id=post.id).first()
        self.assertTrue(repost.is_repost)

    def test_save_post(self):
        post = Post.objects.create(author=self.profile, post_type='text', body='Save me', visibility='public')
        response = self.client.post(f'/api/v1/feed/{post.id}/save/', format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_delete_own_post(self):
        post = Post.objects.create(author=self.profile, post_type='text', body='Delete me', visibility='public')
        response = self.client.delete(f'/api/v1/feed/{post.id}/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        post.refresh_from_db()
        self.assertTrue(post.is_deleted)
