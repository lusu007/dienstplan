import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/providers/schedule_provider.dart';
import 'package:dienstplan/l10n/app_localizations.dart';

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

  String _getFormatText(CalendarFormat format, AppLocalizations l10n) {
    switch (format) {
      case CalendarFormat.month:
        return l10n.calendarFormatMonth;
      case CalendarFormat.week:
        return l10n.calendarFormatWeek;
      case CalendarFormat.twoWeeks:
        return l10n.calendarFormatTwoWeeks;
    }
  }

  Icon _getFormatIcon(CalendarFormat format) {
    switch (format) {
      case CalendarFormat.month:
        return const Icon(Icons.calendar_month);
      case CalendarFormat.week:
        return const Icon(Icons.view_week);
      case CalendarFormat.twoWeeks:
        return const Icon(Icons.view_agenda);
    }
  }

  CalendarFormat _getNextFormat(CalendarFormat format) {
    switch (format) {
      case CalendarFormat.month:
        return CalendarFormat.week;
      case CalendarFormat.week:
        return CalendarFormat.twoWeeks;
      case CalendarFormat.twoWeeks:
        return CalendarFormat.month;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer<ScheduleProvider>(
      builder: (context, scheduleProvider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () {
                  onFormatChanged(_getNextFormat(calendarFormat));
                },
                icon: _getFormatIcon(calendarFormat),
                label: Text(_getFormatText(calendarFormat, l10n)),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.today),
                onPressed: onTodayPressed,
                tooltip: l10n.today,
              ),
            ],
          ),
        );
      },
    );
  }
}
