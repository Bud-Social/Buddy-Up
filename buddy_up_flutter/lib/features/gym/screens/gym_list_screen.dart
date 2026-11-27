import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../providers/gym_provider.dart';
import '../widgets/gym_card.dart';
import '../../../data/models/gym.dart';
import '../../../shared/widgets/page_loader.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/toast.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/navigation/app_nav.dart';

/// Gyms browser — mirrors the web `Gyms.tsx` surface:
/// Discover / My Gyms, format tabs, city + ordering, near-me radius and
/// verified filters, category rail, plus a Manage shortcut for owners.
class GymListScreen extends ConsumerStatefulWidget {
  const GymListScreen({super.key});

  @override
  ConsumerState<GymListScreen> createState() => _GymListScreenState();
}

class _GymListScreenState extends ConsumerState<GymListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  Timer? _debounce;

  static const _orderings = <(String, String)>[
    ('members', 'Most members'),
    ('rating', 'Top rated'),
    ('newest', 'Newest'),
    ('nearest', 'Nearest'),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(gymListProvider.notifier).loadGyms());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _showToast(String message, {ToastType type = ToastType.error}) {
    if (!mounted) return;
    showToast(context, message, type: type);
  }

  Future<void> _locate() async {
    final notifier = ref.read(gymListProvider.notifier);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _showToast('Turn on location services to find nearby gyms.');
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        _showToast('Location blocked — allow it in system settings.');
        return;
      }
      if (perm == LocationPermission.denied) return;
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(timeLimit: Duration(seconds: 10)),
      );
      notifier.setCoords(pos.latitude, pos.longitude);
      notifier.loadGyms(
        lat: pos.latitude,
        lng: pos.longitude,
        ordering: 'nearest',
      );
    } catch (_) {
      _showToast('Could not get your location. Try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gymListProvider);
    final notifier = ref.read(gymListProvider.notifier);
    final categoriesAsync = ref.watch(gymCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.menu),
          tooltip: 'Menu',
          onPressed: () => AppNav.open(context),
        ),
        title: const Text('Gyms'),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/gyms/create'),
            icon: const Icon(LucideIcons.plus, size: 16),
            label: const Text('Create'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              color: BuddyColors.green,
              onRefresh: () => notifier.loadGyms(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ScopeToggle(
                            myGyms: state.myGyms,
                            onChanged: (my) => notifier.loadGyms(my: my),
                          ),
                          const SizedBox(height: 10),
                          _FormatTabs(),
                          const SizedBox(height: 10),
                          _NearbyNotice(),
                          const SizedBox(height: 10),
                          _buildSearch(context, notifier),
                          const SizedBox(height: 10),
                          _buildCityAndOrdering(context, state, notifier),
                          const SizedBox(height: 10),
                          _buildLocationFilters(context, state, notifier),
                          const SizedBox(height: 8),
                          categoriesAsync.when(
                            data: (categories) => _buildCategoryRail(context, state, categories, notifier),
                            loading: () => const SizedBox(height: 34),
                            error: (_, _) => const SizedBox(height: 34),
                          ),
                          if (state.myGyms) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Gyms you manage can be opened below — each one has its own console: '
                              'members, requests, locations, online coaching, announcements, setup.',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontSize: 11,
                                height: 1.35,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                  ..._buildListSlivers(state),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch(BuildContext context, GymListNotifier notifier) {
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      controller: _searchController,
      style: TextStyle(color: scheme.onSurface),
      decoration: InputDecoration(
        hintText: 'Search gyms...',
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        prefixIcon: Icon(LucideIcons.search, color: scheme.onSurfaceVariant, size: 18),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: Icon(LucideIcons.x, color: scheme.onSurfaceVariant, size: 17),
                onPressed: () {
                  _searchController.clear();
                  _debounce?.cancel();
                  notifier.loadGyms(clearQuery: true);
                  setState(() {});
                },
              )
            : null,
      ),
      onChanged: (v) {
        setState(() {});
        _debounce?.cancel();
        if (v.length > 2) {
          _debounce = Timer(const Duration(milliseconds: 400), () {
            notifier.loadGyms(query: v);
          });
        } else if (v.isEmpty) {
          notifier.loadGyms(clearQuery: true);
        }
      },
    );
  }

  Widget _buildCityAndOrdering(
    BuildContext context,
    GymListState state,
    GymListNotifier notifier,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _cityController,
            style: TextStyle(color: scheme.onSurface, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'City (e.g. Nairobi)',
              hintStyle: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            onSubmitted: (v) => notifier.loadGyms(
              city: v.trim(),
              clearCity: v.trim().isEmpty,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: BuddyColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: state.ordering,
              dropdownColor: BuddyColors.surface,
              icon: Icon(LucideIcons.chevronDown, size: 15, color: scheme.onSurfaceVariant),
              style: TextStyle(color: scheme.onSurface, fontSize: 12),
              items: [
                for (final (key, label) in _orderings)
                  DropdownMenuItem(value: key, child: Text(label)),
              ],
              onChanged: (v) {
                if (v == null) return;
                if (v == 'nearest' && state.lat == null) {
                  _locate();
                  return;
                }
                notifier.loadGyms(ordering: v);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationFilters(
    BuildContext context,
    GymListState state,
    GymListNotifier notifier,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final hasCoords = state.lat != null;
    return SizedBox(
      height: 32,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FilterPill(
            label: hasCoords ? 'Near me ✓' : 'Near me',
            icon: LucideIcons.locateFixed,
            active: hasCoords,
            onTap: () {
              if (hasCoords) {
                notifier.setCoords(null, null);
                notifier.loadGyms(ordering: 'members');
              } else {
                _locate();
              }
            },
          ),
          if (hasCoords) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: BuddyColors.surface,
                borderRadius: BorderRadius.circular(999),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<double?>(
                  value: state.radiusKm,
                  dropdownColor: BuddyColors.surface,
                  icon: Icon(LucideIcons.chevronDown, size: 13, color: scheme.onSurfaceVariant),
                  style: TextStyle(color: scheme.onSurface, fontSize: 11),
                  items: const [
                    DropdownMenuItem<double?>(value: null, child: Text('Auto radius (5–10 km)')),
                    DropdownMenuItem<double?>(value: 5, child: Text('5 km')),
                    DropdownMenuItem<double?>(value: 10, child: Text('10 km')),
                  ],
                  onChanged: (v) {
                    notifier.setRadius(v);
                    notifier.loadGyms(radiusKm: v, clearRadius: v == null);
                  },
                ),
              ),
            ),
          ],
          const SizedBox(width: 8),
          _FilterPill(
            label: 'Verified only',
            active: state.verifiedOnly,
            onTap: () => notifier.loadGyms(verified: !state.verifiedOnly),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRail(
    BuildContext context,
    GymListState state,
    List<GymCategory> categories,
    GymListNotifier notifier,
  ) {
    return SizedBox(
      height: 32,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FilterPill(
            label: 'All',
            active: state.categoryFilter == null,
            onTap: () => notifier.loadGyms(clearCategory: true),
          ),
          for (final c in categories) ...[
            const SizedBox(width: 8),
            _FilterPill(
              label: c.displayName.toLowerCase(),
              active: state.categoryFilter == c.name,
              onTap: () => notifier.loadGyms(category: c.name),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildListSlivers(GymListState state) {
    if (state.isLoading) {
      return const [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: PageLoader(),
          ),
        ),
      ];
    }
    if (state.error != null) {
      return [
        SliverToBoxAdapter(
          child: ErrorView(
            message: state.error!,
            onRetry: () => ref.read(gymListProvider.notifier).loadGyms(),
          ),
        ),
      ];
    }
    if (state.gyms.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: _GymEmptyState(
            myGyms: state.myGyms,
            onCreate: () => context.push('/gyms/create'),
          ),
        ),
      ];
    }
    return [
      SliverList.builder(
        itemCount: state.gyms.length,
        itemBuilder: (_, i) {
          final gym = state.gyms[i];
          final canManage = gym.membershipRole == 'owner' || gym.membershipRole == 'co_owner';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GymCard(
                gym: gym,
                onTap: () => context.push('/gyms/${gym.handle}'),
              ),
              if (canManage)
                Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: OutlinedButton(
                    onPressed: () => context.push('/gyms/${gym.handle}/manage'),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    child: Text('Manage ${gym.name}'),
                  ),
                ),
            ],
          );
        },
      ),
    ];
  }
}

class _ScopeToggle extends StatelessWidget {
  final bool myGyms;
  final ValueChanged<bool> onChanged;

  const _ScopeToggle({required this.myGyms, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: BuddyColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _segment(context, 'Discover', !myGyms, () => onChanged(false)),
          _segment(context, 'My Gyms', myGyms, () => onChanged(true)),
        ],
      ),
    );
  }

  Widget _segment(BuildContext context, String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: active ? BuddyColors.green : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: active ? BuddyColors.black : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _FormatTabs extends ConsumerWidget {
  static const _formats = ['all', 'virtual', 'hybrid', 'physical'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gymListProvider);
    final notifier = ref.read(gymListProvider.notifier);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: BuddyColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (final f in _formats)
            Expanded(
              child: GestureDetector(
                onTap: () => notifier.loadGyms(format: f),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: state.formatFilter == f ? BuddyColors.green : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    f[0].toUpperCase() + f.substring(1),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: state.formatFilter == f
                          ? BuddyColors.black
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool active;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.active,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? BuddyColors.green : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? BuddyColors.green : scheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: active ? BuddyColors.black : scheme.onSurfaceVariant),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active ? BuddyColors.black : scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GymEmptyState extends StatelessWidget {
  final bool myGyms;
  final VoidCallback onCreate;

  const _GymEmptyState({required this.myGyms, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 32),
      child: Column(
        children: [
          Icon(LucideIcons.users, size: 48, color: scheme.onSurfaceVariant.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            myGyms ? "You haven't joined any gyms yet" : 'No gyms found',
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 16),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onCreate,
            child: const Text('Create a Gym'),
          ),
        ],
      ),
    );
  }
}

class _NearbyNotice extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gymListProvider);
    final geo = state.geo;
    // Virtual gyms ignore GPS, so never show the nearby banner there.
    if (state.formatFilter == 'virtual' ||
        state.lat == null ||
        geo == null ||
        !geo.auto ||
        geo.message == null) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: BuddyColors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BuddyColors.green.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.mapPin, size: 15, color: BuddyColors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nearby: ${geo.radiusKm.toStringAsFixed(0)} km · '
                  '${geo.density == 'dense' ? 'lots around you' : 'fewer around you'}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  geo.message!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
