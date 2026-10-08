import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_portal.freezed.dart';
part 'admin_portal.g.dart';

/// Typed client for `/api/v1/portal/**`, mirroring
/// `frontend/src/api/adminPortal.ts`.
///
/// Every member is optional-with-a-default on purpose, exactly as on the web:
/// this console is coded against a contract that is landing in parallel, so a
/// renamed or absent field must degrade in the UI rather than crash it. Fields
/// are named after the *server's* serializer, not the web client's optimistic
/// types — where the two disagree the server wins, because the server is what
/// answers.
///
/// The roster is never here. Gyms and communities expose `memberCount` and
/// nothing else; reading a member list is deliberately impossible through this
/// surface.
String? _optNumText(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toString();
  return v.toString();
}

double? _optDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

double _optDoubleOrZero(dynamic v) => _optDouble(v) ?? 0.0;

@freezed
abstract class PortalUser with _$PortalUser {
  const factory PortalUser({
    required String id,
    String? email,
    String? phone,
    @JsonKey(name: 'phone_verified') @Default(false) bool phoneVerified,
    @JsonKey(name: 'email_verified') @Default(false) bool emailVerified,
    String? username,
    @JsonKey(name: 'display_name') String? displayName,
    String? role,
    @JsonKey(name: 'verification_status') String? verificationStatus,
    @JsonKey(name: 'location_city') @Default('') String locationCity,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'is_staff') @Default(false) bool isStaff,
    @JsonKey(name: 'is_superuser') @Default(false) bool isSuperuser,
    @JsonKey(name: 'is_adult') @Default(false) bool isAdult,
    @JsonKey(name: 'totp_enabled') @Default(false) bool totpEnabled,
    @JsonKey(name: 'deleted_at') String? deletedAt,
    @JsonKey(name: 'order_count') @Default(0) int orderCount,
    @JsonKey(name: 'has_buddy_search') @Default(false) bool hasBuddySearch,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'last_login') String? lastLogin,
  }) = _PortalUser;

  factory PortalUser.fromJson(Map<String, dynamic> json) =>
      _$PortalUserFromJson(json);
}

