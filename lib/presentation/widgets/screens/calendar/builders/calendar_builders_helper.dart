import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/date_selector/animated_calendar_day.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_notifier.dart';

class CalendarBuildersHelper {
  static CalendarBuilders createCalendarBuilders({
    VoidCallback? onDaySelected,
  }) {
    return CalendarBuilders(
      defaultBuilder: (context, day, focusedDay) {
        return ReactiveCalendarDay(
          day: day,
          dayType: CalendarDayType.default_,
          onDaySelected: onDaySelected,
        );
      },
      outsideBuilder: (context, day, focusedDay) {
        return ReactiveCalendarDay(
          day: day,
          dayType: CalendarDayType.outside,
          onDaySelected: onDaySelected,
        );
      },
      selectedBuilder: (context, day, focusedDay) {
        return ReactiveCalendarDay(
          day: day,
          dayType: CalendarDayType.selected,
          width: 40.0,
          height: 50.0,
          onDaySelected: onDaySelected,
        );
      },
      todayBuilder: (context, day, focusedDay) {
        return ReactiveCalendarDay(
          day: day,
          dayType: CalendarDayType.today,
          width: 40.0,
          height: 50.0,
          onDaySelected: onDaySelected,
        );
      },
    );
  }

  static String _getDutyAbbreviationForDate(
    DateTime day, {
    required List<Schedule> schedules,
    required String? activeConfigName,
    required String? preferredGroup,
  }) {
    try {
      if (activeConfigName == null || activeConfigName.isEmpty) {
        return '';
      }

      // Get schedules for the specific day and active config
      final schedulesForDay = schedules.where((schedule) {
        // Normalize dates to avoid timezone issues
        final scheduleDate = DateTime(
            schedule.date.year, schedule.date.month, schedule.date.day);
        final dayDate = DateTime(day.year, day.month, day.day);
        final isSameDay = scheduleDate.isAtSameMomentAs(dayDate);

        // Only consider schedules from the active config
        final isActiveConfig = schedule.configName == activeConfigName;

        return isSameDay && isActiveConfig;
      }).toList();

      // If no schedules found for the active config, return empty string (no chip)
      if (schedulesForDay.isEmpty) {
        return '';
      }

      final preferredGroupName = preferredGroup;

      // Try to show duty abbreviation for preferred group first
      if (preferredGroupName != null && preferredGroupName.isNotEmpty) {
        Schedule? preferredSchedule;
        try {
          preferredSchedule = schedulesForDay.firstWhere(
            (s) =>
                s.dutyGroupName == preferredGroupName &&
                s.dutyTypeId.isNotEmpty &&
                s.dutyTypeId != '-',
          );
        } catch (_) {
          preferredSchedule = null;
        }
        if (preferredSchedule != null) {
          return preferredSchedule.dutyTypeId;
        }

        // If preferred group has "-" or empty, check if it's a free day for that group
        try {
          final preferredGroupSchedule = schedulesForDay.firstWhere(
            (s) => s.dutyGroupName == preferredGroupName,
          );
          if (preferredGroupSchedule.dutyTypeId == '-' ||
              preferredGroupSchedule.dutyTypeId.isEmpty) {
            return ''; // Free day for preferred group - no chip
          }
        } catch (_) {
          // No schedule for preferred group
        }
      }

      // If no preferred group is set or no preferred schedule found,
      // show the first available duty type for this day (only if no preferred group is set)
      if (preferredGroupName == null || preferredGroupName.isEmpty) {
        try {
          final firstSchedule = schedulesForDay.firstWhere(
            (s) => s.dutyTypeId.isNotEmpty && s.dutyTypeId != '-',
          );

          return firstSchedule.dutyTypeId;
        } catch (e) {
          return '';
        }
      }

      return '';
    } catch (e) {
      return '';
    }
  }

