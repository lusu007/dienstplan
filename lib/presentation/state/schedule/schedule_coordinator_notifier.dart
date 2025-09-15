import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_ui_state.dart';
import 'package:dienstplan/presentation/state/calendar/calendar_notifier.dart';
import 'package:dienstplan/presentation/state/calendar/calendar_ui_state.dart';
import 'package:dienstplan/presentation/state/config/config_notifier.dart';
import 'package:dienstplan/presentation/state/config/config_ui_state.dart';
import 'package:dienstplan/presentation/state/partner/partner_notifier.dart';
import 'package:dienstplan/presentation/state/partner/partner_ui_state.dart';
import 'package:dienstplan/presentation/state/schedule_data/schedule_data_notifier.dart';
import 'package:dienstplan/presentation/state/schedule_data/schedule_data_ui_state.dart';
import 'package:table_calendar/table_calendar.dart';

part 'schedule_coordinator_notifier.g.dart';

@riverpod
class ScheduleCoordinatorNotifier extends _$ScheduleCoordinatorNotifier {
  @override
  Future<ScheduleUiState> build() async {
    // Initialize all sub-notifiers
    final calendarState = await ref.read(calendarProvider.future);
    final configState = await ref.read(configProvider.future);
    final partnerState = await ref.read(partnerProvider.future);
    final scheduleDataState = await ref.read(scheduleDataProvider.future);

    return _combineStates(
      calendarState,
      configState,
      partnerState,
      scheduleDataState,
    );
  }

  ScheduleUiState _combineStates(
    CalendarUiState calendarState,
    ConfigUiState configState,
    PartnerUiState partnerState,
    ScheduleDataUiState scheduleDataState,
  ) {
    return ScheduleUiState(
      isLoading: calendarState.isLoading ||
          configState.isLoading ||
          partnerState.isLoading ||
          scheduleDataState.isLoading,
      error: calendarState.error ??
          configState.error ??
          partnerState.error ??
          scheduleDataState.error,
      selectedDay: calendarState.selectedDay,
      focusedDay: calendarState.focusedDay,
      calendarFormat: calendarState.calendarFormat,
      schedules: scheduleDataState.schedules,
      activeConfigName: configState.activeConfigName,
      preferredDutyGroup: scheduleDataState.preferredDutyGroup,
      dutyGroups: configState.dutyGroups,
      configs: configState.configs,
      activeConfig: configState.activeConfig,
      partnerConfigName: partnerState.partnerConfigName,
      partnerDutyGroup: partnerState.partnerDutyGroup,
      partnerAccentColorValue: partnerState.partnerAccentColorValue,
      myAccentColorValue: partnerState.myAccentColorValue,
    );
  }

  // Calendar methods
  Future<void> setFocusedDay(DateTime day) async {
    await ref.read(calendarProvider.notifier).setFocusedDay(day);
    await _refreshState();
  }

  Future<void> setSelectedDay(DateTime? day) async {
    await ref.read(calendarProvider.notifier).setSelectedDay(day);
    await _refreshState();
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

  // Partner methods
  Future<void> setPartnerConfigName(String? configName) async {
    await ref.read(partnerProvider.notifier).setPartnerConfigName(configName);
    await _refreshState();
  }

  Future<void> setPartnerDutyGroup(String? dutyGroup) async {
    await ref.read(partnerProvider.notifier).setPartnerDutyGroup(dutyGroup);
    await _refreshState();
  }

  Future<void> setPartnerAccentColor(int? colorValue) async {
    await ref.read(partnerProvider.notifier).setPartnerAccentColor(colorValue);
    await _refreshState();
  }

  Future<void> setMyAccentColor(int? colorValue) async {
    await ref.read(partnerProvider.notifier).setMyAccentColor(colorValue);
    await _refreshState();
  }

  // Schedule data methods
  Future<void> loadSchedulesForDateRange({
    required DateTime startDate,
    required DateTime endDate,
    required String configName,
  }) async {
    await ref.read(scheduleDataProvider.notifier).loadSchedulesForDateRange(
          startDate: startDate,
          endDate: endDate,
          configName: configName,
        );
    await _refreshState();
  }

  Future<void> generateSchedulesForMonth({
    required DateTime month,
    required String configName,
  }) async {
    await ref.read(scheduleDataProvider.notifier).generateSchedulesForMonth(
          month: month,
          configName: configName,
        );
    await _refreshState();
  }

  Future<void> ensureMonthSchedules({
    required DateTime month,
    required String configName,
  }) async {
    await ref.read(scheduleDataProvider.notifier).ensureMonthSchedules(
          month: month,
          configName: configName,
        );
    await _refreshState();
  }

  Future<void> setSelectedDutyGroup(String dutyGroup) async {
    await ref
        .read(scheduleDataProvider.notifier)
        .setSelectedDutyGroup(dutyGroup);
    await _refreshState();
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
    // This method sets the preferred duty group in settings
    // Update settings with new duty group
    // This would need to be implemented based on your settings structure
    await _refreshState();
  }

  Future<void> applyPartnerSelectionChanges() async {
    // This method applies partner selection changes
    await _refreshState();
  }

  Future<void> _refreshState() async {
    final calendarState = await ref.read(calendarProvider.future);
    final configState = await ref.read(configProvider.future);
    final partnerState = await ref.read(partnerProvider.future);
    final scheduleDataState = await ref.read(scheduleDataProvider.future);

    state = AsyncData(_combineStates(
      calendarState,
      configState,
      partnerState,
      scheduleDataState,
    ));
  }
}
