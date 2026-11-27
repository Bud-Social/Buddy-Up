// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analytics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AnalyticsUserInfo {

 String get username;@JsonKey(name: 'display_name') String get displayName;@JsonKey(name: 'avatar_url') String get avatarUrl;@JsonKey(name: 'streak_days') int get streakDays;
/// Create a copy of AnalyticsUserInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalyticsUserInfoCopyWith<AnalyticsUserInfo> get copyWith => _$AnalyticsUserInfoCopyWithImpl<AnalyticsUserInfo>(this as AnalyticsUserInfo, _$identity);

  /// Serializes this AnalyticsUserInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalyticsUserInfo&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.streakDays, streakDays) || other.streakDays == streakDays));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username,displayName,avatarUrl,streakDays);

@override
String toString() {
  return 'AnalyticsUserInfo(username: $username, displayName: $displayName, avatarUrl: $avatarUrl, streakDays: $streakDays)';
}


}

/// @nodoc
abstract mixin class $AnalyticsUserInfoCopyWith<$Res>  {
  factory $AnalyticsUserInfoCopyWith(AnalyticsUserInfo value, $Res Function(AnalyticsUserInfo) _then) = _$AnalyticsUserInfoCopyWithImpl;
@useResult
$Res call({
 String username,@JsonKey(name: 'display_name') String displayName,@JsonKey(name: 'avatar_url') String avatarUrl,@JsonKey(name: 'streak_days') int streakDays
});




}
/// @nodoc
class _$AnalyticsUserInfoCopyWithImpl<$Res>
    implements $AnalyticsUserInfoCopyWith<$Res> {
  _$AnalyticsUserInfoCopyWithImpl(this._self, this._then);

  final AnalyticsUserInfo _self;
  final $Res Function(AnalyticsUserInfo) _then;

/// Create a copy of AnalyticsUserInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? username = null,Object? displayName = null,Object? avatarUrl = null,Object? streakDays = null,}) {
  return _then(_self.copyWith(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,streakDays: null == streakDays ? _self.streakDays : streakDays // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AnalyticsUserInfo].
extension AnalyticsUserInfoPatterns on AnalyticsUserInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalyticsUserInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalyticsUserInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalyticsUserInfo value)  $default,){
final _that = this;
switch (_that) {
case _AnalyticsUserInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalyticsUserInfo value)?  $default,){
final _that = this;
switch (_that) {
case _AnalyticsUserInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String username, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'avatar_url')  String avatarUrl, @JsonKey(name: 'streak_days')  int streakDays)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalyticsUserInfo() when $default != null:
return $default(_that.username,_that.displayName,_that.avatarUrl,_that.streakDays);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String username, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'avatar_url')  String avatarUrl, @JsonKey(name: 'streak_days')  int streakDays)  $default,) {final _that = this;
switch (_that) {
case _AnalyticsUserInfo():
return $default(_that.username,_that.displayName,_that.avatarUrl,_that.streakDays);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String username, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'avatar_url')  String avatarUrl, @JsonKey(name: 'streak_days')  int streakDays)?  $default,) {final _that = this;
switch (_that) {
case _AnalyticsUserInfo() when $default != null:
return $default(_that.username,_that.displayName,_that.avatarUrl,_that.streakDays);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnalyticsUserInfo implements AnalyticsUserInfo {
  const _AnalyticsUserInfo({this.username = '', @JsonKey(name: 'display_name') this.displayName = '', @JsonKey(name: 'avatar_url') this.avatarUrl = '', @JsonKey(name: 'streak_days') this.streakDays = 0});
  factory _AnalyticsUserInfo.fromJson(Map<String, dynamic> json) => _$AnalyticsUserInfoFromJson(json);

@override@JsonKey() final  String username;
@override@JsonKey(name: 'display_name') final  String displayName;
@override@JsonKey(name: 'avatar_url') final  String avatarUrl;
@override@JsonKey(name: 'streak_days') final  int streakDays;

/// Create a copy of AnalyticsUserInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalyticsUserInfoCopyWith<_AnalyticsUserInfo> get copyWith => __$AnalyticsUserInfoCopyWithImpl<_AnalyticsUserInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnalyticsUserInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalyticsUserInfo&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.streakDays, streakDays) || other.streakDays == streakDays));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username,displayName,avatarUrl,streakDays);

@override
String toString() {
  return 'AnalyticsUserInfo(username: $username, displayName: $displayName, avatarUrl: $avatarUrl, streakDays: $streakDays)';
}


}

/// @nodoc
abstract mixin class _$AnalyticsUserInfoCopyWith<$Res> implements $AnalyticsUserInfoCopyWith<$Res> {
  factory _$AnalyticsUserInfoCopyWith(_AnalyticsUserInfo value, $Res Function(_AnalyticsUserInfo) _then) = __$AnalyticsUserInfoCopyWithImpl;
@override @useResult
$Res call({
 String username,@JsonKey(name: 'display_name') String displayName,@JsonKey(name: 'avatar_url') String avatarUrl,@JsonKey(name: 'streak_days') int streakDays
});




}
/// @nodoc
class __$AnalyticsUserInfoCopyWithImpl<$Res>
    implements _$AnalyticsUserInfoCopyWith<$Res> {
  __$AnalyticsUserInfoCopyWithImpl(this._self, this._then);

  final _AnalyticsUserInfo _self;
  final $Res Function(_AnalyticsUserInfo) _then;

/// Create a copy of AnalyticsUserInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? username = null,Object? displayName = null,Object? avatarUrl = null,Object? streakDays = null,}) {
  return _then(_AnalyticsUserInfo(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,streakDays: null == streakDays ? _self.streakDays : streakDays // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ActivityTypeBreakdown {

 String get label; int get count; double get calories; double get distance; double get duration;@JsonKey(name: 'distance_km') double get distanceKm;
/// Create a copy of ActivityTypeBreakdown
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActivityTypeBreakdownCopyWith<ActivityTypeBreakdown> get copyWith => _$ActivityTypeBreakdownCopyWithImpl<ActivityTypeBreakdown>(this as ActivityTypeBreakdown, _$identity);

  /// Serializes this ActivityTypeBreakdown to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActivityTypeBreakdown&&(identical(other.label, label) || other.label == label)&&(identical(other.count, count) || other.count == count)&&(identical(other.calories, calories) || other.calories == calories)&&(identical(other.distance, distance) || other.distance == distance)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,count,calories,distance,duration,distanceKm);

@override
String toString() {
  return 'ActivityTypeBreakdown(label: $label, count: $count, calories: $calories, distance: $distance, duration: $duration, distanceKm: $distanceKm)';
}


}

/// @nodoc
abstract mixin class $ActivityTypeBreakdownCopyWith<$Res>  {
  factory $ActivityTypeBreakdownCopyWith(ActivityTypeBreakdown value, $Res Function(ActivityTypeBreakdown) _then) = _$ActivityTypeBreakdownCopyWithImpl;
@useResult
$Res call({
 String label, int count, double calories, double distance, double duration,@JsonKey(name: 'distance_km') double distanceKm
});




}
/// @nodoc
class _$ActivityTypeBreakdownCopyWithImpl<$Res>
    implements $ActivityTypeBreakdownCopyWith<$Res> {
  _$ActivityTypeBreakdownCopyWithImpl(this._self, this._then);

  final ActivityTypeBreakdown _self;
  final $Res Function(ActivityTypeBreakdown) _then;

/// Create a copy of ActivityTypeBreakdown
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? count = null,Object? calories = null,Object? distance = null,Object? duration = null,Object? distanceKm = null,}) {
  return _then(_self.copyWith(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,calories: null == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as double,distance: null == distance ? _self.distance : distance // ignore: cast_nullable_to_non_nullable
as double,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as double,distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [ActivityTypeBreakdown].
extension ActivityTypeBreakdownPatterns on ActivityTypeBreakdown {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActivityTypeBreakdown value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActivityTypeBreakdown() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActivityTypeBreakdown value)  $default,){
final _that = this;
switch (_that) {
case _ActivityTypeBreakdown():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActivityTypeBreakdown value)?  $default,){
final _that = this;
switch (_that) {
case _ActivityTypeBreakdown() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  int count,  double calories,  double distance,  double duration, @JsonKey(name: 'distance_km')  double distanceKm)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActivityTypeBreakdown() when $default != null:
return $default(_that.label,_that.count,_that.calories,_that.distance,_that.duration,_that.distanceKm);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  int count,  double calories,  double distance,  double duration, @JsonKey(name: 'distance_km')  double distanceKm)  $default,) {final _that = this;
switch (_that) {
case _ActivityTypeBreakdown():
return $default(_that.label,_that.count,_that.calories,_that.distance,_that.duration,_that.distanceKm);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  int count,  double calories,  double distance,  double duration, @JsonKey(name: 'distance_km')  double distanceKm)?  $default,) {final _that = this;
switch (_that) {
case _ActivityTypeBreakdown() when $default != null:
return $default(_that.label,_that.count,_that.calories,_that.distance,_that.duration,_that.distanceKm);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ActivityTypeBreakdown implements ActivityTypeBreakdown {
  const _ActivityTypeBreakdown({this.label = '', this.count = 0, this.calories = 0, this.distance = 0, this.duration = 0, @JsonKey(name: 'distance_km') this.distanceKm = 0});
  factory _ActivityTypeBreakdown.fromJson(Map<String, dynamic> json) => _$ActivityTypeBreakdownFromJson(json);

@override@JsonKey() final  String label;
@override@JsonKey() final  int count;
@override@JsonKey() final  double calories;
@override@JsonKey() final  double distance;
@override@JsonKey() final  double duration;
@override@JsonKey(name: 'distance_km') final  double distanceKm;

/// Create a copy of ActivityTypeBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActivityTypeBreakdownCopyWith<_ActivityTypeBreakdown> get copyWith => __$ActivityTypeBreakdownCopyWithImpl<_ActivityTypeBreakdown>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ActivityTypeBreakdownToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivityTypeBreakdown&&(identical(other.label, label) || other.label == label)&&(identical(other.count, count) || other.count == count)&&(identical(other.calories, calories) || other.calories == calories)&&(identical(other.distance, distance) || other.distance == distance)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,count,calories,distance,duration,distanceKm);

@override
String toString() {
  return 'ActivityTypeBreakdown(label: $label, count: $count, calories: $calories, distance: $distance, duration: $duration, distanceKm: $distanceKm)';
}


}

/// @nodoc
abstract mixin class _$ActivityTypeBreakdownCopyWith<$Res> implements $ActivityTypeBreakdownCopyWith<$Res> {
  factory _$ActivityTypeBreakdownCopyWith(_ActivityTypeBreakdown value, $Res Function(_ActivityTypeBreakdown) _then) = __$ActivityTypeBreakdownCopyWithImpl;
@override @useResult
$Res call({
 String label, int count, double calories, double distance, double duration,@JsonKey(name: 'distance_km') double distanceKm
});




}
/// @nodoc
class __$ActivityTypeBreakdownCopyWithImpl<$Res>
    implements _$ActivityTypeBreakdownCopyWith<$Res> {
  __$ActivityTypeBreakdownCopyWithImpl(this._self, this._then);

  final _ActivityTypeBreakdown _self;
  final $Res Function(_ActivityTypeBreakdown) _then;

/// Create a copy of ActivityTypeBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? count = null,Object? calories = null,Object? distance = null,Object? duration = null,Object? distanceKm = null,}) {
  return _then(_ActivityTypeBreakdown(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,calories: null == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as double,distance: null == distance ? _self.distance : distance // ignore: cast_nullable_to_non_nullable
as double,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as double,distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$WorkoutRecent {

@JsonKey(name: 'performed_at') String? get performedAt;@JsonKey(name: 'workout_type') String get workoutType; String get exercise;@JsonKey(name: 'duration_minutes') int get durationMinutes;@JsonKey(name: 'calories_burned') double? get caloriesBurned;
/// Create a copy of WorkoutRecent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutRecentCopyWith<WorkoutRecent> get copyWith => _$WorkoutRecentCopyWithImpl<WorkoutRecent>(this as WorkoutRecent, _$identity);

  /// Serializes this WorkoutRecent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkoutRecent&&(identical(other.performedAt, performedAt) || other.performedAt == performedAt)&&(identical(other.workoutType, workoutType) || other.workoutType == workoutType)&&(identical(other.exercise, exercise) || other.exercise == exercise)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.caloriesBurned, caloriesBurned) || other.caloriesBurned == caloriesBurned));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,performedAt,workoutType,exercise,durationMinutes,caloriesBurned);

@override
String toString() {
  return 'WorkoutRecent(performedAt: $performedAt, workoutType: $workoutType, exercise: $exercise, durationMinutes: $durationMinutes, caloriesBurned: $caloriesBurned)';
}


}

/// @nodoc
abstract mixin class $WorkoutRecentCopyWith<$Res>  {
  factory $WorkoutRecentCopyWith(WorkoutRecent value, $Res Function(WorkoutRecent) _then) = _$WorkoutRecentCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'performed_at') String? performedAt,@JsonKey(name: 'workout_type') String workoutType, String exercise,@JsonKey(name: 'duration_minutes') int durationMinutes,@JsonKey(name: 'calories_burned') double? caloriesBurned
});




}
/// @nodoc
class _$WorkoutRecentCopyWithImpl<$Res>
    implements $WorkoutRecentCopyWith<$Res> {
  _$WorkoutRecentCopyWithImpl(this._self, this._then);

  final WorkoutRecent _self;
  final $Res Function(WorkoutRecent) _then;

/// Create a copy of WorkoutRecent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? performedAt = freezed,Object? workoutType = null,Object? exercise = null,Object? durationMinutes = null,Object? caloriesBurned = freezed,}) {
  return _then(_self.copyWith(
performedAt: freezed == performedAt ? _self.performedAt : performedAt // ignore: cast_nullable_to_non_nullable
as String?,workoutType: null == workoutType ? _self.workoutType : workoutType // ignore: cast_nullable_to_non_nullable
as String,exercise: null == exercise ? _self.exercise : exercise // ignore: cast_nullable_to_non_nullable
as String,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,caloriesBurned: freezed == caloriesBurned ? _self.caloriesBurned : caloriesBurned // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkoutRecent].
extension WorkoutRecentPatterns on WorkoutRecent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkoutRecent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkoutRecent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkoutRecent value)  $default,){
final _that = this;
switch (_that) {
case _WorkoutRecent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkoutRecent value)?  $default,){
final _that = this;
switch (_that) {
case _WorkoutRecent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'performed_at')  String? performedAt, @JsonKey(name: 'workout_type')  String workoutType,  String exercise, @JsonKey(name: 'duration_minutes')  int durationMinutes, @JsonKey(name: 'calories_burned')  double? caloriesBurned)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkoutRecent() when $default != null:
return $default(_that.performedAt,_that.workoutType,_that.exercise,_that.durationMinutes,_that.caloriesBurned);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'performed_at')  String? performedAt, @JsonKey(name: 'workout_type')  String workoutType,  String exercise, @JsonKey(name: 'duration_minutes')  int durationMinutes, @JsonKey(name: 'calories_burned')  double? caloriesBurned)  $default,) {final _that = this;
switch (_that) {
case _WorkoutRecent():
return $default(_that.performedAt,_that.workoutType,_that.exercise,_that.durationMinutes,_that.caloriesBurned);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'performed_at')  String? performedAt, @JsonKey(name: 'workout_type')  String workoutType,  String exercise, @JsonKey(name: 'duration_minutes')  int durationMinutes, @JsonKey(name: 'calories_burned')  double? caloriesBurned)?  $default,) {final _that = this;
switch (_that) {
case _WorkoutRecent() when $default != null:
return $default(_that.performedAt,_that.workoutType,_that.exercise,_that.durationMinutes,_that.caloriesBurned);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkoutRecent implements WorkoutRecent {
  const _WorkoutRecent({@JsonKey(name: 'performed_at') this.performedAt, @JsonKey(name: 'workout_type') this.workoutType = '', this.exercise = '', @JsonKey(name: 'duration_minutes') this.durationMinutes = 0, @JsonKey(name: 'calories_burned') this.caloriesBurned});
  factory _WorkoutRecent.fromJson(Map<String, dynamic> json) => _$WorkoutRecentFromJson(json);

@override@JsonKey(name: 'performed_at') final  String? performedAt;
@override@JsonKey(name: 'workout_type') final  String workoutType;
@override@JsonKey() final  String exercise;
@override@JsonKey(name: 'duration_minutes') final  int durationMinutes;
@override@JsonKey(name: 'calories_burned') final  double? caloriesBurned;

/// Create a copy of WorkoutRecent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutRecentCopyWith<_WorkoutRecent> get copyWith => __$WorkoutRecentCopyWithImpl<_WorkoutRecent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkoutRecentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkoutRecent&&(identical(other.performedAt, performedAt) || other.performedAt == performedAt)&&(identical(other.workoutType, workoutType) || other.workoutType == workoutType)&&(identical(other.exercise, exercise) || other.exercise == exercise)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.caloriesBurned, caloriesBurned) || other.caloriesBurned == caloriesBurned));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,performedAt,workoutType,exercise,durationMinutes,caloriesBurned);

@override
String toString() {
  return 'WorkoutRecent(performedAt: $performedAt, workoutType: $workoutType, exercise: $exercise, durationMinutes: $durationMinutes, caloriesBurned: $caloriesBurned)';
}


}

/// @nodoc
abstract mixin class _$WorkoutRecentCopyWith<$Res> implements $WorkoutRecentCopyWith<$Res> {
  factory _$WorkoutRecentCopyWith(_WorkoutRecent value, $Res Function(_WorkoutRecent) _then) = __$WorkoutRecentCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'performed_at') String? performedAt,@JsonKey(name: 'workout_type') String workoutType, String exercise,@JsonKey(name: 'duration_minutes') int durationMinutes,@JsonKey(name: 'calories_burned') double? caloriesBurned
});




}
/// @nodoc
class __$WorkoutRecentCopyWithImpl<$Res>
    implements _$WorkoutRecentCopyWith<$Res> {
  __$WorkoutRecentCopyWithImpl(this._self, this._then);

  final _WorkoutRecent _self;
  final $Res Function(_WorkoutRecent) _then;

/// Create a copy of WorkoutRecent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? performedAt = freezed,Object? workoutType = null,Object? exercise = null,Object? durationMinutes = null,Object? caloriesBurned = freezed,}) {
  return _then(_WorkoutRecent(
performedAt: freezed == performedAt ? _self.performedAt : performedAt // ignore: cast_nullable_to_non_nullable
as String?,workoutType: null == workoutType ? _self.workoutType : workoutType // ignore: cast_nullable_to_non_nullable
as String,exercise: null == exercise ? _self.exercise : exercise // ignore: cast_nullable_to_non_nullable
as String,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,caloriesBurned: freezed == caloriesBurned ? _self.caloriesBurned : caloriesBurned // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$WorkoutSummary {

 int get count;@JsonKey(name: 'total_calories_burned') double get totalCaloriesBurned;@JsonKey(name: 'total_volume') double get totalVolume;@JsonKey(name: 'by_type') List<ActivityTypeBreakdown> get byType;@JsonKey(name: 'most_trained') String? get mostTrained; List<WorkoutRecent> get recent;
/// Create a copy of WorkoutSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutSummaryCopyWith<WorkoutSummary> get copyWith => _$WorkoutSummaryCopyWithImpl<WorkoutSummary>(this as WorkoutSummary, _$identity);

  /// Serializes this WorkoutSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkoutSummary&&(identical(other.count, count) || other.count == count)&&(identical(other.totalCaloriesBurned, totalCaloriesBurned) || other.totalCaloriesBurned == totalCaloriesBurned)&&(identical(other.totalVolume, totalVolume) || other.totalVolume == totalVolume)&&const DeepCollectionEquality().equals(other.byType, byType)&&(identical(other.mostTrained, mostTrained) || other.mostTrained == mostTrained)&&const DeepCollectionEquality().equals(other.recent, recent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,count,totalCaloriesBurned,totalVolume,const DeepCollectionEquality().hash(byType),mostTrained,const DeepCollectionEquality().hash(recent));

@override
String toString() {
  return 'WorkoutSummary(count: $count, totalCaloriesBurned: $totalCaloriesBurned, totalVolume: $totalVolume, byType: $byType, mostTrained: $mostTrained, recent: $recent)';
}


}

/// @nodoc
abstract mixin class $WorkoutSummaryCopyWith<$Res>  {
  factory $WorkoutSummaryCopyWith(WorkoutSummary value, $Res Function(WorkoutSummary) _then) = _$WorkoutSummaryCopyWithImpl;
@useResult
$Res call({
 int count,@JsonKey(name: 'total_calories_burned') double totalCaloriesBurned,@JsonKey(name: 'total_volume') double totalVolume,@JsonKey(name: 'by_type') List<ActivityTypeBreakdown> byType,@JsonKey(name: 'most_trained') String? mostTrained, List<WorkoutRecent> recent
});




}
/// @nodoc
class _$WorkoutSummaryCopyWithImpl<$Res>
    implements $WorkoutSummaryCopyWith<$Res> {
  _$WorkoutSummaryCopyWithImpl(this._self, this._then);

  final WorkoutSummary _self;
  final $Res Function(WorkoutSummary) _then;

/// Create a copy of WorkoutSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? count = null,Object? totalCaloriesBurned = null,Object? totalVolume = null,Object? byType = null,Object? mostTrained = freezed,Object? recent = null,}) {
  return _then(_self.copyWith(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,totalCaloriesBurned: null == totalCaloriesBurned ? _self.totalCaloriesBurned : totalCaloriesBurned // ignore: cast_nullable_to_non_nullable
as double,totalVolume: null == totalVolume ? _self.totalVolume : totalVolume // ignore: cast_nullable_to_non_nullable
as double,byType: null == byType ? _self.byType : byType // ignore: cast_nullable_to_non_nullable
as List<ActivityTypeBreakdown>,mostTrained: freezed == mostTrained ? _self.mostTrained : mostTrained // ignore: cast_nullable_to_non_nullable
as String?,recent: null == recent ? _self.recent : recent // ignore: cast_nullable_to_non_nullable
as List<WorkoutRecent>,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkoutSummary].
extension WorkoutSummaryPatterns on WorkoutSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkoutSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkoutSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkoutSummary value)  $default,){
final _that = this;
switch (_that) {
case _WorkoutSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkoutSummary value)?  $default,){
final _that = this;
switch (_that) {
case _WorkoutSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int count, @JsonKey(name: 'total_calories_burned')  double totalCaloriesBurned, @JsonKey(name: 'total_volume')  double totalVolume, @JsonKey(name: 'by_type')  List<ActivityTypeBreakdown> byType, @JsonKey(name: 'most_trained')  String? mostTrained,  List<WorkoutRecent> recent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkoutSummary() when $default != null:
return $default(_that.count,_that.totalCaloriesBurned,_that.totalVolume,_that.byType,_that.mostTrained,_that.recent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int count, @JsonKey(name: 'total_calories_burned')  double totalCaloriesBurned, @JsonKey(name: 'total_volume')  double totalVolume, @JsonKey(name: 'by_type')  List<ActivityTypeBreakdown> byType, @JsonKey(name: 'most_trained')  String? mostTrained,  List<WorkoutRecent> recent)  $default,) {final _that = this;
switch (_that) {
case _WorkoutSummary():
return $default(_that.count,_that.totalCaloriesBurned,_that.totalVolume,_that.byType,_that.mostTrained,_that.recent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int count, @JsonKey(name: 'total_calories_burned')  double totalCaloriesBurned, @JsonKey(name: 'total_volume')  double totalVolume, @JsonKey(name: 'by_type')  List<ActivityTypeBreakdown> byType, @JsonKey(name: 'most_trained')  String? mostTrained,  List<WorkoutRecent> recent)?  $default,) {final _that = this;
switch (_that) {
case _WorkoutSummary() when $default != null:
return $default(_that.count,_that.totalCaloriesBurned,_that.totalVolume,_that.byType,_that.mostTrained,_that.recent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkoutSummary implements WorkoutSummary {
  const _WorkoutSummary({this.count = 0, @JsonKey(name: 'total_calories_burned') this.totalCaloriesBurned = 0, @JsonKey(name: 'total_volume') this.totalVolume = 0, @JsonKey(name: 'by_type') final  List<ActivityTypeBreakdown> byType = const <ActivityTypeBreakdown>[], @JsonKey(name: 'most_trained') this.mostTrained, final  List<WorkoutRecent> recent = const <WorkoutRecent>[]}): _byType = byType,_recent = recent;
  factory _WorkoutSummary.fromJson(Map<String, dynamic> json) => _$WorkoutSummaryFromJson(json);

@override@JsonKey() final  int count;
@override@JsonKey(name: 'total_calories_burned') final  double totalCaloriesBurned;
@override@JsonKey(name: 'total_volume') final  double totalVolume;
 final  List<ActivityTypeBreakdown> _byType;
@override@JsonKey(name: 'by_type') List<ActivityTypeBreakdown> get byType {
  if (_byType is EqualUnmodifiableListView) return _byType;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_byType);
}

@override@JsonKey(name: 'most_trained') final  String? mostTrained;
 final  List<WorkoutRecent> _recent;
@override@JsonKey() List<WorkoutRecent> get recent {
  if (_recent is EqualUnmodifiableListView) return _recent;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recent);
}


/// Create a copy of WorkoutSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutSummaryCopyWith<_WorkoutSummary> get copyWith => __$WorkoutSummaryCopyWithImpl<_WorkoutSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkoutSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkoutSummary&&(identical(other.count, count) || other.count == count)&&(identical(other.totalCaloriesBurned, totalCaloriesBurned) || other.totalCaloriesBurned == totalCaloriesBurned)&&(identical(other.totalVolume, totalVolume) || other.totalVolume == totalVolume)&&const DeepCollectionEquality().equals(other._byType, _byType)&&(identical(other.mostTrained, mostTrained) || other.mostTrained == mostTrained)&&const DeepCollectionEquality().equals(other._recent, _recent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,count,totalCaloriesBurned,totalVolume,const DeepCollectionEquality().hash(_byType),mostTrained,const DeepCollectionEquality().hash(_recent));

@override
String toString() {
  return 'WorkoutSummary(count: $count, totalCaloriesBurned: $totalCaloriesBurned, totalVolume: $totalVolume, byType: $byType, mostTrained: $mostTrained, recent: $recent)';
}


}

/// @nodoc
abstract mixin class _$WorkoutSummaryCopyWith<$Res> implements $WorkoutSummaryCopyWith<$Res> {
  factory _$WorkoutSummaryCopyWith(_WorkoutSummary value, $Res Function(_WorkoutSummary) _then) = __$WorkoutSummaryCopyWithImpl;
@override @useResult
$Res call({
 int count,@JsonKey(name: 'total_calories_burned') double totalCaloriesBurned,@JsonKey(name: 'total_volume') double totalVolume,@JsonKey(name: 'by_type') List<ActivityTypeBreakdown> byType,@JsonKey(name: 'most_trained') String? mostTrained, List<WorkoutRecent> recent
});




}
/// @nodoc
class __$WorkoutSummaryCopyWithImpl<$Res>
    implements _$WorkoutSummaryCopyWith<$Res> {
  __$WorkoutSummaryCopyWithImpl(this._self, this._then);

  final _WorkoutSummary _self;
  final $Res Function(_WorkoutSummary) _then;

/// Create a copy of WorkoutSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? count = null,Object? totalCaloriesBurned = null,Object? totalVolume = null,Object? byType = null,Object? mostTrained = freezed,Object? recent = null,}) {
  return _then(_WorkoutSummary(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,totalCaloriesBurned: null == totalCaloriesBurned ? _self.totalCaloriesBurned : totalCaloriesBurned // ignore: cast_nullable_to_non_nullable
as double,totalVolume: null == totalVolume ? _self.totalVolume : totalVolume // ignore: cast_nullable_to_non_nullable
as double,byType: null == byType ? _self._byType : byType // ignore: cast_nullable_to_non_nullable
as List<ActivityTypeBreakdown>,mostTrained: freezed == mostTrained ? _self.mostTrained : mostTrained // ignore: cast_nullable_to_non_nullable
as String?,recent: null == recent ? _self._recent : recent // ignore: cast_nullable_to_non_nullable
as List<WorkoutRecent>,
  ));
}


}


/// @nodoc
mixin _$ActivityRecent {

 String get id;@JsonKey(name: 'activity_type') String get activityType;@JsonKey(name: 'started_at') String? get startedAt;@JsonKey(name: 'duration_seconds') int get durationSeconds;@JsonKey(name: 'distance_meters') double get distanceMeters;@JsonKey(name: 'distance_km') double get distanceKm;@JsonKey(name: 'avg_pace') double? get avgPace;@JsonKey(name: 'calories_burned') double? get caloriesBurned; int get steps; List<dynamic> get route;
/// Create a copy of ActivityRecent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActivityRecentCopyWith<ActivityRecent> get copyWith => _$ActivityRecentCopyWithImpl<ActivityRecent>(this as ActivityRecent, _$identity);

  /// Serializes this ActivityRecent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActivityRecent&&(identical(other.id, id) || other.id == id)&&(identical(other.activityType, activityType) || other.activityType == activityType)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.distanceMeters, distanceMeters) || other.distanceMeters == distanceMeters)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.avgPace, avgPace) || other.avgPace == avgPace)&&(identical(other.caloriesBurned, caloriesBurned) || other.caloriesBurned == caloriesBurned)&&(identical(other.steps, steps) || other.steps == steps)&&const DeepCollectionEquality().equals(other.route, route));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,activityType,startedAt,durationSeconds,distanceMeters,distanceKm,avgPace,caloriesBurned,steps,const DeepCollectionEquality().hash(route));

@override
String toString() {
  return 'ActivityRecent(id: $id, activityType: $activityType, startedAt: $startedAt, durationSeconds: $durationSeconds, distanceMeters: $distanceMeters, distanceKm: $distanceKm, avgPace: $avgPace, caloriesBurned: $caloriesBurned, steps: $steps, route: $route)';
}


}

/// @nodoc
abstract mixin class $ActivityRecentCopyWith<$Res>  {
  factory $ActivityRecentCopyWith(ActivityRecent value, $Res Function(ActivityRecent) _then) = _$ActivityRecentCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'activity_type') String activityType,@JsonKey(name: 'started_at') String? startedAt,@JsonKey(name: 'duration_seconds') int durationSeconds,@JsonKey(name: 'distance_meters') double distanceMeters,@JsonKey(name: 'distance_km') double distanceKm,@JsonKey(name: 'avg_pace') double? avgPace,@JsonKey(name: 'calories_burned') double? caloriesBurned, int steps, List<dynamic> route
});




}
/// @nodoc
class _$ActivityRecentCopyWithImpl<$Res>
    implements $ActivityRecentCopyWith<$Res> {
  _$ActivityRecentCopyWithImpl(this._self, this._then);

  final ActivityRecent _self;
  final $Res Function(ActivityRecent) _then;

/// Create a copy of ActivityRecent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? activityType = null,Object? startedAt = freezed,Object? durationSeconds = null,Object? distanceMeters = null,Object? distanceKm = null,Object? avgPace = freezed,Object? caloriesBurned = freezed,Object? steps = null,Object? route = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,activityType: null == activityType ? _self.activityType : activityType // ignore: cast_nullable_to_non_nullable
as String,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as String?,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,distanceMeters: null == distanceMeters ? _self.distanceMeters : distanceMeters // ignore: cast_nullable_to_non_nullable
as double,distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,avgPace: freezed == avgPace ? _self.avgPace : avgPace // ignore: cast_nullable_to_non_nullable
as double?,caloriesBurned: freezed == caloriesBurned ? _self.caloriesBurned : caloriesBurned // ignore: cast_nullable_to_non_nullable
as double?,steps: null == steps ? _self.steps : steps // ignore: cast_nullable_to_non_nullable
as int,route: null == route ? _self.route : route // ignore: cast_nullable_to_non_nullable
as List<dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [ActivityRecent].
extension ActivityRecentPatterns on ActivityRecent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActivityRecent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActivityRecent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActivityRecent value)  $default,){
final _that = this;
switch (_that) {
case _ActivityRecent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActivityRecent value)?  $default,){
final _that = this;
switch (_that) {
case _ActivityRecent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'activity_type')  String activityType, @JsonKey(name: 'started_at')  String? startedAt, @JsonKey(name: 'duration_seconds')  int durationSeconds, @JsonKey(name: 'distance_meters')  double distanceMeters, @JsonKey(name: 'distance_km')  double distanceKm, @JsonKey(name: 'avg_pace')  double? avgPace, @JsonKey(name: 'calories_burned')  double? caloriesBurned,  int steps,  List<dynamic> route)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActivityRecent() when $default != null:
return $default(_that.id,_that.activityType,_that.startedAt,_that.durationSeconds,_that.distanceMeters,_that.distanceKm,_that.avgPace,_that.caloriesBurned,_that.steps,_that.route);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'activity_type')  String activityType, @JsonKey(name: 'started_at')  String? startedAt, @JsonKey(name: 'duration_seconds')  int durationSeconds, @JsonKey(name: 'distance_meters')  double distanceMeters, @JsonKey(name: 'distance_km')  double distanceKm, @JsonKey(name: 'avg_pace')  double? avgPace, @JsonKey(name: 'calories_burned')  double? caloriesBurned,  int steps,  List<dynamic> route)  $default,) {final _that = this;
switch (_that) {
case _ActivityRecent():
return $default(_that.id,_that.activityType,_that.startedAt,_that.durationSeconds,_that.distanceMeters,_that.distanceKm,_that.avgPace,_that.caloriesBurned,_that.steps,_that.route);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'activity_type')  String activityType, @JsonKey(name: 'started_at')  String? startedAt, @JsonKey(name: 'duration_seconds')  int durationSeconds, @JsonKey(name: 'distance_meters')  double distanceMeters, @JsonKey(name: 'distance_km')  double distanceKm, @JsonKey(name: 'avg_pace')  double? avgPace, @JsonKey(name: 'calories_burned')  double? caloriesBurned,  int steps,  List<dynamic> route)?  $default,) {final _that = this;
switch (_that) {
case _ActivityRecent() when $default != null:
return $default(_that.id,_that.activityType,_that.startedAt,_that.durationSeconds,_that.distanceMeters,_that.distanceKm,_that.avgPace,_that.caloriesBurned,_that.steps,_that.route);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ActivityRecent implements ActivityRecent {
  const _ActivityRecent({this.id = '', @JsonKey(name: 'activity_type') this.activityType = '', @JsonKey(name: 'started_at') this.startedAt, @JsonKey(name: 'duration_seconds') this.durationSeconds = 0, @JsonKey(name: 'distance_meters') this.distanceMeters = 0, @JsonKey(name: 'distance_km') this.distanceKm = 0, @JsonKey(name: 'avg_pace') this.avgPace, @JsonKey(name: 'calories_burned') this.caloriesBurned, this.steps = 0, final  List<dynamic> route = const <dynamic>[]}): _route = route;
  factory _ActivityRecent.fromJson(Map<String, dynamic> json) => _$ActivityRecentFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey(name: 'activity_type') final  String activityType;
@override@JsonKey(name: 'started_at') final  String? startedAt;
@override@JsonKey(name: 'duration_seconds') final  int durationSeconds;
@override@JsonKey(name: 'distance_meters') final  double distanceMeters;
@override@JsonKey(name: 'distance_km') final  double distanceKm;
@override@JsonKey(name: 'avg_pace') final  double? avgPace;
@override@JsonKey(name: 'calories_burned') final  double? caloriesBurned;
@override@JsonKey() final  int steps;
 final  List<dynamic> _route;
@override@JsonKey() List<dynamic> get route {
  if (_route is EqualUnmodifiableListView) return _route;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_route);
}


/// Create a copy of ActivityRecent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActivityRecentCopyWith<_ActivityRecent> get copyWith => __$ActivityRecentCopyWithImpl<_ActivityRecent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ActivityRecentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivityRecent&&(identical(other.id, id) || other.id == id)&&(identical(other.activityType, activityType) || other.activityType == activityType)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.distanceMeters, distanceMeters) || other.distanceMeters == distanceMeters)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.avgPace, avgPace) || other.avgPace == avgPace)&&(identical(other.caloriesBurned, caloriesBurned) || other.caloriesBurned == caloriesBurned)&&(identical(other.steps, steps) || other.steps == steps)&&const DeepCollectionEquality().equals(other._route, _route));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,activityType,startedAt,durationSeconds,distanceMeters,distanceKm,avgPace,caloriesBurned,steps,const DeepCollectionEquality().hash(_route));

@override
String toString() {
  return 'ActivityRecent(id: $id, activityType: $activityType, startedAt: $startedAt, durationSeconds: $durationSeconds, distanceMeters: $distanceMeters, distanceKm: $distanceKm, avgPace: $avgPace, caloriesBurned: $caloriesBurned, steps: $steps, route: $route)';
}


}

/// @nodoc
abstract mixin class _$ActivityRecentCopyWith<$Res> implements $ActivityRecentCopyWith<$Res> {
  factory _$ActivityRecentCopyWith(_ActivityRecent value, $Res Function(_ActivityRecent) _then) = __$ActivityRecentCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'activity_type') String activityType,@JsonKey(name: 'started_at') String? startedAt,@JsonKey(name: 'duration_seconds') int durationSeconds,@JsonKey(name: 'distance_meters') double distanceMeters,@JsonKey(name: 'distance_km') double distanceKm,@JsonKey(name: 'avg_pace') double? avgPace,@JsonKey(name: 'calories_burned') double? caloriesBurned, int steps, List<dynamic> route
});




}
/// @nodoc
class __$ActivityRecentCopyWithImpl<$Res>
    implements _$ActivityRecentCopyWith<$Res> {
  __$ActivityRecentCopyWithImpl(this._self, this._then);

  final _ActivityRecent _self;
  final $Res Function(_ActivityRecent) _then;

/// Create a copy of ActivityRecent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? activityType = null,Object? startedAt = freezed,Object? durationSeconds = null,Object? distanceMeters = null,Object? distanceKm = null,Object? avgPace = freezed,Object? caloriesBurned = freezed,Object? steps = null,Object? route = null,}) {
  return _then(_ActivityRecent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,activityType: null == activityType ? _self.activityType : activityType // ignore: cast_nullable_to_non_nullable
as String,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as String?,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,distanceMeters: null == distanceMeters ? _self.distanceMeters : distanceMeters // ignore: cast_nullable_to_non_nullable
as double,distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,avgPace: freezed == avgPace ? _self.avgPace : avgPace // ignore: cast_nullable_to_non_nullable
as double?,caloriesBurned: freezed == caloriesBurned ? _self.caloriesBurned : caloriesBurned // ignore: cast_nullable_to_non_nullable
as double?,steps: null == steps ? _self.steps : steps // ignore: cast_nullable_to_non_nullable
as int,route: null == route ? _self._route : route // ignore: cast_nullable_to_non_nullable
as List<dynamic>,
  ));
}


}


