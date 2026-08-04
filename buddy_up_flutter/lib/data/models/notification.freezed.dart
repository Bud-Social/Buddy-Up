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

 String get id;@JsonKey(name: 'notification_type') String get notificationType; String get title; String get body;@JsonKey(name: 'is_read') bool get isRead;@JsonKey(name: 'sender_username') String? get senderUsername;@JsonKey(name: 'sender_avatar') String? get senderAvatar;@JsonKey(name: 'action_link') String? get actionLink;@JsonKey(name: 'image_url') String? get imageUrl;@JsonKey(name: 'metadata') Map<String, dynamic>? get metadata;@JsonKey(name: 'created_at') String get createdAt;
/// Create a copy of BuddyNotification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BuddyNotificationCopyWith<BuddyNotification> get copyWith => _$BuddyNotificationCopyWithImpl<BuddyNotification>(this as BuddyNotification, _$identity);

  /// Serializes this BuddyNotification to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BuddyNotification&&(identical(other.id, id) || other.id == id)&&(identical(other.notificationType, notificationType) || other.notificationType == notificationType)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.senderUsername, senderUsername) || other.senderUsername == senderUsername)&&(identical(other.senderAvatar, senderAvatar) || other.senderAvatar == senderAvatar)&&(identical(other.actionLink, actionLink) || other.actionLink == actionLink)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,notificationType,title,body,isRead,senderUsername,senderAvatar,actionLink,imageUrl,const DeepCollectionEquality().hash(metadata),createdAt);

@override
String toString() {
  return 'BuddyNotification(id: $id, notificationType: $notificationType, title: $title, body: $body, isRead: $isRead, senderUsername: $senderUsername, senderAvatar: $senderAvatar, actionLink: $actionLink, imageUrl: $imageUrl, metadata: $metadata, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $BuddyNotificationCopyWith<$Res>  {
  factory $BuddyNotificationCopyWith(BuddyNotification value, $Res Function(BuddyNotification) _then) = _$BuddyNotificationCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'notification_type') String notificationType, String title, String body,@JsonKey(name: 'is_read') bool isRead,@JsonKey(name: 'sender_username') String? senderUsername,@JsonKey(name: 'sender_avatar') String? senderAvatar,@JsonKey(name: 'action_link') String? actionLink,@JsonKey(name: 'image_url') String? imageUrl,@JsonKey(name: 'metadata') Map<String, dynamic>? metadata,@JsonKey(name: 'created_at') String createdAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? notificationType = null,Object? title = null,Object? body = null,Object? isRead = null,Object? senderUsername = freezed,Object? senderAvatar = freezed,Object? actionLink = freezed,Object? imageUrl = freezed,Object? metadata = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,notificationType: null == notificationType ? _self.notificationType : notificationType // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'notification_type')  String notificationType,  String title,  String body, @JsonKey(name: 'is_read')  bool isRead, @JsonKey(name: 'sender_username')  String? senderUsername, @JsonKey(name: 'sender_avatar')  String? senderAvatar, @JsonKey(name: 'action_link')  String? actionLink, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'metadata')  Map<String, dynamic>? metadata, @JsonKey(name: 'created_at')  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BuddyNotification() when $default != null:
return $default(_that.id,_that.notificationType,_that.title,_that.body,_that.isRead,_that.senderUsername,_that.senderAvatar,_that.actionLink,_that.imageUrl,_that.metadata,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'notification_type')  String notificationType,  String title,  String body, @JsonKey(name: 'is_read')  bool isRead, @JsonKey(name: 'sender_username')  String? senderUsername, @JsonKey(name: 'sender_avatar')  String? senderAvatar, @JsonKey(name: 'action_link')  String? actionLink, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'metadata')  Map<String, dynamic>? metadata, @JsonKey(name: 'created_at')  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _BuddyNotification():
return $default(_that.id,_that.notificationType,_that.title,_that.body,_that.isRead,_that.senderUsername,_that.senderAvatar,_that.actionLink,_that.imageUrl,_that.metadata,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'notification_type')  String notificationType,  String title,  String body, @JsonKey(name: 'is_read')  bool isRead, @JsonKey(name: 'sender_username')  String? senderUsername, @JsonKey(name: 'sender_avatar')  String? senderAvatar, @JsonKey(name: 'action_link')  String? actionLink, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'metadata')  Map<String, dynamic>? metadata, @JsonKey(name: 'created_at')  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _BuddyNotification() when $default != null:
return $default(_that.id,_that.notificationType,_that.title,_that.body,_that.isRead,_that.senderUsername,_that.senderAvatar,_that.actionLink,_that.imageUrl,_that.metadata,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BuddyNotification implements BuddyNotification {
  const _BuddyNotification({required this.id, @JsonKey(name: 'notification_type') required this.notificationType, required this.title, required this.body, @JsonKey(name: 'is_read') this.isRead = false, @JsonKey(name: 'sender_username') this.senderUsername, @JsonKey(name: 'sender_avatar') this.senderAvatar, @JsonKey(name: 'action_link') this.actionLink, @JsonKey(name: 'image_url') this.imageUrl, @JsonKey(name: 'metadata') final  Map<String, dynamic>? metadata, @JsonKey(name: 'created_at') required this.createdAt}): _metadata = metadata;
  factory _BuddyNotification.fromJson(Map<String, dynamic> json) => _$BuddyNotificationFromJson(json);

@override final  String id;
@override@JsonKey(name: 'notification_type') final  String notificationType;
@override final  String title;
@override final  String body;
@override@JsonKey(name: 'is_read') final  bool isRead;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BuddyNotification&&(identical(other.id, id) || other.id == id)&&(identical(other.notificationType, notificationType) || other.notificationType == notificationType)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.senderUsername, senderUsername) || other.senderUsername == senderUsername)&&(identical(other.senderAvatar, senderAvatar) || other.senderAvatar == senderAvatar)&&(identical(other.actionLink, actionLink) || other.actionLink == actionLink)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,notificationType,title,body,isRead,senderUsername,senderAvatar,actionLink,imageUrl,const DeepCollectionEquality().hash(_metadata),createdAt);

