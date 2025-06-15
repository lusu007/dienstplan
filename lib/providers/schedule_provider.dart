import 'package:flutter/foundation.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/models/schedule.dart';
import 'package:dienstplan/models/duty_schedule_config.dart';
import 'package:dienstplan/services/database_service.dart';
import 'package:dienstplan/services/schedule_config_service.dart';
import 'package:dienstplan/utils/logger.dart';

class ScheduleProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final ScheduleConfigService _configService;

  List<DutyScheduleConfig> _configs = [];
  DutyScheduleConfig? _activeConfig;
  final List<String> _dutyGroups = [];
  String? _selectedDutyGroup;
  DateTime? _selectedDay;
  DateTime? _focusedDay;
  List<Schedule> _schedules = [];
  CalendarFormat _calendarFormat = CalendarFormat.month;

  ScheduleProvider(this._configService);

  // Getters
  List<DutyScheduleConfig> get configs => _configs;
  DutyScheduleConfig? get activeConfig => _activeConfig;
  List<String> get dutyGroups => _dutyGroups;
  String? get selectedDutyGroup => _selectedDutyGroup;
  DateTime? get selectedDay => _selectedDay;
  DateTime? get focusedDay => _focusedDay;
  List<Schedule> get schedules => _schedules;
  CalendarFormat get calendarFormat => _calendarFormat;

  // Initialize the provider
  Future<void> initialize() async {
    try {
      AppLogger.i('initialize() called');
      AppLogger.i('Initializing ScheduleProvider');
      AppLogger.i('Loading schedule configurations');
      AppLogger.i('Loading settings');
      AppLogger.i('Loading active config');
      await _configService.initialize();
      await _loadConfigs();
      await _loadSettings();

      AppLogger.i(
          'Checking for default config: ${_configService.hasDefaultConfig}');
      if (_configService.hasDefaultConfig) {
        AppLogger.i(
          'Setting active config to default: '
          '${_configService.defaultConfig?.name}',
        );
        await setActiveConfig(_configService.defaultConfig!);
      } else if (_configs.isNotEmpty && _activeConfig == null) {
        AppLogger.i(
            'No default config, using first config: ${_configs.first.name}');
        await setActiveConfig(_configs.first);
      }

      // Always load schedules after initialization
      await loadSchedules();
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.e('Error initializing ScheduleProvider', e, stackTrace);
      rethrow;
    }
  }

  // Load configurations
  Future<void> _loadConfigs() async {
    try {
      _configs = _configService.configs;
      AppLogger.i(
          'ScheduleProvider: _loadConfigs loaded: ${_configs.length} configs');
    } catch (e, stackTrace) {
      AppLogger.e('Error loading configs', e, stackTrace);
      rethrow;
    }
  }

  // Load settings
  Future<void> _loadSettings() async {
    try {
      final settings = await _databaseService.loadSettings();
      if (settings != null) {
        _calendarFormat = CalendarFormat.values.firstWhere(
          (format) => format.toString() == settings['calendar_format'],
          orElse: () => CalendarFormat.month,
        );
        _focusedDay = settings['focused_day'] as DateTime;
        _selectedDay = settings['selected_day'] as DateTime;
      } else {
        // Set default values if no settings exist
        _calendarFormat = CalendarFormat.month;
        _focusedDay = DateTime.now();
        _selectedDay = DateTime.now();
      }
    } catch (e, stackTrace) {
      AppLogger.e('Error loading settings', e, stackTrace);
      rethrow;
    }
  }

  // Save settings
  Future<void> _saveSettings() async {
    try {
      await _databaseService.saveSettings(
        calendarFormat: _calendarFormat.toString(),
        focusedDay: _focusedDay ?? DateTime.now(),
        selectedDay: _selectedDay ?? DateTime.now(),
      );
    } catch (e, stackTrace) {
      AppLogger.e('Error saving settings', e, stackTrace);
      rethrow;
    }
  }

  // Set active configuration
  Future<void> setActiveConfig(DutyScheduleConfig config) async {
    _activeConfig = config;
    await _saveSettings();

    // Generate and save schedules for the new config
    final schedules = await _configService.generateSchedulesForConfig(config);
    await _databaseService.saveSchedules(schedules);

    await loadSchedules();
    notifyListeners();
  }

  // Load schedules for the selected day
  Future<void> loadSchedules() async {
    try {
      _schedules = await _databaseService.loadSchedules();
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.e('Error loading schedules', e, stackTrace);
      rethrow;
    }
  }

  // Save schedules
  Future<void> saveSchedules() async {
    try {
      await _databaseService.saveSchedules(_schedules);
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.e('Error saving schedules', e, stackTrace);
      rethrow;
    }
  }

  // Set selected date
  Future<void> setSelectedDate(DateTime date) async {
    _selectedDay = date;
    await loadSchedules();
    await _saveSettings();
    notifyListeners();
  }

  // Set selected day (alias for setSelectedDate)
  Future<void> setSelectedDay(DateTime day) async {
    await setSelectedDate(day);
  }

  // Set focused day
  Future<void> setFocusedDay(DateTime date) async {
    _focusedDay = date;
    await _saveSettings();
    notifyListeners();
  }

  // Set selected duty group
  Future<void> setSelectedDutyGroup(String? group) async {
    _selectedDutyGroup = group;
    await loadSchedules();
    notifyListeners();
  }

  // Set calendar format
  Future<void> setCalendarFormat(CalendarFormat format) async {
    _calendarFormat = format;
    await _saveSettings();
    notifyListeners();
  }

  // Reset the provider
  Future<void> reset() async {
    try {
      // Clear all data from the database
      await _databaseService.clearDatabase();

      // Reset all state variables
      _schedules = [];
      _selectedDutyGroup = null;
      _activeConfig = null;
      _selectedDay = DateTime.now();
      _focusedDay = DateTime.now();
      _calendarFormat = CalendarFormat.month;

      // Clear settings
      await _saveSettings();

      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.e('Error resetting schedule provider', e, stackTrace);
      rethrow;
    }
  }

  // Get duty type information
  Future<DutyType?> getDutyType(String serviceId) async {
    try {
      if (_activeConfig == null) return null;
      return _activeConfig!.dutyTypes[serviceId];
    } catch (e, stackTrace) {
      AppLogger.e('Error getting duty type', e, stackTrace);
      return null;
    }
  }

  // Get service display name
  Future<String> getServiceDisplayName(String serviceId) async {
    try {
      if (_activeConfig == null) return serviceId;
      final dutyType = _activeConfig!.dutyTypes[serviceId];
      if (dutyType == null) return serviceId;
      return dutyType.label;
    } catch (e, stackTrace) {
      AppLogger.e('Error getting service display name', e, stackTrace);
      return serviceId;
    }
  }

  int mod(int n, int m) => ((n % m) + m) % m;
}