/// @nodoc
mixin _$ActivitySummary {

 int get count;@JsonKey(name: 'total_distance_km') double get totalDistanceKm;@JsonKey(name: 'total_duration_seconds') int get totalDurationSeconds;@JsonKey(name: 'total_calories_burned') double get totalCaloriesBurned;@JsonKey(name: 'total_steps') int get totalSteps;@JsonKey(name: 'avg_pace') double? get avgPace;@JsonKey(name: 'by_type') List<ActivityTypeBreakdown> get byType; List<ActivityRecent> get recent;
/// Create a copy of ActivitySummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActivitySummaryCopyWith<ActivitySummary> get copyWith => _$ActivitySummaryCopyWithImpl<ActivitySummary>(this as ActivitySummary, _$identity);

  /// Serializes this ActivitySummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActivitySummary&&(identical(other.count, count) || other.count == count)&&(identical(other.totalDistanceKm, totalDistanceKm) || other.totalDistanceKm == totalDistanceKm)&&(identical(other.totalDurationSeconds, totalDurationSeconds) || other.totalDurationSeconds == totalDurationSeconds)&&(identical(other.totalCaloriesBurned, totalCaloriesBurned) || other.totalCaloriesBurned == totalCaloriesBurned)&&(identical(other.totalSteps, totalSteps) || other.totalSteps == totalSteps)&&(identical(other.avgPace, avgPace) || other.avgPace == avgPace)&&const DeepCollectionEquality().equals(other.byType, byType)&&const DeepCollectionEquality().equals(other.recent, recent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,count,totalDistanceKm,totalDurationSeconds,totalCaloriesBurned,totalSteps,avgPace,const DeepCollectionEquality().hash(byType),const DeepCollectionEquality().hash(recent));

@override
String toString() {
  return 'ActivitySummary(count: $count, totalDistanceKm: $totalDistanceKm, totalDurationSeconds: $totalDurationSeconds, totalCaloriesBurned: $totalCaloriesBurned, totalSteps: $totalSteps, avgPace: $avgPace, byType: $byType, recent: $recent)';
}


}

/// @nodoc
abstract mixin class $ActivitySummaryCopyWith<$Res>  {
  factory $ActivitySummaryCopyWith(ActivitySummary value, $Res Function(ActivitySummary) _then) = _$ActivitySummaryCopyWithImpl;
@useResult
$Res call({
 int count,@JsonKey(name: 'total_distance_km') double totalDistanceKm,@JsonKey(name: 'total_duration_seconds') int totalDurationSeconds,@JsonKey(name: 'total_calories_burned') double totalCaloriesBurned,@JsonKey(name: 'total_steps') int totalSteps,@JsonKey(name: 'avg_pace') double? avgPace,@JsonKey(name: 'by_type') List<ActivityTypeBreakdown> byType, List<ActivityRecent> recent
});




}
/// @nodoc
class _$ActivitySummaryCopyWithImpl<$Res>
    implements $ActivitySummaryCopyWith<$Res> {
  _$ActivitySummaryCopyWithImpl(this._self, this._then);

  final ActivitySummary _self;
  final $Res Function(ActivitySummary) _then;

/// Create a copy of ActivitySummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? count = null,Object? totalDistanceKm = null,Object? totalDurationSeconds = null,Object? totalCaloriesBurned = null,Object? totalSteps = null,Object? avgPace = freezed,Object? byType = null,Object? recent = null,}) {
  return _then(_self.copyWith(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,totalDistanceKm: null == totalDistanceKm ? _self.totalDistanceKm : totalDistanceKm // ignore: cast_nullable_to_non_nullable
as double,totalDurationSeconds: null == totalDurationSeconds ? _self.totalDurationSeconds : totalDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,totalCaloriesBurned: null == totalCaloriesBurned ? _self.totalCaloriesBurned : totalCaloriesBurned // ignore: cast_nullable_to_non_nullable
as double,totalSteps: null == totalSteps ? _self.totalSteps : totalSteps // ignore: cast_nullable_to_non_nullable
as int,avgPace: freezed == avgPace ? _self.avgPace : avgPace // ignore: cast_nullable_to_non_nullable
as double?,byType: null == byType ? _self.byType : byType // ignore: cast_nullable_to_non_nullable
as List<ActivityTypeBreakdown>,recent: null == recent ? _self.recent : recent // ignore: cast_nullable_to_non_nullable
as List<ActivityRecent>,
  ));
}

}


