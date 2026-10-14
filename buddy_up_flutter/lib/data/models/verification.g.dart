// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VerificationDocument _$VerificationDocumentFromJson(
  Map<String, dynamic> json,
) => _VerificationDocument(
  id: json['id'] as String? ?? '',
  documentType: json['document_type'] as String? ?? '',
  fileUrl: json['file_url'] as String? ?? '',
  status: json['status'] as String? ?? 'pending',
  rejectionReason: json['rejection_reason'] as String? ?? '',
  reviewedBy: json['reviewed_by'] as String?,
  reviewedAt: json['reviewed_at'] as String?,
  expiresAt: json['expires_at'] as String?,
  purgeAfter: json['purge_after'] as String?,
  purgedAt: json['purged_at'] as String?,
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$VerificationDocumentToJson(
  _VerificationDocument instance,
) => <String, dynamic>{
  'id': instance.id,
  'document_type': instance.documentType,
  'file_url': instance.fileUrl,
  'status': instance.status,
  'rejection_reason': instance.rejectionReason,
  'reviewed_by': instance.reviewedBy,
  'reviewed_at': instance.reviewedAt,
  'expires_at': instance.expiresAt,
  'purge_after': instance.purgeAfter,
  'purged_at': instance.purgedAt,
  'created_at': instance.createdAt,
};

_VerificationApprovalState _$VerificationApprovalStateFromJson(
  Map<String, dynamic> json,
) => _VerificationApprovalState(
  id: json['id'] as String?,
  status: json['status'] as String? ?? '',
  decision: json['decision'] as String?,
  requiredScope: json['required_scope'] as String? ?? '',
  requestedByProfile: json['requested_by_profile'] as String? ?? '',
  requestedAt: json['requested_at'] as String?,
  decidedBy: json['decided_by'] as String?,
  decidedAt: json['decided_at'] as String?,
  decisionNote: json['decision_note'] as String? ?? '',
  appliedAt: json['applied_at'] as String?,
);

Map<String, dynamic> _$VerificationApprovalStateToJson(
  _VerificationApprovalState instance,
) => <String, dynamic>{
  'id': instance.id,
  'status': instance.status,
  'decision': instance.decision,
  'required_scope': instance.requiredScope,
  'requested_by_profile': instance.requestedByProfile,
  'requested_at': instance.requestedAt,
  'decided_by': instance.decidedBy,
  'decided_at': instance.decidedAt,
  'decision_note': instance.decisionNote,
  'applied_at': instance.appliedAt,
};

_VerificationApprovalRequest _$VerificationApprovalRequestFromJson(
  Map<String, dynamic> json,
) => _VerificationApprovalRequest(
  id: json['id'] as String?,
  status: json['status'] as String? ?? '',
  requestedByProfile: json['requested_by_profile'] as String? ?? '',
  requiredScope: json['required_scope'] as String? ?? '',
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$VerificationApprovalRequestToJson(
  _VerificationApprovalRequest instance,
) => <String, dynamic>{
  'id': instance.id,
  'status': instance.status,
  'requested_by_profile': instance.requestedByProfile,
  'required_scope': instance.requiredScope,
  'created_at': instance.createdAt,
};

_VerificationDecisionOutcome _$VerificationDecisionOutcomeFromJson(
  Map<String, dynamic> json,
) => _VerificationDecisionOutcome(
  id: json['id'] as String?,
  status: json['status'] as String? ?? '',
  decisionNote: json['decision_note'] as String? ?? '',
  decidedBy: json['decided_by'] as String?,
  decidedAt: json['decided_at'] as String?,
  appliedAt: json['applied_at'] as String?,
  effect: json['effect'] as String? ?? '',
);

Map<String, dynamic> _$VerificationDecisionOutcomeToJson(
  _VerificationDecisionOutcome instance,
) => <String, dynamic>{
  'id': instance.id,
  'status': instance.status,
  'decision_note': instance.decisionNote,
  'decided_by': instance.decidedBy,
  'decided_at': instance.decidedAt,
  'applied_at': instance.appliedAt,
  'effect': instance.effect,
};

_VerificationSubmission _$VerificationSubmissionFromJson(
  Map<String, dynamic> json,
) => _VerificationSubmission(
  id: json['id'] as String? ?? '',
  profile: json['profile'] as String?,
  verificationType: json['verification_type'] as String? ?? '',
  status: json['status'] as String? ?? 'draft',
  documents:
      (json['documents'] as List<dynamic>?)
          ?.map((e) => VerificationDocument.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <VerificationDocument>[],
  notes: json['notes'] as String? ?? '',
  gym: json['gym'] as String?,
  gymName: json['gym_name'] as String?,
  reviewedBy: json['reviewed_by'] as String?,
  reviewedAt: json['reviewed_at'] as String?,
  submittedAt: json['submitted_at'] as String?,
  createdAt: json['created_at'] as String?,
  currentStep: json['current_step'] as String? ?? '',
  completedSteps: json['completed_steps'] == null
      ? const <String>[]
      : _stringList(json['completed_steps']),
  faceMatchStatus: json['face_match_status'] as String? ?? 'pending',
  faceMatchScore: _optionalDouble(json['face_match_score']),
  credentialTitle: json['credential_title'] as String? ?? '',
  credentialIssuer: json['credential_issuer'] as String? ?? '',
  credentialId: json['credential_id'] as String? ?? '',
  issuedDate: json['issued_date'] as String?,
  scopeOfPractice: json['scope_of_practice'] as String? ?? '',
  approvalState: json['approval_state'] == null
      ? null
      : VerificationApprovalState.fromJson(
          json['approval_state'] as Map<String, dynamic>,
        ),
  pendingApproval: json['pending_approval'] == null
      ? null
      : VerificationApprovalState.fromJson(
          json['pending_approval'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$VerificationSubmissionToJson(
  _VerificationSubmission instance,
) => <String, dynamic>{
  'id': instance.id,
  'profile': instance.profile,
  'verification_type': instance.verificationType,
  'status': instance.status,
  'documents': instance.documents,
  'notes': instance.notes,
  'gym': instance.gym,
  'gym_name': instance.gymName,
  'reviewed_by': instance.reviewedBy,
  'reviewed_at': instance.reviewedAt,
  'submitted_at': instance.submittedAt,
  'created_at': instance.createdAt,
  'current_step': instance.currentStep,
  'completed_steps': instance.completedSteps,
  'face_match_status': instance.faceMatchStatus,
  'face_match_score': instance.faceMatchScore,
  'credential_title': instance.credentialTitle,
  'credential_issuer': instance.credentialIssuer,
  'credential_id': instance.credentialId,
  'issued_date': instance.issuedDate,
  'scope_of_practice': instance.scopeOfPractice,
  'approval_state': instance.approvalState,
  'pending_approval': instance.pendingApproval,
};

_MyApplication _$MyApplicationFromJson(Map<String, dynamic> json) =>
    _MyApplication(
      id: json['id'] as String? ?? '',
      category: json['verification_type'] as String? ?? '',
      status: json['status'] as String? ?? '',
      createdAt: json['created_at'] as String?,
      submittedAt: json['submitted_at'] as String?,
      decidedAt: json['decided_at'] as String?,
      reviewedAt: json['reviewed_at'] as String?,
      reviewerNote: json['reviewer_note'] as String? ?? '',
      approvalState: json['approval_state'] == null
          ? null
          : VerificationApprovalState.fromJson(
              json['approval_state'] as Map<String, dynamic>,
            ),
      documentCount: (json['document_count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$MyApplicationToJson(_MyApplication instance) =>
    <String, dynamic>{
      'id': instance.id,
      'verification_type': instance.category,
      'status': instance.status,
      'created_at': instance.createdAt,
      'submitted_at': instance.submittedAt,
      'decided_at': instance.decidedAt,
      'reviewed_at': instance.reviewedAt,
      'reviewer_note': instance.reviewerNote,
      'approval_state': instance.approvalState,
      'document_count': instance.documentCount,
    };
