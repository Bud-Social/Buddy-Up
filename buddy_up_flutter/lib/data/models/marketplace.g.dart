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

_Shop _$ShopFromJson(Map<String, dynamic> json) => _Shop(
  id: json['id'] as String,
  handle: json['handle'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  logoUrl: json['logo_url'] as String?,
  bannerUrl: json['banner_url'] as String?,
  accentColor: json['accent_color'] as String? ?? '#6366f1',
  contactEmail: json['contact_email'] as String? ?? '',
  contactPhone: json['contact_phone'] as String? ?? '',
  websiteUrl: json['website_url'] as String? ?? '',
  socialLinks:
      (json['social_links'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  category: json['category'] as String? ?? '',
  verificationStatus: json['verification_status'] as String? ?? 'unverified',
  isActive: json['is_active'] as bool? ?? true,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$ShopToJson(_Shop instance) => <String, dynamic>{
  'id': instance.id,
  'handle': instance.handle,
  'name': instance.name,
  'description': instance.description,
  'logo_url': instance.logoUrl,
  'banner_url': instance.bannerUrl,
  'accent_color': instance.accentColor,
  'contact_email': instance.contactEmail,
  'contact_phone': instance.contactPhone,
  'website_url': instance.websiteUrl,
  'social_links': instance.socialLinks,
  'category': instance.category,
  'verification_status': instance.verificationStatus,
  'is_active': instance.isActive,
  'created_at': instance.createdAt,
};

_UserShopResponse _$UserShopResponseFromJson(
  Map<String, dynamic> json,
) => _UserShopResponse(
  shop: Shop.fromJson(json['shop'] as Map<String, dynamic>),
  mealPlans:
      (json['meal_plans'] as List<dynamic>?)
          ?.map((e) => MealPlan.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <MealPlan>[],
  programmes:
      (json['programmes'] as List<dynamic>?)
          ?.map((e) => TrainingProgramme.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <TrainingProgramme>[],
  events:
      (json['events'] as List<dynamic>?)
          ?.map((e) => MarketplaceEvent.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <MarketplaceEvent>[],
  products:
      (json['products'] as List<dynamic>?)
          ?.map((e) => MarketplaceProduct.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <MarketplaceProduct>[],
);

Map<String, dynamic> _$UserShopResponseToJson(_UserShopResponse instance) =>
    <String, dynamic>{
      'shop': instance.shop,
      'meal_plans': instance.mealPlans,
      'programmes': instance.programmes,
      'events': instance.events,
      'products': instance.products,
    };

_BuddyUpCertification _$BuddyUpCertificationFromJson(
  Map<String, dynamic> json,
) => _BuddyUpCertification(
  id: json['id'] as String,
  shopId: json['shop_id'] as String,
  status: json['status'] as String,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$BuddyUpCertificationToJson(
  _BuddyUpCertification instance,
) => <String, dynamic>{
  'id': instance.id,
  'shop_id': instance.shopId,
  'status': instance.status,
  'notes': instance.notes,
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
  contentRating: json['content_rating'] as String? ?? 'general',
  purchaseCount: (json['purchase_count'] as num?)?.toInt() ?? 0,
  averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
  reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
  creatorData: CreatorData.fromJson(
    json['creator_data'] as Map<String, dynamic>,
  ),
  isPurchased: json['is_purchased'] as bool? ?? false,
  isPublished: json['is_published'] as bool? ?? true,
  shopData: json['shop_data'] == null
      ? null
      : Shop.fromJson(json['shop_data'] as Map<String, dynamic>),
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
  'content_rating': instance.contentRating,
  'purchase_count': instance.purchaseCount,
  'average_rating': instance.averageRating,
  'review_count': instance.reviewCount,
  'creator_data': instance.creatorData,
  'is_purchased': instance.isPurchased,
  'is_published': instance.isPublished,
  'shop_data': instance.shopData,
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
      isPublished: json['is_published'] as bool? ?? true,
      shopData: json['shop_data'] == null
          ? null
          : Shop.fromJson(json['shop_data'] as Map<String, dynamic>),
      contentRating: json['content_rating'] as String? ?? 'general',
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
      'is_published': instance.isPublished,
      'shop_data': instance.shopData,
      'content_rating': instance.contentRating,
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
      contentRating: json['content_rating'] as String? ?? 'general',
      recommendedBy: json['recommended_by'] as String?,
      recommenderData: json['recommender_data'] as Map<String, dynamic>?,
      clickCount: (json['click_count'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      shopData: json['shop_data'] == null
          ? null
          : Shop.fromJson(json['shop_data'] as Map<String, dynamic>),
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
      'content_rating': instance.contentRating,
      'recommended_by': instance.recommendedBy,
      'recommender_data': instance.recommenderData,
      'click_count': instance.clickCount,
      'is_active': instance.isActive,
      'shop_data': instance.shopData,
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

_EventMediaItem _$EventMediaItemFromJson(Map<String, dynamic> json) =>
    _EventMediaItem(
      id: json['id'] as String,
      mediaType: json['media_type'] as String? ?? 'image',
      url: json['url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String? ?? '',
      altText: json['alt_text'] as String? ?? '',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$EventMediaItemToJson(_EventMediaItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'media_type': instance.mediaType,
      'url': instance.url,
      'thumbnail_url': instance.thumbnailUrl,
      'alt_text': instance.altText,
      'sort_order': instance.sortOrder,
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
      promoVideoUrl: json['promo_video_url'] as String? ?? '',
      galleryUrls:
          (json['gallery_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      eventType: json['event_type'] as String,
      location: json['location'] as String,
      onlineUrl: json['online_url'] as String,
      startDatetime: json['start_datetime'] as String,
      endDatetime: json['end_datetime'] as String,
      timezone: json['timezone'] as String,
      recurrence: json['recurrence'] as String? ?? 'none',
      ticketTiers:
          (json['ticket_tiers'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const <Map<String, dynamic>>[],
      agenda:
          (json['agenda'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const <Map<String, dynamic>>[],
      cancellationPolicy: json['cancellationPolicy'] as String? ?? '',
      earlyBirdEnabled: json['early_bird_enabled'] as bool? ?? false,
      earlyBirdDeadline: json['early_bird_deadline'] as String?,
      earlyBirdPriceArtifacts:
          (json['early_bird_price_artifacts'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const <String, int>{},
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
      contentRating: json['content_rating'] as String? ?? 'general',
      isRegistered: json['is_registered'] as bool? ?? false,
      spotsRemaining: (json['spots_remaining'] as num?)?.toInt(),
      shopData: json['shop_data'] == null
          ? null
          : Shop.fromJson(json['shop_data'] as Map<String, dynamic>),
      media:
          (json['media'] as List<dynamic>?)
              ?.map((e) => EventMediaItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <EventMediaItem>[],
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
      'promo_video_url': instance.promoVideoUrl,
      'gallery_urls': instance.galleryUrls,
      'event_type': instance.eventType,
      'location': instance.location,
      'online_url': instance.onlineUrl,
      'start_datetime': instance.startDatetime,
      'end_datetime': instance.endDatetime,
      'timezone': instance.timezone,
      'recurrence': instance.recurrence,
      'ticket_tiers': instance.ticketTiers,
      'agenda': instance.agenda,
      'cancellationPolicy': instance.cancellationPolicy,
      'early_bird_enabled': instance.earlyBirdEnabled,
      'early_bird_deadline': instance.earlyBirdDeadline,
      'early_bird_price_artifacts': instance.earlyBirdPriceArtifacts,
      'capacity': instance.capacity,
      'ticket_price_artifacts': instance.ticketPriceArtifacts,
      'is_free': instance.isFree,
      'is_published': instance.isPublished,
      'is_cancelled': instance.isCancelled,
      'attendee_count': instance.attendeeCount,
      'tags': instance.tags,
      'category': instance.category,
      'content_rating': instance.contentRating,
      'is_registered': instance.isRegistered,
      'spots_remaining': instance.spotsRemaining,
      'shop_data': instance.shopData,
      'media': instance.media,
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
  itemTotalArtifacts:
      (json['item_total_artifacts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const <String, int>{},
  itemTotalUsd: (json['item_total_usd'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$CartItemToJson(_CartItem instance) => <String, dynamic>{
  'id': instance.id,
  'item_type': instance.itemType,
  'meal_plan': instance.mealPlan,
  'programme': instance.programme,
  'product': instance.product,
  'event': instance.event,
  'quantity': instance.quantity,
  'item_total_artifacts': instance.itemTotalArtifacts,
  'item_total_usd': instance.itemTotalUsd,
};

_Cart _$CartFromJson(Map<String, dynamic> json) => _Cart(
  id: json['id'] as String,
  items: (json['items'] as List<dynamic>)
      .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  discountCode: json['discount_code'] == null
      ? null
      : DiscountCode.fromJson(json['discount_code'] as Map<String, dynamic>),
  totalArtifacts:
      (json['total_artifacts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const <String, int>{},
  totalUsd: (json['total_usd'] as num?)?.toDouble() ?? 0.0,
  totalLocalCurrency: (json['total_local_currency'] as num?)?.toDouble() ?? 0.0,
  baseCurrency: json['base_currency'] as String? ?? 'USD',
  localCurrency: json['local_currency'] as String? ?? 'KES',
  conversionRate: (json['conversion_rate'] as num?)?.toDouble() ?? 129.5,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$CartToJson(_Cart instance) => <String, dynamic>{
  'id': instance.id,
  'items': instance.items,
  'discount_code': instance.discountCode,
  'total_artifacts': instance.totalArtifacts,
  'total_usd': instance.totalUsd,
  'total_local_currency': instance.totalLocalCurrency,
  'base_currency': instance.baseCurrency,
  'local_currency': instance.localCurrency,
  'conversion_rate': instance.conversionRate,
  'created_at': instance.createdAt,
};

_DiscountCode _$DiscountCodeFromJson(Map<String, dynamic> json) =>
    _DiscountCode(
      id: json['id'] as String,
      creator: json['creator'] as String,
      code: json['code'] as String,
      discountType: json['discount_type'] as String? ?? 'percentage',
      discountPct: (json['discount_pct'] as num?)?.toInt() ?? 0,
      discountArtifacts:
          (json['discount_artifacts'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const <String, int>{},
      codeType: json['code_type'] as String? ?? 'text',
      qrCode: json['qr_code'] as String?,
      description: json['description'] as String? ?? '',
      campaign: json['campaign'] as String? ?? '',
      validFrom: json['valid_from'] as String?,
      validUntil: json['valid_until'] as String?,
      usageLimit: (json['usage_limit'] as num?)?.toInt() ?? 0,
      maxUsesPerUser: (json['max_uses_per_user'] as num?)?.toInt() ?? 0,
      timesUsed: (json['times_used'] as num?)?.toInt() ?? 0,
      minPurchaseArtifacts:
          (json['min_purchase_artifacts'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const <String, int>{},
      isActive: json['is_active'] as bool? ?? true,
      isRetired: json['is_retired'] as bool? ?? false,
      retiredAt: json['retired_at'] as String?,
      retiredReason: json['retired_reason'] as String? ?? '',
      shareCount: (json['share_count'] as num?)?.toInt() ?? 0,
      usageCount: (json['usage_count'] as num?)?.toInt() ?? 0,
      isExpired: json['is_expired'] as bool? ?? false,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );

Map<String, dynamic> _$DiscountCodeToJson(_DiscountCode instance) =>
    <String, dynamic>{
      'id': instance.id,
      'creator': instance.creator,
      'code': instance.code,
      'discount_type': instance.discountType,
      'discount_pct': instance.discountPct,
      'discount_artifacts': instance.discountArtifacts,
      'code_type': instance.codeType,
      'qr_code': instance.qrCode,
      'description': instance.description,
      'campaign': instance.campaign,
      'valid_from': instance.validFrom,
      'valid_until': instance.validUntil,
      'usage_limit': instance.usageLimit,
      'max_uses_per_user': instance.maxUsesPerUser,
      'times_used': instance.timesUsed,
      'min_purchase_artifacts': instance.minPurchaseArtifacts,
      'is_active': instance.isActive,
      'is_retired': instance.isRetired,
      'retired_at': instance.retiredAt,
      'retired_reason': instance.retiredReason,
      'share_count': instance.shareCount,
      'usage_count': instance.usageCount,
      'is_expired': instance.isExpired,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

_DiscountUsageRecord _$DiscountUsageRecordFromJson(Map<String, dynamic> json) =>
    _DiscountUsageRecord(
      id: json['id'] as String,
      code: json['code'] as String,
      userDisplay: json['user_display'] as String,
      discount: json['discount'] as String,
      user: json['user'] as String,
      cart: json['cart'] as String?,
      orderArtifacts:
          (json['order_artifacts'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const <String, int>{},
      discountPctApplied: (json['discount_pct_applied'] as num?)?.toInt() ?? 0,
      discountArtifactsApplied:
          (json['discount_artifacts_applied'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const <String, int>{},
      savingsArtifacts:
          (json['savings_artifacts'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const <String, int>{},
      savingsUsd: (json['savings_usd'] as num?)?.toDouble() ?? 0.0,
      wasSuccessful: json['was_successful'] as bool? ?? true,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$DiscountUsageRecordToJson(
  _DiscountUsageRecord instance,
) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'user_display': instance.userDisplay,
  'discount': instance.discount,
  'user': instance.user,
  'cart': instance.cart,
  'order_artifacts': instance.orderArtifacts,
  'discount_pct_applied': instance.discountPctApplied,
  'discount_artifacts_applied': instance.discountArtifactsApplied,
  'savings_artifacts': instance.savingsArtifacts,
  'savings_usd': instance.savingsUsd,
  'was_successful': instance.wasSuccessful,
  'created_at': instance.createdAt,
};

_DiscountAnalytics _$DiscountAnalyticsFromJson(Map<String, dynamic> json) =>
    _DiscountAnalytics(
      totalUses: (json['total_uses'] as num?)?.toInt() ?? 0,
      successfulUses: (json['successful_uses'] as num?)?.toInt() ?? 0,
      totalSavingsUsd: (json['total_savings_usd'] as num?)?.toDouble() ?? 0.0,
      shareCount: (json['share_count'] as num?)?.toInt() ?? 0,
      timesUsed: (json['times_used'] as num?)?.toInt() ?? 0,
      uniqueUsers: (json['unique_users'] as num?)?.toInt() ?? 0,
      returningUsers: (json['returning_users'] as num?)?.toInt() ?? 0,
      retentionRate: (json['retention_rate'] as num?)?.toDouble() ?? 0.0,
      repeatUsageDistribution:
          (json['repeat_usage_distribution'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const <Map<String, dynamic>>[],
      avgSavingsPerUser:
          (json['avg_savings_per_user'] as num?)?.toDouble() ?? 0.0,
      totalOrderValueUsd:
          (json['total_order_value_usd'] as num?)?.toDouble() ?? 0.0,
      topUsers:
          (json['top_users'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const <Map<String, dynamic>>[],
      usageOverTime:
          (json['usage_over_time'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const <Map<String, dynamic>>[],
      code: DiscountCode.fromJson(json['code'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DiscountAnalyticsToJson(_DiscountAnalytics instance) =>
    <String, dynamic>{
      'total_uses': instance.totalUses,
      'successful_uses': instance.successfulUses,
      'total_savings_usd': instance.totalSavingsUsd,
      'share_count': instance.shareCount,
      'times_used': instance.timesUsed,
      'unique_users': instance.uniqueUsers,
      'returning_users': instance.returningUsers,
      'retention_rate': instance.retentionRate,
      'repeat_usage_distribution': instance.repeatUsageDistribution,
      'avg_savings_per_user': instance.avgSavingsPerUser,
      'total_order_value_usd': instance.totalOrderValueUsd,
      'top_users': instance.topUsers,
      'usage_over_time': instance.usageOverTime,
      'code': instance.code,
    };

_DiscountShareResult _$DiscountShareResultFromJson(Map<String, dynamic> json) =>
    _DiscountShareResult(
      code: json['code'] as String,
      discountPct: (json['discount_pct'] as num?)?.toInt() ?? 0,
      discountType: json['discount_type'] as String? ?? 'percentage',
      description: json['description'] as String? ?? '',
      qrCode: json['qr_code'] as String?,
    );

Map<String, dynamic> _$DiscountShareResultToJson(
  _DiscountShareResult instance,
) => <String, dynamic>{
  'code': instance.code,
  'discount_pct': instance.discountPct,
  'discount_type': instance.discountType,
  'description': instance.description,
  'qr_code': instance.qrCode,
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

_CreatorServices _$CreatorServicesFromJson(
  Map<String, dynamic> json,
) => _CreatorServices(
  mealPlans:
      (json['meal_plans'] as List<dynamic>?)
          ?.map((e) => MealPlan.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <MealPlan>[],
  programmes:
      (json['programmes'] as List<dynamic>?)
          ?.map((e) => TrainingProgramme.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <TrainingProgramme>[],
  events:
      (json['events'] as List<dynamic>?)
          ?.map((e) => MarketplaceEvent.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <MarketplaceEvent>[],
  products:
      (json['products'] as List<dynamic>?)
          ?.map((e) => MarketplaceProduct.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <MarketplaceProduct>[],
  discountCodes:
      (json['discount_codes'] as List<dynamic>?)
          ?.map((e) => DiscountCode.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <DiscountCode>[],
);

Map<String, dynamic> _$CreatorServicesToJson(_CreatorServices instance) =>
    <String, dynamic>{
      'meal_plans': instance.mealPlans,
      'programmes': instance.programmes,
      'events': instance.events,
      'products': instance.products,
      'discount_codes': instance.discountCodes,
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
