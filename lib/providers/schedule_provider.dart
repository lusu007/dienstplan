import 'package:flutter/foundation.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/models/schedule.dart';
import 'package:dienstplan/models/duty_schedule_config.dart';
import 'package:dienstplan/models/duty_type.dart';
import 'package:dienstplan/models/settings.dart';
import 'package:dienstplan/services/database_service.dart';
import 'package:dienstplan/services/schedule_config_service.dart';
import 'package:dienstplan/utils/logger.dart';

class ScheduleProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final ScheduleConfigService _configService;

  List<DutyScheduleConfig> _configs = [];
  DutyScheduleConfig? _activeConfig;
  String? _selectedDutyGroup;
  String? _preferredDutyGroup;
  DateTime? _selectedDay;
  DateTime? _focusedDay;
  List<Schedule> _schedules = [];
  CalendarFormat _calendarFormat = CalendarFormat.month;

  final Map<String, List<Schedule>> _scheduleCache = {};
  static const int _cacheDays = 62;
  DateTime? _lastGeneratedStartDate;
  DateTime? _lastGeneratedEndDate;

  ScheduleProvider(this._configService);

  List<DutyScheduleConfig> get configs => _configs;
  DutyScheduleConfig? get activeConfig => _activeConfig;
  List<String> get dutyGroups =>
      _activeConfig?.dutyGroups.map((group) => group.name).toList() ?? [];
  String? get selectedDutyGroup => _selectedDutyGroup;
  String? get preferredDutyGroup => _preferredDutyGroup;
  DateTime? get selectedDay => _selectedDay;
  DateTime? get focusedDay => _focusedDay;
  List<Schedule> get schedules => _schedules;
  CalendarFormat get calendarFormat => _calendarFormat;

  set selectedDutyGroup(String? value) {
    _selectedDutyGroup = value;
    saveSettings();
    notifyListeners();
  }

  set preferredDutyGroup(String? value) {
    _preferredDutyGroup = value;
    saveSettings();
    notifyListeners();
  }

  Future<void> initialize() async {
    try {
      AppLogger.i('Initializing ScheduleProvider');
      await _configService.initialize();
      await _loadConfigs();
      AppLogger.i('Loading settings');
      AppLogger.i('Loading active config');
      await _loadSettings();

      AppLogger.i(
          'Checking for default config: ${_configService.hasDefaultConfig}');
      if (_configService.hasDefaultConfig) {
        AppLogger.i(
            'Setting active config to default: ${_configService.defaultConfig?.name}');
        await setActiveConfig(_configService.defaultConfig!,
            generateSchedules: true, saveSettingsAfter: false);
      }

      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.e('Error initializing ScheduleProvider', e, stackTrace);
      rethrow;
    }
  }

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

  Future<void> _loadSettings() async {
    try {
      final settings = await _databaseService.loadSettings();
      if (settings != null) {
        _calendarFormat = settings.calendarFormat;
        _selectedDutyGroup = settings.selectedDutyGroup;
        _preferredDutyGroup = settings.preferredDutyGroup;
        _focusedDay = settings.focusedDay;
        _selectedDay = settings.selectedDay;
      } else {
        _calendarFormat = CalendarFormat.month;
        _focusedDay = DateTime.now();
        _selectedDay = DateTime.now();
        _selectedDutyGroup = null;
        _preferredDutyGroup = null;
      }
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.e('Error loading settings', e, stackTrace);
    }
  }

  Future<void> saveSettings() async {
    try {
      final settings = Settings(
        calendarFormat: _calendarFormat,
        focusedDay: _focusedDay ?? DateTime.now(),
        selectedDay: _selectedDay ?? DateTime.now(),
        selectedDutyGroup: _selectedDutyGroup,
        preferredDutyGroup: _preferredDutyGroup,
      );
      await _databaseService.saveSettings(settings);
    } catch (e, stackTrace) {
      AppLogger.e('Error saving settings', e, stackTrace);
    }
  }

  Future<void> setActiveConfig(DutyScheduleConfig config,
      {bool generateSchedules = true, bool saveSettingsAfter = true}) async {
    try {
      if (generateSchedules) {
        final now = DateTime.now();
        final startDate = DateTime(now.year - 1, now.month, now.day);
        final endDate = DateTime(now.year + 1, now.month, now.day);

        _lastGeneratedStartDate = startDate;
        _lastGeneratedEndDate = endDate;

        AppLogger.i('Generating initial schedules for config: ${config.name}');
        AppLogger.i(
            'Generating schedules from ${startDate.toIso8601String()} to ${endDate.toIso8601String()}');
        final schedules = await _configService.generateSchedulesForConfig(
          config,
          startDate: startDate,
          endDate: endDate,
        );

        await _databaseService.saveSchedules(schedules);

        // Save duty types to database
        await _databaseService.saveDutyTypes(config.name, config.dutyTypes);
      }

      _activeConfig = config;

      // Load duty types from database to ensure they're available
      final loadedDutyTypes = await _databaseService.loadDutyTypes(config.name);
      if (loadedDutyTypes.isNotEmpty) {
        _activeConfig!.dutyTypes.clear();
        _activeConfig!.dutyTypes.addAll(loadedDutyTypes);
      }

      if (saveSettingsAfter) {
        await saveSettings();
      }
      await loadSchedules();
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.e('Error setting active config', e, stackTrace);
      rethrow;
    }
  }

  Future<void> loadSchedules() async {
    try {
      if (_activeConfig == null) {
        AppLogger.w('No active config available, skipping schedule load');
        _schedules = [];
        notifyListeners();
        return;
      }

      final now = DateTime.now();
      final selectedMonthStart = _selectedDay != null
          ? DateTime(_selectedDay!.year, _selectedDay!.month, 1)
          : DateTime(now.year, now.month, 1);
      final selectedMonthEnd = _selectedDay != null
          ? DateTime(_selectedDay!.year, _selectedDay!.month + 1, 0)
          : DateTime(now.year, now.month + 1, 0);

      final focusedMonthStart = _focusedDay != null
          ? DateTime(_focusedDay!.year, _focusedDay!.month, 1)
          : DateTime(now.year, now.month, 1);
      final focusedMonthEnd =
          DateTime(focusedMonthStart.year, focusedMonthStart.month + 1, 0);

      // Calculate the first day of the first week of the focused month
      final firstDayOfWeek = focusedMonthStart.weekday;
      final firstWeekStart =
          focusedMonthStart.subtract(Duration(days: firstDayOfWeek - 1));

      // If we're in the current month, use the entire month as the date range
      final startDate =
          _selectedDay?.month == now.month && _selectedDay?.year == now.year
              ? selectedMonthStart
              : selectedMonthStart.isBefore(firstWeekStart)
                  ? selectedMonthStart
                  : firstWeekStart;
      final endDate =
          _selectedDay?.month == now.month && _selectedDay?.year == now.year
              ? selectedMonthEnd
              : selectedMonthEnd.isAfter(focusedMonthEnd)
                  ? selectedMonthEnd
                  : focusedMonthEnd;

      AppLogger.i(
          'Loading schedules for date range: ${startDate.toIso8601String()} to ${endDate.toIso8601String()}');
      AppLogger.i(
          'Selected day: ${_selectedDay?.toIso8601String()}, Focused day: ${_focusedDay?.toIso8601String()}');
      AppLogger.i('First week start: ${firstWeekStart.toIso8601String()}');

      if (_lastGeneratedStartDate == null ||
          _lastGeneratedEndDate == null ||
          startDate.isBefore(_lastGeneratedStartDate!) ||
          endDate.isAfter(_lastGeneratedEndDate!)) {
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

        await _databaseService.saveSchedules(newSchedules);

        _lastGeneratedStartDate = newStartDate;
        _lastGeneratedEndDate = newEndDate;
      }

      final startKey = DateTime(startDate.year, startDate.month, startDate.day);
      final endKey = DateTime(endDate.year, endDate.month, endDate.day);
      final cacheKey =
          '${startKey.toIso8601String()}_${endKey.toIso8601String()}_${_activeConfig!.meta.name}';

      if (_scheduleCache.containsKey(cacheKey)) {
        _schedules = _scheduleCache[cacheKey]!;
        notifyListeners();
        return;
      }

      _schedules = await _databaseService.loadSchedulesForDateRange(
        startDate,
        endDate,
        configName: _activeConfig!.meta.name,
      );

      _scheduleCache[cacheKey] = _schedules;

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

  Future<void> saveSchedules() async {
    try {
      await _databaseService.saveSchedules(_schedules);
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.e('Error saving schedules', e, stackTrace);
      rethrow;
    }
  }

  Future<void> setSelectedDate(DateTime date) async {
    _selectedDay = date;
    _focusedDay = date;
    await loadSchedules();
    await saveSettings();
    notifyListeners();
  }

  Future<void> setSelectedDay(DateTime day) async {
    await setSelectedDate(day);
  }

  Future<void> setFocusedDay(DateTime date) async {
    if (_focusedDay?.year == date.year && _focusedDay?.month == date.month) {
      return;
    }
    _focusedDay = date;
    await loadSchedules();
    await saveSettings();
    notifyListeners();
  }

  Future<void> setSelectedDutyGroup(String? group) async {
    _selectedDutyGroup = group;
    await loadSchedules();
    notifyListeners();
  }

  Future<void> setCalendarFormat(CalendarFormat format) async {
    _calendarFormat = format;
    await saveSettings();
    notifyListeners();
  }

  Future<void> reset() async {
    try {
      await _databaseService.clearDatabase();

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

  Future<DutyType?> getDutyType(String serviceId) async {
    try {
      if (_activeConfig == null) return null;

      // First try to get from memory
      final dutyType = _activeConfig!.dutyTypes[serviceId];
      if (dutyType != null) return dutyType;

      // If not in memory, try to load from database
      return await _databaseService.loadDutyType(
          serviceId, _activeConfig!.name);
    } catch (e, stackTrace) {
      AppLogger.e('Error getting duty type', e, stackTrace);
      return null;
    }
  }

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
