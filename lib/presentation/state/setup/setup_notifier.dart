import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dienstplan/presentation/state/setup/setup_ui_state.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/domain/entities/settings.dart';
import 'package:dienstplan/domain/use_cases/get_configs_use_case.dart';
import 'package:dienstplan/domain/use_cases/set_active_config_use_case.dart';
import 'package:dienstplan/domain/use_cases/generate_schedules_use_case.dart';
import 'package:dienstplan/domain/use_cases/get_settings_use_case.dart';
import 'package:dienstplan/domain/use_cases/save_settings_use_case.dart';
import 'package:dienstplan/domain/repositories/config_repository.dart';
import 'package:dienstplan/data/services/schedule_config_service.dart';
import 'package:dienstplan/domain/policies/date_range_policy.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/core/constants/animation_constants.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'dart:async';

part 'setup_notifier.g.dart';

@riverpod
class SetupNotifier extends _$SetupNotifier {
  GetConfigsUseCase? _getConfigsUseCase;
  SetActiveConfigUseCase? _setActiveConfigUseCase;
  GenerateSchedulesUseCase? _generateSchedulesUseCase;
  GetSettingsUseCase? _getSettingsUseCase;
  SaveSettingsUseCase? _saveSettingsUseCase;
  ConfigRepository? _configRepository;
  ScheduleConfigService? _scheduleConfigService;
  DateRangePolicy? _dateRangePolicy;

  @override
  Future<SetupUiState> build() async {
    _getConfigsUseCase ??= await ref.read(getConfigsUseCaseProvider.future);
    _setActiveConfigUseCase ??=
        await ref.read(setActiveConfigUseCaseProvider.future);
    _generateSchedulesUseCase ??=
        await ref.read(generateSchedulesUseCaseProvider.future);
    _getSettingsUseCase ??= await ref.read(getSettingsUseCaseProvider.future);
    _saveSettingsUseCase ??= await ref.read(saveSettingsUseCaseProvider.future);
    _configRepository ??= await ref.read(configRepositoryProvider.future);
    _scheduleConfigService ??=
        await ref.read(scheduleConfigServiceProvider.future);
    _dateRangePolicy ??= ref.read(dateRangePolicyProvider);

    return await _loadConfigs();
  }

  Future<SetupUiState> _loadConfigs() async {
    state = const AsyncLoading();
    try {
      AppLogger.i('Loading duty schedule configurations');
      final configs = await _getConfigsUseCase!.execute();
      AppLogger.i('Loaded ${configs.length} configurations');

      return SetupUiState(
        isLoading: false,
        isGeneratingSchedules: false,
        isSetupCompleted: false,
        currentStep: 1,
        selectedTheme: ThemePreference.system,
        configs: configs,
      );
    } catch (e, stackTrace) {
      AppLogger.e('Error loading configs', e, stackTrace);
      return SetupUiState.initial().copyWith(
        isLoading: false,
        error: 'Failed to load configurations',
        errorStackTrace: stackTrace,
      );
    }
  }

  Future<void> setTheme(ThemePreference theme) async {
    final current = state.value ?? SetupUiState.initial();
    state = AsyncData(current.copyWith(selectedTheme: theme));

    // Apply theme immediately
    await ref.read(settingsProvider.notifier).setThemePreference(theme);
  }

  Future<void> setConfig(DutyScheduleConfig? config) async {
    final current = state.value ?? SetupUiState.initial();
    state = AsyncData(current.copyWith(selectedConfig: config));
  }

  Future<void> setDutyGroup(String? dutyGroup) async {
    final current = state.value ?? SetupUiState.initial();
    state = AsyncData(current.copyWith(selectedDutyGroup: dutyGroup));
  }

  Future<void> setPartnerConfig(DutyScheduleConfig? config) async {
    final current = state.value ?? SetupUiState.initial();
    state = AsyncData(current.copyWith(
      selectedPartnerConfig: config,
      selectedPartnerDutyGroup: null,
    ));
  }

  Future<void> setPartnerDutyGroup(String? dutyGroup) async {
    final current = state.value ?? SetupUiState.initial();
    state = AsyncData(current.copyWith(selectedPartnerDutyGroup: dutyGroup));
  }

