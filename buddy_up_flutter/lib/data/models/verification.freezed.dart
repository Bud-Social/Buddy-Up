// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verification.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VerificationDocument {

 String get id;@JsonKey(name: 'document_type') String get documentType;@JsonKey(name: 'file_url') String get fileUrl; String get status;@JsonKey(name: 'submitted_at') String get submittedAt; String? get reviewedBy; String? get reviewedAt; String? get rejectionReason;
/// Create a copy of VerificationDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerificationDocumentCopyWith<VerificationDocument> get copyWith => _$VerificationDocumentCopyWithImpl<VerificationDocument>(this as VerificationDocument, _$identity);

  /// Serializes this VerificationDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerificationDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.documentType, documentType) || other.documentType == documentType)&&(identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.reviewedBy, reviewedBy) || other.reviewedBy == reviewedBy)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,documentType,fileUrl,status,submittedAt,reviewedBy,reviewedAt,rejectionReason);

@override
String toString() {
  return 'VerificationDocument(id: $id, documentType: $documentType, fileUrl: $fileUrl, status: $status, submittedAt: $submittedAt, reviewedBy: $reviewedBy, reviewedAt: $reviewedAt, rejectionReason: $rejectionReason)';
}


}

/// @nodoc
abstract mixin class $VerificationDocumentCopyWith<$Res>  {
  factory $VerificationDocumentCopyWith(VerificationDocument value, $Res Function(VerificationDocument) _then) = _$VerificationDocumentCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'document_type') String documentType,@JsonKey(name: 'file_url') String fileUrl, String status,@JsonKey(name: 'submitted_at') String submittedAt, String? reviewedBy, String? reviewedAt, String? rejectionReason
});




}
/// @nodoc
class _$VerificationDocumentCopyWithImpl<$Res>
    implements $VerificationDocumentCopyWith<$Res> {
  _$VerificationDocumentCopyWithImpl(this._self, this._then);

  final VerificationDocument _self;
  final $Res Function(VerificationDocument) _then;

/// Create a copy of VerificationDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? documentType = null,Object? fileUrl = null,Object? status = null,Object? submittedAt = null,Object? reviewedBy = freezed,Object? reviewedAt = freezed,Object? rejectionReason = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,documentType: null == documentType ? _self.documentType : documentType // ignore: cast_nullable_to_non_nullable
as String,fileUrl: null == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,submittedAt: null == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as String,reviewedBy: freezed == reviewedBy ? _self.reviewedBy : reviewedBy // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as String?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VerificationDocument].
extension VerificationDocumentPatterns on VerificationDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VerificationDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VerificationDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VerificationDocument value)  $default,){
final _that = this;
switch (_that) {
case _VerificationDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VerificationDocument value)?  $default,){
final _that = this;
switch (_that) {
case _VerificationDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'document_type')  String documentType, @JsonKey(name: 'file_url')  String fileUrl,  String status, @JsonKey(name: 'submitted_at')  String submittedAt,  String? reviewedBy,  String? reviewedAt,  String? rejectionReason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VerificationDocument() when $default != null:
return $default(_that.id,_that.documentType,_that.fileUrl,_that.status,_that.submittedAt,_that.reviewedBy,_that.reviewedAt,_that.rejectionReason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'document_type')  String documentType, @JsonKey(name: 'file_url')  String fileUrl,  String status, @JsonKey(name: 'submitted_at')  String submittedAt,  String? reviewedBy,  String? reviewedAt,  String? rejectionReason)  $default,) {final _that = this;
switch (_that) {
case _VerificationDocument():
return $default(_that.id,_that.documentType,_that.fileUrl,_that.status,_that.submittedAt,_that.reviewedBy,_that.reviewedAt,_that.rejectionReason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'document_type')  String documentType, @JsonKey(name: 'file_url')  String fileUrl,  String status, @JsonKey(name: 'submitted_at')  String submittedAt,  String? reviewedBy,  String? reviewedAt,  String? rejectionReason)?  $default,) {final _that = this;
switch (_that) {
case _VerificationDocument() when $default != null:
return $default(_that.id,_that.documentType,_that.fileUrl,_that.status,_that.submittedAt,_that.reviewedBy,_that.reviewedAt,_that.rejectionReason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VerificationDocument implements VerificationDocument {
  const _VerificationDocument({required this.id, @JsonKey(name: 'document_type') required this.documentType, @JsonKey(name: 'file_url') required this.fileUrl, this.status = 'pending', @JsonKey(name: 'submitted_at') required this.submittedAt, this.reviewedBy, this.reviewedAt, this.rejectionReason});
  factory _VerificationDocument.fromJson(Map<String, dynamic> json) => _$VerificationDocumentFromJson(json);

@override final  String id;
@override@JsonKey(name: 'document_type') final  String documentType;
@override@JsonKey(name: 'file_url') final  String fileUrl;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'submitted_at') final  String submittedAt;
@override final  String? reviewedBy;
@override final  String? reviewedAt;
@override final  String? rejectionReason;

/// Create a copy of VerificationDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerificationDocumentCopyWith<_VerificationDocument> get copyWith => __$VerificationDocumentCopyWithImpl<_VerificationDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VerificationDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerificationDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.documentType, documentType) || other.documentType == documentType)&&(identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.reviewedBy, reviewedBy) || other.reviewedBy == reviewedBy)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,documentType,fileUrl,status,submittedAt,reviewedBy,reviewedAt,rejectionReason);

@override
String toString() {
  return 'VerificationDocument(id: $id, documentType: $documentType, fileUrl: $fileUrl, status: $status, submittedAt: $submittedAt, reviewedBy: $reviewedBy, reviewedAt: $reviewedAt, rejectionReason: $rejectionReason)';
}


}

/// @nodoc
abstract mixin class _$VerificationDocumentCopyWith<$Res> implements $VerificationDocumentCopyWith<$Res> {
  factory _$VerificationDocumentCopyWith(_VerificationDocument value, $Res Function(_VerificationDocument) _then) = __$VerificationDocumentCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'document_type') String documentType,@JsonKey(name: 'file_url') String fileUrl, String status,@JsonKey(name: 'submitted_at') String submittedAt, String? reviewedBy, String? reviewedAt, String? rejectionReason
});




}
/// @nodoc
class __$VerificationDocumentCopyWithImpl<$Res>
    implements _$VerificationDocumentCopyWith<$Res> {
  __$VerificationDocumentCopyWithImpl(this._self, this._then);

  final _VerificationDocument _self;
  final $Res Function(_VerificationDocument) _then;

/// Create a copy of VerificationDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? documentType = null,Object? fileUrl = null,Object? status = null,Object? submittedAt = null,Object? reviewedBy = freezed,Object? reviewedAt = freezed,Object? rejectionReason = freezed,}) {
  return _then(_VerificationDocument(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,documentType: null == documentType ? _self.documentType : documentType // ignore: cast_nullable_to_non_nullable
as String,fileUrl: null == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,submittedAt: null == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as String,reviewedBy: freezed == reviewedBy ? _self.reviewedBy : reviewedBy // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as String?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$VerificationSubmission {

 String get id;@JsonKey(name: 'submission_type') String get submissionType; String get status; List<VerificationDocument> get documents; String? get reviewedBy; String? get reviewedAt; String? get rejectionReason;@JsonKey(name: 'submitted_at') String get submittedAt;
/// Create a copy of VerificationSubmission
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerificationSubmissionCopyWith<VerificationSubmission> get copyWith => _$VerificationSubmissionCopyWithImpl<VerificationSubmission>(this as VerificationSubmission, _$identity);

  /// Serializes this VerificationSubmission to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerificationSubmission&&(identical(other.id, id) || other.id == id)&&(identical(other.submissionType, submissionType) || other.submissionType == submissionType)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.documents, documents)&&(identical(other.reviewedBy, reviewedBy) || other.reviewedBy == reviewedBy)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,submissionType,status,const DeepCollectionEquality().hash(documents),reviewedBy,reviewedAt,rejectionReason,submittedAt);

@override
String toString() {
  return 'VerificationSubmission(id: $id, submissionType: $submissionType, status: $status, documents: $documents, reviewedBy: $reviewedBy, reviewedAt: $reviewedAt, rejectionReason: $rejectionReason, submittedAt: $submittedAt)';
}


}

/// @nodoc
abstract mixin class $VerificationSubmissionCopyWith<$Res>  {
  factory $VerificationSubmissionCopyWith(VerificationSubmission value, $Res Function(VerificationSubmission) _then) = _$VerificationSubmissionCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'submission_type') String submissionType, String status, List<VerificationDocument> documents, String? reviewedBy, String? reviewedAt, String? rejectionReason,@JsonKey(name: 'submitted_at') String submittedAt
});




}
/// @nodoc
class _$VerificationSubmissionCopyWithImpl<$Res>
    implements $VerificationSubmissionCopyWith<$Res> {
  _$VerificationSubmissionCopyWithImpl(this._self, this._then);

  final VerificationSubmission _self;
  final $Res Function(VerificationSubmission) _then;

/// Create a copy of VerificationSubmission
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? submissionType = null,Object? status = null,Object? documents = null,Object? reviewedBy = freezed,Object? reviewedAt = freezed,Object? rejectionReason = freezed,Object? submittedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,submissionType: null == submissionType ? _self.submissionType : submissionType // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,documents: null == documents ? _self.documents : documents // ignore: cast_nullable_to_non_nullable
as List<VerificationDocument>,reviewedBy: freezed == reviewedBy ? _self.reviewedBy : reviewedBy // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as String?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: null == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [VerificationSubmission].
extension VerificationSubmissionPatterns on VerificationSubmission {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VerificationSubmission value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VerificationSubmission() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VerificationSubmission value)  $default,){
final _that = this;
switch (_that) {
case _VerificationSubmission():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VerificationSubmission value)?  $default,){
final _that = this;
switch (_that) {
case _VerificationSubmission() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'submission_type')  String submissionType,  String status,  List<VerificationDocument> documents,  String? reviewedBy,  String? reviewedAt,  String? rejectionReason, @JsonKey(name: 'submitted_at')  String submittedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VerificationSubmission() when $default != null:
return $default(_that.id,_that.submissionType,_that.status,_that.documents,_that.reviewedBy,_that.reviewedAt,_that.rejectionReason,_that.submittedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'submission_type')  String submissionType,  String status,  List<VerificationDocument> documents,  String? reviewedBy,  String? reviewedAt,  String? rejectionReason, @JsonKey(name: 'submitted_at')  String submittedAt)  $default,) {final _that = this;
switch (_that) {
case _VerificationSubmission():
return $default(_that.id,_that.submissionType,_that.status,_that.documents,_that.reviewedBy,_that.reviewedAt,_that.rejectionReason,_that.submittedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'submission_type')  String submissionType,  String status,  List<VerificationDocument> documents,  String? reviewedBy,  String? reviewedAt,  String? rejectionReason, @JsonKey(name: 'submitted_at')  String submittedAt)?  $default,) {final _that = this;
switch (_that) {
case _VerificationSubmission() when $default != null:
return $default(_that.id,_that.submissionType,_that.status,_that.documents,_that.reviewedBy,_that.reviewedAt,_that.rejectionReason,_that.submittedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VerificationSubmission implements VerificationSubmission {
  const _VerificationSubmission({required this.id, @JsonKey(name: 'submission_type') required this.submissionType, this.status = 'pending', final  List<VerificationDocument> documents = const <VerificationDocument>[], this.reviewedBy, this.reviewedAt, this.rejectionReason, @JsonKey(name: 'submitted_at') required this.submittedAt}): _documents = documents;
  factory _VerificationSubmission.fromJson(Map<String, dynamic> json) => _$VerificationSubmissionFromJson(json);

@override final  String id;
@override@JsonKey(name: 'submission_type') final  String submissionType;
@override@JsonKey() final  String status;
 final  List<VerificationDocument> _documents;
@override@JsonKey() List<VerificationDocument> get documents {
  if (_documents is EqualUnmodifiableListView) return _documents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_documents);
}

@override final  String? reviewedBy;
@override final  String? reviewedAt;
@override final  String? rejectionReason;
@override@JsonKey(name: 'submitted_at') final  String submittedAt;

/// Create a copy of VerificationSubmission
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerificationSubmissionCopyWith<_VerificationSubmission> get copyWith => __$VerificationSubmissionCopyWithImpl<_VerificationSubmission>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VerificationSubmissionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerificationSubmission&&(identical(other.id, id) || other.id == id)&&(identical(other.submissionType, submissionType) || other.submissionType == submissionType)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._documents, _documents)&&(identical(other.reviewedBy, reviewedBy) || other.reviewedBy == reviewedBy)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,submissionType,status,const DeepCollectionEquality().hash(_documents),reviewedBy,reviewedAt,rejectionReason,submittedAt);

@override
String toString() {
  return 'VerificationSubmission(id: $id, submissionType: $submissionType, status: $status, documents: $documents, reviewedBy: $reviewedBy, reviewedAt: $reviewedAt, rejectionReason: $rejectionReason, submittedAt: $submittedAt)';
}


}

