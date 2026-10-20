// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarm.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AlarmSound _$AlarmSoundFromJson(Map<String, dynamic> json) => _AlarmSound(
  id: json['id'] as String,
  name: json['name'] as String,
  source: json['source'] as String? ?? 'upload',
  audioUrl: json['audio_url'] as String? ?? '',
  durationMs: (json['duration_ms'] as num?)?.toInt() ?? 0,
  visibility: json['visibility'] as String? ?? 'private',
  owner: json['owner'] as String? ?? '',
  isMine: json['is_mine'] as bool? ?? false,
);

Map<String, dynamic> _$AlarmSoundToJson(_AlarmSound instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'source': instance.source,
      'audio_url': instance.audioUrl,
      'duration_ms': instance.durationMs,
      'visibility': instance.visibility,
      'owner': instance.owner,
      'is_mine': instance.isMine,
    };

_Alarm _$AlarmFromJson(Map<String, dynamic> json) => _Alarm(
  id: json['id'] as String,
  time: json['time'] as String,
  daysMask: (json['days_mask'] as num?)?.toInt() ?? 0,
  label: json['label'] as String? ?? '',
  sound: json['sound'] == null
      ? null
      : AlarmSound.fromJson(json['sound'] as Map<String, dynamic>),
  enabled: json['enabled'] as bool? ?? true,
  snoozeMinutes: (json['snooze_minutes'] as num?)?.toInt() ?? 5,
);

Map<String, dynamic> _$AlarmToJson(_Alarm instance) => <String, dynamic>{
  'id': instance.id,
  'time': instance.time,
  'days_mask': instance.daysMask,
  'label': instance.label,
  'sound': instance.sound,
  'enabled': instance.enabled,
  'snooze_minutes': instance.snoozeMinutes,
};

_AlarmSender _$AlarmSenderFromJson(Map<String, dynamic> json) => _AlarmSender(
  profileId: json['profile_id'] as String?,
  username: json['username'] as String?,
  displayName: json['display_name'] as String?,
  avatarUrl: json['avatar_url'] as String?,
);

Map<String, dynamic> _$AlarmSenderToJson(_AlarmSender instance) =>
    <String, dynamic>{
      'profile_id': instance.profileId,
      'username': instance.username,
      'display_name': instance.displayName,
      'avatar_url': instance.avatarUrl,
    };

_AlarmShare _$AlarmShareFromJson(Map<String, dynamic> json) => _AlarmShare(
  id: json['id'] as String,
  sound: AlarmSound.fromJson(json['sound'] as Map<String, dynamic>),
  sender: json['sender'] == null
      ? null
      : AlarmSender.fromJson(json['sender'] as Map<String, dynamic>),
  status: json['status'] as String? ?? 'pending',
);

Map<String, dynamic> _$AlarmShareToJson(_AlarmShare instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sound': instance.sound,
      'sender': instance.sender,
      'status': instance.status,
    };

_AlarmSuggestion _$AlarmSuggestionFromJson(Map<String, dynamic> json) =>
    _AlarmSuggestion(
      id: json['id'] as String,
      title: json['title'] as String,
      note: json['note'] as String?,
      url: json['url'] as String?,
      sender: json['sender'] == null
          ? null
          : AlarmSender.fromJson(json['sender'] as Map<String, dynamic>),
      status: json['status'] as String? ?? 'pending',
    );

Map<String, dynamic> _$AlarmSuggestionToJson(_AlarmSuggestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'note': instance.note,
      'url': instance.url,
      'sender': instance.sender,
      'status': instance.status,
    };
