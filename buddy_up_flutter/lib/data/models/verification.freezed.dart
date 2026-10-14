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

 String get id;@JsonKey(name: 'document_type') String get documentType;@JsonKey(name: 'file_url') String get fileUrl;/// pending / approved / rejected.
 String get status;@JsonKey(name: 'rejection_reason') String get rejectionReason;@JsonKey(name: 'reviewed_by') String? get reviewedBy;@JsonKey(name: 'reviewed_at') String? get reviewedAt;@JsonKey(name: 'expires_at') String? get expiresAt;@JsonKey(name: 'purge_after') String? get purgeAfter;@JsonKey(name: 'purged_at') String? get purgedAt;@JsonKey(name: 'created_at') String? get createdAt;
/// Create a copy of VerificationDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerificationDocumentCopyWith<VerificationDocument> get copyWith => _$VerificationDocumentCopyWithImpl<VerificationDocument>(this as VerificationDocument, _$identity);

  /// Serializes this VerificationDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerificationDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.documentType, documentType) || other.documentType == documentType)&&(identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.reviewedBy, reviewedBy) || other.reviewedBy == reviewedBy)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.purgeAfter, purgeAfter) || other.purgeAfter == purgeAfter)&&(identical(other.purgedAt, purgedAt) || other.purgedAt == purgedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,documentType,fileUrl,status,rejectionReason,reviewedBy,reviewedAt,expiresAt,purgeAfter,purgedAt,createdAt);

@override
String toString() {
  return 'VerificationDocument(id: $id, documentType: $documentType, fileUrl: $fileUrl, status: $status, rejectionReason: $rejectionReason, reviewedBy: $reviewedBy, reviewedAt: $reviewedAt, expiresAt: $expiresAt, purgeAfter: $purgeAfter, purgedAt: $purgedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $VerificationDocumentCopyWith<$Res>  {
  factory $VerificationDocumentCopyWith(VerificationDocument value, $Res Function(VerificationDocument) _then) = _$VerificationDocumentCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'document_type') String documentType,@JsonKey(name: 'file_url') String fileUrl, String status,@JsonKey(name: 'rejection_reason') String rejectionReason,@JsonKey(name: 'reviewed_by') String? reviewedBy,@JsonKey(name: 'reviewed_at') String? reviewedAt,@JsonKey(name: 'expires_at') String? expiresAt,@JsonKey(name: 'purge_after') String? purgeAfter,@JsonKey(name: 'purged_at') String? purgedAt,@JsonKey(name: 'created_at') String? createdAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? documentType = null,Object? fileUrl = null,Object? status = null,Object? rejectionReason = null,Object? reviewedBy = freezed,Object? reviewedAt = freezed,Object? expiresAt = freezed,Object? purgeAfter = freezed,Object? purgedAt = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,documentType: null == documentType ? _self.documentType : documentType // ignore: cast_nullable_to_non_nullable
as String,fileUrl: null == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,rejectionReason: null == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String,reviewedBy: freezed == reviewedBy ? _self.reviewedBy : reviewedBy // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as String?,purgeAfter: freezed == purgeAfter ? _self.purgeAfter : purgeAfter // ignore: cast_nullable_to_non_nullable
as String?,purgedAt: freezed == purgedAt ? _self.purgedAt : purgedAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'document_type')  String documentType, @JsonKey(name: 'file_url')  String fileUrl,  String status, @JsonKey(name: 'rejection_reason')  String rejectionReason, @JsonKey(name: 'reviewed_by')  String? reviewedBy, @JsonKey(name: 'reviewed_at')  String? reviewedAt, @JsonKey(name: 'expires_at')  String? expiresAt, @JsonKey(name: 'purge_after')  String? purgeAfter, @JsonKey(name: 'purged_at')  String? purgedAt, @JsonKey(name: 'created_at')  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VerificationDocument() when $default != null:
return $default(_that.id,_that.documentType,_that.fileUrl,_that.status,_that.rejectionReason,_that.reviewedBy,_that.reviewedAt,_that.expiresAt,_that.purgeAfter,_that.purgedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'document_type')  String documentType, @JsonKey(name: 'file_url')  String fileUrl,  String status, @JsonKey(name: 'rejection_reason')  String rejectionReason, @JsonKey(name: 'reviewed_by')  String? reviewedBy, @JsonKey(name: 'reviewed_at')  String? reviewedAt, @JsonKey(name: 'expires_at')  String? expiresAt, @JsonKey(name: 'purge_after')  String? purgeAfter, @JsonKey(name: 'purged_at')  String? purgedAt, @JsonKey(name: 'created_at')  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _VerificationDocument():
return $default(_that.id,_that.documentType,_that.fileUrl,_that.status,_that.rejectionReason,_that.reviewedBy,_that.reviewedAt,_that.expiresAt,_that.purgeAfter,_that.purgedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'document_type')  String documentType, @JsonKey(name: 'file_url')  String fileUrl,  String status, @JsonKey(name: 'rejection_reason')  String rejectionReason, @JsonKey(name: 'reviewed_by')  String? reviewedBy, @JsonKey(name: 'reviewed_at')  String? reviewedAt, @JsonKey(name: 'expires_at')  String? expiresAt, @JsonKey(name: 'purge_after')  String? purgeAfter, @JsonKey(name: 'purged_at')  String? purgedAt, @JsonKey(name: 'created_at')  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _VerificationDocument() when $default != null:
return $default(_that.id,_that.documentType,_that.fileUrl,_that.status,_that.rejectionReason,_that.reviewedBy,_that.reviewedAt,_that.expiresAt,_that.purgeAfter,_that.purgedAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VerificationDocument implements VerificationDocument {
  const _VerificationDocument({this.id = '', @JsonKey(name: 'document_type') this.documentType = '', @JsonKey(name: 'file_url') this.fileUrl = '', this.status = 'pending', @JsonKey(name: 'rejection_reason') this.rejectionReason = '', @JsonKey(name: 'reviewed_by') this.reviewedBy, @JsonKey(name: 'reviewed_at') this.reviewedAt, @JsonKey(name: 'expires_at') this.expiresAt, @JsonKey(name: 'purge_after') this.purgeAfter, @JsonKey(name: 'purged_at') this.purgedAt, @JsonKey(name: 'created_at') this.createdAt});
  factory _VerificationDocument.fromJson(Map<String, dynamic> json) => _$VerificationDocumentFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey(name: 'document_type') final  String documentType;
@override@JsonKey(name: 'file_url') final  String fileUrl;
/// pending / approved / rejected.
@override@JsonKey() final  String status;
@override@JsonKey(name: 'rejection_reason') final  String rejectionReason;
@override@JsonKey(name: 'reviewed_by') final  String? reviewedBy;
@override@JsonKey(name: 'reviewed_at') final  String? reviewedAt;
@override@JsonKey(name: 'expires_at') final  String? expiresAt;
@override@JsonKey(name: 'purge_after') final  String? purgeAfter;
@override@JsonKey(name: 'purged_at') final  String? purgedAt;
@override@JsonKey(name: 'created_at') final  String? createdAt;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerificationDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.documentType, documentType) || other.documentType == documentType)&&(identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.reviewedBy, reviewedBy) || other.reviewedBy == reviewedBy)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.purgeAfter, purgeAfter) || other.purgeAfter == purgeAfter)&&(identical(other.purgedAt, purgedAt) || other.purgedAt == purgedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,documentType,fileUrl,status,rejectionReason,reviewedBy,reviewedAt,expiresAt,purgeAfter,purgedAt,createdAt);

