import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/updates/update_prompt.dart';
import 'core/auth/auth_provider.dart';
import 'core/auth/biometric_provider.dart';
import 'features/analytics/providers/analytics_provider.dart';
import 'features/notifications/services/push_notification_service.dart';
import 'features/messaging/widgets/call_host.dart';
import 'features/settings/widgets/alarm_ring_host.dart';
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

class _BuddyUpAppState extends ConsumerState<BuddyUpApp> with WidgetsBindingObserver {
  Timer? _activitySyncTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() {
      ref.read(pushNotificationServiceProvider).initialize();
    });
    // Trigger biometric state load (and lock if enabled) at startup.
    ref.read(biometricProvider.notifier);
    // Activities recorded offline replay as soon as a session exists, then on
    // a slow tick while the app is open and whenever it returns to the
    // foreground (the connection may only come back while backgrounded).
    Future.microtask(_syncPendingActivities);
    _activitySyncTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => _syncPendingActivities(),
    );
  }

  Future<void> _syncPendingActivities() async {
    final ownerId = ref.read(authProvider).user?.id;
    if (ownerId == null) return;
    try {
      final result = await ref
          .read(activityQueueServiceProvider)
          .flush(ownerId);
      if (!mounted) return;
      if (result.synced > 0) {
        await ref.read(analyticsSummaryProvider.notifier).refresh();
      }
    } catch (_) {
      // Storage or transport trouble — the queue stays for the next attempt.
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncPendingActivities();
    }
  }

  @override
  void dispose() {
    _activitySyncTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider.select((s) => s.user?.id), (previous, next) {
      if (next != null && next != previous) {
        Future.microtask(_syncPendingActivities);
      }
    });
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeModeProvider);
    final biometric = ref.watch(biometricProvider);

    return CallHost(
      child: MaterialApp.router(
        title: 'BuddyUp Fit',
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
          return Stack(
            children: [
              AlarmRingHost(child: child ?? const SizedBox.shrink()),
              // Best-effort in-app updater for the sideloaded Android APK.
              const UpdatePrompt(),
            ],
          );
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
