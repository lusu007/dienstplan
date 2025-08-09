// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule_ui_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ScheduleUiState {
  bool get isLoading;
  String? get error;
  DateTime? get selectedDay;
  DateTime? get focusedDay;
  CalendarFormat? get calendarFormat;
  List<Schedule> get schedules;
  String? get activeConfigName;
  String? get preferredDutyGroup;
  String? get selectedDutyGroup;
  List<String> get dutyGroups;
  List<DutyScheduleConfig> get configs;
  DutyScheduleConfig? get activeConfig;
  int get scheduleGeneration;

  /// Create a copy of ScheduleUiState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ScheduleUiStateCopyWith<ScheduleUiState> get copyWith =>
      _$ScheduleUiStateCopyWithImpl<ScheduleUiState>(
          this as ScheduleUiState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ScheduleUiState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.selectedDay, selectedDay) ||
                other.selectedDay == selectedDay) &&
            (identical(other.focusedDay, focusedDay) ||
                other.focusedDay == focusedDay) &&
            (identical(other.calendarFormat, calendarFormat) ||
                other.calendarFormat == calendarFormat) &&
            const DeepCollectionEquality().equals(other.schedules, schedules) &&
            (identical(other.activeConfigName, activeConfigName) ||
                other.activeConfigName == activeConfigName) &&
            (identical(other.preferredDutyGroup, preferredDutyGroup) ||
                other.preferredDutyGroup == preferredDutyGroup) &&
            (identical(other.selectedDutyGroup, selectedDutyGroup) ||
                other.selectedDutyGroup == selectedDutyGroup) &&
            const DeepCollectionEquality()
                .equals(other.dutyGroups, dutyGroups) &&
            const DeepCollectionEquality().equals(other.configs, configs) &&
            (identical(other.activeConfig, activeConfig) ||
                other.activeConfig == activeConfig) &&
            (identical(other.scheduleGeneration, scheduleGeneration) ||
                other.scheduleGeneration == scheduleGeneration));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isLoading,
      error,
      selectedDay,
      focusedDay,
      calendarFormat,
      const DeepCollectionEquality().hash(schedules),
      activeConfigName,
      preferredDutyGroup,
      selectedDutyGroup,
      const DeepCollectionEquality().hash(dutyGroups),
      const DeepCollectionEquality().hash(configs),
      activeConfig,
      scheduleGeneration);

  @override
  String toString() {
    return 'ScheduleUiState(isLoading: $isLoading, error: $error, selectedDay: $selectedDay, focusedDay: $focusedDay, calendarFormat: $calendarFormat, schedules: $schedules, activeConfigName: $activeConfigName, preferredDutyGroup: $preferredDutyGroup, selectedDutyGroup: $selectedDutyGroup, dutyGroups: $dutyGroups, configs: $configs, activeConfig: $activeConfig, scheduleGeneration: $scheduleGeneration)';
  }
}

