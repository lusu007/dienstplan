import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:dienstplan/domain/entities/duty_type.dart';
import 'package:dienstplan/domain/entities/duty_group.dart';
import 'package:dienstplan/domain/entities/rhythm.dart';
import 'package:dienstplan/domain/entities/meta.dart';

part 'duty_schedule_config.freezed.dart';

@freezed
abstract class DutyScheduleConfig with _$DutyScheduleConfig {
  const factory DutyScheduleConfig({
    required String version,
    required Meta meta,
    required Map<String, DutyType> dutyTypes,
    required List<String> dutyTypeOrder,
    required Map<String, Rhythm> rhythms,
    required List<DutyGroup> dutyGroups,
  }) = _DutyScheduleConfig;

  const DutyScheduleConfig._();

  String get name => meta.name;
  DateTime get startDate => meta.startDate;
}
