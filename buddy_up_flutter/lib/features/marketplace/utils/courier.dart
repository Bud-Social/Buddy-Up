/// Courier dashboard helpers, mirroring the courier half of
/// `frontend/src/api/marketplace.ts`.
///
/// Three rules shape everything here:
///
///  1. **A 404 from `/delivery/summary/` means "not registered".** The endpoint
///     is scoped to the signed-in courier (`_courier_for` filters
///     `profile=request.user.profile`), so it cannot 404 for a missing id — the
///     only way to get one is to have no `DeliveryPersonnel` row at all. That is
///     a route to the registration wizard, never an empty dashboard.
///  2. **`allowed_transitions` is authoritative.** The buttons a courier sees are
///     built from what the server put on the row. There is deliberately *no*
///     client-side transition map here: a hardcoded copy would drift the moment
///     the backend adds a move, and offering a transition the server rejects is
///     worse than offering none.
///  3. **Earnings are an estimate.** The endpoint sums completed order values
///     times a commission rate. There is no courier ledger and no payout, so the
///     figure must never be presented as money owed.
library;

import '../../../core/api/api_error.dart';
import '../../../data/models/marketplace.dart';

/// USD value of one artifact, matching `ArtifactIcon` / `ArtifactValue` on the
/// web and `_artifactUsdValues` in `marketplace_screen.dart`. An unknown bucket
/// contributes zero rather than guessing a rate.
const Map<String, double> kArtifactUsdValues = {
  'dumbbell': 0.10,
  'barbell': 0.50,
  'burpee': 1.00,
  'squat': 2.50,
  'sprint': 5.00,
  'pr': 10.00,
  'champion': 25.00,
};

/// Convert an artifact map into an approximate USD figure.
///
/// Returns null for a null/empty map so the UI can render a dash — "≈ \$0.00"
/// reads like a real, confirmed zero, which is a different statement.
double? artifactsUsd(Map<String, int>? artifacts) {
  if (artifacts == null || artifacts.isEmpty) return null;
  var total = 0.0;
  artifacts.forEach((type, qty) {
    total += (kArtifactUsdValues[type] ?? 0) * qty;
  });
  return total;
}

/// `delivery_address` is a `JSONField`, but a legacy/imported row can hold a
/// bare string. Both collapse to one line; neither ever yields an empty label.
const String noDeliveryAddressLabel = 'No delivery address on file';

const List<String> _deliveryAddressKeys = [
  'line1',
  'line2',
  'city',
  'postal_code',
  'country',
];

String courierAddressLabel(Map<String, dynamic>? address) {
  if (address == null || address.isEmpty) return noDeliveryAddressLabel;
  final parts = <String>[];
  for (final key in _deliveryAddressKeys) {
    final value = address[key];
    if (value is String && value.trim().isNotEmpty) parts.add(value.trim());
  }
  if (parts.isNotEmpty) return parts.join(', ');
  // No recognised keys: fall back to the first non-empty string value so an
  // address block written with different key names is still shown.
  for (final value in address.values) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
  }
  return noDeliveryAddressLabel;
}

/// `"Pick up: Karura Fitness — Mombasa Road"`, or null when the order has no
/// collection point (a courier delivering door-to-door has nothing to collect).
String? courierPickupLabel(CourierPickupPoint? station) {
  if (station == null) return null;
  final name = station.name.trim();
  final address = station.address.trim();
  if (name.isEmpty && address.isEmpty) return null;
  if (address.isEmpty) return name;
  if (name.isEmpty) return address;
  return '$name — $address';
}

/// The status filters the courier list offers, in lifecycle order.
///
/// The count is read from `summary.counts` when present — the backend zero-fills
/// that map across every `Order.STATUS_CHOICES` value precisely so a dashboard
/// can render a fixed set of tiles.
class CourierStatusFilter {
  final String value;
  final String label;

  const CourierStatusFilter(this.value, this.label);
}

const List<CourierStatusFilter> kCourierStatusFilters = [
  CourierStatusFilter('', 'All'),
  CourierStatusFilter('processing', 'Processing'),
  CourierStatusFilter('shipped', 'Shipped'),
  CourierStatusFilter('out_for_delivery', 'Out for delivery'),
  CourierStatusFilter('delivered', 'Delivered'),
];

