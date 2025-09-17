// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Settings {

 CalendarFormat get calendarFormat; String? get language; String? get selectedDutyGroup; String? get myDutyGroup; String? get activeConfigName; ThemePreference? get themePreference;// Partner duty group feature
 String? get partnerConfigName; String? get partnerDutyGroup; int? get partnerAccentColorValue;// My accent color feature
 int? get myAccentColorValue;// School holidays feature
 String? get schoolHolidayStateCode; bool? get showSchoolHolidays; DateTime? get lastSchoolHolidayRefresh; int? get holidayAccentColorValue;
/// Create a copy of Settings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsCopyWith<Settings> get copyWith => _$SettingsCopyWithImpl<Settings>(this as Settings, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Settings&&(identical(other.calendarFormat, calendarFormat) || other.calendarFormat == calendarFormat)&&(identical(other.language, language) || other.language == language)&&(identical(other.selectedDutyGroup, selectedDutyGroup) || other.selectedDutyGroup == selectedDutyGroup)&&(identical(other.myDutyGroup, myDutyGroup) || other.myDutyGroup == myDutyGroup)&&(identical(other.activeConfigName, activeConfigName) || other.activeConfigName == activeConfigName)&&(identical(other.themePreference, themePreference) || other.themePreference == themePreference)&&(identical(other.partnerConfigName, partnerConfigName) || other.partnerConfigName == partnerConfigName)&&(identical(other.partnerDutyGroup, partnerDutyGroup) || other.partnerDutyGroup == partnerDutyGroup)&&(identical(other.partnerAccentColorValue, partnerAccentColorValue) || other.partnerAccentColorValue == partnerAccentColorValue)&&(identical(other.myAccentColorValue, myAccentColorValue) || other.myAccentColorValue == myAccentColorValue)&&(identical(other.schoolHolidayStateCode, schoolHolidayStateCode) || other.schoolHolidayStateCode == schoolHolidayStateCode)&&(identical(other.showSchoolHolidays, showSchoolHolidays) || other.showSchoolHolidays == showSchoolHolidays)&&(identical(other.lastSchoolHolidayRefresh, lastSchoolHolidayRefresh) || other.lastSchoolHolidayRefresh == lastSchoolHolidayRefresh)&&(identical(other.holidayAccentColorValue, holidayAccentColorValue) || other.holidayAccentColorValue == holidayAccentColorValue));
}


@override
int get hashCode => Object.hash(runtimeType,calendarFormat,language,selectedDutyGroup,myDutyGroup,activeConfigName,themePreference,partnerConfigName,partnerDutyGroup,partnerAccentColorValue,myAccentColorValue,schoolHolidayStateCode,showSchoolHolidays,lastSchoolHolidayRefresh,holidayAccentColorValue);

@override
String toString() {
  return 'Settings(calendarFormat: $calendarFormat, language: $language, selectedDutyGroup: $selectedDutyGroup, myDutyGroup: $myDutyGroup, activeConfigName: $activeConfigName, themePreference: $themePreference, partnerConfigName: $partnerConfigName, partnerDutyGroup: $partnerDutyGroup, partnerAccentColorValue: $partnerAccentColorValue, myAccentColorValue: $myAccentColorValue, schoolHolidayStateCode: $schoolHolidayStateCode, showSchoolHolidays: $showSchoolHolidays, lastSchoolHolidayRefresh: $lastSchoolHolidayRefresh, holidayAccentColorValue: $holidayAccentColorValue)';
}


}

