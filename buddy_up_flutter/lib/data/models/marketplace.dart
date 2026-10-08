import 'package:freezed_annotation/freezed_annotation.dart';

part 'marketplace.freezed.dart';
part 'marketplace.g.dart';

/// Backend speaks snake_case (plain DRF JSONRenderer). Geo columns and money
/// columns are `DecimalField`s, so they serialise as strings — parse them
/// leniently instead of casting.
/// A `DecimalField` arrives as a string and is rendered as-is. Converting it
/// through a double would silently reformat "25.00" as "25.0", which is a
/// cosmetic lie about money, so this only normalises a num into text.
String? _optNum(dynamic v) {
  if (v == null) return null;
  return v is String ? v : v.toString();
}

double? _optDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

@freezed
abstract class CreatorData with _$CreatorData {
  const factory CreatorData({
    required String username,
    @JsonKey(name: 'display_name') @Default('') String displayName,
    // `Profile.avatar_url` is nullable and the serializer passes it straight
    // through, so an avatar-less creator must not make the row unparseable.
    @JsonKey(name: 'avatar_url') @Default('') String avatarUrl,
    @JsonKey(name: 'verification_status') @Default('') String verificationStatus,
  }) = _CreatorData;

  factory CreatorData.fromJson(Map<String, dynamic> json) =>
      _$CreatorDataFromJson(json);
}

/// A shop row. Every member past `id` is optional on purpose: the marketplace
/// serializers embed a shop as a four-key `shop_data` block on a meal plan,
/// programme, product or event, and a model that demanded the full
/// `ShopDetailSerializer` shape made every shop-owned cart row unparseable.
@freezed
abstract class Shop with _$Shop {
  const factory Shop({
    required String id,
    @Default('') String handle,
    @Default('') String name,
    @Default('') String description,
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
    @JsonKey(name: 'created_at') @Default('') String createdAt,
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
    // `MealPlanSerializer` exposes the image as `cover`, so a row from a list endpoint
    // carries no `cover_image_url`. Default it rather than making the whole object
    // unparseable over a missing thumbnail.
    @JsonKey(name: 'cover_image_url') @Default('') String coverImageUrl,
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
    // Same story as `MealPlan.coverImageUrl`: the list serializer sends `cover`.
    @JsonKey(name: 'cover_image_url') @Default('') String coverImageUrl,
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
    @JsonKey(name: 'delivery_modes') @Default(<String>[]) List<String> deliveryModes,
    @JsonKey(name: 'fulfillment_details') @Default(<String, dynamic>{}) Map<String, dynamic> fulfillmentDetails,
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
    // Nullable in the serializer, and only present when the gym has one.
    @JsonKey(name: 'logo_url') @Default('') String logoUrl,
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
    @JsonKey(name: 'distance_km') double? distanceKm,
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
    @JsonKey(name: 'qr_data_uri') String? qrDataUri,
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
    // `*_detail` is the serialised object; the bare `meal_plan` / `product` /
    // `event` keys next to it are foreign-key UUIDs. Reading the detail key is
    // the only way to get a title or a `delivery_modes` list out of a cart row.
    @JsonKey(name: 'meal_plan_detail') MealPlan? mealPlan,
    @JsonKey(name: 'programme_detail') TrainingProgramme? programme,
    @JsonKey(name: 'product_detail') MarketplaceProduct? product,
    @JsonKey(name: 'event_detail') MarketplaceEvent? event,
    @Default(1) int quantity,
    @JsonKey(name: 'item_total_artifacts') @Default(<String, int>{}) Map<String, int> itemTotalArtifacts,
    @JsonKey(name: 'item_total_usd') @Default(0.0) double itemTotalUsd,
  }) = _CartItem;

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);
}

@freezed
abstract class SuggestedFulfillment with _$SuggestedFulfillment {
  const factory SuggestedFulfillment({
    @Default('digital') String type,
    @Default(<String>[]) List<String> available,
    @Default(<String, dynamic>{}) Map<String, dynamic> detail,
  }) = _SuggestedFulfillment;

