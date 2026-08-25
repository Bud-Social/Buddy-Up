import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/marketplace_provider.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/marketplace.dart';
import '../utils/event_categories.dart';

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
    // Creator gating parity (web P6): existing creators see 'Creator',
    // everyone else sees 'Become a Creator'.
    final profile = ref.watch(authProvider).profile;
    final isCreator =
        profile != null && profile.role != 'user' && profile.role.isNotEmpty;
    final creatorLabel = isCreator ? 'Creator' : 'Become a Creator';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => context.push('/marketplace/cart'),
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: () => context.push('/marketplace/orders'),
          ),
          TextButton.icon(
            onPressed: () => context.push('/marketplace/creator-studio'),
            icon: const Icon(Icons.storefront_outlined, size: 18),
            label: Text(creatorLabel),
          ),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            // Stacked icon + label tabs — parity with web P6 (labels always
            // visible instead of disappearing on narrow screens).
            tabs: const [
              Tab(icon: Icon(Icons.event_outlined, size: 18), text: 'Events'),
              Tab(icon: Icon(Icons.restaurant_menu_outlined, size: 18), text: 'Meal Plans'),
              Tab(icon: Icon(Icons.fitness_center_outlined, size: 18), text: 'Programmes'),
              Tab(icon: Icon(Icons.shopping_bag_outlined, size: 18), text: 'Products'),
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

// ─── Grid card ───────────────────────────────────────────────────────────────

const _artifactUsdValues = <String, double>{
  'dumbbell': 0.10,
  'barbell': 0.50,
  'burpee': 1.00,
  'squat': 2.50,
  'sprint': 5.00,
  'pr': 10.00,
  'champion': 25.00,
};

double _artifactsToUsd(Map<String, int>? artifacts) {
  if (artifacts == null || artifacts.isEmpty) return 0;
  return artifacts.entries.fold(0.0,
      (sum, e) => sum + (_artifactUsdValues[e.key] ?? 0) * e.value);
}

class _GridCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String? subtitle;
  final String badgeLabel;
  final String? priceLabel;
  final Map<String, int>? artifacts;
  final VoidCallback onTap;
  final VoidCallback? onAddToCart;
  final bool isPast;

  const _GridCard({
    required this.imageUrl,
    required this.title,
    this.subtitle,
    required this.badgeLabel,
    this.priceLabel,
    this.artifacts,
    required this.onTap,
    this.onAddToCart,
    this.isPast = false,
  });

  @override
  Widget build(BuildContext context) {
    final usd = _artifactsToUsd(artifacts);
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: BuddyColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 120,
              width: double.infinity,
              child: Stack(
                children: [
                  Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: BuddyColors.surfaceRaised,
                      child: const Center(
                        child: Icon(Icons.image, color: BuddyColors.textSecondary, size: 32),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: BuddyColors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(badgeLabel,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  if (priceLabel != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: BuddyColors.green.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(priceLabel!,
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: BuddyColors.black)),
                      ),
                    ),
                  if (isPast)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: BuddyColors.red.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Ended',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(subtitle!,
                        style: const TextStyle(fontSize: 12, color: BuddyColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                  if (usd > 0) ...[
                    const SizedBox(height: 2),
                    Text('~USD ${usd.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 11, color: BuddyColors.textSecondary)),
                  ],
                  if (onAddToCart != null) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: ElevatedButton.icon(
                        onPressed: onAddToCart,
                        icon: const Icon(Icons.add_shopping_cart, size: 14),
                        label: const Text('Add to Cart',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BuddyColors.green,
                          foregroundColor: BuddyColors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tabs ────────────────────────────────────────────────────────────────────

class _EventsTab extends ConsumerStatefulWidget {
  const _EventsTab();

  @override
  ConsumerState<_EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends ConsumerState<_EventsTab> {
  String _selectedCategory = 'all';

  void _addToCart(MarketplaceEvent event) {
    ref.read(cartProvider.notifier).addToCart('event_ticket', {'event_id': event.id});
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Added to cart'), duration: Duration(seconds: 1)));
  }

  @override
  Widget build(BuildContext context) {
    final scope = ref.watch(eventsScopeProvider);
    final eventsAsync = ref.watch(eventsProvider);
    final scopes = [('upcoming', 'Upcoming'), ('past', 'Past'), ('all', 'All')];
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Scope selector
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: scopes.map((entry) {
              final key = entry.$1;
              final label = entry.$2;
              final selected = scope == key;
              return Padding(
                padding: const EdgeInsets.only(right: 8, top: 8),
                child: ChoiceChip(
                  label: Text(label),
                  selected: selected,
                  showCheckmark: false,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected ? BuddyColors.black : cs.onSurface,
                  ),
                  backgroundColor: cs.surfaceContainerHighest,
                  selectedColor: BuddyColors.green,
                  onSelected: (_) => ref.read(eventsProvider.notifier).setScope(key),
                ),
              );
            }).toList(),
          ),
        ),

        // Category filter chips
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  label: const Text('All Categories'),
                  selected: _selectedCategory == 'all',
                  showCheckmark: false,
                  selectedColor: BuddyColors.green.withValues(alpha: 0.25),
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _selectedCategory == 'all' ? BuddyColors.green : cs.onSurface.withValues(alpha: 0.7),
                  ),
                  onSelected: (_) => setState(() => _selectedCategory = 'all'),
                ),
              ),
              ...kEventCategories.map((cat) {
                final selected = _selectedCategory == cat.key;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    avatar: Icon(cat.icon, size: 14, color: selected ? BuddyColors.green : cs.onSurface.withValues(alpha: 0.6)),
                    label: Text(cat.label),
                    selected: selected,
                    showCheckmark: false,
                    selectedColor: BuddyColors.green.withValues(alpha: 0.25),
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: selected ? BuddyColors.green : cs.onSurface.withValues(alpha: 0.7),
                    ),
                    onSelected: (selected) => setState(() => _selectedCategory = selected ? cat.key : 'all'),
                  ),
                );
              }),
            ],
          ),
        ),

        Expanded(
          child: eventsAsync.when(
            data: (allEvents) {
              final events = _selectedCategory == 'all'
                  ? allEvents
                  : allEvents.where((e) => e.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();

              if (events.isEmpty) {
                return _emptyState('No events in this category');
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  itemCount: events.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (_, i) {
                    final e = events[i];
                    final start =
                        DateTime.tryParse(e.startDatetime) ?? DateTime.fromMillisecondsSinceEpoch(0);
                        final isPast = start.isBefore(DateTime.now());
                        return _GridCard(
                          imageUrl: e.coverImageUrl,
                          title: e.title,
                          subtitle: _formatDateShort(e.startDatetime),
                          badgeLabel: _eventTypeLabel(e.eventType),
                          priceLabel: e.isFree ? 'FREE' : null,
                          artifacts: e.ticketPriceArtifacts,
                          isPast: isPast,
                          onTap: () => context.push('/marketplace/events/${e.id}'),
                          onAddToCart:
                               e.isRegistered || isPast
                                  ? null
                                  : () => _addToCart(e),
                        );
                      },
                    ),
                  );
                },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
          ),
        ),
      ],
    );
  }
}

