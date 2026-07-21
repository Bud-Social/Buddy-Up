// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'live.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AgoraCredentials {

 String get appId; String get channel; String? get token;
/// Create a copy of AgoraCredentials
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AgoraCredentialsCopyWith<AgoraCredentials> get copyWith => _$AgoraCredentialsCopyWithImpl<AgoraCredentials>(this as AgoraCredentials, _$identity);

  /// Serializes this AgoraCredentials to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AgoraCredentials&&(identical(other.appId, appId) || other.appId == appId)&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.token, token) || other.token == token));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,appId,channel,token);

@override
String toString() {
  return 'AgoraCredentials(appId: $appId, channel: $channel, token: $token)';
}


}

/// @nodoc
abstract mixin class $AgoraCredentialsCopyWith<$Res>  {
  factory $AgoraCredentialsCopyWith(AgoraCredentials value, $Res Function(AgoraCredentials) _then) = _$AgoraCredentialsCopyWithImpl;
@useResult
$Res call({
 String appId, String channel, String? token
});




}
/// @nodoc
class _$AgoraCredentialsCopyWithImpl<$Res>
    implements $AgoraCredentialsCopyWith<$Res> {
  _$AgoraCredentialsCopyWithImpl(this._self, this._then);

  final AgoraCredentials _self;
  final $Res Function(AgoraCredentials) _then;

/// Create a copy of AgoraCredentials
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? appId = null,Object? channel = null,Object? token = freezed,}) {
  return _then(_self.copyWith(
appId: null == appId ? _self.appId : appId // ignore: cast_nullable_to_non_nullable
as String,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as String,token: freezed == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AgoraCredentials].
extension AgoraCredentialsPatterns on AgoraCredentials {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AgoraCredentials value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AgoraCredentials() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AgoraCredentials value)  $default,){
final _that = this;
switch (_that) {
case _AgoraCredentials():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AgoraCredentials value)?  $default,){
final _that = this;
switch (_that) {
case _AgoraCredentials() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String appId,  String channel,  String? token)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AgoraCredentials() when $default != null:
return $default(_that.appId,_that.channel,_that.token);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String appId,  String channel,  String? token)  $default,) {final _that = this;
switch (_that) {
case _AgoraCredentials():
return $default(_that.appId,_that.channel,_that.token);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String appId,  String channel,  String? token)?  $default,) {final _that = this;
switch (_that) {
case _AgoraCredentials() when $default != null:
return $default(_that.appId,_that.channel,_that.token);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AgoraCredentials implements AgoraCredentials {
  const _AgoraCredentials({required this.appId, required this.channel, this.token});
  factory _AgoraCredentials.fromJson(Map<String, dynamic> json) => _$AgoraCredentialsFromJson(json);

@override final  String appId;
@override final  String channel;
@override final  String? token;

/// Create a copy of AgoraCredentials
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AgoraCredentialsCopyWith<_AgoraCredentials> get copyWith => __$AgoraCredentialsCopyWithImpl<_AgoraCredentials>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AgoraCredentialsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AgoraCredentials&&(identical(other.appId, appId) || other.appId == appId)&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.token, token) || other.token == token));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,appId,channel,token);

@override
String toString() {
  return 'AgoraCredentials(appId: $appId, channel: $channel, token: $token)';
}


}

