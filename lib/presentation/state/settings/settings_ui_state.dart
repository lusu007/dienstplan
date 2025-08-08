import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:table_calendar/table_calendar.dart';

part 'settings_ui_state.freezed.dart';

@freezed
class SettingsUiState with _$SettingsUiState {
  const factory SettingsUiState({
    required bool isLoading,
    String? error,
    String? language,
    CalendarFormat? calendarFormat,
    String? activeConfigName,
    String? myDutyGroup,
  }) = _SettingsUiState;

  const SettingsUiState._();

  factory SettingsUiState.initial() => const SettingsUiState(
        isLoading: false,
      );
}

