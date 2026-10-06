// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'config_ui_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConfigUiState {
  bool get isLoading;
  String? get error;
  String? get activeConfigName;
  List<String> get dutyGroups;
  List<DutyScheduleConfig> get configs;
  DutyScheduleConfig? get activeConfig;

  /// Create a copy of ConfigUiState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ConfigUiStateCopyWith<ConfigUiState> get copyWith =>
      _$ConfigUiStateCopyWithImpl<ConfigUiState>(
        this as ConfigUiState,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    final _this = this as ConfigUiState;
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ConfigUiState &&
            (identical(other.isLoading, _this.isLoading) ||
                other.isLoading == _this.isLoading) &&
            (identical(other.error, _this.error) ||
                other.error == _this.error) &&
            (identical(other.activeConfigName, _this.activeConfigName) ||
                other.activeConfigName == _this.activeConfigName) &&
            const DeepCollectionEquality().equals(
              other.dutyGroups,
              _this.dutyGroups,
            ) &&
            const DeepCollectionEquality().equals(
              other.configs,
              _this.configs,
            ) &&
            (identical(other.activeConfig, _this.activeConfig) ||
                other.activeConfig == _this.activeConfig));
  }

  @override
  int get hashCode {
    final _this = this as ConfigUiState;
    return Object.hash(
      runtimeType,
      _this.isLoading,
      _this.error,
      _this.activeConfigName,
      const DeepCollectionEquality().hash(_this.dutyGroups),
      const DeepCollectionEquality().hash(_this.configs),
      _this.activeConfig,
    );
  }

  @override
  String toString() {
    final _this = this as ConfigUiState;
    return 'ConfigUiState(isLoading: ${_this.isLoading}, error: ${_this.error}, activeConfigName: ${_this.activeConfigName}, dutyGroups: ${_this.dutyGroups}, configs: ${_this.configs}, activeConfig: ${_this.activeConfig})';
  }
}

/// @nodoc
abstract mixin class $ConfigUiStateCopyWith<$Res> {
  factory $ConfigUiStateCopyWith(
    ConfigUiState value,
    $Res Function(ConfigUiState) _then,
  ) = _$ConfigUiStateCopyWithImpl;
  @useResult
  $Res call({
    bool isLoading,
    String? error,
    String? activeConfigName,
    List<String> dutyGroups,
    List<DutyScheduleConfig> configs,
    DutyScheduleConfig? activeConfig,
  });

  $DutyScheduleConfigCopyWith<$Res>? get activeConfig;
}

/// @nodoc
class _$ConfigUiStateCopyWithImpl<$Res>
    implements $ConfigUiStateCopyWith<$Res> {
  _$ConfigUiStateCopyWithImpl(this._self, this._then);

  final ConfigUiState _self;
  final $Res Function(ConfigUiState) _then;

  /// Create a copy of ConfigUiState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? activeConfigName = freezed,
    Object? dutyGroups = null,
    Object? configs = null,
    Object? activeConfig = freezed,
  }) {
    return _then(
      ConfigUiState(
        isLoading: null == isLoading
            ? _self.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _self.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        activeConfigName: freezed == activeConfigName
            ? _self.activeConfigName
            : activeConfigName // ignore: cast_nullable_to_non_nullable
                  as String?,
        dutyGroups: null == dutyGroups
            ? _self.dutyGroups
            : dutyGroups // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        configs: null == configs
            ? _self.configs
            : configs // ignore: cast_nullable_to_non_nullable
                  as List<DutyScheduleConfig>,
        activeConfig: freezed == activeConfig
            ? _self.activeConfig
            : activeConfig // ignore: cast_nullable_to_non_nullable
                  as DutyScheduleConfig?,
      ),
    );
  }

  /// Create a copy of ConfigUiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DutyScheduleConfigCopyWith<$Res>? get activeConfig {
    if (_self.activeConfig == null) {
      return null;
    }

    return $DutyScheduleConfigCopyWith<$Res>(_self.activeConfig!, (value) {
      return _then(_self.copyWith(activeConfig: value));
    });
  }
}

