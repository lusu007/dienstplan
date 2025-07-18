import 'package:dienstplan/domain/entities/duty_type.dart';

class DutyScheduleConfig {
  final String version;
  final Meta meta;
  final Map<String, DutyType> dutyTypes;
  final List<String> dutyTypeOrder;
  final Map<String, Rhythm> rhythms;
  final List<DutyGroup> dutyGroups;

  DutyScheduleConfig({
    required this.version,
    required this.meta,
    required this.dutyTypes,
    required this.dutyTypeOrder,
    required this.rhythms,
    required this.dutyGroups,
  });

  String get name => meta.name;
  DateTime get startDate => meta.startDate;

  factory DutyScheduleConfig.fromMap(Map<String, dynamic> map) {
    return DutyScheduleConfig(
      version: map['version'] as String,
      meta: Meta.fromMap(map['meta'] as Map<String, dynamic>),
      dutyTypes: (map['duty_types'] as Map<String, dynamic>).map(
        (key, value) =>
            MapEntry(key, DutyType.fromMap(value as Map<String, dynamic>)),
      ),
      dutyTypeOrder: List<String>.from(map['duty_type_order'] as List),
      rhythms: (map['rhythms'] as Map<String, dynamic>).map(
        (key, value) =>
            MapEntry(key, Rhythm.fromMap(value as Map<String, dynamic>)),
      ),
      dutyGroups: (map['dienstgruppen'] as List<dynamic>)
          .map(
            (x) => DutyGroup.fromMap(x as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'version': version,
      'meta': meta.toMap(),
      'duty_types': dutyTypes.map((key, value) => MapEntry(key, value.toMap())),
      'duty_type_order': dutyTypeOrder,
      'rhythms': rhythms.map((key, value) => MapEntry(key, value.toMap())),
      'dienstgruppen': dutyGroups.map((x) => x.toMap()).toList(),
    };
  }
}

class DutyGroup {
  final String id;
  final String name;
  final String rhythm;
  final double offsetWeeks;

  DutyGroup({
    required this.id,
    required this.name,
    required this.rhythm,
    required this.offsetWeeks,
  });

  factory DutyGroup.fromMap(Map<String, dynamic> map) {
    return DutyGroup(
      id: map['id'] as String,
      name: map['name'] as String,
      rhythm: map['rhythm'] as String,
      offsetWeeks: (map['offset_weeks'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'rhythm': rhythm,
      'offset_weeks': offsetWeeks,
    };
  }
}

class Rhythm {
  final int lengthWeeks;
  final List<List<String>> pattern;

  Rhythm({
    required this.lengthWeeks,
    required this.pattern,
  });

  factory Rhythm.fromMap(Map<String, dynamic> map) {
    return Rhythm(
      lengthWeeks: map['length_weeks'] as int,
      pattern: (map['pattern'] as List)
          .map((week) => List<String>.from(week as List))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'length_weeks': lengthWeeks,
      'pattern': pattern,
    };
  }
}

class Meta {
  final String name;
  final String description;
  final DateTime startDate;
  final String startWeekDay;
  final List<String> days;
  final String? icon;

  Meta({
    required this.name,
    required this.description,
    required this.startDate,
    required this.startWeekDay,
    required this.days,
    this.icon,
  });

  factory Meta.fromMap(Map<String, dynamic> map) {
    return Meta(
      name: map['name'] as String,
      description: map['description'] as String,
      startDate: DateTime.parse(map['start_date'] as String),
      startWeekDay: map['start_week_day'] as String,
      days: List<String>.from(map['days'] as List),
      icon: map['icon'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'start_week_day': startWeekDay,
      'days': days,
      if (icon != null) 'icon': icon,
    };
  }
}
