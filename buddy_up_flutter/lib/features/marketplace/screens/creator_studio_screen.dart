import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/marketplace_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/marketplace.dart';
import '../../../shared/widgets/page_loader.dart';
import 'my_shops_screen.dart';
import 'creator_orders_screen.dart';
import 'creator_services_screen.dart';
import 'creator_payouts_screen.dart';

class CreatorStudioScreen extends ConsumerStatefulWidget {
  const CreatorStudioScreen({super.key});

  @override
  ConsumerState<CreatorStudioScreen> createState() => _CreatorStudioScreenState();
}

class _CreatorStudioScreenState extends ConsumerState<CreatorStudioScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(creatorAnalyticsProvider);
    final servicesAsync = ref.watch(creatorServicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Creator Studio'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Analytics', icon: Icon(Icons.analytics, size: 18)),
            Tab(text: 'Orders', icon: Icon(Icons.shopping_bag, size: 18)),
            Tab(text: 'Services', icon: Icon(Icons.inventory_2, size: 18)),
            Tab(text: 'Payouts', icon: Icon(Icons.payments, size: 18)),
            Tab(text: 'My Shops', icon: Icon(Icons.storefront, size: 18)),
            Tab(text: 'Discounts', icon: Icon(Icons.discount, size: 18)),
          ],
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAnalyticsTab(analyticsAsync),
          const CreatorOrdersScreen(),
          const CreatorServicesScreen(),
          const CreatorPayoutsScreen(),
          const MyShopsScreen(),
          _buildDiscountsTab(servicesAsync),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(AsyncValue<CreatorAnalytics> analyticsAsync) {
    return analyticsAsync.when(
      data: (analytics) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _statCards(analytics),
            const SizedBox(height: 16),
            if (analytics.categorySales.isNotEmpty) _categorySalesCard(analytics),
            if (analytics.topServices.isNotEmpty) _topServicesCard(analytics),
            if (analytics.revenueOverTime.isNotEmpty) _revenueOverTimeCard(analytics),
          ],
        ),
      ),
      loading: () => const PageLoader(),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _statCards(CreatorAnalytics analytics) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Total Revenue',
            value: '\$${analytics.totalRevenueUsd.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
            subtitle: '${analytics.totalSales} sales',
            color: BuddyColors.green,
            icon: Icons.attach_money,
          ),
        ),
        const SizedBox(width: 12),
          Expanded(
          child: _StatCard(
            label: 'Total Views',
            value: analytics.totalViews.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},'),
            subtitle: 'Impressions',
            color: const Color(0xFF60A5FA),
            icon: Icons.visibility,
          ),
        ),
      ],
    );
  }

  Widget _categorySalesCard(CreatorAnalytics analytics) {
    return Card(
      color: BuddyColors.surface,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Category Sales', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: BuddyColors.textSecondary)),
            const SizedBox(height: 12),
            ...analytics.categorySales.entries.map((entry) {
              final count = entry.value;
              final pct = analytics.totalSales > 0 ? (count / analytics.totalSales * 100).round() : 0;
              final colorMap = {
                'meal_plan': BuddyColors.green,
                'programme': const Color(0xFF60A5FA),
                'event': const Color(0xFFFBBF24),
              };
              final color = colorMap[entry.key] ?? const Color(0xFF60A5FA);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(_formatCategory(entry.key), style: const TextStyle(fontSize: 12, color: BuddyColors.textSecondary)),
                        const Spacer(),
                        Text('$count sales ($pct%)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: pct / 100,
                      backgroundColor: BuddyColors.surfaceRaised,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _topServicesCard(CreatorAnalytics analytics) {
    return Card(
      color: BuddyColors.surface,
      margin: const EdgeInsets.only(top: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Top Services', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: BuddyColors.textSecondary)),
            const SizedBox(height: 12),
            ...analytics.topServices.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  _typeBadge(s.type),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(s.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                  ),
                  Text('${s.sales} sales', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: BuddyColors.textSecondary)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _revenueOverTimeCard(CreatorAnalytics analytics) {
    return Card(
      color: BuddyColors.surface,
      margin: const EdgeInsets.only(top: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Revenue Over Time', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: BuddyColors.textSecondary)),
            const SizedBox(height: 12),
            ...analytics.revenueOverTime.map((r) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(r.month, style: const TextStyle(fontSize: 12, color: BuddyColors.textSecondary)),
                  Text('\$${r.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _typeBadge(String type) {
    final colors = {
      'meal_plan': BuddyColors.green,
      'programme': const Color(0xFF60A5FA),
      'event': const Color(0xFFFBBF24),
    };
    final color = colors[type] ?? const Color(0xFF60A5FA);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
      child: Text(_formatCategory(type), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }

  String _formatCategory(String key) {
    switch (key) {
      case 'meal_plan': return 'Meal Plan';
      case 'programme': return 'Programme';
      case 'event': return 'Event';
      default: return key.replaceAll('_', ' ').split(' ').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
    }
  }

  Widget _buildDiscountsTab(AsyncValue<CreatorServices> servicesAsync) {
    return servicesAsync.when(
      data: (services) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.discount, size: 20, color: BuddyColors.green),
                const SizedBox(width: 8),
                Text('Discount Codes (${services.discountCodes.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => context.push('/marketplace/creator/discount-codes'),
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text('Manage'),
                ),
              ],
            ),
            if (services.discountCodes.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('No discount codes created.', style: TextStyle(color: BuddyColors.textSecondary)),
              )
            else
              ...services.discountCodes.map((c) => _discountCodeTile(c)),
          ],
        ),
      ),
      loading: () => const PageLoader(),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _discountCodeTile(DiscountCode c) {
    return Card(
      color: BuddyColors.surface,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(c.code, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', fontSize: 14)),
        subtitle: Text(
          c.discountType == 'percentage' ? '${c.discountPct}% off' : 'Fixed',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${c.timesUsed}/${c.usageLimit == 0 ? '∞' : c.usageLimit.toString()}',
                style: const TextStyle(fontSize: 12, color: BuddyColors.textSecondary)),
            IconButton(
              icon: Icon(c.isActive ? Icons.pause_circle_outline : Icons.play_circle_outline,
                  size: 22, color: c.isActive ? Colors.orange : BuddyColors.green),
              tooltip: c.isActive ? 'Suspend' : 'Reactivate',
              onPressed: () => _toggleDiscount(c),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleDiscount(DiscountCode c) async {
    final action = c.isActive ? 'suspend' : 'reactivate';
    try {
      await ref.read(marketplaceRepositoryProvider).patchDiscountCode(c.id, {'action': action});
      ref.invalidate(creatorServicesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(c.isActive ? 'Code suspended.' : 'Code reactivated.'),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withValues(alpha: 0.15),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: color.withValues(alpha: 0.3))),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 6),
                Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 10, color: color)),
          ],
        ),
      ),
    );
  }
}