import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart' as tc;
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/builders/calendar_day_builders.dart';
import 'package:dienstplan/core/constants/calendar_config.dart';

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

    // Stable calendar key per month/config/locale/format to avoid full rebuilds on data changes
    final String stableCalendarKey =
        'cal_${focusedDay.year}_${focusedDay.month}_'
        '${state?.activeConfigName ?? ''}_'
        '${Localizations.localeOf(context).languageCode}_'
        '${calendarFormat.index}';

    return RepaintBoundary(
      child: SizedBox(
        height: CalendarConfig.kCalendarHeight,
        child: tc.TableCalendar(
          key: ValueKey<String>(stableCalendarKey),
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
          onPageChanged: (focusedDay) {
            ref
                .read(scheduleCoordinatorProvider.notifier)
                .setFocusedDay(focusedDay);
            onPageChanged(focusedDay);
          },
          calendarBuilders: CalendarDayBuilders.create(),
          calendarStyle: CalendarConfig.createCalendarStyle(context),
          headerStyle: CalendarConfig.createHeaderStyle(),
          locale: Localizations.localeOf(context).languageCode,
        ),
      ),
    );
  }
}
