// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BuddyNotification {

 String get id;@JsonKey(name: 'notification_type') String get notificationType; String get title; String get body;@JsonKey(name: 'is_read') bool get isRead;@JsonKey(name: 'is_pinned') bool get isPinned;@JsonKey(name: 'sender_username') String? get senderUsername;@JsonKey(name: 'sender_avatar') String? get senderAvatar;@JsonKey(name: 'action_link') String? get actionLink;@JsonKey(name: 'image_url') String? get imageUrl;@JsonKey(name: 'metadata') Map<String, dynamic>? get metadata;@JsonKey(name: 'created_at') String get createdAt;
/// Create a copy of BuddyNotification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BuddyNotificationCopyWith<BuddyNotification> get copyWith => _$BuddyNotificationCopyWithImpl<BuddyNotification>(this as BuddyNotification, _$identity);

  /// Serializes this BuddyNotification to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BuddyNotification&&(identical(other.id, id) || other.id == id)&&(identical(other.notificationType, notificationType) || other.notificationType == notificationType)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned)&&(identical(other.senderUsername, senderUsername) || other.senderUsername == senderUsername)&&(identical(other.senderAvatar, senderAvatar) || other.senderAvatar == senderAvatar)&&(identical(other.actionLink, actionLink) || other.actionLink == actionLink)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,notificationType,title,body,isRead,isPinned,senderUsername,senderAvatar,actionLink,imageUrl,const DeepCollectionEquality().hash(metadata),createdAt);

