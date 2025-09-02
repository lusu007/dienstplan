import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_notifier.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/duty_list/duty_schedule_list.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/builders/calendar_builders_helper.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/date_selector/animated_calendar_day.dart';
import 'package:dienstplan/core/constants/calendar_config.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/duty_list/duty_schedule_header.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/date_selector/calendar_date_selector_header.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/draggable_sheet_container.dart';

import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/domain/entities/schedule.dart';

class CalendarViewUiBuilder {
  static Widget buildCalendarHeader({
    required BuildContext context,
    required GlobalKey headerKey,
    required VoidCallback onLeftChevronTap,
    required VoidCallback onRightChevronTap,
    required Function(DateTime) onDateSelected,
    VoidCallback? onTodayButtonPressed,
  }) {
    return CalendarDateSelectorHeader(
      key: headerKey,
      onLeftChevronTap: onLeftChevronTap,
      onRightChevronTap: onRightChevronTap,
      locale: Localizations.localeOf(context),
      onDateSelected: onDateSelected,
      onTodayButtonPressed: onTodayButtonPressed,
    );
  }

  static Widget buildTableCalendar({
    required BuildContext context,
    required GlobalKey calendarKey,
    required Function(CalendarFormat) onFormatChanged,
    required Function(DateTime) onPageChanged,
    required VoidCallback onDaySelected,
  }) {
    return _TableCalendarWrapper(
      calendarKey: calendarKey,
      onFormatChanged: onFormatChanged,
      onPageChanged: onPageChanged,
      onDaySelected: onDaySelected,
    );
  }

  static Widget buildSheetContainer({
    required BuildContext context,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: child,
    );
  }

  static Widget buildDraggableSheetContainer({
    required BuildContext context,
    required Widget child,
    double initialHeight = 300.0,
    double minHeight = 150.0,
    double maxHeight = 600.0,
    List<double>? snapPoints,
    VoidCallback? onHeightChanged,
  }) {
    return DraggableSheetContainer(
      initialHeight: initialHeight,
      minHeight: minHeight,
      maxHeight: maxHeight,
      snapPoints: snapPoints,
      onHeightChanged: onHeightChanged,
      child: child,
    );
  }

