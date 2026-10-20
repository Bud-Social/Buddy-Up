// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'alarm.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AlarmSound {

 String get id; String get name; String get source;@JsonKey(name: 'audio_url') String get audioUrl;@JsonKey(name: 'duration_ms') int get durationMs; String get visibility; String get owner;@JsonKey(name: 'is_mine') bool get isMine;
/// Create a copy of AlarmSound
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AlarmSoundCopyWith<AlarmSound> get copyWith => _$AlarmSoundCopyWithImpl<AlarmSound>(this as AlarmSound, _$identity);

  /// Serializes this AlarmSound to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AlarmSound&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.source, source) || other.source == source)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.owner, owner) || other.owner == owner)&&(identical(other.isMine, isMine) || other.isMine == isMine));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,source,audioUrl,durationMs,visibility,owner,isMine);

@override
String toString() {
  return 'AlarmSound(id: $id, name: $name, source: $source, audioUrl: $audioUrl, durationMs: $durationMs, visibility: $visibility, owner: $owner, isMine: $isMine)';
}


}

/// @nodoc
abstract mixin class $AlarmSoundCopyWith<$Res>  {
  factory $AlarmSoundCopyWith(AlarmSound value, $Res Function(AlarmSound) _then) = _$AlarmSoundCopyWithImpl;
@useResult
$Res call({
 String id, String name, String source,@JsonKey(name: 'audio_url') String audioUrl,@JsonKey(name: 'duration_ms') int durationMs, String visibility, String owner,@JsonKey(name: 'is_mine') bool isMine
});




}
/// @nodoc
class _$AlarmSoundCopyWithImpl<$Res>
    implements $AlarmSoundCopyWith<$Res> {
  _$AlarmSoundCopyWithImpl(this._self, this._then);

  final AlarmSound _self;
  final $Res Function(AlarmSound) _then;

/// Create a copy of AlarmSound
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? source = null,Object? audioUrl = null,Object? durationMs = null,Object? visibility = null,Object? owner = null,Object? isMine = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,audioUrl: null == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as String,owner: null == owner ? _self.owner : owner // ignore: cast_nullable_to_non_nullable
as String,isMine: null == isMine ? _self.isMine : isMine // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AlarmSound].
extension AlarmSoundPatterns on AlarmSound {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AlarmSound value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AlarmSound() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AlarmSound value)  $default,){
final _that = this;
switch (_that) {
case _AlarmSound():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AlarmSound value)?  $default,){
final _that = this;
switch (_that) {
case _AlarmSound() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String source, @JsonKey(name: 'audio_url')  String audioUrl, @JsonKey(name: 'duration_ms')  int durationMs,  String visibility,  String owner, @JsonKey(name: 'is_mine')  bool isMine)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AlarmSound() when $default != null:
return $default(_that.id,_that.name,_that.source,_that.audioUrl,_that.durationMs,_that.visibility,_that.owner,_that.isMine);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String source, @JsonKey(name: 'audio_url')  String audioUrl, @JsonKey(name: 'duration_ms')  int durationMs,  String visibility,  String owner, @JsonKey(name: 'is_mine')  bool isMine)  $default,) {final _that = this;
switch (_that) {
case _AlarmSound():
return $default(_that.id,_that.name,_that.source,_that.audioUrl,_that.durationMs,_that.visibility,_that.owner,_that.isMine);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String source, @JsonKey(name: 'audio_url')  String audioUrl, @JsonKey(name: 'duration_ms')  int durationMs,  String visibility,  String owner, @JsonKey(name: 'is_mine')  bool isMine)?  $default,) {final _that = this;
switch (_that) {
case _AlarmSound() when $default != null:
return $default(_that.id,_that.name,_that.source,_that.audioUrl,_that.durationMs,_that.visibility,_that.owner,_that.isMine);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AlarmSound implements AlarmSound {
  const _AlarmSound({required this.id, required this.name, this.source = 'upload', @JsonKey(name: 'audio_url') this.audioUrl = '', @JsonKey(name: 'duration_ms') this.durationMs = 0, this.visibility = 'private', this.owner = '', @JsonKey(name: 'is_mine') this.isMine = false});
  factory _AlarmSound.fromJson(Map<String, dynamic> json) => _$AlarmSoundFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey() final  String source;
@override@JsonKey(name: 'audio_url') final  String audioUrl;
@override@JsonKey(name: 'duration_ms') final  int durationMs;
@override@JsonKey() final  String visibility;
@override@JsonKey() final  String owner;
@override@JsonKey(name: 'is_mine') final  bool isMine;

/// Create a copy of AlarmSound
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AlarmSoundCopyWith<_AlarmSound> get copyWith => __$AlarmSoundCopyWithImpl<_AlarmSound>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AlarmSoundToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AlarmSound&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.source, source) || other.source == source)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.owner, owner) || other.owner == owner)&&(identical(other.isMine, isMine) || other.isMine == isMine));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,source,audioUrl,durationMs,visibility,owner,isMine);

