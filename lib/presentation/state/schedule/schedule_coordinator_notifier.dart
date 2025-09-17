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
import 'package:dienstplan/core/constants/schedule_constants.dart';
import 'package:table_calendar/table_calendar.dart';

part 'schedule_coordinator_notifier.g.dart';

@riverpod
class ScheduleCoordinatorNotifier extends _$ScheduleCoordinatorNotifier {
  GetSchedulesUseCase? _getSchedulesUseCase;
  EnsureMonthSchedulesUseCase? _ensureMonthSchedulesUseCase;
  DateRangePolicy? _dateRangePolicy;
  ScheduleMergeService? _scheduleMergeService;

  @override
  Future<ScheduleUiState> build() async {
    _getSchedulesUseCase ??= await ref.read(getSchedulesUseCaseProvider.future);
    _ensureMonthSchedulesUseCase ??= await ref.read(
      ensureMonthSchedulesUseCaseProvider.future,
    );
    _dateRangePolicy ??= ref.read(dateRangePolicyProvider);
    _scheduleMergeService ??= ref.read(scheduleMergeServiceProvider);
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
    );
    // Kick off partner data ensure in the background so partner chips can render
    // without blocking initial build.
    unawaited(_ensurePartnerDataForFocusedRange());
    return combined;
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
      calendarFormat: calendarState.calendarFormat,
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
    await ref.read(calendarProvider.notifier).setFocusedDay(day);
    await _updateCalendarStateOnly();
    await _ensurePartnerDataForFocusedRange();
  }

  Future<void> setSelectedDay(DateTime? day) async {
    await ref.read(calendarProvider.notifier).setSelectedDay(day);
    await _updateCalendarStateOnly();
  }

  Future<void> setCalendarFormat(CalendarFormat format) async {
    await ref.read(calendarProvider.notifier).setCalendarFormat(format);
    await _refreshState();
  }

  Future<void> goToToday() async {
    await ref.read(calendarProvider.notifier).goToToday();
    await _refreshState();
  }

  // Config methods
  Future<void> setActiveConfig(String configName) async {
    await ref.read(configProvider.notifier).setActiveConfig(configName);
    await _refreshState();
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
      final getSettingsUseCase = await ref.read(
        getSettingsUseCaseProvider.future,
      );
      final saveSettingsUseCase = await ref.read(
        saveSettingsUseCaseProvider.future,
      );

      final settingsResult = await getSettingsUseCase.executeSafe();
      final existing = settingsResult.isSuccess ? settingsResult.value : null;

      if (existing != null) {
        await saveSettingsUseCase.executeSafe(
          existing.copyWith(selectedDutyGroup: dutyGroup),
        );

        // Refresh the schedule data provider to ensure it has the latest selectedDutyGroup
        await ref
            .read(scheduleDataProvider.notifier)
            .refreshSelectedDutyGroupFromSettings();
      }
    } catch (e) {
      // Ignore settings save errors to avoid disrupting the filter
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

  // Additional methods that were in the original ScheduleNotifier
  Future<void> updateCalendarFormatOnly(CalendarFormat format) async {
    await ref.read(calendarProvider.notifier).updateCalendarFormatOnly(format);
    await _refreshState();
  }

  Future<void> ensureActiveDay(DateTime day) async {
    // This method ensures the active day is properly set
    await setSelectedDay(day);
    await setFocusedDay(day);
  }

  Future<void> setPreferredDutyGroup(String dutyGroup) async {
    // Update the schedule data state immediately
    final current = await future;
    state = AsyncData(current.copyWith(preferredDutyGroup: dutyGroup));

    // Save to settings
    final getSettingsUseCase = await ref.read(
      getSettingsUseCaseProvider.future,
    );
    final saveSettingsUseCase = await ref.read(
      saveSettingsUseCaseProvider.future,
    );

    final settingsResult = await getSettingsUseCase.executeSafe();
    final existing = settingsResult.isSuccess ? settingsResult.value : null;

    if (existing != null) {
      await saveSettingsUseCase.executeSafe(
        existing.copyWith(myDutyGroup: dutyGroup),
      );
    }

    // Update the schedule data state to reflect the change
    await _updateScheduleDataStateOnly();
  }

  Future<void> applyPartnerSelectionChanges() async {
    // This method applies partner selection changes
    await _refreshState();
    await _ensurePartnerDataForFocusedRange();
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
      calendarFormat: calendarState.calendarFormat,
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

    // Only update schedule data-related fields
    final updatedState = currentState.copyWith(
      schedules: scheduleDataState.schedules,
      preferredDutyGroup: scheduleDataState.preferredDutyGroup,
      selectedDutyGroup: scheduleDataState.selectedDutyGroup,
      holidayAccentColorValue: scheduleDataState.holidayAccentColorValue,
      isLoading: scheduleDataState.isLoading || currentState.isLoading,
      error: scheduleDataState.error ?? currentState.error,
    );

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

    // Only update schedule data-related fields, but preserve the selectedDutyGroup
    final updatedState = currentState.copyWith(
      schedules: scheduleDataState.schedules,
      preferredDutyGroup: scheduleDataState.preferredDutyGroup,
      selectedDutyGroup:
          selectedDutyGroup, // Use the provided value instead of scheduleDataState
      holidayAccentColorValue: scheduleDataState.holidayAccentColorValue,
      isLoading: scheduleDataState.isLoading || currentState.isLoading,
      error: scheduleDataState.error ?? currentState.error,
    );

    state = AsyncData(updatedState);
  }

  Future<void> _refreshState() async {
    final calendarState = await ref.read(calendarProvider.future);
    final configState = await ref.read(configProvider.future);
    final partnerState = await ref.read(partnerProvider.future);
    final scheduleDataState = await ref.read(scheduleDataProvider.future);

    state = AsyncData(
      _combineStates(
        calendarState,
        configState,
        partnerState,
        scheduleDataState,
      ),
    );
  }

  Future<void> _ensurePartnerDataForFocusedRange() async {
    try {
      final ScheduleUiState current = state.value ?? await future;
      final String? partnerConfig = current.partnerConfigName;
      if (partnerConfig == null || partnerConfig.isEmpty) return;
      final DateTime focused = current.focusedDay ?? DateTime.now();
      final DateRange focusedRange = _dateRangePolicy!.computeFocusedRange(
        focused,
      );
      final DateTime? selected = current.selectedDay;
      DateRange combinedRange = focusedRange;
      if (selected != null) {
        final DateRange selectedRange = _dateRangePolicy!.computeSelectedRange(
          selected,
        );
        combinedRange = DateRange.union(focusedRange, selectedRange);
      }
      final result = await _getSchedulesUseCase!.executeForDateRangeSafe(
        startDate: combinedRange.start,
        endDate: combinedRange.end,
        configName: partnerConfig,
      );
      if (result.isFailure) return;
      final List<Schedule> allPartner = <Schedule>[...result.value];
      Future<void> ensurePartnerMonth(DateTime monthStart) async {
        final List<Schedule> ensured = await _ensureMonthSchedulesUseCase!
            .execute(configName: partnerConfig, monthStart: monthStart);
        if (ensured.isNotEmpty) {
          allPartner.addAll(ensured);
        }
      }

      await Future.wait(<Future<void>>[
        for (int i = 0; i <= kMonthsPrefetchRadius; i++)
          ensurePartnerMonth(DateTime(focused.year, focused.month + i, 1)),
      ]);
      final List<Schedule> existingNow =
          (state.value?.schedules ?? current.schedules).toList();
      final List<Schedule> merged = _scheduleMergeService!
          .mergeReplacingConfigInRange(
            existing: existingNow,
            incoming: allPartner,
            range: combinedRange,
            replaceConfigName: partnerConfig,
          );
      state = AsyncData((state.value ?? current).copyWith(schedules: merged));
    } catch (e, stack) {
      AppLogger.e('Error in _ensurePartnerDataForFocusedRange', e, stack);
    }
  }
}
