"""Platform analytics: staff access, window validation, rollups, retention,
hashtags and the honest-unavailable paths.

These are new files rather than additions to ``apps/analytics/tests.py``: that
file belongs to the per-user analytics surface (summary, event ingestion, body
metrics) and someone else may be working in it.

What is worth testing here, and why:

* **Staff-only, every route.** A missing permission class on a platform-wide
  endpoint exposes every user, every order and every wallet transaction to any
  logged-in account. The 401/403 pair is asserted per route.
* **Every allow-listed metric, not a sample of them.** The metric registry is
  the thing most likely to rot: a new spec with a bad filter or a non-zero-fill
  bug only shows up on the metric nobody looked at.
* **Rollup == live.** The timeseries endpoint has two code paths and reports
  which one it used. If they disagree, every historical chart is quietly wrong,
  and nothing else in the system notices.
* **The honest absences.** ``trending?kind=pages`` must say it has no data
  rather than return an empty series, and ``accuracy_proxy`` must never be
  labelled as accuracy.
"""
import datetime as dt
from unittest import mock

from django.test import TestCase, override_settings
from django.utils import timezone
from rest_framework import status
from rest_framework.test import APIClient

from apps.accounts.models import User
from apps.analytics import platform_metrics as metrics
from apps.analytics.models import AnalyticsEvent, DailyPlatformMetric
from apps.analytics.tasks import (
    purge_expired_analytics_events, rollup_daily_platform_metrics,
)
from apps.feed.models import Post, PostTag, Tag
from apps.governance.models import StaffRole
from apps.profiles.models import Profile

PREFIX = '/api/v1/portal/analytics'

READ_ROUTES = (
    f'{PREFIX}/overview/',
    f'{PREFIX}/timeseries/?metric=posts.new',
    f'{PREFIX}/trending/?kind=posts',
    f'{PREFIX}/ai-quality/',
    f'{PREFIX}/predictive/',
)
ALL_ROUTES = READ_ROUTES + (
    f'{PREFIX}/export/?report=overview&format=csv',
    f'{PREFIX}/export/?report=overview&format=xlsx',
)


def _make_user(email, username, *, staff=False, superuser=False, **extra):
    user = User.objects.create_user(email=email, password='TestPass123!', **extra)
    user.is_staff = staff
    user.is_superuser = superuser
    user.save(update_fields=['is_staff', 'is_superuser'])
    Profile.objects.create(user=user, username=username, display_name=username.title())
    return user


class StaffOnlyTests(TestCase):
    """Every analytics route is staff-only, and says so correctly.

    401 for anonymous (no credentials) and 403 for an authenticated non-staff
    account: collapsing the two would tell a prober which of the two they got
    right.
    """

    def setUp(self):
        self.client = APIClient()

    def test_anonymous_is_unauthenticated_on_every_route(self):
        for route in ALL_ROUTES:
            with self.subTest(route=route):
                self.assertEqual(self.client.get(route).status_code,
                                 status.HTTP_401_UNAUTHORIZED)

    def test_authenticated_non_staff_is_forbidden_on_every_route(self):
        member = _make_user('member@example.com', 'plainmember')
        self.client.force_authenticate(member)
        for route in ALL_ROUTES:
            with self.subTest(route=route):
                response = self.client.get(route)
                self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    def test_staff_reaches_the_read_routes(self):
        staff = _make_user('staff@example.com', 'portalstaff', staff=True)
        self.client.force_authenticate(staff)
        for route in READ_ROUTES:
            with self.subTest(route=route):
                self.assertEqual(self.client.get(route).status_code, status.HTTP_200_OK)