/// Adds pattern-matching-related methods to [ActivitySummary].
extension ActivitySummaryPatterns on ActivitySummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActivitySummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActivitySummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActivitySummary value)  $default,){
final _that = this;
switch (_that) {
case _ActivitySummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActivitySummary value)?  $default,){
final _that = this;
switch (_that) {
case _ActivitySummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int count, @JsonKey(name: 'total_distance_km')  double totalDistanceKm, @JsonKey(name: 'total_duration_seconds')  int totalDurationSeconds, @JsonKey(name: 'total_calories_burned')  double totalCaloriesBurned, @JsonKey(name: 'total_steps')  int totalSteps, @JsonKey(name: 'avg_pace')  double? avgPace, @JsonKey(name: 'by_type')  List<ActivityTypeBreakdown> byType,  List<ActivityRecent> recent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActivitySummary() when $default != null:
return $default(_that.count,_that.totalDistanceKm,_that.totalDurationSeconds,_that.totalCaloriesBurned,_that.totalSteps,_that.avgPace,_that.byType,_that.recent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int count, @JsonKey(name: 'total_distance_km')  double totalDistanceKm, @JsonKey(name: 'total_duration_seconds')  int totalDurationSeconds, @JsonKey(name: 'total_calories_burned')  double totalCaloriesBurned, @JsonKey(name: 'total_steps')  int totalSteps, @JsonKey(name: 'avg_pace')  double? avgPace, @JsonKey(name: 'by_type')  List<ActivityTypeBreakdown> byType,  List<ActivityRecent> recent)  $default,) {final _that = this;
switch (_that) {
case _ActivitySummary():
return $default(_that.count,_that.totalDistanceKm,_that.totalDurationSeconds,_that.totalCaloriesBurned,_that.totalSteps,_that.avgPace,_that.byType,_that.recent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int count, @JsonKey(name: 'total_distance_km')  double totalDistanceKm, @JsonKey(name: 'total_duration_seconds')  int totalDurationSeconds, @JsonKey(name: 'total_calories_burned')  double totalCaloriesBurned, @JsonKey(name: 'total_steps')  int totalSteps, @JsonKey(name: 'avg_pace')  double? avgPace, @JsonKey(name: 'by_type')  List<ActivityTypeBreakdown> byType,  List<ActivityRecent> recent)?  $default,) {final _that = this;
switch (_that) {
case _ActivitySummary() when $default != null:
return $default(_that.count,_that.totalDistanceKm,_that.totalDurationSeconds,_that.totalCaloriesBurned,_that.totalSteps,_that.avgPace,_that.byType,_that.recent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ActivitySummary implements ActivitySummary {
  const _ActivitySummary({this.count = 0, @JsonKey(name: 'total_distance_km') this.totalDistanceKm = 0, @JsonKey(name: 'total_duration_seconds') this.totalDurationSeconds = 0, @JsonKey(name: 'total_calories_burned') this.totalCaloriesBurned = 0, @JsonKey(name: 'total_steps') this.totalSteps = 0, @JsonKey(name: 'avg_pace') this.avgPace, @JsonKey(name: 'by_type') final  List<ActivityTypeBreakdown> byType = const <ActivityTypeBreakdown>[], final  List<ActivityRecent> recent = const <ActivityRecent>[]}): _byType = byType,_recent = recent;
  factory _ActivitySummary.fromJson(Map<String, dynamic> json) => _$ActivitySummaryFromJson(json);

@override@JsonKey() final  int count;
@override@JsonKey(name: 'total_distance_km') final  double totalDistanceKm;
@override@JsonKey(name: 'total_duration_seconds') final  int totalDurationSeconds;
@override@JsonKey(name: 'total_calories_burned') final  double totalCaloriesBurned;
@override@JsonKey(name: 'total_steps') final  int totalSteps;
@override@JsonKey(name: 'avg_pace') final  double? avgPace;
 final  List<ActivityTypeBreakdown> _byType;
@override@JsonKey(name: 'by_type') List<ActivityTypeBreakdown> get byType {
  if (_byType is EqualUnmodifiableListView) return _byType;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_byType);
}

 final  List<ActivityRecent> _recent;
@override@JsonKey() List<ActivityRecent> get recent {
  if (_recent is EqualUnmodifiableListView) return _recent;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recent);
}


/// Create a copy of ActivitySummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActivitySummaryCopyWith<_ActivitySummary> get copyWith => __$ActivitySummaryCopyWithImpl<_ActivitySummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ActivitySummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivitySummary&&(identical(other.count, count) || other.count == count)&&(identical(other.totalDistanceKm, totalDistanceKm) || other.totalDistanceKm == totalDistanceKm)&&(identical(other.totalDurationSeconds, totalDurationSeconds) || other.totalDurationSeconds == totalDurationSeconds)&&(identical(other.totalCaloriesBurned, totalCaloriesBurned) || other.totalCaloriesBurned == totalCaloriesBurned)&&(identical(other.totalSteps, totalSteps) || other.totalSteps == totalSteps)&&(identical(other.avgPace, avgPace) || other.avgPace == avgPace)&&const DeepCollectionEquality().equals(other._byType, _byType)&&const DeepCollectionEquality().equals(other._recent, _recent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,count,totalDistanceKm,totalDurationSeconds,totalCaloriesBurned,totalSteps,avgPace,const DeepCollectionEquality().hash(_byType),const DeepCollectionEquality().hash(_recent));

@override
String toString() {
  return 'ActivitySummary(count: $count, totalDistanceKm: $totalDistanceKm, totalDurationSeconds: $totalDurationSeconds, totalCaloriesBurned: $totalCaloriesBurned, totalSteps: $totalSteps, avgPace: $avgPace, byType: $byType, recent: $recent)';
}


}

/// @nodoc
abstract mixin class _$ActivitySummaryCopyWith<$Res> implements $ActivitySummaryCopyWith<$Res> {
  factory _$ActivitySummaryCopyWith(_ActivitySummary value, $Res Function(_ActivitySummary) _then) = __$ActivitySummaryCopyWithImpl;
@override @useResult
$Res call({
 int count,@JsonKey(name: 'total_distance_km') double totalDistanceKm,@JsonKey(name: 'total_duration_seconds') int totalDurationSeconds,@JsonKey(name: 'total_calories_burned') double totalCaloriesBurned,@JsonKey(name: 'total_steps') int totalSteps,@JsonKey(name: 'avg_pace') double? avgPace,@JsonKey(name: 'by_type') List<ActivityTypeBreakdown> byType, List<ActivityRecent> recent
});




}
/// @nodoc
class __$ActivitySummaryCopyWithImpl<$Res>
    implements _$ActivitySummaryCopyWith<$Res> {
  __$ActivitySummaryCopyWithImpl(this._self, this._then);

  final _ActivitySummary _self;
  final $Res Function(_ActivitySummary) _then;

/// Create a copy of ActivitySummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? count = null,Object? totalDistanceKm = null,Object? totalDurationSeconds = null,Object? totalCaloriesBurned = null,Object? totalSteps = null,Object? avgPace = freezed,Object? byType = null,Object? recent = null,}) {
  return _then(_ActivitySummary(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,totalDistanceKm: null == totalDistanceKm ? _self.totalDistanceKm : totalDistanceKm // ignore: cast_nullable_to_non_nullable
as double,totalDurationSeconds: null == totalDurationSeconds ? _self.totalDurationSeconds : totalDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,totalCaloriesBurned: null == totalCaloriesBurned ? _self.totalCaloriesBurned : totalCaloriesBurned // ignore: cast_nullable_to_non_nullable
as double,totalSteps: null == totalSteps ? _self.totalSteps : totalSteps // ignore: cast_nullable_to_non_nullable
as int,avgPace: freezed == avgPace ? _self.avgPace : avgPace // ignore: cast_nullable_to_non_nullable
as double?,byType: null == byType ? _self._byType : byType // ignore: cast_nullable_to_non_nullable
as List<ActivityTypeBreakdown>,recent: null == recent ? _self._recent : recent // ignore: cast_nullable_to_non_nullable
as List<ActivityRecent>,
  ));
}


}


/// @nodoc
mixin _$BodySeriesPoint {

 String get id;@JsonKey(name: 'weight_kg') double get weightKg;@JsonKey(name: 'body_fat_pct') double? get bodyFatPct;@JsonKey(name: 'measured_at') String? get measuredAt;@JsonKey(name: 'photo_url') String get photoUrl;@JsonKey(name: 'scale_photo_url') String get scalePhotoUrl;
/// Create a copy of BodySeriesPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BodySeriesPointCopyWith<BodySeriesPoint> get copyWith => _$BodySeriesPointCopyWithImpl<BodySeriesPoint>(this as BodySeriesPoint, _$identity);

  /// Serializes this BodySeriesPoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BodySeriesPoint&&(identical(other.id, id) || other.id == id)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.bodyFatPct, bodyFatPct) || other.bodyFatPct == bodyFatPct)&&(identical(other.measuredAt, measuredAt) || other.measuredAt == measuredAt)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.scalePhotoUrl, scalePhotoUrl) || other.scalePhotoUrl == scalePhotoUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,weightKg,bodyFatPct,measuredAt,photoUrl,scalePhotoUrl);

@override
String toString() {
  return 'BodySeriesPoint(id: $id, weightKg: $weightKg, bodyFatPct: $bodyFatPct, measuredAt: $measuredAt, photoUrl: $photoUrl, scalePhotoUrl: $scalePhotoUrl)';
}


}

/// @nodoc
abstract mixin class $BodySeriesPointCopyWith<$Res>  {
  factory $BodySeriesPointCopyWith(BodySeriesPoint value, $Res Function(BodySeriesPoint) _then) = _$BodySeriesPointCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'weight_kg') double weightKg,@JsonKey(name: 'body_fat_pct') double? bodyFatPct,@JsonKey(name: 'measured_at') String? measuredAt,@JsonKey(name: 'photo_url') String photoUrl,@JsonKey(name: 'scale_photo_url') String scalePhotoUrl
});




}
/// @nodoc
class _$BodySeriesPointCopyWithImpl<$Res>
    implements $BodySeriesPointCopyWith<$Res> {
  _$BodySeriesPointCopyWithImpl(this._self, this._then);

  final BodySeriesPoint _self;
  final $Res Function(BodySeriesPoint) _then;

/// Create a copy of BodySeriesPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? weightKg = null,Object? bodyFatPct = freezed,Object? measuredAt = freezed,Object? photoUrl = null,Object? scalePhotoUrl = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,bodyFatPct: freezed == bodyFatPct ? _self.bodyFatPct : bodyFatPct // ignore: cast_nullable_to_non_nullable
as double?,measuredAt: freezed == measuredAt ? _self.measuredAt : measuredAt // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: null == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String,scalePhotoUrl: null == scalePhotoUrl ? _self.scalePhotoUrl : scalePhotoUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BodySeriesPoint].
extension BodySeriesPointPatterns on BodySeriesPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BodySeriesPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BodySeriesPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BodySeriesPoint value)  $default,){
final _that = this;
switch (_that) {
case _BodySeriesPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BodySeriesPoint value)?  $default,){
final _that = this;
switch (_that) {
case _BodySeriesPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'weight_kg')  double weightKg, @JsonKey(name: 'body_fat_pct')  double? bodyFatPct, @JsonKey(name: 'measured_at')  String? measuredAt, @JsonKey(name: 'photo_url')  String photoUrl, @JsonKey(name: 'scale_photo_url')  String scalePhotoUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BodySeriesPoint() when $default != null:
return $default(_that.id,_that.weightKg,_that.bodyFatPct,_that.measuredAt,_that.photoUrl,_that.scalePhotoUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'weight_kg')  double weightKg, @JsonKey(name: 'body_fat_pct')  double? bodyFatPct, @JsonKey(name: 'measured_at')  String? measuredAt, @JsonKey(name: 'photo_url')  String photoUrl, @JsonKey(name: 'scale_photo_url')  String scalePhotoUrl)  $default,) {final _that = this;
switch (_that) {
case _BodySeriesPoint():
return $default(_that.id,_that.weightKg,_that.bodyFatPct,_that.measuredAt,_that.photoUrl,_that.scalePhotoUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'weight_kg')  double weightKg, @JsonKey(name: 'body_fat_pct')  double? bodyFatPct, @JsonKey(name: 'measured_at')  String? measuredAt, @JsonKey(name: 'photo_url')  String photoUrl, @JsonKey(name: 'scale_photo_url')  String scalePhotoUrl)?  $default,) {final _that = this;
switch (_that) {
case _BodySeriesPoint() when $default != null:
return $default(_that.id,_that.weightKg,_that.bodyFatPct,_that.measuredAt,_that.photoUrl,_that.scalePhotoUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BodySeriesPoint implements BodySeriesPoint {
  const _BodySeriesPoint({this.id = '', @JsonKey(name: 'weight_kg') this.weightKg = 0, @JsonKey(name: 'body_fat_pct') this.bodyFatPct, @JsonKey(name: 'measured_at') this.measuredAt, @JsonKey(name: 'photo_url') this.photoUrl = '', @JsonKey(name: 'scale_photo_url') this.scalePhotoUrl = ''});
  factory _BodySeriesPoint.fromJson(Map<String, dynamic> json) => _$BodySeriesPointFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey(name: 'weight_kg') final  double weightKg;
@override@JsonKey(name: 'body_fat_pct') final  double? bodyFatPct;
@override@JsonKey(name: 'measured_at') final  String? measuredAt;
@override@JsonKey(name: 'photo_url') final  String photoUrl;
@override@JsonKey(name: 'scale_photo_url') final  String scalePhotoUrl;

/// Create a copy of BodySeriesPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BodySeriesPointCopyWith<_BodySeriesPoint> get copyWith => __$BodySeriesPointCopyWithImpl<_BodySeriesPoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BodySeriesPointToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BodySeriesPoint&&(identical(other.id, id) || other.id == id)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.bodyFatPct, bodyFatPct) || other.bodyFatPct == bodyFatPct)&&(identical(other.measuredAt, measuredAt) || other.measuredAt == measuredAt)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.scalePhotoUrl, scalePhotoUrl) || other.scalePhotoUrl == scalePhotoUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,weightKg,bodyFatPct,measuredAt,photoUrl,scalePhotoUrl);

@override
String toString() {
  return 'BodySeriesPoint(id: $id, weightKg: $weightKg, bodyFatPct: $bodyFatPct, measuredAt: $measuredAt, photoUrl: $photoUrl, scalePhotoUrl: $scalePhotoUrl)';
}


}

/// @nodoc
abstract mixin class _$BodySeriesPointCopyWith<$Res> implements $BodySeriesPointCopyWith<$Res> {
  factory _$BodySeriesPointCopyWith(_BodySeriesPoint value, $Res Function(_BodySeriesPoint) _then) = __$BodySeriesPointCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'weight_kg') double weightKg,@JsonKey(name: 'body_fat_pct') double? bodyFatPct,@JsonKey(name: 'measured_at') String? measuredAt,@JsonKey(name: 'photo_url') String photoUrl,@JsonKey(name: 'scale_photo_url') String scalePhotoUrl
});




}
/// @nodoc
class __$BodySeriesPointCopyWithImpl<$Res>
    implements _$BodySeriesPointCopyWith<$Res> {
  __$BodySeriesPointCopyWithImpl(this._self, this._then);

  final _BodySeriesPoint _self;
  final $Res Function(_BodySeriesPoint) _then;

/// Create a copy of BodySeriesPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? weightKg = null,Object? bodyFatPct = freezed,Object? measuredAt = freezed,Object? photoUrl = null,Object? scalePhotoUrl = null,}) {
  return _then(_BodySeriesPoint(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,bodyFatPct: freezed == bodyFatPct ? _self.bodyFatPct : bodyFatPct // ignore: cast_nullable_to_non_nullable
as double?,measuredAt: freezed == measuredAt ? _self.measuredAt : measuredAt // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: null == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String,scalePhotoUrl: null == scalePhotoUrl ? _self.scalePhotoUrl : scalePhotoUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$BodySummary {

 int get count;@JsonKey(name: 'start_weight_kg') double? get startWeightKg;@JsonKey(name: 'latest_weight_kg') double? get latestWeightKg;@JsonKey(name: 'weight_change_kg') double? get weightChangeKg;@JsonKey(name: 'latest_body_fat_pct') double? get latestBodyFatPct; List<BodySeriesPoint> get series;
/// Create a copy of BodySummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BodySummaryCopyWith<BodySummary> get copyWith => _$BodySummaryCopyWithImpl<BodySummary>(this as BodySummary, _$identity);

  /// Serializes this BodySummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BodySummary&&(identical(other.count, count) || other.count == count)&&(identical(other.startWeightKg, startWeightKg) || other.startWeightKg == startWeightKg)&&(identical(other.latestWeightKg, latestWeightKg) || other.latestWeightKg == latestWeightKg)&&(identical(other.weightChangeKg, weightChangeKg) || other.weightChangeKg == weightChangeKg)&&(identical(other.latestBodyFatPct, latestBodyFatPct) || other.latestBodyFatPct == latestBodyFatPct)&&const DeepCollectionEquality().equals(other.series, series));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,count,startWeightKg,latestWeightKg,weightChangeKg,latestBodyFatPct,const DeepCollectionEquality().hash(series));

@override
String toString() {
  return 'BodySummary(count: $count, startWeightKg: $startWeightKg, latestWeightKg: $latestWeightKg, weightChangeKg: $weightChangeKg, latestBodyFatPct: $latestBodyFatPct, series: $series)';
}


}

/// @nodoc
abstract mixin class $BodySummaryCopyWith<$Res>  {
  factory $BodySummaryCopyWith(BodySummary value, $Res Function(BodySummary) _then) = _$BodySummaryCopyWithImpl;
@useResult
$Res call({
 int count,@JsonKey(name: 'start_weight_kg') double? startWeightKg,@JsonKey(name: 'latest_weight_kg') double? latestWeightKg,@JsonKey(name: 'weight_change_kg') double? weightChangeKg,@JsonKey(name: 'latest_body_fat_pct') double? latestBodyFatPct, List<BodySeriesPoint> series
});




}
/// @nodoc
class _$BodySummaryCopyWithImpl<$Res>
    implements $BodySummaryCopyWith<$Res> {
  _$BodySummaryCopyWithImpl(this._self, this._then);

  final BodySummary _self;
  final $Res Function(BodySummary) _then;

/// Create a copy of BodySummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? count = null,Object? startWeightKg = freezed,Object? latestWeightKg = freezed,Object? weightChangeKg = freezed,Object? latestBodyFatPct = freezed,Object? series = null,}) {
  return _then(_self.copyWith(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,startWeightKg: freezed == startWeightKg ? _self.startWeightKg : startWeightKg // ignore: cast_nullable_to_non_nullable
as double?,latestWeightKg: freezed == latestWeightKg ? _self.latestWeightKg : latestWeightKg // ignore: cast_nullable_to_non_nullable
as double?,weightChangeKg: freezed == weightChangeKg ? _self.weightChangeKg : weightChangeKg // ignore: cast_nullable_to_non_nullable
as double?,latestBodyFatPct: freezed == latestBodyFatPct ? _self.latestBodyFatPct : latestBodyFatPct // ignore: cast_nullable_to_non_nullable
as double?,series: null == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as List<BodySeriesPoint>,
  ));
}

}


/// Adds pattern-matching-related methods to [BodySummary].
extension BodySummaryPatterns on BodySummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BodySummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BodySummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BodySummary value)  $default,){
final _that = this;
switch (_that) {
case _BodySummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BodySummary value)?  $default,){
final _that = this;
switch (_that) {
case _BodySummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int count, @JsonKey(name: 'start_weight_kg')  double? startWeightKg, @JsonKey(name: 'latest_weight_kg')  double? latestWeightKg, @JsonKey(name: 'weight_change_kg')  double? weightChangeKg, @JsonKey(name: 'latest_body_fat_pct')  double? latestBodyFatPct,  List<BodySeriesPoint> series)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BodySummary() when $default != null:
return $default(_that.count,_that.startWeightKg,_that.latestWeightKg,_that.weightChangeKg,_that.latestBodyFatPct,_that.series);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int count, @JsonKey(name: 'start_weight_kg')  double? startWeightKg, @JsonKey(name: 'latest_weight_kg')  double? latestWeightKg, @JsonKey(name: 'weight_change_kg')  double? weightChangeKg, @JsonKey(name: 'latest_body_fat_pct')  double? latestBodyFatPct,  List<BodySeriesPoint> series)  $default,) {final _that = this;
switch (_that) {
case _BodySummary():
return $default(_that.count,_that.startWeightKg,_that.latestWeightKg,_that.weightChangeKg,_that.latestBodyFatPct,_that.series);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int count, @JsonKey(name: 'start_weight_kg')  double? startWeightKg, @JsonKey(name: 'latest_weight_kg')  double? latestWeightKg, @JsonKey(name: 'weight_change_kg')  double? weightChangeKg, @JsonKey(name: 'latest_body_fat_pct')  double? latestBodyFatPct,  List<BodySeriesPoint> series)?  $default,) {final _that = this;
switch (_that) {
case _BodySummary() when $default != null:
return $default(_that.count,_that.startWeightKg,_that.latestWeightKg,_that.weightChangeKg,_that.latestBodyFatPct,_that.series);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BodySummary implements BodySummary {
  const _BodySummary({this.count = 0, @JsonKey(name: 'start_weight_kg') this.startWeightKg, @JsonKey(name: 'latest_weight_kg') this.latestWeightKg, @JsonKey(name: 'weight_change_kg') this.weightChangeKg, @JsonKey(name: 'latest_body_fat_pct') this.latestBodyFatPct, final  List<BodySeriesPoint> series = const <BodySeriesPoint>[]}): _series = series;
  factory _BodySummary.fromJson(Map<String, dynamic> json) => _$BodySummaryFromJson(json);

@override@JsonKey() final  int count;
@override@JsonKey(name: 'start_weight_kg') final  double? startWeightKg;
@override@JsonKey(name: 'latest_weight_kg') final  double? latestWeightKg;
@override@JsonKey(name: 'weight_change_kg') final  double? weightChangeKg;
@override@JsonKey(name: 'latest_body_fat_pct') final  double? latestBodyFatPct;
 final  List<BodySeriesPoint> _series;
@override@JsonKey() List<BodySeriesPoint> get series {
  if (_series is EqualUnmodifiableListView) return _series;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_series);
}


/// Create a copy of BodySummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BodySummaryCopyWith<_BodySummary> get copyWith => __$BodySummaryCopyWithImpl<_BodySummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BodySummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BodySummary&&(identical(other.count, count) || other.count == count)&&(identical(other.startWeightKg, startWeightKg) || other.startWeightKg == startWeightKg)&&(identical(other.latestWeightKg, latestWeightKg) || other.latestWeightKg == latestWeightKg)&&(identical(other.weightChangeKg, weightChangeKg) || other.weightChangeKg == weightChangeKg)&&(identical(other.latestBodyFatPct, latestBodyFatPct) || other.latestBodyFatPct == latestBodyFatPct)&&const DeepCollectionEquality().equals(other._series, _series));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,count,startWeightKg,latestWeightKg,weightChangeKg,latestBodyFatPct,const DeepCollectionEquality().hash(_series));

@override
String toString() {
  return 'BodySummary(count: $count, startWeightKg: $startWeightKg, latestWeightKg: $latestWeightKg, weightChangeKg: $weightChangeKg, latestBodyFatPct: $latestBodyFatPct, series: $series)';
}


}

/// @nodoc
abstract mixin class _$BodySummaryCopyWith<$Res> implements $BodySummaryCopyWith<$Res> {
  factory _$BodySummaryCopyWith(_BodySummary value, $Res Function(_BodySummary) _then) = __$BodySummaryCopyWithImpl;
@override @useResult
$Res call({
 int count,@JsonKey(name: 'start_weight_kg') double? startWeightKg,@JsonKey(name: 'latest_weight_kg') double? latestWeightKg,@JsonKey(name: 'weight_change_kg') double? weightChangeKg,@JsonKey(name: 'latest_body_fat_pct') double? latestBodyFatPct, List<BodySeriesPoint> series
});




}
/// @nodoc
class __$BodySummaryCopyWithImpl<$Res>
    implements _$BodySummaryCopyWith<$Res> {
  __$BodySummaryCopyWithImpl(this._self, this._then);

  final _BodySummary _self;
  final $Res Function(_BodySummary) _then;

/// Create a copy of BodySummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? count = null,Object? startWeightKg = freezed,Object? latestWeightKg = freezed,Object? weightChangeKg = freezed,Object? latestBodyFatPct = freezed,Object? series = null,}) {
  return _then(_BodySummary(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,startWeightKg: freezed == startWeightKg ? _self.startWeightKg : startWeightKg // ignore: cast_nullable_to_non_nullable
as double?,latestWeightKg: freezed == latestWeightKg ? _self.latestWeightKg : latestWeightKg // ignore: cast_nullable_to_non_nullable
as double?,weightChangeKg: freezed == weightChangeKg ? _self.weightChangeKg : weightChangeKg // ignore: cast_nullable_to_non_nullable
as double?,latestBodyFatPct: freezed == latestBodyFatPct ? _self.latestBodyFatPct : latestBodyFatPct // ignore: cast_nullable_to_non_nullable
as double?,series: null == series ? _self._series : series // ignore: cast_nullable_to_non_nullable
as List<BodySeriesPoint>,
  ));
}


}


/// @nodoc
mixin _$LivesSummary {

@JsonKey(name: 'joined_count') int get joinedCount;@JsonKey(name: 'total_duration_seconds') int get totalDurationSeconds;@JsonKey(name: 'by_type') List<ActivityTypeBreakdown> get byType;
/// Create a copy of LivesSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LivesSummaryCopyWith<LivesSummary> get copyWith => _$LivesSummaryCopyWithImpl<LivesSummary>(this as LivesSummary, _$identity);

  /// Serializes this LivesSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LivesSummary&&(identical(other.joinedCount, joinedCount) || other.joinedCount == joinedCount)&&(identical(other.totalDurationSeconds, totalDurationSeconds) || other.totalDurationSeconds == totalDurationSeconds)&&const DeepCollectionEquality().equals(other.byType, byType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,joinedCount,totalDurationSeconds,const DeepCollectionEquality().hash(byType));

@override
String toString() {
  return 'LivesSummary(joinedCount: $joinedCount, totalDurationSeconds: $totalDurationSeconds, byType: $byType)';
}


}

/// @nodoc
abstract mixin class $LivesSummaryCopyWith<$Res>  {
  factory $LivesSummaryCopyWith(LivesSummary value, $Res Function(LivesSummary) _then) = _$LivesSummaryCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'joined_count') int joinedCount,@JsonKey(name: 'total_duration_seconds') int totalDurationSeconds,@JsonKey(name: 'by_type') List<ActivityTypeBreakdown> byType
});




}
/// @nodoc
class _$LivesSummaryCopyWithImpl<$Res>
    implements $LivesSummaryCopyWith<$Res> {
  _$LivesSummaryCopyWithImpl(this._self, this._then);

  final LivesSummary _self;
  final $Res Function(LivesSummary) _then;

/// Create a copy of LivesSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? joinedCount = null,Object? totalDurationSeconds = null,Object? byType = null,}) {
  return _then(_self.copyWith(
joinedCount: null == joinedCount ? _self.joinedCount : joinedCount // ignore: cast_nullable_to_non_nullable
as int,totalDurationSeconds: null == totalDurationSeconds ? _self.totalDurationSeconds : totalDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,byType: null == byType ? _self.byType : byType // ignore: cast_nullable_to_non_nullable
as List<ActivityTypeBreakdown>,
  ));
}

}


/// Adds pattern-matching-related methods to [LivesSummary].
extension LivesSummaryPatterns on LivesSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LivesSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LivesSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LivesSummary value)  $default,){
final _that = this;
switch (_that) {
case _LivesSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LivesSummary value)?  $default,){
final _that = this;
switch (_that) {
case _LivesSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'joined_count')  int joinedCount, @JsonKey(name: 'total_duration_seconds')  int totalDurationSeconds, @JsonKey(name: 'by_type')  List<ActivityTypeBreakdown> byType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LivesSummary() when $default != null:
return $default(_that.joinedCount,_that.totalDurationSeconds,_that.byType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'joined_count')  int joinedCount, @JsonKey(name: 'total_duration_seconds')  int totalDurationSeconds, @JsonKey(name: 'by_type')  List<ActivityTypeBreakdown> byType)  $default,) {final _that = this;
switch (_that) {
case _LivesSummary():
return $default(_that.joinedCount,_that.totalDurationSeconds,_that.byType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'joined_count')  int joinedCount, @JsonKey(name: 'total_duration_seconds')  int totalDurationSeconds, @JsonKey(name: 'by_type')  List<ActivityTypeBreakdown> byType)?  $default,) {final _that = this;
switch (_that) {
case _LivesSummary() when $default != null:
return $default(_that.joinedCount,_that.totalDurationSeconds,_that.byType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LivesSummary implements LivesSummary {
  const _LivesSummary({@JsonKey(name: 'joined_count') this.joinedCount = 0, @JsonKey(name: 'total_duration_seconds') this.totalDurationSeconds = 0, @JsonKey(name: 'by_type') final  List<ActivityTypeBreakdown> byType = const <ActivityTypeBreakdown>[]}): _byType = byType;
  factory _LivesSummary.fromJson(Map<String, dynamic> json) => _$LivesSummaryFromJson(json);

@override@JsonKey(name: 'joined_count') final  int joinedCount;
@override@JsonKey(name: 'total_duration_seconds') final  int totalDurationSeconds;
 final  List<ActivityTypeBreakdown> _byType;
@override@JsonKey(name: 'by_type') List<ActivityTypeBreakdown> get byType {
  if (_byType is EqualUnmodifiableListView) return _byType;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_byType);
}


/// Create a copy of LivesSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LivesSummaryCopyWith<_LivesSummary> get copyWith => __$LivesSummaryCopyWithImpl<_LivesSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LivesSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LivesSummary&&(identical(other.joinedCount, joinedCount) || other.joinedCount == joinedCount)&&(identical(other.totalDurationSeconds, totalDurationSeconds) || other.totalDurationSeconds == totalDurationSeconds)&&const DeepCollectionEquality().equals(other._byType, _byType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,joinedCount,totalDurationSeconds,const DeepCollectionEquality().hash(_byType));

@override
String toString() {
  return 'LivesSummary(joinedCount: $joinedCount, totalDurationSeconds: $totalDurationSeconds, byType: $byType)';
}


}

/// @nodoc
abstract mixin class _$LivesSummaryCopyWith<$Res> implements $LivesSummaryCopyWith<$Res> {
  factory _$LivesSummaryCopyWith(_LivesSummary value, $Res Function(_LivesSummary) _then) = __$LivesSummaryCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'joined_count') int joinedCount,@JsonKey(name: 'total_duration_seconds') int totalDurationSeconds,@JsonKey(name: 'by_type') List<ActivityTypeBreakdown> byType
});




}
/// @nodoc
class __$LivesSummaryCopyWithImpl<$Res>
    implements _$LivesSummaryCopyWith<$Res> {
  __$LivesSummaryCopyWithImpl(this._self, this._then);

  final _LivesSummary _self;
  final $Res Function(_LivesSummary) _then;

/// Create a copy of LivesSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? joinedCount = null,Object? totalDurationSeconds = null,Object? byType = null,}) {
  return _then(_LivesSummary(
joinedCount: null == joinedCount ? _self.joinedCount : joinedCount // ignore: cast_nullable_to_non_nullable
as int,totalDurationSeconds: null == totalDurationSeconds ? _self.totalDurationSeconds : totalDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,byType: null == byType ? _self._byType : byType // ignore: cast_nullable_to_non_nullable
as List<ActivityTypeBreakdown>,
  ));
}


}