@override
String toString() {
  return 'BuddyNotification(id: $id, notificationType: $notificationType, title: $title, body: $body, isRead: $isRead, isPinned: $isPinned, senderUsername: $senderUsername, senderAvatar: $senderAvatar, actionLink: $actionLink, imageUrl: $imageUrl, metadata: $metadata, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $BuddyNotificationCopyWith<$Res>  {
  factory $BuddyNotificationCopyWith(BuddyNotification value, $Res Function(BuddyNotification) _then) = _$BuddyNotificationCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'notification_type') String notificationType, String title, String body,@JsonKey(name: 'is_read') bool isRead,@JsonKey(name: 'is_pinned') bool isPinned,@JsonKey(name: 'sender_username') String? senderUsername,@JsonKey(name: 'sender_avatar') String? senderAvatar,@JsonKey(name: 'action_link') String? actionLink,@JsonKey(name: 'image_url') String? imageUrl,@JsonKey(name: 'metadata') Map<String, dynamic>? metadata,@JsonKey(name: 'created_at') String createdAt
});




}
/// @nodoc
class _$BuddyNotificationCopyWithImpl<$Res>
    implements $BuddyNotificationCopyWith<$Res> {
  _$BuddyNotificationCopyWithImpl(this._self, this._then);

  final BuddyNotification _self;
  final $Res Function(BuddyNotification) _then;

/// Create a copy of BuddyNotification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? notificationType = null,Object? title = null,Object? body = null,Object? isRead = null,Object? isPinned = null,Object? senderUsername = freezed,Object? senderAvatar = freezed,Object? actionLink = freezed,Object? imageUrl = freezed,Object? metadata = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,notificationType: null == notificationType ? _self.notificationType : notificationType // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,senderUsername: freezed == senderUsername ? _self.senderUsername : senderUsername // ignore: cast_nullable_to_non_nullable
as String?,senderAvatar: freezed == senderAvatar ? _self.senderAvatar : senderAvatar // ignore: cast_nullable_to_non_nullable
as String?,actionLink: freezed == actionLink ? _self.actionLink : actionLink // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BuddyNotification].
extension BuddyNotificationPatterns on BuddyNotification {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BuddyNotification value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BuddyNotification() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BuddyNotification value)  $default,){
final _that = this;
switch (_that) {
case _BuddyNotification():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BuddyNotification value)?  $default,){
final _that = this;
switch (_that) {
case _BuddyNotification() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'notification_type')  String notificationType,  String title,  String body, @JsonKey(name: 'is_read')  bool isRead, @JsonKey(name: 'is_pinned')  bool isPinned, @JsonKey(name: 'sender_username')  String? senderUsername, @JsonKey(name: 'sender_avatar')  String? senderAvatar, @JsonKey(name: 'action_link')  String? actionLink, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'metadata')  Map<String, dynamic>? metadata, @JsonKey(name: 'created_at')  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BuddyNotification() when $default != null:
return $default(_that.id,_that.notificationType,_that.title,_that.body,_that.isRead,_that.isPinned,_that.senderUsername,_that.senderAvatar,_that.actionLink,_that.imageUrl,_that.metadata,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'notification_type')  String notificationType,  String title,  String body, @JsonKey(name: 'is_read')  bool isRead, @JsonKey(name: 'is_pinned')  bool isPinned, @JsonKey(name: 'sender_username')  String? senderUsername, @JsonKey(name: 'sender_avatar')  String? senderAvatar, @JsonKey(name: 'action_link')  String? actionLink, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'metadata')  Map<String, dynamic>? metadata, @JsonKey(name: 'created_at')  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _BuddyNotification():
return $default(_that.id,_that.notificationType,_that.title,_that.body,_that.isRead,_that.isPinned,_that.senderUsername,_that.senderAvatar,_that.actionLink,_that.imageUrl,_that.metadata,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'notification_type')  String notificationType,  String title,  String body, @JsonKey(name: 'is_read')  bool isRead, @JsonKey(name: 'is_pinned')  bool isPinned, @JsonKey(name: 'sender_username')  String? senderUsername, @JsonKey(name: 'sender_avatar')  String? senderAvatar, @JsonKey(name: 'action_link')  String? actionLink, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'metadata')  Map<String, dynamic>? metadata, @JsonKey(name: 'created_at')  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _BuddyNotification() when $default != null:
return $default(_that.id,_that.notificationType,_that.title,_that.body,_that.isRead,_that.isPinned,_that.senderUsername,_that.senderAvatar,_that.actionLink,_that.imageUrl,_that.metadata,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BuddyNotification implements BuddyNotification {
  const _BuddyNotification({required this.id, @JsonKey(name: 'notification_type') required this.notificationType, required this.title, required this.body, @JsonKey(name: 'is_read') this.isRead = false, @JsonKey(name: 'is_pinned') this.isPinned = false, @JsonKey(name: 'sender_username') this.senderUsername, @JsonKey(name: 'sender_avatar') this.senderAvatar, @JsonKey(name: 'action_link') this.actionLink, @JsonKey(name: 'image_url') this.imageUrl, @JsonKey(name: 'metadata') final  Map<String, dynamic>? metadata, @JsonKey(name: 'created_at') required this.createdAt}): _metadata = metadata;
  factory _BuddyNotification.fromJson(Map<String, dynamic> json) => _$BuddyNotificationFromJson(json);

@override final  String id;
@override@JsonKey(name: 'notification_type') final  String notificationType;
@override final  String title;
@override final  String body;
@override@JsonKey(name: 'is_read') final  bool isRead;
@override@JsonKey(name: 'is_pinned') final  bool isPinned;
@override@JsonKey(name: 'sender_username') final  String? senderUsername;
@override@JsonKey(name: 'sender_avatar') final  String? senderAvatar;
@override@JsonKey(name: 'action_link') final  String? actionLink;
@override@JsonKey(name: 'image_url') final  String? imageUrl;
 final  Map<String, dynamic>? _metadata;
@override@JsonKey(name: 'metadata') Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey(name: 'created_at') final  String createdAt;

/// Create a copy of BuddyNotification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BuddyNotificationCopyWith<_BuddyNotification> get copyWith => __$BuddyNotificationCopyWithImpl<_BuddyNotification>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BuddyNotificationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BuddyNotification&&(identical(other.id, id) || other.id == id)&&(identical(other.notificationType, notificationType) || other.notificationType == notificationType)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned)&&(identical(other.senderUsername, senderUsername) || other.senderUsername == senderUsername)&&(identical(other.senderAvatar, senderAvatar) || other.senderAvatar == senderAvatar)&&(identical(other.actionLink, actionLink) || other.actionLink == actionLink)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,notificationType,title,body,isRead,isPinned,senderUsername,senderAvatar,actionLink,imageUrl,const DeepCollectionEquality().hash(_metadata),createdAt);

@override
String toString() {
  return 'BuddyNotification(id: $id, notificationType: $notificationType, title: $title, body: $body, isRead: $isRead, isPinned: $isPinned, senderUsername: $senderUsername, senderAvatar: $senderAvatar, actionLink: $actionLink, imageUrl: $imageUrl, metadata: $metadata, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$BuddyNotificationCopyWith<$Res> implements $BuddyNotificationCopyWith<$Res> {
  factory _$BuddyNotificationCopyWith(_BuddyNotification value, $Res Function(_BuddyNotification) _then) = __$BuddyNotificationCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'notification_type') String notificationType, String title, String body,@JsonKey(name: 'is_read') bool isRead,@JsonKey(name: 'is_pinned') bool isPinned,@JsonKey(name: 'sender_username') String? senderUsername,@JsonKey(name: 'sender_avatar') String? senderAvatar,@JsonKey(name: 'action_link') String? actionLink,@JsonKey(name: 'image_url') String? imageUrl,@JsonKey(name: 'metadata') Map<String, dynamic>? metadata,@JsonKey(name: 'created_at') String createdAt
});




}
/// @nodoc
class __$BuddyNotificationCopyWithImpl<$Res>
    implements _$BuddyNotificationCopyWith<$Res> {
  __$BuddyNotificationCopyWithImpl(this._self, this._then);

  final _BuddyNotification _self;
  final $Res Function(_BuddyNotification) _then;

/// Create a copy of BuddyNotification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? notificationType = null,Object? title = null,Object? body = null,Object? isRead = null,Object? isPinned = null,Object? senderUsername = freezed,Object? senderAvatar = freezed,Object? actionLink = freezed,Object? imageUrl = freezed,Object? metadata = freezed,Object? createdAt = null,}) {
  return _then(_BuddyNotification(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,notificationType: null == notificationType ? _self.notificationType : notificationType // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,senderUsername: freezed == senderUsername ? _self.senderUsername : senderUsername // ignore: cast_nullable_to_non_nullable
as String?,senderAvatar: freezed == senderAvatar ? _self.senderAvatar : senderAvatar // ignore: cast_nullable_to_non_nullable
as String?,actionLink: freezed == actionLink ? _self.actionLink : actionLink // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$NotificationPreference {

@JsonKey(name: 'push_enabled') bool get pushEnabled;@JsonKey(name: 'email_enabled') bool get emailEnabled;@JsonKey(name: 'in_app_enabled') bool get inAppEnabled;@JsonKey(name: 'quiet_hours_start') String? get quietHoursStart;@JsonKey(name: 'quiet_hours_end') String? get quietHoursEnd;@JsonKey(name: 'timezone')@_FlexibleStringConverter() String? get timezone;@JsonKey(name: 'category_frequency')@_FlexibleStringConverter() String? get categoryFrequency;@JsonKey(name: 'buddy_request_push') bool get buddyRequestPush;@JsonKey(name: 'buddy_accepted_push') bool get buddyAcceptedPush;@JsonKey(name: 'new_follower_push') bool get newFollowerPush;@JsonKey(name: 'comment_push') bool get commentPush;@JsonKey(name: 'live_starting_push') bool get liveStartingPush;@JsonKey(name: 'session_reminder_push') bool get sessionReminderPush;@JsonKey(name: 'streak_milestone_push') bool get streakMilestonePush;@JsonKey(name: 'accountability_ping_push') bool get accountabilityPingPush;@JsonKey(name: 'programme_reminder_push') bool get programmeReminderPush;@JsonKey(name: 'meal_reminder_push') bool get mealReminderPush;@JsonKey(name: 'shop_cert_push') bool get shopCertPush;@JsonKey(name: 'new_purchase_push') bool get newPurchasePush;
/// Create a copy of NotificationPreference
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationPreferenceCopyWith<NotificationPreference> get copyWith => _$NotificationPreferenceCopyWithImpl<NotificationPreference>(this as NotificationPreference, _$identity);

  /// Serializes this NotificationPreference to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationPreference&&(identical(other.pushEnabled, pushEnabled) || other.pushEnabled == pushEnabled)&&(identical(other.emailEnabled, emailEnabled) || other.emailEnabled == emailEnabled)&&(identical(other.inAppEnabled, inAppEnabled) || other.inAppEnabled == inAppEnabled)&&(identical(other.quietHoursStart, quietHoursStart) || other.quietHoursStart == quietHoursStart)&&(identical(other.quietHoursEnd, quietHoursEnd) || other.quietHoursEnd == quietHoursEnd)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.categoryFrequency, categoryFrequency) || other.categoryFrequency == categoryFrequency)&&(identical(other.buddyRequestPush, buddyRequestPush) || other.buddyRequestPush == buddyRequestPush)&&(identical(other.buddyAcceptedPush, buddyAcceptedPush) || other.buddyAcceptedPush == buddyAcceptedPush)&&(identical(other.newFollowerPush, newFollowerPush) || other.newFollowerPush == newFollowerPush)&&(identical(other.commentPush, commentPush) || other.commentPush == commentPush)&&(identical(other.liveStartingPush, liveStartingPush) || other.liveStartingPush == liveStartingPush)&&(identical(other.sessionReminderPush, sessionReminderPush) || other.sessionReminderPush == sessionReminderPush)&&(identical(other.streakMilestonePush, streakMilestonePush) || other.streakMilestonePush == streakMilestonePush)&&(identical(other.accountabilityPingPush, accountabilityPingPush) || other.accountabilityPingPush == accountabilityPingPush)&&(identical(other.programmeReminderPush, programmeReminderPush) || other.programmeReminderPush == programmeReminderPush)&&(identical(other.mealReminderPush, mealReminderPush) || other.mealReminderPush == mealReminderPush)&&(identical(other.shopCertPush, shopCertPush) || other.shopCertPush == shopCertPush)&&(identical(other.newPurchasePush, newPurchasePush) || other.newPurchasePush == newPurchasePush));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,pushEnabled,emailEnabled,inAppEnabled,quietHoursStart,quietHoursEnd,timezone,categoryFrequency,buddyRequestPush,buddyAcceptedPush,newFollowerPush,commentPush,liveStartingPush,sessionReminderPush,streakMilestonePush,accountabilityPingPush,programmeReminderPush,mealReminderPush,shopCertPush,newPurchasePush]);

@override
String toString() {
  return 'NotificationPreference(pushEnabled: $pushEnabled, emailEnabled: $emailEnabled, inAppEnabled: $inAppEnabled, quietHoursStart: $quietHoursStart, quietHoursEnd: $quietHoursEnd, timezone: $timezone, categoryFrequency: $categoryFrequency, buddyRequestPush: $buddyRequestPush, buddyAcceptedPush: $buddyAcceptedPush, newFollowerPush: $newFollowerPush, commentPush: $commentPush, liveStartingPush: $liveStartingPush, sessionReminderPush: $sessionReminderPush, streakMilestonePush: $streakMilestonePush, accountabilityPingPush: $accountabilityPingPush, programmeReminderPush: $programmeReminderPush, mealReminderPush: $mealReminderPush, shopCertPush: $shopCertPush, newPurchasePush: $newPurchasePush)';
}


}

/// @nodoc
abstract mixin class $NotificationPreferenceCopyWith<$Res>  {
  factory $NotificationPreferenceCopyWith(NotificationPreference value, $Res Function(NotificationPreference) _then) = _$NotificationPreferenceCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'push_enabled') bool pushEnabled,@JsonKey(name: 'email_enabled') bool emailEnabled,@JsonKey(name: 'in_app_enabled') bool inAppEnabled,@JsonKey(name: 'quiet_hours_start') String? quietHoursStart,@JsonKey(name: 'quiet_hours_end') String? quietHoursEnd,@JsonKey(name: 'timezone')@_FlexibleStringConverter() String? timezone,@JsonKey(name: 'category_frequency')@_FlexibleStringConverter() String? categoryFrequency,@JsonKey(name: 'buddy_request_push') bool buddyRequestPush,@JsonKey(name: 'buddy_accepted_push') bool buddyAcceptedPush,@JsonKey(name: 'new_follower_push') bool newFollowerPush,@JsonKey(name: 'comment_push') bool commentPush,@JsonKey(name: 'live_starting_push') bool liveStartingPush,@JsonKey(name: 'session_reminder_push') bool sessionReminderPush,@JsonKey(name: 'streak_milestone_push') bool streakMilestonePush,@JsonKey(name: 'accountability_ping_push') bool accountabilityPingPush,@JsonKey(name: 'programme_reminder_push') bool programmeReminderPush,@JsonKey(name: 'meal_reminder_push') bool mealReminderPush,@JsonKey(name: 'shop_cert_push') bool shopCertPush,@JsonKey(name: 'new_purchase_push') bool newPurchasePush
});




}
/// @nodoc
class _$NotificationPreferenceCopyWithImpl<$Res>
    implements $NotificationPreferenceCopyWith<$Res> {
  _$NotificationPreferenceCopyWithImpl(this._self, this._then);

  final NotificationPreference _self;
  final $Res Function(NotificationPreference) _then;

/// Create a copy of NotificationPreference
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pushEnabled = null,Object? emailEnabled = null,Object? inAppEnabled = null,Object? quietHoursStart = freezed,Object? quietHoursEnd = freezed,Object? timezone = freezed,Object? categoryFrequency = freezed,Object? buddyRequestPush = null,Object? buddyAcceptedPush = null,Object? newFollowerPush = null,Object? commentPush = null,Object? liveStartingPush = null,Object? sessionReminderPush = null,Object? streakMilestonePush = null,Object? accountabilityPingPush = null,Object? programmeReminderPush = null,Object? mealReminderPush = null,Object? shopCertPush = null,Object? newPurchasePush = null,}) {
  return _then(_self.copyWith(
pushEnabled: null == pushEnabled ? _self.pushEnabled : pushEnabled // ignore: cast_nullable_to_non_nullable
as bool,emailEnabled: null == emailEnabled ? _self.emailEnabled : emailEnabled // ignore: cast_nullable_to_non_nullable
as bool,inAppEnabled: null == inAppEnabled ? _self.inAppEnabled : inAppEnabled // ignore: cast_nullable_to_non_nullable
as bool,quietHoursStart: freezed == quietHoursStart ? _self.quietHoursStart : quietHoursStart // ignore: cast_nullable_to_non_nullable
as String?,quietHoursEnd: freezed == quietHoursEnd ? _self.quietHoursEnd : quietHoursEnd // ignore: cast_nullable_to_non_nullable
as String?,timezone: freezed == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String?,categoryFrequency: freezed == categoryFrequency ? _self.categoryFrequency : categoryFrequency // ignore: cast_nullable_to_non_nullable
as String?,buddyRequestPush: null == buddyRequestPush ? _self.buddyRequestPush : buddyRequestPush // ignore: cast_nullable_to_non_nullable
as bool,buddyAcceptedPush: null == buddyAcceptedPush ? _self.buddyAcceptedPush : buddyAcceptedPush // ignore: cast_nullable_to_non_nullable
as bool,newFollowerPush: null == newFollowerPush ? _self.newFollowerPush : newFollowerPush // ignore: cast_nullable_to_non_nullable
as bool,commentPush: null == commentPush ? _self.commentPush : commentPush // ignore: cast_nullable_to_non_nullable
as bool,liveStartingPush: null == liveStartingPush ? _self.liveStartingPush : liveStartingPush // ignore: cast_nullable_to_non_nullable
as bool,sessionReminderPush: null == sessionReminderPush ? _self.sessionReminderPush : sessionReminderPush // ignore: cast_nullable_to_non_nullable
as bool,streakMilestonePush: null == streakMilestonePush ? _self.streakMilestonePush : streakMilestonePush // ignore: cast_nullable_to_non_nullable
as bool,accountabilityPingPush: null == accountabilityPingPush ? _self.accountabilityPingPush : accountabilityPingPush // ignore: cast_nullable_to_non_nullable
as bool,programmeReminderPush: null == programmeReminderPush ? _self.programmeReminderPush : programmeReminderPush // ignore: cast_nullable_to_non_nullable
as bool,mealReminderPush: null == mealReminderPush ? _self.mealReminderPush : mealReminderPush // ignore: cast_nullable_to_non_nullable
as bool,shopCertPush: null == shopCertPush ? _self.shopCertPush : shopCertPush // ignore: cast_nullable_to_non_nullable
as bool,newPurchasePush: null == newPurchasePush ? _self.newPurchasePush : newPurchasePush // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationPreference].
extension NotificationPreferencePatterns on NotificationPreference {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationPreference value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationPreference() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationPreference value)  $default,){
final _that = this;
switch (_that) {
case _NotificationPreference():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationPreference value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationPreference() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'push_enabled')  bool pushEnabled, @JsonKey(name: 'email_enabled')  bool emailEnabled, @JsonKey(name: 'in_app_enabled')  bool inAppEnabled, @JsonKey(name: 'quiet_hours_start')  String? quietHoursStart, @JsonKey(name: 'quiet_hours_end')  String? quietHoursEnd, @JsonKey(name: 'timezone')@_FlexibleStringConverter()  String? timezone, @JsonKey(name: 'category_frequency')@_FlexibleStringConverter()  String? categoryFrequency, @JsonKey(name: 'buddy_request_push')  bool buddyRequestPush, @JsonKey(name: 'buddy_accepted_push')  bool buddyAcceptedPush, @JsonKey(name: 'new_follower_push')  bool newFollowerPush, @JsonKey(name: 'comment_push')  bool commentPush, @JsonKey(name: 'live_starting_push')  bool liveStartingPush, @JsonKey(name: 'session_reminder_push')  bool sessionReminderPush, @JsonKey(name: 'streak_milestone_push')  bool streakMilestonePush, @JsonKey(name: 'accountability_ping_push')  bool accountabilityPingPush, @JsonKey(name: 'programme_reminder_push')  bool programmeReminderPush, @JsonKey(name: 'meal_reminder_push')  bool mealReminderPush, @JsonKey(name: 'shop_cert_push')  bool shopCertPush, @JsonKey(name: 'new_purchase_push')  bool newPurchasePush)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationPreference() when $default != null:
return $default(_that.pushEnabled,_that.emailEnabled,_that.inAppEnabled,_that.quietHoursStart,_that.quietHoursEnd,_that.timezone,_that.categoryFrequency,_that.buddyRequestPush,_that.buddyAcceptedPush,_that.newFollowerPush,_that.commentPush,_that.liveStartingPush,_that.sessionReminderPush,_that.streakMilestonePush,_that.accountabilityPingPush,_that.programmeReminderPush,_that.mealReminderPush,_that.shopCertPush,_that.newPurchasePush);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'push_enabled')  bool pushEnabled, @JsonKey(name: 'email_enabled')  bool emailEnabled, @JsonKey(name: 'in_app_enabled')  bool inAppEnabled, @JsonKey(name: 'quiet_hours_start')  String? quietHoursStart, @JsonKey(name: 'quiet_hours_end')  String? quietHoursEnd, @JsonKey(name: 'timezone')@_FlexibleStringConverter()  String? timezone, @JsonKey(name: 'category_frequency')@_FlexibleStringConverter()  String? categoryFrequency, @JsonKey(name: 'buddy_request_push')  bool buddyRequestPush, @JsonKey(name: 'buddy_accepted_push')  bool buddyAcceptedPush, @JsonKey(name: 'new_follower_push')  bool newFollowerPush, @JsonKey(name: 'comment_push')  bool commentPush, @JsonKey(name: 'live_starting_push')  bool liveStartingPush, @JsonKey(name: 'session_reminder_push')  bool sessionReminderPush, @JsonKey(name: 'streak_milestone_push')  bool streakMilestonePush, @JsonKey(name: 'accountability_ping_push')  bool accountabilityPingPush, @JsonKey(name: 'programme_reminder_push')  bool programmeReminderPush, @JsonKey(name: 'meal_reminder_push')  bool mealReminderPush, @JsonKey(name: 'shop_cert_push')  bool shopCertPush, @JsonKey(name: 'new_purchase_push')  bool newPurchasePush)  $default,) {final _that = this;
switch (_that) {
case _NotificationPreference():
return $default(_that.pushEnabled,_that.emailEnabled,_that.inAppEnabled,_that.quietHoursStart,_that.quietHoursEnd,_that.timezone,_that.categoryFrequency,_that.buddyRequestPush,_that.buddyAcceptedPush,_that.newFollowerPush,_that.commentPush,_that.liveStartingPush,_that.sessionReminderPush,_that.streakMilestonePush,_that.accountabilityPingPush,_that.programmeReminderPush,_that.mealReminderPush,_that.shopCertPush,_that.newPurchasePush);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'push_enabled')  bool pushEnabled, @JsonKey(name: 'email_enabled')  bool emailEnabled, @JsonKey(name: 'in_app_enabled')  bool inAppEnabled, @JsonKey(name: 'quiet_hours_start')  String? quietHoursStart, @JsonKey(name: 'quiet_hours_end')  String? quietHoursEnd, @JsonKey(name: 'timezone')@_FlexibleStringConverter()  String? timezone, @JsonKey(name: 'category_frequency')@_FlexibleStringConverter()  String? categoryFrequency, @JsonKey(name: 'buddy_request_push')  bool buddyRequestPush, @JsonKey(name: 'buddy_accepted_push')  bool buddyAcceptedPush, @JsonKey(name: 'new_follower_push')  bool newFollowerPush, @JsonKey(name: 'comment_push')  bool commentPush, @JsonKey(name: 'live_starting_push')  bool liveStartingPush, @JsonKey(name: 'session_reminder_push')  bool sessionReminderPush, @JsonKey(name: 'streak_milestone_push')  bool streakMilestonePush, @JsonKey(name: 'accountability_ping_push')  bool accountabilityPingPush, @JsonKey(name: 'programme_reminder_push')  bool programmeReminderPush, @JsonKey(name: 'meal_reminder_push')  bool mealReminderPush, @JsonKey(name: 'shop_cert_push')  bool shopCertPush, @JsonKey(name: 'new_purchase_push')  bool newPurchasePush)?  $default,) {final _that = this;
switch (_that) {
case _NotificationPreference() when $default != null:
return $default(_that.pushEnabled,_that.emailEnabled,_that.inAppEnabled,_that.quietHoursStart,_that.quietHoursEnd,_that.timezone,_that.categoryFrequency,_that.buddyRequestPush,_that.buddyAcceptedPush,_that.newFollowerPush,_that.commentPush,_that.liveStartingPush,_that.sessionReminderPush,_that.streakMilestonePush,_that.accountabilityPingPush,_that.programmeReminderPush,_that.mealReminderPush,_that.shopCertPush,_that.newPurchasePush);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationPreference implements NotificationPreference {
  const _NotificationPreference({@JsonKey(name: 'push_enabled') this.pushEnabled = true, @JsonKey(name: 'email_enabled') this.emailEnabled = true, @JsonKey(name: 'in_app_enabled') this.inAppEnabled = true, @JsonKey(name: 'quiet_hours_start') this.quietHoursStart, @JsonKey(name: 'quiet_hours_end') this.quietHoursEnd, @JsonKey(name: 'timezone')@_FlexibleStringConverter() this.timezone, @JsonKey(name: 'category_frequency')@_FlexibleStringConverter() this.categoryFrequency, @JsonKey(name: 'buddy_request_push') this.buddyRequestPush = true, @JsonKey(name: 'buddy_accepted_push') this.buddyAcceptedPush = true, @JsonKey(name: 'new_follower_push') this.newFollowerPush = true, @JsonKey(name: 'comment_push') this.commentPush = true, @JsonKey(name: 'live_starting_push') this.liveStartingPush = true, @JsonKey(name: 'session_reminder_push') this.sessionReminderPush = true, @JsonKey(name: 'streak_milestone_push') this.streakMilestonePush = true, @JsonKey(name: 'accountability_ping_push') this.accountabilityPingPush = true, @JsonKey(name: 'programme_reminder_push') this.programmeReminderPush = true, @JsonKey(name: 'meal_reminder_push') this.mealReminderPush = true, @JsonKey(name: 'shop_cert_push') this.shopCertPush = true, @JsonKey(name: 'new_purchase_push') this.newPurchasePush = true});
  factory _NotificationPreference.fromJson(Map<String, dynamic> json) => _$NotificationPreferenceFromJson(json);

@override@JsonKey(name: 'push_enabled') final  bool pushEnabled;
@override@JsonKey(name: 'email_enabled') final  bool emailEnabled;
@override@JsonKey(name: 'in_app_enabled') final  bool inAppEnabled;
@override@JsonKey(name: 'quiet_hours_start') final  String? quietHoursStart;
@override@JsonKey(name: 'quiet_hours_end') final  String? quietHoursEnd;
@override@JsonKey(name: 'timezone')@_FlexibleStringConverter() final  String? timezone;
@override@JsonKey(name: 'category_frequency')@_FlexibleStringConverter() final  String? categoryFrequency;
@override@JsonKey(name: 'buddy_request_push') final  bool buddyRequestPush;
@override@JsonKey(name: 'buddy_accepted_push') final  bool buddyAcceptedPush;
@override@JsonKey(name: 'new_follower_push') final  bool newFollowerPush;
@override@JsonKey(name: 'comment_push') final  bool commentPush;
@override@JsonKey(name: 'live_starting_push') final  bool liveStartingPush;
@override@JsonKey(name: 'session_reminder_push') final  bool sessionReminderPush;
@override@JsonKey(name: 'streak_milestone_push') final  bool streakMilestonePush;
@override@JsonKey(name: 'accountability_ping_push') final  bool accountabilityPingPush;
@override@JsonKey(name: 'programme_reminder_push') final  bool programmeReminderPush;
@override@JsonKey(name: 'meal_reminder_push') final  bool mealReminderPush;
@override@JsonKey(name: 'shop_cert_push') final  bool shopCertPush;
@override@JsonKey(name: 'new_purchase_push') final  bool newPurchasePush;

/// Create a copy of NotificationPreference
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationPreferenceCopyWith<_NotificationPreference> get copyWith => __$NotificationPreferenceCopyWithImpl<_NotificationPreference>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationPreferenceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationPreference&&(identical(other.pushEnabled, pushEnabled) || other.pushEnabled == pushEnabled)&&(identical(other.emailEnabled, emailEnabled) || other.emailEnabled == emailEnabled)&&(identical(other.inAppEnabled, inAppEnabled) || other.inAppEnabled == inAppEnabled)&&(identical(other.quietHoursStart, quietHoursStart) || other.quietHoursStart == quietHoursStart)&&(identical(other.quietHoursEnd, quietHoursEnd) || other.quietHoursEnd == quietHoursEnd)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.categoryFrequency, categoryFrequency) || other.categoryFrequency == categoryFrequency)&&(identical(other.buddyRequestPush, buddyRequestPush) || other.buddyRequestPush == buddyRequestPush)&&(identical(other.buddyAcceptedPush, buddyAcceptedPush) || other.buddyAcceptedPush == buddyAcceptedPush)&&(identical(other.newFollowerPush, newFollowerPush) || other.newFollowerPush == newFollowerPush)&&(identical(other.commentPush, commentPush) || other.commentPush == commentPush)&&(identical(other.liveStartingPush, liveStartingPush) || other.liveStartingPush == liveStartingPush)&&(identical(other.sessionReminderPush, sessionReminderPush) || other.sessionReminderPush == sessionReminderPush)&&(identical(other.streakMilestonePush, streakMilestonePush) || other.streakMilestonePush == streakMilestonePush)&&(identical(other.accountabilityPingPush, accountabilityPingPush) || other.accountabilityPingPush == accountabilityPingPush)&&(identical(other.programmeReminderPush, programmeReminderPush) || other.programmeReminderPush == programmeReminderPush)&&(identical(other.mealReminderPush, mealReminderPush) || other.mealReminderPush == mealReminderPush)&&(identical(other.shopCertPush, shopCertPush) || other.shopCertPush == shopCertPush)&&(identical(other.newPurchasePush, newPurchasePush) || other.newPurchasePush == newPurchasePush));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,pushEnabled,emailEnabled,inAppEnabled,quietHoursStart,quietHoursEnd,timezone,categoryFrequency,buddyRequestPush,buddyAcceptedPush,newFollowerPush,commentPush,liveStartingPush,sessionReminderPush,streakMilestonePush,accountabilityPingPush,programmeReminderPush,mealReminderPush,shopCertPush,newPurchasePush]);

