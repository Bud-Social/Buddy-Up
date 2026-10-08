import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/marketplace_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/marketplace.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/page_loader.dart';

/// The cart owns quantities and the discount code — nothing else.
///
/// Checkout used to live here as two nested modals (a confirm sheet and an
/// AlertDialog receipt). It is now its own screen at `/marketplace/checkout`, so
/// the flow is deep-linkable, survives a rebuild, and can present the payment
/// choice and station picker at full width.
class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _discountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(cartProvider.notifier).loadCart();
    });
  }

  @override
  void dispose() {
    _discountController.dispose();
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
        onPressed: () => context.push('/marketplace/checkout'),
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