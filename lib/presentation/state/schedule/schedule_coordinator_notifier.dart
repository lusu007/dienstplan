import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_ui_state.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/presentation/state/calendar/calendar_notifier.dart';
import 'package:dienstplan/presentation/state/calendar/calendar_ui_state.dart';
import 'package:dienstplan/presentation/state/config/config_notifier.dart';
import 'package:dienstplan/presentation/state/config/config_ui_state.dart';
import 'package:dienstplan/presentation/state/partner/partner_notifier.dart';
import 'package:dienstplan/presentation/state/partner/partner_ui_state.dart';
import 'package:dienstplan/presentation/state/schedule_data/schedule_data_notifier.dart';
import 'package:dienstplan/presentation/state/schedule_data/schedule_data_ui_state.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/domain/use_cases/get_schedules_use_case.dart';
import 'package:dienstplan/domain/use_cases/ensure_month_schedules_use_case.dart';
import 'package:dienstplan/domain/policies/date_range_policy.dart';
import 'package:dienstplan/domain/services/schedule_merge_service.dart';
import 'package:dienstplan/domain/value_objects/date_range.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/domain/entities/settings.dart';
import 'package:dienstplan/domain/use_cases/save_settings_use_case.dart';
import 'package:dienstplan/core/constants/schedule_constants.dart';
import 'package:dienstplan/core/cache/settings_cache.dart';
import 'package:dienstplan/core/utils/settings_utils.dart';
import 'package:flutter/material.dart';
import 'package:dienstplan/shared/utils/schedule_isolate.dart';

part 'schedule_coordinator_notifier.g.dart';

@Riverpod(keepAlive: true)
class ScheduleCoordinatorNotifier extends _$ScheduleCoordinatorNotifier {
  GetSchedulesUseCase? _getSchedulesUseCase;
  EnsureMonthSchedulesUseCase? _ensureMonthSchedulesUseCase;
  DateRangePolicy? _dateRangePolicy;
  ScheduleMergeService? _scheduleMergeService;

  @override
  Future<ScheduleUiState> build() async {
    // Sync deps before any await so user-driven calls (e.g. setFocusedDay) never
    // see null _dateRangePolicy while build() is suspended.
    _dateRangePolicy ??= ref.read(dateRangePolicyProvider);
    _scheduleMergeService ??= ref.read(scheduleMergeServiceProvider);
    _getSchedulesUseCase ??= await ref.read(getSchedulesUseCaseProvider.future);
    _ensureMonthSchedulesUseCase ??= await ref.read(
      ensureMonthSchedulesUseCaseProvider.future,
    );
    // Initialize all sub-notifiers
    final calendarState = await ref.read(calendarProvider.future);
    final configState = await ref.read(configProvider.future);
    final partnerState = await ref.read(partnerProvider.future);
    final scheduleDataState = await ref.read(scheduleDataProvider.future);

    final ScheduleUiState combined = _combineStates(
      calendarState,
      configState,
      partnerState,
      scheduleDataState,
    ).updateScheduleIndex();
    // Kick off partner data ensure in the background so partner chips can render
    // without blocking initial build.
    unawaited(_ensurePartnerDataForFocusedRange());
    return combined;
  }

  DateRangePolicy _resolveDateRangePolicy() {
    _dateRangePolicy ??= ref.read(dateRangePolicyProvider);
    return _dateRangePolicy!;
  }

  ScheduleUiState _combineStates(
    CalendarUiState calendarState,
    ConfigUiState configState,
    PartnerUiState partnerState,
    ScheduleDataUiState scheduleDataState,
  ) {
    return ScheduleUiState(
      isLoading:
          calendarState.isLoading ||
          configState.isLoading ||
          partnerState.isLoading ||
          scheduleDataState.isLoading,
      error:
          calendarState.error ??
          configState.error ??
          partnerState.error ??
          scheduleDataState.error,
      selectedDay: calendarState.selectedDay,
      focusedDay: calendarState.focusedDay,
      schedules: scheduleDataState.schedules,
      activeConfigName: configState.activeConfigName,
      preferredDutyGroup: scheduleDataState.preferredDutyGroup,
      selectedDutyGroup: scheduleDataState.selectedDutyGroup,
      dutyGroups: configState.dutyGroups,
      configs: configState.configs,
      activeConfig: configState.activeConfig,
      partnerConfigName: partnerState.partnerConfigName,
      partnerDutyGroup: partnerState.partnerDutyGroup,
      partnerAccentColorValue: partnerState.partnerAccentColorValue,
      myAccentColorValue: partnerState.myAccentColorValue,
      holidayAccentColorValue: scheduleDataState.holidayAccentColorValue,
    );
  }