/// Adds pattern-matching-related methods to [ConfigUiState].
extension ConfigUiStatePatterns on ConfigUiState {
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
    TResult Function(_ConfigUiState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ConfigUiState() when $default != null:
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
    TResult Function(_ConfigUiState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ConfigUiState():
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
    TResult? Function(_ConfigUiState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ConfigUiState() when $default != null:
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
      String? activeConfigName,
      List<String> dutyGroups,
      List<DutyScheduleConfig> configs,
      DutyScheduleConfig? activeConfig,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ConfigUiState() when $default != null:
        return $default(
          _that.isLoading,
          _that.error,
          _that.activeConfigName,
          _that.dutyGroups,
          _that.configs,
          _that.activeConfig,
        );
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
      String? activeConfigName,
      List<String> dutyGroups,
      List<DutyScheduleConfig> configs,
      DutyScheduleConfig? activeConfig,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ConfigUiState():
        return $default(
          _that.isLoading,
          _that.error,
          _that.activeConfigName,
          _that.dutyGroups,
          _that.configs,
          _that.activeConfig,
        );
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
      String? activeConfigName,
      List<String> dutyGroups,
      List<DutyScheduleConfig> configs,
      DutyScheduleConfig? activeConfig,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ConfigUiState() when $default != null:
        return $default(
          _that.isLoading,
          _that.error,
          _that.activeConfigName,
          _that.dutyGroups,
          _that.configs,
          _that.activeConfig,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ConfigUiState extends ConfigUiState {
  const _ConfigUiState({
    required this.isLoading,
    this.error,
    this.activeConfigName,
    List<String> dutyGroups = const <String>[],
    List<DutyScheduleConfig> configs = const <DutyScheduleConfig>[],
    this.activeConfig,
  }) : _dutyGroups = dutyGroups,
       _configs = configs,
       super._();

  @override
  final bool isLoading;
  @override
  final String? error;
  @override
  final String? activeConfigName;
  final List<String> _dutyGroups;
  @override
  @JsonKey()
  List<String> get dutyGroups {
    if (_dutyGroups is EqualUnmodifiableListView) return _dutyGroups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dutyGroups);
  }

  final List<DutyScheduleConfig> _configs;
  @override
  @JsonKey()
  List<DutyScheduleConfig> get configs {
    if (_configs is EqualUnmodifiableListView) return _configs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_configs);
  }

  @override
  final DutyScheduleConfig? activeConfig;

  /// Create a copy of ConfigUiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ConfigUiStateCopyWith<_ConfigUiState> get copyWith =>
      __$ConfigUiStateCopyWithImpl<_ConfigUiState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ConfigUiState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.activeConfigName, activeConfigName) ||
                other.activeConfigName == activeConfigName) &&
            const DeepCollectionEquality().equals(
              other.dutyGroups,
              _dutyGroups,
            ) &&
            const DeepCollectionEquality().equals(other.configs, _configs) &&
            (identical(other.activeConfig, activeConfig) ||
                other.activeConfig == activeConfig));
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      isLoading,
      error,
      activeConfigName,
      const DeepCollectionEquality().hash(_dutyGroups),
      const DeepCollectionEquality().hash(_configs),
      activeConfig,
    );
  }

  @override
  String toString() {
    return 'ConfigUiState(isLoading: $isLoading, error: $error, activeConfigName: $activeConfigName, dutyGroups: $dutyGroups, configs: $configs, activeConfig: $activeConfig)';
  }
}

/// @nodoc
abstract mixin class _$ConfigUiStateCopyWith<$Res>
    implements $ConfigUiStateCopyWith<$Res> {
  factory _$ConfigUiStateCopyWith(
    _ConfigUiState value,
    $Res Function(_ConfigUiState) _then,
  ) = __$ConfigUiStateCopyWithImpl;
  @override
  @useResult
  $Res call({
    bool isLoading,
    String? error,
    String? activeConfigName,
    List<String> dutyGroups,
    List<DutyScheduleConfig> configs,
    DutyScheduleConfig? activeConfig,
  });

  @override
  $DutyScheduleConfigCopyWith<$Res>? get activeConfig;
}

/// @nodoc
class __$ConfigUiStateCopyWithImpl<$Res>
    implements _$ConfigUiStateCopyWith<$Res> {
  __$ConfigUiStateCopyWithImpl(this._self, this._then);

  final _ConfigUiState _self;
  final $Res Function(_ConfigUiState) _then;

  /// Create a copy of ConfigUiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? activeConfigName = freezed,
    Object? dutyGroups = null,
    Object? configs = null,
    Object? activeConfig = freezed,
  }) {
    return _then(
      _ConfigUiState(
        isLoading: null == isLoading
            ? _self.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _self.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        activeConfigName: freezed == activeConfigName
            ? _self.activeConfigName
            : activeConfigName // ignore: cast_nullable_to_non_nullable
                  as String?,
        dutyGroups: null == dutyGroups
            ? _self._dutyGroups
            : dutyGroups // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        configs: null == configs
            ? _self._configs
            : configs // ignore: cast_nullable_to_non_nullable
                  as List<DutyScheduleConfig>,
        activeConfig: freezed == activeConfig
            ? _self.activeConfig
            : activeConfig // ignore: cast_nullable_to_non_nullable
                  as DutyScheduleConfig?,
      ),
    );
  }

  /// Create a copy of ConfigUiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DutyScheduleConfigCopyWith<$Res>? get activeConfig {
    if (_self.activeConfig == null) {
      return null;
    }

    return $DutyScheduleConfigCopyWith<$Res>(_self.activeConfig!, (value) {
      return _then(_self.copyWith(activeConfig: value));
    });
  }
}
