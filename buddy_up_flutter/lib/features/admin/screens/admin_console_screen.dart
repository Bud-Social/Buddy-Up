import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/error_view.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_widgets.dart';

/// Staff-gated admin console for `/api/v1/portal/**`.
///
/// Read-mostly by design: the web console is the primary surface, so this
/// mirrors its capabilities rather than inventing new ones. Gym and community
/// rows expose `member_count` and nothing else — a roster is deliberately not
/// reachable from here.
class AdminConsoleScreen extends ConsumerWidget {
  const AdminConsoleScreen({super.key});

  static const List<({String route, String label, String blurb, IconData icon})>
      sections = [
    (
      route: '/admin/users',
      label: 'Users',
      blurb: 'Search, inspect and suspend accounts',
      icon: Icons.people_alt_outlined
    ),
    (
      route: '/admin/shops',
      label: 'Shops',
      blurb: 'Shops plus the Buddy Up certification queue',
      icon: Icons.storefront_outlined
    ),
    (
      route: '/admin/orders',
      label: 'Orders',
      blurb: 'Platform-wide orders and status actions',
      icon: Icons.shopping_bag_outlined
    ),
    (
      route: '/admin/gyms',
      label: 'Gyms',
      blurb: 'Verification and access (count only, no roster)',
      icon: Icons.fitness_center_outlined
    ),
    (
      route: '/admin/communities',
      label: 'Communities',
      blurb: 'Group triage including private ones (count only)',
      icon: Icons.groups_outlined
    ),
    (
      route: '/admin/stations',
      label: 'Stations',
      blurb: 'Pickup stations and station applications',
      icon: Icons.store_outlined
    ),
    (
      route: '/admin/delivery',
      label: 'Delivery',
      blurb: 'Couriers and courier applications',
      icon: Icons.local_shipping_outlined
    ),
    (
      route: '/admin/wallet',
      label: 'Wallet',
      blurb: 'Transactions and reconciliation (read only)',
      icon: Icons.payments_outlined
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isStaff = ref.watch(isStaffProvider);
    final cs = Theme.of(context).colorScheme;

    if (!isStaff) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin Console')),
        body: const ErrorView(
          message: 'Staff access is required for the admin console. If you are '
              'staff, sign in again.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Console')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const AdminPageHeader(
            title: 'Platform administration',
            description: 'Staff only. Read-mostly — the web console is the '
                'primary surface.',
          ),
          const SizedBox(height: 16),
          for (final section in sections)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => context.push(section.route),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: cs.outline.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      Icon(section.icon, size: 20, color: BuddyColors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              section.label,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              section.blurb,
                              style: TextStyle(
                                  fontSize: 12, color: cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          size: 20, color: BuddyColors.textSecondary),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: BuddyColors.gold.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: BuddyColors.gold.withValues(alpha: 0.25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, size: 14, color: BuddyColors.gold),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'A 403 on any page means the server rejected this session as '
                    'non-staff. Nothing on this screen can change that.',
                    style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
