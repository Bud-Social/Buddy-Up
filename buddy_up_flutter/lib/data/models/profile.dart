import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    @JsonKey(name: 'user_id') required String userId,
    required String username,
    @JsonKey(name: 'display_name') required String displayName,
    @Default('') String bio,
    @JsonKey(name: 'avatar_url') @Default('') String avatarUrl,
    @JsonKey(name: 'cover_url') @Default('') String coverUrl,
    @Default('') String pronouns,
    @JsonKey(name: 'location_city') @Default('') String locationCity,
    @JsonKey(name: 'location_country') @Default('') String locationCountry,
    @JsonKey(name: 'external_link') String? externalLink,
    @JsonKey(name: 'content_rating') @Default('general') String contentRating,
    @Default('user') String role,
    @JsonKey(name: 'verification_status') @Default('none') String verificationStatus,
    @JsonKey(name: 'privacy_level') @Default('public') String privacyLevel,
    @JsonKey(name: 'onboarding_completed') @Default(true) bool onboardingCompleted,
    @JsonKey(name: 'streak_days') @Default(0) int streakDays,
    @JsonKey(name: 'artifact_balance') @Default({}) Map<String, int> artifactBalance,
    @JsonKey(name: 'buddy_count') @Default(0) int buddyCount,
    @JsonKey(name: 'following_count') @Default(0) int followingCount,
    @JsonKey(name: 'follower_count') @Default(0) int followerCount,
    @JsonKey(name: 'gym_count') @Default(0) int gymCount,
    @JsonKey(name: 'post_count') @Default(0) int postCount,
    @JsonKey(name: 'is_buddy') @Default(false) bool isBuddy,
    @JsonKey(name: 'buddy_status') String? buddyStatus,
    @JsonKey(name: 'is_following') @Default(false) bool isFollowing,
    @JsonKey(name: 'show_active_status') @Default(true) bool showActiveStatus,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}

@freezed
abstract class ProfileUpdatePayload with _$ProfileUpdatePayload {
  const factory ProfileUpdatePayload({
    String? displayName,
    String? bio,
    String? pronouns,
    String? locationCity,
    String? locationCountry,
    String? externalLink,
    String? workoutSchedule,
    @JsonKey(name: 'content_rating') @Default('general') String contentRating,
    bool? showActiveStatus,
    bool? isAnonymousPosting,
    String? privacyLevel,
  }) = _ProfileUpdatePayload;

  factory ProfileUpdatePayload.fromJson(Map<String, dynamic> json) =>
      _$ProfileUpdatePayloadFromJson(json);
}
