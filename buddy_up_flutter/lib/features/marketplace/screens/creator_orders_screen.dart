import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/marketplace_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/marketplace.dart';
import '../../../shared/widgets/page_loader.dart';

class CreatorOrdersScreen extends ConsumerStatefulWidget {
  const CreatorOrdersScreen({super.key});

  @override
  ConsumerState<CreatorOrdersScreen> createState() => _CreatorOrdersScreenState();
}

class _CreatorOrdersScreenState extends ConsumerState<CreatorOrdersScreen> {
  String? _selectedStatus;

  final _statusFilters = const [
    {'label': 'All', 'value': null},
    {'label': 'Paid', 'value': 'paid'},
    {'label': 'Pending', 'value': 'pending_fulfillment'},
    {'label': 'Shipped', 'value': 'shipped'},
    {'label': 'Delivered', 'value': 'delivered'},
    {'label': 'Cancelled', 'value': 'cancelled'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? BuddyColors.surface : theme.colorScheme.surface;
    final ordersAsync = ref.watch(creatorOrdersProvider(_selectedStatus));

    return Column(
      children: [
        // Filter Chips Row
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _statusFilters.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final filter = _statusFilters[index];
              final isSelected = _selectedStatus == filter['value'];
              return ChoiceChip(
                label: Text(filter['label']!),
                selected: isSelected,
                selectedColor: BuddyColors.green.withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? BuddyColors.green : theme.colorScheme.onSurfaceVariant,
                ),
                side: BorderSide(
                  color: isSelected ? BuddyColors.green : theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
                onSelected: (selected) {
                  setState(() {
                    _selectedStatus = selected ? filter['value'] : null;
                  });
                },
              );
            },
          ),
        ),

        // Orders List
        Expanded(
          child: ordersAsync.when(
            data: (orders) {
              if (orders.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () async => ref.refresh(creatorOrdersProvider(_selectedStatus)),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.shopping_bag_outlined, size: 48, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                            const SizedBox(height: 12),
                            Text(
                              'No orders found',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Customer orders will appear here.',
                              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => ref.refresh(creatorOrdersProvider(_selectedStatus)),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return _OrderCard(
                      order: order,
                      cardBg: cardBg,
                      onUpdateStatus: () => _showUpdateStatusSheet(order),
                    );
                  },
                ),
              );
            },
            loading: () => const PageLoader(),
            error: (err, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Failed to load orders: $err'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => ref.refresh(creatorOrdersProvider(_selectedStatus)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showUpdateStatusSheet(Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _UpdateOrderStatusSheet(
        order: order,
        onStatusUpdated: () {
          ref.invalidate(creatorOrdersProvider);
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final Color cardBg;
  final VoidCallback onUpdateStatus;

  const _OrderCard({
    required this.order,
    required this.cardBg,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(order.status);

    return Card(
      color: cardBg,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  order.orderNumber,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'monospace'),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    order.statusLabel.isNotEmpty ? order.statusLabel : order.status.toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${order.items.length} item(s) · Total: \$${order.spentUsd.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
            ),
            const Divider(height: 16),
            ...order.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.title} x${item.quantity}',
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    item.itemType.replaceAll('_', ' '),
                    style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            )),
            if (order.fulfillment?.trackingNumber != null && order.fulfillment!.trackingNumber.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_shipping_outlined, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Tracking: ${order.fulfillment!.trackingNumber}',
                      style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onUpdateStatus,
                icon: const Icon(Icons.edit_note, size: 16),
                label: const Text('Update Status'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: BuddyColors.green,
                  side: const BorderSide(color: BuddyColors.green),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'delivered':
      case 'completed':
        return BuddyColors.green;
      case 'shipped':
      case 'out_for_delivery':
        return const Color(0xFF60A5FA);
      case 'pending':
      case 'pending_fulfillment':
        return Colors.orange;
      case 'cancelled':
      case 'failed':
        return Colors.red;
      default:
        return const Color(0xFF9CA3AF);
    }
  }
}

class _UpdateOrderStatusSheet extends ConsumerStatefulWidget {
  final Order order;
  final VoidCallback onStatusUpdated;

  const _UpdateOrderStatusSheet({
    required this.order,
    required this.onStatusUpdated,
  });

  @override
  ConsumerState<_UpdateOrderStatusSheet> createState() => _UpdateOrderStatusSheetState();
}

class _UpdateOrderStatusSheetState extends ConsumerState<_UpdateOrderStatusSheet> {
  String? _selectedStatus;
  final _noteController = TextEditingController();
  bool _isSubmitting = false;

  final _statuses = const [
    {'label': 'Pending Fulfillment', 'value': 'pending_fulfillment'},
    {'label': 'Shipped', 'value': 'shipped'},
    {'label': 'Out for Delivery', 'value': 'out_for_delivery'},
    {'label': 'Delivered', 'value': 'delivered'},
    {'label': 'Cancelled', 'value': 'cancelled'},
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Update Status for #${widget.order.orderNumber}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Select Next Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _statuses.map((st) {
              final isSelected = _selectedStatus == st['value'];
              return ChoiceChip(
                label: Text(st['label']!),
                selected: isSelected,
                selectedColor: BuddyColors.green.withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? BuddyColors.green : null,
                ),
                onSelected: (selected) {
                  setState(() => _selectedStatus = selected ? st['value'] : null);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              labelText: 'Tracking / Status Note (Optional)',
              hintText: 'e.g. Dispatched with tracking #12345',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: _selectedStatus == null || _isSubmitting ? null : _submitStatus,
              style: ElevatedButton.styleFrom(
                backgroundColor: BuddyColors.green,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _isSubmitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Confirm Status Update', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitStatus() async {
    setState(() => _isSubmitting = true);
    try {
      await ref.read(marketplaceRepositoryProvider).updateOrderStatus(
        widget.order.id,
        {
          'status': _selectedStatus,
          'note': _noteController.text.trim(),
        },
      );
      widget.onStatusUpdated();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order status updated successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
