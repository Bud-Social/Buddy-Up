import 'dart:convert';

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

/// Accepts a non-string where a `String?` is declared.
///
/// Used for the handful of governance fields whose type is "a sentence on the
/// happy path and something structured on an edge" — `effect` on an approval
/// is a string today and a dict the day an action grows a payload. A cast error
/// at decode time would blank the whole row, which is a worse outcome than
/// printing the JSON.
class _FlexibleTextConverter implements JsonConverter<String?, dynamic> {
  const _FlexibleTextConverter();

  @override
  String? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is String) return json;
    try {
      return jsonEncode(json);
    } on Object {
      return json.toString();
    }
  }

  @override
  dynamic toJson(String? object) => object;
}

/// Normalise any map-shaped JSON value to `Map<String, dynamic>`.
///
/// json_serializable generates a bare `json['key'] as Map<String, dynamic>?`
/// for a map field, and that cast throws on a `_Map<dynamic, dynamic>` — which
/// is what an empty or hand-built map literal actually is. A field that is
/// legitimately allowed to be empty (`before`, `after`, `payload`) therefore
/// crashes the decoder on the *empty* case, which is the one most likely to
/// arrive. Coercing here means an empty delta or a renamed field degrades to
/// an empty map instead of taking the row — and the queue it sits in — down.
Map<String, dynamic>? _stringKeyedMap(dynamic json) {
  if (json is Map<String, dynamic>) return json;
  if (json is Map) return json.map((key, value) => MapEntry('$key', value));
  return null;
}

/// The same coercion for a field that is non-nullable with a default: a value
/// of the wrong shape becomes an empty map rather than an exception.
Map<String, dynamic> _stringKeyedMapOrEmpty(dynamic json) =>
    _stringKeyedMap(json) ?? <String, dynamic>{};

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

// ---------------------------------------------------------------------------
// `/api/v1/governance/**` — the two-person surface.
//
// Separate from `/portal/**` on the server because the routes that grant
// access must not sit in the same table as the routes access is granted over.
// The models keep that separation rather than merging them into Portal*.
// ---------------------------------------------------------------------------

/// The `{id, email, display_name}` identity object
/// `governance.serializers._user_ref` returns.
///
/// A three-field object rather than the whole user row: governance rows outlive
/// their actors (`requested_by` is SET_NULL, `actor` is SET_NULL) and the
/// serializers snapshot what matters separately, so nothing here is load-bearing.
@freezed
abstract class GovernanceUserRef with _$GovernanceUserRef {
  const factory GovernanceUserRef({
    String? id,
    String? email,
    @JsonKey(name: 'display_name') @Default('') String displayName,
  }) = _GovernanceUserRef;

  factory GovernanceUserRef.fromJson(Map<String, dynamic> json) =>
      _$GovernanceUserRefFromJson(json);
}

extension GovernanceUserRefX on GovernanceUserRef? {
  String get label {
    final ref = this;
    if (ref == null) return 'Unknown';
    if (ref.displayName.trim().isNotEmpty) return ref.displayName.trim();
    if ((ref.email ?? '').trim().isNotEmpty) return ref.email!.trim();
    final id = ref.id ?? '';
    return id.isEmpty ? 'Unknown' : id.substring(0, id.length > 8 ? 8 : id.length);
  }
}

