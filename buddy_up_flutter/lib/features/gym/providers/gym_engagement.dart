import 'package:dio/dio.dart';

/// Gym-actor engagement calls — the exact mirror of the web console's
/// `gymFeedApi`. Every payload lands as the gym with the acting member as
/// audit trail; the server renders the gym identity.
///
/// Two shapes exist because the feed and communities apps diverged:
///  - feed: ids in the JSON body (`post_id`, `comment_id`), integer comment PKs
///  - community: ids in the path, UUID comment PKs
class GymEngagementService {
  /// Like/react on a post. `reactionType` `like` on community posts maps to the
  /// community like toggle; anything else toggles a typed reaction row.
  /// Returns the decoded `data` payload (community likes carry `like_count`
  /// and `is_reacted`).
  static Future<Map<String, dynamic>> react(
    Dio dio,
    String slug, {
    required String postId,
    required String reactionType,
    String? communityId,
  }) async {
    if (communityId != null && communityId.isNotEmpty) {
      final res = await dio.post(
        '/gyms/$slug/communities/$communityId/posts/$postId/react/',
        data: {'reaction_type': reactionType},
      );
      return _unwrap(res);
    }
    final res = await dio.post(
      '/gyms/$slug/feed/react/',
      data: {'post_id': postId, 'reaction_type': reactionType},
    );
    return _unwrap(res);
  }

  static Future<bool> repost(
    Dio dio,
    String slug, {
    required String postId,
    String? communityId,
  }) async {
    if (communityId != null && communityId.isNotEmpty) {
      final res = await dio.post('/gyms/$slug/communities/$communityId/posts/$postId/repost/');
      return _unwrap(res)['reposted'] == true;
    }
    final res = await dio.post('/gyms/$slug/feed/repost/', data: {'post_id': postId});
    return _unwrap(res)['action'] == 'reposted';
  }

  static Future<bool> toggleSave(
    Dio dio,
    String slug, {
    required String postId,
    String? communityId,
  }) async {
    if (communityId != null && communityId.isNotEmpty) {
      final res = await dio.post('/gyms/$slug/communities/$communityId/posts/$postId/save/');
      return _unwrap(res)['saved'] == true;
    }
    final res = await dio.post('/gyms/$slug/feed/save/', data: {'post_id': postId});
    return _unwrap(res)['saved'] == true;
  }

  /// Comments for a post. Community posts route through the gym endpoint so a
  /// linked-but-not-member gym can read them; feed comments use the public
  /// feed listing (gym-authored rows render as the gym server-side).
  static Future<List<Map<String, dynamic>>> fetchComments(
    Dio dio,
    String slug, {
    required String postId,
    String? communityId,
  }) async {
    if (communityId != null && communityId.isNotEmpty) {
      final res = await dio.get('/gyms/$slug/communities/$communityId/posts/$postId/comments/');
      return _rows(res);
    }
    final res = await dio.get('/feed/$postId/comments/');
    return _rows(res);
  }

  static Future<void> addComment(
    Dio dio,
    String slug, {
    required String postId,
    required String body,
    String? replyToId,
    String? communityId,
  }) async {
    if (communityId != null && communityId.isNotEmpty) {
      final payload = <String, dynamic>{'body': body};
      if (replyToId != null) payload['reply_to_id'] = replyToId;
      await dio.post(
        '/gyms/$slug/communities/$communityId/posts/$postId/comments/',
        data: payload,
      );
      return;
    }
    final feedPayload = <String, dynamic>{
      'post_id': postId,
      'body': body,
    };
    if (replyToId != null) feedPayload['parent_id'] = int.tryParse(replyToId) ?? replyToId;
    await dio.post(
      '/gyms/$slug/feed/comment/',
      data: feedPayload,
    );
  }

  /// Toggle the gym's like on a comment; returns the fresh like count and
  /// whether the gym now likes it.
  static Future<({bool isLiked, int likeCount})> toggleCommentLike(
    Dio dio,
    String slug, {
    required String postId,
    required String commentId,
    String? communityId,
  }) async {
    if (communityId != null && communityId.isNotEmpty) {
      final res = await dio.post(
        '/gyms/$slug/communities/$communityId/posts/$postId/comments/$commentId/like/',
        data: const {},
      );
      final d = _unwrap(res);
      return (isLiked: d['is_liked'] == true, likeCount: (d['like_count'] as num?)?.toInt() ?? 0);
    }
    final res = await dio.post(
      '/gyms/$slug/feed/comments/like/',
      data: {'post_id': postId, 'comment_id': int.tryParse(commentId) ?? commentId},
    );
    final d = _unwrap(res);
    return (isLiked: d['is_liked'] == true, likeCount: _likeCount(d['reaction_counts']));
  }

  static int _likeCount(dynamic reactionCounts) {
    if (reactionCounts is Map<String, dynamic>) {
      final v = reactionCounts['❤️'];
      if (v is num) return v.toInt();
    }
    return 0;
  }

  static Map<String, dynamic> _unwrap(Response res) {
    final body = res.data;
    if (body is Map<String, dynamic>) {
      final d = body['data'];
      return d is Map<String, dynamic> ? d : body;
    }
    return <String, dynamic>{};
  }

  static List<Map<String, dynamic>> _rows(Response res) {
    final body = res.data;
    if (body is Map<String, dynamic>) {
      final d = body['data'];
      if (d is List) return d.whereType<Map>().map((r) => Map<String, dynamic>.from(r)).toList();
    }
    if (body is List) return body.whereType<Map>().map((r) => Map<String, dynamic>.from(r)).toList();
    return const [];
  }
}