  static Widget buildServicesSection({
    required DateTime? selectedDay,
  }) {
    return Builder(
      builder: (context) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: DutyScheduleHeader(selectedDay: selectedDay),
        );
      },
    );
  }

  static Widget buildDutyScheduleList({
    required BuildContext context,
    bool shouldAnimate = false,
  }) {
    return Consumer(builder: (context, ref, __) {
      final asyncState = ref.watch(scheduleNotifierProvider);
      final state = asyncState.value;
      final String? selectedGroup = state?.selectedDutyGroup;

      // Filter schedules for selected day
      final selectedDaySchedules = (state?.schedules ?? const []).where((s) {
        final sel = state?.selectedDay;
        if (sel == null) return false;

        // Normalize dates to avoid timezone issues
        final scheduleDate = DateTime(s.date.year, s.date.month, s.date.day);
        final selectedDate = DateTime(sel.year, sel.month, sel.day);

        // Also ensure we're using the correct config
        final activeConfig = state?.activeConfigName;
        final isCorrectConfig =
            activeConfig == null || s.configName == activeConfig;

        return scheduleDate.isAtSameMomentAs(selectedDate) && isCorrectConfig;
      }).toList();

      // Only show loading if selected day has no schedules AND we're actually loading
      final hasSchedulesForSelectedDay = selectedDaySchedules.isNotEmpty;
      final isLoadingSelectedDay =
          (state?.isLoading ?? false) && !hasSchedulesForSelectedDay;

      // Trigger data loading if we have no schedules for selected day and not currently loading
      if (!hasSchedulesForSelectedDay &&
          !isLoadingSelectedDay &&
          state?.selectedDay != null &&
          state?.activeConfigName != null) {
        // Use post-frame callback to avoid building during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            ref
                .read(scheduleNotifierProvider.notifier)
                .setSelectedDay(state!.selectedDay);
          }
        });
      }

      return DutyScheduleList(
        schedules: selectedDaySchedules,
        selectedDutyGroup: selectedGroup,
        activeConfigName: state?.activeConfigName,
        dutyTypeOrder: state?.activeConfig?.dutyTypeOrder,
        dutyTypes: state?.activeConfig?.dutyTypes,
        onDutyGroupSelected: (group) {
          ref
              .read(scheduleNotifierProvider.notifier)
              .setSelectedDutyGroup(group);
        },
        shouldAnimate: shouldAnimate,
        isLoading: isLoadingSelectedDay,
      );
    });
  }

  static Widget buildFilterStatusText({
    required BuildContext context,
  }) {
    final l10n = AppLocalizations.of(context);
    return Consumer(builder: (context, ref, __) {
      final state = ref.watch(scheduleNotifierProvider).value;
      final filterText = (state?.selectedDutyGroup ?? '').isNotEmpty
          ? state!.selectedDutyGroup!
          : l10n.all;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Text(
          '${l10n.filteredBy}: $filterText',
          style: TextStyle(
            fontSize: 12.0,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    });
  }
}

class _TableCalendarWrapper extends ConsumerWidget {
  final GlobalKey calendarKey;
  final Function(CalendarFormat) onFormatChanged;
  final Function(DateTime) onPageChanged;
  final VoidCallback onDaySelected;

  const _TableCalendarWrapper({
    required this.calendarKey,
    required this.onFormatChanged,
    required this.onPageChanged,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scheduleNotifierProvider).value;
    final calendarFormat = state?.calendarFormat ?? CalendarFormat.month;
    final focusedDay = state?.focusedDay ?? DateTime.now();

    // Create unique hash from schedule content of the visible calendar area
    // Include previous, current and next months so "out days" changes also trigger rebuilds
    final DateTime hashStartMonth =
        DateTime(focusedDay.year, focusedDay.month - 1, 1);
    final DateTime hashEndMonth =
        DateTime(focusedDay.year, focusedDay.month + 2, 0); // end of next month
    final List<Schedule> visibleSchedulesForHash = (state?.schedules ??
            const <Schedule>[])
        .where((schedule) =>
            schedule.date
                .isAfter(hashStartMonth.subtract(const Duration(days: 1))) &&
            schedule.date.isBefore(hashEndMonth.add(const Duration(days: 1))))
        .toList();
    visibleSchedulesForHash.sort((a, b) => a.date.compareTo(b.date));
    // Build a compact hash of visible data to force TableCalendar to rebuild
    final String visibleSignature = visibleSchedulesForHash
        .map((s) =>
            '${s.date.year}-${s.date.month}-${s.date.day}|${s.configName}|${s.dutyGroupName}|${s.dutyTypeId}')
        .join(';');
    final int tableCalendarKeyHash = Object.hash(
      focusedDay.year,
      focusedDay.month,
      visibleSignature.hashCode,
      state?.activeConfigName,
      state?.preferredDutyGroup,
      state?.partnerConfigName,
      state?.partnerDutyGroup,
    );

    return SizedBox(
      height: CalendarConfig.kCalendarHeight,
      child: TableCalendar(
        key: ValueKey<int>(tableCalendarKeyHash),
        firstDay: CalendarConfig.firstDay,
        lastDay: CalendarConfig.lastDay,
        focusedDay: focusedDay,
        calendarFormat: calendarFormat,
        startingDayOfWeek: CalendarConfig.startingDayOfWeek,
        rowHeight:
            CalendarConfig.kCalendarDayHeight + 8, // Add padding for row height
        selectedDayPredicate: (day) {
          return isSameDay(state?.selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) async {
          await ref
              .read(scheduleNotifierProvider.notifier)
              .setSelectedDay(selectedDay);
          ref.read(scheduleNotifierProvider.notifier).setFocusedDay(focusedDay);
          await ref
              .read(scheduleNotifierProvider.notifier)
              .ensureActiveDay(selectedDay);
          onDaySelected();
        },
        onFormatChanged: (format) {
          // Single source of truth: notifier handles persistence and state
          ref.read(scheduleNotifierProvider.notifier).setCalendarFormat(format);
          onFormatChanged(format);
        },
        onPageChanged: (focusedDay) async {
          // Single source of truth: notifier loads/generates months
          await ref
              .read(scheduleNotifierProvider.notifier)
              .setFocusedDay(focusedDay);
          onPageChanged(focusedDay);
        },
        calendarBuilders: CalendarBuilders(
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
              width: CalendarConfig.kCalendarDayHeight,
              height: CalendarConfig.kCalendarDayHeight,
              onDaySelected: onDaySelected,
            );
          },
        ),
        calendarStyle: CalendarConfig.createCalendarStyle(context),
        headerStyle: CalendarConfig.createHeaderStyle(),
        locale: Localizations.localeOf(context).languageCode,
      ),
    );
  }
}
