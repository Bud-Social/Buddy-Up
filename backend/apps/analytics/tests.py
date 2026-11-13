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


class SharedPostDraftTests(TestCase):
    """A shared countdown/activity/workout is reviewed before it is posted."""

    def setUp(self):
        self.user = User.objects.create_user(email='share@example.com', password='TestPass123!')
        self.profile = Profile.objects.create(user=self.user, username='shareuser', display_name='Share User')
        self.client = APIClient()
        self.client.force_authenticate(self.user)

    def _countdown(self):
        from apps.countdowns.models import CountdownTemplate, UserCountdown

        template = CountdownTemplate.objects.create(
            code='sobriety', title='Sobriety', unit='days',
            description='Days since last drink.', icon='🍻', color='#ef4444',
            default_target=0, sort_order=1,
        )
        return UserCountdown.objects.create(
            user=self.profile, template=template,
            countdown_type='manual', unit='days', current_count=12, target_count=30,
        )

    def test_a_countdown_prepares_a_countdown_post(self):
        countdown = self._countdown()
        resp = self.client.post('/api/v1/analytics/share/prepare/', {
            'kind': 'countdown',
            'obj_id': str(countdown.id),
            'visibility': 'public',
        }, format='json')
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED)
        self.assertEqual(resp.data['data']['source_kind'], 'countdown')
        self.assertEqual(resp.data['data']['post_type'], 'countdown')
        self.assertIn('Sobriety', resp.data['data']['body'])

    def test_the_prepared_draft_carries_the_countdowns_numbers(self):
        countdown = self._countdown()
        resp = self.client.post('/api/v1/analytics/share/prepare/', {
            'kind': 'countdown',
            'obj_id': str(countdown.id),
        }, format='json')
        draft_id = resp.data['data']['draft_id']

        publish = self.client.post(f'/api/v1/analytics/share/draft/{draft_id}/publish/', {
            'body': 'Twelve days in.',
            'visibility': 'public',
        }, format='json')
        self.assertEqual(publish.status_code, status.HTTP_201_CREATED)

        from apps.feed.models import Post
        post = Post.objects.get(id=publish.data['data']['post_id'])
        self.assertEqual(post.post_type, 'countdown')
        # The metrics survive the publish — the card can show them.
        self.assertEqual(post.workout_log_data['count'], 12)
        self.assertEqual(post.workout_log_data['target_count'], 30)
        self.assertEqual(post.workout_log_data['countdown_reason'], 'Sobriety')

    def test_the_draft_can_be_read_for_the_composer(self):
        countdown = self._countdown()
        resp = self.client.post('/api/v1/analytics/share/prepare/', {
            'kind': 'countdown',
            'obj_id': str(countdown.id),
        }, format='json')
        draft_id = resp.data['data']['draft_id']

        detail = self.client.get(f'/api/v1/feed/drafts/{draft_id}/')
        self.assertEqual(detail.status_code, status.HTTP_200_OK)
        source = detail.data['data']['source']
        self.assertEqual(source['kind'], 'countdown')
        self.assertEqual(source['count'], 12)
        self.assertEqual(source['title'], 'Sobriety')

    def test_an_activity_prepares_without_the_location_crash(self):
        resp = self.client.post('/api/v1/analytics/activities/', {
            'activity_type': 'walk',
            'duration_seconds': 1800,
            'distance_meters': 2000,
        }, format='json')
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED)
        activity_id = resp.data['data']['id']

        prepared = self.client.post('/api/v1/analytics/share/prepare/', {
            'kind': 'activity',
            'obj_id': activity_id,
        }, format='json')
        self.assertEqual(prepared.status_code, status.HTTP_201_CREATED)

    def test_a_shared_activity_keeps_its_metrics(self):
        resp = self.client.post('/api/v1/analytics/activities/', {
            'activity_type': 'run',
            'duration_seconds': 1800,
            'distance_meters': 5000,
            'calories_burned': 300,
            'avg_pace': 360,
        }, format='json')
        activity_id = resp.data['data']['id']

        prepared = self.client.post('/api/v1/analytics/share/prepare/', {
            'kind': 'activity',
            'obj_id': activity_id,
        }, format='json')
        draft_id = prepared.data['data']['draft_id']
        publish = self.client.post(f'/api/v1/analytics/share/draft/{draft_id}/publish/', {
            'body': 'A good one.',
        }, format='json')
        self.assertEqual(publish.status_code, status.HTTP_201_CREATED)

        from apps.feed.models import Post
        post = Post.objects.get(id=publish.data['data']['post_id'])
        self.assertEqual(post.workout_log_data['distance_km'], 5.0)
        self.assertEqual(post.workout_log_data['calories'], 300)
        self.assertEqual(post.workout_log_data['activity_type'], 'run')


