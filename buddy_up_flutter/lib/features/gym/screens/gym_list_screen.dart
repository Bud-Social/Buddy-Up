import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/gym_provider.dart';
import '../widgets/gym_card.dart';
import '../../../shared/widgets/page_loader.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/navigation/app_nav.dart';

class GymListScreen extends ConsumerStatefulWidget {
  const GymListScreen({super.key});

  @override
  ConsumerState<GymListScreen> createState() => _GymListScreenState();
}

class _GymListScreenState extends ConsumerState<GymListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(gymListProvider.notifier).loadGyms());
  }

  @override
  void dispose() {
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
                          notifier.loadGyms();
                        },
                      )
                    : null,
              ),
              onChanged: (v) {
                setState(() {});
                if (v.length > 2) {
                  notifier.loadGyms(query: v);
                } else if (v.isEmpty) {
                  notifier.loadGyms();
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
                        notifier.loadGyms(category: isAll ? null : categories[i - 1].name);
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