  // Calendar methods - optimized for selective updates
  Future<void> setFocusedDay(DateTime day) async {
    // Coalesce repeated calls: if month hasn't changed, only update calendar state
    // Avoid awaiting future here to keep navigation snappy; fall back to calendar provider
    final DateTime? currentFocused =
        state.value?.focusedDay ?? ref.read(calendarProvider).value?.focusedDay;
    final bool monthUnchanged =
        currentFocused != null &&
        currentFocused.year == day.year &&
        currentFocused.month == day.month;

    await ref.read(calendarProvider.notifier).setFocusedDay(day);
    await _updateCalendarStateOnly();

    if (monthUnchanged) {
      // Skip heavy ensures/dynamic loading if month didn't change
      return;
    }

    // Ensure own data for the newly focused range so own chips render immediately
    await _ensureOwnDataForFocusedRange();
    unawaited(_ensurePartnerDataForFocusedRange());
    // Trigger dynamic loading for the new focused range
    unawaited(_triggerDynamicLoadingForFocusedDay(day));
  }

  Future<void> setSelectedDay(DateTime? day) async {
    await ref.read(calendarProvider.notifier).setSelectedDay(day);
    await _updateCalendarStateOnly();
  }

  Future<void> goToToday() async {
    await ref.read(calendarProvider.notifier).goToToday();
    unawaited(_refreshState());
  }

  // Config methods
  Future<void> setActiveConfig(String configName) async {
    // Optimistically update coordinator state for instant UI feedback
    final ScheduleUiState? current = state.value;
    if (current != null) {
      try {
        DutyScheduleConfig? selected;
        if (current.configs.isNotEmpty) {
          try {
            selected = current.configs.firstWhere((c) => c.name == configName);
          } catch (_) {
            selected = current.configs.first;
          }
        } else {
          selected = current.activeConfig;
        }
        if (selected != null) {
          final List<String> dutyGroups = selected.dutyGroups
              .map((g) => g.name)
              .toList(growable: false);
          state = AsyncData(
            current.copyWith(
              activeConfigName: configName,
              activeConfig: selected,
              dutyGroups: dutyGroups,
            ),
          );
        } else {
          AppLogger.w(
            'ScheduleCoordinatorNotifier: No valid config found for name: $configName',
          );
        }
      } catch (_) {
        // Ignore optimistic update failure and proceed
      }
    }

    await ref.read(configProvider.notifier).setActiveConfig(configName);
    await _updateScheduleDataStateOnly();
    await _refreshState();
    await _ensurePartnerDataForFocusedRange();
  }

  Future<void> refreshConfigs() async {
    await ref.read(configProvider.notifier).refreshConfigs();
    await _refreshState();
  }

  // Partner methods - optimized for selective updates
  Future<void> setPartnerConfigName(String? configName) async {
    await ref.read(partnerProvider.notifier).setPartnerConfigName(configName);
    await _updatePartnerStateOnly();
    await _ensurePartnerDataForFocusedRange();
  }

  Future<void> setPartnerDutyGroup(String? dutyGroup) async {
    await ref.read(partnerProvider.notifier).setPartnerDutyGroup(dutyGroup);
    await _updatePartnerStateOnly();
    await _ensurePartnerDataForFocusedRange();
  }

  Future<void> setPartnerAccentColor(int? colorValue) async {
    await ref.read(partnerProvider.notifier).setPartnerAccentColor(colorValue);
    await _updatePartnerStateOnly();
  }

  Future<void> clearActiveConfig() async {
    try {
      // Update combined state optimistically
      final ScheduleUiState existingState = state.value ?? await future;
      state = AsyncData(
        existingState.copyWith(
          activeConfigName: null,
          activeConfig: null,
          dutyGroups: const <String>[],
          preferredDutyGroup: null,
          myAccentColorValue: null,
        ),
      );

      // Persist to settings
      final SaveSettingsUseCase saveSettingsUseCase = await ref.read(
        saveSettingsUseCaseProvider.future,
      );
      await saveSettingsUseCase.patchExistingIfPresent(
        (Settings existing) => existing.copyWith(activeConfigName: null),
      );

      // Invalidate caches and refresh providers
      ref.invalidate(getSettingsUseCaseProvider);
      SettingsCache.clearCache();

      // Refresh config provider to reflect cleared selection
      await ref.read(configProvider.notifier).refreshConfigs();
      await _updateScheduleDataStateOnly();
      await _refreshState();
    } catch (e, stackTrace) {
      AppLogger.e(
        'ScheduleCoordinatorNotifier: clearActiveConfig failed',
        e,
        stackTrace,
      );
    }
  }

