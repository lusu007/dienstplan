import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dienstplan/presentation/state/schedule_data/schedule_data_ui_state.dart';
import 'package:dienstplan/domain/use_cases/get_schedules_use_case.dart';
import 'package:dienstplan/domain/use_cases/generate_schedules_use_case.dart';
import 'package:dienstplan/domain/use_cases/ensure_month_schedules_use_case.dart';
import 'package:dienstplan/domain/use_cases/get_settings_use_case.dart';
import 'package:dienstplan/domain/use_cases/save_settings_use_case.dart';
import 'package:dienstplan/domain/policies/date_range_policy.dart';
import 'package:dienstplan/domain/services/schedule_merge_service.dart';
import 'package:dienstplan/domain/value_objects/date_range.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/domain/failures/failure.dart';
import 'package:dienstplan/domain/failures/result.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_cache_manager.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_loading_queue.dart';
import 'package:dienstplan/core/constants/schedule_constants.dart';

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

  // Non-static instance variables
  ScheduleDataUiState? _cachedState;
  DateTime? _lastCacheTime;
  ScheduleCacheManager? _cacheManager;
  ScheduleLoadingQueue? _loadingQueue;
  final Map<String, String> _lastKnownConfigVersions = <String, String>{};

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

    // Initialize cache and queue from providers
    _cacheManager ??= ref.read(scheduleCacheManagerProvider);
    _loadingQueue ??= ref.read(scheduleLoadingQueueProvider);

    // Return cached state if available and still valid, otherwise initialize
    if (_cachedState != null && _isCacheValid()) {
      AppLogger.d('ScheduleDataNotifier: Returning cached state');
      return _cachedState!;
    }

    return await _initialize();
  }

  bool _isCacheValid() {
    if (_lastCacheTime == null) return false;
    return DateTime.now().difference(_lastCacheTime!) <
        kScheduleDataCacheValidityDuration;
  }

  Future<ScheduleDataUiState> _initialize() async {
    try {
      // Detect config version changes and invalidate caches if needed
      await _invalidateCacheOnVersionChange();
      final settingsResult = await _getSettingsUseCase!.executeSafe();
      final settings = settingsResult.isSuccess ? settingsResult.value : null;

      final activeConfigName = settings?.activeConfigName;
      final preferredDutyGroup = settings?.myDutyGroup;
      final selectedDutyGroup = settings?.selectedDutyGroup;

      List<Schedule> schedules = [];
      if (activeConfigName != null) {
        final DateTime now = DateTime.now();
        final DateRange initialRange = _dateRangePolicy!.computeInitialRange(
          now,
        );

        AppLogger.d(
          'ScheduleDataNotifier: Initial load range: ${initialRange.start} to ${initialRange.end}',
        );

        final schedulesResult = await _getSchedulesUseCase!
            .executeForDateRangeSafe(
              startDate: initialRange.start,
              endDate: initialRange.end,
              configName: activeConfigName,
            );

        if (schedulesResult.isSuccess) {
          schedules = schedulesResult.value;
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

  Future<void> _invalidateCacheOnVersionChange() async {
    try {
      final getConfigs = await ref.read(getConfigsUseCaseProvider.future);
      final configs = await getConfigs.execute();
      bool anyInvalidated = false;
      for (final c in configs) {
        final String name = c.name;
        final String version = c.version;
        final String? previous = _lastKnownConfigVersions[name];
        if (previous != null && previous != version) {
          _cacheManager?.clearCacheForConfig(name);
          anyInvalidated = true;
        }
        _lastKnownConfigVersions[name] = version;
      }
      if (anyInvalidated) {
        _cachedState = null;
        _lastCacheTime = null;
        // Proactively ensure current month for active config so UI updates
        final settingsResult = await _getSettingsUseCase!.executeSafe();
        final settings = settingsResult.isSuccess ? settingsResult.value : null;
        final String? activeName = settings?.activeConfigName;
        if (activeName != null && activeName.isNotEmpty) {
          final DateTime now = DateTime.now();
          await _ensureMonthSchedulesUseCase!.execute(
            monthStart: DateTime(now.year, now.month, 1),
            configName: activeName,
          );
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
    final cachedSchedules = _cacheManager!.getSchedules(
      startDate,
      endDate,
      configName,
    );
    if (cachedSchedules != null) {
      AppLogger.d(
        'ScheduleDataNotifier: Using cached data for range ${startDate.toIso8601String()} to ${endDate.toIso8601String()}',
      );
      final baseline = state.value ?? _cachedState ?? await future;
      final mergedSchedules = _scheduleMergeService!.upsertByKey(
        existing: baseline.schedules,
        incoming: cachedSchedules,
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
    final operationKey = _loadingQueue!.generateOperationKey(
      startDate,
      endDate,
      configName,
    );
    final wasQueued = await _loadingQueue!.executeIfNotPending(
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
    await _ensureDependencies();
    final baseline = await _setLoadingState();

    try {
      final schedulesResult = await _loadSchedulesFromRepository(
        startDate,
        endDate,
        configName,
      );

      if (schedulesResult.isSuccess) {
        await _handleSuccessfulScheduleLoad(
          schedulesResult.value,
          baseline,
          startDate,
          endDate,
          configName,
        );
      } else {
        await _handleFailedScheduleLoad(schedulesResult.failure, baseline);
      }
    } catch (e) {
      await _handleScheduleLoadException(e);
    }
  }

  Future<void> _ensureDependencies() async {
    _getSchedulesUseCase ??= await ref.read(getSchedulesUseCaseProvider.future);
    _scheduleMergeService ??= ref.read(scheduleMergeServiceProvider);
  }

  Future<ScheduleDataUiState> _setLoadingState() async {
    final baseline = state.value ?? _cachedState ?? await future;
    final loadingState = baseline.copyWith(isLoading: true);
    _cachedState = loadingState;
    if (ref.mounted) {
      state = AsyncData(loadingState);
    }
    return baseline;
  }

  Future<Result<List<Schedule>>> _loadSchedulesFromRepository(
    DateTime startDate,
    DateTime endDate,
    String configName,
  ) async {
    return await _getSchedulesUseCase!.executeForDateRangeSafe(
      startDate: startDate,
      endDate: endDate,
      configName: configName,
    );
  }

  Future<void> _handleSuccessfulScheduleLoad(
    List<Schedule> newSchedules,
    ScheduleDataUiState baseline,
    DateTime startDate,
    DateTime endDate,
    String configName,
  ) async {
    _cacheManager!.setSchedules(startDate, endDate, configName, newSchedules);

    final mergedSchedules = _scheduleMergeService!.upsertByKey(
      existing: baseline.schedules,
      incoming: newSchedules,
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
  }

  Future<void> _handleFailedScheduleLoad(
    Failure failure,
    ScheduleDataUiState baseline,
  ) async {
    final message = await _presentFailure(failure);
    final errored = baseline.copyWith(error: message, isLoading: false);
    _cachedState = errored;
    if (ref.mounted) {
      state = AsyncData(errored);
    }
  }

  Future<void> _handleScheduleLoadException(dynamic error) async {
    final errored =
        (state.value ?? _cachedState ?? ScheduleDataUiState.initial()).copyWith(
          error: 'Failed to load schedules',
          isLoading: false,
        );
    _cachedState = errored;
    if (ref.mounted) {
      state = AsyncData(errored);
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
      await _generateSchedulesUseCase!.execute(
        startDate: DateTime(month.year, month.month, 1),
        endDate: DateTime(month.year, month.month + 1, 0),
        configName: configName,
      );

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
    final String operationKey = _loadingQueue!.generateOperationKey(
      startDate,
      endDate,
      configName,
    );

    await _loadingQueue!.executeIfNotPending(operationKey, () async {
      try {
        await _ensureMonthSchedulesUseCase!.execute(
          monthStart: month,
          configName: configName,
        );

        if (!ref.mounted) return;

        await loadSchedulesForDateRange(
          startDate: startDate,
          endDate: endDate,
          configName: configName,
        );
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
      final settingsResult = await _getSettingsUseCase!.executeSafe();
      final settings = settingsResult.isSuccess ? settingsResult.value : null;
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

  /// Method to invalidate cache for a specific config from external services
  void invalidateCacheForConfig(String configName) {
    // Clear the cache manager for the specific config
    _cacheManager?.clearCacheForConfig(configName);

    // Clear cache state to force reload on next access
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
