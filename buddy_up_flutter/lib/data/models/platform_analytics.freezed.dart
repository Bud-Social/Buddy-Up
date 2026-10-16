// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'platform_analytics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AnalyticsWindow {

@JsonKey(name: 'from') String get fromDate;@JsonKey(name: 'to') String get toDate; int get days; String get basis; String get timezone;/// "All time" for a gauge, "Window" for a flow, and the date range for
/// everything else.
 String get label;
/// Create a copy of AnalyticsWindow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalyticsWindowCopyWith<AnalyticsWindow> get copyWith => _$AnalyticsWindowCopyWithImpl<AnalyticsWindow>(this as AnalyticsWindow, _$identity);

  /// Serializes this AnalyticsWindow to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalyticsWindow&&(identical(other.fromDate, fromDate) || other.fromDate == fromDate)&&(identical(other.toDate, toDate) || other.toDate == toDate)&&(identical(other.days, days) || other.days == days)&&(identical(other.basis, basis) || other.basis == basis)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fromDate,toDate,days,basis,timezone,label);

@override
String toString() {
  return 'AnalyticsWindow(fromDate: $fromDate, toDate: $toDate, days: $days, basis: $basis, timezone: $timezone, label: $label)';
}


}

/// @nodoc
abstract mixin class $AnalyticsWindowCopyWith<$Res>  {
  factory $AnalyticsWindowCopyWith(AnalyticsWindow value, $Res Function(AnalyticsWindow) _then) = _$AnalyticsWindowCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'from') String fromDate,@JsonKey(name: 'to') String toDate, int days, String basis, String timezone, String label
});




}
/// @nodoc
class _$AnalyticsWindowCopyWithImpl<$Res>
    implements $AnalyticsWindowCopyWith<$Res> {
  _$AnalyticsWindowCopyWithImpl(this._self, this._then);

  final AnalyticsWindow _self;
  final $Res Function(AnalyticsWindow) _then;

/// Create a copy of AnalyticsWindow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fromDate = null,Object? toDate = null,Object? days = null,Object? basis = null,Object? timezone = null,Object? label = null,}) {
  return _then(_self.copyWith(
fromDate: null == fromDate ? _self.fromDate : fromDate // ignore: cast_nullable_to_non_nullable
as String,toDate: null == toDate ? _self.toDate : toDate // ignore: cast_nullable_to_non_nullable
as String,days: null == days ? _self.days : days // ignore: cast_nullable_to_non_nullable
as int,basis: null == basis ? _self.basis : basis // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AnalyticsWindow].
extension AnalyticsWindowPatterns on AnalyticsWindow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalyticsWindow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalyticsWindow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalyticsWindow value)  $default,){
final _that = this;
switch (_that) {
case _AnalyticsWindow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalyticsWindow value)?  $default,){
final _that = this;
switch (_that) {
case _AnalyticsWindow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'from')  String fromDate, @JsonKey(name: 'to')  String toDate,  int days,  String basis,  String timezone,  String label)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalyticsWindow() when $default != null:
return $default(_that.fromDate,_that.toDate,_that.days,_that.basis,_that.timezone,_that.label);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'from')  String fromDate, @JsonKey(name: 'to')  String toDate,  int days,  String basis,  String timezone,  String label)  $default,) {final _that = this;
switch (_that) {
case _AnalyticsWindow():
return $default(_that.fromDate,_that.toDate,_that.days,_that.basis,_that.timezone,_that.label);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'from')  String fromDate, @JsonKey(name: 'to')  String toDate,  int days,  String basis,  String timezone,  String label)?  $default,) {final _that = this;
switch (_that) {
case _AnalyticsWindow() when $default != null:
return $default(_that.fromDate,_that.toDate,_that.days,_that.basis,_that.timezone,_that.label);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnalyticsWindow implements AnalyticsWindow {
  const _AnalyticsWindow({@JsonKey(name: 'from') this.fromDate = '', @JsonKey(name: 'to') this.toDate = '', this.days = 0, this.basis = '', this.timezone = '', this.label = ''});
  factory _AnalyticsWindow.fromJson(Map<String, dynamic> json) => _$AnalyticsWindowFromJson(json);

@override@JsonKey(name: 'from') final  String fromDate;
@override@JsonKey(name: 'to') final  String toDate;
@override@JsonKey() final  int days;
@override@JsonKey() final  String basis;
@override@JsonKey() final  String timezone;
/// "All time" for a gauge, "Window" for a flow, and the date range for
/// everything else.
@override@JsonKey() final  String label;

/// Create a copy of AnalyticsWindow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalyticsWindowCopyWith<_AnalyticsWindow> get copyWith => __$AnalyticsWindowCopyWithImpl<_AnalyticsWindow>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnalyticsWindowToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalyticsWindow&&(identical(other.fromDate, fromDate) || other.fromDate == fromDate)&&(identical(other.toDate, toDate) || other.toDate == toDate)&&(identical(other.days, days) || other.days == days)&&(identical(other.basis, basis) || other.basis == basis)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fromDate,toDate,days,basis,timezone,label);

@override
String toString() {
  return 'AnalyticsWindow(fromDate: $fromDate, toDate: $toDate, days: $days, basis: $basis, timezone: $timezone, label: $label)';
}


}

/// @nodoc
abstract mixin class _$AnalyticsWindowCopyWith<$Res> implements $AnalyticsWindowCopyWith<$Res> {
  factory _$AnalyticsWindowCopyWith(_AnalyticsWindow value, $Res Function(_AnalyticsWindow) _then) = __$AnalyticsWindowCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'from') String fromDate,@JsonKey(name: 'to') String toDate, int days, String basis, String timezone, String label
});




}
/// @nodoc
class __$AnalyticsWindowCopyWithImpl<$Res>
    implements _$AnalyticsWindowCopyWith<$Res> {
  __$AnalyticsWindowCopyWithImpl(this._self, this._then);

  final _AnalyticsWindow _self;
  final $Res Function(_AnalyticsWindow) _then;

/// Create a copy of AnalyticsWindow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fromDate = null,Object? toDate = null,Object? days = null,Object? basis = null,Object? timezone = null,Object? label = null,}) {
  return _then(_AnalyticsWindow(
fromDate: null == fromDate ? _self.fromDate : fromDate // ignore: cast_nullable_to_non_nullable
as String,toDate: null == toDate ? _self.toDate : toDate // ignore: cast_nullable_to_non_nullable
as String,days: null == days ? _self.days : days // ignore: cast_nullable_to_non_nullable
as int,basis: null == basis ? _self.basis : basis // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$AnalyticsTable {

 List<String> get columns;@JsonKey(name: 'rows', fromJson: _tableRows) List<List<Object?>> get rows;
/// Create a copy of AnalyticsTable
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalyticsTableCopyWith<AnalyticsTable> get copyWith => _$AnalyticsTableCopyWithImpl<AnalyticsTable>(this as AnalyticsTable, _$identity);

  /// Serializes this AnalyticsTable to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalyticsTable&&const DeepCollectionEquality().equals(other.columns, columns)&&const DeepCollectionEquality().equals(other.rows, rows));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(columns),const DeepCollectionEquality().hash(rows));

@override
String toString() {
  return 'AnalyticsTable(columns: $columns, rows: $rows)';
}


}

/// @nodoc
abstract mixin class $AnalyticsTableCopyWith<$Res>  {
  factory $AnalyticsTableCopyWith(AnalyticsTable value, $Res Function(AnalyticsTable) _then) = _$AnalyticsTableCopyWithImpl;
@useResult
$Res call({
 List<String> columns,@JsonKey(name: 'rows', fromJson: _tableRows) List<List<Object?>> rows
});




}
/// @nodoc
class _$AnalyticsTableCopyWithImpl<$Res>
    implements $AnalyticsTableCopyWith<$Res> {
  _$AnalyticsTableCopyWithImpl(this._self, this._then);

  final AnalyticsTable _self;
  final $Res Function(AnalyticsTable) _then;

/// Create a copy of AnalyticsTable
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? columns = null,Object? rows = null,}) {
  return _then(_self.copyWith(
columns: null == columns ? _self.columns : columns // ignore: cast_nullable_to_non_nullable
as List<String>,rows: null == rows ? _self.rows : rows // ignore: cast_nullable_to_non_nullable
as List<List<Object?>>,
  ));
}

}


/// Adds pattern-matching-related methods to [AnalyticsTable].
extension AnalyticsTablePatterns on AnalyticsTable {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalyticsTable value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalyticsTable() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalyticsTable value)  $default,){
final _that = this;
switch (_that) {
case _AnalyticsTable():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalyticsTable value)?  $default,){
final _that = this;
switch (_that) {
case _AnalyticsTable() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> columns, @JsonKey(name: 'rows', fromJson: _tableRows)  List<List<Object?>> rows)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalyticsTable() when $default != null:
return $default(_that.columns,_that.rows);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> columns, @JsonKey(name: 'rows', fromJson: _tableRows)  List<List<Object?>> rows)  $default,) {final _that = this;
switch (_that) {
case _AnalyticsTable():
return $default(_that.columns,_that.rows);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> columns, @JsonKey(name: 'rows', fromJson: _tableRows)  List<List<Object?>> rows)?  $default,) {final _that = this;
switch (_that) {
case _AnalyticsTable() when $default != null:
return $default(_that.columns,_that.rows);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnalyticsTable implements AnalyticsTable {
  const _AnalyticsTable({final  List<String> columns = const <String>[], @JsonKey(name: 'rows', fromJson: _tableRows) final  List<List<Object?>> rows = const <List<Object?>>[]}): _columns = columns,_rows = rows;
  factory _AnalyticsTable.fromJson(Map<String, dynamic> json) => _$AnalyticsTableFromJson(json);

 final  List<String> _columns;
@override@JsonKey() List<String> get columns {
  if (_columns is EqualUnmodifiableListView) return _columns;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_columns);
}

 final  List<List<Object?>> _rows;
@override@JsonKey(name: 'rows', fromJson: _tableRows) List<List<Object?>> get rows {
  if (_rows is EqualUnmodifiableListView) return _rows;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rows);
}


/// Create a copy of AnalyticsTable
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalyticsTableCopyWith<_AnalyticsTable> get copyWith => __$AnalyticsTableCopyWithImpl<_AnalyticsTable>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnalyticsTableToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalyticsTable&&const DeepCollectionEquality().equals(other._columns, _columns)&&const DeepCollectionEquality().equals(other._rows, _rows));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_columns),const DeepCollectionEquality().hash(_rows));

@override
String toString() {
  return 'AnalyticsTable(columns: $columns, rows: $rows)';
}


}

/// @nodoc
abstract mixin class _$AnalyticsTableCopyWith<$Res> implements $AnalyticsTableCopyWith<$Res> {
  factory _$AnalyticsTableCopyWith(_AnalyticsTable value, $Res Function(_AnalyticsTable) _then) = __$AnalyticsTableCopyWithImpl;
@override @useResult
$Res call({
 List<String> columns,@JsonKey(name: 'rows', fromJson: _tableRows) List<List<Object?>> rows
});




}
/// @nodoc
class __$AnalyticsTableCopyWithImpl<$Res>
    implements _$AnalyticsTableCopyWith<$Res> {
  __$AnalyticsTableCopyWithImpl(this._self, this._then);

  final _AnalyticsTable _self;
  final $Res Function(_AnalyticsTable) _then;

/// Create a copy of AnalyticsTable
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? columns = null,Object? rows = null,}) {
  return _then(_AnalyticsTable(
columns: null == columns ? _self._columns : columns // ignore: cast_nullable_to_non_nullable
as List<String>,rows: null == rows ? _self._rows : rows // ignore: cast_nullable_to_non_nullable
as List<List<Object?>>,
  ));
}


}


/// @nodoc
mixin _$AnalyticsKpi {

 String get key; String get label; String get group;/// `count` or `usd`.
 String get unit;@JsonKey(name: 'value', fromJson: _optNumOrZero) num get value; String get kind; AnalyticsWindow get window; String get source;/// False when the figure reads a column no index covers. Disclosed, not
/// hidden — see `performance_notes` on the overview.
 bool get indexed; String get note;@JsonKey(name: 'source_count') int? get sourceCount;
/// Create a copy of AnalyticsKpi
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalyticsKpiCopyWith<AnalyticsKpi> get copyWith => _$AnalyticsKpiCopyWithImpl<AnalyticsKpi>(this as AnalyticsKpi, _$identity);

  /// Serializes this AnalyticsKpi to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalyticsKpi&&(identical(other.key, key) || other.key == key)&&(identical(other.label, label) || other.label == label)&&(identical(other.group, group) || other.group == group)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.value, value) || other.value == value)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.window, window) || other.window == window)&&(identical(other.source, source) || other.source == source)&&(identical(other.indexed, indexed) || other.indexed == indexed)&&(identical(other.note, note) || other.note == note)&&(identical(other.sourceCount, sourceCount) || other.sourceCount == sourceCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,label,group,unit,value,kind,window,source,indexed,note,sourceCount);

@override
String toString() {
  return 'AnalyticsKpi(key: $key, label: $label, group: $group, unit: $unit, value: $value, kind: $kind, window: $window, source: $source, indexed: $indexed, note: $note, sourceCount: $sourceCount)';
}


}

/// @nodoc
abstract mixin class $AnalyticsKpiCopyWith<$Res>  {
  factory $AnalyticsKpiCopyWith(AnalyticsKpi value, $Res Function(AnalyticsKpi) _then) = _$AnalyticsKpiCopyWithImpl;
@useResult
$Res call({
 String key, String label, String group, String unit,@JsonKey(name: 'value', fromJson: _optNumOrZero) num value, String kind, AnalyticsWindow window, String source, bool indexed, String note,@JsonKey(name: 'source_count') int? sourceCount
});


$AnalyticsWindowCopyWith<$Res> get window;

}
/// @nodoc
class _$AnalyticsKpiCopyWithImpl<$Res>
    implements $AnalyticsKpiCopyWith<$Res> {
  _$AnalyticsKpiCopyWithImpl(this._self, this._then);

  final AnalyticsKpi _self;
  final $Res Function(AnalyticsKpi) _then;

/// Create a copy of AnalyticsKpi
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? label = null,Object? group = null,Object? unit = null,Object? value = null,Object? kind = null,Object? window = null,Object? source = null,Object? indexed = null,Object? note = null,Object? sourceCount = freezed,}) {
  return _then(_self.copyWith(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as num,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,window: null == window ? _self.window : window // ignore: cast_nullable_to_non_nullable
as AnalyticsWindow,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,indexed: null == indexed ? _self.indexed : indexed // ignore: cast_nullable_to_non_nullable
as bool,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,sourceCount: freezed == sourceCount ? _self.sourceCount : sourceCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of AnalyticsKpi
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsWindowCopyWith<$Res> get window {
  
  return $AnalyticsWindowCopyWith<$Res>(_self.window, (value) {
    return _then(_self.copyWith(window: value));
  });
}
}


/// Adds pattern-matching-related methods to [AnalyticsKpi].
extension AnalyticsKpiPatterns on AnalyticsKpi {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalyticsKpi value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalyticsKpi() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalyticsKpi value)  $default,){
final _that = this;
switch (_that) {
case _AnalyticsKpi():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalyticsKpi value)?  $default,){
final _that = this;
switch (_that) {
case _AnalyticsKpi() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String label,  String group,  String unit, @JsonKey(name: 'value', fromJson: _optNumOrZero)  num value,  String kind,  AnalyticsWindow window,  String source,  bool indexed,  String note, @JsonKey(name: 'source_count')  int? sourceCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalyticsKpi() when $default != null:
return $default(_that.key,_that.label,_that.group,_that.unit,_that.value,_that.kind,_that.window,_that.source,_that.indexed,_that.note,_that.sourceCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String label,  String group,  String unit, @JsonKey(name: 'value', fromJson: _optNumOrZero)  num value,  String kind,  AnalyticsWindow window,  String source,  bool indexed,  String note, @JsonKey(name: 'source_count')  int? sourceCount)  $default,) {final _that = this;
switch (_that) {
case _AnalyticsKpi():
return $default(_that.key,_that.label,_that.group,_that.unit,_that.value,_that.kind,_that.window,_that.source,_that.indexed,_that.note,_that.sourceCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String label,  String group,  String unit, @JsonKey(name: 'value', fromJson: _optNumOrZero)  num value,  String kind,  AnalyticsWindow window,  String source,  bool indexed,  String note, @JsonKey(name: 'source_count')  int? sourceCount)?  $default,) {final _that = this;
switch (_that) {
case _AnalyticsKpi() when $default != null:
return $default(_that.key,_that.label,_that.group,_that.unit,_that.value,_that.kind,_that.window,_that.source,_that.indexed,_that.note,_that.sourceCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnalyticsKpi implements AnalyticsKpi {
  const _AnalyticsKpi({this.key = '', this.label = '', this.group = '', this.unit = '', @JsonKey(name: 'value', fromJson: _optNumOrZero) this.value = 0, this.kind = 'gauge', this.window = const AnalyticsWindow(), this.source = '', this.indexed = true, this.note = '', @JsonKey(name: 'source_count') this.sourceCount});
  factory _AnalyticsKpi.fromJson(Map<String, dynamic> json) => _$AnalyticsKpiFromJson(json);

@override@JsonKey() final  String key;
@override@JsonKey() final  String label;
@override@JsonKey() final  String group;
/// `count` or `usd`.
@override@JsonKey() final  String unit;
@override@JsonKey(name: 'value', fromJson: _optNumOrZero) final  num value;
@override@JsonKey() final  String kind;
@override@JsonKey() final  AnalyticsWindow window;
@override@JsonKey() final  String source;
/// False when the figure reads a column no index covers. Disclosed, not
/// hidden — see `performance_notes` on the overview.
@override@JsonKey() final  bool indexed;
@override@JsonKey() final  String note;
@override@JsonKey(name: 'source_count') final  int? sourceCount;

/// Create a copy of AnalyticsKpi
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalyticsKpiCopyWith<_AnalyticsKpi> get copyWith => __$AnalyticsKpiCopyWithImpl<_AnalyticsKpi>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnalyticsKpiToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalyticsKpi&&(identical(other.key, key) || other.key == key)&&(identical(other.label, label) || other.label == label)&&(identical(other.group, group) || other.group == group)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.value, value) || other.value == value)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.window, window) || other.window == window)&&(identical(other.source, source) || other.source == source)&&(identical(other.indexed, indexed) || other.indexed == indexed)&&(identical(other.note, note) || other.note == note)&&(identical(other.sourceCount, sourceCount) || other.sourceCount == sourceCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,label,group,unit,value,kind,window,source,indexed,note,sourceCount);

@override
String toString() {
  return 'AnalyticsKpi(key: $key, label: $label, group: $group, unit: $unit, value: $value, kind: $kind, window: $window, source: $source, indexed: $indexed, note: $note, sourceCount: $sourceCount)';
}


}

/// @nodoc
abstract mixin class _$AnalyticsKpiCopyWith<$Res> implements $AnalyticsKpiCopyWith<$Res> {
  factory _$AnalyticsKpiCopyWith(_AnalyticsKpi value, $Res Function(_AnalyticsKpi) _then) = __$AnalyticsKpiCopyWithImpl;
@override @useResult
$Res call({
 String key, String label, String group, String unit,@JsonKey(name: 'value', fromJson: _optNumOrZero) num value, String kind, AnalyticsWindow window, String source, bool indexed, String note,@JsonKey(name: 'source_count') int? sourceCount
});


@override $AnalyticsWindowCopyWith<$Res> get window;

}
/// @nodoc
class __$AnalyticsKpiCopyWithImpl<$Res>
    implements _$AnalyticsKpiCopyWith<$Res> {
  __$AnalyticsKpiCopyWithImpl(this._self, this._then);

  final _AnalyticsKpi _self;
  final $Res Function(_AnalyticsKpi) _then;

/// Create a copy of AnalyticsKpi
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? label = null,Object? group = null,Object? unit = null,Object? value = null,Object? kind = null,Object? window = null,Object? source = null,Object? indexed = null,Object? note = null,Object? sourceCount = freezed,}) {
  return _then(_AnalyticsKpi(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as num,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,window: null == window ? _self.window : window // ignore: cast_nullable_to_non_nullable
as AnalyticsWindow,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,indexed: null == indexed ? _self.indexed : indexed // ignore: cast_nullable_to_non_nullable
as bool,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,sourceCount: freezed == sourceCount ? _self.sourceCount : sourceCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of AnalyticsKpi
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsWindowCopyWith<$Res> get window {
  
  return $AnalyticsWindowCopyWith<$Res>(_self.window, (value) {
    return _then(_self.copyWith(window: value));
  });
}
}


/// @nodoc
mixin _$AnalyticsPerformanceNote {

 String get source; String get issue;@JsonKey(name: 'suggested_migration') String get suggestedMigration; String get owner;
/// Create a copy of AnalyticsPerformanceNote
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalyticsPerformanceNoteCopyWith<AnalyticsPerformanceNote> get copyWith => _$AnalyticsPerformanceNoteCopyWithImpl<AnalyticsPerformanceNote>(this as AnalyticsPerformanceNote, _$identity);

  /// Serializes this AnalyticsPerformanceNote to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalyticsPerformanceNote&&(identical(other.source, source) || other.source == source)&&(identical(other.issue, issue) || other.issue == issue)&&(identical(other.suggestedMigration, suggestedMigration) || other.suggestedMigration == suggestedMigration)&&(identical(other.owner, owner) || other.owner == owner));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,source,issue,suggestedMigration,owner);

@override
String toString() {
  return 'AnalyticsPerformanceNote(source: $source, issue: $issue, suggestedMigration: $suggestedMigration, owner: $owner)';
}


}

/// @nodoc
abstract mixin class $AnalyticsPerformanceNoteCopyWith<$Res>  {
  factory $AnalyticsPerformanceNoteCopyWith(AnalyticsPerformanceNote value, $Res Function(AnalyticsPerformanceNote) _then) = _$AnalyticsPerformanceNoteCopyWithImpl;
@useResult
$Res call({
 String source, String issue,@JsonKey(name: 'suggested_migration') String suggestedMigration, String owner
});




}
/// @nodoc
class _$AnalyticsPerformanceNoteCopyWithImpl<$Res>
    implements $AnalyticsPerformanceNoteCopyWith<$Res> {
  _$AnalyticsPerformanceNoteCopyWithImpl(this._self, this._then);

  final AnalyticsPerformanceNote _self;
  final $Res Function(AnalyticsPerformanceNote) _then;

/// Create a copy of AnalyticsPerformanceNote
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? source = null,Object? issue = null,Object? suggestedMigration = null,Object? owner = null,}) {
  return _then(_self.copyWith(
source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,issue: null == issue ? _self.issue : issue // ignore: cast_nullable_to_non_nullable
as String,suggestedMigration: null == suggestedMigration ? _self.suggestedMigration : suggestedMigration // ignore: cast_nullable_to_non_nullable
as String,owner: null == owner ? _self.owner : owner // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AnalyticsPerformanceNote].
extension AnalyticsPerformanceNotePatterns on AnalyticsPerformanceNote {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalyticsPerformanceNote value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalyticsPerformanceNote() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalyticsPerformanceNote value)  $default,){
final _that = this;
switch (_that) {
case _AnalyticsPerformanceNote():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalyticsPerformanceNote value)?  $default,){
final _that = this;
switch (_that) {
case _AnalyticsPerformanceNote() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String source,  String issue, @JsonKey(name: 'suggested_migration')  String suggestedMigration,  String owner)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalyticsPerformanceNote() when $default != null:
return $default(_that.source,_that.issue,_that.suggestedMigration,_that.owner);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String source,  String issue, @JsonKey(name: 'suggested_migration')  String suggestedMigration,  String owner)  $default,) {final _that = this;
switch (_that) {
case _AnalyticsPerformanceNote():
return $default(_that.source,_that.issue,_that.suggestedMigration,_that.owner);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String source,  String issue, @JsonKey(name: 'suggested_migration')  String suggestedMigration,  String owner)?  $default,) {final _that = this;
switch (_that) {
case _AnalyticsPerformanceNote() when $default != null:
return $default(_that.source,_that.issue,_that.suggestedMigration,_that.owner);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnalyticsPerformanceNote implements AnalyticsPerformanceNote {
  const _AnalyticsPerformanceNote({this.source = '', this.issue = '', @JsonKey(name: 'suggested_migration') this.suggestedMigration = '', this.owner = ''});
  factory _AnalyticsPerformanceNote.fromJson(Map<String, dynamic> json) => _$AnalyticsPerformanceNoteFromJson(json);

@override@JsonKey() final  String source;
@override@JsonKey() final  String issue;
@override@JsonKey(name: 'suggested_migration') final  String suggestedMigration;
@override@JsonKey() final  String owner;

/// Create a copy of AnalyticsPerformanceNote
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalyticsPerformanceNoteCopyWith<_AnalyticsPerformanceNote> get copyWith => __$AnalyticsPerformanceNoteCopyWithImpl<_AnalyticsPerformanceNote>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnalyticsPerformanceNoteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalyticsPerformanceNote&&(identical(other.source, source) || other.source == source)&&(identical(other.issue, issue) || other.issue == issue)&&(identical(other.suggestedMigration, suggestedMigration) || other.suggestedMigration == suggestedMigration)&&(identical(other.owner, owner) || other.owner == owner));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,source,issue,suggestedMigration,owner);

@override
String toString() {
  return 'AnalyticsPerformanceNote(source: $source, issue: $issue, suggestedMigration: $suggestedMigration, owner: $owner)';
}


}

/// @nodoc
abstract mixin class _$AnalyticsPerformanceNoteCopyWith<$Res> implements $AnalyticsPerformanceNoteCopyWith<$Res> {
  factory _$AnalyticsPerformanceNoteCopyWith(_AnalyticsPerformanceNote value, $Res Function(_AnalyticsPerformanceNote) _then) = __$AnalyticsPerformanceNoteCopyWithImpl;
@override @useResult
$Res call({
 String source, String issue,@JsonKey(name: 'suggested_migration') String suggestedMigration, String owner
});




}
/// @nodoc
class __$AnalyticsPerformanceNoteCopyWithImpl<$Res>
    implements _$AnalyticsPerformanceNoteCopyWith<$Res> {
  __$AnalyticsPerformanceNoteCopyWithImpl(this._self, this._then);

  final _AnalyticsPerformanceNote _self;
  final $Res Function(_AnalyticsPerformanceNote) _then;

/// Create a copy of AnalyticsPerformanceNote
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? source = null,Object? issue = null,Object? suggestedMigration = null,Object? owner = null,}) {
  return _then(_AnalyticsPerformanceNote(
source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,issue: null == issue ? _self.issue : issue // ignore: cast_nullable_to_non_nullable
as String,suggestedMigration: null == suggestedMigration ? _self.suggestedMigration : suggestedMigration // ignore: cast_nullable_to_non_nullable
as String,owner: null == owner ? _self.owner : owner // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$AnalyticsBreakdown {

 String get title; AnalyticsWindow get window; String get basis; String get note;@JsonKey(name: 'rows', fromJson: _mapList) List<Map<String, dynamic>> get rows;
/// Create a copy of AnalyticsBreakdown
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalyticsBreakdownCopyWith<AnalyticsBreakdown> get copyWith => _$AnalyticsBreakdownCopyWithImpl<AnalyticsBreakdown>(this as AnalyticsBreakdown, _$identity);

  /// Serializes this AnalyticsBreakdown to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalyticsBreakdown&&(identical(other.title, title) || other.title == title)&&(identical(other.window, window) || other.window == window)&&(identical(other.basis, basis) || other.basis == basis)&&(identical(other.note, note) || other.note == note)&&const DeepCollectionEquality().equals(other.rows, rows));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,window,basis,note,const DeepCollectionEquality().hash(rows));

@override
String toString() {
  return 'AnalyticsBreakdown(title: $title, window: $window, basis: $basis, note: $note, rows: $rows)';
}


}

/// @nodoc
abstract mixin class $AnalyticsBreakdownCopyWith<$Res>  {
  factory $AnalyticsBreakdownCopyWith(AnalyticsBreakdown value, $Res Function(AnalyticsBreakdown) _then) = _$AnalyticsBreakdownCopyWithImpl;
@useResult
$Res call({
 String title, AnalyticsWindow window, String basis, String note,@JsonKey(name: 'rows', fromJson: _mapList) List<Map<String, dynamic>> rows
});


$AnalyticsWindowCopyWith<$Res> get window;

}
/// @nodoc
class _$AnalyticsBreakdownCopyWithImpl<$Res>
    implements $AnalyticsBreakdownCopyWith<$Res> {
  _$AnalyticsBreakdownCopyWithImpl(this._self, this._then);

  final AnalyticsBreakdown _self;
  final $Res Function(AnalyticsBreakdown) _then;

/// Create a copy of AnalyticsBreakdown
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? window = null,Object? basis = null,Object? note = null,Object? rows = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,window: null == window ? _self.window : window // ignore: cast_nullable_to_non_nullable
as AnalyticsWindow,basis: null == basis ? _self.basis : basis // ignore: cast_nullable_to_non_nullable
as String,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,rows: null == rows ? _self.rows : rows // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,
  ));
}
/// Create a copy of AnalyticsBreakdown
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsWindowCopyWith<$Res> get window {
  
  return $AnalyticsWindowCopyWith<$Res>(_self.window, (value) {
    return _then(_self.copyWith(window: value));
  });
}
}


/// Adds pattern-matching-related methods to [AnalyticsBreakdown].
extension AnalyticsBreakdownPatterns on AnalyticsBreakdown {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalyticsBreakdown value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalyticsBreakdown() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalyticsBreakdown value)  $default,){
final _that = this;
switch (_that) {
case _AnalyticsBreakdown():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalyticsBreakdown value)?  $default,){
final _that = this;
switch (_that) {
case _AnalyticsBreakdown() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  AnalyticsWindow window,  String basis,  String note, @JsonKey(name: 'rows', fromJson: _mapList)  List<Map<String, dynamic>> rows)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalyticsBreakdown() when $default != null:
return $default(_that.title,_that.window,_that.basis,_that.note,_that.rows);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  AnalyticsWindow window,  String basis,  String note, @JsonKey(name: 'rows', fromJson: _mapList)  List<Map<String, dynamic>> rows)  $default,) {final _that = this;
switch (_that) {
case _AnalyticsBreakdown():
return $default(_that.title,_that.window,_that.basis,_that.note,_that.rows);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  AnalyticsWindow window,  String basis,  String note, @JsonKey(name: 'rows', fromJson: _mapList)  List<Map<String, dynamic>> rows)?  $default,) {final _that = this;
switch (_that) {
case _AnalyticsBreakdown() when $default != null:
return $default(_that.title,_that.window,_that.basis,_that.note,_that.rows);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnalyticsBreakdown implements AnalyticsBreakdown {
  const _AnalyticsBreakdown({this.title = '', this.window = const AnalyticsWindow(), this.basis = '', this.note = '', @JsonKey(name: 'rows', fromJson: _mapList) final  List<Map<String, dynamic>> rows = const <Map<String, dynamic>>[]}): _rows = rows;
  factory _AnalyticsBreakdown.fromJson(Map<String, dynamic> json) => _$AnalyticsBreakdownFromJson(json);

@override@JsonKey() final  String title;
@override@JsonKey() final  AnalyticsWindow window;
@override@JsonKey() final  String basis;
@override@JsonKey() final  String note;
 final  List<Map<String, dynamic>> _rows;
@override@JsonKey(name: 'rows', fromJson: _mapList) List<Map<String, dynamic>> get rows {
  if (_rows is EqualUnmodifiableListView) return _rows;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rows);
}


/// Create a copy of AnalyticsBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalyticsBreakdownCopyWith<_AnalyticsBreakdown> get copyWith => __$AnalyticsBreakdownCopyWithImpl<_AnalyticsBreakdown>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnalyticsBreakdownToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalyticsBreakdown&&(identical(other.title, title) || other.title == title)&&(identical(other.window, window) || other.window == window)&&(identical(other.basis, basis) || other.basis == basis)&&(identical(other.note, note) || other.note == note)&&const DeepCollectionEquality().equals(other._rows, _rows));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,window,basis,note,const DeepCollectionEquality().hash(_rows));

@override
String toString() {
  return 'AnalyticsBreakdown(title: $title, window: $window, basis: $basis, note: $note, rows: $rows)';
}


}

/// @nodoc
abstract mixin class _$AnalyticsBreakdownCopyWith<$Res> implements $AnalyticsBreakdownCopyWith<$Res> {
  factory _$AnalyticsBreakdownCopyWith(_AnalyticsBreakdown value, $Res Function(_AnalyticsBreakdown) _then) = __$AnalyticsBreakdownCopyWithImpl;
@override @useResult
$Res call({
 String title, AnalyticsWindow window, String basis, String note,@JsonKey(name: 'rows', fromJson: _mapList) List<Map<String, dynamic>> rows
});


@override $AnalyticsWindowCopyWith<$Res> get window;

}
/// @nodoc
class __$AnalyticsBreakdownCopyWithImpl<$Res>
    implements _$AnalyticsBreakdownCopyWith<$Res> {
  __$AnalyticsBreakdownCopyWithImpl(this._self, this._then);

  final _AnalyticsBreakdown _self;
  final $Res Function(_AnalyticsBreakdown) _then;

/// Create a copy of AnalyticsBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? window = null,Object? basis = null,Object? note = null,Object? rows = null,}) {
  return _then(_AnalyticsBreakdown(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,window: null == window ? _self.window : window // ignore: cast_nullable_to_non_nullable
as AnalyticsWindow,basis: null == basis ? _self.basis : basis // ignore: cast_nullable_to_non_nullable
as String,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,rows: null == rows ? _self._rows : rows // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,
  ));
}

/// Create a copy of AnalyticsBreakdown
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsWindowCopyWith<$Res> get window {
  
  return $AnalyticsWindowCopyWith<$Res>(_self.window, (value) {
    return _then(_self.copyWith(window: value));
  });
}
}


