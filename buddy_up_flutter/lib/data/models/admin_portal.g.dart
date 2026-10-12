// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_portal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PortalUser _$PortalUserFromJson(Map<String, dynamic> json) => _PortalUser(
  id: json['id'] as String,
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  phoneVerified: json['phone_verified'] as bool? ?? false,
  emailVerified: json['email_verified'] as bool? ?? false,
  username: json['username'] as String?,
  displayName: json['display_name'] as String?,
  role: json['role'] as String?,
  verificationStatus: json['verification_status'] as String?,
  locationCity: json['location_city'] as String? ?? '',
  isActive: json['is_active'] as bool? ?? true,
  isStaff: json['is_staff'] as bool? ?? false,
  isSuperuser: json['is_superuser'] as bool? ?? false,
  isAdult: json['is_adult'] as bool? ?? false,
  totpEnabled: json['totp_enabled'] as bool? ?? false,
  deletedAt: json['deleted_at'] as String?,
  orderCount: (json['order_count'] as num?)?.toInt() ?? 0,
  hasBuddySearch: json['has_buddy_search'] as bool? ?? false,
  createdAt: json['created_at'] as String?,
  lastLogin: json['last_login'] as String?,
);

Map<String, dynamic> _$PortalUserToJson(_PortalUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'phone': instance.phone,
      'phone_verified': instance.phoneVerified,
      'email_verified': instance.emailVerified,
      'username': instance.username,
      'display_name': instance.displayName,
      'role': instance.role,
      'verification_status': instance.verificationStatus,
      'location_city': instance.locationCity,
      'is_active': instance.isActive,
      'is_staff': instance.isStaff,
      'is_superuser': instance.isSuperuser,
      'is_adult': instance.isAdult,
      'totp_enabled': instance.totpEnabled,
      'deleted_at': instance.deletedAt,
      'order_count': instance.orderCount,
      'has_buddy_search': instance.hasBuddySearch,
      'created_at': instance.createdAt,
      'last_login': instance.lastLogin,
    };

