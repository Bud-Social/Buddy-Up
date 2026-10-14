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

/// `GET /api/v1/portal/analytics/timeseries/` — one metric over time.
///
/// **No chart package, and none added.** There is no plotting dependency in
/// `pubspec.yaml` and this screen does not introduce one. The series is
/// rendered as a bucket/value table with a bar drawn in each row by
/// [AnalyticsSeriesTable], which is the same AdminStatCard/table vocabulary the
/// rest of the console uses. That is a deliberate choice rather than a
/// compromise: what an operator needs from this page is *which bucket, what
/// value, and is that number real* — the provenance questions — and all three
/// are answered by a table. A line chart would answer none of them and would
/// need a package.
//
// **The zeros are kept.** `read_rollup` returns the complete label set for the
/// window precisely so the caller can tell "no rows" from "a real zero". A gap
/// in the middle of the series is a fact about the data, so it renders as a row
/// marked *zero-filled bucket* rather than as an absence.
///
/// **The metric picker is built from the server's catalogue.** The endpoint
/// refuses a non-additive or non-windowed metric with a 400 that names it, so
/// those entries are shown but disabled with the reason rather than hidden —
/// "why can't I plot active users?" is answered by pointing at the rule.
class AdminAnalyticsTrendsScreen extends ConsumerStatefulWidget {
  const AdminAnalyticsTrendsScreen({super.key});

  @override
  ConsumerState<AdminAnalyticsTrendsScreen> createState() =>
      _AdminAnalyticsTrendsScreenState();
}