/// @nodoc
mixin _$AnalyticsOverview {

 AnalyticsWindow get window;@JsonKey(name: 'generated_at') String get generatedAt;@JsonKey(name: 'kpis', fromJson: _mapList) List<Map<String, dynamic>> get kpis;@JsonKey(name: 'breakdowns', fromJson: _mapList) List<Map<String, dynamic>> get breakdowns; List<String> get groups;@JsonKey(name: 'performance_notes', fromJson: _mapList) List<Map<String, dynamic>> get performanceNotes; AnalyticsTable get table;
/// Create a copy of AnalyticsOverview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalyticsOverviewCopyWith<AnalyticsOverview> get copyWith => _$AnalyticsOverviewCopyWithImpl<AnalyticsOverview>(this as AnalyticsOverview, _$identity);

  /// Serializes this AnalyticsOverview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalyticsOverview&&(identical(other.window, window) || other.window == window)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&const DeepCollectionEquality().equals(other.kpis, kpis)&&const DeepCollectionEquality().equals(other.breakdowns, breakdowns)&&const DeepCollectionEquality().equals(other.groups, groups)&&const DeepCollectionEquality().equals(other.performanceNotes, performanceNotes)&&(identical(other.table, table) || other.table == table));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,window,generatedAt,const DeepCollectionEquality().hash(kpis),const DeepCollectionEquality().hash(breakdowns),const DeepCollectionEquality().hash(groups),const DeepCollectionEquality().hash(performanceNotes),table);

@override
String toString() {
  return 'AnalyticsOverview(window: $window, generatedAt: $generatedAt, kpis: $kpis, breakdowns: $breakdowns, groups: $groups, performanceNotes: $performanceNotes, table: $table)';
}


}

/// @nodoc
abstract mixin class $AnalyticsOverviewCopyWith<$Res>  {
  factory $AnalyticsOverviewCopyWith(AnalyticsOverview value, $Res Function(AnalyticsOverview) _then) = _$AnalyticsOverviewCopyWithImpl;
@useResult
$Res call({
 AnalyticsWindow window,@JsonKey(name: 'generated_at') String generatedAt,@JsonKey(name: 'kpis', fromJson: _mapList) List<Map<String, dynamic>> kpis,@JsonKey(name: 'breakdowns', fromJson: _mapList) List<Map<String, dynamic>> breakdowns, List<String> groups,@JsonKey(name: 'performance_notes', fromJson: _mapList) List<Map<String, dynamic>> performanceNotes, AnalyticsTable table
});


$AnalyticsWindowCopyWith<$Res> get window;$AnalyticsTableCopyWith<$Res> get table;

}
/// @nodoc
class _$AnalyticsOverviewCopyWithImpl<$Res>
    implements $AnalyticsOverviewCopyWith<$Res> {
  _$AnalyticsOverviewCopyWithImpl(this._self, this._then);

  final AnalyticsOverview _self;
  final $Res Function(AnalyticsOverview) _then;

/// Create a copy of AnalyticsOverview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? window = null,Object? generatedAt = null,Object? kpis = null,Object? breakdowns = null,Object? groups = null,Object? performanceNotes = null,Object? table = null,}) {
  return _then(_self.copyWith(
window: null == window ? _self.window : window // ignore: cast_nullable_to_non_nullable
as AnalyticsWindow,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as String,kpis: null == kpis ? _self.kpis : kpis // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,breakdowns: null == breakdowns ? _self.breakdowns : breakdowns // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as List<String>,performanceNotes: null == performanceNotes ? _self.performanceNotes : performanceNotes // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,table: null == table ? _self.table : table // ignore: cast_nullable_to_non_nullable
as AnalyticsTable,
  ));
}
/// Create a copy of AnalyticsOverview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsWindowCopyWith<$Res> get window {
  
  return $AnalyticsWindowCopyWith<$Res>(_self.window, (value) {
    return _then(_self.copyWith(window: value));
  });
}/// Create a copy of AnalyticsOverview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsTableCopyWith<$Res> get table {
  
  return $AnalyticsTableCopyWith<$Res>(_self.table, (value) {
    return _then(_self.copyWith(table: value));
  });
}
}


/// Adds pattern-matching-related methods to [AnalyticsOverview].
extension AnalyticsOverviewPatterns on AnalyticsOverview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalyticsOverview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalyticsOverview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalyticsOverview value)  $default,){
final _that = this;
switch (_that) {
case _AnalyticsOverview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalyticsOverview value)?  $default,){
final _that = this;
switch (_that) {
case _AnalyticsOverview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AnalyticsWindow window, @JsonKey(name: 'generated_at')  String generatedAt, @JsonKey(name: 'kpis', fromJson: _mapList)  List<Map<String, dynamic>> kpis, @JsonKey(name: 'breakdowns', fromJson: _mapList)  List<Map<String, dynamic>> breakdowns,  List<String> groups, @JsonKey(name: 'performance_notes', fromJson: _mapList)  List<Map<String, dynamic>> performanceNotes,  AnalyticsTable table)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalyticsOverview() when $default != null:
return $default(_that.window,_that.generatedAt,_that.kpis,_that.breakdowns,_that.groups,_that.performanceNotes,_that.table);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AnalyticsWindow window, @JsonKey(name: 'generated_at')  String generatedAt, @JsonKey(name: 'kpis', fromJson: _mapList)  List<Map<String, dynamic>> kpis, @JsonKey(name: 'breakdowns', fromJson: _mapList)  List<Map<String, dynamic>> breakdowns,  List<String> groups, @JsonKey(name: 'performance_notes', fromJson: _mapList)  List<Map<String, dynamic>> performanceNotes,  AnalyticsTable table)  $default,) {final _that = this;
switch (_that) {
case _AnalyticsOverview():
return $default(_that.window,_that.generatedAt,_that.kpis,_that.breakdowns,_that.groups,_that.performanceNotes,_that.table);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AnalyticsWindow window, @JsonKey(name: 'generated_at')  String generatedAt, @JsonKey(name: 'kpis', fromJson: _mapList)  List<Map<String, dynamic>> kpis, @JsonKey(name: 'breakdowns', fromJson: _mapList)  List<Map<String, dynamic>> breakdowns,  List<String> groups, @JsonKey(name: 'performance_notes', fromJson: _mapList)  List<Map<String, dynamic>> performanceNotes,  AnalyticsTable table)?  $default,) {final _that = this;
switch (_that) {
case _AnalyticsOverview() when $default != null:
return $default(_that.window,_that.generatedAt,_that.kpis,_that.breakdowns,_that.groups,_that.performanceNotes,_that.table);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnalyticsOverview implements AnalyticsOverview {
  const _AnalyticsOverview({this.window = const AnalyticsWindow(), @JsonKey(name: 'generated_at') this.generatedAt = '', @JsonKey(name: 'kpis', fromJson: _mapList) final  List<Map<String, dynamic>> kpis = const <Map<String, dynamic>>[], @JsonKey(name: 'breakdowns', fromJson: _mapList) final  List<Map<String, dynamic>> breakdowns = const <Map<String, dynamic>>[], final  List<String> groups = const <String>[], @JsonKey(name: 'performance_notes', fromJson: _mapList) final  List<Map<String, dynamic>> performanceNotes = const <Map<String, dynamic>>[], this.table = const AnalyticsTable()}): _kpis = kpis,_breakdowns = breakdowns,_groups = groups,_performanceNotes = performanceNotes;
  factory _AnalyticsOverview.fromJson(Map<String, dynamic> json) => _$AnalyticsOverviewFromJson(json);

@override@JsonKey() final  AnalyticsWindow window;
@override@JsonKey(name: 'generated_at') final  String generatedAt;
 final  List<Map<String, dynamic>> _kpis;
@override@JsonKey(name: 'kpis', fromJson: _mapList) List<Map<String, dynamic>> get kpis {
  if (_kpis is EqualUnmodifiableListView) return _kpis;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_kpis);
}

 final  List<Map<String, dynamic>> _breakdowns;
@override@JsonKey(name: 'breakdowns', fromJson: _mapList) List<Map<String, dynamic>> get breakdowns {
  if (_breakdowns is EqualUnmodifiableListView) return _breakdowns;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_breakdowns);
}

 final  List<String> _groups;
@override@JsonKey() List<String> get groups {
  if (_groups is EqualUnmodifiableListView) return _groups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groups);
}

 final  List<Map<String, dynamic>> _performanceNotes;
@override@JsonKey(name: 'performance_notes', fromJson: _mapList) List<Map<String, dynamic>> get performanceNotes {
  if (_performanceNotes is EqualUnmodifiableListView) return _performanceNotes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_performanceNotes);
}

@override@JsonKey() final  AnalyticsTable table;

/// Create a copy of AnalyticsOverview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalyticsOverviewCopyWith<_AnalyticsOverview> get copyWith => __$AnalyticsOverviewCopyWithImpl<_AnalyticsOverview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnalyticsOverviewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalyticsOverview&&(identical(other.window, window) || other.window == window)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&const DeepCollectionEquality().equals(other._kpis, _kpis)&&const DeepCollectionEquality().equals(other._breakdowns, _breakdowns)&&const DeepCollectionEquality().equals(other._groups, _groups)&&const DeepCollectionEquality().equals(other._performanceNotes, _performanceNotes)&&(identical(other.table, table) || other.table == table));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,window,generatedAt,const DeepCollectionEquality().hash(_kpis),const DeepCollectionEquality().hash(_breakdowns),const DeepCollectionEquality().hash(_groups),const DeepCollectionEquality().hash(_performanceNotes),table);

@override
String toString() {
  return 'AnalyticsOverview(window: $window, generatedAt: $generatedAt, kpis: $kpis, breakdowns: $breakdowns, groups: $groups, performanceNotes: $performanceNotes, table: $table)';
}


}

/// @nodoc
abstract mixin class _$AnalyticsOverviewCopyWith<$Res> implements $AnalyticsOverviewCopyWith<$Res> {
  factory _$AnalyticsOverviewCopyWith(_AnalyticsOverview value, $Res Function(_AnalyticsOverview) _then) = __$AnalyticsOverviewCopyWithImpl;
@override @useResult
$Res call({
 AnalyticsWindow window,@JsonKey(name: 'generated_at') String generatedAt,@JsonKey(name: 'kpis', fromJson: _mapList) List<Map<String, dynamic>> kpis,@JsonKey(name: 'breakdowns', fromJson: _mapList) List<Map<String, dynamic>> breakdowns, List<String> groups,@JsonKey(name: 'performance_notes', fromJson: _mapList) List<Map<String, dynamic>> performanceNotes, AnalyticsTable table
});


@override $AnalyticsWindowCopyWith<$Res> get window;@override $AnalyticsTableCopyWith<$Res> get table;

}
/// @nodoc
class __$AnalyticsOverviewCopyWithImpl<$Res>
    implements _$AnalyticsOverviewCopyWith<$Res> {
  __$AnalyticsOverviewCopyWithImpl(this._self, this._then);

  final _AnalyticsOverview _self;
  final $Res Function(_AnalyticsOverview) _then;

/// Create a copy of AnalyticsOverview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? window = null,Object? generatedAt = null,Object? kpis = null,Object? breakdowns = null,Object? groups = null,Object? performanceNotes = null,Object? table = null,}) {
  return _then(_AnalyticsOverview(
window: null == window ? _self.window : window // ignore: cast_nullable_to_non_nullable
as AnalyticsWindow,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as String,kpis: null == kpis ? _self._kpis : kpis // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,breakdowns: null == breakdowns ? _self._breakdowns : breakdowns // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,groups: null == groups ? _self._groups : groups // ignore: cast_nullable_to_non_nullable
as List<String>,performanceNotes: null == performanceNotes ? _self._performanceNotes : performanceNotes // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,table: null == table ? _self.table : table // ignore: cast_nullable_to_non_nullable
as AnalyticsTable,
  ));
}

/// Create a copy of AnalyticsOverview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsWindowCopyWith<$Res> get window {
  
  return $AnalyticsWindowCopyWith<$Res>(_self.window, (value) {
    return _then(_self.copyWith(window: value));
  });
}/// Create a copy of AnalyticsOverview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsTableCopyWith<$Res> get table {
  
  return $AnalyticsTableCopyWith<$Res>(_self.table, (value) {
    return _then(_self.copyWith(table: value));
  });
}
}


/// @nodoc
mixin _$AnalyticsMetric {

 String get key; String get label; String get unit; String get group; String get source; String get description;
/// Create a copy of AnalyticsMetric
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalyticsMetricCopyWith<AnalyticsMetric> get copyWith => _$AnalyticsMetricCopyWithImpl<AnalyticsMetric>(this as AnalyticsMetric, _$identity);

  /// Serializes this AnalyticsMetric to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalyticsMetric&&(identical(other.key, key) || other.key == key)&&(identical(other.label, label) || other.label == label)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.group, group) || other.group == group)&&(identical(other.source, source) || other.source == source)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,label,unit,group,source,description);

@override
String toString() {
  return 'AnalyticsMetric(key: $key, label: $label, unit: $unit, group: $group, source: $source, description: $description)';
}


}

/// @nodoc
abstract mixin class $AnalyticsMetricCopyWith<$Res>  {
  factory $AnalyticsMetricCopyWith(AnalyticsMetric value, $Res Function(AnalyticsMetric) _then) = _$AnalyticsMetricCopyWithImpl;
@useResult
$Res call({
 String key, String label, String unit, String group, String source, String description
});




}
/// @nodoc
class _$AnalyticsMetricCopyWithImpl<$Res>
    implements $AnalyticsMetricCopyWith<$Res> {
  _$AnalyticsMetricCopyWithImpl(this._self, this._then);

  final AnalyticsMetric _self;
  final $Res Function(AnalyticsMetric) _then;

/// Create a copy of AnalyticsMetric
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? label = null,Object? unit = null,Object? group = null,Object? source = null,Object? description = null,}) {
  return _then(_self.copyWith(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AnalyticsMetric].
extension AnalyticsMetricPatterns on AnalyticsMetric {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalyticsMetric value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalyticsMetric() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalyticsMetric value)  $default,){
final _that = this;
switch (_that) {
case _AnalyticsMetric():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalyticsMetric value)?  $default,){
final _that = this;
switch (_that) {
case _AnalyticsMetric() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String label,  String unit,  String group,  String source,  String description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalyticsMetric() when $default != null:
return $default(_that.key,_that.label,_that.unit,_that.group,_that.source,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String label,  String unit,  String group,  String source,  String description)  $default,) {final _that = this;
switch (_that) {
case _AnalyticsMetric():
return $default(_that.key,_that.label,_that.unit,_that.group,_that.source,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String label,  String unit,  String group,  String source,  String description)?  $default,) {final _that = this;
switch (_that) {
case _AnalyticsMetric() when $default != null:
return $default(_that.key,_that.label,_that.unit,_that.group,_that.source,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnalyticsMetric implements AnalyticsMetric {
  const _AnalyticsMetric({this.key = '', this.label = '', this.unit = '', this.group = '', this.source = '', this.description = ''});
  factory _AnalyticsMetric.fromJson(Map<String, dynamic> json) => _$AnalyticsMetricFromJson(json);

@override@JsonKey() final  String key;
@override@JsonKey() final  String label;
@override@JsonKey() final  String unit;
@override@JsonKey() final  String group;
@override@JsonKey() final  String source;
@override@JsonKey() final  String description;

/// Create a copy of AnalyticsMetric
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalyticsMetricCopyWith<_AnalyticsMetric> get copyWith => __$AnalyticsMetricCopyWithImpl<_AnalyticsMetric>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnalyticsMetricToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalyticsMetric&&(identical(other.key, key) || other.key == key)&&(identical(other.label, label) || other.label == label)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.group, group) || other.group == group)&&(identical(other.source, source) || other.source == source)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,label,unit,group,source,description);

@override
String toString() {
  return 'AnalyticsMetric(key: $key, label: $label, unit: $unit, group: $group, source: $source, description: $description)';
}


}

/// @nodoc
abstract mixin class _$AnalyticsMetricCopyWith<$Res> implements $AnalyticsMetricCopyWith<$Res> {
  factory _$AnalyticsMetricCopyWith(_AnalyticsMetric value, $Res Function(_AnalyticsMetric) _then) = __$AnalyticsMetricCopyWithImpl;
@override @useResult
$Res call({
 String key, String label, String unit, String group, String source, String description
});




}
/// @nodoc
class __$AnalyticsMetricCopyWithImpl<$Res>
    implements _$AnalyticsMetricCopyWith<$Res> {
  __$AnalyticsMetricCopyWithImpl(this._self, this._then);

  final _AnalyticsMetric _self;
  final $Res Function(_AnalyticsMetric) _then;

/// Create a copy of AnalyticsMetric
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? label = null,Object? unit = null,Object? group = null,Object? source = null,Object? description = null,}) {
  return _then(_AnalyticsMetric(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$AnalyticsBucket {

 String get bucket;@JsonKey(name: 'value', fromJson: _optNumOrZero) num get value;
/// Create a copy of AnalyticsBucket
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalyticsBucketCopyWith<AnalyticsBucket> get copyWith => _$AnalyticsBucketCopyWithImpl<AnalyticsBucket>(this as AnalyticsBucket, _$identity);

  /// Serializes this AnalyticsBucket to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalyticsBucket&&(identical(other.bucket, bucket) || other.bucket == bucket)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bucket,value);

@override
String toString() {
  return 'AnalyticsBucket(bucket: $bucket, value: $value)';
}


}

/// @nodoc
abstract mixin class $AnalyticsBucketCopyWith<$Res>  {
  factory $AnalyticsBucketCopyWith(AnalyticsBucket value, $Res Function(AnalyticsBucket) _then) = _$AnalyticsBucketCopyWithImpl;
@useResult
$Res call({
 String bucket,@JsonKey(name: 'value', fromJson: _optNumOrZero) num value
});




}
/// @nodoc
class _$AnalyticsBucketCopyWithImpl<$Res>
    implements $AnalyticsBucketCopyWith<$Res> {
  _$AnalyticsBucketCopyWithImpl(this._self, this._then);

  final AnalyticsBucket _self;
  final $Res Function(AnalyticsBucket) _then;

/// Create a copy of AnalyticsBucket
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bucket = null,Object? value = null,}) {
  return _then(_self.copyWith(
bucket: null == bucket ? _self.bucket : bucket // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as num,
  ));
}

}


/// Adds pattern-matching-related methods to [AnalyticsBucket].
extension AnalyticsBucketPatterns on AnalyticsBucket {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalyticsBucket value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalyticsBucket() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalyticsBucket value)  $default,){
final _that = this;
switch (_that) {
case _AnalyticsBucket():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalyticsBucket value)?  $default,){
final _that = this;
switch (_that) {
case _AnalyticsBucket() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String bucket, @JsonKey(name: 'value', fromJson: _optNumOrZero)  num value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalyticsBucket() when $default != null:
return $default(_that.bucket,_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String bucket, @JsonKey(name: 'value', fromJson: _optNumOrZero)  num value)  $default,) {final _that = this;
switch (_that) {
case _AnalyticsBucket():
return $default(_that.bucket,_that.value);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String bucket, @JsonKey(name: 'value', fromJson: _optNumOrZero)  num value)?  $default,) {final _that = this;
switch (_that) {
case _AnalyticsBucket() when $default != null:
return $default(_that.bucket,_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnalyticsBucket implements AnalyticsBucket {
  const _AnalyticsBucket({this.bucket = '', @JsonKey(name: 'value', fromJson: _optNumOrZero) this.value = 0});
  factory _AnalyticsBucket.fromJson(Map<String, dynamic> json) => _$AnalyticsBucketFromJson(json);

@override@JsonKey() final  String bucket;
@override@JsonKey(name: 'value', fromJson: _optNumOrZero) final  num value;

/// Create a copy of AnalyticsBucket
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalyticsBucketCopyWith<_AnalyticsBucket> get copyWith => __$AnalyticsBucketCopyWithImpl<_AnalyticsBucket>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnalyticsBucketToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalyticsBucket&&(identical(other.bucket, bucket) || other.bucket == bucket)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bucket,value);

@override
String toString() {
  return 'AnalyticsBucket(bucket: $bucket, value: $value)';
}


}

/// @nodoc
abstract mixin class _$AnalyticsBucketCopyWith<$Res> implements $AnalyticsBucketCopyWith<$Res> {
  factory _$AnalyticsBucketCopyWith(_AnalyticsBucket value, $Res Function(_AnalyticsBucket) _then) = __$AnalyticsBucketCopyWithImpl;
@override @useResult
$Res call({
 String bucket,@JsonKey(name: 'value', fromJson: _optNumOrZero) num value
});




}
/// @nodoc
class __$AnalyticsBucketCopyWithImpl<$Res>
    implements _$AnalyticsBucketCopyWith<$Res> {
  __$AnalyticsBucketCopyWithImpl(this._self, this._then);

  final _AnalyticsBucket _self;
  final $Res Function(_AnalyticsBucket) _then;

/// Create a copy of AnalyticsBucket
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bucket = null,Object? value = null,}) {
  return _then(_AnalyticsBucket(
bucket: null == bucket ? _self.bucket : bucket // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as num,
  ));
}


}


/// @nodoc
mixin _$AnalyticsTotals {

@JsonKey(name: 'sum', fromJson: _optNumOrZero) num get sum;@JsonKey(name: 'non_zero_buckets', fromJson: _optNumOrZero) num get nonZeroBuckets;
/// Create a copy of AnalyticsTotals
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalyticsTotalsCopyWith<AnalyticsTotals> get copyWith => _$AnalyticsTotalsCopyWithImpl<AnalyticsTotals>(this as AnalyticsTotals, _$identity);

  /// Serializes this AnalyticsTotals to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalyticsTotals&&(identical(other.sum, sum) || other.sum == sum)&&(identical(other.nonZeroBuckets, nonZeroBuckets) || other.nonZeroBuckets == nonZeroBuckets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sum,nonZeroBuckets);

@override
String toString() {
  return 'AnalyticsTotals(sum: $sum, nonZeroBuckets: $nonZeroBuckets)';
}


}

/// @nodoc
abstract mixin class $AnalyticsTotalsCopyWith<$Res>  {
  factory $AnalyticsTotalsCopyWith(AnalyticsTotals value, $Res Function(AnalyticsTotals) _then) = _$AnalyticsTotalsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'sum', fromJson: _optNumOrZero) num sum,@JsonKey(name: 'non_zero_buckets', fromJson: _optNumOrZero) num nonZeroBuckets
});




}
/// @nodoc
class _$AnalyticsTotalsCopyWithImpl<$Res>
    implements $AnalyticsTotalsCopyWith<$Res> {
  _$AnalyticsTotalsCopyWithImpl(this._self, this._then);

  final AnalyticsTotals _self;
  final $Res Function(AnalyticsTotals) _then;

/// Create a copy of AnalyticsTotals
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sum = null,Object? nonZeroBuckets = null,}) {
  return _then(_self.copyWith(
sum: null == sum ? _self.sum : sum // ignore: cast_nullable_to_non_nullable
as num,nonZeroBuckets: null == nonZeroBuckets ? _self.nonZeroBuckets : nonZeroBuckets // ignore: cast_nullable_to_non_nullable
as num,
  ));
}

}


/// Adds pattern-matching-related methods to [AnalyticsTotals].
extension AnalyticsTotalsPatterns on AnalyticsTotals {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalyticsTotals value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalyticsTotals() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalyticsTotals value)  $default,){
final _that = this;
switch (_that) {
case _AnalyticsTotals():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalyticsTotals value)?  $default,){
final _that = this;
switch (_that) {
case _AnalyticsTotals() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'sum', fromJson: _optNumOrZero)  num sum, @JsonKey(name: 'non_zero_buckets', fromJson: _optNumOrZero)  num nonZeroBuckets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalyticsTotals() when $default != null:
return $default(_that.sum,_that.nonZeroBuckets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'sum', fromJson: _optNumOrZero)  num sum, @JsonKey(name: 'non_zero_buckets', fromJson: _optNumOrZero)  num nonZeroBuckets)  $default,) {final _that = this;
switch (_that) {
case _AnalyticsTotals():
return $default(_that.sum,_that.nonZeroBuckets);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'sum', fromJson: _optNumOrZero)  num sum, @JsonKey(name: 'non_zero_buckets', fromJson: _optNumOrZero)  num nonZeroBuckets)?  $default,) {final _that = this;
switch (_that) {
case _AnalyticsTotals() when $default != null:
return $default(_that.sum,_that.nonZeroBuckets);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnalyticsTotals implements AnalyticsTotals {
  const _AnalyticsTotals({@JsonKey(name: 'sum', fromJson: _optNumOrZero) this.sum = 0, @JsonKey(name: 'non_zero_buckets', fromJson: _optNumOrZero) this.nonZeroBuckets = 0});
  factory _AnalyticsTotals.fromJson(Map<String, dynamic> json) => _$AnalyticsTotalsFromJson(json);

@override@JsonKey(name: 'sum', fromJson: _optNumOrZero) final  num sum;
@override@JsonKey(name: 'non_zero_buckets', fromJson: _optNumOrZero) final  num nonZeroBuckets;

/// Create a copy of AnalyticsTotals
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalyticsTotalsCopyWith<_AnalyticsTotals> get copyWith => __$AnalyticsTotalsCopyWithImpl<_AnalyticsTotals>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnalyticsTotalsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalyticsTotals&&(identical(other.sum, sum) || other.sum == sum)&&(identical(other.nonZeroBuckets, nonZeroBuckets) || other.nonZeroBuckets == nonZeroBuckets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sum,nonZeroBuckets);

@override
String toString() {
  return 'AnalyticsTotals(sum: $sum, nonZeroBuckets: $nonZeroBuckets)';
}


}

/// @nodoc
abstract mixin class _$AnalyticsTotalsCopyWith<$Res> implements $AnalyticsTotalsCopyWith<$Res> {
  factory _$AnalyticsTotalsCopyWith(_AnalyticsTotals value, $Res Function(_AnalyticsTotals) _then) = __$AnalyticsTotalsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'sum', fromJson: _optNumOrZero) num sum,@JsonKey(name: 'non_zero_buckets', fromJson: _optNumOrZero) num nonZeroBuckets
});




}
/// @nodoc
class __$AnalyticsTotalsCopyWithImpl<$Res>
    implements _$AnalyticsTotalsCopyWith<$Res> {
  __$AnalyticsTotalsCopyWithImpl(this._self, this._then);

  final _AnalyticsTotals _self;
  final $Res Function(_AnalyticsTotals) _then;

/// Create a copy of AnalyticsTotals
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sum = null,Object? nonZeroBuckets = null,}) {
  return _then(_AnalyticsTotals(
sum: null == sum ? _self.sum : sum // ignore: cast_nullable_to_non_nullable
as num,nonZeroBuckets: null == nonZeroBuckets ? _self.nonZeroBuckets : nonZeroBuckets // ignore: cast_nullable_to_non_nullable
as num,
  ));
}


}


/// @nodoc
mixin _$AnalyticsDataSource {

 String get path;@JsonKey(name: 'rollup_complete') bool get rollupComplete;@JsonKey(name: 'missing_days', fromJson: _stringList) List<String> get missingDays; String get note;
/// Create a copy of AnalyticsDataSource
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalyticsDataSourceCopyWith<AnalyticsDataSource> get copyWith => _$AnalyticsDataSourceCopyWithImpl<AnalyticsDataSource>(this as AnalyticsDataSource, _$identity);

  /// Serializes this AnalyticsDataSource to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalyticsDataSource&&(identical(other.path, path) || other.path == path)&&(identical(other.rollupComplete, rollupComplete) || other.rollupComplete == rollupComplete)&&const DeepCollectionEquality().equals(other.missingDays, missingDays)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,path,rollupComplete,const DeepCollectionEquality().hash(missingDays),note);

@override
String toString() {
  return 'AnalyticsDataSource(path: $path, rollupComplete: $rollupComplete, missingDays: $missingDays, note: $note)';
}


}

