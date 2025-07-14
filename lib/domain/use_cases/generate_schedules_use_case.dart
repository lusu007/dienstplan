import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/data/repositories/schedule_repository.dart';
import 'package:dienstplan/data/repositories/config_repository.dart';
import 'package:dienstplan/data/services/schedule_config_service.dart';
import 'package:dienstplan/data/models/duty_schedule_config.dart' as data;
import 'package:dienstplan/data/models/schedule.dart' as data_schedule;
import 'package:dienstplan/data/models/duty_type.dart' as data_duty_type;
import 'package:dienstplan/core/utils/logger.dart';

class GenerateSchedulesUseCase {
  final ScheduleRepository _scheduleRepository;
  final ConfigRepository _configRepository;
  final ScheduleConfigService _scheduleConfigService;

  GenerateSchedulesUseCase(
    this._scheduleRepository,
    this._configRepository,
    this._scheduleConfigService,
  );

  Future<List<Schedule>> execute({
    required String configName,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      AppLogger.i(
          'GenerateSchedulesUseCase: Generating schedules for config: $configName from $startDate to $endDate');

      // Business logic: Validate date range
      if (startDate.isAfter(endDate)) {
        throw ArgumentError('Start date cannot be after end date');
      }

      // Business logic: Validate date range size (performance optimization)
      final daysDifference = endDate.difference(startDate).inDays;
      if (daysDifference > 365 * 5) {
        // Max 5 years
        throw ArgumentError('Date range too large. Maximum 5 years allowed.');
      }

      // Get the configuration
      final configs = await _configRepository.getConfigs();
      final config = configs.firstWhere(
        (c) => c.name == configName,
        orElse: () =>
            throw ArgumentError('Configuration not found: $configName'),
      );

      // Convert domain config to data config
      final dataConfig = _toDataConfig(config);

      // Use the working implementation from schedule_config_service
      final dataSchedules =
          await _scheduleConfigService.generateSchedulesForConfig(
        dataConfig,
        startDate: startDate,
        endDate: endDate,
      );

      // Convert data schedules to domain schedules
      final schedules = dataSchedules.map((s) => _toDomainSchedule(s)).toList();

      // Save generated schedules
      await _scheduleRepository.saveSchedules(schedules);

      AppLogger.i(
          'GenerateSchedulesUseCase: Generated and saved ${schedules.length} schedules');
      return schedules;
    } catch (e, stackTrace) {
      AppLogger.e('GenerateSchedulesUseCase: Error generating schedules', e,
          stackTrace);
      rethrow;
    }
  }

  // Convert domain config to data config
  data.DutyScheduleConfig _toDataConfig(DutyScheduleConfig config) {
    return data.DutyScheduleConfig(
      version: config.version,
      meta: data.Meta(
        name: config.meta.name,
        description: config.meta.description,
        startDate: config.meta.startDate,
        startWeekDay: config.meta.startWeekDay,
        days: List<String>.from(config.meta.days),
        icon: config.meta.icon,
      ),
      dutyTypes: config.dutyTypes.map((key, value) => MapEntry(
          key,
          data_duty_type.DutyType(
            label: value.label,
            isAllDay: value.isAllDay,
            icon: value.icon,
          ))),
      dutyTypeOrder: List<String>.from(config.dutyTypeOrder),
      rhythms: config.rhythms.map((key, value) => MapEntry(
          key,
          data.Rhythm(
            lengthWeeks: value.lengthWeeks,
            pattern:
                value.pattern.map((week) => List<String>.from(week)).toList(),
          ))),
      dutyGroups: config.dutyGroups
          .map((group) => data.DutyGroup(
                id: group.id,
                name: group.name,
                rhythm: group.rhythm,
                offsetWeeks: group.offsetWeeks,
              ))
          .toList(),
    );
  }

  // Convert data schedule to domain schedule
  Schedule _toDomainSchedule(data_schedule.Schedule schedule) {
    return Schedule(
      date: schedule.date,
      service: schedule.service,
      dutyGroupId: schedule.dutyGroupId,
      dutyTypeId: schedule.dutyTypeId,
      dutyGroupName: schedule.dutyGroupName,
      configName: schedule.configName,
      isAllDay: schedule.isAllDay,
    );
  }
}
