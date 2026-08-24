import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/marketplace_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/marketplace.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/page_loader.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _discountController = TextEditingController();
  final _pickupController = TextEditingController();
  final _deliveryLineController = TextEditingController();
  final _deliveryCityController = TextEditingController();
  final _deliveryCountryController = TextEditingController();
  String _fulfillmentType = 'digital';
  bool _isCheckingOut = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(cartProvider.notifier).loadCart());
  }

  @override
  void dispose() {
    _discountController.dispose();
    _pickupController.dispose();
    _deliveryLineController.dispose();
    _deliveryCityController.dispose();
    _deliveryCountryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: cartAsync.when(
        data: (cart) {
          if (cart == null || cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 64,
                      color: BuddyColors.textSecondary.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  const Text('Your cart is empty',
                      style: TextStyle(color: BuddyColors.textSecondary)),
                  const SizedBox(height: 24),
                  BuddyButton(
                    label: 'Browse Marketplace',
                    variant: BuddyButtonVariant.outline,
                    onPressed: () => context.push('/marketplace'),
                  ),
                ],
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length + 1,
                  itemBuilder: (_, i) {
                    if (i < cart.items.length) {
                      return _CartItemCard(
                        item: cart.items[i],
                        onIncrement: () => _increment(cart.items[i]),
                        onRemove: () => _remove(cart.items[i]),
                      );
                    }
                    return _TotalsSummary(cart: cart);
                  },
                ),
              ),
              _discountSection(cart),
              _checkoutSection(cart),
            ],
          );
        },
        loading: () => const PageLoader(),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }

  void _increment(CartItem item) {
    final idMap = _idMapForItem(item);
    if (idMap != null) {
      ref.read(cartProvider.notifier).addToCart(item.itemType, idMap, quantity: 1);
    }
  }

  void _remove(CartItem item) {
    ref.read(cartProvider.notifier).removeFromCart(item.id);
  }

  Map<String, dynamic>? _idMapForItem(CartItem item) {
    switch (item.itemType) {
      case 'event_ticket':
        return item.event != null ? {'event_id': item.event!.id} : null;
      case 'product':
        return item.product != null ? {'product_id': item.product!.id} : null;
      case 'meal_plan':
        return item.mealPlan != null ? {'meal_plan_id': item.mealPlan!.id} : null;
      case 'programme':
        return item.programme != null ? {'programme_id': item.programme!.id} : null;
      default:
        return null;
    }
  }

  Widget _discountSection(Cart cart) {
    final hasCode = cart.discountCode != null;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: BuddyColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasCode)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: BuddyColors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: BuddyColors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: BuddyColors.green, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${cart.discountCode!.code}${cart.discountCode!.discountType == 'percentage' && cart.discountCode!.discountPct > 0 ? ' - ${cart.discountCode!.discountPct}% off' : cart.discountCode!.discountType == 'fixed_artifacts' ? ' - Fixed discount' : ''}',
                      style: const TextStyle(
                          color: BuddyColors.green,
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                    ),
                  ),
                  InkWell(
                    onTap: () => _discountController.clear(),
                    child: const Icon(Icons.close, size: 16, color: BuddyColors.textSecondary),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _discountController,
                  decoration: const InputDecoration(
                    hintText: 'Discount code',
                    filled: true,
                    fillColor: BuddyColors.surface,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(width: 8),
              BuddyButton(
                label: 'Apply',
                onPressed: () {
                  final code = _discountController.text.trim();
                  if (code.isNotEmpty) {
                    ref.read(cartProvider.notifier).applyDiscount(code);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _checkoutSection(Cart cart) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: BuddyButton(
        label: 'Review & Checkout (${cart.items.length} items)',
        fullWidth: true,
        isLoading: _isCheckingOut,
        onPressed: _isCheckingOut
            ? null
            : () => _showConfirmSheet(context, cart),
      ),
    );
  }

  Future<void> _showConfirmSheet(BuildContext context, Cart cart) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: BuddyColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Confirm Order',
                style: Theme.of(sheetCtx).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260),
              child: ListView(
                shrinkWrap: true,
                children: cart.items.map((item) {
                  final title = item.mealPlan?.title ??
                      item.programme?.title ??
                      item.product?.name ??
                      item.event?.title ??
                      'Item';
                  final art = item.itemTotalArtifacts.entries
                      .where((e) => e.value > 0)
                      .map((e) => '${e.value} ${e.key}')
                      .join(', ');
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text('$title × ${item.quantity}',
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 8),
                        Text(art.isNotEmpty
                            ? art
                            : item.itemTotalUsd > 0
                                ? '\$${item.itemTotalUsd.toStringAsFixed(2)}'
                                : '',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const Divider(color: BuddyColors.border, height: 20),
            if (cart.discountCode != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(cart.discountCode!.code,
                      style: const TextStyle(
                          color: BuddyColors.green,
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                  const Text('discount applied',
                      style: TextStyle(
                          color: BuddyColors.green, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 6),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total to pay',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(
                  cart.totalArtifacts.entries
                      .where((e) => e.value > 0)
                      .map((e) => '${e.value} ${e.key}')
                      .join(', '),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: BuddyColors.green),
                ),
              ],
            ),
            if (cart.totalUsd > 0) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${cart.baseCurrency} value',
                      style: const TextStyle(
                          fontSize: 12, color: BuddyColors.textSecondary)),
                  Text(
                    '\$${cart.totalUsd.toStringAsFixed(2)}'
                    '${cart.totalLocalCurrency > 0 ? ' · ${cart.localCurrency} ${cart.totalLocalCurrency.toStringAsFixed(2)}' : ''}',
                    style: const TextStyle(
                        fontSize: 12, color: BuddyColors.textSecondary),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            _fulfillmentSection(sheetCtx),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: BuddyButton(
                    label: 'Cancel',
                    variant: BuddyButtonVariant.outline,
                    onPressed: () => Navigator.pop(sheetCtx, false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: BuddyButton(
                    label: 'Confirm Payment',
                    isLoading: _isCheckingOut,
                    onPressed: _isCheckingOut
                        ? null
                        : () => _doCheckout(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (confirmed == true && mounted) setState(() => _isCheckingOut = false);
  }

  Future<void> _doCheckout() async {
    setState(() => _isCheckingOut = true);
    try {
      final payload = <String, dynamic>{
        'fulfillment_type': _fulfillmentType,
      };
      if (_fulfillmentType == 'delivery') {
        payload['delivery_address'] = {
          'line1': _deliveryLineController.text,
          'city': _deliveryCityController.text,
          'country': _deliveryCountryController.text,
        };
      } else if (_fulfillmentType == 'pickup') {
        payload['pickup_details'] = {
          'location': _pickupController.text,
        };
      }
      final res = await ref
          .read(marketplaceRepositoryProvider)
          .checkoutCart(payload);
      if (!mounted) return;
      final data = res['data'] as Map<String, dynamic>? ?? {};
      Navigator.pop(context, true);
      ref.read(cartProvider.notifier).loadCart();
      _showReceipt(data);
    } catch (e) {
      if (mounted) {
        Navigator.pop(context, false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Checkout failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCheckingOut = false);
    }
  }

  Widget _fulfillmentSection(BuildContext sheetCtx) {
    const types = [
      ('digital', 'Digital', Icons.check_circle_outline),
      ('pickup', 'Pickup', Icons.store_outlined),
      ('delivery', 'Delivery', Icons.local_shipping_outlined),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Delivery method',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        Row(
          children: types.map((t) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: InkWell(
                  onTap: () => setState(() => _fulfillmentType = t.$1),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _fulfillmentType == t.$1
                            ? BuddyColors.green
                            : BuddyColors.border,
                      ),
                      color: _fulfillmentType == t.$1
                          ? BuddyColors.green.withValues(alpha: 0.1)
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(t.$3,
                            size: 16,
                            color: _fulfillmentType == t.$1
                                ? BuddyColors.green
                                : BuddyColors.textSecondary),
                        const SizedBox(height: 4),
                        Text(t.$2,
                            style: TextStyle(
                                fontSize: 12,
                                color: _fulfillmentType == t.$1
                                    ? BuddyColors.green
                                    : BuddyColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (_fulfillmentType == 'delivery') ...[
          const SizedBox(height: 8),
          TextField(
            controller: _deliveryLineController,
            decoration: const InputDecoration(
              hintText: 'Street address',
              filled: true,
              fillColor: BuddyColors.surface,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
            ),
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _deliveryCityController,
                  decoration: const InputDecoration(
                    hintText: 'City',
                    filled: true,
                    fillColor: BuddyColors.surface,
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _deliveryCountryController,
                  decoration: const InputDecoration(
                    hintText: 'Country',
                    filled: true,
                    fillColor: BuddyColors.surface,
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ],
        if (_fulfillmentType == 'pickup') ...[
          const SizedBox(height: 8),
          TextField(
            controller: _pickupController,
            decoration: const InputDecoration(
              hintText: 'Pickup location / venue',
              filled: true,
              fillColor: BuddyColors.surface,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
            ),
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ],
    );
  }

  void _showReceipt(Map<String, dynamic> receipt) {
    if (!mounted) return;
    final items = (receipt['items'] as List?) ?? [];
    final total = (receipt['total_artifacts'] as Map<String, dynamic>?) ?? {};
    final original = (receipt['original_artifacts'] as Map<String, dynamic>?) ?? {};
    final savings = (receipt['savings_artifacts'] as Map<String, dynamic>?) ?? {};
    final code = receipt['discount_code'] as String?;
    final spentUsd = (receipt['spent_usd'] as num?) ?? 0;
    final orderId = receipt['order_id'] as String?;
    final orderNumber = receipt['order_number'] as String? ?? '';

    String artifacts(Map<String, dynamic> m) => m.entries
        .where((e) => (e.value as num) > 0)
        .map((e) => '${e.value} ${e.key}')
        .join(', ');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: BuddyColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.check_circle,
                  color: BuddyColors.green, size: 48),
              const SizedBox(height: 8),
              const Text('Payment Successful',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(
                orderNumber.isNotEmpty
                    ? 'Order #$orderNumber'
                    : 'Order #${(receipt['order_id'] as String? ?? '').substring(0, (receipt['order_id'] as String? ?? '').length > 8 ? 8 : (receipt['order_id'] as String? ?? '').length).toUpperCase()}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12, color: BuddyColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ...items.map((it) {
                final m = (it as Map<String, dynamic>);
                final paid = (m['paid_artifacts'] as Map<String, dynamic>?) ?? {};
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${m['title']} × ${m['quantity']}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                      if (artifacts(paid).isNotEmpty)
                        Text(artifacts(paid),
                            style: const TextStyle(
                                color: BuddyColors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                    ],
                  ),
                );
              }),
              const Divider(color: BuddyColors.border, height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Original',
                      style: TextStyle(
                          fontSize: 12, color: BuddyColors.textSecondary)),
                  Text(artifacts(original),
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
              if (artifacts(savings).isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(code != null ? 'Savings ($code)' : 'Savings',
                        style: const TextStyle(
                            fontSize: 12, color: BuddyColors.green)),
                    Text('-${artifacts(savings)}',
                        style: const TextStyle(
                            fontSize: 12, color: BuddyColors.green)),
                  ],
                ),
              ],
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('You paid',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(artifacts(total),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: BuddyColors.green)),
                ],
              ),
              if (spentUsd > 0) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Value (USD)',
                        style: TextStyle(
                            fontSize: 12, color: BuddyColors.textSecondary)),
                    Text('\$${spentUsd.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 12, color: BuddyColors.textSecondary)),
                  ],
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (orderId != null)
            TextButton(
              onPressed: () {
                Navigator.pop(dialogCtx);
                context.go('/marketplace/orders/$orderId');
              },
              child: const Text('View Order',
                  style: TextStyle(color: BuddyColors.green)),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.pop();
            },
            child: const Text('Done',
                style: TextStyle(color: BuddyColors.green)),
          ),
        ],
      ),
    );
  }
}

// ─── Totals Summary ──────────────────────────────────────────────────────────

class _TotalsSummary extends StatelessWidget {
  final Cart cart;
  const _TotalsSummary({required this.cart});

  @override
  Widget build(BuildContext context) {
    final total = cart.totalArtifacts;
    final usd = cart.totalUsd;
    final local = cart.totalLocalCurrency;
    final baseCur = cart.baseCurrency;
    final localCur = cart.localCurrency;
    final hasArtifacts = total.isNotEmpty;

    if (!hasArtifacts && usd <= 0) return const SizedBox.shrink();

    return Card(
      color: BuddyColors.surface,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cart Summary',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            if (hasArtifacts)
              ...total.entries
                  .where((e) => e.value > 0)
                  .map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(e.key,
                                style: const TextStyle(
                                    color: BuddyColors.textSecondary, fontSize: 13)),
                            Text('${e.value}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 13)),
                          ],
                        ),
                      )),
            if (usd > 0) ...[
              const Divider(height: 16, color: BuddyColors.border),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total ($baseCur)',
                      style: const TextStyle(fontSize: 13)),
                  Text('$baseCur ${usd.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              if (local > 0) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$localCur Equivalent',
                        style: const TextStyle(
                            color: BuddyColors.textSecondary, fontSize: 13)),
                    Text('$localCur ${local.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Cart item card ──────────────────────────────────────────────────────────

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.item,
    required this.onIncrement,
    required this.onRemove,
  });

  String get _title {
    return item.mealPlan?.title ??
        item.programme?.title ??
        item.product?.name ??
        item.event?.title ??
        'Item';
  }

  String get _subtitle {
    return item.itemType.replaceAll('_', ' ');
  }

  String? get _imageUrl {
    return item.mealPlan?.coverImageUrl ??
        item.programme?.coverImageUrl ??
        item.product?.imageUrl ??
        item.event?.coverImageUrl;
  }

  @override
  Widget build(BuildContext context) {
    final totalArt = item.itemTotalArtifacts;
    final totalUsd = item.itemTotalUsd;
    final hasArtifacts = totalArt.isNotEmpty;

    return Card(
      color: BuddyColors.surface,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 64,
                height: 64,
                child: Image.network(
                  _imageUrl ?? '',
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: BuddyColors.surfaceRaised,
                    child: const Icon(Icons.image,
                        color: BuddyColors.textSecondary, size: 24),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(_subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: BuddyColors.textSecondary)),
                  if (hasArtifacts) ...[
                    const SizedBox(height: 4),
                    ...totalArt.entries.where((e) => e.value > 0).map((e) => Text(
                          '${e.value} ${e.key}',
                          style: const TextStyle(
                              fontSize: 12,
                              color: BuddyColors.green,
                              fontWeight: FontWeight.w600),
                        )),
                    if (totalUsd > 0)
                      Text('~USD ${totalUsd.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 11, color: BuddyColors.textSecondary)),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _MiniQtyButton(icon: Icons.remove, onPressed: onRemove),
                      const SizedBox(width: 8),
                      Text('${item.quantity}',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      _MiniQtyButton(icon: Icons.add, onPressed: onIncrement),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: BuddyColors.red, size: 20),
              onPressed: onRemove,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniQtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _MiniQtyButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(color: BuddyColors.border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 14, color: BuddyColors.textPrimary),
      ),
    );
  }
}
