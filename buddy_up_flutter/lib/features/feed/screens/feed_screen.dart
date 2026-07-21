import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/feed_provider.dart';
import '../widgets/feed_tab_bar.dart';
import '../widgets/post_card.dart';
import '../../../shared/widgets/page_loader.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/post.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() => ref.read(feedProvider.notifier).loadFeed());
  }

  @override
  void dispose() {
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

    return Scaffold(
      appBar: AppBar(
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
            onTabChanged: (tab) => notifier.setTab(tab),
          ),
          Expanded(
            child: _buildBody(state, notifier),
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

    return RefreshIndicator(
      color: BuddyColors.green,
      onRefresh: () => notifier.refresh(),
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
            onPollVote: (id) => _handlePollVote(id),
          );
        },
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

  void _handleRepost(String postId) async {
    final repo = ref.read(feedRepositoryProvider);
    try {
      final raw = await repo.repost(postId, const RepostPayload());
      final newPost = Post.fromJson(raw['data'] as Map<String, dynamic>);
      ref.read(feedProvider.notifier).addPostToTop(newPost);
    } catch (_) {}
  }

  void _handlePollVote(String postId) async {
    final repo = ref.read(feedRepositoryProvider);
    try {
      final raw = await repo.voteOnPoll(postId, {});
      if (raw['data'] != null) {
        final updated = Post.fromJson(raw['data'] as Map<String, dynamic>);
        ref.read(feedProvider.notifier).updatePostInList(updated);
      }
    } catch (_) {}
  }
}
