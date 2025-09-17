import 'package:freezed_annotation/freezed_annotation.dart';

part 'school_holiday.freezed.dart';

/// Represents a school holiday period
@freezed
abstract class SchoolHoliday with _$SchoolHoliday {
  const factory SchoolHoliday({
    required String id,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    required String stateCode,
    required String stateName,
    String? description,
    HolidayType? type,
  }) = _SchoolHoliday;

  const SchoolHoliday._();

  /// Check if a date falls within this holiday period
  bool containsDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final startOnly = DateTime(startDate.year, startDate.month, startDate.day);
    final endOnly = DateTime(endDate.year, endDate.month, endDate.day);

    return !dateOnly.isBefore(startOnly) && !dateOnly.isAfter(endOnly);
  }

  /// Get the duration of the holiday in days
  int get durationInDays {
    return endDate.difference(startDate).inDays + 1;
  }
}

/// Types of school holidays
enum HolidayType {
  /// Regular school holidays (e.g., summer vacation)
  regular,

  /// Public holidays that also affect schools
  publicHoliday,

  /// Movable holidays specific to individual schools
  movableHoliday,

  /// Other types of holidays
  other,
}