/// @nodoc
abstract mixin class $AnalyticsDataSourceCopyWith<$Res>  {
  factory $AnalyticsDataSourceCopyWith(AnalyticsDataSource value, $Res Function(AnalyticsDataSource) _then) = _$AnalyticsDataSourceCopyWithImpl;
@useResult
$Res call({
 String path,@JsonKey(name: 'rollup_complete') bool rollupComplete,@JsonKey(name: 'missing_days', fromJson: _stringList) List<String> missingDays, String note
});




}
/// @nodoc
class _$AnalyticsDataSourceCopyWithImpl<$Res>
    implements $AnalyticsDataSourceCopyWith<$Res> {
  _$AnalyticsDataSourceCopyWithImpl(this._self, this._then);

  final AnalyticsDataSource _self;
  final $Res Function(AnalyticsDataSource) _then;

/// Create a copy of AnalyticsDataSource
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,Object? rollupComplete = null,Object? missingDays = null,Object? note = null,}) {
  return _then(_self.copyWith(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,rollupComplete: null == rollupComplete ? _self.rollupComplete : rollupComplete // ignore: cast_nullable_to_non_nullable
as bool,missingDays: null == missingDays ? _self.missingDays : missingDays // ignore: cast_nullable_to_non_nullable
as List<String>,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AnalyticsDataSource].
extension AnalyticsDataSourcePatterns on AnalyticsDataSource {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalyticsDataSource value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalyticsDataSource() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalyticsDataSource value)  $default,){
final _that = this;
switch (_that) {
case _AnalyticsDataSource():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalyticsDataSource value)?  $default,){
final _that = this;
switch (_that) {
case _AnalyticsDataSource() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String path, @JsonKey(name: 'rollup_complete')  bool rollupComplete, @JsonKey(name: 'missing_days', fromJson: _stringList)  List<String> missingDays,  String note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalyticsDataSource() when $default != null:
return $default(_that.path,_that.rollupComplete,_that.missingDays,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String path, @JsonKey(name: 'rollup_complete')  bool rollupComplete, @JsonKey(name: 'missing_days', fromJson: _stringList)  List<String> missingDays,  String note)  $default,) {final _that = this;
switch (_that) {
case _AnalyticsDataSource():
return $default(_that.path,_that.rollupComplete,_that.missingDays,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String path, @JsonKey(name: 'rollup_complete')  bool rollupComplete, @JsonKey(name: 'missing_days', fromJson: _stringList)  List<String> missingDays,  String note)?  $default,) {final _that = this;
switch (_that) {
case _AnalyticsDataSource() when $default != null:
return $default(_that.path,_that.rollupComplete,_that.missingDays,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnalyticsDataSource implements AnalyticsDataSource {
  const _AnalyticsDataSource({this.path = '', @JsonKey(name: 'rollup_complete') this.rollupComplete = false, @JsonKey(name: 'missing_days', fromJson: _stringList) final  List<String> missingDays = const <String>[], this.note = ''}): _missingDays = missingDays;
  factory _AnalyticsDataSource.fromJson(Map<String, dynamic> json) => _$AnalyticsDataSourceFromJson(json);

@override@JsonKey() final  String path;
@override@JsonKey(name: 'rollup_complete') final  bool rollupComplete;
 final  List<String> _missingDays;
@override@JsonKey(name: 'missing_days', fromJson: _stringList) List<String> get missingDays {
  if (_missingDays is EqualUnmodifiableListView) return _missingDays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_missingDays);
}

@override@JsonKey() final  String note;

/// Create a copy of AnalyticsDataSource
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalyticsDataSourceCopyWith<_AnalyticsDataSource> get copyWith => __$AnalyticsDataSourceCopyWithImpl<_AnalyticsDataSource>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnalyticsDataSourceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalyticsDataSource&&(identical(other.path, path) || other.path == path)&&(identical(other.rollupComplete, rollupComplete) || other.rollupComplete == rollupComplete)&&const DeepCollectionEquality().equals(other._missingDays, _missingDays)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,path,rollupComplete,const DeepCollectionEquality().hash(_missingDays),note);

@override
String toString() {
  return 'AnalyticsDataSource(path: $path, rollupComplete: $rollupComplete, missingDays: $missingDays, note: $note)';
}


}

/// @nodoc
abstract mixin class _$AnalyticsDataSourceCopyWith<$Res> implements $AnalyticsDataSourceCopyWith<$Res> {
  factory _$AnalyticsDataSourceCopyWith(_AnalyticsDataSource value, $Res Function(_AnalyticsDataSource) _then) = __$AnalyticsDataSourceCopyWithImpl;
@override @useResult
$Res call({
 String path,@JsonKey(name: 'rollup_complete') bool rollupComplete,@JsonKey(name: 'missing_days', fromJson: _stringList) List<String> missingDays, String note
});




}
/// @nodoc
class __$AnalyticsDataSourceCopyWithImpl<$Res>
    implements _$AnalyticsDataSourceCopyWith<$Res> {
  __$AnalyticsDataSourceCopyWithImpl(this._self, this._then);

  final _AnalyticsDataSource _self;
  final $Res Function(_AnalyticsDataSource) _then;

/// Create a copy of AnalyticsDataSource
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? rollupComplete = null,Object? missingDays = null,Object? note = null,}) {
  return _then(_AnalyticsDataSource(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,rollupComplete: null == rollupComplete ? _self.rollupComplete : rollupComplete // ignore: cast_nullable_to_non_nullable
as bool,missingDays: null == missingDays ? _self._missingDays : missingDays // ignore: cast_nullable_to_non_nullable
as List<String>,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$AnalyticsMetricCatalogueEntry {

 String get key; String get label; String get group; String get unit;/// False for distinct-counts and gauges, which the server refuses a series
/// over with a 400 naming the reason.
 bool get additive; bool get windowed; String get source; String get description;
/// Create a copy of AnalyticsMetricCatalogueEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalyticsMetricCatalogueEntryCopyWith<AnalyticsMetricCatalogueEntry> get copyWith => _$AnalyticsMetricCatalogueEntryCopyWithImpl<AnalyticsMetricCatalogueEntry>(this as AnalyticsMetricCatalogueEntry, _$identity);

  /// Serializes this AnalyticsMetricCatalogueEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalyticsMetricCatalogueEntry&&(identical(other.key, key) || other.key == key)&&(identical(other.label, label) || other.label == label)&&(identical(other.group, group) || other.group == group)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.additive, additive) || other.additive == additive)&&(identical(other.windowed, windowed) || other.windowed == windowed)&&(identical(other.source, source) || other.source == source)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,label,group,unit,additive,windowed,source,description);

@override
String toString() {
  return 'AnalyticsMetricCatalogueEntry(key: $key, label: $label, group: $group, unit: $unit, additive: $additive, windowed: $windowed, source: $source, description: $description)';
}


}

/// @nodoc
abstract mixin class $AnalyticsMetricCatalogueEntryCopyWith<$Res>  {
  factory $AnalyticsMetricCatalogueEntryCopyWith(AnalyticsMetricCatalogueEntry value, $Res Function(AnalyticsMetricCatalogueEntry) _then) = _$AnalyticsMetricCatalogueEntryCopyWithImpl;
@useResult
$Res call({
 String key, String label, String group, String unit, bool additive, bool windowed, String source, String description
});




}
/// @nodoc
class _$AnalyticsMetricCatalogueEntryCopyWithImpl<$Res>
    implements $AnalyticsMetricCatalogueEntryCopyWith<$Res> {
  _$AnalyticsMetricCatalogueEntryCopyWithImpl(this._self, this._then);

  final AnalyticsMetricCatalogueEntry _self;
  final $Res Function(AnalyticsMetricCatalogueEntry) _then;

/// Create a copy of AnalyticsMetricCatalogueEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? label = null,Object? group = null,Object? unit = null,Object? additive = null,Object? windowed = null,Object? source = null,Object? description = null,}) {
  return _then(_self.copyWith(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,additive: null == additive ? _self.additive : additive // ignore: cast_nullable_to_non_nullable
as bool,windowed: null == windowed ? _self.windowed : windowed // ignore: cast_nullable_to_non_nullable
as bool,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AnalyticsMetricCatalogueEntry].
extension AnalyticsMetricCatalogueEntryPatterns on AnalyticsMetricCatalogueEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalyticsMetricCatalogueEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalyticsMetricCatalogueEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalyticsMetricCatalogueEntry value)  $default,){
final _that = this;
switch (_that) {
case _AnalyticsMetricCatalogueEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalyticsMetricCatalogueEntry value)?  $default,){
final _that = this;
switch (_that) {
case _AnalyticsMetricCatalogueEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String label,  String group,  String unit,  bool additive,  bool windowed,  String source,  String description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalyticsMetricCatalogueEntry() when $default != null:
return $default(_that.key,_that.label,_that.group,_that.unit,_that.additive,_that.windowed,_that.source,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String label,  String group,  String unit,  bool additive,  bool windowed,  String source,  String description)  $default,) {final _that = this;
switch (_that) {
case _AnalyticsMetricCatalogueEntry():
return $default(_that.key,_that.label,_that.group,_that.unit,_that.additive,_that.windowed,_that.source,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String label,  String group,  String unit,  bool additive,  bool windowed,  String source,  String description)?  $default,) {final _that = this;
switch (_that) {
case _AnalyticsMetricCatalogueEntry() when $default != null:
return $default(_that.key,_that.label,_that.group,_that.unit,_that.additive,_that.windowed,_that.source,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnalyticsMetricCatalogueEntry implements AnalyticsMetricCatalogueEntry {
  const _AnalyticsMetricCatalogueEntry({this.key = '', this.label = '', this.group = '', this.unit = '', this.additive = true, this.windowed = true, this.source = '', this.description = ''});
  factory _AnalyticsMetricCatalogueEntry.fromJson(Map<String, dynamic> json) => _$AnalyticsMetricCatalogueEntryFromJson(json);

@override@JsonKey() final  String key;
@override@JsonKey() final  String label;
@override@JsonKey() final  String group;
@override@JsonKey() final  String unit;
/// False for distinct-counts and gauges, which the server refuses a series
/// over with a 400 naming the reason.
@override@JsonKey() final  bool additive;
@override@JsonKey() final  bool windowed;
@override@JsonKey() final  String source;
@override@JsonKey() final  String description;

/// Create a copy of AnalyticsMetricCatalogueEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalyticsMetricCatalogueEntryCopyWith<_AnalyticsMetricCatalogueEntry> get copyWith => __$AnalyticsMetricCatalogueEntryCopyWithImpl<_AnalyticsMetricCatalogueEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnalyticsMetricCatalogueEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalyticsMetricCatalogueEntry&&(identical(other.key, key) || other.key == key)&&(identical(other.label, label) || other.label == label)&&(identical(other.group, group) || other.group == group)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.additive, additive) || other.additive == additive)&&(identical(other.windowed, windowed) || other.windowed == windowed)&&(identical(other.source, source) || other.source == source)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,label,group,unit,additive,windowed,source,description);

@override
String toString() {
  return 'AnalyticsMetricCatalogueEntry(key: $key, label: $label, group: $group, unit: $unit, additive: $additive, windowed: $windowed, source: $source, description: $description)';
}


}

/// @nodoc
abstract mixin class _$AnalyticsMetricCatalogueEntryCopyWith<$Res> implements $AnalyticsMetricCatalogueEntryCopyWith<$Res> {
  factory _$AnalyticsMetricCatalogueEntryCopyWith(_AnalyticsMetricCatalogueEntry value, $Res Function(_AnalyticsMetricCatalogueEntry) _then) = __$AnalyticsMetricCatalogueEntryCopyWithImpl;
@override @useResult
$Res call({
 String key, String label, String group, String unit, bool additive, bool windowed, String source, String description
});




}
/// @nodoc
class __$AnalyticsMetricCatalogueEntryCopyWithImpl<$Res>
    implements _$AnalyticsMetricCatalogueEntryCopyWith<$Res> {
  __$AnalyticsMetricCatalogueEntryCopyWithImpl(this._self, this._then);

  final _AnalyticsMetricCatalogueEntry _self;
  final $Res Function(_AnalyticsMetricCatalogueEntry) _then;

/// Create a copy of AnalyticsMetricCatalogueEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? label = null,Object? group = null,Object? unit = null,Object? additive = null,Object? windowed = null,Object? source = null,Object? description = null,}) {
  return _then(_AnalyticsMetricCatalogueEntry(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,additive: null == additive ? _self.additive : additive // ignore: cast_nullable_to_non_nullable
as bool,windowed: null == windowed ? _self.windowed : windowed // ignore: cast_nullable_to_non_nullable
as bool,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$AnalyticsTimeseries {

 AnalyticsWindow get window; AnalyticsMetric get metric;/// `day` or `week`.
 String get granularity;@JsonKey(name: 'series', fromJson: _mapList) List<Map<String, dynamic>> get series; AnalyticsTotals get totals;@JsonKey(name: 'data_source') AnalyticsDataSource? get dataSource;@JsonKey(name: 'available_metrics', fromJson: _stringList) List<String> get availableMetrics;@JsonKey(name: 'metric_catalogue', fromJson: _mapList) List<Map<String, dynamic>> get metricCatalogue; AnalyticsTable get table;
/// Create a copy of AnalyticsTimeseries
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalyticsTimeseriesCopyWith<AnalyticsTimeseries> get copyWith => _$AnalyticsTimeseriesCopyWithImpl<AnalyticsTimeseries>(this as AnalyticsTimeseries, _$identity);

  /// Serializes this AnalyticsTimeseries to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalyticsTimeseries&&(identical(other.window, window) || other.window == window)&&(identical(other.metric, metric) || other.metric == metric)&&(identical(other.granularity, granularity) || other.granularity == granularity)&&const DeepCollectionEquality().equals(other.series, series)&&(identical(other.totals, totals) || other.totals == totals)&&(identical(other.dataSource, dataSource) || other.dataSource == dataSource)&&const DeepCollectionEquality().equals(other.availableMetrics, availableMetrics)&&const DeepCollectionEquality().equals(other.metricCatalogue, metricCatalogue)&&(identical(other.table, table) || other.table == table));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,window,metric,granularity,const DeepCollectionEquality().hash(series),totals,dataSource,const DeepCollectionEquality().hash(availableMetrics),const DeepCollectionEquality().hash(metricCatalogue),table);

@override
String toString() {
  return 'AnalyticsTimeseries(window: $window, metric: $metric, granularity: $granularity, series: $series, totals: $totals, dataSource: $dataSource, availableMetrics: $availableMetrics, metricCatalogue: $metricCatalogue, table: $table)';
}


}

/// @nodoc
abstract mixin class $AnalyticsTimeseriesCopyWith<$Res>  {
  factory $AnalyticsTimeseriesCopyWith(AnalyticsTimeseries value, $Res Function(AnalyticsTimeseries) _then) = _$AnalyticsTimeseriesCopyWithImpl;
@useResult
$Res call({
 AnalyticsWindow window, AnalyticsMetric metric, String granularity,@JsonKey(name: 'series', fromJson: _mapList) List<Map<String, dynamic>> series, AnalyticsTotals totals,@JsonKey(name: 'data_source') AnalyticsDataSource? dataSource,@JsonKey(name: 'available_metrics', fromJson: _stringList) List<String> availableMetrics,@JsonKey(name: 'metric_catalogue', fromJson: _mapList) List<Map<String, dynamic>> metricCatalogue, AnalyticsTable table
});


$AnalyticsWindowCopyWith<$Res> get window;$AnalyticsMetricCopyWith<$Res> get metric;$AnalyticsTotalsCopyWith<$Res> get totals;$AnalyticsDataSourceCopyWith<$Res>? get dataSource;$AnalyticsTableCopyWith<$Res> get table;

}
/// @nodoc
class _$AnalyticsTimeseriesCopyWithImpl<$Res>
    implements $AnalyticsTimeseriesCopyWith<$Res> {
  _$AnalyticsTimeseriesCopyWithImpl(this._self, this._then);

  final AnalyticsTimeseries _self;
  final $Res Function(AnalyticsTimeseries) _then;

/// Create a copy of AnalyticsTimeseries
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? window = null,Object? metric = null,Object? granularity = null,Object? series = null,Object? totals = null,Object? dataSource = freezed,Object? availableMetrics = null,Object? metricCatalogue = null,Object? table = null,}) {
  return _then(_self.copyWith(
window: null == window ? _self.window : window // ignore: cast_nullable_to_non_nullable
as AnalyticsWindow,metric: null == metric ? _self.metric : metric // ignore: cast_nullable_to_non_nullable
as AnalyticsMetric,granularity: null == granularity ? _self.granularity : granularity // ignore: cast_nullable_to_non_nullable
as String,series: null == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,totals: null == totals ? _self.totals : totals // ignore: cast_nullable_to_non_nullable
as AnalyticsTotals,dataSource: freezed == dataSource ? _self.dataSource : dataSource // ignore: cast_nullable_to_non_nullable
as AnalyticsDataSource?,availableMetrics: null == availableMetrics ? _self.availableMetrics : availableMetrics // ignore: cast_nullable_to_non_nullable
as List<String>,metricCatalogue: null == metricCatalogue ? _self.metricCatalogue : metricCatalogue // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,table: null == table ? _self.table : table // ignore: cast_nullable_to_non_nullable
as AnalyticsTable,
  ));
}
/// Create a copy of AnalyticsTimeseries
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsWindowCopyWith<$Res> get window {
  
  return $AnalyticsWindowCopyWith<$Res>(_self.window, (value) {
    return _then(_self.copyWith(window: value));
  });
}/// Create a copy of AnalyticsTimeseries
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsMetricCopyWith<$Res> get metric {
  
  return $AnalyticsMetricCopyWith<$Res>(_self.metric, (value) {
    return _then(_self.copyWith(metric: value));
  });
}/// Create a copy of AnalyticsTimeseries
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsTotalsCopyWith<$Res> get totals {
  
  return $AnalyticsTotalsCopyWith<$Res>(_self.totals, (value) {
    return _then(_self.copyWith(totals: value));
  });
}/// Create a copy of AnalyticsTimeseries
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsDataSourceCopyWith<$Res>? get dataSource {
    if (_self.dataSource == null) {
    return null;
  }

  return $AnalyticsDataSourceCopyWith<$Res>(_self.dataSource!, (value) {
    return _then(_self.copyWith(dataSource: value));
  });
}/// Create a copy of AnalyticsTimeseries
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsTableCopyWith<$Res> get table {
  
  return $AnalyticsTableCopyWith<$Res>(_self.table, (value) {
    return _then(_self.copyWith(table: value));
  });
}
}


/// Adds pattern-matching-related methods to [AnalyticsTimeseries].
extension AnalyticsTimeseriesPatterns on AnalyticsTimeseries {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalyticsTimeseries value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalyticsTimeseries() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalyticsTimeseries value)  $default,){
final _that = this;
switch (_that) {
case _AnalyticsTimeseries():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalyticsTimeseries value)?  $default,){
final _that = this;
switch (_that) {
case _AnalyticsTimeseries() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AnalyticsWindow window,  AnalyticsMetric metric,  String granularity, @JsonKey(name: 'series', fromJson: _mapList)  List<Map<String, dynamic>> series,  AnalyticsTotals totals, @JsonKey(name: 'data_source')  AnalyticsDataSource? dataSource, @JsonKey(name: 'available_metrics', fromJson: _stringList)  List<String> availableMetrics, @JsonKey(name: 'metric_catalogue', fromJson: _mapList)  List<Map<String, dynamic>> metricCatalogue,  AnalyticsTable table)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalyticsTimeseries() when $default != null:
return $default(_that.window,_that.metric,_that.granularity,_that.series,_that.totals,_that.dataSource,_that.availableMetrics,_that.metricCatalogue,_that.table);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AnalyticsWindow window,  AnalyticsMetric metric,  String granularity, @JsonKey(name: 'series', fromJson: _mapList)  List<Map<String, dynamic>> series,  AnalyticsTotals totals, @JsonKey(name: 'data_source')  AnalyticsDataSource? dataSource, @JsonKey(name: 'available_metrics', fromJson: _stringList)  List<String> availableMetrics, @JsonKey(name: 'metric_catalogue', fromJson: _mapList)  List<Map<String, dynamic>> metricCatalogue,  AnalyticsTable table)  $default,) {final _that = this;
switch (_that) {
case _AnalyticsTimeseries():
return $default(_that.window,_that.metric,_that.granularity,_that.series,_that.totals,_that.dataSource,_that.availableMetrics,_that.metricCatalogue,_that.table);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AnalyticsWindow window,  AnalyticsMetric metric,  String granularity, @JsonKey(name: 'series', fromJson: _mapList)  List<Map<String, dynamic>> series,  AnalyticsTotals totals, @JsonKey(name: 'data_source')  AnalyticsDataSource? dataSource, @JsonKey(name: 'available_metrics', fromJson: _stringList)  List<String> availableMetrics, @JsonKey(name: 'metric_catalogue', fromJson: _mapList)  List<Map<String, dynamic>> metricCatalogue,  AnalyticsTable table)?  $default,) {final _that = this;
switch (_that) {
case _AnalyticsTimeseries() when $default != null:
return $default(_that.window,_that.metric,_that.granularity,_that.series,_that.totals,_that.dataSource,_that.availableMetrics,_that.metricCatalogue,_that.table);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnalyticsTimeseries implements AnalyticsTimeseries {
  const _AnalyticsTimeseries({this.window = const AnalyticsWindow(), this.metric = const AnalyticsMetric(), this.granularity = 'day', @JsonKey(name: 'series', fromJson: _mapList) final  List<Map<String, dynamic>> series = const <Map<String, dynamic>>[], this.totals = const AnalyticsTotals(), @JsonKey(name: 'data_source') this.dataSource, @JsonKey(name: 'available_metrics', fromJson: _stringList) final  List<String> availableMetrics = const <String>[], @JsonKey(name: 'metric_catalogue', fromJson: _mapList) final  List<Map<String, dynamic>> metricCatalogue = const <Map<String, dynamic>>[], this.table = const AnalyticsTable()}): _series = series,_availableMetrics = availableMetrics,_metricCatalogue = metricCatalogue;
  factory _AnalyticsTimeseries.fromJson(Map<String, dynamic> json) => _$AnalyticsTimeseriesFromJson(json);

@override@JsonKey() final  AnalyticsWindow window;
@override@JsonKey() final  AnalyticsMetric metric;
/// `day` or `week`.
@override@JsonKey() final  String granularity;
 final  List<Map<String, dynamic>> _series;
@override@JsonKey(name: 'series', fromJson: _mapList) List<Map<String, dynamic>> get series {
  if (_series is EqualUnmodifiableListView) return _series;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_series);
}

@override@JsonKey() final  AnalyticsTotals totals;
@override@JsonKey(name: 'data_source') final  AnalyticsDataSource? dataSource;
 final  List<String> _availableMetrics;
@override@JsonKey(name: 'available_metrics', fromJson: _stringList) List<String> get availableMetrics {
  if (_availableMetrics is EqualUnmodifiableListView) return _availableMetrics;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_availableMetrics);
}

 final  List<Map<String, dynamic>> _metricCatalogue;
@override@JsonKey(name: 'metric_catalogue', fromJson: _mapList) List<Map<String, dynamic>> get metricCatalogue {
  if (_metricCatalogue is EqualUnmodifiableListView) return _metricCatalogue;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_metricCatalogue);
}

@override@JsonKey() final  AnalyticsTable table;

/// Create a copy of AnalyticsTimeseries
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalyticsTimeseriesCopyWith<_AnalyticsTimeseries> get copyWith => __$AnalyticsTimeseriesCopyWithImpl<_AnalyticsTimeseries>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnalyticsTimeseriesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalyticsTimeseries&&(identical(other.window, window) || other.window == window)&&(identical(other.metric, metric) || other.metric == metric)&&(identical(other.granularity, granularity) || other.granularity == granularity)&&const DeepCollectionEquality().equals(other._series, _series)&&(identical(other.totals, totals) || other.totals == totals)&&(identical(other.dataSource, dataSource) || other.dataSource == dataSource)&&const DeepCollectionEquality().equals(other._availableMetrics, _availableMetrics)&&const DeepCollectionEquality().equals(other._metricCatalogue, _metricCatalogue)&&(identical(other.table, table) || other.table == table));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,window,metric,granularity,const DeepCollectionEquality().hash(_series),totals,dataSource,const DeepCollectionEquality().hash(_availableMetrics),const DeepCollectionEquality().hash(_metricCatalogue),table);

@override
String toString() {
  return 'AnalyticsTimeseries(window: $window, metric: $metric, granularity: $granularity, series: $series, totals: $totals, dataSource: $dataSource, availableMetrics: $availableMetrics, metricCatalogue: $metricCatalogue, table: $table)';
}


}

/// @nodoc
abstract mixin class _$AnalyticsTimeseriesCopyWith<$Res> implements $AnalyticsTimeseriesCopyWith<$Res> {
  factory _$AnalyticsTimeseriesCopyWith(_AnalyticsTimeseries value, $Res Function(_AnalyticsTimeseries) _then) = __$AnalyticsTimeseriesCopyWithImpl;
@override @useResult
$Res call({
 AnalyticsWindow window, AnalyticsMetric metric, String granularity,@JsonKey(name: 'series', fromJson: _mapList) List<Map<String, dynamic>> series, AnalyticsTotals totals,@JsonKey(name: 'data_source') AnalyticsDataSource? dataSource,@JsonKey(name: 'available_metrics', fromJson: _stringList) List<String> availableMetrics,@JsonKey(name: 'metric_catalogue', fromJson: _mapList) List<Map<String, dynamic>> metricCatalogue, AnalyticsTable table
});


@override $AnalyticsWindowCopyWith<$Res> get window;@override $AnalyticsMetricCopyWith<$Res> get metric;@override $AnalyticsTotalsCopyWith<$Res> get totals;@override $AnalyticsDataSourceCopyWith<$Res>? get dataSource;@override $AnalyticsTableCopyWith<$Res> get table;

}
/// @nodoc
class __$AnalyticsTimeseriesCopyWithImpl<$Res>
    implements _$AnalyticsTimeseriesCopyWith<$Res> {
  __$AnalyticsTimeseriesCopyWithImpl(this._self, this._then);

  final _AnalyticsTimeseries _self;
  final $Res Function(_AnalyticsTimeseries) _then;

/// Create a copy of AnalyticsTimeseries
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? window = null,Object? metric = null,Object? granularity = null,Object? series = null,Object? totals = null,Object? dataSource = freezed,Object? availableMetrics = null,Object? metricCatalogue = null,Object? table = null,}) {
  return _then(_AnalyticsTimeseries(
window: null == window ? _self.window : window // ignore: cast_nullable_to_non_nullable
as AnalyticsWindow,metric: null == metric ? _self.metric : metric // ignore: cast_nullable_to_non_nullable
as AnalyticsMetric,granularity: null == granularity ? _self.granularity : granularity // ignore: cast_nullable_to_non_nullable
as String,series: null == series ? _self._series : series // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,totals: null == totals ? _self.totals : totals // ignore: cast_nullable_to_non_nullable
as AnalyticsTotals,dataSource: freezed == dataSource ? _self.dataSource : dataSource // ignore: cast_nullable_to_non_nullable
as AnalyticsDataSource?,availableMetrics: null == availableMetrics ? _self._availableMetrics : availableMetrics // ignore: cast_nullable_to_non_nullable
as List<String>,metricCatalogue: null == metricCatalogue ? _self._metricCatalogue : metricCatalogue // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,table: null == table ? _self.table : table // ignore: cast_nullable_to_non_nullable
as AnalyticsTable,
  ));
}

/// Create a copy of AnalyticsTimeseries
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsWindowCopyWith<$Res> get window {
  
  return $AnalyticsWindowCopyWith<$Res>(_self.window, (value) {
    return _then(_self.copyWith(window: value));
  });
}/// Create a copy of AnalyticsTimeseries
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsMetricCopyWith<$Res> get metric {
  
  return $AnalyticsMetricCopyWith<$Res>(_self.metric, (value) {
    return _then(_self.copyWith(metric: value));
  });
}/// Create a copy of AnalyticsTimeseries
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsTotalsCopyWith<$Res> get totals {
  
  return $AnalyticsTotalsCopyWith<$Res>(_self.totals, (value) {
    return _then(_self.copyWith(totals: value));
  });
}/// Create a copy of AnalyticsTimeseries
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsDataSourceCopyWith<$Res>? get dataSource {
    if (_self.dataSource == null) {
    return null;
  }

  return $AnalyticsDataSourceCopyWith<$Res>(_self.dataSource!, (value) {
    return _then(_self.copyWith(dataSource: value));
  });
}/// Create a copy of AnalyticsTimeseries
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsTableCopyWith<$Res> get table {
  
  return $AnalyticsTableCopyWith<$Res>(_self.table, (value) {
    return _then(_self.copyWith(table: value));
  });
}
}


/// @nodoc
mixin _$TrendingItem {

 int get rank;@JsonKey(name: 'post_id') String get postId;@JsonKey(name: 'author_username') String get authorUsername;@JsonKey(name: 'post_type') String get postType;@JsonKey(name: 'body_excerpt') String get bodyExcerpt; String get createdAt; int get reactions; int get comments;@JsonKey(name: 'view_count') int get viewCount;@JsonKey(name: 'share_count') int get shareCount; int get engagement; String get kind; String get id; String get title; String get creator;@JsonKey(name: 'purchases_in_window') int get purchasesInWindow;@JsonKey(name: 'purchase_count_total') int get purchaseCountTotal;@JsonKey(name: 'average_rating') double? get averageRating;@JsonKey(name: 'review_count') int? get reviewCount;@JsonKey(name: 'is_published') bool? get isPublished; String get category;@JsonKey(name: 'event_type') String get eventType;@JsonKey(name: 'starts_at') String? get startsAt; String get shop; String get gym;@JsonKey(name: 'tickets_in_window') int get ticketsInWindow;@JsonKey(name: 'sold_tickets_in_window') int get soldTicketsInWindow;@JsonKey(name: 'attendee_count') int get attendeeCount;@JsonKey(name: 'is_cancelled') bool? get isCancelled; String get tag;@JsonKey(name: 'tag_id') String get tagId;@JsonKey(name: 'posts_in_window') int get postsInWindow;@JsonKey(name: 'posts_in_previous_window') int get postsInPreviousWindow; int get delta;@JsonKey(name: 'pct_change') double? get pctChange;@JsonKey(name: 'total_posts_ever') int get totalPostsEver;
/// Create a copy of TrendingItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrendingItemCopyWith<TrendingItem> get copyWith => _$TrendingItemCopyWithImpl<TrendingItem>(this as TrendingItem, _$identity);

  /// Serializes this TrendingItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrendingItem&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.authorUsername, authorUsername) || other.authorUsername == authorUsername)&&(identical(other.postType, postType) || other.postType == postType)&&(identical(other.bodyExcerpt, bodyExcerpt) || other.bodyExcerpt == bodyExcerpt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.reactions, reactions) || other.reactions == reactions)&&(identical(other.comments, comments) || other.comments == comments)&&(identical(other.viewCount, viewCount) || other.viewCount == viewCount)&&(identical(other.shareCount, shareCount) || other.shareCount == shareCount)&&(identical(other.engagement, engagement) || other.engagement == engagement)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.creator, creator) || other.creator == creator)&&(identical(other.purchasesInWindow, purchasesInWindow) || other.purchasesInWindow == purchasesInWindow)&&(identical(other.purchaseCountTotal, purchaseCountTotal) || other.purchaseCountTotal == purchaseCountTotal)&&(identical(other.averageRating, averageRating) || other.averageRating == averageRating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.isPublished, isPublished) || other.isPublished == isPublished)&&(identical(other.category, category) || other.category == category)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.shop, shop) || other.shop == shop)&&(identical(other.gym, gym) || other.gym == gym)&&(identical(other.ticketsInWindow, ticketsInWindow) || other.ticketsInWindow == ticketsInWindow)&&(identical(other.soldTicketsInWindow, soldTicketsInWindow) || other.soldTicketsInWindow == soldTicketsInWindow)&&(identical(other.attendeeCount, attendeeCount) || other.attendeeCount == attendeeCount)&&(identical(other.isCancelled, isCancelled) || other.isCancelled == isCancelled)&&(identical(other.tag, tag) || other.tag == tag)&&(identical(other.tagId, tagId) || other.tagId == tagId)&&(identical(other.postsInWindow, postsInWindow) || other.postsInWindow == postsInWindow)&&(identical(other.postsInPreviousWindow, postsInPreviousWindow) || other.postsInPreviousWindow == postsInPreviousWindow)&&(identical(other.delta, delta) || other.delta == delta)&&(identical(other.pctChange, pctChange) || other.pctChange == pctChange)&&(identical(other.totalPostsEver, totalPostsEver) || other.totalPostsEver == totalPostsEver));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,rank,postId,authorUsername,postType,bodyExcerpt,createdAt,reactions,comments,viewCount,shareCount,engagement,kind,id,title,creator,purchasesInWindow,purchaseCountTotal,averageRating,reviewCount,isPublished,category,eventType,startsAt,shop,gym,ticketsInWindow,soldTicketsInWindow,attendeeCount,isCancelled,tag,tagId,postsInWindow,postsInPreviousWindow,delta,pctChange,totalPostsEver]);

@override
String toString() {
  return 'TrendingItem(rank: $rank, postId: $postId, authorUsername: $authorUsername, postType: $postType, bodyExcerpt: $bodyExcerpt, createdAt: $createdAt, reactions: $reactions, comments: $comments, viewCount: $viewCount, shareCount: $shareCount, engagement: $engagement, kind: $kind, id: $id, title: $title, creator: $creator, purchasesInWindow: $purchasesInWindow, purchaseCountTotal: $purchaseCountTotal, averageRating: $averageRating, reviewCount: $reviewCount, isPublished: $isPublished, category: $category, eventType: $eventType, startsAt: $startsAt, shop: $shop, gym: $gym, ticketsInWindow: $ticketsInWindow, soldTicketsInWindow: $soldTicketsInWindow, attendeeCount: $attendeeCount, isCancelled: $isCancelled, tag: $tag, tagId: $tagId, postsInWindow: $postsInWindow, postsInPreviousWindow: $postsInPreviousWindow, delta: $delta, pctChange: $pctChange, totalPostsEver: $totalPostsEver)';
}


}

/// @nodoc
abstract mixin class $TrendingItemCopyWith<$Res>  {
  factory $TrendingItemCopyWith(TrendingItem value, $Res Function(TrendingItem) _then) = _$TrendingItemCopyWithImpl;
@useResult
$Res call({
 int rank,@JsonKey(name: 'post_id') String postId,@JsonKey(name: 'author_username') String authorUsername,@JsonKey(name: 'post_type') String postType,@JsonKey(name: 'body_excerpt') String bodyExcerpt, String createdAt, int reactions, int comments,@JsonKey(name: 'view_count') int viewCount,@JsonKey(name: 'share_count') int shareCount, int engagement, String kind, String id, String title, String creator,@JsonKey(name: 'purchases_in_window') int purchasesInWindow,@JsonKey(name: 'purchase_count_total') int purchaseCountTotal,@JsonKey(name: 'average_rating') double? averageRating,@JsonKey(name: 'review_count') int? reviewCount,@JsonKey(name: 'is_published') bool? isPublished, String category,@JsonKey(name: 'event_type') String eventType,@JsonKey(name: 'starts_at') String? startsAt, String shop, String gym,@JsonKey(name: 'tickets_in_window') int ticketsInWindow,@JsonKey(name: 'sold_tickets_in_window') int soldTicketsInWindow,@JsonKey(name: 'attendee_count') int attendeeCount,@JsonKey(name: 'is_cancelled') bool? isCancelled, String tag,@JsonKey(name: 'tag_id') String tagId,@JsonKey(name: 'posts_in_window') int postsInWindow,@JsonKey(name: 'posts_in_previous_window') int postsInPreviousWindow, int delta,@JsonKey(name: 'pct_change') double? pctChange,@JsonKey(name: 'total_posts_ever') int totalPostsEver
});




}
/// @nodoc
class _$TrendingItemCopyWithImpl<$Res>
    implements $TrendingItemCopyWith<$Res> {
  _$TrendingItemCopyWithImpl(this._self, this._then);

  final TrendingItem _self;
  final $Res Function(TrendingItem) _then;

/// Create a copy of TrendingItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rank = null,Object? postId = null,Object? authorUsername = null,Object? postType = null,Object? bodyExcerpt = null,Object? createdAt = null,Object? reactions = null,Object? comments = null,Object? viewCount = null,Object? shareCount = null,Object? engagement = null,Object? kind = null,Object? id = null,Object? title = null,Object? creator = null,Object? purchasesInWindow = null,Object? purchaseCountTotal = null,Object? averageRating = freezed,Object? reviewCount = freezed,Object? isPublished = freezed,Object? category = null,Object? eventType = null,Object? startsAt = freezed,Object? shop = null,Object? gym = null,Object? ticketsInWindow = null,Object? soldTicketsInWindow = null,Object? attendeeCount = null,Object? isCancelled = freezed,Object? tag = null,Object? tagId = null,Object? postsInWindow = null,Object? postsInPreviousWindow = null,Object? delta = null,Object? pctChange = freezed,Object? totalPostsEver = null,}) {
  return _then(_self.copyWith(
rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,authorUsername: null == authorUsername ? _self.authorUsername : authorUsername // ignore: cast_nullable_to_non_nullable
as String,postType: null == postType ? _self.postType : postType // ignore: cast_nullable_to_non_nullable
as String,bodyExcerpt: null == bodyExcerpt ? _self.bodyExcerpt : bodyExcerpt // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,reactions: null == reactions ? _self.reactions : reactions // ignore: cast_nullable_to_non_nullable
as int,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as int,viewCount: null == viewCount ? _self.viewCount : viewCount // ignore: cast_nullable_to_non_nullable
as int,shareCount: null == shareCount ? _self.shareCount : shareCount // ignore: cast_nullable_to_non_nullable
as int,engagement: null == engagement ? _self.engagement : engagement // ignore: cast_nullable_to_non_nullable
as int,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,creator: null == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as String,purchasesInWindow: null == purchasesInWindow ? _self.purchasesInWindow : purchasesInWindow // ignore: cast_nullable_to_non_nullable
as int,purchaseCountTotal: null == purchaseCountTotal ? _self.purchaseCountTotal : purchaseCountTotal // ignore: cast_nullable_to_non_nullable
as int,averageRating: freezed == averageRating ? _self.averageRating : averageRating // ignore: cast_nullable_to_non_nullable
as double?,reviewCount: freezed == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int?,isPublished: freezed == isPublished ? _self.isPublished : isPublished // ignore: cast_nullable_to_non_nullable
as bool?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as String,startsAt: freezed == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as String?,shop: null == shop ? _self.shop : shop // ignore: cast_nullable_to_non_nullable
as String,gym: null == gym ? _self.gym : gym // ignore: cast_nullable_to_non_nullable
as String,ticketsInWindow: null == ticketsInWindow ? _self.ticketsInWindow : ticketsInWindow // ignore: cast_nullable_to_non_nullable
as int,soldTicketsInWindow: null == soldTicketsInWindow ? _self.soldTicketsInWindow : soldTicketsInWindow // ignore: cast_nullable_to_non_nullable
as int,attendeeCount: null == attendeeCount ? _self.attendeeCount : attendeeCount // ignore: cast_nullable_to_non_nullable
as int,isCancelled: freezed == isCancelled ? _self.isCancelled : isCancelled // ignore: cast_nullable_to_non_nullable
as bool?,tag: null == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as String,tagId: null == tagId ? _self.tagId : tagId // ignore: cast_nullable_to_non_nullable
as String,postsInWindow: null == postsInWindow ? _self.postsInWindow : postsInWindow // ignore: cast_nullable_to_non_nullable
as int,postsInPreviousWindow: null == postsInPreviousWindow ? _self.postsInPreviousWindow : postsInPreviousWindow // ignore: cast_nullable_to_non_nullable
as int,delta: null == delta ? _self.delta : delta // ignore: cast_nullable_to_non_nullable
as int,pctChange: freezed == pctChange ? _self.pctChange : pctChange // ignore: cast_nullable_to_non_nullable
as double?,totalPostsEver: null == totalPostsEver ? _self.totalPostsEver : totalPostsEver // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TrendingItem].
extension TrendingItemPatterns on TrendingItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrendingItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrendingItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrendingItem value)  $default,){
final _that = this;
switch (_that) {
case _TrendingItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrendingItem value)?  $default,){
final _that = this;
switch (_that) {
case _TrendingItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int rank, @JsonKey(name: 'post_id')  String postId, @JsonKey(name: 'author_username')  String authorUsername, @JsonKey(name: 'post_type')  String postType, @JsonKey(name: 'body_excerpt')  String bodyExcerpt,  String createdAt,  int reactions,  int comments, @JsonKey(name: 'view_count')  int viewCount, @JsonKey(name: 'share_count')  int shareCount,  int engagement,  String kind,  String id,  String title,  String creator, @JsonKey(name: 'purchases_in_window')  int purchasesInWindow, @JsonKey(name: 'purchase_count_total')  int purchaseCountTotal, @JsonKey(name: 'average_rating')  double? averageRating, @JsonKey(name: 'review_count')  int? reviewCount, @JsonKey(name: 'is_published')  bool? isPublished,  String category, @JsonKey(name: 'event_type')  String eventType, @JsonKey(name: 'starts_at')  String? startsAt,  String shop,  String gym, @JsonKey(name: 'tickets_in_window')  int ticketsInWindow, @JsonKey(name: 'sold_tickets_in_window')  int soldTicketsInWindow, @JsonKey(name: 'attendee_count')  int attendeeCount, @JsonKey(name: 'is_cancelled')  bool? isCancelled,  String tag, @JsonKey(name: 'tag_id')  String tagId, @JsonKey(name: 'posts_in_window')  int postsInWindow, @JsonKey(name: 'posts_in_previous_window')  int postsInPreviousWindow,  int delta, @JsonKey(name: 'pct_change')  double? pctChange, @JsonKey(name: 'total_posts_ever')  int totalPostsEver)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrendingItem() when $default != null:
return $default(_that.rank,_that.postId,_that.authorUsername,_that.postType,_that.bodyExcerpt,_that.createdAt,_that.reactions,_that.comments,_that.viewCount,_that.shareCount,_that.engagement,_that.kind,_that.id,_that.title,_that.creator,_that.purchasesInWindow,_that.purchaseCountTotal,_that.averageRating,_that.reviewCount,_that.isPublished,_that.category,_that.eventType,_that.startsAt,_that.shop,_that.gym,_that.ticketsInWindow,_that.soldTicketsInWindow,_that.attendeeCount,_that.isCancelled,_that.tag,_that.tagId,_that.postsInWindow,_that.postsInPreviousWindow,_that.delta,_that.pctChange,_that.totalPostsEver);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int rank, @JsonKey(name: 'post_id')  String postId, @JsonKey(name: 'author_username')  String authorUsername, @JsonKey(name: 'post_type')  String postType, @JsonKey(name: 'body_excerpt')  String bodyExcerpt,  String createdAt,  int reactions,  int comments, @JsonKey(name: 'view_count')  int viewCount, @JsonKey(name: 'share_count')  int shareCount,  int engagement,  String kind,  String id,  String title,  String creator, @JsonKey(name: 'purchases_in_window')  int purchasesInWindow, @JsonKey(name: 'purchase_count_total')  int purchaseCountTotal, @JsonKey(name: 'average_rating')  double? averageRating, @JsonKey(name: 'review_count')  int? reviewCount, @JsonKey(name: 'is_published')  bool? isPublished,  String category, @JsonKey(name: 'event_type')  String eventType, @JsonKey(name: 'starts_at')  String? startsAt,  String shop,  String gym, @JsonKey(name: 'tickets_in_window')  int ticketsInWindow, @JsonKey(name: 'sold_tickets_in_window')  int soldTicketsInWindow, @JsonKey(name: 'attendee_count')  int attendeeCount, @JsonKey(name: 'is_cancelled')  bool? isCancelled,  String tag, @JsonKey(name: 'tag_id')  String tagId, @JsonKey(name: 'posts_in_window')  int postsInWindow, @JsonKey(name: 'posts_in_previous_window')  int postsInPreviousWindow,  int delta, @JsonKey(name: 'pct_change')  double? pctChange, @JsonKey(name: 'total_posts_ever')  int totalPostsEver)  $default,) {final _that = this;
switch (_that) {
case _TrendingItem():
return $default(_that.rank,_that.postId,_that.authorUsername,_that.postType,_that.bodyExcerpt,_that.createdAt,_that.reactions,_that.comments,_that.viewCount,_that.shareCount,_that.engagement,_that.kind,_that.id,_that.title,_that.creator,_that.purchasesInWindow,_that.purchaseCountTotal,_that.averageRating,_that.reviewCount,_that.isPublished,_that.category,_that.eventType,_that.startsAt,_that.shop,_that.gym,_that.ticketsInWindow,_that.soldTicketsInWindow,_that.attendeeCount,_that.isCancelled,_that.tag,_that.tagId,_that.postsInWindow,_that.postsInPreviousWindow,_that.delta,_that.pctChange,_that.totalPostsEver);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int rank, @JsonKey(name: 'post_id')  String postId, @JsonKey(name: 'author_username')  String authorUsername, @JsonKey(name: 'post_type')  String postType, @JsonKey(name: 'body_excerpt')  String bodyExcerpt,  String createdAt,  int reactions,  int comments, @JsonKey(name: 'view_count')  int viewCount, @JsonKey(name: 'share_count')  int shareCount,  int engagement,  String kind,  String id,  String title,  String creator, @JsonKey(name: 'purchases_in_window')  int purchasesInWindow, @JsonKey(name: 'purchase_count_total')  int purchaseCountTotal, @JsonKey(name: 'average_rating')  double? averageRating, @JsonKey(name: 'review_count')  int? reviewCount, @JsonKey(name: 'is_published')  bool? isPublished,  String category, @JsonKey(name: 'event_type')  String eventType, @JsonKey(name: 'starts_at')  String? startsAt,  String shop,  String gym, @JsonKey(name: 'tickets_in_window')  int ticketsInWindow, @JsonKey(name: 'sold_tickets_in_window')  int soldTicketsInWindow, @JsonKey(name: 'attendee_count')  int attendeeCount, @JsonKey(name: 'is_cancelled')  bool? isCancelled,  String tag, @JsonKey(name: 'tag_id')  String tagId, @JsonKey(name: 'posts_in_window')  int postsInWindow, @JsonKey(name: 'posts_in_previous_window')  int postsInPreviousWindow,  int delta, @JsonKey(name: 'pct_change')  double? pctChange, @JsonKey(name: 'total_posts_ever')  int totalPostsEver)?  $default,) {final _that = this;
switch (_that) {
case _TrendingItem() when $default != null:
return $default(_that.rank,_that.postId,_that.authorUsername,_that.postType,_that.bodyExcerpt,_that.createdAt,_that.reactions,_that.comments,_that.viewCount,_that.shareCount,_that.engagement,_that.kind,_that.id,_that.title,_that.creator,_that.purchasesInWindow,_that.purchaseCountTotal,_that.averageRating,_that.reviewCount,_that.isPublished,_that.category,_that.eventType,_that.startsAt,_that.shop,_that.gym,_that.ticketsInWindow,_that.soldTicketsInWindow,_that.attendeeCount,_that.isCancelled,_that.tag,_that.tagId,_that.postsInWindow,_that.postsInPreviousWindow,_that.delta,_that.pctChange,_that.totalPostsEver);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrendingItem implements TrendingItem {
  const _TrendingItem({this.rank = 0, @JsonKey(name: 'post_id') this.postId = '', @JsonKey(name: 'author_username') this.authorUsername = '', @JsonKey(name: 'post_type') this.postType = '', @JsonKey(name: 'body_excerpt') this.bodyExcerpt = '', this.createdAt = '', this.reactions = 0, this.comments = 0, @JsonKey(name: 'view_count') this.viewCount = 0, @JsonKey(name: 'share_count') this.shareCount = 0, this.engagement = 0, this.kind = '', this.id = '', this.title = '', this.creator = '', @JsonKey(name: 'purchases_in_window') this.purchasesInWindow = 0, @JsonKey(name: 'purchase_count_total') this.purchaseCountTotal = 0, @JsonKey(name: 'average_rating') this.averageRating, @JsonKey(name: 'review_count') this.reviewCount, @JsonKey(name: 'is_published') this.isPublished, this.category = '', @JsonKey(name: 'event_type') this.eventType = '', @JsonKey(name: 'starts_at') this.startsAt, this.shop = '', this.gym = '', @JsonKey(name: 'tickets_in_window') this.ticketsInWindow = 0, @JsonKey(name: 'sold_tickets_in_window') this.soldTicketsInWindow = 0, @JsonKey(name: 'attendee_count') this.attendeeCount = 0, @JsonKey(name: 'is_cancelled') this.isCancelled, this.tag = '', @JsonKey(name: 'tag_id') this.tagId = '', @JsonKey(name: 'posts_in_window') this.postsInWindow = 0, @JsonKey(name: 'posts_in_previous_window') this.postsInPreviousWindow = 0, this.delta = 0, @JsonKey(name: 'pct_change') this.pctChange, @JsonKey(name: 'total_posts_ever') this.totalPostsEver = 0});
  factory _TrendingItem.fromJson(Map<String, dynamic> json) => _$TrendingItemFromJson(json);

@override@JsonKey() final  int rank;
@override@JsonKey(name: 'post_id') final  String postId;
@override@JsonKey(name: 'author_username') final  String authorUsername;
@override@JsonKey(name: 'post_type') final  String postType;
@override@JsonKey(name: 'body_excerpt') final  String bodyExcerpt;
@override@JsonKey() final  String createdAt;
@override@JsonKey() final  int reactions;
@override@JsonKey() final  int comments;
@override@JsonKey(name: 'view_count') final  int viewCount;
@override@JsonKey(name: 'share_count') final  int shareCount;
@override@JsonKey() final  int engagement;
@override@JsonKey() final  String kind;
@override@JsonKey() final  String id;
@override@JsonKey() final  String title;
@override@JsonKey() final  String creator;
@override@JsonKey(name: 'purchases_in_window') final  int purchasesInWindow;
@override@JsonKey(name: 'purchase_count_total') final  int purchaseCountTotal;
@override@JsonKey(name: 'average_rating') final  double? averageRating;
@override@JsonKey(name: 'review_count') final  int? reviewCount;
@override@JsonKey(name: 'is_published') final  bool? isPublished;
@override@JsonKey() final  String category;
@override@JsonKey(name: 'event_type') final  String eventType;
@override@JsonKey(name: 'starts_at') final  String? startsAt;
@override@JsonKey() final  String shop;
@override@JsonKey() final  String gym;
@override@JsonKey(name: 'tickets_in_window') final  int ticketsInWindow;
@override@JsonKey(name: 'sold_tickets_in_window') final  int soldTicketsInWindow;
@override@JsonKey(name: 'attendee_count') final  int attendeeCount;
@override@JsonKey(name: 'is_cancelled') final  bool? isCancelled;
@override@JsonKey() final  String tag;
@override@JsonKey(name: 'tag_id') final  String tagId;
@override@JsonKey(name: 'posts_in_window') final  int postsInWindow;
@override@JsonKey(name: 'posts_in_previous_window') final  int postsInPreviousWindow;
@override@JsonKey() final  int delta;
@override@JsonKey(name: 'pct_change') final  double? pctChange;
@override@JsonKey(name: 'total_posts_ever') final  int totalPostsEver;

/// Create a copy of TrendingItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrendingItemCopyWith<_TrendingItem> get copyWith => __$TrendingItemCopyWithImpl<_TrendingItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrendingItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrendingItem&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.authorUsername, authorUsername) || other.authorUsername == authorUsername)&&(identical(other.postType, postType) || other.postType == postType)&&(identical(other.bodyExcerpt, bodyExcerpt) || other.bodyExcerpt == bodyExcerpt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.reactions, reactions) || other.reactions == reactions)&&(identical(other.comments, comments) || other.comments == comments)&&(identical(other.viewCount, viewCount) || other.viewCount == viewCount)&&(identical(other.shareCount, shareCount) || other.shareCount == shareCount)&&(identical(other.engagement, engagement) || other.engagement == engagement)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.creator, creator) || other.creator == creator)&&(identical(other.purchasesInWindow, purchasesInWindow) || other.purchasesInWindow == purchasesInWindow)&&(identical(other.purchaseCountTotal, purchaseCountTotal) || other.purchaseCountTotal == purchaseCountTotal)&&(identical(other.averageRating, averageRating) || other.averageRating == averageRating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.isPublished, isPublished) || other.isPublished == isPublished)&&(identical(other.category, category) || other.category == category)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.shop, shop) || other.shop == shop)&&(identical(other.gym, gym) || other.gym == gym)&&(identical(other.ticketsInWindow, ticketsInWindow) || other.ticketsInWindow == ticketsInWindow)&&(identical(other.soldTicketsInWindow, soldTicketsInWindow) || other.soldTicketsInWindow == soldTicketsInWindow)&&(identical(other.attendeeCount, attendeeCount) || other.attendeeCount == attendeeCount)&&(identical(other.isCancelled, isCancelled) || other.isCancelled == isCancelled)&&(identical(other.tag, tag) || other.tag == tag)&&(identical(other.tagId, tagId) || other.tagId == tagId)&&(identical(other.postsInWindow, postsInWindow) || other.postsInWindow == postsInWindow)&&(identical(other.postsInPreviousWindow, postsInPreviousWindow) || other.postsInPreviousWindow == postsInPreviousWindow)&&(identical(other.delta, delta) || other.delta == delta)&&(identical(other.pctChange, pctChange) || other.pctChange == pctChange)&&(identical(other.totalPostsEver, totalPostsEver) || other.totalPostsEver == totalPostsEver));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,rank,postId,authorUsername,postType,bodyExcerpt,createdAt,reactions,comments,viewCount,shareCount,engagement,kind,id,title,creator,purchasesInWindow,purchaseCountTotal,averageRating,reviewCount,isPublished,category,eventType,startsAt,shop,gym,ticketsInWindow,soldTicketsInWindow,attendeeCount,isCancelled,tag,tagId,postsInWindow,postsInPreviousWindow,delta,pctChange,totalPostsEver]);

@override
String toString() {
  return 'TrendingItem(rank: $rank, postId: $postId, authorUsername: $authorUsername, postType: $postType, bodyExcerpt: $bodyExcerpt, createdAt: $createdAt, reactions: $reactions, comments: $comments, viewCount: $viewCount, shareCount: $shareCount, engagement: $engagement, kind: $kind, id: $id, title: $title, creator: $creator, purchasesInWindow: $purchasesInWindow, purchaseCountTotal: $purchaseCountTotal, averageRating: $averageRating, reviewCount: $reviewCount, isPublished: $isPublished, category: $category, eventType: $eventType, startsAt: $startsAt, shop: $shop, gym: $gym, ticketsInWindow: $ticketsInWindow, soldTicketsInWindow: $soldTicketsInWindow, attendeeCount: $attendeeCount, isCancelled: $isCancelled, tag: $tag, tagId: $tagId, postsInWindow: $postsInWindow, postsInPreviousWindow: $postsInPreviousWindow, delta: $delta, pctChange: $pctChange, totalPostsEver: $totalPostsEver)';
}


}

/// @nodoc
abstract mixin class _$TrendingItemCopyWith<$Res> implements $TrendingItemCopyWith<$Res> {
  factory _$TrendingItemCopyWith(_TrendingItem value, $Res Function(_TrendingItem) _then) = __$TrendingItemCopyWithImpl;
@override @useResult
$Res call({
 int rank,@JsonKey(name: 'post_id') String postId,@JsonKey(name: 'author_username') String authorUsername,@JsonKey(name: 'post_type') String postType,@JsonKey(name: 'body_excerpt') String bodyExcerpt, String createdAt, int reactions, int comments,@JsonKey(name: 'view_count') int viewCount,@JsonKey(name: 'share_count') int shareCount, int engagement, String kind, String id, String title, String creator,@JsonKey(name: 'purchases_in_window') int purchasesInWindow,@JsonKey(name: 'purchase_count_total') int purchaseCountTotal,@JsonKey(name: 'average_rating') double? averageRating,@JsonKey(name: 'review_count') int? reviewCount,@JsonKey(name: 'is_published') bool? isPublished, String category,@JsonKey(name: 'event_type') String eventType,@JsonKey(name: 'starts_at') String? startsAt, String shop, String gym,@JsonKey(name: 'tickets_in_window') int ticketsInWindow,@JsonKey(name: 'sold_tickets_in_window') int soldTicketsInWindow,@JsonKey(name: 'attendee_count') int attendeeCount,@JsonKey(name: 'is_cancelled') bool? isCancelled, String tag,@JsonKey(name: 'tag_id') String tagId,@JsonKey(name: 'posts_in_window') int postsInWindow,@JsonKey(name: 'posts_in_previous_window') int postsInPreviousWindow, int delta,@JsonKey(name: 'pct_change') double? pctChange,@JsonKey(name: 'total_posts_ever') int totalPostsEver
});




}
/// @nodoc
class __$TrendingItemCopyWithImpl<$Res>
    implements _$TrendingItemCopyWith<$Res> {
  __$TrendingItemCopyWithImpl(this._self, this._then);

  final _TrendingItem _self;
  final $Res Function(_TrendingItem) _then;

/// Create a copy of TrendingItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rank = null,Object? postId = null,Object? authorUsername = null,Object? postType = null,Object? bodyExcerpt = null,Object? createdAt = null,Object? reactions = null,Object? comments = null,Object? viewCount = null,Object? shareCount = null,Object? engagement = null,Object? kind = null,Object? id = null,Object? title = null,Object? creator = null,Object? purchasesInWindow = null,Object? purchaseCountTotal = null,Object? averageRating = freezed,Object? reviewCount = freezed,Object? isPublished = freezed,Object? category = null,Object? eventType = null,Object? startsAt = freezed,Object? shop = null,Object? gym = null,Object? ticketsInWindow = null,Object? soldTicketsInWindow = null,Object? attendeeCount = null,Object? isCancelled = freezed,Object? tag = null,Object? tagId = null,Object? postsInWindow = null,Object? postsInPreviousWindow = null,Object? delta = null,Object? pctChange = freezed,Object? totalPostsEver = null,}) {
  return _then(_TrendingItem(
rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,authorUsername: null == authorUsername ? _self.authorUsername : authorUsername // ignore: cast_nullable_to_non_nullable
as String,postType: null == postType ? _self.postType : postType // ignore: cast_nullable_to_non_nullable
as String,bodyExcerpt: null == bodyExcerpt ? _self.bodyExcerpt : bodyExcerpt // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,reactions: null == reactions ? _self.reactions : reactions // ignore: cast_nullable_to_non_nullable
as int,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as int,viewCount: null == viewCount ? _self.viewCount : viewCount // ignore: cast_nullable_to_non_nullable
as int,shareCount: null == shareCount ? _self.shareCount : shareCount // ignore: cast_nullable_to_non_nullable
as int,engagement: null == engagement ? _self.engagement : engagement // ignore: cast_nullable_to_non_nullable
as int,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,creator: null == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as String,purchasesInWindow: null == purchasesInWindow ? _self.purchasesInWindow : purchasesInWindow // ignore: cast_nullable_to_non_nullable
as int,purchaseCountTotal: null == purchaseCountTotal ? _self.purchaseCountTotal : purchaseCountTotal // ignore: cast_nullable_to_non_nullable
as int,averageRating: freezed == averageRating ? _self.averageRating : averageRating // ignore: cast_nullable_to_non_nullable
as double?,reviewCount: freezed == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int?,isPublished: freezed == isPublished ? _self.isPublished : isPublished // ignore: cast_nullable_to_non_nullable
as bool?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as String,startsAt: freezed == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as String?,shop: null == shop ? _self.shop : shop // ignore: cast_nullable_to_non_nullable
as String,gym: null == gym ? _self.gym : gym // ignore: cast_nullable_to_non_nullable
as String,ticketsInWindow: null == ticketsInWindow ? _self.ticketsInWindow : ticketsInWindow // ignore: cast_nullable_to_non_nullable
as int,soldTicketsInWindow: null == soldTicketsInWindow ? _self.soldTicketsInWindow : soldTicketsInWindow // ignore: cast_nullable_to_non_nullable
as int,attendeeCount: null == attendeeCount ? _self.attendeeCount : attendeeCount // ignore: cast_nullable_to_non_nullable
as int,isCancelled: freezed == isCancelled ? _self.isCancelled : isCancelled // ignore: cast_nullable_to_non_nullable
as bool?,tag: null == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as String,tagId: null == tagId ? _self.tagId : tagId // ignore: cast_nullable_to_non_nullable
as String,postsInWindow: null == postsInWindow ? _self.postsInWindow : postsInWindow // ignore: cast_nullable_to_non_nullable
as int,postsInPreviousWindow: null == postsInPreviousWindow ? _self.postsInPreviousWindow : postsInPreviousWindow // ignore: cast_nullable_to_non_nullable
as int,delta: null == delta ? _self.delta : delta // ignore: cast_nullable_to_non_nullable
as int,pctChange: freezed == pctChange ? _self.pctChange : pctChange // ignore: cast_nullable_to_non_nullable
as double?,totalPostsEver: null == totalPostsEver ? _self.totalPostsEver : totalPostsEver // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$AnalyticsTrending {

 String get kind;/// Defaults false: an absent `available` must not let a list through.
 bool get available; String get reason; AnalyticsWindow get window;@JsonKey(name: 'rank_basis') String get rankBasis;@JsonKey(name: 'items', fromJson: _mapList) List<Map<String, dynamic>> get items; AnalyticsTable get table;
/// Create a copy of AnalyticsTrending
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalyticsTrendingCopyWith<AnalyticsTrending> get copyWith => _$AnalyticsTrendingCopyWithImpl<AnalyticsTrending>(this as AnalyticsTrending, _$identity);

  /// Serializes this AnalyticsTrending to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalyticsTrending&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.available, available) || other.available == available)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.window, window) || other.window == window)&&(identical(other.rankBasis, rankBasis) || other.rankBasis == rankBasis)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.table, table) || other.table == table));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,available,reason,window,rankBasis,const DeepCollectionEquality().hash(items),table);

@override
String toString() {
  return 'AnalyticsTrending(kind: $kind, available: $available, reason: $reason, window: $window, rankBasis: $rankBasis, items: $items, table: $table)';
}


}

/// @nodoc
abstract mixin class $AnalyticsTrendingCopyWith<$Res>  {
  factory $AnalyticsTrendingCopyWith(AnalyticsTrending value, $Res Function(AnalyticsTrending) _then) = _$AnalyticsTrendingCopyWithImpl;
@useResult
$Res call({
 String kind, bool available, String reason, AnalyticsWindow window,@JsonKey(name: 'rank_basis') String rankBasis,@JsonKey(name: 'items', fromJson: _mapList) List<Map<String, dynamic>> items, AnalyticsTable table
});


$AnalyticsWindowCopyWith<$Res> get window;$AnalyticsTableCopyWith<$Res> get table;

}
/// @nodoc
class _$AnalyticsTrendingCopyWithImpl<$Res>
    implements $AnalyticsTrendingCopyWith<$Res> {
  _$AnalyticsTrendingCopyWithImpl(this._self, this._then);

  final AnalyticsTrending _self;
  final $Res Function(AnalyticsTrending) _then;

/// Create a copy of AnalyticsTrending
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? available = null,Object? reason = null,Object? window = null,Object? rankBasis = null,Object? items = null,Object? table = null,}) {
  return _then(_self.copyWith(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,window: null == window ? _self.window : window // ignore: cast_nullable_to_non_nullable
as AnalyticsWindow,rankBasis: null == rankBasis ? _self.rankBasis : rankBasis // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,table: null == table ? _self.table : table // ignore: cast_nullable_to_non_nullable
as AnalyticsTable,
  ));
}
/// Create a copy of AnalyticsTrending
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsWindowCopyWith<$Res> get window {
  
  return $AnalyticsWindowCopyWith<$Res>(_self.window, (value) {
    return _then(_self.copyWith(window: value));
  });
}/// Create a copy of AnalyticsTrending
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsTableCopyWith<$Res> get table {
  
  return $AnalyticsTableCopyWith<$Res>(_self.table, (value) {
    return _then(_self.copyWith(table: value));
  });
}
}


/// Adds pattern-matching-related methods to [AnalyticsTrending].
extension AnalyticsTrendingPatterns on AnalyticsTrending {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalyticsTrending value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalyticsTrending() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalyticsTrending value)  $default,){
final _that = this;
switch (_that) {
case _AnalyticsTrending():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalyticsTrending value)?  $default,){
final _that = this;
switch (_that) {
case _AnalyticsTrending() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String kind,  bool available,  String reason,  AnalyticsWindow window, @JsonKey(name: 'rank_basis')  String rankBasis, @JsonKey(name: 'items', fromJson: _mapList)  List<Map<String, dynamic>> items,  AnalyticsTable table)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalyticsTrending() when $default != null:
return $default(_that.kind,_that.available,_that.reason,_that.window,_that.rankBasis,_that.items,_that.table);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String kind,  bool available,  String reason,  AnalyticsWindow window, @JsonKey(name: 'rank_basis')  String rankBasis, @JsonKey(name: 'items', fromJson: _mapList)  List<Map<String, dynamic>> items,  AnalyticsTable table)  $default,) {final _that = this;
switch (_that) {
case _AnalyticsTrending():
return $default(_that.kind,_that.available,_that.reason,_that.window,_that.rankBasis,_that.items,_that.table);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String kind,  bool available,  String reason,  AnalyticsWindow window, @JsonKey(name: 'rank_basis')  String rankBasis, @JsonKey(name: 'items', fromJson: _mapList)  List<Map<String, dynamic>> items,  AnalyticsTable table)?  $default,) {final _that = this;
switch (_that) {
case _AnalyticsTrending() when $default != null:
return $default(_that.kind,_that.available,_that.reason,_that.window,_that.rankBasis,_that.items,_that.table);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnalyticsTrending implements AnalyticsTrending {
  const _AnalyticsTrending({this.kind = '', this.available = false, this.reason = '', this.window = const AnalyticsWindow(), @JsonKey(name: 'rank_basis') this.rankBasis = '', @JsonKey(name: 'items', fromJson: _mapList) final  List<Map<String, dynamic>> items = const <Map<String, dynamic>>[], this.table = const AnalyticsTable()}): _items = items;
  factory _AnalyticsTrending.fromJson(Map<String, dynamic> json) => _$AnalyticsTrendingFromJson(json);

@override@JsonKey() final  String kind;
/// Defaults false: an absent `available` must not let a list through.
@override@JsonKey() final  bool available;
@override@JsonKey() final  String reason;
@override@JsonKey() final  AnalyticsWindow window;
@override@JsonKey(name: 'rank_basis') final  String rankBasis;
 final  List<Map<String, dynamic>> _items;
@override@JsonKey(name: 'items', fromJson: _mapList) List<Map<String, dynamic>> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  AnalyticsTable table;

/// Create a copy of AnalyticsTrending
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalyticsTrendingCopyWith<_AnalyticsTrending> get copyWith => __$AnalyticsTrendingCopyWithImpl<_AnalyticsTrending>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnalyticsTrendingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalyticsTrending&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.available, available) || other.available == available)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.window, window) || other.window == window)&&(identical(other.rankBasis, rankBasis) || other.rankBasis == rankBasis)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.table, table) || other.table == table));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,available,reason,window,rankBasis,const DeepCollectionEquality().hash(_items),table);

