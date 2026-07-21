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

 String get id;@JsonKey(name: 'creator_id') String get creatorId; String get title; String get description;@JsonKey(name: 'cover_image_url') String get coverImageUrl;@JsonKey(name: 'diet_type') String get dietType;@JsonKey(name: 'duration_weeks') int get durationWeeks;@JsonKey(name: 'calorie_range') String get calorieRange;@JsonKey(name: 'price_artifacts') Map<String, int> get priceArtifacts;@JsonKey(name: 'preview_day') Map<String, dynamic> get previewDay;@JsonKey(name: 'full_plan') Map<String, dynamic>? get fullPlan;@JsonKey(name: 'shopping_list') List<String> get shoppingList;@JsonKey(name: 'purchase_count') int get purchaseCount;@JsonKey(name: 'average_rating') double get averageRating;@JsonKey(name: 'review_count') int get reviewCount;@JsonKey(name: 'creator_data') CreatorData get creatorData;@JsonKey(name: 'is_purchased') bool get isPurchased;@JsonKey(name: 'created_at') String get createdAt;
/// Create a copy of MealPlan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MealPlanCopyWith<MealPlan> get copyWith => _$MealPlanCopyWithImpl<MealPlan>(this as MealPlan, _$identity);

  /// Serializes this MealPlan to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MealPlan&&(identical(other.id, id) || other.id == id)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.coverImageUrl, coverImageUrl) || other.coverImageUrl == coverImageUrl)&&(identical(other.dietType, dietType) || other.dietType == dietType)&&(identical(other.durationWeeks, durationWeeks) || other.durationWeeks == durationWeeks)&&(identical(other.calorieRange, calorieRange) || other.calorieRange == calorieRange)&&const DeepCollectionEquality().equals(other.priceArtifacts, priceArtifacts)&&const DeepCollectionEquality().equals(other.previewDay, previewDay)&&const DeepCollectionEquality().equals(other.fullPlan, fullPlan)&&const DeepCollectionEquality().equals(other.shoppingList, shoppingList)&&(identical(other.purchaseCount, purchaseCount) || other.purchaseCount == purchaseCount)&&(identical(other.averageRating, averageRating) || other.averageRating == averageRating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.creatorData, creatorData) || other.creatorData == creatorData)&&(identical(other.isPurchased, isPurchased) || other.isPurchased == isPurchased)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,creatorId,title,description,coverImageUrl,dietType,durationWeeks,calorieRange,const DeepCollectionEquality().hash(priceArtifacts),const DeepCollectionEquality().hash(previewDay),const DeepCollectionEquality().hash(fullPlan),const DeepCollectionEquality().hash(shoppingList),purchaseCount,averageRating,reviewCount,creatorData,isPurchased,createdAt);

@override
String toString() {
  return 'MealPlan(id: $id, creatorId: $creatorId, title: $title, description: $description, coverImageUrl: $coverImageUrl, dietType: $dietType, durationWeeks: $durationWeeks, calorieRange: $calorieRange, priceArtifacts: $priceArtifacts, previewDay: $previewDay, fullPlan: $fullPlan, shoppingList: $shoppingList, purchaseCount: $purchaseCount, averageRating: $averageRating, reviewCount: $reviewCount, creatorData: $creatorData, isPurchased: $isPurchased, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $MealPlanCopyWith<$Res>  {
  factory $MealPlanCopyWith(MealPlan value, $Res Function(MealPlan) _then) = _$MealPlanCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'creator_id') String creatorId, String title, String description,@JsonKey(name: 'cover_image_url') String coverImageUrl,@JsonKey(name: 'diet_type') String dietType,@JsonKey(name: 'duration_weeks') int durationWeeks,@JsonKey(name: 'calorie_range') String calorieRange,@JsonKey(name: 'price_artifacts') Map<String, int> priceArtifacts,@JsonKey(name: 'preview_day') Map<String, dynamic> previewDay,@JsonKey(name: 'full_plan') Map<String, dynamic>? fullPlan,@JsonKey(name: 'shopping_list') List<String> shoppingList,@JsonKey(name: 'purchase_count') int purchaseCount,@JsonKey(name: 'average_rating') double averageRating,@JsonKey(name: 'review_count') int reviewCount,@JsonKey(name: 'creator_data') CreatorData creatorData,@JsonKey(name: 'is_purchased') bool isPurchased,@JsonKey(name: 'created_at') String createdAt
});


$CreatorDataCopyWith<$Res> get creatorData;

}
/// @nodoc
class _$MealPlanCopyWithImpl<$Res>
    implements $MealPlanCopyWith<$Res> {
  _$MealPlanCopyWithImpl(this._self, this._then);

  final MealPlan _self;
  final $Res Function(MealPlan) _then;

/// Create a copy of MealPlan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? creatorId = null,Object? title = null,Object? description = null,Object? coverImageUrl = null,Object? dietType = null,Object? durationWeeks = null,Object? calorieRange = null,Object? priceArtifacts = null,Object? previewDay = null,Object? fullPlan = freezed,Object? shoppingList = null,Object? purchaseCount = null,Object? averageRating = null,Object? reviewCount = null,Object? creatorData = null,Object? isPurchased = null,Object? createdAt = null,}) {
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
as List<String>,purchaseCount: null == purchaseCount ? _self.purchaseCount : purchaseCount // ignore: cast_nullable_to_non_nullable
as int,averageRating: null == averageRating ? _self.averageRating : averageRating // ignore: cast_nullable_to_non_nullable
as double,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,creatorData: null == creatorData ? _self.creatorData : creatorData // ignore: cast_nullable_to_non_nullable
as CreatorData,isPurchased: null == isPurchased ? _self.isPurchased : isPurchased // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'creator_id')  String creatorId,  String title,  String description, @JsonKey(name: 'cover_image_url')  String coverImageUrl, @JsonKey(name: 'diet_type')  String dietType, @JsonKey(name: 'duration_weeks')  int durationWeeks, @JsonKey(name: 'calorie_range')  String calorieRange, @JsonKey(name: 'price_artifacts')  Map<String, int> priceArtifacts, @JsonKey(name: 'preview_day')  Map<String, dynamic> previewDay, @JsonKey(name: 'full_plan')  Map<String, dynamic>? fullPlan, @JsonKey(name: 'shopping_list')  List<String> shoppingList, @JsonKey(name: 'purchase_count')  int purchaseCount, @JsonKey(name: 'average_rating')  double averageRating, @JsonKey(name: 'review_count')  int reviewCount, @JsonKey(name: 'creator_data')  CreatorData creatorData, @JsonKey(name: 'is_purchased')  bool isPurchased, @JsonKey(name: 'created_at')  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MealPlan() when $default != null:
return $default(_that.id,_that.creatorId,_that.title,_that.description,_that.coverImageUrl,_that.dietType,_that.durationWeeks,_that.calorieRange,_that.priceArtifacts,_that.previewDay,_that.fullPlan,_that.shoppingList,_that.purchaseCount,_that.averageRating,_that.reviewCount,_that.creatorData,_that.isPurchased,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'creator_id')  String creatorId,  String title,  String description, @JsonKey(name: 'cover_image_url')  String coverImageUrl, @JsonKey(name: 'diet_type')  String dietType, @JsonKey(name: 'duration_weeks')  int durationWeeks, @JsonKey(name: 'calorie_range')  String calorieRange, @JsonKey(name: 'price_artifacts')  Map<String, int> priceArtifacts, @JsonKey(name: 'preview_day')  Map<String, dynamic> previewDay, @JsonKey(name: 'full_plan')  Map<String, dynamic>? fullPlan, @JsonKey(name: 'shopping_list')  List<String> shoppingList, @JsonKey(name: 'purchase_count')  int purchaseCount, @JsonKey(name: 'average_rating')  double averageRating, @JsonKey(name: 'review_count')  int reviewCount, @JsonKey(name: 'creator_data')  CreatorData creatorData, @JsonKey(name: 'is_purchased')  bool isPurchased, @JsonKey(name: 'created_at')  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _MealPlan():
return $default(_that.id,_that.creatorId,_that.title,_that.description,_that.coverImageUrl,_that.dietType,_that.durationWeeks,_that.calorieRange,_that.priceArtifacts,_that.previewDay,_that.fullPlan,_that.shoppingList,_that.purchaseCount,_that.averageRating,_that.reviewCount,_that.creatorData,_that.isPurchased,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'creator_id')  String creatorId,  String title,  String description, @JsonKey(name: 'cover_image_url')  String coverImageUrl, @JsonKey(name: 'diet_type')  String dietType, @JsonKey(name: 'duration_weeks')  int durationWeeks, @JsonKey(name: 'calorie_range')  String calorieRange, @JsonKey(name: 'price_artifacts')  Map<String, int> priceArtifacts, @JsonKey(name: 'preview_day')  Map<String, dynamic> previewDay, @JsonKey(name: 'full_plan')  Map<String, dynamic>? fullPlan, @JsonKey(name: 'shopping_list')  List<String> shoppingList, @JsonKey(name: 'purchase_count')  int purchaseCount, @JsonKey(name: 'average_rating')  double averageRating, @JsonKey(name: 'review_count')  int reviewCount, @JsonKey(name: 'creator_data')  CreatorData creatorData, @JsonKey(name: 'is_purchased')  bool isPurchased, @JsonKey(name: 'created_at')  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _MealPlan() when $default != null:
return $default(_that.id,_that.creatorId,_that.title,_that.description,_that.coverImageUrl,_that.dietType,_that.durationWeeks,_that.calorieRange,_that.priceArtifacts,_that.previewDay,_that.fullPlan,_that.shoppingList,_that.purchaseCount,_that.averageRating,_that.reviewCount,_that.creatorData,_that.isPurchased,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MealPlan implements MealPlan {
  const _MealPlan({required this.id, @JsonKey(name: 'creator_id') required this.creatorId, required this.title, required this.description, @JsonKey(name: 'cover_image_url') required this.coverImageUrl, @JsonKey(name: 'diet_type') required this.dietType, @JsonKey(name: 'duration_weeks') required this.durationWeeks, @JsonKey(name: 'calorie_range') required this.calorieRange, @JsonKey(name: 'price_artifacts') required final  Map<String, int> priceArtifacts, @JsonKey(name: 'preview_day') required final  Map<String, dynamic> previewDay, @JsonKey(name: 'full_plan') final  Map<String, dynamic>? fullPlan, @JsonKey(name: 'shopping_list') final  List<String> shoppingList = const <String>[], @JsonKey(name: 'purchase_count') this.purchaseCount = 0, @JsonKey(name: 'average_rating') this.averageRating = 0.0, @JsonKey(name: 'review_count') this.reviewCount = 0, @JsonKey(name: 'creator_data') required this.creatorData, @JsonKey(name: 'is_purchased') this.isPurchased = false, @JsonKey(name: 'created_at') required this.createdAt}): _priceArtifacts = priceArtifacts,_previewDay = previewDay,_fullPlan = fullPlan,_shoppingList = shoppingList;
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

@override@JsonKey(name: 'purchase_count') final  int purchaseCount;
@override@JsonKey(name: 'average_rating') final  double averageRating;
@override@JsonKey(name: 'review_count') final  int reviewCount;
@override@JsonKey(name: 'creator_data') final  CreatorData creatorData;
@override@JsonKey(name: 'is_purchased') final  bool isPurchased;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MealPlan&&(identical(other.id, id) || other.id == id)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.coverImageUrl, coverImageUrl) || other.coverImageUrl == coverImageUrl)&&(identical(other.dietType, dietType) || other.dietType == dietType)&&(identical(other.durationWeeks, durationWeeks) || other.durationWeeks == durationWeeks)&&(identical(other.calorieRange, calorieRange) || other.calorieRange == calorieRange)&&const DeepCollectionEquality().equals(other._priceArtifacts, _priceArtifacts)&&const DeepCollectionEquality().equals(other._previewDay, _previewDay)&&const DeepCollectionEquality().equals(other._fullPlan, _fullPlan)&&const DeepCollectionEquality().equals(other._shoppingList, _shoppingList)&&(identical(other.purchaseCount, purchaseCount) || other.purchaseCount == purchaseCount)&&(identical(other.averageRating, averageRating) || other.averageRating == averageRating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.creatorData, creatorData) || other.creatorData == creatorData)&&(identical(other.isPurchased, isPurchased) || other.isPurchased == isPurchased)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,creatorId,title,description,coverImageUrl,dietType,durationWeeks,calorieRange,const DeepCollectionEquality().hash(_priceArtifacts),const DeepCollectionEquality().hash(_previewDay),const DeepCollectionEquality().hash(_fullPlan),const DeepCollectionEquality().hash(_shoppingList),purchaseCount,averageRating,reviewCount,creatorData,isPurchased,createdAt);

