// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'buddy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BuddyRequestPayload _$BuddyRequestPayloadFromJson(Map<String, dynamic> json) =>
    _BuddyRequestPayload(username: json['username'] as String);

Map<String, dynamic> _$BuddyRequestPayloadToJson(
  _BuddyRequestPayload instance,
) => <String, dynamic>{'username': instance.username};

_PingPayload _$PingPayloadFromJson(Map<String, dynamic> json) =>
    _PingPayload(message: json['message'] as String);

Map<String, dynamic> _$PingPayloadToJson(_PingPayload instance) =>
    <String, dynamic>{'message': instance.message};

_PresenceInfo _$PresenceInfoFromJson(Map<String, dynamic> json) =>
    _PresenceInfo(
      online: json['online'] as bool,
      lastSeen: json['lastSeen'] as String?,
    );

Map<String, dynamic> _$PresenceInfoToJson(_PresenceInfo instance) =>
    <String, dynamic>{'online': instance.online, 'lastSeen': instance.lastSeen};
