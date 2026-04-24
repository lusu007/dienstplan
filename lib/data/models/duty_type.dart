class DutyType {
  final String label;
  final bool isAllDay;
  final String? icon;
  final String? abbr;

  DutyType({required this.label, this.isAllDay = false, this.icon, this.abbr});

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'all_day': isAllDay,
      if (icon != null) 'icon': icon,
      if (abbr != null && abbr!.isNotEmpty) 'abbr': abbr,
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

    final String? abbrFromJson = map['abbr'] as String?;
    final String? abbrFromDb = map['abbreviation'] as String?;
    final String? resolvedAbbr = abbrFromJson ?? abbrFromDb;

    return DutyType(
      label: map['label'] as String,
      isAllDay: isAllDay,
      icon: map['icon'] as String?,
      abbr: resolvedAbbr,
    );
  }

  @override
  String toString() {
    return 'DutyType(label: $label, isAllDay: $isAllDay, icon: $icon, abbr: $abbr)';
  }
}
