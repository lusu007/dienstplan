// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'school_holiday.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SchoolHoliday {

 String get id; String get name; DateTime get startDate; DateTime get endDate; String get stateCode; String get stateName; String? get description; HolidayType? get type;
/// Create a copy of SchoolHoliday
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SchoolHolidayCopyWith<SchoolHoliday> get copyWith => _$SchoolHolidayCopyWithImpl<SchoolHoliday>(this as SchoolHoliday, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SchoolHoliday&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.stateCode, stateCode) || other.stateCode == stateCode)&&(identical(other.stateName, stateName) || other.stateName == stateName)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,startDate,endDate,stateCode,stateName,description,type);

@override
String toString() {
  return 'SchoolHoliday(id: $id, name: $name, startDate: $startDate, endDate: $endDate, stateCode: $stateCode, stateName: $stateName, description: $description, type: $type)';
}


}

/// @nodoc
abstract mixin class $SchoolHolidayCopyWith<$Res>  {
  factory $SchoolHolidayCopyWith(SchoolHoliday value, $Res Function(SchoolHoliday) _then) = _$SchoolHolidayCopyWithImpl;
@useResult
$Res call({
 String id, String name, DateTime startDate, DateTime endDate, String stateCode, String stateName, String? description, HolidayType? type
});




}
/// @nodoc
class _$SchoolHolidayCopyWithImpl<$Res>
    implements $SchoolHolidayCopyWith<$Res> {
  _$SchoolHolidayCopyWithImpl(this._self, this._then);

  final SchoolHoliday _self;
  final $Res Function(SchoolHoliday) _then;

/// Create a copy of SchoolHoliday
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? startDate = null,Object? endDate = null,Object? stateCode = null,Object? stateName = null,Object? description = freezed,Object? type = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,stateCode: null == stateCode ? _self.stateCode : stateCode // ignore: cast_nullable_to_non_nullable
as String,stateName: null == stateName ? _self.stateName : stateName // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as HolidayType?,
  ));
}

}


/// Adds pattern-matching-related methods to [SchoolHoliday].
extension SchoolHolidayPatterns on SchoolHoliday {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SchoolHoliday value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SchoolHoliday() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SchoolHoliday value)  $default,){
final _that = this;
switch (_that) {
case _SchoolHoliday():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SchoolHoliday value)?  $default,){
final _that = this;
switch (_that) {
case _SchoolHoliday() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  DateTime startDate,  DateTime endDate,  String stateCode,  String stateName,  String? description,  HolidayType? type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SchoolHoliday() when $default != null:
return $default(_that.id,_that.name,_that.startDate,_that.endDate,_that.stateCode,_that.stateName,_that.description,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  DateTime startDate,  DateTime endDate,  String stateCode,  String stateName,  String? description,  HolidayType? type)  $default,) {final _that = this;
switch (_that) {
case _SchoolHoliday():
return $default(_that.id,_that.name,_that.startDate,_that.endDate,_that.stateCode,_that.stateName,_that.description,_that.type);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  DateTime startDate,  DateTime endDate,  String stateCode,  String stateName,  String? description,  HolidayType? type)?  $default,) {final _that = this;
switch (_that) {
case _SchoolHoliday() when $default != null:
return $default(_that.id,_that.name,_that.startDate,_that.endDate,_that.stateCode,_that.stateName,_that.description,_that.type);case _:
  return null;

}
}

}

/// @nodoc


class _SchoolHoliday extends SchoolHoliday {
  const _SchoolHoliday({required this.id, required this.name, required this.startDate, required this.endDate, required this.stateCode, required this.stateName, this.description, this.type}): super._();
  

@override final  String id;
@override final  String name;
@override final  DateTime startDate;
@override final  DateTime endDate;
@override final  String stateCode;
@override final  String stateName;
@override final  String? description;
@override final  HolidayType? type;

/// Create a copy of SchoolHoliday
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SchoolHolidayCopyWith<_SchoolHoliday> get copyWith => __$SchoolHolidayCopyWithImpl<_SchoolHoliday>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SchoolHoliday&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.stateCode, stateCode) || other.stateCode == stateCode)&&(identical(other.stateName, stateName) || other.stateName == stateName)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,startDate,endDate,stateCode,stateName,description,type);

@override
String toString() {
  return 'SchoolHoliday(id: $id, name: $name, startDate: $startDate, endDate: $endDate, stateCode: $stateCode, stateName: $stateName, description: $description, type: $type)';
}


}

/// @nodoc
abstract mixin class _$SchoolHolidayCopyWith<$Res> implements $SchoolHolidayCopyWith<$Res> {
  factory _$SchoolHolidayCopyWith(_SchoolHoliday value, $Res Function(_SchoolHoliday) _then) = __$SchoolHolidayCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, DateTime startDate, DateTime endDate, String stateCode, String stateName, String? description, HolidayType? type
});




}
/// @nodoc
class __$SchoolHolidayCopyWithImpl<$Res>
    implements _$SchoolHolidayCopyWith<$Res> {
  __$SchoolHolidayCopyWithImpl(this._self, this._then);

  final _SchoolHoliday _self;
  final $Res Function(_SchoolHoliday) _then;

/// Create a copy of SchoolHoliday
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? startDate = null,Object? endDate = null,Object? stateCode = null,Object? stateName = null,Object? description = freezed,Object? type = freezed,}) {
  return _then(_SchoolHoliday(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,stateCode: null == stateCode ? _self.stateCode : stateCode // ignore: cast_nullable_to_non_nullable
as String,stateName: null == stateName ? _self.stateName : stateName // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as HolidayType?,
  ));
}


}

// dart format on
