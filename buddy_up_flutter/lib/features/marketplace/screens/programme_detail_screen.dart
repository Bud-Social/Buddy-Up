import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/marketplace_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/marketplace.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/page_loader.dart';

class ProgrammeDetailScreen extends ConsumerWidget {
  final String programmeId;
  const ProgrammeDetailScreen({super.key, required this.programmeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programmeAsync = ref.watch(programmeDetailProvider(programmeId));

    return programmeAsync.when(
      data: (programme) => Scaffold(
        backgroundColor: BuddyColors.black,
        body: CustomScrollView(
          slivers: [
            // Hero cover
            SliverAppBar(
              expandedHeight: 260,
              pinned: true,
              backgroundColor: BuddyColors.surface,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      programme.coverImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: BuddyColors.surfaceRaised,
                        child: const Center(
                          child: Icon(Icons.fitness_center, size: 64, color: BuddyColors.textSecondary),
                        ),
                      ),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black87],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF60A5FA).withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              programme.category.replaceAll('_', ' ').toUpperCase(),
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(programme.title,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Row(children: [
                            const Icon(Icons.calendar_today, size: 14, color: Colors.white70),
                            const SizedBox(width: 4),
                            Text('${programme.durationWeeks} weeks',
                                style: const TextStyle(color: Colors.white70, fontSize: 13)),
                            const SizedBox(width: 12),
                            const Icon(Icons.people_outline, size: 14, color: Colors.white70),
                            const SizedBox(width: 4),
                            Text('${programme.purchaseCount} enrolled',
                                style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Creator row
                    _CreatorRow(creator: programme.creatorData),
                    const SizedBox(height: 20),

                    // Description
                    const Text('About', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(programme.description,
                        style: const TextStyle(color: BuddyColors.textSecondary, height: 1.6)),
                    const SizedBox(height: 20),

                    // Pricing
                    if (programme.priceArtifacts.isNotEmpty) ...[
                      const Text('Pricing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Row(
                        children: programme.priceArtifacts.entries
                            .map((e) => Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF60A5FA).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: const Color(0xFF60A5FA).withValues(alpha: 0.3)),
                                  ),
                                  child: Text('${e.value} ${e.key}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF60A5FA))),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Schedule preview (if purchased)
                    if (programme.isPurchased) ...[
                      Row(
                        children: [
                          const Expanded(
                            child: Text('Programme Schedule',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          Text('${programme.durationWeeks} weeks',
                              style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Week cards
                      ...List.generate(programme.durationWeeks.clamp(0, 6), (weekIdx) {
                        return _WeekScheduleCard(
                          weekIndex: weekIdx,
                          programmeId: programmeId,
                        );
                      }),
                      if (programme.durationWeeks > 6)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '+ ${programme.durationWeeks - 6} more weeks...',
                            style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 12),
                          ),
                        ),
                      const SizedBox(height: 20),
                    ],

                    // CTA
                    BuddyButton(
                      label: programme.isPurchased ? '✓ Enrolled' : 'Enroll Now',
                      fullWidth: true,
                      onPressed: programme.isPurchased
                          ? null
                          : () async {
                              try {
                                await ref
                                    .read(marketplaceRepositoryProvider)
                                    .purchaseProgramme(programmeId);
                                ref.invalidate(programmeDetailProvider(programmeId));
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('🎉 Enrolled successfully!'),
                                      backgroundColor: BuddyColors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                                  );
                                }
                              }
                            },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      loading: () => const Scaffold(body: PageLoader()),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Programme')),
        body: Center(child: Text('$e')),
      ),
    );
  }
}

class _CreatorRow extends StatelessWidget {
  final CreatorData creator;
  const _CreatorRow({required this.creator});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      CircleAvatar(
        backgroundImage: NetworkImage(creator.avatarUrl),
        radius: 20,
        backgroundColor: BuddyColors.surfaceRaised,
      ),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(creator.displayName,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        Text('@${creator.username}',
            style: const TextStyle(fontSize: 12, color: BuddyColors.textSecondary)),
      ]),
      if (creator.verificationStatus == 'verified') ...[
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: BuddyColors.green.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified, size: 12, color: BuddyColors.green),
              const SizedBox(width: 4),
              Text('Verified', style: TextStyle(fontSize: 10, color: BuddyColors.green, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    ]);
  }
}

class _WeekScheduleCard extends ConsumerWidget {
  final int weekIndex;
  final String programmeId;
  const _WeekScheduleCard({required this.weekIndex, required this.programmeId});

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _fullDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: BuddyColors.surface,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Week ${weekIndex + 1}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (dayIdx) {
              // For demo, alternate active/rest days
              final isActive = dayIdx < 5;
              return GestureDetector(
                onTap: isActive
                    ? () => context.push(
                          '/marketplace/programmes/$programmeId/activity?week=$weekIndex&day=${_fullDays[dayIdx]}&activity=0',
                        )
                    : null,
                child: Column(children: [
                  Text(_days[dayIdx],
                      style: const TextStyle(fontSize: 10, color: BuddyColors.textSecondary)),
                  const SizedBox(height: 4),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF60A5FA).withValues(alpha: 0.2)
                          : BuddyColors.surfaceRaised,
                      shape: BoxShape.circle,
                      border: isActive
                          ? Border.all(color: const Color(0xFF60A5FA).withValues(alpha: 0.4))
                          : null,
                    ),
                    child: Center(
                      child: Icon(
                        isActive ? Icons.fitness_center : Icons.hotel,
                        size: 14,
                        color: isActive ? const Color(0xFF60A5FA) : BuddyColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(isActive ? 'Train' : 'Rest',
                      style: const TextStyle(fontSize: 9, color: BuddyColors.textSecondary)),
                ]),
              );
            }),
          ),
        ]),
      ),
    );
  }
}
