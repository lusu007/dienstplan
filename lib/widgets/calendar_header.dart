import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/schedule_provider.dart';

class CalendarHeader extends StatelessWidget {
  final DateTime focusedDay;
  final CalendarFormat calendarFormat;
  final Function(CalendarFormat) onFormatChanged;
  final Function(DateTime) onDaySelected;
  final Function() onTodayPressed;

  const CalendarHeader({
    super.key,
    required this.focusedDay,
    required this.calendarFormat,
    required this.onFormatChanged,
    required this.onDaySelected,
    required this.onTodayPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ScheduleProvider>(
      builder: (context, scheduleProvider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left navigation arrow
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  final newFocusedDay =
                      _getPreviousPeriod(focusedDay, calendarFormat);
                  onDaySelected(newFocusedDay);
                },
                tooltip: 'Vorheriger Zeitraum',
              ),
              // Center section with format buttons and today button
              Row(
                children: [
                  // Format buttons
                  SegmentedButton<CalendarFormat>(
                    segments: const [
                      ButtonSegment<CalendarFormat>(
                        value: CalendarFormat.month,
                        label: Text('Monat'),
                        icon: Icon(Icons.calendar_month),
                      ),
                      ButtonSegment<CalendarFormat>(
                        value: CalendarFormat.week,
                        label: Text('Woche'),
                        icon: Icon(Icons.view_week),
                      ),
                      ButtonSegment<CalendarFormat>(
                        value: CalendarFormat.twoWeeks,
                        label: Text('2 Wochen'),
                        icon: Icon(Icons.view_agenda),
                      ),
                    ],
                    selected: {calendarFormat},
                    onSelectionChanged: (Set<CalendarFormat> selected) {
                      if (selected.isNotEmpty) {
                        onFormatChanged(selected.first);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  // Today button
                  IconButton(
                    icon: const Icon(Icons.today),
                    onPressed: onTodayPressed,
                    tooltip: 'Heute',
                  ),
                ],
              ),
              // Right navigation arrow
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  final newFocusedDay =
                      _getNextPeriod(focusedDay, calendarFormat);
                  onDaySelected(newFocusedDay);
                },
                tooltip: 'Nächster Zeitraum',
              ),
            ],
          ),
        );
      },
    );
  }

  DateTime _getPreviousPeriod(DateTime date, CalendarFormat format) {
    switch (format) {
      case CalendarFormat.month:
        return DateTime(date.year, date.month - 1, 1);
      case CalendarFormat.week:
        return date.subtract(const Duration(days: 7));
      case CalendarFormat.twoWeeks:
        return date.subtract(const Duration(days: 14));
      default:
        return date;
    }
  }

  DateTime _getNextPeriod(DateTime date, CalendarFormat format) {
    switch (format) {
      case CalendarFormat.month:
        return DateTime(date.year, date.month + 1, 1);
      case CalendarFormat.week:
        return date.add(const Duration(days: 7));
      case CalendarFormat.twoWeeks:
        return date.add(const Duration(days: 14));
      default:
        return date;
    }
  }
}
