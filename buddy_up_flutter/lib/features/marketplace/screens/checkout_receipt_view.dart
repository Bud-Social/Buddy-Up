import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/marketplace.dart';
import '../../../shared/widgets/button.dart';
import '../utils/checkout.dart';
import 'checkout_widgets.dart';

/// The post-checkout receipt, rendered on the checkout screen itself.
///
/// It is deliberately not a toast or a dialog: for a real-money order the
/// payment may still be pending, so the buyer needs to be able to read what was
/// ordered, what was charged and what happens next, and to retry the provider
/// leg from the order page if it failed.
class CheckoutReceiptView extends ConsumerWidget {
  final CheckoutReceipt receipt;
  final String baseCurrency;
  final String localCurrency;
  final double conversionRate;
  final String paymentMethod;
  final String fulfillmentType;
  final PaymentIntentResult? paymentIntent;
  final String? intentNote;
  final String? stationName;
  final String manualPickup;
  final Map<String, String>? address;
  final VoidCallback onViewOrder;
  final VoidCallback onBackToMarketplace;

  const CheckoutReceiptView({
    super.key,
    required this.receipt,
    required this.baseCurrency,
    required this.localCurrency,
    required this.conversionRate,
    required this.paymentMethod,
    required this.fulfillmentType,
    required this.paymentIntent,
    required this.intentNote,
    required this.stationName,
    required this.manualPickup,
    required this.address,
    required this.onViewOrder,
    required this.onBackToMarketplace,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final status = receipt.paymentStatus ??
        (paymentMethod == 'artifacts' ? 'paid' : 'pending');
    final orderLabel = receipt.orderNumber.isNotEmpty
        ? receipt.orderNumber
        : _shortId(receipt.orderId);
    final spentUsd =
        receipt.spentUsd > 0 ? receipt.spentUsd : 0.0;
    final spentLocal = spentUsd * conversionRate;
    final collectingFrom =
        (stationName?.isNotEmpty ?? false) ? stationName! : manualPickup;
    final totalsLabel = artifactDisplay(receipt.totalArtifacts);
    final originalLabel = artifactDisplay(receipt.originalArtifacts);
    final savingsLabel = artifactDisplay(receipt.savingsArtifacts);
    final balanceLabel = artifactDisplay(receipt.newBalance);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        CheckoutSectionCard(
          icon: Icons.check_circle,
          title: 'Order placed',
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: BuddyColors.green, size: 44),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Order #$orderLabel',
                style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _FactBox(
                    caption: 'Paid with',
                    value: kPaymentLabels[paymentMethod] ?? paymentMethod,
                    badge: MiniBadge(
                      label: paymentStatusLabel(status),
                      color: _statusColor(status),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _FactBox(
                    caption: 'Fulfillment',
                    value: kFulfillmentLabels[fulfillmentType] ??
                        fulfillmentType,
                    subtitle: 'Status: '
                        '${receipt.status.isEmpty ? 'paid' : receipt.status}',
                  ),
                ),
              ],
            ),
            if (fulfillmentType == 'pickup') ...[
              const SizedBox(height: 10),
              _FactBox(
                caption: 'Collecting from',
                value: collectingFrom.isEmpty ? 'Pickup station' : collectingFrom,
              ),
            ],
            if (fulfillmentType == 'delivery' && address != null) ...[
              const SizedBox(height: 10),
              _FactBox(
                caption: 'Delivering to',
                value: [
                  address!['line1'] ?? '',
                  address!['line2'] ?? '',
                ].where((v) => v.trim().isNotEmpty).join(', '),
                subtitle: [
                  address!['city'] ?? '',
                  address!['postal_code'] ?? '',
                  address!['country'] ?? '',
                ].where((v) => v.trim().isNotEmpty).join(', '),
                footer: [
                  if ((address!['phone'] ?? '').trim().isNotEmpty)
                    (address!['phone'] ?? '').trim(),
                  if ((address!['notes'] ?? '').trim().isNotEmpty)
                    (address!['notes'] ?? '').trim(),
                ].join('\n'),
              ),
            ],
            if (paymentMethod != 'artifacts') ...[
              const SizedBox(height: 10),
              InlineNote(
                message: _pendingMessage(paymentMethod, status),
                icon: Icons.schedule,
                color: BuddyColors.gold,
              ),
              if (paymentIntent?.intent?.providerReference?.isNotEmpty ?? false)
                _MiniLine('Reference: ${paymentIntent!.intent!.providerReference}'),
              if (paymentIntent?.intent?.status != null)
                _MiniLine(
                  'Provider status: '
                  '${paymentIntent!.intent!.status!.replaceAll('_', ' ')}',
                ),
              if (paymentIntent?.railConfigured == false)
                const _MiniLine(
                  'No payment provider is configured on this deployment, so no '
                  'charge was started. Pay with artifacts instead.',
                ),
              if (intentNote != null && intentNote!.isNotEmpty)
                InlineNote(message: intentNote!, icon: Icons.error_outline,
                    color: BuddyColors.red, borderColor: BuddyColors.red),
            ],
            if (receipt.items.isNotEmpty) ...[
              const SizedBox(height: 14),
              Divider(color: cs.outline.withValues(alpha: 0.15), height: 1),
              const SizedBox(height: 12),
              for (final item in receipt.items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${item.title} × ${item.quantity}',
                          style: const TextStyle(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        artifactDisplay(
                              item.paidArtifacts.isNotEmpty
                                  ? item.paidArtifacts
                                  : item.totalArtifacts,
                            )
                            .isEmpty
                            ? artifactDisplay(item.priceArtifacts)
                            : artifactDisplay(
                                item.paidArtifacts.isNotEmpty
                                    ? item.paidArtifacts
                                    : item.totalArtifacts,
                              ),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            const SizedBox(height: 12),
            Divider(color: cs.outline.withValues(alpha: 0.15), height: 1),
            const SizedBox(height: 12),
            if (originalLabel.isNotEmpty)
              _ReceiptRow(label: 'Original total', value: originalLabel),
            if (savingsLabel.isNotEmpty)
              _ReceiptRow(
                label: receipt.discountCode != null
                    ? 'Savings (${receipt.discountCode})'
                    : 'Savings',
                value: '-$savingsLabel',
                tint: BuddyColors.green,
              ),
            _ReceiptRow(
              label: 'You paid',
              value: totalsLabel.isEmpty ? 'Free' : totalsLabel,
              tint: BuddyColors.green,
              bold: true,
            ),
            _ReceiptRow(
              label: 'Value ($baseCurrency)',
              value: '$baseCurrency ${spentUsd.toStringAsFixed(2)}',
            ),
            if (conversionRate > 0)
              _ReceiptRow(
                label: 'Value ($localCurrency)',
                value: '$localCurrency ${spentLocal.toStringAsFixed(2)}',
              ),
            if (balanceLabel.isNotEmpty)
              _ReceiptRow(
                label: 'Remaining balance',
                value: balanceLabel,
              ),
            const SizedBox(height: 16),
            BuddyButton(
              label: 'View Order',
              fullWidth: true,
              onPressed: onViewOrder,
            ),
            const SizedBox(height: 8),
            BuddyButton(
              label: 'Back to Marketplace',
              variant: BuddyButtonVariant.ghost,
              fullWidth: true,
              onPressed: () {
                context.pop();
                onBackToMarketplace();
              },
            ),
          ],
        ),
      ],
    );
  }

  static String _pendingMessage(String method, String status) {
    final lowered = paymentStatusLabel(status).toLowerCase();
    final lead = method == 'mpesa'
        ? 'Approve the M-Pesa prompt on your phone to settle this order.'
        : 'Your card provider still needs to confirm this payment.';
    return '$lead The order stays $lowered until they do.';
  }

  static Color _statusColor(String status) {
    switch (status) {
      case 'paid':
      case 'succeeded':
        return BuddyColors.green;
      case 'pending':
      case 'awaiting_confirmation':
      case 'initiated':
        return BuddyColors.gold;
      case 'failed':
        return BuddyColors.red;
      case 'refunded':
        return BuddyColors.textSecondary;
      default:
        return BuddyColors.textSecondary;
    }
  }

  static String _shortId(String id) =>
      id.length > 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase();
}

class _FactBox extends StatelessWidget {
  final String caption;
  final String value;
  final String? subtitle;
  final String? footer;
  final Widget? badge;

  const _FactBox({
    required this.caption,
    required this.value,
    this.subtitle,
    this.footer,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            caption,
            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 2),
          Text(
            value.isEmpty ? '—' : value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: BuddyColors.textPrimary,
            ),
          ),
          if (badge != null) ...[const SizedBox(height: 6), badge!],
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
            ),
          ],
          if (footer != null && footer!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              footer!,
              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? tint;
  final bool bold;

  const _ReceiptRow({
    required this.label,
    required this.value,
    this.tint,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: bold ? 15 : 12,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                color: tint ?? cs.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: bold ? 15 : 12,
              fontWeight: FontWeight.w700,
              color: tint ?? cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniLine extends StatelessWidget {
  final String text;

  const _MiniLine(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