/// @nodoc
abstract mixin class _$VerificationSubmissionCopyWith<$Res> implements $VerificationSubmissionCopyWith<$Res> {
  factory _$VerificationSubmissionCopyWith(_VerificationSubmission value, $Res Function(_VerificationSubmission) _then) = __$VerificationSubmissionCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'submission_type') String submissionType, String status, List<VerificationDocument> documents, String? reviewedBy, String? reviewedAt, String? rejectionReason,@JsonKey(name: 'submitted_at') String submittedAt
});




}
/// @nodoc
class __$VerificationSubmissionCopyWithImpl<$Res>
    implements _$VerificationSubmissionCopyWith<$Res> {
  __$VerificationSubmissionCopyWithImpl(this._self, this._then);

  final _VerificationSubmission _self;
  final $Res Function(_VerificationSubmission) _then;

/// Create a copy of VerificationSubmission
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? submissionType = null,Object? status = null,Object? documents = null,Object? reviewedBy = freezed,Object? reviewedAt = freezed,Object? rejectionReason = freezed,Object? submittedAt = null,}) {
  return _then(_VerificationSubmission(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,submissionType: null == submissionType ? _self.submissionType : submissionType // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,documents: null == documents ? _self._documents : documents // ignore: cast_nullable_to_non_nullable
as List<VerificationDocument>,reviewedBy: freezed == reviewedBy ? _self.reviewedBy : reviewedBy // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as String?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: null == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
