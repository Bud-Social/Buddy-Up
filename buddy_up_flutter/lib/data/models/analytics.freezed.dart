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

 String get id;@JsonKey(name: 'activity_type') String get activityType;@JsonKey(name: 'started_at') String? get startedAt;@JsonKey(name: 'duration_seconds') int get durationSeconds;@JsonKey(name: 'distance_meters') double get distanceMeters;@JsonKey(name: 'distance_km') double get distanceKm;@JsonKey(name: 'avg_pace') double? get avgPace;@JsonKey(name: 'calories_burned') double? get caloriesBurned; List<dynamic> get route;
/// Create a copy of ActivityRecent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActivityRecentCopyWith<ActivityRecent> get copyWith => _$ActivityRecentCopyWithImpl<ActivityRecent>(this as ActivityRecent, _$identity);

  /// Serializes this ActivityRecent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActivityRecent&&(identical(other.id, id) || other.id == id)&&(identical(other.activityType, activityType) || other.activityType == activityType)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.distanceMeters, distanceMeters) || other.distanceMeters == distanceMeters)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.avgPace, avgPace) || other.avgPace == avgPace)&&(identical(other.caloriesBurned, caloriesBurned) || other.caloriesBurned == caloriesBurned)&&const DeepCollectionEquality().equals(other.route, route));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,activityType,startedAt,durationSeconds,distanceMeters,distanceKm,avgPace,caloriesBurned,const DeepCollectionEquality().hash(route));

@override
String toString() {
  return 'ActivityRecent(id: $id, activityType: $activityType, startedAt: $startedAt, durationSeconds: $durationSeconds, distanceMeters: $distanceMeters, distanceKm: $distanceKm, avgPace: $avgPace, caloriesBurned: $caloriesBurned, route: $route)';
}


}

/// @nodoc
abstract mixin class $ActivityRecentCopyWith<$Res>  {
  factory $ActivityRecentCopyWith(ActivityRecent value, $Res Function(ActivityRecent) _then) = _$ActivityRecentCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'activity_type') String activityType,@JsonKey(name: 'started_at') String? startedAt,@JsonKey(name: 'duration_seconds') int durationSeconds,@JsonKey(name: 'distance_meters') double distanceMeters,@JsonKey(name: 'distance_km') double distanceKm,@JsonKey(name: 'avg_pace') double? avgPace,@JsonKey(name: 'calories_burned') double? caloriesBurned, List<dynamic> route
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? activityType = null,Object? startedAt = freezed,Object? durationSeconds = null,Object? distanceMeters = null,Object? distanceKm = null,Object? avgPace = freezed,Object? caloriesBurned = freezed,Object? route = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,activityType: null == activityType ? _self.activityType : activityType // ignore: cast_nullable_to_non_nullable
as String,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as String?,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,distanceMeters: null == distanceMeters ? _self.distanceMeters : distanceMeters // ignore: cast_nullable_to_non_nullable
as double,distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,avgPace: freezed == avgPace ? _self.avgPace : avgPace // ignore: cast_nullable_to_non_nullable
as double?,caloriesBurned: freezed == caloriesBurned ? _self.caloriesBurned : caloriesBurned // ignore: cast_nullable_to_non_nullable
as double?,route: null == route ? _self.route : route // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'activity_type')  String activityType, @JsonKey(name: 'started_at')  String? startedAt, @JsonKey(name: 'duration_seconds')  int durationSeconds, @JsonKey(name: 'distance_meters')  double distanceMeters, @JsonKey(name: 'distance_km')  double distanceKm, @JsonKey(name: 'avg_pace')  double? avgPace, @JsonKey(name: 'calories_burned')  double? caloriesBurned,  List<dynamic> route)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActivityRecent() when $default != null:
return $default(_that.id,_that.activityType,_that.startedAt,_that.durationSeconds,_that.distanceMeters,_that.distanceKm,_that.avgPace,_that.caloriesBurned,_that.route);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'activity_type')  String activityType, @JsonKey(name: 'started_at')  String? startedAt, @JsonKey(name: 'duration_seconds')  int durationSeconds, @JsonKey(name: 'distance_meters')  double distanceMeters, @JsonKey(name: 'distance_km')  double distanceKm, @JsonKey(name: 'avg_pace')  double? avgPace, @JsonKey(name: 'calories_burned')  double? caloriesBurned,  List<dynamic> route)  $default,) {final _that = this;
switch (_that) {
case _ActivityRecent():
return $default(_that.id,_that.activityType,_that.startedAt,_that.durationSeconds,_that.distanceMeters,_that.distanceKm,_that.avgPace,_that.caloriesBurned,_that.route);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'activity_type')  String activityType, @JsonKey(name: 'started_at')  String? startedAt, @JsonKey(name: 'duration_seconds')  int durationSeconds, @JsonKey(name: 'distance_meters')  double distanceMeters, @JsonKey(name: 'distance_km')  double distanceKm, @JsonKey(name: 'avg_pace')  double? avgPace, @JsonKey(name: 'calories_burned')  double? caloriesBurned,  List<dynamic> route)?  $default,) {final _that = this;
switch (_that) {
case _ActivityRecent() when $default != null:
return $default(_that.id,_that.activityType,_that.startedAt,_that.durationSeconds,_that.distanceMeters,_that.distanceKm,_that.avgPace,_that.caloriesBurned,_that.route);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ActivityRecent implements ActivityRecent {
  const _ActivityRecent({this.id = '', @JsonKey(name: 'activity_type') this.activityType = '', @JsonKey(name: 'started_at') this.startedAt, @JsonKey(name: 'duration_seconds') this.durationSeconds = 0, @JsonKey(name: 'distance_meters') this.distanceMeters = 0, @JsonKey(name: 'distance_km') this.distanceKm = 0, @JsonKey(name: 'avg_pace') this.avgPace, @JsonKey(name: 'calories_burned') this.caloriesBurned, final  List<dynamic> route = const <dynamic>[]}): _route = route;
  factory _ActivityRecent.fromJson(Map<String, dynamic> json) => _$ActivityRecentFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey(name: 'activity_type') final  String activityType;
@override@JsonKey(name: 'started_at') final  String? startedAt;
@override@JsonKey(name: 'duration_seconds') final  int durationSeconds;
@override@JsonKey(name: 'distance_meters') final  double distanceMeters;
@override@JsonKey(name: 'distance_km') final  double distanceKm;
@override@JsonKey(name: 'avg_pace') final  double? avgPace;
@override@JsonKey(name: 'calories_burned') final  double? caloriesBurned;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivityRecent&&(identical(other.id, id) || other.id == id)&&(identical(other.activityType, activityType) || other.activityType == activityType)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.distanceMeters, distanceMeters) || other.distanceMeters == distanceMeters)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.avgPace, avgPace) || other.avgPace == avgPace)&&(identical(other.caloriesBurned, caloriesBurned) || other.caloriesBurned == caloriesBurned)&&const DeepCollectionEquality().equals(other._route, _route));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,activityType,startedAt,durationSeconds,distanceMeters,distanceKm,avgPace,caloriesBurned,const DeepCollectionEquality().hash(_route));

