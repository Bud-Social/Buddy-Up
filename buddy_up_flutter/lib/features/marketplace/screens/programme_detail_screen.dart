import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/marketplace_provider.dart';
import '../../../core/theme/app_theme.dart';
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
        appBar: AppBar(title: Text(programme.title)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  programme.coverImageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 200, color: BuddyColors.surfaceRaised,
                    child: const Center(child: Icon(Icons.fitness_center, size: 48, color: BuddyColors.textSecondary)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(programme.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.category_outlined, size: 16, color: BuddyColors.textSecondary),
                const SizedBox(width: 4),
                Text(programme.category, style: const TextStyle(color: BuddyColors.textSecondary)),
                const SizedBox(width: 16),
                const Icon(Icons.calendar_today, size: 16, color: BuddyColors.textSecondary),
                const SizedBox(width: 4),
                Text('${programme.durationWeeks} weeks', style: const TextStyle(color: BuddyColors.textSecondary)),
              ]),
              const SizedBox(height: 16),
              Text(programme.description, style: const TextStyle(height: 1.5)),
              const SizedBox(height: 24),
              if (programme.priceArtifacts.isNotEmpty) ...[
                const Text('Price', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8, children: programme.priceArtifacts.entries.map((e) =>
                  Chip(label: Text('${e.value} ${e.key}'), backgroundColor: BuddyColors.surfaceRaised),
                ).toList()),
                const SizedBox(height: 24),
              ],
              BuddyButton(
                label: programme.isPurchased ? 'View Weeks' : 'Enroll Now',
                fullWidth: true,
                onPressed: programme.isPurchased
                    ? () => context.push('/programmes/$programmeId/weeks?title=${Uri.encodeComponent(programme.title)}')
                    : () async {
                  await ref.read(marketplaceRepositoryProvider).purchaseProgramme(programmeId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Enrolled successfully!')),
                    );
                    ref.invalidate(programmeDetailProvider(programmeId));
                  }
                },
              ),
              const SizedBox(height: 8),
              Text('${programme.purchaseCount} enrolled', style: const TextStyle(color: BuddyColors.textSecondary)),
            ],
          ),
        ),
      ),
      loading: () => const Scaffold(body: PageLoader()),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
    );
  }
}
