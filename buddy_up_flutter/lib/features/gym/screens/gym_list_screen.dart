import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../providers/gym_provider.dart';
import '../widgets/gym_card.dart';
import '../../../shared/widgets/page_loader.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/toast.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/navigation/app_nav.dart';

class GymListScreen extends ConsumerStatefulWidget {
  const GymListScreen({super.key});

  @override
  ConsumerState<GymListScreen> createState() => _GymListScreenState();
}

class _GymListScreenState extends ConsumerState<GymListScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(gymListProvider.notifier).loadGyms());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gymListProvider);
    final notifier = ref.read(gymListProvider.notifier);
    final categoriesAsync = ref.watch(gymCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          tooltip: 'Menu',
          onPressed: () => AppNav.open(context),
        ),
        title: const Text('Gyms'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: BuddyColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search gyms...',
                hintStyle: const TextStyle(color: BuddyColors.textSecondary),
                prefixIcon: const Icon(Icons.search, color: BuddyColors.textSecondary, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: BuddyColors.textSecondary, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _debounce?.cancel();
                          notifier.loadGyms(clearQuery: true);
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
            ),
          ),
          categoriesAsync.when(
            data: (categories) => SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length + 1,
                itemBuilder: (_, i) {
                  final isAll = i == 0;
                  final isActive = isAll
                      ? state.categoryFilter == null
                      : state.categoryFilter == categories[i - 1].name;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(isAll ? 'All' : categories[i - 1].displayName),
                      selected: isActive,
                      onSelected: (_) {
                        if (isAll) {
                          notifier.loadGyms(clearCategory: true);
                        } else {
                          notifier.loadGyms(category: categories[i - 1].name);
                        }
                      },
                      selectedColor: BuddyColors.green.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: isActive ? BuddyColors.green : BuddyColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
            loading: () => const SizedBox(height: 40),
            error: (_, _) => const SizedBox(height: 40),
          ),
          _FormatTabs(),
          _NearbyNotice(),
          const SizedBox(height: 8),
          Expanded(
            child: _buildBody(state),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: BuddyColors.green,
        onPressed: () => context.push('/gyms/create'),
        child: const Icon(Icons.add, color: BuddyColors.black),
      ),
    );
  }

  Widget _buildBody(GymListState state) {
    if (state.isLoading) return const PageLoader();
    if (state.error != null) {
      return ErrorView(message: state.error!, onRetry: () => ref.read(gymListProvider.notifier).loadGyms());
    }
    if (state.gyms.isEmpty) {
      return const Center(
        child: Text('No gyms found', style: TextStyle(color: BuddyColors.textSecondary)),
      );
    }
    return ListView.builder(
      itemCount: state.gyms.length,
      itemBuilder: (_, i) => GymCard(
        gym: state.gyms[i],
        onTap: () => context.push('/gyms/${state.gyms[i].handle}'),
      ),
    );
  }
}

class _FormatTabs extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gymListProvider);
    final notifier = ref.read(gymListProvider.notifier);
    const formats = ['all', 'virtual', 'hybrid', 'physical'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (final f in formats)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(f[0].toUpperCase() + f.substring(1)),
                  selected: state.formatFilter == f,
                  onSelected: (_) => notifier.loadGyms(format: f),
                  selectedColor: BuddyColors.green.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: state.formatFilter == f ? BuddyColors.green : BuddyColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          IconButton(
            icon: Icon(
              Icons.near_me,
              color: state.lat != null ? BuddyColors.green : BuddyColors.textSecondary,
            ),
            tooltip: state.lat != null ? 'Using your location' : 'Use my location',
            onPressed: () async {
              if (state.lat != null) {
                notifier.setCoords(null, null);
                notifier.loadGyms();
                return;
              }
              try {
                if (!await Geolocator.isLocationServiceEnabled()) {
                  if (context.mounted) {
                    showToast(context, 'Turn on location services to find nearby gyms.',
                        type: ToastType.error);
                  }
                  return;
                }
                var perm = await Geolocator.checkPermission();
                if (perm == LocationPermission.denied) {
                  perm = await Geolocator.requestPermission();
                }
                if (perm == LocationPermission.deniedForever) {
                  if (context.mounted) {
                    showToast(context, 'Location blocked — allow it in system settings.',
                        type: ToastType.error);
                  }
                  return;
                }
                if (perm == LocationPermission.denied) return;
                final pos = await Geolocator.getCurrentPosition(
                  locationSettings: const LocationSettings(timeLimit: Duration(seconds: 10)),
                );
                notifier.setCoords(pos.latitude, pos.longitude);
                notifier.loadGyms(lat: pos.latitude, lng: pos.longitude);
              } catch (_) {
                if (context.mounted) {
                  showToast(context, 'Could not get your location. Try again.',
                      type: ToastType.error);
                }
              }
            },
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
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
                  style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  geo.message!,
                  style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