@override
String toString() {
  return 'ActivityRecent(id: $id, activityType: $activityType, startedAt: $startedAt, durationSeconds: $durationSeconds, distanceMeters: $distanceMeters, distanceKm: $distanceKm, avgPace: $avgPace, caloriesBurned: $caloriesBurned, route: $route)';
}


}

/// @nodoc
abstract mixin class _$ActivityRecentCopyWith<$Res> implements $ActivityRecentCopyWith<$Res> {
  factory _$ActivityRecentCopyWith(_ActivityRecent value, $Res Function(_ActivityRecent) _then) = __$ActivityRecentCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'activity_type') String activityType,@JsonKey(name: 'started_at') String? startedAt,@JsonKey(name: 'duration_seconds') int durationSeconds,@JsonKey(name: 'distance_meters') double distanceMeters,@JsonKey(name: 'distance_km') double distanceKm,@JsonKey(name: 'avg_pace') double? avgPace,@JsonKey(name: 'calories_burned') double? caloriesBurned, List<dynamic> route
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? activityType = null,Object? startedAt = freezed,Object? durationSeconds = null,Object? distanceMeters = null,Object? distanceKm = null,Object? avgPace = freezed,Object? caloriesBurned = freezed,Object? route = null,}) {
  return _then(_ActivityRecent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,activityType: null == activityType ? _self.activityType : activityType // ignore: cast_nullable_to_non_nullable
as String,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as String?,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,distanceMeters: null == distanceMeters ? _self.distanceMeters : distanceMeters // ignore: cast_nullable_to_non_nullable
as double,distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,avgPace: freezed == avgPace ? _self.avgPace : avgPace // ignore: cast_nullable_to_non_nullable
as double?,caloriesBurned: freezed == caloriesBurned ? _self.caloriesBurned : caloriesBurned // ignore: cast_nullable_to_non_nullable
as double?,route: null == route ? _self._route : route // ignore: cast_nullable_to_non_nullable
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
mixin _$MealRecent {

 String get id;@JsonKey(name: 'meal_type') String get mealType;@JsonKey(name: 'food_name') String get foodName; String get description; double? get calories;@JsonKey(name: 'protein_g') double? get proteinG;@JsonKey(name: 'carbs_g') double? get carbsG;@JsonKey(name: 'fat_g') double? get fatG;@JsonKey(name: 'photo_url') String get photoUrl;@JsonKey(name: 'logged_at') String? get loggedAt;
/// Create a copy of MealRecent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MealRecentCopyWith<MealRecent> get copyWith => _$MealRecentCopyWithImpl<MealRecent>(this as MealRecent, _$identity);

  /// Serializes this MealRecent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MealRecent&&(identical(other.id, id) || other.id == id)&&(identical(other.mealType, mealType) || other.mealType == mealType)&&(identical(other.foodName, foodName) || other.foodName == foodName)&&(identical(other.description, description) || other.description == description)&&(identical(other.calories, calories) || other.calories == calories)&&(identical(other.proteinG, proteinG) || other.proteinG == proteinG)&&(identical(other.carbsG, carbsG) || other.carbsG == carbsG)&&(identical(other.fatG, fatG) || other.fatG == fatG)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.loggedAt, loggedAt) || other.loggedAt == loggedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,mealType,foodName,description,calories,proteinG,carbsG,fatG,photoUrl,loggedAt);

@override
String toString() {
  return 'MealRecent(id: $id, mealType: $mealType, foodName: $foodName, description: $description, calories: $calories, proteinG: $proteinG, carbsG: $carbsG, fatG: $fatG, photoUrl: $photoUrl, loggedAt: $loggedAt)';
}


}

/// @nodoc
abstract mixin class $MealRecentCopyWith<$Res>  {
  factory $MealRecentCopyWith(MealRecent value, $Res Function(MealRecent) _then) = _$MealRecentCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'meal_type') String mealType,@JsonKey(name: 'food_name') String foodName, String description, double? calories,@JsonKey(name: 'protein_g') double? proteinG,@JsonKey(name: 'carbs_g') double? carbsG,@JsonKey(name: 'fat_g') double? fatG,@JsonKey(name: 'photo_url') String photoUrl,@JsonKey(name: 'logged_at') String? loggedAt
});




}
/// @nodoc
class _$MealRecentCopyWithImpl<$Res>
    implements $MealRecentCopyWith<$Res> {
  _$MealRecentCopyWithImpl(this._self, this._then);

  final MealRecent _self;
  final $Res Function(MealRecent) _then;

/// Create a copy of MealRecent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? mealType = null,Object? foodName = null,Object? description = null,Object? calories = freezed,Object? proteinG = freezed,Object? carbsG = freezed,Object? fatG = freezed,Object? photoUrl = null,Object? loggedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,mealType: null == mealType ? _self.mealType : mealType // ignore: cast_nullable_to_non_nullable
as String,foodName: null == foodName ? _self.foodName : foodName // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,calories: freezed == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as double?,proteinG: freezed == proteinG ? _self.proteinG : proteinG // ignore: cast_nullable_to_non_nullable
as double?,carbsG: freezed == carbsG ? _self.carbsG : carbsG // ignore: cast_nullable_to_non_nullable
as double?,fatG: freezed == fatG ? _self.fatG : fatG // ignore: cast_nullable_to_non_nullable
as double?,photoUrl: null == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String,loggedAt: freezed == loggedAt ? _self.loggedAt : loggedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MealRecent].
extension MealRecentPatterns on MealRecent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MealRecent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MealRecent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MealRecent value)  $default,){
final _that = this;
switch (_that) {
case _MealRecent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MealRecent value)?  $default,){
final _that = this;
switch (_that) {
case _MealRecent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'meal_type')  String mealType, @JsonKey(name: 'food_name')  String foodName,  String description,  double? calories, @JsonKey(name: 'protein_g')  double? proteinG, @JsonKey(name: 'carbs_g')  double? carbsG, @JsonKey(name: 'fat_g')  double? fatG, @JsonKey(name: 'photo_url')  String photoUrl, @JsonKey(name: 'logged_at')  String? loggedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MealRecent() when $default != null:
return $default(_that.id,_that.mealType,_that.foodName,_that.description,_that.calories,_that.proteinG,_that.carbsG,_that.fatG,_that.photoUrl,_that.loggedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'meal_type')  String mealType, @JsonKey(name: 'food_name')  String foodName,  String description,  double? calories, @JsonKey(name: 'protein_g')  double? proteinG, @JsonKey(name: 'carbs_g')  double? carbsG, @JsonKey(name: 'fat_g')  double? fatG, @JsonKey(name: 'photo_url')  String photoUrl, @JsonKey(name: 'logged_at')  String? loggedAt)  $default,) {final _that = this;
switch (_that) {
case _MealRecent():
return $default(_that.id,_that.mealType,_that.foodName,_that.description,_that.calories,_that.proteinG,_that.carbsG,_that.fatG,_that.photoUrl,_that.loggedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'meal_type')  String mealType, @JsonKey(name: 'food_name')  String foodName,  String description,  double? calories, @JsonKey(name: 'protein_g')  double? proteinG, @JsonKey(name: 'carbs_g')  double? carbsG, @JsonKey(name: 'fat_g')  double? fatG, @JsonKey(name: 'photo_url')  String photoUrl, @JsonKey(name: 'logged_at')  String? loggedAt)?  $default,) {final _that = this;
switch (_that) {
case _MealRecent() when $default != null:
return $default(_that.id,_that.mealType,_that.foodName,_that.description,_that.calories,_that.proteinG,_that.carbsG,_that.fatG,_that.photoUrl,_that.loggedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MealRecent implements MealRecent {
  const _MealRecent({this.id = '', @JsonKey(name: 'meal_type') this.mealType = '', @JsonKey(name: 'food_name') this.foodName = '', this.description = '', this.calories, @JsonKey(name: 'protein_g') this.proteinG, @JsonKey(name: 'carbs_g') this.carbsG, @JsonKey(name: 'fat_g') this.fatG, @JsonKey(name: 'photo_url') this.photoUrl = '', @JsonKey(name: 'logged_at') this.loggedAt});
  factory _MealRecent.fromJson(Map<String, dynamic> json) => _$MealRecentFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey(name: 'meal_type') final  String mealType;
@override@JsonKey(name: 'food_name') final  String foodName;
@override@JsonKey() final  String description;
@override final  double? calories;
@override@JsonKey(name: 'protein_g') final  double? proteinG;
@override@JsonKey(name: 'carbs_g') final  double? carbsG;
@override@JsonKey(name: 'fat_g') final  double? fatG;
@override@JsonKey(name: 'photo_url') final  String photoUrl;
@override@JsonKey(name: 'logged_at') final  String? loggedAt;

/// Create a copy of MealRecent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MealRecentCopyWith<_MealRecent> get copyWith => __$MealRecentCopyWithImpl<_MealRecent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MealRecentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MealRecent&&(identical(other.id, id) || other.id == id)&&(identical(other.mealType, mealType) || other.mealType == mealType)&&(identical(other.foodName, foodName) || other.foodName == foodName)&&(identical(other.description, description) || other.description == description)&&(identical(other.calories, calories) || other.calories == calories)&&(identical(other.proteinG, proteinG) || other.proteinG == proteinG)&&(identical(other.carbsG, carbsG) || other.carbsG == carbsG)&&(identical(other.fatG, fatG) || other.fatG == fatG)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.loggedAt, loggedAt) || other.loggedAt == loggedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,mealType,foodName,description,calories,proteinG,carbsG,fatG,photoUrl,loggedAt);

@override
String toString() {
  return 'MealRecent(id: $id, mealType: $mealType, foodName: $foodName, description: $description, calories: $calories, proteinG: $proteinG, carbsG: $carbsG, fatG: $fatG, photoUrl: $photoUrl, loggedAt: $loggedAt)';
}


}

/// @nodoc
abstract mixin class _$MealRecentCopyWith<$Res> implements $MealRecentCopyWith<$Res> {
  factory _$MealRecentCopyWith(_MealRecent value, $Res Function(_MealRecent) _then) = __$MealRecentCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'meal_type') String mealType,@JsonKey(name: 'food_name') String foodName, String description, double? calories,@JsonKey(name: 'protein_g') double? proteinG,@JsonKey(name: 'carbs_g') double? carbsG,@JsonKey(name: 'fat_g') double? fatG,@JsonKey(name: 'photo_url') String photoUrl,@JsonKey(name: 'logged_at') String? loggedAt
});




}
/// @nodoc
class __$MealRecentCopyWithImpl<$Res>
    implements _$MealRecentCopyWith<$Res> {
  __$MealRecentCopyWithImpl(this._self, this._then);

  final _MealRecent _self;
  final $Res Function(_MealRecent) _then;

/// Create a copy of MealRecent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? mealType = null,Object? foodName = null,Object? description = null,Object? calories = freezed,Object? proteinG = freezed,Object? carbsG = freezed,Object? fatG = freezed,Object? photoUrl = null,Object? loggedAt = freezed,}) {
  return _then(_MealRecent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,mealType: null == mealType ? _self.mealType : mealType // ignore: cast_nullable_to_non_nullable
as String,foodName: null == foodName ? _self.foodName : foodName // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,calories: freezed == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as double?,proteinG: freezed == proteinG ? _self.proteinG : proteinG // ignore: cast_nullable_to_non_nullable
as double?,carbsG: freezed == carbsG ? _self.carbsG : carbsG // ignore: cast_nullable_to_non_nullable
as double?,fatG: freezed == fatG ? _self.fatG : fatG // ignore: cast_nullable_to_non_nullable
as double?,photoUrl: null == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String,loggedAt: freezed == loggedAt ? _self.loggedAt : loggedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$NutritionSummary {

 int get count;@JsonKey(name: 'total_calories') double get totalCalories;@JsonKey(name: 'total_protein_g') double get totalProteinG;@JsonKey(name: 'total_carbs_g') double get totalCarbsG;@JsonKey(name: 'total_fat_g') double get totalFatG;@JsonKey(name: 'by_type') List<ActivityTypeBreakdown> get byType;@JsonKey(name: 'avg_daily_calories') double? get avgDailyCalories; List<MealRecent> get recent;
/// Create a copy of NutritionSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NutritionSummaryCopyWith<NutritionSummary> get copyWith => _$NutritionSummaryCopyWithImpl<NutritionSummary>(this as NutritionSummary, _$identity);

  /// Serializes this NutritionSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NutritionSummary&&(identical(other.count, count) || other.count == count)&&(identical(other.totalCalories, totalCalories) || other.totalCalories == totalCalories)&&(identical(other.totalProteinG, totalProteinG) || other.totalProteinG == totalProteinG)&&(identical(other.totalCarbsG, totalCarbsG) || other.totalCarbsG == totalCarbsG)&&(identical(other.totalFatG, totalFatG) || other.totalFatG == totalFatG)&&const DeepCollectionEquality().equals(other.byType, byType)&&(identical(other.avgDailyCalories, avgDailyCalories) || other.avgDailyCalories == avgDailyCalories)&&const DeepCollectionEquality().equals(other.recent, recent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,count,totalCalories,totalProteinG,totalCarbsG,totalFatG,const DeepCollectionEquality().hash(byType),avgDailyCalories,const DeepCollectionEquality().hash(recent));

@override
String toString() {
  return 'NutritionSummary(count: $count, totalCalories: $totalCalories, totalProteinG: $totalProteinG, totalCarbsG: $totalCarbsG, totalFatG: $totalFatG, byType: $byType, avgDailyCalories: $avgDailyCalories, recent: $recent)';
}


}

/// @nodoc
abstract mixin class $NutritionSummaryCopyWith<$Res>  {
  factory $NutritionSummaryCopyWith(NutritionSummary value, $Res Function(NutritionSummary) _then) = _$NutritionSummaryCopyWithImpl;
@useResult
$Res call({
 int count,@JsonKey(name: 'total_calories') double totalCalories,@JsonKey(name: 'total_protein_g') double totalProteinG,@JsonKey(name: 'total_carbs_g') double totalCarbsG,@JsonKey(name: 'total_fat_g') double totalFatG,@JsonKey(name: 'by_type') List<ActivityTypeBreakdown> byType,@JsonKey(name: 'avg_daily_calories') double? avgDailyCalories, List<MealRecent> recent
});




}
/// @nodoc
class _$NutritionSummaryCopyWithImpl<$Res>
    implements $NutritionSummaryCopyWith<$Res> {
  _$NutritionSummaryCopyWithImpl(this._self, this._then);

  final NutritionSummary _self;
  final $Res Function(NutritionSummary) _then;

/// Create a copy of NutritionSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? count = null,Object? totalCalories = null,Object? totalProteinG = null,Object? totalCarbsG = null,Object? totalFatG = null,Object? byType = null,Object? avgDailyCalories = freezed,Object? recent = null,}) {
  return _then(_self.copyWith(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,totalCalories: null == totalCalories ? _self.totalCalories : totalCalories // ignore: cast_nullable_to_non_nullable
as double,totalProteinG: null == totalProteinG ? _self.totalProteinG : totalProteinG // ignore: cast_nullable_to_non_nullable
as double,totalCarbsG: null == totalCarbsG ? _self.totalCarbsG : totalCarbsG // ignore: cast_nullable_to_non_nullable
as double,totalFatG: null == totalFatG ? _self.totalFatG : totalFatG // ignore: cast_nullable_to_non_nullable
as double,byType: null == byType ? _self.byType : byType // ignore: cast_nullable_to_non_nullable
as List<ActivityTypeBreakdown>,avgDailyCalories: freezed == avgDailyCalories ? _self.avgDailyCalories : avgDailyCalories // ignore: cast_nullable_to_non_nullable
as double?,recent: null == recent ? _self.recent : recent // ignore: cast_nullable_to_non_nullable
as List<MealRecent>,
  ));
}

}


/// Adds pattern-matching-related methods to [NutritionSummary].
extension NutritionSummaryPatterns on NutritionSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NutritionSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NutritionSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NutritionSummary value)  $default,){
final _that = this;
switch (_that) {
case _NutritionSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NutritionSummary value)?  $default,){
final _that = this;
switch (_that) {
case _NutritionSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int count, @JsonKey(name: 'total_calories')  double totalCalories, @JsonKey(name: 'total_protein_g')  double totalProteinG, @JsonKey(name: 'total_carbs_g')  double totalCarbsG, @JsonKey(name: 'total_fat_g')  double totalFatG, @JsonKey(name: 'by_type')  List<ActivityTypeBreakdown> byType, @JsonKey(name: 'avg_daily_calories')  double? avgDailyCalories,  List<MealRecent> recent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NutritionSummary() when $default != null:
return $default(_that.count,_that.totalCalories,_that.totalProteinG,_that.totalCarbsG,_that.totalFatG,_that.byType,_that.avgDailyCalories,_that.recent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int count, @JsonKey(name: 'total_calories')  double totalCalories, @JsonKey(name: 'total_protein_g')  double totalProteinG, @JsonKey(name: 'total_carbs_g')  double totalCarbsG, @JsonKey(name: 'total_fat_g')  double totalFatG, @JsonKey(name: 'by_type')  List<ActivityTypeBreakdown> byType, @JsonKey(name: 'avg_daily_calories')  double? avgDailyCalories,  List<MealRecent> recent)  $default,) {final _that = this;
switch (_that) {
case _NutritionSummary():
return $default(_that.count,_that.totalCalories,_that.totalProteinG,_that.totalCarbsG,_that.totalFatG,_that.byType,_that.avgDailyCalories,_that.recent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int count, @JsonKey(name: 'total_calories')  double totalCalories, @JsonKey(name: 'total_protein_g')  double totalProteinG, @JsonKey(name: 'total_carbs_g')  double totalCarbsG, @JsonKey(name: 'total_fat_g')  double totalFatG, @JsonKey(name: 'by_type')  List<ActivityTypeBreakdown> byType, @JsonKey(name: 'avg_daily_calories')  double? avgDailyCalories,  List<MealRecent> recent)?  $default,) {final _that = this;
switch (_that) {
case _NutritionSummary() when $default != null:
return $default(_that.count,_that.totalCalories,_that.totalProteinG,_that.totalCarbsG,_that.totalFatG,_that.byType,_that.avgDailyCalories,_that.recent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NutritionSummary implements NutritionSummary {
  const _NutritionSummary({this.count = 0, @JsonKey(name: 'total_calories') this.totalCalories = 0, @JsonKey(name: 'total_protein_g') this.totalProteinG = 0, @JsonKey(name: 'total_carbs_g') this.totalCarbsG = 0, @JsonKey(name: 'total_fat_g') this.totalFatG = 0, @JsonKey(name: 'by_type') final  List<ActivityTypeBreakdown> byType = const <ActivityTypeBreakdown>[], @JsonKey(name: 'avg_daily_calories') this.avgDailyCalories, final  List<MealRecent> recent = const <MealRecent>[]}): _byType = byType,_recent = recent;
  factory _NutritionSummary.fromJson(Map<String, dynamic> json) => _$NutritionSummaryFromJson(json);

@override@JsonKey() final  int count;
@override@JsonKey(name: 'total_calories') final  double totalCalories;
@override@JsonKey(name: 'total_protein_g') final  double totalProteinG;
@override@JsonKey(name: 'total_carbs_g') final  double totalCarbsG;
@override@JsonKey(name: 'total_fat_g') final  double totalFatG;
 final  List<ActivityTypeBreakdown> _byType;
@override@JsonKey(name: 'by_type') List<ActivityTypeBreakdown> get byType {
  if (_byType is EqualUnmodifiableListView) return _byType;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_byType);
}

@override@JsonKey(name: 'avg_daily_calories') final  double? avgDailyCalories;
 final  List<MealRecent> _recent;
@override@JsonKey() List<MealRecent> get recent {
  if (_recent is EqualUnmodifiableListView) return _recent;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recent);
}


/// Create a copy of NutritionSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NutritionSummaryCopyWith<_NutritionSummary> get copyWith => __$NutritionSummaryCopyWithImpl<_NutritionSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NutritionSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NutritionSummary&&(identical(other.count, count) || other.count == count)&&(identical(other.totalCalories, totalCalories) || other.totalCalories == totalCalories)&&(identical(other.totalProteinG, totalProteinG) || other.totalProteinG == totalProteinG)&&(identical(other.totalCarbsG, totalCarbsG) || other.totalCarbsG == totalCarbsG)&&(identical(other.totalFatG, totalFatG) || other.totalFatG == totalFatG)&&const DeepCollectionEquality().equals(other._byType, _byType)&&(identical(other.avgDailyCalories, avgDailyCalories) || other.avgDailyCalories == avgDailyCalories)&&const DeepCollectionEquality().equals(other._recent, _recent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,count,totalCalories,totalProteinG,totalCarbsG,totalFatG,const DeepCollectionEquality().hash(_byType),avgDailyCalories,const DeepCollectionEquality().hash(_recent));

@override
String toString() {
  return 'NutritionSummary(count: $count, totalCalories: $totalCalories, totalProteinG: $totalProteinG, totalCarbsG: $totalCarbsG, totalFatG: $totalFatG, byType: $byType, avgDailyCalories: $avgDailyCalories, recent: $recent)';
}


}

/// @nodoc
abstract mixin class _$NutritionSummaryCopyWith<$Res> implements $NutritionSummaryCopyWith<$Res> {
  factory _$NutritionSummaryCopyWith(_NutritionSummary value, $Res Function(_NutritionSummary) _then) = __$NutritionSummaryCopyWithImpl;
@override @useResult
$Res call({
 int count,@JsonKey(name: 'total_calories') double totalCalories,@JsonKey(name: 'total_protein_g') double totalProteinG,@JsonKey(name: 'total_carbs_g') double totalCarbsG,@JsonKey(name: 'total_fat_g') double totalFatG,@JsonKey(name: 'by_type') List<ActivityTypeBreakdown> byType,@JsonKey(name: 'avg_daily_calories') double? avgDailyCalories, List<MealRecent> recent
});




}
/// @nodoc
class __$NutritionSummaryCopyWithImpl<$Res>
    implements _$NutritionSummaryCopyWith<$Res> {
  __$NutritionSummaryCopyWithImpl(this._self, this._then);

  final _NutritionSummary _self;
  final $Res Function(_NutritionSummary) _then;

/// Create a copy of NutritionSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? count = null,Object? totalCalories = null,Object? totalProteinG = null,Object? totalCarbsG = null,Object? totalFatG = null,Object? byType = null,Object? avgDailyCalories = freezed,Object? recent = null,}) {
  return _then(_NutritionSummary(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,totalCalories: null == totalCalories ? _self.totalCalories : totalCalories // ignore: cast_nullable_to_non_nullable
as double,totalProteinG: null == totalProteinG ? _self.totalProteinG : totalProteinG // ignore: cast_nullable_to_non_nullable
as double,totalCarbsG: null == totalCarbsG ? _self.totalCarbsG : totalCarbsG // ignore: cast_nullable_to_non_nullable
as double,totalFatG: null == totalFatG ? _self.totalFatG : totalFatG // ignore: cast_nullable_to_non_nullable
as double,byType: null == byType ? _self._byType : byType // ignore: cast_nullable_to_non_nullable
as List<ActivityTypeBreakdown>,avgDailyCalories: freezed == avgDailyCalories ? _self.avgDailyCalories : avgDailyCalories // ignore: cast_nullable_to_non_nullable
as double?,recent: null == recent ? _self._recent : recent // ignore: cast_nullable_to_non_nullable
as List<MealRecent>,
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

 String get period; AnalyticsUserInfo get user; WorkoutSummary get workouts; ActivitySummary get activity; NutritionSummary get nutrition; BodySummary get body; LivesSummary get lives; SpendingSummary get spending; ProgrammesSummary get programmes;
/// Create a copy of AnalyticsSummaryData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalyticsSummaryDataCopyWith<AnalyticsSummaryData> get copyWith => _$AnalyticsSummaryDataCopyWithImpl<AnalyticsSummaryData>(this as AnalyticsSummaryData, _$identity);

  /// Serializes this AnalyticsSummaryData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalyticsSummaryData&&(identical(other.period, period) || other.period == period)&&(identical(other.user, user) || other.user == user)&&(identical(other.workouts, workouts) || other.workouts == workouts)&&(identical(other.activity, activity) || other.activity == activity)&&(identical(other.nutrition, nutrition) || other.nutrition == nutrition)&&(identical(other.body, body) || other.body == body)&&(identical(other.lives, lives) || other.lives == lives)&&(identical(other.spending, spending) || other.spending == spending)&&(identical(other.programmes, programmes) || other.programmes == programmes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,period,user,workouts,activity,nutrition,body,lives,spending,programmes);

@override
String toString() {
  return 'AnalyticsSummaryData(period: $period, user: $user, workouts: $workouts, activity: $activity, nutrition: $nutrition, body: $body, lives: $lives, spending: $spending, programmes: $programmes)';
}


}

/// @nodoc
abstract mixin class $AnalyticsSummaryDataCopyWith<$Res>  {
  factory $AnalyticsSummaryDataCopyWith(AnalyticsSummaryData value, $Res Function(AnalyticsSummaryData) _then) = _$AnalyticsSummaryDataCopyWithImpl;
@useResult
$Res call({
 String period, AnalyticsUserInfo user, WorkoutSummary workouts, ActivitySummary activity, NutritionSummary nutrition, BodySummary body, LivesSummary lives, SpendingSummary spending, ProgrammesSummary programmes
});


$AnalyticsUserInfoCopyWith<$Res> get user;$WorkoutSummaryCopyWith<$Res> get workouts;$ActivitySummaryCopyWith<$Res> get activity;$NutritionSummaryCopyWith<$Res> get nutrition;$BodySummaryCopyWith<$Res> get body;$LivesSummaryCopyWith<$Res> get lives;$SpendingSummaryCopyWith<$Res> get spending;$ProgrammesSummaryCopyWith<$Res> get programmes;

}
/// @nodoc
class _$AnalyticsSummaryDataCopyWithImpl<$Res>
    implements $AnalyticsSummaryDataCopyWith<$Res> {
  _$AnalyticsSummaryDataCopyWithImpl(this._self, this._then);

  final AnalyticsSummaryData _self;
  final $Res Function(AnalyticsSummaryData) _then;

/// Create a copy of AnalyticsSummaryData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? period = null,Object? user = null,Object? workouts = null,Object? activity = null,Object? nutrition = null,Object? body = null,Object? lives = null,Object? spending = null,Object? programmes = null,}) {
  return _then(_self.copyWith(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as String,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as AnalyticsUserInfo,workouts: null == workouts ? _self.workouts : workouts // ignore: cast_nullable_to_non_nullable
as WorkoutSummary,activity: null == activity ? _self.activity : activity // ignore: cast_nullable_to_non_nullable
as ActivitySummary,nutrition: null == nutrition ? _self.nutrition : nutrition // ignore: cast_nullable_to_non_nullable
as NutritionSummary,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as BodySummary,lives: null == lives ? _self.lives : lives // ignore: cast_nullable_to_non_nullable
as LivesSummary,spending: null == spending ? _self.spending : spending // ignore: cast_nullable_to_non_nullable
as SpendingSummary,programmes: null == programmes ? _self.programmes : programmes // ignore: cast_nullable_to_non_nullable
as ProgrammesSummary,
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
$NutritionSummaryCopyWith<$Res> get nutrition {
  
  return $NutritionSummaryCopyWith<$Res>(_self.nutrition, (value) {
    return _then(_self.copyWith(nutrition: value));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String period,  AnalyticsUserInfo user,  WorkoutSummary workouts,  ActivitySummary activity,  NutritionSummary nutrition,  BodySummary body,  LivesSummary lives,  SpendingSummary spending,  ProgrammesSummary programmes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalyticsSummaryData() when $default != null:
return $default(_that.period,_that.user,_that.workouts,_that.activity,_that.nutrition,_that.body,_that.lives,_that.spending,_that.programmes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String period,  AnalyticsUserInfo user,  WorkoutSummary workouts,  ActivitySummary activity,  NutritionSummary nutrition,  BodySummary body,  LivesSummary lives,  SpendingSummary spending,  ProgrammesSummary programmes)  $default,) {final _that = this;
switch (_that) {
case _AnalyticsSummaryData():
return $default(_that.period,_that.user,_that.workouts,_that.activity,_that.nutrition,_that.body,_that.lives,_that.spending,_that.programmes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String period,  AnalyticsUserInfo user,  WorkoutSummary workouts,  ActivitySummary activity,  NutritionSummary nutrition,  BodySummary body,  LivesSummary lives,  SpendingSummary spending,  ProgrammesSummary programmes)?  $default,) {final _that = this;
switch (_that) {
case _AnalyticsSummaryData() when $default != null:
return $default(_that.period,_that.user,_that.workouts,_that.activity,_that.nutrition,_that.body,_that.lives,_that.spending,_that.programmes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnalyticsSummaryData implements AnalyticsSummaryData {
  const _AnalyticsSummaryData({this.period = 'all', this.user = const AnalyticsUserInfo(), this.workouts = const WorkoutSummary(), this.activity = const ActivitySummary(), this.nutrition = const NutritionSummary(), this.body = const BodySummary(), this.lives = const LivesSummary(), this.spending = const SpendingSummary(), this.programmes = const ProgrammesSummary()});
  factory _AnalyticsSummaryData.fromJson(Map<String, dynamic> json) => _$AnalyticsSummaryDataFromJson(json);

@override@JsonKey() final  String period;
@override@JsonKey() final  AnalyticsUserInfo user;
@override@JsonKey() final  WorkoutSummary workouts;
@override@JsonKey() final  ActivitySummary activity;
@override@JsonKey() final  NutritionSummary nutrition;
@override@JsonKey() final  BodySummary body;
@override@JsonKey() final  LivesSummary lives;
@override@JsonKey() final  SpendingSummary spending;
@override@JsonKey() final  ProgrammesSummary programmes;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalyticsSummaryData&&(identical(other.period, period) || other.period == period)&&(identical(other.user, user) || other.user == user)&&(identical(other.workouts, workouts) || other.workouts == workouts)&&(identical(other.activity, activity) || other.activity == activity)&&(identical(other.nutrition, nutrition) || other.nutrition == nutrition)&&(identical(other.body, body) || other.body == body)&&(identical(other.lives, lives) || other.lives == lives)&&(identical(other.spending, spending) || other.spending == spending)&&(identical(other.programmes, programmes) || other.programmes == programmes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,period,user,workouts,activity,nutrition,body,lives,spending,programmes);

@override
String toString() {
  return 'AnalyticsSummaryData(period: $period, user: $user, workouts: $workouts, activity: $activity, nutrition: $nutrition, body: $body, lives: $lives, spending: $spending, programmes: $programmes)';
}


}

/// @nodoc
abstract mixin class _$AnalyticsSummaryDataCopyWith<$Res> implements $AnalyticsSummaryDataCopyWith<$Res> {
  factory _$AnalyticsSummaryDataCopyWith(_AnalyticsSummaryData value, $Res Function(_AnalyticsSummaryData) _then) = __$AnalyticsSummaryDataCopyWithImpl;
@override @useResult
$Res call({
 String period, AnalyticsUserInfo user, WorkoutSummary workouts, ActivitySummary activity, NutritionSummary nutrition, BodySummary body, LivesSummary lives, SpendingSummary spending, ProgrammesSummary programmes
});


@override $AnalyticsUserInfoCopyWith<$Res> get user;@override $WorkoutSummaryCopyWith<$Res> get workouts;@override $ActivitySummaryCopyWith<$Res> get activity;@override $NutritionSummaryCopyWith<$Res> get nutrition;@override $BodySummaryCopyWith<$Res> get body;@override $LivesSummaryCopyWith<$Res> get lives;@override $SpendingSummaryCopyWith<$Res> get spending;@override $ProgrammesSummaryCopyWith<$Res> get programmes;

}
/// @nodoc
class __$AnalyticsSummaryDataCopyWithImpl<$Res>
    implements _$AnalyticsSummaryDataCopyWith<$Res> {
  __$AnalyticsSummaryDataCopyWithImpl(this._self, this._then);

  final _AnalyticsSummaryData _self;
  final $Res Function(_AnalyticsSummaryData) _then;

/// Create a copy of AnalyticsSummaryData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? period = null,Object? user = null,Object? workouts = null,Object? activity = null,Object? nutrition = null,Object? body = null,Object? lives = null,Object? spending = null,Object? programmes = null,}) {
  return _then(_AnalyticsSummaryData(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as String,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as AnalyticsUserInfo,workouts: null == workouts ? _self.workouts : workouts // ignore: cast_nullable_to_non_nullable
as WorkoutSummary,activity: null == activity ? _self.activity : activity // ignore: cast_nullable_to_non_nullable
as ActivitySummary,nutrition: null == nutrition ? _self.nutrition : nutrition // ignore: cast_nullable_to_non_nullable
as NutritionSummary,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as BodySummary,lives: null == lives ? _self.lives : lives // ignore: cast_nullable_to_non_nullable
as LivesSummary,spending: null == spending ? _self.spending : spending // ignore: cast_nullable_to_non_nullable
as SpendingSummary,programmes: null == programmes ? _self.programmes : programmes // ignore: cast_nullable_to_non_nullable
as ProgrammesSummary,
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
$NutritionSummaryCopyWith<$Res> get nutrition {
  
  return $NutritionSummaryCopyWith<$Res>(_self.nutrition, (value) {
    return _then(_self.copyWith(nutrition: value));
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
