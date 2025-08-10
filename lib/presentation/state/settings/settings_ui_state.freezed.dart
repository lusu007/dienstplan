// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_ui_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SettingsUiState {
  bool get isLoading;
  String? get error;
  String? get language;
  CalendarFormat? get calendarFormat;
  String? get activeConfigName;
  String? get myDutyGroup;
  ThemePreference? get themePreference; // Partner duty group UI values
  String? get partnerConfigName;
  String? get partnerDutyGroup;
  int? get partnerAccentColorValue; // My accent color UI value
  int? get myAccentColorValue;

  /// Create a copy of SettingsUiState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SettingsUiStateCopyWith<SettingsUiState> get copyWith =>
      _$SettingsUiStateCopyWithImpl<SettingsUiState>(
          this as SettingsUiState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SettingsUiState &&
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
                other.myDutyGroup == myDutyGroup) &&
            (identical(other.themePreference, themePreference) ||
                other.themePreference == themePreference) &&
            (identical(other.partnerConfigName, partnerConfigName) ||
                other.partnerConfigName == partnerConfigName) &&
            (identical(other.partnerDutyGroup, partnerDutyGroup) ||
                other.partnerDutyGroup == partnerDutyGroup) &&
            (identical(
                    other.partnerAccentColorValue, partnerAccentColorValue) ||
                other.partnerAccentColorValue == partnerAccentColorValue) &&
            (identical(other.myAccentColorValue, myAccentColorValue) ||
                other.myAccentColorValue == myAccentColorValue));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isLoading,
      error,
      language,
      calendarFormat,
      activeConfigName,
      myDutyGroup,
      themePreference,
      partnerConfigName,
      partnerDutyGroup,
      partnerAccentColorValue,
      myAccentColorValue);

  @override
  String toString() {
    return 'SettingsUiState(isLoading: $isLoading, error: $error, language: $language, calendarFormat: $calendarFormat, activeConfigName: $activeConfigName, myDutyGroup: $myDutyGroup, themePreference: $themePreference, partnerConfigName: $partnerConfigName, partnerDutyGroup: $partnerDutyGroup, partnerAccentColorValue: $partnerAccentColorValue, myAccentColorValue: $myAccentColorValue)';
  }
}

/// @nodoc
abstract mixin class $SettingsUiStateCopyWith<$Res> {
  factory $SettingsUiStateCopyWith(
          SettingsUiState value, $Res Function(SettingsUiState) _then) =
      _$SettingsUiStateCopyWithImpl;
  @useResult
  $Res call(
      {bool isLoading,
      String? error,
      String? language,
      CalendarFormat? calendarFormat,
      String? activeConfigName,
      String? myDutyGroup,
      ThemePreference? themePreference,
      String? partnerConfigName,
      String? partnerDutyGroup,
      int? partnerAccentColorValue,
      int? myAccentColorValue});
}

