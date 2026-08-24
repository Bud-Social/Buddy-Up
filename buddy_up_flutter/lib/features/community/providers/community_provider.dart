import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/messaging.dart';
import '../../messaging/providers/messaging_provider.dart' show messagingRepositoryProvider;

final communityRepositoryProvider = messagingRepositoryProvider;

List<Conversation> _parseConvList(dynamic data) =>
    (data as List).map((e) => Conversation.fromJson(e as Map<String, dynamic>)).toList();

List<CommunityPost> _parsePostList(dynamic data) =>
    (data as List).map((e) => CommunityPost.fromJson(e as Map<String, dynamic>)).toList();

class CommunitiesListState {
  final List<Conversation> mine;
  final List<Conversation> discover;
  final bool isLoading;
  final String? error;

  const CommunitiesListState({
    this.mine = const [],
    this.discover = const [],
    this.isLoading = false,
    this.error,
  });

  CommunitiesListState copyWith({
    List<Conversation>? mine,
    List<Conversation>? discover,
    bool? isLoading,
    String? error,
  }) {
    return CommunitiesListState(
      mine: mine ?? this.mine,
      discover: discover ?? this.discover,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class CommunitiesListNotifier extends AsyncNotifier<CommunitiesListState> {
  @override
  Future<CommunitiesListState> build() async {
    final raw = await ref.read(communityRepositoryProvider).getCommunities();
    final data = raw['data'] as Map<String, dynamic>;
    return CommunitiesListState(
      mine: _parseConvList(data['mine']),
      discover: _parseConvList(data['discover']),
      isLoading: false,
    );
  }

  Future<void> refresh() async {
    try {
      final raw = await ref.read(communityRepositoryProvider).getCommunities();
      final data = raw['data'] as Map<String, dynamic>;
      state = AsyncValue.data(CommunitiesListState(
        mine: _parseConvList(data['mine']),
        discover: _parseConvList(data['discover']),
        isLoading: false,
      ));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<CommunityDetail?> joinByCode(String inviteCode) async {
    final raw = await ref.read(communityRepositoryProvider).joinCommunityByCode({'invite_code': inviteCode});
    await refresh();
    return CommunityDetail.fromJson(raw['data'] as Map<String, dynamic>);
  }

  Future<CommunityDetail?> create(
    String name, {
    String description = '',
    bool isPublic = true,
    String? groupAvatarUrl,
  }) async {
    final raw = await ref.read(communityRepositoryProvider).createCommunity({
      'name': name,
      'description': description,
      'is_public': isPublic,
      if (groupAvatarUrl != null && groupAvatarUrl.isNotEmpty) 'group_avatar_url': groupAvatarUrl,
    });
    await refresh();
    return CommunityDetail.fromJson(raw['data'] as Map<String, dynamic>);
  }
}

final communitiesListProvider =
    AsyncNotifierProvider<CommunitiesListNotifier, CommunitiesListState>(
  CommunitiesListNotifier.new,
);

class CommunityFeedState {
  final CommunityDetail? detail;
  final List<CommunityPost> posts;
  final bool isLoading;
  final String? error;

  const CommunityFeedState({this.detail, this.posts = const [], this.isLoading = false, this.error});

  CommunityFeedState copyWith({
    CommunityDetail? detail,
    List<CommunityPost>? posts,
    bool? isLoading,
    String? error,
  }) {
    return CommunityFeedState(
      detail: detail ?? this.detail,
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class CommunityFeedNotifier extends AsyncNotifier<CommunityFeedState> {
  final String communityId;

  CommunityFeedNotifier(this.communityId);

  @override
  Future<CommunityFeedState> build() async {
    final raw = await ref.read(communityRepositoryProvider).getCommunity(communityId);
    final detail = CommunityDetail.fromJson(raw['data'] as Map<String, dynamic>);
    return CommunityFeedState(detail: detail);
  }

  Future<void> refresh() async {
    final raw = await ref.read(communityRepositoryProvider).getCommunity(communityId);
    final detail = CommunityDetail.fromJson(raw['data'] as Map<String, dynamic>);
    state = AsyncValue.data(CommunityFeedState(detail: detail));
  }

  Future<void> loadPosts() async {
    try {
      final raw = await ref.read(communityRepositoryProvider).getCommunityPosts(communityId);
      state = AsyncValue.data((state.value ?? const CommunityFeedState()).copyWith(
        posts: _parsePostList(raw['data']),
      ));
    } catch (e) {
      state = AsyncValue.data((state.value ?? const CommunityFeedState()).copyWith(error: e.toString()));
    }
  }

  Future<void> createPost(String body, {String mediaUrl = ''}) async {
    final payload = <String, dynamic>{'body': body};
    if (mediaUrl.isNotEmpty) payload['media_url'] = mediaUrl;
    await ref.read(communityRepositoryProvider).createCommunityPost(communityId, payload);
    await loadPosts();
  }

  Future<void> updatePost(String postId, Map<String, dynamic> body) async {
    await ref.read(communityRepositoryProvider).updateCommunityPost(communityId, postId, body);
    await loadPosts();
  }

  Future<void> deletePost(String postId) async {
    await ref.read(communityRepositoryProvider).deleteCommunityPost(communityId, postId);
    await loadPosts();
  }

  Future<void> updateSettings(
    String name,
    String description,
    bool isPublic, {
    String? groupAvatarUrl,
  }) async {
    await ref.read(communityRepositoryProvider).updateCommunity(communityId, {
      'name': name,
      'description': description,
      'is_public': isPublic,
      if (groupAvatarUrl != null && groupAvatarUrl.isNotEmpty) 'group_avatar_url': groupAvatarUrl,
    });
    await refresh();
  }

  Future<void> rotateInvite() async {
    await ref.read(communityRepositoryProvider).rotateInviteCode(communityId);
    await refresh();
  }

  Future<void> toggleLike(String postId) async {
    await ref.read(communityRepositoryProvider).togglePostLike(communityId, postId);
    await loadPosts();
  }

  Future<void> addComment(String postId, String body) async {
    await ref.read(communityRepositoryProvider).addPostComment(communityId, postId, {'body': body});
    await loadPosts();
  }

  Future<void> join() async {
    await ref.read(communityRepositoryProvider).joinCommunity(communityId, {});
    await refresh();
  }

  Future<void> leave() async {
    await ref.read(communityRepositoryProvider).leaveCommunity(communityId);
  }

  Future<void> setRole(String userId, String role) async {
    await ref.read(communityRepositoryProvider).setCommunityRole(communityId, userId, {'role': role});
    await refresh();
  }

  Future<void> transferOwnership(String userId) async {
    await ref.read(communityRepositoryProvider).transferCommunityOwnership(communityId, {'user_id': userId});
    await refresh();
  }

  Future<void> removeMember(String userId) async {
    await ref.read(communityRepositoryProvider).removeCommunityMember(communityId, userId);
    await refresh();
  }

  bool get canManage {
    final role = state.value?.detail?.myRole ?? state.value?.detail?.membershipRole;
    return role == 'owner' || role == 'admin';
  }
}

final communityFeedProvider =
    AsyncNotifierProvider.family<CommunityFeedNotifier, CommunityFeedState, String>(
  CommunityFeedNotifier.new,
);