/// @nodoc
abstract mixin class $ScheduleUiStateCopyWith<$Res> {
  factory $ScheduleUiStateCopyWith(
          ScheduleUiState value, $Res Function(ScheduleUiState) _then) =
      _$ScheduleUiStateCopyWithImpl;
  @useResult
  $Res call(
      {bool isLoading,
      String? error,
      DateTime? selectedDay,
      DateTime? focusedDay,
      CalendarFormat? calendarFormat,
      List<Schedule> schedules,
      String? activeConfigName,
      String? preferredDutyGroup,
      String? selectedDutyGroup,
      List<String> dutyGroups,
      List<DutyScheduleConfig> configs,
      DutyScheduleConfig? activeConfig,
      int scheduleGeneration});
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
    Object? selectedDay = freezed,
    Object? focusedDay = freezed,
    Object? calendarFormat = freezed,
    Object? schedules = null,
    Object? activeConfigName = freezed,
    Object? preferredDutyGroup = freezed,
    Object? selectedDutyGroup = freezed,
    Object? dutyGroups = null,
    Object? configs = null,
    Object? activeConfig = freezed,
    Object? scheduleGeneration = null,
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
      selectedDay: freezed == selectedDay
          ? _self.selectedDay
          : selectedDay // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      focusedDay: freezed == focusedDay
          ? _self.focusedDay
          : focusedDay // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      calendarFormat: freezed == calendarFormat
          ? _self.calendarFormat
          : calendarFormat // ignore: cast_nullable_to_non_nullable
              as CalendarFormat?,
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
      selectedDutyGroup: freezed == selectedDutyGroup
          ? _self.selectedDutyGroup
          : selectedDutyGroup // ignore: cast_nullable_to_non_nullable
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
      scheduleGeneration: null == scheduleGeneration
          ? _self.scheduleGeneration
          : scheduleGeneration // ignore: cast_nullable_to_non_nullable
              as int,
    ));
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
            DateTime? selectedDay,
            DateTime? focusedDay,
            CalendarFormat? calendarFormat,
            List<Schedule> schedules,
            String? activeConfigName,
            String? preferredDutyGroup,
            String? selectedDutyGroup,
            List<String> dutyGroups,
            List<DutyScheduleConfig> configs,
            DutyScheduleConfig? activeConfig,
            int scheduleGeneration)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ScheduleUiState() when $default != null:
        return $default(
            _that.isLoading,
            _that.error,
            _that.selectedDay,
            _that.focusedDay,
            _that.calendarFormat,
            _that.schedules,
            _that.activeConfigName,
            _that.preferredDutyGroup,
            _that.selectedDutyGroup,
            _that.dutyGroups,
            _that.configs,
            _that.activeConfig,
            _that.scheduleGeneration);
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
            DateTime? selectedDay,
            DateTime? focusedDay,
            CalendarFormat? calendarFormat,
            List<Schedule> schedules,
            String? activeConfigName,
            String? preferredDutyGroup,
            String? selectedDutyGroup,
            List<String> dutyGroups,
            List<DutyScheduleConfig> configs,
            DutyScheduleConfig? activeConfig,
            int scheduleGeneration)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleUiState():
        return $default(
            _that.isLoading,
            _that.error,
            _that.selectedDay,
            _that.focusedDay,
            _that.calendarFormat,
            _that.schedules,
            _that.activeConfigName,
            _that.preferredDutyGroup,
            _that.selectedDutyGroup,
            _that.dutyGroups,
            _that.configs,
            _that.activeConfig,
            _that.scheduleGeneration);
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
            DateTime? selectedDay,
            DateTime? focusedDay,
            CalendarFormat? calendarFormat,
            List<Schedule> schedules,
            String? activeConfigName,
            String? preferredDutyGroup,
            String? selectedDutyGroup,
            List<String> dutyGroups,
            List<DutyScheduleConfig> configs,
            DutyScheduleConfig? activeConfig,
            int scheduleGeneration)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleUiState() when $default != null:
        return $default(
            _that.isLoading,
            _that.error,
            _that.selectedDay,
            _that.focusedDay,
            _that.calendarFormat,
            _that.schedules,
            _that.activeConfigName,
            _that.preferredDutyGroup,
            _that.selectedDutyGroup,
            _that.dutyGroups,
            _that.configs,
            _that.activeConfig,
            _that.scheduleGeneration);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ScheduleUiState extends ScheduleUiState {
  const _ScheduleUiState(
      {required this.isLoading,
      this.error,
      this.selectedDay,
      this.focusedDay,
      this.calendarFormat,
      final List<Schedule> schedules = const <Schedule>[],
      this.activeConfigName,
      this.preferredDutyGroup,
      this.selectedDutyGroup,
      final List<String> dutyGroups = const <String>[],
      final List<DutyScheduleConfig> configs = const <DutyScheduleConfig>[],
      this.activeConfig,
      this.scheduleGeneration = 0})
      : _schedules = schedules,
        _dutyGroups = dutyGroups,
        _configs = configs,
        super._();

  @override
  final bool isLoading;
  @override
  final String? error;
  @override
  final DateTime? selectedDay;
  @override
  final DateTime? focusedDay;
  @override
  final CalendarFormat? calendarFormat;
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
  @override
  final String? selectedDutyGroup;
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
  @JsonKey()
  final int scheduleGeneration;

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
            (identical(other.selectedDay, selectedDay) ||
                other.selectedDay == selectedDay) &&
            (identical(other.focusedDay, focusedDay) ||
                other.focusedDay == focusedDay) &&
            (identical(other.calendarFormat, calendarFormat) ||
                other.calendarFormat == calendarFormat) &&
            const DeepCollectionEquality()
                .equals(other._schedules, _schedules) &&
            (identical(other.activeConfigName, activeConfigName) ||
                other.activeConfigName == activeConfigName) &&
            (identical(other.preferredDutyGroup, preferredDutyGroup) ||
                other.preferredDutyGroup == preferredDutyGroup) &&
            (identical(other.selectedDutyGroup, selectedDutyGroup) ||
                other.selectedDutyGroup == selectedDutyGroup) &&
            const DeepCollectionEquality()
                .equals(other._dutyGroups, _dutyGroups) &&
            const DeepCollectionEquality().equals(other._configs, _configs) &&
            (identical(other.activeConfig, activeConfig) ||
                other.activeConfig == activeConfig) &&
            (identical(other.scheduleGeneration, scheduleGeneration) ||
                other.scheduleGeneration == scheduleGeneration));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isLoading,
      error,
      selectedDay,
      focusedDay,
      calendarFormat,
      const DeepCollectionEquality().hash(_schedules),
      activeConfigName,
      preferredDutyGroup,
      selectedDutyGroup,
      const DeepCollectionEquality().hash(_dutyGroups),
      const DeepCollectionEquality().hash(_configs),
      activeConfig,
      scheduleGeneration);

  @override
  String toString() {
    return 'ScheduleUiState(isLoading: $isLoading, error: $error, selectedDay: $selectedDay, focusedDay: $focusedDay, calendarFormat: $calendarFormat, schedules: $schedules, activeConfigName: $activeConfigName, preferredDutyGroup: $preferredDutyGroup, selectedDutyGroup: $selectedDutyGroup, dutyGroups: $dutyGroups, configs: $configs, activeConfig: $activeConfig, scheduleGeneration: $scheduleGeneration)';
  }
}

