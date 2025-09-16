import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/date_selector/animated_calendar_day.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/state/school_holidays/school_holidays_notifier.dart';
import 'package:dienstplan/core/constants/calendar_config.dart';
import 'package:dienstplan/domain/entities/schedule.dart';

/// Optimized calendar day widget with memoization and selective provider watching
class MemoizedCalendarDay extends ConsumerWidget {
  final DateTime day;
  final CalendarDayType dayType;
  final double? width;
  final double? height;
  final VoidCallback? onDaySelected;

  const MemoizedCalendarDay({
    super.key,
    required this.day,
    required this.dayType,
    this.width,
    this.height,
    this.onDaySelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RepaintBoundary(
      child: _MemoizedCalendarDayContent(
        day: day,
        dayType: dayType,
        width: width,
        height: height,
        onDaySelected: onDaySelected,
      ),
    );
  }
}

class _MemoizedCalendarDayContent extends ConsumerWidget {
  final DateTime day;
  final CalendarDayType dayType;
  final double? width;
  final double? height;
  final VoidCallback? onDaySelected;

  const _MemoizedCalendarDayContent({
    required this.day,
    required this.dayType,
    this.width,
    this.height,
    this.onDaySelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Selective provider watching - only watch specific parts of the state
    final schedules = ref.watch(
      scheduleCoordinatorProvider.select(
        (state) => state.value?.schedules ?? const <Schedule>[],
      ),
    );

    final activeConfig = ref.watch(
      scheduleCoordinatorProvider.select(
        (state) => state.value?.activeConfigName,
      ),
    );

    final preferredGroup = ref.watch(
      scheduleCoordinatorProvider.select(
        (state) => state.value?.preferredDutyGroup,
      ),
    );

    final partnerConfigName = ref.watch(
      scheduleCoordinatorProvider.select(
        (state) => state.value?.partnerConfigName,
      ),
    );

    final partnerGroup = ref.watch(
      scheduleCoordinatorProvider.select(
        (state) => state.value?.partnerDutyGroup,
      ),
    );

    final selectedDay = ref.watch(
      scheduleCoordinatorProvider.select((state) => state.value?.selectedDay),
    );

    final partnerAccentColor = ref.watch(
      scheduleCoordinatorProvider.select(
        (state) => state.value?.partnerAccentColorValue,
      ),
    );

    final myAccentColor = ref.watch(
      scheduleCoordinatorProvider.select(
        (state) => state.value?.myAccentColorValue,
      ),
    );

    // Watch school holidays state
    final holidaysAsyncValue = ref.watch(schoolHolidaysProvider);
    final holidaysState = holidaysAsyncValue.whenData((data) => data).value;

    final hasSchoolHoliday =
        holidaysState?.isEnabled == true &&
        holidaysState?.hasHolidayOnDate(day) == true;
    final holidays = hasSchoolHoliday
        ? holidaysState?.getHolidaysForDate(day) ?? []
        : [];
    final schoolHolidayName = holidays.isNotEmpty ? holidays.first.name : null;

    // Memoized duty calculations
    final dutyData = _MemoizedDutyCalculator.calculateDutyData(
      day: day,
      schedules: schedules,
      activeConfigName: activeConfig,
      preferredGroup: preferredGroup,
      partnerConfigName: partnerConfigName,
      partnerGroup: partnerGroup,
    );

    final isSelected = _isSelected(selectedDay);

    return AnimatedCalendarDay(
      day: day,
      dutyAbbreviation: dutyData.myDuty,
      partnerDutyAbbreviation: dutyData.partnerDuty,
      partnerAccentColorValue: partnerAccentColor,
      myAccentColorValue: myAccentColor,
      dayType: dayType,
      width: width ?? CalendarConfig.kCalendarDayWidth,
      height: height ?? CalendarConfig.kCalendarDayHeight,
      isSelected: isSelected,
      hasSchoolHoliday: hasSchoolHoliday,
      schoolHolidayName: schoolHolidayName,
      onTap: () async {
        try {
          // Trigger day selection via provider
          await ref
              .read(scheduleCoordinatorProvider.notifier)
              .setSelectedDay(day);
          ref.read(scheduleCoordinatorProvider.notifier).setFocusedDay(day);
        } catch (e) {
          // Ignore errors during day selection
        }
      },
    );
  }

  bool _isSelected(DateTime? selectedDay) {
    if (selectedDay == null) return false;
    return day.year == selectedDay.year &&
        day.month == selectedDay.month &&
        day.day == selectedDay.day;
  }
}

/// Memoized duty calculation data class
class DutyData {
  final String myDuty;
  final String partnerDuty;