class ScopeEnforcementTests(TestCase):
    """``analytics.read`` / ``analytics.export`` behave as scopes.

    These tests simulate governance having the scopes registered by patching
    ``governance.models.ALL_SCOPES``. That keeps them meaningful whether or not
    the entries have been merged upstream yet, and they pin the behaviour the
    moment the merge lands: the "any staff" bridge in
    ``platform_permissions`` must disappear and become a real allow-list check.
    """

    def setUp(self):
        self.client = APIClient()
        self.staff = _make_user('scoped@example.com', 'scopedstaff', staff=True)
        self.staff_role = StaffRole.objects.create(user=self.staff, role='moderator')
        self.client.force_authenticate(self.staff)

    def _register_scopes(self):
        from apps.governance import models as governance_models
        return mock.patch.object(
            governance_models, 'ALL_SCOPES',
            frozenset(set(governance_models.ALL_SCOPES) | set(metrics_registered_scopes())),
        )

    def test_registered_scope_is_enforced_once_governance_knows_it(self):
        with self._register_scopes():
            response = self.client.get(f'{PREFIX}/overview/')
            self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
            self.assertIn('analytics.read', str(response.data))

            self.staff_role.scopes = ['analytics.read']
            self.staff_role.save(update_fields=['scopes', 'updated_at'])
            self.assertEqual(self.client.get(f'{PREFIX}/overview/').status_code,
                             status.HTTP_200_OK)

    def test_registered_export_scope_is_enforced_separately(self):
        with self._register_scopes():
            # `read` alone must not export: exporting moves platform data off
            # the platform, which is exactly what the second scope is for.
            self.staff_role.scopes = ['analytics.read']
            self.staff_role.save(update_fields=['scopes', 'updated_at'])
            self.assertEqual(
                self.client.get(f'{PREFIX}/export/?report=overview&format=csv').status_code,
                status.HTTP_403_FORBIDDEN,
            )
            self.staff_role.scopes = ['analytics.export']
            self.staff_role.save(update_fields=['scopes', 'updated_at'])
            self.assertEqual(
                self.client.get(f'{PREFIX}/export/?report=overview&format=csv').status_code,
                status.HTTP_200_OK,
            )

    def test_revoked_role_grants_nothing(self):
        with self._register_scopes():
            self.staff_role.revoked_at = timezone.now()
            self.staff_role.save(update_fields=['revoked_at', 'updated_at'])
            self.assertEqual(self.client.get(f'{PREFIX}/overview/').status_code,
                             status.HTTP_403_FORBIDDEN)

    def test_permission_classes_require_a_scope(self):
        from apps.analytics.platform_permissions import IsAnalyticsStaff
        with self.assertRaises(ValueError):
            IsAnalyticsStaff()


def metrics_registered_scopes():
    from apps.analytics.platform_permissions import ANALYTICS_SCOPES
    return list(ANALYTICS_SCOPES)


class WindowValidationTests(TestCase):
    """A bad window is a 400 naming the problem, on every endpoint.

    Silence here reads as "no data", which is the failure mode this validation
    exists to prevent.
    """

    def setUp(self):
        self.client = APIClient()
        self.staff = _make_user('win@example.com', 'winstaff', staff=True, superuser=True)
        self.client.force_authenticate(self.staff)

    def test_unparseable_date_is_rejected(self):
        for route in (f'{PREFIX}/overview/', f'{PREFIX}/ai-quality/',
                      f'{PREFIX}/predictive/', f'{PREFIX}/trending/?kind=posts'):
            with self.subTest(route=route):
                response = self.client.get(route, {'from': 'last-tuesday'})
                self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
                self.assertIn('YYYY-MM-DD', str(response.data))

    def test_reversed_window_is_rejected(self):
        response = self.client.get(f'{PREFIX}/overview/',
                                   {'from': '2026-05-01', 'to': '2026-04-01'})
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_future_window_is_rejected(self):
        tomorrow = (timezone.now().date() + dt.timedelta(days=1)).isoformat()
        response = self.client.get(f'{PREFIX}/overview/', {'to': tomorrow})
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_window_over_the_cap_is_rejected_and_names_the_cap(self):
        today = timezone.now().date()
        response = self.client.get(f'{PREFIX}/overview/', {
            'from': (today - dt.timedelta(days=metrics.MAX_RANGE_DAYS + 5)).isoformat(),
            'to': today.isoformat(),
        })
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn(str(metrics.MAX_RANGE_DAYS), str(response.data))

    def test_default_window_is_30_days_ending_today(self):
        response = self.client.get(f'{PREFIX}/overview/')
        window = response.data['data']['window']
        self.assertEqual(window['days'], 30)
        self.assertEqual(window['to'], timezone.now().date().isoformat())
        self.assertEqual(window['timezone'], 'UTC')
        self.assertEqual(window['basis'], 'inclusive')


