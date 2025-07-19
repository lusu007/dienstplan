import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/presentation/controllers/schedule_controller.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/duty_list/duty_schedule_list.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/builders/calendar_builders_helper.dart';
import 'package:dienstplan/core/constants/calendar_config.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/duty_list/duty_schedule_header.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/date_selector/calendar_date_selector_header.dart';

class CalendarViewUiBuilder {
  static Widget buildCalendarHeader({
    required BuildContext context,
    required ScheduleController scheduleController,
    required GlobalKey headerKey,
    required VoidCallback onLeftChevronTap,
    required VoidCallback onRightChevronTap,
    required Function(DateTime) onDateSelected,
  }) {
    return CalendarDateSelectorHeader(
      key: headerKey,
      scheduleController: scheduleController,
      onLeftChevronTap: onLeftChevronTap,
      onRightChevronTap: onRightChevronTap,
      locale: Localizations.localeOf(context),
      onDateSelected: onDateSelected,
    );
  }

  static Widget buildTableCalendar({
    required BuildContext context,
    required ScheduleController scheduleController,
    required GlobalKey calendarKey,
    required Function(CalendarFormat) onFormatChanged,
    required Function(DateTime) onPageChanged,
    required VoidCallback onDaySelected,
  }) {
    return _TableCalendarWrapper(
      scheduleController: scheduleController,
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
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.02,
            ),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
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
    required ScheduleController scheduleController,
    bool shouldAnimate = false,
  }) {
    // Only use selectedDutyGroup if it's explicitly set by user action
    // Don't automatically use preferredDutyGroup for filtering
    final selectedGroup =
        scheduleController.selectedDutyGroup?.isNotEmpty == true
            ? scheduleController.selectedDutyGroup
            : null;

    return DutyScheduleList(
      schedules: scheduleController.schedulesForSelectedDay.cast(),
      dutyGroups: scheduleController.dutyGroups,
      selectedDutyGroup: selectedGroup,
      activeConfigName: scheduleController.activeConfig?.name,
      dutyTypeOrder: scheduleController.activeConfig?.dutyTypeOrder,
      dutyTypes: scheduleController.activeConfig?.dutyTypes,
      onDutyGroupSelected: (group) {
        scheduleController.setSelectedDutyGroup(group ?? '');
      },
      shouldAnimate: shouldAnimate,
      selectedDay: scheduleController.selectedDay,
      isLoading: scheduleController.isLoading, // Pass loading state
    );
  }
}

class _TableCalendarWrapper extends StatefulWidget {
  final ScheduleController scheduleController;
  final GlobalKey calendarKey;
  final Function(CalendarFormat) onFormatChanged;
  final Function(DateTime) onPageChanged;
  final VoidCallback onDaySelected;

  const _TableCalendarWrapper({
    required this.scheduleController,
    required this.calendarKey,
    required this.onFormatChanged,
    required this.onPageChanged,
    required this.onDaySelected,
  });

  @override
  State<_TableCalendarWrapper> createState() {
    return _TableCalendarWrapperState();
  }
}

class _TableCalendarWrapperState extends State<_TableCalendarWrapper> {
  @override
  void initState() {
    super.initState();
    // Listen to controller changes to sync calendar
    widget.scheduleController.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.scheduleController.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    // Rebuild when controller changes
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final calendarFormat = widget.scheduleController.calendarFormat;

    // Use a stable key based on calendarFormat only
    final calendarKey = ValueKey('calendar_$calendarFormat');

    return TableCalendar(
      key: calendarKey,
      firstDay: CalendarConfig.firstDay,
      lastDay: CalendarConfig.lastDay,
      focusedDay: widget.scheduleController.focusedDay ?? DateTime.now(),
      calendarFormat: calendarFormat,
      startingDayOfWeek: CalendarConfig.startingDayOfWeek,
      selectedDayPredicate: (day) {
        return isSameDay(widget.scheduleController.selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        // This callback is not used since we handle day selection in the calendar builders
        // The calendar builders directly call the controller methods
      },
      onFormatChanged: widget.onFormatChanged,
      onPageChanged: widget.onPageChanged,
      calendarBuilders: CalendarBuildersHelper.createCalendarBuilders(
        widget.scheduleController,
        onDaySelected: widget.onDaySelected,
      ),
      calendarStyle: CalendarConfig.createCalendarStyle(context),
      headerStyle: CalendarConfig.createHeaderStyle(),
      locale: Localizations.localeOf(context).languageCode,
    );
  }
}
