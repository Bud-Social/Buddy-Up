import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/auth/auth_provider.dart';
import '../providers/settings_providers.dart';
import '../../../data/models/profile.dart';
import '../../../shared/widgets/button.dart';

/// Privacy: profile visibility, active status, anonymous posting.
class PrivacyScreen extends ConsumerStatefulWidget {
  const PrivacyScreen({super.key});

  @override
  ConsumerState<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends ConsumerState<PrivacyScreen> {
  String _privacyLevel = 'public';
  bool _showActiveStatus = true;
  bool? _anonymousPosting;
  bool _isSavingPrivacy = false;
  bool _privacySaved = false;
  bool _loadedFromProfile = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(authProvider).profile;
    if (profile != null) {
      _loadedFromProfile = true;
      _privacyLevel = profile.privacyLevel;
      _showActiveStatus = profile.showActiveStatus;
    }
  }

  Future<void> _savePrivacy() async {
    setState(() {
      _isSavingPrivacy = true;
      _privacySaved = false;
    });
    try {
      final repo = ref.read(settingsProfileRepoProvider);
      final updated = await repo.updateProfile(ProfileUpdatePayload(
        privacyLevel: _privacyLevel,
        showActiveStatus: _showActiveStatus,
        // Only send when the user touched it, so we never overwrite the
        // server value with a default.
        isAnonymousPosting: _anonymousPosting,
      ));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Profile Visibility',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'public', label: Text('Public')),
                      ButtonSegment(value: 'private', label: Text('Private')),
                    ],
                    selected: {_privacyLevel},
                    onSelectionChanged: (sel) =>
                        setState(() => _privacyLevel = sel.first),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Show Active Status', style: TextStyle(fontSize: 14)),
                    subtitle: const Text('Display when you are online',
                        style: TextStyle(color: BuddyColors.textSecondary, fontSize: 12)),
                    value: _showActiveStatus,
                    onChanged: (v) => setState(() => _showActiveStatus = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Anonymous Posting', style: TextStyle(fontSize: 14)),
                    subtitle: const Text(
                      'Post to the feed without showing your name',
                      style: TextStyle(color: BuddyColors.textSecondary, fontSize: 12),
                    ),
                    value: _anonymousPosting ?? false,
                    onChanged: _loadedFromProfile ? (v) => setState(() => _anonymousPosting = v) : null,
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
                    const Text('Privacy settings saved',
                        style: TextStyle(color: BuddyColors.green, fontSize: 12)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
