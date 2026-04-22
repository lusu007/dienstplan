import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/state/school_holidays/school_holidays_notifier.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/date_selector/calendar_date_selector.dart';

/// Tappable month/year chip used inside the [CalendarHeader].
///
/// Returns the raw [CalendarDateSelector] (which opens the month/year picker
/// modal on tap). All positioning and spacing is handled by the parent.
class CalendarMonthTitle extends ConsumerWidget {
  const CalendarMonthTitle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scheduleCoordinatorProvider).value;
    final DateTime focusedDay = state?.focusedDay ?? DateTime.now();
    final DateTime? selectedDay = state?.selectedDay;

    return CalendarDateSelector(
      currentDate: focusedDay,
      selectedDay: selectedDay,
      locale: Localizations.localeOf(context),
      onDateSelected: (DateTime date) => _handleDateSelected(ref, date),
    );
  }

  Future<void> _handleDateSelected(WidgetRef ref, DateTime date) async {
    final currentFocusedDay = ref
        .read(scheduleCoordinatorProvider)
        .value
        ?.focusedDay;
    final bool yearChanged =
        currentFocusedDay == null || currentFocusedDay.year != date.year;
    if (yearChanged) {
      await ref
          .read(schoolHolidaysProvider.notifier)
          .loadHolidaysForYear(date.year);
    }
    await ref.read(scheduleCoordinatorProvider.notifier).setFocusedDay(date);
  }
}