@override
String toString() {
  return 'VerificationDocument(id: $id, documentType: $documentType, fileUrl: $fileUrl, status: $status, rejectionReason: $rejectionReason, reviewedBy: $reviewedBy, reviewedAt: $reviewedAt, expiresAt: $expiresAt, purgeAfter: $purgeAfter, purgedAt: $purgedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$VerificationDocumentCopyWith<$Res> implements $VerificationDocumentCopyWith<$Res> {
  factory _$VerificationDocumentCopyWith(_VerificationDocument value, $Res Function(_VerificationDocument) _then) = __$VerificationDocumentCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'document_type') String documentType,@JsonKey(name: 'file_url') String fileUrl, String status,@JsonKey(name: 'rejection_reason') String rejectionReason,@JsonKey(name: 'reviewed_by') String? reviewedBy,@JsonKey(name: 'reviewed_at') String? reviewedAt,@JsonKey(name: 'expires_at') String? expiresAt,@JsonKey(name: 'purge_after') String? purgeAfter,@JsonKey(name: 'purged_at') String? purgedAt,@JsonKey(name: 'created_at') String? createdAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? documentType = null,Object? fileUrl = null,Object? status = null,Object? rejectionReason = null,Object? reviewedBy = freezed,Object? reviewedAt = freezed,Object? expiresAt = freezed,Object? purgeAfter = freezed,Object? purgedAt = freezed,Object? createdAt = freezed,}) {
  return _then(_VerificationDocument(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,documentType: null == documentType ? _self.documentType : documentType // ignore: cast_nullable_to_non_nullable
as String,fileUrl: null == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,rejectionReason: null == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String,reviewedBy: freezed == reviewedBy ? _self.reviewedBy : reviewedBy // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as String?,purgeAfter: freezed == purgeAfter ? _self.purgeAfter : purgeAfter // ignore: cast_nullable_to_non_nullable
as String?,purgedAt: freezed == purgedAt ? _self.purgedAt : purgedAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$VerificationApprovalState {

 String? get id;/// pending / approved / rejected.
 String get status;/// The decision that was *requested*: approve or reject.
 String? get decision;@JsonKey(name: 'required_scope') String get requiredScope;@JsonKey(name: 'requested_by_profile') String get requestedByProfile;@JsonKey(name: 'requested_at') String? get requestedAt;@JsonKey(name: 'decided_by') String? get decidedBy;@JsonKey(name: 'decided_at') String? get decidedAt;@JsonKey(name: 'decision_note') String get decisionNote;/// Null until the decide call actually applied the effect. A request
/// reading "approved" with no `applied_at` has not changed anything.
@JsonKey(name: 'applied_at') String? get appliedAt;
/// Create a copy of VerificationApprovalState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerificationApprovalStateCopyWith<VerificationApprovalState> get copyWith => _$VerificationApprovalStateCopyWithImpl<VerificationApprovalState>(this as VerificationApprovalState, _$identity);

  /// Serializes this VerificationApprovalState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerificationApprovalState&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.decision, decision) || other.decision == decision)&&(identical(other.requiredScope, requiredScope) || other.requiredScope == requiredScope)&&(identical(other.requestedByProfile, requestedByProfile) || other.requestedByProfile == requestedByProfile)&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt)&&(identical(other.decidedBy, decidedBy) || other.decidedBy == decidedBy)&&(identical(other.decidedAt, decidedAt) || other.decidedAt == decidedAt)&&(identical(other.decisionNote, decisionNote) || other.decisionNote == decisionNote)&&(identical(other.appliedAt, appliedAt) || other.appliedAt == appliedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,decision,requiredScope,requestedByProfile,requestedAt,decidedBy,decidedAt,decisionNote,appliedAt);

@override
String toString() {
  return 'VerificationApprovalState(id: $id, status: $status, decision: $decision, requiredScope: $requiredScope, requestedByProfile: $requestedByProfile, requestedAt: $requestedAt, decidedBy: $decidedBy, decidedAt: $decidedAt, decisionNote: $decisionNote, appliedAt: $appliedAt)';
}


}

/// @nodoc
abstract mixin class $VerificationApprovalStateCopyWith<$Res>  {
  factory $VerificationApprovalStateCopyWith(VerificationApprovalState value, $Res Function(VerificationApprovalState) _then) = _$VerificationApprovalStateCopyWithImpl;
@useResult
$Res call({
 String? id, String status, String? decision,@JsonKey(name: 'required_scope') String requiredScope,@JsonKey(name: 'requested_by_profile') String requestedByProfile,@JsonKey(name: 'requested_at') String? requestedAt,@JsonKey(name: 'decided_by') String? decidedBy,@JsonKey(name: 'decided_at') String? decidedAt,@JsonKey(name: 'decision_note') String decisionNote,@JsonKey(name: 'applied_at') String? appliedAt
});




}
/// @nodoc
class _$VerificationApprovalStateCopyWithImpl<$Res>
    implements $VerificationApprovalStateCopyWith<$Res> {
  _$VerificationApprovalStateCopyWithImpl(this._self, this._then);

  final VerificationApprovalState _self;
  final $Res Function(VerificationApprovalState) _then;

/// Create a copy of VerificationApprovalState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? status = null,Object? decision = freezed,Object? requiredScope = null,Object? requestedByProfile = null,Object? requestedAt = freezed,Object? decidedBy = freezed,Object? decidedAt = freezed,Object? decisionNote = null,Object? appliedAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,decision: freezed == decision ? _self.decision : decision // ignore: cast_nullable_to_non_nullable
as String?,requiredScope: null == requiredScope ? _self.requiredScope : requiredScope // ignore: cast_nullable_to_non_nullable
as String,requestedByProfile: null == requestedByProfile ? _self.requestedByProfile : requestedByProfile // ignore: cast_nullable_to_non_nullable
as String,requestedAt: freezed == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as String?,decidedBy: freezed == decidedBy ? _self.decidedBy : decidedBy // ignore: cast_nullable_to_non_nullable
as String?,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as String?,decisionNote: null == decisionNote ? _self.decisionNote : decisionNote // ignore: cast_nullable_to_non_nullable
as String,appliedAt: freezed == appliedAt ? _self.appliedAt : appliedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VerificationApprovalState].
extension VerificationApprovalStatePatterns on VerificationApprovalState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VerificationApprovalState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VerificationApprovalState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VerificationApprovalState value)  $default,){
final _that = this;
switch (_that) {
case _VerificationApprovalState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VerificationApprovalState value)?  $default,){
final _that = this;
switch (_that) {
case _VerificationApprovalState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String status,  String? decision, @JsonKey(name: 'required_scope')  String requiredScope, @JsonKey(name: 'requested_by_profile')  String requestedByProfile, @JsonKey(name: 'requested_at')  String? requestedAt, @JsonKey(name: 'decided_by')  String? decidedBy, @JsonKey(name: 'decided_at')  String? decidedAt, @JsonKey(name: 'decision_note')  String decisionNote, @JsonKey(name: 'applied_at')  String? appliedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VerificationApprovalState() when $default != null:
return $default(_that.id,_that.status,_that.decision,_that.requiredScope,_that.requestedByProfile,_that.requestedAt,_that.decidedBy,_that.decidedAt,_that.decisionNote,_that.appliedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String status,  String? decision, @JsonKey(name: 'required_scope')  String requiredScope, @JsonKey(name: 'requested_by_profile')  String requestedByProfile, @JsonKey(name: 'requested_at')  String? requestedAt, @JsonKey(name: 'decided_by')  String? decidedBy, @JsonKey(name: 'decided_at')  String? decidedAt, @JsonKey(name: 'decision_note')  String decisionNote, @JsonKey(name: 'applied_at')  String? appliedAt)  $default,) {final _that = this;
switch (_that) {
case _VerificationApprovalState():
return $default(_that.id,_that.status,_that.decision,_that.requiredScope,_that.requestedByProfile,_that.requestedAt,_that.decidedBy,_that.decidedAt,_that.decisionNote,_that.appliedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String status,  String? decision, @JsonKey(name: 'required_scope')  String requiredScope, @JsonKey(name: 'requested_by_profile')  String requestedByProfile, @JsonKey(name: 'requested_at')  String? requestedAt, @JsonKey(name: 'decided_by')  String? decidedBy, @JsonKey(name: 'decided_at')  String? decidedAt, @JsonKey(name: 'decision_note')  String decisionNote, @JsonKey(name: 'applied_at')  String? appliedAt)?  $default,) {final _that = this;
switch (_that) {
case _VerificationApprovalState() when $default != null:
return $default(_that.id,_that.status,_that.decision,_that.requiredScope,_that.requestedByProfile,_that.requestedAt,_that.decidedBy,_that.decidedAt,_that.decisionNote,_that.appliedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VerificationApprovalState implements VerificationApprovalState {
  const _VerificationApprovalState({this.id, this.status = '', this.decision, @JsonKey(name: 'required_scope') this.requiredScope = '', @JsonKey(name: 'requested_by_profile') this.requestedByProfile = '', @JsonKey(name: 'requested_at') this.requestedAt, @JsonKey(name: 'decided_by') this.decidedBy, @JsonKey(name: 'decided_at') this.decidedAt, @JsonKey(name: 'decision_note') this.decisionNote = '', @JsonKey(name: 'applied_at') this.appliedAt});
  factory _VerificationApprovalState.fromJson(Map<String, dynamic> json) => _$VerificationApprovalStateFromJson(json);

@override final  String? id;
/// pending / approved / rejected.
@override@JsonKey() final  String status;
/// The decision that was *requested*: approve or reject.
@override final  String? decision;
@override@JsonKey(name: 'required_scope') final  String requiredScope;
@override@JsonKey(name: 'requested_by_profile') final  String requestedByProfile;
@override@JsonKey(name: 'requested_at') final  String? requestedAt;
@override@JsonKey(name: 'decided_by') final  String? decidedBy;
@override@JsonKey(name: 'decided_at') final  String? decidedAt;
@override@JsonKey(name: 'decision_note') final  String decisionNote;
/// Null until the decide call actually applied the effect. A request
/// reading "approved" with no `applied_at` has not changed anything.
@override@JsonKey(name: 'applied_at') final  String? appliedAt;

/// Create a copy of VerificationApprovalState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerificationApprovalStateCopyWith<_VerificationApprovalState> get copyWith => __$VerificationApprovalStateCopyWithImpl<_VerificationApprovalState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VerificationApprovalStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerificationApprovalState&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.decision, decision) || other.decision == decision)&&(identical(other.requiredScope, requiredScope) || other.requiredScope == requiredScope)&&(identical(other.requestedByProfile, requestedByProfile) || other.requestedByProfile == requestedByProfile)&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt)&&(identical(other.decidedBy, decidedBy) || other.decidedBy == decidedBy)&&(identical(other.decidedAt, decidedAt) || other.decidedAt == decidedAt)&&(identical(other.decisionNote, decisionNote) || other.decisionNote == decisionNote)&&(identical(other.appliedAt, appliedAt) || other.appliedAt == appliedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,decision,requiredScope,requestedByProfile,requestedAt,decidedBy,decidedAt,decisionNote,appliedAt);

@override
String toString() {
  return 'VerificationApprovalState(id: $id, status: $status, decision: $decision, requiredScope: $requiredScope, requestedByProfile: $requestedByProfile, requestedAt: $requestedAt, decidedBy: $decidedBy, decidedAt: $decidedAt, decisionNote: $decisionNote, appliedAt: $appliedAt)';
}


}

/// @nodoc
abstract mixin class _$VerificationApprovalStateCopyWith<$Res> implements $VerificationApprovalStateCopyWith<$Res> {
  factory _$VerificationApprovalStateCopyWith(_VerificationApprovalState value, $Res Function(_VerificationApprovalState) _then) = __$VerificationApprovalStateCopyWithImpl;
@override @useResult
$Res call({
 String? id, String status, String? decision,@JsonKey(name: 'required_scope') String requiredScope,@JsonKey(name: 'requested_by_profile') String requestedByProfile,@JsonKey(name: 'requested_at') String? requestedAt,@JsonKey(name: 'decided_by') String? decidedBy,@JsonKey(name: 'decided_at') String? decidedAt,@JsonKey(name: 'decision_note') String decisionNote,@JsonKey(name: 'applied_at') String? appliedAt
});




}
/// @nodoc
class __$VerificationApprovalStateCopyWithImpl<$Res>
    implements _$VerificationApprovalStateCopyWith<$Res> {
  __$VerificationApprovalStateCopyWithImpl(this._self, this._then);

  final _VerificationApprovalState _self;
  final $Res Function(_VerificationApprovalState) _then;

/// Create a copy of VerificationApprovalState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? status = null,Object? decision = freezed,Object? requiredScope = null,Object? requestedByProfile = null,Object? requestedAt = freezed,Object? decidedBy = freezed,Object? decidedAt = freezed,Object? decisionNote = null,Object? appliedAt = freezed,}) {
  return _then(_VerificationApprovalState(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,decision: freezed == decision ? _self.decision : decision // ignore: cast_nullable_to_non_nullable
as String?,requiredScope: null == requiredScope ? _self.requiredScope : requiredScope // ignore: cast_nullable_to_non_nullable
as String,requestedByProfile: null == requestedByProfile ? _self.requestedByProfile : requestedByProfile // ignore: cast_nullable_to_non_nullable
as String,requestedAt: freezed == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as String?,decidedBy: freezed == decidedBy ? _self.decidedBy : decidedBy // ignore: cast_nullable_to_non_nullable
as String?,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as String?,decisionNote: null == decisionNote ? _self.decisionNote : decisionNote // ignore: cast_nullable_to_non_nullable
as String,appliedAt: freezed == appliedAt ? _self.appliedAt : appliedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$VerificationApprovalRequest {

 String? get id; String get status;@JsonKey(name: 'requested_by_profile') String get requestedByProfile;@JsonKey(name: 'required_scope') String get requiredScope;@JsonKey(name: 'created_at') String? get createdAt;
/// Create a copy of VerificationApprovalRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerificationApprovalRequestCopyWith<VerificationApprovalRequest> get copyWith => _$VerificationApprovalRequestCopyWithImpl<VerificationApprovalRequest>(this as VerificationApprovalRequest, _$identity);

  /// Serializes this VerificationApprovalRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerificationApprovalRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.requestedByProfile, requestedByProfile) || other.requestedByProfile == requestedByProfile)&&(identical(other.requiredScope, requiredScope) || other.requiredScope == requiredScope)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,requestedByProfile,requiredScope,createdAt);

@override
String toString() {
  return 'VerificationApprovalRequest(id: $id, status: $status, requestedByProfile: $requestedByProfile, requiredScope: $requiredScope, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $VerificationApprovalRequestCopyWith<$Res>  {
  factory $VerificationApprovalRequestCopyWith(VerificationApprovalRequest value, $Res Function(VerificationApprovalRequest) _then) = _$VerificationApprovalRequestCopyWithImpl;
@useResult
$Res call({
 String? id, String status,@JsonKey(name: 'requested_by_profile') String requestedByProfile,@JsonKey(name: 'required_scope') String requiredScope,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class _$VerificationApprovalRequestCopyWithImpl<$Res>
    implements $VerificationApprovalRequestCopyWith<$Res> {
  _$VerificationApprovalRequestCopyWithImpl(this._self, this._then);

  final VerificationApprovalRequest _self;
  final $Res Function(VerificationApprovalRequest) _then;

/// Create a copy of VerificationApprovalRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? status = null,Object? requestedByProfile = null,Object? requiredScope = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,requestedByProfile: null == requestedByProfile ? _self.requestedByProfile : requestedByProfile // ignore: cast_nullable_to_non_nullable
as String,requiredScope: null == requiredScope ? _self.requiredScope : requiredScope // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VerificationApprovalRequest].
extension VerificationApprovalRequestPatterns on VerificationApprovalRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VerificationApprovalRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VerificationApprovalRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VerificationApprovalRequest value)  $default,){
final _that = this;
switch (_that) {
case _VerificationApprovalRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VerificationApprovalRequest value)?  $default,){
final _that = this;
switch (_that) {
case _VerificationApprovalRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String status, @JsonKey(name: 'requested_by_profile')  String requestedByProfile, @JsonKey(name: 'required_scope')  String requiredScope, @JsonKey(name: 'created_at')  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VerificationApprovalRequest() when $default != null:
return $default(_that.id,_that.status,_that.requestedByProfile,_that.requiredScope,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String status, @JsonKey(name: 'requested_by_profile')  String requestedByProfile, @JsonKey(name: 'required_scope')  String requiredScope, @JsonKey(name: 'created_at')  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _VerificationApprovalRequest():
return $default(_that.id,_that.status,_that.requestedByProfile,_that.requiredScope,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String status, @JsonKey(name: 'requested_by_profile')  String requestedByProfile, @JsonKey(name: 'required_scope')  String requiredScope, @JsonKey(name: 'created_at')  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _VerificationApprovalRequest() when $default != null:
return $default(_that.id,_that.status,_that.requestedByProfile,_that.requiredScope,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VerificationApprovalRequest implements VerificationApprovalRequest {
  const _VerificationApprovalRequest({this.id, this.status = '', @JsonKey(name: 'requested_by_profile') this.requestedByProfile = '', @JsonKey(name: 'required_scope') this.requiredScope = '', @JsonKey(name: 'created_at') this.createdAt});
  factory _VerificationApprovalRequest.fromJson(Map<String, dynamic> json) => _$VerificationApprovalRequestFromJson(json);

@override final  String? id;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'requested_by_profile') final  String requestedByProfile;
@override@JsonKey(name: 'required_scope') final  String requiredScope;
@override@JsonKey(name: 'created_at') final  String? createdAt;

/// Create a copy of VerificationApprovalRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerificationApprovalRequestCopyWith<_VerificationApprovalRequest> get copyWith => __$VerificationApprovalRequestCopyWithImpl<_VerificationApprovalRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VerificationApprovalRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerificationApprovalRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.requestedByProfile, requestedByProfile) || other.requestedByProfile == requestedByProfile)&&(identical(other.requiredScope, requiredScope) || other.requiredScope == requiredScope)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,requestedByProfile,requiredScope,createdAt);

@override
String toString() {
  return 'VerificationApprovalRequest(id: $id, status: $status, requestedByProfile: $requestedByProfile, requiredScope: $requiredScope, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$VerificationApprovalRequestCopyWith<$Res> implements $VerificationApprovalRequestCopyWith<$Res> {
  factory _$VerificationApprovalRequestCopyWith(_VerificationApprovalRequest value, $Res Function(_VerificationApprovalRequest) _then) = __$VerificationApprovalRequestCopyWithImpl;
@override @useResult
$Res call({
 String? id, String status,@JsonKey(name: 'requested_by_profile') String requestedByProfile,@JsonKey(name: 'required_scope') String requiredScope,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class __$VerificationApprovalRequestCopyWithImpl<$Res>
    implements _$VerificationApprovalRequestCopyWith<$Res> {
  __$VerificationApprovalRequestCopyWithImpl(this._self, this._then);

  final _VerificationApprovalRequest _self;
  final $Res Function(_VerificationApprovalRequest) _then;

/// Create a copy of VerificationApprovalRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? status = null,Object? requestedByProfile = null,Object? requiredScope = null,Object? createdAt = freezed,}) {
  return _then(_VerificationApprovalRequest(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,requestedByProfile: null == requestedByProfile ? _self.requestedByProfile : requestedByProfile // ignore: cast_nullable_to_non_nullable
as String,requiredScope: null == requiredScope ? _self.requiredScope : requiredScope // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$VerificationDecisionOutcome {

 String? get id; String get status;@JsonKey(name: 'decision_note') String get decisionNote;@JsonKey(name: 'decided_by') String? get decidedBy;@JsonKey(name: 'decided_at') String? get decidedAt;@JsonKey(name: 'applied_at') String? get appliedAt;/// Server prose: "The trainer application was approved."
 String get effect;
/// Create a copy of VerificationDecisionOutcome
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerificationDecisionOutcomeCopyWith<VerificationDecisionOutcome> get copyWith => _$VerificationDecisionOutcomeCopyWithImpl<VerificationDecisionOutcome>(this as VerificationDecisionOutcome, _$identity);

  /// Serializes this VerificationDecisionOutcome to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerificationDecisionOutcome&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.decisionNote, decisionNote) || other.decisionNote == decisionNote)&&(identical(other.decidedBy, decidedBy) || other.decidedBy == decidedBy)&&(identical(other.decidedAt, decidedAt) || other.decidedAt == decidedAt)&&(identical(other.appliedAt, appliedAt) || other.appliedAt == appliedAt)&&(identical(other.effect, effect) || other.effect == effect));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,decisionNote,decidedBy,decidedAt,appliedAt,effect);

@override
String toString() {
  return 'VerificationDecisionOutcome(id: $id, status: $status, decisionNote: $decisionNote, decidedBy: $decidedBy, decidedAt: $decidedAt, appliedAt: $appliedAt, effect: $effect)';
}


}

/// @nodoc
abstract mixin class $VerificationDecisionOutcomeCopyWith<$Res>  {
  factory $VerificationDecisionOutcomeCopyWith(VerificationDecisionOutcome value, $Res Function(VerificationDecisionOutcome) _then) = _$VerificationDecisionOutcomeCopyWithImpl;
@useResult
$Res call({
 String? id, String status,@JsonKey(name: 'decision_note') String decisionNote,@JsonKey(name: 'decided_by') String? decidedBy,@JsonKey(name: 'decided_at') String? decidedAt,@JsonKey(name: 'applied_at') String? appliedAt, String effect
});




}
/// @nodoc
class _$VerificationDecisionOutcomeCopyWithImpl<$Res>
    implements $VerificationDecisionOutcomeCopyWith<$Res> {
  _$VerificationDecisionOutcomeCopyWithImpl(this._self, this._then);

  final VerificationDecisionOutcome _self;
  final $Res Function(VerificationDecisionOutcome) _then;

/// Create a copy of VerificationDecisionOutcome
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? status = null,Object? decisionNote = null,Object? decidedBy = freezed,Object? decidedAt = freezed,Object? appliedAt = freezed,Object? effect = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,decisionNote: null == decisionNote ? _self.decisionNote : decisionNote // ignore: cast_nullable_to_non_nullable
as String,decidedBy: freezed == decidedBy ? _self.decidedBy : decidedBy // ignore: cast_nullable_to_non_nullable
as String?,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as String?,appliedAt: freezed == appliedAt ? _self.appliedAt : appliedAt // ignore: cast_nullable_to_non_nullable
as String?,effect: null == effect ? _self.effect : effect // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [VerificationDecisionOutcome].
extension VerificationDecisionOutcomePatterns on VerificationDecisionOutcome {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VerificationDecisionOutcome value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VerificationDecisionOutcome() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VerificationDecisionOutcome value)  $default,){
final _that = this;
switch (_that) {
case _VerificationDecisionOutcome():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VerificationDecisionOutcome value)?  $default,){
final _that = this;
switch (_that) {
case _VerificationDecisionOutcome() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String status, @JsonKey(name: 'decision_note')  String decisionNote, @JsonKey(name: 'decided_by')  String? decidedBy, @JsonKey(name: 'decided_at')  String? decidedAt, @JsonKey(name: 'applied_at')  String? appliedAt,  String effect)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VerificationDecisionOutcome() when $default != null:
return $default(_that.id,_that.status,_that.decisionNote,_that.decidedBy,_that.decidedAt,_that.appliedAt,_that.effect);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String status, @JsonKey(name: 'decision_note')  String decisionNote, @JsonKey(name: 'decided_by')  String? decidedBy, @JsonKey(name: 'decided_at')  String? decidedAt, @JsonKey(name: 'applied_at')  String? appliedAt,  String effect)  $default,) {final _that = this;
switch (_that) {
case _VerificationDecisionOutcome():
return $default(_that.id,_that.status,_that.decisionNote,_that.decidedBy,_that.decidedAt,_that.appliedAt,_that.effect);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String status, @JsonKey(name: 'decision_note')  String decisionNote, @JsonKey(name: 'decided_by')  String? decidedBy, @JsonKey(name: 'decided_at')  String? decidedAt, @JsonKey(name: 'applied_at')  String? appliedAt,  String effect)?  $default,) {final _that = this;
switch (_that) {
case _VerificationDecisionOutcome() when $default != null:
return $default(_that.id,_that.status,_that.decisionNote,_that.decidedBy,_that.decidedAt,_that.appliedAt,_that.effect);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VerificationDecisionOutcome implements VerificationDecisionOutcome {
  const _VerificationDecisionOutcome({this.id, this.status = '', @JsonKey(name: 'decision_note') this.decisionNote = '', @JsonKey(name: 'decided_by') this.decidedBy, @JsonKey(name: 'decided_at') this.decidedAt, @JsonKey(name: 'applied_at') this.appliedAt, this.effect = ''});
  factory _VerificationDecisionOutcome.fromJson(Map<String, dynamic> json) => _$VerificationDecisionOutcomeFromJson(json);

@override final  String? id;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'decision_note') final  String decisionNote;
@override@JsonKey(name: 'decided_by') final  String? decidedBy;
@override@JsonKey(name: 'decided_at') final  String? decidedAt;
@override@JsonKey(name: 'applied_at') final  String? appliedAt;
/// Server prose: "The trainer application was approved."
@override@JsonKey() final  String effect;

/// Create a copy of VerificationDecisionOutcome
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerificationDecisionOutcomeCopyWith<_VerificationDecisionOutcome> get copyWith => __$VerificationDecisionOutcomeCopyWithImpl<_VerificationDecisionOutcome>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VerificationDecisionOutcomeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerificationDecisionOutcome&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.decisionNote, decisionNote) || other.decisionNote == decisionNote)&&(identical(other.decidedBy, decidedBy) || other.decidedBy == decidedBy)&&(identical(other.decidedAt, decidedAt) || other.decidedAt == decidedAt)&&(identical(other.appliedAt, appliedAt) || other.appliedAt == appliedAt)&&(identical(other.effect, effect) || other.effect == effect));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,decisionNote,decidedBy,decidedAt,appliedAt,effect);

@override
String toString() {
  return 'VerificationDecisionOutcome(id: $id, status: $status, decisionNote: $decisionNote, decidedBy: $decidedBy, decidedAt: $decidedAt, appliedAt: $appliedAt, effect: $effect)';
}


}

/// @nodoc
abstract mixin class _$VerificationDecisionOutcomeCopyWith<$Res> implements $VerificationDecisionOutcomeCopyWith<$Res> {
  factory _$VerificationDecisionOutcomeCopyWith(_VerificationDecisionOutcome value, $Res Function(_VerificationDecisionOutcome) _then) = __$VerificationDecisionOutcomeCopyWithImpl;
@override @useResult
$Res call({
 String? id, String status,@JsonKey(name: 'decision_note') String decisionNote,@JsonKey(name: 'decided_by') String? decidedBy,@JsonKey(name: 'decided_at') String? decidedAt,@JsonKey(name: 'applied_at') String? appliedAt, String effect
});




}
/// @nodoc
class __$VerificationDecisionOutcomeCopyWithImpl<$Res>
    implements _$VerificationDecisionOutcomeCopyWith<$Res> {
  __$VerificationDecisionOutcomeCopyWithImpl(this._self, this._then);

  final _VerificationDecisionOutcome _self;
  final $Res Function(_VerificationDecisionOutcome) _then;

/// Create a copy of VerificationDecisionOutcome
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? status = null,Object? decisionNote = null,Object? decidedBy = freezed,Object? decidedAt = freezed,Object? appliedAt = freezed,Object? effect = null,}) {
  return _then(_VerificationDecisionOutcome(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,decisionNote: null == decisionNote ? _self.decisionNote : decisionNote // ignore: cast_nullable_to_non_nullable
as String,decidedBy: freezed == decidedBy ? _self.decidedBy : decidedBy // ignore: cast_nullable_to_non_nullable
as String?,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as String?,appliedAt: freezed == appliedAt ? _self.appliedAt : appliedAt // ignore: cast_nullable_to_non_nullable
as String?,effect: null == effect ? _self.effect : effect // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$VerificationSubmission {

 String get id; String? get profile;@JsonKey(name: 'verification_type') String get verificationType; String get status; List<VerificationDocument> get documents; String get notes; String? get gym;@JsonKey(name: 'gym_name') String? get gymName;@JsonKey(name: 'reviewed_by') String? get reviewedBy;@JsonKey(name: 'reviewed_at') String? get reviewedAt;@JsonKey(name: 'submitted_at') String? get submittedAt;@JsonKey(name: 'created_at') String? get createdAt;@JsonKey(name: 'current_step') String get currentStep;@JsonKey(name: 'completed_steps', fromJson: _stringList) List<String> get completedSteps;@JsonKey(name: 'face_match_status') String get faceMatchStatus;@JsonKey(name: 'face_match_score', fromJson: _optionalDouble) double? get faceMatchScore;@JsonKey(name: 'credential_title') String get credentialTitle;@JsonKey(name: 'credential_issuer') String get credentialIssuer;@JsonKey(name: 'credential_id') String get credentialId;@JsonKey(name: 'issued_date') String? get issuedDate;@JsonKey(name: 'scope_of_practice') String get scopeOfPractice;@JsonKey(name: 'approval_state') VerificationApprovalState? get approvalState;/// Non-null exactly while a second approver is still owed.
@JsonKey(name: 'pending_approval') VerificationApprovalState? get pendingApproval;
/// Create a copy of VerificationSubmission
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerificationSubmissionCopyWith<VerificationSubmission> get copyWith => _$VerificationSubmissionCopyWithImpl<VerificationSubmission>(this as VerificationSubmission, _$identity);

  /// Serializes this VerificationSubmission to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerificationSubmission&&(identical(other.id, id) || other.id == id)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.verificationType, verificationType) || other.verificationType == verificationType)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.documents, documents)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.gym, gym) || other.gym == gym)&&(identical(other.gymName, gymName) || other.gymName == gymName)&&(identical(other.reviewedBy, reviewedBy) || other.reviewedBy == reviewedBy)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&const DeepCollectionEquality().equals(other.completedSteps, completedSteps)&&(identical(other.faceMatchStatus, faceMatchStatus) || other.faceMatchStatus == faceMatchStatus)&&(identical(other.faceMatchScore, faceMatchScore) || other.faceMatchScore == faceMatchScore)&&(identical(other.credentialTitle, credentialTitle) || other.credentialTitle == credentialTitle)&&(identical(other.credentialIssuer, credentialIssuer) || other.credentialIssuer == credentialIssuer)&&(identical(other.credentialId, credentialId) || other.credentialId == credentialId)&&(identical(other.issuedDate, issuedDate) || other.issuedDate == issuedDate)&&(identical(other.scopeOfPractice, scopeOfPractice) || other.scopeOfPractice == scopeOfPractice)&&(identical(other.approvalState, approvalState) || other.approvalState == approvalState)&&(identical(other.pendingApproval, pendingApproval) || other.pendingApproval == pendingApproval));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,profile,verificationType,status,const DeepCollectionEquality().hash(documents),notes,gym,gymName,reviewedBy,reviewedAt,submittedAt,createdAt,currentStep,const DeepCollectionEquality().hash(completedSteps),faceMatchStatus,faceMatchScore,credentialTitle,credentialIssuer,credentialId,issuedDate,scopeOfPractice,approvalState,pendingApproval]);

@override
String toString() {
  return 'VerificationSubmission(id: $id, profile: $profile, verificationType: $verificationType, status: $status, documents: $documents, notes: $notes, gym: $gym, gymName: $gymName, reviewedBy: $reviewedBy, reviewedAt: $reviewedAt, submittedAt: $submittedAt, createdAt: $createdAt, currentStep: $currentStep, completedSteps: $completedSteps, faceMatchStatus: $faceMatchStatus, faceMatchScore: $faceMatchScore, credentialTitle: $credentialTitle, credentialIssuer: $credentialIssuer, credentialId: $credentialId, issuedDate: $issuedDate, scopeOfPractice: $scopeOfPractice, approvalState: $approvalState, pendingApproval: $pendingApproval)';
}


}

/// @nodoc
abstract mixin class $VerificationSubmissionCopyWith<$Res>  {
  factory $VerificationSubmissionCopyWith(VerificationSubmission value, $Res Function(VerificationSubmission) _then) = _$VerificationSubmissionCopyWithImpl;
@useResult
$Res call({
 String id, String? profile,@JsonKey(name: 'verification_type') String verificationType, String status, List<VerificationDocument> documents, String notes, String? gym,@JsonKey(name: 'gym_name') String? gymName,@JsonKey(name: 'reviewed_by') String? reviewedBy,@JsonKey(name: 'reviewed_at') String? reviewedAt,@JsonKey(name: 'submitted_at') String? submittedAt,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'current_step') String currentStep,@JsonKey(name: 'completed_steps', fromJson: _stringList) List<String> completedSteps,@JsonKey(name: 'face_match_status') String faceMatchStatus,@JsonKey(name: 'face_match_score', fromJson: _optionalDouble) double? faceMatchScore,@JsonKey(name: 'credential_title') String credentialTitle,@JsonKey(name: 'credential_issuer') String credentialIssuer,@JsonKey(name: 'credential_id') String credentialId,@JsonKey(name: 'issued_date') String? issuedDate,@JsonKey(name: 'scope_of_practice') String scopeOfPractice,@JsonKey(name: 'approval_state') VerificationApprovalState? approvalState,@JsonKey(name: 'pending_approval') VerificationApprovalState? pendingApproval
});


$VerificationApprovalStateCopyWith<$Res>? get approvalState;$VerificationApprovalStateCopyWith<$Res>? get pendingApproval;

}
/// @nodoc
class _$VerificationSubmissionCopyWithImpl<$Res>
    implements $VerificationSubmissionCopyWith<$Res> {
  _$VerificationSubmissionCopyWithImpl(this._self, this._then);

  final VerificationSubmission _self;
  final $Res Function(VerificationSubmission) _then;

/// Create a copy of VerificationSubmission
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? profile = freezed,Object? verificationType = null,Object? status = null,Object? documents = null,Object? notes = null,Object? gym = freezed,Object? gymName = freezed,Object? reviewedBy = freezed,Object? reviewedAt = freezed,Object? submittedAt = freezed,Object? createdAt = freezed,Object? currentStep = null,Object? completedSteps = null,Object? faceMatchStatus = null,Object? faceMatchScore = freezed,Object? credentialTitle = null,Object? credentialIssuer = null,Object? credentialId = null,Object? issuedDate = freezed,Object? scopeOfPractice = null,Object? approvalState = freezed,Object? pendingApproval = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as String?,verificationType: null == verificationType ? _self.verificationType : verificationType // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,documents: null == documents ? _self.documents : documents // ignore: cast_nullable_to_non_nullable
as List<VerificationDocument>,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,gym: freezed == gym ? _self.gym : gym // ignore: cast_nullable_to_non_nullable
as String?,gymName: freezed == gymName ? _self.gymName : gymName // ignore: cast_nullable_to_non_nullable
as String?,reviewedBy: freezed == reviewedBy ? _self.reviewedBy : reviewedBy // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as String,completedSteps: null == completedSteps ? _self.completedSteps : completedSteps // ignore: cast_nullable_to_non_nullable
as List<String>,faceMatchStatus: null == faceMatchStatus ? _self.faceMatchStatus : faceMatchStatus // ignore: cast_nullable_to_non_nullable
as String,faceMatchScore: freezed == faceMatchScore ? _self.faceMatchScore : faceMatchScore // ignore: cast_nullable_to_non_nullable
as double?,credentialTitle: null == credentialTitle ? _self.credentialTitle : credentialTitle // ignore: cast_nullable_to_non_nullable
as String,credentialIssuer: null == credentialIssuer ? _self.credentialIssuer : credentialIssuer // ignore: cast_nullable_to_non_nullable
as String,credentialId: null == credentialId ? _self.credentialId : credentialId // ignore: cast_nullable_to_non_nullable
as String,issuedDate: freezed == issuedDate ? _self.issuedDate : issuedDate // ignore: cast_nullable_to_non_nullable
as String?,scopeOfPractice: null == scopeOfPractice ? _self.scopeOfPractice : scopeOfPractice // ignore: cast_nullable_to_non_nullable
as String,approvalState: freezed == approvalState ? _self.approvalState : approvalState // ignore: cast_nullable_to_non_nullable
as VerificationApprovalState?,pendingApproval: freezed == pendingApproval ? _self.pendingApproval : pendingApproval // ignore: cast_nullable_to_non_nullable
as VerificationApprovalState?,
  ));
}
/// Create a copy of VerificationSubmission
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VerificationApprovalStateCopyWith<$Res>? get approvalState {
    if (_self.approvalState == null) {
    return null;
  }

  return $VerificationApprovalStateCopyWith<$Res>(_self.approvalState!, (value) {
    return _then(_self.copyWith(approvalState: value));
  });
}/// Create a copy of VerificationSubmission
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VerificationApprovalStateCopyWith<$Res>? get pendingApproval {
    if (_self.pendingApproval == null) {
    return null;
  }

  return $VerificationApprovalStateCopyWith<$Res>(_self.pendingApproval!, (value) {
    return _then(_self.copyWith(pendingApproval: value));
  });
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? profile, @JsonKey(name: 'verification_type')  String verificationType,  String status,  List<VerificationDocument> documents,  String notes,  String? gym, @JsonKey(name: 'gym_name')  String? gymName, @JsonKey(name: 'reviewed_by')  String? reviewedBy, @JsonKey(name: 'reviewed_at')  String? reviewedAt, @JsonKey(name: 'submitted_at')  String? submittedAt, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'current_step')  String currentStep, @JsonKey(name: 'completed_steps', fromJson: _stringList)  List<String> completedSteps, @JsonKey(name: 'face_match_status')  String faceMatchStatus, @JsonKey(name: 'face_match_score', fromJson: _optionalDouble)  double? faceMatchScore, @JsonKey(name: 'credential_title')  String credentialTitle, @JsonKey(name: 'credential_issuer')  String credentialIssuer, @JsonKey(name: 'credential_id')  String credentialId, @JsonKey(name: 'issued_date')  String? issuedDate, @JsonKey(name: 'scope_of_practice')  String scopeOfPractice, @JsonKey(name: 'approval_state')  VerificationApprovalState? approvalState, @JsonKey(name: 'pending_approval')  VerificationApprovalState? pendingApproval)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VerificationSubmission() when $default != null:
return $default(_that.id,_that.profile,_that.verificationType,_that.status,_that.documents,_that.notes,_that.gym,_that.gymName,_that.reviewedBy,_that.reviewedAt,_that.submittedAt,_that.createdAt,_that.currentStep,_that.completedSteps,_that.faceMatchStatus,_that.faceMatchScore,_that.credentialTitle,_that.credentialIssuer,_that.credentialId,_that.issuedDate,_that.scopeOfPractice,_that.approvalState,_that.pendingApproval);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? profile, @JsonKey(name: 'verification_type')  String verificationType,  String status,  List<VerificationDocument> documents,  String notes,  String? gym, @JsonKey(name: 'gym_name')  String? gymName, @JsonKey(name: 'reviewed_by')  String? reviewedBy, @JsonKey(name: 'reviewed_at')  String? reviewedAt, @JsonKey(name: 'submitted_at')  String? submittedAt, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'current_step')  String currentStep, @JsonKey(name: 'completed_steps', fromJson: _stringList)  List<String> completedSteps, @JsonKey(name: 'face_match_status')  String faceMatchStatus, @JsonKey(name: 'face_match_score', fromJson: _optionalDouble)  double? faceMatchScore, @JsonKey(name: 'credential_title')  String credentialTitle, @JsonKey(name: 'credential_issuer')  String credentialIssuer, @JsonKey(name: 'credential_id')  String credentialId, @JsonKey(name: 'issued_date')  String? issuedDate, @JsonKey(name: 'scope_of_practice')  String scopeOfPractice, @JsonKey(name: 'approval_state')  VerificationApprovalState? approvalState, @JsonKey(name: 'pending_approval')  VerificationApprovalState? pendingApproval)  $default,) {final _that = this;
switch (_that) {
case _VerificationSubmission():
return $default(_that.id,_that.profile,_that.verificationType,_that.status,_that.documents,_that.notes,_that.gym,_that.gymName,_that.reviewedBy,_that.reviewedAt,_that.submittedAt,_that.createdAt,_that.currentStep,_that.completedSteps,_that.faceMatchStatus,_that.faceMatchScore,_that.credentialTitle,_that.credentialIssuer,_that.credentialId,_that.issuedDate,_that.scopeOfPractice,_that.approvalState,_that.pendingApproval);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? profile, @JsonKey(name: 'verification_type')  String verificationType,  String status,  List<VerificationDocument> documents,  String notes,  String? gym, @JsonKey(name: 'gym_name')  String? gymName, @JsonKey(name: 'reviewed_by')  String? reviewedBy, @JsonKey(name: 'reviewed_at')  String? reviewedAt, @JsonKey(name: 'submitted_at')  String? submittedAt, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'current_step')  String currentStep, @JsonKey(name: 'completed_steps', fromJson: _stringList)  List<String> completedSteps, @JsonKey(name: 'face_match_status')  String faceMatchStatus, @JsonKey(name: 'face_match_score', fromJson: _optionalDouble)  double? faceMatchScore, @JsonKey(name: 'credential_title')  String credentialTitle, @JsonKey(name: 'credential_issuer')  String credentialIssuer, @JsonKey(name: 'credential_id')  String credentialId, @JsonKey(name: 'issued_date')  String? issuedDate, @JsonKey(name: 'scope_of_practice')  String scopeOfPractice, @JsonKey(name: 'approval_state')  VerificationApprovalState? approvalState, @JsonKey(name: 'pending_approval')  VerificationApprovalState? pendingApproval)?  $default,) {final _that = this;
switch (_that) {
case _VerificationSubmission() when $default != null:
return $default(_that.id,_that.profile,_that.verificationType,_that.status,_that.documents,_that.notes,_that.gym,_that.gymName,_that.reviewedBy,_that.reviewedAt,_that.submittedAt,_that.createdAt,_that.currentStep,_that.completedSteps,_that.faceMatchStatus,_that.faceMatchScore,_that.credentialTitle,_that.credentialIssuer,_that.credentialId,_that.issuedDate,_that.scopeOfPractice,_that.approvalState,_that.pendingApproval);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VerificationSubmission implements VerificationSubmission {
  const _VerificationSubmission({this.id = '', this.profile, @JsonKey(name: 'verification_type') this.verificationType = '', this.status = 'draft', final  List<VerificationDocument> documents = const <VerificationDocument>[], this.notes = '', this.gym, @JsonKey(name: 'gym_name') this.gymName, @JsonKey(name: 'reviewed_by') this.reviewedBy, @JsonKey(name: 'reviewed_at') this.reviewedAt, @JsonKey(name: 'submitted_at') this.submittedAt, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'current_step') this.currentStep = '', @JsonKey(name: 'completed_steps', fromJson: _stringList) final  List<String> completedSteps = const <String>[], @JsonKey(name: 'face_match_status') this.faceMatchStatus = 'pending', @JsonKey(name: 'face_match_score', fromJson: _optionalDouble) this.faceMatchScore, @JsonKey(name: 'credential_title') this.credentialTitle = '', @JsonKey(name: 'credential_issuer') this.credentialIssuer = '', @JsonKey(name: 'credential_id') this.credentialId = '', @JsonKey(name: 'issued_date') this.issuedDate, @JsonKey(name: 'scope_of_practice') this.scopeOfPractice = '', @JsonKey(name: 'approval_state') this.approvalState, @JsonKey(name: 'pending_approval') this.pendingApproval}): _documents = documents,_completedSteps = completedSteps;
  factory _VerificationSubmission.fromJson(Map<String, dynamic> json) => _$VerificationSubmissionFromJson(json);

@override@JsonKey() final  String id;
@override final  String? profile;
@override@JsonKey(name: 'verification_type') final  String verificationType;
@override@JsonKey() final  String status;
 final  List<VerificationDocument> _documents;
@override@JsonKey() List<VerificationDocument> get documents {
  if (_documents is EqualUnmodifiableListView) return _documents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_documents);
}

@override@JsonKey() final  String notes;
@override final  String? gym;
@override@JsonKey(name: 'gym_name') final  String? gymName;
@override@JsonKey(name: 'reviewed_by') final  String? reviewedBy;
@override@JsonKey(name: 'reviewed_at') final  String? reviewedAt;
@override@JsonKey(name: 'submitted_at') final  String? submittedAt;
@override@JsonKey(name: 'created_at') final  String? createdAt;
@override@JsonKey(name: 'current_step') final  String currentStep;
 final  List<String> _completedSteps;
@override@JsonKey(name: 'completed_steps', fromJson: _stringList) List<String> get completedSteps {
  if (_completedSteps is EqualUnmodifiableListView) return _completedSteps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_completedSteps);
}

@override@JsonKey(name: 'face_match_status') final  String faceMatchStatus;
@override@JsonKey(name: 'face_match_score', fromJson: _optionalDouble) final  double? faceMatchScore;
@override@JsonKey(name: 'credential_title') final  String credentialTitle;
@override@JsonKey(name: 'credential_issuer') final  String credentialIssuer;
@override@JsonKey(name: 'credential_id') final  String credentialId;
@override@JsonKey(name: 'issued_date') final  String? issuedDate;
@override@JsonKey(name: 'scope_of_practice') final  String scopeOfPractice;
@override@JsonKey(name: 'approval_state') final  VerificationApprovalState? approvalState;
/// Non-null exactly while a second approver is still owed.
@override@JsonKey(name: 'pending_approval') final  VerificationApprovalState? pendingApproval;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerificationSubmission&&(identical(other.id, id) || other.id == id)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.verificationType, verificationType) || other.verificationType == verificationType)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._documents, _documents)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.gym, gym) || other.gym == gym)&&(identical(other.gymName, gymName) || other.gymName == gymName)&&(identical(other.reviewedBy, reviewedBy) || other.reviewedBy == reviewedBy)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&const DeepCollectionEquality().equals(other._completedSteps, _completedSteps)&&(identical(other.faceMatchStatus, faceMatchStatus) || other.faceMatchStatus == faceMatchStatus)&&(identical(other.faceMatchScore, faceMatchScore) || other.faceMatchScore == faceMatchScore)&&(identical(other.credentialTitle, credentialTitle) || other.credentialTitle == credentialTitle)&&(identical(other.credentialIssuer, credentialIssuer) || other.credentialIssuer == credentialIssuer)&&(identical(other.credentialId, credentialId) || other.credentialId == credentialId)&&(identical(other.issuedDate, issuedDate) || other.issuedDate == issuedDate)&&(identical(other.scopeOfPractice, scopeOfPractice) || other.scopeOfPractice == scopeOfPractice)&&(identical(other.approvalState, approvalState) || other.approvalState == approvalState)&&(identical(other.pendingApproval, pendingApproval) || other.pendingApproval == pendingApproval));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,profile,verificationType,status,const DeepCollectionEquality().hash(_documents),notes,gym,gymName,reviewedBy,reviewedAt,submittedAt,createdAt,currentStep,const DeepCollectionEquality().hash(_completedSteps),faceMatchStatus,faceMatchScore,credentialTitle,credentialIssuer,credentialId,issuedDate,scopeOfPractice,approvalState,pendingApproval]);

@override
String toString() {
  return 'VerificationSubmission(id: $id, profile: $profile, verificationType: $verificationType, status: $status, documents: $documents, notes: $notes, gym: $gym, gymName: $gymName, reviewedBy: $reviewedBy, reviewedAt: $reviewedAt, submittedAt: $submittedAt, createdAt: $createdAt, currentStep: $currentStep, completedSteps: $completedSteps, faceMatchStatus: $faceMatchStatus, faceMatchScore: $faceMatchScore, credentialTitle: $credentialTitle, credentialIssuer: $credentialIssuer, credentialId: $credentialId, issuedDate: $issuedDate, scopeOfPractice: $scopeOfPractice, approvalState: $approvalState, pendingApproval: $pendingApproval)';
}


}

/// @nodoc
abstract mixin class _$VerificationSubmissionCopyWith<$Res> implements $VerificationSubmissionCopyWith<$Res> {
  factory _$VerificationSubmissionCopyWith(_VerificationSubmission value, $Res Function(_VerificationSubmission) _then) = __$VerificationSubmissionCopyWithImpl;
@override @useResult
$Res call({
 String id, String? profile,@JsonKey(name: 'verification_type') String verificationType, String status, List<VerificationDocument> documents, String notes, String? gym,@JsonKey(name: 'gym_name') String? gymName,@JsonKey(name: 'reviewed_by') String? reviewedBy,@JsonKey(name: 'reviewed_at') String? reviewedAt,@JsonKey(name: 'submitted_at') String? submittedAt,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'current_step') String currentStep,@JsonKey(name: 'completed_steps', fromJson: _stringList) List<String> completedSteps,@JsonKey(name: 'face_match_status') String faceMatchStatus,@JsonKey(name: 'face_match_score', fromJson: _optionalDouble) double? faceMatchScore,@JsonKey(name: 'credential_title') String credentialTitle,@JsonKey(name: 'credential_issuer') String credentialIssuer,@JsonKey(name: 'credential_id') String credentialId,@JsonKey(name: 'issued_date') String? issuedDate,@JsonKey(name: 'scope_of_practice') String scopeOfPractice,@JsonKey(name: 'approval_state') VerificationApprovalState? approvalState,@JsonKey(name: 'pending_approval') VerificationApprovalState? pendingApproval
});


@override $VerificationApprovalStateCopyWith<$Res>? get approvalState;@override $VerificationApprovalStateCopyWith<$Res>? get pendingApproval;

}
/// @nodoc
class __$VerificationSubmissionCopyWithImpl<$Res>
    implements _$VerificationSubmissionCopyWith<$Res> {
  __$VerificationSubmissionCopyWithImpl(this._self, this._then);

  final _VerificationSubmission _self;
  final $Res Function(_VerificationSubmission) _then;

/// Create a copy of VerificationSubmission
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? profile = freezed,Object? verificationType = null,Object? status = null,Object? documents = null,Object? notes = null,Object? gym = freezed,Object? gymName = freezed,Object? reviewedBy = freezed,Object? reviewedAt = freezed,Object? submittedAt = freezed,Object? createdAt = freezed,Object? currentStep = null,Object? completedSteps = null,Object? faceMatchStatus = null,Object? faceMatchScore = freezed,Object? credentialTitle = null,Object? credentialIssuer = null,Object? credentialId = null,Object? issuedDate = freezed,Object? scopeOfPractice = null,Object? approvalState = freezed,Object? pendingApproval = freezed,}) {
  return _then(_VerificationSubmission(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as String?,verificationType: null == verificationType ? _self.verificationType : verificationType // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,documents: null == documents ? _self._documents : documents // ignore: cast_nullable_to_non_nullable
as List<VerificationDocument>,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,gym: freezed == gym ? _self.gym : gym // ignore: cast_nullable_to_non_nullable
as String?,gymName: freezed == gymName ? _self.gymName : gymName // ignore: cast_nullable_to_non_nullable
as String?,reviewedBy: freezed == reviewedBy ? _self.reviewedBy : reviewedBy // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as String,completedSteps: null == completedSteps ? _self._completedSteps : completedSteps // ignore: cast_nullable_to_non_nullable
as List<String>,faceMatchStatus: null == faceMatchStatus ? _self.faceMatchStatus : faceMatchStatus // ignore: cast_nullable_to_non_nullable
as String,faceMatchScore: freezed == faceMatchScore ? _self.faceMatchScore : faceMatchScore // ignore: cast_nullable_to_non_nullable
as double?,credentialTitle: null == credentialTitle ? _self.credentialTitle : credentialTitle // ignore: cast_nullable_to_non_nullable
as String,credentialIssuer: null == credentialIssuer ? _self.credentialIssuer : credentialIssuer // ignore: cast_nullable_to_non_nullable
as String,credentialId: null == credentialId ? _self.credentialId : credentialId // ignore: cast_nullable_to_non_nullable
as String,issuedDate: freezed == issuedDate ? _self.issuedDate : issuedDate // ignore: cast_nullable_to_non_nullable
as String?,scopeOfPractice: null == scopeOfPractice ? _self.scopeOfPractice : scopeOfPractice // ignore: cast_nullable_to_non_nullable
as String,approvalState: freezed == approvalState ? _self.approvalState : approvalState // ignore: cast_nullable_to_non_nullable
as VerificationApprovalState?,pendingApproval: freezed == pendingApproval ? _self.pendingApproval : pendingApproval // ignore: cast_nullable_to_non_nullable
as VerificationApprovalState?,
  ));
}

