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
        final screenSize = MediaQuery.of(context).size;
        final isLandscape = screenSize.width > screenSize.height;
        return _buildCalendarDay(
          context,
          day,
          scheduleProvider,
          CalendarDayType.selected,
          width: isLandscape ? 35.0 : 40.0,
          height: isLandscape ? 45.0 : 50.0,
        );
      },
      todayBuilder: (context, day, focusedDay) {
        final screenSize = MediaQuery.of(context).size;
        final isLandscape = screenSize.width > screenSize.height;
        return _buildCalendarDay(
          context,
          day,
          scheduleProvider,
          CalendarDayType.today,
          width: isLandscape ? 35.0 : 40.0,
          height: isLandscape ? 45.0 : 50.0,
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
