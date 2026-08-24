import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/analytics.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../providers/analytics_provider.dart';
import '../utils/analytics_format.dart';
import '../widgets/analytics_widgets.dart';

class OverviewTab extends ConsumerWidget {
  final AnalyticsSummaryData? summary;

  const OverviewTab({super.key, this.summary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = summary;
    if (s == null) {
      return const EmptyState(icon: Icons.insights, title: 'No analytics yet');
    }

    final distance = s.activity.totalDistanceKm;
    final workoutCal = s.workouts.totalCaloriesBurned;
    final mealCal = s.nutrition.totalCalories;
    final activeCal = s.activity.totalCaloriesBurned;
    final weight = s.body.latestWeightKg;

    return RefreshIndicator(
      onRefresh: () => ref.read(analyticsSummaryProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              _userCard(s.user, context),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: 'Streak',
                  value: '${s.user.streakDays} days',
                  icon: Icons.whatshot,
                  accent: BuddyColors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              StatCard(
                label: 'Distance',
                value: '${formatNumber(distance, decimals: 1)} km',
                icon: Icons.route,
              ),
              StatCard(
                label: 'Workouts',
                value: '${s.workouts.count}',
                icon: Icons.fitness_center,
                accent: BuddyColors.gold,
              ),
              StatCard(
                label: 'Calories Logged',
                value: formatNumber(mealCal),
                icon: Icons.local_fire_department,
                accent: BuddyColors.red,
              ),
              StatCard(
                label: 'Weight',
                value: weight != null
                    ? '${formatNumber(weight, decimals: 1)} kg'
                    : '—',
                icon: Icons.monitor_weight_outlined,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SectionHeader(
            title: 'Macros',
            icon: Icons.pie_chart_outline,
            trailing: Text(
              '${formatNumber(s.nutrition.totalCalories)} kcal',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: Column(
              children: [
                MacroBar(
                  label: 'Protein',
                  value: s.nutrition.totalProteinG,
                  max: 120,
                  color: BuddyColors.green,
                ),
                const SizedBox(height: 12),
                MacroBar(
                  label: 'Carbs',
                  value: s.nutrition.totalCarbsG,
                  max: 180,
                  color: BuddyColors.gold,
                ),
                const SizedBox(height: 12),
                MacroBar(
                  label: 'Fat',
                  value: s.nutrition.totalFatG,
                  max: 70,
                  color: BuddyColors.red,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(
            title: 'Also this period',
            icon: Icons.more_horiz,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Active Calories',
                  value: formatNumber(activeCal),
                  icon: Icons.bolt,
                  accent: BuddyColors.gold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: 'Time Active',
                  value: formatDuration(s.activity.totalDurationSeconds),
                  icon: Icons.timer_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Workout Burn',
                  value: formatNumber(workoutCal),
                  icon: Icons.local_fire_department,
                  accent: BuddyColors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: 'Spent',
                  value: '${s.spending.totalArtifactsSpent}',
                  icon: Icons.paid_outlined,
                  accent: BuddyColors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Lives Joined',
                  value: '${s.lives.joinedCount}',
                  icon: Icons.videocam_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: 'Programmes',
                  value: '${s.programmes.programmesPurchased}',
                  icon: Icons.school_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _userCard(AnalyticsUserInfo user, BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            ClipOval(
              child: SizedBox(
                width: 44,
                height: 44,
                child: user.avatarUrl.isNotEmpty
                    ? Image.network(
                        user.avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.person,
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                      )
                    : Icon(
                        Icons.person,
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName.isEmpty ? user.username : user.displayName,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Your progress',
                    style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
