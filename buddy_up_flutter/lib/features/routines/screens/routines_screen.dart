import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/routine.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/page_loader.dart';
import '../providers/routines_provider.dart';

const List<String> _dayShort = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

/// Routines — the daily streak system from the web app.
///
/// The list is the product: every row shows headline type, days, streak and
/// a check-in button the size of a thumb. The detail/create flow lives in
/// [RoutineEditorScreen] and mirrors the web form field for field.
class RoutinesScreen extends ConsumerStatefulWidget {
  const RoutinesScreen({super.key});

  @override
  ConsumerState<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends ConsumerState<RoutinesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(routinesProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(routinesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Routines'),
        actions: [
          IconButton(
            tooltip: 'Analytics',
            icon: const Icon(Icons.insights_outlined),
            onPressed: () => context.push('/analytics'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: BuddyColors.green,
        onPressed: () => context.push('/routines/create'),
        child: const Icon(Icons.add, color: BuddyColors.black),
      ),
      body: state.isLoading && state.routines.isEmpty
          ? const PageLoader()
          : state.error != null && state.routines.isEmpty
              ? ErrorView(
                  message: state.error!,
                  onRetry: () =>
                      ref.read(routinesProvider.notifier).load(),
                )
              : state.routines.isEmpty
                  ? const EmptyState(
                      icon: Icons.repeat_rounded,
                      title: 'No routines yet',
                      subtitle: 'Create your first routine — even “10 push-ups '
                          'every morning” counts.',
                    )
                  : RefreshIndicator(
                      onRefresh: () =>
                          ref.read(routinesProvider.notifier).load(),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                        children: [
                          _SummaryBar(routines: state.routines),
                          const SizedBox(height: 12),
                          for (final routine in state.routines)
                            _RoutineCard(
                              routine: routine,
                              onEdit: () => context.push(
                                '/routines/${routine.id}/edit',
                              ),
                              onDelete: () => _confirmDelete(routine.id),
                            ),
                        ],
                      ),
                    ),
    );
  }

  Future<void> _confirmDelete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete routine?'),
        content: const Text(
          'The streak and check-in history disappear with it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(routinesProvider.notifier).deleteRoutine(id);
    }
  }
}

class _SummaryBar extends StatelessWidget {
  final List<Routine> routines;

  const _SummaryBar({required this.routines});

  @override
  Widget build(BuildContext context) {
    final active = routines.length;
    final totalStreak = routines.fold<int>(
      0,
      (prev, r) => prev + r.streak,
    );
    final doneToday = routines.where((r) => r.completedToday).length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [BuddyColors.green, BuddyColors.gold],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: _stat('Active routines', '$active', Colors.white),
          ),
          Container(width: 1, height: 36, color: Colors.white54),
          Expanded(
            child: _stat('Total streak', '$totalStreak', Colors.white),
          ),
          Container(width: 1, height: 36, color: Colors.white54),
          Expanded(
            child: _stat('Done today', '$doneToday', Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color.withValues(alpha: 0.9),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _RoutineCard extends ConsumerWidget {
  final Routine routine;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RoutineCard({
    required this.routine,
    required this.onEdit,
    required this.onDelete,
  });

  static IconData _iconFor(String type) {
    switch (type) {
      case 'walk':
        return Icons.directions_walk;
      case 'run':
        return Icons.directions_run;
      case 'cycle':
        return Icons.directions_bike;
      case 'hike':
        return Icons.terrain;
      case 'workout':
        return Icons.fitness_center;
      case 'gym':
        return Icons.warehouse_outlined;
      default:
        return Icons.repeat_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final days = routine.days;
    final completedToday = routine.completedToday;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: completedToday
              ? BuddyColors.green.withValues(alpha: 0.5)
              : cs.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: double.infinity,
            decoration: BoxDecoration(
              color: BuddyColors.green.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
            ),
            child: Icon(_iconFor(routine.type as String? ?? 'other'),
                color: BuddyColors.green, size: 26),
          ),
          Expanded(
            child: InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      routine.displayName.isNotEmpty
                          ? routine.displayName
                          : (routine.name.isNotEmpty ? routine.name : 'Other'),
                      style: TextStyle(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.local_fire_department_outlined,
                            size: 13, color: BuddyColors.gold),
                        const SizedBox(width: 3),
                        Text(
                          '${routine.streak} streak',
                          style: TextStyle(
                            color: cs.onSurface.withValues(alpha: 0.75),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${routine.target} ${routine.unit}',
                          style: TextStyle(
                            color: cs.onSurface.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (var i = 0; i < 7; i++)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Container(
                              width: 22,
                              height: 22,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: days.contains(i)
                                    ? BuddyColors.green.withValues(alpha: 0.2)
                                    : cs.surfaceContainerHighest,
                              ),
                              child: Text(
                                _dayShort[i],
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: days.contains(i)
                                      ? BuddyColors.green
                                      : cs.onSurface
                                          .withValues(alpha: 0.4),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton.icon(
                  onPressed: completedToday
                      ? null
                      : () => _checkIn(context, ref, routine.id),
                  style: FilledButton.styleFrom(
                    backgroundColor: BuddyColors.green,
                    foregroundColor: BuddyColors.black,
                    disabledBackgroundColor: BuddyColors.green.withValues(alpha: 0.25),
                    disabledForegroundColor: BuddyColors.black.withValues(alpha: 0.6),
                    minimumSize: const Size(88, 40),
                  ),
                  icon: Icon(
                    completedToday ? Icons.check_rounded : Icons.check,
                    size: 18,
                  ),
                  label: Text(completedToday ? 'Done' : 'Check in'),
                ),
                IconButton(
                  tooltip: 'Delete routine',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onDelete,
                  iconSize: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkIn(BuildContext context, WidgetRef ref, String id) async {
    final created = await ref.read(routinesProvider.notifier).checkIn(id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(created == null ? 'Check-in failed' : 'Checked in — nice work!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
