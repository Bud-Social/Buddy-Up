import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_error.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/platform_analytics.dart';
import '../../../shared/widgets/error_view.dart';
import '../providers/admin_provider.dart';
import '../providers/analytics_provider.dart';
import '../widgets/admin_widgets.dart';
import '../widgets/analytics_widgets.dart';

/// `GET /api/v1/portal/analytics/predictive/`.
///
/// **Observed and inferred are rendered as different things.** The server
/// marks every signal with `observed`, which is false when the value is a ratio
/// of two counted sets rather than a count — "negative feedback share" is not a
/// measurement of anything, it is a quotient, and the fastest way to turn it
/// into a prediction is to print it next to a count in the same weight. So:
/// counted signals sit in the *Observed* block with a solid row and a COUNTED
/// badge, derived signals sit in a separate *Inferred* block with a dashed
/// border and a DERIVED badge, and every derived row states the `basis` — the
/// exact ratio the server computed.
///
/// **The disclaimer is above everything**, in the same weight as a rule rather
/// than a tooltip. It says the endpoint does not forecast, and that claim goes
/// stale the moment the numbers are read as one.
class AdminAnalyticsPredictiveScreen extends ConsumerStatefulWidget {
  const AdminAnalyticsPredictiveScreen({super.key});

  @override
  ConsumerState<AdminAnalyticsPredictiveScreen> createState() =>
      _AdminAnalyticsPredictiveScreenState();
}

