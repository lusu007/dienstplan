class DutyType {
  final String label;
  final String? startTime;
  final String? endTime;
  final bool isAllDay;

  DutyType({
    required this.label,
    this.startTime,
    this.endTime,
    required this.isAllDay,
  });

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      'all_day': isAllDay,
    };
  }

  factory DutyType.fromMap(Map<String, dynamic> map) {
    final allDayValue = map['all_day'];
    final bool isAllDay;

    if (allDayValue is bool) {
      isAllDay = allDayValue;
    } else if (allDayValue is int) {
      isAllDay = allDayValue == 1;
    } else {
      isAllDay = false;
    }

    return DutyType(
      label: map['label'] as String,
      startTime: map['start_time'] as String?,
      endTime: map['end_time'] as String?,
      isAllDay: isAllDay,
    );
  }

  @override
  String toString() {
    return 'DutyType(label: $label, startTime: $startTime, endTime: $endTime, isAllDay: $isAllDay)';
  }
}
