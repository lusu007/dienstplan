import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/presentation/state/calendar/calendar_ui_state.dart';
import 'package:dienstplan/domain/use_cases/get_settings_use_case.dart';
import 'package:dienstplan/domain/use_cases/save_settings_use_case.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';

part 'calendar_notifier.g.dart';

@riverpod
class CalendarNotifier extends _$CalendarNotifier {
  GetSettingsUseCase? _getSettingsUseCase;
  SaveSettingsUseCase? _saveSettingsUseCase;

  @override
  Future<CalendarUiState> build() async {
    _getSettingsUseCase ??= await ref.read(getSettingsUseCaseProvider.future);
    _saveSettingsUseCase ??= await ref.read(saveSettingsUseCaseProvider.future);
    return await _initialize();
  }

  Future<CalendarUiState> _initialize() async {
    try {
      final DateTime now = DateTime.now();
      final settingsResult = await _getSettingsUseCase!.executeSafe();
      final settings = settingsResult.isSuccess ? settingsResult.value : null;
      final format = settings?.calendarFormat ?? CalendarFormat.month;

      return CalendarUiState(
        isLoading: false,
        error: null,
        selectedDay: now,
        focusedDay: now,
        calendarFormat: format,
      );
    } catch (e) {
      return CalendarUiState.initial().copyWith(
        error: 'Failed to initialize calendar',
      );
    }
  }

  Future<void> setFocusedDay(DateTime day) async {
    final current = state.value ?? CalendarUiState.initial();
    state = AsyncData(current.copyWith(focusedDay: day));
  }

  Future<void> setSelectedDay(DateTime? day) async {
    final current = state.value ?? CalendarUiState.initial();
    // Early return if the day didn't change to avoid redundant emits
    final DateTime? prev = current.selectedDay;
    final bool isSame =
        prev != null &&
        day != null &&
        prev.year == day.year &&
        prev.month == day.month &&
        prev.day == day.day;
    if (isSame || (prev == null && day == null)) {
      return;
    }
    state = AsyncData(current.copyWith(selectedDay: day));
  }

  Future<void> setCalendarFormat(CalendarFormat format) async {
    final current = state.value ?? CalendarUiState.initial();
    state = AsyncData(current.copyWith(calendarFormat: format));

    // Save to settings
    final settingsResult = await _getSettingsUseCase!.executeSafe();
    final existing = settingsResult.isSuccess ? settingsResult.value : null;
    if (existing != null) {
      await _saveSettingsUseCase!.executeSafe(
        existing.copyWith(calendarFormat: format),
      );
    }
  }

  Future<void> updateCalendarFormatOnly(CalendarFormat format) async {
    final current = state.value ?? CalendarUiState.initial();
    state = AsyncData(current.copyWith(calendarFormat: format));
  }

  Future<void> goToToday() async {
    final now = DateTime.now();
    final current = state.value ?? CalendarUiState.initial();

    state = AsyncData(current.copyWith(isLoading: true));

    try {
      // Set selected day to today
      await setSelectedDay(DateTime(now.year, now.month, now.day));

      // Set focused day to current month
      await setFocusedDay(DateTime(now.year, now.month, 1));

      // Clear loading state
      state = AsyncData((state.value ?? current).copyWith(isLoading: false));
    } catch (e) {
      state = AsyncData(
        current.copyWith(error: 'Failed to go to today', isLoading: false),
      );
    }
  }

  Future<void> clearError() async {
    final current = await future;
    state = AsyncData(current.copyWith(error: null));
  }
}
