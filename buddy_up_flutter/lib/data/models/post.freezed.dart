// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuthorData {

 String? get userId; String get username; String get displayName; String get avatarUrl; String get verificationStatus;
/// Create a copy of AuthorData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthorDataCopyWith<AuthorData> get copyWith => _$AuthorDataCopyWithImpl<AuthorData>(this as AuthorData, _$identity);

  /// Serializes this AuthorData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthorData&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username,displayName,avatarUrl,verificationStatus);

@override
String toString() {
  return 'AuthorData(userId: $userId, username: $username, displayName: $displayName, avatarUrl: $avatarUrl, verificationStatus: $verificationStatus)';
}


}

/// @nodoc
abstract mixin class $AuthorDataCopyWith<$Res>  {
  factory $AuthorDataCopyWith(AuthorData value, $Res Function(AuthorData) _then) = _$AuthorDataCopyWithImpl;
@useResult
$Res call({
 String? userId, String username, String displayName, String avatarUrl, String verificationStatus
});




}
/// @nodoc
class _$AuthorDataCopyWithImpl<$Res>
    implements $AuthorDataCopyWith<$Res> {
  _$AuthorDataCopyWithImpl(this._self, this._then);

  final AuthorData _self;
  final $Res Function(AuthorData) _then;

/// Create a copy of AuthorData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = freezed,Object? username = null,Object? displayName = null,Object? avatarUrl = null,Object? verificationStatus = null,}) {
  return _then(_self.copyWith(
userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthorData].
extension AuthorDataPatterns on AuthorData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthorData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthorData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthorData value)  $default,){
final _that = this;
switch (_that) {
case _AuthorData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthorData value)?  $default,){
final _that = this;
switch (_that) {
case _AuthorData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? userId,  String username,  String displayName,  String avatarUrl,  String verificationStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthorData() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? userId,  String username,  String displayName,  String avatarUrl,  String verificationStatus)  $default,) {final _that = this;
switch (_that) {
case _AuthorData():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? userId,  String username,  String displayName,  String avatarUrl,  String verificationStatus)?  $default,) {final _that = this;
switch (_that) {
case _AuthorData() when $default != null:
return $default(_that.userId,_that.username,_that.displayName,_that.avatarUrl,_that.verificationStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthorData implements AuthorData {
  const _AuthorData({this.userId, required this.username, required this.displayName, required this.avatarUrl, this.verificationStatus = 'none'});
  factory _AuthorData.fromJson(Map<String, dynamic> json) => _$AuthorDataFromJson(json);

@override final  String? userId;
@override final  String username;
@override final  String displayName;
@override final  String avatarUrl;
@override@JsonKey() final  String verificationStatus;

/// Create a copy of AuthorData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthorDataCopyWith<_AuthorData> get copyWith => __$AuthorDataCopyWithImpl<_AuthorData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthorDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthorData&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username,displayName,avatarUrl,verificationStatus);

@override
String toString() {
  return 'AuthorData(userId: $userId, username: $username, displayName: $displayName, avatarUrl: $avatarUrl, verificationStatus: $verificationStatus)';
}


}

/// @nodoc
abstract mixin class _$AuthorDataCopyWith<$Res> implements $AuthorDataCopyWith<$Res> {
  factory _$AuthorDataCopyWith(_AuthorData value, $Res Function(_AuthorData) _then) = __$AuthorDataCopyWithImpl;
@override @useResult
$Res call({
 String? userId, String username, String displayName, String avatarUrl, String verificationStatus
});




}
/// @nodoc
class __$AuthorDataCopyWithImpl<$Res>
    implements _$AuthorDataCopyWith<$Res> {
  __$AuthorDataCopyWithImpl(this._self, this._then);

  final _AuthorData _self;
  final $Res Function(_AuthorData) _then;

/// Create a copy of AuthorData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = freezed,Object? username = null,Object? displayName = null,Object? avatarUrl = null,Object? verificationStatus = null,}) {
  return _then(_AuthorData(
userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PollOption {

 String get id; String get text; int get order; int get voteCount; bool get userVoted;
/// Create a copy of PollOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PollOptionCopyWith<PollOption> get copyWith => _$PollOptionCopyWithImpl<PollOption>(this as PollOption, _$identity);

  /// Serializes this PollOption to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PollOption&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&(identical(other.order, order) || other.order == order)&&(identical(other.voteCount, voteCount) || other.voteCount == voteCount)&&(identical(other.userVoted, userVoted) || other.userVoted == userVoted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,text,order,voteCount,userVoted);

@override
String toString() {
  return 'PollOption(id: $id, text: $text, order: $order, voteCount: $voteCount, userVoted: $userVoted)';
}


}

/// @nodoc
abstract mixin class $PollOptionCopyWith<$Res>  {
  factory $PollOptionCopyWith(PollOption value, $Res Function(PollOption) _then) = _$PollOptionCopyWithImpl;
@useResult
$Res call({
 String id, String text, int order, int voteCount, bool userVoted
});




}
/// @nodoc
class _$PollOptionCopyWithImpl<$Res>
    implements $PollOptionCopyWith<$Res> {
  _$PollOptionCopyWithImpl(this._self, this._then);

  final PollOption _self;
  final $Res Function(PollOption) _then;

/// Create a copy of PollOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? text = null,Object? order = null,Object? voteCount = null,Object? userVoted = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,voteCount: null == voteCount ? _self.voteCount : voteCount // ignore: cast_nullable_to_non_nullable
as int,userVoted: null == userVoted ? _self.userVoted : userVoted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PollOption].
extension PollOptionPatterns on PollOption {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PollOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PollOption() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PollOption value)  $default,){
final _that = this;
switch (_that) {
case _PollOption():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PollOption value)?  $default,){
final _that = this;
switch (_that) {
case _PollOption() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String text,  int order,  int voteCount,  bool userVoted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PollOption() when $default != null:
return $default(_that.id,_that.text,_that.order,_that.voteCount,_that.userVoted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String text,  int order,  int voteCount,  bool userVoted)  $default,) {final _that = this;
switch (_that) {
case _PollOption():
return $default(_that.id,_that.text,_that.order,_that.voteCount,_that.userVoted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String text,  int order,  int voteCount,  bool userVoted)?  $default,) {final _that = this;
switch (_that) {
case _PollOption() when $default != null:
return $default(_that.id,_that.text,_that.order,_that.voteCount,_that.userVoted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PollOption implements PollOption {
  const _PollOption({required this.id, required this.text, this.order = 0, this.voteCount = 0, this.userVoted = false});
  factory _PollOption.fromJson(Map<String, dynamic> json) => _$PollOptionFromJson(json);

@override final  String id;
@override final  String text;
@override@JsonKey() final  int order;
@override@JsonKey() final  int voteCount;
@override@JsonKey() final  bool userVoted;

/// Create a copy of PollOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PollOptionCopyWith<_PollOption> get copyWith => __$PollOptionCopyWithImpl<_PollOption>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PollOptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PollOption&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&(identical(other.order, order) || other.order == order)&&(identical(other.voteCount, voteCount) || other.voteCount == voteCount)&&(identical(other.userVoted, userVoted) || other.userVoted == userVoted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,text,order,voteCount,userVoted);

@override
String toString() {
  return 'PollOption(id: $id, text: $text, order: $order, voteCount: $voteCount, userVoted: $userVoted)';
}


}

/// @nodoc
abstract mixin class _$PollOptionCopyWith<$Res> implements $PollOptionCopyWith<$Res> {
  factory _$PollOptionCopyWith(_PollOption value, $Res Function(_PollOption) _then) = __$PollOptionCopyWithImpl;
@override @useResult
$Res call({
 String id, String text, int order, int voteCount, bool userVoted
});




}
/// @nodoc
class __$PollOptionCopyWithImpl<$Res>
    implements _$PollOptionCopyWith<$Res> {
  __$PollOptionCopyWithImpl(this._self, this._then);

  final _PollOption _self;
  final $Res Function(_PollOption) _then;

/// Create a copy of PollOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? text = null,Object? order = null,Object? voteCount = null,Object? userVoted = null,}) {
  return _then(_PollOption(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,voteCount: null == voteCount ? _self.voteCount : voteCount // ignore: cast_nullable_to_non_nullable
as int,userVoted: null == userVoted ? _self.userVoted : userVoted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$Poll {

 String get id; String get question; String? get closesAt; bool get allowMultiple; int get totalVotes; bool get isClosed; List<PollOption> get options; List<String> get userVotedOptionIds;
/// Create a copy of Poll
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PollCopyWith<Poll> get copyWith => _$PollCopyWithImpl<Poll>(this as Poll, _$identity);

  /// Serializes this Poll to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Poll&&(identical(other.id, id) || other.id == id)&&(identical(other.question, question) || other.question == question)&&(identical(other.closesAt, closesAt) || other.closesAt == closesAt)&&(identical(other.allowMultiple, allowMultiple) || other.allowMultiple == allowMultiple)&&(identical(other.totalVotes, totalVotes) || other.totalVotes == totalVotes)&&(identical(other.isClosed, isClosed) || other.isClosed == isClosed)&&const DeepCollectionEquality().equals(other.options, options)&&const DeepCollectionEquality().equals(other.userVotedOptionIds, userVotedOptionIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,question,closesAt,allowMultiple,totalVotes,isClosed,const DeepCollectionEquality().hash(options),const DeepCollectionEquality().hash(userVotedOptionIds));

@override
String toString() {
  return 'Poll(id: $id, question: $question, closesAt: $closesAt, allowMultiple: $allowMultiple, totalVotes: $totalVotes, isClosed: $isClosed, options: $options, userVotedOptionIds: $userVotedOptionIds)';
}


}

/// @nodoc
abstract mixin class $PollCopyWith<$Res>  {
  factory $PollCopyWith(Poll value, $Res Function(Poll) _then) = _$PollCopyWithImpl;
@useResult
$Res call({
 String id, String question, String? closesAt, bool allowMultiple, int totalVotes, bool isClosed, List<PollOption> options, List<String> userVotedOptionIds
});




}
/// @nodoc
class _$PollCopyWithImpl<$Res>
    implements $PollCopyWith<$Res> {
  _$PollCopyWithImpl(this._self, this._then);

  final Poll _self;
  final $Res Function(Poll) _then;

/// Create a copy of Poll
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? question = null,Object? closesAt = freezed,Object? allowMultiple = null,Object? totalVotes = null,Object? isClosed = null,Object? options = null,Object? userVotedOptionIds = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,closesAt: freezed == closesAt ? _self.closesAt : closesAt // ignore: cast_nullable_to_non_nullable
as String?,allowMultiple: null == allowMultiple ? _self.allowMultiple : allowMultiple // ignore: cast_nullable_to_non_nullable
as bool,totalVotes: null == totalVotes ? _self.totalVotes : totalVotes // ignore: cast_nullable_to_non_nullable
as int,isClosed: null == isClosed ? _self.isClosed : isClosed // ignore: cast_nullable_to_non_nullable
as bool,options: null == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as List<PollOption>,userVotedOptionIds: null == userVotedOptionIds ? _self.userVotedOptionIds : userVotedOptionIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [Poll].
extension PollPatterns on Poll {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Poll value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Poll() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Poll value)  $default,){
final _that = this;
switch (_that) {
case _Poll():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Poll value)?  $default,){
final _that = this;
switch (_that) {
case _Poll() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String question,  String? closesAt,  bool allowMultiple,  int totalVotes,  bool isClosed,  List<PollOption> options,  List<String> userVotedOptionIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Poll() when $default != null:
return $default(_that.id,_that.question,_that.closesAt,_that.allowMultiple,_that.totalVotes,_that.isClosed,_that.options,_that.userVotedOptionIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String question,  String? closesAt,  bool allowMultiple,  int totalVotes,  bool isClosed,  List<PollOption> options,  List<String> userVotedOptionIds)  $default,) {final _that = this;
switch (_that) {
case _Poll():
return $default(_that.id,_that.question,_that.closesAt,_that.allowMultiple,_that.totalVotes,_that.isClosed,_that.options,_that.userVotedOptionIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String question,  String? closesAt,  bool allowMultiple,  int totalVotes,  bool isClosed,  List<PollOption> options,  List<String> userVotedOptionIds)?  $default,) {final _that = this;
switch (_that) {
case _Poll() when $default != null:
return $default(_that.id,_that.question,_that.closesAt,_that.allowMultiple,_that.totalVotes,_that.isClosed,_that.options,_that.userVotedOptionIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Poll implements Poll {
  const _Poll({required this.id, required this.question, this.closesAt, this.allowMultiple = false, this.totalVotes = 0, this.isClosed = false, required final  List<PollOption> options, final  List<String> userVotedOptionIds = const <String>[]}): _options = options,_userVotedOptionIds = userVotedOptionIds;
  factory _Poll.fromJson(Map<String, dynamic> json) => _$PollFromJson(json);

@override final  String id;
@override final  String question;
@override final  String? closesAt;
@override@JsonKey() final  bool allowMultiple;
@override@JsonKey() final  int totalVotes;
@override@JsonKey() final  bool isClosed;
 final  List<PollOption> _options;
@override List<PollOption> get options {
  if (_options is EqualUnmodifiableListView) return _options;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_options);
}

 final  List<String> _userVotedOptionIds;
@override@JsonKey() List<String> get userVotedOptionIds {
  if (_userVotedOptionIds is EqualUnmodifiableListView) return _userVotedOptionIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_userVotedOptionIds);
}


/// Create a copy of Poll
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PollCopyWith<_Poll> get copyWith => __$PollCopyWithImpl<_Poll>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PollToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Poll&&(identical(other.id, id) || other.id == id)&&(identical(other.question, question) || other.question == question)&&(identical(other.closesAt, closesAt) || other.closesAt == closesAt)&&(identical(other.allowMultiple, allowMultiple) || other.allowMultiple == allowMultiple)&&(identical(other.totalVotes, totalVotes) || other.totalVotes == totalVotes)&&(identical(other.isClosed, isClosed) || other.isClosed == isClosed)&&const DeepCollectionEquality().equals(other._options, _options)&&const DeepCollectionEquality().equals(other._userVotedOptionIds, _userVotedOptionIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,question,closesAt,allowMultiple,totalVotes,isClosed,const DeepCollectionEquality().hash(_options),const DeepCollectionEquality().hash(_userVotedOptionIds));

@override
String toString() {
  return 'Poll(id: $id, question: $question, closesAt: $closesAt, allowMultiple: $allowMultiple, totalVotes: $totalVotes, isClosed: $isClosed, options: $options, userVotedOptionIds: $userVotedOptionIds)';
}


}

/// @nodoc
abstract mixin class _$PollCopyWith<$Res> implements $PollCopyWith<$Res> {
  factory _$PollCopyWith(_Poll value, $Res Function(_Poll) _then) = __$PollCopyWithImpl;
@override @useResult
$Res call({
 String id, String question, String? closesAt, bool allowMultiple, int totalVotes, bool isClosed, List<PollOption> options, List<String> userVotedOptionIds
});




}
/// @nodoc
class __$PollCopyWithImpl<$Res>
    implements _$PollCopyWith<$Res> {
  __$PollCopyWithImpl(this._self, this._then);

  final _Poll _self;
  final $Res Function(_Poll) _then;

/// Create a copy of Poll
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? question = null,Object? closesAt = freezed,Object? allowMultiple = null,Object? totalVotes = null,Object? isClosed = null,Object? options = null,Object? userVotedOptionIds = null,}) {
  return _then(_Poll(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,closesAt: freezed == closesAt ? _self.closesAt : closesAt // ignore: cast_nullable_to_non_nullable
as String?,allowMultiple: null == allowMultiple ? _self.allowMultiple : allowMultiple // ignore: cast_nullable_to_non_nullable
as bool,totalVotes: null == totalVotes ? _self.totalVotes : totalVotes // ignore: cast_nullable_to_non_nullable
as int,isClosed: null == isClosed ? _self.isClosed : isClosed // ignore: cast_nullable_to_non_nullable
as bool,options: null == options ? _self._options : options // ignore: cast_nullable_to_non_nullable
as List<PollOption>,userVotedOptionIds: null == userVotedOptionIds ? _self._userVotedOptionIds : userVotedOptionIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$OriginalPostData {

 String get id; AuthorData get authorData; String get body; List<String> get mediaUrls; String get postType; String? get locationLabel; Map<String, dynamic>? get workoutLogData; Map<String, dynamic>? get mealData; Map<String, dynamic>? get progressData; Poll? get poll; int get commentCount; String? get gymTagName; String get createdAt;
/// Create a copy of OriginalPostData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OriginalPostDataCopyWith<OriginalPostData> get copyWith => _$OriginalPostDataCopyWithImpl<OriginalPostData>(this as OriginalPostData, _$identity);

  /// Serializes this OriginalPostData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OriginalPostData&&(identical(other.id, id) || other.id == id)&&(identical(other.authorData, authorData) || other.authorData == authorData)&&(identical(other.body, body) || other.body == body)&&const DeepCollectionEquality().equals(other.mediaUrls, mediaUrls)&&(identical(other.postType, postType) || other.postType == postType)&&(identical(other.locationLabel, locationLabel) || other.locationLabel == locationLabel)&&const DeepCollectionEquality().equals(other.workoutLogData, workoutLogData)&&const DeepCollectionEquality().equals(other.mealData, mealData)&&const DeepCollectionEquality().equals(other.progressData, progressData)&&(identical(other.poll, poll) || other.poll == poll)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.gymTagName, gymTagName) || other.gymTagName == gymTagName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,authorData,body,const DeepCollectionEquality().hash(mediaUrls),postType,locationLabel,const DeepCollectionEquality().hash(workoutLogData),const DeepCollectionEquality().hash(mealData),const DeepCollectionEquality().hash(progressData),poll,commentCount,gymTagName,createdAt);

@override
String toString() {
  return 'OriginalPostData(id: $id, authorData: $authorData, body: $body, mediaUrls: $mediaUrls, postType: $postType, locationLabel: $locationLabel, workoutLogData: $workoutLogData, mealData: $mealData, progressData: $progressData, poll: $poll, commentCount: $commentCount, gymTagName: $gymTagName, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $OriginalPostDataCopyWith<$Res>  {
  factory $OriginalPostDataCopyWith(OriginalPostData value, $Res Function(OriginalPostData) _then) = _$OriginalPostDataCopyWithImpl;
@useResult
$Res call({
 String id, AuthorData authorData, String body, List<String> mediaUrls, String postType, String? locationLabel, Map<String, dynamic>? workoutLogData, Map<String, dynamic>? mealData, Map<String, dynamic>? progressData, Poll? poll, int commentCount, String? gymTagName, String createdAt
});


$AuthorDataCopyWith<$Res> get authorData;$PollCopyWith<$Res>? get poll;

}
/// @nodoc
class _$OriginalPostDataCopyWithImpl<$Res>
    implements $OriginalPostDataCopyWith<$Res> {
  _$OriginalPostDataCopyWithImpl(this._self, this._then);

  final OriginalPostData _self;
  final $Res Function(OriginalPostData) _then;

/// Create a copy of OriginalPostData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? authorData = null,Object? body = null,Object? mediaUrls = null,Object? postType = null,Object? locationLabel = freezed,Object? workoutLogData = freezed,Object? mealData = freezed,Object? progressData = freezed,Object? poll = freezed,Object? commentCount = null,Object? gymTagName = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,authorData: null == authorData ? _self.authorData : authorData // ignore: cast_nullable_to_non_nullable
as AuthorData,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,mediaUrls: null == mediaUrls ? _self.mediaUrls : mediaUrls // ignore: cast_nullable_to_non_nullable
as List<String>,postType: null == postType ? _self.postType : postType // ignore: cast_nullable_to_non_nullable
as String,locationLabel: freezed == locationLabel ? _self.locationLabel : locationLabel // ignore: cast_nullable_to_non_nullable
as String?,workoutLogData: freezed == workoutLogData ? _self.workoutLogData : workoutLogData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,mealData: freezed == mealData ? _self.mealData : mealData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,progressData: freezed == progressData ? _self.progressData : progressData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,poll: freezed == poll ? _self.poll : poll // ignore: cast_nullable_to_non_nullable
as Poll?,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,gymTagName: freezed == gymTagName ? _self.gymTagName : gymTagName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of OriginalPostData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthorDataCopyWith<$Res> get authorData {
  
  return $AuthorDataCopyWith<$Res>(_self.authorData, (value) {
    return _then(_self.copyWith(authorData: value));
  });
}/// Create a copy of OriginalPostData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PollCopyWith<$Res>? get poll {
    if (_self.poll == null) {
    return null;
  }

  return $PollCopyWith<$Res>(_self.poll!, (value) {
    return _then(_self.copyWith(poll: value));
  });
}
}


/// Adds pattern-matching-related methods to [OriginalPostData].
extension OriginalPostDataPatterns on OriginalPostData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OriginalPostData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OriginalPostData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OriginalPostData value)  $default,){
final _that = this;
switch (_that) {
case _OriginalPostData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OriginalPostData value)?  $default,){
final _that = this;
switch (_that) {
case _OriginalPostData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  AuthorData authorData,  String body,  List<String> mediaUrls,  String postType,  String? locationLabel,  Map<String, dynamic>? workoutLogData,  Map<String, dynamic>? mealData,  Map<String, dynamic>? progressData,  Poll? poll,  int commentCount,  String? gymTagName,  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OriginalPostData() when $default != null:
return $default(_that.id,_that.authorData,_that.body,_that.mediaUrls,_that.postType,_that.locationLabel,_that.workoutLogData,_that.mealData,_that.progressData,_that.poll,_that.commentCount,_that.gymTagName,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  AuthorData authorData,  String body,  List<String> mediaUrls,  String postType,  String? locationLabel,  Map<String, dynamic>? workoutLogData,  Map<String, dynamic>? mealData,  Map<String, dynamic>? progressData,  Poll? poll,  int commentCount,  String? gymTagName,  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _OriginalPostData():
return $default(_that.id,_that.authorData,_that.body,_that.mediaUrls,_that.postType,_that.locationLabel,_that.workoutLogData,_that.mealData,_that.progressData,_that.poll,_that.commentCount,_that.gymTagName,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  AuthorData authorData,  String body,  List<String> mediaUrls,  String postType,  String? locationLabel,  Map<String, dynamic>? workoutLogData,  Map<String, dynamic>? mealData,  Map<String, dynamic>? progressData,  Poll? poll,  int commentCount,  String? gymTagName,  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _OriginalPostData() when $default != null:
return $default(_that.id,_that.authorData,_that.body,_that.mediaUrls,_that.postType,_that.locationLabel,_that.workoutLogData,_that.mealData,_that.progressData,_that.poll,_that.commentCount,_that.gymTagName,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OriginalPostData implements OriginalPostData {
  const _OriginalPostData({required this.id, required this.authorData, required this.body, final  List<String> mediaUrls = const <String>[], this.postType = 'text', this.locationLabel, final  Map<String, dynamic>? workoutLogData, final  Map<String, dynamic>? mealData, final  Map<String, dynamic>? progressData, this.poll, this.commentCount = 0, this.gymTagName, required this.createdAt}): _mediaUrls = mediaUrls,_workoutLogData = workoutLogData,_mealData = mealData,_progressData = progressData;
  factory _OriginalPostData.fromJson(Map<String, dynamic> json) => _$OriginalPostDataFromJson(json);

@override final  String id;
@override final  AuthorData authorData;
@override final  String body;
 final  List<String> _mediaUrls;
@override@JsonKey() List<String> get mediaUrls {
  if (_mediaUrls is EqualUnmodifiableListView) return _mediaUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mediaUrls);
}

@override@JsonKey() final  String postType;
@override final  String? locationLabel;
 final  Map<String, dynamic>? _workoutLogData;
@override Map<String, dynamic>? get workoutLogData {
  final value = _workoutLogData;
  if (value == null) return null;
  if (_workoutLogData is EqualUnmodifiableMapView) return _workoutLogData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _mealData;
@override Map<String, dynamic>? get mealData {
  final value = _mealData;
  if (value == null) return null;
  if (_mealData is EqualUnmodifiableMapView) return _mealData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _progressData;
@override Map<String, dynamic>? get progressData {
  final value = _progressData;
  if (value == null) return null;
  if (_progressData is EqualUnmodifiableMapView) return _progressData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  Poll? poll;
@override@JsonKey() final  int commentCount;
@override final  String? gymTagName;
@override final  String createdAt;

/// Create a copy of OriginalPostData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OriginalPostDataCopyWith<_OriginalPostData> get copyWith => __$OriginalPostDataCopyWithImpl<_OriginalPostData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OriginalPostDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OriginalPostData&&(identical(other.id, id) || other.id == id)&&(identical(other.authorData, authorData) || other.authorData == authorData)&&(identical(other.body, body) || other.body == body)&&const DeepCollectionEquality().equals(other._mediaUrls, _mediaUrls)&&(identical(other.postType, postType) || other.postType == postType)&&(identical(other.locationLabel, locationLabel) || other.locationLabel == locationLabel)&&const DeepCollectionEquality().equals(other._workoutLogData, _workoutLogData)&&const DeepCollectionEquality().equals(other._mealData, _mealData)&&const DeepCollectionEquality().equals(other._progressData, _progressData)&&(identical(other.poll, poll) || other.poll == poll)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.gymTagName, gymTagName) || other.gymTagName == gymTagName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,authorData,body,const DeepCollectionEquality().hash(_mediaUrls),postType,locationLabel,const DeepCollectionEquality().hash(_workoutLogData),const DeepCollectionEquality().hash(_mealData),const DeepCollectionEquality().hash(_progressData),poll,commentCount,gymTagName,createdAt);

@override
String toString() {
  return 'OriginalPostData(id: $id, authorData: $authorData, body: $body, mediaUrls: $mediaUrls, postType: $postType, locationLabel: $locationLabel, workoutLogData: $workoutLogData, mealData: $mealData, progressData: $progressData, poll: $poll, commentCount: $commentCount, gymTagName: $gymTagName, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$OriginalPostDataCopyWith<$Res> implements $OriginalPostDataCopyWith<$Res> {
  factory _$OriginalPostDataCopyWith(_OriginalPostData value, $Res Function(_OriginalPostData) _then) = __$OriginalPostDataCopyWithImpl;
@override @useResult
$Res call({
 String id, AuthorData authorData, String body, List<String> mediaUrls, String postType, String? locationLabel, Map<String, dynamic>? workoutLogData, Map<String, dynamic>? mealData, Map<String, dynamic>? progressData, Poll? poll, int commentCount, String? gymTagName, String createdAt
});


@override $AuthorDataCopyWith<$Res> get authorData;@override $PollCopyWith<$Res>? get poll;

}
/// @nodoc
class __$OriginalPostDataCopyWithImpl<$Res>
    implements _$OriginalPostDataCopyWith<$Res> {
  __$OriginalPostDataCopyWithImpl(this._self, this._then);

  final _OriginalPostData _self;
  final $Res Function(_OriginalPostData) _then;

/// Create a copy of OriginalPostData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? authorData = null,Object? body = null,Object? mediaUrls = null,Object? postType = null,Object? locationLabel = freezed,Object? workoutLogData = freezed,Object? mealData = freezed,Object? progressData = freezed,Object? poll = freezed,Object? commentCount = null,Object? gymTagName = freezed,Object? createdAt = null,}) {
  return _then(_OriginalPostData(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,authorData: null == authorData ? _self.authorData : authorData // ignore: cast_nullable_to_non_nullable
as AuthorData,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,mediaUrls: null == mediaUrls ? _self._mediaUrls : mediaUrls // ignore: cast_nullable_to_non_nullable
as List<String>,postType: null == postType ? _self.postType : postType // ignore: cast_nullable_to_non_nullable
as String,locationLabel: freezed == locationLabel ? _self.locationLabel : locationLabel // ignore: cast_nullable_to_non_nullable
as String?,workoutLogData: freezed == workoutLogData ? _self._workoutLogData : workoutLogData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,mealData: freezed == mealData ? _self._mealData : mealData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,progressData: freezed == progressData ? _self._progressData : progressData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,poll: freezed == poll ? _self.poll : poll // ignore: cast_nullable_to_non_nullable
as Poll?,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,gymTagName: freezed == gymTagName ? _self.gymTagName : gymTagName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of OriginalPostData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthorDataCopyWith<$Res> get authorData {
  
  return $AuthorDataCopyWith<$Res>(_self.authorData, (value) {
    return _then(_self.copyWith(authorData: value));
  });
}/// Create a copy of OriginalPostData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PollCopyWith<$Res>? get poll {
    if (_self.poll == null) {
    return null;
  }

  return $PollCopyWith<$Res>(_self.poll!, (value) {
    return _then(_self.copyWith(poll: value));
  });
}
}


/// @nodoc
mixin _$Post {

 String get id; AuthorData get authorData; String get postType; String get body; bool get isAnonymous; List<String> get mediaUrls; List<String> get tags; Map<String, dynamic>? get workoutLogData; Map<String, dynamic>? get mealData; Map<String, dynamic>? get progressData; String get locationLabel; int get viewCount; Map<String, int> get reactionCounts; String? get userReaction; int get commentCount; int get repostCount; bool get isRepost; String? get originalPostId; String get quoteBody; bool get isSaved; bool get isPinned; String get visibility; String get moderationStatus;@JsonKey(readValue: _readAiAnalysis) Map<String, dynamic>? get aiAnalysis; String? get gymTagId; String? get gymTagName; Poll? get poll; OriginalPostData? get originalPostData; String get createdAt; String? get updatedAt;
/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostCopyWith<Post> get copyWith => _$PostCopyWithImpl<Post>(this as Post, _$identity);

  /// Serializes this Post to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Post&&(identical(other.id, id) || other.id == id)&&(identical(other.authorData, authorData) || other.authorData == authorData)&&(identical(other.postType, postType) || other.postType == postType)&&(identical(other.body, body) || other.body == body)&&(identical(other.isAnonymous, isAnonymous) || other.isAnonymous == isAnonymous)&&const DeepCollectionEquality().equals(other.mediaUrls, mediaUrls)&&const DeepCollectionEquality().equals(other.tags, tags)&&const DeepCollectionEquality().equals(other.workoutLogData, workoutLogData)&&const DeepCollectionEquality().equals(other.mealData, mealData)&&const DeepCollectionEquality().equals(other.progressData, progressData)&&(identical(other.locationLabel, locationLabel) || other.locationLabel == locationLabel)&&(identical(other.viewCount, viewCount) || other.viewCount == viewCount)&&const DeepCollectionEquality().equals(other.reactionCounts, reactionCounts)&&(identical(other.userReaction, userReaction) || other.userReaction == userReaction)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.repostCount, repostCount) || other.repostCount == repostCount)&&(identical(other.isRepost, isRepost) || other.isRepost == isRepost)&&(identical(other.originalPostId, originalPostId) || other.originalPostId == originalPostId)&&(identical(other.quoteBody, quoteBody) || other.quoteBody == quoteBody)&&(identical(other.isSaved, isSaved) || other.isSaved == isSaved)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.moderationStatus, moderationStatus) || other.moderationStatus == moderationStatus)&&const DeepCollectionEquality().equals(other.aiAnalysis, aiAnalysis)&&(identical(other.gymTagId, gymTagId) || other.gymTagId == gymTagId)&&(identical(other.gymTagName, gymTagName) || other.gymTagName == gymTagName)&&(identical(other.poll, poll) || other.poll == poll)&&(identical(other.originalPostData, originalPostData) || other.originalPostData == originalPostData)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,authorData,postType,body,isAnonymous,const DeepCollectionEquality().hash(mediaUrls),const DeepCollectionEquality().hash(tags),const DeepCollectionEquality().hash(workoutLogData),const DeepCollectionEquality().hash(mealData),const DeepCollectionEquality().hash(progressData),locationLabel,viewCount,const DeepCollectionEquality().hash(reactionCounts),userReaction,commentCount,repostCount,isRepost,originalPostId,quoteBody,isSaved,isPinned,visibility,moderationStatus,const DeepCollectionEquality().hash(aiAnalysis),gymTagId,gymTagName,poll,originalPostData,createdAt,updatedAt]);

@override
String toString() {
  return 'Post(id: $id, authorData: $authorData, postType: $postType, body: $body, isAnonymous: $isAnonymous, mediaUrls: $mediaUrls, tags: $tags, workoutLogData: $workoutLogData, mealData: $mealData, progressData: $progressData, locationLabel: $locationLabel, viewCount: $viewCount, reactionCounts: $reactionCounts, userReaction: $userReaction, commentCount: $commentCount, repostCount: $repostCount, isRepost: $isRepost, originalPostId: $originalPostId, quoteBody: $quoteBody, isSaved: $isSaved, isPinned: $isPinned, visibility: $visibility, moderationStatus: $moderationStatus, aiAnalysis: $aiAnalysis, gymTagId: $gymTagId, gymTagName: $gymTagName, poll: $poll, originalPostData: $originalPostData, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PostCopyWith<$Res>  {
  factory $PostCopyWith(Post value, $Res Function(Post) _then) = _$PostCopyWithImpl;
@useResult
$Res call({
 String id, AuthorData authorData, String postType, String body, bool isAnonymous, List<String> mediaUrls, List<String> tags, Map<String, dynamic>? workoutLogData, Map<String, dynamic>? mealData, Map<String, dynamic>? progressData, String locationLabel, int viewCount, Map<String, int> reactionCounts, String? userReaction, int commentCount, int repostCount, bool isRepost, String? originalPostId, String quoteBody, bool isSaved, bool isPinned, String visibility, String moderationStatus,@JsonKey(readValue: _readAiAnalysis) Map<String, dynamic>? aiAnalysis, String? gymTagId, String? gymTagName, Poll? poll, OriginalPostData? originalPostData, String createdAt, String? updatedAt
});


$AuthorDataCopyWith<$Res> get authorData;$PollCopyWith<$Res>? get poll;$OriginalPostDataCopyWith<$Res>? get originalPostData;

}
/// @nodoc
class _$PostCopyWithImpl<$Res>
    implements $PostCopyWith<$Res> {
  _$PostCopyWithImpl(this._self, this._then);

  final Post _self;
  final $Res Function(Post) _then;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? authorData = null,Object? postType = null,Object? body = null,Object? isAnonymous = null,Object? mediaUrls = null,Object? tags = null,Object? workoutLogData = freezed,Object? mealData = freezed,Object? progressData = freezed,Object? locationLabel = null,Object? viewCount = null,Object? reactionCounts = null,Object? userReaction = freezed,Object? commentCount = null,Object? repostCount = null,Object? isRepost = null,Object? originalPostId = freezed,Object? quoteBody = null,Object? isSaved = null,Object? isPinned = null,Object? visibility = null,Object? moderationStatus = null,Object? aiAnalysis = freezed,Object? gymTagId = freezed,Object? gymTagName = freezed,Object? poll = freezed,Object? originalPostData = freezed,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,authorData: null == authorData ? _self.authorData : authorData // ignore: cast_nullable_to_non_nullable
as AuthorData,postType: null == postType ? _self.postType : postType // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,isAnonymous: null == isAnonymous ? _self.isAnonymous : isAnonymous // ignore: cast_nullable_to_non_nullable
as bool,mediaUrls: null == mediaUrls ? _self.mediaUrls : mediaUrls // ignore: cast_nullable_to_non_nullable
as List<String>,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,workoutLogData: freezed == workoutLogData ? _self.workoutLogData : workoutLogData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,mealData: freezed == mealData ? _self.mealData : mealData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,progressData: freezed == progressData ? _self.progressData : progressData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,locationLabel: null == locationLabel ? _self.locationLabel : locationLabel // ignore: cast_nullable_to_non_nullable
as String,viewCount: null == viewCount ? _self.viewCount : viewCount // ignore: cast_nullable_to_non_nullable
as int,reactionCounts: null == reactionCounts ? _self.reactionCounts : reactionCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,userReaction: freezed == userReaction ? _self.userReaction : userReaction // ignore: cast_nullable_to_non_nullable
as String?,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,repostCount: null == repostCount ? _self.repostCount : repostCount // ignore: cast_nullable_to_non_nullable
as int,isRepost: null == isRepost ? _self.isRepost : isRepost // ignore: cast_nullable_to_non_nullable
as bool,originalPostId: freezed == originalPostId ? _self.originalPostId : originalPostId // ignore: cast_nullable_to_non_nullable
as String?,quoteBody: null == quoteBody ? _self.quoteBody : quoteBody // ignore: cast_nullable_to_non_nullable
as String,isSaved: null == isSaved ? _self.isSaved : isSaved // ignore: cast_nullable_to_non_nullable
as bool,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as String,moderationStatus: null == moderationStatus ? _self.moderationStatus : moderationStatus // ignore: cast_nullable_to_non_nullable
as String,aiAnalysis: freezed == aiAnalysis ? _self.aiAnalysis : aiAnalysis // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,gymTagId: freezed == gymTagId ? _self.gymTagId : gymTagId // ignore: cast_nullable_to_non_nullable
as String?,gymTagName: freezed == gymTagName ? _self.gymTagName : gymTagName // ignore: cast_nullable_to_non_nullable
as String?,poll: freezed == poll ? _self.poll : poll // ignore: cast_nullable_to_non_nullable
as Poll?,originalPostData: freezed == originalPostData ? _self.originalPostData : originalPostData // ignore: cast_nullable_to_non_nullable
as OriginalPostData?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthorDataCopyWith<$Res> get authorData {
  
  return $AuthorDataCopyWith<$Res>(_self.authorData, (value) {
    return _then(_self.copyWith(authorData: value));
  });
}/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PollCopyWith<$Res>? get poll {
    if (_self.poll == null) {
    return null;
  }

  return $PollCopyWith<$Res>(_self.poll!, (value) {
    return _then(_self.copyWith(poll: value));
  });
}/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OriginalPostDataCopyWith<$Res>? get originalPostData {
    if (_self.originalPostData == null) {
    return null;
  }

  return $OriginalPostDataCopyWith<$Res>(_self.originalPostData!, (value) {
    return _then(_self.copyWith(originalPostData: value));
  });
}
}


/// Adds pattern-matching-related methods to [Post].
extension PostPatterns on Post {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Post value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Post() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Post value)  $default,){
final _that = this;
switch (_that) {
case _Post():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Post value)?  $default,){
final _that = this;
switch (_that) {
case _Post() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  AuthorData authorData,  String postType,  String body,  bool isAnonymous,  List<String> mediaUrls,  List<String> tags,  Map<String, dynamic>? workoutLogData,  Map<String, dynamic>? mealData,  Map<String, dynamic>? progressData,  String locationLabel,  int viewCount,  Map<String, int> reactionCounts,  String? userReaction,  int commentCount,  int repostCount,  bool isRepost,  String? originalPostId,  String quoteBody,  bool isSaved,  bool isPinned,  String visibility,  String moderationStatus, @JsonKey(readValue: _readAiAnalysis)  Map<String, dynamic>? aiAnalysis,  String? gymTagId,  String? gymTagName,  Poll? poll,  OriginalPostData? originalPostData,  String createdAt,  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Post() when $default != null:
return $default(_that.id,_that.authorData,_that.postType,_that.body,_that.isAnonymous,_that.mediaUrls,_that.tags,_that.workoutLogData,_that.mealData,_that.progressData,_that.locationLabel,_that.viewCount,_that.reactionCounts,_that.userReaction,_that.commentCount,_that.repostCount,_that.isRepost,_that.originalPostId,_that.quoteBody,_that.isSaved,_that.isPinned,_that.visibility,_that.moderationStatus,_that.aiAnalysis,_that.gymTagId,_that.gymTagName,_that.poll,_that.originalPostData,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  AuthorData authorData,  String postType,  String body,  bool isAnonymous,  List<String> mediaUrls,  List<String> tags,  Map<String, dynamic>? workoutLogData,  Map<String, dynamic>? mealData,  Map<String, dynamic>? progressData,  String locationLabel,  int viewCount,  Map<String, int> reactionCounts,  String? userReaction,  int commentCount,  int repostCount,  bool isRepost,  String? originalPostId,  String quoteBody,  bool isSaved,  bool isPinned,  String visibility,  String moderationStatus, @JsonKey(readValue: _readAiAnalysis)  Map<String, dynamic>? aiAnalysis,  String? gymTagId,  String? gymTagName,  Poll? poll,  OriginalPostData? originalPostData,  String createdAt,  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Post():
return $default(_that.id,_that.authorData,_that.postType,_that.body,_that.isAnonymous,_that.mediaUrls,_that.tags,_that.workoutLogData,_that.mealData,_that.progressData,_that.locationLabel,_that.viewCount,_that.reactionCounts,_that.userReaction,_that.commentCount,_that.repostCount,_that.isRepost,_that.originalPostId,_that.quoteBody,_that.isSaved,_that.isPinned,_that.visibility,_that.moderationStatus,_that.aiAnalysis,_that.gymTagId,_that.gymTagName,_that.poll,_that.originalPostData,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  AuthorData authorData,  String postType,  String body,  bool isAnonymous,  List<String> mediaUrls,  List<String> tags,  Map<String, dynamic>? workoutLogData,  Map<String, dynamic>? mealData,  Map<String, dynamic>? progressData,  String locationLabel,  int viewCount,  Map<String, int> reactionCounts,  String? userReaction,  int commentCount,  int repostCount,  bool isRepost,  String? originalPostId,  String quoteBody,  bool isSaved,  bool isPinned,  String visibility,  String moderationStatus, @JsonKey(readValue: _readAiAnalysis)  Map<String, dynamic>? aiAnalysis,  String? gymTagId,  String? gymTagName,  Poll? poll,  OriginalPostData? originalPostData,  String createdAt,  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Post() when $default != null:
return $default(_that.id,_that.authorData,_that.postType,_that.body,_that.isAnonymous,_that.mediaUrls,_that.tags,_that.workoutLogData,_that.mealData,_that.progressData,_that.locationLabel,_that.viewCount,_that.reactionCounts,_that.userReaction,_that.commentCount,_that.repostCount,_that.isRepost,_that.originalPostId,_that.quoteBody,_that.isSaved,_that.isPinned,_that.visibility,_that.moderationStatus,_that.aiAnalysis,_that.gymTagId,_that.gymTagName,_that.poll,_that.originalPostData,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Post implements Post {
  const _Post({required this.id, required this.authorData, this.postType = 'text', this.body = '', this.isAnonymous = false, final  List<String> mediaUrls = const <String>[], final  List<String> tags = const <String>[], final  Map<String, dynamic>? workoutLogData, final  Map<String, dynamic>? mealData, final  Map<String, dynamic>? progressData, this.locationLabel = '', this.viewCount = 0, final  Map<String, int> reactionCounts = const <String, int>{}, this.userReaction, this.commentCount = 0, this.repostCount = 0, this.isRepost = false, this.originalPostId, this.quoteBody = '', this.isSaved = false, this.isPinned = false, this.visibility = 'public', this.moderationStatus = 'clean', @JsonKey(readValue: _readAiAnalysis) final  Map<String, dynamic>? aiAnalysis, this.gymTagId, this.gymTagName, this.poll, this.originalPostData, required this.createdAt, this.updatedAt}): _mediaUrls = mediaUrls,_tags = tags,_workoutLogData = workoutLogData,_mealData = mealData,_progressData = progressData,_reactionCounts = reactionCounts,_aiAnalysis = aiAnalysis;
  factory _Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);

@override final  String id;
@override final  AuthorData authorData;
@override@JsonKey() final  String postType;
@override@JsonKey() final  String body;
@override@JsonKey() final  bool isAnonymous;
 final  List<String> _mediaUrls;
@override@JsonKey() List<String> get mediaUrls {
  if (_mediaUrls is EqualUnmodifiableListView) return _mediaUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mediaUrls);
}

 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

 final  Map<String, dynamic>? _workoutLogData;
@override Map<String, dynamic>? get workoutLogData {
  final value = _workoutLogData;
  if (value == null) return null;
  if (_workoutLogData is EqualUnmodifiableMapView) return _workoutLogData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _mealData;
@override Map<String, dynamic>? get mealData {
  final value = _mealData;
  if (value == null) return null;
  if (_mealData is EqualUnmodifiableMapView) return _mealData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _progressData;
@override Map<String, dynamic>? get progressData {
  final value = _progressData;
  if (value == null) return null;
  if (_progressData is EqualUnmodifiableMapView) return _progressData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey() final  String locationLabel;
@override@JsonKey() final  int viewCount;
 final  Map<String, int> _reactionCounts;
@override@JsonKey() Map<String, int> get reactionCounts {
  if (_reactionCounts is EqualUnmodifiableMapView) return _reactionCounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_reactionCounts);
}

@override final  String? userReaction;
@override@JsonKey() final  int commentCount;
@override@JsonKey() final  int repostCount;
@override@JsonKey() final  bool isRepost;
@override final  String? originalPostId;
@override@JsonKey() final  String quoteBody;
@override@JsonKey() final  bool isSaved;
@override@JsonKey() final  bool isPinned;
@override@JsonKey() final  String visibility;
@override@JsonKey() final  String moderationStatus;
 final  Map<String, dynamic>? _aiAnalysis;
@override@JsonKey(readValue: _readAiAnalysis) Map<String, dynamic>? get aiAnalysis {
  final value = _aiAnalysis;
  if (value == null) return null;
  if (_aiAnalysis is EqualUnmodifiableMapView) return _aiAnalysis;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? gymTagId;
@override final  String? gymTagName;
@override final  Poll? poll;
@override final  OriginalPostData? originalPostData;
@override final  String createdAt;
@override final  String? updatedAt;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostCopyWith<_Post> get copyWith => __$PostCopyWithImpl<_Post>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Post&&(identical(other.id, id) || other.id == id)&&(identical(other.authorData, authorData) || other.authorData == authorData)&&(identical(other.postType, postType) || other.postType == postType)&&(identical(other.body, body) || other.body == body)&&(identical(other.isAnonymous, isAnonymous) || other.isAnonymous == isAnonymous)&&const DeepCollectionEquality().equals(other._mediaUrls, _mediaUrls)&&const DeepCollectionEquality().equals(other._tags, _tags)&&const DeepCollectionEquality().equals(other._workoutLogData, _workoutLogData)&&const DeepCollectionEquality().equals(other._mealData, _mealData)&&const DeepCollectionEquality().equals(other._progressData, _progressData)&&(identical(other.locationLabel, locationLabel) || other.locationLabel == locationLabel)&&(identical(other.viewCount, viewCount) || other.viewCount == viewCount)&&const DeepCollectionEquality().equals(other._reactionCounts, _reactionCounts)&&(identical(other.userReaction, userReaction) || other.userReaction == userReaction)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.repostCount, repostCount) || other.repostCount == repostCount)&&(identical(other.isRepost, isRepost) || other.isRepost == isRepost)&&(identical(other.originalPostId, originalPostId) || other.originalPostId == originalPostId)&&(identical(other.quoteBody, quoteBody) || other.quoteBody == quoteBody)&&(identical(other.isSaved, isSaved) || other.isSaved == isSaved)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.moderationStatus, moderationStatus) || other.moderationStatus == moderationStatus)&&const DeepCollectionEquality().equals(other._aiAnalysis, _aiAnalysis)&&(identical(other.gymTagId, gymTagId) || other.gymTagId == gymTagId)&&(identical(other.gymTagName, gymTagName) || other.gymTagName == gymTagName)&&(identical(other.poll, poll) || other.poll == poll)&&(identical(other.originalPostData, originalPostData) || other.originalPostData == originalPostData)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,authorData,postType,body,isAnonymous,const DeepCollectionEquality().hash(_mediaUrls),const DeepCollectionEquality().hash(_tags),const DeepCollectionEquality().hash(_workoutLogData),const DeepCollectionEquality().hash(_mealData),const DeepCollectionEquality().hash(_progressData),locationLabel,viewCount,const DeepCollectionEquality().hash(_reactionCounts),userReaction,commentCount,repostCount,isRepost,originalPostId,quoteBody,isSaved,isPinned,visibility,moderationStatus,const DeepCollectionEquality().hash(_aiAnalysis),gymTagId,gymTagName,poll,originalPostData,createdAt,updatedAt]);

@override
String toString() {
  return 'Post(id: $id, authorData: $authorData, postType: $postType, body: $body, isAnonymous: $isAnonymous, mediaUrls: $mediaUrls, tags: $tags, workoutLogData: $workoutLogData, mealData: $mealData, progressData: $progressData, locationLabel: $locationLabel, viewCount: $viewCount, reactionCounts: $reactionCounts, userReaction: $userReaction, commentCount: $commentCount, repostCount: $repostCount, isRepost: $isRepost, originalPostId: $originalPostId, quoteBody: $quoteBody, isSaved: $isSaved, isPinned: $isPinned, visibility: $visibility, moderationStatus: $moderationStatus, aiAnalysis: $aiAnalysis, gymTagId: $gymTagId, gymTagName: $gymTagName, poll: $poll, originalPostData: $originalPostData, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PostCopyWith<$Res> implements $PostCopyWith<$Res> {
  factory _$PostCopyWith(_Post value, $Res Function(_Post) _then) = __$PostCopyWithImpl;
@override @useResult
$Res call({
 String id, AuthorData authorData, String postType, String body, bool isAnonymous, List<String> mediaUrls, List<String> tags, Map<String, dynamic>? workoutLogData, Map<String, dynamic>? mealData, Map<String, dynamic>? progressData, String locationLabel, int viewCount, Map<String, int> reactionCounts, String? userReaction, int commentCount, int repostCount, bool isRepost, String? originalPostId, String quoteBody, bool isSaved, bool isPinned, String visibility, String moderationStatus,@JsonKey(readValue: _readAiAnalysis) Map<String, dynamic>? aiAnalysis, String? gymTagId, String? gymTagName, Poll? poll, OriginalPostData? originalPostData, String createdAt, String? updatedAt
});


@override $AuthorDataCopyWith<$Res> get authorData;@override $PollCopyWith<$Res>? get poll;@override $OriginalPostDataCopyWith<$Res>? get originalPostData;

}
/// @nodoc
class __$PostCopyWithImpl<$Res>
    implements _$PostCopyWith<$Res> {
  __$PostCopyWithImpl(this._self, this._then);

  final _Post _self;
  final $Res Function(_Post) _then;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? authorData = null,Object? postType = null,Object? body = null,Object? isAnonymous = null,Object? mediaUrls = null,Object? tags = null,Object? workoutLogData = freezed,Object? mealData = freezed,Object? progressData = freezed,Object? locationLabel = null,Object? viewCount = null,Object? reactionCounts = null,Object? userReaction = freezed,Object? commentCount = null,Object? repostCount = null,Object? isRepost = null,Object? originalPostId = freezed,Object? quoteBody = null,Object? isSaved = null,Object? isPinned = null,Object? visibility = null,Object? moderationStatus = null,Object? aiAnalysis = freezed,Object? gymTagId = freezed,Object? gymTagName = freezed,Object? poll = freezed,Object? originalPostData = freezed,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_Post(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,authorData: null == authorData ? _self.authorData : authorData // ignore: cast_nullable_to_non_nullable
as AuthorData,postType: null == postType ? _self.postType : postType // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,isAnonymous: null == isAnonymous ? _self.isAnonymous : isAnonymous // ignore: cast_nullable_to_non_nullable
as bool,mediaUrls: null == mediaUrls ? _self._mediaUrls : mediaUrls // ignore: cast_nullable_to_non_nullable
as List<String>,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,workoutLogData: freezed == workoutLogData ? _self._workoutLogData : workoutLogData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,mealData: freezed == mealData ? _self._mealData : mealData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,progressData: freezed == progressData ? _self._progressData : progressData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,locationLabel: null == locationLabel ? _self.locationLabel : locationLabel // ignore: cast_nullable_to_non_nullable
as String,viewCount: null == viewCount ? _self.viewCount : viewCount // ignore: cast_nullable_to_non_nullable
as int,reactionCounts: null == reactionCounts ? _self._reactionCounts : reactionCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,userReaction: freezed == userReaction ? _self.userReaction : userReaction // ignore: cast_nullable_to_non_nullable
as String?,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,repostCount: null == repostCount ? _self.repostCount : repostCount // ignore: cast_nullable_to_non_nullable
as int,isRepost: null == isRepost ? _self.isRepost : isRepost // ignore: cast_nullable_to_non_nullable
as bool,originalPostId: freezed == originalPostId ? _self.originalPostId : originalPostId // ignore: cast_nullable_to_non_nullable
as String?,quoteBody: null == quoteBody ? _self.quoteBody : quoteBody // ignore: cast_nullable_to_non_nullable
as String,isSaved: null == isSaved ? _self.isSaved : isSaved // ignore: cast_nullable_to_non_nullable
as bool,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as String,moderationStatus: null == moderationStatus ? _self.moderationStatus : moderationStatus // ignore: cast_nullable_to_non_nullable
as String,aiAnalysis: freezed == aiAnalysis ? _self._aiAnalysis : aiAnalysis // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,gymTagId: freezed == gymTagId ? _self.gymTagId : gymTagId // ignore: cast_nullable_to_non_nullable
as String?,gymTagName: freezed == gymTagName ? _self.gymTagName : gymTagName // ignore: cast_nullable_to_non_nullable
as String?,poll: freezed == poll ? _self.poll : poll // ignore: cast_nullable_to_non_nullable
as Poll?,originalPostData: freezed == originalPostData ? _self.originalPostData : originalPostData // ignore: cast_nullable_to_non_nullable
as OriginalPostData?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthorDataCopyWith<$Res> get authorData {
  
  return $AuthorDataCopyWith<$Res>(_self.authorData, (value) {
    return _then(_self.copyWith(authorData: value));
  });
}/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PollCopyWith<$Res>? get poll {
    if (_self.poll == null) {
    return null;
  }

  return $PollCopyWith<$Res>(_self.poll!, (value) {
    return _then(_self.copyWith(poll: value));
  });
}/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OriginalPostDataCopyWith<$Res>? get originalPostData {
    if (_self.originalPostData == null) {
    return null;
  }

  return $OriginalPostDataCopyWith<$Res>(_self.originalPostData!, (value) {
    return _then(_self.copyWith(originalPostData: value));
  });
}
}


/// @nodoc
mixin _$Comment {

 String get id; String get postId; AuthorData get authorData; String get body; String? get parentId; bool get isAnonymous; int get replyCount; Map<String, int> get reactionCounts; String? get userReaction; String get createdAt; String? get updatedAt;
/// Create a copy of Comment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommentCopyWith<Comment> get copyWith => _$CommentCopyWithImpl<Comment>(this as Comment, _$identity);

  /// Serializes this Comment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Comment&&(identical(other.id, id) || other.id == id)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.authorData, authorData) || other.authorData == authorData)&&(identical(other.body, body) || other.body == body)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.isAnonymous, isAnonymous) || other.isAnonymous == isAnonymous)&&(identical(other.replyCount, replyCount) || other.replyCount == replyCount)&&const DeepCollectionEquality().equals(other.reactionCounts, reactionCounts)&&(identical(other.userReaction, userReaction) || other.userReaction == userReaction)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,postId,authorData,body,parentId,isAnonymous,replyCount,const DeepCollectionEquality().hash(reactionCounts),userReaction,createdAt,updatedAt);

@override
String toString() {
  return 'Comment(id: $id, postId: $postId, authorData: $authorData, body: $body, parentId: $parentId, isAnonymous: $isAnonymous, replyCount: $replyCount, reactionCounts: $reactionCounts, userReaction: $userReaction, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CommentCopyWith<$Res>  {
  factory $CommentCopyWith(Comment value, $Res Function(Comment) _then) = _$CommentCopyWithImpl;
@useResult
$Res call({
 String id, String postId, AuthorData authorData, String body, String? parentId, bool isAnonymous, int replyCount, Map<String, int> reactionCounts, String? userReaction, String createdAt, String? updatedAt
});


$AuthorDataCopyWith<$Res> get authorData;

}
/// @nodoc
class _$CommentCopyWithImpl<$Res>
    implements $CommentCopyWith<$Res> {
  _$CommentCopyWithImpl(this._self, this._then);

  final Comment _self;
  final $Res Function(Comment) _then;

/// Create a copy of Comment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? postId = null,Object? authorData = null,Object? body = null,Object? parentId = freezed,Object? isAnonymous = null,Object? replyCount = null,Object? reactionCounts = null,Object? userReaction = freezed,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,authorData: null == authorData ? _self.authorData : authorData // ignore: cast_nullable_to_non_nullable
as AuthorData,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,isAnonymous: null == isAnonymous ? _self.isAnonymous : isAnonymous // ignore: cast_nullable_to_non_nullable
as bool,replyCount: null == replyCount ? _self.replyCount : replyCount // ignore: cast_nullable_to_non_nullable
as int,reactionCounts: null == reactionCounts ? _self.reactionCounts : reactionCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,userReaction: freezed == userReaction ? _self.userReaction : userReaction // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Comment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthorDataCopyWith<$Res> get authorData {
  
  return $AuthorDataCopyWith<$Res>(_self.authorData, (value) {
    return _then(_self.copyWith(authorData: value));
  });
}
}


/// Adds pattern-matching-related methods to [Comment].
extension CommentPatterns on Comment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Comment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Comment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Comment value)  $default,){
final _that = this;
switch (_that) {
case _Comment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Comment value)?  $default,){
final _that = this;
switch (_that) {
case _Comment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String postId,  AuthorData authorData,  String body,  String? parentId,  bool isAnonymous,  int replyCount,  Map<String, int> reactionCounts,  String? userReaction,  String createdAt,  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Comment() when $default != null:
return $default(_that.id,_that.postId,_that.authorData,_that.body,_that.parentId,_that.isAnonymous,_that.replyCount,_that.reactionCounts,_that.userReaction,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String postId,  AuthorData authorData,  String body,  String? parentId,  bool isAnonymous,  int replyCount,  Map<String, int> reactionCounts,  String? userReaction,  String createdAt,  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Comment():
return $default(_that.id,_that.postId,_that.authorData,_that.body,_that.parentId,_that.isAnonymous,_that.replyCount,_that.reactionCounts,_that.userReaction,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String postId,  AuthorData authorData,  String body,  String? parentId,  bool isAnonymous,  int replyCount,  Map<String, int> reactionCounts,  String? userReaction,  String createdAt,  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Comment() when $default != null:
return $default(_that.id,_that.postId,_that.authorData,_that.body,_that.parentId,_that.isAnonymous,_that.replyCount,_that.reactionCounts,_that.userReaction,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Comment implements Comment {
  const _Comment({required this.id, required this.postId, required this.authorData, required this.body, this.parentId, this.isAnonymous = false, this.replyCount = 0, final  Map<String, int> reactionCounts = const <String, int>{}, this.userReaction, required this.createdAt, this.updatedAt}): _reactionCounts = reactionCounts;
  factory _Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);

@override final  String id;
@override final  String postId;
@override final  AuthorData authorData;
@override final  String body;
@override final  String? parentId;
@override@JsonKey() final  bool isAnonymous;
@override@JsonKey() final  int replyCount;
 final  Map<String, int> _reactionCounts;
@override@JsonKey() Map<String, int> get reactionCounts {
  if (_reactionCounts is EqualUnmodifiableMapView) return _reactionCounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_reactionCounts);
}

@override final  String? userReaction;
@override final  String createdAt;
@override final  String? updatedAt;

/// Create a copy of Comment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommentCopyWith<_Comment> get copyWith => __$CommentCopyWithImpl<_Comment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CommentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Comment&&(identical(other.id, id) || other.id == id)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.authorData, authorData) || other.authorData == authorData)&&(identical(other.body, body) || other.body == body)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.isAnonymous, isAnonymous) || other.isAnonymous == isAnonymous)&&(identical(other.replyCount, replyCount) || other.replyCount == replyCount)&&const DeepCollectionEquality().equals(other._reactionCounts, _reactionCounts)&&(identical(other.userReaction, userReaction) || other.userReaction == userReaction)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,postId,authorData,body,parentId,isAnonymous,replyCount,const DeepCollectionEquality().hash(_reactionCounts),userReaction,createdAt,updatedAt);

@override
String toString() {
  return 'Comment(id: $id, postId: $postId, authorData: $authorData, body: $body, parentId: $parentId, isAnonymous: $isAnonymous, replyCount: $replyCount, reactionCounts: $reactionCounts, userReaction: $userReaction, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CommentCopyWith<$Res> implements $CommentCopyWith<$Res> {
  factory _$CommentCopyWith(_Comment value, $Res Function(_Comment) _then) = __$CommentCopyWithImpl;
@override @useResult
$Res call({
 String id, String postId, AuthorData authorData, String body, String? parentId, bool isAnonymous, int replyCount, Map<String, int> reactionCounts, String? userReaction, String createdAt, String? updatedAt
});


@override $AuthorDataCopyWith<$Res> get authorData;

}
/// @nodoc
class __$CommentCopyWithImpl<$Res>
    implements _$CommentCopyWith<$Res> {
  __$CommentCopyWithImpl(this._self, this._then);

  final _Comment _self;
  final $Res Function(_Comment) _then;

/// Create a copy of Comment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? postId = null,Object? authorData = null,Object? body = null,Object? parentId = freezed,Object? isAnonymous = null,Object? replyCount = null,Object? reactionCounts = null,Object? userReaction = freezed,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_Comment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,authorData: null == authorData ? _self.authorData : authorData // ignore: cast_nullable_to_non_nullable
as AuthorData,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,isAnonymous: null == isAnonymous ? _self.isAnonymous : isAnonymous // ignore: cast_nullable_to_non_nullable
as bool,replyCount: null == replyCount ? _self.replyCount : replyCount // ignore: cast_nullable_to_non_nullable
as int,reactionCounts: null == reactionCounts ? _self._reactionCounts : reactionCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,userReaction: freezed == userReaction ? _self.userReaction : userReaction // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Comment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthorDataCopyWith<$Res> get authorData {
  
  return $AuthorDataCopyWith<$Res>(_self.authorData, (value) {
    return _then(_self.copyWith(authorData: value));
  });
}
}


/// @nodoc
mixin _$FeedFilter {

 String get tab; String? get cursor;
/// Create a copy of FeedFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedFilterCopyWith<FeedFilter> get copyWith => _$FeedFilterCopyWithImpl<FeedFilter>(this as FeedFilter, _$identity);

  /// Serializes this FeedFilter to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedFilter&&(identical(other.tab, tab) || other.tab == tab)&&(identical(other.cursor, cursor) || other.cursor == cursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tab,cursor);

@override
String toString() {
  return 'FeedFilter(tab: $tab, cursor: $cursor)';
}


}

/// @nodoc
abstract mixin class $FeedFilterCopyWith<$Res>  {
  factory $FeedFilterCopyWith(FeedFilter value, $Res Function(FeedFilter) _then) = _$FeedFilterCopyWithImpl;
@useResult
$Res call({
 String tab, String? cursor
});




}
/// @nodoc
class _$FeedFilterCopyWithImpl<$Res>
    implements $FeedFilterCopyWith<$Res> {
  _$FeedFilterCopyWithImpl(this._self, this._then);

  final FeedFilter _self;
  final $Res Function(FeedFilter) _then;

/// Create a copy of FeedFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tab = null,Object? cursor = freezed,}) {
  return _then(_self.copyWith(
tab: null == tab ? _self.tab : tab // ignore: cast_nullable_to_non_nullable
as String,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FeedFilter].
extension FeedFilterPatterns on FeedFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeedFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeedFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeedFilter value)  $default,){
final _that = this;
switch (_that) {
case _FeedFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeedFilter value)?  $default,){
final _that = this;
switch (_that) {
case _FeedFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String tab,  String? cursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeedFilter() when $default != null:
return $default(_that.tab,_that.cursor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String tab,  String? cursor)  $default,) {final _that = this;
switch (_that) {
case _FeedFilter():
return $default(_that.tab,_that.cursor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String tab,  String? cursor)?  $default,) {final _that = this;
switch (_that) {
case _FeedFilter() when $default != null:
return $default(_that.tab,_that.cursor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FeedFilter implements FeedFilter {
  const _FeedFilter({this.tab = 'for_you', this.cursor});
  factory _FeedFilter.fromJson(Map<String, dynamic> json) => _$FeedFilterFromJson(json);

@override@JsonKey() final  String tab;
@override final  String? cursor;

/// Create a copy of FeedFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedFilterCopyWith<_FeedFilter> get copyWith => __$FeedFilterCopyWithImpl<_FeedFilter>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FeedFilterToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedFilter&&(identical(other.tab, tab) || other.tab == tab)&&(identical(other.cursor, cursor) || other.cursor == cursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tab,cursor);

@override
String toString() {
  return 'FeedFilter(tab: $tab, cursor: $cursor)';
}


}

/// @nodoc
abstract mixin class _$FeedFilterCopyWith<$Res> implements $FeedFilterCopyWith<$Res> {
  factory _$FeedFilterCopyWith(_FeedFilter value, $Res Function(_FeedFilter) _then) = __$FeedFilterCopyWithImpl;
@override @useResult
$Res call({
 String tab, String? cursor
});




}
/// @nodoc
class __$FeedFilterCopyWithImpl<$Res>
    implements _$FeedFilterCopyWith<$Res> {
  __$FeedFilterCopyWithImpl(this._self, this._then);

  final _FeedFilter _self;
  final $Res Function(_FeedFilter) _then;

/// Create a copy of FeedFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tab = null,Object? cursor = freezed,}) {
  return _then(_FeedFilter(
tab: null == tab ? _self.tab : tab // ignore: cast_nullable_to_non_nullable
as String,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CreatePostPayload {

 String get postType; String? get body; String get visibility; String? get gymTag; String? get locationLabel; List<String> get mediaUrls; List<String> get tags; bool get isAnonymous; String? get pollQuestion; List<String> get pollOptions; String? get pollClosesAt; bool get pollAllowMultiple; List<String> get mentionedUsers;
/// Create a copy of CreatePostPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreatePostPayloadCopyWith<CreatePostPayload> get copyWith => _$CreatePostPayloadCopyWithImpl<CreatePostPayload>(this as CreatePostPayload, _$identity);

  /// Serializes this CreatePostPayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreatePostPayload&&(identical(other.postType, postType) || other.postType == postType)&&(identical(other.body, body) || other.body == body)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.gymTag, gymTag) || other.gymTag == gymTag)&&(identical(other.locationLabel, locationLabel) || other.locationLabel == locationLabel)&&const DeepCollectionEquality().equals(other.mediaUrls, mediaUrls)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.isAnonymous, isAnonymous) || other.isAnonymous == isAnonymous)&&(identical(other.pollQuestion, pollQuestion) || other.pollQuestion == pollQuestion)&&const DeepCollectionEquality().equals(other.pollOptions, pollOptions)&&(identical(other.pollClosesAt, pollClosesAt) || other.pollClosesAt == pollClosesAt)&&(identical(other.pollAllowMultiple, pollAllowMultiple) || other.pollAllowMultiple == pollAllowMultiple)&&const DeepCollectionEquality().equals(other.mentionedUsers, mentionedUsers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,postType,body,visibility,gymTag,locationLabel,const DeepCollectionEquality().hash(mediaUrls),const DeepCollectionEquality().hash(tags),isAnonymous,pollQuestion,const DeepCollectionEquality().hash(pollOptions),pollClosesAt,pollAllowMultiple,const DeepCollectionEquality().hash(mentionedUsers));

@override
String toString() {
  return 'CreatePostPayload(postType: $postType, body: $body, visibility: $visibility, gymTag: $gymTag, locationLabel: $locationLabel, mediaUrls: $mediaUrls, tags: $tags, isAnonymous: $isAnonymous, pollQuestion: $pollQuestion, pollOptions: $pollOptions, pollClosesAt: $pollClosesAt, pollAllowMultiple: $pollAllowMultiple, mentionedUsers: $mentionedUsers)';
}


}

/// @nodoc
abstract mixin class $CreatePostPayloadCopyWith<$Res>  {
  factory $CreatePostPayloadCopyWith(CreatePostPayload value, $Res Function(CreatePostPayload) _then) = _$CreatePostPayloadCopyWithImpl;
@useResult
$Res call({
 String postType, String? body, String visibility, String? gymTag, String? locationLabel, List<String> mediaUrls, List<String> tags, bool isAnonymous, String? pollQuestion, List<String> pollOptions, String? pollClosesAt, bool pollAllowMultiple, List<String> mentionedUsers
});




}
/// @nodoc
class _$CreatePostPayloadCopyWithImpl<$Res>
    implements $CreatePostPayloadCopyWith<$Res> {
  _$CreatePostPayloadCopyWithImpl(this._self, this._then);

  final CreatePostPayload _self;
  final $Res Function(CreatePostPayload) _then;

/// Create a copy of CreatePostPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? postType = null,Object? body = freezed,Object? visibility = null,Object? gymTag = freezed,Object? locationLabel = freezed,Object? mediaUrls = null,Object? tags = null,Object? isAnonymous = null,Object? pollQuestion = freezed,Object? pollOptions = null,Object? pollClosesAt = freezed,Object? pollAllowMultiple = null,Object? mentionedUsers = null,}) {
  return _then(_self.copyWith(
postType: null == postType ? _self.postType : postType // ignore: cast_nullable_to_non_nullable
as String,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as String,gymTag: freezed == gymTag ? _self.gymTag : gymTag // ignore: cast_nullable_to_non_nullable
as String?,locationLabel: freezed == locationLabel ? _self.locationLabel : locationLabel // ignore: cast_nullable_to_non_nullable
as String?,mediaUrls: null == mediaUrls ? _self.mediaUrls : mediaUrls // ignore: cast_nullable_to_non_nullable
as List<String>,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,isAnonymous: null == isAnonymous ? _self.isAnonymous : isAnonymous // ignore: cast_nullable_to_non_nullable
as bool,pollQuestion: freezed == pollQuestion ? _self.pollQuestion : pollQuestion // ignore: cast_nullable_to_non_nullable
as String?,pollOptions: null == pollOptions ? _self.pollOptions : pollOptions // ignore: cast_nullable_to_non_nullable
as List<String>,pollClosesAt: freezed == pollClosesAt ? _self.pollClosesAt : pollClosesAt // ignore: cast_nullable_to_non_nullable
as String?,pollAllowMultiple: null == pollAllowMultiple ? _self.pollAllowMultiple : pollAllowMultiple // ignore: cast_nullable_to_non_nullable
as bool,mentionedUsers: null == mentionedUsers ? _self.mentionedUsers : mentionedUsers // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [CreatePostPayload].
extension CreatePostPayloadPatterns on CreatePostPayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreatePostPayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreatePostPayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreatePostPayload value)  $default,){
final _that = this;
switch (_that) {
case _CreatePostPayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreatePostPayload value)?  $default,){
final _that = this;
switch (_that) {
case _CreatePostPayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String postType,  String? body,  String visibility,  String? gymTag,  String? locationLabel,  List<String> mediaUrls,  List<String> tags,  bool isAnonymous,  String? pollQuestion,  List<String> pollOptions,  String? pollClosesAt,  bool pollAllowMultiple,  List<String> mentionedUsers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreatePostPayload() when $default != null:
return $default(_that.postType,_that.body,_that.visibility,_that.gymTag,_that.locationLabel,_that.mediaUrls,_that.tags,_that.isAnonymous,_that.pollQuestion,_that.pollOptions,_that.pollClosesAt,_that.pollAllowMultiple,_that.mentionedUsers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String postType,  String? body,  String visibility,  String? gymTag,  String? locationLabel,  List<String> mediaUrls,  List<String> tags,  bool isAnonymous,  String? pollQuestion,  List<String> pollOptions,  String? pollClosesAt,  bool pollAllowMultiple,  List<String> mentionedUsers)  $default,) {final _that = this;
switch (_that) {
case _CreatePostPayload():
return $default(_that.postType,_that.body,_that.visibility,_that.gymTag,_that.locationLabel,_that.mediaUrls,_that.tags,_that.isAnonymous,_that.pollQuestion,_that.pollOptions,_that.pollClosesAt,_that.pollAllowMultiple,_that.mentionedUsers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String postType,  String? body,  String visibility,  String? gymTag,  String? locationLabel,  List<String> mediaUrls,  List<String> tags,  bool isAnonymous,  String? pollQuestion,  List<String> pollOptions,  String? pollClosesAt,  bool pollAllowMultiple,  List<String> mentionedUsers)?  $default,) {final _that = this;
switch (_that) {
case _CreatePostPayload() when $default != null:
return $default(_that.postType,_that.body,_that.visibility,_that.gymTag,_that.locationLabel,_that.mediaUrls,_that.tags,_that.isAnonymous,_that.pollQuestion,_that.pollOptions,_that.pollClosesAt,_that.pollAllowMultiple,_that.mentionedUsers);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreatePostPayload implements CreatePostPayload {
  const _CreatePostPayload({required this.postType, this.body, this.visibility = 'public', this.gymTag, this.locationLabel, final  List<String> mediaUrls = const <String>[], final  List<String> tags = const <String>[], this.isAnonymous = false, this.pollQuestion, final  List<String> pollOptions = const <String>[], this.pollClosesAt, this.pollAllowMultiple = false, final  List<String> mentionedUsers = const <String>[]}): _mediaUrls = mediaUrls,_tags = tags,_pollOptions = pollOptions,_mentionedUsers = mentionedUsers;
  factory _CreatePostPayload.fromJson(Map<String, dynamic> json) => _$CreatePostPayloadFromJson(json);

@override final  String postType;
@override final  String? body;
@override@JsonKey() final  String visibility;
@override final  String? gymTag;
@override final  String? locationLabel;
 final  List<String> _mediaUrls;
@override@JsonKey() List<String> get mediaUrls {
  if (_mediaUrls is EqualUnmodifiableListView) return _mediaUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mediaUrls);
}

 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override@JsonKey() final  bool isAnonymous;
@override final  String? pollQuestion;
 final  List<String> _pollOptions;
@override@JsonKey() List<String> get pollOptions {
  if (_pollOptions is EqualUnmodifiableListView) return _pollOptions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pollOptions);
}

@override final  String? pollClosesAt;
@override@JsonKey() final  bool pollAllowMultiple;
 final  List<String> _mentionedUsers;
@override@JsonKey() List<String> get mentionedUsers {
  if (_mentionedUsers is EqualUnmodifiableListView) return _mentionedUsers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mentionedUsers);
}


/// Create a copy of CreatePostPayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreatePostPayloadCopyWith<_CreatePostPayload> get copyWith => __$CreatePostPayloadCopyWithImpl<_CreatePostPayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreatePostPayloadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreatePostPayload&&(identical(other.postType, postType) || other.postType == postType)&&(identical(other.body, body) || other.body == body)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.gymTag, gymTag) || other.gymTag == gymTag)&&(identical(other.locationLabel, locationLabel) || other.locationLabel == locationLabel)&&const DeepCollectionEquality().equals(other._mediaUrls, _mediaUrls)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.isAnonymous, isAnonymous) || other.isAnonymous == isAnonymous)&&(identical(other.pollQuestion, pollQuestion) || other.pollQuestion == pollQuestion)&&const DeepCollectionEquality().equals(other._pollOptions, _pollOptions)&&(identical(other.pollClosesAt, pollClosesAt) || other.pollClosesAt == pollClosesAt)&&(identical(other.pollAllowMultiple, pollAllowMultiple) || other.pollAllowMultiple == pollAllowMultiple)&&const DeepCollectionEquality().equals(other._mentionedUsers, _mentionedUsers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,postType,body,visibility,gymTag,locationLabel,const DeepCollectionEquality().hash(_mediaUrls),const DeepCollectionEquality().hash(_tags),isAnonymous,pollQuestion,const DeepCollectionEquality().hash(_pollOptions),pollClosesAt,pollAllowMultiple,const DeepCollectionEquality().hash(_mentionedUsers));

@override
String toString() {
  return 'CreatePostPayload(postType: $postType, body: $body, visibility: $visibility, gymTag: $gymTag, locationLabel: $locationLabel, mediaUrls: $mediaUrls, tags: $tags, isAnonymous: $isAnonymous, pollQuestion: $pollQuestion, pollOptions: $pollOptions, pollClosesAt: $pollClosesAt, pollAllowMultiple: $pollAllowMultiple, mentionedUsers: $mentionedUsers)';
}


}

/// @nodoc
abstract mixin class _$CreatePostPayloadCopyWith<$Res> implements $CreatePostPayloadCopyWith<$Res> {
  factory _$CreatePostPayloadCopyWith(_CreatePostPayload value, $Res Function(_CreatePostPayload) _then) = __$CreatePostPayloadCopyWithImpl;
@override @useResult
$Res call({
 String postType, String? body, String visibility, String? gymTag, String? locationLabel, List<String> mediaUrls, List<String> tags, bool isAnonymous, String? pollQuestion, List<String> pollOptions, String? pollClosesAt, bool pollAllowMultiple, List<String> mentionedUsers
});




}
/// @nodoc
class __$CreatePostPayloadCopyWithImpl<$Res>
    implements _$CreatePostPayloadCopyWith<$Res> {
  __$CreatePostPayloadCopyWithImpl(this._self, this._then);

  final _CreatePostPayload _self;
  final $Res Function(_CreatePostPayload) _then;

/// Create a copy of CreatePostPayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? postType = null,Object? body = freezed,Object? visibility = null,Object? gymTag = freezed,Object? locationLabel = freezed,Object? mediaUrls = null,Object? tags = null,Object? isAnonymous = null,Object? pollQuestion = freezed,Object? pollOptions = null,Object? pollClosesAt = freezed,Object? pollAllowMultiple = null,Object? mentionedUsers = null,}) {
  return _then(_CreatePostPayload(
postType: null == postType ? _self.postType : postType // ignore: cast_nullable_to_non_nullable
as String,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as String,gymTag: freezed == gymTag ? _self.gymTag : gymTag // ignore: cast_nullable_to_non_nullable
as String?,locationLabel: freezed == locationLabel ? _self.locationLabel : locationLabel // ignore: cast_nullable_to_non_nullable
as String?,mediaUrls: null == mediaUrls ? _self._mediaUrls : mediaUrls // ignore: cast_nullable_to_non_nullable
as List<String>,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,isAnonymous: null == isAnonymous ? _self.isAnonymous : isAnonymous // ignore: cast_nullable_to_non_nullable
as bool,pollQuestion: freezed == pollQuestion ? _self.pollQuestion : pollQuestion // ignore: cast_nullable_to_non_nullable
as String?,pollOptions: null == pollOptions ? _self._pollOptions : pollOptions // ignore: cast_nullable_to_non_nullable
as List<String>,pollClosesAt: freezed == pollClosesAt ? _self.pollClosesAt : pollClosesAt // ignore: cast_nullable_to_non_nullable
as String?,pollAllowMultiple: null == pollAllowMultiple ? _self.pollAllowMultiple : pollAllowMultiple // ignore: cast_nullable_to_non_nullable
as bool,mentionedUsers: null == mentionedUsers ? _self._mentionedUsers : mentionedUsers // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$ReactionInput {

 String get reactionType;
/// Create a copy of ReactionInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReactionInputCopyWith<ReactionInput> get copyWith => _$ReactionInputCopyWithImpl<ReactionInput>(this as ReactionInput, _$identity);

  /// Serializes this ReactionInput to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReactionInput&&(identical(other.reactionType, reactionType) || other.reactionType == reactionType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reactionType);

@override
String toString() {
  return 'ReactionInput(reactionType: $reactionType)';
}


}

/// @nodoc
abstract mixin class $ReactionInputCopyWith<$Res>  {
  factory $ReactionInputCopyWith(ReactionInput value, $Res Function(ReactionInput) _then) = _$ReactionInputCopyWithImpl;
@useResult
$Res call({
 String reactionType
});




}
/// @nodoc
class _$ReactionInputCopyWithImpl<$Res>
    implements $ReactionInputCopyWith<$Res> {
  _$ReactionInputCopyWithImpl(this._self, this._then);

  final ReactionInput _self;
  final $Res Function(ReactionInput) _then;

/// Create a copy of ReactionInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reactionType = null,}) {
  return _then(_self.copyWith(
reactionType: null == reactionType ? _self.reactionType : reactionType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ReactionInput].
extension ReactionInputPatterns on ReactionInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReactionInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReactionInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReactionInput value)  $default,){
final _that = this;
switch (_that) {
case _ReactionInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReactionInput value)?  $default,){
final _that = this;
switch (_that) {
case _ReactionInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String reactionType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReactionInput() when $default != null:
return $default(_that.reactionType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String reactionType)  $default,) {final _that = this;
switch (_that) {
case _ReactionInput():
return $default(_that.reactionType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String reactionType)?  $default,) {final _that = this;
switch (_that) {
case _ReactionInput() when $default != null:
return $default(_that.reactionType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReactionInput implements ReactionInput {
  const _ReactionInput({required this.reactionType});
  factory _ReactionInput.fromJson(Map<String, dynamic> json) => _$ReactionInputFromJson(json);

@override final  String reactionType;

/// Create a copy of ReactionInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReactionInputCopyWith<_ReactionInput> get copyWith => __$ReactionInputCopyWithImpl<_ReactionInput>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReactionInputToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReactionInput&&(identical(other.reactionType, reactionType) || other.reactionType == reactionType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reactionType);

@override
String toString() {
  return 'ReactionInput(reactionType: $reactionType)';
}


}

/// @nodoc
abstract mixin class _$ReactionInputCopyWith<$Res> implements $ReactionInputCopyWith<$Res> {
  factory _$ReactionInputCopyWith(_ReactionInput value, $Res Function(_ReactionInput) _then) = __$ReactionInputCopyWithImpl;
@override @useResult
$Res call({
 String reactionType
});




}
/// @nodoc
class __$ReactionInputCopyWithImpl<$Res>
    implements _$ReactionInputCopyWith<$Res> {
  __$ReactionInputCopyWithImpl(this._self, this._then);

  final _ReactionInput _self;
  final $Res Function(_ReactionInput) _then;

/// Create a copy of ReactionInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reactionType = null,}) {
  return _then(_ReactionInput(
reactionType: null == reactionType ? _self.reactionType : reactionType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CommentCreateInput {

 String get body; String? get parentId; bool get isAnonymous;
/// Create a copy of CommentCreateInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommentCreateInputCopyWith<CommentCreateInput> get copyWith => _$CommentCreateInputCopyWithImpl<CommentCreateInput>(this as CommentCreateInput, _$identity);

  /// Serializes this CommentCreateInput to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommentCreateInput&&(identical(other.body, body) || other.body == body)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.isAnonymous, isAnonymous) || other.isAnonymous == isAnonymous));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,body,parentId,isAnonymous);

@override
String toString() {
  return 'CommentCreateInput(body: $body, parentId: $parentId, isAnonymous: $isAnonymous)';
}


}

/// @nodoc
abstract mixin class $CommentCreateInputCopyWith<$Res>  {
  factory $CommentCreateInputCopyWith(CommentCreateInput value, $Res Function(CommentCreateInput) _then) = _$CommentCreateInputCopyWithImpl;
@useResult
$Res call({
 String body, String? parentId, bool isAnonymous
});




}
/// @nodoc
class _$CommentCreateInputCopyWithImpl<$Res>
    implements $CommentCreateInputCopyWith<$Res> {
  _$CommentCreateInputCopyWithImpl(this._self, this._then);

  final CommentCreateInput _self;
  final $Res Function(CommentCreateInput) _then;

/// Create a copy of CommentCreateInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? body = null,Object? parentId = freezed,Object? isAnonymous = null,}) {
  return _then(_self.copyWith(
body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,isAnonymous: null == isAnonymous ? _self.isAnonymous : isAnonymous // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CommentCreateInput].
extension CommentCreateInputPatterns on CommentCreateInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommentCreateInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommentCreateInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommentCreateInput value)  $default,){
final _that = this;
switch (_that) {
case _CommentCreateInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommentCreateInput value)?  $default,){
final _that = this;
switch (_that) {
case _CommentCreateInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String body,  String? parentId,  bool isAnonymous)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommentCreateInput() when $default != null:
return $default(_that.body,_that.parentId,_that.isAnonymous);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String body,  String? parentId,  bool isAnonymous)  $default,) {final _that = this;
switch (_that) {
case _CommentCreateInput():
return $default(_that.body,_that.parentId,_that.isAnonymous);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String body,  String? parentId,  bool isAnonymous)?  $default,) {final _that = this;
switch (_that) {
case _CommentCreateInput() when $default != null:
return $default(_that.body,_that.parentId,_that.isAnonymous);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CommentCreateInput implements CommentCreateInput {
  const _CommentCreateInput({required this.body, this.parentId, this.isAnonymous = false});
  factory _CommentCreateInput.fromJson(Map<String, dynamic> json) => _$CommentCreateInputFromJson(json);

@override final  String body;
@override final  String? parentId;
@override@JsonKey() final  bool isAnonymous;

/// Create a copy of CommentCreateInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommentCreateInputCopyWith<_CommentCreateInput> get copyWith => __$CommentCreateInputCopyWithImpl<_CommentCreateInput>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CommentCreateInputToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommentCreateInput&&(identical(other.body, body) || other.body == body)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.isAnonymous, isAnonymous) || other.isAnonymous == isAnonymous));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,body,parentId,isAnonymous);

@override
String toString() {
  return 'CommentCreateInput(body: $body, parentId: $parentId, isAnonymous: $isAnonymous)';
}


}

/// @nodoc
abstract mixin class _$CommentCreateInputCopyWith<$Res> implements $CommentCreateInputCopyWith<$Res> {
  factory _$CommentCreateInputCopyWith(_CommentCreateInput value, $Res Function(_CommentCreateInput) _then) = __$CommentCreateInputCopyWithImpl;
@override @useResult
$Res call({
 String body, String? parentId, bool isAnonymous
});




}
/// @nodoc
class __$CommentCreateInputCopyWithImpl<$Res>
    implements _$CommentCreateInputCopyWith<$Res> {
  __$CommentCreateInputCopyWithImpl(this._self, this._then);

  final _CommentCreateInput _self;
  final $Res Function(_CommentCreateInput) _then;

/// Create a copy of CommentCreateInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? body = null,Object? parentId = freezed,Object? isAnonymous = null,}) {
  return _then(_CommentCreateInput(
body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,isAnonymous: null == isAnonymous ? _self.isAnonymous : isAnonymous // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$RepostPayload {

 String get quoteBody;
/// Create a copy of RepostPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RepostPayloadCopyWith<RepostPayload> get copyWith => _$RepostPayloadCopyWithImpl<RepostPayload>(this as RepostPayload, _$identity);

  /// Serializes this RepostPayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RepostPayload&&(identical(other.quoteBody, quoteBody) || other.quoteBody == quoteBody));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,quoteBody);

@override
String toString() {
  return 'RepostPayload(quoteBody: $quoteBody)';
}


}

/// @nodoc
abstract mixin class $RepostPayloadCopyWith<$Res>  {
  factory $RepostPayloadCopyWith(RepostPayload value, $Res Function(RepostPayload) _then) = _$RepostPayloadCopyWithImpl;
@useResult
$Res call({
 String quoteBody
});




}
/// @nodoc
class _$RepostPayloadCopyWithImpl<$Res>
    implements $RepostPayloadCopyWith<$Res> {
  _$RepostPayloadCopyWithImpl(this._self, this._then);

  final RepostPayload _self;
  final $Res Function(RepostPayload) _then;

/// Create a copy of RepostPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? quoteBody = null,}) {
  return _then(_self.copyWith(
quoteBody: null == quoteBody ? _self.quoteBody : quoteBody // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RepostPayload].
extension RepostPayloadPatterns on RepostPayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RepostPayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RepostPayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RepostPayload value)  $default,){
final _that = this;
switch (_that) {
case _RepostPayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RepostPayload value)?  $default,){
final _that = this;
switch (_that) {
case _RepostPayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String quoteBody)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RepostPayload() when $default != null:
return $default(_that.quoteBody);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String quoteBody)  $default,) {final _that = this;
switch (_that) {
case _RepostPayload():
return $default(_that.quoteBody);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String quoteBody)?  $default,) {final _that = this;
switch (_that) {
case _RepostPayload() when $default != null:
return $default(_that.quoteBody);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RepostPayload implements RepostPayload {
  const _RepostPayload({this.quoteBody = ''});
  factory _RepostPayload.fromJson(Map<String, dynamic> json) => _$RepostPayloadFromJson(json);

@override@JsonKey() final  String quoteBody;

/// Create a copy of RepostPayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RepostPayloadCopyWith<_RepostPayload> get copyWith => __$RepostPayloadCopyWithImpl<_RepostPayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RepostPayloadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RepostPayload&&(identical(other.quoteBody, quoteBody) || other.quoteBody == quoteBody));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,quoteBody);

@override
String toString() {
  return 'RepostPayload(quoteBody: $quoteBody)';
}


}

/// @nodoc
abstract mixin class _$RepostPayloadCopyWith<$Res> implements $RepostPayloadCopyWith<$Res> {
  factory _$RepostPayloadCopyWith(_RepostPayload value, $Res Function(_RepostPayload) _then) = __$RepostPayloadCopyWithImpl;
@override @useResult
$Res call({
 String quoteBody
});




}
/// @nodoc
class __$RepostPayloadCopyWithImpl<$Res>
    implements _$RepostPayloadCopyWith<$Res> {
  __$RepostPayloadCopyWithImpl(this._self, this._then);

  final _RepostPayload _self;
  final $Res Function(_RepostPayload) _then;

/// Create a copy of RepostPayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? quoteBody = null,}) {
  return _then(_RepostPayload(
quoteBody: null == quoteBody ? _self.quoteBody : quoteBody // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SavePayload {

 String? get collection;
/// Create a copy of SavePayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavePayloadCopyWith<SavePayload> get copyWith => _$SavePayloadCopyWithImpl<SavePayload>(this as SavePayload, _$identity);

  /// Serializes this SavePayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavePayload&&(identical(other.collection, collection) || other.collection == collection));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,collection);

@override
String toString() {
  return 'SavePayload(collection: $collection)';
}


}

/// @nodoc
abstract mixin class $SavePayloadCopyWith<$Res>  {
  factory $SavePayloadCopyWith(SavePayload value, $Res Function(SavePayload) _then) = _$SavePayloadCopyWithImpl;
@useResult
$Res call({
 String? collection
});




}
/// @nodoc
class _$SavePayloadCopyWithImpl<$Res>
    implements $SavePayloadCopyWith<$Res> {
  _$SavePayloadCopyWithImpl(this._self, this._then);

  final SavePayload _self;
  final $Res Function(SavePayload) _then;

/// Create a copy of SavePayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? collection = freezed,}) {
  return _then(_self.copyWith(
collection: freezed == collection ? _self.collection : collection // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SavePayload].
extension SavePayloadPatterns on SavePayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavePayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavePayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavePayload value)  $default,){
final _that = this;
switch (_that) {
case _SavePayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavePayload value)?  $default,){
final _that = this;
switch (_that) {
case _SavePayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? collection)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavePayload() when $default != null:
return $default(_that.collection);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? collection)  $default,) {final _that = this;
switch (_that) {
case _SavePayload():
return $default(_that.collection);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? collection)?  $default,) {final _that = this;
switch (_that) {
case _SavePayload() when $default != null:
return $default(_that.collection);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SavePayload implements SavePayload {
  const _SavePayload({this.collection});
  factory _SavePayload.fromJson(Map<String, dynamic> json) => _$SavePayloadFromJson(json);

@override final  String? collection;

/// Create a copy of SavePayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavePayloadCopyWith<_SavePayload> get copyWith => __$SavePayloadCopyWithImpl<_SavePayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SavePayloadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavePayload&&(identical(other.collection, collection) || other.collection == collection));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,collection);

@override
String toString() {
  return 'SavePayload(collection: $collection)';
}


}

/// @nodoc
abstract mixin class _$SavePayloadCopyWith<$Res> implements $SavePayloadCopyWith<$Res> {
  factory _$SavePayloadCopyWith(_SavePayload value, $Res Function(_SavePayload) _then) = __$SavePayloadCopyWithImpl;
@override @useResult
$Res call({
 String? collection
});




}
/// @nodoc
class __$SavePayloadCopyWithImpl<$Res>
    implements _$SavePayloadCopyWith<$Res> {
  __$SavePayloadCopyWithImpl(this._self, this._then);

  final _SavePayload _self;
  final $Res Function(_SavePayload) _then;

/// Create a copy of SavePayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? collection = freezed,}) {
  return _then(_SavePayload(
collection: freezed == collection ? _self.collection : collection // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Draft {

 String? get id; String get postType; String get body; String get visibility; String? get gymTag; String? get locationLabel; List<String> get mediaUrls; List<String> get tags; String get pollQuestion; List<String> get pollOptions; bool get pollAllowMultiple; List<String> get mentionedUserIds; bool get isAnonymous;
/// Create a copy of Draft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DraftCopyWith<Draft> get copyWith => _$DraftCopyWithImpl<Draft>(this as Draft, _$identity);

  /// Serializes this Draft to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Draft&&(identical(other.id, id) || other.id == id)&&(identical(other.postType, postType) || other.postType == postType)&&(identical(other.body, body) || other.body == body)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.gymTag, gymTag) || other.gymTag == gymTag)&&(identical(other.locationLabel, locationLabel) || other.locationLabel == locationLabel)&&const DeepCollectionEquality().equals(other.mediaUrls, mediaUrls)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.pollQuestion, pollQuestion) || other.pollQuestion == pollQuestion)&&const DeepCollectionEquality().equals(other.pollOptions, pollOptions)&&(identical(other.pollAllowMultiple, pollAllowMultiple) || other.pollAllowMultiple == pollAllowMultiple)&&const DeepCollectionEquality().equals(other.mentionedUserIds, mentionedUserIds)&&(identical(other.isAnonymous, isAnonymous) || other.isAnonymous == isAnonymous));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,postType,body,visibility,gymTag,locationLabel,const DeepCollectionEquality().hash(mediaUrls),const DeepCollectionEquality().hash(tags),pollQuestion,const DeepCollectionEquality().hash(pollOptions),pollAllowMultiple,const DeepCollectionEquality().hash(mentionedUserIds),isAnonymous);

@override
String toString() {
  return 'Draft(id: $id, postType: $postType, body: $body, visibility: $visibility, gymTag: $gymTag, locationLabel: $locationLabel, mediaUrls: $mediaUrls, tags: $tags, pollQuestion: $pollQuestion, pollOptions: $pollOptions, pollAllowMultiple: $pollAllowMultiple, mentionedUserIds: $mentionedUserIds, isAnonymous: $isAnonymous)';
}


}

/// @nodoc
abstract mixin class $DraftCopyWith<$Res>  {
  factory $DraftCopyWith(Draft value, $Res Function(Draft) _then) = _$DraftCopyWithImpl;
@useResult
$Res call({
 String? id, String postType, String body, String visibility, String? gymTag, String? locationLabel, List<String> mediaUrls, List<String> tags, String pollQuestion, List<String> pollOptions, bool pollAllowMultiple, List<String> mentionedUserIds, bool isAnonymous
});




}
/// @nodoc
class _$DraftCopyWithImpl<$Res>
    implements $DraftCopyWith<$Res> {
  _$DraftCopyWithImpl(this._self, this._then);

  final Draft _self;
  final $Res Function(Draft) _then;

/// Create a copy of Draft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? postType = null,Object? body = null,Object? visibility = null,Object? gymTag = freezed,Object? locationLabel = freezed,Object? mediaUrls = null,Object? tags = null,Object? pollQuestion = null,Object? pollOptions = null,Object? pollAllowMultiple = null,Object? mentionedUserIds = null,Object? isAnonymous = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,postType: null == postType ? _self.postType : postType // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as String,gymTag: freezed == gymTag ? _self.gymTag : gymTag // ignore: cast_nullable_to_non_nullable
as String?,locationLabel: freezed == locationLabel ? _self.locationLabel : locationLabel // ignore: cast_nullable_to_non_nullable
as String?,mediaUrls: null == mediaUrls ? _self.mediaUrls : mediaUrls // ignore: cast_nullable_to_non_nullable
as List<String>,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,pollQuestion: null == pollQuestion ? _self.pollQuestion : pollQuestion // ignore: cast_nullable_to_non_nullable
as String,pollOptions: null == pollOptions ? _self.pollOptions : pollOptions // ignore: cast_nullable_to_non_nullable
as List<String>,pollAllowMultiple: null == pollAllowMultiple ? _self.pollAllowMultiple : pollAllowMultiple // ignore: cast_nullable_to_non_nullable
as bool,mentionedUserIds: null == mentionedUserIds ? _self.mentionedUserIds : mentionedUserIds // ignore: cast_nullable_to_non_nullable
as List<String>,isAnonymous: null == isAnonymous ? _self.isAnonymous : isAnonymous // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Draft].
extension DraftPatterns on Draft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Draft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Draft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Draft value)  $default,){
final _that = this;
switch (_that) {
case _Draft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Draft value)?  $default,){
final _that = this;
switch (_that) {
case _Draft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String postType,  String body,  String visibility,  String? gymTag,  String? locationLabel,  List<String> mediaUrls,  List<String> tags,  String pollQuestion,  List<String> pollOptions,  bool pollAllowMultiple,  List<String> mentionedUserIds,  bool isAnonymous)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Draft() when $default != null:
return $default(_that.id,_that.postType,_that.body,_that.visibility,_that.gymTag,_that.locationLabel,_that.mediaUrls,_that.tags,_that.pollQuestion,_that.pollOptions,_that.pollAllowMultiple,_that.mentionedUserIds,_that.isAnonymous);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String postType,  String body,  String visibility,  String? gymTag,  String? locationLabel,  List<String> mediaUrls,  List<String> tags,  String pollQuestion,  List<String> pollOptions,  bool pollAllowMultiple,  List<String> mentionedUserIds,  bool isAnonymous)  $default,) {final _that = this;
switch (_that) {
case _Draft():
return $default(_that.id,_that.postType,_that.body,_that.visibility,_that.gymTag,_that.locationLabel,_that.mediaUrls,_that.tags,_that.pollQuestion,_that.pollOptions,_that.pollAllowMultiple,_that.mentionedUserIds,_that.isAnonymous);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String postType,  String body,  String visibility,  String? gymTag,  String? locationLabel,  List<String> mediaUrls,  List<String> tags,  String pollQuestion,  List<String> pollOptions,  bool pollAllowMultiple,  List<String> mentionedUserIds,  bool isAnonymous)?  $default,) {final _that = this;
switch (_that) {
case _Draft() when $default != null:
return $default(_that.id,_that.postType,_that.body,_that.visibility,_that.gymTag,_that.locationLabel,_that.mediaUrls,_that.tags,_that.pollQuestion,_that.pollOptions,_that.pollAllowMultiple,_that.mentionedUserIds,_that.isAnonymous);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Draft implements Draft {
  const _Draft({this.id, this.postType = 'text', this.body = '', this.visibility = 'public', this.gymTag, this.locationLabel, final  List<String> mediaUrls = const <String>[], final  List<String> tags = const <String>[], this.pollQuestion = '', final  List<String> pollOptions = const <String>[], this.pollAllowMultiple = false, final  List<String> mentionedUserIds = const <String>[], this.isAnonymous = false}): _mediaUrls = mediaUrls,_tags = tags,_pollOptions = pollOptions,_mentionedUserIds = mentionedUserIds;
  factory _Draft.fromJson(Map<String, dynamic> json) => _$DraftFromJson(json);

@override final  String? id;
@override@JsonKey() final  String postType;
@override@JsonKey() final  String body;
@override@JsonKey() final  String visibility;
@override final  String? gymTag;
@override final  String? locationLabel;
 final  List<String> _mediaUrls;
@override@JsonKey() List<String> get mediaUrls {
  if (_mediaUrls is EqualUnmodifiableListView) return _mediaUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mediaUrls);
}

 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override@JsonKey() final  String pollQuestion;
 final  List<String> _pollOptions;
@override@JsonKey() List<String> get pollOptions {
  if (_pollOptions is EqualUnmodifiableListView) return _pollOptions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pollOptions);
}

@override@JsonKey() final  bool pollAllowMultiple;
 final  List<String> _mentionedUserIds;
@override@JsonKey() List<String> get mentionedUserIds {
  if (_mentionedUserIds is EqualUnmodifiableListView) return _mentionedUserIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mentionedUserIds);
}

@override@JsonKey() final  bool isAnonymous;

/// Create a copy of Draft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DraftCopyWith<_Draft> get copyWith => __$DraftCopyWithImpl<_Draft>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DraftToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Draft&&(identical(other.id, id) || other.id == id)&&(identical(other.postType, postType) || other.postType == postType)&&(identical(other.body, body) || other.body == body)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.gymTag, gymTag) || other.gymTag == gymTag)&&(identical(other.locationLabel, locationLabel) || other.locationLabel == locationLabel)&&const DeepCollectionEquality().equals(other._mediaUrls, _mediaUrls)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.pollQuestion, pollQuestion) || other.pollQuestion == pollQuestion)&&const DeepCollectionEquality().equals(other._pollOptions, _pollOptions)&&(identical(other.pollAllowMultiple, pollAllowMultiple) || other.pollAllowMultiple == pollAllowMultiple)&&const DeepCollectionEquality().equals(other._mentionedUserIds, _mentionedUserIds)&&(identical(other.isAnonymous, isAnonymous) || other.isAnonymous == isAnonymous));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,postType,body,visibility,gymTag,locationLabel,const DeepCollectionEquality().hash(_mediaUrls),const DeepCollectionEquality().hash(_tags),pollQuestion,const DeepCollectionEquality().hash(_pollOptions),pollAllowMultiple,const DeepCollectionEquality().hash(_mentionedUserIds),isAnonymous);

@override
String toString() {
  return 'Draft(id: $id, postType: $postType, body: $body, visibility: $visibility, gymTag: $gymTag, locationLabel: $locationLabel, mediaUrls: $mediaUrls, tags: $tags, pollQuestion: $pollQuestion, pollOptions: $pollOptions, pollAllowMultiple: $pollAllowMultiple, mentionedUserIds: $mentionedUserIds, isAnonymous: $isAnonymous)';
}


}

/// @nodoc
abstract mixin class _$DraftCopyWith<$Res> implements $DraftCopyWith<$Res> {
  factory _$DraftCopyWith(_Draft value, $Res Function(_Draft) _then) = __$DraftCopyWithImpl;
@override @useResult
$Res call({
 String? id, String postType, String body, String visibility, String? gymTag, String? locationLabel, List<String> mediaUrls, List<String> tags, String pollQuestion, List<String> pollOptions, bool pollAllowMultiple, List<String> mentionedUserIds, bool isAnonymous
});




}
/// @nodoc
class __$DraftCopyWithImpl<$Res>
    implements _$DraftCopyWith<$Res> {
  __$DraftCopyWithImpl(this._self, this._then);

  final _Draft _self;
  final $Res Function(_Draft) _then;

/// Create a copy of Draft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? postType = null,Object? body = null,Object? visibility = null,Object? gymTag = freezed,Object? locationLabel = freezed,Object? mediaUrls = null,Object? tags = null,Object? pollQuestion = null,Object? pollOptions = null,Object? pollAllowMultiple = null,Object? mentionedUserIds = null,Object? isAnonymous = null,}) {
  return _then(_Draft(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,postType: null == postType ? _self.postType : postType // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as String,gymTag: freezed == gymTag ? _self.gymTag : gymTag // ignore: cast_nullable_to_non_nullable
as String?,locationLabel: freezed == locationLabel ? _self.locationLabel : locationLabel // ignore: cast_nullable_to_non_nullable
as String?,mediaUrls: null == mediaUrls ? _self._mediaUrls : mediaUrls // ignore: cast_nullable_to_non_nullable
as List<String>,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,pollQuestion: null == pollQuestion ? _self.pollQuestion : pollQuestion // ignore: cast_nullable_to_non_nullable
as String,pollOptions: null == pollOptions ? _self._pollOptions : pollOptions // ignore: cast_nullable_to_non_nullable
as List<String>,pollAllowMultiple: null == pollAllowMultiple ? _self.pollAllowMultiple : pollAllowMultiple // ignore: cast_nullable_to_non_nullable
as bool,mentionedUserIds: null == mentionedUserIds ? _self._mentionedUserIds : mentionedUserIds // ignore: cast_nullable_to_non_nullable
as List<String>,isAnonymous: null == isAnonymous ? _self.isAnonymous : isAnonymous // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
