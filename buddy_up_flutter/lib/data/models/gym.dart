import 'package:freezed_annotation/freezed_annotation.dart';

part 'gym.freezed.dart';
part 'gym.g.dart';

@freezed
abstract class OwnerData with _$OwnerData {
  const factory OwnerData({
    required String userId,
    required String username,
    required String displayName,
    required String avatarUrl,
    required String role,
  }) = _OwnerData;

  factory OwnerData.fromJson(Map<String, dynamic> json) => _$OwnerDataFromJson(json);
}

@freezed
abstract class MemberData with _$MemberData {
  const factory MemberData({
    required String userId,
    required String username,
    required String displayName,
    required String avatarUrl,
    @Default('none') String verificationStatus,
  }) = _MemberData;

  factory MemberData.fromJson(Map<String, dynamic> json) => _$MemberDataFromJson(json);
}

@freezed
abstract class GymCategory with _$GymCategory {
  const factory GymCategory({
    required String id,
    required String name,
    required String displayName,
    @Default('') String icon,
    @Default(true) bool isActive,
  }) = _GymCategory;

  factory GymCategory.fromJson(Map<String, dynamic> json) => _$GymCategoryFromJson(json);
}

@freezed
abstract class GymCategoryPricing with _$GymCategoryPricing {
  const factory GymCategoryPricing({
    String? id,
    required String category,
    String? categoryName,
    double? feePerDay,
    double? feePerWeek,
    double? feePerMonth,
    double? feePerYear,
    @Default(false) bool isFree,
  }) = _GymCategoryPricing;

  factory GymCategoryPricing.fromJson(Map<String, dynamic> json) =>
      _$GymCategoryPricingFromJson(json);
}

@freezed
abstract class Gym with _$Gym {
  const factory Gym({
    required String id,
    required String name,
    required String handle,
    @Default('') String description,
    @Default('') String logoUrl,
    @Default('') String coverUrl,
    @Default('') String category,
    @JsonKey(name: 'content_rating') @Default('general') String contentRating,
    @Default(<GymCategory>[]) List<GymCategory> categories,
    @Default('public') String accessType,
    @Default('free') String subscriptionType,
    @Default(false) bool isVerified,
    @Default(true) bool isReviewsEnabled,
    @Default(false) bool isDonationsEnabled,
    double? averageRating,
    @Default(0) int reviewCount,
    @Default(<MemberData>[]) List<MemberData> recentReviewers,
    @Default(<String>[]) List<String> rules,
    @Default(<String>[]) List<String> tags,
    @Default(0) int memberCount,
    @Default(0) int activeToday,
    @Default('') String locationCity,
    @Default('') String locationCountry,
    @Default(<OwnerData>[]) List<OwnerData> ownerData,
    String? membershipRole,
    @Default(false) bool isMember,
    required String createdAt,
    String? updatedAt,
  }) = _Gym;

  factory Gym.fromJson(Map<String, dynamic> json) => _$GymFromJson(json);
}

@freezed
abstract class GymMembership with _$GymMembership {
  const factory GymMembership({
    required String id,
    required String gymId,
    required String memberId,
    @Default('member') String role,
    @Default(false) bool subscriptionActive,
    String? subscriptionExpiresAt,
    required MemberData memberData,
    required String createdAt,
  }) = _GymMembership;

  factory GymMembership.fromJson(Map<String, dynamic> json) =>
      _$GymMembershipFromJson(json);
}

@freezed
abstract class JoinRequest with _$JoinRequest {
  const factory JoinRequest({
    required String id,
    required String gymId,
    required String requester,
    required MemberData requesterData,
    @Default('') String message,
    @Default('pending') String status,
    String? reviewedBy,
    String? reviewedAt,
    required String createdAt,
  }) = _JoinRequest;

  factory JoinRequest.fromJson(Map<String, dynamic> json) =>
      _$JoinRequestFromJson(json);
}

@freezed
abstract class GymInvite with _$GymInvite {
  const factory GymInvite({
    required String id,
    required String gymId,
    required String invitedUser,
    required MemberData invitedUserData,
    required String invitedBy,
    required Map<String, dynamic> invitedByData,
    @Default('pending') String status,
    required String createdAt,
  }) = _GymInvite;

  factory GymInvite.fromJson(Map<String, dynamic> json) => _$GymInviteFromJson(json);
}

@freezed
abstract class CityResult with _$CityResult {
  const factory CityResult({
    required String placeId,
    required String city,
    required String country,
    required String description,
  }) = _CityResult;

  factory CityResult.fromJson(Map<String, dynamic> json) => _$CityResultFromJson(json);
}

@freezed
abstract class GymSchedulePost with _$GymSchedulePost {
  const factory GymSchedulePost({
    required String id,
    required String gymId,
    required String author,
    required MemberData authorData,
    @Default('') String title,
    @Default('') String content,
    @Default('') String activityType,
    @Default('') String customActivityType,
    @Default('') String locationMode,
    String? startTime,
    String? endTime,
    String? recurrence,
    String? recurrenceEndDate,
    String? recurrenceDays,
    @Default(0) int maxSlots,
    @Default(0) int enrollmentCount,
    @Default(false) bool isEnrolled,
    required String createdAt,
  }) = _GymSchedulePost;

  factory GymSchedulePost.fromJson(Map<String, dynamic> json) =>
      _$GymSchedulePostFromJson(json);
}

@freezed
abstract class GymReview with _$GymReview {
  const factory GymReview({
    required String id,
    required String gymId,
    required String reviewer,
    required MemberData reviewerData,
    required int rating,
    @Default('') String comment,
    @Default('') String replyText,
    String? repliedBy,
    MemberData? repliedByData,
    String? repliedAt,
    required String createdAt,
  }) = _GymReview;

  factory GymReview.fromJson(Map<String, dynamic> json) => _$GymReviewFromJson(json);
}

@freezed
abstract class GymDonation with _$GymDonation {
  const factory GymDonation({
    required String id,
    required String gymId,
    required String donor,
    required MemberData donorData,
    required String amount,
    @Default('') String message,
    required String createdAt,
  }) = _GymDonation;

  factory GymDonation.fromJson(Map<String, dynamic> json) =>
      _$GymDonationFromJson(json);
}

@freezed
abstract class GymEvent with _$GymEvent {
  const factory GymEvent({
    required String id,
    required String gymId,
    required String title,
    @Default('') String description,
    String? startTime,
    String? endTime,
    @Default('') String location,
    required String createdAt,
  }) = _GymEvent;

  factory GymEvent.fromJson(Map<String, dynamic> json) => _$GymEventFromJson(json);
}

@freezed
abstract class CreateGymPayload with _$CreateGymPayload {
  const factory CreateGymPayload({
    required String name,
    required String handle,
    String? description,
    required String category,
    @JsonKey(name: 'content_rating') @Default('general') String contentRating,
    @Default(<String>[]) List<String> categoryIds,
    @Default('public') String accessType,
    @Default('free') String subscriptionType,
    String? locationCity,
    String? locationCountry,
    @Default(<String>[]) List<String> rules,
    @Default(<String>[]) List<String> tags,
    @Default(<GymCategoryPricing>[]) List<GymCategoryPricing> categoryPricing,
  }) = _CreateGymPayload;

  factory CreateGymPayload.fromJson(Map<String, dynamic> json) =>
      _$CreateGymPayloadFromJson(json);
}
