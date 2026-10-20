import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/settings_providers.dart';

/// Appearance: theme mode picker wired to the existing themeModeProvider.
class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Appearance')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _option(
            context,
            ref,
            value: ThemeMode.system,
            groupValue: themeMode,
            icon: Icons.brightness_auto,
            title: 'System',
            subtitle: 'Match your device setting',
          ),
          _option(
            context,
            ref,
            value: ThemeMode.light,
            groupValue: themeMode,
            icon: Icons.light_mode_outlined,
            title: 'Light',
            subtitle: 'Bright theme',
          ),
          _option(
            context,
            ref,
            value: ThemeMode.dark,
            groupValue: themeMode,
            icon: Icons.dark_mode_outlined,
            title: 'Dark',
            subtitle: 'The classic BuddyUp green-on-dark',
          ),
          const SizedBox(height: 8),
          _AccessibilityCard(),
        ],
      ),
    );
  }

  Widget _option(
    BuildContext context,
    WidgetRef ref, {
    required ThemeMode value,
    required ThemeMode groupValue,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final selected = value == groupValue;
    return Card(
      color: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: selected
            ? const BorderSide(color: BuddyColors.green, width: 1.5)
            : BorderSide.none,
      ),
      child: ListTile(
        onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(value),
        leading: Icon(icon, color: selected ? BuddyColors.green : BuddyColors.textSecondary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(subtitle,
            style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 12)),
        trailing: selected
            ? const Icon(Icons.check_circle, color: BuddyColors.green)
            : const Icon(Icons.circle_outlined, color: BuddyColors.textSecondary),
      ),
    );
  }
}

/// Left-handed interaction mode + a live preview of the mirrored action row.
class _AccessibilityCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leftHanded = ref.watch(handednessProvider);
    return Card(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Left-handed mode',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      SizedBox(height: 2),
                      Text(
                        'Mirror post interaction buttons so they sit under a '
                        'left thumb.',
                        style: TextStyle(
                            color: BuddyColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: leftHanded,
                  onChanged: (value) =>
                      ref.read(handednessProvider.notifier).setLeftHanded(value),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Post interaction preview',
                style: TextStyle(
                    fontSize: 11, color: BuddyColors.textSecondary)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: BuddyColors.surfaceRaised,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                textDirection:
                    leftHanded ? TextDirection.rtl : TextDirection.ltr,
                children: const [
                  Icon(Icons.favorite_border,
                      size: 18, color: BuddyColors.textSecondary),
                  SizedBox(width: 18),
                  Icon(Icons.chat_bubble_outline,
                      size: 18, color: BuddyColors.textSecondary),
                  SizedBox(width: 18),
                  Icon(Icons.repeat,
                      size: 18, color: BuddyColors.textSecondary),
                  SizedBox(width: 18),
                  Icon(Icons.bookmark_border,
                      size: 18, color: BuddyColors.textSecondary),
                  Spacer(),
                  Icon(Icons.share_outlined,
                      size: 18, color: BuddyColors.textSecondary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
