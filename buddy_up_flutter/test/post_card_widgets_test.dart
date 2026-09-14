import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buddy_up_flutter/core/analytics/analytics_service.dart';
import 'package:buddy_up_flutter/core/auth/auth_provider.dart';
import 'package:buddy_up_flutter/data/models/post.dart';
import 'package:buddy_up_flutter/data/models/profile.dart';
import 'package:buddy_up_flutter/data/repositories/feed_repository.dart';
import 'package:buddy_up_flutter/features/feed/providers/feed_provider.dart';
import 'package:buddy_up_flutter/features/feed/widgets/post_card.dart';
import 'package:buddy_up_flutter/features/feed/widgets/repost_indicator.dart';

/// Bud Press parity widgets: header view counter, animated repost avatar
/// overlay, and the mobile-native post menu rows.
void main() {
  setUpAll(() {
    // Create the analytics singleton outside the fake-async zone so its
    // batch-flush timer never trips the pending-timer check. Without dotenv
    // the flush path is a no-op (lazy client), so no network is attempted.
    AnalyticsService.instance.track('test.warmup', surface: 'test');
  });
  Map<String, dynamic> postJson(String id, [Map<String, dynamic>? extra]) {
    return {
      'id': id,
      'author_data': {
        'user_id': 'uid-alice',
        'username': 'alice',
        'display_name': 'Alice',
        'avatar_url': '',
        'verification_status': 'none',
      },
      'created_at': '2026-01-01T00:00:00Z',
      ...?extra,
    };
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
          avatarUrl: 'https://example.invalid/me.png',
        ),
      ),
    );
  }

  ProviderScope wrap(Widget child) {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) => handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {'data': <String, dynamic>{}},
          ),
        ),
      ),
    );
    return ProviderScope(
      overrides: [
        authProvider.overrideWith(testAuth),
        feedRepositoryProvider.overrideWithValue(FeedRepository(dio)),
      ],
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }

  /// Dispose the tree so PostCard's pending view timer is cancelled before
  /// the fake-async teardown check runs.
  Future<void> settleTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
  }

  group('RepostIndicator avatar overlay', () {
    testWidgets('viewer avatar pops in on repost', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RepostIndicator(
              reposters: [
                ReposterData(displayName: 'A', avatarUrl: ''),
                ReposterData(displayName: 'B', avatarUrl: ''),
              ],
              username: 'alice',
              viewerReposted: true,
              viewerAvatarUrl: 'https://example.invalid/me.png',
              viewerDisplayName: 'Me',
            ),
          ),
        ),
      );

      expect(
        find.byKey(const ValueKey('viewer-repost-avatar')),
        findsOneWidget,
      );
      final scale = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
      expect(scale.scale, 1.0);
      await settleTree(tester);
    });

    testWidgets('viewer avatar scales out on unrepost', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RepostIndicator(
              reposters: [
                ReposterData(displayName: 'A', avatarUrl: ''),
                ReposterData(displayName: 'B', avatarUrl: ''),
              ],
              username: 'alice',
              viewerReposted: false,
              viewerAvatarUrl: 'https://example.invalid/me.png',
              viewerDisplayName: 'Me',
            ),
          ),
        ),
      );

      expect(
        find.byKey(const ValueKey('viewer-repost-avatar')),
        findsOneWidget,
      );
      final scale = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
      expect(scale.scale, 0.0);
      await settleTree(tester);
    });

    testWidgets('no viewer slot without a viewer avatar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RepostIndicator(
              reposters: [
                ReposterData(displayName: 'A', avatarUrl: ''),
                ReposterData(displayName: 'B', avatarUrl: ''),
              ],
              username: 'alice',
            ),
          ),
        ),
      );

      expect(
        find.byKey(const ValueKey('viewer-repost-avatar')),
        findsNothing,
      );
      await settleTree(tester);
    });
  });

  group('PostCard header', () {
    testWidgets('shows eye + view count next to the menu button',
        (tester) async {
      final post = Post.fromJson(postJson('p1', {'view_count': 1200}));
      await tester.pumpWidget(wrap(PostCard(post: post)));

      final counter = find.byKey(const ValueKey('post-header-view-count'));
      expect(counter, findsOneWidget);
      expect(
        tester.widget<Text>(counter).data,
        '1.2k',
      );
      expect(find.byIcon(Icons.visibility_outlined), findsWidgets);
      expect(find.byIcon(Icons.more_horiz), findsOneWidget);
      await settleTree(tester);
    });

    testWidgets('repost row shows the viewer overlay in the card',
        (tester) async {
      final post = Post.fromJson(
        postJson('row1', {
          'is_repost': true,
          'is_reposted_by_me': true,
          'reposters': [
            {'display_name': 'A', 'avatar_url': ''},
            {'display_name': 'B', 'avatar_url': ''},
          ],
        }),
      );
      await tester.pumpWidget(wrap(PostCard(post: post)));

      expect(
        find.byKey(const ValueKey('viewer-repost-avatar')),
        findsOneWidget,
      );
      await settleTree(tester);
    });
  });

  group('PostCard menu', () {
    testWidgets('menu button opens rows for all parity actions',
        (tester) async {
      final post = Post.fromJson(postJson('p1'));
      await tester.pumpWidget(wrap(PostCard(post: post)));

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      expect(find.text('Like'), findsOneWidget);
      expect(find.text('Not interested'), findsOneWidget);
      expect(find.text('Report'), findsOneWidget);
      expect(find.text('Block @alice'), findsOneWidget);
      expect(find.text("Don't suggest this creator"), findsOneWidget);
      await settleTree(tester);
    });
  });
}

class _TestAuthNotifier extends AuthNotifier {
  _TestAuthNotifier(this._state);

  final AuthState _state;

  @override
  AuthState build() => _state;
}