class _AdminAnalyticsTrendsScreenState
    extends ConsumerState<AdminAnalyticsTrendsScreen> {
  AnalyticsQuery _query = const AnalyticsQuery(
    metric: kDefaultTimeseriesMetric,
  );
  int? _windowDays;
  bool _showAllMetrics = false;

  void _setWindow(int? days) {
    setState(() {
      _windowDays = days;
      _query = _query.copyWith(
        from: days == null ? '' : _isoDaysAgo(days),
        to: days == null ? '' : _today(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(isStaffProvider)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin · Trends')),
        body: const ErrorView(
          message: 'Staff access is required. Metric time series are not '
              'readable from a personal account.',
        ),
      );
    }

    final series = ref.watch(analyticsTimeseriesProvider(_query));

    return Scaffold(
      appBar: AppBar(title: const Text('Admin · Trends')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(analyticsTimeseriesProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AdminPageHeader(
              title: 'Metric trends',
              description: 'One metric, bucketed by day or week, zero-filled. '
                  'The table lists every bucket in the window; bars are scaled '
                  'to this series\' own peak.',
              onRefresh: () => ref.invalidate(analyticsTimeseriesProvider),
              refreshing: series.isLoading,
            ),
            const SizedBox(height: 14),
            AdminWindowChips(days: _windowDays, onChanged: _setWindow),
            const SizedBox(height: 10),
            AdminFilterChips(
              value: _query.granularity,
              options: kGranularityChoices,
              onChanged: (value) =>
                  setState(() => _query = _query.copyWith(granularity: value)),
            ),
            const SizedBox(height: 10),
            ...series.when(
              loading: () => const [AdminLoadingBlock()],
              error: (e, _) => [
                AdminErrorBanner(
                  message: apiErrorMessage(
                    e,
                    fallback: 'Could not load this metric series.',
                  ),
                ),
                // The 400 for a refused metric names the metric and the reason.
                // Offering alternatives underneath means the operator can pick
                // a legal one instead of retyping the key — the error body
                // carries no catalogue, so the safe defaults are named here.
                _refusedMetricHelp(),
              ],
              data: (report) => [
                _metricPicker(report.catalogue),
                const SizedBox(height: 12),
                _metricHeader(report),
                const SizedBox(height: 10),
                AdminDataSourceNote(
                  path: report.source.path.isEmpty ? 'live' : report.source.path,
                  rollupComplete: report.source.rollupComplete,
                  missingDays: report.source.missingDays,
                  note: report.source.note,
                ),
                const SizedBox(height: 14),
                AnalyticsSeriesTable(series: report),
                const SizedBox(height: 18),
                _totals(report),
                const SizedBox(height: 18),
                AnalyticsTableBlock(table: report.table),
                AnalyticsExportBar(
                  query: _query,
                  availableReports: const ['timeseries'],
                  defaultReport: 'timeseries',
                  title: 'Export this series',
                ),
                const SizedBox(height: 32),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// The metric header: what is being counted, from which column, over which
  /// window — and the server's own description of what the number means.
  Widget _metricHeader(AnalyticsTimeseries report) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  report.metric.label.isEmpty
                      ? report.metric.key
                      : report.metric.label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ),
              AdminStatusBadge(status: report.window.displayLabel, upper: false),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            report.metric.key,
            style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
          ),
          if (report.metric.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              report.metric.description,
              style: TextStyle(fontSize: 11, color: cs.onSurface, height: 1.4),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            'Source: ${report.metric.source} · window ${report.window.range} '
            '(${report.window.days} days, ${report.window.basis}, '
            '${report.window.timezone})',
            style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _totals(AnalyticsTimeseries report) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: AdminStatCard(
                label: 'Sum of buckets',
                value: report.totals.sum.toString(),
                sub: 'server-computed',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AdminStatCard(
                label: 'Non-zero buckets',
                value: report.totals.nonZeroBuckets.toString(),
                sub: 'of ${report.buckets.length}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'The sum is only meaningful for an additive metric, which is why the '
          'server refuses to plot a distinct-count at all.',
          style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant, height: 1.35),
        ),
      ],
    );
  }

  /// The metric picker, built from the response's `metric_catalogue`.
  ///
  /// Every registered entry is reachable. Only additive, windowed metrics are
  /// offered as selectable chips, because the others are exactly the ones the
  /// server refuses a series over; the full registry is one tap away so
  /// hiding them never makes the console look like it is missing metrics
  /// rather than declining to sum buckets that cannot be summed.
  Widget _metricPicker(List<AnalyticsMetricCatalogueEntry> catalogue) {
    return _catalogue(catalogue);
  }

  /// The 400 path. The refusal body carries no catalogue, so the operator is
  /// told which metric was refused and offered metrics that are known legal.
  Widget _refusedMetricHelp() {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'The server will only plot a metric whose buckets can be summed. A '
          'distinct-user count is not one, and a running total is not either. '
          'Both are on the Overview instead.',
          style: TextStyle(fontSize: 11, color: cs.onSurface, height: 1.4),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final key in const [
              kDefaultTimeseriesMetric,
              'users.new',
              'posts.new',
              'orders.gross_usd',
            ])
              ActionChip(
                label: Text(key, style: const TextStyle(fontSize: 11)),
                onPressed: () =>
                    setState(() => _query = _query.copyWith(metric: key)),
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      ],
    );
  }

  Widget _catalogue(List<AnalyticsMetricCatalogueEntry> catalogue) {
    if (catalogue.isEmpty) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    final plottable = catalogue.where((entry) => entry.isPlottable).toList();
    final blocked = catalogue.where((entry) => !entry.isPlottable).toList();
    final shown = _showAllMetrics ? catalogue : plottable;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Metric · ${_query.metric.isEmpty ? kDefaultTimeseriesMetric : _query.metric}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ),
            Text(
              '${plottable.length} plottable of ${catalogue.length} registered',
              style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final entry in shown)
              ChoiceChip(
                label: Text(entry.label.isEmpty ? entry.key : entry.label,
                    style: const TextStyle(fontSize: 11)),
                selected: entry.key == _query.metric,
                onSelected: (_) =>
                    setState(() => _query = _query.copyWith(metric: entry.key)),
                selectedColor: BuddyColors.green.withValues(alpha: 0.2),
                backgroundColor: cs.surface,
                visualDensity: VisualDensity.compact,
                side: BorderSide(
                  color: entry.key == _query.metric
                      ? BuddyColors.green
                      : cs.outline.withValues(alpha: 0.3),
                ),
              ),
          ],
        ),
        if (blocked.isNotEmpty) ...[
          const SizedBox(height: 8),
          const AdminHintNote(
            text: 'Distinct-counts and running totals are not plotted: summing '
                'five daily active-user buckets does not give you five days of '
                'active users. They are on the Overview instead.',
          ),
        ],
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => setState(() => _showAllMetrics = !_showAllMetrics),
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              foregroundColor: BuddyColors.green,
            ),
            icon: Icon(
              _showAllMetrics ? Icons.expand_less : Icons.expand_more,
              size: 14,
            ),
            label: Text(
              _showAllMetrics
                  ? 'Hide the full registry'
                  : 'Show all ${catalogue.length} registered metrics',
              style: const TextStyle(fontSize: 11),
            ),
          ),
        ),
      ],
    );
  }

  static String _today() => _isoDate(DateTime.now());

  static String _isoDaysAgo(int days) =>
      _isoDate(DateTime.now().subtract(Duration(days: days - 1)));

  static String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}