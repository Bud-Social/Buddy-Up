import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/feed_provider.dart';
import '../widgets/feed_tab_bar.dart';
import '../widgets/post_card.dart';
import '../../community/providers/community_provider.dart';
import '../../../data/models/messaging.dart';
import '../../../shared/widgets/page_loader.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/navigation/app_nav.dart';
import '../../../data/models/post.dart';

class FeedScreen extends ConsumerStatefulWidget {
  final String initialTab;

  const FeedScreen({super.key, this.initialTab = 'for_you'});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final ScrollController _scrollController = ScrollController();
  Timer? _newPostsTimer;
  final Set<String> _knownPostIds = <String>{};
  List<Post> _pendingNewPosts = <Post>[];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() {
      ref.read(feedProvider.notifier).loadFeed(tab: widget.initialTab);
      _startNewPostsPolling();
    });
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
        final raw = await repo.getFeed(
          tab: tab,
          excludePostTypes: tab == 'for_you' ? 'meal' : null,
        );
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
      case 'meals':
        return '/feed/meals';
      case 'progress':
        return '/feed/progress';
      default:
        return '/feed';
    }
  }

  void _onTabChanged(String tab) {
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
    final communitiesAsync = ref.watch(communitiesListProvider);
    final myCommunities = communitiesAsync.value?.mine ?? [];
    final hasCommunities = myCommunities.isNotEmpty;
    final tabs = [
      'for_you',
      'following',
      if (hasCommunities) 'communities',
      'videos',
      'meals',
      'progress',
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          tooltip: 'Menu',
          onPressed: () => AppNav.open(context),
        ),
        title: const Text(
          'Buddy-Up',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          FeedTabBar(
            activeTab: state.activeTab,
            tabs: tabs,
            onTabChanged: _onTabChanged,
          ),
          Expanded(
            child: state.activeTab == 'communities'
                ? _buildCommunitiesTab(myCommunities)
                : _buildBody(state, notifier),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: BuddyColors.green,
        onPressed: () => _navigateToComposer(),
        child: const Icon(Icons.edit, color: BuddyColors.black),
      ),
    );
  }

  Widget _buildCommunitiesTab(List<Conversation> communities) {
    final cs = Theme.of(context).colorScheme;
    if (communities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.groups_outlined, size: 64, color: BuddyColors.textSecondary),
            const SizedBox(height: 16),
            const Text('No Communities Joined Yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Join a community to see posts and connect with peers.', style: TextStyle(color: BuddyColors.textSecondary)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.push('/communities'),
              child: const Text('Discover Communities'),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Your Communities (${communities.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            TextButton(
              onPressed: () => context.push('/communities'),
              child: const Text('View All', style: TextStyle(color: BuddyColors.green)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...communities.map((c) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: cs.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: cs.outlineVariant),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: cs.surfaceContainerHighest,
              backgroundImage: c.groupAvatarUrl.isNotEmpty ? NetworkImage(c.groupAvatarUrl) : null,
              child: c.groupAvatarUrl.isEmpty ? const Icon(Icons.groups, color: BuddyColors.green) : null,
            ),
            title: Text(c.groupName.isEmpty ? 'Community' : c.groupName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              c.description.isNotEmpty
                  ? c.description
                  : (c.lastMessage?.body.isNotEmpty == true
                      ? c.lastMessage!.body
                      : 'Tap to open community feed & chat'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6)),
            ),
            trailing: const Icon(Icons.chevron_right, color: BuddyColors.green),
            onTap: () => context.push('/communities/${c.id}'),
          ),
        )),
      ],
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: _showPendingNewPosts,
                icon: const Icon(Icons.arrow_upward, size: 14, color: BuddyColors.green),
                label: Text(
                  '${_pendingNewPosts.length} new post${_pendingNewPosts.length == 1 ? '' : 's'}',
                  style: const TextStyle(color: BuddyColors.green, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: state.posts.length + (state.isLoadingMore ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == state.posts.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final post = state.posts[i];
                return PostCard(
                  post: post,
                  onComment: (id) => _navigateToPostDetail(id),
                  onReact: (id, reaction) => _handleReact(id, reaction),
                  onSave: (id) => _handleSave(id),
                  onRepost: (id) => _handleRepost(id),
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

  void _navigateToComposer() {
    context.push('/feed/post');
  }

  void _navigateToPostDetail(String postId) {
    context.push('/feed/$postId');
  }

  void _navigateToProfile(String? username) {
    if (username != null) {
      context.push('/$username');
    }
  }

  void _handleReact(String postId, String reaction) async {
    if (reaction.isEmpty) return;
    final repo = ref.read(feedRepositoryProvider);
    try {
      final raw = await repo.react(postId, ReactionInput(reactionType: reaction));
      final updated = Post.fromJson(raw['data'] as Map<String, dynamic>);
      ref.read(feedProvider.notifier).updatePostInList(updated);
    } catch (_) {}
  }

  void _handleSave(String postId) async {
    final repo = ref.read(feedRepositoryProvider);
    final state = ref.read(feedProvider);
    final post = state.posts.firstWhere((p) => p.id == postId);
    try {
      if (post.isSaved) {
        await repo.unsave(postId);
      } else {
        await repo.save(postId, const SavePayload());
      }
      ref.read(feedProvider.notifier).updatePostInList(
        post.copyWith(isSaved: !post.isSaved),
      );
    } catch (_) {}
  }

  void _handleRepost(String postId) {
    ref.read(feedProvider.notifier).toggleRepost(postId);
  }

  void _handlePollVote(String postId, List<String> optionIds) async {
    if (optionIds.isEmpty) return;
    final repo = ref.read(feedRepositoryProvider);
    try {
      final raw = await repo.voteOnPoll(postId, {'option_ids': optionIds});
      if (raw['data'] != null) {
        final updated = Post.fromJson(raw['data'] as Map<String, dynamic>);
        ref.read(feedProvider.notifier).updatePostInList(updated);
      }
    } catch (_) {}
  }
}
