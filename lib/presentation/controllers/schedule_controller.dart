import 'package:flutter/foundation.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/domain/use_cases/get_schedules_use_case.dart';
import 'package:dienstplan/domain/use_cases/generate_schedules_use_case.dart';
import 'package:dienstplan/domain/use_cases/get_duty_abbreviation_use_case.dart';
import 'package:dienstplan/domain/use_cases/get_configs_use_case.dart';
import 'package:dienstplan/domain/use_cases/set_active_config_use_case.dart';
import 'package:dienstplan/domain/use_cases/get_settings_use_case.dart';
import 'package:dienstplan/domain/use_cases/save_settings_use_case.dart';
import 'package:dienstplan/domain/entities/settings.dart';
import 'package:dienstplan/core/utils/logger.dart';

class ScheduleController extends ChangeNotifier {
  final GetSchedulesUseCase getSchedulesUseCase;
  final GenerateSchedulesUseCase generateSchedulesUseCase;
  final GetDutyAbbreviationUseCase getDutyAbbreviationUseCase;
  final GetConfigsUseCase getConfigsUseCase;
  final SetActiveConfigUseCase setActiveConfigUseCase;
  final GetSettingsUseCase getSettingsUseCase;
  final SaveSettingsUseCase saveSettingsUseCase;

  List<DutyScheduleConfig> _configs = [];
  DutyScheduleConfig? _activeConfig;
  String? _selectedDutyGroup;
  String? _preferredDutyGroup;
  DateTime? _selectedDay;
  DateTime? _focusedDay;
  List<Schedule> _schedules = [];
  CalendarFormat _calendarFormat = CalendarFormat.month;
  bool _isLoading = false;
  String? _error;
  bool _isInitializing = false;

  final Map<String, String?> _dutyAbbreviationCache = {};

  ScheduleController({
    required this.getSchedulesUseCase,
    required this.generateSchedulesUseCase,
    required this.getDutyAbbreviationUseCase,
    required this.getConfigsUseCase,
    required this.setActiveConfigUseCase,
    required this.getSettingsUseCase,
    required this.saveSettingsUseCase,
  });

  List<DutyScheduleConfig> get configs => _configs;
  DutyScheduleConfig? get activeConfig => _activeConfig;
  List<String> get dutyGroups =>
      _activeConfig?.dutyGroups.map((group) => group.name).toList() ?? [];
  String? get selectedDutyGroup => _selectedDutyGroup;
  String? get preferredDutyGroup => _preferredDutyGroup;
  DateTime? get selectedDay => _selectedDay;
  DateTime? get focusedDay => _focusedDay;
  List<Schedule> get schedules => _schedules;

  List<Schedule> get schedulesForSelectedDay {
    if (_selectedDay == null) return [];

    return _schedules.where((schedule) {
      return schedule.date.year == _selectedDay!.year &&
          schedule.date.month == _selectedDay!.month &&
          schedule.date.day == _selectedDay!.day;
    }).toList();
  }

  CalendarFormat get calendarFormat => _calendarFormat;
  bool get isLoading => _isLoading;
  String? get error => _error;

  set selectedDutyGroup(String? value) {
    _selectedDutyGroup = value;
    notifyListeners();
  }

  set preferredDutyGroup(String? value) {
    _preferredDutyGroup = value;
    notifyListeners();
    _savePreferredDutyGroup(value);
  }

  Future<void> _savePreferredDutyGroup(String? value) async {
    try {
      final currentSettings = await getSettingsUseCase.execute();
      if (currentSettings != null) {
        final updatedSettings = currentSettings.copyWith(
          preferredDutyGroup: value,
        );
        await saveSettingsUseCase.execute(updatedSettings);
      }
    } catch (e, stackTrace) {
      AppLogger.e('ScheduleController: Error saving preferred duty group', e,
          stackTrace);
    }
  }

