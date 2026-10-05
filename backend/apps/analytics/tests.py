from django.test import SimpleTestCase, TestCase
from rest_framework.test import APIClient
from rest_framework import status

from apps.accounts.models import User
from apps.profiles.models import Profile

from .models import AnalyticsEvent, WorkoutLog, WORKOUT_TYPE_SPECS, all_category_keys
from .serializers import ActivityRecordSerializer


class AnalyticsValidationTests(SimpleTestCase):
    def test_rejects_negative_activity_values(self):
        serializer = ActivityRecordSerializer(data={'duration_seconds': -1})
        self.assertFalse(serializer.is_valid())


class SummaryContractTests(TestCase):
    """The summary response must always include every section key the
    clients read unconditionally — a missing key crashes the apps."""

    def setUp(self):
        self.user = User.objects.create_user(email='summary@example.com', password='TestPass123!')
        self.profile = Profile.objects.create(user=self.user, username='summaryuser', display_name='Summary User')
        self.client = APIClient()
        self.client.force_authenticate(self.user)

    def test_summary_includes_nutrition_block(self):
        from . import engine
        summary = engine.build_summary(self.profile, 'month')
        self.assertIn('nutrition', summary)
        for key in ('count', 'total_calories', 'total_protein_g',
                    'total_carbs_g', 'total_fat_g', 'by_type',
                    'avg_daily_calories', 'recent'):
            self.assertIn(key, summary['nutrition'])

    def test_summary_endpoint_returns_nutrition(self):
        resp = self.client.get('/api/v1/analytics/summary/', {'period': 'month'})
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertIn('nutrition', resp.data['data'])


class EventIngestionTests(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(email='events@example.com', password='TestPass123!')
        self.profile = Profile.objects.create(user=self.user, username='eventsuser', display_name='Events User')
        self.client = APIClient()
        self.client.force_authenticate(self.user)

    def _post(self, events, **overrides):
        payload = {'events': events, **overrides}
        return self.client.post('/api/v1/analytics/events/', payload, format='json')

    def test_batch_accepted_and_stored(self):
        resp = self._post([
            {'event_name': 'feed.post_impression', 'object_type': 'post', 'object_id': 'abc',
             'properties': {'feed_tab': 'for_you', 'rank': 3}, 'consent': {'analytics': True}},
            {'event_name': 'feed.tab_selected', 'properties': {'feed_tab': 'videos'}, 'consent': {'analytics': True}},
        ])
        self.assertEqual(resp.status_code, status.HTTP_202_ACCEPTED)
        self.assertEqual(resp.data['data']['accepted'], 2)
        self.assertEqual(AnalyticsEvent.objects.count(), 2)
        event = AnalyticsEvent.objects.get(event_name='feed.post_impression')
        self.assertEqual(event.actor, self.profile)
        self.assertEqual(event.properties['rank'], 3)

    def test_missing_consent_is_skipped_not_stored(self):
        resp = self._post([
            {'event_name': 'feed.loaded', 'properties': {}},
            {'event_name': 'feed.loaded', 'properties': {}, 'consent': {'analytics': False}},
        ])
        self.assertEqual(resp.status_code, status.HTTP_202_ACCEPTED)
        self.assertEqual(resp.data['data']['skipped'], 2)
        self.assertEqual(AnalyticsEvent.objects.count(), 0)

    def test_invalid_event_name_rejected(self):
        resp = self._post([{'event_name': 'Bad Name!', 'consent': {'analytics': True}}])
        self.assertEqual(resp.data['data']['skipped'], 1)
        self.assertEqual(AnalyticsEvent.objects.count(), 0)

    def test_oversized_batch_rejected(self):
        resp = self._post([
            {'event_name': 'feed.loaded', 'consent': {'analytics': True}},
        ] * 51)
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)

    def test_anonymous_requires_anonymous_id(self):
        client = APIClient()
        resp = client.post('/api/v1/analytics/events/', {'events': [
            {'event_name': 'feed.loaded', 'consent': {'analytics': True}},
        ]}, format='json')
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)

        resp = client.post('/api/v1/analytics/events/', {
            'anonymous_id': 'anon-123',
            'events': [{'event_name': 'feed.loaded', 'consent': {'analytics': True}}],
        }, format='json')
        self.assertEqual(resp.status_code, status.HTTP_202_ACCEPTED)
        self.assertEqual(AnalyticsEvent.objects.filter(anonymous_id='anon-123').count(), 1)


