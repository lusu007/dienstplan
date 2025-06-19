import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/widgets/calendar/calendar_day_builder.dart';
import 'package:dienstplan/providers/schedule_provider.dart';

class CalendarBuildersHelper {
  static CalendarBuilders createCalendarBuilders(
      ScheduleProvider scheduleProvider) {
    return CalendarBuilders(
      defaultBuilder: (context, day, focusedDay) {
        return _buildCalendarDay(
          context,
          day,
          scheduleProvider,
          CalendarDayType.default_,
        );
      },
      outsideBuilder: (context, day, focusedDay) {
        return _buildCalendarDay(
          context,
          day,
          scheduleProvider,
          CalendarDayType.outside,
        );
      },
      selectedBuilder: (context, day, focusedDay) {
        return _buildCalendarDay(
          context,
          day,
          scheduleProvider,
          CalendarDayType.selected,
          width: 40,
          height: 50,
        );
      },
      todayBuilder: (context, day, focusedDay) {
        return _buildCalendarDay(
          context,
          day,
          scheduleProvider,
          CalendarDayType.today,
          width: 40,
          height: 50,
        );
      },
    );
  }

  static Widget _buildCalendarDay(
    BuildContext context,
    DateTime day,
    ScheduleProvider scheduleProvider,
    CalendarDayType dayType, {
    double? width,
    double? height,
  }) {
    final dutyAbbreviation = scheduleProvider.getDutyAbbreviationForDate(
      day,
      scheduleProvider.preferredDutyGroup,
    );

    return CalendarDayBuilder(
      day: day,
      dutyAbbreviation: dutyAbbreviation,
      dayType: dayType,
      width: width,
      height: height,
    );
  }
}
