// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'routine.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Routine {

 String get id; String get type;@JsonKey(name: 'type_label') String get typeLabel;@JsonKey(name: 'custom_name') String get customName;@JsonKey(name: 'display_name') String get displayName; String get name; int get target; String get unit; List<int> get days;@JsonKey(name: 'target_day') int? get targetDay;@JsonKey(name: 'time_of_day') String? get timeOfDay;@JsonKey(name: 'reminder_minutes') List<int> get reminderMinutes; String get activation; String get tracking;@JsonKey(name: 'sort_order') int get sortOrder; int get streak;@JsonKey(name: 'completed_today') bool get completedToday;@JsonKey(name: 'last_checkin_at') String? get lastCheckinAt;@JsonKey(name: 'is_active') bool get isActive;@JsonKey(name: 'checkin_count') int get checkinCount; List<RoutineHighlight> get highlights;@JsonKey(name: 'created_at') String? get createdAt;@JsonKey(name: 'updated_at') String? get updatedAt;
/// Create a copy of Routine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoutineCopyWith<Routine> get copyWith => _$RoutineCopyWithImpl<Routine>(this as Routine, _$identity);

  /// Serializes this Routine to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Routine&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.typeLabel, typeLabel) || other.typeLabel == typeLabel)&&(identical(other.customName, customName) || other.customName == customName)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.name, name) || other.name == name)&&(identical(other.target, target) || other.target == target)&&(identical(other.unit, unit) || other.unit == unit)&&const DeepCollectionEquality().equals(other.days, days)&&(identical(other.targetDay, targetDay) || other.targetDay == targetDay)&&(identical(other.timeOfDay, timeOfDay) || other.timeOfDay == timeOfDay)&&const DeepCollectionEquality().equals(other.reminderMinutes, reminderMinutes)&&(identical(other.activation, activation) || other.activation == activation)&&(identical(other.tracking, tracking) || other.tracking == tracking)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.streak, streak) || other.streak == streak)&&(identical(other.completedToday, completedToday) || other.completedToday == completedToday)&&(identical(other.lastCheckinAt, lastCheckinAt) || other.lastCheckinAt == lastCheckinAt)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.checkinCount, checkinCount) || other.checkinCount == checkinCount)&&const DeepCollectionEquality().equals(other.highlights, highlights)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,type,typeLabel,customName,displayName,name,target,unit,const DeepCollectionEquality().hash(days),targetDay,timeOfDay,const DeepCollectionEquality().hash(reminderMinutes),activation,tracking,sortOrder,streak,completedToday,lastCheckinAt,isActive,checkinCount,const DeepCollectionEquality().hash(highlights),createdAt,updatedAt]);