class WorkoutCategoryTests(TestCase):
    """Guided workouts record which muscle group was trained, and the
    history can be filtered by it."""

    def setUp(self):
        self.user = User.objects.create_user(email='athlete@example.com', password='TestPass123!')
        self.profile = Profile.objects.create(user=self.user, username='athlete', display_name='Athlete')
        self.client = APIClient()
        self.client.force_authenticate(user=self.user)

    def _log(self, **kwargs):
        payload = {
            'workout_type': 'strength',
            'duration_minutes': 45,
            **kwargs,
        }
        return self.client.post('/api/v1/analytics/workouts/', payload, format='json')

    def test_create_accepts_category(self):
        resp = self._log(category='upper', exercise='Bench press')
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED, resp.content)
        self.assertEqual(resp.data['data']['category'], 'upper')

    def test_create_defaults_to_blank_category(self):
        resp = self._log(exercise='Squats')
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED, resp.content)
        self.assertEqual(resp.data['data']['category'], '')

    def test_create_rejects_unknown_category(self):
        resp = self._log(category='elbows')
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)

    def test_filter_by_category(self):
        self._log(category='upper', exercise='Bench press')
        self._log(category='lower', exercise='Squat')

        resp = self.client.get('/api/v1/analytics/workouts/', {'category': 'upper'})
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        results = resp.data['data']
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]['category'], 'upper')


class WorkoutTaxonomyTests(TestCase):
    """WORKOUT_TYPE_SPECS is the source of truth: the model choices and the
    /workout-types/ endpoint must both mirror it exactly."""

    def test_model_choices_match_specs(self):
        self.assertEqual(
            [key for key, _ in WorkoutLog.WORKOUT_TYPES],
            list(WORKOUT_TYPE_SPECS),
        )
        self.assertEqual(
            [key for key, _ in WorkoutLog.CATEGORY_CHOICES],
            all_category_keys(),
        )

    def test_every_type_category_is_a_valid_choice(self):
        valid = {key for key, _ in WorkoutLog.CATEGORY_CHOICES}
        for workout_type, spec in WORKOUT_TYPE_SPECS.items():
            for category in spec['categories']:
                with self.subTest(workout_type=workout_type, category=category):
                    self.assertIn(category, valid)

    def test_spec_shape(self):
        for workout_type, spec in WORKOUT_TYPE_SPECS.items():
            with self.subTest(workout_type=workout_type):
                self.assertEqual(set(spec), {'label', 'categories', 'fields', 'measured'})
                self.assertTrue(spec['label'])
                self.assertIsInstance(spec['categories'], list)
                self.assertIsInstance(spec['fields'], list)
                self.assertIsInstance(spec['measured'], bool)


class WorkoutTypeEndpointTests(TestCase):
    """Clients read the taxonomy from the API instead of hardcoding it."""

    def setUp(self):
        self.anon = APIClient()

    def test_endpoint_is_public(self):
        resp = self.anon.get('/api/v1/analytics/workout-types/')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertTrue(resp.data['success'])
        self.assertIsNone(resp.data['errors'])

    def test_endpoint_returns_full_spec_dict(self):
        resp = self.anon.get('/api/v1/analytics/workout-types/')
        data = resp.data['data']
        self.assertEqual(data['workout_types'], WORKOUT_TYPE_SPECS)
        self.assertEqual(data['categories'], all_category_keys())
        for key in ('strength', 'hiit', 'cardio', 'running', 'walking', 'cycling',
                    'swimming', 'climbing', 'rowing', 'dance', 'yoga', 'pilates',
                    'mobility', 'sport', 'boxing', 'martial_arts', 'other'):
            self.assertIn(key, data['workout_types'])
        self.assertEqual(data['workout_types']['hiit']['fields'], ['rounds'])
        self.assertIn('upper', data['workout_types']['strength']['categories'])
        self.assertEqual(data['workout_types']['climbing']['measured'], False)


