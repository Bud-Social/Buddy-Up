import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buddy_up_flutter/core/analytics/analytics_service.dart';
import 'package:buddy_up_flutter/core/auth/auth_provider.dart';
import 'package:buddy_up_flutter/core/theme/app_theme.dart';
import 'package:buddy_up_flutter/data/models/profile.dart';
import 'package:buddy_up_flutter/data/repositories/profile_repository.dart';
import 'package:buddy_up_flutter/features/buddies/buddy_nearby_provider.dart';
import 'package:buddy_up_flutter/features/buddies/widgets/buddy_discovery_card.dart';

/// Like state on the discovery card: the heart renders filled/tinted only when
/// `liked_by_me` is set, and the "Liked you" back-signal appears only when
/// they liked me and I have not yet replied.
void main() {
  setUpAll(() {
    // Warm the analytics singleton outside the fake-async zone so its
    // batch-flush timer never trips the pending-timer check.
    AnalyticsService.instance.track('test.warmup', surface: 'test');
  });

  Map<String, dynamic> buddyJson({
    bool likedByMe = false,
    bool likedMe = false,
    String username = 'sam',
    double? distanceKm = 0.85,
  }) {
    return {
      'profile': {'username': username, 'display_name': 'Sam', 'avatar_url': ''},
      'display_name': 'Sam',
      'intents': ['early_bird_run'],
      'goals': ['get_faster'],
      'modes': ['in_person'],
      'pace': 'steady',
      'age_band': '28–34',
      'available_now': true,
      'distance_km': distanceKm,
      'liked_by_me': likedByMe,
      'liked_me': likedMe,
    };
  }

  NearbyBuddy buddy({
    bool likedByMe = false,
    bool likedMe = false,
    String username = 'sam',
    double? distanceKm = 0.85,
  }) {
    return NearbyBuddy.fromJson(
      buddyJson(
        likedByMe: likedByMe,
        likedMe: likedMe,
        username: username,
        distanceKm: distanceKm,
      ),
    );
  }

  /// Auth notifier that never touches secure storage (no platform channels).
  AuthNotifier testAuth() {
    return _TestAuthNotifier(
      const AuthState(
        isAuthenticated: true,
        profile: Profile(
          userId: 'uid-me',
          username: 'me',
          displayName: 'Me',
          avatarUrl: '',
        ),
      ),
    );
  }

  Widget wrap(Widget child) {
    return ProviderScope(
      overrides: [authProvider.overrideWith(testAuth)],
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }

  Finder likeButton(String username) => find.byKey(ValueKey('buddy-card-like-$username'));
  Finder messageButton(String username) => find.byKey(ValueKey('buddy-card-message-$username'));
  Finder likedYouBadge(String username) => find.byKey(ValueKey('buddy-card-liked-you-$username'));

  Icon likeIcon(WidgetTester tester, String username) => tester.widget<Icon>(
        find.descendant(of: likeButton(username), matching: find.byType(Icon)),
      );

  group('Discovery card — liked_by_me', () {
    testWidgets('unliked card shows an empty heart', (tester) async {
      await tester.pumpWidget(wrap(SizedBox(
        height: 260,
        width: 200,
        child: BuddyDiscoveryCard(
          buddy: buddy(),
          onOpenProfile: () {},
          onMessage: () {},
          onLike: () {},
        ),
      )));

      expect(likeIcon(tester, 'sam').icon, Icons.favorite_border);
      expect(likeIcon(tester, 'sam').color, BuddyColors.textSecondary);
      expect(find.byIcon(Icons.favorite), findsNothing);
      expect(find.byTooltip('Like'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('liked card fills the heart in green', (tester) async {
      await tester.pumpWidget(wrap(SizedBox(
        height: 260,
        width: 200,
        child: BuddyDiscoveryCard(
          buddy: buddy(likedByMe: true),
          onOpenProfile: () {},
          onMessage: () {},
          onLike: () {},
        ),
      )));

      expect(likeIcon(tester, 'sam').icon, Icons.favorite);
      expect(likeIcon(tester, 'sam').color, BuddyColors.green);
      expect(find.byTooltip('Unlike'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('the heart is disabled while the like is in flight',
        (tester) async {
      await tester.pumpWidget(wrap(SizedBox(
        height: 260,
        width: 200,
        child: BuddyDiscoveryCard(
          buddy: buddy(),
          liking: true,
          onOpenProfile: () {},
          onMessage: () {},
          onLike: () {},
        ),
      )));

      final button = tester.widget<IconButton>(
        find.descendant(of: likeButton('sam'), matching: find.byType(IconButton)),
      );
      expect(button.onPressed, isNull);
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('Discovery card — liked_me back-signal', () {
    testWidgets('shows "Liked you" when they liked me and I have not',
        (tester) async {
      await tester.pumpWidget(wrap(SizedBox(
        height: 260,
        width: 200,
        child: BuddyDiscoveryCard(
          buddy: buddy(likedMe: true),
          onOpenProfile: () {},
          onMessage: () {},
          onLike: () {},
        ),
      )));

      expect(likedYouBadge('sam'), findsOneWidget);
      expect(find.text('Liked you'), findsOneWidget);
      expect(likeIcon(tester, 'sam').icon, Icons.favorite_border);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('drops the badge once the like is mutual', (tester) async {
      await tester.pumpWidget(wrap(SizedBox(
        height: 260,
        width: 200,
        child: BuddyDiscoveryCard(
          buddy: buddy(likedMe: true, likedByMe: true),
          onOpenProfile: () {},
          onMessage: () {},
          onLike: () {},
        ),
      )));

      expect(likedYouBadge('sam'), findsNothing);
      expect(find.text('Liked you'), findsNothing);
      expect(likeIcon(tester, 'sam').icon, Icons.favorite);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('no badge when there is no back-signal', (tester) async {
      await tester.pumpWidget(wrap(SizedBox(
        height: 260,
        width: 200,
        child: BuddyDiscoveryCard(
          buddy: buddy(),
          onOpenProfile: () {},
          onMessage: () {},
          onLike: () {},
        ),
      )));

      expect(likedYouBadge('sam'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('Discovery card — the two actions', () {
    testWidgets('message and like are separate callbacks', (tester) async {
      var messages = 0;
      var likes = 0;
      await tester.pumpWidget(wrap(SizedBox(
        height: 260,
        width: 200,
        child: BuddyDiscoveryCard(
          buddy: buddy(),
          onOpenProfile: () {},
          onMessage: () => messages++,
          onLike: () => likes++,
        ),
      )));

      await tester.tap(messageButton('sam'));
      await tester.tap(likeButton('sam'));
      await tester.pump();

      expect(messages, 1);
      expect(likes, 1);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('the card body is no longer a buddy request', (tester) async {
      await tester.pumpWidget(wrap(SizedBox(
        height: 260,
        width: 200,
        child: BuddyDiscoveryCard(
          buddy: buddy(),
          onOpenProfile: () {},
          onMessage: () {},
          onLike: () {},
        ),
      )));

      // The old "Buddy Up" affordance is gone: like + message replace it.
      expect(find.byIcon(Icons.person_add), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('Discovery card — distance band', () {
    testWidgets('renders the shared <1 km band on the photo', (tester) async {
      await tester.pumpWidget(wrap(SizedBox(
        height: 260,
        width: 200,
        child: BuddyDiscoveryCard(
          buddy: buddy(),
          onOpenProfile: () {},
          onMessage: () {},
          onLike: () {},
        ),
      )));

      expect(find.text('<1 km'), findsOneWidget);
      expect(find.text('850 m'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('omits the badge when the API could not band it',
        (tester) async {
      await tester.pumpWidget(wrap(SizedBox(
        height: 260,
        width: 200,
        child: BuddyDiscoveryCard(
          buddy: buddy(distanceKm: null),
          onOpenProfile: () {},
          onMessage: () {},
          onLike: () {},
        ),
      )));

      expect(find.text('<1 km'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('Discovery card — essentials', () {
    testWidgets('carries the facts you decide on', (tester) async {
      await tester.pumpWidget(wrap(SizedBox(
        height: 320,
        width: 220,
        child: BuddyDiscoveryCard(
          buddy: buddy(distanceKm: 1.3),
          onOpenProfile: () {},
          onMessage: () {},
          onLike: () {},
        ),
      )));

      expect(find.text('Sam'), findsOneWidget);
      expect(find.text('28–34'), findsOneWidget);
      expect(find.text('early bird run'), findsOneWidget);
      expect(find.text('in person'), findsOneWidget);
      expect(find.text('get faster · steady'), findsOneWidget);
      expect(find.text('Available now'), findsOneWidget);
      expect(find.text('1.3 km'), findsOneWidget);
      // A real photo is preferred over the initials placeholder.
      expect(find.byType(CachedNetworkImage), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });
  });
}

class _TestAuthNotifier extends AuthNotifier {
  final AuthState _state;

  _TestAuthNotifier(this._state);

  @override
  AuthState build() => _state;
}