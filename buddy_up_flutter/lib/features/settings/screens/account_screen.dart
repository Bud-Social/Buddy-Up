import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/auth/auth_provider.dart';
import '../providers/settings_providers.dart';
import '../../../data/models/auth_models.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/input.dart';

/// Account: read-only profile basics, verification status, and the
/// password set/change flow (moved from the old settings monolith).
class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  final _currentPwCtrl = TextEditingController();
  final _newPwCtrl = TextEditingController();
  final _confirmPwCtrl = TextEditingController();
  bool _isChangingPassword = false;
  // Social sign-ups have no password yet — the current-password field hides
  // and the endpoint accepts a new password without it.
  bool? _hasPassword;

  @override
  void initState() {
    super.initState();
    _loadPasswordStatus();
  }

  @override
  void dispose() {
    _currentPwCtrl.dispose();
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPasswordStatus() async {
    try {
      final res = await ref.read(settingsAuthRepoProvider).passwordStatus();
      final data = (res is Map && res['data'] is Map) ? res['data'] as Map : {};
      if (mounted) setState(() => _hasPassword = data['has_password'] == true);
    } catch (_) {
      if (mounted) setState(() => _hasPassword = true);
    }
  }

  Future<void> _changePassword() async {
    if (_newPwCtrl.text != _confirmPwCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }
    setState(() => _isChangingPassword = true);
    try {
      final hasPassword = _hasPassword ?? true;
      final repo = ref.read(settingsAuthRepoProvider);
      if (hasPassword) {
        await repo.changePassword(ChangePasswordPayload(
          currentPassword: _currentPwCtrl.text,
          newPassword: _newPwCtrl.text,
        ));
      } else {
        await repo.setPassword(<String, dynamic>{'new_password': _newPwCtrl.text});
      }
      if (mounted) {
        setState(() => _hasPassword = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(hasPassword ? 'Password changed successfully' : 'Password set successfully'),
            backgroundColor: BuddyColors.green,
          ),
        );
        _currentPwCtrl.clear();
        _newPwCtrl.clear();
        _confirmPwCtrl.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isChangingPassword = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(authProvider).profile;
    final verificationStatus = profile?.verificationStatus ?? 'none';
    final labels = <String, String>{
      'none': 'Not verified',
      'email': 'Email verified',
      'id': 'ID verified',
      'trainer': 'Trainer certified',
      'practitioner': 'Health practitioner',
      'shop': 'Shop verified',
      'gym': 'Gym verified',
    };
    final verificationLabel = labels[verificationStatus] ?? verificationStatus;

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row('Username', profile?.username ?? ''),
                  _row('Display name', profile?.displayName ?? ''),
                  _row('Role', profile?.role ?? ''),
                  _row('Location', [
                    profile?.locationCity,
                    profile?.locationCountry,
                  ].whereType<String>().where((s) => s.isNotEmpty).join(', ')),
                  const SizedBox(height: 8),
                  BuddyButton(
                    label: 'Edit Profile',
                    variant: BuddyButtonVariant.secondary,
                    icon: Icons.edit_outlined,
                    fullWidth: true,
                    onPressed: () => context.push('/profile'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _sectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        verificationStatus == 'none' ? Icons.verified_outlined : Icons.verified,
                        size: 20,
                        color: verificationStatus == 'none' ? BuddyColors.textSecondary : BuddyColors.green,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(verificationLabel,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  BuddyButton(
                    label: verificationStatus == 'none' ? 'Complete Verification' : 'Manage Verification',
                    variant: BuddyButtonVariant.secondary,
                    icon: Icons.badge_outlined,
                    fullWidth: true,
                    onPressed: () => context.push('/verification'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _sectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  if (_hasPassword == false)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text(
                        'You signed up with a social account — set a password to also log in with your email.',
                        style: TextStyle(color: BuddyColors.textSecondary, fontSize: 12),
                      ),
                    ),
                  if (_hasPassword != false)
                    BuddyInput(label: 'Current Password', controller: _currentPwCtrl, obscureText: true),
                  if (_hasPassword != false) const SizedBox(height: 12),
                  BuddyInput(label: 'New Password', controller: _newPwCtrl, obscureText: true),
                  const SizedBox(height: 12),
                  BuddyInput(label: 'Confirm New Password', controller: _confirmPwCtrl, obscureText: true),
                  const SizedBox(height: 12),
                  BuddyButton(
                    label: (_hasPassword == false) ? 'Set Password' : 'Change Password',
                    isLoading: _isChangingPassword,
                    fullWidth: true,
                    onPressed: _changePassword,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 13)),
          ),
          Expanded(
            child: Text(value.isEmpty ? '—' : value,
                style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