/// Create a copy of VerificationSubmission
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VerificationApprovalStateCopyWith<$Res>? get approvalState {
    if (_self.approvalState == null) {
    return null;
  }

  return $VerificationApprovalStateCopyWith<$Res>(_self.approvalState!, (value) {
    return _then(_self.copyWith(approvalState: value));
  });
}/// Create a copy of VerificationSubmission
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VerificationApprovalStateCopyWith<$Res>? get pendingApproval {
    if (_self.pendingApproval == null) {
    return null;
  }

  return $VerificationApprovalStateCopyWith<$Res>(_self.pendingApproval!, (value) {
    return _then(_self.copyWith(pendingApproval: value));
  });
}
}


/// @nodoc
mixin _$MyApplication {

 String get id;@JsonKey(name: 'verification_type') String get category; String get status;@JsonKey(name: 'created_at') String? get createdAt;@JsonKey(name: 'submitted_at') String? get submittedAt;@JsonKey(name: 'decided_at') String? get decidedAt;@JsonKey(name: 'reviewed_at') String? get reviewedAt;@JsonKey(name: 'reviewer_note') String get reviewerNote;@JsonKey(name: 'approval_state') VerificationApprovalState? get approvalState;@JsonKey(name: 'document_count') int get documentCount;
/// Create a copy of MyApplication
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MyApplicationCopyWith<MyApplication> get copyWith => _$MyApplicationCopyWithImpl<MyApplication>(this as MyApplication, _$identity);

  /// Serializes this MyApplication to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MyApplication&&(identical(other.id, id) || other.id == id)&&(identical(other.category, category) || other.category == category)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.decidedAt, decidedAt) || other.decidedAt == decidedAt)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.reviewerNote, reviewerNote) || other.reviewerNote == reviewerNote)&&(identical(other.approvalState, approvalState) || other.approvalState == approvalState)&&(identical(other.documentCount, documentCount) || other.documentCount == documentCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,category,status,createdAt,submittedAt,decidedAt,reviewedAt,reviewerNote,approvalState,documentCount);

@override
String toString() {
  return 'MyApplication(id: $id, category: $category, status: $status, createdAt: $createdAt, submittedAt: $submittedAt, decidedAt: $decidedAt, reviewedAt: $reviewedAt, reviewerNote: $reviewerNote, approvalState: $approvalState, documentCount: $documentCount)';
}


}