@override
String toString() {
  return 'MealPlan(id: $id, creatorId: $creatorId, title: $title, description: $description, coverImageUrl: $coverImageUrl, dietType: $dietType, durationWeeks: $durationWeeks, calorieRange: $calorieRange, priceArtifacts: $priceArtifacts, previewDay: $previewDay, fullPlan: $fullPlan, shoppingList: $shoppingList, purchaseCount: $purchaseCount, averageRating: $averageRating, reviewCount: $reviewCount, creatorData: $creatorData, isPurchased: $isPurchased, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$MealPlanCopyWith<$Res> implements $MealPlanCopyWith<$Res> {
  factory _$MealPlanCopyWith(_MealPlan value, $Res Function(_MealPlan) _then) = __$MealPlanCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'creator_id') String creatorId, String title, String description,@JsonKey(name: 'cover_image_url') String coverImageUrl,@JsonKey(name: 'diet_type') String dietType,@JsonKey(name: 'duration_weeks') int durationWeeks,@JsonKey(name: 'calorie_range') String calorieRange,@JsonKey(name: 'price_artifacts') Map<String, int> priceArtifacts,@JsonKey(name: 'preview_day') Map<String, dynamic> previewDay,@JsonKey(name: 'full_plan') Map<String, dynamic>? fullPlan,@JsonKey(name: 'shopping_list') List<String> shoppingList,@JsonKey(name: 'purchase_count') int purchaseCount,@JsonKey(name: 'average_rating') double averageRating,@JsonKey(name: 'review_count') int reviewCount,@JsonKey(name: 'creator_data') CreatorData creatorData,@JsonKey(name: 'is_purchased') bool isPurchased,@JsonKey(name: 'created_at') String createdAt
});


@override $CreatorDataCopyWith<$Res> get creatorData;

}
/// @nodoc
class __$MealPlanCopyWithImpl<$Res>
    implements _$MealPlanCopyWith<$Res> {
  __$MealPlanCopyWithImpl(this._self, this._then);

  final _MealPlan _self;
  final $Res Function(_MealPlan) _then;

/// Create a copy of MealPlan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? creatorId = null,Object? title = null,Object? description = null,Object? coverImageUrl = null,Object? dietType = null,Object? durationWeeks = null,Object? calorieRange = null,Object? priceArtifacts = null,Object? previewDay = null,Object? fullPlan = freezed,Object? shoppingList = null,Object? purchaseCount = null,Object? averageRating = null,Object? reviewCount = null,Object? creatorData = null,Object? isPurchased = null,Object? createdAt = null,}) {
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
as List<String>,purchaseCount: null == purchaseCount ? _self.purchaseCount : purchaseCount // ignore: cast_nullable_to_non_nullable
as int,averageRating: null == averageRating ? _self.averageRating : averageRating // ignore: cast_nullable_to_non_nullable
as double,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,creatorData: null == creatorData ? _self.creatorData : creatorData // ignore: cast_nullable_to_non_nullable
as CreatorData,isPurchased: null == isPurchased ? _self.isPurchased : isPurchased // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
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

 String get id;@JsonKey(name: 'creator_id') String get creatorId; String get title; String get description;@JsonKey(name: 'cover_image_url') String get coverImageUrl; String get category;@JsonKey(name: 'duration_weeks') int get durationWeeks;@JsonKey(name: 'price_artifacts') Map<String, int> get priceArtifacts;@JsonKey(name: 'purchase_count') int get purchaseCount;@JsonKey(name: 'creator_data') CreatorData get creatorData;@JsonKey(name: 'is_purchased') bool get isPurchased;@JsonKey(name: 'created_at') String get createdAt;
/// Create a copy of TrainingProgramme
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrainingProgrammeCopyWith<TrainingProgramme> get copyWith => _$TrainingProgrammeCopyWithImpl<TrainingProgramme>(this as TrainingProgramme, _$identity);

  /// Serializes this TrainingProgramme to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrainingProgramme&&(identical(other.id, id) || other.id == id)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.coverImageUrl, coverImageUrl) || other.coverImageUrl == coverImageUrl)&&(identical(other.category, category) || other.category == category)&&(identical(other.durationWeeks, durationWeeks) || other.durationWeeks == durationWeeks)&&const DeepCollectionEquality().equals(other.priceArtifacts, priceArtifacts)&&(identical(other.purchaseCount, purchaseCount) || other.purchaseCount == purchaseCount)&&(identical(other.creatorData, creatorData) || other.creatorData == creatorData)&&(identical(other.isPurchased, isPurchased) || other.isPurchased == isPurchased)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,creatorId,title,description,coverImageUrl,category,durationWeeks,const DeepCollectionEquality().hash(priceArtifacts),purchaseCount,creatorData,isPurchased,createdAt);

@override
String toString() {
  return 'TrainingProgramme(id: $id, creatorId: $creatorId, title: $title, description: $description, coverImageUrl: $coverImageUrl, category: $category, durationWeeks: $durationWeeks, priceArtifacts: $priceArtifacts, purchaseCount: $purchaseCount, creatorData: $creatorData, isPurchased: $isPurchased, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $TrainingProgrammeCopyWith<$Res>  {
  factory $TrainingProgrammeCopyWith(TrainingProgramme value, $Res Function(TrainingProgramme) _then) = _$TrainingProgrammeCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'creator_id') String creatorId, String title, String description,@JsonKey(name: 'cover_image_url') String coverImageUrl, String category,@JsonKey(name: 'duration_weeks') int durationWeeks,@JsonKey(name: 'price_artifacts') Map<String, int> priceArtifacts,@JsonKey(name: 'purchase_count') int purchaseCount,@JsonKey(name: 'creator_data') CreatorData creatorData,@JsonKey(name: 'is_purchased') bool isPurchased,@JsonKey(name: 'created_at') String createdAt
});


