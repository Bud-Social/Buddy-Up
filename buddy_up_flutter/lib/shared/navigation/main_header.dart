import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import '../../features/notifications/providers/notification_provider.dart';
import 'app_nav.dart';

/// Web-parity notification bell with the unread badge.
///
/// Mirrors `AppShell.tsx`'s `NotificationBell`: bell opens `/notifications`,
/// badge caps at "9+" (the drawer caps at 99+). Reused by every main-tab
/// header so the bell never disappears when switching tabs.
class NotificationBellButton extends ConsumerWidget {
  const NotificationBellButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadCountProvider).value ?? 0;
    return Badge(
      isLabelVisible: unread > 0,
      label: Text(
        unread > 9 ? '9+' : '$unread',
        style: const TextStyle(
          color: BuddyColors.black,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
      backgroundColor: BuddyColors.green,
      child: IconButton(
        icon: const Icon(LucideIcons.bell),
        tooltip: 'Notifications',
        onPressed: () => context.push('/notifications'),
      ),
    );
  }
}

/// Shared app bar for the five main tabs: hamburger (opens the drawer),
/// brand mark or title, optional page actions, then search + notifications.
///
/// Conventions from the web shell:
/// * menu button is always present (conversations is the only exemption),
/// * search sits immediately left of the notification bell,
/// * the logo replaces the title on Home, titles stay elsewhere.
class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({
    super.key,
    this.title,
    this.showLogo = false,
    this.showSearch = true,
    this.actions = const [],
    this.onSearch,
  });

  final String? title;
  final bool showLogo;
  final bool showSearch;

  /// Page-specific actions rendered before the shared search/bell pair.
  final List<Widget> actions;

  /// Overrides the default search action (navigate to `/discover`).
  final VoidCallback? onSearch;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(LucideIcons.menu),
        tooltip: 'Menu',
        onPressed: () => AppNav.open(context),
      ),
      title: showLogo
          ? Image.asset(
              'assets/logo-dark.png',
              height: 28,
              fit: BoxFit.contain,
            )
          : (title == null ? null : Text(title!)),
      actions: [
        ...actions,
        if (showSearch)
          IconButton(
            icon: const Icon(LucideIcons.search),
            tooltip: 'Search',
            onPressed: onSearch ?? () => context.go('/discover'),
          ),
        const NotificationBellButton(),
      ],
    );
  }
}