@override
String toString() {
  return 'AnalyticsTrending(kind: $kind, available: $available, reason: $reason, window: $window, rankBasis: $rankBasis, items: $items, table: $table)';
}


}

/// @nodoc
abstract mixin class _$AnalyticsTrendingCopyWith<$Res> implements $AnalyticsTrendingCopyWith<$Res> {
  factory _$AnalyticsTrendingCopyWith(_AnalyticsTrending value, $Res Function(_AnalyticsTrending) _then) = __$AnalyticsTrendingCopyWithImpl;
@override @useResult
$Res call({
 String kind, bool available, String reason, AnalyticsWindow window,@JsonKey(name: 'rank_basis') String rankBasis,@JsonKey(name: 'items', fromJson: _mapList) List<Map<String, dynamic>> items, AnalyticsTable table
});


@override $AnalyticsWindowCopyWith<$Res> get window;@override $AnalyticsTableCopyWith<$Res> get table;

}
/// @nodoc
class __$AnalyticsTrendingCopyWithImpl<$Res>
    implements _$AnalyticsTrendingCopyWith<$Res> {
  __$AnalyticsTrendingCopyWithImpl(this._self, this._then);

  final _AnalyticsTrending _self;
  final $Res Function(_AnalyticsTrending) _then;

/// Create a copy of AnalyticsTrending
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? available = null,Object? reason = null,Object? window = null,Object? rankBasis = null,Object? items = null,Object? table = null,}) {
  return _then(_AnalyticsTrending(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,window: null == window ? _self.window : window // ignore: cast_nullable_to_non_nullable
as AnalyticsWindow,rankBasis: null == rankBasis ? _self.rankBasis : rankBasis // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,table: null == table ? _self.table : table // ignore: cast_nullable_to_non_nullable
as AnalyticsTable,
  ));
}

