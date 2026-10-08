import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../data/models/admin_portal.dart';
import '../../../data/repositories/admin_portal_repository.dart';
import '../../../core/auth/auth_provider.dart';

final adminPortalRepositoryProvider = Provider<AdminPortalRepository>((ref) {
  final dio = ref.watch(apiClientProvider8).dio;
  return AdminPortalRepository(dio);
});

final apiClientProvider8 = Provider<ApiClient>((_) => ApiClient());

/// Staff gate, mirroring the web `AdminGuard`.
///
/// Admin capability on this platform is *only* Django's `is_staff`
/// (`accounts.User`), which every auth endpoint returns. The server re-checks
/// it (`IsAdminUser`) and answers 403 for anyone else, so this is a convenience
/// that hides the console rather than the security boundary.
final isStaffProvider = Provider<bool>(
  (ref) => ref.watch(authProvider).user?.isStaff ?? false,
);

/// Page size for every console list, matching the web console.
const int kPortalPageSize = 25;

/// One page of a `/portal/**` list plus the envelope's real total.
class PortalPage<T> {
  final List<T> items;
  final PortalPagination pagination;

  const PortalPage(this.items, this.pagination);

  int get count => pagination.count;

  int get pageCount {
    final pages = (pagination.count / kPortalPageSize).ceil();
    return pages < 1 ? 1 : pages;
  }
}

/// Immutable list query: a page number plus an already-cleaned filter map.
///
/// Filters travel as a map because the endpoints validate their values and
/// answer a typo with a 400 naming the allowed set — passing them straight
/// through (rather than guessing client-side) is the whole point.
class PortalQuery {
  final int page;
  final Map<String, dynamic> params;

  const PortalQuery({this.page = 1, this.params = const {}});

  /// Drop nulls, blanks and the `'all'` sentinel so the query string stays clean.
  factory PortalQuery.of(
    int page, [
    Map<String, dynamic> filters = const {},
  ]) {
    final clean = <String, dynamic>{};
    filters.forEach((key, value) {
      if (value == null || value == '' || value == 'all') return;
      clean[key] = value;
    });
    return PortalQuery(page: page, params: clean);
  }

  PortalQuery copyWith({int? page, Map<String, dynamic>? params}) =>
      PortalQuery(page: page ?? this.page, params: params ?? this.params);

  String? text(String key) => params[key] as String?;

  bool? flag(String key) => params[key] as bool?;

  /// Stable identity for a Riverpod family — the map has no value equality.
  String get key => jsonEncode({'page': page, 'params': params});

  @override
  bool operator ==(Object other) =>
      other is PortalQuery && other.key == key;

  @override
  int get hashCode => key.hashCode;
}

/// Normalise a list payload. The contract says every list is a bare array, but
/// a paginated shape (`{results: [...]}`) or a null body must not crash a table.
List<Map<String, dynamic>> portalListItems(dynamic data) {
  if (data is List) return data.whereType<Map<String, dynamic>>().toList();
  if (data is Map) {
    final results = data['results'];
    if (results is List) return results.whereType<Map<String, dynamic>>().toList();
    final items = data['items'];
    if (items is List) return items.whereType<Map<String, dynamic>>().toList();
  }
  return [];
}

PortalPagination portalPagination(dynamic raw, int fallbackCount) {
  if (raw is Map<String, dynamic>) {
    return PortalPagination.fromJson(raw);
  }
  return PortalPagination(count: fallbackCount);
}

PortalPage<T> _page<T>(
  List<Map<String, dynamic>> rows,
  dynamic envelope,
  T Function(Map<String, dynamic>) parse,
) =>
    PortalPage(
      rows.map(parse).toList(),
      portalPagination(envelope, rows.length),
    );

// -- Users ------------------------------------------------------------------

final adminUsersProvider =
    FutureProvider.family<PortalPage<PortalUser>, PortalQuery>((ref, q) async {
  final raw = await ref.watch(adminPortalRepositoryProvider).getUsers(
        query: q.text('q'),
        role: q.text('role'),
        isActive: q.flag('is_active'),
        verificationStatus: q.text('verification_status'),
        hasSearchProfile: q.flag('has_search_profile'),
        page: q.page,
        pageSize: kPortalPageSize,
      );
  return _page(portalListItems(raw['data']), raw['pagination'], PortalUser.fromJson);
});

// -- Shops & certifications --------------------------------------------------

final adminShopsProvider =
    FutureProvider.family<PortalPage<PortalShop>, PortalQuery>((ref, q) async {
  final raw = await ref.watch(adminPortalRepositoryProvider).getShops(
        query: q.text('q'),
        verificationStatus: q.text('verification_status'),
        isActive: q.flag('is_active'),
        page: q.page,
        pageSize: kPortalPageSize,
      );
  return _page(portalListItems(raw['data']), raw['pagination'], PortalShop.fromJson);
});

final adminShopCertificationsProvider = FutureProvider.family<
    PortalPage<PortalShopCertification>, PortalQuery>((ref, q) async {
  final raw = await ref
      .watch(adminPortalRepositoryProvider)
      .getShopCertifications(
        status: q.text('status'),
        query: q.text('q'),
        page: q.page,
        pageSize: kPortalPageSize,
      );
  return _page(
      portalListItems(raw['data']), raw['pagination'], PortalShopCertification.fromJson);
});

