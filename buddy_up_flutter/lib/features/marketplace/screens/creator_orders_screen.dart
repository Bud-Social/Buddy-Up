import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/marketplace_provider.dart';
import '../utils/delivery_vehicles.dart';
import '../utils/order_transitions.dart';
import '../utils/stations.dart';
import '../../../core/api/api_error.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/distance.dart';
import '../../../data/models/marketplace.dart';
import '../../../shared/widgets/page_loader.dart';

/// The seller order hub: bulk status moves, per-order courier assignment and a
/// carrier/tracking editor.
///
/// Transitions follow the server's fulfillment-aware machine
/// (`utils/order_transitions.dart`) so a `pickup` order is never offered
/// "shipped" and a `digital` one is never offered "out for delivery". That map
/// only decides which *buttons* exist — when the server disagrees, its 400 wins
/// and its message is rendered verbatim rather than being second-guessed.
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
      return order != null &&
          isOrderTransitionAllowed(
            order.status,
            newStatus,
            order.fulfillmentType,
          );
    }).toList();
    if (targets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No selected order can legally move to that status'),
        ),
      );
      return;
    }
    setState(() => _bulkUpdating = true);
    var ok = 0;
    final failures = <String>[];
    for (final id in targets) {
      try {
        await ref
            .read(marketplaceRepositoryProvider)
            .updateOrderFulfillment(id, {'status': newStatus});
        ok++;
      } catch (e) {
        failures.add(apiErrorMessage(e, fallback: 'Order $id failed.'));
      }
    }
    setState(() {
      _bulkUpdating = false;
      _selectedOrderIds.clear();
    });
    ref.invalidate(creatorOrdersProvider);
    if (!mounted) return;
    final verb = newStatus.replaceAll('_', ' ');
    // A partial bulk run must say what failed, not just how many worked.
    final message = failures.isEmpty
        ? 'Updated $ok/${targets.length} orders to $verb'
        : 'Updated $ok/${targets.length} orders to $verb. '
            '${failures.length} rejected: ${failures.first}';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
                            for (final st in const ['processing', 'delivered'])
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
                            onManageOrder: () => _showManageOrderSheet(order),
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

  void _showManageOrderSheet(Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _ManageOrderSheet(
        order: order,
        onSaved: () {
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
  final VoidCallback onManageOrder;

  const _OrderCard({
    required this.order,
    required this.cardBg,
    required this.isSelected,
    required this.onToggleSelect,
    required this.onManageOrder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(order.status);
    final next = allowedOrderTransitions(order.status, order.fulfillmentType);

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
              '${order.items.length} item(s) · ${order.fulfillmentType} · Total: \$${order.spentUsd.toStringAsFixed(2)}',
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
                    Expanded(
                      child: Text(
                        'Tracking: ${order.fulfillment!.trackingNumber}'
                        '${order.fulfillment!.carrier.isEmpty ? '' : ' · ${order.fulfillment!.carrier}'}',
                        style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onManageOrder,
                      icon: const Icon(Icons.local_shipping, size: 16),
                      label: const Text('Manage'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: BuddyColors.green,
                        side: const BorderSide(color: BuddyColors.green),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (next.isEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'No further status changes are legal from ${order.status.replaceAll('_', ' ')} for a '
                '${order.fulfillmentType} order.',
                style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
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

/// Seller order management: status + courier + carrier/tracking, in one PATCH.
///
/// `PATCH /marketplace/orders/<id>/fulfillment/` is the single place a seller
/// writes any of this — and the single place an order status change notifies
/// anyone, so shipping the courier id and the new status together produces
/// exactly one notification rather than two.
class _ManageOrderSheet extends ConsumerStatefulWidget {
  final Order order;
  final VoidCallback onSaved;

  const _ManageOrderSheet({required this.order, required this.onSaved});

  @override
  ConsumerState<_ManageOrderSheet> createState() => _ManageOrderSheetState();
}

class _ManageOrderSheetState extends ConsumerState<_ManageOrderSheet> {
  late String? _status;
  late String _courierId;
  late String _stationId;
  late final TextEditingController _noteController;
  late final TextEditingController _carrierController;
  late final TextEditingController _trackingController;
  late final TextEditingController _trackingUrlController;
  late final TextEditingController _pickupLocationController;

  bool _submitting = false;
  String? _serverError;

  @override
  void initState() {
    super.initState();
    final order = widget.order;
    _status = null;
    _courierId = order.deliveryPersonnel ?? '';
    _stationId = order.pickupStation ?? '';
    _noteController = TextEditingController();
    _carrierController =
        TextEditingController(text: order.fulfillment?.carrier ?? '');
    _trackingController =
        TextEditingController(text: order.fulfillment?.trackingNumber ?? '');
    _trackingUrlController =
        TextEditingController(text: order.fulfillment?.trackingUrl ?? '');
    _pickupLocationController =
        TextEditingController(text: order.fulfillment?.pickupLocation ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    _carrierController.dispose();
    _trackingController.dispose();
    _trackingUrlController.dispose();
    _pickupLocationController.dispose();
    super.dispose();
  }

  bool get _hasCarrierFields =>
      _carrierController.text.trim().isNotEmpty ||
      _trackingController.text.trim().isNotEmpty ||
      _trackingUrlController.text.trim().isNotEmpty ||
      _pickupLocationController.text.trim().isNotEmpty;

  bool get _hasChanges =>
      _status != null ||
      _courierId != (widget.order.deliveryPersonnel ?? '') ||
      _stationId != (widget.order.pickupStation ?? '') ||
      _noteController.text.trim().isNotEmpty ||
      _hasCarrierFields;

  Future<void> _submit() async {
    final note = _noteController.text.trim();
    final payload = <String, dynamic>{
      // Always send the assignment keys — an explicit null clears the courier or
      // the station, which is how "unassign" is expressed.
      'delivery_personnel_id': _courierId.isEmpty ? null : _courierId,
      'pickup_station_id': _stationId.isEmpty ? null : _stationId,
      if (_carrierController.text.trim().isNotEmpty)
        'carrier': _carrierController.text.trim(),
      if (_trackingController.text.trim().isNotEmpty)
        'tracking_number': _trackingController.text.trim(),
      if (_trackingUrlController.text.trim().isNotEmpty)
        'tracking_url': _trackingUrlController.text.trim(),
      if (_pickupLocationController.text.trim().isNotEmpty)
        'pickup_location': _pickupLocationController.text.trim(),
      if (note.isNotEmpty) 'notes': note,
      if (_status != null) 'status': _status,
    };

    setState(() {
      _submitting = true;
      _serverError = null;
    });
    try {
      await ref
          .read(marketplaceRepositoryProvider)
          .updateOrderFulfillment(widget.order.id, payload);
      widget.onSaved();
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order updated.')),
      );
    } catch (e) {
      // The server names the illegal move ("Cannot move order from pickup to
      // out_for_delivery…"). Show that sentence; never re-word it.
      if (mounted) {
        setState(() => _serverError = apiErrorMessage(
              e,
              fallback: 'Could not update this order.',
            ));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final order = widget.order;
    final next = allowedOrderTransitions(order.status, order.fulfillmentType);
    final physical = order.fulfillmentType == 'delivery';

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: ListView(
          controller: scrollController,
          shrinkWrap: true,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Manage #${order.orderNumber}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${orderStatusLabel(order.status)} · ${order.fulfillmentType} order',
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),

            // ── Status ──────────────────────────────────────────────────────
            const Text('Move to status',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (next.isEmpty)
              Text(
                'This order is at a terminal state — nothing further is allowed from '
                '${orderStatusLabel(order.status)} on a ${order.fulfillmentType} order.',
                style: TextStyle(
                    fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: next.map((status) {
                  final isSelected = _status == status;
                  return ChoiceChip(
                    label: Text(orderStatusLabel(status)),
                    selected: isSelected,
                    selectedColor: BuddyColors.green.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? BuddyColors.green : null,
                    ),
                    onSelected: (selected) => setState(
                      () => _status = selected ? status : null,
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),

            // ── Courier (delivery only) ─────────────────────────────────────
            if (physical) ...[
              const Text('Courier',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _CourierPicker(
                orderId: order.id,
                selectedId: _courierId,
                onSelect: (value) => setState(() => _courierId = value ?? ''),
              ),
              const SizedBox(height: 16),
            ],

            // ── Pickup station (pickup only) ────────────────────────────────
            if (order.fulfillmentType == 'pickup') ...[
              const Text('Pickup station',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _StationPicker(
                selectedId: _stationId,
                onSelect: (value) => setState(() => _stationId = value ?? ''),
              ),
              const SizedBox(height: 16),
            ],

            // ── Carrier / tracking ─────────────────────────────────────────
            const Text('Carrier & tracking',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _Field(controller: _carrierController, label: 'Carrier (optional)'),
            const SizedBox(height: 10),
            _Field(
              controller: _trackingController,
              label: 'Tracking number (optional)',
            ),
            const SizedBox(height: 10),
            _Field(
              controller: _trackingUrlController,
              label: 'Tracking URL (optional)',
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 10),
            _Field(
              controller: _pickupLocationController,
              label: 'Pickup location (optional)',
            ),
            const SizedBox(height: 10),
            _Field(
              controller: _noteController,
              label: 'Status note (optional)',
              maxLines: 2,
              hint: 'e.g. Dispatched with the courier',
            ),
            const SizedBox(height: 16),

            if (_serverError != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: BuddyColors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: BuddyColors.red.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _serverError!,
                  style: const TextStyle(
                      fontSize: 12, color: BuddyColors.red, height: 1.35),
                ),
              ),
              const SizedBox(height: 12),
            ],

            SizedBox(
              height: 46,
              child: ElevatedButton(
                onPressed: !_hasChanges || _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: BuddyColors.green,
                  foregroundColor: Colors.black,
                  shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save changes',
                        style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboardType;

  const _Field({
    required this.controller,
    required this.label,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

/// Courier assignment, grouped by vehicle type.
///
/// The endpoint returns every active courier and deliberately does not try to
/// fit vehicles to orders, so the seller chooses. `distance_km` is null unless
/// the courier shares a non-incognito search profile and the order carries
/// coordinates — the picker degrades to service zones in that case.
class _CourierPicker extends ConsumerWidget {
  final String orderId;
  final String selectedId;
  final ValueChanged<String?> onSelect;

  const _CourierPicker({
    required this.orderId,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couriers = ref.watch(orderCouriersProvider(orderId));
    return couriers.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (e, _) => Text(
        apiErrorMessage(e, fallback: 'Could not load couriers.'),
        style: const TextStyle(fontSize: 12, color: BuddyColors.red),
      ),
      data: (data) {
        if (data.couriers.isEmpty) {
          return const Text(
            'No active couriers are available to assign yet.',
            style: TextStyle(fontSize: 12),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CourierTile(
              label: 'No courier',
              selected: selectedId.isEmpty,
              onTap: () => onSelect(null),
            ),
            for (final group in data.byVehicle) ...[
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 4),
                child: Text(
                  '${group.vehicleLabel.isEmpty ? deliveryVehicleLabel(group.vehicleType) : group.vehicleLabel} · ${group.count}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              for (final courier in group.couriers)
                _CourierTile(
                  label: courier.displayName.isEmpty
                      ? courier.username
                      : courier.displayName,
                  detail: [
                    if (courier.serviceZones.isNotEmpty)
                      serviceZonesLabel(courier.serviceZones),
                    if (courier.rating != null)
                      '★ ${courier.rating!.toStringAsFixed(1)}',
                    if (formatDistanceBadge(courier.distanceKm) != null)
                      formatDistanceBadge(courier.distanceKm)!,
                  ].join(' · '),
                  selected: courier.id == selectedId,
                  onTap: () => onSelect(courier.id),
                ),
            ],
          ],
        );
      },
    );
  }
}

class _CourierTile extends StatelessWidget {
  final String label;
  final String? detail;
  final bool selected;
  final VoidCallback onTap;

  const _CourierTile({
    required this.label,
    required this.selected,
    required this.onTap,
    this.detail,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? BuddyColors.green : cs.outline.withValues(alpha: 0.2),
          ),
          color:
              selected ? BuddyColors.green.withValues(alpha: 0.1) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 16,
              color: selected ? BuddyColors.green : cs.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (detail != null && detail!.isNotEmpty)
                    Text(
                      detail!,
                      style:
                          TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

/// Station assignment for a pickup order. Reads the same public list a buyer
/// picks from, so the two can never disagree about which station exists.
class _StationPicker extends ConsumerWidget {
  final String selectedId;
  final ValueChanged<String?> onSelect;

  const _StationPicker({required this.selectedId, required this.onSelect});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stations = ref.watch(stationsProvider(const StationQuery()));
    return stations.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (e, _) => Text(
        apiErrorMessage(e, fallback: 'Could not load pickup stations.'),
        style: const TextStyle(fontSize: 12, color: BuddyColors.red),
      ),
      data: (list) {
        if (list.isEmpty) {
          return const Text(
            'No active pickup stations are listed yet.',
            style: TextStyle(fontSize: 12),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CourierTile(
              label: 'No station',
              selected: selectedId.isEmpty,
              onTap: () => onSelect(null),
            ),
            for (final station in list)
              _CourierTile(
                label: station.name.isEmpty ? 'Pickup station' : station.name,
                detail: stationAreaLabel(station),
                selected: station.id == selectedId,
                onTap: () => onSelect(station.id),
              ),
          ],
        );
      },
    );
  }
}