/// @nodoc
mixin _$SpendingCategory {

 String get category; int get quantity; int get count; String get label;
/// Create a copy of SpendingCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpendingCategoryCopyWith<SpendingCategory> get copyWith => _$SpendingCategoryCopyWithImpl<SpendingCategory>(this as SpendingCategory, _$identity);

  /// Serializes this SpendingCategory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpendingCategory&&(identical(other.category, category) || other.category == category)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.count, count) || other.count == count)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,category,quantity,count,label);

@override
String toString() {
  return 'SpendingCategory(category: $category, quantity: $quantity, count: $count, label: $label)';
}


}

/// @nodoc
abstract mixin class $SpendingCategoryCopyWith<$Res>  {
  factory $SpendingCategoryCopyWith(SpendingCategory value, $Res Function(SpendingCategory) _then) = _$SpendingCategoryCopyWithImpl;
@useResult
$Res call({
 String category, int quantity, int count, String label
});




}
/// @nodoc
class _$SpendingCategoryCopyWithImpl<$Res>
    implements $SpendingCategoryCopyWith<$Res> {
  _$SpendingCategoryCopyWithImpl(this._self, this._then);

  final SpendingCategory _self;
  final $Res Function(SpendingCategory) _then;

/// Create a copy of SpendingCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? category = null,Object? quantity = null,Object? count = null,Object? label = null,}) {
  return _then(_self.copyWith(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SpendingCategory].
extension SpendingCategoryPatterns on SpendingCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SpendingCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SpendingCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SpendingCategory value)  $default,){
final _that = this;
switch (_that) {
case _SpendingCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SpendingCategory value)?  $default,){
final _that = this;
switch (_that) {
case _SpendingCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String category,  int quantity,  int count,  String label)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SpendingCategory() when $default != null:
return $default(_that.category,_that.quantity,_that.count,_that.label);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String category,  int quantity,  int count,  String label)  $default,) {final _that = this;
switch (_that) {
case _SpendingCategory():
return $default(_that.category,_that.quantity,_that.count,_that.label);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String category,  int quantity,  int count,  String label)?  $default,) {final _that = this;
switch (_that) {
case _SpendingCategory() when $default != null:
return $default(_that.category,_that.quantity,_that.count,_that.label);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SpendingCategory implements SpendingCategory {
  const _SpendingCategory({this.category = '', this.quantity = 0, this.count = 0, this.label = ''});
  factory _SpendingCategory.fromJson(Map<String, dynamic> json) => _$SpendingCategoryFromJson(json);

@override@JsonKey() final  String category;
@override@JsonKey() final  int quantity;
@override@JsonKey() final  int count;
@override@JsonKey() final  String label;

/// Create a copy of SpendingCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpendingCategoryCopyWith<_SpendingCategory> get copyWith => __$SpendingCategoryCopyWithImpl<_SpendingCategory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SpendingCategoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SpendingCategory&&(identical(other.category, category) || other.category == category)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.count, count) || other.count == count)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,category,quantity,count,label);

@override
String toString() {
  return 'SpendingCategory(category: $category, quantity: $quantity, count: $count, label: $label)';
}


}

/// @nodoc
abstract mixin class _$SpendingCategoryCopyWith<$Res> implements $SpendingCategoryCopyWith<$Res> {
  factory _$SpendingCategoryCopyWith(_SpendingCategory value, $Res Function(_SpendingCategory) _then) = __$SpendingCategoryCopyWithImpl;
@override @useResult
$Res call({
 String category, int quantity, int count, String label
});




}
/// @nodoc
class __$SpendingCategoryCopyWithImpl<$Res>
    implements _$SpendingCategoryCopyWith<$Res> {
  __$SpendingCategoryCopyWithImpl(this._self, this._then);

  final _SpendingCategory _self;
  final $Res Function(_SpendingCategory) _then;

/// Create a copy of SpendingCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? category = null,Object? quantity = null,Object? count = null,Object? label = null,}) {
  return _then(_SpendingCategory(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SpendingSummary {

@JsonKey(name: 'gifts_sent') SpendingCategory get giftsSent;@JsonKey(name: 'gifts_received') SpendingCategory get giftsReceived;@JsonKey(name: 'tips_sent') SpendingCategory get tipsSent;@JsonKey(name: 'tips_received') SpendingCategory get tipsReceived;@JsonKey(name: 'live_fees') SpendingCategory get liveFees;@JsonKey(name: 'gym_subscriptions') SpendingCategory get gymSubscriptions;@JsonKey(name: 'session_fees') SpendingCategory get sessionFees;@JsonKey(name: 'marketplace_spend') SpendingCategory get marketplaceSpend;@JsonKey(name: 'total_transactions') int get totalTransactions;@JsonKey(name: 'total_artifacts_spent') int get totalArtifactsSpent; List<SpendingCategory> get breakdown;
/// Create a copy of SpendingSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpendingSummaryCopyWith<SpendingSummary> get copyWith => _$SpendingSummaryCopyWithImpl<SpendingSummary>(this as SpendingSummary, _$identity);

  /// Serializes this SpendingSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpendingSummary&&(identical(other.giftsSent, giftsSent) || other.giftsSent == giftsSent)&&(identical(other.giftsReceived, giftsReceived) || other.giftsReceived == giftsReceived)&&(identical(other.tipsSent, tipsSent) || other.tipsSent == tipsSent)&&(identical(other.tipsReceived, tipsReceived) || other.tipsReceived == tipsReceived)&&(identical(other.liveFees, liveFees) || other.liveFees == liveFees)&&(identical(other.gymSubscriptions, gymSubscriptions) || other.gymSubscriptions == gymSubscriptions)&&(identical(other.sessionFees, sessionFees) || other.sessionFees == sessionFees)&&(identical(other.marketplaceSpend, marketplaceSpend) || other.marketplaceSpend == marketplaceSpend)&&(identical(other.totalTransactions, totalTransactions) || other.totalTransactions == totalTransactions)&&(identical(other.totalArtifactsSpent, totalArtifactsSpent) || other.totalArtifactsSpent == totalArtifactsSpent)&&const DeepCollectionEquality().equals(other.breakdown, breakdown));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,giftsSent,giftsReceived,tipsSent,tipsReceived,liveFees,gymSubscriptions,sessionFees,marketplaceSpend,totalTransactions,totalArtifactsSpent,const DeepCollectionEquality().hash(breakdown));

@override
String toString() {
  return 'SpendingSummary(giftsSent: $giftsSent, giftsReceived: $giftsReceived, tipsSent: $tipsSent, tipsReceived: $tipsReceived, liveFees: $liveFees, gymSubscriptions: $gymSubscriptions, sessionFees: $sessionFees, marketplaceSpend: $marketplaceSpend, totalTransactions: $totalTransactions, totalArtifactsSpent: $totalArtifactsSpent, breakdown: $breakdown)';
}


}

/// @nodoc
abstract mixin class $SpendingSummaryCopyWith<$Res>  {
  factory $SpendingSummaryCopyWith(SpendingSummary value, $Res Function(SpendingSummary) _then) = _$SpendingSummaryCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'gifts_sent') SpendingCategory giftsSent,@JsonKey(name: 'gifts_received') SpendingCategory giftsReceived,@JsonKey(name: 'tips_sent') SpendingCategory tipsSent,@JsonKey(name: 'tips_received') SpendingCategory tipsReceived,@JsonKey(name: 'live_fees') SpendingCategory liveFees,@JsonKey(name: 'gym_subscriptions') SpendingCategory gymSubscriptions,@JsonKey(name: 'session_fees') SpendingCategory sessionFees,@JsonKey(name: 'marketplace_spend') SpendingCategory marketplaceSpend,@JsonKey(name: 'total_transactions') int totalTransactions,@JsonKey(name: 'total_artifacts_spent') int totalArtifactsSpent, List<SpendingCategory> breakdown
});


$SpendingCategoryCopyWith<$Res> get giftsSent;$SpendingCategoryCopyWith<$Res> get giftsReceived;$SpendingCategoryCopyWith<$Res> get tipsSent;$SpendingCategoryCopyWith<$Res> get tipsReceived;$SpendingCategoryCopyWith<$Res> get liveFees;$SpendingCategoryCopyWith<$Res> get gymSubscriptions;$SpendingCategoryCopyWith<$Res> get sessionFees;$SpendingCategoryCopyWith<$Res> get marketplaceSpend;

}
/// @nodoc
class _$SpendingSummaryCopyWithImpl<$Res>
    implements $SpendingSummaryCopyWith<$Res> {
  _$SpendingSummaryCopyWithImpl(this._self, this._then);

  final SpendingSummary _self;
  final $Res Function(SpendingSummary) _then;

/// Create a copy of SpendingSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? giftsSent = null,Object? giftsReceived = null,Object? tipsSent = null,Object? tipsReceived = null,Object? liveFees = null,Object? gymSubscriptions = null,Object? sessionFees = null,Object? marketplaceSpend = null,Object? totalTransactions = null,Object? totalArtifactsSpent = null,Object? breakdown = null,}) {
  return _then(_self.copyWith(
giftsSent: null == giftsSent ? _self.giftsSent : giftsSent // ignore: cast_nullable_to_non_nullable
as SpendingCategory,giftsReceived: null == giftsReceived ? _self.giftsReceived : giftsReceived // ignore: cast_nullable_to_non_nullable
as SpendingCategory,tipsSent: null == tipsSent ? _self.tipsSent : tipsSent // ignore: cast_nullable_to_non_nullable
as SpendingCategory,tipsReceived: null == tipsReceived ? _self.tipsReceived : tipsReceived // ignore: cast_nullable_to_non_nullable
as SpendingCategory,liveFees: null == liveFees ? _self.liveFees : liveFees // ignore: cast_nullable_to_non_nullable
as SpendingCategory,gymSubscriptions: null == gymSubscriptions ? _self.gymSubscriptions : gymSubscriptions // ignore: cast_nullable_to_non_nullable
as SpendingCategory,sessionFees: null == sessionFees ? _self.sessionFees : sessionFees // ignore: cast_nullable_to_non_nullable
as SpendingCategory,marketplaceSpend: null == marketplaceSpend ? _self.marketplaceSpend : marketplaceSpend // ignore: cast_nullable_to_non_nullable
as SpendingCategory,totalTransactions: null == totalTransactions ? _self.totalTransactions : totalTransactions // ignore: cast_nullable_to_non_nullable
as int,totalArtifactsSpent: null == totalArtifactsSpent ? _self.totalArtifactsSpent : totalArtifactsSpent // ignore: cast_nullable_to_non_nullable
as int,breakdown: null == breakdown ? _self.breakdown : breakdown // ignore: cast_nullable_to_non_nullable
as List<SpendingCategory>,
  ));
}
/// Create a copy of SpendingSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SpendingCategoryCopyWith<$Res> get giftsSent {
  
  return $SpendingCategoryCopyWith<$Res>(_self.giftsSent, (value) {
    return _then(_self.copyWith(giftsSent: value));
  });
}/// Create a copy of SpendingSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SpendingCategoryCopyWith<$Res> get giftsReceived {
  
  return $SpendingCategoryCopyWith<$Res>(_self.giftsReceived, (value) {
    return _then(_self.copyWith(giftsReceived: value));
  });
}/// Create a copy of SpendingSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SpendingCategoryCopyWith<$Res> get tipsSent {
  
  return $SpendingCategoryCopyWith<$Res>(_self.tipsSent, (value) {
    return _then(_self.copyWith(tipsSent: value));
  });
}/// Create a copy of SpendingSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SpendingCategoryCopyWith<$Res> get tipsReceived {
  
  return $SpendingCategoryCopyWith<$Res>(_self.tipsReceived, (value) {
    return _then(_self.copyWith(tipsReceived: value));
  });
}/// Create a copy of SpendingSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SpendingCategoryCopyWith<$Res> get liveFees {
  
  return $SpendingCategoryCopyWith<$Res>(_self.liveFees, (value) {
    return _then(_self.copyWith(liveFees: value));
  });
}/// Create a copy of SpendingSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SpendingCategoryCopyWith<$Res> get gymSubscriptions {
  
  return $SpendingCategoryCopyWith<$Res>(_self.gymSubscriptions, (value) {
    return _then(_self.copyWith(gymSubscriptions: value));
  });
}/// Create a copy of SpendingSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SpendingCategoryCopyWith<$Res> get sessionFees {
  
  return $SpendingCategoryCopyWith<$Res>(_self.sessionFees, (value) {
    return _then(_self.copyWith(sessionFees: value));
  });
}/// Create a copy of SpendingSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SpendingCategoryCopyWith<$Res> get marketplaceSpend {
  
  return $SpendingCategoryCopyWith<$Res>(_self.marketplaceSpend, (value) {
    return _then(_self.copyWith(marketplaceSpend: value));
  });
}
}


/// Adds pattern-matching-related methods to [SpendingSummary].
extension SpendingSummaryPatterns on SpendingSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SpendingSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SpendingSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SpendingSummary value)  $default,){
final _that = this;
switch (_that) {
case _SpendingSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SpendingSummary value)?  $default,){
final _that = this;
switch (_that) {
case _SpendingSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'gifts_sent')  SpendingCategory giftsSent, @JsonKey(name: 'gifts_received')  SpendingCategory giftsReceived, @JsonKey(name: 'tips_sent')  SpendingCategory tipsSent, @JsonKey(name: 'tips_received')  SpendingCategory tipsReceived, @JsonKey(name: 'live_fees')  SpendingCategory liveFees, @JsonKey(name: 'gym_subscriptions')  SpendingCategory gymSubscriptions, @JsonKey(name: 'session_fees')  SpendingCategory sessionFees, @JsonKey(name: 'marketplace_spend')  SpendingCategory marketplaceSpend, @JsonKey(name: 'total_transactions')  int totalTransactions, @JsonKey(name: 'total_artifacts_spent')  int totalArtifactsSpent,  List<SpendingCategory> breakdown)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SpendingSummary() when $default != null:
return $default(_that.giftsSent,_that.giftsReceived,_that.tipsSent,_that.tipsReceived,_that.liveFees,_that.gymSubscriptions,_that.sessionFees,_that.marketplaceSpend,_that.totalTransactions,_that.totalArtifactsSpent,_that.breakdown);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'gifts_sent')  SpendingCategory giftsSent, @JsonKey(name: 'gifts_received')  SpendingCategory giftsReceived, @JsonKey(name: 'tips_sent')  SpendingCategory tipsSent, @JsonKey(name: 'tips_received')  SpendingCategory tipsReceived, @JsonKey(name: 'live_fees')  SpendingCategory liveFees, @JsonKey(name: 'gym_subscriptions')  SpendingCategory gymSubscriptions, @JsonKey(name: 'session_fees')  SpendingCategory sessionFees, @JsonKey(name: 'marketplace_spend')  SpendingCategory marketplaceSpend, @JsonKey(name: 'total_transactions')  int totalTransactions, @JsonKey(name: 'total_artifacts_spent')  int totalArtifactsSpent,  List<SpendingCategory> breakdown)  $default,) {final _that = this;
switch (_that) {
case _SpendingSummary():
return $default(_that.giftsSent,_that.giftsReceived,_that.tipsSent,_that.tipsReceived,_that.liveFees,_that.gymSubscriptions,_that.sessionFees,_that.marketplaceSpend,_that.totalTransactions,_that.totalArtifactsSpent,_that.breakdown);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'gifts_sent')  SpendingCategory giftsSent, @JsonKey(name: 'gifts_received')  SpendingCategory giftsReceived, @JsonKey(name: 'tips_sent')  SpendingCategory tipsSent, @JsonKey(name: 'tips_received')  SpendingCategory tipsReceived, @JsonKey(name: 'live_fees')  SpendingCategory liveFees, @JsonKey(name: 'gym_subscriptions')  SpendingCategory gymSubscriptions, @JsonKey(name: 'session_fees')  SpendingCategory sessionFees, @JsonKey(name: 'marketplace_spend')  SpendingCategory marketplaceSpend, @JsonKey(name: 'total_transactions')  int totalTransactions, @JsonKey(name: 'total_artifacts_spent')  int totalArtifactsSpent,  List<SpendingCategory> breakdown)?  $default,) {final _that = this;
switch (_that) {
case _SpendingSummary() when $default != null:
return $default(_that.giftsSent,_that.giftsReceived,_that.tipsSent,_that.tipsReceived,_that.liveFees,_that.gymSubscriptions,_that.sessionFees,_that.marketplaceSpend,_that.totalTransactions,_that.totalArtifactsSpent,_that.breakdown);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SpendingSummary implements SpendingSummary {
  const _SpendingSummary({@JsonKey(name: 'gifts_sent') this.giftsSent = const SpendingCategory(), @JsonKey(name: 'gifts_received') this.giftsReceived = const SpendingCategory(), @JsonKey(name: 'tips_sent') this.tipsSent = const SpendingCategory(), @JsonKey(name: 'tips_received') this.tipsReceived = const SpendingCategory(), @JsonKey(name: 'live_fees') this.liveFees = const SpendingCategory(), @JsonKey(name: 'gym_subscriptions') this.gymSubscriptions = const SpendingCategory(), @JsonKey(name: 'session_fees') this.sessionFees = const SpendingCategory(), @JsonKey(name: 'marketplace_spend') this.marketplaceSpend = const SpendingCategory(), @JsonKey(name: 'total_transactions') this.totalTransactions = 0, @JsonKey(name: 'total_artifacts_spent') this.totalArtifactsSpent = 0, final  List<SpendingCategory> breakdown = const <SpendingCategory>[]}): _breakdown = breakdown;
  factory _SpendingSummary.fromJson(Map<String, dynamic> json) => _$SpendingSummaryFromJson(json);

@override@JsonKey(name: 'gifts_sent') final  SpendingCategory giftsSent;
@override@JsonKey(name: 'gifts_received') final  SpendingCategory giftsReceived;
@override@JsonKey(name: 'tips_sent') final  SpendingCategory tipsSent;
@override@JsonKey(name: 'tips_received') final  SpendingCategory tipsReceived;
@override@JsonKey(name: 'live_fees') final  SpendingCategory liveFees;
@override@JsonKey(name: 'gym_subscriptions') final  SpendingCategory gymSubscriptions;
@override@JsonKey(name: 'session_fees') final  SpendingCategory sessionFees;
@override@JsonKey(name: 'marketplace_spend') final  SpendingCategory marketplaceSpend;
@override@JsonKey(name: 'total_transactions') final  int totalTransactions;
@override@JsonKey(name: 'total_artifacts_spent') final  int totalArtifactsSpent;
 final  List<SpendingCategory> _breakdown;
@override@JsonKey() List<SpendingCategory> get breakdown {
  if (_breakdown is EqualUnmodifiableListView) return _breakdown;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_breakdown);
}


/// Create a copy of SpendingSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpendingSummaryCopyWith<_SpendingSummary> get copyWith => __$SpendingSummaryCopyWithImpl<_SpendingSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SpendingSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SpendingSummary&&(identical(other.giftsSent, giftsSent) || other.giftsSent == giftsSent)&&(identical(other.giftsReceived, giftsReceived) || other.giftsReceived == giftsReceived)&&(identical(other.tipsSent, tipsSent) || other.tipsSent == tipsSent)&&(identical(other.tipsReceived, tipsReceived) || other.tipsReceived == tipsReceived)&&(identical(other.liveFees, liveFees) || other.liveFees == liveFees)&&(identical(other.gymSubscriptions, gymSubscriptions) || other.gymSubscriptions == gymSubscriptions)&&(identical(other.sessionFees, sessionFees) || other.sessionFees == sessionFees)&&(identical(other.marketplaceSpend, marketplaceSpend) || other.marketplaceSpend == marketplaceSpend)&&(identical(other.totalTransactions, totalTransactions) || other.totalTransactions == totalTransactions)&&(identical(other.totalArtifactsSpent, totalArtifactsSpent) || other.totalArtifactsSpent == totalArtifactsSpent)&&const DeepCollectionEquality().equals(other._breakdown, _breakdown));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,giftsSent,giftsReceived,tipsSent,tipsReceived,liveFees,gymSubscriptions,sessionFees,marketplaceSpend,totalTransactions,totalArtifactsSpent,const DeepCollectionEquality().hash(_breakdown));

@override
String toString() {
  return 'SpendingSummary(giftsSent: $giftsSent, giftsReceived: $giftsReceived, tipsSent: $tipsSent, tipsReceived: $tipsReceived, liveFees: $liveFees, gymSubscriptions: $gymSubscriptions, sessionFees: $sessionFees, marketplaceSpend: $marketplaceSpend, totalTransactions: $totalTransactions, totalArtifactsSpent: $totalArtifactsSpent, breakdown: $breakdown)';
}


}

/// @nodoc
abstract mixin class _$SpendingSummaryCopyWith<$Res> implements $SpendingSummaryCopyWith<$Res> {
  factory _$SpendingSummaryCopyWith(_SpendingSummary value, $Res Function(_SpendingSummary) _then) = __$SpendingSummaryCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'gifts_sent') SpendingCategory giftsSent,@JsonKey(name: 'gifts_received') SpendingCategory giftsReceived,@JsonKey(name: 'tips_sent') SpendingCategory tipsSent,@JsonKey(name: 'tips_received') SpendingCategory tipsReceived,@JsonKey(name: 'live_fees') SpendingCategory liveFees,@JsonKey(name: 'gym_subscriptions') SpendingCategory gymSubscriptions,@JsonKey(name: 'session_fees') SpendingCategory sessionFees,@JsonKey(name: 'marketplace_spend') SpendingCategory marketplaceSpend,@JsonKey(name: 'total_transactions') int totalTransactions,@JsonKey(name: 'total_artifacts_spent') int totalArtifactsSpent, List<SpendingCategory> breakdown
});


@override $SpendingCategoryCopyWith<$Res> get giftsSent;@override $SpendingCategoryCopyWith<$Res> get giftsReceived;@override $SpendingCategoryCopyWith<$Res> get tipsSent;@override $SpendingCategoryCopyWith<$Res> get tipsReceived;@override $SpendingCategoryCopyWith<$Res> get liveFees;@override $SpendingCategoryCopyWith<$Res> get gymSubscriptions;@override $SpendingCategoryCopyWith<$Res> get sessionFees;@override $SpendingCategoryCopyWith<$Res> get marketplaceSpend;

}
/// @nodoc
class __$SpendingSummaryCopyWithImpl<$Res>
    implements _$SpendingSummaryCopyWith<$Res> {
  __$SpendingSummaryCopyWithImpl(this._self, this._then);

  final _SpendingSummary _self;
  final $Res Function(_SpendingSummary) _then;

/// Create a copy of SpendingSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? giftsSent = null,Object? giftsReceived = null,Object? tipsSent = null,Object? tipsReceived = null,Object? liveFees = null,Object? gymSubscriptions = null,Object? sessionFees = null,Object? marketplaceSpend = null,Object? totalTransactions = null,Object? totalArtifactsSpent = null,Object? breakdown = null,}) {
  return _then(_SpendingSummary(
giftsSent: null == giftsSent ? _self.giftsSent : giftsSent // ignore: cast_nullable_to_non_nullable
as SpendingCategory,giftsReceived: null == giftsReceived ? _self.giftsReceived : giftsReceived // ignore: cast_nullable_to_non_nullable
as SpendingCategory,tipsSent: null == tipsSent ? _self.tipsSent : tipsSent // ignore: cast_nullable_to_non_nullable
as SpendingCategory,tipsReceived: null == tipsReceived ? _self.tipsReceived : tipsReceived // ignore: cast_nullable_to_non_nullable
as SpendingCategory,liveFees: null == liveFees ? _self.liveFees : liveFees // ignore: cast_nullable_to_non_nullable
as SpendingCategory,gymSubscriptions: null == gymSubscriptions ? _self.gymSubscriptions : gymSubscriptions // ignore: cast_nullable_to_non_nullable
as SpendingCategory,sessionFees: null == sessionFees ? _self.sessionFees : sessionFees // ignore: cast_nullable_to_non_nullable
as SpendingCategory,marketplaceSpend: null == marketplaceSpend ? _self.marketplaceSpend : marketplaceSpend // ignore: cast_nullable_to_non_nullable
as SpendingCategory,totalTransactions: null == totalTransactions ? _self.totalTransactions : totalTransactions // ignore: cast_nullable_to_non_nullable
as int,totalArtifactsSpent: null == totalArtifactsSpent ? _self.totalArtifactsSpent : totalArtifactsSpent // ignore: cast_nullable_to_non_nullable
as int,breakdown: null == breakdown ? _self._breakdown : breakdown // ignore: cast_nullable_to_non_nullable
as List<SpendingCategory>,
  ));
}

