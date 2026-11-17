import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../data/models/gym_insights.dart';
import '../../../data/models/post.dart';
import '../../messaging/providers/messaging_provider.dart';
import 'gym_provider.dart';

/// Providers for the privileged surfaces of the gym management console:
/// sessions, messages, communities and the rich analytics panel.
///
/// Decoding is defensive — a payload that does not match the backend's
/// envelope degrades to the model's zeros rather than a thrown panel.
final gymSessionsProvider =
    FutureProvider.family<GymSessionsData, String>((ref, slug) async {
  final raw = await ref.read(gymRepositoryProvider).getGymSessions(slug);
  return GymSessionsData.fromJson(_payload(raw));
});

final gymMessagesProvider =
    FutureProvider.family<GymMessagesData, String>((ref, slug) async {
  final raw = await ref.read(gymRepositoryProvider).getGymMessages(slug);
  return GymMessagesData.fromJson(_payload(raw));
});

final gymCommunitiesProvider =
    FutureProvider.family<GymCommunitiesData, String>((ref, slug) async {
  final raw = await ref.read(gymRepositoryProvider).getGymCommunities(slug);
  return GymCommunitiesData.fromJson(_payload(raw));
});

final gymAnalyticsProvider =
    FutureProvider.family<GymAnalyticsData, String>((ref, slug) async {
  final raw = await ref.read(gymRepositoryProvider).getGymAnalytics(slug);
  return GymAnalyticsData.fromJson(_payload(raw));
});

/// The gym-linked community actions (create / link / unlink). The caller
/// re-reads [gymCommunitiesProvider] after a successful mutation.
class GymCommunityActions {
  final Ref ref;
  const GymCommunityActions(this.ref);

  Future<Map<String, dynamic>> createCommunity(
    String slug, {
    required String name,
    String description = '',
    bool isPublic = true,
  }) async {
    final raw = await ref.read(gymRepositoryProvider).manageGymCommunity(
      slug,
      {
        'action': 'create',
        'name': name,
        'description': description,
        'is_public': isPublic,
      },
    ) as Map<String, dynamic>;
    return _payload(raw);
  }

  Future<Map<String, dynamic>> linkCommunity(String slug, String communityId) async {
    final raw = await ref.read(gymRepositoryProvider).manageGymCommunity(
      slug,
      {'action': 'link', 'community_id': communityId},
    ) as Map<String, dynamic>;
    return _payload(raw);
  }

  Future<void> unlinkCommunity(String slug, String communityId) =>
      ref.read(gymRepositoryProvider).unlinkGymCommunity(
        slug,
        {'community_id': communityId},
      );
}

final gymCommunityActionsProvider =
    Provider<GymCommunityActions>((ref) => GymCommunityActions(ref));

Map<String, dynamic> _payload(dynamic raw) {
  if (raw is Map<String, dynamic>) {
    final data = raw['data'];
    if (data is Map<String, dynamic>) return data;
    return raw;
  }
  return <String, dynamic>{};
}

// ---------------------------------------------------------------------------
// Contained gym inbox — gym ↔ members / team / clients, no redirect into
// the acting owner's personal DMs. Direct use of the API client keeps the
// surface symmetric with the community settings screens' Dio usage.
// ---------------------------------------------------------------------------

class GymInboxMember {
  final String userId;
  final String username;
  final String displayName;
  final String avatarUrl;

  const GymInboxMember({
    this.userId = '',
    this.username = '',
    this.displayName = '',
    this.avatarUrl = '',
  });

  factory GymInboxMember.fromJson(Map<String, dynamic> json) => GymInboxMember(
        userId: json['user_id']?.toString() ?? '',
        username: json['username']?.toString() ?? '',
        displayName: json['display_name']?.toString() ?? '',
        avatarUrl: json['avatar_url']?.toString() ?? '',
      );

  String get name => displayName.isNotEmpty ? displayName : username;
}

