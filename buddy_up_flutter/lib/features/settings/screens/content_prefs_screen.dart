import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/profile.dart';
import '../../../shared/widgets/toast.dart';
import '../providers/settings_providers.dart';

/// Settings → Content Preferences: mature-content rating (synced to the
/// account) and a device-level profanity filter.
class ContentPrefsScreen extends ConsumerStatefulWidget {
  const ContentPrefsScreen({super.key});

  @override
  ConsumerState<ContentPrefsScreen> createState() => _ContentPrefsScreenState();
}

class _ContentPrefsScreenState extends ConsumerState<ContentPrefsScreen> {
  bool _saving = false;

  Future<void> _setMature(bool value) async {
    final auth = ref.read(authProvider);
    if (auth.user?.isAdult != true) {
      showToast(context, 'Mature content requires age verification as 18+.',
          type: ToastType.error);
      return;
    }
    final profile = auth.profile;
    if (profile == null) return;
    setState(() => _saving = true);
    try {
      final updated = await ref
          .read(settingsProfileRepoProvider)
          .updateProfile(ProfileUpdatePayload(
            contentRating: value ? 'mature' : 'general',
          ));
      await ref.read(authProvider.notifier).updateProfile(updated);
    } catch (_) {
      if (mounted) {
        showToast(context, 'Failed to update mature content setting',
            type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final isAdult = auth.user?.isAdult == true;
    final mature = (auth.profile?.contentRating ?? 'general') == 'mature';
    final profanity = ref.watch(profanityFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Content Preferences')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  value: mature,
                  onChanged: (!isAdult || _saving) ? null : _setMature,
                  title: const Text('Mature content',
                      style: TextStyle(fontSize: 14)),
                  subtitle: Text(
                    isAdult
                        ? 'Show sensitive health & transformation content (18+)'
                        : 'Available once your account is age-verified as 18+',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                if (!isAdult)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(
                      'Mature content is disabled for under-18 accounts. '
                      'Confirm your age with an ID or passport in Settings → '
                      'Verifications if this is incorrect.',
                      style: TextStyle(
                          fontSize: 11, color: BuddyColors.textSecondary),
                    ),
                  ),
                const Divider(height: 1),
                SwitchListTile(
                  value: profanity,
                  onChanged: (value) => ref
                      .read(profanityFilterProvider.notifier)
                      .setEnabled(value),
                  title: const Text('Profanity filter',
                      style: TextStyle(fontSize: 14)),
                  subtitle: const Text(
                    'Mask explicit language in post text on this device',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'The mature-content rating syncs to your account. The profanity '
            'filter applies to this device only.',
            style: TextStyle(fontSize: 11, color: BuddyColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
