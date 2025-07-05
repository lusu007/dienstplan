import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/providers/schedule_provider.dart';
import 'package:dienstplan/widgets/layout/schedule_list.dart';
import 'package:dienstplan/widgets/calendar/calendar_builders.dart';
import 'package:dienstplan/widgets/calendar/calendar_config.dart';
import 'package:dienstplan/widgets/calendar/services_section.dart';

class LandscapeLayout extends StatelessWidget {
  final ScheduleProvider scheduleProvider;

  const LandscapeLayout({
    super.key,
    required this.scheduleProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left side: Calendar
        Expanded(
          flex: 3,
          child: _buildTableCalendar(scheduleProvider),
        ),
        // Right side: Services
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header with accent color
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Drag handle
                      Container(
                        margin: const EdgeInsets.only(top: 8, bottom: 8),
                        width: double.infinity,
                        height: 30,
                        color: Colors.transparent,
                        child: Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                      // Services section as header
                      ServicesSection(
                          selectedDay: scheduleProvider.selectedDay),
                    ],
                  ),
                ),
                // Schedule list
                Expanded(
                  child: ScheduleList(
                    schedules: scheduleProvider.schedules,
                    dutyGroups: scheduleProvider.dutyGroups,
                    selectedDutyGroup: scheduleProvider.selectedDutyGroup,
                    onDutyGroupSelected: (group) {
                      scheduleProvider.setSelectedDutyGroup(group);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableCalendar(ScheduleProvider scheduleProvider) {
    return Builder(
      builder: (context) {
        final calendar = TableCalendar(
          firstDay: CalendarConfig.firstDay,
          lastDay: CalendarConfig.lastDay,
          focusedDay: scheduleProvider.focusedDay ?? DateTime.now(),
          calendarFormat: scheduleProvider.calendarFormat,
          startingDayOfWeek: CalendarConfig.startingDayOfWeek,
          selectedDayPredicate: (day) {
            return isSameDay(scheduleProvider.selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            scheduleProvider.setSelectedDay(selectedDay);
            scheduleProvider.setFocusedDay(focusedDay);
          },
          onFormatChanged: (format) {
            scheduleProvider.setCalendarFormat(format);
          },
          onPageChanged: (focusedDay) {
            scheduleProvider.setFocusedDay(focusedDay);
          },
          calendarBuilders:
              CalendarBuildersHelper.createCalendarBuilders(scheduleProvider),
          calendarStyle: CalendarConfig.createCalendarStyle(context),
          headerStyle: CalendarConfig.createHeaderStyle(),
          locale: 'de_DE',
        );

        return calendar;
      },
    );
  }
}
