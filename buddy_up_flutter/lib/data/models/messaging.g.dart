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
      groupName: json['groupName'] as String? ?? '',
      groupAvatarUrl: json['groupAvatarUrl'] as String? ?? '',
      groupGymId: json['groupGymId'] as String?,
      subChannel: json['subChannel'] as String? ?? '',
      callInProgress: json['callInProgress'] as bool? ?? false,
      participantsData:
          (json['participantsData'] as List<dynamic>?)
              ?.map((e) => ParticipantData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ParticipantData>[],
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
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
      'groupName': instance.groupName,
      'groupAvatarUrl': instance.groupAvatarUrl,
      'groupGymId': instance.groupGymId,
      'subChannel': instance.subChannel,
      'callInProgress': instance.callInProgress,
      'participantsData': instance.participantsData,
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

ChatEventCallOffer _$ChatEventCallOfferFromJson(Map<String, dynamic> json) =>
    ChatEventCallOffer(
      callType: json['callType'] as String,
      data: json['data'] as Map<String, dynamic>,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$ChatEventCallOfferToJson(ChatEventCallOffer instance) =>
    <String, dynamic>{
      'callType': instance.callType,
      'data': instance.data,
      'runtimeType': instance.$type,
    };

ChatEventCallAnswer _$ChatEventCallAnswerFromJson(Map<String, dynamic> json) =>
    ChatEventCallAnswer(
      callType: json['callType'] as String,
      data: json['data'] as Map<String, dynamic>,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$ChatEventCallAnswerToJson(
  ChatEventCallAnswer instance,
) => <String, dynamic>{
  'callType': instance.callType,
  'data': instance.data,
  'runtimeType': instance.$type,
};

ChatEventCallIce _$ChatEventCallIceFromJson(Map<String, dynamic> json) =>
    ChatEventCallIce(
      data: json['data'] as Map<String, dynamic>,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$ChatEventCallIceToJson(ChatEventCallIce instance) =>
    <String, dynamic>{'data': instance.data, 'runtimeType': instance.$type};

ChatEventCallEnd _$ChatEventCallEndFromJson(Map<String, dynamic> json) =>
    ChatEventCallEnd($type: json['runtimeType'] as String?);

Map<String, dynamic> _$ChatEventCallEndToJson(ChatEventCallEnd instance) =>
    <String, dynamic>{'runtimeType': instance.$type};

ChatEventCallDecline _$ChatEventCallDeclineFromJson(
  Map<String, dynamic> json,
) => ChatEventCallDecline($type: json['runtimeType'] as String?);

Map<String, dynamic> _$ChatEventCallDeclineToJson(
  ChatEventCallDecline instance,
) => <String, dynamic>{'runtimeType': instance.$type};

ChatEventCallRinging _$ChatEventCallRingingFromJson(
  Map<String, dynamic> json,
) => ChatEventCallRinging(
  data: json['data'] as Map<String, dynamic>,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$ChatEventCallRingingToJson(
  ChatEventCallRinging instance,
) => <String, dynamic>{'data': instance.data, 'runtimeType': instance.$type};
