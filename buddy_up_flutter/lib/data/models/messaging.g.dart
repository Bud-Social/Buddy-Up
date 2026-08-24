// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messaging.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ParticipantData _$ParticipantDataFromJson(Map<String, dynamic> json) =>
    _ParticipantData(
      userId: json['userId'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String,
      verificationStatus: json['verificationStatus'] as String? ?? 'none',
      role: json['role'] as String? ?? '',
    );

Map<String, dynamic> _$ParticipantDataToJson(_ParticipantData instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'username': instance.username,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'verificationStatus': instance.verificationStatus,
      'role': instance.role,
    };

_LastMessageData _$LastMessageDataFromJson(Map<String, dynamic> json) =>
    _LastMessageData(
      body: json['body'] as String? ?? '',
      messageType: json['messageType'] as String? ?? 'text',
      mediaUrl: json['mediaUrl'] as String? ?? '',
      senderName: json['senderName'] as String? ?? '',
    );

Map<String, dynamic> _$LastMessageDataToJson(_LastMessageData instance) =>
    <String, dynamic>{
      'body': instance.body,
      'messageType': instance.messageType,
      'mediaUrl': instance.mediaUrl,
      'senderName': instance.senderName,
    };

_Conversation _$ConversationFromJson(Map<String, dynamic> json) =>
    _Conversation(
      id: json['id'] as String,
      isGroup: json['isGroup'] as bool? ?? false,
      isCommunity: json['isCommunity'] as bool? ?? false,
      groupName: json['groupName'] as String? ?? '',
      groupAvatarUrl: json['groupAvatarUrl'] as String? ?? '',
      groupGymId: json['groupGymId'] as String?,
      subChannel: json['subChannel'] as String? ?? '',
      callInProgress: json['callInProgress'] as bool? ?? false,
      description: json['description'] as String? ?? '',
      coverUrl: json['coverUrl'] as String? ?? '',
      inviteCode: json['inviteCode'] as String? ?? '',
      isPublic: json['isPublic'] as bool? ?? false,
      participantsData:
          (json['participantsData'] as List<dynamic>?)
              ?.map((e) => ParticipantData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ParticipantData>[],
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      membershipRole: json['membershipRole'] as String?,
      lastMessage: json['lastMessage'] == null
          ? null
          : LastMessageData.fromJson(
              json['lastMessage'] as Map<String, dynamic>,
            ),
      lastMessageAt: json['lastMessageAt'] as String?,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$ConversationToJson(_Conversation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'isGroup': instance.isGroup,
      'isCommunity': instance.isCommunity,
      'groupName': instance.groupName,
      'groupAvatarUrl': instance.groupAvatarUrl,
      'groupGymId': instance.groupGymId,
      'subChannel': instance.subChannel,
      'callInProgress': instance.callInProgress,
      'description': instance.description,
      'coverUrl': instance.coverUrl,
      'inviteCode': instance.inviteCode,
      'isPublic': instance.isPublic,
      'participantsData': instance.participantsData,
      'unreadCount': instance.unreadCount,
      'membershipRole': instance.membershipRole,
      'lastMessage': instance.lastMessage,
      'lastMessageAt': instance.lastMessageAt,
      'createdAt': instance.createdAt,
    };

_CommunityMember _$CommunityMemberFromJson(Map<String, dynamic> json) =>
    _CommunityMember(
      userId: json['userId'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String? ?? '',
      verificationStatus: json['verificationStatus'] as String? ?? 'none',
      role: json['role'] as String? ?? 'member',
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$CommunityMemberToJson(_CommunityMember instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'username': instance.username,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'verificationStatus': instance.verificationStatus,
      'role': instance.role,
      'createdAt': instance.createdAt,
    };

_CommunityPostComment _$CommunityPostCommentFromJson(
  Map<String, dynamic> json,
) => _CommunityPostComment(
  id: json['id'] as String,
  postId: json['postId'] as String,
  body: json['body'] as String,
  replyToId: json['replyToId'] as String?,
  replyCount: (json['replyCount'] as num?)?.toInt() ?? 0,
  authorData: ProfileBrief.fromJson(json['authorData'] as Map<String, dynamic>),
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$CommunityPostCommentToJson(
  _CommunityPostComment instance,
) => <String, dynamic>{
  'id': instance.id,
  'postId': instance.postId,
  'body': instance.body,
  'replyToId': instance.replyToId,
  'replyCount': instance.replyCount,
  'authorData': instance.authorData,
  'createdAt': instance.createdAt,
};

_ProfileBrief _$ProfileBriefFromJson(Map<String, dynamic> json) =>
    _ProfileBrief(
      userId: json['userId'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String? ?? '',
      role: json['role'] as String? ?? '',
    );

Map<String, dynamic> _$ProfileBriefToJson(_ProfileBrief instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'username': instance.username,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'role': instance.role,
    };

_CommunityPost _$CommunityPostFromJson(
  Map<String, dynamic> json,
) => _CommunityPost(
  id: json['id'] as String,
  conversationId: json['conversationId'] as String,
  authorId: json['authorId'] as String,
  body: json['body'] as String? ?? '',
  mediaUrl: json['mediaUrl'] as String? ?? '',
  mediaMime: json['mediaMime'] as String? ?? '',
  isPinned: json['isPinned'] as bool? ?? false,
  likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
  commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
  authorData: ProfileBrief.fromJson(json['authorData'] as Map<String, dynamic>),
  isLiked: json['isLiked'] as bool? ?? false,
  comments:
      (json['comments'] as List<dynamic>?)
          ?.map((e) => CommunityPostComment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CommunityPostComment>[],
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$CommunityPostToJson(_CommunityPost instance) =>
    <String, dynamic>{
      'id': instance.id,
      'conversationId': instance.conversationId,
      'authorId': instance.authorId,
      'body': instance.body,
      'mediaUrl': instance.mediaUrl,
      'mediaMime': instance.mediaMime,
      'isPinned': instance.isPinned,
      'likeCount': instance.likeCount,
      'commentCount': instance.commentCount,
      'authorData': instance.authorData,
      'isLiked': instance.isLiked,
      'comments': instance.comments,
      'createdAt': instance.createdAt,
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
      isGroup: json['isGroup'] as bool? ?? false,
      isCommunity: json['isCommunity'] as bool? ?? true,
      groupName: json['groupName'] as String? ?? '',
      groupAvatarUrl: json['groupAvatarUrl'] as String? ?? '',
      groupGymId: json['groupGymId'] as String?,
      subChannel: json['subChannel'] as String? ?? '',
      callInProgress: json['callInProgress'] as bool? ?? false,
      description: json['description'] as String? ?? '',
      coverUrl: json['coverUrl'] as String? ?? '',
      inviteCode: json['inviteCode'] as String? ?? '',
      isPublic: json['isPublic'] as bool? ?? false,
      membershipRole: json['membershipRole'] as String?,
      myRole: json['myRole'] as String?,
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
      participantsData:
          (json['participantsData'] as List<dynamic>?)
              ?.map((e) => ParticipantData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ParticipantData>[],
      members:
          (json['members'] as List<dynamic>?)
              ?.map((e) => CommunityMember.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <CommunityMember>[],
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      lastMessage: json['lastMessage'] == null
          ? null
          : LastMessageData.fromJson(
              json['lastMessage'] as Map<String, dynamic>,
            ),
      lastMessageAt: json['lastMessageAt'] as String?,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$CommunityDetailToJson(_CommunityDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'isGroup': instance.isGroup,
      'isCommunity': instance.isCommunity,
      'groupName': instance.groupName,
      'groupAvatarUrl': instance.groupAvatarUrl,
      'groupGymId': instance.groupGymId,
      'subChannel': instance.subChannel,
      'callInProgress': instance.callInProgress,
      'description': instance.description,
      'coverUrl': instance.coverUrl,
      'inviteCode': instance.inviteCode,
      'isPublic': instance.isPublic,
      'membershipRole': instance.membershipRole,
      'myRole': instance.myRole,
      'memberCount': instance.memberCount,
      'participantsData': instance.participantsData,
      'members': instance.members,
      'unreadCount': instance.unreadCount,
      'lastMessage': instance.lastMessage,
      'lastMessageAt': instance.lastMessageAt,
      'createdAt': instance.createdAt,
    };

_ReplyData _$ReplyDataFromJson(Map<String, dynamic> json) => _ReplyData(
  id: json['id'] as String,
  body: json['body'] as String? ?? '',
  senderName: json['senderName'] as String? ?? '',
  messageType: json['messageType'] as String? ?? 'text',
  mediaUrl: json['mediaUrl'] as String? ?? '',
);

Map<String, dynamic> _$ReplyDataToJson(_ReplyData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'body': instance.body,
      'senderName': instance.senderName,
      'messageType': instance.messageType,
      'mediaUrl': instance.mediaUrl,
    };

_Message _$MessageFromJson(Map<String, dynamic> json) => _Message(
  id: json['id'] as String,
  conversationId: json['conversationId'] as String,
  senderId: json['senderId'] as String,
  messageType: json['messageType'] as String? ?? 'text',
  body: json['body'] as String? ?? '',
  mediaUrl: json['mediaUrl'] as String? ?? '',
  mediaMime: json['mediaMime'] as String? ?? '',
  fileName: json['fileName'] as String? ?? '',
  replyToId: json['replyToId'] as String?,
  metadata:
      json['metadata'] as Map<String, dynamic>? ?? const <String, dynamic>{},
  isRead: json['isRead'] as bool? ?? false,
  deletedFor:
      (json['deletedFor'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  senderData: ParticipantData.fromJson(
    json['senderData'] as Map<String, dynamic>,
  ),
  replyData: json['replyData'] == null
      ? null
      : ReplyData.fromJson(json['replyData'] as Map<String, dynamic>),
  reactions:
      (json['reactions'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const <String, int>{},
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$MessageToJson(_Message instance) => <String, dynamic>{
  'id': instance.id,
  'conversationId': instance.conversationId,
  'senderId': instance.senderId,
  'messageType': instance.messageType,
  'body': instance.body,
  'mediaUrl': instance.mediaUrl,
  'mediaMime': instance.mediaMime,
  'fileName': instance.fileName,
  'replyToId': instance.replyToId,
  'metadata': instance.metadata,
  'isRead': instance.isRead,
  'deletedFor': instance.deletedFor,
  'senderData': instance.senderData,
  'replyData': instance.replyData,
  'reactions': instance.reactions,
  'createdAt': instance.createdAt,
};

_CallLog _$CallLogFromJson(Map<String, dynamic> json) => _CallLog(
  id: json['id'] as String,
  conversationId: json['conversationId'] as String,
  callType: json['callType'] as String? ?? 'audio',
  status: json['status'] as String? ?? '',
  durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
  callerData: json['callerData'] as Map<String, dynamic>,
  calleeData: json['calleeData'] as Map<String, dynamic>,
  createdAt: json['createdAt'] as String,
  endedAt: json['endedAt'] as String?,
);

Map<String, dynamic> _$CallLogToJson(_CallLog instance) => <String, dynamic>{
  'id': instance.id,
  'conversationId': instance.conversationId,
  'callType': instance.callType,
  'status': instance.status,
  'durationSeconds': instance.durationSeconds,
  'callerData': instance.callerData,
  'calleeData': instance.calleeData,
  'createdAt': instance.createdAt,
  'endedAt': instance.endedAt,
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
  conversationId: json['conversationId'] as String,
  fromUserId: json['fromUserId'] as String,
  fromUsername: json['fromUsername'] as String,
  fromDisplayName: json['fromDisplayName'] as String,
  fromAvatarUrl: json['fromAvatarUrl'] as String,
  callType: json['callType'] as String? ?? 'audio',
  data: json['data'] as Map<String, dynamic>? ?? const <String, dynamic>{},
);

Map<String, dynamic> _$PendingCallToJson(_PendingCall instance) =>
    <String, dynamic>{
      'conversationId': instance.conversationId,
      'fromUserId': instance.fromUserId,
      'fromUsername': instance.fromUsername,
      'fromDisplayName': instance.fromDisplayName,
      'fromAvatarUrl': instance.fromAvatarUrl,
      'callType': instance.callType,
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
