import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/providers/schedule_provider.dart';
import 'package:dienstplan/services/language_service.dart';
import 'package:dienstplan/widgets/layout/schedule_list.dart';
import 'package:dienstplan/screens/settings_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:dienstplan/l10n/app_localizations.dart';
import 'package:dienstplan/widgets/calendar/calendar_header.dart';
import 'package:dienstplan/widgets/calendar/calendar_builders.dart';
import 'package:dienstplan/widgets/calendar/calendar_config.dart';
import 'package:dienstplan/widgets/calendar/services_section.dart';

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
          appBar: _buildAppBar(l10n),
          body: Column(
            children: [
              _buildCalendarHeader(scheduleProvider),
              _buildTableCalendar(scheduleProvider),
              ServicesSection(selectedDay: scheduleProvider.selectedDay),
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

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n) {
    return AppBar(
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
    );
  }

  Widget _buildCalendarHeader(ScheduleProvider scheduleProvider) {
    return CalendarHeader(
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
    );
  }

  Widget _buildTableCalendar(ScheduleProvider scheduleProvider) {
    return TableCalendar(
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
      locale: _locale,
    );
  }
}
