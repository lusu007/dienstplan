import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/domain/failures/failure.dart';
import 'package:dienstplan/domain/failures/result.dart';
import 'package:dienstplan/domain/repositories/config_repository.dart';
import 'package:dienstplan/domain/repositories/schedule_repository.dart';
import 'package:dienstplan/domain/use_cases/generate_schedules_use_case.dart';

class EnsureMonthSchedulesUseCase {
  final ScheduleRepository _scheduleRepository;
  final ConfigRepository _configRepository;
  final GenerateSchedulesUseCase _generateSchedulesUseCase;

  EnsureMonthSchedulesUseCase(
    this._scheduleRepository,
    this._configRepository,
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
    final Result<int> countResult = await _scheduleRepository
        .countSchedulesForMonth(month: monthStart, configName: configName);
    if (countResult.isFailure) {
      return Result.createFailure<List<Schedule>>(countResult.failure);
    }
    final int count = countResult.value;
    final Result<List<DutyScheduleConfig>> configsResult =
        await _configRepository.getConfigs();
    if (configsResult.isFailure) {
      return Result.createFailure<List<Schedule>>(configsResult.failure);
    }
    DutyScheduleConfig? matched;
    for (final DutyScheduleConfig c in configsResult.value) {
      if (c.name == configName) {
        matched = c;
        break;
      }
    }
    if (matched == null) {
      return Result.createFailure<List<Schedule>>(
        ValidationFailure(
          technicalMessage: 'Configuration not found: $configName',
        ),
      );
    }
    final int schedulesPerDay = matched.expectedSchedulesPerCalendarDay;
    final int expectedTotal = daysInMonth * schedulesPerDay;
    // Do not use a coverage threshold here: e.g. 30/31 days filled (150/155)
    // passes 80% but still needs gap fill from GenerateSchedulesUseCase.
    if (schedulesPerDay > 0 && count >= expectedTotal) {
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
