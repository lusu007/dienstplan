import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/entities/school_holiday.dart';
import '../../../domain/use_cases/get_school_holidays_use_case.dart';
import '../../../domain/use_cases/get_settings_use_case.dart';
import '../../../domain/use_cases/save_settings_use_case.dart';
import '../../../core/di/riverpod_providers.dart';
import '../../../core/utils/logger.dart';
import 'school_holidays_ui_state.dart';

part 'school_holidays_notifier.g.dart';

@Riverpod(keepAlive: true)
class SchoolHolidaysNotifier extends _$SchoolHolidaysNotifier {
  late GetSchoolHolidaysUseCase _getHolidaysUseCase;
  late GetSettingsUseCase _getSettingsUseCase;
  late SaveSettingsUseCase _saveSettingsUseCase;

  @override
  Future<SchoolHolidaysUiState> build() async {
    AppLogger.i('[DEBUG] SchoolHolidaysNotifier: build() called');

    _getHolidaysUseCase = await ref.read(
      getSchoolHolidaysUseCaseProvider.future,
    );
    _getSettingsUseCase = await ref.read(getSettingsUseCaseProvider.future);
    _saveSettingsUseCase = await ref.read(saveSettingsUseCaseProvider.future);

    // Load initial settings
    final settings = await _getSettingsUseCase.execute();
    AppLogger.i(
      '[DEBUG] SchoolHolidaysNotifier: Settings loaded - showSchoolHolidays: ${settings?.showSchoolHolidays}, stateCode: ${settings?.schoolHolidayStateCode}',
    );

    if (settings != null &&
        settings.showSchoolHolidays == true &&
        settings.schoolHolidayStateCode != null) {
      AppLogger.i(
        '[DEBUG] SchoolHolidaysNotifier: Loading holidays for state: ${settings.schoolHolidayStateCode}',
      );
      // Load holidays if enabled and return the result
      return await _loadHolidaysForCurrentYearAndReturnState(
        settings.schoolHolidayStateCode!,
      );
    } else {
      AppLogger.i(
        '[DEBUG] SchoolHolidaysNotifier: Not loading holidays - conditions not met',
      );
      return SchoolHolidaysUiState(
        isLoading: false,
        isRefreshing: false,
        isEnabled: settings?.showSchoolHolidays ?? false,
        selectedStateCode: settings?.schoolHolidayStateCode,
        lastRefreshTime: settings?.lastSchoolHolidayRefresh,
      );
    }
  }

  /// Toggle school holidays feature on/off
  Future<void> toggleEnabled(bool enabled) async {
    final previous = state.value;
    if (previous != null) {
      state = AsyncValue.data(previous.copyWith(isLoading: true));
    }
    try {
      final currentSettings = await _getSettingsUseCase.execute();
      if (currentSettings == null) {
        if (previous != null) {
          state = AsyncValue.data(previous.copyWith(isLoading: false));
        }
        return;
      }
      final updatedSettings = currentSettings.copyWith(
        showSchoolHolidays: enabled,
      );
      final result = await _saveSettingsUseCase.executeSafe(updatedSettings);
      if (result.isSuccess) {
        if (enabled && updatedSettings.schoolHolidayStateCode != null) {
          await _loadHolidaysForCurrentYear(
            updatedSettings.schoolHolidayStateCode!,
          );
        } else {
          final base =
              state.value ??
              previous ??
              SchoolHolidaysUiState(
                isLoading: false,
                isRefreshing: false,
                isEnabled: enabled,
                selectedStateCode: updatedSettings.schoolHolidayStateCode,
              );
          state = AsyncValue.data(
            base.copyWith(
              isLoading: false,
              isEnabled: enabled,
              selectedStateCode: updatedSettings.schoolHolidayStateCode,
              error: null,
            ),
          );
        }
      } else {
        final base = state.value ?? previous;
        if (base != null) {
          state = AsyncValue.data(
            base.copyWith(
              isLoading: false,
              error: result.failure.technicalMessage,
            ),
          );
        }
      }
    } catch (e) {
      final base = state.value ?? previous;
      if (base != null) {
        state = AsyncValue.data(
          base.copyWith(isLoading: false, error: e.toString()),
        );
      }
    }
  }

