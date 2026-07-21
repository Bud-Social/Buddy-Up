import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/marketplace_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/page_loader.dart';

class CreatorStudioScreen extends ConsumerWidget {
  const CreatorStudioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(creatorServicesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Creator Studio')),
      body: servicesAsync.when(
        data: (services) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader('Meal Plans (${services.mealPlans.length})', Icons.restaurant, () =>
                context.push('/marketplace/meal-plans/create')),
              ...services.mealPlans.map((p) => _listingTile(p.title, '${p.purchaseCount} purchases', p.coverImageUrl)),
              const SizedBox(height: 24),
              _sectionHeader('Programmes (${services.programmes.length})', Icons.fitness_center, () =>
                context.push('/marketplace/programmes/create')),
              ...services.programmes.map((p) => _listingTile(p.title, '${p.purchaseCount} enrollments', p.coverImageUrl)),
              const SizedBox(height: 24),
              _sectionHeader('Events (${services.events.length})', Icons.event, () =>
                context.push('/marketplace/events/create')),
              ...services.events.map((e) => _listingTile(e.title, '${e.attendeeCount} attendees', e.coverImageUrl)),
            ],
          ),
        ),
        loading: () => const PageLoader(),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon, VoidCallback onAdd) {
    return Row(
      children: [
        Icon(icon, size: 20, color: BuddyColors.green),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Spacer(),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('New'),
        ),
      ],
    );
  }

  Widget _listingTile(String title, String subtitle, String imageUrl) {
    return Card(
      color: BuddyColors.surface,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(imageUrl, width: 48, height: 48, fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(width: 48, height: 48, color: BuddyColors.surfaceRaised)),
        ),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(subtitle),
      ),
    );
  }
}
