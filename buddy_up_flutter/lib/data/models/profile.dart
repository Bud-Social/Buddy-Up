import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    required String userId,
    required String username,
    required String displayName,
    @Default('') String bio,
    @Default('') String avatarUrl,
    @Default('') String coverUrl,
    @Default('') String pronouns,
    @Default('') String locationCity,
    @Default('') String locationCountry,
    String? externalLink,
    @Default('user') String role,
    @Default('none') String verificationStatus,
    @Default('public') String privacyLevel,
    @Default(0) int streakDays,
    @Default({}) Map<String, int> artifactBalance,
    @Default(0) int buddyCount,
    @Default(0) int followingCount,
    @Default(0) int followerCount,
    @Default(0) int gymCount,
    @Default(0) int postCount,
    @Default(false) bool isBuddy,
    String? buddyStatus,
    @Default(false) bool isFollowing,
    @Default(true) bool showActiveStatus,
    String? createdAt,
    String? updatedAt,
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
    bool? showActiveStatus,
    bool? isAnonymousPosting,
    String? privacyLevel,
  }) = _ProfileUpdatePayload;

  factory ProfileUpdatePayload.fromJson(Map<String, dynamic> json) =>
      _$ProfileUpdatePayloadFromJson(json);
}
