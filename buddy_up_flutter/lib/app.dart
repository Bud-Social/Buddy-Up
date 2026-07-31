import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/auth/auth_provider.dart';
import 'features/notifications/services/push_notification_service.dart';
import 'router.dart';

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

    return MaterialApp.router(
      title: 'Buddy-Up',
      debugShowCheckedModeBanner: false,
      theme: buildBuddyTheme(),
      routerConfig: buildRouter(ref, authState),
    );
  }
}
