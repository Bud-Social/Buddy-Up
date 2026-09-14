// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Profile _$ProfileFromJson(Map<String, dynamic> json) => _Profile(
  userId: json['user_id'] as String,
  username: json['username'] as String,
  displayName: json['display_name'] as String,
  bio: json['bio'] as String? ?? '',
  avatarUrl: json['avatar_url'] as String? ?? '',
  coverUrl: json['cover_url'] as String? ?? '',
  pronouns: json['pronouns'] as String? ?? '',
  locationCity: json['location_city'] as String? ?? '',
  locationCountry: json['location_country'] as String? ?? '',
  externalLink: json['external_link'] as String?,
  contentRating: json['content_rating'] as String? ?? 'general',
  role: json['role'] as String? ?? 'user',
  verificationStatus: json['verification_status'] as String? ?? 'none',
  privacyLevel: json['privacy_level'] as String? ?? 'public',
  onboardingCompleted: json['onboarding_completed'] as bool? ?? true,
  streakDays: (json['streak_days'] as num?)?.toInt() ?? 0,
  artifactBalance:
      (json['artifact_balance'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
  buddyCount: (json['buddy_count'] as num?)?.toInt() ?? 0,
  followingCount: (json['following_count'] as num?)?.toInt() ?? 0,
  followerCount: (json['follower_count'] as num?)?.toInt() ?? 0,
  gymCount: (json['gym_count'] as num?)?.toInt() ?? 0,
  postCount: (json['post_count'] as num?)?.toInt() ?? 0,
  isBuddy: json['is_buddy'] as bool? ?? false,
  buddyStatus: json['buddy_status'] as String?,
  isFollowing: json['is_following'] as bool? ?? false,
  showActiveStatus: json['show_active_status'] as bool? ?? true,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$ProfileToJson(_Profile instance) => <String, dynamic>{
  'user_id': instance.userId,
  'username': instance.username,
  'display_name': instance.displayName,
  'bio': instance.bio,
  'avatar_url': instance.avatarUrl,
  'cover_url': instance.coverUrl,
  'pronouns': instance.pronouns,
  'location_city': instance.locationCity,
  'location_country': instance.locationCountry,
  'external_link': instance.externalLink,
  'content_rating': instance.contentRating,
  'role': instance.role,
  'verification_status': instance.verificationStatus,
  'privacy_level': instance.privacyLevel,
  'onboarding_completed': instance.onboardingCompleted,
  'streak_days': instance.streakDays,
  'artifact_balance': instance.artifactBalance,
  'buddy_count': instance.buddyCount,
  'following_count': instance.followingCount,
  'follower_count': instance.followerCount,
  'gym_count': instance.gymCount,
  'post_count': instance.postCount,
  'is_buddy': instance.isBuddy,
  'buddy_status': instance.buddyStatus,
  'is_following': instance.isFollowing,
  'show_active_status': instance.showActiveStatus,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

_ProfileUpdatePayload _$ProfileUpdatePayloadFromJson(
  Map<String, dynamic> json,
) => _ProfileUpdatePayload(
  displayName: json['displayName'] as String?,
  bio: json['bio'] as String?,
  pronouns: json['pronouns'] as String?,
  locationCity: json['locationCity'] as String?,
  locationCountry: json['locationCountry'] as String?,
  externalLink: json['externalLink'] as String?,
  workoutSchedule: json['workoutSchedule'] as String?,
  contentRating: json['content_rating'] as String? ?? 'general',
  showActiveStatus: json['showActiveStatus'] as bool?,
  isAnonymousPosting: json['isAnonymousPosting'] as bool?,
  privacyLevel: json['privacyLevel'] as String?,
);

Map<String, dynamic> _$ProfileUpdatePayloadToJson(
  _ProfileUpdatePayload instance,
) => <String, dynamic>{
  'displayName': instance.displayName,
  'bio': instance.bio,
  'pronouns': instance.pronouns,
  'locationCity': instance.locationCity,
  'locationCountry': instance.locationCountry,
  'externalLink': instance.externalLink,
  'workoutSchedule': instance.workoutSchedule,
  'content_rating': instance.contentRating,
  'showActiveStatus': instance.showActiveStatus,
  'isAnonymousPosting': instance.isAnonymousPosting,
  'privacyLevel': instance.privacyLevel,
};
