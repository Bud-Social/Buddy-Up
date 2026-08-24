import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/feed_repository.dart';
import '../../../data/models/post.dart';
import '../../../core/api/api_client.dart';
import '../../../core/cache/with_cache.dart';

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  final dio = ref.watch(apiClientProvider).dio;
  return FeedRepository(dio);
});

final apiClientProvider = Provider<ApiClient>((_) => ApiClient());

List<Post> _parsePostList(dynamic data) =>
    (data as List).map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
List<Comment> _parseCommentList(dynamic data) =>
    (data as List).map((e) => Comment.fromJson(e as Map<String, dynamic>)).toList();

class FeedState {
  final List<Post> posts;
  final String activeTab;
  final bool isLoading;
  final bool isLoadingMore;
  final String? cursor;
  final bool hasMore;
  final String? error;

  const FeedState({
    this.posts = const [],
    this.activeTab = 'for_you',
    this.isLoading = false,
    this.isLoadingMore = false,
    this.cursor,
    this.hasMore = true,
    this.error,
  });

  FeedState copyWith({
    List<Post>? posts,
    String? activeTab,
    bool? isLoading,
    bool? isLoadingMore,
    String? cursor,
    bool? hasMore,
    String? error,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      activeTab: activeTab ?? this.activeTab,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      cursor: cursor ?? this.cursor,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
    );
  }
}

class FeedNotifier extends Notifier<FeedState> {
  @override
  FeedState build() => const FeedState();

  FeedRepository get _repository => ref.read(feedRepositoryProvider);

  Future<void> loadFeed({String? tab}) async {
    final t = tab ?? state.activeTab;
    state = state.copyWith(isLoading: true, error: null, activeTab: t);
    try {
      final cacheKey = 'feed_$t';
      final raw = await withCache(ref as dynamic, cacheKey, () => _repository.getFeed(tab: t));
      final data = raw['data'];
      final pagination = raw['pagination'] as Map<String, dynamic>?;
      state = state.copyWith(
        posts: _parsePostList(data),
        isLoading: false,
        cursor: _extractCursor(pagination?['next'] as String?),
        hasMore: pagination?['next'] != null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final raw = await _repository.getFeed(tab: state.activeTab, cursor: state.cursor);
      final data = raw['data'];
      final pagination = raw['pagination'] as Map<String, dynamic>?;
      state = state.copyWith(
        posts: [...state.posts, ..._parsePostList(data)],
        isLoadingMore: false,
        cursor: _extractCursor(pagination?['next'] as String?),
        hasMore: pagination?['next'] != null,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(cursor: null, hasMore: true);
    await loadFeed();
  }

  void setTab(String tab) {
    if (tab != state.activeTab) {
      state = state.copyWith(posts: [], cursor: null, hasMore: true);
      loadFeed(tab: tab);
    }
  }

  void updatePostInList(Post updated) {
    state = state.copyWith(
      posts: state.posts.map((p) => p.id == updated.id ? updated : p).toList(),
    );
  }

  void removePostFromList(String postId) {
    state = state.copyWith(
      posts: state.posts.where((p) => p.id != postId).toList(),
    );
  }

  void addPostToTop(Post post) {
    state = state.copyWith(posts: [post, ...state.posts]);
  }

  String? _extractCursor(String? url) {
    if (url == null) return null;
    final uri = Uri.tryParse(url);
    return uri?.queryParameters['cursor'];
  }

  Future<void> toggleRepost(String postId) async {
    final idx = state.posts.indexWhere((p) => p.id == postId);
    if (idx == -1) return;
    
    final post = state.posts[idx];
    final isReposted = post.isRepostedByMe;
    
    // Optimistic update
    final updated = post.copyWith(
      isRepostedByMe: !isReposted,
      repostCount: (post.repostCount + (isReposted ? -1 : 1)).clamp(0, 999999),
    );
    updatePostInList(updated);
    
    try {
      final res = await _repository.repost(postId, const RepostPayload());
      if (res['repost_count'] != null) {
        updatePostInList(updated.copyWith(repostCount: res['repost_count'] as int));
      }
    } catch (e) {
      // Rollback
      updatePostInList(post);
    }
  }
}

final feedProvider = NotifierProvider<FeedNotifier, FeedState>(FeedNotifier.new);

final postDetailProvider = FutureProvider.family<Post, String>((ref, postId) async {
  final repo = ref.watch(feedRepositoryProvider);
  final raw = await repo.getPost(postId);
  return Post.fromJson(raw['data'] as Map<String, dynamic>);
});

final commentsProvider = FutureProvider.family<List<Comment>, String>((ref, postId) async {
  final repo = ref.watch(feedRepositoryProvider);
  final raw = await repo.getComments(postId);
  return _parseCommentList(raw['data']);
});
