// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_portal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PortalUser {

 String get id; String? get email; String? get phone;@JsonKey(name: 'phone_verified') bool get phoneVerified;@JsonKey(name: 'email_verified') bool get emailVerified; String? get username;@JsonKey(name: 'display_name') String? get displayName; String? get role;@JsonKey(name: 'verification_status') String? get verificationStatus;@JsonKey(name: 'location_city') String get locationCity;@JsonKey(name: 'is_active') bool get isActive;@JsonKey(name: 'is_staff') bool get isStaff;@JsonKey(name: 'is_superuser') bool get isSuperuser;@JsonKey(name: 'is_adult') bool get isAdult;@JsonKey(name: 'totp_enabled') bool get totpEnabled;@JsonKey(name: 'deleted_at') String? get deletedAt;@JsonKey(name: 'order_count') int get orderCount;@JsonKey(name: 'has_buddy_search') bool get hasBuddySearch;@JsonKey(name: 'created_at') String? get createdAt;@JsonKey(name: 'last_login') String? get lastLogin;
/// Create a copy of PortalUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PortalUserCopyWith<PortalUser> get copyWith => _$PortalUserCopyWithImpl<PortalUser>(this as PortalUser, _$identity);

  /// Serializes this PortalUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PortalUser&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.phoneVerified, phoneVerified) || other.phoneVerified == phoneVerified)&&(identical(other.emailVerified, emailVerified) || other.emailVerified == emailVerified)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.role, role) || other.role == role)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.locationCity, locationCity) || other.locationCity == locationCity)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isStaff, isStaff) || other.isStaff == isStaff)&&(identical(other.isSuperuser, isSuperuser) || other.isSuperuser == isSuperuser)&&(identical(other.isAdult, isAdult) || other.isAdult == isAdult)&&(identical(other.totpEnabled, totpEnabled) || other.totpEnabled == totpEnabled)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.orderCount, orderCount) || other.orderCount == orderCount)&&(identical(other.hasBuddySearch, hasBuddySearch) || other.hasBuddySearch == hasBuddySearch)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastLogin, lastLogin) || other.lastLogin == lastLogin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,email,phone,phoneVerified,emailVerified,username,displayName,role,verificationStatus,locationCity,isActive,isStaff,isSuperuser,isAdult,totpEnabled,deletedAt,orderCount,hasBuddySearch,createdAt,lastLogin]);

@override
String toString() {
  return 'PortalUser(id: $id, email: $email, phone: $phone, phoneVerified: $phoneVerified, emailVerified: $emailVerified, username: $username, displayName: $displayName, role: $role, verificationStatus: $verificationStatus, locationCity: $locationCity, isActive: $isActive, isStaff: $isStaff, isSuperuser: $isSuperuser, isAdult: $isAdult, totpEnabled: $totpEnabled, deletedAt: $deletedAt, orderCount: $orderCount, hasBuddySearch: $hasBuddySearch, createdAt: $createdAt, lastLogin: $lastLogin)';
}


}

/// @nodoc
abstract mixin class $PortalUserCopyWith<$Res>  {
  factory $PortalUserCopyWith(PortalUser value, $Res Function(PortalUser) _then) = _$PortalUserCopyWithImpl;
@useResult
$Res call({
 String id, String? email, String? phone,@JsonKey(name: 'phone_verified') bool phoneVerified,@JsonKey(name: 'email_verified') bool emailVerified, String? username,@JsonKey(name: 'display_name') String? displayName, String? role,@JsonKey(name: 'verification_status') String? verificationStatus,@JsonKey(name: 'location_city') String locationCity,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'is_staff') bool isStaff,@JsonKey(name: 'is_superuser') bool isSuperuser,@JsonKey(name: 'is_adult') bool isAdult,@JsonKey(name: 'totp_enabled') bool totpEnabled,@JsonKey(name: 'deleted_at') String? deletedAt,@JsonKey(name: 'order_count') int orderCount,@JsonKey(name: 'has_buddy_search') bool hasBuddySearch,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'last_login') String? lastLogin
});




}
/// @nodoc
class _$PortalUserCopyWithImpl<$Res>
    implements $PortalUserCopyWith<$Res> {
  _$PortalUserCopyWithImpl(this._self, this._then);

  final PortalUser _self;
  final $Res Function(PortalUser) _then;

/// Create a copy of PortalUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = freezed,Object? phone = freezed,Object? phoneVerified = null,Object? emailVerified = null,Object? username = freezed,Object? displayName = freezed,Object? role = freezed,Object? verificationStatus = freezed,Object? locationCity = null,Object? isActive = null,Object? isStaff = null,Object? isSuperuser = null,Object? isAdult = null,Object? totpEnabled = null,Object? deletedAt = freezed,Object? orderCount = null,Object? hasBuddySearch = null,Object? createdAt = freezed,Object? lastLogin = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,phoneVerified: null == phoneVerified ? _self.phoneVerified : phoneVerified // ignore: cast_nullable_to_non_nullable
as bool,emailVerified: null == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,verificationStatus: freezed == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String?,locationCity: null == locationCity ? _self.locationCity : locationCity // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isStaff: null == isStaff ? _self.isStaff : isStaff // ignore: cast_nullable_to_non_nullable
as bool,isSuperuser: null == isSuperuser ? _self.isSuperuser : isSuperuser // ignore: cast_nullable_to_non_nullable
as bool,isAdult: null == isAdult ? _self.isAdult : isAdult // ignore: cast_nullable_to_non_nullable
as bool,totpEnabled: null == totpEnabled ? _self.totpEnabled : totpEnabled // ignore: cast_nullable_to_non_nullable
as bool,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as String?,orderCount: null == orderCount ? _self.orderCount : orderCount // ignore: cast_nullable_to_non_nullable
as int,hasBuddySearch: null == hasBuddySearch ? _self.hasBuddySearch : hasBuddySearch // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,lastLogin: freezed == lastLogin ? _self.lastLogin : lastLogin // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PortalUser].
extension PortalUserPatterns on PortalUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PortalUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PortalUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PortalUser value)  $default,){
final _that = this;
switch (_that) {
case _PortalUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PortalUser value)?  $default,){
final _that = this;
switch (_that) {
case _PortalUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? email,  String? phone, @JsonKey(name: 'phone_verified')  bool phoneVerified, @JsonKey(name: 'email_verified')  bool emailVerified,  String? username, @JsonKey(name: 'display_name')  String? displayName,  String? role, @JsonKey(name: 'verification_status')  String? verificationStatus, @JsonKey(name: 'location_city')  String locationCity, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'is_staff')  bool isStaff, @JsonKey(name: 'is_superuser')  bool isSuperuser, @JsonKey(name: 'is_adult')  bool isAdult, @JsonKey(name: 'totp_enabled')  bool totpEnabled, @JsonKey(name: 'deleted_at')  String? deletedAt, @JsonKey(name: 'order_count')  int orderCount, @JsonKey(name: 'has_buddy_search')  bool hasBuddySearch, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'last_login')  String? lastLogin)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PortalUser() when $default != null:
return $default(_that.id,_that.email,_that.phone,_that.phoneVerified,_that.emailVerified,_that.username,_that.displayName,_that.role,_that.verificationStatus,_that.locationCity,_that.isActive,_that.isStaff,_that.isSuperuser,_that.isAdult,_that.totpEnabled,_that.deletedAt,_that.orderCount,_that.hasBuddySearch,_that.createdAt,_that.lastLogin);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? email,  String? phone, @JsonKey(name: 'phone_verified')  bool phoneVerified, @JsonKey(name: 'email_verified')  bool emailVerified,  String? username, @JsonKey(name: 'display_name')  String? displayName,  String? role, @JsonKey(name: 'verification_status')  String? verificationStatus, @JsonKey(name: 'location_city')  String locationCity, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'is_staff')  bool isStaff, @JsonKey(name: 'is_superuser')  bool isSuperuser, @JsonKey(name: 'is_adult')  bool isAdult, @JsonKey(name: 'totp_enabled')  bool totpEnabled, @JsonKey(name: 'deleted_at')  String? deletedAt, @JsonKey(name: 'order_count')  int orderCount, @JsonKey(name: 'has_buddy_search')  bool hasBuddySearch, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'last_login')  String? lastLogin)  $default,) {final _that = this;
switch (_that) {
case _PortalUser():
return $default(_that.id,_that.email,_that.phone,_that.phoneVerified,_that.emailVerified,_that.username,_that.displayName,_that.role,_that.verificationStatus,_that.locationCity,_that.isActive,_that.isStaff,_that.isSuperuser,_that.isAdult,_that.totpEnabled,_that.deletedAt,_that.orderCount,_that.hasBuddySearch,_that.createdAt,_that.lastLogin);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? email,  String? phone, @JsonKey(name: 'phone_verified')  bool phoneVerified, @JsonKey(name: 'email_verified')  bool emailVerified,  String? username, @JsonKey(name: 'display_name')  String? displayName,  String? role, @JsonKey(name: 'verification_status')  String? verificationStatus, @JsonKey(name: 'location_city')  String locationCity, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'is_staff')  bool isStaff, @JsonKey(name: 'is_superuser')  bool isSuperuser, @JsonKey(name: 'is_adult')  bool isAdult, @JsonKey(name: 'totp_enabled')  bool totpEnabled, @JsonKey(name: 'deleted_at')  String? deletedAt, @JsonKey(name: 'order_count')  int orderCount, @JsonKey(name: 'has_buddy_search')  bool hasBuddySearch, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'last_login')  String? lastLogin)?  $default,) {final _that = this;
switch (_that) {
case _PortalUser() when $default != null:
return $default(_that.id,_that.email,_that.phone,_that.phoneVerified,_that.emailVerified,_that.username,_that.displayName,_that.role,_that.verificationStatus,_that.locationCity,_that.isActive,_that.isStaff,_that.isSuperuser,_that.isAdult,_that.totpEnabled,_that.deletedAt,_that.orderCount,_that.hasBuddySearch,_that.createdAt,_that.lastLogin);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PortalUser implements PortalUser {
  const _PortalUser({required this.id, this.email, this.phone, @JsonKey(name: 'phone_verified') this.phoneVerified = false, @JsonKey(name: 'email_verified') this.emailVerified = false, this.username, @JsonKey(name: 'display_name') this.displayName, this.role, @JsonKey(name: 'verification_status') this.verificationStatus, @JsonKey(name: 'location_city') this.locationCity = '', @JsonKey(name: 'is_active') this.isActive = true, @JsonKey(name: 'is_staff') this.isStaff = false, @JsonKey(name: 'is_superuser') this.isSuperuser = false, @JsonKey(name: 'is_adult') this.isAdult = false, @JsonKey(name: 'totp_enabled') this.totpEnabled = false, @JsonKey(name: 'deleted_at') this.deletedAt, @JsonKey(name: 'order_count') this.orderCount = 0, @JsonKey(name: 'has_buddy_search') this.hasBuddySearch = false, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'last_login') this.lastLogin});
  factory _PortalUser.fromJson(Map<String, dynamic> json) => _$PortalUserFromJson(json);

@override final  String id;
@override final  String? email;
@override final  String? phone;
@override@JsonKey(name: 'phone_verified') final  bool phoneVerified;
@override@JsonKey(name: 'email_verified') final  bool emailVerified;
@override final  String? username;
@override@JsonKey(name: 'display_name') final  String? displayName;
@override final  String? role;
@override@JsonKey(name: 'verification_status') final  String? verificationStatus;
@override@JsonKey(name: 'location_city') final  String locationCity;
@override@JsonKey(name: 'is_active') final  bool isActive;
@override@JsonKey(name: 'is_staff') final  bool isStaff;
@override@JsonKey(name: 'is_superuser') final  bool isSuperuser;
@override@JsonKey(name: 'is_adult') final  bool isAdult;
@override@JsonKey(name: 'totp_enabled') final  bool totpEnabled;
@override@JsonKey(name: 'deleted_at') final  String? deletedAt;
@override@JsonKey(name: 'order_count') final  int orderCount;
@override@JsonKey(name: 'has_buddy_search') final  bool hasBuddySearch;
@override@JsonKey(name: 'created_at') final  String? createdAt;
@override@JsonKey(name: 'last_login') final  String? lastLogin;

/// Create a copy of PortalUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PortalUserCopyWith<_PortalUser> get copyWith => __$PortalUserCopyWithImpl<_PortalUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PortalUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PortalUser&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.phoneVerified, phoneVerified) || other.phoneVerified == phoneVerified)&&(identical(other.emailVerified, emailVerified) || other.emailVerified == emailVerified)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.role, role) || other.role == role)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.locationCity, locationCity) || other.locationCity == locationCity)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isStaff, isStaff) || other.isStaff == isStaff)&&(identical(other.isSuperuser, isSuperuser) || other.isSuperuser == isSuperuser)&&(identical(other.isAdult, isAdult) || other.isAdult == isAdult)&&(identical(other.totpEnabled, totpEnabled) || other.totpEnabled == totpEnabled)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.orderCount, orderCount) || other.orderCount == orderCount)&&(identical(other.hasBuddySearch, hasBuddySearch) || other.hasBuddySearch == hasBuddySearch)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastLogin, lastLogin) || other.lastLogin == lastLogin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,email,phone,phoneVerified,emailVerified,username,displayName,role,verificationStatus,locationCity,isActive,isStaff,isSuperuser,isAdult,totpEnabled,deletedAt,orderCount,hasBuddySearch,createdAt,lastLogin]);

@override
String toString() {
  return 'PortalUser(id: $id, email: $email, phone: $phone, phoneVerified: $phoneVerified, emailVerified: $emailVerified, username: $username, displayName: $displayName, role: $role, verificationStatus: $verificationStatus, locationCity: $locationCity, isActive: $isActive, isStaff: $isStaff, isSuperuser: $isSuperuser, isAdult: $isAdult, totpEnabled: $totpEnabled, deletedAt: $deletedAt, orderCount: $orderCount, hasBuddySearch: $hasBuddySearch, createdAt: $createdAt, lastLogin: $lastLogin)';
}


}

/// @nodoc
abstract mixin class _$PortalUserCopyWith<$Res> implements $PortalUserCopyWith<$Res> {
  factory _$PortalUserCopyWith(_PortalUser value, $Res Function(_PortalUser) _then) = __$PortalUserCopyWithImpl;
@override @useResult
$Res call({
 String id, String? email, String? phone,@JsonKey(name: 'phone_verified') bool phoneVerified,@JsonKey(name: 'email_verified') bool emailVerified, String? username,@JsonKey(name: 'display_name') String? displayName, String? role,@JsonKey(name: 'verification_status') String? verificationStatus,@JsonKey(name: 'location_city') String locationCity,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'is_staff') bool isStaff,@JsonKey(name: 'is_superuser') bool isSuperuser,@JsonKey(name: 'is_adult') bool isAdult,@JsonKey(name: 'totp_enabled') bool totpEnabled,@JsonKey(name: 'deleted_at') String? deletedAt,@JsonKey(name: 'order_count') int orderCount,@JsonKey(name: 'has_buddy_search') bool hasBuddySearch,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'last_login') String? lastLogin
});




}
/// @nodoc
class __$PortalUserCopyWithImpl<$Res>
    implements _$PortalUserCopyWith<$Res> {
  __$PortalUserCopyWithImpl(this._self, this._then);

  final _PortalUser _self;
  final $Res Function(_PortalUser) _then;

/// Create a copy of PortalUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = freezed,Object? phone = freezed,Object? phoneVerified = null,Object? emailVerified = null,Object? username = freezed,Object? displayName = freezed,Object? role = freezed,Object? verificationStatus = freezed,Object? locationCity = null,Object? isActive = null,Object? isStaff = null,Object? isSuperuser = null,Object? isAdult = null,Object? totpEnabled = null,Object? deletedAt = freezed,Object? orderCount = null,Object? hasBuddySearch = null,Object? createdAt = freezed,Object? lastLogin = freezed,}) {
  return _then(_PortalUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,phoneVerified: null == phoneVerified ? _self.phoneVerified : phoneVerified // ignore: cast_nullable_to_non_nullable
as bool,emailVerified: null == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,verificationStatus: freezed == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String?,locationCity: null == locationCity ? _self.locationCity : locationCity // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isStaff: null == isStaff ? _self.isStaff : isStaff // ignore: cast_nullable_to_non_nullable
as bool,isSuperuser: null == isSuperuser ? _self.isSuperuser : isSuperuser // ignore: cast_nullable_to_non_nullable
as bool,isAdult: null == isAdult ? _self.isAdult : isAdult // ignore: cast_nullable_to_non_nullable
as bool,totpEnabled: null == totpEnabled ? _self.totpEnabled : totpEnabled // ignore: cast_nullable_to_non_nullable
as bool,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as String?,orderCount: null == orderCount ? _self.orderCount : orderCount // ignore: cast_nullable_to_non_nullable
as int,hasBuddySearch: null == hasBuddySearch ? _self.hasBuddySearch : hasBuddySearch // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,lastLogin: freezed == lastLogin ? _self.lastLogin : lastLogin // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PortalShop {

 String get id; String? get name; String? get handle; String? get category;@JsonKey(name: 'is_active') bool get isActive;@JsonKey(name: 'verification_status') String? get verificationStatus;@JsonKey(name: 'rejection_reason') String get rejectionReason;@JsonKey(name: 'verification_applied_at') String? get verificationAppliedAt;@JsonKey(name: 'verified_at') String? get verifiedAt;@JsonKey(name: 'contact_email') String get contactEmail;@JsonKey(name: 'product_count') int get productCount;@JsonKey(name: 'member_count') int get memberCount;@JsonKey(name: 'owner_count') int get ownerCount;@JsonKey(name: 'created_at') String? get createdAt;@JsonKey(name: 'updated_at') String? get updatedAt;
/// Create a copy of PortalShop
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PortalShopCopyWith<PortalShop> get copyWith => _$PortalShopCopyWithImpl<PortalShop>(this as PortalShop, _$identity);

  /// Serializes this PortalShop to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PortalShop&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.handle, handle) || other.handle == handle)&&(identical(other.category, category) || other.category == category)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.verificationAppliedAt, verificationAppliedAt) || other.verificationAppliedAt == verificationAppliedAt)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.contactEmail, contactEmail) || other.contactEmail == contactEmail)&&(identical(other.productCount, productCount) || other.productCount == productCount)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount)&&(identical(other.ownerCount, ownerCount) || other.ownerCount == ownerCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,handle,category,isActive,verificationStatus,rejectionReason,verificationAppliedAt,verifiedAt,contactEmail,productCount,memberCount,ownerCount,createdAt,updatedAt);

@override
String toString() {
  return 'PortalShop(id: $id, name: $name, handle: $handle, category: $category, isActive: $isActive, verificationStatus: $verificationStatus, rejectionReason: $rejectionReason, verificationAppliedAt: $verificationAppliedAt, verifiedAt: $verifiedAt, contactEmail: $contactEmail, productCount: $productCount, memberCount: $memberCount, ownerCount: $ownerCount, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PortalShopCopyWith<$Res>  {
  factory $PortalShopCopyWith(PortalShop value, $Res Function(PortalShop) _then) = _$PortalShopCopyWithImpl;
@useResult
$Res call({
 String id, String? name, String? handle, String? category,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'verification_status') String? verificationStatus,@JsonKey(name: 'rejection_reason') String rejectionReason,@JsonKey(name: 'verification_applied_at') String? verificationAppliedAt,@JsonKey(name: 'verified_at') String? verifiedAt,@JsonKey(name: 'contact_email') String contactEmail,@JsonKey(name: 'product_count') int productCount,@JsonKey(name: 'member_count') int memberCount,@JsonKey(name: 'owner_count') int ownerCount,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
});




}
/// @nodoc
class _$PortalShopCopyWithImpl<$Res>
    implements $PortalShopCopyWith<$Res> {
  _$PortalShopCopyWithImpl(this._self, this._then);

  final PortalShop _self;
  final $Res Function(PortalShop) _then;

/// Create a copy of PortalShop
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = freezed,Object? handle = freezed,Object? category = freezed,Object? isActive = null,Object? verificationStatus = freezed,Object? rejectionReason = null,Object? verificationAppliedAt = freezed,Object? verifiedAt = freezed,Object? contactEmail = null,Object? productCount = null,Object? memberCount = null,Object? ownerCount = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,handle: freezed == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,verificationStatus: freezed == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String?,rejectionReason: null == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String,verificationAppliedAt: freezed == verificationAppliedAt ? _self.verificationAppliedAt : verificationAppliedAt // ignore: cast_nullable_to_non_nullable
as String?,verifiedAt: freezed == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as String?,contactEmail: null == contactEmail ? _self.contactEmail : contactEmail // ignore: cast_nullable_to_non_nullable
as String,productCount: null == productCount ? _self.productCount : productCount // ignore: cast_nullable_to_non_nullable
as int,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,ownerCount: null == ownerCount ? _self.ownerCount : ownerCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PortalShop].
extension PortalShopPatterns on PortalShop {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PortalShop value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PortalShop() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PortalShop value)  $default,){
final _that = this;
switch (_that) {
case _PortalShop():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PortalShop value)?  $default,){
final _that = this;
switch (_that) {
case _PortalShop() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? name,  String? handle,  String? category, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'verification_status')  String? verificationStatus, @JsonKey(name: 'rejection_reason')  String rejectionReason, @JsonKey(name: 'verification_applied_at')  String? verificationAppliedAt, @JsonKey(name: 'verified_at')  String? verifiedAt, @JsonKey(name: 'contact_email')  String contactEmail, @JsonKey(name: 'product_count')  int productCount, @JsonKey(name: 'member_count')  int memberCount, @JsonKey(name: 'owner_count')  int ownerCount, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PortalShop() when $default != null:
return $default(_that.id,_that.name,_that.handle,_that.category,_that.isActive,_that.verificationStatus,_that.rejectionReason,_that.verificationAppliedAt,_that.verifiedAt,_that.contactEmail,_that.productCount,_that.memberCount,_that.ownerCount,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? name,  String? handle,  String? category, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'verification_status')  String? verificationStatus, @JsonKey(name: 'rejection_reason')  String rejectionReason, @JsonKey(name: 'verification_applied_at')  String? verificationAppliedAt, @JsonKey(name: 'verified_at')  String? verifiedAt, @JsonKey(name: 'contact_email')  String contactEmail, @JsonKey(name: 'product_count')  int productCount, @JsonKey(name: 'member_count')  int memberCount, @JsonKey(name: 'owner_count')  int ownerCount, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PortalShop():
return $default(_that.id,_that.name,_that.handle,_that.category,_that.isActive,_that.verificationStatus,_that.rejectionReason,_that.verificationAppliedAt,_that.verifiedAt,_that.contactEmail,_that.productCount,_that.memberCount,_that.ownerCount,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? name,  String? handle,  String? category, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'verification_status')  String? verificationStatus, @JsonKey(name: 'rejection_reason')  String rejectionReason, @JsonKey(name: 'verification_applied_at')  String? verificationAppliedAt, @JsonKey(name: 'verified_at')  String? verifiedAt, @JsonKey(name: 'contact_email')  String contactEmail, @JsonKey(name: 'product_count')  int productCount, @JsonKey(name: 'member_count')  int memberCount, @JsonKey(name: 'owner_count')  int ownerCount, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PortalShop() when $default != null:
return $default(_that.id,_that.name,_that.handle,_that.category,_that.isActive,_that.verificationStatus,_that.rejectionReason,_that.verificationAppliedAt,_that.verifiedAt,_that.contactEmail,_that.productCount,_that.memberCount,_that.ownerCount,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PortalShop implements PortalShop {
  const _PortalShop({required this.id, this.name, this.handle, this.category, @JsonKey(name: 'is_active') this.isActive = true, @JsonKey(name: 'verification_status') this.verificationStatus, @JsonKey(name: 'rejection_reason') this.rejectionReason = '', @JsonKey(name: 'verification_applied_at') this.verificationAppliedAt, @JsonKey(name: 'verified_at') this.verifiedAt, @JsonKey(name: 'contact_email') this.contactEmail = '', @JsonKey(name: 'product_count') this.productCount = 0, @JsonKey(name: 'member_count') this.memberCount = 0, @JsonKey(name: 'owner_count') this.ownerCount = 0, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _PortalShop.fromJson(Map<String, dynamic> json) => _$PortalShopFromJson(json);

@override final  String id;
@override final  String? name;
@override final  String? handle;
@override final  String? category;
@override@JsonKey(name: 'is_active') final  bool isActive;
@override@JsonKey(name: 'verification_status') final  String? verificationStatus;
@override@JsonKey(name: 'rejection_reason') final  String rejectionReason;
@override@JsonKey(name: 'verification_applied_at') final  String? verificationAppliedAt;
@override@JsonKey(name: 'verified_at') final  String? verifiedAt;
@override@JsonKey(name: 'contact_email') final  String contactEmail;
@override@JsonKey(name: 'product_count') final  int productCount;
@override@JsonKey(name: 'member_count') final  int memberCount;
@override@JsonKey(name: 'owner_count') final  int ownerCount;
@override@JsonKey(name: 'created_at') final  String? createdAt;
@override@JsonKey(name: 'updated_at') final  String? updatedAt;

/// Create a copy of PortalShop
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PortalShopCopyWith<_PortalShop> get copyWith => __$PortalShopCopyWithImpl<_PortalShop>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PortalShopToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PortalShop&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.handle, handle) || other.handle == handle)&&(identical(other.category, category) || other.category == category)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.verificationAppliedAt, verificationAppliedAt) || other.verificationAppliedAt == verificationAppliedAt)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.contactEmail, contactEmail) || other.contactEmail == contactEmail)&&(identical(other.productCount, productCount) || other.productCount == productCount)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount)&&(identical(other.ownerCount, ownerCount) || other.ownerCount == ownerCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,handle,category,isActive,verificationStatus,rejectionReason,verificationAppliedAt,verifiedAt,contactEmail,productCount,memberCount,ownerCount,createdAt,updatedAt);

@override
String toString() {
  return 'PortalShop(id: $id, name: $name, handle: $handle, category: $category, isActive: $isActive, verificationStatus: $verificationStatus, rejectionReason: $rejectionReason, verificationAppliedAt: $verificationAppliedAt, verifiedAt: $verifiedAt, contactEmail: $contactEmail, productCount: $productCount, memberCount: $memberCount, ownerCount: $ownerCount, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PortalShopCopyWith<$Res> implements $PortalShopCopyWith<$Res> {
  factory _$PortalShopCopyWith(_PortalShop value, $Res Function(_PortalShop) _then) = __$PortalShopCopyWithImpl;
@override @useResult
$Res call({
 String id, String? name, String? handle, String? category,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'verification_status') String? verificationStatus,@JsonKey(name: 'rejection_reason') String rejectionReason,@JsonKey(name: 'verification_applied_at') String? verificationAppliedAt,@JsonKey(name: 'verified_at') String? verifiedAt,@JsonKey(name: 'contact_email') String contactEmail,@JsonKey(name: 'product_count') int productCount,@JsonKey(name: 'member_count') int memberCount,@JsonKey(name: 'owner_count') int ownerCount,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
});




}
/// @nodoc
class __$PortalShopCopyWithImpl<$Res>
    implements _$PortalShopCopyWith<$Res> {
  __$PortalShopCopyWithImpl(this._self, this._then);

  final _PortalShop _self;
  final $Res Function(_PortalShop) _then;

/// Create a copy of PortalShop
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = freezed,Object? handle = freezed,Object? category = freezed,Object? isActive = null,Object? verificationStatus = freezed,Object? rejectionReason = null,Object? verificationAppliedAt = freezed,Object? verifiedAt = freezed,Object? contactEmail = null,Object? productCount = null,Object? memberCount = null,Object? ownerCount = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_PortalShop(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,handle: freezed == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,verificationStatus: freezed == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String?,rejectionReason: null == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String,verificationAppliedAt: freezed == verificationAppliedAt ? _self.verificationAppliedAt : verificationAppliedAt // ignore: cast_nullable_to_non_nullable
as String?,verifiedAt: freezed == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as String?,contactEmail: null == contactEmail ? _self.contactEmail : contactEmail // ignore: cast_nullable_to_non_nullable
as String,productCount: null == productCount ? _self.productCount : productCount // ignore: cast_nullable_to_non_nullable
as int,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,ownerCount: null == ownerCount ? _self.ownerCount : ownerCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PortalProduct {

 String get id; String? get name; String? get brand; String? get category;@JsonKey(name: 'is_active') bool get isActive; String? get shop;@JsonKey(name: 'shop_handle') String? get shopHandle;@JsonKey(name: 'price_display') String? get priceDisplay;@JsonKey(name: 'stock_quantity') int? get stockQuantity;@JsonKey(name: 'stock_tracking_enabled') bool get stockTrackingEnabled;@JsonKey(name: 'click_count') int get clickCount;@JsonKey(name: 'content_rating') String get contentRating;@JsonKey(name: 'supplement_registration_number') String? get supplementRegistrationNumber;@JsonKey(name: 'supplement_registration_expiry') String? get supplementRegistrationExpiry;@JsonKey(name: 'supplement_claims_reviewed') bool get supplementClaimsReviewed;@JsonKey(name: 'created_at') String? get createdAt;
/// Create a copy of PortalProduct
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PortalProductCopyWith<PortalProduct> get copyWith => _$PortalProductCopyWithImpl<PortalProduct>(this as PortalProduct, _$identity);

  /// Serializes this PortalProduct to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PortalProduct&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.category, category) || other.category == category)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.shop, shop) || other.shop == shop)&&(identical(other.shopHandle, shopHandle) || other.shopHandle == shopHandle)&&(identical(other.priceDisplay, priceDisplay) || other.priceDisplay == priceDisplay)&&(identical(other.stockQuantity, stockQuantity) || other.stockQuantity == stockQuantity)&&(identical(other.stockTrackingEnabled, stockTrackingEnabled) || other.stockTrackingEnabled == stockTrackingEnabled)&&(identical(other.clickCount, clickCount) || other.clickCount == clickCount)&&(identical(other.contentRating, contentRating) || other.contentRating == contentRating)&&(identical(other.supplementRegistrationNumber, supplementRegistrationNumber) || other.supplementRegistrationNumber == supplementRegistrationNumber)&&(identical(other.supplementRegistrationExpiry, supplementRegistrationExpiry) || other.supplementRegistrationExpiry == supplementRegistrationExpiry)&&(identical(other.supplementClaimsReviewed, supplementClaimsReviewed) || other.supplementClaimsReviewed == supplementClaimsReviewed)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,brand,category,isActive,shop,shopHandle,priceDisplay,stockQuantity,stockTrackingEnabled,clickCount,contentRating,supplementRegistrationNumber,supplementRegistrationExpiry,supplementClaimsReviewed,createdAt);

@override
String toString() {
  return 'PortalProduct(id: $id, name: $name, brand: $brand, category: $category, isActive: $isActive, shop: $shop, shopHandle: $shopHandle, priceDisplay: $priceDisplay, stockQuantity: $stockQuantity, stockTrackingEnabled: $stockTrackingEnabled, clickCount: $clickCount, contentRating: $contentRating, supplementRegistrationNumber: $supplementRegistrationNumber, supplementRegistrationExpiry: $supplementRegistrationExpiry, supplementClaimsReviewed: $supplementClaimsReviewed, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PortalProductCopyWith<$Res>  {
  factory $PortalProductCopyWith(PortalProduct value, $Res Function(PortalProduct) _then) = _$PortalProductCopyWithImpl;
@useResult
$Res call({
 String id, String? name, String? brand, String? category,@JsonKey(name: 'is_active') bool isActive, String? shop,@JsonKey(name: 'shop_handle') String? shopHandle,@JsonKey(name: 'price_display') String? priceDisplay,@JsonKey(name: 'stock_quantity') int? stockQuantity,@JsonKey(name: 'stock_tracking_enabled') bool stockTrackingEnabled,@JsonKey(name: 'click_count') int clickCount,@JsonKey(name: 'content_rating') String contentRating,@JsonKey(name: 'supplement_registration_number') String? supplementRegistrationNumber,@JsonKey(name: 'supplement_registration_expiry') String? supplementRegistrationExpiry,@JsonKey(name: 'supplement_claims_reviewed') bool supplementClaimsReviewed,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class _$PortalProductCopyWithImpl<$Res>
    implements $PortalProductCopyWith<$Res> {
  _$PortalProductCopyWithImpl(this._self, this._then);

  final PortalProduct _self;
  final $Res Function(PortalProduct) _then;

/// Create a copy of PortalProduct
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = freezed,Object? brand = freezed,Object? category = freezed,Object? isActive = null,Object? shop = freezed,Object? shopHandle = freezed,Object? priceDisplay = freezed,Object? stockQuantity = freezed,Object? stockTrackingEnabled = null,Object? clickCount = null,Object? contentRating = null,Object? supplementRegistrationNumber = freezed,Object? supplementRegistrationExpiry = freezed,Object? supplementClaimsReviewed = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,shop: freezed == shop ? _self.shop : shop // ignore: cast_nullable_to_non_nullable
as String?,shopHandle: freezed == shopHandle ? _self.shopHandle : shopHandle // ignore: cast_nullable_to_non_nullable
as String?,priceDisplay: freezed == priceDisplay ? _self.priceDisplay : priceDisplay // ignore: cast_nullable_to_non_nullable
as String?,stockQuantity: freezed == stockQuantity ? _self.stockQuantity : stockQuantity // ignore: cast_nullable_to_non_nullable
as int?,stockTrackingEnabled: null == stockTrackingEnabled ? _self.stockTrackingEnabled : stockTrackingEnabled // ignore: cast_nullable_to_non_nullable
as bool,clickCount: null == clickCount ? _self.clickCount : clickCount // ignore: cast_nullable_to_non_nullable
as int,contentRating: null == contentRating ? _self.contentRating : contentRating // ignore: cast_nullable_to_non_nullable
as String,supplementRegistrationNumber: freezed == supplementRegistrationNumber ? _self.supplementRegistrationNumber : supplementRegistrationNumber // ignore: cast_nullable_to_non_nullable
as String?,supplementRegistrationExpiry: freezed == supplementRegistrationExpiry ? _self.supplementRegistrationExpiry : supplementRegistrationExpiry // ignore: cast_nullable_to_non_nullable
as String?,supplementClaimsReviewed: null == supplementClaimsReviewed ? _self.supplementClaimsReviewed : supplementClaimsReviewed // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PortalProduct].
extension PortalProductPatterns on PortalProduct {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PortalProduct value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PortalProduct() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PortalProduct value)  $default,){
final _that = this;
switch (_that) {
case _PortalProduct():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PortalProduct value)?  $default,){
final _that = this;
switch (_that) {
case _PortalProduct() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? name,  String? brand,  String? category, @JsonKey(name: 'is_active')  bool isActive,  String? shop, @JsonKey(name: 'shop_handle')  String? shopHandle, @JsonKey(name: 'price_display')  String? priceDisplay, @JsonKey(name: 'stock_quantity')  int? stockQuantity, @JsonKey(name: 'stock_tracking_enabled')  bool stockTrackingEnabled, @JsonKey(name: 'click_count')  int clickCount, @JsonKey(name: 'content_rating')  String contentRating, @JsonKey(name: 'supplement_registration_number')  String? supplementRegistrationNumber, @JsonKey(name: 'supplement_registration_expiry')  String? supplementRegistrationExpiry, @JsonKey(name: 'supplement_claims_reviewed')  bool supplementClaimsReviewed, @JsonKey(name: 'created_at')  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PortalProduct() when $default != null:
return $default(_that.id,_that.name,_that.brand,_that.category,_that.isActive,_that.shop,_that.shopHandle,_that.priceDisplay,_that.stockQuantity,_that.stockTrackingEnabled,_that.clickCount,_that.contentRating,_that.supplementRegistrationNumber,_that.supplementRegistrationExpiry,_that.supplementClaimsReviewed,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? name,  String? brand,  String? category, @JsonKey(name: 'is_active')  bool isActive,  String? shop, @JsonKey(name: 'shop_handle')  String? shopHandle, @JsonKey(name: 'price_display')  String? priceDisplay, @JsonKey(name: 'stock_quantity')  int? stockQuantity, @JsonKey(name: 'stock_tracking_enabled')  bool stockTrackingEnabled, @JsonKey(name: 'click_count')  int clickCount, @JsonKey(name: 'content_rating')  String contentRating, @JsonKey(name: 'supplement_registration_number')  String? supplementRegistrationNumber, @JsonKey(name: 'supplement_registration_expiry')  String? supplementRegistrationExpiry, @JsonKey(name: 'supplement_claims_reviewed')  bool supplementClaimsReviewed, @JsonKey(name: 'created_at')  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _PortalProduct():
return $default(_that.id,_that.name,_that.brand,_that.category,_that.isActive,_that.shop,_that.shopHandle,_that.priceDisplay,_that.stockQuantity,_that.stockTrackingEnabled,_that.clickCount,_that.contentRating,_that.supplementRegistrationNumber,_that.supplementRegistrationExpiry,_that.supplementClaimsReviewed,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? name,  String? brand,  String? category, @JsonKey(name: 'is_active')  bool isActive,  String? shop, @JsonKey(name: 'shop_handle')  String? shopHandle, @JsonKey(name: 'price_display')  String? priceDisplay, @JsonKey(name: 'stock_quantity')  int? stockQuantity, @JsonKey(name: 'stock_tracking_enabled')  bool stockTrackingEnabled, @JsonKey(name: 'click_count')  int clickCount, @JsonKey(name: 'content_rating')  String contentRating, @JsonKey(name: 'supplement_registration_number')  String? supplementRegistrationNumber, @JsonKey(name: 'supplement_registration_expiry')  String? supplementRegistrationExpiry, @JsonKey(name: 'supplement_claims_reviewed')  bool supplementClaimsReviewed, @JsonKey(name: 'created_at')  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _PortalProduct() when $default != null:
return $default(_that.id,_that.name,_that.brand,_that.category,_that.isActive,_that.shop,_that.shopHandle,_that.priceDisplay,_that.stockQuantity,_that.stockTrackingEnabled,_that.clickCount,_that.contentRating,_that.supplementRegistrationNumber,_that.supplementRegistrationExpiry,_that.supplementClaimsReviewed,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PortalProduct implements PortalProduct {
  const _PortalProduct({required this.id, this.name, this.brand, this.category, @JsonKey(name: 'is_active') this.isActive = true, this.shop, @JsonKey(name: 'shop_handle') this.shopHandle, @JsonKey(name: 'price_display') this.priceDisplay, @JsonKey(name: 'stock_quantity') this.stockQuantity, @JsonKey(name: 'stock_tracking_enabled') this.stockTrackingEnabled = false, @JsonKey(name: 'click_count') this.clickCount = 0, @JsonKey(name: 'content_rating') this.contentRating = 'general', @JsonKey(name: 'supplement_registration_number') this.supplementRegistrationNumber, @JsonKey(name: 'supplement_registration_expiry') this.supplementRegistrationExpiry, @JsonKey(name: 'supplement_claims_reviewed') this.supplementClaimsReviewed = false, @JsonKey(name: 'created_at') this.createdAt});
  factory _PortalProduct.fromJson(Map<String, dynamic> json) => _$PortalProductFromJson(json);

@override final  String id;
@override final  String? name;
@override final  String? brand;
@override final  String? category;
@override@JsonKey(name: 'is_active') final  bool isActive;
@override final  String? shop;
@override@JsonKey(name: 'shop_handle') final  String? shopHandle;
@override@JsonKey(name: 'price_display') final  String? priceDisplay;
@override@JsonKey(name: 'stock_quantity') final  int? stockQuantity;
@override@JsonKey(name: 'stock_tracking_enabled') final  bool stockTrackingEnabled;
@override@JsonKey(name: 'click_count') final  int clickCount;
@override@JsonKey(name: 'content_rating') final  String contentRating;
@override@JsonKey(name: 'supplement_registration_number') final  String? supplementRegistrationNumber;
@override@JsonKey(name: 'supplement_registration_expiry') final  String? supplementRegistrationExpiry;
@override@JsonKey(name: 'supplement_claims_reviewed') final  bool supplementClaimsReviewed;
@override@JsonKey(name: 'created_at') final  String? createdAt;

/// Create a copy of PortalProduct
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PortalProductCopyWith<_PortalProduct> get copyWith => __$PortalProductCopyWithImpl<_PortalProduct>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PortalProductToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PortalProduct&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.category, category) || other.category == category)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.shop, shop) || other.shop == shop)&&(identical(other.shopHandle, shopHandle) || other.shopHandle == shopHandle)&&(identical(other.priceDisplay, priceDisplay) || other.priceDisplay == priceDisplay)&&(identical(other.stockQuantity, stockQuantity) || other.stockQuantity == stockQuantity)&&(identical(other.stockTrackingEnabled, stockTrackingEnabled) || other.stockTrackingEnabled == stockTrackingEnabled)&&(identical(other.clickCount, clickCount) || other.clickCount == clickCount)&&(identical(other.contentRating, contentRating) || other.contentRating == contentRating)&&(identical(other.supplementRegistrationNumber, supplementRegistrationNumber) || other.supplementRegistrationNumber == supplementRegistrationNumber)&&(identical(other.supplementRegistrationExpiry, supplementRegistrationExpiry) || other.supplementRegistrationExpiry == supplementRegistrationExpiry)&&(identical(other.supplementClaimsReviewed, supplementClaimsReviewed) || other.supplementClaimsReviewed == supplementClaimsReviewed)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,brand,category,isActive,shop,shopHandle,priceDisplay,stockQuantity,stockTrackingEnabled,clickCount,contentRating,supplementRegistrationNumber,supplementRegistrationExpiry,supplementClaimsReviewed,createdAt);

@override
String toString() {
  return 'PortalProduct(id: $id, name: $name, brand: $brand, category: $category, isActive: $isActive, shop: $shop, shopHandle: $shopHandle, priceDisplay: $priceDisplay, stockQuantity: $stockQuantity, stockTrackingEnabled: $stockTrackingEnabled, clickCount: $clickCount, contentRating: $contentRating, supplementRegistrationNumber: $supplementRegistrationNumber, supplementRegistrationExpiry: $supplementRegistrationExpiry, supplementClaimsReviewed: $supplementClaimsReviewed, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PortalProductCopyWith<$Res> implements $PortalProductCopyWith<$Res> {
  factory _$PortalProductCopyWith(_PortalProduct value, $Res Function(_PortalProduct) _then) = __$PortalProductCopyWithImpl;
@override @useResult
$Res call({
 String id, String? name, String? brand, String? category,@JsonKey(name: 'is_active') bool isActive, String? shop,@JsonKey(name: 'shop_handle') String? shopHandle,@JsonKey(name: 'price_display') String? priceDisplay,@JsonKey(name: 'stock_quantity') int? stockQuantity,@JsonKey(name: 'stock_tracking_enabled') bool stockTrackingEnabled,@JsonKey(name: 'click_count') int clickCount,@JsonKey(name: 'content_rating') String contentRating,@JsonKey(name: 'supplement_registration_number') String? supplementRegistrationNumber,@JsonKey(name: 'supplement_registration_expiry') String? supplementRegistrationExpiry,@JsonKey(name: 'supplement_claims_reviewed') bool supplementClaimsReviewed,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class __$PortalProductCopyWithImpl<$Res>
    implements _$PortalProductCopyWith<$Res> {
  __$PortalProductCopyWithImpl(this._self, this._then);

  final _PortalProduct _self;
  final $Res Function(_PortalProduct) _then;

/// Create a copy of PortalProduct
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = freezed,Object? brand = freezed,Object? category = freezed,Object? isActive = null,Object? shop = freezed,Object? shopHandle = freezed,Object? priceDisplay = freezed,Object? stockQuantity = freezed,Object? stockTrackingEnabled = null,Object? clickCount = null,Object? contentRating = null,Object? supplementRegistrationNumber = freezed,Object? supplementRegistrationExpiry = freezed,Object? supplementClaimsReviewed = null,Object? createdAt = freezed,}) {
  return _then(_PortalProduct(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,shop: freezed == shop ? _self.shop : shop // ignore: cast_nullable_to_non_nullable
as String?,shopHandle: freezed == shopHandle ? _self.shopHandle : shopHandle // ignore: cast_nullable_to_non_nullable
as String?,priceDisplay: freezed == priceDisplay ? _self.priceDisplay : priceDisplay // ignore: cast_nullable_to_non_nullable
as String?,stockQuantity: freezed == stockQuantity ? _self.stockQuantity : stockQuantity // ignore: cast_nullable_to_non_nullable
as int?,stockTrackingEnabled: null == stockTrackingEnabled ? _self.stockTrackingEnabled : stockTrackingEnabled // ignore: cast_nullable_to_non_nullable
as bool,clickCount: null == clickCount ? _self.clickCount : clickCount // ignore: cast_nullable_to_non_nullable
as int,contentRating: null == contentRating ? _self.contentRating : contentRating // ignore: cast_nullable_to_non_nullable
as String,supplementRegistrationNumber: freezed == supplementRegistrationNumber ? _self.supplementRegistrationNumber : supplementRegistrationNumber // ignore: cast_nullable_to_non_nullable
as String?,supplementRegistrationExpiry: freezed == supplementRegistrationExpiry ? _self.supplementRegistrationExpiry : supplementRegistrationExpiry // ignore: cast_nullable_to_non_nullable
as String?,supplementClaimsReviewed: null == supplementClaimsReviewed ? _self.supplementClaimsReviewed : supplementClaimsReviewed // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PortalShopCertification {

 String get id; String? get shop;@JsonKey(name: 'shop_handle') String? get shopHandle;@JsonKey(name: 'shop_name') String? get shopName; String get status;@JsonKey(name: 'service_type') String get serviceType;@JsonKey(name: 'legal_name') String get legalName;@JsonKey(name: 'business_registration_number') String get businessRegistrationNumber; String get country; String get phone;@JsonKey(name: 'id_document_url') String get idDocumentUrl;@JsonKey(name: 'professional_cert_url') String get professionalCertUrl;@JsonKey(name: 'website_url') String get websiteUrl;@JsonKey(name: 'years_of_experience') int? get yearsOfExperience;@JsonKey(name: 'specializations') List<dynamic> get specializations;@JsonKey(name: 'bio_statement') String get bioStatement;@JsonKey(name: 'agreed_to_creator_policy') bool get agreedToCreatorPolicy;@JsonKey(name: 'submitted_by_username') String? get submittedByUsername;@JsonKey(name: 'reviewer_notes') String get reviewerNotes;@JsonKey(name: 'rejection_reason') String get rejectionReason;@JsonKey(name: 'reviewed_by_username') String? get reviewedByUsername;@JsonKey(name: 'reviewed_at') String? get reviewedAt;@JsonKey(name: 'created_at') String? get createdAt;
/// Create a copy of PortalShopCertification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PortalShopCertificationCopyWith<PortalShopCertification> get copyWith => _$PortalShopCertificationCopyWithImpl<PortalShopCertification>(this as PortalShopCertification, _$identity);

  /// Serializes this PortalShopCertification to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PortalShopCertification&&(identical(other.id, id) || other.id == id)&&(identical(other.shop, shop) || other.shop == shop)&&(identical(other.shopHandle, shopHandle) || other.shopHandle == shopHandle)&&(identical(other.shopName, shopName) || other.shopName == shopName)&&(identical(other.status, status) || other.status == status)&&(identical(other.serviceType, serviceType) || other.serviceType == serviceType)&&(identical(other.legalName, legalName) || other.legalName == legalName)&&(identical(other.businessRegistrationNumber, businessRegistrationNumber) || other.businessRegistrationNumber == businessRegistrationNumber)&&(identical(other.country, country) || other.country == country)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.idDocumentUrl, idDocumentUrl) || other.idDocumentUrl == idDocumentUrl)&&(identical(other.professionalCertUrl, professionalCertUrl) || other.professionalCertUrl == professionalCertUrl)&&(identical(other.websiteUrl, websiteUrl) || other.websiteUrl == websiteUrl)&&(identical(other.yearsOfExperience, yearsOfExperience) || other.yearsOfExperience == yearsOfExperience)&&const DeepCollectionEquality().equals(other.specializations, specializations)&&(identical(other.bioStatement, bioStatement) || other.bioStatement == bioStatement)&&(identical(other.agreedToCreatorPolicy, agreedToCreatorPolicy) || other.agreedToCreatorPolicy == agreedToCreatorPolicy)&&(identical(other.submittedByUsername, submittedByUsername) || other.submittedByUsername == submittedByUsername)&&(identical(other.reviewerNotes, reviewerNotes) || other.reviewerNotes == reviewerNotes)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.reviewedByUsername, reviewedByUsername) || other.reviewedByUsername == reviewedByUsername)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,shop,shopHandle,shopName,status,serviceType,legalName,businessRegistrationNumber,country,phone,idDocumentUrl,professionalCertUrl,websiteUrl,yearsOfExperience,const DeepCollectionEquality().hash(specializations),bioStatement,agreedToCreatorPolicy,submittedByUsername,reviewerNotes,rejectionReason,reviewedByUsername,reviewedAt,createdAt]);

@override
String toString() {
  return 'PortalShopCertification(id: $id, shop: $shop, shopHandle: $shopHandle, shopName: $shopName, status: $status, serviceType: $serviceType, legalName: $legalName, businessRegistrationNumber: $businessRegistrationNumber, country: $country, phone: $phone, idDocumentUrl: $idDocumentUrl, professionalCertUrl: $professionalCertUrl, websiteUrl: $websiteUrl, yearsOfExperience: $yearsOfExperience, specializations: $specializations, bioStatement: $bioStatement, agreedToCreatorPolicy: $agreedToCreatorPolicy, submittedByUsername: $submittedByUsername, reviewerNotes: $reviewerNotes, rejectionReason: $rejectionReason, reviewedByUsername: $reviewedByUsername, reviewedAt: $reviewedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PortalShopCertificationCopyWith<$Res>  {
  factory $PortalShopCertificationCopyWith(PortalShopCertification value, $Res Function(PortalShopCertification) _then) = _$PortalShopCertificationCopyWithImpl;
@useResult
$Res call({
 String id, String? shop,@JsonKey(name: 'shop_handle') String? shopHandle,@JsonKey(name: 'shop_name') String? shopName, String status,@JsonKey(name: 'service_type') String serviceType,@JsonKey(name: 'legal_name') String legalName,@JsonKey(name: 'business_registration_number') String businessRegistrationNumber, String country, String phone,@JsonKey(name: 'id_document_url') String idDocumentUrl,@JsonKey(name: 'professional_cert_url') String professionalCertUrl,@JsonKey(name: 'website_url') String websiteUrl,@JsonKey(name: 'years_of_experience') int? yearsOfExperience,@JsonKey(name: 'specializations') List<dynamic> specializations,@JsonKey(name: 'bio_statement') String bioStatement,@JsonKey(name: 'agreed_to_creator_policy') bool agreedToCreatorPolicy,@JsonKey(name: 'submitted_by_username') String? submittedByUsername,@JsonKey(name: 'reviewer_notes') String reviewerNotes,@JsonKey(name: 'rejection_reason') String rejectionReason,@JsonKey(name: 'reviewed_by_username') String? reviewedByUsername,@JsonKey(name: 'reviewed_at') String? reviewedAt,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class _$PortalShopCertificationCopyWithImpl<$Res>
    implements $PortalShopCertificationCopyWith<$Res> {
  _$PortalShopCertificationCopyWithImpl(this._self, this._then);

  final PortalShopCertification _self;
  final $Res Function(PortalShopCertification) _then;

/// Create a copy of PortalShopCertification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? shop = freezed,Object? shopHandle = freezed,Object? shopName = freezed,Object? status = null,Object? serviceType = null,Object? legalName = null,Object? businessRegistrationNumber = null,Object? country = null,Object? phone = null,Object? idDocumentUrl = null,Object? professionalCertUrl = null,Object? websiteUrl = null,Object? yearsOfExperience = freezed,Object? specializations = null,Object? bioStatement = null,Object? agreedToCreatorPolicy = null,Object? submittedByUsername = freezed,Object? reviewerNotes = null,Object? rejectionReason = null,Object? reviewedByUsername = freezed,Object? reviewedAt = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shop: freezed == shop ? _self.shop : shop // ignore: cast_nullable_to_non_nullable
as String?,shopHandle: freezed == shopHandle ? _self.shopHandle : shopHandle // ignore: cast_nullable_to_non_nullable
as String?,shopName: freezed == shopName ? _self.shopName : shopName // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,serviceType: null == serviceType ? _self.serviceType : serviceType // ignore: cast_nullable_to_non_nullable
as String,legalName: null == legalName ? _self.legalName : legalName // ignore: cast_nullable_to_non_nullable
as String,businessRegistrationNumber: null == businessRegistrationNumber ? _self.businessRegistrationNumber : businessRegistrationNumber // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,idDocumentUrl: null == idDocumentUrl ? _self.idDocumentUrl : idDocumentUrl // ignore: cast_nullable_to_non_nullable
as String,professionalCertUrl: null == professionalCertUrl ? _self.professionalCertUrl : professionalCertUrl // ignore: cast_nullable_to_non_nullable
as String,websiteUrl: null == websiteUrl ? _self.websiteUrl : websiteUrl // ignore: cast_nullable_to_non_nullable
as String,yearsOfExperience: freezed == yearsOfExperience ? _self.yearsOfExperience : yearsOfExperience // ignore: cast_nullable_to_non_nullable
as int?,specializations: null == specializations ? _self.specializations : specializations // ignore: cast_nullable_to_non_nullable
as List<dynamic>,bioStatement: null == bioStatement ? _self.bioStatement : bioStatement // ignore: cast_nullable_to_non_nullable
as String,agreedToCreatorPolicy: null == agreedToCreatorPolicy ? _self.agreedToCreatorPolicy : agreedToCreatorPolicy // ignore: cast_nullable_to_non_nullable
as bool,submittedByUsername: freezed == submittedByUsername ? _self.submittedByUsername : submittedByUsername // ignore: cast_nullable_to_non_nullable
as String?,reviewerNotes: null == reviewerNotes ? _self.reviewerNotes : reviewerNotes // ignore: cast_nullable_to_non_nullable
as String,rejectionReason: null == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String,reviewedByUsername: freezed == reviewedByUsername ? _self.reviewedByUsername : reviewedByUsername // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PortalShopCertification].
extension PortalShopCertificationPatterns on PortalShopCertification {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PortalShopCertification value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PortalShopCertification() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PortalShopCertification value)  $default,){
final _that = this;
switch (_that) {
case _PortalShopCertification():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PortalShopCertification value)?  $default,){
final _that = this;
switch (_that) {
case _PortalShopCertification() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? shop, @JsonKey(name: 'shop_handle')  String? shopHandle, @JsonKey(name: 'shop_name')  String? shopName,  String status, @JsonKey(name: 'service_type')  String serviceType, @JsonKey(name: 'legal_name')  String legalName, @JsonKey(name: 'business_registration_number')  String businessRegistrationNumber,  String country,  String phone, @JsonKey(name: 'id_document_url')  String idDocumentUrl, @JsonKey(name: 'professional_cert_url')  String professionalCertUrl, @JsonKey(name: 'website_url')  String websiteUrl, @JsonKey(name: 'years_of_experience')  int? yearsOfExperience, @JsonKey(name: 'specializations')  List<dynamic> specializations, @JsonKey(name: 'bio_statement')  String bioStatement, @JsonKey(name: 'agreed_to_creator_policy')  bool agreedToCreatorPolicy, @JsonKey(name: 'submitted_by_username')  String? submittedByUsername, @JsonKey(name: 'reviewer_notes')  String reviewerNotes, @JsonKey(name: 'rejection_reason')  String rejectionReason, @JsonKey(name: 'reviewed_by_username')  String? reviewedByUsername, @JsonKey(name: 'reviewed_at')  String? reviewedAt, @JsonKey(name: 'created_at')  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PortalShopCertification() when $default != null:
return $default(_that.id,_that.shop,_that.shopHandle,_that.shopName,_that.status,_that.serviceType,_that.legalName,_that.businessRegistrationNumber,_that.country,_that.phone,_that.idDocumentUrl,_that.professionalCertUrl,_that.websiteUrl,_that.yearsOfExperience,_that.specializations,_that.bioStatement,_that.agreedToCreatorPolicy,_that.submittedByUsername,_that.reviewerNotes,_that.rejectionReason,_that.reviewedByUsername,_that.reviewedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? shop, @JsonKey(name: 'shop_handle')  String? shopHandle, @JsonKey(name: 'shop_name')  String? shopName,  String status, @JsonKey(name: 'service_type')  String serviceType, @JsonKey(name: 'legal_name')  String legalName, @JsonKey(name: 'business_registration_number')  String businessRegistrationNumber,  String country,  String phone, @JsonKey(name: 'id_document_url')  String idDocumentUrl, @JsonKey(name: 'professional_cert_url')  String professionalCertUrl, @JsonKey(name: 'website_url')  String websiteUrl, @JsonKey(name: 'years_of_experience')  int? yearsOfExperience, @JsonKey(name: 'specializations')  List<dynamic> specializations, @JsonKey(name: 'bio_statement')  String bioStatement, @JsonKey(name: 'agreed_to_creator_policy')  bool agreedToCreatorPolicy, @JsonKey(name: 'submitted_by_username')  String? submittedByUsername, @JsonKey(name: 'reviewer_notes')  String reviewerNotes, @JsonKey(name: 'rejection_reason')  String rejectionReason, @JsonKey(name: 'reviewed_by_username')  String? reviewedByUsername, @JsonKey(name: 'reviewed_at')  String? reviewedAt, @JsonKey(name: 'created_at')  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _PortalShopCertification():
return $default(_that.id,_that.shop,_that.shopHandle,_that.shopName,_that.status,_that.serviceType,_that.legalName,_that.businessRegistrationNumber,_that.country,_that.phone,_that.idDocumentUrl,_that.professionalCertUrl,_that.websiteUrl,_that.yearsOfExperience,_that.specializations,_that.bioStatement,_that.agreedToCreatorPolicy,_that.submittedByUsername,_that.reviewerNotes,_that.rejectionReason,_that.reviewedByUsername,_that.reviewedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? shop, @JsonKey(name: 'shop_handle')  String? shopHandle, @JsonKey(name: 'shop_name')  String? shopName,  String status, @JsonKey(name: 'service_type')  String serviceType, @JsonKey(name: 'legal_name')  String legalName, @JsonKey(name: 'business_registration_number')  String businessRegistrationNumber,  String country,  String phone, @JsonKey(name: 'id_document_url')  String idDocumentUrl, @JsonKey(name: 'professional_cert_url')  String professionalCertUrl, @JsonKey(name: 'website_url')  String websiteUrl, @JsonKey(name: 'years_of_experience')  int? yearsOfExperience, @JsonKey(name: 'specializations')  List<dynamic> specializations, @JsonKey(name: 'bio_statement')  String bioStatement, @JsonKey(name: 'agreed_to_creator_policy')  bool agreedToCreatorPolicy, @JsonKey(name: 'submitted_by_username')  String? submittedByUsername, @JsonKey(name: 'reviewer_notes')  String reviewerNotes, @JsonKey(name: 'rejection_reason')  String rejectionReason, @JsonKey(name: 'reviewed_by_username')  String? reviewedByUsername, @JsonKey(name: 'reviewed_at')  String? reviewedAt, @JsonKey(name: 'created_at')  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _PortalShopCertification() when $default != null:
return $default(_that.id,_that.shop,_that.shopHandle,_that.shopName,_that.status,_that.serviceType,_that.legalName,_that.businessRegistrationNumber,_that.country,_that.phone,_that.idDocumentUrl,_that.professionalCertUrl,_that.websiteUrl,_that.yearsOfExperience,_that.specializations,_that.bioStatement,_that.agreedToCreatorPolicy,_that.submittedByUsername,_that.reviewerNotes,_that.rejectionReason,_that.reviewedByUsername,_that.reviewedAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PortalShopCertification implements PortalShopCertification {
  const _PortalShopCertification({required this.id, this.shop, @JsonKey(name: 'shop_handle') this.shopHandle, @JsonKey(name: 'shop_name') this.shopName, this.status = 'draft', @JsonKey(name: 'service_type') this.serviceType = '', @JsonKey(name: 'legal_name') this.legalName = '', @JsonKey(name: 'business_registration_number') this.businessRegistrationNumber = '', this.country = '', this.phone = '', @JsonKey(name: 'id_document_url') this.idDocumentUrl = '', @JsonKey(name: 'professional_cert_url') this.professionalCertUrl = '', @JsonKey(name: 'website_url') this.websiteUrl = '', @JsonKey(name: 'years_of_experience') this.yearsOfExperience, @JsonKey(name: 'specializations') final  List<dynamic> specializations = const <dynamic>[], @JsonKey(name: 'bio_statement') this.bioStatement = '', @JsonKey(name: 'agreed_to_creator_policy') this.agreedToCreatorPolicy = false, @JsonKey(name: 'submitted_by_username') this.submittedByUsername, @JsonKey(name: 'reviewer_notes') this.reviewerNotes = '', @JsonKey(name: 'rejection_reason') this.rejectionReason = '', @JsonKey(name: 'reviewed_by_username') this.reviewedByUsername, @JsonKey(name: 'reviewed_at') this.reviewedAt, @JsonKey(name: 'created_at') this.createdAt}): _specializations = specializations;
  factory _PortalShopCertification.fromJson(Map<String, dynamic> json) => _$PortalShopCertificationFromJson(json);

@override final  String id;
@override final  String? shop;
@override@JsonKey(name: 'shop_handle') final  String? shopHandle;
@override@JsonKey(name: 'shop_name') final  String? shopName;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'service_type') final  String serviceType;
@override@JsonKey(name: 'legal_name') final  String legalName;
@override@JsonKey(name: 'business_registration_number') final  String businessRegistrationNumber;
@override@JsonKey() final  String country;
@override@JsonKey() final  String phone;
@override@JsonKey(name: 'id_document_url') final  String idDocumentUrl;
@override@JsonKey(name: 'professional_cert_url') final  String professionalCertUrl;
@override@JsonKey(name: 'website_url') final  String websiteUrl;
@override@JsonKey(name: 'years_of_experience') final  int? yearsOfExperience;
 final  List<dynamic> _specializations;
@override@JsonKey(name: 'specializations') List<dynamic> get specializations {
  if (_specializations is EqualUnmodifiableListView) return _specializations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_specializations);
}

@override@JsonKey(name: 'bio_statement') final  String bioStatement;
@override@JsonKey(name: 'agreed_to_creator_policy') final  bool agreedToCreatorPolicy;
@override@JsonKey(name: 'submitted_by_username') final  String? submittedByUsername;
@override@JsonKey(name: 'reviewer_notes') final  String reviewerNotes;
@override@JsonKey(name: 'rejection_reason') final  String rejectionReason;
@override@JsonKey(name: 'reviewed_by_username') final  String? reviewedByUsername;
@override@JsonKey(name: 'reviewed_at') final  String? reviewedAt;
@override@JsonKey(name: 'created_at') final  String? createdAt;

/// Create a copy of PortalShopCertification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PortalShopCertificationCopyWith<_PortalShopCertification> get copyWith => __$PortalShopCertificationCopyWithImpl<_PortalShopCertification>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PortalShopCertificationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PortalShopCertification&&(identical(other.id, id) || other.id == id)&&(identical(other.shop, shop) || other.shop == shop)&&(identical(other.shopHandle, shopHandle) || other.shopHandle == shopHandle)&&(identical(other.shopName, shopName) || other.shopName == shopName)&&(identical(other.status, status) || other.status == status)&&(identical(other.serviceType, serviceType) || other.serviceType == serviceType)&&(identical(other.legalName, legalName) || other.legalName == legalName)&&(identical(other.businessRegistrationNumber, businessRegistrationNumber) || other.businessRegistrationNumber == businessRegistrationNumber)&&(identical(other.country, country) || other.country == country)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.idDocumentUrl, idDocumentUrl) || other.idDocumentUrl == idDocumentUrl)&&(identical(other.professionalCertUrl, professionalCertUrl) || other.professionalCertUrl == professionalCertUrl)&&(identical(other.websiteUrl, websiteUrl) || other.websiteUrl == websiteUrl)&&(identical(other.yearsOfExperience, yearsOfExperience) || other.yearsOfExperience == yearsOfExperience)&&const DeepCollectionEquality().equals(other._specializations, _specializations)&&(identical(other.bioStatement, bioStatement) || other.bioStatement == bioStatement)&&(identical(other.agreedToCreatorPolicy, agreedToCreatorPolicy) || other.agreedToCreatorPolicy == agreedToCreatorPolicy)&&(identical(other.submittedByUsername, submittedByUsername) || other.submittedByUsername == submittedByUsername)&&(identical(other.reviewerNotes, reviewerNotes) || other.reviewerNotes == reviewerNotes)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.reviewedByUsername, reviewedByUsername) || other.reviewedByUsername == reviewedByUsername)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,shop,shopHandle,shopName,status,serviceType,legalName,businessRegistrationNumber,country,phone,idDocumentUrl,professionalCertUrl,websiteUrl,yearsOfExperience,const DeepCollectionEquality().hash(_specializations),bioStatement,agreedToCreatorPolicy,submittedByUsername,reviewerNotes,rejectionReason,reviewedByUsername,reviewedAt,createdAt]);

@override
String toString() {
  return 'PortalShopCertification(id: $id, shop: $shop, shopHandle: $shopHandle, shopName: $shopName, status: $status, serviceType: $serviceType, legalName: $legalName, businessRegistrationNumber: $businessRegistrationNumber, country: $country, phone: $phone, idDocumentUrl: $idDocumentUrl, professionalCertUrl: $professionalCertUrl, websiteUrl: $websiteUrl, yearsOfExperience: $yearsOfExperience, specializations: $specializations, bioStatement: $bioStatement, agreedToCreatorPolicy: $agreedToCreatorPolicy, submittedByUsername: $submittedByUsername, reviewerNotes: $reviewerNotes, rejectionReason: $rejectionReason, reviewedByUsername: $reviewedByUsername, reviewedAt: $reviewedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PortalShopCertificationCopyWith<$Res> implements $PortalShopCertificationCopyWith<$Res> {
  factory _$PortalShopCertificationCopyWith(_PortalShopCertification value, $Res Function(_PortalShopCertification) _then) = __$PortalShopCertificationCopyWithImpl;
@override @useResult
$Res call({
 String id, String? shop,@JsonKey(name: 'shop_handle') String? shopHandle,@JsonKey(name: 'shop_name') String? shopName, String status,@JsonKey(name: 'service_type') String serviceType,@JsonKey(name: 'legal_name') String legalName,@JsonKey(name: 'business_registration_number') String businessRegistrationNumber, String country, String phone,@JsonKey(name: 'id_document_url') String idDocumentUrl,@JsonKey(name: 'professional_cert_url') String professionalCertUrl,@JsonKey(name: 'website_url') String websiteUrl,@JsonKey(name: 'years_of_experience') int? yearsOfExperience,@JsonKey(name: 'specializations') List<dynamic> specializations,@JsonKey(name: 'bio_statement') String bioStatement,@JsonKey(name: 'agreed_to_creator_policy') bool agreedToCreatorPolicy,@JsonKey(name: 'submitted_by_username') String? submittedByUsername,@JsonKey(name: 'reviewer_notes') String reviewerNotes,@JsonKey(name: 'rejection_reason') String rejectionReason,@JsonKey(name: 'reviewed_by_username') String? reviewedByUsername,@JsonKey(name: 'reviewed_at') String? reviewedAt,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class __$PortalShopCertificationCopyWithImpl<$Res>
    implements _$PortalShopCertificationCopyWith<$Res> {
  __$PortalShopCertificationCopyWithImpl(this._self, this._then);

  final _PortalShopCertification _self;
  final $Res Function(_PortalShopCertification) _then;

/// Create a copy of PortalShopCertification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? shop = freezed,Object? shopHandle = freezed,Object? shopName = freezed,Object? status = null,Object? serviceType = null,Object? legalName = null,Object? businessRegistrationNumber = null,Object? country = null,Object? phone = null,Object? idDocumentUrl = null,Object? professionalCertUrl = null,Object? websiteUrl = null,Object? yearsOfExperience = freezed,Object? specializations = null,Object? bioStatement = null,Object? agreedToCreatorPolicy = null,Object? submittedByUsername = freezed,Object? reviewerNotes = null,Object? rejectionReason = null,Object? reviewedByUsername = freezed,Object? reviewedAt = freezed,Object? createdAt = freezed,}) {
  return _then(_PortalShopCertification(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shop: freezed == shop ? _self.shop : shop // ignore: cast_nullable_to_non_nullable
as String?,shopHandle: freezed == shopHandle ? _self.shopHandle : shopHandle // ignore: cast_nullable_to_non_nullable
as String?,shopName: freezed == shopName ? _self.shopName : shopName // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,serviceType: null == serviceType ? _self.serviceType : serviceType // ignore: cast_nullable_to_non_nullable
as String,legalName: null == legalName ? _self.legalName : legalName // ignore: cast_nullable_to_non_nullable
as String,businessRegistrationNumber: null == businessRegistrationNumber ? _self.businessRegistrationNumber : businessRegistrationNumber // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,idDocumentUrl: null == idDocumentUrl ? _self.idDocumentUrl : idDocumentUrl // ignore: cast_nullable_to_non_nullable
as String,professionalCertUrl: null == professionalCertUrl ? _self.professionalCertUrl : professionalCertUrl // ignore: cast_nullable_to_non_nullable
as String,websiteUrl: null == websiteUrl ? _self.websiteUrl : websiteUrl // ignore: cast_nullable_to_non_nullable
as String,yearsOfExperience: freezed == yearsOfExperience ? _self.yearsOfExperience : yearsOfExperience // ignore: cast_nullable_to_non_nullable
as int?,specializations: null == specializations ? _self._specializations : specializations // ignore: cast_nullable_to_non_nullable
as List<dynamic>,bioStatement: null == bioStatement ? _self.bioStatement : bioStatement // ignore: cast_nullable_to_non_nullable
as String,agreedToCreatorPolicy: null == agreedToCreatorPolicy ? _self.agreedToCreatorPolicy : agreedToCreatorPolicy // ignore: cast_nullable_to_non_nullable
as bool,submittedByUsername: freezed == submittedByUsername ? _self.submittedByUsername : submittedByUsername // ignore: cast_nullable_to_non_nullable
as String?,reviewerNotes: null == reviewerNotes ? _self.reviewerNotes : reviewerNotes // ignore: cast_nullable_to_non_nullable
as String,rejectionReason: null == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String,reviewedByUsername: freezed == reviewedByUsername ? _self.reviewedByUsername : reviewedByUsername // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PortalOrderItem {

 String? get id;@JsonKey(name: 'item_type') String get itemType; String get title; int get quantity;@JsonKey(name: 'fulfillment_status') String get fulfillmentStatus;@JsonKey(name: 'creator_username') String? get creatorUsername;@JsonKey(name: 'creator_display_name') String? get creatorDisplayName;
/// Create a copy of PortalOrderItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PortalOrderItemCopyWith<PortalOrderItem> get copyWith => _$PortalOrderItemCopyWithImpl<PortalOrderItem>(this as PortalOrderItem, _$identity);

  /// Serializes this PortalOrderItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PortalOrderItem&&(identical(other.id, id) || other.id == id)&&(identical(other.itemType, itemType) || other.itemType == itemType)&&(identical(other.title, title) || other.title == title)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.fulfillmentStatus, fulfillmentStatus) || other.fulfillmentStatus == fulfillmentStatus)&&(identical(other.creatorUsername, creatorUsername) || other.creatorUsername == creatorUsername)&&(identical(other.creatorDisplayName, creatorDisplayName) || other.creatorDisplayName == creatorDisplayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,itemType,title,quantity,fulfillmentStatus,creatorUsername,creatorDisplayName);

@override
String toString() {
  return 'PortalOrderItem(id: $id, itemType: $itemType, title: $title, quantity: $quantity, fulfillmentStatus: $fulfillmentStatus, creatorUsername: $creatorUsername, creatorDisplayName: $creatorDisplayName)';
}


}

/// @nodoc
abstract mixin class $PortalOrderItemCopyWith<$Res>  {
  factory $PortalOrderItemCopyWith(PortalOrderItem value, $Res Function(PortalOrderItem) _then) = _$PortalOrderItemCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(name: 'item_type') String itemType, String title, int quantity,@JsonKey(name: 'fulfillment_status') String fulfillmentStatus,@JsonKey(name: 'creator_username') String? creatorUsername,@JsonKey(name: 'creator_display_name') String? creatorDisplayName
});




}
/// @nodoc
class _$PortalOrderItemCopyWithImpl<$Res>
    implements $PortalOrderItemCopyWith<$Res> {
  _$PortalOrderItemCopyWithImpl(this._self, this._then);

  final PortalOrderItem _self;
  final $Res Function(PortalOrderItem) _then;

/// Create a copy of PortalOrderItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? itemType = null,Object? title = null,Object? quantity = null,Object? fulfillmentStatus = null,Object? creatorUsername = freezed,Object? creatorDisplayName = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,itemType: null == itemType ? _self.itemType : itemType // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,fulfillmentStatus: null == fulfillmentStatus ? _self.fulfillmentStatus : fulfillmentStatus // ignore: cast_nullable_to_non_nullable
as String,creatorUsername: freezed == creatorUsername ? _self.creatorUsername : creatorUsername // ignore: cast_nullable_to_non_nullable
as String?,creatorDisplayName: freezed == creatorDisplayName ? _self.creatorDisplayName : creatorDisplayName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PortalOrderItem].
extension PortalOrderItemPatterns on PortalOrderItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PortalOrderItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PortalOrderItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PortalOrderItem value)  $default,){
final _that = this;
switch (_that) {
case _PortalOrderItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PortalOrderItem value)?  $default,){
final _that = this;
switch (_that) {
case _PortalOrderItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'item_type')  String itemType,  String title,  int quantity, @JsonKey(name: 'fulfillment_status')  String fulfillmentStatus, @JsonKey(name: 'creator_username')  String? creatorUsername, @JsonKey(name: 'creator_display_name')  String? creatorDisplayName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PortalOrderItem() when $default != null:
return $default(_that.id,_that.itemType,_that.title,_that.quantity,_that.fulfillmentStatus,_that.creatorUsername,_that.creatorDisplayName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'item_type')  String itemType,  String title,  int quantity, @JsonKey(name: 'fulfillment_status')  String fulfillmentStatus, @JsonKey(name: 'creator_username')  String? creatorUsername, @JsonKey(name: 'creator_display_name')  String? creatorDisplayName)  $default,) {final _that = this;
switch (_that) {
case _PortalOrderItem():
return $default(_that.id,_that.itemType,_that.title,_that.quantity,_that.fulfillmentStatus,_that.creatorUsername,_that.creatorDisplayName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(name: 'item_type')  String itemType,  String title,  int quantity, @JsonKey(name: 'fulfillment_status')  String fulfillmentStatus, @JsonKey(name: 'creator_username')  String? creatorUsername, @JsonKey(name: 'creator_display_name')  String? creatorDisplayName)?  $default,) {final _that = this;
switch (_that) {
case _PortalOrderItem() when $default != null:
return $default(_that.id,_that.itemType,_that.title,_that.quantity,_that.fulfillmentStatus,_that.creatorUsername,_that.creatorDisplayName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PortalOrderItem implements PortalOrderItem {
  const _PortalOrderItem({this.id, @JsonKey(name: 'item_type') this.itemType = '', this.title = '', this.quantity = 1, @JsonKey(name: 'fulfillment_status') this.fulfillmentStatus = '', @JsonKey(name: 'creator_username') this.creatorUsername, @JsonKey(name: 'creator_display_name') this.creatorDisplayName});
  factory _PortalOrderItem.fromJson(Map<String, dynamic> json) => _$PortalOrderItemFromJson(json);

@override final  String? id;
@override@JsonKey(name: 'item_type') final  String itemType;
@override@JsonKey() final  String title;
@override@JsonKey() final  int quantity;
@override@JsonKey(name: 'fulfillment_status') final  String fulfillmentStatus;
@override@JsonKey(name: 'creator_username') final  String? creatorUsername;
@override@JsonKey(name: 'creator_display_name') final  String? creatorDisplayName;

/// Create a copy of PortalOrderItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PortalOrderItemCopyWith<_PortalOrderItem> get copyWith => __$PortalOrderItemCopyWithImpl<_PortalOrderItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PortalOrderItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PortalOrderItem&&(identical(other.id, id) || other.id == id)&&(identical(other.itemType, itemType) || other.itemType == itemType)&&(identical(other.title, title) || other.title == title)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.fulfillmentStatus, fulfillmentStatus) || other.fulfillmentStatus == fulfillmentStatus)&&(identical(other.creatorUsername, creatorUsername) || other.creatorUsername == creatorUsername)&&(identical(other.creatorDisplayName, creatorDisplayName) || other.creatorDisplayName == creatorDisplayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,itemType,title,quantity,fulfillmentStatus,creatorUsername,creatorDisplayName);

@override
String toString() {
  return 'PortalOrderItem(id: $id, itemType: $itemType, title: $title, quantity: $quantity, fulfillmentStatus: $fulfillmentStatus, creatorUsername: $creatorUsername, creatorDisplayName: $creatorDisplayName)';
}


}

/// @nodoc
abstract mixin class _$PortalOrderItemCopyWith<$Res> implements $PortalOrderItemCopyWith<$Res> {
  factory _$PortalOrderItemCopyWith(_PortalOrderItem value, $Res Function(_PortalOrderItem) _then) = __$PortalOrderItemCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(name: 'item_type') String itemType, String title, int quantity,@JsonKey(name: 'fulfillment_status') String fulfillmentStatus,@JsonKey(name: 'creator_username') String? creatorUsername,@JsonKey(name: 'creator_display_name') String? creatorDisplayName
});




}
/// @nodoc
class __$PortalOrderItemCopyWithImpl<$Res>
    implements _$PortalOrderItemCopyWith<$Res> {
  __$PortalOrderItemCopyWithImpl(this._self, this._then);

  final _PortalOrderItem _self;
  final $Res Function(_PortalOrderItem) _then;

/// Create a copy of PortalOrderItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? itemType = null,Object? title = null,Object? quantity = null,Object? fulfillmentStatus = null,Object? creatorUsername = freezed,Object? creatorDisplayName = freezed,}) {
  return _then(_PortalOrderItem(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,itemType: null == itemType ? _self.itemType : itemType // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,fulfillmentStatus: null == fulfillmentStatus ? _self.fulfillmentStatus : fulfillmentStatus // ignore: cast_nullable_to_non_nullable
as String,creatorUsername: freezed == creatorUsername ? _self.creatorUsername : creatorUsername // ignore: cast_nullable_to_non_nullable
as String?,creatorDisplayName: freezed == creatorDisplayName ? _self.creatorDisplayName : creatorDisplayName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PortalOrderCase {

 String? get id; String? get order;@JsonKey(name: 'order_number') String? get orderNumber;@JsonKey(name: 'case_type') String get caseType; String get status;@JsonKey(name: 'reason') String get reason;@JsonKey(name: 'evidence') Map<String, dynamic> get evidence;@JsonKey(name: 'resolution') String get resolution;@JsonKey(name: 'resolved_at') String? get resolvedAt;@JsonKey(name: 'requester_username') String? get requesterUsername;@JsonKey(name: 'affects_ledger') bool get affectsLedger;@JsonKey(name: 'created_at') String? get createdAt;
/// Create a copy of PortalOrderCase
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PortalOrderCaseCopyWith<PortalOrderCase> get copyWith => _$PortalOrderCaseCopyWithImpl<PortalOrderCase>(this as PortalOrderCase, _$identity);

  /// Serializes this PortalOrderCase to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PortalOrderCase&&(identical(other.id, id) || other.id == id)&&(identical(other.order, order) || other.order == order)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.caseType, caseType) || other.caseType == caseType)&&(identical(other.status, status) || other.status == status)&&(identical(other.reason, reason) || other.reason == reason)&&const DeepCollectionEquality().equals(other.evidence, evidence)&&(identical(other.resolution, resolution) || other.resolution == resolution)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.requesterUsername, requesterUsername) || other.requesterUsername == requesterUsername)&&(identical(other.affectsLedger, affectsLedger) || other.affectsLedger == affectsLedger)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,order,orderNumber,caseType,status,reason,const DeepCollectionEquality().hash(evidence),resolution,resolvedAt,requesterUsername,affectsLedger,createdAt);

@override
String toString() {
  return 'PortalOrderCase(id: $id, order: $order, orderNumber: $orderNumber, caseType: $caseType, status: $status, reason: $reason, evidence: $evidence, resolution: $resolution, resolvedAt: $resolvedAt, requesterUsername: $requesterUsername, affectsLedger: $affectsLedger, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PortalOrderCaseCopyWith<$Res>  {
  factory $PortalOrderCaseCopyWith(PortalOrderCase value, $Res Function(PortalOrderCase) _then) = _$PortalOrderCaseCopyWithImpl;
@useResult
$Res call({
 String? id, String? order,@JsonKey(name: 'order_number') String? orderNumber,@JsonKey(name: 'case_type') String caseType, String status,@JsonKey(name: 'reason') String reason,@JsonKey(name: 'evidence') Map<String, dynamic> evidence,@JsonKey(name: 'resolution') String resolution,@JsonKey(name: 'resolved_at') String? resolvedAt,@JsonKey(name: 'requester_username') String? requesterUsername,@JsonKey(name: 'affects_ledger') bool affectsLedger,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class _$PortalOrderCaseCopyWithImpl<$Res>
    implements $PortalOrderCaseCopyWith<$Res> {
  _$PortalOrderCaseCopyWithImpl(this._self, this._then);

  final PortalOrderCase _self;
  final $Res Function(PortalOrderCase) _then;

/// Create a copy of PortalOrderCase
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? order = freezed,Object? orderNumber = freezed,Object? caseType = null,Object? status = null,Object? reason = null,Object? evidence = null,Object? resolution = null,Object? resolvedAt = freezed,Object? requesterUsername = freezed,Object? affectsLedger = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,order: freezed == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as String?,orderNumber: freezed == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String?,caseType: null == caseType ? _self.caseType : caseType // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,evidence: null == evidence ? _self.evidence : evidence // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,resolution: null == resolution ? _self.resolution : resolution // ignore: cast_nullable_to_non_nullable
as String,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as String?,requesterUsername: freezed == requesterUsername ? _self.requesterUsername : requesterUsername // ignore: cast_nullable_to_non_nullable
as String?,affectsLedger: null == affectsLedger ? _self.affectsLedger : affectsLedger // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PortalOrderCase].
extension PortalOrderCasePatterns on PortalOrderCase {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PortalOrderCase value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PortalOrderCase() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PortalOrderCase value)  $default,){
final _that = this;
switch (_that) {
case _PortalOrderCase():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PortalOrderCase value)?  $default,){
final _that = this;
switch (_that) {
case _PortalOrderCase() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? order, @JsonKey(name: 'order_number')  String? orderNumber, @JsonKey(name: 'case_type')  String caseType,  String status, @JsonKey(name: 'reason')  String reason, @JsonKey(name: 'evidence')  Map<String, dynamic> evidence, @JsonKey(name: 'resolution')  String resolution, @JsonKey(name: 'resolved_at')  String? resolvedAt, @JsonKey(name: 'requester_username')  String? requesterUsername, @JsonKey(name: 'affects_ledger')  bool affectsLedger, @JsonKey(name: 'created_at')  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PortalOrderCase() when $default != null:
return $default(_that.id,_that.order,_that.orderNumber,_that.caseType,_that.status,_that.reason,_that.evidence,_that.resolution,_that.resolvedAt,_that.requesterUsername,_that.affectsLedger,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? order, @JsonKey(name: 'order_number')  String? orderNumber, @JsonKey(name: 'case_type')  String caseType,  String status, @JsonKey(name: 'reason')  String reason, @JsonKey(name: 'evidence')  Map<String, dynamic> evidence, @JsonKey(name: 'resolution')  String resolution, @JsonKey(name: 'resolved_at')  String? resolvedAt, @JsonKey(name: 'requester_username')  String? requesterUsername, @JsonKey(name: 'affects_ledger')  bool affectsLedger, @JsonKey(name: 'created_at')  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _PortalOrderCase():
return $default(_that.id,_that.order,_that.orderNumber,_that.caseType,_that.status,_that.reason,_that.evidence,_that.resolution,_that.resolvedAt,_that.requesterUsername,_that.affectsLedger,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? order, @JsonKey(name: 'order_number')  String? orderNumber, @JsonKey(name: 'case_type')  String caseType,  String status, @JsonKey(name: 'reason')  String reason, @JsonKey(name: 'evidence')  Map<String, dynamic> evidence, @JsonKey(name: 'resolution')  String resolution, @JsonKey(name: 'resolved_at')  String? resolvedAt, @JsonKey(name: 'requester_username')  String? requesterUsername, @JsonKey(name: 'affects_ledger')  bool affectsLedger, @JsonKey(name: 'created_at')  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _PortalOrderCase() when $default != null:
return $default(_that.id,_that.order,_that.orderNumber,_that.caseType,_that.status,_that.reason,_that.evidence,_that.resolution,_that.resolvedAt,_that.requesterUsername,_that.affectsLedger,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PortalOrderCase implements PortalOrderCase {
  const _PortalOrderCase({this.id, this.order, @JsonKey(name: 'order_number') this.orderNumber, @JsonKey(name: 'case_type') this.caseType = '', this.status = 'open', @JsonKey(name: 'reason') this.reason = '', @JsonKey(name: 'evidence') final  Map<String, dynamic> evidence = const <String, dynamic>{}, @JsonKey(name: 'resolution') this.resolution = '', @JsonKey(name: 'resolved_at') this.resolvedAt, @JsonKey(name: 'requester_username') this.requesterUsername, @JsonKey(name: 'affects_ledger') this.affectsLedger = false, @JsonKey(name: 'created_at') this.createdAt}): _evidence = evidence;
  factory _PortalOrderCase.fromJson(Map<String, dynamic> json) => _$PortalOrderCaseFromJson(json);

@override final  String? id;
@override final  String? order;
@override@JsonKey(name: 'order_number') final  String? orderNumber;
@override@JsonKey(name: 'case_type') final  String caseType;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'reason') final  String reason;
 final  Map<String, dynamic> _evidence;
@override@JsonKey(name: 'evidence') Map<String, dynamic> get evidence {
  if (_evidence is EqualUnmodifiableMapView) return _evidence;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_evidence);
}

@override@JsonKey(name: 'resolution') final  String resolution;
@override@JsonKey(name: 'resolved_at') final  String? resolvedAt;
@override@JsonKey(name: 'requester_username') final  String? requesterUsername;
@override@JsonKey(name: 'affects_ledger') final  bool affectsLedger;
@override@JsonKey(name: 'created_at') final  String? createdAt;

/// Create a copy of PortalOrderCase
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PortalOrderCaseCopyWith<_PortalOrderCase> get copyWith => __$PortalOrderCaseCopyWithImpl<_PortalOrderCase>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PortalOrderCaseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PortalOrderCase&&(identical(other.id, id) || other.id == id)&&(identical(other.order, order) || other.order == order)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.caseType, caseType) || other.caseType == caseType)&&(identical(other.status, status) || other.status == status)&&(identical(other.reason, reason) || other.reason == reason)&&const DeepCollectionEquality().equals(other._evidence, _evidence)&&(identical(other.resolution, resolution) || other.resolution == resolution)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.requesterUsername, requesterUsername) || other.requesterUsername == requesterUsername)&&(identical(other.affectsLedger, affectsLedger) || other.affectsLedger == affectsLedger)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,order,orderNumber,caseType,status,reason,const DeepCollectionEquality().hash(_evidence),resolution,resolvedAt,requesterUsername,affectsLedger,createdAt);

@override
String toString() {
  return 'PortalOrderCase(id: $id, order: $order, orderNumber: $orderNumber, caseType: $caseType, status: $status, reason: $reason, evidence: $evidence, resolution: $resolution, resolvedAt: $resolvedAt, requesterUsername: $requesterUsername, affectsLedger: $affectsLedger, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PortalOrderCaseCopyWith<$Res> implements $PortalOrderCaseCopyWith<$Res> {
  factory _$PortalOrderCaseCopyWith(_PortalOrderCase value, $Res Function(_PortalOrderCase) _then) = __$PortalOrderCaseCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? order,@JsonKey(name: 'order_number') String? orderNumber,@JsonKey(name: 'case_type') String caseType, String status,@JsonKey(name: 'reason') String reason,@JsonKey(name: 'evidence') Map<String, dynamic> evidence,@JsonKey(name: 'resolution') String resolution,@JsonKey(name: 'resolved_at') String? resolvedAt,@JsonKey(name: 'requester_username') String? requesterUsername,@JsonKey(name: 'affects_ledger') bool affectsLedger,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class __$PortalOrderCaseCopyWithImpl<$Res>
    implements _$PortalOrderCaseCopyWith<$Res> {
  __$PortalOrderCaseCopyWithImpl(this._self, this._then);

  final _PortalOrderCase _self;
  final $Res Function(_PortalOrderCase) _then;

/// Create a copy of PortalOrderCase
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? order = freezed,Object? orderNumber = freezed,Object? caseType = null,Object? status = null,Object? reason = null,Object? evidence = null,Object? resolution = null,Object? resolvedAt = freezed,Object? requesterUsername = freezed,Object? affectsLedger = null,Object? createdAt = freezed,}) {
  return _then(_PortalOrderCase(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,order: freezed == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as String?,orderNumber: freezed == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String?,caseType: null == caseType ? _self.caseType : caseType // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,evidence: null == evidence ? _self._evidence : evidence // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,resolution: null == resolution ? _self.resolution : resolution // ignore: cast_nullable_to_non_nullable
as String,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as String?,requesterUsername: freezed == requesterUsername ? _self.requesterUsername : requesterUsername // ignore: cast_nullable_to_non_nullable
as String?,affectsLedger: null == affectsLedger ? _self.affectsLedger : affectsLedger // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PortalOrder {

 String get id;@JsonKey(name: 'order_number') String get orderNumber; String get status;@JsonKey(name: 'status_label') String get statusLabel;/// Server-computed from the flat `ORDER_FORWARD_STATES` map, which the
/// `/portal/orders/<id>/status/` PATCH then enforces. The seller-facing
/// endpoint is the fulfillment-aware one, so this list can be a superset.
@JsonKey(name: 'allowed_next_statuses') List<String> get allowedNextStatuses;@JsonKey(name: 'fulfillment_type') String get fulfillmentType;@JsonKey(name: 'payment_method') String? get paymentMethod;@JsonKey(name: 'payment_status') String get paymentStatus;@JsonKey(name: 'payment_reference') String get paymentReference;@JsonKey(name: 'payment_provider') String get paymentProvider;@JsonKey(name: 'buyer_username') String? get buyerUsername;@JsonKey(name: 'buyer_display_name') String? get buyerDisplayName;@JsonKey(name: 'buyer_email') String? get buyerEmail;@JsonKey(name: 'delivery_address') Map<String, dynamic> get deliveryAddress;@JsonKey(name: 'pickup_details') Map<String, dynamic> get pickupDetails;@JsonKey(name: 'pickup_station') String? get pickupStation;@JsonKey(name: 'delivery_personnel') String? get deliveryPersonnel; List<PortalOrderItem> get items;@JsonKey(name: 'items_total_artifacts') Map<String, int> get itemsTotalArtifacts;@JsonKey(name: 'discount_artifacts') Map<String, int> get discountArtifacts;@JsonKey(name: 'total_artifacts') Map<String, int> get totalArtifacts;@JsonKey(name: 'spent_usd', fromJson: _optDoubleOrZero) double get spentUsd;@JsonKey(name: 'status_history') List<Map<String, dynamic>> get statusHistory; List<PortalOrderCase> get cases;@JsonKey(name: 'paid_at') String? get paidAt;@JsonKey(name: 'created_at') String? get createdAt;@JsonKey(name: 'updated_at') String? get updatedAt;
/// Create a copy of PortalOrder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PortalOrderCopyWith<PortalOrder> get copyWith => _$PortalOrderCopyWithImpl<PortalOrder>(this as PortalOrder, _$identity);

  /// Serializes this PortalOrder to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PortalOrder&&(identical(other.id, id) || other.id == id)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusLabel, statusLabel) || other.statusLabel == statusLabel)&&const DeepCollectionEquality().equals(other.allowedNextStatuses, allowedNextStatuses)&&(identical(other.fulfillmentType, fulfillmentType) || other.fulfillmentType == fulfillmentType)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.paymentReference, paymentReference) || other.paymentReference == paymentReference)&&(identical(other.paymentProvider, paymentProvider) || other.paymentProvider == paymentProvider)&&(identical(other.buyerUsername, buyerUsername) || other.buyerUsername == buyerUsername)&&(identical(other.buyerDisplayName, buyerDisplayName) || other.buyerDisplayName == buyerDisplayName)&&(identical(other.buyerEmail, buyerEmail) || other.buyerEmail == buyerEmail)&&const DeepCollectionEquality().equals(other.deliveryAddress, deliveryAddress)&&const DeepCollectionEquality().equals(other.pickupDetails, pickupDetails)&&(identical(other.pickupStation, pickupStation) || other.pickupStation == pickupStation)&&(identical(other.deliveryPersonnel, deliveryPersonnel) || other.deliveryPersonnel == deliveryPersonnel)&&const DeepCollectionEquality().equals(other.items, items)&&const DeepCollectionEquality().equals(other.itemsTotalArtifacts, itemsTotalArtifacts)&&const DeepCollectionEquality().equals(other.discountArtifacts, discountArtifacts)&&const DeepCollectionEquality().equals(other.totalArtifacts, totalArtifacts)&&(identical(other.spentUsd, spentUsd) || other.spentUsd == spentUsd)&&const DeepCollectionEquality().equals(other.statusHistory, statusHistory)&&const DeepCollectionEquality().equals(other.cases, cases)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,orderNumber,status,statusLabel,const DeepCollectionEquality().hash(allowedNextStatuses),fulfillmentType,paymentMethod,paymentStatus,paymentReference,paymentProvider,buyerUsername,buyerDisplayName,buyerEmail,const DeepCollectionEquality().hash(deliveryAddress),const DeepCollectionEquality().hash(pickupDetails),pickupStation,deliveryPersonnel,const DeepCollectionEquality().hash(items),const DeepCollectionEquality().hash(itemsTotalArtifacts),const DeepCollectionEquality().hash(discountArtifacts),const DeepCollectionEquality().hash(totalArtifacts),spentUsd,const DeepCollectionEquality().hash(statusHistory),const DeepCollectionEquality().hash(cases),paidAt,createdAt,updatedAt]);

@override
String toString() {
  return 'PortalOrder(id: $id, orderNumber: $orderNumber, status: $status, statusLabel: $statusLabel, allowedNextStatuses: $allowedNextStatuses, fulfillmentType: $fulfillmentType, paymentMethod: $paymentMethod, paymentStatus: $paymentStatus, paymentReference: $paymentReference, paymentProvider: $paymentProvider, buyerUsername: $buyerUsername, buyerDisplayName: $buyerDisplayName, buyerEmail: $buyerEmail, deliveryAddress: $deliveryAddress, pickupDetails: $pickupDetails, pickupStation: $pickupStation, deliveryPersonnel: $deliveryPersonnel, items: $items, itemsTotalArtifacts: $itemsTotalArtifacts, discountArtifacts: $discountArtifacts, totalArtifacts: $totalArtifacts, spentUsd: $spentUsd, statusHistory: $statusHistory, cases: $cases, paidAt: $paidAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PortalOrderCopyWith<$Res>  {
  factory $PortalOrderCopyWith(PortalOrder value, $Res Function(PortalOrder) _then) = _$PortalOrderCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'order_number') String orderNumber, String status,@JsonKey(name: 'status_label') String statusLabel,@JsonKey(name: 'allowed_next_statuses') List<String> allowedNextStatuses,@JsonKey(name: 'fulfillment_type') String fulfillmentType,@JsonKey(name: 'payment_method') String? paymentMethod,@JsonKey(name: 'payment_status') String paymentStatus,@JsonKey(name: 'payment_reference') String paymentReference,@JsonKey(name: 'payment_provider') String paymentProvider,@JsonKey(name: 'buyer_username') String? buyerUsername,@JsonKey(name: 'buyer_display_name') String? buyerDisplayName,@JsonKey(name: 'buyer_email') String? buyerEmail,@JsonKey(name: 'delivery_address') Map<String, dynamic> deliveryAddress,@JsonKey(name: 'pickup_details') Map<String, dynamic> pickupDetails,@JsonKey(name: 'pickup_station') String? pickupStation,@JsonKey(name: 'delivery_personnel') String? deliveryPersonnel, List<PortalOrderItem> items,@JsonKey(name: 'items_total_artifacts') Map<String, int> itemsTotalArtifacts,@JsonKey(name: 'discount_artifacts') Map<String, int> discountArtifacts,@JsonKey(name: 'total_artifacts') Map<String, int> totalArtifacts,@JsonKey(name: 'spent_usd', fromJson: _optDoubleOrZero) double spentUsd,@JsonKey(name: 'status_history') List<Map<String, dynamic>> statusHistory, List<PortalOrderCase> cases,@JsonKey(name: 'paid_at') String? paidAt,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
});




}
/// @nodoc
class _$PortalOrderCopyWithImpl<$Res>
    implements $PortalOrderCopyWith<$Res> {
  _$PortalOrderCopyWithImpl(this._self, this._then);

  final PortalOrder _self;
  final $Res Function(PortalOrder) _then;

/// Create a copy of PortalOrder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orderNumber = null,Object? status = null,Object? statusLabel = null,Object? allowedNextStatuses = null,Object? fulfillmentType = null,Object? paymentMethod = freezed,Object? paymentStatus = null,Object? paymentReference = null,Object? paymentProvider = null,Object? buyerUsername = freezed,Object? buyerDisplayName = freezed,Object? buyerEmail = freezed,Object? deliveryAddress = null,Object? pickupDetails = null,Object? pickupStation = freezed,Object? deliveryPersonnel = freezed,Object? items = null,Object? itemsTotalArtifacts = null,Object? discountArtifacts = null,Object? totalArtifacts = null,Object? spentUsd = null,Object? statusHistory = null,Object? cases = null,Object? paidAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,statusLabel: null == statusLabel ? _self.statusLabel : statusLabel // ignore: cast_nullable_to_non_nullable
as String,allowedNextStatuses: null == allowedNextStatuses ? _self.allowedNextStatuses : allowedNextStatuses // ignore: cast_nullable_to_non_nullable
as List<String>,fulfillmentType: null == fulfillmentType ? _self.fulfillmentType : fulfillmentType // ignore: cast_nullable_to_non_nullable
as String,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String?,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as String,paymentReference: null == paymentReference ? _self.paymentReference : paymentReference // ignore: cast_nullable_to_non_nullable
as String,paymentProvider: null == paymentProvider ? _self.paymentProvider : paymentProvider // ignore: cast_nullable_to_non_nullable
as String,buyerUsername: freezed == buyerUsername ? _self.buyerUsername : buyerUsername // ignore: cast_nullable_to_non_nullable
as String?,buyerDisplayName: freezed == buyerDisplayName ? _self.buyerDisplayName : buyerDisplayName // ignore: cast_nullable_to_non_nullable
as String?,buyerEmail: freezed == buyerEmail ? _self.buyerEmail : buyerEmail // ignore: cast_nullable_to_non_nullable
as String?,deliveryAddress: null == deliveryAddress ? _self.deliveryAddress : deliveryAddress // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,pickupDetails: null == pickupDetails ? _self.pickupDetails : pickupDetails // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,pickupStation: freezed == pickupStation ? _self.pickupStation : pickupStation // ignore: cast_nullable_to_non_nullable
as String?,deliveryPersonnel: freezed == deliveryPersonnel ? _self.deliveryPersonnel : deliveryPersonnel // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<PortalOrderItem>,itemsTotalArtifacts: null == itemsTotalArtifacts ? _self.itemsTotalArtifacts : itemsTotalArtifacts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,discountArtifacts: null == discountArtifacts ? _self.discountArtifacts : discountArtifacts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,totalArtifacts: null == totalArtifacts ? _self.totalArtifacts : totalArtifacts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,spentUsd: null == spentUsd ? _self.spentUsd : spentUsd // ignore: cast_nullable_to_non_nullable
as double,statusHistory: null == statusHistory ? _self.statusHistory : statusHistory // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,cases: null == cases ? _self.cases : cases // ignore: cast_nullable_to_non_nullable
as List<PortalOrderCase>,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PortalOrder].
extension PortalOrderPatterns on PortalOrder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PortalOrder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PortalOrder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PortalOrder value)  $default,){
final _that = this;
switch (_that) {
case _PortalOrder():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PortalOrder value)?  $default,){
final _that = this;
switch (_that) {
case _PortalOrder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'order_number')  String orderNumber,  String status, @JsonKey(name: 'status_label')  String statusLabel, @JsonKey(name: 'allowed_next_statuses')  List<String> allowedNextStatuses, @JsonKey(name: 'fulfillment_type')  String fulfillmentType, @JsonKey(name: 'payment_method')  String? paymentMethod, @JsonKey(name: 'payment_status')  String paymentStatus, @JsonKey(name: 'payment_reference')  String paymentReference, @JsonKey(name: 'payment_provider')  String paymentProvider, @JsonKey(name: 'buyer_username')  String? buyerUsername, @JsonKey(name: 'buyer_display_name')  String? buyerDisplayName, @JsonKey(name: 'buyer_email')  String? buyerEmail, @JsonKey(name: 'delivery_address')  Map<String, dynamic> deliveryAddress, @JsonKey(name: 'pickup_details')  Map<String, dynamic> pickupDetails, @JsonKey(name: 'pickup_station')  String? pickupStation, @JsonKey(name: 'delivery_personnel')  String? deliveryPersonnel,  List<PortalOrderItem> items, @JsonKey(name: 'items_total_artifacts')  Map<String, int> itemsTotalArtifacts, @JsonKey(name: 'discount_artifacts')  Map<String, int> discountArtifacts, @JsonKey(name: 'total_artifacts')  Map<String, int> totalArtifacts, @JsonKey(name: 'spent_usd', fromJson: _optDoubleOrZero)  double spentUsd, @JsonKey(name: 'status_history')  List<Map<String, dynamic>> statusHistory,  List<PortalOrderCase> cases, @JsonKey(name: 'paid_at')  String? paidAt, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PortalOrder() when $default != null:
return $default(_that.id,_that.orderNumber,_that.status,_that.statusLabel,_that.allowedNextStatuses,_that.fulfillmentType,_that.paymentMethod,_that.paymentStatus,_that.paymentReference,_that.paymentProvider,_that.buyerUsername,_that.buyerDisplayName,_that.buyerEmail,_that.deliveryAddress,_that.pickupDetails,_that.pickupStation,_that.deliveryPersonnel,_that.items,_that.itemsTotalArtifacts,_that.discountArtifacts,_that.totalArtifacts,_that.spentUsd,_that.statusHistory,_that.cases,_that.paidAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'order_number')  String orderNumber,  String status, @JsonKey(name: 'status_label')  String statusLabel, @JsonKey(name: 'allowed_next_statuses')  List<String> allowedNextStatuses, @JsonKey(name: 'fulfillment_type')  String fulfillmentType, @JsonKey(name: 'payment_method')  String? paymentMethod, @JsonKey(name: 'payment_status')  String paymentStatus, @JsonKey(name: 'payment_reference')  String paymentReference, @JsonKey(name: 'payment_provider')  String paymentProvider, @JsonKey(name: 'buyer_username')  String? buyerUsername, @JsonKey(name: 'buyer_display_name')  String? buyerDisplayName, @JsonKey(name: 'buyer_email')  String? buyerEmail, @JsonKey(name: 'delivery_address')  Map<String, dynamic> deliveryAddress, @JsonKey(name: 'pickup_details')  Map<String, dynamic> pickupDetails, @JsonKey(name: 'pickup_station')  String? pickupStation, @JsonKey(name: 'delivery_personnel')  String? deliveryPersonnel,  List<PortalOrderItem> items, @JsonKey(name: 'items_total_artifacts')  Map<String, int> itemsTotalArtifacts, @JsonKey(name: 'discount_artifacts')  Map<String, int> discountArtifacts, @JsonKey(name: 'total_artifacts')  Map<String, int> totalArtifacts, @JsonKey(name: 'spent_usd', fromJson: _optDoubleOrZero)  double spentUsd, @JsonKey(name: 'status_history')  List<Map<String, dynamic>> statusHistory,  List<PortalOrderCase> cases, @JsonKey(name: 'paid_at')  String? paidAt, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PortalOrder():
return $default(_that.id,_that.orderNumber,_that.status,_that.statusLabel,_that.allowedNextStatuses,_that.fulfillmentType,_that.paymentMethod,_that.paymentStatus,_that.paymentReference,_that.paymentProvider,_that.buyerUsername,_that.buyerDisplayName,_that.buyerEmail,_that.deliveryAddress,_that.pickupDetails,_that.pickupStation,_that.deliveryPersonnel,_that.items,_that.itemsTotalArtifacts,_that.discountArtifacts,_that.totalArtifacts,_that.spentUsd,_that.statusHistory,_that.cases,_that.paidAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'order_number')  String orderNumber,  String status, @JsonKey(name: 'status_label')  String statusLabel, @JsonKey(name: 'allowed_next_statuses')  List<String> allowedNextStatuses, @JsonKey(name: 'fulfillment_type')  String fulfillmentType, @JsonKey(name: 'payment_method')  String? paymentMethod, @JsonKey(name: 'payment_status')  String paymentStatus, @JsonKey(name: 'payment_reference')  String paymentReference, @JsonKey(name: 'payment_provider')  String paymentProvider, @JsonKey(name: 'buyer_username')  String? buyerUsername, @JsonKey(name: 'buyer_display_name')  String? buyerDisplayName, @JsonKey(name: 'buyer_email')  String? buyerEmail, @JsonKey(name: 'delivery_address')  Map<String, dynamic> deliveryAddress, @JsonKey(name: 'pickup_details')  Map<String, dynamic> pickupDetails, @JsonKey(name: 'pickup_station')  String? pickupStation, @JsonKey(name: 'delivery_personnel')  String? deliveryPersonnel,  List<PortalOrderItem> items, @JsonKey(name: 'items_total_artifacts')  Map<String, int> itemsTotalArtifacts, @JsonKey(name: 'discount_artifacts')  Map<String, int> discountArtifacts, @JsonKey(name: 'total_artifacts')  Map<String, int> totalArtifacts, @JsonKey(name: 'spent_usd', fromJson: _optDoubleOrZero)  double spentUsd, @JsonKey(name: 'status_history')  List<Map<String, dynamic>> statusHistory,  List<PortalOrderCase> cases, @JsonKey(name: 'paid_at')  String? paidAt, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PortalOrder() when $default != null:
return $default(_that.id,_that.orderNumber,_that.status,_that.statusLabel,_that.allowedNextStatuses,_that.fulfillmentType,_that.paymentMethod,_that.paymentStatus,_that.paymentReference,_that.paymentProvider,_that.buyerUsername,_that.buyerDisplayName,_that.buyerEmail,_that.deliveryAddress,_that.pickupDetails,_that.pickupStation,_that.deliveryPersonnel,_that.items,_that.itemsTotalArtifacts,_that.discountArtifacts,_that.totalArtifacts,_that.spentUsd,_that.statusHistory,_that.cases,_that.paidAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PortalOrder implements PortalOrder {
  const _PortalOrder({required this.id, @JsonKey(name: 'order_number') this.orderNumber = '', this.status = '', @JsonKey(name: 'status_label') this.statusLabel = '', @JsonKey(name: 'allowed_next_statuses') final  List<String> allowedNextStatuses = const <String>[], @JsonKey(name: 'fulfillment_type') this.fulfillmentType = 'digital', @JsonKey(name: 'payment_method') this.paymentMethod, @JsonKey(name: 'payment_status') this.paymentStatus = 'unpaid', @JsonKey(name: 'payment_reference') this.paymentReference = '', @JsonKey(name: 'payment_provider') this.paymentProvider = '', @JsonKey(name: 'buyer_username') this.buyerUsername, @JsonKey(name: 'buyer_display_name') this.buyerDisplayName, @JsonKey(name: 'buyer_email') this.buyerEmail, @JsonKey(name: 'delivery_address') final  Map<String, dynamic> deliveryAddress = const <String, dynamic>{}, @JsonKey(name: 'pickup_details') final  Map<String, dynamic> pickupDetails = const <String, dynamic>{}, @JsonKey(name: 'pickup_station') this.pickupStation, @JsonKey(name: 'delivery_personnel') this.deliveryPersonnel, final  List<PortalOrderItem> items = const <PortalOrderItem>[], @JsonKey(name: 'items_total_artifacts') final  Map<String, int> itemsTotalArtifacts = const <String, int>{}, @JsonKey(name: 'discount_artifacts') final  Map<String, int> discountArtifacts = const <String, int>{}, @JsonKey(name: 'total_artifacts') final  Map<String, int> totalArtifacts = const <String, int>{}, @JsonKey(name: 'spent_usd', fromJson: _optDoubleOrZero) this.spentUsd = 0.0, @JsonKey(name: 'status_history') final  List<Map<String, dynamic>> statusHistory = const <Map<String, dynamic>>[], final  List<PortalOrderCase> cases = const <PortalOrderCase>[], @JsonKey(name: 'paid_at') this.paidAt, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt}): _allowedNextStatuses = allowedNextStatuses,_deliveryAddress = deliveryAddress,_pickupDetails = pickupDetails,_items = items,_itemsTotalArtifacts = itemsTotalArtifacts,_discountArtifacts = discountArtifacts,_totalArtifacts = totalArtifacts,_statusHistory = statusHistory,_cases = cases;
  factory _PortalOrder.fromJson(Map<String, dynamic> json) => _$PortalOrderFromJson(json);

@override final  String id;
@override@JsonKey(name: 'order_number') final  String orderNumber;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'status_label') final  String statusLabel;
/// Server-computed from the flat `ORDER_FORWARD_STATES` map, which the
/// `/portal/orders/<id>/status/` PATCH then enforces. The seller-facing
/// endpoint is the fulfillment-aware one, so this list can be a superset.
 final  List<String> _allowedNextStatuses;
/// Server-computed from the flat `ORDER_FORWARD_STATES` map, which the
/// `/portal/orders/<id>/status/` PATCH then enforces. The seller-facing
/// endpoint is the fulfillment-aware one, so this list can be a superset.
@override@JsonKey(name: 'allowed_next_statuses') List<String> get allowedNextStatuses {
  if (_allowedNextStatuses is EqualUnmodifiableListView) return _allowedNextStatuses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allowedNextStatuses);
}

@override@JsonKey(name: 'fulfillment_type') final  String fulfillmentType;
@override@JsonKey(name: 'payment_method') final  String? paymentMethod;
@override@JsonKey(name: 'payment_status') final  String paymentStatus;
@override@JsonKey(name: 'payment_reference') final  String paymentReference;
@override@JsonKey(name: 'payment_provider') final  String paymentProvider;
@override@JsonKey(name: 'buyer_username') final  String? buyerUsername;
@override@JsonKey(name: 'buyer_display_name') final  String? buyerDisplayName;
@override@JsonKey(name: 'buyer_email') final  String? buyerEmail;
 final  Map<String, dynamic> _deliveryAddress;
@override@JsonKey(name: 'delivery_address') Map<String, dynamic> get deliveryAddress {
  if (_deliveryAddress is EqualUnmodifiableMapView) return _deliveryAddress;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_deliveryAddress);
}

 final  Map<String, dynamic> _pickupDetails;
@override@JsonKey(name: 'pickup_details') Map<String, dynamic> get pickupDetails {
  if (_pickupDetails is EqualUnmodifiableMapView) return _pickupDetails;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_pickupDetails);
}

@override@JsonKey(name: 'pickup_station') final  String? pickupStation;
@override@JsonKey(name: 'delivery_personnel') final  String? deliveryPersonnel;
 final  List<PortalOrderItem> _items;
@override@JsonKey() List<PortalOrderItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

 final  Map<String, int> _itemsTotalArtifacts;
@override@JsonKey(name: 'items_total_artifacts') Map<String, int> get itemsTotalArtifacts {
  if (_itemsTotalArtifacts is EqualUnmodifiableMapView) return _itemsTotalArtifacts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_itemsTotalArtifacts);
}

 final  Map<String, int> _discountArtifacts;
@override@JsonKey(name: 'discount_artifacts') Map<String, int> get discountArtifacts {
  if (_discountArtifacts is EqualUnmodifiableMapView) return _discountArtifacts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_discountArtifacts);
}

 final  Map<String, int> _totalArtifacts;
@override@JsonKey(name: 'total_artifacts') Map<String, int> get totalArtifacts {
  if (_totalArtifacts is EqualUnmodifiableMapView) return _totalArtifacts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_totalArtifacts);
}

@override@JsonKey(name: 'spent_usd', fromJson: _optDoubleOrZero) final  double spentUsd;
 final  List<Map<String, dynamic>> _statusHistory;
@override@JsonKey(name: 'status_history') List<Map<String, dynamic>> get statusHistory {
  if (_statusHistory is EqualUnmodifiableListView) return _statusHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_statusHistory);
}

 final  List<PortalOrderCase> _cases;
@override@JsonKey() List<PortalOrderCase> get cases {
  if (_cases is EqualUnmodifiableListView) return _cases;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cases);
}

@override@JsonKey(name: 'paid_at') final  String? paidAt;
@override@JsonKey(name: 'created_at') final  String? createdAt;
@override@JsonKey(name: 'updated_at') final  String? updatedAt;

/// Create a copy of PortalOrder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PortalOrderCopyWith<_PortalOrder> get copyWith => __$PortalOrderCopyWithImpl<_PortalOrder>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PortalOrderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PortalOrder&&(identical(other.id, id) || other.id == id)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusLabel, statusLabel) || other.statusLabel == statusLabel)&&const DeepCollectionEquality().equals(other._allowedNextStatuses, _allowedNextStatuses)&&(identical(other.fulfillmentType, fulfillmentType) || other.fulfillmentType == fulfillmentType)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.paymentReference, paymentReference) || other.paymentReference == paymentReference)&&(identical(other.paymentProvider, paymentProvider) || other.paymentProvider == paymentProvider)&&(identical(other.buyerUsername, buyerUsername) || other.buyerUsername == buyerUsername)&&(identical(other.buyerDisplayName, buyerDisplayName) || other.buyerDisplayName == buyerDisplayName)&&(identical(other.buyerEmail, buyerEmail) || other.buyerEmail == buyerEmail)&&const DeepCollectionEquality().equals(other._deliveryAddress, _deliveryAddress)&&const DeepCollectionEquality().equals(other._pickupDetails, _pickupDetails)&&(identical(other.pickupStation, pickupStation) || other.pickupStation == pickupStation)&&(identical(other.deliveryPersonnel, deliveryPersonnel) || other.deliveryPersonnel == deliveryPersonnel)&&const DeepCollectionEquality().equals(other._items, _items)&&const DeepCollectionEquality().equals(other._itemsTotalArtifacts, _itemsTotalArtifacts)&&const DeepCollectionEquality().equals(other._discountArtifacts, _discountArtifacts)&&const DeepCollectionEquality().equals(other._totalArtifacts, _totalArtifacts)&&(identical(other.spentUsd, spentUsd) || other.spentUsd == spentUsd)&&const DeepCollectionEquality().equals(other._statusHistory, _statusHistory)&&const DeepCollectionEquality().equals(other._cases, _cases)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,orderNumber,status,statusLabel,const DeepCollectionEquality().hash(_allowedNextStatuses),fulfillmentType,paymentMethod,paymentStatus,paymentReference,paymentProvider,buyerUsername,buyerDisplayName,buyerEmail,const DeepCollectionEquality().hash(_deliveryAddress),const DeepCollectionEquality().hash(_pickupDetails),pickupStation,deliveryPersonnel,const DeepCollectionEquality().hash(_items),const DeepCollectionEquality().hash(_itemsTotalArtifacts),const DeepCollectionEquality().hash(_discountArtifacts),const DeepCollectionEquality().hash(_totalArtifacts),spentUsd,const DeepCollectionEquality().hash(_statusHistory),const DeepCollectionEquality().hash(_cases),paidAt,createdAt,updatedAt]);

@override
String toString() {
  return 'PortalOrder(id: $id, orderNumber: $orderNumber, status: $status, statusLabel: $statusLabel, allowedNextStatuses: $allowedNextStatuses, fulfillmentType: $fulfillmentType, paymentMethod: $paymentMethod, paymentStatus: $paymentStatus, paymentReference: $paymentReference, paymentProvider: $paymentProvider, buyerUsername: $buyerUsername, buyerDisplayName: $buyerDisplayName, buyerEmail: $buyerEmail, deliveryAddress: $deliveryAddress, pickupDetails: $pickupDetails, pickupStation: $pickupStation, deliveryPersonnel: $deliveryPersonnel, items: $items, itemsTotalArtifacts: $itemsTotalArtifacts, discountArtifacts: $discountArtifacts, totalArtifacts: $totalArtifacts, spentUsd: $spentUsd, statusHistory: $statusHistory, cases: $cases, paidAt: $paidAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PortalOrderCopyWith<$Res> implements $PortalOrderCopyWith<$Res> {
  factory _$PortalOrderCopyWith(_PortalOrder value, $Res Function(_PortalOrder) _then) = __$PortalOrderCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'order_number') String orderNumber, String status,@JsonKey(name: 'status_label') String statusLabel,@JsonKey(name: 'allowed_next_statuses') List<String> allowedNextStatuses,@JsonKey(name: 'fulfillment_type') String fulfillmentType,@JsonKey(name: 'payment_method') String? paymentMethod,@JsonKey(name: 'payment_status') String paymentStatus,@JsonKey(name: 'payment_reference') String paymentReference,@JsonKey(name: 'payment_provider') String paymentProvider,@JsonKey(name: 'buyer_username') String? buyerUsername,@JsonKey(name: 'buyer_display_name') String? buyerDisplayName,@JsonKey(name: 'buyer_email') String? buyerEmail,@JsonKey(name: 'delivery_address') Map<String, dynamic> deliveryAddress,@JsonKey(name: 'pickup_details') Map<String, dynamic> pickupDetails,@JsonKey(name: 'pickup_station') String? pickupStation,@JsonKey(name: 'delivery_personnel') String? deliveryPersonnel, List<PortalOrderItem> items,@JsonKey(name: 'items_total_artifacts') Map<String, int> itemsTotalArtifacts,@JsonKey(name: 'discount_artifacts') Map<String, int> discountArtifacts,@JsonKey(name: 'total_artifacts') Map<String, int> totalArtifacts,@JsonKey(name: 'spent_usd', fromJson: _optDoubleOrZero) double spentUsd,@JsonKey(name: 'status_history') List<Map<String, dynamic>> statusHistory, List<PortalOrderCase> cases,@JsonKey(name: 'paid_at') String? paidAt,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
});




}
/// @nodoc
class __$PortalOrderCopyWithImpl<$Res>
    implements _$PortalOrderCopyWith<$Res> {
  __$PortalOrderCopyWithImpl(this._self, this._then);

  final _PortalOrder _self;
  final $Res Function(_PortalOrder) _then;

/// Create a copy of PortalOrder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orderNumber = null,Object? status = null,Object? statusLabel = null,Object? allowedNextStatuses = null,Object? fulfillmentType = null,Object? paymentMethod = freezed,Object? paymentStatus = null,Object? paymentReference = null,Object? paymentProvider = null,Object? buyerUsername = freezed,Object? buyerDisplayName = freezed,Object? buyerEmail = freezed,Object? deliveryAddress = null,Object? pickupDetails = null,Object? pickupStation = freezed,Object? deliveryPersonnel = freezed,Object? items = null,Object? itemsTotalArtifacts = null,Object? discountArtifacts = null,Object? totalArtifacts = null,Object? spentUsd = null,Object? statusHistory = null,Object? cases = null,Object? paidAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_PortalOrder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,statusLabel: null == statusLabel ? _self.statusLabel : statusLabel // ignore: cast_nullable_to_non_nullable
as String,allowedNextStatuses: null == allowedNextStatuses ? _self._allowedNextStatuses : allowedNextStatuses // ignore: cast_nullable_to_non_nullable
as List<String>,fulfillmentType: null == fulfillmentType ? _self.fulfillmentType : fulfillmentType // ignore: cast_nullable_to_non_nullable
as String,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String?,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as String,paymentReference: null == paymentReference ? _self.paymentReference : paymentReference // ignore: cast_nullable_to_non_nullable
as String,paymentProvider: null == paymentProvider ? _self.paymentProvider : paymentProvider // ignore: cast_nullable_to_non_nullable
as String,buyerUsername: freezed == buyerUsername ? _self.buyerUsername : buyerUsername // ignore: cast_nullable_to_non_nullable
as String?,buyerDisplayName: freezed == buyerDisplayName ? _self.buyerDisplayName : buyerDisplayName // ignore: cast_nullable_to_non_nullable
as String?,buyerEmail: freezed == buyerEmail ? _self.buyerEmail : buyerEmail // ignore: cast_nullable_to_non_nullable
as String?,deliveryAddress: null == deliveryAddress ? _self._deliveryAddress : deliveryAddress // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,pickupDetails: null == pickupDetails ? _self._pickupDetails : pickupDetails // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,pickupStation: freezed == pickupStation ? _self.pickupStation : pickupStation // ignore: cast_nullable_to_non_nullable
as String?,deliveryPersonnel: freezed == deliveryPersonnel ? _self.deliveryPersonnel : deliveryPersonnel // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<PortalOrderItem>,itemsTotalArtifacts: null == itemsTotalArtifacts ? _self._itemsTotalArtifacts : itemsTotalArtifacts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,discountArtifacts: null == discountArtifacts ? _self._discountArtifacts : discountArtifacts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,totalArtifacts: null == totalArtifacts ? _self._totalArtifacts : totalArtifacts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,spentUsd: null == spentUsd ? _self.spentUsd : spentUsd // ignore: cast_nullable_to_non_nullable
as double,statusHistory: null == statusHistory ? _self._statusHistory : statusHistory // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,cases: null == cases ? _self._cases : cases // ignore: cast_nullable_to_non_nullable
as List<PortalOrderCase>,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PortalGym {

 String get id; String? get name; String? get handle; String? get category;@JsonKey(name: 'access_type') String? get accessType;@JsonKey(name: 'subscription_type') String? get subscriptionType;@JsonKey(name: 'is_verified') bool get isVerified;@JsonKey(name: 'is_deleted') bool get isDeleted;@JsonKey(name: 'deleted_at') String? get deletedAt;@JsonKey(name: 'member_count') int get memberCount;@JsonKey(name: 'location_city') String get locationCity;@JsonKey(name: 'location_country') String get locationCountry;@JsonKey(name: 'created_at') String? get createdAt;
/// Create a copy of PortalGym
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PortalGymCopyWith<PortalGym> get copyWith => _$PortalGymCopyWithImpl<PortalGym>(this as PortalGym, _$identity);

  /// Serializes this PortalGym to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PortalGym&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.handle, handle) || other.handle == handle)&&(identical(other.category, category) || other.category == category)&&(identical(other.accessType, accessType) || other.accessType == accessType)&&(identical(other.subscriptionType, subscriptionType) || other.subscriptionType == subscriptionType)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount)&&(identical(other.locationCity, locationCity) || other.locationCity == locationCity)&&(identical(other.locationCountry, locationCountry) || other.locationCountry == locationCountry)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,handle,category,accessType,subscriptionType,isVerified,isDeleted,deletedAt,memberCount,locationCity,locationCountry,createdAt);

@override
String toString() {
  return 'PortalGym(id: $id, name: $name, handle: $handle, category: $category, accessType: $accessType, subscriptionType: $subscriptionType, isVerified: $isVerified, isDeleted: $isDeleted, deletedAt: $deletedAt, memberCount: $memberCount, locationCity: $locationCity, locationCountry: $locationCountry, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PortalGymCopyWith<$Res>  {
  factory $PortalGymCopyWith(PortalGym value, $Res Function(PortalGym) _then) = _$PortalGymCopyWithImpl;
@useResult
$Res call({
 String id, String? name, String? handle, String? category,@JsonKey(name: 'access_type') String? accessType,@JsonKey(name: 'subscription_type') String? subscriptionType,@JsonKey(name: 'is_verified') bool isVerified,@JsonKey(name: 'is_deleted') bool isDeleted,@JsonKey(name: 'deleted_at') String? deletedAt,@JsonKey(name: 'member_count') int memberCount,@JsonKey(name: 'location_city') String locationCity,@JsonKey(name: 'location_country') String locationCountry,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class _$PortalGymCopyWithImpl<$Res>
    implements $PortalGymCopyWith<$Res> {
  _$PortalGymCopyWithImpl(this._self, this._then);

  final PortalGym _self;
  final $Res Function(PortalGym) _then;

/// Create a copy of PortalGym
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = freezed,Object? handle = freezed,Object? category = freezed,Object? accessType = freezed,Object? subscriptionType = freezed,Object? isVerified = null,Object? isDeleted = null,Object? deletedAt = freezed,Object? memberCount = null,Object? locationCity = null,Object? locationCountry = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,handle: freezed == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,accessType: freezed == accessType ? _self.accessType : accessType // ignore: cast_nullable_to_non_nullable
as String?,subscriptionType: freezed == subscriptionType ? _self.subscriptionType : subscriptionType // ignore: cast_nullable_to_non_nullable
as String?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as String?,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,locationCity: null == locationCity ? _self.locationCity : locationCity // ignore: cast_nullable_to_non_nullable
as String,locationCountry: null == locationCountry ? _self.locationCountry : locationCountry // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PortalGym].
extension PortalGymPatterns on PortalGym {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PortalGym value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PortalGym() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PortalGym value)  $default,){
final _that = this;
switch (_that) {
case _PortalGym():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PortalGym value)?  $default,){
final _that = this;
switch (_that) {
case _PortalGym() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? name,  String? handle,  String? category, @JsonKey(name: 'access_type')  String? accessType, @JsonKey(name: 'subscription_type')  String? subscriptionType, @JsonKey(name: 'is_verified')  bool isVerified, @JsonKey(name: 'is_deleted')  bool isDeleted, @JsonKey(name: 'deleted_at')  String? deletedAt, @JsonKey(name: 'member_count')  int memberCount, @JsonKey(name: 'location_city')  String locationCity, @JsonKey(name: 'location_country')  String locationCountry, @JsonKey(name: 'created_at')  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PortalGym() when $default != null:
return $default(_that.id,_that.name,_that.handle,_that.category,_that.accessType,_that.subscriptionType,_that.isVerified,_that.isDeleted,_that.deletedAt,_that.memberCount,_that.locationCity,_that.locationCountry,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? name,  String? handle,  String? category, @JsonKey(name: 'access_type')  String? accessType, @JsonKey(name: 'subscription_type')  String? subscriptionType, @JsonKey(name: 'is_verified')  bool isVerified, @JsonKey(name: 'is_deleted')  bool isDeleted, @JsonKey(name: 'deleted_at')  String? deletedAt, @JsonKey(name: 'member_count')  int memberCount, @JsonKey(name: 'location_city')  String locationCity, @JsonKey(name: 'location_country')  String locationCountry, @JsonKey(name: 'created_at')  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _PortalGym():
return $default(_that.id,_that.name,_that.handle,_that.category,_that.accessType,_that.subscriptionType,_that.isVerified,_that.isDeleted,_that.deletedAt,_that.memberCount,_that.locationCity,_that.locationCountry,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? name,  String? handle,  String? category, @JsonKey(name: 'access_type')  String? accessType, @JsonKey(name: 'subscription_type')  String? subscriptionType, @JsonKey(name: 'is_verified')  bool isVerified, @JsonKey(name: 'is_deleted')  bool isDeleted, @JsonKey(name: 'deleted_at')  String? deletedAt, @JsonKey(name: 'member_count')  int memberCount, @JsonKey(name: 'location_city')  String locationCity, @JsonKey(name: 'location_country')  String locationCountry, @JsonKey(name: 'created_at')  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _PortalGym() when $default != null:
return $default(_that.id,_that.name,_that.handle,_that.category,_that.accessType,_that.subscriptionType,_that.isVerified,_that.isDeleted,_that.deletedAt,_that.memberCount,_that.locationCity,_that.locationCountry,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PortalGym implements PortalGym {
  const _PortalGym({required this.id, this.name, this.handle, this.category, @JsonKey(name: 'access_type') this.accessType, @JsonKey(name: 'subscription_type') this.subscriptionType, @JsonKey(name: 'is_verified') this.isVerified = false, @JsonKey(name: 'is_deleted') this.isDeleted = false, @JsonKey(name: 'deleted_at') this.deletedAt, @JsonKey(name: 'member_count') this.memberCount = 0, @JsonKey(name: 'location_city') this.locationCity = '', @JsonKey(name: 'location_country') this.locationCountry = '', @JsonKey(name: 'created_at') this.createdAt});
  factory _PortalGym.fromJson(Map<String, dynamic> json) => _$PortalGymFromJson(json);

@override final  String id;
@override final  String? name;
@override final  String? handle;
@override final  String? category;
@override@JsonKey(name: 'access_type') final  String? accessType;
@override@JsonKey(name: 'subscription_type') final  String? subscriptionType;
@override@JsonKey(name: 'is_verified') final  bool isVerified;
@override@JsonKey(name: 'is_deleted') final  bool isDeleted;
@override@JsonKey(name: 'deleted_at') final  String? deletedAt;
@override@JsonKey(name: 'member_count') final  int memberCount;
@override@JsonKey(name: 'location_city') final  String locationCity;
@override@JsonKey(name: 'location_country') final  String locationCountry;
@override@JsonKey(name: 'created_at') final  String? createdAt;

/// Create a copy of PortalGym
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PortalGymCopyWith<_PortalGym> get copyWith => __$PortalGymCopyWithImpl<_PortalGym>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PortalGymToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PortalGym&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.handle, handle) || other.handle == handle)&&(identical(other.category, category) || other.category == category)&&(identical(other.accessType, accessType) || other.accessType == accessType)&&(identical(other.subscriptionType, subscriptionType) || other.subscriptionType == subscriptionType)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount)&&(identical(other.locationCity, locationCity) || other.locationCity == locationCity)&&(identical(other.locationCountry, locationCountry) || other.locationCountry == locationCountry)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,handle,category,accessType,subscriptionType,isVerified,isDeleted,deletedAt,memberCount,locationCity,locationCountry,createdAt);

@override
String toString() {
  return 'PortalGym(id: $id, name: $name, handle: $handle, category: $category, accessType: $accessType, subscriptionType: $subscriptionType, isVerified: $isVerified, isDeleted: $isDeleted, deletedAt: $deletedAt, memberCount: $memberCount, locationCity: $locationCity, locationCountry: $locationCountry, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PortalGymCopyWith<$Res> implements $PortalGymCopyWith<$Res> {
  factory _$PortalGymCopyWith(_PortalGym value, $Res Function(_PortalGym) _then) = __$PortalGymCopyWithImpl;
@override @useResult
$Res call({
 String id, String? name, String? handle, String? category,@JsonKey(name: 'access_type') String? accessType,@JsonKey(name: 'subscription_type') String? subscriptionType,@JsonKey(name: 'is_verified') bool isVerified,@JsonKey(name: 'is_deleted') bool isDeleted,@JsonKey(name: 'deleted_at') String? deletedAt,@JsonKey(name: 'member_count') int memberCount,@JsonKey(name: 'location_city') String locationCity,@JsonKey(name: 'location_country') String locationCountry,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class __$PortalGymCopyWithImpl<$Res>
    implements _$PortalGymCopyWith<$Res> {
  __$PortalGymCopyWithImpl(this._self, this._then);

  final _PortalGym _self;
  final $Res Function(_PortalGym) _then;

/// Create a copy of PortalGym
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = freezed,Object? handle = freezed,Object? category = freezed,Object? accessType = freezed,Object? subscriptionType = freezed,Object? isVerified = null,Object? isDeleted = null,Object? deletedAt = freezed,Object? memberCount = null,Object? locationCity = null,Object? locationCountry = null,Object? createdAt = freezed,}) {
  return _then(_PortalGym(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,handle: freezed == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,accessType: freezed == accessType ? _self.accessType : accessType // ignore: cast_nullable_to_non_nullable
as String?,subscriptionType: freezed == subscriptionType ? _self.subscriptionType : subscriptionType // ignore: cast_nullable_to_non_nullable
as String?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as String?,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,locationCity: null == locationCity ? _self.locationCity : locationCity // ignore: cast_nullable_to_non_nullable
as String,locationCountry: null == locationCountry ? _self.locationCountry : locationCountry // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PortalCommunity {

 String get id;@JsonKey(name: 'group_name') String get groupName;@JsonKey(name: 'is_group') bool get isGroup;@JsonKey(name: 'is_community') bool get isCommunity;@JsonKey(name: 'is_public') bool get isPublic;@JsonKey(name: 'origin') String get origin;@JsonKey(name: 'invite_code') String get inviteCode; String get description;@JsonKey(name: 'gym_handle') String? get gymHandle;@JsonKey(name: 'created_by_username') String? get createdByUsername;@JsonKey(name: 'member_count') int get memberCount;@JsonKey(name: 'post_count') int get postCount;@JsonKey(name: 'last_message_at') String? get lastMessageAt;@JsonKey(name: 'created_at') String? get createdAt;
/// Create a copy of PortalCommunity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PortalCommunityCopyWith<PortalCommunity> get copyWith => _$PortalCommunityCopyWithImpl<PortalCommunity>(this as PortalCommunity, _$identity);

  /// Serializes this PortalCommunity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PortalCommunity&&(identical(other.id, id) || other.id == id)&&(identical(other.groupName, groupName) || other.groupName == groupName)&&(identical(other.isGroup, isGroup) || other.isGroup == isGroup)&&(identical(other.isCommunity, isCommunity) || other.isCommunity == isCommunity)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode)&&(identical(other.description, description) || other.description == description)&&(identical(other.gymHandle, gymHandle) || other.gymHandle == gymHandle)&&(identical(other.createdByUsername, createdByUsername) || other.createdByUsername == createdByUsername)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount)&&(identical(other.postCount, postCount) || other.postCount == postCount)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,groupName,isGroup,isCommunity,isPublic,origin,inviteCode,description,gymHandle,createdByUsername,memberCount,postCount,lastMessageAt,createdAt);

@override
String toString() {
  return 'PortalCommunity(id: $id, groupName: $groupName, isGroup: $isGroup, isCommunity: $isCommunity, isPublic: $isPublic, origin: $origin, inviteCode: $inviteCode, description: $description, gymHandle: $gymHandle, createdByUsername: $createdByUsername, memberCount: $memberCount, postCount: $postCount, lastMessageAt: $lastMessageAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PortalCommunityCopyWith<$Res>  {
  factory $PortalCommunityCopyWith(PortalCommunity value, $Res Function(PortalCommunity) _then) = _$PortalCommunityCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'group_name') String groupName,@JsonKey(name: 'is_group') bool isGroup,@JsonKey(name: 'is_community') bool isCommunity,@JsonKey(name: 'is_public') bool isPublic,@JsonKey(name: 'origin') String origin,@JsonKey(name: 'invite_code') String inviteCode, String description,@JsonKey(name: 'gym_handle') String? gymHandle,@JsonKey(name: 'created_by_username') String? createdByUsername,@JsonKey(name: 'member_count') int memberCount,@JsonKey(name: 'post_count') int postCount,@JsonKey(name: 'last_message_at') String? lastMessageAt,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class _$PortalCommunityCopyWithImpl<$Res>
    implements $PortalCommunityCopyWith<$Res> {
  _$PortalCommunityCopyWithImpl(this._self, this._then);

  final PortalCommunity _self;
  final $Res Function(PortalCommunity) _then;

/// Create a copy of PortalCommunity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? groupName = null,Object? isGroup = null,Object? isCommunity = null,Object? isPublic = null,Object? origin = null,Object? inviteCode = null,Object? description = null,Object? gymHandle = freezed,Object? createdByUsername = freezed,Object? memberCount = null,Object? postCount = null,Object? lastMessageAt = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,groupName: null == groupName ? _self.groupName : groupName // ignore: cast_nullable_to_non_nullable
as String,isGroup: null == isGroup ? _self.isGroup : isGroup // ignore: cast_nullable_to_non_nullable
as bool,isCommunity: null == isCommunity ? _self.isCommunity : isCommunity // ignore: cast_nullable_to_non_nullable
as bool,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as String,inviteCode: null == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,gymHandle: freezed == gymHandle ? _self.gymHandle : gymHandle // ignore: cast_nullable_to_non_nullable
as String?,createdByUsername: freezed == createdByUsername ? _self.createdByUsername : createdByUsername // ignore: cast_nullable_to_non_nullable
as String?,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,postCount: null == postCount ? _self.postCount : postCount // ignore: cast_nullable_to_non_nullable
as int,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PortalCommunity].
extension PortalCommunityPatterns on PortalCommunity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PortalCommunity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PortalCommunity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PortalCommunity value)  $default,){
final _that = this;
switch (_that) {
case _PortalCommunity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PortalCommunity value)?  $default,){
final _that = this;
switch (_that) {
case _PortalCommunity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'group_name')  String groupName, @JsonKey(name: 'is_group')  bool isGroup, @JsonKey(name: 'is_community')  bool isCommunity, @JsonKey(name: 'is_public')  bool isPublic, @JsonKey(name: 'origin')  String origin, @JsonKey(name: 'invite_code')  String inviteCode,  String description, @JsonKey(name: 'gym_handle')  String? gymHandle, @JsonKey(name: 'created_by_username')  String? createdByUsername, @JsonKey(name: 'member_count')  int memberCount, @JsonKey(name: 'post_count')  int postCount, @JsonKey(name: 'last_message_at')  String? lastMessageAt, @JsonKey(name: 'created_at')  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PortalCommunity() when $default != null:
return $default(_that.id,_that.groupName,_that.isGroup,_that.isCommunity,_that.isPublic,_that.origin,_that.inviteCode,_that.description,_that.gymHandle,_that.createdByUsername,_that.memberCount,_that.postCount,_that.lastMessageAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'group_name')  String groupName, @JsonKey(name: 'is_group')  bool isGroup, @JsonKey(name: 'is_community')  bool isCommunity, @JsonKey(name: 'is_public')  bool isPublic, @JsonKey(name: 'origin')  String origin, @JsonKey(name: 'invite_code')  String inviteCode,  String description, @JsonKey(name: 'gym_handle')  String? gymHandle, @JsonKey(name: 'created_by_username')  String? createdByUsername, @JsonKey(name: 'member_count')  int memberCount, @JsonKey(name: 'post_count')  int postCount, @JsonKey(name: 'last_message_at')  String? lastMessageAt, @JsonKey(name: 'created_at')  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _PortalCommunity():
return $default(_that.id,_that.groupName,_that.isGroup,_that.isCommunity,_that.isPublic,_that.origin,_that.inviteCode,_that.description,_that.gymHandle,_that.createdByUsername,_that.memberCount,_that.postCount,_that.lastMessageAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'group_name')  String groupName, @JsonKey(name: 'is_group')  bool isGroup, @JsonKey(name: 'is_community')  bool isCommunity, @JsonKey(name: 'is_public')  bool isPublic, @JsonKey(name: 'origin')  String origin, @JsonKey(name: 'invite_code')  String inviteCode,  String description, @JsonKey(name: 'gym_handle')  String? gymHandle, @JsonKey(name: 'created_by_username')  String? createdByUsername, @JsonKey(name: 'member_count')  int memberCount, @JsonKey(name: 'post_count')  int postCount, @JsonKey(name: 'last_message_at')  String? lastMessageAt, @JsonKey(name: 'created_at')  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _PortalCommunity() when $default != null:
return $default(_that.id,_that.groupName,_that.isGroup,_that.isCommunity,_that.isPublic,_that.origin,_that.inviteCode,_that.description,_that.gymHandle,_that.createdByUsername,_that.memberCount,_that.postCount,_that.lastMessageAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PortalCommunity implements PortalCommunity {
  const _PortalCommunity({required this.id, @JsonKey(name: 'group_name') this.groupName = '', @JsonKey(name: 'is_group') this.isGroup = false, @JsonKey(name: 'is_community') this.isCommunity = false, @JsonKey(name: 'is_public') this.isPublic = false, @JsonKey(name: 'origin') this.origin = '', @JsonKey(name: 'invite_code') this.inviteCode = '', this.description = '', @JsonKey(name: 'gym_handle') this.gymHandle, @JsonKey(name: 'created_by_username') this.createdByUsername, @JsonKey(name: 'member_count') this.memberCount = 0, @JsonKey(name: 'post_count') this.postCount = 0, @JsonKey(name: 'last_message_at') this.lastMessageAt, @JsonKey(name: 'created_at') this.createdAt});
  factory _PortalCommunity.fromJson(Map<String, dynamic> json) => _$PortalCommunityFromJson(json);

@override final  String id;
@override@JsonKey(name: 'group_name') final  String groupName;
@override@JsonKey(name: 'is_group') final  bool isGroup;
@override@JsonKey(name: 'is_community') final  bool isCommunity;
@override@JsonKey(name: 'is_public') final  bool isPublic;
@override@JsonKey(name: 'origin') final  String origin;
@override@JsonKey(name: 'invite_code') final  String inviteCode;
@override@JsonKey() final  String description;
@override@JsonKey(name: 'gym_handle') final  String? gymHandle;
@override@JsonKey(name: 'created_by_username') final  String? createdByUsername;
@override@JsonKey(name: 'member_count') final  int memberCount;
@override@JsonKey(name: 'post_count') final  int postCount;
@override@JsonKey(name: 'last_message_at') final  String? lastMessageAt;
@override@JsonKey(name: 'created_at') final  String? createdAt;

/// Create a copy of PortalCommunity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PortalCommunityCopyWith<_PortalCommunity> get copyWith => __$PortalCommunityCopyWithImpl<_PortalCommunity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PortalCommunityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PortalCommunity&&(identical(other.id, id) || other.id == id)&&(identical(other.groupName, groupName) || other.groupName == groupName)&&(identical(other.isGroup, isGroup) || other.isGroup == isGroup)&&(identical(other.isCommunity, isCommunity) || other.isCommunity == isCommunity)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode)&&(identical(other.description, description) || other.description == description)&&(identical(other.gymHandle, gymHandle) || other.gymHandle == gymHandle)&&(identical(other.createdByUsername, createdByUsername) || other.createdByUsername == createdByUsername)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount)&&(identical(other.postCount, postCount) || other.postCount == postCount)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,groupName,isGroup,isCommunity,isPublic,origin,inviteCode,description,gymHandle,createdByUsername,memberCount,postCount,lastMessageAt,createdAt);

@override
String toString() {
  return 'PortalCommunity(id: $id, groupName: $groupName, isGroup: $isGroup, isCommunity: $isCommunity, isPublic: $isPublic, origin: $origin, inviteCode: $inviteCode, description: $description, gymHandle: $gymHandle, createdByUsername: $createdByUsername, memberCount: $memberCount, postCount: $postCount, lastMessageAt: $lastMessageAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PortalCommunityCopyWith<$Res> implements $PortalCommunityCopyWith<$Res> {
  factory _$PortalCommunityCopyWith(_PortalCommunity value, $Res Function(_PortalCommunity) _then) = __$PortalCommunityCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'group_name') String groupName,@JsonKey(name: 'is_group') bool isGroup,@JsonKey(name: 'is_community') bool isCommunity,@JsonKey(name: 'is_public') bool isPublic,@JsonKey(name: 'origin') String origin,@JsonKey(name: 'invite_code') String inviteCode, String description,@JsonKey(name: 'gym_handle') String? gymHandle,@JsonKey(name: 'created_by_username') String? createdByUsername,@JsonKey(name: 'member_count') int memberCount,@JsonKey(name: 'post_count') int postCount,@JsonKey(name: 'last_message_at') String? lastMessageAt,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class __$PortalCommunityCopyWithImpl<$Res>
    implements _$PortalCommunityCopyWith<$Res> {
  __$PortalCommunityCopyWithImpl(this._self, this._then);

  final _PortalCommunity _self;
  final $Res Function(_PortalCommunity) _then;

/// Create a copy of PortalCommunity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? groupName = null,Object? isGroup = null,Object? isCommunity = null,Object? isPublic = null,Object? origin = null,Object? inviteCode = null,Object? description = null,Object? gymHandle = freezed,Object? createdByUsername = freezed,Object? memberCount = null,Object? postCount = null,Object? lastMessageAt = freezed,Object? createdAt = freezed,}) {
  return _then(_PortalCommunity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,groupName: null == groupName ? _self.groupName : groupName // ignore: cast_nullable_to_non_nullable
as String,isGroup: null == isGroup ? _self.isGroup : isGroup // ignore: cast_nullable_to_non_nullable
as bool,isCommunity: null == isCommunity ? _self.isCommunity : isCommunity // ignore: cast_nullable_to_non_nullable
as bool,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as String,inviteCode: null == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,gymHandle: freezed == gymHandle ? _self.gymHandle : gymHandle // ignore: cast_nullable_to_non_nullable
as String?,createdByUsername: freezed == createdByUsername ? _self.createdByUsername : createdByUsername // ignore: cast_nullable_to_non_nullable
as String?,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,postCount: null == postCount ? _self.postCount : postCount // ignore: cast_nullable_to_non_nullable
as int,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PortalStation {

 String get id; String get name; String get description; String get address; String get city; String get country;@JsonKey(name: 'owner_type') String get ownerType;@JsonKey(name: 'owner_name') String? get ownerName; String? get shop; String? get gym;@JsonKey(name: 'is_active') bool get isActive;@JsonKey(name: 'is_primary') bool get isPrimary; String? get phone;@JsonKey(name: 'opening_hours') Map<String, dynamic> get openingHours;@JsonKey(fromJson: _optDouble) double? get latitude;@JsonKey(fromJson: _optDouble) double? get longitude;@JsonKey(name: 'created_at') String? get createdAt;
/// Create a copy of PortalStation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PortalStationCopyWith<PortalStation> get copyWith => _$PortalStationCopyWithImpl<PortalStation>(this as PortalStation, _$identity);

  /// Serializes this PortalStation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PortalStation&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.address, address) || other.address == address)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&(identical(other.ownerType, ownerType) || other.ownerType == ownerType)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.shop, shop) || other.shop == shop)&&(identical(other.gym, gym) || other.gym == gym)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&(identical(other.phone, phone) || other.phone == phone)&&const DeepCollectionEquality().equals(other.openingHours, openingHours)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,address,city,country,ownerType,ownerName,shop,gym,isActive,isPrimary,phone,const DeepCollectionEquality().hash(openingHours),latitude,longitude,createdAt);

@override
String toString() {
  return 'PortalStation(id: $id, name: $name, description: $description, address: $address, city: $city, country: $country, ownerType: $ownerType, ownerName: $ownerName, shop: $shop, gym: $gym, isActive: $isActive, isPrimary: $isPrimary, phone: $phone, openingHours: $openingHours, latitude: $latitude, longitude: $longitude, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PortalStationCopyWith<$Res>  {
  factory $PortalStationCopyWith(PortalStation value, $Res Function(PortalStation) _then) = _$PortalStationCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description, String address, String city, String country,@JsonKey(name: 'owner_type') String ownerType,@JsonKey(name: 'owner_name') String? ownerName, String? shop, String? gym,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'is_primary') bool isPrimary, String? phone,@JsonKey(name: 'opening_hours') Map<String, dynamic> openingHours,@JsonKey(fromJson: _optDouble) double? latitude,@JsonKey(fromJson: _optDouble) double? longitude,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class _$PortalStationCopyWithImpl<$Res>
    implements $PortalStationCopyWith<$Res> {
  _$PortalStationCopyWithImpl(this._self, this._then);

  final PortalStation _self;
  final $Res Function(PortalStation) _then;

/// Create a copy of PortalStation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? address = null,Object? city = null,Object? country = null,Object? ownerType = null,Object? ownerName = freezed,Object? shop = freezed,Object? gym = freezed,Object? isActive = null,Object? isPrimary = null,Object? phone = freezed,Object? openingHours = null,Object? latitude = freezed,Object? longitude = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,ownerType: null == ownerType ? _self.ownerType : ownerType // ignore: cast_nullable_to_non_nullable
as String,ownerName: freezed == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String?,shop: freezed == shop ? _self.shop : shop // ignore: cast_nullable_to_non_nullable
as String?,gym: freezed == gym ? _self.gym : gym // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,openingHours: null == openingHours ? _self.openingHours : openingHours // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PortalStation].
extension PortalStationPatterns on PortalStation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PortalStation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PortalStation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PortalStation value)  $default,){
final _that = this;
switch (_that) {
case _PortalStation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PortalStation value)?  $default,){
final _that = this;
switch (_that) {
case _PortalStation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String description,  String address,  String city,  String country, @JsonKey(name: 'owner_type')  String ownerType, @JsonKey(name: 'owner_name')  String? ownerName,  String? shop,  String? gym, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'is_primary')  bool isPrimary,  String? phone, @JsonKey(name: 'opening_hours')  Map<String, dynamic> openingHours, @JsonKey(fromJson: _optDouble)  double? latitude, @JsonKey(fromJson: _optDouble)  double? longitude, @JsonKey(name: 'created_at')  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PortalStation() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.address,_that.city,_that.country,_that.ownerType,_that.ownerName,_that.shop,_that.gym,_that.isActive,_that.isPrimary,_that.phone,_that.openingHours,_that.latitude,_that.longitude,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String description,  String address,  String city,  String country, @JsonKey(name: 'owner_type')  String ownerType, @JsonKey(name: 'owner_name')  String? ownerName,  String? shop,  String? gym, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'is_primary')  bool isPrimary,  String? phone, @JsonKey(name: 'opening_hours')  Map<String, dynamic> openingHours, @JsonKey(fromJson: _optDouble)  double? latitude, @JsonKey(fromJson: _optDouble)  double? longitude, @JsonKey(name: 'created_at')  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _PortalStation():
return $default(_that.id,_that.name,_that.description,_that.address,_that.city,_that.country,_that.ownerType,_that.ownerName,_that.shop,_that.gym,_that.isActive,_that.isPrimary,_that.phone,_that.openingHours,_that.latitude,_that.longitude,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String description,  String address,  String city,  String country, @JsonKey(name: 'owner_type')  String ownerType, @JsonKey(name: 'owner_name')  String? ownerName,  String? shop,  String? gym, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'is_primary')  bool isPrimary,  String? phone, @JsonKey(name: 'opening_hours')  Map<String, dynamic> openingHours, @JsonKey(fromJson: _optDouble)  double? latitude, @JsonKey(fromJson: _optDouble)  double? longitude, @JsonKey(name: 'created_at')  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _PortalStation() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.address,_that.city,_that.country,_that.ownerType,_that.ownerName,_that.shop,_that.gym,_that.isActive,_that.isPrimary,_that.phone,_that.openingHours,_that.latitude,_that.longitude,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PortalStation implements PortalStation {
  const _PortalStation({required this.id, this.name = '', this.description = '', this.address = '', this.city = '', this.country = '', @JsonKey(name: 'owner_type') this.ownerType = '', @JsonKey(name: 'owner_name') this.ownerName, this.shop, this.gym, @JsonKey(name: 'is_active') this.isActive = true, @JsonKey(name: 'is_primary') this.isPrimary = false, this.phone, @JsonKey(name: 'opening_hours') final  Map<String, dynamic> openingHours = const <String, dynamic>{}, @JsonKey(fromJson: _optDouble) this.latitude, @JsonKey(fromJson: _optDouble) this.longitude, @JsonKey(name: 'created_at') this.createdAt}): _openingHours = openingHours;
  factory _PortalStation.fromJson(Map<String, dynamic> json) => _$PortalStationFromJson(json);

@override final  String id;
@override@JsonKey() final  String name;
@override@JsonKey() final  String description;
@override@JsonKey() final  String address;
@override@JsonKey() final  String city;
@override@JsonKey() final  String country;
@override@JsonKey(name: 'owner_type') final  String ownerType;
@override@JsonKey(name: 'owner_name') final  String? ownerName;
@override final  String? shop;
@override final  String? gym;
@override@JsonKey(name: 'is_active') final  bool isActive;
@override@JsonKey(name: 'is_primary') final  bool isPrimary;
@override final  String? phone;
 final  Map<String, dynamic> _openingHours;
@override@JsonKey(name: 'opening_hours') Map<String, dynamic> get openingHours {
  if (_openingHours is EqualUnmodifiableMapView) return _openingHours;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_openingHours);
}

@override@JsonKey(fromJson: _optDouble) final  double? latitude;
@override@JsonKey(fromJson: _optDouble) final  double? longitude;
@override@JsonKey(name: 'created_at') final  String? createdAt;

/// Create a copy of PortalStation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PortalStationCopyWith<_PortalStation> get copyWith => __$PortalStationCopyWithImpl<_PortalStation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PortalStationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PortalStation&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.address, address) || other.address == address)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&(identical(other.ownerType, ownerType) || other.ownerType == ownerType)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.shop, shop) || other.shop == shop)&&(identical(other.gym, gym) || other.gym == gym)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&(identical(other.phone, phone) || other.phone == phone)&&const DeepCollectionEquality().equals(other._openingHours, _openingHours)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,address,city,country,ownerType,ownerName,shop,gym,isActive,isPrimary,phone,const DeepCollectionEquality().hash(_openingHours),latitude,longitude,createdAt);

@override
String toString() {
  return 'PortalStation(id: $id, name: $name, description: $description, address: $address, city: $city, country: $country, ownerType: $ownerType, ownerName: $ownerName, shop: $shop, gym: $gym, isActive: $isActive, isPrimary: $isPrimary, phone: $phone, openingHours: $openingHours, latitude: $latitude, longitude: $longitude, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PortalStationCopyWith<$Res> implements $PortalStationCopyWith<$Res> {
  factory _$PortalStationCopyWith(_PortalStation value, $Res Function(_PortalStation) _then) = __$PortalStationCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description, String address, String city, String country,@JsonKey(name: 'owner_type') String ownerType,@JsonKey(name: 'owner_name') String? ownerName, String? shop, String? gym,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'is_primary') bool isPrimary, String? phone,@JsonKey(name: 'opening_hours') Map<String, dynamic> openingHours,@JsonKey(fromJson: _optDouble) double? latitude,@JsonKey(fromJson: _optDouble) double? longitude,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class __$PortalStationCopyWithImpl<$Res>
    implements _$PortalStationCopyWith<$Res> {
  __$PortalStationCopyWithImpl(this._self, this._then);

  final _PortalStation _self;
  final $Res Function(_PortalStation) _then;

/// Create a copy of PortalStation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? address = null,Object? city = null,Object? country = null,Object? ownerType = null,Object? ownerName = freezed,Object? shop = freezed,Object? gym = freezed,Object? isActive = null,Object? isPrimary = null,Object? phone = freezed,Object? openingHours = null,Object? latitude = freezed,Object? longitude = freezed,Object? createdAt = freezed,}) {
  return _then(_PortalStation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,ownerType: null == ownerType ? _self.ownerType : ownerType // ignore: cast_nullable_to_non_nullable
as String,ownerName: freezed == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String?,shop: freezed == shop ? _self.shop : shop // ignore: cast_nullable_to_non_nullable
as String?,gym: freezed == gym ? _self.gym : gym // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,openingHours: null == openingHours ? _self._openingHours : openingHours // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PortalStationApplication {

 String get id; String? get shop;@JsonKey(name: 'shop_handle') String? get shopHandle; String? get gym;@JsonKey(name: 'gym_handle') String? get gymHandle; String get status;@JsonKey(name: 'business_registration_number') String get businessRegistrationNumber;@JsonKey(name: 'contact_phone') String get contactPhone; String get address; String get city; String get country;@JsonKey(fromJson: _optDouble) double? get latitude;@JsonKey(fromJson: _optDouble) double? get longitude;@JsonKey(name: 'opening_hours') Map<String, dynamic> get openingHours;@JsonKey(name: 'documents') List<Map<String, dynamic>> get documents;@JsonKey(name: 'agreed_to_policy') bool get agreedToPolicy;@JsonKey(name: 'submitted_by_username') String? get submittedByUsername;@JsonKey(name: 'reviewer_notes') String get reviewerNotes;@JsonKey(name: 'rejection_reason') String get rejectionReason;@JsonKey(name: 'reviewed_by_username') String? get reviewedByUsername;@JsonKey(name: 'reviewed_at') String? get reviewedAt;@JsonKey(name: 'created_at') String? get createdAt;
/// Create a copy of PortalStationApplication
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PortalStationApplicationCopyWith<PortalStationApplication> get copyWith => _$PortalStationApplicationCopyWithImpl<PortalStationApplication>(this as PortalStationApplication, _$identity);

  /// Serializes this PortalStationApplication to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PortalStationApplication&&(identical(other.id, id) || other.id == id)&&(identical(other.shop, shop) || other.shop == shop)&&(identical(other.shopHandle, shopHandle) || other.shopHandle == shopHandle)&&(identical(other.gym, gym) || other.gym == gym)&&(identical(other.gymHandle, gymHandle) || other.gymHandle == gymHandle)&&(identical(other.status, status) || other.status == status)&&(identical(other.businessRegistrationNumber, businessRegistrationNumber) || other.businessRegistrationNumber == businessRegistrationNumber)&&(identical(other.contactPhone, contactPhone) || other.contactPhone == contactPhone)&&(identical(other.address, address) || other.address == address)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&const DeepCollectionEquality().equals(other.openingHours, openingHours)&&const DeepCollectionEquality().equals(other.documents, documents)&&(identical(other.agreedToPolicy, agreedToPolicy) || other.agreedToPolicy == agreedToPolicy)&&(identical(other.submittedByUsername, submittedByUsername) || other.submittedByUsername == submittedByUsername)&&(identical(other.reviewerNotes, reviewerNotes) || other.reviewerNotes == reviewerNotes)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.reviewedByUsername, reviewedByUsername) || other.reviewedByUsername == reviewedByUsername)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,shop,shopHandle,gym,gymHandle,status,businessRegistrationNumber,contactPhone,address,city,country,latitude,longitude,const DeepCollectionEquality().hash(openingHours),const DeepCollectionEquality().hash(documents),agreedToPolicy,submittedByUsername,reviewerNotes,rejectionReason,reviewedByUsername,reviewedAt,createdAt]);

@override
String toString() {
  return 'PortalStationApplication(id: $id, shop: $shop, shopHandle: $shopHandle, gym: $gym, gymHandle: $gymHandle, status: $status, businessRegistrationNumber: $businessRegistrationNumber, contactPhone: $contactPhone, address: $address, city: $city, country: $country, latitude: $latitude, longitude: $longitude, openingHours: $openingHours, documents: $documents, agreedToPolicy: $agreedToPolicy, submittedByUsername: $submittedByUsername, reviewerNotes: $reviewerNotes, rejectionReason: $rejectionReason, reviewedByUsername: $reviewedByUsername, reviewedAt: $reviewedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PortalStationApplicationCopyWith<$Res>  {
  factory $PortalStationApplicationCopyWith(PortalStationApplication value, $Res Function(PortalStationApplication) _then) = _$PortalStationApplicationCopyWithImpl;
@useResult
$Res call({
 String id, String? shop,@JsonKey(name: 'shop_handle') String? shopHandle, String? gym,@JsonKey(name: 'gym_handle') String? gymHandle, String status,@JsonKey(name: 'business_registration_number') String businessRegistrationNumber,@JsonKey(name: 'contact_phone') String contactPhone, String address, String city, String country,@JsonKey(fromJson: _optDouble) double? latitude,@JsonKey(fromJson: _optDouble) double? longitude,@JsonKey(name: 'opening_hours') Map<String, dynamic> openingHours,@JsonKey(name: 'documents') List<Map<String, dynamic>> documents,@JsonKey(name: 'agreed_to_policy') bool agreedToPolicy,@JsonKey(name: 'submitted_by_username') String? submittedByUsername,@JsonKey(name: 'reviewer_notes') String reviewerNotes,@JsonKey(name: 'rejection_reason') String rejectionReason,@JsonKey(name: 'reviewed_by_username') String? reviewedByUsername,@JsonKey(name: 'reviewed_at') String? reviewedAt,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class _$PortalStationApplicationCopyWithImpl<$Res>
    implements $PortalStationApplicationCopyWith<$Res> {
  _$PortalStationApplicationCopyWithImpl(this._self, this._then);

  final PortalStationApplication _self;
  final $Res Function(PortalStationApplication) _then;

/// Create a copy of PortalStationApplication
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? shop = freezed,Object? shopHandle = freezed,Object? gym = freezed,Object? gymHandle = freezed,Object? status = null,Object? businessRegistrationNumber = null,Object? contactPhone = null,Object? address = null,Object? city = null,Object? country = null,Object? latitude = freezed,Object? longitude = freezed,Object? openingHours = null,Object? documents = null,Object? agreedToPolicy = null,Object? submittedByUsername = freezed,Object? reviewerNotes = null,Object? rejectionReason = null,Object? reviewedByUsername = freezed,Object? reviewedAt = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shop: freezed == shop ? _self.shop : shop // ignore: cast_nullable_to_non_nullable
as String?,shopHandle: freezed == shopHandle ? _self.shopHandle : shopHandle // ignore: cast_nullable_to_non_nullable
as String?,gym: freezed == gym ? _self.gym : gym // ignore: cast_nullable_to_non_nullable
as String?,gymHandle: freezed == gymHandle ? _self.gymHandle : gymHandle // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,businessRegistrationNumber: null == businessRegistrationNumber ? _self.businessRegistrationNumber : businessRegistrationNumber // ignore: cast_nullable_to_non_nullable
as String,contactPhone: null == contactPhone ? _self.contactPhone : contactPhone // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,openingHours: null == openingHours ? _self.openingHours : openingHours // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,documents: null == documents ? _self.documents : documents // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,agreedToPolicy: null == agreedToPolicy ? _self.agreedToPolicy : agreedToPolicy // ignore: cast_nullable_to_non_nullable
as bool,submittedByUsername: freezed == submittedByUsername ? _self.submittedByUsername : submittedByUsername // ignore: cast_nullable_to_non_nullable
as String?,reviewerNotes: null == reviewerNotes ? _self.reviewerNotes : reviewerNotes // ignore: cast_nullable_to_non_nullable
as String,rejectionReason: null == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String,reviewedByUsername: freezed == reviewedByUsername ? _self.reviewedByUsername : reviewedByUsername // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PortalStationApplication].
extension PortalStationApplicationPatterns on PortalStationApplication {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PortalStationApplication value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PortalStationApplication() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PortalStationApplication value)  $default,){
final _that = this;
switch (_that) {
case _PortalStationApplication():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PortalStationApplication value)?  $default,){
final _that = this;
switch (_that) {
case _PortalStationApplication() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? shop, @JsonKey(name: 'shop_handle')  String? shopHandle,  String? gym, @JsonKey(name: 'gym_handle')  String? gymHandle,  String status, @JsonKey(name: 'business_registration_number')  String businessRegistrationNumber, @JsonKey(name: 'contact_phone')  String contactPhone,  String address,  String city,  String country, @JsonKey(fromJson: _optDouble)  double? latitude, @JsonKey(fromJson: _optDouble)  double? longitude, @JsonKey(name: 'opening_hours')  Map<String, dynamic> openingHours, @JsonKey(name: 'documents')  List<Map<String, dynamic>> documents, @JsonKey(name: 'agreed_to_policy')  bool agreedToPolicy, @JsonKey(name: 'submitted_by_username')  String? submittedByUsername, @JsonKey(name: 'reviewer_notes')  String reviewerNotes, @JsonKey(name: 'rejection_reason')  String rejectionReason, @JsonKey(name: 'reviewed_by_username')  String? reviewedByUsername, @JsonKey(name: 'reviewed_at')  String? reviewedAt, @JsonKey(name: 'created_at')  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PortalStationApplication() when $default != null:
return $default(_that.id,_that.shop,_that.shopHandle,_that.gym,_that.gymHandle,_that.status,_that.businessRegistrationNumber,_that.contactPhone,_that.address,_that.city,_that.country,_that.latitude,_that.longitude,_that.openingHours,_that.documents,_that.agreedToPolicy,_that.submittedByUsername,_that.reviewerNotes,_that.rejectionReason,_that.reviewedByUsername,_that.reviewedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? shop, @JsonKey(name: 'shop_handle')  String? shopHandle,  String? gym, @JsonKey(name: 'gym_handle')  String? gymHandle,  String status, @JsonKey(name: 'business_registration_number')  String businessRegistrationNumber, @JsonKey(name: 'contact_phone')  String contactPhone,  String address,  String city,  String country, @JsonKey(fromJson: _optDouble)  double? latitude, @JsonKey(fromJson: _optDouble)  double? longitude, @JsonKey(name: 'opening_hours')  Map<String, dynamic> openingHours, @JsonKey(name: 'documents')  List<Map<String, dynamic>> documents, @JsonKey(name: 'agreed_to_policy')  bool agreedToPolicy, @JsonKey(name: 'submitted_by_username')  String? submittedByUsername, @JsonKey(name: 'reviewer_notes')  String reviewerNotes, @JsonKey(name: 'rejection_reason')  String rejectionReason, @JsonKey(name: 'reviewed_by_username')  String? reviewedByUsername, @JsonKey(name: 'reviewed_at')  String? reviewedAt, @JsonKey(name: 'created_at')  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _PortalStationApplication():
return $default(_that.id,_that.shop,_that.shopHandle,_that.gym,_that.gymHandle,_that.status,_that.businessRegistrationNumber,_that.contactPhone,_that.address,_that.city,_that.country,_that.latitude,_that.longitude,_that.openingHours,_that.documents,_that.agreedToPolicy,_that.submittedByUsername,_that.reviewerNotes,_that.rejectionReason,_that.reviewedByUsername,_that.reviewedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? shop, @JsonKey(name: 'shop_handle')  String? shopHandle,  String? gym, @JsonKey(name: 'gym_handle')  String? gymHandle,  String status, @JsonKey(name: 'business_registration_number')  String businessRegistrationNumber, @JsonKey(name: 'contact_phone')  String contactPhone,  String address,  String city,  String country, @JsonKey(fromJson: _optDouble)  double? latitude, @JsonKey(fromJson: _optDouble)  double? longitude, @JsonKey(name: 'opening_hours')  Map<String, dynamic> openingHours, @JsonKey(name: 'documents')  List<Map<String, dynamic>> documents, @JsonKey(name: 'agreed_to_policy')  bool agreedToPolicy, @JsonKey(name: 'submitted_by_username')  String? submittedByUsername, @JsonKey(name: 'reviewer_notes')  String reviewerNotes, @JsonKey(name: 'rejection_reason')  String rejectionReason, @JsonKey(name: 'reviewed_by_username')  String? reviewedByUsername, @JsonKey(name: 'reviewed_at')  String? reviewedAt, @JsonKey(name: 'created_at')  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _PortalStationApplication() when $default != null:
return $default(_that.id,_that.shop,_that.shopHandle,_that.gym,_that.gymHandle,_that.status,_that.businessRegistrationNumber,_that.contactPhone,_that.address,_that.city,_that.country,_that.latitude,_that.longitude,_that.openingHours,_that.documents,_that.agreedToPolicy,_that.submittedByUsername,_that.reviewerNotes,_that.rejectionReason,_that.reviewedByUsername,_that.reviewedAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PortalStationApplication implements PortalStationApplication {
  const _PortalStationApplication({required this.id, this.shop, @JsonKey(name: 'shop_handle') this.shopHandle, this.gym, @JsonKey(name: 'gym_handle') this.gymHandle, this.status = 'draft', @JsonKey(name: 'business_registration_number') this.businessRegistrationNumber = '', @JsonKey(name: 'contact_phone') this.contactPhone = '', this.address = '', this.city = '', this.country = '', @JsonKey(fromJson: _optDouble) this.latitude, @JsonKey(fromJson: _optDouble) this.longitude, @JsonKey(name: 'opening_hours') final  Map<String, dynamic> openingHours = const <String, dynamic>{}, @JsonKey(name: 'documents') final  List<Map<String, dynamic>> documents = const <Map<String, dynamic>>[], @JsonKey(name: 'agreed_to_policy') this.agreedToPolicy = false, @JsonKey(name: 'submitted_by_username') this.submittedByUsername, @JsonKey(name: 'reviewer_notes') this.reviewerNotes = '', @JsonKey(name: 'rejection_reason') this.rejectionReason = '', @JsonKey(name: 'reviewed_by_username') this.reviewedByUsername, @JsonKey(name: 'reviewed_at') this.reviewedAt, @JsonKey(name: 'created_at') this.createdAt}): _openingHours = openingHours,_documents = documents;
  factory _PortalStationApplication.fromJson(Map<String, dynamic> json) => _$PortalStationApplicationFromJson(json);

@override final  String id;
@override final  String? shop;
@override@JsonKey(name: 'shop_handle') final  String? shopHandle;
@override final  String? gym;
@override@JsonKey(name: 'gym_handle') final  String? gymHandle;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'business_registration_number') final  String businessRegistrationNumber;
@override@JsonKey(name: 'contact_phone') final  String contactPhone;
@override@JsonKey() final  String address;
@override@JsonKey() final  String city;
@override@JsonKey() final  String country;
@override@JsonKey(fromJson: _optDouble) final  double? latitude;
@override@JsonKey(fromJson: _optDouble) final  double? longitude;
 final  Map<String, dynamic> _openingHours;
@override@JsonKey(name: 'opening_hours') Map<String, dynamic> get openingHours {
  if (_openingHours is EqualUnmodifiableMapView) return _openingHours;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_openingHours);
}

 final  List<Map<String, dynamic>> _documents;
@override@JsonKey(name: 'documents') List<Map<String, dynamic>> get documents {
  if (_documents is EqualUnmodifiableListView) return _documents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_documents);
}

@override@JsonKey(name: 'agreed_to_policy') final  bool agreedToPolicy;
@override@JsonKey(name: 'submitted_by_username') final  String? submittedByUsername;
@override@JsonKey(name: 'reviewer_notes') final  String reviewerNotes;
@override@JsonKey(name: 'rejection_reason') final  String rejectionReason;
@override@JsonKey(name: 'reviewed_by_username') final  String? reviewedByUsername;
@override@JsonKey(name: 'reviewed_at') final  String? reviewedAt;
@override@JsonKey(name: 'created_at') final  String? createdAt;

/// Create a copy of PortalStationApplication
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PortalStationApplicationCopyWith<_PortalStationApplication> get copyWith => __$PortalStationApplicationCopyWithImpl<_PortalStationApplication>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PortalStationApplicationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PortalStationApplication&&(identical(other.id, id) || other.id == id)&&(identical(other.shop, shop) || other.shop == shop)&&(identical(other.shopHandle, shopHandle) || other.shopHandle == shopHandle)&&(identical(other.gym, gym) || other.gym == gym)&&(identical(other.gymHandle, gymHandle) || other.gymHandle == gymHandle)&&(identical(other.status, status) || other.status == status)&&(identical(other.businessRegistrationNumber, businessRegistrationNumber) || other.businessRegistrationNumber == businessRegistrationNumber)&&(identical(other.contactPhone, contactPhone) || other.contactPhone == contactPhone)&&(identical(other.address, address) || other.address == address)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&const DeepCollectionEquality().equals(other._openingHours, _openingHours)&&const DeepCollectionEquality().equals(other._documents, _documents)&&(identical(other.agreedToPolicy, agreedToPolicy) || other.agreedToPolicy == agreedToPolicy)&&(identical(other.submittedByUsername, submittedByUsername) || other.submittedByUsername == submittedByUsername)&&(identical(other.reviewerNotes, reviewerNotes) || other.reviewerNotes == reviewerNotes)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.reviewedByUsername, reviewedByUsername) || other.reviewedByUsername == reviewedByUsername)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,shop,shopHandle,gym,gymHandle,status,businessRegistrationNumber,contactPhone,address,city,country,latitude,longitude,const DeepCollectionEquality().hash(_openingHours),const DeepCollectionEquality().hash(_documents),agreedToPolicy,submittedByUsername,reviewerNotes,rejectionReason,reviewedByUsername,reviewedAt,createdAt]);

@override
String toString() {
  return 'PortalStationApplication(id: $id, shop: $shop, shopHandle: $shopHandle, gym: $gym, gymHandle: $gymHandle, status: $status, businessRegistrationNumber: $businessRegistrationNumber, contactPhone: $contactPhone, address: $address, city: $city, country: $country, latitude: $latitude, longitude: $longitude, openingHours: $openingHours, documents: $documents, agreedToPolicy: $agreedToPolicy, submittedByUsername: $submittedByUsername, reviewerNotes: $reviewerNotes, rejectionReason: $rejectionReason, reviewedByUsername: $reviewedByUsername, reviewedAt: $reviewedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PortalStationApplicationCopyWith<$Res> implements $PortalStationApplicationCopyWith<$Res> {
  factory _$PortalStationApplicationCopyWith(_PortalStationApplication value, $Res Function(_PortalStationApplication) _then) = __$PortalStationApplicationCopyWithImpl;
@override @useResult
$Res call({
 String id, String? shop,@JsonKey(name: 'shop_handle') String? shopHandle, String? gym,@JsonKey(name: 'gym_handle') String? gymHandle, String status,@JsonKey(name: 'business_registration_number') String businessRegistrationNumber,@JsonKey(name: 'contact_phone') String contactPhone, String address, String city, String country,@JsonKey(fromJson: _optDouble) double? latitude,@JsonKey(fromJson: _optDouble) double? longitude,@JsonKey(name: 'opening_hours') Map<String, dynamic> openingHours,@JsonKey(name: 'documents') List<Map<String, dynamic>> documents,@JsonKey(name: 'agreed_to_policy') bool agreedToPolicy,@JsonKey(name: 'submitted_by_username') String? submittedByUsername,@JsonKey(name: 'reviewer_notes') String reviewerNotes,@JsonKey(name: 'rejection_reason') String rejectionReason,@JsonKey(name: 'reviewed_by_username') String? reviewedByUsername,@JsonKey(name: 'reviewed_at') String? reviewedAt,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class __$PortalStationApplicationCopyWithImpl<$Res>
    implements _$PortalStationApplicationCopyWith<$Res> {
  __$PortalStationApplicationCopyWithImpl(this._self, this._then);

  final _PortalStationApplication _self;
  final $Res Function(_PortalStationApplication) _then;

/// Create a copy of PortalStationApplication
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? shop = freezed,Object? shopHandle = freezed,Object? gym = freezed,Object? gymHandle = freezed,Object? status = null,Object? businessRegistrationNumber = null,Object? contactPhone = null,Object? address = null,Object? city = null,Object? country = null,Object? latitude = freezed,Object? longitude = freezed,Object? openingHours = null,Object? documents = null,Object? agreedToPolicy = null,Object? submittedByUsername = freezed,Object? reviewerNotes = null,Object? rejectionReason = null,Object? reviewedByUsername = freezed,Object? reviewedAt = freezed,Object? createdAt = freezed,}) {
  return _then(_PortalStationApplication(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shop: freezed == shop ? _self.shop : shop // ignore: cast_nullable_to_non_nullable
as String?,shopHandle: freezed == shopHandle ? _self.shopHandle : shopHandle // ignore: cast_nullable_to_non_nullable
as String?,gym: freezed == gym ? _self.gym : gym // ignore: cast_nullable_to_non_nullable
as String?,gymHandle: freezed == gymHandle ? _self.gymHandle : gymHandle // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,businessRegistrationNumber: null == businessRegistrationNumber ? _self.businessRegistrationNumber : businessRegistrationNumber // ignore: cast_nullable_to_non_nullable
as String,contactPhone: null == contactPhone ? _self.contactPhone : contactPhone // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,openingHours: null == openingHours ? _self._openingHours : openingHours // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,documents: null == documents ? _self._documents : documents // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,agreedToPolicy: null == agreedToPolicy ? _self.agreedToPolicy : agreedToPolicy // ignore: cast_nullable_to_non_nullable
as bool,submittedByUsername: freezed == submittedByUsername ? _self.submittedByUsername : submittedByUsername // ignore: cast_nullable_to_non_nullable
as String?,reviewerNotes: null == reviewerNotes ? _self.reviewerNotes : reviewerNotes // ignore: cast_nullable_to_non_nullable
as String,rejectionReason: null == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String,reviewedByUsername: freezed == reviewedByUsername ? _self.reviewedByUsername : reviewedByUsername // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PortalDeliveryPersonnel {

 String get id;@JsonKey(name: 'username') String get username;@JsonKey(name: 'display_name') String get displayName; String? get email;@JsonKey(name: 'vehicle_type') String get vehicleType;@JsonKey(name: 'service_zones') List<String> get serviceZones;@JsonKey(name: 'is_active') bool get isActive;@JsonKey(name: 'rating', fromJson: _optDouble) double? get rating;@JsonKey(name: 'bio') String get bio;@JsonKey(name: 'active_order_count') int get activeOrderCount;@JsonKey(name: 'created_at') String? get createdAt;
/// Create a copy of PortalDeliveryPersonnel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PortalDeliveryPersonnelCopyWith<PortalDeliveryPersonnel> get copyWith => _$PortalDeliveryPersonnelCopyWithImpl<PortalDeliveryPersonnel>(this as PortalDeliveryPersonnel, _$identity);

  /// Serializes this PortalDeliveryPersonnel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PortalDeliveryPersonnel&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.email, email) || other.email == email)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&const DeepCollectionEquality().equals(other.serviceZones, serviceZones)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.activeOrderCount, activeOrderCount) || other.activeOrderCount == activeOrderCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,displayName,email,vehicleType,const DeepCollectionEquality().hash(serviceZones),isActive,rating,bio,activeOrderCount,createdAt);

@override
String toString() {
  return 'PortalDeliveryPersonnel(id: $id, username: $username, displayName: $displayName, email: $email, vehicleType: $vehicleType, serviceZones: $serviceZones, isActive: $isActive, rating: $rating, bio: $bio, activeOrderCount: $activeOrderCount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PortalDeliveryPersonnelCopyWith<$Res>  {
  factory $PortalDeliveryPersonnelCopyWith(PortalDeliveryPersonnel value, $Res Function(PortalDeliveryPersonnel) _then) = _$PortalDeliveryPersonnelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'username') String username,@JsonKey(name: 'display_name') String displayName, String? email,@JsonKey(name: 'vehicle_type') String vehicleType,@JsonKey(name: 'service_zones') List<String> serviceZones,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'rating', fromJson: _optDouble) double? rating,@JsonKey(name: 'bio') String bio,@JsonKey(name: 'active_order_count') int activeOrderCount,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class _$PortalDeliveryPersonnelCopyWithImpl<$Res>
    implements $PortalDeliveryPersonnelCopyWith<$Res> {
  _$PortalDeliveryPersonnelCopyWithImpl(this._self, this._then);

  final PortalDeliveryPersonnel _self;
  final $Res Function(PortalDeliveryPersonnel) _then;

/// Create a copy of PortalDeliveryPersonnel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = null,Object? displayName = null,Object? email = freezed,Object? vehicleType = null,Object? serviceZones = null,Object? isActive = null,Object? rating = freezed,Object? bio = null,Object? activeOrderCount = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as String,serviceZones: null == serviceZones ? _self.serviceZones : serviceZones // ignore: cast_nullable_to_non_nullable
as List<String>,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,activeOrderCount: null == activeOrderCount ? _self.activeOrderCount : activeOrderCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PortalDeliveryPersonnel].
extension PortalDeliveryPersonnelPatterns on PortalDeliveryPersonnel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PortalDeliveryPersonnel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PortalDeliveryPersonnel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PortalDeliveryPersonnel value)  $default,){
final _that = this;
switch (_that) {
case _PortalDeliveryPersonnel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PortalDeliveryPersonnel value)?  $default,){
final _that = this;
switch (_that) {
case _PortalDeliveryPersonnel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'username')  String username, @JsonKey(name: 'display_name')  String displayName,  String? email, @JsonKey(name: 'vehicle_type')  String vehicleType, @JsonKey(name: 'service_zones')  List<String> serviceZones, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'rating', fromJson: _optDouble)  double? rating, @JsonKey(name: 'bio')  String bio, @JsonKey(name: 'active_order_count')  int activeOrderCount, @JsonKey(name: 'created_at')  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PortalDeliveryPersonnel() when $default != null:
return $default(_that.id,_that.username,_that.displayName,_that.email,_that.vehicleType,_that.serviceZones,_that.isActive,_that.rating,_that.bio,_that.activeOrderCount,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'username')  String username, @JsonKey(name: 'display_name')  String displayName,  String? email, @JsonKey(name: 'vehicle_type')  String vehicleType, @JsonKey(name: 'service_zones')  List<String> serviceZones, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'rating', fromJson: _optDouble)  double? rating, @JsonKey(name: 'bio')  String bio, @JsonKey(name: 'active_order_count')  int activeOrderCount, @JsonKey(name: 'created_at')  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _PortalDeliveryPersonnel():
return $default(_that.id,_that.username,_that.displayName,_that.email,_that.vehicleType,_that.serviceZones,_that.isActive,_that.rating,_that.bio,_that.activeOrderCount,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'username')  String username, @JsonKey(name: 'display_name')  String displayName,  String? email, @JsonKey(name: 'vehicle_type')  String vehicleType, @JsonKey(name: 'service_zones')  List<String> serviceZones, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'rating', fromJson: _optDouble)  double? rating, @JsonKey(name: 'bio')  String bio, @JsonKey(name: 'active_order_count')  int activeOrderCount, @JsonKey(name: 'created_at')  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _PortalDeliveryPersonnel() when $default != null:
return $default(_that.id,_that.username,_that.displayName,_that.email,_that.vehicleType,_that.serviceZones,_that.isActive,_that.rating,_that.bio,_that.activeOrderCount,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PortalDeliveryPersonnel implements PortalDeliveryPersonnel {
  const _PortalDeliveryPersonnel({required this.id, @JsonKey(name: 'username') this.username = '', @JsonKey(name: 'display_name') this.displayName = '', this.email, @JsonKey(name: 'vehicle_type') this.vehicleType = 'bike', @JsonKey(name: 'service_zones') final  List<String> serviceZones = const <String>[], @JsonKey(name: 'is_active') this.isActive = true, @JsonKey(name: 'rating', fromJson: _optDouble) this.rating, @JsonKey(name: 'bio') this.bio = '', @JsonKey(name: 'active_order_count') this.activeOrderCount = 0, @JsonKey(name: 'created_at') this.createdAt}): _serviceZones = serviceZones;
  factory _PortalDeliveryPersonnel.fromJson(Map<String, dynamic> json) => _$PortalDeliveryPersonnelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'username') final  String username;
@override@JsonKey(name: 'display_name') final  String displayName;
@override final  String? email;
@override@JsonKey(name: 'vehicle_type') final  String vehicleType;
 final  List<String> _serviceZones;
@override@JsonKey(name: 'service_zones') List<String> get serviceZones {
  if (_serviceZones is EqualUnmodifiableListView) return _serviceZones;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_serviceZones);
}

@override@JsonKey(name: 'is_active') final  bool isActive;
@override@JsonKey(name: 'rating', fromJson: _optDouble) final  double? rating;
@override@JsonKey(name: 'bio') final  String bio;
@override@JsonKey(name: 'active_order_count') final  int activeOrderCount;
@override@JsonKey(name: 'created_at') final  String? createdAt;

/// Create a copy of PortalDeliveryPersonnel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PortalDeliveryPersonnelCopyWith<_PortalDeliveryPersonnel> get copyWith => __$PortalDeliveryPersonnelCopyWithImpl<_PortalDeliveryPersonnel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PortalDeliveryPersonnelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PortalDeliveryPersonnel&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.email, email) || other.email == email)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&const DeepCollectionEquality().equals(other._serviceZones, _serviceZones)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.activeOrderCount, activeOrderCount) || other.activeOrderCount == activeOrderCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,displayName,email,vehicleType,const DeepCollectionEquality().hash(_serviceZones),isActive,rating,bio,activeOrderCount,createdAt);

@override
String toString() {
  return 'PortalDeliveryPersonnel(id: $id, username: $username, displayName: $displayName, email: $email, vehicleType: $vehicleType, serviceZones: $serviceZones, isActive: $isActive, rating: $rating, bio: $bio, activeOrderCount: $activeOrderCount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PortalDeliveryPersonnelCopyWith<$Res> implements $PortalDeliveryPersonnelCopyWith<$Res> {
  factory _$PortalDeliveryPersonnelCopyWith(_PortalDeliveryPersonnel value, $Res Function(_PortalDeliveryPersonnel) _then) = __$PortalDeliveryPersonnelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'username') String username,@JsonKey(name: 'display_name') String displayName, String? email,@JsonKey(name: 'vehicle_type') String vehicleType,@JsonKey(name: 'service_zones') List<String> serviceZones,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'rating', fromJson: _optDouble) double? rating,@JsonKey(name: 'bio') String bio,@JsonKey(name: 'active_order_count') int activeOrderCount,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class __$PortalDeliveryPersonnelCopyWithImpl<$Res>
    implements _$PortalDeliveryPersonnelCopyWith<$Res> {
  __$PortalDeliveryPersonnelCopyWithImpl(this._self, this._then);

  final _PortalDeliveryPersonnel _self;
  final $Res Function(_PortalDeliveryPersonnel) _then;

/// Create a copy of PortalDeliveryPersonnel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = null,Object? displayName = null,Object? email = freezed,Object? vehicleType = null,Object? serviceZones = null,Object? isActive = null,Object? rating = freezed,Object? bio = null,Object? activeOrderCount = null,Object? createdAt = freezed,}) {
  return _then(_PortalDeliveryPersonnel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as String,serviceZones: null == serviceZones ? _self._serviceZones : serviceZones // ignore: cast_nullable_to_non_nullable
as List<String>,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,activeOrderCount: null == activeOrderCount ? _self.activeOrderCount : activeOrderCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PortalDeliveryApplication {

 String get id; String? get profile;@JsonKey(name: 'username') String get username;@JsonKey(name: 'display_name') String get displayName;@JsonKey(name: 'vehicle_type') String get vehicleType;@JsonKey(name: 'service_zones') List<String> get serviceZones;@JsonKey(name: 'id_document_url') String get idDocumentUrl;@JsonKey(name: 'licence_document_url') String get licenceDocumentUrl; String get phone; String get bio; String get status;@JsonKey(name: 'reviewer_notes') String get reviewerNotes;@JsonKey(name: 'rejection_reason') String get rejectionReason;@JsonKey(name: 'reviewed_by_username') String? get reviewedByUsername;@JsonKey(name: 'reviewed_at') String? get reviewedAt;@JsonKey(name: 'created_at') String? get createdAt;
/// Create a copy of PortalDeliveryApplication
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PortalDeliveryApplicationCopyWith<PortalDeliveryApplication> get copyWith => _$PortalDeliveryApplicationCopyWithImpl<PortalDeliveryApplication>(this as PortalDeliveryApplication, _$identity);

  /// Serializes this PortalDeliveryApplication to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PortalDeliveryApplication&&(identical(other.id, id) || other.id == id)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&const DeepCollectionEquality().equals(other.serviceZones, serviceZones)&&(identical(other.idDocumentUrl, idDocumentUrl) || other.idDocumentUrl == idDocumentUrl)&&(identical(other.licenceDocumentUrl, licenceDocumentUrl) || other.licenceDocumentUrl == licenceDocumentUrl)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.status, status) || other.status == status)&&(identical(other.reviewerNotes, reviewerNotes) || other.reviewerNotes == reviewerNotes)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.reviewedByUsername, reviewedByUsername) || other.reviewedByUsername == reviewedByUsername)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,profile,username,displayName,vehicleType,const DeepCollectionEquality().hash(serviceZones),idDocumentUrl,licenceDocumentUrl,phone,bio,status,reviewerNotes,rejectionReason,reviewedByUsername,reviewedAt,createdAt);

@override
String toString() {
  return 'PortalDeliveryApplication(id: $id, profile: $profile, username: $username, displayName: $displayName, vehicleType: $vehicleType, serviceZones: $serviceZones, idDocumentUrl: $idDocumentUrl, licenceDocumentUrl: $licenceDocumentUrl, phone: $phone, bio: $bio, status: $status, reviewerNotes: $reviewerNotes, rejectionReason: $rejectionReason, reviewedByUsername: $reviewedByUsername, reviewedAt: $reviewedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PortalDeliveryApplicationCopyWith<$Res>  {
  factory $PortalDeliveryApplicationCopyWith(PortalDeliveryApplication value, $Res Function(PortalDeliveryApplication) _then) = _$PortalDeliveryApplicationCopyWithImpl;
@useResult
$Res call({
 String id, String? profile,@JsonKey(name: 'username') String username,@JsonKey(name: 'display_name') String displayName,@JsonKey(name: 'vehicle_type') String vehicleType,@JsonKey(name: 'service_zones') List<String> serviceZones,@JsonKey(name: 'id_document_url') String idDocumentUrl,@JsonKey(name: 'licence_document_url') String licenceDocumentUrl, String phone, String bio, String status,@JsonKey(name: 'reviewer_notes') String reviewerNotes,@JsonKey(name: 'rejection_reason') String rejectionReason,@JsonKey(name: 'reviewed_by_username') String? reviewedByUsername,@JsonKey(name: 'reviewed_at') String? reviewedAt,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class _$PortalDeliveryApplicationCopyWithImpl<$Res>
    implements $PortalDeliveryApplicationCopyWith<$Res> {
  _$PortalDeliveryApplicationCopyWithImpl(this._self, this._then);

  final PortalDeliveryApplication _self;
  final $Res Function(PortalDeliveryApplication) _then;

/// Create a copy of PortalDeliveryApplication
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? profile = freezed,Object? username = null,Object? displayName = null,Object? vehicleType = null,Object? serviceZones = null,Object? idDocumentUrl = null,Object? licenceDocumentUrl = null,Object? phone = null,Object? bio = null,Object? status = null,Object? reviewerNotes = null,Object? rejectionReason = null,Object? reviewedByUsername = freezed,Object? reviewedAt = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as String?,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as String,serviceZones: null == serviceZones ? _self.serviceZones : serviceZones // ignore: cast_nullable_to_non_nullable
as List<String>,idDocumentUrl: null == idDocumentUrl ? _self.idDocumentUrl : idDocumentUrl // ignore: cast_nullable_to_non_nullable
as String,licenceDocumentUrl: null == licenceDocumentUrl ? _self.licenceDocumentUrl : licenceDocumentUrl // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,reviewerNotes: null == reviewerNotes ? _self.reviewerNotes : reviewerNotes // ignore: cast_nullable_to_non_nullable
as String,rejectionReason: null == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String,reviewedByUsername: freezed == reviewedByUsername ? _self.reviewedByUsername : reviewedByUsername // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PortalDeliveryApplication].
extension PortalDeliveryApplicationPatterns on PortalDeliveryApplication {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PortalDeliveryApplication value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PortalDeliveryApplication() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PortalDeliveryApplication value)  $default,){
final _that = this;
switch (_that) {
case _PortalDeliveryApplication():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PortalDeliveryApplication value)?  $default,){
final _that = this;
switch (_that) {
case _PortalDeliveryApplication() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? profile, @JsonKey(name: 'username')  String username, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'vehicle_type')  String vehicleType, @JsonKey(name: 'service_zones')  List<String> serviceZones, @JsonKey(name: 'id_document_url')  String idDocumentUrl, @JsonKey(name: 'licence_document_url')  String licenceDocumentUrl,  String phone,  String bio,  String status, @JsonKey(name: 'reviewer_notes')  String reviewerNotes, @JsonKey(name: 'rejection_reason')  String rejectionReason, @JsonKey(name: 'reviewed_by_username')  String? reviewedByUsername, @JsonKey(name: 'reviewed_at')  String? reviewedAt, @JsonKey(name: 'created_at')  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PortalDeliveryApplication() when $default != null:
return $default(_that.id,_that.profile,_that.username,_that.displayName,_that.vehicleType,_that.serviceZones,_that.idDocumentUrl,_that.licenceDocumentUrl,_that.phone,_that.bio,_that.status,_that.reviewerNotes,_that.rejectionReason,_that.reviewedByUsername,_that.reviewedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? profile, @JsonKey(name: 'username')  String username, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'vehicle_type')  String vehicleType, @JsonKey(name: 'service_zones')  List<String> serviceZones, @JsonKey(name: 'id_document_url')  String idDocumentUrl, @JsonKey(name: 'licence_document_url')  String licenceDocumentUrl,  String phone,  String bio,  String status, @JsonKey(name: 'reviewer_notes')  String reviewerNotes, @JsonKey(name: 'rejection_reason')  String rejectionReason, @JsonKey(name: 'reviewed_by_username')  String? reviewedByUsername, @JsonKey(name: 'reviewed_at')  String? reviewedAt, @JsonKey(name: 'created_at')  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _PortalDeliveryApplication():
return $default(_that.id,_that.profile,_that.username,_that.displayName,_that.vehicleType,_that.serviceZones,_that.idDocumentUrl,_that.licenceDocumentUrl,_that.phone,_that.bio,_that.status,_that.reviewerNotes,_that.rejectionReason,_that.reviewedByUsername,_that.reviewedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? profile, @JsonKey(name: 'username')  String username, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'vehicle_type')  String vehicleType, @JsonKey(name: 'service_zones')  List<String> serviceZones, @JsonKey(name: 'id_document_url')  String idDocumentUrl, @JsonKey(name: 'licence_document_url')  String licenceDocumentUrl,  String phone,  String bio,  String status, @JsonKey(name: 'reviewer_notes')  String reviewerNotes, @JsonKey(name: 'rejection_reason')  String rejectionReason, @JsonKey(name: 'reviewed_by_username')  String? reviewedByUsername, @JsonKey(name: 'reviewed_at')  String? reviewedAt, @JsonKey(name: 'created_at')  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _PortalDeliveryApplication() when $default != null:
return $default(_that.id,_that.profile,_that.username,_that.displayName,_that.vehicleType,_that.serviceZones,_that.idDocumentUrl,_that.licenceDocumentUrl,_that.phone,_that.bio,_that.status,_that.reviewerNotes,_that.rejectionReason,_that.reviewedByUsername,_that.reviewedAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PortalDeliveryApplication implements PortalDeliveryApplication {
  const _PortalDeliveryApplication({required this.id, this.profile, @JsonKey(name: 'username') this.username = '', @JsonKey(name: 'display_name') this.displayName = '', @JsonKey(name: 'vehicle_type') this.vehicleType = 'bike', @JsonKey(name: 'service_zones') final  List<String> serviceZones = const <String>[], @JsonKey(name: 'id_document_url') this.idDocumentUrl = '', @JsonKey(name: 'licence_document_url') this.licenceDocumentUrl = '', this.phone = '', this.bio = '', this.status = 'draft', @JsonKey(name: 'reviewer_notes') this.reviewerNotes = '', @JsonKey(name: 'rejection_reason') this.rejectionReason = '', @JsonKey(name: 'reviewed_by_username') this.reviewedByUsername, @JsonKey(name: 'reviewed_at') this.reviewedAt, @JsonKey(name: 'created_at') this.createdAt}): _serviceZones = serviceZones;
  factory _PortalDeliveryApplication.fromJson(Map<String, dynamic> json) => _$PortalDeliveryApplicationFromJson(json);

@override final  String id;
@override final  String? profile;
@override@JsonKey(name: 'username') final  String username;
@override@JsonKey(name: 'display_name') final  String displayName;
@override@JsonKey(name: 'vehicle_type') final  String vehicleType;
 final  List<String> _serviceZones;
@override@JsonKey(name: 'service_zones') List<String> get serviceZones {
  if (_serviceZones is EqualUnmodifiableListView) return _serviceZones;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_serviceZones);
}

@override@JsonKey(name: 'id_document_url') final  String idDocumentUrl;
@override@JsonKey(name: 'licence_document_url') final  String licenceDocumentUrl;
@override@JsonKey() final  String phone;
@override@JsonKey() final  String bio;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'reviewer_notes') final  String reviewerNotes;
@override@JsonKey(name: 'rejection_reason') final  String rejectionReason;
@override@JsonKey(name: 'reviewed_by_username') final  String? reviewedByUsername;
@override@JsonKey(name: 'reviewed_at') final  String? reviewedAt;
@override@JsonKey(name: 'created_at') final  String? createdAt;

/// Create a copy of PortalDeliveryApplication
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PortalDeliveryApplicationCopyWith<_PortalDeliveryApplication> get copyWith => __$PortalDeliveryApplicationCopyWithImpl<_PortalDeliveryApplication>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PortalDeliveryApplicationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PortalDeliveryApplication&&(identical(other.id, id) || other.id == id)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&const DeepCollectionEquality().equals(other._serviceZones, _serviceZones)&&(identical(other.idDocumentUrl, idDocumentUrl) || other.idDocumentUrl == idDocumentUrl)&&(identical(other.licenceDocumentUrl, licenceDocumentUrl) || other.licenceDocumentUrl == licenceDocumentUrl)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.status, status) || other.status == status)&&(identical(other.reviewerNotes, reviewerNotes) || other.reviewerNotes == reviewerNotes)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.reviewedByUsername, reviewedByUsername) || other.reviewedByUsername == reviewedByUsername)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,profile,username,displayName,vehicleType,const DeepCollectionEquality().hash(_serviceZones),idDocumentUrl,licenceDocumentUrl,phone,bio,status,reviewerNotes,rejectionReason,reviewedByUsername,reviewedAt,createdAt);

@override
String toString() {
  return 'PortalDeliveryApplication(id: $id, profile: $profile, username: $username, displayName: $displayName, vehicleType: $vehicleType, serviceZones: $serviceZones, idDocumentUrl: $idDocumentUrl, licenceDocumentUrl: $licenceDocumentUrl, phone: $phone, bio: $bio, status: $status, reviewerNotes: $reviewerNotes, rejectionReason: $rejectionReason, reviewedByUsername: $reviewedByUsername, reviewedAt: $reviewedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PortalDeliveryApplicationCopyWith<$Res> implements $PortalDeliveryApplicationCopyWith<$Res> {
  factory _$PortalDeliveryApplicationCopyWith(_PortalDeliveryApplication value, $Res Function(_PortalDeliveryApplication) _then) = __$PortalDeliveryApplicationCopyWithImpl;
@override @useResult
$Res call({
 String id, String? profile,@JsonKey(name: 'username') String username,@JsonKey(name: 'display_name') String displayName,@JsonKey(name: 'vehicle_type') String vehicleType,@JsonKey(name: 'service_zones') List<String> serviceZones,@JsonKey(name: 'id_document_url') String idDocumentUrl,@JsonKey(name: 'licence_document_url') String licenceDocumentUrl, String phone, String bio, String status,@JsonKey(name: 'reviewer_notes') String reviewerNotes,@JsonKey(name: 'rejection_reason') String rejectionReason,@JsonKey(name: 'reviewed_by_username') String? reviewedByUsername,@JsonKey(name: 'reviewed_at') String? reviewedAt,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class __$PortalDeliveryApplicationCopyWithImpl<$Res>
    implements _$PortalDeliveryApplicationCopyWith<$Res> {
  __$PortalDeliveryApplicationCopyWithImpl(this._self, this._then);

  final _PortalDeliveryApplication _self;
  final $Res Function(_PortalDeliveryApplication) _then;

/// Create a copy of PortalDeliveryApplication
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? profile = freezed,Object? username = null,Object? displayName = null,Object? vehicleType = null,Object? serviceZones = null,Object? idDocumentUrl = null,Object? licenceDocumentUrl = null,Object? phone = null,Object? bio = null,Object? status = null,Object? reviewerNotes = null,Object? rejectionReason = null,Object? reviewedByUsername = freezed,Object? reviewedAt = freezed,Object? createdAt = freezed,}) {
  return _then(_PortalDeliveryApplication(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as String?,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as String,serviceZones: null == serviceZones ? _self._serviceZones : serviceZones // ignore: cast_nullable_to_non_nullable
as List<String>,idDocumentUrl: null == idDocumentUrl ? _self.idDocumentUrl : idDocumentUrl // ignore: cast_nullable_to_non_nullable
as String,licenceDocumentUrl: null == licenceDocumentUrl ? _self.licenceDocumentUrl : licenceDocumentUrl // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,reviewerNotes: null == reviewerNotes ? _self.reviewerNotes : reviewerNotes // ignore: cast_nullable_to_non_nullable
as String,rejectionReason: null == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String,reviewedByUsername: freezed == reviewedByUsername ? _self.reviewedByUsername : reviewedByUsername // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PortalTransaction {

 String get id;@JsonKey(name: 'tx_ref') String get txRef;@JsonKey(name: 'transaction_type') String get transactionType; String get direction; String get status;@JsonKey(name: 'artifact_type') String get artifactType; int get quantity;@JsonKey(name: 'user_username') String get userUsername;@JsonKey(name: 'user_email') String get userEmail;@JsonKey(name: 'counterparty_username') String? get counterpartyUsername;@JsonKey(name: 'reference_id') String get referenceId;@JsonKey(name: 'fiat_amount', fromJson: _optNumText) String? get fiatAmount;@JsonKey(name: 'fiat_currency') String get fiatCurrency;@JsonKey(name: 'payment_provider') String get paymentProvider;@JsonKey(name: 'flutterwave_id') String get flutterwaveId;@JsonKey(name: 'phone_number') String get phoneNumber;@JsonKey(name: 'bank_account') String get bankAccount; String get description;@JsonKey(name: 'journal_entry') String? get journalEntry;@JsonKey(name: 'clearance_at') String? get clearanceAt;@JsonKey(name: 'created_at') String? get createdAt;
/// Create a copy of PortalTransaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PortalTransactionCopyWith<PortalTransaction> get copyWith => _$PortalTransactionCopyWithImpl<PortalTransaction>(this as PortalTransaction, _$identity);

  /// Serializes this PortalTransaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PortalTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.txRef, txRef) || other.txRef == txRef)&&(identical(other.transactionType, transactionType) || other.transactionType == transactionType)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.status, status) || other.status == status)&&(identical(other.artifactType, artifactType) || other.artifactType == artifactType)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.userUsername, userUsername) || other.userUsername == userUsername)&&(identical(other.userEmail, userEmail) || other.userEmail == userEmail)&&(identical(other.counterpartyUsername, counterpartyUsername) || other.counterpartyUsername == counterpartyUsername)&&(identical(other.referenceId, referenceId) || other.referenceId == referenceId)&&(identical(other.fiatAmount, fiatAmount) || other.fiatAmount == fiatAmount)&&(identical(other.fiatCurrency, fiatCurrency) || other.fiatCurrency == fiatCurrency)&&(identical(other.paymentProvider, paymentProvider) || other.paymentProvider == paymentProvider)&&(identical(other.flutterwaveId, flutterwaveId) || other.flutterwaveId == flutterwaveId)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.bankAccount, bankAccount) || other.bankAccount == bankAccount)&&(identical(other.description, description) || other.description == description)&&(identical(other.journalEntry, journalEntry) || other.journalEntry == journalEntry)&&(identical(other.clearanceAt, clearanceAt) || other.clearanceAt == clearanceAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,txRef,transactionType,direction,status,artifactType,quantity,userUsername,userEmail,counterpartyUsername,referenceId,fiatAmount,fiatCurrency,paymentProvider,flutterwaveId,phoneNumber,bankAccount,description,journalEntry,clearanceAt,createdAt]);

@override
String toString() {
  return 'PortalTransaction(id: $id, txRef: $txRef, transactionType: $transactionType, direction: $direction, status: $status, artifactType: $artifactType, quantity: $quantity, userUsername: $userUsername, userEmail: $userEmail, counterpartyUsername: $counterpartyUsername, referenceId: $referenceId, fiatAmount: $fiatAmount, fiatCurrency: $fiatCurrency, paymentProvider: $paymentProvider, flutterwaveId: $flutterwaveId, phoneNumber: $phoneNumber, bankAccount: $bankAccount, description: $description, journalEntry: $journalEntry, clearanceAt: $clearanceAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PortalTransactionCopyWith<$Res>  {
  factory $PortalTransactionCopyWith(PortalTransaction value, $Res Function(PortalTransaction) _then) = _$PortalTransactionCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'tx_ref') String txRef,@JsonKey(name: 'transaction_type') String transactionType, String direction, String status,@JsonKey(name: 'artifact_type') String artifactType, int quantity,@JsonKey(name: 'user_username') String userUsername,@JsonKey(name: 'user_email') String userEmail,@JsonKey(name: 'counterparty_username') String? counterpartyUsername,@JsonKey(name: 'reference_id') String referenceId,@JsonKey(name: 'fiat_amount', fromJson: _optNumText) String? fiatAmount,@JsonKey(name: 'fiat_currency') String fiatCurrency,@JsonKey(name: 'payment_provider') String paymentProvider,@JsonKey(name: 'flutterwave_id') String flutterwaveId,@JsonKey(name: 'phone_number') String phoneNumber,@JsonKey(name: 'bank_account') String bankAccount, String description,@JsonKey(name: 'journal_entry') String? journalEntry,@JsonKey(name: 'clearance_at') String? clearanceAt,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class _$PortalTransactionCopyWithImpl<$Res>
    implements $PortalTransactionCopyWith<$Res> {
  _$PortalTransactionCopyWithImpl(this._self, this._then);

  final PortalTransaction _self;
  final $Res Function(PortalTransaction) _then;

/// Create a copy of PortalTransaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? txRef = null,Object? transactionType = null,Object? direction = null,Object? status = null,Object? artifactType = null,Object? quantity = null,Object? userUsername = null,Object? userEmail = null,Object? counterpartyUsername = freezed,Object? referenceId = null,Object? fiatAmount = freezed,Object? fiatCurrency = null,Object? paymentProvider = null,Object? flutterwaveId = null,Object? phoneNumber = null,Object? bankAccount = null,Object? description = null,Object? journalEntry = freezed,Object? clearanceAt = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,txRef: null == txRef ? _self.txRef : txRef // ignore: cast_nullable_to_non_nullable
as String,transactionType: null == transactionType ? _self.transactionType : transactionType // ignore: cast_nullable_to_non_nullable
as String,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,artifactType: null == artifactType ? _self.artifactType : artifactType // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,userUsername: null == userUsername ? _self.userUsername : userUsername // ignore: cast_nullable_to_non_nullable
as String,userEmail: null == userEmail ? _self.userEmail : userEmail // ignore: cast_nullable_to_non_nullable
as String,counterpartyUsername: freezed == counterpartyUsername ? _self.counterpartyUsername : counterpartyUsername // ignore: cast_nullable_to_non_nullable
as String?,referenceId: null == referenceId ? _self.referenceId : referenceId // ignore: cast_nullable_to_non_nullable
as String,fiatAmount: freezed == fiatAmount ? _self.fiatAmount : fiatAmount // ignore: cast_nullable_to_non_nullable
as String?,fiatCurrency: null == fiatCurrency ? _self.fiatCurrency : fiatCurrency // ignore: cast_nullable_to_non_nullable
as String,paymentProvider: null == paymentProvider ? _self.paymentProvider : paymentProvider // ignore: cast_nullable_to_non_nullable
as String,flutterwaveId: null == flutterwaveId ? _self.flutterwaveId : flutterwaveId // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,bankAccount: null == bankAccount ? _self.bankAccount : bankAccount // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,journalEntry: freezed == journalEntry ? _self.journalEntry : journalEntry // ignore: cast_nullable_to_non_nullable
as String?,clearanceAt: freezed == clearanceAt ? _self.clearanceAt : clearanceAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PortalTransaction].
extension PortalTransactionPatterns on PortalTransaction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PortalTransaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PortalTransaction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PortalTransaction value)  $default,){
final _that = this;
switch (_that) {
case _PortalTransaction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PortalTransaction value)?  $default,){
final _that = this;
switch (_that) {
case _PortalTransaction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'tx_ref')  String txRef, @JsonKey(name: 'transaction_type')  String transactionType,  String direction,  String status, @JsonKey(name: 'artifact_type')  String artifactType,  int quantity, @JsonKey(name: 'user_username')  String userUsername, @JsonKey(name: 'user_email')  String userEmail, @JsonKey(name: 'counterparty_username')  String? counterpartyUsername, @JsonKey(name: 'reference_id')  String referenceId, @JsonKey(name: 'fiat_amount', fromJson: _optNumText)  String? fiatAmount, @JsonKey(name: 'fiat_currency')  String fiatCurrency, @JsonKey(name: 'payment_provider')  String paymentProvider, @JsonKey(name: 'flutterwave_id')  String flutterwaveId, @JsonKey(name: 'phone_number')  String phoneNumber, @JsonKey(name: 'bank_account')  String bankAccount,  String description, @JsonKey(name: 'journal_entry')  String? journalEntry, @JsonKey(name: 'clearance_at')  String? clearanceAt, @JsonKey(name: 'created_at')  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PortalTransaction() when $default != null:
return $default(_that.id,_that.txRef,_that.transactionType,_that.direction,_that.status,_that.artifactType,_that.quantity,_that.userUsername,_that.userEmail,_that.counterpartyUsername,_that.referenceId,_that.fiatAmount,_that.fiatCurrency,_that.paymentProvider,_that.flutterwaveId,_that.phoneNumber,_that.bankAccount,_that.description,_that.journalEntry,_that.clearanceAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'tx_ref')  String txRef, @JsonKey(name: 'transaction_type')  String transactionType,  String direction,  String status, @JsonKey(name: 'artifact_type')  String artifactType,  int quantity, @JsonKey(name: 'user_username')  String userUsername, @JsonKey(name: 'user_email')  String userEmail, @JsonKey(name: 'counterparty_username')  String? counterpartyUsername, @JsonKey(name: 'reference_id')  String referenceId, @JsonKey(name: 'fiat_amount', fromJson: _optNumText)  String? fiatAmount, @JsonKey(name: 'fiat_currency')  String fiatCurrency, @JsonKey(name: 'payment_provider')  String paymentProvider, @JsonKey(name: 'flutterwave_id')  String flutterwaveId, @JsonKey(name: 'phone_number')  String phoneNumber, @JsonKey(name: 'bank_account')  String bankAccount,  String description, @JsonKey(name: 'journal_entry')  String? journalEntry, @JsonKey(name: 'clearance_at')  String? clearanceAt, @JsonKey(name: 'created_at')  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _PortalTransaction():
return $default(_that.id,_that.txRef,_that.transactionType,_that.direction,_that.status,_that.artifactType,_that.quantity,_that.userUsername,_that.userEmail,_that.counterpartyUsername,_that.referenceId,_that.fiatAmount,_that.fiatCurrency,_that.paymentProvider,_that.flutterwaveId,_that.phoneNumber,_that.bankAccount,_that.description,_that.journalEntry,_that.clearanceAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'tx_ref')  String txRef, @JsonKey(name: 'transaction_type')  String transactionType,  String direction,  String status, @JsonKey(name: 'artifact_type')  String artifactType,  int quantity, @JsonKey(name: 'user_username')  String userUsername, @JsonKey(name: 'user_email')  String userEmail, @JsonKey(name: 'counterparty_username')  String? counterpartyUsername, @JsonKey(name: 'reference_id')  String referenceId, @JsonKey(name: 'fiat_amount', fromJson: _optNumText)  String? fiatAmount, @JsonKey(name: 'fiat_currency')  String fiatCurrency, @JsonKey(name: 'payment_provider')  String paymentProvider, @JsonKey(name: 'flutterwave_id')  String flutterwaveId, @JsonKey(name: 'phone_number')  String phoneNumber, @JsonKey(name: 'bank_account')  String bankAccount,  String description, @JsonKey(name: 'journal_entry')  String? journalEntry, @JsonKey(name: 'clearance_at')  String? clearanceAt, @JsonKey(name: 'created_at')  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _PortalTransaction() when $default != null:
return $default(_that.id,_that.txRef,_that.transactionType,_that.direction,_that.status,_that.artifactType,_that.quantity,_that.userUsername,_that.userEmail,_that.counterpartyUsername,_that.referenceId,_that.fiatAmount,_that.fiatCurrency,_that.paymentProvider,_that.flutterwaveId,_that.phoneNumber,_that.bankAccount,_that.description,_that.journalEntry,_that.clearanceAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PortalTransaction implements PortalTransaction {
  const _PortalTransaction({required this.id, @JsonKey(name: 'tx_ref') this.txRef = '', @JsonKey(name: 'transaction_type') this.transactionType = '', this.direction = '', this.status = '', @JsonKey(name: 'artifact_type') this.artifactType = '', this.quantity = 0, @JsonKey(name: 'user_username') this.userUsername = '', @JsonKey(name: 'user_email') this.userEmail = '', @JsonKey(name: 'counterparty_username') this.counterpartyUsername, @JsonKey(name: 'reference_id') this.referenceId = '', @JsonKey(name: 'fiat_amount', fromJson: _optNumText) this.fiatAmount, @JsonKey(name: 'fiat_currency') this.fiatCurrency = '', @JsonKey(name: 'payment_provider') this.paymentProvider = '', @JsonKey(name: 'flutterwave_id') this.flutterwaveId = '', @JsonKey(name: 'phone_number') this.phoneNumber = '', @JsonKey(name: 'bank_account') this.bankAccount = '', this.description = '', @JsonKey(name: 'journal_entry') this.journalEntry, @JsonKey(name: 'clearance_at') this.clearanceAt, @JsonKey(name: 'created_at') this.createdAt});
  factory _PortalTransaction.fromJson(Map<String, dynamic> json) => _$PortalTransactionFromJson(json);

@override final  String id;
@override@JsonKey(name: 'tx_ref') final  String txRef;
@override@JsonKey(name: 'transaction_type') final  String transactionType;
@override@JsonKey() final  String direction;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'artifact_type') final  String artifactType;
@override@JsonKey() final  int quantity;
@override@JsonKey(name: 'user_username') final  String userUsername;
@override@JsonKey(name: 'user_email') final  String userEmail;
@override@JsonKey(name: 'counterparty_username') final  String? counterpartyUsername;
@override@JsonKey(name: 'reference_id') final  String referenceId;
@override@JsonKey(name: 'fiat_amount', fromJson: _optNumText) final  String? fiatAmount;
@override@JsonKey(name: 'fiat_currency') final  String fiatCurrency;
@override@JsonKey(name: 'payment_provider') final  String paymentProvider;
@override@JsonKey(name: 'flutterwave_id') final  String flutterwaveId;
@override@JsonKey(name: 'phone_number') final  String phoneNumber;
@override@JsonKey(name: 'bank_account') final  String bankAccount;
@override@JsonKey() final  String description;
@override@JsonKey(name: 'journal_entry') final  String? journalEntry;
@override@JsonKey(name: 'clearance_at') final  String? clearanceAt;
@override@JsonKey(name: 'created_at') final  String? createdAt;

/// Create a copy of PortalTransaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PortalTransactionCopyWith<_PortalTransaction> get copyWith => __$PortalTransactionCopyWithImpl<_PortalTransaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PortalTransactionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PortalTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.txRef, txRef) || other.txRef == txRef)&&(identical(other.transactionType, transactionType) || other.transactionType == transactionType)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.status, status) || other.status == status)&&(identical(other.artifactType, artifactType) || other.artifactType == artifactType)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.userUsername, userUsername) || other.userUsername == userUsername)&&(identical(other.userEmail, userEmail) || other.userEmail == userEmail)&&(identical(other.counterpartyUsername, counterpartyUsername) || other.counterpartyUsername == counterpartyUsername)&&(identical(other.referenceId, referenceId) || other.referenceId == referenceId)&&(identical(other.fiatAmount, fiatAmount) || other.fiatAmount == fiatAmount)&&(identical(other.fiatCurrency, fiatCurrency) || other.fiatCurrency == fiatCurrency)&&(identical(other.paymentProvider, paymentProvider) || other.paymentProvider == paymentProvider)&&(identical(other.flutterwaveId, flutterwaveId) || other.flutterwaveId == flutterwaveId)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.bankAccount, bankAccount) || other.bankAccount == bankAccount)&&(identical(other.description, description) || other.description == description)&&(identical(other.journalEntry, journalEntry) || other.journalEntry == journalEntry)&&(identical(other.clearanceAt, clearanceAt) || other.clearanceAt == clearanceAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,txRef,transactionType,direction,status,artifactType,quantity,userUsername,userEmail,counterpartyUsername,referenceId,fiatAmount,fiatCurrency,paymentProvider,flutterwaveId,phoneNumber,bankAccount,description,journalEntry,clearanceAt,createdAt]);

@override
String toString() {
  return 'PortalTransaction(id: $id, txRef: $txRef, transactionType: $transactionType, direction: $direction, status: $status, artifactType: $artifactType, quantity: $quantity, userUsername: $userUsername, userEmail: $userEmail, counterpartyUsername: $counterpartyUsername, referenceId: $referenceId, fiatAmount: $fiatAmount, fiatCurrency: $fiatCurrency, paymentProvider: $paymentProvider, flutterwaveId: $flutterwaveId, phoneNumber: $phoneNumber, bankAccount: $bankAccount, description: $description, journalEntry: $journalEntry, clearanceAt: $clearanceAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PortalTransactionCopyWith<$Res> implements $PortalTransactionCopyWith<$Res> {
  factory _$PortalTransactionCopyWith(_PortalTransaction value, $Res Function(_PortalTransaction) _then) = __$PortalTransactionCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'tx_ref') String txRef,@JsonKey(name: 'transaction_type') String transactionType, String direction, String status,@JsonKey(name: 'artifact_type') String artifactType, int quantity,@JsonKey(name: 'user_username') String userUsername,@JsonKey(name: 'user_email') String userEmail,@JsonKey(name: 'counterparty_username') String? counterpartyUsername,@JsonKey(name: 'reference_id') String referenceId,@JsonKey(name: 'fiat_amount', fromJson: _optNumText) String? fiatAmount,@JsonKey(name: 'fiat_currency') String fiatCurrency,@JsonKey(name: 'payment_provider') String paymentProvider,@JsonKey(name: 'flutterwave_id') String flutterwaveId,@JsonKey(name: 'phone_number') String phoneNumber,@JsonKey(name: 'bank_account') String bankAccount, String description,@JsonKey(name: 'journal_entry') String? journalEntry,@JsonKey(name: 'clearance_at') String? clearanceAt,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class __$PortalTransactionCopyWithImpl<$Res>
    implements _$PortalTransactionCopyWith<$Res> {
  __$PortalTransactionCopyWithImpl(this._self, this._then);

  final _PortalTransaction _self;
  final $Res Function(_PortalTransaction) _then;

/// Create a copy of PortalTransaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? txRef = null,Object? transactionType = null,Object? direction = null,Object? status = null,Object? artifactType = null,Object? quantity = null,Object? userUsername = null,Object? userEmail = null,Object? counterpartyUsername = freezed,Object? referenceId = null,Object? fiatAmount = freezed,Object? fiatCurrency = null,Object? paymentProvider = null,Object? flutterwaveId = null,Object? phoneNumber = null,Object? bankAccount = null,Object? description = null,Object? journalEntry = freezed,Object? clearanceAt = freezed,Object? createdAt = freezed,}) {
  return _then(_PortalTransaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,txRef: null == txRef ? _self.txRef : txRef // ignore: cast_nullable_to_non_nullable
as String,transactionType: null == transactionType ? _self.transactionType : transactionType // ignore: cast_nullable_to_non_nullable
as String,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,artifactType: null == artifactType ? _self.artifactType : artifactType // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,userUsername: null == userUsername ? _self.userUsername : userUsername // ignore: cast_nullable_to_non_nullable
as String,userEmail: null == userEmail ? _self.userEmail : userEmail // ignore: cast_nullable_to_non_nullable
as String,counterpartyUsername: freezed == counterpartyUsername ? _self.counterpartyUsername : counterpartyUsername // ignore: cast_nullable_to_non_nullable
as String?,referenceId: null == referenceId ? _self.referenceId : referenceId // ignore: cast_nullable_to_non_nullable
as String,fiatAmount: freezed == fiatAmount ? _self.fiatAmount : fiatAmount // ignore: cast_nullable_to_non_nullable
as String?,fiatCurrency: null == fiatCurrency ? _self.fiatCurrency : fiatCurrency // ignore: cast_nullable_to_non_nullable
as String,paymentProvider: null == paymentProvider ? _self.paymentProvider : paymentProvider // ignore: cast_nullable_to_non_nullable
as String,flutterwaveId: null == flutterwaveId ? _self.flutterwaveId : flutterwaveId // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,bankAccount: null == bankAccount ? _self.bankAccount : bankAccount // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,journalEntry: freezed == journalEntry ? _self.journalEntry : journalEntry // ignore: cast_nullable_to_non_nullable
as String?,clearanceAt: freezed == clearanceAt ? _self.clearanceAt : clearanceAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PortalReconciliationReport {

@JsonKey(name: 'provider') Map<String, dynamic> get provider;@JsonKey(name: 'local') Map<String, dynamic> get local;@JsonKey(name: 'window_days') int get windowDays;@JsonKey(name: 'writes_ledger') bool get writesLedger;
/// Create a copy of PortalReconciliationReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PortalReconciliationReportCopyWith<PortalReconciliationReport> get copyWith => _$PortalReconciliationReportCopyWithImpl<PortalReconciliationReport>(this as PortalReconciliationReport, _$identity);

  /// Serializes this PortalReconciliationReport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PortalReconciliationReport&&const DeepCollectionEquality().equals(other.provider, provider)&&const DeepCollectionEquality().equals(other.local, local)&&(identical(other.windowDays, windowDays) || other.windowDays == windowDays)&&(identical(other.writesLedger, writesLedger) || other.writesLedger == writesLedger));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(provider),const DeepCollectionEquality().hash(local),windowDays,writesLedger);

@override
String toString() {
  return 'PortalReconciliationReport(provider: $provider, local: $local, windowDays: $windowDays, writesLedger: $writesLedger)';
}


}

/// @nodoc
abstract mixin class $PortalReconciliationReportCopyWith<$Res>  {
  factory $PortalReconciliationReportCopyWith(PortalReconciliationReport value, $Res Function(PortalReconciliationReport) _then) = _$PortalReconciliationReportCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'provider') Map<String, dynamic> provider,@JsonKey(name: 'local') Map<String, dynamic> local,@JsonKey(name: 'window_days') int windowDays,@JsonKey(name: 'writes_ledger') bool writesLedger
});




}
/// @nodoc
class _$PortalReconciliationReportCopyWithImpl<$Res>
    implements $PortalReconciliationReportCopyWith<$Res> {
  _$PortalReconciliationReportCopyWithImpl(this._self, this._then);

  final PortalReconciliationReport _self;
  final $Res Function(PortalReconciliationReport) _then;

/// Create a copy of PortalReconciliationReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? provider = null,Object? local = null,Object? windowDays = null,Object? writesLedger = null,}) {
  return _then(_self.copyWith(
provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,local: null == local ? _self.local : local // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,windowDays: null == windowDays ? _self.windowDays : windowDays // ignore: cast_nullable_to_non_nullable
as int,writesLedger: null == writesLedger ? _self.writesLedger : writesLedger // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PortalReconciliationReport].
extension PortalReconciliationReportPatterns on PortalReconciliationReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PortalReconciliationReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PortalReconciliationReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PortalReconciliationReport value)  $default,){
final _that = this;
switch (_that) {
case _PortalReconciliationReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PortalReconciliationReport value)?  $default,){
final _that = this;
switch (_that) {
case _PortalReconciliationReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'provider')  Map<String, dynamic> provider, @JsonKey(name: 'local')  Map<String, dynamic> local, @JsonKey(name: 'window_days')  int windowDays, @JsonKey(name: 'writes_ledger')  bool writesLedger)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PortalReconciliationReport() when $default != null:
return $default(_that.provider,_that.local,_that.windowDays,_that.writesLedger);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'provider')  Map<String, dynamic> provider, @JsonKey(name: 'local')  Map<String, dynamic> local, @JsonKey(name: 'window_days')  int windowDays, @JsonKey(name: 'writes_ledger')  bool writesLedger)  $default,) {final _that = this;
switch (_that) {
case _PortalReconciliationReport():
return $default(_that.provider,_that.local,_that.windowDays,_that.writesLedger);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'provider')  Map<String, dynamic> provider, @JsonKey(name: 'local')  Map<String, dynamic> local, @JsonKey(name: 'window_days')  int windowDays, @JsonKey(name: 'writes_ledger')  bool writesLedger)?  $default,) {final _that = this;
switch (_that) {
case _PortalReconciliationReport() when $default != null:
return $default(_that.provider,_that.local,_that.windowDays,_that.writesLedger);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PortalReconciliationReport implements PortalReconciliationReport {
  const _PortalReconciliationReport({@JsonKey(name: 'provider') final  Map<String, dynamic> provider = const <String, dynamic>{}, @JsonKey(name: 'local') final  Map<String, dynamic> local = const <String, dynamic>{}, @JsonKey(name: 'window_days') this.windowDays = 30, @JsonKey(name: 'writes_ledger') this.writesLedger = false}): _provider = provider,_local = local;
  factory _PortalReconciliationReport.fromJson(Map<String, dynamic> json) => _$PortalReconciliationReportFromJson(json);

 final  Map<String, dynamic> _provider;
@override@JsonKey(name: 'provider') Map<String, dynamic> get provider {
  if (_provider is EqualUnmodifiableMapView) return _provider;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_provider);
}

 final  Map<String, dynamic> _local;
@override@JsonKey(name: 'local') Map<String, dynamic> get local {
  if (_local is EqualUnmodifiableMapView) return _local;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_local);
}

@override@JsonKey(name: 'window_days') final  int windowDays;
@override@JsonKey(name: 'writes_ledger') final  bool writesLedger;

/// Create a copy of PortalReconciliationReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PortalReconciliationReportCopyWith<_PortalReconciliationReport> get copyWith => __$PortalReconciliationReportCopyWithImpl<_PortalReconciliationReport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PortalReconciliationReportToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PortalReconciliationReport&&const DeepCollectionEquality().equals(other._provider, _provider)&&const DeepCollectionEquality().equals(other._local, _local)&&(identical(other.windowDays, windowDays) || other.windowDays == windowDays)&&(identical(other.writesLedger, writesLedger) || other.writesLedger == writesLedger));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_provider),const DeepCollectionEquality().hash(_local),windowDays,writesLedger);

@override
String toString() {
  return 'PortalReconciliationReport(provider: $provider, local: $local, windowDays: $windowDays, writesLedger: $writesLedger)';
}


}

/// @nodoc
abstract mixin class _$PortalReconciliationReportCopyWith<$Res> implements $PortalReconciliationReportCopyWith<$Res> {
  factory _$PortalReconciliationReportCopyWith(_PortalReconciliationReport value, $Res Function(_PortalReconciliationReport) _then) = __$PortalReconciliationReportCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'provider') Map<String, dynamic> provider,@JsonKey(name: 'local') Map<String, dynamic> local,@JsonKey(name: 'window_days') int windowDays,@JsonKey(name: 'writes_ledger') bool writesLedger
});




}
/// @nodoc
class __$PortalReconciliationReportCopyWithImpl<$Res>
    implements _$PortalReconciliationReportCopyWith<$Res> {
  __$PortalReconciliationReportCopyWithImpl(this._self, this._then);

  final _PortalReconciliationReport _self;
  final $Res Function(_PortalReconciliationReport) _then;

/// Create a copy of PortalReconciliationReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? provider = null,Object? local = null,Object? windowDays = null,Object? writesLedger = null,}) {
  return _then(_PortalReconciliationReport(
provider: null == provider ? _self._provider : provider // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,local: null == local ? _self._local : local // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,windowDays: null == windowDays ? _self.windowDays : windowDays // ignore: cast_nullable_to_non_nullable
as int,writesLedger: null == writesLedger ? _self.writesLedger : writesLedger // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$PortalPagination {

 int get count; String? get next; String? get previous;
/// Create a copy of PortalPagination
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PortalPaginationCopyWith<PortalPagination> get copyWith => _$PortalPaginationCopyWithImpl<PortalPagination>(this as PortalPagination, _$identity);

  /// Serializes this PortalPagination to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PortalPagination&&(identical(other.count, count) || other.count == count)&&(identical(other.next, next) || other.next == next)&&(identical(other.previous, previous) || other.previous == previous));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,count,next,previous);

@override
String toString() {
  return 'PortalPagination(count: $count, next: $next, previous: $previous)';
}


}

/// @nodoc
abstract mixin class $PortalPaginationCopyWith<$Res>  {
  factory $PortalPaginationCopyWith(PortalPagination value, $Res Function(PortalPagination) _then) = _$PortalPaginationCopyWithImpl;
@useResult
$Res call({
 int count, String? next, String? previous
});




}
/// @nodoc
class _$PortalPaginationCopyWithImpl<$Res>
    implements $PortalPaginationCopyWith<$Res> {
  _$PortalPaginationCopyWithImpl(this._self, this._then);

  final PortalPagination _self;
  final $Res Function(PortalPagination) _then;

/// Create a copy of PortalPagination
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? count = null,Object? next = freezed,Object? previous = freezed,}) {
  return _then(_self.copyWith(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,next: freezed == next ? _self.next : next // ignore: cast_nullable_to_non_nullable
as String?,previous: freezed == previous ? _self.previous : previous // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PortalPagination].
extension PortalPaginationPatterns on PortalPagination {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PortalPagination value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PortalPagination() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PortalPagination value)  $default,){
final _that = this;
switch (_that) {
case _PortalPagination():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PortalPagination value)?  $default,){
final _that = this;
switch (_that) {
case _PortalPagination() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int count,  String? next,  String? previous)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PortalPagination() when $default != null:
return $default(_that.count,_that.next,_that.previous);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int count,  String? next,  String? previous)  $default,) {final _that = this;
switch (_that) {
case _PortalPagination():
return $default(_that.count,_that.next,_that.previous);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int count,  String? next,  String? previous)?  $default,) {final _that = this;
switch (_that) {
case _PortalPagination() when $default != null:
return $default(_that.count,_that.next,_that.previous);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PortalPagination implements PortalPagination {
  const _PortalPagination({this.count = 0, this.next, this.previous});
  factory _PortalPagination.fromJson(Map<String, dynamic> json) => _$PortalPaginationFromJson(json);

@override@JsonKey() final  int count;
@override final  String? next;
@override final  String? previous;

/// Create a copy of PortalPagination
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PortalPaginationCopyWith<_PortalPagination> get copyWith => __$PortalPaginationCopyWithImpl<_PortalPagination>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PortalPaginationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PortalPagination&&(identical(other.count, count) || other.count == count)&&(identical(other.next, next) || other.next == next)&&(identical(other.previous, previous) || other.previous == previous));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,count,next,previous);

@override
String toString() {
  return 'PortalPagination(count: $count, next: $next, previous: $previous)';
}


}

/// @nodoc
abstract mixin class _$PortalPaginationCopyWith<$Res> implements $PortalPaginationCopyWith<$Res> {
  factory _$PortalPaginationCopyWith(_PortalPagination value, $Res Function(_PortalPagination) _then) = __$PortalPaginationCopyWithImpl;
@override @useResult
$Res call({
 int count, String? next, String? previous
});




}
/// @nodoc
class __$PortalPaginationCopyWithImpl<$Res>
    implements _$PortalPaginationCopyWith<$Res> {
  __$PortalPaginationCopyWithImpl(this._self, this._then);

  final _PortalPagination _self;
  final $Res Function(_PortalPagination) _then;

/// Create a copy of PortalPagination
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? count = null,Object? next = freezed,Object? previous = freezed,}) {
  return _then(_PortalPagination(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,next: freezed == next ? _self.next : next // ignore: cast_nullable_to_non_nullable
as String?,previous: freezed == previous ? _self.previous : previous // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$GovernanceUserRef {

 String? get id; String? get email;@JsonKey(name: 'display_name') String get displayName;
/// Create a copy of GovernanceUserRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GovernanceUserRefCopyWith<GovernanceUserRef> get copyWith => _$GovernanceUserRefCopyWithImpl<GovernanceUserRef>(this as GovernanceUserRef, _$identity);

  /// Serializes this GovernanceUserRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GovernanceUserRef&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,displayName);

@override
String toString() {
  return 'GovernanceUserRef(id: $id, email: $email, displayName: $displayName)';
}


}

/// @nodoc
abstract mixin class $GovernanceUserRefCopyWith<$Res>  {
  factory $GovernanceUserRefCopyWith(GovernanceUserRef value, $Res Function(GovernanceUserRef) _then) = _$GovernanceUserRefCopyWithImpl;
@useResult
$Res call({
 String? id, String? email,@JsonKey(name: 'display_name') String displayName
});




}
/// @nodoc
class _$GovernanceUserRefCopyWithImpl<$Res>
    implements $GovernanceUserRefCopyWith<$Res> {
  _$GovernanceUserRefCopyWithImpl(this._self, this._then);

  final GovernanceUserRef _self;
  final $Res Function(GovernanceUserRef) _then;

/// Create a copy of GovernanceUserRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? email = freezed,Object? displayName = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GovernanceUserRef].
extension GovernanceUserRefPatterns on GovernanceUserRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GovernanceUserRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GovernanceUserRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GovernanceUserRef value)  $default,){
final _that = this;
switch (_that) {
case _GovernanceUserRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GovernanceUserRef value)?  $default,){
final _that = this;
switch (_that) {
case _GovernanceUserRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? email, @JsonKey(name: 'display_name')  String displayName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GovernanceUserRef() when $default != null:
return $default(_that.id,_that.email,_that.displayName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? email, @JsonKey(name: 'display_name')  String displayName)  $default,) {final _that = this;
switch (_that) {
case _GovernanceUserRef():
return $default(_that.id,_that.email,_that.displayName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? email, @JsonKey(name: 'display_name')  String displayName)?  $default,) {final _that = this;
switch (_that) {
case _GovernanceUserRef() when $default != null:
return $default(_that.id,_that.email,_that.displayName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GovernanceUserRef implements GovernanceUserRef {
  const _GovernanceUserRef({this.id, this.email, @JsonKey(name: 'display_name') this.displayName = ''});
  factory _GovernanceUserRef.fromJson(Map<String, dynamic> json) => _$GovernanceUserRefFromJson(json);

@override final  String? id;
@override final  String? email;
@override@JsonKey(name: 'display_name') final  String displayName;

/// Create a copy of GovernanceUserRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GovernanceUserRefCopyWith<_GovernanceUserRef> get copyWith => __$GovernanceUserRefCopyWithImpl<_GovernanceUserRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GovernanceUserRefToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GovernanceUserRef&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,displayName);

@override
String toString() {
  return 'GovernanceUserRef(id: $id, email: $email, displayName: $displayName)';
}


}

/// @nodoc
abstract mixin class _$GovernanceUserRefCopyWith<$Res> implements $GovernanceUserRefCopyWith<$Res> {
  factory _$GovernanceUserRefCopyWith(_GovernanceUserRef value, $Res Function(_GovernanceUserRef) _then) = __$GovernanceUserRefCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? email,@JsonKey(name: 'display_name') String displayName
});




}
/// @nodoc
class __$GovernanceUserRefCopyWithImpl<$Res>
    implements _$GovernanceUserRefCopyWith<$Res> {
  __$GovernanceUserRefCopyWithImpl(this._self, this._then);

  final _GovernanceUserRef _self;
  final $Res Function(_GovernanceUserRef) _then;

/// Create a copy of GovernanceUserRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? email = freezed,Object? displayName = null,}) {
  return _then(_GovernanceUserRef(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$StaffRole {

 String? get id;@JsonKey(name: 'user') GovernanceUserRef? get user; String get role;@JsonKey(name: 'role_display') String get roleDisplay; List<String> get scopes;@JsonKey(name: 'default_scopes') List<String> get defaultScopes;@JsonKey(name: 'effective_scopes') List<String> get effectiveScopes;@JsonKey(name: 'granted_by') GovernanceUserRef? get grantedBy;@JsonKey(name: 'granted_at') String? get grantedAt; String get notes;@JsonKey(name: 'revoked_at') String? get revokedAt;/// A revoked row grants nothing but is kept for the audit trail, so this
/// defaults false: an absent field must not read as "currently holds it".
@JsonKey(name: 'is_active') bool get isActive;@JsonKey(name: 'created_at') String? get createdAt;@JsonKey(name: 'updated_at') String? get updatedAt;
/// Create a copy of StaffRole
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StaffRoleCopyWith<StaffRole> get copyWith => _$StaffRoleCopyWithImpl<StaffRole>(this as StaffRole, _$identity);

  /// Serializes this StaffRole to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StaffRole&&(identical(other.id, id) || other.id == id)&&(identical(other.user, user) || other.user == user)&&(identical(other.role, role) || other.role == role)&&(identical(other.roleDisplay, roleDisplay) || other.roleDisplay == roleDisplay)&&const DeepCollectionEquality().equals(other.scopes, scopes)&&const DeepCollectionEquality().equals(other.defaultScopes, defaultScopes)&&const DeepCollectionEquality().equals(other.effectiveScopes, effectiveScopes)&&(identical(other.grantedBy, grantedBy) || other.grantedBy == grantedBy)&&(identical(other.grantedAt, grantedAt) || other.grantedAt == grantedAt)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.revokedAt, revokedAt) || other.revokedAt == revokedAt)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,user,role,roleDisplay,const DeepCollectionEquality().hash(scopes),const DeepCollectionEquality().hash(defaultScopes),const DeepCollectionEquality().hash(effectiveScopes),grantedBy,grantedAt,notes,revokedAt,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'StaffRole(id: $id, user: $user, role: $role, roleDisplay: $roleDisplay, scopes: $scopes, defaultScopes: $defaultScopes, effectiveScopes: $effectiveScopes, grantedBy: $grantedBy, grantedAt: $grantedAt, notes: $notes, revokedAt: $revokedAt, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $StaffRoleCopyWith<$Res>  {
  factory $StaffRoleCopyWith(StaffRole value, $Res Function(StaffRole) _then) = _$StaffRoleCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(name: 'user') GovernanceUserRef? user, String role,@JsonKey(name: 'role_display') String roleDisplay, List<String> scopes,@JsonKey(name: 'default_scopes') List<String> defaultScopes,@JsonKey(name: 'effective_scopes') List<String> effectiveScopes,@JsonKey(name: 'granted_by') GovernanceUserRef? grantedBy,@JsonKey(name: 'granted_at') String? grantedAt, String notes,@JsonKey(name: 'revoked_at') String? revokedAt,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
});


$GovernanceUserRefCopyWith<$Res>? get user;$GovernanceUserRefCopyWith<$Res>? get grantedBy;

}
/// @nodoc
class _$StaffRoleCopyWithImpl<$Res>
    implements $StaffRoleCopyWith<$Res> {
  _$StaffRoleCopyWithImpl(this._self, this._then);

  final StaffRole _self;
  final $Res Function(StaffRole) _then;

/// Create a copy of StaffRole
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? user = freezed,Object? role = null,Object? roleDisplay = null,Object? scopes = null,Object? defaultScopes = null,Object? effectiveScopes = null,Object? grantedBy = freezed,Object? grantedAt = freezed,Object? notes = null,Object? revokedAt = freezed,Object? isActive = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as GovernanceUserRef?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,roleDisplay: null == roleDisplay ? _self.roleDisplay : roleDisplay // ignore: cast_nullable_to_non_nullable
as String,scopes: null == scopes ? _self.scopes : scopes // ignore: cast_nullable_to_non_nullable
as List<String>,defaultScopes: null == defaultScopes ? _self.defaultScopes : defaultScopes // ignore: cast_nullable_to_non_nullable
as List<String>,effectiveScopes: null == effectiveScopes ? _self.effectiveScopes : effectiveScopes // ignore: cast_nullable_to_non_nullable
as List<String>,grantedBy: freezed == grantedBy ? _self.grantedBy : grantedBy // ignore: cast_nullable_to_non_nullable
as GovernanceUserRef?,grantedAt: freezed == grantedAt ? _self.grantedAt : grantedAt // ignore: cast_nullable_to_non_nullable
as String?,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,revokedAt: freezed == revokedAt ? _self.revokedAt : revokedAt // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of StaffRole
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GovernanceUserRefCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $GovernanceUserRefCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of StaffRole
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GovernanceUserRefCopyWith<$Res>? get grantedBy {
    if (_self.grantedBy == null) {
    return null;
  }

  return $GovernanceUserRefCopyWith<$Res>(_self.grantedBy!, (value) {
    return _then(_self.copyWith(grantedBy: value));
  });
}
}


/// Adds pattern-matching-related methods to [StaffRole].
extension StaffRolePatterns on StaffRole {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StaffRole value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StaffRole() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StaffRole value)  $default,){
final _that = this;
switch (_that) {
case _StaffRole():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StaffRole value)?  $default,){
final _that = this;
switch (_that) {
case _StaffRole() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'user')  GovernanceUserRef? user,  String role, @JsonKey(name: 'role_display')  String roleDisplay,  List<String> scopes, @JsonKey(name: 'default_scopes')  List<String> defaultScopes, @JsonKey(name: 'effective_scopes')  List<String> effectiveScopes, @JsonKey(name: 'granted_by')  GovernanceUserRef? grantedBy, @JsonKey(name: 'granted_at')  String? grantedAt,  String notes, @JsonKey(name: 'revoked_at')  String? revokedAt, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StaffRole() when $default != null:
return $default(_that.id,_that.user,_that.role,_that.roleDisplay,_that.scopes,_that.defaultScopes,_that.effectiveScopes,_that.grantedBy,_that.grantedAt,_that.notes,_that.revokedAt,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'user')  GovernanceUserRef? user,  String role, @JsonKey(name: 'role_display')  String roleDisplay,  List<String> scopes, @JsonKey(name: 'default_scopes')  List<String> defaultScopes, @JsonKey(name: 'effective_scopes')  List<String> effectiveScopes, @JsonKey(name: 'granted_by')  GovernanceUserRef? grantedBy, @JsonKey(name: 'granted_at')  String? grantedAt,  String notes, @JsonKey(name: 'revoked_at')  String? revokedAt, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _StaffRole():
return $default(_that.id,_that.user,_that.role,_that.roleDisplay,_that.scopes,_that.defaultScopes,_that.effectiveScopes,_that.grantedBy,_that.grantedAt,_that.notes,_that.revokedAt,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(name: 'user')  GovernanceUserRef? user,  String role, @JsonKey(name: 'role_display')  String roleDisplay,  List<String> scopes, @JsonKey(name: 'default_scopes')  List<String> defaultScopes, @JsonKey(name: 'effective_scopes')  List<String> effectiveScopes, @JsonKey(name: 'granted_by')  GovernanceUserRef? grantedBy, @JsonKey(name: 'granted_at')  String? grantedAt,  String notes, @JsonKey(name: 'revoked_at')  String? revokedAt, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _StaffRole() when $default != null:
return $default(_that.id,_that.user,_that.role,_that.roleDisplay,_that.scopes,_that.defaultScopes,_that.effectiveScopes,_that.grantedBy,_that.grantedAt,_that.notes,_that.revokedAt,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StaffRole implements StaffRole {
  const _StaffRole({this.id, @JsonKey(name: 'user') this.user, this.role = '', @JsonKey(name: 'role_display') this.roleDisplay = '', final  List<String> scopes = const <String>[], @JsonKey(name: 'default_scopes') final  List<String> defaultScopes = const <String>[], @JsonKey(name: 'effective_scopes') final  List<String> effectiveScopes = const <String>[], @JsonKey(name: 'granted_by') this.grantedBy, @JsonKey(name: 'granted_at') this.grantedAt, this.notes = '', @JsonKey(name: 'revoked_at') this.revokedAt, @JsonKey(name: 'is_active') this.isActive = false, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt}): _scopes = scopes,_defaultScopes = defaultScopes,_effectiveScopes = effectiveScopes;
  factory _StaffRole.fromJson(Map<String, dynamic> json) => _$StaffRoleFromJson(json);

@override final  String? id;
@override@JsonKey(name: 'user') final  GovernanceUserRef? user;
@override@JsonKey() final  String role;
@override@JsonKey(name: 'role_display') final  String roleDisplay;
 final  List<String> _scopes;
@override@JsonKey() List<String> get scopes {
  if (_scopes is EqualUnmodifiableListView) return _scopes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_scopes);
}

 final  List<String> _defaultScopes;
@override@JsonKey(name: 'default_scopes') List<String> get defaultScopes {
  if (_defaultScopes is EqualUnmodifiableListView) return _defaultScopes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_defaultScopes);
}

 final  List<String> _effectiveScopes;
@override@JsonKey(name: 'effective_scopes') List<String> get effectiveScopes {
  if (_effectiveScopes is EqualUnmodifiableListView) return _effectiveScopes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_effectiveScopes);
}

@override@JsonKey(name: 'granted_by') final  GovernanceUserRef? grantedBy;
@override@JsonKey(name: 'granted_at') final  String? grantedAt;
@override@JsonKey() final  String notes;
@override@JsonKey(name: 'revoked_at') final  String? revokedAt;
/// A revoked row grants nothing but is kept for the audit trail, so this
/// defaults false: an absent field must not read as "currently holds it".
@override@JsonKey(name: 'is_active') final  bool isActive;
@override@JsonKey(name: 'created_at') final  String? createdAt;
@override@JsonKey(name: 'updated_at') final  String? updatedAt;

/// Create a copy of StaffRole
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StaffRoleCopyWith<_StaffRole> get copyWith => __$StaffRoleCopyWithImpl<_StaffRole>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StaffRoleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StaffRole&&(identical(other.id, id) || other.id == id)&&(identical(other.user, user) || other.user == user)&&(identical(other.role, role) || other.role == role)&&(identical(other.roleDisplay, roleDisplay) || other.roleDisplay == roleDisplay)&&const DeepCollectionEquality().equals(other._scopes, _scopes)&&const DeepCollectionEquality().equals(other._defaultScopes, _defaultScopes)&&const DeepCollectionEquality().equals(other._effectiveScopes, _effectiveScopes)&&(identical(other.grantedBy, grantedBy) || other.grantedBy == grantedBy)&&(identical(other.grantedAt, grantedAt) || other.grantedAt == grantedAt)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.revokedAt, revokedAt) || other.revokedAt == revokedAt)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,user,role,roleDisplay,const DeepCollectionEquality().hash(_scopes),const DeepCollectionEquality().hash(_defaultScopes),const DeepCollectionEquality().hash(_effectiveScopes),grantedBy,grantedAt,notes,revokedAt,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'StaffRole(id: $id, user: $user, role: $role, roleDisplay: $roleDisplay, scopes: $scopes, defaultScopes: $defaultScopes, effectiveScopes: $effectiveScopes, grantedBy: $grantedBy, grantedAt: $grantedAt, notes: $notes, revokedAt: $revokedAt, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$StaffRoleCopyWith<$Res> implements $StaffRoleCopyWith<$Res> {
  factory _$StaffRoleCopyWith(_StaffRole value, $Res Function(_StaffRole) _then) = __$StaffRoleCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(name: 'user') GovernanceUserRef? user, String role,@JsonKey(name: 'role_display') String roleDisplay, List<String> scopes,@JsonKey(name: 'default_scopes') List<String> defaultScopes,@JsonKey(name: 'effective_scopes') List<String> effectiveScopes,@JsonKey(name: 'granted_by') GovernanceUserRef? grantedBy,@JsonKey(name: 'granted_at') String? grantedAt, String notes,@JsonKey(name: 'revoked_at') String? revokedAt,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
});


@override $GovernanceUserRefCopyWith<$Res>? get user;@override $GovernanceUserRefCopyWith<$Res>? get grantedBy;

}
/// @nodoc
class __$StaffRoleCopyWithImpl<$Res>
    implements _$StaffRoleCopyWith<$Res> {
  __$StaffRoleCopyWithImpl(this._self, this._then);

  final _StaffRole _self;
  final $Res Function(_StaffRole) _then;

/// Create a copy of StaffRole
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? user = freezed,Object? role = null,Object? roleDisplay = null,Object? scopes = null,Object? defaultScopes = null,Object? effectiveScopes = null,Object? grantedBy = freezed,Object? grantedAt = freezed,Object? notes = null,Object? revokedAt = freezed,Object? isActive = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_StaffRole(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as GovernanceUserRef?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,roleDisplay: null == roleDisplay ? _self.roleDisplay : roleDisplay // ignore: cast_nullable_to_non_nullable
as String,scopes: null == scopes ? _self._scopes : scopes // ignore: cast_nullable_to_non_nullable
as List<String>,defaultScopes: null == defaultScopes ? _self._defaultScopes : defaultScopes // ignore: cast_nullable_to_non_nullable
as List<String>,effectiveScopes: null == effectiveScopes ? _self._effectiveScopes : effectiveScopes // ignore: cast_nullable_to_non_nullable
as List<String>,grantedBy: freezed == grantedBy ? _self.grantedBy : grantedBy // ignore: cast_nullable_to_non_nullable
as GovernanceUserRef?,grantedAt: freezed == grantedAt ? _self.grantedAt : grantedAt // ignore: cast_nullable_to_non_nullable
as String?,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,revokedAt: freezed == revokedAt ? _self.revokedAt : revokedAt // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of StaffRole
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GovernanceUserRefCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $GovernanceUserRefCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of StaffRole
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GovernanceUserRefCopyWith<$Res>? get grantedBy {
    if (_self.grantedBy == null) {
    return null;
  }

  return $GovernanceUserRefCopyWith<$Res>(_self.grantedBy!, (value) {
    return _then(_self.copyWith(grantedBy: value));
  });
}
}


/// @nodoc
mixin _$AccountActionRequest {

 String? get id; String get action;@JsonKey(name: 'action_display') String get actionDisplay;@JsonKey(name: 'required_scope') String get requiredScope;@JsonKey(name: 'target_user') GovernanceUserRef? get targetUser;@JsonKey(name: 'payload', fromJson: _stringKeyedMapOrEmpty) Map<String, dynamic> get payload; String get status;@JsonKey(name: 'is_open') bool get isOpen;@JsonKey(name: 'requested_by') GovernanceUserRef? get requestedBy;/// Snapshot of the requester's name. Survives the actor's deletion, which
/// is the row you most want to still be able to audit.
@JsonKey(name: 'requested_by_profile') String get requestedByProfile;@JsonKey(name: 'decided_by') GovernanceUserRef? get decidedBy;@JsonKey(name: 'decided_at') String? get decidedAt;@JsonKey(name: 'decision_note') String get decisionNote;@JsonKey(name: 'requires_second') bool get requiresSecond;/// Null until the approve call has actually applied the effect. A request
/// reading "approved" with no `applied_at` is the case the approve view
/// rolls back rather than leaves lying.
@JsonKey(name: 'applied_at') String? get appliedAt;/// Only on the approve response: a human-readable description of what
/// happened. Other actions record that nothing automatic was done.
@JsonKey(name: 'effect')@_FlexibleTextConverter() String? get effect;@JsonKey(name: 'created_at') String? get createdAt;@JsonKey(name: 'updated_at') String? get updatedAt;
/// Create a copy of AccountActionRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountActionRequestCopyWith<AccountActionRequest> get copyWith => _$AccountActionRequestCopyWithImpl<AccountActionRequest>(this as AccountActionRequest, _$identity);

  /// Serializes this AccountActionRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountActionRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.action, action) || other.action == action)&&(identical(other.actionDisplay, actionDisplay) || other.actionDisplay == actionDisplay)&&(identical(other.requiredScope, requiredScope) || other.requiredScope == requiredScope)&&(identical(other.targetUser, targetUser) || other.targetUser == targetUser)&&const DeepCollectionEquality().equals(other.payload, payload)&&(identical(other.status, status) || other.status == status)&&(identical(other.isOpen, isOpen) || other.isOpen == isOpen)&&(identical(other.requestedBy, requestedBy) || other.requestedBy == requestedBy)&&(identical(other.requestedByProfile, requestedByProfile) || other.requestedByProfile == requestedByProfile)&&(identical(other.decidedBy, decidedBy) || other.decidedBy == decidedBy)&&(identical(other.decidedAt, decidedAt) || other.decidedAt == decidedAt)&&(identical(other.decisionNote, decisionNote) || other.decisionNote == decisionNote)&&(identical(other.requiresSecond, requiresSecond) || other.requiresSecond == requiresSecond)&&(identical(other.appliedAt, appliedAt) || other.appliedAt == appliedAt)&&(identical(other.effect, effect) || other.effect == effect)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,action,actionDisplay,requiredScope,targetUser,const DeepCollectionEquality().hash(payload),status,isOpen,requestedBy,requestedByProfile,decidedBy,decidedAt,decisionNote,requiresSecond,appliedAt,effect,createdAt,updatedAt);

@override
String toString() {
  return 'AccountActionRequest(id: $id, action: $action, actionDisplay: $actionDisplay, requiredScope: $requiredScope, targetUser: $targetUser, payload: $payload, status: $status, isOpen: $isOpen, requestedBy: $requestedBy, requestedByProfile: $requestedByProfile, decidedBy: $decidedBy, decidedAt: $decidedAt, decisionNote: $decisionNote, requiresSecond: $requiresSecond, appliedAt: $appliedAt, effect: $effect, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $AccountActionRequestCopyWith<$Res>  {
  factory $AccountActionRequestCopyWith(AccountActionRequest value, $Res Function(AccountActionRequest) _then) = _$AccountActionRequestCopyWithImpl;
@useResult
$Res call({
 String? id, String action,@JsonKey(name: 'action_display') String actionDisplay,@JsonKey(name: 'required_scope') String requiredScope,@JsonKey(name: 'target_user') GovernanceUserRef? targetUser,@JsonKey(name: 'payload', fromJson: _stringKeyedMapOrEmpty) Map<String, dynamic> payload, String status,@JsonKey(name: 'is_open') bool isOpen,@JsonKey(name: 'requested_by') GovernanceUserRef? requestedBy,@JsonKey(name: 'requested_by_profile') String requestedByProfile,@JsonKey(name: 'decided_by') GovernanceUserRef? decidedBy,@JsonKey(name: 'decided_at') String? decidedAt,@JsonKey(name: 'decision_note') String decisionNote,@JsonKey(name: 'requires_second') bool requiresSecond,@JsonKey(name: 'applied_at') String? appliedAt,@JsonKey(name: 'effect')@_FlexibleTextConverter() String? effect,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
});


$GovernanceUserRefCopyWith<$Res>? get targetUser;$GovernanceUserRefCopyWith<$Res>? get requestedBy;$GovernanceUserRefCopyWith<$Res>? get decidedBy;

}
/// @nodoc
class _$AccountActionRequestCopyWithImpl<$Res>
    implements $AccountActionRequestCopyWith<$Res> {
  _$AccountActionRequestCopyWithImpl(this._self, this._then);

  final AccountActionRequest _self;
  final $Res Function(AccountActionRequest) _then;

/// Create a copy of AccountActionRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? action = null,Object? actionDisplay = null,Object? requiredScope = null,Object? targetUser = freezed,Object? payload = null,Object? status = null,Object? isOpen = null,Object? requestedBy = freezed,Object? requestedByProfile = null,Object? decidedBy = freezed,Object? decidedAt = freezed,Object? decisionNote = null,Object? requiresSecond = null,Object? appliedAt = freezed,Object? effect = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,actionDisplay: null == actionDisplay ? _self.actionDisplay : actionDisplay // ignore: cast_nullable_to_non_nullable
as String,requiredScope: null == requiredScope ? _self.requiredScope : requiredScope // ignore: cast_nullable_to_non_nullable
as String,targetUser: freezed == targetUser ? _self.targetUser : targetUser // ignore: cast_nullable_to_non_nullable
as GovernanceUserRef?,payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,isOpen: null == isOpen ? _self.isOpen : isOpen // ignore: cast_nullable_to_non_nullable
as bool,requestedBy: freezed == requestedBy ? _self.requestedBy : requestedBy // ignore: cast_nullable_to_non_nullable
as GovernanceUserRef?,requestedByProfile: null == requestedByProfile ? _self.requestedByProfile : requestedByProfile // ignore: cast_nullable_to_non_nullable
as String,decidedBy: freezed == decidedBy ? _self.decidedBy : decidedBy // ignore: cast_nullable_to_non_nullable
as GovernanceUserRef?,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as String?,decisionNote: null == decisionNote ? _self.decisionNote : decisionNote // ignore: cast_nullable_to_non_nullable
as String,requiresSecond: null == requiresSecond ? _self.requiresSecond : requiresSecond // ignore: cast_nullable_to_non_nullable
as bool,appliedAt: freezed == appliedAt ? _self.appliedAt : appliedAt // ignore: cast_nullable_to_non_nullable
as String?,effect: freezed == effect ? _self.effect : effect // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of AccountActionRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GovernanceUserRefCopyWith<$Res>? get targetUser {
    if (_self.targetUser == null) {
    return null;
  }

  return $GovernanceUserRefCopyWith<$Res>(_self.targetUser!, (value) {
    return _then(_self.copyWith(targetUser: value));
  });
}/// Create a copy of AccountActionRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GovernanceUserRefCopyWith<$Res>? get requestedBy {
    if (_self.requestedBy == null) {
    return null;
  }

  return $GovernanceUserRefCopyWith<$Res>(_self.requestedBy!, (value) {
    return _then(_self.copyWith(requestedBy: value));
  });
}/// Create a copy of AccountActionRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GovernanceUserRefCopyWith<$Res>? get decidedBy {
    if (_self.decidedBy == null) {
    return null;
  }

  return $GovernanceUserRefCopyWith<$Res>(_self.decidedBy!, (value) {
    return _then(_self.copyWith(decidedBy: value));
  });
}
}


/// Adds pattern-matching-related methods to [AccountActionRequest].
extension AccountActionRequestPatterns on AccountActionRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccountActionRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccountActionRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccountActionRequest value)  $default,){
final _that = this;
switch (_that) {
case _AccountActionRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccountActionRequest value)?  $default,){
final _that = this;
switch (_that) {
case _AccountActionRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String action, @JsonKey(name: 'action_display')  String actionDisplay, @JsonKey(name: 'required_scope')  String requiredScope, @JsonKey(name: 'target_user')  GovernanceUserRef? targetUser, @JsonKey(name: 'payload', fromJson: _stringKeyedMapOrEmpty)  Map<String, dynamic> payload,  String status, @JsonKey(name: 'is_open')  bool isOpen, @JsonKey(name: 'requested_by')  GovernanceUserRef? requestedBy, @JsonKey(name: 'requested_by_profile')  String requestedByProfile, @JsonKey(name: 'decided_by')  GovernanceUserRef? decidedBy, @JsonKey(name: 'decided_at')  String? decidedAt, @JsonKey(name: 'decision_note')  String decisionNote, @JsonKey(name: 'requires_second')  bool requiresSecond, @JsonKey(name: 'applied_at')  String? appliedAt, @JsonKey(name: 'effect')@_FlexibleTextConverter()  String? effect, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccountActionRequest() when $default != null:
return $default(_that.id,_that.action,_that.actionDisplay,_that.requiredScope,_that.targetUser,_that.payload,_that.status,_that.isOpen,_that.requestedBy,_that.requestedByProfile,_that.decidedBy,_that.decidedAt,_that.decisionNote,_that.requiresSecond,_that.appliedAt,_that.effect,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String action, @JsonKey(name: 'action_display')  String actionDisplay, @JsonKey(name: 'required_scope')  String requiredScope, @JsonKey(name: 'target_user')  GovernanceUserRef? targetUser, @JsonKey(name: 'payload', fromJson: _stringKeyedMapOrEmpty)  Map<String, dynamic> payload,  String status, @JsonKey(name: 'is_open')  bool isOpen, @JsonKey(name: 'requested_by')  GovernanceUserRef? requestedBy, @JsonKey(name: 'requested_by_profile')  String requestedByProfile, @JsonKey(name: 'decided_by')  GovernanceUserRef? decidedBy, @JsonKey(name: 'decided_at')  String? decidedAt, @JsonKey(name: 'decision_note')  String decisionNote, @JsonKey(name: 'requires_second')  bool requiresSecond, @JsonKey(name: 'applied_at')  String? appliedAt, @JsonKey(name: 'effect')@_FlexibleTextConverter()  String? effect, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _AccountActionRequest():
return $default(_that.id,_that.action,_that.actionDisplay,_that.requiredScope,_that.targetUser,_that.payload,_that.status,_that.isOpen,_that.requestedBy,_that.requestedByProfile,_that.decidedBy,_that.decidedAt,_that.decisionNote,_that.requiresSecond,_that.appliedAt,_that.effect,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String action, @JsonKey(name: 'action_display')  String actionDisplay, @JsonKey(name: 'required_scope')  String requiredScope, @JsonKey(name: 'target_user')  GovernanceUserRef? targetUser, @JsonKey(name: 'payload', fromJson: _stringKeyedMapOrEmpty)  Map<String, dynamic> payload,  String status, @JsonKey(name: 'is_open')  bool isOpen, @JsonKey(name: 'requested_by')  GovernanceUserRef? requestedBy, @JsonKey(name: 'requested_by_profile')  String requestedByProfile, @JsonKey(name: 'decided_by')  GovernanceUserRef? decidedBy, @JsonKey(name: 'decided_at')  String? decidedAt, @JsonKey(name: 'decision_note')  String decisionNote, @JsonKey(name: 'requires_second')  bool requiresSecond, @JsonKey(name: 'applied_at')  String? appliedAt, @JsonKey(name: 'effect')@_FlexibleTextConverter()  String? effect, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AccountActionRequest() when $default != null:
return $default(_that.id,_that.action,_that.actionDisplay,_that.requiredScope,_that.targetUser,_that.payload,_that.status,_that.isOpen,_that.requestedBy,_that.requestedByProfile,_that.decidedBy,_that.decidedAt,_that.decisionNote,_that.requiresSecond,_that.appliedAt,_that.effect,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AccountActionRequest implements AccountActionRequest {
  const _AccountActionRequest({this.id, this.action = '', @JsonKey(name: 'action_display') this.actionDisplay = '', @JsonKey(name: 'required_scope') this.requiredScope = '', @JsonKey(name: 'target_user') this.targetUser, @JsonKey(name: 'payload', fromJson: _stringKeyedMapOrEmpty) final  Map<String, dynamic> payload = const <String, dynamic>{}, this.status = '', @JsonKey(name: 'is_open') this.isOpen = false, @JsonKey(name: 'requested_by') this.requestedBy, @JsonKey(name: 'requested_by_profile') this.requestedByProfile = '', @JsonKey(name: 'decided_by') this.decidedBy, @JsonKey(name: 'decided_at') this.decidedAt, @JsonKey(name: 'decision_note') this.decisionNote = '', @JsonKey(name: 'requires_second') this.requiresSecond = true, @JsonKey(name: 'applied_at') this.appliedAt, @JsonKey(name: 'effect')@_FlexibleTextConverter() this.effect, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt}): _payload = payload;
  factory _AccountActionRequest.fromJson(Map<String, dynamic> json) => _$AccountActionRequestFromJson(json);

@override final  String? id;
@override@JsonKey() final  String action;
@override@JsonKey(name: 'action_display') final  String actionDisplay;
@override@JsonKey(name: 'required_scope') final  String requiredScope;
@override@JsonKey(name: 'target_user') final  GovernanceUserRef? targetUser;
 final  Map<String, dynamic> _payload;
@override@JsonKey(name: 'payload', fromJson: _stringKeyedMapOrEmpty) Map<String, dynamic> get payload {
  if (_payload is EqualUnmodifiableMapView) return _payload;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_payload);
}

@override@JsonKey() final  String status;
@override@JsonKey(name: 'is_open') final  bool isOpen;
@override@JsonKey(name: 'requested_by') final  GovernanceUserRef? requestedBy;
/// Snapshot of the requester's name. Survives the actor's deletion, which
/// is the row you most want to still be able to audit.
@override@JsonKey(name: 'requested_by_profile') final  String requestedByProfile;
@override@JsonKey(name: 'decided_by') final  GovernanceUserRef? decidedBy;
@override@JsonKey(name: 'decided_at') final  String? decidedAt;
@override@JsonKey(name: 'decision_note') final  String decisionNote;
@override@JsonKey(name: 'requires_second') final  bool requiresSecond;
/// Null until the approve call has actually applied the effect. A request
/// reading "approved" with no `applied_at` is the case the approve view
/// rolls back rather than leaves lying.
@override@JsonKey(name: 'applied_at') final  String? appliedAt;
/// Only on the approve response: a human-readable description of what
/// happened. Other actions record that nothing automatic was done.
@override@JsonKey(name: 'effect')@_FlexibleTextConverter() final  String? effect;
@override@JsonKey(name: 'created_at') final  String? createdAt;
@override@JsonKey(name: 'updated_at') final  String? updatedAt;

/// Create a copy of AccountActionRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountActionRequestCopyWith<_AccountActionRequest> get copyWith => __$AccountActionRequestCopyWithImpl<_AccountActionRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccountActionRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountActionRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.action, action) || other.action == action)&&(identical(other.actionDisplay, actionDisplay) || other.actionDisplay == actionDisplay)&&(identical(other.requiredScope, requiredScope) || other.requiredScope == requiredScope)&&(identical(other.targetUser, targetUser) || other.targetUser == targetUser)&&const DeepCollectionEquality().equals(other._payload, _payload)&&(identical(other.status, status) || other.status == status)&&(identical(other.isOpen, isOpen) || other.isOpen == isOpen)&&(identical(other.requestedBy, requestedBy) || other.requestedBy == requestedBy)&&(identical(other.requestedByProfile, requestedByProfile) || other.requestedByProfile == requestedByProfile)&&(identical(other.decidedBy, decidedBy) || other.decidedBy == decidedBy)&&(identical(other.decidedAt, decidedAt) || other.decidedAt == decidedAt)&&(identical(other.decisionNote, decisionNote) || other.decisionNote == decisionNote)&&(identical(other.requiresSecond, requiresSecond) || other.requiresSecond == requiresSecond)&&(identical(other.appliedAt, appliedAt) || other.appliedAt == appliedAt)&&(identical(other.effect, effect) || other.effect == effect)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,action,actionDisplay,requiredScope,targetUser,const DeepCollectionEquality().hash(_payload),status,isOpen,requestedBy,requestedByProfile,decidedBy,decidedAt,decisionNote,requiresSecond,appliedAt,effect,createdAt,updatedAt);

@override
String toString() {
  return 'AccountActionRequest(id: $id, action: $action, actionDisplay: $actionDisplay, requiredScope: $requiredScope, targetUser: $targetUser, payload: $payload, status: $status, isOpen: $isOpen, requestedBy: $requestedBy, requestedByProfile: $requestedByProfile, decidedBy: $decidedBy, decidedAt: $decidedAt, decisionNote: $decisionNote, requiresSecond: $requiresSecond, appliedAt: $appliedAt, effect: $effect, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$AccountActionRequestCopyWith<$Res> implements $AccountActionRequestCopyWith<$Res> {
  factory _$AccountActionRequestCopyWith(_AccountActionRequest value, $Res Function(_AccountActionRequest) _then) = __$AccountActionRequestCopyWithImpl;
@override @useResult
$Res call({
 String? id, String action,@JsonKey(name: 'action_display') String actionDisplay,@JsonKey(name: 'required_scope') String requiredScope,@JsonKey(name: 'target_user') GovernanceUserRef? targetUser,@JsonKey(name: 'payload', fromJson: _stringKeyedMapOrEmpty) Map<String, dynamic> payload, String status,@JsonKey(name: 'is_open') bool isOpen,@JsonKey(name: 'requested_by') GovernanceUserRef? requestedBy,@JsonKey(name: 'requested_by_profile') String requestedByProfile,@JsonKey(name: 'decided_by') GovernanceUserRef? decidedBy,@JsonKey(name: 'decided_at') String? decidedAt,@JsonKey(name: 'decision_note') String decisionNote,@JsonKey(name: 'requires_second') bool requiresSecond,@JsonKey(name: 'applied_at') String? appliedAt,@JsonKey(name: 'effect')@_FlexibleTextConverter() String? effect,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
});


@override $GovernanceUserRefCopyWith<$Res>? get targetUser;@override $GovernanceUserRefCopyWith<$Res>? get requestedBy;@override $GovernanceUserRefCopyWith<$Res>? get decidedBy;

}
/// @nodoc
class __$AccountActionRequestCopyWithImpl<$Res>
    implements _$AccountActionRequestCopyWith<$Res> {
  __$AccountActionRequestCopyWithImpl(this._self, this._then);

  final _AccountActionRequest _self;
  final $Res Function(_AccountActionRequest) _then;

/// Create a copy of AccountActionRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? action = null,Object? actionDisplay = null,Object? requiredScope = null,Object? targetUser = freezed,Object? payload = null,Object? status = null,Object? isOpen = null,Object? requestedBy = freezed,Object? requestedByProfile = null,Object? decidedBy = freezed,Object? decidedAt = freezed,Object? decisionNote = null,Object? requiresSecond = null,Object? appliedAt = freezed,Object? effect = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_AccountActionRequest(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,actionDisplay: null == actionDisplay ? _self.actionDisplay : actionDisplay // ignore: cast_nullable_to_non_nullable
as String,requiredScope: null == requiredScope ? _self.requiredScope : requiredScope // ignore: cast_nullable_to_non_nullable
as String,targetUser: freezed == targetUser ? _self.targetUser : targetUser // ignore: cast_nullable_to_non_nullable
as GovernanceUserRef?,payload: null == payload ? _self._payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,isOpen: null == isOpen ? _self.isOpen : isOpen // ignore: cast_nullable_to_non_nullable
as bool,requestedBy: freezed == requestedBy ? _self.requestedBy : requestedBy // ignore: cast_nullable_to_non_nullable
as GovernanceUserRef?,requestedByProfile: null == requestedByProfile ? _self.requestedByProfile : requestedByProfile // ignore: cast_nullable_to_non_nullable
as String,decidedBy: freezed == decidedBy ? _self.decidedBy : decidedBy // ignore: cast_nullable_to_non_nullable
as GovernanceUserRef?,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as String?,decisionNote: null == decisionNote ? _self.decisionNote : decisionNote // ignore: cast_nullable_to_non_nullable
as String,requiresSecond: null == requiresSecond ? _self.requiresSecond : requiresSecond // ignore: cast_nullable_to_non_nullable
as bool,appliedAt: freezed == appliedAt ? _self.appliedAt : appliedAt // ignore: cast_nullable_to_non_nullable
as String?,effect: freezed == effect ? _self.effect : effect // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of AccountActionRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GovernanceUserRefCopyWith<$Res>? get targetUser {
    if (_self.targetUser == null) {
    return null;
  }

  return $GovernanceUserRefCopyWith<$Res>(_self.targetUser!, (value) {
    return _then(_self.copyWith(targetUser: value));
  });
}/// Create a copy of AccountActionRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GovernanceUserRefCopyWith<$Res>? get requestedBy {
    if (_self.requestedBy == null) {
    return null;
  }

  return $GovernanceUserRefCopyWith<$Res>(_self.requestedBy!, (value) {
    return _then(_self.copyWith(requestedBy: value));
  });
}/// Create a copy of AccountActionRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GovernanceUserRefCopyWith<$Res>? get decidedBy {
    if (_self.decidedBy == null) {
    return null;
  }

  return $GovernanceUserRefCopyWith<$Res>(_self.decidedBy!, (value) {
    return _then(_self.copyWith(decidedBy: value));
  });
}
}


/// @nodoc
mixin _$AdminActionLog {

 String? get id; String? get actor;/// Snapshot of the actor's address at call time, so deleting a staff
/// account does not delete the evidence that it acted.
@JsonKey(name: 'actor_email') String get actorEmail; String get action;@JsonKey(name: 'target_type') String get targetType;@JsonKey(name: 'target_id') String get targetId; String get summary;@JsonKey(name: 'before', fromJson: _stringKeyedMap) Map<String, dynamic>? get before;@JsonKey(name: 'after', fromJson: _stringKeyedMap) Map<String, dynamic>? get after;@JsonKey(name: 'request_id') String get requestId;@JsonKey(name: 'ip_address') String? get ipAddress;@JsonKey(name: 'user_agent') String get userAgent;@JsonKey(name: 'created_at') String? get createdAt;
/// Create a copy of AdminActionLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminActionLogCopyWith<AdminActionLog> get copyWith => _$AdminActionLogCopyWithImpl<AdminActionLog>(this as AdminActionLog, _$identity);

  /// Serializes this AdminActionLog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminActionLog&&(identical(other.id, id) || other.id == id)&&(identical(other.actor, actor) || other.actor == actor)&&(identical(other.actorEmail, actorEmail) || other.actorEmail == actorEmail)&&(identical(other.action, action) || other.action == action)&&(identical(other.targetType, targetType) || other.targetType == targetType)&&(identical(other.targetId, targetId) || other.targetId == targetId)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other.before, before)&&const DeepCollectionEquality().equals(other.after, after)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.userAgent, userAgent) || other.userAgent == userAgent)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,actor,actorEmail,action,targetType,targetId,summary,const DeepCollectionEquality().hash(before),const DeepCollectionEquality().hash(after),requestId,ipAddress,userAgent,createdAt);

@override
String toString() {
  return 'AdminActionLog(id: $id, actor: $actor, actorEmail: $actorEmail, action: $action, targetType: $targetType, targetId: $targetId, summary: $summary, before: $before, after: $after, requestId: $requestId, ipAddress: $ipAddress, userAgent: $userAgent, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $AdminActionLogCopyWith<$Res>  {
  factory $AdminActionLogCopyWith(AdminActionLog value, $Res Function(AdminActionLog) _then) = _$AdminActionLogCopyWithImpl;
@useResult
$Res call({
 String? id, String? actor,@JsonKey(name: 'actor_email') String actorEmail, String action,@JsonKey(name: 'target_type') String targetType,@JsonKey(name: 'target_id') String targetId, String summary,@JsonKey(name: 'before', fromJson: _stringKeyedMap) Map<String, dynamic>? before,@JsonKey(name: 'after', fromJson: _stringKeyedMap) Map<String, dynamic>? after,@JsonKey(name: 'request_id') String requestId,@JsonKey(name: 'ip_address') String? ipAddress,@JsonKey(name: 'user_agent') String userAgent,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class _$AdminActionLogCopyWithImpl<$Res>
    implements $AdminActionLogCopyWith<$Res> {
  _$AdminActionLogCopyWithImpl(this._self, this._then);

  final AdminActionLog _self;
  final $Res Function(AdminActionLog) _then;

/// Create a copy of AdminActionLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? actor = freezed,Object? actorEmail = null,Object? action = null,Object? targetType = null,Object? targetId = null,Object? summary = null,Object? before = freezed,Object? after = freezed,Object? requestId = null,Object? ipAddress = freezed,Object? userAgent = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,actor: freezed == actor ? _self.actor : actor // ignore: cast_nullable_to_non_nullable
as String?,actorEmail: null == actorEmail ? _self.actorEmail : actorEmail // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,targetType: null == targetType ? _self.targetType : targetType // ignore: cast_nullable_to_non_nullable
as String,targetId: null == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,before: freezed == before ? _self.before : before // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,after: freezed == after ? _self.after : after // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,ipAddress: freezed == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String?,userAgent: null == userAgent ? _self.userAgent : userAgent // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminActionLog].
extension AdminActionLogPatterns on AdminActionLog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminActionLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminActionLog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminActionLog value)  $default,){
final _that = this;
switch (_that) {
case _AdminActionLog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminActionLog value)?  $default,){
final _that = this;
switch (_that) {
case _AdminActionLog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? actor, @JsonKey(name: 'actor_email')  String actorEmail,  String action, @JsonKey(name: 'target_type')  String targetType, @JsonKey(name: 'target_id')  String targetId,  String summary, @JsonKey(name: 'before', fromJson: _stringKeyedMap)  Map<String, dynamic>? before, @JsonKey(name: 'after', fromJson: _stringKeyedMap)  Map<String, dynamic>? after, @JsonKey(name: 'request_id')  String requestId, @JsonKey(name: 'ip_address')  String? ipAddress, @JsonKey(name: 'user_agent')  String userAgent, @JsonKey(name: 'created_at')  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminActionLog() when $default != null:
return $default(_that.id,_that.actor,_that.actorEmail,_that.action,_that.targetType,_that.targetId,_that.summary,_that.before,_that.after,_that.requestId,_that.ipAddress,_that.userAgent,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? actor, @JsonKey(name: 'actor_email')  String actorEmail,  String action, @JsonKey(name: 'target_type')  String targetType, @JsonKey(name: 'target_id')  String targetId,  String summary, @JsonKey(name: 'before', fromJson: _stringKeyedMap)  Map<String, dynamic>? before, @JsonKey(name: 'after', fromJson: _stringKeyedMap)  Map<String, dynamic>? after, @JsonKey(name: 'request_id')  String requestId, @JsonKey(name: 'ip_address')  String? ipAddress, @JsonKey(name: 'user_agent')  String userAgent, @JsonKey(name: 'created_at')  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _AdminActionLog():
return $default(_that.id,_that.actor,_that.actorEmail,_that.action,_that.targetType,_that.targetId,_that.summary,_that.before,_that.after,_that.requestId,_that.ipAddress,_that.userAgent,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? actor, @JsonKey(name: 'actor_email')  String actorEmail,  String action, @JsonKey(name: 'target_type')  String targetType, @JsonKey(name: 'target_id')  String targetId,  String summary, @JsonKey(name: 'before', fromJson: _stringKeyedMap)  Map<String, dynamic>? before, @JsonKey(name: 'after', fromJson: _stringKeyedMap)  Map<String, dynamic>? after, @JsonKey(name: 'request_id')  String requestId, @JsonKey(name: 'ip_address')  String? ipAddress, @JsonKey(name: 'user_agent')  String userAgent, @JsonKey(name: 'created_at')  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _AdminActionLog() when $default != null:
return $default(_that.id,_that.actor,_that.actorEmail,_that.action,_that.targetType,_that.targetId,_that.summary,_that.before,_that.after,_that.requestId,_that.ipAddress,_that.userAgent,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminActionLog implements AdminActionLog {
  const _AdminActionLog({this.id, this.actor, @JsonKey(name: 'actor_email') this.actorEmail = '', this.action = '', @JsonKey(name: 'target_type') this.targetType = '', @JsonKey(name: 'target_id') this.targetId = '', this.summary = '', @JsonKey(name: 'before', fromJson: _stringKeyedMap) final  Map<String, dynamic>? before, @JsonKey(name: 'after', fromJson: _stringKeyedMap) final  Map<String, dynamic>? after, @JsonKey(name: 'request_id') this.requestId = '', @JsonKey(name: 'ip_address') this.ipAddress, @JsonKey(name: 'user_agent') this.userAgent = '', @JsonKey(name: 'created_at') this.createdAt}): _before = before,_after = after;
  factory _AdminActionLog.fromJson(Map<String, dynamic> json) => _$AdminActionLogFromJson(json);

@override final  String? id;
@override final  String? actor;
/// Snapshot of the actor's address at call time, so deleting a staff
/// account does not delete the evidence that it acted.
@override@JsonKey(name: 'actor_email') final  String actorEmail;
@override@JsonKey() final  String action;
@override@JsonKey(name: 'target_type') final  String targetType;
@override@JsonKey(name: 'target_id') final  String targetId;
@override@JsonKey() final  String summary;
 final  Map<String, dynamic>? _before;
@override@JsonKey(name: 'before', fromJson: _stringKeyedMap) Map<String, dynamic>? get before {
  final value = _before;
  if (value == null) return null;
  if (_before is EqualUnmodifiableMapView) return _before;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _after;
@override@JsonKey(name: 'after', fromJson: _stringKeyedMap) Map<String, dynamic>? get after {
  final value = _after;
  if (value == null) return null;
  if (_after is EqualUnmodifiableMapView) return _after;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey(name: 'request_id') final  String requestId;
@override@JsonKey(name: 'ip_address') final  String? ipAddress;
@override@JsonKey(name: 'user_agent') final  String userAgent;
@override@JsonKey(name: 'created_at') final  String? createdAt;

/// Create a copy of AdminActionLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminActionLogCopyWith<_AdminActionLog> get copyWith => __$AdminActionLogCopyWithImpl<_AdminActionLog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminActionLogToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminActionLog&&(identical(other.id, id) || other.id == id)&&(identical(other.actor, actor) || other.actor == actor)&&(identical(other.actorEmail, actorEmail) || other.actorEmail == actorEmail)&&(identical(other.action, action) || other.action == action)&&(identical(other.targetType, targetType) || other.targetType == targetType)&&(identical(other.targetId, targetId) || other.targetId == targetId)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other._before, _before)&&const DeepCollectionEquality().equals(other._after, _after)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.userAgent, userAgent) || other.userAgent == userAgent)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,actor,actorEmail,action,targetType,targetId,summary,const DeepCollectionEquality().hash(_before),const DeepCollectionEquality().hash(_after),requestId,ipAddress,userAgent,createdAt);

@override
String toString() {
  return 'AdminActionLog(id: $id, actor: $actor, actorEmail: $actorEmail, action: $action, targetType: $targetType, targetId: $targetId, summary: $summary, before: $before, after: $after, requestId: $requestId, ipAddress: $ipAddress, userAgent: $userAgent, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AdminActionLogCopyWith<$Res> implements $AdminActionLogCopyWith<$Res> {
  factory _$AdminActionLogCopyWith(_AdminActionLog value, $Res Function(_AdminActionLog) _then) = __$AdminActionLogCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? actor,@JsonKey(name: 'actor_email') String actorEmail, String action,@JsonKey(name: 'target_type') String targetType,@JsonKey(name: 'target_id') String targetId, String summary,@JsonKey(name: 'before', fromJson: _stringKeyedMap) Map<String, dynamic>? before,@JsonKey(name: 'after', fromJson: _stringKeyedMap) Map<String, dynamic>? after,@JsonKey(name: 'request_id') String requestId,@JsonKey(name: 'ip_address') String? ipAddress,@JsonKey(name: 'user_agent') String userAgent,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class __$AdminActionLogCopyWithImpl<$Res>
    implements _$AdminActionLogCopyWith<$Res> {
  __$AdminActionLogCopyWithImpl(this._self, this._then);

  final _AdminActionLog _self;
  final $Res Function(_AdminActionLog) _then;

/// Create a copy of AdminActionLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? actor = freezed,Object? actorEmail = null,Object? action = null,Object? targetType = null,Object? targetId = null,Object? summary = null,Object? before = freezed,Object? after = freezed,Object? requestId = null,Object? ipAddress = freezed,Object? userAgent = null,Object? createdAt = freezed,}) {
  return _then(_AdminActionLog(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,actor: freezed == actor ? _self.actor : actor // ignore: cast_nullable_to_non_nullable
as String?,actorEmail: null == actorEmail ? _self.actorEmail : actorEmail // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,targetType: null == targetType ? _self.targetType : targetType // ignore: cast_nullable_to_non_nullable
as String,targetId: null == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,before: freezed == before ? _self._before : before // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,after: freezed == after ? _self._after : after // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,ipAddress: freezed == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String?,userAgent: null == userAgent ? _self.userAgent : userAgent // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$EmailLog {

 String? get id;@JsonKey(name: 'recipient_user') String? get recipientUser;@JsonKey(name: 'recipient') GovernanceUserRef? get recipient;@JsonKey(name: 'recipient_email') String get recipientEmail; String get subject;@JsonKey(name: 'body_preview') String get bodyPreview;@JsonKey(name: 'template_key') String get templateKey;@JsonKey(name: 'sent_by') String? get sentBy;@JsonKey(name: 'sender') GovernanceUserRef? get sender;@JsonKey(name: 'sent_by_email') String get sentByEmail;/// queued / sent / failed / skipped.
 String get status; String get error;@JsonKey(name: 'dedupe_key') String get dedupeKey;@JsonKey(name: 'related_object_type') String get relatedObjectType;@JsonKey(name: 'related_object_id') String get relatedObjectId;@JsonKey(name: 'created_at') String? get createdAt;
/// Create a copy of EmailLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmailLogCopyWith<EmailLog> get copyWith => _$EmailLogCopyWithImpl<EmailLog>(this as EmailLog, _$identity);

  /// Serializes this EmailLog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmailLog&&(identical(other.id, id) || other.id == id)&&(identical(other.recipientUser, recipientUser) || other.recipientUser == recipientUser)&&(identical(other.recipient, recipient) || other.recipient == recipient)&&(identical(other.recipientEmail, recipientEmail) || other.recipientEmail == recipientEmail)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.bodyPreview, bodyPreview) || other.bodyPreview == bodyPreview)&&(identical(other.templateKey, templateKey) || other.templateKey == templateKey)&&(identical(other.sentBy, sentBy) || other.sentBy == sentBy)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.sentByEmail, sentByEmail) || other.sentByEmail == sentByEmail)&&(identical(other.status, status) || other.status == status)&&(identical(other.error, error) || other.error == error)&&(identical(other.dedupeKey, dedupeKey) || other.dedupeKey == dedupeKey)&&(identical(other.relatedObjectType, relatedObjectType) || other.relatedObjectType == relatedObjectType)&&(identical(other.relatedObjectId, relatedObjectId) || other.relatedObjectId == relatedObjectId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,recipientUser,recipient,recipientEmail,subject,bodyPreview,templateKey,sentBy,sender,sentByEmail,status,error,dedupeKey,relatedObjectType,relatedObjectId,createdAt);

@override
String toString() {
  return 'EmailLog(id: $id, recipientUser: $recipientUser, recipient: $recipient, recipientEmail: $recipientEmail, subject: $subject, bodyPreview: $bodyPreview, templateKey: $templateKey, sentBy: $sentBy, sender: $sender, sentByEmail: $sentByEmail, status: $status, error: $error, dedupeKey: $dedupeKey, relatedObjectType: $relatedObjectType, relatedObjectId: $relatedObjectId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $EmailLogCopyWith<$Res>  {
  factory $EmailLogCopyWith(EmailLog value, $Res Function(EmailLog) _then) = _$EmailLogCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(name: 'recipient_user') String? recipientUser,@JsonKey(name: 'recipient') GovernanceUserRef? recipient,@JsonKey(name: 'recipient_email') String recipientEmail, String subject,@JsonKey(name: 'body_preview') String bodyPreview,@JsonKey(name: 'template_key') String templateKey,@JsonKey(name: 'sent_by') String? sentBy,@JsonKey(name: 'sender') GovernanceUserRef? sender,@JsonKey(name: 'sent_by_email') String sentByEmail, String status, String error,@JsonKey(name: 'dedupe_key') String dedupeKey,@JsonKey(name: 'related_object_type') String relatedObjectType,@JsonKey(name: 'related_object_id') String relatedObjectId,@JsonKey(name: 'created_at') String? createdAt
});


$GovernanceUserRefCopyWith<$Res>? get recipient;$GovernanceUserRefCopyWith<$Res>? get sender;

}
/// @nodoc
class _$EmailLogCopyWithImpl<$Res>
    implements $EmailLogCopyWith<$Res> {
  _$EmailLogCopyWithImpl(this._self, this._then);

  final EmailLog _self;
  final $Res Function(EmailLog) _then;

/// Create a copy of EmailLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? recipientUser = freezed,Object? recipient = freezed,Object? recipientEmail = null,Object? subject = null,Object? bodyPreview = null,Object? templateKey = null,Object? sentBy = freezed,Object? sender = freezed,Object? sentByEmail = null,Object? status = null,Object? error = null,Object? dedupeKey = null,Object? relatedObjectType = null,Object? relatedObjectId = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,recipientUser: freezed == recipientUser ? _self.recipientUser : recipientUser // ignore: cast_nullable_to_non_nullable
as String?,recipient: freezed == recipient ? _self.recipient : recipient // ignore: cast_nullable_to_non_nullable
as GovernanceUserRef?,recipientEmail: null == recipientEmail ? _self.recipientEmail : recipientEmail // ignore: cast_nullable_to_non_nullable
as String,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,bodyPreview: null == bodyPreview ? _self.bodyPreview : bodyPreview // ignore: cast_nullable_to_non_nullable
as String,templateKey: null == templateKey ? _self.templateKey : templateKey // ignore: cast_nullable_to_non_nullable
as String,sentBy: freezed == sentBy ? _self.sentBy : sentBy // ignore: cast_nullable_to_non_nullable
as String?,sender: freezed == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as GovernanceUserRef?,sentByEmail: null == sentByEmail ? _self.sentByEmail : sentByEmail // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,dedupeKey: null == dedupeKey ? _self.dedupeKey : dedupeKey // ignore: cast_nullable_to_non_nullable
as String,relatedObjectType: null == relatedObjectType ? _self.relatedObjectType : relatedObjectType // ignore: cast_nullable_to_non_nullable
as String,relatedObjectId: null == relatedObjectId ? _self.relatedObjectId : relatedObjectId // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of EmailLog
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GovernanceUserRefCopyWith<$Res>? get recipient {
    if (_self.recipient == null) {
    return null;
  }

  return $GovernanceUserRefCopyWith<$Res>(_self.recipient!, (value) {
    return _then(_self.copyWith(recipient: value));
  });
}/// Create a copy of EmailLog
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GovernanceUserRefCopyWith<$Res>? get sender {
    if (_self.sender == null) {
    return null;
  }

  return $GovernanceUserRefCopyWith<$Res>(_self.sender!, (value) {
    return _then(_self.copyWith(sender: value));
  });
}
}


/// Adds pattern-matching-related methods to [EmailLog].
extension EmailLogPatterns on EmailLog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmailLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmailLog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmailLog value)  $default,){
final _that = this;
switch (_that) {
case _EmailLog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmailLog value)?  $default,){
final _that = this;
switch (_that) {
case _EmailLog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'recipient_user')  String? recipientUser, @JsonKey(name: 'recipient')  GovernanceUserRef? recipient, @JsonKey(name: 'recipient_email')  String recipientEmail,  String subject, @JsonKey(name: 'body_preview')  String bodyPreview, @JsonKey(name: 'template_key')  String templateKey, @JsonKey(name: 'sent_by')  String? sentBy, @JsonKey(name: 'sender')  GovernanceUserRef? sender, @JsonKey(name: 'sent_by_email')  String sentByEmail,  String status,  String error, @JsonKey(name: 'dedupe_key')  String dedupeKey, @JsonKey(name: 'related_object_type')  String relatedObjectType, @JsonKey(name: 'related_object_id')  String relatedObjectId, @JsonKey(name: 'created_at')  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmailLog() when $default != null:
return $default(_that.id,_that.recipientUser,_that.recipient,_that.recipientEmail,_that.subject,_that.bodyPreview,_that.templateKey,_that.sentBy,_that.sender,_that.sentByEmail,_that.status,_that.error,_that.dedupeKey,_that.relatedObjectType,_that.relatedObjectId,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'recipient_user')  String? recipientUser, @JsonKey(name: 'recipient')  GovernanceUserRef? recipient, @JsonKey(name: 'recipient_email')  String recipientEmail,  String subject, @JsonKey(name: 'body_preview')  String bodyPreview, @JsonKey(name: 'template_key')  String templateKey, @JsonKey(name: 'sent_by')  String? sentBy, @JsonKey(name: 'sender')  GovernanceUserRef? sender, @JsonKey(name: 'sent_by_email')  String sentByEmail,  String status,  String error, @JsonKey(name: 'dedupe_key')  String dedupeKey, @JsonKey(name: 'related_object_type')  String relatedObjectType, @JsonKey(name: 'related_object_id')  String relatedObjectId, @JsonKey(name: 'created_at')  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _EmailLog():
return $default(_that.id,_that.recipientUser,_that.recipient,_that.recipientEmail,_that.subject,_that.bodyPreview,_that.templateKey,_that.sentBy,_that.sender,_that.sentByEmail,_that.status,_that.error,_that.dedupeKey,_that.relatedObjectType,_that.relatedObjectId,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(name: 'recipient_user')  String? recipientUser, @JsonKey(name: 'recipient')  GovernanceUserRef? recipient, @JsonKey(name: 'recipient_email')  String recipientEmail,  String subject, @JsonKey(name: 'body_preview')  String bodyPreview, @JsonKey(name: 'template_key')  String templateKey, @JsonKey(name: 'sent_by')  String? sentBy, @JsonKey(name: 'sender')  GovernanceUserRef? sender, @JsonKey(name: 'sent_by_email')  String sentByEmail,  String status,  String error, @JsonKey(name: 'dedupe_key')  String dedupeKey, @JsonKey(name: 'related_object_type')  String relatedObjectType, @JsonKey(name: 'related_object_id')  String relatedObjectId, @JsonKey(name: 'created_at')  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _EmailLog() when $default != null:
return $default(_that.id,_that.recipientUser,_that.recipient,_that.recipientEmail,_that.subject,_that.bodyPreview,_that.templateKey,_that.sentBy,_that.sender,_that.sentByEmail,_that.status,_that.error,_that.dedupeKey,_that.relatedObjectType,_that.relatedObjectId,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EmailLog implements EmailLog {
  const _EmailLog({this.id, @JsonKey(name: 'recipient_user') this.recipientUser, @JsonKey(name: 'recipient') this.recipient, @JsonKey(name: 'recipient_email') this.recipientEmail = '', this.subject = '', @JsonKey(name: 'body_preview') this.bodyPreview = '', @JsonKey(name: 'template_key') this.templateKey = '', @JsonKey(name: 'sent_by') this.sentBy, @JsonKey(name: 'sender') this.sender, @JsonKey(name: 'sent_by_email') this.sentByEmail = '', this.status = '', this.error = '', @JsonKey(name: 'dedupe_key') this.dedupeKey = '', @JsonKey(name: 'related_object_type') this.relatedObjectType = '', @JsonKey(name: 'related_object_id') this.relatedObjectId = '', @JsonKey(name: 'created_at') this.createdAt});
  factory _EmailLog.fromJson(Map<String, dynamic> json) => _$EmailLogFromJson(json);

@override final  String? id;
@override@JsonKey(name: 'recipient_user') final  String? recipientUser;
@override@JsonKey(name: 'recipient') final  GovernanceUserRef? recipient;
@override@JsonKey(name: 'recipient_email') final  String recipientEmail;
@override@JsonKey() final  String subject;
@override@JsonKey(name: 'body_preview') final  String bodyPreview;
@override@JsonKey(name: 'template_key') final  String templateKey;
@override@JsonKey(name: 'sent_by') final  String? sentBy;
@override@JsonKey(name: 'sender') final  GovernanceUserRef? sender;
@override@JsonKey(name: 'sent_by_email') final  String sentByEmail;
/// queued / sent / failed / skipped.
@override@JsonKey() final  String status;
@override@JsonKey() final  String error;
@override@JsonKey(name: 'dedupe_key') final  String dedupeKey;
@override@JsonKey(name: 'related_object_type') final  String relatedObjectType;
@override@JsonKey(name: 'related_object_id') final  String relatedObjectId;
@override@JsonKey(name: 'created_at') final  String? createdAt;

/// Create a copy of EmailLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmailLogCopyWith<_EmailLog> get copyWith => __$EmailLogCopyWithImpl<_EmailLog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EmailLogToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmailLog&&(identical(other.id, id) || other.id == id)&&(identical(other.recipientUser, recipientUser) || other.recipientUser == recipientUser)&&(identical(other.recipient, recipient) || other.recipient == recipient)&&(identical(other.recipientEmail, recipientEmail) || other.recipientEmail == recipientEmail)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.bodyPreview, bodyPreview) || other.bodyPreview == bodyPreview)&&(identical(other.templateKey, templateKey) || other.templateKey == templateKey)&&(identical(other.sentBy, sentBy) || other.sentBy == sentBy)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.sentByEmail, sentByEmail) || other.sentByEmail == sentByEmail)&&(identical(other.status, status) || other.status == status)&&(identical(other.error, error) || other.error == error)&&(identical(other.dedupeKey, dedupeKey) || other.dedupeKey == dedupeKey)&&(identical(other.relatedObjectType, relatedObjectType) || other.relatedObjectType == relatedObjectType)&&(identical(other.relatedObjectId, relatedObjectId) || other.relatedObjectId == relatedObjectId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,recipientUser,recipient,recipientEmail,subject,bodyPreview,templateKey,sentBy,sender,sentByEmail,status,error,dedupeKey,relatedObjectType,relatedObjectId,createdAt);

@override
String toString() {
  return 'EmailLog(id: $id, recipientUser: $recipientUser, recipient: $recipient, recipientEmail: $recipientEmail, subject: $subject, bodyPreview: $bodyPreview, templateKey: $templateKey, sentBy: $sentBy, sender: $sender, sentByEmail: $sentByEmail, status: $status, error: $error, dedupeKey: $dedupeKey, relatedObjectType: $relatedObjectType, relatedObjectId: $relatedObjectId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$EmailLogCopyWith<$Res> implements $EmailLogCopyWith<$Res> {
  factory _$EmailLogCopyWith(_EmailLog value, $Res Function(_EmailLog) _then) = __$EmailLogCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(name: 'recipient_user') String? recipientUser,@JsonKey(name: 'recipient') GovernanceUserRef? recipient,@JsonKey(name: 'recipient_email') String recipientEmail, String subject,@JsonKey(name: 'body_preview') String bodyPreview,@JsonKey(name: 'template_key') String templateKey,@JsonKey(name: 'sent_by') String? sentBy,@JsonKey(name: 'sender') GovernanceUserRef? sender,@JsonKey(name: 'sent_by_email') String sentByEmail, String status, String error,@JsonKey(name: 'dedupe_key') String dedupeKey,@JsonKey(name: 'related_object_type') String relatedObjectType,@JsonKey(name: 'related_object_id') String relatedObjectId,@JsonKey(name: 'created_at') String? createdAt
});


@override $GovernanceUserRefCopyWith<$Res>? get recipient;@override $GovernanceUserRefCopyWith<$Res>? get sender;

}
/// @nodoc
class __$EmailLogCopyWithImpl<$Res>
    implements _$EmailLogCopyWith<$Res> {
  __$EmailLogCopyWithImpl(this._self, this._then);

  final _EmailLog _self;
  final $Res Function(_EmailLog) _then;

/// Create a copy of EmailLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? recipientUser = freezed,Object? recipient = freezed,Object? recipientEmail = null,Object? subject = null,Object? bodyPreview = null,Object? templateKey = null,Object? sentBy = freezed,Object? sender = freezed,Object? sentByEmail = null,Object? status = null,Object? error = null,Object? dedupeKey = null,Object? relatedObjectType = null,Object? relatedObjectId = null,Object? createdAt = freezed,}) {
  return _then(_EmailLog(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,recipientUser: freezed == recipientUser ? _self.recipientUser : recipientUser // ignore: cast_nullable_to_non_nullable
as String?,recipient: freezed == recipient ? _self.recipient : recipient // ignore: cast_nullable_to_non_nullable
as GovernanceUserRef?,recipientEmail: null == recipientEmail ? _self.recipientEmail : recipientEmail // ignore: cast_nullable_to_non_nullable
as String,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,bodyPreview: null == bodyPreview ? _self.bodyPreview : bodyPreview // ignore: cast_nullable_to_non_nullable
as String,templateKey: null == templateKey ? _self.templateKey : templateKey // ignore: cast_nullable_to_non_nullable
as String,sentBy: freezed == sentBy ? _self.sentBy : sentBy // ignore: cast_nullable_to_non_nullable
as String?,sender: freezed == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as GovernanceUserRef?,sentByEmail: null == sentByEmail ? _self.sentByEmail : sentByEmail // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,dedupeKey: null == dedupeKey ? _self.dedupeKey : dedupeKey // ignore: cast_nullable_to_non_nullable
as String,relatedObjectType: null == relatedObjectType ? _self.relatedObjectType : relatedObjectType // ignore: cast_nullable_to_non_nullable
as String,relatedObjectId: null == relatedObjectId ? _self.relatedObjectId : relatedObjectId // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of EmailLog
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GovernanceUserRefCopyWith<$Res>? get recipient {
    if (_self.recipient == null) {
    return null;
  }

  return $GovernanceUserRefCopyWith<$Res>(_self.recipient!, (value) {
    return _then(_self.copyWith(recipient: value));
  });
}/// Create a copy of EmailLog
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GovernanceUserRefCopyWith<$Res>? get sender {
    if (_self.sender == null) {
    return null;
  }

  return $GovernanceUserRefCopyWith<$Res>(_self.sender!, (value) {
    return _then(_self.copyWith(sender: value));
  });
}
}


/// @nodoc
mixin _$ContentFlag {

 String? get id;@JsonKey(name: 'flag_reason') String get flagReason; String get severity;@JsonKey(name: 'confidence', fromJson: _optDoubleOrZero) double get confidence; String get source;@JsonKey(name: 'content_type') String get contentType;@JsonKey(name: 'content_id') String get contentId;@JsonKey(name: 'content_preview') String get contentPreview;@JsonKey(name: 'is_actioned') bool get isActioned;@JsonKey(name: 'action_taken') String get actionTaken;@JsonKey(name: 'created_at') String? get createdAt;
/// Create a copy of ContentFlag
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContentFlagCopyWith<ContentFlag> get copyWith => _$ContentFlagCopyWithImpl<ContentFlag>(this as ContentFlag, _$identity);

  /// Serializes this ContentFlag to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContentFlag&&(identical(other.id, id) || other.id == id)&&(identical(other.flagReason, flagReason) || other.flagReason == flagReason)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.source, source) || other.source == source)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.contentId, contentId) || other.contentId == contentId)&&(identical(other.contentPreview, contentPreview) || other.contentPreview == contentPreview)&&(identical(other.isActioned, isActioned) || other.isActioned == isActioned)&&(identical(other.actionTaken, actionTaken) || other.actionTaken == actionTaken)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,flagReason,severity,confidence,source,contentType,contentId,contentPreview,isActioned,actionTaken,createdAt);

@override
String toString() {
  return 'ContentFlag(id: $id, flagReason: $flagReason, severity: $severity, confidence: $confidence, source: $source, contentType: $contentType, contentId: $contentId, contentPreview: $contentPreview, isActioned: $isActioned, actionTaken: $actionTaken, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ContentFlagCopyWith<$Res>  {
  factory $ContentFlagCopyWith(ContentFlag value, $Res Function(ContentFlag) _then) = _$ContentFlagCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(name: 'flag_reason') String flagReason, String severity,@JsonKey(name: 'confidence', fromJson: _optDoubleOrZero) double confidence, String source,@JsonKey(name: 'content_type') String contentType,@JsonKey(name: 'content_id') String contentId,@JsonKey(name: 'content_preview') String contentPreview,@JsonKey(name: 'is_actioned') bool isActioned,@JsonKey(name: 'action_taken') String actionTaken,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class _$ContentFlagCopyWithImpl<$Res>
    implements $ContentFlagCopyWith<$Res> {
  _$ContentFlagCopyWithImpl(this._self, this._then);

  final ContentFlag _self;
  final $Res Function(ContentFlag) _then;

/// Create a copy of ContentFlag
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? flagReason = null,Object? severity = null,Object? confidence = null,Object? source = null,Object? contentType = null,Object? contentId = null,Object? contentPreview = null,Object? isActioned = null,Object? actionTaken = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,flagReason: null == flagReason ? _self.flagReason : flagReason // ignore: cast_nullable_to_non_nullable
as String,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,contentId: null == contentId ? _self.contentId : contentId // ignore: cast_nullable_to_non_nullable
as String,contentPreview: null == contentPreview ? _self.contentPreview : contentPreview // ignore: cast_nullable_to_non_nullable
as String,isActioned: null == isActioned ? _self.isActioned : isActioned // ignore: cast_nullable_to_non_nullable
as bool,actionTaken: null == actionTaken ? _self.actionTaken : actionTaken // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ContentFlag].
extension ContentFlagPatterns on ContentFlag {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContentFlag value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContentFlag() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContentFlag value)  $default,){
final _that = this;
switch (_that) {
case _ContentFlag():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContentFlag value)?  $default,){
final _that = this;
switch (_that) {
case _ContentFlag() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'flag_reason')  String flagReason,  String severity, @JsonKey(name: 'confidence', fromJson: _optDoubleOrZero)  double confidence,  String source, @JsonKey(name: 'content_type')  String contentType, @JsonKey(name: 'content_id')  String contentId, @JsonKey(name: 'content_preview')  String contentPreview, @JsonKey(name: 'is_actioned')  bool isActioned, @JsonKey(name: 'action_taken')  String actionTaken, @JsonKey(name: 'created_at')  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContentFlag() when $default != null:
return $default(_that.id,_that.flagReason,_that.severity,_that.confidence,_that.source,_that.contentType,_that.contentId,_that.contentPreview,_that.isActioned,_that.actionTaken,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'flag_reason')  String flagReason,  String severity, @JsonKey(name: 'confidence', fromJson: _optDoubleOrZero)  double confidence,  String source, @JsonKey(name: 'content_type')  String contentType, @JsonKey(name: 'content_id')  String contentId, @JsonKey(name: 'content_preview')  String contentPreview, @JsonKey(name: 'is_actioned')  bool isActioned, @JsonKey(name: 'action_taken')  String actionTaken, @JsonKey(name: 'created_at')  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _ContentFlag():
return $default(_that.id,_that.flagReason,_that.severity,_that.confidence,_that.source,_that.contentType,_that.contentId,_that.contentPreview,_that.isActioned,_that.actionTaken,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(name: 'flag_reason')  String flagReason,  String severity, @JsonKey(name: 'confidence', fromJson: _optDoubleOrZero)  double confidence,  String source, @JsonKey(name: 'content_type')  String contentType, @JsonKey(name: 'content_id')  String contentId, @JsonKey(name: 'content_preview')  String contentPreview, @JsonKey(name: 'is_actioned')  bool isActioned, @JsonKey(name: 'action_taken')  String actionTaken, @JsonKey(name: 'created_at')  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ContentFlag() when $default != null:
return $default(_that.id,_that.flagReason,_that.severity,_that.confidence,_that.source,_that.contentType,_that.contentId,_that.contentPreview,_that.isActioned,_that.actionTaken,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContentFlag implements ContentFlag {
  const _ContentFlag({this.id, @JsonKey(name: 'flag_reason') this.flagReason = '', this.severity = '', @JsonKey(name: 'confidence', fromJson: _optDoubleOrZero) this.confidence = 0.0, this.source = 'auto', @JsonKey(name: 'content_type') this.contentType = '', @JsonKey(name: 'content_id') this.contentId = '', @JsonKey(name: 'content_preview') this.contentPreview = '', @JsonKey(name: 'is_actioned') this.isActioned = false, @JsonKey(name: 'action_taken') this.actionTaken = '', @JsonKey(name: 'created_at') this.createdAt});
  factory _ContentFlag.fromJson(Map<String, dynamic> json) => _$ContentFlagFromJson(json);

@override final  String? id;
@override@JsonKey(name: 'flag_reason') final  String flagReason;
@override@JsonKey() final  String severity;
@override@JsonKey(name: 'confidence', fromJson: _optDoubleOrZero) final  double confidence;
@override@JsonKey() final  String source;
@override@JsonKey(name: 'content_type') final  String contentType;
@override@JsonKey(name: 'content_id') final  String contentId;
@override@JsonKey(name: 'content_preview') final  String contentPreview;
@override@JsonKey(name: 'is_actioned') final  bool isActioned;
@override@JsonKey(name: 'action_taken') final  String actionTaken;
@override@JsonKey(name: 'created_at') final  String? createdAt;

/// Create a copy of ContentFlag
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContentFlagCopyWith<_ContentFlag> get copyWith => __$ContentFlagCopyWithImpl<_ContentFlag>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContentFlagToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContentFlag&&(identical(other.id, id) || other.id == id)&&(identical(other.flagReason, flagReason) || other.flagReason == flagReason)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.source, source) || other.source == source)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.contentId, contentId) || other.contentId == contentId)&&(identical(other.contentPreview, contentPreview) || other.contentPreview == contentPreview)&&(identical(other.isActioned, isActioned) || other.isActioned == isActioned)&&(identical(other.actionTaken, actionTaken) || other.actionTaken == actionTaken)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,flagReason,severity,confidence,source,contentType,contentId,contentPreview,isActioned,actionTaken,createdAt);

@override
String toString() {
  return 'ContentFlag(id: $id, flagReason: $flagReason, severity: $severity, confidence: $confidence, source: $source, contentType: $contentType, contentId: $contentId, contentPreview: $contentPreview, isActioned: $isActioned, actionTaken: $actionTaken, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ContentFlagCopyWith<$Res> implements $ContentFlagCopyWith<$Res> {
  factory _$ContentFlagCopyWith(_ContentFlag value, $Res Function(_ContentFlag) _then) = __$ContentFlagCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(name: 'flag_reason') String flagReason, String severity,@JsonKey(name: 'confidence', fromJson: _optDoubleOrZero) double confidence, String source,@JsonKey(name: 'content_type') String contentType,@JsonKey(name: 'content_id') String contentId,@JsonKey(name: 'content_preview') String contentPreview,@JsonKey(name: 'is_actioned') bool isActioned,@JsonKey(name: 'action_taken') String actionTaken,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class __$ContentFlagCopyWithImpl<$Res>
    implements _$ContentFlagCopyWith<$Res> {
  __$ContentFlagCopyWithImpl(this._self, this._then);

  final _ContentFlag _self;
  final $Res Function(_ContentFlag) _then;

/// Create a copy of ContentFlag
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? flagReason = null,Object? severity = null,Object? confidence = null,Object? source = null,Object? contentType = null,Object? contentId = null,Object? contentPreview = null,Object? isActioned = null,Object? actionTaken = null,Object? createdAt = freezed,}) {
  return _then(_ContentFlag(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,flagReason: null == flagReason ? _self.flagReason : flagReason // ignore: cast_nullable_to_non_nullable
as String,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,contentId: null == contentId ? _self.contentId : contentId // ignore: cast_nullable_to_non_nullable
as String,contentPreview: null == contentPreview ? _self.contentPreview : contentPreview // ignore: cast_nullable_to_non_nullable
as String,isActioned: null == isActioned ? _self.isActioned : isActioned // ignore: cast_nullable_to_non_nullable
as bool,actionTaken: null == actionTaken ? _self.actionTaken : actionTaken // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ModerationStats {

 int get total; int get unactioned; int get actioned;@JsonKey(name: 'by_severity', fromJson: _stringKeyedMapOrEmpty) Map<String, dynamic> get bySeverity;@JsonKey(name: 'by_reason', fromJson: _stringKeyedMapOrEmpty) Map<String, dynamic> get byReason;
/// Create a copy of ModerationStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModerationStatsCopyWith<ModerationStats> get copyWith => _$ModerationStatsCopyWithImpl<ModerationStats>(this as ModerationStats, _$identity);

  /// Serializes this ModerationStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModerationStats&&(identical(other.total, total) || other.total == total)&&(identical(other.unactioned, unactioned) || other.unactioned == unactioned)&&(identical(other.actioned, actioned) || other.actioned == actioned)&&const DeepCollectionEquality().equals(other.bySeverity, bySeverity)&&const DeepCollectionEquality().equals(other.byReason, byReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total,unactioned,actioned,const DeepCollectionEquality().hash(bySeverity),const DeepCollectionEquality().hash(byReason));

@override
String toString() {
  return 'ModerationStats(total: $total, unactioned: $unactioned, actioned: $actioned, bySeverity: $bySeverity, byReason: $byReason)';
}


}

/// @nodoc
abstract mixin class $ModerationStatsCopyWith<$Res>  {
  factory $ModerationStatsCopyWith(ModerationStats value, $Res Function(ModerationStats) _then) = _$ModerationStatsCopyWithImpl;
@useResult
$Res call({
 int total, int unactioned, int actioned,@JsonKey(name: 'by_severity', fromJson: _stringKeyedMapOrEmpty) Map<String, dynamic> bySeverity,@JsonKey(name: 'by_reason', fromJson: _stringKeyedMapOrEmpty) Map<String, dynamic> byReason
});




}
/// @nodoc
class _$ModerationStatsCopyWithImpl<$Res>
    implements $ModerationStatsCopyWith<$Res> {
  _$ModerationStatsCopyWithImpl(this._self, this._then);

  final ModerationStats _self;
  final $Res Function(ModerationStats) _then;

/// Create a copy of ModerationStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? total = null,Object? unactioned = null,Object? actioned = null,Object? bySeverity = null,Object? byReason = null,}) {
  return _then(_self.copyWith(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,unactioned: null == unactioned ? _self.unactioned : unactioned // ignore: cast_nullable_to_non_nullable
as int,actioned: null == actioned ? _self.actioned : actioned // ignore: cast_nullable_to_non_nullable
as int,bySeverity: null == bySeverity ? _self.bySeverity : bySeverity // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,byReason: null == byReason ? _self.byReason : byReason // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [ModerationStats].
extension ModerationStatsPatterns on ModerationStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModerationStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModerationStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModerationStats value)  $default,){
final _that = this;
switch (_that) {
case _ModerationStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModerationStats value)?  $default,){
final _that = this;
switch (_that) {
case _ModerationStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int total,  int unactioned,  int actioned, @JsonKey(name: 'by_severity', fromJson: _stringKeyedMapOrEmpty)  Map<String, dynamic> bySeverity, @JsonKey(name: 'by_reason', fromJson: _stringKeyedMapOrEmpty)  Map<String, dynamic> byReason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModerationStats() when $default != null:
return $default(_that.total,_that.unactioned,_that.actioned,_that.bySeverity,_that.byReason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int total,  int unactioned,  int actioned, @JsonKey(name: 'by_severity', fromJson: _stringKeyedMapOrEmpty)  Map<String, dynamic> bySeverity, @JsonKey(name: 'by_reason', fromJson: _stringKeyedMapOrEmpty)  Map<String, dynamic> byReason)  $default,) {final _that = this;
switch (_that) {
case _ModerationStats():
return $default(_that.total,_that.unactioned,_that.actioned,_that.bySeverity,_that.byReason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int total,  int unactioned,  int actioned, @JsonKey(name: 'by_severity', fromJson: _stringKeyedMapOrEmpty)  Map<String, dynamic> bySeverity, @JsonKey(name: 'by_reason', fromJson: _stringKeyedMapOrEmpty)  Map<String, dynamic> byReason)?  $default,) {final _that = this;
switch (_that) {
case _ModerationStats() when $default != null:
return $default(_that.total,_that.unactioned,_that.actioned,_that.bySeverity,_that.byReason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ModerationStats implements ModerationStats {
  const _ModerationStats({this.total = 0, this.unactioned = 0, this.actioned = 0, @JsonKey(name: 'by_severity', fromJson: _stringKeyedMapOrEmpty) final  Map<String, dynamic> bySeverity = const <String, dynamic>{}, @JsonKey(name: 'by_reason', fromJson: _stringKeyedMapOrEmpty) final  Map<String, dynamic> byReason = const <String, dynamic>{}}): _bySeverity = bySeverity,_byReason = byReason;
  factory _ModerationStats.fromJson(Map<String, dynamic> json) => _$ModerationStatsFromJson(json);

@override@JsonKey() final  int total;
@override@JsonKey() final  int unactioned;
@override@JsonKey() final  int actioned;
 final  Map<String, dynamic> _bySeverity;
@override@JsonKey(name: 'by_severity', fromJson: _stringKeyedMapOrEmpty) Map<String, dynamic> get bySeverity {
  if (_bySeverity is EqualUnmodifiableMapView) return _bySeverity;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_bySeverity);
}

 final  Map<String, dynamic> _byReason;
@override@JsonKey(name: 'by_reason', fromJson: _stringKeyedMapOrEmpty) Map<String, dynamic> get byReason {
  if (_byReason is EqualUnmodifiableMapView) return _byReason;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_byReason);
}


/// Create a copy of ModerationStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModerationStatsCopyWith<_ModerationStats> get copyWith => __$ModerationStatsCopyWithImpl<_ModerationStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ModerationStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModerationStats&&(identical(other.total, total) || other.total == total)&&(identical(other.unactioned, unactioned) || other.unactioned == unactioned)&&(identical(other.actioned, actioned) || other.actioned == actioned)&&const DeepCollectionEquality().equals(other._bySeverity, _bySeverity)&&const DeepCollectionEquality().equals(other._byReason, _byReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total,unactioned,actioned,const DeepCollectionEquality().hash(_bySeverity),const DeepCollectionEquality().hash(_byReason));

@override
String toString() {
  return 'ModerationStats(total: $total, unactioned: $unactioned, actioned: $actioned, bySeverity: $bySeverity, byReason: $byReason)';
}


}

/// @nodoc
abstract mixin class _$ModerationStatsCopyWith<$Res> implements $ModerationStatsCopyWith<$Res> {
  factory _$ModerationStatsCopyWith(_ModerationStats value, $Res Function(_ModerationStats) _then) = __$ModerationStatsCopyWithImpl;
@override @useResult
$Res call({
 int total, int unactioned, int actioned,@JsonKey(name: 'by_severity', fromJson: _stringKeyedMapOrEmpty) Map<String, dynamic> bySeverity,@JsonKey(name: 'by_reason', fromJson: _stringKeyedMapOrEmpty) Map<String, dynamic> byReason
});




}
/// @nodoc
class __$ModerationStatsCopyWithImpl<$Res>
    implements _$ModerationStatsCopyWith<$Res> {
  __$ModerationStatsCopyWithImpl(this._self, this._then);

  final _ModerationStats _self;
  final $Res Function(_ModerationStats) _then;

/// Create a copy of ModerationStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? total = null,Object? unactioned = null,Object? actioned = null,Object? bySeverity = null,Object? byReason = null,}) {
  return _then(_ModerationStats(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,unactioned: null == unactioned ? _self.unactioned : unactioned // ignore: cast_nullable_to_non_nullable
as int,actioned: null == actioned ? _self.actioned : actioned // ignore: cast_nullable_to_non_nullable
as int,bySeverity: null == bySeverity ? _self._bySeverity : bySeverity // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,byReason: null == byReason ? _self._byReason : byReason // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}


/// @nodoc
mixin _$ModerationReport {

 String? get id; String? get reporter;@JsonKey(name: 'target_user') String? get targetUser; String get reason; String get description;@JsonKey(name: 'content_url') String get contentUrl;/// open / investigating / resolved / dismissed.
 String get status;@JsonKey(name: 'assigned_to') String? get assignedTo;@JsonKey(name: 'resolved_at') String? get resolvedAt;@JsonKey(name: 'resolution_note') String get resolutionNote;@JsonKey(name: 'sla_due_at') String? get slaDueAt;@JsonKey(name: 'sla_breached') bool get slaBreached;@JsonKey(name: 'created_at') String? get createdAt;
/// Create a copy of ModerationReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModerationReportCopyWith<ModerationReport> get copyWith => _$ModerationReportCopyWithImpl<ModerationReport>(this as ModerationReport, _$identity);

  /// Serializes this ModerationReport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModerationReport&&(identical(other.id, id) || other.id == id)&&(identical(other.reporter, reporter) || other.reporter == reporter)&&(identical(other.targetUser, targetUser) || other.targetUser == targetUser)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.description, description) || other.description == description)&&(identical(other.contentUrl, contentUrl) || other.contentUrl == contentUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.assignedTo, assignedTo) || other.assignedTo == assignedTo)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.resolutionNote, resolutionNote) || other.resolutionNote == resolutionNote)&&(identical(other.slaDueAt, slaDueAt) || other.slaDueAt == slaDueAt)&&(identical(other.slaBreached, slaBreached) || other.slaBreached == slaBreached)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reporter,targetUser,reason,description,contentUrl,status,assignedTo,resolvedAt,resolutionNote,slaDueAt,slaBreached,createdAt);

@override
String toString() {
  return 'ModerationReport(id: $id, reporter: $reporter, targetUser: $targetUser, reason: $reason, description: $description, contentUrl: $contentUrl, status: $status, assignedTo: $assignedTo, resolvedAt: $resolvedAt, resolutionNote: $resolutionNote, slaDueAt: $slaDueAt, slaBreached: $slaBreached, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ModerationReportCopyWith<$Res>  {
  factory $ModerationReportCopyWith(ModerationReport value, $Res Function(ModerationReport) _then) = _$ModerationReportCopyWithImpl;
@useResult
$Res call({
 String? id, String? reporter,@JsonKey(name: 'target_user') String? targetUser, String reason, String description,@JsonKey(name: 'content_url') String contentUrl, String status,@JsonKey(name: 'assigned_to') String? assignedTo,@JsonKey(name: 'resolved_at') String? resolvedAt,@JsonKey(name: 'resolution_note') String resolutionNote,@JsonKey(name: 'sla_due_at') String? slaDueAt,@JsonKey(name: 'sla_breached') bool slaBreached,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class _$ModerationReportCopyWithImpl<$Res>
    implements $ModerationReportCopyWith<$Res> {
  _$ModerationReportCopyWithImpl(this._self, this._then);

  final ModerationReport _self;
  final $Res Function(ModerationReport) _then;

/// Create a copy of ModerationReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? reporter = freezed,Object? targetUser = freezed,Object? reason = null,Object? description = null,Object? contentUrl = null,Object? status = null,Object? assignedTo = freezed,Object? resolvedAt = freezed,Object? resolutionNote = null,Object? slaDueAt = freezed,Object? slaBreached = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,reporter: freezed == reporter ? _self.reporter : reporter // ignore: cast_nullable_to_non_nullable
as String?,targetUser: freezed == targetUser ? _self.targetUser : targetUser // ignore: cast_nullable_to_non_nullable
as String?,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,contentUrl: null == contentUrl ? _self.contentUrl : contentUrl // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,assignedTo: freezed == assignedTo ? _self.assignedTo : assignedTo // ignore: cast_nullable_to_non_nullable
as String?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as String?,resolutionNote: null == resolutionNote ? _self.resolutionNote : resolutionNote // ignore: cast_nullable_to_non_nullable
as String,slaDueAt: freezed == slaDueAt ? _self.slaDueAt : slaDueAt // ignore: cast_nullable_to_non_nullable
as String?,slaBreached: null == slaBreached ? _self.slaBreached : slaBreached // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ModerationReport].
extension ModerationReportPatterns on ModerationReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModerationReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModerationReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModerationReport value)  $default,){
final _that = this;
switch (_that) {
case _ModerationReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModerationReport value)?  $default,){
final _that = this;
switch (_that) {
case _ModerationReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? reporter, @JsonKey(name: 'target_user')  String? targetUser,  String reason,  String description, @JsonKey(name: 'content_url')  String contentUrl,  String status, @JsonKey(name: 'assigned_to')  String? assignedTo, @JsonKey(name: 'resolved_at')  String? resolvedAt, @JsonKey(name: 'resolution_note')  String resolutionNote, @JsonKey(name: 'sla_due_at')  String? slaDueAt, @JsonKey(name: 'sla_breached')  bool slaBreached, @JsonKey(name: 'created_at')  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModerationReport() when $default != null:
return $default(_that.id,_that.reporter,_that.targetUser,_that.reason,_that.description,_that.contentUrl,_that.status,_that.assignedTo,_that.resolvedAt,_that.resolutionNote,_that.slaDueAt,_that.slaBreached,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? reporter, @JsonKey(name: 'target_user')  String? targetUser,  String reason,  String description, @JsonKey(name: 'content_url')  String contentUrl,  String status, @JsonKey(name: 'assigned_to')  String? assignedTo, @JsonKey(name: 'resolved_at')  String? resolvedAt, @JsonKey(name: 'resolution_note')  String resolutionNote, @JsonKey(name: 'sla_due_at')  String? slaDueAt, @JsonKey(name: 'sla_breached')  bool slaBreached, @JsonKey(name: 'created_at')  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _ModerationReport():
return $default(_that.id,_that.reporter,_that.targetUser,_that.reason,_that.description,_that.contentUrl,_that.status,_that.assignedTo,_that.resolvedAt,_that.resolutionNote,_that.slaDueAt,_that.slaBreached,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? reporter, @JsonKey(name: 'target_user')  String? targetUser,  String reason,  String description, @JsonKey(name: 'content_url')  String contentUrl,  String status, @JsonKey(name: 'assigned_to')  String? assignedTo, @JsonKey(name: 'resolved_at')  String? resolvedAt, @JsonKey(name: 'resolution_note')  String resolutionNote, @JsonKey(name: 'sla_due_at')  String? slaDueAt, @JsonKey(name: 'sla_breached')  bool slaBreached, @JsonKey(name: 'created_at')  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ModerationReport() when $default != null:
return $default(_that.id,_that.reporter,_that.targetUser,_that.reason,_that.description,_that.contentUrl,_that.status,_that.assignedTo,_that.resolvedAt,_that.resolutionNote,_that.slaDueAt,_that.slaBreached,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ModerationReport implements ModerationReport {
  const _ModerationReport({this.id, this.reporter, @JsonKey(name: 'target_user') this.targetUser, this.reason = '', this.description = '', @JsonKey(name: 'content_url') this.contentUrl = '', this.status = '', @JsonKey(name: 'assigned_to') this.assignedTo, @JsonKey(name: 'resolved_at') this.resolvedAt, @JsonKey(name: 'resolution_note') this.resolutionNote = '', @JsonKey(name: 'sla_due_at') this.slaDueAt, @JsonKey(name: 'sla_breached') this.slaBreached = false, @JsonKey(name: 'created_at') this.createdAt});
  factory _ModerationReport.fromJson(Map<String, dynamic> json) => _$ModerationReportFromJson(json);

@override final  String? id;
@override final  String? reporter;
@override@JsonKey(name: 'target_user') final  String? targetUser;
@override@JsonKey() final  String reason;
@override@JsonKey() final  String description;
@override@JsonKey(name: 'content_url') final  String contentUrl;
/// open / investigating / resolved / dismissed.
@override@JsonKey() final  String status;
@override@JsonKey(name: 'assigned_to') final  String? assignedTo;
@override@JsonKey(name: 'resolved_at') final  String? resolvedAt;
@override@JsonKey(name: 'resolution_note') final  String resolutionNote;
@override@JsonKey(name: 'sla_due_at') final  String? slaDueAt;
@override@JsonKey(name: 'sla_breached') final  bool slaBreached;
@override@JsonKey(name: 'created_at') final  String? createdAt;

/// Create a copy of ModerationReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModerationReportCopyWith<_ModerationReport> get copyWith => __$ModerationReportCopyWithImpl<_ModerationReport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ModerationReportToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModerationReport&&(identical(other.id, id) || other.id == id)&&(identical(other.reporter, reporter) || other.reporter == reporter)&&(identical(other.targetUser, targetUser) || other.targetUser == targetUser)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.description, description) || other.description == description)&&(identical(other.contentUrl, contentUrl) || other.contentUrl == contentUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.assignedTo, assignedTo) || other.assignedTo == assignedTo)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.resolutionNote, resolutionNote) || other.resolutionNote == resolutionNote)&&(identical(other.slaDueAt, slaDueAt) || other.slaDueAt == slaDueAt)&&(identical(other.slaBreached, slaBreached) || other.slaBreached == slaBreached)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reporter,targetUser,reason,description,contentUrl,status,assignedTo,resolvedAt,resolutionNote,slaDueAt,slaBreached,createdAt);

@override
String toString() {
  return 'ModerationReport(id: $id, reporter: $reporter, targetUser: $targetUser, reason: $reason, description: $description, contentUrl: $contentUrl, status: $status, assignedTo: $assignedTo, resolvedAt: $resolvedAt, resolutionNote: $resolutionNote, slaDueAt: $slaDueAt, slaBreached: $slaBreached, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ModerationReportCopyWith<$Res> implements $ModerationReportCopyWith<$Res> {
  factory _$ModerationReportCopyWith(_ModerationReport value, $Res Function(_ModerationReport) _then) = __$ModerationReportCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? reporter,@JsonKey(name: 'target_user') String? targetUser, String reason, String description,@JsonKey(name: 'content_url') String contentUrl, String status,@JsonKey(name: 'assigned_to') String? assignedTo,@JsonKey(name: 'resolved_at') String? resolvedAt,@JsonKey(name: 'resolution_note') String resolutionNote,@JsonKey(name: 'sla_due_at') String? slaDueAt,@JsonKey(name: 'sla_breached') bool slaBreached,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class __$ModerationReportCopyWithImpl<$Res>
    implements _$ModerationReportCopyWith<$Res> {
  __$ModerationReportCopyWithImpl(this._self, this._then);

  final _ModerationReport _self;
  final $Res Function(_ModerationReport) _then;

/// Create a copy of ModerationReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? reporter = freezed,Object? targetUser = freezed,Object? reason = null,Object? description = null,Object? contentUrl = null,Object? status = null,Object? assignedTo = freezed,Object? resolvedAt = freezed,Object? resolutionNote = null,Object? slaDueAt = freezed,Object? slaBreached = null,Object? createdAt = freezed,}) {
  return _then(_ModerationReport(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,reporter: freezed == reporter ? _self.reporter : reporter // ignore: cast_nullable_to_non_nullable
as String?,targetUser: freezed == targetUser ? _self.targetUser : targetUser // ignore: cast_nullable_to_non_nullable
as String?,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,contentUrl: null == contentUrl ? _self.contentUrl : contentUrl // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,assignedTo: freezed == assignedTo ? _self.assignedTo : assignedTo // ignore: cast_nullable_to_non_nullable
as String?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as String?,resolutionNote: null == resolutionNote ? _self.resolutionNote : resolutionNote // ignore: cast_nullable_to_non_nullable
as String,slaDueAt: freezed == slaDueAt ? _self.slaDueAt : slaDueAt // ignore: cast_nullable_to_non_nullable
as String?,slaBreached: null == slaBreached ? _self.slaBreached : slaBreached // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ModerationAction {

 String? get id; String get action; String? get moderator; String? get report;@JsonKey(name: 'target_user') String? get targetUser; String get reason;@JsonKey(name: 'duration_days') int? get durationDays;@JsonKey(name: 'content_type') String get contentType;@JsonKey(name: 'content_type_display') String get contentTypeDisplay;@JsonKey(name: 'content_id') String get contentId;@JsonKey(name: 'is_reversed') bool get isReversed;@JsonKey(name: 'reversed_by') String? get reversedBy;@JsonKey(name: 'reversed_at') String? get reversedAt;@JsonKey(name: 'reversal_reason') String get reversalReason;@JsonKey(name: 'reversed_by_moderator', fromJson: _stringKeyedMapOrEmpty) Map<String, dynamic> get reversedByModerator;@JsonKey(name: 'created_at') String? get createdAt;
/// Create a copy of ModerationAction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModerationActionCopyWith<ModerationAction> get copyWith => _$ModerationActionCopyWithImpl<ModerationAction>(this as ModerationAction, _$identity);

  /// Serializes this ModerationAction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModerationAction&&(identical(other.id, id) || other.id == id)&&(identical(other.action, action) || other.action == action)&&(identical(other.moderator, moderator) || other.moderator == moderator)&&(identical(other.report, report) || other.report == report)&&(identical(other.targetUser, targetUser) || other.targetUser == targetUser)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.durationDays, durationDays) || other.durationDays == durationDays)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.contentTypeDisplay, contentTypeDisplay) || other.contentTypeDisplay == contentTypeDisplay)&&(identical(other.contentId, contentId) || other.contentId == contentId)&&(identical(other.isReversed, isReversed) || other.isReversed == isReversed)&&(identical(other.reversedBy, reversedBy) || other.reversedBy == reversedBy)&&(identical(other.reversedAt, reversedAt) || other.reversedAt == reversedAt)&&(identical(other.reversalReason, reversalReason) || other.reversalReason == reversalReason)&&const DeepCollectionEquality().equals(other.reversedByModerator, reversedByModerator)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,action,moderator,report,targetUser,reason,durationDays,contentType,contentTypeDisplay,contentId,isReversed,reversedBy,reversedAt,reversalReason,const DeepCollectionEquality().hash(reversedByModerator),createdAt);

@override
String toString() {
  return 'ModerationAction(id: $id, action: $action, moderator: $moderator, report: $report, targetUser: $targetUser, reason: $reason, durationDays: $durationDays, contentType: $contentType, contentTypeDisplay: $contentTypeDisplay, contentId: $contentId, isReversed: $isReversed, reversedBy: $reversedBy, reversedAt: $reversedAt, reversalReason: $reversalReason, reversedByModerator: $reversedByModerator, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ModerationActionCopyWith<$Res>  {
  factory $ModerationActionCopyWith(ModerationAction value, $Res Function(ModerationAction) _then) = _$ModerationActionCopyWithImpl;
@useResult
$Res call({
 String? id, String action, String? moderator, String? report,@JsonKey(name: 'target_user') String? targetUser, String reason,@JsonKey(name: 'duration_days') int? durationDays,@JsonKey(name: 'content_type') String contentType,@JsonKey(name: 'content_type_display') String contentTypeDisplay,@JsonKey(name: 'content_id') String contentId,@JsonKey(name: 'is_reversed') bool isReversed,@JsonKey(name: 'reversed_by') String? reversedBy,@JsonKey(name: 'reversed_at') String? reversedAt,@JsonKey(name: 'reversal_reason') String reversalReason,@JsonKey(name: 'reversed_by_moderator', fromJson: _stringKeyedMapOrEmpty) Map<String, dynamic> reversedByModerator,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class _$ModerationActionCopyWithImpl<$Res>
    implements $ModerationActionCopyWith<$Res> {
  _$ModerationActionCopyWithImpl(this._self, this._then);

  final ModerationAction _self;
  final $Res Function(ModerationAction) _then;

/// Create a copy of ModerationAction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? action = null,Object? moderator = freezed,Object? report = freezed,Object? targetUser = freezed,Object? reason = null,Object? durationDays = freezed,Object? contentType = null,Object? contentTypeDisplay = null,Object? contentId = null,Object? isReversed = null,Object? reversedBy = freezed,Object? reversedAt = freezed,Object? reversalReason = null,Object? reversedByModerator = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,moderator: freezed == moderator ? _self.moderator : moderator // ignore: cast_nullable_to_non_nullable
as String?,report: freezed == report ? _self.report : report // ignore: cast_nullable_to_non_nullable
as String?,targetUser: freezed == targetUser ? _self.targetUser : targetUser // ignore: cast_nullable_to_non_nullable
as String?,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,durationDays: freezed == durationDays ? _self.durationDays : durationDays // ignore: cast_nullable_to_non_nullable
as int?,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,contentTypeDisplay: null == contentTypeDisplay ? _self.contentTypeDisplay : contentTypeDisplay // ignore: cast_nullable_to_non_nullable
as String,contentId: null == contentId ? _self.contentId : contentId // ignore: cast_nullable_to_non_nullable
as String,isReversed: null == isReversed ? _self.isReversed : isReversed // ignore: cast_nullable_to_non_nullable
as bool,reversedBy: freezed == reversedBy ? _self.reversedBy : reversedBy // ignore: cast_nullable_to_non_nullable
as String?,reversedAt: freezed == reversedAt ? _self.reversedAt : reversedAt // ignore: cast_nullable_to_non_nullable
as String?,reversalReason: null == reversalReason ? _self.reversalReason : reversalReason // ignore: cast_nullable_to_non_nullable
as String,reversedByModerator: null == reversedByModerator ? _self.reversedByModerator : reversedByModerator // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ModerationAction].
extension ModerationActionPatterns on ModerationAction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModerationAction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModerationAction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModerationAction value)  $default,){
final _that = this;
switch (_that) {
case _ModerationAction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModerationAction value)?  $default,){
final _that = this;
switch (_that) {
case _ModerationAction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String action,  String? moderator,  String? report, @JsonKey(name: 'target_user')  String? targetUser,  String reason, @JsonKey(name: 'duration_days')  int? durationDays, @JsonKey(name: 'content_type')  String contentType, @JsonKey(name: 'content_type_display')  String contentTypeDisplay, @JsonKey(name: 'content_id')  String contentId, @JsonKey(name: 'is_reversed')  bool isReversed, @JsonKey(name: 'reversed_by')  String? reversedBy, @JsonKey(name: 'reversed_at')  String? reversedAt, @JsonKey(name: 'reversal_reason')  String reversalReason, @JsonKey(name: 'reversed_by_moderator', fromJson: _stringKeyedMapOrEmpty)  Map<String, dynamic> reversedByModerator, @JsonKey(name: 'created_at')  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModerationAction() when $default != null:
return $default(_that.id,_that.action,_that.moderator,_that.report,_that.targetUser,_that.reason,_that.durationDays,_that.contentType,_that.contentTypeDisplay,_that.contentId,_that.isReversed,_that.reversedBy,_that.reversedAt,_that.reversalReason,_that.reversedByModerator,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String action,  String? moderator,  String? report, @JsonKey(name: 'target_user')  String? targetUser,  String reason, @JsonKey(name: 'duration_days')  int? durationDays, @JsonKey(name: 'content_type')  String contentType, @JsonKey(name: 'content_type_display')  String contentTypeDisplay, @JsonKey(name: 'content_id')  String contentId, @JsonKey(name: 'is_reversed')  bool isReversed, @JsonKey(name: 'reversed_by')  String? reversedBy, @JsonKey(name: 'reversed_at')  String? reversedAt, @JsonKey(name: 'reversal_reason')  String reversalReason, @JsonKey(name: 'reversed_by_moderator', fromJson: _stringKeyedMapOrEmpty)  Map<String, dynamic> reversedByModerator, @JsonKey(name: 'created_at')  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _ModerationAction():
return $default(_that.id,_that.action,_that.moderator,_that.report,_that.targetUser,_that.reason,_that.durationDays,_that.contentType,_that.contentTypeDisplay,_that.contentId,_that.isReversed,_that.reversedBy,_that.reversedAt,_that.reversalReason,_that.reversedByModerator,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String action,  String? moderator,  String? report, @JsonKey(name: 'target_user')  String? targetUser,  String reason, @JsonKey(name: 'duration_days')  int? durationDays, @JsonKey(name: 'content_type')  String contentType, @JsonKey(name: 'content_type_display')  String contentTypeDisplay, @JsonKey(name: 'content_id')  String contentId, @JsonKey(name: 'is_reversed')  bool isReversed, @JsonKey(name: 'reversed_by')  String? reversedBy, @JsonKey(name: 'reversed_at')  String? reversedAt, @JsonKey(name: 'reversal_reason')  String reversalReason, @JsonKey(name: 'reversed_by_moderator', fromJson: _stringKeyedMapOrEmpty)  Map<String, dynamic> reversedByModerator, @JsonKey(name: 'created_at')  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ModerationAction() when $default != null:
return $default(_that.id,_that.action,_that.moderator,_that.report,_that.targetUser,_that.reason,_that.durationDays,_that.contentType,_that.contentTypeDisplay,_that.contentId,_that.isReversed,_that.reversedBy,_that.reversedAt,_that.reversalReason,_that.reversedByModerator,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ModerationAction implements ModerationAction {
  const _ModerationAction({this.id, this.action = '', this.moderator, this.report, @JsonKey(name: 'target_user') this.targetUser, this.reason = '', @JsonKey(name: 'duration_days') this.durationDays, @JsonKey(name: 'content_type') this.contentType = '', @JsonKey(name: 'content_type_display') this.contentTypeDisplay = '', @JsonKey(name: 'content_id') this.contentId = '', @JsonKey(name: 'is_reversed') this.isReversed = false, @JsonKey(name: 'reversed_by') this.reversedBy, @JsonKey(name: 'reversed_at') this.reversedAt, @JsonKey(name: 'reversal_reason') this.reversalReason = '', @JsonKey(name: 'reversed_by_moderator', fromJson: _stringKeyedMapOrEmpty) final  Map<String, dynamic> reversedByModerator = const <String, dynamic>{}, @JsonKey(name: 'created_at') this.createdAt}): _reversedByModerator = reversedByModerator;
  factory _ModerationAction.fromJson(Map<String, dynamic> json) => _$ModerationActionFromJson(json);

@override final  String? id;
@override@JsonKey() final  String action;
@override final  String? moderator;
@override final  String? report;
@override@JsonKey(name: 'target_user') final  String? targetUser;
@override@JsonKey() final  String reason;
@override@JsonKey(name: 'duration_days') final  int? durationDays;
@override@JsonKey(name: 'content_type') final  String contentType;
@override@JsonKey(name: 'content_type_display') final  String contentTypeDisplay;
@override@JsonKey(name: 'content_id') final  String contentId;
@override@JsonKey(name: 'is_reversed') final  bool isReversed;
@override@JsonKey(name: 'reversed_by') final  String? reversedBy;
@override@JsonKey(name: 'reversed_at') final  String? reversedAt;
@override@JsonKey(name: 'reversal_reason') final  String reversalReason;
 final  Map<String, dynamic> _reversedByModerator;
@override@JsonKey(name: 'reversed_by_moderator', fromJson: _stringKeyedMapOrEmpty) Map<String, dynamic> get reversedByModerator {
  if (_reversedByModerator is EqualUnmodifiableMapView) return _reversedByModerator;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_reversedByModerator);
}

@override@JsonKey(name: 'created_at') final  String? createdAt;

/// Create a copy of ModerationAction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModerationActionCopyWith<_ModerationAction> get copyWith => __$ModerationActionCopyWithImpl<_ModerationAction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ModerationActionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModerationAction&&(identical(other.id, id) || other.id == id)&&(identical(other.action, action) || other.action == action)&&(identical(other.moderator, moderator) || other.moderator == moderator)&&(identical(other.report, report) || other.report == report)&&(identical(other.targetUser, targetUser) || other.targetUser == targetUser)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.durationDays, durationDays) || other.durationDays == durationDays)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.contentTypeDisplay, contentTypeDisplay) || other.contentTypeDisplay == contentTypeDisplay)&&(identical(other.contentId, contentId) || other.contentId == contentId)&&(identical(other.isReversed, isReversed) || other.isReversed == isReversed)&&(identical(other.reversedBy, reversedBy) || other.reversedBy == reversedBy)&&(identical(other.reversedAt, reversedAt) || other.reversedAt == reversedAt)&&(identical(other.reversalReason, reversalReason) || other.reversalReason == reversalReason)&&const DeepCollectionEquality().equals(other._reversedByModerator, _reversedByModerator)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,action,moderator,report,targetUser,reason,durationDays,contentType,contentTypeDisplay,contentId,isReversed,reversedBy,reversedAt,reversalReason,const DeepCollectionEquality().hash(_reversedByModerator),createdAt);

@override
String toString() {
  return 'ModerationAction(id: $id, action: $action, moderator: $moderator, report: $report, targetUser: $targetUser, reason: $reason, durationDays: $durationDays, contentType: $contentType, contentTypeDisplay: $contentTypeDisplay, contentId: $contentId, isReversed: $isReversed, reversedBy: $reversedBy, reversedAt: $reversedAt, reversalReason: $reversalReason, reversedByModerator: $reversedByModerator, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ModerationActionCopyWith<$Res> implements $ModerationActionCopyWith<$Res> {
  factory _$ModerationActionCopyWith(_ModerationAction value, $Res Function(_ModerationAction) _then) = __$ModerationActionCopyWithImpl;
@override @useResult
$Res call({
 String? id, String action, String? moderator, String? report,@JsonKey(name: 'target_user') String? targetUser, String reason,@JsonKey(name: 'duration_days') int? durationDays,@JsonKey(name: 'content_type') String contentType,@JsonKey(name: 'content_type_display') String contentTypeDisplay,@JsonKey(name: 'content_id') String contentId,@JsonKey(name: 'is_reversed') bool isReversed,@JsonKey(name: 'reversed_by') String? reversedBy,@JsonKey(name: 'reversed_at') String? reversedAt,@JsonKey(name: 'reversal_reason') String reversalReason,@JsonKey(name: 'reversed_by_moderator', fromJson: _stringKeyedMapOrEmpty) Map<String, dynamic> reversedByModerator,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class __$ModerationActionCopyWithImpl<$Res>
    implements _$ModerationActionCopyWith<$Res> {
  __$ModerationActionCopyWithImpl(this._self, this._then);

  final _ModerationAction _self;
  final $Res Function(_ModerationAction) _then;

/// Create a copy of ModerationAction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? action = null,Object? moderator = freezed,Object? report = freezed,Object? targetUser = freezed,Object? reason = null,Object? durationDays = freezed,Object? contentType = null,Object? contentTypeDisplay = null,Object? contentId = null,Object? isReversed = null,Object? reversedBy = freezed,Object? reversedAt = freezed,Object? reversalReason = null,Object? reversedByModerator = null,Object? createdAt = freezed,}) {
  return _then(_ModerationAction(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,moderator: freezed == moderator ? _self.moderator : moderator // ignore: cast_nullable_to_non_nullable
as String?,report: freezed == report ? _self.report : report // ignore: cast_nullable_to_non_nullable
as String?,targetUser: freezed == targetUser ? _self.targetUser : targetUser // ignore: cast_nullable_to_non_nullable
as String?,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,durationDays: freezed == durationDays ? _self.durationDays : durationDays // ignore: cast_nullable_to_non_nullable
as int?,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,contentTypeDisplay: null == contentTypeDisplay ? _self.contentTypeDisplay : contentTypeDisplay // ignore: cast_nullable_to_non_nullable
as String,contentId: null == contentId ? _self.contentId : contentId // ignore: cast_nullable_to_non_nullable
as String,isReversed: null == isReversed ? _self.isReversed : isReversed // ignore: cast_nullable_to_non_nullable
as bool,reversedBy: freezed == reversedBy ? _self.reversedBy : reversedBy // ignore: cast_nullable_to_non_nullable
as String?,reversedAt: freezed == reversedAt ? _self.reversedAt : reversedAt // ignore: cast_nullable_to_non_nullable
as String?,reversalReason: null == reversalReason ? _self.reversalReason : reversalReason // ignore: cast_nullable_to_non_nullable
as String,reversedByModerator: null == reversedByModerator ? _self._reversedByModerator : reversedByModerator // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ModerationActionOutcome {

@JsonKey(name: 'moderation_action') ModerationAction? get moderationAction;@JsonKey(name: 'approval') ModerationApprovalStub? get approval; bool get applied;
/// Create a copy of ModerationActionOutcome
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModerationActionOutcomeCopyWith<ModerationActionOutcome> get copyWith => _$ModerationActionOutcomeCopyWithImpl<ModerationActionOutcome>(this as ModerationActionOutcome, _$identity);

  /// Serializes this ModerationActionOutcome to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModerationActionOutcome&&(identical(other.moderationAction, moderationAction) || other.moderationAction == moderationAction)&&(identical(other.approval, approval) || other.approval == approval)&&(identical(other.applied, applied) || other.applied == applied));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,moderationAction,approval,applied);

@override
String toString() {
  return 'ModerationActionOutcome(moderationAction: $moderationAction, approval: $approval, applied: $applied)';
}


}

/// @nodoc
abstract mixin class $ModerationActionOutcomeCopyWith<$Res>  {
  factory $ModerationActionOutcomeCopyWith(ModerationActionOutcome value, $Res Function(ModerationActionOutcome) _then) = _$ModerationActionOutcomeCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'moderation_action') ModerationAction? moderationAction,@JsonKey(name: 'approval') ModerationApprovalStub? approval, bool applied
});


$ModerationActionCopyWith<$Res>? get moderationAction;$ModerationApprovalStubCopyWith<$Res>? get approval;

}
/// @nodoc
class _$ModerationActionOutcomeCopyWithImpl<$Res>
    implements $ModerationActionOutcomeCopyWith<$Res> {
  _$ModerationActionOutcomeCopyWithImpl(this._self, this._then);

  final ModerationActionOutcome _self;
  final $Res Function(ModerationActionOutcome) _then;

/// Create a copy of ModerationActionOutcome
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? moderationAction = freezed,Object? approval = freezed,Object? applied = null,}) {
  return _then(_self.copyWith(
moderationAction: freezed == moderationAction ? _self.moderationAction : moderationAction // ignore: cast_nullable_to_non_nullable
as ModerationAction?,approval: freezed == approval ? _self.approval : approval // ignore: cast_nullable_to_non_nullable
as ModerationApprovalStub?,applied: null == applied ? _self.applied : applied // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of ModerationActionOutcome
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ModerationActionCopyWith<$Res>? get moderationAction {
    if (_self.moderationAction == null) {
    return null;
  }

  return $ModerationActionCopyWith<$Res>(_self.moderationAction!, (value) {
    return _then(_self.copyWith(moderationAction: value));
  });
}/// Create a copy of ModerationActionOutcome
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ModerationApprovalStubCopyWith<$Res>? get approval {
    if (_self.approval == null) {
    return null;
  }

  return $ModerationApprovalStubCopyWith<$Res>(_self.approval!, (value) {
    return _then(_self.copyWith(approval: value));
  });
}
}


/// Adds pattern-matching-related methods to [ModerationActionOutcome].
extension ModerationActionOutcomePatterns on ModerationActionOutcome {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModerationActionOutcome value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModerationActionOutcome() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModerationActionOutcome value)  $default,){
final _that = this;
switch (_that) {
case _ModerationActionOutcome():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModerationActionOutcome value)?  $default,){
final _that = this;
switch (_that) {
case _ModerationActionOutcome() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'moderation_action')  ModerationAction? moderationAction, @JsonKey(name: 'approval')  ModerationApprovalStub? approval,  bool applied)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModerationActionOutcome() when $default != null:
return $default(_that.moderationAction,_that.approval,_that.applied);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'moderation_action')  ModerationAction? moderationAction, @JsonKey(name: 'approval')  ModerationApprovalStub? approval,  bool applied)  $default,) {final _that = this;
switch (_that) {
case _ModerationActionOutcome():
return $default(_that.moderationAction,_that.approval,_that.applied);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'moderation_action')  ModerationAction? moderationAction, @JsonKey(name: 'approval')  ModerationApprovalStub? approval,  bool applied)?  $default,) {final _that = this;
switch (_that) {
case _ModerationActionOutcome() when $default != null:
return $default(_that.moderationAction,_that.approval,_that.applied);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ModerationActionOutcome implements ModerationActionOutcome {
  const _ModerationActionOutcome({@JsonKey(name: 'moderation_action') this.moderationAction, @JsonKey(name: 'approval') this.approval, this.applied = false});
  factory _ModerationActionOutcome.fromJson(Map<String, dynamic> json) => _$ModerationActionOutcomeFromJson(json);

@override@JsonKey(name: 'moderation_action') final  ModerationAction? moderationAction;
@override@JsonKey(name: 'approval') final  ModerationApprovalStub? approval;
@override@JsonKey() final  bool applied;

/// Create a copy of ModerationActionOutcome
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModerationActionOutcomeCopyWith<_ModerationActionOutcome> get copyWith => __$ModerationActionOutcomeCopyWithImpl<_ModerationActionOutcome>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ModerationActionOutcomeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModerationActionOutcome&&(identical(other.moderationAction, moderationAction) || other.moderationAction == moderationAction)&&(identical(other.approval, approval) || other.approval == approval)&&(identical(other.applied, applied) || other.applied == applied));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,moderationAction,approval,applied);

@override
String toString() {
  return 'ModerationActionOutcome(moderationAction: $moderationAction, approval: $approval, applied: $applied)';
}


}

/// @nodoc
abstract mixin class _$ModerationActionOutcomeCopyWith<$Res> implements $ModerationActionOutcomeCopyWith<$Res> {
  factory _$ModerationActionOutcomeCopyWith(_ModerationActionOutcome value, $Res Function(_ModerationActionOutcome) _then) = __$ModerationActionOutcomeCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'moderation_action') ModerationAction? moderationAction,@JsonKey(name: 'approval') ModerationApprovalStub? approval, bool applied
});


@override $ModerationActionCopyWith<$Res>? get moderationAction;@override $ModerationApprovalStubCopyWith<$Res>? get approval;

}
/// @nodoc
class __$ModerationActionOutcomeCopyWithImpl<$Res>
    implements _$ModerationActionOutcomeCopyWith<$Res> {
  __$ModerationActionOutcomeCopyWithImpl(this._self, this._then);

  final _ModerationActionOutcome _self;
  final $Res Function(_ModerationActionOutcome) _then;

/// Create a copy of ModerationActionOutcome
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? moderationAction = freezed,Object? approval = freezed,Object? applied = null,}) {
  return _then(_ModerationActionOutcome(
moderationAction: freezed == moderationAction ? _self.moderationAction : moderationAction // ignore: cast_nullable_to_non_nullable
as ModerationAction?,approval: freezed == approval ? _self.approval : approval // ignore: cast_nullable_to_non_nullable
as ModerationApprovalStub?,applied: null == applied ? _self.applied : applied // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of ModerationActionOutcome
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ModerationActionCopyWith<$Res>? get moderationAction {
    if (_self.moderationAction == null) {
    return null;
  }

  return $ModerationActionCopyWith<$Res>(_self.moderationAction!, (value) {
    return _then(_self.copyWith(moderationAction: value));
  });
}/// Create a copy of ModerationActionOutcome
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ModerationApprovalStubCopyWith<$Res>? get approval {
    if (_self.approval == null) {
    return null;
  }

  return $ModerationApprovalStubCopyWith<$Res>(_self.approval!, (value) {
    return _then(_self.copyWith(approval: value));
  });
}
}


/// @nodoc
mixin _$ModerationApprovalStub {

 String? get id; String get action; String get status;@JsonKey(name: 'requires_second') bool get requiresSecond;@JsonKey(name: 'requested_by') String? get requestedBy;
/// Create a copy of ModerationApprovalStub
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModerationApprovalStubCopyWith<ModerationApprovalStub> get copyWith => _$ModerationApprovalStubCopyWithImpl<ModerationApprovalStub>(this as ModerationApprovalStub, _$identity);

  /// Serializes this ModerationApprovalStub to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModerationApprovalStub&&(identical(other.id, id) || other.id == id)&&(identical(other.action, action) || other.action == action)&&(identical(other.status, status) || other.status == status)&&(identical(other.requiresSecond, requiresSecond) || other.requiresSecond == requiresSecond)&&(identical(other.requestedBy, requestedBy) || other.requestedBy == requestedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,action,status,requiresSecond,requestedBy);

@override
String toString() {
  return 'ModerationApprovalStub(id: $id, action: $action, status: $status, requiresSecond: $requiresSecond, requestedBy: $requestedBy)';
}


}

/// @nodoc
abstract mixin class $ModerationApprovalStubCopyWith<$Res>  {
  factory $ModerationApprovalStubCopyWith(ModerationApprovalStub value, $Res Function(ModerationApprovalStub) _then) = _$ModerationApprovalStubCopyWithImpl;
@useResult
$Res call({
 String? id, String action, String status,@JsonKey(name: 'requires_second') bool requiresSecond,@JsonKey(name: 'requested_by') String? requestedBy
});




}
/// @nodoc
class _$ModerationApprovalStubCopyWithImpl<$Res>
    implements $ModerationApprovalStubCopyWith<$Res> {
  _$ModerationApprovalStubCopyWithImpl(this._self, this._then);

  final ModerationApprovalStub _self;
  final $Res Function(ModerationApprovalStub) _then;

/// Create a copy of ModerationApprovalStub
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? action = null,Object? status = null,Object? requiresSecond = null,Object? requestedBy = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,requiresSecond: null == requiresSecond ? _self.requiresSecond : requiresSecond // ignore: cast_nullable_to_non_nullable
as bool,requestedBy: freezed == requestedBy ? _self.requestedBy : requestedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ModerationApprovalStub].
extension ModerationApprovalStubPatterns on ModerationApprovalStub {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModerationApprovalStub value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModerationApprovalStub() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModerationApprovalStub value)  $default,){
final _that = this;
switch (_that) {
case _ModerationApprovalStub():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModerationApprovalStub value)?  $default,){
final _that = this;
switch (_that) {
case _ModerationApprovalStub() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String action,  String status, @JsonKey(name: 'requires_second')  bool requiresSecond, @JsonKey(name: 'requested_by')  String? requestedBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModerationApprovalStub() when $default != null:
return $default(_that.id,_that.action,_that.status,_that.requiresSecond,_that.requestedBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String action,  String status, @JsonKey(name: 'requires_second')  bool requiresSecond, @JsonKey(name: 'requested_by')  String? requestedBy)  $default,) {final _that = this;
switch (_that) {
case _ModerationApprovalStub():
return $default(_that.id,_that.action,_that.status,_that.requiresSecond,_that.requestedBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String action,  String status, @JsonKey(name: 'requires_second')  bool requiresSecond, @JsonKey(name: 'requested_by')  String? requestedBy)?  $default,) {final _that = this;
switch (_that) {
case _ModerationApprovalStub() when $default != null:
return $default(_that.id,_that.action,_that.status,_that.requiresSecond,_that.requestedBy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ModerationApprovalStub implements ModerationApprovalStub {
  const _ModerationApprovalStub({this.id, this.action = '', this.status = '', @JsonKey(name: 'requires_second') this.requiresSecond = true, @JsonKey(name: 'requested_by') this.requestedBy});
  factory _ModerationApprovalStub.fromJson(Map<String, dynamic> json) => _$ModerationApprovalStubFromJson(json);

@override final  String? id;
@override@JsonKey() final  String action;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'requires_second') final  bool requiresSecond;
@override@JsonKey(name: 'requested_by') final  String? requestedBy;

/// Create a copy of ModerationApprovalStub
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModerationApprovalStubCopyWith<_ModerationApprovalStub> get copyWith => __$ModerationApprovalStubCopyWithImpl<_ModerationApprovalStub>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ModerationApprovalStubToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModerationApprovalStub&&(identical(other.id, id) || other.id == id)&&(identical(other.action, action) || other.action == action)&&(identical(other.status, status) || other.status == status)&&(identical(other.requiresSecond, requiresSecond) || other.requiresSecond == requiresSecond)&&(identical(other.requestedBy, requestedBy) || other.requestedBy == requestedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,action,status,requiresSecond,requestedBy);

@override
String toString() {
  return 'ModerationApprovalStub(id: $id, action: $action, status: $status, requiresSecond: $requiresSecond, requestedBy: $requestedBy)';
}


}

/// @nodoc
abstract mixin class _$ModerationApprovalStubCopyWith<$Res> implements $ModerationApprovalStubCopyWith<$Res> {
  factory _$ModerationApprovalStubCopyWith(_ModerationApprovalStub value, $Res Function(_ModerationApprovalStub) _then) = __$ModerationApprovalStubCopyWithImpl;
@override @useResult
$Res call({
 String? id, String action, String status,@JsonKey(name: 'requires_second') bool requiresSecond,@JsonKey(name: 'requested_by') String? requestedBy
});




}
/// @nodoc
class __$ModerationApprovalStubCopyWithImpl<$Res>
    implements _$ModerationApprovalStubCopyWith<$Res> {
  __$ModerationApprovalStubCopyWithImpl(this._self, this._then);

  final _ModerationApprovalStub _self;
  final $Res Function(_ModerationApprovalStub) _then;

/// Create a copy of ModerationApprovalStub
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? action = null,Object? status = null,Object? requiresSecond = null,Object? requestedBy = freezed,}) {
  return _then(_ModerationApprovalStub(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,requiresSecond: null == requiresSecond ? _self.requiresSecond : requiresSecond // ignore: cast_nullable_to_non_nullable
as bool,requestedBy: freezed == requestedBy ? _self.requestedBy : requestedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ModerationReversalOutcome {

@JsonKey(name: 'reversed_action') ModerationAction? get reversedAction;@JsonKey(name: 'reversal') ModerationAction? get reversal;@JsonKey(name: 'effect')@_FlexibleTextConverter() String? get effect;
/// Create a copy of ModerationReversalOutcome
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModerationReversalOutcomeCopyWith<ModerationReversalOutcome> get copyWith => _$ModerationReversalOutcomeCopyWithImpl<ModerationReversalOutcome>(this as ModerationReversalOutcome, _$identity);

  /// Serializes this ModerationReversalOutcome to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModerationReversalOutcome&&(identical(other.reversedAction, reversedAction) || other.reversedAction == reversedAction)&&(identical(other.reversal, reversal) || other.reversal == reversal)&&(identical(other.effect, effect) || other.effect == effect));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reversedAction,reversal,effect);

@override
String toString() {
  return 'ModerationReversalOutcome(reversedAction: $reversedAction, reversal: $reversal, effect: $effect)';
}


}

/// @nodoc
abstract mixin class $ModerationReversalOutcomeCopyWith<$Res>  {
  factory $ModerationReversalOutcomeCopyWith(ModerationReversalOutcome value, $Res Function(ModerationReversalOutcome) _then) = _$ModerationReversalOutcomeCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'reversed_action') ModerationAction? reversedAction,@JsonKey(name: 'reversal') ModerationAction? reversal,@JsonKey(name: 'effect')@_FlexibleTextConverter() String? effect
});


$ModerationActionCopyWith<$Res>? get reversedAction;$ModerationActionCopyWith<$Res>? get reversal;

}
/// @nodoc
class _$ModerationReversalOutcomeCopyWithImpl<$Res>
    implements $ModerationReversalOutcomeCopyWith<$Res> {
  _$ModerationReversalOutcomeCopyWithImpl(this._self, this._then);

  final ModerationReversalOutcome _self;
  final $Res Function(ModerationReversalOutcome) _then;

/// Create a copy of ModerationReversalOutcome
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reversedAction = freezed,Object? reversal = freezed,Object? effect = freezed,}) {
  return _then(_self.copyWith(
reversedAction: freezed == reversedAction ? _self.reversedAction : reversedAction // ignore: cast_nullable_to_non_nullable
as ModerationAction?,reversal: freezed == reversal ? _self.reversal : reversal // ignore: cast_nullable_to_non_nullable
as ModerationAction?,effect: freezed == effect ? _self.effect : effect // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of ModerationReversalOutcome
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ModerationActionCopyWith<$Res>? get reversedAction {
    if (_self.reversedAction == null) {
    return null;
  }

  return $ModerationActionCopyWith<$Res>(_self.reversedAction!, (value) {
    return _then(_self.copyWith(reversedAction: value));
  });
}/// Create a copy of ModerationReversalOutcome
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ModerationActionCopyWith<$Res>? get reversal {
    if (_self.reversal == null) {
    return null;
  }

  return $ModerationActionCopyWith<$Res>(_self.reversal!, (value) {
    return _then(_self.copyWith(reversal: value));
  });
}
}


/// Adds pattern-matching-related methods to [ModerationReversalOutcome].
extension ModerationReversalOutcomePatterns on ModerationReversalOutcome {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModerationReversalOutcome value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModerationReversalOutcome() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModerationReversalOutcome value)  $default,){
final _that = this;
switch (_that) {
case _ModerationReversalOutcome():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModerationReversalOutcome value)?  $default,){
final _that = this;
switch (_that) {
case _ModerationReversalOutcome() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'reversed_action')  ModerationAction? reversedAction, @JsonKey(name: 'reversal')  ModerationAction? reversal, @JsonKey(name: 'effect')@_FlexibleTextConverter()  String? effect)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModerationReversalOutcome() when $default != null:
return $default(_that.reversedAction,_that.reversal,_that.effect);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'reversed_action')  ModerationAction? reversedAction, @JsonKey(name: 'reversal')  ModerationAction? reversal, @JsonKey(name: 'effect')@_FlexibleTextConverter()  String? effect)  $default,) {final _that = this;
switch (_that) {
case _ModerationReversalOutcome():
return $default(_that.reversedAction,_that.reversal,_that.effect);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'reversed_action')  ModerationAction? reversedAction, @JsonKey(name: 'reversal')  ModerationAction? reversal, @JsonKey(name: 'effect')@_FlexibleTextConverter()  String? effect)?  $default,) {final _that = this;
switch (_that) {
case _ModerationReversalOutcome() when $default != null:
return $default(_that.reversedAction,_that.reversal,_that.effect);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ModerationReversalOutcome implements ModerationReversalOutcome {
  const _ModerationReversalOutcome({@JsonKey(name: 'reversed_action') this.reversedAction, @JsonKey(name: 'reversal') this.reversal, @JsonKey(name: 'effect')@_FlexibleTextConverter() this.effect});
  factory _ModerationReversalOutcome.fromJson(Map<String, dynamic> json) => _$ModerationReversalOutcomeFromJson(json);

@override@JsonKey(name: 'reversed_action') final  ModerationAction? reversedAction;
@override@JsonKey(name: 'reversal') final  ModerationAction? reversal;
@override@JsonKey(name: 'effect')@_FlexibleTextConverter() final  String? effect;

/// Create a copy of ModerationReversalOutcome
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModerationReversalOutcomeCopyWith<_ModerationReversalOutcome> get copyWith => __$ModerationReversalOutcomeCopyWithImpl<_ModerationReversalOutcome>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ModerationReversalOutcomeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModerationReversalOutcome&&(identical(other.reversedAction, reversedAction) || other.reversedAction == reversedAction)&&(identical(other.reversal, reversal) || other.reversal == reversal)&&(identical(other.effect, effect) || other.effect == effect));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reversedAction,reversal,effect);

@override
String toString() {
  return 'ModerationReversalOutcome(reversedAction: $reversedAction, reversal: $reversal, effect: $effect)';
}


}

/// @nodoc
abstract mixin class _$ModerationReversalOutcomeCopyWith<$Res> implements $ModerationReversalOutcomeCopyWith<$Res> {
  factory _$ModerationReversalOutcomeCopyWith(_ModerationReversalOutcome value, $Res Function(_ModerationReversalOutcome) _then) = __$ModerationReversalOutcomeCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'reversed_action') ModerationAction? reversedAction,@JsonKey(name: 'reversal') ModerationAction? reversal,@JsonKey(name: 'effect')@_FlexibleTextConverter() String? effect
});


@override $ModerationActionCopyWith<$Res>? get reversedAction;@override $ModerationActionCopyWith<$Res>? get reversal;

}
/// @nodoc
class __$ModerationReversalOutcomeCopyWithImpl<$Res>
    implements _$ModerationReversalOutcomeCopyWith<$Res> {
  __$ModerationReversalOutcomeCopyWithImpl(this._self, this._then);

  final _ModerationReversalOutcome _self;
  final $Res Function(_ModerationReversalOutcome) _then;

/// Create a copy of ModerationReversalOutcome
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reversedAction = freezed,Object? reversal = freezed,Object? effect = freezed,}) {
  return _then(_ModerationReversalOutcome(
reversedAction: freezed == reversedAction ? _self.reversedAction : reversedAction // ignore: cast_nullable_to_non_nullable
as ModerationAction?,reversal: freezed == reversal ? _self.reversal : reversal // ignore: cast_nullable_to_non_nullable
as ModerationAction?,effect: freezed == effect ? _self.effect : effect // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ModerationReversalOutcome
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ModerationActionCopyWith<$Res>? get reversedAction {
    if (_self.reversedAction == null) {
    return null;
  }

  return $ModerationActionCopyWith<$Res>(_self.reversedAction!, (value) {
    return _then(_self.copyWith(reversedAction: value));
  });
}/// Create a copy of ModerationReversalOutcome
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ModerationActionCopyWith<$Res>? get reversal {
    if (_self.reversal == null) {
    return null;
  }

  return $ModerationActionCopyWith<$Res>(_self.reversal!, (value) {
    return _then(_self.copyWith(reversal: value));
  });
}
}


/// @nodoc
mixin _$ContentFlagOutcome {

 ContentFlag? get flag;@JsonKey(name: 'effect')@_FlexibleTextConverter() String? get effect;
/// Create a copy of ContentFlagOutcome
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContentFlagOutcomeCopyWith<ContentFlagOutcome> get copyWith => _$ContentFlagOutcomeCopyWithImpl<ContentFlagOutcome>(this as ContentFlagOutcome, _$identity);

  /// Serializes this ContentFlagOutcome to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContentFlagOutcome&&(identical(other.flag, flag) || other.flag == flag)&&(identical(other.effect, effect) || other.effect == effect));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,flag,effect);

@override
String toString() {
  return 'ContentFlagOutcome(flag: $flag, effect: $effect)';
}


}

/// @nodoc
abstract mixin class $ContentFlagOutcomeCopyWith<$Res>  {
  factory $ContentFlagOutcomeCopyWith(ContentFlagOutcome value, $Res Function(ContentFlagOutcome) _then) = _$ContentFlagOutcomeCopyWithImpl;
@useResult
$Res call({
 ContentFlag? flag,@JsonKey(name: 'effect')@_FlexibleTextConverter() String? effect
});


$ContentFlagCopyWith<$Res>? get flag;

}
/// @nodoc
class _$ContentFlagOutcomeCopyWithImpl<$Res>
    implements $ContentFlagOutcomeCopyWith<$Res> {
  _$ContentFlagOutcomeCopyWithImpl(this._self, this._then);

  final ContentFlagOutcome _self;
  final $Res Function(ContentFlagOutcome) _then;

/// Create a copy of ContentFlagOutcome
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? flag = freezed,Object? effect = freezed,}) {
  return _then(_self.copyWith(
flag: freezed == flag ? _self.flag : flag // ignore: cast_nullable_to_non_nullable
as ContentFlag?,effect: freezed == effect ? _self.effect : effect // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of ContentFlagOutcome
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContentFlagCopyWith<$Res>? get flag {
    if (_self.flag == null) {
    return null;
  }

  return $ContentFlagCopyWith<$Res>(_self.flag!, (value) {
    return _then(_self.copyWith(flag: value));
  });
}
}


/// Adds pattern-matching-related methods to [ContentFlagOutcome].
extension ContentFlagOutcomePatterns on ContentFlagOutcome {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContentFlagOutcome value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContentFlagOutcome() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContentFlagOutcome value)  $default,){
final _that = this;
switch (_that) {
case _ContentFlagOutcome():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContentFlagOutcome value)?  $default,){
final _that = this;
switch (_that) {
case _ContentFlagOutcome() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ContentFlag? flag, @JsonKey(name: 'effect')@_FlexibleTextConverter()  String? effect)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContentFlagOutcome() when $default != null:
return $default(_that.flag,_that.effect);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ContentFlag? flag, @JsonKey(name: 'effect')@_FlexibleTextConverter()  String? effect)  $default,) {final _that = this;
switch (_that) {
case _ContentFlagOutcome():
return $default(_that.flag,_that.effect);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ContentFlag? flag, @JsonKey(name: 'effect')@_FlexibleTextConverter()  String? effect)?  $default,) {final _that = this;
switch (_that) {
case _ContentFlagOutcome() when $default != null:
return $default(_that.flag,_that.effect);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContentFlagOutcome implements ContentFlagOutcome {
  const _ContentFlagOutcome({this.flag, @JsonKey(name: 'effect')@_FlexibleTextConverter() this.effect});
  factory _ContentFlagOutcome.fromJson(Map<String, dynamic> json) => _$ContentFlagOutcomeFromJson(json);

@override final  ContentFlag? flag;
@override@JsonKey(name: 'effect')@_FlexibleTextConverter() final  String? effect;

/// Create a copy of ContentFlagOutcome
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContentFlagOutcomeCopyWith<_ContentFlagOutcome> get copyWith => __$ContentFlagOutcomeCopyWithImpl<_ContentFlagOutcome>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContentFlagOutcomeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContentFlagOutcome&&(identical(other.flag, flag) || other.flag == flag)&&(identical(other.effect, effect) || other.effect == effect));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,flag,effect);

@override
String toString() {
  return 'ContentFlagOutcome(flag: $flag, effect: $effect)';
}


}

/// @nodoc
abstract mixin class _$ContentFlagOutcomeCopyWith<$Res> implements $ContentFlagOutcomeCopyWith<$Res> {
  factory _$ContentFlagOutcomeCopyWith(_ContentFlagOutcome value, $Res Function(_ContentFlagOutcome) _then) = __$ContentFlagOutcomeCopyWithImpl;
@override @useResult
$Res call({
 ContentFlag? flag,@JsonKey(name: 'effect')@_FlexibleTextConverter() String? effect
});


@override $ContentFlagCopyWith<$Res>? get flag;

}
/// @nodoc
class __$ContentFlagOutcomeCopyWithImpl<$Res>
    implements _$ContentFlagOutcomeCopyWith<$Res> {
  __$ContentFlagOutcomeCopyWithImpl(this._self, this._then);

  final _ContentFlagOutcome _self;
  final $Res Function(_ContentFlagOutcome) _then;

/// Create a copy of ContentFlagOutcome
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? flag = freezed,Object? effect = freezed,}) {
  return _then(_ContentFlagOutcome(
flag: freezed == flag ? _self.flag : flag // ignore: cast_nullable_to_non_nullable
as ContentFlag?,effect: freezed == effect ? _self.effect : effect // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ContentFlagOutcome
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContentFlagCopyWith<$Res>? get flag {
    if (_self.flag == null) {
    return null;
  }

  return $ContentFlagCopyWith<$Res>(_self.flag!, (value) {
    return _then(_self.copyWith(flag: value));
  });
}
}


/// @nodoc
mixin _$ModerationPendingApproval {

 String? get id;/// `ban` or `suspension` — the governance action vocabulary, not the
/// moderation one (`user_banned` / `user_suspended`).
@JsonKey(name: 'governance_action') String get governanceAction;@JsonKey(name: 'target_user') String? get targetUser;@JsonKey(name: 'requested_by') String? get requestedBy;@JsonKey(name: 'requested_by_profile') String get requestedByProfile; String get reason;@JsonKey(name: 'duration_days') int? get durationDays;@JsonKey(name: 'requires_second') bool get requiresSecond;@JsonKey(name: 'waiting_seconds') int get waitingSeconds;@JsonKey(name: 'created_at') String? get createdAt;@JsonKey(name: 'moderation_action_id') String? get moderationActionId;
/// Create a copy of ModerationPendingApproval
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModerationPendingApprovalCopyWith<ModerationPendingApproval> get copyWith => _$ModerationPendingApprovalCopyWithImpl<ModerationPendingApproval>(this as ModerationPendingApproval, _$identity);

  /// Serializes this ModerationPendingApproval to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModerationPendingApproval&&(identical(other.id, id) || other.id == id)&&(identical(other.governanceAction, governanceAction) || other.governanceAction == governanceAction)&&(identical(other.targetUser, targetUser) || other.targetUser == targetUser)&&(identical(other.requestedBy, requestedBy) || other.requestedBy == requestedBy)&&(identical(other.requestedByProfile, requestedByProfile) || other.requestedByProfile == requestedByProfile)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.durationDays, durationDays) || other.durationDays == durationDays)&&(identical(other.requiresSecond, requiresSecond) || other.requiresSecond == requiresSecond)&&(identical(other.waitingSeconds, waitingSeconds) || other.waitingSeconds == waitingSeconds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.moderationActionId, moderationActionId) || other.moderationActionId == moderationActionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,governanceAction,targetUser,requestedBy,requestedByProfile,reason,durationDays,requiresSecond,waitingSeconds,createdAt,moderationActionId);

@override
String toString() {
  return 'ModerationPendingApproval(id: $id, governanceAction: $governanceAction, targetUser: $targetUser, requestedBy: $requestedBy, requestedByProfile: $requestedByProfile, reason: $reason, durationDays: $durationDays, requiresSecond: $requiresSecond, waitingSeconds: $waitingSeconds, createdAt: $createdAt, moderationActionId: $moderationActionId)';
}


}

/// @nodoc
abstract mixin class $ModerationPendingApprovalCopyWith<$Res>  {
  factory $ModerationPendingApprovalCopyWith(ModerationPendingApproval value, $Res Function(ModerationPendingApproval) _then) = _$ModerationPendingApprovalCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(name: 'governance_action') String governanceAction,@JsonKey(name: 'target_user') String? targetUser,@JsonKey(name: 'requested_by') String? requestedBy,@JsonKey(name: 'requested_by_profile') String requestedByProfile, String reason,@JsonKey(name: 'duration_days') int? durationDays,@JsonKey(name: 'requires_second') bool requiresSecond,@JsonKey(name: 'waiting_seconds') int waitingSeconds,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'moderation_action_id') String? moderationActionId
});




}
/// @nodoc
class _$ModerationPendingApprovalCopyWithImpl<$Res>
    implements $ModerationPendingApprovalCopyWith<$Res> {
  _$ModerationPendingApprovalCopyWithImpl(this._self, this._then);

  final ModerationPendingApproval _self;
  final $Res Function(ModerationPendingApproval) _then;

/// Create a copy of ModerationPendingApproval
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? governanceAction = null,Object? targetUser = freezed,Object? requestedBy = freezed,Object? requestedByProfile = null,Object? reason = null,Object? durationDays = freezed,Object? requiresSecond = null,Object? waitingSeconds = null,Object? createdAt = freezed,Object? moderationActionId = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,governanceAction: null == governanceAction ? _self.governanceAction : governanceAction // ignore: cast_nullable_to_non_nullable
as String,targetUser: freezed == targetUser ? _self.targetUser : targetUser // ignore: cast_nullable_to_non_nullable
as String?,requestedBy: freezed == requestedBy ? _self.requestedBy : requestedBy // ignore: cast_nullable_to_non_nullable
as String?,requestedByProfile: null == requestedByProfile ? _self.requestedByProfile : requestedByProfile // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,durationDays: freezed == durationDays ? _self.durationDays : durationDays // ignore: cast_nullable_to_non_nullable
as int?,requiresSecond: null == requiresSecond ? _self.requiresSecond : requiresSecond // ignore: cast_nullable_to_non_nullable
as bool,waitingSeconds: null == waitingSeconds ? _self.waitingSeconds : waitingSeconds // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,moderationActionId: freezed == moderationActionId ? _self.moderationActionId : moderationActionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ModerationPendingApproval].
extension ModerationPendingApprovalPatterns on ModerationPendingApproval {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModerationPendingApproval value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModerationPendingApproval() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModerationPendingApproval value)  $default,){
final _that = this;
switch (_that) {
case _ModerationPendingApproval():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModerationPendingApproval value)?  $default,){
final _that = this;
switch (_that) {
case _ModerationPendingApproval() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'governance_action')  String governanceAction, @JsonKey(name: 'target_user')  String? targetUser, @JsonKey(name: 'requested_by')  String? requestedBy, @JsonKey(name: 'requested_by_profile')  String requestedByProfile,  String reason, @JsonKey(name: 'duration_days')  int? durationDays, @JsonKey(name: 'requires_second')  bool requiresSecond, @JsonKey(name: 'waiting_seconds')  int waitingSeconds, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'moderation_action_id')  String? moderationActionId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModerationPendingApproval() when $default != null:
return $default(_that.id,_that.governanceAction,_that.targetUser,_that.requestedBy,_that.requestedByProfile,_that.reason,_that.durationDays,_that.requiresSecond,_that.waitingSeconds,_that.createdAt,_that.moderationActionId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'governance_action')  String governanceAction, @JsonKey(name: 'target_user')  String? targetUser, @JsonKey(name: 'requested_by')  String? requestedBy, @JsonKey(name: 'requested_by_profile')  String requestedByProfile,  String reason, @JsonKey(name: 'duration_days')  int? durationDays, @JsonKey(name: 'requires_second')  bool requiresSecond, @JsonKey(name: 'waiting_seconds')  int waitingSeconds, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'moderation_action_id')  String? moderationActionId)  $default,) {final _that = this;
switch (_that) {
case _ModerationPendingApproval():
return $default(_that.id,_that.governanceAction,_that.targetUser,_that.requestedBy,_that.requestedByProfile,_that.reason,_that.durationDays,_that.requiresSecond,_that.waitingSeconds,_that.createdAt,_that.moderationActionId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(name: 'governance_action')  String governanceAction, @JsonKey(name: 'target_user')  String? targetUser, @JsonKey(name: 'requested_by')  String? requestedBy, @JsonKey(name: 'requested_by_profile')  String requestedByProfile,  String reason, @JsonKey(name: 'duration_days')  int? durationDays, @JsonKey(name: 'requires_second')  bool requiresSecond, @JsonKey(name: 'waiting_seconds')  int waitingSeconds, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'moderation_action_id')  String? moderationActionId)?  $default,) {final _that = this;
switch (_that) {
case _ModerationPendingApproval() when $default != null:
return $default(_that.id,_that.governanceAction,_that.targetUser,_that.requestedBy,_that.requestedByProfile,_that.reason,_that.durationDays,_that.requiresSecond,_that.waitingSeconds,_that.createdAt,_that.moderationActionId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ModerationPendingApproval implements ModerationPendingApproval {
  const _ModerationPendingApproval({this.id, @JsonKey(name: 'governance_action') this.governanceAction = '', @JsonKey(name: 'target_user') this.targetUser, @JsonKey(name: 'requested_by') this.requestedBy, @JsonKey(name: 'requested_by_profile') this.requestedByProfile = '', this.reason = '', @JsonKey(name: 'duration_days') this.durationDays, @JsonKey(name: 'requires_second') this.requiresSecond = true, @JsonKey(name: 'waiting_seconds') this.waitingSeconds = 0, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'moderation_action_id') this.moderationActionId});
  factory _ModerationPendingApproval.fromJson(Map<String, dynamic> json) => _$ModerationPendingApprovalFromJson(json);

@override final  String? id;
/// `ban` or `suspension` — the governance action vocabulary, not the
/// moderation one (`user_banned` / `user_suspended`).
@override@JsonKey(name: 'governance_action') final  String governanceAction;
@override@JsonKey(name: 'target_user') final  String? targetUser;
@override@JsonKey(name: 'requested_by') final  String? requestedBy;
@override@JsonKey(name: 'requested_by_profile') final  String requestedByProfile;
@override@JsonKey() final  String reason;
@override@JsonKey(name: 'duration_days') final  int? durationDays;
@override@JsonKey(name: 'requires_second') final  bool requiresSecond;
@override@JsonKey(name: 'waiting_seconds') final  int waitingSeconds;
@override@JsonKey(name: 'created_at') final  String? createdAt;
@override@JsonKey(name: 'moderation_action_id') final  String? moderationActionId;

/// Create a copy of ModerationPendingApproval
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModerationPendingApprovalCopyWith<_ModerationPendingApproval> get copyWith => __$ModerationPendingApprovalCopyWithImpl<_ModerationPendingApproval>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ModerationPendingApprovalToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModerationPendingApproval&&(identical(other.id, id) || other.id == id)&&(identical(other.governanceAction, governanceAction) || other.governanceAction == governanceAction)&&(identical(other.targetUser, targetUser) || other.targetUser == targetUser)&&(identical(other.requestedBy, requestedBy) || other.requestedBy == requestedBy)&&(identical(other.requestedByProfile, requestedByProfile) || other.requestedByProfile == requestedByProfile)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.durationDays, durationDays) || other.durationDays == durationDays)&&(identical(other.requiresSecond, requiresSecond) || other.requiresSecond == requiresSecond)&&(identical(other.waitingSeconds, waitingSeconds) || other.waitingSeconds == waitingSeconds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.moderationActionId, moderationActionId) || other.moderationActionId == moderationActionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,governanceAction,targetUser,requestedBy,requestedByProfile,reason,durationDays,requiresSecond,waitingSeconds,createdAt,moderationActionId);

@override
String toString() {
  return 'ModerationPendingApproval(id: $id, governanceAction: $governanceAction, targetUser: $targetUser, requestedBy: $requestedBy, requestedByProfile: $requestedByProfile, reason: $reason, durationDays: $durationDays, requiresSecond: $requiresSecond, waitingSeconds: $waitingSeconds, createdAt: $createdAt, moderationActionId: $moderationActionId)';
}


}

/// @nodoc
abstract mixin class _$ModerationPendingApprovalCopyWith<$Res> implements $ModerationPendingApprovalCopyWith<$Res> {
  factory _$ModerationPendingApprovalCopyWith(_ModerationPendingApproval value, $Res Function(_ModerationPendingApproval) _then) = __$ModerationPendingApprovalCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(name: 'governance_action') String governanceAction,@JsonKey(name: 'target_user') String? targetUser,@JsonKey(name: 'requested_by') String? requestedBy,@JsonKey(name: 'requested_by_profile') String requestedByProfile, String reason,@JsonKey(name: 'duration_days') int? durationDays,@JsonKey(name: 'requires_second') bool requiresSecond,@JsonKey(name: 'waiting_seconds') int waitingSeconds,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'moderation_action_id') String? moderationActionId
});




}
/// @nodoc
class __$ModerationPendingApprovalCopyWithImpl<$Res>
    implements _$ModerationPendingApprovalCopyWith<$Res> {
  __$ModerationPendingApprovalCopyWithImpl(this._self, this._then);

  final _ModerationPendingApproval _self;
  final $Res Function(_ModerationPendingApproval) _then;

/// Create a copy of ModerationPendingApproval
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? governanceAction = null,Object? targetUser = freezed,Object? requestedBy = freezed,Object? requestedByProfile = null,Object? reason = null,Object? durationDays = freezed,Object? requiresSecond = null,Object? waitingSeconds = null,Object? createdAt = freezed,Object? moderationActionId = freezed,}) {
  return _then(_ModerationPendingApproval(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,governanceAction: null == governanceAction ? _self.governanceAction : governanceAction // ignore: cast_nullable_to_non_nullable
as String,targetUser: freezed == targetUser ? _self.targetUser : targetUser // ignore: cast_nullable_to_non_nullable
as String?,requestedBy: freezed == requestedBy ? _self.requestedBy : requestedBy // ignore: cast_nullable_to_non_nullable
as String?,requestedByProfile: null == requestedByProfile ? _self.requestedByProfile : requestedByProfile // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,durationDays: freezed == durationDays ? _self.durationDays : durationDays // ignore: cast_nullable_to_non_nullable
as int?,requiresSecond: null == requiresSecond ? _self.requiresSecond : requiresSecond // ignore: cast_nullable_to_non_nullable
as bool,waitingSeconds: null == waitingSeconds ? _self.waitingSeconds : waitingSeconds // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,moderationActionId: freezed == moderationActionId ? _self.moderationActionId : moderationActionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ModerationAppeal {

 String? get id; String? get action; String? get appellant; String get reason;/// submitted / under_review / approved / denied.
 String get status; String? get reviewer;@JsonKey(name: 'reviewed_at') String? get reviewedAt;@JsonKey(name: 'resolution_note') String get resolutionNote;@JsonKey(name: 'created_at') String? get createdAt;
/// Create a copy of ModerationAppeal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModerationAppealCopyWith<ModerationAppeal> get copyWith => _$ModerationAppealCopyWithImpl<ModerationAppeal>(this as ModerationAppeal, _$identity);

  /// Serializes this ModerationAppeal to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModerationAppeal&&(identical(other.id, id) || other.id == id)&&(identical(other.action, action) || other.action == action)&&(identical(other.appellant, appellant) || other.appellant == appellant)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.status, status) || other.status == status)&&(identical(other.reviewer, reviewer) || other.reviewer == reviewer)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.resolutionNote, resolutionNote) || other.resolutionNote == resolutionNote)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,action,appellant,reason,status,reviewer,reviewedAt,resolutionNote,createdAt);

@override
String toString() {
  return 'ModerationAppeal(id: $id, action: $action, appellant: $appellant, reason: $reason, status: $status, reviewer: $reviewer, reviewedAt: $reviewedAt, resolutionNote: $resolutionNote, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ModerationAppealCopyWith<$Res>  {
  factory $ModerationAppealCopyWith(ModerationAppeal value, $Res Function(ModerationAppeal) _then) = _$ModerationAppealCopyWithImpl;
@useResult
$Res call({
 String? id, String? action, String? appellant, String reason, String status, String? reviewer,@JsonKey(name: 'reviewed_at') String? reviewedAt,@JsonKey(name: 'resolution_note') String resolutionNote,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class _$ModerationAppealCopyWithImpl<$Res>
    implements $ModerationAppealCopyWith<$Res> {
  _$ModerationAppealCopyWithImpl(this._self, this._then);

  final ModerationAppeal _self;
  final $Res Function(ModerationAppeal) _then;

/// Create a copy of ModerationAppeal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? action = freezed,Object? appellant = freezed,Object? reason = null,Object? status = null,Object? reviewer = freezed,Object? reviewedAt = freezed,Object? resolutionNote = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,action: freezed == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String?,appellant: freezed == appellant ? _self.appellant : appellant // ignore: cast_nullable_to_non_nullable
as String?,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,reviewer: freezed == reviewer ? _self.reviewer : reviewer // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as String?,resolutionNote: null == resolutionNote ? _self.resolutionNote : resolutionNote // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ModerationAppeal].
extension ModerationAppealPatterns on ModerationAppeal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModerationAppeal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModerationAppeal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModerationAppeal value)  $default,){
final _that = this;
switch (_that) {
case _ModerationAppeal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModerationAppeal value)?  $default,){
final _that = this;
switch (_that) {
case _ModerationAppeal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? action,  String? appellant,  String reason,  String status,  String? reviewer, @JsonKey(name: 'reviewed_at')  String? reviewedAt, @JsonKey(name: 'resolution_note')  String resolutionNote, @JsonKey(name: 'created_at')  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModerationAppeal() when $default != null:
return $default(_that.id,_that.action,_that.appellant,_that.reason,_that.status,_that.reviewer,_that.reviewedAt,_that.resolutionNote,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? action,  String? appellant,  String reason,  String status,  String? reviewer, @JsonKey(name: 'reviewed_at')  String? reviewedAt, @JsonKey(name: 'resolution_note')  String resolutionNote, @JsonKey(name: 'created_at')  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _ModerationAppeal():
return $default(_that.id,_that.action,_that.appellant,_that.reason,_that.status,_that.reviewer,_that.reviewedAt,_that.resolutionNote,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? action,  String? appellant,  String reason,  String status,  String? reviewer, @JsonKey(name: 'reviewed_at')  String? reviewedAt, @JsonKey(name: 'resolution_note')  String resolutionNote, @JsonKey(name: 'created_at')  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ModerationAppeal() when $default != null:
return $default(_that.id,_that.action,_that.appellant,_that.reason,_that.status,_that.reviewer,_that.reviewedAt,_that.resolutionNote,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ModerationAppeal implements ModerationAppeal {
  const _ModerationAppeal({this.id, this.action, this.appellant, this.reason = '', this.status = '', this.reviewer, @JsonKey(name: 'reviewed_at') this.reviewedAt, @JsonKey(name: 'resolution_note') this.resolutionNote = '', @JsonKey(name: 'created_at') this.createdAt});
  factory _ModerationAppeal.fromJson(Map<String, dynamic> json) => _$ModerationAppealFromJson(json);

@override final  String? id;
@override final  String? action;
@override final  String? appellant;
@override@JsonKey() final  String reason;
/// submitted / under_review / approved / denied.
@override@JsonKey() final  String status;
@override final  String? reviewer;
@override@JsonKey(name: 'reviewed_at') final  String? reviewedAt;
@override@JsonKey(name: 'resolution_note') final  String resolutionNote;
@override@JsonKey(name: 'created_at') final  String? createdAt;

/// Create a copy of ModerationAppeal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModerationAppealCopyWith<_ModerationAppeal> get copyWith => __$ModerationAppealCopyWithImpl<_ModerationAppeal>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ModerationAppealToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModerationAppeal&&(identical(other.id, id) || other.id == id)&&(identical(other.action, action) || other.action == action)&&(identical(other.appellant, appellant) || other.appellant == appellant)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.status, status) || other.status == status)&&(identical(other.reviewer, reviewer) || other.reviewer == reviewer)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.resolutionNote, resolutionNote) || other.resolutionNote == resolutionNote)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,action,appellant,reason,status,reviewer,reviewedAt,resolutionNote,createdAt);

@override
String toString() {
  return 'ModerationAppeal(id: $id, action: $action, appellant: $appellant, reason: $reason, status: $status, reviewer: $reviewer, reviewedAt: $reviewedAt, resolutionNote: $resolutionNote, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ModerationAppealCopyWith<$Res> implements $ModerationAppealCopyWith<$Res> {
  factory _$ModerationAppealCopyWith(_ModerationAppeal value, $Res Function(_ModerationAppeal) _then) = __$ModerationAppealCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? action, String? appellant, String reason, String status, String? reviewer,@JsonKey(name: 'reviewed_at') String? reviewedAt,@JsonKey(name: 'resolution_note') String resolutionNote,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class __$ModerationAppealCopyWithImpl<$Res>
    implements _$ModerationAppealCopyWith<$Res> {
  __$ModerationAppealCopyWithImpl(this._self, this._then);

  final _ModerationAppeal _self;
  final $Res Function(_ModerationAppeal) _then;

/// Create a copy of ModerationAppeal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? action = freezed,Object? appellant = freezed,Object? reason = null,Object? status = null,Object? reviewer = freezed,Object? reviewedAt = freezed,Object? resolutionNote = null,Object? createdAt = freezed,}) {
  return _then(_ModerationAppeal(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,action: freezed == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String?,appellant: freezed == appellant ? _self.appellant : appellant // ignore: cast_nullable_to_non_nullable
as String?,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,reviewer: freezed == reviewer ? _self.reviewer : reviewer // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as String?,resolutionNote: null == resolutionNote ? _self.resolutionNote : resolutionNote // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ModerationCommendation {

 String? get id;/// A profile UUID, per `Commendation.recipient`.
 String? get recipient;@JsonKey(name: 'issued_by') String? get issuedBy; String get category;@JsonKey(name: 'category_display') String get categoryDisplay; String get message;@JsonKey(name: 'visible_to_recipient') bool get visibleToRecipient;@JsonKey(name: 'created_at') String? get createdAt;
/// Create a copy of ModerationCommendation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModerationCommendationCopyWith<ModerationCommendation> get copyWith => _$ModerationCommendationCopyWithImpl<ModerationCommendation>(this as ModerationCommendation, _$identity);

  /// Serializes this ModerationCommendation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModerationCommendation&&(identical(other.id, id) || other.id == id)&&(identical(other.recipient, recipient) || other.recipient == recipient)&&(identical(other.issuedBy, issuedBy) || other.issuedBy == issuedBy)&&(identical(other.category, category) || other.category == category)&&(identical(other.categoryDisplay, categoryDisplay) || other.categoryDisplay == categoryDisplay)&&(identical(other.message, message) || other.message == message)&&(identical(other.visibleToRecipient, visibleToRecipient) || other.visibleToRecipient == visibleToRecipient)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,recipient,issuedBy,category,categoryDisplay,message,visibleToRecipient,createdAt);

@override
String toString() {
  return 'ModerationCommendation(id: $id, recipient: $recipient, issuedBy: $issuedBy, category: $category, categoryDisplay: $categoryDisplay, message: $message, visibleToRecipient: $visibleToRecipient, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ModerationCommendationCopyWith<$Res>  {
  factory $ModerationCommendationCopyWith(ModerationCommendation value, $Res Function(ModerationCommendation) _then) = _$ModerationCommendationCopyWithImpl;
@useResult
$Res call({
 String? id, String? recipient,@JsonKey(name: 'issued_by') String? issuedBy, String category,@JsonKey(name: 'category_display') String categoryDisplay, String message,@JsonKey(name: 'visible_to_recipient') bool visibleToRecipient,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class _$ModerationCommendationCopyWithImpl<$Res>
    implements $ModerationCommendationCopyWith<$Res> {
  _$ModerationCommendationCopyWithImpl(this._self, this._then);

  final ModerationCommendation _self;
  final $Res Function(ModerationCommendation) _then;

/// Create a copy of ModerationCommendation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? recipient = freezed,Object? issuedBy = freezed,Object? category = null,Object? categoryDisplay = null,Object? message = null,Object? visibleToRecipient = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,recipient: freezed == recipient ? _self.recipient : recipient // ignore: cast_nullable_to_non_nullable
as String?,issuedBy: freezed == issuedBy ? _self.issuedBy : issuedBy // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,categoryDisplay: null == categoryDisplay ? _self.categoryDisplay : categoryDisplay // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,visibleToRecipient: null == visibleToRecipient ? _self.visibleToRecipient : visibleToRecipient // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ModerationCommendation].
extension ModerationCommendationPatterns on ModerationCommendation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModerationCommendation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModerationCommendation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModerationCommendation value)  $default,){
final _that = this;
switch (_that) {
case _ModerationCommendation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModerationCommendation value)?  $default,){
final _that = this;
switch (_that) {
case _ModerationCommendation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? recipient, @JsonKey(name: 'issued_by')  String? issuedBy,  String category, @JsonKey(name: 'category_display')  String categoryDisplay,  String message, @JsonKey(name: 'visible_to_recipient')  bool visibleToRecipient, @JsonKey(name: 'created_at')  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModerationCommendation() when $default != null:
return $default(_that.id,_that.recipient,_that.issuedBy,_that.category,_that.categoryDisplay,_that.message,_that.visibleToRecipient,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? recipient, @JsonKey(name: 'issued_by')  String? issuedBy,  String category, @JsonKey(name: 'category_display')  String categoryDisplay,  String message, @JsonKey(name: 'visible_to_recipient')  bool visibleToRecipient, @JsonKey(name: 'created_at')  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _ModerationCommendation():
return $default(_that.id,_that.recipient,_that.issuedBy,_that.category,_that.categoryDisplay,_that.message,_that.visibleToRecipient,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? recipient, @JsonKey(name: 'issued_by')  String? issuedBy,  String category, @JsonKey(name: 'category_display')  String categoryDisplay,  String message, @JsonKey(name: 'visible_to_recipient')  bool visibleToRecipient, @JsonKey(name: 'created_at')  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ModerationCommendation() when $default != null:
return $default(_that.id,_that.recipient,_that.issuedBy,_that.category,_that.categoryDisplay,_that.message,_that.visibleToRecipient,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ModerationCommendation implements ModerationCommendation {
  const _ModerationCommendation({this.id, this.recipient, @JsonKey(name: 'issued_by') this.issuedBy, this.category = '', @JsonKey(name: 'category_display') this.categoryDisplay = '', this.message = '', @JsonKey(name: 'visible_to_recipient') this.visibleToRecipient = true, @JsonKey(name: 'created_at') this.createdAt});
  factory _ModerationCommendation.fromJson(Map<String, dynamic> json) => _$ModerationCommendationFromJson(json);

@override final  String? id;
/// A profile UUID, per `Commendation.recipient`.
@override final  String? recipient;
@override@JsonKey(name: 'issued_by') final  String? issuedBy;
@override@JsonKey() final  String category;
@override@JsonKey(name: 'category_display') final  String categoryDisplay;
@override@JsonKey() final  String message;
@override@JsonKey(name: 'visible_to_recipient') final  bool visibleToRecipient;
@override@JsonKey(name: 'created_at') final  String? createdAt;

/// Create a copy of ModerationCommendation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModerationCommendationCopyWith<_ModerationCommendation> get copyWith => __$ModerationCommendationCopyWithImpl<_ModerationCommendation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ModerationCommendationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModerationCommendation&&(identical(other.id, id) || other.id == id)&&(identical(other.recipient, recipient) || other.recipient == recipient)&&(identical(other.issuedBy, issuedBy) || other.issuedBy == issuedBy)&&(identical(other.category, category) || other.category == category)&&(identical(other.categoryDisplay, categoryDisplay) || other.categoryDisplay == categoryDisplay)&&(identical(other.message, message) || other.message == message)&&(identical(other.visibleToRecipient, visibleToRecipient) || other.visibleToRecipient == visibleToRecipient)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,recipient,issuedBy,category,categoryDisplay,message,visibleToRecipient,createdAt);

@override
String toString() {
  return 'ModerationCommendation(id: $id, recipient: $recipient, issuedBy: $issuedBy, category: $category, categoryDisplay: $categoryDisplay, message: $message, visibleToRecipient: $visibleToRecipient, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ModerationCommendationCopyWith<$Res> implements $ModerationCommendationCopyWith<$Res> {
  factory _$ModerationCommendationCopyWith(_ModerationCommendation value, $Res Function(_ModerationCommendation) _then) = __$ModerationCommendationCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? recipient,@JsonKey(name: 'issued_by') String? issuedBy, String category,@JsonKey(name: 'category_display') String categoryDisplay, String message,@JsonKey(name: 'visible_to_recipient') bool visibleToRecipient,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class __$ModerationCommendationCopyWithImpl<$Res>
    implements _$ModerationCommendationCopyWith<$Res> {
  __$ModerationCommendationCopyWithImpl(this._self, this._then);

  final _ModerationCommendation _self;
  final $Res Function(_ModerationCommendation) _then;

/// Create a copy of ModerationCommendation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? recipient = freezed,Object? issuedBy = freezed,Object? category = null,Object? categoryDisplay = null,Object? message = null,Object? visibleToRecipient = null,Object? createdAt = freezed,}) {
  return _then(_ModerationCommendation(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,recipient: freezed == recipient ? _self.recipient : recipient // ignore: cast_nullable_to_non_nullable
as String?,issuedBy: freezed == issuedBy ? _self.issuedBy : issuedBy // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,categoryDisplay: null == categoryDisplay ? _self.categoryDisplay : categoryDisplay // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,visibleToRecipient: null == visibleToRecipient ? _self.visibleToRecipient : visibleToRecipient // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
