// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'duty_type.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DutyType {

 String get label; bool get isAllDay; String? get icon;
/// Create a copy of DutyType
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DutyTypeCopyWith<DutyType> get copyWith => _$DutyTypeCopyWithImpl<DutyType>(this as DutyType, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DutyType&&(identical(other.label, label) || other.label == label)&&(identical(other.isAllDay, isAllDay) || other.isAllDay == isAllDay)&&(identical(other.icon, icon) || other.icon == icon));
}


@override
int get hashCode => Object.hash(runtimeType,label,isAllDay,icon);

@override
String toString() {
  return 'DutyType(label: $label, isAllDay: $isAllDay, icon: $icon)';
}


}

/// @nodoc
abstract mixin class $DutyTypeCopyWith<$Res>  {
  factory $DutyTypeCopyWith(DutyType value, $Res Function(DutyType) _then) = _$DutyTypeCopyWithImpl;
@useResult
$Res call({
 String label, bool isAllDay, String? icon
});




}
/// @nodoc
class _$DutyTypeCopyWithImpl<$Res>
    implements $DutyTypeCopyWith<$Res> {
  _$DutyTypeCopyWithImpl(this._self, this._then);

  final DutyType _self;
  final $Res Function(DutyType) _then;

/// Create a copy of DutyType
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? isAllDay = null,Object? icon = freezed,}) {
  return _then(_self.copyWith(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,isAllDay: null == isAllDay ? _self.isAllDay : isAllDay // ignore: cast_nullable_to_non_nullable
as bool,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DutyType].
extension DutyTypePatterns on DutyType {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DutyType value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DutyType() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DutyType value)  $default,){
final _that = this;
switch (_that) {
case _DutyType():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DutyType value)?  $default,){
final _that = this;
switch (_that) {
case _DutyType() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  bool isAllDay,  String? icon)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DutyType() when $default != null:
return $default(_that.label,_that.isAllDay,_that.icon);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  bool isAllDay,  String? icon)  $default,) {final _that = this;
switch (_that) {
case _DutyType():
return $default(_that.label,_that.isAllDay,_that.icon);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  bool isAllDay,  String? icon)?  $default,) {final _that = this;
switch (_that) {
case _DutyType() when $default != null:
return $default(_that.label,_that.isAllDay,_that.icon);case _:
  return null;

}
}

}

/// @nodoc


class _DutyType extends DutyType {
  const _DutyType({required this.label, this.isAllDay = false, this.icon}): super._();
  

@override final  String label;
@override@JsonKey() final  bool isAllDay;
@override final  String? icon;

/// Create a copy of DutyType
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DutyTypeCopyWith<_DutyType> get copyWith => __$DutyTypeCopyWithImpl<_DutyType>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DutyType&&(identical(other.label, label) || other.label == label)&&(identical(other.isAllDay, isAllDay) || other.isAllDay == isAllDay)&&(identical(other.icon, icon) || other.icon == icon));
}


@override
int get hashCode => Object.hash(runtimeType,label,isAllDay,icon);

@override
String toString() {
  return 'DutyType(label: $label, isAllDay: $isAllDay, icon: $icon)';
}


}

/// @nodoc
abstract mixin class _$DutyTypeCopyWith<$Res> implements $DutyTypeCopyWith<$Res> {
  factory _$DutyTypeCopyWith(_DutyType value, $Res Function(_DutyType) _then) = __$DutyTypeCopyWithImpl;
@override @useResult
$Res call({
 String label, bool isAllDay, String? icon
});




}
/// @nodoc
class __$DutyTypeCopyWithImpl<$Res>
    implements _$DutyTypeCopyWith<$Res> {
  __$DutyTypeCopyWithImpl(this._self, this._then);

  final _DutyType _self;
  final $Res Function(_DutyType) _then;

/// Create a copy of DutyType
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? isAllDay = null,Object? icon = freezed,}) {
  return _then(_DutyType(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,isAllDay: null == isAllDay ? _self.isAllDay : isAllDay // ignore: cast_nullable_to_non_nullable
as bool,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
