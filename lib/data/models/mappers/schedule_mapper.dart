import 'package:dienstplan/data/models/schedule.dart' as data_model;
import 'package:dienstplan/domain/entities/schedule.dart' as domain;

domain.Schedule toDomainSchedule(data_model.Schedule input) {
  return domain.Schedule(
    date: input.date,
    service: input.service,
    dutyGroupId: input.dutyGroupId,
    dutyTypeId: input.dutyTypeId,
    dutyGroupName: input.dutyGroupName,
    configName: input.configName,
    isAllDay: input.isAllDay,
  );
}

data_model.Schedule toDataSchedule(domain.Schedule input) {
  return data_model.Schedule(
    date: input.date,
    service: input.service,
    dutyGroupId: input.dutyGroupId,
    dutyTypeId: input.dutyTypeId,
    dutyGroupName: input.dutyGroupName,
    configName: input.configName,
    isAllDay: input.isAllDay,
  );
}
