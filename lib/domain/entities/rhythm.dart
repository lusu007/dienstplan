import 'package:freezed_annotation/freezed_annotation.dart';

part 'rhythm.freezed.dart';

@freezed
abstract class Rhythm with _$Rhythm {
  const factory Rhythm({
    required int lengthWeeks,
    required List<List<String>> pattern,
  }) = _Rhythm;

  const Rhythm._();
}
