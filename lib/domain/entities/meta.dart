import 'package:freezed_annotation/freezed_annotation.dart';

part 'meta.freezed.dart';

@freezed
abstract class Meta with _$Meta {
  const factory Meta({
    required String name,
    required String description,
    required DateTime startDate,
    required String startWeekDay,
    required List<String> days,
    String? icon,
  }) = _Meta;

  const Meta._();
}
