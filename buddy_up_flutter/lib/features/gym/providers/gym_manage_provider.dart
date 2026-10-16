import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_error.dart';
import '../../../data/models/gym.dart';
import 'gym_provider.dart';

/// The four panels of the gym management surface.
///
/// The member, schedule-post and review reads already existed as providers on
/// [GymDetailScreen]; what an owner has no affordance for there is *deciding* on
/// a join request, inviting somebody, posting a schedule update and replying to
/// a review. That is what this file adds, over the same endpoints.
///
/// **Each panel degrades on its own.** A missing join-requests endpoint must not
/// blank the member list, so every read here is guarded independently and a
/// failed one simply shows its own empty state.
class GymManageScope {
  final String slug;
  final Gym gym;

  const GymManageScope({required this.slug, required this.gym});
}

final gymManageMembersProvider =
    FutureProvider.family<List<GymMembership>, String>((ref, slug) async {
  final raw = await ref.read(gymRepositoryProvider).getMembers(slug);
  return _rows(raw).map(GymMembership.fromJson).toList();
});

/// The gym's own numbers, for the Overview tab.
///
/// Decoding is defensive on purpose: this is the one panel that is partner-only,
/// so an ordinary member requesting it gets a 403 and the tab has to show an
/// explanation rather than an empty shell or a thrown decode error.
final gymPartnerMetricsProvider =
    FutureProvider.family<GymPartnerMetrics, String>((ref, slug) async {
  final raw = await ref.read(gymRepositoryProvider).getPartnerMetrics(slug);
  return GymPartnerMetrics.fromJson(_payload(raw));
});

/// The gym's operator analytics, with the window each figure covers.
class GymPartnerMetrics {
  final int activeMembers;
  final int checkIns30d;
  final int uniqueAttendees30d;
  final double activationRate30d;
  final int scheduledActivities30d;

  const GymPartnerMetrics({
    required this.activeMembers,
    required this.checkIns30d,
    required this.uniqueAttendees30d,
    required this.activationRate30d,
    required this.scheduledActivities30d,
  });

  factory GymPartnerMetrics.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic value) =>
        value is num ? value.toInt() : int.tryParse('$value') ?? 0;
    double asDouble(dynamic value) =>
        value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

    return GymPartnerMetrics(
      activeMembers: asInt(json['active_members']),
      checkIns30d: asInt(json['check_ins_30d']),
      uniqueAttendees30d: asInt(json['unique_attendees_30d']),
      activationRate30d: asDouble(json['activation_rate_30d']),
      scheduledActivities30d: asInt(json['scheduled_activities_30d']),
    );
  }
}

/// Pending join requests, which is the queue an owner actually works through.
final gymManageJoinRequestsProvider =
    FutureProvider.family<List<JoinRequest>, String>((ref, slug) async {
  final raw = await ref
      .read(gymRepositoryProvider)
      .getJoinRequests(slug, status: 'pending');
  return _rows(raw).map(JoinRequest.fromJson).toList();
});

final gymManageSchedulePostsProvider =
    FutureProvider.family<List<GymSchedulePost>, String>((ref, slug) async {
  final raw = await ref.read(gymRepositoryProvider).getSchedulePosts(slug);
  return _rows(raw).map(GymSchedulePost.fromJson).toList();
});

final gymManageReviewsProvider =
    FutureProvider.family<List<GymReview>, String>((ref, slug) async {
  final raw = await ref.read(gymRepositoryProvider).getReviews(slug);
  return _rows(raw).map(GymReview.fromJson).toList();
});

/// The single object inside the standard `{success, data}` envelope.
Map<String, dynamic> _payload(dynamic body) {
  final data = body is Map ? body['data'] : body;
  if (data is Map<String, dynamic>) return data;
  return const {};
}

List<Map<String, dynamic>> _rows(dynamic body) {
  final data = body is Map ? body['data'] : body;
  if (data is List) return data.whereType<Map<String, dynamic>>().toList();
  if (data is Map) {
    final results = data['results'];
    if (results is List) return results.whereType<Map<String, dynamic>>().toList();
  }
  return const [];
}

/// Approve or reject a join request.
class GymJoinRequestActions {
  final Ref _ref;

  GymJoinRequestActions(this._ref);

  Future<void> decide(String slug, String requestId, String decision) async {
    await _ref
        .read(gymRepositoryProvider)
        .manageJoinRequest(slug, requestId, {'status': decision});
    _ref.invalidate(gymManageJoinRequestsProvider(slug));
    _ref.invalidate(gymManageMembersProvider(slug));
  }
}

final gymJoinRequestActionsProvider =
    Provider<GymJoinRequestActions>(GymJoinRequestActions.new);

/// Invite somebody by username or email.
///
/// The backend takes one or the other, never both, so the shape is chosen from
/// what was typed — sending both is a 400 the caller cannot act on.
class GymInviteActions {
  final Ref _ref;

  GymInviteActions(this._ref);

  Future<void> send(String slug, String target) async {
    final value = target.trim();
    if (value.isEmpty) return;
    await _ref.read(gymRepositoryProvider).invite(slug, {
      if (value.contains('@')) 'email': value else 'username': value,
    });
  }
}

final gymInviteActionsProvider =
    Provider<GymInviteActions>(GymInviteActions.new);

/// Post a schedule update.
class GymSchedulePostActions {
  final Ref _ref;

  GymSchedulePostActions(this._ref);

  Future<void> create(String slug, Map<String, dynamic> payload) async {
    await _ref.read(gymRepositoryProvider).createSchedulePost(slug, payload);
    _ref.invalidate(gymManageSchedulePostsProvider(slug));
  }
}

final gymSchedulePostActionsProvider =
    Provider<GymSchedulePostActions>(GymSchedulePostActions.new);

/// Reply to a review, replacing the server's saved reply with the returned row.
class GymReviewReplyActions {
  final Ref _ref;

  GymReviewReplyActions(this._ref);

  Future<void> reply(String slug, String reviewId, String text) async {
    await _ref
        .read(gymRepositoryProvider)
        .replyToReview(slug, reviewId, {'reply_text': text.trim()});
    _ref.invalidate(gymManageReviewsProvider(slug));
  }
}

final gymReviewReplyActionsProvider =
    Provider<GymReviewReplyActions>(GymReviewReplyActions.new);

/// Every management mutation reports the server's own sentence; a refused
/// approval or a reply on someone else's review says why.
String gymManageErrorMessage(Object error, {required String fallback}) =>
    apiErrorMessage(error, fallback: fallback);