import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/date_selector/animated_calendar_day.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/state/school_holidays/school_holidays_notifier.dart';
import 'package:dienstplan/core/constants/calendar_config.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';

class CalendarBuildersHelper {
  static CalendarBuilders createCalendarBuilders({
    VoidCallback? onDaySelected,
  }) {
    return CalendarBuilders(
      defaultBuilder: (context, day, focusedDay) {
        return ReactiveCalendarDay(
          day: day,
          dayType: CalendarDayType.default_,
          width: CalendarConfig.kCalendarDayWidth,
          height: CalendarConfig.kCalendarDayHeight,
          onDaySelected: onDaySelected,
        );
      },
      outsideBuilder: (context, day, focusedDay) {
        return ReactiveCalendarDay(
          day: day,
          dayType: CalendarDayType.outside,
          width: CalendarConfig.kCalendarDayWidth,
          height: CalendarConfig.kCalendarDayHeight,
          onDaySelected: onDaySelected,
        );
      },
      selectedBuilder: (context, day, focusedDay) {
        return ReactiveCalendarDay(
          day: day,
          dayType: CalendarDayType.selected,
          width: CalendarConfig.kCalendarDayWidth,
          height: CalendarConfig.kCalendarDayHeight,
          onDaySelected: onDaySelected,
        );
      },
      todayBuilder: (context, day, focusedDay) {
        return ReactiveCalendarDay(
          day: day,
          dayType: CalendarDayType.today,
          width: CalendarConfig.kCalendarDayWidth,
          height: CalendarConfig.kCalendarDayHeight,
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
          schedule.date.year,
          schedule.date.month,
          schedule.date.day,
        );
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

      // If no preferred group is set, don't show any duty chips
      if (preferredGroupName == null || preferredGroupName.isEmpty) {
        return '';
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
          schedule.date.year,
          schedule.date.month,
          schedule.date.day,
        );
        final bool isSameDay = scheduleDate.isAtSameMomentAs(dayDate);
        final bool isPartnerConfig = schedule.configName == partnerConfigName;
        return isSameDay && isPartnerConfig;
      }).toList();
      if (schedulesForDay.isEmpty) {
        return '';
      }
      if (partnerGroup != null && partnerGroup.isNotEmpty) {
        try {
          final Schedule matched = schedulesForDay.firstWhere(
            (s) =>
                s.dutyGroupName == partnerGroup &&
                s.dutyTypeId.isNotEmpty &&
                s.dutyTypeId != '-',
          );
          return matched.dutyTypeId;
        } catch (_) {
          // If partner group exists but is off that day, show nothing
          try {
            final Schedule off = schedulesForDay.firstWhere(
              (s) => s.dutyGroupName == partnerGroup,
            );
            if (off.dutyTypeId == '-' || off.dutyTypeId.isEmpty) {
              return '';
            }
          } catch (_) {}
        }
      }
      // If no partner group specified, don't show any duty chips
      return '';
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
    final state = ref.read(scheduleCoordinatorProvider).value;
    final sel = state?.selectedDay;
    return sel != null &&
        widget.day.year == sel.year &&
        widget.day.month == sel.month &&
        widget.day.day == sel.day;
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider to trigger rebuilds when state changes
    final state = ref.watch(scheduleCoordinatorProvider).value;

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

    // Watch school holidays state
    final holidaysAsyncValue = ref.watch(schoolHolidaysProvider);
    final holidaysState = holidaysAsyncValue.whenData((data) => data).value;

    final hasSchoolHoliday =
        holidaysState?.isEnabled == true &&
        holidaysState?.hasHolidayOnDate(widget.day) == true;
    final holidays = hasSchoolHoliday
        ? holidaysState?.getHolidaysForDate(widget.day) ?? []
        : [];
    final schoolHolidayName = holidays.isNotEmpty ? holidays.first.name : null;

    // Watch holiday accent color directly from settings for instant updates
    final int? holidayAccentColor = ref.watch(
      settingsProvider.select((s) => s.value?.holidayAccentColorValue),
    );

    try {
      return AnimatedCalendarDay(
        day: widget.day,
        dutyAbbreviation: dutyAbbreviation,
        partnerDutyAbbreviation: partnerAbbreviation,
        partnerAccentColorValue: state?.partnerAccentColorValue,
        myAccentColorValue: state?.myAccentColorValue,
        holidayAccentColorValue: holidayAccentColor,
        dayType: widget.dayType,
        width: widget.width,
        height: widget.height,
        isSelected: isSelected,
        hasSchoolHoliday: hasSchoolHoliday,
        schoolHolidayName: schoolHolidayName,
        onTap: () async {
          try {
            // Trigger day selection via provider
            await ref
                .read(scheduleCoordinatorProvider.notifier)
                .setSelectedDay(widget.day);
            ref
                .read(scheduleCoordinatorProvider.notifier)
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
