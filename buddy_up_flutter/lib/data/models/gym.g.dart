// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gym.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OwnerData _$OwnerDataFromJson(Map<String, dynamic> json) => _OwnerData(
  userId: json['user_id'] as String,
  username: json['username'] as String,
  displayName: json['display_name'] as String,
  avatarUrl: json['avatar_url'] as String,
  role: json['role'] as String,
);

Map<String, dynamic> _$OwnerDataToJson(_OwnerData instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'username': instance.username,
      'display_name': instance.displayName,
      'avatar_url': instance.avatarUrl,
      'role': instance.role,
    };

_MemberData _$MemberDataFromJson(Map<String, dynamic> json) => _MemberData(
  userId: json['user_id'] as String,
  username: json['username'] as String,
  displayName: json['display_name'] as String,
  avatarUrl: json['avatar_url'] as String,
  verificationStatus: json['verification_status'] as String? ?? 'none',
);

Map<String, dynamic> _$MemberDataToJson(_MemberData instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'username': instance.username,
      'display_name': instance.displayName,
      'avatar_url': instance.avatarUrl,
      'verification_status': instance.verificationStatus,
    };

_GymCategory _$GymCategoryFromJson(Map<String, dynamic> json) => _GymCategory(
  id: _strId(json['id']),
  name: json['name'] as String,
  displayName: json['display_name'] as String,
  icon: json['icon'] as String? ?? '',
  isActive: json['is_active'] as bool? ?? true,
);

Map<String, dynamic> _$GymCategoryToJson(_GymCategory instance) =>
    <String, dynamic>{
      'id': _idToJson(instance.id),
      'name': instance.name,
      'display_name': instance.displayName,
      'icon': instance.icon,
      'is_active': instance.isActive,
    };

_GymCategoryPricing _$GymCategoryPricingFromJson(Map<String, dynamic> json) =>
    _GymCategoryPricing(
      id: _optStr(json['id']),
      category: _strId(json['category']),
      categoryName: json['category_name'] as String?,
      feePerDay: _optDouble(json['fee_per_day']),
      feePerWeek: _optDouble(json['fee_per_week']),
      feePerMonth: _optDouble(json['fee_per_month']),
      feePerYear: _optDouble(json['fee_per_year']),
      isFree: json['is_free'] as bool? ?? false,
    );

Map<String, dynamic> _$GymCategoryPricingToJson(_GymCategoryPricing instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category': _idToJson(instance.category),
      'category_name': instance.categoryName,
      'fee_per_day': instance.feePerDay,
      'fee_per_week': instance.feePerWeek,
      'fee_per_month': instance.feePerMonth,
      'fee_per_year': instance.feePerYear,
      'is_free': instance.isFree,
    };

