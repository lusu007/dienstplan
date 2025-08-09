import 'package:freezed_annotation/freezed_annotation.dart';

part 'duty_group.freezed.dart';

@freezed
abstract class DutyGroup with _$DutyGroup {
  const factory DutyGroup({
    required String id,
    required String name,
    required String rhythm,
    required double offsetWeeks,
  }) = _DutyGroup;

  const DutyGroup._();
}
