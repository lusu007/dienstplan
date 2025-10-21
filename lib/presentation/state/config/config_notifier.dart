import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dienstplan/presentation/state/config/config_ui_state.dart';
import 'package:dienstplan/domain/use_cases/get_configs_use_case.dart';
import 'package:dienstplan/domain/use_cases/set_active_config_use_case.dart';
import 'package:dienstplan/domain/use_cases/get_settings_use_case.dart';
import 'package:dienstplan/domain/use_cases/save_settings_use_case.dart';
import 'package:dienstplan/domain/services/config_query_service.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/core/cache/settings_cache.dart';

part 'config_notifier.g.dart';

@riverpod
class ConfigNotifier extends _$ConfigNotifier {
  GetConfigsUseCase? _getConfigsUseCase;
  SetActiveConfigUseCase? _setActiveConfigUseCase;
  GetSettingsUseCase? _getSettingsUseCase;
  SaveSettingsUseCase? _saveSettingsUseCase;
  ConfigQueryService? _configQueryService;

  @override
  Future<ConfigUiState> build() async {
    _getConfigsUseCase ??= await ref.read(getConfigsUseCaseProvider.future);
    _setActiveConfigUseCase ??= await ref.read(
      setActiveConfigUseCaseProvider.future,
    );
    _getSettingsUseCase ??= await ref.read(getSettingsUseCaseProvider.future);
    _saveSettingsUseCase ??= await ref.read(saveSettingsUseCaseProvider.future);
    _configQueryService ??= ref.read(configQueryServiceProvider);
    return await _initialize();
  }

  Future<ConfigUiState> _initialize() async {
    try {
      final configs = await _getConfigsUseCase!.execute();
      final settingsResult = await _getSettingsUseCase!.executeSafe();
      final settings = settingsResult.isSuccess ? settingsResult.value : null;

      final String? activeConfigName = settings?.activeConfigName;

      final List<String> dutyGroups =
          (activeConfigName != null && activeConfigName.isNotEmpty)
          ? _configQueryService!.extractDutyGroups(configs, activeConfigName)
          : <String>[];

      final DutyScheduleConfig? activeConfig =
          (activeConfigName != null && activeConfigName.isNotEmpty)
          ? (configs.where((c) => c.name == activeConfigName).isNotEmpty
                ? configs.firstWhere((c) => c.name == activeConfigName)
                : null)
          : null;

      return ConfigUiState(
        isLoading: false,
        error: null,
        activeConfigName: activeConfigName ?? '',
        dutyGroups: dutyGroups,
        configs: configs,
        activeConfig: activeConfig,
      );
    } catch (e) {
      return ConfigUiState.initial().copyWith(
        error: 'Failed to initialize config settings',
      );
    }
  }

  Future<void> setActiveConfig(String configName) async {
    final current = await future;
    if (!ref.mounted) return;

    state = AsyncData(current.copyWith(isLoading: true));

    try {
      // Set active config in database
      await _setActiveConfigUseCase!.execute(configName);
      if (!ref.mounted) return;

      // Update settings
      final settingsResult = await _getSettingsUseCase!.executeSafe();
      if (!ref.mounted) return;

      final existing = settingsResult.isSuccess ? settingsResult.value : null;

      if (existing != null) {
        final updated = existing.copyWith(activeConfigName: configName);
        final saveResult = await _saveSettingsUseCase!.executeSafe(updated);
        if (saveResult.isFailure) {
          throw Exception('Failed to save settings: ${saveResult.failure}');
        }
        if (!ref.mounted) return;

        // Force cache invalidation after successful save
        ref.invalidate(getSettingsUseCaseProvider);
        SettingsCache.clearCache();
      }

      // Update duty groups for new config
      final dutyGroups = _configQueryService!.extractDutyGroups(
        current.configs,
        configName,
      );
      final activeConfig = current.configs.firstWhere(
        (config) => config.name == configName,
        orElse: () => current.configs.first,
      );

      if (!ref.mounted) return;

      state = AsyncData(
        current.copyWith(
          activeConfigName: configName,
          dutyGroups: dutyGroups,
          activeConfig: activeConfig,
          isLoading: false,
        ),
      );
    } catch (e) {
      if (!ref.mounted) return;

      state = AsyncData(
        current.copyWith(
          error: 'Failed to set active config',
          isLoading: false,
        ),
      );
    }
  }

  Future<void> refreshConfigs() async {
    final current = await future;
    if (!ref.mounted) return;

    state = AsyncData(current.copyWith(isLoading: true));

    try {
      final configs = await _getConfigsUseCase!.execute();
      if (!ref.mounted) return;

      final settingsResult = await _getSettingsUseCase!.executeSafe();
      if (!ref.mounted) return;

      final settings = settingsResult.isSuccess ? settingsResult.value : null;

      final String? activeConfigName = settings?.activeConfigName;

      final List<String> dutyGroups =
          (activeConfigName != null && activeConfigName.isNotEmpty)
          ? _configQueryService!.extractDutyGroups(configs, activeConfigName)
          : <String>[];

      final DutyScheduleConfig? activeConfig =
          (activeConfigName != null && activeConfigName.isNotEmpty)
          ? (configs.where((c) => c.name == activeConfigName).isNotEmpty
                ? configs.firstWhere((c) => c.name == activeConfigName)
                : null)
          : null;

      if (!ref.mounted) return;

      state = AsyncData(
        current.copyWith(
          configs: configs,
          activeConfigName: activeConfigName ?? '',
          dutyGroups: dutyGroups,
          activeConfig: activeConfig,
          isLoading: false,
        ),
      );
    } catch (e) {
      if (!ref.mounted) return;

      state = AsyncData(
        current.copyWith(error: 'Failed to refresh configs', isLoading: false),
      );
    }
  }

  Future<void> clearError() async {
    final current = await future;
    if (!ref.mounted) return;

    state = AsyncData(current.copyWith(error: null));
  }
}
