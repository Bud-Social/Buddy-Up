import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_error.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../providers/schedule_provider.dart';

/// Everything with a date, in one place.
///
/// Bookings and gym enrolments shared no surface: bookings lived behind
/// `/sessions`, gym slots behind each gym. This is the "what am I doing this
/// week" answer, with owned programmes and meal plans kept as an ongoing
/// section because a six-week plan has no single appointment.
class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedule = ref.watch(scheduleProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      body: schedule.when(
        loading: () => const ShimmerList(),
        error: (e, _) => ErrorView(
          message: apiErrorMessage(e, fallback: 'Could not load your schedule.'),
          onRetry: () => ref.invalidate(scheduleProvider),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(scheduleProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              _SectionHeader(
                label: 'Coming up',
                trailing: '${data.entries.length}',
              ),
              if (data.entries.isEmpty)
                const _EmptySchedule()
              else
                for (final entry in data.entries) _EntryCard(entry: entry),
              const SizedBox(height: 20),
              _SectionHeader(
                label: 'Your plans',
                trailing: '${data.ownedPlanCount} owned',
              ),
              if (data.ownedPlanCount == 0)
                const Card(
                  color: BuddyColors.surface,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Programmes and meal plans you buy stay here, ready to follow.',
                      style: TextStyle(color: BuddyColors.textSecondary),
                    ),
                  ),
                )
              else ...[
                for (final programme in data.programmes)
                  _PlanCard(
                    title: programme.title,
                    subtitle: 'Programme · ${programme.durationWeeks} weeks',
                    icon: Icons.menu_book_outlined,
                    onTap: () =>
                        context.push('/marketplace/programmes/${programme.id}'),
                  ),
                for (final plan in data.mealPlans)
                  _PlanCard(
                    title: plan.title,
                    subtitle: 'Meal plan · ${plan.durationWeeks} weeks',
                    icon: Icons.restaurant_outlined,
                    onTap: () =>
                        context.push('/marketplace/meal-plans/${plan.id}'),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.trailing});

  final String label;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: BuddyColors.textSecondary,
              ),
            ),
          ),
          Text(
            trailing,
            style: const TextStyle(
              fontSize: 11,
              color: BuddyColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry});

  final ScheduleEntry entry;

  @override
  Widget build(BuildContext context) {
    final isBooking = entry.kind == 'booking';
    return Card(
      color: BuddyColors.surface,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push(entry.route),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: BuddyColors.green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isBooking ? Icons.videocam_outlined : Icons.fitness_center,
                  size: 18,
                  color: BuddyColors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        _dayLabel(entry.startsAt),
                        _timeLabel(entry.startsAt),
                        entry.subtitle,
                        if (entry.meta != null && entry.meta!.isNotEmpty)
                          entry.meta!,
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: BuddyColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: BuddyColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: BuddyColors.surface,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, size: 18, color: BuddyColors.green),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: BuddyColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: BuddyColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptySchedule extends StatelessWidget {
  const _EmptySchedule();

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.event_available_outlined,
      title: 'Nothing scheduled yet',
      subtitle: 'Book a trainer or join a gym slot and it will appear here.',
    );
  }
}

const _weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

String _dayLabel(DateTime? value) {
  if (value == null) return 'Unscheduled';
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(value.year, value.month, value.day);
  final diff = target.difference(today).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Tomorrow';
  if (diff > 1 && diff < 7) return _weekdays[target.weekday - 1];
  return '${target.day} ${_month(target.month)}';
}

String _month(int month) => const [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ][month - 1];

String _timeLabel(DateTime? value) {
  if (value == null) return 'Time to be confirmed';
  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${value.hour < 12 ? 'AM' : 'PM'}';
}