  factory SuggestedFulfillment.fromJson(Map<String, dynamic> json) =>
      _$SuggestedFulfillmentFromJson(json);
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
    @JsonKey(name: 'suggested_fulfillment') SuggestedFulfillment? suggestedFulfillment,
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

@freezed
abstract class OrderTimelineEntry with _$OrderTimelineEntry {
  const factory OrderTimelineEntry({
    @Default('') String status,
    String? at,
    @Default('') String note,
  }) = _OrderTimelineEntry;

  factory OrderTimelineEntry.fromJson(Map<String, dynamic> json) =>
      _$OrderTimelineEntryFromJson(json);
}

@freezed
abstract class OrderFulfillment with _$OrderFulfillment {
  const factory OrderFulfillment({
    @Default('') String carrier,
    @JsonKey(name: 'tracking_number') @Default('') String trackingNumber,
    @JsonKey(name: 'tracking_url') @Default('') String trackingUrl,
    @JsonKey(name: 'pickup_location') @Default('') String pickupLocation,
    @Default('') String notes,
    @Default(<OrderTimelineEntry>[]) List<OrderTimelineEntry> timeline,
    @JsonKey(name: 'shipped_at') String? shippedAt,
    @JsonKey(name: 'out_for_delivery_at') String? outForDeliveryAt,
    @JsonKey(name: 'ready_for_pickup_at') String? readyForPickupAt,
    @JsonKey(name: 'delivered_at') String? deliveredAt,
  }) = _OrderFulfillment;

