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