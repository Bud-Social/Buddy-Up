import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/auth/auth_provider.dart';
import '../providers/settings_providers.dart';
import '../../../shared/navigation/business_roles.dart';
import '../../../shared/navigation/business_roles_provider.dart';
import '../../../shared/widgets/toast.dart';

/// Settings hub. Each section lives in its own sub-screen under
/// /settings/<section>; this page is a navigation list only.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: BuddyColors.surface,
        title: const Text('Sign Out?'),
        content: const Text('You will need to sign in again to use BuddyUp.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: BuddyColors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(settingsAuthRepoProvider).logout();
    } catch (_) {
      // Server-side revocation failed; still clear local tokens below.
    }
    await ref.read(authProvider.notifier).logout();
    if (context.mounted) {
      showToast(context, 'Signed out', type: ToastType.success);
    }
  }

  void _showHelpSheet(BuildContext context) {
    final links = <(String, String)>[
      ('Terms of Service', '/terms'),
      ('Privacy Policy', '/privacy'),
      ('Community Guidelines', '/community-guidelines'),
      ('Medical Disclaimer', '/medical-disclaimer'),
      ('Adult Content Policy', '/adult-content-policy'),
    ];
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Help & Safety', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            // Above the policy links, not below them: this is the entry point
            // for "a moderator did something to my account and I want to see
            // why and challenge it", which is a help-and-safety question
            // rather than a documents question.
            ListTile(
              leading: const Icon(Icons.gavel_outlined, color: BuddyColors.green),
              title: const Text('Moderation & appeals',
                  style: TextStyle(color: BuddyColors.green)),
              subtitle: const Text(
                'Warnings, suspensions and bans on your account — and how to '
                'appeal one',
                style: TextStyle(fontSize: 12, color: BuddyColors.textSecondary),
              ),
              trailing: const Icon(Icons.chevron_right, color: BuddyColors.textSecondary),
              onTap: () {
                Navigator.pop(sheetCtx);
                context.push('/settings/moderation');
              },
            ),
            const Divider(height: 1),
            for (final (label, route) in links)
              ListTile(
                title: Text(label, style: const TextStyle(color: BuddyColors.green)),
                trailing: const Icon(Icons.chevron_right, color: BuddyColors.textSecondary),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  context.push(route);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// The role switcher: every destination this operator holds, in one list.
  ///
  /// Built from the same [businessEntries] list the "Your business" tiles use, so
  /// a destination can never be reachable from one and missing from the other.
  void _showBusinessSwitcher(BuildContext context, List<BusinessEntry> entries) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  Icon(Icons.swap_horiz, color: BuddyColors.green, size: 20),
                  SizedBox(width: 10),
                  Text('Your business',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
            ),
            for (final entry in entries)
              ListTile(
                leading: Icon(_businessIcon(entry.key), color: BuddyColors.green),
                title: Text(entry.label,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(entry.subtitle,
                    style: const TextStyle(
                        fontSize: 11, color: BuddyColors.textSecondary)),
                trailing: const Icon(Icons.chevron_right,
                    color: BuddyColors.textSecondary, size: 20),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  context.push(entry.route);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(authProvider).profile;
    final user = ref.watch(authProvider).user;
    final entries = ref.watch(businessEntriesProvider);
    final displayName = profile?.displayName.isNotEmpty == true
        ? profile!.displayName
        : (user?.email ?? 'BuddyUp user');
    final subtitle = user?.email ?? '';
    final tileColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account header row → profile.
          Card(
            color: tileColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: BuddyColors.green.withValues(alpha: 0.2),
                backgroundImage: (profile?.avatarUrl.isNotEmpty ?? false)
                    ? NetworkImage(profile!.avatarUrl)
                    : null,
                child: (profile?.avatarUrl.isNotEmpty ?? false)
                    ? null
                    : Text(
                        displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: BuddyColors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
              ),
              title: Text(displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
              trailing: const Icon(Icons.chevron_right, color: BuddyColors.textSecondary),
              onTap: () => context.push('/profile'),
            ),
          ),
          const SizedBox(height: 12),
          _tile(context, tileColor, Icons.person_outline, 'Account',
              'Profile details, email, password', () => context.push('/settings/account')),
          _tile(context, tileColor, Icons.shield_outlined, 'Security',
              '2FA, biometric lock, device sessions', () => context.push('/settings/security')),
          _tile(context, tileColor, Icons.lock_outline, 'Privacy',
              'Visibility, active status, anonymous posting', () => context.push('/settings/privacy')),
          _tile(context, tileColor, Icons.notifications_outlined, 'Notifications',
              'Channels, per-type alerts, quiet hours',
              () => context.push('/settings/notifications')),
          _tile(context, tileColor, Icons.family_restroom, 'Family',
              user?.isAdult == true
                  ? 'Linked teens, activity, permissions'
                  : 'Guardian links and invites',
              () => context.push('/settings/family')),
          _tile(context, tileColor, Icons.palette_outlined, 'Appearance',
              'System, light or dark theme', () => context.push('/settings/appearance')),
          _tile(context, tileColor, Icons.folder_shared_outlined, 'Data & Privacy',
              'Export, consents, deactivate, delete', () => context.push('/settings/data')),
          _tile(context, tileColor, Icons.help_outline, 'Help & Safety',
              'Policies and guidelines', () => _showHelpSheet(context)),
          _tile(context, tileColor, Icons.block_outlined, 'Blocked Accounts',
              'People you have blocked', () => context.push('/settings/blocked')),
          // Role-driven group. Every entry is derived from real ownership data by
          // `businessRolesProvider`, and each of those probes resolves false on
          // failure — so this group can only ever *hide* an entry for a
          // half-rolled-out backend, never show one the user does not hold.
          // Nothing is rendered until every probe has settled, so the list does
          // not flicker as they land.
          if (entries.isNotEmpty) ...[
            const SizedBox(height: 4),
            _groupLabel(context, 'Your business'),
            for (final entry in entries)
              _tile(
                context,
                tileColor,
                _businessIcon(entry.key),
                entry.label,
                entry.subtitle,
                () => context.push(entry.route),
              ),
            _tile(
              context,
              tileColor,
              Icons.swap_horiz,
              'Switch role',
              'Everything you run, in one list',
              () => _showBusinessSwitcher(context, entries),
            ),
          ],
          // Staff-only surfaces. The tile is hidden entirely for non-staff, the
          // same way the web sidebar hides the admin link, and the console screen
          // re-checks `is_staff` because a deep link must not bypass it.
          if (user?.isStaff ?? false) ...[
            const SizedBox(height: 4),
            _groupLabel(context, 'Staff'),
            _tile(context, tileColor, Icons.admin_panel_settings_outlined,
                'Admin Console',
                'Staff only · users, orders, moderation, approvals, audit',
                () => context.push('/admin')),
          ],
          const SizedBox(height: 12),
          _tile(
            context,
            tileColor,
            Icons.logout,
            'Sign Out',
            'End this session',
            () => _signOut(context, ref),
            destructive: true,
          ),
        ],
      ),
    );
  }

  Widget _groupLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: BuddyColors.textSecondary,
        ),
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    Color tileColor,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool destructive = false,
  }) {
    final color = destructive ? BuddyColors.red : null;
    return Card(
      color: tileColor,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: color ?? BuddyColors.green),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: color,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, color: BuddyColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}

/// Icon for a business role entry.
IconData _businessIcon(BusinessRoleKey key) {
  switch (key) {
    case BusinessRoleKey.shop:
      return Icons.storefront_outlined;
    case BusinessRoleKey.events:
      return Icons.calendar_month_outlined;
    case BusinessRoleKey.gym:
      return Icons.fitness_center_outlined;
    case BusinessRoleKey.stations:
      return Icons.store_outlined;
    case BusinessRoleKey.courier:
      return Icons.pedal_bike_outlined;
  }
}
