import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/auth/auth_provider.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeModeProvider);

    return CallHost(
      child: MaterialApp.router(
        title: 'Buddy-Up',
        debugShowCheckedModeBanner: false,
        theme: buildBuddyLightTheme(),
        darkTheme: buildBuddyTheme(),
        themeMode: themeMode,
        routerConfig: buildRouter(ref, authState),
      ),
    );
  }
}
