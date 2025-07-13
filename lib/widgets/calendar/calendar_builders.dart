import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/widgets/calendar/animated_calendar_day_builder.dart';
import 'package:dienstplan/providers/schedule_provider.dart';

class CalendarBuildersHelper {
  static CalendarBuilders createCalendarBuilders(
    ScheduleProvider scheduleProvider, {
    VoidCallback? onDaySelected,
  }) {
    return CalendarBuilders(
      defaultBuilder: (context, day, focusedDay) {
        return _buildCalendarDay(
          context,
          day,
          scheduleProvider,
          CalendarDayType.default_,
          onDaySelected: onDaySelected,
        );
      },
      outsideBuilder: (context, day, focusedDay) {
        return _buildCalendarDay(
          context,
          day,
          scheduleProvider,
          CalendarDayType.outside,
          onDaySelected: onDaySelected,
        );
      },
      selectedBuilder: (context, day, focusedDay) {
        return _buildCalendarDay(
          context,
          day,
          scheduleProvider,
          CalendarDayType.selected,
          width: 40.0,
          height: 50.0,
          onDaySelected: onDaySelected,
        );
      },
      todayBuilder: (context, day, focusedDay) {
        return _buildCalendarDay(
          context,
          day,
          scheduleProvider,
          CalendarDayType.today,
          width: 40.0,
          height: 50.0,
          onDaySelected: onDaySelected,
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
    VoidCallback? onDaySelected,
  }) {
    final dutyAbbreviation = scheduleProvider.getDutyAbbreviationForDate(
      day,
      scheduleProvider.preferredDutyGroup,
    );

    final isSelected = scheduleProvider.selectedDay != null &&
        day.year == scheduleProvider.selectedDay!.year &&
        day.month == scheduleProvider.selectedDay!.month &&
        day.day == scheduleProvider.selectedDay!.day;

    return AnimatedCalendarDayBuilder(
      day: day,
      dutyAbbreviation: dutyAbbreviation,
      dayType: dayType,
      width: width,
      height: height,
      isSelected: isSelected,
      onTap: () {
        // Trigger day selection
        scheduleProvider.setSelectedDay(day);
        scheduleProvider.setFocusedDay(day);

        // Call the additional callback for animation
        onDaySelected?.call();
      },
    );
  }
}
