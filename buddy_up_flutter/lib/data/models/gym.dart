import 'package:freezed_annotation/freezed_annotation.dart';

part 'gym.freezed.dart';
part 'gym.g.dart';

// Backend speaks snake_case (plain DRF JSONRenderer). These helpers keep
// parsing tolerant: ids may arrive as int, Decimal fees as strings.
String _strId(dynamic v) => v.toString();
String? _optStr(dynamic v) => v?.toString();
dynamic _idToJson(String s) => int.tryParse(s) ?? s;
double? _optDouble(dynamic v) =>
    v == null ? null : (v is num ? v.toDouble() : double.tryParse(v.toString()));

@freezed
abstract class OwnerData with _$OwnerData {
  const factory OwnerData({
    @JsonKey(name: 'user_id') required String userId,
    required String username,
    @JsonKey(name: 'display_name') required String displayName,
    @JsonKey(name: 'avatar_url') required String avatarUrl,
    required String role,
  }) = _OwnerData;

  factory OwnerData.fromJson(Map<String, dynamic> json) => _$OwnerDataFromJson(json);
}

@freezed
abstract class MemberData with _$MemberData {
  const factory MemberData({
    @JsonKey(name: 'user_id') required String userId,
    required String username,
    @JsonKey(name: 'display_name') required String displayName,
    @JsonKey(name: 'avatar_url') required String avatarUrl,
    @JsonKey(name: 'verification_status') @Default('none') String verificationStatus,
  }) = _MemberData;

  factory MemberData.fromJson(Map<String, dynamic> json) => _$MemberDataFromJson(json);
}

@freezed
abstract class GymCategory with _$GymCategory {
  const factory GymCategory({
    @JsonKey(fromJson: _strId, toJson: _idToJson) required String id,
    required String name,
    @JsonKey(name: 'display_name') required String displayName,
    @Default('') String icon,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
  }) = _GymCategory;

  factory GymCategory.fromJson(Map<String, dynamic> json) => _$GymCategoryFromJson(json);
}

