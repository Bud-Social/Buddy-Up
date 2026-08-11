import 'package:freezed_annotation/freezed_annotation.dart';

part 'marketplace.freezed.dart';
part 'marketplace.g.dart';

@freezed
abstract class CreatorData with _$CreatorData {
  const factory CreatorData({
    required String username,
    required String displayName,
    @JsonKey(name: 'avatar_url') required String avatarUrl,
    @JsonKey(name: 'verification_status') @Default('') String verificationStatus,
  }) = _CreatorData;

  factory CreatorData.fromJson(Map<String, dynamic> json) =>
      _$CreatorDataFromJson(json);
}

@freezed
abstract class Shop with _$Shop {
  const factory Shop({
    required String id,
    required String handle,
    required String name,
    required String description,
    @JsonKey(name: 'logo_url') String? logoUrl,
    @JsonKey(name: 'banner_url') String? bannerUrl,
    @JsonKey(name: 'accent_color') @Default('#6366f1') String accentColor,
    @JsonKey(name: 'contact_email') @Default('') String contactEmail,
    @JsonKey(name: 'contact_phone') @Default('') String contactPhone,
    @JsonKey(name: 'website_url') @Default('') String websiteUrl,
    @JsonKey(name: 'social_links') @Default(<String, String>{}) Map<String, String> socialLinks,
    @Default('') String category,
    @JsonKey(name: 'verification_status') @Default('unverified') String verificationStatus,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _Shop;

  factory Shop.fromJson(Map<String, dynamic> json) => _$ShopFromJson(json);
}

extension ShopX on Shop {
  bool get isCertified => verificationStatus == 'verified';
}

@freezed
abstract class UserShopResponse with _$UserShopResponse {
  const factory UserShopResponse({
    required Shop shop,
    @JsonKey(name: 'meal_plans') @Default(<MealPlan>[]) List<MealPlan> mealPlans,
    @Default(<TrainingProgramme>[]) List<TrainingProgramme> programmes,
    @Default(<MarketplaceEvent>[]) List<MarketplaceEvent> events,
    @Default(<MarketplaceProduct>[]) List<MarketplaceProduct> products,
  }) = _UserShopResponse;

  factory UserShopResponse.fromJson(Map<String, dynamic> json) =>
      _$UserShopResponseFromJson(json);
}

@freezed
abstract class BuddyUpCertification with _$BuddyUpCertification {
  const factory BuddyUpCertification({
    required String id,
    @JsonKey(name: 'shop_id') required String shopId,
    required String status,
    String? notes,
  }) = _BuddyUpCertification;

  factory BuddyUpCertification.fromJson(Map<String, dynamic> json) => _$BuddyUpCertificationFromJson(json);
}

@freezed
abstract class BuyerData with _$BuyerData {
  const factory BuyerData({
    required String username,
    required String displayName,
    @JsonKey(name: 'avatar_url') required String avatarUrl,
  }) = _BuyerData;

  factory BuyerData.fromJson(Map<String, dynamic> json) =>
      _$BuyerDataFromJson(json);
}

@freezed
abstract class MealPlan with _$MealPlan {
  const factory MealPlan({
    required String id,
    @JsonKey(name: 'creator_id') required String creatorId,
    required String title,
    required String description,
    @JsonKey(name: 'cover_image_url') required String coverImageUrl,
    @JsonKey(name: 'diet_type') required String dietType,
    @JsonKey(name: 'duration_weeks') required int durationWeeks,
    @JsonKey(name: 'calorie_range') required String calorieRange,
    @JsonKey(name: 'price_artifacts') required Map<String, int> priceArtifacts,
    @JsonKey(name: 'preview_day') required Map<String, dynamic> previewDay,
    @JsonKey(name: 'full_plan') Map<String, dynamic>? fullPlan,
    @JsonKey(name: 'shopping_list') @Default(<String>[]) List<String> shoppingList,
    @JsonKey(name: 'content_rating') @Default('general') String contentRating,
    @JsonKey(name: 'purchase_count') @Default(0) int purchaseCount,
    @JsonKey(name: 'average_rating') @Default(0.0) double averageRating,
    @JsonKey(name: 'review_count') @Default(0) int reviewCount,
    @JsonKey(name: 'creator_data') required CreatorData creatorData,
    @JsonKey(name: 'is_purchased') @Default(false) bool isPurchased,
    @JsonKey(name: 'is_published') @Default(true) bool isPublished,
    @JsonKey(name: 'shop_data') Shop? shopData,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _MealPlan;

  factory MealPlan.fromJson(Map<String, dynamic> json) =>
      _$MealPlanFromJson(json);
}

@freezed
abstract class MealPlanReview with _$MealPlanReview {
  const factory MealPlanReview({
    required String id,
    required int rating,
    String? body,
    @JsonKey(name: 'buyer_data') required BuyerData buyerData,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _MealPlanReview;

  factory MealPlanReview.fromJson(Map<String, dynamic> json) =>
      _$MealPlanReviewFromJson(json);
}

@freezed
abstract class TrainingProgramme with _$TrainingProgramme {
  const factory TrainingProgramme({
    required String id,
    @JsonKey(name: 'creator_id') required String creatorId,
    required String title,
    required String description,
    @JsonKey(name: 'cover_image_url') required String coverImageUrl,
    required String category,
    @JsonKey(name: 'duration_weeks') required int durationWeeks,
    @JsonKey(name: 'price_artifacts') required Map<String, int> priceArtifacts,
    @JsonKey(name: 'purchase_count') @Default(0) int purchaseCount,
    @JsonKey(name: 'creator_data') required CreatorData creatorData,
    @JsonKey(name: 'is_purchased') @Default(false) bool isPurchased,
    @JsonKey(name: 'is_published') @Default(true) bool isPublished,
    @JsonKey(name: 'shop_data') Shop? shopData,
    @JsonKey(name: 'content_rating') @Default('general') String contentRating,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _TrainingProgramme;

  factory TrainingProgramme.fromJson(Map<String, dynamic> json) =>
      _$TrainingProgrammeFromJson(json);
}

@freezed
abstract class TrainingProgrammeReview with _$TrainingProgrammeReview {
  const factory TrainingProgrammeReview({
    required String id,
    required int rating,
    String? body,
    @JsonKey(name: 'buyer_data') required BuyerData buyerData,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _TrainingProgrammeReview;

  factory TrainingProgrammeReview.fromJson(Map<String, dynamic> json) =>
      _$TrainingProgrammeReviewFromJson(json);
}

@freezed
abstract class MarketplaceProduct with _$MarketplaceProduct {
  const factory MarketplaceProduct({
    required String id,
    required String name,
    required String brand,
    required String description,
    required String category,
    @JsonKey(name: 'image_url') required String imageUrl,
    @JsonKey(name: 'affiliate_url') required String affiliateUrl,
    @JsonKey(name: 'price_display') required String priceDisplay,
    @JsonKey(name: 'content_rating') @Default('general') String contentRating,
    @JsonKey(name: 'recommended_by') String? recommendedBy,
    @JsonKey(name: 'recommender_data') Map<String, dynamic>? recommenderData,
    @JsonKey(name: 'click_count') @Default(0) int clickCount,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'shop_data') Shop? shopData,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _MarketplaceProduct;

  factory MarketplaceProduct.fromJson(Map<String, dynamic> json) =>
      _$MarketplaceProductFromJson(json);
}

@freezed
abstract class GymData with _$GymData {
  const factory GymData({
    required String id,
    required String name,
    required String handle,
    @JsonKey(name: 'logo_url') required String logoUrl,
  }) = _GymData;

  factory GymData.fromJson(Map<String, dynamic> json) =>
      _$GymDataFromJson(json);
}

@freezed
@freezed
abstract class EventMediaItem with _$EventMediaItem {
  const factory EventMediaItem({
    required String id,
    @JsonKey(name: 'media_type') @Default('image') String mediaType,
    required String url,
    @JsonKey(name: 'thumbnail_url') @Default('') String thumbnailUrl,
    @JsonKey(name: 'alt_text') @Default('') String altText,
    @JsonKey(name: 'sort_order') @Default(0) int sortOrder,
  }) = _EventMediaItem;

  factory EventMediaItem.fromJson(Map<String, dynamic> json) =>
      _$EventMediaItemFromJson(json);
}

@freezed
abstract class MarketplaceEvent with _$MarketplaceEvent {
  const factory MarketplaceEvent({
    required String id,
    @JsonKey(name: 'creator_data') required CreatorData creatorData,
    @JsonKey(name: 'gym_data') GymData? gymData,
    required String title,
    required String description,
    @JsonKey(name: 'cover_image_url') required String coverImageUrl,
    @JsonKey(name: 'promo_video_url') @Default('') String promoVideoUrl,
    @JsonKey(name: 'gallery_urls') @Default(<String>[]) List<String> galleryUrls,
    @JsonKey(name: 'event_type') required String eventType,
    required String location,
    @JsonKey(name: 'online_url') required String onlineUrl,
    @JsonKey(name: 'start_datetime') required String startDatetime,
    @JsonKey(name: 'end_datetime') required String endDatetime,
    required String timezone,
    @Default('none') String recurrence,
    @JsonKey(name: 'ticket_tiers') @Default(<Map<String, dynamic>>[]) List<Map<String, dynamic>> ticketTiers,
    @Default(<Map<String, dynamic>>[]) List<Map<String, dynamic>> agenda,
    @Default('') String cancellationPolicy,
    @JsonKey(name: 'early_bird_enabled') @Default(false) bool earlyBirdEnabled,
    @JsonKey(name: 'early_bird_deadline') String? earlyBirdDeadline,
    @JsonKey(name: 'early_bird_price_artifacts') @Default(<String, int>{}) Map<String, int> earlyBirdPriceArtifacts,
    required int capacity,
    @JsonKey(name: 'ticket_price_artifacts')
    required Map<String, int> ticketPriceArtifacts,
    @JsonKey(name: 'is_free') @Default(false) bool isFree,
    @JsonKey(name: 'is_published') @Default(false) bool isPublished,
    @JsonKey(name: 'is_cancelled') @Default(false) bool isCancelled,
    @JsonKey(name: 'attendee_count') @Default(0) int attendeeCount,
    @Default(<String>[]) List<String> tags,
    @Default('') String category,
    @JsonKey(name: 'content_rating') @Default('general') String contentRating,
    @JsonKey(name: 'is_registered') @Default(false) bool isRegistered,
    @JsonKey(name: 'spots_remaining') int? spotsRemaining,
    @JsonKey(name: 'shop_data') Shop? shopData,
    @Default(<EventMediaItem>[]) List<EventMediaItem> media,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _MarketplaceEvent;

  factory MarketplaceEvent.fromJson(Map<String, dynamic> json) =>
      _$MarketplaceEventFromJson(json);
}

@freezed
abstract class EventTicket with _$EventTicket {
  const factory EventTicket({
    required String id,
    @JsonKey(name: 'event_data') Map<String, dynamic>? eventData,
    @JsonKey(name: 'holder_data') Map<String, dynamic>? holderData,
    @JsonKey(name: 'ticket_code') required String ticketCode,
    @Default('') String tier,
    @JsonKey(name: 'price_paid_artifacts') Map<String, int>? pricePaidArtifacts,
    @Default('active') String status,
    @JsonKey(name: 'is_checked_in') @Default(false) bool isCheckedIn,
    @JsonKey(name: 'checked_in_at') String? checkedInAt,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _EventTicket;

  factory EventTicket.fromJson(Map<String, dynamic> json) =>
      _$EventTicketFromJson(json);
}

@freezed
abstract class CartItem with _$CartItem {
  const factory CartItem({
    required String id,
    @JsonKey(name: 'item_type') required String itemType,
    @JsonKey(name: 'meal_plan') MealPlan? mealPlan,
    TrainingProgramme? programme,
    @JsonKey(name: 'product')
    MarketplaceProduct? product,
    MarketplaceEvent? event,
    @Default(1) int quantity,
    @JsonKey(name: 'item_total_artifacts') @Default(<String, int>{}) Map<String, int> itemTotalArtifacts,
    @JsonKey(name: 'item_total_usd') @Default(0.0) double itemTotalUsd,
  }) = _CartItem;

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);
}

@freezed
abstract class Cart with _$Cart {
  const factory Cart({
    required String id,
    required List<CartItem> items,
    @JsonKey(name: 'discount_code') DiscountCode? discountCode,
    @JsonKey(name: 'total_artifacts') @Default(<String, int>{}) Map<String, int> totalArtifacts,
    @JsonKey(name: 'total_usd') @Default(0.0) double totalUsd,
    @JsonKey(name: 'total_local_currency') @Default(0.0) double totalLocalCurrency,
    @JsonKey(name: 'base_currency') @Default('USD') String baseCurrency,
    @JsonKey(name: 'local_currency') @Default('KES') String localCurrency,
    @JsonKey(name: 'conversion_rate') @Default(129.5) double conversionRate,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _Cart;

  factory Cart.fromJson(Map<String, dynamic> json) => _$CartFromJson(json);
}

@freezed
abstract class DiscountCode with _$DiscountCode {
  const factory DiscountCode({
    required String id,
    required String creator,
    required String code,
    @JsonKey(name: 'discount_type') @Default('percentage') String discountType,
    @JsonKey(name: 'discount_pct') @Default(0) int discountPct,
    @JsonKey(name: 'discount_artifacts') @Default(<String, int>{}) Map<String, int> discountArtifacts,
    @JsonKey(name: 'code_type') @Default('text') String codeType,
    @JsonKey(name: 'qr_code') String? qrCode,
    @Default('') String description,
    @Default('') String campaign,
    @JsonKey(name: 'valid_from') String? validFrom,
    @JsonKey(name: 'valid_until') String? validUntil,
    @JsonKey(name: 'usage_limit') @Default(0) int usageLimit,
    @JsonKey(name: 'max_uses_per_user') @Default(0) int maxUsesPerUser,
    @JsonKey(name: 'times_used') @Default(0) int timesUsed,
    @JsonKey(name: 'min_purchase_artifacts') @Default(<String, int>{}) Map<String, int> minPurchaseArtifacts,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'is_retired') @Default(false) bool isRetired,
    @JsonKey(name: 'retired_at') String? retiredAt,
    @JsonKey(name: 'retired_reason') @Default('') String retiredReason,
    @JsonKey(name: 'share_count') @Default(0) int shareCount,
    @JsonKey(name: 'usage_count') @Default(0) int usageCount,
    @JsonKey(name: 'is_expired') @Default(false) bool isExpired,
    @JsonKey(name: 'created_at') @Default('') String createdAt,
    @JsonKey(name: 'updated_at') @Default('') String updatedAt,
  }) = _DiscountCode;

  factory DiscountCode.fromJson(Map<String, dynamic> json) =>
      _$DiscountCodeFromJson(json);
}

@freezed
abstract class DiscountUsageRecord with _$DiscountUsageRecord {
  const factory DiscountUsageRecord({
    required String id,
    required String code,
    @JsonKey(name: 'user_display') required String userDisplay,
    required String discount,
    required String user,
    String? cart,
    @JsonKey(name: 'order_artifacts') @Default(<String, int>{}) Map<String, int> orderArtifacts,
    @JsonKey(name: 'discount_pct_applied') @Default(0) int discountPctApplied,
    @JsonKey(name: 'discount_artifacts_applied') @Default(<String, int>{}) Map<String, int> discountArtifactsApplied,
    @JsonKey(name: 'savings_artifacts') @Default(<String, int>{}) Map<String, int> savingsArtifacts,
    @JsonKey(name: 'savings_usd') @Default(0.0) double savingsUsd,
    @JsonKey(name: 'was_successful') @Default(true) bool wasSuccessful,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _DiscountUsageRecord;

  factory DiscountUsageRecord.fromJson(Map<String, dynamic> json) =>
      _$DiscountUsageRecordFromJson(json);
}

@freezed
abstract class DiscountAnalytics with _$DiscountAnalytics {
  const factory DiscountAnalytics({
    @JsonKey(name: 'total_uses') @Default(0) int totalUses,
    @JsonKey(name: 'successful_uses') @Default(0) int successfulUses,
    @JsonKey(name: 'total_savings_usd') @Default(0.0) double totalSavingsUsd,
    @JsonKey(name: 'share_count') @Default(0) int shareCount,
    @JsonKey(name: 'times_used') @Default(0) int timesUsed,
    @JsonKey(name: 'unique_users') @Default(0) int uniqueUsers,
    @JsonKey(name: 'returning_users') @Default(0) int returningUsers,
    @JsonKey(name: 'retention_rate') @Default(0.0) double retentionRate,
    @JsonKey(name: 'repeat_usage_distribution') @Default(<Map<String, dynamic>>[]) List<Map<String, dynamic>> repeatUsageDistribution,
    @JsonKey(name: 'avg_savings_per_user') @Default(0.0) double avgSavingsPerUser,
    @JsonKey(name: 'total_order_value_usd') @Default(0.0) double totalOrderValueUsd,
    @JsonKey(name: 'top_users') @Default(<Map<String, dynamic>>[]) List<Map<String, dynamic>> topUsers,
    @JsonKey(name: 'usage_over_time') @Default(<Map<String, dynamic>>[]) List<Map<String, dynamic>> usageOverTime,
    required DiscountCode code,
  }) = _DiscountAnalytics;

  factory DiscountAnalytics.fromJson(Map<String, dynamic> json) =>
      _$DiscountAnalyticsFromJson(json);
}

@freezed
abstract class DiscountShareResult with _$DiscountShareResult {
  const factory DiscountShareResult({
    required String code,
    @JsonKey(name: 'discount_pct') @Default(0) int discountPct,
    @JsonKey(name: 'discount_type') @Default('percentage') String discountType,
    @Default('') String description,
    @JsonKey(name: 'qr_code') String? qrCode,
  }) = _DiscountShareResult;

  factory DiscountShareResult.fromJson(Map<String, dynamic> json) =>
      _$DiscountShareResultFromJson(json);
}

@freezed
abstract class FoodItem with _$FoodItem {
  const factory FoodItem({
    required String item,
    required double confidence,
    required Map<String, dynamic> nutrition,
  }) = _FoodItem;

  factory FoodItem.fromJson(Map<String, dynamic> json) =>
      _$FoodItemFromJson(json);
}

@freezed
abstract class FoodRecognitionResult with _$FoodRecognitionResult {
  const factory FoodRecognitionResult({
    required List<FoodItem> items,
    @JsonKey(name: 'total_calories') required double totalCalories,
    @JsonKey(name: 'total_protein') required double totalProtein,
    @JsonKey(name: 'total_carbs') required double totalCarbs,
    @JsonKey(name: 'total_fat') required double totalFat,
    @JsonKey(name: 'health_benefits') @Default(<String>[]) List<String> healthBenefits,
    @Default('') String method,
  }) = _FoodRecognitionResult;

  factory FoodRecognitionResult.fromJson(Map<String, dynamic> json) =>
      _$FoodRecognitionResultFromJson(json);
}

@freezed
abstract class CreatorServices with _$CreatorServices {
  const factory CreatorServices({
    @JsonKey(name: 'meal_plans') @Default(<MealPlan>[]) List<MealPlan> mealPlans,
    @Default(<TrainingProgramme>[]) List<TrainingProgramme> programmes,
    @Default(<MarketplaceEvent>[]) List<MarketplaceEvent> events,
    @Default(<MarketplaceProduct>[]) List<MarketplaceProduct> products,
    @JsonKey(name: 'discount_codes') @Default(<DiscountCode>[]) List<DiscountCode> discountCodes,
  }) = _CreatorServices;

  factory CreatorServices.fromJson(Map<String, dynamic> json) =>
      _$CreatorServicesFromJson(json);
}

@freezed
abstract class ProductPayload with _$ProductPayload {
  const factory ProductPayload({
    required String name,
    required String brand,
    required String description,
    required String category,
    @JsonKey(name: 'image_url') required String imageUrl,
    @JsonKey(name: 'affiliate_url') required String affiliateUrl,
    @JsonKey(name: 'price_display') required String priceDisplay,
  }) = _ProductPayload;

  factory ProductPayload.fromJson(Map<String, dynamic> json) =>
      _$ProductPayloadFromJson(json);
}

@freezed
abstract class EventPayload with _$EventPayload {
  const factory EventPayload({
    required String title,
    required String description,
    @JsonKey(name: 'event_type') required String eventType,
    required String location,
    @JsonKey(name: 'online_url') String? onlineUrl,
    @JsonKey(name: 'start_datetime') required String startDatetime,
    @JsonKey(name: 'end_datetime') required String endDatetime,
    required String timezone,
    required int capacity,
    String? gymId,
    @Default(<String>[]) List<String> tags,
    @Default('') String category,
  }) = _EventPayload;

  factory EventPayload.fromJson(Map<String, dynamic> json) =>
      _$EventPayloadFromJson(json);
}

@freezed
abstract class CheckoutResponse with _$CheckoutResponse {
  const factory CheckoutResponse({
    required String status,
    @Default(<String>[]) List<String> purchased,
    @Default(<String>[]) List<String> errors,
  }) = _CheckoutResponse;

  factory CheckoutResponse.fromJson(Map<String, dynamic> json) =>
      _$CheckoutResponseFromJson(json);
}

class CreatorAnalytics {
  final double totalRevenueUsd;
  final int totalSales;
  final int totalViews;
  final Map<String, int> categorySales;
  final Map<String, double> categoryRevenue;
  final List<RevenuePoint> revenueOverTime;
  final List<TopService> topServices;

  CreatorAnalytics({
    this.totalRevenueUsd = 0.0,
    this.totalSales = 0,
    this.totalViews = 0,
    this.categorySales = const {},
    this.categoryRevenue = const {},
    this.revenueOverTime = const [],
    this.topServices = const [],
  });

  factory CreatorAnalytics.fromJson(Map<String, dynamic> json) {
    final sales = json['category_sales'] as Map<String, dynamic>? ?? {};
    final revenue = json['category_revenue'] as Map<String, dynamic>? ?? {};
    final rot = (json['revenue_over_time'] as List?) ?? [];
    final top = (json['top_services'] as List?) ?? [];
    return CreatorAnalytics(
      totalRevenueUsd: (json['total_revenue_usd'] ?? 0.0).toDouble(),
      totalSales: (json['total_sales'] ?? 0) as int,
      totalViews: (json['total_views'] ?? 0) as int,
      categorySales: sales.map((k, v) => MapEntry(k, (v ?? 0) as int)),
      categoryRevenue: revenue.map((k, v) => MapEntry(k, (v ?? 0.0).toDouble())),
      revenueOverTime: rot.map((e) => RevenuePoint.fromJson(e as Map<String, dynamic>)).toList(),
      topServices: top.map((e) => TopService.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class RevenuePoint {
  final String month;
  final double total;

  RevenuePoint({this.month = '', this.total = 0.0});

  factory RevenuePoint.fromJson(Map<String, dynamic> json) {
    return RevenuePoint(
      month: (json['month'] ?? '') as String,
      total: (json['total'] ?? 0.0).toDouble(),
    );
  }
}

class TopService {
  final String id;
  final String title;
  final String type;
  final int sales;

  TopService({this.id = '', this.title = '', this.type = '', this.sales = 0});

  factory TopService.fromJson(Map<String, dynamic> json) {
    return TopService(
      id: (json['id'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      type: (json['type'] ?? '') as String,
      sales: (json['sales'] ?? 0) as int,
    );
  }
}