/// Create a copy of SpendingSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SpendingCategoryCopyWith<$Res> get giftsSent {
  
  return $SpendingCategoryCopyWith<$Res>(_self.giftsSent, (value) {
    return _then(_self.copyWith(giftsSent: value));
  });
}/// Create a copy of SpendingSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SpendingCategoryCopyWith<$Res> get giftsReceived {
  
  return $SpendingCategoryCopyWith<$Res>(_self.giftsReceived, (value) {
    return _then(_self.copyWith(giftsReceived: value));
  });
}/// Create a copy of SpendingSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SpendingCategoryCopyWith<$Res> get tipsSent {
  
  return $SpendingCategoryCopyWith<$Res>(_self.tipsSent, (value) {
    return _then(_self.copyWith(tipsSent: value));
  });
}/// Create a copy of SpendingSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SpendingCategoryCopyWith<$Res> get tipsReceived {
  
  return $SpendingCategoryCopyWith<$Res>(_self.tipsReceived, (value) {
    return _then(_self.copyWith(tipsReceived: value));
  });
}/// Create a copy of SpendingSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SpendingCategoryCopyWith<$Res> get liveFees {
  
  return $SpendingCategoryCopyWith<$Res>(_self.liveFees, (value) {
    return _then(_self.copyWith(liveFees: value));
  });
}/// Create a copy of SpendingSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SpendingCategoryCopyWith<$Res> get gymSubscriptions {
  
  return $SpendingCategoryCopyWith<$Res>(_self.gymSubscriptions, (value) {
    return _then(_self.copyWith(gymSubscriptions: value));
  });
}/// Create a copy of SpendingSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SpendingCategoryCopyWith<$Res> get sessionFees {
  
  return $SpendingCategoryCopyWith<$Res>(_self.sessionFees, (value) {
    return _then(_self.copyWith(sessionFees: value));
  });
}/// Create a copy of SpendingSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SpendingCategoryCopyWith<$Res> get marketplaceSpend {
  
  return $SpendingCategoryCopyWith<$Res>(_self.marketplaceSpend, (value) {
    return _then(_self.copyWith(marketplaceSpend: value));
  });
}
}


/// @nodoc
mixin _$CountdownEntry {

 String get id; String get reason; String get icon; String get unit;@JsonKey(name: 'countdown_type') String get countdownType;@JsonKey(name: 'current_count') int get currentCount;@JsonKey(name: 'target_count') int get targetCount;@JsonKey(name: 'elapsed_units') int get elapsedUnits;@JsonKey(name: 'longest_run_units') double get longestRunUnits; int get checkins; int get resets; bool get completed;@JsonKey(name: 'is_active') bool get isActive;@JsonKey(name: 'last_event_at') String? get lastEventAt;
/// Create a copy of CountdownEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CountdownEntryCopyWith<CountdownEntry> get copyWith => _$CountdownEntryCopyWithImpl<CountdownEntry>(this as CountdownEntry, _$identity);

  /// Serializes this CountdownEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CountdownEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.countdownType, countdownType) || other.countdownType == countdownType)&&(identical(other.currentCount, currentCount) || other.currentCount == currentCount)&&(identical(other.targetCount, targetCount) || other.targetCount == targetCount)&&(identical(other.elapsedUnits, elapsedUnits) || other.elapsedUnits == elapsedUnits)&&(identical(other.longestRunUnits, longestRunUnits) || other.longestRunUnits == longestRunUnits)&&(identical(other.checkins, checkins) || other.checkins == checkins)&&(identical(other.resets, resets) || other.resets == resets)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.lastEventAt, lastEventAt) || other.lastEventAt == lastEventAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reason,icon,unit,countdownType,currentCount,targetCount,elapsedUnits,longestRunUnits,checkins,resets,completed,isActive,lastEventAt);

@override
String toString() {
  return 'CountdownEntry(id: $id, reason: $reason, icon: $icon, unit: $unit, countdownType: $countdownType, currentCount: $currentCount, targetCount: $targetCount, elapsedUnits: $elapsedUnits, longestRunUnits: $longestRunUnits, checkins: $checkins, resets: $resets, completed: $completed, isActive: $isActive, lastEventAt: $lastEventAt)';
}


}

/// @nodoc
abstract mixin class $CountdownEntryCopyWith<$Res>  {
  factory $CountdownEntryCopyWith(CountdownEntry value, $Res Function(CountdownEntry) _then) = _$CountdownEntryCopyWithImpl;
@useResult
$Res call({
 String id, String reason, String icon, String unit,@JsonKey(name: 'countdown_type') String countdownType,@JsonKey(name: 'current_count') int currentCount,@JsonKey(name: 'target_count') int targetCount,@JsonKey(name: 'elapsed_units') int elapsedUnits,@JsonKey(name: 'longest_run_units') double longestRunUnits, int checkins, int resets, bool completed,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'last_event_at') String? lastEventAt
});




}
/// @nodoc
class _$CountdownEntryCopyWithImpl<$Res>
    implements $CountdownEntryCopyWith<$Res> {
  _$CountdownEntryCopyWithImpl(this._self, this._then);

  final CountdownEntry _self;
  final $Res Function(CountdownEntry) _then;

/// Create a copy of CountdownEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reason = null,Object? icon = null,Object? unit = null,Object? countdownType = null,Object? currentCount = null,Object? targetCount = null,Object? elapsedUnits = null,Object? longestRunUnits = null,Object? checkins = null,Object? resets = null,Object? completed = null,Object? isActive = null,Object? lastEventAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,countdownType: null == countdownType ? _self.countdownType : countdownType // ignore: cast_nullable_to_non_nullable
as String,currentCount: null == currentCount ? _self.currentCount : currentCount // ignore: cast_nullable_to_non_nullable
as int,targetCount: null == targetCount ? _self.targetCount : targetCount // ignore: cast_nullable_to_non_nullable
as int,elapsedUnits: null == elapsedUnits ? _self.elapsedUnits : elapsedUnits // ignore: cast_nullable_to_non_nullable
as int,longestRunUnits: null == longestRunUnits ? _self.longestRunUnits : longestRunUnits // ignore: cast_nullable_to_non_nullable
as double,checkins: null == checkins ? _self.checkins : checkins // ignore: cast_nullable_to_non_nullable
as int,resets: null == resets ? _self.resets : resets // ignore: cast_nullable_to_non_nullable
as int,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,lastEventAt: freezed == lastEventAt ? _self.lastEventAt : lastEventAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CountdownEntry].
extension CountdownEntryPatterns on CountdownEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CountdownEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CountdownEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CountdownEntry value)  $default,){
final _that = this;
switch (_that) {
case _CountdownEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CountdownEntry value)?  $default,){
final _that = this;
switch (_that) {
case _CountdownEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String reason,  String icon,  String unit, @JsonKey(name: 'countdown_type')  String countdownType, @JsonKey(name: 'current_count')  int currentCount, @JsonKey(name: 'target_count')  int targetCount, @JsonKey(name: 'elapsed_units')  int elapsedUnits, @JsonKey(name: 'longest_run_units')  double longestRunUnits,  int checkins,  int resets,  bool completed, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'last_event_at')  String? lastEventAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CountdownEntry() when $default != null:
return $default(_that.id,_that.reason,_that.icon,_that.unit,_that.countdownType,_that.currentCount,_that.targetCount,_that.elapsedUnits,_that.longestRunUnits,_that.checkins,_that.resets,_that.completed,_that.isActive,_that.lastEventAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String reason,  String icon,  String unit, @JsonKey(name: 'countdown_type')  String countdownType, @JsonKey(name: 'current_count')  int currentCount, @JsonKey(name: 'target_count')  int targetCount, @JsonKey(name: 'elapsed_units')  int elapsedUnits, @JsonKey(name: 'longest_run_units')  double longestRunUnits,  int checkins,  int resets,  bool completed, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'last_event_at')  String? lastEventAt)  $default,) {final _that = this;
switch (_that) {
case _CountdownEntry():
return $default(_that.id,_that.reason,_that.icon,_that.unit,_that.countdownType,_that.currentCount,_that.targetCount,_that.elapsedUnits,_that.longestRunUnits,_that.checkins,_that.resets,_that.completed,_that.isActive,_that.lastEventAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String reason,  String icon,  String unit, @JsonKey(name: 'countdown_type')  String countdownType, @JsonKey(name: 'current_count')  int currentCount, @JsonKey(name: 'target_count')  int targetCount, @JsonKey(name: 'elapsed_units')  int elapsedUnits, @JsonKey(name: 'longest_run_units')  double longestRunUnits,  int checkins,  int resets,  bool completed, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'last_event_at')  String? lastEventAt)?  $default,) {final _that = this;
switch (_that) {
case _CountdownEntry() when $default != null:
return $default(_that.id,_that.reason,_that.icon,_that.unit,_that.countdownType,_that.currentCount,_that.targetCount,_that.elapsedUnits,_that.longestRunUnits,_that.checkins,_that.resets,_that.completed,_that.isActive,_that.lastEventAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CountdownEntry implements CountdownEntry {
  const _CountdownEntry({this.id = '', this.reason = '', this.icon = '', this.unit = 'days', @JsonKey(name: 'countdown_type') this.countdownType = '', @JsonKey(name: 'current_count') this.currentCount = 0, @JsonKey(name: 'target_count') this.targetCount = 0, @JsonKey(name: 'elapsed_units') this.elapsedUnits = 0, @JsonKey(name: 'longest_run_units') this.longestRunUnits = 0, this.checkins = 0, this.resets = 0, this.completed = false, @JsonKey(name: 'is_active') this.isActive = true, @JsonKey(name: 'last_event_at') this.lastEventAt});
  factory _CountdownEntry.fromJson(Map<String, dynamic> json) => _$CountdownEntryFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String reason;
@override@JsonKey() final  String icon;
@override@JsonKey() final  String unit;
@override@JsonKey(name: 'countdown_type') final  String countdownType;
@override@JsonKey(name: 'current_count') final  int currentCount;
@override@JsonKey(name: 'target_count') final  int targetCount;
@override@JsonKey(name: 'elapsed_units') final  int elapsedUnits;
@override@JsonKey(name: 'longest_run_units') final  double longestRunUnits;
@override@JsonKey() final  int checkins;
@override@JsonKey() final  int resets;
@override@JsonKey() final  bool completed;
@override@JsonKey(name: 'is_active') final  bool isActive;
@override@JsonKey(name: 'last_event_at') final  String? lastEventAt;

/// Create a copy of CountdownEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CountdownEntryCopyWith<_CountdownEntry> get copyWith => __$CountdownEntryCopyWithImpl<_CountdownEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CountdownEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CountdownEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.countdownType, countdownType) || other.countdownType == countdownType)&&(identical(other.currentCount, currentCount) || other.currentCount == currentCount)&&(identical(other.targetCount, targetCount) || other.targetCount == targetCount)&&(identical(other.elapsedUnits, elapsedUnits) || other.elapsedUnits == elapsedUnits)&&(identical(other.longestRunUnits, longestRunUnits) || other.longestRunUnits == longestRunUnits)&&(identical(other.checkins, checkins) || other.checkins == checkins)&&(identical(other.resets, resets) || other.resets == resets)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.lastEventAt, lastEventAt) || other.lastEventAt == lastEventAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reason,icon,unit,countdownType,currentCount,targetCount,elapsedUnits,longestRunUnits,checkins,resets,completed,isActive,lastEventAt);

@override
String toString() {
  return 'CountdownEntry(id: $id, reason: $reason, icon: $icon, unit: $unit, countdownType: $countdownType, currentCount: $currentCount, targetCount: $targetCount, elapsedUnits: $elapsedUnits, longestRunUnits: $longestRunUnits, checkins: $checkins, resets: $resets, completed: $completed, isActive: $isActive, lastEventAt: $lastEventAt)';
}


}

/// @nodoc
abstract mixin class _$CountdownEntryCopyWith<$Res> implements $CountdownEntryCopyWith<$Res> {
  factory _$CountdownEntryCopyWith(_CountdownEntry value, $Res Function(_CountdownEntry) _then) = __$CountdownEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String reason, String icon, String unit,@JsonKey(name: 'countdown_type') String countdownType,@JsonKey(name: 'current_count') int currentCount,@JsonKey(name: 'target_count') int targetCount,@JsonKey(name: 'elapsed_units') int elapsedUnits,@JsonKey(name: 'longest_run_units') double longestRunUnits, int checkins, int resets, bool completed,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'last_event_at') String? lastEventAt
});




}
/// @nodoc
class __$CountdownEntryCopyWithImpl<$Res>
    implements _$CountdownEntryCopyWith<$Res> {
  __$CountdownEntryCopyWithImpl(this._self, this._then);

  final _CountdownEntry _self;
  final $Res Function(_CountdownEntry) _then;

/// Create a copy of CountdownEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reason = null,Object? icon = null,Object? unit = null,Object? countdownType = null,Object? currentCount = null,Object? targetCount = null,Object? elapsedUnits = null,Object? longestRunUnits = null,Object? checkins = null,Object? resets = null,Object? completed = null,Object? isActive = null,Object? lastEventAt = freezed,}) {
  return _then(_CountdownEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,countdownType: null == countdownType ? _self.countdownType : countdownType // ignore: cast_nullable_to_non_nullable
as String,currentCount: null == currentCount ? _self.currentCount : currentCount // ignore: cast_nullable_to_non_nullable
as int,targetCount: null == targetCount ? _self.targetCount : targetCount // ignore: cast_nullable_to_non_nullable
as int,elapsedUnits: null == elapsedUnits ? _self.elapsedUnits : elapsedUnits // ignore: cast_nullable_to_non_nullable
as int,longestRunUnits: null == longestRunUnits ? _self.longestRunUnits : longestRunUnits // ignore: cast_nullable_to_non_nullable
as double,checkins: null == checkins ? _self.checkins : checkins // ignore: cast_nullable_to_non_nullable
as int,resets: null == resets ? _self.resets : resets // ignore: cast_nullable_to_non_nullable
as int,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,lastEventAt: freezed == lastEventAt ? _self.lastEventAt : lastEventAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CountdownEventEntry {

 String get id;@JsonKey(name: 'countdown_id') String get countdownId;@JsonKey(name: 'event_type') String get eventType;@JsonKey(name: 'count_after') int get countAfter;@JsonKey(name: 'elapsed_seconds') double get elapsedSeconds;@JsonKey(name: 'run_elapsed_seconds') double get runElapsedSeconds; String get unit;@JsonKey(name: 'occurred_at') String get occurredAt;
/// Create a copy of CountdownEventEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CountdownEventEntryCopyWith<CountdownEventEntry> get copyWith => _$CountdownEventEntryCopyWithImpl<CountdownEventEntry>(this as CountdownEventEntry, _$identity);

  /// Serializes this CountdownEventEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CountdownEventEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.countdownId, countdownId) || other.countdownId == countdownId)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.countAfter, countAfter) || other.countAfter == countAfter)&&(identical(other.elapsedSeconds, elapsedSeconds) || other.elapsedSeconds == elapsedSeconds)&&(identical(other.runElapsedSeconds, runElapsedSeconds) || other.runElapsedSeconds == runElapsedSeconds)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,countdownId,eventType,countAfter,elapsedSeconds,runElapsedSeconds,unit,occurredAt);

@override
String toString() {
  return 'CountdownEventEntry(id: $id, countdownId: $countdownId, eventType: $eventType, countAfter: $countAfter, elapsedSeconds: $elapsedSeconds, runElapsedSeconds: $runElapsedSeconds, unit: $unit, occurredAt: $occurredAt)';
}


}

/// @nodoc
abstract mixin class $CountdownEventEntryCopyWith<$Res>  {
  factory $CountdownEventEntryCopyWith(CountdownEventEntry value, $Res Function(CountdownEventEntry) _then) = _$CountdownEventEntryCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'countdown_id') String countdownId,@JsonKey(name: 'event_type') String eventType,@JsonKey(name: 'count_after') int countAfter,@JsonKey(name: 'elapsed_seconds') double elapsedSeconds,@JsonKey(name: 'run_elapsed_seconds') double runElapsedSeconds, String unit,@JsonKey(name: 'occurred_at') String occurredAt
});




}
/// @nodoc
class _$CountdownEventEntryCopyWithImpl<$Res>
    implements $CountdownEventEntryCopyWith<$Res> {
  _$CountdownEventEntryCopyWithImpl(this._self, this._then);

  final CountdownEventEntry _self;
  final $Res Function(CountdownEventEntry) _then;

/// Create a copy of CountdownEventEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? countdownId = null,Object? eventType = null,Object? countAfter = null,Object? elapsedSeconds = null,Object? runElapsedSeconds = null,Object? unit = null,Object? occurredAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,countdownId: null == countdownId ? _self.countdownId : countdownId // ignore: cast_nullable_to_non_nullable
as String,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as String,countAfter: null == countAfter ? _self.countAfter : countAfter // ignore: cast_nullable_to_non_nullable
as int,elapsedSeconds: null == elapsedSeconds ? _self.elapsedSeconds : elapsedSeconds // ignore: cast_nullable_to_non_nullable
as double,runElapsedSeconds: null == runElapsedSeconds ? _self.runElapsedSeconds : runElapsedSeconds // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CountdownEventEntry].
extension CountdownEventEntryPatterns on CountdownEventEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CountdownEventEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CountdownEventEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CountdownEventEntry value)  $default,){
final _that = this;
switch (_that) {
case _CountdownEventEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CountdownEventEntry value)?  $default,){
final _that = this;
switch (_that) {
case _CountdownEventEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'countdown_id')  String countdownId, @JsonKey(name: 'event_type')  String eventType, @JsonKey(name: 'count_after')  int countAfter, @JsonKey(name: 'elapsed_seconds')  double elapsedSeconds, @JsonKey(name: 'run_elapsed_seconds')  double runElapsedSeconds,  String unit, @JsonKey(name: 'occurred_at')  String occurredAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CountdownEventEntry() when $default != null:
return $default(_that.id,_that.countdownId,_that.eventType,_that.countAfter,_that.elapsedSeconds,_that.runElapsedSeconds,_that.unit,_that.occurredAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'countdown_id')  String countdownId, @JsonKey(name: 'event_type')  String eventType, @JsonKey(name: 'count_after')  int countAfter, @JsonKey(name: 'elapsed_seconds')  double elapsedSeconds, @JsonKey(name: 'run_elapsed_seconds')  double runElapsedSeconds,  String unit, @JsonKey(name: 'occurred_at')  String occurredAt)  $default,) {final _that = this;
switch (_that) {
case _CountdownEventEntry():
return $default(_that.id,_that.countdownId,_that.eventType,_that.countAfter,_that.elapsedSeconds,_that.runElapsedSeconds,_that.unit,_that.occurredAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'countdown_id')  String countdownId, @JsonKey(name: 'event_type')  String eventType, @JsonKey(name: 'count_after')  int countAfter, @JsonKey(name: 'elapsed_seconds')  double elapsedSeconds, @JsonKey(name: 'run_elapsed_seconds')  double runElapsedSeconds,  String unit, @JsonKey(name: 'occurred_at')  String occurredAt)?  $default,) {final _that = this;
switch (_that) {
case _CountdownEventEntry() when $default != null:
return $default(_that.id,_that.countdownId,_that.eventType,_that.countAfter,_that.elapsedSeconds,_that.runElapsedSeconds,_that.unit,_that.occurredAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CountdownEventEntry implements CountdownEventEntry {
  const _CountdownEventEntry({this.id = '', @JsonKey(name: 'countdown_id') this.countdownId = '', @JsonKey(name: 'event_type') this.eventType = '', @JsonKey(name: 'count_after') this.countAfter = 0, @JsonKey(name: 'elapsed_seconds') this.elapsedSeconds = 0, @JsonKey(name: 'run_elapsed_seconds') this.runElapsedSeconds = 0, this.unit = 'days', @JsonKey(name: 'occurred_at') this.occurredAt = ''});
  factory _CountdownEventEntry.fromJson(Map<String, dynamic> json) => _$CountdownEventEntryFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey(name: 'countdown_id') final  String countdownId;
@override@JsonKey(name: 'event_type') final  String eventType;
@override@JsonKey(name: 'count_after') final  int countAfter;
@override@JsonKey(name: 'elapsed_seconds') final  double elapsedSeconds;
@override@JsonKey(name: 'run_elapsed_seconds') final  double runElapsedSeconds;
@override@JsonKey() final  String unit;
@override@JsonKey(name: 'occurred_at') final  String occurredAt;

/// Create a copy of CountdownEventEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CountdownEventEntryCopyWith<_CountdownEventEntry> get copyWith => __$CountdownEventEntryCopyWithImpl<_CountdownEventEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CountdownEventEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CountdownEventEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.countdownId, countdownId) || other.countdownId == countdownId)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.countAfter, countAfter) || other.countAfter == countAfter)&&(identical(other.elapsedSeconds, elapsedSeconds) || other.elapsedSeconds == elapsedSeconds)&&(identical(other.runElapsedSeconds, runElapsedSeconds) || other.runElapsedSeconds == runElapsedSeconds)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,countdownId,eventType,countAfter,elapsedSeconds,runElapsedSeconds,unit,occurredAt);

@override
String toString() {
  return 'CountdownEventEntry(id: $id, countdownId: $countdownId, eventType: $eventType, countAfter: $countAfter, elapsedSeconds: $elapsedSeconds, runElapsedSeconds: $runElapsedSeconds, unit: $unit, occurredAt: $occurredAt)';
}


}

/// @nodoc
abstract mixin class _$CountdownEventEntryCopyWith<$Res> implements $CountdownEventEntryCopyWith<$Res> {
  factory _$CountdownEventEntryCopyWith(_CountdownEventEntry value, $Res Function(_CountdownEventEntry) _then) = __$CountdownEventEntryCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'countdown_id') String countdownId,@JsonKey(name: 'event_type') String eventType,@JsonKey(name: 'count_after') int countAfter,@JsonKey(name: 'elapsed_seconds') double elapsedSeconds,@JsonKey(name: 'run_elapsed_seconds') double runElapsedSeconds, String unit,@JsonKey(name: 'occurred_at') String occurredAt
});




}
/// @nodoc
class __$CountdownEventEntryCopyWithImpl<$Res>
    implements _$CountdownEventEntryCopyWith<$Res> {
  __$CountdownEventEntryCopyWithImpl(this._self, this._then);

  final _CountdownEventEntry _self;
  final $Res Function(_CountdownEventEntry) _then;

/// Create a copy of CountdownEventEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? countdownId = null,Object? eventType = null,Object? countAfter = null,Object? elapsedSeconds = null,Object? runElapsedSeconds = null,Object? unit = null,Object? occurredAt = null,}) {
  return _then(_CountdownEventEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,countdownId: null == countdownId ? _self.countdownId : countdownId // ignore: cast_nullable_to_non_nullable
as String,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as String,countAfter: null == countAfter ? _self.countAfter : countAfter // ignore: cast_nullable_to_non_nullable
as int,elapsedSeconds: null == elapsedSeconds ? _self.elapsedSeconds : elapsedSeconds // ignore: cast_nullable_to_non_nullable
as double,runElapsedSeconds: null == runElapsedSeconds ? _self.runElapsedSeconds : runElapsedSeconds // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CadenceSummary {

@JsonKey(name: 'median_gap_seconds') double? get medianGapSeconds;@JsonKey(name: 'on_time_checkins') int get onTimeCheckins;@JsonKey(name: 'late_checkins') int get lateCheckins;
/// Create a copy of CadenceSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CadenceSummaryCopyWith<CadenceSummary> get copyWith => _$CadenceSummaryCopyWithImpl<CadenceSummary>(this as CadenceSummary, _$identity);

  /// Serializes this CadenceSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CadenceSummary&&(identical(other.medianGapSeconds, medianGapSeconds) || other.medianGapSeconds == medianGapSeconds)&&(identical(other.onTimeCheckins, onTimeCheckins) || other.onTimeCheckins == onTimeCheckins)&&(identical(other.lateCheckins, lateCheckins) || other.lateCheckins == lateCheckins));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,medianGapSeconds,onTimeCheckins,lateCheckins);

@override
String toString() {
  return 'CadenceSummary(medianGapSeconds: $medianGapSeconds, onTimeCheckins: $onTimeCheckins, lateCheckins: $lateCheckins)';
}


}

/// @nodoc
abstract mixin class $CadenceSummaryCopyWith<$Res>  {
  factory $CadenceSummaryCopyWith(CadenceSummary value, $Res Function(CadenceSummary) _then) = _$CadenceSummaryCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'median_gap_seconds') double? medianGapSeconds,@JsonKey(name: 'on_time_checkins') int onTimeCheckins,@JsonKey(name: 'late_checkins') int lateCheckins
});




}
/// @nodoc
class _$CadenceSummaryCopyWithImpl<$Res>
    implements $CadenceSummaryCopyWith<$Res> {
  _$CadenceSummaryCopyWithImpl(this._self, this._then);

  final CadenceSummary _self;
  final $Res Function(CadenceSummary) _then;

/// Create a copy of CadenceSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? medianGapSeconds = freezed,Object? onTimeCheckins = null,Object? lateCheckins = null,}) {
  return _then(_self.copyWith(
medianGapSeconds: freezed == medianGapSeconds ? _self.medianGapSeconds : medianGapSeconds // ignore: cast_nullable_to_non_nullable
as double?,onTimeCheckins: null == onTimeCheckins ? _self.onTimeCheckins : onTimeCheckins // ignore: cast_nullable_to_non_nullable
as int,lateCheckins: null == lateCheckins ? _self.lateCheckins : lateCheckins // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CadenceSummary].
extension CadenceSummaryPatterns on CadenceSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CadenceSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CadenceSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CadenceSummary value)  $default,){
final _that = this;
switch (_that) {
case _CadenceSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CadenceSummary value)?  $default,){
final _that = this;
switch (_that) {
case _CadenceSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'median_gap_seconds')  double? medianGapSeconds, @JsonKey(name: 'on_time_checkins')  int onTimeCheckins, @JsonKey(name: 'late_checkins')  int lateCheckins)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CadenceSummary() when $default != null:
return $default(_that.medianGapSeconds,_that.onTimeCheckins,_that.lateCheckins);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'median_gap_seconds')  double? medianGapSeconds, @JsonKey(name: 'on_time_checkins')  int onTimeCheckins, @JsonKey(name: 'late_checkins')  int lateCheckins)  $default,) {final _that = this;
switch (_that) {
case _CadenceSummary():
return $default(_that.medianGapSeconds,_that.onTimeCheckins,_that.lateCheckins);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'median_gap_seconds')  double? medianGapSeconds, @JsonKey(name: 'on_time_checkins')  int onTimeCheckins, @JsonKey(name: 'late_checkins')  int lateCheckins)?  $default,) {final _that = this;
switch (_that) {
case _CadenceSummary() when $default != null:
return $default(_that.medianGapSeconds,_that.onTimeCheckins,_that.lateCheckins);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CadenceSummary implements CadenceSummary {
  const _CadenceSummary({@JsonKey(name: 'median_gap_seconds') this.medianGapSeconds, @JsonKey(name: 'on_time_checkins') this.onTimeCheckins = 0, @JsonKey(name: 'late_checkins') this.lateCheckins = 0});
  factory _CadenceSummary.fromJson(Map<String, dynamic> json) => _$CadenceSummaryFromJson(json);

@override@JsonKey(name: 'median_gap_seconds') final  double? medianGapSeconds;
@override@JsonKey(name: 'on_time_checkins') final  int onTimeCheckins;
@override@JsonKey(name: 'late_checkins') final  int lateCheckins;

/// Create a copy of CadenceSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CadenceSummaryCopyWith<_CadenceSummary> get copyWith => __$CadenceSummaryCopyWithImpl<_CadenceSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CadenceSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CadenceSummary&&(identical(other.medianGapSeconds, medianGapSeconds) || other.medianGapSeconds == medianGapSeconds)&&(identical(other.onTimeCheckins, onTimeCheckins) || other.onTimeCheckins == onTimeCheckins)&&(identical(other.lateCheckins, lateCheckins) || other.lateCheckins == lateCheckins));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,medianGapSeconds,onTimeCheckins,lateCheckins);

@override
String toString() {
  return 'CadenceSummary(medianGapSeconds: $medianGapSeconds, onTimeCheckins: $onTimeCheckins, lateCheckins: $lateCheckins)';
}


}

/// @nodoc
abstract mixin class _$CadenceSummaryCopyWith<$Res> implements $CadenceSummaryCopyWith<$Res> {
  factory _$CadenceSummaryCopyWith(_CadenceSummary value, $Res Function(_CadenceSummary) _then) = __$CadenceSummaryCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'median_gap_seconds') double? medianGapSeconds,@JsonKey(name: 'on_time_checkins') int onTimeCheckins,@JsonKey(name: 'late_checkins') int lateCheckins
});




}
/// @nodoc
class __$CadenceSummaryCopyWithImpl<$Res>
    implements _$CadenceSummaryCopyWith<$Res> {
  __$CadenceSummaryCopyWithImpl(this._self, this._then);

  final _CadenceSummary _self;
  final $Res Function(_CadenceSummary) _then;

/// Create a copy of CadenceSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? medianGapSeconds = freezed,Object? onTimeCheckins = null,Object? lateCheckins = null,}) {
  return _then(_CadenceSummary(
medianGapSeconds: freezed == medianGapSeconds ? _self.medianGapSeconds : medianGapSeconds // ignore: cast_nullable_to_non_nullable
as double?,onTimeCheckins: null == onTimeCheckins ? _self.onTimeCheckins : onTimeCheckins // ignore: cast_nullable_to_non_nullable
as int,lateCheckins: null == lateCheckins ? _self.lateCheckins : lateCheckins // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$CountdownSummary {

 int get count;@JsonKey(name: 'active_count') int get activeCount;@JsonKey(name: 'total_checkins') int get totalCheckins;@JsonKey(name: 'total_resets') int get totalResets;@JsonKey(name: 'total_completions') int get totalCompletions;@JsonKey(name: 'current_streak_units') double get currentStreakUnits;@JsonKey(name: 'longest_streak_units') double get longestStreakUnits;@JsonKey(name: 'total_streak_days') double get totalStreakDays;@JsonKey(name: 'by_countdown') List<CountdownEntry> get byCountdown;@JsonKey(name: 'recent_events') List<CountdownEventEntry> get recentEvents;@JsonKey(name: 'cadence') CadenceSummary get cadence;
/// Create a copy of CountdownSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CountdownSummaryCopyWith<CountdownSummary> get copyWith => _$CountdownSummaryCopyWithImpl<CountdownSummary>(this as CountdownSummary, _$identity);

  /// Serializes this CountdownSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CountdownSummary&&(identical(other.count, count) || other.count == count)&&(identical(other.activeCount, activeCount) || other.activeCount == activeCount)&&(identical(other.totalCheckins, totalCheckins) || other.totalCheckins == totalCheckins)&&(identical(other.totalResets, totalResets) || other.totalResets == totalResets)&&(identical(other.totalCompletions, totalCompletions) || other.totalCompletions == totalCompletions)&&(identical(other.currentStreakUnits, currentStreakUnits) || other.currentStreakUnits == currentStreakUnits)&&(identical(other.longestStreakUnits, longestStreakUnits) || other.longestStreakUnits == longestStreakUnits)&&(identical(other.totalStreakDays, totalStreakDays) || other.totalStreakDays == totalStreakDays)&&const DeepCollectionEquality().equals(other.byCountdown, byCountdown)&&const DeepCollectionEquality().equals(other.recentEvents, recentEvents)&&(identical(other.cadence, cadence) || other.cadence == cadence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,count,activeCount,totalCheckins,totalResets,totalCompletions,currentStreakUnits,longestStreakUnits,totalStreakDays,const DeepCollectionEquality().hash(byCountdown),const DeepCollectionEquality().hash(recentEvents),cadence);

@override
String toString() {
  return 'CountdownSummary(count: $count, activeCount: $activeCount, totalCheckins: $totalCheckins, totalResets: $totalResets, totalCompletions: $totalCompletions, currentStreakUnits: $currentStreakUnits, longestStreakUnits: $longestStreakUnits, totalStreakDays: $totalStreakDays, byCountdown: $byCountdown, recentEvents: $recentEvents, cadence: $cadence)';
}


}

/// @nodoc
abstract mixin class $CountdownSummaryCopyWith<$Res>  {
  factory $CountdownSummaryCopyWith(CountdownSummary value, $Res Function(CountdownSummary) _then) = _$CountdownSummaryCopyWithImpl;
@useResult
$Res call({
 int count,@JsonKey(name: 'active_count') int activeCount,@JsonKey(name: 'total_checkins') int totalCheckins,@JsonKey(name: 'total_resets') int totalResets,@JsonKey(name: 'total_completions') int totalCompletions,@JsonKey(name: 'current_streak_units') double currentStreakUnits,@JsonKey(name: 'longest_streak_units') double longestStreakUnits,@JsonKey(name: 'total_streak_days') double totalStreakDays,@JsonKey(name: 'by_countdown') List<CountdownEntry> byCountdown,@JsonKey(name: 'recent_events') List<CountdownEventEntry> recentEvents,@JsonKey(name: 'cadence') CadenceSummary cadence
});


$CadenceSummaryCopyWith<$Res> get cadence;

}
/// @nodoc
class _$CountdownSummaryCopyWithImpl<$Res>
    implements $CountdownSummaryCopyWith<$Res> {
  _$CountdownSummaryCopyWithImpl(this._self, this._then);

  final CountdownSummary _self;
  final $Res Function(CountdownSummary) _then;

/// Create a copy of CountdownSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? count = null,Object? activeCount = null,Object? totalCheckins = null,Object? totalResets = null,Object? totalCompletions = null,Object? currentStreakUnits = null,Object? longestStreakUnits = null,Object? totalStreakDays = null,Object? byCountdown = null,Object? recentEvents = null,Object? cadence = null,}) {
  return _then(_self.copyWith(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,activeCount: null == activeCount ? _self.activeCount : activeCount // ignore: cast_nullable_to_non_nullable
as int,totalCheckins: null == totalCheckins ? _self.totalCheckins : totalCheckins // ignore: cast_nullable_to_non_nullable
as int,totalResets: null == totalResets ? _self.totalResets : totalResets // ignore: cast_nullable_to_non_nullable
as int,totalCompletions: null == totalCompletions ? _self.totalCompletions : totalCompletions // ignore: cast_nullable_to_non_nullable
as int,currentStreakUnits: null == currentStreakUnits ? _self.currentStreakUnits : currentStreakUnits // ignore: cast_nullable_to_non_nullable
as double,longestStreakUnits: null == longestStreakUnits ? _self.longestStreakUnits : longestStreakUnits // ignore: cast_nullable_to_non_nullable
as double,totalStreakDays: null == totalStreakDays ? _self.totalStreakDays : totalStreakDays // ignore: cast_nullable_to_non_nullable
as double,byCountdown: null == byCountdown ? _self.byCountdown : byCountdown // ignore: cast_nullable_to_non_nullable
as List<CountdownEntry>,recentEvents: null == recentEvents ? _self.recentEvents : recentEvents // ignore: cast_nullable_to_non_nullable
as List<CountdownEventEntry>,cadence: null == cadence ? _self.cadence : cadence // ignore: cast_nullable_to_non_nullable
as CadenceSummary,
  ));
}
/// Create a copy of CountdownSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CadenceSummaryCopyWith<$Res> get cadence {
  
  return $CadenceSummaryCopyWith<$Res>(_self.cadence, (value) {
    return _then(_self.copyWith(cadence: value));
  });
}
}


