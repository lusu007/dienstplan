import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:dienstplan/domain/entities/schedule.dart';

part 'schedule_data_ui_state.freezed.dart';

@freezed
abstract class ScheduleDataUiState with _$ScheduleDataUiState {
  const factory ScheduleDataUiState({
    required bool isLoading,
    String? error,
    @Default(<Schedule>[]) List<Schedule> schedules,
    String? activeConfigName,
    String? preferredDutyGroup,
    String? selectedDutyGroup,
    int? holidayAccentColorValue,
  }) = _ScheduleDataUiState;

  const ScheduleDataUiState._();

  factory ScheduleDataUiState.initial() => const ScheduleDataUiState(
    isLoading: false,
    activeConfigName: '',
    preferredDutyGroup: '',
    holidayAccentColorValue: null,
  );
}
