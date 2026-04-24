import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/constants/calendar_config.dart';
import 'package:dienstplan/core/constants/ui_constants.dart';
import 'package:dienstplan/presentation/state/calendar/calendar_notifier.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/state/school_holidays/school_holidays_notifier.dart';
import 'package:dienstplan/presentation/widgets/common/glass_container.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/calendar_view/calendar_split_pointer_listener.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/calendar_view/day_schedules_list_panel.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/calendar_header.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/glass_action_bar.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/schedules_dialog.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/table_calendar.dart';

/// Calendar screen body.
///
/// Renders [CalendarHeader], the month calendar, and the floating glass
/// action bar. Tapping a day opens the glass schedules dialog. A vertical
/// upward swipe on the month grid switches to a height-limited table
/// (compact stripes) and an inline day list below; swipe down on the
/// compact month table restores the default layout.
class CalendarView extends ConsumerStatefulWidget {
  const CalendarView({super.key});

  @override
  ConsumerState<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends ConsumerState<CalendarView> {
  final GlobalKey _calendarKey = GlobalKey();
  bool _isSplitLayout = false;

  @override
  Widget build(BuildContext context) {
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

    final double imeBottom = MediaQuery.viewInsetsOf(context).bottom;
    const double monthToGridSpacing =
        CalendarConfig.kCalendarMonthPickerToGridSpacing;

    return CalendarBackdrop(
      child: Stack(
        children: [
          Positioned.fill(
            child: MediaQuery.removeViewInsets(
              context: context,
              removeBottom: true,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: kGlassBarReservedHeight,
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    child: Column(
                      children: <Widget>[
                        const CalendarHeader(),
                        const SizedBox(height: monthToGridSpacing),
                        if (_isSplitLayout)
                          Expanded(
                            child: LayoutBuilder(
                              builder:
                                  (BuildContext context, BoxConstraints c) {
                                    final double calendarHeight =
                                        _computeSplitLayoutCalendarHeight(
                                          c.maxHeight,
                                        );
                                    return Column(
                                      children: <Widget>[
                                        CalendarSplitPointerListener(
                                          isSplitLayout: true,
                                          onSwipeDownInSplit: _exitSplitLayout,
                                          child: SizedBox(
                                            height: calendarHeight,
                                            width: double.infinity,
                                            child: CalendarTable(
                                              calendarKey: _calendarKey,
                                              onPageChanged: (_) {},
                                              onDaySelected: _handleDaySelected,
                                            ),
                                          ),
                                        ),
                                        const Expanded(
                                          child: DaySchedulesListPanel(),
                                        ),
                                      ],
                                    );
                                  },
                            ),
                          )
                        else
                          Expanded(
                            child: CalendarSplitPointerListener(
                              isSplitLayout: false,
                              onSwipeUpInFull: _enterSplitLayout,
                              child: CalendarTable(
                                calendarKey: _calendarKey,
                                onPageChanged: (_) {},
                                onDaySelected: _handleDaySelected,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: imeBottom,
            child: const GlassActionBar(),
          ),
        ],
      ),
    );
  }

  void _enterSplitLayout() {
    setState(() {
      _isSplitLayout = true;
    });
  }

  void _exitSplitLayout() {
    setState(() {
      _isSplitLayout = false;
    });
  }

  Future<void> _handleDaySelected(DateTime day) async {
    if (!mounted) {
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    if (_isSplitLayout) {
      return;
    }
    await SchedulesDialog.show(context, day);
  }
}

@visibleForTesting
double computeSplitLayoutCalendarHeightForTesting({
  required double availableHeight,
}) {
  return _computeSplitLayoutCalendarHeight(availableHeight);
}

double _computeSplitLayoutCalendarHeight(double availableHeight) {
  return math.min(
    CalendarConfig.kSplitLayoutCalendarMaxHeight,
    availableHeight * 0.55,
  );
}
