import 'dart:convert';
import 'dart:typed_data';

import 'package:buddy_up_flutter/data/models/auth_models.dart';
import 'package:buddy_up_flutter/data/models/platform_analytics.dart';
import 'package:buddy_up_flutter/data/models/verification.dart';
import 'package:buddy_up_flutter/features/admin/providers/analytics_provider.dart';
import 'package:buddy_up_flutter/features/admin/providers/verification_provider.dart';
import 'package:buddy_up_flutter/features/verification/providers/verification_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

/// Contract tests for `/api/v1/portal/analytics/**` and the two-person
/// verification flow.
///
/// Fixtures are shaped from `backend/apps/analytics/platform_metrics.py`,
/// `platform_views.py`, `exports.py` and `backend/apps/verification/*`. The
/// shape of these assertions is deliberate: each one pins a behaviour that a
/// naive client gets *wrong in a way that reads as success* — a gauge labelled
/// with the page's window, a missing measurement rendered as an empty list, a
/// 202 reported as an approval, a capped export reported as a file.
void main() {
  // `Env.apiBaseUrl` reads `.env` through flutter_dotenv, and the app's
  // `main()` calls `dotenv.load()`. A unit test has no app bootstrap, so the
  // store is primed here rather than the export URL builder being taught to
  // tolerate an uninitialised environment.
  dotenv.loadFromString(envString: 'API_BASE_URL=https://api.buddyup.app/api/v1');

  group('overview: every KPI declares its own window', () {
    test('a gauge and a flow are told apart by kind, not by label', () {
      final overview = AnalyticsOverview.fromJson({
        'window': {'from': '2026-02-01', 'to': '2026-03-02', 'days': 30},
        'kpis': [
          {
            'key': 'users.total',
            'label': 'Total users',
            'value': 1240,
            'kind': 'gauge',
            // `_kpi()` labels a gauge "All time" even though the window object
            // is the same one the flow tiles carry.
            'window': {'label': 'All time', 'from': '2026-02-01', 'to': '2026-03-02'},
          },
          {
            'key': 'users.new',
            'label': 'New users',
            'value': 88,
            'kind': 'flow',
            'window': {'label': 'Window', 'from': '2026-02-01', 'to': '2026-03-02'},
          },
        ],
      });

      final kpis = overview.parsedKpis;
      expect(kpis, hasLength(2));
      expect(kpis.first.isGauge, isTrue);
      expect(kpis.first.windowLabel, 'All time');
      expect(kpis.last.isFlow, isTrue);
      expect(kpis.last.windowLabel, 'Window');
      // The two captions differ even though the ranges are identical, which is
      // the whole point of the endpoint.
      expect(kpis.first.windowLabel, isNot(kpis.last.windowLabel));
    });

    test('an absent kind defaults to a gauge and says All time', () {
      final kpi = AnalyticsKpi.fromJson({'key': 'x', 'label': 'X', 'value': 5});
      expect(kpi.isGauge, isTrue);
      expect(kpi.windowLabel, 'All time');
    });

    test('a money KPI gets decimals and a count does not', () {
      final gross = AnalyticsKpi.fromJson({
        'key': 'orders.gross_usd',
        'unit': 'usd',
        'value': 1234.5,
        'kind': 'flow',
      });
      expect(gross.formattedValue, '\$1,234.50');
      final users = AnalyticsKpi.fromJson({
        'key': 'users.total',
        'unit': 'count',
        'value': 1204000,
        'kind': 'gauge',
      });
      expect(users.formattedValue, '1,204,000');
    });

    test('performance_notes are read, including the migration that fixes them',
        () {
      final overview = AnalyticsOverview.fromJson({
        'performance_notes': [
          {
            'source': 'accounts.User.created_at',
            'issue': 'no index; this figure costs a sequential scan until one exists',
            'suggested_migration':
                'AddIndex(fields=["-created_at"], name="accounts_user_created_idx")',
            'owner': 'accounts',
          },
        ],
      });
      final notes = overview.parsedPerformanceNotes;
      expect(notes, hasLength(1));
      expect(notes.single.source, 'accounts.User.created_at');
      expect(notes.single.owner, 'accounts');
      expect(notes.single.suggestedMigration, contains('AddIndex'));
    });

    test('breakdown rows keep whatever shape the builder chose', () {
      final overview = AnalyticsOverview.fromJson({
        'breakdowns': [
          {
            'title': 'Wallet activity by type',
            'basis': 'ArtifactTransaction rows created in the window',
            'rows': [
              {
                'transaction_type': 'debit',
                'direction': 'debit',
                'count': 4,
                'fiat_sum': 120.0,
              },
            ],
          },
        ],
      });
      final breakdown = overview.parsedBreakdowns.single;
      expect(breakdown.columns, contains('fiat_sum'));
      expect(breakdown.columns, contains('transaction_type'));
    });
  });

  group('timeseries: zero-filled buckets and provenance', () {
    Map<String, dynamic> payload({
      String path = 'rollup',
      bool rollupComplete = true,
      List<String> missing = const [],
    }) =>
        {
          'window': {'from': '2026-03-01', 'to': '2026-03-03', 'days': 3},
          'metric': {
            'key': 'orders.new',
            'label': 'New orders',
            'unit': 'count',
            'group': 'commerce',
            'source': 'marketplace.Order.created_at',
            'description': 'Orders created inside the window.',
          },
          'granularity': 'day',
          'series': [
            {'bucket': '2026-03-01', 'value': 4},
            {'bucket': '2026-03-02', 'value': 0},
            {'bucket': '2026-03-03', 'value': 7},
          ],
          'totals': {'sum': 11, 'non_zero_buckets': 2},
          'data_source': {
            'path': path,
            'rollup_complete': rollupComplete,
            'missing_days': missing,
            'note': 'Served from analytics_daily_platform_metric.',
          },
          'available_metrics': ['orders.new', 'users.new'],
          'metric_catalogue': [
            {
              'key': 'orders.new',
              'label': 'New orders',
              'additive': true,
              'windowed': true,
            },
            {
              'key': 'analytics.active_users',
              'label': 'Active users',
              'additive': false,
              'windowed': true,
            },
          ],
          'table': {
            'columns': ['bucket', 'value'],
            'rows': [
              ['2026-03-01', 4],
              ['2026-03-02', 0],
            ],
          },
        };

    test('the zero-filled bucket is kept, not dropped', () {
      final series = AnalyticsTimeseries.fromJson(payload());
      expect(series.buckets, hasLength(3));
      // A zero in the middle is a fact about the data, and dropping it would
      // make the series look continuous.
      expect(series.buckets[1].isZero, isTrue);
      expect(series.isAllZero, isFalse);
    });

    test('the peak is the largest bucket, and null when the series is flat',
        () {
      final series = AnalyticsTimeseries.fromJson(payload());
      expect(series.peak, 7);

      final flat = AnalyticsTimeseries.fromJson({
        'series': [
          {'bucket': '2026-03-01', 'value': 0},
          {'bucket': '2026-03-02', 'value': 0},
        ],
      });
      // Null rather than 0: the bar widget must be able to say "no scale"
      // instead of dividing by zero.
      expect(flat.peak, isNull);
      expect(flat.isAllZero, isTrue);
    });

    test('data_source.path decides rollup vs live, and an absent path is live',
        () {
      expect(
        AnalyticsTimeseries.fromJson(payload()).source.isRollup,
        isTrue,
      );
      final live = AnalyticsTimeseries.fromJson(payload(
        path: 'live',
        rollupComplete: false,
        missing: ['2026-03-02'],
      ));
      expect(live.source.isLive, isTrue);
      expect(live.source.missingDays, ['2026-03-02']);

      // A renamed `path` must not read as the cheap path.
      final unknown = AnalyticsTimeseries.fromJson({
        'data_source': {'rollup_complete': true},
      });
      expect(unknown.source.isRollup, isFalse);
    });

    test('the catalogue marks non-additive metrics as not plottable', () {
      final series = AnalyticsTimeseries.fromJson(payload());
      final plottable = series.catalogue.where((e) => e.isPlottable).toList();
      expect(plottable.map((e) => e.key), ['orders.new']);
      final active = series.catalogue
          .firstWhere((e) => e.key == 'analytics.active_users');
      expect(active.additive, isFalse);
      expect(active.isPlottable, isFalse);
    });
  });

  group('trending: available:false is never an empty list', () {
    test('the pages refusal keeps its reason and blocks the item list', () {
      const reason =
          'No client emits a route-change or screen-view event. There is no '
          'page_view event name in the analytics event stream.';
      final trending = AnalyticsTrending.fromJson({
        'kind': 'pages',
        'available': false,
        'reason': reason,
        'items': [],
        'window': {'from': '2026-02-01', 'to': '2026-03-02'},
      });

      // The two are different claims. "Nothing trended" and "we cannot see
      // page views" must never render the same way.
      expect(trending.isUnavailable, isTrue);
      expect(trending.unavailableReason, reason);
      expect(trending.parsedItems, isEmpty);
      expect(trending.trendingKind, TrendingKind.pages);
    });

    test('an absent available flag does not let a list through', () {
      final trending = AnalyticsTrending.fromJson({
        'kind': 'posts',
        'items': [
          {'rank': 1},
        ],
      });
      // Defaults false: an absent flag is not permission to render the list as
      // though the server had vouched for it.
      expect(trending.isUnavailable, isTrue);
    });

    test('an available kind renders its items and its rank basis', () {
      final trending = AnalyticsTrending.fromJson({
        'kind': 'hashtags',
        'available': true,
        'rank_basis': 'PostTag rows created inside the window.',
        'items': [
          {
            'rank': 1,
            'tag': 'gymtok',
            'tag_id': '8f1c',
            'posts_in_window': 12,
            'posts_in_previous_window': 5,
            'delta': 7,
            'pct_change': 140.0,
            'total_posts_ever': 40,
          },
          {
            'rank': 2,
            'tag': 'new',
            'posts_in_window': 3,
            'posts_in_previous_window': 0,
            'delta': 3,
            // Null, not 0: there is no percentage change from nothing.
            'pct_change': null,
          },
        ],
      });
      expect(trending.isUnavailable, isFalse);
      expect(trending.rankBasis, contains('PostTag'));
      final items = trending.parsedItems;
      expect(items, hasLength(2));
      expect(items.first.pctChange, 140.0);
      expect(items.last.pctChange, isNull);
      expect(items.last.delta, 3);
    });

    test('hashtag, post, event and service fields all land in one row model',
        () {
      final items = [
        TrendingItem.fromJson({
          'rank': 1,
          'post_id': 'abc',
          'author_username': 'peter',
          'reactions': 9,
          'comments': 2,
          'engagement': 11,
        }),
        TrendingItem.fromJson({
          'rank': 1,
          'kind': 'meal_plan',
          'title': 'Keto 30',
          'creator': 'sam',
          'purchases_in_window': 6,
          'average_rating': null,
        }),
        TrendingItem.fromJson({
          'rank': 1,
          'id': 'e1',
          'title': 'Park run',
          'starts_at': '2026-03-04T06:00:00Z',
          'tickets_in_window': 30,
          'sold_tickets_in_window': 22,
        }),
      ];
      expect(items[0].authorUsername, 'peter');
      expect(items[0].engagement, 11);
      expect(items[1].kind, 'meal_plan');
      // Genuinely null for a programme with no denormalised rating columns.
      expect(items[1].averageRating, isNull);
      expect(items[2].soldTicketsInWindow, 22);
      expect(items[2].startsAt, contains('2026-03-04'));
    });
  });

  group('ai quality: accuracy_proxy is never called accuracy', () {
    test('the field is named accuracy_proxy in the model', () {
      final totals = AiQualityTotals.fromJson({
        'calls': 120,
        'fallbacks': 9,
        'fallback_rate': 0.075,
        'corrections': 14,
        'accuracy_proxy': 0.1166,
        'cost_usd': 3.25,
        'cumulative_cost_usd': 41.9,
        'cumulative_calls': 1800,
      });
      expect(totals.accuracyProxy, closeTo(0.1166, 0.0001));
      expect(analyticsPercent(totals.accuracyProxy), '11.7%');
    });

    test('a null ratio prints as a dash, never as 0%', () {
      // The server routes these through `_ratio`, which returns None when the
      // denominator is zero. "No jobs ran" must not read as "every job hit the
      // fallback".
      expect(analyticsPercent(null), '—');
      expect(analyticsPercent(0.0), '0.0%');
      expect(analyticsMs(null), '—');
      expect(analyticsMs(0), '0 ms');
    });

    test('latency percentiles stay null when nothing ran', () {
      final latency = AiQualityLatency.fromJson({
        'samples': 0,
        'sampled': false,
        'p50': null,
        'p95': null,
        'min': null,
        'max': null,
      });
      expect(latency.p50, isNull);
      expect(analyticsMs(latency.p50), '—');
    });

    test('the caveats array survives so the proxy can be qualified', () {
      final report = AiQualityReport.fromJson({
        'caveats': [
          'AIPredictionJob has no ground-truth column.',
        ],
        'totals': {'calls': 5},
      });
      expect(report.caveats.single, contains('no ground-truth'));
    });
  });

  group('predictive: observed is distinct from derived', () {
    test('a counted signal and a ratio are told apart by `observed`', () {
      final report = PredictiveReport.fromJson({
        'disclaimer':
            'This endpoint reports observed signals only. It does not forecast: '
            'there is no model here and no projection of any value.',
        'signals': [
          {
            'key': 'recommendation_feedback.total',
            'label': 'Recommendation feedback rows',
            'observed': true,
            'derivation': 'directly counted',
            'basis': 'RecommendationFeedback rows created in the window',
            'value': 40,
          },
          {
            'key': 'recommendation_feedback.negative_share',
            'label': 'Negative feedback share',
            'observed': false,
            'derivation': 'derived from observed counts',
            'basis': 'ratio: (not_interested + irrelevant) over all feedback',
            'value': 0.225,
          },
          {
            'key': 'recommendation.impressions.ai',
            'label': 'Impressions served by a model',
            'observed': true,
            // Null on a database that cannot index into the JSON properties.
            'value': null,
          },
        ],
      });

      final signals = report.parsedSignals;
      expect(signals[0].observed, isTrue);
      expect(signals[0].isDerived, isFalse);
      expect(signals[1].observed, isFalse);
      expect(signals[1].isDerived, isTrue);
      expect(signals[2].value, isNull);
      expect(report.disclaimerText, contains('does not forecast'));
    });

    test('a missing disclaimer still refuses to be blank', () {
      final report = PredictiveReport.fromJson({'signals': []});
      expect(report.disclaimerText, contains('does not forecast'));
    });
  });

  group('decoding never crashes on a renamed or absent field', () {
    test('an entirely empty body parses to every default', () {
      expect(() => AnalyticsOverview.fromJson({}), returnsNormally);
      expect(() => AnalyticsTimeseries.fromJson({}), returnsNormally);
      expect(() => AnalyticsTrending.fromJson({}), returnsNormally);
      expect(() => AiQualityReport.fromJson({}), returnsNormally);
      expect(() => PredictiveReport.fromJson({}), returnsNormally);
      expect(AnalyticsTable.fromJson({'rows': null}).rows, isEmpty);
      // A table whose `rows` are not lists degrades to empty rather than
      // throwing a cast error inside the report block.
      expect(AnalyticsTable.fromJson({'rows': ['nope', null]}).rows, isEmpty);
    });

    test('a window with only a label keeps its dates empty rather than null',
        () {
      const window = AnalyticsWindow(label: 'All time');
      expect(window.fromDate, '');
      expect(window.toDate, '');
      expect(window.range, '—');
      expect(window.displayLabel, 'All time');
      expect(window.isGaugeLabel, isTrue);
    });
  });

  group('export: the URL carries the current filters', () {
    test('every filter the screen is showing is in the address', () {
      final url = analyticsExportUrl(
        const AnalyticsQuery(
          from: '2026-02-01',
          to: '2026-03-02',
          metric: 'orders.new',
          granularity: 'week',
          kind: 'hashtags',
          limit: 25,
        ),
        report: 'timeseries',
        format: 'csv',
      );

      expect(url.path, endsWith('/portal/analytics/export/'));
      expect(url.queryParameters['report'], 'timeseries');
      expect(url.queryParameters['format'], 'csv');
      expect(url.queryParameters['from'], '2026-02-01');
      expect(url.queryParameters['to'], '2026-03-02');
      expect(url.queryParameters['metric'], 'orders.new');
      expect(url.queryParameters['granularity'], 'week');
      expect(url.queryParameters['kind'], 'hashtags');
      expect(url.queryParameters['limit'], '25');
    });

    test('blank filters are omitted, and an unfiltered query is the server\'s',
        () {
      final url = analyticsExportUrl(const AnalyticsQuery(), report: 'overview');
      final params = url.queryParameters;
      expect(params.containsKey('from'), isFalse);
      expect(params.containsKey('to'), isFalse);
      expect(params.containsKey('limit'), isFalse);
      // granularity/kind always travel: they are the report's own selection,
      // and dropping one would silently change which report is read.
      expect(params['granularity'], 'day');
      expect(params['kind'], 'posts');
    });

    test('a ready export states its row count and window in the confirmation',
        () {
      final ready = AnalyticsExportReady(
        bytes: Uint8List(0),
        filename: 'analytics-overview_2026-02-01_2026-03-02.csv',
        mimeType: 'text/csv',
        rowCount: 20,
        from: '2026-02-01',
        to: '2026-03-02',
        dataSource: 'rollup',
      );
      expect(ready.summary, contains('20 row(s)'));
      expect(ready.summary, contains('2026-02-01'));
      expect(ready.summary, contains('rollup'));
    });

    test('an unstated row count is not presented as zero', () {
      final ready = AnalyticsExportReady(
        bytes: Uint8List(0),
        filename: 'x.csv',
        mimeType: 'text/csv',
      );
      expect(ready.rowCount, isNull);
      expect(ready.summary, contains('an unstated number of'));
      expect(ready.summary, isNot(contains('0 row(s)')));
    });

    test('the three refusals are three separate outcomes', () {
      expect(const AnalyticsExportCapped('too many rows'), isNot(isA<AnalyticsExportXlsxUnavailable>()));
      expect(const AnalyticsExportXlsxUnavailable('no openpyxl'), isNot(isA<AnalyticsExportCapped>()));
      expect(const AnalyticsExportEmpty(), isNot(isA<AnalyticsExportReady>()));
    });
  });

  group('AnalyticsQuery', () {
    test('identity covers every filter, so a change is a new fetch', () {
      const a = AnalyticsQuery(metric: 'orders.new');
      const b = AnalyticsQuery(metric: 'users.new');
      expect(a, isNot(b));
      expect(a, const AnalyticsQuery(metric: 'orders.new'));
    });

    test('the default window is described without pretending to know it', () {
      expect(
        const AnalyticsQuery().windowLabel,
        contains('Default window'),
      );
      expect(
        const AnalyticsQuery(from: '2026-02-01').windowLabel,
        contains('today'),
      );
    });
  });

  // -------------------------------------------------------------------------
  // Verification: two-person
  // -------------------------------------------------------------------------

  group('verification: a review call applies nothing', () {
    Map<String, dynamic> queuedSubmission() => {
          'id': 'sub-1',
          'verification_type': 'trainer',
          'status': 'under_review',
          'credential_id': 'NASM-1234',
          'reviewed_by': null,
          'reviewed_at': null,
          'pending_approval': {
            'id': 'req-1',
            'status': 'pending',
            'decision': 'approve',
            'required_scope': 'shops.certifications',
            'requested_by_profile': 'Alice',
            'requested_at': '2026-03-01T10:00:00Z',
            'decided_by': null,
            'decided_at': null,
            'decision_note': '',
            'applied_at': null,
          },
        };

    test('a queued decision is waiting, not approved', () {
      final submission =
          VerificationSubmission.fromJson(queuedSubmission());
      expect(submission.status, 'under_review');
      expect(submission.awaitsSecondApprover, isTrue);
      expect(submission.isDecided, isFalse);
      expect(submission.isApproved, isFalse);
      // `reviewed_by` stays empty: the reviewer who raised the request has
      // reviewed nothing.
      expect(submission.reviewedBy, isNull);
    });

    test('the review response is read as queued and says what is still owed',
        () {
      final outcome = verificationReviewQueued({
        ...queuedSubmission(),
        'approval_request': {
          'id': 'req-1',
          'status': 'pending',
          'requested_by_profile': 'Alice',
          'required_scope': 'shops.certifications',
          'created_at': '2026-03-01T10:00:00Z',
        },
      });

      // The load-bearing assertion: the message must not contain a claim that
      // anything was verified.
      expect(outcome.message, contains('has been applied to the applicant'));
      expect(outcome.message, contains('awaiting a second approver'));
      expect(outcome.message, contains('shops.certifications'));
      expect(outcome.message.toLowerCase(), isNot(contains('approved')));
      expect(outcome.approvalRequest?.id, 'req-1');
    });

    test('a pending approval that is also in approval_state agrees with itself',
        () {
      final submission = VerificationSubmission.fromJson({
        ...queuedSubmission(),
        'approval_state': (queuedSubmission()['pending_approval'] as Map),
      });
      expect(submission.approvalState?.isPending, isTrue);
      expect(submission.approvalState?.isApplied, isFalse);
      expect(submission.approvalState?.appliedAt, isNull);
      expect(submission.approvalState?.requestedDecisionLabel, 'approving');
    });
  });

  group('verification: only decide applies, and it is visible when it did not',
      () {
    test('a settled request with an applied_at is reported as applied', () {
      final outcome = VerificationDecisionOutcome.fromJson({
        'id': 'req-1',
        'status': 'approved',
        'decision_note': 'Certificate verified against the register.',
        'decided_by': 'bob@example.com',
        'applied_at': '2026-03-01T12:00:00Z',
        'effect': 'The trainer application was approved.',
      });
      expect(outcome.appliedEffect, isTrue);
    });

    test('a settled request with no applied_at is NOT reported as applied', () {
      // The gap documented in apps/verification/decisions.py: a request settled
      // through the governance approvals endpoint stamps applied_at without
      // applying anything — or is settled without it. Reporting "approved"
      // there would tell a reviewer they had verified somebody.
      final outcome = VerificationDecisionOutcome.fromJson({
        'id': 'req-1',
        'status': 'approved',
        'applied_at': null,
        'effect': 'carried out in the owning app',
      });
      expect(outcome.appliedEffect, isFalse);
    });

    test('the decide response is read and its effect surfaced verbatim', () {
      final result = verificationDecisionApplied({
        'id': 'sub-1',
        'verification_type': 'trainer',
        'status': 'approved',
        'approval': {
          'id': 'req-1',
          'status': 'approved',
          'applied_at': '2026-03-01T12:00:00Z',
          'effect': 'The trainer application was approved.',
        },
      });
      expect(result.message, 'The trainer application was approved.');
      expect(result.submission.isApproved, isTrue);
      expect(result.outcome?.appliedEffect, isTrue);
    });

    test('the queue offers the two actions on exactly the right rows', () {
      final queued = VerificationSubmission.fromJson({
        'id': 'a',
        'status': 'under_review',
        'pending_approval': {'status': 'pending'},
      });
      // A decision is already in flight: no second request, and a Decide
      // button is the only thing that can settle it.
      expect(canRequestVerificationDecision(queued), isFalse);
      expect(canDecideVerification(queued), isTrue);

      final fresh = VerificationSubmission.fromJson({
        'id': 'b',
        'status': 'submitted',
      });
      expect(canRequestVerificationDecision(fresh), isTrue);
      expect(canDecideVerification(fresh), isFalse);

      // A draft has not been submitted, so reviewing it is a category error.
      final draft = VerificationSubmission.fromJson({
        'id': 'c',
        'status': 'draft',
      });
      expect(canRequestVerificationDecision(draft), isFalse);
    });
  });

  group('verification: my applications', () {
    test('a pending application says who owes the answer', () {
      final application = MyApplication.fromJson({
        'id': '1',
        'category': 'practitioner',
        'status': 'under_review',
        'approval_state': {'status': 'pending', 'decision': 'approve'},
      });
      expect(application.isPending, isTrue);
      expect(application.statusLabel, contains('second approver'));
      expect(application.note, isEmpty);
      expect(application.awaitingSecondApprover, isTrue);
    });

    test('a decided application carries the reviewer\'s note', () {
      final application = MyApplication.fromJson({
        'id': '2',
        'category': 'trainer',
        'status': 'rejected',
        // Where `apply_decision` actually writes it: on the approval row.
        'approval_state': {
          'id': 'req-1',
          'status': 'rejected',
          'decision': 'reject',
          'decision_note': 'The credential number does not match the register.',
          'decided_at': '2026-03-02T09:00:00Z',
          'applied_at': '2026-03-02T09:00:00Z',
        },
      });
      expect(application.isDecided, isTrue);
      expect(application.isRejected, isTrue);
      expect(application.note, contains('does not match'));
      expect(application.isRejectedWithoutReason, isFalse);
      expect(application.decidedOn, '2026-03-02T09:00:00Z');
    });

    test('a flat reviewer_note is honoured too', () {
      final application = MyApplication.fromJson({
        'id': '4',
        'category': 'trainer',
        'status': 'rejected',
        'reviewer_note': 'Not on the register.',
      });
      expect(application.note, 'Not on the register.');
      expect(application.isRejectedWithoutReason, isFalse);
    });

    test('a rejection with no note is called out rather than left blank', () {
      final application = MyApplication.fromJson({
        'id': '3',
        'category': 'trainer',
        'status': 'rejected',
      });
      expect(application.isRejectedWithoutReason, isTrue);
    });
  });

  group('verification: list bodies', () {
    test('the three shapes this namespace actually returns all parse', () {
      // cursor-paginated DRF viewset
      expect(
        verificationRows({'next': null, 'previous': null, 'results': [{'id': '1'}]}),
        hasLength(1),
      );
      // {count, results}
      expect(verificationRows({'count': 2, 'results': [{'id': '1'}, {'id': '2'}]}),
          hasLength(2));
      // a bare array
      expect(verificationRows([{'id': '1'}]), hasLength(1));
      // anything else is empty rather than a CastError
      expect(verificationRows(null), isEmpty);
      expect(verificationRows('nonsense'), isEmpty);
      expect(verificationRows({'results': 'nope'}), isEmpty);
    });
  });

  group('category applications', () {
    test('the credential fields required per category are reproduced', () {
      // A trainer application without a credential number is refused at the
      // door server-side; the form applies the same rule locally.
      expect(kCategoryRequiredFields['trainer'], contains('credential_id'));
      expect(kCategoryRequiredFields['trainer'], contains('scope_of_practice'));
      expect(kCategoryRequiredFields['shop_owner'], isNot(contains('issued_date')));
      expect(kCategoryRequiresGym, contains('gym_owner'));
    });

    test('the categories are exactly the ones registration will not grant', () {
      expect(
        kCategoryApplicationChoices.map((c) => c.value).toList(),
        ['trainer', 'practitioner', 'gym_owner', 'shop_owner', 'delivery_partner'],
      );
    });
  });

  group('registration no longer carries a role', () {
    test('the payload has no role key on the wire', () {
      final body = jsonEncode(const RegisterPayload(
        email: 'a@b.com',
        password: 'longenough1',
        dob: '1990-01-01',
        username: 'someone',
        displayName: 'Someone',
        acceptedTerms: true,
        acceptedPrivacy: true,
        acceptedGuidelines: true,
        is16Plus: true,
      ).toJson());

      // A role at sign-up used to write straight onto Profile.role and was
      // then treated as proof by every permission class gated on it alone.
      expect(body.contains('"role"'), isFalse);
      expect(jsonDecode(body) as Map<String, dynamic>, isNot(contains('role')));
    });

    test('the replacement route is the one the server names', () {
      expect(
        kCategoryApplicationPath,
        '/api/v1/verification/category-applications/',
      );
    });
  });
}