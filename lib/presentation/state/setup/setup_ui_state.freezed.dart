// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'setup_ui_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SetupUiState {
  bool get isLoading;
  bool get isGeneratingSchedules;
  bool get isSetupCompleted;
  String? get error;
  StackTrace? get errorStackTrace;
  int get currentStep;
  ThemePreference get selectedTheme;
  DutyScheduleConfig? get selectedConfig;
  String? get selectedDutyGroup;
  DutyScheduleConfig? get selectedPartnerConfig;
  String? get selectedPartnerDutyGroup;
  List<DutyScheduleConfig> get configs;

  /// Create a copy of SetupUiState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SetupUiStateCopyWith<SetupUiState> get copyWith =>
      _$SetupUiStateCopyWithImpl<SetupUiState>(
          this as SetupUiState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SetupUiState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isGeneratingSchedules, isGeneratingSchedules) ||
                other.isGeneratingSchedules == isGeneratingSchedules) &&
            (identical(other.isSetupCompleted, isSetupCompleted) ||
                other.isSetupCompleted == isSetupCompleted) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.errorStackTrace, errorStackTrace) ||
                other.errorStackTrace == errorStackTrace) &&
            (identical(other.currentStep, currentStep) ||
                other.currentStep == currentStep) &&
            (identical(other.selectedTheme, selectedTheme) ||
                other.selectedTheme == selectedTheme) &&
            (identical(other.selectedConfig, selectedConfig) ||
                other.selectedConfig == selectedConfig) &&
            (identical(other.selectedDutyGroup, selectedDutyGroup) ||
                other.selectedDutyGroup == selectedDutyGroup) &&
            (identical(other.selectedPartnerConfig, selectedPartnerConfig) ||
                other.selectedPartnerConfig == selectedPartnerConfig) &&
            (identical(
                    other.selectedPartnerDutyGroup, selectedPartnerDutyGroup) ||
                other.selectedPartnerDutyGroup == selectedPartnerDutyGroup) &&
            const DeepCollectionEquality().equals(other.configs, configs));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isLoading,
      isGeneratingSchedules,
      isSetupCompleted,
      error,
      errorStackTrace,
      currentStep,
      selectedTheme,
      selectedConfig,
      selectedDutyGroup,
      selectedPartnerConfig,
      selectedPartnerDutyGroup,
      const DeepCollectionEquality().hash(configs));

  @override
  String toString() {
    return 'SetupUiState(isLoading: $isLoading, isGeneratingSchedules: $isGeneratingSchedules, isSetupCompleted: $isSetupCompleted, error: $error, errorStackTrace: $errorStackTrace, currentStep: $currentStep, selectedTheme: $selectedTheme, selectedConfig: $selectedConfig, selectedDutyGroup: $selectedDutyGroup, selectedPartnerConfig: $selectedPartnerConfig, selectedPartnerDutyGroup: $selectedPartnerDutyGroup, configs: $configs)';
  }
}

/// @nodoc
abstract mixin class $SetupUiStateCopyWith<$Res> {
  factory $SetupUiStateCopyWith(
          SetupUiState value, $Res Function(SetupUiState) _then) =
      _$SetupUiStateCopyWithImpl;
  @useResult
  $Res call(
      {bool isLoading,
      bool isGeneratingSchedules,
      bool isSetupCompleted,
      String? error,
      StackTrace? errorStackTrace,
      int currentStep,
      ThemePreference selectedTheme,
      DutyScheduleConfig? selectedConfig,
      String? selectedDutyGroup,
      DutyScheduleConfig? selectedPartnerConfig,
      String? selectedPartnerDutyGroup,
      List<DutyScheduleConfig> configs});

  $DutyScheduleConfigCopyWith<$Res>? get selectedConfig;
  $DutyScheduleConfigCopyWith<$Res>? get selectedPartnerConfig;
}

/// @nodoc
class _$SetupUiStateCopyWithImpl<$Res> implements $SetupUiStateCopyWith<$Res> {
  _$SetupUiStateCopyWithImpl(this._self, this._then);

  final SetupUiState _self;
  final $Res Function(SetupUiState) _then;

