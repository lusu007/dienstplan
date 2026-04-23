import 'package:dienstplan/presentation/widgets/screens/calendar/components/duty_group_fallback.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('computeEffectiveMyGroup', () {
    test('ignores removed selected-duty-group filter state', () {
      expect(
        computeEffectiveMyGroup(preferredGroup: null, myDutyGroup: 'B'),
        'B',
      );
    });
  });
}