// -- Orders ------------------------------------------------------------------

final adminOrdersProvider =
    FutureProvider.family<PortalPage<PortalOrder>, PortalQuery>((ref, q) async {
  final raw = await ref.watch(adminPortalRepositoryProvider).getOrders(
        status: q.text('status'),
        fulfillmentType: q.text('fulfillment_type'),
        paymentStatus: q.text('payment_status'),
        paymentMethod: q.text('payment_method'),
        query: q.text('q'),
        page: q.page,
        pageSize: kPortalPageSize,
      );
  return _page(portalListItems(raw['data']), raw['pagination'], PortalOrder.fromJson);
});

// -- Gyms -------------------------------------------------------------------

final adminGymsProvider =
    FutureProvider.family<PortalPage<PortalGym>, PortalQuery>((ref, q) async {
  final raw = await ref.watch(adminPortalRepositoryProvider).getGyms(
        query: q.text('q'),
        category: q.text('category'),
        accessType: q.text('access_type'),
        isVerified: q.flag('is_verified'),
        page: q.page,
        pageSize: kPortalPageSize,
      );
  return _page(portalListItems(raw['data']), raw['pagination'], PortalGym.fromJson);
});

// -- Communities -------------------------------------------------------------

final adminCommunitiesProvider =
    FutureProvider.family<PortalPage<PortalCommunity>, PortalQuery>((ref, q) async {
  final raw = await ref.watch(adminPortalRepositoryProvider).getCommunities(
        query: q.text('q'),
        isPublic: q.flag('is_public'),
        page: q.page,
        pageSize: kPortalPageSize,
      );
  return _page(
      portalListItems(raw['data']), raw['pagination'], PortalCommunity.fromJson);
});

// -- Stations ----------------------------------------------------------------

final adminStationsProvider =
    FutureProvider.family<PortalPage<PortalStation>, PortalQuery>((ref, q) async {
  final raw = await ref.watch(adminPortalRepositoryProvider).getStations(
        query: q.text('q'),
        isActive: q.flag('is_active'),
        isPrimary: q.flag('is_primary'),
        ownerType: q.text('owner_type'),
        city: q.text('city'),
        page: q.page,
        pageSize: kPortalPageSize,
      );
  return _page(portalListItems(raw['data']), raw['pagination'], PortalStation.fromJson);
});

final adminStationApplicationsProvider = FutureProvider.family<
    PortalPage<PortalStationApplication>, PortalQuery>((ref, q) async {
  final raw = await ref
      .watch(adminPortalRepositoryProvider)
      .getStationApplications(
        status: q.text('status'),
        query: q.text('q'),
        page: q.page,
        pageSize: kPortalPageSize,
      );
  return _page(
      portalListItems(raw['data']), raw['pagination'], PortalStationApplication.fromJson);
});

// -- Delivery personnel ------------------------------------------------------

final adminDeliveryProvider =
    FutureProvider.family<PortalPage<PortalDeliveryPersonnel>, PortalQuery>((ref, q) async {
  final raw = await ref.watch(adminPortalRepositoryProvider).getDeliveryPersonnel(
        query: q.text('q'),
        vehicleType: q.text('vehicle_type'),
        isActive: q.flag('is_active'),
        page: q.page,
        pageSize: kPortalPageSize,
      );
  return _page(
      portalListItems(raw['data']), raw['pagination'], PortalDeliveryPersonnel.fromJson);
});

final adminDeliveryApplicationsProvider = FutureProvider.family<
    PortalPage<PortalDeliveryApplication>, PortalQuery>((ref, q) async {
  final raw = await ref
      .watch(adminPortalRepositoryProvider)
      .getDeliveryApplications(
        status: q.text('status'),
        query: q.text('q'),
        page: q.page,
        pageSize: kPortalPageSize,
      );
  return _page(
      portalListItems(raw['data']), raw['pagination'], PortalDeliveryApplication.fromJson);
});

// -- Wallet (read-only) ------------------------------------------------------

final adminTransactionsProvider =
    FutureProvider.family<PortalPage<PortalTransaction>, PortalQuery>((ref, q) async {
  final raw = await ref.watch(adminPortalRepositoryProvider).getTransactions(
        status: q.text('status'),
        transactionType: q.text('transaction_type'),
        direction: q.text('direction'),
        email: q.text('email'),
        query: q.text('q'),
        page: q.page,
        pageSize: kPortalPageSize,
      );
  return _page(
      portalListItems(raw['data']), raw['pagination'], PortalTransaction.fromJson);
});

final adminReconciliationProvider =
    FutureProvider<PortalReconciliationReport>((ref) async {
  final raw = await ref.watch(adminPortalRepositoryProvider).getReconciliation();
  return PortalReconciliationReport.fromJson(
      (raw['data'] ?? <String, dynamic>{}) as Map<String, dynamic>);
});

/// The message a portal envelope carries on success — used to confirm a
/// mutation the same way the web console does ("Application reviewed:
/// approved.").
String portalMessage(dynamic envelope, {String fallback = 'Done.'}) {
  if (envelope is Map && envelope['message'] is String) {
    final message = (envelope['message'] as String).trim();
    if (message.isNotEmpty) return message;
  }
  return fallback;
}