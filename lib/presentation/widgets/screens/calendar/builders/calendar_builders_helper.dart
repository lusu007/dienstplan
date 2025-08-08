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
        final isSameDay = schedule.date.year == day.year &&
            schedule.date.month == day.month &&
            schedule.date.day == day.day;

        // Only consider schedules from the active config
        final isActiveConfig = schedule.configName == activeConfigName;

        return isSameDay && isActiveConfig;
      }).toList();

      // Debug for January 2030 specifically
      if (day.year == 2030 && day.month == 1 && day.day <= 5) {
        print('🔍 DEBUG: Filtering schedules for ${day.day}/1/2030');
        print('   📊 Total schedules to filter: ${schedules.length}');
        print('   🎯 ActiveConfig filter: "$activeConfigName"');

        // Show sample of available schedules
        final sampleSchedules = schedules.take(10).toList();
        for (final schedule in sampleSchedules) {
          print(
              '   📅 Sample schedule: ${schedule.date.day}/${schedule.date.month}/${schedule.date.year} - ${schedule.configName}');
        }

        print('   🎯 Found ${schedulesForDay.length} schedules for this day');
        for (final schedule in schedulesForDay) {
          print(
              '   ✅ Matching: ${schedule.date.day}/${schedule.date.month}/${schedule.date.year} - ${schedule.dutyGroupName} - ${schedule.dutyTypeId}');
        }
      }

      // If no schedules found for the active config, return empty string (no chip)
      if (schedulesForDay.isEmpty) {
        return '';
      }

      final preferredGroupName = preferredGroup;

      // Debug log for chip generation
      if (day.day <= 5) {
        // Only log first 5 days to avoid spam
        print(
            '🎯 Day ${day.day}: Found ${schedulesForDay.length} schedules, preferred group: "$preferredGroupName"');
        for (final schedule in schedulesForDay) {
          print(
              '   - Group: "${schedule.dutyGroupName}", Type: "${schedule.dutyTypeId}"');
        }
      }

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
          if (day.day <= 5) {
            print(
                '   → Using preferred group schedule: "${preferredSchedule.dutyTypeId}"');
          }
          return preferredSchedule.dutyTypeId;
        }

        // If preferred group has "-" or empty, check if it's a free day for that group
        try {
          final preferredGroupSchedule = schedulesForDay.firstWhere(
            (s) => s.dutyGroupName == preferredGroupName,
          );
          if (preferredGroupSchedule.dutyTypeId == '-' ||
              preferredGroupSchedule.dutyTypeId.isEmpty) {
            if (day.day <= 5) {
              print('   → Preferred group has free day ("-"), returning empty');
            }
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
          if (day.day <= 5) {
            print(
                '   → No preferred group, using first valid schedule: "${firstSchedule.dutyTypeId}"');
          }
          return firstSchedule.dutyTypeId;
        } catch (e) {
          // If no valid schedule found, return empty string (no chip)
          if (day.day <= 5) {
            print('   → No valid schedules found, returning empty');
          }
          return '';
        }
      }

      // If preferred group is set but has no valid duty, don't show other group's duties
      if (day.day <= 5) {
        print('   → Preferred group set but no valid duty, returning empty');
      }
      return '';
    } catch (e) {
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

    print(
        '🔍 ReactiveCalendarDay building for ${widget.day.day}/${widget.day.month}/${widget.day.year}');
    print('   📊 Total schedules: ${schedules.length}');
    print('   🎯 ActiveConfig: $activeConfig');
    print('   👥 PreferredGroup: $preferredGroup');

    final dutyAbbreviation = CalendarBuildersHelper._getDutyAbbreviationForDate(
      widget.day,
      schedules: schedules,
      activeConfigName: activeConfig,
      preferredGroup: preferredGroup,
    );

    print('   🏷️ Calculated dutyAbbreviation: "$dutyAbbreviation"');

    final isSelected = _isSelected();

    // Use a unique key that includes all relevant state to force rebuild when navigation changes
    final focusedDay = state?.focusedDay;
    final scheduleCount = state?.schedules.length ?? 0;
    final isLoading = state?.isLoading ?? false;
    final key = ValueKey(
        '${widget.day.toIso8601String()}_${dutyAbbreviation}_${focusedDay?.toIso8601String()}_${scheduleCount}_${activeConfig ?? ''}_${preferredGroup ?? ''}_$isLoading');

    try {
      return AnimatedCalendarDay(
        key: key,
        day: widget.day,
        dutyAbbreviation: dutyAbbreviation,
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

            // Animation callback removed
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
