import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

/// Global key for the responsive shell's phone Scaffold so hamburger buttons
/// in the main tab screens can open the navigation drawer.
final GlobalKey<ScaffoldState> appShellScaffoldKey = GlobalKey<ScaffoldState>();

class AppNavDestination {
  final String route;
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const AppNavDestination(this.route, this.icon, this.selectedIcon, this.label);
}

const List<AppNavDestination> appNavDestinations = [
  AppNavDestination('/feed', Icons.home_outlined, Icons.home, 'Home'),
  AppNavDestination(
    '/discover',
    Icons.explore_outlined,
    Icons.explore,
    'Discover',
  ),
  AppNavDestination(
    '/lives',
    Icons.videocam_outlined,
    Icons.videocam,
    'Lives',
  ),
  AppNavDestination(
    '/gyms',
    Icons.fitness_center_outlined,
    Icons.fitness_center,
    'Gyms',
  ),
  AppNavDestination(
    '/messages',
    Icons.chat_bubble_outline,
    Icons.chat_bubble,
    'Messages',
  ),
  AppNavDestination(
    '/communities',
    Icons.groups_outlined,
    Icons.groups,
    'Communities',
  ),
  AppNavDestination('/profile', Icons.person_outline, Icons.person, 'Profile'),
  AppNavDestination(
    '/settings',
    Icons.settings_outlined,
    Icons.settings,
    'Settings',
  ),
];

/// Open the phone-shell navigation drawer from a main tab screen.
class AppNav {
  static void open(BuildContext context) {
    appShellScaffoldKey.currentState?.openDrawer();
  }
}

/// Drawer body listing every nav destination (phone shell).
class AppNavDrawer extends StatelessWidget {
  const AppNavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    return Drawer(
      backgroundColor: BuddyColors.black,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Row(
                children: [
                  Icon(Icons.fitness_center, color: BuddyColors.green, size: 28),
                  SizedBox(width: 10),
                  Text(
                    'Buddy-Up',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            for (final d in appNavDestinations)
              ListTile(
                leading: Icon(
                  d.icon,
                  color: location.startsWith(d.route)
                      ? BuddyColors.green
                      : Colors.white,
                ),
                selected: location.startsWith(d.route),
                selectedTileColor: BuddyColors.green.withValues(alpha: 0.15),
                title: Text(
                  d.label,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  context.go(d.route);
                },
              ),
          ],
        ),
      ),
    );
  }
}