import 'package:flutter/material.dart';
import 'package:dienstplan/core/constants/accent_color_palette.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/domain/entities/duty_type.dart';
import 'package:dienstplan/domain/entities/school_holiday.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';

import 'package:dienstplan/presentation/widgets/screens/calendar/duty_list/duty_item_ui_builder.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/duty_list/vacation_day_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/state/school_holidays/school_holidays_notifier.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/core/constants/ui_constants.dart';

class DutyScheduleList extends ConsumerWidget {
  final List<Schedule> schedules;
  final String? selectedDutyGroup;
  final Function(String?)? onDutyGroupSelected;
  final ScrollController? scrollController;
  final bool shouldAnimate;
  final Map<String, DutyType>? dutyTypes;
  final List<String>? dutyTypeOrder;
  final String? activeConfigName;
  final bool isLoading;
  final DateTime? selectedDay;

  const DutyScheduleList({
    super.key,
    required this.schedules,
    this.selectedDutyGroup,
    this.onDutyGroupSelected,
    this.scrollController,
    this.shouldAnimate = false,
    this.dutyTypes,
    this.dutyTypeOrder,
    this.activeConfigName,
    this.isLoading = false,
    this.selectedDay,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleState = ref.watch(scheduleCoordinatorProvider).value;
    final String? partnerConfigName = scheduleState?.partnerConfigName;
    final int? partnerAccentColorValue = scheduleState?.partnerAccentColorValue;
    final String? partnerDutyGroupName = scheduleState?.partnerDutyGroup;
    final String? myDutyGroupName = scheduleState?.preferredDutyGroup;
    final int? myAccentColorValue = scheduleState?.myAccentColorValue;
    final Map<String, DutyType>? dutyTypesMap =
        scheduleState?.activeConfig?.dutyTypes ?? dutyTypes;

    final holidaysState = ref.watch(
      schoolHolidaysProvider.select((s) => s.value),
    );
    final settingsState = ref.watch(settingsProvider.select((s) => s.value));
    final int? holidayAccentColorValue = settingsState?.holidayAccentColorValue;

    final List<SchoolHoliday>? holidaysForSelectedDay =
        (selectedDay != null && holidaysState?.isEnabled == true)
        ? holidaysState?.getHolidaysForDate(selectedDay!)
        : null;

    if (isLoading) {
      return _buildSkeletonLoader(context);
    }

    final List<Schedule> filteredSchedules = _getFilteredSchedules();
    final List<Schedule> sortedSchedules = _sortSchedules(filteredSchedules);

    final bool hasHolidays =
        holidaysForSelectedDay != null && holidaysForSelectedDay.isNotEmpty;
    final bool hasSchedules = sortedSchedules.isNotEmpty;

    if (!hasHolidays && !hasSchedules) {
      return _buildEmptyState(context);
    }

    return _buildCombinedList(
      context: context,
      schedules: sortedSchedules,
      holidaysForSelectedDay: holidaysForSelectedDay,
      partnerConfigName: partnerConfigName,
      partnerAccentColorValue: partnerAccentColorValue,
      partnerDutyGroupName: partnerDutyGroupName,
      myDutyGroupName: myDutyGroupName,
      myAccentColorValue: myAccentColorValue,
      dutyTypesMap: dutyTypesMap,
      holidayAccentColorValue: holidayAccentColorValue,
    );
  }

  List<Schedule> _getFilteredSchedules() {
    final List<Schedule> base = schedules.where((Schedule schedule) {
      final bool isActiveConfig =
          activeConfigName == null ||
          activeConfigName!.isEmpty ||
          schedule.configName == activeConfigName;
      return isActiveConfig;
    }).toList();

    if (selectedDutyGroup == null || selectedDutyGroup!.isEmpty) {
      return base;
    }

    final List<Schedule> byGroup = base
        .where((Schedule s) => s.dutyGroupName == selectedDutyGroup)
        .toList();
    return byGroup.isEmpty ? base : byGroup;
  }

  List<Schedule> _sortSchedules(List<Schedule> input) {
    if (dutyTypeOrder == null || dutyTypeOrder!.isEmpty) {
      return input;
    }
    return List<Schedule>.from(input)..sort((Schedule a, Schedule b) {
      final int aIndex = dutyTypeOrder!.indexOf(a.dutyTypeId);
      final int bIndex = dutyTypeOrder!.indexOf(b.dutyTypeId);
      if (aIndex != -1 && bIndex != -1) return aIndex.compareTo(bIndex);
      if (aIndex != -1) return -1;
      if (bIndex != -1) return 1;
      return a.dutyTypeId.compareTo(b.dutyTypeId);
    });
  }

  void _onDutyGroupSelected(String? dutyGroupId) {
    onDutyGroupSelected?.call(dutyGroupId);
  }

  Widget _buildEmptyState(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return DutyItemUiBuilder.buildEmptyState(l10n.noServicesForDay);
  }

  Widget _buildCombinedList({
    required BuildContext context,
    required List<Schedule> schedules,
    required List<SchoolHoliday>? holidaysForSelectedDay,
    required String? partnerConfigName,
    required int? partnerAccentColorValue,
    required String? partnerDutyGroupName,
    required String? myDutyGroupName,
    required int? myAccentColorValue,
    required Map<String, DutyType>? dutyTypesMap,
    required int? holidayAccentColorValue,
  }) {
    final int holidaysCount = holidaysForSelectedDay != null
        ? holidaysForSelectedDay.length
        : 0;
    final int dutiesCount = schedules.length;
    final int totalCount = holidaysCount + dutiesCount;

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
      itemCount: totalCount,
      itemExtent: kDutyListItemExtent,
      itemBuilder: (BuildContext context, int index) {
        if (index < holidaysCount) {
          final SchoolHoliday holiday = holidaysForSelectedDay![index];
          return VacationDayItem(
            holiday: holiday,
            holidayAccentColorValue: holidayAccentColorValue,
          );
        }

        final int dutyIndex = index - holidaysCount;
        final Schedule schedule = schedules[dutyIndex];
        final Color partnerColor = Color(
          partnerAccentColorValue ??
              AccentColorDefaults.partnerAccentColorValue,
        );
        final Color myAccentColor = Color(
          myAccentColorValue ?? AccentColorDefaults.myAccentColorValue,
        );

        final bool matchesPartnerConfig =
            (partnerConfigName != null && partnerConfigName.isNotEmpty)
            ? schedule.configName == partnerConfigName
            : (activeConfigName == null ||
                  schedule.configName == activeConfigName);
        final bool matchesPartnerGroup =
            (partnerDutyGroupName != null && partnerDutyGroupName.isNotEmpty)
            ? schedule.dutyGroupName == partnerDutyGroupName
            : false;
        final bool isPartner = matchesPartnerConfig && matchesPartnerGroup;
        final bool isSelected = selectedDutyGroup == schedule.dutyGroupName;
        final Color primaryColor = Theme.of(context).colorScheme.primary;
        final Color outlineColor = Theme.of(context).colorScheme.outlineVariant;
        final bool isOwn =
            (myDutyGroupName != null &&
            myDutyGroupName.isNotEmpty &&
            schedule.dutyGroupName == myDutyGroupName);
        final Color baseColor = isPartner
            ? partnerColor
            : (isOwn ? myAccentColor : outlineColor);
        final Color borderColor = isSelected ? primaryColor : baseColor;
        final Color badgeColor = baseColor;

        return Container(
          key: ValueKey<String>(
            '${schedule.date}-${schedule.configName}-${schedule.dutyGroupName}-${schedule.dutyTypeId}-${schedule.service}',
          ),
          margin: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _onDutyGroupSelected(
                isSelected ? null : schedule.dutyGroupName,
              ),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 72,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primaryColor.withAlpha(kAlphaCardSelected)
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: borderColor,
                    width: isSelected ? 2.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: badgeColor.withAlpha(kAlphaBadge),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getDutyTypeIcon(schedule.dutyTypeId, dutyTypesMap),
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(context).colorScheme.onSurface
                            : badgeColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              schedule.service,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            schedule.dutyGroupName,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getDutyTypeIcon(
    String dutyTypeId,
    Map<String, DutyType>? dutyTypesMap,
  ) {
    return DutyItemUiBuilder.getDutyTypeIcon(dutyTypeId, dutyTypesMap);
  }

  Widget _buildSkeletonLoader(BuildContext context) {
    // Fixed-height skeleton items; no margins to allow itemExtent usage if needed later
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
      itemCount: 5,
      itemExtent: kDutyListItemExtent,
      itemBuilder: (BuildContext context, int index) =>
          _buildSkeletonItem(context),
    );
  }

  Widget _buildSkeletonItem(BuildContext context) {
    return Container(
      height: kDutyListItemExtent,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: MediaQuery.of(context).size.width * 0.4,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
