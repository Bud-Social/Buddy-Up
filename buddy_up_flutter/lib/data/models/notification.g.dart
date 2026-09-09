// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BuddyNotification _$BuddyNotificationFromJson(Map<String, dynamic> json) =>
    _BuddyNotification(
      id: json['id'] as String,
      notificationType: json['notification_type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      isRead: json['is_read'] as bool? ?? false,
      isPinned: json['is_pinned'] as bool? ?? false,
      senderUsername: json['sender_username'] as String?,
      senderAvatar: json['sender_avatar'] as String?,
      actionLink: json['action_link'] as String?,
      imageUrl: json['image_url'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$BuddyNotificationToJson(_BuddyNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'notification_type': instance.notificationType,
      'title': instance.title,
      'body': instance.body,
      'is_read': instance.isRead,
      'is_pinned': instance.isPinned,
      'sender_username': instance.senderUsername,
      'sender_avatar': instance.senderAvatar,
      'action_link': instance.actionLink,
      'image_url': instance.imageUrl,
      'metadata': instance.metadata,
      'created_at': instance.createdAt,
    };

_NotificationPreference _$NotificationPreferenceFromJson(
  Map<String, dynamic> json,
) => _NotificationPreference(
  pushEnabled: json['push_enabled'] as bool? ?? true,
  emailEnabled: json['email_enabled'] as bool? ?? true,
  inAppEnabled: json['in_app_enabled'] as bool? ?? true,
  quietHoursStart: json['quiet_hours_start'] as String?,
  quietHoursEnd: json['quiet_hours_end'] as String?,
  timezone: const _FlexibleStringConverter().fromJson(json['timezone']),
  categoryFrequency: const _FlexibleStringConverter().fromJson(
    json['category_frequency'],
  ),
  buddyRequestPush: json['buddy_request_push'] as bool? ?? true,
  buddyAcceptedPush: json['buddy_accepted_push'] as bool? ?? true,
  newFollowerPush: json['new_follower_push'] as bool? ?? true,
  commentPush: json['comment_push'] as bool? ?? true,
  liveStartingPush: json['live_starting_push'] as bool? ?? true,
  sessionReminderPush: json['session_reminder_push'] as bool? ?? true,
  streakMilestonePush: json['streak_milestone_push'] as bool? ?? true,
  accountabilityPingPush: json['accountability_ping_push'] as bool? ?? true,
  programmeReminderPush: json['programme_reminder_push'] as bool? ?? true,
  mealReminderPush: json['meal_reminder_push'] as bool? ?? true,
  shopCertPush: json['shop_cert_push'] as bool? ?? true,
  newPurchasePush: json['new_purchase_push'] as bool? ?? true,
);

Map<String, dynamic> _$NotificationPreferenceToJson(
  _NotificationPreference instance,
) => <String, dynamic>{
  'push_enabled': instance.pushEnabled,
  'email_enabled': instance.emailEnabled,
  'in_app_enabled': instance.inAppEnabled,
  'quiet_hours_start': instance.quietHoursStart,
  'quiet_hours_end': instance.quietHoursEnd,
  'timezone': const _FlexibleStringConverter().toJson(instance.timezone),
  'category_frequency': const _FlexibleStringConverter().toJson(
    instance.categoryFrequency,
  ),
  'buddy_request_push': instance.buddyRequestPush,
  'buddy_accepted_push': instance.buddyAcceptedPush,
  'new_follower_push': instance.newFollowerPush,
  'comment_push': instance.commentPush,
  'live_starting_push': instance.liveStartingPush,
  'session_reminder_push': instance.sessionReminderPush,
  'streak_milestone_push': instance.streakMilestonePush,
  'accountability_ping_push': instance.accountabilityPingPush,
  'programme_reminder_push': instance.programmeReminderPush,
  'meal_reminder_push': instance.mealReminderPush,
  'shop_cert_push': instance.shopCertPush,
  'new_purchase_push': instance.newPurchasePush,
};

_UnreadCount _$UnreadCountFromJson(Map<String, dynamic> json) =>
    _UnreadCount(count: (json['count'] as num?)?.toInt() ?? 0);

Map<String, dynamic> _$UnreadCountToJson(_UnreadCount instance) =>
    <String, dynamic>{'count': instance.count};