/// @nodoc
abstract mixin class _$ScheduleUiStateCopyWith<$Res>
    implements $ScheduleUiStateCopyWith<$Res> {
  factory _$ScheduleUiStateCopyWith(
          _ScheduleUiState value, $Res Function(_ScheduleUiState) _then) =
      __$ScheduleUiStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      String? error,
      DateTime? selectedDay,
      DateTime? focusedDay,
      CalendarFormat? calendarFormat,
      List<Schedule> schedules,
      String? activeConfigName,
      String? preferredDutyGroup,
      String? selectedDutyGroup,
      List<String> dutyGroups,
      List<DutyScheduleConfig> configs,
      DutyScheduleConfig? activeConfig,
      int scheduleGeneration});
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
    Object? selectedDay = freezed,
    Object? focusedDay = freezed,
    Object? calendarFormat = freezed,
    Object? schedules = null,
    Object? activeConfigName = freezed,
    Object? preferredDutyGroup = freezed,
    Object? selectedDutyGroup = freezed,
    Object? dutyGroups = null,
    Object? configs = null,
    Object? activeConfig = freezed,
    Object? scheduleGeneration = null,
  }) {
    return _then(_ScheduleUiState(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedDay: freezed == selectedDay
          ? _self.selectedDay
          : selectedDay // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      focusedDay: freezed == focusedDay
          ? _self.focusedDay
          : focusedDay // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      calendarFormat: freezed == calendarFormat
          ? _self.calendarFormat
          : calendarFormat // ignore: cast_nullable_to_non_nullable
              as CalendarFormat?,
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
      selectedDutyGroup: freezed == selectedDutyGroup
          ? _self.selectedDutyGroup
          : selectedDutyGroup // ignore: cast_nullable_to_non_nullable
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
      scheduleGeneration: null == scheduleGeneration
          ? _self.scheduleGeneration
          : scheduleGeneration // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