@override
String toString() {
  return 'NotificationPreference(pushEnabled: $pushEnabled, emailEnabled: $emailEnabled, inAppEnabled: $inAppEnabled, quietHoursStart: $quietHoursStart, quietHoursEnd: $quietHoursEnd, timezone: $timezone, categoryFrequency: $categoryFrequency, buddyRequestPush: $buddyRequestPush, buddyAcceptedPush: $buddyAcceptedPush, newFollowerPush: $newFollowerPush, commentPush: $commentPush, liveStartingPush: $liveStartingPush, sessionReminderPush: $sessionReminderPush, streakMilestonePush: $streakMilestonePush, accountabilityPingPush: $accountabilityPingPush, programmeReminderPush: $programmeReminderPush, mealReminderPush: $mealReminderPush, shopCertPush: $shopCertPush, newPurchasePush: $newPurchasePush)';
}


}

/// @nodoc
abstract mixin class _$NotificationPreferenceCopyWith<$Res> implements $NotificationPreferenceCopyWith<$Res> {
  factory _$NotificationPreferenceCopyWith(_NotificationPreference value, $Res Function(_NotificationPreference) _then) = __$NotificationPreferenceCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'push_enabled') bool pushEnabled,@JsonKey(name: 'email_enabled') bool emailEnabled,@JsonKey(name: 'in_app_enabled') bool inAppEnabled,@JsonKey(name: 'quiet_hours_start') String? quietHoursStart,@JsonKey(name: 'quiet_hours_end') String? quietHoursEnd,@JsonKey(name: 'timezone')@_FlexibleStringConverter() String? timezone,@JsonKey(name: 'category_frequency')@_FlexibleStringConverter() String? categoryFrequency,@JsonKey(name: 'buddy_request_push') bool buddyRequestPush,@JsonKey(name: 'buddy_accepted_push') bool buddyAcceptedPush,@JsonKey(name: 'new_follower_push') bool newFollowerPush,@JsonKey(name: 'comment_push') bool commentPush,@JsonKey(name: 'live_starting_push') bool liveStartingPush,@JsonKey(name: 'session_reminder_push') bool sessionReminderPush,@JsonKey(name: 'streak_milestone_push') bool streakMilestonePush,@JsonKey(name: 'accountability_ping_push') bool accountabilityPingPush,@JsonKey(name: 'programme_reminder_push') bool programmeReminderPush,@JsonKey(name: 'meal_reminder_push') bool mealReminderPush,@JsonKey(name: 'shop_cert_push') bool shopCertPush,@JsonKey(name: 'new_purchase_push') bool newPurchasePush
});




}
/// @nodoc
class __$NotificationPreferenceCopyWithImpl<$Res>
    implements _$NotificationPreferenceCopyWith<$Res> {
  __$NotificationPreferenceCopyWithImpl(this._self, this._then);

  final _NotificationPreference _self;
  final $Res Function(_NotificationPreference) _then;

/// Create a copy of NotificationPreference
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pushEnabled = null,Object? emailEnabled = null,Object? inAppEnabled = null,Object? quietHoursStart = freezed,Object? quietHoursEnd = freezed,Object? timezone = freezed,Object? categoryFrequency = freezed,Object? buddyRequestPush = null,Object? buddyAcceptedPush = null,Object? newFollowerPush = null,Object? commentPush = null,Object? liveStartingPush = null,Object? sessionReminderPush = null,Object? streakMilestonePush = null,Object? accountabilityPingPush = null,Object? programmeReminderPush = null,Object? mealReminderPush = null,Object? shopCertPush = null,Object? newPurchasePush = null,}) {
  return _then(_NotificationPreference(
pushEnabled: null == pushEnabled ? _self.pushEnabled : pushEnabled // ignore: cast_nullable_to_non_nullable
as bool,emailEnabled: null == emailEnabled ? _self.emailEnabled : emailEnabled // ignore: cast_nullable_to_non_nullable
as bool,inAppEnabled: null == inAppEnabled ? _self.inAppEnabled : inAppEnabled // ignore: cast_nullable_to_non_nullable
as bool,quietHoursStart: freezed == quietHoursStart ? _self.quietHoursStart : quietHoursStart // ignore: cast_nullable_to_non_nullable
as String?,quietHoursEnd: freezed == quietHoursEnd ? _self.quietHoursEnd : quietHoursEnd // ignore: cast_nullable_to_non_nullable
as String?,timezone: freezed == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String?,categoryFrequency: freezed == categoryFrequency ? _self.categoryFrequency : categoryFrequency // ignore: cast_nullable_to_non_nullable
as String?,buddyRequestPush: null == buddyRequestPush ? _self.buddyRequestPush : buddyRequestPush // ignore: cast_nullable_to_non_nullable
as bool,buddyAcceptedPush: null == buddyAcceptedPush ? _self.buddyAcceptedPush : buddyAcceptedPush // ignore: cast_nullable_to_non_nullable
as bool,newFollowerPush: null == newFollowerPush ? _self.newFollowerPush : newFollowerPush // ignore: cast_nullable_to_non_nullable
as bool,commentPush: null == commentPush ? _self.commentPush : commentPush // ignore: cast_nullable_to_non_nullable
as bool,liveStartingPush: null == liveStartingPush ? _self.liveStartingPush : liveStartingPush // ignore: cast_nullable_to_non_nullable
as bool,sessionReminderPush: null == sessionReminderPush ? _self.sessionReminderPush : sessionReminderPush // ignore: cast_nullable_to_non_nullable
as bool,streakMilestonePush: null == streakMilestonePush ? _self.streakMilestonePush : streakMilestonePush // ignore: cast_nullable_to_non_nullable
as bool,accountabilityPingPush: null == accountabilityPingPush ? _self.accountabilityPingPush : accountabilityPingPush // ignore: cast_nullable_to_non_nullable
as bool,programmeReminderPush: null == programmeReminderPush ? _self.programmeReminderPush : programmeReminderPush // ignore: cast_nullable_to_non_nullable
as bool,mealReminderPush: null == mealReminderPush ? _self.mealReminderPush : mealReminderPush // ignore: cast_nullable_to_non_nullable
as bool,shopCertPush: null == shopCertPush ? _self.shopCertPush : shopCertPush // ignore: cast_nullable_to_non_nullable
as bool,newPurchasePush: null == newPurchasePush ? _self.newPurchasePush : newPurchasePush // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$UnreadCount {

 int get count;
/// Create a copy of UnreadCount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnreadCountCopyWith<UnreadCount> get copyWith => _$UnreadCountCopyWithImpl<UnreadCount>(this as UnreadCount, _$identity);

  /// Serializes this UnreadCount to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnreadCount&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,count);

@override
String toString() {
  return 'UnreadCount(count: $count)';
}


}

/// @nodoc
abstract mixin class $UnreadCountCopyWith<$Res>  {
  factory $UnreadCountCopyWith(UnreadCount value, $Res Function(UnreadCount) _then) = _$UnreadCountCopyWithImpl;
@useResult
$Res call({
 int count
});




}
/// @nodoc
class _$UnreadCountCopyWithImpl<$Res>
    implements $UnreadCountCopyWith<$Res> {
  _$UnreadCountCopyWithImpl(this._self, this._then);

  final UnreadCount _self;
  final $Res Function(UnreadCount) _then;

/// Create a copy of UnreadCount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? count = null,}) {
  return _then(_self.copyWith(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [UnreadCount].
extension UnreadCountPatterns on UnreadCount {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UnreadCount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UnreadCount() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UnreadCount value)  $default,){
final _that = this;
switch (_that) {
case _UnreadCount():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UnreadCount value)?  $default,){
final _that = this;
switch (_that) {
case _UnreadCount() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UnreadCount() when $default != null:
return $default(_that.count);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int count)  $default,) {final _that = this;
switch (_that) {
case _UnreadCount():
return $default(_that.count);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int count)?  $default,) {final _that = this;
switch (_that) {
case _UnreadCount() when $default != null:
return $default(_that.count);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UnreadCount implements UnreadCount {
  const _UnreadCount({this.count = 0});
  factory _UnreadCount.fromJson(Map<String, dynamic> json) => _$UnreadCountFromJson(json);

@override@JsonKey() final  int count;

/// Create a copy of UnreadCount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnreadCountCopyWith<_UnreadCount> get copyWith => __$UnreadCountCopyWithImpl<_UnreadCount>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UnreadCountToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnreadCount&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,count);

@override
String toString() {
  return 'UnreadCount(count: $count)';
}


}

/// @nodoc
abstract mixin class _$UnreadCountCopyWith<$Res> implements $UnreadCountCopyWith<$Res> {
  factory _$UnreadCountCopyWith(_UnreadCount value, $Res Function(_UnreadCount) _then) = __$UnreadCountCopyWithImpl;
@override @useResult
$Res call({
 int count
});




}
/// @nodoc
class __$UnreadCountCopyWithImpl<$Res>
    implements _$UnreadCountCopyWith<$Res> {
  __$UnreadCountCopyWithImpl(this._self, this._then);

  final _UnreadCount _self;
  final $Res Function(_UnreadCount) _then;

/// Create a copy of UnreadCount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? count = null,}) {
  return _then(_UnreadCount(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