$CreatorDataCopyWith<$Res> get creatorData;

}
/// @nodoc
class _$TrainingProgrammeCopyWithImpl<$Res>
    implements $TrainingProgrammeCopyWith<$Res> {
  _$TrainingProgrammeCopyWithImpl(this._self, this._then);

  final TrainingProgramme _self;
  final $Res Function(TrainingProgramme) _then;

/// Create a copy of TrainingProgramme
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? creatorId = null,Object? title = null,Object? description = null,Object? coverImageUrl = null,Object? category = null,Object? durationWeeks = null,Object? priceArtifacts = null,Object? purchaseCount = null,Object? creatorData = null,Object? isPurchased = null,Object? createdAt = null,}) {
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
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'creator_id')  String creatorId,  String title,  String description, @JsonKey(name: 'cover_image_url')  String coverImageUrl,  String category, @JsonKey(name: 'duration_weeks')  int durationWeeks, @JsonKey(name: 'price_artifacts')  Map<String, int> priceArtifacts, @JsonKey(name: 'purchase_count')  int purchaseCount, @JsonKey(name: 'creator_data')  CreatorData creatorData, @JsonKey(name: 'is_purchased')  bool isPurchased, @JsonKey(name: 'created_at')  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrainingProgramme() when $default != null:
return $default(_that.id,_that.creatorId,_that.title,_that.description,_that.coverImageUrl,_that.category,_that.durationWeeks,_that.priceArtifacts,_that.purchaseCount,_that.creatorData,_that.isPurchased,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'creator_id')  String creatorId,  String title,  String description, @JsonKey(name: 'cover_image_url')  String coverImageUrl,  String category, @JsonKey(name: 'duration_weeks')  int durationWeeks, @JsonKey(name: 'price_artifacts')  Map<String, int> priceArtifacts, @JsonKey(name: 'purchase_count')  int purchaseCount, @JsonKey(name: 'creator_data')  CreatorData creatorData, @JsonKey(name: 'is_purchased')  bool isPurchased, @JsonKey(name: 'created_at')  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _TrainingProgramme():
return $default(_that.id,_that.creatorId,_that.title,_that.description,_that.coverImageUrl,_that.category,_that.durationWeeks,_that.priceArtifacts,_that.purchaseCount,_that.creatorData,_that.isPurchased,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'creator_id')  String creatorId,  String title,  String description, @JsonKey(name: 'cover_image_url')  String coverImageUrl,  String category, @JsonKey(name: 'duration_weeks')  int durationWeeks, @JsonKey(name: 'price_artifacts')  Map<String, int> priceArtifacts, @JsonKey(name: 'purchase_count')  int purchaseCount, @JsonKey(name: 'creator_data')  CreatorData creatorData, @JsonKey(name: 'is_purchased')  bool isPurchased, @JsonKey(name: 'created_at')  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _TrainingProgramme() when $default != null:
return $default(_that.id,_that.creatorId,_that.title,_that.description,_that.coverImageUrl,_that.category,_that.durationWeeks,_that.priceArtifacts,_that.purchaseCount,_that.creatorData,_that.isPurchased,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrainingProgramme implements TrainingProgramme {
  const _TrainingProgramme({required this.id, @JsonKey(name: 'creator_id') required this.creatorId, required this.title, required this.description, @JsonKey(name: 'cover_image_url') required this.coverImageUrl, required this.category, @JsonKey(name: 'duration_weeks') required this.durationWeeks, @JsonKey(name: 'price_artifacts') required final  Map<String, int> priceArtifacts, @JsonKey(name: 'purchase_count') this.purchaseCount = 0, @JsonKey(name: 'creator_data') required this.creatorData, @JsonKey(name: 'is_purchased') this.isPurchased = false, @JsonKey(name: 'created_at') required this.createdAt}): _priceArtifacts = priceArtifacts;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrainingProgramme&&(identical(other.id, id) || other.id == id)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.coverImageUrl, coverImageUrl) || other.coverImageUrl == coverImageUrl)&&(identical(other.category, category) || other.category == category)&&(identical(other.durationWeeks, durationWeeks) || other.durationWeeks == durationWeeks)&&const DeepCollectionEquality().equals(other._priceArtifacts, _priceArtifacts)&&(identical(other.purchaseCount, purchaseCount) || other.purchaseCount == purchaseCount)&&(identical(other.creatorData, creatorData) || other.creatorData == creatorData)&&(identical(other.isPurchased, isPurchased) || other.isPurchased == isPurchased)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,creatorId,title,description,coverImageUrl,category,durationWeeks,const DeepCollectionEquality().hash(_priceArtifacts),purchaseCount,creatorData,isPurchased,createdAt);

@override
String toString() {
  return 'TrainingProgramme(id: $id, creatorId: $creatorId, title: $title, description: $description, coverImageUrl: $coverImageUrl, category: $category, durationWeeks: $durationWeeks, priceArtifacts: $priceArtifacts, purchaseCount: $purchaseCount, creatorData: $creatorData, isPurchased: $isPurchased, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$TrainingProgrammeCopyWith<$Res> implements $TrainingProgrammeCopyWith<$Res> {
  factory _$TrainingProgrammeCopyWith(_TrainingProgramme value, $Res Function(_TrainingProgramme) _then) = __$TrainingProgrammeCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'creator_id') String creatorId, String title, String description,@JsonKey(name: 'cover_image_url') String coverImageUrl, String category,@JsonKey(name: 'duration_weeks') int durationWeeks,@JsonKey(name: 'price_artifacts') Map<String, int> priceArtifacts,@JsonKey(name: 'purchase_count') int purchaseCount,@JsonKey(name: 'creator_data') CreatorData creatorData,@JsonKey(name: 'is_purchased') bool isPurchased,@JsonKey(name: 'created_at') String createdAt
});


