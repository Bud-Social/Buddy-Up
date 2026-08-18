import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/api/api_client.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/models/auth_models.dart';
import '../../../data/models/profile.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/input.dart' show BuddyInput;

final _settingsAuthRepoProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(_settingsApiClientProvider).dio;
  return AuthRepository(dio);
});

final _settingsApiClientProvider = Provider<ApiClient>((_) => ApiClient());

final _settingsProfileRepoProvider = Provider<ProfileRepository>((ref) {
  final dio = ref.watch(_settingsApiClientProvider).dio;
  return ProfileRepository(dio);
});

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _currentPwCtrl = TextEditingController();
  final _newPwCtrl = TextEditingController();
  final _confirmPwCtrl = TextEditingController();
  final _totpPasswordCtrl = TextEditingController();
  bool _isChangingPassword = false;
  bool _isExporting = false;
  bool _isDeactivating = false;
  bool _isDeleting = false;
  bool _isDisablingTotp = false;
  bool _isSavingPrivacy = false;
  bool _privacySaved = false;
  String _privacyLevel = 'public';
  bool _showActiveStatus = true;

  @override
  void dispose() {
    _currentPwCtrl.dispose();
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    _totpPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _disableTotp() async {
    if (_totpPasswordCtrl.text.trim().isEmpty) return;
    setState(() => _isDisablingTotp = true);
    try {
      final repo = ref.read(_settingsAuthRepoProvider);
      await repo.totpDisable({'password': _totpPasswordCtrl.text.trim()});
      final user = ref.read(authProvider).user;
      if (user != null) {
        await ref.read(authProvider.notifier).setUserAndProfile(user.copyWith(totpEnabled: false), ref.read(authProvider).profile!);
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

  Future<void> _savePrivacy() async {
    setState(() {
      _isSavingPrivacy = true;
      _privacySaved = false;
    });
    try {
      final repo = ref.read(_settingsProfileRepoProvider);
      final updated = await repo.updateProfile(
        ProfileUpdatePayload(
          privacyLevel: _privacyLevel,
          showActiveStatus: _showActiveStatus,
        ),
      );
      await ref.read(authProvider.notifier).updateProfile(updated);
      if (mounted) setState(() => _privacySaved = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingPrivacy = false);
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
      final repo = ref.read(_settingsAuthRepoProvider);
      await repo.changePassword(ChangePasswordPayload(
        currentPassword: _currentPwCtrl.text,
        newPassword: _newPwCtrl.text,
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully')),
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

  Future<void> _exportData() async {
    setState(() => _isExporting = true);
    try {
      final repo = ref.read(_settingsAuthRepoProvider);
      await repo.exportData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data export requested. Check your email.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _deactivateAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: BuddyColors.surface,
        title: const Text('Deactivate Account?'),
        content: const Text('This will deactivate your account. You can reactivate by logging in again.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          BuddyButton(label: 'Deactivate', onPressed: () => Navigator.pop(ctx, true)),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _isDeactivating = true);
    try {
      final repo = ref.read(_settingsAuthRepoProvider);
      await repo.deactivateAccount();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account deactivated')),
        );
        ref.read(authProvider.notifier).logout();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeactivating = false);
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: BuddyColors.surface,
        title: const Text('Permanently Delete Account?'),
        content: const Text('This will permanently delete your account and all data. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          BuddyButton(label: 'Delete Forever', variant: BuddyButtonVariant.destructive, onPressed: () => Navigator.pop(ctx, true)),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _isDeleting = true);
    try {
      final repo = ref.read(_settingsAuthRepoProvider);
      await repo.deleteAccount();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account deleted permanently')),
        );
        ref.read(authProvider.notifier).logout();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  Widget _buildSecuritySection(bool totpEnabled) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BuddyColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.smartphone, size: 20, color: BuddyColors.green),
              const SizedBox(width: 10),
              const Expanded(child: Text('Two-Factor Authentication (2FA)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
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
              onPressed: () => Navigator.of(context).pushNamed('/totp-setup'),
            ),
        ],
      ),
    );
  }

  Widget _buildVerificationSection(String verificationStatus) {
    final labels = <String, String>{
      'none': 'Not verified',
      'email': 'Email verified',
      'id': 'ID verified',
      'trainer': 'Trainer certified',
      'practitioner': 'Health practitioner',
      'shop': 'Shop verified',
      'gym': 'Gym verified',
    };
    final label = labels[verificationStatus] ?? verificationStatus;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BuddyColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
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
              Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
            ],
          ),
          const SizedBox(height: 12),
          BuddyButton(
            label: verificationStatus == 'none' ? 'Complete Verification' : 'Manage Verification',
            variant: BuddyButtonVariant.secondary,
            icon: Icons.badge_outlined,
            fullWidth: true,
            onPressed: () => Navigator.of(context).pushNamed('/verification'),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BuddyColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Profile Visibility', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'public', label: Text('Public')),
              ButtonSegment(value: 'private', label: Text('Private')),
            ],
            selected: {_privacyLevel},
            onSelectionChanged: (sel) => setState(() => _privacyLevel = sel.first),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Show Active Status', style: TextStyle(fontSize: 14)),
            subtitle: const Text('Display when you are online', style: TextStyle(color: BuddyColors.textSecondary, fontSize: 12)),
            value: _showActiveStatus,
            activeTrackColor: BuddyColors.green,
            onChanged: (v) => setState(() => _showActiveStatus = v),
          ),
          const SizedBox(height: 4),
          BuddyButton(
            label: 'Save Privacy Settings',
            variant: BuddyButtonVariant.secondary,
            isLoading: _isSavingPrivacy,
            fullWidth: true,
            onPressed: _savePrivacy,
          ),
          if (_privacySaved) ...[
            const SizedBox(height: 8),
            const Text('Privacy settings saved', style: TextStyle(color: BuddyColors.green, fontSize: 12)),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final profile = ref.watch(authProvider).profile;
    if (profile != null && _privacyLevel == 'public' && profile.privacyLevel == 'private') {
      _privacyLevel = profile.privacyLevel;
      _showActiveStatus = profile.showActiveStatus;
    }
    final totpEnabled = user?.totpEnabled ?? false;
    final verificationStatus = profile?.verificationStatus ?? 'none';
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Security', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildSecuritySection(totpEnabled),
            const SizedBox(height: 32),
            const Text('Verification', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildVerificationSection(verificationStatus),
            const SizedBox(height: 32),
            const Text('Privacy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildPrivacySection(),
            const SizedBox(height: 32),
            const Text('Change Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            BuddyInput(label: 'Current Password', controller: _currentPwCtrl, obscureText: true),
            const SizedBox(height: 12),
            BuddyInput(label: 'New Password', controller: _newPwCtrl, obscureText: true),
            const SizedBox(height: 12),
            BuddyInput(label: 'Confirm New Password', controller: _confirmPwCtrl, obscureText: true),
            const SizedBox(height: 12),
            BuddyButton(
              label: 'Change Password',
              isLoading: _isChangingPassword,
              onPressed: _changePassword,
            ),
            const SizedBox(height: 32),
            const Text('Data', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            BuddyButton(
              label: 'Export My Data',
              variant: BuddyButtonVariant.secondary,
              isLoading: _isExporting,
              icon: Icons.download,
              fullWidth: true,
              onPressed: _exportData,
            ),
            const SizedBox(height: 32),
            const Text('Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            BuddyButton(
              label: 'Deactivate Account',
              variant: BuddyButtonVariant.destructive,
              isLoading: _isDeactivating,
              icon: Icons.person_remove,
              fullWidth: true,
              onPressed: _deactivateAccount,
            ),
            const SizedBox(height: 12),
            BuddyButton(
              label: 'Delete Account Permanently',
              variant: BuddyButtonVariant.destructive,
              isLoading: _isDeleting,
              icon: Icons.delete_forever,
              fullWidth: true,
              onPressed: _deleteAccount,
            ),
          ],
        ),
      ),
    );
  }
}
