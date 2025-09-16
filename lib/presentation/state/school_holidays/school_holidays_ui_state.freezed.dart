// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'school_holidays_ui_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SchoolHolidaysUiState {

 bool get isLoading; bool get isRefreshing; bool get isEnabled; String? get selectedStateCode; String? get error; Map<DateTime, List<SchoolHoliday>> get holidaysByDate; List<SchoolHoliday> get allHolidays; DateTime? get lastRefreshTime;
/// Create a copy of SchoolHolidaysUiState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SchoolHolidaysUiStateCopyWith<SchoolHolidaysUiState> get copyWith => _$SchoolHolidaysUiStateCopyWithImpl<SchoolHolidaysUiState>(this as SchoolHolidaysUiState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SchoolHolidaysUiState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isRefreshing, isRefreshing) || other.isRefreshing == isRefreshing)&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled)&&(identical(other.selectedStateCode, selectedStateCode) || other.selectedStateCode == selectedStateCode)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other.holidaysByDate, holidaysByDate)&&const DeepCollectionEquality().equals(other.allHolidays, allHolidays)&&(identical(other.lastRefreshTime, lastRefreshTime) || other.lastRefreshTime == lastRefreshTime));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,isRefreshing,isEnabled,selectedStateCode,error,const DeepCollectionEquality().hash(holidaysByDate),const DeepCollectionEquality().hash(allHolidays),lastRefreshTime);

@override
String toString() {
  return 'SchoolHolidaysUiState(isLoading: $isLoading, isRefreshing: $isRefreshing, isEnabled: $isEnabled, selectedStateCode: $selectedStateCode, error: $error, holidaysByDate: $holidaysByDate, allHolidays: $allHolidays, lastRefreshTime: $lastRefreshTime)';
}


}

/// @nodoc
abstract mixin class $SchoolHolidaysUiStateCopyWith<$Res>  {
  factory $SchoolHolidaysUiStateCopyWith(SchoolHolidaysUiState value, $Res Function(SchoolHolidaysUiState) _then) = _$SchoolHolidaysUiStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, bool isRefreshing, bool isEnabled, String? selectedStateCode, String? error, Map<DateTime, List<SchoolHoliday>> holidaysByDate, List<SchoolHoliday> allHolidays, DateTime? lastRefreshTime
});




}
/// @nodoc
class _$SchoolHolidaysUiStateCopyWithImpl<$Res>
    implements $SchoolHolidaysUiStateCopyWith<$Res> {
  _$SchoolHolidaysUiStateCopyWithImpl(this._self, this._then);

  final SchoolHolidaysUiState _self;
  final $Res Function(SchoolHolidaysUiState) _then;

/// Create a copy of SchoolHolidaysUiState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? isRefreshing = null,Object? isEnabled = null,Object? selectedStateCode = freezed,Object? error = freezed,Object? holidaysByDate = null,Object? allHolidays = null,Object? lastRefreshTime = freezed,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isRefreshing: null == isRefreshing ? _self.isRefreshing : isRefreshing // ignore: cast_nullable_to_non_nullable
as bool,isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,selectedStateCode: freezed == selectedStateCode ? _self.selectedStateCode : selectedStateCode // ignore: cast_nullable_to_non_nullable
as String?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,holidaysByDate: null == holidaysByDate ? _self.holidaysByDate : holidaysByDate // ignore: cast_nullable_to_non_nullable
as Map<DateTime, List<SchoolHoliday>>,allHolidays: null == allHolidays ? _self.allHolidays : allHolidays // ignore: cast_nullable_to_non_nullable
as List<SchoolHoliday>,lastRefreshTime: freezed == lastRefreshTime ? _self.lastRefreshTime : lastRefreshTime // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SchoolHolidaysUiState].
extension SchoolHolidaysUiStatePatterns on SchoolHolidaysUiState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SchoolHolidaysUiState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SchoolHolidaysUiState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SchoolHolidaysUiState value)  $default,){
final _that = this;
switch (_that) {
case _SchoolHolidaysUiState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SchoolHolidaysUiState value)?  $default,){
final _that = this;
switch (_that) {
case _SchoolHolidaysUiState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  bool isRefreshing,  bool isEnabled,  String? selectedStateCode,  String? error,  Map<DateTime, List<SchoolHoliday>> holidaysByDate,  List<SchoolHoliday> allHolidays,  DateTime? lastRefreshTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SchoolHolidaysUiState() when $default != null:
return $default(_that.isLoading,_that.isRefreshing,_that.isEnabled,_that.selectedStateCode,_that.error,_that.holidaysByDate,_that.allHolidays,_that.lastRefreshTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  bool isRefreshing,  bool isEnabled,  String? selectedStateCode,  String? error,  Map<DateTime, List<SchoolHoliday>> holidaysByDate,  List<SchoolHoliday> allHolidays,  DateTime? lastRefreshTime)  $default,) {final _that = this;
switch (_that) {
case _SchoolHolidaysUiState():
return $default(_that.isLoading,_that.isRefreshing,_that.isEnabled,_that.selectedStateCode,_that.error,_that.holidaysByDate,_that.allHolidays,_that.lastRefreshTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  bool isRefreshing,  bool isEnabled,  String? selectedStateCode,  String? error,  Map<DateTime, List<SchoolHoliday>> holidaysByDate,  List<SchoolHoliday> allHolidays,  DateTime? lastRefreshTime)?  $default,) {final _that = this;
switch (_that) {
case _SchoolHolidaysUiState() when $default != null:
return $default(_that.isLoading,_that.isRefreshing,_that.isEnabled,_that.selectedStateCode,_that.error,_that.holidaysByDate,_that.allHolidays,_that.lastRefreshTime);case _:
  return null;

}
}

}

/// @nodoc


class _SchoolHolidaysUiState extends SchoolHolidaysUiState {
  const _SchoolHolidaysUiState({required this.isLoading, required this.isRefreshing, required this.isEnabled, this.selectedStateCode, this.error, final  Map<DateTime, List<SchoolHoliday>> holidaysByDate = const {}, final  List<SchoolHoliday> allHolidays = const [], this.lastRefreshTime}): _holidaysByDate = holidaysByDate,_allHolidays = allHolidays,super._();
  

@override final  bool isLoading;
@override final  bool isRefreshing;
@override final  bool isEnabled;
@override final  String? selectedStateCode;
@override final  String? error;
 final  Map<DateTime, List<SchoolHoliday>> _holidaysByDate;
@override@JsonKey() Map<DateTime, List<SchoolHoliday>> get holidaysByDate {
  if (_holidaysByDate is EqualUnmodifiableMapView) return _holidaysByDate;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_holidaysByDate);
}

 final  List<SchoolHoliday> _allHolidays;
@override@JsonKey() List<SchoolHoliday> get allHolidays {
  if (_allHolidays is EqualUnmodifiableListView) return _allHolidays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allHolidays);
}