/// Adds pattern-matching-related methods to [CountdownSummary].
extension CountdownSummaryPatterns on CountdownSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CountdownSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CountdownSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CountdownSummary value)  $default,){
final _that = this;
switch (_that) {
case _CountdownSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CountdownSummary value)?  $default,){
final _that = this;
switch (_that) {
case _CountdownSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int count, @JsonKey(name: 'active_count')  int activeCount, @JsonKey(name: 'total_checkins')  int totalCheckins, @JsonKey(name: 'total_resets')  int totalResets, @JsonKey(name: 'total_completions')  int totalCompletions, @JsonKey(name: 'current_streak_units')  double currentStreakUnits, @JsonKey(name: 'longest_streak_units')  double longestStreakUnits, @JsonKey(name: 'total_streak_days')  double totalStreakDays, @JsonKey(name: 'by_countdown')  List<CountdownEntry> byCountdown, @JsonKey(name: 'recent_events')  List<CountdownEventEntry> recentEvents, @JsonKey(name: 'cadence')  CadenceSummary cadence)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CountdownSummary() when $default != null:
return $default(_that.count,_that.activeCount,_that.totalCheckins,_that.totalResets,_that.totalCompletions,_that.currentStreakUnits,_that.longestStreakUnits,_that.totalStreakDays,_that.byCountdown,_that.recentEvents,_that.cadence);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int count, @JsonKey(name: 'active_count')  int activeCount, @JsonKey(name: 'total_checkins')  int totalCheckins, @JsonKey(name: 'total_resets')  int totalResets, @JsonKey(name: 'total_completions')  int totalCompletions, @JsonKey(name: 'current_streak_units')  double currentStreakUnits, @JsonKey(name: 'longest_streak_units')  double longestStreakUnits, @JsonKey(name: 'total_streak_days')  double totalStreakDays, @JsonKey(name: 'by_countdown')  List<CountdownEntry> byCountdown, @JsonKey(name: 'recent_events')  List<CountdownEventEntry> recentEvents, @JsonKey(name: 'cadence')  CadenceSummary cadence)  $default,) {final _that = this;
switch (_that) {
case _CountdownSummary():
return $default(_that.count,_that.activeCount,_that.totalCheckins,_that.totalResets,_that.totalCompletions,_that.currentStreakUnits,_that.longestStreakUnits,_that.totalStreakDays,_that.byCountdown,_that.recentEvents,_that.cadence);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int count, @JsonKey(name: 'active_count')  int activeCount, @JsonKey(name: 'total_checkins')  int totalCheckins, @JsonKey(name: 'total_resets')  int totalResets, @JsonKey(name: 'total_completions')  int totalCompletions, @JsonKey(name: 'current_streak_units')  double currentStreakUnits, @JsonKey(name: 'longest_streak_units')  double longestStreakUnits, @JsonKey(name: 'total_streak_days')  double totalStreakDays, @JsonKey(name: 'by_countdown')  List<CountdownEntry> byCountdown, @JsonKey(name: 'recent_events')  List<CountdownEventEntry> recentEvents, @JsonKey(name: 'cadence')  CadenceSummary cadence)?  $default,) {final _that = this;
switch (_that) {
case _CountdownSummary() when $default != null:
return $default(_that.count,_that.activeCount,_that.totalCheckins,_that.totalResets,_that.totalCompletions,_that.currentStreakUnits,_that.longestStreakUnits,_that.totalStreakDays,_that.byCountdown,_that.recentEvents,_that.cadence);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CountdownSummary implements CountdownSummary {
  const _CountdownSummary({this.count = 0, @JsonKey(name: 'active_count') this.activeCount = 0, @JsonKey(name: 'total_checkins') this.totalCheckins = 0, @JsonKey(name: 'total_resets') this.totalResets = 0, @JsonKey(name: 'total_completions') this.totalCompletions = 0, @JsonKey(name: 'current_streak_units') this.currentStreakUnits = 0, @JsonKey(name: 'longest_streak_units') this.longestStreakUnits = 0, @JsonKey(name: 'total_streak_days') this.totalStreakDays = 0, @JsonKey(name: 'by_countdown') final  List<CountdownEntry> byCountdown = const <CountdownEntry>[], @JsonKey(name: 'recent_events') final  List<CountdownEventEntry> recentEvents = const <CountdownEventEntry>[], @JsonKey(name: 'cadence') this.cadence = const CadenceSummary()}): _byCountdown = byCountdown,_recentEvents = recentEvents;
  factory _CountdownSummary.fromJson(Map<String, dynamic> json) => _$CountdownSummaryFromJson(json);

@override@JsonKey() final  int count;
@override@JsonKey(name: 'active_count') final  int activeCount;
@override@JsonKey(name: 'total_checkins') final  int totalCheckins;
@override@JsonKey(name: 'total_resets') final  int totalResets;
@override@JsonKey(name: 'total_completions') final  int totalCompletions;
@override@JsonKey(name: 'current_streak_units') final  double currentStreakUnits;
@override@JsonKey(name: 'longest_streak_units') final  double longestStreakUnits;
@override@JsonKey(name: 'total_streak_days') final  double totalStreakDays;
 final  List<CountdownEntry> _byCountdown;
@override@JsonKey(name: 'by_countdown') List<CountdownEntry> get byCountdown {
  if (_byCountdown is EqualUnmodifiableListView) return _byCountdown;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_byCountdown);
}

 final  List<CountdownEventEntry> _recentEvents;
@override@JsonKey(name: 'recent_events') List<CountdownEventEntry> get recentEvents {
  if (_recentEvents is EqualUnmodifiableListView) return _recentEvents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentEvents);
}

@override@JsonKey(name: 'cadence') final  CadenceSummary cadence;

/// Create a copy of CountdownSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CountdownSummaryCopyWith<_CountdownSummary> get copyWith => __$CountdownSummaryCopyWithImpl<_CountdownSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CountdownSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CountdownSummary&&(identical(other.count, count) || other.count == count)&&(identical(other.activeCount, activeCount) || other.activeCount == activeCount)&&(identical(other.totalCheckins, totalCheckins) || other.totalCheckins == totalCheckins)&&(identical(other.totalResets, totalResets) || other.totalResets == totalResets)&&(identical(other.totalCompletions, totalCompletions) || other.totalCompletions == totalCompletions)&&(identical(other.currentStreakUnits, currentStreakUnits) || other.currentStreakUnits == currentStreakUnits)&&(identical(other.longestStreakUnits, longestStreakUnits) || other.longestStreakUnits == longestStreakUnits)&&(identical(other.totalStreakDays, totalStreakDays) || other.totalStreakDays == totalStreakDays)&&const DeepCollectionEquality().equals(other._byCountdown, _byCountdown)&&const DeepCollectionEquality().equals(other._recentEvents, _recentEvents)&&(identical(other.cadence, cadence) || other.cadence == cadence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,count,activeCount,totalCheckins,totalResets,totalCompletions,currentStreakUnits,longestStreakUnits,totalStreakDays,const DeepCollectionEquality().hash(_byCountdown),const DeepCollectionEquality().hash(_recentEvents),cadence);

@override
String toString() {
  return 'CountdownSummary(count: $count, activeCount: $activeCount, totalCheckins: $totalCheckins, totalResets: $totalResets, totalCompletions: $totalCompletions, currentStreakUnits: $currentStreakUnits, longestStreakUnits: $longestStreakUnits, totalStreakDays: $totalStreakDays, byCountdown: $byCountdown, recentEvents: $recentEvents, cadence: $cadence)';
}


}

/// @nodoc
abstract mixin class _$CountdownSummaryCopyWith<$Res> implements $CountdownSummaryCopyWith<$Res> {
  factory _$CountdownSummaryCopyWith(_CountdownSummary value, $Res Function(_CountdownSummary) _then) = __$CountdownSummaryCopyWithImpl;
@override @useResult
$Res call({
 int count,@JsonKey(name: 'active_count') int activeCount,@JsonKey(name: 'total_checkins') int totalCheckins,@JsonKey(name: 'total_resets') int totalResets,@JsonKey(name: 'total_completions') int totalCompletions,@JsonKey(name: 'current_streak_units') double currentStreakUnits,@JsonKey(name: 'longest_streak_units') double longestStreakUnits,@JsonKey(name: 'total_streak_days') double totalStreakDays,@JsonKey(name: 'by_countdown') List<CountdownEntry> byCountdown,@JsonKey(name: 'recent_events') List<CountdownEventEntry> recentEvents,@JsonKey(name: 'cadence') CadenceSummary cadence
});


@override $CadenceSummaryCopyWith<$Res> get cadence;

}
/// @nodoc
class __$CountdownSummaryCopyWithImpl<$Res>
    implements _$CountdownSummaryCopyWith<$Res> {
  __$CountdownSummaryCopyWithImpl(this._self, this._then);

  final _CountdownSummary _self;
  final $Res Function(_CountdownSummary) _then;

/// Create a copy of CountdownSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? count = null,Object? activeCount = null,Object? totalCheckins = null,Object? totalResets = null,Object? totalCompletions = null,Object? currentStreakUnits = null,Object? longestStreakUnits = null,Object? totalStreakDays = null,Object? byCountdown = null,Object? recentEvents = null,Object? cadence = null,}) {
  return _then(_CountdownSummary(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,activeCount: null == activeCount ? _self.activeCount : activeCount // ignore: cast_nullable_to_non_nullable
as int,totalCheckins: null == totalCheckins ? _self.totalCheckins : totalCheckins // ignore: cast_nullable_to_non_nullable
as int,totalResets: null == totalResets ? _self.totalResets : totalResets // ignore: cast_nullable_to_non_nullable
as int,totalCompletions: null == totalCompletions ? _self.totalCompletions : totalCompletions // ignore: cast_nullable_to_non_nullable
as int,currentStreakUnits: null == currentStreakUnits ? _self.currentStreakUnits : currentStreakUnits // ignore: cast_nullable_to_non_nullable
as double,longestStreakUnits: null == longestStreakUnits ? _self.longestStreakUnits : longestStreakUnits // ignore: cast_nullable_to_non_nullable
as double,totalStreakDays: null == totalStreakDays ? _self.totalStreakDays : totalStreakDays // ignore: cast_nullable_to_non_nullable
as double,byCountdown: null == byCountdown ? _self._byCountdown : byCountdown // ignore: cast_nullable_to_non_nullable
as List<CountdownEntry>,recentEvents: null == recentEvents ? _self._recentEvents : recentEvents // ignore: cast_nullable_to_non_nullable
as List<CountdownEventEntry>,cadence: null == cadence ? _self.cadence : cadence // ignore: cast_nullable_to_non_nullable
as CadenceSummary,
  ));
}

/// Create a copy of CountdownSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CadenceSummaryCopyWith<$Res> get cadence {
  
  return $CadenceSummaryCopyWith<$Res>(_self.cadence, (value) {
    return _then(_self.copyWith(cadence: value));
  });
}
}


/// @nodoc
mixin _$RoutineCategoryCount {

 String get category; String get label; int get count;
/// Create a copy of RoutineCategoryCount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoutineCategoryCountCopyWith<RoutineCategoryCount> get copyWith => _$RoutineCategoryCountCopyWithImpl<RoutineCategoryCount>(this as RoutineCategoryCount, _$identity);

  /// Serializes this RoutineCategoryCount to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoutineCategoryCount&&(identical(other.category, category) || other.category == category)&&(identical(other.label, label) || other.label == label)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,category,label,count);

@override
String toString() {
  return 'RoutineCategoryCount(category: $category, label: $label, count: $count)';
}


}

