import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart' as tc;
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/builders/calendar_day_builders.dart';
import 'package:dienstplan/core/constants/calendar_config.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/utils/calendar_layout_utils.dart';

/// Month-only table calendar that stretches its rows to fill the vertical
/// space it is given by the parent layout.
///
/// [onDaySelected] is fired after the coordinator has been updated so the
/// parent can trigger UI reactions (e.g. opening the schedules dialog).
class CalendarTable extends ConsumerWidget {
  /// Lower bound when there is enough vertical space (comfortable cells).
  static const double _preferredFloorRowHeight = 32.0;
  static const double _maxRowHeight = 140.0;

  final GlobalKey calendarKey;
  final ValueChanged<DateTime> onPageChanged;
  final ValueChanged<DateTime> onDaySelected;

  const CalendarTable({
    super.key,
    required this.calendarKey,
    required this.onPageChanged,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scheduleCoordinatorProvider.select((s) => s.value));
    final DateTime focusedDay = state?.focusedDay ?? DateTime.now();
    final int weekRows = getWeekRowsForMonth(
      focusedDay,
      starting: CalendarConfig.startingDayOfWeek,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final double available = constraints.maxHeight;
        final double rowHeight = _resolveRowHeight(available, weekRows);
        final double cellHeight = rowHeight - 4.0; // account for 2px margins

        final String stableCalendarKey =
            'cal_${focusedDay.year}_${focusedDay.month}_'
            '${state?.activeConfigName ?? ''}_'
            '${Localizations.localeOf(context).languageCode}_'
            'n${state?.schedules.length ?? 0}_'
            'rh${rowHeight.toStringAsFixed(1)}';

        return RepaintBoundary(
          child: tc.TableCalendar(
            key: ValueKey<String>(stableCalendarKey),
            firstDay: CalendarConfig.firstDay,
            lastDay: CalendarConfig.lastDay,
            focusedDay: focusedDay,
            calendarFormat: tc.CalendarFormat.month,
            availableCalendarFormats: const {tc.CalendarFormat.month: ''},
            startingDayOfWeek: CalendarConfig.startingDayOfWeek,
            headerVisible: false,
            daysOfWeekHeight: CalendarConfig.kDaysOfWeekRowHeight,
            rowHeight: rowHeight,
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
              onDaySelected(selectedDay);
            },
            onPageChanged: (focusedDay) {
              ref
                  .read(scheduleCoordinatorProvider.notifier)
                  .setFocusedDay(focusedDay);
              onPageChanged(focusedDay);
            },
            calendarBuilders: CalendarDayBuilders.create(
              cellHeight: cellHeight,
            ),
            calendarStyle: CalendarConfig.createCalendarStyle(context),
            headerStyle: CalendarConfig.createHeaderStyle(),
            locale: Localizations.localeOf(context).languageCode,
          ),
        );
      },
    );
  }

  double _resolveRowHeight(double availableHeight, int weekRows) {
    if (!availableHeight.isFinite || availableHeight <= 0 || weekRows <= 0) {
      return _preferredFloorRowHeight;
    }
    final double rawRowHeight =
        (availableHeight - CalendarConfig.kDaysOfWeekRowHeight) / weekRows;
    if (rawRowHeight <= 0) {
      return _preferredFloorRowHeight;
    }
    // Never force rows taller than fits (e.g. keyboard shrinks height). Older
    // logic used a high minimum (78) which caused RenderFlex overflow.
    final double clamped = rawRowHeight.clamp(
      _preferredFloorRowHeight,
      _maxRowHeight,
    );
    return math.min(clamped, rawRowHeight);
  }
}
