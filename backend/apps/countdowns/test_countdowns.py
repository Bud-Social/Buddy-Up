from datetime import timedelta

from django.test import TestCase
from django.utils import timezone
from rest_framework.test import APIClient
from rest_framework import status

from apps.accounts.models import User
from apps.profiles.models import Profile
from apps.countdowns.models import CountdownTemplate, UserCountdown
from apps.countdowns.services import advance_matching_countdowns


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
        self.user.is_staff = True
        self.user.save()
        resp = self.client.post('/api/v1/countdowns/auto-advance/', {
            'signal': 'activity_walk',
        }, format='json')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertEqual(resp.data['data']['count'], 1)
        c.refresh_from_db()
        self.assertEqual(c.current_count, 3)

    def test_auto_advance_requires_signal(self):
        self.user.is_staff = True
        self.user.save()
        resp = self.client.post('/api/v1/countdowns/auto-advance/', {}, format='json')
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)

    def test_a_user_cannot_advance_their_own_countdown(self):
        """The advance belongs to the activity that triggers it, not the owner.

        Otherwise a streak could be inflated by tapping a button.
        """
        UserCountdown.objects.create(
            user=self.profile, template=self.template,
            countdown_type='automatic', unit='days',
            auto_advance_signal='activity_walk', current_count=2,
        )
        resp = self.client.post('/api/v1/countdowns/auto-advance/', {
            'signal': 'activity_walk',
        }, format='json')
        self.assertEqual(resp.status_code, status.HTTP_403_FORBIDDEN)

    def test_auto_advance_records_an_event(self):
        c = UserCountdown.objects.create(
            user=self.profile, template=self.template,
            countdown_type='automatic', unit='days',
            auto_advance_signal='activity_walk', current_count=2,
        )
        advance_matching_countdowns(self.profile, 'activity_walk')
        c.refresh_from_db()
        self.assertEqual(c.current_count, 3)
        events = list(c.events.all())
        self.assertEqual(len(events), 1)
        self.assertEqual(events[0].event_type, 'auto_advance')
        self.assertEqual(events[0].count_after, 3)

    def test_auto_advance_leaves_other_signals_alone(self):
        c = UserCountdown.objects.create(
            user=self.profile, template=self.template,
            countdown_type='automatic', unit='days',
            auto_advance_signal='gym_checkin', current_count=2,
        )
        advance_matching_countdowns(self.profile, 'activity_walk')
        c.refresh_from_db()
        self.assertEqual(c.current_count, 2)

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


class CountdownStreamTests(TestCase):
    """The event stream — what makes a reset non-destructive."""

    def setUp(self):
        self.user = User.objects.create_user(email='stream@example.com', password='TestPass123!')
        self.profile = Profile.objects.create(user=self.user, username='streamuser', display_name='Stream User')
        self.client = APIClient()
        self.client.force_authenticate(self.user)
        self.template = CountdownTemplate.objects.create(
            code='sobriety', title='Sobriety', unit='days',
            description='Days since last drink.', icon='🍻', color='#ef4444',
            default_target=0, sort_order=1,
        )

    def test_creating_a_countdown_starts_the_stream(self):
        resp = self.client.post('/api/v1/countdowns/', {
            'template': str(self.template.id),
            'countdown_type': 'manual',
            'unit': 'days',
        }, format='json')
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED)
        countdown = UserCountdown.objects.get(id=resp.data['data']['id'])
        events = list(countdown.events.all())
        self.assertEqual(len(events), 1)
        self.assertEqual(events[0].event_type, 'create')
        self.assertEqual(events[0].count_after, 0)

    def test_a_checkin_is_recorded_with_the_counter_value(self):
        c = UserCountdown.objects.create(
            user=self.profile, template=self.template,
            countdown_type='manual', unit='days', current_count=3,
        )
        self.client.post(f'/api/v1/countdowns/{c.id}/checkin/', format='json')
        event = c.events.first()
        self.assertEqual(event.event_type, 'checkin')
        self.assertEqual(event.count_after, 4)

    def test_a_reset_is_recorded_and_keeps_the_previous_run(self):
        c = UserCountdown.objects.create(
            user=self.profile, template=self.template,
            countdown_type='manual', unit='days', current_count=10,
        )
        self.client.post(f'/api/v1/countdowns/{c.id}/checkin/', format='json')
        self.client.post(f'/api/v1/countdowns/{c.id}/reset/', format='json')

        c.refresh_from_db()
        self.assertEqual(c.current_count, 0)
        # The streak restarts from the reset.
        self.assertIsNotNone(c.last_reset_at)

        events = list(c.events.order_by('occurred_at'))
        self.assertEqual([e.event_type for e in events], ['checkin', 'reset'])
        # The run that the reset ended is still on the record.
        self.assertEqual(events[0].count_after, 11)
        self.assertEqual(events[1].count_after, 0)

    def test_the_event_stream_is_readable(self):
        c = UserCountdown.objects.create(
            user=self.profile, template=self.template,
            countdown_type='manual', unit='days',
        )
        self.client.post(f'/api/v1/countdowns/{c.id}/checkin/', format='json')
        resp = self.client.get(f'/api/v1/countdowns/{c.id}/events/')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertEqual(len(resp.data['data']), 1)
        self.assertEqual(resp.data['data'][0]['event_type'], 'checkin')

    def test_the_event_stream_is_private(self):
        other = User.objects.create_user(email='otherstream@example.com', password='TestPass123!')
        Profile.objects.create(user=other, username='otherstream', display_name='Other')
        c = UserCountdown.objects.create(
            user=self.profile, template=self.template,
            countdown_type='manual', unit='days',
        )
        self.client.force_authenticate(other)
        resp = self.client.get(f'/api/v1/countdowns/{c.id}/events/')
        self.assertEqual(resp.status_code, status.HTTP_404_NOT_FOUND)

    def test_an_edit_is_recorded(self):
        c = UserCountdown.objects.create(
            user=self.profile, template=self.template,
            countdown_type='manual', unit='days',
        )
        self.client.patch(f'/api/v1/countdowns/{c.id}/', {
            'target_count': 30,
        }, format='json')
        self.assertTrue(c.events.filter(event_type='edit').exists())


