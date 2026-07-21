// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrainerProfile {

 String get username;@JsonKey(name: 'display_name') String get displayName;@JsonKey(name: 'avatar_url') String get avatarUrl;@JsonKey(name: 'bio') String get bio;@JsonKey(name: 'specialties') List<String> get specialties;@JsonKey(name: 'experience_years') int get experienceYears;@JsonKey(name: 'certifications') List<String> get certifications;@JsonKey(name: 'average_rating') double get averageRating;@JsonKey(name: 'review_count') int get reviewCount;@JsonKey(name: 'session_count') int get sessionCount;@JsonKey(name: 'hourly_rate') double get hourlyRate;@JsonKey(name: 'currency') String get currency;@JsonKey(name: 'location') String get location;@JsonKey(name: 'is_available') bool get isAvailable;
/// Create a copy of TrainerProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrainerProfileCopyWith<TrainerProfile> get copyWith => _$TrainerProfileCopyWithImpl<TrainerProfile>(this as TrainerProfile, _$identity);

  /// Serializes this TrainerProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrainerProfile&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.bio, bio) || other.bio == bio)&&const DeepCollectionEquality().equals(other.specialties, specialties)&&(identical(other.experienceYears, experienceYears) || other.experienceYears == experienceYears)&&const DeepCollectionEquality().equals(other.certifications, certifications)&&(identical(other.averageRating, averageRating) || other.averageRating == averageRating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.sessionCount, sessionCount) || other.sessionCount == sessionCount)&&(identical(other.hourlyRate, hourlyRate) || other.hourlyRate == hourlyRate)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.location, location) || other.location == location)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username,displayName,avatarUrl,bio,const DeepCollectionEquality().hash(specialties),experienceYears,const DeepCollectionEquality().hash(certifications),averageRating,reviewCount,sessionCount,hourlyRate,currency,location,isAvailable);

@override
String toString() {
  return 'TrainerProfile(username: $username, displayName: $displayName, avatarUrl: $avatarUrl, bio: $bio, specialties: $specialties, experienceYears: $experienceYears, certifications: $certifications, averageRating: $averageRating, reviewCount: $reviewCount, sessionCount: $sessionCount, hourlyRate: $hourlyRate, currency: $currency, location: $location, isAvailable: $isAvailable)';
}


}

/// @nodoc
abstract mixin class $TrainerProfileCopyWith<$Res>  {
  factory $TrainerProfileCopyWith(TrainerProfile value, $Res Function(TrainerProfile) _then) = _$TrainerProfileCopyWithImpl;
@useResult
$Res call({
 String username,@JsonKey(name: 'display_name') String displayName,@JsonKey(name: 'avatar_url') String avatarUrl,@JsonKey(name: 'bio') String bio,@JsonKey(name: 'specialties') List<String> specialties,@JsonKey(name: 'experience_years') int experienceYears,@JsonKey(name: 'certifications') List<String> certifications,@JsonKey(name: 'average_rating') double averageRating,@JsonKey(name: 'review_count') int reviewCount,@JsonKey(name: 'session_count') int sessionCount,@JsonKey(name: 'hourly_rate') double hourlyRate,@JsonKey(name: 'currency') String currency,@JsonKey(name: 'location') String location,@JsonKey(name: 'is_available') bool isAvailable
});




}
/// @nodoc
class _$TrainerProfileCopyWithImpl<$Res>
    implements $TrainerProfileCopyWith<$Res> {
  _$TrainerProfileCopyWithImpl(this._self, this._then);

  final TrainerProfile _self;
  final $Res Function(TrainerProfile) _then;

/// Create a copy of TrainerProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? username = null,Object? displayName = null,Object? avatarUrl = null,Object? bio = null,Object? specialties = null,Object? experienceYears = null,Object? certifications = null,Object? averageRating = null,Object? reviewCount = null,Object? sessionCount = null,Object? hourlyRate = null,Object? currency = null,Object? location = null,Object? isAvailable = null,}) {
  return _then(_self.copyWith(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,specialties: null == specialties ? _self.specialties : specialties // ignore: cast_nullable_to_non_nullable
as List<String>,experienceYears: null == experienceYears ? _self.experienceYears : experienceYears // ignore: cast_nullable_to_non_nullable
as int,certifications: null == certifications ? _self.certifications : certifications // ignore: cast_nullable_to_non_nullable
as List<String>,averageRating: null == averageRating ? _self.averageRating : averageRating // ignore: cast_nullable_to_non_nullable
as double,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,sessionCount: null == sessionCount ? _self.sessionCount : sessionCount // ignore: cast_nullable_to_non_nullable
as int,hourlyRate: null == hourlyRate ? _self.hourlyRate : hourlyRate // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TrainerProfile].
extension TrainerProfilePatterns on TrainerProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrainerProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrainerProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrainerProfile value)  $default,){
final _that = this;
switch (_that) {
case _TrainerProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrainerProfile value)?  $default,){
final _that = this;
switch (_that) {
case _TrainerProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String username, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'avatar_url')  String avatarUrl, @JsonKey(name: 'bio')  String bio, @JsonKey(name: 'specialties')  List<String> specialties, @JsonKey(name: 'experience_years')  int experienceYears, @JsonKey(name: 'certifications')  List<String> certifications, @JsonKey(name: 'average_rating')  double averageRating, @JsonKey(name: 'review_count')  int reviewCount, @JsonKey(name: 'session_count')  int sessionCount, @JsonKey(name: 'hourly_rate')  double hourlyRate, @JsonKey(name: 'currency')  String currency, @JsonKey(name: 'location')  String location, @JsonKey(name: 'is_available')  bool isAvailable)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrainerProfile() when $default != null:
return $default(_that.username,_that.displayName,_that.avatarUrl,_that.bio,_that.specialties,_that.experienceYears,_that.certifications,_that.averageRating,_that.reviewCount,_that.sessionCount,_that.hourlyRate,_that.currency,_that.location,_that.isAvailable);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String username, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'avatar_url')  String avatarUrl, @JsonKey(name: 'bio')  String bio, @JsonKey(name: 'specialties')  List<String> specialties, @JsonKey(name: 'experience_years')  int experienceYears, @JsonKey(name: 'certifications')  List<String> certifications, @JsonKey(name: 'average_rating')  double averageRating, @JsonKey(name: 'review_count')  int reviewCount, @JsonKey(name: 'session_count')  int sessionCount, @JsonKey(name: 'hourly_rate')  double hourlyRate, @JsonKey(name: 'currency')  String currency, @JsonKey(name: 'location')  String location, @JsonKey(name: 'is_available')  bool isAvailable)  $default,) {final _that = this;
switch (_that) {
case _TrainerProfile():
return $default(_that.username,_that.displayName,_that.avatarUrl,_that.bio,_that.specialties,_that.experienceYears,_that.certifications,_that.averageRating,_that.reviewCount,_that.sessionCount,_that.hourlyRate,_that.currency,_that.location,_that.isAvailable);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String username, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'avatar_url')  String avatarUrl, @JsonKey(name: 'bio')  String bio, @JsonKey(name: 'specialties')  List<String> specialties, @JsonKey(name: 'experience_years')  int experienceYears, @JsonKey(name: 'certifications')  List<String> certifications, @JsonKey(name: 'average_rating')  double averageRating, @JsonKey(name: 'review_count')  int reviewCount, @JsonKey(name: 'session_count')  int sessionCount, @JsonKey(name: 'hourly_rate')  double hourlyRate, @JsonKey(name: 'currency')  String currency, @JsonKey(name: 'location')  String location, @JsonKey(name: 'is_available')  bool isAvailable)?  $default,) {final _that = this;
switch (_that) {
case _TrainerProfile() when $default != null:
return $default(_that.username,_that.displayName,_that.avatarUrl,_that.bio,_that.specialties,_that.experienceYears,_that.certifications,_that.averageRating,_that.reviewCount,_that.sessionCount,_that.hourlyRate,_that.currency,_that.location,_that.isAvailable);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrainerProfile implements TrainerProfile {
  const _TrainerProfile({required this.username, @JsonKey(name: 'display_name') required this.displayName, @JsonKey(name: 'avatar_url') required this.avatarUrl, @JsonKey(name: 'bio') this.bio = '', @JsonKey(name: 'specialties') final  List<String> specialties = const <String>[], @JsonKey(name: 'experience_years') this.experienceYears = 0, @JsonKey(name: 'certifications') final  List<String> certifications = const <String>[], @JsonKey(name: 'average_rating') this.averageRating = 0.0, @JsonKey(name: 'review_count') this.reviewCount = 0, @JsonKey(name: 'session_count') this.sessionCount = 0, @JsonKey(name: 'hourly_rate') this.hourlyRate = 0.0, @JsonKey(name: 'currency') this.currency = 'USD', @JsonKey(name: 'location') this.location = '', @JsonKey(name: 'is_available') this.isAvailable = false}): _specialties = specialties,_certifications = certifications;
  factory _TrainerProfile.fromJson(Map<String, dynamic> json) => _$TrainerProfileFromJson(json);

@override final  String username;
@override@JsonKey(name: 'display_name') final  String displayName;
@override@JsonKey(name: 'avatar_url') final  String avatarUrl;
@override@JsonKey(name: 'bio') final  String bio;
 final  List<String> _specialties;
@override@JsonKey(name: 'specialties') List<String> get specialties {
  if (_specialties is EqualUnmodifiableListView) return _specialties;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_specialties);
}

@override@JsonKey(name: 'experience_years') final  int experienceYears;
 final  List<String> _certifications;
@override@JsonKey(name: 'certifications') List<String> get certifications {
  if (_certifications is EqualUnmodifiableListView) return _certifications;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_certifications);
}

@override@JsonKey(name: 'average_rating') final  double averageRating;
@override@JsonKey(name: 'review_count') final  int reviewCount;
@override@JsonKey(name: 'session_count') final  int sessionCount;
@override@JsonKey(name: 'hourly_rate') final  double hourlyRate;
@override@JsonKey(name: 'currency') final  String currency;
@override@JsonKey(name: 'location') final  String location;
@override@JsonKey(name: 'is_available') final  bool isAvailable;

/// Create a copy of TrainerProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrainerProfileCopyWith<_TrainerProfile> get copyWith => __$TrainerProfileCopyWithImpl<_TrainerProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrainerProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrainerProfile&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.bio, bio) || other.bio == bio)&&const DeepCollectionEquality().equals(other._specialties, _specialties)&&(identical(other.experienceYears, experienceYears) || other.experienceYears == experienceYears)&&const DeepCollectionEquality().equals(other._certifications, _certifications)&&(identical(other.averageRating, averageRating) || other.averageRating == averageRating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.sessionCount, sessionCount) || other.sessionCount == sessionCount)&&(identical(other.hourlyRate, hourlyRate) || other.hourlyRate == hourlyRate)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.location, location) || other.location == location)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username,displayName,avatarUrl,bio,const DeepCollectionEquality().hash(_specialties),experienceYears,const DeepCollectionEquality().hash(_certifications),averageRating,reviewCount,sessionCount,hourlyRate,currency,location,isAvailable);

@override
String toString() {
  return 'TrainerProfile(username: $username, displayName: $displayName, avatarUrl: $avatarUrl, bio: $bio, specialties: $specialties, experienceYears: $experienceYears, certifications: $certifications, averageRating: $averageRating, reviewCount: $reviewCount, sessionCount: $sessionCount, hourlyRate: $hourlyRate, currency: $currency, location: $location, isAvailable: $isAvailable)';
}


}

