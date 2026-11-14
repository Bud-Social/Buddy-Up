import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buddy_up_flutter/core/theme/app_theme.dart';
import 'package:buddy_up_flutter/data/models/gym.dart';
import 'package:buddy_up_flutter/features/gym/widgets/gym_card.dart';

/// Flutter parity for the web gym card: verified badge, followed-member
/// social signal, and single- vs multi-location + nearest-distance rendering.
void main() {
  Map<String, dynamic> gymJson({
    bool verified = false,
    bool multiLocation = false,
    int followedCount = 0,
  }) {
    final followed = List.generate(followedCount, (i) => {
          'user_id': 'u$i',
          'username': 'user$i',
          'display_name': 'Member $i',
          'avatar_url': '',
        });
    return {
      'id': 'g1',
      'name': 'Karura Fitness',
      'handle': 'karura',
      'category': 'fitness',
      'member_count': 120,
      'is_verified': verified,
      'followed_members': followed,
      'followed_members_count': followedCount,
      'location_summary': multiLocation
          ? {
              'has_physical': true,
              'venue_count': 2,
              'cities': ['Westlands', 'Karen'],
              'nearest_km': 2.4,
            }
          : null,
      'created_at': '2026-01-01T00:00:00Z',
    };
  }

  Widget wrap(Widget child) => MaterialApp(
        theme: buildBuddyTheme(),
        home: Scaffold(body: Center(child: SizedBox(width: 480, child: child))),
      );

  testWidgets('verified gym shows the dumbbell tick, not just any icon',
      (tester) async {
    await tester.pumpWidget(wrap(GymCard(gym: Gym.fromJson(gymJson(verified: true)))));
    expect(find.byIcon(Icons.fitness_center), findsOneWidget);
  });

  testWidgets('unverified gym shows no verified badge', (tester) async {
    await tester.pumpWidget(wrap(GymCard(gym: Gym.fromJson(gymJson()))));
    expect(find.byIcon(Icons.fitness_center), findsNothing);
  });

  testWidgets('followed members render first name +N others', (tester) async {
    await tester.pumpWidget(wrap(GymCard(gym: Gym.fromJson(gymJson(followedCount: 3)))));
    expect(find.textContaining('Member 0'), findsOneWidget);
    expect(find.textContaining('+2 others'), findsOneWidget);
  });

  testWidgets('multi-location gym shows cities and nearest distance',
      (tester) async {
    await tester.pumpWidget(
      wrap(GymCard(gym: Gym.fromJson(gymJson(multiLocation: true)))),
    );
    expect(find.textContaining('Westlands'), findsOneWidget);
    expect(find.textContaining('nearest'), findsOneWidget);
  });

  group('BuddyColors', () {
    test('blue constant exists for the verified badge', () {
      expect(BuddyColors.blue, const Color(0xFF3B82F6));
    });
  });
}
