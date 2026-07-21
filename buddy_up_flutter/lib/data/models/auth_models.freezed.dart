// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RegisterPayload {

 String get email; String? get phone; String get password; String get dob; String get username; String get displayName; String get role; bool get acceptedTerms; bool get acceptedPrivacy; bool get acceptedGuidelines; bool get is16Plus;
/// Create a copy of RegisterPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterPayloadCopyWith<RegisterPayload> get copyWith => _$RegisterPayloadCopyWithImpl<RegisterPayload>(this as RegisterPayload, _$identity);

  /// Serializes this RegisterPayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterPayload&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.password, password) || other.password == password)&&(identical(other.dob, dob) || other.dob == dob)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.role, role) || other.role == role)&&(identical(other.acceptedTerms, acceptedTerms) || other.acceptedTerms == acceptedTerms)&&(identical(other.acceptedPrivacy, acceptedPrivacy) || other.acceptedPrivacy == acceptedPrivacy)&&(identical(other.acceptedGuidelines, acceptedGuidelines) || other.acceptedGuidelines == acceptedGuidelines)&&(identical(other.is16Plus, is16Plus) || other.is16Plus == is16Plus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email,phone,password,dob,username,displayName,role,acceptedTerms,acceptedPrivacy,acceptedGuidelines,is16Plus);

@override
String toString() {
  return 'RegisterPayload(email: $email, phone: $phone, password: $password, dob: $dob, username: $username, displayName: $displayName, role: $role, acceptedTerms: $acceptedTerms, acceptedPrivacy: $acceptedPrivacy, acceptedGuidelines: $acceptedGuidelines, is16Plus: $is16Plus)';
}


}

