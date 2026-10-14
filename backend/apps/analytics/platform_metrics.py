"""Platform-wide analytics: the metric registry, the rollup writer and every
builder behind ``/api/v1/portal/analytics/``.

The rule this module enforces everywhere
----------------------------------------
**Every figure declares its own window.** There is no ambient "current period"
that a KPI inherits and no way for a caller to mistake a lifetime gauge for a
this-month number. Each KPI carries ``window: {from, to, days, basis}`` and each
breaks-down block carries the same. A UI that renders ``users.new`` next to
``users.total`` therefore has to render two different windows, which is the
truth rather than a bug in the chart.

The metric registry
-------------------
:data:`METRIC_SPECS` is the single allow-list. It exists so that
``timeseries?metric=`` can validate against something, so the rollup task and
the live aggregate cannot drift (both iterate the same specs), and so a new
metric is a dict entry rather than a migration.

Two properties are declared per spec and are load-bearing:

``additive``
    Whether summing buckets is meaningful. Counts and money are; distinct-user
    counts are not — five days of 10 daily actives is not 50 actives, it is at
    most 50 *and* at least 10. Non-additive metrics are refused by the
    timeseries endpoint with a 400 that says why, rather than being summed into
    a number that means nothing.

``source``
    The model and column the number comes from. It is returned to the caller.
    Several of the source columns are **not indexed** (see
    :data:`UNINDEXED_SOURCES`) because the models live in apps this one does not
    own; the response says so instead of pretending the read was cheap. The
    rollup table is the actual fix.

Everything here is read-only. No builder writes to a source table.
"""
import datetime as dt
import logging
from dataclasses import dataclass
from decimal import Decimal

from django.conf import settings
from django.db.models import Avg, Count, Q, Sum
from django.db.models.functions import Coalesce, TruncDate, TruncWeek
from django.db.utils import NotSupportedError
from django.utils import timezone
from rest_framework.exceptions import ValidationError

from .models import DailyPlatformMetric

logger = logging.getLogger(__name__)

UTC = dt.timezone.utc
DEFAULT_WINDOW_DAYS = 30
#: Alias the AnalyticsEvent time column is annotated under, so every read of it
#: — filter, bucket, distinct-count — resolves to the same COALESCE.
_TIME_ANNOTATION = '_analytics_ts'
_EVENT_TS = Coalesce('occurred_at', 'received_at')
#: Hard ceiling on a single query window. Raised per-installation with
#: ``ANALYTICS_MAX_RANGE_DAYS``; it exists because a "give me everything since
#: 2020" timeseries is a sequential scan of every table in the platform.
MAX_RANGE_DAYS = getattr(settings, 'ANALYTICS_MAX_RANGE_DAYS', 366)
TRENDING_LIMIT_DEFAULT = 10
TRENDING_LIMIT_MAX = 100

#: Columns the aggregate reads that no index covers. Reported to the caller in
#: ``performance_notes`` so the cost is disclosed rather than hidden — the fix
#: is an AddIndex in an app this one does not own (reported, not applied).
UNINDEXED_SOURCES = (
    ('accounts.User.created_at', 'AddIndex(fields=["-created_at"], name="accounts_user_created_idx")', 'accounts'),
    ('profiles.Profile.created_at', 'AddIndex(fields=["-created_at"], name="profiles_profile_created_idx")', 'profiles'),
    ('feed.Post.created_at', 'AddIndex(fields=["-created_at"], name="feed_post_created_idx")', 'feed'),
    ('feed.Comment.created_at', 'AddIndex(fields=["-created_at"], name="feed_comment_created_idx")', 'feed'),
    ('feed.Reaction.created_at', 'AddIndex(fields=["-created_at"], name="feed_reaction_created_idx")', 'feed'),
    ('profiles.FollowRelationship.created_at', 'AddIndex(fields=["-created_at"], name="profiles_follow_created_idx")', 'profiles'),
    ('marketplace.Order.created_at', 'AddIndex(fields=["-created_at"], name="mkt_order_created_idx")', 'marketplace'),
    ('wallet.ArtifactTransaction.created_at', 'AddIndex(fields=["-created_at"], name="wallet_tx_created_idx")', 'wallet'),
)


# ---------------------------------------------------------------------------
# The registry
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class MetricSpec:
    key: str
    label: str
    group: str
    unit: str                      # 'count' | 'usd'
    source: str                    # 'accounts.User.created_at'
    model: str                     # 'accounts.User'
    aggregate: str                 # 'count' | 'sum' | 'distinct'
    field_name: str = ''           # summed / counted column
    filters: tuple = ()            # (('field', 'value'), ...)
    additive: bool = True
    windowed: bool = True          # False = gauge, "all rows up to `to`"
    expression: bool = False       # time column is COALESCE(occurred_at, received_at)
    description: str = ''

    @property
    def windowed_label(self):
        return 'Window' if self.windowed else 'All time'


