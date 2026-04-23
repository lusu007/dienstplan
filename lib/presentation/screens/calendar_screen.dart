import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:dienstplan/data/services/language_service.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/calendar_view/calendar_view.dart';

@RoutePage(name: 'CalendarRoute')
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen>
    with WidgetsBindingObserver {
  late String _locale;
  LanguageService? _languageService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _locale = 'de_DE';
    initializeDateFormatting(_locale, null);
    _initializeServices();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_languageService == null) {
      return;
    }
    final String appLocale = _languageService!.currentLocale.languageCode;
    if (appLocale != _locale) {
      setState(() {
        _locale = appLocale;
        initializeDateFormatting(_locale, null);
      });
    }
  }

  Future<void> _initializeServices() async {
    _languageService = await ref.read(languageServiceProvider.future);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Warm up schedule coordinator provider (ensures initial load)
    ref.watch(scheduleCoordinatorProvider);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: const Scaffold(extendBody: true, body: CalendarView()),
    );
  }
}
