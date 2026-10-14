import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_error.dart';
import '../../../data/models/platform_analytics.dart';
import '../../../shared/widgets/error_view.dart';
import '../providers/admin_provider.dart';
import '../providers/analytics_provider.dart';
import '../widgets/admin_widgets.dart';
import '../widgets/analytics_widgets.dart';

/// `GET /api/v1/portal/analytics/trending/?kind=…`.
///
/// **Item fields differ per kind**, so the row renderer switches on the kind
/// the server reported rather than assuming one shape: hashtags carry a
/// window-over-window delta, posts carry reaction and comment counts, events
/// carry ticket sales, services carry purchase counts and a rating. All four
/// live in one model because all four come from the same endpoint; which
/// columns to print is decided here.
///
/// **`available: false` is never an empty list.** The `pages` kind answers
/// `{available: false, reason, items: []}` because nothing on any client emits
/// a screen-view event — the second empty list in that response means "we have
/// no page views", which is a completely different claim from "we have no way
/// to know about page views". [AdminUnavailablePanel] prints the server's own
/// `reason` in full instead, so a missing measurement is never reported to an
/// operator as a quiet week.
class AdminAnalyticsTrendingScreen extends ConsumerStatefulWidget {
  const AdminAnalyticsTrendingScreen({super.key});

  @override
  ConsumerState<AdminAnalyticsTrendingScreen> createState() =>
      _AdminAnalyticsTrendingScreenState();
}