def _specs():
    return (
        MetricSpec(
            key='users.new', label='New users', group='identity', unit='count',
            source='accounts.User.created_at', model='accounts.User',
            aggregate='count',
            description='Accounts created inside the window.',
        ),
        MetricSpec(
            key='profiles.new', label='New profiles', group='identity', unit='count',
            source='profiles.Profile.created_at', model='profiles.Profile',
            aggregate='count',
            description='Profile rows created inside the window. Normally equal '
                        'to users.new a few seconds later.',
        ),
        MetricSpec(
            key='posts.new', label='New posts', group='content', unit='count',
            source='feed.Post.created_at', model='feed.Post',
            aggregate='count',
            filters=(('is_deleted', False),),
            description='Feed posts created inside the window, soft-deleted excluded.',
        ),
        MetricSpec(
            key='comments.new', label='New comments', group='content', unit='count',
            source='feed.Comment.created_at', model='feed.Comment',
            aggregate='count',
        ),
        MetricSpec(
            key='reactions.new', label='New reactions', group='content', unit='count',
            source='feed.Reaction.created_at', model='feed.Reaction',
            aggregate='count',
        ),
        MetricSpec(
            key='follows.new', label='New follows', group='identity', unit='count',
            source='profiles.FollowRelationship.created_at',
            model='profiles.FollowRelationship', aggregate='count',
        ),
        MetricSpec(
            key='posts.views_recorded', label='Post view records', group='content',
            unit='count', source='feed.PostView.created_at', model='feed.PostView',
            aggregate='count',
            description='Unique-viewer rows created in the window (one per post+viewer).',
        ),
        MetricSpec(
            key='orders.new', label='New orders', group='commerce', unit='count',
            source='marketplace.Order.created_at', model='marketplace.Order',
            aggregate='count',
        ),
        MetricSpec(
            key='orders.paid.new', label='Paid orders', group='commerce', unit='count',
            source='marketplace.Order.created_at', model='marketplace.Order',
            aggregate='count', filters=(('payment_status', 'paid'),),
            description='Orders whose payment_status is "paid" at query time — a '
                        'current state, so a later refund restates history.',
        ),
        MetricSpec(
            key='orders.gross_usd', label='Gross order value', group='commerce',
            unit='usd', source='marketplace.Order.spent_usd', model='marketplace.Order',
            aggregate='sum', field_name='spent_usd',
            description='SUM(spent_usd) over orders created in the window. Named '
                        'gross because it includes orders later cancelled or refunded.',
        ),
        MetricSpec(
            key='wallet.transactions.new', label='Wallet transactions',
            group='commerce', unit='count',
            source='wallet.ArtifactTransaction.created_at',
            model='wallet.ArtifactTransaction', aggregate='count',
        ),
        MetricSpec(
            key='wallet.credit.count', label='Wallet credits', group='commerce',
            unit='count', source='wallet.ArtifactTransaction.created_at',
            model='wallet.ArtifactTransaction', aggregate='count',
            filters=(('direction', 'credit'),),
        ),
        MetricSpec(
            key='wallet.debit.count', label='Wallet debits', group='commerce',
            unit='count', source='wallet.ArtifactTransaction.created_at',
            model='wallet.ArtifactTransaction', aggregate='count',
            filters=(('direction', 'debit'),),
        ),
        MetricSpec(
            key='wallet.credit.fiat', label='Fiat credited', group='commerce',
            unit='usd', source='wallet.ArtifactTransaction.fiat_amount',
            model='wallet.ArtifactTransaction', aggregate='sum',
            field_name='fiat_amount', filters=(('direction', 'credit'),),
            description='SUM(fiat_amount) over credits. fiat_currency is '
                        'per-row (KES by default) and is NOT normalised here.',
        ),
        MetricSpec(
            key='wallet.debit.fiat', label='Fiat debited', group='commerce',
            unit='usd', source='wallet.ArtifactTransaction.fiat_amount',
            model='wallet.ArtifactTransaction', aggregate='sum',
            field_name='fiat_amount', filters=(('direction', 'debit'),),
        ),
        MetricSpec(
            key='analytics.events.new', label='Behavioral events', group='engagement',
            unit='count', source='analytics.AnalyticsEvent.received_at',
            model='analytics.AnalyticsEvent', aggregate='count', expression=True,
            description='Counted on COALESCE(occurred_at, received_at) so a '
                        'client-supplied timestamp does not move a row out of '
                        'the day it was received.',
        ),
        MetricSpec(
            key='analytics.active_users', label='Active users', group='engagement',
            unit='count', source='analytics.AnalyticsEvent.actor',
            model='analytics.AnalyticsEvent', aggregate='distinct',
            field_name='actor', additive=False, expression=True,
            description='Distinct profiles appearing in the event stream in the '
                        'window. Only users whose clients emit events with '
                        'consent appear — it is not a DAU for the platform.',
        ),
        # Gauges: "how many exist now", window is irrelevant beyond "up to `to`".
        MetricSpec(
            key='users.total', label='Total users', group='identity', unit='count',
            source='accounts.User', model='accounts.User', aggregate='count',
            windowed=False,
        ),
        MetricSpec(
            key='profiles.total', label='Total profiles', group='identity',
            unit='count', source='profiles.Profile', model='profiles.Profile',
            aggregate='count', windowed=False,
        ),
        MetricSpec(
            key='posts.total', label='Total posts', group='content', unit='count',
            source='feed.Post', model='feed.Post', aggregate='count',
            filters=(('is_deleted', False),), windowed=False,
        ),
        MetricSpec(
            key='comments.total', label='Total comments', group='content',
            unit='count', source='feed.Comment', model='feed.Comment',
            aggregate='count', windowed=False,
        ),
        MetricSpec(
            key='reactions.total', label='Total reactions', group='content',
            unit='count', source='feed.Reaction', model='feed.Reaction',
            aggregate='count', windowed=False,
        ),
        MetricSpec(
            key='follows.total', label='Total follows', group='identity',
            unit='count', source='profiles.FollowRelationship',
            model='profiles.FollowRelationship', aggregate='count', windowed=False,
        ),
        MetricSpec(
            key='shops.total', label='Shops', group='supply', unit='count',
            source='marketplace.Shop', model='marketplace.Shop', aggregate='count',
            filters=(('is_active', True),), windowed=False,
        ),
        MetricSpec(
            key='gyms.total', label='Gyms', group='supply', unit='count',
            source='gyms.Gym', model='gyms.Gym', aggregate='count',
            filters=(('is_deleted', False),), windowed=False,
        ),
        MetricSpec(
            key='communities.total', label='Communities', group='supply',
            unit='count', source='messaging.Conversation',
            model='messaging.Conversation', aggregate='count',
            filters=(('is_community', True),), windowed=False,
        ),
        MetricSpec(
            key='stations.total', label='Pickup stations', group='supply',
            unit='count', source='marketplace.PickupStation',
            model='marketplace.PickupStation', aggregate='count',
            filters=(('is_active', True),), windowed=False,
        ),
        MetricSpec(
            key='events.published.total', label='Published events', group='supply',
            unit='count', source='marketplace.MarketplaceEvent',
            model='marketplace.MarketplaceEvent', aggregate='count',
            filters=(('is_published', True), ('is_draft', False),
                     ('is_cancelled', False)), windowed=False,
        ),
    )


METRIC_SPECS = {spec.key: spec for spec in _specs()}

#: Metrics the timeseries endpoint accepts. Additive only — see MetricSpec.additive.
TIMESERIES_METRICS = tuple(k for k, s in METRIC_SPECS.items() if s.additive and s.windowed)
#: Declared so the 400 can name them instead of saying "unsupported".
REFUSED_METRICS = {
    k: ('non-additive: buckets of this metric cannot be summed, so a series '
        'over it would be a number that means nothing')
    for k, s in METRIC_SPECS.items() if not s.additive or not s.windowed
}

def metric_catalogue():
    """The documented allow-list, safe to hand a UI to build a picker from.

    Returned by the timeseries endpoint as ``metric_catalogue`` so a picker is
    never built from a hardcoded list that can drift from the registry. The flat
    ``available_metrics`` key list stays alongside it for callers that only need
    the keys.
    """
    return [
        {
            'key': spec.key, 'label': spec.label, 'group': spec.group,
            'unit': spec.unit, 'additive': spec.additive, 'windowed': spec.windowed,
            'source': spec.source, 'description': spec.description,
        }
        for spec in sorted(METRIC_SPECS.values(), key=lambda s: (s.group, s.key))
    ]


# ---------------------------------------------------------------------------
# Window parsing
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class Window:
    start_date: dt.date
    end_date: dt.date
    basis: str = 'inclusive'

    @property
    def days(self):
        return (self.end_date - self.start_date).days + 1

    @property
    def start_dt(self):
        return timezone.make_aware(dt.datetime.combine(self.start_date, dt.time.min), UTC)

    @property
    def end_dt_exclusive(self):
        return timezone.make_aware(
            dt.datetime.combine(self.end_date + dt.timedelta(days=1), dt.time.min), UTC,
        )

    def as_dict(self, label=None):
        return {
            'from': self.start_date.isoformat(),
            'to': self.end_date.isoformat(),
            'days': self.days,
            'basis': self.basis,
            'timezone': 'UTC',
            'label': label or (
                f'{self.start_date.isoformat()} to {self.end_date.isoformat()} (UTC, inclusive)'
            ),
        }

    def day_range(self):
        day = self.start_date
        while day <= self.end_date:
            yield day
            day += dt.timedelta(days=1)


