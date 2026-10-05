import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:buddy_up_flutter/core/analytics/analytics_service.dart';
import 'package:buddy_up_flutter/data/models/messaging.dart';
import 'package:buddy_up_flutter/data/repositories/messaging_repository.dart';
import 'package:buddy_up_flutter/data/repositories/profile_repository.dart';
import 'package:buddy_up_flutter/features/buddies/buddy_nearby_provider.dart';
import 'package:buddy_up_flutter/features/buddies/buddy_find_profile_screen.dart';
import 'package:buddy_up_flutter/features/buddies/buddy_nearby_screen.dart';
import 'package:buddy_up_flutter/features/messaging/providers/messaging_provider.dart';

/// The Find-a-Buddy Message buttons must ask the backend for a
/// *discovery-born* thread. The contract is narrow and easy to break in
/// silence: `StartConversationInputSerializer` requires `participants` (a
/// non-empty list of usernames) and only accepts `origin` as
/// 'direct' | 'discovery'. A wrong key means a 400 and no chat at all, and
/// omitting `origin` means the thread never shows up in Buddy messages.
/// [FakeStartEndpoint] below is a faithful port of that input serializer, so
/// these tests fail if the request stops satisfying it.
void main() {
  setUpAll(() {
    // Warm the analytics singleton outside the fake-async zone so its
    // batch-flush timer never trips the pending-timer check.
    AnalyticsService.instance.track('test.warmup', surface: 'test');
  });

  group('Discovery Message button', () {
    testWidgets('starts a thread tagged origin: discovery', (tester) async {
      final server = FakeStartEndpoint();
      final harness = await _pumpNearby(tester, server);

      await tester.tap(find.byKey(const ValueKey('buddy-card-message-sam')));
      await tester.pumpAndSettle();

      expect(server.startBodies, hasLength(1));
      expect(server.startBodies.single, {
        'participants': ['sam'],
        'origin': 'discovery',
      });
      // And the chat actually opens on the conversation the server handed back.
      expect(harness.pushedIds, ['conv-1']);
    });

    testWidgets('the thread it opens is kept by the Buddy messages filter',
        (tester) async {
      final server = FakeStartEndpoint();
      await _pumpNearby(tester, server);

      await tester.tap(find.byKey(const ValueKey('buddy-card-message-sam')));
      await tester.pumpAndSettle();

      final convo = Conversation.fromJson(server.startedConversations.single);
      expect(ConversationFilter.discovery.matches(convo), isTrue);
    });

    testWidgets('the chat still opens when the server ignores origin',
        (tester) async {
      // A stale or trimmed backend drops the unknown field. The row must still
      // decode and the screen must still navigate — it just lands outside the
      // Buddy messages filter.
      final server = FakeStartEndpoint(includeOrigin: false);
      final harness = await _pumpNearby(tester, server);

      await tester.tap(find.byKey(const ValueKey('buddy-card-message-sam')));
      await tester.pumpAndSettle();

      expect(harness.pushedIds, ['conv-1']);
      final convo = Conversation.fromJson(server.startedConversations.single);
      expect(convo.id, 'conv-1');
      expect(convo.participantsData.single.displayName, 'Sam Rivera');
      expect(convo.origin, 'direct');
      expect(ConversationFilter.discovery.matches(convo), isFalse);
    });
  });

  group('Buddy-search profile Message button', () {
    testWidgets('starts a thread tagged origin: discovery', (tester) async {
      final server = FakeStartEndpoint();
      final pushedIds = <String?>[];

      await _pumpProfile(tester, server, pushedIds);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Message'));
      await tester.pumpAndSettle();

      expect(server.startBodies, [
        {
          'participants': ['sam'],
          'origin': 'discovery',
        },
      ]);
      expect(pushedIds, ['conv-1']);
    });

    testWidgets('the chat still opens when the server ignores origin',
        (tester) async {
      final server = FakeStartEndpoint(includeOrigin: false);
      final pushedIds = <String?>[];

      await _pumpProfile(tester, server, pushedIds);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Message'));
      await tester.pumpAndSettle();

      expect(pushedIds, ['conv-1']);
      final convo = Conversation.fromJson(server.startedConversations.single);
      expect(convo.id, 'conv-1');
      expect(convo.participantsData.single.username, 'sam');
    });
  });
}

/// A screen-level harness: the conversation ids the fake router was pushed to.
class _Harness {
  final List<String?> pushedIds;
  final List<Map<String, dynamic>> startedConversations;

  const _Harness(this.pushedIds, this.startedConversations);
}

/// Mirrors `backend/apps/messaging/views.py::StartConversationInputSerializer`:
/// `participants` is required and non-empty, `origin` must be one of the
/// choices, and an invalid body answers 400 the way `raise_exception=True` does.
class FakeStartEndpoint {
  FakeStartEndpoint({this.includeOrigin = true});

  /// Send `origin` back on the created conversation, the way a current backend
  /// does. When false, the field is dropped entirely.
  final bool includeOrigin;

  final List<Map<String, dynamic>> startBodies = [];
  final List<Map<String, dynamic>> startedConversations = [];

  Map<String, dynamic> conversation({bool withOrigin = true}) => {
        'id': 'conv-1',
        'is_group': false,
        'is_community': false,
        'group_name': '',
        'group_avatar_url': null,
        'group_gym_id': null,
        'description': '',
        'cover_url': null,
        'invite_code': null,
        'is_public': false,
        'sub_channel': null,
        'call_in_progress': false,
        if (withOrigin) 'origin': 'discovery',
        'promoted_at': null,
        'promotable': true,
        'promotion_status': null,
        'promotion_id': null,
        'participants_data': [
          {
            'user_id': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
            'username': 'sam',
            'display_name': 'Sam Rivera',
            'avatar_url': '',
            'verification_status': 'verified',
            'role': 'user',
          },
        ],
        'unread_count': 0,
        'membership_role': null,
        'last_message': null,
        'last_message_at': null,
        'created_at': '2026-03-01T10:00:00Z',
      };

