import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/domain/use_cases/generate_schedules_use_case.dart';
import 'package:dienstplan/domain/repositories/schedule_repository.dart';
import 'package:dienstplan/core/constants/schedule_constants.dart';

class EnsureMonthSchedulesUseCase {
  final ScheduleRepository _scheduleRepository;
  final GenerateSchedulesUseCase _generateSchedulesUseCase;

  EnsureMonthSchedulesUseCase(
    this._scheduleRepository,
    this._generateSchedulesUseCase,
  );

  Future<List<Schedule>> execute({
    required String configName,
    required DateTime monthStart,
  }) async {
    final DateTime monthEnd = DateTime(
      monthStart.year,
      monthStart.month + 1,
      0,
    );
    // Fast path: count rows for the month and short-circuit if coverage is high
    final int daysInMonth = monthEnd.day;
    const int expectedPerDay = kExpectedSchedulesPerDay;
    const double coverageThreshold = kCoverageThreshold; // e.g., 0.8
    final int expectedTotal = daysInMonth * expectedPerDay;
    final int count = await _scheduleRepository.countSchedulesForMonth(
      month: monthStart,
      configName: configName,
    );
    if (count >= (expectedTotal * coverageThreshold).floor()) {
      // Enough coverage; return the loaded month using a lightweight range fetch
      return await _scheduleRepository.getSchedulesForDateRange(
        start: monthStart,
        end: monthEnd,
        configName: configName,
      );
    }
    final List<Schedule> generated = await _generateSchedulesUseCase.execute(
      configName: configName,
      startDate: monthStart,
      endDate: monthEnd,
    );

    return generated;
  }
}