def _parse_boundary(raw, param):
    raw = (raw or '').strip()
    if not raw:
        return None
    try:
        parsed = dt.date.fromisoformat(raw)
    except ValueError:
        raise ValidationError({
            param: [f'Invalid date {raw!r}. Use YYYY-MM-DD (UTC calendar days).'],
        })
    if parsed > timezone.now().date():
        raise ValidationError({
            param: [f'{raw!r} is in the future. Analytics windows end today at the latest.'],
        })
    return parsed


def parse_window(params, *, default_days=DEFAULT_WINDOW_DAYS, max_days=None):
    """Read ``from``/``to`` from a query dict into a validated :class:`Window`.

    Validation is shared by every endpoint and by the export path, which is the
    only way to guarantee an export cannot silently cover a different period
    from the report the user was looking at.
    """
    limit = max_days if max_days is not None else MAX_RANGE_DAYS
    end = _parse_boundary(params.get('to'), 'to')
    start = _parse_boundary(params.get('from'), 'from')
    today = timezone.now().date()
    if end is None:
        end = today
    if start is None:
        start = end - dt.timedelta(days=default_days - 1)
    if start > end:
        raise ValidationError({
            'from': [f'{start.isoformat()} is after to ({end.isoformat()}).'],
        })
    span = (end - start).days + 1
    if span > limit:
        raise ValidationError({
            'from': [
                f'Requested window is {span} days; the maximum is {limit}. '
                'Narrow the range, or raise ANALYTICS_MAX_RANGE_DAYS.',
            ],
        })
    return Window(start, end)


def _int_param(params, name, default, minimum, maximum):
    raw = (params.get(name) or '').strip()
    if not raw:
        return default
    try:
        value = int(raw)
    except (TypeError, ValueError):
        raise ValidationError({name: [f'Expected an integer, got {raw!r}.']})
    if value < minimum or value > maximum:
        raise ValidationError({
            name: [f'Must be between {minimum} and {maximum}, got {value}.'],
        })
    return value


def _choice_param(params, name, choices, default):
    raw = (params.get(name) or '').strip() or default
    if raw not in choices:
        raise ValidationError({
            name: [f'Unknown {raw!r}. Must be one of: {", ".join(sorted(choices))}.'],
        })
    return raw


# ---------------------------------------------------------------------------
# Reading the source tables
# ---------------------------------------------------------------------------

def _model_for(spec):
    from django.apps import apps
    return apps.get_model(spec.model)


def _date_expr(spec):
    """The column (or annotated alias) the time filter applies to.

    ``AnalyticsEvent`` carries a client-supplied ``occurred_at`` that can be
    null and can be wrong, so it is coalesced with the server's ``received_at``
    and exposed as the annotation ``_analytics_ts`` — see :func:`_windowed_qs`.
    Every other model filters on plain ``created_at``.
    """
    return _TIME_ANNOTATION if spec.expression else 'created_at'


def _base_qs(spec):
    qs = _model_for(spec).objects.all()
    for name, value in spec.filters:
        qs = qs.filter(**{name: value})
    return qs


def _windowed_qs(spec, window):
    qs = _base_qs(spec)
    field = _date_expr(spec)
    if spec.expression:
        # Annotating rather than filtering on the expression inline: Django has
        # no expression-comparison sugar for `F()`, and a named annotation is
        # legible in the emitted SQL too.
        qs = qs.annotate(**{_TIME_ANNOTATION: _EVENT_TS})
    return qs.filter(
        **{f'{field}__gte': window.start_dt, f'{field}__lt': window.end_dt_exclusive},
    )


def _aggregate_qs(qs, spec):
    """``(value, source_count)`` for one queryset, per the spec's aggregate."""
    if spec.aggregate == 'count':
        rows = qs.count()
        return rows, rows
    if spec.aggregate == 'distinct':
        count = qs.values(_date_expr(spec)).aggregate(
            n=Count(spec.field_name, distinct=True),
        )['n']
        return count, 0
    total = qs.aggregate(total=Sum(spec.field_name))['total'] or 0
    return total, qs.count()


def compute_metric(spec, window):
    """``(value, source_count)`` for one metric over one window. Live aggregate."""
    qs = _windowed_qs(spec, window)
    return _aggregate_qs(qs, spec)


def compute_metric_for_day(spec, day):
    return compute_metric(spec, Window(day, day))


def bucket_metric_live(spec, window, granularity='day'):
    """``{bucket_label: value}`` straight from the source table.

    Bucket labels are ISO dates for ``day`` and the Monday of the ISO week for
    ``week`` — the same label the rollup path produces, so the two paths are
    directly comparable (which is how the fallback is tested).
    """
    field = _date_expr(spec)
    trunc = TruncWeek(field, tzinfo=UTC, week_start=1) if granularity == 'week' \
        else TruncDate(field, tzinfo=UTC)
    qs = _windowed_qs(spec, window)
    if spec.aggregate == 'count':
        # `pk`, not `id`: profiles.Profile's primary key is `user` (a OneToOne),
        # so `Count('id')` raises FieldError on it. `'pk'` resolves to whatever
        # the model's actual key column is, which keeps one registry working
        # across models that do not share a schema.
        rows = qs.annotate(bucket=trunc).values('bucket').annotate(total=Count('pk'))
    elif spec.aggregate == 'distinct':
        rows = qs.annotate(bucket=trunc).values('bucket').annotate(
            total=Count(spec.field_name, distinct=True))
    else:
        rows = qs.annotate(bucket=trunc).values('bucket').annotate(total=Sum(spec.field_name))
    out = {}
    for row in rows:
        bucket = row['bucket']
        if bucket is None:
            continue
        # TruncDate returns a date and TruncWeek a datetime (which subclasses
        # date, hence the order of the checks); both are labelled by their
        # calendar date, so a week is keyed by its Monday.
        day = bucket.date() if isinstance(bucket, dt.datetime) else bucket
        out[day.isoformat()] = row['total'] or 0
    return out


# ---------------------------------------------------------------------------
# Rollup read + write
# ---------------------------------------------------------------------------

def bucket_labels(window, granularity='day'):
    """Every bucket label in the window, in order, gaps included.

    Week buckets start on the Monday of the window's first day, which is what
    ``TruncWeek(week_start=1)`` and :func:`_week_start` both produce — so a
    window that begins mid-week yields one *partial* first bucket rather than
    silently shifting every bucket by the window's own offset.
    """
    if granularity == 'day':
        return [d.isoformat() for d in window.day_range()]
    labels, cursor = [], _week_start(window.start_date)
    while cursor <= window.end_date:
        labels.append(cursor.isoformat())
        cursor += dt.timedelta(days=7)
    return labels


def _week_start(day):
    return day - dt.timedelta(days=day.weekday())


def rollup_coverage(spec, window):
    """``(is_complete, missing_days)`` for the rollup table over this window.

    A day is considered rollable once it is not the current UTC day: today's
    bucket would change with every write, so serving it from a batch that ran
    before the last post would under-report by minutes.
    """
    today = timezone.now().date()
    rows = dict(
        DailyPlatformMetric.objects
        .filter(metric=spec.key, dimension_key='', date__range=(window.start_date, window.end_date))
        .values_list('date', 'value')
    )
    missing = []
    for day in window.day_range():
        if day >= today or day not in rows:
            missing.append(day)
    complete = not missing
    return complete, missing