  /// Set the selected state for holidays
  Future<void> setSelectedState(String? stateCode) async {
    final previous = state.value;
    if (previous != null) {
      state = AsyncValue.data(
        previous.copyWith(isLoading: true, selectedStateCode: stateCode),
      );
    }
    try {
      final currentSettings = await _getSettingsUseCase.execute();
      if (currentSettings == null) {
        if (previous != null) {
          state = AsyncValue.data(previous.copyWith(isLoading: false));
        }
        return;
      }
      final updatedSettings = currentSettings.copyWith(
        schoolHolidayStateCode: stateCode,
      );
      final result = await _saveSettingsUseCase.executeSafe(updatedSettings);
      if (result.isSuccess) {
        if (stateCode != null && currentSettings.showSchoolHolidays == true) {
          await _loadHolidaysForCurrentYear(stateCode);
        } else {
          final base =
              state.value ??
              previous ??
              SchoolHolidaysUiState(
                isLoading: false,
                isRefreshing: false,
                isEnabled: currentSettings.showSchoolHolidays ?? false,
                selectedStateCode: stateCode,
              );
          state = AsyncValue.data(
            base.copyWith(
              isLoading: false,
              isEnabled: currentSettings.showSchoolHolidays ?? false,
              selectedStateCode: stateCode,
              error: null,
            ),
          );
        }
      } else {
        final base = state.value ?? previous;
        if (base != null) {
          state = AsyncValue.data(
            base.copyWith(
              isLoading: false,
              selectedStateCode: previous?.selectedStateCode,
              error: result.failure.technicalMessage,
            ),
          );
        }
      }
    } catch (e) {
      final base = state.value ?? previous;
      if (base != null) {
        state = AsyncValue.data(
          base.copyWith(
            isLoading: false,
            selectedStateCode: previous?.selectedStateCode,
            error: e.toString(),
          ),
        );
      }
    }
  }

