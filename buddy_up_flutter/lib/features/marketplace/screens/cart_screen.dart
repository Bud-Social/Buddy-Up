import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/marketplace_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/page_loader.dart';

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
    Future.microtask(() => ref.read(cartProvider.notifier).loadCart());
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
                  Icon(Icons.shopping_cart_outlined, size: 64, color: BuddyColors.textSecondary.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  const Text('Your cart is empty', style: TextStyle(color: BuddyColors.textSecondary)),
                ],
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  itemBuilder: (_, i) {
                    final item = cart.items[i];
                    final title = item.mealPlan?.title ?? item.programme?.title ?? item.product?.name ?? item.event?.title ?? 'Item';
                    return Card(
                      color: BuddyColors.surface,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(item.itemType.replaceAll('_', ' ')),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, color: BuddyColors.red),
                          onPressed: () => ref.read(cartProvider.notifier).removeFromCart(item.id),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (cart.discountCode != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Discount: ${cart.discountCode!.code} (${cart.discountCode!.discountPct}% off)',
                    style: const TextStyle(color: BuddyColors.green)),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _discountController,
                        decoration: const InputDecoration(
                          hintText: 'Discount code',
                          filled: true,
                          fillColor: BuddyColors.surface,
                          border: OutlineInputBorder(),
                        ),
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
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: BuddyButton(
                  label: 'Checkout (${cart.items.length} items)',
                  fullWidth: true,
                  onPressed: () async {
                    await ref.read(marketplaceRepositoryProvider).checkoutCart();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Checkout successful!')),
                      );
                      ref.read(cartProvider.notifier).loadCart();
                    }
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const PageLoader(),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}
