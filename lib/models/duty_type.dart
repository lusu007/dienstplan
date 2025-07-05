class DutyType {
  final String label;
  final bool isAllDay;

  DutyType({
    required this.label,
    this.isAllDay = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'label': label,
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
      isAllDay: isAllDay,
    );
  }

  @override
  String toString() {
    return 'DutyType(label: $label, isAllDay: $isAllDay)';
  }
}
