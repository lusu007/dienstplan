import 'dart:isolate';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/domain/services/schedule_merge_service.dart';
import 'package:dienstplan/domain/value_objects/date_range.dart';

/// Message types for isolate communication
abstract class IsolateMessage {}

class GenerateSchedulesMessage extends IsolateMessage {
  final DutyScheduleConfig config;
  final DateTime startDate;
  final DateTime endDate;
  final SendPort replyPort;

  GenerateSchedulesMessage({
    required this.config,
    required this.startDate,
    required this.endDate,
    required this.replyPort,
  });
}

class ScheduleGenerationResult {
  final List<Schedule> schedules;
  final String? error;

  ScheduleGenerationResult({required this.schedules, this.error});
}

class ShutdownMessage extends IsolateMessage {}

class MergeUpsertMessage extends IsolateMessage {
  final List<Schedule> existing;
  final List<Schedule> incoming;
  final SendPort replyPort;

  MergeUpsertMessage({
    required this.existing,
    required this.incoming,
    required this.replyPort,
  });
}

class DeduplicateMessage extends IsolateMessage {
  final List<Schedule> schedules;
  final SendPort replyPort;

  DeduplicateMessage({required this.schedules, required this.replyPort});
}

class CleanupOldSchedulesMessage extends IsolateMessage {
  final List<Schedule> schedules;
  final DateTime currentDate;
  final int monthsToKeep;
  final DateTime? selectedDay;
  final SendPort replyPort;

  CleanupOldSchedulesMessage({
    required this.schedules,
    required this.currentDate,
    required this.monthsToKeep,
    required this.selectedDay,
    required this.replyPort,
  });
}

class MergeReplacingConfigInRangeMessage extends IsolateMessage {
  final List<Schedule> existing;
  final List<Schedule> incoming;
  final DateRange range;
  final String replaceConfigName;
  final SendPort replyPort;

  MergeReplacingConfigInRangeMessage({
    required this.existing,
    required this.incoming,
    required this.range,
    required this.replaceConfigName,
    required this.replyPort,
  });
}

/// Background isolate for schedule generation
class ScheduleGenerationIsolate {
  static Isolate? _isolate;
  static SendPort? _sendPort;
  static bool _isInitialized = false;

