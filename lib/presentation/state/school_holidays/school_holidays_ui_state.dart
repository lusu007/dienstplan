import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/school_holiday.dart';

part 'school_holidays_ui_state.freezed.dart';

@freezed
abstract class SchoolHolidaysUiState with _$SchoolHolidaysUiState {
  const factory SchoolHolidaysUiState({
    required bool isLoading,
    required bool isRefreshing,
    required bool isEnabled,
    String? selectedStateCode,
    String? error,
    @Default({}) Map<DateTime, List<SchoolHoliday>> holidaysByDate,
    @Default([]) List<SchoolHoliday> allHolidays,
    DateTime? lastRefreshTime,
  }) = _SchoolHolidaysUiState;

  const SchoolHolidaysUiState._();

  factory SchoolHolidaysUiState.initial() => const SchoolHolidaysUiState(
    isLoading: false,
    isRefreshing: false,
    isEnabled: false,
  );

  /// Get holidays for a specific date
  List<SchoolHoliday> getHolidaysForDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return holidaysByDate[dateOnly] ?? [];
  }

  /// Check if a date has holidays
  bool hasHolidayOnDate(DateTime date) {
    return getHolidaysForDate(date).isNotEmpty;
  }

  /// Get all holidays within a date range
  List<SchoolHoliday> getHolidaysInRange(DateTime start, DateTime end) {
    return allHolidays.where((holiday) {
      return !holiday.endDate.isBefore(start) &&
          !holiday.startDate.isAfter(end);
    }).toList();
  }
}
