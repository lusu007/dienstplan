import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/domain/entities/duty_type.dart';
import 'package:dienstplan/domain/repositories/schedule_repository.dart'
    as domain_repo;
import 'package:dienstplan/data/daos/schedules_dao.dart';
import 'package:dienstplan/data/daos/duty_types_dao.dart';
import 'package:dienstplan/data/models/mappers/schedule_mapper.dart' as mapper;
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/domain/failures/result.dart';
import 'package:dienstplan/core/errors/exception_mapper.dart';
import 'package:dienstplan/domain/failures/failure.dart';

class ScheduleRepositoryImpl implements domain_repo.ScheduleRepository {
  final SchedulesDao _schedulesDao;
  final DutyTypesDao _dutyTypesDao;
  final ExceptionMapper _exceptionMapper;

  ScheduleRepositoryImpl(
    this._schedulesDao,
    this._dutyTypesDao, {
    ExceptionMapper? exceptionMapper,
  }) : _exceptionMapper = exceptionMapper ?? const ExceptionMapper();

  @override
  Future<List<Schedule>> getSchedules() async {
    try {
      AppLogger.i('ScheduleRepository: Getting all schedules');
      final dataSchedules = await _schedulesDao.loadSchedules();
      final schedules = dataSchedules.map(mapper.toDomainSchedule).toList();
      AppLogger.i(
        'ScheduleRepository: Retrieved ${schedules.length} schedules',
      );
      return schedules;
    } catch (e, stackTrace) {
      AppLogger.e('ScheduleRepository: Error getting schedules', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<Result<List<Schedule>>> getSchedulesSafe() async {
    try {
      final result = await getSchedules();
      return Result.success<List<Schedule>>(result);
    } catch (e, stackTrace) {
      final Failure failure = _exceptionMapper.mapToFailure(e, stackTrace);
      return Result.createFailure<List<Schedule>>(failure);
    }
  }

  @override
  Future<List<Schedule>> getSchedulesForDateRange({
    required DateTime start,
    required DateTime end,
    String? configName,
  }) async {
    try {
      AppLogger.i(
        'ScheduleRepository: Getting schedules for date range: $start to $end${configName != null ? ' for config: $configName' : ''}',
      );
      final dataSchedules = await _schedulesDao.loadSchedulesForRange(
        startDate: start,
        endDate: end,
        configName: configName,
      );
      final schedules = dataSchedules.map(mapper.toDomainSchedule).toList();
      AppLogger.i(
        'ScheduleRepository: Retrieved ${schedules.length} schedules for date range',
      );
      return schedules;
    } catch (e, stackTrace) {
      AppLogger.e(
        'ScheduleRepository: Error getting schedules for date range',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  @override
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

  @override
  Future<void> saveSchedules(List<Schedule> schedules) async {
    try {
      AppLogger.i('ScheduleRepository: Saving ${schedules.length} schedules');
      final dataSchedules = schedules.map(mapper.toDataSchedule).toList();
      await _schedulesDao.saveSchedules(dataSchedules);
      AppLogger.i('ScheduleRepository: Successfully saved schedules');
    } catch (e, stackTrace) {
      AppLogger.e('ScheduleRepository: Error saving schedules', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<Result<void>> saveSchedulesSafe(List<Schedule> schedules) async {
    try {
      await saveSchedules(schedules);
      return Result.success<void>(null);
    } catch (e, stackTrace) {
      final Failure failure = _exceptionMapper.mapToFailure(e, stackTrace);
      return Result.createFailure<void>(failure);
    }
  }

  @override
  Future<void> clearSchedules() async {
    try {
      AppLogger.i('ScheduleRepository: Clearing all schedules');
      await _schedulesDao.clear();
      AppLogger.i('ScheduleRepository: Successfully cleared all schedules');
    } catch (e, stackTrace) {
      AppLogger.e(
        'ScheduleRepository: Error clearing schedules',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<Result<void>> clearSchedulesSafe() async {
    try {
      await clearSchedules();
      return Result.success<void>(null);
    } catch (e, stackTrace) {
      final Failure failure = _exceptionMapper.mapToFailure(e, stackTrace);
      return Result.createFailure<void>(failure);
    }
  }

  @override
  Future<void> deleteSchedulesByConfigName(String configName) async {
    try {
      AppLogger.i(
        'ScheduleRepository: Deleting schedules for config: $configName',
      );
      await _schedulesDao.deleteSchedulesByConfigName(configName);
      AppLogger.i(
        'ScheduleRepository: Successfully deleted schedules for config: $configName',
      );
    } catch (e, stackTrace) {
      AppLogger.e(
        'ScheduleRepository: Error deleting schedules for config',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<Result<void>> deleteSchedulesByConfigNameSafe(
    String configName,
  ) async {
    try {
      await deleteSchedulesByConfigName(configName);
      return Result.success<void>(null);
    } catch (e, stackTrace) {
      final Failure failure = _exceptionMapper.mapToFailure(e, stackTrace);
      return Result.createFailure<void>(failure);
    }
  }

  @override
  Future<List<DutyType>> getDutyTypes({required String configName}) async {
    try {
      AppLogger.i(
        'ScheduleRepository: Getting duty types for config: $configName',
      );
      final dataDutyTypesMap = await _dutyTypesDao.loadForConfig(configName);
      final dutyTypes = dataDutyTypesMap.values
          .map(
            (dt) =>
                DutyType(label: dt.label, isAllDay: dt.isAllDay, icon: dt.icon),
          )
          .toList();
      AppLogger.i(
        'ScheduleRepository: Retrieved ${dutyTypes.length} duty types',
      );
      return dutyTypes;
    } catch (e, stackTrace) {
      AppLogger.e(
        'ScheduleRepository: Error getting duty types',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<Result<List<DutyType>>> getDutyTypesSafe({
    required String configName,
  }) async {
    try {
      final result = await getDutyTypes(configName: configName);
      return Result.success<List<DutyType>>(result);
    } catch (e, stackTrace) {
      final Failure failure = _exceptionMapper.mapToFailure(e, stackTrace);
      return Result.createFailure<List<DutyType>>(failure);
    }
  }

  @override
  Future<int> countSchedulesForMonth({
    required DateTime month,
    String? configName,
  }) async {
    try {
      return await _schedulesDao.countSchedulesForMonth(
        month: month,
        configName: configName,
      );
    } catch (e, stackTrace) {
      AppLogger.e(
        'ScheduleRepository: Error counting schedules for month',
        e,
        stackTrace,
      );
      rethrow;
    }
  }
}
