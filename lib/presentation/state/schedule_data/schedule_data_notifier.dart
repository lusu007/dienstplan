import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dienstplan/presentation/state/schedule_data/schedule_data_ui_state.dart';
import 'package:dienstplan/domain/use_cases/get_schedules_use_case.dart';
import 'package:dienstplan/domain/use_cases/generate_schedules_use_case.dart';
import 'package:dienstplan/domain/use_cases/ensure_month_schedules_use_case.dart';
import 'package:dienstplan/domain/use_cases/get_settings_use_case.dart';
import 'package:dienstplan/domain/use_cases/save_settings_use_case.dart';
import 'package:dienstplan/domain/use_cases/list_personal_calendar_entries_use_case.dart';
import 'package:dienstplan/domain/policies/date_range_policy.dart';
import 'package:dienstplan/domain/services/schedule_merge_service.dart';
import 'package:dienstplan/domain/services/personal_entry_schedule_mapper.dart';
import 'package:dienstplan/domain/value_objects/date_range.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/core/constants/schedule_constants.dart';
import 'package:dienstplan/domain/failures/failure.dart';
import 'package:dienstplan/domain/failures/result.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/domain/entities/personal_calendar_entry.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/domain/entities/settings.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_cache_manager.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_loading_queue.dart';

part 'schedule_data_notifier.g.dart';

@Riverpod(keepAlive: true)
class ScheduleDataNotifier extends _$ScheduleDataNotifier {
  GetSchedulesUseCase? _getSchedulesUseCase;
  GenerateSchedulesUseCase? _generateSchedulesUseCase;
  EnsureMonthSchedulesUseCase? _ensureMonthSchedulesUseCase;
  GetSettingsUseCase? _getSettingsUseCase;
  SaveSettingsUseCase? _saveSettingsUseCase;
  DateRangePolicy? _dateRangePolicy;
  ScheduleMergeService? _scheduleMergeService;
  ListPersonalCalendarEntriesUseCase? _listPersonalCalendarEntriesUseCase;

  static ScheduleDataUiState? _cachedState;
  static DateTime? _lastCacheTime;
  static const Duration _cacheValidityDuration = Duration(minutes: 5);
  static final ScheduleCacheManager _cacheManager = ScheduleCacheManager();
  static final ScheduleLoadingQueue _loadingQueue = ScheduleLoadingQueue();
  static final Map<String, String> _lastKnownConfigVersions =
      <String, String>{};

  @override
  Future<ScheduleDataUiState> build() async {
    _getSchedulesUseCase ??= await ref.read(getSchedulesUseCaseProvider.future);
    _generateSchedulesUseCase ??= await ref.read(
      generateSchedulesUseCaseProvider.future,
    );
    _ensureMonthSchedulesUseCase ??= await ref.read(
      ensureMonthSchedulesUseCaseProvider.future,
    );
    _getSettingsUseCase ??= await ref.read(getSettingsUseCaseProvider.future);
    _saveSettingsUseCase ??= await ref.read(saveSettingsUseCaseProvider.future);
    _dateRangePolicy ??= ref.read(dateRangePolicyProvider);
    _scheduleMergeService ??= ref.read(scheduleMergeServiceProvider);
    _listPersonalCalendarEntriesUseCase ??= await ref.read(
      listPersonalCalendarEntriesUseCaseProvider.future,
    );

    // Return cached state if available and still valid, otherwise initialize
    if (_cachedState != null && _isCacheValid()) {
      AppLogger.d('ScheduleDataNotifier: Returning cached state');
      return _cachedState!;
    }

    return await _initialize();
  }

  bool _isCacheValid() {
    if (_lastCacheTime == null) return false;
    return DateTime.now().difference(_lastCacheTime!) < _cacheValidityDuration;
  }

