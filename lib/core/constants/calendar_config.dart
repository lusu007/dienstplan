import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/core/constants/ui_constants.dart';

class CalendarConfig {
  static CalendarStyle createCalendarStyle(BuildContext context) {
    return CalendarStyle(
      selectedDecoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        shape: BoxShape.circle,
      ),
      todayDecoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(kAlphaToday),
        shape: BoxShape.circle,
      ),
    );
  }

  static HeaderStyle createHeaderStyle() {
    return const HeaderStyle(
      formatButtonVisible: false,
      titleCentered: true,
      leftChevronVisible: false,
      rightChevronVisible: false,
      titleTextFormatter: null,
      titleTextStyle: TextStyle(fontSize: kHiddenFontSize),
    );
  }

  // Calendar dimensions
  static const double kCalendarHeight = 500.0; // Legacy fallback height
  static const double kCalendarDayHeight = 70.0; // Increased from 60.0 to 70.0
  static const double kCalendarDayWidth = 50.0; // Increased from 45.0 to 50.0
  static const double kDaysOfWeekRowHeight = 32.0;

  /// Vertical padding (top and bottom) inside the fixed-height app title row
  /// ([CalendarHeader]). Must stay in sync with layout there.
  static const double kCalendarTitleRowVerticalPadding = 4.0;

  /// Explicit gap **below** the 48px title row box and **above** the month chip.
  static const double kCalendarHeaderSectionSpacing = 8.0;

  /// Gap below the month chip before the calendar grid. Matches the perceived
  /// space above the chip: [kCalendarHeaderSectionSpacing] plus the title row's
  /// bottom inset so chip-to-grid aligns with insets-to-chip.
  static const double kCalendarMonthPickerToGridSpacing =
      kCalendarHeaderSectionSpacing + kCalendarTitleRowVerticalPadding;

  /// Soft drop shadow under [CalendarHeader] (light mode).
  static const double kCalendarHeaderShadowOpacityLight = 0.055;

  /// Soft drop shadow under [CalendarHeader] (dark mode; slightly stronger).
  static const double kCalendarHeaderShadowOpacityDark = 0.14;

  static const double kCalendarHeaderShadowBlur = 18.0;
  static const double kCalendarHeaderShadowOffsetY = 5.0;

  /// Negative spread keeps the penumbra tight so the header stays airy.
  static const double kCalendarHeaderShadowSpread = -3.0;

  /// When the day cell is at most this tall, the calendar day uses the compact
  /// stripe layout instead of text chips. IME / tight layouts can yield
  /// ~90–100px cell height while still too short for a full chip stack, so this
  /// is above the nominal [kCalendarDayHeight] to avoid [RenderFlex] overflow.
  static const double kCalendarDayCompactDutyStripesMaxHeight = 100.0;

  /// Max height for the month table in split layout (day list below). Kept
  /// low enough that row height yields compact duty stripes like IME/keyboard
  /// shrink, not full chips.
  static const double kSplitLayoutCalendarMaxHeight = 300.0;

  // Compute total month calendar height based on number of week rows.
  // Includes a small padding above rows via the +8 already used for rowHeight.
  static double computeMonthHeight({required int weekRows}) {
    const double row = kCalendarDayHeight + 8;
    return (weekRows * row) + kDaysOfWeekRowHeight;
  }

  static DateTime get firstDay => DateTime.utc(2018, 1, 1);
  static DateTime get lastDay => DateTime.utc(2100, 12, 31);
  static StartingDayOfWeek get startingDayOfWeek => StartingDayOfWeek.monday;
}
