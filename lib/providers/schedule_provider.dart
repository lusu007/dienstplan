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

  // Cache for loaded schedules
  final Map<String, List<Schedule>> _scheduleCache = {};
  static const int _cacheDays = 62; // Cache two months of schedules
  DateTime? _lastGeneratedStartDate;
  DateTime? _lastGeneratedEndDate;

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
      AppLogger.i('Initializing ScheduleProvider');
      await _configService.initialize();
      AppLogger.i('Loading schedule configurations');
      await _loadConfigs();
      AppLogger.i('Loading settings');
      AppLogger.i('Loading active config');
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
    try {
      _activeConfig = config;
      await _saveSettings();

      // Calculate initial date range to generate (1 year before and after current date)
      final now = DateTime.now();
      final startDate = DateTime(now.year - 1, now.month, now.day);
      final endDate = DateTime(now.year + 1, now.month, now.day);

      _lastGeneratedStartDate = startDate;
      _lastGeneratedEndDate = endDate;

      // Generate and save schedules for the initial date range
      AppLogger.i('Generating initial schedules for config: ${config.name}');
      AppLogger.i(
          'Generating schedules from ${startDate.toIso8601String()} to ${endDate.toIso8601String()}');
      final schedules = await _configService.generateSchedulesForConfig(
        config,
        startDate: startDate,
        endDate: endDate,
      );

      // Save schedules in batches
      await _databaseService.saveSchedules(schedules);

      await loadSchedules();
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.e('Error setting active config', e, stackTrace);
      rethrow;
    }
  }

  // Load schedules for the selected day
  Future<void> loadSchedules() async {
    try {
      if (_activeConfig == null) {
        _schedules = [];
        notifyListeners();
        return;
      }

      // Calculate date ranges for both selected and focused months
      final selectedMonthStart = _selectedDay != null
          ? DateTime(_selectedDay!.year, _selectedDay!.month, 1)
          : DateTime.now();
      final selectedMonthEnd =
          DateTime(selectedMonthStart.year, selectedMonthStart.month + 1, 0);

      final focusedMonthStart = _focusedDay != null
          ? DateTime(_focusedDay!.year, _focusedDay!.month, 1)
          : DateTime.now();
      final focusedMonthEnd =
          DateTime(focusedMonthStart.year, focusedMonthStart.month + 1, 0);

      // Determine the overall date range to load
      final startDate = selectedMonthStart.isBefore(focusedMonthStart)
          ? selectedMonthStart
          : focusedMonthStart;
      final endDate = selectedMonthEnd.isAfter(focusedMonthEnd)
          ? selectedMonthEnd
          : focusedMonthEnd;

      // Check if we need to generate more schedules
      if (_lastGeneratedStartDate == null ||
          _lastGeneratedEndDate == null ||
          startDate.isBefore(_lastGeneratedStartDate!) ||
          endDate.isAfter(_lastGeneratedEndDate!)) {
        // Calculate new date range to generate
        final newStartDate =
            startDate.isBefore(_lastGeneratedStartDate ?? startDate)
                ? startDate
                : _lastGeneratedStartDate!;
        final newEndDate = endDate.isAfter(_lastGeneratedEndDate ?? endDate)
            ? endDate
            : _lastGeneratedEndDate!;

        AppLogger.i(
            'Generating additional schedules from ${newStartDate.toIso8601String()} to ${newEndDate.toIso8601String()}');
        final newSchedules = await _configService.generateSchedulesForConfig(
          _activeConfig!,
          startDate: newStartDate,
          endDate: newEndDate,
        );

        // Save new schedules
        await _databaseService.saveSchedules(newSchedules);

        // Update generated date range
        _lastGeneratedStartDate = newStartDate;
        _lastGeneratedEndDate = newEndDate;
      }

      // Check if we have the data in cache
      final cacheKey =
          '${startDate.toIso8601String()}_${endDate.toIso8601String()}_${_activeConfig!.meta.name}';
      if (_scheduleCache.containsKey(cacheKey)) {
        _schedules = _scheduleCache[cacheKey]!;
        notifyListeners();
        return;
      }

      // Load from database if not in cache
      _schedules = await _databaseService.loadSchedulesForDateRange(
        startDate,
        endDate,
        configName: _activeConfig!.meta.name,
      );

      // Update cache
      _scheduleCache[cacheKey] = _schedules;

      // Clean up old cache entries
      _cleanupCache();

      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.e('Error loading schedules', e, stackTrace);
      rethrow;
    }
  }

  void _cleanupCache() {
    final now = DateTime.now();
    final keysToRemove = _scheduleCache.keys.where((key) {
      final parts = key.split('_');
      if (parts.length < 2) return true;

      try {
        final startDate = DateTime.parse(parts[0]);
        return startDate
            .isBefore(now.subtract(const Duration(days: _cacheDays)));
      } catch (e) {
        return true;
      }
    }).toList();

    for (final key in keysToRemove) {
      _scheduleCache.remove(key);
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
    _focusedDay = date; // Update focused day as well
    await loadSchedules(); // Reload schedules when selected day changes
    await _saveSettings();
    notifyListeners();
  }

  // Set selected day (alias for setSelectedDate)
  Future<void> setSelectedDay(DateTime day) async {
    await setSelectedDate(day);
  }

  // Set focused day
  Future<void> setFocusedDay(DateTime date) async {
    if (_focusedDay?.year == date.year && _focusedDay?.month == date.month) {
      // Only update focused day if month/year changed
      return;
    }
    _focusedDay = date;
    await loadSchedules(); // Reload schedules when focused day changes
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
      _scheduleCache.clear();
      _selectedDutyGroup = null;
      _activeConfig = null;
      _selectedDay = DateTime.now();
      _focusedDay = DateTime.now();
      _calendarFormat = CalendarFormat.month;

      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.e('Error resetting provider', e, stackTrace);
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
