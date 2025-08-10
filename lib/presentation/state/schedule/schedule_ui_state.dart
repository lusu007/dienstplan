import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart';

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
      );
}