@override
String toString() {
  return 'Routine(id: $id, type: $type, typeLabel: $typeLabel, customName: $customName, displayName: $displayName, name: $name, target: $target, unit: $unit, days: $days, targetDay: $targetDay, timeOfDay: $timeOfDay, reminderMinutes: $reminderMinutes, activation: $activation, tracking: $tracking, sortOrder: $sortOrder, streak: $streak, completedToday: $completedToday, lastCheckinAt: $lastCheckinAt, isActive: $isActive, checkinCount: $checkinCount, highlights: $highlights, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $RoutineCopyWith<$Res>  {
  factory $RoutineCopyWith(Routine value, $Res Function(Routine) _then) = _$RoutineCopyWithImpl;
@useResult
$Res call({
 String id, String type,@JsonKey(name: 'type_label') String typeLabel,@JsonKey(name: 'custom_name') String customName,@JsonKey(name: 'display_name') String displayName, String name, int target, String unit, List<int> days,@JsonKey(name: 'target_day') int? targetDay,@JsonKey(name: 'time_of_day') String? timeOfDay,@JsonKey(name: 'reminder_minutes') List<int> reminderMinutes, String activation, String tracking,@JsonKey(name: 'sort_order') int sortOrder, int streak,@JsonKey(name: 'completed_today') bool completedToday,@JsonKey(name: 'last_checkin_at') String? lastCheckinAt,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'checkin_count') int checkinCount, List<RoutineHighlight> highlights,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
});




}
/// @nodoc
class _$RoutineCopyWithImpl<$Res>
    implements $RoutineCopyWith<$Res> {
  _$RoutineCopyWithImpl(this._self, this._then);

  final Routine _self;
  final $Res Function(Routine) _then;

/// Create a copy of Routine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? typeLabel = null,Object? customName = null,Object? displayName = null,Object? name = null,Object? target = null,Object? unit = null,Object? days = null,Object? targetDay = freezed,Object? timeOfDay = freezed,Object? reminderMinutes = null,Object? activation = null,Object? tracking = null,Object? sortOrder = null,Object? streak = null,Object? completedToday = null,Object? lastCheckinAt = freezed,Object? isActive = null,Object? checkinCount = null,Object? highlights = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,typeLabel: null == typeLabel ? _self.typeLabel : typeLabel // ignore: cast_nullable_to_non_nullable
as String,customName: null == customName ? _self.customName : customName // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as int,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,days: null == days ? _self.days : days // ignore: cast_nullable_to_non_nullable
as List<int>,targetDay: freezed == targetDay ? _self.targetDay : targetDay // ignore: cast_nullable_to_non_nullable
as int?,timeOfDay: freezed == timeOfDay ? _self.timeOfDay : timeOfDay // ignore: cast_nullable_to_non_nullable
as String?,reminderMinutes: null == reminderMinutes ? _self.reminderMinutes : reminderMinutes // ignore: cast_nullable_to_non_nullable
as List<int>,activation: null == activation ? _self.activation : activation // ignore: cast_nullable_to_non_nullable
as String,tracking: null == tracking ? _self.tracking : tracking // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,streak: null == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as int,completedToday: null == completedToday ? _self.completedToday : completedToday // ignore: cast_nullable_to_non_nullable
as bool,lastCheckinAt: freezed == lastCheckinAt ? _self.lastCheckinAt : lastCheckinAt // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,checkinCount: null == checkinCount ? _self.checkinCount : checkinCount // ignore: cast_nullable_to_non_nullable
as int,highlights: null == highlights ? _self.highlights : highlights // ignore: cast_nullable_to_non_nullable
as List<RoutineHighlight>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Routine].
extension RoutinePatterns on Routine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Routine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Routine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Routine value)  $default,){
final _that = this;
switch (_that) {
case _Routine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Routine value)?  $default,){
final _that = this;
switch (_that) {
case _Routine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String type, @JsonKey(name: 'type_label')  String typeLabel, @JsonKey(name: 'custom_name')  String customName, @JsonKey(name: 'display_name')  String displayName,  String name,  int target,  String unit,  List<int> days, @JsonKey(name: 'target_day')  int? targetDay, @JsonKey(name: 'time_of_day')  String? timeOfDay, @JsonKey(name: 'reminder_minutes')  List<int> reminderMinutes,  String activation,  String tracking, @JsonKey(name: 'sort_order')  int sortOrder,  int streak, @JsonKey(name: 'completed_today')  bool completedToday, @JsonKey(name: 'last_checkin_at')  String? lastCheckinAt, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'checkin_count')  int checkinCount,  List<RoutineHighlight> highlights, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Routine() when $default != null:
return $default(_that.id,_that.type,_that.typeLabel,_that.customName,_that.displayName,_that.name,_that.target,_that.unit,_that.days,_that.targetDay,_that.timeOfDay,_that.reminderMinutes,_that.activation,_that.tracking,_that.sortOrder,_that.streak,_that.completedToday,_that.lastCheckinAt,_that.isActive,_that.checkinCount,_that.highlights,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String type, @JsonKey(name: 'type_label')  String typeLabel, @JsonKey(name: 'custom_name')  String customName, @JsonKey(name: 'display_name')  String displayName,  String name,  int target,  String unit,  List<int> days, @JsonKey(name: 'target_day')  int? targetDay, @JsonKey(name: 'time_of_day')  String? timeOfDay, @JsonKey(name: 'reminder_minutes')  List<int> reminderMinutes,  String activation,  String tracking, @JsonKey(name: 'sort_order')  int sortOrder,  int streak, @JsonKey(name: 'completed_today')  bool completedToday, @JsonKey(name: 'last_checkin_at')  String? lastCheckinAt, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'checkin_count')  int checkinCount,  List<RoutineHighlight> highlights, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Routine():
return $default(_that.id,_that.type,_that.typeLabel,_that.customName,_that.displayName,_that.name,_that.target,_that.unit,_that.days,_that.targetDay,_that.timeOfDay,_that.reminderMinutes,_that.activation,_that.tracking,_that.sortOrder,_that.streak,_that.completedToday,_that.lastCheckinAt,_that.isActive,_that.checkinCount,_that.highlights,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String type, @JsonKey(name: 'type_label')  String typeLabel, @JsonKey(name: 'custom_name')  String customName, @JsonKey(name: 'display_name')  String displayName,  String name,  int target,  String unit,  List<int> days, @JsonKey(name: 'target_day')  int? targetDay, @JsonKey(name: 'time_of_day')  String? timeOfDay, @JsonKey(name: 'reminder_minutes')  List<int> reminderMinutes,  String activation,  String tracking, @JsonKey(name: 'sort_order')  int sortOrder,  int streak, @JsonKey(name: 'completed_today')  bool completedToday, @JsonKey(name: 'last_checkin_at')  String? lastCheckinAt, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'checkin_count')  int checkinCount,  List<RoutineHighlight> highlights, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Routine() when $default != null:
return $default(_that.id,_that.type,_that.typeLabel,_that.customName,_that.displayName,_that.name,_that.target,_that.unit,_that.days,_that.targetDay,_that.timeOfDay,_that.reminderMinutes,_that.activation,_that.tracking,_that.sortOrder,_that.streak,_that.completedToday,_that.lastCheckinAt,_that.isActive,_that.checkinCount,_that.highlights,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Routine implements Routine {
  const _Routine({required this.id, this.type = 'other', @JsonKey(name: 'type_label') this.typeLabel = 'Other', @JsonKey(name: 'custom_name') this.customName = '', @JsonKey(name: 'display_name') this.displayName = '', this.name = '', this.target = 30, this.unit = 'min', final  List<int> days = const <int>[], @JsonKey(name: 'target_day') this.targetDay, @JsonKey(name: 'time_of_day') this.timeOfDay, @JsonKey(name: 'reminder_minutes') final  List<int> reminderMinutes = const <int>[], this.activation = 'week', this.tracking = 'app', @JsonKey(name: 'sort_order') this.sortOrder = 0, this.streak = 0, @JsonKey(name: 'completed_today') this.completedToday = false, @JsonKey(name: 'last_checkin_at') this.lastCheckinAt, @JsonKey(name: 'is_active') this.isActive = true, @JsonKey(name: 'checkin_count') this.checkinCount = 0, final  List<RoutineHighlight> highlights = const <RoutineHighlight>[], @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt}): _days = days,_reminderMinutes = reminderMinutes,_highlights = highlights;
  factory _Routine.fromJson(Map<String, dynamic> json) => _$RoutineFromJson(json);

@override final  String id;
@override@JsonKey() final  String type;
@override@JsonKey(name: 'type_label') final  String typeLabel;
@override@JsonKey(name: 'custom_name') final  String customName;
@override@JsonKey(name: 'display_name') final  String displayName;
@override@JsonKey() final  String name;
@override@JsonKey() final  int target;
@override@JsonKey() final  String unit;
 final  List<int> _days;
@override@JsonKey() List<int> get days {
  if (_days is EqualUnmodifiableListView) return _days;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_days);
}

@override@JsonKey(name: 'target_day') final  int? targetDay;
@override@JsonKey(name: 'time_of_day') final  String? timeOfDay;
 final  List<int> _reminderMinutes;
@override@JsonKey(name: 'reminder_minutes') List<int> get reminderMinutes {
  if (_reminderMinutes is EqualUnmodifiableListView) return _reminderMinutes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reminderMinutes);
}

@override@JsonKey() final  String activation;
@override@JsonKey() final  String tracking;
@override@JsonKey(name: 'sort_order') final  int sortOrder;
@override@JsonKey() final  int streak;
@override@JsonKey(name: 'completed_today') final  bool completedToday;
@override@JsonKey(name: 'last_checkin_at') final  String? lastCheckinAt;
@override@JsonKey(name: 'is_active') final  bool isActive;
@override@JsonKey(name: 'checkin_count') final  int checkinCount;
 final  List<RoutineHighlight> _highlights;
@override@JsonKey() List<RoutineHighlight> get highlights {
  if (_highlights is EqualUnmodifiableListView) return _highlights;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_highlights);
}