  static String _getPartnerDutyAbbreviationForDate(
    DateTime day, {
    required List<Schedule> schedules,
    required String? partnerConfigName,
    required String? partnerGroup,
  }) {
    try {
      if (partnerConfigName == null || partnerConfigName.isEmpty) {
        return '';
      }
      final DateTime dayDate = DateTime(day.year, day.month, day.day);
      final List<Schedule> schedulesForDay = schedules.where((schedule) {
        final scheduleDate = DateTime(
            schedule.date.year, schedule.date.month, schedule.date.day);
        final bool isSameDay = scheduleDate.isAtSameMomentAs(dayDate);
        final bool isPartnerConfig = schedule.configName == partnerConfigName;
        return isSameDay && isPartnerConfig;
      }).toList();
      if (schedulesForDay.isEmpty) {
        return '';
      }
      if (partnerGroup != null && partnerGroup.isNotEmpty) {
        try {
          final Schedule matched = schedulesForDay.firstWhere((s) =>
              s.dutyGroupName == partnerGroup &&
              s.dutyTypeId.isNotEmpty &&
              s.dutyTypeId != '-');
          return matched.dutyTypeId;
        } catch (_) {
          // If partner group exists but is off that day, show nothing
          try {
            final Schedule off = schedulesForDay
                .firstWhere((s) => s.dutyGroupName == partnerGroup);
            if (off.dutyTypeId == '-' || off.dutyTypeId.isEmpty) {
              return '';
            }
          } catch (_) {}
        }
      }
      // If no partner group specified, pick the first non-empty duty
      try {
        final Schedule first = schedulesForDay
            .firstWhere((s) => s.dutyTypeId.isNotEmpty && s.dutyTypeId != '-');
        return first.dutyTypeId;
      } catch (_) {
        return '';
      }
    } catch (_) {
      return '';
    }
  }
}

class ReactiveCalendarDay extends ConsumerStatefulWidget {
  final DateTime day;
  final CalendarDayType dayType;
  final double? width;
  final double? height;
  final VoidCallback? onDaySelected;

  const ReactiveCalendarDay({
    super.key,
    required this.day,
    required this.dayType,
    this.width,
    this.height,
    this.onDaySelected,
  });

  @override
  ConsumerState<ReactiveCalendarDay> createState() =>
      _ReactiveCalendarDayState();
}

class _ReactiveCalendarDayState extends ConsumerState<ReactiveCalendarDay> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool _isSelected() {
    final state = ref.read(scheduleNotifierProvider).valueOrNull;
    final sel = state?.selectedDay;
    return sel != null &&
        widget.day.year == sel.year &&
        widget.day.month == sel.month &&
        widget.day.day == sel.day;
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider to trigger rebuilds when state changes
    final state = ref.watch(scheduleNotifierProvider).valueOrNull;

    // Calculate duty abbreviation directly on each build to ensure it's always current
    final schedules = state?.schedules ?? const [];
    final activeConfig = state?.activeConfigName;
    final preferredGroup = state?.preferredDutyGroup;

    final dutyAbbreviation = CalendarBuildersHelper._getDutyAbbreviationForDate(
      widget.day,
      schedules: schedules,
      activeConfigName: activeConfig,
      preferredGroup: preferredGroup,
    );

    final partnerConfigName = state?.partnerConfigName;
    final partnerGroup = state?.partnerDutyGroup;
    final partnerAbbreviation =
        CalendarBuildersHelper._getPartnerDutyAbbreviationForDate(
      widget.day,
      schedules: schedules,
      partnerConfigName: partnerConfigName,
      partnerGroup: partnerGroup,
    );

    final isSelected = _isSelected();

    try {
      return AnimatedCalendarDay(
        day: widget.day,
        dutyAbbreviation: dutyAbbreviation,
        partnerDutyAbbreviation: partnerAbbreviation,
        partnerAccentColorValue: state?.partnerAccentColorValue,
        myAccentColorValue: state?.myAccentColorValue,
        dayType: widget.dayType,
        width: widget.width,
        height: widget.height,
        isSelected: isSelected,
        onTap: () async {
          try {
            // Trigger day selection via provider
            await ref
                .read(scheduleNotifierProvider.notifier)
                .setSelectedDay(widget.day);
            ref
                .read(scheduleNotifierProvider.notifier)
                .setFocusedDay(widget.day);
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
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            '${widget.day.day}',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
  }
}
