import 'dart:async';

import 'package:dienstplan/core/cache/settings_cache.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/domain/entities/duty_group.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/domain/entities/duty_type.dart';
import 'package:dienstplan/domain/entities/meta.dart';
import 'package:dienstplan/domain/entities/rhythm.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/domain/entities/settings.dart';
import 'package:dienstplan/domain/failures/result.dart';
import 'package:dienstplan/domain/repositories/config_repository.dart';
import 'package:dienstplan/domain/repositories/settings_repository.dart';
import 'package:dienstplan/domain/use_cases/ensure_month_schedules_use_case.dart';
import 'package:dienstplan/domain/use_cases/get_configs_use_case.dart';
import 'package:dienstplan/domain/use_cases/get_schedules_use_case.dart';
import 'package:dienstplan/presentation/state/calendar/calendar_notifier.dart';
import 'package:dienstplan/presentation/state/config/config_notifier.dart';
import 'package:dienstplan/presentation/state/partner/partner_notifier.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/state/schedule_data/schedule_data_notifier.dart';
import 'package:dienstplan/presentation/state/schedule_data/schedule_data_ui_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _SettingsStore implements SettingsRepository {
  Settings value = const Settings(activeConfigName: 'Plan A', myDutyGroup: '1');
  Completer<void>? saving;

  @override
  Future<Result<Settings?>> getSettings() async => Result.success(value);

  @override
  Future<Result<void>> saveSettings(Settings settings) async {
    await saving?.future;
    value = settings;
    return Result.success(null);
  }

  @override
  Future<Result<void>> clearSettings() async => Result.success(null);
}

class _Configs implements ConfigRepository {
  final configs = [
    for (final name in ['Plan A', 'Plan B'])
      DutyScheduleConfig(
        version: '1',
        meta: Meta(
          name: name,
          description: '',
          startDate: DateTime(2026),
          startWeekDay: 'Monday',
          days: const [],
        ),
        dutyTypes: const {'F': DutyType(label: 'Frühdienst')},
        dutyTypeOrder: const ['F'],
        rhythms: const {
          'r': Rhythm(
            lengthWeeks: 1,
            pattern: [
              ['F'],
            ],
          ),
        },
        dutyGroups: const [
          DutyGroup(id: '1', name: '1', rhythm: 'r', offsetWeeks: 0),
        ],
      ),
  ];

  @override
  Future<Result<List<DutyScheduleConfig>>> getConfigs() async =>
      Result.success(configs);
  @override
  Future<Result<DutyScheduleConfig?>> getDefaultConfig() async =>
      Result.success(configs.first);
  @override
  Future<Result<void>> saveConfig(DutyScheduleConfig config) async =>
      Result.success(null);
  @override
  Future<Result<void>> setDefaultConfig(DutyScheduleConfig config) async =>
      Result.success(null);
}

// Data loading is independent here; keep the coordinator and its auto-dispose
// calendar, config and partner notifiers real, as in the calendar/settings UI.
class _Data extends ScheduleDataNotifier {
  @override
  Future<ScheduleDataUiState> build() async =>
      ScheduleDataUiState.initial().copyWith(
        schedules: [
          Schedule(
            date: DateTime.now(),
            service: 'Frühdienst',
            dutyGroupId: '1',
            dutyTypeId: 'F',
            dutyGroupName: '1',
            configName: 'Plan A',
          ),
        ],
      );
}

class _Schedules implements GetSchedulesUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Ensure implements EnsureMonthSchedulesUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late _SettingsStore store;
  late _Configs configs;
  late Completer<GetConfigsUseCase> configsReady;
  late Completer<void> configStarted;

  setUp(() {
    SettingsCache.clearCache();
    store = _SettingsStore();
    configs = _Configs();
    configsReady = Completer<GetConfigsUseCase>();
    configStarted = Completer<void>();
    container = ProviderContainer(
      overrides: [
        settingsRepositoryProvider.overrideWith((ref) async => store),
        configRepositoryProvider.overrideWith((ref) async => configs),
        getConfigsUseCaseProvider.overrideWith((ref) {
          if (!configStarted.isCompleted) configStarted.complete();
          return configsReady.future;
        }),
        getSchedulesUseCaseProvider.overrideWith((ref) async => _Schedules()),
        ensureMonthSchedulesUseCaseProvider.overrideWith(
          (ref) async => _Ensure(),
        ),
        scheduleDataProvider.overrideWith(_Data.new),
      ],
    );
    addTearDown(() {
      container.dispose();
      SettingsCache.clearCache();
    });
    // The UI subscribes only to the coordinator, not to its sub-notifiers.
    container.listen(scheduleCoordinatorProvider, (_, _) {});
  });

  test(
    'slow startup retains sub-notifiers and exposes loaded duties',
    () async {
      final loading = container.read(scheduleCoordinatorProvider.future);
      // Let coordinator initialization reach the delayed config dependency.
      await configStarted.future;
      await container.pump();
      configsReady.complete(GetConfigsUseCase(configs));
      final loaded = await loading;
      expect(loaded.error, isNull);
      expect(loaded.activeConfigName, 'Plan A');
      expect(loaded.schedules.single.service, 'Frühdienst');
      final configNotifier = container.read(configProvider.notifier);
      final partnerNotifier = container.read(partnerProvider.notifier);
      final calendarNotifier = container.read(calendarProvider.notifier);
      await container.pump();
      expect(container.read(configProvider.notifier), same(configNotifier));
      expect(container.read(partnerProvider.notifier), same(partnerNotifier));
      expect(container.read(calendarProvider.notifier), same(calendarNotifier));
    },
  );

  test(
    'switching plans survives async persistence and preserves selected day',
    () async {
      configsReady.complete(GetConfigsUseCase(configs));
      await container.read(scheduleCoordinatorProvider.future);
      final coordinator = container.read(scheduleCoordinatorProvider.notifier);
      final selected = DateTime(2026, 10, 19);
      await coordinator.setSelectedDay(selected);
      store.saving = Completer<void>();
      final switching = coordinator.setActiveConfig('Plan B');
      await Future<void>.delayed(Duration.zero);
      await container.pump();
      store.saving!.complete();
      await switching;
      await container.pump();
      final state = await container.read(scheduleCoordinatorProvider.future);
      expect(state.error, isNull);
      expect(state.isLoading, isFalse);
      expect(state.activeConfigName, 'Plan B');
      expect(state.activeConfig?.name, 'Plan B');
      expect(state.selectedDay, selected);
      expect(store.value.activeConfigName, 'Plan B');
      expect(
        (await container.read(configProvider.future)).activeConfigName,
        'Plan B',
      );
      await coordinator.setActiveConfig('Plan A');
      expect(store.value.activeConfigName, 'Plan A');
      expect(
        container.read(scheduleCoordinatorProvider).value!.activeConfigName,
        'Plan A',
      );
    },
  );
}