class _MealPlansTab extends ConsumerWidget {
  const _MealPlansTab();

  void _addToCart(WidgetRef ref, BuildContext context, MealPlan plan) {
    ref.read(cartProvider.notifier).addToCart('meal_plan', {'meal_plan_id': plan.id});
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Added to cart'), duration: Duration(seconds: 1)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(mealPlansProvider);
    return plansAsync.when(
      data: (plans) => plans.isEmpty
          ? _emptyState('No meal plans available')
          : Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                itemCount: plans.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (_, i) {
                  final plan = plans[i];
                  final price =
                      '${plan.priceArtifacts.values.firstOrNull ?? 0} art.';
                  return _GridCard(
                    imageUrl: plan.coverImageUrl,
                    title: plan.title,
                    subtitle: '${plan.dietType} \u00b7 ${plan.durationWeeks}wks',
                    badgeLabel: plan.dietType,
                    priceLabel: price,
                    artifacts: plan.priceArtifacts,
                    onTap: () => context.push('/marketplace/meal-plans/${plan.id}'),
                    onAddToCart:
                        plan.isPurchased ? null : () => _addToCart(ref, context, plan),
                  );
                },
              ),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }
}

class _ProgrammesTab extends ConsumerWidget {
  const _ProgrammesTab();

  void _addToCart(WidgetRef ref, BuildContext context, TrainingProgramme programme) {
    ref.read(cartProvider.notifier).addToCart('programme', {'programme_id': programme.id});
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Added to cart'), duration: Duration(seconds: 1)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programmesAsync = ref.watch(programmesProvider);
    return programmesAsync.when(
      data: (programmes) => programmes.isEmpty
          ? _emptyState('No programmes available')
          : Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                itemCount: programmes.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (_, i) {
                  final p = programmes[i];
                  final price =
                      '${p.priceArtifacts.values.firstOrNull ?? 0} art.';
                  return _GridCard(
                    imageUrl: p.coverImageUrl,
                    title: p.title,
                    subtitle: '${p.durationWeeks} weeks',
                    badgeLabel: p.category,
                    priceLabel: price,
                    artifacts: p.priceArtifacts,
                    onTap: () => context.push('/marketplace/programmes/${p.id}'),
                    onAddToCart:
                        p.isPurchased ? null : () => _addToCart(ref, context, p),
                  );
                },
              ),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }
}

class _ProductsTab extends ConsumerWidget {
  const _ProductsTab();

  void _addToCart(WidgetRef ref, BuildContext context, MarketplaceProduct product) {
    ref.read(cartProvider.notifier).addToCart('product', {'product_id': product.id});
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Added to cart'), duration: Duration(seconds: 1)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    return productsAsync.when(
      data: (products) => products.isEmpty
          ? _emptyState('No products available')
          : Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (_, i) {
                  final p = products[i];
                  return _GridCard(
                    imageUrl: p.imageUrl,
                    title: p.name,
                    subtitle: p.brand,
                    badgeLabel: p.category,
                    priceLabel: p.priceDisplay,
                    onTap: () => context.push('/marketplace/products/${p.id}'),
                    onAddToCart: () => _addToCart(ref, context, p),
                  );
                },
              ),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

Widget _emptyState(String message) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.storefront_outlined,
            size: 64, color: BuddyColors.textSecondary.withValues(alpha: 0.3)),
        const SizedBox(height: 16),
        Text(message, style: const TextStyle(color: BuddyColors.textSecondary)),
      ],
    ),
  );
}

String _eventTypeLabel(String type) {
  switch (type) {
    case 'online':
      return 'Virtual';
    case 'in_person':
      return 'In Person';
    case 'hybrid':
      return 'Hybrid';
    default:
      return type.replaceAll('_', ' ');
  }
}

String _formatDateShort(String iso) {
  final dt = DateTime.tryParse(iso);
  if (dt == null) return iso;
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${months[dt.month - 1]} ${dt.day}, ${_formatTimeShort(iso)}';
}

String _formatTimeShort(String iso) {
  final dt = DateTime.tryParse(iso);
  if (dt == null) return '';
  final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
  final ampm = dt.hour >= 12 ? 'PM' : 'AM';
  return '$hour${ampm.toLowerCase()}';
}
