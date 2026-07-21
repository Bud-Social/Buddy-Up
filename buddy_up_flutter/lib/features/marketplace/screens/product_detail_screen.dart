import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/marketplace_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/page_loader.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));
    return productAsync.when(
      data: (product) => Scaffold(
        appBar: AppBar(title: Text(product.name)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
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
                    height: 250, color: BuddyColors.surfaceRaised,
                    child: const Center(child: Icon(Icons.shopping_bag, size: 48, color: BuddyColors.textSecondary)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(product.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              if (product.brand.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(product.brand, style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 16)),
              ],
              const SizedBox(height: 8),
              Text(product.priceDisplay, style: const TextStyle(color: BuddyColors.green, fontSize: 20, fontWeight: FontWeight.bold)),
              if (product.category.isNotEmpty) ...[
                const SizedBox(height: 8),
                Chip(label: Text(product.category), backgroundColor: BuddyColors.surfaceRaised),
              ],
              const SizedBox(height: 16),
              Text(product.description, style: const TextStyle(height: 1.5)),
              const SizedBox(height: 8),
              Text('${product.clickCount} clicks', style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 24),
              BuddyButton(
                label: 'View on Affiliate Site',
                fullWidth: true,
                icon: Icons.open_in_new,
                onPressed: () async {
                  final repo = ref.read(marketplaceRepositoryProvider);
                  await repo.clickProduct(productId);
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
      ),
      loading: () => const Scaffold(body: PageLoader()),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
    );
  }
}
