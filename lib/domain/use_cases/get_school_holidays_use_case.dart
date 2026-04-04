import '../entities/school_holiday.dart';
import '../failures/failure.dart';
import '../failures/result.dart';
import '../repositories/school_holiday_repository.dart';

/// Use case for fetching school holidays
class GetSchoolHolidaysUseCase {
  final SchoolHolidayRepository _repository;

  GetSchoolHolidaysUseCase(this._repository);

  /// Get school holidays for the current settings and date range
  Future<Result<List<SchoolHoliday>>> call({
    required String stateCode,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (stateCode.isEmpty) {
      return Result.createFailure<List<SchoolHoliday>>(
        const ValidationFailure(
          technicalMessage: 'No state selected for school holidays',
        ),
      );
    }

    return _repository.getSchoolHolidaysForRange(
      stateCode: stateCode,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Get school holidays for a specific year
  Future<Result<List<SchoolHoliday>>> forYear({
    required String stateCode,
    required int year,
  }) async {
    if (stateCode.isEmpty) {
      return Result.createFailure<List<SchoolHoliday>>(
        const ValidationFailure(
          technicalMessage: 'No state selected for school holidays',
        ),
      );
    }

    return _repository.getSchoolHolidays(stateCode: stateCode, year: year);
  }

  /// Refresh holidays from the API
  Future<Result<List<SchoolHoliday>>> refresh({
    required String stateCode,
    required int year,
  }) async {
    if (stateCode.isEmpty) {
      return Result.createFailure<List<SchoolHoliday>>(
        const ValidationFailure(
          technicalMessage: 'No state selected for school holidays',
        ),
      );
    }

    return _repository.refreshHolidays(stateCode: stateCode, year: year);
  }

  /// Clear all cached holidays
  Future<Result<void>> clearCache() async {
    return _repository.clearCache();
  }
}
