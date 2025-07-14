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

      final newSchedules = await getSchedulesUseCase.executeForDateRange(
        startDate: start,
        endDate: end,
        configName: configName,
      );

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

        notifyListeners();
      }
    } catch (e, stackTrace) {
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
      AppLogger.e(
          'ScheduleController: Error setting selected day', e, stackTrace);
    }
  }

  Future<void> _ensureSchedulesForSelectedDay(DateTime day) async {
    try {
      // Check if we have schedules for this day
      final hasSchedulesForDay = _schedules.any((schedule) {
        return schedule.date.year == day.year &&
            schedule.date.month == day.month &&
            schedule.date.day == day.day;
      });

      // If no schedules for this day, load them for a small range around the day
      if (!hasSchedulesForDay) {
        // Load schedules for a small range around the selected day to avoid performance issues
        final startDate = day.subtract(const Duration(days: 3));
        final endDate = day.add(const Duration(days: 3));

        await loadSchedulesForRange(startDate, endDate);
      }
    } catch (e, stackTrace) {
      AppLogger.e(
          'ScheduleController: Error ensuring schedules for selected day',
          e,
          stackTrace);
      // Don't crash the app, just log the error
    }
  }

  Future<void> setFocusedDay(DateTime focusedDay) async {
    try {
      final previousFocusedDay = _focusedDay;
      _focusedDay = focusedDay;

      // Check if we need to load schedules for a new month
      if (previousFocusedDay == null ||
          previousFocusedDay.year != focusedDay.year ||
          previousFocusedDay.month != focusedDay.month) {
        await _loadSchedulesForCurrentMonth(focusedDay);
      }

      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.e(
          'ScheduleController: Error setting focused day', e, stackTrace);
    }
  }

  Future<void> _loadSchedulesForCurrentMonth(DateTime focusedDay) async {
    try {
      // Add 2 months before and after to ensure calendar displays properly
      final startDate = DateTime(focusedDay.year, focusedDay.month - 2, 1);
      final endDate = DateTime(focusedDay.year, focusedDay.month + 3, 0);

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
    try {
      if (_calendarFormat != format) {
        _calendarFormat = format;
        await _saveCalendarFormat();
        notifyListeners();
      }
    } catch (e, stackTrace) {
      AppLogger.e(
          'ScheduleController: Error setting calendar format', e, stackTrace);
    }
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
      notifyListeners();
    }
  }

  Future<void> _loadActiveConfig() async {
    try {
      final settings = await getSettingsUseCase.execute();
      final configName = settings?.activeConfigName;

      if (settings != null && configName != null && configName.isNotEmpty) {
        // Try to find the active config by name
        try {
          final activeConfig = _configs.firstWhere(
            (config) => config.name == configName,
          );
          _activeConfig = activeConfig;
          notifyListeners();
          return;
        } catch (e) {
          // If config not found, fallback to first config
          if (_configs.isNotEmpty) {
            _activeConfig = _configs.first;
            // Save this as the active config
            await _saveActiveConfig(_activeConfig!.name);
            notifyListeners();
            return;
          }
        }
      } else if (_configs.isNotEmpty && _activeConfig == null) {
        // Fallback to first config if no active config is set
        _activeConfig = _configs.first;
        // Save this as the active config
        await _saveActiveConfig(_activeConfig!.name);
        notifyListeners();
        return;
      }
    } catch (e, stackTrace) {
      AppLogger.e(
          'ScheduleController: Error loading active config', e, stackTrace);
      // Fallback to first config if error occurs
      if (_configs.isNotEmpty && _activeConfig == null) {
        _activeConfig = _configs.first;
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
      final settings = await getSettingsUseCase.execute();
      if (settings != null) {
        _calendarFormat = settings.calendarFormat;
        // Migrate old format if necessary
        await _migrateCalendarFormatIfNeeded(settings);
      }
    } catch (e, stackTrace) {
      AppLogger.e(
          'ScheduleController: Error loading calendar format', e, stackTrace);
    }
  }

  Future<void> _migrateCalendarFormatIfNeeded(Settings settings) async {
    try {
      // Check if the calendar format was saved with the old toString() method
      // If so, we need to migrate it to use the name property
      final currentSettings = await getSettingsUseCase.execute();
      if (currentSettings != null) {
        // Force a save to ensure the format is saved with the correct name property
        await _saveCalendarFormat();
      }
    } catch (e, stackTrace) {
      AppLogger.e(
          'ScheduleController: Error migrating calendar format', e, stackTrace);
    }
  }

  Future<void> reloadCalendarFormat() async {
    try {
      await _loadCalendarFormat();
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.e(
          'ScheduleController: Error reloading calendar format', e, stackTrace);
    }
  }

  Future<void> _saveCalendarFormat() async {
    try {
      final settings = await getSettingsUseCase.execute();
      if (settings != null) {
        final updatedSettings = settings.copyWith(
          calendarFormat: _calendarFormat,
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
