import 'dart:async';

import 'package:dienstplan/core/cache/settings_cache.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/domain/entities/settings.dart';
import 'package:dienstplan/domain/failures/result.dart';
import 'package:dienstplan/domain/repositories/config_repository.dart';
import 'package:dienstplan/domain/repositories/settings_repository.dart';
import 'package:dienstplan/domain/use_cases/get_configs_use_case.dart';
import 'package:dienstplan/domain/use_cases/get_settings_use_case.dart';
import 'package:dienstplan/domain/use_cases/save_settings_use_case.dart';
import 'package:dienstplan/domain/use_cases/set_active_config_use_case.dart';
import 'package:dienstplan/presentation/state/config/config_notifier.dart';
import 'package:dienstplan/presentation/state/config/config_ui_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Configs implements ConfigRepository {
  @override
  Future<Result<List<DutyScheduleConfig>>> getConfigs() async =>
      Result.success([]);
  @override
  Future<Result<DutyScheduleConfig?>> getDefaultConfig() async =>
      Result.success(null);
  @override
  Future<Result<void>> saveConfig(DutyScheduleConfig config) async =>
      Result.success(null);
  @override
  Future<Result<void>> setDefaultConfig(DutyScheduleConfig config) async =>
      Result.success(null);
}

class _Settings implements SettingsRepository {
  @override
  Future<Result<Settings?>> getSettings() async => Result.success(null);
  @override
  Future<Result<void>> saveSettings(Settings settings) async =>
      Result.success(null);
  @override
  Future<Result<void>> clearSettings() async => Result.success(null);
}

void main() {
  setUp(SettingsCache.clearCache);
  tearDown(SettingsCache.clearCache);
  for (final retainListener in [false, true]) {
    test(
      'config initializes across async dependencies with listener=$retainListener',
      () async {
        final configsReady = Completer<GetConfigsUseCase>();
        final activeReady = Completer<SetActiveConfigUseCase>();
        final settingsReady = Completer<GetSettingsUseCase>();
        final saveReady = Completer<SaveSettingsUseCase>();
        final configs = _Configs();
        final settings = _Settings();
        final getSettings = GetSettingsUseCase(settings);
        final container = ProviderContainer.test(
          overrides: [
            getConfigsUseCaseProvider.overrideWith(
              (ref) => configsReady.future,
            ),
            setActiveConfigUseCaseProvider.overrideWith(
              (ref) => activeReady.future,
            ),
            getSettingsUseCaseProvider.overrideWith(
              (ref) => settingsReady.future,
            ),
            saveSettingsUseCaseProvider.overrideWith((ref) => saveReady.future),
          ],
        );
        if (retainListener) container.listen(configProvider, (_, _) {});
        final loading = container.read(configProvider.future);
        final completed = expectLater(
          loading,
          completion(
            isA<ConfigUiState>()
                .having((s) => s.error, 'error', isNull)
                .having((s) => s.configs, 'configs', isEmpty)
                .having((s) => s.isLoading, 'isLoading', false),
          ),
        );
        await container.pump();
        configsReady.complete(GetConfigsUseCase(configs));
        await container.pump();
        activeReady.complete(SetActiveConfigUseCase(configs));
        await container.pump();
        settingsReady.complete(getSettings);
        await container.pump();
        saveReady.complete(SaveSettingsUseCase(settings, getSettings));
        await completed;
      },
    );
  }
}