def read_rollup(spec, window, granularity='day'):
    """``(buckets, complete, missing_days)`` from the rollup table.

    ``buckets`` is always the full, zero-filled label set for the window — the
    caller never has to distinguish "no row" from "zero".
    """
    labels = bucket_labels(window, granularity)
    complete, missing = rollup_coverage(spec, window)
    # Keyed by ISO string, not by date: `bucket_labels` is the single definition
    # of what a label looks like, and the reader joins on it.
    values = {
        day.isoformat(): value
        for day, value in DailyPlatformMetric.objects
        .filter(metric=spec.key, dimension_key='',
                date__range=(window.start_date, window.end_date))
        .values_list('date', 'value')
    }
    buckets = [{'bucket': label, 'value': 0} for label in labels]
    if granularity == 'day':
        for index, label in enumerate(labels):
            if label in values:
                buckets[index]['value'] = _num(values[label])
        return buckets, complete, missing

    index_by_label = {label: i for i, label in enumerate(labels)}
    for day, value in values.items():
        label = _week_start(dt.date.fromisoformat(day)).isoformat()
        position = index_by_label.get(label)
        if position is not None:
            buckets[position]['value'] = _num(buckets[position]['value']) + _num(value)
    return buckets, complete, missing


def write_daily_metric(spec, day, *, dimensions=None, source_count=0):
    """Recompute one (metric, day) and store it. Idempotent by construction.

    Not an increment: the value is a fresh aggregate over the whole day, so
    running the task twice, running it twice in parallel, or re-running it after
    a late write all converge on the same number. ``updated_at`` moves; the value
    does not double.
    """
    from .models import AnalyticsEvent  # noqa: F401  (registers the app models)

    value, counted = compute_metric_for_day(spec, day)
    dims = dimensions or {}
    key = dimension_key(dims)
    DailyPlatformMetric.objects.update_or_create(
        metric=spec.key, date=day, dimension_key=key,
        defaults={'value': _decimal(value), 'dimensions': dims, 'source_count': source_count or counted},
    )
    return _num(value)


def dimension_key(dimensions):
    """A stable 64-char key for a dimensions dict ('' for the base rows).

    ``sorted`` + compact separators so ``{'a': 1, 'b': 2}`` and
    ``{'b': 2, 'a': 1}`` are the same key, which is what makes
    ``update_or_create`` idempotent for a future dimensioned rollup.
    """
    if not dimensions:
        return ''
    import hashlib
    import json
    canonical = json.dumps(dimensions, sort_keys=True, separators=(',', ':'), default=str)
    return hashlib.sha256(canonical.encode('utf-8')).hexdigest()[:64]


# ---------------------------------------------------------------------------
# Number normalisation
# ---------------------------------------------------------------------------

def _decimal(value):
    if value is None:
        return Decimal('0')
    if isinstance(value, Decimal):
        return value
    if isinstance(value, float):
        return Decimal(str(round(value, 6)))
    return Decimal(str(value))


def _num(value):
    """JSON-safe number: counts stay ints, money stays floats."""
    if value is None:
        return 0
    if isinstance(value, Decimal):
        as_float = float(value)
        return int(as_float) if as_float.is_integer() else round(as_float, 6)
    if isinstance(value, float) and value.is_integer():
        return int(value)
    return value


def _is_indexed(source):
    """False when the figure reads a column no index covers.

    Disclosed rather than hidden: the response tells the caller which figures
    cost a sequential scan today, and the fix belongs to the app that owns the
    model (see :data:`UNINDEXED_SOURCES`).
    """
    return not any(source.startswith(prefix) for prefix, _snippet, _owner in UNINDEXED_SOURCES)


def _kpi(spec, value, window, *, note='', source_count=None):
    return {
        'key': spec.key,
        'label': spec.label,
        'group': spec.group,
        'unit': spec.unit,
        'value': _num(value),
        'kind': 'flow' if spec.windowed else 'gauge',
        'window': window.as_dict(spec.windowed_label),
        'source': spec.source,
        'indexed': _is_indexed(spec.source),
        'note': note,
        'source_count': source_count,
    }


def _breakdown(title, window, rows, *, basis, note=''):
    return {
        'title': title,
        'window': window.as_dict(),
        'basis': basis,
        'note': note,
        'rows': rows,
    }


# ---------------------------------------------------------------------------
# Overview
# ---------------------------------------------------------------------------

#: Which KPIs the headline shows, in render order. Curated rather than "all
#: specs" because the overview is a page, not a data dump.
OVERVIEW_KEYS = (
    'users.total', 'users.new', 'profiles.new', 'analytics.active_users',
    'posts.total', 'posts.new', 'comments.new', 'reactions.new', 'follows.new',
    'orders.new', 'orders.gross_usd', 'orders.paid.new',
    'wallet.transactions.new', 'wallet.credit.fiat', 'wallet.debit.fiat',
    'shops.total', 'gyms.total', 'communities.total', 'stations.total',
    'events.published.total',
)

ACTIVE_USERS_WARNING = (
    'Derived from the analytics event stream, so it counts only users whose '
    'clients emit consented events. It is not platform DAU.'
)


def build_overview(params):
    window = parse_window(params)
    kpis = []
    for key in OVERVIEW_KEYS:
        spec = METRIC_SPECS[key]
        value, counted = compute_metric(spec, window)
        note = ACTIVE_USERS_WARNING if key == 'analytics.active_users' else spec.description
        kpis.append(_kpi(spec, value, window, note=note, source_count=counted))

    breakdowns = [
        _wallet_breakdown(window),
        _posts_breakdown(window),
    ]
    return {
        'window': window.as_dict(),
        'generated_at': timezone.now().isoformat(),
        'kpis': kpis,
        'breakdowns': [b for b in breakdowns if b is not None],
        'groups': sorted({kpi['group'] for kpi in kpis}),
        'performance_notes': [
            {
                'source': prefix,
                'issue': 'no index; this figure costs a sequential scan until one exists',
                'suggested_migration': snippet,
                'owner': owner,
            }
            for prefix, snippet, owner in UNINDEXED_SOURCES
        ],
        'table': _overview_table(kpis),
    }


def _overview_table(kpis):
    return {
        'columns': ['key', 'label', 'group', 'unit', 'value', 'kind', 'window_from', 'window_to', 'window_days', 'source'],
        'rows': [
            [k['key'], k['label'], k['group'], k['unit'], k['value'], k['kind'],
             k['window']['from'], k['window']['to'], k['window']['days'], k['source']]
            for k in kpis
        ],
    }


def _wallet_breakdown(window):
    from apps.wallet.models import ArtifactTransaction

    qs = ArtifactTransaction.objects.filter(
        created_at__gte=window.start_dt, created_at__lt=window.end_dt_exclusive,
    )
    by_type = qs.values('transaction_type', 'direction').annotate(
        count=Count('id'), fiat=Sum('fiat_amount'),
    ).order_by('-count')
    rows = [
        {
            'transaction_type': row['transaction_type'],
            'direction': row['direction'],
            'count': row['count'],
            'fiat_sum': _num(row['fiat'] or 0),
            'fiat_currency': 'mixed (KES unless the row says otherwise)',
        }
        for row in by_type
    ]
    return _breakdown(
        'Wallet activity by type', window, rows,
        basis='ArtifactTransaction rows created in the window, grouped by transaction_type and direction',
        note='fiat_amount is summed without normalising fiat_currency; a row '
             'recorded in another currency is included at face value.',
    )


