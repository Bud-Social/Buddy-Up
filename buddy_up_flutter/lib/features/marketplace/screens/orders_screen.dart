import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/marketplace_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/page_loader.dart';
import '../../../data/models/marketplace.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: ordersAsync.when(
        data: (orders) => orders.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        size: 64,
                        color: BuddyColors.textSecondary.withValues(alpha: 0.3)),
                    const SizedBox(height: 16),
                    const Text('No orders yet',
                        style: TextStyle(color: BuddyColors.textSecondary)),
                    const SizedBox(height: 8),
                    const Text('Your purchases and tracking will appear here',
                        style: TextStyle(
                            color: BuddyColors.textSecondary, fontSize: 13)),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                itemBuilder: (_, i) {
                  final order = orders[i];
                  return _OrderCard(
                    order: order,
                    onTap: () => context.push('/marketplace/orders/${order.id}'),
                  );
                },
              ),
        loading: () => const PageLoader(),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  String _artifactDisplay(Map<String, int> artifacts) {
    return artifacts.entries
        .where((e) => e.value > 0)
        .map((e) => '${e.value} ${e.key}')
        .join(', ');
  }

  String _date(String? iso) {
    final dt = DateTime.tryParse(iso ?? '');
    if (dt == null) return '';
    return '${dt.month}/${dt.day}/${dt.year}';
  }

  Color get _statusColor {
    switch (order.status) {
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

  @override
  Widget build(BuildContext context) {
    return Card(
      color: BuddyColors.surface,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.orderNumber,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace'),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order.statusLabel.isNotEmpty
                          ? order.statusLabel
                          : order.status.replaceAll('_', ' '),
                      style: TextStyle(color: _statusColor, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${order.items.length} item${order.items.length == 1 ? '' : 's'} · ${_date(order.createdAt)}',
                        style: const TextStyle(
                            fontSize: 12, color: BuddyColors.textSecondary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _artifactDisplay(order.totalArtifacts).isNotEmpty
                            ? _artifactDisplay(order.totalArtifacts)
                            : '\$0',
                        style: const TextStyle(
                            fontSize: 13,
                            color: BuddyColors.green,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const Icon(Icons.chevron_right,
                      color: BuddyColors.textSecondary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