class OverviewTests(TestCase):
    """Every figure declares its own window — that is the contract."""

    def setUp(self):
        self.client = APIClient()
        self.staff = _make_user('ov@example.com', 'ovstaff', staff=True, superuser=True)
        self.client.force_authenticate(self.staff)

    def test_envelope_shape(self):
        body = self.client.get(f'{PREFIX}/overview/').data
        self.assertTrue(body['success'])
        self.assertIsNone(body['errors'])
        for key in ('window', 'generated_at', 'kpis', 'breakdowns', 'groups',
                    'performance_notes', 'table'):
            self.assertIn(key, body['data'])

    def test_every_kpi_declares_a_window(self):
        kpis = self.client.get(f'{PREFIX}/overview/').data['data']['kpis']
        self.assertGreaterEqual(len(kpis), 15)
        today = timezone.now().date().isoformat()
        for kpi in kpis:
            with self.subTest(kpi=kpi['key']):
                for field in ('key', 'label', 'group', 'unit', 'value', 'kind',
                              'window', 'source', 'indexed', 'note'):
                    self.assertIn(field, kpi)
                window = kpi['window']
                self.assertIn('from', window)
                self.assertIn('to', window)
                self.assertEqual(window['timezone'], 'UTC')
                self.assertEqual(window['basis'], 'inclusive')
                self.assertGreaterEqual(window['days'], 1)
                # A windowed figure ends today; a gauge says so in its label.
                if kpi['kind'] == 'flow':
                    self.assertEqual(window['to'], today)
                    self.assertEqual(window['label'], 'Window')
                else:
                    self.assertEqual(window['label'], 'All time')

    def test_gauges_and_flows_are_distinguished(self):
        kpis = {k['key']: k for k in
                self.client.get(f'{PREFIX}/overview/').data['data']['kpis']}
        self.assertEqual(kpis['users.total']['kind'], 'gauge')
        self.assertEqual(kpis['users.new']['kind'], 'flow')

    def test_active_users_is_labelled_as_an_event_stream_measure(self):
        kpis = {k['key']: k for k in
                self.client.get(f'{PREFIX}/overview/').data['data']['kpis']}
        note = kpis['analytics.active_users']['note']
        self.assertIn('not platform DAU', note)

    def test_breakdowns_carry_their_own_window(self):
        breakdowns = self.client.get(f'{PREFIX}/overview/').data['data']['breakdowns']
        self.assertTrue(breakdowns)
        for block in breakdowns:
            with self.subTest(title=block['title']):
                self.assertIn('from', block['window'])
                self.assertIn('to', block['window'])
                self.assertTrue(block['basis'])

    def test_unindexed_sources_are_disclosed(self):
        notes = self.client.get(f'{PREFIX}/overview/').data['data']['performance_notes']
        sources = {note['source'] for note in notes}
        self.assertIn('feed.Post.created_at', sources)
        for note in notes:
            self.assertIn('owner', note)
            self.assertIn('suggested_migration', note)


class TimeseriesTests(TestCase):
    """The allow-list, the zero fill, and rollup-versus-live agreement."""

    def setUp(self):
        self.client = APIClient()
        self.staff = _make_user('ts@example.com', 'tsstaff', staff=True, superuser=True)
        self.client.force_authenticate(self.staff)
        # Windows end *yesterday*: today is never in the rollup (it is still
        # being written), so a window including today could never be served from
        # it. And the staff account created in setUp is dated today, so
        # including today would also put a real 1 in the zero-fill series.
        self.today = timezone.now().date()
        self.end = self.today - dt.timedelta(days=1)
        self.start = self.end - dt.timedelta(days=6)

    def _params(self, **extra):
        return {'from': self.start.isoformat(), 'to': self.end.isoformat(), **extra}

    def test_every_allow_listed_metric_returns_a_zero_filled_series(self):
        self.assertTrue(metrics.TIMESERIES_METRICS)
        for key in metrics.TIMESERIES_METRICS:
            with self.subTest(metric=key):
                response = self.client.get(f'{PREFIX}/timeseries/', self._params(metric=key))
                self.assertEqual(response.status_code, status.HTTP_200_OK)
                data = response.data['data']
                self.assertEqual(data['metric']['key'], key)
                # No source rows exist in this test, so every bucket is zero —
                # and every bucket is *present*. A missing bucket would draw a
                # gap in the chart that means nothing.
                self.assertEqual(len(data['series']), 7)
                self.assertEqual([b['value'] for b in data['series']], [0] * 7)
                self.assertEqual(
                    [b['bucket'] for b in data['series']],
                    [(self.start + dt.timedelta(days=i)).isoformat() for i in range(7)],
                )
                self.assertEqual(data['data_source']['path'], 'live')

    def test_allow_list_excludes_non_additive_and_gauges(self):
        self.assertNotIn('analytics.active_users', metrics.TIMESERIES_METRICS)
        self.assertNotIn('users.total', metrics.TIMESERIES_METRICS)
        self.assertIn('analytics.active_users', metrics.REFUSED_METRICS)

    def test_non_additive_metric_is_refused_with_a_reason(self):
        response = self.client.get(f'{PREFIX}/timeseries/',
                                   self._params(metric='analytics.active_users'))
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('non-additive', str(response.data))

    def test_unknown_metric_names_the_allowed_set(self):
        response = self.client.get(f'{PREFIX}/timeseries/', self._params(metric='nope'))
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('posts.new', str(response.data))

    def test_missing_metric_is_rejected(self):
        self.assertEqual(self.client.get(f'{PREFIX}/timeseries/').status_code,
                         status.HTTP_400_BAD_REQUEST)

    def test_unknown_granularity_is_rejected(self):
        response = self.client.get(f'{PREFIX}/timeseries/',
                                   self._params(metric='posts.new', granularity='fortnight'))
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('day, week', str(response.data))

    def test_week_buckets_are_mondays_and_zero_filled(self):
        response = self.client.get(f'{PREFIX}/timeseries/',
                                   self._params(metric='posts.new', granularity='week'))
        buckets = response.data['data']['series']
        self.assertTrue(buckets)
        for bucket in buckets:
            day = dt.date.fromisoformat(bucket['bucket'])
            self.assertEqual(day.weekday(), 0, msg=f'{day} is not a Monday')
            self.assertEqual(bucket['value'], 0)

    def test_rollup_path_is_reported_when_complete(self):
        rollup_daily_platform_metrics(days=7)
        data = self.client.get(
            f'{PREFIX}/timeseries/', self._params(metric='posts.new'),
        ).data['data']
        self.assertEqual(data['data_source']['path'], 'rollup')
        self.assertTrue(data['data_source']['rollup_complete'])
        self.assertEqual(data['data_source']['missing_days'], [])

    def test_missing_rollup_falls_back_to_live_and_says_so(self):
        rollup_daily_platform_metrics(days=3)
        data = self.client.get(
            f'{PREFIX}/timeseries/', self._params(metric='posts.new'),
        ).data['data']
        self.assertEqual(data['data_source']['path'], 'live')
        self.assertFalse(data['data_source']['rollup_complete'])
        self.assertTrue(data['data_source']['missing_days'])
        self.assertIn('apps.analytics.tasks.rollup_daily_platform_metrics',
                      data['data_source']['note'])


