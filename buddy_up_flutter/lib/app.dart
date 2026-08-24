import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/auth/auth_provider.dart';
import 'core/auth/biometric_provider.dart';
import 'features/notifications/services/push_notification_service.dart';
import 'features/messaging/widgets/call_host.dart';
import 'router.dart';

// ── Simple theme-mode notifier ─────────────────────────────────────────────────
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.dark;

  void setThemeMode(ThemeMode mode) => state = mode;
  void toggle() => state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class BuddyUpApp extends ConsumerStatefulWidget {
  const BuddyUpApp({super.key});

  @override
  ConsumerState<BuddyUpApp> createState() => _BuddyUpAppState();
}

class _BuddyUpAppState extends ConsumerState<BuddyUpApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(pushNotificationServiceProvider).initialize();
    });
    // Trigger biometric state load (and lock if enabled) at startup.
    ref.read(biometricProvider.notifier);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeModeProvider);
    final biometric = ref.watch(biometricProvider);

    return CallHost(
      child: MaterialApp.router(
        title: 'Buddy-Up',
        debugShowCheckedModeBanner: false,
        theme: buildBuddyLightTheme(),
        darkTheme: buildBuddyTheme(),
        themeMode: themeMode,
        routerConfig: buildRouter(ref, authState),
        builder: (context, child) {
          // Biometric app-lock overlay: blocks the UI until unlocked.
          final showLock = authState.user != null && biometric.enabled && biometric.locked;
          if (showLock && child != null) {
            return Stack(
              children: [
                Offstage(child: child),
                _BiometricLock(locked: biometric.locked),
              ],
            );
          }
          return child ?? const SizedBox.shrink();
        },
      ),
    );
  }
}

class _BiometricLock extends ConsumerWidget {
  final bool locked;
  const _BiometricLock({required this.locked});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: BuddyColors.black,
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 56, color: BuddyColors.green),
              const SizedBox(height: 16),
              const Text(
                'BuddyUp is locked',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Unlock with your fingerprint or face',
                style: TextStyle(color: BuddyColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: BuddyColors.green,
                  foregroundColor: BuddyColors.black,
                ),
                onPressed: locked ? () => ref.read(biometricProvider.notifier).unlock() : null,
                icon: const Icon(Icons.fingerprint),
                label: const Text('Unlock'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
