// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule_ui_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ScheduleUiState {
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  DateTime? get selectedDay => throw _privateConstructorUsedError;
  DateTime? get focusedDay => throw _privateConstructorUsedError;
  CalendarFormat? get calendarFormat => throw _privateConstructorUsedError;
  List<Schedule> get schedules => throw _privateConstructorUsedError;
  String? get activeConfigName => throw _privateConstructorUsedError;
  String? get preferredDutyGroup => throw _privateConstructorUsedError;
  String? get selectedDutyGroup => throw _privateConstructorUsedError;
  List<String> get dutyGroups => throw _privateConstructorUsedError;
  List<DutyScheduleConfig> get configs => throw _privateConstructorUsedError;
  DutyScheduleConfig? get activeConfig => throw _privateConstructorUsedError;

  /// Create a copy of ScheduleUiState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScheduleUiStateCopyWith<ScheduleUiState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScheduleUiStateCopyWith<$Res> {
  factory $ScheduleUiStateCopyWith(
          ScheduleUiState value, $Res Function(ScheduleUiState) then) =
      _$ScheduleUiStateCopyWithImpl<$Res, ScheduleUiState>;
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
      DutyScheduleConfig? activeConfig});
}

/// @nodoc
class _$ScheduleUiStateCopyWithImpl<$Res, $Val extends ScheduleUiState>
    implements $ScheduleUiStateCopyWith<$Res> {
  _$ScheduleUiStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
      selectedDay: freezed == selectedDay
          ? _value.selectedDay
          : selectedDay // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      focusedDay: freezed == focusedDay
          ? _value.focusedDay
          : focusedDay // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      calendarFormat: freezed == calendarFormat
          ? _value.calendarFormat
          : calendarFormat // ignore: cast_nullable_to_non_nullable
              as CalendarFormat?,
      schedules: null == schedules
          ? _value.schedules
          : schedules // ignore: cast_nullable_to_non_nullable
              as List<Schedule>,
      activeConfigName: freezed == activeConfigName
          ? _value.activeConfigName
          : activeConfigName // ignore: cast_nullable_to_non_nullable
              as String?,
      preferredDutyGroup: freezed == preferredDutyGroup
          ? _value.preferredDutyGroup
          : preferredDutyGroup // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedDutyGroup: freezed == selectedDutyGroup
          ? _value.selectedDutyGroup
          : selectedDutyGroup // ignore: cast_nullable_to_non_nullable
              as String?,
      dutyGroups: null == dutyGroups
          ? _value.dutyGroups
          : dutyGroups // ignore: cast_nullable_to_non_nullable
              as List<String>,
      configs: null == configs
          ? _value.configs
          : configs // ignore: cast_nullable_to_non_nullable
              as List<DutyScheduleConfig>,
      activeConfig: freezed == activeConfig
          ? _value.activeConfig
          : activeConfig // ignore: cast_nullable_to_non_nullable
              as DutyScheduleConfig?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScheduleUiStateImplCopyWith<$Res>
    implements $ScheduleUiStateCopyWith<$Res> {
  factory _$$ScheduleUiStateImplCopyWith(_$ScheduleUiStateImpl value,
          $Res Function(_$ScheduleUiStateImpl) then) =
      __$$ScheduleUiStateImplCopyWithImpl<$Res>;
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
      DutyScheduleConfig? activeConfig});
}

/// @nodoc
class __$$ScheduleUiStateImplCopyWithImpl<$Res>
    extends _$ScheduleUiStateCopyWithImpl<$Res, _$ScheduleUiStateImpl>
    implements _$$ScheduleUiStateImplCopyWith<$Res> {
  __$$ScheduleUiStateImplCopyWithImpl(
      _$ScheduleUiStateImpl _value, $Res Function(_$ScheduleUiStateImpl) _then)
      : super(_value, _then);

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
  }) {
    return _then(_$ScheduleUiStateImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedDay: freezed == selectedDay
          ? _value.selectedDay
          : selectedDay // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      focusedDay: freezed == focusedDay
          ? _value.focusedDay
          : focusedDay // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      calendarFormat: freezed == calendarFormat
          ? _value.calendarFormat
          : calendarFormat // ignore: cast_nullable_to_non_nullable
              as CalendarFormat?,
      schedules: null == schedules
          ? _value._schedules
          : schedules // ignore: cast_nullable_to_non_nullable
              as List<Schedule>,
      activeConfigName: freezed == activeConfigName
          ? _value.activeConfigName
          : activeConfigName // ignore: cast_nullable_to_non_nullable
              as String?,
      preferredDutyGroup: freezed == preferredDutyGroup
          ? _value.preferredDutyGroup
          : preferredDutyGroup // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedDutyGroup: freezed == selectedDutyGroup
          ? _value.selectedDutyGroup
          : selectedDutyGroup // ignore: cast_nullable_to_non_nullable
              as String?,
      dutyGroups: null == dutyGroups
          ? _value._dutyGroups
          : dutyGroups // ignore: cast_nullable_to_non_nullable
              as List<String>,
      configs: null == configs
          ? _value._configs
          : configs // ignore: cast_nullable_to_non_nullable
              as List<DutyScheduleConfig>,
      activeConfig: freezed == activeConfig
          ? _value.activeConfig
          : activeConfig // ignore: cast_nullable_to_non_nullable
              as DutyScheduleConfig?,
    ));
  }
}

/// @nodoc

class _$ScheduleUiStateImpl extends _ScheduleUiState {
  const _$ScheduleUiStateImpl(
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
      this.activeConfig})
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
  String toString() {
    return 'ScheduleUiState(isLoading: $isLoading, error: $error, selectedDay: $selectedDay, focusedDay: $focusedDay, calendarFormat: $calendarFormat, schedules: $schedules, activeConfigName: $activeConfigName, preferredDutyGroup: $preferredDutyGroup, selectedDutyGroup: $selectedDutyGroup, dutyGroups: $dutyGroups, configs: $configs, activeConfig: $activeConfig)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScheduleUiStateImpl &&
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
                other.activeConfig == activeConfig));
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
      activeConfig);

  /// Create a copy of ScheduleUiState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScheduleUiStateImplCopyWith<_$ScheduleUiStateImpl> get copyWith =>
      __$$ScheduleUiStateImplCopyWithImpl<_$ScheduleUiStateImpl>(
          this, _$identity);
}

abstract class _ScheduleUiState extends ScheduleUiState {
  const factory _ScheduleUiState(
      {required final bool isLoading,
      final String? error,
      final DateTime? selectedDay,
      final DateTime? focusedDay,
      final CalendarFormat? calendarFormat,
      final List<Schedule> schedules,
      final String? activeConfigName,
      final String? preferredDutyGroup,
      final String? selectedDutyGroup,
      final List<String> dutyGroups,
      final List<DutyScheduleConfig> configs,
      final DutyScheduleConfig? activeConfig}) = _$ScheduleUiStateImpl;
  const _ScheduleUiState._() : super._();

  @override
  bool get isLoading;
  @override
  String? get error;
  @override
  DateTime? get selectedDay;
  @override
  DateTime? get focusedDay;
  @override
  CalendarFormat? get calendarFormat;
  @override
  List<Schedule> get schedules;
  @override
  String? get activeConfigName;
  @override
  String? get preferredDutyGroup;
  @override
  String? get selectedDutyGroup;
  @override
  List<String> get dutyGroups;
  @override
  List<DutyScheduleConfig> get configs;
  @override
  DutyScheduleConfig? get activeConfig;

  /// Create a copy of ScheduleUiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScheduleUiStateImplCopyWith<_$ScheduleUiStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