@override $CreatorDataCopyWith<$Res> get creatorData;

}
/// @nodoc
class __$TrainingProgrammeCopyWithImpl<$Res>
    implements _$TrainingProgrammeCopyWith<$Res> {
  __$TrainingProgrammeCopyWithImpl(this._self, this._then);

  final _TrainingProgramme _self;
  final $Res Function(_TrainingProgramme) _then;

/// Create a copy of TrainingProgramme
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? creatorId = null,Object? title = null,Object? description = null,Object? coverImageUrl = null,Object? category = null,Object? durationWeeks = null,Object? priceArtifacts = null,Object? purchaseCount = null,Object? creatorData = null,Object? isPurchased = null,Object? createdAt = null,}) {
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
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
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

 String get id; String get name; String get brand; String get description; String get category;@JsonKey(name: 'image_url') String get imageUrl;@JsonKey(name: 'affiliate_url') String get affiliateUrl;@JsonKey(name: 'price_display') String get priceDisplay;@JsonKey(name: 'recommended_by') String? get recommendedBy;@JsonKey(name: 'recommender_data') Map<String, dynamic>? get recommenderData;@JsonKey(name: 'click_count') int get clickCount;@JsonKey(name: 'created_at') String get createdAt;
/// Create a copy of MarketplaceProduct
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarketplaceProductCopyWith<MarketplaceProduct> get copyWith => _$MarketplaceProductCopyWithImpl<MarketplaceProduct>(this as MarketplaceProduct, _$identity);

  /// Serializes this MarketplaceProduct to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarketplaceProduct&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.affiliateUrl, affiliateUrl) || other.affiliateUrl == affiliateUrl)&&(identical(other.priceDisplay, priceDisplay) || other.priceDisplay == priceDisplay)&&(identical(other.recommendedBy, recommendedBy) || other.recommendedBy == recommendedBy)&&const DeepCollectionEquality().equals(other.recommenderData, recommenderData)&&(identical(other.clickCount, clickCount) || other.clickCount == clickCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,brand,description,category,imageUrl,affiliateUrl,priceDisplay,recommendedBy,const DeepCollectionEquality().hash(recommenderData),clickCount,createdAt);

@override
String toString() {
  return 'MarketplaceProduct(id: $id, name: $name, brand: $brand, description: $description, category: $category, imageUrl: $imageUrl, affiliateUrl: $affiliateUrl, priceDisplay: $priceDisplay, recommendedBy: $recommendedBy, recommenderData: $recommenderData, clickCount: $clickCount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $MarketplaceProductCopyWith<$Res>  {
  factory $MarketplaceProductCopyWith(MarketplaceProduct value, $Res Function(MarketplaceProduct) _then) = _$MarketplaceProductCopyWithImpl;
@useResult
$Res call({
 String id, String name, String brand, String description, String category,@JsonKey(name: 'image_url') String imageUrl,@JsonKey(name: 'affiliate_url') String affiliateUrl,@JsonKey(name: 'price_display') String priceDisplay,@JsonKey(name: 'recommended_by') String? recommendedBy,@JsonKey(name: 'recommender_data') Map<String, dynamic>? recommenderData,@JsonKey(name: 'click_count') int clickCount,@JsonKey(name: 'created_at') String createdAt
});




}
/// @nodoc
class _$MarketplaceProductCopyWithImpl<$Res>
    implements $MarketplaceProductCopyWith<$Res> {
  _$MarketplaceProductCopyWithImpl(this._self, this._then);

  final MarketplaceProduct _self;
  final $Res Function(MarketplaceProduct) _then;

/// Create a copy of MarketplaceProduct
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? brand = null,Object? description = null,Object? category = null,Object? imageUrl = null,Object? affiliateUrl = null,Object? priceDisplay = null,Object? recommendedBy = freezed,Object? recommenderData = freezed,Object? clickCount = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,affiliateUrl: null == affiliateUrl ? _self.affiliateUrl : affiliateUrl // ignore: cast_nullable_to_non_nullable
as String,priceDisplay: null == priceDisplay ? _self.priceDisplay : priceDisplay // ignore: cast_nullable_to_non_nullable
as String,recommendedBy: freezed == recommendedBy ? _self.recommendedBy : recommendedBy // ignore: cast_nullable_to_non_nullable
as String?,recommenderData: freezed == recommenderData ? _self.recommenderData : recommenderData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,clickCount: null == clickCount ? _self.clickCount : clickCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String brand,  String description,  String category, @JsonKey(name: 'image_url')  String imageUrl, @JsonKey(name: 'affiliate_url')  String affiliateUrl, @JsonKey(name: 'price_display')  String priceDisplay, @JsonKey(name: 'recommended_by')  String? recommendedBy, @JsonKey(name: 'recommender_data')  Map<String, dynamic>? recommenderData, @JsonKey(name: 'click_count')  int clickCount, @JsonKey(name: 'created_at')  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MarketplaceProduct() when $default != null:
return $default(_that.id,_that.name,_that.brand,_that.description,_that.category,_that.imageUrl,_that.affiliateUrl,_that.priceDisplay,_that.recommendedBy,_that.recommenderData,_that.clickCount,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String brand,  String description,  String category, @JsonKey(name: 'image_url')  String imageUrl, @JsonKey(name: 'affiliate_url')  String affiliateUrl, @JsonKey(name: 'price_display')  String priceDisplay, @JsonKey(name: 'recommended_by')  String? recommendedBy, @JsonKey(name: 'recommender_data')  Map<String, dynamic>? recommenderData, @JsonKey(name: 'click_count')  int clickCount, @JsonKey(name: 'created_at')  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _MarketplaceProduct():
return $default(_that.id,_that.name,_that.brand,_that.description,_that.category,_that.imageUrl,_that.affiliateUrl,_that.priceDisplay,_that.recommendedBy,_that.recommenderData,_that.clickCount,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String brand,  String description,  String category, @JsonKey(name: 'image_url')  String imageUrl, @JsonKey(name: 'affiliate_url')  String affiliateUrl, @JsonKey(name: 'price_display')  String priceDisplay, @JsonKey(name: 'recommended_by')  String? recommendedBy, @JsonKey(name: 'recommender_data')  Map<String, dynamic>? recommenderData, @JsonKey(name: 'click_count')  int clickCount, @JsonKey(name: 'created_at')  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _MarketplaceProduct() when $default != null:
return $default(_that.id,_that.name,_that.brand,_that.description,_that.category,_that.imageUrl,_that.affiliateUrl,_that.priceDisplay,_that.recommendedBy,_that.recommenderData,_that.clickCount,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MarketplaceProduct implements MarketplaceProduct {
  const _MarketplaceProduct({required this.id, required this.name, required this.brand, required this.description, required this.category, @JsonKey(name: 'image_url') required this.imageUrl, @JsonKey(name: 'affiliate_url') required this.affiliateUrl, @JsonKey(name: 'price_display') required this.priceDisplay, @JsonKey(name: 'recommended_by') this.recommendedBy, @JsonKey(name: 'recommender_data') final  Map<String, dynamic>? recommenderData, @JsonKey(name: 'click_count') this.clickCount = 0, @JsonKey(name: 'created_at') required this.createdAt}): _recommenderData = recommenderData;
  factory _MarketplaceProduct.fromJson(Map<String, dynamic> json) => _$MarketplaceProductFromJson(json);

@override final  String id;
@override final  String name;
@override final  String brand;
@override final  String description;
@override final  String category;
@override@JsonKey(name: 'image_url') final  String imageUrl;
@override@JsonKey(name: 'affiliate_url') final  String affiliateUrl;
@override@JsonKey(name: 'price_display') final  String priceDisplay;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MarketplaceProduct&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.affiliateUrl, affiliateUrl) || other.affiliateUrl == affiliateUrl)&&(identical(other.priceDisplay, priceDisplay) || other.priceDisplay == priceDisplay)&&(identical(other.recommendedBy, recommendedBy) || other.recommendedBy == recommendedBy)&&const DeepCollectionEquality().equals(other._recommenderData, _recommenderData)&&(identical(other.clickCount, clickCount) || other.clickCount == clickCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,brand,description,category,imageUrl,affiliateUrl,priceDisplay,recommendedBy,const DeepCollectionEquality().hash(_recommenderData),clickCount,createdAt);

@override
String toString() {
  return 'MarketplaceProduct(id: $id, name: $name, brand: $brand, description: $description, category: $category, imageUrl: $imageUrl, affiliateUrl: $affiliateUrl, priceDisplay: $priceDisplay, recommendedBy: $recommendedBy, recommenderData: $recommenderData, clickCount: $clickCount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$MarketplaceProductCopyWith<$Res> implements $MarketplaceProductCopyWith<$Res> {
  factory _$MarketplaceProductCopyWith(_MarketplaceProduct value, $Res Function(_MarketplaceProduct) _then) = __$MarketplaceProductCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String brand, String description, String category,@JsonKey(name: 'image_url') String imageUrl,@JsonKey(name: 'affiliate_url') String affiliateUrl,@JsonKey(name: 'price_display') String priceDisplay,@JsonKey(name: 'recommended_by') String? recommendedBy,@JsonKey(name: 'recommender_data') Map<String, dynamic>? recommenderData,@JsonKey(name: 'click_count') int clickCount,@JsonKey(name: 'created_at') String createdAt
});




}
/// @nodoc
class __$MarketplaceProductCopyWithImpl<$Res>
    implements _$MarketplaceProductCopyWith<$Res> {
  __$MarketplaceProductCopyWithImpl(this._self, this._then);

  final _MarketplaceProduct _self;
  final $Res Function(_MarketplaceProduct) _then;

/// Create a copy of MarketplaceProduct
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? brand = null,Object? description = null,Object? category = null,Object? imageUrl = null,Object? affiliateUrl = null,Object? priceDisplay = null,Object? recommendedBy = freezed,Object? recommenderData = freezed,Object? clickCount = null,Object? createdAt = null,}) {
  return _then(_MarketplaceProduct(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,affiliateUrl: null == affiliateUrl ? _self.affiliateUrl : affiliateUrl // ignore: cast_nullable_to_non_nullable
as String,priceDisplay: null == priceDisplay ? _self.priceDisplay : priceDisplay // ignore: cast_nullable_to_non_nullable
as String,recommendedBy: freezed == recommendedBy ? _self.recommendedBy : recommendedBy // ignore: cast_nullable_to_non_nullable
as String?,recommenderData: freezed == recommenderData ? _self._recommenderData : recommenderData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,clickCount: null == clickCount ? _self.clickCount : clickCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
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
mixin _$MarketplaceEvent {

 String get id;@JsonKey(name: 'creator_data') CreatorData get creatorData;@JsonKey(name: 'gym_data') GymData? get gymData; String get title; String get description;@JsonKey(name: 'cover_image_url') String get coverImageUrl;@JsonKey(name: 'event_type') String get eventType; String get location;@JsonKey(name: 'online_url') String get onlineUrl;@JsonKey(name: 'start_datetime') String get startDatetime;@JsonKey(name: 'end_datetime') String get endDatetime; String get timezone; int get capacity;@JsonKey(name: 'ticket_price_artifacts') Map<String, int> get ticketPriceArtifacts;@JsonKey(name: 'is_free') bool get isFree;@JsonKey(name: 'is_published') bool get isPublished;@JsonKey(name: 'is_cancelled') bool get isCancelled;@JsonKey(name: 'attendee_count') int get attendeeCount; List<String> get tags; String get category;@JsonKey(name: 'is_registered') bool get isRegistered;@JsonKey(name: 'spots_remaining') int? get spotsRemaining;@JsonKey(name: 'created_at') String get createdAt;
/// Create a copy of MarketplaceEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarketplaceEventCopyWith<MarketplaceEvent> get copyWith => _$MarketplaceEventCopyWithImpl<MarketplaceEvent>(this as MarketplaceEvent, _$identity);

  /// Serializes this MarketplaceEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarketplaceEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.creatorData, creatorData) || other.creatorData == creatorData)&&(identical(other.gymData, gymData) || other.gymData == gymData)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.coverImageUrl, coverImageUrl) || other.coverImageUrl == coverImageUrl)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.location, location) || other.location == location)&&(identical(other.onlineUrl, onlineUrl) || other.onlineUrl == onlineUrl)&&(identical(other.startDatetime, startDatetime) || other.startDatetime == startDatetime)&&(identical(other.endDatetime, endDatetime) || other.endDatetime == endDatetime)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.capacity, capacity) || other.capacity == capacity)&&const DeepCollectionEquality().equals(other.ticketPriceArtifacts, ticketPriceArtifacts)&&(identical(other.isFree, isFree) || other.isFree == isFree)&&(identical(other.isPublished, isPublished) || other.isPublished == isPublished)&&(identical(other.isCancelled, isCancelled) || other.isCancelled == isCancelled)&&(identical(other.attendeeCount, attendeeCount) || other.attendeeCount == attendeeCount)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.category, category) || other.category == category)&&(identical(other.isRegistered, isRegistered) || other.isRegistered == isRegistered)&&(identical(other.spotsRemaining, spotsRemaining) || other.spotsRemaining == spotsRemaining)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,creatorData,gymData,title,description,coverImageUrl,eventType,location,onlineUrl,startDatetime,endDatetime,timezone,capacity,const DeepCollectionEquality().hash(ticketPriceArtifacts),isFree,isPublished,isCancelled,attendeeCount,const DeepCollectionEquality().hash(tags),category,isRegistered,spotsRemaining,createdAt]);

@override
String toString() {
  return 'MarketplaceEvent(id: $id, creatorData: $creatorData, gymData: $gymData, title: $title, description: $description, coverImageUrl: $coverImageUrl, eventType: $eventType, location: $location, onlineUrl: $onlineUrl, startDatetime: $startDatetime, endDatetime: $endDatetime, timezone: $timezone, capacity: $capacity, ticketPriceArtifacts: $ticketPriceArtifacts, isFree: $isFree, isPublished: $isPublished, isCancelled: $isCancelled, attendeeCount: $attendeeCount, tags: $tags, category: $category, isRegistered: $isRegistered, spotsRemaining: $spotsRemaining, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $MarketplaceEventCopyWith<$Res>  {
  factory $MarketplaceEventCopyWith(MarketplaceEvent value, $Res Function(MarketplaceEvent) _then) = _$MarketplaceEventCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'creator_data') CreatorData creatorData,@JsonKey(name: 'gym_data') GymData? gymData, String title, String description,@JsonKey(name: 'cover_image_url') String coverImageUrl,@JsonKey(name: 'event_type') String eventType, String location,@JsonKey(name: 'online_url') String onlineUrl,@JsonKey(name: 'start_datetime') String startDatetime,@JsonKey(name: 'end_datetime') String endDatetime, String timezone, int capacity,@JsonKey(name: 'ticket_price_artifacts') Map<String, int> ticketPriceArtifacts,@JsonKey(name: 'is_free') bool isFree,@JsonKey(name: 'is_published') bool isPublished,@JsonKey(name: 'is_cancelled') bool isCancelled,@JsonKey(name: 'attendee_count') int attendeeCount, List<String> tags, String category,@JsonKey(name: 'is_registered') bool isRegistered,@JsonKey(name: 'spots_remaining') int? spotsRemaining,@JsonKey(name: 'created_at') String createdAt
});


$CreatorDataCopyWith<$Res> get creatorData;$GymDataCopyWith<$Res>? get gymData;

}
/// @nodoc
class _$MarketplaceEventCopyWithImpl<$Res>
    implements $MarketplaceEventCopyWith<$Res> {
  _$MarketplaceEventCopyWithImpl(this._self, this._then);

  final MarketplaceEvent _self;
  final $Res Function(MarketplaceEvent) _then;

/// Create a copy of MarketplaceEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? creatorData = null,Object? gymData = freezed,Object? title = null,Object? description = null,Object? coverImageUrl = null,Object? eventType = null,Object? location = null,Object? onlineUrl = null,Object? startDatetime = null,Object? endDatetime = null,Object? timezone = null,Object? capacity = null,Object? ticketPriceArtifacts = null,Object? isFree = null,Object? isPublished = null,Object? isCancelled = null,Object? attendeeCount = null,Object? tags = null,Object? category = null,Object? isRegistered = null,Object? spotsRemaining = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,creatorData: null == creatorData ? _self.creatorData : creatorData // ignore: cast_nullable_to_non_nullable
as CreatorData,gymData: freezed == gymData ? _self.gymData : gymData // ignore: cast_nullable_to_non_nullable
as GymData?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,coverImageUrl: null == coverImageUrl ? _self.coverImageUrl : coverImageUrl // ignore: cast_nullable_to_non_nullable
as String,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,onlineUrl: null == onlineUrl ? _self.onlineUrl : onlineUrl // ignore: cast_nullable_to_non_nullable
as String,startDatetime: null == startDatetime ? _self.startDatetime : startDatetime // ignore: cast_nullable_to_non_nullable
as String,endDatetime: null == endDatetime ? _self.endDatetime : endDatetime // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,capacity: null == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int,ticketPriceArtifacts: null == ticketPriceArtifacts ? _self.ticketPriceArtifacts : ticketPriceArtifacts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,isFree: null == isFree ? _self.isFree : isFree // ignore: cast_nullable_to_non_nullable
as bool,isPublished: null == isPublished ? _self.isPublished : isPublished // ignore: cast_nullable_to_non_nullable
as bool,isCancelled: null == isCancelled ? _self.isCancelled : isCancelled // ignore: cast_nullable_to_non_nullable
as bool,attendeeCount: null == attendeeCount ? _self.attendeeCount : attendeeCount // ignore: cast_nullable_to_non_nullable
as int,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,isRegistered: null == isRegistered ? _self.isRegistered : isRegistered // ignore: cast_nullable_to_non_nullable
as bool,spotsRemaining: freezed == spotsRemaining ? _self.spotsRemaining : spotsRemaining // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'creator_data')  CreatorData creatorData, @JsonKey(name: 'gym_data')  GymData? gymData,  String title,  String description, @JsonKey(name: 'cover_image_url')  String coverImageUrl, @JsonKey(name: 'event_type')  String eventType,  String location, @JsonKey(name: 'online_url')  String onlineUrl, @JsonKey(name: 'start_datetime')  String startDatetime, @JsonKey(name: 'end_datetime')  String endDatetime,  String timezone,  int capacity, @JsonKey(name: 'ticket_price_artifacts')  Map<String, int> ticketPriceArtifacts, @JsonKey(name: 'is_free')  bool isFree, @JsonKey(name: 'is_published')  bool isPublished, @JsonKey(name: 'is_cancelled')  bool isCancelled, @JsonKey(name: 'attendee_count')  int attendeeCount,  List<String> tags,  String category, @JsonKey(name: 'is_registered')  bool isRegistered, @JsonKey(name: 'spots_remaining')  int? spotsRemaining, @JsonKey(name: 'created_at')  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MarketplaceEvent() when $default != null:
return $default(_that.id,_that.creatorData,_that.gymData,_that.title,_that.description,_that.coverImageUrl,_that.eventType,_that.location,_that.onlineUrl,_that.startDatetime,_that.endDatetime,_that.timezone,_that.capacity,_that.ticketPriceArtifacts,_that.isFree,_that.isPublished,_that.isCancelled,_that.attendeeCount,_that.tags,_that.category,_that.isRegistered,_that.spotsRemaining,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'creator_data')  CreatorData creatorData, @JsonKey(name: 'gym_data')  GymData? gymData,  String title,  String description, @JsonKey(name: 'cover_image_url')  String coverImageUrl, @JsonKey(name: 'event_type')  String eventType,  String location, @JsonKey(name: 'online_url')  String onlineUrl, @JsonKey(name: 'start_datetime')  String startDatetime, @JsonKey(name: 'end_datetime')  String endDatetime,  String timezone,  int capacity, @JsonKey(name: 'ticket_price_artifacts')  Map<String, int> ticketPriceArtifacts, @JsonKey(name: 'is_free')  bool isFree, @JsonKey(name: 'is_published')  bool isPublished, @JsonKey(name: 'is_cancelled')  bool isCancelled, @JsonKey(name: 'attendee_count')  int attendeeCount,  List<String> tags,  String category, @JsonKey(name: 'is_registered')  bool isRegistered, @JsonKey(name: 'spots_remaining')  int? spotsRemaining, @JsonKey(name: 'created_at')  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _MarketplaceEvent():
return $default(_that.id,_that.creatorData,_that.gymData,_that.title,_that.description,_that.coverImageUrl,_that.eventType,_that.location,_that.onlineUrl,_that.startDatetime,_that.endDatetime,_that.timezone,_that.capacity,_that.ticketPriceArtifacts,_that.isFree,_that.isPublished,_that.isCancelled,_that.attendeeCount,_that.tags,_that.category,_that.isRegistered,_that.spotsRemaining,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'creator_data')  CreatorData creatorData, @JsonKey(name: 'gym_data')  GymData? gymData,  String title,  String description, @JsonKey(name: 'cover_image_url')  String coverImageUrl, @JsonKey(name: 'event_type')  String eventType,  String location, @JsonKey(name: 'online_url')  String onlineUrl, @JsonKey(name: 'start_datetime')  String startDatetime, @JsonKey(name: 'end_datetime')  String endDatetime,  String timezone,  int capacity, @JsonKey(name: 'ticket_price_artifacts')  Map<String, int> ticketPriceArtifacts, @JsonKey(name: 'is_free')  bool isFree, @JsonKey(name: 'is_published')  bool isPublished, @JsonKey(name: 'is_cancelled')  bool isCancelled, @JsonKey(name: 'attendee_count')  int attendeeCount,  List<String> tags,  String category, @JsonKey(name: 'is_registered')  bool isRegistered, @JsonKey(name: 'spots_remaining')  int? spotsRemaining, @JsonKey(name: 'created_at')  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _MarketplaceEvent() when $default != null:
return $default(_that.id,_that.creatorData,_that.gymData,_that.title,_that.description,_that.coverImageUrl,_that.eventType,_that.location,_that.onlineUrl,_that.startDatetime,_that.endDatetime,_that.timezone,_that.capacity,_that.ticketPriceArtifacts,_that.isFree,_that.isPublished,_that.isCancelled,_that.attendeeCount,_that.tags,_that.category,_that.isRegistered,_that.spotsRemaining,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MarketplaceEvent implements MarketplaceEvent {
  const _MarketplaceEvent({required this.id, @JsonKey(name: 'creator_data') required this.creatorData, @JsonKey(name: 'gym_data') this.gymData, required this.title, required this.description, @JsonKey(name: 'cover_image_url') required this.coverImageUrl, @JsonKey(name: 'event_type') required this.eventType, required this.location, @JsonKey(name: 'online_url') required this.onlineUrl, @JsonKey(name: 'start_datetime') required this.startDatetime, @JsonKey(name: 'end_datetime') required this.endDatetime, required this.timezone, required this.capacity, @JsonKey(name: 'ticket_price_artifacts') required final  Map<String, int> ticketPriceArtifacts, @JsonKey(name: 'is_free') this.isFree = false, @JsonKey(name: 'is_published') this.isPublished = false, @JsonKey(name: 'is_cancelled') this.isCancelled = false, @JsonKey(name: 'attendee_count') this.attendeeCount = 0, final  List<String> tags = const <String>[], this.category = '', @JsonKey(name: 'is_registered') this.isRegistered = false, @JsonKey(name: 'spots_remaining') this.spotsRemaining, @JsonKey(name: 'created_at') required this.createdAt}): _ticketPriceArtifacts = ticketPriceArtifacts,_tags = tags;
  factory _MarketplaceEvent.fromJson(Map<String, dynamic> json) => _$MarketplaceEventFromJson(json);

@override final  String id;
@override@JsonKey(name: 'creator_data') final  CreatorData creatorData;
@override@JsonKey(name: 'gym_data') final  GymData? gymData;
@override final  String title;
@override final  String description;
@override@JsonKey(name: 'cover_image_url') final  String coverImageUrl;
@override@JsonKey(name: 'event_type') final  String eventType;
@override final  String location;
@override@JsonKey(name: 'online_url') final  String onlineUrl;
@override@JsonKey(name: 'start_datetime') final  String startDatetime;
@override@JsonKey(name: 'end_datetime') final  String endDatetime;
@override final  String timezone;
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
@override@JsonKey(name: 'is_registered') final  bool isRegistered;
@override@JsonKey(name: 'spots_remaining') final  int? spotsRemaining;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MarketplaceEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.creatorData, creatorData) || other.creatorData == creatorData)&&(identical(other.gymData, gymData) || other.gymData == gymData)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.coverImageUrl, coverImageUrl) || other.coverImageUrl == coverImageUrl)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.location, location) || other.location == location)&&(identical(other.onlineUrl, onlineUrl) || other.onlineUrl == onlineUrl)&&(identical(other.startDatetime, startDatetime) || other.startDatetime == startDatetime)&&(identical(other.endDatetime, endDatetime) || other.endDatetime == endDatetime)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.capacity, capacity) || other.capacity == capacity)&&const DeepCollectionEquality().equals(other._ticketPriceArtifacts, _ticketPriceArtifacts)&&(identical(other.isFree, isFree) || other.isFree == isFree)&&(identical(other.isPublished, isPublished) || other.isPublished == isPublished)&&(identical(other.isCancelled, isCancelled) || other.isCancelled == isCancelled)&&(identical(other.attendeeCount, attendeeCount) || other.attendeeCount == attendeeCount)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.category, category) || other.category == category)&&(identical(other.isRegistered, isRegistered) || other.isRegistered == isRegistered)&&(identical(other.spotsRemaining, spotsRemaining) || other.spotsRemaining == spotsRemaining)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,creatorData,gymData,title,description,coverImageUrl,eventType,location,onlineUrl,startDatetime,endDatetime,timezone,capacity,const DeepCollectionEquality().hash(_ticketPriceArtifacts),isFree,isPublished,isCancelled,attendeeCount,const DeepCollectionEquality().hash(_tags),category,isRegistered,spotsRemaining,createdAt]);

