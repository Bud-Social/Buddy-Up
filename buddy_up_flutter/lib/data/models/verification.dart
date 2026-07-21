import 'package:freezed_annotation/freezed_annotation.dart';

part 'verification.freezed.dart';
part 'verification.g.dart';

@freezed
abstract class VerificationDocument with _$VerificationDocument {
  const factory VerificationDocument({
    required String id,
    @JsonKey(name: 'document_type') required String documentType,
    @JsonKey(name: 'file_url') required String fileUrl,
    @Default('pending') String status,
    @JsonKey(name: 'submitted_at') required String submittedAt,
    String? reviewedBy,
    String? reviewedAt,
    String? rejectionReason,
  }) = _VerificationDocument;

  factory VerificationDocument.fromJson(Map<String, dynamic> json) =>
      _$VerificationDocumentFromJson(json);
}

@freezed
abstract class VerificationSubmission with _$VerificationSubmission {
  const factory VerificationSubmission({
    required String id,
    @JsonKey(name: 'submission_type') required String submissionType,
    @Default('pending') String status,
    @Default(<VerificationDocument>[]) List<VerificationDocument> documents,
    String? reviewedBy,
    String? reviewedAt,
    String? rejectionReason,
    @JsonKey(name: 'submitted_at') required String submittedAt,
  }) = _VerificationSubmission;

  factory VerificationSubmission.fromJson(Map<String, dynamic> json) =>
      _$VerificationSubmissionFromJson(json);
}
