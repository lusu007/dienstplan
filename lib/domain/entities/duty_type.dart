import 'package:freezed_annotation/freezed_annotation.dart';

part 'duty_type.freezed.dart';

@freezed
abstract class DutyType with _$DutyType {
  const factory DutyType({
    required String label,
    @Default(false) bool isAllDay,
    String? icon,
    String? abbr,
  }) = _DutyType;

  const DutyType._();
}
