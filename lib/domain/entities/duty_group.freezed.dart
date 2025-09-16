// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'duty_group.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DutyGroup {

 String get id; String get name; String get rhythm; double get offsetWeeks;
/// Create a copy of DutyGroup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DutyGroupCopyWith<DutyGroup> get copyWith => _$DutyGroupCopyWithImpl<DutyGroup>(this as DutyGroup, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DutyGroup&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.rhythm, rhythm) || other.rhythm == rhythm)&&(identical(other.offsetWeeks, offsetWeeks) || other.offsetWeeks == offsetWeeks));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,rhythm,offsetWeeks);

@override
String toString() {
  return 'DutyGroup(id: $id, name: $name, rhythm: $rhythm, offsetWeeks: $offsetWeeks)';
}


}

/// @nodoc
abstract mixin class $DutyGroupCopyWith<$Res>  {
  factory $DutyGroupCopyWith(DutyGroup value, $Res Function(DutyGroup) _then) = _$DutyGroupCopyWithImpl;
@useResult
$Res call({
 String id, String name, String rhythm, double offsetWeeks
});




}
/// @nodoc
class _$DutyGroupCopyWithImpl<$Res>
    implements $DutyGroupCopyWith<$Res> {
  _$DutyGroupCopyWithImpl(this._self, this._then);

  final DutyGroup _self;
  final $Res Function(DutyGroup) _then;

/// Create a copy of DutyGroup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? rhythm = null,Object? offsetWeeks = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,rhythm: null == rhythm ? _self.rhythm : rhythm // ignore: cast_nullable_to_non_nullable
as String,offsetWeeks: null == offsetWeeks ? _self.offsetWeeks : offsetWeeks // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [DutyGroup].
extension DutyGroupPatterns on DutyGroup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DutyGroup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DutyGroup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DutyGroup value)  $default,){
final _that = this;
switch (_that) {
case _DutyGroup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DutyGroup value)?  $default,){
final _that = this;
switch (_that) {
case _DutyGroup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String rhythm,  double offsetWeeks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DutyGroup() when $default != null:
return $default(_that.id,_that.name,_that.rhythm,_that.offsetWeeks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String rhythm,  double offsetWeeks)  $default,) {final _that = this;
switch (_that) {
case _DutyGroup():
return $default(_that.id,_that.name,_that.rhythm,_that.offsetWeeks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String rhythm,  double offsetWeeks)?  $default,) {final _that = this;
switch (_that) {
case _DutyGroup() when $default != null:
return $default(_that.id,_that.name,_that.rhythm,_that.offsetWeeks);case _:
  return null;

}
}

}

/// @nodoc


class _DutyGroup extends DutyGroup {
  const _DutyGroup({required this.id, required this.name, required this.rhythm, required this.offsetWeeks}): super._();
  

@override final  String id;
@override final  String name;
@override final  String rhythm;
@override final  double offsetWeeks;

/// Create a copy of DutyGroup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DutyGroupCopyWith<_DutyGroup> get copyWith => __$DutyGroupCopyWithImpl<_DutyGroup>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DutyGroup&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.rhythm, rhythm) || other.rhythm == rhythm)&&(identical(other.offsetWeeks, offsetWeeks) || other.offsetWeeks == offsetWeeks));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,rhythm,offsetWeeks);

@override
String toString() {
  return 'DutyGroup(id: $id, name: $name, rhythm: $rhythm, offsetWeeks: $offsetWeeks)';
}


}

/// @nodoc
abstract mixin class _$DutyGroupCopyWith<$Res> implements $DutyGroupCopyWith<$Res> {
  factory _$DutyGroupCopyWith(_DutyGroup value, $Res Function(_DutyGroup) _then) = __$DutyGroupCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String rhythm, double offsetWeeks
});




}
/// @nodoc
class __$DutyGroupCopyWithImpl<$Res>
    implements _$DutyGroupCopyWith<$Res> {
  __$DutyGroupCopyWithImpl(this._self, this._then);

  final _DutyGroup _self;
  final $Res Function(_DutyGroup) _then;

/// Create a copy of DutyGroup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? rhythm = null,Object? offsetWeeks = null,}) {
  return _then(_DutyGroup(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,rhythm: null == rhythm ? _self.rhythm : rhythm // ignore: cast_nullable_to_non_nullable
as String,offsetWeeks: null == offsetWeeks ? _self.offsetWeeks : offsetWeeks // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
