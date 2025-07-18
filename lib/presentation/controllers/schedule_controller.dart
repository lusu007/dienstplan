import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/domain/entities/settings.dart';
import 'package:dienstplan/domain/use_cases/get_schedules_use_case.dart';
import 'package:dienstplan/domain/use_cases/generate_schedules_use_case.dart';
import 'package:dienstplan/domain/use_cases/get_configs_use_case.dart';
import 'package:dienstplan/domain/use_cases/set_active_config_use_case.dart';
import 'package:dienstplan/domain/use_cases/get_settings_use_case.dart';
import 'package:dienstplan/domain/use_cases/save_settings_use_case.dart';
import 'package:dienstplan/core/utils/logger.dart';

class ScheduleController extends ChangeNotifier {
  final GetSchedulesUseCase getSchedulesUseCase;
  final GenerateSchedulesUseCase generateSchedulesUseCase;
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

  ScheduleController({
    required this.getSchedulesUseCase,
    required this.generateSchedulesUseCase,
    required this.getConfigsUseCase,
    required this.setActiveConfigUseCase,
    required this.getSettingsUseCase,
    required this.saveSettingsUseCase,
  });

  List<DutyScheduleConfig> get configs => _configs;
  DutyScheduleConfig? get activeConfig => _activeConfig;
  List<String> get dutyGroups {
    // First try to get duty groups from actual schedules
    if (_schedules.isNotEmpty) {
      final dutyGroupNames = _schedules
          .map((schedule) => schedule.dutyGroupName)
          .where((name) => name.isNotEmpty)
          .toSet()
          .toList();

      if (dutyGroupNames.isNotEmpty) {
        // Sort duty groups for consistent ordering
        dutyGroupNames.sort();
        return dutyGroupNames;
      }
    }

    // Fallback to active config duty groups
    final configDutyGroups =
        _activeConfig?.dutyGroups.map((group) => group.name).toList() ?? [];
    configDutyGroups.sort();
    return configDutyGroups;
  }

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
      final configName = _activeConfig?.name;

      _schedules = await getSchedulesUseCase.executeForDateRange(
        startDate: date,
        endDate: date,
        configName: configName,
      );

      // If no schedules found and we have an active config, generate them
      if (_schedules.isEmpty && configName != null && configName.isNotEmpty) {
        AppLogger.i(
            'ScheduleController: No schedules found for date $date, generating new schedules');

        try {
          final generatedSchedules = await generateSchedulesUseCase.execute(
            configName: configName,
            startDate: date,
            endDate: date,
          );

          _schedules = generatedSchedules;
        } catch (e, stackTrace) {
          AppLogger.e('ScheduleController: Error generating schedules for date',
              e, stackTrace);
          // Don't rethrow - we still want to show the UI even if generation fails
        }
      }
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
      // Notify listeners immediately to show loading state
      notifyListeners();

      // Use configName parameter to filter at database level for better performance
      final configName = _activeConfig?.name;

      final newSchedules = await getSchedulesUseCase.executeForDateRange(
        startDate: start,
        endDate: end,
        configName: configName,
      );