/// @nodoc
abstract mixin class _$TrainerProfileCopyWith<$Res> implements $TrainerProfileCopyWith<$Res> {
  factory _$TrainerProfileCopyWith(_TrainerProfile value, $Res Function(_TrainerProfile) _then) = __$TrainerProfileCopyWithImpl;
@override @useResult
$Res call({
 String username,@JsonKey(name: 'display_name') String displayName,@JsonKey(name: 'avatar_url') String avatarUrl,@JsonKey(name: 'bio') String bio,@JsonKey(name: 'specialties') List<String> specialties,@JsonKey(name: 'experience_years') int experienceYears,@JsonKey(name: 'certifications') List<String> certifications,@JsonKey(name: 'average_rating') double averageRating,@JsonKey(name: 'review_count') int reviewCount,@JsonKey(name: 'session_count') int sessionCount,@JsonKey(name: 'hourly_rate') double hourlyRate,@JsonKey(name: 'currency') String currency,@JsonKey(name: 'location') String location,@JsonKey(name: 'is_available') bool isAvailable
});




}
/// @nodoc
class __$TrainerProfileCopyWithImpl<$Res>
    implements _$TrainerProfileCopyWith<$Res> {
  __$TrainerProfileCopyWithImpl(this._self, this._then);

  final _TrainerProfile _self;
  final $Res Function(_TrainerProfile) _then;

/// Create a copy of TrainerProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? username = null,Object? displayName = null,Object? avatarUrl = null,Object? bio = null,Object? specialties = null,Object? experienceYears = null,Object? certifications = null,Object? averageRating = null,Object? reviewCount = null,Object? sessionCount = null,Object? hourlyRate = null,Object? currency = null,Object? location = null,Object? isAvailable = null,}) {
  return _then(_TrainerProfile(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,specialties: null == specialties ? _self._specialties : specialties // ignore: cast_nullable_to_non_nullable
as List<String>,experienceYears: null == experienceYears ? _self.experienceYears : experienceYears // ignore: cast_nullable_to_non_nullable
as int,certifications: null == certifications ? _self._certifications : certifications // ignore: cast_nullable_to_non_nullable
as List<String>,averageRating: null == averageRating ? _self.averageRating : averageRating // ignore: cast_nullable_to_non_nullable
as double,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,sessionCount: null == sessionCount ? _self.sessionCount : sessionCount // ignore: cast_nullable_to_non_nullable
as int,hourlyRate: null == hourlyRate ? _self.hourlyRate : hourlyRate // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$AvailabilitySlot {

 String get id;@JsonKey(name: 'day_of_week') int get dayOfWeek;@JsonKey(name: 'start_time') String get startTime;@JsonKey(name: 'end_time') String get endTime; bool get isBooked;
/// Create a copy of AvailabilitySlot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AvailabilitySlotCopyWith<AvailabilitySlot> get copyWith => _$AvailabilitySlotCopyWithImpl<AvailabilitySlot>(this as AvailabilitySlot, _$identity);

  /// Serializes this AvailabilitySlot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AvailabilitySlot&&(identical(other.id, id) || other.id == id)&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.isBooked, isBooked) || other.isBooked == isBooked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,dayOfWeek,startTime,endTime,isBooked);

@override
String toString() {
  return 'AvailabilitySlot(id: $id, dayOfWeek: $dayOfWeek, startTime: $startTime, endTime: $endTime, isBooked: $isBooked)';
}


}

/// @nodoc
abstract mixin class $AvailabilitySlotCopyWith<$Res>  {
  factory $AvailabilitySlotCopyWith(AvailabilitySlot value, $Res Function(AvailabilitySlot) _then) = _$AvailabilitySlotCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'day_of_week') int dayOfWeek,@JsonKey(name: 'start_time') String startTime,@JsonKey(name: 'end_time') String endTime, bool isBooked
});




}
/// @nodoc
class _$AvailabilitySlotCopyWithImpl<$Res>
    implements $AvailabilitySlotCopyWith<$Res> {
  _$AvailabilitySlotCopyWithImpl(this._self, this._then);

  final AvailabilitySlot _self;
  final $Res Function(AvailabilitySlot) _then;

/// Create a copy of AvailabilitySlot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? dayOfWeek = null,Object? startTime = null,Object? endTime = null,Object? isBooked = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,dayOfWeek: null == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as int,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,isBooked: null == isBooked ? _self.isBooked : isBooked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AvailabilitySlot].
extension AvailabilitySlotPatterns on AvailabilitySlot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AvailabilitySlot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AvailabilitySlot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AvailabilitySlot value)  $default,){
final _that = this;
switch (_that) {
case _AvailabilitySlot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AvailabilitySlot value)?  $default,){
final _that = this;
switch (_that) {
case _AvailabilitySlot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'day_of_week')  int dayOfWeek, @JsonKey(name: 'start_time')  String startTime, @JsonKey(name: 'end_time')  String endTime,  bool isBooked)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AvailabilitySlot() when $default != null:
return $default(_that.id,_that.dayOfWeek,_that.startTime,_that.endTime,_that.isBooked);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'day_of_week')  int dayOfWeek, @JsonKey(name: 'start_time')  String startTime, @JsonKey(name: 'end_time')  String endTime,  bool isBooked)  $default,) {final _that = this;
switch (_that) {
case _AvailabilitySlot():
return $default(_that.id,_that.dayOfWeek,_that.startTime,_that.endTime,_that.isBooked);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'day_of_week')  int dayOfWeek, @JsonKey(name: 'start_time')  String startTime, @JsonKey(name: 'end_time')  String endTime,  bool isBooked)?  $default,) {final _that = this;
switch (_that) {
case _AvailabilitySlot() when $default != null:
return $default(_that.id,_that.dayOfWeek,_that.startTime,_that.endTime,_that.isBooked);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AvailabilitySlot implements AvailabilitySlot {
  const _AvailabilitySlot({required this.id, @JsonKey(name: 'day_of_week') required this.dayOfWeek, @JsonKey(name: 'start_time') required this.startTime, @JsonKey(name: 'end_time') required this.endTime, this.isBooked = false});
  factory _AvailabilitySlot.fromJson(Map<String, dynamic> json) => _$AvailabilitySlotFromJson(json);

@override final  String id;
@override@JsonKey(name: 'day_of_week') final  int dayOfWeek;
@override@JsonKey(name: 'start_time') final  String startTime;
@override@JsonKey(name: 'end_time') final  String endTime;
@override@JsonKey() final  bool isBooked;

/// Create a copy of AvailabilitySlot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AvailabilitySlotCopyWith<_AvailabilitySlot> get copyWith => __$AvailabilitySlotCopyWithImpl<_AvailabilitySlot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AvailabilitySlotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AvailabilitySlot&&(identical(other.id, id) || other.id == id)&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.isBooked, isBooked) || other.isBooked == isBooked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,dayOfWeek,startTime,endTime,isBooked);

@override
String toString() {
  return 'AvailabilitySlot(id: $id, dayOfWeek: $dayOfWeek, startTime: $startTime, endTime: $endTime, isBooked: $isBooked)';
}


}

/// @nodoc
abstract mixin class _$AvailabilitySlotCopyWith<$Res> implements $AvailabilitySlotCopyWith<$Res> {
  factory _$AvailabilitySlotCopyWith(_AvailabilitySlot value, $Res Function(_AvailabilitySlot) _then) = __$AvailabilitySlotCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'day_of_week') int dayOfWeek,@JsonKey(name: 'start_time') String startTime,@JsonKey(name: 'end_time') String endTime, bool isBooked
});




}
/// @nodoc
class __$AvailabilitySlotCopyWithImpl<$Res>
    implements _$AvailabilitySlotCopyWith<$Res> {
  __$AvailabilitySlotCopyWithImpl(this._self, this._then);

  final _AvailabilitySlot _self;
  final $Res Function(_AvailabilitySlot) _then;

/// Create a copy of AvailabilitySlot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? dayOfWeek = null,Object? startTime = null,Object? endTime = null,Object? isBooked = null,}) {
  return _then(_AvailabilitySlot(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,dayOfWeek: null == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as int,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,isBooked: null == isBooked ? _self.isBooked : isBooked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$BookingSession {

 String get id;@JsonKey(name: 'trainer_username') String get trainerUsername;@JsonKey(name: 'trainer_name') String get trainerName;@JsonKey(name: 'trainer_avatar') String get trainerAvatar;@JsonKey(name: 'student_username') String get studentUsername;@JsonKey(name: 'scheduled_date') String get scheduledDate;@JsonKey(name: 'scheduled_time') String get scheduledTime; String get status;@JsonKey(name: 'duration_minutes') int get durationMinutes;@JsonKey(name: 'session_type') String get sessionType; String? get notes;@JsonKey(name: 'total_fee') double? get totalFee; String? get currency;@JsonKey(name: 'meeting_link') String? get meetingLink;@JsonKey(name: 'cancellation_reason') String? get cancellationReason;@JsonKey(name: 'created_at') String get createdAt;
/// Create a copy of BookingSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingSessionCopyWith<BookingSession> get copyWith => _$BookingSessionCopyWithImpl<BookingSession>(this as BookingSession, _$identity);

  /// Serializes this BookingSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookingSession&&(identical(other.id, id) || other.id == id)&&(identical(other.trainerUsername, trainerUsername) || other.trainerUsername == trainerUsername)&&(identical(other.trainerName, trainerName) || other.trainerName == trainerName)&&(identical(other.trainerAvatar, trainerAvatar) || other.trainerAvatar == trainerAvatar)&&(identical(other.studentUsername, studentUsername) || other.studentUsername == studentUsername)&&(identical(other.scheduledDate, scheduledDate) || other.scheduledDate == scheduledDate)&&(identical(other.scheduledTime, scheduledTime) || other.scheduledTime == scheduledTime)&&(identical(other.status, status) || other.status == status)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.sessionType, sessionType) || other.sessionType == sessionType)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.totalFee, totalFee) || other.totalFee == totalFee)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.meetingLink, meetingLink) || other.meetingLink == meetingLink)&&(identical(other.cancellationReason, cancellationReason) || other.cancellationReason == cancellationReason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,trainerUsername,trainerName,trainerAvatar,studentUsername,scheduledDate,scheduledTime,status,durationMinutes,sessionType,notes,totalFee,currency,meetingLink,cancellationReason,createdAt);

@override
String toString() {
  return 'BookingSession(id: $id, trainerUsername: $trainerUsername, trainerName: $trainerName, trainerAvatar: $trainerAvatar, studentUsername: $studentUsername, scheduledDate: $scheduledDate, scheduledTime: $scheduledTime, status: $status, durationMinutes: $durationMinutes, sessionType: $sessionType, notes: $notes, totalFee: $totalFee, currency: $currency, meetingLink: $meetingLink, cancellationReason: $cancellationReason, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $BookingSessionCopyWith<$Res>  {
  factory $BookingSessionCopyWith(BookingSession value, $Res Function(BookingSession) _then) = _$BookingSessionCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'trainer_username') String trainerUsername,@JsonKey(name: 'trainer_name') String trainerName,@JsonKey(name: 'trainer_avatar') String trainerAvatar,@JsonKey(name: 'student_username') String studentUsername,@JsonKey(name: 'scheduled_date') String scheduledDate,@JsonKey(name: 'scheduled_time') String scheduledTime, String status,@JsonKey(name: 'duration_minutes') int durationMinutes,@JsonKey(name: 'session_type') String sessionType, String? notes,@JsonKey(name: 'total_fee') double? totalFee, String? currency,@JsonKey(name: 'meeting_link') String? meetingLink,@JsonKey(name: 'cancellation_reason') String? cancellationReason,@JsonKey(name: 'created_at') String createdAt
});




}
/// @nodoc
class _$BookingSessionCopyWithImpl<$Res>
    implements $BookingSessionCopyWith<$Res> {
  _$BookingSessionCopyWithImpl(this._self, this._then);

  final BookingSession _self;
  final $Res Function(BookingSession) _then;

/// Create a copy of BookingSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? trainerUsername = null,Object? trainerName = null,Object? trainerAvatar = null,Object? studentUsername = null,Object? scheduledDate = null,Object? scheduledTime = null,Object? status = null,Object? durationMinutes = null,Object? sessionType = null,Object? notes = freezed,Object? totalFee = freezed,Object? currency = freezed,Object? meetingLink = freezed,Object? cancellationReason = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,trainerUsername: null == trainerUsername ? _self.trainerUsername : trainerUsername // ignore: cast_nullable_to_non_nullable
as String,trainerName: null == trainerName ? _self.trainerName : trainerName // ignore: cast_nullable_to_non_nullable
as String,trainerAvatar: null == trainerAvatar ? _self.trainerAvatar : trainerAvatar // ignore: cast_nullable_to_non_nullable
as String,studentUsername: null == studentUsername ? _self.studentUsername : studentUsername // ignore: cast_nullable_to_non_nullable
as String,scheduledDate: null == scheduledDate ? _self.scheduledDate : scheduledDate // ignore: cast_nullable_to_non_nullable
as String,scheduledTime: null == scheduledTime ? _self.scheduledTime : scheduledTime // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,sessionType: null == sessionType ? _self.sessionType : sessionType // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,totalFee: freezed == totalFee ? _self.totalFee : totalFee // ignore: cast_nullable_to_non_nullable
as double?,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,meetingLink: freezed == meetingLink ? _self.meetingLink : meetingLink // ignore: cast_nullable_to_non_nullable
as String?,cancellationReason: freezed == cancellationReason ? _self.cancellationReason : cancellationReason // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BookingSession].
extension BookingSessionPatterns on BookingSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookingSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookingSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookingSession value)  $default,){
final _that = this;
switch (_that) {
case _BookingSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookingSession value)?  $default,){
final _that = this;
switch (_that) {
case _BookingSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'trainer_username')  String trainerUsername, @JsonKey(name: 'trainer_name')  String trainerName, @JsonKey(name: 'trainer_avatar')  String trainerAvatar, @JsonKey(name: 'student_username')  String studentUsername, @JsonKey(name: 'scheduled_date')  String scheduledDate, @JsonKey(name: 'scheduled_time')  String scheduledTime,  String status, @JsonKey(name: 'duration_minutes')  int durationMinutes, @JsonKey(name: 'session_type')  String sessionType,  String? notes, @JsonKey(name: 'total_fee')  double? totalFee,  String? currency, @JsonKey(name: 'meeting_link')  String? meetingLink, @JsonKey(name: 'cancellation_reason')  String? cancellationReason, @JsonKey(name: 'created_at')  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookingSession() when $default != null:
return $default(_that.id,_that.trainerUsername,_that.trainerName,_that.trainerAvatar,_that.studentUsername,_that.scheduledDate,_that.scheduledTime,_that.status,_that.durationMinutes,_that.sessionType,_that.notes,_that.totalFee,_that.currency,_that.meetingLink,_that.cancellationReason,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'trainer_username')  String trainerUsername, @JsonKey(name: 'trainer_name')  String trainerName, @JsonKey(name: 'trainer_avatar')  String trainerAvatar, @JsonKey(name: 'student_username')  String studentUsername, @JsonKey(name: 'scheduled_date')  String scheduledDate, @JsonKey(name: 'scheduled_time')  String scheduledTime,  String status, @JsonKey(name: 'duration_minutes')  int durationMinutes, @JsonKey(name: 'session_type')  String sessionType,  String? notes, @JsonKey(name: 'total_fee')  double? totalFee,  String? currency, @JsonKey(name: 'meeting_link')  String? meetingLink, @JsonKey(name: 'cancellation_reason')  String? cancellationReason, @JsonKey(name: 'created_at')  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _BookingSession():
return $default(_that.id,_that.trainerUsername,_that.trainerName,_that.trainerAvatar,_that.studentUsername,_that.scheduledDate,_that.scheduledTime,_that.status,_that.durationMinutes,_that.sessionType,_that.notes,_that.totalFee,_that.currency,_that.meetingLink,_that.cancellationReason,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'trainer_username')  String trainerUsername, @JsonKey(name: 'trainer_name')  String trainerName, @JsonKey(name: 'trainer_avatar')  String trainerAvatar, @JsonKey(name: 'student_username')  String studentUsername, @JsonKey(name: 'scheduled_date')  String scheduledDate, @JsonKey(name: 'scheduled_time')  String scheduledTime,  String status, @JsonKey(name: 'duration_minutes')  int durationMinutes, @JsonKey(name: 'session_type')  String sessionType,  String? notes, @JsonKey(name: 'total_fee')  double? totalFee,  String? currency, @JsonKey(name: 'meeting_link')  String? meetingLink, @JsonKey(name: 'cancellation_reason')  String? cancellationReason, @JsonKey(name: 'created_at')  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _BookingSession() when $default != null:
return $default(_that.id,_that.trainerUsername,_that.trainerName,_that.trainerAvatar,_that.studentUsername,_that.scheduledDate,_that.scheduledTime,_that.status,_that.durationMinutes,_that.sessionType,_that.notes,_that.totalFee,_that.currency,_that.meetingLink,_that.cancellationReason,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BookingSession implements BookingSession {
  const _BookingSession({required this.id, @JsonKey(name: 'trainer_username') required this.trainerUsername, @JsonKey(name: 'trainer_name') required this.trainerName, @JsonKey(name: 'trainer_avatar') required this.trainerAvatar, @JsonKey(name: 'student_username') required this.studentUsername, @JsonKey(name: 'scheduled_date') required this.scheduledDate, @JsonKey(name: 'scheduled_time') required this.scheduledTime, this.status = 'pending', @JsonKey(name: 'duration_minutes') this.durationMinutes = 60, @JsonKey(name: 'session_type') this.sessionType = 'one_on_one', this.notes, @JsonKey(name: 'total_fee') this.totalFee, this.currency, @JsonKey(name: 'meeting_link') this.meetingLink, @JsonKey(name: 'cancellation_reason') this.cancellationReason, @JsonKey(name: 'created_at') required this.createdAt});
  factory _BookingSession.fromJson(Map<String, dynamic> json) => _$BookingSessionFromJson(json);

@override final  String id;
@override@JsonKey(name: 'trainer_username') final  String trainerUsername;
@override@JsonKey(name: 'trainer_name') final  String trainerName;
@override@JsonKey(name: 'trainer_avatar') final  String trainerAvatar;
@override@JsonKey(name: 'student_username') final  String studentUsername;
@override@JsonKey(name: 'scheduled_date') final  String scheduledDate;
@override@JsonKey(name: 'scheduled_time') final  String scheduledTime;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'duration_minutes') final  int durationMinutes;
@override@JsonKey(name: 'session_type') final  String sessionType;
@override final  String? notes;
@override@JsonKey(name: 'total_fee') final  double? totalFee;
@override final  String? currency;
@override@JsonKey(name: 'meeting_link') final  String? meetingLink;
@override@JsonKey(name: 'cancellation_reason') final  String? cancellationReason;
@override@JsonKey(name: 'created_at') final  String createdAt;

/// Create a copy of BookingSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingSessionCopyWith<_BookingSession> get copyWith => __$BookingSessionCopyWithImpl<_BookingSession>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingSessionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookingSession&&(identical(other.id, id) || other.id == id)&&(identical(other.trainerUsername, trainerUsername) || other.trainerUsername == trainerUsername)&&(identical(other.trainerName, trainerName) || other.trainerName == trainerName)&&(identical(other.trainerAvatar, trainerAvatar) || other.trainerAvatar == trainerAvatar)&&(identical(other.studentUsername, studentUsername) || other.studentUsername == studentUsername)&&(identical(other.scheduledDate, scheduledDate) || other.scheduledDate == scheduledDate)&&(identical(other.scheduledTime, scheduledTime) || other.scheduledTime == scheduledTime)&&(identical(other.status, status) || other.status == status)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.sessionType, sessionType) || other.sessionType == sessionType)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.totalFee, totalFee) || other.totalFee == totalFee)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.meetingLink, meetingLink) || other.meetingLink == meetingLink)&&(identical(other.cancellationReason, cancellationReason) || other.cancellationReason == cancellationReason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,trainerUsername,trainerName,trainerAvatar,studentUsername,scheduledDate,scheduledTime,status,durationMinutes,sessionType,notes,totalFee,currency,meetingLink,cancellationReason,createdAt);

@override
String toString() {
  return 'BookingSession(id: $id, trainerUsername: $trainerUsername, trainerName: $trainerName, trainerAvatar: $trainerAvatar, studentUsername: $studentUsername, scheduledDate: $scheduledDate, scheduledTime: $scheduledTime, status: $status, durationMinutes: $durationMinutes, sessionType: $sessionType, notes: $notes, totalFee: $totalFee, currency: $currency, meetingLink: $meetingLink, cancellationReason: $cancellationReason, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$BookingSessionCopyWith<$Res> implements $BookingSessionCopyWith<$Res> {
  factory _$BookingSessionCopyWith(_BookingSession value, $Res Function(_BookingSession) _then) = __$BookingSessionCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'trainer_username') String trainerUsername,@JsonKey(name: 'trainer_name') String trainerName,@JsonKey(name: 'trainer_avatar') String trainerAvatar,@JsonKey(name: 'student_username') String studentUsername,@JsonKey(name: 'scheduled_date') String scheduledDate,@JsonKey(name: 'scheduled_time') String scheduledTime, String status,@JsonKey(name: 'duration_minutes') int durationMinutes,@JsonKey(name: 'session_type') String sessionType, String? notes,@JsonKey(name: 'total_fee') double? totalFee, String? currency,@JsonKey(name: 'meeting_link') String? meetingLink,@JsonKey(name: 'cancellation_reason') String? cancellationReason,@JsonKey(name: 'created_at') String createdAt
});




}
/// @nodoc
class __$BookingSessionCopyWithImpl<$Res>
    implements _$BookingSessionCopyWith<$Res> {
  __$BookingSessionCopyWithImpl(this._self, this._then);

  final _BookingSession _self;
  final $Res Function(_BookingSession) _then;

/// Create a copy of BookingSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? trainerUsername = null,Object? trainerName = null,Object? trainerAvatar = null,Object? studentUsername = null,Object? scheduledDate = null,Object? scheduledTime = null,Object? status = null,Object? durationMinutes = null,Object? sessionType = null,Object? notes = freezed,Object? totalFee = freezed,Object? currency = freezed,Object? meetingLink = freezed,Object? cancellationReason = freezed,Object? createdAt = null,}) {
  return _then(_BookingSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,trainerUsername: null == trainerUsername ? _self.trainerUsername : trainerUsername // ignore: cast_nullable_to_non_nullable
as String,trainerName: null == trainerName ? _self.trainerName : trainerName // ignore: cast_nullable_to_non_nullable
as String,trainerAvatar: null == trainerAvatar ? _self.trainerAvatar : trainerAvatar // ignore: cast_nullable_to_non_nullable
as String,studentUsername: null == studentUsername ? _self.studentUsername : studentUsername // ignore: cast_nullable_to_non_nullable
as String,scheduledDate: null == scheduledDate ? _self.scheduledDate : scheduledDate // ignore: cast_nullable_to_non_nullable
as String,scheduledTime: null == scheduledTime ? _self.scheduledTime : scheduledTime // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,sessionType: null == sessionType ? _self.sessionType : sessionType // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,totalFee: freezed == totalFee ? _self.totalFee : totalFee // ignore: cast_nullable_to_non_nullable
as double?,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,meetingLink: freezed == meetingLink ? _self.meetingLink : meetingLink // ignore: cast_nullable_to_non_nullable
as String?,cancellationReason: freezed == cancellationReason ? _self.cancellationReason : cancellationReason // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SessionReview {

 String get id;@JsonKey(name: 'booking_id') String get bookingId;@JsonKey(name: 'trainer_username') String get trainerUsername;@JsonKey(name: 'reviewer_username') String get reviewerUsername; int get rating; String? get comment;@JsonKey(name: 'created_at') String get createdAt;
/// Create a copy of SessionReview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionReviewCopyWith<SessionReview> get copyWith => _$SessionReviewCopyWithImpl<SessionReview>(this as SessionReview, _$identity);

  /// Serializes this SessionReview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionReview&&(identical(other.id, id) || other.id == id)&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.trainerUsername, trainerUsername) || other.trainerUsername == trainerUsername)&&(identical(other.reviewerUsername, reviewerUsername) || other.reviewerUsername == reviewerUsername)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,bookingId,trainerUsername,reviewerUsername,rating,comment,createdAt);

@override
String toString() {
  return 'SessionReview(id: $id, bookingId: $bookingId, trainerUsername: $trainerUsername, reviewerUsername: $reviewerUsername, rating: $rating, comment: $comment, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $SessionReviewCopyWith<$Res>  {
  factory $SessionReviewCopyWith(SessionReview value, $Res Function(SessionReview) _then) = _$SessionReviewCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'booking_id') String bookingId,@JsonKey(name: 'trainer_username') String trainerUsername,@JsonKey(name: 'reviewer_username') String reviewerUsername, int rating, String? comment,@JsonKey(name: 'created_at') String createdAt
});




}
/// @nodoc
class _$SessionReviewCopyWithImpl<$Res>
    implements $SessionReviewCopyWith<$Res> {
  _$SessionReviewCopyWithImpl(this._self, this._then);

  final SessionReview _self;
  final $Res Function(SessionReview) _then;

/// Create a copy of SessionReview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? bookingId = null,Object? trainerUsername = null,Object? reviewerUsername = null,Object? rating = null,Object? comment = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,bookingId: null == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String,trainerUsername: null == trainerUsername ? _self.trainerUsername : trainerUsername // ignore: cast_nullable_to_non_nullable
as String,reviewerUsername: null == reviewerUsername ? _self.reviewerUsername : reviewerUsername // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionReview].
extension SessionReviewPatterns on SessionReview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionReview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionReview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionReview value)  $default,){
final _that = this;
switch (_that) {
case _SessionReview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionReview value)?  $default,){
final _that = this;
switch (_that) {
case _SessionReview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'booking_id')  String bookingId, @JsonKey(name: 'trainer_username')  String trainerUsername, @JsonKey(name: 'reviewer_username')  String reviewerUsername,  int rating,  String? comment, @JsonKey(name: 'created_at')  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionReview() when $default != null:
return $default(_that.id,_that.bookingId,_that.trainerUsername,_that.reviewerUsername,_that.rating,_that.comment,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'booking_id')  String bookingId, @JsonKey(name: 'trainer_username')  String trainerUsername, @JsonKey(name: 'reviewer_username')  String reviewerUsername,  int rating,  String? comment, @JsonKey(name: 'created_at')  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _SessionReview():
return $default(_that.id,_that.bookingId,_that.trainerUsername,_that.reviewerUsername,_that.rating,_that.comment,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'booking_id')  String bookingId, @JsonKey(name: 'trainer_username')  String trainerUsername, @JsonKey(name: 'reviewer_username')  String reviewerUsername,  int rating,  String? comment, @JsonKey(name: 'created_at')  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _SessionReview() when $default != null:
return $default(_that.id,_that.bookingId,_that.trainerUsername,_that.reviewerUsername,_that.rating,_that.comment,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SessionReview implements SessionReview {
  const _SessionReview({required this.id, @JsonKey(name: 'booking_id') required this.bookingId, @JsonKey(name: 'trainer_username') required this.trainerUsername, @JsonKey(name: 'reviewer_username') required this.reviewerUsername, required this.rating, this.comment, @JsonKey(name: 'created_at') required this.createdAt});
  factory _SessionReview.fromJson(Map<String, dynamic> json) => _$SessionReviewFromJson(json);

@override final  String id;
@override@JsonKey(name: 'booking_id') final  String bookingId;
@override@JsonKey(name: 'trainer_username') final  String trainerUsername;
@override@JsonKey(name: 'reviewer_username') final  String reviewerUsername;
@override final  int rating;
@override final  String? comment;
@override@JsonKey(name: 'created_at') final  String createdAt;

/// Create a copy of SessionReview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionReviewCopyWith<_SessionReview> get copyWith => __$SessionReviewCopyWithImpl<_SessionReview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SessionReviewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionReview&&(identical(other.id, id) || other.id == id)&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.trainerUsername, trainerUsername) || other.trainerUsername == trainerUsername)&&(identical(other.reviewerUsername, reviewerUsername) || other.reviewerUsername == reviewerUsername)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,bookingId,trainerUsername,reviewerUsername,rating,comment,createdAt);

@override
String toString() {
  return 'SessionReview(id: $id, bookingId: $bookingId, trainerUsername: $trainerUsername, reviewerUsername: $reviewerUsername, rating: $rating, comment: $comment, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$SessionReviewCopyWith<$Res> implements $SessionReviewCopyWith<$Res> {
  factory _$SessionReviewCopyWith(_SessionReview value, $Res Function(_SessionReview) _then) = __$SessionReviewCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'booking_id') String bookingId,@JsonKey(name: 'trainer_username') String trainerUsername,@JsonKey(name: 'reviewer_username') String reviewerUsername, int rating, String? comment,@JsonKey(name: 'created_at') String createdAt
});




}
/// @nodoc
class __$SessionReviewCopyWithImpl<$Res>
    implements _$SessionReviewCopyWith<$Res> {
  __$SessionReviewCopyWithImpl(this._self, this._then);

  final _SessionReview _self;
  final $Res Function(_SessionReview) _then;

/// Create a copy of SessionReview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? bookingId = null,Object? trainerUsername = null,Object? reviewerUsername = null,Object? rating = null,Object? comment = freezed,Object? createdAt = null,}) {
  return _then(_SessionReview(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,bookingId: null == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String,trainerUsername: null == trainerUsername ? _self.trainerUsername : trainerUsername // ignore: cast_nullable_to_non_nullable
as String,reviewerUsername: null == reviewerUsername ? _self.reviewerUsername : reviewerUsername // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CreateBookingPayload {

@JsonKey(name: 'trainer_username') String get trainerUsername;@JsonKey(name: 'scheduled_date') String get scheduledDate;@JsonKey(name: 'scheduled_time') String get scheduledTime;@JsonKey(name: 'duration_minutes') int get durationMinutes;@JsonKey(name: 'session_type') String get sessionType; String? get notes;
/// Create a copy of CreateBookingPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateBookingPayloadCopyWith<CreateBookingPayload> get copyWith => _$CreateBookingPayloadCopyWithImpl<CreateBookingPayload>(this as CreateBookingPayload, _$identity);

  /// Serializes this CreateBookingPayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateBookingPayload&&(identical(other.trainerUsername, trainerUsername) || other.trainerUsername == trainerUsername)&&(identical(other.scheduledDate, scheduledDate) || other.scheduledDate == scheduledDate)&&(identical(other.scheduledTime, scheduledTime) || other.scheduledTime == scheduledTime)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.sessionType, sessionType) || other.sessionType == sessionType)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,trainerUsername,scheduledDate,scheduledTime,durationMinutes,sessionType,notes);

@override
String toString() {
  return 'CreateBookingPayload(trainerUsername: $trainerUsername, scheduledDate: $scheduledDate, scheduledTime: $scheduledTime, durationMinutes: $durationMinutes, sessionType: $sessionType, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $CreateBookingPayloadCopyWith<$Res>  {
  factory $CreateBookingPayloadCopyWith(CreateBookingPayload value, $Res Function(CreateBookingPayload) _then) = _$CreateBookingPayloadCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'trainer_username') String trainerUsername,@JsonKey(name: 'scheduled_date') String scheduledDate,@JsonKey(name: 'scheduled_time') String scheduledTime,@JsonKey(name: 'duration_minutes') int durationMinutes,@JsonKey(name: 'session_type') String sessionType, String? notes
});




}
/// @nodoc
class _$CreateBookingPayloadCopyWithImpl<$Res>
    implements $CreateBookingPayloadCopyWith<$Res> {
  _$CreateBookingPayloadCopyWithImpl(this._self, this._then);

  final CreateBookingPayload _self;
  final $Res Function(CreateBookingPayload) _then;

/// Create a copy of CreateBookingPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? trainerUsername = null,Object? scheduledDate = null,Object? scheduledTime = null,Object? durationMinutes = null,Object? sessionType = null,Object? notes = freezed,}) {
  return _then(_self.copyWith(
trainerUsername: null == trainerUsername ? _self.trainerUsername : trainerUsername // ignore: cast_nullable_to_non_nullable
as String,scheduledDate: null == scheduledDate ? _self.scheduledDate : scheduledDate // ignore: cast_nullable_to_non_nullable
as String,scheduledTime: null == scheduledTime ? _self.scheduledTime : scheduledTime // ignore: cast_nullable_to_non_nullable
as String,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,sessionType: null == sessionType ? _self.sessionType : sessionType // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateBookingPayload].
extension CreateBookingPayloadPatterns on CreateBookingPayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateBookingPayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateBookingPayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateBookingPayload value)  $default,){
final _that = this;
switch (_that) {
case _CreateBookingPayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateBookingPayload value)?  $default,){
final _that = this;
switch (_that) {
case _CreateBookingPayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'trainer_username')  String trainerUsername, @JsonKey(name: 'scheduled_date')  String scheduledDate, @JsonKey(name: 'scheduled_time')  String scheduledTime, @JsonKey(name: 'duration_minutes')  int durationMinutes, @JsonKey(name: 'session_type')  String sessionType,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateBookingPayload() when $default != null:
return $default(_that.trainerUsername,_that.scheduledDate,_that.scheduledTime,_that.durationMinutes,_that.sessionType,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'trainer_username')  String trainerUsername, @JsonKey(name: 'scheduled_date')  String scheduledDate, @JsonKey(name: 'scheduled_time')  String scheduledTime, @JsonKey(name: 'duration_minutes')  int durationMinutes, @JsonKey(name: 'session_type')  String sessionType,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _CreateBookingPayload():
return $default(_that.trainerUsername,_that.scheduledDate,_that.scheduledTime,_that.durationMinutes,_that.sessionType,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'trainer_username')  String trainerUsername, @JsonKey(name: 'scheduled_date')  String scheduledDate, @JsonKey(name: 'scheduled_time')  String scheduledTime, @JsonKey(name: 'duration_minutes')  int durationMinutes, @JsonKey(name: 'session_type')  String sessionType,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _CreateBookingPayload() when $default != null:
return $default(_that.trainerUsername,_that.scheduledDate,_that.scheduledTime,_that.durationMinutes,_that.sessionType,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateBookingPayload implements CreateBookingPayload {
  const _CreateBookingPayload({@JsonKey(name: 'trainer_username') required this.trainerUsername, @JsonKey(name: 'scheduled_date') required this.scheduledDate, @JsonKey(name: 'scheduled_time') required this.scheduledTime, @JsonKey(name: 'duration_minutes') this.durationMinutes = 60, @JsonKey(name: 'session_type') this.sessionType = 'one_on_one', this.notes});
  factory _CreateBookingPayload.fromJson(Map<String, dynamic> json) => _$CreateBookingPayloadFromJson(json);

@override@JsonKey(name: 'trainer_username') final  String trainerUsername;
@override@JsonKey(name: 'scheduled_date') final  String scheduledDate;
@override@JsonKey(name: 'scheduled_time') final  String scheduledTime;
@override@JsonKey(name: 'duration_minutes') final  int durationMinutes;
@override@JsonKey(name: 'session_type') final  String sessionType;
@override final  String? notes;

/// Create a copy of CreateBookingPayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateBookingPayloadCopyWith<_CreateBookingPayload> get copyWith => __$CreateBookingPayloadCopyWithImpl<_CreateBookingPayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateBookingPayloadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateBookingPayload&&(identical(other.trainerUsername, trainerUsername) || other.trainerUsername == trainerUsername)&&(identical(other.scheduledDate, scheduledDate) || other.scheduledDate == scheduledDate)&&(identical(other.scheduledTime, scheduledTime) || other.scheduledTime == scheduledTime)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.sessionType, sessionType) || other.sessionType == sessionType)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,trainerUsername,scheduledDate,scheduledTime,durationMinutes,sessionType,notes);

@override
String toString() {
  return 'CreateBookingPayload(trainerUsername: $trainerUsername, scheduledDate: $scheduledDate, scheduledTime: $scheduledTime, durationMinutes: $durationMinutes, sessionType: $sessionType, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$CreateBookingPayloadCopyWith<$Res> implements $CreateBookingPayloadCopyWith<$Res> {
  factory _$CreateBookingPayloadCopyWith(_CreateBookingPayload value, $Res Function(_CreateBookingPayload) _then) = __$CreateBookingPayloadCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'trainer_username') String trainerUsername,@JsonKey(name: 'scheduled_date') String scheduledDate,@JsonKey(name: 'scheduled_time') String scheduledTime,@JsonKey(name: 'duration_minutes') int durationMinutes,@JsonKey(name: 'session_type') String sessionType, String? notes
});




}
/// @nodoc
class __$CreateBookingPayloadCopyWithImpl<$Res>
    implements _$CreateBookingPayloadCopyWith<$Res> {
  __$CreateBookingPayloadCopyWithImpl(this._self, this._then);

  final _CreateBookingPayload _self;
  final $Res Function(_CreateBookingPayload) _then;

/// Create a copy of CreateBookingPayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? trainerUsername = null,Object? scheduledDate = null,Object? scheduledTime = null,Object? durationMinutes = null,Object? sessionType = null,Object? notes = freezed,}) {
  return _then(_CreateBookingPayload(
trainerUsername: null == trainerUsername ? _self.trainerUsername : trainerUsername // ignore: cast_nullable_to_non_nullable
as String,scheduledDate: null == scheduledDate ? _self.scheduledDate : scheduledDate // ignore: cast_nullable_to_non_nullable
as String,scheduledTime: null == scheduledTime ? _self.scheduledTime : scheduledTime // ignore: cast_nullable_to_non_nullable
as String,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,sessionType: null == sessionType ? _self.sessionType : sessionType // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ProgrammeWeek {

 String get id;@JsonKey(name: 'programme_id') String get programmeId;@JsonKey(name: 'week_number') int get weekNumber; String get title; String get description;@JsonKey(name: 'is_completed') bool get isCompleted;
/// Create a copy of ProgrammeWeek
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProgrammeWeekCopyWith<ProgrammeWeek> get copyWith => _$ProgrammeWeekCopyWithImpl<ProgrammeWeek>(this as ProgrammeWeek, _$identity);

  /// Serializes this ProgrammeWeek to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProgrammeWeek&&(identical(other.id, id) || other.id == id)&&(identical(other.programmeId, programmeId) || other.programmeId == programmeId)&&(identical(other.weekNumber, weekNumber) || other.weekNumber == weekNumber)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,programmeId,weekNumber,title,description,isCompleted);

@override
String toString() {
  return 'ProgrammeWeek(id: $id, programmeId: $programmeId, weekNumber: $weekNumber, title: $title, description: $description, isCompleted: $isCompleted)';
}


}

/// @nodoc
abstract mixin class $ProgrammeWeekCopyWith<$Res>  {
  factory $ProgrammeWeekCopyWith(ProgrammeWeek value, $Res Function(ProgrammeWeek) _then) = _$ProgrammeWeekCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'programme_id') String programmeId,@JsonKey(name: 'week_number') int weekNumber, String title, String description,@JsonKey(name: 'is_completed') bool isCompleted
});




}
/// @nodoc
class _$ProgrammeWeekCopyWithImpl<$Res>
    implements $ProgrammeWeekCopyWith<$Res> {
  _$ProgrammeWeekCopyWithImpl(this._self, this._then);

  final ProgrammeWeek _self;
  final $Res Function(ProgrammeWeek) _then;

/// Create a copy of ProgrammeWeek
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? programmeId = null,Object? weekNumber = null,Object? title = null,Object? description = null,Object? isCompleted = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,programmeId: null == programmeId ? _self.programmeId : programmeId // ignore: cast_nullable_to_non_nullable
as String,weekNumber: null == weekNumber ? _self.weekNumber : weekNumber // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ProgrammeWeek].
extension ProgrammeWeekPatterns on ProgrammeWeek {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProgrammeWeek value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProgrammeWeek() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProgrammeWeek value)  $default,){
final _that = this;
switch (_that) {
case _ProgrammeWeek():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProgrammeWeek value)?  $default,){
final _that = this;
switch (_that) {
case _ProgrammeWeek() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'programme_id')  String programmeId, @JsonKey(name: 'week_number')  int weekNumber,  String title,  String description, @JsonKey(name: 'is_completed')  bool isCompleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProgrammeWeek() when $default != null:
return $default(_that.id,_that.programmeId,_that.weekNumber,_that.title,_that.description,_that.isCompleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'programme_id')  String programmeId, @JsonKey(name: 'week_number')  int weekNumber,  String title,  String description, @JsonKey(name: 'is_completed')  bool isCompleted)  $default,) {final _that = this;
switch (_that) {
case _ProgrammeWeek():
return $default(_that.id,_that.programmeId,_that.weekNumber,_that.title,_that.description,_that.isCompleted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'programme_id')  String programmeId, @JsonKey(name: 'week_number')  int weekNumber,  String title,  String description, @JsonKey(name: 'is_completed')  bool isCompleted)?  $default,) {final _that = this;
switch (_that) {
case _ProgrammeWeek() when $default != null:
return $default(_that.id,_that.programmeId,_that.weekNumber,_that.title,_that.description,_that.isCompleted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProgrammeWeek implements ProgrammeWeek {
  const _ProgrammeWeek({required this.id, @JsonKey(name: 'programme_id') required this.programmeId, @JsonKey(name: 'week_number') required this.weekNumber, required this.title, required this.description, @JsonKey(name: 'is_completed') this.isCompleted = false});
  factory _ProgrammeWeek.fromJson(Map<String, dynamic> json) => _$ProgrammeWeekFromJson(json);

@override final  String id;
@override@JsonKey(name: 'programme_id') final  String programmeId;
@override@JsonKey(name: 'week_number') final  int weekNumber;
@override final  String title;
@override final  String description;
@override@JsonKey(name: 'is_completed') final  bool isCompleted;

/// Create a copy of ProgrammeWeek
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProgrammeWeekCopyWith<_ProgrammeWeek> get copyWith => __$ProgrammeWeekCopyWithImpl<_ProgrammeWeek>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProgrammeWeekToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProgrammeWeek&&(identical(other.id, id) || other.id == id)&&(identical(other.programmeId, programmeId) || other.programmeId == programmeId)&&(identical(other.weekNumber, weekNumber) || other.weekNumber == weekNumber)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,programmeId,weekNumber,title,description,isCompleted);

@override
String toString() {
  return 'ProgrammeWeek(id: $id, programmeId: $programmeId, weekNumber: $weekNumber, title: $title, description: $description, isCompleted: $isCompleted)';
}


}

/// @nodoc
abstract mixin class _$ProgrammeWeekCopyWith<$Res> implements $ProgrammeWeekCopyWith<$Res> {
  factory _$ProgrammeWeekCopyWith(_ProgrammeWeek value, $Res Function(_ProgrammeWeek) _then) = __$ProgrammeWeekCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'programme_id') String programmeId,@JsonKey(name: 'week_number') int weekNumber, String title, String description,@JsonKey(name: 'is_completed') bool isCompleted
});




}
/// @nodoc
class __$ProgrammeWeekCopyWithImpl<$Res>
    implements _$ProgrammeWeekCopyWith<$Res> {
  __$ProgrammeWeekCopyWithImpl(this._self, this._then);

  final _ProgrammeWeek _self;
  final $Res Function(_ProgrammeWeek) _then;

/// Create a copy of ProgrammeWeek
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? programmeId = null,Object? weekNumber = null,Object? title = null,Object? description = null,Object? isCompleted = null,}) {
  return _then(_ProgrammeWeek(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,programmeId: null == programmeId ? _self.programmeId : programmeId // ignore: cast_nullable_to_non_nullable
as String,weekNumber: null == weekNumber ? _self.weekNumber : weekNumber // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$ProgrammeEnrollment {

 String get id;@JsonKey(name: 'programme_id') String get programmeId;@JsonKey(name: 'programme_title') String get programmeTitle;@JsonKey(name: 'total_weeks') int get totalWeeks;@JsonKey(name: 'completed_weeks') int get completedWeeks;@JsonKey(name: 'started_at') String get startedAt;@JsonKey(name: 'completed_at') String? get completedAt;
/// Create a copy of ProgrammeEnrollment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProgrammeEnrollmentCopyWith<ProgrammeEnrollment> get copyWith => _$ProgrammeEnrollmentCopyWithImpl<ProgrammeEnrollment>(this as ProgrammeEnrollment, _$identity);

  /// Serializes this ProgrammeEnrollment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProgrammeEnrollment&&(identical(other.id, id) || other.id == id)&&(identical(other.programmeId, programmeId) || other.programmeId == programmeId)&&(identical(other.programmeTitle, programmeTitle) || other.programmeTitle == programmeTitle)&&(identical(other.totalWeeks, totalWeeks) || other.totalWeeks == totalWeeks)&&(identical(other.completedWeeks, completedWeeks) || other.completedWeeks == completedWeeks)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,programmeId,programmeTitle,totalWeeks,completedWeeks,startedAt,completedAt);

@override
String toString() {
  return 'ProgrammeEnrollment(id: $id, programmeId: $programmeId, programmeTitle: $programmeTitle, totalWeeks: $totalWeeks, completedWeeks: $completedWeeks, startedAt: $startedAt, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class $ProgrammeEnrollmentCopyWith<$Res>  {
  factory $ProgrammeEnrollmentCopyWith(ProgrammeEnrollment value, $Res Function(ProgrammeEnrollment) _then) = _$ProgrammeEnrollmentCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'programme_id') String programmeId,@JsonKey(name: 'programme_title') String programmeTitle,@JsonKey(name: 'total_weeks') int totalWeeks,@JsonKey(name: 'completed_weeks') int completedWeeks,@JsonKey(name: 'started_at') String startedAt,@JsonKey(name: 'completed_at') String? completedAt
});




}
/// @nodoc
class _$ProgrammeEnrollmentCopyWithImpl<$Res>
    implements $ProgrammeEnrollmentCopyWith<$Res> {
  _$ProgrammeEnrollmentCopyWithImpl(this._self, this._then);

  final ProgrammeEnrollment _self;
  final $Res Function(ProgrammeEnrollment) _then;

/// Create a copy of ProgrammeEnrollment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? programmeId = null,Object? programmeTitle = null,Object? totalWeeks = null,Object? completedWeeks = null,Object? startedAt = null,Object? completedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,programmeId: null == programmeId ? _self.programmeId : programmeId // ignore: cast_nullable_to_non_nullable
as String,programmeTitle: null == programmeTitle ? _self.programmeTitle : programmeTitle // ignore: cast_nullable_to_non_nullable
as String,totalWeeks: null == totalWeeks ? _self.totalWeeks : totalWeeks // ignore: cast_nullable_to_non_nullable
as int,completedWeeks: null == completedWeeks ? _self.completedWeeks : completedWeeks // ignore: cast_nullable_to_non_nullable
as int,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as String,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProgrammeEnrollment].
extension ProgrammeEnrollmentPatterns on ProgrammeEnrollment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProgrammeEnrollment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProgrammeEnrollment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProgrammeEnrollment value)  $default,){
final _that = this;
switch (_that) {
case _ProgrammeEnrollment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProgrammeEnrollment value)?  $default,){
final _that = this;
switch (_that) {
case _ProgrammeEnrollment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'programme_id')  String programmeId, @JsonKey(name: 'programme_title')  String programmeTitle, @JsonKey(name: 'total_weeks')  int totalWeeks, @JsonKey(name: 'completed_weeks')  int completedWeeks, @JsonKey(name: 'started_at')  String startedAt, @JsonKey(name: 'completed_at')  String? completedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProgrammeEnrollment() when $default != null:
return $default(_that.id,_that.programmeId,_that.programmeTitle,_that.totalWeeks,_that.completedWeeks,_that.startedAt,_that.completedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'programme_id')  String programmeId, @JsonKey(name: 'programme_title')  String programmeTitle, @JsonKey(name: 'total_weeks')  int totalWeeks, @JsonKey(name: 'completed_weeks')  int completedWeeks, @JsonKey(name: 'started_at')  String startedAt, @JsonKey(name: 'completed_at')  String? completedAt)  $default,) {final _that = this;
switch (_that) {
case _ProgrammeEnrollment():
return $default(_that.id,_that.programmeId,_that.programmeTitle,_that.totalWeeks,_that.completedWeeks,_that.startedAt,_that.completedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'programme_id')  String programmeId, @JsonKey(name: 'programme_title')  String programmeTitle, @JsonKey(name: 'total_weeks')  int totalWeeks, @JsonKey(name: 'completed_weeks')  int completedWeeks, @JsonKey(name: 'started_at')  String startedAt, @JsonKey(name: 'completed_at')  String? completedAt)?  $default,) {final _that = this;
switch (_that) {
case _ProgrammeEnrollment() when $default != null:
return $default(_that.id,_that.programmeId,_that.programmeTitle,_that.totalWeeks,_that.completedWeeks,_that.startedAt,_that.completedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProgrammeEnrollment implements ProgrammeEnrollment {
  const _ProgrammeEnrollment({required this.id, @JsonKey(name: 'programme_id') required this.programmeId, @JsonKey(name: 'programme_title') required this.programmeTitle, @JsonKey(name: 'total_weeks') this.totalWeeks = 0, @JsonKey(name: 'completed_weeks') this.completedWeeks = 0, @JsonKey(name: 'started_at') required this.startedAt, @JsonKey(name: 'completed_at') this.completedAt});
  factory _ProgrammeEnrollment.fromJson(Map<String, dynamic> json) => _$ProgrammeEnrollmentFromJson(json);

@override final  String id;
@override@JsonKey(name: 'programme_id') final  String programmeId;
@override@JsonKey(name: 'programme_title') final  String programmeTitle;
@override@JsonKey(name: 'total_weeks') final  int totalWeeks;
@override@JsonKey(name: 'completed_weeks') final  int completedWeeks;
@override@JsonKey(name: 'started_at') final  String startedAt;
@override@JsonKey(name: 'completed_at') final  String? completedAt;

/// Create a copy of ProgrammeEnrollment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProgrammeEnrollmentCopyWith<_ProgrammeEnrollment> get copyWith => __$ProgrammeEnrollmentCopyWithImpl<_ProgrammeEnrollment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProgrammeEnrollmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProgrammeEnrollment&&(identical(other.id, id) || other.id == id)&&(identical(other.programmeId, programmeId) || other.programmeId == programmeId)&&(identical(other.programmeTitle, programmeTitle) || other.programmeTitle == programmeTitle)&&(identical(other.totalWeeks, totalWeeks) || other.totalWeeks == totalWeeks)&&(identical(other.completedWeeks, completedWeeks) || other.completedWeeks == completedWeeks)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,programmeId,programmeTitle,totalWeeks,completedWeeks,startedAt,completedAt);

@override
String toString() {
  return 'ProgrammeEnrollment(id: $id, programmeId: $programmeId, programmeTitle: $programmeTitle, totalWeeks: $totalWeeks, completedWeeks: $completedWeeks, startedAt: $startedAt, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class _$ProgrammeEnrollmentCopyWith<$Res> implements $ProgrammeEnrollmentCopyWith<$Res> {
  factory _$ProgrammeEnrollmentCopyWith(_ProgrammeEnrollment value, $Res Function(_ProgrammeEnrollment) _then) = __$ProgrammeEnrollmentCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'programme_id') String programmeId,@JsonKey(name: 'programme_title') String programmeTitle,@JsonKey(name: 'total_weeks') int totalWeeks,@JsonKey(name: 'completed_weeks') int completedWeeks,@JsonKey(name: 'started_at') String startedAt,@JsonKey(name: 'completed_at') String? completedAt
});




}
/// @nodoc
class __$ProgrammeEnrollmentCopyWithImpl<$Res>
    implements _$ProgrammeEnrollmentCopyWith<$Res> {
  __$ProgrammeEnrollmentCopyWithImpl(this._self, this._then);

  final _ProgrammeEnrollment _self;
  final $Res Function(_ProgrammeEnrollment) _then;

/// Create a copy of ProgrammeEnrollment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? programmeId = null,Object? programmeTitle = null,Object? totalWeeks = null,Object? completedWeeks = null,Object? startedAt = null,Object? completedAt = freezed,}) {
  return _then(_ProgrammeEnrollment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,programmeId: null == programmeId ? _self.programmeId : programmeId // ignore: cast_nullable_to_non_nullable
as String,programmeTitle: null == programmeTitle ? _self.programmeTitle : programmeTitle // ignore: cast_nullable_to_non_nullable
as String,totalWeeks: null == totalWeeks ? _self.totalWeeks : totalWeeks // ignore: cast_nullable_to_non_nullable
as int,completedWeeks: null == completedWeeks ? _self.completedWeeks : completedWeeks // ignore: cast_nullable_to_non_nullable
as int,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as String,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
