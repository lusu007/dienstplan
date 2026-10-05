import 'package:dienstplan/core/constants/calendar_day_surface_tokens.dart';
import 'package:flutter/material.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/date_selector/animated_calendar_day.dart';
import 'package:flutter_test/flutter_test.dart';

double contrast(Color a, Color b) {
  final x = a.computeLuminance(), y = b.computeLuminance();
  return ((x > y ? x : y) + .05) / ((x > y ? y : x) + .05);
}

void main() {
  const colors = <Color>[
    Color(0xFF00B89F),
    Color(0xFFFF7A33),
    Color(0xFF5FBF3A),
    Color(0xFFFFC933),
    Color(0xFFB0BEC5),
    Colors.black,
    Colors.white,
  ];
  for (final color in colors) {
    test('badge text meets small text contrast on $color', () {
      final fg = calendarDayBadgeForegroundColor(color);
      expect(
        contrast(Color.alphaBlend(fg, color), color),
        greaterThanOrEqualTo(4.5),
      );
    });
  }
  test('translucent badge uses its composited background', () {
    const fill = Color(0x708899AA), backdrop = Color(0xFFF8F9FA);
    final bg = Color.alphaBlend(fill, backdrop);
    final fg = calendarDayBadgeForegroundColor(fill, backdropColor: backdrop);
    expect(contrast(fg, bg), greaterThanOrEqualTo(4.5));
  });
  for (final brightness in Brightness.values) {
    testWidgets('outside-month badge uses correct fill in $brightness', (
      tester,
    ) async {
      final theme = ThemeData(brightness: brightness);
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: AnimatedCalendarDay(
                day: DateTime(2026, 9, 30),
                dayType: CalendarDayType.outside,
                isSelected: false,
                partnerDutyAbbreviation: 'P',
                partnerAccentColorValue: 0xFF000000,
                width: 90,
                height: 140,
              ),
            ),
          ),
        ),
      );
      final fg = tester.widget<Text>(find.text('P')).style!.color!;
      if (brightness == Brightness.dark) {
        expect(
          fg,
          Colors.white,
        ); // Exact previously rendered partner foreground.
      } else {
        final bg = Color.alphaBlend(
          calendarDayBadgeOutsideFillColor(theme.colorScheme, brightness),
          theme.colorScheme.surface,
        );
        expect(
          contrast(Color.alphaBlend(fg, bg), bg),
          greaterThanOrEqualTo(4.5),
        );
      }
    });
  }
}
