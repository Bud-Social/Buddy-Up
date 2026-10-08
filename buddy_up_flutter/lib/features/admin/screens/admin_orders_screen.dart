import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_error.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/admin_portal.dart';
import '../../../features/marketplace/utils/checkout.dart' show artifactDisplay;
import '../../../features/marketplace/utils/order_transitions.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_widgets.dart';

/// `/portal/orders/` — platform-wide orders plus the status actions staff own.
///
/// Two different transition vocabularies meet here and both are respected:
///
///  * `allowed_next_statuses` comes from the server and is computed from
///    `ORDER_FORWARD_STATES` — the flat map `PATCH /portal/orders/<id>/status/`
///    actually enforces.
///  * The fulfillment-aware table is what the *seller* endpoint enforces, so a
///    status the flat map allows but the fulfillment machine does not (marking
///    a `pickup` order "shipped", say) is offered but annotated. Silently hiding
///    it would hide a move the server permits; silently dropping the annotation
///    would claim a rule this endpoint does not have.
class AdminOrdersScreen extends ConsumerStatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  ConsumerState<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  Timer? _debounce;

  int _page = 1;
  String _query = '';
  String _status = 'all';
  String _fulfillment = 'all';
  String _paymentStatus = 'all';
  String _paymentMethod = 'all';
  String? _expandedId;
  String? _pendingId;
  String? _error;
  String? _notice;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  PortalQuery get _query_ => PortalQuery.of(_page, {
        'q': _query,
        'status': _status,
        'fulfillment_type': _fulfillment,
        'payment_status': _paymentStatus,
        'payment_method': _paymentMethod,
      });

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(adminOrdersProvider(_query_));
    return Scaffold(
      appBar: AppBar(title: const Text('Admin · Orders')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(adminOrdersProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const AdminPageHeader(
              title: 'Orders',
              description: 'Platform-wide orders. Status actions follow the '
                  "server's own rules; its 400 is shown verbatim.",
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Order number, buyer username or email…',
                prefixIcon: const Icon(Icons.search, size: 18),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (value) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 350), () {
                  if (mounted) {
                    setState(() {
                      _query = value.trim();
                      _page = 1;
                    });
                  }
                });
              },
            ),
            const SizedBox(height: 10),
            AdminFilterChips(
              value: _status,
              options: const [
                (value: 'all', label: 'Any status'),
                (value: 'pending', label: 'Pending'),
                (value: 'paid', label: 'Paid'),
                (value: 'processing', label: 'Processing'),
                (value: 'shipped', label: 'Shipped'),
                (value: 'out_for_delivery', label: 'Out for delivery'),
                (value: 'ready_for_pickup', label: 'Ready for pickup'),
                (value: 'delivered', label: 'Delivered'),
                (value: 'completed', label: 'Completed'),
                (value: 'cancelled', label: 'Cancelled'),
              ],
              onChanged: (v) => setState(() {
                _status = v;
                _page = 1;
              }),
            ),
            const SizedBox(height: 8),
            AdminFilterChips(
              value: _fulfillment,
              options: const [
                (value: 'all', label: 'Any fulfillment'),
                (value: 'digital', label: 'Digital'),
                (value: 'pickup', label: 'Pickup'),
                (value: 'delivery', label: 'Delivery'),
              ],
              onChanged: (v) => setState(() {
                _fulfillment = v;
                _page = 1;
              }),
            ),
            const SizedBox(height: 8),
            AdminFilterChips(
              value: _paymentStatus,
              options: const [
                (value: 'all', label: 'Any payment state'),
                (value: 'unpaid', label: 'Unpaid'),
                (value: 'pending', label: 'Pending'),
                (value: 'paid', label: 'Paid'),
                (value: 'failed', label: 'Failed'),
                (value: 'refunded', label: 'Refunded'),
              ],
              onChanged: (v) => setState(() {
                _paymentStatus = v;
                _page = 1;
              }),
            ),
            const SizedBox(height: 8),
            AdminFilterChips(
              value: _paymentMethod,
              options: const [
                (value: 'all', label: 'Any method'),
                (value: 'artifacts', label: 'Artifacts'),
                (value: 'mpesa', label: 'M-Pesa'),
                (value: 'card', label: 'Card'),
              ],
              onChanged: (v) => setState(() {
                _paymentMethod = v;
                _page = 1;
              }),
            ),
            const SizedBox(height: 12),
            if (_error != null) ...[
              AdminErrorBanner(
                message: _error!,
                onRetry: () => ref.invalidate(adminOrdersProvider),
              ),
              const SizedBox(height: 10),
            ],
            if (_notice != null) ...[
              AdminNoticeBanner(message: _notice!),
              const SizedBox(height: 10),
            ],
            ...async.when(
              loading: () => [const SizedBox(height: 80)],
              error: (e, _) => [
                AdminErrorBanner(
                  message:
                      apiErrorMessage(e, fallback: 'Failed to load orders.'),
                  onRetry: () => ref.invalidate(adminOrdersProvider),
                ),
              ],
              data: (result) => [
                Row(
                  children: [
                    Expanded(
                      child: AdminStatCard(
                        label: 'Matching orders',
                        value: '${result.count}',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AdminStatCard(
                        label: 'Unpaid here',
                        value:
                            '${result.items.where((o) => o.paymentStatus != 'paid').length}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (result.items.isEmpty)
                  const AdminEmptyState(
                    icon: Icons.shopping_bag_outlined,
                    title: 'No orders match the current filters.',
                  )
                else
                  for (final order in result.items) _orderRow(order),
                const SizedBox(height: 4),
                AdminPager(
                  page: result,
                  currentPage: _page,
                  busy: async.isLoading,
                  onPage: (next) => setState(() => _page = next),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<String> _actions(PortalOrder order) {
    final server = order.allowedNextStatuses;
    final fulfillmentAware = allowedOrderTransitions(
      order.status,
      order.fulfillmentType,
    );
    final seen = <String>{};
    return [...server, ...fulfillmentAware].where(seen.add).toList();
  }

  Future<void> _move(PortalOrder order, String next) async {
    setState(() {
      _error = null;
      _notice = null;
    });
    try {
      final note = _noteController.text.trim();
      final raw = await ref
          .read(adminPortalRepositoryProvider)
          .updateOrderStatus(order.id, {
        'status': next,
        if (note.isNotEmpty) 'note': note,
      });
      if (!mounted) return;
      setState(() {
        _notice = portalMessage(raw);
        _pendingId = null;
        _noteController.clear();
      });
      ref.invalidate(adminOrdersProvider);
    } catch (e) {
      if (mounted) {
        setState(() => _error = apiErrorMessage(
              e,
              fallback: 'Could not change the status.',
            ));
      }
    }
  }

  Widget _orderRow(PortalOrder order) {
    final expanded = _expandedId == order.id;
    final acting = _pendingId == order.id;
    final actions = _actions(order);
    return AdminRowCard(
      title: '#${order.orderNumber.isEmpty ? order.id.substring(0, 8) : order.orderNumber}',
      badges: [
        AdminStatusBadge(status: order.statusLabel.isEmpty ? order.status : order.statusLabel, upper: false),
        AdminStatusBadge(status: order.fulfillmentType),
        AdminStatusBadge(status: order.paymentStatus),
        if (order.paymentMethod != null)
          AdminStatusBadge(status: order.paymentMethod),
      ],
      subtitle: artifactDisplay(order.totalArtifacts),
      meta: [
        if (order.buyerUsername != null) '@${order.buyerUsername}',
        if (order.buyerEmail != null && order.buyerEmail!.isNotEmpty)
          order.buyerEmail!,
        '${order.items.length} line(s)',
        'USD ${order.spentUsd.toStringAsFixed(2)}',
      ].join(' · '),
      actions: [
        AdminActionButton(
          label: expanded ? 'Hide' : 'Details',
          icon: Icons.receipt_long_outlined,
          onPressed: () =>
              setState(() => _expandedId = expanded ? null : order.id),
        ),
        AdminActionButton(
          label: 'Status',
          icon: Icons.sync_alt,
          onPressed: () => setState(() => _pendingId = acting ? null : order.id),
        ),
      ],
      expanded: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (expanded) ...[
            AdminDataRow(label: 'Order ID', value: order.id),
            AdminDataRow(label: 'Buyer',
                value: order.buyerDisplayName ??
                    order.buyerUsername ??
                    '—'),
            AdminDataRow(label: 'Paid at', value: order.paidAt ?? '—'),
            AdminDataRow(label: 'Payment provider',
                value: order.paymentProvider.isEmpty ? '—' : order.paymentProvider),
            AdminDataRow(label: 'Payment reference',
                value: order.paymentReference.isEmpty
                    ? '—'
                    : order.paymentReference),
            if (order.deliveryAddress.isNotEmpty) ...[
              const SizedBox(height: 6),
              const Text('Delivery address',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ...order.deliveryAddress.entries.map((e) => AdminDataRow(
                    label: e.key,
                    value: '${e.value}',
                  )),
            ],
            if (order.pickupDetails.isNotEmpty) ...[
              const SizedBox(height: 6),
              const Text('Pickup details',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ...order.pickupDetails.entries.map((e) => AdminDataRow(
                    label: e.key,
                    value: '${e.value}',
                  )),
            ],
            const SizedBox(height: 8),
            for (final item in order.items)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
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
                    Text(
                      item.creatorDisplayName ??
                          item.creatorUsername ??
                          item.itemType.replaceAll('_', ' '),
                      style: const TextStyle(
                          fontSize: 11, color: BuddyColors.textSecondary),
                    ),
                  ],
                ),
              ),
            if (order.cases.isNotEmpty) ...[
              const SizedBox(height: 8),
              for (final itemCase in order.cases)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'Case ${itemCase.caseType} · ${itemCase.status}'
                    '${itemCase.affectsLedger ? '' : ' (ledger unaffected)'}',
                    style: const TextStyle(
                        fontSize: 11, color: BuddyColors.textSecondary),
                  ),
                ),
            ],
          ],
          if (acting) ...[
            const SizedBox(height: 10),
            if (actions.isEmpty)
              const Text(
                'No further transitions are legal from here.',
                style: TextStyle(fontSize: 12, color: BuddyColors.textSecondary),
              )
            else
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final next in actions)
                    ActionChip(
                      label: Text(orderStatusLabel(next),
                          style: const TextStyle(fontSize: 11)),
                      onPressed: () => _move(order, next),
                    ),
                ],
              ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Operator note (optional)',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () =>
                  context.push('/marketplace/orders/${order.id}'),
              icon: const Icon(Icons.open_in_new, size: 14),
              label: const Text('Open in the buyer-facing app',
                  style: TextStyle(fontSize: 12)),
            ),
          ],
        ],
      ),
    );
  }
}