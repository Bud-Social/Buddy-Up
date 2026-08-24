import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/marketplace_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/marketplace.dart';

class ShopDetailScreen extends ConsumerWidget {
  final String handle;
  const ShopDetailScreen({super.key, required this.handle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopAsync = ref.watch(userShopProvider(handle));

    return shopAsync.when(
      data: (response) {
        final shop = response.shop;
        final hasItems = response.mealPlans.isNotEmpty ||
            response.programmes.isNotEmpty ||
            response.events.isNotEmpty ||
            response.products.isNotEmpty;
        return Scaffold(
          backgroundColor: BuddyColors.black,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: BuddyColors.surface,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (shop.bannerUrl != null && shop.bannerUrl!.isNotEmpty)
                        Image.network(shop.bannerUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                                  color: BuddyColors.surfaceRaised,
                                ))
                      else
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                BuddyColors.green.withValues(alpha: 0.3),
                                BuddyColors.surface,
                              ],
                            ),
                          ),
                        ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black54],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: BuddyColors.surface,
                                border: Border.all(color: Colors.white24, width: 1.5),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: shop.logoUrl != null && shop.logoUrl!.isNotEmpty
                                  ? Image.network(shop.logoUrl!, fit: BoxFit.cover)
                                  : const Icon(Icons.storefront, size: 32),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Text(shop.name,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18)),
                                    if (shop.isCertified) ...[
                                      const SizedBox(width: 6),
                                      const Icon(Icons.verified,
                                          color: BuddyColors.green, size: 18),
                                    ],
                                  ],
                                ),
                                Text('@${shop.handle}',
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'certify') {
                        context.push('/marketplace/shops/$handle/certify');
                      }
                    },
                    itemBuilder: (_) => [
                      if (!shop.isCertified)
                        const PopupMenuItem(value: 'certify', child: Text('Apply for Certification')),
                    ],
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (shop.description.isNotEmpty) ...[
                        Text(shop.description,
                            style: const TextStyle(
                                color: BuddyColors.textSecondary, height: 1.5)),
                        const SizedBox(height: 20),
                      ],
                      // Contact info
                      if (shop.contactEmail.isNotEmpty || shop.websiteUrl.isNotEmpty) ...[
                        const Text('Contact',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        if (shop.contactEmail.isNotEmpty)
                          _infoRow(Icons.email_outlined, shop.contactEmail),
                        if (shop.contactPhone.isNotEmpty)
                          _infoRow(Icons.phone_outlined, shop.contactPhone),
                        if (shop.websiteUrl.isNotEmpty)
                          _infoRow(Icons.language_outlined, shop.websiteUrl),
                        const SizedBox(height: 20),
                      ],
                      // Items
                      if (hasItems) ...[
                        const Text('Products & Services',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        if (response.mealPlans.isNotEmpty) ...[
                          _sectionHeader('Meal Plans (${response.mealPlans.length})'),
                          ...response.mealPlans.map((mp) => _itemCard(
                            context,
                            mp.title,
                            mp.coverImageUrl,
                            '/marketplace/meal-plans/${mp.id}',
                            subtitle: mp.dietType,
                            badge: '${mp.purchaseCount} sold',
                          )),
                        ],
                        if (response.programmes.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _sectionHeader('Programmes (${response.programmes.length})'),
                          ...response.programmes.map((p) => _itemCard(
                            context,
                            p.title,
                            p.coverImageUrl,
                            '/marketplace/programmes/${p.id}',
                            subtitle: p.category,
                            badge: '${p.purchaseCount} sold',
                          )),
                        ],
                        if (response.events.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _sectionHeader('Events (${response.events.length})'),
                          ...response.events.map((e) => _itemCard(
                            context,
                            e.title,
                            e.coverImageUrl,
                            '/marketplace/events/${e.id}',
                            subtitle: e.eventType.replaceAll('_', ' '),
                            badge: '${e.attendeeCount} attending',
                          )),
                        ],
                        if (response.products.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _sectionHeader('Products (${response.products.length})'),
                          ...response.products.map((p) => _itemCard(
                            context,
                            p.name,
                            p.imageUrl,
                            '/marketplace/products/${p.id}',
                            subtitle: p.brand,
                          )),
                        ],
                        const SizedBox(height: 24),
                      ],
                      if (!hasItems)
                        Container(
                          padding: const EdgeInsets.all(24),
                          child: const Column(
                            children: [
                              Icon(Icons.storefront_outlined, size: 48, color: BuddyColors.textSecondary),
                              SizedBox(height: 12),
                              Text('No items yet', style: TextStyle(color: BuddyColors.textSecondary)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Shop')),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: BuddyColors.textSecondary)),
    );
  }

  Widget _itemCard(BuildContext context, String title, String imageUrl, String route,
      {String? subtitle, String? badge}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: BuddyColors.surface,
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imageUrl.isNotEmpty
              ? Image.network(imageUrl, width: 48, height: 48, fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(width: 48, height: 48, color: BuddyColors.surfaceRaised,
                      child: const Icon(Icons.image, size: 20, color: BuddyColors.textSecondary)))
              : Container(width: 48, height: 48, color: BuddyColors.surfaceRaised,
                  child: const Icon(Icons.image, size: 20, color: BuddyColors.textSecondary)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
        trailing: badge != null
            ? Text(badge, style: const TextStyle(fontSize: 11, color: BuddyColors.green, fontWeight: FontWeight.w600))
            : null,
        onTap: () => context.push(route),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: BuddyColors.textSecondary),
          const SizedBox(width: 8),
          Flexible(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
