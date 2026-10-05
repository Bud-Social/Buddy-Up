import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buddy_up_flutter/data/models/messaging.dart';
import 'package:buddy_up_flutter/data/repositories/messaging_repository.dart';
import 'package:buddy_up_flutter/features/messaging/providers/messaging_provider.dart';

/// The promote flow: a discovery DM can ask to become a buddy relationship,
/// and every state of that ask reads back from `Conversation.origin` /
/// `promotable` / `promotion_status`.
void main() {
  Map<String, dynamic> convoJson({
    String origin = 'discovery',
    bool promotable = true,
    String? promotionStatus,
    String? promotedAt,
  }) {
    // Keys exactly as ConversationSerializer emits them.
    return {
      'id': 'c1',
      'origin': origin,
      'promotable': promotable,
      'promotion_status': promotionStatus,
      'promoted_at': promotedAt,
      'created_at': '2026-01-01T00:00:00Z',
    };
  }

  Conversation convo({
    String origin = 'discovery',
    bool promotable = true,
    String? promotionStatus,
    String? promotedAt,
  }) {
    return Conversation.fromJson(convoJson(
      origin: origin,
      promotable: promotable,
      promotionStatus: promotionStatus,
      promotedAt: promotedAt,
    ));
  }

  group('Conversation promotion fields', () {
    test('reads origin, promotable and promotion_status', () {
      final c = convo(
        origin: 'discovery',
        promotable: true,
        promotionStatus: 'pending',
      );
      expect(c.origin, 'discovery');
      expect(c.promotable, isTrue);
      expect(c.promotionStatus, 'pending');
      expect(c.promotedAt, isNull);
    });

    test('a confirmed buddy pair is no longer promotable', () {
      final c = convo(
        origin: 'buddy',
        promotable: false,
        promotionStatus: 'accepted',
        promotedAt: '2026-02-01T10:00:00Z',
      );
      expect(c.origin, 'buddy');
      expect(c.promotable, isFalse);
      expect(c.promotedAt, isNotNull);
    });

    test('defaults to a plain direct thread on an older payload', () {
      final c = Conversation.fromJson({'id': 'c2'});
      expect(c.origin, 'direct');
      expect(c.promotable, isFalse);
      expect(c.promotionStatus, isNull);
    });
  });

  group('ConversationFilter.discovery', () {
    test('keeps discovery-born threads', () {
      expect(ConversationFilter.discovery.matches(convo(origin: 'discovery')), isTrue);
    });

    test('keeps a promoted thread, so accepting never hides the chat', () {
      expect(ConversationFilter.discovery.matches(convo(origin: 'buddy')), isTrue);
    });

    test('drops threads that did not come from discovery', () {
      expect(ConversationFilter.discovery.matches(convo(origin: 'direct')), isFalse);
    });

    test('drops group and community chats', () {
      final group = convo(origin: 'discovery').copyWith(isGroup: true);
      final community = convo(origin: 'discovery').copyWith(isCommunity: true);
      expect(ConversationFilter.discovery.matches(group), isFalse);
      expect(ConversationFilter.discovery.matches(community), isFalse);
    });
  });

  group('Buddy messages list', () {
    test('narrows one payload to the discovery threads', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) => handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'data': [
                  convoJson(),
                  convoJson(origin: 'direct'),
                  convoJson(origin: 'buddy', promotable: false),
                ],
              },
            ),
          ),
        ),
      );
      final container = ProviderContainer(
        overrides: [messagingRepositoryProvider.overrideWithValue(MessagingRepository(dio))],
      );
      addTearDown(container.dispose);

      await container.read(conversationsProvider.notifier)
          .load(filter: ConversationFilter.discovery);

      final state = container.read(conversationsProvider);
      expect(state.conversations, hasLength(2));
      expect(
        state.conversations.map((c) => c.origin),
        ['discovery', 'buddy'],
      );
    });

    test('an unfiltered load shows everything again', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) => handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'data': [convoJson(), convoJson(origin: 'direct')],
              },
            ),
          ),
        ),
      );
      final container = ProviderContainer(
        overrides: [messagingRepositoryProvider.overrideWithValue(MessagingRepository(dio))],
      );
      addTearDown(container.dispose);

      final notifier = container.read(conversationsProvider.notifier);
      await notifier.load(filter: ConversationFilter.discovery);
      expect(container.read(conversationsProvider).conversations, hasLength(1));

      await notifier.load(clearFilter: true);
      expect(container.read(conversationsProvider).conversations, hasLength(2));
    });

    test('a filtered list never grows a row the filter rejects', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) => handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {'data': <Map<String, dynamic>>[]},
            ),
          ),
        ),
      );
      final container = ProviderContainer(
        overrides: [messagingRepositoryProvider.overrideWithValue(MessagingRepository(dio))],
      );
      addTearDown(container.dispose);

      final notifier = container.read(conversationsProvider.notifier);
      await notifier.load(filter: ConversationFilter.discovery);

      notifier.updateConversation(convo(origin: 'direct'));
      expect(container.read(conversationsProvider).conversations, isEmpty);

      notifier.updateConversation(convo(origin: 'discovery'));
      expect(container.read(conversationsProvider).conversations, hasLength(1));
    });
  });

  group('Promote requests', () {
    ProviderContainer containerReturning(
      Map<String, dynamic> Function(RequestOptions options) respond,
    ) {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) => handler.resolve(
            Response(requestOptions: options, statusCode: 200, data: respond(options)),
          ),
        ),
      );
      final container = ProviderContainer(
        overrides: [messagingRepositoryProvider.overrideWithValue(MessagingRepository(dio))],
      );
      addTearDown(container.dispose);
      return container;
    }

    ProviderContainer containerFailing(int status, String message) {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) => handler.reject(
            DioException(
              requestOptions: options,
              response: Response(
                requestOptions: options,
                statusCode: status,
                data: {
                  'success': false,
                  'data': null,
                  'message': message,
                },
              ),
            ),
          ),
        ),
      );
      final container = ProviderContainer(
        overrides: [messagingRepositoryProvider.overrideWithValue(MessagingRepository(dio))],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('promote posts to the conversation promote endpoint', () async {
      final requests = <(String, Object?)>[];
      final container = containerReturning((options) {
        requests.add((options.path, options.data));
        return {
          'data': {
            'id': 'p1',
            'conversation_id': 'c1',
            'status': 'pending',
            'requested_by': 'uid-me',
            'created_at': '2026-02-01T00:00:00Z',
          },
        };
      });

      final err = await container
          .read(conversationsProvider.notifier)
          .promoteConversation('c1');

      expect(err, isNull);
      expect(
        requests.map((r) => r.$1),
        contains('/messaging/conversations/c1/promote/'),
      );
    });

    test('already-buddies (409) surfaces the server wording', () async {
      final container = containerFailing(409, 'You are already buddies.');

      final err = await container
          .read(conversationsProvider.notifier)
          .promoteConversation('c1');

      expect(err, 'You are already buddies.');
    });

    test('accepting a promotion posts {accept: true}', () async {
      final requests = <(String, Object?)>[];
      final container = containerReturning((options) {
        requests.add((options.path, options.data));
        return {
          'data': {
            'id': 'p1',
            'conversation_id': 'c1',
            'status': 'accepted',
            'origin': 'buddy',
            'promoted_at': '2026-02-01T10:00:00Z',
          },
        };
      });

      final err = await container
          .read(conversationsProvider.notifier)
          .respondToPromotion('p1', accept: true);

      expect(err, isNull);
      final respond = requests.firstWhere(
        (r) => r.$1 == '/messaging/conversations/promotions/p1/respond/',
      );
      expect((respond.$2 as Map<String, dynamic>)['accept'], isTrue);
    });

    test('only the other participant may respond — 403 is reported', () async {
      final container = containerFailing(
        403,
        'Only the other participant can respond to this request.',
      );

      final err = await container
          .read(conversationsProvider.notifier)
          .respondToPromotion('p1', accept: true);

      expect(err, 'Only the other participant can respond to this request.');
    });

    test('declining posts {accept: false}', () async {
      final requests = <(String, Object?)>[];
      final container = containerReturning((options) {
        requests.add((options.path, options.data));
        return {
          'data': {
            'id': 'p1',
            'conversation_id': 'c1',
            'status': 'declined',
            'origin': 'discovery',
            'promoted_at': null,
          },
        };
      });

      await container
          .read(conversationsProvider.notifier)
          .respondToPromotion('p1', accept: false);

      final respond = requests.firstWhere(
        (r) => r.$1 == '/messaging/conversations/promotions/p1/respond/',
      );
      expect((respond.$2 as Map<String, dynamic>)['accept'], isFalse);
    });
  });
}