  Future<ScheduleDataUiState> _initialize() async {
    try {
      // Detect config version changes and invalidate caches if needed
      await _invalidateCacheOnVersionChange();
      final Result<Settings?> settingsResult = await _getSettingsUseCase!
          .execute();
      if (settingsResult.isFailure) {
        final message = await _presentFailure(settingsResult.failure);
        return ScheduleDataUiState.initial().copyWith(
          isLoading: false,
          error: message,
        );
      }
      final settings = settingsResult.valueIfSuccess;

      final activeConfigName = settings?.activeConfigName;
      final preferredDutyGroup = settings?.myDutyGroup;
      final selectedDutyGroup = settings?.selectedDutyGroup;

      final DateTime now = DateTime.now();
      final DateRange initialRange = _dateRangePolicy!.computeInitialRange(now);

      List<Schedule> schedules = [];
      if (activeConfigName != null) {
        AppLogger.d(
          'ScheduleDataNotifier: Initial load range: ${initialRange.start} to ${initialRange.end}',
        );

        final schedulesResult = await _getSchedulesUseCase!.executeForDateRange(
          startDate: initialRange.start,
          endDate: initialRange.end,
          configName: activeConfigName,
        );

        if (schedulesResult.isSuccess) {
          schedules = schedulesResult.value;
          final List<Result<List<Schedule>>> ensureResults =
              await Future.wait(<Future<Result<List<Schedule>>>>[
                for (
                  int i = -kMonthsPrefetchRadius;
                  i <= kMonthsPrefetchRadius;
                  i++
                )
                  _ensureMonthSchedulesUseCase!.execute(
                    configName: activeConfigName,
                    monthStart: DateTime(now.year, now.month + i, 1),
                  ),
              ]);
          final int ensureCount = ensureResults.length;
          for (int idx = 0; idx < ensureCount; idx++) {
            final Result<List<Schedule>> ensured = ensureResults[idx];
            final int monthOffset = -kMonthsPrefetchRadius + idx;
            final DateTime ensuredMonth = DateTime(
              now.year,
              now.month + monthOffset,
              1,
            );
            if (ensured.isSuccess) {
              schedules = _scheduleMergeService!.upsertByKey(
                existing: schedules,
                incoming: ensured.value,
              );
            } else {
              await AppLogger.w(
                'Failed to ensure schedules during cold start '
                '(configName=$activeConfigName, year=${ensuredMonth.year}, '
                'month=${ensuredMonth.month}, failureCode=${ensured.failure.code}, '
                'reason=${ensured.failure.technicalMessage})',
              );
            }
          }
        } else {
          final message = await _presentFailure(schedulesResult.failure);
          return ScheduleDataUiState(
            isLoading: false,
            error: message,
            schedules: const <Schedule>[],
            activeConfigName: activeConfigName,
            preferredDutyGroup: preferredDutyGroup,
            selectedDutyGroup: selectedDutyGroup,
            holidayAccentColorValue: settings?.holidayAccentColorValue,
          );
        }
      }

      schedules = await _attachPersonalSchedules(
        officialSchedules: schedules,
        rangeStart: initialRange.start,
        rangeEnd: initialRange.end,
      );

      final initialState = ScheduleDataUiState(
        isLoading: false,
        error: null,
        schedules: schedules,
        activeConfigName: activeConfigName ?? '',
        preferredDutyGroup: preferredDutyGroup ?? '',
        selectedDutyGroup: selectedDutyGroup,
        holidayAccentColorValue: settings?.holidayAccentColorValue,
      );
      _cachedState = initialState;
      _lastCacheTime = DateTime.now();
      return initialState;
    } catch (e) {
      return ScheduleDataUiState.initial().copyWith(
        error: 'Failed to initialize schedule data',
      );
    }
  }

  List<Schedule> _onlyOfficialSchedules(List<Schedule> schedules) {
    return schedules.where((Schedule s) => !s.isUserDefined).toList();
  }

  DateRange _personalLoadRangeCovering(DateTime a, DateTime b) {
    final DateTime firstMonth = a.isBefore(b)
        ? DateTime(a.year, a.month, 1)
        : DateTime(b.year, b.month, 1);
    final DateTime lastMonth = a.isAfter(b)
        ? DateTime(a.year, a.month, 1)
        : DateTime(b.year, b.month, 1);
    final DateRange r1 = _dateRangePolicy!.computeFocusedRange(firstMonth);
    final DateRange r2 = _dateRangePolicy!.computeFocusedRange(lastMonth);
    final DateTime start = r1.start.isBefore(r2.start) ? r1.start : r2.start;
    final DateTime end = r1.end.isAfter(r2.end) ? r1.end : r2.end;
    return DateRange(start: start, end: end);
  }

