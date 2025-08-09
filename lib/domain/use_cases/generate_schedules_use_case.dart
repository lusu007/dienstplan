import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/data/repositories/schedule_repository.dart';
import 'package:dienstplan/data/repositories/config_repository.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/shared/utils/schedule_isolate.dart';

class GenerateSchedulesUseCase {
  final ScheduleRepository _scheduleRepository;
  final ConfigRepository _configRepository;

  GenerateSchedulesUseCase(
    this._scheduleRepository,
    this._configRepository,
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

      // Use background isolate for schedule generation
      final schedules = await ScheduleGenerationIsolate.generateSchedules(
        config: config,
        startDate: startDate,
        endDate: endDate,
      );

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

    // Generate schedules for missing date range using isolate
    final schedules = await ScheduleGenerationIsolate.generateSchedules(
      config: config,
      startDate: startDate,
      endDate: endDate,
    );

    // Save generated schedules
    await _scheduleRepository.saveSchedules(schedules);

    return schedules;
  }
}
