// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'buddy.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BuddyRequestPayload {

 String get username;
/// Create a copy of BuddyRequestPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BuddyRequestPayloadCopyWith<BuddyRequestPayload> get copyWith => _$BuddyRequestPayloadCopyWithImpl<BuddyRequestPayload>(this as BuddyRequestPayload, _$identity);

  /// Serializes this BuddyRequestPayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BuddyRequestPayload&&(identical(other.username, username) || other.username == username));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username);

@override
String toString() {
  return 'BuddyRequestPayload(username: $username)';
}


}

/// @nodoc
abstract mixin class $BuddyRequestPayloadCopyWith<$Res>  {
  factory $BuddyRequestPayloadCopyWith(BuddyRequestPayload value, $Res Function(BuddyRequestPayload) _then) = _$BuddyRequestPayloadCopyWithImpl;
@useResult
$Res call({
 String username
});




}
/// @nodoc
class _$BuddyRequestPayloadCopyWithImpl<$Res>
    implements $BuddyRequestPayloadCopyWith<$Res> {
  _$BuddyRequestPayloadCopyWithImpl(this._self, this._then);

  final BuddyRequestPayload _self;
  final $Res Function(BuddyRequestPayload) _then;

/// Create a copy of BuddyRequestPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? username = null,}) {
  return _then(_self.copyWith(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BuddyRequestPayload].
extension BuddyRequestPayloadPatterns on BuddyRequestPayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BuddyRequestPayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BuddyRequestPayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BuddyRequestPayload value)  $default,){
final _that = this;
switch (_that) {
case _BuddyRequestPayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BuddyRequestPayload value)?  $default,){
final _that = this;
switch (_that) {
case _BuddyRequestPayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String username)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BuddyRequestPayload() when $default != null:
return $default(_that.username);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String username)  $default,) {final _that = this;
switch (_that) {
case _BuddyRequestPayload():
return $default(_that.username);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String username)?  $default,) {final _that = this;
switch (_that) {
case _BuddyRequestPayload() when $default != null:
return $default(_that.username);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BuddyRequestPayload implements BuddyRequestPayload {
  const _BuddyRequestPayload({required this.username});
  factory _BuddyRequestPayload.fromJson(Map<String, dynamic> json) => _$BuddyRequestPayloadFromJson(json);

@override final  String username;

/// Create a copy of BuddyRequestPayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BuddyRequestPayloadCopyWith<_BuddyRequestPayload> get copyWith => __$BuddyRequestPayloadCopyWithImpl<_BuddyRequestPayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BuddyRequestPayloadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BuddyRequestPayload&&(identical(other.username, username) || other.username == username));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username);

@override
String toString() {
  return 'BuddyRequestPayload(username: $username)';
}


}

/// @nodoc
abstract mixin class _$BuddyRequestPayloadCopyWith<$Res> implements $BuddyRequestPayloadCopyWith<$Res> {
  factory _$BuddyRequestPayloadCopyWith(_BuddyRequestPayload value, $Res Function(_BuddyRequestPayload) _then) = __$BuddyRequestPayloadCopyWithImpl;
@override @useResult
$Res call({
 String username
});




}
/// @nodoc
class __$BuddyRequestPayloadCopyWithImpl<$Res>
    implements _$BuddyRequestPayloadCopyWith<$Res> {
  __$BuddyRequestPayloadCopyWithImpl(this._self, this._then);

  final _BuddyRequestPayload _self;
  final $Res Function(_BuddyRequestPayload) _then;

/// Create a copy of BuddyRequestPayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? username = null,}) {
  return _then(_BuddyRequestPayload(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PingPayload {

 String get message;
/// Create a copy of PingPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PingPayloadCopyWith<PingPayload> get copyWith => _$PingPayloadCopyWithImpl<PingPayload>(this as PingPayload, _$identity);

  /// Serializes this PingPayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PingPayload&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'PingPayload(message: $message)';
}


}

/// @nodoc
abstract mixin class $PingPayloadCopyWith<$Res>  {
  factory $PingPayloadCopyWith(PingPayload value, $Res Function(PingPayload) _then) = _$PingPayloadCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$PingPayloadCopyWithImpl<$Res>
    implements $PingPayloadCopyWith<$Res> {
  _$PingPayloadCopyWithImpl(this._self, this._then);

  final PingPayload _self;
  final $Res Function(PingPayload) _then;

/// Create a copy of PingPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,}) {
  return _then(_self.copyWith(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PingPayload].
extension PingPayloadPatterns on PingPayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PingPayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PingPayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PingPayload value)  $default,){
final _that = this;
switch (_that) {
case _PingPayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PingPayload value)?  $default,){
final _that = this;
switch (_that) {
case _PingPayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PingPayload() when $default != null:
return $default(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String message)  $default,) {final _that = this;
switch (_that) {
case _PingPayload():
return $default(_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String message)?  $default,) {final _that = this;
switch (_that) {
case _PingPayload() when $default != null:
return $default(_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PingPayload implements PingPayload {
  const _PingPayload({required this.message});
  factory _PingPayload.fromJson(Map<String, dynamic> json) => _$PingPayloadFromJson(json);

@override final  String message;

/// Create a copy of PingPayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PingPayloadCopyWith<_PingPayload> get copyWith => __$PingPayloadCopyWithImpl<_PingPayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PingPayloadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PingPayload&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'PingPayload(message: $message)';
}


}

/// @nodoc
abstract mixin class _$PingPayloadCopyWith<$Res> implements $PingPayloadCopyWith<$Res> {
  factory _$PingPayloadCopyWith(_PingPayload value, $Res Function(_PingPayload) _then) = __$PingPayloadCopyWithImpl;
@override @useResult
$Res call({
 String message
});




}
/// @nodoc
class __$PingPayloadCopyWithImpl<$Res>
    implements _$PingPayloadCopyWith<$Res> {
  __$PingPayloadCopyWithImpl(this._self, this._then);

  final _PingPayload _self;
  final $Res Function(_PingPayload) _then;

/// Create a copy of PingPayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_PingPayload(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PresenceInfo {

 bool get online; String? get lastSeen;
/// Create a copy of PresenceInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PresenceInfoCopyWith<PresenceInfo> get copyWith => _$PresenceInfoCopyWithImpl<PresenceInfo>(this as PresenceInfo, _$identity);

  /// Serializes this PresenceInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PresenceInfo&&(identical(other.online, online) || other.online == online)&&(identical(other.lastSeen, lastSeen) || other.lastSeen == lastSeen));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,online,lastSeen);

@override
String toString() {
  return 'PresenceInfo(online: $online, lastSeen: $lastSeen)';
}


}

/// @nodoc
abstract mixin class $PresenceInfoCopyWith<$Res>  {
  factory $PresenceInfoCopyWith(PresenceInfo value, $Res Function(PresenceInfo) _then) = _$PresenceInfoCopyWithImpl;
@useResult
$Res call({
 bool online, String? lastSeen
});




}
/// @nodoc
class _$PresenceInfoCopyWithImpl<$Res>
    implements $PresenceInfoCopyWith<$Res> {
  _$PresenceInfoCopyWithImpl(this._self, this._then);

  final PresenceInfo _self;
  final $Res Function(PresenceInfo) _then;

/// Create a copy of PresenceInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? online = null,Object? lastSeen = freezed,}) {
  return _then(_self.copyWith(
online: null == online ? _self.online : online // ignore: cast_nullable_to_non_nullable
as bool,lastSeen: freezed == lastSeen ? _self.lastSeen : lastSeen // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PresenceInfo].
extension PresenceInfoPatterns on PresenceInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PresenceInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PresenceInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PresenceInfo value)  $default,){
final _that = this;
switch (_that) {
case _PresenceInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PresenceInfo value)?  $default,){
final _that = this;
switch (_that) {
case _PresenceInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool online,  String? lastSeen)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PresenceInfo() when $default != null:
return $default(_that.online,_that.lastSeen);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool online,  String? lastSeen)  $default,) {final _that = this;
switch (_that) {
case _PresenceInfo():
return $default(_that.online,_that.lastSeen);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool online,  String? lastSeen)?  $default,) {final _that = this;
switch (_that) {
case _PresenceInfo() when $default != null:
return $default(_that.online,_that.lastSeen);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PresenceInfo implements PresenceInfo {
  const _PresenceInfo({required this.online, this.lastSeen});
  factory _PresenceInfo.fromJson(Map<String, dynamic> json) => _$PresenceInfoFromJson(json);

@override final  bool online;
@override final  String? lastSeen;

/// Create a copy of PresenceInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PresenceInfoCopyWith<_PresenceInfo> get copyWith => __$PresenceInfoCopyWithImpl<_PresenceInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PresenceInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PresenceInfo&&(identical(other.online, online) || other.online == online)&&(identical(other.lastSeen, lastSeen) || other.lastSeen == lastSeen));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,online,lastSeen);

@override
String toString() {
  return 'PresenceInfo(online: $online, lastSeen: $lastSeen)';
}


}

/// @nodoc
abstract mixin class _$PresenceInfoCopyWith<$Res> implements $PresenceInfoCopyWith<$Res> {
  factory _$PresenceInfoCopyWith(_PresenceInfo value, $Res Function(_PresenceInfo) _then) = __$PresenceInfoCopyWithImpl;
@override @useResult
$Res call({
 bool online, String? lastSeen
});




}
/// @nodoc
class __$PresenceInfoCopyWithImpl<$Res>
    implements _$PresenceInfoCopyWith<$Res> {
  __$PresenceInfoCopyWithImpl(this._self, this._then);

  final _PresenceInfo _self;
  final $Res Function(_PresenceInfo) _then;

/// Create a copy of PresenceInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? online = null,Object? lastSeen = freezed,}) {
  return _then(_PresenceInfo(
online: null == online ? _self.online : online // ignore: cast_nullable_to_non_nullable
as bool,lastSeen: freezed == lastSeen ? _self.lastSeen : lastSeen // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