/// @nodoc
abstract mixin class $RoutineCategoryCountCopyWith<$Res>  {
  factory $RoutineCategoryCountCopyWith(RoutineCategoryCount value, $Res Function(RoutineCategoryCount) _then) = _$RoutineCategoryCountCopyWithImpl;
@useResult
$Res call({
 String category, String label, int count
});




}
/// @nodoc
class _$RoutineCategoryCountCopyWithImpl<$Res>
    implements $RoutineCategoryCountCopyWith<$Res> {
  _$RoutineCategoryCountCopyWithImpl(this._self, this._then);

  final RoutineCategoryCount _self;
  final $Res Function(RoutineCategoryCount) _then;

/// Create a copy of RoutineCategoryCount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? category = null,Object? label = null,Object? count = null,}) {
  return _then(_self.copyWith(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RoutineCategoryCount].
extension RoutineCategoryCountPatterns on RoutineCategoryCount {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoutineCategoryCount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoutineCategoryCount() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoutineCategoryCount value)  $default,){
final _that = this;
switch (_that) {
case _RoutineCategoryCount():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoutineCategoryCount value)?  $default,){
final _that = this;
switch (_that) {
case _RoutineCategoryCount() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String category,  String label,  int count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoutineCategoryCount() when $default != null:
return $default(_that.category,_that.label,_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String category,  String label,  int count)  $default,) {final _that = this;
switch (_that) {
case _RoutineCategoryCount():
return $default(_that.category,_that.label,_that.count);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String category,  String label,  int count)?  $default,) {final _that = this;
switch (_that) {
case _RoutineCategoryCount() when $default != null:
return $default(_that.category,_that.label,_that.count);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RoutineCategoryCount implements RoutineCategoryCount {
  const _RoutineCategoryCount({this.category = '', this.label = '', this.count = 0});
  factory _RoutineCategoryCount.fromJson(Map<String, dynamic> json) => _$RoutineCategoryCountFromJson(json);

@override@JsonKey() final  String category;
@override@JsonKey() final  String label;
@override@JsonKey() final  int count;

/// Create a copy of RoutineCategoryCount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoutineCategoryCountCopyWith<_RoutineCategoryCount> get copyWith => __$RoutineCategoryCountCopyWithImpl<_RoutineCategoryCount>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoutineCategoryCountToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoutineCategoryCount&&(identical(other.category, category) || other.category == category)&&(identical(other.label, label) || other.label == label)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,category,label,count);

@override
String toString() {
  return 'RoutineCategoryCount(category: $category, label: $label, count: $count)';
}


}

/// @nodoc
abstract mixin class _$RoutineCategoryCountCopyWith<$Res> implements $RoutineCategoryCountCopyWith<$Res> {
  factory _$RoutineCategoryCountCopyWith(_RoutineCategoryCount value, $Res Function(_RoutineCategoryCount) _then) = __$RoutineCategoryCountCopyWithImpl;
@override @useResult
$Res call({
 String category, String label, int count
});




}
/// @nodoc
class __$RoutineCategoryCountCopyWithImpl<$Res>
    implements _$RoutineCategoryCountCopyWith<$Res> {
  __$RoutineCategoryCountCopyWithImpl(this._self, this._then);

  final _RoutineCategoryCount _self;
  final $Res Function(_RoutineCategoryCount) _then;

/// Create a copy of RoutineCategoryCount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? category = null,Object? label = null,Object? count = null,}) {
  return _then(_RoutineCategoryCount(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$RoutineTrackingCount {

 String get tracking; int get count;
/// Create a copy of RoutineTrackingCount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoutineTrackingCountCopyWith<RoutineTrackingCount> get copyWith => _$RoutineTrackingCountCopyWithImpl<RoutineTrackingCount>(this as RoutineTrackingCount, _$identity);

  /// Serializes this RoutineTrackingCount to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoutineTrackingCount&&(identical(other.tracking, tracking) || other.tracking == tracking)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tracking,count);

@override
String toString() {
  return 'RoutineTrackingCount(tracking: $tracking, count: $count)';
}


}

/// @nodoc
abstract mixin class $RoutineTrackingCountCopyWith<$Res>  {
  factory $RoutineTrackingCountCopyWith(RoutineTrackingCount value, $Res Function(RoutineTrackingCount) _then) = _$RoutineTrackingCountCopyWithImpl;
@useResult
$Res call({
 String tracking, int count
});




}
/// @nodoc
class _$RoutineTrackingCountCopyWithImpl<$Res>
    implements $RoutineTrackingCountCopyWith<$Res> {
  _$RoutineTrackingCountCopyWithImpl(this._self, this._then);

  final RoutineTrackingCount _self;
  final $Res Function(RoutineTrackingCount) _then;

/// Create a copy of RoutineTrackingCount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tracking = null,Object? count = null,}) {
  return _then(_self.copyWith(
tracking: null == tracking ? _self.tracking : tracking // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RoutineTrackingCount].
extension RoutineTrackingCountPatterns on RoutineTrackingCount {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoutineTrackingCount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoutineTrackingCount() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoutineTrackingCount value)  $default,){
final _that = this;
switch (_that) {
case _RoutineTrackingCount():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoutineTrackingCount value)?  $default,){
final _that = this;
switch (_that) {
case _RoutineTrackingCount() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String tracking,  int count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoutineTrackingCount() when $default != null:
return $default(_that.tracking,_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String tracking,  int count)  $default,) {final _that = this;
switch (_that) {
case _RoutineTrackingCount():
return $default(_that.tracking,_that.count);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String tracking,  int count)?  $default,) {final _that = this;
switch (_that) {
case _RoutineTrackingCount() when $default != null:
return $default(_that.tracking,_that.count);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RoutineTrackingCount implements RoutineTrackingCount {
  const _RoutineTrackingCount({this.tracking = '', this.count = 0});
  factory _RoutineTrackingCount.fromJson(Map<String, dynamic> json) => _$RoutineTrackingCountFromJson(json);

@override@JsonKey() final  String tracking;
@override@JsonKey() final  int count;

/// Create a copy of RoutineTrackingCount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoutineTrackingCountCopyWith<_RoutineTrackingCount> get copyWith => __$RoutineTrackingCountCopyWithImpl<_RoutineTrackingCount>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoutineTrackingCountToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoutineTrackingCount&&(identical(other.tracking, tracking) || other.tracking == tracking)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tracking,count);

@override
String toString() {
  return 'RoutineTrackingCount(tracking: $tracking, count: $count)';
}


}

/// @nodoc
abstract mixin class _$RoutineTrackingCountCopyWith<$Res> implements $RoutineTrackingCountCopyWith<$Res> {
  factory _$RoutineTrackingCountCopyWith(_RoutineTrackingCount value, $Res Function(_RoutineTrackingCount) _then) = __$RoutineTrackingCountCopyWithImpl;
@override @useResult
$Res call({
 String tracking, int count
});




}
/// @nodoc
class __$RoutineTrackingCountCopyWithImpl<$Res>
    implements _$RoutineTrackingCountCopyWith<$Res> {
  __$RoutineTrackingCountCopyWithImpl(this._self, this._then);

  final _RoutineTrackingCount _self;
  final $Res Function(_RoutineTrackingCount) _then;

/// Create a copy of RoutineTrackingCount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tracking = null,Object? count = null,}) {
  return _then(_RoutineTrackingCount(
tracking: null == tracking ? _self.tracking : tracking // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$RoutinesSummary {

@JsonKey(name: 'active_routines') int get activeRoutines;@JsonKey(name: 'total_checkins') int get totalCheckins;@JsonKey(name: 'by_category') List<RoutineCategoryCount> get byCategory;@JsonKey(name: 'by_tracking') List<RoutineTrackingCount> get byTracking;
/// Create a copy of RoutinesSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoutinesSummaryCopyWith<RoutinesSummary> get copyWith => _$RoutinesSummaryCopyWithImpl<RoutinesSummary>(this as RoutinesSummary, _$identity);

  /// Serializes this RoutinesSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoutinesSummary&&(identical(other.activeRoutines, activeRoutines) || other.activeRoutines == activeRoutines)&&(identical(other.totalCheckins, totalCheckins) || other.totalCheckins == totalCheckins)&&const DeepCollectionEquality().equals(other.byCategory, byCategory)&&const DeepCollectionEquality().equals(other.byTracking, byTracking));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,activeRoutines,totalCheckins,const DeepCollectionEquality().hash(byCategory),const DeepCollectionEquality().hash(byTracking));

@override
String toString() {
  return 'RoutinesSummary(activeRoutines: $activeRoutines, totalCheckins: $totalCheckins, byCategory: $byCategory, byTracking: $byTracking)';
}


}

/// @nodoc
abstract mixin class $RoutinesSummaryCopyWith<$Res>  {
  factory $RoutinesSummaryCopyWith(RoutinesSummary value, $Res Function(RoutinesSummary) _then) = _$RoutinesSummaryCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'active_routines') int activeRoutines,@JsonKey(name: 'total_checkins') int totalCheckins,@JsonKey(name: 'by_category') List<RoutineCategoryCount> byCategory,@JsonKey(name: 'by_tracking') List<RoutineTrackingCount> byTracking
});




}
/// @nodoc
class _$RoutinesSummaryCopyWithImpl<$Res>
    implements $RoutinesSummaryCopyWith<$Res> {
  _$RoutinesSummaryCopyWithImpl(this._self, this._then);

  final RoutinesSummary _self;
  final $Res Function(RoutinesSummary) _then;

/// Create a copy of RoutinesSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? activeRoutines = null,Object? totalCheckins = null,Object? byCategory = null,Object? byTracking = null,}) {
  return _then(_self.copyWith(
activeRoutines: null == activeRoutines ? _self.activeRoutines : activeRoutines // ignore: cast_nullable_to_non_nullable
as int,totalCheckins: null == totalCheckins ? _self.totalCheckins : totalCheckins // ignore: cast_nullable_to_non_nullable
as int,byCategory: null == byCategory ? _self.byCategory : byCategory // ignore: cast_nullable_to_non_nullable
as List<RoutineCategoryCount>,byTracking: null == byTracking ? _self.byTracking : byTracking // ignore: cast_nullable_to_non_nullable
as List<RoutineTrackingCount>,
  ));
}

}


/// Adds pattern-matching-related methods to [RoutinesSummary].
extension RoutinesSummaryPatterns on RoutinesSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoutinesSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoutinesSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoutinesSummary value)  $default,){
final _that = this;
switch (_that) {
case _RoutinesSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoutinesSummary value)?  $default,){
final _that = this;
switch (_that) {
case _RoutinesSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'active_routines')  int activeRoutines, @JsonKey(name: 'total_checkins')  int totalCheckins, @JsonKey(name: 'by_category')  List<RoutineCategoryCount> byCategory, @JsonKey(name: 'by_tracking')  List<RoutineTrackingCount> byTracking)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoutinesSummary() when $default != null:
return $default(_that.activeRoutines,_that.totalCheckins,_that.byCategory,_that.byTracking);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'active_routines')  int activeRoutines, @JsonKey(name: 'total_checkins')  int totalCheckins, @JsonKey(name: 'by_category')  List<RoutineCategoryCount> byCategory, @JsonKey(name: 'by_tracking')  List<RoutineTrackingCount> byTracking)  $default,) {final _that = this;
switch (_that) {
case _RoutinesSummary():
return $default(_that.activeRoutines,_that.totalCheckins,_that.byCategory,_that.byTracking);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'active_routines')  int activeRoutines, @JsonKey(name: 'total_checkins')  int totalCheckins, @JsonKey(name: 'by_category')  List<RoutineCategoryCount> byCategory, @JsonKey(name: 'by_tracking')  List<RoutineTrackingCount> byTracking)?  $default,) {final _that = this;
switch (_that) {
case _RoutinesSummary() when $default != null:
return $default(_that.activeRoutines,_that.totalCheckins,_that.byCategory,_that.byTracking);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RoutinesSummary implements RoutinesSummary {
  const _RoutinesSummary({@JsonKey(name: 'active_routines') this.activeRoutines = 0, @JsonKey(name: 'total_checkins') this.totalCheckins = 0, @JsonKey(name: 'by_category') final  List<RoutineCategoryCount> byCategory = const <RoutineCategoryCount>[], @JsonKey(name: 'by_tracking') final  List<RoutineTrackingCount> byTracking = const <RoutineTrackingCount>[]}): _byCategory = byCategory,_byTracking = byTracking;
  factory _RoutinesSummary.fromJson(Map<String, dynamic> json) => _$RoutinesSummaryFromJson(json);

@override@JsonKey(name: 'active_routines') final  int activeRoutines;
@override@JsonKey(name: 'total_checkins') final  int totalCheckins;
 final  List<RoutineCategoryCount> _byCategory;
@override@JsonKey(name: 'by_category') List<RoutineCategoryCount> get byCategory {
  if (_byCategory is EqualUnmodifiableListView) return _byCategory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_byCategory);
}

 final  List<RoutineTrackingCount> _byTracking;
@override@JsonKey(name: 'by_tracking') List<RoutineTrackingCount> get byTracking {
  if (_byTracking is EqualUnmodifiableListView) return _byTracking;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_byTracking);
}


/// Create a copy of RoutinesSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoutinesSummaryCopyWith<_RoutinesSummary> get copyWith => __$RoutinesSummaryCopyWithImpl<_RoutinesSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoutinesSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoutinesSummary&&(identical(other.activeRoutines, activeRoutines) || other.activeRoutines == activeRoutines)&&(identical(other.totalCheckins, totalCheckins) || other.totalCheckins == totalCheckins)&&const DeepCollectionEquality().equals(other._byCategory, _byCategory)&&const DeepCollectionEquality().equals(other._byTracking, _byTracking));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,activeRoutines,totalCheckins,const DeepCollectionEquality().hash(_byCategory),const DeepCollectionEquality().hash(_byTracking));

@override
String toString() {
  return 'RoutinesSummary(activeRoutines: $activeRoutines, totalCheckins: $totalCheckins, byCategory: $byCategory, byTracking: $byTracking)';
}


}

/// @nodoc
abstract mixin class _$RoutinesSummaryCopyWith<$Res> implements $RoutinesSummaryCopyWith<$Res> {
  factory _$RoutinesSummaryCopyWith(_RoutinesSummary value, $Res Function(_RoutinesSummary) _then) = __$RoutinesSummaryCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'active_routines') int activeRoutines,@JsonKey(name: 'total_checkins') int totalCheckins,@JsonKey(name: 'by_category') List<RoutineCategoryCount> byCategory,@JsonKey(name: 'by_tracking') List<RoutineTrackingCount> byTracking
});




}
/// @nodoc
class __$RoutinesSummaryCopyWithImpl<$Res>
    implements _$RoutinesSummaryCopyWith<$Res> {
  __$RoutinesSummaryCopyWithImpl(this._self, this._then);

  final _RoutinesSummary _self;
  final $Res Function(_RoutinesSummary) _then;

/// Create a copy of RoutinesSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? activeRoutines = null,Object? totalCheckins = null,Object? byCategory = null,Object? byTracking = null,}) {
  return _then(_RoutinesSummary(
activeRoutines: null == activeRoutines ? _self.activeRoutines : activeRoutines // ignore: cast_nullable_to_non_nullable
as int,totalCheckins: null == totalCheckins ? _self.totalCheckins : totalCheckins // ignore: cast_nullable_to_non_nullable
as int,byCategory: null == byCategory ? _self._byCategory : byCategory // ignore: cast_nullable_to_non_nullable
as List<RoutineCategoryCount>,byTracking: null == byTracking ? _self._byTracking : byTracking // ignore: cast_nullable_to_non_nullable
as List<RoutineTrackingCount>,
  ));
}


}


/// @nodoc
mixin _$ProgrammesSummary {

@JsonKey(name: 'programmes_purchased') int get programmesPurchased;@JsonKey(name: 'meal_plans_purchased') int get mealPlansPurchased;@JsonKey(name: 'active_enrolments') int get activeEnrolments;@JsonKey(name: 'completed_enrolments') int get completedEnrolments;@JsonKey(name: 'avg_progress_pct') double? get avgProgressPct;
/// Create a copy of ProgrammesSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProgrammesSummaryCopyWith<ProgrammesSummary> get copyWith => _$ProgrammesSummaryCopyWithImpl<ProgrammesSummary>(this as ProgrammesSummary, _$identity);

  /// Serializes this ProgrammesSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProgrammesSummary&&(identical(other.programmesPurchased, programmesPurchased) || other.programmesPurchased == programmesPurchased)&&(identical(other.mealPlansPurchased, mealPlansPurchased) || other.mealPlansPurchased == mealPlansPurchased)&&(identical(other.activeEnrolments, activeEnrolments) || other.activeEnrolments == activeEnrolments)&&(identical(other.completedEnrolments, completedEnrolments) || other.completedEnrolments == completedEnrolments)&&(identical(other.avgProgressPct, avgProgressPct) || other.avgProgressPct == avgProgressPct));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,programmesPurchased,mealPlansPurchased,activeEnrolments,completedEnrolments,avgProgressPct);

@override
String toString() {
  return 'ProgrammesSummary(programmesPurchased: $programmesPurchased, mealPlansPurchased: $mealPlansPurchased, activeEnrolments: $activeEnrolments, completedEnrolments: $completedEnrolments, avgProgressPct: $avgProgressPct)';
}


}

/// @nodoc
abstract mixin class $ProgrammesSummaryCopyWith<$Res>  {
  factory $ProgrammesSummaryCopyWith(ProgrammesSummary value, $Res Function(ProgrammesSummary) _then) = _$ProgrammesSummaryCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'programmes_purchased') int programmesPurchased,@JsonKey(name: 'meal_plans_purchased') int mealPlansPurchased,@JsonKey(name: 'active_enrolments') int activeEnrolments,@JsonKey(name: 'completed_enrolments') int completedEnrolments,@JsonKey(name: 'avg_progress_pct') double? avgProgressPct
});




}
/// @nodoc
class _$ProgrammesSummaryCopyWithImpl<$Res>
    implements $ProgrammesSummaryCopyWith<$Res> {
  _$ProgrammesSummaryCopyWithImpl(this._self, this._then);

  final ProgrammesSummary _self;
  final $Res Function(ProgrammesSummary) _then;

/// Create a copy of ProgrammesSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? programmesPurchased = null,Object? mealPlansPurchased = null,Object? activeEnrolments = null,Object? completedEnrolments = null,Object? avgProgressPct = freezed,}) {
  return _then(_self.copyWith(
programmesPurchased: null == programmesPurchased ? _self.programmesPurchased : programmesPurchased // ignore: cast_nullable_to_non_nullable
as int,mealPlansPurchased: null == mealPlansPurchased ? _self.mealPlansPurchased : mealPlansPurchased // ignore: cast_nullable_to_non_nullable
as int,activeEnrolments: null == activeEnrolments ? _self.activeEnrolments : activeEnrolments // ignore: cast_nullable_to_non_nullable
as int,completedEnrolments: null == completedEnrolments ? _self.completedEnrolments : completedEnrolments // ignore: cast_nullable_to_non_nullable
as int,avgProgressPct: freezed == avgProgressPct ? _self.avgProgressPct : avgProgressPct // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProgrammesSummary].
extension ProgrammesSummaryPatterns on ProgrammesSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProgrammesSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProgrammesSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProgrammesSummary value)  $default,){
final _that = this;
switch (_that) {
case _ProgrammesSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProgrammesSummary value)?  $default,){
final _that = this;
switch (_that) {
case _ProgrammesSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'programmes_purchased')  int programmesPurchased, @JsonKey(name: 'meal_plans_purchased')  int mealPlansPurchased, @JsonKey(name: 'active_enrolments')  int activeEnrolments, @JsonKey(name: 'completed_enrolments')  int completedEnrolments, @JsonKey(name: 'avg_progress_pct')  double? avgProgressPct)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProgrammesSummary() when $default != null:
return $default(_that.programmesPurchased,_that.mealPlansPurchased,_that.activeEnrolments,_that.completedEnrolments,_that.avgProgressPct);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'programmes_purchased')  int programmesPurchased, @JsonKey(name: 'meal_plans_purchased')  int mealPlansPurchased, @JsonKey(name: 'active_enrolments')  int activeEnrolments, @JsonKey(name: 'completed_enrolments')  int completedEnrolments, @JsonKey(name: 'avg_progress_pct')  double? avgProgressPct)  $default,) {final _that = this;
switch (_that) {
case _ProgrammesSummary():
return $default(_that.programmesPurchased,_that.mealPlansPurchased,_that.activeEnrolments,_that.completedEnrolments,_that.avgProgressPct);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'programmes_purchased')  int programmesPurchased, @JsonKey(name: 'meal_plans_purchased')  int mealPlansPurchased, @JsonKey(name: 'active_enrolments')  int activeEnrolments, @JsonKey(name: 'completed_enrolments')  int completedEnrolments, @JsonKey(name: 'avg_progress_pct')  double? avgProgressPct)?  $default,) {final _that = this;
switch (_that) {
case _ProgrammesSummary() when $default != null:
return $default(_that.programmesPurchased,_that.mealPlansPurchased,_that.activeEnrolments,_that.completedEnrolments,_that.avgProgressPct);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProgrammesSummary implements ProgrammesSummary {
  const _ProgrammesSummary({@JsonKey(name: 'programmes_purchased') this.programmesPurchased = 0, @JsonKey(name: 'meal_plans_purchased') this.mealPlansPurchased = 0, @JsonKey(name: 'active_enrolments') this.activeEnrolments = 0, @JsonKey(name: 'completed_enrolments') this.completedEnrolments = 0, @JsonKey(name: 'avg_progress_pct') this.avgProgressPct});
  factory _ProgrammesSummary.fromJson(Map<String, dynamic> json) => _$ProgrammesSummaryFromJson(json);

@override@JsonKey(name: 'programmes_purchased') final  int programmesPurchased;
@override@JsonKey(name: 'meal_plans_purchased') final  int mealPlansPurchased;
@override@JsonKey(name: 'active_enrolments') final  int activeEnrolments;
@override@JsonKey(name: 'completed_enrolments') final  int completedEnrolments;
@override@JsonKey(name: 'avg_progress_pct') final  double? avgProgressPct;

/// Create a copy of ProgrammesSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProgrammesSummaryCopyWith<_ProgrammesSummary> get copyWith => __$ProgrammesSummaryCopyWithImpl<_ProgrammesSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProgrammesSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProgrammesSummary&&(identical(other.programmesPurchased, programmesPurchased) || other.programmesPurchased == programmesPurchased)&&(identical(other.mealPlansPurchased, mealPlansPurchased) || other.mealPlansPurchased == mealPlansPurchased)&&(identical(other.activeEnrolments, activeEnrolments) || other.activeEnrolments == activeEnrolments)&&(identical(other.completedEnrolments, completedEnrolments) || other.completedEnrolments == completedEnrolments)&&(identical(other.avgProgressPct, avgProgressPct) || other.avgProgressPct == avgProgressPct));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,programmesPurchased,mealPlansPurchased,activeEnrolments,completedEnrolments,avgProgressPct);

@override
String toString() {
  return 'ProgrammesSummary(programmesPurchased: $programmesPurchased, mealPlansPurchased: $mealPlansPurchased, activeEnrolments: $activeEnrolments, completedEnrolments: $completedEnrolments, avgProgressPct: $avgProgressPct)';
}


}

/// @nodoc
abstract mixin class _$ProgrammesSummaryCopyWith<$Res> implements $ProgrammesSummaryCopyWith<$Res> {
  factory _$ProgrammesSummaryCopyWith(_ProgrammesSummary value, $Res Function(_ProgrammesSummary) _then) = __$ProgrammesSummaryCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'programmes_purchased') int programmesPurchased,@JsonKey(name: 'meal_plans_purchased') int mealPlansPurchased,@JsonKey(name: 'active_enrolments') int activeEnrolments,@JsonKey(name: 'completed_enrolments') int completedEnrolments,@JsonKey(name: 'avg_progress_pct') double? avgProgressPct
});




}
/// @nodoc
class __$ProgrammesSummaryCopyWithImpl<$Res>
    implements _$ProgrammesSummaryCopyWith<$Res> {
  __$ProgrammesSummaryCopyWithImpl(this._self, this._then);

  final _ProgrammesSummary _self;
  final $Res Function(_ProgrammesSummary) _then;

/// Create a copy of ProgrammesSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? programmesPurchased = null,Object? mealPlansPurchased = null,Object? activeEnrolments = null,Object? completedEnrolments = null,Object? avgProgressPct = freezed,}) {
  return _then(_ProgrammesSummary(
programmesPurchased: null == programmesPurchased ? _self.programmesPurchased : programmesPurchased // ignore: cast_nullable_to_non_nullable
as int,mealPlansPurchased: null == mealPlansPurchased ? _self.mealPlansPurchased : mealPlansPurchased // ignore: cast_nullable_to_non_nullable
as int,activeEnrolments: null == activeEnrolments ? _self.activeEnrolments : activeEnrolments // ignore: cast_nullable_to_non_nullable
as int,completedEnrolments: null == completedEnrolments ? _self.completedEnrolments : completedEnrolments // ignore: cast_nullable_to_non_nullable
as int,avgProgressPct: freezed == avgProgressPct ? _self.avgProgressPct : avgProgressPct // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$AnalyticsSummaryData {

 String get period; AnalyticsUserInfo get user; WorkoutSummary get workouts; ActivitySummary get activity; BodySummary get body; LivesSummary get lives; SpendingSummary get spending; ProgrammesSummary get programmes; CountdownSummary get countdowns; RoutinesSummary get routines;
/// Create a copy of AnalyticsSummaryData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalyticsSummaryDataCopyWith<AnalyticsSummaryData> get copyWith => _$AnalyticsSummaryDataCopyWithImpl<AnalyticsSummaryData>(this as AnalyticsSummaryData, _$identity);

  /// Serializes this AnalyticsSummaryData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalyticsSummaryData&&(identical(other.period, period) || other.period == period)&&(identical(other.user, user) || other.user == user)&&(identical(other.workouts, workouts) || other.workouts == workouts)&&(identical(other.activity, activity) || other.activity == activity)&&(identical(other.body, body) || other.body == body)&&(identical(other.lives, lives) || other.lives == lives)&&(identical(other.spending, spending) || other.spending == spending)&&(identical(other.programmes, programmes) || other.programmes == programmes)&&(identical(other.countdowns, countdowns) || other.countdowns == countdowns)&&(identical(other.routines, routines) || other.routines == routines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,period,user,workouts,activity,body,lives,spending,programmes,countdowns,routines);

@override
String toString() {
  return 'AnalyticsSummaryData(period: $period, user: $user, workouts: $workouts, activity: $activity, body: $body, lives: $lives, spending: $spending, programmes: $programmes, countdowns: $countdowns, routines: $routines)';
}


}

/// @nodoc
abstract mixin class $AnalyticsSummaryDataCopyWith<$Res>  {
  factory $AnalyticsSummaryDataCopyWith(AnalyticsSummaryData value, $Res Function(AnalyticsSummaryData) _then) = _$AnalyticsSummaryDataCopyWithImpl;
@useResult
$Res call({
 String period, AnalyticsUserInfo user, WorkoutSummary workouts, ActivitySummary activity, BodySummary body, LivesSummary lives, SpendingSummary spending, ProgrammesSummary programmes, CountdownSummary countdowns, RoutinesSummary routines
});


$AnalyticsUserInfoCopyWith<$Res> get user;$WorkoutSummaryCopyWith<$Res> get workouts;$ActivitySummaryCopyWith<$Res> get activity;$BodySummaryCopyWith<$Res> get body;$LivesSummaryCopyWith<$Res> get lives;$SpendingSummaryCopyWith<$Res> get spending;$ProgrammesSummaryCopyWith<$Res> get programmes;$CountdownSummaryCopyWith<$Res> get countdowns;$RoutinesSummaryCopyWith<$Res> get routines;

}
/// @nodoc
class _$AnalyticsSummaryDataCopyWithImpl<$Res>
    implements $AnalyticsSummaryDataCopyWith<$Res> {
  _$AnalyticsSummaryDataCopyWithImpl(this._self, this._then);

  final AnalyticsSummaryData _self;
  final $Res Function(AnalyticsSummaryData) _then;

/// Create a copy of AnalyticsSummaryData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? period = null,Object? user = null,Object? workouts = null,Object? activity = null,Object? body = null,Object? lives = null,Object? spending = null,Object? programmes = null,Object? countdowns = null,Object? routines = null,}) {
  return _then(_self.copyWith(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as String,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as AnalyticsUserInfo,workouts: null == workouts ? _self.workouts : workouts // ignore: cast_nullable_to_non_nullable
as WorkoutSummary,activity: null == activity ? _self.activity : activity // ignore: cast_nullable_to_non_nullable
as ActivitySummary,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as BodySummary,lives: null == lives ? _self.lives : lives // ignore: cast_nullable_to_non_nullable
as LivesSummary,spending: null == spending ? _self.spending : spending // ignore: cast_nullable_to_non_nullable
as SpendingSummary,programmes: null == programmes ? _self.programmes : programmes // ignore: cast_nullable_to_non_nullable
as ProgrammesSummary,countdowns: null == countdowns ? _self.countdowns : countdowns // ignore: cast_nullable_to_non_nullable
as CountdownSummary,routines: null == routines ? _self.routines : routines // ignore: cast_nullable_to_non_nullable
as RoutinesSummary,
  ));
}
/// Create a copy of AnalyticsSummaryData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsUserInfoCopyWith<$Res> get user {
  
  return $AnalyticsUserInfoCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of AnalyticsSummaryData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WorkoutSummaryCopyWith<$Res> get workouts {
  
  return $WorkoutSummaryCopyWith<$Res>(_self.workouts, (value) {
    return _then(_self.copyWith(workouts: value));
  });
}/// Create a copy of AnalyticsSummaryData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ActivitySummaryCopyWith<$Res> get activity {
  
  return $ActivitySummaryCopyWith<$Res>(_self.activity, (value) {
    return _then(_self.copyWith(activity: value));
  });
}/// Create a copy of AnalyticsSummaryData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BodySummaryCopyWith<$Res> get body {
  
  return $BodySummaryCopyWith<$Res>(_self.body, (value) {
    return _then(_self.copyWith(body: value));
  });
}/// Create a copy of AnalyticsSummaryData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LivesSummaryCopyWith<$Res> get lives {
  
  return $LivesSummaryCopyWith<$Res>(_self.lives, (value) {
    return _then(_self.copyWith(lives: value));
  });
}/// Create a copy of AnalyticsSummaryData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SpendingSummaryCopyWith<$Res> get spending {
  
  return $SpendingSummaryCopyWith<$Res>(_self.spending, (value) {
    return _then(_self.copyWith(spending: value));
  });
}/// Create a copy of AnalyticsSummaryData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProgrammesSummaryCopyWith<$Res> get programmes {
  
  return $ProgrammesSummaryCopyWith<$Res>(_self.programmes, (value) {
    return _then(_self.copyWith(programmes: value));
  });
}/// Create a copy of AnalyticsSummaryData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CountdownSummaryCopyWith<$Res> get countdowns {
  
  return $CountdownSummaryCopyWith<$Res>(_self.countdowns, (value) {
    return _then(_self.copyWith(countdowns: value));
  });
}/// Create a copy of AnalyticsSummaryData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RoutinesSummaryCopyWith<$Res> get routines {
  
  return $RoutinesSummaryCopyWith<$Res>(_self.routines, (value) {
    return _then(_self.copyWith(routines: value));
  });
}
}


