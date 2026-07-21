// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VerificationDocument _$VerificationDocumentFromJson(
  Map<String, dynamic> json,
) => _VerificationDocument(
  id: json['id'] as String,
  documentType: json['document_type'] as String,
  fileUrl: json['file_url'] as String,
  status: json['status'] as String? ?? 'pending',
  submittedAt: json['submitted_at'] as String,
  reviewedBy: json['reviewedBy'] as String?,
  reviewedAt: json['reviewedAt'] as String?,
  rejectionReason: json['rejectionReason'] as String?,
);

Map<String, dynamic> _$VerificationDocumentToJson(
  _VerificationDocument instance,
) => <String, dynamic>{
  'id': instance.id,
  'document_type': instance.documentType,
  'file_url': instance.fileUrl,
  'status': instance.status,
  'submitted_at': instance.submittedAt,
  'reviewedBy': instance.reviewedBy,
  'reviewedAt': instance.reviewedAt,
  'rejectionReason': instance.rejectionReason,
};

_VerificationSubmission _$VerificationSubmissionFromJson(
  Map<String, dynamic> json,
) => _VerificationSubmission(
  id: json['id'] as String,
  submissionType: json['submission_type'] as String,
  status: json['status'] as String? ?? 'pending',
  documents:
      (json['documents'] as List<dynamic>?)
          ?.map((e) => VerificationDocument.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <VerificationDocument>[],
  reviewedBy: json['reviewedBy'] as String?,
  reviewedAt: json['reviewedAt'] as String?,
  rejectionReason: json['rejectionReason'] as String?,
  submittedAt: json['submitted_at'] as String,
);

Map<String, dynamic> _$VerificationSubmissionToJson(
  _VerificationSubmission instance,
) => <String, dynamic>{
  'id': instance.id,
  'submission_type': instance.submissionType,
  'status': instance.status,
  'documents': instance.documents,
  'reviewedBy': instance.reviewedBy,
  'reviewedAt': instance.reviewedAt,
  'rejectionReason': instance.rejectionReason,
  'submitted_at': instance.submittedAt,
};
