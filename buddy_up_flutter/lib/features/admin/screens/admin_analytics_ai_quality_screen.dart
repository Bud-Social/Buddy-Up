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

/// `GET /api/v1/portal/analytics/ai-quality/`.
///
/// **Nothing on this screen is called "accuracy".** The server calls the
/// figure `accuracy_proxy` everywhere it appears and ships a `caveats` array
/// saying why: `AIPredictionJob` has no ground-truth column, `correction` is
/// written only when a human overrode an AI output, and the resulting ratio is
/// biased toward what people bother to correct. Calling it accuracy would be a
/// claim the data cannot support, so the label here is the same word the server
/// uses and the caveat is printed above the numbers, not hidden behind an info
/// icon.
///
/// **Nulls stay null.** The server deliberately routes latency percentiles and
/// ratios through helpers that return `None` rather than `0`, because "no jobs
/// ran" must not read as "every job hit the fallback". Every such field prints
/// an em dash here, and `analyticsPercent` / `analyticsMs` refuse to turn a null
/// into a number.
///
/// **Cumulative is cumulative.** `cumulative_cost_usd` is a lifetime figure and
/// is labelled as one; a per-window cost that resets looks like a spend of zero
/// in a quiet week.
class AdminAnalyticsAiQualityScreen extends ConsumerStatefulWidget {
  const AdminAnalyticsAiQualityScreen({super.key});

  @override
  ConsumerState<AdminAnalyticsAiQualityScreen> createState() =>
      _AdminAnalyticsAiQualityScreenState();
}