class RollupTaskTests(TestCase):
    """The rollup must be convergent: run it twice, get the same numbers."""

    def setUp(self):
        self.client = APIClient()
        self.staff = _make_user('roll@example.com', 'rollstaff', staff=True, superuser=True)
        self.client.force_authenticate(self.staff)
        self.profile = Profile.objects.get(user=self.staff)
        self.today = timezone.now().date()
        self.yesterday = self.today - dt.timedelta(days=1)

    def _make_post(self, day, count=1):
        created = []
        for index in range(count):
            post = Post.objects.create(
                author=self.profile, post_type='text', body=f'post {day} {index}',
            )
            # created_at is auto_now_add, so backdate it explicitly: the rollup
            # has to be tested against data in a past bucket.
            Post.objects.filter(pk=post.pk).update(
                created_at=timezone.make_aware(dt.datetime.combine(day, dt.time(12, 0)),
                                               dt.timezone.utc),
            )
            created.append(post.pk)
        return created

    def test_second_run_does_not_double_count(self):
        self._make_post(self.yesterday, count=3)
        first = rollup_daily_platform_metrics(days=2)
        values_first = self._snapshot('posts.new')
        second = rollup_daily_platform_metrics(days=2)
        values_second = self._snapshot('posts.new')

        self.assertEqual(first['errors'], {})
        self.assertEqual(second['errors'], {})
        self.assertEqual(first['rows'], second['rows'])
        self.assertEqual(values_first, values_second)
        self.assertEqual(
            DailyPlatformMetric.objects.filter(
                metric='posts.new', date=self.yesterday, dimension_key='',
            ).count(),
            1,
            msg='re-running the rollup created a second row for the same day',
        )
        self.assertEqual(values_first[self.yesterday], 3)

    def test_rollup_matches_the_live_aggregate_for_every_windowed_metric(self):
        self._make_post(self.yesterday, count=2)
        rollup_daily_platform_metrics(days=3)
        window = metrics.Window(self.today - dt.timedelta(days=3), self.today - dt.timedelta(days=1))
        for key in metrics.TIMESERIES_METRICS:
            spec = metrics.METRIC_SPECS[key]
            with self.subTest(metric=key):
                for granularity in ('day', 'week'):
                    rollup, complete, _missing = metrics.read_rollup(spec, window, granularity)
                    self.assertTrue(complete)
                    live = metrics.bucket_metric_live(spec, window, granularity)
                    for bucket in rollup:
                        self.assertEqual(
                            bucket['value'], metrics._num(live.get(bucket['bucket'], 0)),
                            msg=f'{key}/{granularity}/{bucket["bucket"]}: '
                                'rollup and live aggregate disagree',
                        )

    def test_backfill_covers_history_and_is_clamped_to_the_cap(self):
        self._make_post(self.today - dt.timedelta(days=20), count=1)
        result = rollup_daily_platform_metrics(backfill=True)
        self.assertEqual(result['errors'], {})
        self.assertGreaterEqual(result['days'], 20)
        value = DailyPlatformMetric.objects.filter(
            metric='posts.new', date=self.today - dt.timedelta(days=20),
        ).first()
        self.assertIsNotNone(value)
        self.assertEqual(metrics._num(value.value), 1)

    def test_one_failing_metric_does_not_stop_the_others(self):
        real = metrics.compute_metric_for_day

        def explode_on_posts(spec, day):
            if spec.key == 'posts.new':
                raise RuntimeError('boom')
            return real(spec, day)

        with mock.patch.object(metrics, 'compute_metric_for_day', explode_on_posts):
            result = rollup_daily_platform_metrics(days=1)
        self.assertEqual({key.rsplit(':', 1)[0] for key in result['errors']}, {'posts.new'})
        # The other metrics still rolled up: a single broken metric must not
        # cost the platform its whole dashboard.
        self.assertTrue(DailyPlatformMetric.objects.filter(metric='users.new').exists())
        self.assertFalse(DailyPlatformMetric.objects.filter(metric='posts.new').exists())

    def _snapshot(self, metric):
        """``{date: Decimal}`` straight from the table — the task's own output,
        not a re-derivation of it, so a double-count would be visible."""
        return dict(
            DailyPlatformMetric.objects
            .filter(metric=metric, dimension_key='')
            .values_list('date', 'value')
        )

    def test_dimension_key_is_order_independent_and_hash_stable(self):
        self.assertEqual(metrics.dimension_key({}), '')
        self.assertEqual(
            metrics.dimension_key({'b': 2, 'a': 1}), metrics.dimension_key({'a': 1, 'b': 2}),
        )
        self.assertNotEqual(
            metrics.dimension_key({'a': 1}), metrics.dimension_key({'a': 2}),
        )


