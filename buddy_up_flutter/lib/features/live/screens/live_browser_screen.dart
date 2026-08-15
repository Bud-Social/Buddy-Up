import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../providers/live_provider.dart';
import '../widgets/live_card.dart';
import '../../../shared/widgets/page_loader.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/constants.dart';
import '../../../shared/navigation/app_nav.dart';

class LiveBrowserScreen extends ConsumerStatefulWidget {
  const LiveBrowserScreen({super.key});

  @override
  ConsumerState<LiveBrowserScreen> createState() => _LiveBrowserScreenState();
}

class _LiveBrowserScreenState extends ConsumerState<LiveBrowserScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() => ref.read(liveBrowserProvider.notifier).browse());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(liveBrowserProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(liveBrowserProvider);
    final notifier = ref.read(liveBrowserProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          tooltip: 'Menu',
          onPressed: () => AppNav.open(context),
        ),
        title: const Text('Lives'),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () => context.push('/lives/create'),
          ),
          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: () => context.push('/lives/random-drop'),
            tooltip: 'Random Drop',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(state, notifier),
          _buildCategoryChips(state, notifier),
          Expanded(child: _buildBody(state)),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(LiveBrowserState state, LiveBrowserNotifier notifier) {
    final selected = state.category;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          _categoryChip('All', null, selected == null, () => notifier.setCategory(null)),
          ...liveCategories.map((c) => _categoryChip(
                c.replaceAll('_', ' '),
                c,
                selected == c,
                () => notifier.setCategory(c),
              )),
        ],
      ),
    );
  }

  Widget _categoryChip(String label, String? value, bool isActive, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(
        label[0].toUpperCase() + label.substring(1),
        style: TextStyle(
          fontSize: 12,
          color: isActive ? BuddyColors.black : BuddyColors.textSecondary,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isActive,
      onSelected: (_) => onTap(),
      selectedColor: BuddyColors.green,
      backgroundColor: BuddyColors.surface,
      side: BorderSide(color: isActive ? BuddyColors.green : BuddyColors.surfaceRaised),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildTabBar(LiveBrowserState state, LiveBrowserNotifier notifier) {
    final tabs = ['live', 'scheduled', 'replays', 'upcoming'];
    final labels = ['Live', 'Scheduled', 'Replays', 'Upcoming'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isActive = state.activeTab == tabs[i];
          return Expanded(
            child: GestureDetector(
              onTap: () => notifier.setTab(tabs[i]),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: isActive ? BuddyColors.green : Colors.transparent, width: 2),
                  ),
                ),
                child: Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isActive ? BuddyColors.textPrimary : BuddyColors.textSecondary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBody(LiveBrowserState state) {
    if (state.isLoading && state.lives.isEmpty) return const PageLoader();
    if (state.error != null) {
      return ErrorView(message: state.error!, onRetry: () => ref.read(liveBrowserProvider.notifier).browse());
    }
    if (state.lives.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.videocam_off, size: 48, color: BuddyColors.textSecondary),
            SizedBox(height: 12),
            Text('No lives found', style: TextStyle(color: BuddyColors.textSecondary)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: BuddyColors.green,
      onRefresh: () => ref.read(liveBrowserProvider.notifier).browse(),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: state.lives.length + (state.cursor != null ? 1 : 0),
        itemBuilder: (_, i) {
          if (i == state.lives.length) {
            return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
          }
          return LiveCard(
            live: state.lives[i],
            onTap: () => context.push('/lives/${state.lives[i].id}'),
            onRsvp: _handleRsvp,
          );
        },
      ),
    );
  }

  Future<void> _handleRsvp(String liveId) async {
    final repo = ref.read(liveRepositoryProvider);
    try {
      await repo.rsvp(liveId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('RSVP confirmed!')),
      );
      ref.read(liveBrowserProvider.notifier).browse();
    } on DioException catch (e) {
      final message = (e.response?.data as Map<String, dynamic>?)?['message'] as String? ??
          (e.response?.statusMessage ?? 'Failed to RSVP.');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$message')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to RSVP.')),
      );
    }
  }
}
