import 'package:dienstplan/core/constants/calendar_config.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/calendar_view/calendar_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('split calendar layout', () {
    test('uses 55 percent of available height below the maximum', () {
      expect(
        computeSplitLayoutCalendarHeightForTesting(availableHeight: 400),
        closeTo(220, 0.0001),
      );
    });

    test('caps calendar height at configured maximum', () {
      expect(
        computeSplitLayoutCalendarHeightForTesting(availableHeight: 800),
        CalendarConfig.kSplitLayoutCalendarMaxHeight,
      );
    });
  });
}
