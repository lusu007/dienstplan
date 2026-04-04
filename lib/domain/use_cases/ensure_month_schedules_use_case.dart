import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/domain/use_cases/generate_schedules_use_case.dart';
import 'package:dienstplan/domain/repositories/schedule_repository.dart';
import 'package:dienstplan/core/constants/schedule_constants.dart';
import 'package:dienstplan/domain/failures/result.dart';

class EnsureMonthSchedulesUseCase {
  final ScheduleRepository _scheduleRepository;
  final GenerateSchedulesUseCase _generateSchedulesUseCase;

  EnsureMonthSchedulesUseCase(
    this._scheduleRepository,
    this._generateSchedulesUseCase,
  );

  Future<Result<List<Schedule>>> execute({
    required String configName,
    required DateTime monthStart,
  }) async {
    final DateTime monthEnd = DateTime(
      monthStart.year,
      monthStart.month + 1,
      0,
    );
    final int daysInMonth = monthEnd.day;
    const int expectedPerDay = kExpectedSchedulesPerDay;
    const double coverageThreshold = kCoverageThreshold;
    final int expectedTotal = daysInMonth * expectedPerDay;
    final Result<int> countResult = await _scheduleRepository
        .countSchedulesForMonth(month: monthStart, configName: configName);
    if (countResult.isFailure) {
      return Result.createFailure<List<Schedule>>(countResult.failure);
    }
    final int count = countResult.value;
    if (count >= (expectedTotal * coverageThreshold).floor()) {
      final Result<List<Schedule>> rangeResult = await _scheduleRepository
          .getSchedulesForDateRange(
            start: monthStart,
            end: monthEnd,
            configName: configName,
          );
      if (rangeResult.isFailure) {
        return Result.createFailure<List<Schedule>>(rangeResult.failure);
      }
      return rangeResult;
    }
    return _generateSchedulesUseCase.execute(
      configName: configName,
      startDate: monthStart,
      endDate: monthEnd,
    );
  }
}
