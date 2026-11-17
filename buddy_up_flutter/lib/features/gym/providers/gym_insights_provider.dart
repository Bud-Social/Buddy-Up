import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/gym_insights.dart';
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