/// @nodoc
abstract mixin class $SettingsCopyWith<$Res>  {
  factory $SettingsCopyWith(Settings value, $Res Function(Settings) _then) = _$SettingsCopyWithImpl;
@useResult
$Res call({
 CalendarFormat calendarFormat, String? language, String? selectedDutyGroup, String? myDutyGroup, String? activeConfigName, ThemePreference? themePreference, String? partnerConfigName, String? partnerDutyGroup, int? partnerAccentColorValue, int? myAccentColorValue, String? schoolHolidayStateCode, bool? showSchoolHolidays, DateTime? lastSchoolHolidayRefresh, int? holidayAccentColorValue
});




}
/// @nodoc
class _$SettingsCopyWithImpl<$Res>
    implements $SettingsCopyWith<$Res> {
  _$SettingsCopyWithImpl(this._self, this._then);

  final Settings _self;
  final $Res Function(Settings) _then;

/// Create a copy of Settings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? calendarFormat = null,Object? language = freezed,Object? selectedDutyGroup = freezed,Object? myDutyGroup = freezed,Object? activeConfigName = freezed,Object? themePreference = freezed,Object? partnerConfigName = freezed,Object? partnerDutyGroup = freezed,Object? partnerAccentColorValue = freezed,Object? myAccentColorValue = freezed,Object? schoolHolidayStateCode = freezed,Object? showSchoolHolidays = freezed,Object? lastSchoolHolidayRefresh = freezed,Object? holidayAccentColorValue = freezed,}) {
  return _then(_self.copyWith(
calendarFormat: null == calendarFormat ? _self.calendarFormat : calendarFormat // ignore: cast_nullable_to_non_nullable
as CalendarFormat,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,selectedDutyGroup: freezed == selectedDutyGroup ? _self.selectedDutyGroup : selectedDutyGroup // ignore: cast_nullable_to_non_nullable
as String?,myDutyGroup: freezed == myDutyGroup ? _self.myDutyGroup : myDutyGroup // ignore: cast_nullable_to_non_nullable
as String?,activeConfigName: freezed == activeConfigName ? _self.activeConfigName : activeConfigName // ignore: cast_nullable_to_non_nullable
as String?,themePreference: freezed == themePreference ? _self.themePreference : themePreference // ignore: cast_nullable_to_non_nullable
as ThemePreference?,partnerConfigName: freezed == partnerConfigName ? _self.partnerConfigName : partnerConfigName // ignore: cast_nullable_to_non_nullable
as String?,partnerDutyGroup: freezed == partnerDutyGroup ? _self.partnerDutyGroup : partnerDutyGroup // ignore: cast_nullable_to_non_nullable
as String?,partnerAccentColorValue: freezed == partnerAccentColorValue ? _self.partnerAccentColorValue : partnerAccentColorValue // ignore: cast_nullable_to_non_nullable
as int?,myAccentColorValue: freezed == myAccentColorValue ? _self.myAccentColorValue : myAccentColorValue // ignore: cast_nullable_to_non_nullable
as int?,schoolHolidayStateCode: freezed == schoolHolidayStateCode ? _self.schoolHolidayStateCode : schoolHolidayStateCode // ignore: cast_nullable_to_non_nullable
as String?,showSchoolHolidays: freezed == showSchoolHolidays ? _self.showSchoolHolidays : showSchoolHolidays // ignore: cast_nullable_to_non_nullable
as bool?,lastSchoolHolidayRefresh: freezed == lastSchoolHolidayRefresh ? _self.lastSchoolHolidayRefresh : lastSchoolHolidayRefresh // ignore: cast_nullable_to_non_nullable
as DateTime?,holidayAccentColorValue: freezed == holidayAccentColorValue ? _self.holidayAccentColorValue : holidayAccentColorValue // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [Settings].
extension SettingsPatterns on Settings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Settings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Settings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Settings value)  $default,){
final _that = this;
switch (_that) {
case _Settings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Settings value)?  $default,){
final _that = this;
switch (_that) {
case _Settings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CalendarFormat calendarFormat,  String? language,  String? selectedDutyGroup,  String? myDutyGroup,  String? activeConfigName,  ThemePreference? themePreference,  String? partnerConfigName,  String? partnerDutyGroup,  int? partnerAccentColorValue,  int? myAccentColorValue,  String? schoolHolidayStateCode,  bool? showSchoolHolidays,  DateTime? lastSchoolHolidayRefresh,  int? holidayAccentColorValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Settings() when $default != null:
return $default(_that.calendarFormat,_that.language,_that.selectedDutyGroup,_that.myDutyGroup,_that.activeConfigName,_that.themePreference,_that.partnerConfigName,_that.partnerDutyGroup,_that.partnerAccentColorValue,_that.myAccentColorValue,_that.schoolHolidayStateCode,_that.showSchoolHolidays,_that.lastSchoolHolidayRefresh,_that.holidayAccentColorValue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CalendarFormat calendarFormat,  String? language,  String? selectedDutyGroup,  String? myDutyGroup,  String? activeConfigName,  ThemePreference? themePreference,  String? partnerConfigName,  String? partnerDutyGroup,  int? partnerAccentColorValue,  int? myAccentColorValue,  String? schoolHolidayStateCode,  bool? showSchoolHolidays,  DateTime? lastSchoolHolidayRefresh,  int? holidayAccentColorValue)  $default,) {final _that = this;
switch (_that) {
case _Settings():
return $default(_that.calendarFormat,_that.language,_that.selectedDutyGroup,_that.myDutyGroup,_that.activeConfigName,_that.themePreference,_that.partnerConfigName,_that.partnerDutyGroup,_that.partnerAccentColorValue,_that.myAccentColorValue,_that.schoolHolidayStateCode,_that.showSchoolHolidays,_that.lastSchoolHolidayRefresh,_that.holidayAccentColorValue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CalendarFormat calendarFormat,  String? language,  String? selectedDutyGroup,  String? myDutyGroup,  String? activeConfigName,  ThemePreference? themePreference,  String? partnerConfigName,  String? partnerDutyGroup,  int? partnerAccentColorValue,  int? myAccentColorValue,  String? schoolHolidayStateCode,  bool? showSchoolHolidays,  DateTime? lastSchoolHolidayRefresh,  int? holidayAccentColorValue)?  $default,) {final _that = this;
switch (_that) {
case _Settings() when $default != null:
return $default(_that.calendarFormat,_that.language,_that.selectedDutyGroup,_that.myDutyGroup,_that.activeConfigName,_that.themePreference,_that.partnerConfigName,_that.partnerDutyGroup,_that.partnerAccentColorValue,_that.myAccentColorValue,_that.schoolHolidayStateCode,_that.showSchoolHolidays,_that.lastSchoolHolidayRefresh,_that.holidayAccentColorValue);case _:
  return null;

}
}

}

/// @nodoc


class _Settings extends Settings {
  const _Settings({required this.calendarFormat, this.language, this.selectedDutyGroup, this.myDutyGroup, this.activeConfigName, this.themePreference, this.partnerConfigName, this.partnerDutyGroup, this.partnerAccentColorValue, this.myAccentColorValue, this.schoolHolidayStateCode, this.showSchoolHolidays, this.lastSchoolHolidayRefresh, this.holidayAccentColorValue}): super._();
  

@override final  CalendarFormat calendarFormat;
@override final  String? language;
@override final  String? selectedDutyGroup;
@override final  String? myDutyGroup;
@override final  String? activeConfigName;
@override final  ThemePreference? themePreference;
// Partner duty group feature
@override final  String? partnerConfigName;
@override final  String? partnerDutyGroup;
@override final  int? partnerAccentColorValue;
// My accent color feature
@override final  int? myAccentColorValue;
// School holidays feature
@override final  String? schoolHolidayStateCode;
@override final  bool? showSchoolHolidays;
@override final  DateTime? lastSchoolHolidayRefresh;
@override final  int? holidayAccentColorValue;

/// Create a copy of Settings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettingsCopyWith<_Settings> get copyWith => __$SettingsCopyWithImpl<_Settings>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Settings&&(identical(other.calendarFormat, calendarFormat) || other.calendarFormat == calendarFormat)&&(identical(other.language, language) || other.language == language)&&(identical(other.selectedDutyGroup, selectedDutyGroup) || other.selectedDutyGroup == selectedDutyGroup)&&(identical(other.myDutyGroup, myDutyGroup) || other.myDutyGroup == myDutyGroup)&&(identical(other.activeConfigName, activeConfigName) || other.activeConfigName == activeConfigName)&&(identical(other.themePreference, themePreference) || other.themePreference == themePreference)&&(identical(other.partnerConfigName, partnerConfigName) || other.partnerConfigName == partnerConfigName)&&(identical(other.partnerDutyGroup, partnerDutyGroup) || other.partnerDutyGroup == partnerDutyGroup)&&(identical(other.partnerAccentColorValue, partnerAccentColorValue) || other.partnerAccentColorValue == partnerAccentColorValue)&&(identical(other.myAccentColorValue, myAccentColorValue) || other.myAccentColorValue == myAccentColorValue)&&(identical(other.schoolHolidayStateCode, schoolHolidayStateCode) || other.schoolHolidayStateCode == schoolHolidayStateCode)&&(identical(other.showSchoolHolidays, showSchoolHolidays) || other.showSchoolHolidays == showSchoolHolidays)&&(identical(other.lastSchoolHolidayRefresh, lastSchoolHolidayRefresh) || other.lastSchoolHolidayRefresh == lastSchoolHolidayRefresh)&&(identical(other.holidayAccentColorValue, holidayAccentColorValue) || other.holidayAccentColorValue == holidayAccentColorValue));
}


@override
int get hashCode => Object.hash(runtimeType,calendarFormat,language,selectedDutyGroup,myDutyGroup,activeConfigName,themePreference,partnerConfigName,partnerDutyGroup,partnerAccentColorValue,myAccentColorValue,schoolHolidayStateCode,showSchoolHolidays,lastSchoolHolidayRefresh,holidayAccentColorValue);

@override
String toString() {
  return 'Settings(calendarFormat: $calendarFormat, language: $language, selectedDutyGroup: $selectedDutyGroup, myDutyGroup: $myDutyGroup, activeConfigName: $activeConfigName, themePreference: $themePreference, partnerConfigName: $partnerConfigName, partnerDutyGroup: $partnerDutyGroup, partnerAccentColorValue: $partnerAccentColorValue, myAccentColorValue: $myAccentColorValue, schoolHolidayStateCode: $schoolHolidayStateCode, showSchoolHolidays: $showSchoolHolidays, lastSchoolHolidayRefresh: $lastSchoolHolidayRefresh, holidayAccentColorValue: $holidayAccentColorValue)';
}


}

/// @nodoc
abstract mixin class _$SettingsCopyWith<$Res> implements $SettingsCopyWith<$Res> {
  factory _$SettingsCopyWith(_Settings value, $Res Function(_Settings) _then) = __$SettingsCopyWithImpl;
@override @useResult
$Res call({
 CalendarFormat calendarFormat, String? language, String? selectedDutyGroup, String? myDutyGroup, String? activeConfigName, ThemePreference? themePreference, String? partnerConfigName, String? partnerDutyGroup, int? partnerAccentColorValue, int? myAccentColorValue, String? schoolHolidayStateCode, bool? showSchoolHolidays, DateTime? lastSchoolHolidayRefresh, int? holidayAccentColorValue
});




}
/// @nodoc
class __$SettingsCopyWithImpl<$Res>
    implements _$SettingsCopyWith<$Res> {
  __$SettingsCopyWithImpl(this._self, this._then);

  final _Settings _self;
  final $Res Function(_Settings) _then;

/// Create a copy of Settings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? calendarFormat = null,Object? language = freezed,Object? selectedDutyGroup = freezed,Object? myDutyGroup = freezed,Object? activeConfigName = freezed,Object? themePreference = freezed,Object? partnerConfigName = freezed,Object? partnerDutyGroup = freezed,Object? partnerAccentColorValue = freezed,Object? myAccentColorValue = freezed,Object? schoolHolidayStateCode = freezed,Object? showSchoolHolidays = freezed,Object? lastSchoolHolidayRefresh = freezed,Object? holidayAccentColorValue = freezed,}) {
  return _then(_Settings(
calendarFormat: null == calendarFormat ? _self.calendarFormat : calendarFormat // ignore: cast_nullable_to_non_nullable
as CalendarFormat,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,selectedDutyGroup: freezed == selectedDutyGroup ? _self.selectedDutyGroup : selectedDutyGroup // ignore: cast_nullable_to_non_nullable
as String?,myDutyGroup: freezed == myDutyGroup ? _self.myDutyGroup : myDutyGroup // ignore: cast_nullable_to_non_nullable
as String?,activeConfigName: freezed == activeConfigName ? _self.activeConfigName : activeConfigName // ignore: cast_nullable_to_non_nullable
as String?,themePreference: freezed == themePreference ? _self.themePreference : themePreference // ignore: cast_nullable_to_non_nullable
as ThemePreference?,partnerConfigName: freezed == partnerConfigName ? _self.partnerConfigName : partnerConfigName // ignore: cast_nullable_to_non_nullable
as String?,partnerDutyGroup: freezed == partnerDutyGroup ? _self.partnerDutyGroup : partnerDutyGroup // ignore: cast_nullable_to_non_nullable
as String?,partnerAccentColorValue: freezed == partnerAccentColorValue ? _self.partnerAccentColorValue : partnerAccentColorValue // ignore: cast_nullable_to_non_nullable
as int?,myAccentColorValue: freezed == myAccentColorValue ? _self.myAccentColorValue : myAccentColorValue // ignore: cast_nullable_to_non_nullable
as int?,schoolHolidayStateCode: freezed == schoolHolidayStateCode ? _self.schoolHolidayStateCode : schoolHolidayStateCode // ignore: cast_nullable_to_non_nullable
as String?,showSchoolHolidays: freezed == showSchoolHolidays ? _self.showSchoolHolidays : showSchoolHolidays // ignore: cast_nullable_to_non_nullable
as bool?,lastSchoolHolidayRefresh: freezed == lastSchoolHolidayRefresh ? _self.lastSchoolHolidayRefresh : lastSchoolHolidayRefresh // ignore: cast_nullable_to_non_nullable
as DateTime?,holidayAccentColorValue: freezed == holidayAccentColorValue ? _self.holidayAccentColorValue : holidayAccentColorValue // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