/// Create a copy of AnalyticsTrending
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsWindowCopyWith<$Res> get window {
  
  return $AnalyticsWindowCopyWith<$Res>(_self.window, (value) {
    return _then(_self.copyWith(window: value));
  });
}/// Create a copy of AnalyticsTrending
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsTableCopyWith<$Res> get table {
  
  return $AnalyticsTableCopyWith<$Res>(_self.table, (value) {
    return _then(_self.copyWith(table: value));
  });
}
}


/// @nodoc
mixin _$AiQualityTotals {

 int get calls; int get fallbacks;@JsonKey(name: 'fallback_rate') double? get fallbackRate; int get corrections;@JsonKey(name: 'accuracy_proxy') double? get accuracyProxy;@JsonKey(name: 'cost_usd', fromJson: _optNumOrZero) num get costUsd;@JsonKey(name: 'cost_per_call_usd', fromJson: _optNumOrZero) num get costPerCallUsd;@JsonKey(name: 'cumulative_cost_usd', fromJson: _optNumOrZero) num get cumulativeCostUsd;@JsonKey(name: 'cumulative_calls') int get cumulativeCalls;@JsonKey(name: 'cumulative_cost_per_call_usd', fromJson: _optNumOrZero) num get cumulativeCostPerCallUsd;
/// Create a copy of AiQualityTotals
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiQualityTotalsCopyWith<AiQualityTotals> get copyWith => _$AiQualityTotalsCopyWithImpl<AiQualityTotals>(this as AiQualityTotals, _$identity);

  /// Serializes this AiQualityTotals to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiQualityTotals&&(identical(other.calls, calls) || other.calls == calls)&&(identical(other.fallbacks, fallbacks) || other.fallbacks == fallbacks)&&(identical(other.fallbackRate, fallbackRate) || other.fallbackRate == fallbackRate)&&(identical(other.corrections, corrections) || other.corrections == corrections)&&(identical(other.accuracyProxy, accuracyProxy) || other.accuracyProxy == accuracyProxy)&&(identical(other.costUsd, costUsd) || other.costUsd == costUsd)&&(identical(other.costPerCallUsd, costPerCallUsd) || other.costPerCallUsd == costPerCallUsd)&&(identical(other.cumulativeCostUsd, cumulativeCostUsd) || other.cumulativeCostUsd == cumulativeCostUsd)&&(identical(other.cumulativeCalls, cumulativeCalls) || other.cumulativeCalls == cumulativeCalls)&&(identical(other.cumulativeCostPerCallUsd, cumulativeCostPerCallUsd) || other.cumulativeCostPerCallUsd == cumulativeCostPerCallUsd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,calls,fallbacks,fallbackRate,corrections,accuracyProxy,costUsd,costPerCallUsd,cumulativeCostUsd,cumulativeCalls,cumulativeCostPerCallUsd);

@override
String toString() {
  return 'AiQualityTotals(calls: $calls, fallbacks: $fallbacks, fallbackRate: $fallbackRate, corrections: $corrections, accuracyProxy: $accuracyProxy, costUsd: $costUsd, costPerCallUsd: $costPerCallUsd, cumulativeCostUsd: $cumulativeCostUsd, cumulativeCalls: $cumulativeCalls, cumulativeCostPerCallUsd: $cumulativeCostPerCallUsd)';
}


}

/// @nodoc
abstract mixin class $AiQualityTotalsCopyWith<$Res>  {
  factory $AiQualityTotalsCopyWith(AiQualityTotals value, $Res Function(AiQualityTotals) _then) = _$AiQualityTotalsCopyWithImpl;
@useResult
$Res call({
 int calls, int fallbacks,@JsonKey(name: 'fallback_rate') double? fallbackRate, int corrections,@JsonKey(name: 'accuracy_proxy') double? accuracyProxy,@JsonKey(name: 'cost_usd', fromJson: _optNumOrZero) num costUsd,@JsonKey(name: 'cost_per_call_usd', fromJson: _optNumOrZero) num costPerCallUsd,@JsonKey(name: 'cumulative_cost_usd', fromJson: _optNumOrZero) num cumulativeCostUsd,@JsonKey(name: 'cumulative_calls') int cumulativeCalls,@JsonKey(name: 'cumulative_cost_per_call_usd', fromJson: _optNumOrZero) num cumulativeCostPerCallUsd
});




}
/// @nodoc
class _$AiQualityTotalsCopyWithImpl<$Res>
    implements $AiQualityTotalsCopyWith<$Res> {
  _$AiQualityTotalsCopyWithImpl(this._self, this._then);

  final AiQualityTotals _self;
  final $Res Function(AiQualityTotals) _then;

/// Create a copy of AiQualityTotals
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? calls = null,Object? fallbacks = null,Object? fallbackRate = freezed,Object? corrections = null,Object? accuracyProxy = freezed,Object? costUsd = null,Object? costPerCallUsd = null,Object? cumulativeCostUsd = null,Object? cumulativeCalls = null,Object? cumulativeCostPerCallUsd = null,}) {
  return _then(_self.copyWith(
calls: null == calls ? _self.calls : calls // ignore: cast_nullable_to_non_nullable
as int,fallbacks: null == fallbacks ? _self.fallbacks : fallbacks // ignore: cast_nullable_to_non_nullable
as int,fallbackRate: freezed == fallbackRate ? _self.fallbackRate : fallbackRate // ignore: cast_nullable_to_non_nullable
as double?,corrections: null == corrections ? _self.corrections : corrections // ignore: cast_nullable_to_non_nullable
as int,accuracyProxy: freezed == accuracyProxy ? _self.accuracyProxy : accuracyProxy // ignore: cast_nullable_to_non_nullable
as double?,costUsd: null == costUsd ? _self.costUsd : costUsd // ignore: cast_nullable_to_non_nullable
as num,costPerCallUsd: null == costPerCallUsd ? _self.costPerCallUsd : costPerCallUsd // ignore: cast_nullable_to_non_nullable
as num,cumulativeCostUsd: null == cumulativeCostUsd ? _self.cumulativeCostUsd : cumulativeCostUsd // ignore: cast_nullable_to_non_nullable
as num,cumulativeCalls: null == cumulativeCalls ? _self.cumulativeCalls : cumulativeCalls // ignore: cast_nullable_to_non_nullable
as int,cumulativeCostPerCallUsd: null == cumulativeCostPerCallUsd ? _self.cumulativeCostPerCallUsd : cumulativeCostPerCallUsd // ignore: cast_nullable_to_non_nullable
as num,
  ));
}

}


/// Adds pattern-matching-related methods to [AiQualityTotals].
extension AiQualityTotalsPatterns on AiQualityTotals {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiQualityTotals value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiQualityTotals() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiQualityTotals value)  $default,){
final _that = this;
switch (_that) {
case _AiQualityTotals():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiQualityTotals value)?  $default,){
final _that = this;
switch (_that) {
case _AiQualityTotals() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int calls,  int fallbacks, @JsonKey(name: 'fallback_rate')  double? fallbackRate,  int corrections, @JsonKey(name: 'accuracy_proxy')  double? accuracyProxy, @JsonKey(name: 'cost_usd', fromJson: _optNumOrZero)  num costUsd, @JsonKey(name: 'cost_per_call_usd', fromJson: _optNumOrZero)  num costPerCallUsd, @JsonKey(name: 'cumulative_cost_usd', fromJson: _optNumOrZero)  num cumulativeCostUsd, @JsonKey(name: 'cumulative_calls')  int cumulativeCalls, @JsonKey(name: 'cumulative_cost_per_call_usd', fromJson: _optNumOrZero)  num cumulativeCostPerCallUsd)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiQualityTotals() when $default != null:
return $default(_that.calls,_that.fallbacks,_that.fallbackRate,_that.corrections,_that.accuracyProxy,_that.costUsd,_that.costPerCallUsd,_that.cumulativeCostUsd,_that.cumulativeCalls,_that.cumulativeCostPerCallUsd);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int calls,  int fallbacks, @JsonKey(name: 'fallback_rate')  double? fallbackRate,  int corrections, @JsonKey(name: 'accuracy_proxy')  double? accuracyProxy, @JsonKey(name: 'cost_usd', fromJson: _optNumOrZero)  num costUsd, @JsonKey(name: 'cost_per_call_usd', fromJson: _optNumOrZero)  num costPerCallUsd, @JsonKey(name: 'cumulative_cost_usd', fromJson: _optNumOrZero)  num cumulativeCostUsd, @JsonKey(name: 'cumulative_calls')  int cumulativeCalls, @JsonKey(name: 'cumulative_cost_per_call_usd', fromJson: _optNumOrZero)  num cumulativeCostPerCallUsd)  $default,) {final _that = this;
switch (_that) {
case _AiQualityTotals():
return $default(_that.calls,_that.fallbacks,_that.fallbackRate,_that.corrections,_that.accuracyProxy,_that.costUsd,_that.costPerCallUsd,_that.cumulativeCostUsd,_that.cumulativeCalls,_that.cumulativeCostPerCallUsd);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int calls,  int fallbacks, @JsonKey(name: 'fallback_rate')  double? fallbackRate,  int corrections, @JsonKey(name: 'accuracy_proxy')  double? accuracyProxy, @JsonKey(name: 'cost_usd', fromJson: _optNumOrZero)  num costUsd, @JsonKey(name: 'cost_per_call_usd', fromJson: _optNumOrZero)  num costPerCallUsd, @JsonKey(name: 'cumulative_cost_usd', fromJson: _optNumOrZero)  num cumulativeCostUsd, @JsonKey(name: 'cumulative_calls')  int cumulativeCalls, @JsonKey(name: 'cumulative_cost_per_call_usd', fromJson: _optNumOrZero)  num cumulativeCostPerCallUsd)?  $default,) {final _that = this;
switch (_that) {
case _AiQualityTotals() when $default != null:
return $default(_that.calls,_that.fallbacks,_that.fallbackRate,_that.corrections,_that.accuracyProxy,_that.costUsd,_that.costPerCallUsd,_that.cumulativeCostUsd,_that.cumulativeCalls,_that.cumulativeCostPerCallUsd);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiQualityTotals implements AiQualityTotals {
  const _AiQualityTotals({this.calls = 0, this.fallbacks = 0, @JsonKey(name: 'fallback_rate') this.fallbackRate, this.corrections = 0, @JsonKey(name: 'accuracy_proxy') this.accuracyProxy, @JsonKey(name: 'cost_usd', fromJson: _optNumOrZero) this.costUsd = 0, @JsonKey(name: 'cost_per_call_usd', fromJson: _optNumOrZero) this.costPerCallUsd = 0, @JsonKey(name: 'cumulative_cost_usd', fromJson: _optNumOrZero) this.cumulativeCostUsd = 0, @JsonKey(name: 'cumulative_calls') this.cumulativeCalls = 0, @JsonKey(name: 'cumulative_cost_per_call_usd', fromJson: _optNumOrZero) this.cumulativeCostPerCallUsd = 0});
  factory _AiQualityTotals.fromJson(Map<String, dynamic> json) => _$AiQualityTotalsFromJson(json);

@override@JsonKey() final  int calls;
@override@JsonKey() final  int fallbacks;
@override@JsonKey(name: 'fallback_rate') final  double? fallbackRate;
@override@JsonKey() final  int corrections;
@override@JsonKey(name: 'accuracy_proxy') final  double? accuracyProxy;
@override@JsonKey(name: 'cost_usd', fromJson: _optNumOrZero) final  num costUsd;
@override@JsonKey(name: 'cost_per_call_usd', fromJson: _optNumOrZero) final  num costPerCallUsd;
@override@JsonKey(name: 'cumulative_cost_usd', fromJson: _optNumOrZero) final  num cumulativeCostUsd;
@override@JsonKey(name: 'cumulative_calls') final  int cumulativeCalls;
@override@JsonKey(name: 'cumulative_cost_per_call_usd', fromJson: _optNumOrZero) final  num cumulativeCostPerCallUsd;

/// Create a copy of AiQualityTotals
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiQualityTotalsCopyWith<_AiQualityTotals> get copyWith => __$AiQualityTotalsCopyWithImpl<_AiQualityTotals>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiQualityTotalsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiQualityTotals&&(identical(other.calls, calls) || other.calls == calls)&&(identical(other.fallbacks, fallbacks) || other.fallbacks == fallbacks)&&(identical(other.fallbackRate, fallbackRate) || other.fallbackRate == fallbackRate)&&(identical(other.corrections, corrections) || other.corrections == corrections)&&(identical(other.accuracyProxy, accuracyProxy) || other.accuracyProxy == accuracyProxy)&&(identical(other.costUsd, costUsd) || other.costUsd == costUsd)&&(identical(other.costPerCallUsd, costPerCallUsd) || other.costPerCallUsd == costPerCallUsd)&&(identical(other.cumulativeCostUsd, cumulativeCostUsd) || other.cumulativeCostUsd == cumulativeCostUsd)&&(identical(other.cumulativeCalls, cumulativeCalls) || other.cumulativeCalls == cumulativeCalls)&&(identical(other.cumulativeCostPerCallUsd, cumulativeCostPerCallUsd) || other.cumulativeCostPerCallUsd == cumulativeCostPerCallUsd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,calls,fallbacks,fallbackRate,corrections,accuracyProxy,costUsd,costPerCallUsd,cumulativeCostUsd,cumulativeCalls,cumulativeCostPerCallUsd);

@override
String toString() {
  return 'AiQualityTotals(calls: $calls, fallbacks: $fallbacks, fallbackRate: $fallbackRate, corrections: $corrections, accuracyProxy: $accuracyProxy, costUsd: $costUsd, costPerCallUsd: $costPerCallUsd, cumulativeCostUsd: $cumulativeCostUsd, cumulativeCalls: $cumulativeCalls, cumulativeCostPerCallUsd: $cumulativeCostPerCallUsd)';
}


}

/// @nodoc
abstract mixin class _$AiQualityTotalsCopyWith<$Res> implements $AiQualityTotalsCopyWith<$Res> {
  factory _$AiQualityTotalsCopyWith(_AiQualityTotals value, $Res Function(_AiQualityTotals) _then) = __$AiQualityTotalsCopyWithImpl;
@override @useResult
$Res call({
 int calls, int fallbacks,@JsonKey(name: 'fallback_rate') double? fallbackRate, int corrections,@JsonKey(name: 'accuracy_proxy') double? accuracyProxy,@JsonKey(name: 'cost_usd', fromJson: _optNumOrZero) num costUsd,@JsonKey(name: 'cost_per_call_usd', fromJson: _optNumOrZero) num costPerCallUsd,@JsonKey(name: 'cumulative_cost_usd', fromJson: _optNumOrZero) num cumulativeCostUsd,@JsonKey(name: 'cumulative_calls') int cumulativeCalls,@JsonKey(name: 'cumulative_cost_per_call_usd', fromJson: _optNumOrZero) num cumulativeCostPerCallUsd
});




}
/// @nodoc
class __$AiQualityTotalsCopyWithImpl<$Res>
    implements _$AiQualityTotalsCopyWith<$Res> {
  __$AiQualityTotalsCopyWithImpl(this._self, this._then);

  final _AiQualityTotals _self;
  final $Res Function(_AiQualityTotals) _then;

/// Create a copy of AiQualityTotals
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? calls = null,Object? fallbacks = null,Object? fallbackRate = freezed,Object? corrections = null,Object? accuracyProxy = freezed,Object? costUsd = null,Object? costPerCallUsd = null,Object? cumulativeCostUsd = null,Object? cumulativeCalls = null,Object? cumulativeCostPerCallUsd = null,}) {
  return _then(_AiQualityTotals(
calls: null == calls ? _self.calls : calls // ignore: cast_nullable_to_non_nullable
as int,fallbacks: null == fallbacks ? _self.fallbacks : fallbacks // ignore: cast_nullable_to_non_nullable
as int,fallbackRate: freezed == fallbackRate ? _self.fallbackRate : fallbackRate // ignore: cast_nullable_to_non_nullable
as double?,corrections: null == corrections ? _self.corrections : corrections // ignore: cast_nullable_to_non_nullable
as int,accuracyProxy: freezed == accuracyProxy ? _self.accuracyProxy : accuracyProxy // ignore: cast_nullable_to_non_nullable
as double?,costUsd: null == costUsd ? _self.costUsd : costUsd // ignore: cast_nullable_to_non_nullable
as num,costPerCallUsd: null == costPerCallUsd ? _self.costPerCallUsd : costPerCallUsd // ignore: cast_nullable_to_non_nullable
as num,cumulativeCostUsd: null == cumulativeCostUsd ? _self.cumulativeCostUsd : cumulativeCostUsd // ignore: cast_nullable_to_non_nullable
as num,cumulativeCalls: null == cumulativeCalls ? _self.cumulativeCalls : cumulativeCalls // ignore: cast_nullable_to_non_nullable
as int,cumulativeCostPerCallUsd: null == cumulativeCostPerCallUsd ? _self.cumulativeCostPerCallUsd : cumulativeCostPerCallUsd // ignore: cast_nullable_to_non_nullable
as num,
  ));
}


}


/// @nodoc
mixin _$AiQualityLatency {

 int get samples; bool get sampled;@JsonKey(name: 'sample_limit') int get sampleLimit;@JsonKey(name: 'p50') int? get p50;@JsonKey(name: 'p95') int? get p95; int? get min; int? get max;
/// Create a copy of AiQualityLatency
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiQualityLatencyCopyWith<AiQualityLatency> get copyWith => _$AiQualityLatencyCopyWithImpl<AiQualityLatency>(this as AiQualityLatency, _$identity);

  /// Serializes this AiQualityLatency to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiQualityLatency&&(identical(other.samples, samples) || other.samples == samples)&&(identical(other.sampled, sampled) || other.sampled == sampled)&&(identical(other.sampleLimit, sampleLimit) || other.sampleLimit == sampleLimit)&&(identical(other.p50, p50) || other.p50 == p50)&&(identical(other.p95, p95) || other.p95 == p95)&&(identical(other.min, min) || other.min == min)&&(identical(other.max, max) || other.max == max));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,samples,sampled,sampleLimit,p50,p95,min,max);

@override
String toString() {
  return 'AiQualityLatency(samples: $samples, sampled: $sampled, sampleLimit: $sampleLimit, p50: $p50, p95: $p95, min: $min, max: $max)';
}


}