@override final  DateTime? lastRefreshTime;

/// Create a copy of SchoolHolidaysUiState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SchoolHolidaysUiStateCopyWith<_SchoolHolidaysUiState> get copyWith => __$SchoolHolidaysUiStateCopyWithImpl<_SchoolHolidaysUiState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SchoolHolidaysUiState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isRefreshing, isRefreshing) || other.isRefreshing == isRefreshing)&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled)&&(identical(other.selectedStateCode, selectedStateCode) || other.selectedStateCode == selectedStateCode)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other._holidaysByDate, _holidaysByDate)&&const DeepCollectionEquality().equals(other._allHolidays, _allHolidays)&&(identical(other.lastRefreshTime, lastRefreshTime) || other.lastRefreshTime == lastRefreshTime));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,isRefreshing,isEnabled,selectedStateCode,error,const DeepCollectionEquality().hash(_holidaysByDate),const DeepCollectionEquality().hash(_allHolidays),lastRefreshTime);

@override
String toString() {
  return 'SchoolHolidaysUiState(isLoading: $isLoading, isRefreshing: $isRefreshing, isEnabled: $isEnabled, selectedStateCode: $selectedStateCode, error: $error, holidaysByDate: $holidaysByDate, allHolidays: $allHolidays, lastRefreshTime: $lastRefreshTime)';
}


}

/// @nodoc
abstract mixin class _$SchoolHolidaysUiStateCopyWith<$Res> implements $SchoolHolidaysUiStateCopyWith<$Res> {
  factory _$SchoolHolidaysUiStateCopyWith(_SchoolHolidaysUiState value, $Res Function(_SchoolHolidaysUiState) _then) = __$SchoolHolidaysUiStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, bool isRefreshing, bool isEnabled, String? selectedStateCode, String? error, Map<DateTime, List<SchoolHoliday>> holidaysByDate, List<SchoolHoliday> allHolidays, DateTime? lastRefreshTime
});




}
/// @nodoc
class __$SchoolHolidaysUiStateCopyWithImpl<$Res>
    implements _$SchoolHolidaysUiStateCopyWith<$Res> {
  __$SchoolHolidaysUiStateCopyWithImpl(this._self, this._then);

  final _SchoolHolidaysUiState _self;
  final $Res Function(_SchoolHolidaysUiState) _then;

/// Create a copy of SchoolHolidaysUiState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? isRefreshing = null,Object? isEnabled = null,Object? selectedStateCode = freezed,Object? error = freezed,Object? holidaysByDate = null,Object? allHolidays = null,Object? lastRefreshTime = freezed,}) {
  return _then(_SchoolHolidaysUiState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isRefreshing: null == isRefreshing ? _self.isRefreshing : isRefreshing // ignore: cast_nullable_to_non_nullable
as bool,isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,selectedStateCode: freezed == selectedStateCode ? _self.selectedStateCode : selectedStateCode // ignore: cast_nullable_to_non_nullable
as String?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,holidaysByDate: null == holidaysByDate ? _self._holidaysByDate : holidaysByDate // ignore: cast_nullable_to_non_nullable
as Map<DateTime, List<SchoolHoliday>>,allHolidays: null == allHolidays ? _self._allHolidays : allHolidays // ignore: cast_nullable_to_non_nullable
as List<SchoolHoliday>,lastRefreshTime: freezed == lastRefreshTime ? _self.lastRefreshTime : lastRefreshTime // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
