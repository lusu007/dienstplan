// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_ui_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SettingsUiState {
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  String? get language => throw _privateConstructorUsedError;
  CalendarFormat? get calendarFormat => throw _privateConstructorUsedError;
  String? get activeConfigName => throw _privateConstructorUsedError;
  String? get myDutyGroup => throw _privateConstructorUsedError;

  /// Create a copy of SettingsUiState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SettingsUiStateCopyWith<SettingsUiState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SettingsUiStateCopyWith<$Res> {
  factory $SettingsUiStateCopyWith(
          SettingsUiState value, $Res Function(SettingsUiState) then) =
      _$SettingsUiStateCopyWithImpl<$Res, SettingsUiState>;
  @useResult
  $Res call(
      {bool isLoading,
      String? error,
      String? language,
      CalendarFormat? calendarFormat,
      String? activeConfigName,
      String? myDutyGroup});
}

/// @nodoc
class _$SettingsUiStateCopyWithImpl<$Res, $Val extends SettingsUiState>
    implements $SettingsUiStateCopyWith<$Res> {
  _$SettingsUiStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SettingsUiState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? language = freezed,
    Object? calendarFormat = freezed,
    Object? activeConfigName = freezed,
    Object? myDutyGroup = freezed,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      language: freezed == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
      calendarFormat: freezed == calendarFormat
          ? _value.calendarFormat
          : calendarFormat // ignore: cast_nullable_to_non_nullable
              as CalendarFormat?,
      activeConfigName: freezed == activeConfigName
          ? _value.activeConfigName
          : activeConfigName // ignore: cast_nullable_to_non_nullable
              as String?,
      myDutyGroup: freezed == myDutyGroup
          ? _value.myDutyGroup
          : myDutyGroup // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SettingsUiStateImplCopyWith<$Res>
    implements $SettingsUiStateCopyWith<$Res> {
  factory _$$SettingsUiStateImplCopyWith(_$SettingsUiStateImpl value,
          $Res Function(_$SettingsUiStateImpl) then) =
      __$$SettingsUiStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      String? error,
      String? language,
      CalendarFormat? calendarFormat,
      String? activeConfigName,
      String? myDutyGroup});
}

/// @nodoc
class __$$SettingsUiStateImplCopyWithImpl<$Res>
    extends _$SettingsUiStateCopyWithImpl<$Res, _$SettingsUiStateImpl>
    implements _$$SettingsUiStateImplCopyWith<$Res> {
  __$$SettingsUiStateImplCopyWithImpl(
      _$SettingsUiStateImpl _value, $Res Function(_$SettingsUiStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of SettingsUiState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? language = freezed,
    Object? calendarFormat = freezed,
    Object? activeConfigName = freezed,
    Object? myDutyGroup = freezed,
  }) {
    return _then(_$SettingsUiStateImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      language: freezed == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
      calendarFormat: freezed == calendarFormat
          ? _value.calendarFormat
          : calendarFormat // ignore: cast_nullable_to_non_nullable
              as CalendarFormat?,
      activeConfigName: freezed == activeConfigName
          ? _value.activeConfigName
          : activeConfigName // ignore: cast_nullable_to_non_nullable
              as String?,
      myDutyGroup: freezed == myDutyGroup
          ? _value.myDutyGroup
          : myDutyGroup // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$SettingsUiStateImpl extends _SettingsUiState {
  const _$SettingsUiStateImpl(
      {required this.isLoading,
      this.error,
      this.language,
      this.calendarFormat,
      this.activeConfigName,
      this.myDutyGroup})
      : super._();

  @override
  final bool isLoading;
  @override
  final String? error;
  @override
  final String? language;
  @override
  final CalendarFormat? calendarFormat;
  @override
  final String? activeConfigName;
  @override
  final String? myDutyGroup;

  @override
  String toString() {
    return 'SettingsUiState(isLoading: $isLoading, error: $error, language: $language, calendarFormat: $calendarFormat, activeConfigName: $activeConfigName, myDutyGroup: $myDutyGroup)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SettingsUiStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.calendarFormat, calendarFormat) ||
                other.calendarFormat == calendarFormat) &&
            (identical(other.activeConfigName, activeConfigName) ||
                other.activeConfigName == activeConfigName) &&
            (identical(other.myDutyGroup, myDutyGroup) ||
                other.myDutyGroup == myDutyGroup));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading, error, language,
      calendarFormat, activeConfigName, myDutyGroup);

  /// Create a copy of SettingsUiState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SettingsUiStateImplCopyWith<_$SettingsUiStateImpl> get copyWith =>
      __$$SettingsUiStateImplCopyWithImpl<_$SettingsUiStateImpl>(
          this, _$identity);
}

abstract class _SettingsUiState extends SettingsUiState {
  const factory _SettingsUiState(
      {required final bool isLoading,
      final String? error,
      final String? language,
      final CalendarFormat? calendarFormat,
      final String? activeConfigName,
      final String? myDutyGroup}) = _$SettingsUiStateImpl;
  const _SettingsUiState._() : super._();

  @override
  bool get isLoading;
  @override
  String? get error;
  @override
  String? get language;
  @override
  CalendarFormat? get calendarFormat;
  @override
  String? get activeConfigName;
  @override
  String? get myDutyGroup;

  /// Create a copy of SettingsUiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SettingsUiStateImplCopyWith<_$SettingsUiStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
