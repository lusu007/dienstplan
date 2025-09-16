// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rhythm.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Rhythm {

 int get lengthWeeks; List<List<String>> get pattern;
/// Create a copy of Rhythm
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RhythmCopyWith<Rhythm> get copyWith => _$RhythmCopyWithImpl<Rhythm>(this as Rhythm, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Rhythm&&(identical(other.lengthWeeks, lengthWeeks) || other.lengthWeeks == lengthWeeks)&&const DeepCollectionEquality().equals(other.pattern, pattern));
}


@override
int get hashCode => Object.hash(runtimeType,lengthWeeks,const DeepCollectionEquality().hash(pattern));

@override
String toString() {
  return 'Rhythm(lengthWeeks: $lengthWeeks, pattern: $pattern)';
}


}

/// @nodoc
abstract mixin class $RhythmCopyWith<$Res>  {
  factory $RhythmCopyWith(Rhythm value, $Res Function(Rhythm) _then) = _$RhythmCopyWithImpl;
@useResult
$Res call({
 int lengthWeeks, List<List<String>> pattern
});




}
/// @nodoc
class _$RhythmCopyWithImpl<$Res>
    implements $RhythmCopyWith<$Res> {
  _$RhythmCopyWithImpl(this._self, this._then);

  final Rhythm _self;
  final $Res Function(Rhythm) _then;

/// Create a copy of Rhythm
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lengthWeeks = null,Object? pattern = null,}) {
  return _then(_self.copyWith(
lengthWeeks: null == lengthWeeks ? _self.lengthWeeks : lengthWeeks // ignore: cast_nullable_to_non_nullable
as int,pattern: null == pattern ? _self.pattern : pattern // ignore: cast_nullable_to_non_nullable
as List<List<String>>,
  ));
}

}


/// Adds pattern-matching-related methods to [Rhythm].
extension RhythmPatterns on Rhythm {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Rhythm value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Rhythm() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Rhythm value)  $default,){
final _that = this;
switch (_that) {
case _Rhythm():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Rhythm value)?  $default,){
final _that = this;
switch (_that) {
case _Rhythm() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int lengthWeeks,  List<List<String>> pattern)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Rhythm() when $default != null:
return $default(_that.lengthWeeks,_that.pattern);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int lengthWeeks,  List<List<String>> pattern)  $default,) {final _that = this;
switch (_that) {
case _Rhythm():
return $default(_that.lengthWeeks,_that.pattern);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int lengthWeeks,  List<List<String>> pattern)?  $default,) {final _that = this;
switch (_that) {
case _Rhythm() when $default != null:
return $default(_that.lengthWeeks,_that.pattern);case _:
  return null;

}
}

}

/// @nodoc


class _Rhythm extends Rhythm {
  const _Rhythm({required this.lengthWeeks, required final  List<List<String>> pattern}): _pattern = pattern,super._();
  

@override final  int lengthWeeks;
 final  List<List<String>> _pattern;
@override List<List<String>> get pattern {
  if (_pattern is EqualUnmodifiableListView) return _pattern;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pattern);
}


/// Create a copy of Rhythm
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RhythmCopyWith<_Rhythm> get copyWith => __$RhythmCopyWithImpl<_Rhythm>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Rhythm&&(identical(other.lengthWeeks, lengthWeeks) || other.lengthWeeks == lengthWeeks)&&const DeepCollectionEquality().equals(other._pattern, _pattern));
}


@override
int get hashCode => Object.hash(runtimeType,lengthWeeks,const DeepCollectionEquality().hash(_pattern));

@override
String toString() {
  return 'Rhythm(lengthWeeks: $lengthWeeks, pattern: $pattern)';
}


}

/// @nodoc
abstract mixin class _$RhythmCopyWith<$Res> implements $RhythmCopyWith<$Res> {
  factory _$RhythmCopyWith(_Rhythm value, $Res Function(_Rhythm) _then) = __$RhythmCopyWithImpl;
@override @useResult
$Res call({
 int lengthWeeks, List<List<String>> pattern
});




}
/// @nodoc
class __$RhythmCopyWithImpl<$Res>
    implements _$RhythmCopyWith<$Res> {
  __$RhythmCopyWithImpl(this._self, this._then);

  final _Rhythm _self;
  final $Res Function(_Rhythm) _then;

/// Create a copy of Rhythm
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lengthWeeks = null,Object? pattern = null,}) {
  return _then(_Rhythm(
lengthWeeks: null == lengthWeeks ? _self.lengthWeeks : lengthWeeks // ignore: cast_nullable_to_non_nullable
as int,pattern: null == pattern ? _self._pattern : pattern // ignore: cast_nullable_to_non_nullable
as List<List<String>>,
  ));
}


}

// dart format on