class RetentionTaskTests(TestCase):
    """AnalyticsEvent had no retention at all. It does now."""

    def setUp(self):
        self.client = APIClient()
        self.profile = _make_user('ret@example.com', 'retstaff',
                                  staff=True, superuser=True)

    def _event(self, days_old, name='feed.post_impression'):
        """An event backdated on *received_at*, which is what retention cuts on.

        ``received_at`` is ``auto_now_add``, so it has to be written afterwards.
        Backdating ``occurred_at`` alone would test nothing: a client could
        forge that, which is exactly why retention anchors on the server clock.
        """
        when = timezone.now() - dt.timedelta(days=days_old)
        event = AnalyticsEvent.objects.create(
            event_name=name, actor=self.profile.profile, occurred_at=when,
            properties={'source': 'ai'}, consent={'analytics': True},
        )
        AnalyticsEvent.objects.filter(pk=event.pk).update(received_at=when)
        return event

    @override_settings(ANALYTICS_EVENT_RETENTION_DAYS=30)
    def test_purges_past_the_window_and_keeps_the_rest(self):
        ancient = self._event(days_old=400)
        older_than_window = self._event(days_old=45)
        recent = self._event(days_old=3)

        result = purge_expired_analytics_events()

        self.assertEqual(result['deleted'], 2)
        self.assertEqual(result['retention_days'], 30)
        self.assertFalse(AnalyticsEvent.objects.filter(pk=ancient.pk).exists())
        self.assertFalse(AnalyticsEvent.objects.filter(pk=older_than_window.pk).exists())
        self.assertTrue(AnalyticsEvent.objects.filter(pk=recent.pk).exists())

    def test_purge_is_batched(self):
        for _ in range(5):
            self._event(days_old=400)
        result = purge_expired_analytics_events(limit=2, days=30)
        self.assertEqual(result['deleted'], 2)
        self.assertEqual(AnalyticsEvent.objects.count(), 3)
        purge_expired_analytics_events(limit=10, days=30)
        self.assertEqual(AnalyticsEvent.objects.count(), 0)

    def test_retention_window_is_configurable(self):
        ten_days_old = self._event(days_old=10)
        # A 20-day window keeps a 10-day-old event; a 5-day window does not.
        self.assertEqual(purge_expired_analytics_events(days=20)['deleted'], 0)
        self.assertTrue(AnalyticsEvent.objects.filter(pk=ten_days_old.pk).exists())
        self.assertEqual(purge_expired_analytics_events(days=5)['deleted'], 1)
        with override_settings(ANALYTICS_EVENT_RETENTION_DAYS=5):
            from apps.analytics.tasks import retention_days
            self.assertEqual(retention_days(), 5)


