import 'dart:isolate';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart';

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

  ScheduleGenerationResult({
    required this.schedules,
    this.error,
  });
}

class ShutdownMessage extends IsolateMessage {}

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
        config.startDate.year, config.startDate.month, config.startDate.day);

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

  /// Floor division helper
  static int _floorDiv(int a, int b) {
    if (a < 0) {
      return -((-a + b - 1) ~/ b);
    }
    return a ~/ b;
  }
}