  const DutyData({required this.myDuty, required this.partnerDuty});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DutyData &&
        other.myDuty == myDuty &&
        other.partnerDuty == partnerDuty;
  }

  @override
  int get hashCode => Object.hash(myDuty, partnerDuty);
}

/// Memoized duty calculator with caching
class _MemoizedDutyCalculator {
  static final Map<String, DutyData> _cache = {};
  static const int _maxCacheSize = 200;

  static DutyData calculateDutyData({
    required DateTime day,
    required List<Schedule> schedules,
    required String? activeConfigName,
    required String? preferredGroup,
    required String? partnerConfigName,
    required String? partnerGroup,
  }) {
    // Create cache key based on relevant parameters
    final cacheKey = _createCacheKey(
      day: day,
      activeConfigName: activeConfigName,
      preferredGroup: preferredGroup,
      partnerConfigName: partnerConfigName,
      partnerGroup: partnerGroup,
      schedulesHash: _getSchedulesHash(schedules, day),
    );

    // Check cache first
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    // Calculate duty data
    final myDuty = _getDutyAbbreviationForDate(
      day: day,
      schedules: schedules,
      activeConfigName: activeConfigName,
      preferredGroup: preferredGroup,
    );

    final partnerDuty = _getPartnerDutyAbbreviationForDate(
      day: day,
      schedules: schedules,
      partnerConfigName: partnerConfigName,
      partnerGroup: partnerGroup,
    );

    final dutyData = DutyData(myDuty: myDuty, partnerDuty: partnerDuty);

    // Cache the result
    _cache[cacheKey] = dutyData;

    // Clean cache if it gets too large
    if (_cache.length > _maxCacheSize) {
      _cleanCache();
    }

    return dutyData;
  }

  static String _createCacheKey({
    required DateTime day,
    required String? activeConfigName,
    required String? preferredGroup,
    required String? partnerConfigName,
    required String? partnerGroup,
    required int schedulesHash,
  }) {
    return '${day.year}-${day.month}-${day.day}_'
        '${activeConfigName ?? 'null'}_'
        '${preferredGroup ?? 'null'}_'
        '${partnerConfigName ?? 'null'}_'
        '${partnerGroup ?? 'null'}_'
        '$schedulesHash';
  }

  static int _getSchedulesHash(List<Schedule> schedules, DateTime day) {
    // Only hash schedules for the current month to avoid cache misses
    final monthStart = DateTime(day.year, day.month, 1);
    final monthEnd = DateTime(day.year, day.month + 1, 0);

    final relevantSchedules = schedules
        .where(
          (schedule) =>
              schedule.date.isAfter(
                monthStart.subtract(const Duration(days: 1)),
              ) &&
              schedule.date.isBefore(monthEnd.add(const Duration(days: 1))),
        )
        .toList();

    return relevantSchedules
        .map(
          (s) =>
              '${s.date.year}-${s.date.month}-${s.date.day}|${s.configName}|${s.dutyGroupName}|${s.dutyTypeId}',
        )
        .join(';')
        .hashCode;
  }

  static void _cleanCache() {
    // Remove oldest 50% of cache entries
    final keysToRemove = _cache.keys.take(_cache.length ~/ 2).toList();
    for (final key in keysToRemove) {
      _cache.remove(key);
    }
  }

  static String _getDutyAbbreviationForDate({
    required DateTime day,
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

  static String _getPartnerDutyAbbreviationForDate({
    required DateTime day,
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
