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
    return Schedule(
      date: DateTime.parse(map['date'] as String),
      service: map['service'] as String,
      dutyGroupId: map['duty_group_id'] as String,
      dutyTypeId: map['duty_type_id'] as String,
      dutyGroupName: map['duty_group_name'] as String,
      configName: map['config_name'] as String,
      isAllDay: map['is_all_day'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
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
    return 'Schedule(date: $date, service: $service, dutyGroupId: $dutyGroupId, dutyTypeId: $dutyTypeId, dutyGroupName: $dutyGroupName, configName: $configName)';
  }
}
