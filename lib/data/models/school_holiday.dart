import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/school_holiday.dart' as domain;

part 'school_holiday.g.dart';

@JsonSerializable()
class SchoolHoliday {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String stateCode;
  final String stateName;
  final String? description;
  final String? type;

  const SchoolHoliday({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.stateCode,
    required this.stateName,
    this.description,
    this.type,
  });

  factory SchoolHoliday.fromJson(Map<String, dynamic> json) =>
      _$SchoolHolidayFromJson(json);

  Map<String, dynamic> toJson() => _$SchoolHolidayToJson(this);
}

@JsonSerializable()
class SchoolHolidayApiResponse {
  final String status;
  final List<SchoolHoliday> data;

  const SchoolHolidayApiResponse({
    required this.status,
    required this.data,
  });

  factory SchoolHolidayApiResponse.fromJson(Map<String, dynamic> json) =>
      _$SchoolHolidayApiResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SchoolHolidayApiResponseToJson(this);
}