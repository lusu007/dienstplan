import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/domain/entities/duty_type.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/presentation/state/calendar/calendar_partner_visibility_notifier.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/state/school_holidays/school_holidays_notifier.dart';
import 'package:dienstplan/presentation/state/school_holidays/school_holidays_ui_state.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/calendar_day_schedule_lookup.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/duty_group_fallback.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalendarTableRenderingData {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final String? activeConfigName;

  const CalendarTableRenderingData({
    required this.focusedDay,
    required this.selectedDay,
    required this.activeConfigName,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CalendarTableRenderingData &&
            other.focusedDay == focusedDay &&
            other.selectedDay == selectedDay &&
            other.activeConfigName == activeConfigName;
  }

  @override
  int get hashCode => Object.hash(focusedDay, selectedDay, activeConfigName);
}

class CalendarDayRenderingData {
  final CalendarDayScheduleLookup? scheduleLookup;
  final String? activeConfigName;
  final String? preferredDutyGroup;
  final String? myDutyGroup;
  final String? partnerConfigName;
  final String? partnerDutyGroup;
  final bool isPartnerVisible;
  final int? partnerAccentColorValue;
  final int? myAccentColorValue;
  final int? holidayAccentColorValue;
  final Map<String, DutyType>? activeDutyTypes;
  final List<DutyScheduleConfig> configs;
  final SchoolHolidaysUiState? holidaysState;

  const CalendarDayRenderingData({
    required this.scheduleLookup,
    required this.activeConfigName,
    required this.preferredDutyGroup,
    required this.myDutyGroup,
    required this.partnerConfigName,
    required this.partnerDutyGroup,
    required this.isPartnerVisible,
    required this.partnerAccentColorValue,
    required this.myAccentColorValue,
    required this.holidayAccentColorValue,
    required this.activeDutyTypes,
    required this.configs,
    required this.holidaysState,
  });

  String? get effectivePartnerConfigName {
    return isPartnerVisible ? partnerConfigName : null;
  }

  String? get effectivePartnerGroup {
    return isPartnerVisible ? partnerDutyGroup : null;
  }

  String? get effectiveMyGroup {
    return computeEffectiveMyGroup(
      preferredGroup: preferredDutyGroup,
      myDutyGroup: myDutyGroup,
    );
  }

  Map<String, DutyType>? get partnerDutyTypes {
    final String? partnerName = effectivePartnerConfigName;
    if (partnerName == null || partnerName.isEmpty) {
      return null;
    }
    for (final DutyScheduleConfig config in configs) {
      if (config.name == partnerName) {
        return config.dutyTypes;
      }
    }
    return null;
  }

  int signatureForMonth(DateTime day) {
    return scheduleLookup?.signatureForMonth(day) ?? 0;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CalendarDayRenderingData &&
            other.scheduleLookup == scheduleLookup &&
            other.activeConfigName == activeConfigName &&
            other.preferredDutyGroup == preferredDutyGroup &&
            other.myDutyGroup == myDutyGroup &&
            other.partnerConfigName == partnerConfigName &&
            other.partnerDutyGroup == partnerDutyGroup &&
            other.isPartnerVisible == isPartnerVisible &&
            other.partnerAccentColorValue == partnerAccentColorValue &&
            other.myAccentColorValue == myAccentColorValue &&
            other.holidayAccentColorValue == holidayAccentColorValue &&
            mapEquals(other.activeDutyTypes, activeDutyTypes) &&
            listEquals(other.configs, configs) &&
            other.holidaysState == holidaysState;
  }

  @override
  int get hashCode => Object.hash(
    scheduleLookup,
    activeConfigName,
    preferredDutyGroup,
    myDutyGroup,
    partnerConfigName,
    partnerDutyGroup,
    isPartnerVisible,
    partnerAccentColorValue,
    myAccentColorValue,
    holidayAccentColorValue,
    activeDutyTypes == null
        ? null
        : Object.hashAll(
            activeDutyTypes!.entries.map(
              (entry) => Object.hash(entry.key, entry.value),
            ),
          ),
    Object.hashAll(configs),
    holidaysState,
  );
}

final calendarTableRenderingDataProvider = Provider<CalendarTableRenderingData>(
  (ref) {
    final DateTime now = DateTime.now();
    final DateTime? focusedDay = ref.watch(
      scheduleCoordinatorProvider.select((state) => state.value?.focusedDay),
    );
    final DateTime? selectedDay = ref.watch(
      scheduleCoordinatorProvider.select((state) => state.value?.selectedDay),
    );
    final String? activeConfigName = ref.watch(
      scheduleCoordinatorProvider.select(
        (state) => state.value?.activeConfigName,
      ),
    );

    return CalendarTableRenderingData(
      focusedDay: focusedDay ?? now,
      selectedDay: selectedDay,
      activeConfigName: activeConfigName,
    );
  },
);

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

final calendarDayRenderingDataProvider = Provider<CalendarDayRenderingData>((
  ref,
) {
  final String? myDutyGroup = ref.watch(
    settingsProvider.select((s) => s.value?.myDutyGroup),
  );
  final int? holidayAccentColorValue = ref.watch(
    settingsProvider.select((s) => s.value?.holidayAccentColorValue),
  );
  final CalendarDayScheduleLookup scheduleLookup = ref.watch(
    calendarDayScheduleLookupProvider,
  );

  return CalendarDayRenderingData(
    scheduleLookup: scheduleLookup,
    activeConfigName: ref.watch(
      scheduleCoordinatorProvider.select(
        (state) => state.value?.activeConfigName,
      ),
    ),
    preferredDutyGroup: ref.watch(
      scheduleCoordinatorProvider.select(
        (state) => state.value?.preferredDutyGroup,
      ),
    ),
    myDutyGroup: myDutyGroup,
    partnerConfigName: ref.watch(
      scheduleCoordinatorProvider.select(
        (state) => state.value?.partnerConfigName,
      ),
    ),
    partnerDutyGroup: ref.watch(
      scheduleCoordinatorProvider.select(
        (state) => state.value?.partnerDutyGroup,
      ),
    ),
    isPartnerVisible: ref.watch(calendarPartnerVisibilityProvider),
    partnerAccentColorValue: ref.watch(
      scheduleCoordinatorProvider.select(
        (state) => state.value?.partnerAccentColorValue,
      ),
    ),
    myAccentColorValue: ref.watch(
      scheduleCoordinatorProvider.select(
        (state) => state.value?.myAccentColorValue,
      ),
    ),
    holidayAccentColorValue: holidayAccentColorValue,
    activeDutyTypes: ref.watch(
      scheduleCoordinatorProvider.select(
        (state) => state.value?.activeConfig?.dutyTypes,
      ),
    ),
    configs: ref.watch(
      scheduleCoordinatorProvider.select(
        (state) => state.value?.configs ?? const <DutyScheduleConfig>[],
      ),
    ),
    holidaysState: ref.watch(schoolHolidaysProvider.select((s) => s.value)),
  );
});