  Future<void> nextStep() async {
    final current = state.value ?? SetupUiState.initial();

    if (current.currentStep == 1) {
      state = AsyncData(current.copyWith(currentStep: 2));
      return;
    }

    if (current.currentStep == 2 && current.selectedConfig != null) {
      // Pre-select current duty group if it exists
      final scheduleState = ref.read(scheduleCoordinatorProvider).value;
      final currentDutyGroup = scheduleState?.preferredDutyGroup;

      state = AsyncData(current.copyWith(
        currentStep: 3,
        selectedDutyGroup: currentDutyGroup,
      ));
      return;
    }

    if (current.currentStep == 3) {
      state = AsyncData(current.copyWith(
        currentStep: 4,
        selectedPartnerConfig: null,
        selectedPartnerDutyGroup: null,
      ));
      return;
    }

    if (current.currentStep == 4) {
      if (current.selectedPartnerConfig != null) {
        state = AsyncData(current.copyWith(
          currentStep: 5,
          selectedPartnerDutyGroup: null,
        ));
      } else {
        // Skip partner setup - setup is already complete
        await _saveDefaultConfig();
      }
      return;
    }

    if (current.currentStep == 5) {
      await _saveDefaultConfig();
      return;
    }
  }

  Future<void> previousStep() async {
    final current = state.value ?? SetupUiState.initial();

    if (current.currentStep > 1) {
      final int newStep = current.currentStep - 1;
      String? newDutyGroup = current.selectedDutyGroup;
      DutyScheduleConfig? newPartnerConfig = current.selectedPartnerConfig;
      String? newPartnerDutyGroup = current.selectedPartnerDutyGroup;

      if (newStep < 3) {
        newDutyGroup = null;
      }
      if (newStep < 4) {
        newPartnerConfig = null;
        newPartnerDutyGroup = null;
      }
      if (newStep < 5) {
        newPartnerDutyGroup = null;
      }

      state = AsyncData(current.copyWith(
        currentStep: newStep,
        selectedDutyGroup: newDutyGroup,
        selectedPartnerConfig: newPartnerConfig,
        selectedPartnerDutyGroup: newPartnerDutyGroup,
      ));
    }
  }

  Future<void> retryLoading() async {
    state = const AsyncLoading();
    final newState = await _loadConfigs();
    state = AsyncData(newState);
  }

  Future<void> _saveDefaultConfig() async {
    final current = state.value ?? SetupUiState.initial();

    try {
      AppLogger.i('Starting setup completion process');
      state = AsyncData(current.copyWith(isGeneratingSchedules: true));

      if (current.selectedConfig != null) {
        await _configRepository!.setDefaultConfig(current.selectedConfig!);
        await _setActiveConfigUseCase!.execute(current.selectedConfig!.name);
      }

      final DateTime now = DateTime.now();
      final initialRange = _dateRangePolicy!.computeInitialRange(now);

      if (current.selectedConfig != null) {
        await _generateSchedulesUseCase!.execute(
          configName: current.selectedConfig!.name,
          startDate: initialRange.start,
          endDate: initialRange.end,
        );
      }

      final existingSettings = await _getSettingsUseCase!.execute();
      final initialSettings = Settings(
        calendarFormat:
            existingSettings?.calendarFormat ?? CalendarFormat.month,
        myDutyGroup: current.selectedDutyGroup,
        activeConfigName: current.selectedConfig?.name,
        themePreference: current.selectedTheme,
        partnerConfigName: current.selectedPartnerConfig?.name,
        partnerDutyGroup: current.selectedPartnerDutyGroup,
      );
      await _saveSettingsUseCase!.execute(initialSettings);

      await _scheduleConfigService!.markSetupCompleted();
      AppLogger.i(
          'Setup completed successfully for config: ${current.selectedConfig?.name ?? "none"}');

      await Future.delayed(kUiDelayShort);

      final finalSettings = Settings(
        calendarFormat: CalendarFormat.month,
        myDutyGroup: current.selectedDutyGroup,
        activeConfigName: current.selectedConfig!.name,
        themePreference: current.selectedTheme,
        partnerConfigName: current.selectedPartnerConfig?.name,
        partnerDutyGroup: current.selectedPartnerDutyGroup,
      );
      await _saveSettingsUseCase!.execute(finalSettings);

      await ref
          .read(settingsProvider.notifier)
          .setThemePreference(current.selectedTheme);
      ref.invalidate(scheduleCoordinatorProvider);

      // Mark setup as completed and keep loading state for smooth transition
      state = AsyncData(current.copyWith(
        isGeneratingSchedules: true, // Keep loading state
        isSetupCompleted: true,
      ));
    } catch (e, stackTrace) {
      AppLogger.e('Error saving default config', e, stackTrace);
      state = AsyncData(current.copyWith(
        isGeneratingSchedules: false,
        error: 'Failed to complete setup',
        errorStackTrace: stackTrace,
      ));
      rethrow;
    }
  }
}
