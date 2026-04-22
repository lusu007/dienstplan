import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/date_selector/animated_calendar_day.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/state/school_holidays/school_holidays_notifier.dart';
import 'package:dienstplan/core/constants/calendar_config.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/presentation/state/calendar/calendar_partner_visibility_notifier.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/duty_group_fallback.dart';

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

    final selectedGroup = ref.watch(
      scheduleCoordinatorProvider.select(
        (state) => state.value?.selectedDutyGroup,
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

    // View-only visibility override: hiding the partner in the calendar
    // must not mutate the persisted partner configuration.
    final bool partnerVisible = ref.watch(calendarPartnerVisibilityProvider);
    final String? effectivePartnerConfigName = partnerVisible
        ? partnerConfigName
        : null;
    final String? effectivePartnerGroup = partnerVisible ? partnerGroup : null;

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

    final holidayAccentColor = ref.watch(
      settingsProvider.select((s) => s.value?.holidayAccentColorValue),
    );

    final myDutyGroup = ref.watch(
      settingsProvider.select((s) => s.value?.myDutyGroup),
    );

    final holidaysAsyncValue = ref.watch(schoolHolidaysProvider);
    final holidaysState = holidaysAsyncValue.whenData((data) => data).value;

    final hasSchoolHoliday =
        holidaysState?.isEnabled == true &&
        holidaysState?.hasHolidayOnDate(day) == true;
    final holidays = hasSchoolHoliday
        ? holidaysState?.getHolidaysForDate(day) ?? []
        : [];
    final schoolHolidayName = holidays.isNotEmpty ? holidays.first.name : null;

    final String? effectiveMyGroup = computeEffectiveMyGroup(
      preferredGroup: preferredGroup,
      selectedGroup: selectedGroup,
      myDutyGroup: myDutyGroup,
    );
    final dutyData = _MemoizedDutyCalculator.calculateDutyData(
      day: day,
      schedules: schedules,
      activeConfigName: activeConfig,
      preferredGroup: effectiveMyGroup,
      partnerConfigName: effectivePartnerConfigName,
      partnerGroup: effectivePartnerGroup,
    );

    final isSelected = _isSelected(selectedDay);

    return AnimatedCalendarDay(
      day: day,
      dutyAbbreviation: dutyData.myDuty,
      partnerDutyAbbreviation: dutyData.partnerDuty,
      hasPersonalCalendarEntry: dutyData.hasPersonalEntry,
      partnerAccentColorValue: partnerAccentColor,
      myAccentColorValue: myAccentColor,
      holidayAccentColorValue: holidayAccentColor,
      dayType: dayType,
      width: width ?? CalendarConfig.kCalendarDayWidth,
      height: height ?? CalendarConfig.kCalendarDayHeight,
      isSelected: isSelected,
      hasSchoolHoliday: hasSchoolHoliday,
      schoolHolidayName: schoolHolidayName,
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
  final bool hasPersonalEntry;

  const DutyData({
    required this.myDuty,
    required this.partnerDuty,
    required this.hasPersonalEntry,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DutyData &&
        other.myDuty == myDuty &&
        other.partnerDuty == partnerDuty &&
        other.hasPersonalEntry == hasPersonalEntry;
  }

  @override
  int get hashCode => Object.hash(myDuty, partnerDuty, hasPersonalEntry);
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
    final cacheKey = _createCacheKey(
      day: day,
      activeConfigName: activeConfigName,
      preferredGroup: preferredGroup,
      partnerConfigName: partnerConfigName,
      partnerGroup: partnerGroup,
      schedulesHash: _getSchedulesHash(schedules, day),
    );

    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

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

    final bool hasPersonal = _hasPersonalEntryOnDay(day: day, schedules: schedules);

    final dutyData = DutyData(
      myDuty: myDuty,
      partnerDuty: partnerDuty,
      hasPersonalEntry: hasPersonal,
    );

    _cache[cacheKey] = dutyData;

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
    final int monthMarker = day.year * 100 + day.month;

    final relevantSchedules = schedules.where((schedule) {
      final scheduleDate = schedule.date;
      return scheduleDate.year == day.year && scheduleDate.month == day.month;
    }).toList();

    // Create a content-based hash that includes key schedule properties
    // This ensures cache invalidation when schedule content changes
    final int contentHash = relevantSchedules.fold<int>(0, (
      int hash,
      Schedule schedule,
    ) {
      return hash ^
          Object.hash(
            schedule.date.day,
            schedule.dutyTypeId,
            schedule.dutyGroupName,
            schedule.configName,
            schedule.service,
            schedule.isUserDefined,
            schedule.personalEntryId,
          );
    });

    return Object.hash(monthMarker, schedules.length, contentHash);
  }

  static void _cleanCache() {
    final keysToRemove = _cache.keys.take(_cache.length ~/ 2).toList();
    for (final key in keysToRemove) {
      _cache.remove(key);
    }
  }

  static bool _hasPersonalEntryOnDay({
    required DateTime day,
    required List<Schedule> schedules,
  }) {
    final DateTime dayDate = DateTime(day.year, day.month, day.day);
    for (final Schedule schedule in schedules) {
      if (!schedule.isUserDefined) {
        continue;
      }
      final DateTime scheduleDate = DateTime(
        schedule.date.year,
        schedule.date.month,
        schedule.date.day,
      );
      if (scheduleDate.isAtSameMomentAs(dayDate)) {
        return true;
      }
    }
    return false;
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

      final schedulesForDay = schedules.where((schedule) {
        final scheduleDate = DateTime(
          schedule.date.year,
          schedule.date.month,
          schedule.date.day,
        );
        final dayDate = DateTime(day.year, day.month, day.day);
        final isSameDay = scheduleDate.isAtSameMomentAs(dayDate);
        final isActiveConfig = schedule.configName == activeConfigName;

        return isSameDay && isActiveConfig;
      }).toList();

      if (schedulesForDay.isEmpty) {
        return '';
      }

      final preferredGroupName = preferredGroup;

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

        try {
          final preferredGroupSchedule = schedulesForDay.firstWhere(
            (s) => s.dutyGroupName == preferredGroupName,
          );
          if (preferredGroupSchedule.dutyTypeId == '-' ||
              preferredGroupSchedule.dutyTypeId.isEmpty) {
            return '';
          }
        } catch (_) {
          // No schedule for preferred group
        }
      }

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
      return '';
    } catch (_) {
      return '';
    }
  }
}