_PortalShop _$PortalShopFromJson(Map<String, dynamic> json) => _PortalShop(
  id: json['id'] as String,
  name: json['name'] as String?,
  handle: json['handle'] as String?,
  category: json['category'] as String?,
  isActive: json['is_active'] as bool? ?? true,
  verificationStatus: json['verification_status'] as String?,
  rejectionReason: json['rejection_reason'] as String? ?? '',
  verificationAppliedAt: json['verification_applied_at'] as String?,
  verifiedAt: json['verified_at'] as String?,
  contactEmail: json['contact_email'] as String? ?? '',
  productCount: (json['product_count'] as num?)?.toInt() ?? 0,
  memberCount: (json['member_count'] as num?)?.toInt() ?? 0,
  ownerCount: (json['owner_count'] as num?)?.toInt() ?? 0,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$PortalShopToJson(_PortalShop instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'handle': instance.handle,
      'category': instance.category,
      'is_active': instance.isActive,
      'verification_status': instance.verificationStatus,
      'rejection_reason': instance.rejectionReason,
      'verification_applied_at': instance.verificationAppliedAt,
      'verified_at': instance.verifiedAt,
      'contact_email': instance.contactEmail,
      'product_count': instance.productCount,
      'member_count': instance.memberCount,
      'owner_count': instance.ownerCount,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

_PortalProduct _$PortalProductFromJson(Map<String, dynamic> json) =>
    _PortalProduct(
      id: json['id'] as String,
      name: json['name'] as String?,
      brand: json['brand'] as String?,
      category: json['category'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      shop: json['shop'] as String?,
      shopHandle: json['shop_handle'] as String?,
      priceDisplay: json['price_display'] as String?,
      stockQuantity: (json['stock_quantity'] as num?)?.toInt(),
      stockTrackingEnabled: json['stock_tracking_enabled'] as bool? ?? false,
      clickCount: (json['click_count'] as num?)?.toInt() ?? 0,
      contentRating: json['content_rating'] as String? ?? 'general',
      supplementRegistrationNumber:
          json['supplement_registration_number'] as String?,
      supplementRegistrationExpiry:
          json['supplement_registration_expiry'] as String?,
      supplementClaimsReviewed:
          json['supplement_claims_reviewed'] as bool? ?? false,
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$PortalProductToJson(_PortalProduct instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'brand': instance.brand,
      'category': instance.category,
      'is_active': instance.isActive,
      'shop': instance.shop,
      'shop_handle': instance.shopHandle,
      'price_display': instance.priceDisplay,
      'stock_quantity': instance.stockQuantity,
      'stock_tracking_enabled': instance.stockTrackingEnabled,
      'click_count': instance.clickCount,
      'content_rating': instance.contentRating,
      'supplement_registration_number': instance.supplementRegistrationNumber,
      'supplement_registration_expiry': instance.supplementRegistrationExpiry,
      'supplement_claims_reviewed': instance.supplementClaimsReviewed,
      'created_at': instance.createdAt,
    };

_PortalShopCertification _$PortalShopCertificationFromJson(
  Map<String, dynamic> json,
) => _PortalShopCertification(
  id: json['id'] as String,
  shop: json['shop'] as String?,
  shopHandle: json['shop_handle'] as String?,
  shopName: json['shop_name'] as String?,
  status: json['status'] as String? ?? 'draft',
  serviceType: json['service_type'] as String? ?? '',
  legalName: json['legal_name'] as String? ?? '',
  businessRegistrationNumber:
      json['business_registration_number'] as String? ?? '',
  country: json['country'] as String? ?? '',
  phone: json['phone'] as String? ?? '',
  idDocumentUrl: json['id_document_url'] as String? ?? '',
  professionalCertUrl: json['professional_cert_url'] as String? ?? '',
  websiteUrl: json['website_url'] as String? ?? '',
  yearsOfExperience: (json['years_of_experience'] as num?)?.toInt(),
  specializations:
      json['specializations'] as List<dynamic>? ?? const <dynamic>[],
  bioStatement: json['bio_statement'] as String? ?? '',
  agreedToCreatorPolicy: json['agreed_to_creator_policy'] as bool? ?? false,
  submittedByUsername: json['submitted_by_username'] as String?,
  reviewerNotes: json['reviewer_notes'] as String? ?? '',
  rejectionReason: json['rejection_reason'] as String? ?? '',
  reviewedByUsername: json['reviewed_by_username'] as String?,
  reviewedAt: json['reviewed_at'] as String?,
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$PortalShopCertificationToJson(
  _PortalShopCertification instance,
) => <String, dynamic>{
  'id': instance.id,
  'shop': instance.shop,
  'shop_handle': instance.shopHandle,
  'shop_name': instance.shopName,
  'status': instance.status,
  'service_type': instance.serviceType,
  'legal_name': instance.legalName,
  'business_registration_number': instance.businessRegistrationNumber,
  'country': instance.country,
  'phone': instance.phone,
  'id_document_url': instance.idDocumentUrl,
  'professional_cert_url': instance.professionalCertUrl,
  'website_url': instance.websiteUrl,
  'years_of_experience': instance.yearsOfExperience,
  'specializations': instance.specializations,
  'bio_statement': instance.bioStatement,
  'agreed_to_creator_policy': instance.agreedToCreatorPolicy,
  'submitted_by_username': instance.submittedByUsername,
  'reviewer_notes': instance.reviewerNotes,
  'rejection_reason': instance.rejectionReason,
  'reviewed_by_username': instance.reviewedByUsername,
  'reviewed_at': instance.reviewedAt,
  'created_at': instance.createdAt,
};

_PortalOrderItem _$PortalOrderItemFromJson(Map<String, dynamic> json) =>
    _PortalOrderItem(
      id: json['id'] as String?,
      itemType: json['item_type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      fulfillmentStatus: json['fulfillment_status'] as String? ?? '',
      creatorUsername: json['creator_username'] as String?,
      creatorDisplayName: json['creator_display_name'] as String?,
    );

Map<String, dynamic> _$PortalOrderItemToJson(_PortalOrderItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'item_type': instance.itemType,
      'title': instance.title,
      'quantity': instance.quantity,
      'fulfillment_status': instance.fulfillmentStatus,
      'creator_username': instance.creatorUsername,
      'creator_display_name': instance.creatorDisplayName,
    };

_PortalOrderCase _$PortalOrderCaseFromJson(Map<String, dynamic> json) =>
    _PortalOrderCase(
      id: json['id'] as String?,
      order: json['order'] as String?,
      orderNumber: json['order_number'] as String?,
      caseType: json['case_type'] as String? ?? '',
      status: json['status'] as String? ?? 'open',
      reason: json['reason'] as String? ?? '',
      evidence:
          json['evidence'] as Map<String, dynamic>? ??
          const <String, dynamic>{},
      resolution: json['resolution'] as String? ?? '',
      resolvedAt: json['resolved_at'] as String?,
      requesterUsername: json['requester_username'] as String?,
      affectsLedger: json['affects_ledger'] as bool? ?? false,
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$PortalOrderCaseToJson(_PortalOrderCase instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order': instance.order,
      'order_number': instance.orderNumber,
      'case_type': instance.caseType,
      'status': instance.status,
      'reason': instance.reason,
      'evidence': instance.evidence,
      'resolution': instance.resolution,
      'resolved_at': instance.resolvedAt,
      'requester_username': instance.requesterUsername,
      'affects_ledger': instance.affectsLedger,
      'created_at': instance.createdAt,
    };

_PortalOrder _$PortalOrderFromJson(Map<String, dynamic> json) => _PortalOrder(
  id: json['id'] as String,
  orderNumber: json['order_number'] as String? ?? '',
  status: json['status'] as String? ?? '',
  statusLabel: json['status_label'] as String? ?? '',
  allowedNextStatuses:
      (json['allowed_next_statuses'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  fulfillmentType: json['fulfillment_type'] as String? ?? 'digital',
  paymentMethod: json['payment_method'] as String?,
  paymentStatus: json['payment_status'] as String? ?? 'unpaid',
  paymentReference: json['payment_reference'] as String? ?? '',
  paymentProvider: json['payment_provider'] as String? ?? '',
  buyerUsername: json['buyer_username'] as String?,
  buyerDisplayName: json['buyer_display_name'] as String?,
  buyerEmail: json['buyer_email'] as String?,
  deliveryAddress:
      json['delivery_address'] as Map<String, dynamic>? ??
      const <String, dynamic>{},
  pickupDetails:
      json['pickup_details'] as Map<String, dynamic>? ??
      const <String, dynamic>{},
  pickupStation: json['pickup_station'] as String?,
  deliveryPersonnel: json['delivery_personnel'] as String?,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => PortalOrderItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <PortalOrderItem>[],
  itemsTotalArtifacts:
      (json['items_total_artifacts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const <String, int>{},
  discountArtifacts:
      (json['discount_artifacts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const <String, int>{},
  totalArtifacts:
      (json['total_artifacts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const <String, int>{},
  spentUsd: json['spent_usd'] == null
      ? 0.0
      : _optDoubleOrZero(json['spent_usd']),
  statusHistory:
      (json['status_history'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const <Map<String, dynamic>>[],
  cases:
      (json['cases'] as List<dynamic>?)
          ?.map((e) => PortalOrderCase.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <PortalOrderCase>[],
  paidAt: json['paid_at'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$PortalOrderToJson(_PortalOrder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_number': instance.orderNumber,
      'status': instance.status,
      'status_label': instance.statusLabel,
      'allowed_next_statuses': instance.allowedNextStatuses,
      'fulfillment_type': instance.fulfillmentType,
      'payment_method': instance.paymentMethod,
      'payment_status': instance.paymentStatus,
      'payment_reference': instance.paymentReference,
      'payment_provider': instance.paymentProvider,
      'buyer_username': instance.buyerUsername,
      'buyer_display_name': instance.buyerDisplayName,
      'buyer_email': instance.buyerEmail,
      'delivery_address': instance.deliveryAddress,
      'pickup_details': instance.pickupDetails,
      'pickup_station': instance.pickupStation,
      'delivery_personnel': instance.deliveryPersonnel,
      'items': instance.items,
      'items_total_artifacts': instance.itemsTotalArtifacts,
      'discount_artifacts': instance.discountArtifacts,
      'total_artifacts': instance.totalArtifacts,
      'spent_usd': instance.spentUsd,
      'status_history': instance.statusHistory,
      'cases': instance.cases,
      'paid_at': instance.paidAt,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

_PortalGym _$PortalGymFromJson(Map<String, dynamic> json) => _PortalGym(
  id: json['id'] as String,
  name: json['name'] as String?,
  handle: json['handle'] as String?,
  category: json['category'] as String?,
  accessType: json['access_type'] as String?,
  subscriptionType: json['subscription_type'] as String?,
  isVerified: json['is_verified'] as bool? ?? false,
  isDeleted: json['is_deleted'] as bool? ?? false,
  deletedAt: json['deleted_at'] as String?,
  memberCount: (json['member_count'] as num?)?.toInt() ?? 0,
  locationCity: json['location_city'] as String? ?? '',
  locationCountry: json['location_country'] as String? ?? '',
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$PortalGymToJson(_PortalGym instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'handle': instance.handle,
      'category': instance.category,
      'access_type': instance.accessType,
      'subscription_type': instance.subscriptionType,
      'is_verified': instance.isVerified,
      'is_deleted': instance.isDeleted,
      'deleted_at': instance.deletedAt,
      'member_count': instance.memberCount,
      'location_city': instance.locationCity,
      'location_country': instance.locationCountry,
      'created_at': instance.createdAt,
    };

_PortalCommunity _$PortalCommunityFromJson(Map<String, dynamic> json) =>
    _PortalCommunity(
      id: json['id'] as String,
      groupName: json['group_name'] as String? ?? '',
      isGroup: json['is_group'] as bool? ?? false,
      isCommunity: json['is_community'] as bool? ?? false,
      isPublic: json['is_public'] as bool? ?? false,
      origin: json['origin'] as String? ?? '',
      inviteCode: json['invite_code'] as String? ?? '',
      description: json['description'] as String? ?? '',
      gymHandle: json['gym_handle'] as String?,
      createdByUsername: json['created_by_username'] as String?,
      memberCount: (json['member_count'] as num?)?.toInt() ?? 0,
      postCount: (json['post_count'] as num?)?.toInt() ?? 0,
      lastMessageAt: json['last_message_at'] as String?,
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$PortalCommunityToJson(_PortalCommunity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'group_name': instance.groupName,
      'is_group': instance.isGroup,
      'is_community': instance.isCommunity,
      'is_public': instance.isPublic,
      'origin': instance.origin,
      'invite_code': instance.inviteCode,
      'description': instance.description,
      'gym_handle': instance.gymHandle,
      'created_by_username': instance.createdByUsername,
      'member_count': instance.memberCount,
      'post_count': instance.postCount,
      'last_message_at': instance.lastMessageAt,
      'created_at': instance.createdAt,
    };

_PortalStation _$PortalStationFromJson(Map<String, dynamic> json) =>
    _PortalStation(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      country: json['country'] as String? ?? '',
      ownerType: json['owner_type'] as String? ?? '',
      ownerName: json['owner_name'] as String?,
      shop: json['shop'] as String?,
      gym: json['gym'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      isPrimary: json['is_primary'] as bool? ?? false,
      phone: json['phone'] as String?,
      openingHours:
          json['opening_hours'] as Map<String, dynamic>? ??
          const <String, dynamic>{},
      latitude: _optDouble(json['latitude']),
      longitude: _optDouble(json['longitude']),
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$PortalStationToJson(_PortalStation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'address': instance.address,
      'city': instance.city,
      'country': instance.country,
      'owner_type': instance.ownerType,
      'owner_name': instance.ownerName,
      'shop': instance.shop,
      'gym': instance.gym,
      'is_active': instance.isActive,
      'is_primary': instance.isPrimary,
      'phone': instance.phone,
      'opening_hours': instance.openingHours,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'created_at': instance.createdAt,
    };

_PortalStationApplication _$PortalStationApplicationFromJson(
  Map<String, dynamic> json,
) => _PortalStationApplication(
  id: json['id'] as String,
  shop: json['shop'] as String?,
  shopHandle: json['shop_handle'] as String?,
  gym: json['gym'] as String?,
  gymHandle: json['gym_handle'] as String?,
  status: json['status'] as String? ?? 'draft',
  businessRegistrationNumber:
      json['business_registration_number'] as String? ?? '',
  contactPhone: json['contact_phone'] as String? ?? '',
  address: json['address'] as String? ?? '',
  city: json['city'] as String? ?? '',
  country: json['country'] as String? ?? '',
  latitude: _optDouble(json['latitude']),
  longitude: _optDouble(json['longitude']),
  openingHours:
      json['opening_hours'] as Map<String, dynamic>? ??
      const <String, dynamic>{},
  documents:
      (json['documents'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const <Map<String, dynamic>>[],
  agreedToPolicy: json['agreed_to_policy'] as bool? ?? false,
  submittedByUsername: json['submitted_by_username'] as String?,
  reviewerNotes: json['reviewer_notes'] as String? ?? '',
  rejectionReason: json['rejection_reason'] as String? ?? '',
  reviewedByUsername: json['reviewed_by_username'] as String?,
  reviewedAt: json['reviewed_at'] as String?,
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$PortalStationApplicationToJson(
  _PortalStationApplication instance,
) => <String, dynamic>{
  'id': instance.id,
  'shop': instance.shop,
  'shop_handle': instance.shopHandle,
  'gym': instance.gym,
  'gym_handle': instance.gymHandle,
  'status': instance.status,
  'business_registration_number': instance.businessRegistrationNumber,
  'contact_phone': instance.contactPhone,
  'address': instance.address,
  'city': instance.city,
  'country': instance.country,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'opening_hours': instance.openingHours,
  'documents': instance.documents,
  'agreed_to_policy': instance.agreedToPolicy,
  'submitted_by_username': instance.submittedByUsername,
  'reviewer_notes': instance.reviewerNotes,
  'rejection_reason': instance.rejectionReason,
  'reviewed_by_username': instance.reviewedByUsername,
  'reviewed_at': instance.reviewedAt,
  'created_at': instance.createdAt,
};

_PortalDeliveryPersonnel _$PortalDeliveryPersonnelFromJson(
  Map<String, dynamic> json,
) => _PortalDeliveryPersonnel(
  id: json['id'] as String,
  username: json['username'] as String? ?? '',
  displayName: json['display_name'] as String? ?? '',
  email: json['email'] as String?,
  vehicleType: json['vehicle_type'] as String? ?? 'bike',
  serviceZones:
      (json['service_zones'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  isActive: json['is_active'] as bool? ?? true,
  rating: _optDouble(json['rating']),
  bio: json['bio'] as String? ?? '',
  activeOrderCount: (json['active_order_count'] as num?)?.toInt() ?? 0,
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$PortalDeliveryPersonnelToJson(
  _PortalDeliveryPersonnel instance,
) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'display_name': instance.displayName,
  'email': instance.email,
  'vehicle_type': instance.vehicleType,
  'service_zones': instance.serviceZones,
  'is_active': instance.isActive,
  'rating': instance.rating,
  'bio': instance.bio,
  'active_order_count': instance.activeOrderCount,
  'created_at': instance.createdAt,
};

_PortalDeliveryApplication _$PortalDeliveryApplicationFromJson(
  Map<String, dynamic> json,
) => _PortalDeliveryApplication(
  id: json['id'] as String,
  profile: json['profile'] as String?,
  username: json['username'] as String? ?? '',
  displayName: json['display_name'] as String? ?? '',
  vehicleType: json['vehicle_type'] as String? ?? 'bike',
  serviceZones:
      (json['service_zones'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  idDocumentUrl: json['id_document_url'] as String? ?? '',
  licenceDocumentUrl: json['licence_document_url'] as String? ?? '',
  phone: json['phone'] as String? ?? '',
  bio: json['bio'] as String? ?? '',
  status: json['status'] as String? ?? 'draft',
  reviewerNotes: json['reviewer_notes'] as String? ?? '',
  rejectionReason: json['rejection_reason'] as String? ?? '',
  reviewedByUsername: json['reviewed_by_username'] as String?,
  reviewedAt: json['reviewed_at'] as String?,
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$PortalDeliveryApplicationToJson(
  _PortalDeliveryApplication instance,
) => <String, dynamic>{
  'id': instance.id,
  'profile': instance.profile,
  'username': instance.username,
  'display_name': instance.displayName,
  'vehicle_type': instance.vehicleType,
  'service_zones': instance.serviceZones,
  'id_document_url': instance.idDocumentUrl,
  'licence_document_url': instance.licenceDocumentUrl,
  'phone': instance.phone,
  'bio': instance.bio,
  'status': instance.status,
  'reviewer_notes': instance.reviewerNotes,
  'rejection_reason': instance.rejectionReason,
  'reviewed_by_username': instance.reviewedByUsername,
  'reviewed_at': instance.reviewedAt,
  'created_at': instance.createdAt,
};

_PortalTransaction _$PortalTransactionFromJson(Map<String, dynamic> json) =>
    _PortalTransaction(
      id: json['id'] as String,
      txRef: json['tx_ref'] as String? ?? '',
      transactionType: json['transaction_type'] as String? ?? '',
      direction: json['direction'] as String? ?? '',
      status: json['status'] as String? ?? '',
      artifactType: json['artifact_type'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      userUsername: json['user_username'] as String? ?? '',
      userEmail: json['user_email'] as String? ?? '',
      counterpartyUsername: json['counterparty_username'] as String?,
      referenceId: json['reference_id'] as String? ?? '',
      fiatAmount: _optNumText(json['fiat_amount']),
      fiatCurrency: json['fiat_currency'] as String? ?? '',
      paymentProvider: json['payment_provider'] as String? ?? '',
      flutterwaveId: json['flutterwave_id'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      bankAccount: json['bank_account'] as String? ?? '',
      description: json['description'] as String? ?? '',
      journalEntry: json['journal_entry'] as String?,
      clearanceAt: json['clearance_at'] as String?,
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$PortalTransactionToJson(_PortalTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tx_ref': instance.txRef,
      'transaction_type': instance.transactionType,
      'direction': instance.direction,
      'status': instance.status,
      'artifact_type': instance.artifactType,
      'quantity': instance.quantity,
      'user_username': instance.userUsername,
      'user_email': instance.userEmail,
      'counterparty_username': instance.counterpartyUsername,
      'reference_id': instance.referenceId,
      'fiat_amount': instance.fiatAmount,
      'fiat_currency': instance.fiatCurrency,
      'payment_provider': instance.paymentProvider,
      'flutterwave_id': instance.flutterwaveId,
      'phone_number': instance.phoneNumber,
      'bank_account': instance.bankAccount,
      'description': instance.description,
      'journal_entry': instance.journalEntry,
      'clearance_at': instance.clearanceAt,
      'created_at': instance.createdAt,
    };

_PortalReconciliationReport _$PortalReconciliationReportFromJson(
  Map<String, dynamic> json,
) => _PortalReconciliationReport(
  provider:
      json['provider'] as Map<String, dynamic>? ?? const <String, dynamic>{},
  local: json['local'] as Map<String, dynamic>? ?? const <String, dynamic>{},
  windowDays: (json['window_days'] as num?)?.toInt() ?? 30,
  writesLedger: json['writes_ledger'] as bool? ?? false,
);

Map<String, dynamic> _$PortalReconciliationReportToJson(
  _PortalReconciliationReport instance,
) => <String, dynamic>{
  'provider': instance.provider,
  'local': instance.local,
  'window_days': instance.windowDays,
  'writes_ledger': instance.writesLedger,
};

_PortalPagination _$PortalPaginationFromJson(Map<String, dynamic> json) =>
    _PortalPagination(
      count: (json['count'] as num?)?.toInt() ?? 0,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
    );

Map<String, dynamic> _$PortalPaginationToJson(_PortalPagination instance) =>
    <String, dynamic>{
      'count': instance.count,
      'next': instance.next,
      'previous': instance.previous,
    };

_GovernanceUserRef _$GovernanceUserRefFromJson(Map<String, dynamic> json) =>
    _GovernanceUserRef(
      id: json['id'] as String?,
      email: json['email'] as String?,
      displayName: json['display_name'] as String? ?? '',
    );

Map<String, dynamic> _$GovernanceUserRefToJson(_GovernanceUserRef instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'display_name': instance.displayName,
    };

_StaffRole _$StaffRoleFromJson(Map<String, dynamic> json) => _StaffRole(
  id: json['id'] as String?,
  user: json['user'] == null
      ? null
      : GovernanceUserRef.fromJson(json['user'] as Map<String, dynamic>),
  role: json['role'] as String? ?? '',
  roleDisplay: json['role_display'] as String? ?? '',
  scopes:
      (json['scopes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  defaultScopes:
      (json['default_scopes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  effectiveScopes:
      (json['effective_scopes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  grantedBy: json['granted_by'] == null
      ? null
      : GovernanceUserRef.fromJson(json['granted_by'] as Map<String, dynamic>),
  grantedAt: json['granted_at'] as String?,
  notes: json['notes'] as String? ?? '',
  revokedAt: json['revoked_at'] as String?,
  isActive: json['is_active'] as bool? ?? false,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$StaffRoleToJson(_StaffRole instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user': instance.user,
      'role': instance.role,
      'role_display': instance.roleDisplay,
      'scopes': instance.scopes,
      'default_scopes': instance.defaultScopes,
      'effective_scopes': instance.effectiveScopes,
      'granted_by': instance.grantedBy,
      'granted_at': instance.grantedAt,
      'notes': instance.notes,
      'revoked_at': instance.revokedAt,
      'is_active': instance.isActive,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

_AccountActionRequest _$AccountActionRequestFromJson(
  Map<String, dynamic> json,
) => _AccountActionRequest(
  id: json['id'] as String?,
  action: json['action'] as String? ?? '',
  actionDisplay: json['action_display'] as String? ?? '',
  requiredScope: json['required_scope'] as String? ?? '',
  targetUser: json['target_user'] == null
      ? null
      : GovernanceUserRef.fromJson(json['target_user'] as Map<String, dynamic>),
  payload: json['payload'] == null
      ? const <String, dynamic>{}
      : _stringKeyedMapOrEmpty(json['payload']),
  status: json['status'] as String? ?? '',
  isOpen: json['is_open'] as bool? ?? false,
  requestedBy: json['requested_by'] == null
      ? null
      : GovernanceUserRef.fromJson(
          json['requested_by'] as Map<String, dynamic>,
        ),
  requestedByProfile: json['requested_by_profile'] as String? ?? '',
  decidedBy: json['decided_by'] == null
      ? null
      : GovernanceUserRef.fromJson(json['decided_by'] as Map<String, dynamic>),
  decidedAt: json['decided_at'] as String?,
  decisionNote: json['decision_note'] as String? ?? '',
  requiresSecond: json['requires_second'] as bool? ?? true,
  appliedAt: json['applied_at'] as String?,
  effect: const _FlexibleTextConverter().fromJson(json['effect']),
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$AccountActionRequestToJson(
  _AccountActionRequest instance,
) => <String, dynamic>{
  'id': instance.id,
  'action': instance.action,
  'action_display': instance.actionDisplay,
  'required_scope': instance.requiredScope,
  'target_user': instance.targetUser,
  'payload': instance.payload,
  'status': instance.status,
  'is_open': instance.isOpen,
  'requested_by': instance.requestedBy,
  'requested_by_profile': instance.requestedByProfile,
  'decided_by': instance.decidedBy,
  'decided_at': instance.decidedAt,
  'decision_note': instance.decisionNote,
  'requires_second': instance.requiresSecond,
  'applied_at': instance.appliedAt,
  'effect': const _FlexibleTextConverter().toJson(instance.effect),
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

_AdminActionLog _$AdminActionLogFromJson(Map<String, dynamic> json) =>
    _AdminActionLog(
      id: json['id'] as String?,
      actor: json['actor'] as String?,
      actorEmail: json['actor_email'] as String? ?? '',
      action: json['action'] as String? ?? '',
      targetType: json['target_type'] as String? ?? '',
      targetId: json['target_id'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      before: _stringKeyedMap(json['before']),
      after: _stringKeyedMap(json['after']),
      requestId: json['request_id'] as String? ?? '',
      ipAddress: json['ip_address'] as String?,
      userAgent: json['user_agent'] as String? ?? '',
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$AdminActionLogToJson(_AdminActionLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'actor': instance.actor,
      'actor_email': instance.actorEmail,
      'action': instance.action,
      'target_type': instance.targetType,
      'target_id': instance.targetId,
      'summary': instance.summary,
      'before': instance.before,
      'after': instance.after,
      'request_id': instance.requestId,
      'ip_address': instance.ipAddress,
      'user_agent': instance.userAgent,
      'created_at': instance.createdAt,
    };

_EmailLog _$EmailLogFromJson(Map<String, dynamic> json) => _EmailLog(
  id: json['id'] as String?,
  recipientUser: json['recipient_user'] as String?,
  recipient: json['recipient'] == null
      ? null
      : GovernanceUserRef.fromJson(json['recipient'] as Map<String, dynamic>),
  recipientEmail: json['recipient_email'] as String? ?? '',
  subject: json['subject'] as String? ?? '',
  bodyPreview: json['body_preview'] as String? ?? '',
  templateKey: json['template_key'] as String? ?? '',
  sentBy: json['sent_by'] as String?,
  sender: json['sender'] == null
      ? null
      : GovernanceUserRef.fromJson(json['sender'] as Map<String, dynamic>),
  sentByEmail: json['sent_by_email'] as String? ?? '',
  status: json['status'] as String? ?? '',
  error: json['error'] as String? ?? '',
  dedupeKey: json['dedupe_key'] as String? ?? '',
  relatedObjectType: json['related_object_type'] as String? ?? '',
  relatedObjectId: json['related_object_id'] as String? ?? '',
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$EmailLogToJson(_EmailLog instance) => <String, dynamic>{
  'id': instance.id,
  'recipient_user': instance.recipientUser,
  'recipient': instance.recipient,
  'recipient_email': instance.recipientEmail,
  'subject': instance.subject,
  'body_preview': instance.bodyPreview,
  'template_key': instance.templateKey,
  'sent_by': instance.sentBy,
  'sender': instance.sender,
  'sent_by_email': instance.sentByEmail,
  'status': instance.status,
  'error': instance.error,
  'dedupe_key': instance.dedupeKey,
  'related_object_type': instance.relatedObjectType,
  'related_object_id': instance.relatedObjectId,
  'created_at': instance.createdAt,
};

_ContentFlag _$ContentFlagFromJson(Map<String, dynamic> json) => _ContentFlag(
  id: json['id'] as String?,
  flagReason: json['flag_reason'] as String? ?? '',
  severity: json['severity'] as String? ?? '',
  confidence: json['confidence'] == null
      ? 0.0
      : _optDoubleOrZero(json['confidence']),
  source: json['source'] as String? ?? 'auto',
  contentType: json['content_type'] as String? ?? '',
  contentId: json['content_id'] as String? ?? '',
  contentPreview: json['content_preview'] as String? ?? '',
  isActioned: json['is_actioned'] as bool? ?? false,
  actionTaken: json['action_taken'] as String? ?? '',
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$ContentFlagToJson(_ContentFlag instance) =>
    <String, dynamic>{
      'id': instance.id,
      'flag_reason': instance.flagReason,
      'severity': instance.severity,
      'confidence': instance.confidence,
      'source': instance.source,
      'content_type': instance.contentType,
      'content_id': instance.contentId,
      'content_preview': instance.contentPreview,
      'is_actioned': instance.isActioned,
      'action_taken': instance.actionTaken,
      'created_at': instance.createdAt,
    };

_ModerationStats _$ModerationStatsFromJson(Map<String, dynamic> json) =>
    _ModerationStats(
      total: (json['total'] as num?)?.toInt() ?? 0,
      unactioned: (json['unactioned'] as num?)?.toInt() ?? 0,
      actioned: (json['actioned'] as num?)?.toInt() ?? 0,
      bySeverity: json['by_severity'] == null
          ? const <String, dynamic>{}
          : _stringKeyedMapOrEmpty(json['by_severity']),
      byReason: json['by_reason'] == null
          ? const <String, dynamic>{}
          : _stringKeyedMapOrEmpty(json['by_reason']),
    );

Map<String, dynamic> _$ModerationStatsToJson(_ModerationStats instance) =>
    <String, dynamic>{
      'total': instance.total,
      'unactioned': instance.unactioned,
      'actioned': instance.actioned,
      'by_severity': instance.bySeverity,
      'by_reason': instance.byReason,
    };

_ModerationReport _$ModerationReportFromJson(Map<String, dynamic> json) =>
    _ModerationReport(
      id: json['id'] as String?,
      reporter: json['reporter'] as String?,
      targetUser: json['target_user'] as String?,
      reason: json['reason'] as String? ?? '',
      description: json['description'] as String? ?? '',
      contentUrl: json['content_url'] as String? ?? '',
      status: json['status'] as String? ?? '',
      assignedTo: json['assigned_to'] as String?,
      resolvedAt: json['resolved_at'] as String?,
      resolutionNote: json['resolution_note'] as String? ?? '',
      slaDueAt: json['sla_due_at'] as String?,
      slaBreached: json['sla_breached'] as bool? ?? false,
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$ModerationReportToJson(_ModerationReport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reporter': instance.reporter,
      'target_user': instance.targetUser,
      'reason': instance.reason,
      'description': instance.description,
      'content_url': instance.contentUrl,
      'status': instance.status,
      'assigned_to': instance.assignedTo,
      'resolved_at': instance.resolvedAt,
      'resolution_note': instance.resolutionNote,
      'sla_due_at': instance.slaDueAt,
      'sla_breached': instance.slaBreached,
      'created_at': instance.createdAt,
    };

_ModerationAction _$ModerationActionFromJson(Map<String, dynamic> json) =>
    _ModerationAction(
      id: json['id'] as String?,
      action: json['action'] as String? ?? '',
      moderator: json['moderator'] as String?,
      report: json['report'] as String?,
      targetUser: json['target_user'] as String?,
      reason: json['reason'] as String? ?? '',
      durationDays: (json['duration_days'] as num?)?.toInt(),
      contentType: json['content_type'] as String? ?? '',
      contentTypeDisplay: json['content_type_display'] as String? ?? '',
      contentId: json['content_id'] as String? ?? '',
      isReversed: json['is_reversed'] as bool? ?? false,
      reversedBy: json['reversed_by'] as String?,
      reversedAt: json['reversed_at'] as String?,
      reversalReason: json['reversal_reason'] as String? ?? '',
      reversedByModerator: json['reversed_by_moderator'] == null
          ? const <String, dynamic>{}
          : _stringKeyedMapOrEmpty(json['reversed_by_moderator']),
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$ModerationActionToJson(_ModerationAction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'action': instance.action,
      'moderator': instance.moderator,
      'report': instance.report,
      'target_user': instance.targetUser,
      'reason': instance.reason,
      'duration_days': instance.durationDays,
      'content_type': instance.contentType,
      'content_type_display': instance.contentTypeDisplay,
      'content_id': instance.contentId,
      'is_reversed': instance.isReversed,
      'reversed_by': instance.reversedBy,
      'reversed_at': instance.reversedAt,
      'reversal_reason': instance.reversalReason,
      'reversed_by_moderator': instance.reversedByModerator,
      'created_at': instance.createdAt,
    };

_ModerationActionOutcome _$ModerationActionOutcomeFromJson(
  Map<String, dynamic> json,
) => _ModerationActionOutcome(
  moderationAction: json['moderation_action'] == null
      ? null
      : ModerationAction.fromJson(
          json['moderation_action'] as Map<String, dynamic>,
        ),
  approval: json['approval'] == null
      ? null
      : ModerationApprovalStub.fromJson(
          json['approval'] as Map<String, dynamic>,
        ),
  applied: json['applied'] as bool? ?? false,
);

Map<String, dynamic> _$ModerationActionOutcomeToJson(
  _ModerationActionOutcome instance,
) => <String, dynamic>{
  'moderation_action': instance.moderationAction,
  'approval': instance.approval,
  'applied': instance.applied,
};

_ModerationApprovalStub _$ModerationApprovalStubFromJson(
  Map<String, dynamic> json,
) => _ModerationApprovalStub(
  id: json['id'] as String?,
  action: json['action'] as String? ?? '',
  status: json['status'] as String? ?? '',
  requiresSecond: json['requires_second'] as bool? ?? true,
  requestedBy: json['requested_by'] as String?,
);

Map<String, dynamic> _$ModerationApprovalStubToJson(
  _ModerationApprovalStub instance,
) => <String, dynamic>{
  'id': instance.id,
  'action': instance.action,
  'status': instance.status,
  'requires_second': instance.requiresSecond,
  'requested_by': instance.requestedBy,
};

_ModerationReversalOutcome _$ModerationReversalOutcomeFromJson(
  Map<String, dynamic> json,
) => _ModerationReversalOutcome(
  reversedAction: json['reversed_action'] == null
      ? null
      : ModerationAction.fromJson(
          json['reversed_action'] as Map<String, dynamic>,
        ),
  reversal: json['reversal'] == null
      ? null
      : ModerationAction.fromJson(json['reversal'] as Map<String, dynamic>),
  effect: const _FlexibleTextConverter().fromJson(json['effect']),
);

Map<String, dynamic> _$ModerationReversalOutcomeToJson(
  _ModerationReversalOutcome instance,
) => <String, dynamic>{
  'reversed_action': instance.reversedAction,
  'reversal': instance.reversal,
  'effect': const _FlexibleTextConverter().toJson(instance.effect),
};

_ContentFlagOutcome _$ContentFlagOutcomeFromJson(Map<String, dynamic> json) =>
    _ContentFlagOutcome(
      flag: json['flag'] == null
          ? null
          : ContentFlag.fromJson(json['flag'] as Map<String, dynamic>),
      effect: const _FlexibleTextConverter().fromJson(json['effect']),
    );

Map<String, dynamic> _$ContentFlagOutcomeToJson(_ContentFlagOutcome instance) =>
    <String, dynamic>{
      'flag': instance.flag,
      'effect': const _FlexibleTextConverter().toJson(instance.effect),
    };

_ModerationPendingApproval _$ModerationPendingApprovalFromJson(
  Map<String, dynamic> json,
) => _ModerationPendingApproval(
  id: json['id'] as String?,
  governanceAction: json['governance_action'] as String? ?? '',
  targetUser: json['target_user'] as String?,
  requestedBy: json['requested_by'] as String?,
  requestedByProfile: json['requested_by_profile'] as String? ?? '',
  reason: json['reason'] as String? ?? '',
  durationDays: (json['duration_days'] as num?)?.toInt(),
  requiresSecond: json['requires_second'] as bool? ?? true,
  waitingSeconds: (json['waiting_seconds'] as num?)?.toInt() ?? 0,
  createdAt: json['created_at'] as String?,
  moderationActionId: json['moderation_action_id'] as String?,
);

Map<String, dynamic> _$ModerationPendingApprovalToJson(
  _ModerationPendingApproval instance,
) => <String, dynamic>{
  'id': instance.id,
  'governance_action': instance.governanceAction,
  'target_user': instance.targetUser,
  'requested_by': instance.requestedBy,
  'requested_by_profile': instance.requestedByProfile,
  'reason': instance.reason,
  'duration_days': instance.durationDays,
  'requires_second': instance.requiresSecond,
  'waiting_seconds': instance.waitingSeconds,
  'created_at': instance.createdAt,
  'moderation_action_id': instance.moderationActionId,
};

_ModerationAppeal _$ModerationAppealFromJson(Map<String, dynamic> json) =>
    _ModerationAppeal(
      id: json['id'] as String?,
      action: json['action'] as String?,
      appellant: json['appellant'] as String?,
      reason: json['reason'] as String? ?? '',
      status: json['status'] as String? ?? '',
      reviewer: json['reviewer'] as String?,
      reviewedAt: json['reviewed_at'] as String?,
      resolutionNote: json['resolution_note'] as String? ?? '',
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$ModerationAppealToJson(_ModerationAppeal instance) =>
    <String, dynamic>{
      'id': instance.id,
      'action': instance.action,
      'appellant': instance.appellant,
      'reason': instance.reason,
      'status': instance.status,
      'reviewer': instance.reviewer,
      'reviewed_at': instance.reviewedAt,
      'resolution_note': instance.resolutionNote,
      'created_at': instance.createdAt,
    };

_ModerationCommendation _$ModerationCommendationFromJson(
  Map<String, dynamic> json,
) => _ModerationCommendation(
  id: json['id'] as String?,
  recipient: json['recipient'] as String?,
  issuedBy: json['issued_by'] as String?,
  category: json['category'] as String? ?? '',
  categoryDisplay: json['category_display'] as String? ?? '',
  message: json['message'] as String? ?? '',
  visibleToRecipient: json['visible_to_recipient'] as bool? ?? true,
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$ModerationCommendationToJson(
  _ModerationCommendation instance,
) => <String, dynamic>{
  'id': instance.id,
  'recipient': instance.recipient,
  'issued_by': instance.issuedBy,
  'category': instance.category,
  'category_display': instance.categoryDisplay,
  'message': instance.message,
  'visible_to_recipient': instance.visibleToRecipient,
  'created_at': instance.createdAt,
};
