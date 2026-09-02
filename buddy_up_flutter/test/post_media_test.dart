import 'package:flutter_test/flutter_test.dart';
import 'package:buddy_up_flutter/data/models/post.dart';

void main() {
  Post basePost(Map<String, dynamic> extra) {
    return Post.fromJson({
      'id': 'p1',
      'authorData': {
        'username': 'u',
        'displayName': 'U',
        'avatarUrl': '',
        'verificationStatus': 'none',
      },
      'createdAt': '2026-01-01T00:00:00Z',
      ...extra,
    });
  }

  test('Post parses snake_case media + captions + comments_disabled', () {
    final post = basePost({
      'comments_disabled': true,
      'media': [
        {
          'url': 'https://cdn.example.com/v.mp4',
          'media_type': 'video',
          'width': 1080,
          'height': 1920,
          'duration_ms': 42000,
          'poster_url': 'https://cdn.example.com/v.jpg',
          'trim_start_ms': 1500,
          'trim_end_ms': 30000,
          'sound_id': 's1',
          'sound_volume': 0.5,
          'captions': [
            {'start_ms': 0, 'end_ms': 2000, 'text': 'hello'},
          ],
        },
      ],
    });
    expect(post.commentsDisabled, isTrue);
    expect(post.media, hasLength(1));
    final m = post.media.first;
    expect(m.isVideo, isTrue);
    expect(m.url, 'https://cdn.example.com/v.mp4');
    expect(m.posterUrl, 'https://cdn.example.com/v.jpg');
    expect(m.durationMs, 42000);
    expect(m.trimStartMs, 1500);
    expect(m.trimEndMs, 30000);
    expect(m.soundId, 's1');
    expect(m.soundVolume, 0.5);
    expect(m.captions.single.text, 'hello');
    expect(m.captions.single.startMs, 0);
    expect(m.captions.single.endMs, 2000);
  });

  test('Post parses camelCase media keys and defaults', () {
    final post = basePost({
      'media': [
        {'url': 'https://cdn.example.com/i.jpg', 'mediaType': 'image'},
      ],
    });
    expect(post.commentsDisabled, isFalse);
    expect(post.media.single.mediaType, 'image');
    expect(post.media.single.isVideo, isFalse);
    expect(post.media.single.captions, isEmpty);
  });

  test('Post without media defaults to empty list', () {
    final post = basePost({});
    expect(post.media, isEmpty);
  });
}
