import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/auth/auth_provider.dart';
import 'router.dart';

class BuddyUpApp extends ConsumerWidget {
  const BuddyUpApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp.router(
      title: 'Buddy-Up',
      debugShowCheckedModeBanner: false,
      theme: buildBuddyTheme(),
      routerConfig: buildRouter(ref, authState),
    );
  }
}
