import 'package:dienstplan/data/models/duty_schedule_config.dart' as data_dsc;
import 'package:dienstplan/domain/entities/duty_schedule_config.dart' as domain;
import 'package:dienstplan/data/models/duty_type.dart' as data_duty;
import 'package:dienstplan/domain/entities/duty_type.dart' as domain_duty;
import 'package:dienstplan/domain/entities/meta.dart' as domain_meta;
import 'package:dienstplan/domain/entities/duty_group.dart' as domain_group;
import 'package:dienstplan/domain/entities/rhythm.dart' as domain_rhythm;

domain.DutyScheduleConfig toDomainConfig(data_dsc.DutyScheduleConfig input) {
  return domain.DutyScheduleConfig(
    version: input.version,
    meta: toDomainMeta(input.meta),
    dutyTypes: input.dutyTypes
        .map((key, value) => MapEntry(key, toDomainDutyType(value))),
    dutyTypeOrder: input.dutyTypeOrder,
    rhythms:
        input.rhythms.map((key, value) => MapEntry(key, toDomainRhythm(value))),
    dutyGroups: input.dutyGroups.map(toDomainDutyGroup).toList(),
  );
}

data_dsc.DutyScheduleConfig toDataConfig(domain.DutyScheduleConfig input) {
  return data_dsc.DutyScheduleConfig(
    version: input.version,
    meta: toDataMeta(input.meta),
    dutyTypes: input.dutyTypes
        .map((key, value) => MapEntry(key, toDataDutyType(value))),
    dutyTypeOrder: input.dutyTypeOrder,
    rhythms:
        input.rhythms.map((key, value) => MapEntry(key, toDataRhythm(value))),
    dutyGroups: input.dutyGroups.map(toDataDutyGroup).toList(),
  );
}

domain_meta.Meta toDomainMeta(data_dsc.Meta input) {
  return domain_meta.Meta(
    name: input.name,
    description: input.description,
    startDate: input.startDate,
    startWeekDay: input.startWeekDay,
    days: input.days,
    icon: input.icon,
    policeAuthority: input.policeAuthority,
  );
}

data_dsc.Meta toDataMeta(domain_meta.Meta input) {
  return data_dsc.Meta(
    name: input.name,
    description: input.description,
    startDate: input.startDate,
    startWeekDay: input.startWeekDay,
    days: input.days,
    icon: input.icon,
    policeAuthority: input.policeAuthority,
  );
}

domain_duty.DutyType toDomainDutyType(data_duty.DutyType input) {
  return domain_duty.DutyType(
    label: input.label,
    isAllDay: input.isAllDay,
    icon: input.icon,
  );
}

data_duty.DutyType toDataDutyType(domain_duty.DutyType input) {
  return data_duty.DutyType(
    label: input.label,
    isAllDay: input.isAllDay,
    icon: input.icon,
  );
}

domain_rhythm.Rhythm toDomainRhythm(data_dsc.Rhythm input) {
  return domain_rhythm.Rhythm(
    lengthWeeks: input.lengthWeeks,
    pattern: input.pattern,
  );
}

data_dsc.Rhythm toDataRhythm(domain_rhythm.Rhythm input) {
  return data_dsc.Rhythm(
    lengthWeeks: input.lengthWeeks,
    pattern: input.pattern,
  );
}

domain_group.DutyGroup toDomainDutyGroup(data_dsc.DutyGroup input) {
  return domain_group.DutyGroup(
    id: input.id,
    name: input.name,
    rhythm: input.rhythm,
    offsetWeeks: input.offsetWeeks,
  );
}

data_dsc.DutyGroup toDataDutyGroup(domain_group.DutyGroup input) {
  return data_dsc.DutyGroup(
    id: input.id,
    name: input.name,
    rhythm: input.rhythm,
    offsetWeeks: input.offsetWeeks,
  );
}
