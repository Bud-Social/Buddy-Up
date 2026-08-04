import 'package:freezed_annotation/freezed_annotation.dart';

part 'live.freezed.dart';
part 'live.g.dart';

@freezed
abstract class AgoraCredentials with _$AgoraCredentials {
  const factory AgoraCredentials({
    required String appId,
    required String channel,
    String? token,
  }) = _AgoraCredentials;

  factory AgoraCredentials.fromJson(Map<String, dynamic> json) =>
      _$AgoraCredentialsFromJson(json);
}

@freezed
abstract class LiveKitCredentials with _$LiveKitCredentials {
  const factory LiveKitCredentials({
    required String url,
    required String room,
    required String token,
    @Default(true) bool canPublish,
  }) = _LiveKitCredentials;

  factory LiveKitCredentials.fromJson(Map<String, dynamic> json) =>
      _$LiveKitCredentialsFromJson(json);
}

@freezed
abstract class LiveCredentials with _$LiveCredentials {
  const factory LiveCredentials({
    required AgoraCredentials agora,
    required LiveKitCredentials livekit,
  }) = _LiveCredentials;

  factory LiveCredentials.fromJson(Map<String, dynamic> json) =>
      _$LiveCredentialsFromJson(json);
}

@freezed
abstract class BuddyLiveHost with _$BuddyLiveHost {
  const factory BuddyLiveHost({
    required String userId,
    required String username,
    required String displayName,
    required String avatarUrl,
  }) = _BuddyLiveHost;

  factory BuddyLiveHost.fromJson(Map<String, dynamic> json) =>
      _$BuddyLiveHostFromJson(json);
}

@freezed
abstract class BuddyLive with _$BuddyLive {
  const factory BuddyLive({
    required String id,
    required BuddyLiveHost host,
    required String title,
    @Default('open_sweat') String liveType,
    @Default('') String category,
    @Default('public') String access,
    @Default('scheduled') String status,
    String? startedAt,
    String? endedAt,
    @Default(0) int viewerPeak,
    @Default(0) int viewerCount,
    @Default('') String replayUrl,
    @Default(false) bool replaySaved,
    String? muxPlaybackId,
    String? scheduledFor,
    @Default(false) bool isRecurring,
    @Default(<String>[]) List<String> equipmentList,
    @Default(false) bool hasRsvped,
    @Default(0) int rsvpCount,
    @JsonKey(name: 'artifact_fee') Map<String, dynamic>? artifactFee,
    @JsonKey(name: 'recording_consent') String? recordingConsent,
    String? gymId,
    required String createdAt,
  }) = _BuddyLive;

  factory BuddyLive.fromJson(Map<String, dynamic> json) => _$BuddyLiveFromJson(json);
}

@freezed
abstract class CoHost with _$CoHost {
  const factory CoHost({
    required String userId,
    required String displayName,
    required String avatarUrl,
  }) = _CoHost;

  factory CoHost.fromJson(Map<String, dynamic> json) => _$CoHostFromJson(json);
}

@freezed
abstract class GiftInfo with _$GiftInfo {
  const factory GiftInfo({
    required String txId,
    required String artifactType,
    required int quantity,
    required String senderId,
    required String senderName,
    required int total,
  }) = _GiftInfo;

  factory GiftInfo.fromJson(Map<String, dynamic> json) => _$GiftInfoFromJson(json);
}

@freezed
abstract class AttendeeInfo with _$AttendeeInfo {
  const factory AttendeeInfo({
    required String id,
    required String displayName,
    required String avatarUrl,
    @Default(false) bool isSpeaking,
    @Default(true) bool hasMicOn,
    @Default(true) bool hasVideoOn,
    @Default(false) bool isLocal,
    @Default(0) double audioLevel,
  }) = _AttendeeInfo;

  factory AttendeeInfo.fromJson(Map<String, dynamic> json) =>
      _$AttendeeInfoFromJson(json);
}

@freezed
abstract class LiveRoomData with _$LiveRoomData {
  const factory LiveRoomData({
    required LiveCredentials credentials,
    @Default('') String liveType,
    @Default('') String title,
    @Default('') String hostName,
    @Default('') String hostUserId,
    @Default('') String hostAvatar,
    @Default('') String status,
    @Default(0) int viewerCount,
    @Default(<CoHost>[]) List<CoHost> coHosts,
  }) = _LiveRoomData;

  factory LiveRoomData.fromJson(Map<String, dynamic> json) =>
      _$LiveRoomDataFromJson(json);
}

@freezed
abstract class StartLivePayload with _$StartLivePayload {
  const factory StartLivePayload({
    required String title,
    required String liveType,
    required String category,
    @Default('public') String access,
    String? gymId,
    String? scheduledFor,
    @Default(false) bool isRecurring,
    @Default(<String>[]) List<String> equipmentList,
    @Default(<String>[]) List<String> coHosts,
  }) = _StartLivePayload;

  factory StartLivePayload.fromJson(Map<String, dynamic> json) =>
      _$StartLivePayloadFromJson(json);
}

@freezed
abstract class RandomDropPayload with _$RandomDropPayload {
  const factory RandomDropPayload({
    required String activityType,
    required int duration,
    String? fee,
  }) = _RandomDropPayload;

  factory RandomDropPayload.fromJson(Map<String, dynamic> json) =>
      _$RandomDropPayloadFromJson(json);
}

@freezed
abstract class RandomDropStatus with _$RandomDropStatus {
  const factory RandomDropStatus({
    @Default('not_searching') String status,
    @Default(0) int timeoutSeconds,
    String? liveId,
    LiveCredentials? credentials,
  }) = _RandomDropStatus;

  factory RandomDropStatus.fromJson(Map<String, dynamic> json) =>
      _$RandomDropStatusFromJson(json);
}

@freezed
abstract class JoinLiveResponse with _$JoinLiveResponse {
  const factory JoinLiveResponse({
    required LiveCredentials credentials,
    @Default('') String liveType,
    @Default('') String hostName,
  }) = _JoinLiveResponse;

  factory JoinLiveResponse.fromJson(Map<String, dynamic> json) =>
      _$JoinLiveResponseFromJson(json);
}

@freezed
abstract class StartLiveResponse with _$StartLiveResponse {
  const factory StartLiveResponse({
    required BuddyLive live,
    required LiveCredentials credentials,
  }) = _StartLiveResponse;

  factory StartLiveResponse.fromJson(Map<String, dynamic> json) =>
      _$StartLiveResponseFromJson(json);
}
