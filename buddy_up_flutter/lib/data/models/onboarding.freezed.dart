// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OnboardingPayload {

 List<String> get primaryGoal; String get activityLevel; List<String> get preferredWorkouts; String get dietaryPreference; String get preferredTime; String? get discoverySource;
/// Create a copy of OnboardingPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnboardingPayloadCopyWith<OnboardingPayload> get copyWith => _$OnboardingPayloadCopyWithImpl<OnboardingPayload>(this as OnboardingPayload, _$identity);

  /// Serializes this OnboardingPayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingPayload&&const DeepCollectionEquality().equals(other.primaryGoal, primaryGoal)&&(identical(other.activityLevel, activityLevel) || other.activityLevel == activityLevel)&&const DeepCollectionEquality().equals(other.preferredWorkouts, preferredWorkouts)&&(identical(other.dietaryPreference, dietaryPreference) || other.dietaryPreference == dietaryPreference)&&(identical(other.preferredTime, preferredTime) || other.preferredTime == preferredTime)&&(identical(other.discoverySource, discoverySource) || other.discoverySource == discoverySource));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(primaryGoal),activityLevel,const DeepCollectionEquality().hash(preferredWorkouts),dietaryPreference,preferredTime,discoverySource);

@override
String toString() {
  return 'OnboardingPayload(primaryGoal: $primaryGoal, activityLevel: $activityLevel, preferredWorkouts: $preferredWorkouts, dietaryPreference: $dietaryPreference, preferredTime: $preferredTime, discoverySource: $discoverySource)';
}


}

/// @nodoc
abstract mixin class $OnboardingPayloadCopyWith<$Res>  {
  factory $OnboardingPayloadCopyWith(OnboardingPayload value, $Res Function(OnboardingPayload) _then) = _$OnboardingPayloadCopyWithImpl;
@useResult
$Res call({
 List<String> primaryGoal, String activityLevel, List<String> preferredWorkouts, String dietaryPreference, String preferredTime, String? discoverySource
});




}
/// @nodoc
class _$OnboardingPayloadCopyWithImpl<$Res>
    implements $OnboardingPayloadCopyWith<$Res> {
  _$OnboardingPayloadCopyWithImpl(this._self, this._then);

  final OnboardingPayload _self;
  final $Res Function(OnboardingPayload) _then;

/// Create a copy of OnboardingPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? primaryGoal = null,Object? activityLevel = null,Object? preferredWorkouts = null,Object? dietaryPreference = null,Object? preferredTime = null,Object? discoverySource = freezed,}) {
  return _then(_self.copyWith(
primaryGoal: null == primaryGoal ? _self.primaryGoal : primaryGoal // ignore: cast_nullable_to_non_nullable
as List<String>,activityLevel: null == activityLevel ? _self.activityLevel : activityLevel // ignore: cast_nullable_to_non_nullable
as String,preferredWorkouts: null == preferredWorkouts ? _self.preferredWorkouts : preferredWorkouts // ignore: cast_nullable_to_non_nullable
as List<String>,dietaryPreference: null == dietaryPreference ? _self.dietaryPreference : dietaryPreference // ignore: cast_nullable_to_non_nullable
as String,preferredTime: null == preferredTime ? _self.preferredTime : preferredTime // ignore: cast_nullable_to_non_nullable
as String,discoverySource: freezed == discoverySource ? _self.discoverySource : discoverySource // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OnboardingPayload].
extension OnboardingPayloadPatterns on OnboardingPayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OnboardingPayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OnboardingPayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OnboardingPayload value)  $default,){
final _that = this;
switch (_that) {
case _OnboardingPayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OnboardingPayload value)?  $default,){
final _that = this;
switch (_that) {
case _OnboardingPayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> primaryGoal,  String activityLevel,  List<String> preferredWorkouts,  String dietaryPreference,  String preferredTime,  String? discoverySource)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OnboardingPayload() when $default != null:
return $default(_that.primaryGoal,_that.activityLevel,_that.preferredWorkouts,_that.dietaryPreference,_that.preferredTime,_that.discoverySource);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> primaryGoal,  String activityLevel,  List<String> preferredWorkouts,  String dietaryPreference,  String preferredTime,  String? discoverySource)  $default,) {final _that = this;
switch (_that) {
case _OnboardingPayload():
return $default(_that.primaryGoal,_that.activityLevel,_that.preferredWorkouts,_that.dietaryPreference,_that.preferredTime,_that.discoverySource);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> primaryGoal,  String activityLevel,  List<String> preferredWorkouts,  String dietaryPreference,  String preferredTime,  String? discoverySource)?  $default,) {final _that = this;
switch (_that) {
case _OnboardingPayload() when $default != null:
return $default(_that.primaryGoal,_that.activityLevel,_that.preferredWorkouts,_that.dietaryPreference,_that.preferredTime,_that.discoverySource);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OnboardingPayload implements OnboardingPayload {
  const _OnboardingPayload({required final  List<String> primaryGoal, required this.activityLevel, required final  List<String> preferredWorkouts, required this.dietaryPreference, required this.preferredTime, this.discoverySource}): _primaryGoal = primaryGoal,_preferredWorkouts = preferredWorkouts;
  factory _OnboardingPayload.fromJson(Map<String, dynamic> json) => _$OnboardingPayloadFromJson(json);

 final  List<String> _primaryGoal;
@override List<String> get primaryGoal {
  if (_primaryGoal is EqualUnmodifiableListView) return _primaryGoal;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_primaryGoal);
}

@override final  String activityLevel;
 final  List<String> _preferredWorkouts;
@override List<String> get preferredWorkouts {
  if (_preferredWorkouts is EqualUnmodifiableListView) return _preferredWorkouts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_preferredWorkouts);
}

@override final  String dietaryPreference;
@override final  String preferredTime;
@override final  String? discoverySource;

/// Create a copy of OnboardingPayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnboardingPayloadCopyWith<_OnboardingPayload> get copyWith => __$OnboardingPayloadCopyWithImpl<_OnboardingPayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OnboardingPayloadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnboardingPayload&&const DeepCollectionEquality().equals(other._primaryGoal, _primaryGoal)&&(identical(other.activityLevel, activityLevel) || other.activityLevel == activityLevel)&&const DeepCollectionEquality().equals(other._preferredWorkouts, _preferredWorkouts)&&(identical(other.dietaryPreference, dietaryPreference) || other.dietaryPreference == dietaryPreference)&&(identical(other.preferredTime, preferredTime) || other.preferredTime == preferredTime)&&(identical(other.discoverySource, discoverySource) || other.discoverySource == discoverySource));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_primaryGoal),activityLevel,const DeepCollectionEquality().hash(_preferredWorkouts),dietaryPreference,preferredTime,discoverySource);

@override
String toString() {
  return 'OnboardingPayload(primaryGoal: $primaryGoal, activityLevel: $activityLevel, preferredWorkouts: $preferredWorkouts, dietaryPreference: $dietaryPreference, preferredTime: $preferredTime, discoverySource: $discoverySource)';
}


}

