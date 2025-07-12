import 'package:flutter/foundation.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/models/schedule.dart';
import 'package:dienstplan/models/duty_schedule_config.dart';
import 'package:dienstplan/models/duty_type.dart';
import 'package:dienstplan/models/settings.dart';
import 'package:dienstplan/services/database_service.dart';
import 'package:dienstplan/services/schedule_config_service.dart';
import 'package:dienstplan/utils/logger.dart';
import 'dart:async';

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
  bool _isLoadingSchedules = false;
  final bool _isReloadingCalendarView = false;

  final Map<String, List<Schedule>> _scheduleCache = {};
  static const int _cacheDays = 62;
  DateTime? _lastGeneratedStartDate;
  DateTime? _lastGeneratedEndDate;

  // Debounce timer for loadSchedules calls
  Timer? _loadSchedulesDebounceTimer;

  final Map<String, String?> _dutyAbbreviationCache = {};

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
  bool get isLoadingSchedules => _isLoadingSchedules;

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
        final endDate = DateTime(now.year + 5, now.month, now.day);

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

      // Check if the preferred duty group exists in the new config
      if (_preferredDutyGroup != null) {
        final availableDutyGroups =
            config.dutyGroups.map((group) => group.name).toList();
        if (!availableDutyGroups.contains(_preferredDutyGroup)) {
          AppLogger.i(
              'Preferred duty group "$_preferredDutyGroup" not available in new config "${config.name}", resetting to null');
          _preferredDutyGroup = null;
        }
      }

      // Check if the selected duty group exists in the new config
      if (_selectedDutyGroup != null) {
        final availableDutyGroups =
            config.dutyGroups.map((group) => group.name).toList();
        if (!availableDutyGroups.contains(_selectedDutyGroup)) {
          AppLogger.i(
              'Selected duty group "$_selectedDutyGroup" not available in new config "${config.name}", resetting to null');
          _selectedDutyGroup = null;
        }
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

      // Cancel any pending debounced call
      _loadSchedulesDebounceTimer?.cancel();

      // Debounce the loadSchedules call to prevent rapid successive calls
      _loadSchedulesDebounceTimer =
          Timer(const Duration(milliseconds: 100), () async {
        await _performLoadSchedules();
      });
    } catch (e, stackTrace) {
      AppLogger.e('Error in loadSchedules', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _performLoadSchedules() async {
    try {
      if (_activeConfig == null) return;

      // Set loading state
      _isLoadingSchedules = true;
      notifyListeners();

      final now = DateTime.now();

      final focusedMonthStart = _focusedDay != null
          ? DateTime(_focusedDay!.year, _focusedDay!.month, 1)
          : DateTime(now.year, now.month, 1);
      final focusedMonthEnd =
          DateTime(focusedMonthStart.year, focusedMonthStart.month + 1, 0);

      // Calculate the first day of the first week of the focused month
      final firstDayOfWeek = focusedMonthStart.weekday;
      final firstWeekStart =
          focusedMonthStart.subtract(Duration(days: firstDayOfWeek - 1));

      // Calculate the last day of the last week of the focused month
      final lastDayOfWeek = focusedMonthEnd.weekday;
      final lastWeekEnd =
          focusedMonthEnd.add(Duration(days: 7 - lastDayOfWeek));

      // Always load the full calendar view including outside days
      final startDate = firstWeekStart;
      final endDate = lastWeekEnd;

      // If there's a selected day outside the calendar view, extend the range to include it
      final effectiveStartDate =
          _selectedDay != null && _selectedDay!.isBefore(startDate)
              ? _selectedDay!
              : startDate;
      final effectiveEndDate =
          _selectedDay != null && _selectedDay!.isAfter(endDate)
              ? _selectedDay!
              : endDate;

      AppLogger.i(
          'Loading schedules for date range: ${effectiveStartDate.toIso8601String()} to ${effectiveEndDate.toIso8601String()}');
      AppLogger.i(
          'Selected day: ${_selectedDay?.toIso8601String()}, Focused day: ${_focusedDay?.toIso8601String()}');
      AppLogger.i('First week start: ${firstWeekStart.toIso8601String()}');
      AppLogger.i('Last week end: ${lastWeekEnd.toIso8601String()}');

      if (_lastGeneratedStartDate == null ||
          _lastGeneratedEndDate == null ||
          effectiveStartDate.isBefore(_lastGeneratedStartDate!) ||
          effectiveEndDate.isAfter(_lastGeneratedEndDate!)) {
        final newStartDate = effectiveStartDate
                .isBefore(_lastGeneratedStartDate ?? effectiveStartDate)
            ? effectiveStartDate
            : _lastGeneratedStartDate!;
        final newEndDate =
            effectiveEndDate.isAfter(_lastGeneratedEndDate ?? effectiveEndDate)
                ? effectiveEndDate
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

      final startKey = DateTime(effectiveStartDate.year,
          effectiveStartDate.month, effectiveStartDate.day);
      final endKey = DateTime(
          effectiveEndDate.year, effectiveEndDate.month, effectiveEndDate.day);
      final cacheKey =
          '${startKey.toIso8601String()}_${endKey.toIso8601String()}_${_activeConfig!.meta.name}';

      if (_scheduleCache.containsKey(cacheKey)) {
        _schedules = _scheduleCache[cacheKey]!;
        _isLoadingSchedules = false;
        clearDutyAbbreviationCache();
        notifyListeners();
        return;
      }

      // Load new schedules from database
      final newSchedules = await _databaseService.loadSchedulesForDateRange(
        effectiveStartDate,
        effectiveEndDate,
        configName: _activeConfig!.meta.name,
      );

      // Merge with existing schedules to prevent duty abbreviations from disappearing
      final existingSchedules = List<Schedule>.from(_schedules);

      // Remove any existing schedules that are in the new range to avoid duplicates
      existingSchedules.removeWhere((schedule) {
        final scheduleDate = DateTime(
            schedule.date.year, schedule.date.month, schedule.date.day);
        return scheduleDate.isAfter(
                effectiveStartDate.subtract(const Duration(days: 1))) &&
            scheduleDate
                .isBefore(effectiveEndDate.add(const Duration(days: 1)));
      });

      // Add the new schedules
      existingSchedules.addAll(newSchedules);

      // Update the schedules list
      _schedules = existingSchedules;

      _scheduleCache[cacheKey] = _schedules;

      _cleanupCache();

      _isLoadingSchedules = false;
      clearDutyAbbreviationCache();
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.e('Error loading schedules', e, stackTrace);
      _isLoadingSchedules = false;
      notifyListeners();
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
      clearDutyAbbreviationCache();
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
    _selectedDay = day;
    _focusedDay = day;

    // Check if we need to generate schedules for the selected day
    if (_activeConfig != null) {
      final selectedDayStart = DateTime(day.year, day.month, day.day);

      // If the selected day is outside our current generation range, generate schedules for it
      if (_lastGeneratedStartDate == null ||
          _lastGeneratedEndDate == null ||
          selectedDayStart.isBefore(_lastGeneratedStartDate!) ||
          selectedDayStart.isAfter(_lastGeneratedEndDate!)) {
        AppLogger.i(
            'Selected day outside current generation range, generating schedules for: ${selectedDayStart.toIso8601String()}');

        // Calculate 3 months before and after
        final generateStartDate =
            DateTime(selectedDayStart.year, selectedDayStart.month - 3, 1);
        final generateEndDate =
            DateTime(selectedDayStart.year, selectedDayStart.month + 4, 0);

        final newSchedules = await _configService.generateSchedulesForConfig(
          _activeConfig!,
          startDate: generateStartDate,
          endDate: generateEndDate,
        );

        await _databaseService.saveSchedules(newSchedules);

        // Update generation range
        if (_lastGeneratedStartDate == null ||
            generateStartDate.isBefore(_lastGeneratedStartDate!)) {
          _lastGeneratedStartDate = generateStartDate;
        }
        if (_lastGeneratedEndDate == null ||
            generateEndDate.isAfter(_lastGeneratedEndDate!)) {
          _lastGeneratedEndDate = generateEndDate;
        }
      }
    }

    await loadSchedules();
    await saveSettings();
    notifyListeners();
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
      _preferredDutyGroup = null;
      _activeConfig = null;
      _selectedDay = DateTime.now();
      _focusedDay = DateTime.now();
      _calendarFormat = CalendarFormat.month;
      clearDutyAbbreviationCache();

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

  String? getDutyAbbreviationForDate(
      DateTime date, String? preferredDutyGroup) {
    if (preferredDutyGroup == null || _activeConfig == null) return null;

    // Use simple cache key for better performance
    final cacheKey =
        '${date.year}-${date.month}-${date.day}|$preferredDutyGroup';
    if (_dutyAbbreviationCache.containsKey(cacheKey)) {
      return _dutyAbbreviationCache[cacheKey];
    }

    // Don't trigger generation if we're already loading schedules or reloading calendar view
    if (_isLoadingSchedules || _isReloadingCalendarView) {
      return null;
    }

    // Use optimized lookup with early exit
    String? result;
    for (final schedule in _schedules) {
      if (schedule.date.year == date.year &&
          schedule.date.month == date.month &&
          schedule.date.day == date.day &&
          schedule.dutyGroupName == preferredDutyGroup) {
        // The duty_type_id is already the abbreviation from the JSON
        final dutyTypeId = schedule.dutyTypeId;
        // Only return empty string for free days ("-")
        result = dutyTypeId == '-' ? '' : dutyTypeId;
        break;
      }
    }

    // Cache the result (including null results)
    _dutyAbbreviationCache[cacheKey] = result;
    return result;
  }

  int mod(int n, int m) => ((n % m) + m) % m;

  void clearDutyAbbreviationCache() {
    _dutyAbbreviationCache.clear();
  }

  @override
  void dispose() {
    _loadSchedulesDebounceTimer?.cancel();
    super.dispose();
  }
}