class CountdownCheckInCadenceTests(TestCase):
    """A check-in unlocks once per unit — an hour, or 24 hours."""

    def setUp(self):
        self.user = User.objects.create_user(email='cadence@example.com', password='TestPass123!')
        self.profile = Profile.objects.create(user=self.user, username='cadence', display_name='Cadence')
        self.client = APIClient()
        self.client.force_authenticate(self.user)
        self.template = CountdownTemplate.objects.create(
            code='sobriety', title='Sobriety', unit='days',
            description='Days since last drink.', icon='🍻', color='#ef4444',
            default_target=0, sort_order=1,
        )

    def test_a_daily_countdown_cannot_be_checked_in_twice_in_a_day(self):
        c = UserCountdown.objects.create(
            user=self.profile, template=self.template,
            countdown_type='manual', unit='days', current_count=3,
            last_checkin_at=timezone.now() - timedelta(hours=2),
        )
        resp = self.client.post(f'/api/v1/countdowns/{c.id}/checkin/', format='json')
        self.assertEqual(resp.status_code, status.HTTP_409_CONFLICT)
        c.refresh_from_db()
        self.assertEqual(c.current_count, 3)
        self.assertIn('opens in', resp.data['message'])

    def test_a_daily_countdown_opens_again_after_24_hours(self):
        c = UserCountdown.objects.create(
            user=self.profile, template=self.template,
            countdown_type='manual', unit='days', current_count=3,
            last_checkin_at=timezone.now() - timedelta(hours=25),
        )
        resp = self.client.post(f'/api/v1/countdowns/{c.id}/checkin/', format='json')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        c.refresh_from_db()
        self.assertEqual(c.current_count, 4)

    def test_an_hourly_countdown_opens_again_after_an_hour(self):
        c = UserCountdown.objects.create(
            user=self.profile, template=self.template,
            countdown_type='manual', unit='hours', current_count=3,
            last_checkin_at=timezone.now() - timedelta(minutes=70),
        )
        resp = self.client.post(f'/api/v1/countdowns/{c.id}/checkin/', format='json')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        c.refresh_from_db()
        self.assertEqual(c.current_count, 4)

    def test_an_hourly_countdown_cannot_be_checked_in_twice_within_the_hour(self):
        c = UserCountdown.objects.create(
            user=self.profile, template=self.template,
            countdown_type='manual', unit='hours', current_count=3,
            last_checkin_at=timezone.now() - timedelta(minutes=20),
        )
        resp = self.client.post(f'/api/v1/countdowns/{c.id}/checkin/', format='json')
        self.assertEqual(resp.status_code, status.HTTP_409_CONFLICT)
        c.refresh_from_db()
        self.assertEqual(c.current_count, 3)

    def test_the_next_checkin_time_is_reported(self):
        unlock = timezone.now() + timedelta(hours=3)
        c = UserCountdown.objects.create(
            user=self.profile, template=self.template,
            countdown_type='manual', unit='days', current_count=1,
            last_checkin_at=unlock - timedelta(days=1),
        )
        resp = self.client.get(f'/api/v1/countdowns/{c.id}/')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertIsNotNone(resp.data['data']['next_checkin_at'])


