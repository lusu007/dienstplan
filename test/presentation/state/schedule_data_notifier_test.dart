import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/domain/entities/duty_type.dart';
import 'package:dienstplan/domain/entities/personal_calendar_entry.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/domain/entities/settings.dart';
import 'package:dienstplan/domain/failures/result.dart';
import 'package:dienstplan/domain/repositories/config_repository.dart';
import 'package:dienstplan/domain/repositories/personal_calendar_repository.dart';
import 'package:dienstplan/domain/repositories/schedule_repository.dart';
import 'package:dienstplan/domain/repositories/settings_repository.dart';
import 'package:dienstplan/domain/use_cases/ensure_month_schedules_use_case.dart';
import 'package:dienstplan/domain/use_cases/generate_schedules_use_case.dart';
import 'package:dienstplan/domain/use_cases/get_configs_use_case.dart';
import 'package:dienstplan/domain/use_cases/get_schedules_use_case.dart';
import 'package:dienstplan/domain/use_cases/get_settings_use_case.dart';
import 'package:dienstplan/domain/use_cases/list_personal_calendar_entries_use_case.dart';
import 'package:dienstplan/presentation/state/calendar/calendar_notifier.dart';
import 'package:dienstplan/presentation/state/schedule_data/schedule_data_notifier.dart';

class _FakeScheduleRepository implements ScheduleRepository {
  @override
  Future<Result<void>> clearSchedules() async => Result.success<void>(null);

  @override
  Future<Result<int>> countSchedulesForMonth({
    required DateTime month,
    String? configName,
  }) async => Result.success<int>(0);

  @override
  Future<Result<void>> deleteSchedulesByConfigName(String configName) async =>
      Result.success<void>(null);

  @override
  Future<Result<List<DutyType>>> getDutyTypes({
    required String configName,
  }) async => Result.success<List<DutyType>>(const <DutyType>[]);

  @override
  Future<Result<List<Schedule>>> getSchedules() async =>
      Result.success<List<Schedule>>(const <Schedule>[]);

  @override
  Future<Result<List<Schedule>>> getSchedulesForDateRange({
    required DateTime start,
    required DateTime end,
    String? configName,
  }) async => Result.success<List<Schedule>>(const <Schedule>[]);

  @override
  Future<Result<void>> saveSchedules(List<Schedule> schedules) async =>
      Result.success<void>(null);
}

class _FakeConfigRepository implements ConfigRepository {
  @override
  Future<Result<List<DutyScheduleConfig>>> getConfigs() async =>
      Result.success<List<DutyScheduleConfig>>(const <DutyScheduleConfig>[]);

  @override
  Future<Result<DutyScheduleConfig?>> getDefaultConfig() async =>
      Result.success<DutyScheduleConfig?>(null);

  @override
  Future<Result<void>> saveConfig(DutyScheduleConfig config) async =>
      Result.success<void>(null);

  @override
  Future<Result<void>> setDefaultConfig(DutyScheduleConfig config) async =>
      Result.success<void>(null);
}

class _FakeSettingsRepository implements SettingsRepository {
  @override
  Future<Result<void>> clearSettings() async => Result.success<void>(null);

  @override
  Future<Result<Settings?>> getSettings() async =>
      Result.success<Settings?>(const Settings(activeConfigName: null));

  @override
  Future<Result<void>> saveSettings(Settings settings) async =>
      Result.success<void>(null);
}

class _FakePersonalCalendarRepository implements PersonalCalendarRepository {
  DateTime? lastStartDate;
  DateTime? lastEndDate;

  @override
  Future<Result<void>> deleteAll() async => Result.success<void>(null);

  @override
  Future<Result<void>> deleteById(String id) async =>
      Result.success<void>(null);

  @override
  Future<Result<List<PersonalCalendarEntry>>> listBetween({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    lastStartDate = startDate;
    lastEndDate = endDate;
    final PersonalCalendarEntry futureEntry = PersonalCalendarEntry(
      id: 'pe-future',
      kind: PersonalCalendarEntryKind.appointment,
      title: 'Future appointment',
      notes: null,
      date: DateTime.utc(2032, 8, 15),
      isAllDay: true,
      startMinutesFromMidnight: null,
      endMinutesFromMidnight: null,
      dutyGroupName: 'Private',
      createdAtMs: 1,
      updatedAtMs: 1,
    );
    return Result.success<List<PersonalCalendarEntry>>(<PersonalCalendarEntry>[
      futureEntry,
    ]);
  }

  @override
  Future<Result<void>> upsert(PersonalCalendarEntry entry) async =>
      Result.success<void>(null);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'refreshPersonalCalendarEntries includes focused and selected later-year range',
    () async {
      final _FakeScheduleRepository scheduleRepository =
          _FakeScheduleRepository();
      final _FakeConfigRepository configRepository = _FakeConfigRepository();
      final _FakeSettingsRepository settingsRepository =
          _FakeSettingsRepository();
      final _FakePersonalCalendarRepository personalRepository =
          _FakePersonalCalendarRepository();
      final GenerateSchedulesUseCase generateSchedulesUseCase =
          GenerateSchedulesUseCase(scheduleRepository, configRepository);
      final EnsureMonthSchedulesUseCase ensureMonthSchedulesUseCase =
          EnsureMonthSchedulesUseCase(
            scheduleRepository,
            configRepository,
            generateSchedulesUseCase,
          );
      final ProviderContainer container = ProviderContainer(
        overrides: [
          getSchedulesUseCaseProvider.overrideWith(
            (Ref ref) async => GetSchedulesUseCase(scheduleRepository),
          ),
          generateSchedulesUseCaseProvider.overrideWith(
            (Ref ref) async => generateSchedulesUseCase,
          ),
          ensureMonthSchedulesUseCaseProvider.overrideWith(
            (Ref ref) async => ensureMonthSchedulesUseCase,
          ),
          getSettingsUseCaseProvider.overrideWith(
            (Ref ref) async => GetSettingsUseCase(settingsRepository),
          ),
          getConfigsUseCaseProvider.overrideWith(
            (Ref ref) async => GetConfigsUseCase(configRepository),
          ),
          listPersonalCalendarEntriesUseCaseProvider.overrideWith(
            (Ref ref) async =>
                ListPersonalCalendarEntriesUseCase(personalRepository),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(calendarProvider.future);
      await container
          .read(calendarProvider.notifier)
          .setFocusedDay(DateTime(2032, 7, 1));
      await container
          .read(calendarProvider.notifier)
          .setSelectedDay(DateTime(2032, 8, 15));
      await container.read(scheduleDataProvider.future);
      await container
          .read(scheduleDataProvider.notifier)
          .refreshPersonalCalendarEntries();
      final DateTime startDate = personalRepository.lastStartDate!;
      final DateTime endDate = personalRepository.lastEndDate!;
      expect(
        startDate.isBefore(DateTime(2032, 7, 1)) ||
            startDate.isAtSameMomentAs(DateTime(2032, 7, 1)),
        isTrue,
      );
      expect(
        endDate.isAfter(DateTime(2032, 8, 15)) ||
            endDate.isAtSameMomentAs(DateTime(2032, 8, 15)),
        isTrue,
      );
      final List<Schedule> schedules = container
          .read(scheduleDataProvider)
          .value!
          .schedules;
      expect(
        schedules.any((Schedule schedule) => schedule.isUserDefined),
        isTrue,
      );
      expect(
        schedules.any((Schedule schedule) => schedule.date.year == 2032),
        isTrue,
      );
    },
  );
}
