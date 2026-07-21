import 'package:freezed_annotation/freezed_annotation.dart';

part 'buddy.freezed.dart';
part 'buddy.g.dart';

@freezed
abstract class BuddyRequestPayload with _$BuddyRequestPayload {
  const factory BuddyRequestPayload({
    required String username,
  }) = _BuddyRequestPayload;

  factory BuddyRequestPayload.fromJson(Map<String, dynamic> json) =>
      _$BuddyRequestPayloadFromJson(json);
}

@freezed
abstract class PingPayload with _$PingPayload {
  const factory PingPayload({
    required String message,
  }) = _PingPayload;

  factory PingPayload.fromJson(Map<String, dynamic> json) =>
      _$PingPayloadFromJson(json);
}

@freezed
abstract class PresenceInfo with _$PresenceInfo {
  const factory PresenceInfo({
    required bool online,
    String? lastSeen,
  }) = _PresenceInfo;

  factory PresenceInfo.fromJson(Map<String, dynamic> json) =>
      _$PresenceInfoFromJson(json);
}