class ActivityAnalyticsDetailTests(TestCase):
    """The activity summary carries more than totals."""

    def setUp(self):
        self.user = User.objects.create_user(email='actdetail@example.com', password='TestPass123!')
        self.profile = Profile.objects.create(user=self.user, username='actdetail', display_name='Act Detail')
        self.client = APIClient()
        self.client.force_authenticate(self.user)

    def _activity(self, **kwargs):
        from .models import ActivityRecord

        defaults = {
            'activity_type': 'run',
            'duration_seconds': 1800,
            'distance_meters': 5000,
            'avg_pace': 360,
            'avg_speed_kmh': 10,
            'calories_burned': 300,
            'route': [[-1.29, 36.82, 1], [-1.28, 36.83, 2]],
        }
        defaults.update(kwargs)
        return ActivityRecord.objects.create(user=self.profile, **defaults)

    def test_the_summary_carries_records_trends_and_goals(self):
        from . import engine

        self._activity(distance_meters=5000, duration_seconds=1800, avg_pace=360, steps=1000)
        self._activity(
            activity_type='hike', distance_meters=12000, duration_seconds=7200,
            avg_pace=600, elevation_gain_m=650,
        )
        self._activity(activity_type='walk', distance_meters=2000, duration_seconds=1200, steps=3000)

        summary = engine.build_summary(self.profile, 'all')
        activity = summary['activity']

        self.assertIn('records', activity)
        self.assertIn('weekly', activity)
        self.assertIn('distribution', activity)
        self.assertIn('calendar', activity)
        self.assertIn('goals', activity)
        self.assertIn('gallery', activity)

        # The records pick the best of each.
        self.assertEqual(activity['records']['longest_distance_km'], 12.0)
        self.assertEqual(activity['records']['biggest_climb_m'], 650)
        self.assertEqual(activity['records']['most_steps'], 3000)
        self.assertEqual(activity['records']['fastest_pace'], 360)

        # The gallery holds the sessions that have a route.
        self.assertEqual(len(activity['gallery']), 3)
        self.assertTrue(all(g['route_points'] == 2 for g in activity['gallery']))

        # Goals are set for each kind that was recorded.
        kinds = {g['activity_type'] for g in activity['goals']}
        self.assertEqual(kinds, {'run', 'hike', 'walk'})

    def test_an_empty_history_does_not_break_the_summary(self):
        from . import engine

        summary = engine.build_summary(self.profile, 'all')
        activity = summary['activity']
        self.assertEqual(activity['count'], 0)
        self.assertEqual(activity['records']['longest_distance_km'], 0)
        self.assertEqual(activity['weekly'], [])
        self.assertEqual(activity['goals'], [])

    def test_the_endpoint_returns_the_detail(self):
        self._activity()
        resp = self.client.get('/api/v1/analytics/summary/', {'period': 'all'})
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        activity = resp.data['data']['activity']
        self.assertIn('records', activity)
        self.assertIn('weekly', activity)


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


class ActivityDetectionTests(TestCase):
    """Automatic activity-type detection from GPS route / summary stats."""

    def setUp(self):
        self.user = User.objects.create_user(email='detect@example.com', password='TestPass123!')
        self.profile = Profile.objects.create(user=self.user, username='detectuser', display_name='Detect User')
        self.client = APIClient()
        self.client.force_authenticate(self.user)

    def _detect(self, payload):
        return self.client.post('/api/v1/analytics/activity/detect/', payload, format='json')

    def test_detect_walk_from_route(self):
        # Slow walking pace ~4 km/h over 10 points
        route = []
        lat, lng, t = 51.5, -0.1, 1000.0
        for i in range(10):
            route.append([lat, lng, t + i * 60])
            lat += 0.0005  # ~55m per minute → ~3.3 km/h
        resp = self._detect({'route': route, 'duration_seconds': 600, 'distance_meters': 330})
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertEqual(resp.data['data']['activity_type'], 'walk')
        self.assertEqual(resp.data['data']['method'], 'route')

    def test_detect_run_from_route(self):
        # Running pace ~10 km/h
        route = []
        lat, lng, t = 51.5, -0.1, 1000.0
        for i in range(10):
            route.append([lat, lng, t + i * 30])
            lat += 0.0008  # ~88m per 30s → ~10.6 km/h
        resp = self._detect({'route': route, 'duration_seconds': 300, 'distance_meters': 880})
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertEqual(resp.data['data']['activity_type'], 'run')

    def test_detect_cycle_from_route(self):
        # Cycling pace ~20 km/h
        route = []
        lat, lng, t = 51.5, -0.1, 1000.0
        for i in range(10):
            route.append([lat, lng, t + i * 20])
            lat += 0.0015  # ~166m per 20s → ~30 km/h
        resp = self._detect({'route': route, 'duration_seconds': 200, 'distance_meters': 1660})
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertEqual(resp.data['data']['activity_type'], 'cycle')

    def test_detect_hike_from_route(self):
        # Walking pace with elevation gain >100m → hike
        route = []
        lat, lng, t, elev = 51.5, -0.1, 1000.0, 0.0
        for i in range(10):
            route.append([lat, lng, t + i * 60, elev])
            lat += 0.0005
            elev += 15  # 15m per point → 135m gain
        resp = self._detect({'route': route, 'duration_seconds': 600, 'distance_meters': 550,
                             'elevation_gain_m': 135})
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertEqual(resp.data['data']['activity_type'], 'hike')

    def test_detect_walk_from_summary(self):
        resp = self._detect({
            'duration_seconds': 1800, 'distance_meters': 2000,
            'avg_speed_kmh': 4.0,
        })
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertEqual(resp.data['data']['activity_type'], 'walk')
        self.assertEqual(resp.data['data']['method'], 'summary')

    def test_detect_cycle_from_summary(self):
        resp = self._detect({
            'duration_seconds': 1800, 'distance_meters': 10000,
            'avg_speed_kmh': 20.0,
        })
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertEqual(resp.data['data']['activity_type'], 'cycle')

    def test_detect_insufficient_route_falls_back_to_walk(self):
        resp = self._detect({'route': [[51.5, -0.1, 1000.0]], 'duration_seconds': 60, 'distance_meters': 0})
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertEqual(resp.data['data']['activity_type'], 'walk')

