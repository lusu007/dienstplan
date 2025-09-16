// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school_holiday.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SchoolHoliday _$SchoolHolidayFromJson(Map<String, dynamic> json) =>
    SchoolHoliday(
      id: json['id'] as String,
      name: json['name'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      stateCode: json['stateCode'] as String,
      stateName: json['stateName'] as String,
      year: (json['year'] as num).toInt(),
      description: json['description'] as String?,
      type: json['type'] as String?,
    );

Map<String, dynamic> _$SchoolHolidayToJson(SchoolHoliday instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'stateCode': instance.stateCode,
      'stateName': instance.stateName,
      'year': instance.year,
      'description': instance.description,
      'type': instance.type,
    };

SchoolHolidayApiResponse _$SchoolHolidayApiResponseFromJson(
  Map<String, dynamic> json,
) => SchoolHolidayApiResponse(
  status: json['status'] as String,
  data: (json['data'] as List<dynamic>)
      .map((e) => SchoolHoliday.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SchoolHolidayApiResponseToJson(
  SchoolHolidayApiResponse instance,
) => <String, dynamic>{'status': instance.status, 'data': instance.data};