/// @nodoc
abstract mixin class _$OnboardingPayloadCopyWith<$Res> implements $OnboardingPayloadCopyWith<$Res> {
  factory _$OnboardingPayloadCopyWith(_OnboardingPayload value, $Res Function(_OnboardingPayload) _then) = __$OnboardingPayloadCopyWithImpl;
@override @useResult
$Res call({
 List<String> primaryGoal, String activityLevel, List<String> preferredWorkouts, String dietaryPreference, String preferredTime, String? discoverySource
});




}
/// @nodoc
class __$OnboardingPayloadCopyWithImpl<$Res>
    implements _$OnboardingPayloadCopyWith<$Res> {
  __$OnboardingPayloadCopyWithImpl(this._self, this._then);

  final _OnboardingPayload _self;
  final $Res Function(_OnboardingPayload) _then;

/// Create a copy of OnboardingPayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? primaryGoal = null,Object? activityLevel = null,Object? preferredWorkouts = null,Object? dietaryPreference = null,Object? preferredTime = null,Object? discoverySource = freezed,}) {
  return _then(_OnboardingPayload(
primaryGoal: null == primaryGoal ? _self._primaryGoal : primaryGoal // ignore: cast_nullable_to_non_nullable
as List<String>,activityLevel: null == activityLevel ? _self.activityLevel : activityLevel // ignore: cast_nullable_to_non_nullable
as String,preferredWorkouts: null == preferredWorkouts ? _self._preferredWorkouts : preferredWorkouts // ignore: cast_nullable_to_non_nullable
as List<String>,dietaryPreference: null == dietaryPreference ? _self.dietaryPreference : dietaryPreference // ignore: cast_nullable_to_non_nullable
as String,preferredTime: null == preferredTime ? _self.preferredTime : preferredTime // ignore: cast_nullable_to_non_nullable
as String,discoverySource: freezed == discoverySource ? _self.discoverySource : discoverySource // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$OnboardingData {

 List<String> get primaryGoal; String get activityLevel; List<String> get preferredWorkouts; String get dietaryPreference; String get preferredTime; String? get discoverySource;
/// Create a copy of OnboardingData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnboardingDataCopyWith<OnboardingData> get copyWith => _$OnboardingDataCopyWithImpl<OnboardingData>(this as OnboardingData, _$identity);

  /// Serializes this OnboardingData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingData&&const DeepCollectionEquality().equals(other.primaryGoal, primaryGoal)&&(identical(other.activityLevel, activityLevel) || other.activityLevel == activityLevel)&&const DeepCollectionEquality().equals(other.preferredWorkouts, preferredWorkouts)&&(identical(other.dietaryPreference, dietaryPreference) || other.dietaryPreference == dietaryPreference)&&(identical(other.preferredTime, preferredTime) || other.preferredTime == preferredTime)&&(identical(other.discoverySource, discoverySource) || other.discoverySource == discoverySource));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(primaryGoal),activityLevel,const DeepCollectionEquality().hash(preferredWorkouts),dietaryPreference,preferredTime,discoverySource);

@override
String toString() {
  return 'OnboardingData(primaryGoal: $primaryGoal, activityLevel: $activityLevel, preferredWorkouts: $preferredWorkouts, dietaryPreference: $dietaryPreference, preferredTime: $preferredTime, discoverySource: $discoverySource)';
}


}

/// @nodoc
abstract mixin class $OnboardingDataCopyWith<$Res>  {
  factory $OnboardingDataCopyWith(OnboardingData value, $Res Function(OnboardingData) _then) = _$OnboardingDataCopyWithImpl;
@useResult
$Res call({
 List<String> primaryGoal, String activityLevel, List<String> preferredWorkouts, String dietaryPreference, String preferredTime, String? discoverySource
});




}
/// @nodoc
class _$OnboardingDataCopyWithImpl<$Res>
    implements $OnboardingDataCopyWith<$Res> {
  _$OnboardingDataCopyWithImpl(this._self, this._then);

  final OnboardingData _self;
  final $Res Function(OnboardingData) _then;

/// Create a copy of OnboardingData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? primaryGoal = null,Object? activityLevel = null,Object? preferredWorkouts = null,Object? dietaryPreference = null,Object? preferredTime = null,Object? discoverySource = freezed,}) {
  return _then(_self.copyWith(
primaryGoal: null == primaryGoal ? _self.primaryGoal : primaryGoal // ignore: cast_nullable_to_non_nullable
as List<String>,activityLevel: null == activityLevel ? _self.activityLevel : activityLevel // ignore: cast_nullable_to_non_nullable
as String,preferredWorkouts: null == preferredWorkouts ? _self.preferredWorkouts : preferredWorkouts // ignore: cast_nullable_to_non_nullable
as List<String>,dietaryPreference: null == dietaryPreference ? _self.dietaryPreference : dietaryPreference // ignore: cast_nullable_to_non_nullable
as String,preferredTime: null == preferredTime ? _self.preferredTime : preferredTime // ignore: cast_nullable_to_non_nullable
as String,discoverySource: freezed == discoverySource ? _self.discoverySource : discoverySource // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OnboardingData].
extension OnboardingDataPatterns on OnboardingData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OnboardingData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OnboardingData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OnboardingData value)  $default,){
final _that = this;
switch (_that) {
case _OnboardingData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OnboardingData value)?  $default,){
final _that = this;
switch (_that) {
case _OnboardingData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> primaryGoal,  String activityLevel,  List<String> preferredWorkouts,  String dietaryPreference,  String preferredTime,  String? discoverySource)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OnboardingData() when $default != null:
return $default(_that.primaryGoal,_that.activityLevel,_that.preferredWorkouts,_that.dietaryPreference,_that.preferredTime,_that.discoverySource);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> primaryGoal,  String activityLevel,  List<String> preferredWorkouts,  String dietaryPreference,  String preferredTime,  String? discoverySource)  $default,) {final _that = this;
switch (_that) {
case _OnboardingData():
return $default(_that.primaryGoal,_that.activityLevel,_that.preferredWorkouts,_that.dietaryPreference,_that.preferredTime,_that.discoverySource);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> primaryGoal,  String activityLevel,  List<String> preferredWorkouts,  String dietaryPreference,  String preferredTime,  String? discoverySource)?  $default,) {final _that = this;
switch (_that) {
case _OnboardingData() when $default != null:
return $default(_that.primaryGoal,_that.activityLevel,_that.preferredWorkouts,_that.dietaryPreference,_that.preferredTime,_that.discoverySource);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OnboardingData implements OnboardingData {
  const _OnboardingData({required final  List<String> primaryGoal, required this.activityLevel, required final  List<String> preferredWorkouts, required this.dietaryPreference, required this.preferredTime, this.discoverySource}): _primaryGoal = primaryGoal,_preferredWorkouts = preferredWorkouts;
  factory _OnboardingData.fromJson(Map<String, dynamic> json) => _$OnboardingDataFromJson(json);

 final  List<String> _primaryGoal;
@override List<String> get primaryGoal {
  if (_primaryGoal is EqualUnmodifiableListView) return _primaryGoal;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_primaryGoal);
}

@override final  String activityLevel;
 final  List<String> _preferredWorkouts;
@override List<String> get preferredWorkouts {
  if (_preferredWorkouts is EqualUnmodifiableListView) return _preferredWorkouts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_preferredWorkouts);
}

@override final  String dietaryPreference;
@override final  String preferredTime;
@override final  String? discoverySource;

/// Create a copy of OnboardingData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnboardingDataCopyWith<_OnboardingData> get copyWith => __$OnboardingDataCopyWithImpl<_OnboardingData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OnboardingDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnboardingData&&const DeepCollectionEquality().equals(other._primaryGoal, _primaryGoal)&&(identical(other.activityLevel, activityLevel) || other.activityLevel == activityLevel)&&const DeepCollectionEquality().equals(other._preferredWorkouts, _preferredWorkouts)&&(identical(other.dietaryPreference, dietaryPreference) || other.dietaryPreference == dietaryPreference)&&(identical(other.preferredTime, preferredTime) || other.preferredTime == preferredTime)&&(identical(other.discoverySource, discoverySource) || other.discoverySource == discoverySource));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_primaryGoal),activityLevel,const DeepCollectionEquality().hash(_preferredWorkouts),dietaryPreference,preferredTime,discoverySource);

@override
String toString() {
  return 'OnboardingData(primaryGoal: $primaryGoal, activityLevel: $activityLevel, preferredWorkouts: $preferredWorkouts, dietaryPreference: $dietaryPreference, preferredTime: $preferredTime, discoverySource: $discoverySource)';
}


}

/// @nodoc
abstract mixin class _$OnboardingDataCopyWith<$Res> implements $OnboardingDataCopyWith<$Res> {
  factory _$OnboardingDataCopyWith(_OnboardingData value, $Res Function(_OnboardingData) _then) = __$OnboardingDataCopyWithImpl;
@override @useResult
$Res call({
 List<String> primaryGoal, String activityLevel, List<String> preferredWorkouts, String dietaryPreference, String preferredTime, String? discoverySource
});




}
/// @nodoc
class __$OnboardingDataCopyWithImpl<$Res>
    implements _$OnboardingDataCopyWith<$Res> {
  __$OnboardingDataCopyWithImpl(this._self, this._then);

  final _OnboardingData _self;
  final $Res Function(_OnboardingData) _then;

/// Create a copy of OnboardingData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? primaryGoal = null,Object? activityLevel = null,Object? preferredWorkouts = null,Object? dietaryPreference = null,Object? preferredTime = null,Object? discoverySource = freezed,}) {
  return _then(_OnboardingData(
primaryGoal: null == primaryGoal ? _self._primaryGoal : primaryGoal // ignore: cast_nullable_to_non_nullable
as List<String>,activityLevel: null == activityLevel ? _self.activityLevel : activityLevel // ignore: cast_nullable_to_non_nullable
as String,preferredWorkouts: null == preferredWorkouts ? _self._preferredWorkouts : preferredWorkouts // ignore: cast_nullable_to_non_nullable
as List<String>,dietaryPreference: null == dietaryPreference ? _self.dietaryPreference : dietaryPreference // ignore: cast_nullable_to_non_nullable
as String,preferredTime: null == preferredTime ? _self.preferredTime : preferredTime // ignore: cast_nullable_to_non_nullable
as String,discoverySource: freezed == discoverySource ? _self.discoverySource : discoverySource // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$OnboardingPlan {

 String get primaryGoal; List<String> get recommendedTrainerSpecialties; List<String> get recommendedGymCategories; SuggestedWorkoutPlan? get suggestedWorkoutPlan; String? get activityLevelAdvice; String? get timePreferenceAdvice; String? get buddyMatchingHint; String? get mealPlanRecommendation; List<String>? get recommendedDietaryTags;
/// Create a copy of OnboardingPlan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnboardingPlanCopyWith<OnboardingPlan> get copyWith => _$OnboardingPlanCopyWithImpl<OnboardingPlan>(this as OnboardingPlan, _$identity);

  /// Serializes this OnboardingPlan to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingPlan&&(identical(other.primaryGoal, primaryGoal) || other.primaryGoal == primaryGoal)&&const DeepCollectionEquality().equals(other.recommendedTrainerSpecialties, recommendedTrainerSpecialties)&&const DeepCollectionEquality().equals(other.recommendedGymCategories, recommendedGymCategories)&&(identical(other.suggestedWorkoutPlan, suggestedWorkoutPlan) || other.suggestedWorkoutPlan == suggestedWorkoutPlan)&&(identical(other.activityLevelAdvice, activityLevelAdvice) || other.activityLevelAdvice == activityLevelAdvice)&&(identical(other.timePreferenceAdvice, timePreferenceAdvice) || other.timePreferenceAdvice == timePreferenceAdvice)&&(identical(other.buddyMatchingHint, buddyMatchingHint) || other.buddyMatchingHint == buddyMatchingHint)&&(identical(other.mealPlanRecommendation, mealPlanRecommendation) || other.mealPlanRecommendation == mealPlanRecommendation)&&const DeepCollectionEquality().equals(other.recommendedDietaryTags, recommendedDietaryTags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,primaryGoal,const DeepCollectionEquality().hash(recommendedTrainerSpecialties),const DeepCollectionEquality().hash(recommendedGymCategories),suggestedWorkoutPlan,activityLevelAdvice,timePreferenceAdvice,buddyMatchingHint,mealPlanRecommendation,const DeepCollectionEquality().hash(recommendedDietaryTags));

@override
String toString() {
  return 'OnboardingPlan(primaryGoal: $primaryGoal, recommendedTrainerSpecialties: $recommendedTrainerSpecialties, recommendedGymCategories: $recommendedGymCategories, suggestedWorkoutPlan: $suggestedWorkoutPlan, activityLevelAdvice: $activityLevelAdvice, timePreferenceAdvice: $timePreferenceAdvice, buddyMatchingHint: $buddyMatchingHint, mealPlanRecommendation: $mealPlanRecommendation, recommendedDietaryTags: $recommendedDietaryTags)';
}


}

/// @nodoc
abstract mixin class $OnboardingPlanCopyWith<$Res>  {
  factory $OnboardingPlanCopyWith(OnboardingPlan value, $Res Function(OnboardingPlan) _then) = _$OnboardingPlanCopyWithImpl;
@useResult
$Res call({
 String primaryGoal, List<String> recommendedTrainerSpecialties, List<String> recommendedGymCategories, SuggestedWorkoutPlan? suggestedWorkoutPlan, String? activityLevelAdvice, String? timePreferenceAdvice, String? buddyMatchingHint, String? mealPlanRecommendation, List<String>? recommendedDietaryTags
});


$SuggestedWorkoutPlanCopyWith<$Res>? get suggestedWorkoutPlan;

}
/// @nodoc
class _$OnboardingPlanCopyWithImpl<$Res>
    implements $OnboardingPlanCopyWith<$Res> {
  _$OnboardingPlanCopyWithImpl(this._self, this._then);

  final OnboardingPlan _self;
  final $Res Function(OnboardingPlan) _then;

/// Create a copy of OnboardingPlan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? primaryGoal = null,Object? recommendedTrainerSpecialties = null,Object? recommendedGymCategories = null,Object? suggestedWorkoutPlan = freezed,Object? activityLevelAdvice = freezed,Object? timePreferenceAdvice = freezed,Object? buddyMatchingHint = freezed,Object? mealPlanRecommendation = freezed,Object? recommendedDietaryTags = freezed,}) {
  return _then(_self.copyWith(
primaryGoal: null == primaryGoal ? _self.primaryGoal : primaryGoal // ignore: cast_nullable_to_non_nullable
as String,recommendedTrainerSpecialties: null == recommendedTrainerSpecialties ? _self.recommendedTrainerSpecialties : recommendedTrainerSpecialties // ignore: cast_nullable_to_non_nullable
as List<String>,recommendedGymCategories: null == recommendedGymCategories ? _self.recommendedGymCategories : recommendedGymCategories // ignore: cast_nullable_to_non_nullable
as List<String>,suggestedWorkoutPlan: freezed == suggestedWorkoutPlan ? _self.suggestedWorkoutPlan : suggestedWorkoutPlan // ignore: cast_nullable_to_non_nullable
as SuggestedWorkoutPlan?,activityLevelAdvice: freezed == activityLevelAdvice ? _self.activityLevelAdvice : activityLevelAdvice // ignore: cast_nullable_to_non_nullable
as String?,timePreferenceAdvice: freezed == timePreferenceAdvice ? _self.timePreferenceAdvice : timePreferenceAdvice // ignore: cast_nullable_to_non_nullable
as String?,buddyMatchingHint: freezed == buddyMatchingHint ? _self.buddyMatchingHint : buddyMatchingHint // ignore: cast_nullable_to_non_nullable
as String?,mealPlanRecommendation: freezed == mealPlanRecommendation ? _self.mealPlanRecommendation : mealPlanRecommendation // ignore: cast_nullable_to_non_nullable
as String?,recommendedDietaryTags: freezed == recommendedDietaryTags ? _self.recommendedDietaryTags : recommendedDietaryTags // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}
/// Create a copy of OnboardingPlan
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SuggestedWorkoutPlanCopyWith<$Res>? get suggestedWorkoutPlan {
    if (_self.suggestedWorkoutPlan == null) {
    return null;
  }

  return $SuggestedWorkoutPlanCopyWith<$Res>(_self.suggestedWorkoutPlan!, (value) {
    return _then(_self.copyWith(suggestedWorkoutPlan: value));
  });
}
}


/// Adds pattern-matching-related methods to [OnboardingPlan].
extension OnboardingPlanPatterns on OnboardingPlan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OnboardingPlan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OnboardingPlan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OnboardingPlan value)  $default,){
final _that = this;
switch (_that) {
case _OnboardingPlan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OnboardingPlan value)?  $default,){
final _that = this;
switch (_that) {
case _OnboardingPlan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String primaryGoal,  List<String> recommendedTrainerSpecialties,  List<String> recommendedGymCategories,  SuggestedWorkoutPlan? suggestedWorkoutPlan,  String? activityLevelAdvice,  String? timePreferenceAdvice,  String? buddyMatchingHint,  String? mealPlanRecommendation,  List<String>? recommendedDietaryTags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OnboardingPlan() when $default != null:
return $default(_that.primaryGoal,_that.recommendedTrainerSpecialties,_that.recommendedGymCategories,_that.suggestedWorkoutPlan,_that.activityLevelAdvice,_that.timePreferenceAdvice,_that.buddyMatchingHint,_that.mealPlanRecommendation,_that.recommendedDietaryTags);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String primaryGoal,  List<String> recommendedTrainerSpecialties,  List<String> recommendedGymCategories,  SuggestedWorkoutPlan? suggestedWorkoutPlan,  String? activityLevelAdvice,  String? timePreferenceAdvice,  String? buddyMatchingHint,  String? mealPlanRecommendation,  List<String>? recommendedDietaryTags)  $default,) {final _that = this;
switch (_that) {
case _OnboardingPlan():
return $default(_that.primaryGoal,_that.recommendedTrainerSpecialties,_that.recommendedGymCategories,_that.suggestedWorkoutPlan,_that.activityLevelAdvice,_that.timePreferenceAdvice,_that.buddyMatchingHint,_that.mealPlanRecommendation,_that.recommendedDietaryTags);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String primaryGoal,  List<String> recommendedTrainerSpecialties,  List<String> recommendedGymCategories,  SuggestedWorkoutPlan? suggestedWorkoutPlan,  String? activityLevelAdvice,  String? timePreferenceAdvice,  String? buddyMatchingHint,  String? mealPlanRecommendation,  List<String>? recommendedDietaryTags)?  $default,) {final _that = this;
switch (_that) {
case _OnboardingPlan() when $default != null:
return $default(_that.primaryGoal,_that.recommendedTrainerSpecialties,_that.recommendedGymCategories,_that.suggestedWorkoutPlan,_that.activityLevelAdvice,_that.timePreferenceAdvice,_that.buddyMatchingHint,_that.mealPlanRecommendation,_that.recommendedDietaryTags);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OnboardingPlan implements OnboardingPlan {
  const _OnboardingPlan({required this.primaryGoal, required final  List<String> recommendedTrainerSpecialties, required final  List<String> recommendedGymCategories, this.suggestedWorkoutPlan, this.activityLevelAdvice, this.timePreferenceAdvice, this.buddyMatchingHint, this.mealPlanRecommendation, final  List<String>? recommendedDietaryTags}): _recommendedTrainerSpecialties = recommendedTrainerSpecialties,_recommendedGymCategories = recommendedGymCategories,_recommendedDietaryTags = recommendedDietaryTags;
  factory _OnboardingPlan.fromJson(Map<String, dynamic> json) => _$OnboardingPlanFromJson(json);

@override final  String primaryGoal;
 final  List<String> _recommendedTrainerSpecialties;
@override List<String> get recommendedTrainerSpecialties {
  if (_recommendedTrainerSpecialties is EqualUnmodifiableListView) return _recommendedTrainerSpecialties;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recommendedTrainerSpecialties);
}

 final  List<String> _recommendedGymCategories;
@override List<String> get recommendedGymCategories {
  if (_recommendedGymCategories is EqualUnmodifiableListView) return _recommendedGymCategories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recommendedGymCategories);
}

@override final  SuggestedWorkoutPlan? suggestedWorkoutPlan;
@override final  String? activityLevelAdvice;
@override final  String? timePreferenceAdvice;
@override final  String? buddyMatchingHint;
@override final  String? mealPlanRecommendation;
 final  List<String>? _recommendedDietaryTags;
@override List<String>? get recommendedDietaryTags {
  final value = _recommendedDietaryTags;
  if (value == null) return null;
  if (_recommendedDietaryTags is EqualUnmodifiableListView) return _recommendedDietaryTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of OnboardingPlan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnboardingPlanCopyWith<_OnboardingPlan> get copyWith => __$OnboardingPlanCopyWithImpl<_OnboardingPlan>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OnboardingPlanToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnboardingPlan&&(identical(other.primaryGoal, primaryGoal) || other.primaryGoal == primaryGoal)&&const DeepCollectionEquality().equals(other._recommendedTrainerSpecialties, _recommendedTrainerSpecialties)&&const DeepCollectionEquality().equals(other._recommendedGymCategories, _recommendedGymCategories)&&(identical(other.suggestedWorkoutPlan, suggestedWorkoutPlan) || other.suggestedWorkoutPlan == suggestedWorkoutPlan)&&(identical(other.activityLevelAdvice, activityLevelAdvice) || other.activityLevelAdvice == activityLevelAdvice)&&(identical(other.timePreferenceAdvice, timePreferenceAdvice) || other.timePreferenceAdvice == timePreferenceAdvice)&&(identical(other.buddyMatchingHint, buddyMatchingHint) || other.buddyMatchingHint == buddyMatchingHint)&&(identical(other.mealPlanRecommendation, mealPlanRecommendation) || other.mealPlanRecommendation == mealPlanRecommendation)&&const DeepCollectionEquality().equals(other._recommendedDietaryTags, _recommendedDietaryTags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,primaryGoal,const DeepCollectionEquality().hash(_recommendedTrainerSpecialties),const DeepCollectionEquality().hash(_recommendedGymCategories),suggestedWorkoutPlan,activityLevelAdvice,timePreferenceAdvice,buddyMatchingHint,mealPlanRecommendation,const DeepCollectionEquality().hash(_recommendedDietaryTags));

@override
String toString() {
  return 'OnboardingPlan(primaryGoal: $primaryGoal, recommendedTrainerSpecialties: $recommendedTrainerSpecialties, recommendedGymCategories: $recommendedGymCategories, suggestedWorkoutPlan: $suggestedWorkoutPlan, activityLevelAdvice: $activityLevelAdvice, timePreferenceAdvice: $timePreferenceAdvice, buddyMatchingHint: $buddyMatchingHint, mealPlanRecommendation: $mealPlanRecommendation, recommendedDietaryTags: $recommendedDietaryTags)';
}


}

/// @nodoc
abstract mixin class _$OnboardingPlanCopyWith<$Res> implements $OnboardingPlanCopyWith<$Res> {
  factory _$OnboardingPlanCopyWith(_OnboardingPlan value, $Res Function(_OnboardingPlan) _then) = __$OnboardingPlanCopyWithImpl;
@override @useResult
$Res call({
 String primaryGoal, List<String> recommendedTrainerSpecialties, List<String> recommendedGymCategories, SuggestedWorkoutPlan? suggestedWorkoutPlan, String? activityLevelAdvice, String? timePreferenceAdvice, String? buddyMatchingHint, String? mealPlanRecommendation, List<String>? recommendedDietaryTags
});


@override $SuggestedWorkoutPlanCopyWith<$Res>? get suggestedWorkoutPlan;

}
/// @nodoc
class __$OnboardingPlanCopyWithImpl<$Res>
    implements _$OnboardingPlanCopyWith<$Res> {
  __$OnboardingPlanCopyWithImpl(this._self, this._then);

  final _OnboardingPlan _self;
  final $Res Function(_OnboardingPlan) _then;

/// Create a copy of OnboardingPlan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? primaryGoal = null,Object? recommendedTrainerSpecialties = null,Object? recommendedGymCategories = null,Object? suggestedWorkoutPlan = freezed,Object? activityLevelAdvice = freezed,Object? timePreferenceAdvice = freezed,Object? buddyMatchingHint = freezed,Object? mealPlanRecommendation = freezed,Object? recommendedDietaryTags = freezed,}) {
  return _then(_OnboardingPlan(
primaryGoal: null == primaryGoal ? _self.primaryGoal : primaryGoal // ignore: cast_nullable_to_non_nullable
as String,recommendedTrainerSpecialties: null == recommendedTrainerSpecialties ? _self._recommendedTrainerSpecialties : recommendedTrainerSpecialties // ignore: cast_nullable_to_non_nullable
as List<String>,recommendedGymCategories: null == recommendedGymCategories ? _self._recommendedGymCategories : recommendedGymCategories // ignore: cast_nullable_to_non_nullable
as List<String>,suggestedWorkoutPlan: freezed == suggestedWorkoutPlan ? _self.suggestedWorkoutPlan : suggestedWorkoutPlan // ignore: cast_nullable_to_non_nullable
as SuggestedWorkoutPlan?,activityLevelAdvice: freezed == activityLevelAdvice ? _self.activityLevelAdvice : activityLevelAdvice // ignore: cast_nullable_to_non_nullable
as String?,timePreferenceAdvice: freezed == timePreferenceAdvice ? _self.timePreferenceAdvice : timePreferenceAdvice // ignore: cast_nullable_to_non_nullable
as String?,buddyMatchingHint: freezed == buddyMatchingHint ? _self.buddyMatchingHint : buddyMatchingHint // ignore: cast_nullable_to_non_nullable
as String?,mealPlanRecommendation: freezed == mealPlanRecommendation ? _self.mealPlanRecommendation : mealPlanRecommendation // ignore: cast_nullable_to_non_nullable
as String?,recommendedDietaryTags: freezed == recommendedDietaryTags ? _self._recommendedDietaryTags : recommendedDietaryTags // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

/// Create a copy of OnboardingPlan
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SuggestedWorkoutPlanCopyWith<$Res>? get suggestedWorkoutPlan {
    if (_self.suggestedWorkoutPlan == null) {
    return null;
  }

  return $SuggestedWorkoutPlanCopyWith<$Res>(_self.suggestedWorkoutPlan!, (value) {
    return _then(_self.copyWith(suggestedWorkoutPlan: value));
  });
}
}


/// @nodoc
mixin _$SuggestedWorkoutPlan {

 String get frequency; String get focus; List<String> get sampleSplit;
/// Create a copy of SuggestedWorkoutPlan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SuggestedWorkoutPlanCopyWith<SuggestedWorkoutPlan> get copyWith => _$SuggestedWorkoutPlanCopyWithImpl<SuggestedWorkoutPlan>(this as SuggestedWorkoutPlan, _$identity);

  /// Serializes this SuggestedWorkoutPlan to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SuggestedWorkoutPlan&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.focus, focus) || other.focus == focus)&&const DeepCollectionEquality().equals(other.sampleSplit, sampleSplit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,frequency,focus,const DeepCollectionEquality().hash(sampleSplit));

@override
String toString() {
  return 'SuggestedWorkoutPlan(frequency: $frequency, focus: $focus, sampleSplit: $sampleSplit)';
}


}

/// @nodoc
abstract mixin class $SuggestedWorkoutPlanCopyWith<$Res>  {
  factory $SuggestedWorkoutPlanCopyWith(SuggestedWorkoutPlan value, $Res Function(SuggestedWorkoutPlan) _then) = _$SuggestedWorkoutPlanCopyWithImpl;
@useResult
$Res call({
 String frequency, String focus, List<String> sampleSplit
});




}
/// @nodoc
class _$SuggestedWorkoutPlanCopyWithImpl<$Res>
    implements $SuggestedWorkoutPlanCopyWith<$Res> {
  _$SuggestedWorkoutPlanCopyWithImpl(this._self, this._then);

  final SuggestedWorkoutPlan _self;
  final $Res Function(SuggestedWorkoutPlan) _then;

/// Create a copy of SuggestedWorkoutPlan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? frequency = null,Object? focus = null,Object? sampleSplit = null,}) {
  return _then(_self.copyWith(
frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as String,focus: null == focus ? _self.focus : focus // ignore: cast_nullable_to_non_nullable
as String,sampleSplit: null == sampleSplit ? _self.sampleSplit : sampleSplit // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [SuggestedWorkoutPlan].
extension SuggestedWorkoutPlanPatterns on SuggestedWorkoutPlan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SuggestedWorkoutPlan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SuggestedWorkoutPlan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SuggestedWorkoutPlan value)  $default,){
final _that = this;
switch (_that) {
case _SuggestedWorkoutPlan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SuggestedWorkoutPlan value)?  $default,){
final _that = this;
switch (_that) {
case _SuggestedWorkoutPlan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String frequency,  String focus,  List<String> sampleSplit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SuggestedWorkoutPlan() when $default != null:
return $default(_that.frequency,_that.focus,_that.sampleSplit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String frequency,  String focus,  List<String> sampleSplit)  $default,) {final _that = this;
switch (_that) {
case _SuggestedWorkoutPlan():
return $default(_that.frequency,_that.focus,_that.sampleSplit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String frequency,  String focus,  List<String> sampleSplit)?  $default,) {final _that = this;
switch (_that) {
case _SuggestedWorkoutPlan() when $default != null:
return $default(_that.frequency,_that.focus,_that.sampleSplit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SuggestedWorkoutPlan implements SuggestedWorkoutPlan {
  const _SuggestedWorkoutPlan({required this.frequency, required this.focus, required final  List<String> sampleSplit}): _sampleSplit = sampleSplit;
  factory _SuggestedWorkoutPlan.fromJson(Map<String, dynamic> json) => _$SuggestedWorkoutPlanFromJson(json);

@override final  String frequency;
@override final  String focus;
 final  List<String> _sampleSplit;
@override List<String> get sampleSplit {
  if (_sampleSplit is EqualUnmodifiableListView) return _sampleSplit;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sampleSplit);
}


/// Create a copy of SuggestedWorkoutPlan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SuggestedWorkoutPlanCopyWith<_SuggestedWorkoutPlan> get copyWith => __$SuggestedWorkoutPlanCopyWithImpl<_SuggestedWorkoutPlan>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SuggestedWorkoutPlanToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SuggestedWorkoutPlan&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.focus, focus) || other.focus == focus)&&const DeepCollectionEquality().equals(other._sampleSplit, _sampleSplit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,frequency,focus,const DeepCollectionEquality().hash(_sampleSplit));

@override
String toString() {
  return 'SuggestedWorkoutPlan(frequency: $frequency, focus: $focus, sampleSplit: $sampleSplit)';
}


}

/// @nodoc
abstract mixin class _$SuggestedWorkoutPlanCopyWith<$Res> implements $SuggestedWorkoutPlanCopyWith<$Res> {
  factory _$SuggestedWorkoutPlanCopyWith(_SuggestedWorkoutPlan value, $Res Function(_SuggestedWorkoutPlan) _then) = __$SuggestedWorkoutPlanCopyWithImpl;
@override @useResult
$Res call({
 String frequency, String focus, List<String> sampleSplit
});




}
/// @nodoc
class __$SuggestedWorkoutPlanCopyWithImpl<$Res>
    implements _$SuggestedWorkoutPlanCopyWith<$Res> {
  __$SuggestedWorkoutPlanCopyWithImpl(this._self, this._then);

  final _SuggestedWorkoutPlan _self;
  final $Res Function(_SuggestedWorkoutPlan) _then;

/// Create a copy of SuggestedWorkoutPlan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? frequency = null,Object? focus = null,Object? sampleSplit = null,}) {
  return _then(_SuggestedWorkoutPlan(
frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as String,focus: null == focus ? _self.focus : focus // ignore: cast_nullable_to_non_nullable
as String,sampleSplit: null == sampleSplit ? _self._sampleSplit : sampleSplit // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
