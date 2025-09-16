// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meta.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Meta {

 String get name; String get description; DateTime get startDate; String get startWeekDay; List<String> get days; String? get icon; String? get policeAuthority;
/// Create a copy of Meta
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MetaCopyWith<Meta> get copyWith => _$MetaCopyWithImpl<Meta>(this as Meta, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Meta&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.startWeekDay, startWeekDay) || other.startWeekDay == startWeekDay)&&const DeepCollectionEquality().equals(other.days, days)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.policeAuthority, policeAuthority) || other.policeAuthority == policeAuthority));
}


@override
int get hashCode => Object.hash(runtimeType,name,description,startDate,startWeekDay,const DeepCollectionEquality().hash(days),icon,policeAuthority);

@override
String toString() {
  return 'Meta(name: $name, description: $description, startDate: $startDate, startWeekDay: $startWeekDay, days: $days, icon: $icon, policeAuthority: $policeAuthority)';
}


}

/// @nodoc
abstract mixin class $MetaCopyWith<$Res>  {
  factory $MetaCopyWith(Meta value, $Res Function(Meta) _then) = _$MetaCopyWithImpl;
@useResult
$Res call({
 String name, String description, DateTime startDate, String startWeekDay, List<String> days, String? icon, String? policeAuthority
});




}
/// @nodoc
class _$MetaCopyWithImpl<$Res>
    implements $MetaCopyWith<$Res> {
  _$MetaCopyWithImpl(this._self, this._then);

  final Meta _self;
  final $Res Function(Meta) _then;

/// Create a copy of Meta
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? description = null,Object? startDate = null,Object? startWeekDay = null,Object? days = null,Object? icon = freezed,Object? policeAuthority = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,startWeekDay: null == startWeekDay ? _self.startWeekDay : startWeekDay // ignore: cast_nullable_to_non_nullable
as String,days: null == days ? _self.days : days // ignore: cast_nullable_to_non_nullable
as List<String>,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,policeAuthority: freezed == policeAuthority ? _self.policeAuthority : policeAuthority // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Meta].
extension MetaPatterns on Meta {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Meta value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Meta() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Meta value)  $default,){
final _that = this;
switch (_that) {
case _Meta():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Meta value)?  $default,){
final _that = this;
switch (_that) {
case _Meta() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String description,  DateTime startDate,  String startWeekDay,  List<String> days,  String? icon,  String? policeAuthority)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Meta() when $default != null:
return $default(_that.name,_that.description,_that.startDate,_that.startWeekDay,_that.days,_that.icon,_that.policeAuthority);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String description,  DateTime startDate,  String startWeekDay,  List<String> days,  String? icon,  String? policeAuthority)  $default,) {final _that = this;
switch (_that) {
case _Meta():
return $default(_that.name,_that.description,_that.startDate,_that.startWeekDay,_that.days,_that.icon,_that.policeAuthority);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String description,  DateTime startDate,  String startWeekDay,  List<String> days,  String? icon,  String? policeAuthority)?  $default,) {final _that = this;
switch (_that) {
case _Meta() when $default != null:
return $default(_that.name,_that.description,_that.startDate,_that.startWeekDay,_that.days,_that.icon,_that.policeAuthority);case _:
  return null;

}
}

}

/// @nodoc


class _Meta extends Meta {
  const _Meta({required this.name, required this.description, required this.startDate, required this.startWeekDay, required final  List<String> days, this.icon, this.policeAuthority}): _days = days,super._();
  

@override final  String name;
@override final  String description;
@override final  DateTime startDate;
@override final  String startWeekDay;
 final  List<String> _days;
@override List<String> get days {
  if (_days is EqualUnmodifiableListView) return _days;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_days);
}

@override final  String? icon;
@override final  String? policeAuthority;

/// Create a copy of Meta
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MetaCopyWith<_Meta> get copyWith => __$MetaCopyWithImpl<_Meta>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Meta&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.startWeekDay, startWeekDay) || other.startWeekDay == startWeekDay)&&const DeepCollectionEquality().equals(other._days, _days)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.policeAuthority, policeAuthority) || other.policeAuthority == policeAuthority));
}


@override
int get hashCode => Object.hash(runtimeType,name,description,startDate,startWeekDay,const DeepCollectionEquality().hash(_days),icon,policeAuthority);

@override
String toString() {
  return 'Meta(name: $name, description: $description, startDate: $startDate, startWeekDay: $startWeekDay, days: $days, icon: $icon, policeAuthority: $policeAuthority)';
}


}

/// @nodoc
abstract mixin class _$MetaCopyWith<$Res> implements $MetaCopyWith<$Res> {
  factory _$MetaCopyWith(_Meta value, $Res Function(_Meta) _then) = __$MetaCopyWithImpl;
@override @useResult
$Res call({
 String name, String description, DateTime startDate, String startWeekDay, List<String> days, String? icon, String? policeAuthority
});




}
/// @nodoc
class __$MetaCopyWithImpl<$Res>
    implements _$MetaCopyWith<$Res> {
  __$MetaCopyWithImpl(this._self, this._then);

  final _Meta _self;
  final $Res Function(_Meta) _then;

/// Create a copy of Meta
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? description = null,Object? startDate = null,Object? startWeekDay = null,Object? days = null,Object? icon = freezed,Object? policeAuthority = freezed,}) {
  return _then(_Meta(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,startWeekDay: null == startWeekDay ? _self.startWeekDay : startWeekDay // ignore: cast_nullable_to_non_nullable
as String,days: null == days ? _self._days : days // ignore: cast_nullable_to_non_nullable
as List<String>,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,policeAuthority: freezed == policeAuthority ? _self.policeAuthority : policeAuthority // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
