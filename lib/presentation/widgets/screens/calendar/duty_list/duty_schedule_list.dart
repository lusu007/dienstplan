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

class DutyScheduleList extends ConsumerStatefulWidget {
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
  ConsumerState<DutyScheduleList> createState() => _DutyScheduleListState();
}

class _DutyScheduleListState extends ConsumerState<DutyScheduleList> {
  String? _partnerConfigName;
  int? _partnerAccentColorValue;
  String? _myDutyGroupName;
  String? _partnerDutyGroupName;
  int? _myAccentColorValue;
  Map<String, DutyType>? _dutyTypes;
  List<SchoolHoliday>? _holidaysForSelectedDay;
  int? _holidayAccentColorValue;
  List<Schedule> _getFilteredSchedules() {
    final List<Schedule> base = widget.schedules.where((schedule) {
      final bool isActiveConfig =
          widget.activeConfigName == null ||
          widget.activeConfigName!.isEmpty ||
          schedule.configName == widget.activeConfigName;
      return isActiveConfig;
    }).toList();

    if (widget.selectedDutyGroup == null || widget.selectedDutyGroup!.isEmpty) {
      return base;
    }

    final List<Schedule> byGroup = base
        .where((s) => s.dutyGroupName == widget.selectedDutyGroup)
        .toList();

    // Fallback: if the selected group has no services for this day,
    // show all groups instead of an empty list to avoid a blank UI.
    return byGroup.isEmpty ? base : byGroup;
  }

  List<Schedule> _sortSchedules(List<Schedule> schedules) {
    if (widget.dutyTypeOrder == null || widget.dutyTypeOrder!.isEmpty) {
      return schedules;
    }

    return List.from(schedules)..sort((a, b) {
      final aIndex = widget.dutyTypeOrder!.indexOf(a.dutyTypeId);
      final bIndex = widget.dutyTypeOrder!.indexOf(b.dutyTypeId);

      if (aIndex != -1 && bIndex != -1) {
        return aIndex.compareTo(bIndex);
      }
      if (aIndex != -1) return -1;
      if (bIndex != -1) return 1;
      return a.dutyTypeId.compareTo(b.dutyTypeId);
    });
  }

  void _onDutyGroupSelected(String? dutyGroupId) {
    widget.onDutyGroupSelected?.call(dutyGroupId);
  }

  @override
  Widget build(BuildContext context) {
    // Read partner config and color via Riverpod
    final scheduleState = ref.watch(scheduleCoordinatorProvider).value;
    _partnerConfigName = scheduleState?.partnerConfigName;
    _partnerAccentColorValue = scheduleState?.partnerAccentColorValue;
    _partnerDutyGroupName = scheduleState?.partnerDutyGroup;
    _myDutyGroupName = scheduleState?.preferredDutyGroup;
    _myAccentColorValue = scheduleState?.myAccentColorValue;

    // Convert duty types list to map for easier lookup
    if (scheduleState?.activeConfig != null) {
      _dutyTypes = scheduleState!.activeConfig!.dutyTypes;
    }

    // Get holiday data for the selected day
    final holidaysState = ref.watch(
      schoolHolidaysProvider.select((s) => s.value),
    );

    // Get holiday accent color from settings
    final settingsState = ref.watch(settingsProvider.select((s) => s.value));
    _holidayAccentColorValue = settingsState?.holidayAccentColorValue;

    if (widget.selectedDay != null && holidaysState?.isEnabled == true) {
      _holidaysForSelectedDay = holidaysState?.getHolidaysForDate(
        widget.selectedDay!,
      );
    } else {
      _holidaysForSelectedDay = null;
    }

    if (widget.isLoading) {
      return _buildSkeletonLoader();
    }

    final filteredSchedules = _getFilteredSchedules();
    final sortedSchedules = _sortSchedules(filteredSchedules);

    // Check if we have holidays to show
    final hasHolidays =
        _holidaysForSelectedDay != null && _holidaysForSelectedDay!.isNotEmpty;
    final hasSchedules = sortedSchedules.isNotEmpty;

    if (!hasHolidays && !hasSchedules) {
      return _buildEmptyState();
    }

    return _buildCombinedList(sortedSchedules, hasHolidays);
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context);
    return DutyItemUiBuilder.buildEmptyState(l10n.noServicesForDay);
  }

  Widget _buildCombinedList(List<Schedule> schedules, bool hasHolidays) {
    final int holidaysCount = hasHolidays && _holidaysForSelectedDay != null
        ? _holidaysForSelectedDay!.length
        : 0;
    final int dutiesCount = schedules.length;
    final int totalCount = holidaysCount + dutiesCount;

    return ListView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
      itemCount: totalCount,
      itemBuilder: (context, index) {
        if (index < holidaysCount) {
          final holiday = _holidaysForSelectedDay![index];
          return VacationDayItem(
            holiday: holiday,
            holidayAccentColorValue: _holidayAccentColorValue,
          );
        }
        final int dutyIndex = index - holidaysCount;
        final schedule = schedules[dutyIndex];
        final Color partnerColor = Color(
          _partnerAccentColorValue ??
              AccentColorDefaults.partnerAccentColorValue,
        );
        final Color myAccentColor = Color(
          _myAccentColorValue ?? AccentColorDefaults.myAccentColorValue,
        );
        final bool matchesPartnerConfig =
            (_partnerConfigName != null && _partnerConfigName!.isNotEmpty)
            ? schedule.configName == _partnerConfigName
            : (widget.activeConfigName == null ||
                  schedule.configName == widget.activeConfigName);
        final bool matchesPartnerGroup =
            (_partnerDutyGroupName != null && _partnerDutyGroupName!.isNotEmpty)
            ? schedule.dutyGroupName == _partnerDutyGroupName
            : false;
        final bool isPartner = matchesPartnerConfig && matchesPartnerGroup;
        final bool isSelected =
            widget.selectedDutyGroup == schedule.dutyGroupName;
        final Color primaryColor = Theme.of(context).colorScheme.primary;
        final Color outlineColor = Theme.of(context).colorScheme.outlineVariant;
        final bool isOwn =
            (_myDutyGroupName != null &&
            _myDutyGroupName!.isNotEmpty &&
            schedule.dutyGroupName == _myDutyGroupName);
        final Color baseColor = isPartner
            ? partnerColor
            : (isOwn ? myAccentColor : outlineColor);
        final Color borderColor = isSelected ? primaryColor : baseColor;
        final Color badgeColor = baseColor;

        return Container(
          key: ValueKey(
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
                        _getDutyTypeIcon(schedule.dutyTypeId),
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

  IconData _getDutyTypeIcon(String dutyTypeId) {
    // Use the icon from the duty type configuration if available
    return DutyItemUiBuilder.getDutyTypeIcon(dutyTypeId, _dutyTypes);
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
      itemCount: 5,
      itemBuilder: (context, index) => _buildSkeletonItem(),
    );
  }

  Widget _buildSkeletonItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      height: 72,
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
