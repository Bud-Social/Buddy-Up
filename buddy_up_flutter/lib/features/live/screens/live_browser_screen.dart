import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../providers/live_provider.dart';
import '../widgets/live_card.dart';
import '../../../shared/widgets/page_loader.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/constants.dart';
import '../../../shared/navigation/main_header.dart';

class LiveBrowserScreen extends ConsumerStatefulWidget {
  final String? initialCategory;

  const LiveBrowserScreen({super.key, this.initialCategory});

  @override
  ConsumerState<LiveBrowserScreen> createState() => _LiveBrowserScreenState();
}

class _LiveBrowserScreenState extends ConsumerState<LiveBrowserScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(
      () => ref
          .read(liveBrowserProvider.notifier)
          .browse(category: widget.initialCategory),
    );
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
      appBar: MainAppBar(
        title: 'Lives',
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.video),
            onPressed: () => context.push('/lives/create'),
            tooltip: 'Go live',
          ),
          IconButton(
            icon: const Icon(LucideIcons.shuffle),
            onPressed: () => context.push('/lives/random-drop'),
            tooltip: 'Random Drop',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(state, notifier),
          if (state.activeTab == 'replays') _buildReplayScopeSwitcher(state, notifier),
          _buildCategoryChips(state, notifier),
          Expanded(child: _buildBody(state)),
        ],
      ),
    );
  }

  Widget _buildReplayScopeSwitcher(LiveBrowserState state, LiveBrowserNotifier notifier) {
    if (state.activeTab != 'replays') return const SizedBox.shrink();
    final scope = state.replayScope;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          _replayScopeChip('All', null, scope != 'mine', () => notifier.setReplayScope(null)),
          _replayScopeChip('My Replays', 'mine', scope == 'mine', () => notifier.setReplayScope('mine')),
        ],
      ),
    );
  }

  Widget _replayScopeChip(String label, String? value, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? BuddyColors.green : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
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
          color: isActive ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.onSurfaceVariant,
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
    const tabs = <({String key, String label, IconData icon})>[
      (key: 'live', label: 'Live Now', icon: LucideIcons.radio),
      (key: 'scheduled', label: 'Upcoming', icon: LucideIcons.calendar),
      (key: 'replays', label: 'Replays', icon: LucideIcons.play),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isActive = state.activeTab == tabs[i].key;
          return Expanded(
            child: GestureDetector(
              onTap: () => notifier.setTab(tabs[i].key),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: isActive ? BuddyColors.green : Colors.transparent, width: 2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(tabs[i].icon, size: 14, color: isActive ? BuddyColors.green : Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(
                      tabs[i].label,
                      style: TextStyle(
                        color: isActive ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ],
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
      final emptyText = switch (state.activeTab) {
        'live' => 'No live sessions right now',
        'scheduled' => 'No upcoming lives',
        'replays' => state.replayScope == 'mine'
            ? 'No replays saved by you yet'
            : 'No replays yet',
        _ => 'No replays yet',
      };
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.videocam_off, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(emptyText, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text(
              state.activeTab == 'live'
                  ? 'Be the first to start a Buddy Live!'
                  : state.activeTab == 'scheduled'
                  ? 'Schedule a live session for your community.'
                  : 'End a live with "Save Replay" to create one.',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7), fontSize: 12),
            ),
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
          final live = state.lives[i];
          final replayProcessing =
              live.status == 'ended' && live.replaySaved && live.replayUrl.isEmpty;
          return LiveCard(
            live: live,
            onTap: replayProcessing ? null : () => context.push('/lives/${live.id}'),
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
        SnackBar(content: Text(message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to RSVP.')),
      );
    }
  }
}
