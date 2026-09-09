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

/// Coerces non-string JSON values (e.g. a dict the backend may send for
/// category_frequency) to null instead of throwing a cast error.
class _FlexibleStringConverter implements JsonConverter<String?, dynamic> {
  const _FlexibleStringConverter();

  @override
  String? fromJson(dynamic json) => json is String ? json : null;

  @override
  dynamic toJson(String? object) => object;
}

@freezed
abstract class NotificationPreference with _$NotificationPreference {
  const factory NotificationPreference({
    @JsonKey(name: 'push_enabled') @Default(true) bool pushEnabled,
    @JsonKey(name: 'email_enabled') @Default(true) bool emailEnabled,
    @JsonKey(name: 'in_app_enabled') @Default(true) bool inAppEnabled,
    @JsonKey(name: 'quiet_hours_start') String? quietHoursStart,
    @JsonKey(name: 'quiet_hours_end') String? quietHoursEnd,
    @JsonKey(name: 'timezone') @_FlexibleStringConverter() String? timezone,
    @JsonKey(name: 'category_frequency')
    @_FlexibleStringConverter()
    String? categoryFrequency,
    @JsonKey(name: 'buddy_request_push') @Default(true) bool buddyRequestPush,
    @JsonKey(name: 'buddy_accepted_push') @Default(true) bool buddyAcceptedPush,
    @JsonKey(name: 'new_follower_push') @Default(true) bool newFollowerPush,
    @JsonKey(name: 'comment_push') @Default(true) bool commentPush,
    @JsonKey(name: 'live_starting_push') @Default(true) bool liveStartingPush,
    @JsonKey(name: 'session_reminder_push')
    @Default(true)
    bool sessionReminderPush,
    @JsonKey(name: 'streak_milestone_push')
    @Default(true)
    bool streakMilestonePush,
    @JsonKey(name: 'accountability_ping_push')
    @Default(true)
    bool accountabilityPingPush,
    @JsonKey(name: 'programme_reminder_push')
    @Default(true)
    bool programmeReminderPush,
    @JsonKey(name: 'meal_reminder_push') @Default(true) bool mealReminderPush,
    @JsonKey(name: 'shop_cert_push') @Default(true) bool shopCertPush,
    @JsonKey(name: 'new_purchase_push') @Default(true) bool newPurchasePush,
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