/// @nodoc
abstract mixin class $AiQualityLatencyCopyWith<$Res>  {
  factory $AiQualityLatencyCopyWith(AiQualityLatency value, $Res Function(AiQualityLatency) _then) = _$AiQualityLatencyCopyWithImpl;
@useResult
$Res call({
 int samples, bool sampled,@JsonKey(name: 'sample_limit') int sampleLimit,@JsonKey(name: 'p50') int? p50,@JsonKey(name: 'p95') int? p95, int? min, int? max
});




}
/// @nodoc
class _$AiQualityLatencyCopyWithImpl<$Res>
    implements $AiQualityLatencyCopyWith<$Res> {
  _$AiQualityLatencyCopyWithImpl(this._self, this._then);

  final AiQualityLatency _self;
  final $Res Function(AiQualityLatency) _then;

/// Create a copy of AiQualityLatency
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? samples = null,Object? sampled = null,Object? sampleLimit = null,Object? p50 = freezed,Object? p95 = freezed,Object? min = freezed,Object? max = freezed,}) {
  return _then(_self.copyWith(
samples: null == samples ? _self.samples : samples // ignore: cast_nullable_to_non_nullable
as int,sampled: null == sampled ? _self.sampled : sampled // ignore: cast_nullable_to_non_nullable
as bool,sampleLimit: null == sampleLimit ? _self.sampleLimit : sampleLimit // ignore: cast_nullable_to_non_nullable
as int,p50: freezed == p50 ? _self.p50 : p50 // ignore: cast_nullable_to_non_nullable
as int?,p95: freezed == p95 ? _self.p95 : p95 // ignore: cast_nullable_to_non_nullable
as int?,min: freezed == min ? _self.min : min // ignore: cast_nullable_to_non_nullable
as int?,max: freezed == max ? _self.max : max // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [AiQualityLatency].
extension AiQualityLatencyPatterns on AiQualityLatency {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiQualityLatency value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiQualityLatency() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiQualityLatency value)  $default,){
final _that = this;
switch (_that) {
case _AiQualityLatency():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiQualityLatency value)?  $default,){
final _that = this;
switch (_that) {
case _AiQualityLatency() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int samples,  bool sampled, @JsonKey(name: 'sample_limit')  int sampleLimit, @JsonKey(name: 'p50')  int? p50, @JsonKey(name: 'p95')  int? p95,  int? min,  int? max)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiQualityLatency() when $default != null:
return $default(_that.samples,_that.sampled,_that.sampleLimit,_that.p50,_that.p95,_that.min,_that.max);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int samples,  bool sampled, @JsonKey(name: 'sample_limit')  int sampleLimit, @JsonKey(name: 'p50')  int? p50, @JsonKey(name: 'p95')  int? p95,  int? min,  int? max)  $default,) {final _that = this;
switch (_that) {
case _AiQualityLatency():
return $default(_that.samples,_that.sampled,_that.sampleLimit,_that.p50,_that.p95,_that.min,_that.max);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int samples,  bool sampled, @JsonKey(name: 'sample_limit')  int sampleLimit, @JsonKey(name: 'p50')  int? p50, @JsonKey(name: 'p95')  int? p95,  int? min,  int? max)?  $default,) {final _that = this;
switch (_that) {
case _AiQualityLatency() when $default != null:
return $default(_that.samples,_that.sampled,_that.sampleLimit,_that.p50,_that.p95,_that.min,_that.max);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiQualityLatency implements AiQualityLatency {
  const _AiQualityLatency({this.samples = 0, this.sampled = false, @JsonKey(name: 'sample_limit') this.sampleLimit = 0, @JsonKey(name: 'p50') this.p50, @JsonKey(name: 'p95') this.p95, this.min, this.max});
  factory _AiQualityLatency.fromJson(Map<String, dynamic> json) => _$AiQualityLatencyFromJson(json);

@override@JsonKey() final  int samples;
@override@JsonKey() final  bool sampled;
@override@JsonKey(name: 'sample_limit') final  int sampleLimit;
@override@JsonKey(name: 'p50') final  int? p50;
@override@JsonKey(name: 'p95') final  int? p95;
@override final  int? min;
@override final  int? max;

/// Create a copy of AiQualityLatency
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiQualityLatencyCopyWith<_AiQualityLatency> get copyWith => __$AiQualityLatencyCopyWithImpl<_AiQualityLatency>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiQualityLatencyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiQualityLatency&&(identical(other.samples, samples) || other.samples == samples)&&(identical(other.sampled, sampled) || other.sampled == sampled)&&(identical(other.sampleLimit, sampleLimit) || other.sampleLimit == sampleLimit)&&(identical(other.p50, p50) || other.p50 == p50)&&(identical(other.p95, p95) || other.p95 == p95)&&(identical(other.min, min) || other.min == min)&&(identical(other.max, max) || other.max == max));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,samples,sampled,sampleLimit,p50,p95,min,max);

@override
String toString() {
  return 'AiQualityLatency(samples: $samples, sampled: $sampled, sampleLimit: $sampleLimit, p50: $p50, p95: $p95, min: $min, max: $max)';
}


}

/// @nodoc
abstract mixin class _$AiQualityLatencyCopyWith<$Res> implements $AiQualityLatencyCopyWith<$Res> {
  factory _$AiQualityLatencyCopyWith(_AiQualityLatency value, $Res Function(_AiQualityLatency) _then) = __$AiQualityLatencyCopyWithImpl;
@override @useResult
$Res call({
 int samples, bool sampled,@JsonKey(name: 'sample_limit') int sampleLimit,@JsonKey(name: 'p50') int? p50,@JsonKey(name: 'p95') int? p95, int? min, int? max
});




}
/// @nodoc
class __$AiQualityLatencyCopyWithImpl<$Res>
    implements _$AiQualityLatencyCopyWith<$Res> {
  __$AiQualityLatencyCopyWithImpl(this._self, this._then);

  final _AiQualityLatency _self;
  final $Res Function(_AiQualityLatency) _then;

/// Create a copy of AiQualityLatency
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? samples = null,Object? sampled = null,Object? sampleLimit = null,Object? p50 = freezed,Object? p95 = freezed,Object? min = freezed,Object? max = freezed,}) {
  return _then(_AiQualityLatency(
samples: null == samples ? _self.samples : samples // ignore: cast_nullable_to_non_nullable
as int,sampled: null == sampled ? _self.sampled : sampled // ignore: cast_nullable_to_non_nullable
as bool,sampleLimit: null == sampleLimit ? _self.sampleLimit : sampleLimit // ignore: cast_nullable_to_non_nullable
as int,p50: freezed == p50 ? _self.p50 : p50 // ignore: cast_nullable_to_non_nullable
as int?,p95: freezed == p95 ? _self.p95 : p95 // ignore: cast_nullable_to_non_nullable
as int?,min: freezed == min ? _self.min : min // ignore: cast_nullable_to_non_nullable
as int?,max: freezed == max ? _self.max : max // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$AiConfidenceBucket {

 String get bucket;@JsonKey(name: 'low', fromJson: _optNumOrZero) num get low;@JsonKey(name: 'high', fromJson: _optNumOrZero) num get high; int get count;
/// Create a copy of AiConfidenceBucket
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiConfidenceBucketCopyWith<AiConfidenceBucket> get copyWith => _$AiConfidenceBucketCopyWithImpl<AiConfidenceBucket>(this as AiConfidenceBucket, _$identity);

  /// Serializes this AiConfidenceBucket to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiConfidenceBucket&&(identical(other.bucket, bucket) || other.bucket == bucket)&&(identical(other.low, low) || other.low == low)&&(identical(other.high, high) || other.high == high)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bucket,low,high,count);

@override
String toString() {
  return 'AiConfidenceBucket(bucket: $bucket, low: $low, high: $high, count: $count)';
}


}

/// @nodoc
abstract mixin class $AiConfidenceBucketCopyWith<$Res>  {
  factory $AiConfidenceBucketCopyWith(AiConfidenceBucket value, $Res Function(AiConfidenceBucket) _then) = _$AiConfidenceBucketCopyWithImpl;
@useResult
$Res call({
 String bucket,@JsonKey(name: 'low', fromJson: _optNumOrZero) num low,@JsonKey(name: 'high', fromJson: _optNumOrZero) num high, int count
});




}
/// @nodoc
class _$AiConfidenceBucketCopyWithImpl<$Res>
    implements $AiConfidenceBucketCopyWith<$Res> {
  _$AiConfidenceBucketCopyWithImpl(this._self, this._then);

  final AiConfidenceBucket _self;
  final $Res Function(AiConfidenceBucket) _then;

/// Create a copy of AiConfidenceBucket
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bucket = null,Object? low = null,Object? high = null,Object? count = null,}) {
  return _then(_self.copyWith(
bucket: null == bucket ? _self.bucket : bucket // ignore: cast_nullable_to_non_nullable
as String,low: null == low ? _self.low : low // ignore: cast_nullable_to_non_nullable
as num,high: null == high ? _self.high : high // ignore: cast_nullable_to_non_nullable
as num,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AiConfidenceBucket].
extension AiConfidenceBucketPatterns on AiConfidenceBucket {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiConfidenceBucket value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiConfidenceBucket() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiConfidenceBucket value)  $default,){
final _that = this;
switch (_that) {
case _AiConfidenceBucket():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiConfidenceBucket value)?  $default,){
final _that = this;
switch (_that) {
case _AiConfidenceBucket() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String bucket, @JsonKey(name: 'low', fromJson: _optNumOrZero)  num low, @JsonKey(name: 'high', fromJson: _optNumOrZero)  num high,  int count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiConfidenceBucket() when $default != null:
return $default(_that.bucket,_that.low,_that.high,_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String bucket, @JsonKey(name: 'low', fromJson: _optNumOrZero)  num low, @JsonKey(name: 'high', fromJson: _optNumOrZero)  num high,  int count)  $default,) {final _that = this;
switch (_that) {
case _AiConfidenceBucket():
return $default(_that.bucket,_that.low,_that.high,_that.count);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String bucket, @JsonKey(name: 'low', fromJson: _optNumOrZero)  num low, @JsonKey(name: 'high', fromJson: _optNumOrZero)  num high,  int count)?  $default,) {final _that = this;
switch (_that) {
case _AiConfidenceBucket() when $default != null:
return $default(_that.bucket,_that.low,_that.high,_that.count);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiConfidenceBucket implements AiConfidenceBucket {
  const _AiConfidenceBucket({this.bucket = '', @JsonKey(name: 'low', fromJson: _optNumOrZero) this.low = 0, @JsonKey(name: 'high', fromJson: _optNumOrZero) this.high = 0, this.count = 0});
  factory _AiConfidenceBucket.fromJson(Map<String, dynamic> json) => _$AiConfidenceBucketFromJson(json);

@override@JsonKey() final  String bucket;
@override@JsonKey(name: 'low', fromJson: _optNumOrZero) final  num low;
@override@JsonKey(name: 'high', fromJson: _optNumOrZero) final  num high;
@override@JsonKey() final  int count;

/// Create a copy of AiConfidenceBucket
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiConfidenceBucketCopyWith<_AiConfidenceBucket> get copyWith => __$AiConfidenceBucketCopyWithImpl<_AiConfidenceBucket>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiConfidenceBucketToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiConfidenceBucket&&(identical(other.bucket, bucket) || other.bucket == bucket)&&(identical(other.low, low) || other.low == low)&&(identical(other.high, high) || other.high == high)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bucket,low,high,count);

@override
String toString() {
  return 'AiConfidenceBucket(bucket: $bucket, low: $low, high: $high, count: $count)';
}


}

/// @nodoc
abstract mixin class _$AiConfidenceBucketCopyWith<$Res> implements $AiConfidenceBucketCopyWith<$Res> {
  factory _$AiConfidenceBucketCopyWith(_AiConfidenceBucket value, $Res Function(_AiConfidenceBucket) _then) = __$AiConfidenceBucketCopyWithImpl;
@override @useResult
$Res call({
 String bucket,@JsonKey(name: 'low', fromJson: _optNumOrZero) num low,@JsonKey(name: 'high', fromJson: _optNumOrZero) num high, int count
});




}
/// @nodoc
class __$AiConfidenceBucketCopyWithImpl<$Res>
    implements _$AiConfidenceBucketCopyWith<$Res> {
  __$AiConfidenceBucketCopyWithImpl(this._self, this._then);

  final _AiConfidenceBucket _self;
  final $Res Function(_AiConfidenceBucket) _then;

/// Create a copy of AiConfidenceBucket
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bucket = null,Object? low = null,Object? high = null,Object? count = null,}) {
  return _then(_AiConfidenceBucket(
bucket: null == bucket ? _self.bucket : bucket // ignore: cast_nullable_to_non_nullable
as String,low: null == low ? _self.low : low // ignore: cast_nullable_to_non_nullable
as num,high: null == high ? _self.high : high // ignore: cast_nullable_to_non_nullable
as num,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$AiConfidenceDistribution {

 AnalyticsWindow get window;@JsonKey(name: 'with_confidence') int get withConfidence; List<Map<String, dynamic>> get buckets;
/// Create a copy of AiConfidenceDistribution
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiConfidenceDistributionCopyWith<AiConfidenceDistribution> get copyWith => _$AiConfidenceDistributionCopyWithImpl<AiConfidenceDistribution>(this as AiConfidenceDistribution, _$identity);

  /// Serializes this AiConfidenceDistribution to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiConfidenceDistribution&&(identical(other.window, window) || other.window == window)&&(identical(other.withConfidence, withConfidence) || other.withConfidence == withConfidence)&&const DeepCollectionEquality().equals(other.buckets, buckets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,window,withConfidence,const DeepCollectionEquality().hash(buckets));

@override
String toString() {
  return 'AiConfidenceDistribution(window: $window, withConfidence: $withConfidence, buckets: $buckets)';
}


}

/// @nodoc
abstract mixin class $AiConfidenceDistributionCopyWith<$Res>  {
  factory $AiConfidenceDistributionCopyWith(AiConfidenceDistribution value, $Res Function(AiConfidenceDistribution) _then) = _$AiConfidenceDistributionCopyWithImpl;
@useResult
$Res call({
 AnalyticsWindow window,@JsonKey(name: 'with_confidence') int withConfidence, List<Map<String, dynamic>> buckets
});


$AnalyticsWindowCopyWith<$Res> get window;

}
/// @nodoc
class _$AiConfidenceDistributionCopyWithImpl<$Res>
    implements $AiConfidenceDistributionCopyWith<$Res> {
  _$AiConfidenceDistributionCopyWithImpl(this._self, this._then);

  final AiConfidenceDistribution _self;
  final $Res Function(AiConfidenceDistribution) _then;

/// Create a copy of AiConfidenceDistribution
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? window = null,Object? withConfidence = null,Object? buckets = null,}) {
  return _then(_self.copyWith(
window: null == window ? _self.window : window // ignore: cast_nullable_to_non_nullable
as AnalyticsWindow,withConfidence: null == withConfidence ? _self.withConfidence : withConfidence // ignore: cast_nullable_to_non_nullable
as int,buckets: null == buckets ? _self.buckets : buckets // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,
  ));
}
/// Create a copy of AiConfidenceDistribution
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsWindowCopyWith<$Res> get window {
  
  return $AnalyticsWindowCopyWith<$Res>(_self.window, (value) {
    return _then(_self.copyWith(window: value));
  });
}
}


/// Adds pattern-matching-related methods to [AiConfidenceDistribution].
extension AiConfidenceDistributionPatterns on AiConfidenceDistribution {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiConfidenceDistribution value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiConfidenceDistribution() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiConfidenceDistribution value)  $default,){
final _that = this;
switch (_that) {
case _AiConfidenceDistribution():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiConfidenceDistribution value)?  $default,){
final _that = this;
switch (_that) {
case _AiConfidenceDistribution() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AnalyticsWindow window, @JsonKey(name: 'with_confidence')  int withConfidence,  List<Map<String, dynamic>> buckets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiConfidenceDistribution() when $default != null:
return $default(_that.window,_that.withConfidence,_that.buckets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AnalyticsWindow window, @JsonKey(name: 'with_confidence')  int withConfidence,  List<Map<String, dynamic>> buckets)  $default,) {final _that = this;
switch (_that) {
case _AiConfidenceDistribution():
return $default(_that.window,_that.withConfidence,_that.buckets);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AnalyticsWindow window, @JsonKey(name: 'with_confidence')  int withConfidence,  List<Map<String, dynamic>> buckets)?  $default,) {final _that = this;
switch (_that) {
case _AiConfidenceDistribution() when $default != null:
return $default(_that.window,_that.withConfidence,_that.buckets);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiConfidenceDistribution implements AiConfidenceDistribution {
  const _AiConfidenceDistribution({this.window = const AnalyticsWindow(), @JsonKey(name: 'with_confidence') this.withConfidence = 0, final  List<Map<String, dynamic>> buckets = const <Map<String, dynamic>>[]}): _buckets = buckets;
  factory _AiConfidenceDistribution.fromJson(Map<String, dynamic> json) => _$AiConfidenceDistributionFromJson(json);

@override@JsonKey() final  AnalyticsWindow window;
@override@JsonKey(name: 'with_confidence') final  int withConfidence;
 final  List<Map<String, dynamic>> _buckets;
@override@JsonKey() List<Map<String, dynamic>> get buckets {
  if (_buckets is EqualUnmodifiableListView) return _buckets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_buckets);
}


/// Create a copy of AiConfidenceDistribution
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiConfidenceDistributionCopyWith<_AiConfidenceDistribution> get copyWith => __$AiConfidenceDistributionCopyWithImpl<_AiConfidenceDistribution>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiConfidenceDistributionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiConfidenceDistribution&&(identical(other.window, window) || other.window == window)&&(identical(other.withConfidence, withConfidence) || other.withConfidence == withConfidence)&&const DeepCollectionEquality().equals(other._buckets, _buckets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,window,withConfidence,const DeepCollectionEquality().hash(_buckets));

@override
String toString() {
  return 'AiConfidenceDistribution(window: $window, withConfidence: $withConfidence, buckets: $buckets)';
}


}

/// @nodoc
abstract mixin class _$AiConfidenceDistributionCopyWith<$Res> implements $AiConfidenceDistributionCopyWith<$Res> {
  factory _$AiConfidenceDistributionCopyWith(_AiConfidenceDistribution value, $Res Function(_AiConfidenceDistribution) _then) = __$AiConfidenceDistributionCopyWithImpl;
@override @useResult
$Res call({
 AnalyticsWindow window,@JsonKey(name: 'with_confidence') int withConfidence, List<Map<String, dynamic>> buckets
});


@override $AnalyticsWindowCopyWith<$Res> get window;

}
/// @nodoc
class __$AiConfidenceDistributionCopyWithImpl<$Res>
    implements _$AiConfidenceDistributionCopyWith<$Res> {
  __$AiConfidenceDistributionCopyWithImpl(this._self, this._then);

  final _AiConfidenceDistribution _self;
  final $Res Function(_AiConfidenceDistribution) _then;

/// Create a copy of AiConfidenceDistribution
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? window = null,Object? withConfidence = null,Object? buckets = null,}) {
  return _then(_AiConfidenceDistribution(
window: null == window ? _self.window : window // ignore: cast_nullable_to_non_nullable
as AnalyticsWindow,withConfidence: null == withConfidence ? _self.withConfidence : withConfidence // ignore: cast_nullable_to_non_nullable
as int,buckets: null == buckets ? _self._buckets : buckets // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,
  ));
}

/// Create a copy of AiConfidenceDistribution
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsWindowCopyWith<$Res> get window {
  
  return $AnalyticsWindowCopyWith<$Res>(_self.window, (value) {
    return _then(_self.copyWith(window: value));
  });
}
}


/// @nodoc
mixin _$AiFallbackReason {

 String get reason; int get count;
/// Create a copy of AiFallbackReason
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiFallbackReasonCopyWith<AiFallbackReason> get copyWith => _$AiFallbackReasonCopyWithImpl<AiFallbackReason>(this as AiFallbackReason, _$identity);

  /// Serializes this AiFallbackReason to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiFallbackReason&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reason,count);

@override
String toString() {
  return 'AiFallbackReason(reason: $reason, count: $count)';
}


}

/// @nodoc
abstract mixin class $AiFallbackReasonCopyWith<$Res>  {
  factory $AiFallbackReasonCopyWith(AiFallbackReason value, $Res Function(AiFallbackReason) _then) = _$AiFallbackReasonCopyWithImpl;
@useResult
$Res call({
 String reason, int count
});




}
/// @nodoc
class _$AiFallbackReasonCopyWithImpl<$Res>
    implements $AiFallbackReasonCopyWith<$Res> {
  _$AiFallbackReasonCopyWithImpl(this._self, this._then);

  final AiFallbackReason _self;
  final $Res Function(AiFallbackReason) _then;

/// Create a copy of AiFallbackReason
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reason = null,Object? count = null,}) {
  return _then(_self.copyWith(
reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AiFallbackReason].
extension AiFallbackReasonPatterns on AiFallbackReason {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiFallbackReason value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiFallbackReason() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiFallbackReason value)  $default,){
final _that = this;
switch (_that) {
case _AiFallbackReason():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiFallbackReason value)?  $default,){
final _that = this;
switch (_that) {
case _AiFallbackReason() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String reason,  int count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiFallbackReason() when $default != null:
return $default(_that.reason,_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String reason,  int count)  $default,) {final _that = this;
switch (_that) {
case _AiFallbackReason():
return $default(_that.reason,_that.count);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String reason,  int count)?  $default,) {final _that = this;
switch (_that) {
case _AiFallbackReason() when $default != null:
return $default(_that.reason,_that.count);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiFallbackReason implements AiFallbackReason {
  const _AiFallbackReason({this.reason = '', this.count = 0});
  factory _AiFallbackReason.fromJson(Map<String, dynamic> json) => _$AiFallbackReasonFromJson(json);

@override@JsonKey() final  String reason;
@override@JsonKey() final  int count;

/// Create a copy of AiFallbackReason
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiFallbackReasonCopyWith<_AiFallbackReason> get copyWith => __$AiFallbackReasonCopyWithImpl<_AiFallbackReason>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiFallbackReasonToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiFallbackReason&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reason,count);

@override
String toString() {
  return 'AiFallbackReason(reason: $reason, count: $count)';
}


}

/// @nodoc
abstract mixin class _$AiFallbackReasonCopyWith<$Res> implements $AiFallbackReasonCopyWith<$Res> {
  factory _$AiFallbackReasonCopyWith(_AiFallbackReason value, $Res Function(_AiFallbackReason) _then) = __$AiFallbackReasonCopyWithImpl;
@override @useResult
$Res call({
 String reason, int count
});




}
/// @nodoc
class __$AiFallbackReasonCopyWithImpl<$Res>
    implements _$AiFallbackReasonCopyWith<$Res> {
  __$AiFallbackReasonCopyWithImpl(this._self, this._then);

  final _AiFallbackReason _self;
  final $Res Function(_AiFallbackReason) _then;

/// Create a copy of AiFallbackReason
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reason = null,Object? count = null,}) {
  return _then(_AiFallbackReason(
reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$AiModelUsage {

 String get model; String get task;@JsonKey(name: 'model_version') String get modelVersion; int get calls; int get completed; int get failed;@JsonKey(name: 'success_rate') double? get successRate; int get fallbacks;@JsonKey(name: 'fallback_rate') double? get fallbackRate; int get corrections;@JsonKey(name: 'accuracy_proxy') double? get accuracyProxy;@JsonKey(name: 'mean_confidence') double? get meanConfidence;@JsonKey(name: 'cost_usd', fromJson: _optNumOrZero) num get costUsd;@JsonKey(name: 'cost_per_call_usd', fromJson: _optNumOrZero) num get costPerCallUsd;
/// Create a copy of AiModelUsage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiModelUsageCopyWith<AiModelUsage> get copyWith => _$AiModelUsageCopyWithImpl<AiModelUsage>(this as AiModelUsage, _$identity);

  /// Serializes this AiModelUsage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiModelUsage&&(identical(other.model, model) || other.model == model)&&(identical(other.task, task) || other.task == task)&&(identical(other.modelVersion, modelVersion) || other.modelVersion == modelVersion)&&(identical(other.calls, calls) || other.calls == calls)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.failed, failed) || other.failed == failed)&&(identical(other.successRate, successRate) || other.successRate == successRate)&&(identical(other.fallbacks, fallbacks) || other.fallbacks == fallbacks)&&(identical(other.fallbackRate, fallbackRate) || other.fallbackRate == fallbackRate)&&(identical(other.corrections, corrections) || other.corrections == corrections)&&(identical(other.accuracyProxy, accuracyProxy) || other.accuracyProxy == accuracyProxy)&&(identical(other.meanConfidence, meanConfidence) || other.meanConfidence == meanConfidence)&&(identical(other.costUsd, costUsd) || other.costUsd == costUsd)&&(identical(other.costPerCallUsd, costPerCallUsd) || other.costPerCallUsd == costPerCallUsd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,model,task,modelVersion,calls,completed,failed,successRate,fallbacks,fallbackRate,corrections,accuracyProxy,meanConfidence,costUsd,costPerCallUsd);

@override
String toString() {
  return 'AiModelUsage(model: $model, task: $task, modelVersion: $modelVersion, calls: $calls, completed: $completed, failed: $failed, successRate: $successRate, fallbacks: $fallbacks, fallbackRate: $fallbackRate, corrections: $corrections, accuracyProxy: $accuracyProxy, meanConfidence: $meanConfidence, costUsd: $costUsd, costPerCallUsd: $costPerCallUsd)';
}


}

/// @nodoc
abstract mixin class $AiModelUsageCopyWith<$Res>  {
  factory $AiModelUsageCopyWith(AiModelUsage value, $Res Function(AiModelUsage) _then) = _$AiModelUsageCopyWithImpl;
@useResult
$Res call({
 String model, String task,@JsonKey(name: 'model_version') String modelVersion, int calls, int completed, int failed,@JsonKey(name: 'success_rate') double? successRate, int fallbacks,@JsonKey(name: 'fallback_rate') double? fallbackRate, int corrections,@JsonKey(name: 'accuracy_proxy') double? accuracyProxy,@JsonKey(name: 'mean_confidence') double? meanConfidence,@JsonKey(name: 'cost_usd', fromJson: _optNumOrZero) num costUsd,@JsonKey(name: 'cost_per_call_usd', fromJson: _optNumOrZero) num costPerCallUsd
});




}
/// @nodoc
class _$AiModelUsageCopyWithImpl<$Res>
    implements $AiModelUsageCopyWith<$Res> {
  _$AiModelUsageCopyWithImpl(this._self, this._then);

  final AiModelUsage _self;
  final $Res Function(AiModelUsage) _then;

/// Create a copy of AiModelUsage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? model = null,Object? task = null,Object? modelVersion = null,Object? calls = null,Object? completed = null,Object? failed = null,Object? successRate = freezed,Object? fallbacks = null,Object? fallbackRate = freezed,Object? corrections = null,Object? accuracyProxy = freezed,Object? meanConfidence = freezed,Object? costUsd = null,Object? costPerCallUsd = null,}) {
  return _then(_self.copyWith(
model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,task: null == task ? _self.task : task // ignore: cast_nullable_to_non_nullable
as String,modelVersion: null == modelVersion ? _self.modelVersion : modelVersion // ignore: cast_nullable_to_non_nullable
as String,calls: null == calls ? _self.calls : calls // ignore: cast_nullable_to_non_nullable
as int,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as int,failed: null == failed ? _self.failed : failed // ignore: cast_nullable_to_non_nullable
as int,successRate: freezed == successRate ? _self.successRate : successRate // ignore: cast_nullable_to_non_nullable
as double?,fallbacks: null == fallbacks ? _self.fallbacks : fallbacks // ignore: cast_nullable_to_non_nullable
as int,fallbackRate: freezed == fallbackRate ? _self.fallbackRate : fallbackRate // ignore: cast_nullable_to_non_nullable
as double?,corrections: null == corrections ? _self.corrections : corrections // ignore: cast_nullable_to_non_nullable
as int,accuracyProxy: freezed == accuracyProxy ? _self.accuracyProxy : accuracyProxy // ignore: cast_nullable_to_non_nullable
as double?,meanConfidence: freezed == meanConfidence ? _self.meanConfidence : meanConfidence // ignore: cast_nullable_to_non_nullable
as double?,costUsd: null == costUsd ? _self.costUsd : costUsd // ignore: cast_nullable_to_non_nullable
as num,costPerCallUsd: null == costPerCallUsd ? _self.costPerCallUsd : costPerCallUsd // ignore: cast_nullable_to_non_nullable
as num,
  ));
}

}


/// Adds pattern-matching-related methods to [AiModelUsage].
extension AiModelUsagePatterns on AiModelUsage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiModelUsage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiModelUsage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiModelUsage value)  $default,){
final _that = this;
switch (_that) {
case _AiModelUsage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiModelUsage value)?  $default,){
final _that = this;
switch (_that) {
case _AiModelUsage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String model,  String task, @JsonKey(name: 'model_version')  String modelVersion,  int calls,  int completed,  int failed, @JsonKey(name: 'success_rate')  double? successRate,  int fallbacks, @JsonKey(name: 'fallback_rate')  double? fallbackRate,  int corrections, @JsonKey(name: 'accuracy_proxy')  double? accuracyProxy, @JsonKey(name: 'mean_confidence')  double? meanConfidence, @JsonKey(name: 'cost_usd', fromJson: _optNumOrZero)  num costUsd, @JsonKey(name: 'cost_per_call_usd', fromJson: _optNumOrZero)  num costPerCallUsd)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiModelUsage() when $default != null:
return $default(_that.model,_that.task,_that.modelVersion,_that.calls,_that.completed,_that.failed,_that.successRate,_that.fallbacks,_that.fallbackRate,_that.corrections,_that.accuracyProxy,_that.meanConfidence,_that.costUsd,_that.costPerCallUsd);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String model,  String task, @JsonKey(name: 'model_version')  String modelVersion,  int calls,  int completed,  int failed, @JsonKey(name: 'success_rate')  double? successRate,  int fallbacks, @JsonKey(name: 'fallback_rate')  double? fallbackRate,  int corrections, @JsonKey(name: 'accuracy_proxy')  double? accuracyProxy, @JsonKey(name: 'mean_confidence')  double? meanConfidence, @JsonKey(name: 'cost_usd', fromJson: _optNumOrZero)  num costUsd, @JsonKey(name: 'cost_per_call_usd', fromJson: _optNumOrZero)  num costPerCallUsd)  $default,) {final _that = this;
switch (_that) {
case _AiModelUsage():
return $default(_that.model,_that.task,_that.modelVersion,_that.calls,_that.completed,_that.failed,_that.successRate,_that.fallbacks,_that.fallbackRate,_that.corrections,_that.accuracyProxy,_that.meanConfidence,_that.costUsd,_that.costPerCallUsd);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String model,  String task, @JsonKey(name: 'model_version')  String modelVersion,  int calls,  int completed,  int failed, @JsonKey(name: 'success_rate')  double? successRate,  int fallbacks, @JsonKey(name: 'fallback_rate')  double? fallbackRate,  int corrections, @JsonKey(name: 'accuracy_proxy')  double? accuracyProxy, @JsonKey(name: 'mean_confidence')  double? meanConfidence, @JsonKey(name: 'cost_usd', fromJson: _optNumOrZero)  num costUsd, @JsonKey(name: 'cost_per_call_usd', fromJson: _optNumOrZero)  num costPerCallUsd)?  $default,) {final _that = this;
switch (_that) {
case _AiModelUsage() when $default != null:
return $default(_that.model,_that.task,_that.modelVersion,_that.calls,_that.completed,_that.failed,_that.successRate,_that.fallbacks,_that.fallbackRate,_that.corrections,_that.accuracyProxy,_that.meanConfidence,_that.costUsd,_that.costPerCallUsd);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiModelUsage implements AiModelUsage {
  const _AiModelUsage({this.model = '', this.task = '', @JsonKey(name: 'model_version') this.modelVersion = '', this.calls = 0, this.completed = 0, this.failed = 0, @JsonKey(name: 'success_rate') this.successRate, this.fallbacks = 0, @JsonKey(name: 'fallback_rate') this.fallbackRate, this.corrections = 0, @JsonKey(name: 'accuracy_proxy') this.accuracyProxy, @JsonKey(name: 'mean_confidence') this.meanConfidence, @JsonKey(name: 'cost_usd', fromJson: _optNumOrZero) this.costUsd = 0, @JsonKey(name: 'cost_per_call_usd', fromJson: _optNumOrZero) this.costPerCallUsd = 0});
  factory _AiModelUsage.fromJson(Map<String, dynamic> json) => _$AiModelUsageFromJson(json);

@override@JsonKey() final  String model;
@override@JsonKey() final  String task;
@override@JsonKey(name: 'model_version') final  String modelVersion;
@override@JsonKey() final  int calls;
@override@JsonKey() final  int completed;
@override@JsonKey() final  int failed;
@override@JsonKey(name: 'success_rate') final  double? successRate;
@override@JsonKey() final  int fallbacks;
@override@JsonKey(name: 'fallback_rate') final  double? fallbackRate;
@override@JsonKey() final  int corrections;
@override@JsonKey(name: 'accuracy_proxy') final  double? accuracyProxy;
@override@JsonKey(name: 'mean_confidence') final  double? meanConfidence;
@override@JsonKey(name: 'cost_usd', fromJson: _optNumOrZero) final  num costUsd;
@override@JsonKey(name: 'cost_per_call_usd', fromJson: _optNumOrZero) final  num costPerCallUsd;

/// Create a copy of AiModelUsage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiModelUsageCopyWith<_AiModelUsage> get copyWith => __$AiModelUsageCopyWithImpl<_AiModelUsage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiModelUsageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiModelUsage&&(identical(other.model, model) || other.model == model)&&(identical(other.task, task) || other.task == task)&&(identical(other.modelVersion, modelVersion) || other.modelVersion == modelVersion)&&(identical(other.calls, calls) || other.calls == calls)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.failed, failed) || other.failed == failed)&&(identical(other.successRate, successRate) || other.successRate == successRate)&&(identical(other.fallbacks, fallbacks) || other.fallbacks == fallbacks)&&(identical(other.fallbackRate, fallbackRate) || other.fallbackRate == fallbackRate)&&(identical(other.corrections, corrections) || other.corrections == corrections)&&(identical(other.accuracyProxy, accuracyProxy) || other.accuracyProxy == accuracyProxy)&&(identical(other.meanConfidence, meanConfidence) || other.meanConfidence == meanConfidence)&&(identical(other.costUsd, costUsd) || other.costUsd == costUsd)&&(identical(other.costPerCallUsd, costPerCallUsd) || other.costPerCallUsd == costPerCallUsd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,model,task,modelVersion,calls,completed,failed,successRate,fallbacks,fallbackRate,corrections,accuracyProxy,meanConfidence,costUsd,costPerCallUsd);

@override
String toString() {
  return 'AiModelUsage(model: $model, task: $task, modelVersion: $modelVersion, calls: $calls, completed: $completed, failed: $failed, successRate: $successRate, fallbacks: $fallbacks, fallbackRate: $fallbackRate, corrections: $corrections, accuracyProxy: $accuracyProxy, meanConfidence: $meanConfidence, costUsd: $costUsd, costPerCallUsd: $costPerCallUsd)';
}


}

/// @nodoc
abstract mixin class _$AiModelUsageCopyWith<$Res> implements $AiModelUsageCopyWith<$Res> {
  factory _$AiModelUsageCopyWith(_AiModelUsage value, $Res Function(_AiModelUsage) _then) = __$AiModelUsageCopyWithImpl;
@override @useResult
$Res call({
 String model, String task,@JsonKey(name: 'model_version') String modelVersion, int calls, int completed, int failed,@JsonKey(name: 'success_rate') double? successRate, int fallbacks,@JsonKey(name: 'fallback_rate') double? fallbackRate, int corrections,@JsonKey(name: 'accuracy_proxy') double? accuracyProxy,@JsonKey(name: 'mean_confidence') double? meanConfidence,@JsonKey(name: 'cost_usd', fromJson: _optNumOrZero) num costUsd,@JsonKey(name: 'cost_per_call_usd', fromJson: _optNumOrZero) num costPerCallUsd
});




}
/// @nodoc
class __$AiModelUsageCopyWithImpl<$Res>
    implements _$AiModelUsageCopyWith<$Res> {
  __$AiModelUsageCopyWithImpl(this._self, this._then);

  final _AiModelUsage _self;
  final $Res Function(_AiModelUsage) _then;

/// Create a copy of AiModelUsage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? model = null,Object? task = null,Object? modelVersion = null,Object? calls = null,Object? completed = null,Object? failed = null,Object? successRate = freezed,Object? fallbacks = null,Object? fallbackRate = freezed,Object? corrections = null,Object? accuracyProxy = freezed,Object? meanConfidence = freezed,Object? costUsd = null,Object? costPerCallUsd = null,}) {
  return _then(_AiModelUsage(
model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,task: null == task ? _self.task : task // ignore: cast_nullable_to_non_nullable
as String,modelVersion: null == modelVersion ? _self.modelVersion : modelVersion // ignore: cast_nullable_to_non_nullable
as String,calls: null == calls ? _self.calls : calls // ignore: cast_nullable_to_non_nullable
as int,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as int,failed: null == failed ? _self.failed : failed // ignore: cast_nullable_to_non_nullable
as int,successRate: freezed == successRate ? _self.successRate : successRate // ignore: cast_nullable_to_non_nullable
as double?,fallbacks: null == fallbacks ? _self.fallbacks : fallbacks // ignore: cast_nullable_to_non_nullable
as int,fallbackRate: freezed == fallbackRate ? _self.fallbackRate : fallbackRate // ignore: cast_nullable_to_non_nullable
as double?,corrections: null == corrections ? _self.corrections : corrections // ignore: cast_nullable_to_non_nullable
as int,accuracyProxy: freezed == accuracyProxy ? _self.accuracyProxy : accuracyProxy // ignore: cast_nullable_to_non_nullable
as double?,meanConfidence: freezed == meanConfidence ? _self.meanConfidence : meanConfidence // ignore: cast_nullable_to_non_nullable
as double?,costUsd: null == costUsd ? _self.costUsd : costUsd // ignore: cast_nullable_to_non_nullable
as num,costPerCallUsd: null == costPerCallUsd ? _self.costPerCallUsd : costPerCallUsd // ignore: cast_nullable_to_non_nullable
as num,
  ));
}


}


/// @nodoc
mixin _$AiQualityReport {

 AnalyticsWindow get window; AiQualityTotals get totals;@JsonKey(name: 'latency_ms') AiQualityLatency get latency;@JsonKey(name: 'confidence_distribution') AiConfidenceDistribution get confidenceDistribution;@JsonKey(name: 'fallback_reasons', fromJson: _mapList) List<Map<String, dynamic>> get fallbackReasons;@JsonKey(name: 'models', fromJson: _mapList) List<Map<String, dynamic>> get models; List<String> get caveats; AnalyticsTable get table;
/// Create a copy of AiQualityReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiQualityReportCopyWith<AiQualityReport> get copyWith => _$AiQualityReportCopyWithImpl<AiQualityReport>(this as AiQualityReport, _$identity);

  /// Serializes this AiQualityReport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiQualityReport&&(identical(other.window, window) || other.window == window)&&(identical(other.totals, totals) || other.totals == totals)&&(identical(other.latency, latency) || other.latency == latency)&&(identical(other.confidenceDistribution, confidenceDistribution) || other.confidenceDistribution == confidenceDistribution)&&const DeepCollectionEquality().equals(other.fallbackReasons, fallbackReasons)&&const DeepCollectionEquality().equals(other.models, models)&&const DeepCollectionEquality().equals(other.caveats, caveats)&&(identical(other.table, table) || other.table == table));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,window,totals,latency,confidenceDistribution,const DeepCollectionEquality().hash(fallbackReasons),const DeepCollectionEquality().hash(models),const DeepCollectionEquality().hash(caveats),table);

@override
String toString() {
  return 'AiQualityReport(window: $window, totals: $totals, latency: $latency, confidenceDistribution: $confidenceDistribution, fallbackReasons: $fallbackReasons, models: $models, caveats: $caveats, table: $table)';
}


}

/// @nodoc
abstract mixin class $AiQualityReportCopyWith<$Res>  {
  factory $AiQualityReportCopyWith(AiQualityReport value, $Res Function(AiQualityReport) _then) = _$AiQualityReportCopyWithImpl;
@useResult
$Res call({
 AnalyticsWindow window, AiQualityTotals totals,@JsonKey(name: 'latency_ms') AiQualityLatency latency,@JsonKey(name: 'confidence_distribution') AiConfidenceDistribution confidenceDistribution,@JsonKey(name: 'fallback_reasons', fromJson: _mapList) List<Map<String, dynamic>> fallbackReasons,@JsonKey(name: 'models', fromJson: _mapList) List<Map<String, dynamic>> models, List<String> caveats, AnalyticsTable table
});


$AnalyticsWindowCopyWith<$Res> get window;$AiQualityTotalsCopyWith<$Res> get totals;$AiQualityLatencyCopyWith<$Res> get latency;$AiConfidenceDistributionCopyWith<$Res> get confidenceDistribution;$AnalyticsTableCopyWith<$Res> get table;

}
/// @nodoc
class _$AiQualityReportCopyWithImpl<$Res>
    implements $AiQualityReportCopyWith<$Res> {
  _$AiQualityReportCopyWithImpl(this._self, this._then);

  final AiQualityReport _self;
  final $Res Function(AiQualityReport) _then;

/// Create a copy of AiQualityReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? window = null,Object? totals = null,Object? latency = null,Object? confidenceDistribution = null,Object? fallbackReasons = null,Object? models = null,Object? caveats = null,Object? table = null,}) {
  return _then(_self.copyWith(
window: null == window ? _self.window : window // ignore: cast_nullable_to_non_nullable
as AnalyticsWindow,totals: null == totals ? _self.totals : totals // ignore: cast_nullable_to_non_nullable
as AiQualityTotals,latency: null == latency ? _self.latency : latency // ignore: cast_nullable_to_non_nullable
as AiQualityLatency,confidenceDistribution: null == confidenceDistribution ? _self.confidenceDistribution : confidenceDistribution // ignore: cast_nullable_to_non_nullable
as AiConfidenceDistribution,fallbackReasons: null == fallbackReasons ? _self.fallbackReasons : fallbackReasons // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,models: null == models ? _self.models : models // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,caveats: null == caveats ? _self.caveats : caveats // ignore: cast_nullable_to_non_nullable
as List<String>,table: null == table ? _self.table : table // ignore: cast_nullable_to_non_nullable
as AnalyticsTable,
  ));
}
/// Create a copy of AiQualityReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsWindowCopyWith<$Res> get window {
  
  return $AnalyticsWindowCopyWith<$Res>(_self.window, (value) {
    return _then(_self.copyWith(window: value));
  });
}/// Create a copy of AiQualityReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AiQualityTotalsCopyWith<$Res> get totals {
  
  return $AiQualityTotalsCopyWith<$Res>(_self.totals, (value) {
    return _then(_self.copyWith(totals: value));
  });
}/// Create a copy of AiQualityReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AiQualityLatencyCopyWith<$Res> get latency {
  
  return $AiQualityLatencyCopyWith<$Res>(_self.latency, (value) {
    return _then(_self.copyWith(latency: value));
  });
}/// Create a copy of AiQualityReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AiConfidenceDistributionCopyWith<$Res> get confidenceDistribution {
  
  return $AiConfidenceDistributionCopyWith<$Res>(_self.confidenceDistribution, (value) {
    return _then(_self.copyWith(confidenceDistribution: value));
  });
}/// Create a copy of AiQualityReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsTableCopyWith<$Res> get table {
  
  return $AnalyticsTableCopyWith<$Res>(_self.table, (value) {
    return _then(_self.copyWith(table: value));
  });
}
}


