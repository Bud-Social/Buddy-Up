import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_provider.dart';
import '../../features/gym/providers/gym_provider.dart';
import '../../features/marketplace/providers/marketplace_provider.dart';
import '../../features/marketplace/utils/stations.dart';
import 'business_roles.dart';

/// Resolve a probe without letting one failure take down the rest.
///
/// Mirrors the `probe()` helper in `useBusinessRoles`: every call is caught
/// individually so an endpoint that 404s, 405s or is simply not deployed on this
/// server resolves `false`/empty. That is the whole safety property — a
/// half-rolled-out backend can only ever *hide* a nav entry.
Future<T> _probe<T>(Future<T> Function() run, T fallback) async {
  try {
    return await run();
  } catch (_) {
    return fallback;
  }
}

/// List rows out of a body that may be a bare array or a paginated envelope.
///
/// `getOrganisedEvents` returns a bare array today and `getStations` a
/// paginated one; both are legal, and neither should crash a probe.
List<Map<String, dynamic>> _rows(dynamic body) {
  final data = body is Map ? body['data'] : body;
  if (data is List) {
    return data.whereType<Map<String, dynamic>>().toList();
  }
  if (data is Map) {
    final results = data['results'];
    if (results is List) {
      return results.whereType<Map<String, dynamic>>().toList();
    }
  }
  return const [];
}

/// The five role signals, derived from real ownership data.
///
/// `loading` is true until every probe has settled; the nav renders nothing
/// meanwhile so the group does not pop in and out as probes land.
class BusinessRolesNotifier extends AsyncNotifier<BusinessRoleFlags> {
  @override
  Future<BusinessRoleFlags> build() async {
    final auth = ref.watch(authProvider);
    // Signed out: nothing to derive, and probing would 401 on every mount.
    if (!auth.isAuthenticated) {
      return const BusinessRoleFlags(loading: false);
    }
    return _resolve();
  }

  Future<BusinessRoleFlags> _resolve() async {
    final marketplace = ref.read(marketplaceRepositoryProvider);

    final shopIds = await _probe(
      () async => _rows(await marketplace.getMyShops())
          .map((row) => '${row['id'] ?? ''}'.trim())
          .where((id) => id.isNotEmpty)
          .toSet(),
      <String>{},
    );

    // A shop OR any listing ever created both mean "you sell here".
    final hasShop = await _probe(() async {
      if (shopIds.isNotEmpty) return true;
      final row = await marketplace.getMyServices();
      final data = row is Map ? row['data'] : null;
      if (data is! Map) return false;
      const buckets = ['meal_plans', 'programmes', 'events', 'products'];
      return buckets.any((key) {
        final list = data[key];
        return list is List && list.isNotEmpty;
      });
    }, false);

    // A 403 for a non-organiser is the expected answer and reads as "no events".
    final hasEvents = await _probe(() async {
      final rows = _rows(await marketplace.getOrganisedEvents());
      return rows.isNotEmpty;
    }, false);

    // `ownedGymsProvider` already swallows its own failures, but the result is
    // still probed so this derivation reads the same way as the others.
    final ownedGyms = await _probe(
      () async => ref.read(ownedGymsProvider.future),
      const <OwnedGym>[],
    );

    // Ownership is derived from the list response itself — no per-row probe.
    final hasStation = await _probe(() async {
      final rows = stationList((await marketplace.getStations())['data']);
      final owned = deriveOwnedStations(
        rows,
        shopIds: shopIds,
        gymIds: ownedGyms.map((gym) => gym.id).toSet(),
      );
      return owned.isNotEmpty;
    }, false);

    // The delivery summary 404s for anyone without a DeliveryPersonnel row,
    // which is precisely the "not a courier" answer.
    final isCourier = await _probe(() async {
      await marketplace.getCourierSummary();
      return true;
    }, false);

    final gym = ownedGyms.isEmpty ? null : ownedGyms.first;
    return BusinessRoleFlags(
      hasShop: hasShop,
      hasEvents: hasEvents,
      gymSlug: gym?.handle,
      gymName: gym?.name,
      hasStation: hasStation,
      isCourier: isCourier,
      loading: false,
    );
  }

  /// Re-probe without clearing the current value.
  ///
  /// The nav does not want to blink out of existence every time a user finishes
  /// an onboarding step, so the previous flags stay on screen while the new ones
  /// land and are only replaced once every probe has settled.
  Future<void> refresh() async {
    ref.invalidate(ownedGymsProvider);
    state = await AsyncValue.guard(_resolve);
  }
}

final businessRolesProvider =
    AsyncNotifierProvider<BusinessRolesNotifier, BusinessRoleFlags>(
  BusinessRolesNotifier.new,
);

/// The destinations the operator holds, or an empty list while unresolved.
///
/// Returning `[]` rather than the loading state keeps the nav simple: a
/// destination can only ever disappear, never appear without evidence.
final businessEntriesProvider = Provider<List<BusinessEntry>>((ref) {
  final flags = ref.watch(businessRolesProvider).value;
  if (flags == null) return const [];
  return businessEntries(flags);
});