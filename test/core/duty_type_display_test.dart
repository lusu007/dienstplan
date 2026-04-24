import 'package:dienstplan/core/utils/duty_type_display.dart';
import 'package:dienstplan/domain/entities/duty_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveDutyTypeAbbreviation', () {
    test('returns dutyTypeId when map is null', () {
      expect(resolveDutyTypeAbbreviation('F', null), 'F');
    });

    test('returns dutyTypeId when abbr is missing', () {
      final Map<String, DutyType> types = <String, DutyType>{
        'F': const DutyType(label: 'Frühdienst'),
      };
      expect(resolveDutyTypeAbbreviation('F', types), 'F');
    });

    test('returns abbr when set', () {
      final Map<String, DutyType> types = <String, DutyType>{
        'F': const DutyType(label: 'Frühdienst', abbr: 'Früh'),
      };
      expect(resolveDutyTypeAbbreviation('F', types), 'Früh');
    });

    test('preserves off marker', () {
      expect(resolveDutyTypeAbbreviation('-', <String, DutyType>{}), '-');
    });
  });

  group('hashDutyTypesAbbreviationSignature', () {
    test('changes when abbr changes', () {
      final Map<String, DutyType> a = <String, DutyType>{
        'F': const DutyType(label: 'x', abbr: 'Früh'),
      };
      final Map<String, DutyType> b = <String, DutyType>{
        'F': const DutyType(label: 'x', abbr: 'F'),
      };
      expect(
        hashDutyTypesAbbreviationSignature(a) ==
            hashDutyTypesAbbreviationSignature(b),
        false,
      );
    });
  });
}
