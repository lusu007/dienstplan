import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/domain/entities/duty_type.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/calendar_day_rendering_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CalendarDayRenderingData', () {
    test('disables partner fields when partner visibility is false', () {
      const data = CalendarDayRenderingData(
        activeConfigName: 'main',
        preferredDutyGroup: 'A',
        myDutyGroup: 'A',
        partnerConfigName: 'partner',
        partnerDutyGroup: 'B',
        isPartnerVisible: false,
        partnerAccentColorValue: 0xff0000ff,
        myAccentColorValue: 0xffff0000,
        holidayAccentColorValue: 0xff00ff00,
        activeDutyTypes: <String, DutyType>{},
        configs: <DutyScheduleConfig>[],
        holidaysState: null,
        scheduleLookup: null,
      );

      expect(data.effectivePartnerConfigName, isNull);
      expect(data.effectivePartnerGroup, isNull);
      expect(data.effectiveMyGroup, 'A');
    });

    test('uses configured partner fields when partner visibility is true', () {
      const data = CalendarDayRenderingData(
        activeConfigName: 'main',
        preferredDutyGroup: null,
        myDutyGroup: 'A',
        partnerConfigName: 'partner',
        partnerDutyGroup: 'B',
        isPartnerVisible: true,
        partnerAccentColorValue: null,
        myAccentColorValue: null,
        holidayAccentColorValue: null,
        activeDutyTypes: <String, DutyType>{},
        configs: <DutyScheduleConfig>[],
        holidaysState: null,
        scheduleLookup: null,
      );

      expect(data.effectivePartnerConfigName, 'partner');
      expect(data.effectivePartnerGroup, 'B');
      expect(data.effectiveMyGroup, 'A');
    });
  });
}
