import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/marketplace_provider.dart';
import '../../../core/theme/app_theme.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => context.push('/marketplace/cart'),
          ),
          IconButton(
            icon: const Icon(Icons.dashboard_outlined),
            onPressed: () => context.push('/marketplace/creator-studio'),
          ),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Events'),
              Tab(text: 'Meal Plans'),
              Tab(text: 'Programmes'),
              Tab(text: 'Products'),
            ],
            indicatorColor: BuddyColors.green,
            labelColor: BuddyColors.green,
            unselectedLabelColor: BuddyColors.textSecondary,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _EventsTab(),
                _MealPlansTab(),
                _ProgrammesTab(),
                _ProductsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EventsTab extends ConsumerWidget {
  const _EventsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);
    return eventsAsync.when(
      data: (events) => events.isEmpty
          ? _emptyState('No events available')
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              itemBuilder: (_, i) => _MarketplaceCard(
                title: events[i].title,
                subtitle: events[i].eventType,
                imageUrl: events[i].coverImageUrl,
                trailing: events[i].isFree ? 'FREE' : 'Artifacts',
                onTap: () => context.push('/marketplace/events/${events[i].id}'),
              ),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }
}

class _MealPlansTab extends ConsumerWidget {
  const _MealPlansTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(mealPlansProvider);
    return plansAsync.when(
      data: (plans) => plans.isEmpty
          ? _emptyState('No meal plans available')
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: plans.length,
              itemBuilder: (_, i) => _MarketplaceCard(
                title: plans[i].title,
                subtitle: '${plans[i].dietType} - ${plans[i].durationWeeks} weeks',
                imageUrl: plans[i].coverImageUrl,
                trailing: '${plans[i].purchaseCount} bought',
                onTap: () => context.push('/marketplace/meal-plans/${plans[i].id}'),
              ),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }
}

class _ProgrammesTab extends ConsumerWidget {
  const _ProgrammesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programmesAsync = ref.watch(programmesProvider);
    return programmesAsync.when(
      data: (programmes) => programmes.isEmpty
          ? _emptyState('No programmes available')
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: programmes.length,
              itemBuilder: (_, i) => _MarketplaceCard(
                title: programmes[i].title,
                subtitle: '${programmes[i].category} - ${programmes[i].durationWeeks} weeks',
                imageUrl: programmes[i].coverImageUrl,
                trailing: '${programmes[i].purchaseCount} enrolled',
                onTap: () => context.push('/marketplace/programmes/${programmes[i].id}'),
              ),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }
}

class _ProductsTab extends ConsumerWidget {
  const _ProductsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    return productsAsync.when(
      data: (products) => products.isEmpty
          ? _emptyState('No products available')
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (_, i) => _MarketplaceCard(
                title: products[i].name,
                subtitle: products[i].brand,
                imageUrl: products[i].imageUrl,
                trailing: products[i].priceDisplay,
                onTap: () => context.push('/marketplace/products/${products[i].id}'),
              ),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }
}

Widget _emptyState(String message) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.storefront_outlined, size: 64, color: BuddyColors.textSecondary.withValues(alpha: 0.3)),
        const SizedBox(height: 16),
        Text(message, style: const TextStyle(color: BuddyColors.textSecondary)),
      ],
    ),
  );
}

class _MarketplaceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final String trailing;
  final VoidCallback onTap;

  const _MarketplaceCard({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: BuddyColors.surface,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 72, height: 72,
                    color: BuddyColors.surfaceRaised,
                    child: const Icon(Icons.image, color: BuddyColors.textSecondary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 13, color: BuddyColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(trailing, style: const TextStyle(fontSize: 12, color: BuddyColors.green, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
