// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Profile {

 String get userId; String get username; String get displayName; String get bio; String get avatarUrl; String get coverUrl; String get pronouns; String get locationCity; String get locationCountry; String? get externalLink; String get role; String get verificationStatus; String get privacyLevel; int get streakDays; Map<String, int> get artifactBalance; int get buddyCount; int get followingCount; int get followerCount; int get gymCount; int get postCount; bool get isBuddy; String? get buddyStatus; bool get isFollowing; bool get showActiveStatus; String? get createdAt; String? get updatedAt;
/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileCopyWith<Profile> get copyWith => _$ProfileCopyWithImpl<Profile>(this as Profile, _$identity);

  /// Serializes this Profile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Profile&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.pronouns, pronouns) || other.pronouns == pronouns)&&(identical(other.locationCity, locationCity) || other.locationCity == locationCity)&&(identical(other.locationCountry, locationCountry) || other.locationCountry == locationCountry)&&(identical(other.externalLink, externalLink) || other.externalLink == externalLink)&&(identical(other.role, role) || other.role == role)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.privacyLevel, privacyLevel) || other.privacyLevel == privacyLevel)&&(identical(other.streakDays, streakDays) || other.streakDays == streakDays)&&const DeepCollectionEquality().equals(other.artifactBalance, artifactBalance)&&(identical(other.buddyCount, buddyCount) || other.buddyCount == buddyCount)&&(identical(other.followingCount, followingCount) || other.followingCount == followingCount)&&(identical(other.followerCount, followerCount) || other.followerCount == followerCount)&&(identical(other.gymCount, gymCount) || other.gymCount == gymCount)&&(identical(other.postCount, postCount) || other.postCount == postCount)&&(identical(other.isBuddy, isBuddy) || other.isBuddy == isBuddy)&&(identical(other.buddyStatus, buddyStatus) || other.buddyStatus == buddyStatus)&&(identical(other.isFollowing, isFollowing) || other.isFollowing == isFollowing)&&(identical(other.showActiveStatus, showActiveStatus) || other.showActiveStatus == showActiveStatus)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,userId,username,displayName,bio,avatarUrl,coverUrl,pronouns,locationCity,locationCountry,externalLink,role,verificationStatus,privacyLevel,streakDays,const DeepCollectionEquality().hash(artifactBalance),buddyCount,followingCount,followerCount,gymCount,postCount,isBuddy,buddyStatus,isFollowing,showActiveStatus,createdAt,updatedAt]);

