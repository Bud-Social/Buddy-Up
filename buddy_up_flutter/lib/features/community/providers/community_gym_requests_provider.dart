import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';

final communityGymApiClientProvider = Provider<ApiClient>((_) => ApiClient());

/// A pending gym→community link request, as reviewed by the community's
/// owner/admin. Mirrors the web `GymLinkRequestsPanel`.
class CommunityGymLinkRequest {
  final int id;
  final String gymHandle;
  final String gymName;
  final String gymLogoUrl;
  final String gymCategory;
  final int gymMemberCount;
  final String communityName;
  final String requestedBy;
  final String createdAt;

  const CommunityGymLinkRequest({
    required this.id,
    required this.gymHandle,
    required this.gymName,
    required this.gymLogoUrl,
    required this.gymCategory,
    required this.gymMemberCount,
    required this.communityName,
    required this.requestedBy,
    required this.createdAt,
  });

  factory CommunityGymLinkRequest.fromJson(Map<String, dynamic> json) {
    return CommunityGymLinkRequest(
      id: (json['id'] as num?)?.toInt() ?? 0,
      gymHandle: json['gym_handle'] as String? ?? '',
      gymName: json['gym_name'] as String? ?? '',
      gymLogoUrl: json['gym_logo_url'] as String? ?? '',
      gymCategory: json['gym_category'] as String? ?? '',
      gymMemberCount: (json['gym_member_count'] as num?)?.toInt() ?? 0,
      communityName: json['community_name'] as String? ?? '',
      requestedBy: json['requested_by'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}

class CommunityGymRequestsNotifier
    extends AsyncNotifier<List<CommunityGymLinkRequest>> {
  final String communityId;

  CommunityGymRequestsNotifier(this.communityId);

  @override
  Future<List<CommunityGymLinkRequest>> build() => _load();

  Future<List<CommunityGymLinkRequest>> _load() async {
    final raw = await ref
        .read(communityGymApiClientProvider)
        .dio
        .get(
          '/gyms/community-link-requests/',
          queryParameters: {'community_id': communityId},
        );
    final data = raw.data;
    final payload = data is Map ? data['data'] : null;
    final requests = payload is Map ? payload['requests'] : null;
    if (requests is! List) return const [];
    return requests
        .whereType<Map<String, dynamic>>()
        .map(CommunityGymLinkRequest.fromJson)
        .toList();
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> decide(int requestId, bool approve) async {
    await ref
        .read(communityGymApiClientProvider)
        .dio
        .post(
          '/gyms/community-link-requests/$requestId/decide/',
          data: {'decision': approve ? 'approved' : 'declined'},
        );
    state = state.whenData(
      (requests) => requests.where((r) => r.id != requestId).toList(),
    );
  }
}

final communityGymRequestsProvider =
    AsyncNotifierProvider.family<
      CommunityGymRequestsNotifier,
      List<CommunityGymLinkRequest>,
      String
    >(CommunityGymRequestsNotifier.new);
