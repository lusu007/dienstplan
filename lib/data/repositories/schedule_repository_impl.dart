import 'package:dienstplan/domain/repositories/schedule_repository.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/domain/entities/duty_type.dart';
import 'package:dienstplan/data/services/database_service.dart';
import 'package:dienstplan/data/models/schedule.dart' as data;
import 'package:dienstplan/data/models/duty_type.dart' as data;
import 'package:dienstplan/core/utils/logger.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final DatabaseService _databaseService;

  ScheduleRepositoryImpl(this._databaseService);

  @override
  Future<List<Schedule>> getSchedules() async {
    try {
      final dataSchedules = await _databaseService.loadSchedules();
      return dataSchedules.map((e) => _toDomainSchedule(e)).toList();
    } catch (e, stack) {
      AppLogger.e('Error in getSchedules', e, stack);
      rethrow;
    }
  }

  @override
  Future<List<Schedule>> getSchedulesForDateRange({
    required DateTime start,
    required DateTime end,
    String? configName,
  }) async {
    try {
      final dataSchedules = await _databaseService
          .loadSchedulesForDateRange(start, end, configName: configName);
      return dataSchedules.map((e) => _toDomainSchedule(e)).toList();
    } catch (e, stack) {
      AppLogger.e('Error in getSchedulesForDateRange', e, stack);
      rethrow;
    }
  }

  @override
  Future<void> saveSchedules(List<Schedule> schedules) async {
    try {
      final dataSchedules = schedules.map((e) => _toDataSchedule(e)).toList();
      await _databaseService.saveSchedules(dataSchedules);
    } catch (e, stack) {
      AppLogger.e('Error in saveSchedules', e, stack);
      rethrow;
    }
  }

  @override
  Future<void> clearSchedules() async {
    try {
      await _databaseService.clearDatabase();
    } catch (e, stack) {
      AppLogger.e('Error in clearSchedules', e, stack);
      rethrow;
    }
  }

  @override
  Future<List<DutyType>> getDutyTypes({required String configName}) async {
    try {
      final dataDutyTypesMap = await _databaseService.loadDutyTypes(configName);
      return dataDutyTypesMap.values.map((e) => _toDomainDutyType(e)).toList();
    } catch (e, stack) {
      AppLogger.e('Error in getDutyTypes', e, stack);
      rethrow;
    }
  }

  // Mapping helpers
  Schedule _toDomainSchedule(data.Schedule s) => Schedule(
        date: s.date,
        service: s.service,
        dutyGroupId: s.dutyGroupId,
        dutyTypeId: s.dutyTypeId,
        dutyGroupName: s.dutyGroupName,
        configName: s.configName,
        isAllDay: s.isAllDay,
      );

  data.Schedule _toDataSchedule(Schedule s) => data.Schedule(
        date: s.date,
        service: s.service,
        dutyGroupId: s.dutyGroupId,
        dutyTypeId: s.dutyTypeId,
        dutyGroupName: s.dutyGroupName,
        configName: s.configName,
        isAllDay: s.isAllDay,
      );

  DutyType _toDomainDutyType(data.DutyType d) => DutyType(
        // Map fields as needed, adjust if domain/data models differ
        label: d.label,
        isAllDay: d.isAllDay,
        icon: d.icon,
        // Add other fields if present in your domain model
      );
}
