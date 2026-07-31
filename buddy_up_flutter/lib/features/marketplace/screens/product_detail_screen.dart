import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/marketplace_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/page_loader.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));
    return productAsync.when(
      data: (product) => Scaffold(
        appBar: AppBar(title: Text(product.name)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  product.imageUrl,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 250,
                    color: BuddyColors.surfaceRaised,
                    child: const Center(
                        child: Icon(Icons.shopping_bag, size: 48,
                            color: BuddyColors.textSecondary)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(product.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              if (product.brand.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(product.brand,
                    style:
                        const TextStyle(color: BuddyColors.textSecondary, fontSize: 16)),
              ],
              const SizedBox(height: 8),
              Text(product.priceDisplay,
                  style: const TextStyle(
                      color: BuddyColors.green,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              if (product.category.isNotEmpty) ...[
                const SizedBox(height: 8),
                Chip(label: Text(product.category),
                    backgroundColor: BuddyColors.surfaceRaised),
              ],
              const SizedBox(height: 16),
              Text(product.description, style: const TextStyle(height: 1.5)),
              const SizedBox(height: 8),
              Text('${product.clickCount} clicks',
                  style:
                      const TextStyle(color: BuddyColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 24),
              BuddyButton(
                label: 'View on Affiliate Site',
                fullWidth: true,
                variant: BuddyButtonVariant.outline,
                icon: Icons.open_in_new,
                onPressed: () async {
                  final repo = ref.read(marketplaceRepositoryProvider);
                  await repo.clickProduct(widget.productId);
                  if (product.affiliateUrl.isNotEmpty) {
                    final uri = Uri.tryParse(product.affiliateUrl);
                    if (uri != null && await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  }
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          decoration: const BoxDecoration(
            color: BuddyColors.surface,
            border: Border(top: BorderSide(color: BuddyColors.border)),
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: BuddyColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _QtyButton(
                      icon: Icons.remove,
                      onPressed: _quantity > 1
                          ? () => setState(() => _quantity--)
                          : null,
                    ),
                    SizedBox(
                      width: 40,
                      child: Center(
                        child: Text('$_quantity',
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    _QtyButton(
                      icon: Icons.add,
                      onPressed: () => setState(() => _quantity++),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BuddyButton(
                  label: 'Add to Cart',
                  onPressed: () {
                    ref.read(cartProvider.notifier).addToCart(
                      'product',
                      {'product_id': widget.productId},
                      quantity: _quantity,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Added to cart'),
                          duration: Duration(seconds: 1)),
                    );
                    _quantity = 1;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      loading: () => const Scaffold(body: PageLoader()),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _QtyButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        icon: Icon(icon, size: 18),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        color: onPressed == null ? BuddyColors.textSecondary : BuddyColors.textPrimary,
      ),
    );
  }
}