  Future<void> loadSchedules(DateTime date) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _selectedDay = date;
      _schedules = await getSchedulesUseCase.executeForDateRange(
        startDate: date,
        endDate: date,
      );
    } catch (e, stackTrace) {
      _error = 'Failed to load schedules';
      AppLogger.e('ScheduleController: Error loading schedules', e, stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSchedulesForRange(DateTime start, DateTime end) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Use configName parameter to filter at database level for better performance
      final configName = _activeConfig?.name;

      print(
          'DEBUG loadSchedulesForRange: Loading schedules for range: $start to $end');
      print('  Config: $configName');
      print(
          '  Range covers: ${start.month}/${start.year} to ${end.month}/${end.year}');
      print('  Current schedules count before loading: ${_schedules.length}');

      final newSchedules = await getSchedulesUseCase.executeForDateRange(
        startDate: start,
        endDate: end,
        configName: configName,
      );

      print('  Loaded ${newSchedules.length} new schedules');

      // Merge new schedules with existing ones, avoiding duplicates
      final existingDates = _schedules
          .map((s) => '${s.date.year}-${s.date.month}-${s.date.day}')
          .toSet();
      final schedulesToAdd = newSchedules.where((schedule) {
        final dateKey =
            '${schedule.date.year}-${schedule.date.month}-${schedule.date.day}';
        return !existingDates.contains(dateKey);
      }).toList();

      // Update schedules immediately and notify listeners
      if (schedulesToAdd.isNotEmpty) {
        _schedules.addAll(schedulesToAdd);

        print('  Added ${schedulesToAdd.length} new schedules');
        print('  Total schedules count after loading: ${_schedules.length}');

        // Notify listeners immediately when new data is added
        notifyListeners();
      }

      if (_schedules.isNotEmpty) {
        final firstSchedule = _schedules.first;
        final lastSchedule = _schedules.last;
        print(
            '  Total schedule range: ${firstSchedule.date} to ${lastSchedule.date}');
      }
    } catch (e, stackTrace) {
      print('ERROR loadSchedulesForRange: Error loading schedules: $e');
      print('Stack trace: $stackTrace');
      _error = 'Failed to load schedules';
      AppLogger.e('ScheduleController: Error loading schedules', e, stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedDay(DateTime day) {
    try {
      _selectedDay = day;
      notifyListeners();

      // Check if we have schedules for this day, if not, load them
      _ensureSchedulesForSelectedDay(day);
    } catch (e, stackTrace) {
      print('ERROR setSelectedDay: Error setting selected day: $e');
      print('Stack trace: $stackTrace');
      AppLogger.e(
          'ScheduleController: Error setting selected day', e, stackTrace);
    }
  }

  Future<void> _ensureSchedulesForSelectedDay(DateTime day) async {
    try {
      print(
          'DEBUG _ensureSchedulesForSelectedDay: Checking schedules for day: $day');
      print('  Current schedules count: ${_schedules.length}');

      // Check if we have schedules for this day
      final hasSchedulesForDay = _schedules.any((schedule) {
        return schedule.date.year == day.year &&
            schedule.date.month == day.month &&
            schedule.date.day == day.day;
      });

      print('  Has schedules for selected day: $hasSchedulesForDay');

      // If no schedules for this day, load them for a small range around the day
      if (!hasSchedulesForDay) {
        print('  Loading schedules for selected day range');
        // Load schedules for a small range around the selected day to avoid performance issues
        final startDate = day.subtract(const Duration(days: 3));
        final endDate = day.add(const Duration(days: 3));

        await loadSchedulesForRange(startDate, endDate);
        print('  Schedules loaded for selected day range');
      } else {
        print('  Schedules already available for selected day');
      }
    } catch (e, stackTrace) {
      print(
          'ERROR _ensureSchedulesForSelectedDay: Error ensuring schedules for selected day: $e');
      print('Stack trace: $stackTrace');
      AppLogger.e(
          'ScheduleController: Error ensuring schedules for selected day',
          e,
          stackTrace);
      // Don't crash the app, just log the error
    }
  }

  void setFocusedDay(DateTime day) {
    try {
      final oldFocusedDay = _focusedDay;
      _focusedDay = day;

      // Notify listeners immediately for UI update
      notifyListeners();

      // Only reload schedules if this is not during initialization and the month changed
      // AND if this is not a day selection (to avoid race conditions with setSelectedDay)
      if (!_isInitializing &&
          (oldFocusedDay == null ||
              oldFocusedDay.year != day.year ||
              oldFocusedDay.month != day.month)) {
        print(
            'DEBUG setFocusedDay: Month changed, loading schedules for: $day');
        _loadSchedulesForCurrentMonth(day);
      } else {
        print('DEBUG setFocusedDay: No month change or during initialization');
      }
    } catch (e, stackTrace) {
      print('ERROR setFocusedDay: Error setting focused day: $e');
      print('Stack trace: $stackTrace');
      AppLogger.e(
          'ScheduleController: Error setting focused day', e, stackTrace);
    }
  }

  Future<void> _loadSchedulesForCurrentMonth(DateTime focusedDay) async {
    try {
      // Load schedules for the current month plus 2 months before and after
      // This ensures smooth navigation and proper calendar display
      final firstDayOfMonth = DateTime(focusedDay.year, focusedDay.month, 1);
      final lastDayOfMonth = DateTime(focusedDay.year, focusedDay.month + 1, 0);

      // Add 2 months before and after to ensure calendar displays properly
      final startDate = DateTime(focusedDay.year, focusedDay.month - 2, 1);
      final endDate = DateTime(focusedDay.year, focusedDay.month + 3, 0);

      print(
          'DEBUG _loadSchedulesForCurrentMonth: Loading schedules for range: $startDate to $endDate');
      print('  Focused day: $focusedDay');
      print('  Selected day: $_selectedDay');
      print(
          '  Range covers: ${startDate.month}/${startDate.year} to ${endDate.month}/${endDate.year}');

      await loadSchedulesForRange(startDate, endDate);

      // After loading the month range, also ensure we have schedules for the selected day
      if (_selectedDay != null) {
        await _ensureSchedulesForSelectedDay(_selectedDay!);
      }
    } catch (e, stackTrace) {
      AppLogger.e(
          'ScheduleController: Error loading schedules for current month',
          e,
          stackTrace);
    }
  }

  void clearScheduleCache() {
    _schedules.clear();
    _dutyAbbreviationCache.clear();
    notifyListeners();
  }

  void setActiveConfigDirectly(DutyScheduleConfig config) {
    _activeConfig = config;
    notifyListeners();

    // Don't automatically reload schedules when setting active config
    // Let user trigger schedule loading when needed
  }

  Future<void> setCalendarFormat(CalendarFormat format) async {
    print(
        'DEBUG ScheduleController: setCalendarFormat called with format: $format');
    _calendarFormat = format;
    print(
        'DEBUG ScheduleController: Calling notifyListeners() from setCalendarFormat');
    notifyListeners();

    // Save calendar format to settings
    await _saveCalendarFormat(format);
    print(
        'DEBUG ScheduleController: setCalendarFormat completed, format saved: $_calendarFormat');
  }

  void setSelectedDutyGroup(String group) {
    _selectedDutyGroup = group;
    notifyListeners();
    refreshSchedules();
  }

  Future<void> refreshSchedules() async {
    if (_selectedDay != null) {
      await loadSchedules(_selectedDay!);
    }
  }

  Future<void> loadConfigs() async {
    _isLoading = true;
    _error = null;
    _isInitializing = true;
    notifyListeners();
    try {
      _configs = await getConfigsUseCase.execute();

      // Load active config from settings
      await _loadActiveConfig();

      // Load preferred duty group from settings
      await _loadPreferredDutyGroup();

      // Load selected and focused day from settings
      await _loadSelectedAndFocusedDay();

      // Load calendar format from settings
      await _loadCalendarFormat();

      // Load schedules for current month if we have an active config and focused day
      if (_activeConfig != null && _focusedDay != null) {
        await _loadSchedulesForCurrentMonth(_focusedDay!);
      }
    } catch (e, stackTrace) {
      _error = 'Failed to load configs';
      AppLogger.e('ScheduleController: Error loading configs', e, stackTrace);
    } finally {
      _isLoading = false;
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<void> _loadActiveConfig() async {
    try {
      final settings = await getSettingsUseCase.execute();
      final configName = settings?.activeConfigName;

      print('DEBUG _loadActiveConfig: Starting to load active config');
      print('  Settings: $settings');
      print('  activeConfigName: $configName');
      print('  selectedDutyGroup: ${settings?.selectedDutyGroup}');
      print('  preferredDutyGroup: ${settings?.preferredDutyGroup}');
      print('  Available configs: ${_configs.map((c) => c.name).toList()}');

      if (settings != null && configName != null && configName.isNotEmpty) {
        // Try to find the active config by name
        try {
          final activeConfig = _configs.firstWhere(
            (config) => config.name == configName,
          );
          _activeConfig = activeConfig;
          print('  ✅ Found active config: ${activeConfig.name}');
          notifyListeners();
          return;
        } catch (e) {
          print(
              '  ❌ Config not found: $configName, falling back to first config');
          // If config not found, fallback to first config
          if (_configs.isNotEmpty) {
            _activeConfig = _configs.first;
            print('  🔄 Using first config: ${_activeConfig!.name}');
            // Save this as the active config
            await _saveActiveConfig(_activeConfig!.name);
            notifyListeners();
            return;
          }
        }
      } else if (_configs.isNotEmpty && _activeConfig == null) {
        // Fallback to first config if no active config is set
        _activeConfig = _configs.first;
        print(
            '  🔄 No active config set, using first config: ${_activeConfig!.name}');
        // Save this as the active config
        await _saveActiveConfig(_activeConfig!.name);
        notifyListeners();
        return;
      }

      print('  ⚠️ No configs available or no fallback possible');
    } catch (e, stackTrace) {
      AppLogger.e(
          'ScheduleController: Error loading active config', e, stackTrace);
      // Fallback to first config if error occurs
      if (_configs.isNotEmpty && _activeConfig == null) {
        _activeConfig = _configs.first;
        print(
            '  🔄 Error fallback: Using first config: ${_activeConfig!.name}');
        notifyListeners();
      }
    }
  }

  Future<void> _loadPreferredDutyGroup() async {
    try {
      final settings = await getSettingsUseCase.execute();
      if (settings != null && settings.preferredDutyGroup != null) {
        _preferredDutyGroup = settings.preferredDutyGroup;
        notifyListeners();
      }
    } catch (e, stackTrace) {
      AppLogger.e('ScheduleController: Error loading preferred duty group', e,
          stackTrace);
    }
  }

  Future<void> _loadSelectedAndFocusedDay() async {
    try {
      final settings = await getSettingsUseCase.execute();
      if (settings != null) {
        _selectedDay = settings.selectedDay;
        _focusedDay = settings.focusedDay;
        notifyListeners();
      } else {
        // Fallback to current date if no settings
        final now = DateTime.now();
        _selectedDay = now;
        _focusedDay = now;
        notifyListeners();
      }
    } catch (e, stackTrace) {
      AppLogger.e('ScheduleController: Error loading selected and focused day',
          e, stackTrace);
      // Fallback to current date if error occurs
      final now = DateTime.now();
      _selectedDay = now;
      _focusedDay = now;
      notifyListeners();
    }
  }

  Future<void> setActiveConfig(DutyScheduleConfig config) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await setActiveConfigUseCase.execute(config.name);
      _activeConfig = config;

      // Save active config to settings
      await _saveActiveConfig(config.name);

      // Check if preferred duty group is still available in new config
      await _validatePreferredDutyGroup();
    } catch (e, stackTrace) {
      _error = 'Failed to set active config';
      AppLogger.e(
          'ScheduleController: Error setting active config', e, stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _validatePreferredDutyGroup() async {
    if (_preferredDutyGroup != null && _activeConfig != null) {
      final availableGroups =
          _activeConfig!.dutyGroups.map((group) => group.name).toList();
      if (!availableGroups.contains(_preferredDutyGroup)) {
        // Preferred duty group is not available in new config, reset it
        _preferredDutyGroup = null;
        await _savePreferredDutyGroup(null);
        notifyListeners();
      }
    }
  }

  Future<void> _saveActiveConfig(String configName) async {
    try {
      final currentSettings = await getSettingsUseCase.execute();
      if (currentSettings != null) {
        final updatedSettings = currentSettings.copyWith(
          activeConfigName: configName,
        );
        await saveSettingsUseCase.execute(updatedSettings);
      }
    } catch (e, stackTrace) {
      AppLogger.e(
          'ScheduleController: Error saving active config', e, stackTrace);
    }
  }

  Future<void> _loadCalendarFormat() async {
    try {
      print('DEBUG ScheduleController: _loadCalendarFormat called');
      final settings = await getSettingsUseCase.execute();
      print('DEBUG ScheduleController: Settings loaded: $settings');
      if (settings != null) {
        print(
            'DEBUG ScheduleController: Current format: $_calendarFormat, Settings format: ${settings.calendarFormat}');
        _calendarFormat = settings.calendarFormat;
        print('DEBUG ScheduleController: Format updated to: $_calendarFormat');
        print(
            'DEBUG ScheduleController: Calling notifyListeners() from _loadCalendarFormat');
        notifyListeners();
      }
    } catch (e, stackTrace) {
      AppLogger.e(
          'ScheduleController: Error loading calendar format', e, stackTrace);
    }
  }

  Future<void> reloadCalendarFormat() async {
    print('DEBUG ScheduleController: reloadCalendarFormat called');
    await _loadCalendarFormat();
    print(
        'DEBUG ScheduleController: reloadCalendarFormat completed, format: $_calendarFormat');
  }

  Future<void> _saveCalendarFormat(CalendarFormat format) async {
    try {
      final currentSettings = await getSettingsUseCase.execute();
      if (currentSettings != null) {
        final updatedSettings = currentSettings.copyWith(
          calendarFormat: format,
        );
        await saveSettingsUseCase.execute(updatedSettings);
      }
    } catch (e, stackTrace) {
      AppLogger.e(
          'ScheduleController: Error saving calendar format', e, stackTrace);
    }
  }

  Future<String?> getDutyAbbreviation(String dutyTypeId) async {
    if (_dutyAbbreviationCache.containsKey(dutyTypeId)) {
      return _dutyAbbreviationCache[dutyTypeId];
    }

    try {
      final configName = _activeConfig?.name ?? '';
      if (configName.isEmpty) return null;

      final abbreviation = await getDutyAbbreviationUseCase.execute(
        dutyTypeId: dutyTypeId,
        configName: configName,
      );
      _dutyAbbreviationCache[dutyTypeId] = abbreviation;
      return abbreviation;
    } catch (e, stackTrace) {
      AppLogger.e(
          'ScheduleController: Error getting duty abbreviation', e, stackTrace);
      return null;
    }
  }

  Future<void> generateSchedules(DateTime startDate, DateTime endDate) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final configName = _activeConfig?.name ?? '';
      if (configName.isEmpty) {
        throw ArgumentError('No active config selected');
      }

      await generateSchedulesUseCase.execute(
        configName: configName,
        startDate: startDate,
        endDate: endDate,
      );
      await refreshSchedules();
    } catch (e, stackTrace) {
      _error = 'Failed to generate schedules';
      AppLogger.e(
          'ScheduleController: Error generating schedules', e, stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> regenerateAllSchedules(
      DateTime startDate, DateTime endDate) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      // Generate schedules for all configs
      for (final config in _configs) {
        await generateSchedulesUseCase.execute(
          configName: config.name,
          startDate: startDate,
          endDate: endDate,
        );
      }

      // Reload schedules for current range
      if (_selectedDay != null) {
        // Use the same range as _loadSchedulesForCurrentMonth (±2 months)
        final startDate =
            DateTime(_selectedDay!.year, _selectedDay!.month - 2, 1);
        final endDate =
            DateTime(_selectedDay!.year, _selectedDay!.month + 3, 0);
        await loadSchedulesForRange(startDate, endDate);
      }
    } catch (e, stackTrace) {
      _error = 'Failed to regenerate schedules';
      AppLogger.e(
          'ScheduleController: Error regenerating schedules', e, stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSchedulesForCurrentMonth() async {
    if (_focusedDay != null && _activeConfig != null) {
      await _loadSchedulesForCurrentMonth(_focusedDay!);
    } else {}
  }
}
