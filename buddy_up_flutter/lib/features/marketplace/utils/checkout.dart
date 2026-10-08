/// Client-side rules for the checkout screen, mirroring
/// `frontend/src/pages/app/CheckoutPage.tsx`.
///
/// The two that shape the whole screen:
///
///  1. Only offer a fulfillment type this cart can actually fulfill. Products
///     are the only item type with `delivery_modes`; meal plans, programmes and
///     event tickets are digital by construction, so pickup/delivery are
///     *absent* — not disabled — when nothing physical is in the cart.
///  2. Never destroy the buyer's input on a failure. A rejected checkout (most
///     often `Insufficient <token> tokens.`) leaves every field exactly where it
///     was and renders the server's own wording inline.
library;

import '../../../data/models/marketplace.dart';

const List<String> kFulfillmentValues = ['digital', 'pickup', 'delivery'];

const Map<String, String> kFulfillmentLabels = {
  'digital': 'Digital',
  'pickup': 'Pickup',
  'delivery': 'Delivery',
};

/// Real-money methods. Artifacts (the wallet) never goes through a provider.
const List<String> kProviderPaymentMethods = ['mpesa', 'card'];

const Map<String, String> kPaymentLabels = {
  'artifacts': 'Artifacts (wallet)',
  'mpesa': 'M-Pesa',
  'card': 'Card',
};

/// `"240 dumbbell, 90 protein"` — the canonical artifact rendering used by
/// every total, row and receipt line.
String artifactDisplay(Map<String, dynamic>? artifacts) {
  if (artifacts == null) return '';
  final parts = <String>[];
  artifacts.forEach((type, value) {
    final qty = value is num ? value.toInt() : int.tryParse('$value') ?? 0;
    if (qty > 0) parts.add('$qty $type');
  });
  parts.sort();
  return parts.join(', ');
}

/// Positive-valued entries only — what a balance check should compare against.
Map<String, int> positiveArtifacts(Map<String, dynamic> artifacts) {
  final out = <String, int>{};
  artifacts.forEach((type, value) {
    final qty = value is num ? value.toInt() : int.tryParse('$value') ?? 0;
    if (qty > 0) out[type] = qty;
  });
  return out;
}

/// Fulfillment types this cart can actually fulfill.
///
/// Digital is always possible. Pickup and delivery are added only by a product
/// that lists them in `delivery_modes`, matching the backend's own
/// `_suggested_fulfillment` composition rules. An empty `delivery_modes` on a
/// legacy product stays permissive rather than becoming a checkout block, so
/// such a product contributes nothing.
List<String> availableFulfillmentTypes(List<CartItem> items) {
  final available = <String>{'digital'};
  for (final item in items) {
    if (item.itemType != 'product') continue;
    final modes = item.product?.deliveryModes ?? const <String>[];
    if (modes.isEmpty) continue;
    for (final mode in modes) {
      if (kFulfillmentValues.contains(mode)) available.add(mode);
    }
  }
  return kFulfillmentValues
      .where((value) => available.contains(value))
      .toList();
}

/// True when a physical item is present, which is what unlocks pickup/delivery.
bool hasPhysicalItem(List<CartItem> items) =>
    items.any((item) => item.itemType == 'product');

/// Savings the cart endpoint does not spell out.
///
/// `total_artifacts` is already post-discount while each line's
/// `item_total_artifacts` is not, so the gap between the summed lines and the
/// total is exactly what the discount took off.
Map<String, int> deriveSavings(
  List<CartItem> items,
  Map<String, dynamic> total,
) {
  final original = <String, int>{};
  for (final item in items) {
    item.itemTotalArtifacts.forEach((type, qty) {
      original[type] = (original[type] ?? 0) + qty;
    });
  }
  final savings = <String, int>{};
  original.forEach((type, qty) {
    final paid = total[type] is num
        ? (total[type] as num).toInt()
        : int.tryParse('${total[type]}') ?? 0;
    final delta = qty - paid;
    if (delta > 0) savings[type] = delta;
  });
  return savings;
}

/// `BUY10 — 10% off` / `SAVE — fixed artifact discount` / just the code.
String? discountLabel(DiscountCode? discount) {
  if (discount == null) return null;
  if (discount.discountType == 'percentage' && discount.discountPct > 0) {
    return '${discount.code} — ${discount.discountPct}% off';
  }
  if (discount.discountType == 'fixed_artifacts') {
    return '${discount.code} — fixed artifact discount';
  }
  return discount.code.isEmpty ? null : discount.code;
}

/// 7–15 digits, optionally with a leading +, spaces, dashes or brackets.
final RegExp _phonePattern = RegExp(r'^\+?[0-9][0-9\s().-]{5,18}$');

bool isValidPhone(String value) {
  final trimmed = value.trim();
  if (!_phonePattern.hasMatch(trimmed)) return false;
  final digits = trimmed.replaceAll(RegExp(r'\D'), '');
  return digits.length >= 7 && digits.length <= 15;
}

/// Address keys in the order the form renders them.
const List<String> kAddressFields = [
  'line1', 'line2', 'city', 'postal_code', 'country', 'phone', 'notes',
];

/// Required-field validation for the delivery address. Only `line1`, `city`,
/// `country` and `phone` are mandatory — `line2`, `postal_code` and `notes` are
/// optional and return no error, matching the web form and the backend's
/// `_has_delivery_address`.
Map<String, String> validateAddress(Map<String, String> address) {
  final errors = <String, String>{};
  if ((address['line1'] ?? '').trim().isEmpty) {
    errors['line1'] = 'Enter the street address.';
  }
  if ((address['city'] ?? '').trim().isEmpty) {
    errors['city'] = 'Enter the city.';
  }
  if ((address['country'] ?? '').trim().isEmpty) {
    errors['country'] = 'Enter the country.';
  }
  final phone = (address['phone'] ?? '').trim();
  if (phone.isEmpty) {
    errors['phone'] = 'Enter a phone number for the courier.';
  } else if (!isValidPhone(phone)) {
    errors['phone'] = 'Use 7–15 digits, e.g. +254 712 345 678.';
  }
  return errors;
}

/// Trims and drops the optional blanks so the server stores `''` rather than
/// `"undefined"` — `Order.delivery_address` is a free-form JSON blob that the
/// seller reads verbatim.
Map<String, dynamic> addressPayload(Map<String, String> address) {
  final payload = <String, dynamic>{};
  for (final field in kAddressFields) {
    final value = (address[field] ?? '').trim();
    payload[field] = value;
  }
  return payload;
}

/// Human label for a `payment_status` / intent status, matching the web badge
/// map so the two consoles read the same.
String paymentStatusLabel(String status) {
  switch (status) {
    case 'paid':
    case 'succeeded':
      return 'Paid';
    case 'pending':
    case 'awaiting_confirmation':
    case 'initiated':
      return 'Awaiting provider confirmation';
    case 'failed':
      return 'Failed';
    case 'refunded':
      return 'Refunded';
    default:
      return status.replaceAll('_', ' ');
  }
}

/// `pickup_details` the backend stores on the order and mirrors into the
/// fulfillment timeline.
Map<String, dynamic> pickupDetailsPayload({
  required String? stationName,
  required String manualLocation,
  String? instructions,
}) =>
    {
      if (stationName != null && stationName.isNotEmpty) 'venue': stationName,
      'location': (stationName != null && stationName.isNotEmpty)
          ? stationName
          : manualLocation.trim(),
      'instructions': instructions ?? '',
    };