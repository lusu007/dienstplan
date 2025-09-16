import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/domain/entities/settings.dart';

part 'setup_ui_state.freezed.dart';

@freezed
abstract class SetupUiState with _$SetupUiState {
  const factory SetupUiState({
    required bool isLoading,
    required bool isGeneratingSchedules,
    required bool isSetupCompleted,
    String? error,
    StackTrace? errorStackTrace,
    required int currentStep,
    required ThemePreference selectedTheme,
    DutyScheduleConfig? selectedConfig,
    String? selectedDutyGroup,
    DutyScheduleConfig? selectedPartnerConfig,
    String? selectedPartnerDutyGroup,
    required List<DutyScheduleConfig> configs,
    required Set<String> selectedPoliceAuthorities,
  }) = _SetupUiState;

  const SetupUiState._();

  List<DutyScheduleConfig> get filteredConfigs {
    if (selectedPoliceAuthorities.isEmpty) {
      return configs;
    }
    return configs
        .where((config) =>
            config.meta.policeAuthority != null &&
            selectedPoliceAuthorities.contains(config.meta.policeAuthority))
        .toList();
  }

  Set<String> get availablePoliceAuthorities {
    return configs
        .map((config) => config.meta.policeAuthority)
        .where((authority) => authority != null)
        .cast<String>()
        .toSet();
  }

  factory SetupUiState.initial() => const SetupUiState(
        isLoading: true,
        isGeneratingSchedules: false,
        isSetupCompleted: false,
        currentStep: 1,
        selectedTheme: ThemePreference.system,
        configs: [],
        selectedPoliceAuthorities: {},
      );
}
