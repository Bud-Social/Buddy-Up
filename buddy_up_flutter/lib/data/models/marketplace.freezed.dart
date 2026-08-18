// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'marketplace.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreatorData {

 String get username; String get displayName;@JsonKey(name: 'avatar_url') String get avatarUrl;@JsonKey(name: 'verification_status') String get verificationStatus;
/// Create a copy of CreatorData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreatorDataCopyWith<CreatorData> get copyWith => _$CreatorDataCopyWithImpl<CreatorData>(this as CreatorData, _$identity);

  /// Serializes this CreatorData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreatorData&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username,displayName,avatarUrl,verificationStatus);

@override
String toString() {
  return 'CreatorData(username: $username, displayName: $displayName, avatarUrl: $avatarUrl, verificationStatus: $verificationStatus)';
}


}

/// @nodoc
abstract mixin class $CreatorDataCopyWith<$Res>  {
  factory $CreatorDataCopyWith(CreatorData value, $Res Function(CreatorData) _then) = _$CreatorDataCopyWithImpl;
@useResult
$Res call({
 String username, String displayName,@JsonKey(name: 'avatar_url') String avatarUrl,@JsonKey(name: 'verification_status') String verificationStatus
});




}
/// @nodoc
class _$CreatorDataCopyWithImpl<$Res>
    implements $CreatorDataCopyWith<$Res> {
  _$CreatorDataCopyWithImpl(this._self, this._then);

  final CreatorData _self;
  final $Res Function(CreatorData) _then;

/// Create a copy of CreatorData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? username = null,Object? displayName = null,Object? avatarUrl = null,Object? verificationStatus = null,}) {
  return _then(_self.copyWith(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CreatorData].
extension CreatorDataPatterns on CreatorData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreatorData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreatorData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreatorData value)  $default,){
final _that = this;
switch (_that) {
case _CreatorData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreatorData value)?  $default,){
final _that = this;
switch (_that) {
case _CreatorData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String username,  String displayName, @JsonKey(name: 'avatar_url')  String avatarUrl, @JsonKey(name: 'verification_status')  String verificationStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreatorData() when $default != null:
return $default(_that.username,_that.displayName,_that.avatarUrl,_that.verificationStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String username,  String displayName, @JsonKey(name: 'avatar_url')  String avatarUrl, @JsonKey(name: 'verification_status')  String verificationStatus)  $default,) {final _that = this;
switch (_that) {
case _CreatorData():
return $default(_that.username,_that.displayName,_that.avatarUrl,_that.verificationStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String username,  String displayName, @JsonKey(name: 'avatar_url')  String avatarUrl, @JsonKey(name: 'verification_status')  String verificationStatus)?  $default,) {final _that = this;
switch (_that) {
case _CreatorData() when $default != null:
return $default(_that.username,_that.displayName,_that.avatarUrl,_that.verificationStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreatorData implements CreatorData {
  const _CreatorData({required this.username, required this.displayName, @JsonKey(name: 'avatar_url') required this.avatarUrl, @JsonKey(name: 'verification_status') this.verificationStatus = ''});
  factory _CreatorData.fromJson(Map<String, dynamic> json) => _$CreatorDataFromJson(json);

@override final  String username;
@override final  String displayName;
@override@JsonKey(name: 'avatar_url') final  String avatarUrl;
@override@JsonKey(name: 'verification_status') final  String verificationStatus;

/// Create a copy of CreatorData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreatorDataCopyWith<_CreatorData> get copyWith => __$CreatorDataCopyWithImpl<_CreatorData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreatorDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreatorData&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username,displayName,avatarUrl,verificationStatus);

@override
String toString() {
  return 'CreatorData(username: $username, displayName: $displayName, avatarUrl: $avatarUrl, verificationStatus: $verificationStatus)';
}


}

/// @nodoc
abstract mixin class _$CreatorDataCopyWith<$Res> implements $CreatorDataCopyWith<$Res> {
  factory _$CreatorDataCopyWith(_CreatorData value, $Res Function(_CreatorData) _then) = __$CreatorDataCopyWithImpl;
@override @useResult
$Res call({
 String username, String displayName,@JsonKey(name: 'avatar_url') String avatarUrl,@JsonKey(name: 'verification_status') String verificationStatus
});




}
/// @nodoc
class __$CreatorDataCopyWithImpl<$Res>
    implements _$CreatorDataCopyWith<$Res> {
  __$CreatorDataCopyWithImpl(this._self, this._then);

  final _CreatorData _self;
  final $Res Function(_CreatorData) _then;

/// Create a copy of CreatorData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? username = null,Object? displayName = null,Object? avatarUrl = null,Object? verificationStatus = null,}) {
  return _then(_CreatorData(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Shop {

 String get id; String get handle; String get name; String get description;@JsonKey(name: 'logo_url') String? get logoUrl;@JsonKey(name: 'banner_url') String? get bannerUrl;@JsonKey(name: 'accent_color') String get accentColor;@JsonKey(name: 'contact_email') String get contactEmail;@JsonKey(name: 'contact_phone') String get contactPhone;@JsonKey(name: 'website_url') String get websiteUrl;@JsonKey(name: 'social_links') Map<String, String> get socialLinks; String get category;@JsonKey(name: 'verification_status') String get verificationStatus;@JsonKey(name: 'is_active') bool get isActive;@JsonKey(name: 'created_at') String get createdAt;
/// Create a copy of Shop
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShopCopyWith<Shop> get copyWith => _$ShopCopyWithImpl<Shop>(this as Shop, _$identity);

  /// Serializes this Shop to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Shop&&(identical(other.id, id) || other.id == id)&&(identical(other.handle, handle) || other.handle == handle)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.bannerUrl, bannerUrl) || other.bannerUrl == bannerUrl)&&(identical(other.accentColor, accentColor) || other.accentColor == accentColor)&&(identical(other.contactEmail, contactEmail) || other.contactEmail == contactEmail)&&(identical(other.contactPhone, contactPhone) || other.contactPhone == contactPhone)&&(identical(other.websiteUrl, websiteUrl) || other.websiteUrl == websiteUrl)&&const DeepCollectionEquality().equals(other.socialLinks, socialLinks)&&(identical(other.category, category) || other.category == category)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,handle,name,description,logoUrl,bannerUrl,accentColor,contactEmail,contactPhone,websiteUrl,const DeepCollectionEquality().hash(socialLinks),category,verificationStatus,isActive,createdAt);

@override
String toString() {
  return 'Shop(id: $id, handle: $handle, name: $name, description: $description, logoUrl: $logoUrl, bannerUrl: $bannerUrl, accentColor: $accentColor, contactEmail: $contactEmail, contactPhone: $contactPhone, websiteUrl: $websiteUrl, socialLinks: $socialLinks, category: $category, verificationStatus: $verificationStatus, isActive: $isActive, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ShopCopyWith<$Res>  {
  factory $ShopCopyWith(Shop value, $Res Function(Shop) _then) = _$ShopCopyWithImpl;
@useResult
$Res call({
 String id, String handle, String name, String description,@JsonKey(name: 'logo_url') String? logoUrl,@JsonKey(name: 'banner_url') String? bannerUrl,@JsonKey(name: 'accent_color') String accentColor,@JsonKey(name: 'contact_email') String contactEmail,@JsonKey(name: 'contact_phone') String contactPhone,@JsonKey(name: 'website_url') String websiteUrl,@JsonKey(name: 'social_links') Map<String, String> socialLinks, String category,@JsonKey(name: 'verification_status') String verificationStatus,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'created_at') String createdAt
});




}
/// @nodoc
class _$ShopCopyWithImpl<$Res>
    implements $ShopCopyWith<$Res> {
  _$ShopCopyWithImpl(this._self, this._then);

  final Shop _self;
  final $Res Function(Shop) _then;

/// Create a copy of Shop
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? handle = null,Object? name = null,Object? description = null,Object? logoUrl = freezed,Object? bannerUrl = freezed,Object? accentColor = null,Object? contactEmail = null,Object? contactPhone = null,Object? websiteUrl = null,Object? socialLinks = null,Object? category = null,Object? verificationStatus = null,Object? isActive = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,bannerUrl: freezed == bannerUrl ? _self.bannerUrl : bannerUrl // ignore: cast_nullable_to_non_nullable
as String?,accentColor: null == accentColor ? _self.accentColor : accentColor // ignore: cast_nullable_to_non_nullable
as String,contactEmail: null == contactEmail ? _self.contactEmail : contactEmail // ignore: cast_nullable_to_non_nullable
as String,contactPhone: null == contactPhone ? _self.contactPhone : contactPhone // ignore: cast_nullable_to_non_nullable
as String,websiteUrl: null == websiteUrl ? _self.websiteUrl : websiteUrl // ignore: cast_nullable_to_non_nullable
as String,socialLinks: null == socialLinks ? _self.socialLinks : socialLinks // ignore: cast_nullable_to_non_nullable
as Map<String, String>,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Shop].
extension ShopPatterns on Shop {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Shop value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Shop() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Shop value)  $default,){
final _that = this;
switch (_that) {
case _Shop():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Shop value)?  $default,){
final _that = this;
switch (_that) {
case _Shop() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String handle,  String name,  String description, @JsonKey(name: 'logo_url')  String? logoUrl, @JsonKey(name: 'banner_url')  String? bannerUrl, @JsonKey(name: 'accent_color')  String accentColor, @JsonKey(name: 'contact_email')  String contactEmail, @JsonKey(name: 'contact_phone')  String contactPhone, @JsonKey(name: 'website_url')  String websiteUrl, @JsonKey(name: 'social_links')  Map<String, String> socialLinks,  String category, @JsonKey(name: 'verification_status')  String verificationStatus, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Shop() when $default != null:
return $default(_that.id,_that.handle,_that.name,_that.description,_that.logoUrl,_that.bannerUrl,_that.accentColor,_that.contactEmail,_that.contactPhone,_that.websiteUrl,_that.socialLinks,_that.category,_that.verificationStatus,_that.isActive,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String handle,  String name,  String description, @JsonKey(name: 'logo_url')  String? logoUrl, @JsonKey(name: 'banner_url')  String? bannerUrl, @JsonKey(name: 'accent_color')  String accentColor, @JsonKey(name: 'contact_email')  String contactEmail, @JsonKey(name: 'contact_phone')  String contactPhone, @JsonKey(name: 'website_url')  String websiteUrl, @JsonKey(name: 'social_links')  Map<String, String> socialLinks,  String category, @JsonKey(name: 'verification_status')  String verificationStatus, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _Shop():
return $default(_that.id,_that.handle,_that.name,_that.description,_that.logoUrl,_that.bannerUrl,_that.accentColor,_that.contactEmail,_that.contactPhone,_that.websiteUrl,_that.socialLinks,_that.category,_that.verificationStatus,_that.isActive,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String handle,  String name,  String description, @JsonKey(name: 'logo_url')  String? logoUrl, @JsonKey(name: 'banner_url')  String? bannerUrl, @JsonKey(name: 'accent_color')  String accentColor, @JsonKey(name: 'contact_email')  String contactEmail, @JsonKey(name: 'contact_phone')  String contactPhone, @JsonKey(name: 'website_url')  String websiteUrl, @JsonKey(name: 'social_links')  Map<String, String> socialLinks,  String category, @JsonKey(name: 'verification_status')  String verificationStatus, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Shop() when $default != null:
return $default(_that.id,_that.handle,_that.name,_that.description,_that.logoUrl,_that.bannerUrl,_that.accentColor,_that.contactEmail,_that.contactPhone,_that.websiteUrl,_that.socialLinks,_that.category,_that.verificationStatus,_that.isActive,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Shop implements Shop {
  const _Shop({required this.id, required this.handle, required this.name, required this.description, @JsonKey(name: 'logo_url') this.logoUrl, @JsonKey(name: 'banner_url') this.bannerUrl, @JsonKey(name: 'accent_color') this.accentColor = '#6366f1', @JsonKey(name: 'contact_email') this.contactEmail = '', @JsonKey(name: 'contact_phone') this.contactPhone = '', @JsonKey(name: 'website_url') this.websiteUrl = '', @JsonKey(name: 'social_links') final  Map<String, String> socialLinks = const <String, String>{}, this.category = '', @JsonKey(name: 'verification_status') this.verificationStatus = 'unverified', @JsonKey(name: 'is_active') this.isActive = true, @JsonKey(name: 'created_at') required this.createdAt}): _socialLinks = socialLinks;
  factory _Shop.fromJson(Map<String, dynamic> json) => _$ShopFromJson(json);

@override final  String id;
@override final  String handle;
@override final  String name;
@override final  String description;
@override@JsonKey(name: 'logo_url') final  String? logoUrl;
@override@JsonKey(name: 'banner_url') final  String? bannerUrl;
@override@JsonKey(name: 'accent_color') final  String accentColor;
@override@JsonKey(name: 'contact_email') final  String contactEmail;
@override@JsonKey(name: 'contact_phone') final  String contactPhone;
@override@JsonKey(name: 'website_url') final  String websiteUrl;
 final  Map<String, String> _socialLinks;
@override@JsonKey(name: 'social_links') Map<String, String> get socialLinks {
  if (_socialLinks is EqualUnmodifiableMapView) return _socialLinks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_socialLinks);
}

@override@JsonKey() final  String category;
@override@JsonKey(name: 'verification_status') final  String verificationStatus;
@override@JsonKey(name: 'is_active') final  bool isActive;
@override@JsonKey(name: 'created_at') final  String createdAt;

/// Create a copy of Shop
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShopCopyWith<_Shop> get copyWith => __$ShopCopyWithImpl<_Shop>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShopToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Shop&&(identical(other.id, id) || other.id == id)&&(identical(other.handle, handle) || other.handle == handle)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.bannerUrl, bannerUrl) || other.bannerUrl == bannerUrl)&&(identical(other.accentColor, accentColor) || other.accentColor == accentColor)&&(identical(other.contactEmail, contactEmail) || other.contactEmail == contactEmail)&&(identical(other.contactPhone, contactPhone) || other.contactPhone == contactPhone)&&(identical(other.websiteUrl, websiteUrl) || other.websiteUrl == websiteUrl)&&const DeepCollectionEquality().equals(other._socialLinks, _socialLinks)&&(identical(other.category, category) || other.category == category)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,handle,name,description,logoUrl,bannerUrl,accentColor,contactEmail,contactPhone,websiteUrl,const DeepCollectionEquality().hash(_socialLinks),category,verificationStatus,isActive,createdAt);

@override
String toString() {
  return 'Shop(id: $id, handle: $handle, name: $name, description: $description, logoUrl: $logoUrl, bannerUrl: $bannerUrl, accentColor: $accentColor, contactEmail: $contactEmail, contactPhone: $contactPhone, websiteUrl: $websiteUrl, socialLinks: $socialLinks, category: $category, verificationStatus: $verificationStatus, isActive: $isActive, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ShopCopyWith<$Res> implements $ShopCopyWith<$Res> {
  factory _$ShopCopyWith(_Shop value, $Res Function(_Shop) _then) = __$ShopCopyWithImpl;
@override @useResult
$Res call({
 String id, String handle, String name, String description,@JsonKey(name: 'logo_url') String? logoUrl,@JsonKey(name: 'banner_url') String? bannerUrl,@JsonKey(name: 'accent_color') String accentColor,@JsonKey(name: 'contact_email') String contactEmail,@JsonKey(name: 'contact_phone') String contactPhone,@JsonKey(name: 'website_url') String websiteUrl,@JsonKey(name: 'social_links') Map<String, String> socialLinks, String category,@JsonKey(name: 'verification_status') String verificationStatus,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'created_at') String createdAt
});




}
/// @nodoc
class __$ShopCopyWithImpl<$Res>
    implements _$ShopCopyWith<$Res> {
  __$ShopCopyWithImpl(this._self, this._then);

  final _Shop _self;
  final $Res Function(_Shop) _then;

/// Create a copy of Shop
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? handle = null,Object? name = null,Object? description = null,Object? logoUrl = freezed,Object? bannerUrl = freezed,Object? accentColor = null,Object? contactEmail = null,Object? contactPhone = null,Object? websiteUrl = null,Object? socialLinks = null,Object? category = null,Object? verificationStatus = null,Object? isActive = null,Object? createdAt = null,}) {
  return _then(_Shop(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,bannerUrl: freezed == bannerUrl ? _self.bannerUrl : bannerUrl // ignore: cast_nullable_to_non_nullable
as String?,accentColor: null == accentColor ? _self.accentColor : accentColor // ignore: cast_nullable_to_non_nullable
as String,contactEmail: null == contactEmail ? _self.contactEmail : contactEmail // ignore: cast_nullable_to_non_nullable
as String,contactPhone: null == contactPhone ? _self.contactPhone : contactPhone // ignore: cast_nullable_to_non_nullable
as String,websiteUrl: null == websiteUrl ? _self.websiteUrl : websiteUrl // ignore: cast_nullable_to_non_nullable
as String,socialLinks: null == socialLinks ? _self._socialLinks : socialLinks // ignore: cast_nullable_to_non_nullable
as Map<String, String>,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$UserShopResponse {

 Shop get shop;@JsonKey(name: 'meal_plans') List<MealPlan> get mealPlans; List<TrainingProgramme> get programmes; List<MarketplaceEvent> get events; List<MarketplaceProduct> get products;
/// Create a copy of UserShopResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserShopResponseCopyWith<UserShopResponse> get copyWith => _$UserShopResponseCopyWithImpl<UserShopResponse>(this as UserShopResponse, _$identity);

  /// Serializes this UserShopResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserShopResponse&&(identical(other.shop, shop) || other.shop == shop)&&const DeepCollectionEquality().equals(other.mealPlans, mealPlans)&&const DeepCollectionEquality().equals(other.programmes, programmes)&&const DeepCollectionEquality().equals(other.events, events)&&const DeepCollectionEquality().equals(other.products, products));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,shop,const DeepCollectionEquality().hash(mealPlans),const DeepCollectionEquality().hash(programmes),const DeepCollectionEquality().hash(events),const DeepCollectionEquality().hash(products));

@override
String toString() {
  return 'UserShopResponse(shop: $shop, mealPlans: $mealPlans, programmes: $programmes, events: $events, products: $products)';
}


}

/// @nodoc
abstract mixin class $UserShopResponseCopyWith<$Res>  {
  factory $UserShopResponseCopyWith(UserShopResponse value, $Res Function(UserShopResponse) _then) = _$UserShopResponseCopyWithImpl;
@useResult
$Res call({
 Shop shop,@JsonKey(name: 'meal_plans') List<MealPlan> mealPlans, List<TrainingProgramme> programmes, List<MarketplaceEvent> events, List<MarketplaceProduct> products
});


$ShopCopyWith<$Res> get shop;

}
/// @nodoc
class _$UserShopResponseCopyWithImpl<$Res>
    implements $UserShopResponseCopyWith<$Res> {
  _$UserShopResponseCopyWithImpl(this._self, this._then);

  final UserShopResponse _self;
  final $Res Function(UserShopResponse) _then;

/// Create a copy of UserShopResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? shop = null,Object? mealPlans = null,Object? programmes = null,Object? events = null,Object? products = null,}) {
  return _then(_self.copyWith(
shop: null == shop ? _self.shop : shop // ignore: cast_nullable_to_non_nullable
as Shop,mealPlans: null == mealPlans ? _self.mealPlans : mealPlans // ignore: cast_nullable_to_non_nullable
as List<MealPlan>,programmes: null == programmes ? _self.programmes : programmes // ignore: cast_nullable_to_non_nullable
as List<TrainingProgramme>,events: null == events ? _self.events : events // ignore: cast_nullable_to_non_nullable
as List<MarketplaceEvent>,products: null == products ? _self.products : products // ignore: cast_nullable_to_non_nullable
as List<MarketplaceProduct>,
  ));
}
/// Create a copy of UserShopResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShopCopyWith<$Res> get shop {
  
  return $ShopCopyWith<$Res>(_self.shop, (value) {
    return _then(_self.copyWith(shop: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserShopResponse].
extension UserShopResponsePatterns on UserShopResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserShopResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserShopResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserShopResponse value)  $default,){
final _that = this;
switch (_that) {
case _UserShopResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserShopResponse value)?  $default,){
final _that = this;
switch (_that) {
case _UserShopResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Shop shop, @JsonKey(name: 'meal_plans')  List<MealPlan> mealPlans,  List<TrainingProgramme> programmes,  List<MarketplaceEvent> events,  List<MarketplaceProduct> products)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserShopResponse() when $default != null:
return $default(_that.shop,_that.mealPlans,_that.programmes,_that.events,_that.products);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Shop shop, @JsonKey(name: 'meal_plans')  List<MealPlan> mealPlans,  List<TrainingProgramme> programmes,  List<MarketplaceEvent> events,  List<MarketplaceProduct> products)  $default,) {final _that = this;
switch (_that) {
case _UserShopResponse():
return $default(_that.shop,_that.mealPlans,_that.programmes,_that.events,_that.products);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Shop shop, @JsonKey(name: 'meal_plans')  List<MealPlan> mealPlans,  List<TrainingProgramme> programmes,  List<MarketplaceEvent> events,  List<MarketplaceProduct> products)?  $default,) {final _that = this;
switch (_that) {
case _UserShopResponse() when $default != null:
return $default(_that.shop,_that.mealPlans,_that.programmes,_that.events,_that.products);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserShopResponse implements UserShopResponse {
  const _UserShopResponse({required this.shop, @JsonKey(name: 'meal_plans') final  List<MealPlan> mealPlans = const <MealPlan>[], final  List<TrainingProgramme> programmes = const <TrainingProgramme>[], final  List<MarketplaceEvent> events = const <MarketplaceEvent>[], final  List<MarketplaceProduct> products = const <MarketplaceProduct>[]}): _mealPlans = mealPlans,_programmes = programmes,_events = events,_products = products;
  factory _UserShopResponse.fromJson(Map<String, dynamic> json) => _$UserShopResponseFromJson(json);

@override final  Shop shop;
 final  List<MealPlan> _mealPlans;
@override@JsonKey(name: 'meal_plans') List<MealPlan> get mealPlans {
  if (_mealPlans is EqualUnmodifiableListView) return _mealPlans;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mealPlans);
}

 final  List<TrainingProgramme> _programmes;
@override@JsonKey() List<TrainingProgramme> get programmes {
  if (_programmes is EqualUnmodifiableListView) return _programmes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_programmes);
}

 final  List<MarketplaceEvent> _events;
@override@JsonKey() List<MarketplaceEvent> get events {
  if (_events is EqualUnmodifiableListView) return _events;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_events);
}

 final  List<MarketplaceProduct> _products;
@override@JsonKey() List<MarketplaceProduct> get products {
  if (_products is EqualUnmodifiableListView) return _products;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_products);
}


/// Create a copy of UserShopResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserShopResponseCopyWith<_UserShopResponse> get copyWith => __$UserShopResponseCopyWithImpl<_UserShopResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserShopResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserShopResponse&&(identical(other.shop, shop) || other.shop == shop)&&const DeepCollectionEquality().equals(other._mealPlans, _mealPlans)&&const DeepCollectionEquality().equals(other._programmes, _programmes)&&const DeepCollectionEquality().equals(other._events, _events)&&const DeepCollectionEquality().equals(other._products, _products));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,shop,const DeepCollectionEquality().hash(_mealPlans),const DeepCollectionEquality().hash(_programmes),const DeepCollectionEquality().hash(_events),const DeepCollectionEquality().hash(_products));

@override
String toString() {
  return 'UserShopResponse(shop: $shop, mealPlans: $mealPlans, programmes: $programmes, events: $events, products: $products)';
}


}

/// @nodoc
abstract mixin class _$UserShopResponseCopyWith<$Res> implements $UserShopResponseCopyWith<$Res> {
  factory _$UserShopResponseCopyWith(_UserShopResponse value, $Res Function(_UserShopResponse) _then) = __$UserShopResponseCopyWithImpl;
@override @useResult
$Res call({
 Shop shop,@JsonKey(name: 'meal_plans') List<MealPlan> mealPlans, List<TrainingProgramme> programmes, List<MarketplaceEvent> events, List<MarketplaceProduct> products
});


@override $ShopCopyWith<$Res> get shop;

}
/// @nodoc
class __$UserShopResponseCopyWithImpl<$Res>
    implements _$UserShopResponseCopyWith<$Res> {
  __$UserShopResponseCopyWithImpl(this._self, this._then);

  final _UserShopResponse _self;
  final $Res Function(_UserShopResponse) _then;

/// Create a copy of UserShopResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? shop = null,Object? mealPlans = null,Object? programmes = null,Object? events = null,Object? products = null,}) {
  return _then(_UserShopResponse(
shop: null == shop ? _self.shop : shop // ignore: cast_nullable_to_non_nullable
as Shop,mealPlans: null == mealPlans ? _self._mealPlans : mealPlans // ignore: cast_nullable_to_non_nullable
as List<MealPlan>,programmes: null == programmes ? _self._programmes : programmes // ignore: cast_nullable_to_non_nullable
as List<TrainingProgramme>,events: null == events ? _self._events : events // ignore: cast_nullable_to_non_nullable
as List<MarketplaceEvent>,products: null == products ? _self._products : products // ignore: cast_nullable_to_non_nullable
as List<MarketplaceProduct>,
  ));
}

/// Create a copy of UserShopResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShopCopyWith<$Res> get shop {
  
  return $ShopCopyWith<$Res>(_self.shop, (value) {
    return _then(_self.copyWith(shop: value));
  });
}
}


/// @nodoc
mixin _$BuddyUpCertification {

 String get id;@JsonKey(name: 'shop_id') String get shopId; String get status; String? get notes;
/// Create a copy of BuddyUpCertification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BuddyUpCertificationCopyWith<BuddyUpCertification> get copyWith => _$BuddyUpCertificationCopyWithImpl<BuddyUpCertification>(this as BuddyUpCertification, _$identity);

  /// Serializes this BuddyUpCertification to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BuddyUpCertification&&(identical(other.id, id) || other.id == id)&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.status, status) || other.status == status)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shopId,status,notes);

@override
String toString() {
  return 'BuddyUpCertification(id: $id, shopId: $shopId, status: $status, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $BuddyUpCertificationCopyWith<$Res>  {
  factory $BuddyUpCertificationCopyWith(BuddyUpCertification value, $Res Function(BuddyUpCertification) _then) = _$BuddyUpCertificationCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'shop_id') String shopId, String status, String? notes
});




}
/// @nodoc
class _$BuddyUpCertificationCopyWithImpl<$Res>
    implements $BuddyUpCertificationCopyWith<$Res> {
  _$BuddyUpCertificationCopyWithImpl(this._self, this._then);

  final BuddyUpCertification _self;
  final $Res Function(BuddyUpCertification) _then;

/// Create a copy of BuddyUpCertification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? shopId = null,Object? status = null,Object? notes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BuddyUpCertification].
extension BuddyUpCertificationPatterns on BuddyUpCertification {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BuddyUpCertification value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BuddyUpCertification() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BuddyUpCertification value)  $default,){
final _that = this;
switch (_that) {
case _BuddyUpCertification():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BuddyUpCertification value)?  $default,){
final _that = this;
switch (_that) {
case _BuddyUpCertification() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'shop_id')  String shopId,  String status,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BuddyUpCertification() when $default != null:
return $default(_that.id,_that.shopId,_that.status,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'shop_id')  String shopId,  String status,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _BuddyUpCertification():
return $default(_that.id,_that.shopId,_that.status,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'shop_id')  String shopId,  String status,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _BuddyUpCertification() when $default != null:
return $default(_that.id,_that.shopId,_that.status,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BuddyUpCertification implements BuddyUpCertification {
  const _BuddyUpCertification({required this.id, @JsonKey(name: 'shop_id') required this.shopId, required this.status, this.notes});
  factory _BuddyUpCertification.fromJson(Map<String, dynamic> json) => _$BuddyUpCertificationFromJson(json);

@override final  String id;
@override@JsonKey(name: 'shop_id') final  String shopId;
@override final  String status;
@override final  String? notes;

/// Create a copy of BuddyUpCertification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BuddyUpCertificationCopyWith<_BuddyUpCertification> get copyWith => __$BuddyUpCertificationCopyWithImpl<_BuddyUpCertification>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BuddyUpCertificationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BuddyUpCertification&&(identical(other.id, id) || other.id == id)&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.status, status) || other.status == status)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shopId,status,notes);

@override
String toString() {
  return 'BuddyUpCertification(id: $id, shopId: $shopId, status: $status, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$BuddyUpCertificationCopyWith<$Res> implements $BuddyUpCertificationCopyWith<$Res> {
  factory _$BuddyUpCertificationCopyWith(_BuddyUpCertification value, $Res Function(_BuddyUpCertification) _then) = __$BuddyUpCertificationCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'shop_id') String shopId, String status, String? notes
});




}
/// @nodoc
class __$BuddyUpCertificationCopyWithImpl<$Res>
    implements _$BuddyUpCertificationCopyWith<$Res> {
  __$BuddyUpCertificationCopyWithImpl(this._self, this._then);

  final _BuddyUpCertification _self;
  final $Res Function(_BuddyUpCertification) _then;

/// Create a copy of BuddyUpCertification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? shopId = null,Object? status = null,Object? notes = freezed,}) {
  return _then(_BuddyUpCertification(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$BuyerData {

 String get username; String get displayName;@JsonKey(name: 'avatar_url') String get avatarUrl;
/// Create a copy of BuyerData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BuyerDataCopyWith<BuyerData> get copyWith => _$BuyerDataCopyWithImpl<BuyerData>(this as BuyerData, _$identity);

  /// Serializes this BuyerData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BuyerData&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username,displayName,avatarUrl);

@override
String toString() {
  return 'BuyerData(username: $username, displayName: $displayName, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class $BuyerDataCopyWith<$Res>  {
  factory $BuyerDataCopyWith(BuyerData value, $Res Function(BuyerData) _then) = _$BuyerDataCopyWithImpl;
@useResult
$Res call({
 String username, String displayName,@JsonKey(name: 'avatar_url') String avatarUrl
});




}
/// @nodoc
class _$BuyerDataCopyWithImpl<$Res>
    implements $BuyerDataCopyWith<$Res> {
  _$BuyerDataCopyWithImpl(this._self, this._then);

  final BuyerData _self;
  final $Res Function(BuyerData) _then;

/// Create a copy of BuyerData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? username = null,Object? displayName = null,Object? avatarUrl = null,}) {
  return _then(_self.copyWith(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BuyerData].
extension BuyerDataPatterns on BuyerData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BuyerData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BuyerData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BuyerData value)  $default,){
final _that = this;
switch (_that) {
case _BuyerData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BuyerData value)?  $default,){
final _that = this;
switch (_that) {
case _BuyerData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String username,  String displayName, @JsonKey(name: 'avatar_url')  String avatarUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BuyerData() when $default != null:
return $default(_that.username,_that.displayName,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String username,  String displayName, @JsonKey(name: 'avatar_url')  String avatarUrl)  $default,) {final _that = this;
switch (_that) {
case _BuyerData():
return $default(_that.username,_that.displayName,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String username,  String displayName, @JsonKey(name: 'avatar_url')  String avatarUrl)?  $default,) {final _that = this;
switch (_that) {
case _BuyerData() when $default != null:
return $default(_that.username,_that.displayName,_that.avatarUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BuyerData implements BuyerData {
  const _BuyerData({required this.username, required this.displayName, @JsonKey(name: 'avatar_url') required this.avatarUrl});
  factory _BuyerData.fromJson(Map<String, dynamic> json) => _$BuyerDataFromJson(json);

@override final  String username;
@override final  String displayName;
@override@JsonKey(name: 'avatar_url') final  String avatarUrl;

/// Create a copy of BuyerData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BuyerDataCopyWith<_BuyerData> get copyWith => __$BuyerDataCopyWithImpl<_BuyerData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BuyerDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BuyerData&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username,displayName,avatarUrl);

@override
String toString() {
  return 'BuyerData(username: $username, displayName: $displayName, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class _$BuyerDataCopyWith<$Res> implements $BuyerDataCopyWith<$Res> {
  factory _$BuyerDataCopyWith(_BuyerData value, $Res Function(_BuyerData) _then) = __$BuyerDataCopyWithImpl;
@override @useResult
$Res call({
 String username, String displayName,@JsonKey(name: 'avatar_url') String avatarUrl
});




}
/// @nodoc
class __$BuyerDataCopyWithImpl<$Res>
    implements _$BuyerDataCopyWith<$Res> {
  __$BuyerDataCopyWithImpl(this._self, this._then);

  final _BuyerData _self;
  final $Res Function(_BuyerData) _then;

/// Create a copy of BuyerData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? username = null,Object? displayName = null,Object? avatarUrl = null,}) {
  return _then(_BuyerData(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$MealPlan {

 String get id;@JsonKey(name: 'creator_id') String get creatorId; String get title; String get description;@JsonKey(name: 'cover_image_url') String get coverImageUrl;@JsonKey(name: 'diet_type') String get dietType;@JsonKey(name: 'duration_weeks') int get durationWeeks;@JsonKey(name: 'calorie_range') String get calorieRange;@JsonKey(name: 'price_artifacts') Map<String, int> get priceArtifacts;@JsonKey(name: 'preview_day') Map<String, dynamic> get previewDay;@JsonKey(name: 'full_plan') Map<String, dynamic>? get fullPlan;@JsonKey(name: 'shopping_list') List<String> get shoppingList;@JsonKey(name: 'content_rating') String get contentRating;@JsonKey(name: 'purchase_count') int get purchaseCount;@JsonKey(name: 'average_rating') double get averageRating;@JsonKey(name: 'review_count') int get reviewCount;@JsonKey(name: 'creator_data') CreatorData get creatorData;@JsonKey(name: 'is_purchased') bool get isPurchased;@JsonKey(name: 'is_published') bool get isPublished;@JsonKey(name: 'shop_data') Shop? get shopData;@JsonKey(name: 'created_at') String get createdAt;
/// Create a copy of MealPlan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MealPlanCopyWith<MealPlan> get copyWith => _$MealPlanCopyWithImpl<MealPlan>(this as MealPlan, _$identity);

  /// Serializes this MealPlan to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MealPlan&&(identical(other.id, id) || other.id == id)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.coverImageUrl, coverImageUrl) || other.coverImageUrl == coverImageUrl)&&(identical(other.dietType, dietType) || other.dietType == dietType)&&(identical(other.durationWeeks, durationWeeks) || other.durationWeeks == durationWeeks)&&(identical(other.calorieRange, calorieRange) || other.calorieRange == calorieRange)&&const DeepCollectionEquality().equals(other.priceArtifacts, priceArtifacts)&&const DeepCollectionEquality().equals(other.previewDay, previewDay)&&const DeepCollectionEquality().equals(other.fullPlan, fullPlan)&&const DeepCollectionEquality().equals(other.shoppingList, shoppingList)&&(identical(other.contentRating, contentRating) || other.contentRating == contentRating)&&(identical(other.purchaseCount, purchaseCount) || other.purchaseCount == purchaseCount)&&(identical(other.averageRating, averageRating) || other.averageRating == averageRating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.creatorData, creatorData) || other.creatorData == creatorData)&&(identical(other.isPurchased, isPurchased) || other.isPurchased == isPurchased)&&(identical(other.isPublished, isPublished) || other.isPublished == isPublished)&&(identical(other.shopData, shopData) || other.shopData == shopData)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,creatorId,title,description,coverImageUrl,dietType,durationWeeks,calorieRange,const DeepCollectionEquality().hash(priceArtifacts),const DeepCollectionEquality().hash(previewDay),const DeepCollectionEquality().hash(fullPlan),const DeepCollectionEquality().hash(shoppingList),contentRating,purchaseCount,averageRating,reviewCount,creatorData,isPurchased,isPublished,shopData,createdAt]);

@override
String toString() {
  return 'MealPlan(id: $id, creatorId: $creatorId, title: $title, description: $description, coverImageUrl: $coverImageUrl, dietType: $dietType, durationWeeks: $durationWeeks, calorieRange: $calorieRange, priceArtifacts: $priceArtifacts, previewDay: $previewDay, fullPlan: $fullPlan, shoppingList: $shoppingList, contentRating: $contentRating, purchaseCount: $purchaseCount, averageRating: $averageRating, reviewCount: $reviewCount, creatorData: $creatorData, isPurchased: $isPurchased, isPublished: $isPublished, shopData: $shopData, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $MealPlanCopyWith<$Res>  {
  factory $MealPlanCopyWith(MealPlan value, $Res Function(MealPlan) _then) = _$MealPlanCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'creator_id') String creatorId, String title, String description,@JsonKey(name: 'cover_image_url') String coverImageUrl,@JsonKey(name: 'diet_type') String dietType,@JsonKey(name: 'duration_weeks') int durationWeeks,@JsonKey(name: 'calorie_range') String calorieRange,@JsonKey(name: 'price_artifacts') Map<String, int> priceArtifacts,@JsonKey(name: 'preview_day') Map<String, dynamic> previewDay,@JsonKey(name: 'full_plan') Map<String, dynamic>? fullPlan,@JsonKey(name: 'shopping_list') List<String> shoppingList,@JsonKey(name: 'content_rating') String contentRating,@JsonKey(name: 'purchase_count') int purchaseCount,@JsonKey(name: 'average_rating') double averageRating,@JsonKey(name: 'review_count') int reviewCount,@JsonKey(name: 'creator_data') CreatorData creatorData,@JsonKey(name: 'is_purchased') bool isPurchased,@JsonKey(name: 'is_published') bool isPublished,@JsonKey(name: 'shop_data') Shop? shopData,@JsonKey(name: 'created_at') String createdAt
});


$CreatorDataCopyWith<$Res> get creatorData;$ShopCopyWith<$Res>? get shopData;

}
/// @nodoc
class _$MealPlanCopyWithImpl<$Res>
    implements $MealPlanCopyWith<$Res> {
  _$MealPlanCopyWithImpl(this._self, this._then);

  final MealPlan _self;
  final $Res Function(MealPlan) _then;

/// Create a copy of MealPlan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? creatorId = null,Object? title = null,Object? description = null,Object? coverImageUrl = null,Object? dietType = null,Object? durationWeeks = null,Object? calorieRange = null,Object? priceArtifacts = null,Object? previewDay = null,Object? fullPlan = freezed,Object? shoppingList = null,Object? contentRating = null,Object? purchaseCount = null,Object? averageRating = null,Object? reviewCount = null,Object? creatorData = null,Object? isPurchased = null,Object? isPublished = null,Object? shopData = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,coverImageUrl: null == coverImageUrl ? _self.coverImageUrl : coverImageUrl // ignore: cast_nullable_to_non_nullable
as String,dietType: null == dietType ? _self.dietType : dietType // ignore: cast_nullable_to_non_nullable
as String,durationWeeks: null == durationWeeks ? _self.durationWeeks : durationWeeks // ignore: cast_nullable_to_non_nullable
as int,calorieRange: null == calorieRange ? _self.calorieRange : calorieRange // ignore: cast_nullable_to_non_nullable
as String,priceArtifacts: null == priceArtifacts ? _self.priceArtifacts : priceArtifacts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,previewDay: null == previewDay ? _self.previewDay : previewDay // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,fullPlan: freezed == fullPlan ? _self.fullPlan : fullPlan // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,shoppingList: null == shoppingList ? _self.shoppingList : shoppingList // ignore: cast_nullable_to_non_nullable
as List<String>,contentRating: null == contentRating ? _self.contentRating : contentRating // ignore: cast_nullable_to_non_nullable
as String,purchaseCount: null == purchaseCount ? _self.purchaseCount : purchaseCount // ignore: cast_nullable_to_non_nullable
as int,averageRating: null == averageRating ? _self.averageRating : averageRating // ignore: cast_nullable_to_non_nullable
as double,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,creatorData: null == creatorData ? _self.creatorData : creatorData // ignore: cast_nullable_to_non_nullable
as CreatorData,isPurchased: null == isPurchased ? _self.isPurchased : isPurchased // ignore: cast_nullable_to_non_nullable
as bool,isPublished: null == isPublished ? _self.isPublished : isPublished // ignore: cast_nullable_to_non_nullable
as bool,shopData: freezed == shopData ? _self.shopData : shopData // ignore: cast_nullable_to_non_nullable
as Shop?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of MealPlan
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CreatorDataCopyWith<$Res> get creatorData {
  
  return $CreatorDataCopyWith<$Res>(_self.creatorData, (value) {
    return _then(_self.copyWith(creatorData: value));
  });
}/// Create a copy of MealPlan
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShopCopyWith<$Res>? get shopData {
    if (_self.shopData == null) {
    return null;
  }

  return $ShopCopyWith<$Res>(_self.shopData!, (value) {
    return _then(_self.copyWith(shopData: value));
  });
}
}


/// Adds pattern-matching-related methods to [MealPlan].
extension MealPlanPatterns on MealPlan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MealPlan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MealPlan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MealPlan value)  $default,){
final _that = this;
switch (_that) {
case _MealPlan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MealPlan value)?  $default,){
final _that = this;
switch (_that) {
case _MealPlan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'creator_id')  String creatorId,  String title,  String description, @JsonKey(name: 'cover_image_url')  String coverImageUrl, @JsonKey(name: 'diet_type')  String dietType, @JsonKey(name: 'duration_weeks')  int durationWeeks, @JsonKey(name: 'calorie_range')  String calorieRange, @JsonKey(name: 'price_artifacts')  Map<String, int> priceArtifacts, @JsonKey(name: 'preview_day')  Map<String, dynamic> previewDay, @JsonKey(name: 'full_plan')  Map<String, dynamic>? fullPlan, @JsonKey(name: 'shopping_list')  List<String> shoppingList, @JsonKey(name: 'content_rating')  String contentRating, @JsonKey(name: 'purchase_count')  int purchaseCount, @JsonKey(name: 'average_rating')  double averageRating, @JsonKey(name: 'review_count')  int reviewCount, @JsonKey(name: 'creator_data')  CreatorData creatorData, @JsonKey(name: 'is_purchased')  bool isPurchased, @JsonKey(name: 'is_published')  bool isPublished, @JsonKey(name: 'shop_data')  Shop? shopData, @JsonKey(name: 'created_at')  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MealPlan() when $default != null:
return $default(_that.id,_that.creatorId,_that.title,_that.description,_that.coverImageUrl,_that.dietType,_that.durationWeeks,_that.calorieRange,_that.priceArtifacts,_that.previewDay,_that.fullPlan,_that.shoppingList,_that.contentRating,_that.purchaseCount,_that.averageRating,_that.reviewCount,_that.creatorData,_that.isPurchased,_that.isPublished,_that.shopData,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'creator_id')  String creatorId,  String title,  String description, @JsonKey(name: 'cover_image_url')  String coverImageUrl, @JsonKey(name: 'diet_type')  String dietType, @JsonKey(name: 'duration_weeks')  int durationWeeks, @JsonKey(name: 'calorie_range')  String calorieRange, @JsonKey(name: 'price_artifacts')  Map<String, int> priceArtifacts, @JsonKey(name: 'preview_day')  Map<String, dynamic> previewDay, @JsonKey(name: 'full_plan')  Map<String, dynamic>? fullPlan, @JsonKey(name: 'shopping_list')  List<String> shoppingList, @JsonKey(name: 'content_rating')  String contentRating, @JsonKey(name: 'purchase_count')  int purchaseCount, @JsonKey(name: 'average_rating')  double averageRating, @JsonKey(name: 'review_count')  int reviewCount, @JsonKey(name: 'creator_data')  CreatorData creatorData, @JsonKey(name: 'is_purchased')  bool isPurchased, @JsonKey(name: 'is_published')  bool isPublished, @JsonKey(name: 'shop_data')  Shop? shopData, @JsonKey(name: 'created_at')  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _MealPlan():
return $default(_that.id,_that.creatorId,_that.title,_that.description,_that.coverImageUrl,_that.dietType,_that.durationWeeks,_that.calorieRange,_that.priceArtifacts,_that.previewDay,_that.fullPlan,_that.shoppingList,_that.contentRating,_that.purchaseCount,_that.averageRating,_that.reviewCount,_that.creatorData,_that.isPurchased,_that.isPublished,_that.shopData,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'creator_id')  String creatorId,  String title,  String description, @JsonKey(name: 'cover_image_url')  String coverImageUrl, @JsonKey(name: 'diet_type')  String dietType, @JsonKey(name: 'duration_weeks')  int durationWeeks, @JsonKey(name: 'calorie_range')  String calorieRange, @JsonKey(name: 'price_artifacts')  Map<String, int> priceArtifacts, @JsonKey(name: 'preview_day')  Map<String, dynamic> previewDay, @JsonKey(name: 'full_plan')  Map<String, dynamic>? fullPlan, @JsonKey(name: 'shopping_list')  List<String> shoppingList, @JsonKey(name: 'content_rating')  String contentRating, @JsonKey(name: 'purchase_count')  int purchaseCount, @JsonKey(name: 'average_rating')  double averageRating, @JsonKey(name: 'review_count')  int reviewCount, @JsonKey(name: 'creator_data')  CreatorData creatorData, @JsonKey(name: 'is_purchased')  bool isPurchased, @JsonKey(name: 'is_published')  bool isPublished, @JsonKey(name: 'shop_data')  Shop? shopData, @JsonKey(name: 'created_at')  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _MealPlan() when $default != null:
return $default(_that.id,_that.creatorId,_that.title,_that.description,_that.coverImageUrl,_that.dietType,_that.durationWeeks,_that.calorieRange,_that.priceArtifacts,_that.previewDay,_that.fullPlan,_that.shoppingList,_that.contentRating,_that.purchaseCount,_that.averageRating,_that.reviewCount,_that.creatorData,_that.isPurchased,_that.isPublished,_that.shopData,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MealPlan implements MealPlan {
  const _MealPlan({required this.id, @JsonKey(name: 'creator_id') required this.creatorId, required this.title, required this.description, @JsonKey(name: 'cover_image_url') required this.coverImageUrl, @JsonKey(name: 'diet_type') required this.dietType, @JsonKey(name: 'duration_weeks') required this.durationWeeks, @JsonKey(name: 'calorie_range') required this.calorieRange, @JsonKey(name: 'price_artifacts') required final  Map<String, int> priceArtifacts, @JsonKey(name: 'preview_day') required final  Map<String, dynamic> previewDay, @JsonKey(name: 'full_plan') final  Map<String, dynamic>? fullPlan, @JsonKey(name: 'shopping_list') final  List<String> shoppingList = const <String>[], @JsonKey(name: 'content_rating') this.contentRating = 'general', @JsonKey(name: 'purchase_count') this.purchaseCount = 0, @JsonKey(name: 'average_rating') this.averageRating = 0.0, @JsonKey(name: 'review_count') this.reviewCount = 0, @JsonKey(name: 'creator_data') required this.creatorData, @JsonKey(name: 'is_purchased') this.isPurchased = false, @JsonKey(name: 'is_published') this.isPublished = true, @JsonKey(name: 'shop_data') this.shopData, @JsonKey(name: 'created_at') required this.createdAt}): _priceArtifacts = priceArtifacts,_previewDay = previewDay,_fullPlan = fullPlan,_shoppingList = shoppingList;
  factory _MealPlan.fromJson(Map<String, dynamic> json) => _$MealPlanFromJson(json);

@override final  String id;
@override@JsonKey(name: 'creator_id') final  String creatorId;
@override final  String title;
@override final  String description;
@override@JsonKey(name: 'cover_image_url') final  String coverImageUrl;
@override@JsonKey(name: 'diet_type') final  String dietType;
@override@JsonKey(name: 'duration_weeks') final  int durationWeeks;
@override@JsonKey(name: 'calorie_range') final  String calorieRange;
 final  Map<String, int> _priceArtifacts;
@override@JsonKey(name: 'price_artifacts') Map<String, int> get priceArtifacts {
  if (_priceArtifacts is EqualUnmodifiableMapView) return _priceArtifacts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_priceArtifacts);
}

 final  Map<String, dynamic> _previewDay;
@override@JsonKey(name: 'preview_day') Map<String, dynamic> get previewDay {
  if (_previewDay is EqualUnmodifiableMapView) return _previewDay;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_previewDay);
}

 final  Map<String, dynamic>? _fullPlan;
@override@JsonKey(name: 'full_plan') Map<String, dynamic>? get fullPlan {
  final value = _fullPlan;
  if (value == null) return null;
  if (_fullPlan is EqualUnmodifiableMapView) return _fullPlan;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<String> _shoppingList;
@override@JsonKey(name: 'shopping_list') List<String> get shoppingList {
  if (_shoppingList is EqualUnmodifiableListView) return _shoppingList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_shoppingList);
}

@override@JsonKey(name: 'content_rating') final  String contentRating;
@override@JsonKey(name: 'purchase_count') final  int purchaseCount;
@override@JsonKey(name: 'average_rating') final  double averageRating;
@override@JsonKey(name: 'review_count') final  int reviewCount;
@override@JsonKey(name: 'creator_data') final  CreatorData creatorData;
@override@JsonKey(name: 'is_purchased') final  bool isPurchased;
@override@JsonKey(name: 'is_published') final  bool isPublished;
@override@JsonKey(name: 'shop_data') final  Shop? shopData;
@override@JsonKey(name: 'created_at') final  String createdAt;

/// Create a copy of MealPlan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MealPlanCopyWith<_MealPlan> get copyWith => __$MealPlanCopyWithImpl<_MealPlan>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MealPlanToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MealPlan&&(identical(other.id, id) || other.id == id)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.coverImageUrl, coverImageUrl) || other.coverImageUrl == coverImageUrl)&&(identical(other.dietType, dietType) || other.dietType == dietType)&&(identical(other.durationWeeks, durationWeeks) || other.durationWeeks == durationWeeks)&&(identical(other.calorieRange, calorieRange) || other.calorieRange == calorieRange)&&const DeepCollectionEquality().equals(other._priceArtifacts, _priceArtifacts)&&const DeepCollectionEquality().equals(other._previewDay, _previewDay)&&const DeepCollectionEquality().equals(other._fullPlan, _fullPlan)&&const DeepCollectionEquality().equals(other._shoppingList, _shoppingList)&&(identical(other.contentRating, contentRating) || other.contentRating == contentRating)&&(identical(other.purchaseCount, purchaseCount) || other.purchaseCount == purchaseCount)&&(identical(other.averageRating, averageRating) || other.averageRating == averageRating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.creatorData, creatorData) || other.creatorData == creatorData)&&(identical(other.isPurchased, isPurchased) || other.isPurchased == isPurchased)&&(identical(other.isPublished, isPublished) || other.isPublished == isPublished)&&(identical(other.shopData, shopData) || other.shopData == shopData)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,creatorId,title,description,coverImageUrl,dietType,durationWeeks,calorieRange,const DeepCollectionEquality().hash(_priceArtifacts),const DeepCollectionEquality().hash(_previewDay),const DeepCollectionEquality().hash(_fullPlan),const DeepCollectionEquality().hash(_shoppingList),contentRating,purchaseCount,averageRating,reviewCount,creatorData,isPurchased,isPublished,shopData,createdAt]);

@override
String toString() {
  return 'MealPlan(id: $id, creatorId: $creatorId, title: $title, description: $description, coverImageUrl: $coverImageUrl, dietType: $dietType, durationWeeks: $durationWeeks, calorieRange: $calorieRange, priceArtifacts: $priceArtifacts, previewDay: $previewDay, fullPlan: $fullPlan, shoppingList: $shoppingList, contentRating: $contentRating, purchaseCount: $purchaseCount, averageRating: $averageRating, reviewCount: $reviewCount, creatorData: $creatorData, isPurchased: $isPurchased, isPublished: $isPublished, shopData: $shopData, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$MealPlanCopyWith<$Res> implements $MealPlanCopyWith<$Res> {
  factory _$MealPlanCopyWith(_MealPlan value, $Res Function(_MealPlan) _then) = __$MealPlanCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'creator_id') String creatorId, String title, String description,@JsonKey(name: 'cover_image_url') String coverImageUrl,@JsonKey(name: 'diet_type') String dietType,@JsonKey(name: 'duration_weeks') int durationWeeks,@JsonKey(name: 'calorie_range') String calorieRange,@JsonKey(name: 'price_artifacts') Map<String, int> priceArtifacts,@JsonKey(name: 'preview_day') Map<String, dynamic> previewDay,@JsonKey(name: 'full_plan') Map<String, dynamic>? fullPlan,@JsonKey(name: 'shopping_list') List<String> shoppingList,@JsonKey(name: 'content_rating') String contentRating,@JsonKey(name: 'purchase_count') int purchaseCount,@JsonKey(name: 'average_rating') double averageRating,@JsonKey(name: 'review_count') int reviewCount,@JsonKey(name: 'creator_data') CreatorData creatorData,@JsonKey(name: 'is_purchased') bool isPurchased,@JsonKey(name: 'is_published') bool isPublished,@JsonKey(name: 'shop_data') Shop? shopData,@JsonKey(name: 'created_at') String createdAt
});


@override $CreatorDataCopyWith<$Res> get creatorData;@override $ShopCopyWith<$Res>? get shopData;

}
/// @nodoc
class __$MealPlanCopyWithImpl<$Res>
    implements _$MealPlanCopyWith<$Res> {
  __$MealPlanCopyWithImpl(this._self, this._then);

  final _MealPlan _self;
  final $Res Function(_MealPlan) _then;

/// Create a copy of MealPlan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? creatorId = null,Object? title = null,Object? description = null,Object? coverImageUrl = null,Object? dietType = null,Object? durationWeeks = null,Object? calorieRange = null,Object? priceArtifacts = null,Object? previewDay = null,Object? fullPlan = freezed,Object? shoppingList = null,Object? contentRating = null,Object? purchaseCount = null,Object? averageRating = null,Object? reviewCount = null,Object? creatorData = null,Object? isPurchased = null,Object? isPublished = null,Object? shopData = freezed,Object? createdAt = null,}) {
  return _then(_MealPlan(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,coverImageUrl: null == coverImageUrl ? _self.coverImageUrl : coverImageUrl // ignore: cast_nullable_to_non_nullable
as String,dietType: null == dietType ? _self.dietType : dietType // ignore: cast_nullable_to_non_nullable
as String,durationWeeks: null == durationWeeks ? _self.durationWeeks : durationWeeks // ignore: cast_nullable_to_non_nullable
as int,calorieRange: null == calorieRange ? _self.calorieRange : calorieRange // ignore: cast_nullable_to_non_nullable
as String,priceArtifacts: null == priceArtifacts ? _self._priceArtifacts : priceArtifacts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,previewDay: null == previewDay ? _self._previewDay : previewDay // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,fullPlan: freezed == fullPlan ? _self._fullPlan : fullPlan // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,shoppingList: null == shoppingList ? _self._shoppingList : shoppingList // ignore: cast_nullable_to_non_nullable
as List<String>,contentRating: null == contentRating ? _self.contentRating : contentRating // ignore: cast_nullable_to_non_nullable
as String,purchaseCount: null == purchaseCount ? _self.purchaseCount : purchaseCount // ignore: cast_nullable_to_non_nullable
as int,averageRating: null == averageRating ? _self.averageRating : averageRating // ignore: cast_nullable_to_non_nullable
as double,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,creatorData: null == creatorData ? _self.creatorData : creatorData // ignore: cast_nullable_to_non_nullable
as CreatorData,isPurchased: null == isPurchased ? _self.isPurchased : isPurchased // ignore: cast_nullable_to_non_nullable
as bool,isPublished: null == isPublished ? _self.isPublished : isPublished // ignore: cast_nullable_to_non_nullable
as bool,shopData: freezed == shopData ? _self.shopData : shopData // ignore: cast_nullable_to_non_nullable
as Shop?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of MealPlan
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CreatorDataCopyWith<$Res> get creatorData {
  
  return $CreatorDataCopyWith<$Res>(_self.creatorData, (value) {
    return _then(_self.copyWith(creatorData: value));
  });
}/// Create a copy of MealPlan
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShopCopyWith<$Res>? get shopData {
    if (_self.shopData == null) {
    return null;
  }

  return $ShopCopyWith<$Res>(_self.shopData!, (value) {
    return _then(_self.copyWith(shopData: value));
  });
}
}


/// @nodoc
mixin _$MealPlanReview {

 String get id; int get rating; String? get body;@JsonKey(name: 'buyer_data') BuyerData get buyerData;@JsonKey(name: 'created_at') String get createdAt;
/// Create a copy of MealPlanReview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MealPlanReviewCopyWith<MealPlanReview> get copyWith => _$MealPlanReviewCopyWithImpl<MealPlanReview>(this as MealPlanReview, _$identity);

  /// Serializes this MealPlanReview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MealPlanReview&&(identical(other.id, id) || other.id == id)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.body, body) || other.body == body)&&(identical(other.buyerData, buyerData) || other.buyerData == buyerData)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,rating,body,buyerData,createdAt);

@override
String toString() {
  return 'MealPlanReview(id: $id, rating: $rating, body: $body, buyerData: $buyerData, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $MealPlanReviewCopyWith<$Res>  {
  factory $MealPlanReviewCopyWith(MealPlanReview value, $Res Function(MealPlanReview) _then) = _$MealPlanReviewCopyWithImpl;
@useResult
$Res call({
 String id, int rating, String? body,@JsonKey(name: 'buyer_data') BuyerData buyerData,@JsonKey(name: 'created_at') String createdAt
});


$BuyerDataCopyWith<$Res> get buyerData;

}
/// @nodoc
class _$MealPlanReviewCopyWithImpl<$Res>
    implements $MealPlanReviewCopyWith<$Res> {
  _$MealPlanReviewCopyWithImpl(this._self, this._then);

  final MealPlanReview _self;
  final $Res Function(MealPlanReview) _then;

/// Create a copy of MealPlanReview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? rating = null,Object? body = freezed,Object? buyerData = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,buyerData: null == buyerData ? _self.buyerData : buyerData // ignore: cast_nullable_to_non_nullable
as BuyerData,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of MealPlanReview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BuyerDataCopyWith<$Res> get buyerData {
  
  return $BuyerDataCopyWith<$Res>(_self.buyerData, (value) {
    return _then(_self.copyWith(buyerData: value));
  });
}
}


/// Adds pattern-matching-related methods to [MealPlanReview].
extension MealPlanReviewPatterns on MealPlanReview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MealPlanReview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MealPlanReview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MealPlanReview value)  $default,){
final _that = this;
switch (_that) {
case _MealPlanReview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MealPlanReview value)?  $default,){
final _that = this;
switch (_that) {
case _MealPlanReview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int rating,  String? body, @JsonKey(name: 'buyer_data')  BuyerData buyerData, @JsonKey(name: 'created_at')  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MealPlanReview() when $default != null:
return $default(_that.id,_that.rating,_that.body,_that.buyerData,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int rating,  String? body, @JsonKey(name: 'buyer_data')  BuyerData buyerData, @JsonKey(name: 'created_at')  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _MealPlanReview():
return $default(_that.id,_that.rating,_that.body,_that.buyerData,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int rating,  String? body, @JsonKey(name: 'buyer_data')  BuyerData buyerData, @JsonKey(name: 'created_at')  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _MealPlanReview() when $default != null:
return $default(_that.id,_that.rating,_that.body,_that.buyerData,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MealPlanReview implements MealPlanReview {
  const _MealPlanReview({required this.id, required this.rating, this.body, @JsonKey(name: 'buyer_data') required this.buyerData, @JsonKey(name: 'created_at') required this.createdAt});
  factory _MealPlanReview.fromJson(Map<String, dynamic> json) => _$MealPlanReviewFromJson(json);

@override final  String id;
@override final  int rating;
@override final  String? body;
@override@JsonKey(name: 'buyer_data') final  BuyerData buyerData;
@override@JsonKey(name: 'created_at') final  String createdAt;

/// Create a copy of MealPlanReview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MealPlanReviewCopyWith<_MealPlanReview> get copyWith => __$MealPlanReviewCopyWithImpl<_MealPlanReview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MealPlanReviewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MealPlanReview&&(identical(other.id, id) || other.id == id)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.body, body) || other.body == body)&&(identical(other.buyerData, buyerData) || other.buyerData == buyerData)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,rating,body,buyerData,createdAt);

@override
String toString() {
  return 'MealPlanReview(id: $id, rating: $rating, body: $body, buyerData: $buyerData, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$MealPlanReviewCopyWith<$Res> implements $MealPlanReviewCopyWith<$Res> {
  factory _$MealPlanReviewCopyWith(_MealPlanReview value, $Res Function(_MealPlanReview) _then) = __$MealPlanReviewCopyWithImpl;
@override @useResult
$Res call({
 String id, int rating, String? body,@JsonKey(name: 'buyer_data') BuyerData buyerData,@JsonKey(name: 'created_at') String createdAt
});


@override $BuyerDataCopyWith<$Res> get buyerData;

}
/// @nodoc
class __$MealPlanReviewCopyWithImpl<$Res>
    implements _$MealPlanReviewCopyWith<$Res> {
  __$MealPlanReviewCopyWithImpl(this._self, this._then);

  final _MealPlanReview _self;
  final $Res Function(_MealPlanReview) _then;

/// Create a copy of MealPlanReview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? rating = null,Object? body = freezed,Object? buyerData = null,Object? createdAt = null,}) {
  return _then(_MealPlanReview(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,buyerData: null == buyerData ? _self.buyerData : buyerData // ignore: cast_nullable_to_non_nullable
as BuyerData,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of MealPlanReview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BuyerDataCopyWith<$Res> get buyerData {
  
  return $BuyerDataCopyWith<$Res>(_self.buyerData, (value) {
    return _then(_self.copyWith(buyerData: value));
  });
}
}


/// @nodoc
mixin _$TrainingProgramme {

 String get id;@JsonKey(name: 'creator_id') String get creatorId; String get title; String get description;@JsonKey(name: 'cover_image_url') String get coverImageUrl; String get category;@JsonKey(name: 'duration_weeks') int get durationWeeks;@JsonKey(name: 'price_artifacts') Map<String, int> get priceArtifacts;@JsonKey(name: 'purchase_count') int get purchaseCount;@JsonKey(name: 'creator_data') CreatorData get creatorData;@JsonKey(name: 'is_purchased') bool get isPurchased;@JsonKey(name: 'is_published') bool get isPublished;@JsonKey(name: 'shop_data') Shop? get shopData;@JsonKey(name: 'content_rating') String get contentRating;@JsonKey(name: 'created_at') String get createdAt;
/// Create a copy of TrainingProgramme
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrainingProgrammeCopyWith<TrainingProgramme> get copyWith => _$TrainingProgrammeCopyWithImpl<TrainingProgramme>(this as TrainingProgramme, _$identity);

  /// Serializes this TrainingProgramme to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrainingProgramme&&(identical(other.id, id) || other.id == id)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.coverImageUrl, coverImageUrl) || other.coverImageUrl == coverImageUrl)&&(identical(other.category, category) || other.category == category)&&(identical(other.durationWeeks, durationWeeks) || other.durationWeeks == durationWeeks)&&const DeepCollectionEquality().equals(other.priceArtifacts, priceArtifacts)&&(identical(other.purchaseCount, purchaseCount) || other.purchaseCount == purchaseCount)&&(identical(other.creatorData, creatorData) || other.creatorData == creatorData)&&(identical(other.isPurchased, isPurchased) || other.isPurchased == isPurchased)&&(identical(other.isPublished, isPublished) || other.isPublished == isPublished)&&(identical(other.shopData, shopData) || other.shopData == shopData)&&(identical(other.contentRating, contentRating) || other.contentRating == contentRating)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,creatorId,title,description,coverImageUrl,category,durationWeeks,const DeepCollectionEquality().hash(priceArtifacts),purchaseCount,creatorData,isPurchased,isPublished,shopData,contentRating,createdAt);

@override
String toString() {
  return 'TrainingProgramme(id: $id, creatorId: $creatorId, title: $title, description: $description, coverImageUrl: $coverImageUrl, category: $category, durationWeeks: $durationWeeks, priceArtifacts: $priceArtifacts, purchaseCount: $purchaseCount, creatorData: $creatorData, isPurchased: $isPurchased, isPublished: $isPublished, shopData: $shopData, contentRating: $contentRating, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $TrainingProgrammeCopyWith<$Res>  {
  factory $TrainingProgrammeCopyWith(TrainingProgramme value, $Res Function(TrainingProgramme) _then) = _$TrainingProgrammeCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'creator_id') String creatorId, String title, String description,@JsonKey(name: 'cover_image_url') String coverImageUrl, String category,@JsonKey(name: 'duration_weeks') int durationWeeks,@JsonKey(name: 'price_artifacts') Map<String, int> priceArtifacts,@JsonKey(name: 'purchase_count') int purchaseCount,@JsonKey(name: 'creator_data') CreatorData creatorData,@JsonKey(name: 'is_purchased') bool isPurchased,@JsonKey(name: 'is_published') bool isPublished,@JsonKey(name: 'shop_data') Shop? shopData,@JsonKey(name: 'content_rating') String contentRating,@JsonKey(name: 'created_at') String createdAt
});


$CreatorDataCopyWith<$Res> get creatorData;$ShopCopyWith<$Res>? get shopData;

}
/// @nodoc
class _$TrainingProgrammeCopyWithImpl<$Res>
    implements $TrainingProgrammeCopyWith<$Res> {
  _$TrainingProgrammeCopyWithImpl(this._self, this._then);

  final TrainingProgramme _self;
  final $Res Function(TrainingProgramme) _then;

/// Create a copy of TrainingProgramme
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? creatorId = null,Object? title = null,Object? description = null,Object? coverImageUrl = null,Object? category = null,Object? durationWeeks = null,Object? priceArtifacts = null,Object? purchaseCount = null,Object? creatorData = null,Object? isPurchased = null,Object? isPublished = null,Object? shopData = freezed,Object? contentRating = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,coverImageUrl: null == coverImageUrl ? _self.coverImageUrl : coverImageUrl // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,durationWeeks: null == durationWeeks ? _self.durationWeeks : durationWeeks // ignore: cast_nullable_to_non_nullable
as int,priceArtifacts: null == priceArtifacts ? _self.priceArtifacts : priceArtifacts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,purchaseCount: null == purchaseCount ? _self.purchaseCount : purchaseCount // ignore: cast_nullable_to_non_nullable
as int,creatorData: null == creatorData ? _self.creatorData : creatorData // ignore: cast_nullable_to_non_nullable
as CreatorData,isPurchased: null == isPurchased ? _self.isPurchased : isPurchased // ignore: cast_nullable_to_non_nullable
as bool,isPublished: null == isPublished ? _self.isPublished : isPublished // ignore: cast_nullable_to_non_nullable
as bool,shopData: freezed == shopData ? _self.shopData : shopData // ignore: cast_nullable_to_non_nullable
as Shop?,contentRating: null == contentRating ? _self.contentRating : contentRating // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of TrainingProgramme
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CreatorDataCopyWith<$Res> get creatorData {
  
  return $CreatorDataCopyWith<$Res>(_self.creatorData, (value) {
    return _then(_self.copyWith(creatorData: value));
  });
}/// Create a copy of TrainingProgramme
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShopCopyWith<$Res>? get shopData {
    if (_self.shopData == null) {
    return null;
  }

  return $ShopCopyWith<$Res>(_self.shopData!, (value) {
    return _then(_self.copyWith(shopData: value));
  });
}
}


/// Adds pattern-matching-related methods to [TrainingProgramme].
extension TrainingProgrammePatterns on TrainingProgramme {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrainingProgramme value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrainingProgramme() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrainingProgramme value)  $default,){
final _that = this;
switch (_that) {
case _TrainingProgramme():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrainingProgramme value)?  $default,){
final _that = this;
switch (_that) {
case _TrainingProgramme() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'creator_id')  String creatorId,  String title,  String description, @JsonKey(name: 'cover_image_url')  String coverImageUrl,  String category, @JsonKey(name: 'duration_weeks')  int durationWeeks, @JsonKey(name: 'price_artifacts')  Map<String, int> priceArtifacts, @JsonKey(name: 'purchase_count')  int purchaseCount, @JsonKey(name: 'creator_data')  CreatorData creatorData, @JsonKey(name: 'is_purchased')  bool isPurchased, @JsonKey(name: 'is_published')  bool isPublished, @JsonKey(name: 'shop_data')  Shop? shopData, @JsonKey(name: 'content_rating')  String contentRating, @JsonKey(name: 'created_at')  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrainingProgramme() when $default != null:
return $default(_that.id,_that.creatorId,_that.title,_that.description,_that.coverImageUrl,_that.category,_that.durationWeeks,_that.priceArtifacts,_that.purchaseCount,_that.creatorData,_that.isPurchased,_that.isPublished,_that.shopData,_that.contentRating,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'creator_id')  String creatorId,  String title,  String description, @JsonKey(name: 'cover_image_url')  String coverImageUrl,  String category, @JsonKey(name: 'duration_weeks')  int durationWeeks, @JsonKey(name: 'price_artifacts')  Map<String, int> priceArtifacts, @JsonKey(name: 'purchase_count')  int purchaseCount, @JsonKey(name: 'creator_data')  CreatorData creatorData, @JsonKey(name: 'is_purchased')  bool isPurchased, @JsonKey(name: 'is_published')  bool isPublished, @JsonKey(name: 'shop_data')  Shop? shopData, @JsonKey(name: 'content_rating')  String contentRating, @JsonKey(name: 'created_at')  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _TrainingProgramme():
return $default(_that.id,_that.creatorId,_that.title,_that.description,_that.coverImageUrl,_that.category,_that.durationWeeks,_that.priceArtifacts,_that.purchaseCount,_that.creatorData,_that.isPurchased,_that.isPublished,_that.shopData,_that.contentRating,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'creator_id')  String creatorId,  String title,  String description, @JsonKey(name: 'cover_image_url')  String coverImageUrl,  String category, @JsonKey(name: 'duration_weeks')  int durationWeeks, @JsonKey(name: 'price_artifacts')  Map<String, int> priceArtifacts, @JsonKey(name: 'purchase_count')  int purchaseCount, @JsonKey(name: 'creator_data')  CreatorData creatorData, @JsonKey(name: 'is_purchased')  bool isPurchased, @JsonKey(name: 'is_published')  bool isPublished, @JsonKey(name: 'shop_data')  Shop? shopData, @JsonKey(name: 'content_rating')  String contentRating, @JsonKey(name: 'created_at')  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _TrainingProgramme() when $default != null:
return $default(_that.id,_that.creatorId,_that.title,_that.description,_that.coverImageUrl,_that.category,_that.durationWeeks,_that.priceArtifacts,_that.purchaseCount,_that.creatorData,_that.isPurchased,_that.isPublished,_that.shopData,_that.contentRating,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrainingProgramme implements TrainingProgramme {
  const _TrainingProgramme({required this.id, @JsonKey(name: 'creator_id') required this.creatorId, required this.title, required this.description, @JsonKey(name: 'cover_image_url') required this.coverImageUrl, required this.category, @JsonKey(name: 'duration_weeks') required this.durationWeeks, @JsonKey(name: 'price_artifacts') required final  Map<String, int> priceArtifacts, @JsonKey(name: 'purchase_count') this.purchaseCount = 0, @JsonKey(name: 'creator_data') required this.creatorData, @JsonKey(name: 'is_purchased') this.isPurchased = false, @JsonKey(name: 'is_published') this.isPublished = true, @JsonKey(name: 'shop_data') this.shopData, @JsonKey(name: 'content_rating') this.contentRating = 'general', @JsonKey(name: 'created_at') required this.createdAt}): _priceArtifacts = priceArtifacts;
  factory _TrainingProgramme.fromJson(Map<String, dynamic> json) => _$TrainingProgrammeFromJson(json);

@override final  String id;
@override@JsonKey(name: 'creator_id') final  String creatorId;
@override final  String title;
@override final  String description;
@override@JsonKey(name: 'cover_image_url') final  String coverImageUrl;
@override final  String category;
@override@JsonKey(name: 'duration_weeks') final  int durationWeeks;
 final  Map<String, int> _priceArtifacts;
@override@JsonKey(name: 'price_artifacts') Map<String, int> get priceArtifacts {
  if (_priceArtifacts is EqualUnmodifiableMapView) return _priceArtifacts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_priceArtifacts);
}

@override@JsonKey(name: 'purchase_count') final  int purchaseCount;
@override@JsonKey(name: 'creator_data') final  CreatorData creatorData;
@override@JsonKey(name: 'is_purchased') final  bool isPurchased;
@override@JsonKey(name: 'is_published') final  bool isPublished;
@override@JsonKey(name: 'shop_data') final  Shop? shopData;
@override@JsonKey(name: 'content_rating') final  String contentRating;
@override@JsonKey(name: 'created_at') final  String createdAt;

/// Create a copy of TrainingProgramme
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrainingProgrammeCopyWith<_TrainingProgramme> get copyWith => __$TrainingProgrammeCopyWithImpl<_TrainingProgramme>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrainingProgrammeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrainingProgramme&&(identical(other.id, id) || other.id == id)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.coverImageUrl, coverImageUrl) || other.coverImageUrl == coverImageUrl)&&(identical(other.category, category) || other.category == category)&&(identical(other.durationWeeks, durationWeeks) || other.durationWeeks == durationWeeks)&&const DeepCollectionEquality().equals(other._priceArtifacts, _priceArtifacts)&&(identical(other.purchaseCount, purchaseCount) || other.purchaseCount == purchaseCount)&&(identical(other.creatorData, creatorData) || other.creatorData == creatorData)&&(identical(other.isPurchased, isPurchased) || other.isPurchased == isPurchased)&&(identical(other.isPublished, isPublished) || other.isPublished == isPublished)&&(identical(other.shopData, shopData) || other.shopData == shopData)&&(identical(other.contentRating, contentRating) || other.contentRating == contentRating)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,creatorId,title,description,coverImageUrl,category,durationWeeks,const DeepCollectionEquality().hash(_priceArtifacts),purchaseCount,creatorData,isPurchased,isPublished,shopData,contentRating,createdAt);

@override
String toString() {
  return 'TrainingProgramme(id: $id, creatorId: $creatorId, title: $title, description: $description, coverImageUrl: $coverImageUrl, category: $category, durationWeeks: $durationWeeks, priceArtifacts: $priceArtifacts, purchaseCount: $purchaseCount, creatorData: $creatorData, isPurchased: $isPurchased, isPublished: $isPublished, shopData: $shopData, contentRating: $contentRating, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$TrainingProgrammeCopyWith<$Res> implements $TrainingProgrammeCopyWith<$Res> {
  factory _$TrainingProgrammeCopyWith(_TrainingProgramme value, $Res Function(_TrainingProgramme) _then) = __$TrainingProgrammeCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'creator_id') String creatorId, String title, String description,@JsonKey(name: 'cover_image_url') String coverImageUrl, String category,@JsonKey(name: 'duration_weeks') int durationWeeks,@JsonKey(name: 'price_artifacts') Map<String, int> priceArtifacts,@JsonKey(name: 'purchase_count') int purchaseCount,@JsonKey(name: 'creator_data') CreatorData creatorData,@JsonKey(name: 'is_purchased') bool isPurchased,@JsonKey(name: 'is_published') bool isPublished,@JsonKey(name: 'shop_data') Shop? shopData,@JsonKey(name: 'content_rating') String contentRating,@JsonKey(name: 'created_at') String createdAt
});


@override $CreatorDataCopyWith<$Res> get creatorData;@override $ShopCopyWith<$Res>? get shopData;

}
/// @nodoc
class __$TrainingProgrammeCopyWithImpl<$Res>
    implements _$TrainingProgrammeCopyWith<$Res> {
  __$TrainingProgrammeCopyWithImpl(this._self, this._then);

  final _TrainingProgramme _self;
  final $Res Function(_TrainingProgramme) _then;

/// Create a copy of TrainingProgramme
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? creatorId = null,Object? title = null,Object? description = null,Object? coverImageUrl = null,Object? category = null,Object? durationWeeks = null,Object? priceArtifacts = null,Object? purchaseCount = null,Object? creatorData = null,Object? isPurchased = null,Object? isPublished = null,Object? shopData = freezed,Object? contentRating = null,Object? createdAt = null,}) {
  return _then(_TrainingProgramme(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,coverImageUrl: null == coverImageUrl ? _self.coverImageUrl : coverImageUrl // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,durationWeeks: null == durationWeeks ? _self.durationWeeks : durationWeeks // ignore: cast_nullable_to_non_nullable
as int,priceArtifacts: null == priceArtifacts ? _self._priceArtifacts : priceArtifacts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,purchaseCount: null == purchaseCount ? _self.purchaseCount : purchaseCount // ignore: cast_nullable_to_non_nullable
as int,creatorData: null == creatorData ? _self.creatorData : creatorData // ignore: cast_nullable_to_non_nullable
as CreatorData,isPurchased: null == isPurchased ? _self.isPurchased : isPurchased // ignore: cast_nullable_to_non_nullable
as bool,isPublished: null == isPublished ? _self.isPublished : isPublished // ignore: cast_nullable_to_non_nullable
as bool,shopData: freezed == shopData ? _self.shopData : shopData // ignore: cast_nullable_to_non_nullable
as Shop?,contentRating: null == contentRating ? _self.contentRating : contentRating // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of TrainingProgramme
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CreatorDataCopyWith<$Res> get creatorData {
  
  return $CreatorDataCopyWith<$Res>(_self.creatorData, (value) {
    return _then(_self.copyWith(creatorData: value));
  });
}/// Create a copy of TrainingProgramme
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShopCopyWith<$Res>? get shopData {
    if (_self.shopData == null) {
    return null;
  }

  return $ShopCopyWith<$Res>(_self.shopData!, (value) {
    return _then(_self.copyWith(shopData: value));
  });
}
}


/// @nodoc
mixin _$TrainingProgrammeReview {

 String get id; int get rating; String? get body;@JsonKey(name: 'buyer_data') BuyerData get buyerData;@JsonKey(name: 'created_at') String get createdAt;
/// Create a copy of TrainingProgrammeReview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrainingProgrammeReviewCopyWith<TrainingProgrammeReview> get copyWith => _$TrainingProgrammeReviewCopyWithImpl<TrainingProgrammeReview>(this as TrainingProgrammeReview, _$identity);

  /// Serializes this TrainingProgrammeReview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrainingProgrammeReview&&(identical(other.id, id) || other.id == id)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.body, body) || other.body == body)&&(identical(other.buyerData, buyerData) || other.buyerData == buyerData)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,rating,body,buyerData,createdAt);

@override
String toString() {
  return 'TrainingProgrammeReview(id: $id, rating: $rating, body: $body, buyerData: $buyerData, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $TrainingProgrammeReviewCopyWith<$Res>  {
  factory $TrainingProgrammeReviewCopyWith(TrainingProgrammeReview value, $Res Function(TrainingProgrammeReview) _then) = _$TrainingProgrammeReviewCopyWithImpl;
@useResult
$Res call({
 String id, int rating, String? body,@JsonKey(name: 'buyer_data') BuyerData buyerData,@JsonKey(name: 'created_at') String createdAt
});


$BuyerDataCopyWith<$Res> get buyerData;

}
/// @nodoc
class _$TrainingProgrammeReviewCopyWithImpl<$Res>
    implements $TrainingProgrammeReviewCopyWith<$Res> {
  _$TrainingProgrammeReviewCopyWithImpl(this._self, this._then);

  final TrainingProgrammeReview _self;
  final $Res Function(TrainingProgrammeReview) _then;

/// Create a copy of TrainingProgrammeReview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? rating = null,Object? body = freezed,Object? buyerData = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,buyerData: null == buyerData ? _self.buyerData : buyerData // ignore: cast_nullable_to_non_nullable
as BuyerData,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of TrainingProgrammeReview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BuyerDataCopyWith<$Res> get buyerData {
  
  return $BuyerDataCopyWith<$Res>(_self.buyerData, (value) {
    return _then(_self.copyWith(buyerData: value));
  });
}
}


/// Adds pattern-matching-related methods to [TrainingProgrammeReview].
extension TrainingProgrammeReviewPatterns on TrainingProgrammeReview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrainingProgrammeReview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrainingProgrammeReview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrainingProgrammeReview value)  $default,){
final _that = this;
switch (_that) {
case _TrainingProgrammeReview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrainingProgrammeReview value)?  $default,){
final _that = this;
switch (_that) {
case _TrainingProgrammeReview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int rating,  String? body, @JsonKey(name: 'buyer_data')  BuyerData buyerData, @JsonKey(name: 'created_at')  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrainingProgrammeReview() when $default != null:
return $default(_that.id,_that.rating,_that.body,_that.buyerData,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int rating,  String? body, @JsonKey(name: 'buyer_data')  BuyerData buyerData, @JsonKey(name: 'created_at')  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _TrainingProgrammeReview():
return $default(_that.id,_that.rating,_that.body,_that.buyerData,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int rating,  String? body, @JsonKey(name: 'buyer_data')  BuyerData buyerData, @JsonKey(name: 'created_at')  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _TrainingProgrammeReview() when $default != null:
return $default(_that.id,_that.rating,_that.body,_that.buyerData,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrainingProgrammeReview implements TrainingProgrammeReview {
  const _TrainingProgrammeReview({required this.id, required this.rating, this.body, @JsonKey(name: 'buyer_data') required this.buyerData, @JsonKey(name: 'created_at') required this.createdAt});
  factory _TrainingProgrammeReview.fromJson(Map<String, dynamic> json) => _$TrainingProgrammeReviewFromJson(json);

@override final  String id;
@override final  int rating;
@override final  String? body;
@override@JsonKey(name: 'buyer_data') final  BuyerData buyerData;
@override@JsonKey(name: 'created_at') final  String createdAt;

/// Create a copy of TrainingProgrammeReview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrainingProgrammeReviewCopyWith<_TrainingProgrammeReview> get copyWith => __$TrainingProgrammeReviewCopyWithImpl<_TrainingProgrammeReview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrainingProgrammeReviewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrainingProgrammeReview&&(identical(other.id, id) || other.id == id)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.body, body) || other.body == body)&&(identical(other.buyerData, buyerData) || other.buyerData == buyerData)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,rating,body,buyerData,createdAt);

@override
String toString() {
  return 'TrainingProgrammeReview(id: $id, rating: $rating, body: $body, buyerData: $buyerData, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$TrainingProgrammeReviewCopyWith<$Res> implements $TrainingProgrammeReviewCopyWith<$Res> {
  factory _$TrainingProgrammeReviewCopyWith(_TrainingProgrammeReview value, $Res Function(_TrainingProgrammeReview) _then) = __$TrainingProgrammeReviewCopyWithImpl;
@override @useResult
$Res call({
 String id, int rating, String? body,@JsonKey(name: 'buyer_data') BuyerData buyerData,@JsonKey(name: 'created_at') String createdAt
});


@override $BuyerDataCopyWith<$Res> get buyerData;

}
/// @nodoc
class __$TrainingProgrammeReviewCopyWithImpl<$Res>
    implements _$TrainingProgrammeReviewCopyWith<$Res> {
  __$TrainingProgrammeReviewCopyWithImpl(this._self, this._then);

  final _TrainingProgrammeReview _self;
  final $Res Function(_TrainingProgrammeReview) _then;

/// Create a copy of TrainingProgrammeReview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? rating = null,Object? body = freezed,Object? buyerData = null,Object? createdAt = null,}) {
  return _then(_TrainingProgrammeReview(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,buyerData: null == buyerData ? _self.buyerData : buyerData // ignore: cast_nullable_to_non_nullable
as BuyerData,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of TrainingProgrammeReview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BuyerDataCopyWith<$Res> get buyerData {
  
  return $BuyerDataCopyWith<$Res>(_self.buyerData, (value) {
    return _then(_self.copyWith(buyerData: value));
  });
}
}


/// @nodoc
mixin _$MarketplaceProduct {

 String get id; String get name; String get brand; String get description; String get category;@JsonKey(name: 'image_url') String get imageUrl;@JsonKey(name: 'affiliate_url') String get affiliateUrl;@JsonKey(name: 'price_display') String get priceDisplay;@JsonKey(name: 'content_rating') String get contentRating;@JsonKey(name: 'recommended_by') String? get recommendedBy;@JsonKey(name: 'recommender_data') Map<String, dynamic>? get recommenderData;@JsonKey(name: 'click_count') int get clickCount;@JsonKey(name: 'is_active') bool get isActive;@JsonKey(name: 'shop_data') Shop? get shopData;@JsonKey(name: 'created_at') String get createdAt;
/// Create a copy of MarketplaceProduct
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarketplaceProductCopyWith<MarketplaceProduct> get copyWith => _$MarketplaceProductCopyWithImpl<MarketplaceProduct>(this as MarketplaceProduct, _$identity);

  /// Serializes this MarketplaceProduct to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarketplaceProduct&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.affiliateUrl, affiliateUrl) || other.affiliateUrl == affiliateUrl)&&(identical(other.priceDisplay, priceDisplay) || other.priceDisplay == priceDisplay)&&(identical(other.contentRating, contentRating) || other.contentRating == contentRating)&&(identical(other.recommendedBy, recommendedBy) || other.recommendedBy == recommendedBy)&&const DeepCollectionEquality().equals(other.recommenderData, recommenderData)&&(identical(other.clickCount, clickCount) || other.clickCount == clickCount)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.shopData, shopData) || other.shopData == shopData)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,brand,description,category,imageUrl,affiliateUrl,priceDisplay,contentRating,recommendedBy,const DeepCollectionEquality().hash(recommenderData),clickCount,isActive,shopData,createdAt);

@override
String toString() {
  return 'MarketplaceProduct(id: $id, name: $name, brand: $brand, description: $description, category: $category, imageUrl: $imageUrl, affiliateUrl: $affiliateUrl, priceDisplay: $priceDisplay, contentRating: $contentRating, recommendedBy: $recommendedBy, recommenderData: $recommenderData, clickCount: $clickCount, isActive: $isActive, shopData: $shopData, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $MarketplaceProductCopyWith<$Res>  {
  factory $MarketplaceProductCopyWith(MarketplaceProduct value, $Res Function(MarketplaceProduct) _then) = _$MarketplaceProductCopyWithImpl;
@useResult
$Res call({
 String id, String name, String brand, String description, String category,@JsonKey(name: 'image_url') String imageUrl,@JsonKey(name: 'affiliate_url') String affiliateUrl,@JsonKey(name: 'price_display') String priceDisplay,@JsonKey(name: 'content_rating') String contentRating,@JsonKey(name: 'recommended_by') String? recommendedBy,@JsonKey(name: 'recommender_data') Map<String, dynamic>? recommenderData,@JsonKey(name: 'click_count') int clickCount,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'shop_data') Shop? shopData,@JsonKey(name: 'created_at') String createdAt
});


$ShopCopyWith<$Res>? get shopData;

}
/// @nodoc
class _$MarketplaceProductCopyWithImpl<$Res>
    implements $MarketplaceProductCopyWith<$Res> {
  _$MarketplaceProductCopyWithImpl(this._self, this._then);

  final MarketplaceProduct _self;
  final $Res Function(MarketplaceProduct) _then;

/// Create a copy of MarketplaceProduct
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? brand = null,Object? description = null,Object? category = null,Object? imageUrl = null,Object? affiliateUrl = null,Object? priceDisplay = null,Object? contentRating = null,Object? recommendedBy = freezed,Object? recommenderData = freezed,Object? clickCount = null,Object? isActive = null,Object? shopData = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,affiliateUrl: null == affiliateUrl ? _self.affiliateUrl : affiliateUrl // ignore: cast_nullable_to_non_nullable
as String,priceDisplay: null == priceDisplay ? _self.priceDisplay : priceDisplay // ignore: cast_nullable_to_non_nullable
as String,contentRating: null == contentRating ? _self.contentRating : contentRating // ignore: cast_nullable_to_non_nullable
as String,recommendedBy: freezed == recommendedBy ? _self.recommendedBy : recommendedBy // ignore: cast_nullable_to_non_nullable
as String?,recommenderData: freezed == recommenderData ? _self.recommenderData : recommenderData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,clickCount: null == clickCount ? _self.clickCount : clickCount // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,shopData: freezed == shopData ? _self.shopData : shopData // ignore: cast_nullable_to_non_nullable
as Shop?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of MarketplaceProduct
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShopCopyWith<$Res>? get shopData {
    if (_self.shopData == null) {
    return null;
  }

  return $ShopCopyWith<$Res>(_self.shopData!, (value) {
    return _then(_self.copyWith(shopData: value));
  });
}
}


/// Adds pattern-matching-related methods to [MarketplaceProduct].
extension MarketplaceProductPatterns on MarketplaceProduct {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MarketplaceProduct value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MarketplaceProduct() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MarketplaceProduct value)  $default,){
final _that = this;
switch (_that) {
case _MarketplaceProduct():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MarketplaceProduct value)?  $default,){
final _that = this;
switch (_that) {
case _MarketplaceProduct() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String brand,  String description,  String category, @JsonKey(name: 'image_url')  String imageUrl, @JsonKey(name: 'affiliate_url')  String affiliateUrl, @JsonKey(name: 'price_display')  String priceDisplay, @JsonKey(name: 'content_rating')  String contentRating, @JsonKey(name: 'recommended_by')  String? recommendedBy, @JsonKey(name: 'recommender_data')  Map<String, dynamic>? recommenderData, @JsonKey(name: 'click_count')  int clickCount, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'shop_data')  Shop? shopData, @JsonKey(name: 'created_at')  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MarketplaceProduct() when $default != null:
return $default(_that.id,_that.name,_that.brand,_that.description,_that.category,_that.imageUrl,_that.affiliateUrl,_that.priceDisplay,_that.contentRating,_that.recommendedBy,_that.recommenderData,_that.clickCount,_that.isActive,_that.shopData,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String brand,  String description,  String category, @JsonKey(name: 'image_url')  String imageUrl, @JsonKey(name: 'affiliate_url')  String affiliateUrl, @JsonKey(name: 'price_display')  String priceDisplay, @JsonKey(name: 'content_rating')  String contentRating, @JsonKey(name: 'recommended_by')  String? recommendedBy, @JsonKey(name: 'recommender_data')  Map<String, dynamic>? recommenderData, @JsonKey(name: 'click_count')  int clickCount, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'shop_data')  Shop? shopData, @JsonKey(name: 'created_at')  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _MarketplaceProduct():
return $default(_that.id,_that.name,_that.brand,_that.description,_that.category,_that.imageUrl,_that.affiliateUrl,_that.priceDisplay,_that.contentRating,_that.recommendedBy,_that.recommenderData,_that.clickCount,_that.isActive,_that.shopData,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String brand,  String description,  String category, @JsonKey(name: 'image_url')  String imageUrl, @JsonKey(name: 'affiliate_url')  String affiliateUrl, @JsonKey(name: 'price_display')  String priceDisplay, @JsonKey(name: 'content_rating')  String contentRating, @JsonKey(name: 'recommended_by')  String? recommendedBy, @JsonKey(name: 'recommender_data')  Map<String, dynamic>? recommenderData, @JsonKey(name: 'click_count')  int clickCount, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'shop_data')  Shop? shopData, @JsonKey(name: 'created_at')  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _MarketplaceProduct() when $default != null:
return $default(_that.id,_that.name,_that.brand,_that.description,_that.category,_that.imageUrl,_that.affiliateUrl,_that.priceDisplay,_that.contentRating,_that.recommendedBy,_that.recommenderData,_that.clickCount,_that.isActive,_that.shopData,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MarketplaceProduct implements MarketplaceProduct {
  const _MarketplaceProduct({required this.id, required this.name, required this.brand, required this.description, required this.category, @JsonKey(name: 'image_url') required this.imageUrl, @JsonKey(name: 'affiliate_url') required this.affiliateUrl, @JsonKey(name: 'price_display') required this.priceDisplay, @JsonKey(name: 'content_rating') this.contentRating = 'general', @JsonKey(name: 'recommended_by') this.recommendedBy, @JsonKey(name: 'recommender_data') final  Map<String, dynamic>? recommenderData, @JsonKey(name: 'click_count') this.clickCount = 0, @JsonKey(name: 'is_active') this.isActive = true, @JsonKey(name: 'shop_data') this.shopData, @JsonKey(name: 'created_at') required this.createdAt}): _recommenderData = recommenderData;
  factory _MarketplaceProduct.fromJson(Map<String, dynamic> json) => _$MarketplaceProductFromJson(json);

@override final  String id;
@override final  String name;
@override final  String brand;
@override final  String description;
@override final  String category;
@override@JsonKey(name: 'image_url') final  String imageUrl;
@override@JsonKey(name: 'affiliate_url') final  String affiliateUrl;
@override@JsonKey(name: 'price_display') final  String priceDisplay;
@override@JsonKey(name: 'content_rating') final  String contentRating;
@override@JsonKey(name: 'recommended_by') final  String? recommendedBy;
 final  Map<String, dynamic>? _recommenderData;
@override@JsonKey(name: 'recommender_data') Map<String, dynamic>? get recommenderData {
  final value = _recommenderData;
  if (value == null) return null;
  if (_recommenderData is EqualUnmodifiableMapView) return _recommenderData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey(name: 'click_count') final  int clickCount;
@override@JsonKey(name: 'is_active') final  bool isActive;
@override@JsonKey(name: 'shop_data') final  Shop? shopData;
@override@JsonKey(name: 'created_at') final  String createdAt;

/// Create a copy of MarketplaceProduct
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarketplaceProductCopyWith<_MarketplaceProduct> get copyWith => __$MarketplaceProductCopyWithImpl<_MarketplaceProduct>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MarketplaceProductToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MarketplaceProduct&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.affiliateUrl, affiliateUrl) || other.affiliateUrl == affiliateUrl)&&(identical(other.priceDisplay, priceDisplay) || other.priceDisplay == priceDisplay)&&(identical(other.contentRating, contentRating) || other.contentRating == contentRating)&&(identical(other.recommendedBy, recommendedBy) || other.recommendedBy == recommendedBy)&&const DeepCollectionEquality().equals(other._recommenderData, _recommenderData)&&(identical(other.clickCount, clickCount) || other.clickCount == clickCount)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.shopData, shopData) || other.shopData == shopData)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,brand,description,category,imageUrl,affiliateUrl,priceDisplay,contentRating,recommendedBy,const DeepCollectionEquality().hash(_recommenderData),clickCount,isActive,shopData,createdAt);

@override
String toString() {
  return 'MarketplaceProduct(id: $id, name: $name, brand: $brand, description: $description, category: $category, imageUrl: $imageUrl, affiliateUrl: $affiliateUrl, priceDisplay: $priceDisplay, contentRating: $contentRating, recommendedBy: $recommendedBy, recommenderData: $recommenderData, clickCount: $clickCount, isActive: $isActive, shopData: $shopData, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$MarketplaceProductCopyWith<$Res> implements $MarketplaceProductCopyWith<$Res> {
  factory _$MarketplaceProductCopyWith(_MarketplaceProduct value, $Res Function(_MarketplaceProduct) _then) = __$MarketplaceProductCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String brand, String description, String category,@JsonKey(name: 'image_url') String imageUrl,@JsonKey(name: 'affiliate_url') String affiliateUrl,@JsonKey(name: 'price_display') String priceDisplay,@JsonKey(name: 'content_rating') String contentRating,@JsonKey(name: 'recommended_by') String? recommendedBy,@JsonKey(name: 'recommender_data') Map<String, dynamic>? recommenderData,@JsonKey(name: 'click_count') int clickCount,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'shop_data') Shop? shopData,@JsonKey(name: 'created_at') String createdAt
});


@override $ShopCopyWith<$Res>? get shopData;

}
/// @nodoc
class __$MarketplaceProductCopyWithImpl<$Res>
    implements _$MarketplaceProductCopyWith<$Res> {
  __$MarketplaceProductCopyWithImpl(this._self, this._then);

  final _MarketplaceProduct _self;
  final $Res Function(_MarketplaceProduct) _then;

/// Create a copy of MarketplaceProduct
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? brand = null,Object? description = null,Object? category = null,Object? imageUrl = null,Object? affiliateUrl = null,Object? priceDisplay = null,Object? contentRating = null,Object? recommendedBy = freezed,Object? recommenderData = freezed,Object? clickCount = null,Object? isActive = null,Object? shopData = freezed,Object? createdAt = null,}) {
  return _then(_MarketplaceProduct(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,affiliateUrl: null == affiliateUrl ? _self.affiliateUrl : affiliateUrl // ignore: cast_nullable_to_non_nullable
as String,priceDisplay: null == priceDisplay ? _self.priceDisplay : priceDisplay // ignore: cast_nullable_to_non_nullable
as String,contentRating: null == contentRating ? _self.contentRating : contentRating // ignore: cast_nullable_to_non_nullable
as String,recommendedBy: freezed == recommendedBy ? _self.recommendedBy : recommendedBy // ignore: cast_nullable_to_non_nullable
as String?,recommenderData: freezed == recommenderData ? _self._recommenderData : recommenderData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,clickCount: null == clickCount ? _self.clickCount : clickCount // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,shopData: freezed == shopData ? _self.shopData : shopData // ignore: cast_nullable_to_non_nullable
as Shop?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of MarketplaceProduct
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShopCopyWith<$Res>? get shopData {
    if (_self.shopData == null) {
    return null;
  }

  return $ShopCopyWith<$Res>(_self.shopData!, (value) {
    return _then(_self.copyWith(shopData: value));
  });
}
}


/// @nodoc
mixin _$GymData {

 String get id; String get name; String get handle;@JsonKey(name: 'logo_url') String get logoUrl;
/// Create a copy of GymData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GymDataCopyWith<GymData> get copyWith => _$GymDataCopyWithImpl<GymData>(this as GymData, _$identity);

  /// Serializes this GymData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GymData&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.handle, handle) || other.handle == handle)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,handle,logoUrl);

@override
String toString() {
  return 'GymData(id: $id, name: $name, handle: $handle, logoUrl: $logoUrl)';
}


}

/// @nodoc
abstract mixin class $GymDataCopyWith<$Res>  {
  factory $GymDataCopyWith(GymData value, $Res Function(GymData) _then) = _$GymDataCopyWithImpl;
@useResult
$Res call({
 String id, String name, String handle,@JsonKey(name: 'logo_url') String logoUrl
});




}
/// @nodoc
class _$GymDataCopyWithImpl<$Res>
    implements $GymDataCopyWith<$Res> {
  _$GymDataCopyWithImpl(this._self, this._then);

  final GymData _self;
  final $Res Function(GymData) _then;

/// Create a copy of GymData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? handle = null,Object? logoUrl = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,logoUrl: null == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GymData].
extension GymDataPatterns on GymData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GymData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GymData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GymData value)  $default,){
final _that = this;
switch (_that) {
case _GymData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GymData value)?  $default,){
final _that = this;
switch (_that) {
case _GymData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String handle, @JsonKey(name: 'logo_url')  String logoUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GymData() when $default != null:
return $default(_that.id,_that.name,_that.handle,_that.logoUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String handle, @JsonKey(name: 'logo_url')  String logoUrl)  $default,) {final _that = this;
switch (_that) {
case _GymData():
return $default(_that.id,_that.name,_that.handle,_that.logoUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String handle, @JsonKey(name: 'logo_url')  String logoUrl)?  $default,) {final _that = this;
switch (_that) {
case _GymData() when $default != null:
return $default(_that.id,_that.name,_that.handle,_that.logoUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GymData implements GymData {
  const _GymData({required this.id, required this.name, required this.handle, @JsonKey(name: 'logo_url') required this.logoUrl});
  factory _GymData.fromJson(Map<String, dynamic> json) => _$GymDataFromJson(json);

@override final  String id;
@override final  String name;
@override final  String handle;
@override@JsonKey(name: 'logo_url') final  String logoUrl;

/// Create a copy of GymData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GymDataCopyWith<_GymData> get copyWith => __$GymDataCopyWithImpl<_GymData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GymDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GymData&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.handle, handle) || other.handle == handle)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,handle,logoUrl);

@override
String toString() {
  return 'GymData(id: $id, name: $name, handle: $handle, logoUrl: $logoUrl)';
}


}

/// @nodoc
abstract mixin class _$GymDataCopyWith<$Res> implements $GymDataCopyWith<$Res> {
  factory _$GymDataCopyWith(_GymData value, $Res Function(_GymData) _then) = __$GymDataCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String handle,@JsonKey(name: 'logo_url') String logoUrl
});




}
/// @nodoc
class __$GymDataCopyWithImpl<$Res>
    implements _$GymDataCopyWith<$Res> {
  __$GymDataCopyWithImpl(this._self, this._then);

  final _GymData _self;
  final $Res Function(_GymData) _then;

/// Create a copy of GymData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? handle = null,Object? logoUrl = null,}) {
  return _then(_GymData(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,logoUrl: null == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$EventMediaItem {

 String get id;@JsonKey(name: 'media_type') String get mediaType; String get url;@JsonKey(name: 'thumbnail_url') String get thumbnailUrl;@JsonKey(name: 'alt_text') String get altText;@JsonKey(name: 'sort_order') int get sortOrder;
/// Create a copy of EventMediaItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventMediaItemCopyWith<EventMediaItem> get copyWith => _$EventMediaItemCopyWithImpl<EventMediaItem>(this as EventMediaItem, _$identity);

  /// Serializes this EventMediaItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventMediaItem&&(identical(other.id, id) || other.id == id)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.url, url) || other.url == url)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.altText, altText) || other.altText == altText)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,mediaType,url,thumbnailUrl,altText,sortOrder);

@override
String toString() {
  return 'EventMediaItem(id: $id, mediaType: $mediaType, url: $url, thumbnailUrl: $thumbnailUrl, altText: $altText, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class $EventMediaItemCopyWith<$Res>  {
  factory $EventMediaItemCopyWith(EventMediaItem value, $Res Function(EventMediaItem) _then) = _$EventMediaItemCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'media_type') String mediaType, String url,@JsonKey(name: 'thumbnail_url') String thumbnailUrl,@JsonKey(name: 'alt_text') String altText,@JsonKey(name: 'sort_order') int sortOrder
});




}
/// @nodoc
class _$EventMediaItemCopyWithImpl<$Res>
    implements $EventMediaItemCopyWith<$Res> {
  _$EventMediaItemCopyWithImpl(this._self, this._then);

  final EventMediaItem _self;
  final $Res Function(EventMediaItem) _then;

/// Create a copy of EventMediaItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? mediaType = null,Object? url = null,Object? thumbnailUrl = null,Object? altText = null,Object? sortOrder = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: null == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String,altText: null == altText ? _self.altText : altText // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [EventMediaItem].
extension EventMediaItemPatterns on EventMediaItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventMediaItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventMediaItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventMediaItem value)  $default,){
final _that = this;
switch (_that) {
case _EventMediaItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventMediaItem value)?  $default,){
final _that = this;
switch (_that) {
case _EventMediaItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'media_type')  String mediaType,  String url, @JsonKey(name: 'thumbnail_url')  String thumbnailUrl, @JsonKey(name: 'alt_text')  String altText, @JsonKey(name: 'sort_order')  int sortOrder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventMediaItem() when $default != null:
return $default(_that.id,_that.mediaType,_that.url,_that.thumbnailUrl,_that.altText,_that.sortOrder);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'media_type')  String mediaType,  String url, @JsonKey(name: 'thumbnail_url')  String thumbnailUrl, @JsonKey(name: 'alt_text')  String altText, @JsonKey(name: 'sort_order')  int sortOrder)  $default,) {final _that = this;
switch (_that) {
case _EventMediaItem():
return $default(_that.id,_that.mediaType,_that.url,_that.thumbnailUrl,_that.altText,_that.sortOrder);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'media_type')  String mediaType,  String url, @JsonKey(name: 'thumbnail_url')  String thumbnailUrl, @JsonKey(name: 'alt_text')  String altText, @JsonKey(name: 'sort_order')  int sortOrder)?  $default,) {final _that = this;
switch (_that) {
case _EventMediaItem() when $default != null:
return $default(_that.id,_that.mediaType,_that.url,_that.thumbnailUrl,_that.altText,_that.sortOrder);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventMediaItem implements EventMediaItem {
  const _EventMediaItem({required this.id, @JsonKey(name: 'media_type') this.mediaType = 'image', required this.url, @JsonKey(name: 'thumbnail_url') this.thumbnailUrl = '', @JsonKey(name: 'alt_text') this.altText = '', @JsonKey(name: 'sort_order') this.sortOrder = 0});
  factory _EventMediaItem.fromJson(Map<String, dynamic> json) => _$EventMediaItemFromJson(json);

@override final  String id;
@override@JsonKey(name: 'media_type') final  String mediaType;
@override final  String url;
@override@JsonKey(name: 'thumbnail_url') final  String thumbnailUrl;
@override@JsonKey(name: 'alt_text') final  String altText;
@override@JsonKey(name: 'sort_order') final  int sortOrder;

/// Create a copy of EventMediaItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventMediaItemCopyWith<_EventMediaItem> get copyWith => __$EventMediaItemCopyWithImpl<_EventMediaItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventMediaItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventMediaItem&&(identical(other.id, id) || other.id == id)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.url, url) || other.url == url)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.altText, altText) || other.altText == altText)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,mediaType,url,thumbnailUrl,altText,sortOrder);

@override
String toString() {
  return 'EventMediaItem(id: $id, mediaType: $mediaType, url: $url, thumbnailUrl: $thumbnailUrl, altText: $altText, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class _$EventMediaItemCopyWith<$Res> implements $EventMediaItemCopyWith<$Res> {
  factory _$EventMediaItemCopyWith(_EventMediaItem value, $Res Function(_EventMediaItem) _then) = __$EventMediaItemCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'media_type') String mediaType, String url,@JsonKey(name: 'thumbnail_url') String thumbnailUrl,@JsonKey(name: 'alt_text') String altText,@JsonKey(name: 'sort_order') int sortOrder
});




}
/// @nodoc
class __$EventMediaItemCopyWithImpl<$Res>
    implements _$EventMediaItemCopyWith<$Res> {
  __$EventMediaItemCopyWithImpl(this._self, this._then);

  final _EventMediaItem _self;
  final $Res Function(_EventMediaItem) _then;

/// Create a copy of EventMediaItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? mediaType = null,Object? url = null,Object? thumbnailUrl = null,Object? altText = null,Object? sortOrder = null,}) {
  return _then(_EventMediaItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: null == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String,altText: null == altText ? _self.altText : altText // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$MarketplaceEvent {

 String get id;@JsonKey(name: 'creator_data') CreatorData get creatorData;@JsonKey(name: 'gym_data') GymData? get gymData; String get title; String get description;@JsonKey(name: 'cover_image_url') String get coverImageUrl;@JsonKey(name: 'promo_video_url') String get promoVideoUrl;@JsonKey(name: 'gallery_urls') List<String> get galleryUrls;@JsonKey(name: 'event_type') String get eventType; String get location;@JsonKey(name: 'online_url') String get onlineUrl;@JsonKey(name: 'start_datetime') String get startDatetime;@JsonKey(name: 'end_datetime') String get endDatetime; String get timezone; String get recurrence;@JsonKey(name: 'ticket_tiers') List<Map<String, dynamic>> get ticketTiers; List<Map<String, dynamic>> get agenda; String get cancellationPolicy;@JsonKey(name: 'early_bird_enabled') bool get earlyBirdEnabled;@JsonKey(name: 'early_bird_deadline') String? get earlyBirdDeadline;@JsonKey(name: 'early_bird_price_artifacts') Map<String, int> get earlyBirdPriceArtifacts; int get capacity;@JsonKey(name: 'ticket_price_artifacts') Map<String, int> get ticketPriceArtifacts;@JsonKey(name: 'is_free') bool get isFree;@JsonKey(name: 'is_published') bool get isPublished;@JsonKey(name: 'is_cancelled') bool get isCancelled;@JsonKey(name: 'attendee_count') int get attendeeCount; List<String> get tags; String get category;@JsonKey(name: 'content_rating') String get contentRating;@JsonKey(name: 'is_registered') bool get isRegistered;@JsonKey(name: 'spots_remaining') int? get spotsRemaining;@JsonKey(name: 'shop_data') Shop? get shopData; List<EventMediaItem> get media;@JsonKey(name: 'created_at') String get createdAt;
/// Create a copy of MarketplaceEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarketplaceEventCopyWith<MarketplaceEvent> get copyWith => _$MarketplaceEventCopyWithImpl<MarketplaceEvent>(this as MarketplaceEvent, _$identity);

  /// Serializes this MarketplaceEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarketplaceEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.creatorData, creatorData) || other.creatorData == creatorData)&&(identical(other.gymData, gymData) || other.gymData == gymData)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.coverImageUrl, coverImageUrl) || other.coverImageUrl == coverImageUrl)&&(identical(other.promoVideoUrl, promoVideoUrl) || other.promoVideoUrl == promoVideoUrl)&&const DeepCollectionEquality().equals(other.galleryUrls, galleryUrls)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.location, location) || other.location == location)&&(identical(other.onlineUrl, onlineUrl) || other.onlineUrl == onlineUrl)&&(identical(other.startDatetime, startDatetime) || other.startDatetime == startDatetime)&&(identical(other.endDatetime, endDatetime) || other.endDatetime == endDatetime)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.recurrence, recurrence) || other.recurrence == recurrence)&&const DeepCollectionEquality().equals(other.ticketTiers, ticketTiers)&&const DeepCollectionEquality().equals(other.agenda, agenda)&&(identical(other.cancellationPolicy, cancellationPolicy) || other.cancellationPolicy == cancellationPolicy)&&(identical(other.earlyBirdEnabled, earlyBirdEnabled) || other.earlyBirdEnabled == earlyBirdEnabled)&&(identical(other.earlyBirdDeadline, earlyBirdDeadline) || other.earlyBirdDeadline == earlyBirdDeadline)&&const DeepCollectionEquality().equals(other.earlyBirdPriceArtifacts, earlyBirdPriceArtifacts)&&(identical(other.capacity, capacity) || other.capacity == capacity)&&const DeepCollectionEquality().equals(other.ticketPriceArtifacts, ticketPriceArtifacts)&&(identical(other.isFree, isFree) || other.isFree == isFree)&&(identical(other.isPublished, isPublished) || other.isPublished == isPublished)&&(identical(other.isCancelled, isCancelled) || other.isCancelled == isCancelled)&&(identical(other.attendeeCount, attendeeCount) || other.attendeeCount == attendeeCount)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.category, category) || other.category == category)&&(identical(other.contentRating, contentRating) || other.contentRating == contentRating)&&(identical(other.isRegistered, isRegistered) || other.isRegistered == isRegistered)&&(identical(other.spotsRemaining, spotsRemaining) || other.spotsRemaining == spotsRemaining)&&(identical(other.shopData, shopData) || other.shopData == shopData)&&const DeepCollectionEquality().equals(other.media, media)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,creatorData,gymData,title,description,coverImageUrl,promoVideoUrl,const DeepCollectionEquality().hash(galleryUrls),eventType,location,onlineUrl,startDatetime,endDatetime,timezone,recurrence,const DeepCollectionEquality().hash(ticketTiers),const DeepCollectionEquality().hash(agenda),cancellationPolicy,earlyBirdEnabled,earlyBirdDeadline,const DeepCollectionEquality().hash(earlyBirdPriceArtifacts),capacity,const DeepCollectionEquality().hash(ticketPriceArtifacts),isFree,isPublished,isCancelled,attendeeCount,const DeepCollectionEquality().hash(tags),category,contentRating,isRegistered,spotsRemaining,shopData,const DeepCollectionEquality().hash(media),createdAt]);

@override
String toString() {
  return 'MarketplaceEvent(id: $id, creatorData: $creatorData, gymData: $gymData, title: $title, description: $description, coverImageUrl: $coverImageUrl, promoVideoUrl: $promoVideoUrl, galleryUrls: $galleryUrls, eventType: $eventType, location: $location, onlineUrl: $onlineUrl, startDatetime: $startDatetime, endDatetime: $endDatetime, timezone: $timezone, recurrence: $recurrence, ticketTiers: $ticketTiers, agenda: $agenda, cancellationPolicy: $cancellationPolicy, earlyBirdEnabled: $earlyBirdEnabled, earlyBirdDeadline: $earlyBirdDeadline, earlyBirdPriceArtifacts: $earlyBirdPriceArtifacts, capacity: $capacity, ticketPriceArtifacts: $ticketPriceArtifacts, isFree: $isFree, isPublished: $isPublished, isCancelled: $isCancelled, attendeeCount: $attendeeCount, tags: $tags, category: $category, contentRating: $contentRating, isRegistered: $isRegistered, spotsRemaining: $spotsRemaining, shopData: $shopData, media: $media, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $MarketplaceEventCopyWith<$Res>  {
  factory $MarketplaceEventCopyWith(MarketplaceEvent value, $Res Function(MarketplaceEvent) _then) = _$MarketplaceEventCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'creator_data') CreatorData creatorData,@JsonKey(name: 'gym_data') GymData? gymData, String title, String description,@JsonKey(name: 'cover_image_url') String coverImageUrl,@JsonKey(name: 'promo_video_url') String promoVideoUrl,@JsonKey(name: 'gallery_urls') List<String> galleryUrls,@JsonKey(name: 'event_type') String eventType, String location,@JsonKey(name: 'online_url') String onlineUrl,@JsonKey(name: 'start_datetime') String startDatetime,@JsonKey(name: 'end_datetime') String endDatetime, String timezone, String recurrence,@JsonKey(name: 'ticket_tiers') List<Map<String, dynamic>> ticketTiers, List<Map<String, dynamic>> agenda, String cancellationPolicy,@JsonKey(name: 'early_bird_enabled') bool earlyBirdEnabled,@JsonKey(name: 'early_bird_deadline') String? earlyBirdDeadline,@JsonKey(name: 'early_bird_price_artifacts') Map<String, int> earlyBirdPriceArtifacts, int capacity,@JsonKey(name: 'ticket_price_artifacts') Map<String, int> ticketPriceArtifacts,@JsonKey(name: 'is_free') bool isFree,@JsonKey(name: 'is_published') bool isPublished,@JsonKey(name: 'is_cancelled') bool isCancelled,@JsonKey(name: 'attendee_count') int attendeeCount, List<String> tags, String category,@JsonKey(name: 'content_rating') String contentRating,@JsonKey(name: 'is_registered') bool isRegistered,@JsonKey(name: 'spots_remaining') int? spotsRemaining,@JsonKey(name: 'shop_data') Shop? shopData, List<EventMediaItem> media,@JsonKey(name: 'created_at') String createdAt
});


$CreatorDataCopyWith<$Res> get creatorData;$GymDataCopyWith<$Res>? get gymData;$ShopCopyWith<$Res>? get shopData;

}
/// @nodoc
class _$MarketplaceEventCopyWithImpl<$Res>
    implements $MarketplaceEventCopyWith<$Res> {
  _$MarketplaceEventCopyWithImpl(this._self, this._then);

  final MarketplaceEvent _self;
  final $Res Function(MarketplaceEvent) _then;

/// Create a copy of MarketplaceEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? creatorData = null,Object? gymData = freezed,Object? title = null,Object? description = null,Object? coverImageUrl = null,Object? promoVideoUrl = null,Object? galleryUrls = null,Object? eventType = null,Object? location = null,Object? onlineUrl = null,Object? startDatetime = null,Object? endDatetime = null,Object? timezone = null,Object? recurrence = null,Object? ticketTiers = null,Object? agenda = null,Object? cancellationPolicy = null,Object? earlyBirdEnabled = null,Object? earlyBirdDeadline = freezed,Object? earlyBirdPriceArtifacts = null,Object? capacity = null,Object? ticketPriceArtifacts = null,Object? isFree = null,Object? isPublished = null,Object? isCancelled = null,Object? attendeeCount = null,Object? tags = null,Object? category = null,Object? contentRating = null,Object? isRegistered = null,Object? spotsRemaining = freezed,Object? shopData = freezed,Object? media = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,creatorData: null == creatorData ? _self.creatorData : creatorData // ignore: cast_nullable_to_non_nullable
as CreatorData,gymData: freezed == gymData ? _self.gymData : gymData // ignore: cast_nullable_to_non_nullable
as GymData?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,coverImageUrl: null == coverImageUrl ? _self.coverImageUrl : coverImageUrl // ignore: cast_nullable_to_non_nullable
as String,promoVideoUrl: null == promoVideoUrl ? _self.promoVideoUrl : promoVideoUrl // ignore: cast_nullable_to_non_nullable
as String,galleryUrls: null == galleryUrls ? _self.galleryUrls : galleryUrls // ignore: cast_nullable_to_non_nullable
as List<String>,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,onlineUrl: null == onlineUrl ? _self.onlineUrl : onlineUrl // ignore: cast_nullable_to_non_nullable
as String,startDatetime: null == startDatetime ? _self.startDatetime : startDatetime // ignore: cast_nullable_to_non_nullable
as String,endDatetime: null == endDatetime ? _self.endDatetime : endDatetime // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,recurrence: null == recurrence ? _self.recurrence : recurrence // ignore: cast_nullable_to_non_nullable
as String,ticketTiers: null == ticketTiers ? _self.ticketTiers : ticketTiers // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,agenda: null == agenda ? _self.agenda : agenda // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,cancellationPolicy: null == cancellationPolicy ? _self.cancellationPolicy : cancellationPolicy // ignore: cast_nullable_to_non_nullable
as String,earlyBirdEnabled: null == earlyBirdEnabled ? _self.earlyBirdEnabled : earlyBirdEnabled // ignore: cast_nullable_to_non_nullable
as bool,earlyBirdDeadline: freezed == earlyBirdDeadline ? _self.earlyBirdDeadline : earlyBirdDeadline // ignore: cast_nullable_to_non_nullable
as String?,earlyBirdPriceArtifacts: null == earlyBirdPriceArtifacts ? _self.earlyBirdPriceArtifacts : earlyBirdPriceArtifacts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,capacity: null == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int,ticketPriceArtifacts: null == ticketPriceArtifacts ? _self.ticketPriceArtifacts : ticketPriceArtifacts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,isFree: null == isFree ? _self.isFree : isFree // ignore: cast_nullable_to_non_nullable
as bool,isPublished: null == isPublished ? _self.isPublished : isPublished // ignore: cast_nullable_to_non_nullable
as bool,isCancelled: null == isCancelled ? _self.isCancelled : isCancelled // ignore: cast_nullable_to_non_nullable
as bool,attendeeCount: null == attendeeCount ? _self.attendeeCount : attendeeCount // ignore: cast_nullable_to_non_nullable
as int,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,contentRating: null == contentRating ? _self.contentRating : contentRating // ignore: cast_nullable_to_non_nullable
as String,isRegistered: null == isRegistered ? _self.isRegistered : isRegistered // ignore: cast_nullable_to_non_nullable
as bool,spotsRemaining: freezed == spotsRemaining ? _self.spotsRemaining : spotsRemaining // ignore: cast_nullable_to_non_nullable
as int?,shopData: freezed == shopData ? _self.shopData : shopData // ignore: cast_nullable_to_non_nullable
as Shop?,media: null == media ? _self.media : media // ignore: cast_nullable_to_non_nullable
as List<EventMediaItem>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of MarketplaceEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CreatorDataCopyWith<$Res> get creatorData {
  
  return $CreatorDataCopyWith<$Res>(_self.creatorData, (value) {
    return _then(_self.copyWith(creatorData: value));
  });
}/// Create a copy of MarketplaceEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GymDataCopyWith<$Res>? get gymData {
    if (_self.gymData == null) {
    return null;
  }

  return $GymDataCopyWith<$Res>(_self.gymData!, (value) {
    return _then(_self.copyWith(gymData: value));
  });
}/// Create a copy of MarketplaceEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShopCopyWith<$Res>? get shopData {
    if (_self.shopData == null) {
    return null;
  }

  return $ShopCopyWith<$Res>(_self.shopData!, (value) {
    return _then(_self.copyWith(shopData: value));
  });
}
}


/// Adds pattern-matching-related methods to [MarketplaceEvent].
extension MarketplaceEventPatterns on MarketplaceEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MarketplaceEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MarketplaceEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MarketplaceEvent value)  $default,){
final _that = this;
switch (_that) {
case _MarketplaceEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MarketplaceEvent value)?  $default,){
final _that = this;
switch (_that) {
case _MarketplaceEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'creator_data')  CreatorData creatorData, @JsonKey(name: 'gym_data')  GymData? gymData,  String title,  String description, @JsonKey(name: 'cover_image_url')  String coverImageUrl, @JsonKey(name: 'promo_video_url')  String promoVideoUrl, @JsonKey(name: 'gallery_urls')  List<String> galleryUrls, @JsonKey(name: 'event_type')  String eventType,  String location, @JsonKey(name: 'online_url')  String onlineUrl, @JsonKey(name: 'start_datetime')  String startDatetime, @JsonKey(name: 'end_datetime')  String endDatetime,  String timezone,  String recurrence, @JsonKey(name: 'ticket_tiers')  List<Map<String, dynamic>> ticketTiers,  List<Map<String, dynamic>> agenda,  String cancellationPolicy, @JsonKey(name: 'early_bird_enabled')  bool earlyBirdEnabled, @JsonKey(name: 'early_bird_deadline')  String? earlyBirdDeadline, @JsonKey(name: 'early_bird_price_artifacts')  Map<String, int> earlyBirdPriceArtifacts,  int capacity, @JsonKey(name: 'ticket_price_artifacts')  Map<String, int> ticketPriceArtifacts, @JsonKey(name: 'is_free')  bool isFree, @JsonKey(name: 'is_published')  bool isPublished, @JsonKey(name: 'is_cancelled')  bool isCancelled, @JsonKey(name: 'attendee_count')  int attendeeCount,  List<String> tags,  String category, @JsonKey(name: 'content_rating')  String contentRating, @JsonKey(name: 'is_registered')  bool isRegistered, @JsonKey(name: 'spots_remaining')  int? spotsRemaining, @JsonKey(name: 'shop_data')  Shop? shopData,  List<EventMediaItem> media, @JsonKey(name: 'created_at')  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MarketplaceEvent() when $default != null:
return $default(_that.id,_that.creatorData,_that.gymData,_that.title,_that.description,_that.coverImageUrl,_that.promoVideoUrl,_that.galleryUrls,_that.eventType,_that.location,_that.onlineUrl,_that.startDatetime,_that.endDatetime,_that.timezone,_that.recurrence,_that.ticketTiers,_that.agenda,_that.cancellationPolicy,_that.earlyBirdEnabled,_that.earlyBirdDeadline,_that.earlyBirdPriceArtifacts,_that.capacity,_that.ticketPriceArtifacts,_that.isFree,_that.isPublished,_that.isCancelled,_that.attendeeCount,_that.tags,_that.category,_that.contentRating,_that.isRegistered,_that.spotsRemaining,_that.shopData,_that.media,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'creator_data')  CreatorData creatorData, @JsonKey(name: 'gym_data')  GymData? gymData,  String title,  String description, @JsonKey(name: 'cover_image_url')  String coverImageUrl, @JsonKey(name: 'promo_video_url')  String promoVideoUrl, @JsonKey(name: 'gallery_urls')  List<String> galleryUrls, @JsonKey(name: 'event_type')  String eventType,  String location, @JsonKey(name: 'online_url')  String onlineUrl, @JsonKey(name: 'start_datetime')  String startDatetime, @JsonKey(name: 'end_datetime')  String endDatetime,  String timezone,  String recurrence, @JsonKey(name: 'ticket_tiers')  List<Map<String, dynamic>> ticketTiers,  List<Map<String, dynamic>> agenda,  String cancellationPolicy, @JsonKey(name: 'early_bird_enabled')  bool earlyBirdEnabled, @JsonKey(name: 'early_bird_deadline')  String? earlyBirdDeadline, @JsonKey(name: 'early_bird_price_artifacts')  Map<String, int> earlyBirdPriceArtifacts,  int capacity, @JsonKey(name: 'ticket_price_artifacts')  Map<String, int> ticketPriceArtifacts, @JsonKey(name: 'is_free')  bool isFree, @JsonKey(name: 'is_published')  bool isPublished, @JsonKey(name: 'is_cancelled')  bool isCancelled, @JsonKey(name: 'attendee_count')  int attendeeCount,  List<String> tags,  String category, @JsonKey(name: 'content_rating')  String contentRating, @JsonKey(name: 'is_registered')  bool isRegistered, @JsonKey(name: 'spots_remaining')  int? spotsRemaining, @JsonKey(name: 'shop_data')  Shop? shopData,  List<EventMediaItem> media, @JsonKey(name: 'created_at')  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _MarketplaceEvent():
return $default(_that.id,_that.creatorData,_that.gymData,_that.title,_that.description,_that.coverImageUrl,_that.promoVideoUrl,_that.galleryUrls,_that.eventType,_that.location,_that.onlineUrl,_that.startDatetime,_that.endDatetime,_that.timezone,_that.recurrence,_that.ticketTiers,_that.agenda,_that.cancellationPolicy,_that.earlyBirdEnabled,_that.earlyBirdDeadline,_that.earlyBirdPriceArtifacts,_that.capacity,_that.ticketPriceArtifacts,_that.isFree,_that.isPublished,_that.isCancelled,_that.attendeeCount,_that.tags,_that.category,_that.contentRating,_that.isRegistered,_that.spotsRemaining,_that.shopData,_that.media,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'creator_data')  CreatorData creatorData, @JsonKey(name: 'gym_data')  GymData? gymData,  String title,  String description, @JsonKey(name: 'cover_image_url')  String coverImageUrl, @JsonKey(name: 'promo_video_url')  String promoVideoUrl, @JsonKey(name: 'gallery_urls')  List<String> galleryUrls, @JsonKey(name: 'event_type')  String eventType,  String location, @JsonKey(name: 'online_url')  String onlineUrl, @JsonKey(name: 'start_datetime')  String startDatetime, @JsonKey(name: 'end_datetime')  String endDatetime,  String timezone,  String recurrence, @JsonKey(name: 'ticket_tiers')  List<Map<String, dynamic>> ticketTiers,  List<Map<String, dynamic>> agenda,  String cancellationPolicy, @JsonKey(name: 'early_bird_enabled')  bool earlyBirdEnabled, @JsonKey(name: 'early_bird_deadline')  String? earlyBirdDeadline, @JsonKey(name: 'early_bird_price_artifacts')  Map<String, int> earlyBirdPriceArtifacts,  int capacity, @JsonKey(name: 'ticket_price_artifacts')  Map<String, int> ticketPriceArtifacts, @JsonKey(name: 'is_free')  bool isFree, @JsonKey(name: 'is_published')  bool isPublished, @JsonKey(name: 'is_cancelled')  bool isCancelled, @JsonKey(name: 'attendee_count')  int attendeeCount,  List<String> tags,  String category, @JsonKey(name: 'content_rating')  String contentRating, @JsonKey(name: 'is_registered')  bool isRegistered, @JsonKey(name: 'spots_remaining')  int? spotsRemaining, @JsonKey(name: 'shop_data')  Shop? shopData,  List<EventMediaItem> media, @JsonKey(name: 'created_at')  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _MarketplaceEvent() when $default != null:
return $default(_that.id,_that.creatorData,_that.gymData,_that.title,_that.description,_that.coverImageUrl,_that.promoVideoUrl,_that.galleryUrls,_that.eventType,_that.location,_that.onlineUrl,_that.startDatetime,_that.endDatetime,_that.timezone,_that.recurrence,_that.ticketTiers,_that.agenda,_that.cancellationPolicy,_that.earlyBirdEnabled,_that.earlyBirdDeadline,_that.earlyBirdPriceArtifacts,_that.capacity,_that.ticketPriceArtifacts,_that.isFree,_that.isPublished,_that.isCancelled,_that.attendeeCount,_that.tags,_that.category,_that.contentRating,_that.isRegistered,_that.spotsRemaining,_that.shopData,_that.media,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MarketplaceEvent implements MarketplaceEvent {
  const _MarketplaceEvent({required this.id, @JsonKey(name: 'creator_data') required this.creatorData, @JsonKey(name: 'gym_data') this.gymData, required this.title, required this.description, @JsonKey(name: 'cover_image_url') required this.coverImageUrl, @JsonKey(name: 'promo_video_url') this.promoVideoUrl = '', @JsonKey(name: 'gallery_urls') final  List<String> galleryUrls = const <String>[], @JsonKey(name: 'event_type') required this.eventType, required this.location, @JsonKey(name: 'online_url') required this.onlineUrl, @JsonKey(name: 'start_datetime') required this.startDatetime, @JsonKey(name: 'end_datetime') required this.endDatetime, required this.timezone, this.recurrence = 'none', @JsonKey(name: 'ticket_tiers') final  List<Map<String, dynamic>> ticketTiers = const <Map<String, dynamic>>[], final  List<Map<String, dynamic>> agenda = const <Map<String, dynamic>>[], this.cancellationPolicy = '', @JsonKey(name: 'early_bird_enabled') this.earlyBirdEnabled = false, @JsonKey(name: 'early_bird_deadline') this.earlyBirdDeadline, @JsonKey(name: 'early_bird_price_artifacts') final  Map<String, int> earlyBirdPriceArtifacts = const <String, int>{}, required this.capacity, @JsonKey(name: 'ticket_price_artifacts') required final  Map<String, int> ticketPriceArtifacts, @JsonKey(name: 'is_free') this.isFree = false, @JsonKey(name: 'is_published') this.isPublished = false, @JsonKey(name: 'is_cancelled') this.isCancelled = false, @JsonKey(name: 'attendee_count') this.attendeeCount = 0, final  List<String> tags = const <String>[], this.category = '', @JsonKey(name: 'content_rating') this.contentRating = 'general', @JsonKey(name: 'is_registered') this.isRegistered = false, @JsonKey(name: 'spots_remaining') this.spotsRemaining, @JsonKey(name: 'shop_data') this.shopData, final  List<EventMediaItem> media = const <EventMediaItem>[], @JsonKey(name: 'created_at') required this.createdAt}): _galleryUrls = galleryUrls,_ticketTiers = ticketTiers,_agenda = agenda,_earlyBirdPriceArtifacts = earlyBirdPriceArtifacts,_ticketPriceArtifacts = ticketPriceArtifacts,_tags = tags,_media = media;
  factory _MarketplaceEvent.fromJson(Map<String, dynamic> json) => _$MarketplaceEventFromJson(json);

@override final  String id;
@override@JsonKey(name: 'creator_data') final  CreatorData creatorData;
@override@JsonKey(name: 'gym_data') final  GymData? gymData;
@override final  String title;
@override final  String description;
@override@JsonKey(name: 'cover_image_url') final  String coverImageUrl;
@override@JsonKey(name: 'promo_video_url') final  String promoVideoUrl;
 final  List<String> _galleryUrls;
@override@JsonKey(name: 'gallery_urls') List<String> get galleryUrls {
  if (_galleryUrls is EqualUnmodifiableListView) return _galleryUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_galleryUrls);
}

@override@JsonKey(name: 'event_type') final  String eventType;
@override final  String location;
@override@JsonKey(name: 'online_url') final  String onlineUrl;
@override@JsonKey(name: 'start_datetime') final  String startDatetime;
@override@JsonKey(name: 'end_datetime') final  String endDatetime;
@override final  String timezone;
@override@JsonKey() final  String recurrence;
 final  List<Map<String, dynamic>> _ticketTiers;
@override@JsonKey(name: 'ticket_tiers') List<Map<String, dynamic>> get ticketTiers {
  if (_ticketTiers is EqualUnmodifiableListView) return _ticketTiers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ticketTiers);
}

 final  List<Map<String, dynamic>> _agenda;
@override@JsonKey() List<Map<String, dynamic>> get agenda {
  if (_agenda is EqualUnmodifiableListView) return _agenda;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_agenda);
}

@override@JsonKey() final  String cancellationPolicy;
@override@JsonKey(name: 'early_bird_enabled') final  bool earlyBirdEnabled;
@override@JsonKey(name: 'early_bird_deadline') final  String? earlyBirdDeadline;
 final  Map<String, int> _earlyBirdPriceArtifacts;
@override@JsonKey(name: 'early_bird_price_artifacts') Map<String, int> get earlyBirdPriceArtifacts {
  if (_earlyBirdPriceArtifacts is EqualUnmodifiableMapView) return _earlyBirdPriceArtifacts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_earlyBirdPriceArtifacts);
}

@override final  int capacity;
 final  Map<String, int> _ticketPriceArtifacts;
@override@JsonKey(name: 'ticket_price_artifacts') Map<String, int> get ticketPriceArtifacts {
  if (_ticketPriceArtifacts is EqualUnmodifiableMapView) return _ticketPriceArtifacts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_ticketPriceArtifacts);
}

@override@JsonKey(name: 'is_free') final  bool isFree;
@override@JsonKey(name: 'is_published') final  bool isPublished;
@override@JsonKey(name: 'is_cancelled') final  bool isCancelled;
@override@JsonKey(name: 'attendee_count') final  int attendeeCount;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override@JsonKey() final  String category;
@override@JsonKey(name: 'content_rating') final  String contentRating;
@override@JsonKey(name: 'is_registered') final  bool isRegistered;
@override@JsonKey(name: 'spots_remaining') final  int? spotsRemaining;
@override@JsonKey(name: 'shop_data') final  Shop? shopData;
 final  List<EventMediaItem> _media;
@override@JsonKey() List<EventMediaItem> get media {
  if (_media is EqualUnmodifiableListView) return _media;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_media);
}

@override@JsonKey(name: 'created_at') final  String createdAt;

/// Create a copy of MarketplaceEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarketplaceEventCopyWith<_MarketplaceEvent> get copyWith => __$MarketplaceEventCopyWithImpl<_MarketplaceEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MarketplaceEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MarketplaceEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.creatorData, creatorData) || other.creatorData == creatorData)&&(identical(other.gymData, gymData) || other.gymData == gymData)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.coverImageUrl, coverImageUrl) || other.coverImageUrl == coverImageUrl)&&(identical(other.promoVideoUrl, promoVideoUrl) || other.promoVideoUrl == promoVideoUrl)&&const DeepCollectionEquality().equals(other._galleryUrls, _galleryUrls)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.location, location) || other.location == location)&&(identical(other.onlineUrl, onlineUrl) || other.onlineUrl == onlineUrl)&&(identical(other.startDatetime, startDatetime) || other.startDatetime == startDatetime)&&(identical(other.endDatetime, endDatetime) || other.endDatetime == endDatetime)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.recurrence, recurrence) || other.recurrence == recurrence)&&const DeepCollectionEquality().equals(other._ticketTiers, _ticketTiers)&&const DeepCollectionEquality().equals(other._agenda, _agenda)&&(identical(other.cancellationPolicy, cancellationPolicy) || other.cancellationPolicy == cancellationPolicy)&&(identical(other.earlyBirdEnabled, earlyBirdEnabled) || other.earlyBirdEnabled == earlyBirdEnabled)&&(identical(other.earlyBirdDeadline, earlyBirdDeadline) || other.earlyBirdDeadline == earlyBirdDeadline)&&const DeepCollectionEquality().equals(other._earlyBirdPriceArtifacts, _earlyBirdPriceArtifacts)&&(identical(other.capacity, capacity) || other.capacity == capacity)&&const DeepCollectionEquality().equals(other._ticketPriceArtifacts, _ticketPriceArtifacts)&&(identical(other.isFree, isFree) || other.isFree == isFree)&&(identical(other.isPublished, isPublished) || other.isPublished == isPublished)&&(identical(other.isCancelled, isCancelled) || other.isCancelled == isCancelled)&&(identical(other.attendeeCount, attendeeCount) || other.attendeeCount == attendeeCount)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.category, category) || other.category == category)&&(identical(other.contentRating, contentRating) || other.contentRating == contentRating)&&(identical(other.isRegistered, isRegistered) || other.isRegistered == isRegistered)&&(identical(other.spotsRemaining, spotsRemaining) || other.spotsRemaining == spotsRemaining)&&(identical(other.shopData, shopData) || other.shopData == shopData)&&const DeepCollectionEquality().equals(other._media, _media)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,creatorData,gymData,title,description,coverImageUrl,promoVideoUrl,const DeepCollectionEquality().hash(_galleryUrls),eventType,location,onlineUrl,startDatetime,endDatetime,timezone,recurrence,const DeepCollectionEquality().hash(_ticketTiers),const DeepCollectionEquality().hash(_agenda),cancellationPolicy,earlyBirdEnabled,earlyBirdDeadline,const DeepCollectionEquality().hash(_earlyBirdPriceArtifacts),capacity,const DeepCollectionEquality().hash(_ticketPriceArtifacts),isFree,isPublished,isCancelled,attendeeCount,const DeepCollectionEquality().hash(_tags),category,contentRating,isRegistered,spotsRemaining,shopData,const DeepCollectionEquality().hash(_media),createdAt]);

@override
String toString() {
  return 'MarketplaceEvent(id: $id, creatorData: $creatorData, gymData: $gymData, title: $title, description: $description, coverImageUrl: $coverImageUrl, promoVideoUrl: $promoVideoUrl, galleryUrls: $galleryUrls, eventType: $eventType, location: $location, onlineUrl: $onlineUrl, startDatetime: $startDatetime, endDatetime: $endDatetime, timezone: $timezone, recurrence: $recurrence, ticketTiers: $ticketTiers, agenda: $agenda, cancellationPolicy: $cancellationPolicy, earlyBirdEnabled: $earlyBirdEnabled, earlyBirdDeadline: $earlyBirdDeadline, earlyBirdPriceArtifacts: $earlyBirdPriceArtifacts, capacity: $capacity, ticketPriceArtifacts: $ticketPriceArtifacts, isFree: $isFree, isPublished: $isPublished, isCancelled: $isCancelled, attendeeCount: $attendeeCount, tags: $tags, category: $category, contentRating: $contentRating, isRegistered: $isRegistered, spotsRemaining: $spotsRemaining, shopData: $shopData, media: $media, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$MarketplaceEventCopyWith<$Res> implements $MarketplaceEventCopyWith<$Res> {
  factory _$MarketplaceEventCopyWith(_MarketplaceEvent value, $Res Function(_MarketplaceEvent) _then) = __$MarketplaceEventCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'creator_data') CreatorData creatorData,@JsonKey(name: 'gym_data') GymData? gymData, String title, String description,@JsonKey(name: 'cover_image_url') String coverImageUrl,@JsonKey(name: 'promo_video_url') String promoVideoUrl,@JsonKey(name: 'gallery_urls') List<String> galleryUrls,@JsonKey(name: 'event_type') String eventType, String location,@JsonKey(name: 'online_url') String onlineUrl,@JsonKey(name: 'start_datetime') String startDatetime,@JsonKey(name: 'end_datetime') String endDatetime, String timezone, String recurrence,@JsonKey(name: 'ticket_tiers') List<Map<String, dynamic>> ticketTiers, List<Map<String, dynamic>> agenda, String cancellationPolicy,@JsonKey(name: 'early_bird_enabled') bool earlyBirdEnabled,@JsonKey(name: 'early_bird_deadline') String? earlyBirdDeadline,@JsonKey(name: 'early_bird_price_artifacts') Map<String, int> earlyBirdPriceArtifacts, int capacity,@JsonKey(name: 'ticket_price_artifacts') Map<String, int> ticketPriceArtifacts,@JsonKey(name: 'is_free') bool isFree,@JsonKey(name: 'is_published') bool isPublished,@JsonKey(name: 'is_cancelled') bool isCancelled,@JsonKey(name: 'attendee_count') int attendeeCount, List<String> tags, String category,@JsonKey(name: 'content_rating') String contentRating,@JsonKey(name: 'is_registered') bool isRegistered,@JsonKey(name: 'spots_remaining') int? spotsRemaining,@JsonKey(name: 'shop_data') Shop? shopData, List<EventMediaItem> media,@JsonKey(name: 'created_at') String createdAt
});


@override $CreatorDataCopyWith<$Res> get creatorData;@override $GymDataCopyWith<$Res>? get gymData;@override $ShopCopyWith<$Res>? get shopData;

}
/// @nodoc
class __$MarketplaceEventCopyWithImpl<$Res>
    implements _$MarketplaceEventCopyWith<$Res> {
  __$MarketplaceEventCopyWithImpl(this._self, this._then);

  final _MarketplaceEvent _self;
  final $Res Function(_MarketplaceEvent) _then;

/// Create a copy of MarketplaceEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? creatorData = null,Object? gymData = freezed,Object? title = null,Object? description = null,Object? coverImageUrl = null,Object? promoVideoUrl = null,Object? galleryUrls = null,Object? eventType = null,Object? location = null,Object? onlineUrl = null,Object? startDatetime = null,Object? endDatetime = null,Object? timezone = null,Object? recurrence = null,Object? ticketTiers = null,Object? agenda = null,Object? cancellationPolicy = null,Object? earlyBirdEnabled = null,Object? earlyBirdDeadline = freezed,Object? earlyBirdPriceArtifacts = null,Object? capacity = null,Object? ticketPriceArtifacts = null,Object? isFree = null,Object? isPublished = null,Object? isCancelled = null,Object? attendeeCount = null,Object? tags = null,Object? category = null,Object? contentRating = null,Object? isRegistered = null,Object? spotsRemaining = freezed,Object? shopData = freezed,Object? media = null,Object? createdAt = null,}) {
  return _then(_MarketplaceEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,creatorData: null == creatorData ? _self.creatorData : creatorData // ignore: cast_nullable_to_non_nullable
as CreatorData,gymData: freezed == gymData ? _self.gymData : gymData // ignore: cast_nullable_to_non_nullable
as GymData?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,coverImageUrl: null == coverImageUrl ? _self.coverImageUrl : coverImageUrl // ignore: cast_nullable_to_non_nullable
as String,promoVideoUrl: null == promoVideoUrl ? _self.promoVideoUrl : promoVideoUrl // ignore: cast_nullable_to_non_nullable
as String,galleryUrls: null == galleryUrls ? _self._galleryUrls : galleryUrls // ignore: cast_nullable_to_non_nullable
as List<String>,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,onlineUrl: null == onlineUrl ? _self.onlineUrl : onlineUrl // ignore: cast_nullable_to_non_nullable
as String,startDatetime: null == startDatetime ? _self.startDatetime : startDatetime // ignore: cast_nullable_to_non_nullable
as String,endDatetime: null == endDatetime ? _self.endDatetime : endDatetime // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,recurrence: null == recurrence ? _self.recurrence : recurrence // ignore: cast_nullable_to_non_nullable
as String,ticketTiers: null == ticketTiers ? _self._ticketTiers : ticketTiers // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,agenda: null == agenda ? _self._agenda : agenda // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,cancellationPolicy: null == cancellationPolicy ? _self.cancellationPolicy : cancellationPolicy // ignore: cast_nullable_to_non_nullable
as String,earlyBirdEnabled: null == earlyBirdEnabled ? _self.earlyBirdEnabled : earlyBirdEnabled // ignore: cast_nullable_to_non_nullable
as bool,earlyBirdDeadline: freezed == earlyBirdDeadline ? _self.earlyBirdDeadline : earlyBirdDeadline // ignore: cast_nullable_to_non_nullable
as String?,earlyBirdPriceArtifacts: null == earlyBirdPriceArtifacts ? _self._earlyBirdPriceArtifacts : earlyBirdPriceArtifacts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,capacity: null == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int,ticketPriceArtifacts: null == ticketPriceArtifacts ? _self._ticketPriceArtifacts : ticketPriceArtifacts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,isFree: null == isFree ? _self.isFree : isFree // ignore: cast_nullable_to_non_nullable
as bool,isPublished: null == isPublished ? _self.isPublished : isPublished // ignore: cast_nullable_to_non_nullable
as bool,isCancelled: null == isCancelled ? _self.isCancelled : isCancelled // ignore: cast_nullable_to_non_nullable
as bool,attendeeCount: null == attendeeCount ? _self.attendeeCount : attendeeCount // ignore: cast_nullable_to_non_nullable
as int,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,contentRating: null == contentRating ? _self.contentRating : contentRating // ignore: cast_nullable_to_non_nullable
as String,isRegistered: null == isRegistered ? _self.isRegistered : isRegistered // ignore: cast_nullable_to_non_nullable
as bool,spotsRemaining: freezed == spotsRemaining ? _self.spotsRemaining : spotsRemaining // ignore: cast_nullable_to_non_nullable
as int?,shopData: freezed == shopData ? _self.shopData : shopData // ignore: cast_nullable_to_non_nullable
as Shop?,media: null == media ? _self._media : media // ignore: cast_nullable_to_non_nullable
as List<EventMediaItem>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of MarketplaceEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CreatorDataCopyWith<$Res> get creatorData {
  
  return $CreatorDataCopyWith<$Res>(_self.creatorData, (value) {
    return _then(_self.copyWith(creatorData: value));
  });
}/// Create a copy of MarketplaceEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GymDataCopyWith<$Res>? get gymData {
    if (_self.gymData == null) {
    return null;
  }

  return $GymDataCopyWith<$Res>(_self.gymData!, (value) {
    return _then(_self.copyWith(gymData: value));
  });
}/// Create a copy of MarketplaceEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShopCopyWith<$Res>? get shopData {
    if (_self.shopData == null) {
    return null;
  }

  return $ShopCopyWith<$Res>(_self.shopData!, (value) {
    return _then(_self.copyWith(shopData: value));
  });
}
}


/// @nodoc
mixin _$EventTicket {

 String get id;@JsonKey(name: 'event_data') Map<String, dynamic>? get eventData;@JsonKey(name: 'holder_data') Map<String, dynamic>? get holderData;@JsonKey(name: 'ticket_code') String get ticketCode; String get tier;@JsonKey(name: 'price_paid_artifacts') Map<String, int>? get pricePaidArtifacts; String get status;@JsonKey(name: 'is_checked_in') bool get isCheckedIn;@JsonKey(name: 'checked_in_at') String? get checkedInAt;@JsonKey(name: 'qr_data_uri') String? get qrDataUri;@JsonKey(name: 'created_at') String get createdAt;
/// Create a copy of EventTicket
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventTicketCopyWith<EventTicket> get copyWith => _$EventTicketCopyWithImpl<EventTicket>(this as EventTicket, _$identity);

  /// Serializes this EventTicket to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventTicket&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.eventData, eventData)&&const DeepCollectionEquality().equals(other.holderData, holderData)&&(identical(other.ticketCode, ticketCode) || other.ticketCode == ticketCode)&&(identical(other.tier, tier) || other.tier == tier)&&const DeepCollectionEquality().equals(other.pricePaidArtifacts, pricePaidArtifacts)&&(identical(other.status, status) || other.status == status)&&(identical(other.isCheckedIn, isCheckedIn) || other.isCheckedIn == isCheckedIn)&&(identical(other.checkedInAt, checkedInAt) || other.checkedInAt == checkedInAt)&&(identical(other.qrDataUri, qrDataUri) || other.qrDataUri == qrDataUri)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(eventData),const DeepCollectionEquality().hash(holderData),ticketCode,tier,const DeepCollectionEquality().hash(pricePaidArtifacts),status,isCheckedIn,checkedInAt,qrDataUri,createdAt);

@override
String toString() {
  return 'EventTicket(id: $id, eventData: $eventData, holderData: $holderData, ticketCode: $ticketCode, tier: $tier, pricePaidArtifacts: $pricePaidArtifacts, status: $status, isCheckedIn: $isCheckedIn, checkedInAt: $checkedInAt, qrDataUri: $qrDataUri, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $EventTicketCopyWith<$Res>  {
  factory $EventTicketCopyWith(EventTicket value, $Res Function(EventTicket) _then) = _$EventTicketCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'event_data') Map<String, dynamic>? eventData,@JsonKey(name: 'holder_data') Map<String, dynamic>? holderData,@JsonKey(name: 'ticket_code') String ticketCode, String tier,@JsonKey(name: 'price_paid_artifacts') Map<String, int>? pricePaidArtifacts, String status,@JsonKey(name: 'is_checked_in') bool isCheckedIn,@JsonKey(name: 'checked_in_at') String? checkedInAt,@JsonKey(name: 'qr_data_uri') String? qrDataUri,@JsonKey(name: 'created_at') String createdAt
});




}
/// @nodoc
class _$EventTicketCopyWithImpl<$Res>
    implements $EventTicketCopyWith<$Res> {
  _$EventTicketCopyWithImpl(this._self, this._then);

  final EventTicket _self;
  final $Res Function(EventTicket) _then;

/// Create a copy of EventTicket
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? eventData = freezed,Object? holderData = freezed,Object? ticketCode = null,Object? tier = null,Object? pricePaidArtifacts = freezed,Object? status = null,Object? isCheckedIn = null,Object? checkedInAt = freezed,Object? qrDataUri = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eventData: freezed == eventData ? _self.eventData : eventData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,holderData: freezed == holderData ? _self.holderData : holderData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,ticketCode: null == ticketCode ? _self.ticketCode : ticketCode // ignore: cast_nullable_to_non_nullable
as String,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as String,pricePaidArtifacts: freezed == pricePaidArtifacts ? _self.pricePaidArtifacts : pricePaidArtifacts // ignore: cast_nullable_to_non_nullable
as Map<String, int>?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,isCheckedIn: null == isCheckedIn ? _self.isCheckedIn : isCheckedIn // ignore: cast_nullable_to_non_nullable
as bool,checkedInAt: freezed == checkedInAt ? _self.checkedInAt : checkedInAt // ignore: cast_nullable_to_non_nullable
as String?,qrDataUri: freezed == qrDataUri ? _self.qrDataUri : qrDataUri // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [EventTicket].
extension EventTicketPatterns on EventTicket {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventTicket value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventTicket() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventTicket value)  $default,){
final _that = this;
switch (_that) {
case _EventTicket():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventTicket value)?  $default,){
final _that = this;
switch (_that) {
case _EventTicket() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'event_data')  Map<String, dynamic>? eventData, @JsonKey(name: 'holder_data')  Map<String, dynamic>? holderData, @JsonKey(name: 'ticket_code')  String ticketCode,  String tier, @JsonKey(name: 'price_paid_artifacts')  Map<String, int>? pricePaidArtifacts,  String status, @JsonKey(name: 'is_checked_in')  bool isCheckedIn, @JsonKey(name: 'checked_in_at')  String? checkedInAt, @JsonKey(name: 'qr_data_uri')  String? qrDataUri, @JsonKey(name: 'created_at')  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventTicket() when $default != null:
return $default(_that.id,_that.eventData,_that.holderData,_that.ticketCode,_that.tier,_that.pricePaidArtifacts,_that.status,_that.isCheckedIn,_that.checkedInAt,_that.qrDataUri,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'event_data')  Map<String, dynamic>? eventData, @JsonKey(name: 'holder_data')  Map<String, dynamic>? holderData, @JsonKey(name: 'ticket_code')  String ticketCode,  String tier, @JsonKey(name: 'price_paid_artifacts')  Map<String, int>? pricePaidArtifacts,  String status, @JsonKey(name: 'is_checked_in')  bool isCheckedIn, @JsonKey(name: 'checked_in_at')  String? checkedInAt, @JsonKey(name: 'qr_data_uri')  String? qrDataUri, @JsonKey(name: 'created_at')  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _EventTicket():
return $default(_that.id,_that.eventData,_that.holderData,_that.ticketCode,_that.tier,_that.pricePaidArtifacts,_that.status,_that.isCheckedIn,_that.checkedInAt,_that.qrDataUri,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'event_data')  Map<String, dynamic>? eventData, @JsonKey(name: 'holder_data')  Map<String, dynamic>? holderData, @JsonKey(name: 'ticket_code')  String ticketCode,  String tier, @JsonKey(name: 'price_paid_artifacts')  Map<String, int>? pricePaidArtifacts,  String status, @JsonKey(name: 'is_checked_in')  bool isCheckedIn, @JsonKey(name: 'checked_in_at')  String? checkedInAt, @JsonKey(name: 'qr_data_uri')  String? qrDataUri, @JsonKey(name: 'created_at')  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _EventTicket() when $default != null:
return $default(_that.id,_that.eventData,_that.holderData,_that.ticketCode,_that.tier,_that.pricePaidArtifacts,_that.status,_that.isCheckedIn,_that.checkedInAt,_that.qrDataUri,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventTicket implements EventTicket {
  const _EventTicket({required this.id, @JsonKey(name: 'event_data') final  Map<String, dynamic>? eventData, @JsonKey(name: 'holder_data') final  Map<String, dynamic>? holderData, @JsonKey(name: 'ticket_code') required this.ticketCode, this.tier = '', @JsonKey(name: 'price_paid_artifacts') final  Map<String, int>? pricePaidArtifacts, this.status = 'active', @JsonKey(name: 'is_checked_in') this.isCheckedIn = false, @JsonKey(name: 'checked_in_at') this.checkedInAt, @JsonKey(name: 'qr_data_uri') this.qrDataUri, @JsonKey(name: 'created_at') required this.createdAt}): _eventData = eventData,_holderData = holderData,_pricePaidArtifacts = pricePaidArtifacts;
  factory _EventTicket.fromJson(Map<String, dynamic> json) => _$EventTicketFromJson(json);

@override final  String id;
 final  Map<String, dynamic>? _eventData;
@override@JsonKey(name: 'event_data') Map<String, dynamic>? get eventData {
  final value = _eventData;
  if (value == null) return null;
  if (_eventData is EqualUnmodifiableMapView) return _eventData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _holderData;
@override@JsonKey(name: 'holder_data') Map<String, dynamic>? get holderData {
  final value = _holderData;
  if (value == null) return null;
  if (_holderData is EqualUnmodifiableMapView) return _holderData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey(name: 'ticket_code') final  String ticketCode;
@override@JsonKey() final  String tier;
 final  Map<String, int>? _pricePaidArtifacts;
@override@JsonKey(name: 'price_paid_artifacts') Map<String, int>? get pricePaidArtifacts {
  final value = _pricePaidArtifacts;
  if (value == null) return null;
  if (_pricePaidArtifacts is EqualUnmodifiableMapView) return _pricePaidArtifacts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey() final  String status;
@override@JsonKey(name: 'is_checked_in') final  bool isCheckedIn;
@override@JsonKey(name: 'checked_in_at') final  String? checkedInAt;
@override@JsonKey(name: 'qr_data_uri') final  String? qrDataUri;
@override@JsonKey(name: 'created_at') final  String createdAt;

/// Create a copy of EventTicket
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventTicketCopyWith<_EventTicket> get copyWith => __$EventTicketCopyWithImpl<_EventTicket>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventTicketToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventTicket&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._eventData, _eventData)&&const DeepCollectionEquality().equals(other._holderData, _holderData)&&(identical(other.ticketCode, ticketCode) || other.ticketCode == ticketCode)&&(identical(other.tier, tier) || other.tier == tier)&&const DeepCollectionEquality().equals(other._pricePaidArtifacts, _pricePaidArtifacts)&&(identical(other.status, status) || other.status == status)&&(identical(other.isCheckedIn, isCheckedIn) || other.isCheckedIn == isCheckedIn)&&(identical(other.checkedInAt, checkedInAt) || other.checkedInAt == checkedInAt)&&(identical(other.qrDataUri, qrDataUri) || other.qrDataUri == qrDataUri)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_eventData),const DeepCollectionEquality().hash(_holderData),ticketCode,tier,const DeepCollectionEquality().hash(_pricePaidArtifacts),status,isCheckedIn,checkedInAt,qrDataUri,createdAt);

@override
String toString() {
  return 'EventTicket(id: $id, eventData: $eventData, holderData: $holderData, ticketCode: $ticketCode, tier: $tier, pricePaidArtifacts: $pricePaidArtifacts, status: $status, isCheckedIn: $isCheckedIn, checkedInAt: $checkedInAt, qrDataUri: $qrDataUri, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$EventTicketCopyWith<$Res> implements $EventTicketCopyWith<$Res> {
  factory _$EventTicketCopyWith(_EventTicket value, $Res Function(_EventTicket) _then) = __$EventTicketCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'event_data') Map<String, dynamic>? eventData,@JsonKey(name: 'holder_data') Map<String, dynamic>? holderData,@JsonKey(name: 'ticket_code') String ticketCode, String tier,@JsonKey(name: 'price_paid_artifacts') Map<String, int>? pricePaidArtifacts, String status,@JsonKey(name: 'is_checked_in') bool isCheckedIn,@JsonKey(name: 'checked_in_at') String? checkedInAt,@JsonKey(name: 'qr_data_uri') String? qrDataUri,@JsonKey(name: 'created_at') String createdAt
});




}
/// @nodoc
class __$EventTicketCopyWithImpl<$Res>
    implements _$EventTicketCopyWith<$Res> {
  __$EventTicketCopyWithImpl(this._self, this._then);

  final _EventTicket _self;
  final $Res Function(_EventTicket) _then;

/// Create a copy of EventTicket
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? eventData = freezed,Object? holderData = freezed,Object? ticketCode = null,Object? tier = null,Object? pricePaidArtifacts = freezed,Object? status = null,Object? isCheckedIn = null,Object? checkedInAt = freezed,Object? qrDataUri = freezed,Object? createdAt = null,}) {
  return _then(_EventTicket(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eventData: freezed == eventData ? _self._eventData : eventData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,holderData: freezed == holderData ? _self._holderData : holderData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,ticketCode: null == ticketCode ? _self.ticketCode : ticketCode // ignore: cast_nullable_to_non_nullable
as String,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as String,pricePaidArtifacts: freezed == pricePaidArtifacts ? _self._pricePaidArtifacts : pricePaidArtifacts // ignore: cast_nullable_to_non_nullable
as Map<String, int>?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,isCheckedIn: null == isCheckedIn ? _self.isCheckedIn : isCheckedIn // ignore: cast_nullable_to_non_nullable
as bool,checkedInAt: freezed == checkedInAt ? _self.checkedInAt : checkedInAt // ignore: cast_nullable_to_non_nullable
as String?,qrDataUri: freezed == qrDataUri ? _self.qrDataUri : qrDataUri // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CartItem {

 String get id;@JsonKey(name: 'item_type') String get itemType;@JsonKey(name: 'meal_plan') MealPlan? get mealPlan; TrainingProgramme? get programme;@JsonKey(name: 'product') MarketplaceProduct? get product; MarketplaceEvent? get event; int get quantity;@JsonKey(name: 'item_total_artifacts') Map<String, int> get itemTotalArtifacts;@JsonKey(name: 'item_total_usd') double get itemTotalUsd;
/// Create a copy of CartItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartItemCopyWith<CartItem> get copyWith => _$CartItemCopyWithImpl<CartItem>(this as CartItem, _$identity);

  /// Serializes this CartItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CartItem&&(identical(other.id, id) || other.id == id)&&(identical(other.itemType, itemType) || other.itemType == itemType)&&(identical(other.mealPlan, mealPlan) || other.mealPlan == mealPlan)&&(identical(other.programme, programme) || other.programme == programme)&&(identical(other.product, product) || other.product == product)&&(identical(other.event, event) || other.event == event)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&const DeepCollectionEquality().equals(other.itemTotalArtifacts, itemTotalArtifacts)&&(identical(other.itemTotalUsd, itemTotalUsd) || other.itemTotalUsd == itemTotalUsd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,itemType,mealPlan,programme,product,event,quantity,const DeepCollectionEquality().hash(itemTotalArtifacts),itemTotalUsd);

@override
String toString() {
  return 'CartItem(id: $id, itemType: $itemType, mealPlan: $mealPlan, programme: $programme, product: $product, event: $event, quantity: $quantity, itemTotalArtifacts: $itemTotalArtifacts, itemTotalUsd: $itemTotalUsd)';
}


}

/// @nodoc
abstract mixin class $CartItemCopyWith<$Res>  {
  factory $CartItemCopyWith(CartItem value, $Res Function(CartItem) _then) = _$CartItemCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'item_type') String itemType,@JsonKey(name: 'meal_plan') MealPlan? mealPlan, TrainingProgramme? programme,@JsonKey(name: 'product') MarketplaceProduct? product, MarketplaceEvent? event, int quantity,@JsonKey(name: 'item_total_artifacts') Map<String, int> itemTotalArtifacts,@JsonKey(name: 'item_total_usd') double itemTotalUsd
});


$MealPlanCopyWith<$Res>? get mealPlan;$TrainingProgrammeCopyWith<$Res>? get programme;$MarketplaceProductCopyWith<$Res>? get product;$MarketplaceEventCopyWith<$Res>? get event;

}
/// @nodoc
class _$CartItemCopyWithImpl<$Res>
    implements $CartItemCopyWith<$Res> {
  _$CartItemCopyWithImpl(this._self, this._then);

  final CartItem _self;
  final $Res Function(CartItem) _then;

/// Create a copy of CartItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? itemType = null,Object? mealPlan = freezed,Object? programme = freezed,Object? product = freezed,Object? event = freezed,Object? quantity = null,Object? itemTotalArtifacts = null,Object? itemTotalUsd = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,itemType: null == itemType ? _self.itemType : itemType // ignore: cast_nullable_to_non_nullable
as String,mealPlan: freezed == mealPlan ? _self.mealPlan : mealPlan // ignore: cast_nullable_to_non_nullable
as MealPlan?,programme: freezed == programme ? _self.programme : programme // ignore: cast_nullable_to_non_nullable
as TrainingProgramme?,product: freezed == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as MarketplaceProduct?,event: freezed == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as MarketplaceEvent?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,itemTotalArtifacts: null == itemTotalArtifacts ? _self.itemTotalArtifacts : itemTotalArtifacts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,itemTotalUsd: null == itemTotalUsd ? _self.itemTotalUsd : itemTotalUsd // ignore: cast_nullable_to_non_nullable
as double,
  ));
}
/// Create a copy of CartItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MealPlanCopyWith<$Res>? get mealPlan {
    if (_self.mealPlan == null) {
    return null;
  }

  return $MealPlanCopyWith<$Res>(_self.mealPlan!, (value) {
    return _then(_self.copyWith(mealPlan: value));
  });
}/// Create a copy of CartItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrainingProgrammeCopyWith<$Res>? get programme {
    if (_self.programme == null) {
    return null;
  }

  return $TrainingProgrammeCopyWith<$Res>(_self.programme!, (value) {
    return _then(_self.copyWith(programme: value));
  });
}/// Create a copy of CartItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MarketplaceProductCopyWith<$Res>? get product {
    if (_self.product == null) {
    return null;
  }

  return $MarketplaceProductCopyWith<$Res>(_self.product!, (value) {
    return _then(_self.copyWith(product: value));
  });
}/// Create a copy of CartItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MarketplaceEventCopyWith<$Res>? get event {
    if (_self.event == null) {
    return null;
  }

  return $MarketplaceEventCopyWith<$Res>(_self.event!, (value) {
    return _then(_self.copyWith(event: value));
  });
}
}


/// Adds pattern-matching-related methods to [CartItem].
extension CartItemPatterns on CartItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CartItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CartItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CartItem value)  $default,){
final _that = this;
switch (_that) {
case _CartItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CartItem value)?  $default,){
final _that = this;
switch (_that) {
case _CartItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'item_type')  String itemType, @JsonKey(name: 'meal_plan')  MealPlan? mealPlan,  TrainingProgramme? programme, @JsonKey(name: 'product')  MarketplaceProduct? product,  MarketplaceEvent? event,  int quantity, @JsonKey(name: 'item_total_artifacts')  Map<String, int> itemTotalArtifacts, @JsonKey(name: 'item_total_usd')  double itemTotalUsd)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CartItem() when $default != null:
return $default(_that.id,_that.itemType,_that.mealPlan,_that.programme,_that.product,_that.event,_that.quantity,_that.itemTotalArtifacts,_that.itemTotalUsd);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'item_type')  String itemType, @JsonKey(name: 'meal_plan')  MealPlan? mealPlan,  TrainingProgramme? programme, @JsonKey(name: 'product')  MarketplaceProduct? product,  MarketplaceEvent? event,  int quantity, @JsonKey(name: 'item_total_artifacts')  Map<String, int> itemTotalArtifacts, @JsonKey(name: 'item_total_usd')  double itemTotalUsd)  $default,) {final _that = this;
switch (_that) {
case _CartItem():
return $default(_that.id,_that.itemType,_that.mealPlan,_that.programme,_that.product,_that.event,_that.quantity,_that.itemTotalArtifacts,_that.itemTotalUsd);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'item_type')  String itemType, @JsonKey(name: 'meal_plan')  MealPlan? mealPlan,  TrainingProgramme? programme, @JsonKey(name: 'product')  MarketplaceProduct? product,  MarketplaceEvent? event,  int quantity, @JsonKey(name: 'item_total_artifacts')  Map<String, int> itemTotalArtifacts, @JsonKey(name: 'item_total_usd')  double itemTotalUsd)?  $default,) {final _that = this;
switch (_that) {
case _CartItem() when $default != null:
return $default(_that.id,_that.itemType,_that.mealPlan,_that.programme,_that.product,_that.event,_that.quantity,_that.itemTotalArtifacts,_that.itemTotalUsd);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CartItem implements CartItem {
  const _CartItem({required this.id, @JsonKey(name: 'item_type') required this.itemType, @JsonKey(name: 'meal_plan') this.mealPlan, this.programme, @JsonKey(name: 'product') this.product, this.event, this.quantity = 1, @JsonKey(name: 'item_total_artifacts') final  Map<String, int> itemTotalArtifacts = const <String, int>{}, @JsonKey(name: 'item_total_usd') this.itemTotalUsd = 0.0}): _itemTotalArtifacts = itemTotalArtifacts;
  factory _CartItem.fromJson(Map<String, dynamic> json) => _$CartItemFromJson(json);

@override final  String id;
@override@JsonKey(name: 'item_type') final  String itemType;
@override@JsonKey(name: 'meal_plan') final  MealPlan? mealPlan;
@override final  TrainingProgramme? programme;
@override@JsonKey(name: 'product') final  MarketplaceProduct? product;
@override final  MarketplaceEvent? event;
@override@JsonKey() final  int quantity;
 final  Map<String, int> _itemTotalArtifacts;
@override@JsonKey(name: 'item_total_artifacts') Map<String, int> get itemTotalArtifacts {
  if (_itemTotalArtifacts is EqualUnmodifiableMapView) return _itemTotalArtifacts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_itemTotalArtifacts);
}

@override@JsonKey(name: 'item_total_usd') final  double itemTotalUsd;

/// Create a copy of CartItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CartItemCopyWith<_CartItem> get copyWith => __$CartItemCopyWithImpl<_CartItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CartItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CartItem&&(identical(other.id, id) || other.id == id)&&(identical(other.itemType, itemType) || other.itemType == itemType)&&(identical(other.mealPlan, mealPlan) || other.mealPlan == mealPlan)&&(identical(other.programme, programme) || other.programme == programme)&&(identical(other.product, product) || other.product == product)&&(identical(other.event, event) || other.event == event)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&const DeepCollectionEquality().equals(other._itemTotalArtifacts, _itemTotalArtifacts)&&(identical(other.itemTotalUsd, itemTotalUsd) || other.itemTotalUsd == itemTotalUsd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,itemType,mealPlan,programme,product,event,quantity,const DeepCollectionEquality().hash(_itemTotalArtifacts),itemTotalUsd);

@override
String toString() {
  return 'CartItem(id: $id, itemType: $itemType, mealPlan: $mealPlan, programme: $programme, product: $product, event: $event, quantity: $quantity, itemTotalArtifacts: $itemTotalArtifacts, itemTotalUsd: $itemTotalUsd)';
}


}

/// @nodoc
abstract mixin class _$CartItemCopyWith<$Res> implements $CartItemCopyWith<$Res> {
  factory _$CartItemCopyWith(_CartItem value, $Res Function(_CartItem) _then) = __$CartItemCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'item_type') String itemType,@JsonKey(name: 'meal_plan') MealPlan? mealPlan, TrainingProgramme? programme,@JsonKey(name: 'product') MarketplaceProduct? product, MarketplaceEvent? event, int quantity,@JsonKey(name: 'item_total_artifacts') Map<String, int> itemTotalArtifacts,@JsonKey(name: 'item_total_usd') double itemTotalUsd
});


@override $MealPlanCopyWith<$Res>? get mealPlan;@override $TrainingProgrammeCopyWith<$Res>? get programme;@override $MarketplaceProductCopyWith<$Res>? get product;@override $MarketplaceEventCopyWith<$Res>? get event;

}
/// @nodoc
class __$CartItemCopyWithImpl<$Res>
    implements _$CartItemCopyWith<$Res> {
  __$CartItemCopyWithImpl(this._self, this._then);

  final _CartItem _self;
  final $Res Function(_CartItem) _then;

/// Create a copy of CartItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? itemType = null,Object? mealPlan = freezed,Object? programme = freezed,Object? product = freezed,Object? event = freezed,Object? quantity = null,Object? itemTotalArtifacts = null,Object? itemTotalUsd = null,}) {
  return _then(_CartItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,itemType: null == itemType ? _self.itemType : itemType // ignore: cast_nullable_to_non_nullable
as String,mealPlan: freezed == mealPlan ? _self.mealPlan : mealPlan // ignore: cast_nullable_to_non_nullable
as MealPlan?,programme: freezed == programme ? _self.programme : programme // ignore: cast_nullable_to_non_nullable
as TrainingProgramme?,product: freezed == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as MarketplaceProduct?,event: freezed == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as MarketplaceEvent?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,itemTotalArtifacts: null == itemTotalArtifacts ? _self._itemTotalArtifacts : itemTotalArtifacts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,itemTotalUsd: null == itemTotalUsd ? _self.itemTotalUsd : itemTotalUsd // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

/// Create a copy of CartItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MealPlanCopyWith<$Res>? get mealPlan {
    if (_self.mealPlan == null) {
    return null;
  }

  return $MealPlanCopyWith<$Res>(_self.mealPlan!, (value) {
    return _then(_self.copyWith(mealPlan: value));
  });
}/// Create a copy of CartItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrainingProgrammeCopyWith<$Res>? get programme {
    if (_self.programme == null) {
    return null;
  }

  return $TrainingProgrammeCopyWith<$Res>(_self.programme!, (value) {
    return _then(_self.copyWith(programme: value));
  });
}/// Create a copy of CartItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MarketplaceProductCopyWith<$Res>? get product {
    if (_self.product == null) {
    return null;
  }

  return $MarketplaceProductCopyWith<$Res>(_self.product!, (value) {
    return _then(_self.copyWith(product: value));
  });
}/// Create a copy of CartItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MarketplaceEventCopyWith<$Res>? get event {
    if (_self.event == null) {
    return null;
  }

  return $MarketplaceEventCopyWith<$Res>(_self.event!, (value) {
    return _then(_self.copyWith(event: value));
  });
}
}


/// @nodoc
mixin _$Cart {

 String get id; List<CartItem> get items;@JsonKey(name: 'discount_code') DiscountCode? get discountCode;@JsonKey(name: 'total_artifacts') Map<String, int> get totalArtifacts;@JsonKey(name: 'total_usd') double get totalUsd;@JsonKey(name: 'total_local_currency') double get totalLocalCurrency;@JsonKey(name: 'base_currency') String get baseCurrency;@JsonKey(name: 'local_currency') String get localCurrency;@JsonKey(name: 'conversion_rate') double get conversionRate;@JsonKey(name: 'created_at') String get createdAt;
/// Create a copy of Cart
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartCopyWith<Cart> get copyWith => _$CartCopyWithImpl<Cart>(this as Cart, _$identity);

  /// Serializes this Cart to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Cart&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.discountCode, discountCode) || other.discountCode == discountCode)&&const DeepCollectionEquality().equals(other.totalArtifacts, totalArtifacts)&&(identical(other.totalUsd, totalUsd) || other.totalUsd == totalUsd)&&(identical(other.totalLocalCurrency, totalLocalCurrency) || other.totalLocalCurrency == totalLocalCurrency)&&(identical(other.baseCurrency, baseCurrency) || other.baseCurrency == baseCurrency)&&(identical(other.localCurrency, localCurrency) || other.localCurrency == localCurrency)&&(identical(other.conversionRate, conversionRate) || other.conversionRate == conversionRate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(items),discountCode,const DeepCollectionEquality().hash(totalArtifacts),totalUsd,totalLocalCurrency,baseCurrency,localCurrency,conversionRate,createdAt);

@override
String toString() {
  return 'Cart(id: $id, items: $items, discountCode: $discountCode, totalArtifacts: $totalArtifacts, totalUsd: $totalUsd, totalLocalCurrency: $totalLocalCurrency, baseCurrency: $baseCurrency, localCurrency: $localCurrency, conversionRate: $conversionRate, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $CartCopyWith<$Res>  {
  factory $CartCopyWith(Cart value, $Res Function(Cart) _then) = _$CartCopyWithImpl;
@useResult
$Res call({
 String id, List<CartItem> items,@JsonKey(name: 'discount_code') DiscountCode? discountCode,@JsonKey(name: 'total_artifacts') Map<String, int> totalArtifacts,@JsonKey(name: 'total_usd') double totalUsd,@JsonKey(name: 'total_local_currency') double totalLocalCurrency,@JsonKey(name: 'base_currency') String baseCurrency,@JsonKey(name: 'local_currency') String localCurrency,@JsonKey(name: 'conversion_rate') double conversionRate,@JsonKey(name: 'created_at') String createdAt
});


$DiscountCodeCopyWith<$Res>? get discountCode;

}
/// @nodoc
class _$CartCopyWithImpl<$Res>
    implements $CartCopyWith<$Res> {
  _$CartCopyWithImpl(this._self, this._then);

  final Cart _self;
  final $Res Function(Cart) _then;

/// Create a copy of Cart
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? items = null,Object? discountCode = freezed,Object? totalArtifacts = null,Object? totalUsd = null,Object? totalLocalCurrency = null,Object? baseCurrency = null,Object? localCurrency = null,Object? conversionRate = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<CartItem>,discountCode: freezed == discountCode ? _self.discountCode : discountCode // ignore: cast_nullable_to_non_nullable
as DiscountCode?,totalArtifacts: null == totalArtifacts ? _self.totalArtifacts : totalArtifacts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,totalUsd: null == totalUsd ? _self.totalUsd : totalUsd // ignore: cast_nullable_to_non_nullable
as double,totalLocalCurrency: null == totalLocalCurrency ? _self.totalLocalCurrency : totalLocalCurrency // ignore: cast_nullable_to_non_nullable
as double,baseCurrency: null == baseCurrency ? _self.baseCurrency : baseCurrency // ignore: cast_nullable_to_non_nullable
as String,localCurrency: null == localCurrency ? _self.localCurrency : localCurrency // ignore: cast_nullable_to_non_nullable
as String,conversionRate: null == conversionRate ? _self.conversionRate : conversionRate // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of Cart
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DiscountCodeCopyWith<$Res>? get discountCode {
    if (_self.discountCode == null) {
    return null;
  }

  return $DiscountCodeCopyWith<$Res>(_self.discountCode!, (value) {
    return _then(_self.copyWith(discountCode: value));
  });
}
}


/// Adds pattern-matching-related methods to [Cart].
extension CartPatterns on Cart {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Cart value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Cart() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Cart value)  $default,){
final _that = this;
switch (_that) {
case _Cart():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Cart value)?  $default,){
final _that = this;
switch (_that) {
case _Cart() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  List<CartItem> items, @JsonKey(name: 'discount_code')  DiscountCode? discountCode, @JsonKey(name: 'total_artifacts')  Map<String, int> totalArtifacts, @JsonKey(name: 'total_usd')  double totalUsd, @JsonKey(name: 'total_local_currency')  double totalLocalCurrency, @JsonKey(name: 'base_currency')  String baseCurrency, @JsonKey(name: 'local_currency')  String localCurrency, @JsonKey(name: 'conversion_rate')  double conversionRate, @JsonKey(name: 'created_at')  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Cart() when $default != null:
return $default(_that.id,_that.items,_that.discountCode,_that.totalArtifacts,_that.totalUsd,_that.totalLocalCurrency,_that.baseCurrency,_that.localCurrency,_that.conversionRate,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  List<CartItem> items, @JsonKey(name: 'discount_code')  DiscountCode? discountCode, @JsonKey(name: 'total_artifacts')  Map<String, int> totalArtifacts, @JsonKey(name: 'total_usd')  double totalUsd, @JsonKey(name: 'total_local_currency')  double totalLocalCurrency, @JsonKey(name: 'base_currency')  String baseCurrency, @JsonKey(name: 'local_currency')  String localCurrency, @JsonKey(name: 'conversion_rate')  double conversionRate, @JsonKey(name: 'created_at')  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _Cart():
return $default(_that.id,_that.items,_that.discountCode,_that.totalArtifacts,_that.totalUsd,_that.totalLocalCurrency,_that.baseCurrency,_that.localCurrency,_that.conversionRate,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  List<CartItem> items, @JsonKey(name: 'discount_code')  DiscountCode? discountCode, @JsonKey(name: 'total_artifacts')  Map<String, int> totalArtifacts, @JsonKey(name: 'total_usd')  double totalUsd, @JsonKey(name: 'total_local_currency')  double totalLocalCurrency, @JsonKey(name: 'base_currency')  String baseCurrency, @JsonKey(name: 'local_currency')  String localCurrency, @JsonKey(name: 'conversion_rate')  double conversionRate, @JsonKey(name: 'created_at')  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Cart() when $default != null:
return $default(_that.id,_that.items,_that.discountCode,_that.totalArtifacts,_that.totalUsd,_that.totalLocalCurrency,_that.baseCurrency,_that.localCurrency,_that.conversionRate,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Cart implements Cart {
  const _Cart({required this.id, required final  List<CartItem> items, @JsonKey(name: 'discount_code') this.discountCode, @JsonKey(name: 'total_artifacts') final  Map<String, int> totalArtifacts = const <String, int>{}, @JsonKey(name: 'total_usd') this.totalUsd = 0.0, @JsonKey(name: 'total_local_currency') this.totalLocalCurrency = 0.0, @JsonKey(name: 'base_currency') this.baseCurrency = 'USD', @JsonKey(name: 'local_currency') this.localCurrency = 'KES', @JsonKey(name: 'conversion_rate') this.conversionRate = 129.5, @JsonKey(name: 'created_at') required this.createdAt}): _items = items,_totalArtifacts = totalArtifacts;
  factory _Cart.fromJson(Map<String, dynamic> json) => _$CartFromJson(json);

@override final  String id;
 final  List<CartItem> _items;
@override List<CartItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey(name: 'discount_code') final  DiscountCode? discountCode;
 final  Map<String, int> _totalArtifacts;
@override@JsonKey(name: 'total_artifacts') Map<String, int> get totalArtifacts {
  if (_totalArtifacts is EqualUnmodifiableMapView) return _totalArtifacts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_totalArtifacts);
}

@override@JsonKey(name: 'total_usd') final  double totalUsd;
@override@JsonKey(name: 'total_local_currency') final  double totalLocalCurrency;
@override@JsonKey(name: 'base_currency') final  String baseCurrency;
@override@JsonKey(name: 'local_currency') final  String localCurrency;
@override@JsonKey(name: 'conversion_rate') final  double conversionRate;
@override@JsonKey(name: 'created_at') final  String createdAt;

/// Create a copy of Cart
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CartCopyWith<_Cart> get copyWith => __$CartCopyWithImpl<_Cart>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CartToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Cart&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.discountCode, discountCode) || other.discountCode == discountCode)&&const DeepCollectionEquality().equals(other._totalArtifacts, _totalArtifacts)&&(identical(other.totalUsd, totalUsd) || other.totalUsd == totalUsd)&&(identical(other.totalLocalCurrency, totalLocalCurrency) || other.totalLocalCurrency == totalLocalCurrency)&&(identical(other.baseCurrency, baseCurrency) || other.baseCurrency == baseCurrency)&&(identical(other.localCurrency, localCurrency) || other.localCurrency == localCurrency)&&(identical(other.conversionRate, conversionRate) || other.conversionRate == conversionRate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_items),discountCode,const DeepCollectionEquality().hash(_totalArtifacts),totalUsd,totalLocalCurrency,baseCurrency,localCurrency,conversionRate,createdAt);

@override
String toString() {
  return 'Cart(id: $id, items: $items, discountCode: $discountCode, totalArtifacts: $totalArtifacts, totalUsd: $totalUsd, totalLocalCurrency: $totalLocalCurrency, baseCurrency: $baseCurrency, localCurrency: $localCurrency, conversionRate: $conversionRate, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$CartCopyWith<$Res> implements $CartCopyWith<$Res> {
  factory _$CartCopyWith(_Cart value, $Res Function(_Cart) _then) = __$CartCopyWithImpl;
@override @useResult
$Res call({
 String id, List<CartItem> items,@JsonKey(name: 'discount_code') DiscountCode? discountCode,@JsonKey(name: 'total_artifacts') Map<String, int> totalArtifacts,@JsonKey(name: 'total_usd') double totalUsd,@JsonKey(name: 'total_local_currency') double totalLocalCurrency,@JsonKey(name: 'base_currency') String baseCurrency,@JsonKey(name: 'local_currency') String localCurrency,@JsonKey(name: 'conversion_rate') double conversionRate,@JsonKey(name: 'created_at') String createdAt
});


@override $DiscountCodeCopyWith<$Res>? get discountCode;

}
/// @nodoc
class __$CartCopyWithImpl<$Res>
    implements _$CartCopyWith<$Res> {
  __$CartCopyWithImpl(this._self, this._then);

  final _Cart _self;
  final $Res Function(_Cart) _then;

/// Create a copy of Cart
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? items = null,Object? discountCode = freezed,Object? totalArtifacts = null,Object? totalUsd = null,Object? totalLocalCurrency = null,Object? baseCurrency = null,Object? localCurrency = null,Object? conversionRate = null,Object? createdAt = null,}) {
  return _then(_Cart(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CartItem>,discountCode: freezed == discountCode ? _self.discountCode : discountCode // ignore: cast_nullable_to_non_nullable
as DiscountCode?,totalArtifacts: null == totalArtifacts ? _self._totalArtifacts : totalArtifacts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,totalUsd: null == totalUsd ? _self.totalUsd : totalUsd // ignore: cast_nullable_to_non_nullable
as double,totalLocalCurrency: null == totalLocalCurrency ? _self.totalLocalCurrency : totalLocalCurrency // ignore: cast_nullable_to_non_nullable
as double,baseCurrency: null == baseCurrency ? _self.baseCurrency : baseCurrency // ignore: cast_nullable_to_non_nullable
as String,localCurrency: null == localCurrency ? _self.localCurrency : localCurrency // ignore: cast_nullable_to_non_nullable
as String,conversionRate: null == conversionRate ? _self.conversionRate : conversionRate // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of Cart
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DiscountCodeCopyWith<$Res>? get discountCode {
    if (_self.discountCode == null) {
    return null;
  }

  return $DiscountCodeCopyWith<$Res>(_self.discountCode!, (value) {
    return _then(_self.copyWith(discountCode: value));
  });
}
}


/// @nodoc
mixin _$DiscountCode {

 String get id; String get creator; String get code;@JsonKey(name: 'discount_type') String get discountType;@JsonKey(name: 'discount_pct') int get discountPct;@JsonKey(name: 'discount_artifacts') Map<String, int> get discountArtifacts;@JsonKey(name: 'code_type') String get codeType;@JsonKey(name: 'qr_code') String? get qrCode; String get description; String get campaign;@JsonKey(name: 'valid_from') String? get validFrom;@JsonKey(name: 'valid_until') String? get validUntil;@JsonKey(name: 'usage_limit') int get usageLimit;@JsonKey(name: 'max_uses_per_user') int get maxUsesPerUser;@JsonKey(name: 'times_used') int get timesUsed;@JsonKey(name: 'min_purchase_artifacts') Map<String, int> get minPurchaseArtifacts;@JsonKey(name: 'is_active') bool get isActive;@JsonKey(name: 'is_retired') bool get isRetired;@JsonKey(name: 'retired_at') String? get retiredAt;@JsonKey(name: 'retired_reason') String get retiredReason;@JsonKey(name: 'share_count') int get shareCount;@JsonKey(name: 'usage_count') int get usageCount;@JsonKey(name: 'is_expired') bool get isExpired;@JsonKey(name: 'created_at') String get createdAt;@JsonKey(name: 'updated_at') String get updatedAt;
/// Create a copy of DiscountCode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiscountCodeCopyWith<DiscountCode> get copyWith => _$DiscountCodeCopyWithImpl<DiscountCode>(this as DiscountCode, _$identity);

  /// Serializes this DiscountCode to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiscountCode&&(identical(other.id, id) || other.id == id)&&(identical(other.creator, creator) || other.creator == creator)&&(identical(other.code, code) || other.code == code)&&(identical(other.discountType, discountType) || other.discountType == discountType)&&(identical(other.discountPct, discountPct) || other.discountPct == discountPct)&&const DeepCollectionEquality().equals(other.discountArtifacts, discountArtifacts)&&(identical(other.codeType, codeType) || other.codeType == codeType)&&(identical(other.qrCode, qrCode) || other.qrCode == qrCode)&&(identical(other.description, description) || other.description == description)&&(identical(other.campaign, campaign) || other.campaign == campaign)&&(identical(other.validFrom, validFrom) || other.validFrom == validFrom)&&(identical(other.validUntil, validUntil) || other.validUntil == validUntil)&&(identical(other.usageLimit, usageLimit) || other.usageLimit == usageLimit)&&(identical(other.maxUsesPerUser, maxUsesPerUser) || other.maxUsesPerUser == maxUsesPerUser)&&(identical(other.timesUsed, timesUsed) || other.timesUsed == timesUsed)&&const DeepCollectionEquality().equals(other.minPurchaseArtifacts, minPurchaseArtifacts)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isRetired, isRetired) || other.isRetired == isRetired)&&(identical(other.retiredAt, retiredAt) || other.retiredAt == retiredAt)&&(identical(other.retiredReason, retiredReason) || other.retiredReason == retiredReason)&&(identical(other.shareCount, shareCount) || other.shareCount == shareCount)&&(identical(other.usageCount, usageCount) || other.usageCount == usageCount)&&(identical(other.isExpired, isExpired) || other.isExpired == isExpired)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,creator,code,discountType,discountPct,const DeepCollectionEquality().hash(discountArtifacts),codeType,qrCode,description,campaign,validFrom,validUntil,usageLimit,maxUsesPerUser,timesUsed,const DeepCollectionEquality().hash(minPurchaseArtifacts),isActive,isRetired,retiredAt,retiredReason,shareCount,usageCount,isExpired,createdAt,updatedAt]);

@override
String toString() {
  return 'DiscountCode(id: $id, creator: $creator, code: $code, discountType: $discountType, discountPct: $discountPct, discountArtifacts: $discountArtifacts, codeType: $codeType, qrCode: $qrCode, description: $description, campaign: $campaign, validFrom: $validFrom, validUntil: $validUntil, usageLimit: $usageLimit, maxUsesPerUser: $maxUsesPerUser, timesUsed: $timesUsed, minPurchaseArtifacts: $minPurchaseArtifacts, isActive: $isActive, isRetired: $isRetired, retiredAt: $retiredAt, retiredReason: $retiredReason, shareCount: $shareCount, usageCount: $usageCount, isExpired: $isExpired, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $DiscountCodeCopyWith<$Res>  {
  factory $DiscountCodeCopyWith(DiscountCode value, $Res Function(DiscountCode) _then) = _$DiscountCodeCopyWithImpl;
@useResult
$Res call({
 String id, String creator, String code,@JsonKey(name: 'discount_type') String discountType,@JsonKey(name: 'discount_pct') int discountPct,@JsonKey(name: 'discount_artifacts') Map<String, int> discountArtifacts,@JsonKey(name: 'code_type') String codeType,@JsonKey(name: 'qr_code') String? qrCode, String description, String campaign,@JsonKey(name: 'valid_from') String? validFrom,@JsonKey(name: 'valid_until') String? validUntil,@JsonKey(name: 'usage_limit') int usageLimit,@JsonKey(name: 'max_uses_per_user') int maxUsesPerUser,@JsonKey(name: 'times_used') int timesUsed,@JsonKey(name: 'min_purchase_artifacts') Map<String, int> minPurchaseArtifacts,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'is_retired') bool isRetired,@JsonKey(name: 'retired_at') String? retiredAt,@JsonKey(name: 'retired_reason') String retiredReason,@JsonKey(name: 'share_count') int shareCount,@JsonKey(name: 'usage_count') int usageCount,@JsonKey(name: 'is_expired') bool isExpired,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt
});




}
/// @nodoc
class _$DiscountCodeCopyWithImpl<$Res>
    implements $DiscountCodeCopyWith<$Res> {
  _$DiscountCodeCopyWithImpl(this._self, this._then);

  final DiscountCode _self;
  final $Res Function(DiscountCode) _then;

/// Create a copy of DiscountCode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? creator = null,Object? code = null,Object? discountType = null,Object? discountPct = null,Object? discountArtifacts = null,Object? codeType = null,Object? qrCode = freezed,Object? description = null,Object? campaign = null,Object? validFrom = freezed,Object? validUntil = freezed,Object? usageLimit = null,Object? maxUsesPerUser = null,Object? timesUsed = null,Object? minPurchaseArtifacts = null,Object? isActive = null,Object? isRetired = null,Object? retiredAt = freezed,Object? retiredReason = null,Object? shareCount = null,Object? usageCount = null,Object? isExpired = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,creator: null == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,discountType: null == discountType ? _self.discountType : discountType // ignore: cast_nullable_to_non_nullable
as String,discountPct: null == discountPct ? _self.discountPct : discountPct // ignore: cast_nullable_to_non_nullable
as int,discountArtifacts: null == discountArtifacts ? _self.discountArtifacts : discountArtifacts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,codeType: null == codeType ? _self.codeType : codeType // ignore: cast_nullable_to_non_nullable
as String,qrCode: freezed == qrCode ? _self.qrCode : qrCode // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,campaign: null == campaign ? _self.campaign : campaign // ignore: cast_nullable_to_non_nullable
as String,validFrom: freezed == validFrom ? _self.validFrom : validFrom // ignore: cast_nullable_to_non_nullable
as String?,validUntil: freezed == validUntil ? _self.validUntil : validUntil // ignore: cast_nullable_to_non_nullable
as String?,usageLimit: null == usageLimit ? _self.usageLimit : usageLimit // ignore: cast_nullable_to_non_nullable
as int,maxUsesPerUser: null == maxUsesPerUser ? _self.maxUsesPerUser : maxUsesPerUser // ignore: cast_nullable_to_non_nullable
as int,timesUsed: null == timesUsed ? _self.timesUsed : timesUsed // ignore: cast_nullable_to_non_nullable
as int,minPurchaseArtifacts: null == minPurchaseArtifacts ? _self.minPurchaseArtifacts : minPurchaseArtifacts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isRetired: null == isRetired ? _self.isRetired : isRetired // ignore: cast_nullable_to_non_nullable
as bool,retiredAt: freezed == retiredAt ? _self.retiredAt : retiredAt // ignore: cast_nullable_to_non_nullable
as String?,retiredReason: null == retiredReason ? _self.retiredReason : retiredReason // ignore: cast_nullable_to_non_nullable
as String,shareCount: null == shareCount ? _self.shareCount : shareCount // ignore: cast_nullable_to_non_nullable
as int,usageCount: null == usageCount ? _self.usageCount : usageCount // ignore: cast_nullable_to_non_nullable
as int,isExpired: null == isExpired ? _self.isExpired : isExpired // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DiscountCode].
extension DiscountCodePatterns on DiscountCode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DiscountCode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DiscountCode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DiscountCode value)  $default,){
final _that = this;
switch (_that) {
case _DiscountCode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DiscountCode value)?  $default,){
final _that = this;
switch (_that) {
case _DiscountCode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String creator,  String code, @JsonKey(name: 'discount_type')  String discountType, @JsonKey(name: 'discount_pct')  int discountPct, @JsonKey(name: 'discount_artifacts')  Map<String, int> discountArtifacts, @JsonKey(name: 'code_type')  String codeType, @JsonKey(name: 'qr_code')  String? qrCode,  String description,  String campaign, @JsonKey(name: 'valid_from')  String? validFrom, @JsonKey(name: 'valid_until')  String? validUntil, @JsonKey(name: 'usage_limit')  int usageLimit, @JsonKey(name: 'max_uses_per_user')  int maxUsesPerUser, @JsonKey(name: 'times_used')  int timesUsed, @JsonKey(name: 'min_purchase_artifacts')  Map<String, int> minPurchaseArtifacts, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'is_retired')  bool isRetired, @JsonKey(name: 'retired_at')  String? retiredAt, @JsonKey(name: 'retired_reason')  String retiredReason, @JsonKey(name: 'share_count')  int shareCount, @JsonKey(name: 'usage_count')  int usageCount, @JsonKey(name: 'is_expired')  bool isExpired, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DiscountCode() when $default != null:
return $default(_that.id,_that.creator,_that.code,_that.discountType,_that.discountPct,_that.discountArtifacts,_that.codeType,_that.qrCode,_that.description,_that.campaign,_that.validFrom,_that.validUntil,_that.usageLimit,_that.maxUsesPerUser,_that.timesUsed,_that.minPurchaseArtifacts,_that.isActive,_that.isRetired,_that.retiredAt,_that.retiredReason,_that.shareCount,_that.usageCount,_that.isExpired,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String creator,  String code, @JsonKey(name: 'discount_type')  String discountType, @JsonKey(name: 'discount_pct')  int discountPct, @JsonKey(name: 'discount_artifacts')  Map<String, int> discountArtifacts, @JsonKey(name: 'code_type')  String codeType, @JsonKey(name: 'qr_code')  String? qrCode,  String description,  String campaign, @JsonKey(name: 'valid_from')  String? validFrom, @JsonKey(name: 'valid_until')  String? validUntil, @JsonKey(name: 'usage_limit')  int usageLimit, @JsonKey(name: 'max_uses_per_user')  int maxUsesPerUser, @JsonKey(name: 'times_used')  int timesUsed, @JsonKey(name: 'min_purchase_artifacts')  Map<String, int> minPurchaseArtifacts, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'is_retired')  bool isRetired, @JsonKey(name: 'retired_at')  String? retiredAt, @JsonKey(name: 'retired_reason')  String retiredReason, @JsonKey(name: 'share_count')  int shareCount, @JsonKey(name: 'usage_count')  int usageCount, @JsonKey(name: 'is_expired')  bool isExpired, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt)  $default,) {final _that = this;
switch (_that) {
case _DiscountCode():
return $default(_that.id,_that.creator,_that.code,_that.discountType,_that.discountPct,_that.discountArtifacts,_that.codeType,_that.qrCode,_that.description,_that.campaign,_that.validFrom,_that.validUntil,_that.usageLimit,_that.maxUsesPerUser,_that.timesUsed,_that.minPurchaseArtifacts,_that.isActive,_that.isRetired,_that.retiredAt,_that.retiredReason,_that.shareCount,_that.usageCount,_that.isExpired,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String creator,  String code, @JsonKey(name: 'discount_type')  String discountType, @JsonKey(name: 'discount_pct')  int discountPct, @JsonKey(name: 'discount_artifacts')  Map<String, int> discountArtifacts, @JsonKey(name: 'code_type')  String codeType, @JsonKey(name: 'qr_code')  String? qrCode,  String description,  String campaign, @JsonKey(name: 'valid_from')  String? validFrom, @JsonKey(name: 'valid_until')  String? validUntil, @JsonKey(name: 'usage_limit')  int usageLimit, @JsonKey(name: 'max_uses_per_user')  int maxUsesPerUser, @JsonKey(name: 'times_used')  int timesUsed, @JsonKey(name: 'min_purchase_artifacts')  Map<String, int> minPurchaseArtifacts, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'is_retired')  bool isRetired, @JsonKey(name: 'retired_at')  String? retiredAt, @JsonKey(name: 'retired_reason')  String retiredReason, @JsonKey(name: 'share_count')  int shareCount, @JsonKey(name: 'usage_count')  int usageCount, @JsonKey(name: 'is_expired')  bool isExpired, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _DiscountCode() when $default != null:
return $default(_that.id,_that.creator,_that.code,_that.discountType,_that.discountPct,_that.discountArtifacts,_that.codeType,_that.qrCode,_that.description,_that.campaign,_that.validFrom,_that.validUntil,_that.usageLimit,_that.maxUsesPerUser,_that.timesUsed,_that.minPurchaseArtifacts,_that.isActive,_that.isRetired,_that.retiredAt,_that.retiredReason,_that.shareCount,_that.usageCount,_that.isExpired,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DiscountCode implements DiscountCode {
  const _DiscountCode({required this.id, required this.creator, required this.code, @JsonKey(name: 'discount_type') this.discountType = 'percentage', @JsonKey(name: 'discount_pct') this.discountPct = 0, @JsonKey(name: 'discount_artifacts') final  Map<String, int> discountArtifacts = const <String, int>{}, @JsonKey(name: 'code_type') this.codeType = 'text', @JsonKey(name: 'qr_code') this.qrCode, this.description = '', this.campaign = '', @JsonKey(name: 'valid_from') this.validFrom, @JsonKey(name: 'valid_until') this.validUntil, @JsonKey(name: 'usage_limit') this.usageLimit = 0, @JsonKey(name: 'max_uses_per_user') this.maxUsesPerUser = 0, @JsonKey(name: 'times_used') this.timesUsed = 0, @JsonKey(name: 'min_purchase_artifacts') final  Map<String, int> minPurchaseArtifacts = const <String, int>{}, @JsonKey(name: 'is_active') this.isActive = true, @JsonKey(name: 'is_retired') this.isRetired = false, @JsonKey(name: 'retired_at') this.retiredAt, @JsonKey(name: 'retired_reason') this.retiredReason = '', @JsonKey(name: 'share_count') this.shareCount = 0, @JsonKey(name: 'usage_count') this.usageCount = 0, @JsonKey(name: 'is_expired') this.isExpired = false, @JsonKey(name: 'created_at') this.createdAt = '', @JsonKey(name: 'updated_at') this.updatedAt = ''}): _discountArtifacts = discountArtifacts,_minPurchaseArtifacts = minPurchaseArtifacts;
  factory _DiscountCode.fromJson(Map<String, dynamic> json) => _$DiscountCodeFromJson(json);

@override final  String id;
@override final  String creator;
@override final  String code;
@override@JsonKey(name: 'discount_type') final  String discountType;
@override@JsonKey(name: 'discount_pct') final  int discountPct;
 final  Map<String, int> _discountArtifacts;
@override@JsonKey(name: 'discount_artifacts') Map<String, int> get discountArtifacts {
  if (_discountArtifacts is EqualUnmodifiableMapView) return _discountArtifacts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_discountArtifacts);
}

@override@JsonKey(name: 'code_type') final  String codeType;
@override@JsonKey(name: 'qr_code') final  String? qrCode;
@override@JsonKey() final  String description;
@override@JsonKey() final  String campaign;
@override@JsonKey(name: 'valid_from') final  String? validFrom;
@override@JsonKey(name: 'valid_until') final  String? validUntil;
@override@JsonKey(name: 'usage_limit') final  int usageLimit;
@override@JsonKey(name: 'max_uses_per_user') final  int maxUsesPerUser;
@override@JsonKey(name: 'times_used') final  int timesUsed;
 final  Map<String, int> _minPurchaseArtifacts;
@override@JsonKey(name: 'min_purchase_artifacts') Map<String, int> get minPurchaseArtifacts {
  if (_minPurchaseArtifacts is EqualUnmodifiableMapView) return _minPurchaseArtifacts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_minPurchaseArtifacts);
}

@override@JsonKey(name: 'is_active') final  bool isActive;
@override@JsonKey(name: 'is_retired') final  bool isRetired;
@override@JsonKey(name: 'retired_at') final  String? retiredAt;
@override@JsonKey(name: 'retired_reason') final  String retiredReason;
@override@JsonKey(name: 'share_count') final  int shareCount;
@override@JsonKey(name: 'usage_count') final  int usageCount;
@override@JsonKey(name: 'is_expired') final  bool isExpired;
@override@JsonKey(name: 'created_at') final  String createdAt;
@override@JsonKey(name: 'updated_at') final  String updatedAt;

/// Create a copy of DiscountCode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DiscountCodeCopyWith<_DiscountCode> get copyWith => __$DiscountCodeCopyWithImpl<_DiscountCode>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DiscountCodeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DiscountCode&&(identical(other.id, id) || other.id == id)&&(identical(other.creator, creator) || other.creator == creator)&&(identical(other.code, code) || other.code == code)&&(identical(other.discountType, discountType) || other.discountType == discountType)&&(identical(other.discountPct, discountPct) || other.discountPct == discountPct)&&const DeepCollectionEquality().equals(other._discountArtifacts, _discountArtifacts)&&(identical(other.codeType, codeType) || other.codeType == codeType)&&(identical(other.qrCode, qrCode) || other.qrCode == qrCode)&&(identical(other.description, description) || other.description == description)&&(identical(other.campaign, campaign) || other.campaign == campaign)&&(identical(other.validFrom, validFrom) || other.validFrom == validFrom)&&(identical(other.validUntil, validUntil) || other.validUntil == validUntil)&&(identical(other.usageLimit, usageLimit) || other.usageLimit == usageLimit)&&(identical(other.maxUsesPerUser, maxUsesPerUser) || other.maxUsesPerUser == maxUsesPerUser)&&(identical(other.timesUsed, timesUsed) || other.timesUsed == timesUsed)&&const DeepCollectionEquality().equals(other._minPurchaseArtifacts, _minPurchaseArtifacts)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isRetired, isRetired) || other.isRetired == isRetired)&&(identical(other.retiredAt, retiredAt) || other.retiredAt == retiredAt)&&(identical(other.retiredReason, retiredReason) || other.retiredReason == retiredReason)&&(identical(other.shareCount, shareCount) || other.shareCount == shareCount)&&(identical(other.usageCount, usageCount) || other.usageCount == usageCount)&&(identical(other.isExpired, isExpired) || other.isExpired == isExpired)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,creator,code,discountType,discountPct,const DeepCollectionEquality().hash(_discountArtifacts),codeType,qrCode,description,campaign,validFrom,validUntil,usageLimit,maxUsesPerUser,timesUsed,const DeepCollectionEquality().hash(_minPurchaseArtifacts),isActive,isRetired,retiredAt,retiredReason,shareCount,usageCount,isExpired,createdAt,updatedAt]);

@override
String toString() {
  return 'DiscountCode(id: $id, creator: $creator, code: $code, discountType: $discountType, discountPct: $discountPct, discountArtifacts: $discountArtifacts, codeType: $codeType, qrCode: $qrCode, description: $description, campaign: $campaign, validFrom: $validFrom, validUntil: $validUntil, usageLimit: $usageLimit, maxUsesPerUser: $maxUsesPerUser, timesUsed: $timesUsed, minPurchaseArtifacts: $minPurchaseArtifacts, isActive: $isActive, isRetired: $isRetired, retiredAt: $retiredAt, retiredReason: $retiredReason, shareCount: $shareCount, usageCount: $usageCount, isExpired: $isExpired, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$DiscountCodeCopyWith<$Res> implements $DiscountCodeCopyWith<$Res> {
  factory _$DiscountCodeCopyWith(_DiscountCode value, $Res Function(_DiscountCode) _then) = __$DiscountCodeCopyWithImpl;
@override @useResult
$Res call({
 String id, String creator, String code,@JsonKey(name: 'discount_type') String discountType,@JsonKey(name: 'discount_pct') int discountPct,@JsonKey(name: 'discount_artifacts') Map<String, int> discountArtifacts,@JsonKey(name: 'code_type') String codeType,@JsonKey(name: 'qr_code') String? qrCode, String description, String campaign,@JsonKey(name: 'valid_from') String? validFrom,@JsonKey(name: 'valid_until') String? validUntil,@JsonKey(name: 'usage_limit') int usageLimit,@JsonKey(name: 'max_uses_per_user') int maxUsesPerUser,@JsonKey(name: 'times_used') int timesUsed,@JsonKey(name: 'min_purchase_artifacts') Map<String, int> minPurchaseArtifacts,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'is_retired') bool isRetired,@JsonKey(name: 'retired_at') String? retiredAt,@JsonKey(name: 'retired_reason') String retiredReason,@JsonKey(name: 'share_count') int shareCount,@JsonKey(name: 'usage_count') int usageCount,@JsonKey(name: 'is_expired') bool isExpired,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt
});




}
/// @nodoc
class __$DiscountCodeCopyWithImpl<$Res>
    implements _$DiscountCodeCopyWith<$Res> {
  __$DiscountCodeCopyWithImpl(this._self, this._then);

  final _DiscountCode _self;
  final $Res Function(_DiscountCode) _then;

/// Create a copy of DiscountCode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? creator = null,Object? code = null,Object? discountType = null,Object? discountPct = null,Object? discountArtifacts = null,Object? codeType = null,Object? qrCode = freezed,Object? description = null,Object? campaign = null,Object? validFrom = freezed,Object? validUntil = freezed,Object? usageLimit = null,Object? maxUsesPerUser = null,Object? timesUsed = null,Object? minPurchaseArtifacts = null,Object? isActive = null,Object? isRetired = null,Object? retiredAt = freezed,Object? retiredReason = null,Object? shareCount = null,Object? usageCount = null,Object? isExpired = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_DiscountCode(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,creator: null == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,discountType: null == discountType ? _self.discountType : discountType // ignore: cast_nullable_to_non_nullable
as String,discountPct: null == discountPct ? _self.discountPct : discountPct // ignore: cast_nullable_to_non_nullable
as int,discountArtifacts: null == discountArtifacts ? _self._discountArtifacts : discountArtifacts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,codeType: null == codeType ? _self.codeType : codeType // ignore: cast_nullable_to_non_nullable
as String,qrCode: freezed == qrCode ? _self.qrCode : qrCode // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,campaign: null == campaign ? _self.campaign : campaign // ignore: cast_nullable_to_non_nullable
as String,validFrom: freezed == validFrom ? _self.validFrom : validFrom // ignore: cast_nullable_to_non_nullable
as String?,validUntil: freezed == validUntil ? _self.validUntil : validUntil // ignore: cast_nullable_to_non_nullable
as String?,usageLimit: null == usageLimit ? _self.usageLimit : usageLimit // ignore: cast_nullable_to_non_nullable
as int,maxUsesPerUser: null == maxUsesPerUser ? _self.maxUsesPerUser : maxUsesPerUser // ignore: cast_nullable_to_non_nullable
as int,timesUsed: null == timesUsed ? _self.timesUsed : timesUsed // ignore: cast_nullable_to_non_nullable
as int,minPurchaseArtifacts: null == minPurchaseArtifacts ? _self._minPurchaseArtifacts : minPurchaseArtifacts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isRetired: null == isRetired ? _self.isRetired : isRetired // ignore: cast_nullable_to_non_nullable
as bool,retiredAt: freezed == retiredAt ? _self.retiredAt : retiredAt // ignore: cast_nullable_to_non_nullable
as String?,retiredReason: null == retiredReason ? _self.retiredReason : retiredReason // ignore: cast_nullable_to_non_nullable
as String,shareCount: null == shareCount ? _self.shareCount : shareCount // ignore: cast_nullable_to_non_nullable
as int,usageCount: null == usageCount ? _self.usageCount : usageCount // ignore: cast_nullable_to_non_nullable
as int,isExpired: null == isExpired ? _self.isExpired : isExpired // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$DiscountUsageRecord {

 String get id; String get code;@JsonKey(name: 'user_display') String get userDisplay; String get discount; String get user; String? get cart;@JsonKey(name: 'order_artifacts') Map<String, int> get orderArtifacts;@JsonKey(name: 'discount_pct_applied') int get discountPctApplied;@JsonKey(name: 'discount_artifacts_applied') Map<String, int> get discountArtifactsApplied;@JsonKey(name: 'savings_artifacts') Map<String, int> get savingsArtifacts;@JsonKey(name: 'savings_usd') double get savingsUsd;@JsonKey(name: 'was_successful') bool get wasSuccessful;@JsonKey(name: 'created_at') String get createdAt;
/// Create a copy of DiscountUsageRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiscountUsageRecordCopyWith<DiscountUsageRecord> get copyWith => _$DiscountUsageRecordCopyWithImpl<DiscountUsageRecord>(this as DiscountUsageRecord, _$identity);

  /// Serializes this DiscountUsageRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiscountUsageRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.userDisplay, userDisplay) || other.userDisplay == userDisplay)&&(identical(other.discount, discount) || other.discount == discount)&&(identical(other.user, user) || other.user == user)&&(identical(other.cart, cart) || other.cart == cart)&&const DeepCollectionEquality().equals(other.orderArtifacts, orderArtifacts)&&(identical(other.discountPctApplied, discountPctApplied) || other.discountPctApplied == discountPctApplied)&&const DeepCollectionEquality().equals(other.discountArtifactsApplied, discountArtifactsApplied)&&const DeepCollectionEquality().equals(other.savingsArtifacts, savingsArtifacts)&&(identical(other.savingsUsd, savingsUsd) || other.savingsUsd == savingsUsd)&&(identical(other.wasSuccessful, wasSuccessful) || other.wasSuccessful == wasSuccessful)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,code,userDisplay,discount,user,cart,const DeepCollectionEquality().hash(orderArtifacts),discountPctApplied,const DeepCollectionEquality().hash(discountArtifactsApplied),const DeepCollectionEquality().hash(savingsArtifacts),savingsUsd,wasSuccessful,createdAt);

@override
String toString() {
  return 'DiscountUsageRecord(id: $id, code: $code, userDisplay: $userDisplay, discount: $discount, user: $user, cart: $cart, orderArtifacts: $orderArtifacts, discountPctApplied: $discountPctApplied, discountArtifactsApplied: $discountArtifactsApplied, savingsArtifacts: $savingsArtifacts, savingsUsd: $savingsUsd, wasSuccessful: $wasSuccessful, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $DiscountUsageRecordCopyWith<$Res>  {
  factory $DiscountUsageRecordCopyWith(DiscountUsageRecord value, $Res Function(DiscountUsageRecord) _then) = _$DiscountUsageRecordCopyWithImpl;
@useResult
$Res call({
 String id, String code,@JsonKey(name: 'user_display') String userDisplay, String discount, String user, String? cart,@JsonKey(name: 'order_artifacts') Map<String, int> orderArtifacts,@JsonKey(name: 'discount_pct_applied') int discountPctApplied,@JsonKey(name: 'discount_artifacts_applied') Map<String, int> discountArtifactsApplied,@JsonKey(name: 'savings_artifacts') Map<String, int> savingsArtifacts,@JsonKey(name: 'savings_usd') double savingsUsd,@JsonKey(name: 'was_successful') bool wasSuccessful,@JsonKey(name: 'created_at') String createdAt
});




}
/// @nodoc
class _$DiscountUsageRecordCopyWithImpl<$Res>
    implements $DiscountUsageRecordCopyWith<$Res> {
  _$DiscountUsageRecordCopyWithImpl(this._self, this._then);

  final DiscountUsageRecord _self;
  final $Res Function(DiscountUsageRecord) _then;

/// Create a copy of DiscountUsageRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? userDisplay = null,Object? discount = null,Object? user = null,Object? cart = freezed,Object? orderArtifacts = null,Object? discountPctApplied = null,Object? discountArtifactsApplied = null,Object? savingsArtifacts = null,Object? savingsUsd = null,Object? wasSuccessful = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,userDisplay: null == userDisplay ? _self.userDisplay : userDisplay // ignore: cast_nullable_to_non_nullable
as String,discount: null == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as String,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as String,cart: freezed == cart ? _self.cart : cart // ignore: cast_nullable_to_non_nullable
as String?,orderArtifacts: null == orderArtifacts ? _self.orderArtifacts : orderArtifacts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,discountPctApplied: null == discountPctApplied ? _self.discountPctApplied : discountPctApplied // ignore: cast_nullable_to_non_nullable
as int,discountArtifactsApplied: null == discountArtifactsApplied ? _self.discountArtifactsApplied : discountArtifactsApplied // ignore: cast_nullable_to_non_nullable
as Map<String, int>,savingsArtifacts: null == savingsArtifacts ? _self.savingsArtifacts : savingsArtifacts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,savingsUsd: null == savingsUsd ? _self.savingsUsd : savingsUsd // ignore: cast_nullable_to_non_nullable
as double,wasSuccessful: null == wasSuccessful ? _self.wasSuccessful : wasSuccessful // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DiscountUsageRecord].
extension DiscountUsageRecordPatterns on DiscountUsageRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DiscountUsageRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DiscountUsageRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DiscountUsageRecord value)  $default,){
final _that = this;
switch (_that) {
case _DiscountUsageRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DiscountUsageRecord value)?  $default,){
final _that = this;
switch (_that) {
case _DiscountUsageRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String code, @JsonKey(name: 'user_display')  String userDisplay,  String discount,  String user,  String? cart, @JsonKey(name: 'order_artifacts')  Map<String, int> orderArtifacts, @JsonKey(name: 'discount_pct_applied')  int discountPctApplied, @JsonKey(name: 'discount_artifacts_applied')  Map<String, int> discountArtifactsApplied, @JsonKey(name: 'savings_artifacts')  Map<String, int> savingsArtifacts, @JsonKey(name: 'savings_usd')  double savingsUsd, @JsonKey(name: 'was_successful')  bool wasSuccessful, @JsonKey(name: 'created_at')  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DiscountUsageRecord() when $default != null:
return $default(_that.id,_that.code,_that.userDisplay,_that.discount,_that.user,_that.cart,_that.orderArtifacts,_that.discountPctApplied,_that.discountArtifactsApplied,_that.savingsArtifacts,_that.savingsUsd,_that.wasSuccessful,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String code, @JsonKey(name: 'user_display')  String userDisplay,  String discount,  String user,  String? cart, @JsonKey(name: 'order_artifacts')  Map<String, int> orderArtifacts, @JsonKey(name: 'discount_pct_applied')  int discountPctApplied, @JsonKey(name: 'discount_artifacts_applied')  Map<String, int> discountArtifactsApplied, @JsonKey(name: 'savings_artifacts')  Map<String, int> savingsArtifacts, @JsonKey(name: 'savings_usd')  double savingsUsd, @JsonKey(name: 'was_successful')  bool wasSuccessful, @JsonKey(name: 'created_at')  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _DiscountUsageRecord():
return $default(_that.id,_that.code,_that.userDisplay,_that.discount,_that.user,_that.cart,_that.orderArtifacts,_that.discountPctApplied,_that.discountArtifactsApplied,_that.savingsArtifacts,_that.savingsUsd,_that.wasSuccessful,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String code, @JsonKey(name: 'user_display')  String userDisplay,  String discount,  String user,  String? cart, @JsonKey(name: 'order_artifacts')  Map<String, int> orderArtifacts, @JsonKey(name: 'discount_pct_applied')  int discountPctApplied, @JsonKey(name: 'discount_artifacts_applied')  Map<String, int> discountArtifactsApplied, @JsonKey(name: 'savings_artifacts')  Map<String, int> savingsArtifacts, @JsonKey(name: 'savings_usd')  double savingsUsd, @JsonKey(name: 'was_successful')  bool wasSuccessful, @JsonKey(name: 'created_at')  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _DiscountUsageRecord() when $default != null:
return $default(_that.id,_that.code,_that.userDisplay,_that.discount,_that.user,_that.cart,_that.orderArtifacts,_that.discountPctApplied,_that.discountArtifactsApplied,_that.savingsArtifacts,_that.savingsUsd,_that.wasSuccessful,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DiscountUsageRecord implements DiscountUsageRecord {
  const _DiscountUsageRecord({required this.id, required this.code, @JsonKey(name: 'user_display') required this.userDisplay, required this.discount, required this.user, this.cart, @JsonKey(name: 'order_artifacts') final  Map<String, int> orderArtifacts = const <String, int>{}, @JsonKey(name: 'discount_pct_applied') this.discountPctApplied = 0, @JsonKey(name: 'discount_artifacts_applied') final  Map<String, int> discountArtifactsApplied = const <String, int>{}, @JsonKey(name: 'savings_artifacts') final  Map<String, int> savingsArtifacts = const <String, int>{}, @JsonKey(name: 'savings_usd') this.savingsUsd = 0.0, @JsonKey(name: 'was_successful') this.wasSuccessful = true, @JsonKey(name: 'created_at') required this.createdAt}): _orderArtifacts = orderArtifacts,_discountArtifactsApplied = discountArtifactsApplied,_savingsArtifacts = savingsArtifacts;
  factory _DiscountUsageRecord.fromJson(Map<String, dynamic> json) => _$DiscountUsageRecordFromJson(json);

@override final  String id;
@override final  String code;
@override@JsonKey(name: 'user_display') final  String userDisplay;
@override final  String discount;
@override final  String user;
@override final  String? cart;
 final  Map<String, int> _orderArtifacts;
@override@JsonKey(name: 'order_artifacts') Map<String, int> get orderArtifacts {
  if (_orderArtifacts is EqualUnmodifiableMapView) return _orderArtifacts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_orderArtifacts);
}

@override@JsonKey(name: 'discount_pct_applied') final  int discountPctApplied;
 final  Map<String, int> _discountArtifactsApplied;
@override@JsonKey(name: 'discount_artifacts_applied') Map<String, int> get discountArtifactsApplied {
  if (_discountArtifactsApplied is EqualUnmodifiableMapView) return _discountArtifactsApplied;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_discountArtifactsApplied);
}

 final  Map<String, int> _savingsArtifacts;
@override@JsonKey(name: 'savings_artifacts') Map<String, int> get savingsArtifacts {
  if (_savingsArtifacts is EqualUnmodifiableMapView) return _savingsArtifacts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_savingsArtifacts);
}

@override@JsonKey(name: 'savings_usd') final  double savingsUsd;
@override@JsonKey(name: 'was_successful') final  bool wasSuccessful;
@override@JsonKey(name: 'created_at') final  String createdAt;

/// Create a copy of DiscountUsageRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DiscountUsageRecordCopyWith<_DiscountUsageRecord> get copyWith => __$DiscountUsageRecordCopyWithImpl<_DiscountUsageRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DiscountUsageRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DiscountUsageRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.userDisplay, userDisplay) || other.userDisplay == userDisplay)&&(identical(other.discount, discount) || other.discount == discount)&&(identical(other.user, user) || other.user == user)&&(identical(other.cart, cart) || other.cart == cart)&&const DeepCollectionEquality().equals(other._orderArtifacts, _orderArtifacts)&&(identical(other.discountPctApplied, discountPctApplied) || other.discountPctApplied == discountPctApplied)&&const DeepCollectionEquality().equals(other._discountArtifactsApplied, _discountArtifactsApplied)&&const DeepCollectionEquality().equals(other._savingsArtifacts, _savingsArtifacts)&&(identical(other.savingsUsd, savingsUsd) || other.savingsUsd == savingsUsd)&&(identical(other.wasSuccessful, wasSuccessful) || other.wasSuccessful == wasSuccessful)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,code,userDisplay,discount,user,cart,const DeepCollectionEquality().hash(_orderArtifacts),discountPctApplied,const DeepCollectionEquality().hash(_discountArtifactsApplied),const DeepCollectionEquality().hash(_savingsArtifacts),savingsUsd,wasSuccessful,createdAt);

@override
String toString() {
  return 'DiscountUsageRecord(id: $id, code: $code, userDisplay: $userDisplay, discount: $discount, user: $user, cart: $cart, orderArtifacts: $orderArtifacts, discountPctApplied: $discountPctApplied, discountArtifactsApplied: $discountArtifactsApplied, savingsArtifacts: $savingsArtifacts, savingsUsd: $savingsUsd, wasSuccessful: $wasSuccessful, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$DiscountUsageRecordCopyWith<$Res> implements $DiscountUsageRecordCopyWith<$Res> {
  factory _$DiscountUsageRecordCopyWith(_DiscountUsageRecord value, $Res Function(_DiscountUsageRecord) _then) = __$DiscountUsageRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, String code,@JsonKey(name: 'user_display') String userDisplay, String discount, String user, String? cart,@JsonKey(name: 'order_artifacts') Map<String, int> orderArtifacts,@JsonKey(name: 'discount_pct_applied') int discountPctApplied,@JsonKey(name: 'discount_artifacts_applied') Map<String, int> discountArtifactsApplied,@JsonKey(name: 'savings_artifacts') Map<String, int> savingsArtifacts,@JsonKey(name: 'savings_usd') double savingsUsd,@JsonKey(name: 'was_successful') bool wasSuccessful,@JsonKey(name: 'created_at') String createdAt
});




}
/// @nodoc
class __$DiscountUsageRecordCopyWithImpl<$Res>
    implements _$DiscountUsageRecordCopyWith<$Res> {
  __$DiscountUsageRecordCopyWithImpl(this._self, this._then);

  final _DiscountUsageRecord _self;
  final $Res Function(_DiscountUsageRecord) _then;

/// Create a copy of DiscountUsageRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? userDisplay = null,Object? discount = null,Object? user = null,Object? cart = freezed,Object? orderArtifacts = null,Object? discountPctApplied = null,Object? discountArtifactsApplied = null,Object? savingsArtifacts = null,Object? savingsUsd = null,Object? wasSuccessful = null,Object? createdAt = null,}) {
  return _then(_DiscountUsageRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,userDisplay: null == userDisplay ? _self.userDisplay : userDisplay // ignore: cast_nullable_to_non_nullable
as String,discount: null == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as String,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as String,cart: freezed == cart ? _self.cart : cart // ignore: cast_nullable_to_non_nullable
as String?,orderArtifacts: null == orderArtifacts ? _self._orderArtifacts : orderArtifacts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,discountPctApplied: null == discountPctApplied ? _self.discountPctApplied : discountPctApplied // ignore: cast_nullable_to_non_nullable
as int,discountArtifactsApplied: null == discountArtifactsApplied ? _self._discountArtifactsApplied : discountArtifactsApplied // ignore: cast_nullable_to_non_nullable
as Map<String, int>,savingsArtifacts: null == savingsArtifacts ? _self._savingsArtifacts : savingsArtifacts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,savingsUsd: null == savingsUsd ? _self.savingsUsd : savingsUsd // ignore: cast_nullable_to_non_nullable
as double,wasSuccessful: null == wasSuccessful ? _self.wasSuccessful : wasSuccessful // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$DiscountAnalytics {

@JsonKey(name: 'total_uses') int get totalUses;@JsonKey(name: 'successful_uses') int get successfulUses;@JsonKey(name: 'total_savings_usd') double get totalSavingsUsd;@JsonKey(name: 'share_count') int get shareCount;@JsonKey(name: 'times_used') int get timesUsed;@JsonKey(name: 'unique_users') int get uniqueUsers;@JsonKey(name: 'returning_users') int get returningUsers;@JsonKey(name: 'retention_rate') double get retentionRate;@JsonKey(name: 'repeat_usage_distribution') List<Map<String, dynamic>> get repeatUsageDistribution;@JsonKey(name: 'avg_savings_per_user') double get avgSavingsPerUser;@JsonKey(name: 'total_order_value_usd') double get totalOrderValueUsd;@JsonKey(name: 'top_users') List<Map<String, dynamic>> get topUsers;@JsonKey(name: 'usage_over_time') List<Map<String, dynamic>> get usageOverTime; DiscountCode get code;
/// Create a copy of DiscountAnalytics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiscountAnalyticsCopyWith<DiscountAnalytics> get copyWith => _$DiscountAnalyticsCopyWithImpl<DiscountAnalytics>(this as DiscountAnalytics, _$identity);

  /// Serializes this DiscountAnalytics to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiscountAnalytics&&(identical(other.totalUses, totalUses) || other.totalUses == totalUses)&&(identical(other.successfulUses, successfulUses) || other.successfulUses == successfulUses)&&(identical(other.totalSavingsUsd, totalSavingsUsd) || other.totalSavingsUsd == totalSavingsUsd)&&(identical(other.shareCount, shareCount) || other.shareCount == shareCount)&&(identical(other.timesUsed, timesUsed) || other.timesUsed == timesUsed)&&(identical(other.uniqueUsers, uniqueUsers) || other.uniqueUsers == uniqueUsers)&&(identical(other.returningUsers, returningUsers) || other.returningUsers == returningUsers)&&(identical(other.retentionRate, retentionRate) || other.retentionRate == retentionRate)&&const DeepCollectionEquality().equals(other.repeatUsageDistribution, repeatUsageDistribution)&&(identical(other.avgSavingsPerUser, avgSavingsPerUser) || other.avgSavingsPerUser == avgSavingsPerUser)&&(identical(other.totalOrderValueUsd, totalOrderValueUsd) || other.totalOrderValueUsd == totalOrderValueUsd)&&const DeepCollectionEquality().equals(other.topUsers, topUsers)&&const DeepCollectionEquality().equals(other.usageOverTime, usageOverTime)&&(identical(other.code, code) || other.code == code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalUses,successfulUses,totalSavingsUsd,shareCount,timesUsed,uniqueUsers,returningUsers,retentionRate,const DeepCollectionEquality().hash(repeatUsageDistribution),avgSavingsPerUser,totalOrderValueUsd,const DeepCollectionEquality().hash(topUsers),const DeepCollectionEquality().hash(usageOverTime),code);

@override
String toString() {
  return 'DiscountAnalytics(totalUses: $totalUses, successfulUses: $successfulUses, totalSavingsUsd: $totalSavingsUsd, shareCount: $shareCount, timesUsed: $timesUsed, uniqueUsers: $uniqueUsers, returningUsers: $returningUsers, retentionRate: $retentionRate, repeatUsageDistribution: $repeatUsageDistribution, avgSavingsPerUser: $avgSavingsPerUser, totalOrderValueUsd: $totalOrderValueUsd, topUsers: $topUsers, usageOverTime: $usageOverTime, code: $code)';
}


}

/// @nodoc
abstract mixin class $DiscountAnalyticsCopyWith<$Res>  {
  factory $DiscountAnalyticsCopyWith(DiscountAnalytics value, $Res Function(DiscountAnalytics) _then) = _$DiscountAnalyticsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'total_uses') int totalUses,@JsonKey(name: 'successful_uses') int successfulUses,@JsonKey(name: 'total_savings_usd') double totalSavingsUsd,@JsonKey(name: 'share_count') int shareCount,@JsonKey(name: 'times_used') int timesUsed,@JsonKey(name: 'unique_users') int uniqueUsers,@JsonKey(name: 'returning_users') int returningUsers,@JsonKey(name: 'retention_rate') double retentionRate,@JsonKey(name: 'repeat_usage_distribution') List<Map<String, dynamic>> repeatUsageDistribution,@JsonKey(name: 'avg_savings_per_user') double avgSavingsPerUser,@JsonKey(name: 'total_order_value_usd') double totalOrderValueUsd,@JsonKey(name: 'top_users') List<Map<String, dynamic>> topUsers,@JsonKey(name: 'usage_over_time') List<Map<String, dynamic>> usageOverTime, DiscountCode code
});


$DiscountCodeCopyWith<$Res> get code;

}
/// @nodoc
class _$DiscountAnalyticsCopyWithImpl<$Res>
    implements $DiscountAnalyticsCopyWith<$Res> {
  _$DiscountAnalyticsCopyWithImpl(this._self, this._then);

  final DiscountAnalytics _self;
  final $Res Function(DiscountAnalytics) _then;

/// Create a copy of DiscountAnalytics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalUses = null,Object? successfulUses = null,Object? totalSavingsUsd = null,Object? shareCount = null,Object? timesUsed = null,Object? uniqueUsers = null,Object? returningUsers = null,Object? retentionRate = null,Object? repeatUsageDistribution = null,Object? avgSavingsPerUser = null,Object? totalOrderValueUsd = null,Object? topUsers = null,Object? usageOverTime = null,Object? code = null,}) {
  return _then(_self.copyWith(
totalUses: null == totalUses ? _self.totalUses : totalUses // ignore: cast_nullable_to_non_nullable
as int,successfulUses: null == successfulUses ? _self.successfulUses : successfulUses // ignore: cast_nullable_to_non_nullable
as int,totalSavingsUsd: null == totalSavingsUsd ? _self.totalSavingsUsd : totalSavingsUsd // ignore: cast_nullable_to_non_nullable
as double,shareCount: null == shareCount ? _self.shareCount : shareCount // ignore: cast_nullable_to_non_nullable
as int,timesUsed: null == timesUsed ? _self.timesUsed : timesUsed // ignore: cast_nullable_to_non_nullable
as int,uniqueUsers: null == uniqueUsers ? _self.uniqueUsers : uniqueUsers // ignore: cast_nullable_to_non_nullable
as int,returningUsers: null == returningUsers ? _self.returningUsers : returningUsers // ignore: cast_nullable_to_non_nullable
as int,retentionRate: null == retentionRate ? _self.retentionRate : retentionRate // ignore: cast_nullable_to_non_nullable
as double,repeatUsageDistribution: null == repeatUsageDistribution ? _self.repeatUsageDistribution : repeatUsageDistribution // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,avgSavingsPerUser: null == avgSavingsPerUser ? _self.avgSavingsPerUser : avgSavingsPerUser // ignore: cast_nullable_to_non_nullable
as double,totalOrderValueUsd: null == totalOrderValueUsd ? _self.totalOrderValueUsd : totalOrderValueUsd // ignore: cast_nullable_to_non_nullable
as double,topUsers: null == topUsers ? _self.topUsers : topUsers // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,usageOverTime: null == usageOverTime ? _self.usageOverTime : usageOverTime // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as DiscountCode,
  ));
}
/// Create a copy of DiscountAnalytics
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DiscountCodeCopyWith<$Res> get code {
  
  return $DiscountCodeCopyWith<$Res>(_self.code, (value) {
    return _then(_self.copyWith(code: value));
  });
}
}


/// Adds pattern-matching-related methods to [DiscountAnalytics].
extension DiscountAnalyticsPatterns on DiscountAnalytics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DiscountAnalytics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DiscountAnalytics() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DiscountAnalytics value)  $default,){
final _that = this;
switch (_that) {
case _DiscountAnalytics():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DiscountAnalytics value)?  $default,){
final _that = this;
switch (_that) {
case _DiscountAnalytics() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'total_uses')  int totalUses, @JsonKey(name: 'successful_uses')  int successfulUses, @JsonKey(name: 'total_savings_usd')  double totalSavingsUsd, @JsonKey(name: 'share_count')  int shareCount, @JsonKey(name: 'times_used')  int timesUsed, @JsonKey(name: 'unique_users')  int uniqueUsers, @JsonKey(name: 'returning_users')  int returningUsers, @JsonKey(name: 'retention_rate')  double retentionRate, @JsonKey(name: 'repeat_usage_distribution')  List<Map<String, dynamic>> repeatUsageDistribution, @JsonKey(name: 'avg_savings_per_user')  double avgSavingsPerUser, @JsonKey(name: 'total_order_value_usd')  double totalOrderValueUsd, @JsonKey(name: 'top_users')  List<Map<String, dynamic>> topUsers, @JsonKey(name: 'usage_over_time')  List<Map<String, dynamic>> usageOverTime,  DiscountCode code)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DiscountAnalytics() when $default != null:
return $default(_that.totalUses,_that.successfulUses,_that.totalSavingsUsd,_that.shareCount,_that.timesUsed,_that.uniqueUsers,_that.returningUsers,_that.retentionRate,_that.repeatUsageDistribution,_that.avgSavingsPerUser,_that.totalOrderValueUsd,_that.topUsers,_that.usageOverTime,_that.code);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'total_uses')  int totalUses, @JsonKey(name: 'successful_uses')  int successfulUses, @JsonKey(name: 'total_savings_usd')  double totalSavingsUsd, @JsonKey(name: 'share_count')  int shareCount, @JsonKey(name: 'times_used')  int timesUsed, @JsonKey(name: 'unique_users')  int uniqueUsers, @JsonKey(name: 'returning_users')  int returningUsers, @JsonKey(name: 'retention_rate')  double retentionRate, @JsonKey(name: 'repeat_usage_distribution')  List<Map<String, dynamic>> repeatUsageDistribution, @JsonKey(name: 'avg_savings_per_user')  double avgSavingsPerUser, @JsonKey(name: 'total_order_value_usd')  double totalOrderValueUsd, @JsonKey(name: 'top_users')  List<Map<String, dynamic>> topUsers, @JsonKey(name: 'usage_over_time')  List<Map<String, dynamic>> usageOverTime,  DiscountCode code)  $default,) {final _that = this;
switch (_that) {
case _DiscountAnalytics():
return $default(_that.totalUses,_that.successfulUses,_that.totalSavingsUsd,_that.shareCount,_that.timesUsed,_that.uniqueUsers,_that.returningUsers,_that.retentionRate,_that.repeatUsageDistribution,_that.avgSavingsPerUser,_that.totalOrderValueUsd,_that.topUsers,_that.usageOverTime,_that.code);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'total_uses')  int totalUses, @JsonKey(name: 'successful_uses')  int successfulUses, @JsonKey(name: 'total_savings_usd')  double totalSavingsUsd, @JsonKey(name: 'share_count')  int shareCount, @JsonKey(name: 'times_used')  int timesUsed, @JsonKey(name: 'unique_users')  int uniqueUsers, @JsonKey(name: 'returning_users')  int returningUsers, @JsonKey(name: 'retention_rate')  double retentionRate, @JsonKey(name: 'repeat_usage_distribution')  List<Map<String, dynamic>> repeatUsageDistribution, @JsonKey(name: 'avg_savings_per_user')  double avgSavingsPerUser, @JsonKey(name: 'total_order_value_usd')  double totalOrderValueUsd, @JsonKey(name: 'top_users')  List<Map<String, dynamic>> topUsers, @JsonKey(name: 'usage_over_time')  List<Map<String, dynamic>> usageOverTime,  DiscountCode code)?  $default,) {final _that = this;
switch (_that) {
case _DiscountAnalytics() when $default != null:
return $default(_that.totalUses,_that.successfulUses,_that.totalSavingsUsd,_that.shareCount,_that.timesUsed,_that.uniqueUsers,_that.returningUsers,_that.retentionRate,_that.repeatUsageDistribution,_that.avgSavingsPerUser,_that.totalOrderValueUsd,_that.topUsers,_that.usageOverTime,_that.code);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DiscountAnalytics implements DiscountAnalytics {
  const _DiscountAnalytics({@JsonKey(name: 'total_uses') this.totalUses = 0, @JsonKey(name: 'successful_uses') this.successfulUses = 0, @JsonKey(name: 'total_savings_usd') this.totalSavingsUsd = 0.0, @JsonKey(name: 'share_count') this.shareCount = 0, @JsonKey(name: 'times_used') this.timesUsed = 0, @JsonKey(name: 'unique_users') this.uniqueUsers = 0, @JsonKey(name: 'returning_users') this.returningUsers = 0, @JsonKey(name: 'retention_rate') this.retentionRate = 0.0, @JsonKey(name: 'repeat_usage_distribution') final  List<Map<String, dynamic>> repeatUsageDistribution = const <Map<String, dynamic>>[], @JsonKey(name: 'avg_savings_per_user') this.avgSavingsPerUser = 0.0, @JsonKey(name: 'total_order_value_usd') this.totalOrderValueUsd = 0.0, @JsonKey(name: 'top_users') final  List<Map<String, dynamic>> topUsers = const <Map<String, dynamic>>[], @JsonKey(name: 'usage_over_time') final  List<Map<String, dynamic>> usageOverTime = const <Map<String, dynamic>>[], required this.code}): _repeatUsageDistribution = repeatUsageDistribution,_topUsers = topUsers,_usageOverTime = usageOverTime;
  factory _DiscountAnalytics.fromJson(Map<String, dynamic> json) => _$DiscountAnalyticsFromJson(json);

@override@JsonKey(name: 'total_uses') final  int totalUses;
@override@JsonKey(name: 'successful_uses') final  int successfulUses;
@override@JsonKey(name: 'total_savings_usd') final  double totalSavingsUsd;
@override@JsonKey(name: 'share_count') final  int shareCount;
@override@JsonKey(name: 'times_used') final  int timesUsed;
@override@JsonKey(name: 'unique_users') final  int uniqueUsers;
@override@JsonKey(name: 'returning_users') final  int returningUsers;
@override@JsonKey(name: 'retention_rate') final  double retentionRate;
 final  List<Map<String, dynamic>> _repeatUsageDistribution;
@override@JsonKey(name: 'repeat_usage_distribution') List<Map<String, dynamic>> get repeatUsageDistribution {
  if (_repeatUsageDistribution is EqualUnmodifiableListView) return _repeatUsageDistribution;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_repeatUsageDistribution);
}

@override@JsonKey(name: 'avg_savings_per_user') final  double avgSavingsPerUser;
@override@JsonKey(name: 'total_order_value_usd') final  double totalOrderValueUsd;
 final  List<Map<String, dynamic>> _topUsers;
@override@JsonKey(name: 'top_users') List<Map<String, dynamic>> get topUsers {
  if (_topUsers is EqualUnmodifiableListView) return _topUsers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_topUsers);
}

 final  List<Map<String, dynamic>> _usageOverTime;
@override@JsonKey(name: 'usage_over_time') List<Map<String, dynamic>> get usageOverTime {
  if (_usageOverTime is EqualUnmodifiableListView) return _usageOverTime;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_usageOverTime);
}

@override final  DiscountCode code;

/// Create a copy of DiscountAnalytics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DiscountAnalyticsCopyWith<_DiscountAnalytics> get copyWith => __$DiscountAnalyticsCopyWithImpl<_DiscountAnalytics>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DiscountAnalyticsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DiscountAnalytics&&(identical(other.totalUses, totalUses) || other.totalUses == totalUses)&&(identical(other.successfulUses, successfulUses) || other.successfulUses == successfulUses)&&(identical(other.totalSavingsUsd, totalSavingsUsd) || other.totalSavingsUsd == totalSavingsUsd)&&(identical(other.shareCount, shareCount) || other.shareCount == shareCount)&&(identical(other.timesUsed, timesUsed) || other.timesUsed == timesUsed)&&(identical(other.uniqueUsers, uniqueUsers) || other.uniqueUsers == uniqueUsers)&&(identical(other.returningUsers, returningUsers) || other.returningUsers == returningUsers)&&(identical(other.retentionRate, retentionRate) || other.retentionRate == retentionRate)&&const DeepCollectionEquality().equals(other._repeatUsageDistribution, _repeatUsageDistribution)&&(identical(other.avgSavingsPerUser, avgSavingsPerUser) || other.avgSavingsPerUser == avgSavingsPerUser)&&(identical(other.totalOrderValueUsd, totalOrderValueUsd) || other.totalOrderValueUsd == totalOrderValueUsd)&&const DeepCollectionEquality().equals(other._topUsers, _topUsers)&&const DeepCollectionEquality().equals(other._usageOverTime, _usageOverTime)&&(identical(other.code, code) || other.code == code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalUses,successfulUses,totalSavingsUsd,shareCount,timesUsed,uniqueUsers,returningUsers,retentionRate,const DeepCollectionEquality().hash(_repeatUsageDistribution),avgSavingsPerUser,totalOrderValueUsd,const DeepCollectionEquality().hash(_topUsers),const DeepCollectionEquality().hash(_usageOverTime),code);

@override
String toString() {
  return 'DiscountAnalytics(totalUses: $totalUses, successfulUses: $successfulUses, totalSavingsUsd: $totalSavingsUsd, shareCount: $shareCount, timesUsed: $timesUsed, uniqueUsers: $uniqueUsers, returningUsers: $returningUsers, retentionRate: $retentionRate, repeatUsageDistribution: $repeatUsageDistribution, avgSavingsPerUser: $avgSavingsPerUser, totalOrderValueUsd: $totalOrderValueUsd, topUsers: $topUsers, usageOverTime: $usageOverTime, code: $code)';
}


}

/// @nodoc
abstract mixin class _$DiscountAnalyticsCopyWith<$Res> implements $DiscountAnalyticsCopyWith<$Res> {
  factory _$DiscountAnalyticsCopyWith(_DiscountAnalytics value, $Res Function(_DiscountAnalytics) _then) = __$DiscountAnalyticsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'total_uses') int totalUses,@JsonKey(name: 'successful_uses') int successfulUses,@JsonKey(name: 'total_savings_usd') double totalSavingsUsd,@JsonKey(name: 'share_count') int shareCount,@JsonKey(name: 'times_used') int timesUsed,@JsonKey(name: 'unique_users') int uniqueUsers,@JsonKey(name: 'returning_users') int returningUsers,@JsonKey(name: 'retention_rate') double retentionRate,@JsonKey(name: 'repeat_usage_distribution') List<Map<String, dynamic>> repeatUsageDistribution,@JsonKey(name: 'avg_savings_per_user') double avgSavingsPerUser,@JsonKey(name: 'total_order_value_usd') double totalOrderValueUsd,@JsonKey(name: 'top_users') List<Map<String, dynamic>> topUsers,@JsonKey(name: 'usage_over_time') List<Map<String, dynamic>> usageOverTime, DiscountCode code
});


@override $DiscountCodeCopyWith<$Res> get code;

}
/// @nodoc
class __$DiscountAnalyticsCopyWithImpl<$Res>
    implements _$DiscountAnalyticsCopyWith<$Res> {
  __$DiscountAnalyticsCopyWithImpl(this._self, this._then);

  final _DiscountAnalytics _self;
  final $Res Function(_DiscountAnalytics) _then;

/// Create a copy of DiscountAnalytics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalUses = null,Object? successfulUses = null,Object? totalSavingsUsd = null,Object? shareCount = null,Object? timesUsed = null,Object? uniqueUsers = null,Object? returningUsers = null,Object? retentionRate = null,Object? repeatUsageDistribution = null,Object? avgSavingsPerUser = null,Object? totalOrderValueUsd = null,Object? topUsers = null,Object? usageOverTime = null,Object? code = null,}) {
  return _then(_DiscountAnalytics(
totalUses: null == totalUses ? _self.totalUses : totalUses // ignore: cast_nullable_to_non_nullable
as int,successfulUses: null == successfulUses ? _self.successfulUses : successfulUses // ignore: cast_nullable_to_non_nullable
as int,totalSavingsUsd: null == totalSavingsUsd ? _self.totalSavingsUsd : totalSavingsUsd // ignore: cast_nullable_to_non_nullable
as double,shareCount: null == shareCount ? _self.shareCount : shareCount // ignore: cast_nullable_to_non_nullable
as int,timesUsed: null == timesUsed ? _self.timesUsed : timesUsed // ignore: cast_nullable_to_non_nullable
as int,uniqueUsers: null == uniqueUsers ? _self.uniqueUsers : uniqueUsers // ignore: cast_nullable_to_non_nullable
as int,returningUsers: null == returningUsers ? _self.returningUsers : returningUsers // ignore: cast_nullable_to_non_nullable
as int,retentionRate: null == retentionRate ? _self.retentionRate : retentionRate // ignore: cast_nullable_to_non_nullable
as double,repeatUsageDistribution: null == repeatUsageDistribution ? _self._repeatUsageDistribution : repeatUsageDistribution // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,avgSavingsPerUser: null == avgSavingsPerUser ? _self.avgSavingsPerUser : avgSavingsPerUser // ignore: cast_nullable_to_non_nullable
as double,totalOrderValueUsd: null == totalOrderValueUsd ? _self.totalOrderValueUsd : totalOrderValueUsd // ignore: cast_nullable_to_non_nullable
as double,topUsers: null == topUsers ? _self._topUsers : topUsers // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,usageOverTime: null == usageOverTime ? _self._usageOverTime : usageOverTime // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as DiscountCode,
  ));
}

/// Create a copy of DiscountAnalytics
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DiscountCodeCopyWith<$Res> get code {
  
  return $DiscountCodeCopyWith<$Res>(_self.code, (value) {
    return _then(_self.copyWith(code: value));
  });
}
}


/// @nodoc
mixin _$DiscountShareResult {

 String get code;@JsonKey(name: 'discount_pct') int get discountPct;@JsonKey(name: 'discount_type') String get discountType; String get description;@JsonKey(name: 'qr_code') String? get qrCode;
/// Create a copy of DiscountShareResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiscountShareResultCopyWith<DiscountShareResult> get copyWith => _$DiscountShareResultCopyWithImpl<DiscountShareResult>(this as DiscountShareResult, _$identity);

  /// Serializes this DiscountShareResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiscountShareResult&&(identical(other.code, code) || other.code == code)&&(identical(other.discountPct, discountPct) || other.discountPct == discountPct)&&(identical(other.discountType, discountType) || other.discountType == discountType)&&(identical(other.description, description) || other.description == description)&&(identical(other.qrCode, qrCode) || other.qrCode == qrCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,discountPct,discountType,description,qrCode);

@override
String toString() {
  return 'DiscountShareResult(code: $code, discountPct: $discountPct, discountType: $discountType, description: $description, qrCode: $qrCode)';
}


}

/// @nodoc
abstract mixin class $DiscountShareResultCopyWith<$Res>  {
  factory $DiscountShareResultCopyWith(DiscountShareResult value, $Res Function(DiscountShareResult) _then) = _$DiscountShareResultCopyWithImpl;
@useResult
$Res call({
 String code,@JsonKey(name: 'discount_pct') int discountPct,@JsonKey(name: 'discount_type') String discountType, String description,@JsonKey(name: 'qr_code') String? qrCode
});




}
/// @nodoc
class _$DiscountShareResultCopyWithImpl<$Res>
    implements $DiscountShareResultCopyWith<$Res> {
  _$DiscountShareResultCopyWithImpl(this._self, this._then);

  final DiscountShareResult _self;
  final $Res Function(DiscountShareResult) _then;

/// Create a copy of DiscountShareResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? discountPct = null,Object? discountType = null,Object? description = null,Object? qrCode = freezed,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,discountPct: null == discountPct ? _self.discountPct : discountPct // ignore: cast_nullable_to_non_nullable
as int,discountType: null == discountType ? _self.discountType : discountType // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,qrCode: freezed == qrCode ? _self.qrCode : qrCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DiscountShareResult].
extension DiscountShareResultPatterns on DiscountShareResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DiscountShareResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DiscountShareResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DiscountShareResult value)  $default,){
final _that = this;
switch (_that) {
case _DiscountShareResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DiscountShareResult value)?  $default,){
final _that = this;
switch (_that) {
case _DiscountShareResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code, @JsonKey(name: 'discount_pct')  int discountPct, @JsonKey(name: 'discount_type')  String discountType,  String description, @JsonKey(name: 'qr_code')  String? qrCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DiscountShareResult() when $default != null:
return $default(_that.code,_that.discountPct,_that.discountType,_that.description,_that.qrCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code, @JsonKey(name: 'discount_pct')  int discountPct, @JsonKey(name: 'discount_type')  String discountType,  String description, @JsonKey(name: 'qr_code')  String? qrCode)  $default,) {final _that = this;
switch (_that) {
case _DiscountShareResult():
return $default(_that.code,_that.discountPct,_that.discountType,_that.description,_that.qrCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code, @JsonKey(name: 'discount_pct')  int discountPct, @JsonKey(name: 'discount_type')  String discountType,  String description, @JsonKey(name: 'qr_code')  String? qrCode)?  $default,) {final _that = this;
switch (_that) {
case _DiscountShareResult() when $default != null:
return $default(_that.code,_that.discountPct,_that.discountType,_that.description,_that.qrCode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DiscountShareResult implements DiscountShareResult {
  const _DiscountShareResult({required this.code, @JsonKey(name: 'discount_pct') this.discountPct = 0, @JsonKey(name: 'discount_type') this.discountType = 'percentage', this.description = '', @JsonKey(name: 'qr_code') this.qrCode});
  factory _DiscountShareResult.fromJson(Map<String, dynamic> json) => _$DiscountShareResultFromJson(json);

@override final  String code;
@override@JsonKey(name: 'discount_pct') final  int discountPct;
@override@JsonKey(name: 'discount_type') final  String discountType;
@override@JsonKey() final  String description;
@override@JsonKey(name: 'qr_code') final  String? qrCode;

/// Create a copy of DiscountShareResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DiscountShareResultCopyWith<_DiscountShareResult> get copyWith => __$DiscountShareResultCopyWithImpl<_DiscountShareResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DiscountShareResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DiscountShareResult&&(identical(other.code, code) || other.code == code)&&(identical(other.discountPct, discountPct) || other.discountPct == discountPct)&&(identical(other.discountType, discountType) || other.discountType == discountType)&&(identical(other.description, description) || other.description == description)&&(identical(other.qrCode, qrCode) || other.qrCode == qrCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,discountPct,discountType,description,qrCode);

@override
String toString() {
  return 'DiscountShareResult(code: $code, discountPct: $discountPct, discountType: $discountType, description: $description, qrCode: $qrCode)';
}


}

/// @nodoc
abstract mixin class _$DiscountShareResultCopyWith<$Res> implements $DiscountShareResultCopyWith<$Res> {
  factory _$DiscountShareResultCopyWith(_DiscountShareResult value, $Res Function(_DiscountShareResult) _then) = __$DiscountShareResultCopyWithImpl;
@override @useResult
$Res call({
 String code,@JsonKey(name: 'discount_pct') int discountPct,@JsonKey(name: 'discount_type') String discountType, String description,@JsonKey(name: 'qr_code') String? qrCode
});




}
/// @nodoc
class __$DiscountShareResultCopyWithImpl<$Res>
    implements _$DiscountShareResultCopyWith<$Res> {
  __$DiscountShareResultCopyWithImpl(this._self, this._then);

  final _DiscountShareResult _self;
  final $Res Function(_DiscountShareResult) _then;

/// Create a copy of DiscountShareResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? discountPct = null,Object? discountType = null,Object? description = null,Object? qrCode = freezed,}) {
  return _then(_DiscountShareResult(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,discountPct: null == discountPct ? _self.discountPct : discountPct // ignore: cast_nullable_to_non_nullable
as int,discountType: null == discountType ? _self.discountType : discountType // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,qrCode: freezed == qrCode ? _self.qrCode : qrCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$FoodItem {

 String get item; double get confidence; Map<String, dynamic> get nutrition;
/// Create a copy of FoodItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FoodItemCopyWith<FoodItem> get copyWith => _$FoodItemCopyWithImpl<FoodItem>(this as FoodItem, _$identity);

  /// Serializes this FoodItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FoodItem&&(identical(other.item, item) || other.item == item)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&const DeepCollectionEquality().equals(other.nutrition, nutrition));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,item,confidence,const DeepCollectionEquality().hash(nutrition));

@override
String toString() {
  return 'FoodItem(item: $item, confidence: $confidence, nutrition: $nutrition)';
}


}

/// @nodoc
abstract mixin class $FoodItemCopyWith<$Res>  {
  factory $FoodItemCopyWith(FoodItem value, $Res Function(FoodItem) _then) = _$FoodItemCopyWithImpl;
@useResult
$Res call({
 String item, double confidence, Map<String, dynamic> nutrition
});




}
/// @nodoc
class _$FoodItemCopyWithImpl<$Res>
    implements $FoodItemCopyWith<$Res> {
  _$FoodItemCopyWithImpl(this._self, this._then);

  final FoodItem _self;
  final $Res Function(FoodItem) _then;

/// Create a copy of FoodItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? item = null,Object? confidence = null,Object? nutrition = null,}) {
  return _then(_self.copyWith(
item: null == item ? _self.item : item // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,nutrition: null == nutrition ? _self.nutrition : nutrition // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [FoodItem].
extension FoodItemPatterns on FoodItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FoodItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FoodItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FoodItem value)  $default,){
final _that = this;
switch (_that) {
case _FoodItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FoodItem value)?  $default,){
final _that = this;
switch (_that) {
case _FoodItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String item,  double confidence,  Map<String, dynamic> nutrition)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FoodItem() when $default != null:
return $default(_that.item,_that.confidence,_that.nutrition);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String item,  double confidence,  Map<String, dynamic> nutrition)  $default,) {final _that = this;
switch (_that) {
case _FoodItem():
return $default(_that.item,_that.confidence,_that.nutrition);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String item,  double confidence,  Map<String, dynamic> nutrition)?  $default,) {final _that = this;
switch (_that) {
case _FoodItem() when $default != null:
return $default(_that.item,_that.confidence,_that.nutrition);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FoodItem implements FoodItem {
  const _FoodItem({required this.item, required this.confidence, required final  Map<String, dynamic> nutrition}): _nutrition = nutrition;
  factory _FoodItem.fromJson(Map<String, dynamic> json) => _$FoodItemFromJson(json);

@override final  String item;
@override final  double confidence;
 final  Map<String, dynamic> _nutrition;
@override Map<String, dynamic> get nutrition {
  if (_nutrition is EqualUnmodifiableMapView) return _nutrition;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_nutrition);
}


/// Create a copy of FoodItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FoodItemCopyWith<_FoodItem> get copyWith => __$FoodItemCopyWithImpl<_FoodItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FoodItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FoodItem&&(identical(other.item, item) || other.item == item)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&const DeepCollectionEquality().equals(other._nutrition, _nutrition));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,item,confidence,const DeepCollectionEquality().hash(_nutrition));

@override
String toString() {
  return 'FoodItem(item: $item, confidence: $confidence, nutrition: $nutrition)';
}


}

/// @nodoc
abstract mixin class _$FoodItemCopyWith<$Res> implements $FoodItemCopyWith<$Res> {
  factory _$FoodItemCopyWith(_FoodItem value, $Res Function(_FoodItem) _then) = __$FoodItemCopyWithImpl;
@override @useResult
$Res call({
 String item, double confidence, Map<String, dynamic> nutrition
});




}
/// @nodoc
class __$FoodItemCopyWithImpl<$Res>
    implements _$FoodItemCopyWith<$Res> {
  __$FoodItemCopyWithImpl(this._self, this._then);

  final _FoodItem _self;
  final $Res Function(_FoodItem) _then;

/// Create a copy of FoodItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? item = null,Object? confidence = null,Object? nutrition = null,}) {
  return _then(_FoodItem(
item: null == item ? _self.item : item // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,nutrition: null == nutrition ? _self._nutrition : nutrition // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}


/// @nodoc
mixin _$FoodRecognitionResult {

 List<FoodItem> get items;@JsonKey(name: 'total_calories') double get totalCalories;@JsonKey(name: 'total_protein') double get totalProtein;@JsonKey(name: 'total_carbs') double get totalCarbs;@JsonKey(name: 'total_fat') double get totalFat;@JsonKey(name: 'health_benefits') List<String> get healthBenefits; String get method;
/// Create a copy of FoodRecognitionResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FoodRecognitionResultCopyWith<FoodRecognitionResult> get copyWith => _$FoodRecognitionResultCopyWithImpl<FoodRecognitionResult>(this as FoodRecognitionResult, _$identity);

  /// Serializes this FoodRecognitionResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FoodRecognitionResult&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.totalCalories, totalCalories) || other.totalCalories == totalCalories)&&(identical(other.totalProtein, totalProtein) || other.totalProtein == totalProtein)&&(identical(other.totalCarbs, totalCarbs) || other.totalCarbs == totalCarbs)&&(identical(other.totalFat, totalFat) || other.totalFat == totalFat)&&const DeepCollectionEquality().equals(other.healthBenefits, healthBenefits)&&(identical(other.method, method) || other.method == method));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),totalCalories,totalProtein,totalCarbs,totalFat,const DeepCollectionEquality().hash(healthBenefits),method);

@override
String toString() {
  return 'FoodRecognitionResult(items: $items, totalCalories: $totalCalories, totalProtein: $totalProtein, totalCarbs: $totalCarbs, totalFat: $totalFat, healthBenefits: $healthBenefits, method: $method)';
}


}

/// @nodoc
abstract mixin class $FoodRecognitionResultCopyWith<$Res>  {
  factory $FoodRecognitionResultCopyWith(FoodRecognitionResult value, $Res Function(FoodRecognitionResult) _then) = _$FoodRecognitionResultCopyWithImpl;
@useResult
$Res call({
 List<FoodItem> items,@JsonKey(name: 'total_calories') double totalCalories,@JsonKey(name: 'total_protein') double totalProtein,@JsonKey(name: 'total_carbs') double totalCarbs,@JsonKey(name: 'total_fat') double totalFat,@JsonKey(name: 'health_benefits') List<String> healthBenefits, String method
});




}
/// @nodoc
class _$FoodRecognitionResultCopyWithImpl<$Res>
    implements $FoodRecognitionResultCopyWith<$Res> {
  _$FoodRecognitionResultCopyWithImpl(this._self, this._then);

  final FoodRecognitionResult _self;
  final $Res Function(FoodRecognitionResult) _then;

/// Create a copy of FoodRecognitionResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? totalCalories = null,Object? totalProtein = null,Object? totalCarbs = null,Object? totalFat = null,Object? healthBenefits = null,Object? method = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<FoodItem>,totalCalories: null == totalCalories ? _self.totalCalories : totalCalories // ignore: cast_nullable_to_non_nullable
as double,totalProtein: null == totalProtein ? _self.totalProtein : totalProtein // ignore: cast_nullable_to_non_nullable
as double,totalCarbs: null == totalCarbs ? _self.totalCarbs : totalCarbs // ignore: cast_nullable_to_non_nullable
as double,totalFat: null == totalFat ? _self.totalFat : totalFat // ignore: cast_nullable_to_non_nullable
as double,healthBenefits: null == healthBenefits ? _self.healthBenefits : healthBenefits // ignore: cast_nullable_to_non_nullable
as List<String>,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [FoodRecognitionResult].
extension FoodRecognitionResultPatterns on FoodRecognitionResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FoodRecognitionResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FoodRecognitionResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FoodRecognitionResult value)  $default,){
final _that = this;
switch (_that) {
case _FoodRecognitionResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FoodRecognitionResult value)?  $default,){
final _that = this;
switch (_that) {
case _FoodRecognitionResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<FoodItem> items, @JsonKey(name: 'total_calories')  double totalCalories, @JsonKey(name: 'total_protein')  double totalProtein, @JsonKey(name: 'total_carbs')  double totalCarbs, @JsonKey(name: 'total_fat')  double totalFat, @JsonKey(name: 'health_benefits')  List<String> healthBenefits,  String method)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FoodRecognitionResult() when $default != null:
return $default(_that.items,_that.totalCalories,_that.totalProtein,_that.totalCarbs,_that.totalFat,_that.healthBenefits,_that.method);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<FoodItem> items, @JsonKey(name: 'total_calories')  double totalCalories, @JsonKey(name: 'total_protein')  double totalProtein, @JsonKey(name: 'total_carbs')  double totalCarbs, @JsonKey(name: 'total_fat')  double totalFat, @JsonKey(name: 'health_benefits')  List<String> healthBenefits,  String method)  $default,) {final _that = this;
switch (_that) {
case _FoodRecognitionResult():
return $default(_that.items,_that.totalCalories,_that.totalProtein,_that.totalCarbs,_that.totalFat,_that.healthBenefits,_that.method);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<FoodItem> items, @JsonKey(name: 'total_calories')  double totalCalories, @JsonKey(name: 'total_protein')  double totalProtein, @JsonKey(name: 'total_carbs')  double totalCarbs, @JsonKey(name: 'total_fat')  double totalFat, @JsonKey(name: 'health_benefits')  List<String> healthBenefits,  String method)?  $default,) {final _that = this;
switch (_that) {
case _FoodRecognitionResult() when $default != null:
return $default(_that.items,_that.totalCalories,_that.totalProtein,_that.totalCarbs,_that.totalFat,_that.healthBenefits,_that.method);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FoodRecognitionResult implements FoodRecognitionResult {
  const _FoodRecognitionResult({required final  List<FoodItem> items, @JsonKey(name: 'total_calories') required this.totalCalories, @JsonKey(name: 'total_protein') required this.totalProtein, @JsonKey(name: 'total_carbs') required this.totalCarbs, @JsonKey(name: 'total_fat') required this.totalFat, @JsonKey(name: 'health_benefits') final  List<String> healthBenefits = const <String>[], this.method = ''}): _items = items,_healthBenefits = healthBenefits;
  factory _FoodRecognitionResult.fromJson(Map<String, dynamic> json) => _$FoodRecognitionResultFromJson(json);

 final  List<FoodItem> _items;
@override List<FoodItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey(name: 'total_calories') final  double totalCalories;
@override@JsonKey(name: 'total_protein') final  double totalProtein;
@override@JsonKey(name: 'total_carbs') final  double totalCarbs;
@override@JsonKey(name: 'total_fat') final  double totalFat;
 final  List<String> _healthBenefits;
@override@JsonKey(name: 'health_benefits') List<String> get healthBenefits {
  if (_healthBenefits is EqualUnmodifiableListView) return _healthBenefits;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_healthBenefits);
}

@override@JsonKey() final  String method;

/// Create a copy of FoodRecognitionResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FoodRecognitionResultCopyWith<_FoodRecognitionResult> get copyWith => __$FoodRecognitionResultCopyWithImpl<_FoodRecognitionResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FoodRecognitionResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FoodRecognitionResult&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.totalCalories, totalCalories) || other.totalCalories == totalCalories)&&(identical(other.totalProtein, totalProtein) || other.totalProtein == totalProtein)&&(identical(other.totalCarbs, totalCarbs) || other.totalCarbs == totalCarbs)&&(identical(other.totalFat, totalFat) || other.totalFat == totalFat)&&const DeepCollectionEquality().equals(other._healthBenefits, _healthBenefits)&&(identical(other.method, method) || other.method == method));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),totalCalories,totalProtein,totalCarbs,totalFat,const DeepCollectionEquality().hash(_healthBenefits),method);

@override
String toString() {
  return 'FoodRecognitionResult(items: $items, totalCalories: $totalCalories, totalProtein: $totalProtein, totalCarbs: $totalCarbs, totalFat: $totalFat, healthBenefits: $healthBenefits, method: $method)';
}


}

/// @nodoc
abstract mixin class _$FoodRecognitionResultCopyWith<$Res> implements $FoodRecognitionResultCopyWith<$Res> {
  factory _$FoodRecognitionResultCopyWith(_FoodRecognitionResult value, $Res Function(_FoodRecognitionResult) _then) = __$FoodRecognitionResultCopyWithImpl;
@override @useResult
$Res call({
 List<FoodItem> items,@JsonKey(name: 'total_calories') double totalCalories,@JsonKey(name: 'total_protein') double totalProtein,@JsonKey(name: 'total_carbs') double totalCarbs,@JsonKey(name: 'total_fat') double totalFat,@JsonKey(name: 'health_benefits') List<String> healthBenefits, String method
});




}
/// @nodoc
class __$FoodRecognitionResultCopyWithImpl<$Res>
    implements _$FoodRecognitionResultCopyWith<$Res> {
  __$FoodRecognitionResultCopyWithImpl(this._self, this._then);

  final _FoodRecognitionResult _self;
  final $Res Function(_FoodRecognitionResult) _then;

/// Create a copy of FoodRecognitionResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? totalCalories = null,Object? totalProtein = null,Object? totalCarbs = null,Object? totalFat = null,Object? healthBenefits = null,Object? method = null,}) {
  return _then(_FoodRecognitionResult(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<FoodItem>,totalCalories: null == totalCalories ? _self.totalCalories : totalCalories // ignore: cast_nullable_to_non_nullable
as double,totalProtein: null == totalProtein ? _self.totalProtein : totalProtein // ignore: cast_nullable_to_non_nullable
as double,totalCarbs: null == totalCarbs ? _self.totalCarbs : totalCarbs // ignore: cast_nullable_to_non_nullable
as double,totalFat: null == totalFat ? _self.totalFat : totalFat // ignore: cast_nullable_to_non_nullable
as double,healthBenefits: null == healthBenefits ? _self._healthBenefits : healthBenefits // ignore: cast_nullable_to_non_nullable
as List<String>,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CreatorServices {

@JsonKey(name: 'meal_plans') List<MealPlan> get mealPlans; List<TrainingProgramme> get programmes; List<MarketplaceEvent> get events; List<MarketplaceProduct> get products;@JsonKey(name: 'discount_codes') List<DiscountCode> get discountCodes;
/// Create a copy of CreatorServices
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreatorServicesCopyWith<CreatorServices> get copyWith => _$CreatorServicesCopyWithImpl<CreatorServices>(this as CreatorServices, _$identity);

  /// Serializes this CreatorServices to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreatorServices&&const DeepCollectionEquality().equals(other.mealPlans, mealPlans)&&const DeepCollectionEquality().equals(other.programmes, programmes)&&const DeepCollectionEquality().equals(other.events, events)&&const DeepCollectionEquality().equals(other.products, products)&&const DeepCollectionEquality().equals(other.discountCodes, discountCodes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(mealPlans),const DeepCollectionEquality().hash(programmes),const DeepCollectionEquality().hash(events),const DeepCollectionEquality().hash(products),const DeepCollectionEquality().hash(discountCodes));

@override
String toString() {
  return 'CreatorServices(mealPlans: $mealPlans, programmes: $programmes, events: $events, products: $products, discountCodes: $discountCodes)';
}


}

/// @nodoc
abstract mixin class $CreatorServicesCopyWith<$Res>  {
  factory $CreatorServicesCopyWith(CreatorServices value, $Res Function(CreatorServices) _then) = _$CreatorServicesCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'meal_plans') List<MealPlan> mealPlans, List<TrainingProgramme> programmes, List<MarketplaceEvent> events, List<MarketplaceProduct> products,@JsonKey(name: 'discount_codes') List<DiscountCode> discountCodes
});




}
/// @nodoc
class _$CreatorServicesCopyWithImpl<$Res>
    implements $CreatorServicesCopyWith<$Res> {
  _$CreatorServicesCopyWithImpl(this._self, this._then);

  final CreatorServices _self;
  final $Res Function(CreatorServices) _then;

/// Create a copy of CreatorServices
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mealPlans = null,Object? programmes = null,Object? events = null,Object? products = null,Object? discountCodes = null,}) {
  return _then(_self.copyWith(
mealPlans: null == mealPlans ? _self.mealPlans : mealPlans // ignore: cast_nullable_to_non_nullable
as List<MealPlan>,programmes: null == programmes ? _self.programmes : programmes // ignore: cast_nullable_to_non_nullable
as List<TrainingProgramme>,events: null == events ? _self.events : events // ignore: cast_nullable_to_non_nullable
as List<MarketplaceEvent>,products: null == products ? _self.products : products // ignore: cast_nullable_to_non_nullable
as List<MarketplaceProduct>,discountCodes: null == discountCodes ? _self.discountCodes : discountCodes // ignore: cast_nullable_to_non_nullable
as List<DiscountCode>,
  ));
}

}


/// Adds pattern-matching-related methods to [CreatorServices].
extension CreatorServicesPatterns on CreatorServices {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreatorServices value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreatorServices() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreatorServices value)  $default,){
final _that = this;
switch (_that) {
case _CreatorServices():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreatorServices value)?  $default,){
final _that = this;
switch (_that) {
case _CreatorServices() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'meal_plans')  List<MealPlan> mealPlans,  List<TrainingProgramme> programmes,  List<MarketplaceEvent> events,  List<MarketplaceProduct> products, @JsonKey(name: 'discount_codes')  List<DiscountCode> discountCodes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreatorServices() when $default != null:
return $default(_that.mealPlans,_that.programmes,_that.events,_that.products,_that.discountCodes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'meal_plans')  List<MealPlan> mealPlans,  List<TrainingProgramme> programmes,  List<MarketplaceEvent> events,  List<MarketplaceProduct> products, @JsonKey(name: 'discount_codes')  List<DiscountCode> discountCodes)  $default,) {final _that = this;
switch (_that) {
case _CreatorServices():
return $default(_that.mealPlans,_that.programmes,_that.events,_that.products,_that.discountCodes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'meal_plans')  List<MealPlan> mealPlans,  List<TrainingProgramme> programmes,  List<MarketplaceEvent> events,  List<MarketplaceProduct> products, @JsonKey(name: 'discount_codes')  List<DiscountCode> discountCodes)?  $default,) {final _that = this;
switch (_that) {
case _CreatorServices() when $default != null:
return $default(_that.mealPlans,_that.programmes,_that.events,_that.products,_that.discountCodes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreatorServices implements CreatorServices {
  const _CreatorServices({@JsonKey(name: 'meal_plans') final  List<MealPlan> mealPlans = const <MealPlan>[], final  List<TrainingProgramme> programmes = const <TrainingProgramme>[], final  List<MarketplaceEvent> events = const <MarketplaceEvent>[], final  List<MarketplaceProduct> products = const <MarketplaceProduct>[], @JsonKey(name: 'discount_codes') final  List<DiscountCode> discountCodes = const <DiscountCode>[]}): _mealPlans = mealPlans,_programmes = programmes,_events = events,_products = products,_discountCodes = discountCodes;
  factory _CreatorServices.fromJson(Map<String, dynamic> json) => _$CreatorServicesFromJson(json);

 final  List<MealPlan> _mealPlans;
@override@JsonKey(name: 'meal_plans') List<MealPlan> get mealPlans {
  if (_mealPlans is EqualUnmodifiableListView) return _mealPlans;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mealPlans);
}

 final  List<TrainingProgramme> _programmes;
@override@JsonKey() List<TrainingProgramme> get programmes {
  if (_programmes is EqualUnmodifiableListView) return _programmes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_programmes);
}

 final  List<MarketplaceEvent> _events;
@override@JsonKey() List<MarketplaceEvent> get events {
  if (_events is EqualUnmodifiableListView) return _events;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_events);
}

 final  List<MarketplaceProduct> _products;
@override@JsonKey() List<MarketplaceProduct> get products {
  if (_products is EqualUnmodifiableListView) return _products;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_products);
}

 final  List<DiscountCode> _discountCodes;
@override@JsonKey(name: 'discount_codes') List<DiscountCode> get discountCodes {
  if (_discountCodes is EqualUnmodifiableListView) return _discountCodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_discountCodes);
}


/// Create a copy of CreatorServices
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreatorServicesCopyWith<_CreatorServices> get copyWith => __$CreatorServicesCopyWithImpl<_CreatorServices>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreatorServicesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreatorServices&&const DeepCollectionEquality().equals(other._mealPlans, _mealPlans)&&const DeepCollectionEquality().equals(other._programmes, _programmes)&&const DeepCollectionEquality().equals(other._events, _events)&&const DeepCollectionEquality().equals(other._products, _products)&&const DeepCollectionEquality().equals(other._discountCodes, _discountCodes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_mealPlans),const DeepCollectionEquality().hash(_programmes),const DeepCollectionEquality().hash(_events),const DeepCollectionEquality().hash(_products),const DeepCollectionEquality().hash(_discountCodes));

@override
String toString() {
  return 'CreatorServices(mealPlans: $mealPlans, programmes: $programmes, events: $events, products: $products, discountCodes: $discountCodes)';
}


}

/// @nodoc
abstract mixin class _$CreatorServicesCopyWith<$Res> implements $CreatorServicesCopyWith<$Res> {
  factory _$CreatorServicesCopyWith(_CreatorServices value, $Res Function(_CreatorServices) _then) = __$CreatorServicesCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'meal_plans') List<MealPlan> mealPlans, List<TrainingProgramme> programmes, List<MarketplaceEvent> events, List<MarketplaceProduct> products,@JsonKey(name: 'discount_codes') List<DiscountCode> discountCodes
});




}
/// @nodoc
class __$CreatorServicesCopyWithImpl<$Res>
    implements _$CreatorServicesCopyWith<$Res> {
  __$CreatorServicesCopyWithImpl(this._self, this._then);

  final _CreatorServices _self;
  final $Res Function(_CreatorServices) _then;

/// Create a copy of CreatorServices
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mealPlans = null,Object? programmes = null,Object? events = null,Object? products = null,Object? discountCodes = null,}) {
  return _then(_CreatorServices(
mealPlans: null == mealPlans ? _self._mealPlans : mealPlans // ignore: cast_nullable_to_non_nullable
as List<MealPlan>,programmes: null == programmes ? _self._programmes : programmes // ignore: cast_nullable_to_non_nullable
as List<TrainingProgramme>,events: null == events ? _self._events : events // ignore: cast_nullable_to_non_nullable
as List<MarketplaceEvent>,products: null == products ? _self._products : products // ignore: cast_nullable_to_non_nullable
as List<MarketplaceProduct>,discountCodes: null == discountCodes ? _self._discountCodes : discountCodes // ignore: cast_nullable_to_non_nullable
as List<DiscountCode>,
  ));
}


}


/// @nodoc
mixin _$ProductPayload {

 String get name; String get brand; String get description; String get category;@JsonKey(name: 'image_url') String get imageUrl;@JsonKey(name: 'affiliate_url') String get affiliateUrl;@JsonKey(name: 'price_display') String get priceDisplay;
/// Create a copy of ProductPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductPayloadCopyWith<ProductPayload> get copyWith => _$ProductPayloadCopyWithImpl<ProductPayload>(this as ProductPayload, _$identity);

  /// Serializes this ProductPayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductPayload&&(identical(other.name, name) || other.name == name)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.affiliateUrl, affiliateUrl) || other.affiliateUrl == affiliateUrl)&&(identical(other.priceDisplay, priceDisplay) || other.priceDisplay == priceDisplay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,brand,description,category,imageUrl,affiliateUrl,priceDisplay);

@override
String toString() {
  return 'ProductPayload(name: $name, brand: $brand, description: $description, category: $category, imageUrl: $imageUrl, affiliateUrl: $affiliateUrl, priceDisplay: $priceDisplay)';
}


}

/// @nodoc
abstract mixin class $ProductPayloadCopyWith<$Res>  {
  factory $ProductPayloadCopyWith(ProductPayload value, $Res Function(ProductPayload) _then) = _$ProductPayloadCopyWithImpl;
@useResult
$Res call({
 String name, String brand, String description, String category,@JsonKey(name: 'image_url') String imageUrl,@JsonKey(name: 'affiliate_url') String affiliateUrl,@JsonKey(name: 'price_display') String priceDisplay
});




}
/// @nodoc
class _$ProductPayloadCopyWithImpl<$Res>
    implements $ProductPayloadCopyWith<$Res> {
  _$ProductPayloadCopyWithImpl(this._self, this._then);

  final ProductPayload _self;
  final $Res Function(ProductPayload) _then;

/// Create a copy of ProductPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? brand = null,Object? description = null,Object? category = null,Object? imageUrl = null,Object? affiliateUrl = null,Object? priceDisplay = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,affiliateUrl: null == affiliateUrl ? _self.affiliateUrl : affiliateUrl // ignore: cast_nullable_to_non_nullable
as String,priceDisplay: null == priceDisplay ? _self.priceDisplay : priceDisplay // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductPayload].
extension ProductPayloadPatterns on ProductPayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductPayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductPayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductPayload value)  $default,){
final _that = this;
switch (_that) {
case _ProductPayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductPayload value)?  $default,){
final _that = this;
switch (_that) {
case _ProductPayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String brand,  String description,  String category, @JsonKey(name: 'image_url')  String imageUrl, @JsonKey(name: 'affiliate_url')  String affiliateUrl, @JsonKey(name: 'price_display')  String priceDisplay)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductPayload() when $default != null:
return $default(_that.name,_that.brand,_that.description,_that.category,_that.imageUrl,_that.affiliateUrl,_that.priceDisplay);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String brand,  String description,  String category, @JsonKey(name: 'image_url')  String imageUrl, @JsonKey(name: 'affiliate_url')  String affiliateUrl, @JsonKey(name: 'price_display')  String priceDisplay)  $default,) {final _that = this;
switch (_that) {
case _ProductPayload():
return $default(_that.name,_that.brand,_that.description,_that.category,_that.imageUrl,_that.affiliateUrl,_that.priceDisplay);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String brand,  String description,  String category, @JsonKey(name: 'image_url')  String imageUrl, @JsonKey(name: 'affiliate_url')  String affiliateUrl, @JsonKey(name: 'price_display')  String priceDisplay)?  $default,) {final _that = this;
switch (_that) {
case _ProductPayload() when $default != null:
return $default(_that.name,_that.brand,_that.description,_that.category,_that.imageUrl,_that.affiliateUrl,_that.priceDisplay);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductPayload implements ProductPayload {
  const _ProductPayload({required this.name, required this.brand, required this.description, required this.category, @JsonKey(name: 'image_url') required this.imageUrl, @JsonKey(name: 'affiliate_url') required this.affiliateUrl, @JsonKey(name: 'price_display') required this.priceDisplay});
  factory _ProductPayload.fromJson(Map<String, dynamic> json) => _$ProductPayloadFromJson(json);

@override final  String name;
@override final  String brand;
@override final  String description;
@override final  String category;
@override@JsonKey(name: 'image_url') final  String imageUrl;
@override@JsonKey(name: 'affiliate_url') final  String affiliateUrl;
@override@JsonKey(name: 'price_display') final  String priceDisplay;

/// Create a copy of ProductPayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductPayloadCopyWith<_ProductPayload> get copyWith => __$ProductPayloadCopyWithImpl<_ProductPayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductPayloadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductPayload&&(identical(other.name, name) || other.name == name)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.affiliateUrl, affiliateUrl) || other.affiliateUrl == affiliateUrl)&&(identical(other.priceDisplay, priceDisplay) || other.priceDisplay == priceDisplay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,brand,description,category,imageUrl,affiliateUrl,priceDisplay);

@override
String toString() {
  return 'ProductPayload(name: $name, brand: $brand, description: $description, category: $category, imageUrl: $imageUrl, affiliateUrl: $affiliateUrl, priceDisplay: $priceDisplay)';
}


}

/// @nodoc
abstract mixin class _$ProductPayloadCopyWith<$Res> implements $ProductPayloadCopyWith<$Res> {
  factory _$ProductPayloadCopyWith(_ProductPayload value, $Res Function(_ProductPayload) _then) = __$ProductPayloadCopyWithImpl;
@override @useResult
$Res call({
 String name, String brand, String description, String category,@JsonKey(name: 'image_url') String imageUrl,@JsonKey(name: 'affiliate_url') String affiliateUrl,@JsonKey(name: 'price_display') String priceDisplay
});




}
/// @nodoc
class __$ProductPayloadCopyWithImpl<$Res>
    implements _$ProductPayloadCopyWith<$Res> {
  __$ProductPayloadCopyWithImpl(this._self, this._then);

  final _ProductPayload _self;
  final $Res Function(_ProductPayload) _then;

/// Create a copy of ProductPayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? brand = null,Object? description = null,Object? category = null,Object? imageUrl = null,Object? affiliateUrl = null,Object? priceDisplay = null,}) {
  return _then(_ProductPayload(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,affiliateUrl: null == affiliateUrl ? _self.affiliateUrl : affiliateUrl // ignore: cast_nullable_to_non_nullable
as String,priceDisplay: null == priceDisplay ? _self.priceDisplay : priceDisplay // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$EventPayload {

 String get title; String get description;@JsonKey(name: 'event_type') String get eventType; String get location;@JsonKey(name: 'online_url') String? get onlineUrl;@JsonKey(name: 'start_datetime') String get startDatetime;@JsonKey(name: 'end_datetime') String get endDatetime; String get timezone; int get capacity; String? get gymId; List<String> get tags; String get category;
/// Create a copy of EventPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventPayloadCopyWith<EventPayload> get copyWith => _$EventPayloadCopyWithImpl<EventPayload>(this as EventPayload, _$identity);

  /// Serializes this EventPayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventPayload&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.location, location) || other.location == location)&&(identical(other.onlineUrl, onlineUrl) || other.onlineUrl == onlineUrl)&&(identical(other.startDatetime, startDatetime) || other.startDatetime == startDatetime)&&(identical(other.endDatetime, endDatetime) || other.endDatetime == endDatetime)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.capacity, capacity) || other.capacity == capacity)&&(identical(other.gymId, gymId) || other.gymId == gymId)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.category, category) || other.category == category));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,description,eventType,location,onlineUrl,startDatetime,endDatetime,timezone,capacity,gymId,const DeepCollectionEquality().hash(tags),category);

@override
String toString() {
  return 'EventPayload(title: $title, description: $description, eventType: $eventType, location: $location, onlineUrl: $onlineUrl, startDatetime: $startDatetime, endDatetime: $endDatetime, timezone: $timezone, capacity: $capacity, gymId: $gymId, tags: $tags, category: $category)';
}


}

/// @nodoc
abstract mixin class $EventPayloadCopyWith<$Res>  {
  factory $EventPayloadCopyWith(EventPayload value, $Res Function(EventPayload) _then) = _$EventPayloadCopyWithImpl;
@useResult
$Res call({
 String title, String description,@JsonKey(name: 'event_type') String eventType, String location,@JsonKey(name: 'online_url') String? onlineUrl,@JsonKey(name: 'start_datetime') String startDatetime,@JsonKey(name: 'end_datetime') String endDatetime, String timezone, int capacity, String? gymId, List<String> tags, String category
});




}
/// @nodoc
class _$EventPayloadCopyWithImpl<$Res>
    implements $EventPayloadCopyWith<$Res> {
  _$EventPayloadCopyWithImpl(this._self, this._then);

  final EventPayload _self;
  final $Res Function(EventPayload) _then;

/// Create a copy of EventPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? description = null,Object? eventType = null,Object? location = null,Object? onlineUrl = freezed,Object? startDatetime = null,Object? endDatetime = null,Object? timezone = null,Object? capacity = null,Object? gymId = freezed,Object? tags = null,Object? category = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,onlineUrl: freezed == onlineUrl ? _self.onlineUrl : onlineUrl // ignore: cast_nullable_to_non_nullable
as String?,startDatetime: null == startDatetime ? _self.startDatetime : startDatetime // ignore: cast_nullable_to_non_nullable
as String,endDatetime: null == endDatetime ? _self.endDatetime : endDatetime // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,capacity: null == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int,gymId: freezed == gymId ? _self.gymId : gymId // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [EventPayload].
extension EventPayloadPatterns on EventPayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventPayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventPayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventPayload value)  $default,){
final _that = this;
switch (_that) {
case _EventPayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventPayload value)?  $default,){
final _that = this;
switch (_that) {
case _EventPayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String description, @JsonKey(name: 'event_type')  String eventType,  String location, @JsonKey(name: 'online_url')  String? onlineUrl, @JsonKey(name: 'start_datetime')  String startDatetime, @JsonKey(name: 'end_datetime')  String endDatetime,  String timezone,  int capacity,  String? gymId,  List<String> tags,  String category)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventPayload() when $default != null:
return $default(_that.title,_that.description,_that.eventType,_that.location,_that.onlineUrl,_that.startDatetime,_that.endDatetime,_that.timezone,_that.capacity,_that.gymId,_that.tags,_that.category);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String description, @JsonKey(name: 'event_type')  String eventType,  String location, @JsonKey(name: 'online_url')  String? onlineUrl, @JsonKey(name: 'start_datetime')  String startDatetime, @JsonKey(name: 'end_datetime')  String endDatetime,  String timezone,  int capacity,  String? gymId,  List<String> tags,  String category)  $default,) {final _that = this;
switch (_that) {
case _EventPayload():
return $default(_that.title,_that.description,_that.eventType,_that.location,_that.onlineUrl,_that.startDatetime,_that.endDatetime,_that.timezone,_that.capacity,_that.gymId,_that.tags,_that.category);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String description, @JsonKey(name: 'event_type')  String eventType,  String location, @JsonKey(name: 'online_url')  String? onlineUrl, @JsonKey(name: 'start_datetime')  String startDatetime, @JsonKey(name: 'end_datetime')  String endDatetime,  String timezone,  int capacity,  String? gymId,  List<String> tags,  String category)?  $default,) {final _that = this;
switch (_that) {
case _EventPayload() when $default != null:
return $default(_that.title,_that.description,_that.eventType,_that.location,_that.onlineUrl,_that.startDatetime,_that.endDatetime,_that.timezone,_that.capacity,_that.gymId,_that.tags,_that.category);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventPayload implements EventPayload {
  const _EventPayload({required this.title, required this.description, @JsonKey(name: 'event_type') required this.eventType, required this.location, @JsonKey(name: 'online_url') this.onlineUrl, @JsonKey(name: 'start_datetime') required this.startDatetime, @JsonKey(name: 'end_datetime') required this.endDatetime, required this.timezone, required this.capacity, this.gymId, final  List<String> tags = const <String>[], this.category = ''}): _tags = tags;
  factory _EventPayload.fromJson(Map<String, dynamic> json) => _$EventPayloadFromJson(json);

@override final  String title;
@override final  String description;
@override@JsonKey(name: 'event_type') final  String eventType;
@override final  String location;
@override@JsonKey(name: 'online_url') final  String? onlineUrl;
@override@JsonKey(name: 'start_datetime') final  String startDatetime;
@override@JsonKey(name: 'end_datetime') final  String endDatetime;
@override final  String timezone;
@override final  int capacity;
@override final  String? gymId;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override@JsonKey() final  String category;

/// Create a copy of EventPayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventPayloadCopyWith<_EventPayload> get copyWith => __$EventPayloadCopyWithImpl<_EventPayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventPayloadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventPayload&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.location, location) || other.location == location)&&(identical(other.onlineUrl, onlineUrl) || other.onlineUrl == onlineUrl)&&(identical(other.startDatetime, startDatetime) || other.startDatetime == startDatetime)&&(identical(other.endDatetime, endDatetime) || other.endDatetime == endDatetime)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.capacity, capacity) || other.capacity == capacity)&&(identical(other.gymId, gymId) || other.gymId == gymId)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.category, category) || other.category == category));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,description,eventType,location,onlineUrl,startDatetime,endDatetime,timezone,capacity,gymId,const DeepCollectionEquality().hash(_tags),category);

@override
String toString() {
  return 'EventPayload(title: $title, description: $description, eventType: $eventType, location: $location, onlineUrl: $onlineUrl, startDatetime: $startDatetime, endDatetime: $endDatetime, timezone: $timezone, capacity: $capacity, gymId: $gymId, tags: $tags, category: $category)';
}


}

/// @nodoc
abstract mixin class _$EventPayloadCopyWith<$Res> implements $EventPayloadCopyWith<$Res> {
  factory _$EventPayloadCopyWith(_EventPayload value, $Res Function(_EventPayload) _then) = __$EventPayloadCopyWithImpl;
@override @useResult
$Res call({
 String title, String description,@JsonKey(name: 'event_type') String eventType, String location,@JsonKey(name: 'online_url') String? onlineUrl,@JsonKey(name: 'start_datetime') String startDatetime,@JsonKey(name: 'end_datetime') String endDatetime, String timezone, int capacity, String? gymId, List<String> tags, String category
});




}
/// @nodoc
class __$EventPayloadCopyWithImpl<$Res>
    implements _$EventPayloadCopyWith<$Res> {
  __$EventPayloadCopyWithImpl(this._self, this._then);

  final _EventPayload _self;
  final $Res Function(_EventPayload) _then;

/// Create a copy of EventPayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? description = null,Object? eventType = null,Object? location = null,Object? onlineUrl = freezed,Object? startDatetime = null,Object? endDatetime = null,Object? timezone = null,Object? capacity = null,Object? gymId = freezed,Object? tags = null,Object? category = null,}) {
  return _then(_EventPayload(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,onlineUrl: freezed == onlineUrl ? _self.onlineUrl : onlineUrl // ignore: cast_nullable_to_non_nullable
as String?,startDatetime: null == startDatetime ? _self.startDatetime : startDatetime // ignore: cast_nullable_to_non_nullable
as String,endDatetime: null == endDatetime ? _self.endDatetime : endDatetime // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,capacity: null == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int,gymId: freezed == gymId ? _self.gymId : gymId // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CheckoutResponse {

 String get status; List<String> get purchased; List<String> get errors;
/// Create a copy of CheckoutResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckoutResponseCopyWith<CheckoutResponse> get copyWith => _$CheckoutResponseCopyWithImpl<CheckoutResponse>(this as CheckoutResponse, _$identity);

  /// Serializes this CheckoutResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckoutResponse&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.purchased, purchased)&&const DeepCollectionEquality().equals(other.errors, errors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(purchased),const DeepCollectionEquality().hash(errors));

@override
String toString() {
  return 'CheckoutResponse(status: $status, purchased: $purchased, errors: $errors)';
}


}

/// @nodoc
abstract mixin class $CheckoutResponseCopyWith<$Res>  {
  factory $CheckoutResponseCopyWith(CheckoutResponse value, $Res Function(CheckoutResponse) _then) = _$CheckoutResponseCopyWithImpl;
@useResult
$Res call({
 String status, List<String> purchased, List<String> errors
});




}
/// @nodoc
class _$CheckoutResponseCopyWithImpl<$Res>
    implements $CheckoutResponseCopyWith<$Res> {
  _$CheckoutResponseCopyWithImpl(this._self, this._then);

  final CheckoutResponse _self;
  final $Res Function(CheckoutResponse) _then;

/// Create a copy of CheckoutResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? purchased = null,Object? errors = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,purchased: null == purchased ? _self.purchased : purchased // ignore: cast_nullable_to_non_nullable
as List<String>,errors: null == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [CheckoutResponse].
extension CheckoutResponsePatterns on CheckoutResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckoutResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckoutResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckoutResponse value)  $default,){
final _that = this;
switch (_that) {
case _CheckoutResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckoutResponse value)?  $default,){
final _that = this;
switch (_that) {
case _CheckoutResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String status,  List<String> purchased,  List<String> errors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckoutResponse() when $default != null:
return $default(_that.status,_that.purchased,_that.errors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String status,  List<String> purchased,  List<String> errors)  $default,) {final _that = this;
switch (_that) {
case _CheckoutResponse():
return $default(_that.status,_that.purchased,_that.errors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String status,  List<String> purchased,  List<String> errors)?  $default,) {final _that = this;
switch (_that) {
case _CheckoutResponse() when $default != null:
return $default(_that.status,_that.purchased,_that.errors);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CheckoutResponse implements CheckoutResponse {
  const _CheckoutResponse({required this.status, final  List<String> purchased = const <String>[], final  List<String> errors = const <String>[]}): _purchased = purchased,_errors = errors;
  factory _CheckoutResponse.fromJson(Map<String, dynamic> json) => _$CheckoutResponseFromJson(json);

@override final  String status;
 final  List<String> _purchased;
@override@JsonKey() List<String> get purchased {
  if (_purchased is EqualUnmodifiableListView) return _purchased;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_purchased);
}

 final  List<String> _errors;
@override@JsonKey() List<String> get errors {
  if (_errors is EqualUnmodifiableListView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_errors);
}


/// Create a copy of CheckoutResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckoutResponseCopyWith<_CheckoutResponse> get copyWith => __$CheckoutResponseCopyWithImpl<_CheckoutResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CheckoutResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckoutResponse&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._purchased, _purchased)&&const DeepCollectionEquality().equals(other._errors, _errors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_purchased),const DeepCollectionEquality().hash(_errors));

@override
String toString() {
  return 'CheckoutResponse(status: $status, purchased: $purchased, errors: $errors)';
}


}

/// @nodoc
abstract mixin class _$CheckoutResponseCopyWith<$Res> implements $CheckoutResponseCopyWith<$Res> {
  factory _$CheckoutResponseCopyWith(_CheckoutResponse value, $Res Function(_CheckoutResponse) _then) = __$CheckoutResponseCopyWithImpl;
@override @useResult
$Res call({
 String status, List<String> purchased, List<String> errors
});




}
/// @nodoc
class __$CheckoutResponseCopyWithImpl<$Res>
    implements _$CheckoutResponseCopyWith<$Res> {
  __$CheckoutResponseCopyWithImpl(this._self, this._then);

  final _CheckoutResponse _self;
  final $Res Function(_CheckoutResponse) _then;

/// Create a copy of CheckoutResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? purchased = null,Object? errors = null,}) {
  return _then(_CheckoutResponse(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,purchased: null == purchased ? _self._purchased : purchased // ignore: cast_nullable_to_non_nullable
as List<String>,errors: null == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$OrderTimelineEntry {

 String get status; String? get at; String get note;
/// Create a copy of OrderTimelineEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderTimelineEntryCopyWith<OrderTimelineEntry> get copyWith => _$OrderTimelineEntryCopyWithImpl<OrderTimelineEntry>(this as OrderTimelineEntry, _$identity);

  /// Serializes this OrderTimelineEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderTimelineEntry&&(identical(other.status, status) || other.status == status)&&(identical(other.at, at) || other.at == at)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,at,note);

@override
String toString() {
  return 'OrderTimelineEntry(status: $status, at: $at, note: $note)';
}


}

/// @nodoc
abstract mixin class $OrderTimelineEntryCopyWith<$Res>  {
  factory $OrderTimelineEntryCopyWith(OrderTimelineEntry value, $Res Function(OrderTimelineEntry) _then) = _$OrderTimelineEntryCopyWithImpl;
@useResult
$Res call({
 String status, String? at, String note
});




}
/// @nodoc
class _$OrderTimelineEntryCopyWithImpl<$Res>
    implements $OrderTimelineEntryCopyWith<$Res> {
  _$OrderTimelineEntryCopyWithImpl(this._self, this._then);

  final OrderTimelineEntry _self;
  final $Res Function(OrderTimelineEntry) _then;

/// Create a copy of OrderTimelineEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? at = freezed,Object? note = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,at: freezed == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as String?,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderTimelineEntry].
extension OrderTimelineEntryPatterns on OrderTimelineEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderTimelineEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderTimelineEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderTimelineEntry value)  $default,){
final _that = this;
switch (_that) {
case _OrderTimelineEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderTimelineEntry value)?  $default,){
final _that = this;
switch (_that) {
case _OrderTimelineEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String status,  String? at,  String note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderTimelineEntry() when $default != null:
return $default(_that.status,_that.at,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String status,  String? at,  String note)  $default,) {final _that = this;
switch (_that) {
case _OrderTimelineEntry():
return $default(_that.status,_that.at,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String status,  String? at,  String note)?  $default,) {final _that = this;
switch (_that) {
case _OrderTimelineEntry() when $default != null:
return $default(_that.status,_that.at,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderTimelineEntry implements OrderTimelineEntry {
  const _OrderTimelineEntry({this.status = '', this.at, this.note = ''});
  factory _OrderTimelineEntry.fromJson(Map<String, dynamic> json) => _$OrderTimelineEntryFromJson(json);

@override@JsonKey() final  String status;
@override final  String? at;
@override@JsonKey() final  String note;

/// Create a copy of OrderTimelineEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderTimelineEntryCopyWith<_OrderTimelineEntry> get copyWith => __$OrderTimelineEntryCopyWithImpl<_OrderTimelineEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderTimelineEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderTimelineEntry&&(identical(other.status, status) || other.status == status)&&(identical(other.at, at) || other.at == at)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,at,note);

@override
String toString() {
  return 'OrderTimelineEntry(status: $status, at: $at, note: $note)';
}


}

/// @nodoc
abstract mixin class _$OrderTimelineEntryCopyWith<$Res> implements $OrderTimelineEntryCopyWith<$Res> {
  factory _$OrderTimelineEntryCopyWith(_OrderTimelineEntry value, $Res Function(_OrderTimelineEntry) _then) = __$OrderTimelineEntryCopyWithImpl;
@override @useResult
$Res call({
 String status, String? at, String note
});




}
/// @nodoc
class __$OrderTimelineEntryCopyWithImpl<$Res>
    implements _$OrderTimelineEntryCopyWith<$Res> {
  __$OrderTimelineEntryCopyWithImpl(this._self, this._then);

  final _OrderTimelineEntry _self;
  final $Res Function(_OrderTimelineEntry) _then;

/// Create a copy of OrderTimelineEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? at = freezed,Object? note = null,}) {
  return _then(_OrderTimelineEntry(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,at: freezed == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as String?,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$OrderFulfillment {

 String get carrier;@JsonKey(name: 'tracking_number') String get trackingNumber;@JsonKey(name: 'tracking_url') String get trackingUrl;@JsonKey(name: 'pickup_location') String get pickupLocation; String get notes; List<OrderTimelineEntry> get timeline;@JsonKey(name: 'shipped_at') String? get shippedAt;@JsonKey(name: 'out_for_delivery_at') String? get outForDeliveryAt;@JsonKey(name: 'ready_for_pickup_at') String? get readyForPickupAt;@JsonKey(name: 'delivered_at') String? get deliveredAt;
/// Create a copy of OrderFulfillment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderFulfillmentCopyWith<OrderFulfillment> get copyWith => _$OrderFulfillmentCopyWithImpl<OrderFulfillment>(this as OrderFulfillment, _$identity);

  /// Serializes this OrderFulfillment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderFulfillment&&(identical(other.carrier, carrier) || other.carrier == carrier)&&(identical(other.trackingNumber, trackingNumber) || other.trackingNumber == trackingNumber)&&(identical(other.trackingUrl, trackingUrl) || other.trackingUrl == trackingUrl)&&(identical(other.pickupLocation, pickupLocation) || other.pickupLocation == pickupLocation)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other.timeline, timeline)&&(identical(other.shippedAt, shippedAt) || other.shippedAt == shippedAt)&&(identical(other.outForDeliveryAt, outForDeliveryAt) || other.outForDeliveryAt == outForDeliveryAt)&&(identical(other.readyForPickupAt, readyForPickupAt) || other.readyForPickupAt == readyForPickupAt)&&(identical(other.deliveredAt, deliveredAt) || other.deliveredAt == deliveredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,carrier,trackingNumber,trackingUrl,pickupLocation,notes,const DeepCollectionEquality().hash(timeline),shippedAt,outForDeliveryAt,readyForPickupAt,deliveredAt);

@override
String toString() {
  return 'OrderFulfillment(carrier: $carrier, trackingNumber: $trackingNumber, trackingUrl: $trackingUrl, pickupLocation: $pickupLocation, notes: $notes, timeline: $timeline, shippedAt: $shippedAt, outForDeliveryAt: $outForDeliveryAt, readyForPickupAt: $readyForPickupAt, deliveredAt: $deliveredAt)';
}


}

/// @nodoc
abstract mixin class $OrderFulfillmentCopyWith<$Res>  {
  factory $OrderFulfillmentCopyWith(OrderFulfillment value, $Res Function(OrderFulfillment) _then) = _$OrderFulfillmentCopyWithImpl;
@useResult
$Res call({
 String carrier,@JsonKey(name: 'tracking_number') String trackingNumber,@JsonKey(name: 'tracking_url') String trackingUrl,@JsonKey(name: 'pickup_location') String pickupLocation, String notes, List<OrderTimelineEntry> timeline,@JsonKey(name: 'shipped_at') String? shippedAt,@JsonKey(name: 'out_for_delivery_at') String? outForDeliveryAt,@JsonKey(name: 'ready_for_pickup_at') String? readyForPickupAt,@JsonKey(name: 'delivered_at') String? deliveredAt
});




}
/// @nodoc
class _$OrderFulfillmentCopyWithImpl<$Res>
    implements $OrderFulfillmentCopyWith<$Res> {
  _$OrderFulfillmentCopyWithImpl(this._self, this._then);

  final OrderFulfillment _self;
  final $Res Function(OrderFulfillment) _then;

/// Create a copy of OrderFulfillment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? carrier = null,Object? trackingNumber = null,Object? trackingUrl = null,Object? pickupLocation = null,Object? notes = null,Object? timeline = null,Object? shippedAt = freezed,Object? outForDeliveryAt = freezed,Object? readyForPickupAt = freezed,Object? deliveredAt = freezed,}) {
  return _then(_self.copyWith(
carrier: null == carrier ? _self.carrier : carrier // ignore: cast_nullable_to_non_nullable
as String,trackingNumber: null == trackingNumber ? _self.trackingNumber : trackingNumber // ignore: cast_nullable_to_non_nullable
as String,trackingUrl: null == trackingUrl ? _self.trackingUrl : trackingUrl // ignore: cast_nullable_to_non_nullable
as String,pickupLocation: null == pickupLocation ? _self.pickupLocation : pickupLocation // ignore: cast_nullable_to_non_nullable
as String,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,timeline: null == timeline ? _self.timeline : timeline // ignore: cast_nullable_to_non_nullable
as List<OrderTimelineEntry>,shippedAt: freezed == shippedAt ? _self.shippedAt : shippedAt // ignore: cast_nullable_to_non_nullable
as String?,outForDeliveryAt: freezed == outForDeliveryAt ? _self.outForDeliveryAt : outForDeliveryAt // ignore: cast_nullable_to_non_nullable
as String?,readyForPickupAt: freezed == readyForPickupAt ? _self.readyForPickupAt : readyForPickupAt // ignore: cast_nullable_to_non_nullable
as String?,deliveredAt: freezed == deliveredAt ? _self.deliveredAt : deliveredAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderFulfillment].
extension OrderFulfillmentPatterns on OrderFulfillment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderFulfillment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderFulfillment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderFulfillment value)  $default,){
final _that = this;
switch (_that) {
case _OrderFulfillment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderFulfillment value)?  $default,){
final _that = this;
switch (_that) {
case _OrderFulfillment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String carrier, @JsonKey(name: 'tracking_number')  String trackingNumber, @JsonKey(name: 'tracking_url')  String trackingUrl, @JsonKey(name: 'pickup_location')  String pickupLocation,  String notes,  List<OrderTimelineEntry> timeline, @JsonKey(name: 'shipped_at')  String? shippedAt, @JsonKey(name: 'out_for_delivery_at')  String? outForDeliveryAt, @JsonKey(name: 'ready_for_pickup_at')  String? readyForPickupAt, @JsonKey(name: 'delivered_at')  String? deliveredAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderFulfillment() when $default != null:
return $default(_that.carrier,_that.trackingNumber,_that.trackingUrl,_that.pickupLocation,_that.notes,_that.timeline,_that.shippedAt,_that.outForDeliveryAt,_that.readyForPickupAt,_that.deliveredAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String carrier, @JsonKey(name: 'tracking_number')  String trackingNumber, @JsonKey(name: 'tracking_url')  String trackingUrl, @JsonKey(name: 'pickup_location')  String pickupLocation,  String notes,  List<OrderTimelineEntry> timeline, @JsonKey(name: 'shipped_at')  String? shippedAt, @JsonKey(name: 'out_for_delivery_at')  String? outForDeliveryAt, @JsonKey(name: 'ready_for_pickup_at')  String? readyForPickupAt, @JsonKey(name: 'delivered_at')  String? deliveredAt)  $default,) {final _that = this;
switch (_that) {
case _OrderFulfillment():
return $default(_that.carrier,_that.trackingNumber,_that.trackingUrl,_that.pickupLocation,_that.notes,_that.timeline,_that.shippedAt,_that.outForDeliveryAt,_that.readyForPickupAt,_that.deliveredAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String carrier, @JsonKey(name: 'tracking_number')  String trackingNumber, @JsonKey(name: 'tracking_url')  String trackingUrl, @JsonKey(name: 'pickup_location')  String pickupLocation,  String notes,  List<OrderTimelineEntry> timeline, @JsonKey(name: 'shipped_at')  String? shippedAt, @JsonKey(name: 'out_for_delivery_at')  String? outForDeliveryAt, @JsonKey(name: 'ready_for_pickup_at')  String? readyForPickupAt, @JsonKey(name: 'delivered_at')  String? deliveredAt)?  $default,) {final _that = this;
switch (_that) {
case _OrderFulfillment() when $default != null:
return $default(_that.carrier,_that.trackingNumber,_that.trackingUrl,_that.pickupLocation,_that.notes,_that.timeline,_that.shippedAt,_that.outForDeliveryAt,_that.readyForPickupAt,_that.deliveredAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderFulfillment implements OrderFulfillment {
  const _OrderFulfillment({this.carrier = '', @JsonKey(name: 'tracking_number') this.trackingNumber = '', @JsonKey(name: 'tracking_url') this.trackingUrl = '', @JsonKey(name: 'pickup_location') this.pickupLocation = '', this.notes = '', final  List<OrderTimelineEntry> timeline = const <OrderTimelineEntry>[], @JsonKey(name: 'shipped_at') this.shippedAt, @JsonKey(name: 'out_for_delivery_at') this.outForDeliveryAt, @JsonKey(name: 'ready_for_pickup_at') this.readyForPickupAt, @JsonKey(name: 'delivered_at') this.deliveredAt}): _timeline = timeline;
  factory _OrderFulfillment.fromJson(Map<String, dynamic> json) => _$OrderFulfillmentFromJson(json);

@override@JsonKey() final  String carrier;
@override@JsonKey(name: 'tracking_number') final  String trackingNumber;
@override@JsonKey(name: 'tracking_url') final  String trackingUrl;
@override@JsonKey(name: 'pickup_location') final  String pickupLocation;
@override@JsonKey() final  String notes;
 final  List<OrderTimelineEntry> _timeline;
@override@JsonKey() List<OrderTimelineEntry> get timeline {
  if (_timeline is EqualUnmodifiableListView) return _timeline;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_timeline);
}

@override@JsonKey(name: 'shipped_at') final  String? shippedAt;
@override@JsonKey(name: 'out_for_delivery_at') final  String? outForDeliveryAt;
@override@JsonKey(name: 'ready_for_pickup_at') final  String? readyForPickupAt;
@override@JsonKey(name: 'delivered_at') final  String? deliveredAt;

/// Create a copy of OrderFulfillment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderFulfillmentCopyWith<_OrderFulfillment> get copyWith => __$OrderFulfillmentCopyWithImpl<_OrderFulfillment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderFulfillmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderFulfillment&&(identical(other.carrier, carrier) || other.carrier == carrier)&&(identical(other.trackingNumber, trackingNumber) || other.trackingNumber == trackingNumber)&&(identical(other.trackingUrl, trackingUrl) || other.trackingUrl == trackingUrl)&&(identical(other.pickupLocation, pickupLocation) || other.pickupLocation == pickupLocation)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other._timeline, _timeline)&&(identical(other.shippedAt, shippedAt) || other.shippedAt == shippedAt)&&(identical(other.outForDeliveryAt, outForDeliveryAt) || other.outForDeliveryAt == outForDeliveryAt)&&(identical(other.readyForPickupAt, readyForPickupAt) || other.readyForPickupAt == readyForPickupAt)&&(identical(other.deliveredAt, deliveredAt) || other.deliveredAt == deliveredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,carrier,trackingNumber,trackingUrl,pickupLocation,notes,const DeepCollectionEquality().hash(_timeline),shippedAt,outForDeliveryAt,readyForPickupAt,deliveredAt);

@override
String toString() {
  return 'OrderFulfillment(carrier: $carrier, trackingNumber: $trackingNumber, trackingUrl: $trackingUrl, pickupLocation: $pickupLocation, notes: $notes, timeline: $timeline, shippedAt: $shippedAt, outForDeliveryAt: $outForDeliveryAt, readyForPickupAt: $readyForPickupAt, deliveredAt: $deliveredAt)';
}


}

/// @nodoc
abstract mixin class _$OrderFulfillmentCopyWith<$Res> implements $OrderFulfillmentCopyWith<$Res> {
  factory _$OrderFulfillmentCopyWith(_OrderFulfillment value, $Res Function(_OrderFulfillment) _then) = __$OrderFulfillmentCopyWithImpl;
@override @useResult
$Res call({
 String carrier,@JsonKey(name: 'tracking_number') String trackingNumber,@JsonKey(name: 'tracking_url') String trackingUrl,@JsonKey(name: 'pickup_location') String pickupLocation, String notes, List<OrderTimelineEntry> timeline,@JsonKey(name: 'shipped_at') String? shippedAt,@JsonKey(name: 'out_for_delivery_at') String? outForDeliveryAt,@JsonKey(name: 'ready_for_pickup_at') String? readyForPickupAt,@JsonKey(name: 'delivered_at') String? deliveredAt
});




}
/// @nodoc
class __$OrderFulfillmentCopyWithImpl<$Res>
    implements _$OrderFulfillmentCopyWith<$Res> {
  __$OrderFulfillmentCopyWithImpl(this._self, this._then);

  final _OrderFulfillment _self;
  final $Res Function(_OrderFulfillment) _then;

/// Create a copy of OrderFulfillment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? carrier = null,Object? trackingNumber = null,Object? trackingUrl = null,Object? pickupLocation = null,Object? notes = null,Object? timeline = null,Object? shippedAt = freezed,Object? outForDeliveryAt = freezed,Object? readyForPickupAt = freezed,Object? deliveredAt = freezed,}) {
  return _then(_OrderFulfillment(
carrier: null == carrier ? _self.carrier : carrier // ignore: cast_nullable_to_non_nullable
as String,trackingNumber: null == trackingNumber ? _self.trackingNumber : trackingNumber // ignore: cast_nullable_to_non_nullable
as String,trackingUrl: null == trackingUrl ? _self.trackingUrl : trackingUrl // ignore: cast_nullable_to_non_nullable
as String,pickupLocation: null == pickupLocation ? _self.pickupLocation : pickupLocation // ignore: cast_nullable_to_non_nullable
as String,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,timeline: null == timeline ? _self._timeline : timeline // ignore: cast_nullable_to_non_nullable
as List<OrderTimelineEntry>,shippedAt: freezed == shippedAt ? _self.shippedAt : shippedAt // ignore: cast_nullable_to_non_nullable
as String?,outForDeliveryAt: freezed == outForDeliveryAt ? _self.outForDeliveryAt : outForDeliveryAt // ignore: cast_nullable_to_non_nullable
as String?,readyForPickupAt: freezed == readyForPickupAt ? _self.readyForPickupAt : readyForPickupAt // ignore: cast_nullable_to_non_nullable
as String?,deliveredAt: freezed == deliveredAt ? _self.deliveredAt : deliveredAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$OrderItem {

@JsonKey(name: 'item_type') String get itemType; String get title; int get quantity;@JsonKey(name: 'price_artifacts') Map<String, int> get priceArtifacts;@JsonKey(name: 'paid_artifacts') Map<String, int> get paidArtifacts;@JsonKey(name: 'creator_name') String? get creatorName;@JsonKey(name: 'created_at') String? get createdAt;
/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderItemCopyWith<OrderItem> get copyWith => _$OrderItemCopyWithImpl<OrderItem>(this as OrderItem, _$identity);

  /// Serializes this OrderItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderItem&&(identical(other.itemType, itemType) || other.itemType == itemType)&&(identical(other.title, title) || other.title == title)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&const DeepCollectionEquality().equals(other.priceArtifacts, priceArtifacts)&&const DeepCollectionEquality().equals(other.paidArtifacts, paidArtifacts)&&(identical(other.creatorName, creatorName) || other.creatorName == creatorName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,itemType,title,quantity,const DeepCollectionEquality().hash(priceArtifacts),const DeepCollectionEquality().hash(paidArtifacts),creatorName,createdAt);

@override
String toString() {
  return 'OrderItem(itemType: $itemType, title: $title, quantity: $quantity, priceArtifacts: $priceArtifacts, paidArtifacts: $paidArtifacts, creatorName: $creatorName, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $OrderItemCopyWith<$Res>  {
  factory $OrderItemCopyWith(OrderItem value, $Res Function(OrderItem) _then) = _$OrderItemCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'item_type') String itemType, String title, int quantity,@JsonKey(name: 'price_artifacts') Map<String, int> priceArtifacts,@JsonKey(name: 'paid_artifacts') Map<String, int> paidArtifacts,@JsonKey(name: 'creator_name') String? creatorName,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class _$OrderItemCopyWithImpl<$Res>
    implements $OrderItemCopyWith<$Res> {
  _$OrderItemCopyWithImpl(this._self, this._then);

  final OrderItem _self;
  final $Res Function(OrderItem) _then;

/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? itemType = null,Object? title = null,Object? quantity = null,Object? priceArtifacts = null,Object? paidArtifacts = null,Object? creatorName = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
itemType: null == itemType ? _self.itemType : itemType // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,priceArtifacts: null == priceArtifacts ? _self.priceArtifacts : priceArtifacts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,paidArtifacts: null == paidArtifacts ? _self.paidArtifacts : paidArtifacts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,creatorName: freezed == creatorName ? _self.creatorName : creatorName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderItem].
extension OrderItemPatterns on OrderItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderItem value)  $default,){
final _that = this;
switch (_that) {
case _OrderItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderItem value)?  $default,){
final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'item_type')  String itemType,  String title,  int quantity, @JsonKey(name: 'price_artifacts')  Map<String, int> priceArtifacts, @JsonKey(name: 'paid_artifacts')  Map<String, int> paidArtifacts, @JsonKey(name: 'creator_name')  String? creatorName, @JsonKey(name: 'created_at')  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
return $default(_that.itemType,_that.title,_that.quantity,_that.priceArtifacts,_that.paidArtifacts,_that.creatorName,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'item_type')  String itemType,  String title,  int quantity, @JsonKey(name: 'price_artifacts')  Map<String, int> priceArtifacts, @JsonKey(name: 'paid_artifacts')  Map<String, int> paidArtifacts, @JsonKey(name: 'creator_name')  String? creatorName, @JsonKey(name: 'created_at')  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _OrderItem():
return $default(_that.itemType,_that.title,_that.quantity,_that.priceArtifacts,_that.paidArtifacts,_that.creatorName,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'item_type')  String itemType,  String title,  int quantity, @JsonKey(name: 'price_artifacts')  Map<String, int> priceArtifacts, @JsonKey(name: 'paid_artifacts')  Map<String, int> paidArtifacts, @JsonKey(name: 'creator_name')  String? creatorName, @JsonKey(name: 'created_at')  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
return $default(_that.itemType,_that.title,_that.quantity,_that.priceArtifacts,_that.paidArtifacts,_that.creatorName,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderItem implements OrderItem {
  const _OrderItem({@JsonKey(name: 'item_type') this.itemType = '', this.title = '', this.quantity = 1, @JsonKey(name: 'price_artifacts') final  Map<String, int> priceArtifacts = const <String, int>{}, @JsonKey(name: 'paid_artifacts') final  Map<String, int> paidArtifacts = const <String, int>{}, @JsonKey(name: 'creator_name') this.creatorName, @JsonKey(name: 'created_at') this.createdAt}): _priceArtifacts = priceArtifacts,_paidArtifacts = paidArtifacts;
  factory _OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);

@override@JsonKey(name: 'item_type') final  String itemType;
@override@JsonKey() final  String title;
@override@JsonKey() final  int quantity;
 final  Map<String, int> _priceArtifacts;
@override@JsonKey(name: 'price_artifacts') Map<String, int> get priceArtifacts {
  if (_priceArtifacts is EqualUnmodifiableMapView) return _priceArtifacts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_priceArtifacts);
}

 final  Map<String, int> _paidArtifacts;
@override@JsonKey(name: 'paid_artifacts') Map<String, int> get paidArtifacts {
  if (_paidArtifacts is EqualUnmodifiableMapView) return _paidArtifacts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_paidArtifacts);
}

@override@JsonKey(name: 'creator_name') final  String? creatorName;
@override@JsonKey(name: 'created_at') final  String? createdAt;

/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderItemCopyWith<_OrderItem> get copyWith => __$OrderItemCopyWithImpl<_OrderItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderItem&&(identical(other.itemType, itemType) || other.itemType == itemType)&&(identical(other.title, title) || other.title == title)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&const DeepCollectionEquality().equals(other._priceArtifacts, _priceArtifacts)&&const DeepCollectionEquality().equals(other._paidArtifacts, _paidArtifacts)&&(identical(other.creatorName, creatorName) || other.creatorName == creatorName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,itemType,title,quantity,const DeepCollectionEquality().hash(_priceArtifacts),const DeepCollectionEquality().hash(_paidArtifacts),creatorName,createdAt);

@override
String toString() {
  return 'OrderItem(itemType: $itemType, title: $title, quantity: $quantity, priceArtifacts: $priceArtifacts, paidArtifacts: $paidArtifacts, creatorName: $creatorName, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$OrderItemCopyWith<$Res> implements $OrderItemCopyWith<$Res> {
  factory _$OrderItemCopyWith(_OrderItem value, $Res Function(_OrderItem) _then) = __$OrderItemCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'item_type') String itemType, String title, int quantity,@JsonKey(name: 'price_artifacts') Map<String, int> priceArtifacts,@JsonKey(name: 'paid_artifacts') Map<String, int> paidArtifacts,@JsonKey(name: 'creator_name') String? creatorName,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class __$OrderItemCopyWithImpl<$Res>
    implements _$OrderItemCopyWith<$Res> {
  __$OrderItemCopyWithImpl(this._self, this._then);

  final _OrderItem _self;
  final $Res Function(_OrderItem) _then;

/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? itemType = null,Object? title = null,Object? quantity = null,Object? priceArtifacts = null,Object? paidArtifacts = null,Object? creatorName = freezed,Object? createdAt = freezed,}) {
  return _then(_OrderItem(
itemType: null == itemType ? _self.itemType : itemType // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,priceArtifacts: null == priceArtifacts ? _self._priceArtifacts : priceArtifacts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,paidArtifacts: null == paidArtifacts ? _self._paidArtifacts : paidArtifacts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,creatorName: freezed == creatorName ? _self.creatorName : creatorName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Order {

 String get id;@JsonKey(name: 'order_number') String get orderNumber; String get status;@JsonKey(name: 'status_label') String get statusLabel;@JsonKey(name: 'fulfillment_type') String get fulfillmentType;@JsonKey(name: 'delivery_address') Map<String, dynamic> get deliveryAddress;@JsonKey(name: 'pickup_details') Map<String, dynamic> get pickupDetails;@JsonKey(name: 'total_artifacts') Map<String, int> get totalArtifacts;@JsonKey(name: 'discount_artifacts') Map<String, int> get discountArtifacts; double get spentUsd;@JsonKey(name: 'discount_code') String? get discountCode;@JsonKey(name: 'status_history') List<OrderTimelineEntry> get statusHistory; List<OrderItem> get items; OrderFulfillment? get fulfillment;@JsonKey(name: 'is_seller') bool get isSeller;@JsonKey(name: 'paid_at') String? get paidAt;@JsonKey(name: 'created_at') String? get createdAt;
/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderCopyWith<Order> get copyWith => _$OrderCopyWithImpl<Order>(this as Order, _$identity);

  /// Serializes this Order to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Order&&(identical(other.id, id) || other.id == id)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusLabel, statusLabel) || other.statusLabel == statusLabel)&&(identical(other.fulfillmentType, fulfillmentType) || other.fulfillmentType == fulfillmentType)&&const DeepCollectionEquality().equals(other.deliveryAddress, deliveryAddress)&&const DeepCollectionEquality().equals(other.pickupDetails, pickupDetails)&&const DeepCollectionEquality().equals(other.totalArtifacts, totalArtifacts)&&const DeepCollectionEquality().equals(other.discountArtifacts, discountArtifacts)&&(identical(other.spentUsd, spentUsd) || other.spentUsd == spentUsd)&&(identical(other.discountCode, discountCode) || other.discountCode == discountCode)&&const DeepCollectionEquality().equals(other.statusHistory, statusHistory)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.fulfillment, fulfillment) || other.fulfillment == fulfillment)&&(identical(other.isSeller, isSeller) || other.isSeller == isSeller)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orderNumber,status,statusLabel,fulfillmentType,const DeepCollectionEquality().hash(deliveryAddress),const DeepCollectionEquality().hash(pickupDetails),const DeepCollectionEquality().hash(totalArtifacts),const DeepCollectionEquality().hash(discountArtifacts),spentUsd,discountCode,const DeepCollectionEquality().hash(statusHistory),const DeepCollectionEquality().hash(items),fulfillment,isSeller,paidAt,createdAt);

@override
String toString() {
  return 'Order(id: $id, orderNumber: $orderNumber, status: $status, statusLabel: $statusLabel, fulfillmentType: $fulfillmentType, deliveryAddress: $deliveryAddress, pickupDetails: $pickupDetails, totalArtifacts: $totalArtifacts, discountArtifacts: $discountArtifacts, spentUsd: $spentUsd, discountCode: $discountCode, statusHistory: $statusHistory, items: $items, fulfillment: $fulfillment, isSeller: $isSeller, paidAt: $paidAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $OrderCopyWith<$Res>  {
  factory $OrderCopyWith(Order value, $Res Function(Order) _then) = _$OrderCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'order_number') String orderNumber, String status,@JsonKey(name: 'status_label') String statusLabel,@JsonKey(name: 'fulfillment_type') String fulfillmentType,@JsonKey(name: 'delivery_address') Map<String, dynamic> deliveryAddress,@JsonKey(name: 'pickup_details') Map<String, dynamic> pickupDetails,@JsonKey(name: 'total_artifacts') Map<String, int> totalArtifacts,@JsonKey(name: 'discount_artifacts') Map<String, int> discountArtifacts, double spentUsd,@JsonKey(name: 'discount_code') String? discountCode,@JsonKey(name: 'status_history') List<OrderTimelineEntry> statusHistory, List<OrderItem> items, OrderFulfillment? fulfillment,@JsonKey(name: 'is_seller') bool isSeller,@JsonKey(name: 'paid_at') String? paidAt,@JsonKey(name: 'created_at') String? createdAt
});


$OrderFulfillmentCopyWith<$Res>? get fulfillment;

}
/// @nodoc
class _$OrderCopyWithImpl<$Res>
    implements $OrderCopyWith<$Res> {
  _$OrderCopyWithImpl(this._self, this._then);

  final Order _self;
  final $Res Function(Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orderNumber = null,Object? status = null,Object? statusLabel = null,Object? fulfillmentType = null,Object? deliveryAddress = null,Object? pickupDetails = null,Object? totalArtifacts = null,Object? discountArtifacts = null,Object? spentUsd = null,Object? discountCode = freezed,Object? statusHistory = null,Object? items = null,Object? fulfillment = freezed,Object? isSeller = null,Object? paidAt = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,statusLabel: null == statusLabel ? _self.statusLabel : statusLabel // ignore: cast_nullable_to_non_nullable
as String,fulfillmentType: null == fulfillmentType ? _self.fulfillmentType : fulfillmentType // ignore: cast_nullable_to_non_nullable
as String,deliveryAddress: null == deliveryAddress ? _self.deliveryAddress : deliveryAddress // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,pickupDetails: null == pickupDetails ? _self.pickupDetails : pickupDetails // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,totalArtifacts: null == totalArtifacts ? _self.totalArtifacts : totalArtifacts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,discountArtifacts: null == discountArtifacts ? _self.discountArtifacts : discountArtifacts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,spentUsd: null == spentUsd ? _self.spentUsd : spentUsd // ignore: cast_nullable_to_non_nullable
as double,discountCode: freezed == discountCode ? _self.discountCode : discountCode // ignore: cast_nullable_to_non_nullable
as String?,statusHistory: null == statusHistory ? _self.statusHistory : statusHistory // ignore: cast_nullable_to_non_nullable
as List<OrderTimelineEntry>,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItem>,fulfillment: freezed == fulfillment ? _self.fulfillment : fulfillment // ignore: cast_nullable_to_non_nullable
as OrderFulfillment?,isSeller: null == isSeller ? _self.isSeller : isSeller // ignore: cast_nullable_to_non_nullable
as bool,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrderFulfillmentCopyWith<$Res>? get fulfillment {
    if (_self.fulfillment == null) {
    return null;
  }

  return $OrderFulfillmentCopyWith<$Res>(_self.fulfillment!, (value) {
    return _then(_self.copyWith(fulfillment: value));
  });
}
}


/// Adds pattern-matching-related methods to [Order].
extension OrderPatterns on Order {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Order value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Order() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Order value)  $default,){
final _that = this;
switch (_that) {
case _Order():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Order value)?  $default,){
final _that = this;
switch (_that) {
case _Order() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'order_number')  String orderNumber,  String status, @JsonKey(name: 'status_label')  String statusLabel, @JsonKey(name: 'fulfillment_type')  String fulfillmentType, @JsonKey(name: 'delivery_address')  Map<String, dynamic> deliveryAddress, @JsonKey(name: 'pickup_details')  Map<String, dynamic> pickupDetails, @JsonKey(name: 'total_artifacts')  Map<String, int> totalArtifacts, @JsonKey(name: 'discount_artifacts')  Map<String, int> discountArtifacts,  double spentUsd, @JsonKey(name: 'discount_code')  String? discountCode, @JsonKey(name: 'status_history')  List<OrderTimelineEntry> statusHistory,  List<OrderItem> items,  OrderFulfillment? fulfillment, @JsonKey(name: 'is_seller')  bool isSeller, @JsonKey(name: 'paid_at')  String? paidAt, @JsonKey(name: 'created_at')  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.orderNumber,_that.status,_that.statusLabel,_that.fulfillmentType,_that.deliveryAddress,_that.pickupDetails,_that.totalArtifacts,_that.discountArtifacts,_that.spentUsd,_that.discountCode,_that.statusHistory,_that.items,_that.fulfillment,_that.isSeller,_that.paidAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'order_number')  String orderNumber,  String status, @JsonKey(name: 'status_label')  String statusLabel, @JsonKey(name: 'fulfillment_type')  String fulfillmentType, @JsonKey(name: 'delivery_address')  Map<String, dynamic> deliveryAddress, @JsonKey(name: 'pickup_details')  Map<String, dynamic> pickupDetails, @JsonKey(name: 'total_artifacts')  Map<String, int> totalArtifacts, @JsonKey(name: 'discount_artifacts')  Map<String, int> discountArtifacts,  double spentUsd, @JsonKey(name: 'discount_code')  String? discountCode, @JsonKey(name: 'status_history')  List<OrderTimelineEntry> statusHistory,  List<OrderItem> items,  OrderFulfillment? fulfillment, @JsonKey(name: 'is_seller')  bool isSeller, @JsonKey(name: 'paid_at')  String? paidAt, @JsonKey(name: 'created_at')  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _Order():
return $default(_that.id,_that.orderNumber,_that.status,_that.statusLabel,_that.fulfillmentType,_that.deliveryAddress,_that.pickupDetails,_that.totalArtifacts,_that.discountArtifacts,_that.spentUsd,_that.discountCode,_that.statusHistory,_that.items,_that.fulfillment,_that.isSeller,_that.paidAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'order_number')  String orderNumber,  String status, @JsonKey(name: 'status_label')  String statusLabel, @JsonKey(name: 'fulfillment_type')  String fulfillmentType, @JsonKey(name: 'delivery_address')  Map<String, dynamic> deliveryAddress, @JsonKey(name: 'pickup_details')  Map<String, dynamic> pickupDetails, @JsonKey(name: 'total_artifacts')  Map<String, int> totalArtifacts, @JsonKey(name: 'discount_artifacts')  Map<String, int> discountArtifacts,  double spentUsd, @JsonKey(name: 'discount_code')  String? discountCode, @JsonKey(name: 'status_history')  List<OrderTimelineEntry> statusHistory,  List<OrderItem> items,  OrderFulfillment? fulfillment, @JsonKey(name: 'is_seller')  bool isSeller, @JsonKey(name: 'paid_at')  String? paidAt, @JsonKey(name: 'created_at')  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.orderNumber,_that.status,_that.statusLabel,_that.fulfillmentType,_that.deliveryAddress,_that.pickupDetails,_that.totalArtifacts,_that.discountArtifacts,_that.spentUsd,_that.discountCode,_that.statusHistory,_that.items,_that.fulfillment,_that.isSeller,_that.paidAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Order implements Order {
  const _Order({required this.id, @JsonKey(name: 'order_number') this.orderNumber = '', this.status = 'paid', @JsonKey(name: 'status_label') this.statusLabel = '', @JsonKey(name: 'fulfillment_type') this.fulfillmentType = 'digital', @JsonKey(name: 'delivery_address') final  Map<String, dynamic> deliveryAddress = const <String, dynamic>{}, @JsonKey(name: 'pickup_details') final  Map<String, dynamic> pickupDetails = const <String, dynamic>{}, @JsonKey(name: 'total_artifacts') final  Map<String, int> totalArtifacts = const <String, int>{}, @JsonKey(name: 'discount_artifacts') final  Map<String, int> discountArtifacts = const <String, int>{}, this.spentUsd = 0.0, @JsonKey(name: 'discount_code') this.discountCode, @JsonKey(name: 'status_history') final  List<OrderTimelineEntry> statusHistory = const <OrderTimelineEntry>[], final  List<OrderItem> items = const <OrderItem>[], this.fulfillment, @JsonKey(name: 'is_seller') this.isSeller = false, @JsonKey(name: 'paid_at') this.paidAt, @JsonKey(name: 'created_at') this.createdAt}): _deliveryAddress = deliveryAddress,_pickupDetails = pickupDetails,_totalArtifacts = totalArtifacts,_discountArtifacts = discountArtifacts,_statusHistory = statusHistory,_items = items;
  factory _Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

@override final  String id;
@override@JsonKey(name: 'order_number') final  String orderNumber;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'status_label') final  String statusLabel;
@override@JsonKey(name: 'fulfillment_type') final  String fulfillmentType;
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

 final  Map<String, int> _totalArtifacts;
@override@JsonKey(name: 'total_artifacts') Map<String, int> get totalArtifacts {
  if (_totalArtifacts is EqualUnmodifiableMapView) return _totalArtifacts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_totalArtifacts);
}

 final  Map<String, int> _discountArtifacts;
@override@JsonKey(name: 'discount_artifacts') Map<String, int> get discountArtifacts {
  if (_discountArtifacts is EqualUnmodifiableMapView) return _discountArtifacts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_discountArtifacts);
}

@override@JsonKey() final  double spentUsd;
@override@JsonKey(name: 'discount_code') final  String? discountCode;
 final  List<OrderTimelineEntry> _statusHistory;
@override@JsonKey(name: 'status_history') List<OrderTimelineEntry> get statusHistory {
  if (_statusHistory is EqualUnmodifiableListView) return _statusHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_statusHistory);
}

 final  List<OrderItem> _items;
@override@JsonKey() List<OrderItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  OrderFulfillment? fulfillment;
@override@JsonKey(name: 'is_seller') final  bool isSeller;
@override@JsonKey(name: 'paid_at') final  String? paidAt;
@override@JsonKey(name: 'created_at') final  String? createdAt;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderCopyWith<_Order> get copyWith => __$OrderCopyWithImpl<_Order>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Order&&(identical(other.id, id) || other.id == id)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusLabel, statusLabel) || other.statusLabel == statusLabel)&&(identical(other.fulfillmentType, fulfillmentType) || other.fulfillmentType == fulfillmentType)&&const DeepCollectionEquality().equals(other._deliveryAddress, _deliveryAddress)&&const DeepCollectionEquality().equals(other._pickupDetails, _pickupDetails)&&const DeepCollectionEquality().equals(other._totalArtifacts, _totalArtifacts)&&const DeepCollectionEquality().equals(other._discountArtifacts, _discountArtifacts)&&(identical(other.spentUsd, spentUsd) || other.spentUsd == spentUsd)&&(identical(other.discountCode, discountCode) || other.discountCode == discountCode)&&const DeepCollectionEquality().equals(other._statusHistory, _statusHistory)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.fulfillment, fulfillment) || other.fulfillment == fulfillment)&&(identical(other.isSeller, isSeller) || other.isSeller == isSeller)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orderNumber,status,statusLabel,fulfillmentType,const DeepCollectionEquality().hash(_deliveryAddress),const DeepCollectionEquality().hash(_pickupDetails),const DeepCollectionEquality().hash(_totalArtifacts),const DeepCollectionEquality().hash(_discountArtifacts),spentUsd,discountCode,const DeepCollectionEquality().hash(_statusHistory),const DeepCollectionEquality().hash(_items),fulfillment,isSeller,paidAt,createdAt);

@override
String toString() {
  return 'Order(id: $id, orderNumber: $orderNumber, status: $status, statusLabel: $statusLabel, fulfillmentType: $fulfillmentType, deliveryAddress: $deliveryAddress, pickupDetails: $pickupDetails, totalArtifacts: $totalArtifacts, discountArtifacts: $discountArtifacts, spentUsd: $spentUsd, discountCode: $discountCode, statusHistory: $statusHistory, items: $items, fulfillment: $fulfillment, isSeller: $isSeller, paidAt: $paidAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$OrderCopyWith<$Res> implements $OrderCopyWith<$Res> {
  factory _$OrderCopyWith(_Order value, $Res Function(_Order) _then) = __$OrderCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'order_number') String orderNumber, String status,@JsonKey(name: 'status_label') String statusLabel,@JsonKey(name: 'fulfillment_type') String fulfillmentType,@JsonKey(name: 'delivery_address') Map<String, dynamic> deliveryAddress,@JsonKey(name: 'pickup_details') Map<String, dynamic> pickupDetails,@JsonKey(name: 'total_artifacts') Map<String, int> totalArtifacts,@JsonKey(name: 'discount_artifacts') Map<String, int> discountArtifacts, double spentUsd,@JsonKey(name: 'discount_code') String? discountCode,@JsonKey(name: 'status_history') List<OrderTimelineEntry> statusHistory, List<OrderItem> items, OrderFulfillment? fulfillment,@JsonKey(name: 'is_seller') bool isSeller,@JsonKey(name: 'paid_at') String? paidAt,@JsonKey(name: 'created_at') String? createdAt
});


@override $OrderFulfillmentCopyWith<$Res>? get fulfillment;

}
/// @nodoc
class __$OrderCopyWithImpl<$Res>
    implements _$OrderCopyWith<$Res> {
  __$OrderCopyWithImpl(this._self, this._then);

  final _Order _self;
  final $Res Function(_Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orderNumber = null,Object? status = null,Object? statusLabel = null,Object? fulfillmentType = null,Object? deliveryAddress = null,Object? pickupDetails = null,Object? totalArtifacts = null,Object? discountArtifacts = null,Object? spentUsd = null,Object? discountCode = freezed,Object? statusHistory = null,Object? items = null,Object? fulfillment = freezed,Object? isSeller = null,Object? paidAt = freezed,Object? createdAt = freezed,}) {
  return _then(_Order(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,statusLabel: null == statusLabel ? _self.statusLabel : statusLabel // ignore: cast_nullable_to_non_nullable
as String,fulfillmentType: null == fulfillmentType ? _self.fulfillmentType : fulfillmentType // ignore: cast_nullable_to_non_nullable
as String,deliveryAddress: null == deliveryAddress ? _self._deliveryAddress : deliveryAddress // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,pickupDetails: null == pickupDetails ? _self._pickupDetails : pickupDetails // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,totalArtifacts: null == totalArtifacts ? _self._totalArtifacts : totalArtifacts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,discountArtifacts: null == discountArtifacts ? _self._discountArtifacts : discountArtifacts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,spentUsd: null == spentUsd ? _self.spentUsd : spentUsd // ignore: cast_nullable_to_non_nullable
as double,discountCode: freezed == discountCode ? _self.discountCode : discountCode // ignore: cast_nullable_to_non_nullable
as String?,statusHistory: null == statusHistory ? _self._statusHistory : statusHistory // ignore: cast_nullable_to_non_nullable
as List<OrderTimelineEntry>,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItem>,fulfillment: freezed == fulfillment ? _self.fulfillment : fulfillment // ignore: cast_nullable_to_non_nullable
as OrderFulfillment?,isSeller: null == isSeller ? _self.isSeller : isSeller // ignore: cast_nullable_to_non_nullable
as bool,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrderFulfillmentCopyWith<$Res>? get fulfillment {
    if (_self.fulfillment == null) {
    return null;
  }

  return $OrderFulfillmentCopyWith<$Res>(_self.fulfillment!, (value) {
    return _then(_self.copyWith(fulfillment: value));
  });
}
}

// dart format on