/// Adds pattern-matching-related methods to [AiQualityReport].
extension AiQualityReportPatterns on AiQualityReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiQualityReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiQualityReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiQualityReport value)  $default,){
final _that = this;
switch (_that) {
case _AiQualityReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiQualityReport value)?  $default,){
final _that = this;
switch (_that) {
case _AiQualityReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AnalyticsWindow window,  AiQualityTotals totals, @JsonKey(name: 'latency_ms')  AiQualityLatency latency, @JsonKey(name: 'confidence_distribution')  AiConfidenceDistribution confidenceDistribution, @JsonKey(name: 'fallback_reasons', fromJson: _mapList)  List<Map<String, dynamic>> fallbackReasons, @JsonKey(name: 'models', fromJson: _mapList)  List<Map<String, dynamic>> models,  List<String> caveats,  AnalyticsTable table)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiQualityReport() when $default != null:
return $default(_that.window,_that.totals,_that.latency,_that.confidenceDistribution,_that.fallbackReasons,_that.models,_that.caveats,_that.table);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AnalyticsWindow window,  AiQualityTotals totals, @JsonKey(name: 'latency_ms')  AiQualityLatency latency, @JsonKey(name: 'confidence_distribution')  AiConfidenceDistribution confidenceDistribution, @JsonKey(name: 'fallback_reasons', fromJson: _mapList)  List<Map<String, dynamic>> fallbackReasons, @JsonKey(name: 'models', fromJson: _mapList)  List<Map<String, dynamic>> models,  List<String> caveats,  AnalyticsTable table)  $default,) {final _that = this;
switch (_that) {
case _AiQualityReport():
return $default(_that.window,_that.totals,_that.latency,_that.confidenceDistribution,_that.fallbackReasons,_that.models,_that.caveats,_that.table);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AnalyticsWindow window,  AiQualityTotals totals, @JsonKey(name: 'latency_ms')  AiQualityLatency latency, @JsonKey(name: 'confidence_distribution')  AiConfidenceDistribution confidenceDistribution, @JsonKey(name: 'fallback_reasons', fromJson: _mapList)  List<Map<String, dynamic>> fallbackReasons, @JsonKey(name: 'models', fromJson: _mapList)  List<Map<String, dynamic>> models,  List<String> caveats,  AnalyticsTable table)?  $default,) {final _that = this;
switch (_that) {
case _AiQualityReport() when $default != null:
return $default(_that.window,_that.totals,_that.latency,_that.confidenceDistribution,_that.fallbackReasons,_that.models,_that.caveats,_that.table);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiQualityReport implements AiQualityReport {
  const _AiQualityReport({this.window = const AnalyticsWindow(), this.totals = const AiQualityTotals(), @JsonKey(name: 'latency_ms') this.latency = const AiQualityLatency(), @JsonKey(name: 'confidence_distribution') this.confidenceDistribution = const AiConfidenceDistribution(), @JsonKey(name: 'fallback_reasons', fromJson: _mapList) final  List<Map<String, dynamic>> fallbackReasons = const <Map<String, dynamic>>[], @JsonKey(name: 'models', fromJson: _mapList) final  List<Map<String, dynamic>> models = const <Map<String, dynamic>>[], final  List<String> caveats = const <String>[], this.table = const AnalyticsTable()}): _fallbackReasons = fallbackReasons,_models = models,_caveats = caveats;
  factory _AiQualityReport.fromJson(Map<String, dynamic> json) => _$AiQualityReportFromJson(json);

@override@JsonKey() final  AnalyticsWindow window;
@override@JsonKey() final  AiQualityTotals totals;
@override@JsonKey(name: 'latency_ms') final  AiQualityLatency latency;
@override@JsonKey(name: 'confidence_distribution') final  AiConfidenceDistribution confidenceDistribution;
 final  List<Map<String, dynamic>> _fallbackReasons;
@override@JsonKey(name: 'fallback_reasons', fromJson: _mapList) List<Map<String, dynamic>> get fallbackReasons {
  if (_fallbackReasons is EqualUnmodifiableListView) return _fallbackReasons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fallbackReasons);
}

 final  List<Map<String, dynamic>> _models;
@override@JsonKey(name: 'models', fromJson: _mapList) List<Map<String, dynamic>> get models {
  if (_models is EqualUnmodifiableListView) return _models;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_models);
}

 final  List<String> _caveats;
@override@JsonKey() List<String> get caveats {
  if (_caveats is EqualUnmodifiableListView) return _caveats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_caveats);
}

@override@JsonKey() final  AnalyticsTable table;

/// Create a copy of AiQualityReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiQualityReportCopyWith<_AiQualityReport> get copyWith => __$AiQualityReportCopyWithImpl<_AiQualityReport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiQualityReportToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiQualityReport&&(identical(other.window, window) || other.window == window)&&(identical(other.totals, totals) || other.totals == totals)&&(identical(other.latency, latency) || other.latency == latency)&&(identical(other.confidenceDistribution, confidenceDistribution) || other.confidenceDistribution == confidenceDistribution)&&const DeepCollectionEquality().equals(other._fallbackReasons, _fallbackReasons)&&const DeepCollectionEquality().equals(other._models, _models)&&const DeepCollectionEquality().equals(other._caveats, _caveats)&&(identical(other.table, table) || other.table == table));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,window,totals,latency,confidenceDistribution,const DeepCollectionEquality().hash(_fallbackReasons),const DeepCollectionEquality().hash(_models),const DeepCollectionEquality().hash(_caveats),table);

@override
String toString() {
  return 'AiQualityReport(window: $window, totals: $totals, latency: $latency, confidenceDistribution: $confidenceDistribution, fallbackReasons: $fallbackReasons, models: $models, caveats: $caveats, table: $table)';
}


}

/// @nodoc
abstract mixin class _$AiQualityReportCopyWith<$Res> implements $AiQualityReportCopyWith<$Res> {
  factory _$AiQualityReportCopyWith(_AiQualityReport value, $Res Function(_AiQualityReport) _then) = __$AiQualityReportCopyWithImpl;
@override @useResult
$Res call({
 AnalyticsWindow window, AiQualityTotals totals,@JsonKey(name: 'latency_ms') AiQualityLatency latency,@JsonKey(name: 'confidence_distribution') AiConfidenceDistribution confidenceDistribution,@JsonKey(name: 'fallback_reasons', fromJson: _mapList) List<Map<String, dynamic>> fallbackReasons,@JsonKey(name: 'models', fromJson: _mapList) List<Map<String, dynamic>> models, List<String> caveats, AnalyticsTable table
});


@override $AnalyticsWindowCopyWith<$Res> get window;@override $AiQualityTotalsCopyWith<$Res> get totals;@override $AiQualityLatencyCopyWith<$Res> get latency;@override $AiConfidenceDistributionCopyWith<$Res> get confidenceDistribution;@override $AnalyticsTableCopyWith<$Res> get table;

}
/// @nodoc
class __$AiQualityReportCopyWithImpl<$Res>
    implements _$AiQualityReportCopyWith<$Res> {
  __$AiQualityReportCopyWithImpl(this._self, this._then);

  final _AiQualityReport _self;
  final $Res Function(_AiQualityReport) _then;

/// Create a copy of AiQualityReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? window = null,Object? totals = null,Object? latency = null,Object? confidenceDistribution = null,Object? fallbackReasons = null,Object? models = null,Object? caveats = null,Object? table = null,}) {
  return _then(_AiQualityReport(
window: null == window ? _self.window : window // ignore: cast_nullable_to_non_nullable
as AnalyticsWindow,totals: null == totals ? _self.totals : totals // ignore: cast_nullable_to_non_nullable
as AiQualityTotals,latency: null == latency ? _self.latency : latency // ignore: cast_nullable_to_non_nullable
as AiQualityLatency,confidenceDistribution: null == confidenceDistribution ? _self.confidenceDistribution : confidenceDistribution // ignore: cast_nullable_to_non_nullable
as AiConfidenceDistribution,fallbackReasons: null == fallbackReasons ? _self._fallbackReasons : fallbackReasons // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,models: null == models ? _self._models : models // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,caveats: null == caveats ? _self._caveats : caveats // ignore: cast_nullable_to_non_nullable
as List<String>,table: null == table ? _self.table : table // ignore: cast_nullable_to_non_nullable
as AnalyticsTable,
  ));
}

/// Create a copy of AiQualityReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsWindowCopyWith<$Res> get window {
  
  return $AnalyticsWindowCopyWith<$Res>(_self.window, (value) {
    return _then(_self.copyWith(window: value));
  });
}/// Create a copy of AiQualityReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AiQualityTotalsCopyWith<$Res> get totals {
  
  return $AiQualityTotalsCopyWith<$Res>(_self.totals, (value) {
    return _then(_self.copyWith(totals: value));
  });
}/// Create a copy of AiQualityReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AiQualityLatencyCopyWith<$Res> get latency {
  
  return $AiQualityLatencyCopyWith<$Res>(_self.latency, (value) {
    return _then(_self.copyWith(latency: value));
  });
}/// Create a copy of AiQualityReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AiConfidenceDistributionCopyWith<$Res> get confidenceDistribution {
  
  return $AiConfidenceDistributionCopyWith<$Res>(_self.confidenceDistribution, (value) {
    return _then(_self.copyWith(confidenceDistribution: value));
  });
}/// Create a copy of AiQualityReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsTableCopyWith<$Res> get table {
  
  return $AnalyticsTableCopyWith<$Res>(_self.table, (value) {
    return _then(_self.copyWith(table: value));
  });
}
}


/// @nodoc
mixin _$PredictiveSignal {

 String get key; String get label; bool get observed; String get derivation; String get basis;/// Null is meaningful: the server leaves `recommendation.impressions.ai`
/// null on a database that cannot do JSON key lookups, and that is
/// different from zero.
@JsonKey(name: 'value', fromJson: _optNum) num? get value; String get note;
/// Create a copy of PredictiveSignal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PredictiveSignalCopyWith<PredictiveSignal> get copyWith => _$PredictiveSignalCopyWithImpl<PredictiveSignal>(this as PredictiveSignal, _$identity);

  /// Serializes this PredictiveSignal to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PredictiveSignal&&(identical(other.key, key) || other.key == key)&&(identical(other.label, label) || other.label == label)&&(identical(other.observed, observed) || other.observed == observed)&&(identical(other.derivation, derivation) || other.derivation == derivation)&&(identical(other.basis, basis) || other.basis == basis)&&(identical(other.value, value) || other.value == value)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,label,observed,derivation,basis,value,note);

@override
String toString() {
  return 'PredictiveSignal(key: $key, label: $label, observed: $observed, derivation: $derivation, basis: $basis, value: $value, note: $note)';
}


}

