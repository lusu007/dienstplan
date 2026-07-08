import 'package:dienstplan/presentation/widgets/screens/calendar/builders/calendar_day_builders.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/calendar_day_rendering_data.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/memoized_calendar_day.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/date_selector/animated_calendar_day.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('selected builder creates selected calendar day cell', (
    WidgetTester tester,
  ) async {
    const renderingData = CalendarDayRenderingData(
      scheduleLookup: null,
      activeConfigName: null,
      preferredDutyGroup: null,
      myDutyGroup: null,
      partnerConfigName: null,
      partnerDutyGroup: null,
      isPartnerVisible: false,
      partnerAccentColorValue: null,
      myAccentColorValue: null,
      holidayAccentColorValue: null,
      activeDutyTypes: null,
      configs: [],
      holidaysState: null,
    );
    final builders = CalendarDayBuilders.create(
      cellHeight: 48,
      renderingData: renderingData,
      useCompactDutyStripes: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Builder(
            builder: (BuildContext context) {
              return builders.selectedBuilder!(
                context,
                DateTime(2026, 5, 4),
                DateTime(2026, 5, 1),
              )!;
            },
          ),
        ),
      ),
    );

    final widget = tester.widget<MemoizedCalendarDay>(
      find.byType(MemoizedCalendarDay),
    );
    expect(widget.renderingData, same(renderingData));
    expect(widget.day, DateTime(2026, 5, 4));
    expect(widget.dayType, CalendarDayType.selected);
    expect(widget.useCompactDutyStripes, isFalse);
  });

  testWidgets(
    'full calendar can use chips below old compact height threshold',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: AnimatedCalendarDay(
              day: DateTime(2026, 8, 1),
              dayType: CalendarDayType.default_,
              dutyAbbreviation: 'DG',
              height: 94,
              isSelected: false,
              useCompactDutyStripes: false,
            ),
          ),
        ),
      );

      expect(find.text('DG'), findsOneWidget);
    },
  );

  testWidgets('compact calendar uses stripes instead of duty chips', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: AnimatedCalendarDay(
            day: DateTime(2026, 8, 1),
            dayType: CalendarDayType.default_,
            dutyAbbreviation: 'DG',
            height: 120,
            isSelected: false,
            useCompactDutyStripes: true,
          ),
        ),
      ),
    );

    expect(find.text('DG'), findsNothing);
  });
}
