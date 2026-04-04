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
  Future<Result<List<Schedule>>> getSchedules() async {
    try {
      AppLogger.d('ScheduleRepository: Getting all schedules');
      final dataSchedules = await _schedulesDao.loadSchedules();
      final schedules = dataSchedules.map(mapper.toDomainSchedule).toList();
      AppLogger.d(
        'ScheduleRepository: Retrieved ${schedules.length} schedules',
      );
      return Result.success<List<Schedule>>(schedules);
    } catch (e, stackTrace) {
      AppLogger.e('ScheduleRepository: Error getting schedules', e, stackTrace);
      final Failure failure = _exceptionMapper.mapToFailure(e, stackTrace);
      return Result.createFailure<List<Schedule>>(failure);
    }
  }

  @override
  Future<Result<List<Schedule>>> getSchedulesForDateRange({
    required DateTime start,
    required DateTime end,
    String? configName,
  }) async {
    try {
      AppLogger.d(
        'ScheduleRepository: Getting schedules for date range: $start to $end${configName != null ? ' for config: $configName' : ''}',
      );
      final dataSchedules = await _schedulesDao.loadSchedulesForRange(
        startDate: start,
        endDate: end,
        configName: configName,
      );
      final schedules = dataSchedules.map(mapper.toDomainSchedule).toList();
      AppLogger.d(
        'ScheduleRepository: Retrieved ${schedules.length} schedules for date range',
      );
      return Result.success<List<Schedule>>(schedules);
    } catch (e, stackTrace) {
      AppLogger.e(
        'ScheduleRepository: Error getting schedules for date range',
        e,
        stackTrace,
      );
      final Failure failure = _exceptionMapper.mapToFailure(e, stackTrace);
      return Result.createFailure<List<Schedule>>(failure);
    }
  }

  @override
  Future<Result<void>> saveSchedules(List<Schedule> schedules) async {
    try {
      AppLogger.d('ScheduleRepository: Saving ${schedules.length} schedules');
      final dataSchedules = schedules.map(mapper.toDataSchedule).toList();
      await _schedulesDao.saveSchedules(dataSchedules);
      AppLogger.d('ScheduleRepository: Successfully saved schedules');
      return Result.success<void>(null);
    } catch (e, stackTrace) {
      AppLogger.e('ScheduleRepository: Error saving schedules', e, stackTrace);
      final Failure failure = _exceptionMapper.mapToFailure(e, stackTrace);
      return Result.createFailure<void>(failure);
    }
  }

  @override
  Future<Result<void>> clearSchedules() async {
    try {
      AppLogger.d('ScheduleRepository: Clearing all schedules');
      await _schedulesDao.clear();
      AppLogger.d('ScheduleRepository: Successfully cleared all schedules');
      return Result.success<void>(null);
    } catch (e, stackTrace) {
      AppLogger.e(
        'ScheduleRepository: Error clearing schedules',
        e,
        stackTrace,
      );
      final Failure failure = _exceptionMapper.mapToFailure(e, stackTrace);
      return Result.createFailure<void>(failure);
    }
  }

  @override
  Future<Result<void>> deleteSchedulesByConfigName(String configName) async {
    try {
      AppLogger.d(
        'ScheduleRepository: Deleting schedules for config: $configName',
      );
      await _schedulesDao.deleteSchedulesByConfigName(configName);
      AppLogger.d(
        'ScheduleRepository: Successfully deleted schedules for config: $configName',
      );
      return Result.success<void>(null);
    } catch (e, stackTrace) {
      AppLogger.e(
        'ScheduleRepository: Error deleting schedules for config',
        e,
        stackTrace,
      );
      final Failure failure = _exceptionMapper.mapToFailure(e, stackTrace);
      return Result.createFailure<void>(failure);
    }
  }

  @override
  Future<Result<List<DutyType>>> getDutyTypes({
    required String configName,
  }) async {
    try {
      AppLogger.d(
        'ScheduleRepository: Getting duty types for config: $configName',
      );
      final dataDutyTypesMap = await _dutyTypesDao.loadForConfig(configName);
      final dutyTypes = dataDutyTypesMap.values
          .map(
            (dt) =>
                DutyType(label: dt.label, isAllDay: dt.isAllDay, icon: dt.icon),
          )
          .toList();
      AppLogger.d(
        'ScheduleRepository: Retrieved ${dutyTypes.length} duty types',
      );
      return Result.success<List<DutyType>>(dutyTypes);
    } catch (e, stackTrace) {
      AppLogger.e(
        'ScheduleRepository: Error getting duty types',
        e,
        stackTrace,
      );
      final Failure failure = _exceptionMapper.mapToFailure(e, stackTrace);
      return Result.createFailure<List<DutyType>>(failure);
    }
  }

  @override
  Future<Result<int>> countSchedulesForMonth({
    required DateTime month,
    String? configName,
  }) async {
    try {
      final int count = await _schedulesDao.countSchedulesForMonth(
        month: month,
        configName: configName,
      );
      return Result.success<int>(count);
    } catch (e, stackTrace) {
      AppLogger.e(
        'ScheduleRepository: Error counting schedules for month',
        e,
        stackTrace,
      );
      final Failure failure = _exceptionMapper.mapToFailure(e, stackTrace);
      return Result.createFailure<int>(failure);
    }
  }
}
