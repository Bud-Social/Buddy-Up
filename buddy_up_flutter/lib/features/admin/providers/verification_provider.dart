import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_error.dart';
import '../../../data/models/verification.dart';
import '../../../data/repositories/verification_repository.dart';
import '../../verification/providers/verification_provider.dart';
import 'admin_provider.dart';

/// The staff half of `/verification/**`: the review queue and the two-person
/// decision.
///
/// **The rule this file exists to keep visible.** `POST …/review/` used to
/// settle an application in one call. It now raises an
/// `AccountActionRequest(action='verification_decision')` and answers **202**,
/// having applied nothing: `Profile.verification_status`, `Profile.role` and
/// `Gym.is_verified` are unchanged until a *different* member of staff calls
/// `POST …/decide/`. A client that reports the 202 as "approved" would tell a
/// reviewer they had verified somebody when they had only asked a colleague to,
/// so the two outcomes are separate types here and the queue renders them with
/// different words.
final verificationAdminRepositoryProvider = Provider<VerificationRepository>(
  (ref) => ref.watch(verificationRepositoryProvider),
);

/// What came back from a `review/` call.
///
/// 202 with an `approval_request` block: a decision is queued and **nothing has
/// been applied**. The sentence the queue shows is deliberately about waiting,
/// not about success.
class VerificationReviewQueued {
  final VerificationSubmission submission;
  final VerificationApprovalRequest? approvalRequest;

  const VerificationReviewQueued(this.submission, this.approvalRequest);

  String get message {
    final scope = approvalRequest?.requiredScope ?? '';
    final who = approvalRequest?.requestedByProfile ?? '';
    final whoText =
        who.isEmpty ? 'Another member of staff' : '$who (or another)';
    return 'Decision requested — awaiting a second approver. Nothing has been '
        'applied to the applicant: no status, no role, no gym verification. '
        '$whoText still has to approve or reject'
        '${scope.isEmpty ? ' it' : ' it (needs $scope)'}. The applicant sees '
        'this as "under review".';
  }
}

/// What came back from a `decide/` call.
///
/// The only call that changes anything. [outcome] is the server's own `effect`
/// sentence — "The trainer application was approved." — which names the type
/// that was granted and is worth showing rather than paraphrasing.
class VerificationDecisionApplied {
  final VerificationSubmission submission;
  final VerificationDecisionOutcome? outcome;

  const VerificationDecisionApplied(this.submission, this.outcome);

  String get message {
    final effect = outcome?.effect ?? '';
    return effect.isEmpty ? 'Decision applied.' : effect;
  }
}

/// Read a `review/` response.
///
/// The response has no envelope: `{**submission, approval_request: {...}}`.
VerificationReviewQueued verificationReviewQueued(dynamic raw) {
  final map = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
  final approval = map['approval_request'];
  return VerificationReviewQueued(
    VerificationSubmission.fromJson(map),
    approval is Map<String, dynamic>
        ? VerificationApprovalRequest.fromJson(approval)
        : null,
  );
}

/// Read a `decide/` response.
///
/// `{**submission, approval: {...}}`.
VerificationDecisionApplied verificationDecisionApplied(dynamic raw) {
  final map = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
  final approval = map['approval'];
  return VerificationDecisionApplied(
    VerificationSubmission.fromJson(map),
    approval is Map<String, dynamic>
        ? VerificationDecisionOutcome.fromJson(approval)
        : null,
  );
}

/// The server's refusal, read for the two separations-of-duties cases.
///
/// Both are 403 with a `detail` sentence, and both mean the operator's next
/// move is *find a different colleague* rather than retry. Showing the server's
/// own wording is the point: "You cannot submit a decision on your own
/// application" and "The person who raised this request cannot be the one who
/// decides it" are different mistakes with different fixes, and a generic
/// "forbidden" would collapse them.
String verificationRefusal(Object error) {
  final message = apiErrorMessage(error, fallback: 'The server refused this.');
  if (apiStatusCode(error) == 403) {
    return '$message Nothing on this screen can waive it — two-person approval '
        'is enforced server-side, and the person who must act is a different '
        'member of staff.';
  }
  return message;
}

/// Which submissions the staff queue offers "Send for decision" on.
///
/// Server-side rule, mirrored: `raise_decision_request` refuses anything that is
/// not `submitted` or `under_review`, and refuses a second request while one is
/// already in flight. Offering the button anywhere else wastes a round trip to
/// learn a rule the client already knows.
bool canRequestVerificationDecision(VerificationSubmission submission) =>
    submission.canRequestDecision && !submission.awaitsSecondApprover;

/// Which submissions this operator could settle right now.
///
/// The server decides — 403 when the caller raised the request — so the client
/// cannot know. It *can* know that a decision is owed, which is what enables the
/// button; the refusal is surfaced verbatim when it comes back.
bool canDecideVerification(VerificationSubmission submission) =>
    submission.awaitsSecondApprover;

/// The queue, refetched whenever either side of a decision changes.
void invalidateVerificationQueues(WidgetRef ref) {
  ref.invalidate(verificationSubmissionsProvider);
  ref.invalidate(submissionsAwaitingDecisionProvider);
  ref.invalidate(myApplicationsProvider);
  ref.invalidate(verificationDocumentsProvider);
  ref.invalidate(attachableDocumentsProvider);
  ref.invalidate(adminPortalRepositoryProvider);
}