  Future<void> setMyAccentColor(int? colorValue) async {
    await ref.read(partnerProvider.notifier).setMyAccentColor(colorValue);
    await _updatePartnerStateOnly();
  }

  // Schedule data methods - optimized for selective updates
  Future<void> loadSchedulesForDateRange({
    required DateTime startDate,
    required DateTime endDate,
    required String configName,
  }) async {
    await ref
        .read(scheduleDataProvider.notifier)
        .loadSchedulesForDateRange(
          startDate: startDate,
          endDate: endDate,
          configName: configName,
        );
    await _updateScheduleDataStateOnly();
  }

  Future<void> generateSchedulesForMonth({
    required DateTime month,
    required String configName,
  }) async {
    await ref
        .read(scheduleDataProvider.notifier)
        .generateSchedulesForMonth(month: month, configName: configName);
    await _updateScheduleDataStateOnly();
  }

  Future<void> ensureMonthSchedules({
    required DateTime month,
    required String configName,
  }) async {
    await ref
        .read(scheduleDataProvider.notifier)
        .ensureMonthSchedules(month: month, configName: configName);
    await _updateScheduleDataStateOnly();
  }

  Future<void> setSelectedDutyGroup(String? dutyGroup) async {
    // Update state immediately for instant UI feedback
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(selectedDutyGroup: dutyGroup));
    }

    // Update the schedule data provider
    await ref
        .read(scheduleDataProvider.notifier)
        .setSelectedDutyGroup(dutyGroup);

    // Update state once with all changes, but preserve the selectedDutyGroup
    await _updateScheduleDataStateOnlyPreservingSelectedDutyGroup(dutyGroup);

    // Save to settings for persistence (in background)
    unawaited(_saveSelectedDutyGroupToSettings(dutyGroup));
  }

  Future<void> _saveSelectedDutyGroupToSettings(String? dutyGroup) async {
    try {
      final SaveSettingsUseCase saveSettingsUseCase = await ref.read(
        saveSettingsUseCaseProvider.future,
      );
      final patchResult = await saveSettingsUseCase.patchExistingIfPresent(
        (Settings existing) => existing.copyWith(selectedDutyGroup: dutyGroup),
      );
      if (patchResult.isSuccess && patchResult.value == true) {
        await ref
            .read(scheduleDataProvider.notifier)
            .refreshSelectedDutyGroupFromSettings();
      }
    } catch (e) {
      AppLogger.d(
        'ScheduleCoordinatorNotifier: Best-effort save selectedDutyGroup skipped '
        '(dutyGroup=$dutyGroup, error=$e)',
      );
    }
  }

  // Utility methods
  Future<void> clearError() async {
    await ref.read(calendarProvider.notifier).clearError();
    await ref.read(configProvider.notifier).clearError();
    await ref.read(partnerProvider.notifier).clearError();
    await ref.read(scheduleDataProvider.notifier).clearError();
    await _refreshState();
  }

  Future<void> ensureActiveDay(DateTime day) async {
    // This method ensures the active day is properly set
    await setSelectedDay(day);
    await setFocusedDay(day);
  }

  Future<void> setPreferredDutyGroup(
    String dutyGroup, {
    String? activeConfigNameOverride,
  }) async {
    // Update the schedule data state immediately using the latest value if available
    final ScheduleUiState existingState;
    if (state.value != null) {
      existingState = state.value!;
    } else {
      existingState = await future;
    }
    state = AsyncData(existingState.copyWith(preferredDutyGroup: dutyGroup));

    // Save to settings using the provided override if present, otherwise the most recent activeConfigName
    final SaveSettingsUseCase saveSettingsUseCase = await ref.read(
      saveSettingsUseCaseProvider.future,
    );

    final ConfigUiState configStateNow =
        ref.read(configProvider).value ?? await ref.read(configProvider.future);

    final patchResult = await saveSettingsUseCase.patchExistingIfPresent((
      Settings existing,
    ) {
      String? activeConfigNameToPersist = activeConfigNameOverride;

      if (activeConfigNameToPersist == null ||
          activeConfigNameToPersist.isEmpty) {
        final String? activeFromConfig = configStateNow.activeConfigName;
        final String? activeFromCoordinator =
            (state.value ?? existingState).activeConfigName;
        activeConfigNameToPersist =
            SettingsUtils.selectActiveConfigNameToPersist(
              currentActiveConfigName:
                  (activeFromConfig != null && activeFromConfig.isNotEmpty)
                  ? activeFromConfig
                  : activeFromCoordinator,
              existingActiveConfigName: existing.activeConfigName,
            );
      }
      return existing.copyWith(
        myDutyGroup: dutyGroup,
        activeConfigName: activeConfigNameToPersist,
      );
    });

    if (patchResult.isFailure) {
      state = AsyncData(existingState);
      return;
    }

    // Invalidate settings cache to ensure fresh data on next read
    ref.invalidate(getSettingsUseCaseProvider);

    // Clear the static settings cache to force reload with new settings
    SettingsCache.clearCache();

    // Invalidate schedule data provider cache to force reload with new settings
    ref.read(scheduleDataProvider.notifier).invalidateCache();

    // Force refresh of the schedule data provider to get new settings
    ref.invalidate(scheduleDataProvider);

    // Update the schedule data state to reflect the change
    await _updateScheduleDataStateOnly();
  }

  Future<void> applyPartnerSelectionChanges() async {
    // This method applies partner selection changes
    await _refreshState();
    await _ensurePartnerDataForFocusedRange();
  }

  Future<void> applyOwnSelectionChanges() async {
    // This method applies own duty group and config selection changes
    // Ensure schedule data provider is refreshed first so new active config is reflected
    ref.read(scheduleDataProvider.notifier).invalidateCache();
    ref.invalidate(scheduleDataProvider);
    // Preserve current selected duty group through the refresh
    final String? selectedBefore;
    if (state.value != null) {
      selectedBefore = state.value!.selectedDutyGroup;
    } else {
      selectedBefore = (await future).selectedDutyGroup;
    }
    await _updateScheduleDataStateOnlyPreservingSelectedDutyGroup(
      selectedBefore,
    );
    // Finally, refresh combined state and ensure partner data for current range
    await _refreshState();
    await _ensurePartnerDataForFocusedRange();

    // Also trigger dynamic loading for the current focused day to prefill chips
    final ScheduleUiState current;
    if (state.value != null) {
      current = state.value!;
    } else {
      current = await future;
    }
    final DateTime focused = current.focusedDay ?? DateTime.now();
    await _triggerDynamicLoadingForFocusedDay(focused);

    // Guarantee generation/availability for the current and next month
    final String? activeName = (state.value ?? current).activeConfigName;
    if (activeName != null && activeName.isNotEmpty) {
      final DateTime monthStart = DateTime(focused.year, focused.month, 1);
      final DateTime nextMonthStart = DateTime(
        focused.year,
        focused.month + 1,
        1,
      );
      await ensureMonthSchedules(month: monthStart, configName: activeName);
      await ensureMonthSchedules(month: nextMonthStart, configName: activeName);
      // Update schedule data state after ensuring months
      await _updateScheduleDataStateOnly();
    }
  }

  /// Optimized method to update only calendar-related state
  Future<void> _updateCalendarStateOnly() async {
    final currentState = state.value;
    if (currentState == null) {
      await _refreshState();
      return;
    }

    final calendarState = await ref.read(calendarProvider.future);

    // Only update calendar-related fields
    final updatedState = currentState.copyWith(
      selectedDay: calendarState.selectedDay,
      focusedDay: calendarState.focusedDay,
      isLoading: calendarState.isLoading || currentState.isLoading,
      error: calendarState.error ?? currentState.error,
    );

    state = AsyncData(updatedState);
  }

  /// Optimized method to update only partner-related state
  Future<void> _updatePartnerStateOnly() async {
    final currentState = state.value;
    if (currentState == null) {
      await _refreshState();
      return;
    }

    final partnerState = await ref.read(partnerProvider.future);

    // Only update partner-related fields
    final updatedState = currentState.copyWith(
      partnerConfigName: partnerState.partnerConfigName,
      partnerDutyGroup: partnerState.partnerDutyGroup,
      partnerAccentColorValue: partnerState.partnerAccentColorValue,
      myAccentColorValue: partnerState.myAccentColorValue,
      isLoading: partnerState.isLoading || currentState.isLoading,
      error: partnerState.error ?? currentState.error,
    );

    state = AsyncData(updatedState);
  }

  /// Optimized method to update only schedule data state
  Future<void> _updateScheduleDataStateOnly() async {
    final currentState = state.value;
    if (currentState == null) {
      await _refreshState();
      return;
    }

    final scheduleDataState = await ref.read(scheduleDataProvider.future);

    // Merge incoming schedules with existing ones to preserve partner data (offloaded)
    final List<Schedule> mergedSchedules =
        await ScheduleGenerationIsolate.mergeUpsertByKey(
          existing: currentState.schedules,
          incoming: scheduleDataState.schedules,
        );

    // Only update schedule data-related fields and update index
    final updatedState = currentState
        .copyWith(
          schedules: mergedSchedules,
          preferredDutyGroup: scheduleDataState.preferredDutyGroup,
          selectedDutyGroup: scheduleDataState.selectedDutyGroup,
          holidayAccentColorValue: scheduleDataState.holidayAccentColorValue,
          isLoading: scheduleDataState.isLoading || currentState.isLoading,
          error: scheduleDataState.error ?? currentState.error,
        )
        .updateScheduleIndex();

    state = AsyncData(updatedState);
  }

  /// Optimized method to update only schedule data state while preserving selectedDutyGroup
  Future<void> _updateScheduleDataStateOnlyPreservingSelectedDutyGroup(
    String? selectedDutyGroup,
  ) async {
    final currentState = state.value;
    if (currentState == null) {
      await _refreshState();
      return;
    }

    final scheduleDataState = await ref.read(scheduleDataProvider.future);

    // Merge schedules to avoid losing dynamically loaded months when
    // scheduleDataProvider reinitializes with a smaller initial range
    final List<Schedule> existing = currentState.schedules;
    final List<Schedule> incoming = scheduleDataState.schedules;
    final List<Schedule> mergedSchedules =
        await ScheduleGenerationIsolate.deduplicateSchedules(
          schedules: <Schedule>[...existing, ...incoming],
        );

    // Only update schedule data-related fields, but preserve the selectedDutyGroup
    final updatedState = currentState
        .copyWith(
          schedules: mergedSchedules,
          preferredDutyGroup: scheduleDataState.preferredDutyGroup,
          selectedDutyGroup:
              selectedDutyGroup, // Use the provided value instead of scheduleDataState
          holidayAccentColorValue: scheduleDataState.holidayAccentColorValue,
          isLoading: scheduleDataState.isLoading || currentState.isLoading,
          error: scheduleDataState.error ?? currentState.error,
        )
        .updateScheduleIndex();

    state = AsyncData(updatedState);
  }

  Future<void> _refreshState() async {
    // Prefer current values to avoid re-initializing providers with stale caches
    Future<T> readNowOrFuture<T>({
      required AsyncValue<T> current,
      required Future<T> future,
    }) async {
      if (current.hasValue && current.value != null) {
        return current.value as T;
      }
      return await future;
    }

    final CalendarUiState calendarState =
        await readNowOrFuture<CalendarUiState>(
          current: ref.read(calendarProvider),
          future: ref.read(calendarProvider.future),
        );
    if (!ref.mounted) return;
    final ConfigUiState configState = await readNowOrFuture<ConfigUiState>(
      current: ref.read(configProvider),
      future: ref.read(configProvider.future),
    );
    if (!ref.mounted) return;
    final PartnerUiState partnerState = await readNowOrFuture<PartnerUiState>(
      current: ref.read(partnerProvider),
      future: ref.read(partnerProvider.future),
    );
    if (!ref.mounted) return;
    final ScheduleDataUiState scheduleDataState =
        await readNowOrFuture<ScheduleDataUiState>(
          current: ref.read(scheduleDataProvider),
          future: ref.read(scheduleDataProvider.future),
        );
    if (!ref.mounted) return;

    // Merge existing coordinator schedules with latest scheduleData to avoid losing
    // previously loaded months due to scheduleData re-inits.
    final List<Schedule> existing =
        state.value?.schedules ?? const <Schedule>[];
    final List<Schedule> incoming = scheduleDataState.schedules;
    final List<Schedule> mergedSchedules =
        await ScheduleGenerationIsolate.deduplicateSchedules(
          schedules: <Schedule>[...existing, ...incoming],
        );

    // Cleanup old schedules to prevent memory accumulation
    final DateTime currentDate = calendarState.focusedDay ?? DateTime.now();
    final DateTime? selectedDay = calendarState.selectedDay;
    final List<Schedule> cleanedSchedules =
        await ScheduleGenerationIsolate.cleanupOldSchedules(
          schedules: mergedSchedules,
          currentDate: currentDate,
          monthsToKeep: kMonthsToKeepInMemory,
          selectedDay: selectedDay,
        );

    final ScheduleUiState combined = _combineStates(
      calendarState,
      configState,
      partnerState,
      scheduleDataState,
    ).copyWith(schedules: cleanedSchedules).updateScheduleIndex();

    state = AsyncData(combined);
  }

  /// Loads schedules for an expanded date range when user scrolls beyond current data
  Future<void> loadSchedulesForExpandedRange({
    required DateTimeRange currentRange,
    required DateTime targetDate,
    required String configName,
  }) async {
    try {
      final DateRange expandedRange = _resolveDateRangePolicy()
          .computeExpandedRange(currentRange, targetDate);

      // Delegate to the schedule data notifier
      await ref
          .read(scheduleDataProvider.notifier)
          .loadSchedulesForDateRange(
            startDate: expandedRange.start,
            endDate: expandedRange.end,
            configName: configName,
          );
    } catch (e) {
      AppLogger.e(
        'ScheduleCoordinatorNotifier: Error loading expanded range',
        e,
      );
      // Don't update state on error for background loading
    }
  }

  // Removed unused _hasCompleteDataForRange after switching to delta loading

  /// Computes the current min/max coverage for the given config in memory.
  DateRange? _getConfigCoverageRange(
    List<Schedule> schedules,
    String configName,
  ) {
    final List<Schedule> filtered = schedules
        .where((Schedule s) => s.configName == configName)
        .toList();
    if (filtered.isEmpty) return null;
    DateTime minDate = filtered.first.date;
    DateTime maxDate = filtered.first.date;
    for (final Schedule s in filtered) {
      if (s.date.isBefore(minDate)) minDate = s.date;
      if (s.date.isAfter(maxDate)) maxDate = s.date;
    }
    // Normalize to month start / end
    final DateTime start = DateTime(minDate.year, minDate.month, 1);
    final DateTime end = DateTime(maxDate.year, maxDate.month + 1, 0);
    return DateRange(start: start, end: end);
  }

  /// Triggers dynamic loading when focused day changes (e.g., via chevron navigation)
  Future<void> _triggerDynamicLoadingForFocusedDay(DateTime focusedDay) async {
    try {
      final current = await future;
      final activeConfigName = current.activeConfigName;

      if (activeConfigName == null || activeConfigName.isEmpty) {
        return;
      }

      // Calculate the range around the focused day
      final DateRange focusedRange = _resolveDateRangePolicy()
          .computeFocusedRange(focusedDay);

      // Determine minimal missing ranges compared to current in-memory coverage.
      final DateRange? coverage = _getConfigCoverageRange(
        current.schedules,
        activeConfigName,
      );

      if (coverage == null) {
        await _ensureAndLoadRange(
          focusedRange.start,
          focusedRange.end,
          activeConfigName,
        );
        await _refreshState();
        return;
      }

      final List<DateRange> deltas = <DateRange>[];

      // Backward delta: from focused start to before coverage start
      if (focusedRange.start.isBefore(coverage.start)) {
        final DateTime deltaStart = DateTime(
          focusedRange.start.year,
          focusedRange.start.month,
          1,
        );
        final DateTime deltaEnd = DateTime(
          coverage.start.year,
          coverage.start.month,
          1,
        ).subtract(const Duration(days: 1));
        deltas.add(DateRange(start: deltaStart, end: deltaEnd));
      }

      // Forward delta: from after coverage end to focused end
      if (focusedRange.end.isAfter(coverage.end)) {
        final DateTime deltaStart = DateTime(
          coverage.end.year,
          coverage.end.month + 1,
          1,
        );
        final DateTime deltaEnd = DateTime(
          focusedRange.end.year,
          focusedRange.end.month + 1,
          0,
        );
        deltas.add(DateRange(start: deltaStart, end: deltaEnd));
      }

      if (deltas.isEmpty) {
        return;
      }

      for (final DateRange delta in deltas) {
        await _ensureAndLoadRange(delta.start, delta.end, activeConfigName);
      }

      await _refreshState();
    } catch (e) {
      AppLogger.e(
        'ScheduleCoordinatorNotifier: Error in dynamic loading for focused day',
        e,
      );
      // Don't update state on error for background loading
    }
  }

  Future<void> _ensurePartnerDataForFocusedRange() async {
    try {
      final ScheduleUiState current;
      if (state.value != null) {
        current = state.value!;
      } else {
        current = await future;
      }
      final String? partnerConfig = current.partnerConfigName;
      if (partnerConfig == null || partnerConfig.isEmpty) return;
      final DateTime focused = current.focusedDay ?? DateTime.now();
      final DateRange focusedRange = _resolveDateRangePolicy()
          .computeFocusedRange(focused);
      final DateTime? selected = current.selectedDay;
      DateRange combinedRange = focusedRange;
      if (selected != null) {
        final DateRange selectedRange = _resolveDateRangePolicy()
            .computeSelectedRange(selected);
        combinedRange = DateRange.union(focusedRange, selectedRange);
      }
      final result = await _getSchedulesUseCase!.executeForDateRange(
        startDate: combinedRange.start,
        endDate: combinedRange.end,
        configName: partnerConfig,
      );
      if (result.isFailure) return;
      final List<Schedule> allPartner = <Schedule>[...result.value];
      // Only ensure months outside current in-memory coverage
      final DateRange? coverage = _getConfigCoverageRange(
        (state.value ?? current).schedules,
        partnerConfig,
      );
      final List<Future<void>> ensureTasks = <Future<void>>[];
      for (int i = -kMonthsPrefetchRadius; i <= kMonthsPrefetchRadius; i++) {
        final DateTime monthStart = DateTime(
          focused.year,
          focused.month + i,
          1,
        );
        final DateTime monthEnd = DateTime(
          monthStart.year,
          monthStart.month + 1,
          0,
        );
        final bool outsideCoverage =
            coverage == null ||
            monthEnd.isBefore(coverage.start) ||
            monthStart.isAfter(coverage.end);
        if (outsideCoverage) {
          ensureTasks.add(() async {
            final result = await _ensureMonthSchedulesUseCase!.execute(
              configName: partnerConfig,
              monthStart: monthStart,
            );
            if (result.isFailure) {
              return;
            }
            final List<Schedule> ensured = result.value;
            if (ensured.isNotEmpty) {
              allPartner.addAll(ensured);
            }
          }());
        }
      }
      if (ensureTasks.isNotEmpty) {
        await Future.wait(ensureTasks);
      }
      final List<Schedule> existingNow =
          (state.value?.schedules ?? current.schedules).toList();
      final List<Schedule> merged =
          await ScheduleGenerationIsolate.mergeReplacingConfigInRange(
            existing: existingNow,
            incoming: allPartner,
            range: combinedRange,
            replaceConfigName: partnerConfig,
          );
      state = AsyncData(
        (state.value ?? current)
            .copyWith(schedules: merged)
            .updateScheduleIndex(),
      );
    } catch (e, stack) {
      AppLogger.e('Error in _ensurePartnerDataForFocusedRange', e, stack);
    }
  }

  Future<void> _ensureOwnDataForFocusedRange() async {
    try {
      final ScheduleUiState current;
      if (state.value != null) {
        current = state.value!;
      } else {
        current = await future;
      }

      final String? activeName = current.activeConfigName;
      if (activeName == null || activeName.isEmpty) return;

      final DateTime focused = current.focusedDay ?? DateTime.now();
      final DateRange focusedRange = _resolveDateRangePolicy()
          .computeFocusedRange(focused);
      final DateTime? selected = current.selectedDay;
      DateRange combinedRange = focusedRange;
      if (selected != null) {
        final DateRange selectedRange = _resolveDateRangePolicy()
            .computeSelectedRange(selected);
        combinedRange = DateRange.union(focusedRange, selectedRange);
      }

      // Load own schedules for combined range
      final ownResult = await _getSchedulesUseCase!.executeForDateRange(
        startDate: combinedRange.start,
        endDate: combinedRange.end,
        configName: activeName,
      );
      if (ownResult.isFailure) return;

      // Ensure own months around the focused period so data exists for chips,
      // but only for months outside current in-memory coverage
      final List<Schedule> allOwn = <Schedule>[...ownResult.value];
      final DateRange? coverage = _getConfigCoverageRange(
        (state.value ?? current).schedules,
        activeName,
      );
      final List<Future<void>> ensureTasks = <Future<void>>[];
      for (int i = -kMonthsPrefetchRadius; i <= kMonthsPrefetchRadius; i++) {
        final DateTime monthStart = DateTime(
          focused.year,
          focused.month + i,
          1,
        );
        final DateTime monthEnd = DateTime(
          monthStart.year,
          monthStart.month + 1,
          0,
        );
        final bool outsideCoverage =
            coverage == null ||
            monthEnd.isBefore(coverage.start) ||
            monthStart.isAfter(coverage.end);
        if (outsideCoverage) {
          ensureTasks.add(() async {
            final result = await _ensureMonthSchedulesUseCase!.execute(
              configName: activeName,
              monthStart: monthStart,
            );
            if (result.isFailure) {
              return;
            }
            final List<Schedule> ensured = result.value;
            if (ensured.isNotEmpty) {
              allOwn.addAll(ensured);
            }
          }());
        }
      }
      if (ensureTasks.isNotEmpty) {
        await Future.wait(ensureTasks);
      }

      final List<Schedule> existingNow =
          (state.value?.schedules ?? current.schedules).toList();
      final List<Schedule> merged =
          await ScheduleGenerationIsolate.mergeReplacingConfigInRange(
            existing: existingNow,
            incoming: allOwn,
            range: combinedRange,
            replaceConfigName: activeName,
          );
      state = AsyncData(
        (state.value ?? current)
            .copyWith(schedules: merged)
            .updateScheduleIndex(),
      );
    } catch (e, stack) {
      AppLogger.e('Error in _ensureOwnDataForFocusedRange', e, stack);
    }
  }

  /// Ensures schedules exist for the range and then loads them
  Future<void> _ensureAndLoadRange(
    DateTime startDate,
    DateTime endDate,
    String configName,
  ) async {
    try {
      // Check if we already have data for this range to avoid redundant queries
      final currentState = state.value;
      if (currentState != null) {
        // Use optimized index for O(k) coverage check + O(log n) binary search
        final hasDataForRange = currentState.hasDataForRange(
          configName,
          startDate,
          endDate,
        );

        if (hasDataForRange) {
          AppLogger.d(
            'ScheduleCoordinatorNotifier: Data already exists for range, skipping load',
          );
          return;
        }
      }

      // First ensure schedules exist for each month in the range
      final monthsToEnsure = <DateTime>[];
      DateTime currentMonth = DateTime(startDate.year, startDate.month, 1);
      final endMonth = DateTime(endDate.year, endDate.month, 1);

      while (currentMonth.isBefore(endMonth) ||
          currentMonth.isAtSameMomentAs(endMonth)) {
        monthsToEnsure.add(currentMonth);
        currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
      }

      // Ensure each month in parallel, but only if not already cached
      await Future.wait(
        monthsToEnsure.map((month) => _ensureMonthIfNeeded(month, configName)),
      );

      // Load the full range in a single query
      await ref
          .read(scheduleDataProvider.notifier)
          .loadSchedulesForDateRange(
            startDate: startDate,
            endDate: endDate,
            configName: configName,
          );
    } catch (e) {
      AppLogger.e(
        'ScheduleCoordinatorNotifier: Error ensuring and loading range',
        e,
      );
      rethrow;
    }
  }

  /// Ensures a month's schedules exist only if not already cached
  Future<void> _ensureMonthIfNeeded(DateTime month, String configName) async {
    try {
      // Check if we already have data for this month
      final currentState = state.value;
      if (currentState != null) {
        // Use optimized index for month range check
        final monthStart = DateTime(month.year, month.month, 1);
        final monthEnd = DateTime(month.year, month.month + 1, 0);
        final hasDataForMonth = currentState.hasDataForRange(
          configName,
          monthStart,
          monthEnd,
        );

        if (hasDataForMonth) {
          AppLogger.d(
            'ScheduleCoordinatorNotifier: Data already exists for month ${month.year}-${month.month}, skipping ensure',
          );
          return;
        }
      }

      // Only ensure if we don't have data for this month
      await ref
          .read(scheduleDataProvider.notifier)
          .ensureMonthSchedules(month: month, configName: configName);
    } catch (e) {
      AppLogger.e(
        'ScheduleCoordinatorNotifier: Error ensuring month ${month.year}-${month.month}',
        e,
      );
      // Don't rethrow to avoid breaking the entire operation
    }
  }
}