/// @nodoc
abstract mixin class $PredictiveSignalCopyWith<$Res>  {
  factory $PredictiveSignalCopyWith(PredictiveSignal value, $Res Function(PredictiveSignal) _then) = _$PredictiveSignalCopyWithImpl;
@useResult
$Res call({
 String key, String label, bool observed, String derivation, String basis,@JsonKey(name: 'value', fromJson: _optNum) num? value, String note
});




}
/// @nodoc
class _$PredictiveSignalCopyWithImpl<$Res>
    implements $PredictiveSignalCopyWith<$Res> {
  _$PredictiveSignalCopyWithImpl(this._self, this._then);

  final PredictiveSignal _self;
  final $Res Function(PredictiveSignal) _then;

/// Create a copy of PredictiveSignal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? label = null,Object? observed = null,Object? derivation = null,Object? basis = null,Object? value = freezed,Object? note = null,}) {
  return _then(_self.copyWith(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,observed: null == observed ? _self.observed : observed // ignore: cast_nullable_to_non_nullable
as bool,derivation: null == derivation ? _self.derivation : derivation // ignore: cast_nullable_to_non_nullable
as String,basis: null == basis ? _self.basis : basis // ignore: cast_nullable_to_non_nullable
as String,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as num?,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PredictiveSignal].
extension PredictiveSignalPatterns on PredictiveSignal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PredictiveSignal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PredictiveSignal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PredictiveSignal value)  $default,){
final _that = this;
switch (_that) {
case _PredictiveSignal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PredictiveSignal value)?  $default,){
final _that = this;
switch (_that) {
case _PredictiveSignal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String label,  bool observed,  String derivation,  String basis, @JsonKey(name: 'value', fromJson: _optNum)  num? value,  String note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PredictiveSignal() when $default != null:
return $default(_that.key,_that.label,_that.observed,_that.derivation,_that.basis,_that.value,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String label,  bool observed,  String derivation,  String basis, @JsonKey(name: 'value', fromJson: _optNum)  num? value,  String note)  $default,) {final _that = this;
switch (_that) {
case _PredictiveSignal():
return $default(_that.key,_that.label,_that.observed,_that.derivation,_that.basis,_that.value,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String label,  bool observed,  String derivation,  String basis, @JsonKey(name: 'value', fromJson: _optNum)  num? value,  String note)?  $default,) {final _that = this;
switch (_that) {
case _PredictiveSignal() when $default != null:
return $default(_that.key,_that.label,_that.observed,_that.derivation,_that.basis,_that.value,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PredictiveSignal implements PredictiveSignal {
  const _PredictiveSignal({this.key = '', this.label = '', this.observed = false, this.derivation = '', this.basis = '', @JsonKey(name: 'value', fromJson: _optNum) this.value, this.note = ''});
  factory _PredictiveSignal.fromJson(Map<String, dynamic> json) => _$PredictiveSignalFromJson(json);

@override@JsonKey() final  String key;
@override@JsonKey() final  String label;
@override@JsonKey() final  bool observed;
@override@JsonKey() final  String derivation;
@override@JsonKey() final  String basis;
/// Null is meaningful: the server leaves `recommendation.impressions.ai`
/// null on a database that cannot do JSON key lookups, and that is
/// different from zero.
@override@JsonKey(name: 'value', fromJson: _optNum) final  num? value;
@override@JsonKey() final  String note;

/// Create a copy of PredictiveSignal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PredictiveSignalCopyWith<_PredictiveSignal> get copyWith => __$PredictiveSignalCopyWithImpl<_PredictiveSignal>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PredictiveSignalToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PredictiveSignal&&(identical(other.key, key) || other.key == key)&&(identical(other.label, label) || other.label == label)&&(identical(other.observed, observed) || other.observed == observed)&&(identical(other.derivation, derivation) || other.derivation == derivation)&&(identical(other.basis, basis) || other.basis == basis)&&(identical(other.value, value) || other.value == value)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,label,observed,derivation,basis,value,note);

@override
String toString() {
  return 'PredictiveSignal(key: $key, label: $label, observed: $observed, derivation: $derivation, basis: $basis, value: $value, note: $note)';
}


}

/// @nodoc
abstract mixin class _$PredictiveSignalCopyWith<$Res> implements $PredictiveSignalCopyWith<$Res> {
  factory _$PredictiveSignalCopyWith(_PredictiveSignal value, $Res Function(_PredictiveSignal) _then) = __$PredictiveSignalCopyWithImpl;
@override @useResult
$Res call({
 String key, String label, bool observed, String derivation, String basis,@JsonKey(name: 'value', fromJson: _optNum) num? value, String note
});




}
/// @nodoc
class __$PredictiveSignalCopyWithImpl<$Res>
    implements _$PredictiveSignalCopyWith<$Res> {
  __$PredictiveSignalCopyWithImpl(this._self, this._then);

  final _PredictiveSignal _self;
  final $Res Function(_PredictiveSignal) _then;

/// Create a copy of PredictiveSignal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? label = null,Object? observed = null,Object? derivation = null,Object? basis = null,Object? value = freezed,Object? note = null,}) {
  return _then(_PredictiveSignal(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,observed: null == observed ? _self.observed : observed // ignore: cast_nullable_to_non_nullable
as bool,derivation: null == derivation ? _self.derivation : derivation // ignore: cast_nullable_to_non_nullable
as String,basis: null == basis ? _self.basis : basis // ignore: cast_nullable_to_non_nullable
as String,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as num?,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PredictiveFeedbackObserved {

 AnalyticsWindow get window; int get total; List<Map<String, dynamic>> get rows; int get negative; int get positive; String get source;
/// Create a copy of PredictiveFeedbackObserved
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PredictiveFeedbackObservedCopyWith<PredictiveFeedbackObserved> get copyWith => _$PredictiveFeedbackObservedCopyWithImpl<PredictiveFeedbackObserved>(this as PredictiveFeedbackObserved, _$identity);

  /// Serializes this PredictiveFeedbackObserved to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PredictiveFeedbackObserved&&(identical(other.window, window) || other.window == window)&&(identical(other.total, total) || other.total == total)&&const DeepCollectionEquality().equals(other.rows, rows)&&(identical(other.negative, negative) || other.negative == negative)&&(identical(other.positive, positive) || other.positive == positive)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,window,total,const DeepCollectionEquality().hash(rows),negative,positive,source);

@override
String toString() {
  return 'PredictiveFeedbackObserved(window: $window, total: $total, rows: $rows, negative: $negative, positive: $positive, source: $source)';
}


}

/// @nodoc
abstract mixin class $PredictiveFeedbackObservedCopyWith<$Res>  {
  factory $PredictiveFeedbackObservedCopyWith(PredictiveFeedbackObserved value, $Res Function(PredictiveFeedbackObserved) _then) = _$PredictiveFeedbackObservedCopyWithImpl;
@useResult
$Res call({
 AnalyticsWindow window, int total, List<Map<String, dynamic>> rows, int negative, int positive, String source
});


$AnalyticsWindowCopyWith<$Res> get window;

}
/// @nodoc
class _$PredictiveFeedbackObservedCopyWithImpl<$Res>
    implements $PredictiveFeedbackObservedCopyWith<$Res> {
  _$PredictiveFeedbackObservedCopyWithImpl(this._self, this._then);

  final PredictiveFeedbackObserved _self;
  final $Res Function(PredictiveFeedbackObserved) _then;

/// Create a copy of PredictiveFeedbackObserved
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? window = null,Object? total = null,Object? rows = null,Object? negative = null,Object? positive = null,Object? source = null,}) {
  return _then(_self.copyWith(
window: null == window ? _self.window : window // ignore: cast_nullable_to_non_nullable
as AnalyticsWindow,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,rows: null == rows ? _self.rows : rows // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,negative: null == negative ? _self.negative : negative // ignore: cast_nullable_to_non_nullable
as int,positive: null == positive ? _self.positive : positive // ignore: cast_nullable_to_non_nullable
as int,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of PredictiveFeedbackObserved
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsWindowCopyWith<$Res> get window {
  
  return $AnalyticsWindowCopyWith<$Res>(_self.window, (value) {
    return _then(_self.copyWith(window: value));
  });
}
}


/// Adds pattern-matching-related methods to [PredictiveFeedbackObserved].
extension PredictiveFeedbackObservedPatterns on PredictiveFeedbackObserved {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PredictiveFeedbackObserved value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PredictiveFeedbackObserved() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PredictiveFeedbackObserved value)  $default,){
final _that = this;
switch (_that) {
case _PredictiveFeedbackObserved():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PredictiveFeedbackObserved value)?  $default,){
final _that = this;
switch (_that) {
case _PredictiveFeedbackObserved() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AnalyticsWindow window,  int total,  List<Map<String, dynamic>> rows,  int negative,  int positive,  String source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PredictiveFeedbackObserved() when $default != null:
return $default(_that.window,_that.total,_that.rows,_that.negative,_that.positive,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AnalyticsWindow window,  int total,  List<Map<String, dynamic>> rows,  int negative,  int positive,  String source)  $default,) {final _that = this;
switch (_that) {
case _PredictiveFeedbackObserved():
return $default(_that.window,_that.total,_that.rows,_that.negative,_that.positive,_that.source);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AnalyticsWindow window,  int total,  List<Map<String, dynamic>> rows,  int negative,  int positive,  String source)?  $default,) {final _that = this;
switch (_that) {
case _PredictiveFeedbackObserved() when $default != null:
return $default(_that.window,_that.total,_that.rows,_that.negative,_that.positive,_that.source);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PredictiveFeedbackObserved implements PredictiveFeedbackObserved {
  const _PredictiveFeedbackObserved({this.window = const AnalyticsWindow(), this.total = 0, final  List<Map<String, dynamic>> rows = const <Map<String, dynamic>>[], this.negative = 0, this.positive = 0, this.source = ''}): _rows = rows;
  factory _PredictiveFeedbackObserved.fromJson(Map<String, dynamic> json) => _$PredictiveFeedbackObservedFromJson(json);

@override@JsonKey() final  AnalyticsWindow window;
@override@JsonKey() final  int total;
 final  List<Map<String, dynamic>> _rows;
@override@JsonKey() List<Map<String, dynamic>> get rows {
  if (_rows is EqualUnmodifiableListView) return _rows;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rows);
}

@override@JsonKey() final  int negative;
@override@JsonKey() final  int positive;
@override@JsonKey() final  String source;

/// Create a copy of PredictiveFeedbackObserved
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PredictiveFeedbackObservedCopyWith<_PredictiveFeedbackObserved> get copyWith => __$PredictiveFeedbackObservedCopyWithImpl<_PredictiveFeedbackObserved>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PredictiveFeedbackObservedToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PredictiveFeedbackObserved&&(identical(other.window, window) || other.window == window)&&(identical(other.total, total) || other.total == total)&&const DeepCollectionEquality().equals(other._rows, _rows)&&(identical(other.negative, negative) || other.negative == negative)&&(identical(other.positive, positive) || other.positive == positive)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,window,total,const DeepCollectionEquality().hash(_rows),negative,positive,source);

@override
String toString() {
  return 'PredictiveFeedbackObserved(window: $window, total: $total, rows: $rows, negative: $negative, positive: $positive, source: $source)';
}


}

/// @nodoc
abstract mixin class _$PredictiveFeedbackObservedCopyWith<$Res> implements $PredictiveFeedbackObservedCopyWith<$Res> {
  factory _$PredictiveFeedbackObservedCopyWith(_PredictiveFeedbackObserved value, $Res Function(_PredictiveFeedbackObserved) _then) = __$PredictiveFeedbackObservedCopyWithImpl;
@override @useResult
$Res call({
 AnalyticsWindow window, int total, List<Map<String, dynamic>> rows, int negative, int positive, String source
});


@override $AnalyticsWindowCopyWith<$Res> get window;

}
/// @nodoc
class __$PredictiveFeedbackObservedCopyWithImpl<$Res>
    implements _$PredictiveFeedbackObservedCopyWith<$Res> {
  __$PredictiveFeedbackObservedCopyWithImpl(this._self, this._then);

  final _PredictiveFeedbackObserved _self;
  final $Res Function(_PredictiveFeedbackObserved) _then;

/// Create a copy of PredictiveFeedbackObserved
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? window = null,Object? total = null,Object? rows = null,Object? negative = null,Object? positive = null,Object? source = null,}) {
  return _then(_PredictiveFeedbackObserved(
window: null == window ? _self.window : window // ignore: cast_nullable_to_non_nullable
as AnalyticsWindow,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,rows: null == rows ? _self._rows : rows // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,negative: null == negative ? _self.negative : negative // ignore: cast_nullable_to_non_nullable
as int,positive: null == positive ? _self.positive : positive // ignore: cast_nullable_to_non_nullable
as int,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of PredictiveFeedbackObserved
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsWindowCopyWith<$Res> get window {
  
  return $AnalyticsWindowCopyWith<$Res>(_self.window, (value) {
    return _then(_self.copyWith(window: value));
  });
}
}


/// @nodoc
mixin _$PredictiveImpressionsObserved {

 AnalyticsWindow get window; int get total; int? get ai; int? get fallback; int get unlabelled; String get source;
/// Create a copy of PredictiveImpressionsObserved
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PredictiveImpressionsObservedCopyWith<PredictiveImpressionsObserved> get copyWith => _$PredictiveImpressionsObservedCopyWithImpl<PredictiveImpressionsObserved>(this as PredictiveImpressionsObserved, _$identity);

  /// Serializes this PredictiveImpressionsObserved to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PredictiveImpressionsObserved&&(identical(other.window, window) || other.window == window)&&(identical(other.total, total) || other.total == total)&&(identical(other.ai, ai) || other.ai == ai)&&(identical(other.fallback, fallback) || other.fallback == fallback)&&(identical(other.unlabelled, unlabelled) || other.unlabelled == unlabelled)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,window,total,ai,fallback,unlabelled,source);

@override
String toString() {
  return 'PredictiveImpressionsObserved(window: $window, total: $total, ai: $ai, fallback: $fallback, unlabelled: $unlabelled, source: $source)';
}


}

/// @nodoc
abstract mixin class $PredictiveImpressionsObservedCopyWith<$Res>  {
  factory $PredictiveImpressionsObservedCopyWith(PredictiveImpressionsObserved value, $Res Function(PredictiveImpressionsObserved) _then) = _$PredictiveImpressionsObservedCopyWithImpl;
@useResult
$Res call({
 AnalyticsWindow window, int total, int? ai, int? fallback, int unlabelled, String source
});


$AnalyticsWindowCopyWith<$Res> get window;

}
/// @nodoc
class _$PredictiveImpressionsObservedCopyWithImpl<$Res>
    implements $PredictiveImpressionsObservedCopyWith<$Res> {
  _$PredictiveImpressionsObservedCopyWithImpl(this._self, this._then);

  final PredictiveImpressionsObserved _self;
  final $Res Function(PredictiveImpressionsObserved) _then;

/// Create a copy of PredictiveImpressionsObserved
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? window = null,Object? total = null,Object? ai = freezed,Object? fallback = freezed,Object? unlabelled = null,Object? source = null,}) {
  return _then(_self.copyWith(
window: null == window ? _self.window : window // ignore: cast_nullable_to_non_nullable
as AnalyticsWindow,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,ai: freezed == ai ? _self.ai : ai // ignore: cast_nullable_to_non_nullable
as int?,fallback: freezed == fallback ? _self.fallback : fallback // ignore: cast_nullable_to_non_nullable
as int?,unlabelled: null == unlabelled ? _self.unlabelled : unlabelled // ignore: cast_nullable_to_non_nullable
as int,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of PredictiveImpressionsObserved
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsWindowCopyWith<$Res> get window {
  
  return $AnalyticsWindowCopyWith<$Res>(_self.window, (value) {
    return _then(_self.copyWith(window: value));
  });
}
}


/// Adds pattern-matching-related methods to [PredictiveImpressionsObserved].
extension PredictiveImpressionsObservedPatterns on PredictiveImpressionsObserved {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PredictiveImpressionsObserved value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PredictiveImpressionsObserved() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PredictiveImpressionsObserved value)  $default,){
final _that = this;
switch (_that) {
case _PredictiveImpressionsObserved():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PredictiveImpressionsObserved value)?  $default,){
final _that = this;
switch (_that) {
case _PredictiveImpressionsObserved() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AnalyticsWindow window,  int total,  int? ai,  int? fallback,  int unlabelled,  String source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PredictiveImpressionsObserved() when $default != null:
return $default(_that.window,_that.total,_that.ai,_that.fallback,_that.unlabelled,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AnalyticsWindow window,  int total,  int? ai,  int? fallback,  int unlabelled,  String source)  $default,) {final _that = this;
switch (_that) {
case _PredictiveImpressionsObserved():
return $default(_that.window,_that.total,_that.ai,_that.fallback,_that.unlabelled,_that.source);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AnalyticsWindow window,  int total,  int? ai,  int? fallback,  int unlabelled,  String source)?  $default,) {final _that = this;
switch (_that) {
case _PredictiveImpressionsObserved() when $default != null:
return $default(_that.window,_that.total,_that.ai,_that.fallback,_that.unlabelled,_that.source);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PredictiveImpressionsObserved implements PredictiveImpressionsObserved {
  const _PredictiveImpressionsObserved({this.window = const AnalyticsWindow(), this.total = 0, this.ai, this.fallback, this.unlabelled = 0, this.source = ''});
  factory _PredictiveImpressionsObserved.fromJson(Map<String, dynamic> json) => _$PredictiveImpressionsObservedFromJson(json);

@override@JsonKey() final  AnalyticsWindow window;
@override@JsonKey() final  int total;
@override final  int? ai;
@override final  int? fallback;
@override@JsonKey() final  int unlabelled;
@override@JsonKey() final  String source;

/// Create a copy of PredictiveImpressionsObserved
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PredictiveImpressionsObservedCopyWith<_PredictiveImpressionsObserved> get copyWith => __$PredictiveImpressionsObservedCopyWithImpl<_PredictiveImpressionsObserved>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PredictiveImpressionsObservedToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PredictiveImpressionsObserved&&(identical(other.window, window) || other.window == window)&&(identical(other.total, total) || other.total == total)&&(identical(other.ai, ai) || other.ai == ai)&&(identical(other.fallback, fallback) || other.fallback == fallback)&&(identical(other.unlabelled, unlabelled) || other.unlabelled == unlabelled)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,window,total,ai,fallback,unlabelled,source);

@override
String toString() {
  return 'PredictiveImpressionsObserved(window: $window, total: $total, ai: $ai, fallback: $fallback, unlabelled: $unlabelled, source: $source)';
}


}

/// @nodoc
abstract mixin class _$PredictiveImpressionsObservedCopyWith<$Res> implements $PredictiveImpressionsObservedCopyWith<$Res> {
  factory _$PredictiveImpressionsObservedCopyWith(_PredictiveImpressionsObserved value, $Res Function(_PredictiveImpressionsObserved) _then) = __$PredictiveImpressionsObservedCopyWithImpl;
@override @useResult
$Res call({
 AnalyticsWindow window, int total, int? ai, int? fallback, int unlabelled, String source
});


@override $AnalyticsWindowCopyWith<$Res> get window;

}
/// @nodoc
class __$PredictiveImpressionsObservedCopyWithImpl<$Res>
    implements _$PredictiveImpressionsObservedCopyWith<$Res> {
  __$PredictiveImpressionsObservedCopyWithImpl(this._self, this._then);

  final _PredictiveImpressionsObserved _self;
  final $Res Function(_PredictiveImpressionsObserved) _then;

/// Create a copy of PredictiveImpressionsObserved
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? window = null,Object? total = null,Object? ai = freezed,Object? fallback = freezed,Object? unlabelled = null,Object? source = null,}) {
  return _then(_PredictiveImpressionsObserved(
window: null == window ? _self.window : window // ignore: cast_nullable_to_non_nullable
as AnalyticsWindow,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,ai: freezed == ai ? _self.ai : ai // ignore: cast_nullable_to_non_nullable
as int?,fallback: freezed == fallback ? _self.fallback : fallback // ignore: cast_nullable_to_non_nullable
as int?,unlabelled: null == unlabelled ? _self.unlabelled : unlabelled // ignore: cast_nullable_to_non_nullable
as int,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of PredictiveImpressionsObserved
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsWindowCopyWith<$Res> get window {
  
  return $AnalyticsWindowCopyWith<$Res>(_self.window, (value) {
    return _then(_self.copyWith(window: value));
  });
}
}


/// @nodoc
mixin _$PredictiveAiJobsObserved {

 AnalyticsWindow get window; int? get total; int? get corrected; int? get completed; String get source;
/// Create a copy of PredictiveAiJobsObserved
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PredictiveAiJobsObservedCopyWith<PredictiveAiJobsObserved> get copyWith => _$PredictiveAiJobsObservedCopyWithImpl<PredictiveAiJobsObserved>(this as PredictiveAiJobsObserved, _$identity);

  /// Serializes this PredictiveAiJobsObserved to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PredictiveAiJobsObserved&&(identical(other.window, window) || other.window == window)&&(identical(other.total, total) || other.total == total)&&(identical(other.corrected, corrected) || other.corrected == corrected)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,window,total,corrected,completed,source);

@override
String toString() {
  return 'PredictiveAiJobsObserved(window: $window, total: $total, corrected: $corrected, completed: $completed, source: $source)';
}


}

/// @nodoc
abstract mixin class $PredictiveAiJobsObservedCopyWith<$Res>  {
  factory $PredictiveAiJobsObservedCopyWith(PredictiveAiJobsObserved value, $Res Function(PredictiveAiJobsObserved) _then) = _$PredictiveAiJobsObservedCopyWithImpl;
@useResult
$Res call({
 AnalyticsWindow window, int? total, int? corrected, int? completed, String source
});


$AnalyticsWindowCopyWith<$Res> get window;

}
/// @nodoc
class _$PredictiveAiJobsObservedCopyWithImpl<$Res>
    implements $PredictiveAiJobsObservedCopyWith<$Res> {
  _$PredictiveAiJobsObservedCopyWithImpl(this._self, this._then);

  final PredictiveAiJobsObserved _self;
  final $Res Function(PredictiveAiJobsObserved) _then;

/// Create a copy of PredictiveAiJobsObserved
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? window = null,Object? total = freezed,Object? corrected = freezed,Object? completed = freezed,Object? source = null,}) {
  return _then(_self.copyWith(
window: null == window ? _self.window : window // ignore: cast_nullable_to_non_nullable
as AnalyticsWindow,total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int?,corrected: freezed == corrected ? _self.corrected : corrected // ignore: cast_nullable_to_non_nullable
as int?,completed: freezed == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as int?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of PredictiveAiJobsObserved
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsWindowCopyWith<$Res> get window {
  
  return $AnalyticsWindowCopyWith<$Res>(_self.window, (value) {
    return _then(_self.copyWith(window: value));
  });
}
}


/// Adds pattern-matching-related methods to [PredictiveAiJobsObserved].
extension PredictiveAiJobsObservedPatterns on PredictiveAiJobsObserved {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PredictiveAiJobsObserved value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PredictiveAiJobsObserved() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PredictiveAiJobsObserved value)  $default,){
final _that = this;
switch (_that) {
case _PredictiveAiJobsObserved():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PredictiveAiJobsObserved value)?  $default,){
final _that = this;
switch (_that) {
case _PredictiveAiJobsObserved() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AnalyticsWindow window,  int? total,  int? corrected,  int? completed,  String source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PredictiveAiJobsObserved() when $default != null:
return $default(_that.window,_that.total,_that.corrected,_that.completed,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AnalyticsWindow window,  int? total,  int? corrected,  int? completed,  String source)  $default,) {final _that = this;
switch (_that) {
case _PredictiveAiJobsObserved():
return $default(_that.window,_that.total,_that.corrected,_that.completed,_that.source);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AnalyticsWindow window,  int? total,  int? corrected,  int? completed,  String source)?  $default,) {final _that = this;
switch (_that) {
case _PredictiveAiJobsObserved() when $default != null:
return $default(_that.window,_that.total,_that.corrected,_that.completed,_that.source);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PredictiveAiJobsObserved implements PredictiveAiJobsObserved {
  const _PredictiveAiJobsObserved({this.window = const AnalyticsWindow(), this.total, this.corrected, this.completed, this.source = ''});
  factory _PredictiveAiJobsObserved.fromJson(Map<String, dynamic> json) => _$PredictiveAiJobsObservedFromJson(json);

@override@JsonKey() final  AnalyticsWindow window;
@override final  int? total;
@override final  int? corrected;
@override final  int? completed;
@override@JsonKey() final  String source;

/// Create a copy of PredictiveAiJobsObserved
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PredictiveAiJobsObservedCopyWith<_PredictiveAiJobsObserved> get copyWith => __$PredictiveAiJobsObservedCopyWithImpl<_PredictiveAiJobsObserved>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PredictiveAiJobsObservedToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PredictiveAiJobsObserved&&(identical(other.window, window) || other.window == window)&&(identical(other.total, total) || other.total == total)&&(identical(other.corrected, corrected) || other.corrected == corrected)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,window,total,corrected,completed,source);

@override
String toString() {
  return 'PredictiveAiJobsObserved(window: $window, total: $total, corrected: $corrected, completed: $completed, source: $source)';
}


}

/// @nodoc
abstract mixin class _$PredictiveAiJobsObservedCopyWith<$Res> implements $PredictiveAiJobsObservedCopyWith<$Res> {
  factory _$PredictiveAiJobsObservedCopyWith(_PredictiveAiJobsObserved value, $Res Function(_PredictiveAiJobsObserved) _then) = __$PredictiveAiJobsObservedCopyWithImpl;
@override @useResult
$Res call({
 AnalyticsWindow window, int? total, int? corrected, int? completed, String source
});


@override $AnalyticsWindowCopyWith<$Res> get window;

}
/// @nodoc
class __$PredictiveAiJobsObservedCopyWithImpl<$Res>
    implements _$PredictiveAiJobsObservedCopyWith<$Res> {
  __$PredictiveAiJobsObservedCopyWithImpl(this._self, this._then);

  final _PredictiveAiJobsObserved _self;
  final $Res Function(_PredictiveAiJobsObserved) _then;

/// Create a copy of PredictiveAiJobsObserved
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? window = null,Object? total = freezed,Object? corrected = freezed,Object? completed = freezed,Object? source = null,}) {
  return _then(_PredictiveAiJobsObserved(
window: null == window ? _self.window : window // ignore: cast_nullable_to_non_nullable
as AnalyticsWindow,total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int?,corrected: freezed == corrected ? _self.corrected : corrected // ignore: cast_nullable_to_non_nullable
as int?,completed: freezed == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as int?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of PredictiveAiJobsObserved
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsWindowCopyWith<$Res> get window {
  
  return $AnalyticsWindowCopyWith<$Res>(_self.window, (value) {
    return _then(_self.copyWith(window: value));
  });
}
}


/// @nodoc
mixin _$PredictiveObserved {

@JsonKey(name: 'recommendation_feedback') PredictiveFeedbackObserved get recommendationFeedback;@JsonKey(name: 'recommendation_impressions') PredictiveImpressionsObserved get recommendationImpressions;@JsonKey(name: 'ai_jobs') PredictiveAiJobsObserved get aiJobs;
/// Create a copy of PredictiveObserved
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PredictiveObservedCopyWith<PredictiveObserved> get copyWith => _$PredictiveObservedCopyWithImpl<PredictiveObserved>(this as PredictiveObserved, _$identity);

  /// Serializes this PredictiveObserved to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PredictiveObserved&&(identical(other.recommendationFeedback, recommendationFeedback) || other.recommendationFeedback == recommendationFeedback)&&(identical(other.recommendationImpressions, recommendationImpressions) || other.recommendationImpressions == recommendationImpressions)&&(identical(other.aiJobs, aiJobs) || other.aiJobs == aiJobs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recommendationFeedback,recommendationImpressions,aiJobs);

@override
String toString() {
  return 'PredictiveObserved(recommendationFeedback: $recommendationFeedback, recommendationImpressions: $recommendationImpressions, aiJobs: $aiJobs)';
}


}

/// @nodoc
abstract mixin class $PredictiveObservedCopyWith<$Res>  {
  factory $PredictiveObservedCopyWith(PredictiveObserved value, $Res Function(PredictiveObserved) _then) = _$PredictiveObservedCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'recommendation_feedback') PredictiveFeedbackObserved recommendationFeedback,@JsonKey(name: 'recommendation_impressions') PredictiveImpressionsObserved recommendationImpressions,@JsonKey(name: 'ai_jobs') PredictiveAiJobsObserved aiJobs
});


$PredictiveFeedbackObservedCopyWith<$Res> get recommendationFeedback;$PredictiveImpressionsObservedCopyWith<$Res> get recommendationImpressions;$PredictiveAiJobsObservedCopyWith<$Res> get aiJobs;

}
/// @nodoc
class _$PredictiveObservedCopyWithImpl<$Res>
    implements $PredictiveObservedCopyWith<$Res> {
  _$PredictiveObservedCopyWithImpl(this._self, this._then);

  final PredictiveObserved _self;
  final $Res Function(PredictiveObserved) _then;

/// Create a copy of PredictiveObserved
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? recommendationFeedback = null,Object? recommendationImpressions = null,Object? aiJobs = null,}) {
  return _then(_self.copyWith(
recommendationFeedback: null == recommendationFeedback ? _self.recommendationFeedback : recommendationFeedback // ignore: cast_nullable_to_non_nullable
as PredictiveFeedbackObserved,recommendationImpressions: null == recommendationImpressions ? _self.recommendationImpressions : recommendationImpressions // ignore: cast_nullable_to_non_nullable
as PredictiveImpressionsObserved,aiJobs: null == aiJobs ? _self.aiJobs : aiJobs // ignore: cast_nullable_to_non_nullable
as PredictiveAiJobsObserved,
  ));
}
/// Create a copy of PredictiveObserved
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PredictiveFeedbackObservedCopyWith<$Res> get recommendationFeedback {
  
  return $PredictiveFeedbackObservedCopyWith<$Res>(_self.recommendationFeedback, (value) {
    return _then(_self.copyWith(recommendationFeedback: value));
  });
}/// Create a copy of PredictiveObserved
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PredictiveImpressionsObservedCopyWith<$Res> get recommendationImpressions {
  
  return $PredictiveImpressionsObservedCopyWith<$Res>(_self.recommendationImpressions, (value) {
    return _then(_self.copyWith(recommendationImpressions: value));
  });
}/// Create a copy of PredictiveObserved
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PredictiveAiJobsObservedCopyWith<$Res> get aiJobs {
  
  return $PredictiveAiJobsObservedCopyWith<$Res>(_self.aiJobs, (value) {
    return _then(_self.copyWith(aiJobs: value));
  });
}
}


/// Adds pattern-matching-related methods to [PredictiveObserved].
extension PredictiveObservedPatterns on PredictiveObserved {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PredictiveObserved value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PredictiveObserved() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PredictiveObserved value)  $default,){
final _that = this;
switch (_that) {
case _PredictiveObserved():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PredictiveObserved value)?  $default,){
final _that = this;
switch (_that) {
case _PredictiveObserved() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'recommendation_feedback')  PredictiveFeedbackObserved recommendationFeedback, @JsonKey(name: 'recommendation_impressions')  PredictiveImpressionsObserved recommendationImpressions, @JsonKey(name: 'ai_jobs')  PredictiveAiJobsObserved aiJobs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PredictiveObserved() when $default != null:
return $default(_that.recommendationFeedback,_that.recommendationImpressions,_that.aiJobs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'recommendation_feedback')  PredictiveFeedbackObserved recommendationFeedback, @JsonKey(name: 'recommendation_impressions')  PredictiveImpressionsObserved recommendationImpressions, @JsonKey(name: 'ai_jobs')  PredictiveAiJobsObserved aiJobs)  $default,) {final _that = this;
switch (_that) {
case _PredictiveObserved():
return $default(_that.recommendationFeedback,_that.recommendationImpressions,_that.aiJobs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'recommendation_feedback')  PredictiveFeedbackObserved recommendationFeedback, @JsonKey(name: 'recommendation_impressions')  PredictiveImpressionsObserved recommendationImpressions, @JsonKey(name: 'ai_jobs')  PredictiveAiJobsObserved aiJobs)?  $default,) {final _that = this;
switch (_that) {
case _PredictiveObserved() when $default != null:
return $default(_that.recommendationFeedback,_that.recommendationImpressions,_that.aiJobs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PredictiveObserved implements PredictiveObserved {
  const _PredictiveObserved({@JsonKey(name: 'recommendation_feedback') this.recommendationFeedback = const PredictiveFeedbackObserved(), @JsonKey(name: 'recommendation_impressions') this.recommendationImpressions = const PredictiveImpressionsObserved(), @JsonKey(name: 'ai_jobs') this.aiJobs = const PredictiveAiJobsObserved()});
  factory _PredictiveObserved.fromJson(Map<String, dynamic> json) => _$PredictiveObservedFromJson(json);

@override@JsonKey(name: 'recommendation_feedback') final  PredictiveFeedbackObserved recommendationFeedback;
@override@JsonKey(name: 'recommendation_impressions') final  PredictiveImpressionsObserved recommendationImpressions;
@override@JsonKey(name: 'ai_jobs') final  PredictiveAiJobsObserved aiJobs;

/// Create a copy of PredictiveObserved
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PredictiveObservedCopyWith<_PredictiveObserved> get copyWith => __$PredictiveObservedCopyWithImpl<_PredictiveObserved>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PredictiveObservedToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PredictiveObserved&&(identical(other.recommendationFeedback, recommendationFeedback) || other.recommendationFeedback == recommendationFeedback)&&(identical(other.recommendationImpressions, recommendationImpressions) || other.recommendationImpressions == recommendationImpressions)&&(identical(other.aiJobs, aiJobs) || other.aiJobs == aiJobs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recommendationFeedback,recommendationImpressions,aiJobs);

@override
String toString() {
  return 'PredictiveObserved(recommendationFeedback: $recommendationFeedback, recommendationImpressions: $recommendationImpressions, aiJobs: $aiJobs)';
}


}

/// @nodoc
abstract mixin class _$PredictiveObservedCopyWith<$Res> implements $PredictiveObservedCopyWith<$Res> {
  factory _$PredictiveObservedCopyWith(_PredictiveObserved value, $Res Function(_PredictiveObserved) _then) = __$PredictiveObservedCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'recommendation_feedback') PredictiveFeedbackObserved recommendationFeedback,@JsonKey(name: 'recommendation_impressions') PredictiveImpressionsObserved recommendationImpressions,@JsonKey(name: 'ai_jobs') PredictiveAiJobsObserved aiJobs
});


@override $PredictiveFeedbackObservedCopyWith<$Res> get recommendationFeedback;@override $PredictiveImpressionsObservedCopyWith<$Res> get recommendationImpressions;@override $PredictiveAiJobsObservedCopyWith<$Res> get aiJobs;

}
/// @nodoc
class __$PredictiveObservedCopyWithImpl<$Res>
    implements _$PredictiveObservedCopyWith<$Res> {
  __$PredictiveObservedCopyWithImpl(this._self, this._then);

  final _PredictiveObserved _self;
  final $Res Function(_PredictiveObserved) _then;

/// Create a copy of PredictiveObserved
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? recommendationFeedback = null,Object? recommendationImpressions = null,Object? aiJobs = null,}) {
  return _then(_PredictiveObserved(
recommendationFeedback: null == recommendationFeedback ? _self.recommendationFeedback : recommendationFeedback // ignore: cast_nullable_to_non_nullable
as PredictiveFeedbackObserved,recommendationImpressions: null == recommendationImpressions ? _self.recommendationImpressions : recommendationImpressions // ignore: cast_nullable_to_non_nullable
as PredictiveImpressionsObserved,aiJobs: null == aiJobs ? _self.aiJobs : aiJobs // ignore: cast_nullable_to_non_nullable
as PredictiveAiJobsObserved,
  ));
}

/// Create a copy of PredictiveObserved
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PredictiveFeedbackObservedCopyWith<$Res> get recommendationFeedback {
  
  return $PredictiveFeedbackObservedCopyWith<$Res>(_self.recommendationFeedback, (value) {
    return _then(_self.copyWith(recommendationFeedback: value));
  });
}/// Create a copy of PredictiveObserved
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PredictiveImpressionsObservedCopyWith<$Res> get recommendationImpressions {
  
  return $PredictiveImpressionsObservedCopyWith<$Res>(_self.recommendationImpressions, (value) {
    return _then(_self.copyWith(recommendationImpressions: value));
  });
}/// Create a copy of PredictiveObserved
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PredictiveAiJobsObservedCopyWith<$Res> get aiJobs {
  
  return $PredictiveAiJobsObservedCopyWith<$Res>(_self.aiJobs, (value) {
    return _then(_self.copyWith(aiJobs: value));
  });
}
}


/// @nodoc
mixin _$PredictiveReport {

 AnalyticsWindow get window; String get disclaimer;@JsonKey(name: 'signals', fromJson: _mapList) List<Map<String, dynamic>> get signals; PredictiveObserved get observed; AnalyticsTable get table;
/// Create a copy of PredictiveReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PredictiveReportCopyWith<PredictiveReport> get copyWith => _$PredictiveReportCopyWithImpl<PredictiveReport>(this as PredictiveReport, _$identity);

  /// Serializes this PredictiveReport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PredictiveReport&&(identical(other.window, window) || other.window == window)&&(identical(other.disclaimer, disclaimer) || other.disclaimer == disclaimer)&&const DeepCollectionEquality().equals(other.signals, signals)&&(identical(other.observed, observed) || other.observed == observed)&&(identical(other.table, table) || other.table == table));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,window,disclaimer,const DeepCollectionEquality().hash(signals),observed,table);

@override
String toString() {
  return 'PredictiveReport(window: $window, disclaimer: $disclaimer, signals: $signals, observed: $observed, table: $table)';
}


}

/// @nodoc
abstract mixin class $PredictiveReportCopyWith<$Res>  {
  factory $PredictiveReportCopyWith(PredictiveReport value, $Res Function(PredictiveReport) _then) = _$PredictiveReportCopyWithImpl;
@useResult
$Res call({
 AnalyticsWindow window, String disclaimer,@JsonKey(name: 'signals', fromJson: _mapList) List<Map<String, dynamic>> signals, PredictiveObserved observed, AnalyticsTable table
});


$AnalyticsWindowCopyWith<$Res> get window;$PredictiveObservedCopyWith<$Res> get observed;$AnalyticsTableCopyWith<$Res> get table;

}
/// @nodoc
class _$PredictiveReportCopyWithImpl<$Res>
    implements $PredictiveReportCopyWith<$Res> {
  _$PredictiveReportCopyWithImpl(this._self, this._then);

  final PredictiveReport _self;
  final $Res Function(PredictiveReport) _then;

/// Create a copy of PredictiveReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? window = null,Object? disclaimer = null,Object? signals = null,Object? observed = null,Object? table = null,}) {
  return _then(_self.copyWith(
window: null == window ? _self.window : window // ignore: cast_nullable_to_non_nullable
as AnalyticsWindow,disclaimer: null == disclaimer ? _self.disclaimer : disclaimer // ignore: cast_nullable_to_non_nullable
as String,signals: null == signals ? _self.signals : signals // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,observed: null == observed ? _self.observed : observed // ignore: cast_nullable_to_non_nullable
as PredictiveObserved,table: null == table ? _self.table : table // ignore: cast_nullable_to_non_nullable
as AnalyticsTable,
  ));
}
/// Create a copy of PredictiveReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsWindowCopyWith<$Res> get window {
  
  return $AnalyticsWindowCopyWith<$Res>(_self.window, (value) {
    return _then(_self.copyWith(window: value));
  });
}/// Create a copy of PredictiveReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PredictiveObservedCopyWith<$Res> get observed {
  
  return $PredictiveObservedCopyWith<$Res>(_self.observed, (value) {
    return _then(_self.copyWith(observed: value));
  });
}/// Create a copy of PredictiveReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsTableCopyWith<$Res> get table {
  
  return $AnalyticsTableCopyWith<$Res>(_self.table, (value) {
    return _then(_self.copyWith(table: value));
  });
}
}


/// Adds pattern-matching-related methods to [PredictiveReport].
extension PredictiveReportPatterns on PredictiveReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PredictiveReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PredictiveReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PredictiveReport value)  $default,){
final _that = this;
switch (_that) {
case _PredictiveReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PredictiveReport value)?  $default,){
final _that = this;
switch (_that) {
case _PredictiveReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AnalyticsWindow window,  String disclaimer, @JsonKey(name: 'signals', fromJson: _mapList)  List<Map<String, dynamic>> signals,  PredictiveObserved observed,  AnalyticsTable table)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PredictiveReport() when $default != null:
return $default(_that.window,_that.disclaimer,_that.signals,_that.observed,_that.table);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AnalyticsWindow window,  String disclaimer, @JsonKey(name: 'signals', fromJson: _mapList)  List<Map<String, dynamic>> signals,  PredictiveObserved observed,  AnalyticsTable table)  $default,) {final _that = this;
switch (_that) {
case _PredictiveReport():
return $default(_that.window,_that.disclaimer,_that.signals,_that.observed,_that.table);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AnalyticsWindow window,  String disclaimer, @JsonKey(name: 'signals', fromJson: _mapList)  List<Map<String, dynamic>> signals,  PredictiveObserved observed,  AnalyticsTable table)?  $default,) {final _that = this;
switch (_that) {
case _PredictiveReport() when $default != null:
return $default(_that.window,_that.disclaimer,_that.signals,_that.observed,_that.table);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PredictiveReport implements PredictiveReport {
  const _PredictiveReport({this.window = const AnalyticsWindow(), this.disclaimer = '', @JsonKey(name: 'signals', fromJson: _mapList) final  List<Map<String, dynamic>> signals = const <Map<String, dynamic>>[], this.observed = const PredictiveObserved(), this.table = const AnalyticsTable()}): _signals = signals;
  factory _PredictiveReport.fromJson(Map<String, dynamic> json) => _$PredictiveReportFromJson(json);

@override@JsonKey() final  AnalyticsWindow window;
@override@JsonKey() final  String disclaimer;
 final  List<Map<String, dynamic>> _signals;
@override@JsonKey(name: 'signals', fromJson: _mapList) List<Map<String, dynamic>> get signals {
  if (_signals is EqualUnmodifiableListView) return _signals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_signals);
}

@override@JsonKey() final  PredictiveObserved observed;
@override@JsonKey() final  AnalyticsTable table;

/// Create a copy of PredictiveReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PredictiveReportCopyWith<_PredictiveReport> get copyWith => __$PredictiveReportCopyWithImpl<_PredictiveReport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PredictiveReportToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PredictiveReport&&(identical(other.window, window) || other.window == window)&&(identical(other.disclaimer, disclaimer) || other.disclaimer == disclaimer)&&const DeepCollectionEquality().equals(other._signals, _signals)&&(identical(other.observed, observed) || other.observed == observed)&&(identical(other.table, table) || other.table == table));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,window,disclaimer,const DeepCollectionEquality().hash(_signals),observed,table);

@override
String toString() {
  return 'PredictiveReport(window: $window, disclaimer: $disclaimer, signals: $signals, observed: $observed, table: $table)';
}


}

/// @nodoc
abstract mixin class _$PredictiveReportCopyWith<$Res> implements $PredictiveReportCopyWith<$Res> {
  factory _$PredictiveReportCopyWith(_PredictiveReport value, $Res Function(_PredictiveReport) _then) = __$PredictiveReportCopyWithImpl;
@override @useResult
$Res call({
 AnalyticsWindow window, String disclaimer,@JsonKey(name: 'signals', fromJson: _mapList) List<Map<String, dynamic>> signals, PredictiveObserved observed, AnalyticsTable table
});


@override $AnalyticsWindowCopyWith<$Res> get window;@override $PredictiveObservedCopyWith<$Res> get observed;@override $AnalyticsTableCopyWith<$Res> get table;

}
/// @nodoc
class __$PredictiveReportCopyWithImpl<$Res>
    implements _$PredictiveReportCopyWith<$Res> {
  __$PredictiveReportCopyWithImpl(this._self, this._then);

  final _PredictiveReport _self;
  final $Res Function(_PredictiveReport) _then;

/// Create a copy of PredictiveReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? window = null,Object? disclaimer = null,Object? signals = null,Object? observed = null,Object? table = null,}) {
  return _then(_PredictiveReport(
window: null == window ? _self.window : window // ignore: cast_nullable_to_non_nullable
as AnalyticsWindow,disclaimer: null == disclaimer ? _self.disclaimer : disclaimer // ignore: cast_nullable_to_non_nullable
as String,signals: null == signals ? _self._signals : signals // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,observed: null == observed ? _self.observed : observed // ignore: cast_nullable_to_non_nullable
as PredictiveObserved,table: null == table ? _self.table : table // ignore: cast_nullable_to_non_nullable
as AnalyticsTable,
  ));
}

/// Create a copy of PredictiveReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsWindowCopyWith<$Res> get window {
  
  return $AnalyticsWindowCopyWith<$Res>(_self.window, (value) {
    return _then(_self.copyWith(window: value));
  });
}/// Create a copy of PredictiveReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PredictiveObservedCopyWith<$Res> get observed {
  
  return $PredictiveObservedCopyWith<$Res>(_self.observed, (value) {
    return _then(_self.copyWith(observed: value));
  });
}/// Create a copy of PredictiveReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnalyticsTableCopyWith<$Res> get table {
  
  return $AnalyticsTableCopyWith<$Res>(_self.table, (value) {
    return _then(_self.copyWith(table: value));
  });
}
}

// dart format on
