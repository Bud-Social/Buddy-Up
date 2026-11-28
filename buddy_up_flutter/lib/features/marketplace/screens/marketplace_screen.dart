import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../providers/marketplace_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/marketplace.dart';
import '../utils/event_categories.dart';
// `StockBadge` lives with the detail screen so the grid and the detail page read
// the product's stock through one set of thresholds.
import 'product_detail_screen.dart';

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
    Future.microtask(() => ref.read(cartProvider.notifier).loadCart());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cartCount = ref.watch(cartProvider).value?.items.length ?? 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Marketplace',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.package, size: 20),
                Text('Orders', style: TextStyle(fontSize: 9)),
              ],
            ),
            tooltip: 'Orders',
            onPressed: () => context.push('/marketplace/orders'),
          ),
          IconButton(
            tooltip: 'Cart',
            onPressed: () => context.push('/marketplace/cart'),
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.shoppingBag, size: 20),
                    Text('Cart', style: TextStyle(fontSize: 9)),
                  ],
                ),
                if (cartCount > 0)
                  Positioned(
                    top: -5,
                    right: -7,
                    child: Container(
                      width: 16,
                      height: 16,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: BuddyColors.green,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$cartCount',
                        style: const TextStyle(
                          color: BuddyColors.black,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Courier self-service lives here: it is the marketplace's
          // fulfillment half, and there is nowhere else a buyer-turned-courier
          // would look.
          PopupMenuButton<String>(
            icon: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.truck, size: 20),
                Text('Courier', style: TextStyle(fontSize: 9)),
              ],
            ),
            tooltip: 'More',
            onSelected: (_) => context.push('/marketplace/delivery-personnel'),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'courier',
                child: Text('Become a courier'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Web parity: a rounded surface rail of pill tabs, active pill solid
          // green with black text — not an underline TabBar.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: AnimatedBuilder(
                animation: _tabController,
                builder: (context, _) {
                  const tabs = <({IconData icon, String label})>[
                    (icon: LucideIcons.calendar, label: 'Events'),
                    (icon: LucideIcons.utensils, label: 'Meal Plans'),
                    (icon: LucideIcons.dumbbell, label: 'Programmes'),
                    (icon: LucideIcons.shoppingBag, label: 'Products'),
                  ];
                  return Row(
                    children: [
                      for (var i = 0; i < tabs.length; i++)
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _tabController.animateTo(i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(vertical: 7),
                              decoration: BoxDecoration(
                                color: _tabController.index == i
                                    ? BuddyColors.green
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    tabs[i].icon,
                                    size: 14,
                                    color: _tabController.index == i
                                        ? BuddyColors.black
                                        : cs.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      tabs[i].label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: _tabController.index == i
                                            ? BuddyColors.black
                                            : cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
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
  final String? distanceLabel;

  /// True for the re-purchase-blocked content types (plans, programmes): render
  /// a disabled "Owned" instead of dropping the CTA silently. Not for products,
  /// which are physical goods bought again -- and not for sold-out products,
  /// whose state lives in `stockBadge`.
  final bool ownedMark;

  /// Stock state for products only. Null hides it entirely, which is what every
  /// non-product listing and every untracked product wants.
  final Widget? stockBadge;

  /// Pre-formatted rating summary, e.g. "4.5 (12)". Null when unrated.
  final String? ratingLabel;

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
    this.distanceLabel,
    this.ownedMark = false,
    this.stockBadge,
    this.ratingLabel,
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
                  if (distanceLabel != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.place, size: 11, color: BuddyColors.green),
                        const SizedBox(width: 3),
                        Text(distanceLabel!,
                            style: const TextStyle(
                                fontSize: 11,
                                color: BuddyColors.green,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                  if (usd > 0) ...[
                    const SizedBox(height: 2),
                    Text('~USD ${usd.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 11, color: BuddyColors.textSecondary)),
                  ],
                  if (ratingLabel != null) ...[
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.star, size: 12, color: BuddyColors.gold),
                      const SizedBox(width: 3),
                      Text(ratingLabel!,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: BuddyColors.gold)),
                    ]),
                  ],
                  if (stockBadge != null) ...[
                    const SizedBox(height: 4),
                    stockBadge!,
                  ],
                  // A sold-out product gets no button at all rather than a
                  // disabled one: a control that can never fire is noise, and
                  // the badge above already says why.
                  if (ownedMark) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: OutlinedButton(
                        onPressed: null,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: BuddyColors.border),
                          shape:
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline, size: 14, color: BuddyColors.green),
                            SizedBox(width: 4),
                            Text('Owned',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: BuddyColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                  ] else if (onAddToCart != null) ...[
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
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(eventsFilterProvider).query;
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(eventsFilterProvider.notifier).setQuery(value.trim());
    });
  }

  /// Web parity: a pill filter. Active pills fill green (or the supplied
  /// accent); idle pills are an outlined surface.
  Widget _pill(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
    IconData? icon,
    Color activeColor = BuddyColors.green,
    Color? activeText,
  }) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? activeColor : cs.surfaceContainerHighest,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: selected
                    ? (activeText ?? BuddyColors.black)
                    : cs.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected
                    ? (activeText ?? BuddyColors.black)
                    : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart(MarketplaceEvent event) {
    ref.read(cartProvider.notifier).addToCart('event_ticket', {'event_id': event.id});
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Added to cart'), duration: Duration(seconds: 1)));
  }

  Future<void> _locate() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Turn on location services to find nearby events.')),
          );
        }
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(timeLimit: Duration(seconds: 10)),
      );
      ref.read(eventsFilterProvider.notifier).setCoords(pos.latitude, pos.longitude);
      ref.read(eventsProvider.notifier).refresh();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not get your location. Try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scope = ref.watch(eventsScopeProvider);
    final eventsAsync = ref.watch(eventsProvider);
    final filter = ref.watch(eventsFilterProvider);
    final geo = ref.watch(eventsGeoProvider);
    final scopes = [('upcoming', 'Upcoming'), ('past', 'Past'), ('all', 'All')];
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Scope selector + My Tickets / Host at the far right
        SizedBox(
          height: 40,
          child: Row(
            children: [
              Expanded(
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
              TextButton(
                onPressed: () => context.push('/marketplace/tickets'),
                child: const Text('My Tickets', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
        // Web parity: the search box sits under the scope row.
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
          child: Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: TextStyle(color: cs.onSurface, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search events...',
                hintStyle: TextStyle(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
                prefixIcon: Icon(
                  LucideIcons.search,
                  size: 16,
                  color: cs.onSurfaceVariant,
                ),
                suffixIcon: filter.query.isEmpty
                    ? null
                    : IconButton(
                        icon: Icon(
                          LucideIcons.x,
                          size: 14,
                          color: cs.onSurfaceVariant,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(eventsFilterProvider.notifier).setQuery('');
                        },
                      ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 11),
              ),
            ),
          ),
        ),
        if (filter.lat != null && geo != null && geo.auto && geo.message != null)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: BuddyColors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: BuddyColors.green.withValues(alpha: 0.25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.place, size: 15, color: BuddyColors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nearby: ${geo.radiusKm.toStringAsFixed(0)} km · ${geo.density == 'dense' ? 'lots around you' : 'fewer around you'}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(geo.message!,
                          style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Format pills + verified toggle + a real "near me".
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            children: [
              for (final format in const [
                ('all', 'All formats'),
                ('in_person', 'In person'),
                ('online', 'Virtual'),
                ('hybrid', 'Hybrid'),
              ])
                _pill(
                  context,
                  label: format.$2,
                  selected: filter.eventType == format.$1,
                  onTap: () => ref
                      .read(eventsFilterProvider.notifier)
                      .setEventType(format.$1),
                ),
              _pill(
                context,
                label: 'Verified only',
                selected: filter.verifiedOnly,
                onTap: () => ref
                    .read(eventsFilterProvider.notifier)
                    .setVerifiedOnly(!filter.verifiedOnly),
              ),
              _pill(
                context,
                label: filter.lat != null ? 'Near me ✓' : 'Near me',
                selected: filter.lat != null,
                icon: LucideIcons.locateFixed,
                onTap: () {
                  if (filter.lat != null) {
                    ref
                        .read(eventsFilterProvider.notifier)
                        .setCoords(null, null);
                  } else {
                    _locate();
                  }
                },
              ),
            ],
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
                          distanceLabel: e.distanceKm != null
                              ? '${e.distanceKm!.toStringAsFixed(e.distanceKm! < 10 ? 1 : 0)} km away'
                              : null,
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
                    ownedMark: plan.isPurchased,
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
                    ownedMark: p.isPurchased,
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
                  // Only a tracked product can be sold out — an untracked one
                  // has a meaningless stock_quantity of 0.
                  final soldOut = p.stockTrackingEnabled && p.stockQuantity == 0;
                  return _GridCard(
                    imageUrl: p.imageUrl,
                    title: p.name,
                    subtitle: p.brand,
                    badgeLabel: p.category,
                    priceLabel: p.priceDisplay,
                    stockBadge: p.stockTrackingEnabled
                        ? StockBadge(quantity: p.stockQuantity, soldOut: soldOut)
                        : null,
                    ratingLabel: p.reviewCount > 0
                        ? '${p.averageRating.toStringAsFixed(1)} (${p.reviewCount})'
                        : null,
                    onTap: () => context.push('/marketplace/products/${p.id}'),
                    onAddToCart: soldOut ? null : () => _addToCart(ref, context, p),
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
