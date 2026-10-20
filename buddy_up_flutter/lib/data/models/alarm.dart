import 'package:freezed_annotation/freezed_annotation.dart';

part 'alarm.freezed.dart';
part 'alarm.g.dart';

@freezed
abstract class AlarmSound with _$AlarmSound {
  const factory AlarmSound({
    required String id,
    required String name,
    @Default('upload') String source,
    @JsonKey(name: 'audio_url') @Default('') String audioUrl,
    @JsonKey(name: 'duration_ms') @Default(0) int durationMs,
    @Default('private') String visibility,
    @Default('') String owner,
    @JsonKey(name: 'is_mine') @Default(false) bool isMine,
  }) = _AlarmSound;

  factory AlarmSound.fromJson(Map<String, dynamic> json) =>
      _$AlarmSoundFromJson(json);
}

@freezed
abstract class Alarm with _$Alarm {
  const factory Alarm({
    required String id,
    required String time,
    @JsonKey(name: 'days_mask') @Default(0) int daysMask,
    @Default('') String label,
    AlarmSound? sound,
    @Default(true) bool enabled,
    @JsonKey(name: 'snooze_minutes') @Default(5) int snoozeMinutes,
  }) = _Alarm;

  factory Alarm.fromJson(Map<String, dynamic> json) => _$AlarmFromJson(json);
}

@freezed
abstract class AlarmSender with _$AlarmSender {
  const factory AlarmSender({
    @JsonKey(name: 'profile_id') String? profileId,
    String? username,
    @JsonKey(name: 'display_name') String? displayName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
  }) = _AlarmSender;

  factory AlarmSender.fromJson(Map<String, dynamic> json) =>
      _$AlarmSenderFromJson(json);
}

@freezed
abstract class AlarmShare with _$AlarmShare {
  const factory AlarmShare({
    required String id,
    required AlarmSound sound,
    AlarmSender? sender,
    @Default('pending') String status,
  }) = _AlarmShare;

  factory AlarmShare.fromJson(Map<String, dynamic> json) =>
      _$AlarmShareFromJson(json);
}

@freezed
abstract class AlarmSuggestion with _$AlarmSuggestion {
  const factory AlarmSuggestion({
    required String id,
    required String title,
    String? note,
    String? url,
    AlarmSender? sender,
    @Default('pending') String status,
  }) = _AlarmSuggestion;

  factory AlarmSuggestion.fromJson(Map<String, dynamic> json) =>
      _$AlarmSuggestionFromJson(json);
}
