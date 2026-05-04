import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/date_selector/animated_calendar_day.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/state/school_holidays/school_holidays_notifier.dart';
import 'package:dienstplan/core/constants/calendar_config.dart';
import 'package:dienstplan/core/utils/duty_type_display.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/domain/entities/duty_type.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/presentation/state/calendar/calendar_partner_visibility_notifier.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/calendar_day_schedule_lookup.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/duty_group_fallback.dart';

final calendarDayScheduleLookupProvider = Provider<CalendarDayScheduleLookup>((
  ref,
) {
  final List<Schedule> schedules = ref.watch(
    scheduleCoordinatorProvider.select(
      (state) => state.value?.schedules ?? const <Schedule>[],
    ),
  );
  return CalendarDayScheduleLookup(schedules);
});

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
    final CalendarDayScheduleLookup scheduleLookup = ref.watch(
      calendarDayScheduleLookupProvider,
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
      myDutyGroup: myDutyGroup,
    );

    final Map<String, DutyType>? activeDutyTypes = ref.watch(
      scheduleCoordinatorProvider.select(
        (state) => state.value?.activeConfig?.dutyTypes,
      ),
    );
    final List<DutyScheduleConfig> configs = ref.watch(
      scheduleCoordinatorProvider.select(
        (state) => state.value?.configs ?? const <DutyScheduleConfig>[],
      ),
    );
    Map<String, DutyType>? partnerDutyTypes;
    final String? partnerName = effectivePartnerConfigName;
    if (partnerName != null && partnerName.isNotEmpty) {
      for (final DutyScheduleConfig c in configs) {
        if (c.name == partnerName) {
          partnerDutyTypes = c.dutyTypes;
          break;
        }
      }
    }

    final dutyData = _MemoizedDutyCalculator.calculateDutyData(
      day: day,
      scheduleLookup: scheduleLookup,
      activeConfigName: activeConfig,
      preferredGroup: effectiveMyGroup,
      partnerConfigName: effectivePartnerConfigName,
      partnerGroup: effectivePartnerGroup,
      activeDutyTypes: activeDutyTypes,
      partnerDutyTypes: partnerDutyTypes,
    );

    final isSelected = _isSelected(selectedDay);

    return AnimatedCalendarDay(
      day: day,
      dutyAbbreviation: dutyData.myDuty,
      partnerDutyAbbreviation: dutyData.partnerDuty,
      personalCalendarTitles: dutyData.personalCalendarTitles,
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
  final List<String> personalCalendarTitles;

  const DutyData({
    required this.myDuty,
    required this.partnerDuty,
    required this.personalCalendarTitles,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DutyData &&
        other.myDuty == myDuty &&
        other.partnerDuty == partnerDuty &&
        listEquals(other.personalCalendarTitles, personalCalendarTitles);
  }

  @override
  int get hashCode =>
      Object.hash(myDuty, partnerDuty, Object.hashAll(personalCalendarTitles));
}

/// Memoized duty calculator with caching
class _MemoizedDutyCalculator {
  static final Map<String, DutyData> _cache = {};
  static const int _maxCacheSize = 200;

  /// Increment to clear the in-memory cache when cached results could be stale:
  /// [DutyData] shape/equality changes, cache key inputs or structure changes,
  /// or changes to how duty labels are resolved (e.g. abbreviation rules), so
  /// hot reload or mixed code versions cannot return incompatible entries.
  static const int _kDutyDataCacheSchema = 3;
  static int _appliedDutyDataCacheSchema = 0;

  static DutyData calculateDutyData({
    required DateTime day,
    required CalendarDayScheduleLookup scheduleLookup,
    required String? activeConfigName,
    required String? preferredGroup,
    required String? partnerConfigName,
    required String? partnerGroup,
    required Map<String, DutyType>? activeDutyTypes,
    required Map<String, DutyType>? partnerDutyTypes,
  }) {
    if (_appliedDutyDataCacheSchema != _kDutyDataCacheSchema) {
      _cache.clear();
      _appliedDutyDataCacheSchema = _kDutyDataCacheSchema;
    }

    final int activeAbbrSig = hashDutyTypesAbbreviationSignature(
      activeDutyTypes,
    );
    final int partnerAbbrSig = hashDutyTypesAbbreviationSignature(
      partnerDutyTypes,
    );

    final cacheKey = _createCacheKey(
      day: day,
      activeConfigName: activeConfigName,
      preferredGroup: preferredGroup,
      partnerConfigName: partnerConfigName,
      partnerGroup: partnerGroup,
      schedulesHash: scheduleLookup.signatureForMonth(day),
      activeAbbreviationSignature: activeAbbrSig,
      partnerAbbreviationSignature: partnerAbbrSig,
    );

    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final myDuty = _getDutyAbbreviationForDate(
      day: day,
      scheduleLookup: scheduleLookup,
      activeConfigName: activeConfigName,
      preferredGroup: preferredGroup,
      dutyTypes: activeDutyTypes,
    );

    final partnerDuty = _getPartnerDutyAbbreviationForDate(
      day: day,
      scheduleLookup: scheduleLookup,
      partnerConfigName: partnerConfigName,
      partnerGroup: partnerGroup,
      dutyTypes: partnerDutyTypes,
    );

    final List<String> personalTitles = _personalEntryTitlesOnDay(
      day: day,
      scheduleLookup: scheduleLookup,
    );

    final dutyData = DutyData(
      myDuty: myDuty,
      partnerDuty: partnerDuty,
      personalCalendarTitles: personalTitles,
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
    required int activeAbbreviationSignature,
    required int partnerAbbreviationSignature,
  }) {
    return '${day.year}-${day.month}-${day.day}_'
        '${activeConfigName ?? 'null'}_'
        '${preferredGroup ?? 'null'}_'
        '${partnerConfigName ?? 'null'}_'
        '${partnerGroup ?? 'null'}_'
        '${schedulesHash}_'
        '${activeAbbreviationSignature}_'
        '$partnerAbbreviationSignature';
  }

  static void _cleanCache() {
    final keysToRemove = _cache.keys.take(_cache.length ~/ 2).toList();
    for (final key in keysToRemove) {
      _cache.remove(key);
    }
  }

  static List<String> _personalEntryTitlesOnDay({
    required DateTime day,
    required CalendarDayScheduleLookup scheduleLookup,
  }) {
    return scheduleLookup
        .personalSchedulesForDay(day)
        .map((Schedule s) {
          final String t = s.service.trim();
          return t.isEmpty ? '—' : t;
        })
        .toList(growable: false);
  }

  static String _getDutyAbbreviationForDate({
    required DateTime day,
    required CalendarDayScheduleLookup scheduleLookup,
    required String? activeConfigName,
    required String? preferredGroup,
    required Map<String, DutyType>? dutyTypes,
  }) {
    try {
      if (activeConfigName == null || activeConfigName.isEmpty) {
        return '';
      }

      final preferredGroupName = preferredGroup;

      if (preferredGroupName != null && preferredGroupName.isNotEmpty) {
        final Schedule? preferredSchedule = scheduleLookup
            .firstOfficialSchedule(
              day: day,
              configName: activeConfigName,
              dutyGroupName: preferredGroupName,
              requireDutyType: true,
            );
        if (preferredSchedule != null) {
          return resolveDutyTypeAbbreviation(
            preferredSchedule.dutyTypeId,
            dutyTypes,
          );
        }

        final Schedule? preferredGroupSchedule = scheduleLookup
            .firstOfficialSchedule(
              day: day,
              configName: activeConfigName,
              dutyGroupName: preferredGroupName,
            );
        if (preferredGroupSchedule == null ||
            preferredGroupSchedule.dutyTypeId == '-' ||
            preferredGroupSchedule.dutyTypeId.isEmpty) {
          return '';
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
    required CalendarDayScheduleLookup scheduleLookup,
    required String? partnerConfigName,
    required String? partnerGroup,
    required Map<String, DutyType>? dutyTypes,
  }) {
    try {
      if (partnerConfigName == null || partnerConfigName.isEmpty) {
        return '';
      }
      if (partnerGroup != null && partnerGroup.isNotEmpty) {
        final Schedule? matched = scheduleLookup.firstOfficialSchedule(
          day: day,
          configName: partnerConfigName,
          dutyGroupName: partnerGroup,
          requireDutyType: true,
        );
        if (matched != null) {
          return resolveDutyTypeAbbreviation(matched.dutyTypeId, dutyTypes);
        }

        final Schedule? off = scheduleLookup.firstOfficialSchedule(
          day: day,
          configName: partnerConfigName,
          dutyGroupName: partnerGroup,
        );
        if (off == null || off.dutyTypeId == '-' || off.dutyTypeId.isEmpty) {
          return '';
        }
      }
      return '';
    } catch (_) {
      return '';
    }
  }
}
