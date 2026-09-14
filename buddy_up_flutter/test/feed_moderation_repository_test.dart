import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buddy_up_flutter/data/repositories/feed_repository.dart';

/// Verifies the additive Bud Press parity endpoints hit the exact backend
/// contract: hide/unhide, mute/unmute, moderation reports.
void main() {
  final seen = <RequestOptions>[];
  late FeedRepository repo;

  Map<String, dynamic>? forcedError;

  setUp(() {
    seen.clear();
    forcedError = null;
    final dio = Dio(BaseOptions(baseUrl: 'https://test.invalid/api/v1'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          seen.add(options);
          final err = forcedError;
          if (err != null) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.badResponse,
                response: Response(
                  requestOptions: options,
                  statusCode: err['status'] as int,
                  data: err['data'],
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
    repo = FeedRepository(dio);
  });

  RequestOptions single() {
    expect(seen, hasLength(1));
    return seen.single;
  }

  test('hidePost POSTs /feed/<id>/hide/', () async {
    await repo.hidePost('p1');
    final req = single();
    expect(req.method, 'POST');
    expect(req.path, '/feed/p1/hide/');
  });

  test('unhidePost DELETEs /feed/<id>/hide/', () async {
    await repo.unhidePost('p1');
    final req = single();
    expect(req.method, 'DELETE');
    expect(req.path, '/feed/p1/hide/');
  });

  test('muteUser POSTs /profiles/<username>/mute/', () async {
    await repo.muteUser('alice');
    final req = single();
    expect(req.method, 'POST');
    expect(req.path, '/profiles/alice/mute/');
  });

  test('unmuteUser DELETEs /profiles/<username>/unmute/', () async {
    await repo.unmuteUser('alice');
    final req = single();
    expect(req.method, 'DELETE');
    expect(req.path, '/profiles/alice/unmute/');
  });

  test('submitModerationReport POSTs /moderation/reports/ with body', () async {
    await repo.submitModerationReport({
      'target_user': 'uid-1',
      'reason': 'spam',
      'description': 'looks scammy',
      'content_url': '/feed/p1',
    });
    final req = single();
    expect(req.method, 'POST');
    expect(req.path, '/moderation/reports/');
    final body = req.data as Map;
    expect(body['target_user'], 'uid-1');
    expect(body['reason'], 'spam');
    expect(body['description'], 'looks scammy');
    expect(body['content_url'], '/feed/p1');
  });

  test('backend 404 surfaces as DioException for defensive handling',
      () async {
    forcedError = {
      'status': 404,
      'data': {'message': 'No Post matches the given query.'},
    };
    try {
      await repo.hidePost('missing');
      fail('expected DioException');
    } on DioException catch (e) {
      expect(e.response?.statusCode, 404);
    }
    expect(seen.single.path, '/feed/missing/hide/');
  });
}
