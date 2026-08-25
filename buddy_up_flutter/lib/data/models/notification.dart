import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

@freezed
abstract class BuddyNotification with _$BuddyNotification {
  const factory BuddyNotification({
    required String id,
    @JsonKey(name: 'notification_type') required String notificationType,
    required String title,
    required String body,
    @JsonKey(name: 'is_read') @Default(false) bool isRead,
    @JsonKey(name: 'is_pinned') @Default(false) bool isPinned,
    @JsonKey(name: 'sender_username') String? senderUsername,
    @JsonKey(name: 'sender_avatar') String? senderAvatar,
    @JsonKey(name: 'action_link') String? actionLink,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'metadata') Map<String, dynamic>? metadata,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _BuddyNotification;

  factory BuddyNotification.fromJson(Map<String, dynamic> json) =>
      _$BuddyNotificationFromJson(json);
}

@freezed
abstract class NotificationPreference with _$NotificationPreference {
  const factory NotificationPreference({
    @Default(true) bool likes,
    @Default(true) bool comments,
    @Default(true) bool follows,
    @Default(true) bool buddyRequests,
    @Default(true) bool messages,
    @Default(true) bool liveStarts,
    @Default(true) bool gymUpdates,
    @Default(true) bool tips,
    @Default(true) bool marketing,
  }) = _NotificationPreference;

  factory NotificationPreference.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferenceFromJson(json);
}

@freezed
abstract class UnreadCount with _$UnreadCount {
  const factory UnreadCount({
    @Default(0) int count,
  }) = _UnreadCount;

  factory UnreadCount.fromJson(Map<String, dynamic> json) =>
      _$UnreadCountFromJson(json);
}
