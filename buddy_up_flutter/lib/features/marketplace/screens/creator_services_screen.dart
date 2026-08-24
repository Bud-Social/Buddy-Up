import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/marketplace_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/page_loader.dart';

class CreatorServicesScreen extends ConsumerWidget {
  const CreatorServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(creatorServicesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? BuddyColors.surface : theme.colorScheme.surface;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: servicesAsync.when(
        data: (services) => RefreshIndicator(
          onRefresh: () async => ref.refresh(creatorServicesProvider),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ServiceSection(
                  title: 'Meal Plans (${services.mealPlans.length})',
                  icon: Icons.restaurant,
                  color: BuddyColors.green,
                  onCreate: () => context.push('/marketplace/meal-plans/create'),
                  children: services.mealPlans.map((p) => _ServiceTile(
                    title: p.title,
                    subtitle: '${p.purchaseCount} sold · ~\$${_artifactUsd(p.priceArtifacts).toStringAsFixed(2)}',
                    imageUrl: p.coverImageUrl,
                    isPublished: p.isPublished,
                    cardBg: cardBg,
                    onTap: () => context.push('/marketplace/meal-plans/${p.id}'),
                    onEdit: () => context.push('/marketplace/meal-plans/create?edit=${p.id}'),
                    onDuplicate: () => _duplicateService(context, ref, 'meal_plan', p),
                    onTogglePublish: () => _togglePublish(context, ref, 'meal_plan', p.id, p.isPublished),
                    onDelete: () => _deleteService(context, ref, 'meal_plan', p.id, p.title),
                  )).toList(),
                ),
                const SizedBox(height: 24),
                _ServiceSection(
                  title: 'Programmes (${services.programmes.length})',
                  icon: Icons.fitness_center,
                  color: const Color(0xFF60A5FA),
                  onCreate: () => context.push('/marketplace/programmes/create'),
                  children: services.programmes.map((p) => _ServiceTile(
                    title: p.title,
                    subtitle: '${p.purchaseCount} enrollments · ~\$${_artifactUsd(p.priceArtifacts).toStringAsFixed(2)}',
                    imageUrl: p.coverImageUrl,
                    isPublished: p.isPublished,
                    cardBg: cardBg,
                    onTap: () => context.push('/marketplace/programmes/${p.id}'),
                    onEdit: () => context.push('/marketplace/programmes/create?edit=${p.id}'),
                    onDuplicate: () => _duplicateService(context, ref, 'programme', p),
                    onTogglePublish: () => _togglePublish(context, ref, 'programme', p.id, p.isPublished),
                    onDelete: () => _deleteService(context, ref, 'programme', p.id, p.title),
                  )).toList(),
                ),
                const SizedBox(height: 24),
                _ServiceSection(
                  title: 'Events (${services.events.length})',
                  icon: Icons.event,
                  color: const Color(0xFFFBBF24),
                  onCreate: () => context.push('/marketplace/events/create'),
                  children: services.events.map((e) => _ServiceTile(
                    title: e.title,
                    subtitle: '${e.attendeeCount} attendees · ${e.startDatetime.length >= 10 ? e.startDatetime.substring(0, 10) : e.startDatetime}',
                    imageUrl: e.coverImageUrl,
                    isPublished: e.isPublished,
                    cardBg: cardBg,
                    onTap: () => context.push('/marketplace/events/${e.id}'),
                    onEdit: () => context.push('/marketplace/events/create?edit=${e.id}'),
                    onDuplicate: () => _duplicateService(context, ref, 'event', e),
                    onTogglePublish: () => _togglePublish(context, ref, 'event', e.id, e.isPublished),
                    onDelete: () => _deleteService(context, ref, 'event', e.id, e.title),
                  )).toList(),
                ),
                const SizedBox(height: 24),
                _ServiceSection(
                  title: 'Products (${services.products.length})',
                  icon: Icons.shopping_bag,
                  color: const Color(0xFFF97316),
                  onCreate: () => context.push('/marketplace/products/create'),
                  children: services.products.map((p) => _ServiceTile(
                    title: p.name,
                    subtitle: '${p.clickCount} clicks',
                    imageUrl: p.imageUrl,
                    isPublished: p.isActive,
                    cardBg: cardBg,
                    onTap: () => context.push('/marketplace/products/${p.id}'),
                    onEdit: () => context.push('/marketplace/products/create?edit=${p.id}'),
                    onDuplicate: () => _duplicateService(context, ref, 'product', p),
                    onTogglePublish: () => _togglePublish(context, ref, 'product', p.id, p.isActive),
                    onDelete: () => _deleteService(context, ref, 'product', p.id, p.name),
                  )).toList(),
                ),
              ],
            ),
          ),
        ),
        loading: () => const PageLoader(),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $e'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.refresh(creatorServicesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddServiceSheet(context),
        backgroundColor: BuddyColors.green,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Add Service', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showAddServiceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Create New Service', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _serviceOption(
              context,
              icon: Icons.restaurant,
              title: 'Meal Plan',
              subtitle: 'Nutrition guide with meal templates',
              color: BuddyColors.green,
              onTap: () {
                Navigator.pop(context);
                context.push('/marketplace/meal-plans/create');
              },
            ),
            _serviceOption(
              context,
              icon: Icons.fitness_center,
              title: 'Training Programme',
              subtitle: 'Multi-week workout routines',
              color: const Color(0xFF60A5FA),
              onTap: () {
                Navigator.pop(context);
                context.push('/marketplace/programmes/create');
              },
            ),
            _serviceOption(
              context,
              icon: Icons.event,
              title: 'Event / Ticket',
              subtitle: 'Online or in-person session event',
              color: const Color(0xFFFBBF24),
              onTap: () {
                Navigator.pop(context);
                context.push('/marketplace/events/create');
              },
            ),
            _serviceOption(
              context,
              icon: Icons.shopping_bag,
              title: 'Product',
              subtitle: 'Affiliate or direct gear and supplements',
              color: const Color(0xFFF97316),
              onTap: () {
                Navigator.pop(context);
                context.push('/marketplace/products/create');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _serviceOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: onTap,
    );
  }

  Future<void> _duplicateService(BuildContext context, WidgetRef ref, String type, dynamic item) async {
    try {
      final repo = ref.read(marketplaceRepositoryProvider);
      if (type == 'meal_plan') {
        await repo.createMealPlan({
          'title': '${item.title} (Copy)',
          'description': item.description,
          'diet_type': item.dietType,
          'duration_weeks': item.durationWeeks,
          'meals_per_day': item.mealsPerDay,
          'calorie_range': item.calorieRange,
          'price_artifacts': item.priceArtifacts,
          'preview_day': item.previewDay,
          'is_published': false,
        });
      } else if (type == 'programme') {
        await repo.createProgramme({
          'title': '${item.title} (Copy)',
          'description': item.description,
          'category': item.category,
          'duration_weeks': item.durationWeeks,
          'price_artifacts': item.priceArtifacts,
          'is_published': false,
        });
      } else if (type == 'event') {
        await repo.createEvent({
          'title': '${item.title} (Copy)',
          'description': item.description,
          'event_type': item.eventType,
          'location': item.location,
          'start_datetime': item.startDatetime,
          'end_datetime': item.endDatetime,
          'timezone': item.timezone,
          'capacity': item.capacity,
          'is_published': false,
        });
      }
      ref.invalidate(creatorServicesProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service duplicated as draft.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Duplicate failed: $e')),
        );
      }
    }
  }

  Future<void> _togglePublish(BuildContext context, WidgetRef ref, String type, String id, bool isCurrentlyPublished) async {
    try {
      final repo = ref.read(marketplaceRepositoryProvider);
      if (type == 'meal_plan') {
        await repo.updateMealPlan(id, {'is_published': !isCurrentlyPublished});
      } else if (type == 'programme') {
        await repo.updateProgramme(id, {'is_published': !isCurrentlyPublished});
      } else if (type == 'event') {
        await repo.updateEvent(id, {'is_published': !isCurrentlyPublished});
      } else if (type == 'product') {
        await repo.updateProduct(id, {'is_active': !isCurrentlyPublished});
      }
      ref.invalidate(creatorServicesProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isCurrentlyPublished ? 'Unpublished (draft).' : 'Published live!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Toggle failed: $e')),
        );
      }
    }
  }

  Future<void> _deleteService(BuildContext context, WidgetRef ref, String type, String id, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service?'),
        content: Text('Are you sure you want to delete "$title"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final repo = ref.read(marketplaceRepositoryProvider);
      if (type == 'meal_plan') {
        await repo.deleteMealPlan(id);
      } else if (type == 'programme') {
        await repo.deleteProgramme(id);
      } else if (type == 'event') {
        await repo.deleteEvent(id);
      } else if (type == 'product') {
        await repo.deleteProduct(id);
      }
      ref.invalidate(creatorServicesProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service deleted.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    }
  }

  double _artifactUsd(Map<String, int> artifacts) {
    const values = {'gym_day_pass': 5.0, 'gym_week_pass': 25.0, 'gym_month_pass': 75.0, 'buddy_token': 1.0};
    return artifacts.entries.fold(0.0, (sum, e) => sum + (values[e.key] ?? 0.0) * e.value);
  }
}

