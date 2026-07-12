import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/date_selector/animated_calendar_day.dart';
import 'package:dienstplan/core/constants/calendar_config.dart';
import 'package:dienstplan/core/utils/duty_type_display.dart';
import 'package:dienstplan/domain/entities/duty_type.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/calendar_day_schedule_lookup.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/calendar_day_rendering_data.dart';

/// Optimized calendar day widget with memoization and selective provider watching
class MemoizedCalendarDay extends StatelessWidget {
  final DateTime day;
  final CalendarDayType dayType;
  final double? width;
  final double? height;
  final VoidCallback? onDaySelected;
  final CalendarDayRenderingData renderingData;
  final bool useCompactDutyStripes;

  const MemoizedCalendarDay({
    super.key,
    required this.day,
    required this.dayType,
    required this.renderingData,
    this.useCompactDutyStripes = false,
    this.width,
    this.height,
    this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: _MemoizedCalendarDayContent(
        day: day,
        dayType: dayType,
        renderingData: renderingData,
        useCompactDutyStripes: useCompactDutyStripes,
        width: width,
        height: height,
        onDaySelected: onDaySelected,
      ),
    );
  }
}

class _MemoizedCalendarDayContent extends StatelessWidget {
  final DateTime day;
  final CalendarDayType dayType;
  final CalendarDayRenderingData renderingData;
  final bool useCompactDutyStripes;
  final double? width;
  final double? height;
  final VoidCallback? onDaySelected;

  const _MemoizedCalendarDayContent({
    required this.day,
    required this.dayType,
    required this.renderingData,
    required this.useCompactDutyStripes,
    this.width,
    this.height,
    this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final holidaysState = renderingData.holidaysState;
    final hasSchoolHoliday =
        holidaysState?.isEnabled == true &&
        holidaysState?.hasHolidayOnDate(day) == true;
    final holidays = hasSchoolHoliday
        ? holidaysState?.getHolidaysForDate(day) ?? []
        : [];
    final schoolHolidayName = holidays.isNotEmpty ? holidays.first.name : null;

    final CalendarDayScheduleLookup? scheduleLookup =
        renderingData.scheduleLookup;
    final dutyData = scheduleLookup == null
        ? const DutyData(
            myDuty: '',
            partnerDuty: '',
            personalCalendarTitles: <String>[],
          )
        : _MemoizedDutyCalculator.calculateDutyData(
            day: day,
            scheduleLookup: scheduleLookup,
            activeConfigName: renderingData.activeConfigName,
            preferredGroup: renderingData.effectiveMyGroup,
            partnerConfigName: renderingData.effectivePartnerConfigName,
            partnerGroup: renderingData.effectivePartnerGroup,
            activeDutyTypes: renderingData.activeDutyTypes,
            partnerDutyTypes: renderingData.partnerDutyTypes,
          );

    final bool isSelected = dayType == CalendarDayType.selected;

    return AnimatedCalendarDay(
      day: day,
      dutyAbbreviation: dutyData.myDuty,
      partnerDutyAbbreviation: dutyData.partnerDuty,
      personalCalendarTitles: dutyData.personalCalendarTitles,
      partnerAccentColorValue: renderingData.partnerAccentColorValue,
      myAccentColorValue: renderingData.myAccentColorValue,
      holidayAccentColorValue: renderingData.holidayAccentColorValue,
      dayType: dayType,
      width: width ?? CalendarConfig.kCalendarDayWidth,
      height: height ?? CalendarConfig.kCalendarDayHeight,
      isSelected: isSelected,
      useCompactDutyStripes: useCompactDutyStripes,
      onTap: onDaySelected,
      hasSchoolHoliday: hasSchoolHoliday,
      schoolHolidayName: schoolHolidayName,
    );
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
