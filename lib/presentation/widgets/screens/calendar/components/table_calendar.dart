import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart' as tc;
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/calendar_builders.dart';
import 'package:dienstplan/core/constants/calendar_config.dart';
import 'package:dienstplan/domain/entities/schedule.dart';

/// Optimized table calendar with RepaintBoundary and const constructors
class CalendarTable extends ConsumerWidget {
  final GlobalKey calendarKey;
  final Function(tc.CalendarFormat) onFormatChanged;
  final Function(DateTime) onPageChanged;
  final VoidCallback onDaySelected;

  const CalendarTable({
    super.key,
    required this.calendarKey,
    required this.onFormatChanged,
    required this.onPageChanged,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scheduleCoordinatorProvider).value;
    final calendarFormat = state?.calendarFormat ?? tc.CalendarFormat.month;
    final focusedDay = state?.focusedDay ?? DateTime.now();

    // Create unique hash from schedule content of the visible calendar area
    final tableCalendarKeyHash = _createTableCalendarKeyHash(
      focusedDay,
      state?.schedules ?? const <Schedule>[],
      state?.activeConfigName,
      state?.preferredDutyGroup,
      state?.partnerConfigName,
      state?.partnerDutyGroup,
    );

    return RepaintBoundary(
      child: SizedBox(
        height: CalendarConfig.kCalendarHeight,
        child: tc.TableCalendar(
          key: ValueKey<int>(tableCalendarKeyHash),
          firstDay: CalendarConfig.firstDay,
          lastDay: CalendarConfig.lastDay,
          focusedDay: focusedDay,
          calendarFormat: calendarFormat,
          startingDayOfWeek: CalendarConfig.startingDayOfWeek,
          rowHeight: CalendarConfig.kCalendarDayHeight + 8,
          selectedDayPredicate: (day) {
            return tc.isSameDay(state?.selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) async {
            await ref
                .read(scheduleCoordinatorProvider.notifier)
                .setSelectedDay(selectedDay);
            ref
                .read(scheduleCoordinatorProvider.notifier)
                .setFocusedDay(focusedDay);
            await ref
                .read(scheduleCoordinatorProvider.notifier)
                .ensureActiveDay(selectedDay);
            onDaySelected();
          },
          onPageChanged: (focusedDay) async {
            await ref
                .read(scheduleCoordinatorProvider.notifier)
                .setFocusedDay(focusedDay);
            onPageChanged(focusedDay);
          },
          calendarBuilders: CustomCalendarBuilders.create(),
          calendarStyle: CalendarConfig.createCalendarStyle(context),
          headerStyle: CalendarConfig.createHeaderStyle(),
          locale: Localizations.localeOf(context).languageCode,
        ),
      ),
    );
  }

  int _createTableCalendarKeyHash(
    DateTime focusedDay,
    List<Schedule> schedules,
    String? activeConfigName,
    String? preferredDutyGroup,
    String? partnerConfigName,
    String? partnerDutyGroup,
  ) {
    // Include previous, current and next months so "out days" changes also trigger rebuilds
    final DateTime hashStartMonth =
        DateTime(focusedDay.year, focusedDay.month - 1, 1);
    final DateTime hashEndMonth =
        DateTime(focusedDay.year, focusedDay.month + 2, 0);

    final List<Schedule> visibleSchedulesForHash = schedules
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

    return Object.hash(
      focusedDay.year,
      focusedDay.month,
      visibleSignature.hashCode,
      activeConfigName,
      preferredDutyGroup,
      partnerConfigName,
      partnerDutyGroup,
    );
  }
}
