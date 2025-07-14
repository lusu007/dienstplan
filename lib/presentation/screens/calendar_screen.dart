import 'package:flutter/material.dart';
import 'package:dienstplan/presentation/controllers/schedule_controller.dart';
import 'package:dienstplan/data/services/language_service.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:get_it/get_it.dart';

import 'package:dienstplan/presentation/widgets/screens/calendar/calendar_widgets/calendar_app_bar.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/calendar_view/calendar_view.dart';

class CalendarScreen extends StatefulWidget {
  final RouteObserver<ModalRoute<void>> routeObserver;

  const CalendarScreen({super.key, required this.routeObserver});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver, RouteAware {
  late AnimationController _controller;
  late String _locale;
  ScheduleController? _scheduleController;
  LanguageService? _languageService;
  bool _isInitialized = false;

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

    // Get controllers and services from DI container
    _initializeControllers();
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

  @override
  void didPopNext() {
    super.didPopNext();
    if (_scheduleController != null) {
      _scheduleController!.reloadCalendarFormat().then((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  Future<void> _initializeControllers() async {
    _scheduleController = await GetIt.instance.getAsync<ScheduleController>();
    _languageService = GetIt.instance<LanguageService>();

    // Clear any existing schedule cache to prevent memory issues
    _scheduleController!.clearScheduleCache();

    // Load initial data
    await _scheduleController!.loadConfigs();

    // Determine active config from schedules if not set correctly
    if (_scheduleController!.activeConfig == null ||
        _scheduleController!.activeConfig!.name == 'Bereitschaftspolizei') {
      await _determineActiveConfigFromSchedules();
    }

    // Load schedules immediately after configs are loaded
    if (_scheduleController!.activeConfig != null) {
      await _scheduleController!.loadSchedulesForCurrentMonth();
    }

    // Add listener to controller to react to format changes
    _scheduleController!.addListener(_onControllerChanged);

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _determineActiveConfigFromSchedules() async {
    try {
      // Load only a very small sample of schedules to determine active config
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, 1);
      final endDate =
          DateTime(now.year, now.month, 7); // Only first week of current month

      final sampleSchedules =
          await _scheduleController!.getSchedulesUseCase.executeForDateRange(
        startDate: startDate,
        endDate: endDate,
      );

      if (sampleSchedules.isNotEmpty) {
        // Count schedules per config
        final configCounts = <String, int>{};
        for (final schedule in sampleSchedules) {
          configCounts[schedule.configName] =
              (configCounts[schedule.configName] ?? 0) + 1;
        }

        // Find the config with the most schedules
        String? mostUsedConfig;
        int maxCount = 0;
        for (final entry in configCounts.entries) {
          if (entry.value > maxCount) {
            maxCount = entry.value;
            mostUsedConfig = entry.key;
          }
        }

        if (mostUsedConfig != null) {
          // Find the config object
          try {
            final activeConfig = _scheduleController!.configs.firstWhere(
              (config) => config.name == mostUsedConfig,
            );
            // Set the active config directly without calling setActiveConfig to avoid unnecessary operations
            _scheduleController!.setActiveConfigDirectly(activeConfig);

            // Save the active config to settings
            final currentSettings =
                await _scheduleController!.getSettingsUseCase.execute();
            if (currentSettings != null) {
              final updatedSettings = currentSettings.copyWith(
                activeConfigName: activeConfig.name,
              );
              await _scheduleController!.saveSettingsUseCase
                  .execute(updatedSettings);
            }
          } catch (e) {
            // Ignore errors when determining active config from schedules
          }
        }
      }
    } catch (e) {
      // Ignore errors when determining active config from schedules
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      if (_scheduleController != null) {
        _scheduleController!.reloadCalendarFormat().then((_) {
          if (mounted) {
            setState(() {});
          }
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.routeObserver.unsubscribe(this);
    _scheduleController?.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _scheduleController == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: const CalendarAppBar(),
      body: CalendarView(scheduleController: _scheduleController!),
    );
  }
}
