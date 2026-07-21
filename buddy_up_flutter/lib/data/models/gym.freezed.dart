// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gym.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OwnerData {

 String get userId; String get username; String get displayName; String get avatarUrl; String get role;
/// Create a copy of OwnerData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OwnerDataCopyWith<OwnerData> get copyWith => _$OwnerDataCopyWithImpl<OwnerData>(this as OwnerData, _$identity);

  /// Serializes this OwnerData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OwnerData&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username,displayName,avatarUrl,role);

@override
String toString() {
  return 'OwnerData(userId: $userId, username: $username, displayName: $displayName, avatarUrl: $avatarUrl, role: $role)';
}


}

/// @nodoc
abstract mixin class $OwnerDataCopyWith<$Res>  {
  factory $OwnerDataCopyWith(OwnerData value, $Res Function(OwnerData) _then) = _$OwnerDataCopyWithImpl;
@useResult
$Res call({
 String userId, String username, String displayName, String avatarUrl, String role
});




}
/// @nodoc
class _$OwnerDataCopyWithImpl<$Res>
    implements $OwnerDataCopyWith<$Res> {
  _$OwnerDataCopyWithImpl(this._self, this._then);

  final OwnerData _self;
  final $Res Function(OwnerData) _then;

/// Create a copy of OwnerData
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


/// Adds pattern-matching-related methods to [OwnerData].
extension OwnerDataPatterns on OwnerData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OwnerData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OwnerData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OwnerData value)  $default,){
final _that = this;
switch (_that) {
case _OwnerData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OwnerData value)?  $default,){
final _that = this;
switch (_that) {
case _OwnerData() when $default != null:
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
case _OwnerData() when $default != null:
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
case _OwnerData():
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
case _OwnerData() when $default != null:
return $default(_that.userId,_that.username,_that.displayName,_that.avatarUrl,_that.role);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OwnerData implements OwnerData {
  const _OwnerData({required this.userId, required this.username, required this.displayName, required this.avatarUrl, required this.role});
  factory _OwnerData.fromJson(Map<String, dynamic> json) => _$OwnerDataFromJson(json);

@override final  String userId;
@override final  String username;
@override final  String displayName;
@override final  String avatarUrl;
@override final  String role;

/// Create a copy of OwnerData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OwnerDataCopyWith<_OwnerData> get copyWith => __$OwnerDataCopyWithImpl<_OwnerData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OwnerDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OwnerData&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username,displayName,avatarUrl,role);

@override
String toString() {
  return 'OwnerData(userId: $userId, username: $username, displayName: $displayName, avatarUrl: $avatarUrl, role: $role)';
}


}

/// @nodoc
abstract mixin class _$OwnerDataCopyWith<$Res> implements $OwnerDataCopyWith<$Res> {
  factory _$OwnerDataCopyWith(_OwnerData value, $Res Function(_OwnerData) _then) = __$OwnerDataCopyWithImpl;
@override @useResult
$Res call({
 String userId, String username, String displayName, String avatarUrl, String role
});




}
/// @nodoc
class __$OwnerDataCopyWithImpl<$Res>
    implements _$OwnerDataCopyWith<$Res> {
  __$OwnerDataCopyWithImpl(this._self, this._then);

  final _OwnerData _self;
  final $Res Function(_OwnerData) _then;

/// Create a copy of OwnerData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? username = null,Object? displayName = null,Object? avatarUrl = null,Object? role = null,}) {
  return _then(_OwnerData(
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
mixin _$MemberData {

 String get userId; String get username; String get displayName; String get avatarUrl; String get verificationStatus;
/// Create a copy of MemberData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemberDataCopyWith<MemberData> get copyWith => _$MemberDataCopyWithImpl<MemberData>(this as MemberData, _$identity);

  /// Serializes this MemberData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MemberData&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username,displayName,avatarUrl,verificationStatus);

@override
String toString() {
  return 'MemberData(userId: $userId, username: $username, displayName: $displayName, avatarUrl: $avatarUrl, verificationStatus: $verificationStatus)';
}


}

/// @nodoc
abstract mixin class $MemberDataCopyWith<$Res>  {
  factory $MemberDataCopyWith(MemberData value, $Res Function(MemberData) _then) = _$MemberDataCopyWithImpl;
@useResult
$Res call({
 String userId, String username, String displayName, String avatarUrl, String verificationStatus
});




}
/// @nodoc
class _$MemberDataCopyWithImpl<$Res>
    implements $MemberDataCopyWith<$Res> {
  _$MemberDataCopyWithImpl(this._self, this._then);

  final MemberData _self;
  final $Res Function(MemberData) _then;

/// Create a copy of MemberData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? username = null,Object? displayName = null,Object? avatarUrl = null,Object? verificationStatus = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MemberData].
extension MemberDataPatterns on MemberData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MemberData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MemberData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MemberData value)  $default,){
final _that = this;
switch (_that) {
case _MemberData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MemberData value)?  $default,){
final _that = this;
switch (_that) {
case _MemberData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String username,  String displayName,  String avatarUrl,  String verificationStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MemberData() when $default != null:
return $default(_that.userId,_that.username,_that.displayName,_that.avatarUrl,_that.verificationStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String username,  String displayName,  String avatarUrl,  String verificationStatus)  $default,) {final _that = this;
switch (_that) {
case _MemberData():
return $default(_that.userId,_that.username,_that.displayName,_that.avatarUrl,_that.verificationStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String username,  String displayName,  String avatarUrl,  String verificationStatus)?  $default,) {final _that = this;
switch (_that) {
case _MemberData() when $default != null:
return $default(_that.userId,_that.username,_that.displayName,_that.avatarUrl,_that.verificationStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MemberData implements MemberData {
  const _MemberData({required this.userId, required this.username, required this.displayName, required this.avatarUrl, this.verificationStatus = 'none'});
  factory _MemberData.fromJson(Map<String, dynamic> json) => _$MemberDataFromJson(json);

@override final  String userId;
@override final  String username;
@override final  String displayName;
@override final  String avatarUrl;
@override@JsonKey() final  String verificationStatus;

/// Create a copy of MemberData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemberDataCopyWith<_MemberData> get copyWith => __$MemberDataCopyWithImpl<_MemberData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MemberDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MemberData&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username,displayName,avatarUrl,verificationStatus);

@override
String toString() {
  return 'MemberData(userId: $userId, username: $username, displayName: $displayName, avatarUrl: $avatarUrl, verificationStatus: $verificationStatus)';
}


}

/// @nodoc
abstract mixin class _$MemberDataCopyWith<$Res> implements $MemberDataCopyWith<$Res> {
  factory _$MemberDataCopyWith(_MemberData value, $Res Function(_MemberData) _then) = __$MemberDataCopyWithImpl;
@override @useResult
$Res call({
 String userId, String username, String displayName, String avatarUrl, String verificationStatus
});




}
/// @nodoc
class __$MemberDataCopyWithImpl<$Res>
    implements _$MemberDataCopyWith<$Res> {
  __$MemberDataCopyWithImpl(this._self, this._then);

  final _MemberData _self;
  final $Res Function(_MemberData) _then;

/// Create a copy of MemberData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? username = null,Object? displayName = null,Object? avatarUrl = null,Object? verificationStatus = null,}) {
  return _then(_MemberData(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$GymCategory {

 String get id; String get name; String get displayName; String get icon; bool get isActive;
/// Create a copy of GymCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GymCategoryCopyWith<GymCategory> get copyWith => _$GymCategoryCopyWithImpl<GymCategory>(this as GymCategory, _$identity);

  /// Serializes this GymCategory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GymCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,displayName,icon,isActive);

@override
String toString() {
  return 'GymCategory(id: $id, name: $name, displayName: $displayName, icon: $icon, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class $GymCategoryCopyWith<$Res>  {
  factory $GymCategoryCopyWith(GymCategory value, $Res Function(GymCategory) _then) = _$GymCategoryCopyWithImpl;
@useResult
$Res call({
 String id, String name, String displayName, String icon, bool isActive
});




}
/// @nodoc
class _$GymCategoryCopyWithImpl<$Res>
    implements $GymCategoryCopyWith<$Res> {
  _$GymCategoryCopyWithImpl(this._self, this._then);

  final GymCategory _self;
  final $Res Function(GymCategory) _then;

/// Create a copy of GymCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? displayName = null,Object? icon = null,Object? isActive = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [GymCategory].
extension GymCategoryPatterns on GymCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GymCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GymCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GymCategory value)  $default,){
final _that = this;
switch (_that) {
case _GymCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GymCategory value)?  $default,){
final _that = this;
switch (_that) {
case _GymCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String displayName,  String icon,  bool isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GymCategory() when $default != null:
return $default(_that.id,_that.name,_that.displayName,_that.icon,_that.isActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String displayName,  String icon,  bool isActive)  $default,) {final _that = this;
switch (_that) {
case _GymCategory():
return $default(_that.id,_that.name,_that.displayName,_that.icon,_that.isActive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String displayName,  String icon,  bool isActive)?  $default,) {final _that = this;
switch (_that) {
case _GymCategory() when $default != null:
return $default(_that.id,_that.name,_that.displayName,_that.icon,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GymCategory implements GymCategory {
  const _GymCategory({required this.id, required this.name, required this.displayName, this.icon = '', this.isActive = true});
  factory _GymCategory.fromJson(Map<String, dynamic> json) => _$GymCategoryFromJson(json);

@override final  String id;
@override final  String name;
@override final  String displayName;
@override@JsonKey() final  String icon;
@override@JsonKey() final  bool isActive;

/// Create a copy of GymCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GymCategoryCopyWith<_GymCategory> get copyWith => __$GymCategoryCopyWithImpl<_GymCategory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GymCategoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GymCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,displayName,icon,isActive);

@override
String toString() {
  return 'GymCategory(id: $id, name: $name, displayName: $displayName, icon: $icon, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$GymCategoryCopyWith<$Res> implements $GymCategoryCopyWith<$Res> {
  factory _$GymCategoryCopyWith(_GymCategory value, $Res Function(_GymCategory) _then) = __$GymCategoryCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String displayName, String icon, bool isActive
});




}
/// @nodoc
class __$GymCategoryCopyWithImpl<$Res>
    implements _$GymCategoryCopyWith<$Res> {
  __$GymCategoryCopyWithImpl(this._self, this._then);

  final _GymCategory _self;
  final $Res Function(_GymCategory) _then;

/// Create a copy of GymCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? displayName = null,Object? icon = null,Object? isActive = null,}) {
  return _then(_GymCategory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$GymCategoryPricing {

 String? get id; String get category; String? get categoryName; double? get feePerDay; double? get feePerWeek; double? get feePerMonth; double? get feePerYear; bool get isFree;
/// Create a copy of GymCategoryPricing
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GymCategoryPricingCopyWith<GymCategoryPricing> get copyWith => _$GymCategoryPricingCopyWithImpl<GymCategoryPricing>(this as GymCategoryPricing, _$identity);

  /// Serializes this GymCategoryPricing to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GymCategoryPricing&&(identical(other.id, id) || other.id == id)&&(identical(other.category, category) || other.category == category)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.feePerDay, feePerDay) || other.feePerDay == feePerDay)&&(identical(other.feePerWeek, feePerWeek) || other.feePerWeek == feePerWeek)&&(identical(other.feePerMonth, feePerMonth) || other.feePerMonth == feePerMonth)&&(identical(other.feePerYear, feePerYear) || other.feePerYear == feePerYear)&&(identical(other.isFree, isFree) || other.isFree == isFree));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,category,categoryName,feePerDay,feePerWeek,feePerMonth,feePerYear,isFree);

@override
String toString() {
  return 'GymCategoryPricing(id: $id, category: $category, categoryName: $categoryName, feePerDay: $feePerDay, feePerWeek: $feePerWeek, feePerMonth: $feePerMonth, feePerYear: $feePerYear, isFree: $isFree)';
}


}

/// @nodoc
abstract mixin class $GymCategoryPricingCopyWith<$Res>  {
  factory $GymCategoryPricingCopyWith(GymCategoryPricing value, $Res Function(GymCategoryPricing) _then) = _$GymCategoryPricingCopyWithImpl;
@useResult
$Res call({
 String? id, String category, String? categoryName, double? feePerDay, double? feePerWeek, double? feePerMonth, double? feePerYear, bool isFree
});




}
/// @nodoc
class _$GymCategoryPricingCopyWithImpl<$Res>
    implements $GymCategoryPricingCopyWith<$Res> {
  _$GymCategoryPricingCopyWithImpl(this._self, this._then);

  final GymCategoryPricing _self;
  final $Res Function(GymCategoryPricing) _then;

/// Create a copy of GymCategoryPricing
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? category = null,Object? categoryName = freezed,Object? feePerDay = freezed,Object? feePerWeek = freezed,Object? feePerMonth = freezed,Object? feePerYear = freezed,Object? isFree = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,categoryName: freezed == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String?,feePerDay: freezed == feePerDay ? _self.feePerDay : feePerDay // ignore: cast_nullable_to_non_nullable
as double?,feePerWeek: freezed == feePerWeek ? _self.feePerWeek : feePerWeek // ignore: cast_nullable_to_non_nullable
as double?,feePerMonth: freezed == feePerMonth ? _self.feePerMonth : feePerMonth // ignore: cast_nullable_to_non_nullable
as double?,feePerYear: freezed == feePerYear ? _self.feePerYear : feePerYear // ignore: cast_nullable_to_non_nullable
as double?,isFree: null == isFree ? _self.isFree : isFree // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [GymCategoryPricing].
extension GymCategoryPricingPatterns on GymCategoryPricing {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GymCategoryPricing value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GymCategoryPricing() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GymCategoryPricing value)  $default,){
final _that = this;
switch (_that) {
case _GymCategoryPricing():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GymCategoryPricing value)?  $default,){
final _that = this;
switch (_that) {
case _GymCategoryPricing() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String category,  String? categoryName,  double? feePerDay,  double? feePerWeek,  double? feePerMonth,  double? feePerYear,  bool isFree)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GymCategoryPricing() when $default != null:
return $default(_that.id,_that.category,_that.categoryName,_that.feePerDay,_that.feePerWeek,_that.feePerMonth,_that.feePerYear,_that.isFree);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String category,  String? categoryName,  double? feePerDay,  double? feePerWeek,  double? feePerMonth,  double? feePerYear,  bool isFree)  $default,) {final _that = this;
switch (_that) {
case _GymCategoryPricing():
return $default(_that.id,_that.category,_that.categoryName,_that.feePerDay,_that.feePerWeek,_that.feePerMonth,_that.feePerYear,_that.isFree);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String category,  String? categoryName,  double? feePerDay,  double? feePerWeek,  double? feePerMonth,  double? feePerYear,  bool isFree)?  $default,) {final _that = this;
switch (_that) {
case _GymCategoryPricing() when $default != null:
return $default(_that.id,_that.category,_that.categoryName,_that.feePerDay,_that.feePerWeek,_that.feePerMonth,_that.feePerYear,_that.isFree);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GymCategoryPricing implements GymCategoryPricing {
  const _GymCategoryPricing({this.id, required this.category, this.categoryName, this.feePerDay, this.feePerWeek, this.feePerMonth, this.feePerYear, this.isFree = false});
  factory _GymCategoryPricing.fromJson(Map<String, dynamic> json) => _$GymCategoryPricingFromJson(json);

@override final  String? id;
@override final  String category;
@override final  String? categoryName;
@override final  double? feePerDay;
@override final  double? feePerWeek;
@override final  double? feePerMonth;
@override final  double? feePerYear;
@override@JsonKey() final  bool isFree;

/// Create a copy of GymCategoryPricing
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GymCategoryPricingCopyWith<_GymCategoryPricing> get copyWith => __$GymCategoryPricingCopyWithImpl<_GymCategoryPricing>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GymCategoryPricingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GymCategoryPricing&&(identical(other.id, id) || other.id == id)&&(identical(other.category, category) || other.category == category)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.feePerDay, feePerDay) || other.feePerDay == feePerDay)&&(identical(other.feePerWeek, feePerWeek) || other.feePerWeek == feePerWeek)&&(identical(other.feePerMonth, feePerMonth) || other.feePerMonth == feePerMonth)&&(identical(other.feePerYear, feePerYear) || other.feePerYear == feePerYear)&&(identical(other.isFree, isFree) || other.isFree == isFree));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,category,categoryName,feePerDay,feePerWeek,feePerMonth,feePerYear,isFree);

@override
String toString() {
  return 'GymCategoryPricing(id: $id, category: $category, categoryName: $categoryName, feePerDay: $feePerDay, feePerWeek: $feePerWeek, feePerMonth: $feePerMonth, feePerYear: $feePerYear, isFree: $isFree)';
}


}

/// @nodoc
abstract mixin class _$GymCategoryPricingCopyWith<$Res> implements $GymCategoryPricingCopyWith<$Res> {
  factory _$GymCategoryPricingCopyWith(_GymCategoryPricing value, $Res Function(_GymCategoryPricing) _then) = __$GymCategoryPricingCopyWithImpl;
@override @useResult
$Res call({
 String? id, String category, String? categoryName, double? feePerDay, double? feePerWeek, double? feePerMonth, double? feePerYear, bool isFree
});




}
/// @nodoc
class __$GymCategoryPricingCopyWithImpl<$Res>
    implements _$GymCategoryPricingCopyWith<$Res> {
  __$GymCategoryPricingCopyWithImpl(this._self, this._then);

  final _GymCategoryPricing _self;
  final $Res Function(_GymCategoryPricing) _then;

/// Create a copy of GymCategoryPricing
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? category = null,Object? categoryName = freezed,Object? feePerDay = freezed,Object? feePerWeek = freezed,Object? feePerMonth = freezed,Object? feePerYear = freezed,Object? isFree = null,}) {
  return _then(_GymCategoryPricing(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,categoryName: freezed == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String?,feePerDay: freezed == feePerDay ? _self.feePerDay : feePerDay // ignore: cast_nullable_to_non_nullable
as double?,feePerWeek: freezed == feePerWeek ? _self.feePerWeek : feePerWeek // ignore: cast_nullable_to_non_nullable
as double?,feePerMonth: freezed == feePerMonth ? _self.feePerMonth : feePerMonth // ignore: cast_nullable_to_non_nullable
as double?,feePerYear: freezed == feePerYear ? _self.feePerYear : feePerYear // ignore: cast_nullable_to_non_nullable
as double?,isFree: null == isFree ? _self.isFree : isFree // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$Gym {

 String get id; String get name; String get handle; String get description; String get logoUrl; String get coverUrl; String get category; List<GymCategory> get categories; String get accessType; String get subscriptionType; bool get isVerified; bool get isReviewsEnabled; bool get isDonationsEnabled; double? get averageRating; int get reviewCount; List<MemberData> get recentReviewers; List<String> get rules; List<String> get tags; int get memberCount; int get activeToday; String get locationCity; String get locationCountry; List<OwnerData> get ownerData; String? get membershipRole; bool get isMember; String get createdAt; String? get updatedAt;
/// Create a copy of Gym
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GymCopyWith<Gym> get copyWith => _$GymCopyWithImpl<Gym>(this as Gym, _$identity);

  /// Serializes this Gym to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Gym&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.handle, handle) || other.handle == handle)&&(identical(other.description, description) || other.description == description)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.categories, categories)&&(identical(other.accessType, accessType) || other.accessType == accessType)&&(identical(other.subscriptionType, subscriptionType) || other.subscriptionType == subscriptionType)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.isReviewsEnabled, isReviewsEnabled) || other.isReviewsEnabled == isReviewsEnabled)&&(identical(other.isDonationsEnabled, isDonationsEnabled) || other.isDonationsEnabled == isDonationsEnabled)&&(identical(other.averageRating, averageRating) || other.averageRating == averageRating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&const DeepCollectionEquality().equals(other.recentReviewers, recentReviewers)&&const DeepCollectionEquality().equals(other.rules, rules)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount)&&(identical(other.activeToday, activeToday) || other.activeToday == activeToday)&&(identical(other.locationCity, locationCity) || other.locationCity == locationCity)&&(identical(other.locationCountry, locationCountry) || other.locationCountry == locationCountry)&&const DeepCollectionEquality().equals(other.ownerData, ownerData)&&(identical(other.membershipRole, membershipRole) || other.membershipRole == membershipRole)&&(identical(other.isMember, isMember) || other.isMember == isMember)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,handle,description,logoUrl,coverUrl,category,const DeepCollectionEquality().hash(categories),accessType,subscriptionType,isVerified,isReviewsEnabled,isDonationsEnabled,averageRating,reviewCount,const DeepCollectionEquality().hash(recentReviewers),const DeepCollectionEquality().hash(rules),const DeepCollectionEquality().hash(tags),memberCount,activeToday,locationCity,locationCountry,const DeepCollectionEquality().hash(ownerData),membershipRole,isMember,createdAt,updatedAt]);

@override
String toString() {
  return 'Gym(id: $id, name: $name, handle: $handle, description: $description, logoUrl: $logoUrl, coverUrl: $coverUrl, category: $category, categories: $categories, accessType: $accessType, subscriptionType: $subscriptionType, isVerified: $isVerified, isReviewsEnabled: $isReviewsEnabled, isDonationsEnabled: $isDonationsEnabled, averageRating: $averageRating, reviewCount: $reviewCount, recentReviewers: $recentReviewers, rules: $rules, tags: $tags, memberCount: $memberCount, activeToday: $activeToday, locationCity: $locationCity, locationCountry: $locationCountry, ownerData: $ownerData, membershipRole: $membershipRole, isMember: $isMember, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $GymCopyWith<$Res>  {
  factory $GymCopyWith(Gym value, $Res Function(Gym) _then) = _$GymCopyWithImpl;
@useResult
$Res call({
 String id, String name, String handle, String description, String logoUrl, String coverUrl, String category, List<GymCategory> categories, String accessType, String subscriptionType, bool isVerified, bool isReviewsEnabled, bool isDonationsEnabled, double? averageRating, int reviewCount, List<MemberData> recentReviewers, List<String> rules, List<String> tags, int memberCount, int activeToday, String locationCity, String locationCountry, List<OwnerData> ownerData, String? membershipRole, bool isMember, String createdAt, String? updatedAt
});




}
/// @nodoc
class _$GymCopyWithImpl<$Res>
    implements $GymCopyWith<$Res> {
  _$GymCopyWithImpl(this._self, this._then);

  final Gym _self;
  final $Res Function(Gym) _then;

/// Create a copy of Gym
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? handle = null,Object? description = null,Object? logoUrl = null,Object? coverUrl = null,Object? category = null,Object? categories = null,Object? accessType = null,Object? subscriptionType = null,Object? isVerified = null,Object? isReviewsEnabled = null,Object? isDonationsEnabled = null,Object? averageRating = freezed,Object? reviewCount = null,Object? recentReviewers = null,Object? rules = null,Object? tags = null,Object? memberCount = null,Object? activeToday = null,Object? locationCity = null,Object? locationCountry = null,Object? ownerData = null,Object? membershipRole = freezed,Object? isMember = null,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,logoUrl: null == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<GymCategory>,accessType: null == accessType ? _self.accessType : accessType // ignore: cast_nullable_to_non_nullable
as String,subscriptionType: null == subscriptionType ? _self.subscriptionType : subscriptionType // ignore: cast_nullable_to_non_nullable
as String,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,isReviewsEnabled: null == isReviewsEnabled ? _self.isReviewsEnabled : isReviewsEnabled // ignore: cast_nullable_to_non_nullable
as bool,isDonationsEnabled: null == isDonationsEnabled ? _self.isDonationsEnabled : isDonationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,averageRating: freezed == averageRating ? _self.averageRating : averageRating // ignore: cast_nullable_to_non_nullable
as double?,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,recentReviewers: null == recentReviewers ? _self.recentReviewers : recentReviewers // ignore: cast_nullable_to_non_nullable
as List<MemberData>,rules: null == rules ? _self.rules : rules // ignore: cast_nullable_to_non_nullable
as List<String>,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,activeToday: null == activeToday ? _self.activeToday : activeToday // ignore: cast_nullable_to_non_nullable
as int,locationCity: null == locationCity ? _self.locationCity : locationCity // ignore: cast_nullable_to_non_nullable
as String,locationCountry: null == locationCountry ? _self.locationCountry : locationCountry // ignore: cast_nullable_to_non_nullable
as String,ownerData: null == ownerData ? _self.ownerData : ownerData // ignore: cast_nullable_to_non_nullable
as List<OwnerData>,membershipRole: freezed == membershipRole ? _self.membershipRole : membershipRole // ignore: cast_nullable_to_non_nullable
as String?,isMember: null == isMember ? _self.isMember : isMember // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Gym].
extension GymPatterns on Gym {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Gym value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Gym() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Gym value)  $default,){
final _that = this;
switch (_that) {
case _Gym():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Gym value)?  $default,){
final _that = this;
switch (_that) {
case _Gym() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String handle,  String description,  String logoUrl,  String coverUrl,  String category,  List<GymCategory> categories,  String accessType,  String subscriptionType,  bool isVerified,  bool isReviewsEnabled,  bool isDonationsEnabled,  double? averageRating,  int reviewCount,  List<MemberData> recentReviewers,  List<String> rules,  List<String> tags,  int memberCount,  int activeToday,  String locationCity,  String locationCountry,  List<OwnerData> ownerData,  String? membershipRole,  bool isMember,  String createdAt,  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Gym() when $default != null:
return $default(_that.id,_that.name,_that.handle,_that.description,_that.logoUrl,_that.coverUrl,_that.category,_that.categories,_that.accessType,_that.subscriptionType,_that.isVerified,_that.isReviewsEnabled,_that.isDonationsEnabled,_that.averageRating,_that.reviewCount,_that.recentReviewers,_that.rules,_that.tags,_that.memberCount,_that.activeToday,_that.locationCity,_that.locationCountry,_that.ownerData,_that.membershipRole,_that.isMember,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String handle,  String description,  String logoUrl,  String coverUrl,  String category,  List<GymCategory> categories,  String accessType,  String subscriptionType,  bool isVerified,  bool isReviewsEnabled,  bool isDonationsEnabled,  double? averageRating,  int reviewCount,  List<MemberData> recentReviewers,  List<String> rules,  List<String> tags,  int memberCount,  int activeToday,  String locationCity,  String locationCountry,  List<OwnerData> ownerData,  String? membershipRole,  bool isMember,  String createdAt,  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Gym():
return $default(_that.id,_that.name,_that.handle,_that.description,_that.logoUrl,_that.coverUrl,_that.category,_that.categories,_that.accessType,_that.subscriptionType,_that.isVerified,_that.isReviewsEnabled,_that.isDonationsEnabled,_that.averageRating,_that.reviewCount,_that.recentReviewers,_that.rules,_that.tags,_that.memberCount,_that.activeToday,_that.locationCity,_that.locationCountry,_that.ownerData,_that.membershipRole,_that.isMember,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String handle,  String description,  String logoUrl,  String coverUrl,  String category,  List<GymCategory> categories,  String accessType,  String subscriptionType,  bool isVerified,  bool isReviewsEnabled,  bool isDonationsEnabled,  double? averageRating,  int reviewCount,  List<MemberData> recentReviewers,  List<String> rules,  List<String> tags,  int memberCount,  int activeToday,  String locationCity,  String locationCountry,  List<OwnerData> ownerData,  String? membershipRole,  bool isMember,  String createdAt,  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Gym() when $default != null:
return $default(_that.id,_that.name,_that.handle,_that.description,_that.logoUrl,_that.coverUrl,_that.category,_that.categories,_that.accessType,_that.subscriptionType,_that.isVerified,_that.isReviewsEnabled,_that.isDonationsEnabled,_that.averageRating,_that.reviewCount,_that.recentReviewers,_that.rules,_that.tags,_that.memberCount,_that.activeToday,_that.locationCity,_that.locationCountry,_that.ownerData,_that.membershipRole,_that.isMember,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Gym implements Gym {
  const _Gym({required this.id, required this.name, required this.handle, this.description = '', this.logoUrl = '', this.coverUrl = '', this.category = '', final  List<GymCategory> categories = const <GymCategory>[], this.accessType = 'public', this.subscriptionType = 'free', this.isVerified = false, this.isReviewsEnabled = true, this.isDonationsEnabled = false, this.averageRating, this.reviewCount = 0, final  List<MemberData> recentReviewers = const <MemberData>[], final  List<String> rules = const <String>[], final  List<String> tags = const <String>[], this.memberCount = 0, this.activeToday = 0, this.locationCity = '', this.locationCountry = '', final  List<OwnerData> ownerData = const <OwnerData>[], this.membershipRole, this.isMember = false, required this.createdAt, this.updatedAt}): _categories = categories,_recentReviewers = recentReviewers,_rules = rules,_tags = tags,_ownerData = ownerData;
  factory _Gym.fromJson(Map<String, dynamic> json) => _$GymFromJson(json);

@override final  String id;
@override final  String name;
@override final  String handle;
@override@JsonKey() final  String description;
@override@JsonKey() final  String logoUrl;
@override@JsonKey() final  String coverUrl;
@override@JsonKey() final  String category;
 final  List<GymCategory> _categories;
@override@JsonKey() List<GymCategory> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

@override@JsonKey() final  String accessType;
@override@JsonKey() final  String subscriptionType;
@override@JsonKey() final  bool isVerified;
@override@JsonKey() final  bool isReviewsEnabled;
@override@JsonKey() final  bool isDonationsEnabled;
@override final  double? averageRating;
@override@JsonKey() final  int reviewCount;
 final  List<MemberData> _recentReviewers;
@override@JsonKey() List<MemberData> get recentReviewers {
  if (_recentReviewers is EqualUnmodifiableListView) return _recentReviewers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentReviewers);
}

 final  List<String> _rules;
@override@JsonKey() List<String> get rules {
  if (_rules is EqualUnmodifiableListView) return _rules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rules);
}

 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override@JsonKey() final  int memberCount;
@override@JsonKey() final  int activeToday;
@override@JsonKey() final  String locationCity;
@override@JsonKey() final  String locationCountry;
 final  List<OwnerData> _ownerData;
@override@JsonKey() List<OwnerData> get ownerData {
  if (_ownerData is EqualUnmodifiableListView) return _ownerData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ownerData);
}

@override final  String? membershipRole;
@override@JsonKey() final  bool isMember;
@override final  String createdAt;
@override final  String? updatedAt;

/// Create a copy of Gym
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GymCopyWith<_Gym> get copyWith => __$GymCopyWithImpl<_Gym>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GymToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Gym&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.handle, handle) || other.handle == handle)&&(identical(other.description, description) || other.description == description)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other._categories, _categories)&&(identical(other.accessType, accessType) || other.accessType == accessType)&&(identical(other.subscriptionType, subscriptionType) || other.subscriptionType == subscriptionType)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.isReviewsEnabled, isReviewsEnabled) || other.isReviewsEnabled == isReviewsEnabled)&&(identical(other.isDonationsEnabled, isDonationsEnabled) || other.isDonationsEnabled == isDonationsEnabled)&&(identical(other.averageRating, averageRating) || other.averageRating == averageRating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&const DeepCollectionEquality().equals(other._recentReviewers, _recentReviewers)&&const DeepCollectionEquality().equals(other._rules, _rules)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount)&&(identical(other.activeToday, activeToday) || other.activeToday == activeToday)&&(identical(other.locationCity, locationCity) || other.locationCity == locationCity)&&(identical(other.locationCountry, locationCountry) || other.locationCountry == locationCountry)&&const DeepCollectionEquality().equals(other._ownerData, _ownerData)&&(identical(other.membershipRole, membershipRole) || other.membershipRole == membershipRole)&&(identical(other.isMember, isMember) || other.isMember == isMember)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,handle,description,logoUrl,coverUrl,category,const DeepCollectionEquality().hash(_categories),accessType,subscriptionType,isVerified,isReviewsEnabled,isDonationsEnabled,averageRating,reviewCount,const DeepCollectionEquality().hash(_recentReviewers),const DeepCollectionEquality().hash(_rules),const DeepCollectionEquality().hash(_tags),memberCount,activeToday,locationCity,locationCountry,const DeepCollectionEquality().hash(_ownerData),membershipRole,isMember,createdAt,updatedAt]);

@override
String toString() {
  return 'Gym(id: $id, name: $name, handle: $handle, description: $description, logoUrl: $logoUrl, coverUrl: $coverUrl, category: $category, categories: $categories, accessType: $accessType, subscriptionType: $subscriptionType, isVerified: $isVerified, isReviewsEnabled: $isReviewsEnabled, isDonationsEnabled: $isDonationsEnabled, averageRating: $averageRating, reviewCount: $reviewCount, recentReviewers: $recentReviewers, rules: $rules, tags: $tags, memberCount: $memberCount, activeToday: $activeToday, locationCity: $locationCity, locationCountry: $locationCountry, ownerData: $ownerData, membershipRole: $membershipRole, isMember: $isMember, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$GymCopyWith<$Res> implements $GymCopyWith<$Res> {
  factory _$GymCopyWith(_Gym value, $Res Function(_Gym) _then) = __$GymCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String handle, String description, String logoUrl, String coverUrl, String category, List<GymCategory> categories, String accessType, String subscriptionType, bool isVerified, bool isReviewsEnabled, bool isDonationsEnabled, double? averageRating, int reviewCount, List<MemberData> recentReviewers, List<String> rules, List<String> tags, int memberCount, int activeToday, String locationCity, String locationCountry, List<OwnerData> ownerData, String? membershipRole, bool isMember, String createdAt, String? updatedAt
});




}
/// @nodoc
class __$GymCopyWithImpl<$Res>
    implements _$GymCopyWith<$Res> {
  __$GymCopyWithImpl(this._self, this._then);

  final _Gym _self;
  final $Res Function(_Gym) _then;

/// Create a copy of Gym
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? handle = null,Object? description = null,Object? logoUrl = null,Object? coverUrl = null,Object? category = null,Object? categories = null,Object? accessType = null,Object? subscriptionType = null,Object? isVerified = null,Object? isReviewsEnabled = null,Object? isDonationsEnabled = null,Object? averageRating = freezed,Object? reviewCount = null,Object? recentReviewers = null,Object? rules = null,Object? tags = null,Object? memberCount = null,Object? activeToday = null,Object? locationCity = null,Object? locationCountry = null,Object? ownerData = null,Object? membershipRole = freezed,Object? isMember = null,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_Gym(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,logoUrl: null == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<GymCategory>,accessType: null == accessType ? _self.accessType : accessType // ignore: cast_nullable_to_non_nullable
as String,subscriptionType: null == subscriptionType ? _self.subscriptionType : subscriptionType // ignore: cast_nullable_to_non_nullable
as String,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,isReviewsEnabled: null == isReviewsEnabled ? _self.isReviewsEnabled : isReviewsEnabled // ignore: cast_nullable_to_non_nullable
as bool,isDonationsEnabled: null == isDonationsEnabled ? _self.isDonationsEnabled : isDonationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,averageRating: freezed == averageRating ? _self.averageRating : averageRating // ignore: cast_nullable_to_non_nullable
as double?,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,recentReviewers: null == recentReviewers ? _self._recentReviewers : recentReviewers // ignore: cast_nullable_to_non_nullable
as List<MemberData>,rules: null == rules ? _self._rules : rules // ignore: cast_nullable_to_non_nullable
as List<String>,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,activeToday: null == activeToday ? _self.activeToday : activeToday // ignore: cast_nullable_to_non_nullable
as int,locationCity: null == locationCity ? _self.locationCity : locationCity // ignore: cast_nullable_to_non_nullable
as String,locationCountry: null == locationCountry ? _self.locationCountry : locationCountry // ignore: cast_nullable_to_non_nullable
as String,ownerData: null == ownerData ? _self._ownerData : ownerData // ignore: cast_nullable_to_non_nullable
as List<OwnerData>,membershipRole: freezed == membershipRole ? _self.membershipRole : membershipRole // ignore: cast_nullable_to_non_nullable
as String?,isMember: null == isMember ? _self.isMember : isMember // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$GymMembership {

 String get id; String get gymId; String get memberId; String get role; bool get subscriptionActive; String? get subscriptionExpiresAt; MemberData get memberData; String get createdAt;
/// Create a copy of GymMembership
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GymMembershipCopyWith<GymMembership> get copyWith => _$GymMembershipCopyWithImpl<GymMembership>(this as GymMembership, _$identity);

  /// Serializes this GymMembership to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GymMembership&&(identical(other.id, id) || other.id == id)&&(identical(other.gymId, gymId) || other.gymId == gymId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.role, role) || other.role == role)&&(identical(other.subscriptionActive, subscriptionActive) || other.subscriptionActive == subscriptionActive)&&(identical(other.subscriptionExpiresAt, subscriptionExpiresAt) || other.subscriptionExpiresAt == subscriptionExpiresAt)&&(identical(other.memberData, memberData) || other.memberData == memberData)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,gymId,memberId,role,subscriptionActive,subscriptionExpiresAt,memberData,createdAt);

@override
String toString() {
  return 'GymMembership(id: $id, gymId: $gymId, memberId: $memberId, role: $role, subscriptionActive: $subscriptionActive, subscriptionExpiresAt: $subscriptionExpiresAt, memberData: $memberData, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $GymMembershipCopyWith<$Res>  {
  factory $GymMembershipCopyWith(GymMembership value, $Res Function(GymMembership) _then) = _$GymMembershipCopyWithImpl;
@useResult
$Res call({
 String id, String gymId, String memberId, String role, bool subscriptionActive, String? subscriptionExpiresAt, MemberData memberData, String createdAt
});


$MemberDataCopyWith<$Res> get memberData;

}
/// @nodoc
class _$GymMembershipCopyWithImpl<$Res>
    implements $GymMembershipCopyWith<$Res> {
  _$GymMembershipCopyWithImpl(this._self, this._then);

  final GymMembership _self;
  final $Res Function(GymMembership) _then;

/// Create a copy of GymMembership
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? gymId = null,Object? memberId = null,Object? role = null,Object? subscriptionActive = null,Object? subscriptionExpiresAt = freezed,Object? memberData = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,gymId: null == gymId ? _self.gymId : gymId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,subscriptionActive: null == subscriptionActive ? _self.subscriptionActive : subscriptionActive // ignore: cast_nullable_to_non_nullable
as bool,subscriptionExpiresAt: freezed == subscriptionExpiresAt ? _self.subscriptionExpiresAt : subscriptionExpiresAt // ignore: cast_nullable_to_non_nullable
as String?,memberData: null == memberData ? _self.memberData : memberData // ignore: cast_nullable_to_non_nullable
as MemberData,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of GymMembership
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MemberDataCopyWith<$Res> get memberData {
  
  return $MemberDataCopyWith<$Res>(_self.memberData, (value) {
    return _then(_self.copyWith(memberData: value));
  });
}
}


/// Adds pattern-matching-related methods to [GymMembership].
extension GymMembershipPatterns on GymMembership {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GymMembership value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GymMembership() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GymMembership value)  $default,){
final _that = this;
switch (_that) {
case _GymMembership():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GymMembership value)?  $default,){
final _that = this;
switch (_that) {
case _GymMembership() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String gymId,  String memberId,  String role,  bool subscriptionActive,  String? subscriptionExpiresAt,  MemberData memberData,  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GymMembership() when $default != null:
return $default(_that.id,_that.gymId,_that.memberId,_that.role,_that.subscriptionActive,_that.subscriptionExpiresAt,_that.memberData,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String gymId,  String memberId,  String role,  bool subscriptionActive,  String? subscriptionExpiresAt,  MemberData memberData,  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _GymMembership():
return $default(_that.id,_that.gymId,_that.memberId,_that.role,_that.subscriptionActive,_that.subscriptionExpiresAt,_that.memberData,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String gymId,  String memberId,  String role,  bool subscriptionActive,  String? subscriptionExpiresAt,  MemberData memberData,  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _GymMembership() when $default != null:
return $default(_that.id,_that.gymId,_that.memberId,_that.role,_that.subscriptionActive,_that.subscriptionExpiresAt,_that.memberData,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GymMembership implements GymMembership {
  const _GymMembership({required this.id, required this.gymId, required this.memberId, this.role = 'member', this.subscriptionActive = false, this.subscriptionExpiresAt, required this.memberData, required this.createdAt});
  factory _GymMembership.fromJson(Map<String, dynamic> json) => _$GymMembershipFromJson(json);

@override final  String id;
@override final  String gymId;
@override final  String memberId;
@override@JsonKey() final  String role;
@override@JsonKey() final  bool subscriptionActive;
@override final  String? subscriptionExpiresAt;
@override final  MemberData memberData;
@override final  String createdAt;

/// Create a copy of GymMembership
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GymMembershipCopyWith<_GymMembership> get copyWith => __$GymMembershipCopyWithImpl<_GymMembership>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GymMembershipToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GymMembership&&(identical(other.id, id) || other.id == id)&&(identical(other.gymId, gymId) || other.gymId == gymId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.role, role) || other.role == role)&&(identical(other.subscriptionActive, subscriptionActive) || other.subscriptionActive == subscriptionActive)&&(identical(other.subscriptionExpiresAt, subscriptionExpiresAt) || other.subscriptionExpiresAt == subscriptionExpiresAt)&&(identical(other.memberData, memberData) || other.memberData == memberData)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,gymId,memberId,role,subscriptionActive,subscriptionExpiresAt,memberData,createdAt);

@override
String toString() {
  return 'GymMembership(id: $id, gymId: $gymId, memberId: $memberId, role: $role, subscriptionActive: $subscriptionActive, subscriptionExpiresAt: $subscriptionExpiresAt, memberData: $memberData, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$GymMembershipCopyWith<$Res> implements $GymMembershipCopyWith<$Res> {
  factory _$GymMembershipCopyWith(_GymMembership value, $Res Function(_GymMembership) _then) = __$GymMembershipCopyWithImpl;
@override @useResult
$Res call({
 String id, String gymId, String memberId, String role, bool subscriptionActive, String? subscriptionExpiresAt, MemberData memberData, String createdAt
});


@override $MemberDataCopyWith<$Res> get memberData;

}
/// @nodoc
class __$GymMembershipCopyWithImpl<$Res>
    implements _$GymMembershipCopyWith<$Res> {
  __$GymMembershipCopyWithImpl(this._self, this._then);

  final _GymMembership _self;
  final $Res Function(_GymMembership) _then;

/// Create a copy of GymMembership
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? gymId = null,Object? memberId = null,Object? role = null,Object? subscriptionActive = null,Object? subscriptionExpiresAt = freezed,Object? memberData = null,Object? createdAt = null,}) {
  return _then(_GymMembership(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,gymId: null == gymId ? _self.gymId : gymId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,subscriptionActive: null == subscriptionActive ? _self.subscriptionActive : subscriptionActive // ignore: cast_nullable_to_non_nullable
as bool,subscriptionExpiresAt: freezed == subscriptionExpiresAt ? _self.subscriptionExpiresAt : subscriptionExpiresAt // ignore: cast_nullable_to_non_nullable
as String?,memberData: null == memberData ? _self.memberData : memberData // ignore: cast_nullable_to_non_nullable
as MemberData,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of GymMembership
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MemberDataCopyWith<$Res> get memberData {
  
  return $MemberDataCopyWith<$Res>(_self.memberData, (value) {
    return _then(_self.copyWith(memberData: value));
  });
}
}


/// @nodoc
mixin _$JoinRequest {

 String get id; String get gymId; String get requester; MemberData get requesterData; String get message; String get status; String? get reviewedBy; String? get reviewedAt; String get createdAt;
/// Create a copy of JoinRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JoinRequestCopyWith<JoinRequest> get copyWith => _$JoinRequestCopyWithImpl<JoinRequest>(this as JoinRequest, _$identity);

  /// Serializes this JoinRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JoinRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.gymId, gymId) || other.gymId == gymId)&&(identical(other.requester, requester) || other.requester == requester)&&(identical(other.requesterData, requesterData) || other.requesterData == requesterData)&&(identical(other.message, message) || other.message == message)&&(identical(other.status, status) || other.status == status)&&(identical(other.reviewedBy, reviewedBy) || other.reviewedBy == reviewedBy)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,gymId,requester,requesterData,message,status,reviewedBy,reviewedAt,createdAt);

@override
String toString() {
  return 'JoinRequest(id: $id, gymId: $gymId, requester: $requester, requesterData: $requesterData, message: $message, status: $status, reviewedBy: $reviewedBy, reviewedAt: $reviewedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $JoinRequestCopyWith<$Res>  {
  factory $JoinRequestCopyWith(JoinRequest value, $Res Function(JoinRequest) _then) = _$JoinRequestCopyWithImpl;
@useResult
$Res call({
 String id, String gymId, String requester, MemberData requesterData, String message, String status, String? reviewedBy, String? reviewedAt, String createdAt
});


$MemberDataCopyWith<$Res> get requesterData;

}
/// @nodoc
class _$JoinRequestCopyWithImpl<$Res>
    implements $JoinRequestCopyWith<$Res> {
  _$JoinRequestCopyWithImpl(this._self, this._then);

  final JoinRequest _self;
  final $Res Function(JoinRequest) _then;

/// Create a copy of JoinRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? gymId = null,Object? requester = null,Object? requesterData = null,Object? message = null,Object? status = null,Object? reviewedBy = freezed,Object? reviewedAt = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,gymId: null == gymId ? _self.gymId : gymId // ignore: cast_nullable_to_non_nullable
as String,requester: null == requester ? _self.requester : requester // ignore: cast_nullable_to_non_nullable
as String,requesterData: null == requesterData ? _self.requesterData : requesterData // ignore: cast_nullable_to_non_nullable
as MemberData,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,reviewedBy: freezed == reviewedBy ? _self.reviewedBy : reviewedBy // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of JoinRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MemberDataCopyWith<$Res> get requesterData {
  
  return $MemberDataCopyWith<$Res>(_self.requesterData, (value) {
    return _then(_self.copyWith(requesterData: value));
  });
}
}


/// Adds pattern-matching-related methods to [JoinRequest].
extension JoinRequestPatterns on JoinRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JoinRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JoinRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JoinRequest value)  $default,){
final _that = this;
switch (_that) {
case _JoinRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JoinRequest value)?  $default,){
final _that = this;
switch (_that) {
case _JoinRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String gymId,  String requester,  MemberData requesterData,  String message,  String status,  String? reviewedBy,  String? reviewedAt,  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JoinRequest() when $default != null:
return $default(_that.id,_that.gymId,_that.requester,_that.requesterData,_that.message,_that.status,_that.reviewedBy,_that.reviewedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String gymId,  String requester,  MemberData requesterData,  String message,  String status,  String? reviewedBy,  String? reviewedAt,  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _JoinRequest():
return $default(_that.id,_that.gymId,_that.requester,_that.requesterData,_that.message,_that.status,_that.reviewedBy,_that.reviewedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String gymId,  String requester,  MemberData requesterData,  String message,  String status,  String? reviewedBy,  String? reviewedAt,  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _JoinRequest() when $default != null:
return $default(_that.id,_that.gymId,_that.requester,_that.requesterData,_that.message,_that.status,_that.reviewedBy,_that.reviewedAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _JoinRequest implements JoinRequest {
  const _JoinRequest({required this.id, required this.gymId, required this.requester, required this.requesterData, this.message = '', this.status = 'pending', this.reviewedBy, this.reviewedAt, required this.createdAt});
  factory _JoinRequest.fromJson(Map<String, dynamic> json) => _$JoinRequestFromJson(json);

@override final  String id;
@override final  String gymId;
@override final  String requester;
@override final  MemberData requesterData;
@override@JsonKey() final  String message;
@override@JsonKey() final  String status;
@override final  String? reviewedBy;
@override final  String? reviewedAt;
@override final  String createdAt;

/// Create a copy of JoinRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JoinRequestCopyWith<_JoinRequest> get copyWith => __$JoinRequestCopyWithImpl<_JoinRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$JoinRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _JoinRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.gymId, gymId) || other.gymId == gymId)&&(identical(other.requester, requester) || other.requester == requester)&&(identical(other.requesterData, requesterData) || other.requesterData == requesterData)&&(identical(other.message, message) || other.message == message)&&(identical(other.status, status) || other.status == status)&&(identical(other.reviewedBy, reviewedBy) || other.reviewedBy == reviewedBy)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,gymId,requester,requesterData,message,status,reviewedBy,reviewedAt,createdAt);

@override
String toString() {
  return 'JoinRequest(id: $id, gymId: $gymId, requester: $requester, requesterData: $requesterData, message: $message, status: $status, reviewedBy: $reviewedBy, reviewedAt: $reviewedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$JoinRequestCopyWith<$Res> implements $JoinRequestCopyWith<$Res> {
  factory _$JoinRequestCopyWith(_JoinRequest value, $Res Function(_JoinRequest) _then) = __$JoinRequestCopyWithImpl;
@override @useResult
$Res call({
 String id, String gymId, String requester, MemberData requesterData, String message, String status, String? reviewedBy, String? reviewedAt, String createdAt
});


@override $MemberDataCopyWith<$Res> get requesterData;

}
/// @nodoc
class __$JoinRequestCopyWithImpl<$Res>
    implements _$JoinRequestCopyWith<$Res> {
  __$JoinRequestCopyWithImpl(this._self, this._then);

  final _JoinRequest _self;
  final $Res Function(_JoinRequest) _then;

/// Create a copy of JoinRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? gymId = null,Object? requester = null,Object? requesterData = null,Object? message = null,Object? status = null,Object? reviewedBy = freezed,Object? reviewedAt = freezed,Object? createdAt = null,}) {
  return _then(_JoinRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,gymId: null == gymId ? _self.gymId : gymId // ignore: cast_nullable_to_non_nullable
as String,requester: null == requester ? _self.requester : requester // ignore: cast_nullable_to_non_nullable
as String,requesterData: null == requesterData ? _self.requesterData : requesterData // ignore: cast_nullable_to_non_nullable
as MemberData,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,reviewedBy: freezed == reviewedBy ? _self.reviewedBy : reviewedBy // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of JoinRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MemberDataCopyWith<$Res> get requesterData {
  
  return $MemberDataCopyWith<$Res>(_self.requesterData, (value) {
    return _then(_self.copyWith(requesterData: value));
  });
}
}


/// @nodoc
mixin _$GymInvite {

 String get id; String get gymId; String get invitedUser; MemberData get invitedUserData; String get invitedBy; Map<String, dynamic> get invitedByData; String get status; String get createdAt;
/// Create a copy of GymInvite
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GymInviteCopyWith<GymInvite> get copyWith => _$GymInviteCopyWithImpl<GymInvite>(this as GymInvite, _$identity);

  /// Serializes this GymInvite to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GymInvite&&(identical(other.id, id) || other.id == id)&&(identical(other.gymId, gymId) || other.gymId == gymId)&&(identical(other.invitedUser, invitedUser) || other.invitedUser == invitedUser)&&(identical(other.invitedUserData, invitedUserData) || other.invitedUserData == invitedUserData)&&(identical(other.invitedBy, invitedBy) || other.invitedBy == invitedBy)&&const DeepCollectionEquality().equals(other.invitedByData, invitedByData)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,gymId,invitedUser,invitedUserData,invitedBy,const DeepCollectionEquality().hash(invitedByData),status,createdAt);

@override
String toString() {
  return 'GymInvite(id: $id, gymId: $gymId, invitedUser: $invitedUser, invitedUserData: $invitedUserData, invitedBy: $invitedBy, invitedByData: $invitedByData, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $GymInviteCopyWith<$Res>  {
  factory $GymInviteCopyWith(GymInvite value, $Res Function(GymInvite) _then) = _$GymInviteCopyWithImpl;
@useResult
$Res call({
 String id, String gymId, String invitedUser, MemberData invitedUserData, String invitedBy, Map<String, dynamic> invitedByData, String status, String createdAt
});


$MemberDataCopyWith<$Res> get invitedUserData;

}
/// @nodoc
class _$GymInviteCopyWithImpl<$Res>
    implements $GymInviteCopyWith<$Res> {
  _$GymInviteCopyWithImpl(this._self, this._then);

  final GymInvite _self;
  final $Res Function(GymInvite) _then;

/// Create a copy of GymInvite
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? gymId = null,Object? invitedUser = null,Object? invitedUserData = null,Object? invitedBy = null,Object? invitedByData = null,Object? status = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,gymId: null == gymId ? _self.gymId : gymId // ignore: cast_nullable_to_non_nullable
as String,invitedUser: null == invitedUser ? _self.invitedUser : invitedUser // ignore: cast_nullable_to_non_nullable
as String,invitedUserData: null == invitedUserData ? _self.invitedUserData : invitedUserData // ignore: cast_nullable_to_non_nullable
as MemberData,invitedBy: null == invitedBy ? _self.invitedBy : invitedBy // ignore: cast_nullable_to_non_nullable
as String,invitedByData: null == invitedByData ? _self.invitedByData : invitedByData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of GymInvite
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MemberDataCopyWith<$Res> get invitedUserData {
  
  return $MemberDataCopyWith<$Res>(_self.invitedUserData, (value) {
    return _then(_self.copyWith(invitedUserData: value));
  });
}
}


/// Adds pattern-matching-related methods to [GymInvite].
extension GymInvitePatterns on GymInvite {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GymInvite value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GymInvite() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GymInvite value)  $default,){
final _that = this;
switch (_that) {
case _GymInvite():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GymInvite value)?  $default,){
final _that = this;
switch (_that) {
case _GymInvite() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String gymId,  String invitedUser,  MemberData invitedUserData,  String invitedBy,  Map<String, dynamic> invitedByData,  String status,  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GymInvite() when $default != null:
return $default(_that.id,_that.gymId,_that.invitedUser,_that.invitedUserData,_that.invitedBy,_that.invitedByData,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String gymId,  String invitedUser,  MemberData invitedUserData,  String invitedBy,  Map<String, dynamic> invitedByData,  String status,  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _GymInvite():
return $default(_that.id,_that.gymId,_that.invitedUser,_that.invitedUserData,_that.invitedBy,_that.invitedByData,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String gymId,  String invitedUser,  MemberData invitedUserData,  String invitedBy,  Map<String, dynamic> invitedByData,  String status,  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _GymInvite() when $default != null:
return $default(_that.id,_that.gymId,_that.invitedUser,_that.invitedUserData,_that.invitedBy,_that.invitedByData,_that.status,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GymInvite implements GymInvite {
  const _GymInvite({required this.id, required this.gymId, required this.invitedUser, required this.invitedUserData, required this.invitedBy, required final  Map<String, dynamic> invitedByData, this.status = 'pending', required this.createdAt}): _invitedByData = invitedByData;
  factory _GymInvite.fromJson(Map<String, dynamic> json) => _$GymInviteFromJson(json);

@override final  String id;
@override final  String gymId;
@override final  String invitedUser;
@override final  MemberData invitedUserData;
@override final  String invitedBy;
 final  Map<String, dynamic> _invitedByData;
@override Map<String, dynamic> get invitedByData {
  if (_invitedByData is EqualUnmodifiableMapView) return _invitedByData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_invitedByData);
}

@override@JsonKey() final  String status;
@override final  String createdAt;

/// Create a copy of GymInvite
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GymInviteCopyWith<_GymInvite> get copyWith => __$GymInviteCopyWithImpl<_GymInvite>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GymInviteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GymInvite&&(identical(other.id, id) || other.id == id)&&(identical(other.gymId, gymId) || other.gymId == gymId)&&(identical(other.invitedUser, invitedUser) || other.invitedUser == invitedUser)&&(identical(other.invitedUserData, invitedUserData) || other.invitedUserData == invitedUserData)&&(identical(other.invitedBy, invitedBy) || other.invitedBy == invitedBy)&&const DeepCollectionEquality().equals(other._invitedByData, _invitedByData)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,gymId,invitedUser,invitedUserData,invitedBy,const DeepCollectionEquality().hash(_invitedByData),status,createdAt);

@override
String toString() {
  return 'GymInvite(id: $id, gymId: $gymId, invitedUser: $invitedUser, invitedUserData: $invitedUserData, invitedBy: $invitedBy, invitedByData: $invitedByData, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$GymInviteCopyWith<$Res> implements $GymInviteCopyWith<$Res> {
  factory _$GymInviteCopyWith(_GymInvite value, $Res Function(_GymInvite) _then) = __$GymInviteCopyWithImpl;
@override @useResult
$Res call({
 String id, String gymId, String invitedUser, MemberData invitedUserData, String invitedBy, Map<String, dynamic> invitedByData, String status, String createdAt
});


@override $MemberDataCopyWith<$Res> get invitedUserData;

}
/// @nodoc
class __$GymInviteCopyWithImpl<$Res>
    implements _$GymInviteCopyWith<$Res> {
  __$GymInviteCopyWithImpl(this._self, this._then);

  final _GymInvite _self;
  final $Res Function(_GymInvite) _then;

/// Create a copy of GymInvite
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? gymId = null,Object? invitedUser = null,Object? invitedUserData = null,Object? invitedBy = null,Object? invitedByData = null,Object? status = null,Object? createdAt = null,}) {
  return _then(_GymInvite(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,gymId: null == gymId ? _self.gymId : gymId // ignore: cast_nullable_to_non_nullable
as String,invitedUser: null == invitedUser ? _self.invitedUser : invitedUser // ignore: cast_nullable_to_non_nullable
as String,invitedUserData: null == invitedUserData ? _self.invitedUserData : invitedUserData // ignore: cast_nullable_to_non_nullable
as MemberData,invitedBy: null == invitedBy ? _self.invitedBy : invitedBy // ignore: cast_nullable_to_non_nullable
as String,invitedByData: null == invitedByData ? _self._invitedByData : invitedByData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of GymInvite
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MemberDataCopyWith<$Res> get invitedUserData {
  
  return $MemberDataCopyWith<$Res>(_self.invitedUserData, (value) {
    return _then(_self.copyWith(invitedUserData: value));
  });
}
}


/// @nodoc
mixin _$CityResult {

 String get placeId; String get city; String get country; String get description;
/// Create a copy of CityResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CityResultCopyWith<CityResult> get copyWith => _$CityResultCopyWithImpl<CityResult>(this as CityResult, _$identity);

  /// Serializes this CityResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CityResult&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,placeId,city,country,description);

@override
String toString() {
  return 'CityResult(placeId: $placeId, city: $city, country: $country, description: $description)';
}


}

/// @nodoc
abstract mixin class $CityResultCopyWith<$Res>  {
  factory $CityResultCopyWith(CityResult value, $Res Function(CityResult) _then) = _$CityResultCopyWithImpl;
@useResult
$Res call({
 String placeId, String city, String country, String description
});




}
/// @nodoc
class _$CityResultCopyWithImpl<$Res>
    implements $CityResultCopyWith<$Res> {
  _$CityResultCopyWithImpl(this._self, this._then);

  final CityResult _self;
  final $Res Function(CityResult) _then;

/// Create a copy of CityResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? placeId = null,Object? city = null,Object? country = null,Object? description = null,}) {
  return _then(_self.copyWith(
placeId: null == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CityResult].
extension CityResultPatterns on CityResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CityResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CityResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CityResult value)  $default,){
final _that = this;
switch (_that) {
case _CityResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CityResult value)?  $default,){
final _that = this;
switch (_that) {
case _CityResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String placeId,  String city,  String country,  String description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CityResult() when $default != null:
return $default(_that.placeId,_that.city,_that.country,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String placeId,  String city,  String country,  String description)  $default,) {final _that = this;
switch (_that) {
case _CityResult():
return $default(_that.placeId,_that.city,_that.country,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String placeId,  String city,  String country,  String description)?  $default,) {final _that = this;
switch (_that) {
case _CityResult() when $default != null:
return $default(_that.placeId,_that.city,_that.country,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CityResult implements CityResult {
  const _CityResult({required this.placeId, required this.city, required this.country, required this.description});
  factory _CityResult.fromJson(Map<String, dynamic> json) => _$CityResultFromJson(json);

@override final  String placeId;
@override final  String city;
@override final  String country;
@override final  String description;

/// Create a copy of CityResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CityResultCopyWith<_CityResult> get copyWith => __$CityResultCopyWithImpl<_CityResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CityResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CityResult&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,placeId,city,country,description);

@override
String toString() {
  return 'CityResult(placeId: $placeId, city: $city, country: $country, description: $description)';
}


}

/// @nodoc
abstract mixin class _$CityResultCopyWith<$Res> implements $CityResultCopyWith<$Res> {
  factory _$CityResultCopyWith(_CityResult value, $Res Function(_CityResult) _then) = __$CityResultCopyWithImpl;
@override @useResult
$Res call({
 String placeId, String city, String country, String description
});




}
/// @nodoc
class __$CityResultCopyWithImpl<$Res>
    implements _$CityResultCopyWith<$Res> {
  __$CityResultCopyWithImpl(this._self, this._then);

  final _CityResult _self;
  final $Res Function(_CityResult) _then;

/// Create a copy of CityResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? placeId = null,Object? city = null,Object? country = null,Object? description = null,}) {
  return _then(_CityResult(
placeId: null == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$GymSchedulePost {

 String get id; String get gymId; String get author; MemberData get authorData; String get title; String get content; String get activityType; String get customActivityType; String get locationMode; String? get startTime; String? get endTime; String? get recurrence; String? get recurrenceEndDate; String? get recurrenceDays; int get maxSlots; int get enrollmentCount; bool get isEnrolled; String get createdAt;
/// Create a copy of GymSchedulePost
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GymSchedulePostCopyWith<GymSchedulePost> get copyWith => _$GymSchedulePostCopyWithImpl<GymSchedulePost>(this as GymSchedulePost, _$identity);

  /// Serializes this GymSchedulePost to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GymSchedulePost&&(identical(other.id, id) || other.id == id)&&(identical(other.gymId, gymId) || other.gymId == gymId)&&(identical(other.author, author) || other.author == author)&&(identical(other.authorData, authorData) || other.authorData == authorData)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.activityType, activityType) || other.activityType == activityType)&&(identical(other.customActivityType, customActivityType) || other.customActivityType == customActivityType)&&(identical(other.locationMode, locationMode) || other.locationMode == locationMode)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.recurrence, recurrence) || other.recurrence == recurrence)&&(identical(other.recurrenceEndDate, recurrenceEndDate) || other.recurrenceEndDate == recurrenceEndDate)&&(identical(other.recurrenceDays, recurrenceDays) || other.recurrenceDays == recurrenceDays)&&(identical(other.maxSlots, maxSlots) || other.maxSlots == maxSlots)&&(identical(other.enrollmentCount, enrollmentCount) || other.enrollmentCount == enrollmentCount)&&(identical(other.isEnrolled, isEnrolled) || other.isEnrolled == isEnrolled)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,gymId,author,authorData,title,content,activityType,customActivityType,locationMode,startTime,endTime,recurrence,recurrenceEndDate,recurrenceDays,maxSlots,enrollmentCount,isEnrolled,createdAt);

@override
String toString() {
  return 'GymSchedulePost(id: $id, gymId: $gymId, author: $author, authorData: $authorData, title: $title, content: $content, activityType: $activityType, customActivityType: $customActivityType, locationMode: $locationMode, startTime: $startTime, endTime: $endTime, recurrence: $recurrence, recurrenceEndDate: $recurrenceEndDate, recurrenceDays: $recurrenceDays, maxSlots: $maxSlots, enrollmentCount: $enrollmentCount, isEnrolled: $isEnrolled, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $GymSchedulePostCopyWith<$Res>  {
  factory $GymSchedulePostCopyWith(GymSchedulePost value, $Res Function(GymSchedulePost) _then) = _$GymSchedulePostCopyWithImpl;
@useResult
$Res call({
 String id, String gymId, String author, MemberData authorData, String title, String content, String activityType, String customActivityType, String locationMode, String? startTime, String? endTime, String? recurrence, String? recurrenceEndDate, String? recurrenceDays, int maxSlots, int enrollmentCount, bool isEnrolled, String createdAt
});


$MemberDataCopyWith<$Res> get authorData;

}
/// @nodoc
class _$GymSchedulePostCopyWithImpl<$Res>
    implements $GymSchedulePostCopyWith<$Res> {
  _$GymSchedulePostCopyWithImpl(this._self, this._then);

  final GymSchedulePost _self;
  final $Res Function(GymSchedulePost) _then;

/// Create a copy of GymSchedulePost
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? gymId = null,Object? author = null,Object? authorData = null,Object? title = null,Object? content = null,Object? activityType = null,Object? customActivityType = null,Object? locationMode = null,Object? startTime = freezed,Object? endTime = freezed,Object? recurrence = freezed,Object? recurrenceEndDate = freezed,Object? recurrenceDays = freezed,Object? maxSlots = null,Object? enrollmentCount = null,Object? isEnrolled = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,gymId: null == gymId ? _self.gymId : gymId // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,authorData: null == authorData ? _self.authorData : authorData // ignore: cast_nullable_to_non_nullable
as MemberData,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,activityType: null == activityType ? _self.activityType : activityType // ignore: cast_nullable_to_non_nullable
as String,customActivityType: null == customActivityType ? _self.customActivityType : customActivityType // ignore: cast_nullable_to_non_nullable
as String,locationMode: null == locationMode ? _self.locationMode : locationMode // ignore: cast_nullable_to_non_nullable
as String,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String?,recurrence: freezed == recurrence ? _self.recurrence : recurrence // ignore: cast_nullable_to_non_nullable
as String?,recurrenceEndDate: freezed == recurrenceEndDate ? _self.recurrenceEndDate : recurrenceEndDate // ignore: cast_nullable_to_non_nullable
as String?,recurrenceDays: freezed == recurrenceDays ? _self.recurrenceDays : recurrenceDays // ignore: cast_nullable_to_non_nullable
as String?,maxSlots: null == maxSlots ? _self.maxSlots : maxSlots // ignore: cast_nullable_to_non_nullable
as int,enrollmentCount: null == enrollmentCount ? _self.enrollmentCount : enrollmentCount // ignore: cast_nullable_to_non_nullable
as int,isEnrolled: null == isEnrolled ? _self.isEnrolled : isEnrolled // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of GymSchedulePost
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MemberDataCopyWith<$Res> get authorData {
  
  return $MemberDataCopyWith<$Res>(_self.authorData, (value) {
    return _then(_self.copyWith(authorData: value));
  });
}
}


/// Adds pattern-matching-related methods to [GymSchedulePost].
extension GymSchedulePostPatterns on GymSchedulePost {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GymSchedulePost value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GymSchedulePost() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GymSchedulePost value)  $default,){
final _that = this;
switch (_that) {
case _GymSchedulePost():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GymSchedulePost value)?  $default,){
final _that = this;
switch (_that) {
case _GymSchedulePost() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String gymId,  String author,  MemberData authorData,  String title,  String content,  String activityType,  String customActivityType,  String locationMode,  String? startTime,  String? endTime,  String? recurrence,  String? recurrenceEndDate,  String? recurrenceDays,  int maxSlots,  int enrollmentCount,  bool isEnrolled,  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GymSchedulePost() when $default != null:
return $default(_that.id,_that.gymId,_that.author,_that.authorData,_that.title,_that.content,_that.activityType,_that.customActivityType,_that.locationMode,_that.startTime,_that.endTime,_that.recurrence,_that.recurrenceEndDate,_that.recurrenceDays,_that.maxSlots,_that.enrollmentCount,_that.isEnrolled,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String gymId,  String author,  MemberData authorData,  String title,  String content,  String activityType,  String customActivityType,  String locationMode,  String? startTime,  String? endTime,  String? recurrence,  String? recurrenceEndDate,  String? recurrenceDays,  int maxSlots,  int enrollmentCount,  bool isEnrolled,  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _GymSchedulePost():
return $default(_that.id,_that.gymId,_that.author,_that.authorData,_that.title,_that.content,_that.activityType,_that.customActivityType,_that.locationMode,_that.startTime,_that.endTime,_that.recurrence,_that.recurrenceEndDate,_that.recurrenceDays,_that.maxSlots,_that.enrollmentCount,_that.isEnrolled,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String gymId,  String author,  MemberData authorData,  String title,  String content,  String activityType,  String customActivityType,  String locationMode,  String? startTime,  String? endTime,  String? recurrence,  String? recurrenceEndDate,  String? recurrenceDays,  int maxSlots,  int enrollmentCount,  bool isEnrolled,  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _GymSchedulePost() when $default != null:
return $default(_that.id,_that.gymId,_that.author,_that.authorData,_that.title,_that.content,_that.activityType,_that.customActivityType,_that.locationMode,_that.startTime,_that.endTime,_that.recurrence,_that.recurrenceEndDate,_that.recurrenceDays,_that.maxSlots,_that.enrollmentCount,_that.isEnrolled,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GymSchedulePost implements GymSchedulePost {
  const _GymSchedulePost({required this.id, required this.gymId, required this.author, required this.authorData, this.title = '', this.content = '', this.activityType = '', this.customActivityType = '', this.locationMode = '', this.startTime, this.endTime, this.recurrence, this.recurrenceEndDate, this.recurrenceDays, this.maxSlots = 0, this.enrollmentCount = 0, this.isEnrolled = false, required this.createdAt});
  factory _GymSchedulePost.fromJson(Map<String, dynamic> json) => _$GymSchedulePostFromJson(json);

@override final  String id;
@override final  String gymId;
@override final  String author;
@override final  MemberData authorData;
@override@JsonKey() final  String title;
@override@JsonKey() final  String content;
@override@JsonKey() final  String activityType;
@override@JsonKey() final  String customActivityType;
@override@JsonKey() final  String locationMode;
@override final  String? startTime;
@override final  String? endTime;
@override final  String? recurrence;
@override final  String? recurrenceEndDate;
@override final  String? recurrenceDays;
@override@JsonKey() final  int maxSlots;
@override@JsonKey() final  int enrollmentCount;
@override@JsonKey() final  bool isEnrolled;
@override final  String createdAt;

/// Create a copy of GymSchedulePost
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GymSchedulePostCopyWith<_GymSchedulePost> get copyWith => __$GymSchedulePostCopyWithImpl<_GymSchedulePost>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GymSchedulePostToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GymSchedulePost&&(identical(other.id, id) || other.id == id)&&(identical(other.gymId, gymId) || other.gymId == gymId)&&(identical(other.author, author) || other.author == author)&&(identical(other.authorData, authorData) || other.authorData == authorData)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.activityType, activityType) || other.activityType == activityType)&&(identical(other.customActivityType, customActivityType) || other.customActivityType == customActivityType)&&(identical(other.locationMode, locationMode) || other.locationMode == locationMode)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.recurrence, recurrence) || other.recurrence == recurrence)&&(identical(other.recurrenceEndDate, recurrenceEndDate) || other.recurrenceEndDate == recurrenceEndDate)&&(identical(other.recurrenceDays, recurrenceDays) || other.recurrenceDays == recurrenceDays)&&(identical(other.maxSlots, maxSlots) || other.maxSlots == maxSlots)&&(identical(other.enrollmentCount, enrollmentCount) || other.enrollmentCount == enrollmentCount)&&(identical(other.isEnrolled, isEnrolled) || other.isEnrolled == isEnrolled)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,gymId,author,authorData,title,content,activityType,customActivityType,locationMode,startTime,endTime,recurrence,recurrenceEndDate,recurrenceDays,maxSlots,enrollmentCount,isEnrolled,createdAt);

@override
String toString() {
  return 'GymSchedulePost(id: $id, gymId: $gymId, author: $author, authorData: $authorData, title: $title, content: $content, activityType: $activityType, customActivityType: $customActivityType, locationMode: $locationMode, startTime: $startTime, endTime: $endTime, recurrence: $recurrence, recurrenceEndDate: $recurrenceEndDate, recurrenceDays: $recurrenceDays, maxSlots: $maxSlots, enrollmentCount: $enrollmentCount, isEnrolled: $isEnrolled, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$GymSchedulePostCopyWith<$Res> implements $GymSchedulePostCopyWith<$Res> {
  factory _$GymSchedulePostCopyWith(_GymSchedulePost value, $Res Function(_GymSchedulePost) _then) = __$GymSchedulePostCopyWithImpl;
@override @useResult
$Res call({
 String id, String gymId, String author, MemberData authorData, String title, String content, String activityType, String customActivityType, String locationMode, String? startTime, String? endTime, String? recurrence, String? recurrenceEndDate, String? recurrenceDays, int maxSlots, int enrollmentCount, bool isEnrolled, String createdAt
});


@override $MemberDataCopyWith<$Res> get authorData;

}
/// @nodoc
class __$GymSchedulePostCopyWithImpl<$Res>
    implements _$GymSchedulePostCopyWith<$Res> {
  __$GymSchedulePostCopyWithImpl(this._self, this._then);

  final _GymSchedulePost _self;
  final $Res Function(_GymSchedulePost) _then;

/// Create a copy of GymSchedulePost
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? gymId = null,Object? author = null,Object? authorData = null,Object? title = null,Object? content = null,Object? activityType = null,Object? customActivityType = null,Object? locationMode = null,Object? startTime = freezed,Object? endTime = freezed,Object? recurrence = freezed,Object? recurrenceEndDate = freezed,Object? recurrenceDays = freezed,Object? maxSlots = null,Object? enrollmentCount = null,Object? isEnrolled = null,Object? createdAt = null,}) {
  return _then(_GymSchedulePost(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,gymId: null == gymId ? _self.gymId : gymId // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,authorData: null == authorData ? _self.authorData : authorData // ignore: cast_nullable_to_non_nullable
as MemberData,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,activityType: null == activityType ? _self.activityType : activityType // ignore: cast_nullable_to_non_nullable
as String,customActivityType: null == customActivityType ? _self.customActivityType : customActivityType // ignore: cast_nullable_to_non_nullable
as String,locationMode: null == locationMode ? _self.locationMode : locationMode // ignore: cast_nullable_to_non_nullable
as String,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String?,recurrence: freezed == recurrence ? _self.recurrence : recurrence // ignore: cast_nullable_to_non_nullable
as String?,recurrenceEndDate: freezed == recurrenceEndDate ? _self.recurrenceEndDate : recurrenceEndDate // ignore: cast_nullable_to_non_nullable
as String?,recurrenceDays: freezed == recurrenceDays ? _self.recurrenceDays : recurrenceDays // ignore: cast_nullable_to_non_nullable
as String?,maxSlots: null == maxSlots ? _self.maxSlots : maxSlots // ignore: cast_nullable_to_non_nullable
as int,enrollmentCount: null == enrollmentCount ? _self.enrollmentCount : enrollmentCount // ignore: cast_nullable_to_non_nullable
as int,isEnrolled: null == isEnrolled ? _self.isEnrolled : isEnrolled // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of GymSchedulePost
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MemberDataCopyWith<$Res> get authorData {
  
  return $MemberDataCopyWith<$Res>(_self.authorData, (value) {
    return _then(_self.copyWith(authorData: value));
  });
}
}


/// @nodoc
mixin _$GymReview {

 String get id; String get gymId; String get reviewer; MemberData get reviewerData; int get rating; String get comment; String get replyText; String? get repliedBy; MemberData? get repliedByData; String? get repliedAt; String get createdAt;
/// Create a copy of GymReview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GymReviewCopyWith<GymReview> get copyWith => _$GymReviewCopyWithImpl<GymReview>(this as GymReview, _$identity);

  /// Serializes this GymReview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GymReview&&(identical(other.id, id) || other.id == id)&&(identical(other.gymId, gymId) || other.gymId == gymId)&&(identical(other.reviewer, reviewer) || other.reviewer == reviewer)&&(identical(other.reviewerData, reviewerData) || other.reviewerData == reviewerData)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.replyText, replyText) || other.replyText == replyText)&&(identical(other.repliedBy, repliedBy) || other.repliedBy == repliedBy)&&(identical(other.repliedByData, repliedByData) || other.repliedByData == repliedByData)&&(identical(other.repliedAt, repliedAt) || other.repliedAt == repliedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,gymId,reviewer,reviewerData,rating,comment,replyText,repliedBy,repliedByData,repliedAt,createdAt);

@override
String toString() {
  return 'GymReview(id: $id, gymId: $gymId, reviewer: $reviewer, reviewerData: $reviewerData, rating: $rating, comment: $comment, replyText: $replyText, repliedBy: $repliedBy, repliedByData: $repliedByData, repliedAt: $repliedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $GymReviewCopyWith<$Res>  {
  factory $GymReviewCopyWith(GymReview value, $Res Function(GymReview) _then) = _$GymReviewCopyWithImpl;
@useResult
$Res call({
 String id, String gymId, String reviewer, MemberData reviewerData, int rating, String comment, String replyText, String? repliedBy, MemberData? repliedByData, String? repliedAt, String createdAt
});


$MemberDataCopyWith<$Res> get reviewerData;$MemberDataCopyWith<$Res>? get repliedByData;

}
/// @nodoc
class _$GymReviewCopyWithImpl<$Res>
    implements $GymReviewCopyWith<$Res> {
  _$GymReviewCopyWithImpl(this._self, this._then);

  final GymReview _self;
  final $Res Function(GymReview) _then;

/// Create a copy of GymReview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? gymId = null,Object? reviewer = null,Object? reviewerData = null,Object? rating = null,Object? comment = null,Object? replyText = null,Object? repliedBy = freezed,Object? repliedByData = freezed,Object? repliedAt = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,gymId: null == gymId ? _self.gymId : gymId // ignore: cast_nullable_to_non_nullable
as String,reviewer: null == reviewer ? _self.reviewer : reviewer // ignore: cast_nullable_to_non_nullable
as String,reviewerData: null == reviewerData ? _self.reviewerData : reviewerData // ignore: cast_nullable_to_non_nullable
as MemberData,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,replyText: null == replyText ? _self.replyText : replyText // ignore: cast_nullable_to_non_nullable
as String,repliedBy: freezed == repliedBy ? _self.repliedBy : repliedBy // ignore: cast_nullable_to_non_nullable
as String?,repliedByData: freezed == repliedByData ? _self.repliedByData : repliedByData // ignore: cast_nullable_to_non_nullable
as MemberData?,repliedAt: freezed == repliedAt ? _self.repliedAt : repliedAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of GymReview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MemberDataCopyWith<$Res> get reviewerData {
  
  return $MemberDataCopyWith<$Res>(_self.reviewerData, (value) {
    return _then(_self.copyWith(reviewerData: value));
  });
}/// Create a copy of GymReview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MemberDataCopyWith<$Res>? get repliedByData {
    if (_self.repliedByData == null) {
    return null;
  }

  return $MemberDataCopyWith<$Res>(_self.repliedByData!, (value) {
    return _then(_self.copyWith(repliedByData: value));
  });
}
}


/// Adds pattern-matching-related methods to [GymReview].
extension GymReviewPatterns on GymReview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GymReview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GymReview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GymReview value)  $default,){
final _that = this;
switch (_that) {
case _GymReview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GymReview value)?  $default,){
final _that = this;
switch (_that) {
case _GymReview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String gymId,  String reviewer,  MemberData reviewerData,  int rating,  String comment,  String replyText,  String? repliedBy,  MemberData? repliedByData,  String? repliedAt,  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GymReview() when $default != null:
return $default(_that.id,_that.gymId,_that.reviewer,_that.reviewerData,_that.rating,_that.comment,_that.replyText,_that.repliedBy,_that.repliedByData,_that.repliedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String gymId,  String reviewer,  MemberData reviewerData,  int rating,  String comment,  String replyText,  String? repliedBy,  MemberData? repliedByData,  String? repliedAt,  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _GymReview():
return $default(_that.id,_that.gymId,_that.reviewer,_that.reviewerData,_that.rating,_that.comment,_that.replyText,_that.repliedBy,_that.repliedByData,_that.repliedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String gymId,  String reviewer,  MemberData reviewerData,  int rating,  String comment,  String replyText,  String? repliedBy,  MemberData? repliedByData,  String? repliedAt,  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _GymReview() when $default != null:
return $default(_that.id,_that.gymId,_that.reviewer,_that.reviewerData,_that.rating,_that.comment,_that.replyText,_that.repliedBy,_that.repliedByData,_that.repliedAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GymReview implements GymReview {
  const _GymReview({required this.id, required this.gymId, required this.reviewer, required this.reviewerData, required this.rating, this.comment = '', this.replyText = '', this.repliedBy, this.repliedByData, this.repliedAt, required this.createdAt});
  factory _GymReview.fromJson(Map<String, dynamic> json) => _$GymReviewFromJson(json);

@override final  String id;
@override final  String gymId;
@override final  String reviewer;
@override final  MemberData reviewerData;
@override final  int rating;
@override@JsonKey() final  String comment;
@override@JsonKey() final  String replyText;
@override final  String? repliedBy;
@override final  MemberData? repliedByData;
@override final  String? repliedAt;
@override final  String createdAt;

/// Create a copy of GymReview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GymReviewCopyWith<_GymReview> get copyWith => __$GymReviewCopyWithImpl<_GymReview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GymReviewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GymReview&&(identical(other.id, id) || other.id == id)&&(identical(other.gymId, gymId) || other.gymId == gymId)&&(identical(other.reviewer, reviewer) || other.reviewer == reviewer)&&(identical(other.reviewerData, reviewerData) || other.reviewerData == reviewerData)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.replyText, replyText) || other.replyText == replyText)&&(identical(other.repliedBy, repliedBy) || other.repliedBy == repliedBy)&&(identical(other.repliedByData, repliedByData) || other.repliedByData == repliedByData)&&(identical(other.repliedAt, repliedAt) || other.repliedAt == repliedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,gymId,reviewer,reviewerData,rating,comment,replyText,repliedBy,repliedByData,repliedAt,createdAt);

@override
String toString() {
  return 'GymReview(id: $id, gymId: $gymId, reviewer: $reviewer, reviewerData: $reviewerData, rating: $rating, comment: $comment, replyText: $replyText, repliedBy: $repliedBy, repliedByData: $repliedByData, repliedAt: $repliedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$GymReviewCopyWith<$Res> implements $GymReviewCopyWith<$Res> {
  factory _$GymReviewCopyWith(_GymReview value, $Res Function(_GymReview) _then) = __$GymReviewCopyWithImpl;
@override @useResult
$Res call({
 String id, String gymId, String reviewer, MemberData reviewerData, int rating, String comment, String replyText, String? repliedBy, MemberData? repliedByData, String? repliedAt, String createdAt
});


@override $MemberDataCopyWith<$Res> get reviewerData;@override $MemberDataCopyWith<$Res>? get repliedByData;

}
/// @nodoc
class __$GymReviewCopyWithImpl<$Res>
    implements _$GymReviewCopyWith<$Res> {
  __$GymReviewCopyWithImpl(this._self, this._then);

  final _GymReview _self;
  final $Res Function(_GymReview) _then;

/// Create a copy of GymReview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? gymId = null,Object? reviewer = null,Object? reviewerData = null,Object? rating = null,Object? comment = null,Object? replyText = null,Object? repliedBy = freezed,Object? repliedByData = freezed,Object? repliedAt = freezed,Object? createdAt = null,}) {
  return _then(_GymReview(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,gymId: null == gymId ? _self.gymId : gymId // ignore: cast_nullable_to_non_nullable
as String,reviewer: null == reviewer ? _self.reviewer : reviewer // ignore: cast_nullable_to_non_nullable
as String,reviewerData: null == reviewerData ? _self.reviewerData : reviewerData // ignore: cast_nullable_to_non_nullable
as MemberData,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,replyText: null == replyText ? _self.replyText : replyText // ignore: cast_nullable_to_non_nullable
as String,repliedBy: freezed == repliedBy ? _self.repliedBy : repliedBy // ignore: cast_nullable_to_non_nullable
as String?,repliedByData: freezed == repliedByData ? _self.repliedByData : repliedByData // ignore: cast_nullable_to_non_nullable
as MemberData?,repliedAt: freezed == repliedAt ? _self.repliedAt : repliedAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of GymReview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MemberDataCopyWith<$Res> get reviewerData {
  
  return $MemberDataCopyWith<$Res>(_self.reviewerData, (value) {
    return _then(_self.copyWith(reviewerData: value));
  });
}/// Create a copy of GymReview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MemberDataCopyWith<$Res>? get repliedByData {
    if (_self.repliedByData == null) {
    return null;
  }

  return $MemberDataCopyWith<$Res>(_self.repliedByData!, (value) {
    return _then(_self.copyWith(repliedByData: value));
  });
}
}


/// @nodoc
mixin _$GymDonation {

 String get id; String get gymId; String get donor; MemberData get donorData; String get amount; String get message; String get createdAt;
/// Create a copy of GymDonation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GymDonationCopyWith<GymDonation> get copyWith => _$GymDonationCopyWithImpl<GymDonation>(this as GymDonation, _$identity);

  /// Serializes this GymDonation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GymDonation&&(identical(other.id, id) || other.id == id)&&(identical(other.gymId, gymId) || other.gymId == gymId)&&(identical(other.donor, donor) || other.donor == donor)&&(identical(other.donorData, donorData) || other.donorData == donorData)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.message, message) || other.message == message)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,gymId,donor,donorData,amount,message,createdAt);

@override
String toString() {
  return 'GymDonation(id: $id, gymId: $gymId, donor: $donor, donorData: $donorData, amount: $amount, message: $message, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $GymDonationCopyWith<$Res>  {
  factory $GymDonationCopyWith(GymDonation value, $Res Function(GymDonation) _then) = _$GymDonationCopyWithImpl;
@useResult
$Res call({
 String id, String gymId, String donor, MemberData donorData, String amount, String message, String createdAt
});


$MemberDataCopyWith<$Res> get donorData;

}
/// @nodoc
class _$GymDonationCopyWithImpl<$Res>
    implements $GymDonationCopyWith<$Res> {
  _$GymDonationCopyWithImpl(this._self, this._then);

  final GymDonation _self;
  final $Res Function(GymDonation) _then;

/// Create a copy of GymDonation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? gymId = null,Object? donor = null,Object? donorData = null,Object? amount = null,Object? message = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,gymId: null == gymId ? _self.gymId : gymId // ignore: cast_nullable_to_non_nullable
as String,donor: null == donor ? _self.donor : donor // ignore: cast_nullable_to_non_nullable
as String,donorData: null == donorData ? _self.donorData : donorData // ignore: cast_nullable_to_non_nullable
as MemberData,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of GymDonation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MemberDataCopyWith<$Res> get donorData {
  
  return $MemberDataCopyWith<$Res>(_self.donorData, (value) {
    return _then(_self.copyWith(donorData: value));
  });
}
}


/// Adds pattern-matching-related methods to [GymDonation].
extension GymDonationPatterns on GymDonation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GymDonation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GymDonation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GymDonation value)  $default,){
final _that = this;
switch (_that) {
case _GymDonation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GymDonation value)?  $default,){
final _that = this;
switch (_that) {
case _GymDonation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String gymId,  String donor,  MemberData donorData,  String amount,  String message,  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GymDonation() when $default != null:
return $default(_that.id,_that.gymId,_that.donor,_that.donorData,_that.amount,_that.message,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String gymId,  String donor,  MemberData donorData,  String amount,  String message,  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _GymDonation():
return $default(_that.id,_that.gymId,_that.donor,_that.donorData,_that.amount,_that.message,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String gymId,  String donor,  MemberData donorData,  String amount,  String message,  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _GymDonation() when $default != null:
return $default(_that.id,_that.gymId,_that.donor,_that.donorData,_that.amount,_that.message,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GymDonation implements GymDonation {
  const _GymDonation({required this.id, required this.gymId, required this.donor, required this.donorData, required this.amount, this.message = '', required this.createdAt});
  factory _GymDonation.fromJson(Map<String, dynamic> json) => _$GymDonationFromJson(json);

@override final  String id;
@override final  String gymId;
@override final  String donor;
@override final  MemberData donorData;
@override final  String amount;
@override@JsonKey() final  String message;
@override final  String createdAt;

/// Create a copy of GymDonation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GymDonationCopyWith<_GymDonation> get copyWith => __$GymDonationCopyWithImpl<_GymDonation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GymDonationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GymDonation&&(identical(other.id, id) || other.id == id)&&(identical(other.gymId, gymId) || other.gymId == gymId)&&(identical(other.donor, donor) || other.donor == donor)&&(identical(other.donorData, donorData) || other.donorData == donorData)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.message, message) || other.message == message)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,gymId,donor,donorData,amount,message,createdAt);

@override
String toString() {
  return 'GymDonation(id: $id, gymId: $gymId, donor: $donor, donorData: $donorData, amount: $amount, message: $message, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$GymDonationCopyWith<$Res> implements $GymDonationCopyWith<$Res> {
  factory _$GymDonationCopyWith(_GymDonation value, $Res Function(_GymDonation) _then) = __$GymDonationCopyWithImpl;
@override @useResult
$Res call({
 String id, String gymId, String donor, MemberData donorData, String amount, String message, String createdAt
});


@override $MemberDataCopyWith<$Res> get donorData;

}
/// @nodoc
class __$GymDonationCopyWithImpl<$Res>
    implements _$GymDonationCopyWith<$Res> {
  __$GymDonationCopyWithImpl(this._self, this._then);

  final _GymDonation _self;
  final $Res Function(_GymDonation) _then;

/// Create a copy of GymDonation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? gymId = null,Object? donor = null,Object? donorData = null,Object? amount = null,Object? message = null,Object? createdAt = null,}) {
  return _then(_GymDonation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,gymId: null == gymId ? _self.gymId : gymId // ignore: cast_nullable_to_non_nullable
as String,donor: null == donor ? _self.donor : donor // ignore: cast_nullable_to_non_nullable
as String,donorData: null == donorData ? _self.donorData : donorData // ignore: cast_nullable_to_non_nullable
as MemberData,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of GymDonation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MemberDataCopyWith<$Res> get donorData {
  
  return $MemberDataCopyWith<$Res>(_self.donorData, (value) {
    return _then(_self.copyWith(donorData: value));
  });
}
}


/// @nodoc
mixin _$GymEvent {

 String get id; String get gymId; String get title; String get description; String? get startTime; String? get endTime; String get location; String get createdAt;
/// Create a copy of GymEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GymEventCopyWith<GymEvent> get copyWith => _$GymEventCopyWithImpl<GymEvent>(this as GymEvent, _$identity);

  /// Serializes this GymEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GymEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.gymId, gymId) || other.gymId == gymId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.location, location) || other.location == location)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,gymId,title,description,startTime,endTime,location,createdAt);

@override
String toString() {
  return 'GymEvent(id: $id, gymId: $gymId, title: $title, description: $description, startTime: $startTime, endTime: $endTime, location: $location, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $GymEventCopyWith<$Res>  {
  factory $GymEventCopyWith(GymEvent value, $Res Function(GymEvent) _then) = _$GymEventCopyWithImpl;
@useResult
$Res call({
 String id, String gymId, String title, String description, String? startTime, String? endTime, String location, String createdAt
});




}
/// @nodoc
class _$GymEventCopyWithImpl<$Res>
    implements $GymEventCopyWith<$Res> {
  _$GymEventCopyWithImpl(this._self, this._then);

  final GymEvent _self;
  final $Res Function(GymEvent) _then;

/// Create a copy of GymEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? gymId = null,Object? title = null,Object? description = null,Object? startTime = freezed,Object? endTime = freezed,Object? location = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,gymId: null == gymId ? _self.gymId : gymId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String?,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GymEvent].
extension GymEventPatterns on GymEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GymEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GymEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GymEvent value)  $default,){
final _that = this;
switch (_that) {
case _GymEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GymEvent value)?  $default,){
final _that = this;
switch (_that) {
case _GymEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String gymId,  String title,  String description,  String? startTime,  String? endTime,  String location,  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GymEvent() when $default != null:
return $default(_that.id,_that.gymId,_that.title,_that.description,_that.startTime,_that.endTime,_that.location,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String gymId,  String title,  String description,  String? startTime,  String? endTime,  String location,  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _GymEvent():
return $default(_that.id,_that.gymId,_that.title,_that.description,_that.startTime,_that.endTime,_that.location,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String gymId,  String title,  String description,  String? startTime,  String? endTime,  String location,  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _GymEvent() when $default != null:
return $default(_that.id,_that.gymId,_that.title,_that.description,_that.startTime,_that.endTime,_that.location,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GymEvent implements GymEvent {
  const _GymEvent({required this.id, required this.gymId, required this.title, this.description = '', this.startTime, this.endTime, this.location = '', required this.createdAt});
  factory _GymEvent.fromJson(Map<String, dynamic> json) => _$GymEventFromJson(json);

@override final  String id;
@override final  String gymId;
@override final  String title;
@override@JsonKey() final  String description;
@override final  String? startTime;
@override final  String? endTime;
@override@JsonKey() final  String location;
@override final  String createdAt;

/// Create a copy of GymEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GymEventCopyWith<_GymEvent> get copyWith => __$GymEventCopyWithImpl<_GymEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GymEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GymEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.gymId, gymId) || other.gymId == gymId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.location, location) || other.location == location)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,gymId,title,description,startTime,endTime,location,createdAt);

@override
String toString() {
  return 'GymEvent(id: $id, gymId: $gymId, title: $title, description: $description, startTime: $startTime, endTime: $endTime, location: $location, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$GymEventCopyWith<$Res> implements $GymEventCopyWith<$Res> {
  factory _$GymEventCopyWith(_GymEvent value, $Res Function(_GymEvent) _then) = __$GymEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String gymId, String title, String description, String? startTime, String? endTime, String location, String createdAt
});




}
/// @nodoc
class __$GymEventCopyWithImpl<$Res>
    implements _$GymEventCopyWith<$Res> {
  __$GymEventCopyWithImpl(this._self, this._then);

  final _GymEvent _self;
  final $Res Function(_GymEvent) _then;

/// Create a copy of GymEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? gymId = null,Object? title = null,Object? description = null,Object? startTime = freezed,Object? endTime = freezed,Object? location = null,Object? createdAt = null,}) {
  return _then(_GymEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,gymId: null == gymId ? _self.gymId : gymId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String?,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CreateGymPayload {

 String get name; String get handle; String? get description; String get category; List<String> get categoryIds; String get accessType; String get subscriptionType; String? get locationCity; String? get locationCountry; List<String> get rules; List<String> get tags; List<GymCategoryPricing> get categoryPricing;
/// Create a copy of CreateGymPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateGymPayloadCopyWith<CreateGymPayload> get copyWith => _$CreateGymPayloadCopyWithImpl<CreateGymPayload>(this as CreateGymPayload, _$identity);

  /// Serializes this CreateGymPayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateGymPayload&&(identical(other.name, name) || other.name == name)&&(identical(other.handle, handle) || other.handle == handle)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.categoryIds, categoryIds)&&(identical(other.accessType, accessType) || other.accessType == accessType)&&(identical(other.subscriptionType, subscriptionType) || other.subscriptionType == subscriptionType)&&(identical(other.locationCity, locationCity) || other.locationCity == locationCity)&&(identical(other.locationCountry, locationCountry) || other.locationCountry == locationCountry)&&const DeepCollectionEquality().equals(other.rules, rules)&&const DeepCollectionEquality().equals(other.tags, tags)&&const DeepCollectionEquality().equals(other.categoryPricing, categoryPricing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,handle,description,category,const DeepCollectionEquality().hash(categoryIds),accessType,subscriptionType,locationCity,locationCountry,const DeepCollectionEquality().hash(rules),const DeepCollectionEquality().hash(tags),const DeepCollectionEquality().hash(categoryPricing));

@override
String toString() {
  return 'CreateGymPayload(name: $name, handle: $handle, description: $description, category: $category, categoryIds: $categoryIds, accessType: $accessType, subscriptionType: $subscriptionType, locationCity: $locationCity, locationCountry: $locationCountry, rules: $rules, tags: $tags, categoryPricing: $categoryPricing)';
}


}

/// @nodoc
abstract mixin class $CreateGymPayloadCopyWith<$Res>  {
  factory $CreateGymPayloadCopyWith(CreateGymPayload value, $Res Function(CreateGymPayload) _then) = _$CreateGymPayloadCopyWithImpl;
@useResult
$Res call({
 String name, String handle, String? description, String category, List<String> categoryIds, String accessType, String subscriptionType, String? locationCity, String? locationCountry, List<String> rules, List<String> tags, List<GymCategoryPricing> categoryPricing
});




}
/// @nodoc
class _$CreateGymPayloadCopyWithImpl<$Res>
    implements $CreateGymPayloadCopyWith<$Res> {
  _$CreateGymPayloadCopyWithImpl(this._self, this._then);

  final CreateGymPayload _self;
  final $Res Function(CreateGymPayload) _then;

/// Create a copy of CreateGymPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? handle = null,Object? description = freezed,Object? category = null,Object? categoryIds = null,Object? accessType = null,Object? subscriptionType = null,Object? locationCity = freezed,Object? locationCountry = freezed,Object? rules = null,Object? tags = null,Object? categoryPricing = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,categoryIds: null == categoryIds ? _self.categoryIds : categoryIds // ignore: cast_nullable_to_non_nullable
as List<String>,accessType: null == accessType ? _self.accessType : accessType // ignore: cast_nullable_to_non_nullable
as String,subscriptionType: null == subscriptionType ? _self.subscriptionType : subscriptionType // ignore: cast_nullable_to_non_nullable
as String,locationCity: freezed == locationCity ? _self.locationCity : locationCity // ignore: cast_nullable_to_non_nullable
as String?,locationCountry: freezed == locationCountry ? _self.locationCountry : locationCountry // ignore: cast_nullable_to_non_nullable
as String?,rules: null == rules ? _self.rules : rules // ignore: cast_nullable_to_non_nullable
as List<String>,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,categoryPricing: null == categoryPricing ? _self.categoryPricing : categoryPricing // ignore: cast_nullable_to_non_nullable
as List<GymCategoryPricing>,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateGymPayload].
extension CreateGymPayloadPatterns on CreateGymPayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateGymPayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateGymPayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateGymPayload value)  $default,){
final _that = this;
switch (_that) {
case _CreateGymPayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateGymPayload value)?  $default,){
final _that = this;
switch (_that) {
case _CreateGymPayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String handle,  String? description,  String category,  List<String> categoryIds,  String accessType,  String subscriptionType,  String? locationCity,  String? locationCountry,  List<String> rules,  List<String> tags,  List<GymCategoryPricing> categoryPricing)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateGymPayload() when $default != null:
return $default(_that.name,_that.handle,_that.description,_that.category,_that.categoryIds,_that.accessType,_that.subscriptionType,_that.locationCity,_that.locationCountry,_that.rules,_that.tags,_that.categoryPricing);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String handle,  String? description,  String category,  List<String> categoryIds,  String accessType,  String subscriptionType,  String? locationCity,  String? locationCountry,  List<String> rules,  List<String> tags,  List<GymCategoryPricing> categoryPricing)  $default,) {final _that = this;
switch (_that) {
case _CreateGymPayload():
return $default(_that.name,_that.handle,_that.description,_that.category,_that.categoryIds,_that.accessType,_that.subscriptionType,_that.locationCity,_that.locationCountry,_that.rules,_that.tags,_that.categoryPricing);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String handle,  String? description,  String category,  List<String> categoryIds,  String accessType,  String subscriptionType,  String? locationCity,  String? locationCountry,  List<String> rules,  List<String> tags,  List<GymCategoryPricing> categoryPricing)?  $default,) {final _that = this;
switch (_that) {
case _CreateGymPayload() when $default != null:
return $default(_that.name,_that.handle,_that.description,_that.category,_that.categoryIds,_that.accessType,_that.subscriptionType,_that.locationCity,_that.locationCountry,_that.rules,_that.tags,_that.categoryPricing);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateGymPayload implements CreateGymPayload {
  const _CreateGymPayload({required this.name, required this.handle, this.description, required this.category, final  List<String> categoryIds = const <String>[], this.accessType = 'public', this.subscriptionType = 'free', this.locationCity, this.locationCountry, final  List<String> rules = const <String>[], final  List<String> tags = const <String>[], final  List<GymCategoryPricing> categoryPricing = const <GymCategoryPricing>[]}): _categoryIds = categoryIds,_rules = rules,_tags = tags,_categoryPricing = categoryPricing;
  factory _CreateGymPayload.fromJson(Map<String, dynamic> json) => _$CreateGymPayloadFromJson(json);

@override final  String name;
@override final  String handle;
@override final  String? description;
@override final  String category;
 final  List<String> _categoryIds;
@override@JsonKey() List<String> get categoryIds {
  if (_categoryIds is EqualUnmodifiableListView) return _categoryIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categoryIds);
}

@override@JsonKey() final  String accessType;
@override@JsonKey() final  String subscriptionType;
@override final  String? locationCity;
@override final  String? locationCountry;
 final  List<String> _rules;
@override@JsonKey() List<String> get rules {
  if (_rules is EqualUnmodifiableListView) return _rules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rules);
}

 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

 final  List<GymCategoryPricing> _categoryPricing;
@override@JsonKey() List<GymCategoryPricing> get categoryPricing {
  if (_categoryPricing is EqualUnmodifiableListView) return _categoryPricing;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categoryPricing);
}


/// Create a copy of CreateGymPayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateGymPayloadCopyWith<_CreateGymPayload> get copyWith => __$CreateGymPayloadCopyWithImpl<_CreateGymPayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateGymPayloadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateGymPayload&&(identical(other.name, name) || other.name == name)&&(identical(other.handle, handle) || other.handle == handle)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other._categoryIds, _categoryIds)&&(identical(other.accessType, accessType) || other.accessType == accessType)&&(identical(other.subscriptionType, subscriptionType) || other.subscriptionType == subscriptionType)&&(identical(other.locationCity, locationCity) || other.locationCity == locationCity)&&(identical(other.locationCountry, locationCountry) || other.locationCountry == locationCountry)&&const DeepCollectionEquality().equals(other._rules, _rules)&&const DeepCollectionEquality().equals(other._tags, _tags)&&const DeepCollectionEquality().equals(other._categoryPricing, _categoryPricing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,handle,description,category,const DeepCollectionEquality().hash(_categoryIds),accessType,subscriptionType,locationCity,locationCountry,const DeepCollectionEquality().hash(_rules),const DeepCollectionEquality().hash(_tags),const DeepCollectionEquality().hash(_categoryPricing));

@override
String toString() {
  return 'CreateGymPayload(name: $name, handle: $handle, description: $description, category: $category, categoryIds: $categoryIds, accessType: $accessType, subscriptionType: $subscriptionType, locationCity: $locationCity, locationCountry: $locationCountry, rules: $rules, tags: $tags, categoryPricing: $categoryPricing)';
}


}

/// @nodoc
abstract mixin class _$CreateGymPayloadCopyWith<$Res> implements $CreateGymPayloadCopyWith<$Res> {
  factory _$CreateGymPayloadCopyWith(_CreateGymPayload value, $Res Function(_CreateGymPayload) _then) = __$CreateGymPayloadCopyWithImpl;
@override @useResult
$Res call({
 String name, String handle, String? description, String category, List<String> categoryIds, String accessType, String subscriptionType, String? locationCity, String? locationCountry, List<String> rules, List<String> tags, List<GymCategoryPricing> categoryPricing
});




}
/// @nodoc
class __$CreateGymPayloadCopyWithImpl<$Res>
    implements _$CreateGymPayloadCopyWith<$Res> {
  __$CreateGymPayloadCopyWithImpl(this._self, this._then);

  final _CreateGymPayload _self;
  final $Res Function(_CreateGymPayload) _then;

/// Create a copy of CreateGymPayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? handle = null,Object? description = freezed,Object? category = null,Object? categoryIds = null,Object? accessType = null,Object? subscriptionType = null,Object? locationCity = freezed,Object? locationCountry = freezed,Object? rules = null,Object? tags = null,Object? categoryPricing = null,}) {
  return _then(_CreateGymPayload(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,categoryIds: null == categoryIds ? _self._categoryIds : categoryIds // ignore: cast_nullable_to_non_nullable
as List<String>,accessType: null == accessType ? _self.accessType : accessType // ignore: cast_nullable_to_non_nullable
as String,subscriptionType: null == subscriptionType ? _self.subscriptionType : subscriptionType // ignore: cast_nullable_to_non_nullable
as String,locationCity: freezed == locationCity ? _self.locationCity : locationCity // ignore: cast_nullable_to_non_nullable
as String?,locationCountry: freezed == locationCountry ? _self.locationCountry : locationCountry // ignore: cast_nullable_to_non_nullable
as String?,rules: null == rules ? _self._rules : rules // ignore: cast_nullable_to_non_nullable
as List<String>,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,categoryPricing: null == categoryPricing ? _self._categoryPricing : categoryPricing // ignore: cast_nullable_to_non_nullable
as List<GymCategoryPricing>,
  ));
}


}

// dart format on
