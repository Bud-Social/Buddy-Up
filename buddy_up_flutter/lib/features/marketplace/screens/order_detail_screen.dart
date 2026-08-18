import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/marketplace_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/page_loader.dart';
import '../../../data/models/marketplace.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));
    return Scaffold(
      appBar: AppBar(title: const Text('Order Tracking')),
      body: orderAsync.when(
        data: (order) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _statusBanner(order),
            const SizedBox(height: 12),
            _fulfillmentCard(order),
            const SizedBox(height: 12),
            _itemsCard(order),
            if (order.statusHistory.isNotEmpty) ...[
              const SizedBox(height: 12),
              _timelineCard(order),
            ],
          ],
        ),
        loading: () => const PageLoader(),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }

  Widget _statusBanner(Order order) {
    final color = _statusColor(order.status);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BuddyColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.check_circle, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.statusLabel.isNotEmpty
                      ? order.statusLabel
                      : order.status.replaceAll('_', ' '),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  'Order ${order.orderNumber}',
                  style: const TextStyle(
                      fontSize: 12, color: BuddyColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fulfillmentCard(Order order) {
    final f = order.fulfillment;
    final fulfillmentLabel =
        order.fulfillmentType.replaceAll('_', ' ').toUpperCase();
    return _sectionCard([
      const Text('Fulfillment',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(fulfillmentLabel,
              style: const TextStyle(
                  fontSize: 12, color: BuddyColors.textSecondary)),
          if (f != null && f.carrier.isNotEmpty)
            Text(f.carrier,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
      if (f != null && f.pickupLocation.isNotEmpty) ...[
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.store,
                size: 13, color: BuddyColors.textSecondary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(f.pickupLocation,
                  style: const TextStyle(
                      fontSize: 12, color: BuddyColors.textSecondary)),
            ),
          ],
        ),
      ],
      if (f != null && f.trackingNumber.isNotEmpty) ...[
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.local_shipping,
                size: 13, color: BuddyColors.textSecondary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Tracking: ${f.trackingNumber}',
                style: const TextStyle(
                    fontSize: 12, color: BuddyColors.textSecondary),
              ),
            ),
          ],
        ),
      ],
      if (order.deliveryAddress.isNotEmpty) ...[
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.location_on,
                size: 13, color: BuddyColors.textSecondary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                order.deliveryAddress.values
                    .where((v) => v != null && '$v'.isNotEmpty)
                    .map((v) => '$v')
                    .join(', '),
                style: const TextStyle(
                    fontSize: 12, color: BuddyColors.textSecondary),
              ),
            ),
          ],
        ),
      ],
    ]);
  }

  Widget _itemsCard(Order order) {
    return _sectionCard([
      const Text('Items',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      const SizedBox(height: 8),
      ...order.items.map(
        (it) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${it.title} × ${it.quantity}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    Text(
                      '${it.itemType.replaceAll('_', ' ')}${it.creatorName != null && it.creatorName!.isNotEmpty ? ' · by ${it.creatorName}' : ''}',
                      style: const TextStyle(
                          fontSize: 12, color: BuddyColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Text(
                _artifactDisplay(it.paidArtifacts).isNotEmpty
                    ? _artifactDisplay(it.paidArtifacts)
                    : '-',
                style: const TextStyle(
                    color: BuddyColors.green,
                    fontWeight: FontWeight.w600,
                    fontSize: 13),
              ),
            ],
          ),
        ),
      ),
      const Divider(color: BuddyColors.border, height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('You paid',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          Text(
            _artifactDisplay(order.totalArtifacts).isNotEmpty
                ? _artifactDisplay(order.totalArtifacts)
                : '\$0',
            style: const TextStyle(
                color: BuddyColors.green,
                fontWeight: FontWeight.bold,
                fontSize: 13),
          ),
        ],
      ),
      if (order.spentUsd > 0) ...[
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Value (USD)',
                style: TextStyle(
                    fontSize: 12, color: BuddyColors.textSecondary)),
            Text('\$${order.spentUsd.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 12, color: BuddyColors.textSecondary)),
          ],
        ),
      ],
    ]);
  }

  Widget _timelineCard(Order order) {
    final timeline = order.statusHistory.reversed.toList();
    return _sectionCard([
      const Text('Order Timeline',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      const SizedBox(height: 12),
      ...List.generate(timeline.length, (i) {
        final entry = timeline[i];
        final isLatest = i == 0;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isLatest
                          ? BuddyColors.green
                          : BuddyColors.surfaceRaised,
                    ),
                  ),
                  if (i < timeline.length - 1)
                    Expanded(
                      child: Container(
                        width: 1,
                        color: BuddyColors.surfaceRaised,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.status.replaceAll('_', ' ').toUpperCase(),
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      if (_formatDate(entry.at).isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(_formatDate(entry.at),
                            style: const TextStyle(
                                fontSize: 12,
                                color: BuddyColors.textSecondary)),
                      ],
                      if (entry.note.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(entry.note,
                            style: const TextStyle(
                                fontSize: 12,
                                color: BuddyColors.textSecondary)),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    ]);
  }

  Widget _sectionCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BuddyColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'paid':
      case 'delivered':
      case 'completed':
        return BuddyColors.green;
      case 'processing':
      case 'ready_for_pickup':
        return BuddyColors.gold;
      case 'shipped':
      case 'out_for_delivery':
        return BuddyColors.gold;
      case 'cancelled':
        return BuddyColors.red;
      default:
        return BuddyColors.textSecondary;
    }
  }

  String _artifactDisplay(Map<String, int> artifacts) {
    return artifacts.entries
        .where((e) => e.value > 0)
        .map((e) => '${e.value} ${e.key}')
        .join(', ');
  }

  String _formatDate(String? iso) {
    final dt = DateTime.tryParse(iso ?? '');
    if (dt == null) return '';
    return '${dt.month}/${dt.day}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
