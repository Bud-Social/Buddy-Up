import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/feed_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/models/post.dart';
import '../../../core/api/api_client.dart';
import '../../../core/analytics/analytics_service.dart';
import '../../../core/cache/with_cache.dart';

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  final dio = ref.watch(apiClientProvider).dio;
  return FeedRepository(dio);
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final dio = ref.watch(apiClientProvider).dio;
  return ProfileRepository(dio);
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
      final raw = await withCache(ref as dynamic, cacheKey, () => _repository.getFeed(
        tab: t,
      ));
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
      final raw = await _repository.getFeed(
        tab: state.activeTab,
        cursor: state.cursor,
      );
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

  /// Insert fresh posts at the top of the feed (deduplicated), used by the
  /// "N new posts" pill so reading position is never disturbed automatically.
  void prependPosts(List<Post> incoming) {
    if (incoming.isEmpty) return;
    final known = state.posts.map((p) => p.id).toSet();
    final fresh = incoming.where((p) => !known.contains(p.id)).toList();
    if (fresh.isEmpty) return;
    state = state.copyWith(posts: [...fresh, ...state.posts]);
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

  /// Optimistic 💪 toggle with rollback (Bud Press rail + cards).
  Future<void> reactTo(String postId, String emoji) async {
    final idx = state.posts.indexWhere((p) => p.id == postId);
    if (idx == -1) return;
    final post = state.posts[idx];
    final counts = Map<String, int>.from(post.reactionCounts);
    if (post.userReaction == emoji) {
      counts[emoji] = (counts[emoji] ?? 1) - 1;
      if (counts[emoji]! <= 0) counts.remove(emoji);
      updatePostInList(post.copyWith(userReaction: null, reactionCounts: counts));
      try {
        await _repository.unreact(postId);
      } catch (_) {
        updatePostInList(post);
      }
      return;
    }
    final prev = post.userReaction;
    if (prev != null) {
      counts[prev] = (counts[prev] ?? 1) - 1;
      if (counts[prev]! <= 0) counts.remove(prev);
    }
    counts[emoji] = (counts[emoji] ?? 0) + 1;
    updatePostInList(post.copyWith(userReaction: emoji, reactionCounts: counts));
    try {
      await _repository.react(postId, ReactionInput(reactionType: emoji));
    } catch (_) {
      updatePostInList(post);
    }
  }

  /// Optimistic save toggle with rollback.
  Future<void> toggleSaveById(String postId) async {
    final idx = state.posts.indexWhere((p) => p.id == postId);
    if (idx == -1) return;
    final post = state.posts[idx];
    updatePostInList(post.copyWith(
      isSaved: !post.isSaved,
      saveCount: (post.saveCount + (post.isSaved ? -1 : 1)).clamp(0, 999999),
    ));
    try {
      if (post.isSaved) {
        await _repository.unsave(postId);
      } else {
        await _repository.save(postId, const SavePayload());
      }
    } catch (_) {
      updatePostInList(post);
    }
  }

  /// Record a share; count updates only on success.
  Future<void> recordShareById(String postId) async {
    final idx = state.posts.indexWhere((p) => p.id == postId);
    if (idx == -1) return;
    try {
      final raw = await _repository.sharePost(postId, {'channel': 'copy'});
      final count = (raw['data'] as Map<String, dynamic>?)?['share_count'] as int?;
      if (count != null) {
        updatePostInList(state.posts[idx].copyWith(shareCount: count));
      }
    } catch (_) {}
  }

  /// Share with a channel; returns the referral code for tracked links.
  Future<String?> shareWithCode(String postId, String channel) async {
    try {
      final raw = await _repository.sharePost(postId, {'channel': channel});
      final data = raw['data'] as Map<String, dynamic>?;
      final count = data?['share_count'] as int?;
      if (count != null) {
        final idx = state.posts.indexWhere((p) => p.id == postId);
        if (idx != -1) {
          updatePostInList(state.posts[idx].copyWith(shareCount: count));
        }
      }
      return data?['code'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// Record a qualified view; count updates only on success.
  Future<void> recordViewById(String postId) async {
    final idx = state.posts.indexWhere((p) => p.id == postId);
    if (idx == -1) return;
    try {
      final raw = await _repository.recordView(postId);
      final count = (raw['data'] as Map<String, dynamic>?)?['view_count'] as int?;
      if (count != null) {
        updatePostInList(state.posts[idx].copyWith(viewCount: count));
      }
    } catch (_) {}
  }

  Future<void> toggleRepost(String postId) async {    final idx = state.posts.indexWhere((p) => p.id == postId);
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

  // ---------------------------------------------------------------------------
  // Bud Press parity: hide / mute / block / report (all optimistic + rollback).
  //
  // Every method returns null on success or a user-facing error message.
  // The hide/mute backends are rolling out in parallel: a 404 restores the
  // list (the post is NOT removed) and surfaces the server message so the
  // caller can toast it.
  // ---------------------------------------------------------------------------

  /// Valid `reason` values for [submitReport] (backend
  /// ModerationReport.REPORT_REASONS).
  static const reportReasons = <String>[
    'spam',
    'harassment',
    'hate_speech',
    'nudity',
    'adult_ungated',
    'violence',
    'misinformation',
    'impersonation',
    'other',
  ];

  String _actionError(Object e, String fallback) {
    if (e is DioException) {
      final data = e.response?.data;
      String? server;
      if (data is Map) {
        final direct = data['message'] ?? data['detail'];
        if (direct is String && direct.isNotEmpty) {
          server = direct;
        } else if (data['data'] is Map) {
          final nested = (data['data'] as Map)['message'];
          if (nested is String && nested.isNotEmpty) server = nested;
        }
      }
      if (e.response?.statusCode == 404) {
        return server ?? 'Not available on the server yet — please update.';
      }
      return server ?? fallback;
    }
    return fallback;
  }

  /// Hide a post ("Not interested"): removes the card optimistically and
  /// restores it at its original position on failure.
  Future<String?> hidePostById(String postId) async {
    final idx = state.posts.indexWhere((p) => p.id == postId);
    if (idx == -1) return 'Post not found.';
    final snapshot = state.posts;
    state = state.copyWith(
      posts: snapshot.where((p) => p.id != postId).toList(),
    );
    try {
      await _repository.hidePost(postId);
      AnalyticsService.instance.track(
        'feed.post_hidden',
        surface: 'feed',
        objectType: 'post',
        objectId: postId,
      );
      return null;
    } catch (e) {
      state = state.copyWith(posts: snapshot);
      return _actionError(e, 'Could not hide this post.');
    }
  }

  /// Undo a hide: unhides server-side, then re-inserts the card on top.
  Future<String?> unhidePost(Post post) async {
    try {
      await _repository.unhidePost(post.id);
    } catch (e) {
      return _actionError(e, 'Could not undo.');
    }
    if (!state.posts.any((p) => p.id == post.id)) {
      addPostToTop(post);
    }
    return null;
  }

  /// Mute an author ("Don't suggest this creator"): removes all of their
  /// cards optimistically, restores the snapshot on failure.
  Future<String?> muteAuthor(String username) async {
    final snapshot = state.posts;
    state = state.copyWith(
      posts: snapshot.where((p) => p.authorData.username != username).toList(),
    );
    try {
      await _repository.muteUser(username);
      AnalyticsService.instance.track(
        'feed.author_muted',
        surface: 'feed',
        objectType: 'profile',
        objectId: username,
      );
      return null;
    } catch (e) {
      state = state.copyWith(posts: snapshot);
      return _actionError(e, 'Could not mute @$username.');
    }
  }

  Future<String?> unmuteAuthor(String username) async {
    try {
      await _repository.unmuteUser(username);
      return null;
    } catch (e) {
      return _actionError(e, 'Could not unmute @$username.');
    }
  }

  /// Block an author: blocks server-side, then removes all of their cards.
  /// Restores the snapshot on failure.
  Future<String?> blockAuthor(String username) async {
    final snapshot = state.posts;
    state = state.copyWith(
      posts: snapshot.where((p) => p.authorData.username != username).toList(),
    );
    try {
      await ref.read(profileRepositoryProvider).blockUser(username);
      AnalyticsService.instance.track(
        'feed.author_blocked',
        surface: 'feed',
        objectType: 'profile',
        objectId: username,
      );
      return null;
    } catch (e) {
      state = state.copyWith(posts: snapshot);
      return _actionError(e, 'Could not block @$username.');
    }
  }

  /// File a moderation report against the post's author.
  Future<String?> submitReport({
    required String targetUser,
    required String reason,
    String description = '',
    String? contentUrl,
  }) async {
    try {
      await _repository.submitModerationReport({
        'target_user': targetUser,
        'reason': reason,
        'description': description,
        if (contentUrl != null && contentUrl.isNotEmpty)
          'content_url': contentUrl,
      });
      AnalyticsService.instance.track(
        'feed.post_reported',
        surface: 'feed',
        objectType: 'profile',
        objectId: targetUser,
        properties: {'reason': reason},
      );
      return null;
    } catch (e) {
      return _actionError(e, 'Could not submit your report.');
    }
  }

  /// Optimistic 💪 toggle that targets the engagement id: on repost rows the
  /// reaction state lives on the ORIGINAL post data while [rowId] locates the
  /// visible row. Rolls back on failure.
  Future<void> toggleReactionForRow({
    required String rowId,
    required String targetId,
    required String emoji,
  }) async {
    final idx = state.posts.indexWhere((p) => p.id == rowId);
    if (idx == -1) return;
    final row = state.posts[idx];
    final orig = row.originalPostData;
    final target = (row.isRepost && orig != null) ? orig : null;
    final current = target?.userReaction ?? row.userReaction;
    final counts = Map<String, int>.from(
      target?.reactionCounts ?? row.reactionCounts,
    );
    String? next;
    if (current == emoji) {
      counts[emoji] = (counts[emoji] ?? 1) - 1;
      if (counts[emoji]! <= 0) counts.remove(emoji);
      next = null;
    } else {
      if (current != null) {
        counts[current] = (counts[current] ?? 1) - 1;
        if (counts[current]! <= 0) counts.remove(current);
      }
      counts[emoji] = (counts[emoji] ?? 0) + 1;
      next = emoji;
    }
    final patched = target != null
        ? row.copyWith(
            originalPostData:
                target.copyWith(userReaction: next, reactionCounts: counts),
          )
        : row.copyWith(userReaction: next, reactionCounts: counts);
    updatePostInList(patched);
    try {
      if (next == null) {
        await _repository.unreact(targetId);
      } else {
        await _repository.react(targetId, ReactionInput(reactionType: emoji));
      }
      AnalyticsService.instance.track(
        'feed.post_interaction',
        surface: 'feed',
        objectType: 'post',
        objectId: targetId,
        properties: {'action': next == null ? 'unlike' : 'like'},
      );
    } catch (_) {
      updatePostInList(row);
    }
  }

  /// Post a comment with focus/submit analytics. Returns null on success or a
  /// user-facing error message.
  Future<String?> submitComment(String postId, String body) async {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return 'Write something first.';
    try {
      await _repository.addComment(postId, CommentCreateInput(body: trimmed));
      AnalyticsService.instance.track(
        'feed.comment_submitted',
        surface: 'feed',
        objectType: 'post',
        objectId: postId,
      );
      return null;
    } catch (e) {
      return _actionError(e, 'Could not post your comment.');
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