@override
String toString() {
  return 'MarketplaceEvent(id: $id, creatorData: $creatorData, gymData: $gymData, title: $title, description: $description, coverImageUrl: $coverImageUrl, eventType: $eventType, location: $location, onlineUrl: $onlineUrl, startDatetime: $startDatetime, endDatetime: $endDatetime, timezone: $timezone, capacity: $capacity, ticketPriceArtifacts: $ticketPriceArtifacts, isFree: $isFree, isPublished: $isPublished, isCancelled: $isCancelled, attendeeCount: $attendeeCount, tags: $tags, category: $category, isRegistered: $isRegistered, spotsRemaining: $spotsRemaining, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$MarketplaceEventCopyWith<$Res> implements $MarketplaceEventCopyWith<$Res> {
  factory _$MarketplaceEventCopyWith(_MarketplaceEvent value, $Res Function(_MarketplaceEvent) _then) = __$MarketplaceEventCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'creator_data') CreatorData creatorData,@JsonKey(name: 'gym_data') GymData? gymData, String title, String description,@JsonKey(name: 'cover_image_url') String coverImageUrl,@JsonKey(name: 'event_type') String eventType, String location,@JsonKey(name: 'online_url') String onlineUrl,@JsonKey(name: 'start_datetime') String startDatetime,@JsonKey(name: 'end_datetime') String endDatetime, String timezone, int capacity,@JsonKey(name: 'ticket_price_artifacts') Map<String, int> ticketPriceArtifacts,@JsonKey(name: 'is_free') bool isFree,@JsonKey(name: 'is_published') bool isPublished,@JsonKey(name: 'is_cancelled') bool isCancelled,@JsonKey(name: 'attendee_count') int attendeeCount, List<String> tags, String category,@JsonKey(name: 'is_registered') bool isRegistered,@JsonKey(name: 'spots_remaining') int? spotsRemaining,@JsonKey(name: 'created_at') String createdAt
});


