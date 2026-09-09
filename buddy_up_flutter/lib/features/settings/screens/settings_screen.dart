import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/auth/auth_provider.dart';
import '../providers/settings_providers.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(authProvider).profile;
    final user = ref.watch(authProvider).user;
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