class TrendingTests(TestCase):
    """Trending ranks what exists, and refuses to invent what does not."""

    def setUp(self):
        self.client = APIClient()
        self.staff = _make_user('tr@example.com', 'trstaff', staff=True, superuser=True)
        self.profile = self.staff.profile
        self.client.force_authenticate(self.staff)

    def _post(self, body='', **extra):
        return Post.objects.create(author=self.profile, post_type='text', body=body, **extra)

    def test_pages_reports_unavailable_rather_than_an_empty_chart(self):
        response = self.client.get(f'{PREFIX}/trending/', {'kind': 'pages'})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.data['data']
        self.assertEqual(data['kind'], 'pages')
        self.assertFalse(data['available'])
        self.assertEqual(data['items'], [])
        self.assertIn('route-change', data['reason'])
        # The message is the reason, so an operator reading only the message
        # still learns the section has no data source.
        self.assertIn('route-change', response.data['message'])
        self.assertNotIn('Trending items', response.data['message'])

    def test_posts_are_ranked_by_engagement(self):
        first = self._post('quiet')
        second = self._post('loud')
        for post in (first, second):
            Post.objects.filter(pk=post.pk).update(
                created_at=timezone.now() - dt.timedelta(days=1),
            )
        from apps.feed.models import Comment
        Comment.objects.create(post=second, author=self.profile, body='nice')
        data = self.client.get(f'{PREFIX}/trending/', {'kind': 'posts'}).data['data']
        self.assertTrue(data['available'])
        self.assertEqual(data['items'][0]['post_id'], str(second.id))
        self.assertEqual(data['items'][0]['comments'], 1)
        self.assertEqual(data['items'][1]['post_id'], str(first.id))
        self.assertTrue(data['rank_basis'])

    def test_posts_outside_the_window_are_excluded(self):
        post = self._post('old')
        Post.objects.filter(pk=post.pk).update(
            created_at=timezone.now() - dt.timedelta(days=60),
        )
        data = self.client.get(
            f'{PREFIX}/trending/',
            {'kind': 'posts', 'from': (timezone.now().date() - dt.timedelta(days=5)).isoformat()},
        ).data['data']
        self.assertEqual(data['items'], [])

    def test_hashtags_rank_by_posts_in_window(self):
        post = self._post('gym time #Gym and #LegDay')
        from apps.feed.tags import sync_post_tags
        sync_post_tags(post)
        data = self.client.get(f'{PREFIX}/trending/', {'kind': 'hashtags'}).data['data']
        tags = {item['tag']: item for item in data['items']}
        self.assertIn('gym', tags)
        self.assertIn('legday', tags)
        self.assertEqual(tags['gym']['posts_in_window'], 1)
        self.assertEqual(tags['gym']['posts_in_previous_window'], 0)
        self.assertEqual(tags['gym']['delta'], 1)
        self.assertIsNone(tags['gym']['pct_change'])

    def test_services_and_events_are_available(self):
        for kind in ('services', 'events'):
            with self.subTest(kind=kind):
                response = self.client.get(f'{PREFIX}/trending/', {'kind': kind})
                self.assertEqual(response.status_code, status.HTTP_200_OK)
                self.assertTrue(response.data['data']['available'])
                self.assertEqual(response.data['data']['items'], [])

    def test_unknown_kind_names_the_allowed_set(self):
        response = self.client.get(f'{PREFIX}/trending/', {'kind': 'vibes'})
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('hashtags', str(response.data))

    def test_limit_is_bounded(self):
        response = self.client.get(f'{PREFIX}/trending/',
                                   {'kind': 'posts', 'limit': '1000'})
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)


class AIQualityTests(TestCase):
    """AI quality: a correction *rate* is never called accuracy."""

    def setUp(self):
        from apps.ai.models import AIPredictionJob
        self.client = APIClient()
        self.staff = _make_user('aiq@example.com', 'aiqstaff', staff=True, superuser=True)
        self.client.force_authenticate(self.staff)
        self.job_model = AIPredictionJob

    def _job(self, **extra):
        defaults = {
            'task': 'food_recognition', 'status': 'completed',
            'model_version': 'v1', 'confidence': 0.8, 'latency_ms': 100,
            'cost_usd': 0.01, 'correction': {}, 'fallback_used': False,
        }
        defaults.update(extra)
        return self.job_model.objects.create(**defaults)

    def test_per_model_rows_carry_the_documented_fields(self):
        self._job(confidence=0.9, latency_ms=100)
        self._job(confidence=0.7, latency_ms=300, fallback_used=True,
                  fallback_reason='model_timeout')
        self._job(task='text_moderation', status='failed', confidence=0.3,
                  latency_ms=50, correction={'label': 'wrong'})
        data = self.client.get(f'{PREFIX}/ai-quality/').data['data']

        self.assertEqual(data['totals']['calls'], 3)
        self.assertEqual(data['totals']['fallbacks'], 1)
        self.assertEqual(data['totals']['fallback_rate'], 0.3333)
        self.assertEqual(data['totals']['corrections'], 1)
        self.assertEqual(data['models'][0]['model'], 'v1')
        self.assertEqual(data['models'][0]['calls'], 2)
        self.assertEqual(data['models'][0]['fallback_reasons'] if False else
                         data['fallback_reasons'][0], {'reason': 'model_timeout', 'count': 1})

    def test_accuracy_is_never_labelled_measurements(self):
        self._job(correction={'label': 'wrong'})
        data = self.client.get(f'{PREFIX}/ai-quality/').data['data']
        self.assertIn('accuracy_proxy', data['models'][0])
        self.assertNotIn('accuracy', data['models'][0])
        self.assertTrue(any('proxy' in caveat for caveat in data['caveats']))
        self.assertIn('no ground-truth', data['caveats'][0])

    def test_latency_percentiles_and_cost(self):
        for latency in (10, 20, 30, 40, 1000):
            self._job(latency_ms=latency, cost_usd=1)
        data = self.client.get(f'{PREFIX}/ai-quality/').data['data']
        self.assertEqual(data['latency_ms']['p50'], 30)
        self.assertEqual(data['latency_ms']['max'], 1000)
        self.assertEqual(data['totals']['cost_usd'], 5)
        self.assertEqual(data['totals']['cost_per_call_usd'], 1)
        # Cumulative cost is all-time, not window-scoped: a per-window number
        # that resets reads as "we spent nothing".
        self.assertEqual(data['totals']['cumulative_cost_usd'], 5)
        self.assertEqual(data['totals']['cumulative_calls'], 5)

    def test_confidence_histogram_covers_the_range(self):
        for value in (0.1, 0.5, 0.95):
            self._job(confidence=value)
        data = self.client.get(f'{PREFIX}/ai-quality/').data['data']
        buckets = data['confidence_distribution']['buckets']
        self.assertEqual(sum(b['count'] for b in buckets), 3)
        self.assertEqual([b['bucket'] for b in buckets],
                         ['0.0-0.2', '0.2-0.4', '0.4-0.6', '0.6-0.8', '0.8-1.0'])

    def test_empty_window_is_all_zero_not_an_error(self):
        data = self.client.get(f'{PREFIX}/ai-quality/',
                               {'from': '2026-01-01', 'to': '2026-01-02'}).data['data']
        self.assertEqual(data['totals']['calls'], 0)
        self.assertIsNone(data['totals']['fallback_rate'])
        self.assertEqual(data['models'], [])
        self.assertIsNone(data['latency_ms']['p50'])