@override $CreatorDataCopyWith<$Res> get creatorData;@override $GymDataCopyWith<$Res>? get gymData;

}
/// @nodoc
class __$MarketplaceEventCopyWithImpl<$Res>
    implements _$MarketplaceEventCopyWith<$Res> {
  __$MarketplaceEventCopyWithImpl(this._self, this._then);

  final _MarketplaceEvent _self;
  final $Res Function(_MarketplaceEvent) _then;

/// Create a copy of MarketplaceEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? creatorData = null,Object? gymData = freezed,Object? title = null,Object? description = null,Object? coverImageUrl = null,Object? eventType = null,Object? location = null,Object? onlineUrl = null,Object? startDatetime = null,Object? endDatetime = null,Object? timezone = null,Object? capacity = null,Object? ticketPriceArtifacts = null,Object? isFree = null,Object? isPublished = null,Object? isCancelled = null,Object? attendeeCount = null,Object? tags = null,Object? category = null,Object? isRegistered = null,Object? spotsRemaining = freezed,Object? createdAt = null,}) {
  return _then(_MarketplaceEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,creatorData: null == creatorData ? _self.creatorData : creatorData // ignore: cast_nullable_to_non_nullable
as CreatorData,gymData: freezed == gymData ? _self.gymData : gymData // ignore: cast_nullable_to_non_nullable
as GymData?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,coverImageUrl: null == coverImageUrl ? _self.coverImageUrl : coverImageUrl // ignore: cast_nullable_to_non_nullable
as String,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,onlineUrl: null == onlineUrl ? _self.onlineUrl : onlineUrl // ignore: cast_nullable_to_non_nullable
as String,startDatetime: null == startDatetime ? _self.startDatetime : startDatetime // ignore: cast_nullable_to_non_nullable
as String,endDatetime: null == endDatetime ? _self.endDatetime : endDatetime // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,capacity: null == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int,ticketPriceArtifacts: null == ticketPriceArtifacts ? _self._ticketPriceArtifacts : ticketPriceArtifacts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,isFree: null == isFree ? _self.isFree : isFree // ignore: cast_nullable_to_non_nullable
as bool,isPublished: null == isPublished ? _self.isPublished : isPublished // ignore: cast_nullable_to_non_nullable
as bool,isCancelled: null == isCancelled ? _self.isCancelled : isCancelled // ignore: cast_nullable_to_non_nullable
as bool,attendeeCount: null == attendeeCount ? _self.attendeeCount : attendeeCount // ignore: cast_nullable_to_non_nullable
as int,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,isRegistered: null == isRegistered ? _self.isRegistered : isRegistered // ignore: cast_nullable_to_non_nullable
as bool,spotsRemaining: freezed == spotsRemaining ? _self.spotsRemaining : spotsRemaining // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
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
}
}


/// @nodoc
mixin _$EventTicket {

 String get id;@JsonKey(name: 'event_data') Map<String, dynamic>? get eventData;@JsonKey(name: 'holder_data') Map<String, dynamic>? get holderData;@JsonKey(name: 'ticket_code') String get ticketCode; String get tier;@JsonKey(name: 'price_paid_artifacts') Map<String, int>? get pricePaidArtifacts; String get status;@JsonKey(name: 'is_checked_in') bool get isCheckedIn;@JsonKey(name: 'checked_in_at') String? get checkedInAt;@JsonKey(name: 'created_at') String get createdAt;
/// Create a copy of EventTicket
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventTicketCopyWith<EventTicket> get copyWith => _$EventTicketCopyWithImpl<EventTicket>(this as EventTicket, _$identity);

  /// Serializes this EventTicket to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventTicket&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.eventData, eventData)&&const DeepCollectionEquality().equals(other.holderData, holderData)&&(identical(other.ticketCode, ticketCode) || other.ticketCode == ticketCode)&&(identical(other.tier, tier) || other.tier == tier)&&const DeepCollectionEquality().equals(other.pricePaidArtifacts, pricePaidArtifacts)&&(identical(other.status, status) || other.status == status)&&(identical(other.isCheckedIn, isCheckedIn) || other.isCheckedIn == isCheckedIn)&&(identical(other.checkedInAt, checkedInAt) || other.checkedInAt == checkedInAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(eventData),const DeepCollectionEquality().hash(holderData),ticketCode,tier,const DeepCollectionEquality().hash(pricePaidArtifacts),status,isCheckedIn,checkedInAt,createdAt);

@override
String toString() {
  return 'EventTicket(id: $id, eventData: $eventData, holderData: $holderData, ticketCode: $ticketCode, tier: $tier, pricePaidArtifacts: $pricePaidArtifacts, status: $status, isCheckedIn: $isCheckedIn, checkedInAt: $checkedInAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $EventTicketCopyWith<$Res>  {
  factory $EventTicketCopyWith(EventTicket value, $Res Function(EventTicket) _then) = _$EventTicketCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'event_data') Map<String, dynamic>? eventData,@JsonKey(name: 'holder_data') Map<String, dynamic>? holderData,@JsonKey(name: 'ticket_code') String ticketCode, String tier,@JsonKey(name: 'price_paid_artifacts') Map<String, int>? pricePaidArtifacts, String status,@JsonKey(name: 'is_checked_in') bool isCheckedIn,@JsonKey(name: 'checked_in_at') String? checkedInAt,@JsonKey(name: 'created_at') String createdAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? eventData = freezed,Object? holderData = freezed,Object? ticketCode = null,Object? tier = null,Object? pricePaidArtifacts = freezed,Object? status = null,Object? isCheckedIn = null,Object? checkedInAt = freezed,Object? createdAt = null,}) {
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'event_data')  Map<String, dynamic>? eventData, @JsonKey(name: 'holder_data')  Map<String, dynamic>? holderData, @JsonKey(name: 'ticket_code')  String ticketCode,  String tier, @JsonKey(name: 'price_paid_artifacts')  Map<String, int>? pricePaidArtifacts,  String status, @JsonKey(name: 'is_checked_in')  bool isCheckedIn, @JsonKey(name: 'checked_in_at')  String? checkedInAt, @JsonKey(name: 'created_at')  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventTicket() when $default != null:
return $default(_that.id,_that.eventData,_that.holderData,_that.ticketCode,_that.tier,_that.pricePaidArtifacts,_that.status,_that.isCheckedIn,_that.checkedInAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'event_data')  Map<String, dynamic>? eventData, @JsonKey(name: 'holder_data')  Map<String, dynamic>? holderData, @JsonKey(name: 'ticket_code')  String ticketCode,  String tier, @JsonKey(name: 'price_paid_artifacts')  Map<String, int>? pricePaidArtifacts,  String status, @JsonKey(name: 'is_checked_in')  bool isCheckedIn, @JsonKey(name: 'checked_in_at')  String? checkedInAt, @JsonKey(name: 'created_at')  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _EventTicket():
return $default(_that.id,_that.eventData,_that.holderData,_that.ticketCode,_that.tier,_that.pricePaidArtifacts,_that.status,_that.isCheckedIn,_that.checkedInAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'event_data')  Map<String, dynamic>? eventData, @JsonKey(name: 'holder_data')  Map<String, dynamic>? holderData, @JsonKey(name: 'ticket_code')  String ticketCode,  String tier, @JsonKey(name: 'price_paid_artifacts')  Map<String, int>? pricePaidArtifacts,  String status, @JsonKey(name: 'is_checked_in')  bool isCheckedIn, @JsonKey(name: 'checked_in_at')  String? checkedInAt, @JsonKey(name: 'created_at')  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _EventTicket() when $default != null:
return $default(_that.id,_that.eventData,_that.holderData,_that.ticketCode,_that.tier,_that.pricePaidArtifacts,_that.status,_that.isCheckedIn,_that.checkedInAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventTicket implements EventTicket {
  const _EventTicket({required this.id, @JsonKey(name: 'event_data') final  Map<String, dynamic>? eventData, @JsonKey(name: 'holder_data') final  Map<String, dynamic>? holderData, @JsonKey(name: 'ticket_code') required this.ticketCode, this.tier = '', @JsonKey(name: 'price_paid_artifacts') final  Map<String, int>? pricePaidArtifacts, this.status = 'active', @JsonKey(name: 'is_checked_in') this.isCheckedIn = false, @JsonKey(name: 'checked_in_at') this.checkedInAt, @JsonKey(name: 'created_at') required this.createdAt}): _eventData = eventData,_holderData = holderData,_pricePaidArtifacts = pricePaidArtifacts;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventTicket&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._eventData, _eventData)&&const DeepCollectionEquality().equals(other._holderData, _holderData)&&(identical(other.ticketCode, ticketCode) || other.ticketCode == ticketCode)&&(identical(other.tier, tier) || other.tier == tier)&&const DeepCollectionEquality().equals(other._pricePaidArtifacts, _pricePaidArtifacts)&&(identical(other.status, status) || other.status == status)&&(identical(other.isCheckedIn, isCheckedIn) || other.isCheckedIn == isCheckedIn)&&(identical(other.checkedInAt, checkedInAt) || other.checkedInAt == checkedInAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_eventData),const DeepCollectionEquality().hash(_holderData),ticketCode,tier,const DeepCollectionEquality().hash(_pricePaidArtifacts),status,isCheckedIn,checkedInAt,createdAt);

