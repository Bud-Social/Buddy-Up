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
    @JsonKey(name: 'purchase_count') @Default(0) int purchaseCount,
    @JsonKey(name: 'average_rating') @Default(0.0) double averageRating,
    @JsonKey(name: 'review_count') @Default(0) int reviewCount,
    @JsonKey(name: 'creator_data') required CreatorData creatorData,
    @JsonKey(name: 'is_purchased') @Default(false) bool isPurchased,
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
    @JsonKey(name: 'recommended_by') String? recommendedBy,
    @JsonKey(name: 'recommender_data') Map<String, dynamic>? recommenderData,
    @JsonKey(name: 'click_count') @Default(0) int clickCount,
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
abstract class MarketplaceEvent with _$MarketplaceEvent {
  const factory MarketplaceEvent({
    required String id,
    @JsonKey(name: 'creator_data') required CreatorData creatorData,
    @JsonKey(name: 'gym_data') GymData? gymData,
    required String title,
    required String description,
    @JsonKey(name: 'cover_image_url') required String coverImageUrl,
    @JsonKey(name: 'event_type') required String eventType,
    required String location,
    @JsonKey(name: 'online_url') required String onlineUrl,
    @JsonKey(name: 'start_datetime') required String startDatetime,
    @JsonKey(name: 'end_datetime') required String endDatetime,
    required String timezone,
    required int capacity,
    @JsonKey(name: 'ticket_price_artifacts')
    required Map<String, int> ticketPriceArtifacts,
    @JsonKey(name: 'is_free') @Default(false) bool isFree,
    @JsonKey(name: 'is_published') @Default(false) bool isPublished,
    @JsonKey(name: 'is_cancelled') @Default(false) bool isCancelled,
    @JsonKey(name: 'attendee_count') @Default(0) int attendeeCount,
    @Default(<String>[]) List<String> tags,
    @Default('') String category,
    @JsonKey(name: 'is_registered') @Default(false) bool isRegistered,
    @JsonKey(name: 'spots_remaining') int? spotsRemaining,
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
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _Cart;

  factory Cart.fromJson(Map<String, dynamic> json) => _$CartFromJson(json);
}

@freezed
abstract class DiscountCode with _$DiscountCode {
  const factory DiscountCode({
    required String code,
    @JsonKey(name: 'discount_pct') @Default(0) int discountPct,
    @JsonKey(name: 'discount_artifacts') Map<String, int>? discountArtifacts,
  }) = _DiscountCode;

  factory DiscountCode.fromJson(Map<String, dynamic> json) =>
      _$DiscountCodeFromJson(json);
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
