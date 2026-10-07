// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule_ui_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ScheduleUiState {
  bool get isLoading;
  String? get error;
  String? get partnerError;
  DateTime? get selectedDay;
  DateTime? get focusedDay;
  List<Schedule> get schedules;
  String? get activeConfigName;
  String? get preferredDutyGroup;
  List<String> get dutyGroups;
  List<DutyScheduleConfig> get configs;
  DutyScheduleConfig? get activeConfig;
  String? get partnerConfigName;
  String? get partnerDutyGroup;
  int? get partnerAccentColorValue;
  int? get myAccentColorValue;
  int? get holidayAccentColorValue;
  ScheduleIndex get scheduleIndex;

  /// Create a copy of ScheduleUiState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ScheduleUiStateCopyWith<ScheduleUiState> get copyWith =>
      _$ScheduleUiStateCopyWithImpl<ScheduleUiState>(
        this as ScheduleUiState,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    final _this = this as ScheduleUiState;
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ScheduleUiState &&
            (identical(other.isLoading, _this.isLoading) ||
                other.isLoading == _this.isLoading) &&
            (identical(other.error, _this.error) ||
                other.error == _this.error) &&
            (identical(other.partnerError, _this.partnerError) ||
                other.partnerError == _this.partnerError) &&
            (identical(other.selectedDay, _this.selectedDay) ||
                other.selectedDay == _this.selectedDay) &&
            (identical(other.focusedDay, _this.focusedDay) ||
                other.focusedDay == _this.focusedDay) &&
            const DeepCollectionEquality().equals(
              other.schedules,
              _this.schedules,
            ) &&
            (identical(other.activeConfigName, _this.activeConfigName) ||
                other.activeConfigName == _this.activeConfigName) &&
            (identical(other.preferredDutyGroup, _this.preferredDutyGroup) ||
                other.preferredDutyGroup == _this.preferredDutyGroup) &&
            const DeepCollectionEquality().equals(
              other.dutyGroups,
              _this.dutyGroups,
            ) &&
            const DeepCollectionEquality().equals(
              other.configs,
              _this.configs,
            ) &&
            (identical(other.activeConfig, _this.activeConfig) ||
                other.activeConfig == _this.activeConfig) &&
            (identical(other.partnerConfigName, _this.partnerConfigName) ||
                other.partnerConfigName == _this.partnerConfigName) &&
            (identical(other.partnerDutyGroup, _this.partnerDutyGroup) ||
                other.partnerDutyGroup == _this.partnerDutyGroup) &&
            (identical(
                  other.partnerAccentColorValue,
                  _this.partnerAccentColorValue,
                ) ||
                other.partnerAccentColorValue ==
                    _this.partnerAccentColorValue) &&
            (identical(other.myAccentColorValue, _this.myAccentColorValue) ||
                other.myAccentColorValue == _this.myAccentColorValue) &&
            (identical(
                  other.holidayAccentColorValue,
                  _this.holidayAccentColorValue,
                ) ||
                other.holidayAccentColorValue ==
                    _this.holidayAccentColorValue) &&
            (identical(other.scheduleIndex, _this.scheduleIndex) ||
                other.scheduleIndex == _this.scheduleIndex));
  }

  @override
  int get hashCode {
    final _this = this as ScheduleUiState;
    return Object.hash(
      runtimeType,
      _this.isLoading,
      _this.error,
      _this.partnerError,
      _this.selectedDay,
      _this.focusedDay,
      const DeepCollectionEquality().hash(_this.schedules),
      _this.activeConfigName,
      _this.preferredDutyGroup,
      const DeepCollectionEquality().hash(_this.dutyGroups),
      const DeepCollectionEquality().hash(_this.configs),
      _this.activeConfig,
      _this.partnerConfigName,
      _this.partnerDutyGroup,
      _this.partnerAccentColorValue,
      _this.myAccentColorValue,
      _this.holidayAccentColorValue,
      _this.scheduleIndex,
    );
  }

  @override
  String toString() {
    final _this = this as ScheduleUiState;
    return 'ScheduleUiState(isLoading: ${_this.isLoading}, error: ${_this.error}, partnerError: ${_this.partnerError}, selectedDay: ${_this.selectedDay}, focusedDay: ${_this.focusedDay}, schedules: ${_this.schedules}, activeConfigName: ${_this.activeConfigName}, preferredDutyGroup: ${_this.preferredDutyGroup}, dutyGroups: ${_this.dutyGroups}, configs: ${_this.configs}, activeConfig: ${_this.activeConfig}, partnerConfigName: ${_this.partnerConfigName}, partnerDutyGroup: ${_this.partnerDutyGroup}, partnerAccentColorValue: ${_this.partnerAccentColorValue}, myAccentColorValue: ${_this.myAccentColorValue}, holidayAccentColorValue: ${_this.holidayAccentColorValue}, scheduleIndex: ${_this.scheduleIndex})';
  }
}

