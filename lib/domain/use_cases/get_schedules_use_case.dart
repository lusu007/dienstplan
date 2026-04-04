import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/domain/repositories/schedule_repository.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/domain/failures/result.dart';
import 'package:dienstplan/domain/failures/failure.dart';

class GetSchedulesUseCase {
  final ScheduleRepository _scheduleRepository;

  GetSchedulesUseCase(this._scheduleRepository);

  Future<Result<List<Schedule>>> execute() async {
    AppLogger.d('GetSchedulesUseCase: Executing get schedules');
    final Result<List<Schedule>> result = await _scheduleRepository
        .getSchedules();
    if (result.isFailure) {
      AppLogger.e(
        'GetSchedulesUseCase: Error getting schedules',
        result.failure.cause ?? result.failure,
        result.failure.stackTrace,
      );
      return result;
    }
    AppLogger.d(
      'GetSchedulesUseCase: Retrieved ${result.value.length} schedules',
    );
    return result;
  }

  Future<Result<List<Schedule>>> executeForDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? configName,
  }) async {
    AppLogger.d(
      'GetSchedulesUseCase: Executing get schedules for date range: $startDate to $endDate${configName != null ? ' for config: $configName' : ''}',
    );
    if (startDate.isAfter(endDate)) {
      return Result.createFailure<List<Schedule>>(
        const ValidationFailure(
          technicalMessage: 'Start date cannot be after end date',
        ),
      );
    }
    final Result<List<Schedule>> result = await _scheduleRepository
        .getSchedulesForDateRange(
          start: startDate,
          end: endDate,
          configName: configName,
        );
    if (result.isFailure) {
      AppLogger.e(
        'GetSchedulesUseCase: Error getting schedules for date range',
        result.failure.cause ?? result.failure,
        result.failure.stackTrace,
      );
      return result;
    }
    AppLogger.d(
      'GetSchedulesUseCase: Retrieved ${result.value.length} schedules for date range',
    );
    return result;
  }

  Future<Result<void>> clearSchedules() async {
    AppLogger.d('GetSchedulesUseCase: Clearing all schedules');
    final Result<void> result = await _scheduleRepository.clearSchedules();
    if (result.isFailure) {
      AppLogger.e(
        'GetSchedulesUseCase: Error clearing schedules',
        result.failure.cause ?? result.failure,
        result.failure.stackTrace,
      );
      return result;
    }
    AppLogger.d('GetSchedulesUseCase: All schedules cleared');
    return result;
  }
}
