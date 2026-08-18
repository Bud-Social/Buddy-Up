// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'messaging.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ParticipantData {

 String get userId; String get username; String get displayName; String get avatarUrl; String get verificationStatus; String get role;
/// Create a copy of ParticipantData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParticipantDataCopyWith<ParticipantData> get copyWith => _$ParticipantDataCopyWithImpl<ParticipantData>(this as ParticipantData, _$identity);

  /// Serializes this ParticipantData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParticipantData&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username,displayName,avatarUrl,verificationStatus,role);

@override
String toString() {
  return 'ParticipantData(userId: $userId, username: $username, displayName: $displayName, avatarUrl: $avatarUrl, verificationStatus: $verificationStatus, role: $role)';
}


}

/// @nodoc
abstract mixin class $ParticipantDataCopyWith<$Res>  {
  factory $ParticipantDataCopyWith(ParticipantData value, $Res Function(ParticipantData) _then) = _$ParticipantDataCopyWithImpl;
@useResult
$Res call({
 String userId, String username, String displayName, String avatarUrl, String verificationStatus, String role
});




}
/// @nodoc
class _$ParticipantDataCopyWithImpl<$Res>
    implements $ParticipantDataCopyWith<$Res> {
  _$ParticipantDataCopyWithImpl(this._self, this._then);

  final ParticipantData _self;
  final $Res Function(ParticipantData) _then;

/// Create a copy of ParticipantData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? username = null,Object? displayName = null,Object? avatarUrl = null,Object? verificationStatus = null,Object? role = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ParticipantData].
extension ParticipantDataPatterns on ParticipantData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ParticipantData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ParticipantData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ParticipantData value)  $default,){
final _that = this;
switch (_that) {
case _ParticipantData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ParticipantData value)?  $default,){
final _that = this;
switch (_that) {
case _ParticipantData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String username,  String displayName,  String avatarUrl,  String verificationStatus,  String role)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParticipantData() when $default != null:
return $default(_that.userId,_that.username,_that.displayName,_that.avatarUrl,_that.verificationStatus,_that.role);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String username,  String displayName,  String avatarUrl,  String verificationStatus,  String role)  $default,) {final _that = this;
switch (_that) {
case _ParticipantData():
return $default(_that.userId,_that.username,_that.displayName,_that.avatarUrl,_that.verificationStatus,_that.role);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String username,  String displayName,  String avatarUrl,  String verificationStatus,  String role)?  $default,) {final _that = this;
switch (_that) {
case _ParticipantData() when $default != null:
return $default(_that.userId,_that.username,_that.displayName,_that.avatarUrl,_that.verificationStatus,_that.role);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ParticipantData implements ParticipantData {
  const _ParticipantData({required this.userId, required this.username, required this.displayName, required this.avatarUrl, this.verificationStatus = 'none', this.role = ''});
  factory _ParticipantData.fromJson(Map<String, dynamic> json) => _$ParticipantDataFromJson(json);

@override final  String userId;
@override final  String username;
@override final  String displayName;
@override final  String avatarUrl;
@override@JsonKey() final  String verificationStatus;
@override@JsonKey() final  String role;

/// Create a copy of ParticipantData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParticipantDataCopyWith<_ParticipantData> get copyWith => __$ParticipantDataCopyWithImpl<_ParticipantData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ParticipantDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParticipantData&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username,displayName,avatarUrl,verificationStatus,role);

@override
String toString() {
  return 'ParticipantData(userId: $userId, username: $username, displayName: $displayName, avatarUrl: $avatarUrl, verificationStatus: $verificationStatus, role: $role)';
}


}

/// @nodoc
abstract mixin class _$ParticipantDataCopyWith<$Res> implements $ParticipantDataCopyWith<$Res> {
  factory _$ParticipantDataCopyWith(_ParticipantData value, $Res Function(_ParticipantData) _then) = __$ParticipantDataCopyWithImpl;
@override @useResult
$Res call({
 String userId, String username, String displayName, String avatarUrl, String verificationStatus, String role
});




}
/// @nodoc
class __$ParticipantDataCopyWithImpl<$Res>
    implements _$ParticipantDataCopyWith<$Res> {
  __$ParticipantDataCopyWithImpl(this._self, this._then);

  final _ParticipantData _self;
  final $Res Function(_ParticipantData) _then;

/// Create a copy of ParticipantData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? username = null,Object? displayName = null,Object? avatarUrl = null,Object? verificationStatus = null,Object? role = null,}) {
  return _then(_ParticipantData(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$LastMessageData {

 String get body; String get messageType; String get mediaUrl; String get senderName;
/// Create a copy of LastMessageData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LastMessageDataCopyWith<LastMessageData> get copyWith => _$LastMessageDataCopyWithImpl<LastMessageData>(this as LastMessageData, _$identity);

  /// Serializes this LastMessageData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LastMessageData&&(identical(other.body, body) || other.body == body)&&(identical(other.messageType, messageType) || other.messageType == messageType)&&(identical(other.mediaUrl, mediaUrl) || other.mediaUrl == mediaUrl)&&(identical(other.senderName, senderName) || other.senderName == senderName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,body,messageType,mediaUrl,senderName);

@override
String toString() {
  return 'LastMessageData(body: $body, messageType: $messageType, mediaUrl: $mediaUrl, senderName: $senderName)';
}


}

/// @nodoc
abstract mixin class $LastMessageDataCopyWith<$Res>  {
  factory $LastMessageDataCopyWith(LastMessageData value, $Res Function(LastMessageData) _then) = _$LastMessageDataCopyWithImpl;
@useResult
$Res call({
 String body, String messageType, String mediaUrl, String senderName
});




}
/// @nodoc
class _$LastMessageDataCopyWithImpl<$Res>
    implements $LastMessageDataCopyWith<$Res> {
  _$LastMessageDataCopyWithImpl(this._self, this._then);

  final LastMessageData _self;
  final $Res Function(LastMessageData) _then;

/// Create a copy of LastMessageData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? body = null,Object? messageType = null,Object? mediaUrl = null,Object? senderName = null,}) {
  return _then(_self.copyWith(
body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,messageType: null == messageType ? _self.messageType : messageType // ignore: cast_nullable_to_non_nullable
as String,mediaUrl: null == mediaUrl ? _self.mediaUrl : mediaUrl // ignore: cast_nullable_to_non_nullable
as String,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LastMessageData].
extension LastMessageDataPatterns on LastMessageData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LastMessageData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LastMessageData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LastMessageData value)  $default,){
final _that = this;
switch (_that) {
case _LastMessageData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LastMessageData value)?  $default,){
final _that = this;
switch (_that) {
case _LastMessageData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String body,  String messageType,  String mediaUrl,  String senderName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LastMessageData() when $default != null:
return $default(_that.body,_that.messageType,_that.mediaUrl,_that.senderName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String body,  String messageType,  String mediaUrl,  String senderName)  $default,) {final _that = this;
switch (_that) {
case _LastMessageData():
return $default(_that.body,_that.messageType,_that.mediaUrl,_that.senderName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String body,  String messageType,  String mediaUrl,  String senderName)?  $default,) {final _that = this;
switch (_that) {
case _LastMessageData() when $default != null:
return $default(_that.body,_that.messageType,_that.mediaUrl,_that.senderName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LastMessageData implements LastMessageData {
  const _LastMessageData({this.body = '', this.messageType = 'text', this.mediaUrl = '', this.senderName = ''});
  factory _LastMessageData.fromJson(Map<String, dynamic> json) => _$LastMessageDataFromJson(json);

@override@JsonKey() final  String body;
@override@JsonKey() final  String messageType;
@override@JsonKey() final  String mediaUrl;
@override@JsonKey() final  String senderName;

/// Create a copy of LastMessageData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LastMessageDataCopyWith<_LastMessageData> get copyWith => __$LastMessageDataCopyWithImpl<_LastMessageData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LastMessageDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LastMessageData&&(identical(other.body, body) || other.body == body)&&(identical(other.messageType, messageType) || other.messageType == messageType)&&(identical(other.mediaUrl, mediaUrl) || other.mediaUrl == mediaUrl)&&(identical(other.senderName, senderName) || other.senderName == senderName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,body,messageType,mediaUrl,senderName);

@override
String toString() {
  return 'LastMessageData(body: $body, messageType: $messageType, mediaUrl: $mediaUrl, senderName: $senderName)';
}


}

/// @nodoc
abstract mixin class _$LastMessageDataCopyWith<$Res> implements $LastMessageDataCopyWith<$Res> {
  factory _$LastMessageDataCopyWith(_LastMessageData value, $Res Function(_LastMessageData) _then) = __$LastMessageDataCopyWithImpl;
@override @useResult
$Res call({
 String body, String messageType, String mediaUrl, String senderName
});




}
/// @nodoc
class __$LastMessageDataCopyWithImpl<$Res>
    implements _$LastMessageDataCopyWith<$Res> {
  __$LastMessageDataCopyWithImpl(this._self, this._then);

  final _LastMessageData _self;
  final $Res Function(_LastMessageData) _then;

/// Create a copy of LastMessageData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? body = null,Object? messageType = null,Object? mediaUrl = null,Object? senderName = null,}) {
  return _then(_LastMessageData(
body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,messageType: null == messageType ? _self.messageType : messageType // ignore: cast_nullable_to_non_nullable
as String,mediaUrl: null == mediaUrl ? _self.mediaUrl : mediaUrl // ignore: cast_nullable_to_non_nullable
as String,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Conversation {

 String get id; bool get isGroup; bool get isCommunity; String get groupName; String get groupAvatarUrl; String? get groupGymId; String get subChannel; bool get callInProgress; String get description; String get coverUrl; String get inviteCode; bool get isPublic; List<ParticipantData> get participantsData; int get unreadCount; String? get membershipRole; LastMessageData? get lastMessage; String? get lastMessageAt; String get createdAt;
/// Create a copy of Conversation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConversationCopyWith<Conversation> get copyWith => _$ConversationCopyWithImpl<Conversation>(this as Conversation, _$identity);

  /// Serializes this Conversation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Conversation&&(identical(other.id, id) || other.id == id)&&(identical(other.isGroup, isGroup) || other.isGroup == isGroup)&&(identical(other.isCommunity, isCommunity) || other.isCommunity == isCommunity)&&(identical(other.groupName, groupName) || other.groupName == groupName)&&(identical(other.groupAvatarUrl, groupAvatarUrl) || other.groupAvatarUrl == groupAvatarUrl)&&(identical(other.groupGymId, groupGymId) || other.groupGymId == groupGymId)&&(identical(other.subChannel, subChannel) || other.subChannel == subChannel)&&(identical(other.callInProgress, callInProgress) || other.callInProgress == callInProgress)&&(identical(other.description, description) || other.description == description)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&const DeepCollectionEquality().equals(other.participantsData, participantsData)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.membershipRole, membershipRole) || other.membershipRole == membershipRole)&&(identical(other.lastMessage, lastMessage) || other.lastMessage == lastMessage)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,isGroup,isCommunity,groupName,groupAvatarUrl,groupGymId,subChannel,callInProgress,description,coverUrl,inviteCode,isPublic,const DeepCollectionEquality().hash(participantsData),unreadCount,membershipRole,lastMessage,lastMessageAt,createdAt);

@override
String toString() {
  return 'Conversation(id: $id, isGroup: $isGroup, isCommunity: $isCommunity, groupName: $groupName, groupAvatarUrl: $groupAvatarUrl, groupGymId: $groupGymId, subChannel: $subChannel, callInProgress: $callInProgress, description: $description, coverUrl: $coverUrl, inviteCode: $inviteCode, isPublic: $isPublic, participantsData: $participantsData, unreadCount: $unreadCount, membershipRole: $membershipRole, lastMessage: $lastMessage, lastMessageAt: $lastMessageAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ConversationCopyWith<$Res>  {
  factory $ConversationCopyWith(Conversation value, $Res Function(Conversation) _then) = _$ConversationCopyWithImpl;
@useResult
$Res call({
 String id, bool isGroup, bool isCommunity, String groupName, String groupAvatarUrl, String? groupGymId, String subChannel, bool callInProgress, String description, String coverUrl, String inviteCode, bool isPublic, List<ParticipantData> participantsData, int unreadCount, String? membershipRole, LastMessageData? lastMessage, String? lastMessageAt, String createdAt
});


$LastMessageDataCopyWith<$Res>? get lastMessage;

}
/// @nodoc
class _$ConversationCopyWithImpl<$Res>
    implements $ConversationCopyWith<$Res> {
  _$ConversationCopyWithImpl(this._self, this._then);

  final Conversation _self;
  final $Res Function(Conversation) _then;

/// Create a copy of Conversation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? isGroup = null,Object? isCommunity = null,Object? groupName = null,Object? groupAvatarUrl = null,Object? groupGymId = freezed,Object? subChannel = null,Object? callInProgress = null,Object? description = null,Object? coverUrl = null,Object? inviteCode = null,Object? isPublic = null,Object? participantsData = null,Object? unreadCount = null,Object? membershipRole = freezed,Object? lastMessage = freezed,Object? lastMessageAt = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,isGroup: null == isGroup ? _self.isGroup : isGroup // ignore: cast_nullable_to_non_nullable
as bool,isCommunity: null == isCommunity ? _self.isCommunity : isCommunity // ignore: cast_nullable_to_non_nullable
as bool,groupName: null == groupName ? _self.groupName : groupName // ignore: cast_nullable_to_non_nullable
as String,groupAvatarUrl: null == groupAvatarUrl ? _self.groupAvatarUrl : groupAvatarUrl // ignore: cast_nullable_to_non_nullable
as String,groupGymId: freezed == groupGymId ? _self.groupGymId : groupGymId // ignore: cast_nullable_to_non_nullable
as String?,subChannel: null == subChannel ? _self.subChannel : subChannel // ignore: cast_nullable_to_non_nullable
as String,callInProgress: null == callInProgress ? _self.callInProgress : callInProgress // ignore: cast_nullable_to_non_nullable
as bool,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,inviteCode: null == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,participantsData: null == participantsData ? _self.participantsData : participantsData // ignore: cast_nullable_to_non_nullable
as List<ParticipantData>,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,membershipRole: freezed == membershipRole ? _self.membershipRole : membershipRole // ignore: cast_nullable_to_non_nullable
as String?,lastMessage: freezed == lastMessage ? _self.lastMessage : lastMessage // ignore: cast_nullable_to_non_nullable
as LastMessageData?,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of Conversation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LastMessageDataCopyWith<$Res>? get lastMessage {
    if (_self.lastMessage == null) {
    return null;
  }

  return $LastMessageDataCopyWith<$Res>(_self.lastMessage!, (value) {
    return _then(_self.copyWith(lastMessage: value));
  });
}
}


/// Adds pattern-matching-related methods to [Conversation].
extension ConversationPatterns on Conversation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Conversation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Conversation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Conversation value)  $default,){
final _that = this;
switch (_that) {
case _Conversation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Conversation value)?  $default,){
final _that = this;
switch (_that) {
case _Conversation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  bool isGroup,  bool isCommunity,  String groupName,  String groupAvatarUrl,  String? groupGymId,  String subChannel,  bool callInProgress,  String description,  String coverUrl,  String inviteCode,  bool isPublic,  List<ParticipantData> participantsData,  int unreadCount,  String? membershipRole,  LastMessageData? lastMessage,  String? lastMessageAt,  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Conversation() when $default != null:
return $default(_that.id,_that.isGroup,_that.isCommunity,_that.groupName,_that.groupAvatarUrl,_that.groupGymId,_that.subChannel,_that.callInProgress,_that.description,_that.coverUrl,_that.inviteCode,_that.isPublic,_that.participantsData,_that.unreadCount,_that.membershipRole,_that.lastMessage,_that.lastMessageAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  bool isGroup,  bool isCommunity,  String groupName,  String groupAvatarUrl,  String? groupGymId,  String subChannel,  bool callInProgress,  String description,  String coverUrl,  String inviteCode,  bool isPublic,  List<ParticipantData> participantsData,  int unreadCount,  String? membershipRole,  LastMessageData? lastMessage,  String? lastMessageAt,  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _Conversation():
return $default(_that.id,_that.isGroup,_that.isCommunity,_that.groupName,_that.groupAvatarUrl,_that.groupGymId,_that.subChannel,_that.callInProgress,_that.description,_that.coverUrl,_that.inviteCode,_that.isPublic,_that.participantsData,_that.unreadCount,_that.membershipRole,_that.lastMessage,_that.lastMessageAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  bool isGroup,  bool isCommunity,  String groupName,  String groupAvatarUrl,  String? groupGymId,  String subChannel,  bool callInProgress,  String description,  String coverUrl,  String inviteCode,  bool isPublic,  List<ParticipantData> participantsData,  int unreadCount,  String? membershipRole,  LastMessageData? lastMessage,  String? lastMessageAt,  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Conversation() when $default != null:
return $default(_that.id,_that.isGroup,_that.isCommunity,_that.groupName,_that.groupAvatarUrl,_that.groupGymId,_that.subChannel,_that.callInProgress,_that.description,_that.coverUrl,_that.inviteCode,_that.isPublic,_that.participantsData,_that.unreadCount,_that.membershipRole,_that.lastMessage,_that.lastMessageAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Conversation implements Conversation {
  const _Conversation({required this.id, this.isGroup = false, this.isCommunity = false, this.groupName = '', this.groupAvatarUrl = '', this.groupGymId, this.subChannel = '', this.callInProgress = false, this.description = '', this.coverUrl = '', this.inviteCode = '', this.isPublic = false, final  List<ParticipantData> participantsData = const <ParticipantData>[], this.unreadCount = 0, this.membershipRole, this.lastMessage, this.lastMessageAt, required this.createdAt}): _participantsData = participantsData;
  factory _Conversation.fromJson(Map<String, dynamic> json) => _$ConversationFromJson(json);

@override final  String id;
@override@JsonKey() final  bool isGroup;
@override@JsonKey() final  bool isCommunity;
@override@JsonKey() final  String groupName;
@override@JsonKey() final  String groupAvatarUrl;
@override final  String? groupGymId;
@override@JsonKey() final  String subChannel;
@override@JsonKey() final  bool callInProgress;
@override@JsonKey() final  String description;
@override@JsonKey() final  String coverUrl;
@override@JsonKey() final  String inviteCode;
@override@JsonKey() final  bool isPublic;
 final  List<ParticipantData> _participantsData;
@override@JsonKey() List<ParticipantData> get participantsData {
  if (_participantsData is EqualUnmodifiableListView) return _participantsData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participantsData);
}

@override@JsonKey() final  int unreadCount;
@override final  String? membershipRole;
@override final  LastMessageData? lastMessage;
@override final  String? lastMessageAt;
@override final  String createdAt;

/// Create a copy of Conversation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConversationCopyWith<_Conversation> get copyWith => __$ConversationCopyWithImpl<_Conversation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConversationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Conversation&&(identical(other.id, id) || other.id == id)&&(identical(other.isGroup, isGroup) || other.isGroup == isGroup)&&(identical(other.isCommunity, isCommunity) || other.isCommunity == isCommunity)&&(identical(other.groupName, groupName) || other.groupName == groupName)&&(identical(other.groupAvatarUrl, groupAvatarUrl) || other.groupAvatarUrl == groupAvatarUrl)&&(identical(other.groupGymId, groupGymId) || other.groupGymId == groupGymId)&&(identical(other.subChannel, subChannel) || other.subChannel == subChannel)&&(identical(other.callInProgress, callInProgress) || other.callInProgress == callInProgress)&&(identical(other.description, description) || other.description == description)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&const DeepCollectionEquality().equals(other._participantsData, _participantsData)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.membershipRole, membershipRole) || other.membershipRole == membershipRole)&&(identical(other.lastMessage, lastMessage) || other.lastMessage == lastMessage)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,isGroup,isCommunity,groupName,groupAvatarUrl,groupGymId,subChannel,callInProgress,description,coverUrl,inviteCode,isPublic,const DeepCollectionEquality().hash(_participantsData),unreadCount,membershipRole,lastMessage,lastMessageAt,createdAt);

@override
String toString() {
  return 'Conversation(id: $id, isGroup: $isGroup, isCommunity: $isCommunity, groupName: $groupName, groupAvatarUrl: $groupAvatarUrl, groupGymId: $groupGymId, subChannel: $subChannel, callInProgress: $callInProgress, description: $description, coverUrl: $coverUrl, inviteCode: $inviteCode, isPublic: $isPublic, participantsData: $participantsData, unreadCount: $unreadCount, membershipRole: $membershipRole, lastMessage: $lastMessage, lastMessageAt: $lastMessageAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ConversationCopyWith<$Res> implements $ConversationCopyWith<$Res> {
  factory _$ConversationCopyWith(_Conversation value, $Res Function(_Conversation) _then) = __$ConversationCopyWithImpl;
@override @useResult
$Res call({
 String id, bool isGroup, bool isCommunity, String groupName, String groupAvatarUrl, String? groupGymId, String subChannel, bool callInProgress, String description, String coverUrl, String inviteCode, bool isPublic, List<ParticipantData> participantsData, int unreadCount, String? membershipRole, LastMessageData? lastMessage, String? lastMessageAt, String createdAt
});


@override $LastMessageDataCopyWith<$Res>? get lastMessage;

}
/// @nodoc
class __$ConversationCopyWithImpl<$Res>
    implements _$ConversationCopyWith<$Res> {
  __$ConversationCopyWithImpl(this._self, this._then);

  final _Conversation _self;
  final $Res Function(_Conversation) _then;

/// Create a copy of Conversation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? isGroup = null,Object? isCommunity = null,Object? groupName = null,Object? groupAvatarUrl = null,Object? groupGymId = freezed,Object? subChannel = null,Object? callInProgress = null,Object? description = null,Object? coverUrl = null,Object? inviteCode = null,Object? isPublic = null,Object? participantsData = null,Object? unreadCount = null,Object? membershipRole = freezed,Object? lastMessage = freezed,Object? lastMessageAt = freezed,Object? createdAt = null,}) {
  return _then(_Conversation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,isGroup: null == isGroup ? _self.isGroup : isGroup // ignore: cast_nullable_to_non_nullable
as bool,isCommunity: null == isCommunity ? _self.isCommunity : isCommunity // ignore: cast_nullable_to_non_nullable
as bool,groupName: null == groupName ? _self.groupName : groupName // ignore: cast_nullable_to_non_nullable
as String,groupAvatarUrl: null == groupAvatarUrl ? _self.groupAvatarUrl : groupAvatarUrl // ignore: cast_nullable_to_non_nullable
as String,groupGymId: freezed == groupGymId ? _self.groupGymId : groupGymId // ignore: cast_nullable_to_non_nullable
as String?,subChannel: null == subChannel ? _self.subChannel : subChannel // ignore: cast_nullable_to_non_nullable
as String,callInProgress: null == callInProgress ? _self.callInProgress : callInProgress // ignore: cast_nullable_to_non_nullable
as bool,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,inviteCode: null == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,participantsData: null == participantsData ? _self._participantsData : participantsData // ignore: cast_nullable_to_non_nullable
as List<ParticipantData>,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,membershipRole: freezed == membershipRole ? _self.membershipRole : membershipRole // ignore: cast_nullable_to_non_nullable
as String?,lastMessage: freezed == lastMessage ? _self.lastMessage : lastMessage // ignore: cast_nullable_to_non_nullable
as LastMessageData?,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of Conversation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LastMessageDataCopyWith<$Res>? get lastMessage {
    if (_self.lastMessage == null) {
    return null;
  }

  return $LastMessageDataCopyWith<$Res>(_self.lastMessage!, (value) {
    return _then(_self.copyWith(lastMessage: value));
  });
}
}


/// @nodoc
mixin _$CommunityMember {

 String get userId; String get username; String get displayName; String get avatarUrl; String get verificationStatus; String get role; String get createdAt;
/// Create a copy of CommunityMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommunityMemberCopyWith<CommunityMember> get copyWith => _$CommunityMemberCopyWithImpl<CommunityMember>(this as CommunityMember, _$identity);

  /// Serializes this CommunityMember to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommunityMember&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.role, role) || other.role == role)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username,displayName,avatarUrl,verificationStatus,role,createdAt);

@override
String toString() {
  return 'CommunityMember(userId: $userId, username: $username, displayName: $displayName, avatarUrl: $avatarUrl, verificationStatus: $verificationStatus, role: $role, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $CommunityMemberCopyWith<$Res>  {
  factory $CommunityMemberCopyWith(CommunityMember value, $Res Function(CommunityMember) _then) = _$CommunityMemberCopyWithImpl;
@useResult
$Res call({
 String userId, String username, String displayName, String avatarUrl, String verificationStatus, String role, String createdAt
});




}
/// @nodoc
class _$CommunityMemberCopyWithImpl<$Res>
    implements $CommunityMemberCopyWith<$Res> {
  _$CommunityMemberCopyWithImpl(this._self, this._then);

  final CommunityMember _self;
  final $Res Function(CommunityMember) _then;

/// Create a copy of CommunityMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? username = null,Object? displayName = null,Object? avatarUrl = null,Object? verificationStatus = null,Object? role = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CommunityMember].
extension CommunityMemberPatterns on CommunityMember {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommunityMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommunityMember() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommunityMember value)  $default,){
final _that = this;
switch (_that) {
case _CommunityMember():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommunityMember value)?  $default,){
final _that = this;
switch (_that) {
case _CommunityMember() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String username,  String displayName,  String avatarUrl,  String verificationStatus,  String role,  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommunityMember() when $default != null:
return $default(_that.userId,_that.username,_that.displayName,_that.avatarUrl,_that.verificationStatus,_that.role,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String username,  String displayName,  String avatarUrl,  String verificationStatus,  String role,  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _CommunityMember():
return $default(_that.userId,_that.username,_that.displayName,_that.avatarUrl,_that.verificationStatus,_that.role,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String username,  String displayName,  String avatarUrl,  String verificationStatus,  String role,  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _CommunityMember() when $default != null:
return $default(_that.userId,_that.username,_that.displayName,_that.avatarUrl,_that.verificationStatus,_that.role,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CommunityMember implements CommunityMember {
  const _CommunityMember({required this.userId, required this.username, required this.displayName, this.avatarUrl = '', this.verificationStatus = 'none', this.role = 'member', required this.createdAt});
  factory _CommunityMember.fromJson(Map<String, dynamic> json) => _$CommunityMemberFromJson(json);

@override final  String userId;
@override final  String username;
@override final  String displayName;
@override@JsonKey() final  String avatarUrl;
@override@JsonKey() final  String verificationStatus;
@override@JsonKey() final  String role;
@override final  String createdAt;

/// Create a copy of CommunityMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommunityMemberCopyWith<_CommunityMember> get copyWith => __$CommunityMemberCopyWithImpl<_CommunityMember>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CommunityMemberToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommunityMember&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.role, role) || other.role == role)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username,displayName,avatarUrl,verificationStatus,role,createdAt);

@override
String toString() {
  return 'CommunityMember(userId: $userId, username: $username, displayName: $displayName, avatarUrl: $avatarUrl, verificationStatus: $verificationStatus, role: $role, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$CommunityMemberCopyWith<$Res> implements $CommunityMemberCopyWith<$Res> {
  factory _$CommunityMemberCopyWith(_CommunityMember value, $Res Function(_CommunityMember) _then) = __$CommunityMemberCopyWithImpl;
@override @useResult
$Res call({
 String userId, String username, String displayName, String avatarUrl, String verificationStatus, String role, String createdAt
});




}
/// @nodoc
class __$CommunityMemberCopyWithImpl<$Res>
    implements _$CommunityMemberCopyWith<$Res> {
  __$CommunityMemberCopyWithImpl(this._self, this._then);

  final _CommunityMember _self;
  final $Res Function(_CommunityMember) _then;

/// Create a copy of CommunityMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? username = null,Object? displayName = null,Object? avatarUrl = null,Object? verificationStatus = null,Object? role = null,Object? createdAt = null,}) {
  return _then(_CommunityMember(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CommunityPostComment {

 String get id; String get postId; String get body; String? get replyToId; int get replyCount; ProfileBrief get authorData; String get createdAt;
/// Create a copy of CommunityPostComment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommunityPostCommentCopyWith<CommunityPostComment> get copyWith => _$CommunityPostCommentCopyWithImpl<CommunityPostComment>(this as CommunityPostComment, _$identity);

  /// Serializes this CommunityPostComment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommunityPostComment&&(identical(other.id, id) || other.id == id)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.body, body) || other.body == body)&&(identical(other.replyToId, replyToId) || other.replyToId == replyToId)&&(identical(other.replyCount, replyCount) || other.replyCount == replyCount)&&(identical(other.authorData, authorData) || other.authorData == authorData)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,postId,body,replyToId,replyCount,authorData,createdAt);

@override
String toString() {
  return 'CommunityPostComment(id: $id, postId: $postId, body: $body, replyToId: $replyToId, replyCount: $replyCount, authorData: $authorData, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $CommunityPostCommentCopyWith<$Res>  {
  factory $CommunityPostCommentCopyWith(CommunityPostComment value, $Res Function(CommunityPostComment) _then) = _$CommunityPostCommentCopyWithImpl;
@useResult
$Res call({
 String id, String postId, String body, String? replyToId, int replyCount, ProfileBrief authorData, String createdAt
});


$ProfileBriefCopyWith<$Res> get authorData;

}
/// @nodoc
class _$CommunityPostCommentCopyWithImpl<$Res>
    implements $CommunityPostCommentCopyWith<$Res> {
  _$CommunityPostCommentCopyWithImpl(this._self, this._then);

  final CommunityPostComment _self;
  final $Res Function(CommunityPostComment) _then;

/// Create a copy of CommunityPostComment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? postId = null,Object? body = null,Object? replyToId = freezed,Object? replyCount = null,Object? authorData = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,replyToId: freezed == replyToId ? _self.replyToId : replyToId // ignore: cast_nullable_to_non_nullable
as String?,replyCount: null == replyCount ? _self.replyCount : replyCount // ignore: cast_nullable_to_non_nullable
as int,authorData: null == authorData ? _self.authorData : authorData // ignore: cast_nullable_to_non_nullable
as ProfileBrief,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of CommunityPostComment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileBriefCopyWith<$Res> get authorData {
  
  return $ProfileBriefCopyWith<$Res>(_self.authorData, (value) {
    return _then(_self.copyWith(authorData: value));
  });
}
}


/// Adds pattern-matching-related methods to [CommunityPostComment].
extension CommunityPostCommentPatterns on CommunityPostComment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommunityPostComment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommunityPostComment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommunityPostComment value)  $default,){
final _that = this;
switch (_that) {
case _CommunityPostComment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommunityPostComment value)?  $default,){
final _that = this;
switch (_that) {
case _CommunityPostComment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String postId,  String body,  String? replyToId,  int replyCount,  ProfileBrief authorData,  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommunityPostComment() when $default != null:
return $default(_that.id,_that.postId,_that.body,_that.replyToId,_that.replyCount,_that.authorData,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String postId,  String body,  String? replyToId,  int replyCount,  ProfileBrief authorData,  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _CommunityPostComment():
return $default(_that.id,_that.postId,_that.body,_that.replyToId,_that.replyCount,_that.authorData,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String postId,  String body,  String? replyToId,  int replyCount,  ProfileBrief authorData,  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _CommunityPostComment() when $default != null:
return $default(_that.id,_that.postId,_that.body,_that.replyToId,_that.replyCount,_that.authorData,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CommunityPostComment implements CommunityPostComment {
  const _CommunityPostComment({required this.id, required this.postId, required this.body, this.replyToId, this.replyCount = 0, required this.authorData, required this.createdAt});
  factory _CommunityPostComment.fromJson(Map<String, dynamic> json) => _$CommunityPostCommentFromJson(json);

@override final  String id;
@override final  String postId;
@override final  String body;
@override final  String? replyToId;
@override@JsonKey() final  int replyCount;
@override final  ProfileBrief authorData;
@override final  String createdAt;

/// Create a copy of CommunityPostComment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommunityPostCommentCopyWith<_CommunityPostComment> get copyWith => __$CommunityPostCommentCopyWithImpl<_CommunityPostComment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CommunityPostCommentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommunityPostComment&&(identical(other.id, id) || other.id == id)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.body, body) || other.body == body)&&(identical(other.replyToId, replyToId) || other.replyToId == replyToId)&&(identical(other.replyCount, replyCount) || other.replyCount == replyCount)&&(identical(other.authorData, authorData) || other.authorData == authorData)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,postId,body,replyToId,replyCount,authorData,createdAt);

@override
String toString() {
  return 'CommunityPostComment(id: $id, postId: $postId, body: $body, replyToId: $replyToId, replyCount: $replyCount, authorData: $authorData, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$CommunityPostCommentCopyWith<$Res> implements $CommunityPostCommentCopyWith<$Res> {
  factory _$CommunityPostCommentCopyWith(_CommunityPostComment value, $Res Function(_CommunityPostComment) _then) = __$CommunityPostCommentCopyWithImpl;
@override @useResult
$Res call({
 String id, String postId, String body, String? replyToId, int replyCount, ProfileBrief authorData, String createdAt
});


@override $ProfileBriefCopyWith<$Res> get authorData;

}
/// @nodoc
class __$CommunityPostCommentCopyWithImpl<$Res>
    implements _$CommunityPostCommentCopyWith<$Res> {
  __$CommunityPostCommentCopyWithImpl(this._self, this._then);

  final _CommunityPostComment _self;
  final $Res Function(_CommunityPostComment) _then;

/// Create a copy of CommunityPostComment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? postId = null,Object? body = null,Object? replyToId = freezed,Object? replyCount = null,Object? authorData = null,Object? createdAt = null,}) {
  return _then(_CommunityPostComment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,replyToId: freezed == replyToId ? _self.replyToId : replyToId // ignore: cast_nullable_to_non_nullable
as String?,replyCount: null == replyCount ? _self.replyCount : replyCount // ignore: cast_nullable_to_non_nullable
as int,authorData: null == authorData ? _self.authorData : authorData // ignore: cast_nullable_to_non_nullable
as ProfileBrief,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of CommunityPostComment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileBriefCopyWith<$Res> get authorData {
  
  return $ProfileBriefCopyWith<$Res>(_self.authorData, (value) {
    return _then(_self.copyWith(authorData: value));
  });
}
}


/// @nodoc
mixin _$ProfileBrief {

 String get userId; String get username; String get displayName; String get avatarUrl; String get role;
/// Create a copy of ProfileBrief
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileBriefCopyWith<ProfileBrief> get copyWith => _$ProfileBriefCopyWithImpl<ProfileBrief>(this as ProfileBrief, _$identity);

  /// Serializes this ProfileBrief to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileBrief&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username,displayName,avatarUrl,role);

@override
String toString() {
  return 'ProfileBrief(userId: $userId, username: $username, displayName: $displayName, avatarUrl: $avatarUrl, role: $role)';
}


}

/// @nodoc
abstract mixin class $ProfileBriefCopyWith<$Res>  {
  factory $ProfileBriefCopyWith(ProfileBrief value, $Res Function(ProfileBrief) _then) = _$ProfileBriefCopyWithImpl;
@useResult
$Res call({
 String userId, String username, String displayName, String avatarUrl, String role
});




}
/// @nodoc
class _$ProfileBriefCopyWithImpl<$Res>
    implements $ProfileBriefCopyWith<$Res> {
  _$ProfileBriefCopyWithImpl(this._self, this._then);

  final ProfileBrief _self;
  final $Res Function(ProfileBrief) _then;

/// Create a copy of ProfileBrief
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? username = null,Object? displayName = null,Object? avatarUrl = null,Object? role = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileBrief].
extension ProfileBriefPatterns on ProfileBrief {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileBrief value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileBrief() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileBrief value)  $default,){
final _that = this;
switch (_that) {
case _ProfileBrief():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileBrief value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileBrief() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String username,  String displayName,  String avatarUrl,  String role)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileBrief() when $default != null:
return $default(_that.userId,_that.username,_that.displayName,_that.avatarUrl,_that.role);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String username,  String displayName,  String avatarUrl,  String role)  $default,) {final _that = this;
switch (_that) {
case _ProfileBrief():
return $default(_that.userId,_that.username,_that.displayName,_that.avatarUrl,_that.role);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String username,  String displayName,  String avatarUrl,  String role)?  $default,) {final _that = this;
switch (_that) {
case _ProfileBrief() when $default != null:
return $default(_that.userId,_that.username,_that.displayName,_that.avatarUrl,_that.role);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProfileBrief implements ProfileBrief {
  const _ProfileBrief({required this.userId, required this.username, required this.displayName, this.avatarUrl = '', this.role = ''});
  factory _ProfileBrief.fromJson(Map<String, dynamic> json) => _$ProfileBriefFromJson(json);

@override final  String userId;
@override final  String username;
@override final  String displayName;
@override@JsonKey() final  String avatarUrl;
@override@JsonKey() final  String role;

/// Create a copy of ProfileBrief
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileBriefCopyWith<_ProfileBrief> get copyWith => __$ProfileBriefCopyWithImpl<_ProfileBrief>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileBriefToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileBrief&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username,displayName,avatarUrl,role);

@override
String toString() {
  return 'ProfileBrief(userId: $userId, username: $username, displayName: $displayName, avatarUrl: $avatarUrl, role: $role)';
}


}

/// @nodoc
abstract mixin class _$ProfileBriefCopyWith<$Res> implements $ProfileBriefCopyWith<$Res> {
  factory _$ProfileBriefCopyWith(_ProfileBrief value, $Res Function(_ProfileBrief) _then) = __$ProfileBriefCopyWithImpl;
@override @useResult
$Res call({
 String userId, String username, String displayName, String avatarUrl, String role
});




}
/// @nodoc
class __$ProfileBriefCopyWithImpl<$Res>
    implements _$ProfileBriefCopyWith<$Res> {
  __$ProfileBriefCopyWithImpl(this._self, this._then);

  final _ProfileBrief _self;
  final $Res Function(_ProfileBrief) _then;

/// Create a copy of ProfileBrief
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? username = null,Object? displayName = null,Object? avatarUrl = null,Object? role = null,}) {
  return _then(_ProfileBrief(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CommunityPost {

 String get id; String get conversationId; String get authorId; String get body; String get mediaUrl; String get mediaMime; bool get isPinned; int get likeCount; int get commentCount; ProfileBrief get authorData; bool get isLiked; List<CommunityPostComment> get comments; String get createdAt;
/// Create a copy of CommunityPost
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommunityPostCopyWith<CommunityPost> get copyWith => _$CommunityPostCopyWithImpl<CommunityPost>(this as CommunityPost, _$identity);

  /// Serializes this CommunityPost to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommunityPost&&(identical(other.id, id) || other.id == id)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.body, body) || other.body == body)&&(identical(other.mediaUrl, mediaUrl) || other.mediaUrl == mediaUrl)&&(identical(other.mediaMime, mediaMime) || other.mediaMime == mediaMime)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.authorData, authorData) || other.authorData == authorData)&&(identical(other.isLiked, isLiked) || other.isLiked == isLiked)&&const DeepCollectionEquality().equals(other.comments, comments)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,conversationId,authorId,body,mediaUrl,mediaMime,isPinned,likeCount,commentCount,authorData,isLiked,const DeepCollectionEquality().hash(comments),createdAt);

@override
String toString() {
  return 'CommunityPost(id: $id, conversationId: $conversationId, authorId: $authorId, body: $body, mediaUrl: $mediaUrl, mediaMime: $mediaMime, isPinned: $isPinned, likeCount: $likeCount, commentCount: $commentCount, authorData: $authorData, isLiked: $isLiked, comments: $comments, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $CommunityPostCopyWith<$Res>  {
  factory $CommunityPostCopyWith(CommunityPost value, $Res Function(CommunityPost) _then) = _$CommunityPostCopyWithImpl;
@useResult
$Res call({
 String id, String conversationId, String authorId, String body, String mediaUrl, String mediaMime, bool isPinned, int likeCount, int commentCount, ProfileBrief authorData, bool isLiked, List<CommunityPostComment> comments, String createdAt
});


$ProfileBriefCopyWith<$Res> get authorData;

}
/// @nodoc
class _$CommunityPostCopyWithImpl<$Res>
    implements $CommunityPostCopyWith<$Res> {
  _$CommunityPostCopyWithImpl(this._self, this._then);

  final CommunityPost _self;
  final $Res Function(CommunityPost) _then;

/// Create a copy of CommunityPost
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? conversationId = null,Object? authorId = null,Object? body = null,Object? mediaUrl = null,Object? mediaMime = null,Object? isPinned = null,Object? likeCount = null,Object? commentCount = null,Object? authorData = null,Object? isLiked = null,Object? comments = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,mediaUrl: null == mediaUrl ? _self.mediaUrl : mediaUrl // ignore: cast_nullable_to_non_nullable
as String,mediaMime: null == mediaMime ? _self.mediaMime : mediaMime // ignore: cast_nullable_to_non_nullable
as String,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,authorData: null == authorData ? _self.authorData : authorData // ignore: cast_nullable_to_non_nullable
as ProfileBrief,isLiked: null == isLiked ? _self.isLiked : isLiked // ignore: cast_nullable_to_non_nullable
as bool,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as List<CommunityPostComment>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of CommunityPost
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileBriefCopyWith<$Res> get authorData {
  
  return $ProfileBriefCopyWith<$Res>(_self.authorData, (value) {
    return _then(_self.copyWith(authorData: value));
  });
}
}


/// Adds pattern-matching-related methods to [CommunityPost].
extension CommunityPostPatterns on CommunityPost {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommunityPost value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommunityPost() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommunityPost value)  $default,){
final _that = this;
switch (_that) {
case _CommunityPost():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommunityPost value)?  $default,){
final _that = this;
switch (_that) {
case _CommunityPost() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String conversationId,  String authorId,  String body,  String mediaUrl,  String mediaMime,  bool isPinned,  int likeCount,  int commentCount,  ProfileBrief authorData,  bool isLiked,  List<CommunityPostComment> comments,  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommunityPost() when $default != null:
return $default(_that.id,_that.conversationId,_that.authorId,_that.body,_that.mediaUrl,_that.mediaMime,_that.isPinned,_that.likeCount,_that.commentCount,_that.authorData,_that.isLiked,_that.comments,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String conversationId,  String authorId,  String body,  String mediaUrl,  String mediaMime,  bool isPinned,  int likeCount,  int commentCount,  ProfileBrief authorData,  bool isLiked,  List<CommunityPostComment> comments,  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _CommunityPost():
return $default(_that.id,_that.conversationId,_that.authorId,_that.body,_that.mediaUrl,_that.mediaMime,_that.isPinned,_that.likeCount,_that.commentCount,_that.authorData,_that.isLiked,_that.comments,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String conversationId,  String authorId,  String body,  String mediaUrl,  String mediaMime,  bool isPinned,  int likeCount,  int commentCount,  ProfileBrief authorData,  bool isLiked,  List<CommunityPostComment> comments,  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _CommunityPost() when $default != null:
return $default(_that.id,_that.conversationId,_that.authorId,_that.body,_that.mediaUrl,_that.mediaMime,_that.isPinned,_that.likeCount,_that.commentCount,_that.authorData,_that.isLiked,_that.comments,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CommunityPost implements CommunityPost {
  const _CommunityPost({required this.id, required this.conversationId, required this.authorId, this.body = '', this.mediaUrl = '', this.mediaMime = '', this.isPinned = false, this.likeCount = 0, this.commentCount = 0, required this.authorData, this.isLiked = false, final  List<CommunityPostComment> comments = const <CommunityPostComment>[], required this.createdAt}): _comments = comments;
  factory _CommunityPost.fromJson(Map<String, dynamic> json) => _$CommunityPostFromJson(json);

@override final  String id;
@override final  String conversationId;
@override final  String authorId;
@override@JsonKey() final  String body;
@override@JsonKey() final  String mediaUrl;
@override@JsonKey() final  String mediaMime;
@override@JsonKey() final  bool isPinned;
@override@JsonKey() final  int likeCount;
@override@JsonKey() final  int commentCount;
@override final  ProfileBrief authorData;
@override@JsonKey() final  bool isLiked;
 final  List<CommunityPostComment> _comments;
@override@JsonKey() List<CommunityPostComment> get comments {
  if (_comments is EqualUnmodifiableListView) return _comments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_comments);
}

@override final  String createdAt;

/// Create a copy of CommunityPost
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommunityPostCopyWith<_CommunityPost> get copyWith => __$CommunityPostCopyWithImpl<_CommunityPost>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CommunityPostToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommunityPost&&(identical(other.id, id) || other.id == id)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.body, body) || other.body == body)&&(identical(other.mediaUrl, mediaUrl) || other.mediaUrl == mediaUrl)&&(identical(other.mediaMime, mediaMime) || other.mediaMime == mediaMime)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.authorData, authorData) || other.authorData == authorData)&&(identical(other.isLiked, isLiked) || other.isLiked == isLiked)&&const DeepCollectionEquality().equals(other._comments, _comments)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,conversationId,authorId,body,mediaUrl,mediaMime,isPinned,likeCount,commentCount,authorData,isLiked,const DeepCollectionEquality().hash(_comments),createdAt);

@override
String toString() {
  return 'CommunityPost(id: $id, conversationId: $conversationId, authorId: $authorId, body: $body, mediaUrl: $mediaUrl, mediaMime: $mediaMime, isPinned: $isPinned, likeCount: $likeCount, commentCount: $commentCount, authorData: $authorData, isLiked: $isLiked, comments: $comments, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$CommunityPostCopyWith<$Res> implements $CommunityPostCopyWith<$Res> {
  factory _$CommunityPostCopyWith(_CommunityPost value, $Res Function(_CommunityPost) _then) = __$CommunityPostCopyWithImpl;
@override @useResult
$Res call({
 String id, String conversationId, String authorId, String body, String mediaUrl, String mediaMime, bool isPinned, int likeCount, int commentCount, ProfileBrief authorData, bool isLiked, List<CommunityPostComment> comments, String createdAt
});


@override $ProfileBriefCopyWith<$Res> get authorData;

}
/// @nodoc
class __$CommunityPostCopyWithImpl<$Res>
    implements _$CommunityPostCopyWith<$Res> {
  __$CommunityPostCopyWithImpl(this._self, this._then);

  final _CommunityPost _self;
  final $Res Function(_CommunityPost) _then;

/// Create a copy of CommunityPost
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? conversationId = null,Object? authorId = null,Object? body = null,Object? mediaUrl = null,Object? mediaMime = null,Object? isPinned = null,Object? likeCount = null,Object? commentCount = null,Object? authorData = null,Object? isLiked = null,Object? comments = null,Object? createdAt = null,}) {
  return _then(_CommunityPost(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,mediaUrl: null == mediaUrl ? _self.mediaUrl : mediaUrl // ignore: cast_nullable_to_non_nullable
as String,mediaMime: null == mediaMime ? _self.mediaMime : mediaMime // ignore: cast_nullable_to_non_nullable
as String,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,authorData: null == authorData ? _self.authorData : authorData // ignore: cast_nullable_to_non_nullable
as ProfileBrief,isLiked: null == isLiked ? _self.isLiked : isLiked // ignore: cast_nullable_to_non_nullable
as bool,comments: null == comments ? _self._comments : comments // ignore: cast_nullable_to_non_nullable
as List<CommunityPostComment>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of CommunityPost
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileBriefCopyWith<$Res> get authorData {
  
  return $ProfileBriefCopyWith<$Res>(_self.authorData, (value) {
    return _then(_self.copyWith(authorData: value));
  });
}
}


/// @nodoc
mixin _$CommunityListData {

 List<Conversation> get mine; List<Conversation> get discover;
/// Create a copy of CommunityListData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommunityListDataCopyWith<CommunityListData> get copyWith => _$CommunityListDataCopyWithImpl<CommunityListData>(this as CommunityListData, _$identity);

  /// Serializes this CommunityListData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommunityListData&&const DeepCollectionEquality().equals(other.mine, mine)&&const DeepCollectionEquality().equals(other.discover, discover));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(mine),const DeepCollectionEquality().hash(discover));

@override
String toString() {
  return 'CommunityListData(mine: $mine, discover: $discover)';
}


}

/// @nodoc
abstract mixin class $CommunityListDataCopyWith<$Res>  {
  factory $CommunityListDataCopyWith(CommunityListData value, $Res Function(CommunityListData) _then) = _$CommunityListDataCopyWithImpl;
@useResult
$Res call({
 List<Conversation> mine, List<Conversation> discover
});




}
/// @nodoc
class _$CommunityListDataCopyWithImpl<$Res>
    implements $CommunityListDataCopyWith<$Res> {
  _$CommunityListDataCopyWithImpl(this._self, this._then);

  final CommunityListData _self;
  final $Res Function(CommunityListData) _then;

/// Create a copy of CommunityListData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mine = null,Object? discover = null,}) {
  return _then(_self.copyWith(
mine: null == mine ? _self.mine : mine // ignore: cast_nullable_to_non_nullable
as List<Conversation>,discover: null == discover ? _self.discover : discover // ignore: cast_nullable_to_non_nullable
as List<Conversation>,
  ));
}

}


/// Adds pattern-matching-related methods to [CommunityListData].
extension CommunityListDataPatterns on CommunityListData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommunityListData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommunityListData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommunityListData value)  $default,){
final _that = this;
switch (_that) {
case _CommunityListData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommunityListData value)?  $default,){
final _that = this;
switch (_that) {
case _CommunityListData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Conversation> mine,  List<Conversation> discover)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommunityListData() when $default != null:
return $default(_that.mine,_that.discover);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Conversation> mine,  List<Conversation> discover)  $default,) {final _that = this;
switch (_that) {
case _CommunityListData():
return $default(_that.mine,_that.discover);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Conversation> mine,  List<Conversation> discover)?  $default,) {final _that = this;
switch (_that) {
case _CommunityListData() when $default != null:
return $default(_that.mine,_that.discover);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CommunityListData implements CommunityListData {
  const _CommunityListData({final  List<Conversation> mine = const <Conversation>[], final  List<Conversation> discover = const <Conversation>[]}): _mine = mine,_discover = discover;
  factory _CommunityListData.fromJson(Map<String, dynamic> json) => _$CommunityListDataFromJson(json);

 final  List<Conversation> _mine;
@override@JsonKey() List<Conversation> get mine {
  if (_mine is EqualUnmodifiableListView) return _mine;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mine);
}

 final  List<Conversation> _discover;
@override@JsonKey() List<Conversation> get discover {
  if (_discover is EqualUnmodifiableListView) return _discover;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_discover);
}


/// Create a copy of CommunityListData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommunityListDataCopyWith<_CommunityListData> get copyWith => __$CommunityListDataCopyWithImpl<_CommunityListData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CommunityListDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommunityListData&&const DeepCollectionEquality().equals(other._mine, _mine)&&const DeepCollectionEquality().equals(other._discover, _discover));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_mine),const DeepCollectionEquality().hash(_discover));

@override
String toString() {
  return 'CommunityListData(mine: $mine, discover: $discover)';
}


}

/// @nodoc
abstract mixin class _$CommunityListDataCopyWith<$Res> implements $CommunityListDataCopyWith<$Res> {
  factory _$CommunityListDataCopyWith(_CommunityListData value, $Res Function(_CommunityListData) _then) = __$CommunityListDataCopyWithImpl;
@override @useResult
$Res call({
 List<Conversation> mine, List<Conversation> discover
});




}
/// @nodoc
class __$CommunityListDataCopyWithImpl<$Res>
    implements _$CommunityListDataCopyWith<$Res> {
  __$CommunityListDataCopyWithImpl(this._self, this._then);

  final _CommunityListData _self;
  final $Res Function(_CommunityListData) _then;

/// Create a copy of CommunityListData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mine = null,Object? discover = null,}) {
  return _then(_CommunityListData(
mine: null == mine ? _self._mine : mine // ignore: cast_nullable_to_non_nullable
as List<Conversation>,discover: null == discover ? _self._discover : discover // ignore: cast_nullable_to_non_nullable
as List<Conversation>,
  ));
}


}


/// @nodoc
mixin _$CommunityDetail {

 String get id; bool get isGroup; bool get isCommunity; String get groupName; String get groupAvatarUrl; String? get groupGymId; String get subChannel; bool get callInProgress; String get description; String get coverUrl; String get inviteCode; bool get isPublic; String? get membershipRole; String? get myRole; int get memberCount; List<ParticipantData> get participantsData; List<CommunityMember> get members; int get unreadCount; LastMessageData? get lastMessage; String? get lastMessageAt; String get createdAt;
/// Create a copy of CommunityDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommunityDetailCopyWith<CommunityDetail> get copyWith => _$CommunityDetailCopyWithImpl<CommunityDetail>(this as CommunityDetail, _$identity);

  /// Serializes this CommunityDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommunityDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.isGroup, isGroup) || other.isGroup == isGroup)&&(identical(other.isCommunity, isCommunity) || other.isCommunity == isCommunity)&&(identical(other.groupName, groupName) || other.groupName == groupName)&&(identical(other.groupAvatarUrl, groupAvatarUrl) || other.groupAvatarUrl == groupAvatarUrl)&&(identical(other.groupGymId, groupGymId) || other.groupGymId == groupGymId)&&(identical(other.subChannel, subChannel) || other.subChannel == subChannel)&&(identical(other.callInProgress, callInProgress) || other.callInProgress == callInProgress)&&(identical(other.description, description) || other.description == description)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.membershipRole, membershipRole) || other.membershipRole == membershipRole)&&(identical(other.myRole, myRole) || other.myRole == myRole)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount)&&const DeepCollectionEquality().equals(other.participantsData, participantsData)&&const DeepCollectionEquality().equals(other.members, members)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.lastMessage, lastMessage) || other.lastMessage == lastMessage)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,isGroup,isCommunity,groupName,groupAvatarUrl,groupGymId,subChannel,callInProgress,description,coverUrl,inviteCode,isPublic,membershipRole,myRole,memberCount,const DeepCollectionEquality().hash(participantsData),const DeepCollectionEquality().hash(members),unreadCount,lastMessage,lastMessageAt,createdAt]);

@override
String toString() {
  return 'CommunityDetail(id: $id, isGroup: $isGroup, isCommunity: $isCommunity, groupName: $groupName, groupAvatarUrl: $groupAvatarUrl, groupGymId: $groupGymId, subChannel: $subChannel, callInProgress: $callInProgress, description: $description, coverUrl: $coverUrl, inviteCode: $inviteCode, isPublic: $isPublic, membershipRole: $membershipRole, myRole: $myRole, memberCount: $memberCount, participantsData: $participantsData, members: $members, unreadCount: $unreadCount, lastMessage: $lastMessage, lastMessageAt: $lastMessageAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $CommunityDetailCopyWith<$Res>  {
  factory $CommunityDetailCopyWith(CommunityDetail value, $Res Function(CommunityDetail) _then) = _$CommunityDetailCopyWithImpl;
@useResult
$Res call({
 String id, bool isGroup, bool isCommunity, String groupName, String groupAvatarUrl, String? groupGymId, String subChannel, bool callInProgress, String description, String coverUrl, String inviteCode, bool isPublic, String? membershipRole, String? myRole, int memberCount, List<ParticipantData> participantsData, List<CommunityMember> members, int unreadCount, LastMessageData? lastMessage, String? lastMessageAt, String createdAt
});


$LastMessageDataCopyWith<$Res>? get lastMessage;

}
/// @nodoc
class _$CommunityDetailCopyWithImpl<$Res>
    implements $CommunityDetailCopyWith<$Res> {
  _$CommunityDetailCopyWithImpl(this._self, this._then);

  final CommunityDetail _self;
  final $Res Function(CommunityDetail) _then;

/// Create a copy of CommunityDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? isGroup = null,Object? isCommunity = null,Object? groupName = null,Object? groupAvatarUrl = null,Object? groupGymId = freezed,Object? subChannel = null,Object? callInProgress = null,Object? description = null,Object? coverUrl = null,Object? inviteCode = null,Object? isPublic = null,Object? membershipRole = freezed,Object? myRole = freezed,Object? memberCount = null,Object? participantsData = null,Object? members = null,Object? unreadCount = null,Object? lastMessage = freezed,Object? lastMessageAt = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,isGroup: null == isGroup ? _self.isGroup : isGroup // ignore: cast_nullable_to_non_nullable
as bool,isCommunity: null == isCommunity ? _self.isCommunity : isCommunity // ignore: cast_nullable_to_non_nullable
as bool,groupName: null == groupName ? _self.groupName : groupName // ignore: cast_nullable_to_non_nullable
as String,groupAvatarUrl: null == groupAvatarUrl ? _self.groupAvatarUrl : groupAvatarUrl // ignore: cast_nullable_to_non_nullable
as String,groupGymId: freezed == groupGymId ? _self.groupGymId : groupGymId // ignore: cast_nullable_to_non_nullable
as String?,subChannel: null == subChannel ? _self.subChannel : subChannel // ignore: cast_nullable_to_non_nullable
as String,callInProgress: null == callInProgress ? _self.callInProgress : callInProgress // ignore: cast_nullable_to_non_nullable
as bool,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,inviteCode: null == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,membershipRole: freezed == membershipRole ? _self.membershipRole : membershipRole // ignore: cast_nullable_to_non_nullable
as String?,myRole: freezed == myRole ? _self.myRole : myRole // ignore: cast_nullable_to_non_nullable
as String?,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,participantsData: null == participantsData ? _self.participantsData : participantsData // ignore: cast_nullable_to_non_nullable
as List<ParticipantData>,members: null == members ? _self.members : members // ignore: cast_nullable_to_non_nullable
as List<CommunityMember>,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,lastMessage: freezed == lastMessage ? _self.lastMessage : lastMessage // ignore: cast_nullable_to_non_nullable
as LastMessageData?,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of CommunityDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LastMessageDataCopyWith<$Res>? get lastMessage {
    if (_self.lastMessage == null) {
    return null;
  }

  return $LastMessageDataCopyWith<$Res>(_self.lastMessage!, (value) {
    return _then(_self.copyWith(lastMessage: value));
  });
}
}


/// Adds pattern-matching-related methods to [CommunityDetail].
extension CommunityDetailPatterns on CommunityDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommunityDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommunityDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommunityDetail value)  $default,){
final _that = this;
switch (_that) {
case _CommunityDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommunityDetail value)?  $default,){
final _that = this;
switch (_that) {
case _CommunityDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  bool isGroup,  bool isCommunity,  String groupName,  String groupAvatarUrl,  String? groupGymId,  String subChannel,  bool callInProgress,  String description,  String coverUrl,  String inviteCode,  bool isPublic,  String? membershipRole,  String? myRole,  int memberCount,  List<ParticipantData> participantsData,  List<CommunityMember> members,  int unreadCount,  LastMessageData? lastMessage,  String? lastMessageAt,  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommunityDetail() when $default != null:
return $default(_that.id,_that.isGroup,_that.isCommunity,_that.groupName,_that.groupAvatarUrl,_that.groupGymId,_that.subChannel,_that.callInProgress,_that.description,_that.coverUrl,_that.inviteCode,_that.isPublic,_that.membershipRole,_that.myRole,_that.memberCount,_that.participantsData,_that.members,_that.unreadCount,_that.lastMessage,_that.lastMessageAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  bool isGroup,  bool isCommunity,  String groupName,  String groupAvatarUrl,  String? groupGymId,  String subChannel,  bool callInProgress,  String description,  String coverUrl,  String inviteCode,  bool isPublic,  String? membershipRole,  String? myRole,  int memberCount,  List<ParticipantData> participantsData,  List<CommunityMember> members,  int unreadCount,  LastMessageData? lastMessage,  String? lastMessageAt,  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _CommunityDetail():
return $default(_that.id,_that.isGroup,_that.isCommunity,_that.groupName,_that.groupAvatarUrl,_that.groupGymId,_that.subChannel,_that.callInProgress,_that.description,_that.coverUrl,_that.inviteCode,_that.isPublic,_that.membershipRole,_that.myRole,_that.memberCount,_that.participantsData,_that.members,_that.unreadCount,_that.lastMessage,_that.lastMessageAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  bool isGroup,  bool isCommunity,  String groupName,  String groupAvatarUrl,  String? groupGymId,  String subChannel,  bool callInProgress,  String description,  String coverUrl,  String inviteCode,  bool isPublic,  String? membershipRole,  String? myRole,  int memberCount,  List<ParticipantData> participantsData,  List<CommunityMember> members,  int unreadCount,  LastMessageData? lastMessage,  String? lastMessageAt,  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _CommunityDetail() when $default != null:
return $default(_that.id,_that.isGroup,_that.isCommunity,_that.groupName,_that.groupAvatarUrl,_that.groupGymId,_that.subChannel,_that.callInProgress,_that.description,_that.coverUrl,_that.inviteCode,_that.isPublic,_that.membershipRole,_that.myRole,_that.memberCount,_that.participantsData,_that.members,_that.unreadCount,_that.lastMessage,_that.lastMessageAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CommunityDetail implements CommunityDetail {
  const _CommunityDetail({required this.id, this.isGroup = false, this.isCommunity = true, this.groupName = '', this.groupAvatarUrl = '', this.groupGymId, this.subChannel = '', this.callInProgress = false, this.description = '', this.coverUrl = '', this.inviteCode = '', this.isPublic = false, this.membershipRole, this.myRole, this.memberCount = 0, final  List<ParticipantData> participantsData = const <ParticipantData>[], final  List<CommunityMember> members = const <CommunityMember>[], this.unreadCount = 0, this.lastMessage, this.lastMessageAt, required this.createdAt}): _participantsData = participantsData,_members = members;
  factory _CommunityDetail.fromJson(Map<String, dynamic> json) => _$CommunityDetailFromJson(json);

@override final  String id;
@override@JsonKey() final  bool isGroup;
@override@JsonKey() final  bool isCommunity;
@override@JsonKey() final  String groupName;
@override@JsonKey() final  String groupAvatarUrl;
@override final  String? groupGymId;
@override@JsonKey() final  String subChannel;
@override@JsonKey() final  bool callInProgress;
@override@JsonKey() final  String description;
@override@JsonKey() final  String coverUrl;
@override@JsonKey() final  String inviteCode;
@override@JsonKey() final  bool isPublic;
@override final  String? membershipRole;
@override final  String? myRole;
@override@JsonKey() final  int memberCount;
 final  List<ParticipantData> _participantsData;
@override@JsonKey() List<ParticipantData> get participantsData {
  if (_participantsData is EqualUnmodifiableListView) return _participantsData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participantsData);
}

 final  List<CommunityMember> _members;
@override@JsonKey() List<CommunityMember> get members {
  if (_members is EqualUnmodifiableListView) return _members;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_members);
}

@override@JsonKey() final  int unreadCount;
@override final  LastMessageData? lastMessage;
@override final  String? lastMessageAt;
@override final  String createdAt;

/// Create a copy of CommunityDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommunityDetailCopyWith<_CommunityDetail> get copyWith => __$CommunityDetailCopyWithImpl<_CommunityDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CommunityDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommunityDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.isGroup, isGroup) || other.isGroup == isGroup)&&(identical(other.isCommunity, isCommunity) || other.isCommunity == isCommunity)&&(identical(other.groupName, groupName) || other.groupName == groupName)&&(identical(other.groupAvatarUrl, groupAvatarUrl) || other.groupAvatarUrl == groupAvatarUrl)&&(identical(other.groupGymId, groupGymId) || other.groupGymId == groupGymId)&&(identical(other.subChannel, subChannel) || other.subChannel == subChannel)&&(identical(other.callInProgress, callInProgress) || other.callInProgress == callInProgress)&&(identical(other.description, description) || other.description == description)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.membershipRole, membershipRole) || other.membershipRole == membershipRole)&&(identical(other.myRole, myRole) || other.myRole == myRole)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount)&&const DeepCollectionEquality().equals(other._participantsData, _participantsData)&&const DeepCollectionEquality().equals(other._members, _members)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.lastMessage, lastMessage) || other.lastMessage == lastMessage)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,isGroup,isCommunity,groupName,groupAvatarUrl,groupGymId,subChannel,callInProgress,description,coverUrl,inviteCode,isPublic,membershipRole,myRole,memberCount,const DeepCollectionEquality().hash(_participantsData),const DeepCollectionEquality().hash(_members),unreadCount,lastMessage,lastMessageAt,createdAt]);

@override
String toString() {
  return 'CommunityDetail(id: $id, isGroup: $isGroup, isCommunity: $isCommunity, groupName: $groupName, groupAvatarUrl: $groupAvatarUrl, groupGymId: $groupGymId, subChannel: $subChannel, callInProgress: $callInProgress, description: $description, coverUrl: $coverUrl, inviteCode: $inviteCode, isPublic: $isPublic, membershipRole: $membershipRole, myRole: $myRole, memberCount: $memberCount, participantsData: $participantsData, members: $members, unreadCount: $unreadCount, lastMessage: $lastMessage, lastMessageAt: $lastMessageAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$CommunityDetailCopyWith<$Res> implements $CommunityDetailCopyWith<$Res> {
  factory _$CommunityDetailCopyWith(_CommunityDetail value, $Res Function(_CommunityDetail) _then) = __$CommunityDetailCopyWithImpl;
@override @useResult
$Res call({
 String id, bool isGroup, bool isCommunity, String groupName, String groupAvatarUrl, String? groupGymId, String subChannel, bool callInProgress, String description, String coverUrl, String inviteCode, bool isPublic, String? membershipRole, String? myRole, int memberCount, List<ParticipantData> participantsData, List<CommunityMember> members, int unreadCount, LastMessageData? lastMessage, String? lastMessageAt, String createdAt
});


@override $LastMessageDataCopyWith<$Res>? get lastMessage;

}
/// @nodoc
class __$CommunityDetailCopyWithImpl<$Res>
    implements _$CommunityDetailCopyWith<$Res> {
  __$CommunityDetailCopyWithImpl(this._self, this._then);

  final _CommunityDetail _self;
  final $Res Function(_CommunityDetail) _then;

/// Create a copy of CommunityDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? isGroup = null,Object? isCommunity = null,Object? groupName = null,Object? groupAvatarUrl = null,Object? groupGymId = freezed,Object? subChannel = null,Object? callInProgress = null,Object? description = null,Object? coverUrl = null,Object? inviteCode = null,Object? isPublic = null,Object? membershipRole = freezed,Object? myRole = freezed,Object? memberCount = null,Object? participantsData = null,Object? members = null,Object? unreadCount = null,Object? lastMessage = freezed,Object? lastMessageAt = freezed,Object? createdAt = null,}) {
  return _then(_CommunityDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,isGroup: null == isGroup ? _self.isGroup : isGroup // ignore: cast_nullable_to_non_nullable
as bool,isCommunity: null == isCommunity ? _self.isCommunity : isCommunity // ignore: cast_nullable_to_non_nullable
as bool,groupName: null == groupName ? _self.groupName : groupName // ignore: cast_nullable_to_non_nullable
as String,groupAvatarUrl: null == groupAvatarUrl ? _self.groupAvatarUrl : groupAvatarUrl // ignore: cast_nullable_to_non_nullable
as String,groupGymId: freezed == groupGymId ? _self.groupGymId : groupGymId // ignore: cast_nullable_to_non_nullable
as String?,subChannel: null == subChannel ? _self.subChannel : subChannel // ignore: cast_nullable_to_non_nullable
as String,callInProgress: null == callInProgress ? _self.callInProgress : callInProgress // ignore: cast_nullable_to_non_nullable
as bool,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,inviteCode: null == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,membershipRole: freezed == membershipRole ? _self.membershipRole : membershipRole // ignore: cast_nullable_to_non_nullable
as String?,myRole: freezed == myRole ? _self.myRole : myRole // ignore: cast_nullable_to_non_nullable
as String?,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,participantsData: null == participantsData ? _self._participantsData : participantsData // ignore: cast_nullable_to_non_nullable
as List<ParticipantData>,members: null == members ? _self._members : members // ignore: cast_nullable_to_non_nullable
as List<CommunityMember>,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,lastMessage: freezed == lastMessage ? _self.lastMessage : lastMessage // ignore: cast_nullable_to_non_nullable
as LastMessageData?,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of CommunityDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LastMessageDataCopyWith<$Res>? get lastMessage {
    if (_self.lastMessage == null) {
    return null;
  }

  return $LastMessageDataCopyWith<$Res>(_self.lastMessage!, (value) {
    return _then(_self.copyWith(lastMessage: value));
  });
}
}


/// @nodoc
mixin _$ReplyData {

 String get id; String get body; String get senderName; String get messageType; String get mediaUrl;
/// Create a copy of ReplyData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReplyDataCopyWith<ReplyData> get copyWith => _$ReplyDataCopyWithImpl<ReplyData>(this as ReplyData, _$identity);

  /// Serializes this ReplyData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReplyData&&(identical(other.id, id) || other.id == id)&&(identical(other.body, body) || other.body == body)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.messageType, messageType) || other.messageType == messageType)&&(identical(other.mediaUrl, mediaUrl) || other.mediaUrl == mediaUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,body,senderName,messageType,mediaUrl);

@override
String toString() {
  return 'ReplyData(id: $id, body: $body, senderName: $senderName, messageType: $messageType, mediaUrl: $mediaUrl)';
}


}

/// @nodoc
abstract mixin class $ReplyDataCopyWith<$Res>  {
  factory $ReplyDataCopyWith(ReplyData value, $Res Function(ReplyData) _then) = _$ReplyDataCopyWithImpl;
@useResult
$Res call({
 String id, String body, String senderName, String messageType, String mediaUrl
});




}
/// @nodoc
class _$ReplyDataCopyWithImpl<$Res>
    implements $ReplyDataCopyWith<$Res> {
  _$ReplyDataCopyWithImpl(this._self, this._then);

  final ReplyData _self;
  final $Res Function(ReplyData) _then;

/// Create a copy of ReplyData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? body = null,Object? senderName = null,Object? messageType = null,Object? mediaUrl = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,messageType: null == messageType ? _self.messageType : messageType // ignore: cast_nullable_to_non_nullable
as String,mediaUrl: null == mediaUrl ? _self.mediaUrl : mediaUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ReplyData].
extension ReplyDataPatterns on ReplyData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReplyData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReplyData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReplyData value)  $default,){
final _that = this;
switch (_that) {
case _ReplyData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReplyData value)?  $default,){
final _that = this;
switch (_that) {
case _ReplyData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String body,  String senderName,  String messageType,  String mediaUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReplyData() when $default != null:
return $default(_that.id,_that.body,_that.senderName,_that.messageType,_that.mediaUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String body,  String senderName,  String messageType,  String mediaUrl)  $default,) {final _that = this;
switch (_that) {
case _ReplyData():
return $default(_that.id,_that.body,_that.senderName,_that.messageType,_that.mediaUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String body,  String senderName,  String messageType,  String mediaUrl)?  $default,) {final _that = this;
switch (_that) {
case _ReplyData() when $default != null:
return $default(_that.id,_that.body,_that.senderName,_that.messageType,_that.mediaUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReplyData implements ReplyData {
  const _ReplyData({required this.id, this.body = '', this.senderName = '', this.messageType = 'text', this.mediaUrl = ''});
  factory _ReplyData.fromJson(Map<String, dynamic> json) => _$ReplyDataFromJson(json);

@override final  String id;
@override@JsonKey() final  String body;
@override@JsonKey() final  String senderName;
@override@JsonKey() final  String messageType;
@override@JsonKey() final  String mediaUrl;

/// Create a copy of ReplyData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReplyDataCopyWith<_ReplyData> get copyWith => __$ReplyDataCopyWithImpl<_ReplyData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReplyDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReplyData&&(identical(other.id, id) || other.id == id)&&(identical(other.body, body) || other.body == body)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.messageType, messageType) || other.messageType == messageType)&&(identical(other.mediaUrl, mediaUrl) || other.mediaUrl == mediaUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,body,senderName,messageType,mediaUrl);

@override
String toString() {
  return 'ReplyData(id: $id, body: $body, senderName: $senderName, messageType: $messageType, mediaUrl: $mediaUrl)';
}


}

/// @nodoc
abstract mixin class _$ReplyDataCopyWith<$Res> implements $ReplyDataCopyWith<$Res> {
  factory _$ReplyDataCopyWith(_ReplyData value, $Res Function(_ReplyData) _then) = __$ReplyDataCopyWithImpl;
@override @useResult
$Res call({
 String id, String body, String senderName, String messageType, String mediaUrl
});




}
/// @nodoc
class __$ReplyDataCopyWithImpl<$Res>
    implements _$ReplyDataCopyWith<$Res> {
  __$ReplyDataCopyWithImpl(this._self, this._then);

  final _ReplyData _self;
  final $Res Function(_ReplyData) _then;

/// Create a copy of ReplyData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? body = null,Object? senderName = null,Object? messageType = null,Object? mediaUrl = null,}) {
  return _then(_ReplyData(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,messageType: null == messageType ? _self.messageType : messageType // ignore: cast_nullable_to_non_nullable
as String,mediaUrl: null == mediaUrl ? _self.mediaUrl : mediaUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Message {

 String get id; String get conversationId; String get senderId; String get messageType; String get body; String get mediaUrl; String get mediaMime; String get fileName; String? get replyToId; Map<String, dynamic> get metadata; bool get isRead; List<String> get deletedFor; ParticipantData get senderData; ReplyData? get replyData; Map<String, int> get reactions; String get createdAt;
/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageCopyWith<Message> get copyWith => _$MessageCopyWithImpl<Message>(this as Message, _$identity);

  /// Serializes this Message to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Message&&(identical(other.id, id) || other.id == id)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.messageType, messageType) || other.messageType == messageType)&&(identical(other.body, body) || other.body == body)&&(identical(other.mediaUrl, mediaUrl) || other.mediaUrl == mediaUrl)&&(identical(other.mediaMime, mediaMime) || other.mediaMime == mediaMime)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.replyToId, replyToId) || other.replyToId == replyToId)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&const DeepCollectionEquality().equals(other.deletedFor, deletedFor)&&(identical(other.senderData, senderData) || other.senderData == senderData)&&(identical(other.replyData, replyData) || other.replyData == replyData)&&const DeepCollectionEquality().equals(other.reactions, reactions)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,conversationId,senderId,messageType,body,mediaUrl,mediaMime,fileName,replyToId,const DeepCollectionEquality().hash(metadata),isRead,const DeepCollectionEquality().hash(deletedFor),senderData,replyData,const DeepCollectionEquality().hash(reactions),createdAt);

@override
String toString() {
  return 'Message(id: $id, conversationId: $conversationId, senderId: $senderId, messageType: $messageType, body: $body, mediaUrl: $mediaUrl, mediaMime: $mediaMime, fileName: $fileName, replyToId: $replyToId, metadata: $metadata, isRead: $isRead, deletedFor: $deletedFor, senderData: $senderData, replyData: $replyData, reactions: $reactions, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $MessageCopyWith<$Res>  {
  factory $MessageCopyWith(Message value, $Res Function(Message) _then) = _$MessageCopyWithImpl;
@useResult
$Res call({
 String id, String conversationId, String senderId, String messageType, String body, String mediaUrl, String mediaMime, String fileName, String? replyToId, Map<String, dynamic> metadata, bool isRead, List<String> deletedFor, ParticipantData senderData, ReplyData? replyData, Map<String, int> reactions, String createdAt
});


$ParticipantDataCopyWith<$Res> get senderData;$ReplyDataCopyWith<$Res>? get replyData;

}
/// @nodoc
class _$MessageCopyWithImpl<$Res>
    implements $MessageCopyWith<$Res> {
  _$MessageCopyWithImpl(this._self, this._then);

  final Message _self;
  final $Res Function(Message) _then;

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? conversationId = null,Object? senderId = null,Object? messageType = null,Object? body = null,Object? mediaUrl = null,Object? mediaMime = null,Object? fileName = null,Object? replyToId = freezed,Object? metadata = null,Object? isRead = null,Object? deletedFor = null,Object? senderData = null,Object? replyData = freezed,Object? reactions = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,messageType: null == messageType ? _self.messageType : messageType // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,mediaUrl: null == mediaUrl ? _self.mediaUrl : mediaUrl // ignore: cast_nullable_to_non_nullable
as String,mediaMime: null == mediaMime ? _self.mediaMime : mediaMime // ignore: cast_nullable_to_non_nullable
as String,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,replyToId: freezed == replyToId ? _self.replyToId : replyToId // ignore: cast_nullable_to_non_nullable
as String?,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,deletedFor: null == deletedFor ? _self.deletedFor : deletedFor // ignore: cast_nullable_to_non_nullable
as List<String>,senderData: null == senderData ? _self.senderData : senderData // ignore: cast_nullable_to_non_nullable
as ParticipantData,replyData: freezed == replyData ? _self.replyData : replyData // ignore: cast_nullable_to_non_nullable
as ReplyData?,reactions: null == reactions ? _self.reactions : reactions // ignore: cast_nullable_to_non_nullable
as Map<String, int>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ParticipantDataCopyWith<$Res> get senderData {
  
  return $ParticipantDataCopyWith<$Res>(_self.senderData, (value) {
    return _then(_self.copyWith(senderData: value));
  });
}/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReplyDataCopyWith<$Res>? get replyData {
    if (_self.replyData == null) {
    return null;
  }

  return $ReplyDataCopyWith<$Res>(_self.replyData!, (value) {
    return _then(_self.copyWith(replyData: value));
  });
}
}


/// Adds pattern-matching-related methods to [Message].
extension MessagePatterns on Message {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Message value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Message() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Message value)  $default,){
final _that = this;
switch (_that) {
case _Message():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Message value)?  $default,){
final _that = this;
switch (_that) {
case _Message() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String conversationId,  String senderId,  String messageType,  String body,  String mediaUrl,  String mediaMime,  String fileName,  String? replyToId,  Map<String, dynamic> metadata,  bool isRead,  List<String> deletedFor,  ParticipantData senderData,  ReplyData? replyData,  Map<String, int> reactions,  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Message() when $default != null:
return $default(_that.id,_that.conversationId,_that.senderId,_that.messageType,_that.body,_that.mediaUrl,_that.mediaMime,_that.fileName,_that.replyToId,_that.metadata,_that.isRead,_that.deletedFor,_that.senderData,_that.replyData,_that.reactions,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String conversationId,  String senderId,  String messageType,  String body,  String mediaUrl,  String mediaMime,  String fileName,  String? replyToId,  Map<String, dynamic> metadata,  bool isRead,  List<String> deletedFor,  ParticipantData senderData,  ReplyData? replyData,  Map<String, int> reactions,  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _Message():
return $default(_that.id,_that.conversationId,_that.senderId,_that.messageType,_that.body,_that.mediaUrl,_that.mediaMime,_that.fileName,_that.replyToId,_that.metadata,_that.isRead,_that.deletedFor,_that.senderData,_that.replyData,_that.reactions,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String conversationId,  String senderId,  String messageType,  String body,  String mediaUrl,  String mediaMime,  String fileName,  String? replyToId,  Map<String, dynamic> metadata,  bool isRead,  List<String> deletedFor,  ParticipantData senderData,  ReplyData? replyData,  Map<String, int> reactions,  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Message() when $default != null:
return $default(_that.id,_that.conversationId,_that.senderId,_that.messageType,_that.body,_that.mediaUrl,_that.mediaMime,_that.fileName,_that.replyToId,_that.metadata,_that.isRead,_that.deletedFor,_that.senderData,_that.replyData,_that.reactions,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Message implements Message {
  const _Message({required this.id, required this.conversationId, required this.senderId, this.messageType = 'text', this.body = '', this.mediaUrl = '', this.mediaMime = '', this.fileName = '', this.replyToId, final  Map<String, dynamic> metadata = const <String, dynamic>{}, this.isRead = false, final  List<String> deletedFor = const <String>[], required this.senderData, this.replyData, final  Map<String, int> reactions = const <String, int>{}, required this.createdAt}): _metadata = metadata,_deletedFor = deletedFor,_reactions = reactions;
  factory _Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

@override final  String id;
@override final  String conversationId;
@override final  String senderId;
@override@JsonKey() final  String messageType;
@override@JsonKey() final  String body;
@override@JsonKey() final  String mediaUrl;
@override@JsonKey() final  String mediaMime;
@override@JsonKey() final  String fileName;
@override final  String? replyToId;
 final  Map<String, dynamic> _metadata;
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}

@override@JsonKey() final  bool isRead;
 final  List<String> _deletedFor;
@override@JsonKey() List<String> get deletedFor {
  if (_deletedFor is EqualUnmodifiableListView) return _deletedFor;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_deletedFor);
}

@override final  ParticipantData senderData;
@override final  ReplyData? replyData;
 final  Map<String, int> _reactions;
@override@JsonKey() Map<String, int> get reactions {
  if (_reactions is EqualUnmodifiableMapView) return _reactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_reactions);
}

@override final  String createdAt;

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageCopyWith<_Message> get copyWith => __$MessageCopyWithImpl<_Message>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Message&&(identical(other.id, id) || other.id == id)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.messageType, messageType) || other.messageType == messageType)&&(identical(other.body, body) || other.body == body)&&(identical(other.mediaUrl, mediaUrl) || other.mediaUrl == mediaUrl)&&(identical(other.mediaMime, mediaMime) || other.mediaMime == mediaMime)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.replyToId, replyToId) || other.replyToId == replyToId)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&const DeepCollectionEquality().equals(other._deletedFor, _deletedFor)&&(identical(other.senderData, senderData) || other.senderData == senderData)&&(identical(other.replyData, replyData) || other.replyData == replyData)&&const DeepCollectionEquality().equals(other._reactions, _reactions)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,conversationId,senderId,messageType,body,mediaUrl,mediaMime,fileName,replyToId,const DeepCollectionEquality().hash(_metadata),isRead,const DeepCollectionEquality().hash(_deletedFor),senderData,replyData,const DeepCollectionEquality().hash(_reactions),createdAt);

@override
String toString() {
  return 'Message(id: $id, conversationId: $conversationId, senderId: $senderId, messageType: $messageType, body: $body, mediaUrl: $mediaUrl, mediaMime: $mediaMime, fileName: $fileName, replyToId: $replyToId, metadata: $metadata, isRead: $isRead, deletedFor: $deletedFor, senderData: $senderData, replyData: $replyData, reactions: $reactions, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$MessageCopyWith<$Res> implements $MessageCopyWith<$Res> {
  factory _$MessageCopyWith(_Message value, $Res Function(_Message) _then) = __$MessageCopyWithImpl;
@override @useResult
$Res call({
 String id, String conversationId, String senderId, String messageType, String body, String mediaUrl, String mediaMime, String fileName, String? replyToId, Map<String, dynamic> metadata, bool isRead, List<String> deletedFor, ParticipantData senderData, ReplyData? replyData, Map<String, int> reactions, String createdAt
});


@override $ParticipantDataCopyWith<$Res> get senderData;@override $ReplyDataCopyWith<$Res>? get replyData;

}
/// @nodoc
class __$MessageCopyWithImpl<$Res>
    implements _$MessageCopyWith<$Res> {
  __$MessageCopyWithImpl(this._self, this._then);

  final _Message _self;
  final $Res Function(_Message) _then;

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? conversationId = null,Object? senderId = null,Object? messageType = null,Object? body = null,Object? mediaUrl = null,Object? mediaMime = null,Object? fileName = null,Object? replyToId = freezed,Object? metadata = null,Object? isRead = null,Object? deletedFor = null,Object? senderData = null,Object? replyData = freezed,Object? reactions = null,Object? createdAt = null,}) {
  return _then(_Message(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,messageType: null == messageType ? _self.messageType : messageType // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,mediaUrl: null == mediaUrl ? _self.mediaUrl : mediaUrl // ignore: cast_nullable_to_non_nullable
as String,mediaMime: null == mediaMime ? _self.mediaMime : mediaMime // ignore: cast_nullable_to_non_nullable
as String,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,replyToId: freezed == replyToId ? _self.replyToId : replyToId // ignore: cast_nullable_to_non_nullable
as String?,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,deletedFor: null == deletedFor ? _self._deletedFor : deletedFor // ignore: cast_nullable_to_non_nullable
as List<String>,senderData: null == senderData ? _self.senderData : senderData // ignore: cast_nullable_to_non_nullable
as ParticipantData,replyData: freezed == replyData ? _self.replyData : replyData // ignore: cast_nullable_to_non_nullable
as ReplyData?,reactions: null == reactions ? _self._reactions : reactions // ignore: cast_nullable_to_non_nullable
as Map<String, int>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ParticipantDataCopyWith<$Res> get senderData {
  
  return $ParticipantDataCopyWith<$Res>(_self.senderData, (value) {
    return _then(_self.copyWith(senderData: value));
  });
}/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReplyDataCopyWith<$Res>? get replyData {
    if (_self.replyData == null) {
    return null;
  }

  return $ReplyDataCopyWith<$Res>(_self.replyData!, (value) {
    return _then(_self.copyWith(replyData: value));
  });
}
}


/// @nodoc
mixin _$CallLog {

 String get id; String get conversationId; String get callType; String get status; int get durationSeconds; Map<String, dynamic> get callerData; Map<String, dynamic> get calleeData; String get createdAt; String? get endedAt;
/// Create a copy of CallLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CallLogCopyWith<CallLog> get copyWith => _$CallLogCopyWithImpl<CallLog>(this as CallLog, _$identity);

  /// Serializes this CallLog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CallLog&&(identical(other.id, id) || other.id == id)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.callType, callType) || other.callType == callType)&&(identical(other.status, status) || other.status == status)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&const DeepCollectionEquality().equals(other.callerData, callerData)&&const DeepCollectionEquality().equals(other.calleeData, calleeData)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,conversationId,callType,status,durationSeconds,const DeepCollectionEquality().hash(callerData),const DeepCollectionEquality().hash(calleeData),createdAt,endedAt);

@override
String toString() {
  return 'CallLog(id: $id, conversationId: $conversationId, callType: $callType, status: $status, durationSeconds: $durationSeconds, callerData: $callerData, calleeData: $calleeData, createdAt: $createdAt, endedAt: $endedAt)';
}


}

/// @nodoc
abstract mixin class $CallLogCopyWith<$Res>  {
  factory $CallLogCopyWith(CallLog value, $Res Function(CallLog) _then) = _$CallLogCopyWithImpl;
@useResult
$Res call({
 String id, String conversationId, String callType, String status, int durationSeconds, Map<String, dynamic> callerData, Map<String, dynamic> calleeData, String createdAt, String? endedAt
});




}
/// @nodoc
class _$CallLogCopyWithImpl<$Res>
    implements $CallLogCopyWith<$Res> {
  _$CallLogCopyWithImpl(this._self, this._then);

  final CallLog _self;
  final $Res Function(CallLog) _then;

/// Create a copy of CallLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? conversationId = null,Object? callType = null,Object? status = null,Object? durationSeconds = null,Object? callerData = null,Object? calleeData = null,Object? createdAt = null,Object? endedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,callType: null == callType ? _self.callType : callType // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,callerData: null == callerData ? _self.callerData : callerData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,calleeData: null == calleeData ? _self.calleeData : calleeData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CallLog].
extension CallLogPatterns on CallLog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CallLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CallLog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CallLog value)  $default,){
final _that = this;
switch (_that) {
case _CallLog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CallLog value)?  $default,){
final _that = this;
switch (_that) {
case _CallLog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String conversationId,  String callType,  String status,  int durationSeconds,  Map<String, dynamic> callerData,  Map<String, dynamic> calleeData,  String createdAt,  String? endedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CallLog() when $default != null:
return $default(_that.id,_that.conversationId,_that.callType,_that.status,_that.durationSeconds,_that.callerData,_that.calleeData,_that.createdAt,_that.endedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String conversationId,  String callType,  String status,  int durationSeconds,  Map<String, dynamic> callerData,  Map<String, dynamic> calleeData,  String createdAt,  String? endedAt)  $default,) {final _that = this;
switch (_that) {
case _CallLog():
return $default(_that.id,_that.conversationId,_that.callType,_that.status,_that.durationSeconds,_that.callerData,_that.calleeData,_that.createdAt,_that.endedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String conversationId,  String callType,  String status,  int durationSeconds,  Map<String, dynamic> callerData,  Map<String, dynamic> calleeData,  String createdAt,  String? endedAt)?  $default,) {final _that = this;
switch (_that) {
case _CallLog() when $default != null:
return $default(_that.id,_that.conversationId,_that.callType,_that.status,_that.durationSeconds,_that.callerData,_that.calleeData,_that.createdAt,_that.endedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CallLog implements CallLog {
  const _CallLog({required this.id, required this.conversationId, this.callType = 'audio', this.status = '', this.durationSeconds = 0, required final  Map<String, dynamic> callerData, required final  Map<String, dynamic> calleeData, required this.createdAt, this.endedAt}): _callerData = callerData,_calleeData = calleeData;
  factory _CallLog.fromJson(Map<String, dynamic> json) => _$CallLogFromJson(json);

@override final  String id;
@override final  String conversationId;
@override@JsonKey() final  String callType;
@override@JsonKey() final  String status;
@override@JsonKey() final  int durationSeconds;
 final  Map<String, dynamic> _callerData;
@override Map<String, dynamic> get callerData {
  if (_callerData is EqualUnmodifiableMapView) return _callerData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_callerData);
}

 final  Map<String, dynamic> _calleeData;
@override Map<String, dynamic> get calleeData {
  if (_calleeData is EqualUnmodifiableMapView) return _calleeData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_calleeData);
}

@override final  String createdAt;
@override final  String? endedAt;

/// Create a copy of CallLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CallLogCopyWith<_CallLog> get copyWith => __$CallLogCopyWithImpl<_CallLog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CallLogToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CallLog&&(identical(other.id, id) || other.id == id)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.callType, callType) || other.callType == callType)&&(identical(other.status, status) || other.status == status)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&const DeepCollectionEquality().equals(other._callerData, _callerData)&&const DeepCollectionEquality().equals(other._calleeData, _calleeData)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,conversationId,callType,status,durationSeconds,const DeepCollectionEquality().hash(_callerData),const DeepCollectionEquality().hash(_calleeData),createdAt,endedAt);

@override
String toString() {
  return 'CallLog(id: $id, conversationId: $conversationId, callType: $callType, status: $status, durationSeconds: $durationSeconds, callerData: $callerData, calleeData: $calleeData, createdAt: $createdAt, endedAt: $endedAt)';
}


}

/// @nodoc
abstract mixin class _$CallLogCopyWith<$Res> implements $CallLogCopyWith<$Res> {
  factory _$CallLogCopyWith(_CallLog value, $Res Function(_CallLog) _then) = __$CallLogCopyWithImpl;
@override @useResult
$Res call({
 String id, String conversationId, String callType, String status, int durationSeconds, Map<String, dynamic> callerData, Map<String, dynamic> calleeData, String createdAt, String? endedAt
});




}
/// @nodoc
class __$CallLogCopyWithImpl<$Res>
    implements _$CallLogCopyWith<$Res> {
  __$CallLogCopyWithImpl(this._self, this._then);

  final _CallLog _self;
  final $Res Function(_CallLog) _then;

/// Create a copy of CallLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? conversationId = null,Object? callType = null,Object? status = null,Object? durationSeconds = null,Object? callerData = null,Object? calleeData = null,Object? createdAt = null,Object? endedAt = freezed,}) {
  return _then(_CallLog(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,callType: null == callType ? _self.callType : callType // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,callerData: null == callerData ? _self._callerData : callerData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,calleeData: null == calleeData ? _self._calleeData : calleeData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$LinkPreviewData {

 String get url; String get title; String get description; String get image; String get domain;
/// Create a copy of LinkPreviewData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LinkPreviewDataCopyWith<LinkPreviewData> get copyWith => _$LinkPreviewDataCopyWithImpl<LinkPreviewData>(this as LinkPreviewData, _$identity);

  /// Serializes this LinkPreviewData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LinkPreviewData&&(identical(other.url, url) || other.url == url)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.image, image) || other.image == image)&&(identical(other.domain, domain) || other.domain == domain));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,title,description,image,domain);

@override
String toString() {
  return 'LinkPreviewData(url: $url, title: $title, description: $description, image: $image, domain: $domain)';
}


}

/// @nodoc
abstract mixin class $LinkPreviewDataCopyWith<$Res>  {
  factory $LinkPreviewDataCopyWith(LinkPreviewData value, $Res Function(LinkPreviewData) _then) = _$LinkPreviewDataCopyWithImpl;
@useResult
$Res call({
 String url, String title, String description, String image, String domain
});




}
/// @nodoc
class _$LinkPreviewDataCopyWithImpl<$Res>
    implements $LinkPreviewDataCopyWith<$Res> {
  _$LinkPreviewDataCopyWithImpl(this._self, this._then);

  final LinkPreviewData _self;
  final $Res Function(LinkPreviewData) _then;

/// Create a copy of LinkPreviewData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? title = null,Object? description = null,Object? image = null,Object? domain = null,}) {
  return _then(_self.copyWith(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String,domain: null == domain ? _self.domain : domain // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LinkPreviewData].
extension LinkPreviewDataPatterns on LinkPreviewData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LinkPreviewData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LinkPreviewData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LinkPreviewData value)  $default,){
final _that = this;
switch (_that) {
case _LinkPreviewData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LinkPreviewData value)?  $default,){
final _that = this;
switch (_that) {
case _LinkPreviewData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  String title,  String description,  String image,  String domain)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LinkPreviewData() when $default != null:
return $default(_that.url,_that.title,_that.description,_that.image,_that.domain);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  String title,  String description,  String image,  String domain)  $default,) {final _that = this;
switch (_that) {
case _LinkPreviewData():
return $default(_that.url,_that.title,_that.description,_that.image,_that.domain);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  String title,  String description,  String image,  String domain)?  $default,) {final _that = this;
switch (_that) {
case _LinkPreviewData() when $default != null:
return $default(_that.url,_that.title,_that.description,_that.image,_that.domain);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LinkPreviewData implements LinkPreviewData {
  const _LinkPreviewData({required this.url, this.title = '', this.description = '', this.image = '', this.domain = ''});
  factory _LinkPreviewData.fromJson(Map<String, dynamic> json) => _$LinkPreviewDataFromJson(json);

@override final  String url;
@override@JsonKey() final  String title;
@override@JsonKey() final  String description;
@override@JsonKey() final  String image;
@override@JsonKey() final  String domain;

/// Create a copy of LinkPreviewData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LinkPreviewDataCopyWith<_LinkPreviewData> get copyWith => __$LinkPreviewDataCopyWithImpl<_LinkPreviewData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LinkPreviewDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LinkPreviewData&&(identical(other.url, url) || other.url == url)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.image, image) || other.image == image)&&(identical(other.domain, domain) || other.domain == domain));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,title,description,image,domain);

@override
String toString() {
  return 'LinkPreviewData(url: $url, title: $title, description: $description, image: $image, domain: $domain)';
}


}

/// @nodoc
abstract mixin class _$LinkPreviewDataCopyWith<$Res> implements $LinkPreviewDataCopyWith<$Res> {
  factory _$LinkPreviewDataCopyWith(_LinkPreviewData value, $Res Function(_LinkPreviewData) _then) = __$LinkPreviewDataCopyWithImpl;
@override @useResult
$Res call({
 String url, String title, String description, String image, String domain
});




}
/// @nodoc
class __$LinkPreviewDataCopyWithImpl<$Res>
    implements _$LinkPreviewDataCopyWith<$Res> {
  __$LinkPreviewDataCopyWithImpl(this._self, this._then);

  final _LinkPreviewData _self;
  final $Res Function(_LinkPreviewData) _then;

/// Create a copy of LinkPreviewData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? title = null,Object? description = null,Object? image = null,Object? domain = null,}) {
  return _then(_LinkPreviewData(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String,domain: null == domain ? _self.domain : domain // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PendingCall {

 String get conversationId; String get fromUserId; String get fromUsername; String get fromDisplayName; String get fromAvatarUrl; String get callType; Map<String, dynamic> get data;
/// Create a copy of PendingCall
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PendingCallCopyWith<PendingCall> get copyWith => _$PendingCallCopyWithImpl<PendingCall>(this as PendingCall, _$identity);

  /// Serializes this PendingCall to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PendingCall&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.fromUserId, fromUserId) || other.fromUserId == fromUserId)&&(identical(other.fromUsername, fromUsername) || other.fromUsername == fromUsername)&&(identical(other.fromDisplayName, fromDisplayName) || other.fromDisplayName == fromDisplayName)&&(identical(other.fromAvatarUrl, fromAvatarUrl) || other.fromAvatarUrl == fromAvatarUrl)&&(identical(other.callType, callType) || other.callType == callType)&&const DeepCollectionEquality().equals(other.data, data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,conversationId,fromUserId,fromUsername,fromDisplayName,fromAvatarUrl,callType,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'PendingCall(conversationId: $conversationId, fromUserId: $fromUserId, fromUsername: $fromUsername, fromDisplayName: $fromDisplayName, fromAvatarUrl: $fromAvatarUrl, callType: $callType, data: $data)';
}


}

/// @nodoc
abstract mixin class $PendingCallCopyWith<$Res>  {
  factory $PendingCallCopyWith(PendingCall value, $Res Function(PendingCall) _then) = _$PendingCallCopyWithImpl;
@useResult
$Res call({
 String conversationId, String fromUserId, String fromUsername, String fromDisplayName, String fromAvatarUrl, String callType, Map<String, dynamic> data
});




}
/// @nodoc
class _$PendingCallCopyWithImpl<$Res>
    implements $PendingCallCopyWith<$Res> {
  _$PendingCallCopyWithImpl(this._self, this._then);

  final PendingCall _self;
  final $Res Function(PendingCall) _then;

/// Create a copy of PendingCall
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? conversationId = null,Object? fromUserId = null,Object? fromUsername = null,Object? fromDisplayName = null,Object? fromAvatarUrl = null,Object? callType = null,Object? data = null,}) {
  return _then(_self.copyWith(
conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,fromUserId: null == fromUserId ? _self.fromUserId : fromUserId // ignore: cast_nullable_to_non_nullable
as String,fromUsername: null == fromUsername ? _self.fromUsername : fromUsername // ignore: cast_nullable_to_non_nullable
as String,fromDisplayName: null == fromDisplayName ? _self.fromDisplayName : fromDisplayName // ignore: cast_nullable_to_non_nullable
as String,fromAvatarUrl: null == fromAvatarUrl ? _self.fromAvatarUrl : fromAvatarUrl // ignore: cast_nullable_to_non_nullable
as String,callType: null == callType ? _self.callType : callType // ignore: cast_nullable_to_non_nullable
as String,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [PendingCall].
extension PendingCallPatterns on PendingCall {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PendingCall value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PendingCall() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PendingCall value)  $default,){
final _that = this;
switch (_that) {
case _PendingCall():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PendingCall value)?  $default,){
final _that = this;
switch (_that) {
case _PendingCall() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String conversationId,  String fromUserId,  String fromUsername,  String fromDisplayName,  String fromAvatarUrl,  String callType,  Map<String, dynamic> data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PendingCall() when $default != null:
return $default(_that.conversationId,_that.fromUserId,_that.fromUsername,_that.fromDisplayName,_that.fromAvatarUrl,_that.callType,_that.data);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String conversationId,  String fromUserId,  String fromUsername,  String fromDisplayName,  String fromAvatarUrl,  String callType,  Map<String, dynamic> data)  $default,) {final _that = this;
switch (_that) {
case _PendingCall():
return $default(_that.conversationId,_that.fromUserId,_that.fromUsername,_that.fromDisplayName,_that.fromAvatarUrl,_that.callType,_that.data);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String conversationId,  String fromUserId,  String fromUsername,  String fromDisplayName,  String fromAvatarUrl,  String callType,  Map<String, dynamic> data)?  $default,) {final _that = this;
switch (_that) {
case _PendingCall() when $default != null:
return $default(_that.conversationId,_that.fromUserId,_that.fromUsername,_that.fromDisplayName,_that.fromAvatarUrl,_that.callType,_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PendingCall implements PendingCall {
  const _PendingCall({required this.conversationId, required this.fromUserId, required this.fromUsername, required this.fromDisplayName, required this.fromAvatarUrl, this.callType = 'audio', final  Map<String, dynamic> data = const <String, dynamic>{}}): _data = data;
  factory _PendingCall.fromJson(Map<String, dynamic> json) => _$PendingCallFromJson(json);

@override final  String conversationId;
@override final  String fromUserId;
@override final  String fromUsername;
@override final  String fromDisplayName;
@override final  String fromAvatarUrl;
@override@JsonKey() final  String callType;
 final  Map<String, dynamic> _data;
@override@JsonKey() Map<String, dynamic> get data {
  if (_data is EqualUnmodifiableMapView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_data);
}


/// Create a copy of PendingCall
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PendingCallCopyWith<_PendingCall> get copyWith => __$PendingCallCopyWithImpl<_PendingCall>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PendingCallToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PendingCall&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.fromUserId, fromUserId) || other.fromUserId == fromUserId)&&(identical(other.fromUsername, fromUsername) || other.fromUsername == fromUsername)&&(identical(other.fromDisplayName, fromDisplayName) || other.fromDisplayName == fromDisplayName)&&(identical(other.fromAvatarUrl, fromAvatarUrl) || other.fromAvatarUrl == fromAvatarUrl)&&(identical(other.callType, callType) || other.callType == callType)&&const DeepCollectionEquality().equals(other._data, _data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,conversationId,fromUserId,fromUsername,fromDisplayName,fromAvatarUrl,callType,const DeepCollectionEquality().hash(_data));

@override
String toString() {
  return 'PendingCall(conversationId: $conversationId, fromUserId: $fromUserId, fromUsername: $fromUsername, fromDisplayName: $fromDisplayName, fromAvatarUrl: $fromAvatarUrl, callType: $callType, data: $data)';
}


}

/// @nodoc
abstract mixin class _$PendingCallCopyWith<$Res> implements $PendingCallCopyWith<$Res> {
  factory _$PendingCallCopyWith(_PendingCall value, $Res Function(_PendingCall) _then) = __$PendingCallCopyWithImpl;
@override @useResult
$Res call({
 String conversationId, String fromUserId, String fromUsername, String fromDisplayName, String fromAvatarUrl, String callType, Map<String, dynamic> data
});




}
/// @nodoc
class __$PendingCallCopyWithImpl<$Res>
    implements _$PendingCallCopyWith<$Res> {
  __$PendingCallCopyWithImpl(this._self, this._then);

  final _PendingCall _self;
  final $Res Function(_PendingCall) _then;

/// Create a copy of PendingCall
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? conversationId = null,Object? fromUserId = null,Object? fromUsername = null,Object? fromDisplayName = null,Object? fromAvatarUrl = null,Object? callType = null,Object? data = null,}) {
  return _then(_PendingCall(
conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,fromUserId: null == fromUserId ? _self.fromUserId : fromUserId // ignore: cast_nullable_to_non_nullable
as String,fromUsername: null == fromUsername ? _self.fromUsername : fromUsername // ignore: cast_nullable_to_non_nullable
as String,fromDisplayName: null == fromDisplayName ? _self.fromDisplayName : fromDisplayName // ignore: cast_nullable_to_non_nullable
as String,fromAvatarUrl: null == fromAvatarUrl ? _self.fromAvatarUrl : fromAvatarUrl // ignore: cast_nullable_to_non_nullable
as String,callType: null == callType ? _self.callType : callType // ignore: cast_nullable_to_non_nullable
as String,data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}


/// @nodoc
mixin _$SendMessagePayload {

 String get messageType; String? get body; String? get mediaUrl; String? get mediaMime; String? get fileName; String? get replyToId; Map<String, dynamic> get metadata;
/// Create a copy of SendMessagePayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SendMessagePayloadCopyWith<SendMessagePayload> get copyWith => _$SendMessagePayloadCopyWithImpl<SendMessagePayload>(this as SendMessagePayload, _$identity);

  /// Serializes this SendMessagePayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SendMessagePayload&&(identical(other.messageType, messageType) || other.messageType == messageType)&&(identical(other.body, body) || other.body == body)&&(identical(other.mediaUrl, mediaUrl) || other.mediaUrl == mediaUrl)&&(identical(other.mediaMime, mediaMime) || other.mediaMime == mediaMime)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.replyToId, replyToId) || other.replyToId == replyToId)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,messageType,body,mediaUrl,mediaMime,fileName,replyToId,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'SendMessagePayload(messageType: $messageType, body: $body, mediaUrl: $mediaUrl, mediaMime: $mediaMime, fileName: $fileName, replyToId: $replyToId, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $SendMessagePayloadCopyWith<$Res>  {
  factory $SendMessagePayloadCopyWith(SendMessagePayload value, $Res Function(SendMessagePayload) _then) = _$SendMessagePayloadCopyWithImpl;
@useResult
$Res call({
 String messageType, String? body, String? mediaUrl, String? mediaMime, String? fileName, String? replyToId, Map<String, dynamic> metadata
});




}
/// @nodoc
class _$SendMessagePayloadCopyWithImpl<$Res>
    implements $SendMessagePayloadCopyWith<$Res> {
  _$SendMessagePayloadCopyWithImpl(this._self, this._then);

  final SendMessagePayload _self;
  final $Res Function(SendMessagePayload) _then;

/// Create a copy of SendMessagePayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? messageType = null,Object? body = freezed,Object? mediaUrl = freezed,Object? mediaMime = freezed,Object? fileName = freezed,Object? replyToId = freezed,Object? metadata = null,}) {
  return _then(_self.copyWith(
messageType: null == messageType ? _self.messageType : messageType // ignore: cast_nullable_to_non_nullable
as String,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,mediaUrl: freezed == mediaUrl ? _self.mediaUrl : mediaUrl // ignore: cast_nullable_to_non_nullable
as String?,mediaMime: freezed == mediaMime ? _self.mediaMime : mediaMime // ignore: cast_nullable_to_non_nullable
as String?,fileName: freezed == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String?,replyToId: freezed == replyToId ? _self.replyToId : replyToId // ignore: cast_nullable_to_non_nullable
as String?,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [SendMessagePayload].
extension SendMessagePayloadPatterns on SendMessagePayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SendMessagePayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SendMessagePayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SendMessagePayload value)  $default,){
final _that = this;
switch (_that) {
case _SendMessagePayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SendMessagePayload value)?  $default,){
final _that = this;
switch (_that) {
case _SendMessagePayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String messageType,  String? body,  String? mediaUrl,  String? mediaMime,  String? fileName,  String? replyToId,  Map<String, dynamic> metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SendMessagePayload() when $default != null:
return $default(_that.messageType,_that.body,_that.mediaUrl,_that.mediaMime,_that.fileName,_that.replyToId,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String messageType,  String? body,  String? mediaUrl,  String? mediaMime,  String? fileName,  String? replyToId,  Map<String, dynamic> metadata)  $default,) {final _that = this;
switch (_that) {
case _SendMessagePayload():
return $default(_that.messageType,_that.body,_that.mediaUrl,_that.mediaMime,_that.fileName,_that.replyToId,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String messageType,  String? body,  String? mediaUrl,  String? mediaMime,  String? fileName,  String? replyToId,  Map<String, dynamic> metadata)?  $default,) {final _that = this;
switch (_that) {
case _SendMessagePayload() when $default != null:
return $default(_that.messageType,_that.body,_that.mediaUrl,_that.mediaMime,_that.fileName,_that.replyToId,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SendMessagePayload implements SendMessagePayload {
  const _SendMessagePayload({this.messageType = 'text', this.body, this.mediaUrl, this.mediaMime, this.fileName, this.replyToId, final  Map<String, dynamic> metadata = const <String, dynamic>{}}): _metadata = metadata;
  factory _SendMessagePayload.fromJson(Map<String, dynamic> json) => _$SendMessagePayloadFromJson(json);

@override@JsonKey() final  String messageType;
@override final  String? body;
@override final  String? mediaUrl;
@override final  String? mediaMime;
@override final  String? fileName;
@override final  String? replyToId;
 final  Map<String, dynamic> _metadata;
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}


/// Create a copy of SendMessagePayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SendMessagePayloadCopyWith<_SendMessagePayload> get copyWith => __$SendMessagePayloadCopyWithImpl<_SendMessagePayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SendMessagePayloadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SendMessagePayload&&(identical(other.messageType, messageType) || other.messageType == messageType)&&(identical(other.body, body) || other.body == body)&&(identical(other.mediaUrl, mediaUrl) || other.mediaUrl == mediaUrl)&&(identical(other.mediaMime, mediaMime) || other.mediaMime == mediaMime)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.replyToId, replyToId) || other.replyToId == replyToId)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,messageType,body,mediaUrl,mediaMime,fileName,replyToId,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'SendMessagePayload(messageType: $messageType, body: $body, mediaUrl: $mediaUrl, mediaMime: $mediaMime, fileName: $fileName, replyToId: $replyToId, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$SendMessagePayloadCopyWith<$Res> implements $SendMessagePayloadCopyWith<$Res> {
  factory _$SendMessagePayloadCopyWith(_SendMessagePayload value, $Res Function(_SendMessagePayload) _then) = __$SendMessagePayloadCopyWithImpl;
@override @useResult
$Res call({
 String messageType, String? body, String? mediaUrl, String? mediaMime, String? fileName, String? replyToId, Map<String, dynamic> metadata
});




}
/// @nodoc
class __$SendMessagePayloadCopyWithImpl<$Res>
    implements _$SendMessagePayloadCopyWith<$Res> {
  __$SendMessagePayloadCopyWithImpl(this._self, this._then);

  final _SendMessagePayload _self;
  final $Res Function(_SendMessagePayload) _then;

/// Create a copy of SendMessagePayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? messageType = null,Object? body = freezed,Object? mediaUrl = freezed,Object? mediaMime = freezed,Object? fileName = freezed,Object? replyToId = freezed,Object? metadata = null,}) {
  return _then(_SendMessagePayload(
messageType: null == messageType ? _self.messageType : messageType // ignore: cast_nullable_to_non_nullable
as String,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,mediaUrl: freezed == mediaUrl ? _self.mediaUrl : mediaUrl // ignore: cast_nullable_to_non_nullable
as String?,mediaMime: freezed == mediaMime ? _self.mediaMime : mediaMime // ignore: cast_nullable_to_non_nullable
as String?,fileName: freezed == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String?,replyToId: freezed == replyToId ? _self.replyToId : replyToId // ignore: cast_nullable_to_non_nullable
as String?,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}


/// @nodoc
mixin _$ForwardPayload {

 String get conversationId;
/// Create a copy of ForwardPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ForwardPayloadCopyWith<ForwardPayload> get copyWith => _$ForwardPayloadCopyWithImpl<ForwardPayload>(this as ForwardPayload, _$identity);

  /// Serializes this ForwardPayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ForwardPayload&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,conversationId);

@override
String toString() {
  return 'ForwardPayload(conversationId: $conversationId)';
}


}

/// @nodoc
abstract mixin class $ForwardPayloadCopyWith<$Res>  {
  factory $ForwardPayloadCopyWith(ForwardPayload value, $Res Function(ForwardPayload) _then) = _$ForwardPayloadCopyWithImpl;
@useResult
$Res call({
 String conversationId
});




}
/// @nodoc
class _$ForwardPayloadCopyWithImpl<$Res>
    implements $ForwardPayloadCopyWith<$Res> {
  _$ForwardPayloadCopyWithImpl(this._self, this._then);

  final ForwardPayload _self;
  final $Res Function(ForwardPayload) _then;

/// Create a copy of ForwardPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? conversationId = null,}) {
  return _then(_self.copyWith(
conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ForwardPayload].
extension ForwardPayloadPatterns on ForwardPayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ForwardPayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ForwardPayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ForwardPayload value)  $default,){
final _that = this;
switch (_that) {
case _ForwardPayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ForwardPayload value)?  $default,){
final _that = this;
switch (_that) {
case _ForwardPayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String conversationId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ForwardPayload() when $default != null:
return $default(_that.conversationId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String conversationId)  $default,) {final _that = this;
switch (_that) {
case _ForwardPayload():
return $default(_that.conversationId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String conversationId)?  $default,) {final _that = this;
switch (_that) {
case _ForwardPayload() when $default != null:
return $default(_that.conversationId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ForwardPayload implements ForwardPayload {
  const _ForwardPayload({required this.conversationId});
  factory _ForwardPayload.fromJson(Map<String, dynamic> json) => _$ForwardPayloadFromJson(json);

@override final  String conversationId;

/// Create a copy of ForwardPayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ForwardPayloadCopyWith<_ForwardPayload> get copyWith => __$ForwardPayloadCopyWithImpl<_ForwardPayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ForwardPayloadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ForwardPayload&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,conversationId);

@override
String toString() {
  return 'ForwardPayload(conversationId: $conversationId)';
}


}

/// @nodoc
abstract mixin class _$ForwardPayloadCopyWith<$Res> implements $ForwardPayloadCopyWith<$Res> {
  factory _$ForwardPayloadCopyWith(_ForwardPayload value, $Res Function(_ForwardPayload) _then) = __$ForwardPayloadCopyWithImpl;
@override @useResult
$Res call({
 String conversationId
});




}
/// @nodoc
class __$ForwardPayloadCopyWithImpl<$Res>
    implements _$ForwardPayloadCopyWith<$Res> {
  __$ForwardPayloadCopyWithImpl(this._self, this._then);

  final _ForwardPayload _self;
  final $Res Function(_ForwardPayload) _then;

/// Create a copy of ForwardPayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? conversationId = null,}) {
  return _then(_ForwardPayload(
conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$MessageReactionPayload {

 String get emoji;
/// Create a copy of MessageReactionPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageReactionPayloadCopyWith<MessageReactionPayload> get copyWith => _$MessageReactionPayloadCopyWithImpl<MessageReactionPayload>(this as MessageReactionPayload, _$identity);

  /// Serializes this MessageReactionPayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageReactionPayload&&(identical(other.emoji, emoji) || other.emoji == emoji));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,emoji);

@override
String toString() {
  return 'MessageReactionPayload(emoji: $emoji)';
}


}

/// @nodoc
abstract mixin class $MessageReactionPayloadCopyWith<$Res>  {
  factory $MessageReactionPayloadCopyWith(MessageReactionPayload value, $Res Function(MessageReactionPayload) _then) = _$MessageReactionPayloadCopyWithImpl;
@useResult
$Res call({
 String emoji
});




}
/// @nodoc
class _$MessageReactionPayloadCopyWithImpl<$Res>
    implements $MessageReactionPayloadCopyWith<$Res> {
  _$MessageReactionPayloadCopyWithImpl(this._self, this._then);

  final MessageReactionPayload _self;
  final $Res Function(MessageReactionPayload) _then;

/// Create a copy of MessageReactionPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? emoji = null,}) {
  return _then(_self.copyWith(
emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MessageReactionPayload].
extension MessageReactionPayloadPatterns on MessageReactionPayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageReactionPayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageReactionPayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageReactionPayload value)  $default,){
final _that = this;
switch (_that) {
case _MessageReactionPayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageReactionPayload value)?  $default,){
final _that = this;
switch (_that) {
case _MessageReactionPayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String emoji)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageReactionPayload() when $default != null:
return $default(_that.emoji);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String emoji)  $default,) {final _that = this;
switch (_that) {
case _MessageReactionPayload():
return $default(_that.emoji);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String emoji)?  $default,) {final _that = this;
switch (_that) {
case _MessageReactionPayload() when $default != null:
return $default(_that.emoji);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MessageReactionPayload implements MessageReactionPayload {
  const _MessageReactionPayload({required this.emoji});
  factory _MessageReactionPayload.fromJson(Map<String, dynamic> json) => _$MessageReactionPayloadFromJson(json);

@override final  String emoji;

/// Create a copy of MessageReactionPayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageReactionPayloadCopyWith<_MessageReactionPayload> get copyWith => __$MessageReactionPayloadCopyWithImpl<_MessageReactionPayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageReactionPayloadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageReactionPayload&&(identical(other.emoji, emoji) || other.emoji == emoji));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,emoji);

@override
String toString() {
  return 'MessageReactionPayload(emoji: $emoji)';
}


}

/// @nodoc
abstract mixin class _$MessageReactionPayloadCopyWith<$Res> implements $MessageReactionPayloadCopyWith<$Res> {
  factory _$MessageReactionPayloadCopyWith(_MessageReactionPayload value, $Res Function(_MessageReactionPayload) _then) = __$MessageReactionPayloadCopyWithImpl;
@override @useResult
$Res call({
 String emoji
});




}
/// @nodoc
class __$MessageReactionPayloadCopyWithImpl<$Res>
    implements _$MessageReactionPayloadCopyWith<$Res> {
  __$MessageReactionPayloadCopyWithImpl(this._self, this._then);

  final _MessageReactionPayload _self;
  final $Res Function(_MessageReactionPayload) _then;

/// Create a copy of MessageReactionPayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? emoji = null,}) {
  return _then(_MessageReactionPayload(
emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

ChatEvent _$ChatEventFromJson(
  Map<String, dynamic> json
) {
        switch (json['runtimeType']) {
                  case 'message':
          return ChatEventMessage.fromJson(
            json
          );
                case 'typingStart':
          return ChatEventTypingStart.fromJson(
            json
          );
                case 'typingStop':
          return ChatEventTypingStop.fromJson(
            json
          );
                case 'read':
          return ChatEventRead.fromJson(
            json
          );
                case 'react':
          return ChatEventReact.fromJson(
            json
          );
                case 'callOffer':
          return ChatEventCallOffer.fromJson(
            json
          );
                case 'callAnswer':
          return ChatEventCallAnswer.fromJson(
            json
          );
                case 'callIce':
          return ChatEventCallIce.fromJson(
            json
          );
                case 'callEnd':
          return ChatEventCallEnd.fromJson(
            json
          );
                case 'callDecline':
          return ChatEventCallDecline.fromJson(
            json
          );
                case 'callRinging':
          return ChatEventCallRinging.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'runtimeType',
  'ChatEvent',
  'Invalid union type "${json['runtimeType']}"!'
);
        }
      
}

/// @nodoc
mixin _$ChatEvent {



  /// Serializes this ChatEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatEvent);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatEvent()';
}


}

/// @nodoc
class $ChatEventCopyWith<$Res>  {
$ChatEventCopyWith(ChatEvent _, $Res Function(ChatEvent) __);
}


/// Adds pattern-matching-related methods to [ChatEvent].
extension ChatEventPatterns on ChatEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ChatEventMessage value)?  message,TResult Function( ChatEventTypingStart value)?  typingStart,TResult Function( ChatEventTypingStop value)?  typingStop,TResult Function( ChatEventRead value)?  read,TResult Function( ChatEventReact value)?  react,TResult Function( ChatEventCallOffer value)?  callOffer,TResult Function( ChatEventCallAnswer value)?  callAnswer,TResult Function( ChatEventCallIce value)?  callIce,TResult Function( ChatEventCallEnd value)?  callEnd,TResult Function( ChatEventCallDecline value)?  callDecline,TResult Function( ChatEventCallRinging value)?  callRinging,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ChatEventMessage() when message != null:
return message(_that);case ChatEventTypingStart() when typingStart != null:
return typingStart(_that);case ChatEventTypingStop() when typingStop != null:
return typingStop(_that);case ChatEventRead() when read != null:
return read(_that);case ChatEventReact() when react != null:
return react(_that);case ChatEventCallOffer() when callOffer != null:
return callOffer(_that);case ChatEventCallAnswer() when callAnswer != null:
return callAnswer(_that);case ChatEventCallIce() when callIce != null:
return callIce(_that);case ChatEventCallEnd() when callEnd != null:
return callEnd(_that);case ChatEventCallDecline() when callDecline != null:
return callDecline(_that);case ChatEventCallRinging() when callRinging != null:
return callRinging(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ChatEventMessage value)  message,required TResult Function( ChatEventTypingStart value)  typingStart,required TResult Function( ChatEventTypingStop value)  typingStop,required TResult Function( ChatEventRead value)  read,required TResult Function( ChatEventReact value)  react,required TResult Function( ChatEventCallOffer value)  callOffer,required TResult Function( ChatEventCallAnswer value)  callAnswer,required TResult Function( ChatEventCallIce value)  callIce,required TResult Function( ChatEventCallEnd value)  callEnd,required TResult Function( ChatEventCallDecline value)  callDecline,required TResult Function( ChatEventCallRinging value)  callRinging,}){
final _that = this;
switch (_that) {
case ChatEventMessage():
return message(_that);case ChatEventTypingStart():
return typingStart(_that);case ChatEventTypingStop():
return typingStop(_that);case ChatEventRead():
return read(_that);case ChatEventReact():
return react(_that);case ChatEventCallOffer():
return callOffer(_that);case ChatEventCallAnswer():
return callAnswer(_that);case ChatEventCallIce():
return callIce(_that);case ChatEventCallEnd():
return callEnd(_that);case ChatEventCallDecline():
return callDecline(_that);case ChatEventCallRinging():
return callRinging(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ChatEventMessage value)?  message,TResult? Function( ChatEventTypingStart value)?  typingStart,TResult? Function( ChatEventTypingStop value)?  typingStop,TResult? Function( ChatEventRead value)?  read,TResult? Function( ChatEventReact value)?  react,TResult? Function( ChatEventCallOffer value)?  callOffer,TResult? Function( ChatEventCallAnswer value)?  callAnswer,TResult? Function( ChatEventCallIce value)?  callIce,TResult? Function( ChatEventCallEnd value)?  callEnd,TResult? Function( ChatEventCallDecline value)?  callDecline,TResult? Function( ChatEventCallRinging value)?  callRinging,}){
final _that = this;
switch (_that) {
case ChatEventMessage() when message != null:
return message(_that);case ChatEventTypingStart() when typingStart != null:
return typingStart(_that);case ChatEventTypingStop() when typingStop != null:
return typingStop(_that);case ChatEventRead() when read != null:
return read(_that);case ChatEventReact() when react != null:
return react(_that);case ChatEventCallOffer() when callOffer != null:
return callOffer(_that);case ChatEventCallAnswer() when callAnswer != null:
return callAnswer(_that);case ChatEventCallIce() when callIce != null:
return callIce(_that);case ChatEventCallEnd() when callEnd != null:
return callEnd(_that);case ChatEventCallDecline() when callDecline != null:
return callDecline(_that);case ChatEventCallRinging() when callRinging != null:
return callRinging(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( Map<String, dynamic> data)?  message,TResult Function( String userId,  String username,  String displayName,  String avatarUrl)?  typingStart,TResult Function( String userId,  String username)?  typingStop,TResult Function( String conversationId,  String readerId,  String? messageId,  int count)?  read,TResult Function( String conversationId,  String messageId,  Map<String, int> reactions)?  react,TResult Function( String callType,  Map<String, dynamic> data)?  callOffer,TResult Function( String callType,  Map<String, dynamic> data)?  callAnswer,TResult Function( Map<String, dynamic> data)?  callIce,TResult Function()?  callEnd,TResult Function()?  callDecline,TResult Function( Map<String, dynamic> data)?  callRinging,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ChatEventMessage() when message != null:
return message(_that.data);case ChatEventTypingStart() when typingStart != null:
return typingStart(_that.userId,_that.username,_that.displayName,_that.avatarUrl);case ChatEventTypingStop() when typingStop != null:
return typingStop(_that.userId,_that.username);case ChatEventRead() when read != null:
return read(_that.conversationId,_that.readerId,_that.messageId,_that.count);case ChatEventReact() when react != null:
return react(_that.conversationId,_that.messageId,_that.reactions);case ChatEventCallOffer() when callOffer != null:
return callOffer(_that.callType,_that.data);case ChatEventCallAnswer() when callAnswer != null:
return callAnswer(_that.callType,_that.data);case ChatEventCallIce() when callIce != null:
return callIce(_that.data);case ChatEventCallEnd() when callEnd != null:
return callEnd();case ChatEventCallDecline() when callDecline != null:
return callDecline();case ChatEventCallRinging() when callRinging != null:
return callRinging(_that.data);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( Map<String, dynamic> data)  message,required TResult Function( String userId,  String username,  String displayName,  String avatarUrl)  typingStart,required TResult Function( String userId,  String username)  typingStop,required TResult Function( String conversationId,  String readerId,  String? messageId,  int count)  read,required TResult Function( String conversationId,  String messageId,  Map<String, int> reactions)  react,required TResult Function( String callType,  Map<String, dynamic> data)  callOffer,required TResult Function( String callType,  Map<String, dynamic> data)  callAnswer,required TResult Function( Map<String, dynamic> data)  callIce,required TResult Function()  callEnd,required TResult Function()  callDecline,required TResult Function( Map<String, dynamic> data)  callRinging,}) {final _that = this;
switch (_that) {
case ChatEventMessage():
return message(_that.data);case ChatEventTypingStart():
return typingStart(_that.userId,_that.username,_that.displayName,_that.avatarUrl);case ChatEventTypingStop():
return typingStop(_that.userId,_that.username);case ChatEventRead():
return read(_that.conversationId,_that.readerId,_that.messageId,_that.count);case ChatEventReact():
return react(_that.conversationId,_that.messageId,_that.reactions);case ChatEventCallOffer():
return callOffer(_that.callType,_that.data);case ChatEventCallAnswer():
return callAnswer(_that.callType,_that.data);case ChatEventCallIce():
return callIce(_that.data);case ChatEventCallEnd():
return callEnd();case ChatEventCallDecline():
return callDecline();case ChatEventCallRinging():
return callRinging(_that.data);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( Map<String, dynamic> data)?  message,TResult? Function( String userId,  String username,  String displayName,  String avatarUrl)?  typingStart,TResult? Function( String userId,  String username)?  typingStop,TResult? Function( String conversationId,  String readerId,  String? messageId,  int count)?  read,TResult? Function( String conversationId,  String messageId,  Map<String, int> reactions)?  react,TResult? Function( String callType,  Map<String, dynamic> data)?  callOffer,TResult? Function( String callType,  Map<String, dynamic> data)?  callAnswer,TResult? Function( Map<String, dynamic> data)?  callIce,TResult? Function()?  callEnd,TResult? Function()?  callDecline,TResult? Function( Map<String, dynamic> data)?  callRinging,}) {final _that = this;
switch (_that) {
case ChatEventMessage() when message != null:
return message(_that.data);case ChatEventTypingStart() when typingStart != null:
return typingStart(_that.userId,_that.username,_that.displayName,_that.avatarUrl);case ChatEventTypingStop() when typingStop != null:
return typingStop(_that.userId,_that.username);case ChatEventRead() when read != null:
return read(_that.conversationId,_that.readerId,_that.messageId,_that.count);case ChatEventReact() when react != null:
return react(_that.conversationId,_that.messageId,_that.reactions);case ChatEventCallOffer() when callOffer != null:
return callOffer(_that.callType,_that.data);case ChatEventCallAnswer() when callAnswer != null:
return callAnswer(_that.callType,_that.data);case ChatEventCallIce() when callIce != null:
return callIce(_that.data);case ChatEventCallEnd() when callEnd != null:
return callEnd();case ChatEventCallDecline() when callDecline != null:
return callDecline();case ChatEventCallRinging() when callRinging != null:
return callRinging(_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class ChatEventMessage implements ChatEvent {
  const ChatEventMessage({required final  Map<String, dynamic> data, final  String? $type}): _data = data,$type = $type ?? 'message';
  factory ChatEventMessage.fromJson(Map<String, dynamic> json) => _$ChatEventMessageFromJson(json);

 final  Map<String, dynamic> _data;
 Map<String, dynamic> get data {
  if (_data is EqualUnmodifiableMapView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_data);
}


@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of ChatEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatEventMessageCopyWith<ChatEventMessage> get copyWith => _$ChatEventMessageCopyWithImpl<ChatEventMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatEventMessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatEventMessage&&const DeepCollectionEquality().equals(other._data, _data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_data));

@override
String toString() {
  return 'ChatEvent.message(data: $data)';
}


}

/// @nodoc
abstract mixin class $ChatEventMessageCopyWith<$Res> implements $ChatEventCopyWith<$Res> {
  factory $ChatEventMessageCopyWith(ChatEventMessage value, $Res Function(ChatEventMessage) _then) = _$ChatEventMessageCopyWithImpl;
@useResult
$Res call({
 Map<String, dynamic> data
});




}
/// @nodoc
class _$ChatEventMessageCopyWithImpl<$Res>
    implements $ChatEventMessageCopyWith<$Res> {
  _$ChatEventMessageCopyWithImpl(this._self, this._then);

  final ChatEventMessage _self;
  final $Res Function(ChatEventMessage) _then;

/// Create a copy of ChatEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(ChatEventMessage(
data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

/// @nodoc
@JsonSerializable()

class ChatEventTypingStart implements ChatEvent {
  const ChatEventTypingStart({required this.userId, required this.username, required this.displayName, required this.avatarUrl, final  String? $type}): $type = $type ?? 'typingStart';
  factory ChatEventTypingStart.fromJson(Map<String, dynamic> json) => _$ChatEventTypingStartFromJson(json);

 final  String userId;
 final  String username;
 final  String displayName;
 final  String avatarUrl;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of ChatEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatEventTypingStartCopyWith<ChatEventTypingStart> get copyWith => _$ChatEventTypingStartCopyWithImpl<ChatEventTypingStart>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatEventTypingStartToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatEventTypingStart&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username,displayName,avatarUrl);

@override
String toString() {
  return 'ChatEvent.typingStart(userId: $userId, username: $username, displayName: $displayName, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class $ChatEventTypingStartCopyWith<$Res> implements $ChatEventCopyWith<$Res> {
  factory $ChatEventTypingStartCopyWith(ChatEventTypingStart value, $Res Function(ChatEventTypingStart) _then) = _$ChatEventTypingStartCopyWithImpl;
@useResult
$Res call({
 String userId, String username, String displayName, String avatarUrl
});




}
/// @nodoc
class _$ChatEventTypingStartCopyWithImpl<$Res>
    implements $ChatEventTypingStartCopyWith<$Res> {
  _$ChatEventTypingStartCopyWithImpl(this._self, this._then);

  final ChatEventTypingStart _self;
  final $Res Function(ChatEventTypingStart) _then;

/// Create a copy of ChatEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? username = null,Object? displayName = null,Object? avatarUrl = null,}) {
  return _then(ChatEventTypingStart(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class ChatEventTypingStop implements ChatEvent {
  const ChatEventTypingStop({required this.userId, required this.username, final  String? $type}): $type = $type ?? 'typingStop';
  factory ChatEventTypingStop.fromJson(Map<String, dynamic> json) => _$ChatEventTypingStopFromJson(json);

 final  String userId;
 final  String username;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of ChatEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatEventTypingStopCopyWith<ChatEventTypingStop> get copyWith => _$ChatEventTypingStopCopyWithImpl<ChatEventTypingStop>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatEventTypingStopToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatEventTypingStop&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username);

@override
String toString() {
  return 'ChatEvent.typingStop(userId: $userId, username: $username)';
}


}

/// @nodoc
abstract mixin class $ChatEventTypingStopCopyWith<$Res> implements $ChatEventCopyWith<$Res> {
  factory $ChatEventTypingStopCopyWith(ChatEventTypingStop value, $Res Function(ChatEventTypingStop) _then) = _$ChatEventTypingStopCopyWithImpl;
@useResult
$Res call({
 String userId, String username
});




}
/// @nodoc
class _$ChatEventTypingStopCopyWithImpl<$Res>
    implements $ChatEventTypingStopCopyWith<$Res> {
  _$ChatEventTypingStopCopyWithImpl(this._self, this._then);

  final ChatEventTypingStop _self;
  final $Res Function(ChatEventTypingStop) _then;

/// Create a copy of ChatEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? username = null,}) {
  return _then(ChatEventTypingStop(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class ChatEventRead implements ChatEvent {
  const ChatEventRead({required this.conversationId, required this.readerId, this.messageId, this.count = 0, final  String? $type}): $type = $type ?? 'read';
  factory ChatEventRead.fromJson(Map<String, dynamic> json) => _$ChatEventReadFromJson(json);

 final  String conversationId;
 final  String readerId;
 final  String? messageId;
@JsonKey() final  int count;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of ChatEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatEventReadCopyWith<ChatEventRead> get copyWith => _$ChatEventReadCopyWithImpl<ChatEventRead>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatEventReadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatEventRead&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.readerId, readerId) || other.readerId == readerId)&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,conversationId,readerId,messageId,count);

@override
String toString() {
  return 'ChatEvent.read(conversationId: $conversationId, readerId: $readerId, messageId: $messageId, count: $count)';
}


}

/// @nodoc
abstract mixin class $ChatEventReadCopyWith<$Res> implements $ChatEventCopyWith<$Res> {
  factory $ChatEventReadCopyWith(ChatEventRead value, $Res Function(ChatEventRead) _then) = _$ChatEventReadCopyWithImpl;
@useResult
$Res call({
 String conversationId, String readerId, String? messageId, int count
});




}
/// @nodoc
class _$ChatEventReadCopyWithImpl<$Res>
    implements $ChatEventReadCopyWith<$Res> {
  _$ChatEventReadCopyWithImpl(this._self, this._then);

  final ChatEventRead _self;
  final $Res Function(ChatEventRead) _then;

/// Create a copy of ChatEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? conversationId = null,Object? readerId = null,Object? messageId = freezed,Object? count = null,}) {
  return _then(ChatEventRead(
conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,readerId: null == readerId ? _self.readerId : readerId // ignore: cast_nullable_to_non_nullable
as String,messageId: freezed == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as String?,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
@JsonSerializable()

class ChatEventReact implements ChatEvent {
  const ChatEventReact({required this.conversationId, required this.messageId, final  Map<String, int> reactions = const <String, int>{}, final  String? $type}): _reactions = reactions,$type = $type ?? 'react';
  factory ChatEventReact.fromJson(Map<String, dynamic> json) => _$ChatEventReactFromJson(json);

 final  String conversationId;
 final  String messageId;
 final  Map<String, int> _reactions;
@JsonKey() Map<String, int> get reactions {
  if (_reactions is EqualUnmodifiableMapView) return _reactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_reactions);
}


@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of ChatEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatEventReactCopyWith<ChatEventReact> get copyWith => _$ChatEventReactCopyWithImpl<ChatEventReact>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatEventReactToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatEventReact&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.messageId, messageId) || other.messageId == messageId)&&const DeepCollectionEquality().equals(other._reactions, _reactions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,conversationId,messageId,const DeepCollectionEquality().hash(_reactions));

@override
String toString() {
  return 'ChatEvent.react(conversationId: $conversationId, messageId: $messageId, reactions: $reactions)';
}


}

/// @nodoc
abstract mixin class $ChatEventReactCopyWith<$Res> implements $ChatEventCopyWith<$Res> {
  factory $ChatEventReactCopyWith(ChatEventReact value, $Res Function(ChatEventReact) _then) = _$ChatEventReactCopyWithImpl;
@useResult
$Res call({
 String conversationId, String messageId, Map<String, int> reactions
});




}
/// @nodoc
class _$ChatEventReactCopyWithImpl<$Res>
    implements $ChatEventReactCopyWith<$Res> {
  _$ChatEventReactCopyWithImpl(this._self, this._then);

  final ChatEventReact _self;
  final $Res Function(ChatEventReact) _then;

/// Create a copy of ChatEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? conversationId = null,Object? messageId = null,Object? reactions = null,}) {
  return _then(ChatEventReact(
conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as String,reactions: null == reactions ? _self._reactions : reactions // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}


}

/// @nodoc
@JsonSerializable()

class ChatEventCallOffer implements ChatEvent {
  const ChatEventCallOffer({required this.callType, required final  Map<String, dynamic> data, final  String? $type}): _data = data,$type = $type ?? 'callOffer';
  factory ChatEventCallOffer.fromJson(Map<String, dynamic> json) => _$ChatEventCallOfferFromJson(json);

 final  String callType;
 final  Map<String, dynamic> _data;
 Map<String, dynamic> get data {
  if (_data is EqualUnmodifiableMapView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_data);
}


@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of ChatEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatEventCallOfferCopyWith<ChatEventCallOffer> get copyWith => _$ChatEventCallOfferCopyWithImpl<ChatEventCallOffer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatEventCallOfferToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatEventCallOffer&&(identical(other.callType, callType) || other.callType == callType)&&const DeepCollectionEquality().equals(other._data, _data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,callType,const DeepCollectionEquality().hash(_data));

@override
String toString() {
  return 'ChatEvent.callOffer(callType: $callType, data: $data)';
}


}

/// @nodoc
abstract mixin class $ChatEventCallOfferCopyWith<$Res> implements $ChatEventCopyWith<$Res> {
  factory $ChatEventCallOfferCopyWith(ChatEventCallOffer value, $Res Function(ChatEventCallOffer) _then) = _$ChatEventCallOfferCopyWithImpl;
@useResult
$Res call({
 String callType, Map<String, dynamic> data
});




}
/// @nodoc
class _$ChatEventCallOfferCopyWithImpl<$Res>
    implements $ChatEventCallOfferCopyWith<$Res> {
  _$ChatEventCallOfferCopyWithImpl(this._self, this._then);

  final ChatEventCallOffer _self;
  final $Res Function(ChatEventCallOffer) _then;

/// Create a copy of ChatEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? callType = null,Object? data = null,}) {
  return _then(ChatEventCallOffer(
callType: null == callType ? _self.callType : callType // ignore: cast_nullable_to_non_nullable
as String,data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

/// @nodoc
@JsonSerializable()

class ChatEventCallAnswer implements ChatEvent {
  const ChatEventCallAnswer({required this.callType, required final  Map<String, dynamic> data, final  String? $type}): _data = data,$type = $type ?? 'callAnswer';
  factory ChatEventCallAnswer.fromJson(Map<String, dynamic> json) => _$ChatEventCallAnswerFromJson(json);

 final  String callType;
 final  Map<String, dynamic> _data;
 Map<String, dynamic> get data {
  if (_data is EqualUnmodifiableMapView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_data);
}


@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of ChatEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatEventCallAnswerCopyWith<ChatEventCallAnswer> get copyWith => _$ChatEventCallAnswerCopyWithImpl<ChatEventCallAnswer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatEventCallAnswerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatEventCallAnswer&&(identical(other.callType, callType) || other.callType == callType)&&const DeepCollectionEquality().equals(other._data, _data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,callType,const DeepCollectionEquality().hash(_data));

@override
String toString() {
  return 'ChatEvent.callAnswer(callType: $callType, data: $data)';
}


}

/// @nodoc
abstract mixin class $ChatEventCallAnswerCopyWith<$Res> implements $ChatEventCopyWith<$Res> {
  factory $ChatEventCallAnswerCopyWith(ChatEventCallAnswer value, $Res Function(ChatEventCallAnswer) _then) = _$ChatEventCallAnswerCopyWithImpl;
@useResult
$Res call({
 String callType, Map<String, dynamic> data
});




}
/// @nodoc
class _$ChatEventCallAnswerCopyWithImpl<$Res>
    implements $ChatEventCallAnswerCopyWith<$Res> {
  _$ChatEventCallAnswerCopyWithImpl(this._self, this._then);

  final ChatEventCallAnswer _self;
  final $Res Function(ChatEventCallAnswer) _then;

/// Create a copy of ChatEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? callType = null,Object? data = null,}) {
  return _then(ChatEventCallAnswer(
callType: null == callType ? _self.callType : callType // ignore: cast_nullable_to_non_nullable
as String,data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

/// @nodoc
@JsonSerializable()

class ChatEventCallIce implements ChatEvent {
  const ChatEventCallIce({required final  Map<String, dynamic> data, final  String? $type}): _data = data,$type = $type ?? 'callIce';
  factory ChatEventCallIce.fromJson(Map<String, dynamic> json) => _$ChatEventCallIceFromJson(json);

 final  Map<String, dynamic> _data;
 Map<String, dynamic> get data {
  if (_data is EqualUnmodifiableMapView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_data);
}


@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of ChatEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatEventCallIceCopyWith<ChatEventCallIce> get copyWith => _$ChatEventCallIceCopyWithImpl<ChatEventCallIce>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatEventCallIceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatEventCallIce&&const DeepCollectionEquality().equals(other._data, _data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_data));

@override
String toString() {
  return 'ChatEvent.callIce(data: $data)';
}


}

/// @nodoc
abstract mixin class $ChatEventCallIceCopyWith<$Res> implements $ChatEventCopyWith<$Res> {
  factory $ChatEventCallIceCopyWith(ChatEventCallIce value, $Res Function(ChatEventCallIce) _then) = _$ChatEventCallIceCopyWithImpl;
@useResult
$Res call({
 Map<String, dynamic> data
});




}
/// @nodoc
class _$ChatEventCallIceCopyWithImpl<$Res>
    implements $ChatEventCallIceCopyWith<$Res> {
  _$ChatEventCallIceCopyWithImpl(this._self, this._then);

  final ChatEventCallIce _self;
  final $Res Function(ChatEventCallIce) _then;

/// Create a copy of ChatEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(ChatEventCallIce(
data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

/// @nodoc
@JsonSerializable()

class ChatEventCallEnd implements ChatEvent {
  const ChatEventCallEnd({final  String? $type}): $type = $type ?? 'callEnd';
  factory ChatEventCallEnd.fromJson(Map<String, dynamic> json) => _$ChatEventCallEndFromJson(json);



@JsonKey(name: 'runtimeType')
final String $type;



@override
Map<String, dynamic> toJson() {
  return _$ChatEventCallEndToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatEventCallEnd);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatEvent.callEnd()';
}


}




/// @nodoc
@JsonSerializable()

class ChatEventCallDecline implements ChatEvent {
  const ChatEventCallDecline({final  String? $type}): $type = $type ?? 'callDecline';
  factory ChatEventCallDecline.fromJson(Map<String, dynamic> json) => _$ChatEventCallDeclineFromJson(json);



@JsonKey(name: 'runtimeType')
final String $type;



@override
Map<String, dynamic> toJson() {
  return _$ChatEventCallDeclineToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatEventCallDecline);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatEvent.callDecline()';
}


}




/// @nodoc
@JsonSerializable()

class ChatEventCallRinging implements ChatEvent {
  const ChatEventCallRinging({required final  Map<String, dynamic> data, final  String? $type}): _data = data,$type = $type ?? 'callRinging';
  factory ChatEventCallRinging.fromJson(Map<String, dynamic> json) => _$ChatEventCallRingingFromJson(json);

 final  Map<String, dynamic> _data;
 Map<String, dynamic> get data {
  if (_data is EqualUnmodifiableMapView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_data);
}


@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of ChatEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatEventCallRingingCopyWith<ChatEventCallRinging> get copyWith => _$ChatEventCallRingingCopyWithImpl<ChatEventCallRinging>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatEventCallRingingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatEventCallRinging&&const DeepCollectionEquality().equals(other._data, _data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_data));

@override
String toString() {
  return 'ChatEvent.callRinging(data: $data)';
}


}

/// @nodoc
abstract mixin class $ChatEventCallRingingCopyWith<$Res> implements $ChatEventCopyWith<$Res> {
  factory $ChatEventCallRingingCopyWith(ChatEventCallRinging value, $Res Function(ChatEventCallRinging) _then) = _$ChatEventCallRingingCopyWithImpl;
@useResult
$Res call({
 Map<String, dynamic> data
});




}
/// @nodoc
class _$ChatEventCallRingingCopyWithImpl<$Res>
    implements $ChatEventCallRingingCopyWith<$Res> {
  _$ChatEventCallRingingCopyWithImpl(this._self, this._then);

  final ChatEventCallRinging _self;
  final $Res Function(ChatEventCallRinging) _then;

/// Create a copy of ChatEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(ChatEventCallRinging(
data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