@override
String toString() {
  return 'Profile(userId: $userId, username: $username, displayName: $displayName, bio: $bio, avatarUrl: $avatarUrl, coverUrl: $coverUrl, pronouns: $pronouns, locationCity: $locationCity, locationCountry: $locationCountry, externalLink: $externalLink, role: $role, verificationStatus: $verificationStatus, privacyLevel: $privacyLevel, streakDays: $streakDays, artifactBalance: $artifactBalance, buddyCount: $buddyCount, followingCount: $followingCount, followerCount: $followerCount, gymCount: $gymCount, postCount: $postCount, isBuddy: $isBuddy, buddyStatus: $buddyStatus, isFollowing: $isFollowing, showActiveStatus: $showActiveStatus, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ProfileCopyWith<$Res>  {
  factory $ProfileCopyWith(Profile value, $Res Function(Profile) _then) = _$ProfileCopyWithImpl;
@useResult
$Res call({
 String userId, String username, String displayName, String bio, String avatarUrl, String coverUrl, String pronouns, String locationCity, String locationCountry, String? externalLink, String role, String verificationStatus, String privacyLevel, int streakDays, Map<String, int> artifactBalance, int buddyCount, int followingCount, int followerCount, int gymCount, int postCount, bool isBuddy, String? buddyStatus, bool isFollowing, bool showActiveStatus, String? createdAt, String? updatedAt
});




}
/// @nodoc
class _$ProfileCopyWithImpl<$Res>
    implements $ProfileCopyWith<$Res> {
  _$ProfileCopyWithImpl(this._self, this._then);

  final Profile _self;
  final $Res Function(Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? username = null,Object? displayName = null,Object? bio = null,Object? avatarUrl = null,Object? coverUrl = null,Object? pronouns = null,Object? locationCity = null,Object? locationCountry = null,Object? externalLink = freezed,Object? role = null,Object? verificationStatus = null,Object? privacyLevel = null,Object? streakDays = null,Object? artifactBalance = null,Object? buddyCount = null,Object? followingCount = null,Object? followerCount = null,Object? gymCount = null,Object? postCount = null,Object? isBuddy = null,Object? buddyStatus = freezed,Object? isFollowing = null,Object? showActiveStatus = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,pronouns: null == pronouns ? _self.pronouns : pronouns // ignore: cast_nullable_to_non_nullable
as String,locationCity: null == locationCity ? _self.locationCity : locationCity // ignore: cast_nullable_to_non_nullable
as String,locationCountry: null == locationCountry ? _self.locationCountry : locationCountry // ignore: cast_nullable_to_non_nullable
as String,externalLink: freezed == externalLink ? _self.externalLink : externalLink // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String,privacyLevel: null == privacyLevel ? _self.privacyLevel : privacyLevel // ignore: cast_nullable_to_non_nullable
as String,streakDays: null == streakDays ? _self.streakDays : streakDays // ignore: cast_nullable_to_non_nullable
as int,artifactBalance: null == artifactBalance ? _self.artifactBalance : artifactBalance // ignore: cast_nullable_to_non_nullable
as Map<String, int>,buddyCount: null == buddyCount ? _self.buddyCount : buddyCount // ignore: cast_nullable_to_non_nullable
as int,followingCount: null == followingCount ? _self.followingCount : followingCount // ignore: cast_nullable_to_non_nullable
as int,followerCount: null == followerCount ? _self.followerCount : followerCount // ignore: cast_nullable_to_non_nullable
as int,gymCount: null == gymCount ? _self.gymCount : gymCount // ignore: cast_nullable_to_non_nullable
as int,postCount: null == postCount ? _self.postCount : postCount // ignore: cast_nullable_to_non_nullable
as int,isBuddy: null == isBuddy ? _self.isBuddy : isBuddy // ignore: cast_nullable_to_non_nullable
as bool,buddyStatus: freezed == buddyStatus ? _self.buddyStatus : buddyStatus // ignore: cast_nullable_to_non_nullable
as String?,isFollowing: null == isFollowing ? _self.isFollowing : isFollowing // ignore: cast_nullable_to_non_nullable
as bool,showActiveStatus: null == showActiveStatus ? _self.showActiveStatus : showActiveStatus // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Profile].
extension ProfilePatterns on Profile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Profile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Profile value)  $default,){
final _that = this;
switch (_that) {
case _Profile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Profile value)?  $default,){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String username,  String displayName,  String bio,  String avatarUrl,  String coverUrl,  String pronouns,  String locationCity,  String locationCountry,  String? externalLink,  String role,  String verificationStatus,  String privacyLevel,  int streakDays,  Map<String, int> artifactBalance,  int buddyCount,  int followingCount,  int followerCount,  int gymCount,  int postCount,  bool isBuddy,  String? buddyStatus,  bool isFollowing,  bool showActiveStatus,  String? createdAt,  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.userId,_that.username,_that.displayName,_that.bio,_that.avatarUrl,_that.coverUrl,_that.pronouns,_that.locationCity,_that.locationCountry,_that.externalLink,_that.role,_that.verificationStatus,_that.privacyLevel,_that.streakDays,_that.artifactBalance,_that.buddyCount,_that.followingCount,_that.followerCount,_that.gymCount,_that.postCount,_that.isBuddy,_that.buddyStatus,_that.isFollowing,_that.showActiveStatus,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String username,  String displayName,  String bio,  String avatarUrl,  String coverUrl,  String pronouns,  String locationCity,  String locationCountry,  String? externalLink,  String role,  String verificationStatus,  String privacyLevel,  int streakDays,  Map<String, int> artifactBalance,  int buddyCount,  int followingCount,  int followerCount,  int gymCount,  int postCount,  bool isBuddy,  String? buddyStatus,  bool isFollowing,  bool showActiveStatus,  String? createdAt,  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Profile():
return $default(_that.userId,_that.username,_that.displayName,_that.bio,_that.avatarUrl,_that.coverUrl,_that.pronouns,_that.locationCity,_that.locationCountry,_that.externalLink,_that.role,_that.verificationStatus,_that.privacyLevel,_that.streakDays,_that.artifactBalance,_that.buddyCount,_that.followingCount,_that.followerCount,_that.gymCount,_that.postCount,_that.isBuddy,_that.buddyStatus,_that.isFollowing,_that.showActiveStatus,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String username,  String displayName,  String bio,  String avatarUrl,  String coverUrl,  String pronouns,  String locationCity,  String locationCountry,  String? externalLink,  String role,  String verificationStatus,  String privacyLevel,  int streakDays,  Map<String, int> artifactBalance,  int buddyCount,  int followingCount,  int followerCount,  int gymCount,  int postCount,  bool isBuddy,  String? buddyStatus,  bool isFollowing,  bool showActiveStatus,  String? createdAt,  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.userId,_that.username,_that.displayName,_that.bio,_that.avatarUrl,_that.coverUrl,_that.pronouns,_that.locationCity,_that.locationCountry,_that.externalLink,_that.role,_that.verificationStatus,_that.privacyLevel,_that.streakDays,_that.artifactBalance,_that.buddyCount,_that.followingCount,_that.followerCount,_that.gymCount,_that.postCount,_that.isBuddy,_that.buddyStatus,_that.isFollowing,_that.showActiveStatus,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Profile implements Profile {
  const _Profile({required this.userId, required this.username, required this.displayName, this.bio = '', this.avatarUrl = '', this.coverUrl = '', this.pronouns = '', this.locationCity = '', this.locationCountry = '', this.externalLink, this.role = 'user', this.verificationStatus = 'none', this.privacyLevel = 'public', this.streakDays = 0, final  Map<String, int> artifactBalance = const {}, this.buddyCount = 0, this.followingCount = 0, this.followerCount = 0, this.gymCount = 0, this.postCount = 0, this.isBuddy = false, this.buddyStatus, this.isFollowing = false, this.showActiveStatus = true, this.createdAt, this.updatedAt}): _artifactBalance = artifactBalance;
  factory _Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

@override final  String userId;
@override final  String username;
@override final  String displayName;
@override@JsonKey() final  String bio;
@override@JsonKey() final  String avatarUrl;
@override@JsonKey() final  String coverUrl;
@override@JsonKey() final  String pronouns;
@override@JsonKey() final  String locationCity;
@override@JsonKey() final  String locationCountry;
@override final  String? externalLink;
@override@JsonKey() final  String role;
@override@JsonKey() final  String verificationStatus;
@override@JsonKey() final  String privacyLevel;
@override@JsonKey() final  int streakDays;
 final  Map<String, int> _artifactBalance;
@override@JsonKey() Map<String, int> get artifactBalance {
  if (_artifactBalance is EqualUnmodifiableMapView) return _artifactBalance;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_artifactBalance);
}

@override@JsonKey() final  int buddyCount;
@override@JsonKey() final  int followingCount;
@override@JsonKey() final  int followerCount;
@override@JsonKey() final  int gymCount;
@override@JsonKey() final  int postCount;
@override@JsonKey() final  bool isBuddy;
@override final  String? buddyStatus;
@override@JsonKey() final  bool isFollowing;
@override@JsonKey() final  bool showActiveStatus;
@override final  String? createdAt;
@override final  String? updatedAt;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileCopyWith<_Profile> get copyWith => __$ProfileCopyWithImpl<_Profile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Profile&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.pronouns, pronouns) || other.pronouns == pronouns)&&(identical(other.locationCity, locationCity) || other.locationCity == locationCity)&&(identical(other.locationCountry, locationCountry) || other.locationCountry == locationCountry)&&(identical(other.externalLink, externalLink) || other.externalLink == externalLink)&&(identical(other.role, role) || other.role == role)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.privacyLevel, privacyLevel) || other.privacyLevel == privacyLevel)&&(identical(other.streakDays, streakDays) || other.streakDays == streakDays)&&const DeepCollectionEquality().equals(other._artifactBalance, _artifactBalance)&&(identical(other.buddyCount, buddyCount) || other.buddyCount == buddyCount)&&(identical(other.followingCount, followingCount) || other.followingCount == followingCount)&&(identical(other.followerCount, followerCount) || other.followerCount == followerCount)&&(identical(other.gymCount, gymCount) || other.gymCount == gymCount)&&(identical(other.postCount, postCount) || other.postCount == postCount)&&(identical(other.isBuddy, isBuddy) || other.isBuddy == isBuddy)&&(identical(other.buddyStatus, buddyStatus) || other.buddyStatus == buddyStatus)&&(identical(other.isFollowing, isFollowing) || other.isFollowing == isFollowing)&&(identical(other.showActiveStatus, showActiveStatus) || other.showActiveStatus == showActiveStatus)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,userId,username,displayName,bio,avatarUrl,coverUrl,pronouns,locationCity,locationCountry,externalLink,role,verificationStatus,privacyLevel,streakDays,const DeepCollectionEquality().hash(_artifactBalance),buddyCount,followingCount,followerCount,gymCount,postCount,isBuddy,buddyStatus,isFollowing,showActiveStatus,createdAt,updatedAt]);