  Future<List<Schedule>> _loadPersonalSchedulesMapped(
    DateTime startDate,
    DateTime endDate,
  ) async {
    _listPersonalCalendarEntriesUseCase ??= await ref.read(
      listPersonalCalendarEntriesUseCaseProvider.future,
    );
    final Result<List<PersonalCalendarEntry>> result =
        await _listPersonalCalendarEntriesUseCase!.executeBetween(
          startDate: startDate,
          endDate: endDate,
        );
    if (result.isFailure) {
      AppLogger.w(
        'ScheduleDataNotifier: Failed to load personal calendar entries '
        '(reason=${result.failure.technicalMessage})',
      );
      return const <Schedule>[];
    }
    return result.value
        .map(PersonalEntryScheduleMapper.toSchedule)
        .toList(growable: false);
  }

  Future<List<Schedule>> _attachPersonalSchedules({
    required List<Schedule> officialSchedules,
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) async {
    final DateRange wide = _personalLoadRangeCovering(rangeStart, rangeEnd);
    final List<Schedule> personal = await _loadPersonalSchedulesMapped(
      wide.start,
      wide.end,
    );
    return <Schedule>[...personal, ...officialSchedules];
  }

  /// Reloads personal rows from SQLite and merges them with the current official schedules.
  Future<void> refreshPersonalCalendarEntries() async {
    final ScheduleDataUiState baseline =
        state.value ?? _cachedState ?? await future;
    final List<Schedule> official = _onlyOfficialSchedules(baseline.schedules);
    DateTime rangeStart;
    DateTime rangeEnd;
    if (official.isEmpty) {
      final DateRange r = _dateRangePolicy!.computeInitialRange(DateTime.now());
      rangeStart = r.start;
      rangeEnd = r.end;
    } else {
      DateTime minD = official.first.date;
      DateTime maxD = official.first.date;
      for (final Schedule s in official) {
        if (s.date.isBefore(minD)) {
          minD = s.date;
        }
        if (s.date.isAfter(maxD)) {
          maxD = s.date;
        }
      }
      rangeStart = minD;
      rangeEnd = maxD;
    }
    final List<Schedule> merged = await _attachPersonalSchedules(
      officialSchedules: official,
      rangeStart: rangeStart,
      rangeEnd: rangeEnd,
    );
    final ScheduleDataUiState updated = baseline.copyWith(schedules: merged);
    _cachedState = updated;
    _lastCacheTime = DateTime.now();
    if (ref.mounted) {
      state = AsyncData(updated);
    }
  }

  Future<void> _invalidateCacheOnVersionChange() async {
    try {
      final getConfigs = await ref.read(getConfigsUseCaseProvider.future);
      final Result<List<DutyScheduleConfig>> configsResult = await getConfigs
          .execute();
      if (configsResult.isFailure) {
        return;
      }
      final List<DutyScheduleConfig> configs = configsResult.value;
      bool anyInvalidated = false;
      for (final DutyScheduleConfig c in configs) {
        final String name = c.name;
        final String version = c.version;
        final String? previous = _lastKnownConfigVersions[name];
        if (previous != null && previous != version) {
          _cacheManager.clearCacheForConfig(name);
          anyInvalidated = true;
        }
        _lastKnownConfigVersions[name] = version;
      }
      if (anyInvalidated) {
        _cachedState = null;
        _lastCacheTime = null;
        // Proactively ensure current month for active config so UI updates
        final Result<Settings?> settingsResult = await _getSettingsUseCase!
            .execute();
        final Settings? settings = settingsResult.valueIfSuccess;
        final String? activeName = settings?.activeConfigName;
        if (activeName != null &&
            activeName.isNotEmpty &&
            settingsResult.isSuccess) {
          final DateTime now = DateTime.now();
          final Result<List<Schedule>> ensureResult =
              await _ensureMonthSchedulesUseCase!.execute(
                monthStart: DateTime(now.year, now.month, 1),
                configName: activeName,
              );
          if (ensureResult.isFailure) {
            return;
          }
          // Reload the range into state and cache
          final DateTime startDate = DateTime(now.year, now.month, 1);
          final DateTime endDate = DateTime(now.year, now.month + 1, 0);
          await loadSchedulesForDateRange(
            startDate: startDate,
            endDate: endDate,
            configName: activeName,
          );
        }
      }
    } catch (_) {
      // Best-effort invalidation; ignore errors
    }
  }

  Future<void> loadSchedulesForDateRange({
    required DateTime startDate,
    required DateTime endDate,
    required String configName,
  }) async {
    // Check cache first
    final cachedSchedules = _cacheManager.getSchedules(
      startDate,
      endDate,
      configName,
    );
    if (cachedSchedules != null) {
      AppLogger.d(
        'ScheduleDataNotifier: Using cached data for range ${startDate.toIso8601String()} to ${endDate.toIso8601String()}',
      );
      final baseline = state.value ?? _cachedState ?? await future;
      final List<Schedule> baselineOfficial = _onlyOfficialSchedules(
        baseline.schedules,
      );
      final List<Schedule> mergedOfficial = _scheduleMergeService!.upsertByKey(
        existing: baselineOfficial,
        incoming: cachedSchedules,
      );
      final List<Schedule> mergedSchedules = await _attachPersonalSchedules(
        officialSchedules: mergedOfficial,
        rangeStart: startDate,
        rangeEnd: endDate,
      );

      final updated = baseline.copyWith(
        schedules: mergedSchedules,
        activeConfigName: configName,
        isLoading: false,
      );
      _cachedState = updated;
      _lastCacheTime = DateTime.now();
      if (ref.mounted) {
        state = AsyncData(updated);
      }
      return;
    }

    // Use loading queue to prevent duplicate requests
    final operationKey = _loadingQueue.generateOperationKey(
      startDate,
      endDate,
      configName,
    );
    final wasQueued = await _loadingQueue.executeIfNotPending(
      operationKey,
      () async => await _performScheduleLoading(startDate, endDate, configName),
    );

    if (!wasQueued) {
      // Operation already in progress, skipping
    }
  }

  Future<void> _performScheduleLoading(
    DateTime startDate,
    DateTime endDate,
    String configName,
  ) async {
    // Ensure dependencies are available even if provider rebuilt and returned cached state
    _getSchedulesUseCase ??= await ref.read(getSchedulesUseCaseProvider.future);
    _scheduleMergeService ??= ref.read(scheduleMergeServiceProvider);

    final ScheduleDataUiState baseline =
        state.value ?? _cachedState ?? await future;
    final ScheduleDataUiState loadingState = baseline.copyWith(isLoading: true);
    _cachedState = loadingState;
    if (ref.mounted) {
      state = AsyncData(loadingState);
    }

    try {
      final schedulesResult = await _getSchedulesUseCase!.executeForDateRange(
        startDate: startDate,
        endDate: endDate,
        configName: configName,
      );

      if (schedulesResult.isSuccess) {
        final newSchedules = schedulesResult.value;

        // Cache the results
        _cacheManager.setSchedules(
          startDate,
          endDate,
          configName,
          newSchedules,
        );

        // Use upsert merge to avoid dropping existing items when loading deltas
        final List<Schedule> baselineOfficial = _onlyOfficialSchedules(
          baseline.schedules,
        );
        final List<Schedule> mergedOfficial = _scheduleMergeService!
            .upsertByKey(
              existing: baselineOfficial,
              incoming: newSchedules,
            );
        final List<Schedule> mergedSchedules = await _attachPersonalSchedules(
          officialSchedules: mergedOfficial,
          rangeStart: startDate,
          rangeEnd: endDate,
        );

        final ScheduleDataUiState updated = baseline.copyWith(
          schedules: mergedSchedules,
          activeConfigName: configName,
          isLoading: false,
        );
        _cachedState = updated;
        _lastCacheTime = DateTime.now();
        if (ref.mounted) {
          state = AsyncData(updated);
        }
      } else {
        final message = await _presentFailure(schedulesResult.failure);
        final ScheduleDataUiState errored = baseline.copyWith(
          error: message,
          isLoading: false,
        );
        _cachedState = errored;
        if (ref.mounted) {
          state = AsyncData(errored);
        }
      }
    } catch (e) {
      final ScheduleDataUiState errored =
          (state.value ?? _cachedState ?? ScheduleDataUiState.initial())
              .copyWith(error: 'Failed to load schedules', isLoading: false);
      _cachedState = errored;
      if (ref.mounted) {
        state = AsyncData(errored);
      }
    }
  }

  Future<void> generateSchedulesForMonth({
    required DateTime month,
    required String configName,
  }) async {
    final current = await future;
    if (!ref.mounted) return;

    state = AsyncData(current.copyWith(isLoading: true));

    try {
      final Result<List<Schedule>> genResult = await _generateSchedulesUseCase!
          .execute(
            startDate: DateTime(month.year, month.month, 1),
            endDate: DateTime(month.year, month.month + 1, 0),
            configName: configName,
          );
      if (genResult.isFailure) {
        if (ref.mounted) {
          state = AsyncData(
            current.copyWith(
              error: genResult.failure.technicalMessage,
              isLoading: false,
            ),
          );
        }
        return;
      }

      if (!ref.mounted) return;

      // Reload schedules for the month
      final startDate = DateTime(month.year, month.month, 1);
      final endDate = DateTime(month.year, month.month + 1, 0);

      await loadSchedulesForDateRange(
        startDate: startDate,
        endDate: endDate,
        configName: configName,
      );
    } catch (e) {
      if (ref.mounted) {
        state = AsyncData(
          current.copyWith(
            error: 'Failed to generate schedules',
            isLoading: false,
          ),
        );
      }
    }
  }

  Future<void> ensureMonthSchedules({
    required DateTime month,
    required String configName,
  }) async {
    final current = await future;
    if (!ref.mounted) return;

    // Deduplicate ensures/loads by month using loading queue
    final DateTime startDate = DateTime(month.year, month.month, 1);
    final DateTime endDate = DateTime(month.year, month.month + 1, 0);
    final String operationKey = _loadingQueue.generateOperationKey(
      startDate,
      endDate,
      configName,
    );

    await _loadingQueue.executeIfNotPending(operationKey, () async {
      try {
        final Result<List<Schedule>> ensureResult =
            await _ensureMonthSchedulesUseCase!.execute(
              monthStart: month,
              configName: configName,
            );
        if (ensureResult.isFailure) {
          if (ref.mounted) {
            state = AsyncData(
              current.copyWith(error: ensureResult.failure.technicalMessage),
            );
          }
          return;
        }

        if (!ref.mounted) return;

        // Load directly inside the existing queued operation to avoid
        // re-entering the loading queue with the same key.
        await _performScheduleLoading(startDate, endDate, configName);
      } catch (e) {
        if (ref.mounted) {
          state = AsyncData(
            current.copyWith(error: 'Failed to ensure month schedules'),
          );
        }
      }
    });
  }

  Future<void> setSelectedDutyGroup(String? dutyGroup) async {
    final current = await future;
    if (!ref.mounted) return;

    // Only update if the value actually changed to avoid unnecessary rebuilds
    if (current.selectedDutyGroup != dutyGroup) {
      state = AsyncData(current.copyWith(selectedDutyGroup: dutyGroup));
    }
  }

  Future<void> refreshSelectedDutyGroupFromSettings() async {
    final current = await future;
    if (!ref.mounted) return;

    try {
      final Result<Settings?> settingsResult = await _getSettingsUseCase!
          .execute();
      final Settings? settings = settingsResult.valueIfSuccess;
      final selectedDutyGroup = settings?.selectedDutyGroup;

      // Only update if the value actually changed
      if (current.selectedDutyGroup != selectedDutyGroup) {
        state = AsyncData(
          current.copyWith(selectedDutyGroup: selectedDutyGroup),
        );
      }
    } catch (e) {
      // Ignore errors to avoid disrupting the filter
    }
  }

  Future<void> clearError() async {
    final current = await future;
    if (!ref.mounted) return;
    state = AsyncData(current.copyWith(error: null));
  }

  /// Invalidates the cached state to force reload with new settings
  /// This instance method only affects the current instance's cache
  void invalidateCache() {
    _cachedState = null;
    _lastCacheTime = null;
  }

  /// Static method to invalidate cache for a specific config from external services
  /// This method is safe to call from external services as it only modifies static cache fields
  /// and uses the shared cache manager which is designed for multi-instance scenarios
  static void invalidateCacheForConfig(String configName) {
    // Clear the cache manager for the specific config
    _cacheManager.clearCacheForConfig(configName);

    // Clear static cache state to force reload on next access
    _cachedState = null;
    _lastCacheTime = null;
    _lastKnownConfigVersions.remove(configName);

    AppLogger.i(
      'ScheduleDataNotifier: Invalidated cache for config $configName',
    );
  }

  Future<String> _presentFailure(Failure failure) async {
    // This would need to be implemented based on your failure presentation logic
    // For now, return a simple error message
    return 'An error occurred: ${failure.toString()}';
  }
}
