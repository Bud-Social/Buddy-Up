// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messaging.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ParticipantData _$ParticipantDataFromJson(Map<String, dynamic> json) =>
    _ParticipantData(
      userId: json['user_id'] as String? ?? '',
      username: json['username'] as String,
      displayName: json['display_name'] as String,
      avatarUrl: json['avatar_url'] as String? ?? '',
      verificationStatus: json['verification_status'] as String? ?? 'none',
      role: json['role'] as String? ?? '',
    );

Map<String, dynamic> _$ParticipantDataToJson(_ParticipantData instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'username': instance.username,
      'display_name': instance.displayName,
      'avatar_url': instance.avatarUrl,
      'verification_status': instance.verificationStatus,
      'role': instance.role,
    };

_LastMessageData _$LastMessageDataFromJson(Map<String, dynamic> json) =>
    _LastMessageData(
      body: json['body'] as String? ?? '',
      messageType: json['message_type'] as String? ?? 'text',
      mediaUrl: json['media_url'] as String? ?? '',
      senderName: json['sender_name'] as String? ?? '',
    );

Map<String, dynamic> _$LastMessageDataToJson(_LastMessageData instance) =>
    <String, dynamic>{
      'body': instance.body,
      'message_type': instance.messageType,
      'media_url': instance.mediaUrl,
      'sender_name': instance.senderName,
    };