/// One row of `governance_staff_role`: a holder, their role, and its scopes.
///
/// `effectiveScopes` is the authoritative list to show — it is the role's
/// defaults plus the per-person extras, computed server-side. `defaultScopes`
/// is the floor the role definition owns and `scopes` the override on top, so
/// all three are surfaced rather than precomputed here.
@freezed
abstract class StaffRole with _$StaffRole {
  const factory StaffRole({
    String? id,
    @JsonKey(name: 'user') GovernanceUserRef? user,
    @Default('') String role,
    @JsonKey(name: 'role_display') @Default('') String roleDisplay,
    @Default(<String>[]) List<String> scopes,
    @JsonKey(name: 'default_scopes') @Default(<String>[]) List<String> defaultScopes,
    @JsonKey(name: 'effective_scopes')
    @Default(<String>[])
    List<String> effectiveScopes,
    @JsonKey(name: 'granted_by') GovernanceUserRef? grantedBy,
    @JsonKey(name: 'granted_at') String? grantedAt,
    @Default('') String notes,
    @JsonKey(name: 'revoked_at') String? revokedAt,
    /// A revoked row grants nothing but is kept for the audit trail, so this
    /// defaults false: an absent field must not read as "currently holds it".
    @JsonKey(name: 'is_active') @Default(false) bool isActive,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _StaffRole;

  factory StaffRole.fromJson(Map<String, dynamic> json) =>
      _$StaffRoleFromJson(json);
}

/// `governance_account_action_request` — a high-risk action awaiting a second,
/// independent approver. Status vocabulary is pending / approved / rejected /
/// cancelled, and every field is server-owned: the write endpoints take a
/// separate input shape so `status` can never be set by a client.
@freezed
abstract class AccountActionRequest with _$AccountActionRequest {
  const factory AccountActionRequest({
    String? id,
    @Default('') String action,
    @JsonKey(name: 'action_display') @Default('') String actionDisplay,
    @JsonKey(name: 'required_scope') @Default('') String requiredScope,
    @JsonKey(name: 'target_user') GovernanceUserRef? targetUser,
    @JsonKey(name: 'payload', fromJson: _stringKeyedMapOrEmpty)
    @Default(<String, dynamic>{})
    Map<String, dynamic> payload,
    @Default('') String status,
    @JsonKey(name: 'is_open') @Default(false) bool isOpen,
    @JsonKey(name: 'requested_by') GovernanceUserRef? requestedBy,
    /// Snapshot of the requester's name. Survives the actor's deletion, which
    /// is the row you most want to still be able to audit.
    @JsonKey(name: 'requested_by_profile') @Default('') String requestedByProfile,
    @JsonKey(name: 'decided_by') GovernanceUserRef? decidedBy,
    @JsonKey(name: 'decided_at') String? decidedAt,
    @JsonKey(name: 'decision_note') @Default('') String decisionNote,
    @JsonKey(name: 'requires_second') @Default(true) bool requiresSecond,
    /// Null until the approve call has actually applied the effect. A request
    /// reading "approved" with no `applied_at` is the case the approve view
    /// rolls back rather than leaves lying.
    @JsonKey(name: 'applied_at') String? appliedAt,
    /// Only on the approve response: a human-readable description of what
    /// happened. Other actions record that nothing automatic was done.
    @JsonKey(name: 'effect') @_FlexibleTextConverter() String? effect,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _AccountActionRequest;

  factory AccountActionRequest.fromJson(Map<String, dynamic> json) =>
      _$AccountActionRequestFromJson(json);
}

extension AccountActionRequestX on AccountActionRequest {
  /// The operator-written justification from `payload.reason`.
  ///
  /// Read defensively: `payload` is a free-form JSONField and a rename here
  /// must degrade to "no reason recorded", not to a cast error on the queue
  /// row that would blank the whole list.
  String get reason {
    final value = payload['reason'];
    if (value is String) return value.trim();
    return '';
  }

  /// `payload.duration_days`, when the action has a term. A ban never has one —
  /// the server refuses the field rather than quietly dropping it.
  int? get durationDays {
    final value = payload['duration_days'];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value');
  }

  /// Who asked, preferring the deletion-proof snapshot over the live FK.
  String get requesterLabel {
    if (requestedByProfile.trim().isNotEmpty) return requestedByProfile.trim();
    return requestedBy.label;
  }

  bool get isPending => status == 'pending';

  bool get isSettled => !isPending;
}

/// `governance_admin_action_log` — one immutable row per mutating staff action.
///
/// `before` / `after` are state deltas with secrets redacted at *write* time by
/// `record_admin_action`; they are returned in full because "recall the details
/// of any action" is the requirement. They are never for content.
@freezed
abstract class AdminActionLog with _$AdminActionLog {
  const factory AdminActionLog({
    String? id,
    String? actor,
    /// Snapshot of the actor's address at call time, so deleting a staff
    /// account does not delete the evidence that it acted.
    @JsonKey(name: 'actor_email') @Default('') String actorEmail,
    @Default('') String action,
    @JsonKey(name: 'target_type') @Default('') String targetType,
    @JsonKey(name: 'target_id') @Default('') String targetId,
    @Default('') String summary,
    @JsonKey(name: 'before', fromJson: _stringKeyedMap) Map<String, dynamic>? before,
    @JsonKey(name: 'after', fromJson: _stringKeyedMap) Map<String, dynamic>? after,
    @JsonKey(name: 'request_id') @Default('') String requestId,
    @JsonKey(name: 'ip_address') String? ipAddress,
    @JsonKey(name: 'user_agent') @Default('') String userAgent,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _AdminActionLog;

  factory AdminActionLog.fromJson(Map<String, dynamic> json) =>
      _$AdminActionLogFromJson(json);
}

extension AdminActionLogX on AdminActionLog {
  String get actorLabel {
    if (actorEmail.trim().isNotEmpty) return actorEmail.trim();
    final id = actor ?? '';
    return id.isEmpty ? 'system' : id.substring(0, id.length > 8 ? 8 : id.length);
  }

  /// Keys whose value actually changed, for a one-line delta summary.
  ///
  /// Computed here rather than shown as two raw JSON blobs because the useful
  /// question is "what moved", and the answer is the set difference.
  List<String> get changedKeys {
    final before_ = before ?? const <String, dynamic>{};
    final after_ = after ?? const <String, dynamic>{};
    final keys = <String>{...before_.keys, ...after_.keys};
    return keys.where((key) {
      final b = '${before_[key] ?? ''}';
      final a = '${after_[key] ?? ''}';
      return b != a;
    }).toList()
      ..sort();
  }

  /// The recorded value of [key] on one side of the delta. [useAfter] picks
  /// the side — named `after` it would shadow the [after] field and silently
  /// resolve to the flag.
  String valueAt(String key, {bool useAfter = false}) {
    final Map<String, dynamic> source =
        (useAfter ? after : before) ?? const <String, dynamic>{};
    final value = source[key];
    return value == null ? '' : '$value';
  }
}

/// `governance_email_log` — one row per message this platform sent to a user.
///
/// Deliberately not the message: `bodyPreview` is the first 500 characters of
/// the rendered body, because a log storing whole messages would outlive the
/// user's account, the retention policy and every deletion request.
@freezed
abstract class EmailLog with _$EmailLog {
  const factory EmailLog({
    String? id,
    @JsonKey(name: 'recipient_user') String? recipientUser,
    @JsonKey(name: 'recipient') GovernanceUserRef? recipient,
    @JsonKey(name: 'recipient_email') @Default('') String recipientEmail,
    @Default('') String subject,
    @JsonKey(name: 'body_preview') @Default('') String bodyPreview,
    @JsonKey(name: 'template_key') @Default('') String templateKey,
    @JsonKey(name: 'sent_by') String? sentBy,
    @JsonKey(name: 'sender') GovernanceUserRef? sender,
    @JsonKey(name: 'sent_by_email') @Default('') String sentByEmail,
    /// queued / sent / failed / skipped.
    @Default('') String status,
    @Default('') String error,
    @JsonKey(name: 'dedupe_key') @Default('') String dedupeKey,
    @JsonKey(name: 'related_object_type') @Default('') String relatedObjectType,
    @JsonKey(name: 'related_object_id') @Default('') String relatedObjectId,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _EmailLog;

  factory EmailLog.fromJson(Map<String, dynamic> json) =>
      _$EmailLogFromJson(json);
}

extension EmailLogX on EmailLog {
  /// Only a `failed` row is resendable: re-sending a `sent` message is a
  /// duplicate the user did not ask for and a `queued` one duplicates the
  /// worker's own retry.
  bool get canResend => status == 'failed';
}

// ---------------------------------------------------------------------------
// `/api/v1/moderation/**` — content flags, reports, the action ledger,
// appeals and commendations.
// ---------------------------------------------------------------------------

/// `moderation_content_flag` — one AI or threshold-raised flag awaiting review.
@freezed
abstract class ContentFlag with _$ContentFlag {
  const factory ContentFlag({
    String? id,
    @JsonKey(name: 'flag_reason') @Default('') String flagReason,
    @Default('') String severity,
    @JsonKey(name: 'confidence', fromJson: _optDoubleOrZero) @Default(0.0) double confidence,
    @Default('auto') String source,
    @JsonKey(name: 'content_type') @Default('') String contentType,
    @JsonKey(name: 'content_id') @Default('') String contentId,
    @JsonKey(name: 'content_preview') @Default('') String contentPreview,
    @JsonKey(name: 'is_actioned') @Default(false) bool isActioned,
    @JsonKey(name: 'action_taken') @Default('') String actionTaken,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _ContentFlag;

  factory ContentFlag.fromJson(Map<String, dynamic> json) =>
      _$ContentFlagFromJson(json);
}

/// `GET /moderation/content-flags/stats/` — the dashboard header counters.
@freezed
abstract class ModerationStats with _$ModerationStats {
  const factory ModerationStats({
    @Default(0) int total,
    @Default(0) int unactioned,
    @Default(0) int actioned,
    @JsonKey(name: 'by_severity', fromJson: _stringKeyedMapOrEmpty)
    @Default(<String, dynamic>{})
    Map<String, dynamic> bySeverity,
    @JsonKey(name: 'by_reason', fromJson: _stringKeyedMapOrEmpty)
    @Default(<String, dynamic>{})
    Map<String, dynamic> byReason,
  }) = _ModerationStats;

  factory ModerationStats.fromJson(Map<String, dynamic> json) =>
      _$ModerationStatsFromJson(json);
}

/// `moderation_report` — a user report against another account.
///
/// `slaDueAt` / `slaBreached` are computed server-side in Python from two
/// already-loaded columns (see `serializers.sla_due_at_for`): 4 hours for the
/// urgent reasons, 24 for everything else. They are read, never recomputed
/// here — a client-side clock would disagree with the queue's own deadline.
@freezed
abstract class ModerationReport with _$ModerationReport {
  const factory ModerationReport({
    String? id,
    String? reporter,
    @JsonKey(name: 'target_user') String? targetUser,
    @Default('') String reason,
    @Default('') String description,
    @JsonKey(name: 'content_url') @Default('') String contentUrl,
    /// open / investigating / resolved / dismissed.
    @Default('') String status,
    @JsonKey(name: 'assigned_to') String? assignedTo,
    @JsonKey(name: 'resolved_at') String? resolvedAt,
    @JsonKey(name: 'resolution_note') @Default('') String resolutionNote,
    @JsonKey(name: 'sla_due_at') String? slaDueAt,
    @JsonKey(name: 'sla_breached') @Default(false) bool slaBreached,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _ModerationReport;

  factory ModerationReport.fromJson(Map<String, dynamic> json) =>
      _$ModerationReportFromJson(json);
}

/// `moderation_action` — the ledger. Every disciplinary decision lands here,
/// including the `escalated` and `report_dismissed` rows that record an
/// internal routing decision without telling the user anything.
@freezed
abstract class ModerationAction with _$ModerationAction {
  const factory ModerationAction({
    String? id,
    @Default('') String action,
    String? moderator,
    String? report,
    @JsonKey(name: 'target_user') String? targetUser,
    @Default('') String reason,
    @JsonKey(name: 'duration_days') int? durationDays,
    @JsonKey(name: 'content_type') @Default('') String contentType,
    @JsonKey(name: 'content_type_display') @Default('') String contentTypeDisplay,
    @JsonKey(name: 'content_id') @Default('') String contentId,
    @JsonKey(name: 'is_reversed') @Default(false) bool isReversed,
    @JsonKey(name: 'reversed_by') String? reversedBy,
    @JsonKey(name: 'reversed_at') String? reversedAt,
    @JsonKey(name: 'reversal_reason') @Default('') String reversalReason,
    @JsonKey(name: 'reversed_by_moderator', fromJson: _stringKeyedMapOrEmpty)
    @Default(<String, dynamic>{})
    Map<String, dynamic> reversedByModerator,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _ModerationAction;

  factory ModerationAction.fromJson(Map<String, dynamic> json) =>
      _$ModerationActionFromJson(json);
}

extension ModerationActionX on ModerationAction {
  /// Actions the server will let a moderator reverse. Reversing a
  /// `report_dismissed` or `action_reversed` row is not a thing the view
  /// offers, so the console does not either.
  bool get isReversible =>
      !isReversed && (action == 'warning' || action == 'content_removed' ||
          action == 'user_suspended' || action == 'user_banned');

  String get targetLabel {
    final id = targetUser ?? '';
    return id.isEmpty ? 'Unknown' : id.substring(0, id.length > 8 ? 8 : id.length);
  }
}

/// The 202 body of `POST /moderation/actions/` for a ban or suspension.
///
/// `applied: false` is the load-bearing part: the moderator raised a request
/// and got no ban, so the console says "pending a second approver" rather than
/// reporting success.
@freezed
abstract class ModerationActionOutcome with _$ModerationActionOutcome {
  const factory ModerationActionOutcome({
    @JsonKey(name: 'moderation_action') ModerationAction? moderationAction,
    @JsonKey(name: 'approval') ModerationApprovalStub? approval,
    @Default(false) bool applied,
  }) = _ModerationActionOutcome;

  factory ModerationActionOutcome.fromJson(Map<String, dynamic> json) =>
      _$ModerationActionOutcomeFromJson(json);
}

/// The `approval` stub nested inside the 202 body — four fields, not the full
/// request row, because the point is "it exists and it is pending".
@freezed
abstract class ModerationApprovalStub with _$ModerationApprovalStub {
  const factory ModerationApprovalStub({
    String? id,
    @Default('') String action,
    @Default('') String status,
    @JsonKey(name: 'requires_second') @Default(true) bool requiresSecond,
    @JsonKey(name: 'requested_by') String? requestedBy,
  }) = _ModerationApprovalStub;

  factory ModerationApprovalStub.fromJson(Map<String, dynamic> json) =>
      _$ModerationApprovalStubFromJson(json);
}

/// `POST /moderation/actions/{id}/reverse/` — the original, the reversal row
/// and what actually changed.
@freezed
abstract class ModerationReversalOutcome with _$ModerationReversalOutcome {
  const factory ModerationReversalOutcome({
    @JsonKey(name: 'reversed_action') ModerationAction? reversedAction,
    @JsonKey(name: 'reversal') ModerationAction? reversal,
    @JsonKey(name: 'effect') @_FlexibleTextConverter() String? effect,
  }) = _ModerationReversalOutcome;

  factory ModerationReversalOutcome.fromJson(Map<String, dynamic> json) =>
      _$ModerationReversalOutcomeFromJson(json);
}

/// `POST /moderation/content-flags/{id}/act/` — the flag after the decision.
@freezed
abstract class ContentFlagOutcome with _$ContentFlagOutcome {
  const factory ContentFlagOutcome({
    ContentFlag? flag,
    @JsonKey(name: 'effect') @_FlexibleTextConverter() String? effect,
  }) = _ContentFlagOutcome;

  factory ContentFlagOutcome.fromJson(Map<String, dynamic> json) =>
      _$ContentFlagOutcomeFromJson(json);
}

/// `GET /moderation/content-flags/pending-approvals/` — ban/suspension
/// requests still waiting for their second approver, surfaced on the moderation
/// side so a moderator who asked for a ban can see it is queued rather than
/// assume it failed.
@freezed
abstract class ModerationPendingApproval with _$ModerationPendingApproval {
  const factory ModerationPendingApproval({
    String? id,
    /// `ban` or `suspension` — the governance action vocabulary, not the
    /// moderation one (`user_banned` / `user_suspended`).
    @JsonKey(name: 'governance_action') @Default('') String governanceAction,
    @JsonKey(name: 'target_user') String? targetUser,
    @JsonKey(name: 'requested_by') String? requestedBy,
    @JsonKey(name: 'requested_by_profile') @Default('') String requestedByProfile,
    @Default('') String reason,
    @JsonKey(name: 'duration_days') int? durationDays,
    @JsonKey(name: 'requires_second') @Default(true) bool requiresSecond,
    @JsonKey(name: 'waiting_seconds') @Default(0) int waitingSeconds,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'moderation_action_id') String? moderationActionId,
  }) = _ModerationPendingApproval;

  factory ModerationPendingApproval.fromJson(Map<String, dynamic> json) =>
      _$ModerationPendingApprovalFromJson(json);
}

/// `moderation_appeal` — a user's challenge to an action against their account.
///
/// `action` is the id of the `ModerationAction` being challenged, and the
/// unique constraint is (action, appellant): one appeal per action per user.
/// A second attempt is refused by the database, so the create form says so
/// rather than letting the user discover it from a 500.
@freezed
abstract class ModerationAppeal with _$ModerationAppeal {
  const factory ModerationAppeal({
    String? id,
    String? action,
    String? appellant,
    @Default('') String reason,
    /// submitted / under_review / approved / denied.
    @Default('') String status,
    String? reviewer,
    @JsonKey(name: 'reviewed_at') String? reviewedAt,
    @JsonKey(name: 'resolution_note') @Default('') String resolutionNote,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _ModerationAppeal;

  factory ModerationAppeal.fromJson(Map<String, dynamic> json) =>
      _$ModerationAppealFromJson(json);
}

extension ModerationAppealX on ModerationAppeal {
  bool get isOpen => status == 'submitted' || status == 'under_review';
}

/// `moderation_commendation` — the positive half of moderation.
///
/// `recipient` is a **Profile** id, not a user id: `CommendationCreateSerializer`
/// resolves it through `Profile.objects`, and the staff console picks a person
/// from the portal user list, so the two ids have to be translated. The lookup
/// `adminscan` does is documented on the grant form.
@freezed
abstract class ModerationCommendation with _$ModerationCommendation {
  const factory ModerationCommendation({
    String? id,
    /// A profile UUID, per `Commendation.recipient`.
    String? recipient,
    @JsonKey(name: 'issued_by') String? issuedBy,
    @Default('') String category,
    @JsonKey(name: 'category_display') @Default('') String categoryDisplay,
    @Default('') String message,
    @JsonKey(name: 'visible_to_recipient') @Default(true) bool visibleToRecipient,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _ModerationCommendation;

  factory ModerationCommendation.fromJson(Map<String, dynamic> json) =>
      _$ModerationCommendationFromJson(json);
}