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
  likes: json['likes'] as bool? ?? true,
  comments: json['comments'] as bool? ?? true,
  follows: json['follows'] as bool? ?? true,
  buddyRequests: json['buddyRequests'] as bool? ?? true,
  messages: json['messages'] as bool? ?? true,
  liveStarts: json['liveStarts'] as bool? ?? true,
  gymUpdates: json['gymUpdates'] as bool? ?? true,
  tips: json['tips'] as bool? ?? true,
  marketing: json['marketing'] as bool? ?? true,
);

Map<String, dynamic> _$NotificationPreferenceToJson(
  _NotificationPreference instance,
) => <String, dynamic>{
  'likes': instance.likes,
  'comments': instance.comments,
  'follows': instance.follows,
  'buddyRequests': instance.buddyRequests,
  'messages': instance.messages,
  'liveStarts': instance.liveStarts,
  'gymUpdates': instance.gymUpdates,
  'tips': instance.tips,
  'marketing': instance.marketing,
};

_UnreadCount _$UnreadCountFromJson(Map<String, dynamic> json) =>
    _UnreadCount(count: (json['count'] as num?)?.toInt() ?? 0);

Map<String, dynamic> _$UnreadCountToJson(_UnreadCount instance) =>
    <String, dynamic>{'count': instance.count};