  factory OrderFulfillment.fromJson(Map<String, dynamic> json) =>
      _$OrderFulfillmentFromJson(json);
}

@freezed
abstract class OrderItem with _$OrderItem {
  const factory OrderItem({
    @JsonKey(name: 'item_type') @Default('') String itemType,
    @Default('') String title,
    @Default(1) int quantity,
    @JsonKey(name: 'price_artifacts') @Default(<String, int>{}) Map<String, int> priceArtifacts,
    @JsonKey(name: 'paid_artifacts') @Default(<String, int>{}) Map<String, int> paidArtifacts,
    @JsonKey(name: 'creator_name') String? creatorName,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _OrderItem;

  factory OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);
}

@freezed
abstract class Order with _$Order {
  const factory Order({
    required String id,
    @JsonKey(name: 'order_number') @Default('') String orderNumber,
    @Default('paid') String status,
    @JsonKey(name: 'status_label') @Default('') String statusLabel,
    @JsonKey(name: 'fulfillment_type') @Default('digital') String fulfillmentType,
    @JsonKey(name: 'delivery_address') @Default(<String, dynamic>{}) Map<String, dynamic> deliveryAddress,
    @JsonKey(name: 'pickup_details') @Default(<String, dynamic>{}) Map<String, dynamic> pickupDetails,
    @JsonKey(name: 'total_artifacts') @Default(<String, int>{}) Map<String, int> totalArtifacts,
    @JsonKey(name: 'discount_artifacts') @Default(<String, int>{}) Map<String, int> discountArtifacts,
    @Default(0.0) double spentUsd,
    @JsonKey(name: 'total_usd') @Default(0.0) double totalUsd,
    @JsonKey(name: 'discount_code') String? discountCode,
    @JsonKey(name: 'status_history') @Default(<OrderTimelineEntry>[]) List<OrderTimelineEntry> statusHistory,
    @Default(<OrderItem>[]) List<OrderItem> items,
    OrderFulfillment? fulfillment,
    @JsonKey(name: 'pickup_station') String? pickupStation,
    @JsonKey(name: 'delivery_personnel') String? deliveryPersonnel,
    @JsonKey(name: 'payment_method') String? paymentMethod,
    @JsonKey(name: 'payment_status') @Default('unpaid') String paymentStatus,
    @JsonKey(name: 'payment_reference') String? paymentReference,
    @JsonKey(name: 'payment_provider') String? paymentProvider,
    @JsonKey(name: 'is_seller') @Default(false) bool isSeller,
    @JsonKey(name: 'paid_at') String? paidAt,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}

// ---------------------------------------------------------------------------
// Fulfillment logistics: pickup stations, couriers, applications
// ---------------------------------------------------------------------------

/// A collection point a buyer can pick a `pickup` order up from.
///
/// `distanceKm` is present ONLY when the list was called with both `lat` and
/// `lng` — the server never infers a buyer's location. See
/// `features/marketplace/utils/stations.dart` for the degraded-path helpers.
@freezed
abstract class PickupStation with _$PickupStation {
  const factory PickupStation({
    required String id,
    @Default('') String name,
    String? description,
    String? address,
    String? city,
    String? country,
    @JsonKey(fromJson: _optDouble) double? latitude,
    @JsonKey(fromJson: _optDouble) double? longitude,
    @JsonKey(name: 'opening_hours') @Default(<String, dynamic>{}) Map<String, dynamic> openingHours,
    String? phone,
    String? instructions,
    @JsonKey(name: 'is_primary') @Default(false) bool isPrimary,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'owner_type') @Default('') String ownerType,
    @JsonKey(name: 'owner_name') String? ownerName,
    @JsonKey(name: 'distance_km', fromJson: _optDouble) double? distanceKm,
    String? shop,
    String? gym,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _PickupStation;

  factory PickupStation.fromJson(Map<String, dynamic> json) =>
      _$PickupStationFromJson(json);
}

/// One courier a seller may assign to one of their orders
/// (`GET /marketplace/orders/seller/<id>/couriers/`).
///
/// The endpoint returns *every* active courier summarised by vehicle type — it
/// deliberately does not try to fit vehicles to orders — so the seller picks.
/// `distanceKm` is null unless the courier shares a non-incognito search
/// profile AND the order carries coordinates.
@freezed
abstract class OrderCourier with _$OrderCourier {
  const factory OrderCourier({
    required String id,
    @JsonKey(name: 'profile') String? profile,
    @JsonKey(name: 'username') @Default('') String username,
    @JsonKey(name: 'display_name') @Default('') String displayName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'vehicle_type') @Default('bike') String vehicleType,
    @JsonKey(name: 'vehicle_label') @Default('') String vehicleLabel,
    @JsonKey(name: 'service_zones') @Default(<String>[]) List<String> serviceZones,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'rating', fromJson: _optDouble) double? rating,
    @JsonKey(name: 'distance_km', fromJson: _optDouble) double? distanceKm,
    @JsonKey(name: 'bio') @Default('') String bio,
  }) = _OrderCourier;

  factory OrderCourier.fromJson(Map<String, dynamic> json) =>
      _$OrderCourierFromJson(json);
}

@freezed
abstract class OrderCourierGroup with _$OrderCourierGroup {
  const factory OrderCourierGroup({
    @JsonKey(name: 'vehicle_type') @Default('') String vehicleType,
    @JsonKey(name: 'vehicle_label') @Default('') String vehicleLabel,
    @Default(0) int count,
    @Default(<OrderCourier>[]) List<OrderCourier> couriers,
  }) = _OrderCourierGroup;

  factory OrderCourierGroup.fromJson(Map<String, dynamic> json) =>
      _$OrderCourierGroupFromJson(json);
}

@freezed
abstract class OrderCourierList with _$OrderCourierList {
  const factory OrderCourierList({
    @JsonKey(name: 'order_id') @Default('') String orderId,
    @JsonKey(name: 'order_number') @Default('') String orderNumber,
    @JsonKey(name: 'fulfillment_type') @Default('digital') String fulfillmentType,
    @JsonKey(name: 'delivery_personnel') String? deliveryPersonnel,
    Map<String, dynamic>? origin,
    @Default(<OrderCourier>[]) List<OrderCourier> couriers,
    @JsonKey(name: 'by_vehicle') @Default(<OrderCourierGroup>[]) List<OrderCourierGroup> byVehicle,
  }) = _OrderCourierList;