  /// Create a copy of SetupUiState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isGeneratingSchedules = null,
    Object? isSetupCompleted = null,
    Object? error = freezed,
    Object? errorStackTrace = freezed,
    Object? currentStep = null,
    Object? selectedTheme = null,
    Object? selectedConfig = freezed,
    Object? selectedDutyGroup = freezed,
    Object? selectedPartnerConfig = freezed,
    Object? selectedPartnerDutyGroup = freezed,
    Object? configs = null,
  }) {
    return _then(_self.copyWith(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isGeneratingSchedules: null == isGeneratingSchedules
          ? _self.isGeneratingSchedules
          : isGeneratingSchedules // ignore: cast_nullable_to_non_nullable
              as bool,
      isSetupCompleted: null == isSetupCompleted
          ? _self.isSetupCompleted
          : isSetupCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      errorStackTrace: freezed == errorStackTrace
          ? _self.errorStackTrace
          : errorStackTrace // ignore: cast_nullable_to_non_nullable
              as StackTrace?,
      currentStep: null == currentStep
          ? _self.currentStep
          : currentStep // ignore: cast_nullable_to_non_nullable
              as int,
      selectedTheme: null == selectedTheme
          ? _self.selectedTheme
          : selectedTheme // ignore: cast_nullable_to_non_nullable
              as ThemePreference,
      selectedConfig: freezed == selectedConfig
          ? _self.selectedConfig
          : selectedConfig // ignore: cast_nullable_to_non_nullable
              as DutyScheduleConfig?,
      selectedDutyGroup: freezed == selectedDutyGroup
          ? _self.selectedDutyGroup
          : selectedDutyGroup // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedPartnerConfig: freezed == selectedPartnerConfig
          ? _self.selectedPartnerConfig
          : selectedPartnerConfig // ignore: cast_nullable_to_non_nullable
              as DutyScheduleConfig?,
      selectedPartnerDutyGroup: freezed == selectedPartnerDutyGroup
          ? _self.selectedPartnerDutyGroup
          : selectedPartnerDutyGroup // ignore: cast_nullable_to_non_nullable
              as String?,
      configs: null == configs
          ? _self.configs
          : configs // ignore: cast_nullable_to_non_nullable
              as List<DutyScheduleConfig>,
    ));
  }

  /// Create a copy of SetupUiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DutyScheduleConfigCopyWith<$Res>? get selectedConfig {
    if (_self.selectedConfig == null) {
      return null;
    }

    return $DutyScheduleConfigCopyWith<$Res>(_self.selectedConfig!, (value) {
      return _then(_self.copyWith(selectedConfig: value));
    });
  }

  /// Create a copy of SetupUiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DutyScheduleConfigCopyWith<$Res>? get selectedPartnerConfig {
    if (_self.selectedPartnerConfig == null) {
      return null;
    }

    return $DutyScheduleConfigCopyWith<$Res>(_self.selectedPartnerConfig!,
        (value) {
      return _then(_self.copyWith(selectedPartnerConfig: value));
    });
  }
}