/// @nodoc
abstract mixin class $MyApplicationCopyWith<$Res>  {
  factory $MyApplicationCopyWith(MyApplication value, $Res Function(MyApplication) _then) = _$MyApplicationCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'verification_type') String category, String status,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'submitted_at') String? submittedAt,@JsonKey(name: 'decided_at') String? decidedAt,@JsonKey(name: 'reviewed_at') String? reviewedAt,@JsonKey(name: 'reviewer_note') String reviewerNote,@JsonKey(name: 'approval_state') VerificationApprovalState? approvalState,@JsonKey(name: 'document_count') int documentCount
});


$VerificationApprovalStateCopyWith<$Res>? get approvalState;

}
/// @nodoc
class _$MyApplicationCopyWithImpl<$Res>
    implements $MyApplicationCopyWith<$Res> {
  _$MyApplicationCopyWithImpl(this._self, this._then);

  final MyApplication _self;
  final $Res Function(MyApplication) _then;

/// Create a copy of MyApplication
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? category = null,Object? status = null,Object? createdAt = freezed,Object? submittedAt = freezed,Object? decidedAt = freezed,Object? reviewedAt = freezed,Object? reviewerNote = null,Object? approvalState = freezed,Object? documentCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as String?,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as String?,reviewerNote: null == reviewerNote ? _self.reviewerNote : reviewerNote // ignore: cast_nullable_to_non_nullable
as String,approvalState: freezed == approvalState ? _self.approvalState : approvalState // ignore: cast_nullable_to_non_nullable
as VerificationApprovalState?,documentCount: null == documentCount ? _self.documentCount : documentCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of MyApplication
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VerificationApprovalStateCopyWith<$Res>? get approvalState {
    if (_self.approvalState == null) {
    return null;
  }

  return $VerificationApprovalStateCopyWith<$Res>(_self.approvalState!, (value) {
    return _then(_self.copyWith(approvalState: value));
  });
}
}


