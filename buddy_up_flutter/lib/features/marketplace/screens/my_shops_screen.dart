import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/marketplace_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/marketplace.dart';

class MyShopsScreen extends ConsumerWidget {
  const MyShopsScreen({super.key});

  Future<void> _registerCreator(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(marketplaceRepositoryProvider).registerCreator({});
      messenger.showSnackBar(
        const SnackBar(
          content: Text('You are now a creator! 🎉'),
          backgroundColor: BuddyColors.green,
        ),
      );
      ref.invalidate(myShopsProvider);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Registration failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopsAsync = ref.watch(myShopsProvider);

    return Scaffold(
      backgroundColor: BuddyColors.black,
      appBar: AppBar(
        backgroundColor: BuddyColors.surface,
        title: const Text('My Shops', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Shop'),
            onPressed: () => context.push('/marketplace/shops/create'),
          ),
        ],
      ),
      body: shopsAsync.when(
        data: (shops) => shops.isEmpty
            ? _EmptyShopsState(
                onCreateTap: () => context.push('/marketplace/shops/create'),
                onRegisterTap: () => _registerCreator(context, ref),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: shops.length,
                itemBuilder: (_, i) => _ShopCard(shop: shops[i]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: BuddyColors.textSecondary),
              const SizedBox(height: 12),
              Text('Failed to load shops', style: TextStyle(color: BuddyColors.textSecondary)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(myShopsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  final Shop shop;
  const _ShopCard({required this.shop});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: BuddyColors.surface,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/marketplace/shops/${shop.handle}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Logo
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: BuddyColors.surfaceRaised,
                ),
                clipBehavior: Clip.antiAlias,
                child: shop.logoUrl != null && shop.logoUrl!.isNotEmpty
                    ? Image.network(shop.logoUrl!, fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(Icons.storefront, color: BuddyColors.textSecondary))
                    : const Icon(Icons.storefront, color: BuddyColors.textSecondary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(shop.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                        if (shop.isCertified)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: BuddyColors.green.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified, size: 12, color: BuddyColors.green),
                                const SizedBox(width: 4),
                                Text('Certified',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: BuddyColors.green)),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('@${shop.handle}',
                        style: const TextStyle(fontSize: 12, color: BuddyColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(shop.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: BuddyColors.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: BuddyColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyShopsState extends StatelessWidget {
  final VoidCallback onCreateTap;
  final VoidCallback onRegisterTap;
  const _EmptyShopsState({required this.onCreateTap, required this.onRegisterTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: BuddyColors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.storefront_outlined, size: 48, color: BuddyColors.green),
            ),
            const SizedBox(height: 24),
            const Text('No Shops Yet',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Create your first shop to start selling\nmeal plans, programmes, products, and events.',
              textAlign: TextAlign.center,
              style: TextStyle(color: BuddyColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.rocket_launch),
              label: const Text('Register as Creator'),
              onPressed: onRegisterTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: BuddyColors.green,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: onCreateTap,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: BuddyColors.green),
                foregroundColor: BuddyColors.green,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Set up a custom shop manually'),
            ),
          ],
        ),
      ),
    );
  }
}
