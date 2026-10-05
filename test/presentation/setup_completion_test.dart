import 'package:dienstplan/core/cache/settings_cache.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/data/services/schedule_config_service.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/domain/entities/meta.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/domain/entities/settings.dart';
import 'package:dienstplan/domain/failures/result.dart';
import 'package:dienstplan/domain/repositories/config_repository.dart';
import 'package:dienstplan/domain/repositories/settings_repository.dart';
import 'package:dienstplan/domain/use_cases/generate_schedules_use_case.dart';
import 'package:dienstplan/domain/use_cases/get_configs_use_case.dart';
import 'package:dienstplan/domain/use_cases/get_settings_use_case.dart';
import 'package:dienstplan/domain/use_cases/reset_settings_use_case.dart';
import 'package:dienstplan/domain/use_cases/save_settings_use_case.dart';
import 'package:dienstplan/domain/use_cases/set_active_config_use_case.dart';
import 'package:dienstplan/presentation/state/config/config_notifier.dart';
import 'package:dienstplan/presentation/state/config/config_ui_state.dart';
import 'package:dienstplan/presentation/state/partner/partner_notifier.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_ui_state.dart';
import 'package:dienstplan/presentation/state/schedule_data/schedule_data_notifier.dart';
import 'package:dienstplan/presentation/state/schedule_data/schedule_data_ui_state.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/presentation/state/setup/setup_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _SettingsStore implements SettingsRepository {
  Settings? value = const Settings(myDutyGroup: 'Old group');
  @override
  Future<Result<Settings?>> getSettings() async => Result.success(value);
  @override
  Future<Result<void>> saveSettings(Settings settings) async {
    value = settings;
    return Result.success(null);
  }

  @override
  Future<Result<void>> clearSettings() async {
    value = null;
    return Result.success(null);
  }
}

class _Configs implements ConfigRepository {
  final config = DutyScheduleConfig(
    version: '1',
    meta: Meta(
      name: 'Plan',
      description: '',
      startDate: DateTime(2026),
      startWeekDay: 'Monday',
      days: const [],
    ),
    dutyTypes: const {},
    dutyTypeOrder: const [],
    rhythms: const {},
    dutyGroups: const [],
  );
  @override
  Future<Result<List<DutyScheduleConfig>>> getConfigs() async =>
      Result.success([config]);
  @override
  Future<Result<DutyScheduleConfig?>> getDefaultConfig() async =>
      Result.success(config);
  @override
  Future<Result<void>> saveConfig(DutyScheduleConfig config) async =>
      Result.success(null);
  @override
  Future<Result<void>> setDefaultConfig(DutyScheduleConfig config) async =>
      Result.success(null);
}

// Replace generation and platform setup flags, keeping setup navigation,
// settings persistence and settings/partner UI hydration real.
class _Generation implements GenerateSchedulesUseCase {
  @override
  Future<Result<List<Schedule>>> execute({
    required String configName,
    required DateTime startDate,
    required DateTime endDate,
  }) async => Result.success([]);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ActiveConfig implements SetActiveConfigUseCase {
  @override
  Future<Result<void>> execute(String name) async => Result.success(null);
}

class _ConfigService implements ScheduleConfigService {
  @override
  Future<void> markSetupCompleted() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Config extends ConfigNotifier {
  @override
  Future<ConfigUiState> build() async => ConfigUiState.initial();
  @override
  Future<void> refreshConfigs() async {}
}

class _Data extends ScheduleDataNotifier {
  @override
  Future<ScheduleDataUiState> build() async => ScheduleDataUiState.initial();
  @override
  void invalidateCache() {}
}

class _Coordinator extends ScheduleCoordinatorNotifier {
  @override
  Future<ScheduleUiState> build() async => ScheduleUiState.initial();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final withPartner in [false, true]) {
    test(
      'setup immediately exposes chosen group after completion (partner: $withPartner)',
      () async {
        SettingsCache.clearCache();
        addTearDown(SettingsCache.clearCache);
        final store = _SettingsStore();
        final configs = _Configs();
        final get = GetSettingsUseCase(store);
        final container = ProviderContainer(
          overrides: [
            getConfigsUseCaseProvider.overrideWith(
              (ref) async => GetConfigsUseCase(configs),
            ),
            configRepositoryProvider.overrideWith((ref) async => configs),
            setActiveConfigUseCaseProvider.overrideWith(
              (ref) async => _ActiveConfig(),
            ),
            generateSchedulesUseCaseProvider.overrideWith(
              (ref) async => _Generation(),
            ),
            getSettingsUseCaseProvider.overrideWith((ref) async => get),
            saveSettingsUseCaseProvider.overrideWith(
              (ref) async => SaveSettingsUseCase(store, get),
            ),
            resetSettingsUseCaseProvider.overrideWith(
              (ref) async => ResetSettingsUseCase(store),
            ),
            scheduleConfigServiceProvider.overrideWith(
              (ref) async => _ConfigService(),
            ),
            configProvider.overrideWith(_Config.new),
            scheduleDataProvider.overrideWith(_Data.new),
            scheduleCoordinatorProvider.overrideWith(_Coordinator.new),
          ],
        );
        addTearDown(container.dispose);
        final setupSub = container.listen(setupProvider, (_, _) {});
        final settingsSub = container.listen(settingsProvider, (_, _) {});
        final partnerSub = container.listen(partnerProvider, (_, _) {});
        addTearDown(setupSub.close);
        addTearDown(settingsSub.close);
        addTearDown(partnerSub.close);
        await container.read(setupProvider.future);
        expect(
          (await container.read(settingsProvider.future)).myDutyGroup,
          'Old group',
        );
        await container.read(partnerProvider.future);
        final setup = container.read(setupProvider.notifier);
        await setup.nextStep();
        await setup.setConfig(configs.config);
        await setup.nextStep();
        await setup.setDutyGroup('Group 4');
        await setup.nextStep();
        if (withPartner) {
          await setup.setPartnerConfig(configs.config);
          await setup.nextStep();
          await setup.setPartnerDutyGroup('Group 2');
        }
        await setup.nextStep();
        expect(store.value!.myDutyGroup, 'Group 4');
        expect(
          (await container.read(settingsProvider.future)).myDutyGroup,
          'Group 4',
        );
        expect(
          (await container.read(settingsProvider.future)).activeConfigName,
          'Plan',
        );
        expect(
          (await container.read(partnerProvider.future)).partnerDutyGroup,
          withPartner ? 'Group 2' : null,
        );
        expect(container.read(setupProvider).value!.isSetupCompleted, isTrue);
      },
    );
  }
}
