import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart' as tc;
import 'package:dienstplan/presentation/widgets/screens/calendar/components/memoized_calendar_day.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/date_selector/animated_calendar_day.dart';
import 'package:dienstplan/core/constants/calendar_config.dart';

/// Unified calendar builders using MemoizedCalendarDay.
///
/// Selection is handled exclusively by TableCalendar.onDaySelected.
class CalendarDayBuilders {
  static tc.CalendarBuilders create() {
    return tc.CalendarBuilders(
      defaultBuilder:
          (BuildContext context, DateTime day, DateTime focusedDay) {
            return MemoizedCalendarDay(
              key: ValueKey('default_${day.year}-${day.month}-${day.day}'),
              day: day,
              dayType: CalendarDayType.default_,
              width: CalendarConfig.kCalendarDayWidth,
              height: CalendarConfig.kCalendarDayHeight,
            );
          },
      outsideBuilder:
          (BuildContext context, DateTime day, DateTime focusedDay) {
            return MemoizedCalendarDay(
              key: ValueKey('outside_${day.year}-${day.month}-${day.day}'),
              day: day,
              dayType: CalendarDayType.outside,
              width: CalendarConfig.kCalendarDayWidth,
              height: CalendarConfig.kCalendarDayHeight,
            );
          },
      selectedBuilder:
          (BuildContext context, DateTime day, DateTime focusedDay) {
            return MemoizedCalendarDay(
              key: ValueKey('selected_${day.year}-${day.month}-${day.day}'),
              day: day,
              dayType: CalendarDayType.selected,
              width: CalendarConfig.kCalendarDayWidth,
              height: CalendarConfig.kCalendarDayHeight,
            );
          },
      todayBuilder: (BuildContext context, DateTime day, DateTime focusedDay) {
        return MemoizedCalendarDay(
          key: ValueKey('today_${day.year}-${day.month}-${day.day}'),
          day: day,
          dayType: CalendarDayType.today,
          width: CalendarConfig.kCalendarDayWidth,
          height: CalendarConfig.kCalendarDayHeight,
        );
      },
    );
  }
}
