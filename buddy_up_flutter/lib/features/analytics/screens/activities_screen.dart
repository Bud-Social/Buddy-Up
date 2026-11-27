import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/navigation/main_header.dart';
import 'activity_tab.dart';
import 'gps_tracker_screen.dart';

/// Dedicated Activities surface, matching the web `/activities` page: the
/// activity overview plus an entry point to the live GPS tracker.
class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        title: 'Activities',
        actions: [
          IconButton(
            tooltip: 'Track activity',
            icon: const Icon(LucideIcons.navigation),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const GpsTrackerScreen(),
              ),
            ),
          ),
        ],
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: ActivityTab(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: BuddyColors.green,
        foregroundColor: Theme.of(context).colorScheme.surface,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const GpsTrackerScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