_Gym _$GymFromJson(Map<String, dynamic> json) => _Gym(
  id: json['id'] as String,
  name: json['name'] as String,
  handle: json['handle'] as String,
  description: json['description'] as String? ?? '',
  logoUrl: json['logoUrl'] as String? ?? '',
  coverUrl: json['coverUrl'] as String? ?? '',
  category: json['category'] as String? ?? '',
  contentRating: json['content_rating'] as String? ?? 'general',
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map((e) => GymCategory.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <GymCategory>[],
  accessType: json['access_type'] as String? ?? 'public',
  subscriptionType: json['subscription_type'] as String? ?? 'free',
  isVerified: json['is_verified'] as bool? ?? false,
  isReviewsEnabled: json['is_reviews_enabled'] as bool? ?? true,
  isDonationsEnabled: json['is_donations_enabled'] as bool? ?? false,
  averageRating: (json['average_rating'] as num?)?.toDouble(),
  reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
  recentReviewers:
      (json['recent_reviewers'] as List<dynamic>?)
          ?.map((e) => MemberData.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <MemberData>[],
  rules:
      (json['rules'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  memberCount: (json['member_count'] as num?)?.toInt() ?? 0,
  activeToday: (json['active_today'] as num?)?.toInt() ?? 0,
  locationCity: json['location_city'] as String? ?? '',
  locationCountry: json['location_country'] as String? ?? '',
  deliveryModes:
      (json['delivery_modes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  distanceKm: (json['distance_km'] as num?)?.toDouble(),
  ownerData:
      (json['owner_data'] as List<dynamic>?)
          ?.map((e) => OwnerData.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <OwnerData>[],
  membershipRole: json['membership_role'] as String?,
  isMember: json['is_member'] as bool? ?? false,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$GymToJson(_Gym instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'handle': instance.handle,
  'description': instance.description,
  'logoUrl': instance.logoUrl,
  'coverUrl': instance.coverUrl,
  'category': instance.category,
  'content_rating': instance.contentRating,
  'categories': instance.categories,
  'access_type': instance.accessType,
  'subscription_type': instance.subscriptionType,
  'is_verified': instance.isVerified,
  'is_reviews_enabled': instance.isReviewsEnabled,
  'is_donations_enabled': instance.isDonationsEnabled,
  'average_rating': instance.averageRating,
  'review_count': instance.reviewCount,
  'recent_reviewers': instance.recentReviewers,
  'rules': instance.rules,
  'tags': instance.tags,
  'member_count': instance.memberCount,
  'active_today': instance.activeToday,
  'location_city': instance.locationCity,
  'location_country': instance.locationCountry,
  'delivery_modes': instance.deliveryModes,
  'distance_km': instance.distanceKm,
  'owner_data': instance.ownerData,
  'membership_role': instance.membershipRole,
  'is_member': instance.isMember,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

_GymMembership _$GymMembershipFromJson(Map<String, dynamic> json) =>
    _GymMembership(
      id: json['id'] as String,
      gymId: json['gym_id'] as String,
      memberId: json['member_id'] as String,
      role: json['role'] as String? ?? 'member',
      subscriptionActive: json['subscription_active'] as bool? ?? false,
      subscriptionExpiresAt: json['subscription_expires_at'] as String?,
      memberData: MemberData.fromJson(
        json['member_data'] as Map<String, dynamic>,
      ),
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$GymMembershipToJson(_GymMembership instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gym_id': instance.gymId,
      'member_id': instance.memberId,
      'role': instance.role,
      'subscription_active': instance.subscriptionActive,
      'subscription_expires_at': instance.subscriptionExpiresAt,
      'member_data': instance.memberData,
      'created_at': instance.createdAt,
    };

_JoinRequest _$JoinRequestFromJson(Map<String, dynamic> json) => _JoinRequest(
  id: json['id'] as String,
  gymId: json['gym_id'] as String,
  requester: json['requester'] as String,
  requesterData: MemberData.fromJson(
    json['requester_data'] as Map<String, dynamic>,
  ),
  message: json['message'] as String? ?? '',
  status: json['status'] as String? ?? 'pending',
  reviewedBy: json['reviewed_by'] as String?,
  reviewedAt: json['reviewed_at'] as String?,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$JoinRequestToJson(_JoinRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gym_id': instance.gymId,
      'requester': instance.requester,
      'requester_data': instance.requesterData,
      'message': instance.message,
      'status': instance.status,
      'reviewed_by': instance.reviewedBy,
      'reviewed_at': instance.reviewedAt,
      'created_at': instance.createdAt,
    };

_GymInvite _$GymInviteFromJson(Map<String, dynamic> json) => _GymInvite(
  id: json['id'] as String,
  gymId: json['gym_id'] as String,
  invitedUser: json['invited_user'] as String,
  invitedUserData: MemberData.fromJson(
    json['invited_user_data'] as Map<String, dynamic>,
  ),
  invitedBy: json['invited_by'] as String,
  invitedByData: json['invited_by_data'] as Map<String, dynamic>,
  status: json['status'] as String? ?? 'pending',
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$GymInviteToJson(_GymInvite instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gym_id': instance.gymId,
      'invited_user': instance.invitedUser,
      'invited_user_data': instance.invitedUserData,
      'invited_by': instance.invitedBy,
      'invited_by_data': instance.invitedByData,
      'status': instance.status,
      'created_at': instance.createdAt,
    };

_CityResult _$CityResultFromJson(Map<String, dynamic> json) => _CityResult(
  placeId: json['place_id'] as String,
  city: json['city'] as String,
  country: json['country'] as String? ?? '',
  description: json['description'] as String,
);

Map<String, dynamic> _$CityResultToJson(_CityResult instance) =>
    <String, dynamic>{
      'place_id': instance.placeId,
      'city': instance.city,
      'country': instance.country,
      'description': instance.description,
    };

_GymSchedulePost _$GymSchedulePostFromJson(Map<String, dynamic> json) =>
    _GymSchedulePost(
      id: json['id'] as String,
      gymId: json['gym_id'] as String,
      author: json['author'] as String,
      authorData: MemberData.fromJson(
        json['author_data'] as Map<String, dynamic>,
      ),
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      activityType: json['activity_type'] as String? ?? '',
      customActivityType: json['custom_activity_type'] as String? ?? '',
      locationMode: json['location_mode'] as String? ?? '',
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      recurrence: json['recurrence'] as String?,
      recurrenceEndDate: json['recurrence_end_date'] as String?,
      recurrenceDays: (json['recurrence_days'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      maxSlots: (json['max_slots'] as num?)?.toInt() ?? 0,
      enrollmentCount: (json['enrollment_count'] as num?)?.toInt() ?? 0,
      isEnrolled: json['is_enrolled'] as bool? ?? false,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$GymSchedulePostToJson(_GymSchedulePost instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gym_id': instance.gymId,
      'author': instance.author,
      'author_data': instance.authorData,
      'title': instance.title,
      'content': instance.content,
      'activity_type': instance.activityType,
      'custom_activity_type': instance.customActivityType,
      'location_mode': instance.locationMode,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'recurrence': instance.recurrence,
      'recurrence_end_date': instance.recurrenceEndDate,
      'recurrence_days': instance.recurrenceDays,
      'max_slots': instance.maxSlots,
      'enrollment_count': instance.enrollmentCount,
      'is_enrolled': instance.isEnrolled,
      'created_at': instance.createdAt,
    };

_GymReview _$GymReviewFromJson(Map<String, dynamic> json) => _GymReview(
  id: json['id'] as String,
  gymId: json['gym_id'] as String,
  reviewer: json['reviewer'] as String,
  reviewerData: MemberData.fromJson(
    json['reviewer_data'] as Map<String, dynamic>,
  ),
  rating: (json['rating'] as num).toInt(),
  comment: json['comment'] as String? ?? '',
  replyText: json['reply_text'] as String? ?? '',
  repliedBy: json['replied_by'] as String?,
  repliedByData: json['replied_by_data'] == null
      ? null
      : MemberData.fromJson(json['replied_by_data'] as Map<String, dynamic>),
  repliedAt: json['replied_at'] as String?,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$GymReviewToJson(_GymReview instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gym_id': instance.gymId,
      'reviewer': instance.reviewer,
      'reviewer_data': instance.reviewerData,
      'rating': instance.rating,
      'comment': instance.comment,
      'reply_text': instance.replyText,
      'replied_by': instance.repliedBy,
      'replied_by_data': instance.repliedByData,
      'replied_at': instance.repliedAt,
      'created_at': instance.createdAt,
    };

_GymDonation _$GymDonationFromJson(Map<String, dynamic> json) => _GymDonation(
  id: json['id'] as String,
  gymId: json['gym_id'] as String,
  donor: json['donor'] as String,
  donorData: MemberData.fromJson(json['donor_data'] as Map<String, dynamic>),
  amount: json['amount'] as String,
  message: json['message'] as String? ?? '',
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$GymDonationToJson(_GymDonation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gym_id': instance.gymId,
      'donor': instance.donor,
      'donor_data': instance.donorData,
      'amount': instance.amount,
      'message': instance.message,
      'created_at': instance.createdAt,
    };

_GymEvent _$GymEventFromJson(Map<String, dynamic> json) => _GymEvent(
  id: json['id'] as String,
  gymId: json['gym_id'] as String?,
  title: json['title'] as String,
  description: json['description'] as String? ?? '',
  startTime: json['start_datetime'] as String?,
  endTime: json['end_datetime'] as String?,
  location: json['location'] as String? ?? '',
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$GymEventToJson(_GymEvent instance) => <String, dynamic>{
  'id': instance.id,
  'gym_id': instance.gymId,
  'title': instance.title,
  'description': instance.description,
  'start_datetime': instance.startTime,
  'end_datetime': instance.endTime,
  'location': instance.location,
  'created_at': instance.createdAt,
};

_CreateGymPayload _$CreateGymPayloadFromJson(Map<String, dynamic> json) =>
    _CreateGymPayload(
      name: json['name'] as String,
      handle: json['handle'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      contentRating: json['content_rating'] as String? ?? 'general',
      categoryIds:
          (json['category_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      accessType: json['access_type'] as String? ?? 'public',
      subscriptionType: json['subscription_type'] as String? ?? 'free',
      locationCity: json['location_city'] as String?,
      locationCountry: json['location_country'] as String?,
      rules:
          (json['rules'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
      categoryPricing:
          (json['category_pricing'] as List<dynamic>?)
              ?.map(
                (e) => GymCategoryPricing.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <GymCategoryPricing>[],
    );

Map<String, dynamic> _$CreateGymPayloadToJson(_CreateGymPayload instance) =>
    <String, dynamic>{
      'name': instance.name,
      'handle': instance.handle,
      'description': instance.description,
      'category': instance.category,
      'content_rating': instance.contentRating,
      'category_ids': instance.categoryIds,
      'access_type': instance.accessType,
      'subscription_type': instance.subscriptionType,
      'location_city': instance.locationCity,
      'location_country': instance.locationCountry,
      'rules': instance.rules,
      'tags': instance.tags,
      'category_pricing': instance.categoryPricing,
    };
