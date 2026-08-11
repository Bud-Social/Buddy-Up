// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gym.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OwnerData _$OwnerDataFromJson(Map<String, dynamic> json) => _OwnerData(
  userId: json['userId'] as String,
  username: json['username'] as String,
  displayName: json['displayName'] as String,
  avatarUrl: json['avatarUrl'] as String,
  role: json['role'] as String,
);

Map<String, dynamic> _$OwnerDataToJson(_OwnerData instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'username': instance.username,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'role': instance.role,
    };

_MemberData _$MemberDataFromJson(Map<String, dynamic> json) => _MemberData(
  userId: json['userId'] as String,
  username: json['username'] as String,
  displayName: json['displayName'] as String,
  avatarUrl: json['avatarUrl'] as String,
  verificationStatus: json['verificationStatus'] as String? ?? 'none',
);

Map<String, dynamic> _$MemberDataToJson(_MemberData instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'username': instance.username,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'verificationStatus': instance.verificationStatus,
    };

_GymCategory _$GymCategoryFromJson(Map<String, dynamic> json) => _GymCategory(
  id: json['id'] as String,
  name: json['name'] as String,
  displayName: json['displayName'] as String,
  icon: json['icon'] as String? ?? '',
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$GymCategoryToJson(_GymCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'displayName': instance.displayName,
      'icon': instance.icon,
      'isActive': instance.isActive,
    };

_GymCategoryPricing _$GymCategoryPricingFromJson(Map<String, dynamic> json) =>
    _GymCategoryPricing(
      id: json['id'] as String?,
      category: json['category'] as String,
      categoryName: json['categoryName'] as String?,
      feePerDay: (json['feePerDay'] as num?)?.toDouble(),
      feePerWeek: (json['feePerWeek'] as num?)?.toDouble(),
      feePerMonth: (json['feePerMonth'] as num?)?.toDouble(),
      feePerYear: (json['feePerYear'] as num?)?.toDouble(),
      isFree: json['isFree'] as bool? ?? false,
    );

Map<String, dynamic> _$GymCategoryPricingToJson(_GymCategoryPricing instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category': instance.category,
      'categoryName': instance.categoryName,
      'feePerDay': instance.feePerDay,
      'feePerWeek': instance.feePerWeek,
      'feePerMonth': instance.feePerMonth,
      'feePerYear': instance.feePerYear,
      'isFree': instance.isFree,
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
  accessType: json['accessType'] as String? ?? 'public',
  subscriptionType: json['subscriptionType'] as String? ?? 'free',
  isVerified: json['isVerified'] as bool? ?? false,
  isReviewsEnabled: json['isReviewsEnabled'] as bool? ?? true,
  isDonationsEnabled: json['isDonationsEnabled'] as bool? ?? false,
  averageRating: (json['averageRating'] as num?)?.toDouble(),
  reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
  recentReviewers:
      (json['recentReviewers'] as List<dynamic>?)
          ?.map((e) => MemberData.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <MemberData>[],
  rules:
      (json['rules'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
  activeToday: (json['activeToday'] as num?)?.toInt() ?? 0,
  locationCity: json['locationCity'] as String? ?? '',
  locationCountry: json['locationCountry'] as String? ?? '',
  ownerData:
      (json['ownerData'] as List<dynamic>?)
          ?.map((e) => OwnerData.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <OwnerData>[],
  membershipRole: json['membershipRole'] as String?,
  isMember: json['isMember'] as bool? ?? false,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String?,
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
  'accessType': instance.accessType,
  'subscriptionType': instance.subscriptionType,
  'isVerified': instance.isVerified,
  'isReviewsEnabled': instance.isReviewsEnabled,
  'isDonationsEnabled': instance.isDonationsEnabled,
  'averageRating': instance.averageRating,
  'reviewCount': instance.reviewCount,
  'recentReviewers': instance.recentReviewers,
  'rules': instance.rules,
  'tags': instance.tags,
  'memberCount': instance.memberCount,
  'activeToday': instance.activeToday,
  'locationCity': instance.locationCity,
  'locationCountry': instance.locationCountry,
  'ownerData': instance.ownerData,
  'membershipRole': instance.membershipRole,
  'isMember': instance.isMember,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

_GymMembership _$GymMembershipFromJson(Map<String, dynamic> json) =>
    _GymMembership(
      id: json['id'] as String,
      gymId: json['gymId'] as String,
      memberId: json['memberId'] as String,
      role: json['role'] as String? ?? 'member',
      subscriptionActive: json['subscriptionActive'] as bool? ?? false,
      subscriptionExpiresAt: json['subscriptionExpiresAt'] as String?,
      memberData: MemberData.fromJson(
        json['memberData'] as Map<String, dynamic>,
      ),
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$GymMembershipToJson(_GymMembership instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gymId': instance.gymId,
      'memberId': instance.memberId,
      'role': instance.role,
      'subscriptionActive': instance.subscriptionActive,
      'subscriptionExpiresAt': instance.subscriptionExpiresAt,
      'memberData': instance.memberData,
      'createdAt': instance.createdAt,
    };

_JoinRequest _$JoinRequestFromJson(Map<String, dynamic> json) => _JoinRequest(
  id: json['id'] as String,
  gymId: json['gymId'] as String,
  requester: json['requester'] as String,
  requesterData: MemberData.fromJson(
    json['requesterData'] as Map<String, dynamic>,
  ),
  message: json['message'] as String? ?? '',
  status: json['status'] as String? ?? 'pending',
  reviewedBy: json['reviewedBy'] as String?,
  reviewedAt: json['reviewedAt'] as String?,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$JoinRequestToJson(_JoinRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gymId': instance.gymId,
      'requester': instance.requester,
      'requesterData': instance.requesterData,
      'message': instance.message,
      'status': instance.status,
      'reviewedBy': instance.reviewedBy,
      'reviewedAt': instance.reviewedAt,
      'createdAt': instance.createdAt,
    };

_GymInvite _$GymInviteFromJson(Map<String, dynamic> json) => _GymInvite(
  id: json['id'] as String,
  gymId: json['gymId'] as String,
  invitedUser: json['invitedUser'] as String,
  invitedUserData: MemberData.fromJson(
    json['invitedUserData'] as Map<String, dynamic>,
  ),
  invitedBy: json['invitedBy'] as String,
  invitedByData: json['invitedByData'] as Map<String, dynamic>,
  status: json['status'] as String? ?? 'pending',
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$GymInviteToJson(_GymInvite instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gymId': instance.gymId,
      'invitedUser': instance.invitedUser,
      'invitedUserData': instance.invitedUserData,
      'invitedBy': instance.invitedBy,
      'invitedByData': instance.invitedByData,
      'status': instance.status,
      'createdAt': instance.createdAt,
    };

_CityResult _$CityResultFromJson(Map<String, dynamic> json) => _CityResult(
  placeId: json['placeId'] as String,
  city: json['city'] as String,
  country: json['country'] as String,
  description: json['description'] as String,
);

Map<String, dynamic> _$CityResultToJson(_CityResult instance) =>
    <String, dynamic>{
      'placeId': instance.placeId,
      'city': instance.city,
      'country': instance.country,
      'description': instance.description,
    };

_GymSchedulePost _$GymSchedulePostFromJson(Map<String, dynamic> json) =>
    _GymSchedulePost(
      id: json['id'] as String,
      gymId: json['gymId'] as String,
      author: json['author'] as String,
      authorData: MemberData.fromJson(
        json['authorData'] as Map<String, dynamic>,
      ),
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      activityType: json['activityType'] as String? ?? '',
      customActivityType: json['customActivityType'] as String? ?? '',
      locationMode: json['locationMode'] as String? ?? '',
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      recurrence: json['recurrence'] as String?,
      recurrenceEndDate: json['recurrenceEndDate'] as String?,
      recurrenceDays: json['recurrenceDays'] as String?,
      maxSlots: (json['maxSlots'] as num?)?.toInt() ?? 0,
      enrollmentCount: (json['enrollmentCount'] as num?)?.toInt() ?? 0,
      isEnrolled: json['isEnrolled'] as bool? ?? false,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$GymSchedulePostToJson(_GymSchedulePost instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gymId': instance.gymId,
      'author': instance.author,
      'authorData': instance.authorData,
      'title': instance.title,
      'content': instance.content,
      'activityType': instance.activityType,
      'customActivityType': instance.customActivityType,
      'locationMode': instance.locationMode,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'recurrence': instance.recurrence,
      'recurrenceEndDate': instance.recurrenceEndDate,
      'recurrenceDays': instance.recurrenceDays,
      'maxSlots': instance.maxSlots,
      'enrollmentCount': instance.enrollmentCount,
      'isEnrolled': instance.isEnrolled,
      'createdAt': instance.createdAt,
    };

_GymReview _$GymReviewFromJson(Map<String, dynamic> json) => _GymReview(
  id: json['id'] as String,
  gymId: json['gymId'] as String,
  reviewer: json['reviewer'] as String,
  reviewerData: MemberData.fromJson(
    json['reviewerData'] as Map<String, dynamic>,
  ),
  rating: (json['rating'] as num).toInt(),
  comment: json['comment'] as String? ?? '',
  replyText: json['replyText'] as String? ?? '',
  repliedBy: json['repliedBy'] as String?,
  repliedByData: json['repliedByData'] == null
      ? null
      : MemberData.fromJson(json['repliedByData'] as Map<String, dynamic>),
  repliedAt: json['repliedAt'] as String?,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$GymReviewToJson(_GymReview instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gymId': instance.gymId,
      'reviewer': instance.reviewer,
      'reviewerData': instance.reviewerData,
      'rating': instance.rating,
      'comment': instance.comment,
      'replyText': instance.replyText,
      'repliedBy': instance.repliedBy,
      'repliedByData': instance.repliedByData,
      'repliedAt': instance.repliedAt,
      'createdAt': instance.createdAt,
    };

_GymDonation _$GymDonationFromJson(Map<String, dynamic> json) => _GymDonation(
  id: json['id'] as String,
  gymId: json['gymId'] as String,
  donor: json['donor'] as String,
  donorData: MemberData.fromJson(json['donorData'] as Map<String, dynamic>),
  amount: json['amount'] as String,
  message: json['message'] as String? ?? '',
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$GymDonationToJson(_GymDonation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gymId': instance.gymId,
      'donor': instance.donor,
      'donorData': instance.donorData,
      'amount': instance.amount,
      'message': instance.message,
      'createdAt': instance.createdAt,
    };

_GymEvent _$GymEventFromJson(Map<String, dynamic> json) => _GymEvent(
  id: json['id'] as String,
  gymId: json['gymId'] as String,
  title: json['title'] as String,
  description: json['description'] as String? ?? '',
  startTime: json['startTime'] as String?,
  endTime: json['endTime'] as String?,
  location: json['location'] as String? ?? '',
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$GymEventToJson(_GymEvent instance) => <String, dynamic>{
  'id': instance.id,
  'gymId': instance.gymId,
  'title': instance.title,
  'description': instance.description,
  'startTime': instance.startTime,
  'endTime': instance.endTime,
  'location': instance.location,
  'createdAt': instance.createdAt,
};

_CreateGymPayload _$CreateGymPayloadFromJson(Map<String, dynamic> json) =>
    _CreateGymPayload(
      name: json['name'] as String,
      handle: json['handle'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      contentRating: json['content_rating'] as String? ?? 'general',
      categoryIds:
          (json['categoryIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      accessType: json['accessType'] as String? ?? 'public',
      subscriptionType: json['subscriptionType'] as String? ?? 'free',
      locationCity: json['locationCity'] as String?,
      locationCountry: json['locationCountry'] as String?,
      rules:
          (json['rules'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
      categoryPricing:
          (json['categoryPricing'] as List<dynamic>?)
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
      'categoryIds': instance.categoryIds,
      'accessType': instance.accessType,
      'subscriptionType': instance.subscriptionType,
      'locationCity': instance.locationCity,
      'locationCountry': instance.locationCountry,
      'rules': instance.rules,
      'tags': instance.tags,
      'categoryPricing': instance.categoryPricing,
    };
