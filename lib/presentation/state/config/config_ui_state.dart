import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart';

part 'config_ui_state.freezed.dart';

@freezed
abstract class ConfigUiState with _$ConfigUiState {
  const factory ConfigUiState({
    required bool isLoading,
    String? error,
    String? activeConfigName,
    @Default(<String>[]) List<String> dutyGroups,
    @Default(<DutyScheduleConfig>[]) List<DutyScheduleConfig> configs,
    DutyScheduleConfig? activeConfig,
  }) = _ConfigUiState;

  const ConfigUiState._();

  factory ConfigUiState.initial() =>
      const ConfigUiState(isLoading: false, activeConfigName: '');
}