/// Adds pattern-matching-related methods to [MyApplication].
extension MyApplicationPatterns on MyApplication {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MyApplication value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MyApplication() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MyApplication value)  $default,){
final _that = this;
switch (_that) {
case _MyApplication():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MyApplication value)?  $default,){
final _that = this;
switch (_that) {
case _MyApplication() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'verification_type')  String category,  String status, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'submitted_at')  String? submittedAt, @JsonKey(name: 'decided_at')  String? decidedAt, @JsonKey(name: 'reviewed_at')  String? reviewedAt, @JsonKey(name: 'reviewer_note')  String reviewerNote, @JsonKey(name: 'approval_state')  VerificationApprovalState? approvalState, @JsonKey(name: 'document_count')  int documentCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MyApplication() when $default != null:
return $default(_that.id,_that.category,_that.status,_that.createdAt,_that.submittedAt,_that.decidedAt,_that.reviewedAt,_that.reviewerNote,_that.approvalState,_that.documentCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'verification_type')  String category,  String status, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'submitted_at')  String? submittedAt, @JsonKey(name: 'decided_at')  String? decidedAt, @JsonKey(name: 'reviewed_at')  String? reviewedAt, @JsonKey(name: 'reviewer_note')  String reviewerNote, @JsonKey(name: 'approval_state')  VerificationApprovalState? approvalState, @JsonKey(name: 'document_count')  int documentCount)  $default,) {final _that = this;
switch (_that) {
case _MyApplication():
return $default(_that.id,_that.category,_that.status,_that.createdAt,_that.submittedAt,_that.decidedAt,_that.reviewedAt,_that.reviewerNote,_that.approvalState,_that.documentCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'verification_type')  String category,  String status, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'submitted_at')  String? submittedAt, @JsonKey(name: 'decided_at')  String? decidedAt, @JsonKey(name: 'reviewed_at')  String? reviewedAt, @JsonKey(name: 'reviewer_note')  String reviewerNote, @JsonKey(name: 'approval_state')  VerificationApprovalState? approvalState, @JsonKey(name: 'document_count')  int documentCount)?  $default,) {final _that = this;
switch (_that) {
case _MyApplication() when $default != null:
return $default(_that.id,_that.category,_that.status,_that.createdAt,_that.submittedAt,_that.decidedAt,_that.reviewedAt,_that.reviewerNote,_that.approvalState,_that.documentCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MyApplication implements MyApplication {
  const _MyApplication({this.id = '', @JsonKey(name: 'verification_type') this.category = '', this.status = '', @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'submitted_at') this.submittedAt, @JsonKey(name: 'decided_at') this.decidedAt, @JsonKey(name: 'reviewed_at') this.reviewedAt, @JsonKey(name: 'reviewer_note') this.reviewerNote = '', @JsonKey(name: 'approval_state') this.approvalState, @JsonKey(name: 'document_count') this.documentCount = 0});
  factory _MyApplication.fromJson(Map<String, dynamic> json) => _$MyApplicationFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey(name: 'verification_type') final  String category;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'created_at') final  String? createdAt;
@override@JsonKey(name: 'submitted_at') final  String? submittedAt;
@override@JsonKey(name: 'decided_at') final  String? decidedAt;
@override@JsonKey(name: 'reviewed_at') final  String? reviewedAt;
@override@JsonKey(name: 'reviewer_note') final  String reviewerNote;
@override@JsonKey(name: 'approval_state') final  VerificationApprovalState? approvalState;
@override@JsonKey(name: 'document_count') final  int documentCount;

/// Create a copy of MyApplication
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MyApplicationCopyWith<_MyApplication> get copyWith => __$MyApplicationCopyWithImpl<_MyApplication>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MyApplicationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MyApplication&&(identical(other.id, id) || other.id == id)&&(identical(other.category, category) || other.category == category)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.decidedAt, decidedAt) || other.decidedAt == decidedAt)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.reviewerNote, reviewerNote) || other.reviewerNote == reviewerNote)&&(identical(other.approvalState, approvalState) || other.approvalState == approvalState)&&(identical(other.documentCount, documentCount) || other.documentCount == documentCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,category,status,createdAt,submittedAt,decidedAt,reviewedAt,reviewerNote,approvalState,documentCount);