/// @nodoc
abstract mixin class $RegisterPayloadCopyWith<$Res>  {
  factory $RegisterPayloadCopyWith(RegisterPayload value, $Res Function(RegisterPayload) _then) = _$RegisterPayloadCopyWithImpl;
@useResult
$Res call({
 String email, String? phone, String password, String dob, String username, String displayName, String role, bool acceptedTerms, bool acceptedPrivacy, bool acceptedGuidelines, bool is16Plus
});




}
/// @nodoc
class _$RegisterPayloadCopyWithImpl<$Res>
    implements $RegisterPayloadCopyWith<$Res> {
  _$RegisterPayloadCopyWithImpl(this._self, this._then);

  final RegisterPayload _self;
  final $Res Function(RegisterPayload) _then;

/// Create a copy of RegisterPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? phone = freezed,Object? password = null,Object? dob = null,Object? username = null,Object? displayName = null,Object? role = null,Object? acceptedTerms = null,Object? acceptedPrivacy = null,Object? acceptedGuidelines = null,Object? is16Plus = null,}) {
  return _then(_self.copyWith(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,dob: null == dob ? _self.dob : dob // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,acceptedTerms: null == acceptedTerms ? _self.acceptedTerms : acceptedTerms // ignore: cast_nullable_to_non_nullable
as bool,acceptedPrivacy: null == acceptedPrivacy ? _self.acceptedPrivacy : acceptedPrivacy // ignore: cast_nullable_to_non_nullable
as bool,acceptedGuidelines: null == acceptedGuidelines ? _self.acceptedGuidelines : acceptedGuidelines // ignore: cast_nullable_to_non_nullable
as bool,is16Plus: null == is16Plus ? _self.is16Plus : is16Plus // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RegisterPayload].
extension RegisterPayloadPatterns on RegisterPayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegisterPayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegisterPayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegisterPayload value)  $default,){
final _that = this;
switch (_that) {
case _RegisterPayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegisterPayload value)?  $default,){
final _that = this;
switch (_that) {
case _RegisterPayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email,  String? phone,  String password,  String dob,  String username,  String displayName,  String role,  bool acceptedTerms,  bool acceptedPrivacy,  bool acceptedGuidelines,  bool is16Plus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegisterPayload() when $default != null:
return $default(_that.email,_that.phone,_that.password,_that.dob,_that.username,_that.displayName,_that.role,_that.acceptedTerms,_that.acceptedPrivacy,_that.acceptedGuidelines,_that.is16Plus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email,  String? phone,  String password,  String dob,  String username,  String displayName,  String role,  bool acceptedTerms,  bool acceptedPrivacy,  bool acceptedGuidelines,  bool is16Plus)  $default,) {final _that = this;
switch (_that) {
case _RegisterPayload():
return $default(_that.email,_that.phone,_that.password,_that.dob,_that.username,_that.displayName,_that.role,_that.acceptedTerms,_that.acceptedPrivacy,_that.acceptedGuidelines,_that.is16Plus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email,  String? phone,  String password,  String dob,  String username,  String displayName,  String role,  bool acceptedTerms,  bool acceptedPrivacy,  bool acceptedGuidelines,  bool is16Plus)?  $default,) {final _that = this;
switch (_that) {
case _RegisterPayload() when $default != null:
return $default(_that.email,_that.phone,_that.password,_that.dob,_that.username,_that.displayName,_that.role,_that.acceptedTerms,_that.acceptedPrivacy,_that.acceptedGuidelines,_that.is16Plus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RegisterPayload implements RegisterPayload {
  const _RegisterPayload({required this.email, this.phone, required this.password, required this.dob, required this.username, required this.displayName, required this.role, required this.acceptedTerms, required this.acceptedPrivacy, required this.acceptedGuidelines, required this.is16Plus});
  factory _RegisterPayload.fromJson(Map<String, dynamic> json) => _$RegisterPayloadFromJson(json);

@override final  String email;
@override final  String? phone;
@override final  String password;
@override final  String dob;
@override final  String username;
@override final  String displayName;
@override final  String role;
@override final  bool acceptedTerms;
@override final  bool acceptedPrivacy;
@override final  bool acceptedGuidelines;
@override final  bool is16Plus;

/// Create a copy of RegisterPayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisterPayloadCopyWith<_RegisterPayload> get copyWith => __$RegisterPayloadCopyWithImpl<_RegisterPayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RegisterPayloadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisterPayload&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.password, password) || other.password == password)&&(identical(other.dob, dob) || other.dob == dob)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.role, role) || other.role == role)&&(identical(other.acceptedTerms, acceptedTerms) || other.acceptedTerms == acceptedTerms)&&(identical(other.acceptedPrivacy, acceptedPrivacy) || other.acceptedPrivacy == acceptedPrivacy)&&(identical(other.acceptedGuidelines, acceptedGuidelines) || other.acceptedGuidelines == acceptedGuidelines)&&(identical(other.is16Plus, is16Plus) || other.is16Plus == is16Plus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email,phone,password,dob,username,displayName,role,acceptedTerms,acceptedPrivacy,acceptedGuidelines,is16Plus);

@override
String toString() {
  return 'RegisterPayload(email: $email, phone: $phone, password: $password, dob: $dob, username: $username, displayName: $displayName, role: $role, acceptedTerms: $acceptedTerms, acceptedPrivacy: $acceptedPrivacy, acceptedGuidelines: $acceptedGuidelines, is16Plus: $is16Plus)';
}


}

/// @nodoc
abstract mixin class _$RegisterPayloadCopyWith<$Res> implements $RegisterPayloadCopyWith<$Res> {
  factory _$RegisterPayloadCopyWith(_RegisterPayload value, $Res Function(_RegisterPayload) _then) = __$RegisterPayloadCopyWithImpl;
@override @useResult
$Res call({
 String email, String? phone, String password, String dob, String username, String displayName, String role, bool acceptedTerms, bool acceptedPrivacy, bool acceptedGuidelines, bool is16Plus
});




}
/// @nodoc
class __$RegisterPayloadCopyWithImpl<$Res>
    implements _$RegisterPayloadCopyWith<$Res> {
  __$RegisterPayloadCopyWithImpl(this._self, this._then);

  final _RegisterPayload _self;
  final $Res Function(_RegisterPayload) _then;

/// Create a copy of RegisterPayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? phone = freezed,Object? password = null,Object? dob = null,Object? username = null,Object? displayName = null,Object? role = null,Object? acceptedTerms = null,Object? acceptedPrivacy = null,Object? acceptedGuidelines = null,Object? is16Plus = null,}) {
  return _then(_RegisterPayload(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,dob: null == dob ? _self.dob : dob // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,acceptedTerms: null == acceptedTerms ? _self.acceptedTerms : acceptedTerms // ignore: cast_nullable_to_non_nullable
as bool,acceptedPrivacy: null == acceptedPrivacy ? _self.acceptedPrivacy : acceptedPrivacy // ignore: cast_nullable_to_non_nullable
as bool,acceptedGuidelines: null == acceptedGuidelines ? _self.acceptedGuidelines : acceptedGuidelines // ignore: cast_nullable_to_non_nullable
as bool,is16Plus: null == is16Plus ? _self.is16Plus : is16Plus // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$LoginPayload {

 String get email; String get password; bool get rememberMe;
/// Create a copy of LoginPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginPayloadCopyWith<LoginPayload> get copyWith => _$LoginPayloadCopyWithImpl<LoginPayload>(this as LoginPayload, _$identity);

  /// Serializes this LoginPayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginPayload&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.rememberMe, rememberMe) || other.rememberMe == rememberMe));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email,password,rememberMe);

@override
String toString() {
  return 'LoginPayload(email: $email, password: $password, rememberMe: $rememberMe)';
}


}

/// @nodoc
abstract mixin class $LoginPayloadCopyWith<$Res>  {
  factory $LoginPayloadCopyWith(LoginPayload value, $Res Function(LoginPayload) _then) = _$LoginPayloadCopyWithImpl;
@useResult
$Res call({
 String email, String password, bool rememberMe
});




}
/// @nodoc
class _$LoginPayloadCopyWithImpl<$Res>
    implements $LoginPayloadCopyWith<$Res> {
  _$LoginPayloadCopyWithImpl(this._self, this._then);

  final LoginPayload _self;
  final $Res Function(LoginPayload) _then;

/// Create a copy of LoginPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? password = null,Object? rememberMe = null,}) {
  return _then(_self.copyWith(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,rememberMe: null == rememberMe ? _self.rememberMe : rememberMe // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LoginPayload].
extension LoginPayloadPatterns on LoginPayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginPayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginPayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginPayload value)  $default,){
final _that = this;
switch (_that) {
case _LoginPayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginPayload value)?  $default,){
final _that = this;
switch (_that) {
case _LoginPayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email,  String password,  bool rememberMe)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginPayload() when $default != null:
return $default(_that.email,_that.password,_that.rememberMe);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email,  String password,  bool rememberMe)  $default,) {final _that = this;
switch (_that) {
case _LoginPayload():
return $default(_that.email,_that.password,_that.rememberMe);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email,  String password,  bool rememberMe)?  $default,) {final _that = this;
switch (_that) {
case _LoginPayload() when $default != null:
return $default(_that.email,_that.password,_that.rememberMe);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LoginPayload implements LoginPayload {
  const _LoginPayload({required this.email, required this.password, this.rememberMe = false});
  factory _LoginPayload.fromJson(Map<String, dynamic> json) => _$LoginPayloadFromJson(json);

@override final  String email;
@override final  String password;
@override@JsonKey() final  bool rememberMe;

/// Create a copy of LoginPayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginPayloadCopyWith<_LoginPayload> get copyWith => __$LoginPayloadCopyWithImpl<_LoginPayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoginPayloadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginPayload&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.rememberMe, rememberMe) || other.rememberMe == rememberMe));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email,password,rememberMe);

@override
String toString() {
  return 'LoginPayload(email: $email, password: $password, rememberMe: $rememberMe)';
}


}

/// @nodoc
abstract mixin class _$LoginPayloadCopyWith<$Res> implements $LoginPayloadCopyWith<$Res> {
  factory _$LoginPayloadCopyWith(_LoginPayload value, $Res Function(_LoginPayload) _then) = __$LoginPayloadCopyWithImpl;
@override @useResult
$Res call({
 String email, String password, bool rememberMe
});




}
/// @nodoc
class __$LoginPayloadCopyWithImpl<$Res>
    implements _$LoginPayloadCopyWith<$Res> {
  __$LoginPayloadCopyWithImpl(this._self, this._then);

  final _LoginPayload _self;
  final $Res Function(_LoginPayload) _then;

/// Create a copy of LoginPayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? password = null,Object? rememberMe = null,}) {
  return _then(_LoginPayload(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,rememberMe: null == rememberMe ? _self.rememberMe : rememberMe // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$LoginInitResponse {

 bool get requireOtp; String get loginToken; String get maskedEmail;
/// Create a copy of LoginInitResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginInitResponseCopyWith<LoginInitResponse> get copyWith => _$LoginInitResponseCopyWithImpl<LoginInitResponse>(this as LoginInitResponse, _$identity);

  /// Serializes this LoginInitResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginInitResponse&&(identical(other.requireOtp, requireOtp) || other.requireOtp == requireOtp)&&(identical(other.loginToken, loginToken) || other.loginToken == loginToken)&&(identical(other.maskedEmail, maskedEmail) || other.maskedEmail == maskedEmail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,requireOtp,loginToken,maskedEmail);

@override
String toString() {
  return 'LoginInitResponse(requireOtp: $requireOtp, loginToken: $loginToken, maskedEmail: $maskedEmail)';
}


}

/// @nodoc
abstract mixin class $LoginInitResponseCopyWith<$Res>  {
  factory $LoginInitResponseCopyWith(LoginInitResponse value, $Res Function(LoginInitResponse) _then) = _$LoginInitResponseCopyWithImpl;
@useResult
$Res call({
 bool requireOtp, String loginToken, String maskedEmail
});




}
/// @nodoc
class _$LoginInitResponseCopyWithImpl<$Res>
    implements $LoginInitResponseCopyWith<$Res> {
  _$LoginInitResponseCopyWithImpl(this._self, this._then);

  final LoginInitResponse _self;
  final $Res Function(LoginInitResponse) _then;

/// Create a copy of LoginInitResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? requireOtp = null,Object? loginToken = null,Object? maskedEmail = null,}) {
  return _then(_self.copyWith(
requireOtp: null == requireOtp ? _self.requireOtp : requireOtp // ignore: cast_nullable_to_non_nullable
as bool,loginToken: null == loginToken ? _self.loginToken : loginToken // ignore: cast_nullable_to_non_nullable
as String,maskedEmail: null == maskedEmail ? _self.maskedEmail : maskedEmail // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LoginInitResponse].
extension LoginInitResponsePatterns on LoginInitResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginInitResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginInitResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginInitResponse value)  $default,){
final _that = this;
switch (_that) {
case _LoginInitResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginInitResponse value)?  $default,){
final _that = this;
switch (_that) {
case _LoginInitResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool requireOtp,  String loginToken,  String maskedEmail)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginInitResponse() when $default != null:
return $default(_that.requireOtp,_that.loginToken,_that.maskedEmail);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool requireOtp,  String loginToken,  String maskedEmail)  $default,) {final _that = this;
switch (_that) {
case _LoginInitResponse():
return $default(_that.requireOtp,_that.loginToken,_that.maskedEmail);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool requireOtp,  String loginToken,  String maskedEmail)?  $default,) {final _that = this;
switch (_that) {
case _LoginInitResponse() when $default != null:
return $default(_that.requireOtp,_that.loginToken,_that.maskedEmail);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LoginInitResponse implements LoginInitResponse {
  const _LoginInitResponse({required this.requireOtp, required this.loginToken, required this.maskedEmail});
  factory _LoginInitResponse.fromJson(Map<String, dynamic> json) => _$LoginInitResponseFromJson(json);

@override final  bool requireOtp;
@override final  String loginToken;
@override final  String maskedEmail;

/// Create a copy of LoginInitResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginInitResponseCopyWith<_LoginInitResponse> get copyWith => __$LoginInitResponseCopyWithImpl<_LoginInitResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoginInitResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginInitResponse&&(identical(other.requireOtp, requireOtp) || other.requireOtp == requireOtp)&&(identical(other.loginToken, loginToken) || other.loginToken == loginToken)&&(identical(other.maskedEmail, maskedEmail) || other.maskedEmail == maskedEmail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,requireOtp,loginToken,maskedEmail);

@override
String toString() {
  return 'LoginInitResponse(requireOtp: $requireOtp, loginToken: $loginToken, maskedEmail: $maskedEmail)';
}


}

/// @nodoc
abstract mixin class _$LoginInitResponseCopyWith<$Res> implements $LoginInitResponseCopyWith<$Res> {
  factory _$LoginInitResponseCopyWith(_LoginInitResponse value, $Res Function(_LoginInitResponse) _then) = __$LoginInitResponseCopyWithImpl;
@override @useResult
$Res call({
 bool requireOtp, String loginToken, String maskedEmail
});




}
/// @nodoc
class __$LoginInitResponseCopyWithImpl<$Res>
    implements _$LoginInitResponseCopyWith<$Res> {
  __$LoginInitResponseCopyWithImpl(this._self, this._then);

  final _LoginInitResponse _self;
  final $Res Function(_LoginInitResponse) _then;

/// Create a copy of LoginInitResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? requireOtp = null,Object? loginToken = null,Object? maskedEmail = null,}) {
  return _then(_LoginInitResponse(
requireOtp: null == requireOtp ? _self.requireOtp : requireOtp // ignore: cast_nullable_to_non_nullable
as bool,loginToken: null == loginToken ? _self.loginToken : loginToken // ignore: cast_nullable_to_non_nullable
as String,maskedEmail: null == maskedEmail ? _self.maskedEmail : maskedEmail // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$LoginOTPResponse {

 String get access; String get refresh; User get user; Profile get profile; bool get newDevice;
/// Create a copy of LoginOTPResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginOTPResponseCopyWith<LoginOTPResponse> get copyWith => _$LoginOTPResponseCopyWithImpl<LoginOTPResponse>(this as LoginOTPResponse, _$identity);

  /// Serializes this LoginOTPResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginOTPResponse&&(identical(other.access, access) || other.access == access)&&(identical(other.refresh, refresh) || other.refresh == refresh)&&(identical(other.user, user) || other.user == user)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.newDevice, newDevice) || other.newDevice == newDevice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,access,refresh,user,profile,newDevice);

@override
String toString() {
  return 'LoginOTPResponse(access: $access, refresh: $refresh, user: $user, profile: $profile, newDevice: $newDevice)';
}


}

/// @nodoc
abstract mixin class $LoginOTPResponseCopyWith<$Res>  {
  factory $LoginOTPResponseCopyWith(LoginOTPResponse value, $Res Function(LoginOTPResponse) _then) = _$LoginOTPResponseCopyWithImpl;
@useResult
$Res call({
 String access, String refresh, User user, Profile profile, bool newDevice
});


$UserCopyWith<$Res> get user;$ProfileCopyWith<$Res> get profile;

}
/// @nodoc
class _$LoginOTPResponseCopyWithImpl<$Res>
    implements $LoginOTPResponseCopyWith<$Res> {
  _$LoginOTPResponseCopyWithImpl(this._self, this._then);

  final LoginOTPResponse _self;
  final $Res Function(LoginOTPResponse) _then;

/// Create a copy of LoginOTPResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? access = null,Object? refresh = null,Object? user = null,Object? profile = null,Object? newDevice = null,}) {
  return _then(_self.copyWith(
access: null == access ? _self.access : access // ignore: cast_nullable_to_non_nullable
as String,refresh: null == refresh ? _self.refresh : refresh // ignore: cast_nullable_to_non_nullable
as String,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as Profile,newDevice: null == newDevice ? _self.newDevice : newDevice // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of LoginOTPResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res> get user {
  
  return $UserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of LoginOTPResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileCopyWith<$Res> get profile {
  
  return $ProfileCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// Adds pattern-matching-related methods to [LoginOTPResponse].
extension LoginOTPResponsePatterns on LoginOTPResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginOTPResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginOTPResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginOTPResponse value)  $default,){
final _that = this;
switch (_that) {
case _LoginOTPResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginOTPResponse value)?  $default,){
final _that = this;
switch (_that) {
case _LoginOTPResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String access,  String refresh,  User user,  Profile profile,  bool newDevice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginOTPResponse() when $default != null:
return $default(_that.access,_that.refresh,_that.user,_that.profile,_that.newDevice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String access,  String refresh,  User user,  Profile profile,  bool newDevice)  $default,) {final _that = this;
switch (_that) {
case _LoginOTPResponse():
return $default(_that.access,_that.refresh,_that.user,_that.profile,_that.newDevice);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String access,  String refresh,  User user,  Profile profile,  bool newDevice)?  $default,) {final _that = this;
switch (_that) {
case _LoginOTPResponse() when $default != null:
return $default(_that.access,_that.refresh,_that.user,_that.profile,_that.newDevice);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LoginOTPResponse implements LoginOTPResponse {
  const _LoginOTPResponse({required this.access, required this.refresh, required this.user, required this.profile, this.newDevice = false});
  factory _LoginOTPResponse.fromJson(Map<String, dynamic> json) => _$LoginOTPResponseFromJson(json);

@override final  String access;
@override final  String refresh;
@override final  User user;
@override final  Profile profile;
@override@JsonKey() final  bool newDevice;

/// Create a copy of LoginOTPResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginOTPResponseCopyWith<_LoginOTPResponse> get copyWith => __$LoginOTPResponseCopyWithImpl<_LoginOTPResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoginOTPResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginOTPResponse&&(identical(other.access, access) || other.access == access)&&(identical(other.refresh, refresh) || other.refresh == refresh)&&(identical(other.user, user) || other.user == user)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.newDevice, newDevice) || other.newDevice == newDevice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,access,refresh,user,profile,newDevice);

@override
String toString() {
  return 'LoginOTPResponse(access: $access, refresh: $refresh, user: $user, profile: $profile, newDevice: $newDevice)';
}


}

/// @nodoc
abstract mixin class _$LoginOTPResponseCopyWith<$Res> implements $LoginOTPResponseCopyWith<$Res> {
  factory _$LoginOTPResponseCopyWith(_LoginOTPResponse value, $Res Function(_LoginOTPResponse) _then) = __$LoginOTPResponseCopyWithImpl;
@override @useResult
$Res call({
 String access, String refresh, User user, Profile profile, bool newDevice
});


@override $UserCopyWith<$Res> get user;@override $ProfileCopyWith<$Res> get profile;

}
/// @nodoc
class __$LoginOTPResponseCopyWithImpl<$Res>
    implements _$LoginOTPResponseCopyWith<$Res> {
  __$LoginOTPResponseCopyWithImpl(this._self, this._then);

  final _LoginOTPResponse _self;
  final $Res Function(_LoginOTPResponse) _then;

/// Create a copy of LoginOTPResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? access = null,Object? refresh = null,Object? user = null,Object? profile = null,Object? newDevice = null,}) {
  return _then(_LoginOTPResponse(
access: null == access ? _self.access : access // ignore: cast_nullable_to_non_nullable
as String,refresh: null == refresh ? _self.refresh : refresh // ignore: cast_nullable_to_non_nullable
as String,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as Profile,newDevice: null == newDevice ? _self.newDevice : newDevice // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of LoginOTPResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res> get user {
  
  return $UserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of LoginOTPResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileCopyWith<$Res> get profile {
  
  return $ProfileCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// @nodoc
mixin _$RegisterResponse {

 String get registrationToken; String get email; String get userId; String get message;
/// Create a copy of RegisterResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterResponseCopyWith<RegisterResponse> get copyWith => _$RegisterResponseCopyWithImpl<RegisterResponse>(this as RegisterResponse, _$identity);

  /// Serializes this RegisterResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterResponse&&(identical(other.registrationToken, registrationToken) || other.registrationToken == registrationToken)&&(identical(other.email, email) || other.email == email)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,registrationToken,email,userId,message);

@override
String toString() {
  return 'RegisterResponse(registrationToken: $registrationToken, email: $email, userId: $userId, message: $message)';
}


}

/// @nodoc
abstract mixin class $RegisterResponseCopyWith<$Res>  {
  factory $RegisterResponseCopyWith(RegisterResponse value, $Res Function(RegisterResponse) _then) = _$RegisterResponseCopyWithImpl;
@useResult
$Res call({
 String registrationToken, String email, String userId, String message
});




}
/// @nodoc
class _$RegisterResponseCopyWithImpl<$Res>
    implements $RegisterResponseCopyWith<$Res> {
  _$RegisterResponseCopyWithImpl(this._self, this._then);

  final RegisterResponse _self;
  final $Res Function(RegisterResponse) _then;

/// Create a copy of RegisterResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? registrationToken = null,Object? email = null,Object? userId = null,Object? message = null,}) {
  return _then(_self.copyWith(
registrationToken: null == registrationToken ? _self.registrationToken : registrationToken // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RegisterResponse].
extension RegisterResponsePatterns on RegisterResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegisterResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegisterResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegisterResponse value)  $default,){
final _that = this;
switch (_that) {
case _RegisterResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegisterResponse value)?  $default,){
final _that = this;
switch (_that) {
case _RegisterResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String registrationToken,  String email,  String userId,  String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegisterResponse() when $default != null:
return $default(_that.registrationToken,_that.email,_that.userId,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String registrationToken,  String email,  String userId,  String message)  $default,) {final _that = this;
switch (_that) {
case _RegisterResponse():
return $default(_that.registrationToken,_that.email,_that.userId,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String registrationToken,  String email,  String userId,  String message)?  $default,) {final _that = this;
switch (_that) {
case _RegisterResponse() when $default != null:
return $default(_that.registrationToken,_that.email,_that.userId,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RegisterResponse implements RegisterResponse {
  const _RegisterResponse({required this.registrationToken, required this.email, required this.userId, required this.message});
  factory _RegisterResponse.fromJson(Map<String, dynamic> json) => _$RegisterResponseFromJson(json);

@override final  String registrationToken;
@override final  String email;
@override final  String userId;
@override final  String message;

/// Create a copy of RegisterResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisterResponseCopyWith<_RegisterResponse> get copyWith => __$RegisterResponseCopyWithImpl<_RegisterResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RegisterResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisterResponse&&(identical(other.registrationToken, registrationToken) || other.registrationToken == registrationToken)&&(identical(other.email, email) || other.email == email)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,registrationToken,email,userId,message);

@override
String toString() {
  return 'RegisterResponse(registrationToken: $registrationToken, email: $email, userId: $userId, message: $message)';
}


}

/// @nodoc
abstract mixin class _$RegisterResponseCopyWith<$Res> implements $RegisterResponseCopyWith<$Res> {
  factory _$RegisterResponseCopyWith(_RegisterResponse value, $Res Function(_RegisterResponse) _then) = __$RegisterResponseCopyWithImpl;
@override @useResult
$Res call({
 String registrationToken, String email, String userId, String message
});




}
/// @nodoc
class __$RegisterResponseCopyWithImpl<$Res>
    implements _$RegisterResponseCopyWith<$Res> {
  __$RegisterResponseCopyWithImpl(this._self, this._then);

  final _RegisterResponse _self;
  final $Res Function(_RegisterResponse) _then;

/// Create a copy of RegisterResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? registrationToken = null,Object? email = null,Object? userId = null,Object? message = null,}) {
  return _then(_RegisterResponse(
registrationToken: null == registrationToken ? _self.registrationToken : registrationToken // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$TOTPSetupResponse {

 String get secret; String get provisioningUri; String get qrCode;
/// Create a copy of TOTPSetupResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TOTPSetupResponseCopyWith<TOTPSetupResponse> get copyWith => _$TOTPSetupResponseCopyWithImpl<TOTPSetupResponse>(this as TOTPSetupResponse, _$identity);

  /// Serializes this TOTPSetupResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TOTPSetupResponse&&(identical(other.secret, secret) || other.secret == secret)&&(identical(other.provisioningUri, provisioningUri) || other.provisioningUri == provisioningUri)&&(identical(other.qrCode, qrCode) || other.qrCode == qrCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,secret,provisioningUri,qrCode);

@override
String toString() {
  return 'TOTPSetupResponse(secret: $secret, provisioningUri: $provisioningUri, qrCode: $qrCode)';
}


}

/// @nodoc
abstract mixin class $TOTPSetupResponseCopyWith<$Res>  {
  factory $TOTPSetupResponseCopyWith(TOTPSetupResponse value, $Res Function(TOTPSetupResponse) _then) = _$TOTPSetupResponseCopyWithImpl;
@useResult
$Res call({
 String secret, String provisioningUri, String qrCode
});




}
/// @nodoc
class _$TOTPSetupResponseCopyWithImpl<$Res>
    implements $TOTPSetupResponseCopyWith<$Res> {
  _$TOTPSetupResponseCopyWithImpl(this._self, this._then);

  final TOTPSetupResponse _self;
  final $Res Function(TOTPSetupResponse) _then;

/// Create a copy of TOTPSetupResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? secret = null,Object? provisioningUri = null,Object? qrCode = null,}) {
  return _then(_self.copyWith(
secret: null == secret ? _self.secret : secret // ignore: cast_nullable_to_non_nullable
as String,provisioningUri: null == provisioningUri ? _self.provisioningUri : provisioningUri // ignore: cast_nullable_to_non_nullable
as String,qrCode: null == qrCode ? _self.qrCode : qrCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TOTPSetupResponse].
extension TOTPSetupResponsePatterns on TOTPSetupResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TOTPSetupResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TOTPSetupResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TOTPSetupResponse value)  $default,){
final _that = this;
switch (_that) {
case _TOTPSetupResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TOTPSetupResponse value)?  $default,){
final _that = this;
switch (_that) {
case _TOTPSetupResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String secret,  String provisioningUri,  String qrCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TOTPSetupResponse() when $default != null:
return $default(_that.secret,_that.provisioningUri,_that.qrCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String secret,  String provisioningUri,  String qrCode)  $default,) {final _that = this;
switch (_that) {
case _TOTPSetupResponse():
return $default(_that.secret,_that.provisioningUri,_that.qrCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String secret,  String provisioningUri,  String qrCode)?  $default,) {final _that = this;
switch (_that) {
case _TOTPSetupResponse() when $default != null:
return $default(_that.secret,_that.provisioningUri,_that.qrCode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TOTPSetupResponse implements TOTPSetupResponse {
  const _TOTPSetupResponse({required this.secret, required this.provisioningUri, required this.qrCode});
  factory _TOTPSetupResponse.fromJson(Map<String, dynamic> json) => _$TOTPSetupResponseFromJson(json);

@override final  String secret;
@override final  String provisioningUri;
@override final  String qrCode;

/// Create a copy of TOTPSetupResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TOTPSetupResponseCopyWith<_TOTPSetupResponse> get copyWith => __$TOTPSetupResponseCopyWithImpl<_TOTPSetupResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TOTPSetupResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TOTPSetupResponse&&(identical(other.secret, secret) || other.secret == secret)&&(identical(other.provisioningUri, provisioningUri) || other.provisioningUri == provisioningUri)&&(identical(other.qrCode, qrCode) || other.qrCode == qrCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,secret,provisioningUri,qrCode);

@override
String toString() {
  return 'TOTPSetupResponse(secret: $secret, provisioningUri: $provisioningUri, qrCode: $qrCode)';
}


}

/// @nodoc
abstract mixin class _$TOTPSetupResponseCopyWith<$Res> implements $TOTPSetupResponseCopyWith<$Res> {
  factory _$TOTPSetupResponseCopyWith(_TOTPSetupResponse value, $Res Function(_TOTPSetupResponse) _then) = __$TOTPSetupResponseCopyWithImpl;
@override @useResult
$Res call({
 String secret, String provisioningUri, String qrCode
});




}
/// @nodoc
class __$TOTPSetupResponseCopyWithImpl<$Res>
    implements _$TOTPSetupResponseCopyWith<$Res> {
  __$TOTPSetupResponseCopyWithImpl(this._self, this._then);

  final _TOTPSetupResponse _self;
  final $Res Function(_TOTPSetupResponse) _then;

/// Create a copy of TOTPSetupResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? secret = null,Object? provisioningUri = null,Object? qrCode = null,}) {
  return _then(_TOTPSetupResponse(
secret: null == secret ? _self.secret : secret // ignore: cast_nullable_to_non_nullable
as String,provisioningUri: null == provisioningUri ? _self.provisioningUri : provisioningUri // ignore: cast_nullable_to_non_nullable
as String,qrCode: null == qrCode ? _self.qrCode : qrCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$TOTPChallengeInitResponse {

 bool get requireTotp; String get tempToken;
/// Create a copy of TOTPChallengeInitResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TOTPChallengeInitResponseCopyWith<TOTPChallengeInitResponse> get copyWith => _$TOTPChallengeInitResponseCopyWithImpl<TOTPChallengeInitResponse>(this as TOTPChallengeInitResponse, _$identity);

  /// Serializes this TOTPChallengeInitResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TOTPChallengeInitResponse&&(identical(other.requireTotp, requireTotp) || other.requireTotp == requireTotp)&&(identical(other.tempToken, tempToken) || other.tempToken == tempToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,requireTotp,tempToken);

@override
String toString() {
  return 'TOTPChallengeInitResponse(requireTotp: $requireTotp, tempToken: $tempToken)';
}


}

/// @nodoc
abstract mixin class $TOTPChallengeInitResponseCopyWith<$Res>  {
  factory $TOTPChallengeInitResponseCopyWith(TOTPChallengeInitResponse value, $Res Function(TOTPChallengeInitResponse) _then) = _$TOTPChallengeInitResponseCopyWithImpl;
@useResult
$Res call({
 bool requireTotp, String tempToken
});




}
/// @nodoc
class _$TOTPChallengeInitResponseCopyWithImpl<$Res>
    implements $TOTPChallengeInitResponseCopyWith<$Res> {
  _$TOTPChallengeInitResponseCopyWithImpl(this._self, this._then);

  final TOTPChallengeInitResponse _self;
  final $Res Function(TOTPChallengeInitResponse) _then;

/// Create a copy of TOTPChallengeInitResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? requireTotp = null,Object? tempToken = null,}) {
  return _then(_self.copyWith(
requireTotp: null == requireTotp ? _self.requireTotp : requireTotp // ignore: cast_nullable_to_non_nullable
as bool,tempToken: null == tempToken ? _self.tempToken : tempToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TOTPChallengeInitResponse].
extension TOTPChallengeInitResponsePatterns on TOTPChallengeInitResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TOTPChallengeInitResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TOTPChallengeInitResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TOTPChallengeInitResponse value)  $default,){
final _that = this;
switch (_that) {
case _TOTPChallengeInitResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TOTPChallengeInitResponse value)?  $default,){
final _that = this;
switch (_that) {
case _TOTPChallengeInitResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool requireTotp,  String tempToken)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TOTPChallengeInitResponse() when $default != null:
return $default(_that.requireTotp,_that.tempToken);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool requireTotp,  String tempToken)  $default,) {final _that = this;
switch (_that) {
case _TOTPChallengeInitResponse():
return $default(_that.requireTotp,_that.tempToken);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool requireTotp,  String tempToken)?  $default,) {final _that = this;
switch (_that) {
case _TOTPChallengeInitResponse() when $default != null:
return $default(_that.requireTotp,_that.tempToken);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TOTPChallengeInitResponse implements TOTPChallengeInitResponse {
  const _TOTPChallengeInitResponse({required this.requireTotp, required this.tempToken});
  factory _TOTPChallengeInitResponse.fromJson(Map<String, dynamic> json) => _$TOTPChallengeInitResponseFromJson(json);

@override final  bool requireTotp;
@override final  String tempToken;

/// Create a copy of TOTPChallengeInitResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TOTPChallengeInitResponseCopyWith<_TOTPChallengeInitResponse> get copyWith => __$TOTPChallengeInitResponseCopyWithImpl<_TOTPChallengeInitResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TOTPChallengeInitResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TOTPChallengeInitResponse&&(identical(other.requireTotp, requireTotp) || other.requireTotp == requireTotp)&&(identical(other.tempToken, tempToken) || other.tempToken == tempToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,requireTotp,tempToken);

@override
String toString() {
  return 'TOTPChallengeInitResponse(requireTotp: $requireTotp, tempToken: $tempToken)';
}


}

/// @nodoc
abstract mixin class _$TOTPChallengeInitResponseCopyWith<$Res> implements $TOTPChallengeInitResponseCopyWith<$Res> {
  factory _$TOTPChallengeInitResponseCopyWith(_TOTPChallengeInitResponse value, $Res Function(_TOTPChallengeInitResponse) _then) = __$TOTPChallengeInitResponseCopyWithImpl;
@override @useResult
$Res call({
 bool requireTotp, String tempToken
});




}
/// @nodoc
class __$TOTPChallengeInitResponseCopyWithImpl<$Res>
    implements _$TOTPChallengeInitResponseCopyWith<$Res> {
  __$TOTPChallengeInitResponseCopyWithImpl(this._self, this._then);

  final _TOTPChallengeInitResponse _self;
  final $Res Function(_TOTPChallengeInitResponse) _then;

/// Create a copy of TOTPChallengeInitResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? requireTotp = null,Object? tempToken = null,}) {
  return _then(_TOTPChallengeInitResponse(
requireTotp: null == requireTotp ? _self.requireTotp : requireTotp // ignore: cast_nullable_to_non_nullable
as bool,tempToken: null == tempToken ? _self.tempToken : tempToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$TOTPChallengeResponse {

 String get access; String get refresh; User get user; Profile get profile;
/// Create a copy of TOTPChallengeResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TOTPChallengeResponseCopyWith<TOTPChallengeResponse> get copyWith => _$TOTPChallengeResponseCopyWithImpl<TOTPChallengeResponse>(this as TOTPChallengeResponse, _$identity);

  /// Serializes this TOTPChallengeResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TOTPChallengeResponse&&(identical(other.access, access) || other.access == access)&&(identical(other.refresh, refresh) || other.refresh == refresh)&&(identical(other.user, user) || other.user == user)&&(identical(other.profile, profile) || other.profile == profile));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,access,refresh,user,profile);

@override
String toString() {
  return 'TOTPChallengeResponse(access: $access, refresh: $refresh, user: $user, profile: $profile)';
}


}

/// @nodoc
abstract mixin class $TOTPChallengeResponseCopyWith<$Res>  {
  factory $TOTPChallengeResponseCopyWith(TOTPChallengeResponse value, $Res Function(TOTPChallengeResponse) _then) = _$TOTPChallengeResponseCopyWithImpl;
@useResult
$Res call({
 String access, String refresh, User user, Profile profile
});


$UserCopyWith<$Res> get user;$ProfileCopyWith<$Res> get profile;

}
/// @nodoc
class _$TOTPChallengeResponseCopyWithImpl<$Res>
    implements $TOTPChallengeResponseCopyWith<$Res> {
  _$TOTPChallengeResponseCopyWithImpl(this._self, this._then);

  final TOTPChallengeResponse _self;
  final $Res Function(TOTPChallengeResponse) _then;

/// Create a copy of TOTPChallengeResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? access = null,Object? refresh = null,Object? user = null,Object? profile = null,}) {
  return _then(_self.copyWith(
access: null == access ? _self.access : access // ignore: cast_nullable_to_non_nullable
as String,refresh: null == refresh ? _self.refresh : refresh // ignore: cast_nullable_to_non_nullable
as String,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as Profile,
  ));
}
/// Create a copy of TOTPChallengeResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res> get user {
  
  return $UserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of TOTPChallengeResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileCopyWith<$Res> get profile {
  
  return $ProfileCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// Adds pattern-matching-related methods to [TOTPChallengeResponse].
extension TOTPChallengeResponsePatterns on TOTPChallengeResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TOTPChallengeResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TOTPChallengeResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TOTPChallengeResponse value)  $default,){
final _that = this;
switch (_that) {
case _TOTPChallengeResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TOTPChallengeResponse value)?  $default,){
final _that = this;
switch (_that) {
case _TOTPChallengeResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String access,  String refresh,  User user,  Profile profile)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TOTPChallengeResponse() when $default != null:
return $default(_that.access,_that.refresh,_that.user,_that.profile);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String access,  String refresh,  User user,  Profile profile)  $default,) {final _that = this;
switch (_that) {
case _TOTPChallengeResponse():
return $default(_that.access,_that.refresh,_that.user,_that.profile);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String access,  String refresh,  User user,  Profile profile)?  $default,) {final _that = this;
switch (_that) {
case _TOTPChallengeResponse() when $default != null:
return $default(_that.access,_that.refresh,_that.user,_that.profile);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TOTPChallengeResponse implements TOTPChallengeResponse {
  const _TOTPChallengeResponse({required this.access, required this.refresh, required this.user, required this.profile});
  factory _TOTPChallengeResponse.fromJson(Map<String, dynamic> json) => _$TOTPChallengeResponseFromJson(json);

@override final  String access;
@override final  String refresh;
@override final  User user;
@override final  Profile profile;

/// Create a copy of TOTPChallengeResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TOTPChallengeResponseCopyWith<_TOTPChallengeResponse> get copyWith => __$TOTPChallengeResponseCopyWithImpl<_TOTPChallengeResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TOTPChallengeResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TOTPChallengeResponse&&(identical(other.access, access) || other.access == access)&&(identical(other.refresh, refresh) || other.refresh == refresh)&&(identical(other.user, user) || other.user == user)&&(identical(other.profile, profile) || other.profile == profile));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,access,refresh,user,profile);

@override
String toString() {
  return 'TOTPChallengeResponse(access: $access, refresh: $refresh, user: $user, profile: $profile)';
}


}

/// @nodoc
abstract mixin class _$TOTPChallengeResponseCopyWith<$Res> implements $TOTPChallengeResponseCopyWith<$Res> {
  factory _$TOTPChallengeResponseCopyWith(_TOTPChallengeResponse value, $Res Function(_TOTPChallengeResponse) _then) = __$TOTPChallengeResponseCopyWithImpl;
@override @useResult
$Res call({
 String access, String refresh, User user, Profile profile
});


@override $UserCopyWith<$Res> get user;@override $ProfileCopyWith<$Res> get profile;

}
/// @nodoc
class __$TOTPChallengeResponseCopyWithImpl<$Res>
    implements _$TOTPChallengeResponseCopyWith<$Res> {
  __$TOTPChallengeResponseCopyWithImpl(this._self, this._then);

  final _TOTPChallengeResponse _self;
  final $Res Function(_TOTPChallengeResponse) _then;

/// Create a copy of TOTPChallengeResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? access = null,Object? refresh = null,Object? user = null,Object? profile = null,}) {
  return _then(_TOTPChallengeResponse(
access: null == access ? _self.access : access // ignore: cast_nullable_to_non_nullable
as String,refresh: null == refresh ? _self.refresh : refresh // ignore: cast_nullable_to_non_nullable
as String,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as Profile,
  ));
}

/// Create a copy of TOTPChallengeResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res> get user {
  
  return $UserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of TOTPChallengeResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileCopyWith<$Res> get profile {
  
  return $ProfileCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// @nodoc
mixin _$OTPSerializer {

 String get otp; String? get channel;
/// Create a copy of OTPSerializer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OTPSerializerCopyWith<OTPSerializer> get copyWith => _$OTPSerializerCopyWithImpl<OTPSerializer>(this as OTPSerializer, _$identity);

  /// Serializes this OTPSerializer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OTPSerializer&&(identical(other.otp, otp) || other.otp == otp)&&(identical(other.channel, channel) || other.channel == channel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,otp,channel);

@override
String toString() {
  return 'OTPSerializer(otp: $otp, channel: $channel)';
}


}

/// @nodoc
abstract mixin class $OTPSerializerCopyWith<$Res>  {
  factory $OTPSerializerCopyWith(OTPSerializer value, $Res Function(OTPSerializer) _then) = _$OTPSerializerCopyWithImpl;
@useResult
$Res call({
 String otp, String? channel
});




}
/// @nodoc
class _$OTPSerializerCopyWithImpl<$Res>
    implements $OTPSerializerCopyWith<$Res> {
  _$OTPSerializerCopyWithImpl(this._self, this._then);

  final OTPSerializer _self;
  final $Res Function(OTPSerializer) _then;

/// Create a copy of OTPSerializer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? otp = null,Object? channel = freezed,}) {
  return _then(_self.copyWith(
otp: null == otp ? _self.otp : otp // ignore: cast_nullable_to_non_nullable
as String,channel: freezed == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OTPSerializer].
extension OTPSerializerPatterns on OTPSerializer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OTPSerializer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OTPSerializer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OTPSerializer value)  $default,){
final _that = this;
switch (_that) {
case _OTPSerializer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OTPSerializer value)?  $default,){
final _that = this;
switch (_that) {
case _OTPSerializer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String otp,  String? channel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OTPSerializer() when $default != null:
return $default(_that.otp,_that.channel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String otp,  String? channel)  $default,) {final _that = this;
switch (_that) {
case _OTPSerializer():
return $default(_that.otp,_that.channel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String otp,  String? channel)?  $default,) {final _that = this;
switch (_that) {
case _OTPSerializer() when $default != null:
return $default(_that.otp,_that.channel);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OTPSerializer implements OTPSerializer {
  const _OTPSerializer({required this.otp, this.channel});
  factory _OTPSerializer.fromJson(Map<String, dynamic> json) => _$OTPSerializerFromJson(json);

@override final  String otp;
@override final  String? channel;

/// Create a copy of OTPSerializer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OTPSerializerCopyWith<_OTPSerializer> get copyWith => __$OTPSerializerCopyWithImpl<_OTPSerializer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OTPSerializerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OTPSerializer&&(identical(other.otp, otp) || other.otp == otp)&&(identical(other.channel, channel) || other.channel == channel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,otp,channel);

@override
String toString() {
  return 'OTPSerializer(otp: $otp, channel: $channel)';
}


}

/// @nodoc
abstract mixin class _$OTPSerializerCopyWith<$Res> implements $OTPSerializerCopyWith<$Res> {
  factory _$OTPSerializerCopyWith(_OTPSerializer value, $Res Function(_OTPSerializer) _then) = __$OTPSerializerCopyWithImpl;
@override @useResult
$Res call({
 String otp, String? channel
});




}
/// @nodoc
class __$OTPSerializerCopyWithImpl<$Res>
    implements _$OTPSerializerCopyWith<$Res> {
  __$OTPSerializerCopyWithImpl(this._self, this._then);

  final _OTPSerializer _self;
  final $Res Function(_OTPSerializer) _then;

/// Create a copy of OTPSerializer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? otp = null,Object? channel = freezed,}) {
  return _then(_OTPSerializer(
otp: null == otp ? _self.otp : otp // ignore: cast_nullable_to_non_nullable
as String,channel: freezed == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$RegistrationOTPSerializer {

 String get registrationToken; String get otp;
/// Create a copy of RegistrationOTPSerializer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegistrationOTPSerializerCopyWith<RegistrationOTPSerializer> get copyWith => _$RegistrationOTPSerializerCopyWithImpl<RegistrationOTPSerializer>(this as RegistrationOTPSerializer, _$identity);

  /// Serializes this RegistrationOTPSerializer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegistrationOTPSerializer&&(identical(other.registrationToken, registrationToken) || other.registrationToken == registrationToken)&&(identical(other.otp, otp) || other.otp == otp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,registrationToken,otp);

@override
String toString() {
  return 'RegistrationOTPSerializer(registrationToken: $registrationToken, otp: $otp)';
}


}

/// @nodoc
abstract mixin class $RegistrationOTPSerializerCopyWith<$Res>  {
  factory $RegistrationOTPSerializerCopyWith(RegistrationOTPSerializer value, $Res Function(RegistrationOTPSerializer) _then) = _$RegistrationOTPSerializerCopyWithImpl;
@useResult
$Res call({
 String registrationToken, String otp
});




}
/// @nodoc
class _$RegistrationOTPSerializerCopyWithImpl<$Res>
    implements $RegistrationOTPSerializerCopyWith<$Res> {
  _$RegistrationOTPSerializerCopyWithImpl(this._self, this._then);

  final RegistrationOTPSerializer _self;
  final $Res Function(RegistrationOTPSerializer) _then;

/// Create a copy of RegistrationOTPSerializer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? registrationToken = null,Object? otp = null,}) {
  return _then(_self.copyWith(
registrationToken: null == registrationToken ? _self.registrationToken : registrationToken // ignore: cast_nullable_to_non_nullable
as String,otp: null == otp ? _self.otp : otp // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RegistrationOTPSerializer].
extension RegistrationOTPSerializerPatterns on RegistrationOTPSerializer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegistrationOTPSerializer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegistrationOTPSerializer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegistrationOTPSerializer value)  $default,){
final _that = this;
switch (_that) {
case _RegistrationOTPSerializer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegistrationOTPSerializer value)?  $default,){
final _that = this;
switch (_that) {
case _RegistrationOTPSerializer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String registrationToken,  String otp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegistrationOTPSerializer() when $default != null:
return $default(_that.registrationToken,_that.otp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String registrationToken,  String otp)  $default,) {final _that = this;
switch (_that) {
case _RegistrationOTPSerializer():
return $default(_that.registrationToken,_that.otp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String registrationToken,  String otp)?  $default,) {final _that = this;
switch (_that) {
case _RegistrationOTPSerializer() when $default != null:
return $default(_that.registrationToken,_that.otp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RegistrationOTPSerializer implements RegistrationOTPSerializer {
  const _RegistrationOTPSerializer({required this.registrationToken, required this.otp});
  factory _RegistrationOTPSerializer.fromJson(Map<String, dynamic> json) => _$RegistrationOTPSerializerFromJson(json);

@override final  String registrationToken;
@override final  String otp;

/// Create a copy of RegistrationOTPSerializer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegistrationOTPSerializerCopyWith<_RegistrationOTPSerializer> get copyWith => __$RegistrationOTPSerializerCopyWithImpl<_RegistrationOTPSerializer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RegistrationOTPSerializerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegistrationOTPSerializer&&(identical(other.registrationToken, registrationToken) || other.registrationToken == registrationToken)&&(identical(other.otp, otp) || other.otp == otp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,registrationToken,otp);

@override
String toString() {
  return 'RegistrationOTPSerializer(registrationToken: $registrationToken, otp: $otp)';
}


}

/// @nodoc
abstract mixin class _$RegistrationOTPSerializerCopyWith<$Res> implements $RegistrationOTPSerializerCopyWith<$Res> {
  factory _$RegistrationOTPSerializerCopyWith(_RegistrationOTPSerializer value, $Res Function(_RegistrationOTPSerializer) _then) = __$RegistrationOTPSerializerCopyWithImpl;
@override @useResult
$Res call({
 String registrationToken, String otp
});




}
/// @nodoc
class __$RegistrationOTPSerializerCopyWithImpl<$Res>
    implements _$RegistrationOTPSerializerCopyWith<$Res> {
  __$RegistrationOTPSerializerCopyWithImpl(this._self, this._then);

  final _RegistrationOTPSerializer _self;
  final $Res Function(_RegistrationOTPSerializer) _then;

/// Create a copy of RegistrationOTPSerializer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? registrationToken = null,Object? otp = null,}) {
  return _then(_RegistrationOTPSerializer(
registrationToken: null == registrationToken ? _self.registrationToken : registrationToken // ignore: cast_nullable_to_non_nullable
as String,otp: null == otp ? _self.otp : otp // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$LoginOTPSerializer {

 String get loginToken; String get otp; bool get rememberMe;
/// Create a copy of LoginOTPSerializer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginOTPSerializerCopyWith<LoginOTPSerializer> get copyWith => _$LoginOTPSerializerCopyWithImpl<LoginOTPSerializer>(this as LoginOTPSerializer, _$identity);

  /// Serializes this LoginOTPSerializer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginOTPSerializer&&(identical(other.loginToken, loginToken) || other.loginToken == loginToken)&&(identical(other.otp, otp) || other.otp == otp)&&(identical(other.rememberMe, rememberMe) || other.rememberMe == rememberMe));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,loginToken,otp,rememberMe);

@override
String toString() {
  return 'LoginOTPSerializer(loginToken: $loginToken, otp: $otp, rememberMe: $rememberMe)';
}


}

/// @nodoc
abstract mixin class $LoginOTPSerializerCopyWith<$Res>  {
  factory $LoginOTPSerializerCopyWith(LoginOTPSerializer value, $Res Function(LoginOTPSerializer) _then) = _$LoginOTPSerializerCopyWithImpl;
@useResult
$Res call({
 String loginToken, String otp, bool rememberMe
});




}
/// @nodoc
class _$LoginOTPSerializerCopyWithImpl<$Res>
    implements $LoginOTPSerializerCopyWith<$Res> {
  _$LoginOTPSerializerCopyWithImpl(this._self, this._then);

  final LoginOTPSerializer _self;
  final $Res Function(LoginOTPSerializer) _then;

/// Create a copy of LoginOTPSerializer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? loginToken = null,Object? otp = null,Object? rememberMe = null,}) {
  return _then(_self.copyWith(
loginToken: null == loginToken ? _self.loginToken : loginToken // ignore: cast_nullable_to_non_nullable
as String,otp: null == otp ? _self.otp : otp // ignore: cast_nullable_to_non_nullable
as String,rememberMe: null == rememberMe ? _self.rememberMe : rememberMe // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LoginOTPSerializer].
extension LoginOTPSerializerPatterns on LoginOTPSerializer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginOTPSerializer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginOTPSerializer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginOTPSerializer value)  $default,){
final _that = this;
switch (_that) {
case _LoginOTPSerializer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginOTPSerializer value)?  $default,){
final _that = this;
switch (_that) {
case _LoginOTPSerializer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String loginToken,  String otp,  bool rememberMe)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginOTPSerializer() when $default != null:
return $default(_that.loginToken,_that.otp,_that.rememberMe);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String loginToken,  String otp,  bool rememberMe)  $default,) {final _that = this;
switch (_that) {
case _LoginOTPSerializer():
return $default(_that.loginToken,_that.otp,_that.rememberMe);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String loginToken,  String otp,  bool rememberMe)?  $default,) {final _that = this;
switch (_that) {
case _LoginOTPSerializer() when $default != null:
return $default(_that.loginToken,_that.otp,_that.rememberMe);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LoginOTPSerializer implements LoginOTPSerializer {
  const _LoginOTPSerializer({required this.loginToken, required this.otp, this.rememberMe = false});
  factory _LoginOTPSerializer.fromJson(Map<String, dynamic> json) => _$LoginOTPSerializerFromJson(json);

@override final  String loginToken;
@override final  String otp;
@override@JsonKey() final  bool rememberMe;

/// Create a copy of LoginOTPSerializer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginOTPSerializerCopyWith<_LoginOTPSerializer> get copyWith => __$LoginOTPSerializerCopyWithImpl<_LoginOTPSerializer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoginOTPSerializerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginOTPSerializer&&(identical(other.loginToken, loginToken) || other.loginToken == loginToken)&&(identical(other.otp, otp) || other.otp == otp)&&(identical(other.rememberMe, rememberMe) || other.rememberMe == rememberMe));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,loginToken,otp,rememberMe);

@override
String toString() {
  return 'LoginOTPSerializer(loginToken: $loginToken, otp: $otp, rememberMe: $rememberMe)';
}


}

/// @nodoc
abstract mixin class _$LoginOTPSerializerCopyWith<$Res> implements $LoginOTPSerializerCopyWith<$Res> {
  factory _$LoginOTPSerializerCopyWith(_LoginOTPSerializer value, $Res Function(_LoginOTPSerializer) _then) = __$LoginOTPSerializerCopyWithImpl;
@override @useResult
$Res call({
 String loginToken, String otp, bool rememberMe
});




}
/// @nodoc
class __$LoginOTPSerializerCopyWithImpl<$Res>
    implements _$LoginOTPSerializerCopyWith<$Res> {
  __$LoginOTPSerializerCopyWithImpl(this._self, this._then);

  final _LoginOTPSerializer _self;
  final $Res Function(_LoginOTPSerializer) _then;

/// Create a copy of LoginOTPSerializer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? loginToken = null,Object? otp = null,Object? rememberMe = null,}) {
  return _then(_LoginOTPSerializer(
loginToken: null == loginToken ? _self.loginToken : loginToken // ignore: cast_nullable_to_non_nullable
as String,otp: null == otp ? _self.otp : otp // ignore: cast_nullable_to_non_nullable
as String,rememberMe: null == rememberMe ? _self.rememberMe : rememberMe // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$PasswordResetRequest {

 String get email;
/// Create a copy of PasswordResetRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PasswordResetRequestCopyWith<PasswordResetRequest> get copyWith => _$PasswordResetRequestCopyWithImpl<PasswordResetRequest>(this as PasswordResetRequest, _$identity);

  /// Serializes this PasswordResetRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordResetRequest&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email);

@override
String toString() {
  return 'PasswordResetRequest(email: $email)';
}


}

/// @nodoc
abstract mixin class $PasswordResetRequestCopyWith<$Res>  {
  factory $PasswordResetRequestCopyWith(PasswordResetRequest value, $Res Function(PasswordResetRequest) _then) = _$PasswordResetRequestCopyWithImpl;
@useResult
$Res call({
 String email
});




}
/// @nodoc
class _$PasswordResetRequestCopyWithImpl<$Res>
    implements $PasswordResetRequestCopyWith<$Res> {
  _$PasswordResetRequestCopyWithImpl(this._self, this._then);

  final PasswordResetRequest _self;
  final $Res Function(PasswordResetRequest) _then;

/// Create a copy of PasswordResetRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,}) {
  return _then(_self.copyWith(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PasswordResetRequest].
extension PasswordResetRequestPatterns on PasswordResetRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PasswordResetRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PasswordResetRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PasswordResetRequest value)  $default,){
final _that = this;
switch (_that) {
case _PasswordResetRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PasswordResetRequest value)?  $default,){
final _that = this;
switch (_that) {
case _PasswordResetRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PasswordResetRequest() when $default != null:
return $default(_that.email);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email)  $default,) {final _that = this;
switch (_that) {
case _PasswordResetRequest():
return $default(_that.email);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email)?  $default,) {final _that = this;
switch (_that) {
case _PasswordResetRequest() when $default != null:
return $default(_that.email);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PasswordResetRequest implements PasswordResetRequest {
  const _PasswordResetRequest({required this.email});
  factory _PasswordResetRequest.fromJson(Map<String, dynamic> json) => _$PasswordResetRequestFromJson(json);

@override final  String email;

/// Create a copy of PasswordResetRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PasswordResetRequestCopyWith<_PasswordResetRequest> get copyWith => __$PasswordResetRequestCopyWithImpl<_PasswordResetRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PasswordResetRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PasswordResetRequest&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email);

@override
String toString() {
  return 'PasswordResetRequest(email: $email)';
}


}

/// @nodoc
abstract mixin class _$PasswordResetRequestCopyWith<$Res> implements $PasswordResetRequestCopyWith<$Res> {
  factory _$PasswordResetRequestCopyWith(_PasswordResetRequest value, $Res Function(_PasswordResetRequest) _then) = __$PasswordResetRequestCopyWithImpl;
@override @useResult
$Res call({
 String email
});




}
/// @nodoc
class __$PasswordResetRequestCopyWithImpl<$Res>
    implements _$PasswordResetRequestCopyWith<$Res> {
  __$PasswordResetRequestCopyWithImpl(this._self, this._then);

  final _PasswordResetRequest _self;
  final $Res Function(_PasswordResetRequest) _then;

/// Create a copy of PasswordResetRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,}) {
  return _then(_PasswordResetRequest(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PasswordResetConfirm {

 String get token; String get newPassword;
/// Create a copy of PasswordResetConfirm
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PasswordResetConfirmCopyWith<PasswordResetConfirm> get copyWith => _$PasswordResetConfirmCopyWithImpl<PasswordResetConfirm>(this as PasswordResetConfirm, _$identity);

  /// Serializes this PasswordResetConfirm to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordResetConfirm&&(identical(other.token, token) || other.token == token)&&(identical(other.newPassword, newPassword) || other.newPassword == newPassword));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,token,newPassword);

@override
String toString() {
  return 'PasswordResetConfirm(token: $token, newPassword: $newPassword)';
}


}

/// @nodoc
abstract mixin class $PasswordResetConfirmCopyWith<$Res>  {
  factory $PasswordResetConfirmCopyWith(PasswordResetConfirm value, $Res Function(PasswordResetConfirm) _then) = _$PasswordResetConfirmCopyWithImpl;
@useResult
$Res call({
 String token, String newPassword
});




}
/// @nodoc
class _$PasswordResetConfirmCopyWithImpl<$Res>
    implements $PasswordResetConfirmCopyWith<$Res> {
  _$PasswordResetConfirmCopyWithImpl(this._self, this._then);

  final PasswordResetConfirm _self;
  final $Res Function(PasswordResetConfirm) _then;

/// Create a copy of PasswordResetConfirm
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = null,Object? newPassword = null,}) {
  return _then(_self.copyWith(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PasswordResetConfirm].
extension PasswordResetConfirmPatterns on PasswordResetConfirm {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PasswordResetConfirm value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PasswordResetConfirm() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PasswordResetConfirm value)  $default,){
final _that = this;
switch (_that) {
case _PasswordResetConfirm():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PasswordResetConfirm value)?  $default,){
final _that = this;
switch (_that) {
case _PasswordResetConfirm() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String token,  String newPassword)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PasswordResetConfirm() when $default != null:
return $default(_that.token,_that.newPassword);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String token,  String newPassword)  $default,) {final _that = this;
switch (_that) {
case _PasswordResetConfirm():
return $default(_that.token,_that.newPassword);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String token,  String newPassword)?  $default,) {final _that = this;
switch (_that) {
case _PasswordResetConfirm() when $default != null:
return $default(_that.token,_that.newPassword);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PasswordResetConfirm implements PasswordResetConfirm {
  const _PasswordResetConfirm({required this.token, required this.newPassword});
  factory _PasswordResetConfirm.fromJson(Map<String, dynamic> json) => _$PasswordResetConfirmFromJson(json);

@override final  String token;
@override final  String newPassword;

/// Create a copy of PasswordResetConfirm
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PasswordResetConfirmCopyWith<_PasswordResetConfirm> get copyWith => __$PasswordResetConfirmCopyWithImpl<_PasswordResetConfirm>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PasswordResetConfirmToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PasswordResetConfirm&&(identical(other.token, token) || other.token == token)&&(identical(other.newPassword, newPassword) || other.newPassword == newPassword));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,token,newPassword);

@override
String toString() {
  return 'PasswordResetConfirm(token: $token, newPassword: $newPassword)';
}


}

/// @nodoc
abstract mixin class _$PasswordResetConfirmCopyWith<$Res> implements $PasswordResetConfirmCopyWith<$Res> {
  factory _$PasswordResetConfirmCopyWith(_PasswordResetConfirm value, $Res Function(_PasswordResetConfirm) _then) = __$PasswordResetConfirmCopyWithImpl;
@override @useResult
$Res call({
 String token, String newPassword
});




}
/// @nodoc
class __$PasswordResetConfirmCopyWithImpl<$Res>
    implements _$PasswordResetConfirmCopyWith<$Res> {
  __$PasswordResetConfirmCopyWithImpl(this._self, this._then);

  final _PasswordResetConfirm _self;
  final $Res Function(_PasswordResetConfirm) _then;

/// Create a copy of PasswordResetConfirm
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = null,Object? newPassword = null,}) {
  return _then(_PasswordResetConfirm(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ChangePasswordPayload {

 String get currentPassword; String get newPassword;
/// Create a copy of ChangePasswordPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangePasswordPayloadCopyWith<ChangePasswordPayload> get copyWith => _$ChangePasswordPayloadCopyWithImpl<ChangePasswordPayload>(this as ChangePasswordPayload, _$identity);

  /// Serializes this ChangePasswordPayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangePasswordPayload&&(identical(other.currentPassword, currentPassword) || other.currentPassword == currentPassword)&&(identical(other.newPassword, newPassword) || other.newPassword == newPassword));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentPassword,newPassword);

@override
String toString() {
  return 'ChangePasswordPayload(currentPassword: $currentPassword, newPassword: $newPassword)';
}


}

/// @nodoc
abstract mixin class $ChangePasswordPayloadCopyWith<$Res>  {
  factory $ChangePasswordPayloadCopyWith(ChangePasswordPayload value, $Res Function(ChangePasswordPayload) _then) = _$ChangePasswordPayloadCopyWithImpl;
@useResult
$Res call({
 String currentPassword, String newPassword
});




}
/// @nodoc
class _$ChangePasswordPayloadCopyWithImpl<$Res>
    implements $ChangePasswordPayloadCopyWith<$Res> {
  _$ChangePasswordPayloadCopyWithImpl(this._self, this._then);

  final ChangePasswordPayload _self;
  final $Res Function(ChangePasswordPayload) _then;

/// Create a copy of ChangePasswordPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentPassword = null,Object? newPassword = null,}) {
  return _then(_self.copyWith(
currentPassword: null == currentPassword ? _self.currentPassword : currentPassword // ignore: cast_nullable_to_non_nullable
as String,newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ChangePasswordPayload].
extension ChangePasswordPayloadPatterns on ChangePasswordPayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChangePasswordPayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChangePasswordPayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChangePasswordPayload value)  $default,){
final _that = this;
switch (_that) {
case _ChangePasswordPayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChangePasswordPayload value)?  $default,){
final _that = this;
switch (_that) {
case _ChangePasswordPayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String currentPassword,  String newPassword)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChangePasswordPayload() when $default != null:
return $default(_that.currentPassword,_that.newPassword);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String currentPassword,  String newPassword)  $default,) {final _that = this;
switch (_that) {
case _ChangePasswordPayload():
return $default(_that.currentPassword,_that.newPassword);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String currentPassword,  String newPassword)?  $default,) {final _that = this;
switch (_that) {
case _ChangePasswordPayload() when $default != null:
return $default(_that.currentPassword,_that.newPassword);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChangePasswordPayload implements ChangePasswordPayload {
  const _ChangePasswordPayload({required this.currentPassword, required this.newPassword});
  factory _ChangePasswordPayload.fromJson(Map<String, dynamic> json) => _$ChangePasswordPayloadFromJson(json);

@override final  String currentPassword;
@override final  String newPassword;

/// Create a copy of ChangePasswordPayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChangePasswordPayloadCopyWith<_ChangePasswordPayload> get copyWith => __$ChangePasswordPayloadCopyWithImpl<_ChangePasswordPayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChangePasswordPayloadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChangePasswordPayload&&(identical(other.currentPassword, currentPassword) || other.currentPassword == currentPassword)&&(identical(other.newPassword, newPassword) || other.newPassword == newPassword));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentPassword,newPassword);

@override
String toString() {
  return 'ChangePasswordPayload(currentPassword: $currentPassword, newPassword: $newPassword)';
}


}

/// @nodoc
abstract mixin class _$ChangePasswordPayloadCopyWith<$Res> implements $ChangePasswordPayloadCopyWith<$Res> {
  factory _$ChangePasswordPayloadCopyWith(_ChangePasswordPayload value, $Res Function(_ChangePasswordPayload) _then) = __$ChangePasswordPayloadCopyWithImpl;
@override @useResult
$Res call({
 String currentPassword, String newPassword
});




}
/// @nodoc
class __$ChangePasswordPayloadCopyWithImpl<$Res>
    implements _$ChangePasswordPayloadCopyWith<$Res> {
  __$ChangePasswordPayloadCopyWithImpl(this._self, this._then);

  final _ChangePasswordPayload _self;
  final $Res Function(_ChangePasswordPayload) _then;

/// Create a copy of ChangePasswordPayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentPassword = null,Object? newPassword = null,}) {
  return _then(_ChangePasswordPayload(
currentPassword: null == currentPassword ? _self.currentPassword : currentPassword // ignore: cast_nullable_to_non_nullable
as String,newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
