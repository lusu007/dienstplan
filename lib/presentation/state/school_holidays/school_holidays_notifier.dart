import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/entities/school_holiday.dart';
import '../../../domain/use_cases/get_school_holidays_use_case.dart';
import '../../../domain/use_cases/get_settings_use_case.dart';
import '../../../domain/use_cases/save_settings_use_case.dart';
import 'school_holidays_ui_state.dart';

part 'school_holidays_notifier.g.dart';

@riverpod
class SchoolHolidaysNotifier extends _$SchoolHolidaysNotifier {
  late GetSchoolHolidaysUseCase _getHolidaysUseCase;
  late GetSettingsUseCase _getSettingsUseCase;
  late SaveSettingsUseCase _saveSettingsUseCase;

  @override
  Future<SchoolHolidaysUiState> build() async {
    _getHolidaysUseCase = await ref.read(getSchoolHolidaysUseCaseProvider.future);
    _getSettingsUseCase = await ref.read(getSettingsUseCaseProvider.future);
    _saveSettingsUseCase = await ref.read(saveSettingsUseCaseProvider.future);

    // Load initial settings
    final settings = await _getSettingsUseCase.execute();
    
    if (settings != null && 
        settings.showSchoolHolidays == true && 
        settings.schoolHolidayStateCode != null) {
      // Load holidays if enabled
      await _loadHolidaysForCurrentYear(settings.schoolHolidayStateCode!);
    }

    return SchoolHolidaysUiState(
      isLoading: false,
      isRefreshing: false,
      isEnabled: settings?.showSchoolHolidays ?? false,
      selectedStateCode: settings?.schoolHolidayStateCode,
    );
  }

  /// Toggle school holidays feature on/off
  Future<void> toggleEnabled(bool enabled) async {
    state = const AsyncValue.loading();
    
    try {
      final currentSettings = await _getSettingsUseCase.execute();
      if (currentSettings == null) return;

      final updatedSettings = currentSettings.copyWith(
        showSchoolHolidays: enabled,
      );

      final result = await _saveSettingsUseCase.execute(updatedSettings);
      
      result.fold(
        (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
        (_) async {
          if (enabled && updatedSettings.schoolHolidayStateCode != null) {
            await _loadHolidaysForCurrentYear(updatedSettings.schoolHolidayStateCode!);
          } else {
            state = AsyncValue.data(
              SchoolHolidaysUiState(
                isLoading: false,
                isRefreshing: false,
                isEnabled: enabled,
                selectedStateCode: updatedSettings.schoolHolidayStateCode,
              ),
            );
          }
        },
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Set the selected state for holidays
  Future<void> setSelectedState(String? stateCode) async {
    state = const AsyncValue.loading();
    
    try {
      final currentSettings = await _getSettingsUseCase.execute();
      if (currentSettings == null) return;

      final updatedSettings = currentSettings.copyWith(
        schoolHolidayStateCode: stateCode,
      );

      final result = await _saveSettingsUseCase.execute(updatedSettings);
      
      result.fold(
        (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
        (_) async {
          if (stateCode != null && currentSettings.showSchoolHolidays == true) {
            await _loadHolidaysForCurrentYear(stateCode);
          } else {
            state = AsyncValue.data(
              SchoolHolidaysUiState(
                isLoading: false,
                isRefreshing: false,
                isEnabled: currentSettings.showSchoolHolidays ?? false,
                selectedStateCode: stateCode,
              ),
            );
          }
        },
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Load holidays for a specific date range
  Future<void> loadHolidaysForRange(DateTime start, DateTime end) async {
    final currentState = state.valueOrNull;
    if (currentState == null || 
        !currentState.isEnabled || 
        currentState.selectedStateCode == null) {
      return;
    }

    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      final result = await _getHolidaysUseCase.call(
        stateCode: currentState.selectedStateCode!,
        startDate: start,
        endDate: end,
      );

      result.fold(
        (failure) {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              error: failure.message,
            ),
          );
        },
        (holidays) {
          final holidaysByDate = _groupHolidaysByDate(holidays);
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              allHolidays: holidays,
              holidaysByDate: holidaysByDate,
              error: null,
            ),
          );
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          error: e.toString(),
        ),
      );
    }
  }

  /// Refresh holidays from API
  Future<void> refreshHolidays() async {
    final currentState = state.valueOrNull;
    if (currentState == null || 
        !currentState.isEnabled || 
        currentState.selectedStateCode == null) {
      return;
    }

    state = AsyncValue.data(currentState.copyWith(isRefreshing: true));

    try {
      final result = await _getHolidaysUseCase.refresh(
        stateCode: currentState.selectedStateCode!,
        year: DateTime.now().year,
      );

      result.fold(
        (failure) {
          state = AsyncValue.data(
            currentState.copyWith(
              isRefreshing: false,
              error: failure.message,
            ),
          );
        },
        (holidays) async {
          // After refresh, reload for current year
          await _loadHolidaysForCurrentYear(currentState.selectedStateCode!);
          state = AsyncValue.data(
            state.value!.copyWith(
              isRefreshing: false,
              lastRefreshTime: DateTime.now(),
            ),
          );
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          isRefreshing: false,
          error: e.toString(),
        ),
      );
    }
  }

  /// Clear error message
  void clearError() {
    final currentState = state.valueOrNull;
    if (currentState != null) {
      state = AsyncValue.data(currentState.copyWith(error: null));
    }
  }

  /// Load holidays for the current year
  Future<void> _loadHolidaysForCurrentYear(String stateCode) async {
    final now = DateTime.now();
    final start = DateTime(now.year, 1, 1);
    final end = DateTime(now.year, 12, 31);
    
    await loadHolidaysForRange(start, end);
  }

  /// Group holidays by date for quick lookup
  Map<DateTime, List<SchoolHoliday>> _groupHolidaysByDate(
    List<SchoolHoliday> holidays,
  ) {
    final holidaysByDate = <DateTime, List<SchoolHoliday>>{};

    for (final holiday in holidays) {
      // Add holiday to each date it spans
      var currentDate = holiday.startDate;
      while (!currentDate.isAfter(holiday.endDate)) {
        final dateOnly = DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
        );
        
        holidaysByDate.putIfAbsent(dateOnly, () => []).add(holiday);
        currentDate = currentDate.add(const Duration(days: 1));
      }
    }

    return holidaysByDate;
  }
}