_Conversation _$ConversationFromJson(Map<String, dynamic> json) =>
    _Conversation(
      id: json['id'] as String,
      isGroup: json['is_group'] as bool? ?? false,
      isCommunity: json['is_community'] as bool? ?? false,
      groupName: json['group_name'] as String? ?? '',
      groupAvatarUrl: json['group_avatar_url'] as String? ?? '',
      groupGymId: json['group_gym_id'] as String?,
      subChannel: json['sub_channel'] as String? ?? '',
      callInProgress: json['call_in_progress'] as bool? ?? false,
      description: json['description'] as String? ?? '',
      coverUrl: json['cover_url'] as String? ?? '',
      inviteCode: json['invite_code'] as String? ?? '',
      isPublic: json['is_public'] as bool? ?? false,
      participantsData:
          (json['participants_data'] as List<dynamic>?)
              ?.map((e) => ParticipantData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ParticipantData>[],
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
      membershipRole: json['membership_role'] as String?,
      lastMessage: json['last_message'] == null
          ? null
          : LastMessageData.fromJson(
              json['last_message'] as Map<String, dynamic>,
            ),
      lastMessageAt: json['last_message_at'] as String?,
      origin: json['origin'] as String? ?? 'direct',
      promotedAt: json['promoted_at'] as String?,
      promotable: json['promotable'] as bool? ?? false,
      promotionStatus: json['promotion_status'] as String?,
      createdAt: json['created_at'] as String? ?? '',
    );

Map<String, dynamic> _$ConversationToJson(_Conversation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'is_group': instance.isGroup,
      'is_community': instance.isCommunity,
      'group_name': instance.groupName,
      'group_avatar_url': instance.groupAvatarUrl,
      'group_gym_id': instance.groupGymId,
      'sub_channel': instance.subChannel,
      'call_in_progress': instance.callInProgress,
      'description': instance.description,
      'cover_url': instance.coverUrl,
      'invite_code': instance.inviteCode,
      'is_public': instance.isPublic,
      'participants_data': instance.participantsData,
      'unread_count': instance.unreadCount,
      'membership_role': instance.membershipRole,
      'last_message': instance.lastMessage,
      'last_message_at': instance.lastMessageAt,
      'origin': instance.origin,
      'promoted_at': instance.promotedAt,
      'promotable': instance.promotable,
      'promotion_status': instance.promotionStatus,
      'created_at': instance.createdAt,
    };

_CommunityMember _$CommunityMemberFromJson(Map<String, dynamic> json) =>
    _CommunityMember(
      userId: json['user_id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      verificationStatus: json['verification_status'] as String? ?? 'none',
      role: json['role'] as String? ?? 'member',
      createdAt: json['created_at'] as String? ?? '',
    );

Map<String, dynamic> _$CommunityMemberToJson(_CommunityMember instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'username': instance.username,
      'display_name': instance.displayName,
      'avatar_url': instance.avatarUrl,
      'verification_status': instance.verificationStatus,
      'role': instance.role,
      'created_at': instance.createdAt,
    };

_CommunityPostComment _$CommunityPostCommentFromJson(
  Map<String, dynamic> json,
) => _CommunityPostComment(
  id: json['id'] as String,
  postId: json['post_id'] as String? ?? '',
  body: json['body'] as String? ?? '',
  replyToId: json['reply_to_id'] as String?,
  replyCount: (json['reply_count'] as num?)?.toInt() ?? 0,
  authorData: json['author_data'] == null
      ? const ProfileBrief()
      : ProfileBrief.fromJson(json['author_data'] as Map<String, dynamic>),
  createdAt: json['created_at'] as String? ?? '',
);

Map<String, dynamic> _$CommunityPostCommentToJson(
  _CommunityPostComment instance,
) => <String, dynamic>{
  'id': instance.id,
  'post_id': instance.postId,
  'body': instance.body,
  'reply_to_id': instance.replyToId,
  'reply_count': instance.replyCount,
  'author_data': instance.authorData,
  'created_at': instance.createdAt,
};

_ProfileBrief _$ProfileBriefFromJson(Map<String, dynamic> json) =>
    _ProfileBrief(
      userId: json['user_id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      role: json['role'] as String? ?? '',
    );

Map<String, dynamic> _$ProfileBriefToJson(_ProfileBrief instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'username': instance.username,
      'display_name': instance.displayName,
      'avatar_url': instance.avatarUrl,
      'role': instance.role,
    };

_CommunityPost _$CommunityPostFromJson(Map<String, dynamic> json) =>
    _CommunityPost(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String? ?? '',
      authorId: json['author_id'] as String? ?? '',
      body: json['body'] as String? ?? '',
      mediaUrl: json['media_url'] as String? ?? '',
      mediaMime: json['media_mime'] as String? ?? '',
      isPinned: json['is_pinned'] as bool? ?? false,
      likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
      commentCount: (json['comment_count'] as num?)?.toInt() ?? 0,
      authorData: json['author_data'] == null
          ? const ProfileBrief()
          : ProfileBrief.fromJson(json['author_data'] as Map<String, dynamic>),
      isLiked: json['is_liked'] as bool? ?? false,
      comments:
          (json['comments'] as List<dynamic>?)
              ?.map(
                (e) => CommunityPostComment.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <CommunityPostComment>[],
      createdAt: json['created_at'] as String? ?? '',
    );

Map<String, dynamic> _$CommunityPostToJson(_CommunityPost instance) =>
    <String, dynamic>{
      'id': instance.id,
      'conversation_id': instance.conversationId,
      'author_id': instance.authorId,
      'body': instance.body,
      'media_url': instance.mediaUrl,
      'media_mime': instance.mediaMime,
      'is_pinned': instance.isPinned,
      'like_count': instance.likeCount,
      'comment_count': instance.commentCount,
      'author_data': instance.authorData,
      'is_liked': instance.isLiked,
      'comments': instance.comments,
      'created_at': instance.createdAt,
    };

_CommunityListData _$CommunityListDataFromJson(Map<String, dynamic> json) =>
    _CommunityListData(
      mine:
          (json['mine'] as List<dynamic>?)
              ?.map((e) => Conversation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Conversation>[],
      discover:
          (json['discover'] as List<dynamic>?)
              ?.map((e) => Conversation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Conversation>[],
    );

Map<String, dynamic> _$CommunityListDataToJson(_CommunityListData instance) =>
    <String, dynamic>{'mine': instance.mine, 'discover': instance.discover};

_CommunityDetail _$CommunityDetailFromJson(Map<String, dynamic> json) =>
    _CommunityDetail(
      id: json['id'] as String,
      isGroup: json['is_group'] as bool? ?? false,
      isCommunity: json['is_community'] as bool? ?? true,
      groupName: json['group_name'] as String? ?? '',
      groupAvatarUrl: json['group_avatar_url'] as String? ?? '',
      groupGymId: json['group_gym_id'] as String?,
      subChannel: json['sub_channel'] as String? ?? '',
      callInProgress: json['call_in_progress'] as bool? ?? false,
      description: json['description'] as String? ?? '',
      coverUrl: json['cover_url'] as String? ?? '',
      inviteCode: json['invite_code'] as String? ?? '',
      isPublic: json['is_public'] as bool? ?? false,
      membershipRole: json['membership_role'] as String?,
      myRole: json['my_role'] as String?,
      memberCount: (json['member_count'] as num?)?.toInt() ?? 0,
      participantsData:
          (json['participants_data'] as List<dynamic>?)
              ?.map((e) => ParticipantData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ParticipantData>[],
      members:
          (json['members'] as List<dynamic>?)
              ?.map((e) => CommunityMember.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <CommunityMember>[],
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
      lastMessage: json['last_message'] == null
          ? null
          : LastMessageData.fromJson(
              json['last_message'] as Map<String, dynamic>,
            ),
      lastMessageAt: json['last_message_at'] as String?,
      createdAt: json['created_at'] as String? ?? '',
    );

Map<String, dynamic> _$CommunityDetailToJson(_CommunityDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'is_group': instance.isGroup,
      'is_community': instance.isCommunity,
      'group_name': instance.groupName,
      'group_avatar_url': instance.groupAvatarUrl,
      'group_gym_id': instance.groupGymId,
      'sub_channel': instance.subChannel,
      'call_in_progress': instance.callInProgress,
      'description': instance.description,
      'cover_url': instance.coverUrl,
      'invite_code': instance.inviteCode,
      'is_public': instance.isPublic,
      'membership_role': instance.membershipRole,
      'my_role': instance.myRole,
      'member_count': instance.memberCount,
      'participants_data': instance.participantsData,
      'members': instance.members,
      'unread_count': instance.unreadCount,
      'last_message': instance.lastMessage,
      'last_message_at': instance.lastMessageAt,
      'created_at': instance.createdAt,
    };

_ReplyData _$ReplyDataFromJson(Map<String, dynamic> json) => _ReplyData(
  id: json['id'] as String,
  body: json['body'] as String? ?? '',
  senderName: json['sender_name'] as String? ?? '',
  messageType: json['message_type'] as String? ?? 'text',
  mediaUrl: json['media_url'] as String? ?? '',
);

Map<String, dynamic> _$ReplyDataToJson(_ReplyData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'body': instance.body,
      'sender_name': instance.senderName,
      'message_type': instance.messageType,
      'media_url': instance.mediaUrl,
    };

_Message _$MessageFromJson(Map<String, dynamic> json) => _Message(
  id: json['id'] as String,
  conversationId: json['conversation_id'] as String,
  senderId: json['sender_id'] as String,
  messageType: json['message_type'] as String? ?? 'text',
  body: json['body'] as String? ?? '',
  mediaUrl: json['media_url'] as String? ?? '',
  mediaMime: json['media_mime'] as String? ?? '',
  fileName: json['file_name'] as String? ?? '',
  replyToId: json['reply_to_id'] as String?,
  metadata:
      json['metadata'] as Map<String, dynamic>? ?? const <String, dynamic>{},
  isRead: json['is_read'] as bool? ?? false,
  deletedFor:
      (json['deleted_for'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  senderData: ParticipantData.fromJson(
    json['sender_data'] as Map<String, dynamic>,
  ),
  replyData: json['reply_data'] == null
      ? null
      : ReplyData.fromJson(json['reply_data'] as Map<String, dynamic>),
  reactions:
      (json['reactions'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const <String, int>{},
  createdAt: json['created_at'] as String? ?? '',
);

Map<String, dynamic> _$MessageToJson(_Message instance) => <String, dynamic>{
  'id': instance.id,
  'conversation_id': instance.conversationId,
  'sender_id': instance.senderId,
  'message_type': instance.messageType,
  'body': instance.body,
  'media_url': instance.mediaUrl,
  'media_mime': instance.mediaMime,
  'file_name': instance.fileName,
  'reply_to_id': instance.replyToId,
  'metadata': instance.metadata,
  'is_read': instance.isRead,
  'deleted_for': instance.deletedFor,
  'sender_data': instance.senderData,
  'reply_data': instance.replyData,
  'reactions': instance.reactions,
  'created_at': instance.createdAt,
};

_CallLog _$CallLogFromJson(Map<String, dynamic> json) => _CallLog(
  id: json['id'] as String,
  conversationId: json['conversation_id'] as String? ?? '',
  callType: json['call_type'] as String? ?? 'audio',
  status: json['status'] as String? ?? '',
  durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 0,
  callerData:
      json['caller_data'] as Map<String, dynamic>? ?? const <String, dynamic>{},
  calleeData:
      json['callee_data'] as Map<String, dynamic>? ?? const <String, dynamic>{},
  createdAt: json['created_at'] as String? ?? '',
  endedAt: json['ended_at'] as String?,
);

Map<String, dynamic> _$CallLogToJson(_CallLog instance) => <String, dynamic>{
  'id': instance.id,
  'conversation_id': instance.conversationId,
  'call_type': instance.callType,
  'status': instance.status,
  'duration_seconds': instance.durationSeconds,
  'caller_data': instance.callerData,
  'callee_data': instance.calleeData,
  'created_at': instance.createdAt,
  'ended_at': instance.endedAt,
};

_LinkPreviewData _$LinkPreviewDataFromJson(Map<String, dynamic> json) =>
    _LinkPreviewData(
      url: json['url'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      image: json['image'] as String? ?? '',
      domain: json['domain'] as String? ?? '',
    );

Map<String, dynamic> _$LinkPreviewDataToJson(_LinkPreviewData instance) =>
    <String, dynamic>{
      'url': instance.url,
      'title': instance.title,
      'description': instance.description,
      'image': instance.image,
      'domain': instance.domain,
    };

_PendingCall _$PendingCallFromJson(Map<String, dynamic> json) => _PendingCall(
  conversationId: json['conversation_id'] as String? ?? '',
  fromUserId: json['from_user_id'] as String? ?? '',
  fromUsername: json['from_username'] as String? ?? '',
  fromDisplayName: json['from_display_name'] as String? ?? '',
  fromAvatarUrl: json['from_avatar_url'] as String? ?? '',
  callType: json['call_type'] as String? ?? 'audio',
  data: json['data'] as Map<String, dynamic>? ?? const <String, dynamic>{},
);

Map<String, dynamic> _$PendingCallToJson(_PendingCall instance) =>
    <String, dynamic>{
      'conversation_id': instance.conversationId,
      'from_user_id': instance.fromUserId,
      'from_username': instance.fromUsername,
      'from_display_name': instance.fromDisplayName,
      'from_avatar_url': instance.fromAvatarUrl,
      'call_type': instance.callType,
      'data': instance.data,
    };

_SendMessagePayload _$SendMessagePayloadFromJson(Map<String, dynamic> json) =>
    _SendMessagePayload(
      messageType: json['messageType'] as String? ?? 'text',
      body: json['body'] as String?,
      mediaUrl: json['mediaUrl'] as String?,
      mediaMime: json['mediaMime'] as String?,
      fileName: json['fileName'] as String?,
      replyToId: json['replyToId'] as String?,
      metadata:
          json['metadata'] as Map<String, dynamic>? ??
          const <String, dynamic>{},
    );

Map<String, dynamic> _$SendMessagePayloadToJson(_SendMessagePayload instance) =>
    <String, dynamic>{
      'messageType': instance.messageType,
      'body': instance.body,
      'mediaUrl': instance.mediaUrl,
      'mediaMime': instance.mediaMime,
      'fileName': instance.fileName,
      'replyToId': instance.replyToId,
      'metadata': instance.metadata,
    };

_ForwardPayload _$ForwardPayloadFromJson(Map<String, dynamic> json) =>
    _ForwardPayload(conversationId: json['conversationId'] as String);

Map<String, dynamic> _$ForwardPayloadToJson(_ForwardPayload instance) =>
    <String, dynamic>{'conversationId': instance.conversationId};

_MessageReactionPayload _$MessageReactionPayloadFromJson(
  Map<String, dynamic> json,
) => _MessageReactionPayload(emoji: json['emoji'] as String);

Map<String, dynamic> _$MessageReactionPayloadToJson(
  _MessageReactionPayload instance,
) => <String, dynamic>{'emoji': instance.emoji};

ChatEventMessage _$ChatEventMessageFromJson(Map<String, dynamic> json) =>
    ChatEventMessage(
      data: json['data'] as Map<String, dynamic>,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$ChatEventMessageToJson(ChatEventMessage instance) =>
    <String, dynamic>{'data': instance.data, 'runtimeType': instance.$type};

ChatEventTypingStart _$ChatEventTypingStartFromJson(
  Map<String, dynamic> json,
) => ChatEventTypingStart(
  userId: json['userId'] as String,
  username: json['username'] as String,
  displayName: json['displayName'] as String,
  avatarUrl: json['avatarUrl'] as String,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$ChatEventTypingStartToJson(
  ChatEventTypingStart instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'username': instance.username,
  'displayName': instance.displayName,
  'avatarUrl': instance.avatarUrl,
  'runtimeType': instance.$type,
};

ChatEventTypingStop _$ChatEventTypingStopFromJson(Map<String, dynamic> json) =>
    ChatEventTypingStop(
      userId: json['userId'] as String,
      username: json['username'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$ChatEventTypingStopToJson(
  ChatEventTypingStop instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'username': instance.username,
  'runtimeType': instance.$type,
};

ChatEventRead _$ChatEventReadFromJson(Map<String, dynamic> json) =>
    ChatEventRead(
      conversationId: json['conversationId'] as String,
      readerId: json['readerId'] as String,
      messageId: json['messageId'] as String?,
      count: (json['count'] as num?)?.toInt() ?? 0,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$ChatEventReadToJson(ChatEventRead instance) =>
    <String, dynamic>{
      'conversationId': instance.conversationId,
      'readerId': instance.readerId,
      'messageId': instance.messageId,
      'count': instance.count,
      'runtimeType': instance.$type,
    };

ChatEventReact _$ChatEventReactFromJson(Map<String, dynamic> json) =>
    ChatEventReact(
      conversationId: json['conversationId'] as String,
      messageId: json['messageId'] as String,
      reactions:
          (json['reactions'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const <String, int>{},
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$ChatEventReactToJson(ChatEventReact instance) =>
    <String, dynamic>{
      'conversationId': instance.conversationId,
      'messageId': instance.messageId,
      'reactions': instance.reactions,
      'runtimeType': instance.$type,
    };
