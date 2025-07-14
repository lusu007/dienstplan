import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/presentation/controllers/schedule_controller.dart';
import 'package:dienstplan/presentation/widgets/extra_widgets/layout/schedule_list.dart';
import 'package:dienstplan/presentation/widgets/extra_widgets/calendar/calendar_builders.dart';
import 'package:dienstplan/presentation/widgets/extra_widgets/calendar/calendar_config.dart';
import 'package:dienstplan/presentation/widgets/extra_widgets/calendar/services_section.dart';
import 'package:dienstplan/presentation/widgets/extra_widgets/calendar/custom_calendar_header.dart';

class DraggableSheetUiBuilder {
  static Widget buildCalendarHeader({
    required ScheduleController scheduleController,
    required GlobalKey headerKey,
    required VoidCallback onLeftChevronTap,
    required VoidCallback onRightChevronTap,
    required Function(DateTime) onDateSelected,
  }) {
    return CustomCalendarHeader(
      key: headerKey,
      scheduleController: scheduleController,
      onLeftChevronTap: onLeftChevronTap,
      onRightChevronTap: onRightChevronTap,
      locale: const Locale('de', 'DE'),
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
          child: ServicesSection(selectedDay: selectedDay),
        );
      },
    );
  }

  static Widget buildScheduleList({
    required ScheduleController scheduleController,
    required bool shouldAnimate,
  }) {
    final selectedGroup =
        scheduleController.selectedDutyGroup?.isNotEmpty == true
            ? scheduleController.selectedDutyGroup
            : (scheduleController.preferredDutyGroup?.isNotEmpty == true
                ? scheduleController.preferredDutyGroup
                : null);
    return ScheduleList(
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
    );
  }
}

class _TableCalendarWrapper extends StatefulWidget {
  final ScheduleController scheduleController;
  final GlobalKey calendarKey;
  final Function(CalendarFormat) onFormatChanged;
  final Function(DateTime) onPageChanged;
  final VoidCallback onDaySelected;

  _TableCalendarWrapper({
    required this.scheduleController,
    required this.calendarKey,
    required this.onFormatChanged,
    required this.onPageChanged,
    required this.onDaySelected,
  }) {
    print('DEBUG _TableCalendarWrapper: Constructor called');
  }

  @override
  State<_TableCalendarWrapper> createState() {
    print('DEBUG _TableCalendarWrapper: createState called');
    return _TableCalendarWrapperState();
  }
}

class _TableCalendarWrapperState extends State<_TableCalendarWrapper> {
  @override
  void initState() {
    super.initState();
    // Listen to controller changes
    print('DEBUG _TableCalendarWrapper: Adding listener to scheduleController');
    widget.scheduleController.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    // Remove listener
    print(
        'DEBUG _TableCalendarWrapper: Removing listener from scheduleController');
    widget.scheduleController.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    print('DEBUG _TableCalendarWrapper: _onControllerChanged called');
    // Rebuild when controller changes
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final calendarFormat = widget.scheduleController.calendarFormat;
    print('DEBUG _TableCalendarWrapper: Building with format: $calendarFormat');
    print(
        'DEBUG _TableCalendarWrapper: Controller format: ${widget.scheduleController.calendarFormat}');

    final calendarKey = ValueKey(
        'calendar_${calendarFormat}_${DateTime.now().millisecondsSinceEpoch}');
    print('DEBUG _TableCalendarWrapper: Using key: $calendarKey');

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
      locale: 'de_DE',
    );
  }
}
