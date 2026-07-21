import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/marketplace_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/page_loader.dart';

class MealPlanDetailScreen extends ConsumerWidget {
  final String planId;
  const MealPlanDetailScreen({super.key, required this.planId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(mealPlanDetailProvider(planId));
    return planAsync.when(
      data: (plan) => Scaffold(
        appBar: AppBar(title: Text(plan.title)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  plan.coverImageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 200, color: BuddyColors.surfaceRaised,
                    child: const Center(child: Icon(Icons.restaurant, size: 48, color: BuddyColors.textSecondary)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(plan.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ),
                  if (plan.isPurchased)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: BuddyColors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Purchased', style: TextStyle(color: BuddyColors.green, fontSize: 12)),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.restaurant_menu, size: 16, color: BuddyColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(plan.dietType, style: const TextStyle(color: BuddyColors.textSecondary)),
                  const SizedBox(width: 16),
                  const Icon(Icons.calendar_today, size: 16, color: BuddyColors.textSecondary),
                  const SizedBox(width: 4),
                  Text('${plan.durationWeeks} weeks', style: const TextStyle(color: BuddyColors.textSecondary)),
                  const SizedBox(width: 16),
                  const Icon(Icons.local_fire_department, size: 16, color: BuddyColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(plan.calorieRange, style: const TextStyle(color: BuddyColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 16),
              Text(plan.description, style: const TextStyle(height: 1.5)),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text('${plan.averageRating.toStringAsFixed(1)} (${plan.reviewCount} reviews)'),
                  const Spacer(),
                  Text('${plan.purchaseCount} purchased', style: const TextStyle(color: BuddyColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 24),
              if (plan.priceArtifacts.isNotEmpty) ...[
                const Text('Price', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: plan.priceArtifacts.entries.map((e) =>
                    Chip(
                      label: Text('${e.value} ${e.key}'),
                      backgroundColor: BuddyColors.surfaceRaised,
                    ),
                  ).toList(),
                ),
                const SizedBox(height: 24),
              ],
              BuddyButton(
                label: plan.isPurchased ? 'Personalise with AI' : 'Purchase',
                fullWidth: true,
                onPressed: () async {
                  if (plan.isPurchased) {
                    await ref.read(marketplaceRepositoryProvider).personaliseMealPlan(planId);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Personalisation started!')),
                      );
                    }
                  } else {
                    await ref.read(marketplaceRepositoryProvider).purchaseMealPlan(planId);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Purchase successful!')),
                      );
                      ref.invalidate(mealPlanDetailProvider(planId));
                    }
                  }
                },
              ),
              if (plan.isPurchased) ...[
                const SizedBox(height: 12),
                BuddyButton(
                  label: 'View Full Plan',
                  variant: BuddyButtonVariant.secondary,
                  fullWidth: true,
                  onPressed: () {
                    if (plan.fullPlan != null) {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: BuddyColors.surface,
                        builder: (_) => _FullPlanSheet(plan: plan.fullPlan!),
                      );
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      loading: () => const Scaffold(body: PageLoader()),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
    );
  }
}

class _FullPlanSheet extends StatelessWidget {
  final Map<String, dynamic> plan;
  const _FullPlanSheet({required this.plan});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: BuddyColors.textSecondary, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            const Text('Full Meal Plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                controller: scrollController,
                children: plan.entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('${e.key}: ${e.value}', style: const TextStyle(height: 1.4)),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