/// Adds pattern-matching-related methods to [SetupUiState].
extension SetupUiStatePatterns on SetupUiState {
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
    TResult Function(_SetupUiState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SetupUiState() when $default != null:
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
    TResult Function(_SetupUiState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SetupUiState():
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
    TResult? Function(_SetupUiState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SetupUiState() when $default != null:
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
            bool isGeneratingSchedules,
            bool isSetupCompleted,
            String? error,
            StackTrace? errorStackTrace,
            int currentStep,
            ThemePreference selectedTheme,
            DutyScheduleConfig? selectedConfig,
            String? selectedDutyGroup,
            DutyScheduleConfig? selectedPartnerConfig,
            String? selectedPartnerDutyGroup,
            List<DutyScheduleConfig> configs)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SetupUiState() when $default != null:
        return $default(
            _that.isLoading,
            _that.isGeneratingSchedules,
            _that.isSetupCompleted,
            _that.error,
            _that.errorStackTrace,
            _that.currentStep,
            _that.selectedTheme,
            _that.selectedConfig,
            _that.selectedDutyGroup,
            _that.selectedPartnerConfig,
            _that.selectedPartnerDutyGroup,
            _that.configs);
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
            bool isGeneratingSchedules,
            bool isSetupCompleted,
            String? error,
            StackTrace? errorStackTrace,
            int currentStep,
            ThemePreference selectedTheme,
            DutyScheduleConfig? selectedConfig,
            String? selectedDutyGroup,
            DutyScheduleConfig? selectedPartnerConfig,
            String? selectedPartnerDutyGroup,
            List<DutyScheduleConfig> configs)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SetupUiState():
        return $default(
            _that.isLoading,
            _that.isGeneratingSchedules,
            _that.isSetupCompleted,
            _that.error,
            _that.errorStackTrace,
            _that.currentStep,
            _that.selectedTheme,
            _that.selectedConfig,
            _that.selectedDutyGroup,
            _that.selectedPartnerConfig,
            _that.selectedPartnerDutyGroup,
            _that.configs);
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
            bool isGeneratingSchedules,
            bool isSetupCompleted,
            String? error,
            StackTrace? errorStackTrace,
            int currentStep,
            ThemePreference selectedTheme,
            DutyScheduleConfig? selectedConfig,
            String? selectedDutyGroup,
            DutyScheduleConfig? selectedPartnerConfig,
            String? selectedPartnerDutyGroup,
            List<DutyScheduleConfig> configs)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SetupUiState() when $default != null:
        return $default(
            _that.isLoading,
            _that.isGeneratingSchedules,
            _that.isSetupCompleted,
            _that.error,
            _that.errorStackTrace,
            _that.currentStep,
            _that.selectedTheme,
            _that.selectedConfig,
            _that.selectedDutyGroup,
            _that.selectedPartnerConfig,
            _that.selectedPartnerDutyGroup,
            _that.configs);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _SetupUiState extends SetupUiState {
  const _SetupUiState(
      {required this.isLoading,
      required this.isGeneratingSchedules,
      required this.isSetupCompleted,
      this.error,
      this.errorStackTrace,
      required this.currentStep,
      required this.selectedTheme,
      this.selectedConfig,
      this.selectedDutyGroup,
      this.selectedPartnerConfig,
      this.selectedPartnerDutyGroup,
      required final List<DutyScheduleConfig> configs})
      : _configs = configs,
        super._();

  @override
  final bool isLoading;
  @override
  final bool isGeneratingSchedules;
  @override
  final bool isSetupCompleted;
  @override
  final String? error;
  @override
  final StackTrace? errorStackTrace;
  @override
  final int currentStep;
  @override
  final ThemePreference selectedTheme;
  @override
  final DutyScheduleConfig? selectedConfig;
  @override
  final String? selectedDutyGroup;
  @override
  final DutyScheduleConfig? selectedPartnerConfig;
  @override
  final String? selectedPartnerDutyGroup;
  final List<DutyScheduleConfig> _configs;
  @override
  List<DutyScheduleConfig> get configs {
    if (_configs is EqualUnmodifiableListView) return _configs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_configs);
  }

  /// Create a copy of SetupUiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SetupUiStateCopyWith<_SetupUiState> get copyWith =>
      __$SetupUiStateCopyWithImpl<_SetupUiState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SetupUiState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isGeneratingSchedules, isGeneratingSchedules) ||
                other.isGeneratingSchedules == isGeneratingSchedules) &&
            (identical(other.isSetupCompleted, isSetupCompleted) ||
                other.isSetupCompleted == isSetupCompleted) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.errorStackTrace, errorStackTrace) ||
                other.errorStackTrace == errorStackTrace) &&
            (identical(other.currentStep, currentStep) ||
                other.currentStep == currentStep) &&
            (identical(other.selectedTheme, selectedTheme) ||
                other.selectedTheme == selectedTheme) &&
            (identical(other.selectedConfig, selectedConfig) ||
                other.selectedConfig == selectedConfig) &&
            (identical(other.selectedDutyGroup, selectedDutyGroup) ||
                other.selectedDutyGroup == selectedDutyGroup) &&
            (identical(other.selectedPartnerConfig, selectedPartnerConfig) ||
                other.selectedPartnerConfig == selectedPartnerConfig) &&
            (identical(
                    other.selectedPartnerDutyGroup, selectedPartnerDutyGroup) ||
                other.selectedPartnerDutyGroup == selectedPartnerDutyGroup) &&
            const DeepCollectionEquality().equals(other._configs, _configs));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isLoading,
      isGeneratingSchedules,
      isSetupCompleted,
      error,
      errorStackTrace,
      currentStep,
      selectedTheme,
      selectedConfig,
      selectedDutyGroup,
      selectedPartnerConfig,
      selectedPartnerDutyGroup,
      const DeepCollectionEquality().hash(_configs));

  @override
  String toString() {
    return 'SetupUiState(isLoading: $isLoading, isGeneratingSchedules: $isGeneratingSchedules, isSetupCompleted: $isSetupCompleted, error: $error, errorStackTrace: $errorStackTrace, currentStep: $currentStep, selectedTheme: $selectedTheme, selectedConfig: $selectedConfig, selectedDutyGroup: $selectedDutyGroup, selectedPartnerConfig: $selectedPartnerConfig, selectedPartnerDutyGroup: $selectedPartnerDutyGroup, configs: $configs)';
  }
}

