import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule.freezed.dart';

@freezed
abstract class Schedule with _$Schedule {
  const factory Schedule({
    required DateTime date,
    required String service,
    required String dutyGroupId,
    required String dutyTypeId,
    required String dutyGroupName,
    required String configName,
    @Default(false) bool isAllDay,
  }) = _Schedule;

  const Schedule._();
}