def _posts_breakdown(window):
    from apps.feed.models import Post

    qs = Post.objects.filter(
        is_deleted=False,
        created_at__gte=window.start_dt, created_at__lt=window.end_dt_exclusive,
    )
    rows = [
        {'post_type': row['post_type'], 'count': row['count']}
        for row in qs.values('post_type').annotate(count=Count('id')).order_by('-count')
    ]
    return _breakdown(
        'Posts by type', window, rows,
        basis='Post rows created in the window, soft-deleted excluded',
    )


# ---------------------------------------------------------------------------
# Timeseries
# ---------------------------------------------------------------------------

def build_timeseries(params):
    window = parse_window(params)
    granularity = _choice_param(params, 'granularity', ('day', 'week'), 'day')
    raw_metric = (params.get('metric') or '').strip()
    if not raw_metric:
        raise ValidationError({
            'metric': [f'Required. One of: {", ".join(TIMESERIES_METRICS)}.'],
        })
    if raw_metric not in METRIC_SPECS:
        raise ValidationError({
            'metric': [f'Unknown metric {raw_metric!r}. One of: {", ".join(sorted(METRIC_SPECS))}.'],
        })
    if raw_metric in REFUSED_METRICS:
        raise ValidationError({
            'metric': [
                f'{raw_metric} is not a series metric: {REFUSED_METRICS[raw_metric]}. '
                'It is available on /overview/ instead.',
            ],
        })
    spec = METRIC_SPECS[raw_metric]

    buckets, complete, missing = read_rollup(spec, window, granularity)
    source = 'rollup'
    if not complete:
        # Fall back rather than refuse: a fresh deployment has no rollup rows
        # yet, and "no data" would be a worse answer than a slow correct one.
        live = bucket_metric_live(spec, window, granularity)
        buckets = [{'bucket': b['bucket'], 'value': _num(live.get(b['bucket'], 0))}
                   for b in buckets]
        source = 'live'

    return {
        'window': window.as_dict(),
        'metric': {
            'key': spec.key, 'label': spec.label, 'unit': spec.unit,
            'group': spec.group, 'source': spec.source,
            'description': spec.description,
        },
        'granularity': granularity,
        'series': buckets,
        'totals': {
            'sum': _num(sum(b['value'] for b in buckets)),
            'non_zero_buckets': sum(1 for b in buckets if b['value']),
        },
        'data_source': {
            'path': source,
            'rollup_complete': complete,
            'missing_days': [d.isoformat() for d in missing],
            'note': (
                'Served from analytics_daily_platform_metric.'
                if source == 'rollup' else
                'Served by aggregating the source table because the rollup has '
                'gaps in this window (or has not run yet). Recompute with '
                'apps.analytics.tasks.rollup_daily_platform_metrics.'
            ),
        },
        'available_metrics': list(TIMESERIES_METRICS),
        'metric_catalogue': metric_catalogue(),
        'table': {
            'columns': ['bucket', 'value', 'metric', 'granularity', 'unit'],
            'rows': [
                [b['bucket'], b['value'], spec.key, granularity, spec.unit]
                for b in buckets
            ],
        },
    }


# ---------------------------------------------------------------------------
# Trending
# ---------------------------------------------------------------------------

TRENDING_KINDS = ('posts', 'services', 'events', 'hashtags', 'pages')

PAGES_UNAVAILABLE_REASON = (
    'No client emits a route-change or screen-view event. There is no page_view '
    'event name in the analytics event stream, and nothing in apps.analytics '
    'receives route changes from web or Flutter. Rather than chart an empty '
    'series, this endpoint says it has nothing. Adding tracking means shipping a '
    'page/screen event in both clients; until then this stays false.'
)


def build_trending(params):
    kind = _choice_param(params, 'kind', TRENDING_KINDS, 'posts')
    limit = _int_param(params, 'limit', TRENDING_LIMIT_DEFAULT, 1, TRENDING_LIMIT_MAX)
    window = parse_window(params)
    builders = {
        'posts': _trending_posts,
        'services': _trending_services,
        'events': _trending_events,
        'hashtags': _trending_hashtags,
    }
    if kind == 'pages':
        return {
            'kind': 'pages',
            'available': False,
            'reason': PAGES_UNAVAILABLE_REASON,
            'window': window.as_dict(),
            'items': [],
            'table': {'columns': ['note'], 'rows': [[PAGES_UNAVAILABLE_REASON]]},
        }
    payload = builders[kind](window, limit)
    payload.update({
        'kind': kind,
        'available': True,
        'window': window.as_dict(),
        'rank_basis': payload.pop('rank_basis'),
    })
    return payload


def _excerpt(text, limit=120):
    flat = ' '.join(str(text or '').split())
    return flat if len(flat) <= limit else flat[:limit].rstrip() + '…'


def _trending_posts(window, limit):
    from apps.feed.models import Post

    qs = Post.objects.filter(
        is_deleted=False,
        created_at__gte=window.start_dt, created_at__lt=window.end_dt_exclusive,
    ).select_related('author').annotate(
        reaction_total=Count('reactions', distinct=True),
        comment_total=Count('comments', distinct=True),
    )
    # Saves/shares have no created_at-window join available without three more
    # counts; view_count and share_count are denormalised counters on the row,
    # which is what the feed itself shows.
    rows = list(qs.order_by('-reaction_total', '-comment_total', '-view_count')[:limit])
    items = [
        {
            'rank': index,
            'post_id': str(post.id),
            'author_username': post.author.username,
            'post_type': post.post_type,
            'body_excerpt': _excerpt(post.body),
            'created_at': post.created_at.isoformat(),
            'reactions': post.reaction_total,
            'comments': post.comment_total,
            'view_count': post.view_count,
            'share_count': post.share_count,
            'engagement': post.reaction_total + post.comment_total,
        }
        for index, post in enumerate(rows, start=1)
    ]
    return {
        'rank_basis': 'Reactions and comments on posts created inside the window '
                      '(denormalised view_count / share_count shown as recorded).',
        'items': items,
        'table': {
            # body_excerpt is in the export as well as the response: a trending
            # list whose export drops the text is not the list the operator saw.
            'columns': ['rank', 'post_id', 'author_username', 'post_type',
                        'body_excerpt', 'created_at', 'reactions', 'comments',
                        'engagement', 'view_count', 'share_count'],
            'rows': [[i['rank'], i['post_id'], i['author_username'], i['post_type'],
                      i['body_excerpt'], i['created_at'], i['reactions'],
                      i['comments'], i['engagement'], i['view_count'],
                      i['share_count']] for i in items],
        },
    }


