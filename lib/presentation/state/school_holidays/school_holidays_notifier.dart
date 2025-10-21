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
    _getHolidaysUseCase = await ref.read(
      getSchoolHolidaysUseCaseProvider.future,
    );
    _getSettingsUseCase = await ref.read(getSettingsUseCaseProvider.future);
    _saveSettingsUseCase = await ref.read(saveSettingsUseCaseProvider.future);

    // Load initial settings
    final settings = await _getSettingsUseCase.execute();

    if (settings != null &&
        settings.showSchoolHolidays == true &&
        settings.schoolHolidayStateCode != null) {
      // Load holidays if enabled and return the result
      return await _loadHolidaysForCurrentYearAndReturnState(
        settings.schoolHolidayStateCode!,
      );
    } else {
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
      state = AsyncValue.data(
        previous.copyWith(
          isLoading: true,
          // Clear holidays immediately when starting toggle
          holidaysByDate: {},
          allHolidays: [],
        ),
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
        showSchoolHolidays: enabled,
        // Preserve state code selection, only reset timestamp when disabling
        lastSchoolHolidayRefresh: enabled
            ? currentSettings.lastSchoolHolidayRefresh
            : null,
      );
      final result = await _saveSettingsUseCase.executeSafe(updatedSettings);
      if (result.isSuccess) {
        if (enabled && updatedSettings.schoolHolidayStateCode != null) {
          await _loadHolidaysForCurrentYear(
            updatedSettings.schoolHolidayStateCode!,
          );
        } else {
          // Always update state when toggling, regardless of state code
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
              lastRefreshTime: updatedSettings.lastSchoolHolidayRefresh,
              error: null,
              // Clear holidays when disabled
              holidaysByDate: enabled ? base.holidaysByDate : {},
              allHolidays: enabled ? base.allHolidays : [],
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
        previous.copyWith(
          isLoading: true,
          selectedStateCode: stateCode,
          // Clear holidays immediately when starting state change
          holidaysByDate: {},
          allHolidays: [],
        ),
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

      // Check if the state code actually changed
      final stateChanged = currentSettings.schoolHolidayStateCode != stateCode;

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
              // Clear holidays if state changed or if no state selected
              holidaysByDate: (stateChanged || stateCode == null)
                  ? {}
                  : base.holidaysByDate,
              allHolidays: (stateChanged || stateCode == null)
                  ? []
                  : base.allHolidays,
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

  /// Load holidays for a specific year
  Future<void> loadHolidaysForYear(int year) async {
    final currentState = state.value;
    if (currentState == null ||
        !currentState.isEnabled ||
        currentState.selectedStateCode == null) {
      return;
    }

    // Check if we already have holidays for this year
    if (_hasHolidaysForYear(year)) {
      AppLogger.d(
        'SchoolHolidaysNotifier: Holidays for year $year already loaded',
      );
      return;
    }

    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      final start = DateTime(year, 1, 1);
      final end = DateTime(year, 12, 31);

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
          if (holidays.isEmpty) {
            state = AsyncValue.data(
              currentState.copyWith(
                isLoading: false,
                error: 'noHolidayDataForYear:$year',
              ),
            );
            return;
          }

          // Log the holidays we received
          for (final holiday in holidays) {
            AppLogger.d(
              'SchoolHolidaysNotifier: Holiday: ${holiday.name} from ${holiday.startDate} to ${holiday.endDate}',
            );
          }

          // Merge new holidays with existing ones
          final existingHolidays = currentState.allHolidays;
          final existingHolidayIds = existingHolidays.map((h) => h.id).toSet();
          final newHolidays = holidays
              .where((h) => !existingHolidayIds.contains(h.id))
              .toList();
          final mergedHolidays = [...existingHolidays, ...newHolidays];

          AppLogger.d(
            'SchoolHolidaysNotifier: Merged holidays - existing: ${existingHolidays.length}, new: ${newHolidays.length}, total: ${mergedHolidays.length}',
          );

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

  /// Check if holidays exist for a specific year
  bool _hasHolidaysForYear(int year) {
    final currentState = state.value;
    if (currentState == null || currentState.allHolidays.isEmpty) {
      return false;
    }

    // Check if we have holidays that START in the requested year
    // This ensures we have loaded the complete year's holidays, not just cross-year holidays
    final hasHolidaysStartingInYear = currentState.allHolidays.any(
      (holiday) => holiday.startDate.year == year,
    );

    return hasHolidaysStartingInYear;
  }

  /// Refresh holidays from API
  Future<void> refreshHolidays() async {
    final currentState = state.value;
    if (currentState == null ||
        !currentState.isEnabled ||
        currentState.selectedStateCode == null) {
      return;
    }

    state = AsyncValue.data(
      currentState.copyWith(
        isRefreshing: true,
        // Clear holidays immediately when starting refresh
        holidaysByDate: {},
        allHolidays: [],
      ),
    );

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
    final now = DateTime.now();
    final start = DateTime(now.year, 1, 1);
    final end = DateTime(now.year, 12, 31);

    try {
      final result = await _getHolidaysUseCase.call(
        stateCode: stateCode,
        startDate: start,
        endDate: end,
      );

      return result.fold(
        (failure) {
          AppLogger.e(
            'SchoolHolidaysNotifier: Failed to load holidays: ${failure.technicalMessage}',
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
          // Set the refresh timestamp when holidays are loaded
          final now = DateTime.now();
          final settings = await _getSettingsUseCase.execute();
          if (settings != null) {
            final updatedSettings = settings.copyWith(
              lastSchoolHolidayRefresh: now,
            );
            await _saveSettingsUseCase.executeSafe(updatedSettings);
          }

          final holidaysByDate = _groupHolidaysByDate(holidays);

          return SchoolHolidaysUiState(
            isLoading: false,
            isRefreshing: false,
            isEnabled: true,
            selectedStateCode: stateCode,
            allHolidays: holidays,
            holidaysByDate: holidaysByDate,
            lastRefreshTime: now,
            error: null,
          );
        },
      );
    } catch (e) {
      AppLogger.e('SchoolHolidaysNotifier: Exception loading holidays: $e');
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
    final now = DateTime.now();
    final start = DateTime(now.year, 1, 1);
    final end = DateTime(now.year, 12, 31);
    final currentState = state.value;

    if (currentState != null) {
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: true,
          selectedStateCode: stateCode,
          // Clear holidays immediately when starting to load
          holidaysByDate: {},
          allHolidays: [],
        ),
      );
    } else {
      state = AsyncValue.data(
        SchoolHolidaysUiState(
          isLoading: true,
          isRefreshing: false,
          isEnabled: true,
          selectedStateCode: stateCode,
          holidaysByDate: {},
          allHolidays: [],
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
            'SchoolHolidaysNotifier: Failed to load holidays: ${failure.technicalMessage}',
          );
          state = AsyncValue.data(
            safeState.copyWith(
              isLoading: false,
              isEnabled: true,
              error: failure.technicalMessage,
            ),
          );
        },
        (holidays) async {
          // Set the refresh timestamp when holidays are loaded
          final now = DateTime.now();
          final settings = await _getSettingsUseCase.execute();
          if (settings != null) {
            final updatedSettings = settings.copyWith(
              lastSchoolHolidayRefresh: now,
            );
            await _saveSettingsUseCase.executeSafe(updatedSettings);
          }

          // Replace holidays completely to ensure we have only the current state's data
          final holidaysByDate = _groupHolidaysByDate(holidays);

          state = AsyncValue.data(
            safeState.copyWith(
              isLoading: false,
              isEnabled: true,
              allHolidays: holidays,
              holidaysByDate: holidaysByDate,
              lastRefreshTime: now,
              error: null,
            ),
          );
        },
      );
    } catch (e) {
      AppLogger.e('SchoolHolidaysNotifier: Exception loading holidays: $e');
      final safeState = state.value;
      if (safeState != null) {
        state = AsyncValue.data(
          safeState.copyWith(
            isLoading: false,
            isEnabled: true,
            error: e.toString(),
          ),
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
