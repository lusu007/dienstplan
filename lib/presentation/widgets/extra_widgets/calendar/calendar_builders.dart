import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/presentation/widgets/extra_widgets/calendar/animated_calendar_day_builder.dart';
import 'package:dienstplan/presentation/controllers/schedule_controller.dart';

class CalendarBuildersHelper {
  static CalendarBuilders createCalendarBuilders(
    ScheduleController scheduleController, {
    VoidCallback? onDaySelected,
  }) {
    return CalendarBuilders(
      defaultBuilder: (context, day, focusedDay) {
        return _buildCalendarDay(
          context,
          day,
          scheduleController,
          CalendarDayType.default_,
          onDaySelected: onDaySelected,
        );
      },
      outsideBuilder: (context, day, focusedDay) {
        return _buildCalendarDay(
          context,
          day,
          scheduleController,
          CalendarDayType.outside,
          onDaySelected: onDaySelected,
        );
      },
      selectedBuilder: (context, day, focusedDay) {
        return _buildCalendarDay(
          context,
          day,
          scheduleController,
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
          scheduleController,
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
    ScheduleController scheduleController,
    CalendarDayType dayType, {
    double? width,
    double? height,
    VoidCallback? onDaySelected,
  }) {
    try {
      // Get duty abbreviation for the specific date
      final dutyAbbreviation =
          _getDutyAbbreviationForDate(day, scheduleController);

      final isSelected = scheduleController.selectedDay != null &&
          day.year == scheduleController.selectedDay!.year &&
          day.month == scheduleController.selectedDay!.month &&
          day.day == scheduleController.selectedDay!.day;

      return AnimatedCalendarDayBuilder(
        day: day,
        dutyAbbreviation: dutyAbbreviation,
        dayType: dayType,
        width: width,
        height: height,
        isSelected: isSelected,
        onTap: () {
          try {
            // Trigger day selection
            scheduleController.setSelectedDay(day);
            scheduleController.setFocusedDay(day);

            // Call the additional callback for animation
            onDaySelected?.call();
          } catch (e, stackTrace) {}
        },
      );
    } catch (e, stackTrace) {
      // Return a simple fallback widget
      return Container(
        width: width ?? 40.0,
        height: height ?? 40.0,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            '${day.day}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      );
    }
  }

  static String _getDutyAbbreviationForDate(
      DateTime day, ScheduleController scheduleController) {
    try {
      // Find schedules for this specific date
      final schedulesForDay = scheduleController.schedules.where((schedule) {
        final isSameDay = schedule.date.year == day.year &&
            schedule.date.month == day.month &&
            schedule.date.day == day.day;
        return isSameDay;
      }).toList();

      if (schedulesForDay.isEmpty) {
        return '';
      }

      // Filter by preferred duty group if set
      final preferredGroup = scheduleController.preferredDutyGroup;
      if (preferredGroup != null && preferredGroup.isNotEmpty) {
        final preferredSchedules = schedulesForDay.where((schedule) {
          return schedule.dutyGroupName == preferredGroup;
        }).toList();

        if (preferredSchedules.isNotEmpty) {
          // Show only the preferred duty group's duty
          final firstPreferredSchedule = preferredSchedules.first;
          final dutyTypeId = firstPreferredSchedule.dutyTypeId;

          // Don't show chip for "no duty" days
          if (dutyTypeId == '-') {
            return '';
          }

          return dutyTypeId;
        }
      }

      // If no preferred group or no schedules for preferred group, show all duties
      if (schedulesForDay.length > 1) {
        final abbreviations = schedulesForDay
            .map((schedule) => schedule.dutyTypeId)
            .where((dutyTypeId) =>
                dutyTypeId.isNotEmpty &&
                dutyTypeId != '-') // Filter out "no duty"
            .toList();

        if (abbreviations.isEmpty) {
          return '';
        }

        final result = abbreviations.join('/');
        return result;
      }

      // Single schedule
      final firstSchedule = schedulesForDay.first;
      final dutyTypeId = firstSchedule.dutyTypeId;

      // Don't show chip for "no duty" days
      if (dutyTypeId == '-') {
        return '';
      }

      return dutyTypeId;
    } catch (e, stackTrace) {
      return ''; // Return empty string on error
    }
  }
}
