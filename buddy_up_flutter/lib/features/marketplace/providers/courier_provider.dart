import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_error.dart';
import '../../../data/models/marketplace.dart';
import '../utils/courier.dart';
import 'marketplace_provider.dart';

/// Status filter on the courier order list. Carried as a `String` (not a
/// nullable) so "All" is a real value rather than the absence of one, which
/// keeps it usable as a `family` key.
final courierStatusFilterProvider = NotifierProvider<CourierStatusFilterNotifier, String>(
    CourierStatusFilterNotifier.new);

class CourierStatusFilterNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;
}

/// The courier's own profile + status counts.
///
/// **A 404 here means "you have no `DeliveryPersonnel` row"**, not "no data":
/// the endpoint is scoped to the signed-in rider and takes no id, so a 404 is
/// the only way the server can say "register first". The dashboard reads
/// [isCourierNotRegistered] and routes to the registration wizard instead of
/// rendering an empty shell.
///
/// Any other failure propagates so the screen can show the server's own wording.
final courierProfileProvider = FutureProvider<CourierProfile>((ref) async {
  final raw = await ref.read(marketplaceRepositoryProvider).getCourierSummary();
  return CourierProfile.fromJson(raw['data'] as Map<String, dynamic>);
});

final courierOrdersProvider =
    FutureProvider.family<List<CourierOrder>, String>((ref, status) async {
  final raw = await ref.read(marketplaceRepositoryProvider).getCourierOrders(
        status: status.isEmpty ? null : status,
      );
  final data = raw['data'];
  if (data is! List) return const [];
  return data
      .whereType<Map<String, dynamic>>()
      .map(CourierOrder.fromJson)
      .toList();
});

/// The commission estimate. Degrades to null when the endpoint is absent so the
/// card can be hidden rather than showing a confident zero.
final courierEarningsProvider = FutureProvider<CourierEarnings?>((ref) async {
  try {
    final raw = await ref.read(marketplaceRepositoryProvider).getCourierEarnings();
    return CourierEarnings.fromJson(raw['data'] as Map<String, dynamic>);
  } catch (_) {
    return null;
  }
});

/// Flip the rider's availability.
///
/// `POST /marketplace/delivery-personnel/` doubles as the active-toggle write
/// against an existing row, so the vehicle and zones are echoed back to avoid
/// blanking fields the serializer requires. Returns the server's message.
class CourierAvailabilityResult {
  final bool isActive;
  final String message;

  const CourierAvailabilityResult({required this.isActive, required this.message});
}

final courierAvailabilityProvider =
    Provider<CourierAvailabilityController>((ref) => CourierAvailabilityController(ref));

class CourierAvailabilityController {
  final Ref _ref;

  CourierAvailabilityController(this._ref);

  Future<CourierAvailabilityResult> setActive({
    required bool isActive,
    required CourierProfile profile,
  }) async {
    final raw = await _ref.read(marketplaceRepositoryProvider).saveDeliveryPersonnel({
      'is_active': isActive,
      // Echoed so the write cannot blank the fields a dispatcher reads.
      'vehicle_type': profile.vehicleType.isEmpty ? 'bike' : profile.vehicleType,
      'service_zones': profile.serviceZones,
      if (profile.bio.isNotEmpty) 'bio': profile.bio,
    });
    return CourierAvailabilityResult(
      isActive: isActive,
      message: '${raw['message'] ?? 'Availability updated.'}'.trim(),
    );
  }
}

/// Move one of *this courier's* orders along.
///
/// Legality comes entirely from the server: the caller renders buttons from
/// `allowed_transitions`, and a 400 names the illegal move in its own words, so
/// that message is what the screen shows.
class CourierOrderActions {
  final Ref _ref;

  CourierOrderActions(this._ref);

  /// Returns the server's confirmation message.
  Future<String> setStatus({
    required String orderId,
    required String status,
    String? note,
  }) async {
    final raw = await _ref
        .read(marketplaceRepositoryProvider)
        .updateCourierOrderStatus(orderId, {
      'status': status,
      if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
    });
    return '${raw['message'] ?? 'Order updated.'}'.trim();
  }
}

final courierOrderActionsProvider =
    Provider<CourierOrderActions>(CourierOrderActions.new);

/// Message for a refused status change — the server names the illegal move.
String courierStatusErrorMessage(Object error) =>
    apiErrorMessage(error, fallback: 'That status change was refused.');