/// @nodoc
class _$SettingsUiStateCopyWithImpl<$Res>
    implements $SettingsUiStateCopyWith<$Res> {
  _$SettingsUiStateCopyWithImpl(this._self, this._then);

  final SettingsUiState _self;
  final $Res Function(SettingsUiState) _then;

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
    Object? themePreference = freezed,
    Object? partnerConfigName = freezed,
    Object? partnerDutyGroup = freezed,
    Object? partnerAccentColorValue = freezed,
    Object? myAccentColorValue = freezed,
  }) {
    return _then(_self.copyWith(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      language: freezed == language
          ? _self.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
      calendarFormat: freezed == calendarFormat
          ? _self.calendarFormat
          : calendarFormat // ignore: cast_nullable_to_non_nullable
              as CalendarFormat?,
      activeConfigName: freezed == activeConfigName
          ? _self.activeConfigName
          : activeConfigName // ignore: cast_nullable_to_non_nullable
              as String?,
      myDutyGroup: freezed == myDutyGroup
          ? _self.myDutyGroup
          : myDutyGroup // ignore: cast_nullable_to_non_nullable
              as String?,
      themePreference: freezed == themePreference
          ? _self.themePreference
          : themePreference // ignore: cast_nullable_to_non_nullable
              as ThemePreference?,
      partnerConfigName: freezed == partnerConfigName
          ? _self.partnerConfigName
          : partnerConfigName // ignore: cast_nullable_to_non_nullable
              as String?,
      partnerDutyGroup: freezed == partnerDutyGroup
          ? _self.partnerDutyGroup
          : partnerDutyGroup // ignore: cast_nullable_to_non_nullable
              as String?,
      partnerAccentColorValue: freezed == partnerAccentColorValue
          ? _self.partnerAccentColorValue
          : partnerAccentColorValue // ignore: cast_nullable_to_non_nullable
              as int?,
      myAccentColorValue: freezed == myAccentColorValue
          ? _self.myAccentColorValue
          : myAccentColorValue // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// Adds pattern-matching-related methods to [SettingsUiState].
extension SettingsUiStatePatterns on SettingsUiState {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_SettingsUiState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SettingsUiState() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_SettingsUiState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SettingsUiState():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_SettingsUiState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SettingsUiState() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            bool isLoading,
            String? error,
            String? language,
            CalendarFormat? calendarFormat,
            String? activeConfigName,
            String? myDutyGroup,
            ThemePreference? themePreference,
            String? partnerConfigName,
            String? partnerDutyGroup,
            int? partnerAccentColorValue,
            int? myAccentColorValue)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SettingsUiState() when $default != null:
        return $default(
            _that.isLoading,
            _that.error,
            _that.language,
            _that.calendarFormat,
            _that.activeConfigName,
            _that.myDutyGroup,
            _that.themePreference,
            _that.partnerConfigName,
            _that.partnerDutyGroup,
            _that.partnerAccentColorValue,
            _that.myAccentColorValue);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            bool isLoading,
            String? error,
            String? language,
            CalendarFormat? calendarFormat,
            String? activeConfigName,
            String? myDutyGroup,
            ThemePreference? themePreference,
            String? partnerConfigName,
            String? partnerDutyGroup,
            int? partnerAccentColorValue,
            int? myAccentColorValue)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SettingsUiState():
        return $default(
            _that.isLoading,
            _that.error,
            _that.language,
            _that.calendarFormat,
            _that.activeConfigName,
            _that.myDutyGroup,
            _that.themePreference,
            _that.partnerConfigName,
            _that.partnerDutyGroup,
            _that.partnerAccentColorValue,
            _that.myAccentColorValue);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            bool isLoading,
            String? error,
            String? language,
            CalendarFormat? calendarFormat,
            String? activeConfigName,
            String? myDutyGroup,
            ThemePreference? themePreference,
            String? partnerConfigName,
            String? partnerDutyGroup,
            int? partnerAccentColorValue,
            int? myAccentColorValue)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SettingsUiState() when $default != null:
        return $default(
            _that.isLoading,
            _that.error,
            _that.language,
            _that.calendarFormat,
            _that.activeConfigName,
            _that.myDutyGroup,
            _that.themePreference,
            _that.partnerConfigName,
            _that.partnerDutyGroup,
            _that.partnerAccentColorValue,
            _that.myAccentColorValue);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _SettingsUiState extends SettingsUiState {
  const _SettingsUiState(
      {required this.isLoading,
      this.error,
      this.language,
      this.calendarFormat,
      this.activeConfigName,
      this.myDutyGroup,
      this.themePreference,
      this.partnerConfigName,
      this.partnerDutyGroup,
      this.partnerAccentColorValue,
      this.myAccentColorValue})
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
  final ThemePreference? themePreference;
// Partner duty group UI values
  @override
  final String? partnerConfigName;
  @override
  final String? partnerDutyGroup;
  @override
  final int? partnerAccentColorValue;
// My accent color UI value
  @override
  final int? myAccentColorValue;

  /// Create a copy of SettingsUiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SettingsUiStateCopyWith<_SettingsUiState> get copyWith =>
      __$SettingsUiStateCopyWithImpl<_SettingsUiState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SettingsUiState &&
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
                other.myDutyGroup == myDutyGroup) &&
            (identical(other.themePreference, themePreference) ||
                other.themePreference == themePreference) &&
            (identical(other.partnerConfigName, partnerConfigName) ||
                other.partnerConfigName == partnerConfigName) &&
            (identical(other.partnerDutyGroup, partnerDutyGroup) ||
                other.partnerDutyGroup == partnerDutyGroup) &&
            (identical(
                    other.partnerAccentColorValue, partnerAccentColorValue) ||
                other.partnerAccentColorValue == partnerAccentColorValue) &&
            (identical(other.myAccentColorValue, myAccentColorValue) ||
                other.myAccentColorValue == myAccentColorValue));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isLoading,
      error,
      language,
      calendarFormat,
      activeConfigName,
      myDutyGroup,
      themePreference,
      partnerConfigName,
      partnerDutyGroup,
      partnerAccentColorValue,
      myAccentColorValue);

  @override
  String toString() {
    return 'SettingsUiState(isLoading: $isLoading, error: $error, language: $language, calendarFormat: $calendarFormat, activeConfigName: $activeConfigName, myDutyGroup: $myDutyGroup, themePreference: $themePreference, partnerConfigName: $partnerConfigName, partnerDutyGroup: $partnerDutyGroup, partnerAccentColorValue: $partnerAccentColorValue, myAccentColorValue: $myAccentColorValue)';
  }
}

