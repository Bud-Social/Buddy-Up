import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../providers/feed_provider.dart';
import '../widgets/feed_tab_bar.dart';
import '../widgets/post_card.dart';
import '../widgets/share_sheet.dart';
import '../widgets/communities_tab.dart';
import '../../../shared/widgets/page_loader.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../core/analytics/analytics_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/navigation/main_header.dart';
import '../../../data/models/post.dart';
import '../../onboarding/walkthrough_overlay.dart';

class FeedScreen extends ConsumerStatefulWidget {
  final String initialTab;

  const FeedScreen({super.key, this.initialTab = 'for_you'});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _feedLoadedTracked = false;
  Timer? _newPostsTimer;
  final Set<String> _knownPostIds = <String>{};
  List<Post> _pendingNewPosts = <Post>[];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Share-a-replay lands here with a pending composer draft — open the
    // inline composer so the long_video draft restores visibly.
    ref.listenManual(composerExpandRequestProvider, (prev, next) {
      if (mounted && next > (prev ?? 0)) {
        // Share-a-replay stores a draft; the dedicated composer route restores
        // it. A full-screen composer avoids embedding a Scaffold in the feed.
        context.push('/create');
      }
    });
    Future.microtask(() {
      ref.read(feedProvider.notifier).loadFeed(tab: widget.initialTab);
      _startNewPostsPolling();
      _maybeShowWalkthrough();
    });
  }

  /// Web parity: onboarding lands on `/feed?walkthrough=1`, which shows the
  /// three-step walkthrough once. The param is stripped immediately so a
  /// rebuild or back-navigation never re-opens it.
  Future<void> _maybeShowWalkthrough() async {
    if (!mounted) return;
    final params = GoRouterState.of(context).uri.queryParameters;
    if (params['walkthrough'] != '1') return;
    if (!await shouldShowWalkthrough()) return;
    if (!mounted) return;
    context.replace('/feed');
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      pageBuilder: (dialogContext, _, _) =>
          WalkthroughOverlay(onClose: () => Navigator.of(dialogContext).pop()),
    );
  }

  void _startNewPostsPolling() {
    _newPostsTimer?.cancel();
    // X-style silent polling: detect fresh posts but never auto-insert them —
    // a pill lets the user jump to the newest when they choose to.
    _newPostsTimer = Timer.periodic(const Duration(seconds: 45), (_) async {
      if (!mounted) return;
      final tab = ref.read(feedProvider).activeTab;
      if (tab == 'videos' || tab == 'communities') return;
      try {
        final repo = ref.read(feedRepositoryProvider);
        final raw = await repo.getFeed(tab: tab);
        final incoming = (raw['data'] as List? ?? [])
            .map((e) => Post.fromJson(e as Map<String, dynamic>))
            .where((p) => !_knownPostIds.contains(p.id))
            .toList();
        if (incoming.isNotEmpty && mounted) {
          setState(() => _pendingNewPosts = [...incoming, ..._pendingNewPosts]);
        }
      } catch (_) {}
    });
  }

  void _showPendingNewPosts() {
    final notifier = ref.read(feedProvider.notifier);
    for (final p in _pendingNewPosts) {
      notifier.updatePostInList(p); // ensure known
    }
    notifier.prependPosts(_pendingNewPosts);
    _pendingNewPosts = [];
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
    setState(() {});
  }

  void _syncKnownIds(List<Post> posts) {
    for (final p in posts) {
      _knownPostIds.add(p.id);
    }
  }

  String _pathForTab(String tab) {
    switch (tab) {
      case 'videos':
        return '/feed/bud-press';
      case 'following':
        return '/feed/following';
      case 'communities':
        return '/feed/communities';
      default:
        return '/feed';
    }
  }

  void _onTabChanged(String tab) {
    AnalyticsService.instance.track(
      'feed.tab_selected',
      surface: 'feed',
      objectType: 'feed_tab',
      objectId: tab,
      properties: {'feed_tab': tab},
    );
    context.go(_pathForTab(tab));
  }

  @override
  void dispose() {
    _newPostsTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(feedProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(feedProvider);
    final notifier = ref.read(feedProvider.notifier);
    if (!_feedLoadedTracked && !state.isLoading && state.error == null) {
      // First frame after the initial load resolves successfully.
      _feedLoadedTracked = true;
      AnalyticsService.instance.track(
        'feed.loaded',
        surface: 'feed',
        objectType: 'feed_tab',
        objectId: state.activeTab,
        properties: {
          'feed_tab': state.activeTab,
          'post_count': state.posts.length,
        },
      );
    }
    final tabs = ['for_you', 'following', 'communities', 'videos'];

    return Scaffold(
      appBar: const MainAppBar(showLogo: true),
      body: Column(
        children: [
          FeedTabBar(
            activeTab: state.activeTab,
            tabs: tabs,
            onTabChanged: _onTabChanged,
          ),
          Expanded(
            child: state.activeTab == 'communities'
                ? const CommunitiesTab()
                : Column(
                    children: [
                      _buildComposerPrompt(),
                      Expanded(child: _buildBody(state, notifier)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  /// Web parity: the collapsed composer is a full-width rounded prompt at the
  /// top of the feed ("Share your workout, meal, or progress..."), not a FAB.
  Widget _buildComposerPrompt() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/create'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: BuddyColors.green.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.penLine,
                    size: 16,
                    color: BuddyColors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Share your workout, meal, or progress...',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(FeedState state, FeedNotifier notifier) {
    if (state.isLoading && state.posts.isEmpty) {
      return const PageLoader();
    }

    if (state.error != null && state.posts.isEmpty) {
      return ErrorView(
        message: state.error!,
        onRetry: () => notifier.loadFeed(),
      );
    }

    _syncKnownIds(state.posts);

    if (state.posts.isEmpty) {
      return RefreshIndicator(
        color: BuddyColors.green,
        onRefresh: () => notifier.refresh(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 120),
            Center(
              child: Column(
                children: [
                  const Icon(LucideIcons.inbox, size: 48, color: BuddyColors.textSecondary),
                  const SizedBox(height: 12),
                  Text(
                    state.activeTab == 'following'
                        ? 'No posts from people you follow yet'
                        : 'No posts yet',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.activeTab == 'following'
                        ? 'Follow people to see their posts here.'
                        : 'Pull to refresh.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: BuddyColors.green,
      onRefresh: () => notifier.refresh(),
      child: Column(
        children: [
          if (_pendingNewPosts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: BuddyColors.green.withValues(alpha: 0.15),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                onPressed: _showPendingNewPosts,
                icon: const Icon(
                  LucideIcons.arrowUp,
                  size: 14,
                  color: BuddyColors.green,
                ),
                label: Text(
                  '${_pendingNewPosts.length} new post${_pendingNewPosts.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: BuddyColors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 12),
              itemCount:
                  state.posts.length +
                  (state.isLoadingMore ? 1 : 0) +
                  (!state.hasMore && state.posts.isNotEmpty ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == state.posts.length && state.isLoadingMore) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final tailIndex =
                    state.posts.length + (state.isLoadingMore ? 1 : 0);
                if (!state.hasMore &&
                    state.posts.isNotEmpty &&
                    i == tailIndex) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 16,
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          LucideIcons.checkCircle,
                          size: 26,
                          color: BuddyColors.green,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "You're all caught up",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton.icon(
                          onPressed: () => notifier.refresh(),
                          icon: const Icon(
                            LucideIcons.arrowUp,
                            size: 15,
                            color: BuddyColors.green,
                          ),
                          label: const Text(
                            'Load latest posts',
                            style: TextStyle(
                              color: BuddyColors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                final post = state.posts[i];
                return PostCard(
                  post: post,
                  onComment: (id) => _navigateToPostDetail(id),
                  onReact: (id, reaction) => _handleReact(id, reaction),
                  onSave: (id) => _handleSave(id),
                  onRepost: (id) => _handleRepost(id),
                  onShare: (id) {
                    final matches = ref
                        .read(feedProvider)
                        .posts
                        .where((p) => p.id == id)
                        .toList();
                    if (matches.isNotEmpty) {
                      ShareSheet.show(context, matches.first);
                    }
                  },
                  onProfileTap: (username) => _navigateToProfile(username),
                  onPollVote: (id, optionIds) => _handlePollVote(id, optionIds),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPostDetail(String postId) {
    AnalyticsService.instance.track(
      'feed.post_opened',
      surface: 'feed',
      objectType: 'post',
      objectId: postId,
      properties: {'feed_tab': ref.read(feedProvider).activeTab},
    );
    context.push('/feed/$postId');
  }

  void _navigateToProfile(String? username) {
    if (username != null) {
      context.push('/$username');
    }
  }

  void _handleReact(String postId, String reaction) {
    final notifier = ref.read(feedProvider.notifier);
    if (reaction.isEmpty) {
      // PostCard uses an empty reaction to mean "remove my reaction".
      final post = ref
          .read(feedProvider)
          .posts
          .where((p) => p.id == postId)
          .firstOrNull;
      final current = post?.userReaction;
      if (current != null) {
        notifier.reactTo(postId, current);
      }
      return;
    }
    // The reaction endpoint returns a reaction_counts map, not a Post, so the
    // provider owns the optimistic update + rollback (same as the web client).
    notifier.reactTo(postId, reaction);
  }

  void _handleSave(String postId) {
    ref.read(feedProvider.notifier).toggleSaveById(postId);
  }

  void _handleRepost(String postId) {
    ref.read(feedProvider.notifier).toggleRepost(postId);
  }

  void _handlePollVote(String postId, List<String> optionIds) async {
    if (optionIds.isEmpty) return;
    final repo = ref.read(feedRepositoryProvider);
    try {
      final raw = await repo.voteOnPoll(postId, {'option_ids': optionIds});
      // The vote endpoint returns the refreshed Poll, not the parent Post.
      final data = raw['data'];
      if (data is Map<String, dynamic>) {
        final post = ref
            .read(feedProvider)
            .posts
            .where((p) => p.id == postId)
            .firstOrNull;
        if (post != null) {
          ref
              .read(feedProvider.notifier)
              .updatePostInList(post.copyWith(poll: Poll.fromJson(data)));
        }
      }
    } catch (_) {}
  }
}