class _AdminAnalyticsPredictiveScreenState
    extends ConsumerState<AdminAnalyticsPredictiveScreen> {
  AnalyticsQuery _query = const AnalyticsQuery();
  int? _windowDays;

  void _setWindow(int? days) {
    setState(() {
      _windowDays = days;
      _query = days == null
          ? const AnalyticsQuery()
          : AnalyticsQuery(from: _isoDaysAgo(days), to: _today());
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(isStaffProvider)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin · Signals')),
        body: const ErrorView(
          message: 'Staff access is required. Recommendation signals are not '
              'readable from a personal account.',
        ),
      );
    }

    final report = ref.watch(analyticsPredictiveProvider(_query));

    return Scaffold(
      appBar: AppBar(title: const Text('Admin · Recommendation signals')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(analyticsPredictiveProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const AdminPageHeader(
              title: 'Recommendation signals',
              description: 'Observed feedback and impression counts for the '
                  'window below. Nothing here is a forecast.',
            ),
            const SizedBox(height: 14),
            AdminWindowChips(days: _windowDays, onChanged: _setWindow),
            const SizedBox(height: 12),
            ...report.when(
              loading: () => const [AdminLoadingBlock()],
              error: (e, _) => [
                AdminErrorBanner(
                  message: apiErrorMessage(
                    e,
                    fallback: 'Could not load the recommendation signals.',
                  ),
                ),
              ],
              data: _body,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _body(PredictiveReport report) {
    final signals = report.parsedSignals;
    final observed = signals.where((s) => s.observed).toList();
    final derived = signals.where((s) => s.isDerived).toList();

    return [
      AdminRuleNote(text: report.disclaimerText),
      const SizedBox(height: 14),
      _observedCounts(report),
      const SizedBox(height: 18),
      if (observed.isNotEmpty) ...[
        _blockHeading(
          'Observed',
          'Counted directly in the window. These are measurements.',
          'query_stats',
        ),
        const SizedBox(height: 8),
        for (final signal in observed) _signalCard(signal),
        const SizedBox(height: 18),
      ],
      if (derived.isNotEmpty) ...[
        _blockHeading(
          'Inferred',
          'Ratios of the counts above. Each states the ratio it is, because a '
              'quotient of two counted sets is not a third measurement.',
          'functions',
        ),
        const SizedBox(height: 8),
        for (final signal in derived) _signalCard(signal),
        const SizedBox(height: 18),
      ],
      _feedbackBreakdown(report.observed.recommendationFeedback),
      const SizedBox(height: 16),
      AnalyticsTableBlock(table: report.table),
      AnalyticsExportBar(
        query: _query,
        availableReports: const ['predictive'],
        defaultReport: 'predictive',
        title: 'Export this report',
      ),
      const SizedBox(height: 32),
    ];
  }

  Widget _blockHeading(String title, String blurb, String icon) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(Icons.analytics_outlined, size: 16, color: cs.onSurfaceVariant),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              Text(
                blurb,
                style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant, height: 1.35),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// The counted blocks, verbatim from `observed`.
  Widget _observedCounts(PredictiveReport report) {
    final observed = report.observed;
    final feedback = observed.recommendationFeedback;
    final impressions = observed.recommendationImpressions;
    final jobs = observed.aiJobs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: AdminStatCard(
                label: 'Feedback rows',
                value: '${feedback.total}',
                sub: report.window.displayLabel,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AdminStatCard(
                label: 'Item impressions',
                value: '${impressions.total}',
                sub: 'analytics events',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: AdminStatCard(
                label: 'Served by a model',
                value: impressions.ai == null ? '—' : '${impressions.ai}',
                sub: impressions.ai == null ? 'split unavailable' : 'properties.source = ai',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AdminStatCard(
                label: 'Served by fallback',
                value: impressions.fallback == null ? '—' : '${impressions.fallback}',
                sub: impressions.fallback == null
                    ? 'split unavailable'
                    : 'properties.source = fallback',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: AdminStatCard(
                label: 'Unlabelled impressions',
                value: '${impressions.unlabelled}',
                sub: 'written before properties.source',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AdminStatCard(
                label: 'AI jobs',
                value: jobs.total == null ? '—' : '${jobs.total}',
                sub: jobs.completed == null
                    ? 'ai app unavailable'
                    : '${jobs.completed} completed',
              ),
            ),
          ],
        ),
        if (impressions.ai == null) ...[
          const SizedBox(height: 8),
          const AdminHintNote(
            text: 'The AI/fallback impression split is null, not zero: the '
                'database behind this deployment cannot index into the event '
                'properties JSON, so the server reported the total and left '
                'the split blank rather than guessing.',
          ),
        ],
      ],
    );
  }

  Widget _signalCard(PredictiveSignal signal) {
    final cs = Theme.of(context).colorScheme;
    final derived = signal.isDerived;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        // Dashed for derived, solid for counted. The border carries the same
        // distinction the badge does, so it survives being skimmed.
        border: Border.all(
          color: (derived ? BuddyColors.gold : BuddyColors.green)
              .withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  signal.label.isEmpty ? signal.key : signal.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ),
              AdminProvenanceBadge(observed: signal.observed),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            signal.key,
            style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
          ),
          const SizedBox(height: 8),
          Text(
            _formatSignalValue(signal),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: derived ? BuddyColors.gold : cs.onSurface,
            ),
          ),
          if (signal.basis.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Basis: ${signal.basis}',
              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant, height: 1.35),
            ),
          ],
          if (signal.derivation.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              signal.derivation,
              style: TextStyle(
                fontSize: 10,
                fontStyle: FontStyle.italic,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
          if (signal.note.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.outline.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                signal.note,
                style: TextStyle(fontSize: 11, color: cs.onSurface, height: 1.4),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// The value, formatted by what the signal is.
  ///
  /// A derived signal's value is a ratio between 0 and 1, so it prints as a
  /// percentage; a counted one prints as a count. A null prints as an em dash —
  /// the server leaves `recommendation.impressions.ai` null on a database that
  /// cannot do the JSON key lookup, and "0%" would be a different claim.
  static String _formatSignalValue(PredictiveSignal signal) {
    final value = signal.value;
    if (value == null) return '—';
    if (signal.isDerived) return analyticsPercent(value.toDouble());
    return '$value';
  }

  Widget _feedbackBreakdown(PredictiveFeedbackObserved feedback) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Feedback breakdown',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: cs.onSurface)),
        const SizedBox(height: 2),
        Text(
          feedback.source.isEmpty
              ? 'RecommendationFeedback rows in the window.'
              : 'Source: ${feedback.source}',
          style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        if (feedback.rows.isEmpty)
          Text('No feedback rows in this window.',
              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant))
        else
          for (final row in feedback.rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '${analyticsTableCell(row['feedback'])} — '
                '${analyticsTableCell(row['count'])} '
                '(${analyticsPercent(_share(row))} of all feedback)',
                style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
              ),
            ),
      ],
    );
  }

  static double? _share(Map<String, dynamic> row) {
    final value = row['share'];
    return value is num ? value.toDouble() : null;
  }

  static String _today() => _isoDate(DateTime.now());

  static String _isoDaysAgo(int days) =>
      _isoDate(DateTime.now().subtract(Duration(days: days - 1)));

  static String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}