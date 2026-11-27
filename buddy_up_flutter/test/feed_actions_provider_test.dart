import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buddy_up_flutter/data/models/post.dart';
import 'package:buddy_up_flutter/data/repositories/feed_repository.dart';
import 'package:buddy_up_flutter/features/feed/providers/feed_provider.dart';

/// Post actions return shaped payloads that are NOT always a Post:
/// `/react/` returns a reaction_counts map, `/poll/vote/` returns a Poll,
/// `/repost/` returns a top-level repost_count. These tests lock the client
/// behaviour to the backend contract (optimistic update + rollback).
void main() {
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

  Post post(String id, [Map<String, dynamic>? extra]) =>
      Post.fromJson(postJson(id, extra));

  late List<RequestOptions> seen;
  int failStatus = 0;
  Map<String, dynamic> responseBody = {'data': <String, dynamic>{}};

  ProviderContainer makeContainer() {
    seen = <RequestOptions>[];
    failStatus = 0;
    responseBody = {'data': <String, dynamic>{}};
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          seen.add(options);
          if (failStatus >= 400) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.badResponse,
                response: Response(
                  requestOptions: options,
                  statusCode: failStatus,
                  data: {'message': 'Server says no'},
                ),
              ),
            );
            return;
          }
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: responseBody,
            ),
          );
        },
      ),
    );
    final container = ProviderContainer(
      overrides: [
        feedRepositoryProvider.overrideWithValue(FeedRepository(dio)),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('reactTo', () {
    test('adds a reaction and POSTs the react endpoint', () async {
      final c = makeContainer();
      final n = c.read(feedProvider.notifier);
      n.addPostToTop(post('p1'));

      await n.reactTo('p1', '💪');

      final updated = c.read(feedProvider).posts.single;
      expect(updated.userReaction, '💪');
      expect(updated.reactionCounts['💪'], 1);
      expect(seen.single.method, 'POST');
      expect(seen.single.path, '/feed/p1/react/');
      expect(
        (seen.single.data as ReactionInput).reactionType,
        '💪',
      );
    });

    test('tapping the same reaction removes it via DELETE', () async {
      final c = makeContainer();
      final n = c.read(feedProvider.notifier);
      n.addPostToTop(
        post('p1', {
          'user_reaction': '💪',
          'reaction_counts': {'💪': 1},
        }),
      );

      await n.reactTo('p1', '💪');

      final updated = c.read(feedProvider).posts.single;
      expect(updated.userReaction, isNull);
      expect(updated.reactionCounts['💪'], isNull);
      expect(seen.single.method, 'DELETE');
      expect(seen.single.path, '/feed/p1/react/');
    });

    test('rolls back on failure', () async {
      final c = makeContainer();
      final n = c.read(feedProvider.notifier);
      n.addPostToTop(post('p1'));
      failStatus = 500;

      await n.reactTo('p1', '💪');

      final updated = c.read(feedProvider).posts.single;
      expect(updated.userReaction, isNull);
      expect(updated.reactionCounts, isEmpty);
    });
  });

  group('toggleSaveById', () {
    test('saves and unsaves with matching verbs', () async {
      final c = makeContainer();
      final n = c.read(feedProvider.notifier);
      n.addPostToTop(post('p1'));

      await n.toggleSaveById('p1');
      var updated = c.read(feedProvider).posts.single;
      expect(updated.isSaved, isTrue);
      expect(updated.saveCount, 1);
      expect(seen.last.method, 'POST');
      expect(seen.last.path, '/feed/p1/save/');

      await n.toggleSaveById('p1');
      updated = c.read(feedProvider).posts.single;
      expect(updated.isSaved, isFalse);
      expect(updated.saveCount, 0);
      expect(seen.last.method, 'DELETE');
      expect(seen.last.path, '/feed/p1/save/');
    });

    test('rolls back on failure', () async {
      final c = makeContainer();
      final n = c.read(feedProvider.notifier);
      n.addPostToTop(post('p1'));
      failStatus = 500;

      await n.toggleSaveById('p1');

      final updated = c.read(feedProvider).posts.single;
      expect(updated.isSaved, isFalse);
      expect(updated.saveCount, 0);
    });
  });

  group('toggleRepost', () {
    test('applies the top-level repost_count from the envelope', () async {
      final c = makeContainer();
      final n = c.read(feedProvider.notifier);
      n.addPostToTop(post('p1'));
      responseBody = {
        'success': true,
        'action': 'reposted',
        'repost_count': 7,
        'data': null,
      };

      await n.toggleRepost('p1');

      final updated = c.read(feedProvider).posts.single;
      expect(updated.isRepostedByMe, isTrue);
      expect(updated.repostCount, 7);
      expect(seen.single.method, 'POST');
      expect(seen.single.path, '/feed/p1/repost/');
    });

    test('rolls back on failure', () async {
      final c = makeContainer();
      final n = c.read(feedProvider.notifier);
      n.addPostToTop(post('p1'));
      failStatus = 500;

      await n.toggleRepost('p1');

      final updated = c.read(feedProvider).posts.single;
      expect(updated.isRepostedByMe, isFalse);
      expect(updated.repostCount, 0);
    });
  });

  group('poll vote payload', () {
    test('Poll.fromJson accepts the PollSerializer shape', () {
      // Exact keys emitted by backend PollSerializer after a vote.
      final poll = Poll.fromJson({
        'id': 'poll-1',
        'question': 'Leg day?',
        'closes_at': '2026-02-01T00:00:00Z',
        'allow_multiple': false,
        'min_selections': 1,
        'max_selections': 1,
        'total_votes': 4,
        'is_closed': false,
        'options': [
          {'id': 'o1', 'text': 'Yes', 'vote_count': 3},
          {'id': 'o2', 'text': 'No', 'vote_count': 1},
        ],
        'user_voted_option_ids': ['o1'],
      });

      expect(poll.id, 'poll-1');
      expect(poll.totalVotes, 4);
      expect(poll.userVotedOptionIds, ['o1']);
      expect(poll.options.length, 2);
    });
  });
}