  /// Initialize the isolate
  static Future<void> initialize() async {
    if (_isInitialized) return;

    final receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_isolateEntryPoint, receivePort.sendPort);
    _sendPort = await receivePort.first as SendPort;
    _isInitialized = true;
  }

  /// Generate schedules in background isolate
  static Future<List<Schedule>> generateSchedules({
    required DutyScheduleConfig config,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final receivePort = ReceivePort();
    final message = GenerateSchedulesMessage(
      config: config,
      startDate: startDate,
      endDate: endDate,
      replyPort: receivePort.sendPort,
    );

    _sendPort!.send(message);
    final result = await receivePort.first as ScheduleGenerationResult;

    if (result.error != null) {
      throw Exception('Schedule generation failed: ${result.error}');
    }

    return result.schedules;
  }

  /// Dispose the isolate
  static Future<void> dispose() async {
    if (!_isInitialized) return;

    _sendPort?.send(ShutdownMessage());
    _isolate?.kill();
    _isolate = null;
    _sendPort = null;
    _isInitialized = false;
  }

  /// Entry point for the isolate
  static void _isolateEntryPoint(SendPort mainSendPort) {
    final receivePort = ReceivePort();
    mainSendPort.send(receivePort.sendPort);

    receivePort.listen((message) {
      if (message is GenerateSchedulesMessage) {
        _handleGenerateSchedules(message);
      } else if (message is MergeUpsertMessage) {
        _handleMergeUpsert(message);
      } else if (message is DeduplicateMessage) {
        _handleDeduplicate(message);
      } else if (message is CleanupOldSchedulesMessage) {
        _handleCleanupOld(message);
      } else if (message is MergeReplacingConfigInRangeMessage) {
        _handleMergeReplacingInRange(message);
      } else if (message is ShutdownMessage) {
        receivePort.close();
      }
    });
  }

  /// Handle schedule generation in isolate
  static void _handleGenerateSchedules(GenerateSchedulesMessage message) {
    try {
      final schedules = _generateSchedulesSync(
        message.config,
        message.startDate,
        message.endDate,
      );

      final result = ScheduleGenerationResult(schedules: schedules);
      message.replyPort.send(result);
    } catch (e) {
      final result = ScheduleGenerationResult(
        schedules: [],
        error: e.toString(),
      );
      message.replyPort.send(result);
    }
  }

  /// Synchronous schedule generation (runs in isolate)
  static List<Schedule> _generateSchedulesSync(
    DutyScheduleConfig config,
    DateTime startDate,
    DateTime endDate,
  ) {
    final schedules = <Schedule>[];

    final daysToGenerate = endDate.difference(startDate).inDays;

    // Pre-calculate normalized start date
    final normalizedStartDate = DateTime.utc(
      config.startDate.year,
      config.startDate.month,
      config.startDate.day,
    );

    // Pre-calculate rhythm patterns for better performance
    final rhythmPatterns = <String, List<List<String>>>{};
    for (final dutyGroup in config.dutyGroups) {
      final rhythm = config.rhythms[dutyGroup.rhythm];
      if (rhythm != null) {
        rhythmPatterns[dutyGroup.rhythm] = rhythm.pattern;
      }
    }

    // Pre-calculate duty types for better performance
    final dutyTypes = config.dutyTypes;

    for (var i = 0; i <= daysToGenerate; i++) {
      final date = startDate.add(Duration(days: i));
      final normalizedDate = DateTime.utc(date.year, date.month, date.day);

      final deltaDays = normalizedDate.difference(normalizedStartDate).inDays;

      for (final dutyGroup in config.dutyGroups) {
        final rhythmPattern = rhythmPatterns[dutyGroup.rhythm];
        if (rhythmPattern == null) {
          continue;
        }

        final rhythm = config.rhythms[dutyGroup.rhythm]!;
        final rawWeekIndex =
            _floorDiv(deltaDays, 7) - dutyGroup.offsetWeeks.toInt();
        final weekIndex =
            ((rawWeekIndex % rhythm.lengthWeeks) + rhythm.lengthWeeks) %
            rhythm.lengthWeeks;
        final dayIndex = ((deltaDays % 7) + 7) % 7;

        if (weekIndex >= 0 &&
            weekIndex < rhythmPattern.length &&
            dayIndex >= 0 &&
            dayIndex < rhythmPattern[weekIndex].length) {
          final dutyTypeId = rhythmPattern[weekIndex][dayIndex];
          final dutyType = dutyTypes[dutyTypeId];

          if (dutyType != null) {
            final schedule = Schedule(
              date: normalizedDate,
              configName: config.name,
              dutyGroupId: dutyGroup.id,
              dutyGroupName: dutyGroup.name,
              service: dutyType.label,
              dutyTypeId: dutyTypeId,
              isAllDay: dutyType.isAllDay,
            );

            schedules.add(schedule);
          }
        }
      }
    }

    return schedules;
  }

  /// Isolate-side merge/dedup/cleanup using ScheduleMergeService
  static final ScheduleMergeService _mergeService = ScheduleMergeService();

  static void _handleMergeUpsert(MergeUpsertMessage message) {
    try {
      final merged = _mergeService.upsertByKey(
        existing: message.existing,
        incoming: message.incoming,
      );
      message.replyPort.send(merged);
    } catch (e) {
      message.replyPort.send(<Schedule>[]);
    }
  }

  static void _handleDeduplicate(DeduplicateMessage message) {
    try {
      final deduped = _mergeService.deduplicate(message.schedules);
      message.replyPort.send(deduped);
    } catch (e) {
      message.replyPort.send(<Schedule>[]);
    }
  }

  static void _handleCleanupOld(CleanupOldSchedulesMessage message) {
    try {
      final cleaned = _mergeService.cleanupOldSchedules(
        schedules: message.schedules,
        currentDate: message.currentDate,
        monthsToKeep: message.monthsToKeep,
        selectedDay: message.selectedDay,
      );
      message.replyPort.send(cleaned);
    } catch (e) {
      message.replyPort.send(<Schedule>[]);
    }
  }

  static void _handleMergeReplacingInRange(
    MergeReplacingConfigInRangeMessage message,
  ) {
    try {
      final merged = _mergeService.mergeReplacingConfigInRange(
        existing: message.existing,
        incoming: message.incoming,
        range: message.range,
        replaceConfigName: message.replaceConfigName,
      );
      message.replyPort.send(merged);
    } catch (e) {
      message.replyPort.send(<Schedule>[]);
    }
  }

  // Public API wrappers
  static Future<List<Schedule>> mergeUpsertByKey({
    required List<Schedule> existing,
    required List<Schedule> incoming,
  }) async {
    if (!_isInitialized) await initialize();
    final receivePort = ReceivePort();
    _sendPort!.send(
      MergeUpsertMessage(
        existing: existing,
        incoming: incoming,
        replyPort: receivePort.sendPort,
      ),
    );
    final result = await receivePort.first as List<Schedule>;
    return result;
  }

  static Future<List<Schedule>> deduplicateSchedules({
    required List<Schedule> schedules,
  }) async {
    if (!_isInitialized) await initialize();
    final receivePort = ReceivePort();
    _sendPort!.send(
      DeduplicateMessage(schedules: schedules, replyPort: receivePort.sendPort),
    );
    final result = await receivePort.first as List<Schedule>;
    return result;
  }

  static Future<List<Schedule>> cleanupOldSchedules({
    required List<Schedule> schedules,
    required DateTime currentDate,
    required int monthsToKeep,
    DateTime? selectedDay,
  }) async {
    if (!_isInitialized) await initialize();
    final receivePort = ReceivePort();
    _sendPort!.send(
      CleanupOldSchedulesMessage(
        schedules: schedules,
        currentDate: currentDate,
        monthsToKeep: monthsToKeep,
        selectedDay: selectedDay,
        replyPort: receivePort.sendPort,
      ),
    );
    final result = await receivePort.first as List<Schedule>;
    return result;
  }

  static Future<List<Schedule>> mergeReplacingConfigInRange({
    required List<Schedule> existing,
    required List<Schedule> incoming,
    required DateRange range,
    required String replaceConfigName,
  }) async {
    if (!_isInitialized) await initialize();
    final receivePort = ReceivePort();
    _sendPort!.send(
      MergeReplacingConfigInRangeMessage(
        existing: existing,
        incoming: incoming,
        range: range,
        replaceConfigName: replaceConfigName,
        replyPort: receivePort.sendPort,
      ),
    );
    final result = await receivePort.first as List<Schedule>;
    return result;
  }

  /// Floor division helper
  static int _floorDiv(int a, int b) {
    if (a < 0) {
      return -((-a + b - 1) ~/ b);
    }
    return a ~/ b;
  }
}