class GymInboxConversation {
  final String id;
  final String conversationKind; // 'member' | 'team' | 'client'
  final String groupName;
  final String groupAvatarUrl;
  final String gymName;
  final int memberCount;
  final List<GymInboxMember> participants;
  final GymInboxMember? audienceMember;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  const GymInboxConversation({
    this.id = '',
    this.conversationKind = 'member',
    this.groupName = '',
    this.groupAvatarUrl = '',
    this.gymName = '',
    this.memberCount = 0,
    this.participants = const [],
    this.audienceMember,
    this.lastMessage = '',
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  bool get isTeam => conversationKind == 'team';
  String get label => isTeam ? (groupName.isNotEmpty ? groupName : 'Team') : (audienceMember?.name.isNotEmpty == true ? audienceMember!.name : 'Member');
  String get avatarUrl => isTeam ? groupAvatarUrl : (audienceMember?.avatarUrl ?? '');

  factory GymInboxConversation.fromJson(Map<String, dynamic> json) {
    final participants = (json['participants'] as List<dynamic>?)
            ?.whereType<Map>()
            .map((row) => GymInboxMember.fromJson(Map<String, dynamic>.from(row)))
            .toList() ??
        const <GymInboxMember>[];
    final audience = json['audience_member'];
    final audienceMember = audience is Map ? GymInboxMember.fromJson(Map<String, dynamic>.from(audience)) : null;
    return GymInboxConversation(
      id: json['id']?.toString() ?? '',
      conversationKind: json['conversation_kind']?.toString() ?? 'member',
      groupName: json['group_name']?.toString() ?? '',
      groupAvatarUrl: json['group_avatar_url']?.toString() ?? '',
      gymName: json['gym_name']?.toString() ?? '',
      memberCount: (json['member_count'] as num?)?.toInt() ?? 0,
      participants: participants,
      audienceMember: audienceMember,
      lastMessage: json['last_message']?.toString() ?? '',
      lastMessageAt: DateTime.tryParse(json['last_message_at']?.toString() ?? ''),
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class GymInboxMessage {
  final String id;
  final String senderUsername;
  final String senderDisplay;
  final String body;
  final DateTime? createdAt;
  final bool isMine;

  const GymInboxMessage({
    this.id = '',
    this.senderUsername = '',
    this.senderDisplay = '',
    this.body = '',
    this.createdAt,
    this.isMine = false,
  });

  factory GymInboxMessage.fromJson(Map<String, dynamic> json) => GymInboxMessage(
        id: json['id']?.toString() ?? '',
        senderUsername: json['sender_username']?.toString() ?? '',
        senderDisplay: json['sender_display']?.toString() ?? '',
        body: json['body']?.toString() ?? '',
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      );
}

final gymInboxProvider = FutureProvider.family<List<GymInboxConversation>, String>((ref, slug) async {
  final dio = ref.read(apiClientProvider4).dio;
  final res = await dio.get('/gyms/$slug/inbox/');
  final payload = res.data is Map<String, dynamic>
      ? (res.data as Map<String, dynamic>)['data']
      : res.data;
  final rows = payload is Map<String, dynamic> ? payload['conversations'] : null;
  if (rows is! List) return const <GymInboxConversation>[];
  return rows
      .whereType<Map>()
      .map((row) => GymInboxConversation.fromJson(Map<String, dynamic>.from(row)))
      .toList();
});

/// A post the gym saved, with the community routing metadata the web console
/// carries alongside the PostSerializer shape. Feed posts have [communityId]
/// null; community posts route their engagement through the gym endpoints.
class GymSavedPost {
  final Post post;
  final String? communityId;
  final String? communityName;

  const GymSavedPost({required this.post, this.communityId, this.communityName});

  factory GymSavedPost.fromJson(Map<String, dynamic> json) {
    final communityId = json['community_id']?.toString();
    final communityName = json['community_name']?.toString();
    return GymSavedPost(
      post: Post.fromJson(json),
      communityId: communityId == null || communityId.isEmpty ? null : communityId,
      communityName: communityName?.isEmpty == true ? null : communityName,
    );
  }
}

/// Posts the gym has saved — newest first, from `/gyms/<slug>/feed/saved/`.
/// The payload matches the feed serializer shape plus `community_id` /
/// `community_name` for community posts saved by the gym.
final gymSavedFeedProvider = FutureProvider.family<List<GymSavedPost>, String>((ref, slug) async {
  final dio = ref.read(apiClientProvider4).dio;
  final res = await dio.get('/gyms/$slug/feed/saved/');
  final payload = res.data is Map<String, dynamic>
      ? (res.data as Map<String, dynamic>)['data']
      : res.data;
  final rows = payload is Map<String, dynamic> ? payload['items'] : null;
  if (rows is! List) return const <GymSavedPost>[];
  return rows
      .whereType<Map>()
      .map((row) => GymSavedPost.fromJson(Map<String, dynamic>.from(row)))
      .toList();
});

final gymInboxMessagesProvider =
    FutureProvider.family<List<GymInboxMessage>, ({String slug, String conversationId})>((ref, args) async {
  final dio = ref.read(apiClientProvider4).dio;
  final res = await dio.get('/gyms/${args.slug}/inbox/${args.conversationId}/messages/');
  final payload = res.data is Map<String, dynamic>
      ? (res.data as Map<String, dynamic>)['data']
      : res.data;
  final rows = payload is Map<String, dynamic> ? payload['messages'] : null;
  if (rows is! List) return const <GymInboxMessage>[];
  String? viewer;
  try {
    final me = await dio.get('/profiles/me/');
    final mePayload = me.data is Map<String, dynamic>
        ? (me.data as Map<String, dynamic>)['data']
        : me.data;
    final meMap = mePayload is Map<String, dynamic> ? mePayload : const <String, dynamic>{};
    viewer = meMap['username'] as String?;
  } catch (_) {
    viewer = null;
  }
  return rows
      .whereType<Map>()
      .map((row) {
        final message = GymInboxMessage.fromJson(Map<String, dynamic>.from(row));
        return GymInboxMessage(
          id: message.id,
          senderUsername: message.senderUsername,
          senderDisplay: message.senderDisplay,
          body: message.body,
          createdAt: message.createdAt,
          isMine: viewer != null && message.senderUsername == viewer,
        );
      })
      .toList();
});

Future<GymInboxConversation> gymInboxOpenConversation(
  String slug, {
  String? audience,
  String? participantId,
}) async {
  final api = ApiClient();
  final res = await api.dio.post(
    '/gyms/$slug/inbox/',
    data: {
    'audience': ?audience,
      'participant_id': ?participantId,
    },
  );
  final payload = res.data is Map<String, dynamic>
      ? (res.data as Map<String, dynamic>)['data']
      : res.data;
  return GymInboxConversation.fromJson(Map<String, dynamic>.from(payload as Map));
}

Future<GymInboxMessage> gymInboxSendMessage(String slug, String conversationId, String body) async {
  final api = ApiClient();
  final res = await api.dio.post('/gyms/$slug/inbox/$conversationId/messages/', data: {'body': body});
  final payload = res.data is Map<String, dynamic>
      ? (res.data as Map<String, dynamic>)['data']
      : res.data;
  final raw = Map<String, dynamic>.from(payload as Map);
  return GymInboxMessage.fromJson(raw);
}