/// @nodoc
abstract mixin class _$SetupUiStateCopyWith<$Res>
    implements $SetupUiStateCopyWith<$Res> {
  factory _$SetupUiStateCopyWith(
          _SetupUiState value, $Res Function(_SetupUiState) _then) =
      __$SetupUiStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      bool isGeneratingSchedules,
      bool isSetupCompleted,
      String? error,
      StackTrace? errorStackTrace,
      int currentStep,
      ThemePreference selectedTheme,
      DutyScheduleConfig? selectedConfig,
      String? selectedDutyGroup,
      DutyScheduleConfig? selectedPartnerConfig,
      String? selectedPartnerDutyGroup,
      List<DutyScheduleConfig> configs});

  @override
  $DutyScheduleConfigCopyWith<$Res>? get selectedConfig;
  @override
  $DutyScheduleConfigCopyWith<$Res>? get selectedPartnerConfig;
}

/// @nodoc
class __$SetupUiStateCopyWithImpl<$Res>
    implements _$SetupUiStateCopyWith<$Res> {
  __$SetupUiStateCopyWithImpl(this._self, this._then);

  final _SetupUiState _self;
  final $Res Function(_SetupUiState) _then;

  /// Create a copy of SetupUiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isLoading = null,
    Object? isGeneratingSchedules = null,
    Object? isSetupCompleted = null,
    Object? error = freezed,
    Object? errorStackTrace = freezed,
    Object? currentStep = null,
    Object? selectedTheme = null,
    Object? selectedConfig = freezed,
    Object? selectedDutyGroup = freezed,
    Object? selectedPartnerConfig = freezed,
    Object? selectedPartnerDutyGroup = freezed,
    Object? configs = null,
  }) {
    return _then(_SetupUiState(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isGeneratingSchedules: null == isGeneratingSchedules
          ? _self.isGeneratingSchedules
          : isGeneratingSchedules // ignore: cast_nullable_to_non_nullable
              as bool,
      isSetupCompleted: null == isSetupCompleted
          ? _self.isSetupCompleted
          : isSetupCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      errorStackTrace: freezed == errorStackTrace
          ? _self.errorStackTrace
          : errorStackTrace // ignore: cast_nullable_to_non_nullable
              as StackTrace?,
      currentStep: null == currentStep
          ? _self.currentStep
          : currentStep // ignore: cast_nullable_to_non_nullable
              as int,
      selectedTheme: null == selectedTheme
          ? _self.selectedTheme
          : selectedTheme // ignore: cast_nullable_to_non_nullable
              as ThemePreference,
      selectedConfig: freezed == selectedConfig
          ? _self.selectedConfig
          : selectedConfig // ignore: cast_nullable_to_non_nullable
              as DutyScheduleConfig?,
      selectedDutyGroup: freezed == selectedDutyGroup
          ? _self.selectedDutyGroup
          : selectedDutyGroup // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedPartnerConfig: freezed == selectedPartnerConfig
          ? _self.selectedPartnerConfig
          : selectedPartnerConfig // ignore: cast_nullable_to_non_nullable
              as DutyScheduleConfig?,
      selectedPartnerDutyGroup: freezed == selectedPartnerDutyGroup
          ? _self.selectedPartnerDutyGroup
          : selectedPartnerDutyGroup // ignore: cast_nullable_to_non_nullable
              as String?,
      configs: null == configs
          ? _self._configs
          : configs // ignore: cast_nullable_to_non_nullable
              as List<DutyScheduleConfig>,
    ));
  }

  /// Create a copy of SetupUiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DutyScheduleConfigCopyWith<$Res>? get selectedConfig {
    if (_self.selectedConfig == null) {
      return null;
    }

    return $DutyScheduleConfigCopyWith<$Res>(_self.selectedConfig!, (value) {
      return _then(_self.copyWith(selectedConfig: value));
    });
  }

  /// Create a copy of SetupUiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DutyScheduleConfigCopyWith<$Res>? get selectedPartnerConfig {
    if (_self.selectedPartnerConfig == null) {
      return null;
    }

    return $DutyScheduleConfigCopyWith<$Res>(_self.selectedPartnerConfig!,
        (value) {
      return _then(_self.copyWith(selectedPartnerConfig: value));
    });
  }
}

// dart format on
