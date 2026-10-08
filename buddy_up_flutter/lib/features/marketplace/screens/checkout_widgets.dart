import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/distance.dart';
import '../../../data/models/marketplace.dart';
import '../../../shared/widgets/input.dart';
import '../utils/checkout.dart';
import '../utils/stations.dart';

/// Shared building blocks for the checkout flow. Flat surfaces, border-tinted
/// cards, `BuddyColors` only — no gradients, no glow.
class CheckoutSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const CheckoutSectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: BuddyColors.green),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: BuddyColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

/// Non-blocking inline note. Used for the shortfall banner, the server's own
/// rejection wording, and the stations-endpoint degradation notice — all three
/// must be readable in place without stealing focus.
class InlineNote extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color color;
  final Color borderColor;

  const InlineNote({
    super.key,
    required this.message,
    required this.icon,
    this.color = BuddyColors.gold,
    this.borderColor = BuddyColors.gold,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 12, color: color, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Order summary ───────────────────────────────────────────────────────────

class OrderSummaryCard extends StatelessWidget {
  final Cart cart;
  final Map<String, int> savings;

  const OrderSummaryCard({
    super.key,
    required this.cart,
    required this.savings,
  });

  static IconData iconFor(String itemType) {
    switch (itemType) {
      case 'meal_plan':
        return Icons.restaurant;
      case 'programme':
        return Icons.fitness_center;
      case 'product':
        return Icons.medication;
      case 'event_ticket':
        return Icons.calendar_month;
      default:
        return Icons.toll;
    }
  }

  static String titleFor(CartItem item) =>
      item.mealPlan?.title ??
      item.programme?.title ??
      item.product?.name ??
      item.event?.title ??
      item.itemType.replaceAll('_', ' ');

  static String imageFor(CartItem item) =>
      item.mealPlan?.coverImageUrl ??
      item.programme?.coverImageUrl ??
      item.product?.imageUrl ??
      item.event?.coverImageUrl ??
      '';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final label = discountLabel(cart.discountCode);
    final savingsLabel = artifactDisplay(savings);
    final totalsLabel = artifactDisplay(cart.totalArtifacts);

    return CheckoutSectionCard(
      icon: Icons.toll,
      title: 'Order summary',
      children: [
        for (final item in cart.items)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Image.network(
                      imageFor(item),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: cs.surfaceContainerHighest,
                        child: Icon(
                          iconFor(item.itemType),
                          size: 18,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titleFor(item),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: BuddyColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '× ${item.quantity}',
                        style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (artifactDisplay(item.itemTotalArtifacts).isNotEmpty)
                      Text(
                        artifactDisplay(item.itemTotalArtifacts),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: BuddyColors.green,
                        ),
                      ),
                    if (item.itemTotalUsd > 0)
                      Text(
                        '${cart.baseCurrency} ${item.itemTotalUsd.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                      ),
                  ],
                ),
              ],
            ),
          ),
        Divider(color: cs.outline.withValues(alpha: 0.15), height: 20),
        if (label != null)
          _SummaryRow(
            label: label,
            value: 'applied at checkout',
            tint: BuddyColors.green,
          ),
        if (savingsLabel.isNotEmpty)
          _SummaryRow(
            label: 'You save',
            value: '-$savingsLabel',
            tint: BuddyColors.green,
          ),
        _SummaryRow(
          label: 'Total in artifacts',
          value: totalsLabel.isEmpty ? 'Free' : totalsLabel,
          valueColor: BuddyColors.green,
          bold: true,
        ),
        _SummaryRow(
          label: 'Total (${cart.baseCurrency})',
          value: '${cart.baseCurrency} ${cart.totalUsd.toStringAsFixed(2)}',
          bold: true,
        ),
        if (cart.conversionRate > 0)
          _SummaryRow(
            label: 'Total (${cart.localCurrency})',
            value:
                '${cart.localCurrency} ${cart.totalLocalCurrency.toStringAsFixed(2)}',
            bold: true,
          ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? tint;
  final Color? valueColor;
  final bool bold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.tint,
    this.valueColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final style = TextStyle(
      fontSize: bold ? 14 : 12,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      color: tint ?? cs.onSurfaceVariant,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: style)),
          const SizedBox(width: 12),
          Text(
            value,
            textAlign: TextAlign.right,
            style: style.copyWith(
              color: valueColor ?? cs.onSurface,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Fulfillment ─────────────────────────────────────────────────────────────

class FulfillmentCard extends StatelessWidget {
  final List<String> availableTypes;
  final String selected;
  final bool physical;
  final String? suggestedType;
  final ValueChanged<String> onSelect;
  final List<Widget> children;

  const FulfillmentCard({
    super.key,
    required this.availableTypes,
    required this.selected,
    required this.physical,
    required this.suggestedType,
    required this.onSelect,
    required this.children,
  });

  static const Map<String, ({IconData icon, String label, String hint})>
      _options = {
    'digital': (
      icon: Icons.check_circle_outline,
      label: 'Digital',
      hint: 'Unlocked instantly'
    ),
    'pickup': (
      icon: Icons.store_outlined,
      label: 'Pickup',
      hint: 'Collect in person'
    ),
    'delivery': (
      icon: Icons.local_shipping_outlined,
      label: 'Delivery',
      hint: 'Shipped to you'
    ),
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CheckoutSectionCard(
      icon: Icons.local_shipping_outlined,
      title: 'How you get it',
      children: [
        Row(
          children: [
            for (final type in availableTypes) ...[
              Expanded(
                child: _FulfillmentOption(
                  icon: _options[type]!.icon,
                  label: _options[type]!.label,
                  hint: _options[type]!.hint,
                  selected: selected == type,
                  onTap: () => onSelect(type),
                ),
              ),
              if (type != availableTypes.last) const SizedBox(width: 8),
            ],
          ],
        ),
        if (!physical) ...[
          const SizedBox(height: 10),
          Text(
            'Meal plans, programmes and event tickets are delivered digitally, so '
            'pickup and delivery are not offered for this cart.',
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant, height: 1.35),
          ),
        ],
        if (suggestedType != null && suggestedType == selected) ...[
          const SizedBox(height: 10),
          Text(
            'Auto-detected: $suggestedType delivery.',
            style: const TextStyle(fontSize: 12, color: BuddyColors.green),
          ),
        ],
        ...children,
      ],
    );
  }
}

class _FulfillmentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  final bool selected;
  final VoidCallback onTap;

  const _FulfillmentOption({
    required this.icon,
    required this.label,
    required this.hint,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tint = selected ? BuddyColors.green : cs.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? BuddyColors.green : cs.outline.withValues(alpha: 0.2),
          ),
          color:
              selected ? BuddyColors.green.withValues(alpha: 0.1) : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: tint),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: tint,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              hint,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Delivery address ────────────────────────────────────────────────────────

/// Structured address form with client-side validation.
///
/// The controllers live here, not in the parent, so the parent can rebuild on
/// every keystroke (to reveal an error) without ever resetting a half-typed
/// line — the "never lose the buyer's input" rule, enforced structurally rather
/// than by remembering to restore it.
class DeliveryAddressForm extends StatefulWidget {
  final Map<String, String> address;
  final String? Function(String field) errorFor;
  final void Function(String field, String value) onChanged;
  final void Function(String field) onTouched;

  const DeliveryAddressForm({
    super.key,
    required this.address,
    required this.errorFor,
    required this.onChanged,
    required this.onTouched,
  });

  @override
  State<DeliveryAddressForm> createState() => _DeliveryAddressFormState();
}

class _DeliveryAddressFormState extends State<DeliveryAddressForm> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (final field in kAddressFields) {
      _controllers[field] = TextEditingController(text: widget.address[field] ?? '');
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, size: 12, color: BuddyColors.green),
              const SizedBox(width: 6),
              Text(
                'Delivery address',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _field('line1', 'Address line 1', 'Mombasa Road, Westlands'),
          const SizedBox(height: 10),
          _field(
            'line2',
            'Address line 2',
            'Apartment, floor or landmark (optional)',
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _field('city', 'City', 'Nairobi')),
              const SizedBox(width: 10),
              Expanded(child: _field('postal_code', 'Postal code', 'Optional')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _field('country', 'Country', 'Kenya')),
              const SizedBox(width: 10),
              Expanded(
                child: _field(
                  'phone',
                  'Phone',
                  '+254 712 345 678',
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _field('notes', 'Notes', 'Gate code, best time to drop off (optional)'),
        ],
      ),
    );
  }

  Widget _field(
    String field,
    String label,
    String hint, {
    TextInputType? keyboardType,
  }) {
    return BuddyInput(
      label: label,
      hint: hint,
      controller: _controllers[field],
      error: widget.errorFor(field),
      keyboardType: keyboardType ?? TextInputType.text,
      onChanged: (value) {
        widget.onTouched(field);
        widget.onChanged(field, value);
      },
    );
  }
}

// ─── Station picker ───────────────────────────────────────────────────────────

/// The pickup-station picker.
///
/// Nearest-first when the buyer shared a location; a search box plus the
/// free-text collection-point field when they did not (or when the endpoint is
/// absent entirely). Owns its own query/collection controllers so a parent
/// rebuild — which happens on every keystroke and on every station reload — does
/// not wipe the field being typed into.
class StationPickerSection extends StatefulWidget {
  final AsyncValue<List<PickupStation>>? async;
  final bool located;
  final bool locating;
  final bool unavailable;
  final String? error;
  final String query;
  final String manualLocation;
  final String? selectedId;
  final String? selectionError;
  final String? manualError;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onManualChanged;
  final ValueChanged<String> onSelect;
  final VoidCallback onUseLocation;

  const StationPickerSection({
    super.key,
    required this.async,
    required this.located,
    required this.locating,
    required this.unavailable,
    required this.error,
    required this.query,
    required this.manualLocation,
    required this.selectedId,
    required this.selectionError,
    required this.manualError,
    required this.onQueryChanged,
    required this.onManualChanged,
    required this.onSelect,
    required this.onUseLocation,
  });

  @override
  State<StationPickerSection> createState() => _StationPickerSectionState();
}

class _StationPickerSectionState extends State<StationPickerSection> {
  final TextEditingController _queryController = TextEditingController();
  final TextEditingController _manualController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _queryController.text = widget.query;
    _manualController.text = widget.manualLocation;
  }

  @override
  void didUpdateWidget(covariant StationPickerSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The cart endpoint seeds the collection point from its own suggestion; only
    // adopt a new seed when the buyer has not typed anything.
    if (widget.manualLocation.isNotEmpty &&
        widget.manualLocation != oldWidget.manualLocation &&
        _manualController.text.isEmpty) {
      _manualController.text = widget.manualLocation;
    }
  }

  @override
  void dispose() {
    _queryController.dispose();
    _manualController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final value = widget.async;
    final loading = value?.isLoading ?? false;
    final stations = value?.value ?? const <PickupStation>[];
    final visible = filterStations(stations, widget.query);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.store, size: 12, color: BuddyColors.green),
              const SizedBox(width: 6),
              const Text(
                'Pickup station',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              if (!widget.located)
                TextButton.icon(
                  onPressed: widget.locating ? null : widget.onUseLocation,
                  icon: Icon(
                    Icons.navigation,
                    size: 12,
                    color: widget.locating ? cs.onSurfaceVariant : BuddyColors.green,
                  ),
                  label: Text(
                    widget.locating ? 'Locating…' : 'Use my location',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          widget.locating ? cs.onSurfaceVariant : BuddyColors.green,
                    ),
                  ),
                ),
            ],
          ),
          if (!widget.located && !loading) ...[
            const SizedBox(height: 8),
            Text(
              'No location shared, so stations are not ranked by distance — search '
              'by name or area instead.',
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant, height: 1.35),
            ),
          ],
          if (!widget.located && !loading && stations.isNotEmpty) ...[
            const SizedBox(height: 10),
            BuddyInput(
              label: 'Search stations',
              hint: 'Search by name or area',
              controller: _queryController,
              onChanged: widget.onQueryChanged,
            ),
          ],
          if (loading) ...[
            const SizedBox(height: 10),
            for (var i = 0; i < 2; i++)
              Container(
                height: 56,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
          ],
          if (!loading && stations.isNotEmpty && visible.isEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'No station matches "${widget.query.trim()}".',
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
          ],
          if (!loading)
            for (var i = 0; i < visible.length; i++)
              _StationRow(
                station: visible[i],
                isNearest: i == 0 && hasStationDistance(visible[i]),
                selected: visible[i].id == widget.selectedId,
                onTap: () => widget.onSelect(visible[i].id),
              ),
          if (widget.selectionError != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.selectionError!,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: BuddyColors.red,
              ),
            ),
          ],
          if (!loading && stations.isEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  widget.unavailable
                      ? 'Station picking is unavailable right now, so tell us where '
                          'to hand the order over.'
                      : 'No pickup stations are listed yet, so tell us where to hand '
                          'the order over.',
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
                if (widget.error != null) ...[
                  const SizedBox(height: 8),
                  InlineNote(message: widget.error!, icon: Icons.error_outline),
                ],
                const SizedBox(height: 10),
                BuddyInput(
                  label: 'Collection point',
                  hint: 'e.g. Karura Fitness, Westlands',
                  controller: _manualController,
                  error: widget.manualError,
                  onChanged: widget.onManualChanged,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _StationRow extends StatelessWidget {
  final PickupStation station;
  final bool isNearest;
  final bool selected;
  final VoidCallback onTap;

  const _StationRow({
    required this.station,
    required this.isNearest,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final distance = formatDistanceBadge(station.distanceKm);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? BuddyColors.green : cs.outline.withValues(alpha: 0.2),
          ),
          color:
              selected ? BuddyColors.green.withValues(alpha: 0.1) : Colors.transparent,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                size: 16,
                color: selected ? BuddyColors.green : cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          station.name.isEmpty ? 'Pickup station' : station.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: BuddyColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (station.isPrimary) ...[
                        const SizedBox(width: 6),
                        const MiniBadge(label: 'Primary', color: BuddyColors.gold),
                      ],
                      if (isNearest) ...[
                        const SizedBox(width: 6),
                        const MiniBadge(label: 'Nearest', color: BuddyColors.green),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stationAreaLabel(station),
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                  Text(
                    stationOpeningHoursLabel(station.openingHours),
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                  if (distance != null)
                    Text(
                      distance,
                      style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MiniBadge extends StatelessWidget {
  final String label;
  final Color color;

  const MiniBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

// ─── Payment ─────────────────────────────────────────────────────────────────

class PaymentCard extends StatelessWidget {
  final Map<String, bool> enabled;
  final String? selected;
  final Map<String, dynamic> totals;
  final Map<String, int> regular;
  final String? shortfallType;
  final int? shortfallNeeded;
  final int shortfallHave;
  final TextEditingController mpesaController;
  final String? mpesaError;
  final ValueChanged<String> onSelect;
  final VoidCallback onPhoneChanged;

  const PaymentCard({
    super.key,
    required this.enabled,
    required this.selected,
    required this.totals,
    required this.regular,
    required this.shortfallType,
    required this.shortfallNeeded,
    required this.shortfallHave,
    required this.mpesaController,
    required this.mpesaError,
    required this.onSelect,
    required this.onPhoneChanged,
  });

  static const Map<String, ({IconData icon, String label, String note})>
      _options = {
    'artifacts': (
      icon: Icons.account_balance_wallet_outlined,
      label: 'Artifacts',
      note: 'Deducts from your wallet instantly.',
    ),
    'mpesa': (
      icon: Icons.smartphone,
      label: 'M-Pesa',
      note: 'Confirm the prompt on your phone first.',
    ),
    'card': (
      icon: Icons.credit_card,
      label: 'Card',
      note: 'Confirmed by the card provider.',
    ),
  };

  int _afterPurchase(String type) {
    final have = regular[type] ?? 0;
    final cost = totals[type] is num
        ? (totals[type] as num).toInt()
        : int.tryParse('${totals[type]}') ?? 0;
    final left = have - cost;
    return left < 0 ? 0 : left;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CheckoutSectionCard(
      icon: Icons.account_balance_wallet_outlined,
      title: 'How you pay',
      children: [
        Text(
          'Artifacts leave your wallet the moment the order is placed. M-Pesa and '
          'Card are only marked paid once the provider confirms them.',
          style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant, height: 1.35),
        ),
        const SizedBox(height: 12),
        for (final entry in _options.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _PaymentOption(
              icon: entry.value.icon,
              label: entry.value.label,
              note: entry.value.note,
              enabled: enabled[entry.key] ?? true,
              selected: selected == entry.key,
              badge: entry.key == 'artifacts'
                  ? (selected == entry.key ? 'Instant' : null)
                  : (selected == entry.key ? 'Needs confirmation' : null),
              shortfall: entry.key == 'artifacts' &&
                      enabled[entry.key] == false &&
                      shortfallType != null
                  ? 'This order needs $shortfallNeeded $shortfallType, you have '
                      '$shortfallHave.'
                  : null,
              balances: entry.key == 'artifacts' && enabled[entry.key] == true
                  ? [
                      for (final line in positiveArtifacts(totals).keys)
                        'Balance ${regular[line] ?? 0} $line · '
                            '${_afterPurchase(line)} after this order',
                    ]
                  : const [],
              onTap: () => onSelect(entry.key),
            ),
          ),
        if (selected == 'mpesa') ...[
          const SizedBox(height: 6),
          BuddyInput(
            label: 'M-Pesa phone',
            hint: '0712 345 678',
            controller: mpesaController,
            error: mpesaError,
            keyboardType: TextInputType.phone,
            onChanged: (_) => onPhoneChanged(),
          ),
        ],
      ],
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String note;
  final bool enabled;
  final bool selected;
  final String? badge;
  final String? shortfall;
  final List<String> balances;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.icon,
    required this.label,
    required this.note,
    required this.enabled,
    required this.selected,
    required this.badge,
    required this.shortfall,
    required this.balances,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tint = selected
        ? BuddyColors.green
        : (enabled ? cs.onSurfaceVariant : cs.onSurface.withValues(alpha: 0.35));
    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? BuddyColors.green
                  : cs.outline.withValues(alpha: enabled ? 0.2 : 0.1),
            ),
            color:
                selected ? BuddyColors.green.withValues(alpha: 0.1) : Colors.transparent,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(icon, size: 16, color: tint),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            label,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: BuddyColors.textPrimary,
                            ),
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 6),
                          MiniBadge(
                            label: badge!,
                            color: label == 'Artifacts'
                                ? BuddyColors.green
                                : BuddyColors.gold,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      note,
                      style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                    ),
                    if (shortfall != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        shortfall!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: BuddyColors.red,
                        ),
                      ),
                    ],
                    for (final line in balances)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          line,
                          style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}