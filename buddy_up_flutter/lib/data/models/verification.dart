import 'package:freezed_annotation/freezed_annotation.dart';

part 'verification.freezed.dart';
part 'verification.g.dart';

// Typed client for `/api/v1/verification/**`, mirroring
// `backend/apps/verification/serializers.py`.
//
// Two things changed here and both are load-bearing:
//
// 1. **A verification decision is two-person.** `POST …/review/` used to settle
//    an application in one call. It now raises an
//    `AccountActionRequest(action='verification_decision')` and answers **202**,
//    having applied nothing; a *different* member of staff settles it with
//    `POST …/decide/`. [VerificationApprovalState] is therefore modelled
//    explicitly — the review screen has to be able to say "awaiting a second
//    approver" rather than "approved", and it can only say that if the pending
//    request is a first-class field rather than something inferred from
//    `reviewed_by` being null.
// 2. **There are two application routes.** `POST
//    /verification/category-applications/` applies for an elevated role —
//    registration no longer accepts one, so this is the only way to become a
//    trainer or a practitioner — and `GET /verification/my-applications/`
//    tracks it.
//
// Every member is defaulted. The previous version of this file declared
// `submission_type` and a required `submitted_at` on documents, neither of
// which the server has ever sent under those names, so the row parser threw on
// a real response and the screen rendered nothing.

/// `_optionalDouble`: a confidence or score that is genuinely nullable.
///
/// Nullable rather than zero-defaulted because "no face match was attempted"
/// and "a face match scored 0.0" are different answers, and a tiered
/// permission check reads the difference.
double? _optionalDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse('$v');
}

