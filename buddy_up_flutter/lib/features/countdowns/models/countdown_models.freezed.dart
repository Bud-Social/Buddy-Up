// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'countdown_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CountdownTemplate {

 String get id; String get code; String get title; String get description; String get unit; int get defaultTarget; String get icon; String get color; bool get isActive; int get sortOrder;
/// Create a copy of CountdownTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CountdownTemplateCopyWith<CountdownTemplate> get copyWith => _$CountdownTemplateCopyWithImpl<CountdownTemplate>(this as CountdownTemplate, _$identity);

  /// Serializes this CountdownTemplate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CountdownTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.defaultTarget, defaultTarget) || other.defaultTarget == defaultTarget)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,code,title,description,unit,defaultTarget,icon,color,isActive,sortOrder);

@override
String toString() {
  return 'CountdownTemplate(id: $id, code: $code, title: $title, description: $description, unit: $unit, defaultTarget: $defaultTarget, icon: $icon, color: $color, isActive: $isActive, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class $CountdownTemplateCopyWith<$Res>  {
  factory $CountdownTemplateCopyWith(CountdownTemplate value, $Res Function(CountdownTemplate) _then) = _$CountdownTemplateCopyWithImpl;
@useResult
$Res call({
 String id, String code, String title, String description, String unit, int defaultTarget, String icon, String color, bool isActive, int sortOrder
});




}
/// @nodoc
class _$CountdownTemplateCopyWithImpl<$Res>
    implements $CountdownTemplateCopyWith<$Res> {
  _$CountdownTemplateCopyWithImpl(this._self, this._then);

  final CountdownTemplate _self;
  final $Res Function(CountdownTemplate) _then;

/// Create a copy of CountdownTemplate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? title = null,Object? description = null,Object? unit = null,Object? defaultTarget = null,Object? icon = null,Object? color = null,Object? isActive = null,Object? sortOrder = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,defaultTarget: null == defaultTarget ? _self.defaultTarget : defaultTarget // ignore: cast_nullable_to_non_nullable
as int,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CountdownTemplate].
extension CountdownTemplatePatterns on CountdownTemplate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CountdownTemplate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CountdownTemplate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CountdownTemplate value)  $default,){
final _that = this;
switch (_that) {
case _CountdownTemplate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CountdownTemplate value)?  $default,){
final _that = this;
switch (_that) {
case _CountdownTemplate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String code,  String title,  String description,  String unit,  int defaultTarget,  String icon,  String color,  bool isActive,  int sortOrder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CountdownTemplate() when $default != null:
return $default(_that.id,_that.code,_that.title,_that.description,_that.unit,_that.defaultTarget,_that.icon,_that.color,_that.isActive,_that.sortOrder);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String code,  String title,  String description,  String unit,  int defaultTarget,  String icon,  String color,  bool isActive,  int sortOrder)  $default,) {final _that = this;
switch (_that) {
case _CountdownTemplate():
return $default(_that.id,_that.code,_that.title,_that.description,_that.unit,_that.defaultTarget,_that.icon,_that.color,_that.isActive,_that.sortOrder);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String code,  String title,  String description,  String unit,  int defaultTarget,  String icon,  String color,  bool isActive,  int sortOrder)?  $default,) {final _that = this;
switch (_that) {
case _CountdownTemplate() when $default != null:
return $default(_that.id,_that.code,_that.title,_that.description,_that.unit,_that.defaultTarget,_that.icon,_that.color,_that.isActive,_that.sortOrder);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CountdownTemplate implements CountdownTemplate {
  const _CountdownTemplate({this.id = '', this.code = '', this.title = '', this.description = '', this.unit = 'days', this.defaultTarget = 0, this.icon = '📅', this.color = '#6366f1', this.isActive = true, this.sortOrder = 0});
  factory _CountdownTemplate.fromJson(Map<String, dynamic> json) => _$CountdownTemplateFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String code;
@override@JsonKey() final  String title;
@override@JsonKey() final  String description;
@override@JsonKey() final  String unit;
@override@JsonKey() final  int defaultTarget;
@override@JsonKey() final  String icon;
@override@JsonKey() final  String color;
@override@JsonKey() final  bool isActive;
@override@JsonKey() final  int sortOrder;

/// Create a copy of CountdownTemplate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CountdownTemplateCopyWith<_CountdownTemplate> get copyWith => __$CountdownTemplateCopyWithImpl<_CountdownTemplate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CountdownTemplateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CountdownTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.defaultTarget, defaultTarget) || other.defaultTarget == defaultTarget)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,code,title,description,unit,defaultTarget,icon,color,isActive,sortOrder);

@override
String toString() {
  return 'CountdownTemplate(id: $id, code: $code, title: $title, description: $description, unit: $unit, defaultTarget: $defaultTarget, icon: $icon, color: $color, isActive: $isActive, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class _$CountdownTemplateCopyWith<$Res> implements $CountdownTemplateCopyWith<$Res> {
  factory _$CountdownTemplateCopyWith(_CountdownTemplate value, $Res Function(_CountdownTemplate) _then) = __$CountdownTemplateCopyWithImpl;
@override @useResult
$Res call({
 String id, String code, String title, String description, String unit, int defaultTarget, String icon, String color, bool isActive, int sortOrder
});




}
/// @nodoc
class __$CountdownTemplateCopyWithImpl<$Res>
    implements _$CountdownTemplateCopyWith<$Res> {
  __$CountdownTemplateCopyWithImpl(this._self, this._then);

  final _CountdownTemplate _self;
  final $Res Function(_CountdownTemplate) _then;

/// Create a copy of CountdownTemplate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? title = null,Object? description = null,Object? unit = null,Object? defaultTarget = null,Object? icon = null,Object? color = null,Object? isActive = null,Object? sortOrder = null,}) {
  return _then(_CountdownTemplate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,defaultTarget: null == defaultTarget ? _self.defaultTarget : defaultTarget // ignore: cast_nullable_to_non_nullable
as int,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$UserCountdown {

 String get id; String? get templateId; CountdownTemplate? get templateDetail; String get customReason; String get countdownType; String get unit; int get currentCount; int get targetCount; String get startDate; String? get lastCheckinAt; String? get lastAutoAdvanceAt; String? get autoAdvanceSignal; bool get isActive; String? get completedAt; int get daysSinceStart; String get displayReason; String get displayIcon; String get createdAt; String get updatedAt;
/// Create a copy of UserCountdown
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserCountdownCopyWith<UserCountdown> get copyWith => _$UserCountdownCopyWithImpl<UserCountdown>(this as UserCountdown, _$identity);

  /// Serializes this UserCountdown to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserCountdown&&(identical(other.id, id) || other.id == id)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.templateDetail, templateDetail) || other.templateDetail == templateDetail)&&(identical(other.customReason, customReason) || other.customReason == customReason)&&(identical(other.countdownType, countdownType) || other.countdownType == countdownType)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.currentCount, currentCount) || other.currentCount == currentCount)&&(identical(other.targetCount, targetCount) || other.targetCount == targetCount)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.lastCheckinAt, lastCheckinAt) || other.lastCheckinAt == lastCheckinAt)&&(identical(other.lastAutoAdvanceAt, lastAutoAdvanceAt) || other.lastAutoAdvanceAt == lastAutoAdvanceAt)&&(identical(other.autoAdvanceSignal, autoAdvanceSignal) || other.autoAdvanceSignal == autoAdvanceSignal)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.daysSinceStart, daysSinceStart) || other.daysSinceStart == daysSinceStart)&&(identical(other.displayReason, displayReason) || other.displayReason == displayReason)&&(identical(other.displayIcon, displayIcon) || other.displayIcon == displayIcon)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,templateId,templateDetail,customReason,countdownType,unit,currentCount,targetCount,startDate,lastCheckinAt,lastAutoAdvanceAt,autoAdvanceSignal,isActive,completedAt,daysSinceStart,displayReason,displayIcon,createdAt,updatedAt]);

@override
String toString() {
  return 'UserCountdown(id: $id, templateId: $templateId, templateDetail: $templateDetail, customReason: $customReason, countdownType: $countdownType, unit: $unit, currentCount: $currentCount, targetCount: $targetCount, startDate: $startDate, lastCheckinAt: $lastCheckinAt, lastAutoAdvanceAt: $lastAutoAdvanceAt, autoAdvanceSignal: $autoAdvanceSignal, isActive: $isActive, completedAt: $completedAt, daysSinceStart: $daysSinceStart, displayReason: $displayReason, displayIcon: $displayIcon, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $UserCountdownCopyWith<$Res>  {
  factory $UserCountdownCopyWith(UserCountdown value, $Res Function(UserCountdown) _then) = _$UserCountdownCopyWithImpl;
@useResult
$Res call({
 String id, String? templateId, CountdownTemplate? templateDetail, String customReason, String countdownType, String unit, int currentCount, int targetCount, String startDate, String? lastCheckinAt, String? lastAutoAdvanceAt, String? autoAdvanceSignal, bool isActive, String? completedAt, int daysSinceStart, String displayReason, String displayIcon, String createdAt, String updatedAt
});


$CountdownTemplateCopyWith<$Res>? get templateDetail;

}
/// @nodoc
class _$UserCountdownCopyWithImpl<$Res>
    implements $UserCountdownCopyWith<$Res> {
  _$UserCountdownCopyWithImpl(this._self, this._then);

  final UserCountdown _self;
  final $Res Function(UserCountdown) _then;

/// Create a copy of UserCountdown
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? templateId = freezed,Object? templateDetail = freezed,Object? customReason = null,Object? countdownType = null,Object? unit = null,Object? currentCount = null,Object? targetCount = null,Object? startDate = null,Object? lastCheckinAt = freezed,Object? lastAutoAdvanceAt = freezed,Object? autoAdvanceSignal = freezed,Object? isActive = null,Object? completedAt = freezed,Object? daysSinceStart = null,Object? displayReason = null,Object? displayIcon = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,templateId: freezed == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String?,templateDetail: freezed == templateDetail ? _self.templateDetail : templateDetail // ignore: cast_nullable_to_non_nullable
as CountdownTemplate?,customReason: null == customReason ? _self.customReason : customReason // ignore: cast_nullable_to_non_nullable
as String,countdownType: null == countdownType ? _self.countdownType : countdownType // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,currentCount: null == currentCount ? _self.currentCount : currentCount // ignore: cast_nullable_to_non_nullable
as int,targetCount: null == targetCount ? _self.targetCount : targetCount // ignore: cast_nullable_to_non_nullable
as int,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String,lastCheckinAt: freezed == lastCheckinAt ? _self.lastCheckinAt : lastCheckinAt // ignore: cast_nullable_to_non_nullable
as String?,lastAutoAdvanceAt: freezed == lastAutoAdvanceAt ? _self.lastAutoAdvanceAt : lastAutoAdvanceAt // ignore: cast_nullable_to_non_nullable
as String?,autoAdvanceSignal: freezed == autoAdvanceSignal ? _self.autoAdvanceSignal : autoAdvanceSignal // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as String?,daysSinceStart: null == daysSinceStart ? _self.daysSinceStart : daysSinceStart // ignore: cast_nullable_to_non_nullable
as int,displayReason: null == displayReason ? _self.displayReason : displayReason // ignore: cast_nullable_to_non_nullable
as String,displayIcon: null == displayIcon ? _self.displayIcon : displayIcon // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of UserCountdown
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CountdownTemplateCopyWith<$Res>? get templateDetail {
    if (_self.templateDetail == null) {
    return null;
  }

  return $CountdownTemplateCopyWith<$Res>(_self.templateDetail!, (value) {
    return _then(_self.copyWith(templateDetail: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserCountdown].
extension UserCountdownPatterns on UserCountdown {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserCountdown value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserCountdown() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserCountdown value)  $default,){
final _that = this;
switch (_that) {
case _UserCountdown():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserCountdown value)?  $default,){
final _that = this;
switch (_that) {
case _UserCountdown() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? templateId,  CountdownTemplate? templateDetail,  String customReason,  String countdownType,  String unit,  int currentCount,  int targetCount,  String startDate,  String? lastCheckinAt,  String? lastAutoAdvanceAt,  String? autoAdvanceSignal,  bool isActive,  String? completedAt,  int daysSinceStart,  String displayReason,  String displayIcon,  String createdAt,  String updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserCountdown() when $default != null:
return $default(_that.id,_that.templateId,_that.templateDetail,_that.customReason,_that.countdownType,_that.unit,_that.currentCount,_that.targetCount,_that.startDate,_that.lastCheckinAt,_that.lastAutoAdvanceAt,_that.autoAdvanceSignal,_that.isActive,_that.completedAt,_that.daysSinceStart,_that.displayReason,_that.displayIcon,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? templateId,  CountdownTemplate? templateDetail,  String customReason,  String countdownType,  String unit,  int currentCount,  int targetCount,  String startDate,  String? lastCheckinAt,  String? lastAutoAdvanceAt,  String? autoAdvanceSignal,  bool isActive,  String? completedAt,  int daysSinceStart,  String displayReason,  String displayIcon,  String createdAt,  String updatedAt)  $default,) {final _that = this;
switch (_that) {
case _UserCountdown():
return $default(_that.id,_that.templateId,_that.templateDetail,_that.customReason,_that.countdownType,_that.unit,_that.currentCount,_that.targetCount,_that.startDate,_that.lastCheckinAt,_that.lastAutoAdvanceAt,_that.autoAdvanceSignal,_that.isActive,_that.completedAt,_that.daysSinceStart,_that.displayReason,_that.displayIcon,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? templateId,  CountdownTemplate? templateDetail,  String customReason,  String countdownType,  String unit,  int currentCount,  int targetCount,  String startDate,  String? lastCheckinAt,  String? lastAutoAdvanceAt,  String? autoAdvanceSignal,  bool isActive,  String? completedAt,  int daysSinceStart,  String displayReason,  String displayIcon,  String createdAt,  String updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _UserCountdown() when $default != null:
return $default(_that.id,_that.templateId,_that.templateDetail,_that.customReason,_that.countdownType,_that.unit,_that.currentCount,_that.targetCount,_that.startDate,_that.lastCheckinAt,_that.lastAutoAdvanceAt,_that.autoAdvanceSignal,_that.isActive,_that.completedAt,_that.daysSinceStart,_that.displayReason,_that.displayIcon,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserCountdown implements UserCountdown {
  const _UserCountdown({this.id = '', this.templateId = null, this.templateDetail = null, this.customReason = '', this.countdownType = 'manual', this.unit = 'days', this.currentCount = 0, this.targetCount = 0, this.startDate = '', this.lastCheckinAt = null, this.lastAutoAdvanceAt = null, this.autoAdvanceSignal = null, this.isActive = true, this.completedAt = null, this.daysSinceStart = 0, this.displayReason = '', this.displayIcon = '📅', this.createdAt = '', this.updatedAt = ''});
  factory _UserCountdown.fromJson(Map<String, dynamic> json) => _$UserCountdownFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String? templateId;
@override@JsonKey() final  CountdownTemplate? templateDetail;
@override@JsonKey() final  String customReason;
@override@JsonKey() final  String countdownType;
@override@JsonKey() final  String unit;
@override@JsonKey() final  int currentCount;
@override@JsonKey() final  int targetCount;
@override@JsonKey() final  String startDate;
@override@JsonKey() final  String? lastCheckinAt;
@override@JsonKey() final  String? lastAutoAdvanceAt;
@override@JsonKey() final  String? autoAdvanceSignal;
@override@JsonKey() final  bool isActive;
@override@JsonKey() final  String? completedAt;
@override@JsonKey() final  int daysSinceStart;
@override@JsonKey() final  String displayReason;
@override@JsonKey() final  String displayIcon;
@override@JsonKey() final  String createdAt;
@override@JsonKey() final  String updatedAt;

/// Create a copy of UserCountdown
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserCountdownCopyWith<_UserCountdown> get copyWith => __$UserCountdownCopyWithImpl<_UserCountdown>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserCountdownToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserCountdown&&(identical(other.id, id) || other.id == id)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.templateDetail, templateDetail) || other.templateDetail == templateDetail)&&(identical(other.customReason, customReason) || other.customReason == customReason)&&(identical(other.countdownType, countdownType) || other.countdownType == countdownType)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.currentCount, currentCount) || other.currentCount == currentCount)&&(identical(other.targetCount, targetCount) || other.targetCount == targetCount)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.lastCheckinAt, lastCheckinAt) || other.lastCheckinAt == lastCheckinAt)&&(identical(other.lastAutoAdvanceAt, lastAutoAdvanceAt) || other.lastAutoAdvanceAt == lastAutoAdvanceAt)&&(identical(other.autoAdvanceSignal, autoAdvanceSignal) || other.autoAdvanceSignal == autoAdvanceSignal)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.daysSinceStart, daysSinceStart) || other.daysSinceStart == daysSinceStart)&&(identical(other.displayReason, displayReason) || other.displayReason == displayReason)&&(identical(other.displayIcon, displayIcon) || other.displayIcon == displayIcon)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,templateId,templateDetail,customReason,countdownType,unit,currentCount,targetCount,startDate,lastCheckinAt,lastAutoAdvanceAt,autoAdvanceSignal,isActive,completedAt,daysSinceStart,displayReason,displayIcon,createdAt,updatedAt]);

@override
String toString() {
  return 'UserCountdown(id: $id, templateId: $templateId, templateDetail: $templateDetail, customReason: $customReason, countdownType: $countdownType, unit: $unit, currentCount: $currentCount, targetCount: $targetCount, startDate: $startDate, lastCheckinAt: $lastCheckinAt, lastAutoAdvanceAt: $lastAutoAdvanceAt, autoAdvanceSignal: $autoAdvanceSignal, isActive: $isActive, completedAt: $completedAt, daysSinceStart: $daysSinceStart, displayReason: $displayReason, displayIcon: $displayIcon, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$UserCountdownCopyWith<$Res> implements $UserCountdownCopyWith<$Res> {
  factory _$UserCountdownCopyWith(_UserCountdown value, $Res Function(_UserCountdown) _then) = __$UserCountdownCopyWithImpl;
@override @useResult
$Res call({
 String id, String? templateId, CountdownTemplate? templateDetail, String customReason, String countdownType, String unit, int currentCount, int targetCount, String startDate, String? lastCheckinAt, String? lastAutoAdvanceAt, String? autoAdvanceSignal, bool isActive, String? completedAt, int daysSinceStart, String displayReason, String displayIcon, String createdAt, String updatedAt
});


@override $CountdownTemplateCopyWith<$Res>? get templateDetail;

}
/// @nodoc
class __$UserCountdownCopyWithImpl<$Res>
    implements _$UserCountdownCopyWith<$Res> {
  __$UserCountdownCopyWithImpl(this._self, this._then);

  final _UserCountdown _self;
  final $Res Function(_UserCountdown) _then;

/// Create a copy of UserCountdown
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? templateId = freezed,Object? templateDetail = freezed,Object? customReason = null,Object? countdownType = null,Object? unit = null,Object? currentCount = null,Object? targetCount = null,Object? startDate = null,Object? lastCheckinAt = freezed,Object? lastAutoAdvanceAt = freezed,Object? autoAdvanceSignal = freezed,Object? isActive = null,Object? completedAt = freezed,Object? daysSinceStart = null,Object? displayReason = null,Object? displayIcon = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_UserCountdown(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,templateId: freezed == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String?,templateDetail: freezed == templateDetail ? _self.templateDetail : templateDetail // ignore: cast_nullable_to_non_nullable
as CountdownTemplate?,customReason: null == customReason ? _self.customReason : customReason // ignore: cast_nullable_to_non_nullable
as String,countdownType: null == countdownType ? _self.countdownType : countdownType // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,currentCount: null == currentCount ? _self.currentCount : currentCount // ignore: cast_nullable_to_non_nullable
as int,targetCount: null == targetCount ? _self.targetCount : targetCount // ignore: cast_nullable_to_non_nullable
as int,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String,lastCheckinAt: freezed == lastCheckinAt ? _self.lastCheckinAt : lastCheckinAt // ignore: cast_nullable_to_non_nullable
as String?,lastAutoAdvanceAt: freezed == lastAutoAdvanceAt ? _self.lastAutoAdvanceAt : lastAutoAdvanceAt // ignore: cast_nullable_to_non_nullable
as String?,autoAdvanceSignal: freezed == autoAdvanceSignal ? _self.autoAdvanceSignal : autoAdvanceSignal // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as String?,daysSinceStart: null == daysSinceStart ? _self.daysSinceStart : daysSinceStart // ignore: cast_nullable_to_non_nullable
as int,displayReason: null == displayReason ? _self.displayReason : displayReason // ignore: cast_nullable_to_non_nullable
as String,displayIcon: null == displayIcon ? _self.displayIcon : displayIcon // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of UserCountdown
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CountdownTemplateCopyWith<$Res>? get templateDetail {
    if (_self.templateDetail == null) {
    return null;
  }

  return $CountdownTemplateCopyWith<$Res>(_self.templateDetail!, (value) {
    return _then(_self.copyWith(templateDetail: value));
  });
}
}


/// @nodoc
mixin _$CreateUserCountdown {

 String? get templateId; String? get customReason; String get countdownType; String get unit; int get targetCount; String? get startDate;
/// Create a copy of CreateUserCountdown
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateUserCountdownCopyWith<CreateUserCountdown> get copyWith => _$CreateUserCountdownCopyWithImpl<CreateUserCountdown>(this as CreateUserCountdown, _$identity);

  /// Serializes this CreateUserCountdown to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateUserCountdown&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.customReason, customReason) || other.customReason == customReason)&&(identical(other.countdownType, countdownType) || other.countdownType == countdownType)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.targetCount, targetCount) || other.targetCount == targetCount)&&(identical(other.startDate, startDate) || other.startDate == startDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,templateId,customReason,countdownType,unit,targetCount,startDate);

@override
String toString() {
  return 'CreateUserCountdown(templateId: $templateId, customReason: $customReason, countdownType: $countdownType, unit: $unit, targetCount: $targetCount, startDate: $startDate)';
}


}

/// @nodoc
abstract mixin class $CreateUserCountdownCopyWith<$Res>  {
  factory $CreateUserCountdownCopyWith(CreateUserCountdown value, $Res Function(CreateUserCountdown) _then) = _$CreateUserCountdownCopyWithImpl;
@useResult
$Res call({
 String? templateId, String? customReason, String countdownType, String unit, int targetCount, String? startDate
});




}
/// @nodoc
class _$CreateUserCountdownCopyWithImpl<$Res>
    implements $CreateUserCountdownCopyWith<$Res> {
  _$CreateUserCountdownCopyWithImpl(this._self, this._then);

  final CreateUserCountdown _self;
  final $Res Function(CreateUserCountdown) _then;

/// Create a copy of CreateUserCountdown
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? templateId = freezed,Object? customReason = freezed,Object? countdownType = null,Object? unit = null,Object? targetCount = null,Object? startDate = freezed,}) {
  return _then(_self.copyWith(
templateId: freezed == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String?,customReason: freezed == customReason ? _self.customReason : customReason // ignore: cast_nullable_to_non_nullable
as String?,countdownType: null == countdownType ? _self.countdownType : countdownType // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,targetCount: null == targetCount ? _self.targetCount : targetCount // ignore: cast_nullable_to_non_nullable
as int,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateUserCountdown].
extension CreateUserCountdownPatterns on CreateUserCountdown {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateUserCountdown value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateUserCountdown() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateUserCountdown value)  $default,){
final _that = this;
switch (_that) {
case _CreateUserCountdown():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateUserCountdown value)?  $default,){
final _that = this;
switch (_that) {
case _CreateUserCountdown() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? templateId,  String? customReason,  String countdownType,  String unit,  int targetCount,  String? startDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateUserCountdown() when $default != null:
return $default(_that.templateId,_that.customReason,_that.countdownType,_that.unit,_that.targetCount,_that.startDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? templateId,  String? customReason,  String countdownType,  String unit,  int targetCount,  String? startDate)  $default,) {final _that = this;
switch (_that) {
case _CreateUserCountdown():
return $default(_that.templateId,_that.customReason,_that.countdownType,_that.unit,_that.targetCount,_that.startDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? templateId,  String? customReason,  String countdownType,  String unit,  int targetCount,  String? startDate)?  $default,) {final _that = this;
switch (_that) {
case _CreateUserCountdown() when $default != null:
return $default(_that.templateId,_that.customReason,_that.countdownType,_that.unit,_that.targetCount,_that.startDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateUserCountdown implements CreateUserCountdown {
  const _CreateUserCountdown({this.templateId = null, this.customReason = null, this.countdownType = 'manual', this.unit = 'days', this.targetCount = 0, this.startDate = null});
  factory _CreateUserCountdown.fromJson(Map<String, dynamic> json) => _$CreateUserCountdownFromJson(json);

@override@JsonKey() final  String? templateId;
@override@JsonKey() final  String? customReason;
@override@JsonKey() final  String countdownType;
@override@JsonKey() final  String unit;
@override@JsonKey() final  int targetCount;
@override@JsonKey() final  String? startDate;

/// Create a copy of CreateUserCountdown
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateUserCountdownCopyWith<_CreateUserCountdown> get copyWith => __$CreateUserCountdownCopyWithImpl<_CreateUserCountdown>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateUserCountdownToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateUserCountdown&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.customReason, customReason) || other.customReason == customReason)&&(identical(other.countdownType, countdownType) || other.countdownType == countdownType)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.targetCount, targetCount) || other.targetCount == targetCount)&&(identical(other.startDate, startDate) || other.startDate == startDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,templateId,customReason,countdownType,unit,targetCount,startDate);

@override
String toString() {
  return 'CreateUserCountdown(templateId: $templateId, customReason: $customReason, countdownType: $countdownType, unit: $unit, targetCount: $targetCount, startDate: $startDate)';
}


}

/// @nodoc
abstract mixin class _$CreateUserCountdownCopyWith<$Res> implements $CreateUserCountdownCopyWith<$Res> {
  factory _$CreateUserCountdownCopyWith(_CreateUserCountdown value, $Res Function(_CreateUserCountdown) _then) = __$CreateUserCountdownCopyWithImpl;
@override @useResult
$Res call({
 String? templateId, String? customReason, String countdownType, String unit, int targetCount, String? startDate
});




}
/// @nodoc
class __$CreateUserCountdownCopyWithImpl<$Res>
    implements _$CreateUserCountdownCopyWith<$Res> {
  __$CreateUserCountdownCopyWithImpl(this._self, this._then);

  final _CreateUserCountdown _self;
  final $Res Function(_CreateUserCountdown) _then;

/// Create a copy of CreateUserCountdown
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? templateId = freezed,Object? customReason = freezed,Object? countdownType = null,Object? unit = null,Object? targetCount = null,Object? startDate = freezed,}) {
  return _then(_CreateUserCountdown(
templateId: freezed == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String?,customReason: freezed == customReason ? _self.customReason : customReason // ignore: cast_nullable_to_non_nullable
as String?,countdownType: null == countdownType ? _self.countdownType : countdownType // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,targetCount: null == targetCount ? _self.targetCount : targetCount // ignore: cast_nullable_to_non_nullable
as int,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$UpdateUserCountdown {

 String? get customReason; String? get countdownType; String? get unit; int? get targetCount; String? get startDate; bool? get isActive;
/// Create a copy of UpdateUserCountdown
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateUserCountdownCopyWith<UpdateUserCountdown> get copyWith => _$UpdateUserCountdownCopyWithImpl<UpdateUserCountdown>(this as UpdateUserCountdown, _$identity);

  /// Serializes this UpdateUserCountdown to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateUserCountdown&&(identical(other.customReason, customReason) || other.customReason == customReason)&&(identical(other.countdownType, countdownType) || other.countdownType == countdownType)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.targetCount, targetCount) || other.targetCount == targetCount)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,customReason,countdownType,unit,targetCount,startDate,isActive);

@override
String toString() {
  return 'UpdateUserCountdown(customReason: $customReason, countdownType: $countdownType, unit: $unit, targetCount: $targetCount, startDate: $startDate, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class $UpdateUserCountdownCopyWith<$Res>  {
  factory $UpdateUserCountdownCopyWith(UpdateUserCountdown value, $Res Function(UpdateUserCountdown) _then) = _$UpdateUserCountdownCopyWithImpl;
@useResult
$Res call({
 String? customReason, String? countdownType, String? unit, int? targetCount, String? startDate, bool? isActive
});




}
/// @nodoc
class _$UpdateUserCountdownCopyWithImpl<$Res>
    implements $UpdateUserCountdownCopyWith<$Res> {
  _$UpdateUserCountdownCopyWithImpl(this._self, this._then);

  final UpdateUserCountdown _self;
  final $Res Function(UpdateUserCountdown) _then;

/// Create a copy of UpdateUserCountdown
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? customReason = freezed,Object? countdownType = freezed,Object? unit = freezed,Object? targetCount = freezed,Object? startDate = freezed,Object? isActive = freezed,}) {
  return _then(_self.copyWith(
customReason: freezed == customReason ? _self.customReason : customReason // ignore: cast_nullable_to_non_nullable
as String?,countdownType: freezed == countdownType ? _self.countdownType : countdownType // ignore: cast_nullable_to_non_nullable
as String?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,targetCount: freezed == targetCount ? _self.targetCount : targetCount // ignore: cast_nullable_to_non_nullable
as int?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String?,isActive: freezed == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateUserCountdown].
extension UpdateUserCountdownPatterns on UpdateUserCountdown {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateUserCountdown value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateUserCountdown() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateUserCountdown value)  $default,){
final _that = this;
switch (_that) {
case _UpdateUserCountdown():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateUserCountdown value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateUserCountdown() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? customReason,  String? countdownType,  String? unit,  int? targetCount,  String? startDate,  bool? isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateUserCountdown() when $default != null:
return $default(_that.customReason,_that.countdownType,_that.unit,_that.targetCount,_that.startDate,_that.isActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? customReason,  String? countdownType,  String? unit,  int? targetCount,  String? startDate,  bool? isActive)  $default,) {final _that = this;
switch (_that) {
case _UpdateUserCountdown():
return $default(_that.customReason,_that.countdownType,_that.unit,_that.targetCount,_that.startDate,_that.isActive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? customReason,  String? countdownType,  String? unit,  int? targetCount,  String? startDate,  bool? isActive)?  $default,) {final _that = this;
switch (_that) {
case _UpdateUserCountdown() when $default != null:
return $default(_that.customReason,_that.countdownType,_that.unit,_that.targetCount,_that.startDate,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateUserCountdown implements UpdateUserCountdown {
  const _UpdateUserCountdown({this.customReason = null, this.countdownType = null, this.unit = null, this.targetCount = null, this.startDate = null, this.isActive = null});
  factory _UpdateUserCountdown.fromJson(Map<String, dynamic> json) => _$UpdateUserCountdownFromJson(json);

@override@JsonKey() final  String? customReason;
@override@JsonKey() final  String? countdownType;
@override@JsonKey() final  String? unit;
@override@JsonKey() final  int? targetCount;
@override@JsonKey() final  String? startDate;
@override@JsonKey() final  bool? isActive;

/// Create a copy of UpdateUserCountdown
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateUserCountdownCopyWith<_UpdateUserCountdown> get copyWith => __$UpdateUserCountdownCopyWithImpl<_UpdateUserCountdown>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateUserCountdownToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateUserCountdown&&(identical(other.customReason, customReason) || other.customReason == customReason)&&(identical(other.countdownType, countdownType) || other.countdownType == countdownType)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.targetCount, targetCount) || other.targetCount == targetCount)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,customReason,countdownType,unit,targetCount,startDate,isActive);

@override
String toString() {
  return 'UpdateUserCountdown(customReason: $customReason, countdownType: $countdownType, unit: $unit, targetCount: $targetCount, startDate: $startDate, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$UpdateUserCountdownCopyWith<$Res> implements $UpdateUserCountdownCopyWith<$Res> {
  factory _$UpdateUserCountdownCopyWith(_UpdateUserCountdown value, $Res Function(_UpdateUserCountdown) _then) = __$UpdateUserCountdownCopyWithImpl;
@override @useResult
$Res call({
 String? customReason, String? countdownType, String? unit, int? targetCount, String? startDate, bool? isActive
});




}
/// @nodoc
class __$UpdateUserCountdownCopyWithImpl<$Res>
    implements _$UpdateUserCountdownCopyWith<$Res> {
  __$UpdateUserCountdownCopyWithImpl(this._self, this._then);

  final _UpdateUserCountdown _self;
  final $Res Function(_UpdateUserCountdown) _then;

/// Create a copy of UpdateUserCountdown
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? customReason = freezed,Object? countdownType = freezed,Object? unit = freezed,Object? targetCount = freezed,Object? startDate = freezed,Object? isActive = freezed,}) {
  return _then(_UpdateUserCountdown(
customReason: freezed == customReason ? _self.customReason : customReason // ignore: cast_nullable_to_non_nullable
as String?,countdownType: freezed == countdownType ? _self.countdownType : countdownType // ignore: cast_nullable_to_non_nullable
as String?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,targetCount: freezed == targetCount ? _self.targetCount : targetCount // ignore: cast_nullable_to_non_nullable
as int?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String?,isActive: freezed == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