@override
String toString() {
  return 'AlarmSound(id: $id, name: $name, source: $source, audioUrl: $audioUrl, durationMs: $durationMs, visibility: $visibility, owner: $owner, isMine: $isMine)';
}


}

/// @nodoc
abstract mixin class _$AlarmSoundCopyWith<$Res> implements $AlarmSoundCopyWith<$Res> {
  factory _$AlarmSoundCopyWith(_AlarmSound value, $Res Function(_AlarmSound) _then) = __$AlarmSoundCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String source,@JsonKey(name: 'audio_url') String audioUrl,@JsonKey(name: 'duration_ms') int durationMs, String visibility, String owner,@JsonKey(name: 'is_mine') bool isMine
});




}
/// @nodoc
class __$AlarmSoundCopyWithImpl<$Res>
    implements _$AlarmSoundCopyWith<$Res> {
  __$AlarmSoundCopyWithImpl(this._self, this._then);

  final _AlarmSound _self;
  final $Res Function(_AlarmSound) _then;

/// Create a copy of AlarmSound
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? source = null,Object? audioUrl = null,Object? durationMs = null,Object? visibility = null,Object? owner = null,Object? isMine = null,}) {
  return _then(_AlarmSound(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,audioUrl: null == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as String,owner: null == owner ? _self.owner : owner // ignore: cast_nullable_to_non_nullable
as String,isMine: null == isMine ? _self.isMine : isMine // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$Alarm {

 String get id; String get time;@JsonKey(name: 'days_mask') int get daysMask; String get label; AlarmSound? get sound; bool get enabled;@JsonKey(name: 'snooze_minutes') int get snoozeMinutes;
/// Create a copy of Alarm
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AlarmCopyWith<Alarm> get copyWith => _$AlarmCopyWithImpl<Alarm>(this as Alarm, _$identity);

  /// Serializes this Alarm to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Alarm&&(identical(other.id, id) || other.id == id)&&(identical(other.time, time) || other.time == time)&&(identical(other.daysMask, daysMask) || other.daysMask == daysMask)&&(identical(other.label, label) || other.label == label)&&(identical(other.sound, sound) || other.sound == sound)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.snoozeMinutes, snoozeMinutes) || other.snoozeMinutes == snoozeMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,time,daysMask,label,sound,enabled,snoozeMinutes);

@override
String toString() {
  return 'Alarm(id: $id, time: $time, daysMask: $daysMask, label: $label, sound: $sound, enabled: $enabled, snoozeMinutes: $snoozeMinutes)';
}


}

/// @nodoc
abstract mixin class $AlarmCopyWith<$Res>  {
  factory $AlarmCopyWith(Alarm value, $Res Function(Alarm) _then) = _$AlarmCopyWithImpl;
@useResult
$Res call({
 String id, String time,@JsonKey(name: 'days_mask') int daysMask, String label, AlarmSound? sound, bool enabled,@JsonKey(name: 'snooze_minutes') int snoozeMinutes
});


$AlarmSoundCopyWith<$Res>? get sound;

}
/// @nodoc
class _$AlarmCopyWithImpl<$Res>
    implements $AlarmCopyWith<$Res> {
  _$AlarmCopyWithImpl(this._self, this._then);

  final Alarm _self;
  final $Res Function(Alarm) _then;

/// Create a copy of Alarm
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? time = null,Object? daysMask = null,Object? label = null,Object? sound = freezed,Object? enabled = null,Object? snoozeMinutes = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,daysMask: null == daysMask ? _self.daysMask : daysMask // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,sound: freezed == sound ? _self.sound : sound // ignore: cast_nullable_to_non_nullable
as AlarmSound?,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,snoozeMinutes: null == snoozeMinutes ? _self.snoozeMinutes : snoozeMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of Alarm
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlarmSoundCopyWith<$Res>? get sound {
    if (_self.sound == null) {
    return null;
  }

  return $AlarmSoundCopyWith<$Res>(_self.sound!, (value) {
    return _then(_self.copyWith(sound: value));
  });
}
}


/// Adds pattern-matching-related methods to [Alarm].
extension AlarmPatterns on Alarm {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Alarm value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Alarm() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Alarm value)  $default,){
final _that = this;
switch (_that) {
case _Alarm():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Alarm value)?  $default,){
final _that = this;
switch (_that) {
case _Alarm() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String time, @JsonKey(name: 'days_mask')  int daysMask,  String label,  AlarmSound? sound,  bool enabled, @JsonKey(name: 'snooze_minutes')  int snoozeMinutes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Alarm() when $default != null:
return $default(_that.id,_that.time,_that.daysMask,_that.label,_that.sound,_that.enabled,_that.snoozeMinutes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String time, @JsonKey(name: 'days_mask')  int daysMask,  String label,  AlarmSound? sound,  bool enabled, @JsonKey(name: 'snooze_minutes')  int snoozeMinutes)  $default,) {final _that = this;
switch (_that) {
case _Alarm():
return $default(_that.id,_that.time,_that.daysMask,_that.label,_that.sound,_that.enabled,_that.snoozeMinutes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String time, @JsonKey(name: 'days_mask')  int daysMask,  String label,  AlarmSound? sound,  bool enabled, @JsonKey(name: 'snooze_minutes')  int snoozeMinutes)?  $default,) {final _that = this;
switch (_that) {
case _Alarm() when $default != null:
return $default(_that.id,_that.time,_that.daysMask,_that.label,_that.sound,_that.enabled,_that.snoozeMinutes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Alarm implements Alarm {
  const _Alarm({required this.id, required this.time, @JsonKey(name: 'days_mask') this.daysMask = 0, this.label = '', this.sound, this.enabled = true, @JsonKey(name: 'snooze_minutes') this.snoozeMinutes = 5});
  factory _Alarm.fromJson(Map<String, dynamic> json) => _$AlarmFromJson(json);

@override final  String id;
@override final  String time;
@override@JsonKey(name: 'days_mask') final  int daysMask;
@override@JsonKey() final  String label;
@override final  AlarmSound? sound;
@override@JsonKey() final  bool enabled;
@override@JsonKey(name: 'snooze_minutes') final  int snoozeMinutes;

/// Create a copy of Alarm
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AlarmCopyWith<_Alarm> get copyWith => __$AlarmCopyWithImpl<_Alarm>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AlarmToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Alarm&&(identical(other.id, id) || other.id == id)&&(identical(other.time, time) || other.time == time)&&(identical(other.daysMask, daysMask) || other.daysMask == daysMask)&&(identical(other.label, label) || other.label == label)&&(identical(other.sound, sound) || other.sound == sound)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.snoozeMinutes, snoozeMinutes) || other.snoozeMinutes == snoozeMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,time,daysMask,label,sound,enabled,snoozeMinutes);

@override
String toString() {
  return 'Alarm(id: $id, time: $time, daysMask: $daysMask, label: $label, sound: $sound, enabled: $enabled, snoozeMinutes: $snoozeMinutes)';
}


}

/// @nodoc
abstract mixin class _$AlarmCopyWith<$Res> implements $AlarmCopyWith<$Res> {
  factory _$AlarmCopyWith(_Alarm value, $Res Function(_Alarm) _then) = __$AlarmCopyWithImpl;
@override @useResult
$Res call({
 String id, String time,@JsonKey(name: 'days_mask') int daysMask, String label, AlarmSound? sound, bool enabled,@JsonKey(name: 'snooze_minutes') int snoozeMinutes
});


@override $AlarmSoundCopyWith<$Res>? get sound;

}
/// @nodoc
class __$AlarmCopyWithImpl<$Res>
    implements _$AlarmCopyWith<$Res> {
  __$AlarmCopyWithImpl(this._self, this._then);

  final _Alarm _self;
  final $Res Function(_Alarm) _then;

/// Create a copy of Alarm
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? time = null,Object? daysMask = null,Object? label = null,Object? sound = freezed,Object? enabled = null,Object? snoozeMinutes = null,}) {
  return _then(_Alarm(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,daysMask: null == daysMask ? _self.daysMask : daysMask // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,sound: freezed == sound ? _self.sound : sound // ignore: cast_nullable_to_non_nullable
as AlarmSound?,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,snoozeMinutes: null == snoozeMinutes ? _self.snoozeMinutes : snoozeMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of Alarm
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlarmSoundCopyWith<$Res>? get sound {
    if (_self.sound == null) {
    return null;
  }

  return $AlarmSoundCopyWith<$Res>(_self.sound!, (value) {
    return _then(_self.copyWith(sound: value));
  });
}
}


/// @nodoc
mixin _$AlarmSender {

@JsonKey(name: 'profile_id') String? get profileId; String? get username;@JsonKey(name: 'display_name') String? get displayName;@JsonKey(name: 'avatar_url') String? get avatarUrl;
/// Create a copy of AlarmSender
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AlarmSenderCopyWith<AlarmSender> get copyWith => _$AlarmSenderCopyWithImpl<AlarmSender>(this as AlarmSender, _$identity);

  /// Serializes this AlarmSender to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AlarmSender&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,profileId,username,displayName,avatarUrl);

@override
String toString() {
  return 'AlarmSender(profileId: $profileId, username: $username, displayName: $displayName, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class $AlarmSenderCopyWith<$Res>  {
  factory $AlarmSenderCopyWith(AlarmSender value, $Res Function(AlarmSender) _then) = _$AlarmSenderCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'profile_id') String? profileId, String? username,@JsonKey(name: 'display_name') String? displayName,@JsonKey(name: 'avatar_url') String? avatarUrl
});




}
/// @nodoc
class _$AlarmSenderCopyWithImpl<$Res>
    implements $AlarmSenderCopyWith<$Res> {
  _$AlarmSenderCopyWithImpl(this._self, this._then);

  final AlarmSender _self;
  final $Res Function(AlarmSender) _then;

/// Create a copy of AlarmSender
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? profileId = freezed,Object? username = freezed,Object? displayName = freezed,Object? avatarUrl = freezed,}) {
  return _then(_self.copyWith(
profileId: freezed == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AlarmSender].
extension AlarmSenderPatterns on AlarmSender {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AlarmSender value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AlarmSender() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AlarmSender value)  $default,){
final _that = this;
switch (_that) {
case _AlarmSender():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AlarmSender value)?  $default,){
final _that = this;
switch (_that) {
case _AlarmSender() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'profile_id')  String? profileId,  String? username, @JsonKey(name: 'display_name')  String? displayName, @JsonKey(name: 'avatar_url')  String? avatarUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AlarmSender() when $default != null:
return $default(_that.profileId,_that.username,_that.displayName,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'profile_id')  String? profileId,  String? username, @JsonKey(name: 'display_name')  String? displayName, @JsonKey(name: 'avatar_url')  String? avatarUrl)  $default,) {final _that = this;
switch (_that) {
case _AlarmSender():
return $default(_that.profileId,_that.username,_that.displayName,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'profile_id')  String? profileId,  String? username, @JsonKey(name: 'display_name')  String? displayName, @JsonKey(name: 'avatar_url')  String? avatarUrl)?  $default,) {final _that = this;
switch (_that) {
case _AlarmSender() when $default != null:
return $default(_that.profileId,_that.username,_that.displayName,_that.avatarUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AlarmSender implements AlarmSender {
  const _AlarmSender({@JsonKey(name: 'profile_id') this.profileId, this.username, @JsonKey(name: 'display_name') this.displayName, @JsonKey(name: 'avatar_url') this.avatarUrl});
  factory _AlarmSender.fromJson(Map<String, dynamic> json) => _$AlarmSenderFromJson(json);

@override@JsonKey(name: 'profile_id') final  String? profileId;
@override final  String? username;
@override@JsonKey(name: 'display_name') final  String? displayName;
@override@JsonKey(name: 'avatar_url') final  String? avatarUrl;

/// Create a copy of AlarmSender
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AlarmSenderCopyWith<_AlarmSender> get copyWith => __$AlarmSenderCopyWithImpl<_AlarmSender>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AlarmSenderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AlarmSender&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,profileId,username,displayName,avatarUrl);

@override
String toString() {
  return 'AlarmSender(profileId: $profileId, username: $username, displayName: $displayName, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class _$AlarmSenderCopyWith<$Res> implements $AlarmSenderCopyWith<$Res> {
  factory _$AlarmSenderCopyWith(_AlarmSender value, $Res Function(_AlarmSender) _then) = __$AlarmSenderCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'profile_id') String? profileId, String? username,@JsonKey(name: 'display_name') String? displayName,@JsonKey(name: 'avatar_url') String? avatarUrl
});




}
/// @nodoc
class __$AlarmSenderCopyWithImpl<$Res>
    implements _$AlarmSenderCopyWith<$Res> {
  __$AlarmSenderCopyWithImpl(this._self, this._then);

  final _AlarmSender _self;
  final $Res Function(_AlarmSender) _then;

/// Create a copy of AlarmSender
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? profileId = freezed,Object? username = freezed,Object? displayName = freezed,Object? avatarUrl = freezed,}) {
  return _then(_AlarmSender(
profileId: freezed == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AlarmShare {

 String get id; AlarmSound get sound; AlarmSender? get sender; String get status;
/// Create a copy of AlarmShare
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AlarmShareCopyWith<AlarmShare> get copyWith => _$AlarmShareCopyWithImpl<AlarmShare>(this as AlarmShare, _$identity);

  /// Serializes this AlarmShare to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AlarmShare&&(identical(other.id, id) || other.id == id)&&(identical(other.sound, sound) || other.sound == sound)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sound,sender,status);

@override
String toString() {
  return 'AlarmShare(id: $id, sound: $sound, sender: $sender, status: $status)';
}


}

/// @nodoc
abstract mixin class $AlarmShareCopyWith<$Res>  {
  factory $AlarmShareCopyWith(AlarmShare value, $Res Function(AlarmShare) _then) = _$AlarmShareCopyWithImpl;
@useResult
$Res call({
 String id, AlarmSound sound, AlarmSender? sender, String status
});


$AlarmSoundCopyWith<$Res> get sound;$AlarmSenderCopyWith<$Res>? get sender;

}
/// @nodoc
class _$AlarmShareCopyWithImpl<$Res>
    implements $AlarmShareCopyWith<$Res> {
  _$AlarmShareCopyWithImpl(this._self, this._then);

  final AlarmShare _self;
  final $Res Function(AlarmShare) _then;

/// Create a copy of AlarmShare
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sound = null,Object? sender = freezed,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sound: null == sound ? _self.sound : sound // ignore: cast_nullable_to_non_nullable
as AlarmSound,sender: freezed == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as AlarmSender?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of AlarmShare
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlarmSoundCopyWith<$Res> get sound {
  
  return $AlarmSoundCopyWith<$Res>(_self.sound, (value) {
    return _then(_self.copyWith(sound: value));
  });
}/// Create a copy of AlarmShare
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlarmSenderCopyWith<$Res>? get sender {
    if (_self.sender == null) {
    return null;
  }

  return $AlarmSenderCopyWith<$Res>(_self.sender!, (value) {
    return _then(_self.copyWith(sender: value));
  });
}
}


/// Adds pattern-matching-related methods to [AlarmShare].
extension AlarmSharePatterns on AlarmShare {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AlarmShare value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AlarmShare() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AlarmShare value)  $default,){
final _that = this;
switch (_that) {
case _AlarmShare():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AlarmShare value)?  $default,){
final _that = this;
switch (_that) {
case _AlarmShare() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  AlarmSound sound,  AlarmSender? sender,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AlarmShare() when $default != null:
return $default(_that.id,_that.sound,_that.sender,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  AlarmSound sound,  AlarmSender? sender,  String status)  $default,) {final _that = this;
switch (_that) {
case _AlarmShare():
return $default(_that.id,_that.sound,_that.sender,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  AlarmSound sound,  AlarmSender? sender,  String status)?  $default,) {final _that = this;
switch (_that) {
case _AlarmShare() when $default != null:
return $default(_that.id,_that.sound,_that.sender,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AlarmShare implements AlarmShare {
  const _AlarmShare({required this.id, required this.sound, this.sender, this.status = 'pending'});
  factory _AlarmShare.fromJson(Map<String, dynamic> json) => _$AlarmShareFromJson(json);

@override final  String id;
@override final  AlarmSound sound;
@override final  AlarmSender? sender;
@override@JsonKey() final  String status;

/// Create a copy of AlarmShare
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AlarmShareCopyWith<_AlarmShare> get copyWith => __$AlarmShareCopyWithImpl<_AlarmShare>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AlarmShareToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AlarmShare&&(identical(other.id, id) || other.id == id)&&(identical(other.sound, sound) || other.sound == sound)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sound,sender,status);

@override
String toString() {
  return 'AlarmShare(id: $id, sound: $sound, sender: $sender, status: $status)';
}


}

/// @nodoc
abstract mixin class _$AlarmShareCopyWith<$Res> implements $AlarmShareCopyWith<$Res> {
  factory _$AlarmShareCopyWith(_AlarmShare value, $Res Function(_AlarmShare) _then) = __$AlarmShareCopyWithImpl;
@override @useResult
$Res call({
 String id, AlarmSound sound, AlarmSender? sender, String status
});


@override $AlarmSoundCopyWith<$Res> get sound;@override $AlarmSenderCopyWith<$Res>? get sender;

}
/// @nodoc
class __$AlarmShareCopyWithImpl<$Res>
    implements _$AlarmShareCopyWith<$Res> {
  __$AlarmShareCopyWithImpl(this._self, this._then);

  final _AlarmShare _self;
  final $Res Function(_AlarmShare) _then;

/// Create a copy of AlarmShare
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sound = null,Object? sender = freezed,Object? status = null,}) {
  return _then(_AlarmShare(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sound: null == sound ? _self.sound : sound // ignore: cast_nullable_to_non_nullable
as AlarmSound,sender: freezed == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as AlarmSender?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of AlarmShare
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlarmSoundCopyWith<$Res> get sound {
  
  return $AlarmSoundCopyWith<$Res>(_self.sound, (value) {
    return _then(_self.copyWith(sound: value));
  });
}/// Create a copy of AlarmShare
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlarmSenderCopyWith<$Res>? get sender {
    if (_self.sender == null) {
    return null;
  }

  return $AlarmSenderCopyWith<$Res>(_self.sender!, (value) {
    return _then(_self.copyWith(sender: value));
  });
}
}


/// @nodoc
mixin _$AlarmSuggestion {

 String get id; String get title; String? get note; String? get url; AlarmSender? get sender; String get status;
/// Create a copy of AlarmSuggestion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AlarmSuggestionCopyWith<AlarmSuggestion> get copyWith => _$AlarmSuggestionCopyWithImpl<AlarmSuggestion>(this as AlarmSuggestion, _$identity);

  /// Serializes this AlarmSuggestion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AlarmSuggestion&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.note, note) || other.note == note)&&(identical(other.url, url) || other.url == url)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,note,url,sender,status);

@override
String toString() {
  return 'AlarmSuggestion(id: $id, title: $title, note: $note, url: $url, sender: $sender, status: $status)';
}


}

/// @nodoc
abstract mixin class $AlarmSuggestionCopyWith<$Res>  {
  factory $AlarmSuggestionCopyWith(AlarmSuggestion value, $Res Function(AlarmSuggestion) _then) = _$AlarmSuggestionCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? note, String? url, AlarmSender? sender, String status
});


$AlarmSenderCopyWith<$Res>? get sender;

}
/// @nodoc
class _$AlarmSuggestionCopyWithImpl<$Res>
    implements $AlarmSuggestionCopyWith<$Res> {
  _$AlarmSuggestionCopyWithImpl(this._self, this._then);

  final AlarmSuggestion _self;
  final $Res Function(AlarmSuggestion) _then;

/// Create a copy of AlarmSuggestion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? note = freezed,Object? url = freezed,Object? sender = freezed,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,sender: freezed == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as AlarmSender?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of AlarmSuggestion
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlarmSenderCopyWith<$Res>? get sender {
    if (_self.sender == null) {
    return null;
  }

  return $AlarmSenderCopyWith<$Res>(_self.sender!, (value) {
    return _then(_self.copyWith(sender: value));
  });
}
}


/// Adds pattern-matching-related methods to [AlarmSuggestion].
extension AlarmSuggestionPatterns on AlarmSuggestion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AlarmSuggestion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AlarmSuggestion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AlarmSuggestion value)  $default,){
final _that = this;
switch (_that) {
case _AlarmSuggestion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AlarmSuggestion value)?  $default,){
final _that = this;
switch (_that) {
case _AlarmSuggestion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? note,  String? url,  AlarmSender? sender,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AlarmSuggestion() when $default != null:
return $default(_that.id,_that.title,_that.note,_that.url,_that.sender,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? note,  String? url,  AlarmSender? sender,  String status)  $default,) {final _that = this;
switch (_that) {
case _AlarmSuggestion():
return $default(_that.id,_that.title,_that.note,_that.url,_that.sender,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? note,  String? url,  AlarmSender? sender,  String status)?  $default,) {final _that = this;
switch (_that) {
case _AlarmSuggestion() when $default != null:
return $default(_that.id,_that.title,_that.note,_that.url,_that.sender,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AlarmSuggestion implements AlarmSuggestion {
  const _AlarmSuggestion({required this.id, required this.title, this.note, this.url, this.sender, this.status = 'pending'});
  factory _AlarmSuggestion.fromJson(Map<String, dynamic> json) => _$AlarmSuggestionFromJson(json);

@override final  String id;
@override final  String title;
@override final  String? note;
@override final  String? url;
@override final  AlarmSender? sender;
@override@JsonKey() final  String status;

/// Create a copy of AlarmSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AlarmSuggestionCopyWith<_AlarmSuggestion> get copyWith => __$AlarmSuggestionCopyWithImpl<_AlarmSuggestion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AlarmSuggestionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AlarmSuggestion&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.note, note) || other.note == note)&&(identical(other.url, url) || other.url == url)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,note,url,sender,status);

@override
String toString() {
  return 'AlarmSuggestion(id: $id, title: $title, note: $note, url: $url, sender: $sender, status: $status)';
}


}

/// @nodoc
abstract mixin class _$AlarmSuggestionCopyWith<$Res> implements $AlarmSuggestionCopyWith<$Res> {
  factory _$AlarmSuggestionCopyWith(_AlarmSuggestion value, $Res Function(_AlarmSuggestion) _then) = __$AlarmSuggestionCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? note, String? url, AlarmSender? sender, String status
});


@override $AlarmSenderCopyWith<$Res>? get sender;

}
/// @nodoc
class __$AlarmSuggestionCopyWithImpl<$Res>
    implements _$AlarmSuggestionCopyWith<$Res> {
  __$AlarmSuggestionCopyWithImpl(this._self, this._then);

  final _AlarmSuggestion _self;
  final $Res Function(_AlarmSuggestion) _then;

/// Create a copy of AlarmSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? note = freezed,Object? url = freezed,Object? sender = freezed,Object? status = null,}) {
  return _then(_AlarmSuggestion(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,sender: freezed == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as AlarmSender?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of AlarmSuggestion
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlarmSenderCopyWith<$Res>? get sender {
    if (_self.sender == null) {
    return null;
  }

  return $AlarmSenderCopyWith<$Res>(_self.sender!, (value) {
    return _then(_self.copyWith(sender: value));
  });
}
}

// dart format on
