import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/auth/auth_provider.dart';
import '../providers/settings_providers.dart';
import '../../../shared/widgets/button.dart';

/// Data & Privacy: data export (+status), consent summary, deactivate,
/// and permanent delete (POST /auth/delete/ with the typed confirmation).
class DataScreen extends ConsumerStatefulWidget {
  const DataScreen({super.key});

  @override
  ConsumerState<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends ConsumerState<DataScreen> {
  bool _isExporting = false;
  bool _isDeactivating = false;
  bool _isDeleting = false;
  Map<String, dynamic>? _exportStatus;
  Map<String, dynamic>? _consentStatus;

  @override
  void initState() {
    super.initState();
    _loadStatuses();
  }

  Future<void> _loadStatuses() async {
    try {
      final repo = ref.read(settingsAuthRepoProvider);
      final export = await repo.exportDataStatus();
      final consent = await repo.consentStatus();
      if (mounted) {
        setState(() {
          _exportStatus = _payload(export);
          _consentStatus = _payload(consent);
        });
      }
    } catch (_) {
      // Status panels are informational — leave them blank on failure.
    }
  }

  Map<String, dynamic>? _payload(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is Map<String, dynamic>) return data;
      return raw;
    }
    return null;
  }

  Future<void> _exportData() async {
    setState(() => _isExporting = true);
    try {
      final repo = ref.read(settingsAuthRepoProvider);
      await repo.exportData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data export requested. Check your email.')),
        );
      }
      await _loadStatuses();
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
        content: const Text(
            'This will deactivate your account. You can reactivate by logging in again.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          BuddyButton(label: 'Deactivate', onPressed: () => Navigator.pop(ctx, true)),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _isDeactivating = true);
    try {
      final repo = ref.read(settingsAuthRepoProvider);
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
    final phraseCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    bool phraseOk = false;
    bool passwordOk = false;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: BuddyColors.surface,
          title: const Text('Permanently Delete Account?'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This will permanently delete your account and all data. This cannot be undone.',
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: (v) => setDialogState(() => phraseOk = v.trim() == 'delete my account'),
                  decoration: const InputDecoration(
                    labelText: "Type 'delete my account' to confirm",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordCtrl,
                  obscureText: true,
                  onChanged: (v) => setDialogState(() => passwordOk = v.isNotEmpty),
                  decoration: const InputDecoration(
                    labelText: 'Current password',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            BuddyButton(
              label: 'Delete Forever',
              variant: BuddyButtonVariant.destructive,
              onPressed: (phraseOk && passwordOk) ? () => Navigator.pop(ctx, true) : null,
            ),
          ],
        ),
      ),
    );
    phraseCtrl.dispose();
    passwordCtrl.dispose();
    if (confirmed != true) return;
    setState(() => _isDeleting = true);
    try {
      final repo = ref.read(settingsAuthRepoProvider);
      // Backend contract: POST /auth/delete/ with
      // {confirm: 'delete my account', current_password}.
      await repo.deleteAccount(<String, dynamic>{
        'confirm': 'delete my account',
        'current_password': passwordCtrl.text,
      });
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
    final exportReady = _exportStatus?['ready'] == true;
    final exportFilename = _exportStatus?['filename']?.toString() ?? '';
    final exportCreated = _exportStatus?['created_at']?.toString() ?? '';
    final consents = <String, dynamic>{...?_consentStatus}
      ..removeWhere((k, v) => v is! bool);

    return Scaffold(
      appBar: AppBar(title: const Text('Data & Privacy')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Export Your Data',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                if (_exportStatus != null)
                  Text(
                    exportReady
                        ? 'Your export is ready: $exportFilename${exportCreated.isNotEmpty ? ' (generated $exportCreated)' : ''}'
                        : 'No export ready yet. Request one and it will be emailed to you.',
                    style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 13),
                  )
                else
                  const Text(
                    'Request a copy of your data. It will be emailed to you.',
                    style: TextStyle(color: BuddyColors.textSecondary, fontSize: 13),
                  ),
                const SizedBox(height: 12),
                BuddyButton(
                  label: 'Export My Data',
                  variant: BuddyButtonVariant.secondary,
                  isLoading: _isExporting,
                  icon: Icons.download,
                  fullWidth: true,
                  onPressed: _exportData,
                ),
              ],
            ),
          ),
          if (consents.isNotEmpty) ...[
            const SizedBox(height: 12),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Consents',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ...consents.entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Icon(
                            e.value == true ? Icons.check_circle : Icons.cancel,
                            size: 16,
                            color: e.value == true ? BuddyColors.green : BuddyColors.red,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _humanize(e.key),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Danger Zone',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: BuddyColors.red)),
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
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
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

  String _humanize(String key) {
    if (key.isEmpty) return key;
    final spaced = key.replaceAll('_', ' ');
    return spaced[0].toUpperCase() + spaced.substring(1);
  }
}