@override
String toString() {
  return 'EventTicket(id: $id, eventData: $eventData, holderData: $holderData, ticketCode: $ticketCode, tier: $tier, pricePaidArtifacts: $pricePaidArtifacts, status: $status, isCheckedIn: $isCheckedIn, checkedInAt: $checkedInAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$EventTicketCopyWith<$Res> implements $EventTicketCopyWith<$Res> {
  factory _$EventTicketCopyWith(_EventTicket value, $Res Function(_EventTicket) _then) = __$EventTicketCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'event_data') Map<String, dynamic>? eventData,@JsonKey(name: 'holder_data') Map<String, dynamic>? holderData,@JsonKey(name: 'ticket_code') String ticketCode, String tier,@JsonKey(name: 'price_paid_artifacts') Map<String, int>? pricePaidArtifacts, String status,@JsonKey(name: 'is_checked_in') bool isCheckedIn,@JsonKey(name: 'checked_in_at') String? checkedInAt,@JsonKey(name: 'created_at') String createdAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? eventData = freezed,Object? holderData = freezed,Object? ticketCode = null,Object? tier = null,Object? pricePaidArtifacts = freezed,Object? status = null,Object? isCheckedIn = null,Object? checkedInAt = freezed,Object? createdAt = null,}) {
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
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CartItem {

 String get id;@JsonKey(name: 'item_type') String get itemType;@JsonKey(name: 'meal_plan') MealPlan? get mealPlan; TrainingProgramme? get programme;@JsonKey(name: 'product') MarketplaceProduct? get product; MarketplaceEvent? get event; int get quantity;
/// Create a copy of CartItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartItemCopyWith<CartItem> get copyWith => _$CartItemCopyWithImpl<CartItem>(this as CartItem, _$identity);

  /// Serializes this CartItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CartItem&&(identical(other.id, id) || other.id == id)&&(identical(other.itemType, itemType) || other.itemType == itemType)&&(identical(other.mealPlan, mealPlan) || other.mealPlan == mealPlan)&&(identical(other.programme, programme) || other.programme == programme)&&(identical(other.product, product) || other.product == product)&&(identical(other.event, event) || other.event == event)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,itemType,mealPlan,programme,product,event,quantity);

@override
String toString() {
  return 'CartItem(id: $id, itemType: $itemType, mealPlan: $mealPlan, programme: $programme, product: $product, event: $event, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class $CartItemCopyWith<$Res>  {
  factory $CartItemCopyWith(CartItem value, $Res Function(CartItem) _then) = _$CartItemCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'item_type') String itemType,@JsonKey(name: 'meal_plan') MealPlan? mealPlan, TrainingProgramme? programme,@JsonKey(name: 'product') MarketplaceProduct? product, MarketplaceEvent? event, int quantity
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? itemType = null,Object? mealPlan = freezed,Object? programme = freezed,Object? product = freezed,Object? event = freezed,Object? quantity = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,itemType: null == itemType ? _self.itemType : itemType // ignore: cast_nullable_to_non_nullable
as String,mealPlan: freezed == mealPlan ? _self.mealPlan : mealPlan // ignore: cast_nullable_to_non_nullable
as MealPlan?,programme: freezed == programme ? _self.programme : programme // ignore: cast_nullable_to_non_nullable
as TrainingProgramme?,product: freezed == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as MarketplaceProduct?,event: freezed == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as MarketplaceEvent?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'item_type')  String itemType, @JsonKey(name: 'meal_plan')  MealPlan? mealPlan,  TrainingProgramme? programme, @JsonKey(name: 'product')  MarketplaceProduct? product,  MarketplaceEvent? event,  int quantity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CartItem() when $default != null:
return $default(_that.id,_that.itemType,_that.mealPlan,_that.programme,_that.product,_that.event,_that.quantity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'item_type')  String itemType, @JsonKey(name: 'meal_plan')  MealPlan? mealPlan,  TrainingProgramme? programme, @JsonKey(name: 'product')  MarketplaceProduct? product,  MarketplaceEvent? event,  int quantity)  $default,) {final _that = this;
switch (_that) {
case _CartItem():
return $default(_that.id,_that.itemType,_that.mealPlan,_that.programme,_that.product,_that.event,_that.quantity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'item_type')  String itemType, @JsonKey(name: 'meal_plan')  MealPlan? mealPlan,  TrainingProgramme? programme, @JsonKey(name: 'product')  MarketplaceProduct? product,  MarketplaceEvent? event,  int quantity)?  $default,) {final _that = this;
switch (_that) {
case _CartItem() when $default != null:
return $default(_that.id,_that.itemType,_that.mealPlan,_that.programme,_that.product,_that.event,_that.quantity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CartItem implements CartItem {
  const _CartItem({required this.id, @JsonKey(name: 'item_type') required this.itemType, @JsonKey(name: 'meal_plan') this.mealPlan, this.programme, @JsonKey(name: 'product') this.product, this.event, this.quantity = 1});
  factory _CartItem.fromJson(Map<String, dynamic> json) => _$CartItemFromJson(json);

@override final  String id;
@override@JsonKey(name: 'item_type') final  String itemType;
@override@JsonKey(name: 'meal_plan') final  MealPlan? mealPlan;
@override final  TrainingProgramme? programme;
@override@JsonKey(name: 'product') final  MarketplaceProduct? product;
@override final  MarketplaceEvent? event;
@override@JsonKey() final  int quantity;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CartItem&&(identical(other.id, id) || other.id == id)&&(identical(other.itemType, itemType) || other.itemType == itemType)&&(identical(other.mealPlan, mealPlan) || other.mealPlan == mealPlan)&&(identical(other.programme, programme) || other.programme == programme)&&(identical(other.product, product) || other.product == product)&&(identical(other.event, event) || other.event == event)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,itemType,mealPlan,programme,product,event,quantity);

@override
String toString() {
  return 'CartItem(id: $id, itemType: $itemType, mealPlan: $mealPlan, programme: $programme, product: $product, event: $event, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class _$CartItemCopyWith<$Res> implements $CartItemCopyWith<$Res> {
  factory _$CartItemCopyWith(_CartItem value, $Res Function(_CartItem) _then) = __$CartItemCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'item_type') String itemType,@JsonKey(name: 'meal_plan') MealPlan? mealPlan, TrainingProgramme? programme,@JsonKey(name: 'product') MarketplaceProduct? product, MarketplaceEvent? event, int quantity
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? itemType = null,Object? mealPlan = freezed,Object? programme = freezed,Object? product = freezed,Object? event = freezed,Object? quantity = null,}) {
  return _then(_CartItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,itemType: null == itemType ? _self.itemType : itemType // ignore: cast_nullable_to_non_nullable
as String,mealPlan: freezed == mealPlan ? _self.mealPlan : mealPlan // ignore: cast_nullable_to_non_nullable
as MealPlan?,programme: freezed == programme ? _self.programme : programme // ignore: cast_nullable_to_non_nullable
as TrainingProgramme?,product: freezed == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as MarketplaceProduct?,event: freezed == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as MarketplaceEvent?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,
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

 String get id; List<CartItem> get items;@JsonKey(name: 'discount_code') DiscountCode? get discountCode;@JsonKey(name: 'created_at') String get createdAt;
/// Create a copy of Cart
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartCopyWith<Cart> get copyWith => _$CartCopyWithImpl<Cart>(this as Cart, _$identity);

  /// Serializes this Cart to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Cart&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.discountCode, discountCode) || other.discountCode == discountCode)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(items),discountCode,createdAt);

@override
String toString() {
  return 'Cart(id: $id, items: $items, discountCode: $discountCode, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $CartCopyWith<$Res>  {
  factory $CartCopyWith(Cart value, $Res Function(Cart) _then) = _$CartCopyWithImpl;
@useResult
$Res call({
 String id, List<CartItem> items,@JsonKey(name: 'discount_code') DiscountCode? discountCode,@JsonKey(name: 'created_at') String createdAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? items = null,Object? discountCode = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<CartItem>,discountCode: freezed == discountCode ? _self.discountCode : discountCode // ignore: cast_nullable_to_non_nullable
as DiscountCode?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  List<CartItem> items, @JsonKey(name: 'discount_code')  DiscountCode? discountCode, @JsonKey(name: 'created_at')  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Cart() when $default != null:
return $default(_that.id,_that.items,_that.discountCode,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  List<CartItem> items, @JsonKey(name: 'discount_code')  DiscountCode? discountCode, @JsonKey(name: 'created_at')  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _Cart():
return $default(_that.id,_that.items,_that.discountCode,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  List<CartItem> items, @JsonKey(name: 'discount_code')  DiscountCode? discountCode, @JsonKey(name: 'created_at')  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Cart() when $default != null:
return $default(_that.id,_that.items,_that.discountCode,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Cart implements Cart {
  const _Cart({required this.id, required final  List<CartItem> items, @JsonKey(name: 'discount_code') this.discountCode, @JsonKey(name: 'created_at') required this.createdAt}): _items = items;
  factory _Cart.fromJson(Map<String, dynamic> json) => _$CartFromJson(json);

@override final  String id;
 final  List<CartItem> _items;
@override List<CartItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey(name: 'discount_code') final  DiscountCode? discountCode;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Cart&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.discountCode, discountCode) || other.discountCode == discountCode)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_items),discountCode,createdAt);

@override
String toString() {
  return 'Cart(id: $id, items: $items, discountCode: $discountCode, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$CartCopyWith<$Res> implements $CartCopyWith<$Res> {
  factory _$CartCopyWith(_Cart value, $Res Function(_Cart) _then) = __$CartCopyWithImpl;
@override @useResult
$Res call({
 String id, List<CartItem> items,@JsonKey(name: 'discount_code') DiscountCode? discountCode,@JsonKey(name: 'created_at') String createdAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? items = null,Object? discountCode = freezed,Object? createdAt = null,}) {
  return _then(_Cart(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CartItem>,discountCode: freezed == discountCode ? _self.discountCode : discountCode // ignore: cast_nullable_to_non_nullable
as DiscountCode?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
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

 String get code;@JsonKey(name: 'discount_pct') int get discountPct;@JsonKey(name: 'discount_artifacts') Map<String, int>? get discountArtifacts;
/// Create a copy of DiscountCode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiscountCodeCopyWith<DiscountCode> get copyWith => _$DiscountCodeCopyWithImpl<DiscountCode>(this as DiscountCode, _$identity);

  /// Serializes this DiscountCode to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiscountCode&&(identical(other.code, code) || other.code == code)&&(identical(other.discountPct, discountPct) || other.discountPct == discountPct)&&const DeepCollectionEquality().equals(other.discountArtifacts, discountArtifacts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,discountPct,const DeepCollectionEquality().hash(discountArtifacts));

@override
String toString() {
  return 'DiscountCode(code: $code, discountPct: $discountPct, discountArtifacts: $discountArtifacts)';
}


}

/// @nodoc
abstract mixin class $DiscountCodeCopyWith<$Res>  {
  factory $DiscountCodeCopyWith(DiscountCode value, $Res Function(DiscountCode) _then) = _$DiscountCodeCopyWithImpl;
@useResult
$Res call({
 String code,@JsonKey(name: 'discount_pct') int discountPct,@JsonKey(name: 'discount_artifacts') Map<String, int>? discountArtifacts
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
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? discountPct = null,Object? discountArtifacts = freezed,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,discountPct: null == discountPct ? _self.discountPct : discountPct // ignore: cast_nullable_to_non_nullable
as int,discountArtifacts: freezed == discountArtifacts ? _self.discountArtifacts : discountArtifacts // ignore: cast_nullable_to_non_nullable
as Map<String, int>?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code, @JsonKey(name: 'discount_pct')  int discountPct, @JsonKey(name: 'discount_artifacts')  Map<String, int>? discountArtifacts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DiscountCode() when $default != null:
return $default(_that.code,_that.discountPct,_that.discountArtifacts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code, @JsonKey(name: 'discount_pct')  int discountPct, @JsonKey(name: 'discount_artifacts')  Map<String, int>? discountArtifacts)  $default,) {final _that = this;
switch (_that) {
case _DiscountCode():
return $default(_that.code,_that.discountPct,_that.discountArtifacts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code, @JsonKey(name: 'discount_pct')  int discountPct, @JsonKey(name: 'discount_artifacts')  Map<String, int>? discountArtifacts)?  $default,) {final _that = this;
switch (_that) {
case _DiscountCode() when $default != null:
return $default(_that.code,_that.discountPct,_that.discountArtifacts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DiscountCode implements DiscountCode {
  const _DiscountCode({required this.code, @JsonKey(name: 'discount_pct') this.discountPct = 0, @JsonKey(name: 'discount_artifacts') final  Map<String, int>? discountArtifacts}): _discountArtifacts = discountArtifacts;
  factory _DiscountCode.fromJson(Map<String, dynamic> json) => _$DiscountCodeFromJson(json);

@override final  String code;
@override@JsonKey(name: 'discount_pct') final  int discountPct;
 final  Map<String, int>? _discountArtifacts;
@override@JsonKey(name: 'discount_artifacts') Map<String, int>? get discountArtifacts {
  final value = _discountArtifacts;
  if (value == null) return null;
  if (_discountArtifacts is EqualUnmodifiableMapView) return _discountArtifacts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DiscountCode&&(identical(other.code, code) || other.code == code)&&(identical(other.discountPct, discountPct) || other.discountPct == discountPct)&&const DeepCollectionEquality().equals(other._discountArtifacts, _discountArtifacts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,discountPct,const DeepCollectionEquality().hash(_discountArtifacts));

@override
String toString() {
  return 'DiscountCode(code: $code, discountPct: $discountPct, discountArtifacts: $discountArtifacts)';
}


}

/// @nodoc
abstract mixin class _$DiscountCodeCopyWith<$Res> implements $DiscountCodeCopyWith<$Res> {
  factory _$DiscountCodeCopyWith(_DiscountCode value, $Res Function(_DiscountCode) _then) = __$DiscountCodeCopyWithImpl;
@override @useResult
$Res call({
 String code,@JsonKey(name: 'discount_pct') int discountPct,@JsonKey(name: 'discount_artifacts') Map<String, int>? discountArtifacts
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
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? discountPct = null,Object? discountArtifacts = freezed,}) {
  return _then(_DiscountCode(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,discountPct: null == discountPct ? _self.discountPct : discountPct // ignore: cast_nullable_to_non_nullable
as int,discountArtifacts: freezed == discountArtifacts ? _self._discountArtifacts : discountArtifacts // ignore: cast_nullable_to_non_nullable
as Map<String, int>?,
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

@JsonKey(name: 'meal_plans') List<MealPlan> get mealPlans; List<TrainingProgramme> get programmes; List<MarketplaceEvent> get events;
/// Create a copy of CreatorServices
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreatorServicesCopyWith<CreatorServices> get copyWith => _$CreatorServicesCopyWithImpl<CreatorServices>(this as CreatorServices, _$identity);

  /// Serializes this CreatorServices to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreatorServices&&const DeepCollectionEquality().equals(other.mealPlans, mealPlans)&&const DeepCollectionEquality().equals(other.programmes, programmes)&&const DeepCollectionEquality().equals(other.events, events));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(mealPlans),const DeepCollectionEquality().hash(programmes),const DeepCollectionEquality().hash(events));

@override
String toString() {
  return 'CreatorServices(mealPlans: $mealPlans, programmes: $programmes, events: $events)';
}


}

/// @nodoc
abstract mixin class $CreatorServicesCopyWith<$Res>  {
  factory $CreatorServicesCopyWith(CreatorServices value, $Res Function(CreatorServices) _then) = _$CreatorServicesCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'meal_plans') List<MealPlan> mealPlans, List<TrainingProgramme> programmes, List<MarketplaceEvent> events
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
@pragma('vm:prefer-inline') @override $Res call({Object? mealPlans = null,Object? programmes = null,Object? events = null,}) {
  return _then(_self.copyWith(
mealPlans: null == mealPlans ? _self.mealPlans : mealPlans // ignore: cast_nullable_to_non_nullable
as List<MealPlan>,programmes: null == programmes ? _self.programmes : programmes // ignore: cast_nullable_to_non_nullable
as List<TrainingProgramme>,events: null == events ? _self.events : events // ignore: cast_nullable_to_non_nullable
as List<MarketplaceEvent>,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'meal_plans')  List<MealPlan> mealPlans,  List<TrainingProgramme> programmes,  List<MarketplaceEvent> events)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreatorServices() when $default != null:
return $default(_that.mealPlans,_that.programmes,_that.events);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'meal_plans')  List<MealPlan> mealPlans,  List<TrainingProgramme> programmes,  List<MarketplaceEvent> events)  $default,) {final _that = this;
switch (_that) {
case _CreatorServices():
return $default(_that.mealPlans,_that.programmes,_that.events);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'meal_plans')  List<MealPlan> mealPlans,  List<TrainingProgramme> programmes,  List<MarketplaceEvent> events)?  $default,) {final _that = this;
switch (_that) {
case _CreatorServices() when $default != null:
return $default(_that.mealPlans,_that.programmes,_that.events);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreatorServices implements CreatorServices {
  const _CreatorServices({@JsonKey(name: 'meal_plans') final  List<MealPlan> mealPlans = const <MealPlan>[], final  List<TrainingProgramme> programmes = const <TrainingProgramme>[], final  List<MarketplaceEvent> events = const <MarketplaceEvent>[]}): _mealPlans = mealPlans,_programmes = programmes,_events = events;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreatorServices&&const DeepCollectionEquality().equals(other._mealPlans, _mealPlans)&&const DeepCollectionEquality().equals(other._programmes, _programmes)&&const DeepCollectionEquality().equals(other._events, _events));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_mealPlans),const DeepCollectionEquality().hash(_programmes),const DeepCollectionEquality().hash(_events));

@override
String toString() {
  return 'CreatorServices(mealPlans: $mealPlans, programmes: $programmes, events: $events)';
}


}

/// @nodoc
abstract mixin class _$CreatorServicesCopyWith<$Res> implements $CreatorServicesCopyWith<$Res> {
  factory _$CreatorServicesCopyWith(_CreatorServices value, $Res Function(_CreatorServices) _then) = __$CreatorServicesCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'meal_plans') List<MealPlan> mealPlans, List<TrainingProgramme> programmes, List<MarketplaceEvent> events
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
@override @pragma('vm:prefer-inline') $Res call({Object? mealPlans = null,Object? programmes = null,Object? events = null,}) {
  return _then(_CreatorServices(
mealPlans: null == mealPlans ? _self._mealPlans : mealPlans // ignore: cast_nullable_to_non_nullable
as List<MealPlan>,programmes: null == programmes ? _self._programmes : programmes // ignore: cast_nullable_to_non_nullable
as List<TrainingProgramme>,events: null == events ? _self._events : events // ignore: cast_nullable_to_non_nullable
as List<MarketplaceEvent>,
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

// dart format on
