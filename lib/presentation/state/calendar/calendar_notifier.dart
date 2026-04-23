import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dienstplan/presentation/state/calendar/calendar_ui_state.dart';

part 'calendar_notifier.g.dart';

@riverpod
class CalendarNotifier extends _$CalendarNotifier {
  @override
  Future<CalendarUiState> build() async {
    return await _initialize();
  }

  Future<CalendarUiState> _initialize() async {
    try {
      final DateTime now = DateTime.now();
      return CalendarUiState(
        isLoading: false,
        error: null,
        selectedDay: now,
        focusedDay: now,
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