@override@JsonKey(name: 'created_at') final  String? createdAt;
@override@JsonKey(name: 'updated_at') final  String? updatedAt;

/// Create a copy of Routine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoutineCopyWith<_Routine> get copyWith => __$RoutineCopyWithImpl<_Routine>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoutineToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Routine&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.typeLabel, typeLabel) || other.typeLabel == typeLabel)&&(identical(other.customName, customName) || other.customName == customName)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.name, name) || other.name == name)&&(identical(other.target, target) || other.target == target)&&(identical(other.unit, unit) || other.unit == unit)&&const DeepCollectionEquality().equals(other._days, _days)&&(identical(other.targetDay, targetDay) || other.targetDay == targetDay)&&(identical(other.timeOfDay, timeOfDay) || other.timeOfDay == timeOfDay)&&const DeepCollectionEquality().equals(other._reminderMinutes, _reminderMinutes)&&(identical(other.activation, activation) || other.activation == activation)&&(identical(other.tracking, tracking) || other.tracking == tracking)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.streak, streak) || other.streak == streak)&&(identical(other.completedToday, completedToday) || other.completedToday == completedToday)&&(identical(other.lastCheckinAt, lastCheckinAt) || other.lastCheckinAt == lastCheckinAt)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.checkinCount, checkinCount) || other.checkinCount == checkinCount)&&const DeepCollectionEquality().equals(other._highlights, _highlights)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,type,typeLabel,customName,displayName,name,target,unit,const DeepCollectionEquality().hash(_days),targetDay,timeOfDay,const DeepCollectionEquality().hash(_reminderMinutes),activation,tracking,sortOrder,streak,completedToday,lastCheckinAt,isActive,checkinCount,const DeepCollectionEquality().hash(_highlights),createdAt,updatedAt]);

