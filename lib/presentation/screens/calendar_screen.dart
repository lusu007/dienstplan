import 'package:flutter/material.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/calendar_view/calendar_view.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/calendar_app_bar.dart';
import 'package:dienstplan/presentation/controllers/schedule_controller.dart';
import 'package:get_it/get_it.dart';
import 'package:dienstplan/data/services/language_service.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/domain/entities/settings.dart';
import 'package:dienstplan/domain/use_cases/get_schedules_use_case.dart';
import 'package:dienstplan/domain/use_cases/generate_schedules_use_case.dart';
import 'package:dienstplan/domain/use_cases/get_configs_use_case.dart';
import 'package:dienstplan/domain/use_cases/set_active_config_use_case.dart';
import 'package:dienstplan/domain/use_cases/get_settings_use_case.dart';
import 'package:dienstplan/domain/use_cases/save_settings_use_case.dart';

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
      // Refresh the UI after returning from settings screen
      _scheduleController!.refreshAfterSettingsClose().then((_) {
        if (mounted) {
          setState(() {});
        }
      });

      // Also reload calendar format
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

    // Trigger rebuild immediately when controller is available
    if (mounted) {
      setState(() {});
    }

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

    // Trigger final rebuild after all initialization is complete
    if (mounted) {
      setState(() {});
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
        // Refresh the UI when app is resumed
        _scheduleController!.refreshAfterSettingsClose().then((_) {
          if (mounted) {
            setState(() {});
          }
        });

        // Also reload calendar format
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
    return Scaffold(
      appBar: const CalendarAppBar(),
      body: CalendarView(
        scheduleController: _scheduleController ?? _createEmptyController(),
      ),
    );
  }

  ScheduleController _createEmptyController() {
    // Create an empty controller that allows the calendar to be displayed
    // but doesn't show any skeleton loading
    return _EmptyScheduleController();
  }
}

class _EmptyScheduleController extends ScheduleController {
  _EmptyScheduleController()
      : super(
          getSchedulesUseCase: _EmptyGetSchedulesUseCase(),
          generateSchedulesUseCase: _EmptyGenerateSchedulesUseCase(),
          getConfigsUseCase: _EmptyGetConfigsUseCase(),
          setActiveConfigUseCase: _EmptySetActiveConfigUseCase(),
          getSettingsUseCase: _EmptyGetSettingsUseCase(),
          saveSettingsUseCase: _EmptySaveSettingsUseCase(),
        );

  @override
  bool get isLoading => false; // No loading state

  @override
  DateTime? get selectedDay => DateTime.now();

  @override
  DateTime? get focusedDay => DateTime.now();

  @override
  CalendarFormat get calendarFormat => CalendarFormat.month;

  @override
  List<Schedule> get schedules => [];

  @override
  List<Schedule> get schedulesForSelectedDay => [];

  @override
  List<String> get dutyGroups => [];

  @override
  DutyScheduleConfig? get activeConfig => null;

  @override
  Future<void> setFocusedDay(DateTime day) async {
    // Do nothing - this is an empty controller
  }

  @override
  void setSelectedDay(DateTime? day) {
    // Do nothing - this is an empty controller
  }

  @override
  Future<void> setCalendarFormat(CalendarFormat format) async {
    // Do nothing - this is an empty controller
  }

  @override
  void setSelectedDutyGroup(String? group) {
    // Do nothing - this is an empty controller
  }
}

// Empty use case classes
class _EmptyGetSchedulesUseCase implements GetSchedulesUseCase {
  @override
  Future<List<Schedule>> executeForDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? configName,
  }) async =>
      [];

  @override
  Future<void> clearSchedules() async {}

  @override
  Future<List<Schedule>> execute() async => [];
}

class _EmptyGenerateSchedulesUseCase implements GenerateSchedulesUseCase {
  @override
  Future<List<Schedule>> execute({
    required String configName,
    required DateTime startDate,
    required DateTime endDate,
  }) async =>
      [];
}

class _EmptyGetConfigsUseCase implements GetConfigsUseCase {
  @override
  Future<List<DutyScheduleConfig>> execute() async => [];
}

class _EmptySetActiveConfigUseCase implements SetActiveConfigUseCase {
  @override
  Future<void> execute(String configName) async {}
}

class _EmptyGetSettingsUseCase implements GetSettingsUseCase {
  @override
  Future<Settings?> execute() async => null;
}

class _EmptySaveSettingsUseCase implements SaveSettingsUseCase {
  @override
  Future<void> execute(Settings settings) async {}
}
