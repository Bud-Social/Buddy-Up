import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/marketplace_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/marketplace.dart';
import '../../../shared/widgets/page_loader.dart';

/// Allowed forward transitions for bulk seller updates (mirrors backend).
const Map<String, List<String>> _sellerForwardOk = {
  'paid': ['processing', 'shipped', 'out_for_delivery', 'ready_for_pickup', 'delivered', 'cancelled'],
  'pending_fulfillment': ['processing', 'shipped', 'out_for_delivery', 'ready_for_pickup', 'delivered', 'cancelled'],
  'processing': ['shipped', 'out_for_delivery', 'ready_for_pickup', 'delivered'],
  'shipped': ['out_for_delivery', 'ready_for_pickup', 'delivered'],
  'out_for_delivery': ['ready_for_pickup', 'delivered'],
  'ready_for_pickup': ['delivered'],
};

class CreatorOrdersScreen extends ConsumerStatefulWidget {
  const CreatorOrdersScreen({super.key});

  @override
  ConsumerState<CreatorOrdersScreen> createState() => _CreatorOrdersScreenState();
}

class _CreatorOrdersScreenState extends ConsumerState<CreatorOrdersScreen> {
  String? _selectedStatus;
  final Set<String> _selectedOrderIds = <String>{};
  bool _bulkUpdating = false;

  final _statusFilters = const [
    {'label': 'All', 'value': null},
    {'label': 'Paid', 'value': 'paid'},
    {'label': 'Pending', 'value': 'pending_fulfillment'},
    {'label': 'Shipped', 'value': 'shipped'},
    {'label': 'Delivered', 'value': 'delivered'},
    {'label': 'Cancelled', 'value': 'cancelled'},
  ];

  Future<void> _exportCsv(List<Order> orders) async {
    if (orders.isEmpty) return;
    String esc(Object? v) => '"${'$v'.replaceAll('"', '""')}"';
    final rows = <List<String>>[
      ['order_number', 'date', 'status', 'items', 'total_usd', 'tracking_number', 'carrier'],
    ];
    for (final o in orders) {
      rows.add([
        o.orderNumber,
        DateTime.tryParse(o.createdAt ?? '')?.toIso8601String() ?? '',
        o.status,
        o.items.map((it) => '${it.title} x${it.quantity}').join('; '),
        o.spentUsd.toStringAsFixed(2),
        o.fulfillment?.trackingNumber ?? '',
        o.fulfillment?.carrier ?? '',
      ]);
    }
    final csv = rows.map((r) => r.map(esc).join(',')).join('\n');
    try {
      final dir = await getApplicationDocumentsDirectory();
      final stamp = DateTime.now().toIso8601String().substring(0, 10);
      final file = File('${dir.path}/buddyup-orders-$stamp.csv');
      await file.writeAsString(csv);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exported ${orders.length} orders to ${file.path}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _bulkUpdate(String newStatus) async {
    final orders =
        (ref.read(creatorOrdersProvider(_selectedStatus)).value ?? const <Order>[]);
    final targets = _selectedOrderIds.where((id) {
      final order = orders.where((o) => o.id == id).firstOrNull;
      return order != null && (_sellerForwardOk[order.status] ?? const []).contains(newStatus);
    }).toList();
    if (targets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No selected orders can move to that status')),
      );
      return;
    }
    setState(() => _bulkUpdating = true);
    var ok = 0;
    for (final id in targets) {
      try {
        await ref.read(marketplaceRepositoryProvider).updateOrderStatus(id, {'status': newStatus});
        ok++;
      } catch (_) {}
    }
    setState(() {
      _bulkUpdating = false;
      _selectedOrderIds.clear();
    });
    ref.invalidate(creatorOrdersProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Updated $ok/${targets.length} orders to ${newStatus.replaceAll('_', ' ')}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? BuddyColors.surface : theme.colorScheme.surface;
    final ordersAsync = ref.watch(creatorOrdersProvider(_selectedStatus));

    return Column(
      children: [
        // Filter Chips Row + export
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Expanded(
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
              TextButton.icon(
                onPressed: () => _exportCsv(ordersAsync.value ?? const <Order>[]),
                icon: const Icon(Icons.file_download_outlined, size: 16),
                label: const Text('CSV', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(foregroundColor: BuddyColors.green),
              ),
            ],
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
                child: Column(
                  children: [
                    if (_selectedOrderIds.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: BuddyColors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: BuddyColors.green.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            Text('${_selectedOrderIds.length} selected',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            const Spacer(),
                            for (final st in const ['processing', 'shipped', 'delivered'])
                              Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: ActionChip(
                                  label: Text('Mark ${st.replaceAll('_', ' ')}',
                                      style: const TextStyle(fontSize: 11)),
                                  onPressed: _bulkUpdating ? null : () => _bulkUpdate(st),
                                ),
                              ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 16),
                              tooltip: 'Clear selection',
                              onPressed: () => setState(() => _selectedOrderIds.clear()),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          return _OrderCard(
                            order: order,
                            cardBg: cardBg,
                            isSelected: _selectedOrderIds.contains(order.id),
                            onToggleSelect: () => setState(() {
                              _selectedOrderIds.contains(order.id)
                                  ? _selectedOrderIds.remove(order.id)
                                  : _selectedOrderIds.add(order.id);
                            }),
                            onUpdateStatus: () => _showUpdateStatusSheet(order),
                          );
                        },
                      ),
                    ),
                  ],
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
  final bool isSelected;
  final VoidCallback onToggleSelect;
  final VoidCallback onUpdateStatus;

  const _OrderCard({
    required this.order,
    required this.cardBg,
    required this.isSelected,
    required this.onToggleSelect,
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
        side: BorderSide(
          color: isSelected ? BuddyColors.green : theme.colorScheme.outline.withValues(alpha: 0.15),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: isSelected,
                  activeColor: BuddyColors.green,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  onChanged: (_) => onToggleSelect(),
                ),
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