class CountdownSignalTests(TestCase):
    """An automatic countdown is defined by the signal it advances on."""

    def setUp(self):
        self.user = User.objects.create_user(email='signal@example.com', password='TestPass123!')
        self.profile = Profile.objects.create(user=self.user, username='signal', display_name='Signal')
        self.client = APIClient()
        self.client.force_authenticate(self.user)
        self.template = CountdownTemplate.objects.create(
            code='walking_days', title='Walking Days', unit='days',
            description='Days with a logged walk.', icon='🚶', color='#10b981',
            default_target=0, sort_order=5,
        )

    def test_an_automatic_countdown_needs_a_signal(self):
        resp = self.client.post('/api/v1/countdowns/', {
            'template': str(self.template.id),
            'countdown_type': 'automatic',
            'unit': 'days',
        }, format='json')
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('auto_advance_signal', resp.data['errors'])

    def test_an_automatic_countdown_rejects_an_unknown_signal(self):
        resp = self.client.post('/api/v1/countdowns/', {
            'template': str(self.template.id),
            'countdown_type': 'automatic',
            'unit': 'days',
            'auto_advance_signal': 'made_up_signal',
        }, format='json')
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)

    def test_a_manual_countdown_must_not_carry_a_signal(self):
        resp = self.client.post('/api/v1/countdowns/', {
            'template': str(self.template.id),
            'countdown_type': 'manual',
            'unit': 'days',
            'auto_advance_signal': 'activity_walk',
        }, format='json')
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)

    def test_an_automatic_countdown_accepts_a_known_signal(self):
        resp = self.client.post('/api/v1/countdowns/', {
            'template': str(self.template.id),
            'countdown_type': 'automatic',
            'unit': 'days',
            'auto_advance_signal': 'activity_walk',
        }, format='json')
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED)
        self.assertEqual(resp.data['data']['auto_advance_signal'], 'activity_walk')

    def test_the_signals_are_listed(self):
        resp = self.client.get('/api/v1/countdowns/signals/')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        keys = {s['key'] for s in resp.data['data']}
        self.assertIn('activity_walk', keys)
        self.assertIn('gym_checkin', keys)


class CountdownSignalWiringTests(TestCase):
    """An activity is what an automatic countdown waits for."""

    def setUp(self):
        self.user = User.objects.create_user(email='wire@example.com', password='TestPass123!')
        self.profile = Profile.objects.create(user=self.user, username='wire', display_name='Wire')
        self.client = APIClient()
        self.client.force_authenticate(self.user)
        self.template = CountdownTemplate.objects.create(
            code='walking_days', title='Walking Days', unit='days',
            description='Days with a logged walk.', icon='🚶', color='#10b981',
            default_target=0, sort_order=5,
        )

    def test_a_logged_walk_advances_the_walking_days_countdown(self):
        c = UserCountdown.objects.create(
            user=self.profile, template=self.template,
            countdown_type='automatic', unit='days',
            auto_advance_signal='activity_walk', current_count=2,
        )
        resp = self.client.post('/api/v1/analytics/activities/', {
            'activity_type': 'walk',
            'duration_seconds': 1800,
            'distance_meters': 2000,
        }, format='json')
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED)
        c.refresh_from_db()
        self.assertEqual(c.current_count, 3)
        self.assertTrue(c.events.filter(event_type='auto_advance').exists())

    def test_a_run_does_not_advance_the_walking_days_countdown(self):
        c = UserCountdown.objects.create(
            user=self.profile, template=self.template,
            countdown_type='automatic', unit='days',
            auto_advance_signal='activity_walk', current_count=2,
        )
        self.client.post('/api/v1/analytics/activities/', {
            'activity_type': 'run',
            'duration_seconds': 1800,
            'distance_meters': 3000,
        }, format='json')
        c.refresh_from_db()
        self.assertEqual(c.current_count, 2)

    def test_a_logged_workout_advances_the_workout_countdown(self):
        c = UserCountdown.objects.create(
            user=self.profile, template=self.template,
            countdown_type='automatic', unit='days',
            auto_advance_signal='workout_logged', current_count=0,
        )
        resp = self.client.post('/api/v1/analytics/workouts/', {
            'workout_type': 'strength',
            'exercise': 'Bench press',
            'sets': 3,
            'reps': 8,
        }, format='json')
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED)
        c.refresh_from_db()
        self.assertEqual(c.current_count, 1)


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


