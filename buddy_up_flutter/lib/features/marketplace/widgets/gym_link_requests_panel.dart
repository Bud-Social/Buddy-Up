import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/page_loader.dart';
import '../providers/marketplace_provider.dart';
import '../../../data/models/marketplace.dart';

/// The two-step gym↔shop approval panel.
///
/// Gym proposes the link, shop owner/manager confirms (one tap). A pending
/// entry shows in the inbox; tapped through it flips the link to `active` and
/// unlocks the shop's attribution panel inside the gym's revenue view.
///
/// [shopHandle] scopes the list to one shop (manage console use case); leave
/// null to show every pending/active/declined link the caller can see
/// (My Shops inbox use case).
class GymLinkRequestsPanel extends ConsumerWidget {
  final String? shopHandle;

  const GymLinkRequestsPanel({super.key, this.shopHandle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linksAsync = ref.watch(shopGymLinksProvider(shopHandle));

    return linksAsync.when(
      loading: () => const PageLoader(fullScreen: false),
      error: (error, _) => ErrorView(
        message: 'Could not load gym link requests.',
        onRetry: () => ref.invalidate(shopGymLinksProvider(shopHandle)),
      ),
      data: (links) => links.isEmpty
          ? _Empty(shopHandle: shopHandle)
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: [
                for (final link in links) _GymLinkCard(link: link, shopHandle: shopHandle),
              ],
            ),
    );
  }
}

class _Empty extends StatelessWidget {
  final String? shopHandle;

  const _Empty({this.shopHandle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        children: [
          const Icon(Icons.link_off_outlined, size: 40, color: BuddyColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            shopHandle == null ? 'No gym link requests yet' : 'No link requests for this shop',
            style: const TextStyle(fontWeight: FontWeight.w600, color: BuddyColors.textPrimary),
          ),
          const SizedBox(height: 6),
          const Text(
            'A gym can ask to link your shop for attribution; approving is one tap.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: BuddyColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _GymLinkCard extends ConsumerWidget {
  final GymLinkRequest link;
  final String? shopHandle;

  const _GymLinkCard({required this.link, required this.shopHandle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(marketplaceRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    String title;
    Color accent;
    switch (link.status) {
      case 'active':
        title = 'Linked — attribution is on';
        accent = BuddyColors.green;
      case 'declined':
        title = 'Declined by the shop';
        accent = BuddyColors.red;
      default:
        title = 'Waiting on the shop to approve';
        accent = BuddyColors.gold;
    }

    Future<void> respond(String action) async {
      try {
        await repo.respondToGymLink(link.id, {'action': action});
        ref.invalidate(shopGymLinksProvider(shopHandle));
        ref.invalidate(shopGymLinksProvider(null));
        messenger.showSnackBar(
          SnackBar(
            content: Text(action == 'accept' ? 'Gym link approved.' : 'Gym link declined.'),
            backgroundColor: accent,
          ),
        );
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Could not $action the link: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    return Card(
      color: BuddyColors.surface,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: BuddyColors.surfaceRaised,
                  backgroundImage:
                      link.gymAvatar.isNotEmpty ? NetworkImage(link.gymAvatar) : null,
                  child: link.gymAvatar.isEmpty
                      ? const Icon(Icons.fitness_center, size: 18, color: BuddyColors.textSecondary)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(link.gymName,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      Text('@${link.gymHandle}',
                          style: const TextStyle(fontSize: 11, color: BuddyColors.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    link.status.toUpperCase(),
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: accent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 11, color: BuddyColors.textSecondary)),
            if (link.status == 'pending') ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => respond('accept'),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BuddyColors.green,
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => respond('decline'),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Decline'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: BuddyColors.red,
                        side: const BorderSide(color: BuddyColors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
