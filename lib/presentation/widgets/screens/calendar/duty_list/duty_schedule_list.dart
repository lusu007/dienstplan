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
import 'package:dienstplan/presentation/widgets/screens/calendar/components/personal_calendar_entry_sheet.dart';
import 'package:dienstplan/core/constants/ui_constants.dart';

/// Visual style for [DutyScheduleList] items.
///
/// [card]: existing opaque material card look (default).
/// [glass]: translucent, softly-bordered surface that lets a blurred
/// background shine through. Used inside the glass schedules dialog.
enum DutyListVisualStyle { card, glass }

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
  final double topPadding;
  final double bottomPadding;
  final DutyListVisualStyle visualStyle;

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
    this.topPadding = 0.0,
    this.bottomPadding = 0.0,
    this.visualStyle = DutyListVisualStyle.card,
  });

  bool get _isGlass => visualStyle == DutyListVisualStyle.glass;

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
      ref: ref,
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
    final List<Schedule> userRows =
        schedules.where((Schedule s) => s.isUserDefined).toList();
    final List<Schedule> officialAll = schedules
        .where((Schedule s) => !s.isUserDefined)
        .toList();
    final List<Schedule> officialFiltered = officialAll
        .where((Schedule schedule) {
          final bool isActiveConfig =
              activeConfigName == null ||
              activeConfigName!.isEmpty ||
              schedule.configName == activeConfigName;
          return isActiveConfig;
        })
        .toList();
    final bool showAllGroups =
        selectedDutyGroup == null || selectedDutyGroup!.isEmpty;
    if (showAllGroups) {
      return <Schedule>[...userRows, ...officialFiltered];
    }
    final List<Schedule> byGroup = officialFiltered
        .where((Schedule s) => s.dutyGroupName == selectedDutyGroup)
        .toList();
    final List<Schedule> officialPart =
        byGroup.isEmpty ? officialFiltered : byGroup;
    final List<Schedule> userPart = userRows
        .where((Schedule s) => s.dutyGroupName == selectedDutyGroup)
        .toList();
    return <Schedule>[...userPart, ...officialPart];
  }

  List<Schedule> _sortSchedules(List<Schedule> input) {
    final List<Schedule> users =
        input.where((Schedule s) => s.isUserDefined).toList();
    final List<Schedule> official =
        input.where((Schedule s) => !s.isUserDefined).toList();
    users.sort((Schedule a, Schedule b) {
      final int as = a.startMinutesFromMidnight ?? -1;
      final int bs = b.startMinutesFromMidnight ?? -1;
      return as.compareTo(bs);
    });
    if (dutyTypeOrder == null || dutyTypeOrder!.isEmpty) {
      return <Schedule>[...users, ...official];
    }
    official.sort((Schedule a, Schedule b) {
      final int aIndex = dutyTypeOrder!.indexOf(a.dutyTypeId);
      final int bIndex = dutyTypeOrder!.indexOf(b.dutyTypeId);
      if (aIndex != -1 && bIndex != -1) {
        return aIndex.compareTo(bIndex);
      }
      if (aIndex != -1) {
        return -1;
      }
      if (bIndex != -1) {
        return 1;
      }
      return a.dutyTypeId.compareTo(b.dutyTypeId);
    });
    return <Schedule>[...users, ...official];
  }

  void _onDutyGroupSelected(String? dutyGroupId) {
    onDutyGroupSelected?.call(dutyGroupId);
  }

  Widget _buildEmptyState(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (!_isGlass) {
      return DutyItemUiBuilder.buildEmptyState(l10n.noServicesForDay);
    }
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_busy_rounded,
              size: 36,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.55),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noServicesForDay,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCombinedList({
    required BuildContext context,
    required WidgetRef ref,
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
      padding: EdgeInsets.fromLTRB(16.0, topPadding, 16.0, bottomPadding),
      itemCount: totalCount,
      itemBuilder: (BuildContext context, int index) {
        if (index < holidaysCount) {
          final SchoolHoliday holiday = holidaysForSelectedDay![index];
          return VacationDayItem(
            holiday: holiday,
            holidayAccentColorValue: holidayAccentColorValue,
            visualStyle: visualStyle,
          );
        }

        final int dutyIndex = index - holidaysCount;
        final Schedule schedule = schedules[dutyIndex];
        final String? personalTimeLabel = schedule.isUserDefined
            ? _personalTimeRightLabel(context, schedule)
            : null;
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
        final bool isPersonal = schedule.isUserDefined;
        final bool isOwn = isPersonal ||
            (myDutyGroupName != null &&
                myDutyGroupName.isNotEmpty &&
                schedule.dutyGroupName == myDutyGroupName);
        final Color baseColor = isPartner
            ? partnerColor
            : (isOwn ? myAccentColor : outlineColor);
        final Color borderColor = isSelected ? primaryColor : baseColor;
        final Color badgeColor = baseColor;
        final bool isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          key: ValueKey<String>(
            '${schedule.date}-${schedule.configName}-${schedule.dutyGroupName}-${schedule.dutyTypeId}-${schedule.service}',
          ),
          margin: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (schedule.isUserDefined) {
                  showPersonalCalendarEntrySheet(
                    context: context,
                    ref: ref,
                    day: schedule.date,
                    existingSchedule: schedule,
                  );
                } else {
                  _onDutyGroupSelected(
                    isSelected ? null : schedule.dutyGroupName,
                  );
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                constraints: const BoxConstraints(minHeight: 72),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: _buildDutyItemDecoration(
                  context: context,
                  isSelected: isSelected,
                  isDark: isDark,
                  borderColor: borderColor,
                  primaryColor: primaryColor,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: _buildIconBadgeDecoration(
                        badgeColor: badgeColor,
                        isDark: isDark,
                      ),
                      child: Icon(
                        DutyItemUiBuilder.iconForSchedule(
                          schedule,
                          dutyTypesMap,
                        ),
                        color: _resolveIconColor(
                          context: context,
                          badgeColor: badgeColor,
                          isDark: isDark,
                        ),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
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
                                if (schedule.isUserDefined &&
                                    _personalNotesLine(schedule) != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      _personalNotesLine(schedule)!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (personalTimeLabel != null &&
                              personalTimeLabel.isNotEmpty) ...<Widget>[
                            const SizedBox(width: 8),
                            Flexible(
                              child: SizedBox(
                                width: double.infinity,
                                child: Text(
                                  personalTimeLabel,
                                  textAlign: TextAlign.end,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ] else ...<Widget>[
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

  BoxDecoration _buildDutyItemDecoration({
    required BuildContext context,
    required bool isSelected,
    required bool isDark,
    required Color borderColor,
    required Color primaryColor,
  }) {
    if (!_isGlass) {
      return BoxDecoration(
        color: isSelected
            ? primaryColor.withAlpha(kAlphaCardSelected)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: isSelected ? 2.5 : 1),
      );
    }
    final Color baseBackground = Colors.white.withValues(
      alpha: isDark ? 0.06 : 0.28,
    );
    final Color selectedBackground = primaryColor.withValues(
      alpha: isDark ? 0.18 : 0.22,
    );
    return BoxDecoration(
      color: isSelected ? selectedBackground : baseBackground,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: isSelected
            ? primaryColor.withValues(alpha: 0.85)
            : borderColor.withValues(alpha: 0.55),
        width: isSelected ? 1.5 : 1,
      ),
      boxShadow: isSelected
          ? [
              BoxShadow(
                color: primaryColor.withValues(alpha: isDark ? 0.32 : 0.28),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ]
          : const [],
    );
  }

  BoxDecoration _buildIconBadgeDecoration({
    required Color badgeColor,
    required bool isDark,
  }) {
    if (!_isGlass) {
      return BoxDecoration(
        color: badgeColor.withAlpha(kAlphaBadge),
        borderRadius: BorderRadius.circular(8),
      );
    }
    return BoxDecoration(
      color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.35),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: badgeColor.withValues(alpha: 0.55), width: 1),
    );
  }

  Color _resolveIconColor({
    required BuildContext context,
    required Color badgeColor,
    required bool isDark,
  }) {
    if (!_isGlass) {
      return isDark ? Theme.of(context).colorScheme.onSurface : badgeColor;
    }
    return isDark ? Colors.white : badgeColor;
  }

  /// Time range or all-day label for the right column (personal entries only).
  String? _personalTimeRightLabel(BuildContext context, Schedule schedule) {
    if (!schedule.isUserDefined) {
      return null;
    }
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (schedule.isAllDay) {
      return l10n.personalEntryAllDayLabel;
    }
    final int? start = schedule.startMinutesFromMidnight;
    final int? end = schedule.endMinutesFromMidnight;
    if (start == null || end == null) {
      return null;
    }
    final TimeOfDay startT = TimeOfDay(hour: start ~/ 60, minute: start % 60);
    final TimeOfDay endT = TimeOfDay(hour: end ~/ 60, minute: end % 60);
    return '${startT.format(context)} – ${endT.format(context)}';
  }

  String? _personalNotesLine(Schedule schedule) {
    if (!schedule.isUserDefined) {
      return null;
    }
    final String? notes = schedule.personalNotes;
    if (notes == null) {
      return null;
    }
    final String trimmed = notes.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  Widget _buildSkeletonLoader(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.0, topPadding, 16.0, bottomPadding),
      itemCount: 5,
      itemExtent: kDutyListItemExtent,
      itemBuilder: (BuildContext context, int index) =>
          _buildSkeletonItem(context),
    );
  }

  Widget _buildSkeletonItem(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    if (!_isGlass) {
      return Container(
        height: kDutyListItemExtent,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: _buildSkeletonRow(context, isGlass: false),
      );
    }
    return _PulsingGlassSkeleton(
      isDark: isDark,
      child: _buildSkeletonRow(context, isGlass: true),
    );
  }

  Widget _buildSkeletonRow(BuildContext context, {required bool isGlass}) {
    final Color barColor = isGlass
        ? Colors.white.withValues(
            alpha: Theme.of(context).brightness == Brightness.dark
                ? 0.12
                : 0.32,
          )
        : Theme.of(context).colorScheme.outlineVariant;
    final Color subBarColor = isGlass
        ? Colors.white.withValues(
            alpha: Theme.of(context).brightness == Brightness.dark
                ? 0.08
                : 0.22,
          )
        : Theme.of(context).colorScheme.surfaceContainerHighest;
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(isGlass ? 10 : 8),
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
                  color: barColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 12,
                width: MediaQuery.of(context).size.width * 0.4,
                decoration: BoxDecoration(
                  color: subBarColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PulsingGlassSkeleton extends StatefulWidget {
  final Widget child;
  final bool isDark;

  const _PulsingGlassSkeleton({required this.child, required this.isDark});

  @override
  State<_PulsingGlassSkeleton> createState() => _PulsingGlassSkeletonState();
}

class _PulsingGlassSkeletonState extends State<_PulsingGlassSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final double t = Curves.easeInOut.transform(_controller.value);
        final double opacity = 0.4 + (0.4 * t);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Opacity(
            opacity: opacity,
            child: Container(
              height: kDutyListItemExtent - 8,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: widget.isDark ? 0.06 : 0.18,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withValues(
                    alpha: widget.isDark ? 0.12 : 0.35,
                  ),
                ),
              ),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}