class WorkoutCategoryPerTypeTests(TestCase):
    """A category is only valid for the workout types that declare it."""

    def setUp(self):
        self.user = User.objects.create_user(email='typed@example.com', password='TestPass123!')
        self.profile = Profile.objects.create(user=self.user, username='typed', display_name='Typed')
        self.client = APIClient()
        self.client.force_authenticate(user=self.user)

    def _log(self, **kwargs):
        payload = {'workout_type': 'strength', 'duration_minutes': 30, **kwargs}
        return self.client.post('/api/v1/analytics/workouts/', payload, format='json')

    def test_category_accepted_for_its_type(self):
        for category in WORKOUT_TYPE_SPECS['strength']['categories']:
            with self.subTest(category=category):
                resp = self._log(category=category)
                self.assertEqual(resp.status_code, status.HTTP_201_CREATED, resp.content)
                self.assertEqual(resp.data['data']['category'], category)

    def test_yoga_rejects_strength_category(self):
        resp = self._log(workout_type='yoga', category='upper', exercise='Vinyasa flow')
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('category', resp.data['errors'])

    def test_yoga_accepts_its_own_categories(self):
        for category in ('flexibility', 'balance', 'mindfulness'):
            with self.subTest(category=category):
                resp = self._log(workout_type='yoga', category=category)
                self.assertEqual(resp.status_code, status.HTTP_201_CREATED, resp.content)

    def test_hiit_and_sport_accept_their_own_categories(self):
        for workout_type, category in (('hiit', 'cardio'), ('hiit', 'core'),
                                       ('sport', 'football'), ('sport', 'netball'),
                                       ('mobility', 'hips'), ('pilates', 'posture')):
            with self.subTest(workout_type=workout_type, category=category):
                resp = self._log(workout_type=workout_type, category=category)
                self.assertEqual(resp.status_code, status.HTTP_201_CREATED, resp.content)

    def test_type_without_categories_rejects_all(self):
        for workout_type in ('cardio', 'running', 'climbing', 'boxing', 'other'):
            with self.subTest(workout_type=workout_type):
                resp = self._log(workout_type=workout_type, category='upper')
                self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)

    def test_blank_category_allowed_for_every_type(self):
        for workout_type in WORKOUT_TYPE_SPECS:
            with self.subTest(workout_type=workout_type):
                resp = self._log(workout_type=workout_type)
                self.assertEqual(resp.status_code, status.HTTP_201_CREATED, resp.content)
                self.assertEqual(resp.data['data']['category'], '')

    def test_unknown_workout_type_rejected(self):
        for bogus in ('kettlebell', 'STRENGTH', 'crossfit', ''):
            with self.subTest(workout_type=bogus):
                resp = self._log(workout_type=bogus)
                self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)

    def test_unknown_category_rejected(self):
        resp = self._log(category='elbows')
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)


class WorkoutProvenanceExtrasTests(TestCase):
    """Type-specific extras (rounds/style/focus/sport) are not columns — they
    persist in provenance and read back from it."""

    def setUp(self):
        self.user = User.objects.create_user(email='extras@example.com', password='TestPass123!')
        self.profile = Profile.objects.create(user=self.user, username='extras', display_name='Extras')
        self.client = APIClient()
        self.client.force_authenticate(user=self.user)

    def _log(self, **kwargs):
        payload = {'workout_type': 'strength', 'duration_minutes': 30, **kwargs}
        return self.client.post('/api/v1/analytics/workouts/', payload, format='json')

    def test_rounds_round_trips_into_provenance(self):
        resp = self._log(workout_type='hiit', rounds=8, exercise='Tabata')
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED, resp.content)
        self.assertEqual(resp.data['data']['provenance']['rounds'], 8)
        log = WorkoutLog.objects.get(id=resp.data['data']['id'])
        self.assertEqual(log.provenance['rounds'], 8)
        self.assertNotIn('rounds', {f.name for f in WorkoutLog._meta.fields})
        self.assertNotIn('rounds', resp.data['data'])

    def test_style_round_trips_into_provenance(self):
        for workout_type, style in (('yoga', 'vinyasa'), ('pilates', 'reformer'),
                                    ('boxing', 'shadow'), ('martial_arts', 'bjj')):
            with self.subTest(workout_type=workout_type):
                resp = self._log(workout_type=workout_type, style=style)
                self.assertEqual(resp.status_code, status.HTTP_201_CREATED, resp.content)
                self.assertEqual(resp.data['data']['provenance']['style'], style)

    def test_focus_and_sport_round_trip_into_provenance(self):
        resp = self._log(workout_type='mobility', focus='hips')
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED, resp.content)
        self.assertEqual(resp.data['data']['provenance']['focus'], 'hips')

        resp = self._log(workout_type='sport', sport='netball')
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED, resp.content)
        self.assertEqual(resp.data['data']['provenance']['sport'], 'netball')

    def test_extras_merge_with_explicit_provenance(self):
        resp = self._log(workout_type='hiit', rounds=12, provenance={'source': 'timer'})
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED, resp.content)
        self.assertEqual(resp.data['data']['provenance'],
                         {'source': 'timer', 'rounds': 12})

    def test_workout_without_extras_has_empty_provenance(self):
        resp = self._log(exercise='Deadlift')
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED, resp.content)
        self.assertEqual(resp.data['data']['provenance'], {})
