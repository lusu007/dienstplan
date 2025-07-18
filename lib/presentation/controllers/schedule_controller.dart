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
    // First try to get duty groups from active config (this updates immediately when config changes)
    if (_activeConfig != null) {
      final configDutyGroups =
          _activeConfig!.dutyGroups.map((group) => group.name).toList();
      if (configDutyGroups.isNotEmpty) {
        // Sort duty groups for consistent ordering
        configDutyGroups.sort();
        return configDutyGroups;
      }
    }

    // Fallback to duty groups from actual schedules
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

    // Return empty list if no duty groups found
    return [];
  }

  String? get selectedDutyGroup => _selectedDutyGroup;
  String? get preferredDutyGroup => _preferredDutyGroup;
  DateTime? get selectedDay => _selectedDay;
  DateTime? get focusedDay => _focusedDay;
  List<Schedule> get schedules => _schedules;

  List<Schedule> get schedulesForSelectedDay {
    if (_selectedDay == null) return [];

    // Ensure we have a valid active config
    if (_activeConfig == null) {
      AppLogger.w(
          'ScheduleController: No active config for schedulesForSelectedDay');
      return [];
    }

    final activeConfigName = _activeConfig!.name;

    return _schedules.where((schedule) {
      final isSameDay = schedule.date.year == _selectedDay!.year &&
          schedule.date.month == _selectedDay!.month &&
          schedule.date.day == _selectedDay!.day;

      // Only return schedules for the active config
      final isActiveConfig = schedule.configName == activeConfigName;

      return isSameDay && isActiveConfig;
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

    // Use unawaited to prevent blocking the UI while saving
    _savePreferredDutyGroup(value).catchError((e, stackTrace) {
      AppLogger.e('ScheduleController: Error in preferredDutyGroup setter', e,
          stackTrace);
    });
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
      // Don't rethrow to prevent UI crashes
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
      // Ensure we have a consistent view of the active config
      final activeConfig = _activeConfig;
      final configName = activeConfig?.name;

      AppLogger.i(
          'ScheduleController: loadSchedulesForRange - Loading for config: $configName');
      AppLogger.i(
          'ScheduleController: loadSchedulesForRange - Active config object: ${activeConfig?.toString()}');
      AppLogger.i(
          'ScheduleController: loadSchedulesForRange - Date range: $start to $end');

      final newSchedules = await getSchedulesUseCase.executeForDateRange(
        startDate: start,
        endDate: end,
        configName: configName,
      );

      AppLogger.i(
          'ScheduleController: loadSchedulesForRange - Loaded ${newSchedules.length} schedules from database');
      AppLogger.i(
          'ScheduleController: loadSchedulesForRange - Schedules for active config: ${newSchedules.where((s) => s.configName == configName).length}');

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

          AppLogger.i(
              'ScheduleController: Generated ${generatedSchedules.length} schedules');
          AppLogger.i(
              'ScheduleController: Generated schedules for active config: ${generatedSchedules.where((s) => s.configName == configName).length}');

          // Replace all schedules with generated ones for the active config
          _schedules = generatedSchedules;
          notifyListeners();
        } catch (e, stackTrace) {
          AppLogger.e(
              'ScheduleController: Error generating schedules for range',
              e,
              stackTrace);
          // Don't rethrow - we still want to show the UI even if generation fails
        }
      } else {
        // Replace all schedules with new ones for the active config
        _schedules = newSchedules;
        notifyListeners();
      }

      AppLogger.i(
          'ScheduleController: loadSchedulesForRange - Final schedules count: ${_schedules.length}');
      AppLogger.i(
          'ScheduleController: loadSchedulesForRange - Final schedules for active config: ${_schedules.where((s) => s.configName == configName).length}');
      AppLogger.i(
          'ScheduleController: loadSchedulesForRange - Active config used: $configName');
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
    if (_isLoading) {
      AppLogger.i(
          'ScheduleController: setFocusedDay - Ignored because _isLoading is true');
      return;
    }

    // Additional safety check: ensure we have a valid active config
    if (_activeConfig == null) {
      AppLogger.w(
          'ScheduleController: setFocusedDay - No active config set, attempting to load from settings');

      // Try to refresh active config from settings
      await _refreshActiveConfigFromSettings();

      // If still no active config, ignore the call
      if (_activeConfig == null) {
        AppLogger.w(
            'ScheduleController: setFocusedDay - Still no active config after refresh, ignoring call');
        return;
      }
    }

    // Force refresh active config from settings to ensure consistency
    await _refreshActiveConfigFromSettings();

    AppLogger.i(
        'ScheduleController: setFocusedDay - Called with active config: ${_activeConfig?.name}');

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
        AppLogger.i(
            'ScheduleController: setFocusedDay - Active config: ${_activeConfig?.name}');
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

      // Ensure we have a consistent view of the active config
      final activeConfig = _activeConfig;

      if (activeConfig == null) {
        AppLogger.w(
            'ScheduleController: _loadSchedulesForCurrentMonth - No active config available');
        return;
      }

      AppLogger.i(
          'ScheduleController: Loading schedules for range: ${startDate.toIso8601String()} to ${endDate.toIso8601String()}');
      AppLogger.i(
          'ScheduleController: _loadSchedulesForCurrentMonth - Active config before loadSchedulesForRange: ${activeConfig.name}');

      await loadSchedulesForRange(startDate, endDate);

      AppLogger.i(
          'ScheduleController: Loaded ${_schedules.length} schedules for current month');

      // Check if we have schedules for the focused month specifically
      final schedulesForFocusedMonth = _schedules.where((schedule) {
        return schedule.date.year == focusedDay.year &&
            schedule.date.month == focusedDay.month &&
            schedule.configName == activeConfig.name;
      }).toList();

      AppLogger.i(
          'ScheduleController: Found ${schedulesForFocusedMonth.length} schedules for focused month ${focusedDay.year}-${focusedDay.month} for config ${activeConfig.name}');

      // If no schedules were loaded for the focused month, try to generate them
      if (schedulesForFocusedMonth.isEmpty) {
        AppLogger.w(
            'ScheduleController: Missing schedules for focused month ${focusedDay.year}-${focusedDay.month}, attempting to generate them');

        // Generate schedules for the entire visible range
        await generateSchedules(startDate, endDate);

        // After generating, check again if we have schedules
        final updatedSchedulesForFocusedMonth = _schedules.where((schedule) {
          return schedule.date.year == focusedDay.year &&
              schedule.date.month == focusedDay.month &&
              schedule.configName == activeConfig.name;
        }).toList();

        AppLogger.i(
            'ScheduleController: After generation: Found ${updatedSchedulesForFocusedMonth.length} schedules for focused month ${focusedDay.year}-${focusedDay.month} for config ${activeConfig.name}');
      }

      // Force UI update after loading schedules
      notifyListeners();
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
      // Validate config before proceeding
      if (config.name.isEmpty) {
        throw ArgumentError('Config name cannot be empty');
      }

      AppLogger.i(
          'ScheduleController: Starting to set active config: ${config.name}');
      AppLogger.i(
          'ScheduleController: Current schedules count: ${_schedules.length}');
      AppLogger.i(
          'ScheduleController: Previous active config: ${_activeConfig?.name}');

      await setActiveConfigUseCase.execute(config.name);
      _activeConfig = config;

      AppLogger.i('ScheduleController: Active config set to: ${config.name}');
      AppLogger.i(
          'ScheduleController: Active config object: ${_activeConfig?.toString()}');

      // Save active config to settings
      await _saveActiveConfig(config.name);

      // Check if preferred duty group is still available in new config
      await _validatePreferredDutyGroup();

      // Clear old schedules and load new ones for the active config
      await _refreshSchedulesForNewConfig();

      // Explicitly set focused day again to ensure correct config is used
      if (_focusedDay != null) {
        AppLogger.i(
            'ScheduleController: setActiveConfig - Explicitly setting focused day after config change: $_focusedDay');
        await setFocusedDay(_focusedDay!);
      }

      AppLogger.i(
          'ScheduleController: After refresh, schedules count: ${_schedules.length}');
      AppLogger.i(
          'ScheduleController: Schedules for active config: ${_schedules.where((s) => s.configName == config.name).length}');

      AppLogger.i(
          'ScheduleController: Successfully set active config: ${config.name}');
    } catch (e, stackTrace) {
      _error = 'Failed to set active config: ${e.toString()}';
      AppLogger.e(
          'ScheduleController: Error setting active config', e, stackTrace);
      // Re-throw the error so the UI can handle it appropriately
      rethrow;
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

  Future<void> _refreshSchedulesForNewConfig() async {
    try {
      AppLogger.i('ScheduleController: Starting _refreshSchedulesForNewConfig');
      AppLogger.i('ScheduleController: Active config: ${_activeConfig?.name}');
      AppLogger.i(
          'ScheduleController: Active config object: ${_activeConfig?.toString()}');

      // Force refresh active config from settings to ensure consistency
      await _refreshActiveConfigFromSettings();

      // Clear existing schedules to prevent showing old data
      _schedules.clear();
      notifyListeners();

      AppLogger.i(
          'ScheduleController: Cleared schedules, count: ${_schedules.length}');

      // Determine the date range to load/generate schedules for
      DateTime targetDate;
      if (_focusedDay != null) {
        targetDate = _focusedDay!;
      } else if (_selectedDay != null) {
        targetDate = _selectedDay!;
      } else {
        targetDate = DateTime.now();
      }

      AppLogger.i('ScheduleController: Target date for loading: $targetDate');

      // Load schedules for the current month (this will only load for active config)
      await _loadSchedulesForCurrentMonth(targetDate);

      AppLogger.i(
          'ScheduleController: After _loadSchedulesForCurrentMonth, schedules count: ${_schedules.length}');
      AppLogger.i(
          'ScheduleController: Schedules for active config: ${_schedules.where((s) => s.configName == _activeConfig?.name).length}');

      AppLogger.i('ScheduleController: Refreshed schedules for new config');
    } catch (e, stackTrace) {
      AppLogger.e(
          'ScheduleController: Error refreshing schedules for new config',
          e,
          stackTrace);
      // Don't rethrow - we still want to show the UI even if schedule loading fails
    }
  }

  Future<void> _refreshActiveConfigFromSettings() async {
    try {
      AppLogger.i('ScheduleController: Refreshing active config from settings');
      final settings = await getSettingsUseCase.execute();
      final configName = settings?.activeConfigName;

      if (configName != null && configName.isNotEmpty) {
        // Find the config by name
        final config = _configs.firstWhere(
          (config) => config.name == configName,
          orElse: () => _activeConfig ?? _configs.first,
        );

        if (config.name != _activeConfig?.name) {
          AppLogger.i(
              'ScheduleController: Active config updated from settings: ${config.name}');
          _activeConfig = config;
          notifyListeners();
        }
      }
    } catch (e, stackTrace) {
      AppLogger.e(
          'ScheduleController: Error refreshing active config from settings',
          e,
          stackTrace);
    }
  }

  /// Call this method after the settings screen is closed to ensure UI is properly updated
  Future<void> refreshAfterSettingsClose() async {
    try {
      AppLogger.i('ScheduleController: Refreshing after settings screen close');

      // Refresh active config from settings to ensure consistency
      await _refreshActiveConfigFromSettings();

      // Load preferred duty group from settings to ensure consistency
      await _loadPreferredDutyGroup();

      // Clear schedules to force a complete reload
      _schedules.clear();
      notifyListeners();

      // Reload schedules for current focused day if available
      if (_focusedDay != null) {
        AppLogger.i(
            'ScheduleController: Reloading schedules for focused day: $_focusedDay');

        // Ensure we have an active config before loading schedules
        if (_activeConfig != null) {
          await _loadSchedulesForCurrentMonth(_focusedDay!);
        } else {
          AppLogger.w(
              'ScheduleController: No active config available after settings close');
        }
      } else {
        AppLogger.w(
            'ScheduleController: No focused day available after settings close');
      }

      AppLogger.i('ScheduleController: Refresh after settings close completed');
    } catch (e, stackTrace) {
      AppLogger.e('ScheduleController: Error refreshing after settings close',
          e, stackTrace);
    }
  }
}
