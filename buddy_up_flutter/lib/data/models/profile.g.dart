// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Profile _$ProfileFromJson(Map<String, dynamic> json) => _Profile(
  userId: json['userId'] as String,
  username: json['username'] as String,
  displayName: json['displayName'] as String,
  bio: json['bio'] as String? ?? '',
  avatarUrl: json['avatarUrl'] as String? ?? '',
  coverUrl: json['coverUrl'] as String? ?? '',
  pronouns: json['pronouns'] as String? ?? '',
  locationCity: json['locationCity'] as String? ?? '',
  locationCountry: json['locationCountry'] as String? ?? '',
  externalLink: json['externalLink'] as String?,
  contentRating: json['content_rating'] as String? ?? 'general',
  role: json['role'] as String? ?? 'user',
  verificationStatus: json['verificationStatus'] as String? ?? 'none',
  privacyLevel: json['privacyLevel'] as String? ?? 'public',
  streakDays: (json['streakDays'] as num?)?.toInt() ?? 0,
  artifactBalance:
      (json['artifactBalance'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
  buddyCount: (json['buddyCount'] as num?)?.toInt() ?? 0,
  followingCount: (json['followingCount'] as num?)?.toInt() ?? 0,
  followerCount: (json['followerCount'] as num?)?.toInt() ?? 0,
  gymCount: (json['gymCount'] as num?)?.toInt() ?? 0,
  postCount: (json['postCount'] as num?)?.toInt() ?? 0,
  isBuddy: json['isBuddy'] as bool? ?? false,
  buddyStatus: json['buddyStatus'] as String?,
  isFollowing: json['isFollowing'] as bool? ?? false,
  showActiveStatus: json['showActiveStatus'] as bool? ?? true,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$ProfileToJson(_Profile instance) => <String, dynamic>{
  'userId': instance.userId,
  'username': instance.username,
  'displayName': instance.displayName,
  'bio': instance.bio,
  'avatarUrl': instance.avatarUrl,
  'coverUrl': instance.coverUrl,
  'pronouns': instance.pronouns,
  'locationCity': instance.locationCity,
  'locationCountry': instance.locationCountry,
  'externalLink': instance.externalLink,
  'content_rating': instance.contentRating,
  'role': instance.role,
  'verificationStatus': instance.verificationStatus,
  'privacyLevel': instance.privacyLevel,
  'streakDays': instance.streakDays,
  'artifactBalance': instance.artifactBalance,
  'buddyCount': instance.buddyCount,
  'followingCount': instance.followingCount,
  'followerCount': instance.followerCount,
  'gymCount': instance.gymCount,
  'postCount': instance.postCount,
  'isBuddy': instance.isBuddy,
  'buddyStatus': instance.buddyStatus,
  'isFollowing': instance.isFollowing,
  'showActiveStatus': instance.showActiveStatus,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
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