  String? validate(Map<String, dynamic> body) {
    final participants = body['participants'];
    if (participants is! List || participants.isEmpty) {
      return 'participants: This field is required.';
    }
    if (participants.any((p) => p is! String)) {
      return 'participants: Not a valid string.';
    }
    final origin = body['origin'];
    if (origin != null && origin != 'direct' && origin != 'discovery') {
      return 'origin: "{origin}" is not a valid choice.';
    }
    return null;
  }

  Dio client() {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path == '/messaging/conversations/start/') {
            final body = Map<String, dynamic>.from(options.data as Map);
            startBodies.add(body);
            final error = validate(body);
            if (error != null) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  response: Response(
                    requestOptions: options,
                    statusCode: 400,
                    data: {'participants': [error]},
                  ),
                ),
              );
              return;
            }
            startedConversations.add(conversation(withOrigin: includeOrigin));
            handler.resolve(Response(
              requestOptions: options,
              statusCode: 201,
              data: {
                'success': true,
                'data': conversation(withOrigin: includeOrigin),
                'message': 'Conversation started.',
              },
            ));
            return;
          }
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: _otherPayload(options.path),
          ));
        },
      ),
    );
    return dio;
  }

  Map<String, dynamic> _otherPayload(String path) {
    if (path == '/profiles/buddies/nearby/') {
      return {
        'success': true,
        'data': [
          {
            'profile': {
              'username': 'sam',
              'display_name': 'Sam',
              'avatar_url': '',
            },
            'display_name': 'Sam',
            'intents': ['early_bird_run'],
            'goals': ['get_faster'],
            'modes': ['in_person'],
            'pace': 'steady',
            'age_band': '28–34',
            'available_now': true,
            'distance_km': 0.85,
            'liked_by_me': false,
            'liked_me': true,
          },
        ],
      };
    }
    if (path == '/profiles/me/search-profile/') {
      // A saved profile, so the editor stays collapsed and the grid is what
      // the test drives.
      return {
        'success': true,
        'data': {
          'intents': ['run'],
          'display_name': 'Me',
          'custom_intent': '',
          'modes': ['in_person'],
          'bio': '',
          'goals': ['get_faster'],
          'age_band': '28–34',
          'photos': <String>[],
          'neighbourhood': '',
          'pace': '',
          'visibility': 'public',
          'incognito': false,
          'available_now': false,
        },
      };
    }
    if (path.endsWith('/search-profile/') && path != '/profiles/me/search-profile/') {
      // BuddyFindProfileScreen: the full card for one nearby buddy.
      return {
        'success': true,
        'data': {
          'username': 'sam',
          'display_name': 'Sam Rivera',
          'avatar_url': '',
          'photos': <String>[],
          'bio': 'Early bird.',
          'intents': ['early_bird_run'],
          'goals': ['get_faster'],
          'modes': ['in_person'],
          'pace': 'steady',
          'age_band': '28–34',
          'neighbourhood': 'Shoreditch',
          'available_now': true,
          'distance_km': 0.85,
          'liked_by_me': false,
          'liked_me': true,
        },
      };
    }
    return {'success': true, 'data': null, 'message': 'OK'};
  }
}

/// Boots the Find-a-Buddy grid over [FakeStartEndpoint] and taps nothing yet.
Future<_Harness> _pumpNearby(WidgetTester tester, FakeStartEndpoint server) async {
  final dio = server.client();
  final pushedIds = <String?>[];
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, _) => const BuddyNearbyScreen()),
      GoRoute(
        path: '/buddies/messages/:id',
        builder: (_, state) {
          pushedIds.add(state.pathParameters['id']);
          return const Scaffold(body: Text('chat'));
        },
      ),
      GoRoute(path: '/buddies/messages', builder: (_, _) => const Scaffold()),
      GoRoute(path: '/buddies/find/:username', builder: (_, _) => const Scaffold()),
    ],
  );
  addTearDown(router.dispose);

  tester.view.physicalSize = const Size(1400, 2200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        profileRepositoryProvider.overrideWithValue(ProfileRepository(dio)),
        messagingRepositoryProvider.overrideWithValue(MessagingRepository(dio)),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();

  expect(find.byKey(const ValueKey('buddy-card-message-sam')), findsOneWidget);
  return _Harness(pushedIds, server.startedConversations);
}

/// Boots the full Find-a-Buddy profile for `sam` over [FakeStartEndpoint].
Future<void> _pumpProfile(
  WidgetTester tester,
  FakeStartEndpoint server,
  List<String?> pushedIds,
) async {
  final dio = server.client();
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const BuddyFindProfileScreen(username: 'sam'),
      ),
      GoRoute(
        path: '/messages/:id',
        builder: (_, state) {
          pushedIds.add(state.pathParameters['id']);
          return const Scaffold(body: Text('chat'));
        },
      ),
      GoRoute(path: '/:username', builder: (_, _) => const Scaffold()),
    ],
  );
  addTearDown(router.dispose);

  tester.view.physicalSize = const Size(1400, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        profileRepositoryProvider.overrideWithValue(ProfileRepository(dio)),
        messagingRepositoryProvider.overrideWithValue(MessagingRepository(dio)),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();

  expect(find.widgetWithText(OutlinedButton, 'Message'), findsOneWidget);
}