@override
String toString() {
  return 'Routine(id: $id, type: $type, typeLabel: $typeLabel, customName: $customName, displayName: $displayName, name: $name, target: $target, unit: $unit, days: $days, targetDay: $targetDay, timeOfDay: $timeOfDay, reminderMinutes: $reminderMinutes, activation: $activation, tracking: $tracking, sortOrder: $sortOrder, streak: $streak, completedToday: $completedToday, lastCheckinAt: $lastCheckinAt, isActive: $isActive, checkinCount: $checkinCount, highlights: $highlights, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$RoutineCopyWith<$Res> implements $RoutineCopyWith<$Res> {
  factory _$RoutineCopyWith(_Routine value, $Res Function(_Routine) _then) = __$RoutineCopyWithImpl;
@override @useResult
$Res call({
 String id, String type,@JsonKey(name: 'type_label') String typeLabel,@JsonKey(name: 'custom_name') String customName,@JsonKey(name: 'display_name') String displayName, String name, int target, String unit, List<int> days,@JsonKey(name: 'target_day') int? targetDay,@JsonKey(name: 'time_of_day') String? timeOfDay,@JsonKey(name: 'reminder_minutes') List<int> reminderMinutes, String activation, String tracking,@JsonKey(name: 'sort_order') int sortOrder, int streak,@JsonKey(name: 'completed_today') bool completedToday,@JsonKey(name: 'last_checkin_at') String? lastCheckinAt,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'checkin_count') int checkinCount, List<RoutineHighlight> highlights,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
});




}
/// @nodoc
class __$RoutineCopyWithImpl<$Res>
    implements _$RoutineCopyWith<$Res> {
  __$RoutineCopyWithImpl(this._self, this._then);

  final _Routine _self;
  final $Res Function(_Routine) _then;

/// Create a copy of Routine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? typeLabel = null,Object? customName = null,Object? displayName = null,Object? name = null,Object? target = null,Object? unit = null,Object? days = null,Object? targetDay = freezed,Object? timeOfDay = freezed,Object? reminderMinutes = null,Object? activation = null,Object? tracking = null,Object? sortOrder = null,Object? streak = null,Object? completedToday = null,Object? lastCheckinAt = freezed,Object? isActive = null,Object? checkinCount = null,Object? highlights = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Routine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,typeLabel: null == typeLabel ? _self.typeLabel : typeLabel // ignore: cast_nullable_to_non_nullable
as String,customName: null == customName ? _self.customName : customName // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as int,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,days: null == days ? _self._days : days // ignore: cast_nullable_to_non_nullable
as List<int>,targetDay: freezed == targetDay ? _self.targetDay : targetDay // ignore: cast_nullable_to_non_nullable
as int?,timeOfDay: freezed == timeOfDay ? _self.timeOfDay : timeOfDay // ignore: cast_nullable_to_non_nullable
as String?,reminderMinutes: null == reminderMinutes ? _self._reminderMinutes : reminderMinutes // ignore: cast_nullable_to_non_nullable
as List<int>,activation: null == activation ? _self.activation : activation // ignore: cast_nullable_to_non_nullable
as String,tracking: null == tracking ? _self.tracking : tracking // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,streak: null == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as int,completedToday: null == completedToday ? _self.completedToday : completedToday // ignore: cast_nullable_to_non_nullable
as bool,lastCheckinAt: freezed == lastCheckinAt ? _self.lastCheckinAt : lastCheckinAt // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,checkinCount: null == checkinCount ? _self.checkinCount : checkinCount // ignore: cast_nullable_to_non_nullable
as int,highlights: null == highlights ? _self._highlights : highlights // ignore: cast_nullable_to_non_nullable
as List<RoutineHighlight>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$RoutineCheckIn {

 String get id; String get routine; int? get value; String get note; String get source;@JsonKey(name: 'occurred_at') String get occurredAt;@JsonKey(name: 'created_at') String? get createdAt;
/// Create a copy of RoutineCheckIn
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoutineCheckInCopyWith<RoutineCheckIn> get copyWith => _$RoutineCheckInCopyWithImpl<RoutineCheckIn>(this as RoutineCheckIn, _$identity);

  /// Serializes this RoutineCheckIn to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoutineCheckIn&&(identical(other.id, id) || other.id == id)&&(identical(other.routine, routine) || other.routine == routine)&&(identical(other.value, value) || other.value == value)&&(identical(other.note, note) || other.note == note)&&(identical(other.source, source) || other.source == source)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,routine,value,note,source,occurredAt,createdAt);

@override
String toString() {
  return 'RoutineCheckIn(id: $id, routine: $routine, value: $value, note: $note, source: $source, occurredAt: $occurredAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $RoutineCheckInCopyWith<$Res>  {
  factory $RoutineCheckInCopyWith(RoutineCheckIn value, $Res Function(RoutineCheckIn) _then) = _$RoutineCheckInCopyWithImpl;
@useResult
$Res call({
 String id, String routine, int? value, String note, String source,@JsonKey(name: 'occurred_at') String occurredAt,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class _$RoutineCheckInCopyWithImpl<$Res>
    implements $RoutineCheckInCopyWith<$Res> {
  _$RoutineCheckInCopyWithImpl(this._self, this._then);

  final RoutineCheckIn _self;
  final $Res Function(RoutineCheckIn) _then;

/// Create a copy of RoutineCheckIn
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? routine = null,Object? value = freezed,Object? note = null,Object? source = null,Object? occurredAt = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,routine: null == routine ? _self.routine : routine // ignore: cast_nullable_to_non_nullable
as String,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int?,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RoutineCheckIn].
extension RoutineCheckInPatterns on RoutineCheckIn {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoutineCheckIn value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoutineCheckIn() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoutineCheckIn value)  $default,){
final _that = this;
switch (_that) {
case _RoutineCheckIn():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoutineCheckIn value)?  $default,){
final _that = this;
switch (_that) {
case _RoutineCheckIn() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String routine,  int? value,  String note,  String source, @JsonKey(name: 'occurred_at')  String occurredAt, @JsonKey(name: 'created_at')  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoutineCheckIn() when $default != null:
return $default(_that.id,_that.routine,_that.value,_that.note,_that.source,_that.occurredAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String routine,  int? value,  String note,  String source, @JsonKey(name: 'occurred_at')  String occurredAt, @JsonKey(name: 'created_at')  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _RoutineCheckIn():
return $default(_that.id,_that.routine,_that.value,_that.note,_that.source,_that.occurredAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String routine,  int? value,  String note,  String source, @JsonKey(name: 'occurred_at')  String occurredAt, @JsonKey(name: 'created_at')  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _RoutineCheckIn() when $default != null:
return $default(_that.id,_that.routine,_that.value,_that.note,_that.source,_that.occurredAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RoutineCheckIn implements RoutineCheckIn {
  const _RoutineCheckIn({required this.id, this.routine = '', this.value = 0, this.note = '', this.source = 'app', @JsonKey(name: 'occurred_at') this.occurredAt = '', @JsonKey(name: 'created_at') this.createdAt});
  factory _RoutineCheckIn.fromJson(Map<String, dynamic> json) => _$RoutineCheckInFromJson(json);

@override final  String id;
@override@JsonKey() final  String routine;
@override@JsonKey() final  int? value;
@override@JsonKey() final  String note;
@override@JsonKey() final  String source;
@override@JsonKey(name: 'occurred_at') final  String occurredAt;
@override@JsonKey(name: 'created_at') final  String? createdAt;

/// Create a copy of RoutineCheckIn
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoutineCheckInCopyWith<_RoutineCheckIn> get copyWith => __$RoutineCheckInCopyWithImpl<_RoutineCheckIn>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoutineCheckInToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoutineCheckIn&&(identical(other.id, id) || other.id == id)&&(identical(other.routine, routine) || other.routine == routine)&&(identical(other.value, value) || other.value == value)&&(identical(other.note, note) || other.note == note)&&(identical(other.source, source) || other.source == source)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,routine,value,note,source,occurredAt,createdAt);

@override
String toString() {
  return 'RoutineCheckIn(id: $id, routine: $routine, value: $value, note: $note, source: $source, occurredAt: $occurredAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$RoutineCheckInCopyWith<$Res> implements $RoutineCheckInCopyWith<$Res> {
  factory _$RoutineCheckInCopyWith(_RoutineCheckIn value, $Res Function(_RoutineCheckIn) _then) = __$RoutineCheckInCopyWithImpl;
@override @useResult
$Res call({
 String id, String routine, int? value, String note, String source,@JsonKey(name: 'occurred_at') String occurredAt,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class __$RoutineCheckInCopyWithImpl<$Res>
    implements _$RoutineCheckInCopyWith<$Res> {
  __$RoutineCheckInCopyWithImpl(this._self, this._then);

  final _RoutineCheckIn _self;
  final $Res Function(_RoutineCheckIn) _then;

/// Create a copy of RoutineCheckIn
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? routine = null,Object? value = freezed,Object? note = null,Object? source = null,Object? occurredAt = null,Object? createdAt = freezed,}) {
  return _then(_RoutineCheckIn(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,routine: null == routine ? _self.routine : routine // ignore: cast_nullable_to_non_nullable
as String,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int?,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$RoutineHighlight {

 String get id; String get routine; String get kind;@JsonKey(name: 'file_url') String get fileUrl;@JsonKey(name: 'thumbnail_url') String get thumbnailUrl; String get caption;@JsonKey(name: 'duration_ms') int? get durationMs;@JsonKey(name: 'created_at') String? get createdAt;
/// Create a copy of RoutineHighlight
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoutineHighlightCopyWith<RoutineHighlight> get copyWith => _$RoutineHighlightCopyWithImpl<RoutineHighlight>(this as RoutineHighlight, _$identity);

  /// Serializes this RoutineHighlight to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoutineHighlight&&(identical(other.id, id) || other.id == id)&&(identical(other.routine, routine) || other.routine == routine)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,routine,kind,fileUrl,thumbnailUrl,caption,durationMs,createdAt);

@override
String toString() {
  return 'RoutineHighlight(id: $id, routine: $routine, kind: $kind, fileUrl: $fileUrl, thumbnailUrl: $thumbnailUrl, caption: $caption, durationMs: $durationMs, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $RoutineHighlightCopyWith<$Res>  {
  factory $RoutineHighlightCopyWith(RoutineHighlight value, $Res Function(RoutineHighlight) _then) = _$RoutineHighlightCopyWithImpl;
@useResult
$Res call({
 String id, String routine, String kind,@JsonKey(name: 'file_url') String fileUrl,@JsonKey(name: 'thumbnail_url') String thumbnailUrl, String caption,@JsonKey(name: 'duration_ms') int? durationMs,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class _$RoutineHighlightCopyWithImpl<$Res>
    implements $RoutineHighlightCopyWith<$Res> {
  _$RoutineHighlightCopyWithImpl(this._self, this._then);

  final RoutineHighlight _self;
  final $Res Function(RoutineHighlight) _then;

/// Create a copy of RoutineHighlight
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? routine = null,Object? kind = null,Object? fileUrl = null,Object? thumbnailUrl = null,Object? caption = null,Object? durationMs = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,routine: null == routine ? _self.routine : routine // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,fileUrl: null == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: null == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String,caption: null == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String,durationMs: freezed == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RoutineHighlight].
extension RoutineHighlightPatterns on RoutineHighlight {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoutineHighlight value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoutineHighlight() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoutineHighlight value)  $default,){
final _that = this;
switch (_that) {
case _RoutineHighlight():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoutineHighlight value)?  $default,){
final _that = this;
switch (_that) {
case _RoutineHighlight() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String routine,  String kind, @JsonKey(name: 'file_url')  String fileUrl, @JsonKey(name: 'thumbnail_url')  String thumbnailUrl,  String caption, @JsonKey(name: 'duration_ms')  int? durationMs, @JsonKey(name: 'created_at')  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoutineHighlight() when $default != null:
return $default(_that.id,_that.routine,_that.kind,_that.fileUrl,_that.thumbnailUrl,_that.caption,_that.durationMs,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String routine,  String kind, @JsonKey(name: 'file_url')  String fileUrl, @JsonKey(name: 'thumbnail_url')  String thumbnailUrl,  String caption, @JsonKey(name: 'duration_ms')  int? durationMs, @JsonKey(name: 'created_at')  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _RoutineHighlight():
return $default(_that.id,_that.routine,_that.kind,_that.fileUrl,_that.thumbnailUrl,_that.caption,_that.durationMs,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String routine,  String kind, @JsonKey(name: 'file_url')  String fileUrl, @JsonKey(name: 'thumbnail_url')  String thumbnailUrl,  String caption, @JsonKey(name: 'duration_ms')  int? durationMs, @JsonKey(name: 'created_at')  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _RoutineHighlight() when $default != null:
return $default(_that.id,_that.routine,_that.kind,_that.fileUrl,_that.thumbnailUrl,_that.caption,_that.durationMs,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RoutineHighlight implements RoutineHighlight {
  const _RoutineHighlight({required this.id, this.routine = '', this.kind = 'photo', @JsonKey(name: 'file_url') this.fileUrl = '', @JsonKey(name: 'thumbnail_url') this.thumbnailUrl = '', this.caption = '', @JsonKey(name: 'duration_ms') this.durationMs, @JsonKey(name: 'created_at') this.createdAt});
  factory _RoutineHighlight.fromJson(Map<String, dynamic> json) => _$RoutineHighlightFromJson(json);

@override final  String id;
@override@JsonKey() final  String routine;
@override@JsonKey() final  String kind;
@override@JsonKey(name: 'file_url') final  String fileUrl;
@override@JsonKey(name: 'thumbnail_url') final  String thumbnailUrl;
@override@JsonKey() final  String caption;
@override@JsonKey(name: 'duration_ms') final  int? durationMs;
@override@JsonKey(name: 'created_at') final  String? createdAt;

/// Create a copy of RoutineHighlight
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoutineHighlightCopyWith<_RoutineHighlight> get copyWith => __$RoutineHighlightCopyWithImpl<_RoutineHighlight>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoutineHighlightToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoutineHighlight&&(identical(other.id, id) || other.id == id)&&(identical(other.routine, routine) || other.routine == routine)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,routine,kind,fileUrl,thumbnailUrl,caption,durationMs,createdAt);

@override
String toString() {
  return 'RoutineHighlight(id: $id, routine: $routine, kind: $kind, fileUrl: $fileUrl, thumbnailUrl: $thumbnailUrl, caption: $caption, durationMs: $durationMs, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$RoutineHighlightCopyWith<$Res> implements $RoutineHighlightCopyWith<$Res> {
  factory _$RoutineHighlightCopyWith(_RoutineHighlight value, $Res Function(_RoutineHighlight) _then) = __$RoutineHighlightCopyWithImpl;
@override @useResult
$Res call({
 String id, String routine, String kind,@JsonKey(name: 'file_url') String fileUrl,@JsonKey(name: 'thumbnail_url') String thumbnailUrl, String caption,@JsonKey(name: 'duration_ms') int? durationMs,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class __$RoutineHighlightCopyWithImpl<$Res>
    implements _$RoutineHighlightCopyWith<$Res> {
  __$RoutineHighlightCopyWithImpl(this._self, this._then);

  final _RoutineHighlight _self;
  final $Res Function(_RoutineHighlight) _then;

/// Create a copy of RoutineHighlight
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? routine = null,Object? kind = null,Object? fileUrl = null,Object? thumbnailUrl = null,Object? caption = null,Object? durationMs = freezed,Object? createdAt = freezed,}) {
  return _then(_RoutineHighlight(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,routine: null == routine ? _self.routine : routine // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,fileUrl: null == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: null == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String,caption: null == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String,durationMs: freezed == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