@freezed
abstract class PortalShop with _$PortalShop {
  const factory PortalShop({
    required String id,
    String? name,
    String? handle,
    String? category,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'verification_status') String? verificationStatus,
    @JsonKey(name: 'rejection_reason') @Default('') String rejectionReason,
    @JsonKey(name: 'verification_applied_at') String? verificationAppliedAt,
    @JsonKey(name: 'verified_at') String? verifiedAt,
    @JsonKey(name: 'contact_email') @Default('') String contactEmail,
    @JsonKey(name: 'product_count') @Default(0) int productCount,
    @JsonKey(name: 'member_count') @Default(0) int memberCount,
    @JsonKey(name: 'owner_count') @Default(0) int ownerCount,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _PortalShop;

  factory PortalShop.fromJson(Map<String, dynamic> json) =>
      _$PortalShopFromJson(json);
}

@freezed
abstract class PortalProduct with _$PortalProduct {
  const factory PortalProduct({
    required String id,
    String? name,
    String? brand,
    String? category,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    String? shop,
    @JsonKey(name: 'shop_handle') String? shopHandle,
    @JsonKey(name: 'price_display') String? priceDisplay,
    @JsonKey(name: 'stock_quantity') int? stockQuantity,
    @JsonKey(name: 'stock_tracking_enabled') @Default(false) bool stockTrackingEnabled,
    @JsonKey(name: 'click_count') @Default(0) int clickCount,
    @JsonKey(name: 'content_rating') @Default('general') String contentRating,
    @JsonKey(name: 'supplement_registration_number') String? supplementRegistrationNumber,
    @JsonKey(name: 'supplement_registration_expiry') String? supplementRegistrationExpiry,
    @JsonKey(name: 'supplement_claims_reviewed') @Default(false) bool supplementClaimsReviewed,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _PortalProduct;

  factory PortalProduct.fromJson(Map<String, dynamic> json) =>
      _$PortalProductFromJson(json);
}

/// The Buddy Up certification review queue. Status vocabulary is
/// draft / submitted / under_review / approved / rejected / more_info_needed.
@freezed
abstract class PortalShopCertification with _$PortalShopCertification {
  const factory PortalShopCertification({
    required String id,
    String? shop,
    @JsonKey(name: 'shop_handle') String? shopHandle,
    @JsonKey(name: 'shop_name') String? shopName,
    @Default('draft') String status,
    @JsonKey(name: 'service_type') @Default('') String serviceType,
    @JsonKey(name: 'legal_name') @Default('') String legalName,
    @JsonKey(name: 'business_registration_number')
    @Default('')
    String businessRegistrationNumber,
    @Default('') String country,
    @Default('') String phone,
    @JsonKey(name: 'id_document_url') @Default('') String idDocumentUrl,
    @JsonKey(name: 'professional_cert_url') @Default('') String professionalCertUrl,
    @JsonKey(name: 'website_url') @Default('') String websiteUrl,
    @JsonKey(name: 'years_of_experience') int? yearsOfExperience,
    @JsonKey(name: 'specializations') @Default(<dynamic>[]) List<dynamic> specializations,
    @JsonKey(name: 'bio_statement') @Default('') String bioStatement,
    @JsonKey(name: 'agreed_to_creator_policy') @Default(false) bool agreedToCreatorPolicy,
    @JsonKey(name: 'submitted_by_username') String? submittedByUsername,
    @JsonKey(name: 'reviewer_notes') @Default('') String reviewerNotes,
    @JsonKey(name: 'rejection_reason') @Default('') String rejectionReason,
    @JsonKey(name: 'reviewed_by_username') String? reviewedByUsername,
    @JsonKey(name: 'reviewed_at') String? reviewedAt,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _PortalShopCertification;

  factory PortalShopCertification.fromJson(Map<String, dynamic> json) =>
      _$PortalShopCertificationFromJson(json);
}

@freezed
abstract class PortalOrderItem with _$PortalOrderItem {
  const factory PortalOrderItem({
    String? id,
    @JsonKey(name: 'item_type') @Default('') String itemType,
    @Default('') String title,
    @Default(1) int quantity,
    @JsonKey(name: 'fulfillment_status') @Default('') String fulfillmentStatus,
    @JsonKey(name: 'creator_username') String? creatorUsername,
    @JsonKey(name: 'creator_display_name') String? creatorDisplayName,
  }) = _PortalOrderItem;

  factory PortalOrderItem.fromJson(Map<String, dynamic> json) =>
      _$PortalOrderItemFromJson(json);
}

@freezed
abstract class PortalOrderCase with _$PortalOrderCase {
  const factory PortalOrderCase({
    String? id,
    String? order,
    @JsonKey(name: 'order_number') String? orderNumber,
    @JsonKey(name: 'case_type') @Default('') String caseType,
    @Default('open') String status,
    @JsonKey(name: 'reason') @Default('') String reason,
    @JsonKey(name: 'evidence') @Default(<String, dynamic>{}) Map<String, dynamic> evidence,
    @JsonKey(name: 'resolution') @Default('') String resolution,
    @JsonKey(name: 'resolved_at') String? resolvedAt,
    @JsonKey(name: 'requester_username') String? requesterUsername,
    // Always false, stated explicitly by the server: approving a case never
    // moves money.
    @JsonKey(name: 'affects_ledger') @Default(false) bool affectsLedger,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _PortalOrderCase;

  factory PortalOrderCase.fromJson(Map<String, dynamic> json) =>
      _$PortalOrderCaseFromJson(json);
}

@freezed
abstract class PortalOrder with _$PortalOrder {
  const factory PortalOrder({
    required String id,
    @JsonKey(name: 'order_number') @Default('') String orderNumber,
    @Default('') String status,
    @JsonKey(name: 'status_label') @Default('') String statusLabel,
    /// Server-computed from the flat `ORDER_FORWARD_STATES` map, which the
    /// `/portal/orders/<id>/status/` PATCH then enforces. The seller-facing
    /// endpoint is the fulfillment-aware one, so this list can be a superset.
    @JsonKey(name: 'allowed_next_statuses')
    @Default(<String>[])
    List<String> allowedNextStatuses,
    @JsonKey(name: 'fulfillment_type') @Default('digital') String fulfillmentType,
    @JsonKey(name: 'payment_method') String? paymentMethod,
    @JsonKey(name: 'payment_status') @Default('unpaid') String paymentStatus,
    @JsonKey(name: 'payment_reference') @Default('') String paymentReference,
    @JsonKey(name: 'payment_provider') @Default('') String paymentProvider,
    @JsonKey(name: 'buyer_username') String? buyerUsername,
    @JsonKey(name: 'buyer_display_name') String? buyerDisplayName,
    @JsonKey(name: 'buyer_email') String? buyerEmail,
    @JsonKey(name: 'delivery_address') @Default(<String, dynamic>{}) Map<String, dynamic> deliveryAddress,
    @JsonKey(name: 'pickup_details') @Default(<String, dynamic>{}) Map<String, dynamic> pickupDetails,
    @JsonKey(name: 'pickup_station') String? pickupStation,
    @JsonKey(name: 'delivery_personnel') String? deliveryPersonnel,
    @Default(<PortalOrderItem>[]) List<PortalOrderItem> items,
    @JsonKey(name: 'items_total_artifacts')
    @Default(<String, int>{})
    Map<String, int> itemsTotalArtifacts,
    @JsonKey(name: 'discount_artifacts')
    @Default(<String, int>{})
    Map<String, int> discountArtifacts,
    @JsonKey(name: 'total_artifacts') @Default(<String, int>{}) Map<String, int> totalArtifacts,
    @JsonKey(name: 'spent_usd', fromJson: _optDoubleOrZero) @Default(0.0) double spentUsd,
    @JsonKey(name: 'status_history') @Default(<Map<String, dynamic>>[]) List<Map<String, dynamic>> statusHistory,
    @Default(<PortalOrderCase>[]) List<PortalOrderCase> cases,
    @JsonKey(name: 'paid_at') String? paidAt,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _PortalOrder;

  factory PortalOrder.fromJson(Map<String, dynamic> json) =>
      _$PortalOrderFromJson(json);
}

/// `member_count` only — the portal never exposes a gym or community roster.
@freezed
abstract class PortalGym with _$PortalGym {
  const factory PortalGym({
    required String id,
    String? name,
    String? handle,
    String? category,
    @JsonKey(name: 'access_type') String? accessType,
    @JsonKey(name: 'subscription_type') String? subscriptionType,
    @JsonKey(name: 'is_verified') @Default(false) bool isVerified,
    @JsonKey(name: 'is_deleted') @Default(false) bool isDeleted,
    @JsonKey(name: 'deleted_at') String? deletedAt,
    @JsonKey(name: 'member_count') @Default(0) int memberCount,
    @JsonKey(name: 'location_city') @Default('') String locationCity,
    @JsonKey(name: 'location_country') @Default('') String locationCountry,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _PortalGym;

  factory PortalGym.fromJson(Map<String, dynamic> json) =>
      _$PortalGymFromJson(json);
}

@freezed
abstract class PortalCommunity with _$PortalCommunity {
  const factory PortalCommunity({
    required String id,
    @JsonKey(name: 'group_name') @Default('') String groupName,
    @JsonKey(name: 'is_group') @Default(false) bool isGroup,
    @JsonKey(name: 'is_community') @Default(false) bool isCommunity,
    @JsonKey(name: 'is_public') @Default(false) bool isPublic,
    @JsonKey(name: 'origin') @Default('') String origin,
    @JsonKey(name: 'invite_code') @Default('') String inviteCode,
    @Default('') String description,
    @JsonKey(name: 'gym_handle') String? gymHandle,
    @JsonKey(name: 'created_by_username') String? createdByUsername,
    @JsonKey(name: 'member_count') @Default(0) int memberCount,
    @JsonKey(name: 'post_count') @Default(0) int postCount,
    @JsonKey(name: 'last_message_at') String? lastMessageAt,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _PortalCommunity;

  factory PortalCommunity.fromJson(Map<String, dynamic> json) =>
      _$PortalCommunityFromJson(json);
}

@freezed
abstract class PortalStation with _$PortalStation {
  const factory PortalStation({
    required String id,
    @Default('') String name,
    @Default('') String description,
    @Default('') String address,
    @Default('') String city,
    @Default('') String country,
    @JsonKey(name: 'owner_type') @Default('') String ownerType,
    @JsonKey(name: 'owner_name') String? ownerName,
    String? shop,
    String? gym,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'is_primary') @Default(false) bool isPrimary,
    String? phone,
    @JsonKey(name: 'opening_hours') @Default(<String, dynamic>{}) Map<String, dynamic> openingHours,
    @JsonKey(fromJson: _optDouble) double? latitude,
    @JsonKey(fromJson: _optDouble) double? longitude,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _PortalStation;

  factory PortalStation.fromJson(Map<String, dynamic> json) =>
      _$PortalStationFromJson(json);
}

@freezed
abstract class PortalStationApplication with _$PortalStationApplication {
  const factory PortalStationApplication({
    required String id,
    String? shop,
    @JsonKey(name: 'shop_handle') String? shopHandle,
    String? gym,
    @JsonKey(name: 'gym_handle') String? gymHandle,
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
    @JsonKey(name: 'submitted_by_username') String? submittedByUsername,
    @JsonKey(name: 'reviewer_notes') @Default('') String reviewerNotes,
    @JsonKey(name: 'rejection_reason') @Default('') String rejectionReason,
    @JsonKey(name: 'reviewed_by_username') String? reviewedByUsername,
    @JsonKey(name: 'reviewed_at') String? reviewedAt,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _PortalStationApplication;

  factory PortalStationApplication.fromJson(Map<String, dynamic> json) =>
      _$PortalStationApplicationFromJson(json);
}

@freezed
abstract class PortalDeliveryPersonnel with _$PortalDeliveryPersonnel {
  const factory PortalDeliveryPersonnel({
    required String id,
    @JsonKey(name: 'username') @Default('') String username,
    @JsonKey(name: 'display_name') @Default('') String displayName,
    String? email,
    @JsonKey(name: 'vehicle_type') @Default('bike') String vehicleType,
    @JsonKey(name: 'service_zones') @Default(<String>[]) List<String> serviceZones,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'rating', fromJson: _optDouble) double? rating,
    @JsonKey(name: 'bio') @Default('') String bio,
    @JsonKey(name: 'active_order_count') @Default(0) int activeOrderCount,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _PortalDeliveryPersonnel;

  factory PortalDeliveryPersonnel.fromJson(Map<String, dynamic> json) =>
      _$PortalDeliveryPersonnelFromJson(json);
}

@freezed
abstract class PortalDeliveryApplication with _$PortalDeliveryApplication {
  const factory PortalDeliveryApplication({
    required String id,
    String? profile,
    @JsonKey(name: 'username') @Default('') String username,
    @JsonKey(name: 'display_name') @Default('') String displayName,
    @JsonKey(name: 'vehicle_type') @Default('bike') String vehicleType,
    @JsonKey(name: 'service_zones') @Default(<String>[]) List<String> serviceZones,
    @JsonKey(name: 'id_document_url') @Default('') String idDocumentUrl,
    @JsonKey(name: 'licence_document_url') @Default('') String licenceDocumentUrl,
    @Default('') String phone,
    @Default('') String bio,
    @Default('draft') String status,
    @JsonKey(name: 'reviewer_notes') @Default('') String reviewerNotes,
    @JsonKey(name: 'rejection_reason') @Default('') String rejectionReason,
    @JsonKey(name: 'reviewed_by_username') String? reviewedByUsername,
    @JsonKey(name: 'reviewed_at') String? reviewedAt,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _PortalDeliveryApplication;

  factory PortalDeliveryApplication.fromJson(Map<String, dynamic> json) =>
      _$PortalDeliveryApplicationFromJson(json);
}

/// Read-only, forever: a transaction row is evidence a balance already moved.
@freezed
abstract class PortalTransaction with _$PortalTransaction {
  const factory PortalTransaction({
    required String id,
    @JsonKey(name: 'tx_ref') @Default('') String txRef,
    @JsonKey(name: 'transaction_type') @Default('') String transactionType,
    @Default('') String direction,
    @Default('') String status,
    @JsonKey(name: 'artifact_type') @Default('') String artifactType,
    @Default(0) int quantity,
    @JsonKey(name: 'user_username') @Default('') String userUsername,
    @JsonKey(name: 'user_email') @Default('') String userEmail,
    @JsonKey(name: 'counterparty_username') String? counterpartyUsername,
    @JsonKey(name: 'reference_id') @Default('') String referenceId,
    @JsonKey(name: 'fiat_amount', fromJson: _optNumText) String? fiatAmount,
    @JsonKey(name: 'fiat_currency') @Default('') String fiatCurrency,
    @JsonKey(name: 'payment_provider') @Default('') String paymentProvider,
    @JsonKey(name: 'flutterwave_id') @Default('') String flutterwaveId,
    @JsonKey(name: 'phone_number') @Default('') String phoneNumber,
    @JsonKey(name: 'bank_account') @Default('') String bankAccount,
    @Default('') String description,
    @JsonKey(name: 'journal_entry') String? journalEntry,
    @JsonKey(name: 'clearance_at') String? clearanceAt,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _PortalTransaction;

  factory PortalTransaction.fromJson(Map<String, dynamic> json) =>
      _$PortalTransactionFromJson(json);
}

/// `/portal/wallet/reconciliation/` — read-only, never writes the ledger.
@freezed
abstract class PortalReconciliationReport with _$PortalReconciliationReport {
  const factory PortalReconciliationReport({
    @JsonKey(name: 'provider') @Default(<String, dynamic>{}) Map<String, dynamic> provider,
    @JsonKey(name: 'local') @Default(<String, dynamic>{}) Map<String, dynamic> local,
    @JsonKey(name: 'window_days') @Default(30) int windowDays,
    @JsonKey(name: 'writes_ledger') @Default(false) bool writesLedger,
  }) = _PortalReconciliationReport;

  factory PortalReconciliationReport.fromJson(Map<String, dynamic> json) =>
      _$PortalReconciliationReportFromJson(json);
}

/// Envelope members every `/portal/**` list returns, so a table can show the
/// real total instead of counting the rows it happens to be holding.
@freezed
abstract class PortalPagination with _$PortalPagination {
  const factory PortalPagination({
    @Default(0) int count,
    String? next,
    String? previous,
  }) = _PortalPagination;

  factory PortalPagination.fromJson(Map<String, dynamic> json) =>
      _$PortalPaginationFromJson(json);
}