/// @nodoc
abstract mixin class $ScheduleUiStateCopyWith<$Res> {
  factory $ScheduleUiStateCopyWith(
    ScheduleUiState value,
    $Res Function(ScheduleUiState) _then,
  ) = _$ScheduleUiStateCopyWithImpl;
  @useResult
  $Res call({
    bool isLoading,
    String? error,
    String? partnerError,
    DateTime? selectedDay,
    DateTime? focusedDay,
    List<Schedule> schedules,
    String? activeConfigName,
    String? preferredDutyGroup,
    List<String> dutyGroups,
    List<DutyScheduleConfig> configs,
    DutyScheduleConfig? activeConfig,
    String? partnerConfigName,
    String? partnerDutyGroup,
    int? partnerAccentColorValue,
    int? myAccentColorValue,
    int? holidayAccentColorValue,
    ScheduleIndex scheduleIndex,
  });

  $DutyScheduleConfigCopyWith<$Res>? get activeConfig;
}

/// @nodoc
class _$ScheduleUiStateCopyWithImpl<$Res>
    implements $ScheduleUiStateCopyWith<$Res> {
  _$ScheduleUiStateCopyWithImpl(this._self, this._then);

  final ScheduleUiState _self;
  final $Res Function(ScheduleUiState) _then;

  /// Create a copy of ScheduleUiState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? partnerError = freezed,
    Object? selectedDay = freezed,
    Object? focusedDay = freezed,
    Object? schedules = null,
    Object? activeConfigName = freezed,
    Object? preferredDutyGroup = freezed,
    Object? dutyGroups = null,
    Object? configs = null,
    Object? activeConfig = freezed,
    Object? partnerConfigName = freezed,
    Object? partnerDutyGroup = freezed,
    Object? partnerAccentColorValue = freezed,
    Object? myAccentColorValue = freezed,
    Object? holidayAccentColorValue = freezed,
    Object? scheduleIndex = null,
  }) {
    return _then(
      ScheduleUiState(
        isLoading: null == isLoading
            ? _self.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _self.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        partnerError: freezed == partnerError
            ? _self.partnerError
            : partnerError // ignore: cast_nullable_to_non_nullable
                  as String?,
        selectedDay: freezed == selectedDay
            ? _self.selectedDay
            : selectedDay // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        focusedDay: freezed == focusedDay
            ? _self.focusedDay
            : focusedDay // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        schedules: null == schedules
            ? _self.schedules
            : schedules // ignore: cast_nullable_to_non_nullable
                  as List<Schedule>,
        activeConfigName: freezed == activeConfigName
            ? _self.activeConfigName
            : activeConfigName // ignore: cast_nullable_to_non_nullable
                  as String?,
        preferredDutyGroup: freezed == preferredDutyGroup
            ? _self.preferredDutyGroup
            : preferredDutyGroup // ignore: cast_nullable_to_non_nullable
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
        holidayAccentColorValue: freezed == holidayAccentColorValue
            ? _self.holidayAccentColorValue
            : holidayAccentColorValue // ignore: cast_nullable_to_non_nullable
                  as int?,
        scheduleIndex: null == scheduleIndex
            ? _self.scheduleIndex
            : scheduleIndex // ignore: cast_nullable_to_non_nullable
                  as ScheduleIndex,
      ),
    );
  }

  /// Create a copy of ScheduleUiState
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