class _AdminAnalyticsTrendingScreenState
    extends ConsumerState<AdminAnalyticsTrendingScreen> {
  AnalyticsQuery _query = const AnalyticsQuery(kind: 'posts');
  int? _windowDays;

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
        appBar: AppBar(title: const Text('Admin · Trending')),
        body: const ErrorView(
          message: 'Staff access is required. Trending reports are not '
              'readable from a personal account.',
        ),
      );
    }

    final trending = ref.watch(analyticsTrendingProvider(_query));
    final kind = TrendingKind.fromWire(_query.kind);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin · Trending')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(analyticsTrendingProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AdminPageHeader(
              title: 'Trending · ${kind.label}',
              description: 'Ranked inside the window below. The rank basis is '
                  'printed with the list because "top" means different things '
                  'for posts than for tickets.',
              onRefresh: () => ref.invalidate(analyticsTrendingProvider),
              refreshing: trending.isLoading,
            ),
            const SizedBox(height: 14),
            AdminWindowChips(days: _windowDays, onChanged: _setWindow),
            const SizedBox(height: 10),
            AdminFilterChips(
              value: _query.kind,
              options: kTrendingKindChoices,
              onChanged: (value) =>
                  setState(() => _query = _query.copyWith(kind: value)),
            ),
            const SizedBox(height: 12),
            ...trending.when(
              loading: () => const [AdminLoadingBlock()],
              error: (e, _) => [
                AdminErrorBanner(
                  message: apiErrorMessage(
                    e,
                    fallback: 'Could not load this trending list.',
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

  List<Widget> _body(AnalyticsTrending report) {
    // Checked first, before `items` is looked at at all. An unavailable kind
    // has an empty `items` array by construction, so any ordering that reads
    // items first will render it as "nothing trended".
    if (report.isUnavailable) {
      return [
        AdminUnavailablePanel(
          title: 'No ${report.trendingKind.label.toLowerCase()} trending to show.',
          reason: report.unavailableReason,
          icon: Icons.sensors_off_outlined,
        ),
        const SizedBox(height: 14),
        AdminHintNote(
          text: 'Window asked for: ${report.window.displayLabel}.',
        ),
        AnalyticsExportBar(
          query: _query,
          availableReports: const ['trending'],
          defaultReport: 'trending',
          title: 'Export this list anyway',
        ),
        const SizedBox(height: 32),
      ];
    }

    final items = report.parsedItems;
    return [
      _rankBasis(report),
      const SizedBox(height: 12),
      if (items.isEmpty)
        const AdminEmptyState(
          icon: Icons.inbox_outlined,
          title: 'Nothing trended in this window.',
          hint: 'The server did have data for this kind — the list is '
              'genuinely empty, which is different from having no way to '
              'measure it.',
        )
      else
        for (final item in items)
          _itemCard(item, report.trendingKind),
      const SizedBox(height: 8),
      AnalyticsTableBlock(table: report.table),
      AnalyticsExportBar(
        query: _query,
        availableReports: const ['trending'],
        defaultReport: 'trending',
        title: 'Export this list',
      ),
      const SizedBox(height: 32),
    ];
  }

  Widget _rankBasis(AnalyticsTrending report) {
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
                  'Ranked by',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              AdminStatusBadge(status: report.window.displayLabel, upper: false),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            report.rankBasis.isEmpty
                ? 'The server did not state a rank basis for this kind.'
                : report.rankBasis,
            style: TextStyle(fontSize: 11, color: cs.onSurface, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _itemCard(TrendingItem item, TrendingKind kind) {
    return AdminRowCard(
      title: '#${item.rank} · ${TrendingItemX.titleFor(kind, item)}',
      badges: [AdminStatusBadge(status: kind.wire)],
      subtitle: TrendingItemX.subtitleFor(kind, item),
      meta: _metaFor(kind, item),
      expanded: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final row in _detailRows(kind, item))
            AdminDataRow(label: row.$1, value: row.$2),
        ],
      ),
    );
  }

  String _metaFor(TrendingKind kind, TrendingItem item) => switch (kind) {
        TrendingKind.posts =>
          '${item.reactions} reactions · ${item.comments} comments · '
              '${item.engagement} engagement',
        TrendingKind.hashtags =>
          '${item.postsInWindow} in window · ${item.delta >= 0 ? '+' : ''}'
              '${item.delta} vs previous window',
        TrendingKind.services =>
          '${item.purchasesInWindow} purchase(s) in window',
        TrendingKind.events =>
          '${item.soldTicketsInWindow} sold of ${item.ticketsInWindow} ticket(s) '
              'issued in window',
        TrendingKind.pages => '',
      };

  /// The per-kind detail rows.
  ///
  /// Only the fields that builder actually produced are printed. A field that
  /// defaults to `0` because the key was absent is skipped rather than shown as
  /// a zero, because `review_count` genuinely being null for a training
  /// programme is a fact and `review_count: 0` would not be.
  List<(String, String)> _detailRows(TrendingKind kind, TrendingItem item) {
    switch (kind) {
      case TrendingKind.posts:
        return [
          ('Post ID', item.postId.isEmpty ? '—' : item.postId),
          ('Author', item.authorUsername.isEmpty ? '—' : item.authorUsername),
          if (item.postType.isNotEmpty) ('Type', item.postType),
          ('Created', _shortDateTime(item.createdAt)),
          ('Reactions', '${item.reactions}'),
          ('Comments', '${item.comments}'),
          ('Views (as recorded)', '${item.viewCount}'),
          ('Shares (as recorded)', '${item.shareCount}'),
        ];
      case TrendingKind.services:
        return [
          ('ID', item.id.isEmpty ? '—' : item.id),
          ('Kind', item.kind.replaceAll('_', ' ')),
          ('Creator', item.creator.isEmpty ? '—' : item.creator),
          ('Purchases in window', '${item.purchasesInWindow}'),
          ('Lifetime purchases', '${item.purchaseCountTotal}'),
          if (item.averageRating != null)
            ('Average rating', item.averageRating!.toStringAsFixed(2)),
          if (item.reviewCount != null) ('Reviews', '${item.reviewCount}'),
          ('Published', item.isPublished == null ? '—' : '${item.isPublished}'),
        ];
      case TrendingKind.events:
        return [
          ('ID', item.id.isEmpty ? '—' : item.id),
          if (item.category.isNotEmpty) ('Category', item.category),
          if (item.eventType.isNotEmpty) ('Type', item.eventType),
          ('Starts', _shortDateTime(item.startsAt)),
          if (item.shop.isNotEmpty) ('Shop', item.shop),
          if (item.gym.isNotEmpty) ('Gym', item.gym),
          ('Tickets issued in window', '${item.ticketsInWindow}'),
          ('Sold in window', '${item.soldTicketsInWindow}'),
          ('Attendees (recorded)', '${item.attendeeCount}'),
          ('Published', item.isPublished == null ? '—' : '${item.isPublished}'),
          ('Cancelled', item.isCancelled == null ? '—' : '${item.isCancelled}'),
        ];
      case TrendingKind.hashtags:
        return [
          ('Tag ID', item.tagId.isEmpty ? '—' : item.tagId),
          ('Posts in window', '${item.postsInWindow}'),
          ('Posts in previous window', '${item.postsInPreviousWindow}'),
          ('Delta', '${item.delta >= 0 ? '+' : ''}${item.delta}'),
          (
            '% change',
            item.pctChange == null
                // The server sends null, not zero, when the previous window had
                // no posts — there is no percentage change from nothing.
                ? '— (no posts in the previous window to compare against)'
                : '${item.pctChange! >= 0 ? '+' : ''}${item.pctChange!.toStringAsFixed(1)}%'
          ),
          ('Total posts ever', '${item.totalPostsEver}'),
        ];
      case TrendingKind.pages:
        return const [];
    }
  }

  static String _shortDateTime(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    return iso.replaceFirst('T', ' ').split('.').first.split('+').first;
  }

  static String _today() => _isoDate(DateTime.now());

  static String _isoDaysAgo(int days) =>
      _isoDate(DateTime.now().subtract(Duration(days: days - 1)));

  static String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}