/// Count for a filter chip, or null when the server did not report one.
int? courierCountFor(Map<String, int> counts, String status) =>
    status.isEmpty ? null : counts[status];

/// How a courier reads their own order status.
///
/// The raw `status` is the backend's seller-facing vocabulary and does not say
/// what the *courier* should be doing; `fulfillment_status` is the server's
/// own courier-facing mapping (`COURIER_FULFILLMENT_STATUS`), so it is preferred
/// and the raw status is the fallback.
String courierFulfillmentLabel(CourierOrder order) {
  final mapped = order.fulfillmentStatus.trim();
  if (mapped.isNotEmpty && mapped != 'unknown') {
    return courierFulfillmentLabels[mapped] ?? _titleise(mapped);
  }
  return order.statusLabel.trim().isNotEmpty
      ? order.statusLabel
      : _titleise(order.status);
}

/// `COURIER_FULFILLMENT_STATUS` — the server's own mapping from the
/// seller-facing `Order.status` onto the courier's own vocabulary.
const Map<String, String> courierFulfillmentLabels = {
  'awaiting_payment': 'Awaiting payment',
  'awaiting_shop': 'Awaiting the shop',
  'ready_to_collect': 'Ready to collect',
  'out_for_delivery': 'Out for delivery',
  'delivered': 'Delivered',
  'completed': 'Completed',
  'cancelled': 'Cancelled',
};

/// Label for a button that moves this order to [target].
///
/// `delivered` is the one irreversible-feeling move a courier makes, so it gets
/// the affirmative wording; the rollback reads as a reversal. The vocabulary is
/// presentation only — legality comes from `allowedTransitions`.
String courierActionLabel(String target) {
  switch (target) {
    case 'out_for_delivery':
      return 'Start delivery';
    case 'delivered':
      return 'Mark delivered';
    case 'processing':
      return 'Return to processing';
    case 'shipped':
      return 'Mark shipped';
    default:
      return 'Set ${_titleise(target)}';
  }
}

String _titleise(String raw) =>
    raw.replaceAll('_', ' ').split(' ').where((w) => w.isNotEmpty).map((w) {
      return w.substring(0, 1).toUpperCase() + w.substring(1);
    }).join(' ');

/// True when the caller has no courier record — the registration signal.
///
/// Any 404 is treated this way: the endpoint takes no id, so a 404 cannot mean
/// "that courier does not exist", only "you are not one".
bool isCourierNotRegistered(Object error) => apiStatusCode(error) == 404;

/// Statuses in `kCourierStatusFilters`, for the quick filter row.
List<String> courierFilterValues() =>
    kCourierStatusFilters.map((f) => f.value).toList();

/// The estimate disclaimer, shown beside the earnings figure.
///
/// Prefers the server's own `note` so the wording can never drift from
/// `CourierEarningsView.ESTIMATE_NOTICE`; falls back to a local copy that says
/// the same thing.
const String courierEarningsFallbackNote =
    'This is an estimate calculated from your completed orders. It is not a '
    'payable balance — payouts are made from your wallet ledger.';

String courierEarningsNote(CourierEarnings? earnings) {
  final note = earnings?.note.trim() ?? '';
  return note.isEmpty ? courierEarningsFallbackNote : note;
}

/// Commission as a percentage, or an em dash when the server sent none.
String courierCommissionLabel(double? rate) =>
    rate == null ? '—' : '${(rate * 100).toStringAsFixed(1)}%';

/// The window the server says the estimate covers, when it echoed one back.
///
/// Null when it did not, so the caller can omit the line rather than invent a
/// range. Both bounds are echoed precisely so a client never has to guess what
/// it is looking at.
String? earningsWindowLabel(Map<String, dynamic> window) {
  final from = _isoDay(window['from'] ?? window['start']);
  final to = _isoDay(window['to'] ?? window['end']);
  if (from == null && to == null) return null;
  if (from != null && to != null) return '$from → $to';
  return from ?? to;
}

String? _isoDay(Object? raw) {
  if (raw is! String) return null;
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  if (trimmed.length < 10) return trimmed;
  return trimmed.substring(0, 10);
}