/// @nodoc
abstract mixin class _$AgoraCredentialsCopyWith<$Res> implements $AgoraCredentialsCopyWith<$Res> {
  factory _$AgoraCredentialsCopyWith(_AgoraCredentials value, $Res Function(_AgoraCredentials) _then) = __$AgoraCredentialsCopyWithImpl;
@override @useResult
$Res call({
 String appId, String channel, String? token
});




}
/// @nodoc
class __$AgoraCredentialsCopyWithImpl<$Res>
    implements _$AgoraCredentialsCopyWith<$Res> {
  __$AgoraCredentialsCopyWithImpl(this._self, this._then);

  final _AgoraCredentials _self;
  final $Res Function(_AgoraCredentials) _then;

/// Create a copy of AgoraCredentials
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? appId = null,Object? channel = null,Object? token = freezed,}) {
  return _then(_AgoraCredentials(
appId: null == appId ? _self.appId : appId // ignore: cast_nullable_to_non_nullable
as String,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as String,token: freezed == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$LiveKitCredentials {

 String get url; String get room; String get token; bool get canPublish;
/// Create a copy of LiveKitCredentials
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LiveKitCredentialsCopyWith<LiveKitCredentials> get copyWith => _$LiveKitCredentialsCopyWithImpl<LiveKitCredentials>(this as LiveKitCredentials, _$identity);

  /// Serializes this LiveKitCredentials to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LiveKitCredentials&&(identical(other.url, url) || other.url == url)&&(identical(other.room, room) || other.room == room)&&(identical(other.token, token) || other.token == token)&&(identical(other.canPublish, canPublish) || other.canPublish == canPublish));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,room,token,canPublish);

@override
String toString() {
  return 'LiveKitCredentials(url: $url, room: $room, token: $token, canPublish: $canPublish)';
}


}

/// @nodoc
abstract mixin class $LiveKitCredentialsCopyWith<$Res>  {
  factory $LiveKitCredentialsCopyWith(LiveKitCredentials value, $Res Function(LiveKitCredentials) _then) = _$LiveKitCredentialsCopyWithImpl;
@useResult
$Res call({
 String url, String room, String token, bool canPublish
});




}
/// @nodoc
class _$LiveKitCredentialsCopyWithImpl<$Res>
    implements $LiveKitCredentialsCopyWith<$Res> {
  _$LiveKitCredentialsCopyWithImpl(this._self, this._then);

  final LiveKitCredentials _self;
  final $Res Function(LiveKitCredentials) _then;

/// Create a copy of LiveKitCredentials
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? room = null,Object? token = null,Object? canPublish = null,}) {
  return _then(_self.copyWith(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,room: null == room ? _self.room : room // ignore: cast_nullable_to_non_nullable
as String,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,canPublish: null == canPublish ? _self.canPublish : canPublish // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LiveKitCredentials].
extension LiveKitCredentialsPatterns on LiveKitCredentials {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LiveKitCredentials value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LiveKitCredentials() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LiveKitCredentials value)  $default,){
final _that = this;
switch (_that) {
case _LiveKitCredentials():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LiveKitCredentials value)?  $default,){
final _that = this;
switch (_that) {
case _LiveKitCredentials() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  String room,  String token,  bool canPublish)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LiveKitCredentials() when $default != null:
return $default(_that.url,_that.room,_that.token,_that.canPublish);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  String room,  String token,  bool canPublish)  $default,) {final _that = this;
switch (_that) {
case _LiveKitCredentials():
return $default(_that.url,_that.room,_that.token,_that.canPublish);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  String room,  String token,  bool canPublish)?  $default,) {final _that = this;
switch (_that) {
case _LiveKitCredentials() when $default != null:
return $default(_that.url,_that.room,_that.token,_that.canPublish);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LiveKitCredentials implements LiveKitCredentials {
  const _LiveKitCredentials({required this.url, required this.room, required this.token, this.canPublish = true});
  factory _LiveKitCredentials.fromJson(Map<String, dynamic> json) => _$LiveKitCredentialsFromJson(json);

@override final  String url;
@override final  String room;
@override final  String token;
@override@JsonKey() final  bool canPublish;

/// Create a copy of LiveKitCredentials
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LiveKitCredentialsCopyWith<_LiveKitCredentials> get copyWith => __$LiveKitCredentialsCopyWithImpl<_LiveKitCredentials>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LiveKitCredentialsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LiveKitCredentials&&(identical(other.url, url) || other.url == url)&&(identical(other.room, room) || other.room == room)&&(identical(other.token, token) || other.token == token)&&(identical(other.canPublish, canPublish) || other.canPublish == canPublish));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,room,token,canPublish);

@override
String toString() {
  return 'LiveKitCredentials(url: $url, room: $room, token: $token, canPublish: $canPublish)';
}


}

/// @nodoc
abstract mixin class _$LiveKitCredentialsCopyWith<$Res> implements $LiveKitCredentialsCopyWith<$Res> {
  factory _$LiveKitCredentialsCopyWith(_LiveKitCredentials value, $Res Function(_LiveKitCredentials) _then) = __$LiveKitCredentialsCopyWithImpl;
@override @useResult
$Res call({
 String url, String room, String token, bool canPublish
});




}
/// @nodoc
class __$LiveKitCredentialsCopyWithImpl<$Res>
    implements _$LiveKitCredentialsCopyWith<$Res> {
  __$LiveKitCredentialsCopyWithImpl(this._self, this._then);

  final _LiveKitCredentials _self;
  final $Res Function(_LiveKitCredentials) _then;

/// Create a copy of LiveKitCredentials
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? room = null,Object? token = null,Object? canPublish = null,}) {
  return _then(_LiveKitCredentials(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,room: null == room ? _self.room : room // ignore: cast_nullable_to_non_nullable
as String,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,canPublish: null == canPublish ? _self.canPublish : canPublish // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$LiveCredentials {

 AgoraCredentials get agora; LiveKitCredentials get livekit;
/// Create a copy of LiveCredentials
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LiveCredentialsCopyWith<LiveCredentials> get copyWith => _$LiveCredentialsCopyWithImpl<LiveCredentials>(this as LiveCredentials, _$identity);

  /// Serializes this LiveCredentials to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LiveCredentials&&(identical(other.agora, agora) || other.agora == agora)&&(identical(other.livekit, livekit) || other.livekit == livekit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,agora,livekit);

@override
String toString() {
  return 'LiveCredentials(agora: $agora, livekit: $livekit)';
}


}

/// @nodoc
abstract mixin class $LiveCredentialsCopyWith<$Res>  {
  factory $LiveCredentialsCopyWith(LiveCredentials value, $Res Function(LiveCredentials) _then) = _$LiveCredentialsCopyWithImpl;
@useResult
$Res call({
 AgoraCredentials agora, LiveKitCredentials livekit
});


$AgoraCredentialsCopyWith<$Res> get agora;$LiveKitCredentialsCopyWith<$Res> get livekit;

}
/// @nodoc
class _$LiveCredentialsCopyWithImpl<$Res>
    implements $LiveCredentialsCopyWith<$Res> {
  _$LiveCredentialsCopyWithImpl(this._self, this._then);

  final LiveCredentials _self;
  final $Res Function(LiveCredentials) _then;

/// Create a copy of LiveCredentials
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? agora = null,Object? livekit = null,}) {
  return _then(_self.copyWith(
agora: null == agora ? _self.agora : agora // ignore: cast_nullable_to_non_nullable
as AgoraCredentials,livekit: null == livekit ? _self.livekit : livekit // ignore: cast_nullable_to_non_nullable
as LiveKitCredentials,
  ));
}
/// Create a copy of LiveCredentials
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AgoraCredentialsCopyWith<$Res> get agora {
  
  return $AgoraCredentialsCopyWith<$Res>(_self.agora, (value) {
    return _then(_self.copyWith(agora: value));
  });
}/// Create a copy of LiveCredentials
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LiveKitCredentialsCopyWith<$Res> get livekit {
  
  return $LiveKitCredentialsCopyWith<$Res>(_self.livekit, (value) {
    return _then(_self.copyWith(livekit: value));
  });
}
}


/// Adds pattern-matching-related methods to [LiveCredentials].
extension LiveCredentialsPatterns on LiveCredentials {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LiveCredentials value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LiveCredentials() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LiveCredentials value)  $default,){
final _that = this;
switch (_that) {
case _LiveCredentials():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LiveCredentials value)?  $default,){
final _that = this;
switch (_that) {
case _LiveCredentials() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AgoraCredentials agora,  LiveKitCredentials livekit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LiveCredentials() when $default != null:
return $default(_that.agora,_that.livekit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AgoraCredentials agora,  LiveKitCredentials livekit)  $default,) {final _that = this;
switch (_that) {
case _LiveCredentials():
return $default(_that.agora,_that.livekit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AgoraCredentials agora,  LiveKitCredentials livekit)?  $default,) {final _that = this;
switch (_that) {
case _LiveCredentials() when $default != null:
return $default(_that.agora,_that.livekit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LiveCredentials implements LiveCredentials {
  const _LiveCredentials({required this.agora, required this.livekit});
  factory _LiveCredentials.fromJson(Map<String, dynamic> json) => _$LiveCredentialsFromJson(json);

@override final  AgoraCredentials agora;
@override final  LiveKitCredentials livekit;

/// Create a copy of LiveCredentials
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LiveCredentialsCopyWith<_LiveCredentials> get copyWith => __$LiveCredentialsCopyWithImpl<_LiveCredentials>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LiveCredentialsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LiveCredentials&&(identical(other.agora, agora) || other.agora == agora)&&(identical(other.livekit, livekit) || other.livekit == livekit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,agora,livekit);

@override
String toString() {
  return 'LiveCredentials(agora: $agora, livekit: $livekit)';
}


}

/// @nodoc
abstract mixin class _$LiveCredentialsCopyWith<$Res> implements $LiveCredentialsCopyWith<$Res> {
  factory _$LiveCredentialsCopyWith(_LiveCredentials value, $Res Function(_LiveCredentials) _then) = __$LiveCredentialsCopyWithImpl;
@override @useResult
$Res call({
 AgoraCredentials agora, LiveKitCredentials livekit
});


@override $AgoraCredentialsCopyWith<$Res> get agora;@override $LiveKitCredentialsCopyWith<$Res> get livekit;

}
/// @nodoc
class __$LiveCredentialsCopyWithImpl<$Res>
    implements _$LiveCredentialsCopyWith<$Res> {
  __$LiveCredentialsCopyWithImpl(this._self, this._then);

  final _LiveCredentials _self;
  final $Res Function(_LiveCredentials) _then;

/// Create a copy of LiveCredentials
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? agora = null,Object? livekit = null,}) {
  return _then(_LiveCredentials(
agora: null == agora ? _self.agora : agora // ignore: cast_nullable_to_non_nullable
as AgoraCredentials,livekit: null == livekit ? _self.livekit : livekit // ignore: cast_nullable_to_non_nullable
as LiveKitCredentials,
  ));
}

/// Create a copy of LiveCredentials
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AgoraCredentialsCopyWith<$Res> get agora {
  
  return $AgoraCredentialsCopyWith<$Res>(_self.agora, (value) {
    return _then(_self.copyWith(agora: value));
  });
}/// Create a copy of LiveCredentials
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LiveKitCredentialsCopyWith<$Res> get livekit {
  
  return $LiveKitCredentialsCopyWith<$Res>(_self.livekit, (value) {
    return _then(_self.copyWith(livekit: value));
  });
}
}


/// @nodoc
mixin _$BuddyLiveHost {

 String get userId; String get username; String get displayName; String get avatarUrl;
/// Create a copy of BuddyLiveHost
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BuddyLiveHostCopyWith<BuddyLiveHost> get copyWith => _$BuddyLiveHostCopyWithImpl<BuddyLiveHost>(this as BuddyLiveHost, _$identity);

  /// Serializes this BuddyLiveHost to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BuddyLiveHost&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username,displayName,avatarUrl);

@override
String toString() {
  return 'BuddyLiveHost(userId: $userId, username: $username, displayName: $displayName, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class $BuddyLiveHostCopyWith<$Res>  {
  factory $BuddyLiveHostCopyWith(BuddyLiveHost value, $Res Function(BuddyLiveHost) _then) = _$BuddyLiveHostCopyWithImpl;
@useResult
$Res call({
 String userId, String username, String displayName, String avatarUrl
});




}
/// @nodoc
class _$BuddyLiveHostCopyWithImpl<$Res>
    implements $BuddyLiveHostCopyWith<$Res> {
  _$BuddyLiveHostCopyWithImpl(this._self, this._then);

  final BuddyLiveHost _self;
  final $Res Function(BuddyLiveHost) _then;

/// Create a copy of BuddyLiveHost
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? username = null,Object? displayName = null,Object? avatarUrl = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BuddyLiveHost].
extension BuddyLiveHostPatterns on BuddyLiveHost {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BuddyLiveHost value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BuddyLiveHost() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BuddyLiveHost value)  $default,){
final _that = this;
switch (_that) {
case _BuddyLiveHost():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BuddyLiveHost value)?  $default,){
final _that = this;
switch (_that) {
case _BuddyLiveHost() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String username,  String displayName,  String avatarUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BuddyLiveHost() when $default != null:
return $default(_that.userId,_that.username,_that.displayName,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String username,  String displayName,  String avatarUrl)  $default,) {final _that = this;
switch (_that) {
case _BuddyLiveHost():
return $default(_that.userId,_that.username,_that.displayName,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String username,  String displayName,  String avatarUrl)?  $default,) {final _that = this;
switch (_that) {
case _BuddyLiveHost() when $default != null:
return $default(_that.userId,_that.username,_that.displayName,_that.avatarUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BuddyLiveHost implements BuddyLiveHost {
  const _BuddyLiveHost({required this.userId, required this.username, required this.displayName, required this.avatarUrl});
  factory _BuddyLiveHost.fromJson(Map<String, dynamic> json) => _$BuddyLiveHostFromJson(json);

@override final  String userId;
@override final  String username;
@override final  String displayName;
@override final  String avatarUrl;

/// Create a copy of BuddyLiveHost
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BuddyLiveHostCopyWith<_BuddyLiveHost> get copyWith => __$BuddyLiveHostCopyWithImpl<_BuddyLiveHost>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BuddyLiveHostToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BuddyLiveHost&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username,displayName,avatarUrl);

@override
String toString() {
  return 'BuddyLiveHost(userId: $userId, username: $username, displayName: $displayName, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class _$BuddyLiveHostCopyWith<$Res> implements $BuddyLiveHostCopyWith<$Res> {
  factory _$BuddyLiveHostCopyWith(_BuddyLiveHost value, $Res Function(_BuddyLiveHost) _then) = __$BuddyLiveHostCopyWithImpl;
@override @useResult
$Res call({
 String userId, String username, String displayName, String avatarUrl
});




}
/// @nodoc
class __$BuddyLiveHostCopyWithImpl<$Res>
    implements _$BuddyLiveHostCopyWith<$Res> {
  __$BuddyLiveHostCopyWithImpl(this._self, this._then);

  final _BuddyLiveHost _self;
  final $Res Function(_BuddyLiveHost) _then;

/// Create a copy of BuddyLiveHost
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? username = null,Object? displayName = null,Object? avatarUrl = null,}) {
  return _then(_BuddyLiveHost(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$BuddyLive {

 String get id; BuddyLiveHost get host; String get title; String get liveType; String get category; String get access; String get status; String? get startedAt; String? get endedAt; int get viewerPeak; int get viewerCount; String get replayUrl; bool get replaySaved; String? get muxPlaybackId; String? get scheduledFor; bool get isRecurring; List<String> get equipmentList; bool get hasRsvped; int get rsvpCount; String? get gymId; String get createdAt;
/// Create a copy of BuddyLive
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BuddyLiveCopyWith<BuddyLive> get copyWith => _$BuddyLiveCopyWithImpl<BuddyLive>(this as BuddyLive, _$identity);

  /// Serializes this BuddyLive to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BuddyLive&&(identical(other.id, id) || other.id == id)&&(identical(other.host, host) || other.host == host)&&(identical(other.title, title) || other.title == title)&&(identical(other.liveType, liveType) || other.liveType == liveType)&&(identical(other.category, category) || other.category == category)&&(identical(other.access, access) || other.access == access)&&(identical(other.status, status) || other.status == status)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.viewerPeak, viewerPeak) || other.viewerPeak == viewerPeak)&&(identical(other.viewerCount, viewerCount) || other.viewerCount == viewerCount)&&(identical(other.replayUrl, replayUrl) || other.replayUrl == replayUrl)&&(identical(other.replaySaved, replaySaved) || other.replaySaved == replaySaved)&&(identical(other.muxPlaybackId, muxPlaybackId) || other.muxPlaybackId == muxPlaybackId)&&(identical(other.scheduledFor, scheduledFor) || other.scheduledFor == scheduledFor)&&(identical(other.isRecurring, isRecurring) || other.isRecurring == isRecurring)&&const DeepCollectionEquality().equals(other.equipmentList, equipmentList)&&(identical(other.hasRsvped, hasRsvped) || other.hasRsvped == hasRsvped)&&(identical(other.rsvpCount, rsvpCount) || other.rsvpCount == rsvpCount)&&(identical(other.gymId, gymId) || other.gymId == gymId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,host,title,liveType,category,access,status,startedAt,endedAt,viewerPeak,viewerCount,replayUrl,replaySaved,muxPlaybackId,scheduledFor,isRecurring,const DeepCollectionEquality().hash(equipmentList),hasRsvped,rsvpCount,gymId,createdAt]);

@override
String toString() {
  return 'BuddyLive(id: $id, host: $host, title: $title, liveType: $liveType, category: $category, access: $access, status: $status, startedAt: $startedAt, endedAt: $endedAt, viewerPeak: $viewerPeak, viewerCount: $viewerCount, replayUrl: $replayUrl, replaySaved: $replaySaved, muxPlaybackId: $muxPlaybackId, scheduledFor: $scheduledFor, isRecurring: $isRecurring, equipmentList: $equipmentList, hasRsvped: $hasRsvped, rsvpCount: $rsvpCount, gymId: $gymId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $BuddyLiveCopyWith<$Res>  {
  factory $BuddyLiveCopyWith(BuddyLive value, $Res Function(BuddyLive) _then) = _$BuddyLiveCopyWithImpl;
@useResult
$Res call({
 String id, BuddyLiveHost host, String title, String liveType, String category, String access, String status, String? startedAt, String? endedAt, int viewerPeak, int viewerCount, String replayUrl, bool replaySaved, String? muxPlaybackId, String? scheduledFor, bool isRecurring, List<String> equipmentList, bool hasRsvped, int rsvpCount, String? gymId, String createdAt
});


$BuddyLiveHostCopyWith<$Res> get host;

}
/// @nodoc
class _$BuddyLiveCopyWithImpl<$Res>
    implements $BuddyLiveCopyWith<$Res> {
  _$BuddyLiveCopyWithImpl(this._self, this._then);

  final BuddyLive _self;
  final $Res Function(BuddyLive) _then;

/// Create a copy of BuddyLive
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? host = null,Object? title = null,Object? liveType = null,Object? category = null,Object? access = null,Object? status = null,Object? startedAt = freezed,Object? endedAt = freezed,Object? viewerPeak = null,Object? viewerCount = null,Object? replayUrl = null,Object? replaySaved = null,Object? muxPlaybackId = freezed,Object? scheduledFor = freezed,Object? isRecurring = null,Object? equipmentList = null,Object? hasRsvped = null,Object? rsvpCount = null,Object? gymId = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as BuddyLiveHost,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,liveType: null == liveType ? _self.liveType : liveType // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,access: null == access ? _self.access : access // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as String?,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as String?,viewerPeak: null == viewerPeak ? _self.viewerPeak : viewerPeak // ignore: cast_nullable_to_non_nullable
as int,viewerCount: null == viewerCount ? _self.viewerCount : viewerCount // ignore: cast_nullable_to_non_nullable
as int,replayUrl: null == replayUrl ? _self.replayUrl : replayUrl // ignore: cast_nullable_to_non_nullable
as String,replaySaved: null == replaySaved ? _self.replaySaved : replaySaved // ignore: cast_nullable_to_non_nullable
as bool,muxPlaybackId: freezed == muxPlaybackId ? _self.muxPlaybackId : muxPlaybackId // ignore: cast_nullable_to_non_nullable
as String?,scheduledFor: freezed == scheduledFor ? _self.scheduledFor : scheduledFor // ignore: cast_nullable_to_non_nullable
as String?,isRecurring: null == isRecurring ? _self.isRecurring : isRecurring // ignore: cast_nullable_to_non_nullable
as bool,equipmentList: null == equipmentList ? _self.equipmentList : equipmentList // ignore: cast_nullable_to_non_nullable
as List<String>,hasRsvped: null == hasRsvped ? _self.hasRsvped : hasRsvped // ignore: cast_nullable_to_non_nullable
as bool,rsvpCount: null == rsvpCount ? _self.rsvpCount : rsvpCount // ignore: cast_nullable_to_non_nullable
as int,gymId: freezed == gymId ? _self.gymId : gymId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of BuddyLive
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BuddyLiveHostCopyWith<$Res> get host {
  
  return $BuddyLiveHostCopyWith<$Res>(_self.host, (value) {
    return _then(_self.copyWith(host: value));
  });
}
}


/// Adds pattern-matching-related methods to [BuddyLive].
extension BuddyLivePatterns on BuddyLive {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BuddyLive value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BuddyLive() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BuddyLive value)  $default,){
final _that = this;
switch (_that) {
case _BuddyLive():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BuddyLive value)?  $default,){
final _that = this;
switch (_that) {
case _BuddyLive() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  BuddyLiveHost host,  String title,  String liveType,  String category,  String access,  String status,  String? startedAt,  String? endedAt,  int viewerPeak,  int viewerCount,  String replayUrl,  bool replaySaved,  String? muxPlaybackId,  String? scheduledFor,  bool isRecurring,  List<String> equipmentList,  bool hasRsvped,  int rsvpCount,  String? gymId,  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BuddyLive() when $default != null:
return $default(_that.id,_that.host,_that.title,_that.liveType,_that.category,_that.access,_that.status,_that.startedAt,_that.endedAt,_that.viewerPeak,_that.viewerCount,_that.replayUrl,_that.replaySaved,_that.muxPlaybackId,_that.scheduledFor,_that.isRecurring,_that.equipmentList,_that.hasRsvped,_that.rsvpCount,_that.gymId,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  BuddyLiveHost host,  String title,  String liveType,  String category,  String access,  String status,  String? startedAt,  String? endedAt,  int viewerPeak,  int viewerCount,  String replayUrl,  bool replaySaved,  String? muxPlaybackId,  String? scheduledFor,  bool isRecurring,  List<String> equipmentList,  bool hasRsvped,  int rsvpCount,  String? gymId,  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _BuddyLive():
return $default(_that.id,_that.host,_that.title,_that.liveType,_that.category,_that.access,_that.status,_that.startedAt,_that.endedAt,_that.viewerPeak,_that.viewerCount,_that.replayUrl,_that.replaySaved,_that.muxPlaybackId,_that.scheduledFor,_that.isRecurring,_that.equipmentList,_that.hasRsvped,_that.rsvpCount,_that.gymId,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  BuddyLiveHost host,  String title,  String liveType,  String category,  String access,  String status,  String? startedAt,  String? endedAt,  int viewerPeak,  int viewerCount,  String replayUrl,  bool replaySaved,  String? muxPlaybackId,  String? scheduledFor,  bool isRecurring,  List<String> equipmentList,  bool hasRsvped,  int rsvpCount,  String? gymId,  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _BuddyLive() when $default != null:
return $default(_that.id,_that.host,_that.title,_that.liveType,_that.category,_that.access,_that.status,_that.startedAt,_that.endedAt,_that.viewerPeak,_that.viewerCount,_that.replayUrl,_that.replaySaved,_that.muxPlaybackId,_that.scheduledFor,_that.isRecurring,_that.equipmentList,_that.hasRsvped,_that.rsvpCount,_that.gymId,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BuddyLive implements BuddyLive {
  const _BuddyLive({required this.id, required this.host, required this.title, this.liveType = 'open_sweat', this.category = '', this.access = 'public', this.status = 'scheduled', this.startedAt, this.endedAt, this.viewerPeak = 0, this.viewerCount = 0, this.replayUrl = '', this.replaySaved = false, this.muxPlaybackId, this.scheduledFor, this.isRecurring = false, final  List<String> equipmentList = const <String>[], this.hasRsvped = false, this.rsvpCount = 0, this.gymId, required this.createdAt}): _equipmentList = equipmentList;
  factory _BuddyLive.fromJson(Map<String, dynamic> json) => _$BuddyLiveFromJson(json);

@override final  String id;
@override final  BuddyLiveHost host;
@override final  String title;
@override@JsonKey() final  String liveType;
@override@JsonKey() final  String category;
@override@JsonKey() final  String access;
@override@JsonKey() final  String status;
@override final  String? startedAt;
@override final  String? endedAt;
@override@JsonKey() final  int viewerPeak;
@override@JsonKey() final  int viewerCount;
@override@JsonKey() final  String replayUrl;
@override@JsonKey() final  bool replaySaved;
@override final  String? muxPlaybackId;
@override final  String? scheduledFor;
@override@JsonKey() final  bool isRecurring;
 final  List<String> _equipmentList;
@override@JsonKey() List<String> get equipmentList {
  if (_equipmentList is EqualUnmodifiableListView) return _equipmentList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_equipmentList);
}

@override@JsonKey() final  bool hasRsvped;
@override@JsonKey() final  int rsvpCount;
@override final  String? gymId;
@override final  String createdAt;

/// Create a copy of BuddyLive
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BuddyLiveCopyWith<_BuddyLive> get copyWith => __$BuddyLiveCopyWithImpl<_BuddyLive>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BuddyLiveToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BuddyLive&&(identical(other.id, id) || other.id == id)&&(identical(other.host, host) || other.host == host)&&(identical(other.title, title) || other.title == title)&&(identical(other.liveType, liveType) || other.liveType == liveType)&&(identical(other.category, category) || other.category == category)&&(identical(other.access, access) || other.access == access)&&(identical(other.status, status) || other.status == status)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.viewerPeak, viewerPeak) || other.viewerPeak == viewerPeak)&&(identical(other.viewerCount, viewerCount) || other.viewerCount == viewerCount)&&(identical(other.replayUrl, replayUrl) || other.replayUrl == replayUrl)&&(identical(other.replaySaved, replaySaved) || other.replaySaved == replaySaved)&&(identical(other.muxPlaybackId, muxPlaybackId) || other.muxPlaybackId == muxPlaybackId)&&(identical(other.scheduledFor, scheduledFor) || other.scheduledFor == scheduledFor)&&(identical(other.isRecurring, isRecurring) || other.isRecurring == isRecurring)&&const DeepCollectionEquality().equals(other._equipmentList, _equipmentList)&&(identical(other.hasRsvped, hasRsvped) || other.hasRsvped == hasRsvped)&&(identical(other.rsvpCount, rsvpCount) || other.rsvpCount == rsvpCount)&&(identical(other.gymId, gymId) || other.gymId == gymId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,host,title,liveType,category,access,status,startedAt,endedAt,viewerPeak,viewerCount,replayUrl,replaySaved,muxPlaybackId,scheduledFor,isRecurring,const DeepCollectionEquality().hash(_equipmentList),hasRsvped,rsvpCount,gymId,createdAt]);

@override
String toString() {
  return 'BuddyLive(id: $id, host: $host, title: $title, liveType: $liveType, category: $category, access: $access, status: $status, startedAt: $startedAt, endedAt: $endedAt, viewerPeak: $viewerPeak, viewerCount: $viewerCount, replayUrl: $replayUrl, replaySaved: $replaySaved, muxPlaybackId: $muxPlaybackId, scheduledFor: $scheduledFor, isRecurring: $isRecurring, equipmentList: $equipmentList, hasRsvped: $hasRsvped, rsvpCount: $rsvpCount, gymId: $gymId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$BuddyLiveCopyWith<$Res> implements $BuddyLiveCopyWith<$Res> {
  factory _$BuddyLiveCopyWith(_BuddyLive value, $Res Function(_BuddyLive) _then) = __$BuddyLiveCopyWithImpl;
@override @useResult
$Res call({
 String id, BuddyLiveHost host, String title, String liveType, String category, String access, String status, String? startedAt, String? endedAt, int viewerPeak, int viewerCount, String replayUrl, bool replaySaved, String? muxPlaybackId, String? scheduledFor, bool isRecurring, List<String> equipmentList, bool hasRsvped, int rsvpCount, String? gymId, String createdAt
});


@override $BuddyLiveHostCopyWith<$Res> get host;

}
/// @nodoc
class __$BuddyLiveCopyWithImpl<$Res>
    implements _$BuddyLiveCopyWith<$Res> {
  __$BuddyLiveCopyWithImpl(this._self, this._then);

  final _BuddyLive _self;
  final $Res Function(_BuddyLive) _then;

/// Create a copy of BuddyLive
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? host = null,Object? title = null,Object? liveType = null,Object? category = null,Object? access = null,Object? status = null,Object? startedAt = freezed,Object? endedAt = freezed,Object? viewerPeak = null,Object? viewerCount = null,Object? replayUrl = null,Object? replaySaved = null,Object? muxPlaybackId = freezed,Object? scheduledFor = freezed,Object? isRecurring = null,Object? equipmentList = null,Object? hasRsvped = null,Object? rsvpCount = null,Object? gymId = freezed,Object? createdAt = null,}) {
  return _then(_BuddyLive(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as BuddyLiveHost,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,liveType: null == liveType ? _self.liveType : liveType // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,access: null == access ? _self.access : access // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as String?,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as String?,viewerPeak: null == viewerPeak ? _self.viewerPeak : viewerPeak // ignore: cast_nullable_to_non_nullable
as int,viewerCount: null == viewerCount ? _self.viewerCount : viewerCount // ignore: cast_nullable_to_non_nullable
as int,replayUrl: null == replayUrl ? _self.replayUrl : replayUrl // ignore: cast_nullable_to_non_nullable
as String,replaySaved: null == replaySaved ? _self.replaySaved : replaySaved // ignore: cast_nullable_to_non_nullable
as bool,muxPlaybackId: freezed == muxPlaybackId ? _self.muxPlaybackId : muxPlaybackId // ignore: cast_nullable_to_non_nullable
as String?,scheduledFor: freezed == scheduledFor ? _self.scheduledFor : scheduledFor // ignore: cast_nullable_to_non_nullable
as String?,isRecurring: null == isRecurring ? _self.isRecurring : isRecurring // ignore: cast_nullable_to_non_nullable
as bool,equipmentList: null == equipmentList ? _self._equipmentList : equipmentList // ignore: cast_nullable_to_non_nullable
as List<String>,hasRsvped: null == hasRsvped ? _self.hasRsvped : hasRsvped // ignore: cast_nullable_to_non_nullable
as bool,rsvpCount: null == rsvpCount ? _self.rsvpCount : rsvpCount // ignore: cast_nullable_to_non_nullable
as int,gymId: freezed == gymId ? _self.gymId : gymId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of BuddyLive
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BuddyLiveHostCopyWith<$Res> get host {
  
  return $BuddyLiveHostCopyWith<$Res>(_self.host, (value) {
    return _then(_self.copyWith(host: value));
  });
}
}


/// @nodoc
mixin _$CoHost {

 String get userId; String get displayName; String get avatarUrl;
/// Create a copy of CoHost
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoHostCopyWith<CoHost> get copyWith => _$CoHostCopyWithImpl<CoHost>(this as CoHost, _$identity);

  /// Serializes this CoHost to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoHost&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,displayName,avatarUrl);

@override
String toString() {
  return 'CoHost(userId: $userId, displayName: $displayName, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class $CoHostCopyWith<$Res>  {
  factory $CoHostCopyWith(CoHost value, $Res Function(CoHost) _then) = _$CoHostCopyWithImpl;
@useResult
$Res call({
 String userId, String displayName, String avatarUrl
});




}
/// @nodoc
class _$CoHostCopyWithImpl<$Res>
    implements $CoHostCopyWith<$Res> {
  _$CoHostCopyWithImpl(this._self, this._then);

  final CoHost _self;
  final $Res Function(CoHost) _then;

/// Create a copy of CoHost
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? displayName = null,Object? avatarUrl = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CoHost].
extension CoHostPatterns on CoHost {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoHost value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoHost() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoHost value)  $default,){
final _that = this;
switch (_that) {
case _CoHost():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoHost value)?  $default,){
final _that = this;
switch (_that) {
case _CoHost() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String displayName,  String avatarUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoHost() when $default != null:
return $default(_that.userId,_that.displayName,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String displayName,  String avatarUrl)  $default,) {final _that = this;
switch (_that) {
case _CoHost():
return $default(_that.userId,_that.displayName,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String displayName,  String avatarUrl)?  $default,) {final _that = this;
switch (_that) {
case _CoHost() when $default != null:
return $default(_that.userId,_that.displayName,_that.avatarUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CoHost implements CoHost {
  const _CoHost({required this.userId, required this.displayName, required this.avatarUrl});
  factory _CoHost.fromJson(Map<String, dynamic> json) => _$CoHostFromJson(json);

@override final  String userId;
@override final  String displayName;
@override final  String avatarUrl;

/// Create a copy of CoHost
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoHostCopyWith<_CoHost> get copyWith => __$CoHostCopyWithImpl<_CoHost>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CoHostToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoHost&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,displayName,avatarUrl);

@override
String toString() {
  return 'CoHost(userId: $userId, displayName: $displayName, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class _$CoHostCopyWith<$Res> implements $CoHostCopyWith<$Res> {
  factory _$CoHostCopyWith(_CoHost value, $Res Function(_CoHost) _then) = __$CoHostCopyWithImpl;
@override @useResult
$Res call({
 String userId, String displayName, String avatarUrl
});




}
/// @nodoc
class __$CoHostCopyWithImpl<$Res>
    implements _$CoHostCopyWith<$Res> {
  __$CoHostCopyWithImpl(this._self, this._then);

  final _CoHost _self;
  final $Res Function(_CoHost) _then;

/// Create a copy of CoHost
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? displayName = null,Object? avatarUrl = null,}) {
  return _then(_CoHost(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$GiftInfo {

 String get txId; String get artifactType; int get quantity; String get senderId; String get senderName; int get total;
/// Create a copy of GiftInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GiftInfoCopyWith<GiftInfo> get copyWith => _$GiftInfoCopyWithImpl<GiftInfo>(this as GiftInfo, _$identity);

  /// Serializes this GiftInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GiftInfo&&(identical(other.txId, txId) || other.txId == txId)&&(identical(other.artifactType, artifactType) || other.artifactType == artifactType)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,txId,artifactType,quantity,senderId,senderName,total);

@override
String toString() {
  return 'GiftInfo(txId: $txId, artifactType: $artifactType, quantity: $quantity, senderId: $senderId, senderName: $senderName, total: $total)';
}


}

/// @nodoc
abstract mixin class $GiftInfoCopyWith<$Res>  {
  factory $GiftInfoCopyWith(GiftInfo value, $Res Function(GiftInfo) _then) = _$GiftInfoCopyWithImpl;
@useResult
$Res call({
 String txId, String artifactType, int quantity, String senderId, String senderName, int total
});




}
/// @nodoc
class _$GiftInfoCopyWithImpl<$Res>
    implements $GiftInfoCopyWith<$Res> {
  _$GiftInfoCopyWithImpl(this._self, this._then);

  final GiftInfo _self;
  final $Res Function(GiftInfo) _then;

/// Create a copy of GiftInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? txId = null,Object? artifactType = null,Object? quantity = null,Object? senderId = null,Object? senderName = null,Object? total = null,}) {
  return _then(_self.copyWith(
txId: null == txId ? _self.txId : txId // ignore: cast_nullable_to_non_nullable
as String,artifactType: null == artifactType ? _self.artifactType : artifactType // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [GiftInfo].
extension GiftInfoPatterns on GiftInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GiftInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GiftInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GiftInfo value)  $default,){
final _that = this;
switch (_that) {
case _GiftInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GiftInfo value)?  $default,){
final _that = this;
switch (_that) {
case _GiftInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String txId,  String artifactType,  int quantity,  String senderId,  String senderName,  int total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GiftInfo() when $default != null:
return $default(_that.txId,_that.artifactType,_that.quantity,_that.senderId,_that.senderName,_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String txId,  String artifactType,  int quantity,  String senderId,  String senderName,  int total)  $default,) {final _that = this;
switch (_that) {
case _GiftInfo():
return $default(_that.txId,_that.artifactType,_that.quantity,_that.senderId,_that.senderName,_that.total);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String txId,  String artifactType,  int quantity,  String senderId,  String senderName,  int total)?  $default,) {final _that = this;
switch (_that) {
case _GiftInfo() when $default != null:
return $default(_that.txId,_that.artifactType,_that.quantity,_that.senderId,_that.senderName,_that.total);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GiftInfo implements GiftInfo {
  const _GiftInfo({required this.txId, required this.artifactType, required this.quantity, required this.senderId, required this.senderName, required this.total});
  factory _GiftInfo.fromJson(Map<String, dynamic> json) => _$GiftInfoFromJson(json);

@override final  String txId;
@override final  String artifactType;
@override final  int quantity;
@override final  String senderId;
@override final  String senderName;
@override final  int total;

/// Create a copy of GiftInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GiftInfoCopyWith<_GiftInfo> get copyWith => __$GiftInfoCopyWithImpl<_GiftInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GiftInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GiftInfo&&(identical(other.txId, txId) || other.txId == txId)&&(identical(other.artifactType, artifactType) || other.artifactType == artifactType)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,txId,artifactType,quantity,senderId,senderName,total);

@override
String toString() {
  return 'GiftInfo(txId: $txId, artifactType: $artifactType, quantity: $quantity, senderId: $senderId, senderName: $senderName, total: $total)';
}


}

/// @nodoc
abstract mixin class _$GiftInfoCopyWith<$Res> implements $GiftInfoCopyWith<$Res> {
  factory _$GiftInfoCopyWith(_GiftInfo value, $Res Function(_GiftInfo) _then) = __$GiftInfoCopyWithImpl;
@override @useResult
$Res call({
 String txId, String artifactType, int quantity, String senderId, String senderName, int total
});




}
/// @nodoc
class __$GiftInfoCopyWithImpl<$Res>
    implements _$GiftInfoCopyWith<$Res> {
  __$GiftInfoCopyWithImpl(this._self, this._then);

  final _GiftInfo _self;
  final $Res Function(_GiftInfo) _then;

/// Create a copy of GiftInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? txId = null,Object? artifactType = null,Object? quantity = null,Object? senderId = null,Object? senderName = null,Object? total = null,}) {
  return _then(_GiftInfo(
txId: null == txId ? _self.txId : txId // ignore: cast_nullable_to_non_nullable
as String,artifactType: null == artifactType ? _self.artifactType : artifactType // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$AttendeeInfo {

 String get id; String get displayName; String get avatarUrl; bool get isSpeaking; bool get hasMicOn; bool get hasVideoOn; bool get isLocal; double get audioLevel;
/// Create a copy of AttendeeInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendeeInfoCopyWith<AttendeeInfo> get copyWith => _$AttendeeInfoCopyWithImpl<AttendeeInfo>(this as AttendeeInfo, _$identity);

  /// Serializes this AttendeeInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttendeeInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.isSpeaking, isSpeaking) || other.isSpeaking == isSpeaking)&&(identical(other.hasMicOn, hasMicOn) || other.hasMicOn == hasMicOn)&&(identical(other.hasVideoOn, hasVideoOn) || other.hasVideoOn == hasVideoOn)&&(identical(other.isLocal, isLocal) || other.isLocal == isLocal)&&(identical(other.audioLevel, audioLevel) || other.audioLevel == audioLevel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,displayName,avatarUrl,isSpeaking,hasMicOn,hasVideoOn,isLocal,audioLevel);

@override
String toString() {
  return 'AttendeeInfo(id: $id, displayName: $displayName, avatarUrl: $avatarUrl, isSpeaking: $isSpeaking, hasMicOn: $hasMicOn, hasVideoOn: $hasVideoOn, isLocal: $isLocal, audioLevel: $audioLevel)';
}


}

/// @nodoc
abstract mixin class $AttendeeInfoCopyWith<$Res>  {
  factory $AttendeeInfoCopyWith(AttendeeInfo value, $Res Function(AttendeeInfo) _then) = _$AttendeeInfoCopyWithImpl;
@useResult
$Res call({
 String id, String displayName, String avatarUrl, bool isSpeaking, bool hasMicOn, bool hasVideoOn, bool isLocal, double audioLevel
});




}
/// @nodoc
class _$AttendeeInfoCopyWithImpl<$Res>
    implements $AttendeeInfoCopyWith<$Res> {
  _$AttendeeInfoCopyWithImpl(this._self, this._then);

  final AttendeeInfo _self;
  final $Res Function(AttendeeInfo) _then;

/// Create a copy of AttendeeInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? displayName = null,Object? avatarUrl = null,Object? isSpeaking = null,Object? hasMicOn = null,Object? hasVideoOn = null,Object? isLocal = null,Object? audioLevel = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,isSpeaking: null == isSpeaking ? _self.isSpeaking : isSpeaking // ignore: cast_nullable_to_non_nullable
as bool,hasMicOn: null == hasMicOn ? _self.hasMicOn : hasMicOn // ignore: cast_nullable_to_non_nullable
as bool,hasVideoOn: null == hasVideoOn ? _self.hasVideoOn : hasVideoOn // ignore: cast_nullable_to_non_nullable
as bool,isLocal: null == isLocal ? _self.isLocal : isLocal // ignore: cast_nullable_to_non_nullable
as bool,audioLevel: null == audioLevel ? _self.audioLevel : audioLevel // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [AttendeeInfo].
extension AttendeeInfoPatterns on AttendeeInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttendeeInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttendeeInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttendeeInfo value)  $default,){
final _that = this;
switch (_that) {
case _AttendeeInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttendeeInfo value)?  $default,){
final _that = this;
switch (_that) {
case _AttendeeInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String displayName,  String avatarUrl,  bool isSpeaking,  bool hasMicOn,  bool hasVideoOn,  bool isLocal,  double audioLevel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttendeeInfo() when $default != null:
return $default(_that.id,_that.displayName,_that.avatarUrl,_that.isSpeaking,_that.hasMicOn,_that.hasVideoOn,_that.isLocal,_that.audioLevel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String displayName,  String avatarUrl,  bool isSpeaking,  bool hasMicOn,  bool hasVideoOn,  bool isLocal,  double audioLevel)  $default,) {final _that = this;
switch (_that) {
case _AttendeeInfo():
return $default(_that.id,_that.displayName,_that.avatarUrl,_that.isSpeaking,_that.hasMicOn,_that.hasVideoOn,_that.isLocal,_that.audioLevel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String displayName,  String avatarUrl,  bool isSpeaking,  bool hasMicOn,  bool hasVideoOn,  bool isLocal,  double audioLevel)?  $default,) {final _that = this;
switch (_that) {
case _AttendeeInfo() when $default != null:
return $default(_that.id,_that.displayName,_that.avatarUrl,_that.isSpeaking,_that.hasMicOn,_that.hasVideoOn,_that.isLocal,_that.audioLevel);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AttendeeInfo implements AttendeeInfo {
  const _AttendeeInfo({required this.id, required this.displayName, required this.avatarUrl, this.isSpeaking = false, this.hasMicOn = true, this.hasVideoOn = true, this.isLocal = false, this.audioLevel = 0});
  factory _AttendeeInfo.fromJson(Map<String, dynamic> json) => _$AttendeeInfoFromJson(json);

@override final  String id;
@override final  String displayName;
@override final  String avatarUrl;
@override@JsonKey() final  bool isSpeaking;
@override@JsonKey() final  bool hasMicOn;
@override@JsonKey() final  bool hasVideoOn;
@override@JsonKey() final  bool isLocal;
@override@JsonKey() final  double audioLevel;

/// Create a copy of AttendeeInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendeeInfoCopyWith<_AttendeeInfo> get copyWith => __$AttendeeInfoCopyWithImpl<_AttendeeInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttendeeInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttendeeInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.isSpeaking, isSpeaking) || other.isSpeaking == isSpeaking)&&(identical(other.hasMicOn, hasMicOn) || other.hasMicOn == hasMicOn)&&(identical(other.hasVideoOn, hasVideoOn) || other.hasVideoOn == hasVideoOn)&&(identical(other.isLocal, isLocal) || other.isLocal == isLocal)&&(identical(other.audioLevel, audioLevel) || other.audioLevel == audioLevel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,displayName,avatarUrl,isSpeaking,hasMicOn,hasVideoOn,isLocal,audioLevel);

@override
String toString() {
  return 'AttendeeInfo(id: $id, displayName: $displayName, avatarUrl: $avatarUrl, isSpeaking: $isSpeaking, hasMicOn: $hasMicOn, hasVideoOn: $hasVideoOn, isLocal: $isLocal, audioLevel: $audioLevel)';
}


}

/// @nodoc
abstract mixin class _$AttendeeInfoCopyWith<$Res> implements $AttendeeInfoCopyWith<$Res> {
  factory _$AttendeeInfoCopyWith(_AttendeeInfo value, $Res Function(_AttendeeInfo) _then) = __$AttendeeInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, String displayName, String avatarUrl, bool isSpeaking, bool hasMicOn, bool hasVideoOn, bool isLocal, double audioLevel
});




}
/// @nodoc
class __$AttendeeInfoCopyWithImpl<$Res>
    implements _$AttendeeInfoCopyWith<$Res> {
  __$AttendeeInfoCopyWithImpl(this._self, this._then);

  final _AttendeeInfo _self;
  final $Res Function(_AttendeeInfo) _then;

/// Create a copy of AttendeeInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? displayName = null,Object? avatarUrl = null,Object? isSpeaking = null,Object? hasMicOn = null,Object? hasVideoOn = null,Object? isLocal = null,Object? audioLevel = null,}) {
  return _then(_AttendeeInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,isSpeaking: null == isSpeaking ? _self.isSpeaking : isSpeaking // ignore: cast_nullable_to_non_nullable
as bool,hasMicOn: null == hasMicOn ? _self.hasMicOn : hasMicOn // ignore: cast_nullable_to_non_nullable
as bool,hasVideoOn: null == hasVideoOn ? _self.hasVideoOn : hasVideoOn // ignore: cast_nullable_to_non_nullable
as bool,isLocal: null == isLocal ? _self.isLocal : isLocal // ignore: cast_nullable_to_non_nullable
as bool,audioLevel: null == audioLevel ? _self.audioLevel : audioLevel // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$LiveRoomData {

 LiveCredentials get credentials; String get liveType; String get title; String get hostName; String get hostUserId; String get hostAvatar; String get status; int get viewerCount; List<CoHost> get coHosts;
/// Create a copy of LiveRoomData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LiveRoomDataCopyWith<LiveRoomData> get copyWith => _$LiveRoomDataCopyWithImpl<LiveRoomData>(this as LiveRoomData, _$identity);

  /// Serializes this LiveRoomData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LiveRoomData&&(identical(other.credentials, credentials) || other.credentials == credentials)&&(identical(other.liveType, liveType) || other.liveType == liveType)&&(identical(other.title, title) || other.title == title)&&(identical(other.hostName, hostName) || other.hostName == hostName)&&(identical(other.hostUserId, hostUserId) || other.hostUserId == hostUserId)&&(identical(other.hostAvatar, hostAvatar) || other.hostAvatar == hostAvatar)&&(identical(other.status, status) || other.status == status)&&(identical(other.viewerCount, viewerCount) || other.viewerCount == viewerCount)&&const DeepCollectionEquality().equals(other.coHosts, coHosts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,credentials,liveType,title,hostName,hostUserId,hostAvatar,status,viewerCount,const DeepCollectionEquality().hash(coHosts));

@override
String toString() {
  return 'LiveRoomData(credentials: $credentials, liveType: $liveType, title: $title, hostName: $hostName, hostUserId: $hostUserId, hostAvatar: $hostAvatar, status: $status, viewerCount: $viewerCount, coHosts: $coHosts)';
}


}

/// @nodoc
abstract mixin class $LiveRoomDataCopyWith<$Res>  {
  factory $LiveRoomDataCopyWith(LiveRoomData value, $Res Function(LiveRoomData) _then) = _$LiveRoomDataCopyWithImpl;
@useResult
$Res call({
 LiveCredentials credentials, String liveType, String title, String hostName, String hostUserId, String hostAvatar, String status, int viewerCount, List<CoHost> coHosts
});


$LiveCredentialsCopyWith<$Res> get credentials;

}
/// @nodoc
class _$LiveRoomDataCopyWithImpl<$Res>
    implements $LiveRoomDataCopyWith<$Res> {
  _$LiveRoomDataCopyWithImpl(this._self, this._then);

  final LiveRoomData _self;
  final $Res Function(LiveRoomData) _then;

/// Create a copy of LiveRoomData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? credentials = null,Object? liveType = null,Object? title = null,Object? hostName = null,Object? hostUserId = null,Object? hostAvatar = null,Object? status = null,Object? viewerCount = null,Object? coHosts = null,}) {
  return _then(_self.copyWith(
credentials: null == credentials ? _self.credentials : credentials // ignore: cast_nullable_to_non_nullable
as LiveCredentials,liveType: null == liveType ? _self.liveType : liveType // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,hostName: null == hostName ? _self.hostName : hostName // ignore: cast_nullable_to_non_nullable
as String,hostUserId: null == hostUserId ? _self.hostUserId : hostUserId // ignore: cast_nullable_to_non_nullable
as String,hostAvatar: null == hostAvatar ? _self.hostAvatar : hostAvatar // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,viewerCount: null == viewerCount ? _self.viewerCount : viewerCount // ignore: cast_nullable_to_non_nullable
as int,coHosts: null == coHosts ? _self.coHosts : coHosts // ignore: cast_nullable_to_non_nullable
as List<CoHost>,
  ));
}
/// Create a copy of LiveRoomData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LiveCredentialsCopyWith<$Res> get credentials {
  
  return $LiveCredentialsCopyWith<$Res>(_self.credentials, (value) {
    return _then(_self.copyWith(credentials: value));
  });
}
}


/// Adds pattern-matching-related methods to [LiveRoomData].
extension LiveRoomDataPatterns on LiveRoomData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LiveRoomData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LiveRoomData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LiveRoomData value)  $default,){
final _that = this;
switch (_that) {
case _LiveRoomData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LiveRoomData value)?  $default,){
final _that = this;
switch (_that) {
case _LiveRoomData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LiveCredentials credentials,  String liveType,  String title,  String hostName,  String hostUserId,  String hostAvatar,  String status,  int viewerCount,  List<CoHost> coHosts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LiveRoomData() when $default != null:
return $default(_that.credentials,_that.liveType,_that.title,_that.hostName,_that.hostUserId,_that.hostAvatar,_that.status,_that.viewerCount,_that.coHosts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LiveCredentials credentials,  String liveType,  String title,  String hostName,  String hostUserId,  String hostAvatar,  String status,  int viewerCount,  List<CoHost> coHosts)  $default,) {final _that = this;
switch (_that) {
case _LiveRoomData():
return $default(_that.credentials,_that.liveType,_that.title,_that.hostName,_that.hostUserId,_that.hostAvatar,_that.status,_that.viewerCount,_that.coHosts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LiveCredentials credentials,  String liveType,  String title,  String hostName,  String hostUserId,  String hostAvatar,  String status,  int viewerCount,  List<CoHost> coHosts)?  $default,) {final _that = this;
switch (_that) {
case _LiveRoomData() when $default != null:
return $default(_that.credentials,_that.liveType,_that.title,_that.hostName,_that.hostUserId,_that.hostAvatar,_that.status,_that.viewerCount,_that.coHosts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LiveRoomData implements LiveRoomData {
  const _LiveRoomData({required this.credentials, this.liveType = '', this.title = '', this.hostName = '', this.hostUserId = '', this.hostAvatar = '', this.status = '', this.viewerCount = 0, final  List<CoHost> coHosts = const <CoHost>[]}): _coHosts = coHosts;
  factory _LiveRoomData.fromJson(Map<String, dynamic> json) => _$LiveRoomDataFromJson(json);

@override final  LiveCredentials credentials;
@override@JsonKey() final  String liveType;
@override@JsonKey() final  String title;
@override@JsonKey() final  String hostName;
@override@JsonKey() final  String hostUserId;
@override@JsonKey() final  String hostAvatar;
@override@JsonKey() final  String status;
@override@JsonKey() final  int viewerCount;
 final  List<CoHost> _coHosts;
@override@JsonKey() List<CoHost> get coHosts {
  if (_coHosts is EqualUnmodifiableListView) return _coHosts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_coHosts);
}


/// Create a copy of LiveRoomData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LiveRoomDataCopyWith<_LiveRoomData> get copyWith => __$LiveRoomDataCopyWithImpl<_LiveRoomData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LiveRoomDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LiveRoomData&&(identical(other.credentials, credentials) || other.credentials == credentials)&&(identical(other.liveType, liveType) || other.liveType == liveType)&&(identical(other.title, title) || other.title == title)&&(identical(other.hostName, hostName) || other.hostName == hostName)&&(identical(other.hostUserId, hostUserId) || other.hostUserId == hostUserId)&&(identical(other.hostAvatar, hostAvatar) || other.hostAvatar == hostAvatar)&&(identical(other.status, status) || other.status == status)&&(identical(other.viewerCount, viewerCount) || other.viewerCount == viewerCount)&&const DeepCollectionEquality().equals(other._coHosts, _coHosts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,credentials,liveType,title,hostName,hostUserId,hostAvatar,status,viewerCount,const DeepCollectionEquality().hash(_coHosts));

@override
String toString() {
  return 'LiveRoomData(credentials: $credentials, liveType: $liveType, title: $title, hostName: $hostName, hostUserId: $hostUserId, hostAvatar: $hostAvatar, status: $status, viewerCount: $viewerCount, coHosts: $coHosts)';
}


}

/// @nodoc
abstract mixin class _$LiveRoomDataCopyWith<$Res> implements $LiveRoomDataCopyWith<$Res> {
  factory _$LiveRoomDataCopyWith(_LiveRoomData value, $Res Function(_LiveRoomData) _then) = __$LiveRoomDataCopyWithImpl;
@override @useResult
$Res call({
 LiveCredentials credentials, String liveType, String title, String hostName, String hostUserId, String hostAvatar, String status, int viewerCount, List<CoHost> coHosts
});


@override $LiveCredentialsCopyWith<$Res> get credentials;

}
/// @nodoc
class __$LiveRoomDataCopyWithImpl<$Res>
    implements _$LiveRoomDataCopyWith<$Res> {
  __$LiveRoomDataCopyWithImpl(this._self, this._then);

  final _LiveRoomData _self;
  final $Res Function(_LiveRoomData) _then;

/// Create a copy of LiveRoomData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? credentials = null,Object? liveType = null,Object? title = null,Object? hostName = null,Object? hostUserId = null,Object? hostAvatar = null,Object? status = null,Object? viewerCount = null,Object? coHosts = null,}) {
  return _then(_LiveRoomData(
credentials: null == credentials ? _self.credentials : credentials // ignore: cast_nullable_to_non_nullable
as LiveCredentials,liveType: null == liveType ? _self.liveType : liveType // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,hostName: null == hostName ? _self.hostName : hostName // ignore: cast_nullable_to_non_nullable
as String,hostUserId: null == hostUserId ? _self.hostUserId : hostUserId // ignore: cast_nullable_to_non_nullable
as String,hostAvatar: null == hostAvatar ? _self.hostAvatar : hostAvatar // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,viewerCount: null == viewerCount ? _self.viewerCount : viewerCount // ignore: cast_nullable_to_non_nullable
as int,coHosts: null == coHosts ? _self._coHosts : coHosts // ignore: cast_nullable_to_non_nullable
as List<CoHost>,
  ));
}

/// Create a copy of LiveRoomData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LiveCredentialsCopyWith<$Res> get credentials {
  
  return $LiveCredentialsCopyWith<$Res>(_self.credentials, (value) {
    return _then(_self.copyWith(credentials: value));
  });
}
}


/// @nodoc
mixin _$StartLivePayload {

 String get title; String get liveType; String get category; String get access; String? get gymId; String? get scheduledFor; bool get isRecurring; List<String> get equipmentList; List<String> get coHosts;
/// Create a copy of StartLivePayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StartLivePayloadCopyWith<StartLivePayload> get copyWith => _$StartLivePayloadCopyWithImpl<StartLivePayload>(this as StartLivePayload, _$identity);

  /// Serializes this StartLivePayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StartLivePayload&&(identical(other.title, title) || other.title == title)&&(identical(other.liveType, liveType) || other.liveType == liveType)&&(identical(other.category, category) || other.category == category)&&(identical(other.access, access) || other.access == access)&&(identical(other.gymId, gymId) || other.gymId == gymId)&&(identical(other.scheduledFor, scheduledFor) || other.scheduledFor == scheduledFor)&&(identical(other.isRecurring, isRecurring) || other.isRecurring == isRecurring)&&const DeepCollectionEquality().equals(other.equipmentList, equipmentList)&&const DeepCollectionEquality().equals(other.coHosts, coHosts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,liveType,category,access,gymId,scheduledFor,isRecurring,const DeepCollectionEquality().hash(equipmentList),const DeepCollectionEquality().hash(coHosts));

@override
String toString() {
  return 'StartLivePayload(title: $title, liveType: $liveType, category: $category, access: $access, gymId: $gymId, scheduledFor: $scheduledFor, isRecurring: $isRecurring, equipmentList: $equipmentList, coHosts: $coHosts)';
}


}

/// @nodoc
abstract mixin class $StartLivePayloadCopyWith<$Res>  {
  factory $StartLivePayloadCopyWith(StartLivePayload value, $Res Function(StartLivePayload) _then) = _$StartLivePayloadCopyWithImpl;
@useResult
$Res call({
 String title, String liveType, String category, String access, String? gymId, String? scheduledFor, bool isRecurring, List<String> equipmentList, List<String> coHosts
});




}
/// @nodoc
class _$StartLivePayloadCopyWithImpl<$Res>
    implements $StartLivePayloadCopyWith<$Res> {
  _$StartLivePayloadCopyWithImpl(this._self, this._then);

  final StartLivePayload _self;
  final $Res Function(StartLivePayload) _then;

/// Create a copy of StartLivePayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? liveType = null,Object? category = null,Object? access = null,Object? gymId = freezed,Object? scheduledFor = freezed,Object? isRecurring = null,Object? equipmentList = null,Object? coHosts = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,liveType: null == liveType ? _self.liveType : liveType // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,access: null == access ? _self.access : access // ignore: cast_nullable_to_non_nullable
as String,gymId: freezed == gymId ? _self.gymId : gymId // ignore: cast_nullable_to_non_nullable
as String?,scheduledFor: freezed == scheduledFor ? _self.scheduledFor : scheduledFor // ignore: cast_nullable_to_non_nullable
as String?,isRecurring: null == isRecurring ? _self.isRecurring : isRecurring // ignore: cast_nullable_to_non_nullable
as bool,equipmentList: null == equipmentList ? _self.equipmentList : equipmentList // ignore: cast_nullable_to_non_nullable
as List<String>,coHosts: null == coHosts ? _self.coHosts : coHosts // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [StartLivePayload].
extension StartLivePayloadPatterns on StartLivePayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StartLivePayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StartLivePayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StartLivePayload value)  $default,){
final _that = this;
switch (_that) {
case _StartLivePayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StartLivePayload value)?  $default,){
final _that = this;
switch (_that) {
case _StartLivePayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String liveType,  String category,  String access,  String? gymId,  String? scheduledFor,  bool isRecurring,  List<String> equipmentList,  List<String> coHosts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StartLivePayload() when $default != null:
return $default(_that.title,_that.liveType,_that.category,_that.access,_that.gymId,_that.scheduledFor,_that.isRecurring,_that.equipmentList,_that.coHosts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String liveType,  String category,  String access,  String? gymId,  String? scheduledFor,  bool isRecurring,  List<String> equipmentList,  List<String> coHosts)  $default,) {final _that = this;
switch (_that) {
case _StartLivePayload():
return $default(_that.title,_that.liveType,_that.category,_that.access,_that.gymId,_that.scheduledFor,_that.isRecurring,_that.equipmentList,_that.coHosts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String liveType,  String category,  String access,  String? gymId,  String? scheduledFor,  bool isRecurring,  List<String> equipmentList,  List<String> coHosts)?  $default,) {final _that = this;
switch (_that) {
case _StartLivePayload() when $default != null:
return $default(_that.title,_that.liveType,_that.category,_that.access,_that.gymId,_that.scheduledFor,_that.isRecurring,_that.equipmentList,_that.coHosts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StartLivePayload implements StartLivePayload {
  const _StartLivePayload({required this.title, required this.liveType, required this.category, this.access = 'public', this.gymId, this.scheduledFor, this.isRecurring = false, final  List<String> equipmentList = const <String>[], final  List<String> coHosts = const <String>[]}): _equipmentList = equipmentList,_coHosts = coHosts;
  factory _StartLivePayload.fromJson(Map<String, dynamic> json) => _$StartLivePayloadFromJson(json);

@override final  String title;
@override final  String liveType;
@override final  String category;
@override@JsonKey() final  String access;
@override final  String? gymId;
@override final  String? scheduledFor;
@override@JsonKey() final  bool isRecurring;
 final  List<String> _equipmentList;
@override@JsonKey() List<String> get equipmentList {
  if (_equipmentList is EqualUnmodifiableListView) return _equipmentList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_equipmentList);
}

 final  List<String> _coHosts;
@override@JsonKey() List<String> get coHosts {
  if (_coHosts is EqualUnmodifiableListView) return _coHosts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_coHosts);
}


/// Create a copy of StartLivePayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StartLivePayloadCopyWith<_StartLivePayload> get copyWith => __$StartLivePayloadCopyWithImpl<_StartLivePayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StartLivePayloadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StartLivePayload&&(identical(other.title, title) || other.title == title)&&(identical(other.liveType, liveType) || other.liveType == liveType)&&(identical(other.category, category) || other.category == category)&&(identical(other.access, access) || other.access == access)&&(identical(other.gymId, gymId) || other.gymId == gymId)&&(identical(other.scheduledFor, scheduledFor) || other.scheduledFor == scheduledFor)&&(identical(other.isRecurring, isRecurring) || other.isRecurring == isRecurring)&&const DeepCollectionEquality().equals(other._equipmentList, _equipmentList)&&const DeepCollectionEquality().equals(other._coHosts, _coHosts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,liveType,category,access,gymId,scheduledFor,isRecurring,const DeepCollectionEquality().hash(_equipmentList),const DeepCollectionEquality().hash(_coHosts));

@override
String toString() {
  return 'StartLivePayload(title: $title, liveType: $liveType, category: $category, access: $access, gymId: $gymId, scheduledFor: $scheduledFor, isRecurring: $isRecurring, equipmentList: $equipmentList, coHosts: $coHosts)';
}


}

/// @nodoc
abstract mixin class _$StartLivePayloadCopyWith<$Res> implements $StartLivePayloadCopyWith<$Res> {
  factory _$StartLivePayloadCopyWith(_StartLivePayload value, $Res Function(_StartLivePayload) _then) = __$StartLivePayloadCopyWithImpl;
@override @useResult
$Res call({
 String title, String liveType, String category, String access, String? gymId, String? scheduledFor, bool isRecurring, List<String> equipmentList, List<String> coHosts
});




}
/// @nodoc
class __$StartLivePayloadCopyWithImpl<$Res>
    implements _$StartLivePayloadCopyWith<$Res> {
  __$StartLivePayloadCopyWithImpl(this._self, this._then);

  final _StartLivePayload _self;
  final $Res Function(_StartLivePayload) _then;

/// Create a copy of StartLivePayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? liveType = null,Object? category = null,Object? access = null,Object? gymId = freezed,Object? scheduledFor = freezed,Object? isRecurring = null,Object? equipmentList = null,Object? coHosts = null,}) {
  return _then(_StartLivePayload(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,liveType: null == liveType ? _self.liveType : liveType // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,access: null == access ? _self.access : access // ignore: cast_nullable_to_non_nullable
as String,gymId: freezed == gymId ? _self.gymId : gymId // ignore: cast_nullable_to_non_nullable
as String?,scheduledFor: freezed == scheduledFor ? _self.scheduledFor : scheduledFor // ignore: cast_nullable_to_non_nullable
as String?,isRecurring: null == isRecurring ? _self.isRecurring : isRecurring // ignore: cast_nullable_to_non_nullable
as bool,equipmentList: null == equipmentList ? _self._equipmentList : equipmentList // ignore: cast_nullable_to_non_nullable
as List<String>,coHosts: null == coHosts ? _self._coHosts : coHosts // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$RandomDropPayload {

 String get activityType; int get duration; String? get fee;
/// Create a copy of RandomDropPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RandomDropPayloadCopyWith<RandomDropPayload> get copyWith => _$RandomDropPayloadCopyWithImpl<RandomDropPayload>(this as RandomDropPayload, _$identity);

  /// Serializes this RandomDropPayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RandomDropPayload&&(identical(other.activityType, activityType) || other.activityType == activityType)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.fee, fee) || other.fee == fee));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,activityType,duration,fee);

@override
String toString() {
  return 'RandomDropPayload(activityType: $activityType, duration: $duration, fee: $fee)';
}


}

/// @nodoc
abstract mixin class $RandomDropPayloadCopyWith<$Res>  {
  factory $RandomDropPayloadCopyWith(RandomDropPayload value, $Res Function(RandomDropPayload) _then) = _$RandomDropPayloadCopyWithImpl;
@useResult
$Res call({
 String activityType, int duration, String? fee
});




}
/// @nodoc
class _$RandomDropPayloadCopyWithImpl<$Res>
    implements $RandomDropPayloadCopyWith<$Res> {
  _$RandomDropPayloadCopyWithImpl(this._self, this._then);

  final RandomDropPayload _self;
  final $Res Function(RandomDropPayload) _then;

/// Create a copy of RandomDropPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? activityType = null,Object? duration = null,Object? fee = freezed,}) {
  return _then(_self.copyWith(
activityType: null == activityType ? _self.activityType : activityType // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,fee: freezed == fee ? _self.fee : fee // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RandomDropPayload].
extension RandomDropPayloadPatterns on RandomDropPayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RandomDropPayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RandomDropPayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RandomDropPayload value)  $default,){
final _that = this;
switch (_that) {
case _RandomDropPayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RandomDropPayload value)?  $default,){
final _that = this;
switch (_that) {
case _RandomDropPayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String activityType,  int duration,  String? fee)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RandomDropPayload() when $default != null:
return $default(_that.activityType,_that.duration,_that.fee);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String activityType,  int duration,  String? fee)  $default,) {final _that = this;
switch (_that) {
case _RandomDropPayload():
return $default(_that.activityType,_that.duration,_that.fee);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String activityType,  int duration,  String? fee)?  $default,) {final _that = this;
switch (_that) {
case _RandomDropPayload() when $default != null:
return $default(_that.activityType,_that.duration,_that.fee);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RandomDropPayload implements RandomDropPayload {
  const _RandomDropPayload({required this.activityType, required this.duration, this.fee});
  factory _RandomDropPayload.fromJson(Map<String, dynamic> json) => _$RandomDropPayloadFromJson(json);

@override final  String activityType;
@override final  int duration;
@override final  String? fee;

/// Create a copy of RandomDropPayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RandomDropPayloadCopyWith<_RandomDropPayload> get copyWith => __$RandomDropPayloadCopyWithImpl<_RandomDropPayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RandomDropPayloadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RandomDropPayload&&(identical(other.activityType, activityType) || other.activityType == activityType)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.fee, fee) || other.fee == fee));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,activityType,duration,fee);

@override
String toString() {
  return 'RandomDropPayload(activityType: $activityType, duration: $duration, fee: $fee)';
}


}

/// @nodoc
abstract mixin class _$RandomDropPayloadCopyWith<$Res> implements $RandomDropPayloadCopyWith<$Res> {
  factory _$RandomDropPayloadCopyWith(_RandomDropPayload value, $Res Function(_RandomDropPayload) _then) = __$RandomDropPayloadCopyWithImpl;
@override @useResult
$Res call({
 String activityType, int duration, String? fee
});




}
/// @nodoc
class __$RandomDropPayloadCopyWithImpl<$Res>
    implements _$RandomDropPayloadCopyWith<$Res> {
  __$RandomDropPayloadCopyWithImpl(this._self, this._then);

  final _RandomDropPayload _self;
  final $Res Function(_RandomDropPayload) _then;

/// Create a copy of RandomDropPayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? activityType = null,Object? duration = null,Object? fee = freezed,}) {
  return _then(_RandomDropPayload(
activityType: null == activityType ? _self.activityType : activityType // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,fee: freezed == fee ? _self.fee : fee // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$RandomDropStatus {

 String get status; int get timeoutSeconds; String? get liveId; LiveCredentials? get credentials;
/// Create a copy of RandomDropStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RandomDropStatusCopyWith<RandomDropStatus> get copyWith => _$RandomDropStatusCopyWithImpl<RandomDropStatus>(this as RandomDropStatus, _$identity);

  /// Serializes this RandomDropStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RandomDropStatus&&(identical(other.status, status) || other.status == status)&&(identical(other.timeoutSeconds, timeoutSeconds) || other.timeoutSeconds == timeoutSeconds)&&(identical(other.liveId, liveId) || other.liveId == liveId)&&(identical(other.credentials, credentials) || other.credentials == credentials));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,timeoutSeconds,liveId,credentials);

@override
String toString() {
  return 'RandomDropStatus(status: $status, timeoutSeconds: $timeoutSeconds, liveId: $liveId, credentials: $credentials)';
}


}

/// @nodoc
abstract mixin class $RandomDropStatusCopyWith<$Res>  {
  factory $RandomDropStatusCopyWith(RandomDropStatus value, $Res Function(RandomDropStatus) _then) = _$RandomDropStatusCopyWithImpl;
@useResult
$Res call({
 String status, int timeoutSeconds, String? liveId, LiveCredentials? credentials
});


$LiveCredentialsCopyWith<$Res>? get credentials;

}
/// @nodoc
class _$RandomDropStatusCopyWithImpl<$Res>
    implements $RandomDropStatusCopyWith<$Res> {
  _$RandomDropStatusCopyWithImpl(this._self, this._then);

  final RandomDropStatus _self;
  final $Res Function(RandomDropStatus) _then;

/// Create a copy of RandomDropStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? timeoutSeconds = null,Object? liveId = freezed,Object? credentials = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,timeoutSeconds: null == timeoutSeconds ? _self.timeoutSeconds : timeoutSeconds // ignore: cast_nullable_to_non_nullable
as int,liveId: freezed == liveId ? _self.liveId : liveId // ignore: cast_nullable_to_non_nullable
as String?,credentials: freezed == credentials ? _self.credentials : credentials // ignore: cast_nullable_to_non_nullable
as LiveCredentials?,
  ));
}
/// Create a copy of RandomDropStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LiveCredentialsCopyWith<$Res>? get credentials {
    if (_self.credentials == null) {
    return null;
  }

  return $LiveCredentialsCopyWith<$Res>(_self.credentials!, (value) {
    return _then(_self.copyWith(credentials: value));
  });
}
}


/// Adds pattern-matching-related methods to [RandomDropStatus].
extension RandomDropStatusPatterns on RandomDropStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RandomDropStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RandomDropStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RandomDropStatus value)  $default,){
final _that = this;
switch (_that) {
case _RandomDropStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RandomDropStatus value)?  $default,){
final _that = this;
switch (_that) {
case _RandomDropStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String status,  int timeoutSeconds,  String? liveId,  LiveCredentials? credentials)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RandomDropStatus() when $default != null:
return $default(_that.status,_that.timeoutSeconds,_that.liveId,_that.credentials);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String status,  int timeoutSeconds,  String? liveId,  LiveCredentials? credentials)  $default,) {final _that = this;
switch (_that) {
case _RandomDropStatus():
return $default(_that.status,_that.timeoutSeconds,_that.liveId,_that.credentials);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String status,  int timeoutSeconds,  String? liveId,  LiveCredentials? credentials)?  $default,) {final _that = this;
switch (_that) {
case _RandomDropStatus() when $default != null:
return $default(_that.status,_that.timeoutSeconds,_that.liveId,_that.credentials);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RandomDropStatus implements RandomDropStatus {
  const _RandomDropStatus({this.status = 'not_searching', this.timeoutSeconds = 0, this.liveId, this.credentials});
  factory _RandomDropStatus.fromJson(Map<String, dynamic> json) => _$RandomDropStatusFromJson(json);

@override@JsonKey() final  String status;
@override@JsonKey() final  int timeoutSeconds;
@override final  String? liveId;
@override final  LiveCredentials? credentials;

/// Create a copy of RandomDropStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RandomDropStatusCopyWith<_RandomDropStatus> get copyWith => __$RandomDropStatusCopyWithImpl<_RandomDropStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RandomDropStatusToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RandomDropStatus&&(identical(other.status, status) || other.status == status)&&(identical(other.timeoutSeconds, timeoutSeconds) || other.timeoutSeconds == timeoutSeconds)&&(identical(other.liveId, liveId) || other.liveId == liveId)&&(identical(other.credentials, credentials) || other.credentials == credentials));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,timeoutSeconds,liveId,credentials);

@override
String toString() {
  return 'RandomDropStatus(status: $status, timeoutSeconds: $timeoutSeconds, liveId: $liveId, credentials: $credentials)';
}


}

/// @nodoc
abstract mixin class _$RandomDropStatusCopyWith<$Res> implements $RandomDropStatusCopyWith<$Res> {
  factory _$RandomDropStatusCopyWith(_RandomDropStatus value, $Res Function(_RandomDropStatus) _then) = __$RandomDropStatusCopyWithImpl;
@override @useResult
$Res call({
 String status, int timeoutSeconds, String? liveId, LiveCredentials? credentials
});


@override $LiveCredentialsCopyWith<$Res>? get credentials;

}
/// @nodoc
class __$RandomDropStatusCopyWithImpl<$Res>
    implements _$RandomDropStatusCopyWith<$Res> {
  __$RandomDropStatusCopyWithImpl(this._self, this._then);

  final _RandomDropStatus _self;
  final $Res Function(_RandomDropStatus) _then;

/// Create a copy of RandomDropStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? timeoutSeconds = null,Object? liveId = freezed,Object? credentials = freezed,}) {
  return _then(_RandomDropStatus(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,timeoutSeconds: null == timeoutSeconds ? _self.timeoutSeconds : timeoutSeconds // ignore: cast_nullable_to_non_nullable
as int,liveId: freezed == liveId ? _self.liveId : liveId // ignore: cast_nullable_to_non_nullable
as String?,credentials: freezed == credentials ? _self.credentials : credentials // ignore: cast_nullable_to_non_nullable
as LiveCredentials?,
  ));
}

/// Create a copy of RandomDropStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LiveCredentialsCopyWith<$Res>? get credentials {
    if (_self.credentials == null) {
    return null;
  }

  return $LiveCredentialsCopyWith<$Res>(_self.credentials!, (value) {
    return _then(_self.copyWith(credentials: value));
  });
}
}


/// @nodoc
mixin _$JoinLiveResponse {

 LiveCredentials get credentials; String get liveType; String get hostName;
/// Create a copy of JoinLiveResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JoinLiveResponseCopyWith<JoinLiveResponse> get copyWith => _$JoinLiveResponseCopyWithImpl<JoinLiveResponse>(this as JoinLiveResponse, _$identity);

  /// Serializes this JoinLiveResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JoinLiveResponse&&(identical(other.credentials, credentials) || other.credentials == credentials)&&(identical(other.liveType, liveType) || other.liveType == liveType)&&(identical(other.hostName, hostName) || other.hostName == hostName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,credentials,liveType,hostName);

@override
String toString() {
  return 'JoinLiveResponse(credentials: $credentials, liveType: $liveType, hostName: $hostName)';
}


}

/// @nodoc
abstract mixin class $JoinLiveResponseCopyWith<$Res>  {
  factory $JoinLiveResponseCopyWith(JoinLiveResponse value, $Res Function(JoinLiveResponse) _then) = _$JoinLiveResponseCopyWithImpl;
@useResult
$Res call({
 LiveCredentials credentials, String liveType, String hostName
});


$LiveCredentialsCopyWith<$Res> get credentials;

}
/// @nodoc
class _$JoinLiveResponseCopyWithImpl<$Res>
    implements $JoinLiveResponseCopyWith<$Res> {
  _$JoinLiveResponseCopyWithImpl(this._self, this._then);

  final JoinLiveResponse _self;
  final $Res Function(JoinLiveResponse) _then;

/// Create a copy of JoinLiveResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? credentials = null,Object? liveType = null,Object? hostName = null,}) {
  return _then(_self.copyWith(
credentials: null == credentials ? _self.credentials : credentials // ignore: cast_nullable_to_non_nullable
as LiveCredentials,liveType: null == liveType ? _self.liveType : liveType // ignore: cast_nullable_to_non_nullable
as String,hostName: null == hostName ? _self.hostName : hostName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of JoinLiveResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LiveCredentialsCopyWith<$Res> get credentials {
  
  return $LiveCredentialsCopyWith<$Res>(_self.credentials, (value) {
    return _then(_self.copyWith(credentials: value));
  });
}
}


/// Adds pattern-matching-related methods to [JoinLiveResponse].
extension JoinLiveResponsePatterns on JoinLiveResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JoinLiveResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JoinLiveResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JoinLiveResponse value)  $default,){
final _that = this;
switch (_that) {
case _JoinLiveResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JoinLiveResponse value)?  $default,){
final _that = this;
switch (_that) {
case _JoinLiveResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LiveCredentials credentials,  String liveType,  String hostName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JoinLiveResponse() when $default != null:
return $default(_that.credentials,_that.liveType,_that.hostName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LiveCredentials credentials,  String liveType,  String hostName)  $default,) {final _that = this;
switch (_that) {
case _JoinLiveResponse():
return $default(_that.credentials,_that.liveType,_that.hostName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LiveCredentials credentials,  String liveType,  String hostName)?  $default,) {final _that = this;
switch (_that) {
case _JoinLiveResponse() when $default != null:
return $default(_that.credentials,_that.liveType,_that.hostName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _JoinLiveResponse implements JoinLiveResponse {
  const _JoinLiveResponse({required this.credentials, this.liveType = '', this.hostName = ''});
  factory _JoinLiveResponse.fromJson(Map<String, dynamic> json) => _$JoinLiveResponseFromJson(json);

@override final  LiveCredentials credentials;
@override@JsonKey() final  String liveType;
@override@JsonKey() final  String hostName;

/// Create a copy of JoinLiveResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JoinLiveResponseCopyWith<_JoinLiveResponse> get copyWith => __$JoinLiveResponseCopyWithImpl<_JoinLiveResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$JoinLiveResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _JoinLiveResponse&&(identical(other.credentials, credentials) || other.credentials == credentials)&&(identical(other.liveType, liveType) || other.liveType == liveType)&&(identical(other.hostName, hostName) || other.hostName == hostName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,credentials,liveType,hostName);

@override
String toString() {
  return 'JoinLiveResponse(credentials: $credentials, liveType: $liveType, hostName: $hostName)';
}


}

/// @nodoc
abstract mixin class _$JoinLiveResponseCopyWith<$Res> implements $JoinLiveResponseCopyWith<$Res> {
  factory _$JoinLiveResponseCopyWith(_JoinLiveResponse value, $Res Function(_JoinLiveResponse) _then) = __$JoinLiveResponseCopyWithImpl;
@override @useResult
$Res call({
 LiveCredentials credentials, String liveType, String hostName
});


@override $LiveCredentialsCopyWith<$Res> get credentials;

}
/// @nodoc
class __$JoinLiveResponseCopyWithImpl<$Res>
    implements _$JoinLiveResponseCopyWith<$Res> {
  __$JoinLiveResponseCopyWithImpl(this._self, this._then);

  final _JoinLiveResponse _self;
  final $Res Function(_JoinLiveResponse) _then;

/// Create a copy of JoinLiveResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? credentials = null,Object? liveType = null,Object? hostName = null,}) {
  return _then(_JoinLiveResponse(
credentials: null == credentials ? _self.credentials : credentials // ignore: cast_nullable_to_non_nullable
as LiveCredentials,liveType: null == liveType ? _self.liveType : liveType // ignore: cast_nullable_to_non_nullable
as String,hostName: null == hostName ? _self.hostName : hostName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of JoinLiveResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LiveCredentialsCopyWith<$Res> get credentials {
  
  return $LiveCredentialsCopyWith<$Res>(_self.credentials, (value) {
    return _then(_self.copyWith(credentials: value));
  });
}
}


/// @nodoc
mixin _$StartLiveResponse {

 BuddyLive get live; LiveCredentials get credentials;
/// Create a copy of StartLiveResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StartLiveResponseCopyWith<StartLiveResponse> get copyWith => _$StartLiveResponseCopyWithImpl<StartLiveResponse>(this as StartLiveResponse, _$identity);

  /// Serializes this StartLiveResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StartLiveResponse&&(identical(other.live, live) || other.live == live)&&(identical(other.credentials, credentials) || other.credentials == credentials));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,live,credentials);

@override
String toString() {
  return 'StartLiveResponse(live: $live, credentials: $credentials)';
}


}

/// @nodoc
abstract mixin class $StartLiveResponseCopyWith<$Res>  {
  factory $StartLiveResponseCopyWith(StartLiveResponse value, $Res Function(StartLiveResponse) _then) = _$StartLiveResponseCopyWithImpl;
@useResult
$Res call({
 BuddyLive live, LiveCredentials credentials
});


$BuddyLiveCopyWith<$Res> get live;$LiveCredentialsCopyWith<$Res> get credentials;

}
/// @nodoc
class _$StartLiveResponseCopyWithImpl<$Res>
    implements $StartLiveResponseCopyWith<$Res> {
  _$StartLiveResponseCopyWithImpl(this._self, this._then);

  final StartLiveResponse _self;
  final $Res Function(StartLiveResponse) _then;

/// Create a copy of StartLiveResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? live = null,Object? credentials = null,}) {
  return _then(_self.copyWith(
live: null == live ? _self.live : live // ignore: cast_nullable_to_non_nullable
as BuddyLive,credentials: null == credentials ? _self.credentials : credentials // ignore: cast_nullable_to_non_nullable
as LiveCredentials,
  ));
}
/// Create a copy of StartLiveResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BuddyLiveCopyWith<$Res> get live {
  
  return $BuddyLiveCopyWith<$Res>(_self.live, (value) {
    return _then(_self.copyWith(live: value));
  });
}/// Create a copy of StartLiveResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LiveCredentialsCopyWith<$Res> get credentials {
  
  return $LiveCredentialsCopyWith<$Res>(_self.credentials, (value) {
    return _then(_self.copyWith(credentials: value));
  });
}
}


/// Adds pattern-matching-related methods to [StartLiveResponse].
extension StartLiveResponsePatterns on StartLiveResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StartLiveResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StartLiveResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StartLiveResponse value)  $default,){
final _that = this;
switch (_that) {
case _StartLiveResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StartLiveResponse value)?  $default,){
final _that = this;
switch (_that) {
case _StartLiveResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( BuddyLive live,  LiveCredentials credentials)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StartLiveResponse() when $default != null:
return $default(_that.live,_that.credentials);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( BuddyLive live,  LiveCredentials credentials)  $default,) {final _that = this;
switch (_that) {
case _StartLiveResponse():
return $default(_that.live,_that.credentials);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( BuddyLive live,  LiveCredentials credentials)?  $default,) {final _that = this;
switch (_that) {
case _StartLiveResponse() when $default != null:
return $default(_that.live,_that.credentials);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StartLiveResponse implements StartLiveResponse {
  const _StartLiveResponse({required this.live, required this.credentials});
  factory _StartLiveResponse.fromJson(Map<String, dynamic> json) => _$StartLiveResponseFromJson(json);

@override final  BuddyLive live;
@override final  LiveCredentials credentials;

/// Create a copy of StartLiveResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StartLiveResponseCopyWith<_StartLiveResponse> get copyWith => __$StartLiveResponseCopyWithImpl<_StartLiveResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StartLiveResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StartLiveResponse&&(identical(other.live, live) || other.live == live)&&(identical(other.credentials, credentials) || other.credentials == credentials));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,live,credentials);

@override
String toString() {
  return 'StartLiveResponse(live: $live, credentials: $credentials)';
}


}

/// @nodoc
abstract mixin class _$StartLiveResponseCopyWith<$Res> implements $StartLiveResponseCopyWith<$Res> {
  factory _$StartLiveResponseCopyWith(_StartLiveResponse value, $Res Function(_StartLiveResponse) _then) = __$StartLiveResponseCopyWithImpl;
@override @useResult
$Res call({
 BuddyLive live, LiveCredentials credentials
});


@override $BuddyLiveCopyWith<$Res> get live;@override $LiveCredentialsCopyWith<$Res> get credentials;

}
/// @nodoc
class __$StartLiveResponseCopyWithImpl<$Res>
    implements _$StartLiveResponseCopyWith<$Res> {
  __$StartLiveResponseCopyWithImpl(this._self, this._then);

  final _StartLiveResponse _self;
  final $Res Function(_StartLiveResponse) _then;

/// Create a copy of StartLiveResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? live = null,Object? credentials = null,}) {
  return _then(_StartLiveResponse(
live: null == live ? _self.live : live // ignore: cast_nullable_to_non_nullable
as BuddyLive,credentials: null == credentials ? _self.credentials : credentials // ignore: cast_nullable_to_non_nullable
as LiveCredentials,
  ));
}

/// Create a copy of StartLiveResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BuddyLiveCopyWith<$Res> get live {
  
  return $BuddyLiveCopyWith<$Res>(_self.live, (value) {
    return _then(_self.copyWith(live: value));
  });
}/// Create a copy of StartLiveResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LiveCredentialsCopyWith<$Res> get credentials {
  
  return $LiveCredentialsCopyWith<$Res>(_self.credentials, (value) {
    return _then(_self.copyWith(credentials: value));
  });
}
}

// dart format on
