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

/// `GET /api/v1/portal/analytics/overview/`.
///
/// **Every KPI declares its own window.** `users.total` is a lifetime gauge
/// and `users.new` is a delta inside the window, and the server labels them
/// "All time" and "Window" on the same page. This screen therefore shows two
/// visibly different tile kinds and prints each tile's own caption — there is
/// no version of [AdminKpiTile] that drops it, because a lifetime number
/// presented without "All time" under it reads as this month's number, which is
/// the exact confusion the endpoint exists to prevent.
///
/// The page window is printed once at the top for the flow tiles and the
/// breakdowns, which is honest, and each gauge states "All time" regardless.
class AdminAnalyticsOverviewScreen extends ConsumerStatefulWidget {
  const AdminAnalyticsOverviewScreen({super.key});

  @override
  ConsumerState<AdminAnalyticsOverviewScreen> createState() =>
      _AdminAnalyticsOverviewScreenState();
}

class _AdminAnalyticsOverviewScreenState
    extends ConsumerState<AdminAnalyticsOverviewScreen> {
  AnalyticsQuery _query = const AnalyticsQuery();

  /// The window in days, or null for the server's own default. Kept as a
  /// nullable int rather than a resolved pair of dates so "server default"
  /// stays distinguishable from "the last 30 days", which happen to coincide
  /// today but are not the same request — a later `DEFAULT_WINDOW_DAYS`
  /// change would silently alter what "Last 30 days" means.
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
        appBar: AppBar(title: const Text('Admin · Analytics')),
        body: const ErrorView(
          message: 'Staff access is required. Platform analytics is not '
              'readable from a personal account.',
        ),
      );
    }

    final overview = ref.watch(analyticsOverviewProvider(_query));

    return Scaffold(
      appBar: AppBar(title: const Text('Admin · Platform overview')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(analyticsOverviewProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AdminPageHeader(
              title: 'Platform overview',
              description: 'Every figure states the window it was measured '
                  'over. A gauge is a running total since launch; a flow is a '
                  'delta inside the window below. They are not comparable.',
              onRefresh: () => ref.invalidate(analyticsOverviewProvider),
              refreshing: overview.isLoading,
            ),
            const SizedBox(height: 14),
            AdminWindowChips(days: _windowDays, onChanged: _setWindow),
            const SizedBox(height: 10),
            ...overview.when(
              loading: () => const [AdminLoadingBlock()],
              error: (e, _) => [
                AdminErrorBanner(
                  message: apiErrorMessage(
                    e,
                    fallback: 'Could not load the platform overview.',
                  ),
                ),
              ],
              data: (report) => _body(report),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _body(AnalyticsOverview report) {
    final kpis = report.parsedKpis;
    final grouped = report.kpisByGroup;

    return [
      _windowStrip(report),
      const SizedBox(height: 14),
      if (kpis.isEmpty)
        const AdminEmptyState(
          icon: Icons.query_stats_outlined,
          title: 'No KPIs in this response.',
          hint: 'The endpoint returned no kpis array for this window. Try the '
              'server default window.',
        )
      else
        for (final entry in grouped.entries) ...[
          _groupHeading(entry.key, entry.value.length),
          const SizedBox(height: 8),
          _kpiGrid(entry.value),
          const SizedBox(height: 16),
        ],
      _breakdowns(report),
      _performanceNotes(report),
      AnalyticsExportBar(
        query: _query,
        // Only the report this screen is drawing. The others are one tap
        // away in the console, and offering them here would export with
        // this page's window and no metric of its own.
        availableReports: const ['overview'],
        defaultReport: 'overview',
        title: 'Export the overview',
      ),
      const SizedBox(height: 32),
    ];
  }

  /// The page's own window, stated once and labelled as *the flow window*.
  Widget _windowStrip(AnalyticsOverview report) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Flow window: ${report.window.displayLabel}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Gauges on this page ignore this window — they count everything up '
            'to ${report.window.toDate.isEmpty ? 'today' : report.window.toDate}. '
            'Generated ${_shortDateTime(report.generatedAt)}.',
            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant, height: 1.35),
          ),
        ],
      ),
    );
  }

  Widget _groupHeading(String group, int count) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      '${group.toUpperCase()} · $count',
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        color: cs.onSurfaceVariant,
      ),
    );
  }

  Widget _kpiGrid(List<AnalyticsKpi> kpis) {
    // Two per row: a tile carries a value, a caption, a source and a note, and
    // one per row leaves the page reading as a list rather than a dashboard.
    const columns = 2;
    const spacing = 8.0;
    final width = (MediaQuery.sizeOf(context).width - 32 - spacing) / columns;
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: [
        for (final kpi in kpis)
          SizedBox(
            width: width,
            child: AdminKpiTile(
              label: kpi.label.isEmpty ? kpi.key : kpi.label,
              value: kpi.formattedValue,
              // The KPI's own window, never the page's.
              windowLabel: '${kpi.windowLabel} · ${kpi.windowRange}',
              isGauge: kpi.isGauge,
              source: kpi.source,
              indexed: kpi.indexed,
              note: kpi.note,
            ),
          ),
      ],
    );
  }

  /// `breakdowns[]` — wallet by type and posts by type today.
  ///
  /// The row shape is chosen per builder, so the columns are derived from the
  /// rows themselves rather than hard-coded. That is also why a new breakdown
  /// appears here without a client change.
  Widget _breakdowns(AnalyticsOverview report) {
    final breakdowns = report.parsedBreakdowns;
    if (breakdowns.isEmpty) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Text(
          'Breakdowns',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        for (final breakdown in breakdowns) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  breakdown.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${breakdown.window.displayLabel} · ${breakdown.basis}',
                  style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                ),
                if (breakdown.note.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    breakdown.note,
                    style: const TextStyle(
                      fontSize: 11,
                      color: BuddyColors.gold,
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                if (breakdown.rows.isEmpty)
                  Text(
                    'No rows in this window.',
                    style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                  )
                else
                  for (final row in breakdown.rows)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Text(
                        breakdown.columns
                            .map((key) =>
                                '$key: ${analyticsTableCell(row[key])}')
                            .join('  ·  '),
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// `performance_notes` — the columns the aggregate reads with no index on
  /// them.
  ///
  /// Shown here, above the export, not filed away in a help page: the tiles
  /// above it include `users.total`, `users.new`, `posts.new`, `orders.new` and
  /// `wallet.*`, every one of which is a sequential scan on a table this app
  /// does not own. An operator reading "142,310 users" should know that number
  /// cost a full scan to produce, in the same glance.
  Widget _performanceNotes(AnalyticsOverview report) {
    final notes = report.parsedPerformanceNotes;
    if (notes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: AdminHintNote(
          text: 'Every figure above reads an indexed column. No unindexed '
              'sources were reported for this response.',
        ),
      );
    }
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BuddyColors.gold.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BuddyColors.gold.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.speed_outlined, size: 16, color: BuddyColors.gold),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Query cost: ${notes.length} figure(s) above read a column '
                  'with no index',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: BuddyColors.gold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'These aggregates are sequential scans today. The numbers are '
            'correct; the cost is not, and the fix is an index in the app that '
            'owns each model — not in this console. The daily rollup table '
            '(see Trends) is the real remedy for the recurring reads.',
            style: TextStyle(fontSize: 11, color: cs.onSurface, height: 1.4),
          ),
          const SizedBox(height: 8),
          for (final note in notes) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Text(
                '${note.source} — ${note.issue}',
                style: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: BuddyColors.gold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 4),
              child: Text(
                'fix (${note.owner}): ${note.suggestedMigration}',
                style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
              ),
            ),
          ],
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

  static String _shortDateTime(String iso) {
    if (iso.isEmpty) return '—';
    return iso.replaceFirst('T', ' ').split('.').first.split('+').first;
  }
}