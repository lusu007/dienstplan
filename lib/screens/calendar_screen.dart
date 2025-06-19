import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/providers/schedule_provider.dart';
import 'package:dienstplan/services/language_service.dart';
import 'package:dienstplan/widgets/schedule_list.dart';
import 'package:dienstplan/screens/settings_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:dienstplan/l10n/app_localizations.dart';
import 'package:dienstplan/widgets/calendar_header.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late String _locale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _controller.forward();
    _locale = 'de_DE'; // Default locale
    initializeDateFormatting(_locale, null);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final languageService = Provider.of<LanguageService>(context);
    final appLocale = languageService.currentLocale.languageCode;
    if (appLocale != _locale) {
      setState(() {
        _locale = appLocale;
        initializeDateFormatting(_locale, null);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer2<ScheduleProvider, LanguageService>(
      builder: (context, scheduleProvider, languageService, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              l10n.dutySchedule,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              CalendarHeader(
                focusedDay: scheduleProvider.focusedDay ?? DateTime.now(),
                calendarFormat: scheduleProvider.calendarFormat,
                onFormatChanged: (format) {
                  scheduleProvider.setCalendarFormat(format);
                },
                onDaySelected: (focusedDay) {
                  scheduleProvider.setFocusedDay(focusedDay);
                },
                onTodayPressed: () {
                  final now = DateTime.now();
                  scheduleProvider.setSelectedDay(now);
                  scheduleProvider.setFocusedDay(now);
                },
              ),
              TableCalendar(
                firstDay: DateTime.utc(2018, 1, 1),
                lastDay: DateTime.utc(2100, 12, 31),
                focusedDay: scheduleProvider.focusedDay ?? DateTime.now(),
                calendarFormat: scheduleProvider.calendarFormat,
                startingDayOfWeek: StartingDayOfWeek.monday,
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
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    final dutyAbbreviation =
                        scheduleProvider.getDutyAbbreviationForDate(
                            day, scheduleProvider.preferredDutyGroup);

                    return Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${day.day}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (dutyAbbreviation != null &&
                              dutyAbbreviation.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                dutyAbbreviation,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                  outsideBuilder: (context, day, focusedDay) {
                    final dutyAbbreviation =
                        scheduleProvider.getDutyAbbreviationForDate(
                            day, scheduleProvider.preferredDutyGroup);

                    return Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${day.day}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          if (dutyAbbreviation != null &&
                              dutyAbbreviation.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                dutyAbbreviation,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                  selectedBuilder: (context, day, focusedDay) {
                    final dutyAbbreviation =
                        scheduleProvider.getDutyAbbreviationForDate(
                            day, scheduleProvider.preferredDutyGroup);

                    return Container(
                      margin: const EdgeInsets.all(1),
                      width: 40,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${day.day}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          if (dutyAbbreviation != null &&
                              dutyAbbreviation.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                dutyAbbreviation,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                  todayBuilder: (context, day, focusedDay) {
                    final dutyAbbreviation =
                        scheduleProvider.getDutyAbbreviationForDate(
                            day, scheduleProvider.preferredDutyGroup);

                    return Container(
                      margin: const EdgeInsets.all(1),
                      width: 40,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withAlpha(128),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${day.day}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (dutyAbbreviation != null &&
                              dutyAbbreviation.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                dutyAbbreviation,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withAlpha(128),
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                locale: _locale,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.services,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      scheduleProvider.selectedDay != null
                          ? l10n.servicesOnDate(DateFormat('dd.MM.yyyy')
                              .format(scheduleProvider.selectedDay!))
                          : l10n.noServicesForDay,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
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
        );
      },
    );
  }
}
