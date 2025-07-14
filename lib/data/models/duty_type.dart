class DutyType {
  final String label;
  final bool isAllDay;
  final String? icon;

  DutyType({
    required this.label,
    this.isAllDay = false,
    this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'all_day': isAllDay,
      if (icon != null) 'icon': icon,
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
      icon: map['icon'] as String?,
    );
  }

  @override
  String toString() {
    return 'DutyType(label: $label, isAllDay: $isAllDay, icon: $icon)';
  }
}
