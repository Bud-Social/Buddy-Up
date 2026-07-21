import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../../../shared/widgets/empty_state.dart';

class TrainerListScreen extends ConsumerStatefulWidget {
  const TrainerListScreen({super.key});

  @override
  ConsumerState<TrainerListScreen> createState() => _TrainerListScreenState();
}

class _TrainerListScreenState extends ConsumerState<TrainerListScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    Future.microtask(() => ref.read(paginatedTrainersProvider.notifier).loadMore());
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      ref.read(paginatedTrainersProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paginatedTrainersProvider);
    final trainers = state.trainers;

    return Scaffold(
      appBar: AppBar(title: const Text('Trainers')),
      body: trainers.isEmpty && state.isLoadingMore
          ? const ShimmerList()
          : trainers.isEmpty
              ? const EmptyState(icon: Icons.person_search, title: 'No trainers found')
              : RefreshIndicator(
                  onRefresh: () => ref.read(paginatedTrainersProvider.notifier).refresh(),
                  child: ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(16),
                    itemCount: trainers.length + (state.hasMore ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i == trainers.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        );
                      }
                      final t = trainers[i];
                      return Card(
                        color: BuddyColors.surface,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => context.push('/trainers/${t.username}'),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Avatar(src: t.avatarUrl, alt: t.displayName, size: AvatarSize.lg),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(t.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                      if (t.specialties.isNotEmpty)
                                        Text(t.specialties.join(', '), style: const TextStyle(fontSize: 12, color: BuddyColors.textSecondary)),
                                      const SizedBox(height: 4),
                                      Row(children: [
                                        const Icon(Icons.star, size: 14, color: Colors.amber),
                                        const SizedBox(width: 4),
                                        Text('${t.averageRating.toStringAsFixed(1)} (${t.reviewCount})', style: const TextStyle(fontSize: 12)),
                                        const SizedBox(width: 12),
                                        const Icon(Icons.fitness_center, size: 14, color: BuddyColors.textSecondary),
                                        const SizedBox(width: 4),
                                        Text('${t.sessionCount} sessions', style: const TextStyle(fontSize: 12)),
                                      ]),
                                    ],
                                  ),
                                ),
                                if (t.hourlyRate > 0)
                                  Text('\$${t.hourlyRate.toStringAsFixed(0)}/hr', style: const TextStyle(color: BuddyColors.green, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}