  /// Load holidays for a specific date range
  Future<void> loadHolidaysForRange(DateTime start, DateTime end) async {
    final currentState = state.value;
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
              error: failure.technicalMessage,
            ),
          );
        },
        (holidays) {
          // Merge new holidays with existing ones to avoid losing data from other months
          final existingHolidays = currentState.allHolidays;
          final existingHolidayIds = existingHolidays.map((h) => h.id).toSet();
          final newHolidays = holidays
              .where((h) => !existingHolidayIds.contains(h.id))
              .toList();
          final mergedHolidays = [...existingHolidays, ...newHolidays];

          final holidaysByDate = _groupHolidaysByDate(mergedHolidays);
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              allHolidays: mergedHolidays,
              holidaysByDate: holidaysByDate,
              error: null,
            ),
          );
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(isLoading: false, error: e.toString()),
      );
    }
  }

  /// Refresh holidays from API
  Future<void> refreshHolidays() async {
    final currentState = state.value;
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
              error: failure.technicalMessage,
            ),
          );
        },
        (holidays) async {
          // After refresh, reload for current year
          await _loadHolidaysForCurrentYear(currentState.selectedStateCode!);

          // Update the last refresh timestamp in settings
          final now = DateTime.now();
          final currentSettings = await _getSettingsUseCase.execute();
          if (currentSettings != null) {
            final updatedSettings = currentSettings.copyWith(
              lastSchoolHolidayRefresh: now,
            );
            await _saveSettingsUseCase.executeSafe(updatedSettings);
          }

          state = AsyncValue.data(
            state.value!.copyWith(isRefreshing: false, lastRefreshTime: now),
          );
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(isRefreshing: false, error: e.toString()),
      );
    }
  }

  /// Clear error message
  void clearError() {
    final currentState = state.value;
    if (currentState != null) {
      state = AsyncValue.data(currentState.copyWith(error: null));
    }
  }

  /// Load holidays for the current year and return the state
  Future<SchoolHolidaysUiState> _loadHolidaysForCurrentYearAndReturnState(
    String stateCode,
  ) async {
    AppLogger.i(
      '[DEBUG] SchoolHolidaysNotifier: _loadHolidaysForCurrentYearAndReturnState called for state: $stateCode',
    );

    final now = DateTime.now();
    final start = DateTime(now.year, 1, 1);
    final end = DateTime(now.year, 12, 31);

    AppLogger.i(
      '[DEBUG] SchoolHolidaysNotifier: Loading holidays for date range: $start to $end',
    );

    try {
      final result = await _getHolidaysUseCase.call(
        stateCode: stateCode,
        startDate: start,
        endDate: end,
      );

      return result.fold(
        (failure) {
          AppLogger.e(
            '[DEBUG] SchoolHolidaysNotifier: Failed to load holidays: ${failure.technicalMessage}',
          );
          return SchoolHolidaysUiState(
            isLoading: false,
            isRefreshing: false,
            isEnabled: true,
            selectedStateCode: stateCode,
            error: failure.technicalMessage,
          );
        },
        (holidays) async {
          AppLogger.i(
            '[DEBUG] SchoolHolidaysNotifier: Successfully loaded ${holidays.length} holidays',
          );

          // Log the actual holidays for debugging
          for (final holiday in holidays) {
            AppLogger.d(
              '[DEBUG] SchoolHolidaysNotifier: Holiday: ${holiday.name} from ${holiday.startDate} to ${holiday.endDate}',
            );
          }

          // Load the last refresh time from settings
          final settings = await _getSettingsUseCase.execute();
          final lastRefreshTime = settings?.lastSchoolHolidayRefresh;

          final holidaysByDate = _groupHolidaysByDate(holidays);
          AppLogger.i(
            '[DEBUG] SchoolHolidaysNotifier: Grouped holidays by date: ${holidaysByDate.length} dates',
          );

          return SchoolHolidaysUiState(
            isLoading: false,
            isRefreshing: false,
            isEnabled: true,
            selectedStateCode: stateCode,
            allHolidays: holidays,
            holidaysByDate: holidaysByDate,
            lastRefreshTime: lastRefreshTime,
            error: null,
          );
        },
      );
    } catch (e) {
      AppLogger.e(
        '[DEBUG] SchoolHolidaysNotifier: Exception loading holidays: $e',
      );
      return SchoolHolidaysUiState(
        isLoading: false,
        isRefreshing: false,
        isEnabled: true,
        selectedStateCode: stateCode,
        error: e.toString(),
      );
    }
  }

  /// Load holidays for the current year
  Future<void> _loadHolidaysForCurrentYear(String stateCode) async {
    AppLogger.i(
      '[DEBUG] SchoolHolidaysNotifier: _loadHolidaysForCurrentYear called for state: $stateCode',
    );

    final now = DateTime.now();
    final start = DateTime(now.year, 1, 1);
    final end = DateTime(now.year, 12, 31);
    final currentState = state.value;

    AppLogger.i(
      '[DEBUG] SchoolHolidaysNotifier: Loading holidays for date range: $start to $end',
    );

    if (currentState != null) {
      state = AsyncValue.data(
        currentState.copyWith(isLoading: true, selectedStateCode: stateCode),
      );
    } else {
      state = AsyncValue.data(
        SchoolHolidaysUiState(
          isLoading: true,
          isRefreshing: false,
          isEnabled: true,
          selectedStateCode: stateCode,
        ),
      );
    }
    try {
      final result = await _getHolidaysUseCase.call(
        stateCode: stateCode,
        startDate: start,
        endDate: end,
      );
      final safeState = state.value!;
      result.fold(
        (failure) {
          AppLogger.e(
            '[DEBUG] SchoolHolidaysNotifier: Failed to load holidays: ${failure.technicalMessage}',
          );
          state = AsyncValue.data(
            safeState.copyWith(
              isLoading: false,
              error: failure.technicalMessage,
            ),
          );
        },
        (holidays) async {
          AppLogger.i(
            '[DEBUG] SchoolHolidaysNotifier: Successfully loaded ${holidays.length} holidays',
          );

          // Load the last refresh time from settings
          final settings = await _getSettingsUseCase.execute();
          final lastRefreshTime = settings?.lastSchoolHolidayRefresh;

          // Merge new holidays with existing ones to avoid losing data from other months
          final existingHolidays = safeState.allHolidays;
          final existingHolidayIds = existingHolidays.map((h) => h.id).toSet();
          final newHolidays = holidays
              .where((h) => !existingHolidayIds.contains(h.id))
              .toList();
          final mergedHolidays = [...existingHolidays, ...newHolidays];

          AppLogger.i(
            '[DEBUG] SchoolHolidaysNotifier: Merged holidays: ${existingHolidays.length} existing + ${newHolidays.length} new = ${mergedHolidays.length} total',
          );

          final holidaysByDate = _groupHolidaysByDate(mergedHolidays);
          AppLogger.i(
            '[DEBUG] SchoolHolidaysNotifier: Grouped holidays by date: ${holidaysByDate.length} dates',
          );

          state = AsyncValue.data(
            safeState.copyWith(
              isLoading: false,
              allHolidays: mergedHolidays,
              holidaysByDate: holidaysByDate,
              lastRefreshTime: lastRefreshTime,
              error: null,
            ),
          );
        },
      );
    } catch (e) {
      AppLogger.e(
        '[DEBUG] SchoolHolidaysNotifier: Exception loading holidays: $e',
      );
      final safeState = state.value;
      if (safeState != null) {
        state = AsyncValue.data(
          safeState.copyWith(isLoading: false, error: e.toString()),
        );
      }
    }
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