def _trending_services(window, limit):
    from apps.marketplace.models import (
        MealPlan, MealPlanPurchase, TrainingProgramme, TrainingProgrammePurchase,
    )

    meal_purchases = list(
        MealPlanPurchase.objects
        .filter(created_at__gte=window.start_dt, created_at__lt=window.end_dt_exclusive)
        .values('meal_plan_id').annotate(n=Count('id')).order_by('-n')[:limit]
    )
    prog_purchases = list(
        TrainingProgrammePurchase.objects
        .filter(created_at__gte=window.start_dt, created_at__lt=window.end_dt_exclusive)
        .values('programme_id').annotate(n=Count('id')).order_by('-n')[:limit]
    )
    plans = {
        p.id: p for p in MealPlan.objects
        .filter(pk__in=[row['meal_plan_id'] for row in meal_purchases])
        .select_related('creator')
    }
    programmes = {
        p.id: p for p in TrainingProgramme.objects
        .filter(pk__in=[row['programme_id'] for row in prog_purchases])
        .select_related('creator')
    }

    items = []
    for row in meal_purchases:
        plan = plans.get(row['meal_plan_id'])
        if plan is None:
            continue
        items.append({
            'kind': 'meal_plan', 'id': str(plan.id), 'title': plan.title,
            'creator': plan.creator.username if plan.creator else None,
            'purchases_in_window': row['n'],
            'purchase_count_total': plan.purchase_count,
            'average_rating': plan.average_rating,
            'review_count': plan.review_count,
            'is_published': plan.is_published,
        })
    for row in prog_purchases:
        prog = programmes.get(row['programme_id'])
        if prog is None:
            continue
        # TrainingProgramme carries no denormalised rating columns, so those two
        # are genuinely null for programmes rather than zero.
        items.append({
            'kind': 'training_programme', 'id': str(prog.id), 'title': prog.title,
            'creator': prog.creator.username if prog.creator else None,
            'purchases_in_window': row['n'],
            'purchase_count_total': prog.purchase_count,
            'average_rating': None,
            'review_count': None,
            'is_published': prog.is_published,
        })
    items.sort(key=lambda i: (-i['purchases_in_window'], i['kind'], i['title'] or ''))
    items = items[:limit]
    for index, item in enumerate(items, start=1):
        item['rank'] = index
    return {
        'rank_basis': 'Purchase rows created inside the window (meal plans and '
                      'training programmes, ranked together).',
        'items': items,
        'table': {
            'columns': ['rank', 'kind', 'id', 'title', 'creator', 'purchases_in_window',
                        'purchase_count_total', 'average_rating', 'review_count', 'is_published'],
            'rows': [[i['rank'], i['kind'], i['id'], i['title'], i['creator'],
                      i['purchases_in_window'], i['purchase_count_total'],
                      i['average_rating'], i['review_count'], i['is_published']]
                     for i in items],
        },
    }


def _trending_events(window, limit):
    from apps.marketplace.models import SOLD_TICKET_STATUSES, EventTicket, MarketplaceEvent

    tickets = (
        EventTicket.objects
        .filter(created_at__gte=window.start_dt, created_at__lt=window.end_dt_exclusive)
        .values('event_id').annotate(n=Count('id'))
    )
    sold = dict(
        EventTicket.objects
        .filter(created_at__gte=window.start_dt, created_at__lt=window.end_dt_exclusive,
                status__in=SOLD_TICKET_STATUSES)
        .values('event_id').annotate(n=Count('id')).values_list('event_id', 'n'),
    )
    ids = [row['event_id'] for row in tickets.order_by('-n')[:limit]]
    events = {
        str(e.id): e for e in MarketplaceEvent.objects.filter(pk__in=ids)
        .select_related('shop', 'gym')
    }
    items = []
    for row in sorted(tickets, key=lambda r: -r['n']):
        event = events.get(str(row['event_id']))
        if event is None:
            continue
        items.append({
            'rank': 0,
            'id': str(event.id),
            'title': event.title,
            'category': event.category,
            'event_type': event.event_type,
            'starts_at': event.start_datetime.isoformat() if event.start_datetime else None,
            'shop': event.shop.name if event.shop else None,
            'gym': event.gym.name if event.gym else None,
            'tickets_in_window': row['n'],
            'sold_tickets_in_window': sold.get(row['event_id'], 0),
            'attendee_count': event.attendee_count,
            'is_published': event.is_published,
            'is_cancelled': event.is_cancelled,
        })
    for index, item in enumerate(items, start=1):
        item['rank'] = index
    return {
        'rank_basis': 'EventTicket rows created inside the window. sold_tickets '
                      'excludes cancelled/refunded, matching the attendee count '
                      'an organiser sees.',
        'items': items[:limit],
        'table': {
            'columns': ['rank', 'id', 'title', 'category', 'event_type', 'starts_at',
                        'shop', 'gym', 'tickets_in_window', 'sold_tickets_in_window',
                        'attendee_count', 'is_published', 'is_cancelled'],
            'rows': [[i['rank'], i['id'], i['title'], i['category'], i['event_type'],
                      i['starts_at'], i['shop'], i['gym'], i['tickets_in_window'],
                      i['sold_tickets_in_window'], i['attendee_count'],
                      i['is_published'], i['is_cancelled']] for i in items[:limit]],
        },
    }


def _trending_hashtags(window, limit):
    from apps.feed.models import PostTag

    # Created on PostTag so the join table's own index answers "newest first";
    # comparing against the previous window is what makes it a *trend* rather
    # than a popularity list.
    previous = Window(
        window.start_date - dt.timedelta(days=window.days),
        window.start_date - dt.timedelta(days=1),
    )
    counts = dict(
        PostTag.objects
        .filter(created_at__gte=window.start_dt, created_at__lt=window.end_dt_exclusive)
        .values_list('tag_id').annotate(n=Count('id')),
    )
    prior = dict(
        PostTag.objects
        .filter(created_at__gte=previous.start_dt, created_at__lt=previous.end_dt_exclusive)
        .values_list('tag_id').annotate(n=Count('id')),
    )
    from apps.feed.models import Tag
    tags = {t.id: t for t in Tag.objects.filter(pk__in=list(counts))}
    items = []
    for tag_id, count in counts.items():
        tag = tags.get(tag_id)
        if tag is None:
            continue
        before = prior.get(tag_id, 0)
        items.append({
            'rank': 0,
            'tag': tag.name,
            'tag_id': str(tag.id),
            'posts_in_window': count,
            'posts_in_previous_window': before,
            'delta': count - before,
            'pct_change': None if before == 0 else round((count - before) * 100.0 / before, 1),
            'total_posts_ever': tag.post_links.count(),
        })
    items.sort(key=lambda i: (-i['posts_in_window'], i['tag']))
    items = items[:limit]
    for index, item in enumerate(items, start=1):
        item['rank'] = index
    return {
        'rank_basis': 'PostTag rows created inside the window, with the '
                      'immediately preceding window of the same length for '
                      'comparison. Requires apps.feed.backfill_post_tags to have '
                      'run — a tag applied to an old post today counts as new '
                      'today, because that is when the association was indexed.',
        'items': items,
        'table': {
            'columns': ['rank', 'tag', 'posts_in_window', 'posts_in_previous_window',
                        'delta', 'pct_change', 'total_posts_ever'],
            'rows': [[i['rank'], i['tag'], i['posts_in_window'],
                      i['posts_in_previous_window'], i['delta'], i['pct_change'],
                      i['total_posts_ever']] for i in items],
        },
    }