class _AdminAnalyticsAiQualityScreenState
    extends ConsumerState<AdminAnalyticsAiQualityScreen> {
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
        appBar: AppBar(title: const Text('Admin · AI quality')),
        body: const ErrorView(
          message: 'Staff access is required. AI quality reporting is not '
              'readable from a personal account.',
        ),
      );
    }

    final report = ref.watch(analyticsAiQualityProvider(_query));

    return Scaffold(
      appBar: AppBar(title: const Text('Admin · AI quality')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(analyticsAiQualityProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AdminPageHeader(
              title: 'AI quality and cost',
              description: 'Per-model call, fallback, correction and cost '
                  'figures for the window below, plus the cumulative spend '
                  'since launch.',
              onRefresh: () => ref.invalidate(analyticsAiQualityProvider),
              refreshing: report.isLoading,
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
                    fallback: 'Could not load the AI quality report.',
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

  List<Widget> _body(AiQualityReport report) {
    final cs = Theme.of(context).colorScheme;
    final totals = report.totals;
    final models = report.modelRows;
    final buckets = report.confidenceDistribution.parsedBuckets;
    final bucketPeak = buckets.isEmpty
        ? 0
        : buckets.map((b) => b.count).reduce((a, b) => a > b ? a : b);

    return [
      // The caveat first. It is the reason the tile below is called a proxy, and
      // reading the tiles without it is how "correction rate" becomes "accuracy"
      // in somebody's head.
      if (report.caveats.isNotEmpty)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final caveat in report.caveats)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AdminRuleNote(text: caveat),
              ),
          ],
        )
      else
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: AdminHintNote(
            text: 'accuracy_proxy is a correction rate, not a measured '
                'accuracy: there is no ground-truth column to compare against.',
          ),
        ),
      _windowStrip(report),
      const SizedBox(height: 14),
      Row(
        children: [
          Expanded(
            child: AdminStatCard(
              label: 'Calls in window',
              value: '${totals.calls}',
              sub: report.window.displayLabel,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AdminStatCard(
              label: 'Fallbacks',
              value: '${totals.fallbacks}',
              sub: analyticsPercent(totals.fallbackRate),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: AdminStatCard(
              label: 'Corrections',
              value: '${totals.corrections}',
              sub: 'human overrides',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AdminStatCard(
              label: 'accuracy_proxy',
              value: analyticsPercent(totals.accuracyProxy),
              sub: 'corrections ÷ completed',
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: AdminStatCard(
              label: 'Cost in window',
              value: analyticsMoney(totals.costUsd),
              sub: '${analyticsMoney(totals.costPerCallUsd)} per call',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AdminStatCard(
              label: 'Spend since launch',
              value: analyticsMoney(totals.cumulativeCostUsd),
              sub: '${totals.cumulativeCalls} lifetime calls · '
                  '${analyticsMoney(totals.cumulativeCostPerCallUsd)} each',
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      _latency(report),
      const SizedBox(height: 16),
      _confidence(report.confidenceDistribution, bucketPeak),
      const SizedBox(height: 16),
      _fallbackReasons(report),
      const SizedBox(height: 16),
      Text('By model',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: cs.onSurface)),
      const SizedBox(height: 8),
      if (models.isEmpty)
        const AdminEmptyState(
          icon: Icons.smart_toy_outlined,
          title: 'No AI calls in this window.',
          hint: 'The endpoint answered with an empty model list, which means '
              'nothing ran — not that the numbers were withheld.',
        )
      else
        for (final model in models) _modelCard(model),
      const SizedBox(height: 12),
      AnalyticsTableBlock(table: report.table),
      AnalyticsExportBar(
        query: _query,
        availableReports: const ['ai_quality'],
        defaultReport: 'ai_quality',
        title: 'Export this report',
      ),
      const SizedBox(height: 32),
    ];
  }

  Widget _windowStrip(AiQualityReport report) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
      ),
      child: Text(
        'Window: ${report.window.displayLabel} · ${report.window.range} '
        '(${report.window.days} days, ${report.window.timezone})',
        style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
      ),
    );
  }

  Widget _latency(AiQualityReport report) {
    final latency = report.latency;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Latency',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              ),
              AdminStatusBadge(
                status: report.latencyIsSampled
                    ? 'sampled over ${latency.sampleLimit} rows'
                    : 'all ${latency.samples} rows',
                upper: false,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: AdminStatCard(
                  label: 'p50',
                  value: analyticsMs(latency.p50),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AdminStatCard(
                  label: 'p95',
                  value: analyticsMs(latency.p95),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: AdminStatCard(
                  label: 'min',
                  value: analyticsMs(latency.min),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AdminStatCard(
                  label: 'max',
                  value: analyticsMs(latency.max),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // `sampled: true` is the server's "the percentiles came from a
          // truncated read". Saying so is the difference between a percentile
          // and an estimate, and the cost figures beside it are exact either way.
          if (report.latencyIsSampled)
            const AdminHintNote(
              text: 'Percentiles are computed from the first 20,000 rows in '
                  'the window, so they are an estimate. Fallback, correction '
                  'and cost figures are exact for every row.',
            )
          else if (latency.samples == 0)
            const AdminHintNote(
              text: 'No job in this window recorded a latency. These are not '
                  'zero-millisecond calls — there were none.',
            ),
        ],
      ),
    );
  }

  /// The confidence histogram, as bars in a table for the same reason as the
  /// series: no chart package, and the numbers are what matter.
  Widget _confidence(AiConfidenceDistribution distribution, int peak) {
    final cs = Theme.of(context).colorScheme;
    final buckets = distribution.parsedBuckets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('Confidence distribution',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
            Text(
              '${distribution.withConfidence} job(s) recorded a confidence',
              style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (buckets.isEmpty)
          Text('No confidence values in this window.',
              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant))
        else
          for (final bucket in buckets)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 76,
                    child: Text(bucket.bucket,
                        style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                  ),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Container(
                          height: 12,
                          decoration: BoxDecoration(
                            color: cs.outline.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: peak == 0
                              ? 0
                              : (bucket.count / peak).clamp(0.0, 1.0),
                          child: Container(
                            height: 12,
                            decoration: BoxDecoration(
                              color: BuddyColors.green.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '${bucket.count}',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 12, color: cs.onSurface),
                    ),
                  ),
                ],
              ),
            ),
      ],
    );
  }

  Widget _fallbackReasons(AiQualityReport report) {
    final cs = Theme.of(context).colorScheme;
    final reasons = report.reasons;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Why the fallback ran',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: cs.onSurface)),
        const SizedBox(height: 8),
        if (reasons.isEmpty)
          Text(
            report.totals.fallbacks == 0
                ? 'No fallback was used in this window.'
                : 'Fallbacks were used but no reason was recorded on them.',
            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
          )
        else
          for (final reason in reasons)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '${reason.reason} — ${reason.count}',
                style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
              ),
            ),
      ],
    );
  }

  Widget _modelCard(AiModelUsage model) {
    return AdminRowCard(
      title: model.model.isEmpty ? model.task : model.model,
      badges: [
        if (model.modelVersion.isNotEmpty)
          AdminStatusBadge(status: model.modelVersion, upper: false),
      ],
      subtitle: model.task.isEmpty ? null : model.task,
      meta: '${model.calls} calls · ${analyticsPercent(model.successRate)} completed '
          '· ${analyticsMoney(model.costUsd)}',
      expanded: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminDataRow(label: 'Calls', value: '${model.calls}'),
          AdminDataRow(label: 'Completed', value: '${model.completed}'),
          AdminDataRow(label: 'Failed', value: '${model.failed}'),
          AdminDataRow(label: 'Success rate', value: analyticsPercent(model.successRate)),
          AdminDataRow(label: 'Fallbacks', value: '${model.fallbacks}'),
          AdminDataRow(label: 'Fallback rate', value: analyticsPercent(model.fallbackRate)),
          AdminDataRow(label: 'Corrections', value: '${model.corrections}'),
          AdminDataRow(
            label: 'accuracy_proxy',
            value: analyticsPercent(model.accuracyProxy),
          ),
          AdminDataRow(
            label: 'Mean confidence',
            value: model.meanConfidence == null
                ? '—'
                : model.meanConfidence!.toStringAsFixed(3),
          ),
          AdminDataRow(label: 'Cost', value: analyticsMoney(model.costUsd)),
          AdminDataRow(
            label: 'Cost per call',
            value: analyticsMoney(model.costPerCallUsd),
          ),
        ],
      ),
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