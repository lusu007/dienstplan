import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_index.dart';

part 'schedule_ui_state.freezed.dart';

@freezed
abstract class ScheduleUiState with _$ScheduleUiState {
  const factory ScheduleUiState({
    required bool isLoading,
    String? error,
    DateTime? selectedDay,
    DateTime? focusedDay,
    CalendarFormat? calendarFormat,
    @Default(<Schedule>[]) List<Schedule> schedules,
    String? activeConfigName,
    String? preferredDutyGroup,
    String? selectedDutyGroup,
    @Default(<String>[]) List<String> dutyGroups,
    @Default(<DutyScheduleConfig>[]) List<DutyScheduleConfig> configs,
    DutyScheduleConfig? activeConfig,
    // Partner group extended state
    String? partnerConfigName,
    String? partnerDutyGroup,
    int? partnerAccentColorValue,
    // My accent color state
    int? myAccentColorValue,
    // Holiday accent color state
    int? holidayAccentColorValue,
    // Optimized schedule index for efficient range queries
    @Default(ScheduleIndex()) ScheduleIndex scheduleIndex,
  }) = _ScheduleUiState;

  const ScheduleUiState._();

  factory ScheduleUiState.initial() => ScheduleUiState(
    isLoading: false,
    selectedDay: DateTime.now(),
    focusedDay: DateTime.now(),
    calendarFormat: CalendarFormat.month,
    activeConfigName: '',
    preferredDutyGroup: '',
    partnerConfigName: null,
    partnerDutyGroup: null,
    partnerAccentColorValue: null,
    myAccentColorValue: null,
    holidayAccentColorValue: null,
  );

  /// Checks if data exists for the given range using optimized algorithms.
  ///
  /// This method uses the schedule index for O(k) coverage checks and
  /// O(log n) binary search for optimal performance.
  bool hasDataForRange(
    String configName,
    DateTime startDate,
    DateTime endDate,
  ) {
    return scheduleIndex.hasDataForRange(configName, startDate, endDate);
  }

  /// Updates the schedule index when schedules change.
  ///
  /// This should be called whenever the schedules list is modified
  /// to keep the index in sync.
  ScheduleUiState updateScheduleIndex() {
    final newIndex = ScheduleIndex.withSchedules(schedules);
    return copyWith(scheduleIndex: newIndex);
  }

  /// Adds schedules and updates the index.
  ScheduleUiState addSchedules(List<Schedule> newSchedules) {
    final updatedSchedules = [...schedules, ...newSchedules];
    final newIndex = ScheduleIndex.withSchedules(updatedSchedules);
    return copyWith(schedules: updatedSchedules, scheduleIndex: newIndex);
  }

  /// Replaces all schedules and updates the index.
  ScheduleUiState replaceSchedules(List<Schedule> newSchedules) {
    final newIndex = ScheduleIndex.withSchedules(newSchedules);
    return copyWith(schedules: newSchedules, scheduleIndex: newIndex);
  }
}
