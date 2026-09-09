import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/auth/biometric_provider.dart';
import '../providers/settings_providers.dart';
import '../../../data/models/device_session.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/input.dart';

/// Security: 2FA status + enable/disable, biometric app lock, and
/// device sessions (list, revoke, sign out everywhere).
class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  final _totpPasswordCtrl = TextEditingController();
  bool _isDisablingTotp = false;
  bool _isLoadingSessions = false;
  bool _isSigningOutAll = false;
  List<DeviceSession> _sessions = [];
  String? _sessionsError;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  @override
  void dispose() {
    _totpPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _isLoadingSessions = true;
      _sessionsError = null;
    });
    try {
      final sessions = await ref.read(settingsAuthRepoProvider).listSessions();
      if (mounted) setState(() => _sessions = sessions);
    } catch (e) {
      if (mounted) setState(() => _sessionsError = '$e');
    } finally {
      if (mounted) setState(() => _isLoadingSessions = false);
    }
  }

  Future<void> _revokeSession(DeviceSession session) async {
    try {
      await ref.read(settingsAuthRepoProvider).revokeSession(session.id);
      await _loadSessions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session revoked')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  Future<void> _signOutAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: BuddyColors.surface,
        title: const Text('Sign out all devices?'),
        content: const Text('Every signed-in session will be revoked, including this one.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: BuddyColors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out All'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _isSigningOutAll = true);
    try {
      await ref.read(settingsAuthRepoProvider).logoutAllDevices();
      await ref.read(authProvider.notifier).logout();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signed out of all devices')),
        );
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSigningOutAll = false);
    }
  }

  Future<void> _disableTotp() async {
    if (_totpPasswordCtrl.text.trim().isEmpty) return;
    setState(() => _isDisablingTotp = true);
    try {
      final repo = ref.read(settingsAuthRepoProvider);
      await repo.totpDisable({'password': _totpPasswordCtrl.text.trim()});
      final user = ref.read(authProvider).user;
      final profile = ref.read(authProvider).profile;
      if (user != null && profile != null) {
        await ref
            .read(authProvider.notifier)
            .setUserAndProfile(user.copyWith(totpEnabled: false), profile);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('2FA disabled')),
        );
        _totpPasswordCtrl.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isDisablingTotp = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final totpEnabled = user?.totpEnabled ?? false;
    final biometric = ref.watch(biometricProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Security')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.smartphone, size: 20, color: BuddyColors.green),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text('Two-Factor Authentication (2FA)',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                      if (totpEnabled)
                        const Icon(Icons.check_circle, size: 20, color: BuddyColors.green),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    totpEnabled
                        ? 'Your account is protected with an authenticator app.'
                        : 'Add an extra layer of security to your account.',
                    style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  if (totpEnabled) ...[
                    BuddyInput(
                      label: 'Current Password',
                      controller: _totpPasswordCtrl,
                      obscureText: true,
                    ),
                    const SizedBox(height: 8),
                    BuddyButton(
                      label: 'Disable 2FA',
                      variant: BuddyButtonVariant.destructive,
                      isLoading: _isDisablingTotp,
                      fullWidth: true,
                      onPressed: _disableTotp,
                    ),
                  ] else
                    BuddyButton(
                      label: 'Enable 2FA',
                      variant: BuddyButtonVariant.secondary,
                      icon: Icons.qr_code,
                      fullWidth: true,
                      // pushNamed does not work in a go_router app.
                      onPressed: () => context.push('/totp-setup'),
                    ),
                ],
              ),
            ),
            if (biometric.available) ...[
              const SizedBox(height: 12),
              _sectionCard(
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.fingerprint, size: 22, color: BuddyColors.green),
                  title: const Text('Biometric App Lock',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text(
                    'Require fingerprint or face unlock when opening BuddyUp.',
                    style: TextStyle(color: BuddyColors.textSecondary, fontSize: 12),
                  ),
                  value: biometric.enabled,
                  onChanged: (on) async {
                    final messenger = ScaffoldMessenger.of(context);
                    final ok = await ref.read(biometricProvider.notifier).setEnabled(on);
                    if (!ok) {
                      messenger.showSnackBar(
                        const SnackBar(
                            content: Text('Biometric authentication failed — lock not enabled')),
                      );
                    }
                  },
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(
                  child: Text('Device Sessions',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                TextButton.icon(
                  onPressed: _isLoadingSessions ? null : _loadSessions,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_isLoadingSessions)
              const Center(child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ))
            else if (_sessionsError != null)
              Text('Could not load sessions: $_sessionsError',
                  style: const TextStyle(color: BuddyColors.red, fontSize: 13))
            else if (_sessions.isEmpty)
              const Text('No other sessions found.',
                  style: TextStyle(color: BuddyColors.textSecondary, fontSize: 13))
            else
              ..._sessions.map(_sessionTile),
            const SizedBox(height: 12),
            BuddyButton(
              label: 'Sign Out All Devices',
              variant: BuddyButtonVariant.destructive,
              icon: Icons.logout,
              isLoading: _isSigningOutAll,
              fullWidth: true,
              onPressed: _signOutAll,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sessionTile(DeviceSession session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            session.isCurrent ? Icons.phone_android : Icons.devices_other,
            size: 22,
            color: session.isCurrent ? BuddyColors.green : BuddyColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.isCurrent ? '${session.deviceName} (this device)' : session.deviceName,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    if (session.location.isNotEmpty) session.location,
                    if (session.ipAddress.isNotEmpty) session.ipAddress,
                    if (session.lastActive.isNotEmpty) 'Last active ${_formatDate(session.lastActive)}',
                  ].join(' · '),
                  style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (!session.isCurrent)
            TextButton(
              onPressed: () => _revokeSession(session),
              style: TextButton.styleFrom(foregroundColor: BuddyColors.red),
              child: const Text('Revoke'),
            ),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}