  factory OrderCourierList.fromJson(Map<String, dynamic> json) =>
      _$OrderCourierListFromJson(json);
}

/// A user's own courier record (`POST /marketplace/delivery-personnel/`).
///
/// Created by the self-registration endpoint, but in practice an approved
/// application creates it — which is why this is the same shape the seller
/// courier picker reads.
@freezed
abstract class DeliveryPersonnel with _$DeliveryPersonnel {
  const factory DeliveryPersonnel({
    required String id,
    @JsonKey(name: 'profile') String? profile,
    @JsonKey(name: 'username') @Default('') String username,
    @JsonKey(name: 'display_name') @Default('') String displayName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'vehicle_type') @Default('bike') String vehicleType,
    @JsonKey(name: 'vehicle_label') @Default('') String vehicleLabel,
    @JsonKey(name: 'service_zones') @Default(<String>[]) List<String> serviceZones,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'rating', fromJson: _optDouble) double? rating,
    @JsonKey(name: 'bio') @Default('') String bio,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _DeliveryPersonnel;

  factory DeliveryPersonnel.fromJson(Map<String, dynamic> json) =>
      _$DeliveryPersonnelFromJson(json);
}

/// `POST /marketplace/delivery-personnel-applications/` — the applicant's own
/// courier claim (draft -> submitted). Review fields are staff-owned.
@freezed
abstract class DeliveryPersonnelApplication with _$DeliveryPersonnelApplication {
  const factory DeliveryPersonnelApplication({
    required String id,
    @JsonKey(name: 'profile') String? profile,
    @JsonKey(name: 'vehicle_type') @Default('bike') String vehicleType,
    @JsonKey(name: 'service_zones') @Default(<String>[]) List<String> serviceZones,
    @JsonKey(name: 'id_document_url') @Default('') String idDocumentUrl,
    @JsonKey(name: 'licence_document_url') @Default('') String licenceDocumentUrl,
    @Default('') String phone,
    @Default('') String bio,
    @Default('draft') String status,
    @JsonKey(name: 'reviewer_notes') @Default('') String reviewerNotes,
    @JsonKey(name: 'rejection_reason') @Default('') String rejectionReason,
    @JsonKey(name: 'reviewed_at') String? reviewedAt,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _DeliveryPersonnelApplication;

  factory DeliveryPersonnelApplication.fromJson(Map<String, dynamic> json) =>
      _$DeliveryPersonnelApplicationFromJson(json);
}

/// `POST /marketplace/station-applications/` — a shop or gym applying to become
/// a pickup station. Exactly one of `shop` / `gym` is set server-side.
@freezed
abstract class StationApplication with _$StationApplication {
  const factory StationApplication({
    required String id,
    String? shop,
    String? gym,
    @Default('draft') String status,
    @JsonKey(name: 'business_registration_number')
    @Default('')
    String businessRegistrationNumber,
    @JsonKey(name: 'contact_phone') @Default('') String contactPhone,
    @Default('') String address,
    @Default('') String city,
    @Default('') String country,
    @JsonKey(fromJson: _optDouble) double? latitude,
    @JsonKey(fromJson: _optDouble) double? longitude,
    @JsonKey(name: 'opening_hours') @Default(<String, dynamic>{}) Map<String, dynamic> openingHours,
    @JsonKey(name: 'documents') @Default(<Map<String, dynamic>>[]) List<Map<String, dynamic>> documents,
    @JsonKey(name: 'agreed_to_policy') @Default(false) bool agreedToPolicy,
    @JsonKey(name: 'agreed_at') String? agreedAt,
    @JsonKey(name: 'reviewer_notes') @Default('') String reviewerNotes,
    @JsonKey(name: 'rejection_reason') @Default('') String rejectionReason,
    @JsonKey(name: 'reviewed_at') String? reviewedAt,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _StationApplication;

  factory StationApplication.fromJson(Map<String, dynamic> json) =>
      _$StationApplicationFromJson(json);
}

// ---------------------------------------------------------------------------
// Checkout
// ---------------------------------------------------------------------------

/// One line of `POST /marketplace/cart/checkout/`'s receipt payload.
@freezed
abstract class CheckoutReceiptItem with _$CheckoutReceiptItem {
  const factory CheckoutReceiptItem({
    @JsonKey(name: 'item_type') @Default('') String itemType,
    @Default('') String title,
    @Default(1) int quantity,
    @JsonKey(name: 'price_artifacts') @Default(<String, int>{}) Map<String, int> priceArtifacts,
    @JsonKey(name: 'total_artifacts') @Default(<String, int>{}) Map<String, int> totalArtifacts,
    @JsonKey(name: 'paid_artifacts') @Default(<String, int>{}) Map<String, int> paidArtifacts,
    @JsonKey(name: 'creator_name') String? creatorName,
  }) = _CheckoutReceiptItem;

  factory CheckoutReceiptItem.fromJson(Map<String, dynamic> json) =>
      _$CheckoutReceiptItemFromJson(json);
}

/// What checkout returns once the order exists.
///
/// `paymentRequired` is true for M-Pesa / Card: nothing was deducted and nothing
/// was provisioned, and the order stays `pending` until the provider confirms.
@freezed
abstract class CheckoutReceipt with _$CheckoutReceipt {
  const factory CheckoutReceipt({
    @JsonKey(name: 'order_id') required String orderId,
    @JsonKey(name: 'order_number') @Default('') String orderNumber,
    @Default('') String status,
    @JsonKey(name: 'fulfillment_type') @Default('digital') String fulfillmentType,
    @JsonKey(name: 'pickup_station_id') String? pickupStationId,
    @JsonKey(name: 'payment_method') String? paymentMethod,
    @JsonKey(name: 'payment_status') String? paymentStatus,
    @JsonKey(name: 'payment_required') @Default(false) bool paymentRequired,
    @Default(<CheckoutReceiptItem>[]) List<CheckoutReceiptItem> items,
    @JsonKey(name: 'total_artifacts') @Default(<String, int>{}) Map<String, int> totalArtifacts,
    @JsonKey(name: 'original_artifacts') @Default(<String, int>{}) Map<String, int> originalArtifacts,
    @JsonKey(name: 'savings_artifacts') @Default(<String, int>{}) Map<String, int> savingsArtifacts,
    @JsonKey(name: 'savings_usd') @Default(0.0) double savingsUsd,
    @JsonKey(name: 'discount_code') String? discountCode,
    @JsonKey(name: 'spent_usd') @Default(0.0) double spentUsd,
    @JsonKey(name: 'new_balance') @Default(<String, int>{}) Map<String, int> newBalance,
  }) = _CheckoutReceipt;

  factory CheckoutReceipt.fromJson(Map<String, dynamic> json) =>
      _$CheckoutReceiptFromJson(json);
}

@freezed
abstract class PaymentIntent with _$PaymentIntent {
  const factory PaymentIntent({
    String? id,
    @JsonKey(name: 'order') String? order,
    @JsonKey(name: 'order_number') String? orderNumber,
    String? provider,
    String? method,
    @JsonKey(name: 'method_label') String? methodLabel,
    @JsonKey(fromJson: _optNum) String? amount,
    String? currency,
    @JsonKey(name: 'provider_reference') String? providerReference,
    String? status,
    @JsonKey(name: 'raw_response') @Default(<String, dynamic>{}) Map<String, dynamic> rawResponse,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _PaymentIntent;

  factory PaymentIntent.fromJson(Map<String, dynamic> json) =>
      _$PaymentIntentFromJson(json);
}

/// The three shapes `POST /marketplace/orders/payment-intents/` answers with,
/// flattened: an unconfigured rail, a hosted-checkout card hand-off, and a
/// live M-Pesa STK push.
///
/// `railConfigured == false` is a *success*, not a failure — the deployment has
/// no Flutterwave keys, so the order exists and no charge was started.
@freezed
abstract class PaymentIntentResult with _$PaymentIntentResult {
  const factory PaymentIntentResult({
    PaymentIntent? intent,
    @JsonKey(name: 'rail_configured') bool? railConfigured,
    @JsonKey(name: 'tx_ref') String? txRef,
    @JsonKey(name: 'public_key') String? publicKey,
    @JsonKey(name: 'amount') String? amount,
    String? currency,
    @JsonKey(name: 'customer_email') String? customerEmail,
    @JsonKey(name: 'customer_name') String? customerName,
    String? status,
  }) = _PaymentIntentResult;

  factory PaymentIntentResult.fromJson(Map<String, dynamic> json) =>
      _$PaymentIntentResultFromJson(json);
}
