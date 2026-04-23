import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/constants/calendar_config.dart';
import 'package:dienstplan/core/constants/ui_constants.dart';
import 'package:dienstplan/presentation/state/calendar/calendar_notifier.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/state/school_holidays/school_holidays_notifier.dart';
import 'package:dienstplan/presentation/widgets/common/glass_container.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/calendar_header.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/glass_action_bar.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/schedules_dialog.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/table_calendar.dart';

/// Calendar screen body.
///
/// Renders its own [CalendarHeader] at the top in place of the default
/// [AppBar], followed by the month calendar and the floating glass action
/// bar. Tapping a day opens the glass schedules dialog.
class CalendarView extends ConsumerStatefulWidget {
  const CalendarView({super.key});

  @override
  ConsumerState<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends ConsumerState<CalendarView> {
  final GlobalKey _calendarKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    // Warm up calendar provider and load holidays when the year changes.
    ref.watch(calendarProvider);
    ref.listen(scheduleCoordinatorProvider, (previous, next) {
      final DateTime? previousFocused = previous?.value?.focusedDay;
      final DateTime? currentFocused = next.value?.focusedDay;
      if (previousFocused == null || currentFocused == null) {
        return;
      }
      if (previousFocused.year != currentFocused.year) {
        ref
            .read(schoolHolidaysProvider.notifier)
            .loadHolidaysForYear(currentFocused.year);
      }
    });

    return CalendarBackdrop(
      child: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: kGlassBarReservedHeight),
              child: Column(
                children: [
                  const CalendarHeader(),
                  const SizedBox(
                    height: CalendarConfig.kCalendarMonthPickerToGridSpacing,
                  ),
                  Expanded(
                    child: CalendarTable(
                      calendarKey: _calendarKey,
                      onPageChanged: (_) {},
                      onDaySelected: _handleDaySelected,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GlassActionBar(),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDaySelected(DateTime day) async {
    if (!mounted) return;
    await SchedulesDialog.show(context, day);
  }
}
