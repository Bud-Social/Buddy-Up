import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/marketplace_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/marketplace.dart';
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
      data: (product) => _buildProduct(context, product),
      loading: () => const Scaffold(body: PageLoader()),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
    );
  }

  Widget _buildProduct(BuildContext context, MarketplaceProduct product) {
    // The badge, the quantity stepper and the button all read this one predicate:
    // only a *tracked* product can be sold out, so an untracked one never claims
    // otherwise and never loses its quantity control.
    final soldOut = product.stockTrackingEnabled && product.stockQuantity == 0;

    return Scaffold(
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
            if (product.stockTrackingEnabled || product.reviewCount > 0) ...[
              const SizedBox(height: 8),
              Row(children: [
                if (product.stockTrackingEnabled)
                  StockBadge(quantity: product.stockQuantity, soldOut: soldOut),
                if (product.stockTrackingEnabled && product.reviewCount > 0)
                  const SizedBox(width: 12),
                // A product with no reviews shows nothing rather than a bare
                // "0.0": zero stars on a new listing reads as "rated badly".
                if (product.reviewCount > 0)
                  Row(children: [
                    const Icon(Icons.star, size: 16, color: BuddyColors.gold),
                    const SizedBox(width: 4),
                    Text('${product.averageRating.toStringAsFixed(1)} · ${product.reviewCount} review${product.reviewCount == 1 ? '' : 's'}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ]),
              ]),
            ],
            const SizedBox(height: 16),
            Text(product.description, style: const TextStyle(height: 1.5)),
            const SizedBox(height: 8),
            Text('${product.clickCount} clicks',
                style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 24),
            _ProductReviewsSection(productId: widget.productId),
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
            // A sold-out product is not a thing you can buy more of, so the
            // quantity stepper goes with the button rather than staying behind
            // as a control that cannot do anything.
            if (!soldOut) ...[
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
                      onPressed:
                          _quantity > 1 ? () => setState(() => _quantity--) : null,
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
            ],
            Expanded(
              child: BuddyButton(
                label: soldOut ? 'Out of Stock' : 'Add to Cart',
                // Disabled, not merely relabelled: checkout rejects a sold-out
                // tracked product anyway, and offering the tap only to fail
                // later is the worse experience.
                onPressed: soldOut ? null : () => _addToCart(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart(BuildContext context) {
    ref.read(cartProvider.notifier).addToCart(
      'product',
      {'product_id': widget.productId},
      quantity: _quantity,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Added to cart'), duration: Duration(seconds: 1)),
    );
    _quantity = 1;
  }
}

/// Out of stock / Only N left / In stock.
///
/// The three states and their thresholds match `Marketplace.tsx`, so a product
/// reads identically on the grid and on its detail page. Public so the grid can
/// reuse it without duplicating the thresholds.
class StockBadge extends StatelessWidget {
  final int quantity;
  final bool soldOut;

  const StockBadge({super.key, required this.quantity, required this.soldOut});

  @override
  Widget build(BuildContext context) {
    final (label, color) = soldOut
        ? ('Out of stock', BuddyColors.red)
        : quantity <= 5
            ? ('Only $quantity left', BuddyColors.gold)
            : ('In stock', BuddyColors.green);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
    );
  }
}

/// The review list, read straight off `GET /products/<id>/reviews/`.
///
/// Read-only on purpose. The backend ties a review to an `OrderItem` and exposes
/// no edit or delete, and a product payload carries no "did I buy this?" signal
/// to gate a form with — so the client does not pretend to offer a write the
/// server would mostly refuse.
class _ProductReviewsSection extends ConsumerWidget {
  final String productId;

  const _ProductReviewsSection({required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(productReviewsProvider(productId));

    return reviewsAsync.when(
      // Newest first server-side; the web detail page shows five, so we do too.
      data: (reviews) => reviews.isEmpty
          ? const SizedBox.shrink()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Customer reviews',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...reviews.take(5).map((review) => _ReviewTile(review: review)),
              ],
            ),
      // A failed review fetch must not take the product page down with it.
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final ProductReview review;

  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BuddyColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            ...List.generate(5, (i) => Icon(
              i < review.rating ? Icons.star : Icons.star_border,
              size: 14,
              color: BuddyColors.gold,
            )),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                review.buyerData.displayName.isEmpty
                    ? review.buyerData.username
                    : review.buyerData.displayName,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ]),
          if (review.body.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(review.body, style: const TextStyle(fontSize: 13, height: 1.4)),
          ],
        ],
      ),
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