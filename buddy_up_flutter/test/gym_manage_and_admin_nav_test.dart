import 'package:buddy_up_flutter/features/admin/screens/admin_console_screen.dart';
import 'package:buddy_up_flutter/features/gym/providers/gym_manage_provider.dart';
import 'package:buddy_up_flutter/features/gym/screens/gym_manage_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('gym partner metrics', () {
    test('decodes the server payload', () {
      final metrics = GymPartnerMetrics.fromJson(const {
        'active_members': 42,
        'check_ins_30d': 128,
        'unique_attendees_30d': 31,
        'activation_rate_30d': 0.74,
        'scheduled_activities_30d': 9,
      });

      expect(metrics.activeMembers, 42);
      expect(metrics.checkIns30d, 128);
      expect(metrics.uniqueAttendees30d, 31);
      expect(metrics.activationRate30d, closeTo(0.74, 1e-9));
      expect(metrics.scheduledActivities30d, 9);
    });

    test('an int activation rate does not throw', () {
      // The server returns a float, but a whole-body ratio serialised as an int
      // is exactly the kind of thing that crashes a console mid-read.
      final metrics = GymPartnerMetrics.fromJson(const {
        'active_members': 1,
        'check_ins_30d': 0,
        'unique_attendees_30d': 0,
        'activation_rate_30d': 1,
        'scheduled_activities_30d': 0,
      });

      expect(metrics.activationRate30d, 1.0);
    });

    test('missing fields read as zero rather than crashing', () {
      final metrics = GymPartnerMetrics.fromJson(const {'active_members': 7});

      expect(metrics.activeMembers, 7);
      expect(metrics.checkIns30d, 0);
      expect(metrics.activationRate30d, 0.0);
    });

    test('a null payload degrades instead of throwing', () {
      final metrics = GymPartnerMetrics.fromJson(const {});

      expect(metrics.activeMembers, 0);
      expect(metrics.scheduledActivities30d, 0);
    });
  });

  group('gym management tabs', () {
    test('opens on Overview', () {
      // The management surface is an operator's dashboard; it should not open
      // on a member list with the numbers two taps away.
      expect(GymManageScreen.tabs.first, 'Overview');
    });

    test('every tab label is short enough for one row', () {
      // These render in a tab strip; a long label wraps the strip to two rows
      // and pushes the panel content off screen.
      for (final tab in GymManageScreen.tabs) {
        expect(tab.length, lessThanOrEqualTo(9), reason: '"$tab" is too long');
      }
    });

    test('the panel count covers every requested surface', () {
      expect(GymManageScreen.tabs, containsAll(<String>[
        'Overview', // gym analytics
        'Members', // remove / change role
        'Requests',
        'Schedule',
        'Reviews',
      ]));
    });
  });

  group('admin console navigation', () {
    List<String> labels() =>
        AdminConsoleScreen.sections.map((s) => s.label).toList();

    test('Overview leads the console', () {
      // It used to sit third, under PLATFORM ANALYTICS, so the console's front
      // door showed an index rather than a summary.
      expect(labels().first, 'Overview');
    });

    test('one destination does not appear under two names', () {
      final all = <String>[
        ...labels(),
        ...AdminConsoleScreen.governanceSections.map((s) => s.label),
        ...AdminConsoleScreen.analyticsSections.map((s) => s.label),
      ];
      expect(all.toSet().length, all.length,
          reason: 'duplicate console labels: $all');
    });

    test('no console route is listed twice', () {
      final routes = <String>[
        ...AdminConsoleScreen.sections.map((s) => s.route),
        ...AdminConsoleScreen.governanceSections.map((s) => s.route),
        ...AdminConsoleScreen.analyticsSections.map((s) => s.route),
      ];
      expect(routes.toSet().length, routes.length,
          reason: 'duplicate console routes: $routes');
    });

    test('the analytics overview route is reachable from the top', () {
      expect(
        AdminConsoleScreen.sections.first.route,
        '/admin/analytics',
      );
    });

    test('every console label is short enough for a tile', () {
      final all = <String>[
        ...labels(),
        ...AdminConsoleScreen.governanceSections.map((s) => s.label),
        ...AdminConsoleScreen.analyticsSections.map((s) => s.label),
      ];
      for (final label in all) {
        expect(label.length, lessThanOrEqualTo(22), reason: '"$label" is too long');
      }
    });
  });
}