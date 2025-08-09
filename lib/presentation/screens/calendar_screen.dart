import 'package:flutter/material.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/calendar_view/calendar_view.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/calendar_app_bar.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_notifier.dart';
import 'package:dienstplan/data/services/language_service.dart';
import 'package:intl/date_symbol_data_local.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  final RouteObserver<ModalRoute<void>> routeObserver;

  const CalendarScreen({super.key, required this.routeObserver});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver, RouteAware {
  late AnimationController _controller;
  late String _locale;
  LanguageService? _languageService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
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
    widget.routeObserver.subscribe(this, ModalRoute.of(context)!);

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
    _languageService = GetIt.instance<LanguageService>();
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
    widget.routeObserver.unsubscribe(this);
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
