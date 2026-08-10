import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/page_loader.dart';
import '../../../shared/widgets/error_view.dart';
import '../providers/analytics_provider.dart';
import 'overview_tab.dart';
import 'workouts_tab.dart';
import 'activity_tab.dart';
import 'meals_tab.dart';
import 'body_tab.dart';
import 'report_tab.dart';

const List<({String key, String label})> _periods = [
  (key: 'week', label: 'Week'),
  (key: 'month', label: 'Month'),
  (key: 'quarter', label: 'Quarter'),
  (key: 'year', label: 'Year'),
  (key: 'all', label: 'All Time'),
];

const List<({String key, String label, IconData icon})> _tabs = [
  (key: 'overview', label: 'Overview', icon: Icons.dashboard_outlined),
  (key: 'workouts', label: 'Workouts', icon: Icons.fitness_center),
  (key: 'activity', label: 'Activity', icon: Icons.directions_run),
  (key: 'meals', label: 'Nutrition', icon: Icons.restaurant),
  (key: 'body', label: 'Body', icon: Icons.monitor_weight_outlined),
  (key: 'report', label: 'Report', icon: Icons.bar_chart),
];

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    Future.microtask(() => ref.read(analyticsSummaryProvider.notifier).load());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(analyticsSummaryProvider);
    final period = ref.watch(analyticsPeriodProvider);

    return Scaffold(
      backgroundColor: BuddyColors.black,
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          PopupMenuButton<String>(
            color: BuddyColors.surface,
            icon: const Icon(Icons.date_range),
            onSelected: (p) =>
                ref.read(analyticsSummaryProvider.notifier).setPeriod(p),
            itemBuilder: (_) => [
              for (final p in _periods)
                PopupMenuItem(
                  value: p.key,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        p.label,
                        style: const TextStyle(color: BuddyColors.textPrimary),
                      ),
                      if (p.key == period)
                        const Icon(
                          Icons.check,
                          size: 18,
                          color: BuddyColors.green,
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: BuddyColors.green,
          labelColor: BuddyColors.green,
          unselectedLabelColor: BuddyColors.textSecondary,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          tabs: [
            for (final t in _tabs)
              Tab(
                height: 48,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(t.icon, size: 16),
                    const SizedBox(width: 6),
                    Text(t.label),
                  ],
                ),
              ),
          ],
        ),
      ),
      body: state.isLoading
          ? const PageLoader()
          : state.error != null && state.summary == null
          ? ErrorView(
              message: state.error!,
              onRetry: () =>
                  ref.read(analyticsSummaryProvider.notifier).refresh(),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                OverviewTab(summary: state.summary),
                WorkoutsTab(summary: state.summary?.workouts),
                ActivityTab(summary: state.summary?.activity),
                MealsTab(summary: state.summary?.nutrition),
                BodyTab(summary: state.summary?.body),
                ReportTab(period: period),
              ],
            ),
    );
  }
}