/// @nodoc
abstract mixin class _$SettingsUiStateCopyWith<$Res>
    implements $SettingsUiStateCopyWith<$Res> {
  factory _$SettingsUiStateCopyWith(
          _SettingsUiState value, $Res Function(_SettingsUiState) _then) =
      __$SettingsUiStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      String? error,
      String? language,
      CalendarFormat? calendarFormat,
      String? activeConfigName,
      String? myDutyGroup,
      ThemePreference? themePreference,
      String? partnerConfigName,
      String? partnerDutyGroup,
      int? partnerAccentColorValue,
      int? myAccentColorValue});
}

/// @nodoc
class __$SettingsUiStateCopyWithImpl<$Res>
    implements _$SettingsUiStateCopyWith<$Res> {
  __$SettingsUiStateCopyWithImpl(this._self, this._then);

  final _SettingsUiState _self;
  final $Res Function(_SettingsUiState) _then;

  /// Create a copy of SettingsUiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? language = freezed,
    Object? calendarFormat = freezed,
    Object? activeConfigName = freezed,
    Object? myDutyGroup = freezed,
    Object? themePreference = freezed,
    Object? partnerConfigName = freezed,
    Object? partnerDutyGroup = freezed,
    Object? partnerAccentColorValue = freezed,
    Object? myAccentColorValue = freezed,
  }) {
    return _then(_SettingsUiState(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      language: freezed == language
          ? _self.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
      calendarFormat: freezed == calendarFormat
          ? _self.calendarFormat
          : calendarFormat // ignore: cast_nullable_to_non_nullable
              as CalendarFormat?,
      activeConfigName: freezed == activeConfigName
          ? _self.activeConfigName
          : activeConfigName // ignore: cast_nullable_to_non_nullable
              as String?,
      myDutyGroup: freezed == myDutyGroup
          ? _self.myDutyGroup
          : myDutyGroup // ignore: cast_nullable_to_non_nullable
              as String?,
      themePreference: freezed == themePreference
          ? _self.themePreference
          : themePreference // ignore: cast_nullable_to_non_nullable
              as ThemePreference?,
      partnerConfigName: freezed == partnerConfigName
          ? _self.partnerConfigName
          : partnerConfigName // ignore: cast_nullable_to_non_nullable
              as String?,
      partnerDutyGroup: freezed == partnerDutyGroup
          ? _self.partnerDutyGroup
          : partnerDutyGroup // ignore: cast_nullable_to_non_nullable
              as String?,
      partnerAccentColorValue: freezed == partnerAccentColorValue
          ? _self.partnerAccentColorValue
          : partnerAccentColorValue // ignore: cast_nullable_to_non_nullable
              as int?,
      myAccentColorValue: freezed == myAccentColorValue
          ? _self.myAccentColorValue
          : myAccentColorValue // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

// dart format on