class PredictiveTests(TestCase):
    """Observed versus derived, labelled on every row."""

    def setUp(self):
        from apps.ai.models import AIPredictionJob
        self.client = APIClient()
        self.staff = _make_user('pr@example.com', 'prstaff', staff=True, superuser=True)
        self.viewer = self.staff.profile
        self.target_user = _make_user('target@example.com', 'targetuser')
        self.target = self.target_user.profile
        self.client.force_authenticate(self.staff)
        self.job_model = AIPredictionJob

    def _impression(self, source):
        AnalyticsEvent.objects.create(
            event_name='recommendation.item_impression',
            actor=self.viewer, occurred_at=timezone.now(),
            object_type='profile', object_id=str(self.target.user_id),
            properties={'source': source, 'rank': 1},
            consent={'analytics': True},
        )

    def test_feedback_distribution_and_impression_split(self):
        from apps.profiles.models import RecommendationFeedback
        RecommendationFeedback.objects.create(
            viewer=self.viewer, target=self.target, feedback='helpful',
        )
        RecommendationFeedback.objects.create(
            viewer=self.target, target=self.viewer, feedback='not_interested',
        )
        self._impression('ai')
        self._impression('ai')
        self._impression('fallback')

        data = self.client.get(f'{PREFIX}/predictive/').data['data']
        feedback = data['observed']['recommendation_feedback']
        self.assertEqual(feedback['total'], 2)
        self.assertEqual({row['feedback']: row['count'] for row in feedback['rows']},
                         {'helpful': 1, 'not_interested': 1})
        impressions = data['observed']['recommendation_impressions']
        self.assertEqual(impressions['total'], 3)
        self.assertEqual(impressions['ai'], 2)
        self.assertEqual(impressions['fallback'], 1)
        self.assertEqual(impressions['unlabelled'], 0)

    def test_signals_declare_observed_versus_derived(self):
        data = self.client.get(f'{PREFIX}/predictive/').data['data']
        signals = {signal['key']: signal for signal in data['signals']}
        self.assertTrue(signals['recommendation_feedback.total']['observed'])
        self.assertFalse(signals['recommendation_feedback.negative_share']['observed'])
        self.assertIn('derived', signals['recommendation_feedback.negative_share']['derivation'])
        self.assertIn('ratio', signals['recommendation_feedback.negative_share']['basis'])
        for signal in signals.values():
            self.assertTrue(signal['basis'])

    def test_no_forecast_is_claimed(self):
        data = self.client.get(f'{PREFIX}/predictive/').data['data']
        self.assertIn('does not forecast', data['disclaimer'])
        self.assertNotIn('forecast', str(data['signals']).lower().replace(
            'not a forecast of churn', ''))

    def test_empty_dataset_reports_zero_not_a_crash(self):
        data = self.client.get(f'{PREFIX}/predictive/').data['data']
        self.assertEqual(data['observed']['recommendation_feedback']['total'], 0)
        self.assertEqual(data['observed']['recommendation_impressions']['total'], 0)