      // If no schedules found and we have an active config, generate them
      if (newSchedules.isEmpty && configName != null && configName.isNotEmpty) {
        AppLogger.i(
            'ScheduleController: No schedules found for range $start to $end, generating new schedules');

        try {
          final generatedSchedules = await generateSchedulesUseCase.execute(
            configName: configName,
            startDate: start,
            endDate: end,
          );

          // Merge generated schedules with existing ones instead of replacing
          _mergeSchedules(generatedSchedules);
          // _mergeSchedules already calls notifyListeners()
        } catch (e, stackTrace) {
          AppLogger.e(
              'ScheduleController: Error generating schedules for range',
              e,
              stackTrace);
          // Don't rethrow - we still want to show the UI even if generation fails
        }
      } else {
        // Merge new schedules with existing ones instead of replacing
        _mergeSchedules(newSchedules);
        // _mergeSchedules already calls notifyListeners()
      }
    } catch (e, stackTrace) {
      AppLogger.e('ScheduleController: Error loading schedules', e, stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _mergeSchedules(List<Schedule> newSchedules) {
    AppLogger.i(
        'ScheduleController: Merging ${newSchedules.length} new schedules with ${_schedules.length} existing schedules');

    // Create a map of new schedules by date and duty group
    final newSchedulesMap = <String, Schedule>{};
    for (final schedule in newSchedules) {
      final key =
          '${schedule.date.toIso8601String()}_${schedule.dutyGroupName}';
      newSchedulesMap[key] = schedule;
    }

    // Merge: keep ALL existing schedules, add/update new schedules
    final mergedSchedules = <Schedule>[];

    // Add all existing schedules (keep everything in memory)
    for (final existingSchedule in _schedules) {
      final key =
          '${existingSchedule.date.toIso8601String()}_${existingSchedule.dutyGroupName}';
      if (!newSchedulesMap.containsKey(key)) {
        // Keep existing schedule if no new one for this date/group
        mergedSchedules.add(existingSchedule);
      }
      // If newSchedulesMap contains the key, we'll add the new one below
    }

    // Add all new schedules (this will replace any existing ones for the same date/group)
    mergedSchedules.addAll(newSchedules);

    // Update the schedules list
    _schedules = mergedSchedules;

    AppLogger.i(
        'ScheduleController: After merge: ${_schedules.length} total schedules');

    // Notify listeners that schedules have been updated
    notifyListeners();
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

      // If no schedules for this day, load them for the entire month plus 2 months before and after
      // This ensures that out-days are covered
      if (!hasSchedulesForDay) {
        // Load schedules for the entire current month plus 2 months before and after
        final startDate = DateTime(day.year, day.month - 2, 1);
        final endDate =
            DateTime(day.year, day.month + 3, 0); // Last day of 2 months after

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

      // Always notify listeners immediately when focused day changes
      notifyListeners();

      // Check if we need to load schedules for a new month
      if (previousFocusedDay == null ||
          previousFocusedDay.year != focusedDay.year ||
          previousFocusedDay.month != focusedDay.month) {
        AppLogger.i(
            'ScheduleController: Loading schedules for new month: ${focusedDay.year}-${focusedDay.month}');
        // Load schedules asynchronously without blocking the UI
        _loadSchedulesForCurrentMonth(focusedDay);
      } else {
        // Even if we're in the same month, ensure we have schedules for this specific month
        // This handles the case where we navigate to a month that hasn't been loaded yet
        final schedulesForMonth = _schedules.where((schedule) {
          return schedule.date.year == focusedDay.year &&
              schedule.date.month == focusedDay.month;
        }).toList();

        AppLogger.i(
            'ScheduleController: Found ${schedulesForMonth.length} schedules for month ${focusedDay.year}-${focusedDay.month}');

        if (schedulesForMonth.isEmpty) {
          AppLogger.i(
              'ScheduleController: No schedules found for month ${focusedDay.year}-${focusedDay.month}, loading them');
          // Load schedules asynchronously without blocking the UI
          _loadSchedulesForCurrentMonth(focusedDay);
        }
      }
    } catch (e, stackTrace) {
      AppLogger.e(
          'ScheduleController: Error setting focused day', e, stackTrace);
      // Still notify listeners even if there was an error
      notifyListeners();
    }
  }

  Future<void> _loadSchedulesForCurrentMonth(DateTime focusedDay) async {
    try {
      // Load current month ±2 months to cover all visible days (including out-days)
      final startDate = DateTime(focusedDay.year, focusedDay.month - 2, 1);
      final endDate = DateTime(focusedDay.year, focusedDay.month + 3, 0);

      AppLogger.i(
          'ScheduleController: Loading schedules for range: ${startDate.toIso8601String()} to ${endDate.toIso8601String()}');

      await loadSchedulesForRange(startDate, endDate);

      AppLogger.i(
          'ScheduleController: Loaded ${_schedules.length} schedules for current month');

      // Check if we have schedules for the focused month specifically
      final schedulesForFocusedMonth = _schedules.where((schedule) {
        return schedule.date.year == focusedDay.year &&
            schedule.date.month == focusedDay.month;
      }).toList();

      AppLogger.i(
          'ScheduleController: Found ${schedulesForFocusedMonth.length} schedules for focused month ${focusedDay.year}-${focusedDay.month}');

      // If no schedules were loaded for the focused month, try to generate them
      if (schedulesForFocusedMonth.isEmpty && _activeConfig != null) {
        AppLogger.w(
            'ScheduleController: Missing schedules for focused month ${focusedDay.year}-${focusedDay.month}, attempting to generate them');

        // Generate schedules for the entire visible range
        await generateSchedules(startDate, endDate);

        // After generating, check again if we have schedules
        final updatedSchedulesForFocusedMonth = _schedules.where((schedule) {
          return schedule.date.year == focusedDay.year &&
              schedule.date.month == focusedDay.month;
        }).toList();

        AppLogger.i(
            'ScheduleController: After generation: Found ${updatedSchedulesForFocusedMonth.length} schedules for focused month ${focusedDay.year}-${focusedDay.month}');
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

      // Load the generated schedules for the entire range
      await loadSchedulesForRange(startDate, endDate);
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
