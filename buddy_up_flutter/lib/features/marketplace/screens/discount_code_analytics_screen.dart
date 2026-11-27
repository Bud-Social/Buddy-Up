import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/marketplace.dart';
import '../../../shared/navigation/main_header.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/page_loader.dart';
import '../providers/marketplace_provider.dart';

/// Deep-linkable counterpart to the web discount-code analytics page.
///
/// The management page still keeps its compact analytics preview, while this
/// screen provides the complete fetchable report for links shared from the web
/// client and from creator notifications.
class DiscountCodeAnalyticsScreen extends ConsumerStatefulWidget {
  final String codeId;

  const DiscountCodeAnalyticsScreen({super.key, required this.codeId});

  @override
  ConsumerState<DiscountCodeAnalyticsScreen> createState() =>
      _DiscountCodeAnalyticsScreenState();
}

class _DiscountCodeAnalyticsScreenState
    extends ConsumerState<DiscountCodeAnalyticsScreen> {
  late Future<DiscountAnalytics> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<DiscountAnalytics> _load() async {
    final raw = await ref
        .read(marketplaceRepositoryProvider)
        .getDiscountCodeAnalytics(widget.codeId);
    final payload = raw is Map && raw['data'] is Map
        ? raw['data'] as Map
        : raw as Map;
    return DiscountAnalytics.fromJson(Map<String, dynamic>.from(payload));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(title: 'Code Analytics'),
      body: FutureBuilder<DiscountAnalytics>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const PageLoader();
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const EmptyState(
              icon: LucideIcons.chartNoAxesCombined,
              title: 'Analytics not found',
              subtitle: 'We could not load this discount code report.',
            );
          }
          return _Report(
            analytics: snapshot.data!,
            onRefresh: () async {
              final next = _load();
              setState(() => _future = next);
              await next;
            },
          );
        },
      ),
    );
  }
}

class _Report extends StatelessWidget {
  final DiscountAnalytics analytics;
  final Future<void> Function() onRefresh;

  const _Report({required this.analytics, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final code = analytics.code;
    return RefreshIndicator(
      color: BuddyColors.green,
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  code.code,
                  style: const TextStyle(
                    color: BuddyColors.electric,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
              _StatusBadge(code: code),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.65,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _Metric('Total uses', '${analytics.totalUses}', '${analytics.successfulUses} successful'),
              _Metric('Savings (USD)', '\$${analytics.totalSavingsUsd.toStringAsFixed(2)}', '\$${analytics.avgSavingsPerUser.toStringAsFixed(2)} / user', color: BuddyColors.green),
              _Metric('Unique users', '${analytics.uniqueUsers}', '${analytics.returningUsers} returning'),
              _Metric('Retention rate', '${analytics.retentionRate.toStringAsFixed(1)}%', 'users who used it 2+ times', color: BuddyColors.gold),
            ],
          ),
          const SizedBox(height: 16),
          _Panel(
            title: 'Usage over time',
            child: analytics.usageOverTime.isEmpty
                ? const _NoData()
                : _UsageBars(points: analytics.usageOverTime),
          ),
          const SizedBox(height: 12),
          _Panel(
            title: 'Repeat usage distribution',
            child: analytics.repeatUsageDistribution.isEmpty
                ? const _NoData()
                : _Distribution(points: analytics.repeatUsageDistribution),
          ),
          if (analytics.topUsers.isNotEmpty) ...[
            const SizedBox(height: 12),
            _Panel(
              title: 'Top users',
              child: Column(
                children: [
                  for (var i = 0; i < analytics.topUsers.length; i++)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: BuddyColors.surfaceRaised,
                        child: Text('${i + 1}', style: const TextStyle(fontSize: 11)),
                      ),
                      title: Text('@${analytics.topUsers[i]['user__username'] ?? 'user'}'),
                      trailing: Text('${analytics.topUsers[i]['uses'] ?? 0} uses'),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          _Panel(
            title: 'Code details',
            child: Wrap(
              spacing: 24,
              runSpacing: 14,
              children: [
                _Detail('Type', code.discountType.replaceAll('_', ' ')),
                _Detail('Uses', '${analytics.timesUsed} / ${code.usageLimit == 0 ? '∞' : code.usageLimit}'),
                _Detail('Shares', '${analytics.shareCount}'),
                _Detail('Order value', '\$${analytics.totalOrderValueUsd.toStringAsFixed(2)}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final String hint;
  final Color color;

  const _Metric(this.label, this.value, this.hint, {this.color = BuddyColors.textPrimary});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 11)),
            const SizedBox(height: 5),
            Text(value, style: TextStyle(color: color, fontSize: 21, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(hint, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 9)),
          ]),
        ),
      );
}

class _Panel extends StatelessWidget {
  final String title;
  final Widget child;
  const _Panel({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            child,
          ]),
        ),
      );
}

class _UsageBars extends StatelessWidget {
  final List<Map<String, dynamic>> points;
  const _UsageBars({required this.points});

  @override
  Widget build(BuildContext context) {
    final max = points.fold<double>(
      1,
      (m, p) => (p['count'] as num?)?.toDouble().clamp(m, double.infinity).toDouble() ?? m,
    );
    return SizedBox(
      height: 150,
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        for (final point in points.take(14))
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: FractionallySizedBox(
                heightFactor: (((point['count'] as num?)?.toDouble() ?? 0) / max).clamp(0.03, 1),
                alignment: Alignment.bottomCenter,
                child: DecoratedBox(decoration: BoxDecoration(color: BuddyColors.electric, borderRadius: BorderRadius.circular(4))),
              ),
            ),
          ),
      ]),
    );
  }
}

class _Distribution extends StatelessWidget {
  final List<Map<String, dynamic>> points;
  const _Distribution({required this.points});

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          for (final p in points)
            Chip(label: Text('${p['uses'] ?? 0}x · ${p['users'] ?? 0} users')),
        ],
      );
}

class _Detail extends StatelessWidget {
  final String label;
  final String value;
  const _Detail(this.label, this.value);

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 11)),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ]);
}

class _StatusBadge extends StatelessWidget {
  final DiscountCode code;
  const _StatusBadge({required this.code});

  @override
  Widget build(BuildContext context) {
    final label = code.isExpired ? 'Expired' : (code.isActive ? 'Active' : 'Suspended');
    final color = code.isExpired ? BuddyColors.red : (code.isActive ? BuddyColors.green : BuddyColors.orange);
    return Chip(label: Text(label), side: BorderSide(color: color), labelStyle: TextStyle(color: color, fontSize: 11));
  }
}

class _NoData extends StatelessWidget {
  const _NoData();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: Text('No data yet.', style: TextStyle(color: BuddyColors.textSecondary))),
      );
}
