import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/api/api_client.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/auth_models.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/input.dart' show BuddyInput;

final _settingsAuthRepoProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(_settingsApiClientProvider).dio;
  return AuthRepository(dio);
});

final _settingsApiClientProvider = Provider<ApiClient>((_) => ApiClient());

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _currentPwCtrl = TextEditingController();
  final _newPwCtrl = TextEditingController();
  final _confirmPwCtrl = TextEditingController();
  bool _isChangingPassword = false;
  bool _isExporting = false;
  bool _isDeactivating = false;
  bool _isDeleting = false;

  @override
  void dispose() {
    _currentPwCtrl.dispose();
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
