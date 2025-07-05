import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dienstplan/providers/schedule_provider.dart';
import 'package:dienstplan/services/language_service.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:dienstplan/widgets/calendar/calendar_app_bar.dart';
import 'package:dienstplan/widgets/calendar/draggable_sheet.dart';
import 'package:dienstplan/widgets/calendar/landscape_layout.dart';

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
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;

    return Consumer2<ScheduleProvider, LanguageService>(
      builder: (context, scheduleProvider, languageService, child) {
        return Scaffold(
          appBar: const CalendarAppBar(),
          body: isLandscape
              ? LandscapeLayout(scheduleProvider: scheduleProvider)
              : DraggableSheet(scheduleProvider: scheduleProvider),
        );
      },
    );
  }
}
