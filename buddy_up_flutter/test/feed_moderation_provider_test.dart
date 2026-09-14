import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buddy_up_flutter/data/models/post.dart';
import 'package:buddy_up_flutter/data/repositories/feed_repository.dart';
import 'package:buddy_up_flutter/data/repositories/profile_repository.dart';
import 'package:buddy_up_flutter/features/feed/providers/feed_provider.dart';

/// Optimistic-update + rollback behaviour for the additive Bud Press parity
/// methods: hide/unhide, mute, block, report, engagement-target reactions.
void main() {
  Map<String, dynamic> postJson(
    String id,
    String username, [
    Map<String, dynamic>? extra,
  ]) {
    return {
      'id': id,
      'author_data': {
        'user_id': 'uid-$username',
        'username': username,
        'display_name': username,
        'avatar_url': '',
        'verification_status': 'none',
      },
      'created_at': '2026-01-01T00:00:00Z',
      ...?extra,
    };
  }

  Post post(String id, String username, [Map<String, dynamic>? extra]) =>
      Post.fromJson(postJson(id, username, extra));

  late List<RequestOptions> seen;
  int failStatus = 0;

  ProviderContainer makeContainer() {
    seen = <RequestOptions>[];
    failStatus = 0;
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
              data: {'data': <String, dynamic>{}},
            ),
          );
        },
      ),
    );
    final container = ProviderContainer(
      overrides: [
        feedRepositoryProvider.overrideWithValue(FeedRepository(dio)),
        profileRepositoryProvider.overrideWithValue(ProfileRepository(dio)),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  List<String> ids(ProviderContainer c) =>
      c.read(feedProvider).posts.map((p) => p.id).toList();

  group('hidePostById', () {
    test('removes the card and POSTs the hide endpoint', () async {
      final c = makeContainer();
      final n = c.read(feedProvider.notifier);
      n.addPostToTop(post('p2', 'bob'));
      n.addPostToTop(post('p1', 'alice'));

      final err = await n.hidePostById('p1');

      expect(err, isNull);
      expect(ids(c), ['p2']);
      expect(seen.single.method, 'POST');
      expect(seen.single.path, '/feed/p1/hide/');
    });

    test('404 keeps the post and returns the server message', () async {
      final c = makeContainer();
      final n = c.read(feedProvider.notifier);
      n.addPostToTop(post('p1', 'alice'));
      failStatus = 404;

      final err = await n.hidePostById('p1');

      expect(err, 'Server says no');
      expect(ids(c), ['p1']);
    });

    test('500 rolls back to the snapshot', () async {
      final c = makeContainer();
      final n = c.read(feedProvider.notifier);
      n.addPostToTop(post('p2', 'bob'));
      n.addPostToTop(post('p1', 'alice'));
      failStatus = 500;

      final err = await n.hidePostById('p1');

      expect(err, isNotNull);
      expect(ids(c), ['p1', 'p2']);
    });
  });

  group('unhidePost', () {
    test('DELETEs and re-inserts the card', () async {
      final c = makeContainer();
      final n = c.read(feedProvider.notifier);
      final p = post('p1', 'alice');

      final err = await n.unhidePost(p);

      expect(err, isNull);
      expect(seen.single.method, 'DELETE');
      expect(seen.single.path, '/feed/p1/hide/');
      expect(ids(c), ['p1']);
    });
  });

  group('muteAuthor', () {
    test("removes the author's cards and POSTs the mute endpoint", () async {
      final c = makeContainer();
      final n = c.read(feedProvider.notifier);
      n.addPostToTop(post('p3', 'alice'));
      n.addPostToTop(post('p2', 'bob'));
      n.addPostToTop(post('p1', 'alice'));

      final err = await n.muteAuthor('alice');

      expect(err, isNull);
      expect(ids(c), ['p2']);
      expect(seen.single.method, 'POST');
      expect(seen.single.path, '/profiles/alice/mute/');
    });

    test('failure restores the snapshot', () async {
      final c = makeContainer();
      final n = c.read(feedProvider.notifier);
      n.addPostToTop(post('p2', 'bob'));
      n.addPostToTop(post('p1', 'alice'));
      failStatus = 404;

      final err = await n.muteAuthor('alice');

      expect(err, isNotNull);
      expect(ids(c), ['p1', 'p2']);
    });
  });

  group('blockAuthor', () {
    test("blocks and removes the author's cards", () async {
      final c = makeContainer();
      final n = c.read(feedProvider.notifier);
      n.addPostToTop(post('p2', 'bob'));
      n.addPostToTop(post('p1', 'alice'));

      final err = await n.blockAuthor('alice');

      expect(err, isNull);
      expect(ids(c), ['p2']);
      expect(seen.single.method, 'POST');
      expect(seen.single.path, '/profiles/alice/block/');
    });

    test('failure restores the snapshot', () async {
      final c = makeContainer();
      final n = c.read(feedProvider.notifier);
      n.addPostToTop(post('p1', 'alice'));
      failStatus = 500;

      final err = await n.blockAuthor('alice');

      expect(err, isNotNull);
      expect(ids(c), ['p1']);
    });
  });

  group('submitReport', () {
    test('POSTs the moderation report body', () async {
      final c = makeContainer();
      final n = c.read(feedProvider.notifier);

      final err = await n.submitReport(
        targetUser: 'uid-alice',
        reason: 'spam',
        description: 'scam link',
        contentUrl: '/feed/p1',
      );

      expect(err, isNull);
      expect(seen.single.method, 'POST');
      expect(seen.single.path, '/moderation/reports/');
      final body = seen.single.data as Map;
      expect(body['target_user'], 'uid-alice');
      expect(body['reason'], 'spam');
    });

    test('returns a message on failure', () async {
      final c = makeContainer();
      failStatus = 500;

      final err =
          await c.read(feedProvider.notifier).submitReport(
                targetUser: 'uid-alice',
                reason: 'spam',
              );

      expect(err, isNotNull);
    });
  });

  group('toggleReactionForRow', () {
    test('likes a plain row and POSTs the react endpoint', () async {
      final c = makeContainer();
      final n = c.read(feedProvider.notifier);
      n.addPostToTop(post('p1', 'alice'));

      await n.toggleReactionForRow(
          rowId: 'p1', targetId: 'p1', emoji: 'fire');

      final updated = c.read(feedProvider).posts.single;
      expect(updated.userReaction, 'fire');
      expect(updated.reactionCounts['fire'], 1);
      expect(seen.single.method, 'POST');
      expect(seen.single.path, '/feed/p1/react/');
    });

    test('targets the original id on repost rows', () async {
      final c = makeContainer();
      final n = c.read(feedProvider.notifier);
      n.addPostToTop(
        post('row1', 'bob', {
          'is_repost': true,
          'original_post_id': 'orig9',
          'original_post_data': {
            'id': 'orig9',
            'author_data': {
              'username': 'alice',
              'display_name': 'alice',
              'avatar_url': '',
            },
            'body': 'hello',
            'created_at': '2026-01-01T00:00:00Z',
          },
        }),
      );

      await n.toggleReactionForRow(
          rowId: 'row1', targetId: 'orig9', emoji: 'fire');

      final updated = c.read(feedProvider).posts.single;
      expect(updated.originalPostData?.userReaction, 'fire');
      expect(seen.single.path, '/feed/orig9/react/');
    });

    test('rolls back on failure', () async {
      final c = makeContainer();
      final n = c.read(feedProvider.notifier);
      n.addPostToTop(post('p1', 'alice'));
      failStatus = 500;

      await n.toggleReactionForRow(
          rowId: 'p1', targetId: 'p1', emoji: 'fire');

      expect(c.read(feedProvider).posts.single.userReaction, isNull);
    });
  });

  group('submitComment', () {
    test('rejects blank bodies without a network call', () async {
      final c = makeContainer();

      final err = await c.read(feedProvider.notifier).submitComment('p1', '  ');

      expect(err, isNotNull);
      expect(seen, isEmpty);
    });

    test('POSTs the comment', () async {
      final c = makeContainer();

      final err =
          await c.read(feedProvider.notifier).submitComment('p1', 'Nice!');

      expect(err, isNull);
      expect(seen.single.method, 'POST');
      expect(seen.single.path, '/feed/p1/comments/');
    });
  });
}