@override
String toString() {
  return 'MyApplication(id: $id, category: $category, status: $status, createdAt: $createdAt, submittedAt: $submittedAt, decidedAt: $decidedAt, reviewedAt: $reviewedAt, reviewerNote: $reviewerNote, approvalState: $approvalState, documentCount: $documentCount)';
}


}

/// @nodoc
abstract mixin class _$MyApplicationCopyWith<$Res> implements $MyApplicationCopyWith<$Res> {
  factory _$MyApplicationCopyWith(_MyApplication value, $Res Function(_MyApplication) _then) = __$MyApplicationCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'verification_type') String category, String status,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'submitted_at') String? submittedAt,@JsonKey(name: 'decided_at') String? decidedAt,@JsonKey(name: 'reviewed_at') String? reviewedAt,@JsonKey(name: 'reviewer_note') String reviewerNote,@JsonKey(name: 'approval_state') VerificationApprovalState? approvalState,@JsonKey(name: 'document_count') int documentCount
});


@override $VerificationApprovalStateCopyWith<$Res>? get approvalState;

}
/// @nodoc
class __$MyApplicationCopyWithImpl<$Res>
    implements _$MyApplicationCopyWith<$Res> {
  __$MyApplicationCopyWithImpl(this._self, this._then);

  final _MyApplication _self;
  final $Res Function(_MyApplication) _then;

/// Create a copy of MyApplication
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? category = null,Object? status = null,Object? createdAt = freezed,Object? submittedAt = freezed,Object? decidedAt = freezed,Object? reviewedAt = freezed,Object? reviewerNote = null,Object? approvalState = freezed,Object? documentCount = null,}) {
  return _then(_MyApplication(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as String?,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as String?,reviewerNote: null == reviewerNote ? _self.reviewerNote : reviewerNote // ignore: cast_nullable_to_non_nullable
as String,approvalState: freezed == approvalState ? _self.approvalState : approvalState // ignore: cast_nullable_to_non_nullable
as VerificationApprovalState?,documentCount: null == documentCount ? _self.documentCount : documentCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of MyApplication
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VerificationApprovalStateCopyWith<$Res>? get approvalState {
    if (_self.approvalState == null) {
    return null;
  }

  return $VerificationApprovalStateCopyWith<$Res>(_self.approvalState!, (value) {
    return _then(_self.copyWith(approvalState: value));
  });
}
}

// dart format on
