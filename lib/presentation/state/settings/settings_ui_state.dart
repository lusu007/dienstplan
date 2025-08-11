import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/domain/entities/settings.dart' show ThemePreference;

part 'settings_ui_state.freezed.dart';

@freezed
abstract class SettingsUiState with _$SettingsUiState {
  const factory SettingsUiState({
    required bool isLoading,
    String? error,
    String? language,
    CalendarFormat? calendarFormat,
    String? activeConfigName,
    String? myDutyGroup,
    ThemePreference? themePreference,
    // Partner duty group UI values
    String? partnerConfigName,
    String? partnerDutyGroup,
    int? partnerAccentColorValue,
    // My accent color UI value
    int? myAccentColorValue,
  }) = _SettingsUiState;

  const SettingsUiState._();

  factory SettingsUiState.initial() => const SettingsUiState(
        isLoading: false,
        themePreference: ThemePreference.system,
      );
}