@override
String toString() {
  return 'Profile(userId: $userId, username: $username, displayName: $displayName, bio: $bio, avatarUrl: $avatarUrl, coverUrl: $coverUrl, pronouns: $pronouns, locationCity: $locationCity, locationCountry: $locationCountry, externalLink: $externalLink, role: $role, verificationStatus: $verificationStatus, privacyLevel: $privacyLevel, streakDays: $streakDays, artifactBalance: $artifactBalance, buddyCount: $buddyCount, followingCount: $followingCount, followerCount: $followerCount, gymCount: $gymCount, postCount: $postCount, isBuddy: $isBuddy, buddyStatus: $buddyStatus, isFollowing: $isFollowing, showActiveStatus: $showActiveStatus, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ProfileCopyWith<$Res> implements $ProfileCopyWith<$Res> {
  factory _$ProfileCopyWith(_Profile value, $Res Function(_Profile) _then) = __$ProfileCopyWithImpl;
@override @useResult
$Res call({
 String userId, String username, String displayName, String bio, String avatarUrl, String coverUrl, String pronouns, String locationCity, String locationCountry, String? externalLink, String role, String verificationStatus, String privacyLevel, int streakDays, Map<String, int> artifactBalance, int buddyCount, int followingCount, int followerCount, int gymCount, int postCount, bool isBuddy, String? buddyStatus, bool isFollowing, bool showActiveStatus, String? createdAt, String? updatedAt
});




}
/// @nodoc
class __$ProfileCopyWithImpl<$Res>
    implements _$ProfileCopyWith<$Res> {
  __$ProfileCopyWithImpl(this._self, this._then);

  final _Profile _self;
  final $Res Function(_Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? username = null,Object? displayName = null,Object? bio = null,Object? avatarUrl = null,Object? coverUrl = null,Object? pronouns = null,Object? locationCity = null,Object? locationCountry = null,Object? externalLink = freezed,Object? role = null,Object? verificationStatus = null,Object? privacyLevel = null,Object? streakDays = null,Object? artifactBalance = null,Object? buddyCount = null,Object? followingCount = null,Object? followerCount = null,Object? gymCount = null,Object? postCount = null,Object? isBuddy = null,Object? buddyStatus = freezed,Object? isFollowing = null,Object? showActiveStatus = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Profile(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,pronouns: null == pronouns ? _self.pronouns : pronouns // ignore: cast_nullable_to_non_nullable
as String,locationCity: null == locationCity ? _self.locationCity : locationCity // ignore: cast_nullable_to_non_nullable
as String,locationCountry: null == locationCountry ? _self.locationCountry : locationCountry // ignore: cast_nullable_to_non_nullable
as String,externalLink: freezed == externalLink ? _self.externalLink : externalLink // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String,privacyLevel: null == privacyLevel ? _self.privacyLevel : privacyLevel // ignore: cast_nullable_to_non_nullable
as String,streakDays: null == streakDays ? _self.streakDays : streakDays // ignore: cast_nullable_to_non_nullable
as int,artifactBalance: null == artifactBalance ? _self._artifactBalance : artifactBalance // ignore: cast_nullable_to_non_nullable
as Map<String, int>,buddyCount: null == buddyCount ? _self.buddyCount : buddyCount // ignore: cast_nullable_to_non_nullable
as int,followingCount: null == followingCount ? _self.followingCount : followingCount // ignore: cast_nullable_to_non_nullable
as int,followerCount: null == followerCount ? _self.followerCount : followerCount // ignore: cast_nullable_to_non_nullable
as int,gymCount: null == gymCount ? _self.gymCount : gymCount // ignore: cast_nullable_to_non_nullable
as int,postCount: null == postCount ? _self.postCount : postCount // ignore: cast_nullable_to_non_nullable
as int,isBuddy: null == isBuddy ? _self.isBuddy : isBuddy // ignore: cast_nullable_to_non_nullable
as bool,buddyStatus: freezed == buddyStatus ? _self.buddyStatus : buddyStatus // ignore: cast_nullable_to_non_nullable
as String?,isFollowing: null == isFollowing ? _self.isFollowing : isFollowing // ignore: cast_nullable_to_non_nullable
as bool,showActiveStatus: null == showActiveStatus ? _self.showActiveStatus : showActiveStatus // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ProfileUpdatePayload {

 String? get displayName; String? get bio; String? get pronouns; String? get locationCity; String? get locationCountry; String? get externalLink; String? get workoutSchedule; bool? get showActiveStatus; bool? get isAnonymousPosting; String? get privacyLevel;
/// Create a copy of ProfileUpdatePayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileUpdatePayloadCopyWith<ProfileUpdatePayload> get copyWith => _$ProfileUpdatePayloadCopyWithImpl<ProfileUpdatePayload>(this as ProfileUpdatePayload, _$identity);

  /// Serializes this ProfileUpdatePayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileUpdatePayload&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.pronouns, pronouns) || other.pronouns == pronouns)&&(identical(other.locationCity, locationCity) || other.locationCity == locationCity)&&(identical(other.locationCountry, locationCountry) || other.locationCountry == locationCountry)&&(identical(other.externalLink, externalLink) || other.externalLink == externalLink)&&(identical(other.workoutSchedule, workoutSchedule) || other.workoutSchedule == workoutSchedule)&&(identical(other.showActiveStatus, showActiveStatus) || other.showActiveStatus == showActiveStatus)&&(identical(other.isAnonymousPosting, isAnonymousPosting) || other.isAnonymousPosting == isAnonymousPosting)&&(identical(other.privacyLevel, privacyLevel) || other.privacyLevel == privacyLevel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,displayName,bio,pronouns,locationCity,locationCountry,externalLink,workoutSchedule,showActiveStatus,isAnonymousPosting,privacyLevel);

@override
String toString() {
  return 'ProfileUpdatePayload(displayName: $displayName, bio: $bio, pronouns: $pronouns, locationCity: $locationCity, locationCountry: $locationCountry, externalLink: $externalLink, workoutSchedule: $workoutSchedule, showActiveStatus: $showActiveStatus, isAnonymousPosting: $isAnonymousPosting, privacyLevel: $privacyLevel)';
}


}

/// @nodoc
abstract mixin class $ProfileUpdatePayloadCopyWith<$Res>  {
  factory $ProfileUpdatePayloadCopyWith(ProfileUpdatePayload value, $Res Function(ProfileUpdatePayload) _then) = _$ProfileUpdatePayloadCopyWithImpl;
@useResult
$Res call({
 String? displayName, String? bio, String? pronouns, String? locationCity, String? locationCountry, String? externalLink, String? workoutSchedule, bool? showActiveStatus, bool? isAnonymousPosting, String? privacyLevel
});




}
/// @nodoc
class _$ProfileUpdatePayloadCopyWithImpl<$Res>
    implements $ProfileUpdatePayloadCopyWith<$Res> {
  _$ProfileUpdatePayloadCopyWithImpl(this._self, this._then);

  final ProfileUpdatePayload _self;
  final $Res Function(ProfileUpdatePayload) _then;

/// Create a copy of ProfileUpdatePayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? displayName = freezed,Object? bio = freezed,Object? pronouns = freezed,Object? locationCity = freezed,Object? locationCountry = freezed,Object? externalLink = freezed,Object? workoutSchedule = freezed,Object? showActiveStatus = freezed,Object? isAnonymousPosting = freezed,Object? privacyLevel = freezed,}) {
  return _then(_self.copyWith(
displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,pronouns: freezed == pronouns ? _self.pronouns : pronouns // ignore: cast_nullable_to_non_nullable
as String?,locationCity: freezed == locationCity ? _self.locationCity : locationCity // ignore: cast_nullable_to_non_nullable
as String?,locationCountry: freezed == locationCountry ? _self.locationCountry : locationCountry // ignore: cast_nullable_to_non_nullable
as String?,externalLink: freezed == externalLink ? _self.externalLink : externalLink // ignore: cast_nullable_to_non_nullable
as String?,workoutSchedule: freezed == workoutSchedule ? _self.workoutSchedule : workoutSchedule // ignore: cast_nullable_to_non_nullable
as String?,showActiveStatus: freezed == showActiveStatus ? _self.showActiveStatus : showActiveStatus // ignore: cast_nullable_to_non_nullable
as bool?,isAnonymousPosting: freezed == isAnonymousPosting ? _self.isAnonymousPosting : isAnonymousPosting // ignore: cast_nullable_to_non_nullable
as bool?,privacyLevel: freezed == privacyLevel ? _self.privacyLevel : privacyLevel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileUpdatePayload].
extension ProfileUpdatePayloadPatterns on ProfileUpdatePayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileUpdatePayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileUpdatePayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileUpdatePayload value)  $default,){
final _that = this;
switch (_that) {
case _ProfileUpdatePayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileUpdatePayload value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileUpdatePayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? displayName,  String? bio,  String? pronouns,  String? locationCity,  String? locationCountry,  String? externalLink,  String? workoutSchedule,  bool? showActiveStatus,  bool? isAnonymousPosting,  String? privacyLevel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileUpdatePayload() when $default != null:
return $default(_that.displayName,_that.bio,_that.pronouns,_that.locationCity,_that.locationCountry,_that.externalLink,_that.workoutSchedule,_that.showActiveStatus,_that.isAnonymousPosting,_that.privacyLevel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? displayName,  String? bio,  String? pronouns,  String? locationCity,  String? locationCountry,  String? externalLink,  String? workoutSchedule,  bool? showActiveStatus,  bool? isAnonymousPosting,  String? privacyLevel)  $default,) {final _that = this;
switch (_that) {
case _ProfileUpdatePayload():
return $default(_that.displayName,_that.bio,_that.pronouns,_that.locationCity,_that.locationCountry,_that.externalLink,_that.workoutSchedule,_that.showActiveStatus,_that.isAnonymousPosting,_that.privacyLevel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? displayName,  String? bio,  String? pronouns,  String? locationCity,  String? locationCountry,  String? externalLink,  String? workoutSchedule,  bool? showActiveStatus,  bool? isAnonymousPosting,  String? privacyLevel)?  $default,) {final _that = this;
switch (_that) {
case _ProfileUpdatePayload() when $default != null:
return $default(_that.displayName,_that.bio,_that.pronouns,_that.locationCity,_that.locationCountry,_that.externalLink,_that.workoutSchedule,_that.showActiveStatus,_that.isAnonymousPosting,_that.privacyLevel);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProfileUpdatePayload implements ProfileUpdatePayload {
  const _ProfileUpdatePayload({this.displayName, this.bio, this.pronouns, this.locationCity, this.locationCountry, this.externalLink, this.workoutSchedule, this.showActiveStatus, this.isAnonymousPosting, this.privacyLevel});
  factory _ProfileUpdatePayload.fromJson(Map<String, dynamic> json) => _$ProfileUpdatePayloadFromJson(json);

@override final  String? displayName;
@override final  String? bio;
@override final  String? pronouns;
@override final  String? locationCity;
@override final  String? locationCountry;
@override final  String? externalLink;
@override final  String? workoutSchedule;
@override final  bool? showActiveStatus;
@override final  bool? isAnonymousPosting;
@override final  String? privacyLevel;

/// Create a copy of ProfileUpdatePayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileUpdatePayloadCopyWith<_ProfileUpdatePayload> get copyWith => __$ProfileUpdatePayloadCopyWithImpl<_ProfileUpdatePayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileUpdatePayloadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileUpdatePayload&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.pronouns, pronouns) || other.pronouns == pronouns)&&(identical(other.locationCity, locationCity) || other.locationCity == locationCity)&&(identical(other.locationCountry, locationCountry) || other.locationCountry == locationCountry)&&(identical(other.externalLink, externalLink) || other.externalLink == externalLink)&&(identical(other.workoutSchedule, workoutSchedule) || other.workoutSchedule == workoutSchedule)&&(identical(other.showActiveStatus, showActiveStatus) || other.showActiveStatus == showActiveStatus)&&(identical(other.isAnonymousPosting, isAnonymousPosting) || other.isAnonymousPosting == isAnonymousPosting)&&(identical(other.privacyLevel, privacyLevel) || other.privacyLevel == privacyLevel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,displayName,bio,pronouns,locationCity,locationCountry,externalLink,workoutSchedule,showActiveStatus,isAnonymousPosting,privacyLevel);

@override
String toString() {
  return 'ProfileUpdatePayload(displayName: $displayName, bio: $bio, pronouns: $pronouns, locationCity: $locationCity, locationCountry: $locationCountry, externalLink: $externalLink, workoutSchedule: $workoutSchedule, showActiveStatus: $showActiveStatus, isAnonymousPosting: $isAnonymousPosting, privacyLevel: $privacyLevel)';
}


}

/// @nodoc
abstract mixin class _$ProfileUpdatePayloadCopyWith<$Res> implements $ProfileUpdatePayloadCopyWith<$Res> {
  factory _$ProfileUpdatePayloadCopyWith(_ProfileUpdatePayload value, $Res Function(_ProfileUpdatePayload) _then) = __$ProfileUpdatePayloadCopyWithImpl;
@override @useResult
$Res call({
 String? displayName, String? bio, String? pronouns, String? locationCity, String? locationCountry, String? externalLink, String? workoutSchedule, bool? showActiveStatus, bool? isAnonymousPosting, String? privacyLevel
});




}
/// @nodoc
class __$ProfileUpdatePayloadCopyWithImpl<$Res>
    implements _$ProfileUpdatePayloadCopyWith<$Res> {
  __$ProfileUpdatePayloadCopyWithImpl(this._self, this._then);

  final _ProfileUpdatePayload _self;
  final $Res Function(_ProfileUpdatePayload) _then;

/// Create a copy of ProfileUpdatePayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? displayName = freezed,Object? bio = freezed,Object? pronouns = freezed,Object? locationCity = freezed,Object? locationCountry = freezed,Object? externalLink = freezed,Object? workoutSchedule = freezed,Object? showActiveStatus = freezed,Object? isAnonymousPosting = freezed,Object? privacyLevel = freezed,}) {
  return _then(_ProfileUpdatePayload(
displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,pronouns: freezed == pronouns ? _self.pronouns : pronouns // ignore: cast_nullable_to_non_nullable
as String?,locationCity: freezed == locationCity ? _self.locationCity : locationCity // ignore: cast_nullable_to_non_nullable
as String?,locationCountry: freezed == locationCountry ? _self.locationCountry : locationCountry // ignore: cast_nullable_to_non_nullable
as String?,externalLink: freezed == externalLink ? _self.externalLink : externalLink // ignore: cast_nullable_to_non_nullable
as String?,workoutSchedule: freezed == workoutSchedule ? _self.workoutSchedule : workoutSchedule // ignore: cast_nullable_to_non_nullable
as String?,showActiveStatus: freezed == showActiveStatus ? _self.showActiveStatus : showActiveStatus // ignore: cast_nullable_to_non_nullable
as bool?,isAnonymousPosting: freezed == isAnonymousPosting ? _self.isAnonymousPosting : isAnonymousPosting // ignore: cast_nullable_to_non_nullable
as bool?,privacyLevel: freezed == privacyLevel ? _self.privacyLevel : privacyLevel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
