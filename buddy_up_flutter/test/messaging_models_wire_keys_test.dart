import 'package:flutter_test/flutter_test.dart';
import 'package:buddy_up_flutter/data/models/messaging.dart';

/// Every payload below is shaped from the backend serializer that produces it,
/// not from the Dart model — `backend/apps/messaging/serializers.py` and the
/// `Response({...})` dicts in `views.py` / `consumers.py`. DRF emits snake_case,
/// so these fixtures are the regression net for the `@JsonKey` annotations on
/// the community, call-log, link-preview and pending-call models: before they
/// existed, decoding any of these threw a `type 'Null' is not a subtype of
/// type 'String'`.
void main() {
  // ── fixtures ─────────────────────────────────────────────────────────────

  /// `ConversationSerializer.Meta.fields`, exactly.
  Map<String, dynamic> conversationJson({
    String id = '11111111-1111-1111-1111-111111111111',
    bool isGroup = false,
    bool isCommunity = false,
    String groupName = '',
    String origin = 'direct',
  }) {
    return {
      'id': id,
      'is_group': isGroup,
      'is_community': isCommunity,
      'group_name': groupName,
      'group_avatar_url': null,
      'group_gym_id': null,
      'description': '',
      'cover_url': null,
      'invite_code': null,
      'is_public': false,
      'sub_channel': null,
      'call_in_progress': false,
      'origin': origin,
      'promoted_at': null,
      'promotable': true,
      'promotion_status': null,
      'promotion_id': null,
      'participants_data': [
        {
          'user_id': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
          'username': 'sam',
          'display_name': 'Sam Rivera',
          'avatar_url': 'https://cdn.example.com/sam.jpg',
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
  }

  /// `CommunityMemberSerializer.Meta.fields`, exactly.
  Map<String, dynamic> memberJson({
    String role = 'admin',
    String? avatarUrl = 'https://cdn.example.com/sam.jpg',
  }) {
    return {
      'user_id': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      'username': 'sam',
      'display_name': 'Sam Rivera',
      'avatar_url': avatarUrl,
      'verification_status': 'verified',
      'role': role,
      'created_at': '2026-02-01T09:00:00Z',
    };
  }

  /// `CommunityPostCommentSerializer.get_author_data` — note it sends no
  /// `role`, unlike the post's own author block.
  Map<String, dynamic> commentAuthorJson() => {
        'user_id': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        'username': 'sam',
        'display_name': 'Sam Rivera',
        'avatar_url': '',
      };

  /// `CommunityPostCommentSerializer.Meta.fields`, exactly.
  Map<String, dynamic> commentJson({
    String id = '33333333-3333-3333-3333-333333333333',
    String? replyToId,
    int replyCount = 0,
  }) {
    return {
      'id': id,
      'post_id': '22222222-2222-2222-2222-222222222222',
      'body': 'Count me in.',
      'reply_to_id': replyToId,
      'author_data': commentAuthorJson(),
      'reply_count': replyCount,
      'created_at': '2026-03-01T11:00:00Z',
    };
  }

  /// Sentinel so a fixture can pass an explicit `comments: null` — which is
  /// what the create and detail responses send — and still get a populated
  /// list when the argument is left out.
  const withDefaultComments = Object();

  /// `CommunityPostSerializer.Meta.fields`, with `include_comments: True` —
  /// what `CommunityPostListView.get` returns.
  Map<String, dynamic> postJson({
    Object? comments = withDefaultComments,
    bool isLiked = true,
  }) {
    return {
      'id': '22222222-2222-2222-2222-222222222222',
      'conversation_id': '11111111-1111-1111-1111-111111111111',
      'author_id': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      'body': 'Sunday long run at 8.',
      'media_url': 'https://cdn.example.com/run.jpg',
      'media_mime': 'image/jpeg',
      'is_pinned': true,
      'like_count': 4,
      'comment_count': 2,
      'author_data': {
        'user_id': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        'username': 'sam',
        'display_name': 'Sam Rivera',
        'avatar_url': 'https://cdn.example.com/sam.jpg',
        'role': 'user',
      },
      'is_liked': isLiked,
      'comments': identical(comments, withDefaultComments)
          ? [commentJson()]
          : comments,
      'created_at': '2026-03-01T10:30:00Z',
    };
  }

  /// `CallLogSerializer.Meta.fields`, exactly.
  Map<String, dynamic> callLogJson() {
    return {
      'id': '44444444-4444-4444-4444-444444444444',
      'conversation_id': '11111111-1111-1111-1111-111111111111',
      'call_type': 'video',
      'status': 'answered',
      'duration_seconds': 95,
      'caller_data': {
        'username': 'sam',
        'display_name': 'Sam Rivera',
        'avatar_url': null,
      },
      'callee_data': {
        'username': 'me',
        'display_name': 'Me',
        'avatar_url': 'https://cdn.example.com/me.jpg',
      },
      'created_at': '2026-03-01T12:00:00Z',
      'ended_at': '2026-03-01T12:01:35Z',
    };
  }

  group('CommunityMember', () {
    test('decodes CommunityMemberSerializer fields', () {
      final m = CommunityMember.fromJson(memberJson());

      expect(m.userId, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa');
      expect(m.username, 'sam');
      expect(m.displayName, 'Sam Rivera');
      expect(m.avatarUrl, 'https://cdn.example.com/sam.jpg');
      expect(m.verificationStatus, 'verified');
      expect(m.role, 'admin');
      expect(m.createdAt, '2026-02-01T09:00:00Z');
    });

    test('a member with no avatar decodes as an empty string', () {
      final m = CommunityMember.fromJson(memberJson(role: 'member', avatarUrl: null));

      expect(m.avatarUrl, isEmpty);
      expect(m.role, 'member');
    });
  });

  group('CommunityPostComment', () {
    test('decodes post_id, reply_count and the nested author', () {
      final c = CommunityPostComment.fromJson(commentJson());

      expect(c.postId, '22222222-2222-2222-2222-222222222222');
      expect(c.body, 'Count me in.');
      expect(c.replyToId, isNull);
      expect(c.replyCount, 0);
      expect(c.authorData.userId, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa');
      expect(c.authorData.displayName, 'Sam Rivera');
      // The comment serializer never sends role — it must not throw.
      expect(c.authorData.role, isEmpty);
      expect(c.createdAt, '2026-03-01T11:00:00Z');
    });

    test('a threaded reply keeps reply_to_id and its reply_count', () {
      final c = CommunityPostComment.fromJson(commentJson(
        id: '55555555-5555-5555-5555-555555555555',
        replyToId: '33333333-3333-3333-3333-333333333333',
        replyCount: 2,
      ));

      expect(c.replyToId, '33333333-3333-3333-3333-333333333333');
      expect(c.replyCount, 2);
    });
  });

  group('CommunityPost', () {
    test('decodes the feed row including author_data and comments', () {
      final p = CommunityPost.fromJson(postJson());

      expect(p.conversationId, '11111111-1111-1111-1111-111111111111');
      expect(p.authorId, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa');
      expect(p.body, 'Sunday long run at 8.');
      expect(p.mediaUrl, 'https://cdn.example.com/run.jpg');
      expect(p.mediaMime, 'image/jpeg');
      expect(p.isPinned, isTrue);
      expect(p.likeCount, 4);
      expect(p.commentCount, 2);
      expect(p.isLiked, isTrue);
      expect(p.authorData.username, 'sam');
      expect(p.authorData.role, 'user');
      expect(p.comments, hasLength(1));
      expect(p.comments.first.postId, p.id);
      expect(p.createdAt, '2026-03-01T10:30:00Z');
    });

    test('comments: null (create and detail responses) decodes as empty', () {
      // CommunityPostSerializer.get_comments returns None unless the request
      // context carries include_comments.
      final p = CommunityPost.fromJson(postJson(comments: null, isLiked: false));

      expect(p.comments, isEmpty);
      expect(p.isLiked, isFalse);
    });

    test('a missing author block falls back to an empty brief', () {
      final json = postJson()..remove('author_data');

      final p = CommunityPost.fromJson(json);

      expect(p.authorData.userId, isEmpty);
      expect(p.authorData.displayName, isEmpty);
    });
  });

  group('CommunityListData', () {
    test('decodes the {mine, discover} envelope', () {
      final list = CommunityListData.fromJson({
        'mine': [conversationJson(id: 'aaaa', groupName: 'Trail Crew')],
        'discover': [conversationJson(id: 'bbbb', origin: 'discovery')],
      });

      expect(list.mine, hasLength(1));
      expect(list.mine.first.groupName, 'Trail Crew');
      expect(list.discover.first.origin, 'discovery');
      // Nulls on the wire (cover_url, invite_code, sub_channel, avatar-free
      // members) must not throw and must read as ''.
      expect(list.mine.first.inviteCode, isEmpty);
      expect(list.mine.first.participantsData.first.username, 'sam');
    });

    test('an absent discover list decodes as empty', () {
      final list = CommunityListData.fromJson({'mine': []});

      expect(list.discover, isEmpty);
    });
  });

  group('CommunityDetail', () {
    test('decodes the detail row with members, member_count and my_role', () {
      final detail = CommunityDetail.fromJson({
        ...conversationJson(isGroup: true, isCommunity: true, groupName: 'Trail Crew'),
        'membership_role': 'owner',
        'my_role': 'owner',
        'member_count': 3,
        'members': [
          memberJson(role: 'owner'),
          memberJson(role: 'admin'),
          memberJson(role: 'member'),
        ],
      });

      expect(detail.groupName, 'Trail Crew');
      expect(detail.isGroup, isTrue);
      expect(detail.isCommunity, isTrue);
      expect(detail.myRole, 'owner');
      expect(detail.membershipRole, 'owner');
      expect(detail.memberCount, 3);
      expect(detail.members.map((m) => m.role), ['owner', 'admin', 'member']);
      expect(detail.members.first.username, 'sam');
      expect(detail.members.first.displayName, 'Sam Rivera');
      expect(detail.members.first.createdAt, '2026-02-01T09:00:00Z');
    });

    test('the create/join responses carry no member keys at all', () {
      // CommunityListView.post and CommunityJoinView return the bare
      // ConversationSerializer, so members/member_count/my_role are absent.
      final detail = CommunityDetail.fromJson(
        conversationJson(isGroup: true, isCommunity: true, groupName: 'New Group'),
      );

      expect(detail.members, isEmpty);
      expect(detail.memberCount, 0);
      expect(detail.myRole, isNull);
    });

    test('a non-member detail row decodes with a null my_role', () {
      final detail = CommunityDetail.fromJson({
        ...conversationJson(isGroup: true, isCommunity: true, groupName: 'Public Crew'),
        'my_role': null,
        'member_count': 12,
        'members': <Map<String, dynamic>>[],
      });

      expect(detail.myRole, isNull);
      expect(detail.memberCount, 12);
      expect(detail.members, isEmpty);
    });
  });

  group('CallLog', () {
    test('decodes CallLogSerializer fields and both computed blocks', () {
      final log = CallLog.fromJson(callLogJson());

      expect(log.conversationId, '11111111-1111-1111-1111-111111111111');
      expect(log.callType, 'video');
      expect(log.status, 'answered');
      expect(log.durationSeconds, 95);
      expect(log.callerData['display_name'], 'Sam Rivera');
      expect(log.callerData['avatar_url'], isNull);
      expect(log.calleeData['username'], 'me');
      expect(log.createdAt, '2026-03-01T12:00:00Z');
      expect(log.endedAt, '2026-03-01T12:01:35Z');
    });

    test('a missed call with no ended_at decodes with nulls', () {
      final log = CallLog.fromJson({
        ...callLogJson(),
        'status': 'missed',
        'duration_seconds': 0,
        'ended_at': null,
      });

      expect(log.status, 'missed');
      expect(log.durationSeconds, 0);
      expect(log.endedAt, isNull);
    });
  });

  group('LinkPreviewData', () {
    test('decodes the LinkPreviewView payload', () {
      final p = LinkPreviewData.fromJson({
        'url': 'https://example.com/trails',
        'title': 'Trail conditions',
        'description': 'Updated this morning.',
        'image': 'https://cdn.example.com/trail.png',
        'domain': 'example.com',
      });

      expect(p.url, 'https://example.com/trails');
      expect(p.title, 'Trail conditions');
      expect(p.description, 'Updated this morning.');
      expect(p.image, 'https://cdn.example.com/trail.png');
      expect(p.domain, 'example.com');
    });

    test('the fallback preview (title set to the url) decodes', () {
      // LinkPreviewView seeds every key with '' and falls back to the url when
      // the page yields no Open Graph tags.
      final p = LinkPreviewData.fromJson({
        'url': 'https://example.com/x',
        'title': 'https://example.com/x',
        'description': '',
        'image': '',
        'domain': 'example.com',
      });

      expect(p.title, 'https://example.com/x');
      expect(p.description, isEmpty);
      expect(p.image, isEmpty);
    });
  });

  group('PendingCall', () {
    test('decodes the incoming_call payload a session start pushes', () {
      // ConversationCallSessionView._notify_members, 'incoming_call' branch.
      final call = PendingCall.fromJson({
        'type': 'incoming_call',
        'session_id': '66666666-6666-6666-6666-666666666666',
        'conversation_id': '11111111-1111-1111-1111-111111111111',
        'call_type': 'video',
        'from_user_id': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        'from_username': 'sam',
        'from_display_name': 'Sam Rivera',
        'from_avatar_url': 'https://cdn.example.com/sam.jpg',
        'participant_count': 1,
      });

      expect(call.conversationId, '11111111-1111-1111-1111-111111111111');
      expect(call.fromUserId, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa');
      expect(call.fromUsername, 'sam');
      expect(call.fromDisplayName, 'Sam Rivera');
      expect(call.fromAvatarUrl, 'https://cdn.example.com/sam.jpg');
      expect(call.callType, 'video');
      // No signalling payload on this branch.
      expect(call.data, isEmpty);
    });

    test('decodes the call_offer relay, which does carry sdp data', () {
      // ChatConsumer._handle_call_signal payload.
      final call = PendingCall.fromJson({
        'type': 'call_offer',
        'conversation_id': '11111111-1111-1111-1111-111111111111',
        'from_user_id': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        'from_username': 'sam',
        'from_display_name': 'Sam Rivera',
        'from_avatar_url': null,
        'data': {
          'sdp': {'type': 'offer', 'sdp': 'v=0'},
        },
        'call_type': 'audio',
      });

      expect(call.fromAvatarUrl, isEmpty);
      expect(call.callType, 'audio');
      expect((call.data['sdp'] as Map<String, dynamic>)['type'], 'offer');
    });
  });

  group('No unannotated camelCase keys remain', () {
    // The original defect: a model with no @JsonKey read `json['displayName']`
    // against a snake_case payload and threw. Assert on the decoded values, not
    // on the annotations, so a dropped annotation fails here too.
    test('a bare community post keeps its identity fields', () {
      final p = CommunityPost.fromJson({'id': 'post-1'});

      expect(p.id, 'post-1');
      expect(p.conversationId, isEmpty);
      expect(p.authorId, isEmpty);
      expect(p.authorData.username, isEmpty);
      expect(p.createdAt, isEmpty);
      expect(p.comments, isEmpty);
    });

    test('a bare comment, member, detail, call log and pending call decode', () {
      expect(CommunityPostComment.fromJson({'id': 'c1'}).postId, isEmpty);
      expect(CommunityMember.fromJson({'user_id': 'u1'}).displayName, isEmpty);
      expect(CommunityDetail.fromJson({'id': 'd1'}).members, isEmpty);
      expect(CallLog.fromJson({'id': 'l1'}).callerData, isEmpty);
      expect(PendingCall.fromJson({'conversation_id': 'x'}).fromUserId, isEmpty);
    });
  });
}