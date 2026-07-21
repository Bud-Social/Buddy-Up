// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marketplace.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreatorData _$CreatorDataFromJson(Map<String, dynamic> json) => _CreatorData(
  username: json['username'] as String,
  displayName: json['displayName'] as String,
  avatarUrl: json['avatar_url'] as String,
  verificationStatus: json['verification_status'] as String? ?? '',
);

Map<String, dynamic> _$CreatorDataToJson(_CreatorData instance) =>
    <String, dynamic>{
      'username': instance.username,
      'displayName': instance.displayName,
      'avatar_url': instance.avatarUrl,
      'verification_status': instance.verificationStatus,
    };

_BuyerData _$BuyerDataFromJson(Map<String, dynamic> json) => _BuyerData(
  username: json['username'] as String,
  displayName: json['displayName'] as String,
  avatarUrl: json['avatar_url'] as String,
);

Map<String, dynamic> _$BuyerDataToJson(_BuyerData instance) =>
    <String, dynamic>{
      'username': instance.username,
      'displayName': instance.displayName,
      'avatar_url': instance.avatarUrl,
    };

_MealPlan _$MealPlanFromJson(Map<String, dynamic> json) => _MealPlan(
  id: json['id'] as String,
  creatorId: json['creator_id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  coverImageUrl: json['cover_image_url'] as String,
  dietType: json['diet_type'] as String,
  durationWeeks: (json['duration_weeks'] as num).toInt(),
  calorieRange: json['calorie_range'] as String,
  priceArtifacts: Map<String, int>.from(json['price_artifacts'] as Map),
  previewDay: json['preview_day'] as Map<String, dynamic>,
  fullPlan: json['full_plan'] as Map<String, dynamic>?,
  shoppingList:
      (json['shopping_list'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  purchaseCount: (json['purchase_count'] as num?)?.toInt() ?? 0,
  averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
  reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
  creatorData: CreatorData.fromJson(
    json['creator_data'] as Map<String, dynamic>,
  ),
  isPurchased: json['is_purchased'] as bool? ?? false,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$MealPlanToJson(_MealPlan instance) => <String, dynamic>{
  'id': instance.id,
  'creator_id': instance.creatorId,
  'title': instance.title,
  'description': instance.description,
  'cover_image_url': instance.coverImageUrl,
  'diet_type': instance.dietType,
  'duration_weeks': instance.durationWeeks,
  'calorie_range': instance.calorieRange,
  'price_artifacts': instance.priceArtifacts,
  'preview_day': instance.previewDay,
  'full_plan': instance.fullPlan,
  'shopping_list': instance.shoppingList,
  'purchase_count': instance.purchaseCount,
  'average_rating': instance.averageRating,
  'review_count': instance.reviewCount,
  'creator_data': instance.creatorData,
  'is_purchased': instance.isPurchased,
  'created_at': instance.createdAt,
};

_MealPlanReview _$MealPlanReviewFromJson(Map<String, dynamic> json) =>
    _MealPlanReview(
      id: json['id'] as String,
      rating: (json['rating'] as num).toInt(),
      body: json['body'] as String?,
      buyerData: BuyerData.fromJson(json['buyer_data'] as Map<String, dynamic>),
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$MealPlanReviewToJson(_MealPlanReview instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rating': instance.rating,
      'body': instance.body,
      'buyer_data': instance.buyerData,
      'created_at': instance.createdAt,
    };

_TrainingProgramme _$TrainingProgrammeFromJson(Map<String, dynamic> json) =>
    _TrainingProgramme(
      id: json['id'] as String,
      creatorId: json['creator_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      coverImageUrl: json['cover_image_url'] as String,
      category: json['category'] as String,
      durationWeeks: (json['duration_weeks'] as num).toInt(),
      priceArtifacts: Map<String, int>.from(json['price_artifacts'] as Map),
      purchaseCount: (json['purchase_count'] as num?)?.toInt() ?? 0,
      creatorData: CreatorData.fromJson(
        json['creator_data'] as Map<String, dynamic>,
      ),
      isPurchased: json['is_purchased'] as bool? ?? false,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$TrainingProgrammeToJson(_TrainingProgramme instance) =>
    <String, dynamic>{
      'id': instance.id,
      'creator_id': instance.creatorId,
      'title': instance.title,
      'description': instance.description,
      'cover_image_url': instance.coverImageUrl,
      'category': instance.category,
      'duration_weeks': instance.durationWeeks,
      'price_artifacts': instance.priceArtifacts,
      'purchase_count': instance.purchaseCount,
      'creator_data': instance.creatorData,
      'is_purchased': instance.isPurchased,
      'created_at': instance.createdAt,
    };

_TrainingProgrammeReview _$TrainingProgrammeReviewFromJson(
  Map<String, dynamic> json,
) => _TrainingProgrammeReview(
  id: json['id'] as String,
  rating: (json['rating'] as num).toInt(),
  body: json['body'] as String?,
  buyerData: BuyerData.fromJson(json['buyer_data'] as Map<String, dynamic>),
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$TrainingProgrammeReviewToJson(
  _TrainingProgrammeReview instance,
) => <String, dynamic>{
  'id': instance.id,
  'rating': instance.rating,
  'body': instance.body,
  'buyer_data': instance.buyerData,
  'created_at': instance.createdAt,
};

_MarketplaceProduct _$MarketplaceProductFromJson(Map<String, dynamic> json) =>
    _MarketplaceProduct(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      imageUrl: json['image_url'] as String,
      affiliateUrl: json['affiliate_url'] as String,
      priceDisplay: json['price_display'] as String,
      recommendedBy: json['recommended_by'] as String?,
      recommenderData: json['recommender_data'] as Map<String, dynamic>?,
      clickCount: (json['click_count'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$MarketplaceProductToJson(_MarketplaceProduct instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'brand': instance.brand,
      'description': instance.description,
      'category': instance.category,
      'image_url': instance.imageUrl,
      'affiliate_url': instance.affiliateUrl,
      'price_display': instance.priceDisplay,
      'recommended_by': instance.recommendedBy,
      'recommender_data': instance.recommenderData,
      'click_count': instance.clickCount,
      'created_at': instance.createdAt,
    };

_GymData _$GymDataFromJson(Map<String, dynamic> json) => _GymData(
  id: json['id'] as String,
  name: json['name'] as String,
  handle: json['handle'] as String,
  logoUrl: json['logo_url'] as String,
);

Map<String, dynamic> _$GymDataToJson(_GymData instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'handle': instance.handle,
  'logo_url': instance.logoUrl,
};

_MarketplaceEvent _$MarketplaceEventFromJson(Map<String, dynamic> json) =>
    _MarketplaceEvent(
      id: json['id'] as String,
      creatorData: CreatorData.fromJson(
        json['creator_data'] as Map<String, dynamic>,
      ),
      gymData: json['gym_data'] == null
          ? null
          : GymData.fromJson(json['gym_data'] as Map<String, dynamic>),
      title: json['title'] as String,
      description: json['description'] as String,
      coverImageUrl: json['cover_image_url'] as String,
      eventType: json['event_type'] as String,
      location: json['location'] as String,
      onlineUrl: json['online_url'] as String,
      startDatetime: json['start_datetime'] as String,
      endDatetime: json['end_datetime'] as String,
      timezone: json['timezone'] as String,
      capacity: (json['capacity'] as num).toInt(),
      ticketPriceArtifacts: Map<String, int>.from(
        json['ticket_price_artifacts'] as Map,
      ),
      isFree: json['is_free'] as bool? ?? false,
      isPublished: json['is_published'] as bool? ?? false,
      isCancelled: json['is_cancelled'] as bool? ?? false,
      attendeeCount: (json['attendee_count'] as num?)?.toInt() ?? 0,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
      category: json['category'] as String? ?? '',
      isRegistered: json['is_registered'] as bool? ?? false,
      spotsRemaining: (json['spots_remaining'] as num?)?.toInt(),
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$MarketplaceEventToJson(_MarketplaceEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'creator_data': instance.creatorData,
      'gym_data': instance.gymData,
      'title': instance.title,
      'description': instance.description,
      'cover_image_url': instance.coverImageUrl,
      'event_type': instance.eventType,
      'location': instance.location,
      'online_url': instance.onlineUrl,
      'start_datetime': instance.startDatetime,
      'end_datetime': instance.endDatetime,
      'timezone': instance.timezone,
      'capacity': instance.capacity,
      'ticket_price_artifacts': instance.ticketPriceArtifacts,
      'is_free': instance.isFree,
      'is_published': instance.isPublished,
      'is_cancelled': instance.isCancelled,
      'attendee_count': instance.attendeeCount,
      'tags': instance.tags,
      'category': instance.category,
      'is_registered': instance.isRegistered,
      'spots_remaining': instance.spotsRemaining,
      'created_at': instance.createdAt,
    };

_EventTicket _$EventTicketFromJson(Map<String, dynamic> json) => _EventTicket(
  id: json['id'] as String,
  eventData: json['event_data'] as Map<String, dynamic>?,
  holderData: json['holder_data'] as Map<String, dynamic>?,
  ticketCode: json['ticket_code'] as String,
  tier: json['tier'] as String? ?? '',
  pricePaidArtifacts: (json['price_paid_artifacts'] as Map<String, dynamic>?)
      ?.map((k, e) => MapEntry(k, (e as num).toInt())),
  status: json['status'] as String? ?? 'active',
  isCheckedIn: json['is_checked_in'] as bool? ?? false,
  checkedInAt: json['checked_in_at'] as String?,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$EventTicketToJson(_EventTicket instance) =>
    <String, dynamic>{
      'id': instance.id,
      'event_data': instance.eventData,
      'holder_data': instance.holderData,
      'ticket_code': instance.ticketCode,
      'tier': instance.tier,
      'price_paid_artifacts': instance.pricePaidArtifacts,
      'status': instance.status,
      'is_checked_in': instance.isCheckedIn,
      'checked_in_at': instance.checkedInAt,
      'created_at': instance.createdAt,
    };

_CartItem _$CartItemFromJson(Map<String, dynamic> json) => _CartItem(
  id: json['id'] as String,
  itemType: json['item_type'] as String,
  mealPlan: json['meal_plan'] == null
      ? null
      : MealPlan.fromJson(json['meal_plan'] as Map<String, dynamic>),
  programme: json['programme'] == null
      ? null
      : TrainingProgramme.fromJson(json['programme'] as Map<String, dynamic>),
  product: json['product'] == null
      ? null
      : MarketplaceProduct.fromJson(json['product'] as Map<String, dynamic>),
  event: json['event'] == null
      ? null
      : MarketplaceEvent.fromJson(json['event'] as Map<String, dynamic>),
  quantity: (json['quantity'] as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$CartItemToJson(_CartItem instance) => <String, dynamic>{
  'id': instance.id,
  'item_type': instance.itemType,
  'meal_plan': instance.mealPlan,
  'programme': instance.programme,
  'product': instance.product,
  'event': instance.event,
  'quantity': instance.quantity,
};

_Cart _$CartFromJson(Map<String, dynamic> json) => _Cart(
  id: json['id'] as String,
  items: (json['items'] as List<dynamic>)
      .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  discountCode: json['discount_code'] == null
      ? null
      : DiscountCode.fromJson(json['discount_code'] as Map<String, dynamic>),
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$CartToJson(_Cart instance) => <String, dynamic>{
  'id': instance.id,
  'items': instance.items,
  'discount_code': instance.discountCode,
  'created_at': instance.createdAt,
};

_DiscountCode _$DiscountCodeFromJson(Map<String, dynamic> json) =>
    _DiscountCode(
      code: json['code'] as String,
      discountPct: (json['discount_pct'] as num?)?.toInt() ?? 0,
      discountArtifacts: (json['discount_artifacts'] as Map<String, dynamic>?)
          ?.map((k, e) => MapEntry(k, (e as num).toInt())),
    );

Map<String, dynamic> _$DiscountCodeToJson(_DiscountCode instance) =>
    <String, dynamic>{
      'code': instance.code,
      'discount_pct': instance.discountPct,
      'discount_artifacts': instance.discountArtifacts,
    };

_FoodItem _$FoodItemFromJson(Map<String, dynamic> json) => _FoodItem(
  item: json['item'] as String,
  confidence: (json['confidence'] as num).toDouble(),
  nutrition: json['nutrition'] as Map<String, dynamic>,
);

Map<String, dynamic> _$FoodItemToJson(_FoodItem instance) => <String, dynamic>{
  'item': instance.item,
  'confidence': instance.confidence,
  'nutrition': instance.nutrition,
};

_FoodRecognitionResult _$FoodRecognitionResultFromJson(
  Map<String, dynamic> json,
) => _FoodRecognitionResult(
  items: (json['items'] as List<dynamic>)
      .map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalCalories: (json['total_calories'] as num).toDouble(),
  totalProtein: (json['total_protein'] as num).toDouble(),
  totalCarbs: (json['total_carbs'] as num).toDouble(),
  totalFat: (json['total_fat'] as num).toDouble(),
  healthBenefits:
      (json['health_benefits'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  method: json['method'] as String? ?? '',
);

Map<String, dynamic> _$FoodRecognitionResultToJson(
  _FoodRecognitionResult instance,
) => <String, dynamic>{
  'items': instance.items,
  'total_calories': instance.totalCalories,
  'total_protein': instance.totalProtein,
  'total_carbs': instance.totalCarbs,
  'total_fat': instance.totalFat,
  'health_benefits': instance.healthBenefits,
  'method': instance.method,
};

_CreatorServices _$CreatorServicesFromJson(Map<String, dynamic> json) =>
    _CreatorServices(
      mealPlans:
          (json['meal_plans'] as List<dynamic>?)
              ?.map((e) => MealPlan.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <MealPlan>[],
      programmes:
          (json['programmes'] as List<dynamic>?)
              ?.map(
                (e) => TrainingProgramme.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <TrainingProgramme>[],
      events:
          (json['events'] as List<dynamic>?)
              ?.map((e) => MarketplaceEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <MarketplaceEvent>[],
    );

Map<String, dynamic> _$CreatorServicesToJson(_CreatorServices instance) =>
    <String, dynamic>{
      'meal_plans': instance.mealPlans,
      'programmes': instance.programmes,
      'events': instance.events,
    };

_ProductPayload _$ProductPayloadFromJson(Map<String, dynamic> json) =>
    _ProductPayload(
      name: json['name'] as String,
      brand: json['brand'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      imageUrl: json['image_url'] as String,
      affiliateUrl: json['affiliate_url'] as String,
      priceDisplay: json['price_display'] as String,
    );

Map<String, dynamic> _$ProductPayloadToJson(_ProductPayload instance) =>
    <String, dynamic>{
      'name': instance.name,
      'brand': instance.brand,
      'description': instance.description,
      'category': instance.category,
      'image_url': instance.imageUrl,
      'affiliate_url': instance.affiliateUrl,
      'price_display': instance.priceDisplay,
    };

_EventPayload _$EventPayloadFromJson(Map<String, dynamic> json) =>
    _EventPayload(
      title: json['title'] as String,
      description: json['description'] as String,
      eventType: json['event_type'] as String,
      location: json['location'] as String,
      onlineUrl: json['online_url'] as String?,
      startDatetime: json['start_datetime'] as String,
      endDatetime: json['end_datetime'] as String,
      timezone: json['timezone'] as String,
      capacity: (json['capacity'] as num).toInt(),
      gymId: json['gymId'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
      category: json['category'] as String? ?? '',
    );

Map<String, dynamic> _$EventPayloadToJson(_EventPayload instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'event_type': instance.eventType,
      'location': instance.location,
      'online_url': instance.onlineUrl,
      'start_datetime': instance.startDatetime,
      'end_datetime': instance.endDatetime,
      'timezone': instance.timezone,
      'capacity': instance.capacity,
      'gymId': instance.gymId,
      'tags': instance.tags,
      'category': instance.category,
    };

_CheckoutResponse _$CheckoutResponseFromJson(
  Map<String, dynamic> json,
) => _CheckoutResponse(
  status: json['status'] as String,
  purchased:
      (json['purchased'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  errors:
      (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
);

Map<String, dynamic> _$CheckoutResponseToJson(_CheckoutResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'purchased': instance.purchased,
      'errors': instance.errors,
    };
