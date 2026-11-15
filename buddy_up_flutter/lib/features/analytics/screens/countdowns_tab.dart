import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/analytics.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/analytics_provider.dart';
import '../utils/analytics_format.dart';
import '../widgets/analytics_widgets.dart';

/// Countdown analytics — the streaks, the cadence and the resets.
///
/// The tab is read-only by design: the shortcut to manage countdowns lives
/// at the bottom so the analytics stay an honest report, not a dashboard of
/// buttons.
class CountdownsTab extends ConsumerWidget {
  final CountdownSummary? summary;

  const CountdownsTab({super.key, this.summary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = summary;
    if (s == null || s.count == 0) {
      return const EmptyState(
        icon: Icons.timer_outlined,
        title: 'No countdowns yet',
        subtitle: 'Start a countdown and your streaks will show up here.',
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(analyticsSummaryProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionHeader(
            title: 'Countdowns',
            icon: Icons.timer_outlined,
            trailing: TextButton.icon(
              onPressed: () => GoRouter.of(context).push('/countdowns'),
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text('Manage'),
            ),
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: [
              StatCard(
                label: 'Active',
                value: '${s.activeCount} / ${s.count}',
                icon: Icons.local_fire_department_outlined,
              ),
              StatCard(
                label: 'Check-ins',
                value: '${s.totalCheckins}',
                icon: Icons.how_to_reg,
              ),
              StatCard(
                label: 'Resets',
                value: '${s.totalResets}',
                icon: Icons.restart_alt,
                accent: BuddyColors.gold,
              ),
              StatCard(
                label: 'Completions',
                value: '${s.totalCompletions}',
                icon: Icons.check_circle_outline,
              ),
            ],
          ),
          const SizedBox(height: 18),
          const SectionHeader(
            title: 'Streaks',
            icon: Icons.trending_up,
          ),
          const SizedBox(height: 10),
          _StreakCard(
            label: 'Current momentum',
            value: formatNumber(s.currentStreakUnits, decimals: 1),
            hint: 'sum of all active streaks',
          ),
          const SizedBox(height: 8),
          _StreakCard(
            label: 'Longest ever',
            value: formatNumber(s.longestStreakUnits, decimals: 1),
            hint: 'best run across every countdown',
          ),
          if (s.byCountdown.isNotEmpty) ...[
            const SizedBox(height: 18),
            const SectionHeader(
              title: 'Per countdown',
              icon: Icons.list_alt_outlined,
            ),
            const SizedBox(height: 10),
            for (final c in s.byCountdown) _CountdownCard(entry: c),
          ],
          if (s.recentEvents.isNotEmpty) ...[
            const SizedBox(height: 18),
            const SectionHeader(
              title: 'Recent events',
              icon: Icons.history,
            ),
            const SizedBox(height: 10),
            for (final e in s.recentEvents.take(10))
              _EventRow(event: e),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final String label;
  final String value;
  final String hint;

  const _StreakCard({required this.label, required this.value, required this.hint});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: BuddyColors.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.bolt, color: BuddyColors.gold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            hint,
            style: TextStyle(
              color: cs.onSurface.withValues(alpha: 0.45),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _CountdownCard extends StatelessWidget {
  final CountdownEntry entry;

  const _CountdownCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final maxValue = entry.longestRunUnits > 0
        ? entry.longestRunUnits
        : entry.elapsedUnits.toDouble();
    final ratio = maxValue > 0 ? (entry.elapsedUnits / maxValue).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.reason.isEmpty ? 'Untitled countdown' : entry.reason,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${formatNumber(entry.elapsedUnits.toDouble(), decimals: 0)} / ${formatNumber(entry.longestRunUnits, decimals: 1)}',
                style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.6),
                  fontSize: 11,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 8,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: ratio,
                child: const DecoratedBox(
                  decoration: BoxDecoration(color: BuddyColors.green),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${entry.checkins} check-ins · ${entry.resets} resets',
            style: TextStyle(
              color: cs.onSurface.withValues(alpha: 0.55),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  final CountdownEventEntry event;

  const _EventRow({required this.event});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final icon = switch (event.eventType) {
      'checkin' => Icons.check_circle_outline,
      'auto_advance' => Icons.trending_up,
      'reset' => Icons.restart_alt,
      'complete' => Icons.celebration_outlined,
      _ => Icons.bolt,
    };
    final color = switch (event.eventType) {
      'reset' => BuddyColors.gold,
      'complete' => BuddyColors.gold,
      _ => BuddyColors.green,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, size: 13, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _labelFor(event.eventType),
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            _relativeTime(event.occurredAt),
            style: TextStyle(
              color: cs.onSurface.withValues(alpha: 0.45),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  String _labelFor(String? type) {
    return switch (type) {
      'checkin' => 'Checked in',
      'auto_advance' => 'Advanced',
      'reset' => 'Reset',
      'complete' => 'Completed',
      _ => 'Event',
    };
  }

  String _relativeTime(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