class HashtagTests(TestCase):
    """Normalisation, the create hook, and the backfill command."""

    def setUp(self):
        from django.core.management import call_command
        from io import StringIO

        self.call_command = call_command
        self.StringIO = StringIO
        self.client = APIClient()
        self.staff = _make_user('tag@example.com', 'tagstaff', staff=True, superuser=True)
        self.profile = self.staff.profile
        self.client.force_authenticate(self.staff)

    def test_normalisation_rules(self):
        from apps.feed.tags import normalise_tag
        self.assertEqual(normalise_tag('  #Gym  '), 'gym')
        # One leading '#' is the marker. A second one means the caller passed
        # something that is not a single tag, so it is rejected rather than
        # guessed at.
        self.assertIsNone(normalise_tag('##x'))
        self.assertIsNone(normalise_tag('#LEG#Day'))
        # Internal whitespace is preserved and collapsed, not dropped: a
        # `tags[]` entry may legitimately be multi-word ("black girl magic").
        self.assertEqual(normalise_tag('#Leg  Day'), 'leg day')
        self.assertEqual(normalise_tag('#Ünïcode_9'), 'ünïcode_9')
        # Anything with a word character in it is a tag: `tags[]` entries may be
        # multi-word, so "not a tag" is a perfectly good tag value. What is not
        # a tag is empty or punctuation-only.
        self.assertEqual(normalise_tag('not a tag'), 'not a tag')
        self.assertIsNone(normalise_tag(''))
        self.assertIsNone(normalise_tag(None))
        self.assertIsNone(normalise_tag('###'))
        self.assertIsNone(normalise_tag('---'))
        self.assertEqual(normalise_tag('#' + 'x' * 200), 'x' * 50)

    def test_body_extraction_dedupes_and_bounds(self):
        from apps.feed.tags import MAX_TAGS_PER_POST, extract_tags_from_body
        # 'and' is prose, not a hashtag: only '#'-prefixed runs are tags.
        tags = extract_tags_from_body('#one #Two #one, #one #and then ' + ' '.join(
            f'#{chr(97 + i)}' for i in range(40)))
        self.assertEqual(tags[:2], ['one', 'two'])
        self.assertEqual(len(tags), MAX_TAGS_PER_POST)
        self.assertEqual(len(set(tags)), len(tags), msg='tags must be deduped')
        self.assertEqual(tags, sorted(set(tags), key=tags.index))

    def test_field_extraction_accepts_the_shapes_clients_send(self):
        from apps.feed.tags import extract_tags_from_field
        self.assertEqual(extract_tags_from_field(['#A', 'b']), ['a', 'b'])
        self.assertEqual(extract_tags_from_field('#A, b'), ['a', 'b'])
        self.assertEqual(extract_tags_from_field('["#A","b"]'), ['a', 'b'])
        self.assertEqual(extract_tags_from_field(None), [])

    def test_create_post_populates_tags_without_changing_the_contract(self):
        response = self.client.post('/api/v1/feed/create/', {
            'post_type': 'text',
            'body': 'Morning #LegDay and #cardio',
            'tags': ['#Morning', 'R mobility'],
        }, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        post = Post.objects.get(id=response.data['data']['id'])

        # The stored tags field is exactly what the client sent — unchanged
        # contract, still echoed back.
        self.assertEqual(post.tags, ['#Morning', 'R mobility'])
        links = {link.tag.name: link.source for link in post.tag_links.all()}
        self.assertEqual(links, {
            'morning': 'field', 'r mobility': 'field',
            'legday': 'body', 'cardio': 'body',
        })

    def test_sync_is_idempotent_and_replaces_stale_rows(self):
        from apps.feed.tags import sync_post_tags
        post = Post.objects.create(author=self.profile, post_type='text',
                                   body='#one #two')
        sync_post_tags(post)
        sync_post_tags(post)
        self.assertEqual(PostTag.objects.filter(post=post).count(), 2)
        post.body = '#one'
        post.save(update_fields=['body', 'updated_at'])
        sync_post_tags(post)
        self.assertEqual(
            sorted(post.tag_links.values_list('tag__name', flat=True)), ['one'],
        )

    def test_backfill_command_recovers_tags_and_reports_counts(self):
        Post.objects.create(author=self.profile, post_type='text', body='#Alpha')
        Post.objects.create(
            author=self.profile, post_type='text', body='no tags here',
            tags=['#Beta'],
        )
        out = self.StringIO()
        self.call_command('backfill_post_tags', stdout=out)
        report = out.getvalue()
        self.assertIn('links_from_tags_field=1', report)
        self.assertIn('links_recovered_from_body=1', report)
        self.assertEqual(
            sorted(PostTag.objects.values_list('tag__name', 'source')),
            [('alpha', 'backfill_body'), ('beta', 'backfill')],
        )

        # Re-running converges instead of duplicating.
        out2 = self.StringIO()
        self.call_command('backfill_post_tags', stdout=out2)
        self.assertEqual(PostTag.objects.count(), 2)
        self.assertIn('(+0)', out2.getvalue())

    def test_backfill_dry_run_writes_nothing(self):
        Post.objects.create(author=self.profile, post_type='text', body='#Gamma')
        out = self.StringIO()
        self.call_command('backfill_post_tags', '--dry-run', stdout=out)
        self.assertIn('dry-run', out.getvalue())
        self.assertEqual(Tag.objects.count(), 0)
        self.assertEqual(PostTag.objects.count(), 0)