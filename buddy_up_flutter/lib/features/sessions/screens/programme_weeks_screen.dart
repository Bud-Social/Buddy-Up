import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/shimmer_loader.dart';

class ProgrammeWeeksScreen extends ConsumerWidget {
  final String programmeId;
  final String programmeTitle;
  const ProgrammeWeeksScreen({super.key, required this.programmeId, required this.programmeTitle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeksAsync = ref.watch(programmeWeeksProvider(programmeId));
    return Scaffold(
      appBar: AppBar(title: Text(programmeTitle)),
      body: weeksAsync.when(
        data: (weeks) {
          final completed = weeks.where((w) => w.isCompleted).length;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  color: BuddyColors.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(children: [
                      SizedBox(
                        width: 56, height: 56,
                        child: Stack(fit: StackFit.expand, children: [
                          CircularProgressIndicator(
                            value: weeks.isEmpty ? 0 : completed / weeks.length,
                            strokeWidth: 6,
                            color: BuddyColors.green,
                            backgroundColor: BuddyColors.surfaceRaised,
                          ),
                          Center(child: Text('$completed/${weeks.length}', style: const TextStyle(fontWeight: FontWeight.bold))),
                        ]),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('$completed/${weeks.length} weeks completed', style: const TextStyle(color: BuddyColors.textSecondary)),
                      ])),
                    ]),
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(weeks.length, (i) {
                  final w = weeks[i];
                  return Card(
                    color: BuddyColors.surface,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: w.isCompleted ? BuddyColors.green.withValues(alpha: 0.2) : BuddyColors.surfaceRaised,
                        child: Icon(w.isCompleted ? Icons.check_circle : Icons.lock_outline, color: w.isCompleted ? BuddyColors.green : BuddyColors.textSecondary, size: 20),
                      ),
                      title: Text('Week ${w.weekNumber}: ${w.title}'),
                      subtitle: Text(w.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: w.isCompleted ? null : () => _completeWeek(ref, programmeId, w.weekNumber),
                    ),
                  );
                }),
              ],
            ),
          );
        },
        loading: () => const ShimmerList(),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }

  Future<void> _completeWeek(WidgetRef ref, String pid, int weekNumber) async {
    try {
      final repo = ref.read(sessionRepositoryProvider);
      await repo.completeWeek(pid, weekNumber);
      ref.invalidate(programmeWeeksProvider(pid));
    } catch (e) {
      // error handled by UI state
    }
  }
}

class MyEnrollmentsScreen extends ConsumerWidget {
  const MyEnrollmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enrollmentsAsync = ref.watch(myEnrollmentsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Programmes')),
      body: enrollmentsAsync.when(
        data: (enrollments) {
          if (enrollments.isEmpty) {
            return const Center(child: Text('No enrolled programmes', style: TextStyle(color: BuddyColors.textSecondary)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: enrollments.length,
            itemBuilder: (_, i) {
              final e = enrollments[i];
              final progress = e.totalWeeks > 0 ? e.completedWeeks / e.totalWeeks : 0.0;
              return Card(
                color: BuddyColors.surface,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => context.push('/programmes/${e.programmeId}/weeks'),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.programmeTitle, style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Row(children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                color: BuddyColors.green,
                                backgroundColor: BuddyColors.surfaceRaised,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text('${e.completedWeeks}/${e.totalWeeks}', style: const TextStyle(fontSize: 13, color: BuddyColors.textSecondary)),
                        ]),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const ShimmerList(),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}