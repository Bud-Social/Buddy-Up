import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/auth/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../features/notifications/providers/notification_provider.dart';
import '../widgets/support_dialog.dart';
import 'business_roles.dart';
import 'business_roles_provider.dart';

class BuddyNavDestination {
  final String route;
  final IconData icon;
  final String label;
  final String group;

  const BuddyNavDestination(this.route, this.icon, this.label, this.group);
}

/// Key attached to the phone shell so any screen can open this drawer.
final GlobalKey<ScaffoldState> appShellScaffoldKey = GlobalKey<ScaffoldState>();

class AppNav {
  static void open(BuildContext context) {
    appShellScaffoldKey.currentState?.openDrawer();
  }
}

const List<BuddyNavDestination> appNavDestinations = <BuddyNavDestination>[
  BuddyNavDestination('/feed', LucideIcons.home, 'Home', 'Main'),
  BuddyNavDestination('/discover', LucideIcons.search, 'Discover', 'Main'),
  BuddyNavDestination(
    '/buddies/find',
    LucideIcons.footprints,
    'Find a Buddy',
    'Main',
  ),
  BuddyNavDestination('/analytics', LucideIcons.activity, 'Analytics', 'Main'),
  BuddyNavDestination('/countdowns', LucideIcons.timer, 'Countdowns', 'Main'),
  BuddyNavDestination('/activities', LucideIcons.map, 'Activities', 'Main'),
  BuddyNavDestination('/lives', LucideIcons.radio, 'Lives', 'Main'),
  BuddyNavDestination('/gyms', LucideIcons.dumbbell, 'Gyms', 'Main'),
  BuddyNavDestination('/trainers', LucideIcons.users, 'Trainers', 'Main'),
  BuddyNavDestination(
    '/marketplace',
    LucideIcons.shoppingBag,
    'Marketplace',
    'Main',
  ),
  BuddyNavDestination(
    '/routines',
    LucideIcons.calendarDays,
    'Routines',
    'Main',
  ),
  BuddyNavDestination('/sessions', LucideIcons.calendar, 'Sessions', 'Main'),
  BuddyNavDestination(
    '/messages',
    LucideIcons.messageCircle,
    'Messages',
    'Main',
  ),
  BuddyNavDestination('/communities', LucideIcons.users, 'Communities', 'Main'),
  BuddyNavDestination('/wallet', LucideIcons.wallet, 'Wallet', 'Main'),
  BuddyNavDestination('/profile', LucideIcons.user, 'Profile', 'Main'),
  BuddyNavDestination('/settings', LucideIcons.settings, 'Settings', 'Footer'),
  BuddyNavDestination('/help', LucideIcons.helpCircle, 'Help', 'Footer'),
];

/// Web-parity navigation drawer: grouped Main / Your business / Staff / Footer,
/// the real brand mark, business-role entries, and a Fund Us action.
class AppNavDrawer extends ConsumerStatefulWidget {
  const AppNavDrawer({super.key});

  @override
  ConsumerState<AppNavDrawer> createState() => _AppNavDrawerState();
}

class _AppNavDrawerState extends ConsumerState<AppNavDrawer> {
  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final roles = ref.watch(businessRolesProvider).value;
    final unreadCount = ref.watch(unreadCountProvider).value ?? 0;
    final location = GoRouterState.of(context).matchedLocation;
    final user = auth.profile;

    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/logo-dark.png', height: 52),
                  const SizedBox(height: 8),
                  Text(
                    'BuddyUp Fit',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: user == null
                            ? const SizedBox.shrink()
                            : Text(
                                user.displayName,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                      ),
                      Badge(
                        isLabelVisible: (unreadCount) > 0,
                        label: Text(
                          unreadCount > 99 ? '99+' : '$unreadCount',
                          style: const TextStyle(
                            color: BuddyColors.black,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        backgroundColor: BuddyColors.green,
                        child: IconButton(
                          tooltip: 'Notifications',
                          icon: const Icon(
                            LucideIcons.bell,
                            color: BuddyColors.green,
                            size: 18,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            context.go('/notifications');
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _section('Main'),
            for (final d in appNavDestinations.where((d) => d.group == 'Main'))
              _tile(d.icon, d.label, d.route, location),
            if (roles != null && !roles.isEmpty) ...[
              _section('Your business'),
              for (final entry in businessEntries(roles))
                _tile(
                  _businessIcon(entry.key),
                  entry.shortLabel,
                  entry.route,
                  location,
                ),
            ],
            if (auth.user?.isStaff ?? false) ...[
              _section('Staff'),
              _tile(LucideIcons.layoutDashboard, 'Admin', '/admin', location),
            ],
            Divider(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            for (final d in appNavDestinations.where(
              (d) => d.group == 'Footer',
            ))
              _tile(d.icon, d.label, d.route, location),
            ListTile(
              leading: const Icon(
                LucideIcons.heartHandshake,
                color: BuddyColors.green,
              ),
              title: Text(
                'Fund Us',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                showSupportDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String label) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
    child: Text(
      label.toUpperCase(),
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    ),
  );

  Widget _tile(IconData icon, String label, String route, String location) {
    final selected = location.startsWith(route);
    return ListTile(
      leading: Icon(
        icon,
        color: selected
            ? BuddyColors.green
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: selected
              ? BuddyColors.green
              : Theme.of(context).colorScheme.onSurface,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: selected,
      selectedTileColor: BuddyColors.green.withValues(alpha: 0.12),
      onTap: () {
        Navigator.of(context).pop();
        context.go(route);
      },
    );
  }

  IconData _businessIcon(BusinessRoleKey key) => switch (key) {
    BusinessRoleKey.creator => LucideIcons.barChart3,
    BusinessRoleKey.shop => LucideIcons.store,
    BusinessRoleKey.events => LucideIcons.calendarRange,
    BusinessRoleKey.gym => LucideIcons.dumbbell,
    BusinessRoleKey.stations => LucideIcons.mapPin,
    BusinessRoleKey.courier => LucideIcons.bike,
  };
}
