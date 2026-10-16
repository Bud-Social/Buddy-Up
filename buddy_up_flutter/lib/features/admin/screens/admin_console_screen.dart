import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/error_view.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_widgets.dart';

/// Staff-gated admin console for `/api/v1/portal/**`, `/governance/**` and
/// `/moderation/**`.
///
/// The first block is the day-to-day read-and-act surface. The second is
/// governance — the routes that decide who may use the first block and record
/// what was done — kept as its own group because a support agent reading this
/// list should not have to infer that "Approvals" is a different kind of thing
/// from "Orders".
///
/// Read-mostly by design on the portal half: the web console is the primary
/// surface, so this mirrors its capabilities rather than inventing new ones.
/// Gym and community rows expose `member_count` and nothing else — a roster is
/// deliberately not reachable from here.
class AdminConsoleScreen extends ConsumerWidget {
  const AdminConsoleScreen({super.key});

  static const List<({String route, String label, String blurb, IconData icon})>
      sections = [
    // Leads the console. It used to be filed third, under PLATFORM ANALYTICS,
    // as "Platform overview" -- so a staff user tapping into the console saw
    // fourteen tiles before the word overview, and the console's own front door
    // showed an index instead of a summary. Same destination, listed first.
    (
      route: '/admin/analytics',
      label: 'Overview',
      blurb: 'Platform health, with every figure labelled by its window',
      icon: Icons.query_stats_outlined
    ),
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

  /// The governance destinations: the routes that decide who may use the blocks
  /// above, and that record what was done to the ones who did.
  ///
  /// Grouped separately rather than appended because they are a different kind
  /// of thing. "Orders" is a queue you work; "Approvals" is a queue where the
  /// only safe action is to be somebody else from the requester.
  static const List<({String route, String label, String blurb, IconData icon})>
      governanceSections = [
    (
      route: '/admin/moderation',
      label: 'Moderation',
      blurb: 'Flag queue, reports, discipline and commendations',
      icon: Icons.shield_outlined
    ),
    (
      route: '/admin/approvals',
      label: 'Approvals',
      blurb: 'Two-person queue — a ban applies only when approved',
      icon: Icons.how_to_reg_outlined
    ),
    (
      route: '/admin/staff-roles',
      label: 'Staff Roles',
      blurb: 'Who may use the console, and with which scopes',
      icon: Icons.badge_outlined
    ),
    (
      route: '/admin/audit',
      label: 'Audit Log',
      blurb: 'Every staff action, with before/after and CSV export',
      icon: Icons.history
    ),
    (
      route: '/admin/emails',
      label: 'Email Console',
      blurb: 'Message a user, and read what was sent',
      icon: Icons.outbox_outlined
    ),
    (
      route: '/admin/verification',
      label: 'Verification',
      blurb: 'Identity and professional reviews — a decision needs two people',
      icon: Icons.badge_outlined
    ),
  ];

  /// The `/portal/analytics/**` reports.
  ///
  /// A group of its own because these read differently from every other tile on
  /// this screen: they are aggregates over tables the portal never exposes,
  /// each figure carries its own window, and several of them decline to answer
  /// at all (`trending?kind=pages`). Filing them under "Users" or "Orders"
  /// would make them look like another queue to work.
  static const List<({String route, String label, String blurb, IconData icon})>
      analyticsSections = [
    // "Overview" lives at the top of the console now; repeating it here gave
    // one destination two names depending on which group you found it in.
    (
      route: '/admin/analytics/trends',
      label: 'Trends',
      blurb: 'One metric over time, bucketed and zero-filled',
      icon: Icons.timeline_outlined
    ),
    (
      route: '/admin/analytics/trending',
      label: 'Trending',
      blurb: 'Top posts, services, events and hashtags in the window',
      icon: Icons.local_fire_department_outlined
    ),
    (
      route: '/admin/analytics/ai-quality',
      label: 'AI quality',
      blurb: 'Fallback rate, correction proxy, latency and cost per model',
      icon: Icons.smart_toy_outlined
    ),
    (
      route: '/admin/analytics/predictive',
      label: 'Recommendation signals',
      blurb: 'Observed feedback and impressions — no forecast',
      icon: Icons.insights_outlined
    ),
  ];

  static Widget _sectionTile(
    BuildContext context,
    ColorScheme cs,
    ({String route, String label, String blurb, IconData icon}) section,
  ) {
    return InkWell(
      onTap: () => context.push(section.route),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
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
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                size: 20, color: BuddyColors.textSecondary),
          ],
        ),
      ),
    );
  }

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
            description: 'Staff only. The portal blocks are read-mostly — the '
                'web console is the primary surface.',
          ),
          const SizedBox(height: 16),
          for (final section in sections)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _sectionTile(context, cs, section),
            ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 0, 2, 8),
            child: Text(
              'GOVERNANCE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          for (final section in governanceSections)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _sectionTile(context, cs, section),
            ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 0, 2, 8),
            child: Text(
              'PLATFORM ANALYTICS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          for (final section in analyticsSections)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _sectionTile(context, cs, section),
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