# ---------------------------------------------------------------------------
# AI quality
# ---------------------------------------------------------------------------

#: Confidence histogram edges. Fixed buckets so two windows are comparable.
CONFIDENCE_BUCKETS = (
    (0.0, 0.2, '0.0-0.2'), (0.2, 0.4, '0.2-0.4'), (0.4, 0.6, '0.4-0.6'),
    (0.6, 0.8, '0.6-0.8'), (0.8, 1.0001, '0.8-1.0'),
)

#: Above this many rows in the window, latency percentiles are computed from a
#: sample and the response says so. Accuracy/fallback/cost are exact.
LATENCY_SAMPLE_LIMIT = 20000

ACCURACY_IS_A_PROXY = (
    'AIPredictionJob has no ground-truth column. `correction` is written when a '
    'human overrides an AI output, so corrected/calls is a correction rate — a '
    'proxy for accuracy that is biased toward what people bother to correct. It '
    'is not a measured accuracy and is labelled accuracy_proxy everywhere it '
    'appears.'
)


def _percentile(sorted_values, fraction):
    """Nearest-rank percentile. Returns None for an empty series."""
    if not sorted_values:
        return None
    if len(sorted_values) == 1:
        return sorted_values[0]
    position = fraction * (len(sorted_values) - 1)
    low = int(position)
    high = min(low + 1, len(sorted_values) - 1)
    weight = position - low
    return sorted_values[low] * (1 - weight) + sorted_values[high] * weight


def build_ai_quality(params):
    from apps.ai.models import AIPredictionJob

    window = parse_window(params)
    jobs = AIPredictionJob.objects.filter(
        created_at__gte=window.start_dt, created_at__lt=window.end_dt_exclusive,
    )
    total = jobs.count()
    total_cost = jobs.aggregate(total=Sum('cost_usd'))['total'] or Decimal('0')
    # Cumulative: every row ever, ignoring the window. A per-window cost that
    # resets looks like a spend of zero when nobody called anything.
    lifetime_cost = AIPredictionJob.objects.aggregate(total=Sum('cost_usd'))['total'] or Decimal('0')
    lifetime_calls = AIPredictionJob.objects.count()

    latencies = sorted(
        jobs.exclude(latency_ms__isnull=True)
        .values_list('latency_ms', flat=True)[:LATENCY_SAMPLE_LIMIT],
    )
    sampled = len(latencies) < LATENCY_SAMPLE_LIMIT

    fallback_rate = _ratio(jobs.filter(fallback_used=True).count(), total)
    corrections = jobs.exclude(correction={}).count()

    rows = []
    grouped = jobs.values('task', 'model_version').annotate(
        calls=Count('id'),
        completed=Count('id', filter=Q(status='completed')),
        failed=Count('id', filter=Q(status='failed')),
        fallbacks=Count('id', filter=Q(fallback_used=True)),
        corrected=Count('id', filter=~Q(correction={})),
        confidence=Avg('confidence'),
        cost=Sum('cost_usd'),
    ).order_by('-calls')
    for row in grouped:
        model = row['model_version'] or f'task:{row["task"]}'
        rows.append({
            'model': model,
            'task': row['task'],
            'model_version': row['model_version'],
            'calls': row['calls'],
            'completed': row['completed'],
            'failed': row['failed'],
            'success_rate': _ratio(row['completed'], row['calls']),
            'fallbacks': row['fallbacks'],
            'fallback_rate': _ratio(row['fallbacks'], row['calls']),
            'corrections': row['corrected'],
            'accuracy_proxy': _ratio(row['corrected'], row['completed']),
            'mean_confidence': _num(row['confidence']) if row['confidence'] is not None else None,
            'cost_usd': _num(row['cost'] or 0),
            'cost_per_call_usd': _num((row['cost'] or 0) / row['calls']) if row['calls'] else 0,
        })

    return {
        'window': window.as_dict(),
        'totals': {
            'calls': total,
            'fallbacks': jobs.filter(fallback_used=True).count(),
            'fallback_rate': fallback_rate,
            'corrections': corrections,
            'accuracy_proxy': _ratio(corrections, jobs.filter(status='completed').count()),
            'cost_usd': _num(total_cost),
            'cost_per_call_usd': _num((total_cost / total) if total else 0),
            'cumulative_cost_usd': _num(lifetime_cost),
            'cumulative_calls': lifetime_calls,
            'cumulative_cost_per_call_usd': _num((lifetime_cost / lifetime_calls) if lifetime_calls else 0),
        },
        'latency_ms': {
            'samples': len(latencies),
            'sampled': not sampled,
            'sample_limit': LATENCY_SAMPLE_LIMIT,
            'p50': _ms(_percentile(latencies, 0.50)),
            'p95': _ms(_percentile(latencies, 0.95)),
            'min': latencies[0] if latencies else None,
            'max': latencies[-1] if latencies else None,
        },
        'confidence_distribution': _confidence_distribution(window),
        'fallback_reasons': _fallback_reasons(window),
        'models': rows,
        'caveats': [ACCURACY_IS_A_PROXY],
        'table': _ai_quality_table(rows),
    }


def _ms(value):
    """A latency percentile in whole milliseconds, or None when there is no data.

    Deliberately *not* routed through ``_num``, which maps None to 0: "no jobs
    ran" must not read as "every job took 0ms".
    """
    return None if value is None else int(round(value))


def _ratio(numerator, denominator):
    if not denominator:
        return None
    return round(numerator * 1.0 / denominator, 4)


def _confidence_distribution(window):
    from apps.ai.models import AIPredictionJob

    jobs = AIPredictionJob.objects.filter(
        created_at__gte=window.start_dt, created_at__lt=window.end_dt_exclusive,
    ).exclude(confidence__isnull=True)
    total = jobs.count()
    buckets = [{'bucket': label, 'low': low, 'high': high, 'count': 0} for low, high, label in CONFIDENCE_BUCKETS]
    for value in jobs.values_list('confidence', flat=True):
        for entry in buckets:
            if entry['low'] <= value < entry['high']:
                entry['count'] += 1
                break
    return {
        'window': window.as_dict(),
        'with_confidence': total,
        'buckets': buckets,
    }


def _fallback_reasons(window):
    from apps.ai.models import AIPredictionJob

    rows = (
        AIPredictionJob.objects
        .filter(created_at__gte=window.start_dt, created_at__lt=window.end_dt_exclusive,
                fallback_used=True)
        .values('fallback_reason').annotate(count=Count('id')).order_by('-count')
    )
    return [
        {'reason': row['fallback_reason'] or '(blank)', 'count': row['count']}
        for row in rows
    ]


def _ai_quality_table(rows):
    return {
        'columns': ['model', 'task', 'model_version', 'calls', 'completed', 'failed',
                    'success_rate', 'fallbacks', 'fallback_rate', 'corrections',
                    'accuracy_proxy', 'mean_confidence', 'cost_usd', 'cost_per_call_usd'],
        'rows': [[r['model'], r['task'], r['model_version'], r['calls'], r['completed'],
                  r['failed'], r['success_rate'], r['fallbacks'], r['fallback_rate'],
                  r['corrections'], r['accuracy_proxy'], r['mean_confidence'],
                  r['cost_usd'], r['cost_per_call_usd']] for r in rows],
    }