/// Adds pattern-matching-related methods to [ScheduleUiState].
extension ScheduleUiStatePatterns on ScheduleUiState {
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
    TResult Function(_ScheduleUiState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ScheduleUiState() when $default != null:
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
    TResult Function(_ScheduleUiState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleUiState():
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
    TResult? Function(_ScheduleUiState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleUiState() when $default != null:
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
      String? partnerError,
      DateTime? selectedDay,
      DateTime? focusedDay,
      List<Schedule> schedules,
      String? activeConfigName,
      String? preferredDutyGroup,
      List<String> dutyGroups,
      List<DutyScheduleConfig> configs,
      DutyScheduleConfig? activeConfig,
      String? partnerConfigName,
      String? partnerDutyGroup,
      int? partnerAccentColorValue,
      int? myAccentColorValue,
      int? holidayAccentColorValue,
      ScheduleIndex scheduleIndex,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ScheduleUiState() when $default != null:
        return $default(
          _that.isLoading,
          _that.error,
          _that.partnerError,
          _that.selectedDay,
          _that.focusedDay,
          _that.schedules,
          _that.activeConfigName,
          _that.preferredDutyGroup,
          _that.dutyGroups,
          _that.configs,
          _that.activeConfig,
          _that.partnerConfigName,
          _that.partnerDutyGroup,
          _that.partnerAccentColorValue,
          _that.myAccentColorValue,
          _that.holidayAccentColorValue,
          _that.scheduleIndex,
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
      String? partnerError,
      DateTime? selectedDay,
      DateTime? focusedDay,
      List<Schedule> schedules,
      String? activeConfigName,
      String? preferredDutyGroup,
      List<String> dutyGroups,
      List<DutyScheduleConfig> configs,
      DutyScheduleConfig? activeConfig,
      String? partnerConfigName,
      String? partnerDutyGroup,
      int? partnerAccentColorValue,
      int? myAccentColorValue,
      int? holidayAccentColorValue,
      ScheduleIndex scheduleIndex,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleUiState():
        return $default(
          _that.isLoading,
          _that.error,
          _that.partnerError,
          _that.selectedDay,
          _that.focusedDay,
          _that.schedules,
          _that.activeConfigName,
          _that.preferredDutyGroup,
          _that.dutyGroups,
          _that.configs,
          _that.activeConfig,
          _that.partnerConfigName,
          _that.partnerDutyGroup,
          _that.partnerAccentColorValue,
          _that.myAccentColorValue,
          _that.holidayAccentColorValue,
          _that.scheduleIndex,
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
      String? partnerError,
      DateTime? selectedDay,
      DateTime? focusedDay,
      List<Schedule> schedules,
      String? activeConfigName,
      String? preferredDutyGroup,
      List<String> dutyGroups,
      List<DutyScheduleConfig> configs,
      DutyScheduleConfig? activeConfig,
      String? partnerConfigName,
      String? partnerDutyGroup,
      int? partnerAccentColorValue,
      int? myAccentColorValue,
      int? holidayAccentColorValue,
      ScheduleIndex scheduleIndex,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleUiState() when $default != null:
        return $default(
          _that.isLoading,
          _that.error,
          _that.partnerError,
          _that.selectedDay,
          _that.focusedDay,
          _that.schedules,
          _that.activeConfigName,
          _that.preferredDutyGroup,
          _that.dutyGroups,
          _that.configs,
          _that.activeConfig,
          _that.partnerConfigName,
          _that.partnerDutyGroup,
          _that.partnerAccentColorValue,
          _that.myAccentColorValue,
          _that.holidayAccentColorValue,
          _that.scheduleIndex,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ScheduleUiState extends ScheduleUiState {
  const _ScheduleUiState({
    required this.isLoading,
    this.error,
    this.partnerError,
    this.selectedDay,
    this.focusedDay,
    List<Schedule> schedules = const <Schedule>[],
    this.activeConfigName,
    this.preferredDutyGroup,
    List<String> dutyGroups = const <String>[],
    List<DutyScheduleConfig> configs = const <DutyScheduleConfig>[],
    this.activeConfig,
    this.partnerConfigName,
    this.partnerDutyGroup,
    this.partnerAccentColorValue,
    this.myAccentColorValue,
    this.holidayAccentColorValue,
    this.scheduleIndex = const ScheduleIndex(),
  }) : _schedules = schedules,
       _dutyGroups = dutyGroups,
       _configs = configs,
       super._();

  @override
  final bool isLoading;
  @override
  final String? error;
  @override
  final String? partnerError;
  @override
  final DateTime? selectedDay;
  @override
  final DateTime? focusedDay;
  final List<Schedule> _schedules;
  @override
  @JsonKey()
  List<Schedule> get schedules {
    if (_schedules is EqualUnmodifiableListView) return _schedules;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_schedules);
  }

  @override
  final String? activeConfigName;
  @override
  final String? preferredDutyGroup;
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
  @override
  final String? partnerConfigName;
  @override
  final String? partnerDutyGroup;
  @override
  final int? partnerAccentColorValue;
  @override
  final int? myAccentColorValue;
  @override
  final int? holidayAccentColorValue;
  @override
  @JsonKey()
  final ScheduleIndex scheduleIndex;

  /// Create a copy of ScheduleUiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ScheduleUiStateCopyWith<_ScheduleUiState> get copyWith =>
      __$ScheduleUiStateCopyWithImpl<_ScheduleUiState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ScheduleUiState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.partnerError, partnerError) ||
                other.partnerError == partnerError) &&
            (identical(other.selectedDay, selectedDay) ||
                other.selectedDay == selectedDay) &&
            (identical(other.focusedDay, focusedDay) ||
                other.focusedDay == focusedDay) &&
            const DeepCollectionEquality().equals(
              other.schedules,
              _schedules,
            ) &&
            (identical(other.activeConfigName, activeConfigName) ||
                other.activeConfigName == activeConfigName) &&
            (identical(other.preferredDutyGroup, preferredDutyGroup) ||
                other.preferredDutyGroup == preferredDutyGroup) &&
            const DeepCollectionEquality().equals(
              other.dutyGroups,
              _dutyGroups,
            ) &&
            const DeepCollectionEquality().equals(other.configs, _configs) &&
            (identical(other.activeConfig, activeConfig) ||
                other.activeConfig == activeConfig) &&
            (identical(other.partnerConfigName, partnerConfigName) ||
                other.partnerConfigName == partnerConfigName) &&
            (identical(other.partnerDutyGroup, partnerDutyGroup) ||
                other.partnerDutyGroup == partnerDutyGroup) &&
            (identical(
                  other.partnerAccentColorValue,
                  partnerAccentColorValue,
                ) ||
                other.partnerAccentColorValue == partnerAccentColorValue) &&
            (identical(other.myAccentColorValue, myAccentColorValue) ||
                other.myAccentColorValue == myAccentColorValue) &&
            (identical(
                  other.holidayAccentColorValue,
                  holidayAccentColorValue,
                ) ||
                other.holidayAccentColorValue == holidayAccentColorValue) &&
            (identical(other.scheduleIndex, scheduleIndex) ||
                other.scheduleIndex == scheduleIndex));
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      isLoading,
      error,
      partnerError,
      selectedDay,
      focusedDay,
      const DeepCollectionEquality().hash(_schedules),
      activeConfigName,
      preferredDutyGroup,
      const DeepCollectionEquality().hash(_dutyGroups),
      const DeepCollectionEquality().hash(_configs),
      activeConfig,
      partnerConfigName,
      partnerDutyGroup,
      partnerAccentColorValue,
      myAccentColorValue,
      holidayAccentColorValue,
      scheduleIndex,
    );
  }

  @override
  String toString() {
    return 'ScheduleUiState(isLoading: $isLoading, error: $error, partnerError: $partnerError, selectedDay: $selectedDay, focusedDay: $focusedDay, schedules: $schedules, activeConfigName: $activeConfigName, preferredDutyGroup: $preferredDutyGroup, dutyGroups: $dutyGroups, configs: $configs, activeConfig: $activeConfig, partnerConfigName: $partnerConfigName, partnerDutyGroup: $partnerDutyGroup, partnerAccentColorValue: $partnerAccentColorValue, myAccentColorValue: $myAccentColorValue, holidayAccentColorValue: $holidayAccentColorValue, scheduleIndex: $scheduleIndex)';
  }
}

/// @nodoc
abstract mixin class _$ScheduleUiStateCopyWith<$Res>
    implements $ScheduleUiStateCopyWith<$Res> {
  factory _$ScheduleUiStateCopyWith(
    _ScheduleUiState value,
    $Res Function(_ScheduleUiState) _then,
  ) = __$ScheduleUiStateCopyWithImpl;
  @override
  @useResult
  $Res call({
    bool isLoading,
    String? error,
    String? partnerError,
    DateTime? selectedDay,
    DateTime? focusedDay,
    List<Schedule> schedules,
    String? activeConfigName,
    String? preferredDutyGroup,
    List<String> dutyGroups,
    List<DutyScheduleConfig> configs,
    DutyScheduleConfig? activeConfig,
    String? partnerConfigName,
    String? partnerDutyGroup,
    int? partnerAccentColorValue,
    int? myAccentColorValue,
    int? holidayAccentColorValue,
    ScheduleIndex scheduleIndex,
  });

  @override
  $DutyScheduleConfigCopyWith<$Res>? get activeConfig;
}

/// @nodoc
class __$ScheduleUiStateCopyWithImpl<$Res>
    implements _$ScheduleUiStateCopyWith<$Res> {
  __$ScheduleUiStateCopyWithImpl(this._self, this._then);

  final _ScheduleUiState _self;
  final $Res Function(_ScheduleUiState) _then;

  /// Create a copy of ScheduleUiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? partnerError = freezed,
    Object? selectedDay = freezed,
    Object? focusedDay = freezed,
    Object? schedules = null,
    Object? activeConfigName = freezed,
    Object? preferredDutyGroup = freezed,
    Object? dutyGroups = null,
    Object? configs = null,
    Object? activeConfig = freezed,
    Object? partnerConfigName = freezed,
    Object? partnerDutyGroup = freezed,
    Object? partnerAccentColorValue = freezed,
    Object? myAccentColorValue = freezed,
    Object? holidayAccentColorValue = freezed,
    Object? scheduleIndex = null,
  }) {
    return _then(
      _ScheduleUiState(
        isLoading: null == isLoading
            ? _self.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _self.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        partnerError: freezed == partnerError
            ? _self.partnerError
            : partnerError // ignore: cast_nullable_to_non_nullable
                  as String?,
        selectedDay: freezed == selectedDay
            ? _self.selectedDay
            : selectedDay // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        focusedDay: freezed == focusedDay
            ? _self.focusedDay
            : focusedDay // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        schedules: null == schedules
            ? _self._schedules
            : schedules // ignore: cast_nullable_to_non_nullable
                  as List<Schedule>,
        activeConfigName: freezed == activeConfigName
            ? _self.activeConfigName
            : activeConfigName // ignore: cast_nullable_to_non_nullable
                  as String?,
        preferredDutyGroup: freezed == preferredDutyGroup
            ? _self.preferredDutyGroup
            : preferredDutyGroup // ignore: cast_nullable_to_non_nullable
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
        holidayAccentColorValue: freezed == holidayAccentColorValue
            ? _self.holidayAccentColorValue
            : holidayAccentColorValue // ignore: cast_nullable_to_non_nullable
                  as int?,
        scheduleIndex: null == scheduleIndex
            ? _self.scheduleIndex
            : scheduleIndex // ignore: cast_nullable_to_non_nullable
                  as ScheduleIndex,
      ),
    );
  }

  /// Create a copy of ScheduleUiState
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
