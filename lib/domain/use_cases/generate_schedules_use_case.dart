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
      // Note: In practice, only ±3 months are loaded at a time, so this limit is rarely reached
      // Removed arbitrary year limit since it's not needed for normal usage

      // Get the configuration first
      final configs = await _configRepository.getConfigs();
      final config = configs.firstWhere(
        (c) => c.name == configName,
        orElse: () =>
            throw ArgumentError('Configuration not found: $configName'),
      );

      // Check if schedules already exist for this range
      final existingSchedules =
          await _scheduleRepository.getSchedulesForDateRange(
        start: startDate,
        end: endDate,
        configName: configName,
      );

      // If we have schedules for most of the range, only generate missing ones
      const expectedSchedulesPerDay = 5; // Approximate number of duty groups
      final daysDifference = endDate.difference(startDate).inDays;
      final expectedTotalSchedules = daysDifference * expectedSchedulesPerDay;
      const coverageThreshold = 0.8; // 80% coverage threshold

      if (existingSchedules.length >=
          expectedTotalSchedules * coverageThreshold) {
        AppLogger.i(
            'GenerateSchedulesUseCase: Found ${existingSchedules.length} existing schedules, checking for gaps');

        // Find date gaps and only generate for missing dates
        final missingDates = _findMissingDates(
            existingSchedules, startDate, endDate, configName);

        if (missingDates.isEmpty) {
          AppLogger.i(
              'GenerateSchedulesUseCase: All schedules already exist, returning existing schedules');
          return existingSchedules;
        }

        AppLogger.i(
            'GenerateSchedulesUseCase: Generating schedules for ${missingDates.length} missing dates');

        // Generate only for missing dates
        final missingSchedules =
            await _generateForMissingDates(configName, missingDates, config);

        // Combine existing and new schedules
        final allSchedules = [...existingSchedules, ...missingSchedules];
        return allSchedules;
      }

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

  // Find missing dates in the schedule range
  List<DateTime> _findMissingDates(
    List<Schedule> existingSchedules,
    DateTime startDate,
    DateTime endDate,
    String configName,
  ) {
    final existingDates = existingSchedules
        .map((s) => DateTime(s.date.year, s.date.month, s.date.day))
        .toSet();

    final missingDates = <DateTime>[];
    for (var date = startDate;
        date.isBefore(endDate.add(const Duration(days: 1)));
        date = date.add(const Duration(days: 1))) {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      if (!existingDates.contains(normalizedDate)) {
        missingDates.add(normalizedDate);
      }
    }

    return missingDates;
  }

  // Generate schedules for missing dates only
  Future<List<Schedule>> _generateForMissingDates(
    String configName,
    List<DateTime> missingDates,
    DutyScheduleConfig config,
  ) async {
    if (missingDates.isEmpty) return [];

    final startDate = missingDates.first;
    final endDate = missingDates.last;

    // Convert domain config to data config
    final dataConfig = _toDataConfig(config);

    // Generate schedules for missing date range
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

    return schedules;
  }
}
