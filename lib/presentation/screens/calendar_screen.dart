import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:dienstplan/core/constants/animation_constants.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/calendar_view/calendar_view.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/calendar_app_bar.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_notifier.dart';
import 'package:dienstplan/data/services/language_service.dart';
import 'package:intl/date_symbol_data_local.dart';

@RoutePage()
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;
  late String _locale;
  LanguageService? _languageService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = AnimationController(
      duration: kAnimDefault,
      vsync: this,
    );

    _controller.forward();
    _locale = 'de_DE'; // Default locale
    initializeDateFormatting(_locale, null);

    // Get services from DI container
    _initializeServices();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_languageService != null) {
      final appLocale = _languageService!.currentLocale.languageCode;
      if (appLocale != _locale) {
        setState(() {
          _locale = appLocale;
          initializeDateFormatting(_locale, null);
        });
      }
    }
  }

  Future<void> _initializeServices() async {
    _languageService = await ref.read(languageServiceProvider.future);
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // No-op; provider handles state
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Warm up schedule provider (ensures initial load)
    ref.watch(scheduleNotifierProvider);
    return const Scaffold(
      appBar: CalendarAppBar(),
      body: CalendarView(),
    );
  }
}
