import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/domain/entities/duty_type.dart';
import 'package:dienstplan/data/services/database_service.dart';
import 'package:dienstplan/data/models/mappers/schedule_mapper.dart' as mapper;
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/domain/failures/result.dart';
import 'package:dienstplan/core/errors/exception_mapper.dart';
import 'package:dienstplan/domain/failures/failure.dart';

class ScheduleRepository {
  final DatabaseService _databaseService;
  final ExceptionMapper _exceptionMapper;

  ScheduleRepository(this._databaseService, {ExceptionMapper? exceptionMapper})
      : _exceptionMapper = exceptionMapper ?? const ExceptionMapper();

  Future<List<Schedule>> getSchedules() async {
    try {
      AppLogger.i('ScheduleRepository: Getting all schedules');
      final dataSchedules = await _databaseService.loadSchedules();
      final schedules = dataSchedules.map(mapper.toDomainSchedule).toList();
      AppLogger.i(
          'ScheduleRepository: Retrieved ${schedules.length} schedules');
      return schedules;
    } catch (e, stackTrace) {
      AppLogger.e('ScheduleRepository: Error getting schedules', e, stackTrace);
      rethrow;
    }
  }

  Future<Result<List<Schedule>>> getSchedulesSafe() async {
    try {
      final result = await getSchedules();
      return Result.success<List<Schedule>>(result);
    } catch (e, stackTrace) {
      final Failure failure = _exceptionMapper.mapToFailure(e, stackTrace);
      return Result.createFailure<List<Schedule>>(failure);
    }
  }

  Future<List<Schedule>> getSchedulesForDateRange({
    required DateTime start,
    required DateTime end,
    String? configName,
  }) async {
    try {
      AppLogger.i(
          'ScheduleRepository: Getting schedules for date range: $start to $end${configName != null ? ' for config: $configName' : ''}');
      final dataSchedules = await _databaseService
          .loadSchedulesForDateRange(start, end, configName: configName);
      final schedules = dataSchedules.map(mapper.toDomainSchedule).toList();
      AppLogger.i(
          'ScheduleRepository: Retrieved ${schedules.length} schedules for date range');
      return schedules;
    } catch (e, stackTrace) {
      AppLogger.e('ScheduleRepository: Error getting schedules for date range',
          e, stackTrace);
      rethrow;
    }
  }

  Future<Result<List<Schedule>>> getSchedulesForDateRangeSafe({
    required DateTime start,
    required DateTime end,
    String? configName,
  }) async {
    try {
      final result = await getSchedulesForDateRange(
        start: start,
        end: end,
        configName: configName,
      );
      return Result.success<List<Schedule>>(result);
    } catch (e, stackTrace) {
      final Failure failure = _exceptionMapper.mapToFailure(e, stackTrace);
      return Result.createFailure<List<Schedule>>(failure);
    }
  }

  Future<void> saveSchedules(List<Schedule> schedules) async {
    try {
      AppLogger.i('ScheduleRepository: Saving ${schedules.length} schedules');
      final dataSchedules = schedules.map(mapper.toDataSchedule).toList();
      await _databaseService.saveSchedules(dataSchedules);
      AppLogger.i('ScheduleRepository: Successfully saved schedules');
    } catch (e, stackTrace) {
      AppLogger.e('ScheduleRepository: Error saving schedules', e, stackTrace);
      rethrow;
    }
  }

  Future<Result<void>> saveSchedulesSafe(List<Schedule> schedules) async {
    try {
      await saveSchedules(schedules);
      return Result.success<void>(null);
    } catch (e, stackTrace) {
      final Failure failure = _exceptionMapper.mapToFailure(e, stackTrace);
      return Result.createFailure<void>(failure);
    }
  }

  Future<void> clearSchedules() async {
    try {
      AppLogger.i('ScheduleRepository: Clearing all schedules');
      await _databaseService.clearDatabase();
      AppLogger.i('ScheduleRepository: Successfully cleared all schedules');
    } catch (e, stackTrace) {
      AppLogger.e(
          'ScheduleRepository: Error clearing schedules', e, stackTrace);
      rethrow;
    }
  }

  Future<Result<void>> clearSchedulesSafe() async {
    try {
      await clearSchedules();
      return Result.success<void>(null);
    } catch (e, stackTrace) {
      final Failure failure = _exceptionMapper.mapToFailure(e, stackTrace);
      return Result.createFailure<void>(failure);
    }
  }

  Future<List<DutyType>> getDutyTypes({required String configName}) async {
    try {
      AppLogger.i(
          'ScheduleRepository: Getting duty types for config: $configName');
      final dataDutyTypesMap = await _databaseService.loadDutyTypes(configName);
      final dutyTypes = dataDutyTypesMap.values
          .map((dt) => DutyType(
                label: dt.label,
                isAllDay: dt.isAllDay,
                icon: dt.icon,
              ))
          .toList();
      AppLogger.i(
          'ScheduleRepository: Retrieved ${dutyTypes.length} duty types');
      return dutyTypes;
    } catch (e, stackTrace) {
      AppLogger.e(
          'ScheduleRepository: Error getting duty types', e, stackTrace);
      rethrow;
    }
  }

  Future<Result<List<DutyType>>> getDutyTypesSafe(
      {required String configName}) async {
    try {
      final result = await getDutyTypes(configName: configName);
      return Result.success<List<DutyType>>(result);
    } catch (e, stackTrace) {
      final Failure failure = _exceptionMapper.mapToFailure(e, stackTrace);
      return Result.createFailure<List<DutyType>>(failure);
    }
  }
}
