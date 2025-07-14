import 'package:dienstplan/domain/entities/schedule.dart' as domain;

class Schedule {
  final DateTime date;
  final String service;
  final String dutyGroupId;
  final String dutyTypeId;
  final bool isAllDay;
  final String dutyGroupName;
  final String configName;

  Schedule({
    required this.date,
    required this.service,
    required this.dutyGroupId,
    required this.dutyTypeId,
    required this.dutyGroupName,
    required this.configName,
    this.isAllDay = false,
  });

  factory Schedule.fromMap(Map<String, dynamic> map) {
    try {
      final dateStr = map['date'] as String?;
      if (dateStr == null) {
        throw ArgumentError('Date field is null in schedule map: $map');
      }

      final dateParts = dateStr.split('T')[0].split('-');
      if (dateParts.length != 3) {
        throw ArgumentError('Invalid date format: $dateStr');
      }

      final service = map['service'] as String? ?? '';
      final dutyGroupId = map['duty_group_id'] as String? ?? '';
      final dutyTypeId = map['duty_type_id'] as String? ?? '';
      final dutyGroupName = map['duty_group_name'] as String? ?? '';
      final configName = map['config_name'] as String? ?? '';

      return Schedule(
        date: DateTime.utc(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
          int.parse(dateParts[2]),
        ),
        service: service,
        dutyGroupId: dutyGroupId,
        dutyTypeId: dutyTypeId,
        dutyGroupName: dutyGroupName,
        configName: configName,
        isAllDay: map['is_all_day'] == 1,
      );
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toUtc().toIso8601String(),
      'service': service,
      'duty_group_id': dutyGroupId,
      'duty_type_id': dutyTypeId,
      'duty_group_name': dutyGroupName,
      'config_name': configName,
      'is_all_day': isAllDay ? 1 : 0,
    };
  }

  @override
  String toString() {
    return 'Schedule(date: ${date.toUtc().toIso8601String()}, service: $service, dutyGroupId: $dutyGroupId, dutyTypeId: $dutyTypeId, dutyGroupName: $dutyGroupName, configName: $configName)';
  }

  /// Convert data model to domain entity
  domain.Schedule toDomain() {
    return domain.Schedule(
      date: date,
      service: service,
      dutyGroupId: dutyGroupId,
      dutyTypeId: dutyTypeId,
      dutyGroupName: dutyGroupName,
      configName: configName,
      isAllDay: isAllDay,
    );
  }

  /// Convert domain entity to data model
  factory Schedule.fromDomain(domain.Schedule schedule) {
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
