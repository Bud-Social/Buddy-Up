// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallet.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BalanceItem {

@JsonKey(name: 'artifact_type') String get artifactType; String get label; int get quantity;@JsonKey(name: 'usd_value') double get usdValue;
/// Create a copy of BalanceItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BalanceItemCopyWith<BalanceItem> get copyWith => _$BalanceItemCopyWithImpl<BalanceItem>(this as BalanceItem, _$identity);

  /// Serializes this BalanceItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BalanceItem&&(identical(other.artifactType, artifactType) || other.artifactType == artifactType)&&(identical(other.label, label) || other.label == label)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.usdValue, usdValue) || other.usdValue == usdValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,artifactType,label,quantity,usdValue);

@override
String toString() {
  return 'BalanceItem(artifactType: $artifactType, label: $label, quantity: $quantity, usdValue: $usdValue)';
}


}

/// @nodoc
abstract mixin class $BalanceItemCopyWith<$Res>  {
  factory $BalanceItemCopyWith(BalanceItem value, $Res Function(BalanceItem) _then) = _$BalanceItemCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'artifact_type') String artifactType, String label, int quantity,@JsonKey(name: 'usd_value') double usdValue
});




}
/// @nodoc
class _$BalanceItemCopyWithImpl<$Res>
    implements $BalanceItemCopyWith<$Res> {
  _$BalanceItemCopyWithImpl(this._self, this._then);

  final BalanceItem _self;
  final $Res Function(BalanceItem) _then;

/// Create a copy of BalanceItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? artifactType = null,Object? label = null,Object? quantity = null,Object? usdValue = null,}) {
  return _then(_self.copyWith(
artifactType: null == artifactType ? _self.artifactType : artifactType // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,usdValue: null == usdValue ? _self.usdValue : usdValue // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [BalanceItem].
extension BalanceItemPatterns on BalanceItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BalanceItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BalanceItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BalanceItem value)  $default,){
final _that = this;
switch (_that) {
case _BalanceItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BalanceItem value)?  $default,){
final _that = this;
switch (_that) {
case _BalanceItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'artifact_type')  String artifactType,  String label,  int quantity, @JsonKey(name: 'usd_value')  double usdValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BalanceItem() when $default != null:
return $default(_that.artifactType,_that.label,_that.quantity,_that.usdValue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'artifact_type')  String artifactType,  String label,  int quantity, @JsonKey(name: 'usd_value')  double usdValue)  $default,) {final _that = this;
switch (_that) {
case _BalanceItem():
return $default(_that.artifactType,_that.label,_that.quantity,_that.usdValue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'artifact_type')  String artifactType,  String label,  int quantity, @JsonKey(name: 'usd_value')  double usdValue)?  $default,) {final _that = this;
switch (_that) {
case _BalanceItem() when $default != null:
return $default(_that.artifactType,_that.label,_that.quantity,_that.usdValue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BalanceItem implements BalanceItem {
  const _BalanceItem({@JsonKey(name: 'artifact_type') required this.artifactType, required this.label, required this.quantity, @JsonKey(name: 'usd_value') required this.usdValue});
  factory _BalanceItem.fromJson(Map<String, dynamic> json) => _$BalanceItemFromJson(json);

@override@JsonKey(name: 'artifact_type') final  String artifactType;
@override final  String label;
@override final  int quantity;
@override@JsonKey(name: 'usd_value') final  double usdValue;

/// Create a copy of BalanceItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BalanceItemCopyWith<_BalanceItem> get copyWith => __$BalanceItemCopyWithImpl<_BalanceItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BalanceItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BalanceItem&&(identical(other.artifactType, artifactType) || other.artifactType == artifactType)&&(identical(other.label, label) || other.label == label)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.usdValue, usdValue) || other.usdValue == usdValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,artifactType,label,quantity,usdValue);

@override
String toString() {
  return 'BalanceItem(artifactType: $artifactType, label: $label, quantity: $quantity, usdValue: $usdValue)';
}


}

/// @nodoc
abstract mixin class _$BalanceItemCopyWith<$Res> implements $BalanceItemCopyWith<$Res> {
  factory _$BalanceItemCopyWith(_BalanceItem value, $Res Function(_BalanceItem) _then) = __$BalanceItemCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'artifact_type') String artifactType, String label, int quantity,@JsonKey(name: 'usd_value') double usdValue
});




}
/// @nodoc
class __$BalanceItemCopyWithImpl<$Res>
    implements _$BalanceItemCopyWith<$Res> {
  __$BalanceItemCopyWithImpl(this._self, this._then);

  final _BalanceItem _self;
  final $Res Function(_BalanceItem) _then;

/// Create a copy of BalanceItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? artifactType = null,Object? label = null,Object? quantity = null,Object? usdValue = null,}) {
  return _then(_BalanceItem(
artifactType: null == artifactType ? _self.artifactType : artifactType // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,usdValue: null == usdValue ? _self.usdValue : usdValue // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$BalanceResponse {

 List<BalanceItem> get balance;@JsonKey(name: 'total_label') String get totalLabel;@JsonKey(name: 'total_fiat') double get totalFiat;@JsonKey(name: 'fiat_currency') String get fiatCurrency;
/// Create a copy of BalanceResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BalanceResponseCopyWith<BalanceResponse> get copyWith => _$BalanceResponseCopyWithImpl<BalanceResponse>(this as BalanceResponse, _$identity);

  /// Serializes this BalanceResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BalanceResponse&&const DeepCollectionEquality().equals(other.balance, balance)&&(identical(other.totalLabel, totalLabel) || other.totalLabel == totalLabel)&&(identical(other.totalFiat, totalFiat) || other.totalFiat == totalFiat)&&(identical(other.fiatCurrency, fiatCurrency) || other.fiatCurrency == fiatCurrency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(balance),totalLabel,totalFiat,fiatCurrency);

@override
String toString() {
  return 'BalanceResponse(balance: $balance, totalLabel: $totalLabel, totalFiat: $totalFiat, fiatCurrency: $fiatCurrency)';
}


}

/// @nodoc
abstract mixin class $BalanceResponseCopyWith<$Res>  {
  factory $BalanceResponseCopyWith(BalanceResponse value, $Res Function(BalanceResponse) _then) = _$BalanceResponseCopyWithImpl;
@useResult
$Res call({
 List<BalanceItem> balance,@JsonKey(name: 'total_label') String totalLabel,@JsonKey(name: 'total_fiat') double totalFiat,@JsonKey(name: 'fiat_currency') String fiatCurrency
});




}
/// @nodoc
class _$BalanceResponseCopyWithImpl<$Res>
    implements $BalanceResponseCopyWith<$Res> {
  _$BalanceResponseCopyWithImpl(this._self, this._then);

  final BalanceResponse _self;
  final $Res Function(BalanceResponse) _then;

/// Create a copy of BalanceResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? balance = null,Object? totalLabel = null,Object? totalFiat = null,Object? fiatCurrency = null,}) {
  return _then(_self.copyWith(
balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as List<BalanceItem>,totalLabel: null == totalLabel ? _self.totalLabel : totalLabel // ignore: cast_nullable_to_non_nullable
as String,totalFiat: null == totalFiat ? _self.totalFiat : totalFiat // ignore: cast_nullable_to_non_nullable
as double,fiatCurrency: null == fiatCurrency ? _self.fiatCurrency : fiatCurrency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BalanceResponse].
extension BalanceResponsePatterns on BalanceResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BalanceResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BalanceResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BalanceResponse value)  $default,){
final _that = this;
switch (_that) {
case _BalanceResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BalanceResponse value)?  $default,){
final _that = this;
switch (_that) {
case _BalanceResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<BalanceItem> balance, @JsonKey(name: 'total_label')  String totalLabel, @JsonKey(name: 'total_fiat')  double totalFiat, @JsonKey(name: 'fiat_currency')  String fiatCurrency)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BalanceResponse() when $default != null:
return $default(_that.balance,_that.totalLabel,_that.totalFiat,_that.fiatCurrency);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<BalanceItem> balance, @JsonKey(name: 'total_label')  String totalLabel, @JsonKey(name: 'total_fiat')  double totalFiat, @JsonKey(name: 'fiat_currency')  String fiatCurrency)  $default,) {final _that = this;
switch (_that) {
case _BalanceResponse():
return $default(_that.balance,_that.totalLabel,_that.totalFiat,_that.fiatCurrency);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<BalanceItem> balance, @JsonKey(name: 'total_label')  String totalLabel, @JsonKey(name: 'total_fiat')  double totalFiat, @JsonKey(name: 'fiat_currency')  String fiatCurrency)?  $default,) {final _that = this;
switch (_that) {
case _BalanceResponse() when $default != null:
return $default(_that.balance,_that.totalLabel,_that.totalFiat,_that.fiatCurrency);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BalanceResponse implements BalanceResponse {
  const _BalanceResponse({required final  List<BalanceItem> balance, @JsonKey(name: 'total_label') required this.totalLabel, @JsonKey(name: 'total_fiat') required this.totalFiat, @JsonKey(name: 'fiat_currency') required this.fiatCurrency}): _balance = balance;
  factory _BalanceResponse.fromJson(Map<String, dynamic> json) => _$BalanceResponseFromJson(json);

 final  List<BalanceItem> _balance;
@override List<BalanceItem> get balance {
  if (_balance is EqualUnmodifiableListView) return _balance;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_balance);
}

@override@JsonKey(name: 'total_label') final  String totalLabel;
@override@JsonKey(name: 'total_fiat') final  double totalFiat;
@override@JsonKey(name: 'fiat_currency') final  String fiatCurrency;

/// Create a copy of BalanceResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BalanceResponseCopyWith<_BalanceResponse> get copyWith => __$BalanceResponseCopyWithImpl<_BalanceResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BalanceResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BalanceResponse&&const DeepCollectionEquality().equals(other._balance, _balance)&&(identical(other.totalLabel, totalLabel) || other.totalLabel == totalLabel)&&(identical(other.totalFiat, totalFiat) || other.totalFiat == totalFiat)&&(identical(other.fiatCurrency, fiatCurrency) || other.fiatCurrency == fiatCurrency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_balance),totalLabel,totalFiat,fiatCurrency);

@override
String toString() {
  return 'BalanceResponse(balance: $balance, totalLabel: $totalLabel, totalFiat: $totalFiat, fiatCurrency: $fiatCurrency)';
}


}

/// @nodoc
abstract mixin class _$BalanceResponseCopyWith<$Res> implements $BalanceResponseCopyWith<$Res> {
  factory _$BalanceResponseCopyWith(_BalanceResponse value, $Res Function(_BalanceResponse) _then) = __$BalanceResponseCopyWithImpl;
@override @useResult
$Res call({
 List<BalanceItem> balance,@JsonKey(name: 'total_label') String totalLabel,@JsonKey(name: 'total_fiat') double totalFiat,@JsonKey(name: 'fiat_currency') String fiatCurrency
});




}
/// @nodoc
class __$BalanceResponseCopyWithImpl<$Res>
    implements _$BalanceResponseCopyWith<$Res> {
  __$BalanceResponseCopyWithImpl(this._self, this._then);

  final _BalanceResponse _self;
  final $Res Function(_BalanceResponse) _then;

/// Create a copy of BalanceResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? balance = null,Object? totalLabel = null,Object? totalFiat = null,Object? fiatCurrency = null,}) {
  return _then(_BalanceResponse(
balance: null == balance ? _self._balance : balance // ignore: cast_nullable_to_non_nullable
as List<BalanceItem>,totalLabel: null == totalLabel ? _self.totalLabel : totalLabel // ignore: cast_nullable_to_non_nullable
as String,totalFiat: null == totalFiat ? _self.totalFiat : totalFiat // ignore: cast_nullable_to_non_nullable
as double,fiatCurrency: null == fiatCurrency ? _self.fiatCurrency : fiatCurrency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ArtifactTransaction {

 String get id;@JsonKey(name: 'transaction_type') String get transactionType;@JsonKey(name: 'artifact_type') String get artifactType; int get quantity; String get direction;@JsonKey(name: 'counterparty_id') String? get counterpartyId;@JsonKey(name: 'counterparty_name') String? get counterpartyName;@JsonKey(name: 'reference_id') String get referenceId; String get status;@JsonKey(name: 'fiat_amount') String? get fiatAmount;@JsonKey(name: 'fiat_currency') String get fiatCurrency; String? get description;@JsonKey(name: 'clearance_at') String? get clearanceAt;@JsonKey(name: 'created_at') String get createdAt;
/// Create a copy of ArtifactTransaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ArtifactTransactionCopyWith<ArtifactTransaction> get copyWith => _$ArtifactTransactionCopyWithImpl<ArtifactTransaction>(this as ArtifactTransaction, _$identity);

  /// Serializes this ArtifactTransaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ArtifactTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.transactionType, transactionType) || other.transactionType == transactionType)&&(identical(other.artifactType, artifactType) || other.artifactType == artifactType)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.counterpartyId, counterpartyId) || other.counterpartyId == counterpartyId)&&(identical(other.counterpartyName, counterpartyName) || other.counterpartyName == counterpartyName)&&(identical(other.referenceId, referenceId) || other.referenceId == referenceId)&&(identical(other.status, status) || other.status == status)&&(identical(other.fiatAmount, fiatAmount) || other.fiatAmount == fiatAmount)&&(identical(other.fiatCurrency, fiatCurrency) || other.fiatCurrency == fiatCurrency)&&(identical(other.description, description) || other.description == description)&&(identical(other.clearanceAt, clearanceAt) || other.clearanceAt == clearanceAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,transactionType,artifactType,quantity,direction,counterpartyId,counterpartyName,referenceId,status,fiatAmount,fiatCurrency,description,clearanceAt,createdAt);

@override
String toString() {
  return 'ArtifactTransaction(id: $id, transactionType: $transactionType, artifactType: $artifactType, quantity: $quantity, direction: $direction, counterpartyId: $counterpartyId, counterpartyName: $counterpartyName, referenceId: $referenceId, status: $status, fiatAmount: $fiatAmount, fiatCurrency: $fiatCurrency, description: $description, clearanceAt: $clearanceAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ArtifactTransactionCopyWith<$Res>  {
  factory $ArtifactTransactionCopyWith(ArtifactTransaction value, $Res Function(ArtifactTransaction) _then) = _$ArtifactTransactionCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'transaction_type') String transactionType,@JsonKey(name: 'artifact_type') String artifactType, int quantity, String direction,@JsonKey(name: 'counterparty_id') String? counterpartyId,@JsonKey(name: 'counterparty_name') String? counterpartyName,@JsonKey(name: 'reference_id') String referenceId, String status,@JsonKey(name: 'fiat_amount') String? fiatAmount,@JsonKey(name: 'fiat_currency') String fiatCurrency, String? description,@JsonKey(name: 'clearance_at') String? clearanceAt,@JsonKey(name: 'created_at') String createdAt
});




}
/// @nodoc
class _$ArtifactTransactionCopyWithImpl<$Res>
    implements $ArtifactTransactionCopyWith<$Res> {
  _$ArtifactTransactionCopyWithImpl(this._self, this._then);

  final ArtifactTransaction _self;
  final $Res Function(ArtifactTransaction) _then;

/// Create a copy of ArtifactTransaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? transactionType = null,Object? artifactType = null,Object? quantity = null,Object? direction = null,Object? counterpartyId = freezed,Object? counterpartyName = freezed,Object? referenceId = null,Object? status = null,Object? fiatAmount = freezed,Object? fiatCurrency = null,Object? description = freezed,Object? clearanceAt = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,transactionType: null == transactionType ? _self.transactionType : transactionType // ignore: cast_nullable_to_non_nullable
as String,artifactType: null == artifactType ? _self.artifactType : artifactType // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as String,counterpartyId: freezed == counterpartyId ? _self.counterpartyId : counterpartyId // ignore: cast_nullable_to_non_nullable
as String?,counterpartyName: freezed == counterpartyName ? _self.counterpartyName : counterpartyName // ignore: cast_nullable_to_non_nullable
as String?,referenceId: null == referenceId ? _self.referenceId : referenceId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,fiatAmount: freezed == fiatAmount ? _self.fiatAmount : fiatAmount // ignore: cast_nullable_to_non_nullable
as String?,fiatCurrency: null == fiatCurrency ? _self.fiatCurrency : fiatCurrency // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,clearanceAt: freezed == clearanceAt ? _self.clearanceAt : clearanceAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ArtifactTransaction].
extension ArtifactTransactionPatterns on ArtifactTransaction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ArtifactTransaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ArtifactTransaction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ArtifactTransaction value)  $default,){
final _that = this;
switch (_that) {
case _ArtifactTransaction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ArtifactTransaction value)?  $default,){
final _that = this;
switch (_that) {
case _ArtifactTransaction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'transaction_type')  String transactionType, @JsonKey(name: 'artifact_type')  String artifactType,  int quantity,  String direction, @JsonKey(name: 'counterparty_id')  String? counterpartyId, @JsonKey(name: 'counterparty_name')  String? counterpartyName, @JsonKey(name: 'reference_id')  String referenceId,  String status, @JsonKey(name: 'fiat_amount')  String? fiatAmount, @JsonKey(name: 'fiat_currency')  String fiatCurrency,  String? description, @JsonKey(name: 'clearance_at')  String? clearanceAt, @JsonKey(name: 'created_at')  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ArtifactTransaction() when $default != null:
return $default(_that.id,_that.transactionType,_that.artifactType,_that.quantity,_that.direction,_that.counterpartyId,_that.counterpartyName,_that.referenceId,_that.status,_that.fiatAmount,_that.fiatCurrency,_that.description,_that.clearanceAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'transaction_type')  String transactionType, @JsonKey(name: 'artifact_type')  String artifactType,  int quantity,  String direction, @JsonKey(name: 'counterparty_id')  String? counterpartyId, @JsonKey(name: 'counterparty_name')  String? counterpartyName, @JsonKey(name: 'reference_id')  String referenceId,  String status, @JsonKey(name: 'fiat_amount')  String? fiatAmount, @JsonKey(name: 'fiat_currency')  String fiatCurrency,  String? description, @JsonKey(name: 'clearance_at')  String? clearanceAt, @JsonKey(name: 'created_at')  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _ArtifactTransaction():
return $default(_that.id,_that.transactionType,_that.artifactType,_that.quantity,_that.direction,_that.counterpartyId,_that.counterpartyName,_that.referenceId,_that.status,_that.fiatAmount,_that.fiatCurrency,_that.description,_that.clearanceAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'transaction_type')  String transactionType, @JsonKey(name: 'artifact_type')  String artifactType,  int quantity,  String direction, @JsonKey(name: 'counterparty_id')  String? counterpartyId, @JsonKey(name: 'counterparty_name')  String? counterpartyName, @JsonKey(name: 'reference_id')  String referenceId,  String status, @JsonKey(name: 'fiat_amount')  String? fiatAmount, @JsonKey(name: 'fiat_currency')  String fiatCurrency,  String? description, @JsonKey(name: 'clearance_at')  String? clearanceAt, @JsonKey(name: 'created_at')  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ArtifactTransaction() when $default != null:
return $default(_that.id,_that.transactionType,_that.artifactType,_that.quantity,_that.direction,_that.counterpartyId,_that.counterpartyName,_that.referenceId,_that.status,_that.fiatAmount,_that.fiatCurrency,_that.description,_that.clearanceAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ArtifactTransaction implements ArtifactTransaction {
  const _ArtifactTransaction({required this.id, @JsonKey(name: 'transaction_type') required this.transactionType, @JsonKey(name: 'artifact_type') required this.artifactType, required this.quantity, required this.direction, @JsonKey(name: 'counterparty_id') this.counterpartyId, @JsonKey(name: 'counterparty_name') this.counterpartyName, @JsonKey(name: 'reference_id') required this.referenceId, required this.status, @JsonKey(name: 'fiat_amount') this.fiatAmount, @JsonKey(name: 'fiat_currency') required this.fiatCurrency, this.description, @JsonKey(name: 'clearance_at') this.clearanceAt, @JsonKey(name: 'created_at') required this.createdAt});
  factory _ArtifactTransaction.fromJson(Map<String, dynamic> json) => _$ArtifactTransactionFromJson(json);

@override final  String id;
@override@JsonKey(name: 'transaction_type') final  String transactionType;
@override@JsonKey(name: 'artifact_type') final  String artifactType;
@override final  int quantity;
@override final  String direction;
@override@JsonKey(name: 'counterparty_id') final  String? counterpartyId;
@override@JsonKey(name: 'counterparty_name') final  String? counterpartyName;
@override@JsonKey(name: 'reference_id') final  String referenceId;
@override final  String status;
@override@JsonKey(name: 'fiat_amount') final  String? fiatAmount;
@override@JsonKey(name: 'fiat_currency') final  String fiatCurrency;
@override final  String? description;
@override@JsonKey(name: 'clearance_at') final  String? clearanceAt;
@override@JsonKey(name: 'created_at') final  String createdAt;

/// Create a copy of ArtifactTransaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ArtifactTransactionCopyWith<_ArtifactTransaction> get copyWith => __$ArtifactTransactionCopyWithImpl<_ArtifactTransaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ArtifactTransactionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ArtifactTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.transactionType, transactionType) || other.transactionType == transactionType)&&(identical(other.artifactType, artifactType) || other.artifactType == artifactType)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.counterpartyId, counterpartyId) || other.counterpartyId == counterpartyId)&&(identical(other.counterpartyName, counterpartyName) || other.counterpartyName == counterpartyName)&&(identical(other.referenceId, referenceId) || other.referenceId == referenceId)&&(identical(other.status, status) || other.status == status)&&(identical(other.fiatAmount, fiatAmount) || other.fiatAmount == fiatAmount)&&(identical(other.fiatCurrency, fiatCurrency) || other.fiatCurrency == fiatCurrency)&&(identical(other.description, description) || other.description == description)&&(identical(other.clearanceAt, clearanceAt) || other.clearanceAt == clearanceAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,transactionType,artifactType,quantity,direction,counterpartyId,counterpartyName,referenceId,status,fiatAmount,fiatCurrency,description,clearanceAt,createdAt);

@override
String toString() {
  return 'ArtifactTransaction(id: $id, transactionType: $transactionType, artifactType: $artifactType, quantity: $quantity, direction: $direction, counterpartyId: $counterpartyId, counterpartyName: $counterpartyName, referenceId: $referenceId, status: $status, fiatAmount: $fiatAmount, fiatCurrency: $fiatCurrency, description: $description, clearanceAt: $clearanceAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ArtifactTransactionCopyWith<$Res> implements $ArtifactTransactionCopyWith<$Res> {
  factory _$ArtifactTransactionCopyWith(_ArtifactTransaction value, $Res Function(_ArtifactTransaction) _then) = __$ArtifactTransactionCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'transaction_type') String transactionType,@JsonKey(name: 'artifact_type') String artifactType, int quantity, String direction,@JsonKey(name: 'counterparty_id') String? counterpartyId,@JsonKey(name: 'counterparty_name') String? counterpartyName,@JsonKey(name: 'reference_id') String referenceId, String status,@JsonKey(name: 'fiat_amount') String? fiatAmount,@JsonKey(name: 'fiat_currency') String fiatCurrency, String? description,@JsonKey(name: 'clearance_at') String? clearanceAt,@JsonKey(name: 'created_at') String createdAt
});




}
/// @nodoc
class __$ArtifactTransactionCopyWithImpl<$Res>
    implements _$ArtifactTransactionCopyWith<$Res> {
  __$ArtifactTransactionCopyWithImpl(this._self, this._then);

  final _ArtifactTransaction _self;
  final $Res Function(_ArtifactTransaction) _then;

/// Create a copy of ArtifactTransaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? transactionType = null,Object? artifactType = null,Object? quantity = null,Object? direction = null,Object? counterpartyId = freezed,Object? counterpartyName = freezed,Object? referenceId = null,Object? status = null,Object? fiatAmount = freezed,Object? fiatCurrency = null,Object? description = freezed,Object? clearanceAt = freezed,Object? createdAt = null,}) {
  return _then(_ArtifactTransaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,transactionType: null == transactionType ? _self.transactionType : transactionType // ignore: cast_nullable_to_non_nullable
as String,artifactType: null == artifactType ? _self.artifactType : artifactType // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as String,counterpartyId: freezed == counterpartyId ? _self.counterpartyId : counterpartyId // ignore: cast_nullable_to_non_nullable
as String?,counterpartyName: freezed == counterpartyName ? _self.counterpartyName : counterpartyName // ignore: cast_nullable_to_non_nullable
as String?,referenceId: null == referenceId ? _self.referenceId : referenceId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,fiatAmount: freezed == fiatAmount ? _self.fiatAmount : fiatAmount // ignore: cast_nullable_to_non_nullable
as String?,fiatCurrency: null == fiatCurrency ? _self.fiatCurrency : fiatCurrency // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,clearanceAt: freezed == clearanceAt ? _self.clearanceAt : clearanceAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$BundleInfo {

 String get id;@JsonKey(name: 'artifact_type') String get artifactType;@JsonKey(name: 'artifact_label') String get artifactLabel; int get quantity;@JsonKey(name: 'price_usd') double get priceUsd; double get savings;
/// Create a copy of BundleInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BundleInfoCopyWith<BundleInfo> get copyWith => _$BundleInfoCopyWithImpl<BundleInfo>(this as BundleInfo, _$identity);

  /// Serializes this BundleInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BundleInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.artifactType, artifactType) || other.artifactType == artifactType)&&(identical(other.artifactLabel, artifactLabel) || other.artifactLabel == artifactLabel)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.priceUsd, priceUsd) || other.priceUsd == priceUsd)&&(identical(other.savings, savings) || other.savings == savings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,artifactType,artifactLabel,quantity,priceUsd,savings);

@override
String toString() {
  return 'BundleInfo(id: $id, artifactType: $artifactType, artifactLabel: $artifactLabel, quantity: $quantity, priceUsd: $priceUsd, savings: $savings)';
}


}

/// @nodoc
abstract mixin class $BundleInfoCopyWith<$Res>  {
  factory $BundleInfoCopyWith(BundleInfo value, $Res Function(BundleInfo) _then) = _$BundleInfoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'artifact_type') String artifactType,@JsonKey(name: 'artifact_label') String artifactLabel, int quantity,@JsonKey(name: 'price_usd') double priceUsd, double savings
});




}
/// @nodoc
class _$BundleInfoCopyWithImpl<$Res>
    implements $BundleInfoCopyWith<$Res> {
  _$BundleInfoCopyWithImpl(this._self, this._then);

  final BundleInfo _self;
  final $Res Function(BundleInfo) _then;

/// Create a copy of BundleInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? artifactType = null,Object? artifactLabel = null,Object? quantity = null,Object? priceUsd = null,Object? savings = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,artifactType: null == artifactType ? _self.artifactType : artifactType // ignore: cast_nullable_to_non_nullable
as String,artifactLabel: null == artifactLabel ? _self.artifactLabel : artifactLabel // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,priceUsd: null == priceUsd ? _self.priceUsd : priceUsd // ignore: cast_nullable_to_non_nullable
as double,savings: null == savings ? _self.savings : savings // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [BundleInfo].
extension BundleInfoPatterns on BundleInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BundleInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BundleInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BundleInfo value)  $default,){
final _that = this;
switch (_that) {
case _BundleInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BundleInfo value)?  $default,){
final _that = this;
switch (_that) {
case _BundleInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'artifact_type')  String artifactType, @JsonKey(name: 'artifact_label')  String artifactLabel,  int quantity, @JsonKey(name: 'price_usd')  double priceUsd,  double savings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BundleInfo() when $default != null:
return $default(_that.id,_that.artifactType,_that.artifactLabel,_that.quantity,_that.priceUsd,_that.savings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'artifact_type')  String artifactType, @JsonKey(name: 'artifact_label')  String artifactLabel,  int quantity, @JsonKey(name: 'price_usd')  double priceUsd,  double savings)  $default,) {final _that = this;
switch (_that) {
case _BundleInfo():
return $default(_that.id,_that.artifactType,_that.artifactLabel,_that.quantity,_that.priceUsd,_that.savings);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'artifact_type')  String artifactType, @JsonKey(name: 'artifact_label')  String artifactLabel,  int quantity, @JsonKey(name: 'price_usd')  double priceUsd,  double savings)?  $default,) {final _that = this;
switch (_that) {
case _BundleInfo() when $default != null:
return $default(_that.id,_that.artifactType,_that.artifactLabel,_that.quantity,_that.priceUsd,_that.savings);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BundleInfo implements BundleInfo {
  const _BundleInfo({required this.id, @JsonKey(name: 'artifact_type') required this.artifactType, @JsonKey(name: 'artifact_label') required this.artifactLabel, required this.quantity, @JsonKey(name: 'price_usd') required this.priceUsd, required this.savings});
  factory _BundleInfo.fromJson(Map<String, dynamic> json) => _$BundleInfoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'artifact_type') final  String artifactType;
@override@JsonKey(name: 'artifact_label') final  String artifactLabel;
@override final  int quantity;
@override@JsonKey(name: 'price_usd') final  double priceUsd;
@override final  double savings;

/// Create a copy of BundleInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BundleInfoCopyWith<_BundleInfo> get copyWith => __$BundleInfoCopyWithImpl<_BundleInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BundleInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BundleInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.artifactType, artifactType) || other.artifactType == artifactType)&&(identical(other.artifactLabel, artifactLabel) || other.artifactLabel == artifactLabel)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.priceUsd, priceUsd) || other.priceUsd == priceUsd)&&(identical(other.savings, savings) || other.savings == savings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,artifactType,artifactLabel,quantity,priceUsd,savings);

@override
String toString() {
  return 'BundleInfo(id: $id, artifactType: $artifactType, artifactLabel: $artifactLabel, quantity: $quantity, priceUsd: $priceUsd, savings: $savings)';
}


}

/// @nodoc
abstract mixin class _$BundleInfoCopyWith<$Res> implements $BundleInfoCopyWith<$Res> {
  factory _$BundleInfoCopyWith(_BundleInfo value, $Res Function(_BundleInfo) _then) = __$BundleInfoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'artifact_type') String artifactType,@JsonKey(name: 'artifact_label') String artifactLabel, int quantity,@JsonKey(name: 'price_usd') double priceUsd, double savings
});




}
/// @nodoc
class __$BundleInfoCopyWithImpl<$Res>
    implements _$BundleInfoCopyWith<$Res> {
  __$BundleInfoCopyWithImpl(this._self, this._then);

  final _BundleInfo _self;
  final $Res Function(_BundleInfo) _then;

/// Create a copy of BundleInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? artifactType = null,Object? artifactLabel = null,Object? quantity = null,Object? priceUsd = null,Object? savings = null,}) {
  return _then(_BundleInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,artifactType: null == artifactType ? _self.artifactType : artifactType // ignore: cast_nullable_to_non_nullable
as String,artifactLabel: null == artifactLabel ? _self.artifactLabel : artifactLabel // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,priceUsd: null == priceUsd ? _self.priceUsd : priceUsd // ignore: cast_nullable_to_non_nullable
as double,savings: null == savings ? _self.savings : savings // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$BankInfo {

 String get code; String get name;
/// Create a copy of BankInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BankInfoCopyWith<BankInfo> get copyWith => _$BankInfoCopyWithImpl<BankInfo>(this as BankInfo, _$identity);

  /// Serializes this BankInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BankInfo&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,name);

@override
String toString() {
  return 'BankInfo(code: $code, name: $name)';
}


}

/// @nodoc
abstract mixin class $BankInfoCopyWith<$Res>  {
  factory $BankInfoCopyWith(BankInfo value, $Res Function(BankInfo) _then) = _$BankInfoCopyWithImpl;
@useResult
$Res call({
 String code, String name
});




}
/// @nodoc
class _$BankInfoCopyWithImpl<$Res>
    implements $BankInfoCopyWith<$Res> {
  _$BankInfoCopyWithImpl(this._self, this._then);

  final BankInfo _self;
  final $Res Function(BankInfo) _then;

/// Create a copy of BankInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? name = null,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BankInfo].
extension BankInfoPatterns on BankInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BankInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BankInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BankInfo value)  $default,){
final _that = this;
switch (_that) {
case _BankInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BankInfo value)?  $default,){
final _that = this;
switch (_that) {
case _BankInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BankInfo() when $default != null:
return $default(_that.code,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String name)  $default,) {final _that = this;
switch (_that) {
case _BankInfo():
return $default(_that.code,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String name)?  $default,) {final _that = this;
switch (_that) {
case _BankInfo() when $default != null:
return $default(_that.code,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BankInfo implements BankInfo {
  const _BankInfo({required this.code, required this.name});
  factory _BankInfo.fromJson(Map<String, dynamic> json) => _$BankInfoFromJson(json);

@override final  String code;
@override final  String name;

/// Create a copy of BankInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BankInfoCopyWith<_BankInfo> get copyWith => __$BankInfoCopyWithImpl<_BankInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BankInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BankInfo&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,name);

@override
String toString() {
  return 'BankInfo(code: $code, name: $name)';
}


}

/// @nodoc
abstract mixin class _$BankInfoCopyWith<$Res> implements $BankInfoCopyWith<$Res> {
  factory _$BankInfoCopyWith(_BankInfo value, $Res Function(_BankInfo) _then) = __$BankInfoCopyWithImpl;
@override @useResult
$Res call({
 String code, String name
});




}
/// @nodoc
class __$BankInfoCopyWithImpl<$Res>
    implements _$BankInfoCopyWith<$Res> {
  __$BankInfoCopyWithImpl(this._self, this._then);

  final _BankInfo _self;
  final $Res Function(_BankInfo) _then;

/// Create a copy of BankInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? name = null,}) {
  return _then(_BankInfo(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$BankResolveResult {

@JsonKey(name: 'account_number') String get accountNumber;@JsonKey(name: 'bank_code') String get bankCode;@JsonKey(name: 'account_name') String get accountName;
/// Create a copy of BankResolveResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BankResolveResultCopyWith<BankResolveResult> get copyWith => _$BankResolveResultCopyWithImpl<BankResolveResult>(this as BankResolveResult, _$identity);

  /// Serializes this BankResolveResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BankResolveResult&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.bankCode, bankCode) || other.bankCode == bankCode)&&(identical(other.accountName, accountName) || other.accountName == accountName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accountNumber,bankCode,accountName);

@override
String toString() {
  return 'BankResolveResult(accountNumber: $accountNumber, bankCode: $bankCode, accountName: $accountName)';
}


}

/// @nodoc
abstract mixin class $BankResolveResultCopyWith<$Res>  {
  factory $BankResolveResultCopyWith(BankResolveResult value, $Res Function(BankResolveResult) _then) = _$BankResolveResultCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'account_number') String accountNumber,@JsonKey(name: 'bank_code') String bankCode,@JsonKey(name: 'account_name') String accountName
});




}
/// @nodoc
class _$BankResolveResultCopyWithImpl<$Res>
    implements $BankResolveResultCopyWith<$Res> {
  _$BankResolveResultCopyWithImpl(this._self, this._then);

  final BankResolveResult _self;
  final $Res Function(BankResolveResult) _then;

/// Create a copy of BankResolveResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accountNumber = null,Object? bankCode = null,Object? accountName = null,}) {
  return _then(_self.copyWith(
accountNumber: null == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String,bankCode: null == bankCode ? _self.bankCode : bankCode // ignore: cast_nullable_to_non_nullable
as String,accountName: null == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BankResolveResult].
extension BankResolveResultPatterns on BankResolveResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BankResolveResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BankResolveResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BankResolveResult value)  $default,){
final _that = this;
switch (_that) {
case _BankResolveResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BankResolveResult value)?  $default,){
final _that = this;
switch (_that) {
case _BankResolveResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'account_number')  String accountNumber, @JsonKey(name: 'bank_code')  String bankCode, @JsonKey(name: 'account_name')  String accountName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BankResolveResult() when $default != null:
return $default(_that.accountNumber,_that.bankCode,_that.accountName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'account_number')  String accountNumber, @JsonKey(name: 'bank_code')  String bankCode, @JsonKey(name: 'account_name')  String accountName)  $default,) {final _that = this;
switch (_that) {
case _BankResolveResult():
return $default(_that.accountNumber,_that.bankCode,_that.accountName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'account_number')  String accountNumber, @JsonKey(name: 'bank_code')  String bankCode, @JsonKey(name: 'account_name')  String accountName)?  $default,) {final _that = this;
switch (_that) {
case _BankResolveResult() when $default != null:
return $default(_that.accountNumber,_that.bankCode,_that.accountName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BankResolveResult implements BankResolveResult {
  const _BankResolveResult({@JsonKey(name: 'account_number') required this.accountNumber, @JsonKey(name: 'bank_code') required this.bankCode, @JsonKey(name: 'account_name') required this.accountName});
  factory _BankResolveResult.fromJson(Map<String, dynamic> json) => _$BankResolveResultFromJson(json);

@override@JsonKey(name: 'account_number') final  String accountNumber;
@override@JsonKey(name: 'bank_code') final  String bankCode;
@override@JsonKey(name: 'account_name') final  String accountName;

/// Create a copy of BankResolveResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BankResolveResultCopyWith<_BankResolveResult> get copyWith => __$BankResolveResultCopyWithImpl<_BankResolveResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BankResolveResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BankResolveResult&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.bankCode, bankCode) || other.bankCode == bankCode)&&(identical(other.accountName, accountName) || other.accountName == accountName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accountNumber,bankCode,accountName);

@override
String toString() {
  return 'BankResolveResult(accountNumber: $accountNumber, bankCode: $bankCode, accountName: $accountName)';
}


}

/// @nodoc
abstract mixin class _$BankResolveResultCopyWith<$Res> implements $BankResolveResultCopyWith<$Res> {
  factory _$BankResolveResultCopyWith(_BankResolveResult value, $Res Function(_BankResolveResult) _then) = __$BankResolveResultCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'account_number') String accountNumber,@JsonKey(name: 'bank_code') String bankCode,@JsonKey(name: 'account_name') String accountName
});




}
/// @nodoc
class __$BankResolveResultCopyWithImpl<$Res>
    implements _$BankResolveResultCopyWith<$Res> {
  __$BankResolveResultCopyWithImpl(this._self, this._then);

  final _BankResolveResult _self;
  final $Res Function(_BankResolveResult) _then;

/// Create a copy of BankResolveResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accountNumber = null,Object? bankCode = null,Object? accountName = null,}) {
  return _then(_BankResolveResult(
accountNumber: null == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String,bankCode: null == bankCode ? _self.bankCode : bankCode // ignore: cast_nullable_to_non_nullable
as String,accountName: null == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$InitializePurchaseResponse {

@JsonKey(name: 'tx_ref') String get txRef;@JsonKey(name: 'flutterwave_ref') String? get flutterwaveRef; String? get status;@JsonKey(name: 'requires_otp') bool get requiresOtp;@JsonKey(name: 'public_key') String get publicKey; double? get amount; String? get currency;@JsonKey(name: 'customer_email') String? get customerEmail;@JsonKey(name: 'customer_name') String? get customerName;
/// Create a copy of InitializePurchaseResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InitializePurchaseResponseCopyWith<InitializePurchaseResponse> get copyWith => _$InitializePurchaseResponseCopyWithImpl<InitializePurchaseResponse>(this as InitializePurchaseResponse, _$identity);

  /// Serializes this InitializePurchaseResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InitializePurchaseResponse&&(identical(other.txRef, txRef) || other.txRef == txRef)&&(identical(other.flutterwaveRef, flutterwaveRef) || other.flutterwaveRef == flutterwaveRef)&&(identical(other.status, status) || other.status == status)&&(identical(other.requiresOtp, requiresOtp) || other.requiresOtp == requiresOtp)&&(identical(other.publicKey, publicKey) || other.publicKey == publicKey)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.customerEmail, customerEmail) || other.customerEmail == customerEmail)&&(identical(other.customerName, customerName) || other.customerName == customerName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,txRef,flutterwaveRef,status,requiresOtp,publicKey,amount,currency,customerEmail,customerName);

@override
String toString() {
  return 'InitializePurchaseResponse(txRef: $txRef, flutterwaveRef: $flutterwaveRef, status: $status, requiresOtp: $requiresOtp, publicKey: $publicKey, amount: $amount, currency: $currency, customerEmail: $customerEmail, customerName: $customerName)';
}


}

/// @nodoc
abstract mixin class $InitializePurchaseResponseCopyWith<$Res>  {
  factory $InitializePurchaseResponseCopyWith(InitializePurchaseResponse value, $Res Function(InitializePurchaseResponse) _then) = _$InitializePurchaseResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'tx_ref') String txRef,@JsonKey(name: 'flutterwave_ref') String? flutterwaveRef, String? status,@JsonKey(name: 'requires_otp') bool requiresOtp,@JsonKey(name: 'public_key') String publicKey, double? amount, String? currency,@JsonKey(name: 'customer_email') String? customerEmail,@JsonKey(name: 'customer_name') String? customerName
});




}
/// @nodoc
class _$InitializePurchaseResponseCopyWithImpl<$Res>
    implements $InitializePurchaseResponseCopyWith<$Res> {
  _$InitializePurchaseResponseCopyWithImpl(this._self, this._then);

  final InitializePurchaseResponse _self;
  final $Res Function(InitializePurchaseResponse) _then;

/// Create a copy of InitializePurchaseResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? txRef = null,Object? flutterwaveRef = freezed,Object? status = freezed,Object? requiresOtp = null,Object? publicKey = null,Object? amount = freezed,Object? currency = freezed,Object? customerEmail = freezed,Object? customerName = freezed,}) {
  return _then(_self.copyWith(
txRef: null == txRef ? _self.txRef : txRef // ignore: cast_nullable_to_non_nullable
as String,flutterwaveRef: freezed == flutterwaveRef ? _self.flutterwaveRef : flutterwaveRef // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,requiresOtp: null == requiresOtp ? _self.requiresOtp : requiresOtp // ignore: cast_nullable_to_non_nullable
as bool,publicKey: null == publicKey ? _self.publicKey : publicKey // ignore: cast_nullable_to_non_nullable
as String,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double?,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,customerEmail: freezed == customerEmail ? _self.customerEmail : customerEmail // ignore: cast_nullable_to_non_nullable
as String?,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [InitializePurchaseResponse].
extension InitializePurchaseResponsePatterns on InitializePurchaseResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InitializePurchaseResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InitializePurchaseResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InitializePurchaseResponse value)  $default,){
final _that = this;
switch (_that) {
case _InitializePurchaseResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InitializePurchaseResponse value)?  $default,){
final _that = this;
switch (_that) {
case _InitializePurchaseResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'tx_ref')  String txRef, @JsonKey(name: 'flutterwave_ref')  String? flutterwaveRef,  String? status, @JsonKey(name: 'requires_otp')  bool requiresOtp, @JsonKey(name: 'public_key')  String publicKey,  double? amount,  String? currency, @JsonKey(name: 'customer_email')  String? customerEmail, @JsonKey(name: 'customer_name')  String? customerName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InitializePurchaseResponse() when $default != null:
return $default(_that.txRef,_that.flutterwaveRef,_that.status,_that.requiresOtp,_that.publicKey,_that.amount,_that.currency,_that.customerEmail,_that.customerName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'tx_ref')  String txRef, @JsonKey(name: 'flutterwave_ref')  String? flutterwaveRef,  String? status, @JsonKey(name: 'requires_otp')  bool requiresOtp, @JsonKey(name: 'public_key')  String publicKey,  double? amount,  String? currency, @JsonKey(name: 'customer_email')  String? customerEmail, @JsonKey(name: 'customer_name')  String? customerName)  $default,) {final _that = this;
switch (_that) {
case _InitializePurchaseResponse():
return $default(_that.txRef,_that.flutterwaveRef,_that.status,_that.requiresOtp,_that.publicKey,_that.amount,_that.currency,_that.customerEmail,_that.customerName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'tx_ref')  String txRef, @JsonKey(name: 'flutterwave_ref')  String? flutterwaveRef,  String? status, @JsonKey(name: 'requires_otp')  bool requiresOtp, @JsonKey(name: 'public_key')  String publicKey,  double? amount,  String? currency, @JsonKey(name: 'customer_email')  String? customerEmail, @JsonKey(name: 'customer_name')  String? customerName)?  $default,) {final _that = this;
switch (_that) {
case _InitializePurchaseResponse() when $default != null:
return $default(_that.txRef,_that.flutterwaveRef,_that.status,_that.requiresOtp,_that.publicKey,_that.amount,_that.currency,_that.customerEmail,_that.customerName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InitializePurchaseResponse implements InitializePurchaseResponse {
  const _InitializePurchaseResponse({@JsonKey(name: 'tx_ref') required this.txRef, @JsonKey(name: 'flutterwave_ref') this.flutterwaveRef, this.status, @JsonKey(name: 'requires_otp') this.requiresOtp = false, @JsonKey(name: 'public_key') required this.publicKey, this.amount, this.currency, @JsonKey(name: 'customer_email') this.customerEmail, @JsonKey(name: 'customer_name') this.customerName});
  factory _InitializePurchaseResponse.fromJson(Map<String, dynamic> json) => _$InitializePurchaseResponseFromJson(json);

@override@JsonKey(name: 'tx_ref') final  String txRef;
@override@JsonKey(name: 'flutterwave_ref') final  String? flutterwaveRef;
@override final  String? status;
@override@JsonKey(name: 'requires_otp') final  bool requiresOtp;
@override@JsonKey(name: 'public_key') final  String publicKey;
@override final  double? amount;
@override final  String? currency;
@override@JsonKey(name: 'customer_email') final  String? customerEmail;
@override@JsonKey(name: 'customer_name') final  String? customerName;

/// Create a copy of InitializePurchaseResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InitializePurchaseResponseCopyWith<_InitializePurchaseResponse> get copyWith => __$InitializePurchaseResponseCopyWithImpl<_InitializePurchaseResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InitializePurchaseResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InitializePurchaseResponse&&(identical(other.txRef, txRef) || other.txRef == txRef)&&(identical(other.flutterwaveRef, flutterwaveRef) || other.flutterwaveRef == flutterwaveRef)&&(identical(other.status, status) || other.status == status)&&(identical(other.requiresOtp, requiresOtp) || other.requiresOtp == requiresOtp)&&(identical(other.publicKey, publicKey) || other.publicKey == publicKey)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.customerEmail, customerEmail) || other.customerEmail == customerEmail)&&(identical(other.customerName, customerName) || other.customerName == customerName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,txRef,flutterwaveRef,status,requiresOtp,publicKey,amount,currency,customerEmail,customerName);

@override
String toString() {
  return 'InitializePurchaseResponse(txRef: $txRef, flutterwaveRef: $flutterwaveRef, status: $status, requiresOtp: $requiresOtp, publicKey: $publicKey, amount: $amount, currency: $currency, customerEmail: $customerEmail, customerName: $customerName)';
}


}

/// @nodoc
abstract mixin class _$InitializePurchaseResponseCopyWith<$Res> implements $InitializePurchaseResponseCopyWith<$Res> {
  factory _$InitializePurchaseResponseCopyWith(_InitializePurchaseResponse value, $Res Function(_InitializePurchaseResponse) _then) = __$InitializePurchaseResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'tx_ref') String txRef,@JsonKey(name: 'flutterwave_ref') String? flutterwaveRef, String? status,@JsonKey(name: 'requires_otp') bool requiresOtp,@JsonKey(name: 'public_key') String publicKey, double? amount, String? currency,@JsonKey(name: 'customer_email') String? customerEmail,@JsonKey(name: 'customer_name') String? customerName
});




}
/// @nodoc
class __$InitializePurchaseResponseCopyWithImpl<$Res>
    implements _$InitializePurchaseResponseCopyWith<$Res> {
  __$InitializePurchaseResponseCopyWithImpl(this._self, this._then);

  final _InitializePurchaseResponse _self;
  final $Res Function(_InitializePurchaseResponse) _then;

/// Create a copy of InitializePurchaseResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? txRef = null,Object? flutterwaveRef = freezed,Object? status = freezed,Object? requiresOtp = null,Object? publicKey = null,Object? amount = freezed,Object? currency = freezed,Object? customerEmail = freezed,Object? customerName = freezed,}) {
  return _then(_InitializePurchaseResponse(
txRef: null == txRef ? _self.txRef : txRef // ignore: cast_nullable_to_non_nullable
as String,flutterwaveRef: freezed == flutterwaveRef ? _self.flutterwaveRef : flutterwaveRef // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,requiresOtp: null == requiresOtp ? _self.requiresOtp : requiresOtp // ignore: cast_nullable_to_non_nullable
as bool,publicKey: null == publicKey ? _self.publicKey : publicKey // ignore: cast_nullable_to_non_nullable
as String,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double?,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,customerEmail: freezed == customerEmail ? _self.customerEmail : customerEmail // ignore: cast_nullable_to_non_nullable
as String?,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ConfirmPurchaseResponse {

 ArtifactTransaction get transaction;@JsonKey(name: 'new_balance') Map<String, int> get newBalance;
/// Create a copy of ConfirmPurchaseResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConfirmPurchaseResponseCopyWith<ConfirmPurchaseResponse> get copyWith => _$ConfirmPurchaseResponseCopyWithImpl<ConfirmPurchaseResponse>(this as ConfirmPurchaseResponse, _$identity);

  /// Serializes this ConfirmPurchaseResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConfirmPurchaseResponse&&(identical(other.transaction, transaction) || other.transaction == transaction)&&const DeepCollectionEquality().equals(other.newBalance, newBalance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,transaction,const DeepCollectionEquality().hash(newBalance));

@override
String toString() {
  return 'ConfirmPurchaseResponse(transaction: $transaction, newBalance: $newBalance)';
}


}

/// @nodoc
abstract mixin class $ConfirmPurchaseResponseCopyWith<$Res>  {
  factory $ConfirmPurchaseResponseCopyWith(ConfirmPurchaseResponse value, $Res Function(ConfirmPurchaseResponse) _then) = _$ConfirmPurchaseResponseCopyWithImpl;
@useResult
$Res call({
 ArtifactTransaction transaction,@JsonKey(name: 'new_balance') Map<String, int> newBalance
});


$ArtifactTransactionCopyWith<$Res> get transaction;

}
/// @nodoc
class _$ConfirmPurchaseResponseCopyWithImpl<$Res>
    implements $ConfirmPurchaseResponseCopyWith<$Res> {
  _$ConfirmPurchaseResponseCopyWithImpl(this._self, this._then);

  final ConfirmPurchaseResponse _self;
  final $Res Function(ConfirmPurchaseResponse) _then;

/// Create a copy of ConfirmPurchaseResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? transaction = null,Object? newBalance = null,}) {
  return _then(_self.copyWith(
transaction: null == transaction ? _self.transaction : transaction // ignore: cast_nullable_to_non_nullable
as ArtifactTransaction,newBalance: null == newBalance ? _self.newBalance : newBalance // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}
/// Create a copy of ConfirmPurchaseResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ArtifactTransactionCopyWith<$Res> get transaction {
  
  return $ArtifactTransactionCopyWith<$Res>(_self.transaction, (value) {
    return _then(_self.copyWith(transaction: value));
  });
}
}


/// Adds pattern-matching-related methods to [ConfirmPurchaseResponse].
extension ConfirmPurchaseResponsePatterns on ConfirmPurchaseResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConfirmPurchaseResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConfirmPurchaseResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConfirmPurchaseResponse value)  $default,){
final _that = this;
switch (_that) {
case _ConfirmPurchaseResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConfirmPurchaseResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ConfirmPurchaseResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ArtifactTransaction transaction, @JsonKey(name: 'new_balance')  Map<String, int> newBalance)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConfirmPurchaseResponse() when $default != null:
return $default(_that.transaction,_that.newBalance);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ArtifactTransaction transaction, @JsonKey(name: 'new_balance')  Map<String, int> newBalance)  $default,) {final _that = this;
switch (_that) {
case _ConfirmPurchaseResponse():
return $default(_that.transaction,_that.newBalance);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ArtifactTransaction transaction, @JsonKey(name: 'new_balance')  Map<String, int> newBalance)?  $default,) {final _that = this;
switch (_that) {
case _ConfirmPurchaseResponse() when $default != null:
return $default(_that.transaction,_that.newBalance);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConfirmPurchaseResponse implements ConfirmPurchaseResponse {
  const _ConfirmPurchaseResponse({required this.transaction, @JsonKey(name: 'new_balance') required final  Map<String, int> newBalance}): _newBalance = newBalance;
  factory _ConfirmPurchaseResponse.fromJson(Map<String, dynamic> json) => _$ConfirmPurchaseResponseFromJson(json);

@override final  ArtifactTransaction transaction;
 final  Map<String, int> _newBalance;
@override@JsonKey(name: 'new_balance') Map<String, int> get newBalance {
  if (_newBalance is EqualUnmodifiableMapView) return _newBalance;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_newBalance);
}


/// Create a copy of ConfirmPurchaseResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConfirmPurchaseResponseCopyWith<_ConfirmPurchaseResponse> get copyWith => __$ConfirmPurchaseResponseCopyWithImpl<_ConfirmPurchaseResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConfirmPurchaseResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConfirmPurchaseResponse&&(identical(other.transaction, transaction) || other.transaction == transaction)&&const DeepCollectionEquality().equals(other._newBalance, _newBalance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,transaction,const DeepCollectionEquality().hash(_newBalance));

@override
String toString() {
  return 'ConfirmPurchaseResponse(transaction: $transaction, newBalance: $newBalance)';
}


}

/// @nodoc
abstract mixin class _$ConfirmPurchaseResponseCopyWith<$Res> implements $ConfirmPurchaseResponseCopyWith<$Res> {
  factory _$ConfirmPurchaseResponseCopyWith(_ConfirmPurchaseResponse value, $Res Function(_ConfirmPurchaseResponse) _then) = __$ConfirmPurchaseResponseCopyWithImpl;
@override @useResult
$Res call({
 ArtifactTransaction transaction,@JsonKey(name: 'new_balance') Map<String, int> newBalance
});


@override $ArtifactTransactionCopyWith<$Res> get transaction;

}
/// @nodoc
class __$ConfirmPurchaseResponseCopyWithImpl<$Res>
    implements _$ConfirmPurchaseResponseCopyWith<$Res> {
  __$ConfirmPurchaseResponseCopyWithImpl(this._self, this._then);

  final _ConfirmPurchaseResponse _self;
  final $Res Function(_ConfirmPurchaseResponse) _then;

/// Create a copy of ConfirmPurchaseResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? transaction = null,Object? newBalance = null,}) {
  return _then(_ConfirmPurchaseResponse(
transaction: null == transaction ? _self.transaction : transaction // ignore: cast_nullable_to_non_nullable
as ArtifactTransaction,newBalance: null == newBalance ? _self._newBalance : newBalance // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}

/// Create a copy of ConfirmPurchaseResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ArtifactTransactionCopyWith<$Res> get transaction {
  
  return $ArtifactTransactionCopyWith<$Res>(_self.transaction, (value) {
    return _then(_self.copyWith(transaction: value));
  });
}
}


/// @nodoc
mixin _$ExchangeRates {

 Map<String, double> get rates;@JsonKey(name: 'base_currency') String get baseCurrency;@JsonKey(name: 'local_currency') String get localCurrency;@JsonKey(name: 'conversion_rate') double get conversionRate; Map<String, String> get labels;
/// Create a copy of ExchangeRates
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExchangeRatesCopyWith<ExchangeRates> get copyWith => _$ExchangeRatesCopyWithImpl<ExchangeRates>(this as ExchangeRates, _$identity);

  /// Serializes this ExchangeRates to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExchangeRates&&const DeepCollectionEquality().equals(other.rates, rates)&&(identical(other.baseCurrency, baseCurrency) || other.baseCurrency == baseCurrency)&&(identical(other.localCurrency, localCurrency) || other.localCurrency == localCurrency)&&(identical(other.conversionRate, conversionRate) || other.conversionRate == conversionRate)&&const DeepCollectionEquality().equals(other.labels, labels));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(rates),baseCurrency,localCurrency,conversionRate,const DeepCollectionEquality().hash(labels));

@override
String toString() {
  return 'ExchangeRates(rates: $rates, baseCurrency: $baseCurrency, localCurrency: $localCurrency, conversionRate: $conversionRate, labels: $labels)';
}


}

/// @nodoc
abstract mixin class $ExchangeRatesCopyWith<$Res>  {
  factory $ExchangeRatesCopyWith(ExchangeRates value, $Res Function(ExchangeRates) _then) = _$ExchangeRatesCopyWithImpl;
@useResult
$Res call({
 Map<String, double> rates,@JsonKey(name: 'base_currency') String baseCurrency,@JsonKey(name: 'local_currency') String localCurrency,@JsonKey(name: 'conversion_rate') double conversionRate, Map<String, String> labels
});




}
/// @nodoc
class _$ExchangeRatesCopyWithImpl<$Res>
    implements $ExchangeRatesCopyWith<$Res> {
  _$ExchangeRatesCopyWithImpl(this._self, this._then);

  final ExchangeRates _self;
  final $Res Function(ExchangeRates) _then;

/// Create a copy of ExchangeRates
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rates = null,Object? baseCurrency = null,Object? localCurrency = null,Object? conversionRate = null,Object? labels = null,}) {
  return _then(_self.copyWith(
rates: null == rates ? _self.rates : rates // ignore: cast_nullable_to_non_nullable
as Map<String, double>,baseCurrency: null == baseCurrency ? _self.baseCurrency : baseCurrency // ignore: cast_nullable_to_non_nullable
as String,localCurrency: null == localCurrency ? _self.localCurrency : localCurrency // ignore: cast_nullable_to_non_nullable
as String,conversionRate: null == conversionRate ? _self.conversionRate : conversionRate // ignore: cast_nullable_to_non_nullable
as double,labels: null == labels ? _self.labels : labels // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ExchangeRates].
extension ExchangeRatesPatterns on ExchangeRates {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExchangeRates value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExchangeRates() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExchangeRates value)  $default,){
final _that = this;
switch (_that) {
case _ExchangeRates():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExchangeRates value)?  $default,){
final _that = this;
switch (_that) {
case _ExchangeRates() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, double> rates, @JsonKey(name: 'base_currency')  String baseCurrency, @JsonKey(name: 'local_currency')  String localCurrency, @JsonKey(name: 'conversion_rate')  double conversionRate,  Map<String, String> labels)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExchangeRates() when $default != null:
return $default(_that.rates,_that.baseCurrency,_that.localCurrency,_that.conversionRate,_that.labels);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, double> rates, @JsonKey(name: 'base_currency')  String baseCurrency, @JsonKey(name: 'local_currency')  String localCurrency, @JsonKey(name: 'conversion_rate')  double conversionRate,  Map<String, String> labels)  $default,) {final _that = this;
switch (_that) {
case _ExchangeRates():
return $default(_that.rates,_that.baseCurrency,_that.localCurrency,_that.conversionRate,_that.labels);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, double> rates, @JsonKey(name: 'base_currency')  String baseCurrency, @JsonKey(name: 'local_currency')  String localCurrency, @JsonKey(name: 'conversion_rate')  double conversionRate,  Map<String, String> labels)?  $default,) {final _that = this;
switch (_that) {
case _ExchangeRates() when $default != null:
return $default(_that.rates,_that.baseCurrency,_that.localCurrency,_that.conversionRate,_that.labels);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExchangeRates implements ExchangeRates {
  const _ExchangeRates({required final  Map<String, double> rates, @JsonKey(name: 'base_currency') required this.baseCurrency, @JsonKey(name: 'local_currency') required this.localCurrency, @JsonKey(name: 'conversion_rate') required this.conversionRate, required final  Map<String, String> labels}): _rates = rates,_labels = labels;
  factory _ExchangeRates.fromJson(Map<String, dynamic> json) => _$ExchangeRatesFromJson(json);

 final  Map<String, double> _rates;
@override Map<String, double> get rates {
  if (_rates is EqualUnmodifiableMapView) return _rates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_rates);
}

@override@JsonKey(name: 'base_currency') final  String baseCurrency;
@override@JsonKey(name: 'local_currency') final  String localCurrency;
@override@JsonKey(name: 'conversion_rate') final  double conversionRate;
 final  Map<String, String> _labels;
@override Map<String, String> get labels {
  if (_labels is EqualUnmodifiableMapView) return _labels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_labels);
}


/// Create a copy of ExchangeRates
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExchangeRatesCopyWith<_ExchangeRates> get copyWith => __$ExchangeRatesCopyWithImpl<_ExchangeRates>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExchangeRatesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExchangeRates&&const DeepCollectionEquality().equals(other._rates, _rates)&&(identical(other.baseCurrency, baseCurrency) || other.baseCurrency == baseCurrency)&&(identical(other.localCurrency, localCurrency) || other.localCurrency == localCurrency)&&(identical(other.conversionRate, conversionRate) || other.conversionRate == conversionRate)&&const DeepCollectionEquality().equals(other._labels, _labels));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_rates),baseCurrency,localCurrency,conversionRate,const DeepCollectionEquality().hash(_labels));

@override
String toString() {
  return 'ExchangeRates(rates: $rates, baseCurrency: $baseCurrency, localCurrency: $localCurrency, conversionRate: $conversionRate, labels: $labels)';
}


}

/// @nodoc
abstract mixin class _$ExchangeRatesCopyWith<$Res> implements $ExchangeRatesCopyWith<$Res> {
  factory _$ExchangeRatesCopyWith(_ExchangeRates value, $Res Function(_ExchangeRates) _then) = __$ExchangeRatesCopyWithImpl;
@override @useResult
$Res call({
 Map<String, double> rates,@JsonKey(name: 'base_currency') String baseCurrency,@JsonKey(name: 'local_currency') String localCurrency,@JsonKey(name: 'conversion_rate') double conversionRate, Map<String, String> labels
});




}
/// @nodoc
class __$ExchangeRatesCopyWithImpl<$Res>
    implements _$ExchangeRatesCopyWith<$Res> {
  __$ExchangeRatesCopyWithImpl(this._self, this._then);

  final _ExchangeRates _self;
  final $Res Function(_ExchangeRates) _then;

/// Create a copy of ExchangeRates
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rates = null,Object? baseCurrency = null,Object? localCurrency = null,Object? conversionRate = null,Object? labels = null,}) {
  return _then(_ExchangeRates(
rates: null == rates ? _self._rates : rates // ignore: cast_nullable_to_non_nullable
as Map<String, double>,baseCurrency: null == baseCurrency ? _self.baseCurrency : baseCurrency // ignore: cast_nullable_to_non_nullable
as String,localCurrency: null == localCurrency ? _self.localCurrency : localCurrency // ignore: cast_nullable_to_non_nullable
as String,conversionRate: null == conversionRate ? _self.conversionRate : conversionRate // ignore: cast_nullable_to_non_nullable
as double,labels: null == labels ? _self._labels : labels // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

// dart format on
