import 'package:json_annotation/json_annotation.dart';

part 'school_holiday.g.dart';

@JsonSerializable()
class SchoolHoliday {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String stateCode;
  final String stateName;
  final int year;
  final String? description;
  final String? type;

  const SchoolHoliday({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.stateCode,
    required this.stateName,
    required this.year,
    this.description,
    this.type,
  });

  factory SchoolHoliday.fromJson(Map<String, dynamic> json) =>
      _$SchoolHolidayFromJson(json);

  Map<String, dynamic> toJson() => _$SchoolHolidayToJson(this);

  factory SchoolHoliday.fromMap(Map<String, dynamic> map) {
    return SchoolHoliday(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      startDate: DateTime.parse(map['start_date']?.toString() ?? ''),
      endDate: DateTime.parse(map['end_date']?.toString() ?? ''),
      stateCode: map['state_code']?.toString() ?? '',
      stateName: map['state_name']?.toString() ?? '',
      year: map['year'] as int? ?? DateTime.now().year,
      description: map['description']?.toString(),
      type: map['type']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'start_date': startDate.toIso8601String().split(
        'T',
      )[0], // YYYY-MM-DD format
      'end_date': endDate.toIso8601String().split('T')[0], // YYYY-MM-DD format
      'state_code': stateCode,
      'state_name': stateName,
      'year': year,
      'description': description,
      'type': type,
    };
  }
}

@JsonSerializable()
class SchoolHolidayApiResponse {
  final String status;
  final List<SchoolHoliday> data;

  const SchoolHolidayApiResponse({required this.status, required this.data});

  factory SchoolHolidayApiResponse.fromJson(Map<String, dynamic> json) =>
      _$SchoolHolidayApiResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SchoolHolidayApiResponseToJson(this);
}
