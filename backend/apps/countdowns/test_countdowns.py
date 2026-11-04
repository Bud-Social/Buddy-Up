from django.test import TestCase
from rest_framework.test import APIClient
from rest_framework import status

from apps.accounts.models import User
from apps.profiles.models import Profile
from apps.countdowns.models import CountdownTemplate, UserCountdown


class CountdownTemplateTests(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(email='ct@example.com', password='TestPass123!')
        self.profile = Profile.objects.create(user=self.user, username='ctuser', display_name='CT User')
        self.client = APIClient()
        self.client.force_authenticate(self.user)

    def test_list_templates(self):
        CountdownTemplate.objects.create(
            code='sobriety', title='Sobriety', unit='days',
            description='Days since last drink.', icon='🍻', color='#ef4444',
            default_target=0, sort_order=1,
        )
        resp = self.client.get('/api/v1/countdowns/templates/')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertEqual(len(resp.data['data']), 1)
        self.assertEqual(resp.data['data'][0]['code'], 'sobriety')


class UserCountdownTests(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(email='uc@example.com', password='TestPass123!')
        self.profile = Profile.objects.create(user=self.user, username='ucuser', display_name='UC User')
        self.client = APIClient()
        self.client.force_authenticate(self.user)
        self.template = CountdownTemplate.objects.create(
            code='sobriety', title='Sobriety', unit='days',
            description='Days since last drink.', icon='🍻', color='#ef4444',
            default_target=0, sort_order=1,
        )

    def test_create_countdown(self):
        resp = self.client.post('/api/v1/countdowns/', {
            'template': str(self.template.id),
            'countdown_type': 'manual',
            'unit': 'days',
        }, format='json')
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED)
        self.assertEqual(resp.data['data']['display_reason'], 'Sobriety')
        self.assertEqual(resp.data['data']['current_count'], 0)

    def test_create_custom_countdown(self):
        resp = self.client.post('/api/v1/countdowns/', {
            'custom_reason': 'Days without coffee',
            'countdown_type': 'manual',
            'unit': 'days',
        }, format='json')
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED)
        self.assertEqual(resp.data['data']['custom_reason'], 'Days without coffee')
        self.assertEqual(resp.data['data']['display_reason'], 'Days without coffee')

    def test_create_without_template_or_reason_fails(self):
        resp = self.client.post('/api/v1/countdowns/', {
            'countdown_type': 'manual',
            'unit': 'days',
        }, format='json')
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)

    def test_list_countdowns(self):
        UserCountdown.objects.create(
            user=self.profile, template=self.template,
            countdown_type='manual', unit='days', current_count=5,
        )
        resp = self.client.get('/api/v1/countdowns/')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertEqual(len(resp.data['data']), 1)

    def test_checkin_advances_manual_countdown(self):
        c = UserCountdown.objects.create(
            user=self.profile, template=self.template,
            countdown_type='manual', unit='days', current_count=3,
        )
        resp = self.client.post(f'/api/v1/countdowns/{c.id}/checkin/', format='json')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertEqual(resp.data['data']['current_count'], 4)

    def test_checkin_rejects_automatic_countdown(self):
        c = UserCountdown.objects.create(
            user=self.profile, template=self.template,
            countdown_type='automatic', unit='days',
            auto_advance_signal='activity_walk', current_count=3,
        )
        resp = self.client.post(f'/api/v1/countdowns/{c.id}/checkin/', format='json')
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)

    def test_reset_countdown(self):
        c = UserCountdown.objects.create(
            user=self.profile, template=self.template,
            countdown_type='manual', unit='days', current_count=10,
        )
        resp = self.client.post(f'/api/v1/countdowns/{c.id}/reset/', format='json')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertEqual(resp.data['data']['current_count'], 0)
        self.assertIsNone(resp.data['data']['completed_at'])

    def test_update_countdown(self):
        c = UserCountdown.objects.create(
            user=self.profile, template=self.template,
            countdown_type='manual', unit='days', current_count=3,
        )
        resp = self.client.patch(f'/api/v1/countdowns/{c.id}/', {
            'custom_reason': 'Updated reason',
            'target_count': 30,
        }, format='json')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertEqual(resp.data['data']['custom_reason'], 'Updated reason')
        self.assertEqual(resp.data['data']['target_count'], 30)

    def test_delete_countdown(self):
        c = UserCountdown.objects.create(
            user=self.profile, template=self.template,
            countdown_type='manual', unit='days',
        )
        resp = self.client.delete(f'/api/v1/countdowns/{c.id}/')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertFalse(UserCountdown.objects.filter(id=c.id).exists())

    def test_auto_advance(self):
        c = UserCountdown.objects.create(
            user=self.profile, template=self.template,
            countdown_type='automatic', unit='days',
            auto_advance_signal='activity_walk', current_count=2,
        )
        resp = self.client.post('/api/v1/countdowns/auto-advance/', {
            'signal': 'activity_walk',
        }, format='json')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertEqual(resp.data['data']['count'], 1)
        c.refresh_from_db()
        self.assertEqual(c.current_count, 3)

    def test_auto_advance_requires_signal(self):
        resp = self.client.post('/api/v1/countdowns/auto-advance/', {}, format='json')
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)

    def test_users_only_see_own_countdowns(self):
        other_user = User.objects.create_user(email='other@example.com', password='TestPass123!')
        Profile.objects.create(user=other_user, username='otheruser', display_name='Other')
        c = UserCountdown.objects.create(
            user=self.profile, template=self.template,
            countdown_type='manual', unit='days', current_count=5,
        )
        # Other user cannot access this countdown
        self.client.force_authenticate(other_user)
        resp = self.client.get(f'/api/v1/countdowns/{c.id}/')
        self.assertEqual(resp.status_code, status.HTTP_404_NOT_FOUND)
        # Other user's list doesn't include it
        resp = self.client.get('/api/v1/countdowns/')
        self.assertEqual(len(resp.data['data']), 0)


class CountdownTemplateSeedTests(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(email='seed@example.com', password='TestPass123!')
        self.user.is_staff = True
        self.user.save()
        self.client = APIClient()
        self.client.force_authenticate(self.user)

    def test_seed_templates(self):
        resp = self.client.post('/api/v1/countdowns/templates/seed/', format='json')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertGreater(resp.data['data']['total'], 0)
        self.assertTrue(CountdownTemplate.objects.filter(code='sobriety').exists())

    def test_seed_templates_idempotent(self):
        self.client.post('/api/v1/countdowns/templates/seed/', format='json')
        first_count = CountdownTemplate.objects.count()
        resp = self.client.post('/api/v1/countdowns/templates/seed/', format='json')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertEqual(CountdownTemplate.objects.count(), first_count)

    def test_non_staff_cannot_seed(self):
        self.user.is_staff = False
        self.user.save()
        resp = self.client.post('/api/v1/countdowns/templates/seed/', format='json')
        self.assertEqual(resp.status_code, status.HTTP_403_FORBIDDEN)
