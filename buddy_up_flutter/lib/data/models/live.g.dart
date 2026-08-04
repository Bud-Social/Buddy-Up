// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AgoraCredentials _$AgoraCredentialsFromJson(Map<String, dynamic> json) =>
    _AgoraCredentials(
      appId: json['appId'] as String,
      channel: json['channel'] as String,
      token: json['token'] as String?,
    );

Map<String, dynamic> _$AgoraCredentialsToJson(_AgoraCredentials instance) =>
    <String, dynamic>{
      'appId': instance.appId,
      'channel': instance.channel,
      'token': instance.token,
    };

_LiveKitCredentials _$LiveKitCredentialsFromJson(Map<String, dynamic> json) =>
    _LiveKitCredentials(
      url: json['url'] as String,
      room: json['room'] as String,
      token: json['token'] as String,
      canPublish: json['canPublish'] as bool? ?? true,
    );

Map<String, dynamic> _$LiveKitCredentialsToJson(_LiveKitCredentials instance) =>
    <String, dynamic>{
      'url': instance.url,
      'room': instance.room,
      'token': instance.token,
      'canPublish': instance.canPublish,
    };

_LiveCredentials _$LiveCredentialsFromJson(Map<String, dynamic> json) =>
    _LiveCredentials(
      agora: AgoraCredentials.fromJson(json['agora'] as Map<String, dynamic>),
      livekit: LiveKitCredentials.fromJson(
        json['livekit'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$LiveCredentialsToJson(_LiveCredentials instance) =>
    <String, dynamic>{'agora': instance.agora, 'livekit': instance.livekit};

_BuddyLiveHost _$BuddyLiveHostFromJson(Map<String, dynamic> json) =>
    _BuddyLiveHost(
      userId: json['userId'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String,
    );

Map<String, dynamic> _$BuddyLiveHostToJson(_BuddyLiveHost instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'username': instance.username,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
    };

_BuddyLive _$BuddyLiveFromJson(Map<String, dynamic> json) => _BuddyLive(
  id: json['id'] as String,
  host: BuddyLiveHost.fromJson(json['host'] as Map<String, dynamic>),
  title: json['title'] as String,
  liveType: json['liveType'] as String? ?? 'open_sweat',
  category: json['category'] as String? ?? '',
  access: json['access'] as String? ?? 'public',
  status: json['status'] as String? ?? 'scheduled',
  startedAt: json['startedAt'] as String?,
  endedAt: json['endedAt'] as String?,
  viewerPeak: (json['viewerPeak'] as num?)?.toInt() ?? 0,
  viewerCount: (json['viewerCount'] as num?)?.toInt() ?? 0,
  replayUrl: json['replayUrl'] as String? ?? '',
  replaySaved: json['replaySaved'] as bool? ?? false,
  muxPlaybackId: json['muxPlaybackId'] as String?,
  scheduledFor: json['scheduledFor'] as String?,
  isRecurring: json['isRecurring'] as bool? ?? false,
  equipmentList:
      (json['equipmentList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  hasRsvped: json['hasRsvped'] as bool? ?? false,
  rsvpCount: (json['rsvpCount'] as num?)?.toInt() ?? 0,
  artifactFee: json['artifact_fee'] as Map<String, dynamic>?,
  recordingConsent: json['recording_consent'] as String?,
  gymId: json['gymId'] as String?,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$BuddyLiveToJson(_BuddyLive instance) =>
    <String, dynamic>{
      'id': instance.id,
      'host': instance.host,
      'title': instance.title,
      'liveType': instance.liveType,
      'category': instance.category,
      'access': instance.access,
      'status': instance.status,
      'startedAt': instance.startedAt,
      'endedAt': instance.endedAt,
      'viewerPeak': instance.viewerPeak,
      'viewerCount': instance.viewerCount,
      'replayUrl': instance.replayUrl,
      'replaySaved': instance.replaySaved,
      'muxPlaybackId': instance.muxPlaybackId,
      'scheduledFor': instance.scheduledFor,
      'isRecurring': instance.isRecurring,
      'equipmentList': instance.equipmentList,
      'hasRsvped': instance.hasRsvped,
      'rsvpCount': instance.rsvpCount,
      'artifact_fee': instance.artifactFee,
      'recording_consent': instance.recordingConsent,
      'gymId': instance.gymId,
      'createdAt': instance.createdAt,
    };

_CoHost _$CoHostFromJson(Map<String, dynamic> json) => _CoHost(
  userId: json['userId'] as String,
  displayName: json['displayName'] as String,
  avatarUrl: json['avatarUrl'] as String,
);

Map<String, dynamic> _$CoHostToJson(_CoHost instance) => <String, dynamic>{
  'userId': instance.userId,
  'displayName': instance.displayName,
  'avatarUrl': instance.avatarUrl,
};

_GiftInfo _$GiftInfoFromJson(Map<String, dynamic> json) => _GiftInfo(
  txId: json['txId'] as String,
  artifactType: json['artifactType'] as String,
  quantity: (json['quantity'] as num).toInt(),
  senderId: json['senderId'] as String,
  senderName: json['senderName'] as String,
  total: (json['total'] as num).toInt(),
);

Map<String, dynamic> _$GiftInfoToJson(_GiftInfo instance) => <String, dynamic>{
  'txId': instance.txId,
  'artifactType': instance.artifactType,
  'quantity': instance.quantity,
  'senderId': instance.senderId,
  'senderName': instance.senderName,
  'total': instance.total,
};

_AttendeeInfo _$AttendeeInfoFromJson(Map<String, dynamic> json) =>
    _AttendeeInfo(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String,
      isSpeaking: json['isSpeaking'] as bool? ?? false,
      hasMicOn: json['hasMicOn'] as bool? ?? true,
      hasVideoOn: json['hasVideoOn'] as bool? ?? true,
      isLocal: json['isLocal'] as bool? ?? false,
      audioLevel: (json['audioLevel'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$AttendeeInfoToJson(_AttendeeInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'isSpeaking': instance.isSpeaking,
      'hasMicOn': instance.hasMicOn,
      'hasVideoOn': instance.hasVideoOn,
      'isLocal': instance.isLocal,
      'audioLevel': instance.audioLevel,
    };

_LiveRoomData _$LiveRoomDataFromJson(Map<String, dynamic> json) =>
    _LiveRoomData(
      credentials: LiveCredentials.fromJson(
        json['credentials'] as Map<String, dynamic>,
      ),
      liveType: json['liveType'] as String? ?? '',
      title: json['title'] as String? ?? '',
      hostName: json['hostName'] as String? ?? '',
      hostUserId: json['hostUserId'] as String? ?? '',
      hostAvatar: json['hostAvatar'] as String? ?? '',
      status: json['status'] as String? ?? '',
      viewerCount: (json['viewerCount'] as num?)?.toInt() ?? 0,
      coHosts:
          (json['coHosts'] as List<dynamic>?)
              ?.map((e) => CoHost.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <CoHost>[],
    );

Map<String, dynamic> _$LiveRoomDataToJson(_LiveRoomData instance) =>
    <String, dynamic>{
      'credentials': instance.credentials,
      'liveType': instance.liveType,
      'title': instance.title,
      'hostName': instance.hostName,
      'hostUserId': instance.hostUserId,
      'hostAvatar': instance.hostAvatar,
      'status': instance.status,
      'viewerCount': instance.viewerCount,
      'coHosts': instance.coHosts,
    };

_StartLivePayload _$StartLivePayloadFromJson(Map<String, dynamic> json) =>
    _StartLivePayload(
      title: json['title'] as String,
      liveType: json['liveType'] as String,
      category: json['category'] as String,
      access: json['access'] as String? ?? 'public',
      gymId: json['gymId'] as String?,
      scheduledFor: json['scheduledFor'] as String?,
      isRecurring: json['isRecurring'] as bool? ?? false,
      equipmentList:
          (json['equipmentList'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      coHosts:
          (json['coHosts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$StartLivePayloadToJson(_StartLivePayload instance) =>
    <String, dynamic>{
      'title': instance.title,
      'liveType': instance.liveType,
      'category': instance.category,
      'access': instance.access,
      'gymId': instance.gymId,
      'scheduledFor': instance.scheduledFor,
      'isRecurring': instance.isRecurring,
      'equipmentList': instance.equipmentList,
      'coHosts': instance.coHosts,
    };

_RandomDropPayload _$RandomDropPayloadFromJson(Map<String, dynamic> json) =>
    _RandomDropPayload(
      activityType: json['activityType'] as String,
      duration: (json['duration'] as num).toInt(),
      fee: json['fee'] as String?,
    );

Map<String, dynamic> _$RandomDropPayloadToJson(_RandomDropPayload instance) =>
    <String, dynamic>{
      'activityType': instance.activityType,
      'duration': instance.duration,
      'fee': instance.fee,
    };

_RandomDropStatus _$RandomDropStatusFromJson(Map<String, dynamic> json) =>
    _RandomDropStatus(
      status: json['status'] as String? ?? 'not_searching',
      timeoutSeconds: (json['timeoutSeconds'] as num?)?.toInt() ?? 0,
      liveId: json['liveId'] as String?,
      credentials: json['credentials'] == null
          ? null
          : LiveCredentials.fromJson(
              json['credentials'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$RandomDropStatusToJson(_RandomDropStatus instance) =>
    <String, dynamic>{
      'status': instance.status,
      'timeoutSeconds': instance.timeoutSeconds,
      'liveId': instance.liveId,
      'credentials': instance.credentials,
    };

_JoinLiveResponse _$JoinLiveResponseFromJson(Map<String, dynamic> json) =>
    _JoinLiveResponse(
      credentials: LiveCredentials.fromJson(
        json['credentials'] as Map<String, dynamic>,
      ),
      liveType: json['liveType'] as String? ?? '',
      hostName: json['hostName'] as String? ?? '',
    );

Map<String, dynamic> _$JoinLiveResponseToJson(_JoinLiveResponse instance) =>
    <String, dynamic>{
      'credentials': instance.credentials,
      'liveType': instance.liveType,
      'hostName': instance.hostName,
    };

_StartLiveResponse _$StartLiveResponseFromJson(Map<String, dynamic> json) =>
    _StartLiveResponse(
      live: BuddyLive.fromJson(json['live'] as Map<String, dynamic>),
      credentials: LiveCredentials.fromJson(
        json['credentials'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$StartLiveResponseToJson(_StartLiveResponse instance) =>
    <String, dynamic>{
      'live': instance.live,
      'credentials': instance.credentials,
    };