class RoutineTests(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(email='rt@example.com', password='TestPass123!')
        self.profile = Profile.objects.create(user=self.user, username='rtuser', display_name='RT User')
        self.client = APIClient()
        self.client.force_authenticate(self.user)

    def test_gym_and_custom_other_types_are_accepted(self):
        gym = self.client.post('/api/v1/countdowns/routines/', {
            'type': 'gym', 'name': 'Gym 4x', 'target': 4, 'unit': 'sessions',
        }, format='json')
        self.assertEqual(gym.status_code, status.HTTP_201_CREATED)

        other = self.client.post('/api/v1/countdowns/routines/', {
            'type': 'other', 'custom_name': 'Cold shower', 'target': 1, 'unit': 'session',
        }, format='json')
        self.assertEqual(other.status_code, status.HTTP_201_CREATED)
        self.assertEqual(other.data['data']['custom_name'], 'Cold shower')
        self.assertEqual(other.data['data']['display_name'], 'Cold shower')

        missing = self.client.post('/api/v1/countdowns/routines/', {
            'type': 'other', 'name': '', 'target': 1, 'unit': 'session',
        }, format='json')
        self.assertEqual(missing.status_code, status.HTTP_400_BAD_REQUEST)

    def test_manual_checkin_and_reorder(self):
        first = self.client.post('/api/v1/countdowns/routines/', {
            'type': 'workout', 'name': 'Strength', 'tracking': 'manual',
        }, format='json').data['data']
        second = self.client.post('/api/v1/countdowns/routines/', {
            'type': 'run', 'name': 'Run',
        }, format='json').data['data']

        reordered = self.client.post('/api/v1/countdowns/routines/reorder/', {
            'ordered_ids': [second['id'], first['id']],
        }, format='json')
        self.assertEqual(reordered.status_code, status.HTTP_200_OK)
        self.assertEqual(reordered.data['data'][0]['id'], second['id'])

        checked = self.client.post(f"/api/v1/countdowns/routines/{first['id']}/checkin/", {
            'value': 30, 'note': 'Done',
        }, format='json')
        self.assertEqual(checked.status_code, status.HTTP_201_CREATED)
        self.assertEqual(checked.data['data']['routine']['streak'], 1)
        self.assertEqual(checked.data['data']['check_in']['source'], 'manual')

    def test_highlights_upload_and_delete(self):
        from django.core.files.uploadedfile import SimpleUploadedFile
        routine = self.client.post('/api/v1/countdowns/routines/', {
            'type': 'gym', 'name': 'Gym',
        }, format='json').data['data']
        image = SimpleUploadedFile('shot.jpg', b'fake-bytes', 'image/jpeg')
        response = self.client.post(
            f"/api/v1/countdowns/routines/{routine['id']}/highlights/",
            {'kind': 'photo', 'file': image}, format='multipart',
        )
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        highlight_id = response.data['data']['id']

        listed = self.client.get(f"/api/v1/countdowns/routines/{routine['id']}/highlights/?kind=photo")
        self.assertEqual(len(listed.data['data']), 1)

        deleted = self.client.delete(
            f"/api/v1/countdowns/routines/{routine['id']}/highlights/{highlight_id}/"
        )
        self.assertEqual(deleted.status_code, status.HTTP_200_OK)

    def test_share_as_story_keeps_overlay_position(self):
        from apps.feed.models import Post

        routine = self.client.post('/api/v1/countdowns/routines/', {
            'type': 'gym', 'name': 'Gym', 'target': 4, 'unit': 'sessions',
        }, format='json').data['data']

        response = self.client.post(f"/api/v1/countdowns/routines/{routine['id']}/share/", {
            'as_story': True, 'overlay_position': 'bottom',
        }, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        post = Post.objects.get(id=response.data['data']['post_id'])
        self.assertEqual(post.post_type, 'moment')
        self.assertEqual(post.workout_log_data['overlay_position'], 'bottom')
        self.assertEqual(post.workout_log_data['routine_name'], 'Gym')


class RoutineAutoDetectionTests(TestCase):
    """A repeated activity becomes a routine — without asking, but opt-out."""

    def setUp(self):
        self.user = User.objects.create_user(email='auto@example.com', password='TestPass123!')
        self.profile = Profile.objects.create(user=self.user, username='autouser', display_name='Auto User')
        self.client = APIClient()
        self.client.force_authenticate(self.user)

    def _activity(self, days_ago, **kwargs):
        from apps.analytics.models import ActivityRecord

        return ActivityRecord.objects.create(
            user=self.profile,
            activity_type=kwargs.pop('activity_type', 'walk'),
            started_at=timezone.now() - timedelta(days=days_ago),
            duration_seconds=kwargs.pop('duration_seconds', 1800),
            distance_meters=kwargs.pop('distance_meters', 2400),
            steps=kwargs.pop('steps', 3200),
            **kwargs,
        )

    def test_three_separate_days_create_a_routine(self):
        from apps.countdowns.services import maybe_create_activity_routine

        self._activity(1)
        self._activity(3)
        latest = self._activity(5)

        routine = maybe_create_activity_routine(latest)

        self.assertIsNotNone(routine)
        self.assertTrue(routine.auto_generated)
        self.assertEqual(routine.type, 'walk')
        self.assertEqual(routine.unit, 'steps')
        self.assertEqual(routine.target % 100, 0)
        self.assertEqual(len(routine.days), 3)
        self.assertTrue(routine.name.startswith(('Morning ', 'Afternoon ', 'Evening ', 'Late ')))

    def test_three_sessions_on_one_day_is_not_a_habit(self):
        from apps.countdowns.models import Routine
        from apps.countdowns.services import maybe_create_activity_routine

        self._activity(0)
        self._activity(0)
        latest = self._activity(0)

        self.assertIsNone(maybe_create_activity_routine(latest))
        self.assertEqual(Routine.objects.count(), 0)

    def test_opt_out_stops_automatic_routines(self):
        from apps.countdowns.models import Routine
        from apps.countdowns.services import maybe_create_activity_routine

        self.profile.auto_routines_enabled = False
        self.profile.save(update_fields=['auto_routines_enabled'])
        self._activity(1)
        self._activity(2)
        latest = self._activity(3)

        self.assertIsNone(maybe_create_activity_routine(latest))
        self.assertEqual(Routine.objects.count(), 0)

    def test_an_existing_routine_is_not_duplicated(self):
        from apps.countdowns.models import Routine
        from apps.countdowns.services import maybe_create_activity_routine

        Routine.objects.create(user=self.profile, type='walk', name='My walk')
        self._activity(1)
        self._activity(2)
        latest = self._activity(3)

        self.assertIsNone(maybe_create_activity_routine(latest))
        self.assertEqual(Routine.objects.filter(type='walk').count(), 1)

    def test_workout_logs_create_a_workout_routine(self):
        from apps.analytics.models import WorkoutLog
        from apps.countdowns.models import Routine
        from apps.countdowns.services import maybe_create_workout_routine

        for days in (1, 3, 5):
            WorkoutLog.objects.create(
                user=self.profile,
                workout_type='strength',
                duration_minutes=45,
                performed_at=timezone.now() - timedelta(days=days),
            )
        latest = WorkoutLog.objects.order_by('-performed_at').first()

        routine = maybe_create_workout_routine(latest)
        self.assertIsNotNone(routine)
        self.assertEqual(routine.type, 'workout')
        self.assertEqual(routine.unit, 'min')
        self.assertEqual(Routine.objects.filter(type='workout').count(), 1)

    def test_logging_an_activity_through_the_api_triggers_detection(self):
        from apps.countdowns.models import Routine

        for days, distance in ((1, 2000), (3, 2600), (5, 3000)):
            response = self.client.post('/api/v1/analytics/activities/', {
                'activity_type': 'run',
                'duration_seconds': 1800,
                'distance_meters': distance,
                'started_at': (timezone.now() - timedelta(days=days)).isoformat(),
            }, format='json')
            self.assertEqual(response.status_code, status.HTTP_201_CREATED, response.data)

        routine = Routine.objects.filter(user=self.profile, type='run').first()
        self.assertIsNotNone(routine)
        self.assertTrue(routine.auto_generated)

    def test_the_preference_round_trips_from_the_own_profile_endpoint(self):
        response = self.client.patch('/api/v1/profiles/me/', {
            'auto_routines_enabled': False,
        }, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertFalse(response.data['data']['auto_routines_enabled'])

        fetched = self.client.get('/api/v1/profiles/me/')
        self.assertEqual(fetched.status_code, status.HTTP_200_OK)
        self.assertFalse(fetched.data['data']['auto_routines_enabled'])