class _ServiceSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onCreate;
  final List<Widget> children;

  const _ServiceSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.onCreate,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
              child: Row(
                children: [
                  Icon(icon, size: 16, color: color),
                  const SizedBox(width: 6),
                  Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
                ],
              ),
            ),
            const Spacer(),
            if (onCreate != null)
              TextButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('New'),
                style: TextButton.styleFrom(foregroundColor: color, visualDensity: VisualDensity.compact),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (children.isEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Text(
              'Nothing here yet.',
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8)),
            ),
          )
        else
          ...children,
      ],
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final bool isPublished;
  final Color cardBg;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onTogglePublish;
  final VoidCallback onDelete;

  const _ServiceTile({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.isPublished,
    required this.cardBg,
    required this.onTap,
    required this.onEdit,
    required this.onDuplicate,
    required this.onTogglePublish,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeColor = isPublished ? BuddyColors.green : Colors.orange;

    return Card(
      color: cardBg,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 44,
                  height: 44,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.image, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: onTap,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isPublished ? 'Live' : 'Draft',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: badgeColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, size: 20, color: theme.colorScheme.onSurfaceVariant),
              padding: EdgeInsets.zero,
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    onEdit();
                    break;
                  case 'duplicate':
                    onDuplicate();
                    break;
                  case 'toggle':
                    onTogglePublish();
                    break;
                  case 'delete':
                    onDelete();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 16), SizedBox(width: 8), Text('Edit')])),
                const PopupMenuItem(value: 'duplicate', child: Row(children: [Icon(Icons.copy, size: 16), SizedBox(width: 8), Text('Duplicate')])),
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(children: [
                    Icon(isPublished ? Icons.archive : Icons.publish, size: 16),
                    const SizedBox(width: 8),
                    Text(isPublished ? 'Unpublish' : 'Publish'),
                  ]),
                ),
                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 16, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