# ---------------------------------------------------------------------------
# Predictive signals
# ---------------------------------------------------------------------------

PREDICTIVE_NOT_FORECAST = (
    'This endpoint reports observed signals only. It does not forecast: there is '
    'no model here and no projection of any value. Anything derived rather than '
    'counted is labelled "derived".'
)

IMPRESSION_SOURCE_NOTE = (
    'Recommendation impressions come from AnalyticsEvent rows named '
    'recommendation.item_impression, written by the recommendation endpoint. '
    'properties.source is "ai" when a model ranked the list and "fallback" when '
    'the deterministic path served it. Rows written before properties.source '
    'existed count as unlabelled, not as either.'
)


def _signal(key, label, value, *, derived=False, basis='', note=''):
    return {
        'key': key,
        'label': label,
        'observed': not derived,
        'derivation': 'derived from observed counts' if derived else 'directly counted',
        'basis': basis,
        'value': value,
        'note': note,
    }


def build_predictive(params):
    from apps.analytics.models import AnalyticsEvent
    from apps.profiles.models import RecommendationFeedback

    window = parse_window(params)

    counted = list(
        RecommendationFeedback.objects
        .filter(created_at__gte=window.start_dt, created_at__lt=window.end_dt_exclusive)
        .values('feedback').annotate(count=Count('id')).order_by('-count')
    )
    feedback_total = sum(row['count'] for row in counted)
    feedback_rows = [
        {'feedback': row['feedback'], 'count': row['count'],
         'share': _ratio(row['count'], feedback_total)}
        for row in counted
    ]
    negative = sum(row['count'] for row in counted
                   if row['feedback'] in ('not_interested', 'irrelevant'))
    positive = sum(row['count'] for row in counted if row['feedback'] == 'helpful')

    impressions = AnalyticsEvent.objects.filter(
        event_name='recommendation.item_impression',
        received_at__gte=window.start_dt, received_at__lt=window.end_dt_exclusive,
    )
    # JSON key lookups: Postgres-only, which this project is (see DATABASES in
    # config/settings/base.py). A backend that cannot do them reports the total
    # and leaves the split null rather than 500-ing the endpoint.
    impression_total = impressions.count()
    ai_impressions = fallback_impressions = None
    unlabelled = impression_total
    try:
        ai_impressions = impressions.filter(properties__source='ai').count()
        fallback_impressions = impressions.filter(properties__source='fallback').count()
        unlabelled = impression_total - ai_impressions - fallback_impressions
    except NotSupportedError:
        logger.warning('recommendation_impression_source_split_unsupported_backend')

    job_total = corrected = completed = None
    try:
        from apps.ai.models import AIPredictionJob
        jobs = AIPredictionJob.objects.filter(
            created_at__gte=window.start_dt, created_at__lt=window.end_dt_exclusive,
        )
        job_total = jobs.count()
        corrected = jobs.exclude(correction={}).count()
        completed = jobs.filter(status='completed').count()
    except Exception:  # noqa: BLE001 — the AI app is optional to this report
        logger.warning('ai_prediction_jobs_unavailable_for_predictive')

    signals = [
        _signal('recommendation_feedback.total', 'Recommendation feedback rows',
                feedback_total,
                basis='RecommendationFeedback rows created in the window'),
        _signal('recommendation_feedback.negative_share', 'Negative feedback share',
                _ratio(negative, feedback_total), derived=True,
                basis='ratio: (not_interested + irrelevant) over all feedback '
                      'rows in the window',
                note='Negative share is a ratio of two counted sets. It is not a '
                     'model score and not a forecast of churn.'),
        _signal('recommendation_feedback.positive_share', 'Helpful share',
                _ratio(positive, feedback_total), derived=True,
                basis='ratio: helpful over all feedback rows in the window'),
        _signal('recommendation.impressions.total', 'Recommendation impressions',
                impression_total,
                basis='AnalyticsEvent rows named recommendation.item_impression'),
        _signal('recommendation.impressions.ai', 'Impressions served by a model',
                ai_impressions,
                basis='properties.source = "ai"',
                note=IMPRESSION_SOURCE_NOTE),
        _signal('recommendation.impressions.fallback',
                'Impressions served by the fallback path', fallback_impressions,
                basis='properties.source = "fallback"'),
        _signal('recommendation.impressions.ai_share', 'AI-served impression share',
                _ratio(ai_impressions, impression_total), derived=True,
                basis='ai impressions over all impressions in the window'),
        _signal('ai_jobs.correction_rate', 'AI correction rate',
                _ratio(corrected, completed), derived=True,
                basis='AIPredictionJob rows with a non-empty correction over completed rows',
                note=ACCURACY_IS_A_PROXY),
    ]

    return {
        'window': window.as_dict(),
        'disclaimer': PREDICTIVE_NOT_FORECAST,
        'signals': signals,
        'observed': {
            'recommendation_feedback': {
                'window': window.as_dict(),
                'total': feedback_total,
                'rows': feedback_rows,
                'negative': negative,
                'positive': positive,
                'source': 'profiles.RecommendationFeedback.created_at',
            },
            'recommendation_impressions': {
                'window': window.as_dict(),
                'total': impression_total,
                'ai': ai_impressions,
                'fallback': fallback_impressions,
                'unlabelled': unlabelled,
                'source': 'analytics.AnalyticsEvent(event_name=recommendation.item_impression).properties.source',
            },
            'ai_jobs': {
                'window': window.as_dict(),
                'total': job_total,
                'corrected': corrected,
                'completed': completed,
                'source': 'ai.AIPredictionJob.correction',
            },
        },
        'table': {
            'columns': ['section', 'key', 'value', 'observed', 'basis'],
            'rows': (
                [['recommendation_feedback', row['feedback'], row['count'], True,
                  'RecommendationFeedback rows created in the window']
                 for row in feedback_rows]
                + [['signals', s['key'], s['value'], s['observed'], s['basis']]
                   for s in signals]
            ),
        },
    }


# ---------------------------------------------------------------------------
# Report registry — the single source for both the screen and the export
# ---------------------------------------------------------------------------

REPORTS = {
    'overview': {
        'label': 'Platform overview',
        'builder': build_overview,
        'scoped_params': (),
        'description': 'The same KPI rows /overview/ renders.',
    },
    'timeseries': {
        'label': 'Metric time series',
        'builder': build_timeseries,
        'scoped_params': ('metric', 'granularity'),
        'description': 'One row per bucket for one metric.',
    },
    'trending': {
        'label': 'Trending',
        'builder': build_trending,
        'scoped_params': ('kind', 'limit'),
        'description': 'Top items for posts / services / events / hashtags.',
    },
    'ai_quality': {
        'label': 'AI quality and cost',
        'builder': build_ai_quality,
        'scoped_params': (),
        'description': 'Per-model accuracy proxy, fallback rate, latency, cost.',
    },
    'predictive': {
        'label': 'Recommendation signals',
        'builder': build_predictive,
        'scoped_params': (),
        'description': 'Observed recommendation feedback and impression split. '
                       'No forecast.',
    },
}