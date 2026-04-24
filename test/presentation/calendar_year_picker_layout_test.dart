import 'package:dienstplan/core/constants/calendar_config.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/date_selector/calendar_year_picker_layout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final int minY = CalendarConfig.firstDay.year;
  final int maxY = CalendarConfig.lastDay.year;

  group('calendarYearBlockStartForYear', () {
    test('aligns to minYear for years in first block', () {
      expect(
        calendarYearBlockStartForYear(minYear: minY, maxYear: maxY, year: minY),
        minY,
      );
      expect(
        calendarYearBlockStartForYear(
          minYear: minY,
          maxYear: maxY,
          year: minY + 11,
        ),
        minY,
      );
    });

    test('starts next block at minYear+12', () {
      expect(
        calendarYearBlockStartForYear(
          minYear: minY,
          maxYear: maxY,
          year: minY + 12,
        ),
        minY + 12,
      );
    });

    test('min not multiple of 12: blocks still align to minYear', () {
      const int min = 2019;
      const int max = 2040;
      expect(
        calendarYearBlockStartForYear(minYear: min, maxYear: max, year: 2025),
        2019,
      );
      expect(
        calendarYearBlockStartForYear(minYear: min, maxYear: max, year: 2031),
        2031,
      );
    });

    test('clamps year below range to first block', () {
      expect(
        calendarYearBlockStartForYear(
          minYear: minY,
          maxYear: maxY,
          year: minY - 50,
        ),
        minY,
      );
    });

    test('clamps year above range to block containing maxYear', () {
      expect(
        calendarYearBlockStartForYear(
          minYear: minY,
          maxYear: maxY,
          year: maxY + 10,
        ),
        calendarYearBlockStartForYear(minYear: minY, maxYear: maxY, year: maxY),
      );
    });

    test('min equals max: single block', () {
      const int y = 2024;
      expect(calendarYearBlockStartForYear(minYear: y, maxYear: y, year: y), y);
    });
  });

  group('calendarYearGridPageCount', () {
    test('matches inclusive year span for production config', () {
      final int n = maxY - minY + 1;
      expect(
        calendarYearGridPageCount(minYear: minY, maxYear: maxY),
        (n / 12).ceil(),
      );
    });

    test('single year yields one page', () {
      expect(calendarYearGridPageCount(minYear: 2020, maxYear: 2020), 1);
    });

    test('exactly 24 years yields two pages', () {
      expect(calendarYearGridPageCount(minYear: 2000, maxYear: 2023), 2);
    });
  });

  group('calendarYearPickerPageIndex', () {
    test('first year is page 0', () {
      expect(
        calendarYearPickerPageIndex(minYear: minY, maxYear: maxY, year: minY),
        0,
      );
    });

    test('maxYear maps to last page', () {
      final int last =
          calendarYearGridPageCount(minYear: minY, maxYear: maxY) - 1;
      expect(
        calendarYearPickerPageIndex(minYear: minY, maxYear: maxY, year: maxY),
        last,
      );
    });

    test('year beyond range clamps to last page index', () {
      final int idxMax = calendarYearPickerPageIndex(
        minYear: minY,
        maxYear: maxY,
        year: maxY,
      );
      expect(
        calendarYearPickerPageIndex(
          minYear: minY,
          maxYear: maxY,
          year: maxY + 100,
        ),
        idxMax,
      );
    });
  });

  group('calendarMonthPickerPageIndex', () {
    test('year offset from min', () {
      expect(
        calendarMonthPickerPageIndex(
          minYear: minY,
          maxYear: maxY,
          year: minY + 5,
        ),
        5,
      );
    });

    test('clamps to range', () {
      expect(
        calendarMonthPickerPageIndex(
          minYear: minY,
          maxYear: maxY,
          year: minY - 10,
        ),
        0,
      );
      expect(
        calendarMonthPickerPageIndex(
          minYear: minY,
          maxYear: maxY,
          year: maxY + 10,
        ),
        maxY - minY,
      );
    });
  });
}
