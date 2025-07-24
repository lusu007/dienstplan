import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/date_selector/animated_calendar_day.dart';
import 'package:dienstplan/presentation/controllers/schedule_controller.dart';
import 'package:dienstplan/domain/entities/schedule.dart';

class CalendarBuildersHelper {
  static CalendarBuilders createCalendarBuilders(
    ScheduleController scheduleController, {
    VoidCallback? onDaySelected,
  }) {
    return CalendarBuilders(
      defaultBuilder: (context, day, focusedDay) {
        return _ReactiveCalendarDay(
          day: day,
          scheduleController: scheduleController,
          dayType: CalendarDayType.default_,
          onDaySelected: onDaySelected,
        );
      },
      outsideBuilder: (context, day, focusedDay) {
        return _ReactiveCalendarDay(
          day: day,
          scheduleController: scheduleController,
          dayType: CalendarDayType.outside,
          onDaySelected: onDaySelected,
        );
      },
      selectedBuilder: (context, day, focusedDay) {
        return _ReactiveCalendarDay(
          day: day,
          scheduleController: scheduleController,
          dayType: CalendarDayType.selected,
          width: 40.0,
          height: 50.0,
          onDaySelected: onDaySelected,
        );
      },
      todayBuilder: (context, day, focusedDay) {
        return _ReactiveCalendarDay(
          day: day,
          scheduleController: scheduleController,
          dayType: CalendarDayType.today,
          width: 40.0,
          height: 50.0,
          onDaySelected: onDaySelected,
        );
      },
    );
  }

  static String _getDutyAbbreviationForDate(
      DateTime day, ScheduleController scheduleController) {
    try {
      // First check if we have an active config
      if (scheduleController.activeConfig == null) {
        return '';
      }

      final activeConfigName = scheduleController.activeConfig!.name;

      // Get schedules for the specific day and active config
      final schedulesForDay = scheduleController.schedules.where((schedule) {
        final isSameDay = schedule.date.year == day.year &&
            schedule.date.month == day.month &&
            schedule.date.day == day.day;

        // Only consider schedules from the active config
        final isActiveConfig = schedule.configName == activeConfigName;

        return isSameDay && isActiveConfig;
      }).toList();

      // If no schedules found for the active config, return empty string
      if (schedulesForDay.isEmpty) {
        return '';
      }

      final preferredGroup = scheduleController.preferredDutyGroup;

      // Only show duty abbreviation if a preferred group is set
      if (preferredGroup != null && preferredGroup.isNotEmpty) {
        Schedule? preferredSchedule;
        try {
          preferredSchedule = schedulesForDay.firstWhere(
            (s) =>
                s.dutyGroupName == preferredGroup &&
                s.dutyTypeId.isNotEmpty &&
                s.dutyTypeId != '-',
          );
        } catch (_) {
          preferredSchedule = null;
        }
        if (preferredSchedule != null) {
          return preferredSchedule.dutyTypeId;
        }
      }

      // If no preferred group is set or no preferred schedule found, show nothing
      return '';
    } catch (e) {
      return '';
    }
  }
}

class _ReactiveCalendarDay extends StatefulWidget {
  final DateTime day;
  final ScheduleController scheduleController;
  final CalendarDayType dayType;
  final double? width;
  final double? height;
  final VoidCallback? onDaySelected;

  const _ReactiveCalendarDay({
    required this.day,
    required this.scheduleController,
    required this.dayType,
    this.width,
    this.height,
    this.onDaySelected,
  });

  @override
  State<_ReactiveCalendarDay> createState() => _ReactiveCalendarDayState();
}

class _ReactiveCalendarDayState extends State<_ReactiveCalendarDay> {
  @override
  void initState() {
    super.initState();
    widget.scheduleController.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.scheduleController.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      // Single rebuild should be sufficient for duty abbreviation updates
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      // Get duty abbreviation for the specific date
      final dutyAbbreviation =
          CalendarBuildersHelper._getDutyAbbreviationForDate(
              widget.day, widget.scheduleController);

      final isSelected = widget.scheduleController.selectedDay != null &&
          widget.day.year == widget.scheduleController.selectedDay!.year &&
          widget.day.month == widget.scheduleController.selectedDay!.month &&
          widget.day.day == widget.scheduleController.selectedDay!.day;

      // Use a unique key that includes the duty abbreviation to force rebuild when it changes
      return AnimatedCalendarDay(
        key: ValueKey('${widget.day.toIso8601String()}_$dutyAbbreviation'),
        day: widget.day,
        dutyAbbreviation: dutyAbbreviation,
        dayType: widget.dayType,
        width: widget.width,
        height: widget.height,
        isSelected: isSelected,
        onTap: () {
          try {
            // Trigger day selection
            widget.scheduleController.setSelectedDay(widget.day);
            widget.scheduleController.setFocusedDay(widget.day);

            // Call the additional callback for animation
            widget.onDaySelected?.call();
          } catch (e) {
            // Ignore errors during day selection
          }
        },
      );
    } catch (e) {
      // Return a simple fallback widget
      return Container(
        width: widget.width ?? 40.0,
        height: widget.height ?? 40.0,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            '${widget.day.day}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      );
    }
  }
}
