import 'package:dartz/dartz.dart';

import '../entities/school_holiday.dart';
import '../failures/failure.dart';

/// Repository interface for school holidays
abstract interface class SchoolHolidayRepository {
  /// Fetch school holidays for a specific state and year
  Future<Either<Failure, List<SchoolHoliday>>> getSchoolHolidays({
    required String stateCode,
    required int year,
  });

  /// Fetch school holidays for a specific state and date range
  Future<Either<Failure, List<SchoolHoliday>>> getSchoolHolidaysForRange({
    required String stateCode,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get cached holidays for a specific state and year
  Future<Either<Failure, List<SchoolHoliday>>> getCachedHolidays({
    required String stateCode,
    required int year,
  });

  /// Clear all cached holidays
  Future<Either<Failure, Unit>> clearCache();

  /// Refresh holidays from the API
  Future<Either<Failure, List<SchoolHoliday>>> refreshHolidays({
    required String stateCode,
    required int year,
  });
}
