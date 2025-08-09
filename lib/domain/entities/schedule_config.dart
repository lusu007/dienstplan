import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule_config.freezed.dart';

@freezed
abstract class ScheduleConfig with _$ScheduleConfig {
  const factory ScheduleConfig({
    required ScheduleMeta meta,
    required List<ScheduleService> services,
    required String version,
  }) = _ScheduleConfig;

  const ScheduleConfig._();
}

@freezed
abstract class ScheduleMeta with _$ScheduleMeta {
  const factory ScheduleMeta({
    required String name,
    required String description,
  }) = _ScheduleMeta;

  const ScheduleMeta._();
}

@freezed
abstract class ScheduleService with _$ScheduleService {
  const factory ScheduleService({
    required String name,
    required List<String> persons,
  }) = _ScheduleService;

  const ScheduleService._();
}
