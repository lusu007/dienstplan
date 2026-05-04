import 'package:dienstplan/presentation/widgets/screens/calendar/components/table_calendar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('calendarTableKeyForTesting', () {
    test('is stable for structural calendar inputs', () {
      expect(
        calendarTableKeyForTesting(
          focusedDay: DateTime(2026, 5, 4),
          activeConfigName: 'main',
          localeLanguageCode: 'de',
          rowHeight: 72.04,
        ),
        'cal_2026_5_main_de_rh72.0',
      );
    });
  });
}
