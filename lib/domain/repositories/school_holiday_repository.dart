import '../entities/school_holiday.dart';
import '../failures/result.dart';

/// Repository interface for school holidays
abstract interface class SchoolHolidayRepository {
  /// Fetch school holidays for a specific state and year
  Future<Result<List<SchoolHoliday>>> getSchoolHolidays({
    required String stateCode,
    required int year,
  });

  /// Fetch school holidays for a specific state and date range
  Future<Result<List<SchoolHoliday>>> getSchoolHolidaysForRange({
    required String stateCode,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get cached holidays for a specific state and year
  Future<Result<List<SchoolHoliday>>> getCachedHolidays({
    required String stateCode,
    required int year,
  });

  /// Clear all cached holidays
  Future<Result<void>> clearCache();

  /// Refresh holidays from the API
  Future<Result<List<SchoolHoliday>>> refreshHolidays({
    required String stateCode,
    required int year,
  });
}
