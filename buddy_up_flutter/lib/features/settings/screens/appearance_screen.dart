import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app.dart';
import '../../../core/theme/app_theme.dart';

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