@freezed
abstract class GymCategoryPricing with _$GymCategoryPricing {
  const factory GymCategoryPricing({
    @JsonKey(fromJson: _optStr) String? id,
    @JsonKey(fromJson: _strId, toJson: _idToJson) required String category,
    @JsonKey(name: 'category_name') String? categoryName,
    @JsonKey(name: 'fee_per_day', fromJson: _optDouble) double? feePerDay,
    @JsonKey(name: 'fee_per_week', fromJson: _optDouble) double? feePerWeek,
    @JsonKey(name: 'fee_per_month', fromJson: _optDouble) double? feePerMonth,
    @JsonKey(name: 'fee_per_year', fromJson: _optDouble) double? feePerYear,
    @JsonKey(name: 'is_free') @Default(false) bool isFree,
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
    @JsonKey(name: 'access_type') @Default('public') String accessType,
    @JsonKey(name: 'subscription_type') @Default('free') String subscriptionType,
    @JsonKey(name: 'is_verified') @Default(false) bool isVerified,
    @JsonKey(name: 'is_reviews_enabled') @Default(true) bool isReviewsEnabled,
    @JsonKey(name: 'is_donations_enabled') @Default(false) bool isDonationsEnabled,
    @JsonKey(name: 'average_rating') double? averageRating,
    @JsonKey(name: 'review_count') @Default(0) int reviewCount,
    @JsonKey(name: 'recent_reviewers') @Default(<MemberData>[]) List<MemberData> recentReviewers,
    @Default(<String>[]) List<String> rules,
    @Default(<String>[]) List<String> tags,
    @JsonKey(name: 'member_count') @Default(0) int memberCount,
    @JsonKey(name: 'active_today') @Default(0) int activeToday,
    @JsonKey(name: 'location_city') @Default('') String locationCity,
    @JsonKey(name: 'location_country') @Default('') String locationCountry,
    @JsonKey(name: 'delivery_modes') @Default(<String>[]) List<String> deliveryModes,
    @JsonKey(name: 'distance_km') double? distanceKm,
    @JsonKey(name: 'owner_data') @Default(<OwnerData>[]) List<OwnerData> ownerData,
    @JsonKey(name: 'membership_role') String? membershipRole,
    @JsonKey(name: 'is_member') @Default(false) bool isMember,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _Gym;

  factory Gym.fromJson(Map<String, dynamic> json) => _$GymFromJson(json);
}

@freezed
abstract class GymMembership with _$GymMembership {
  const factory GymMembership({
    required String id,
    @JsonKey(name: 'gym_id') required String gymId,
    @JsonKey(name: 'member_id') required String memberId,
    @Default('member') String role,
    @JsonKey(name: 'subscription_active') @Default(false) bool subscriptionActive,
    @JsonKey(name: 'subscription_expires_at') String? subscriptionExpiresAt,
    @JsonKey(name: 'member_data') required MemberData memberData,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _GymMembership;

  factory GymMembership.fromJson(Map<String, dynamic> json) =>
      _$GymMembershipFromJson(json);
}

@freezed
abstract class JoinRequest with _$JoinRequest {
  const factory JoinRequest({
    required String id,
    @JsonKey(name: 'gym_id') required String gymId,
    required String requester,
    @JsonKey(name: 'requester_data') required MemberData requesterData,
    @Default('') String message,
    @Default('pending') String status,
    @JsonKey(name: 'reviewed_by') String? reviewedBy,
    @JsonKey(name: 'reviewed_at') String? reviewedAt,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _JoinRequest;

  factory JoinRequest.fromJson(Map<String, dynamic> json) =>
      _$JoinRequestFromJson(json);
}

@freezed
abstract class GymInvite with _$GymInvite {
  const factory GymInvite({
    required String id,
    @JsonKey(name: 'gym_id') required String gymId,
    @JsonKey(name: 'invited_user') required String invitedUser,
    @JsonKey(name: 'invited_user_data') required MemberData invitedUserData,
    @JsonKey(name: 'invited_by') required String invitedBy,
    @JsonKey(name: 'invited_by_data') required Map<String, dynamic> invitedByData,
    @Default('pending') String status,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _GymInvite;

  factory GymInvite.fromJson(Map<String, dynamic> json) => _$GymInviteFromJson(json);
}

@freezed
abstract class CityResult with _$CityResult {
  const factory CityResult({
    @JsonKey(name: 'place_id') required String placeId,
    required String city,
    @Default('') String country,
    required String description,
  }) = _CityResult;

  factory CityResult.fromJson(Map<String, dynamic> json) => _$CityResultFromJson(json);
}

@freezed
abstract class GymSchedulePost with _$GymSchedulePost {
  const factory GymSchedulePost({
    required String id,
    @JsonKey(name: 'gym_id') required String gymId,
    required String author,
    @JsonKey(name: 'author_data') required MemberData authorData,
    @Default('') String title,
    @Default('') String content,
    @JsonKey(name: 'activity_type') @Default('') String activityType,
    @JsonKey(name: 'custom_activity_type') @Default('') String customActivityType,
    @JsonKey(name: 'location_mode') @Default('') String locationMode,
    @JsonKey(name: 'start_time') String? startTime,
    @JsonKey(name: 'end_time') String? endTime,
    String? recurrence,
    @JsonKey(name: 'recurrence_end_date') String? recurrenceEndDate,
    @JsonKey(name: 'recurrence_days') List<int>? recurrenceDays,
    @JsonKey(name: 'max_slots') @Default(0) int maxSlots,
    @JsonKey(name: 'enrollment_count') @Default(0) int enrollmentCount,
    @JsonKey(name: 'is_enrolled') @Default(false) bool isEnrolled,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _GymSchedulePost;

  factory GymSchedulePost.fromJson(Map<String, dynamic> json) =>
      _$GymSchedulePostFromJson(json);
}

@freezed
abstract class GymReview with _$GymReview {
  const factory GymReview({
    required String id,
    @JsonKey(name: 'gym_id') required String gymId,
    required String reviewer,
    @JsonKey(name: 'reviewer_data') required MemberData reviewerData,
    required int rating,
    @Default('') String comment,
    @JsonKey(name: 'reply_text') @Default('') String replyText,
    @JsonKey(name: 'replied_by') String? repliedBy,
    @JsonKey(name: 'replied_by_data') MemberData? repliedByData,
    @JsonKey(name: 'replied_at') String? repliedAt,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _GymReview;

  factory GymReview.fromJson(Map<String, dynamic> json) => _$GymReviewFromJson(json);
}

@freezed
abstract class GymDonation with _$GymDonation {
  const factory GymDonation({
    required String id,
    @JsonKey(name: 'gym_id') required String gymId,
    required String donor,
    @JsonKey(name: 'donor_data') required MemberData donorData,
    required String amount,
    @Default('') String message,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _GymDonation;

  factory GymDonation.fromJson(Map<String, dynamic> json) =>
      _$GymDonationFromJson(json);
}

@freezed
abstract class GymEvent with _$GymEvent {
  const factory GymEvent({
    required String id,
    @JsonKey(name: 'gym_id') String? gymId,
    required String title,
    @Default('') String description,
    @JsonKey(name: 'start_datetime') String? startTime,
    @JsonKey(name: 'end_datetime') String? endTime,
    @Default('') String location,
    @JsonKey(name: 'created_at') String? createdAt,
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
    @JsonKey(name: 'category_ids') @Default(<String>[]) List<String> categoryIds,
    @JsonKey(name: 'access_type') @Default('public') String accessType,
    @JsonKey(name: 'subscription_type') @Default('free') String subscriptionType,
    @JsonKey(name: 'location_city') String? locationCity,
    @JsonKey(name: 'location_country') String? locationCountry,
    @Default(<String>[]) List<String> rules,
    @Default(<String>[]) List<String> tags,
    @JsonKey(name: 'category_pricing') @Default(<GymCategoryPricing>[]) List<GymCategoryPricing> categoryPricing,
  }) = _CreateGymPayload;

  factory CreateGymPayload.fromJson(Map<String, dynamic> json) =>
      _$CreateGymPayloadFromJson(json);
}