/// Adds pattern-matching-related methods to [AnalyticsSummaryData].
extension AnalyticsSummaryDataPatterns on AnalyticsSummaryData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalyticsSummaryData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalyticsSummaryData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalyticsSummaryData value)  $default,){
final _that = this;
switch (_that) {
case _AnalyticsSummaryData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalyticsSummaryData value)?  $default,){
final _that = this;
switch (_that) {
case _AnalyticsSummaryData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String period,  AnalyticsUserInfo user,  WorkoutSummary workouts,  ActivitySummary activity,  BodySummary body,  LivesSummary lives,  SpendingSummary spending,  ProgrammesSummary programmes,  CountdownSummary countdowns,  RoutinesSummary routines)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalyticsSummaryData() when $default != null:
return $default(_that.period,_that.user,_that.workouts,_that.activity,_that.body,_that.lives,_that.spending,_that.programmes,_that.countdowns,_that.routines);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String period,  AnalyticsUserInfo user,  WorkoutSummary workouts,  ActivitySummary activity,  BodySummary body,  LivesSummary lives,  SpendingSummary spending,  ProgrammesSummary programmes,  CountdownSummary countdowns,  RoutinesSummary routines)  $default,) {final _that = this;
switch (_that) {
case _AnalyticsSummaryData():
return $default(_that.period,_that.user,_that.workouts,_that.activity,_that.body,_that.lives,_that.spending,_that.programmes,_that.countdowns,_that.routines);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String period,  AnalyticsUserInfo user,  WorkoutSummary workouts,  ActivitySummary activity,  BodySummary body,  LivesSummary lives,  SpendingSummary spending,  ProgrammesSummary programmes,  CountdownSummary countdowns,  RoutinesSummary routines)?  $default,) {final _that = this;
switch (_that) {
case _AnalyticsSummaryData() when $default != null:
return $default(_that.period,_that.user,_that.workouts,_that.activity,_that.body,_that.lives,_that.spending,_that.programmes,_that.countdowns,_that.routines);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnalyticsSummaryData implements AnalyticsSummaryData {
  const _AnalyticsSummaryData({this.period = 'all', this.user = const AnalyticsUserInfo(), this.workouts = const WorkoutSummary(), this.activity = const ActivitySummary(), this.body = const BodySummary(), this.lives = const LivesSummary(), this.spending = const SpendingSummary(), this.programmes = const ProgrammesSummary(), this.countdowns = const CountdownSummary(), this.routines = const RoutinesSummary()});
  factory _AnalyticsSummaryData.fromJson(Map<String, dynamic> json) => _$AnalyticsSummaryDataFromJson(json);

@override@JsonKey() final  String period;
@override@JsonKey() final  AnalyticsUserInfo user;
@override@JsonKey() final  WorkoutSummary workouts;
@override@JsonKey() final  ActivitySummary activity;
@override@JsonKey() final  BodySummary body;
@override@JsonKey() final  LivesSummary lives;
@override@JsonKey() final  SpendingSummary spending;
@override@JsonKey() final  ProgrammesSummary programmes;
@override@JsonKey() final  CountdownSummary countdowns;
@override@JsonKey() final  RoutinesSummary routines;

/// Create a copy of AnalyticsSummaryData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalyticsSummaryDataCopyWith<_AnalyticsSummaryData> get copyWith => __$AnalyticsSummaryDataCopyWithImpl<_AnalyticsSummaryData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnalyticsSummaryDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalyticsSummaryData&&(identical(other.period, period) || other.period == period)&&(identical(other.user, user) || other.user == user)&&(identical(other.workouts, workouts) || other.workouts == workouts)&&(identical(other.activity, activity) || other.activity == activity)&&(identical(other.body, body) || other.body == body)&&(identical(other.lives, lives) || other.lives == lives)&&(identical(other.spending, spending) || other.spending == spending)&&(identical(other.programmes, programmes) || other.programmes == programmes)&&(identical(other.countdowns, countdowns) || other.countdowns == countdowns)&&(identical(other.routines, routines) || other.routines == routines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,period,user,workouts,activity,body,lives,spending,programmes,countdowns,routines);

@override
String toString() {
  return 'AnalyticsSummaryData(period: $period, user: $user, workouts: $workouts, activity: $activity, body: $body, lives: $lives, spending: $spending, programmes: $programmes, countdowns: $countdowns, routines: $routines)';
}


}

/// @nodoc
abstract mixin class _$AnalyticsSummaryDataCopyWith<$Res> implements $AnalyticsSummaryDataCopyWith<$Res> {
  factory _$AnalyticsSummaryDataCopyWith(_AnalyticsSummaryData value, $Res Function(_AnalyticsSummaryData) _then) = __$AnalyticsSummaryDataCopyWithImpl;
@override @useResult
$Res call({
 String period, AnalyticsUserInfo user, WorkoutSummary workouts, ActivitySummary activity, BodySummary body, LivesSummary lives, SpendingSummary spending, ProgrammesSummary programmes, CountdownSummary countdowns, RoutinesSummary routines
});


@override $AnalyticsUserInfoCopyWith<$Res> get user;@override $WorkoutSummaryCopyWith<$Res> get workouts;@override $ActivitySummaryCopyWith<$Res> get activity;@override $BodySummaryCopyWith<$Res> get body;@override $LivesSummaryCopyWith<$Res> get lives;@override $SpendingSummaryCopyWith<$Res> get spending;@override $ProgrammesSummaryCopyWith<$Res> get programmes;@override $CountdownSummaryCopyWith<$Res> get countdowns;@override $RoutinesSummaryCopyWith<$Res> get routines;

}
/// @nodoc
class __$AnalyticsSummaryDataCopyWithImpl<$Res>
    implements _$AnalyticsSummaryDataCopyWith<$Res> {
  __$AnalyticsSummaryDataCopyWithImpl(this._self, this._then);

  final _AnalyticsSummaryData _self;
  final $Res Function(_AnalyticsSummaryData) _then;

/// Create a copy of AnalyticsSummaryData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? period = null,Object? user = null,Object? workouts = null,Object? activity = null,Object? body = null,Object? lives = null,Object? spending = null,Object? programmes = null,Object? countdowns = null,Object? routines = null,}) {
  return _then(_AnalyticsSummaryData(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as String,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as AnalyticsUserInfo,workouts: null == workouts ? _self.workouts : workouts // ignore: cast_nullable_to_non_nullable
as WorkoutSummary,activity: null == activity ? _self.activity : activity // ignore: cast_nullable_to_non_nullable
as ActivitySummary,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as BodySummary,lives: null == lives ? _self.lives : lives // ignore: cast_nullable_to_non_nullable
as LivesSummary,spending: null == spending ? _self.spending : spending // ignore: cast_nullable_to_non_nullable
as SpendingSummary,programmes: null == programmes ? _self.programmes : programmes // ignore: cast_nullable_to_non_nullable
as ProgrammesSummary,countdowns: null == countdowns ? _self.countdowns : countdowns // ignore: cast_nullable_to_non_nullable
as CountdownSummary,routines: null == routines ? _self.routines : routines // ignore: cast_nullable_to_non_nullable
as RoutinesSummary,
  ));
}

/// Create a copy of AnalyticsSummaryData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsUserInfoCopyWith<$Res> get user {
  
  return $AnalyticsUserInfoCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of AnalyticsSummaryData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WorkoutSummaryCopyWith<$Res> get workouts {
  
  return $WorkoutSummaryCopyWith<$Res>(_self.workouts, (value) {
    return _then(_self.copyWith(workouts: value));
  });
}/// Create a copy of AnalyticsSummaryData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ActivitySummaryCopyWith<$Res> get activity {
  
  return $ActivitySummaryCopyWith<$Res>(_self.activity, (value) {
    return _then(_self.copyWith(activity: value));
  });
}/// Create a copy of AnalyticsSummaryData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BodySummaryCopyWith<$Res> get body {
  
  return $BodySummaryCopyWith<$Res>(_self.body, (value) {
    return _then(_self.copyWith(body: value));
  });
}/// Create a copy of AnalyticsSummaryData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LivesSummaryCopyWith<$Res> get lives {
  
  return $LivesSummaryCopyWith<$Res>(_self.lives, (value) {
    return _then(_self.copyWith(lives: value));
  });
}/// Create a copy of AnalyticsSummaryData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SpendingSummaryCopyWith<$Res> get spending {
  
  return $SpendingSummaryCopyWith<$Res>(_self.spending, (value) {
    return _then(_self.copyWith(spending: value));
  });
}/// Create a copy of AnalyticsSummaryData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProgrammesSummaryCopyWith<$Res> get programmes {
  
  return $ProgrammesSummaryCopyWith<$Res>(_self.programmes, (value) {
    return _then(_self.copyWith(programmes: value));
  });
}/// Create a copy of AnalyticsSummaryData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CountdownSummaryCopyWith<$Res> get countdowns {
  
  return $CountdownSummaryCopyWith<$Res>(_self.countdowns, (value) {
    return _then(_self.copyWith(countdowns: value));
  });
}/// Create a copy of AnalyticsSummaryData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RoutinesSummaryCopyWith<$Res> get routines {
  
  return $RoutinesSummaryCopyWith<$Res>(_self.routines, (value) {
    return _then(_self.copyWith(routines: value));
  });
}
}


/// @nodoc
mixin _$AnalyticsReportResult {

 String get id; String get period; AnalyticsSummaryData get data;@JsonKey(name: 'image_url') String get imageUrl;
/// Create a copy of AnalyticsReportResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalyticsReportResultCopyWith<AnalyticsReportResult> get copyWith => _$AnalyticsReportResultCopyWithImpl<AnalyticsReportResult>(this as AnalyticsReportResult, _$identity);

  /// Serializes this AnalyticsReportResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalyticsReportResult&&(identical(other.id, id) || other.id == id)&&(identical(other.period, period) || other.period == period)&&(identical(other.data, data) || other.data == data)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,period,data,imageUrl);

@override
String toString() {
  return 'AnalyticsReportResult(id: $id, period: $period, data: $data, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class $AnalyticsReportResultCopyWith<$Res>  {
  factory $AnalyticsReportResultCopyWith(AnalyticsReportResult value, $Res Function(AnalyticsReportResult) _then) = _$AnalyticsReportResultCopyWithImpl;
@useResult
$Res call({
 String id, String period, AnalyticsSummaryData data,@JsonKey(name: 'image_url') String imageUrl
});


$AnalyticsSummaryDataCopyWith<$Res> get data;

}
/// @nodoc
class _$AnalyticsReportResultCopyWithImpl<$Res>
    implements $AnalyticsReportResultCopyWith<$Res> {
  _$AnalyticsReportResultCopyWithImpl(this._self, this._then);

  final AnalyticsReportResult _self;
  final $Res Function(AnalyticsReportResult) _then;

/// Create a copy of AnalyticsReportResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? period = null,Object? data = null,Object? imageUrl = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as String,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as AnalyticsSummaryData,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of AnalyticsReportResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsSummaryDataCopyWith<$Res> get data {
  
  return $AnalyticsSummaryDataCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [AnalyticsReportResult].
extension AnalyticsReportResultPatterns on AnalyticsReportResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalyticsReportResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalyticsReportResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalyticsReportResult value)  $default,){
final _that = this;
switch (_that) {
case _AnalyticsReportResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalyticsReportResult value)?  $default,){
final _that = this;
switch (_that) {
case _AnalyticsReportResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String period,  AnalyticsSummaryData data, @JsonKey(name: 'image_url')  String imageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalyticsReportResult() when $default != null:
return $default(_that.id,_that.period,_that.data,_that.imageUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String period,  AnalyticsSummaryData data, @JsonKey(name: 'image_url')  String imageUrl)  $default,) {final _that = this;
switch (_that) {
case _AnalyticsReportResult():
return $default(_that.id,_that.period,_that.data,_that.imageUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String period,  AnalyticsSummaryData data, @JsonKey(name: 'image_url')  String imageUrl)?  $default,) {final _that = this;
switch (_that) {
case _AnalyticsReportResult() when $default != null:
return $default(_that.id,_that.period,_that.data,_that.imageUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnalyticsReportResult implements AnalyticsReportResult {
  const _AnalyticsReportResult({this.id = '', this.period = 'all', this.data = const AnalyticsSummaryData(), @JsonKey(name: 'image_url') this.imageUrl = ''});
  factory _AnalyticsReportResult.fromJson(Map<String, dynamic> json) => _$AnalyticsReportResultFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String period;
@override@JsonKey() final  AnalyticsSummaryData data;
@override@JsonKey(name: 'image_url') final  String imageUrl;

/// Create a copy of AnalyticsReportResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalyticsReportResultCopyWith<_AnalyticsReportResult> get copyWith => __$AnalyticsReportResultCopyWithImpl<_AnalyticsReportResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnalyticsReportResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalyticsReportResult&&(identical(other.id, id) || other.id == id)&&(identical(other.period, period) || other.period == period)&&(identical(other.data, data) || other.data == data)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,period,data,imageUrl);

@override
String toString() {
  return 'AnalyticsReportResult(id: $id, period: $period, data: $data, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class _$AnalyticsReportResultCopyWith<$Res> implements $AnalyticsReportResultCopyWith<$Res> {
  factory _$AnalyticsReportResultCopyWith(_AnalyticsReportResult value, $Res Function(_AnalyticsReportResult) _then) = __$AnalyticsReportResultCopyWithImpl;
@override @useResult
$Res call({
 String id, String period, AnalyticsSummaryData data,@JsonKey(name: 'image_url') String imageUrl
});


@override $AnalyticsSummaryDataCopyWith<$Res> get data;

}
/// @nodoc
class __$AnalyticsReportResultCopyWithImpl<$Res>
    implements _$AnalyticsReportResultCopyWith<$Res> {
  __$AnalyticsReportResultCopyWithImpl(this._self, this._then);

  final _AnalyticsReportResult _self;
  final $Res Function(_AnalyticsReportResult) _then;

/// Create a copy of AnalyticsReportResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? period = null,Object? data = null,Object? imageUrl = null,}) {
  return _then(_AnalyticsReportResult(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as String,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as AnalyticsSummaryData,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of AnalyticsReportResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsSummaryDataCopyWith<$Res> get data {
  
  return $AnalyticsSummaryDataCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// @nodoc
mixin _$ShareReportResult {

@JsonKey(name: 'report_id') String get reportId;@JsonKey(name: 'post_id') String get postId;@JsonKey(name: 'image_url') String get imageUrl;
/// Create a copy of ShareReportResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShareReportResultCopyWith<ShareReportResult> get copyWith => _$ShareReportResultCopyWithImpl<ShareReportResult>(this as ShareReportResult, _$identity);

  /// Serializes this ShareReportResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShareReportResult&&(identical(other.reportId, reportId) || other.reportId == reportId)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reportId,postId,imageUrl);

@override
String toString() {
  return 'ShareReportResult(reportId: $reportId, postId: $postId, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class $ShareReportResultCopyWith<$Res>  {
  factory $ShareReportResultCopyWith(ShareReportResult value, $Res Function(ShareReportResult) _then) = _$ShareReportResultCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'report_id') String reportId,@JsonKey(name: 'post_id') String postId,@JsonKey(name: 'image_url') String imageUrl
});




}
/// @nodoc
class _$ShareReportResultCopyWithImpl<$Res>
    implements $ShareReportResultCopyWith<$Res> {
  _$ShareReportResultCopyWithImpl(this._self, this._then);

  final ShareReportResult _self;
  final $Res Function(ShareReportResult) _then;

/// Create a copy of ShareReportResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reportId = null,Object? postId = null,Object? imageUrl = null,}) {
  return _then(_self.copyWith(
reportId: null == reportId ? _self.reportId : reportId // ignore: cast_nullable_to_non_nullable
as String,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ShareReportResult].
extension ShareReportResultPatterns on ShareReportResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShareReportResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShareReportResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShareReportResult value)  $default,){
final _that = this;
switch (_that) {
case _ShareReportResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShareReportResult value)?  $default,){
final _that = this;
switch (_that) {
case _ShareReportResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'report_id')  String reportId, @JsonKey(name: 'post_id')  String postId, @JsonKey(name: 'image_url')  String imageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShareReportResult() when $default != null:
return $default(_that.reportId,_that.postId,_that.imageUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'report_id')  String reportId, @JsonKey(name: 'post_id')  String postId, @JsonKey(name: 'image_url')  String imageUrl)  $default,) {final _that = this;
switch (_that) {
case _ShareReportResult():
return $default(_that.reportId,_that.postId,_that.imageUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'report_id')  String reportId, @JsonKey(name: 'post_id')  String postId, @JsonKey(name: 'image_url')  String imageUrl)?  $default,) {final _that = this;
switch (_that) {
case _ShareReportResult() when $default != null:
return $default(_that.reportId,_that.postId,_that.imageUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShareReportResult implements ShareReportResult {
  const _ShareReportResult({@JsonKey(name: 'report_id') this.reportId = '', @JsonKey(name: 'post_id') this.postId = '', @JsonKey(name: 'image_url') this.imageUrl = ''});
  factory _ShareReportResult.fromJson(Map<String, dynamic> json) => _$ShareReportResultFromJson(json);

@override@JsonKey(name: 'report_id') final  String reportId;
@override@JsonKey(name: 'post_id') final  String postId;
@override@JsonKey(name: 'image_url') final  String imageUrl;

/// Create a copy of ShareReportResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShareReportResultCopyWith<_ShareReportResult> get copyWith => __$ShareReportResultCopyWithImpl<_ShareReportResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShareReportResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShareReportResult&&(identical(other.reportId, reportId) || other.reportId == reportId)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reportId,postId,imageUrl);

@override
String toString() {
  return 'ShareReportResult(reportId: $reportId, postId: $postId, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class _$ShareReportResultCopyWith<$Res> implements $ShareReportResultCopyWith<$Res> {
  factory _$ShareReportResultCopyWith(_ShareReportResult value, $Res Function(_ShareReportResult) _then) = __$ShareReportResultCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'report_id') String reportId,@JsonKey(name: 'post_id') String postId,@JsonKey(name: 'image_url') String imageUrl
});




}
/// @nodoc
class __$ShareReportResultCopyWithImpl<$Res>
    implements _$ShareReportResultCopyWith<$Res> {
  __$ShareReportResultCopyWithImpl(this._self, this._then);

  final _ShareReportResult _self;
  final $Res Function(_ShareReportResult) _then;

/// Create a copy of ShareReportResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reportId = null,Object? postId = null,Object? imageUrl = null,}) {
  return _then(_ShareReportResult(
reportId: null == reportId ? _self.reportId : reportId // ignore: cast_nullable_to_non_nullable
as String,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