/// A `VerificationDocument`.
///
/// `file_url` is a `SerializerMethodField` that returns an internal
/// `/api/v1/verification/documents/<id>/` path rather than a fetchable public
/// URL when the bytes live in our own storage — so it is a link to an
/// access-audited route, not a file address.
@freezed
abstract class VerificationDocument with _$VerificationDocument {
  const factory VerificationDocument({
    @Default('') String id,
    @JsonKey(name: 'document_type') @Default('') String documentType,
    @JsonKey(name: 'file_url') @Default('') String fileUrl,
    /// pending / approved / rejected.
    @Default('pending') String status,
    @JsonKey(name: 'rejection_reason') @Default('') String rejectionReason,
    @JsonKey(name: 'reviewed_by') String? reviewedBy,
    @JsonKey(name: 'reviewed_at') String? reviewedAt,
    @JsonKey(name: 'expires_at') String? expiresAt,
    @JsonKey(name: 'purge_after') String? purgeAfter,
    @JsonKey(name: 'purged_at') String? purgedAt,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _VerificationDocument;

  factory VerificationDocument.fromJson(Map<String, dynamic> json) =>
      _$VerificationDocumentFromJson(json);
}

extension VerificationDocumentX on VerificationDocument {
  /// Human label for `DOCUMENT_TYPES`, falling back to the raw value so a type
  /// this build has never seen still renders.
  String get typeLabel {
    const labels = {
      'id_document': 'ID document',
      'selfie_liveness': 'Selfie / liveness',
      'certificate': 'Certificate',
      'proof_of_address': 'Proof of address',
      'professional_license': 'Professional licence',
      'insurance': 'Insurance',
      'bank_statement': 'Bank statement',
    };
    return labels[documentType] ?? documentType.replaceAll('_', ' ');
  }

  /// Settled either way. A pending document is one a decision is still owed on.
  bool get isDecided => status == 'approved' || status == 'rejected';
}

/// The `approval_state` / `pending_approval` block on a submission.
///
/// The same object under two keys: `approval_state` is the latest request
/// whether still pending or already applied, and `pending_approval` is non-null
/// *exactly* while a second approver is still owed. The duplication is the
/// server's — `pending_approval` is the convenience for a reviewer who only
/// wants to know "is somebody else holding this".
@freezed
abstract class VerificationApprovalState with _$VerificationApprovalState {
  const factory VerificationApprovalState({
    String? id,
    /// pending / approved / rejected.
    @Default('') String status,
    /// The decision that was *requested*: approve or reject.
    String? decision,
    @JsonKey(name: 'required_scope') @Default('') String requiredScope,
    @JsonKey(name: 'requested_by_profile') @Default('') String requestedByProfile,
    @JsonKey(name: 'requested_at') String? requestedAt,
    @JsonKey(name: 'decided_by') String? decidedBy,
    @JsonKey(name: 'decided_at') String? decidedAt,
    @JsonKey(name: 'decision_note') @Default('') String decisionNote,
    /// Null until the decide call actually applied the effect. A request
    /// reading "approved" with no `applied_at` has not changed anything.
    @JsonKey(name: 'applied_at') String? appliedAt,
  }) = _VerificationApprovalState;

  factory VerificationApprovalState.fromJson(Map<String, dynamic> json) =>
      _$VerificationApprovalStateFromJson(json);
}

extension VerificationApprovalStateX on VerificationApprovalState {
  bool get isPending => status == 'pending';

  /// True when the request is settled *and* carries an applied time.
  ///
  /// The two are separate on purpose. `apply_decision` writes `status` and
  /// `applied_at` in one transaction and rolls the status back if the effect
  /// fails, so a settled row with no `applied_at` means a deployment where the
  /// approval was settled through a path that does not apply anything — the
  /// gap documented in `apps.verification.decisions`. The console reports that
  /// rather than rendering it as done.
  bool get isApplied => !isPending && appliedAt != null;

  bool get isSettledWithoutEffect => !isPending && appliedAt == null;

  /// What the pending request *says* it will do, in words an applicant can read.
  String get requestedDecisionLabel => switch (decision) {
        'approve' => 'approving',
        'reject' => 'rejecting',
        _ => 'deciding',
      };
}

/// The `approval_request` block the 202 from `review/` adds to the submission.
@freezed
abstract class VerificationApprovalRequest with _$VerificationApprovalRequest {
  const factory VerificationApprovalRequest({
    String? id,
    @Default('') String status,
    @JsonKey(name: 'requested_by_profile') @Default('') String requestedByProfile,
    @JsonKey(name: 'required_scope') @Default('') String requiredScope,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _VerificationApprovalRequest;

  factory VerificationApprovalRequest.fromJson(Map<String, dynamic> json) =>
      _$VerificationApprovalRequestFromJson(json);
}

/// The `approval` block the 200 from `decide/` adds to the submission.
@freezed
abstract class VerificationDecisionOutcome with _$VerificationDecisionOutcome {
  const factory VerificationDecisionOutcome({
    String? id,
    @Default('') String status,
    @JsonKey(name: 'decision_note') @Default('') String decisionNote,
    @JsonKey(name: 'decided_by') String? decidedBy,
    @JsonKey(name: 'decided_at') String? decidedAt,
    @JsonKey(name: 'applied_at') String? appliedAt,
    /// Server prose: "The trainer application was approved."
    @Default('') String effect,
  }) = _VerificationDecisionOutcome;

  factory VerificationDecisionOutcome.fromJson(Map<String, dynamic> json) =>
      _$VerificationDecisionOutcomeFromJson(json);
}

extension VerificationDecisionOutcomeX on VerificationDecisionOutcome {
  bool get appliedEffect => appliedAt != null;
}

/// `VERIFICATION_TYPES` a member of the public may apply for, plus the two
/// business verifications the older submission flow covers.
const List<({String value, String label})> kVerificationTypeChoices = [
  (value: 'id', label: 'Identity'),
  (value: 'trainer', label: 'Trainer'),
  (value: 'practitioner', label: 'Practitioner'),
  (value: 'shop', label: 'Shop'),
  (value: 'gym', label: 'Gym'),
  (value: 'gym_owner', label: 'Gym owner'),
  (value: 'shop_owner', label: 'Shop owner'),
  (value: 'delivery_partner', label: 'Delivery partner'),
];

/// `CATEGORY_APPLICATION_TYPES` — the roles registration will not grant.
///
/// This is the route the backend's registration refusal points at, so the
/// Flutter register screen names exactly these five.
const List<({String value, String label})> kCategoryApplicationChoices = [
  (value: 'trainer', label: 'Trainer'),
  (value: 'practitioner', label: 'Practitioner'),
  (value: 'gym_owner', label: 'Gym owner'),
  (value: 'shop_owner', label: 'Shop owner'),
  (value: 'delivery_partner', label: 'Delivery partner'),
];

/// `REQUIRED_FIELDS_BY_TYPE`, keyed by category.
///
/// Reproduced so the form can refuse an incomplete application before the
/// round trip. The server validates the same set and answers with a per-field
/// 400; the point of having it here is that an application missing its
/// credential number is caught *before* a reviewer spends time on it.
const Map<String, List<String>> kCategoryRequiredFields = {
  'trainer': [
    'credential_title',
    'credential_issuer',
    'credential_id',
    'issued_date',
    'scope_of_practice',
  ],
  'practitioner': [
    'credential_title',
    'credential_issuer',
    'credential_id',
    'issued_date',
    'scope_of_practice',
  ],
  'gym_owner': ['credential_title', 'credential_issuer', 'credential_id'],
  'shop_owner': ['credential_title', 'credential_issuer', 'credential_id'],
  'delivery_partner': ['credential_title', 'credential_issuer', 'credential_id'],
};

/// Categories that must name the gym they are applying to run.
const Set<String> kCategoryRequiresGym = {'gym_owner'};

/// `SCOPE_OF_PRACTICE_CHOICES` on the model field.
const List<({String value, String label})> kScopeOfPracticeChoices = [
  (value: 'strength_and_conditioning', label: 'Strength and conditioning'),
  (value: 'mobility', label: 'Mobility'),
  (value: 'rehabilitation', label: 'Rehabilitation'),
  (value: 'weight_management', label: 'Weight management'),
  (value: 'sports_nutrition', label: 'Sports nutrition'),
  (value: 'general_fitness', label: 'General fitness'),
];

/// Submission states a decision may be *requested* from.
///
/// `draft` is excluded upstream: a draft has not been submitted, so reviewing
/// it is a category error rather than a review. Mirrored here so the queue's
/// "Send for review" button is offered on exactly the right rows.
const Set<String> kReviewableSubmissionStatuses = {'submitted', 'under_review'};

/// `VerificationSubmission` — the server's own serializer output.
///
/// Status vocabulary is draft / submitted / under_review / approved / rejected.
@freezed
abstract class VerificationSubmission with _$VerificationSubmission {
  const factory VerificationSubmission({
    @Default('') String id,
    String? profile,
    @JsonKey(name: 'verification_type') @Default('') String verificationType,
    @Default('draft') String status,
    @Default(<VerificationDocument>[]) List<VerificationDocument> documents,
    @Default('') String notes,
    String? gym,
    @JsonKey(name: 'gym_name') String? gymName,
    @JsonKey(name: 'reviewed_by') String? reviewedBy,
    @JsonKey(name: 'reviewed_at') String? reviewedAt,
    @JsonKey(name: 'submitted_at') String? submittedAt,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'current_step') @Default('') String currentStep,
    @JsonKey(name: 'completed_steps', fromJson: _stringList)
    @Default(<String>[])
    List<String> completedSteps,
    @JsonKey(name: 'face_match_status') @Default('pending') String faceMatchStatus,
    @JsonKey(name: 'face_match_score', fromJson: _optionalDouble)
    double? faceMatchScore,
    @JsonKey(name: 'credential_title') @Default('') String credentialTitle,
    @JsonKey(name: 'credential_issuer') @Default('') String credentialIssuer,
    @JsonKey(name: 'credential_id') @Default('') String credentialId,
    @JsonKey(name: 'issued_date') String? issuedDate,
    @JsonKey(name: 'scope_of_practice') @Default('') String scopeOfPractice,
    @JsonKey(name: 'approval_state') VerificationApprovalState? approvalState,
    /// Non-null exactly while a second approver is still owed.
    @JsonKey(name: 'pending_approval') VerificationApprovalState? pendingApproval,
  }) = _VerificationSubmission;

  factory VerificationSubmission.fromJson(Map<String, dynamic> json) =>
      _$VerificationSubmissionFromJson(json);
}

extension VerificationSubmissionX on VerificationSubmission {
  String get typeLabel {
    for (final choice in kVerificationTypeChoices) {
      if (choice.value == verificationType) return choice.label;
    }
    return verificationType.replaceAll('_', ' ');
  }

  /// Settled either way — no further decision can be applied.
  bool get isDecided => status == 'approved' || status == 'rejected';

  bool get isApproved => status == 'approved';

  bool get isRejected => status == 'rejected';

  /// `raise_decision_request` only accepts a submitted application, so the
  /// queue offers the action on exactly these rows.
  bool get canRequestDecision => kReviewableSubmissionStatuses.contains(status);

  /// True when a decision has been asked for and nobody has settled it.
  ///
  /// This is the state a review screen has to present as *waiting*, not as
  /// approved: `review` returns 202 and changes nothing, and an operator who
  /// reads that as a completed review is exactly the bug the two-person split
  /// was written to prevent.
  bool get awaitsSecondApprover => pendingApproval != null;

  /// True when a request exists but was settled on a path that applied nothing.
  bool get isSettledWithoutEffect =>
      (approvalState?.isSettledWithoutEffect ?? false) && !isDecided;

  /// The reviewer's note the applicant reads. A rejection's note is the
  /// approver's reason; an approval's is whatever the approver typed.
  String get reviewerNote {
    final note = approvalState?.decisionNote ?? '';
    return note;
  }

  String get scopeLabel {
    for (final choice in kScopeOfPracticeChoices) {
      if (choice.value == scopeOfPractice) return choice.label;
    }
    return scopeOfPractice.replaceAll('_', ' ');
  }
}

/// One row of `GET /verification/my-applications/`.
///
/// The applicant must be able to see, per application: is it still open, and
/// what did the reviewer write. A status of "rejected" with no reason is the
/// one outcome a platform must never produce, so `reviewerNote` is a first-class
/// member rather than something derived.
///
/// **The note is read from two places on purpose.** The route returns
/// `VerificationSubmissionSerializer`, which has no `reviewer_note` of its own —
/// the note lives on `approval_state.decision_note`, which is where
/// `apply_decision` writes the reason the applicant is meant to read. A flat
/// `reviewer_note` is accepted too so a deployment that flattens it still
/// renders, and a *missing* note degrades to an explicit callout
/// ([isRejectedWithoutReason]) rather than to a blank line.
@freezed
abstract class MyApplication with _$MyApplication {
  const factory MyApplication({
    @Default('') String id,
    @JsonKey(name: 'verification_type') @Default('') String category,
    @Default('') String status,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'submitted_at') String? submittedAt,
    @JsonKey(name: 'decided_at') String? decidedAt,
    @JsonKey(name: 'reviewed_at') String? reviewedAt,
    @JsonKey(name: 'reviewer_note') @Default('') String reviewerNote,
    @JsonKey(name: 'approval_state') VerificationApprovalState? approvalState,
    @JsonKey(name: 'document_count') @Default(0) int documentCount,
  }) = _MyApplication;

  factory MyApplication.fromJson(Map<String, dynamic> json) =>
      _$MyApplicationFromJson(json);
}

extension MyApplicationX on MyApplication {
  static const pendingStatuses = {'draft', 'submitted', 'under_review'};

  String get categoryLabel {
    for (final choice in kCategoryApplicationChoices) {
      if (choice.value == category) return choice.label;
    }
    return category.replaceAll('_', ' ');
  }

  bool get isPending => pendingStatuses.contains(status);

  bool get isDecided => !isPending;

  bool get isRejected => status == 'rejected';

  bool get isApproved => status == 'approved';

  /// What the reviewer wrote, wherever it was recorded.
  ///
  /// The flat `reviewer_note` wins when a deployment sends it; otherwise the
  /// note is read off `approval_state`, which is where `apply_decision` writes
  /// it — "the record the applicant will read" is that field's stated purpose,
  /// so it is the one that is authoritative.
  String get note {
    final flat = reviewerNote.trim();
    if (flat.isNotEmpty) return flat;
    return (approvalState?.decisionNote ?? '').trim();
  }

  /// When the decision landed, from whichever field carried it.
  String? get decidedOn => decidedAt ?? reviewedAt ?? approvalState?.decidedAt;

  /// True while somebody other than the applicant still owes an answer.
  bool get awaitingSecondApprover =>
      approvalState?.isPending ?? (status == 'under_review');

  /// The one-line state an applicant actually needs.
  ///
  /// `under_review` is the important one: it means a reviewer looked at it and
  /// sent it for a decision, and that somebody *else* now owes the answer.
  String get statusLabel => switch (status) {
        'draft' => 'Not submitted',
        'submitted' => 'Waiting for a reviewer to look at it',
        'under_review' => 'With a reviewer — a second approver must agree',
        'approved' => 'Approved',
        'rejected' => 'Not approved',
        _ => status.replaceAll('_', ' '),
      };

  /// A rejection with no note is the one thing the applicant must be told
  /// about, because without it there is nothing to act on.
  bool get isRejectedWithoutReason => isRejected && note.isEmpty;
}

/// A list of strings, tolerant of a null or a wrong-shaped body.
List<String> _stringList(dynamic json) {
  if (json is! List) return const [];
  return json.where((e) => e != null).map((e) => '$e').toList();
}