@override
String toString() {
  return 'BuddyNotification(id: $id, notificationType: $notificationType, title: $title, body: $body, isRead: $isRead, senderUsername: $senderUsername, senderAvatar: $senderAvatar, actionLink: $actionLink, imageUrl: $imageUrl, metadata: $metadata, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$BuddyNotificationCopyWith<$Res> implements $BuddyNotificationCopyWith<$Res> {
  factory _$BuddyNotificationCopyWith(_BuddyNotification value, $Res Function(_BuddyNotification) _then) = __$BuddyNotificationCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'notification_type') String notificationType, String title, String body,@JsonKey(name: 'is_read') bool isRead,@JsonKey(name: 'sender_username') String? senderUsername,@JsonKey(name: 'sender_avatar') String? senderAvatar,@JsonKey(name: 'action_link') String? actionLink,@JsonKey(name: 'image_url') String? imageUrl,@JsonKey(name: 'metadata') Map<String, dynamic>? metadata,@JsonKey(name: 'created_at') String createdAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? notificationType = null,Object? title = null,Object? body = null,Object? isRead = null,Object? senderUsername = freezed,Object? senderAvatar = freezed,Object? actionLink = freezed,Object? imageUrl = freezed,Object? metadata = freezed,Object? createdAt = null,}) {
  return _then(_BuddyNotification(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,notificationType: null == notificationType ? _self.notificationType : notificationType // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
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

 bool get likes; bool get comments; bool get follows; bool get buddyRequests; bool get messages; bool get liveStarts; bool get gymUpdates; bool get tips; bool get marketing;
/// Create a copy of NotificationPreference
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationPreferenceCopyWith<NotificationPreference> get copyWith => _$NotificationPreferenceCopyWithImpl<NotificationPreference>(this as NotificationPreference, _$identity);

  /// Serializes this NotificationPreference to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationPreference&&(identical(other.likes, likes) || other.likes == likes)&&(identical(other.comments, comments) || other.comments == comments)&&(identical(other.follows, follows) || other.follows == follows)&&(identical(other.buddyRequests, buddyRequests) || other.buddyRequests == buddyRequests)&&(identical(other.messages, messages) || other.messages == messages)&&(identical(other.liveStarts, liveStarts) || other.liveStarts == liveStarts)&&(identical(other.gymUpdates, gymUpdates) || other.gymUpdates == gymUpdates)&&(identical(other.tips, tips) || other.tips == tips)&&(identical(other.marketing, marketing) || other.marketing == marketing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,likes,comments,follows,buddyRequests,messages,liveStarts,gymUpdates,tips,marketing);

@override
String toString() {
  return 'NotificationPreference(likes: $likes, comments: $comments, follows: $follows, buddyRequests: $buddyRequests, messages: $messages, liveStarts: $liveStarts, gymUpdates: $gymUpdates, tips: $tips, marketing: $marketing)';
}


}

/// @nodoc
abstract mixin class $NotificationPreferenceCopyWith<$Res>  {
  factory $NotificationPreferenceCopyWith(NotificationPreference value, $Res Function(NotificationPreference) _then) = _$NotificationPreferenceCopyWithImpl;
@useResult
$Res call({
 bool likes, bool comments, bool follows, bool buddyRequests, bool messages, bool liveStarts, bool gymUpdates, bool tips, bool marketing
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
@pragma('vm:prefer-inline') @override $Res call({Object? likes = null,Object? comments = null,Object? follows = null,Object? buddyRequests = null,Object? messages = null,Object? liveStarts = null,Object? gymUpdates = null,Object? tips = null,Object? marketing = null,}) {
  return _then(_self.copyWith(
likes: null == likes ? _self.likes : likes // ignore: cast_nullable_to_non_nullable
as bool,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as bool,follows: null == follows ? _self.follows : follows // ignore: cast_nullable_to_non_nullable
as bool,buddyRequests: null == buddyRequests ? _self.buddyRequests : buddyRequests // ignore: cast_nullable_to_non_nullable
as bool,messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as bool,liveStarts: null == liveStarts ? _self.liveStarts : liveStarts // ignore: cast_nullable_to_non_nullable
as bool,gymUpdates: null == gymUpdates ? _self.gymUpdates : gymUpdates // ignore: cast_nullable_to_non_nullable
as bool,tips: null == tips ? _self.tips : tips // ignore: cast_nullable_to_non_nullable
as bool,marketing: null == marketing ? _self.marketing : marketing // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool likes,  bool comments,  bool follows,  bool buddyRequests,  bool messages,  bool liveStarts,  bool gymUpdates,  bool tips,  bool marketing)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationPreference() when $default != null:
return $default(_that.likes,_that.comments,_that.follows,_that.buddyRequests,_that.messages,_that.liveStarts,_that.gymUpdates,_that.tips,_that.marketing);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool likes,  bool comments,  bool follows,  bool buddyRequests,  bool messages,  bool liveStarts,  bool gymUpdates,  bool tips,  bool marketing)  $default,) {final _that = this;
switch (_that) {
case _NotificationPreference():
return $default(_that.likes,_that.comments,_that.follows,_that.buddyRequests,_that.messages,_that.liveStarts,_that.gymUpdates,_that.tips,_that.marketing);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool likes,  bool comments,  bool follows,  bool buddyRequests,  bool messages,  bool liveStarts,  bool gymUpdates,  bool tips,  bool marketing)?  $default,) {final _that = this;
switch (_that) {
case _NotificationPreference() when $default != null:
return $default(_that.likes,_that.comments,_that.follows,_that.buddyRequests,_that.messages,_that.liveStarts,_that.gymUpdates,_that.tips,_that.marketing);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationPreference implements NotificationPreference {
  const _NotificationPreference({this.likes = true, this.comments = true, this.follows = true, this.buddyRequests = true, this.messages = true, this.liveStarts = true, this.gymUpdates = true, this.tips = true, this.marketing = true});
  factory _NotificationPreference.fromJson(Map<String, dynamic> json) => _$NotificationPreferenceFromJson(json);

@override@JsonKey() final  bool likes;
@override@JsonKey() final  bool comments;
@override@JsonKey() final  bool follows;
@override@JsonKey() final  bool buddyRequests;
@override@JsonKey() final  bool messages;
@override@JsonKey() final  bool liveStarts;
@override@JsonKey() final  bool gymUpdates;
@override@JsonKey() final  bool tips;
@override@JsonKey() final  bool marketing;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationPreference&&(identical(other.likes, likes) || other.likes == likes)&&(identical(other.comments, comments) || other.comments == comments)&&(identical(other.follows, follows) || other.follows == follows)&&(identical(other.buddyRequests, buddyRequests) || other.buddyRequests == buddyRequests)&&(identical(other.messages, messages) || other.messages == messages)&&(identical(other.liveStarts, liveStarts) || other.liveStarts == liveStarts)&&(identical(other.gymUpdates, gymUpdates) || other.gymUpdates == gymUpdates)&&(identical(other.tips, tips) || other.tips == tips)&&(identical(other.marketing, marketing) || other.marketing == marketing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,likes,comments,follows,buddyRequests,messages,liveStarts,gymUpdates,tips,marketing);

@override
String toString() {
  return 'NotificationPreference(likes: $likes, comments: $comments, follows: $follows, buddyRequests: $buddyRequests, messages: $messages, liveStarts: $liveStarts, gymUpdates: $gymUpdates, tips: $tips, marketing: $marketing)';
}


}

/// @nodoc
abstract mixin class _$NotificationPreferenceCopyWith<$Res> implements $NotificationPreferenceCopyWith<$Res> {
  factory _$NotificationPreferenceCopyWith(_NotificationPreference value, $Res Function(_NotificationPreference) _then) = __$NotificationPreferenceCopyWithImpl;
@override @useResult
$Res call({
 bool likes, bool comments, bool follows, bool buddyRequests, bool messages, bool liveStarts, bool gymUpdates, bool tips, bool marketing
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
@override @pragma('vm:prefer-inline') $Res call({Object? likes = null,Object? comments = null,Object? follows = null,Object? buddyRequests = null,Object? messages = null,Object? liveStarts = null,Object? gymUpdates = null,Object? tips = null,Object? marketing = null,}) {
  return _then(_NotificationPreference(
likes: null == likes ? _self.likes : likes // ignore: cast_nullable_to_non_nullable
as bool,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as bool,follows: null == follows ? _self.follows : follows // ignore: cast_nullable_to_non_nullable
as bool,buddyRequests: null == buddyRequests ? _self.buddyRequests : buddyRequests // ignore: cast_nullable_to_non_nullable
as bool,messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as bool,liveStarts: null == liveStarts ? _self.liveStarts : liveStarts // ignore: cast_nullable_to_non_nullable
as bool,gymUpdates: null == gymUpdates ? _self.gymUpdates : gymUpdates // ignore: cast_nullable_to_non_nullable
as bool,tips: null == tips ? _self.tips : tips // ignore: cast_nullable_to_non_nullable
as bool,marketing: null == marketing ? _self.marketing : marketing // ignore: cast_nullable_to_non_nullable
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
