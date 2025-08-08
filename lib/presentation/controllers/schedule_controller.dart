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
import 'package:dienstplan/core/cache/settings_cache.dart';

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
  String? _myDutyGroup;
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
  String? get preferredDutyGroup => _myDutyGroup;
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
    _myDutyGroup = value;
    notifyListeners();

    // Use unawaited to prevent blocking the UI while saving
    _saveMyDutyGroup(value).catchError((e, stackTrace) {
      AppLogger.e('ScheduleController: Error in preferredDutyGroup setter', e,
          stackTrace);
    });
  }

  Future<void> _saveMyDutyGroup(String? value) async {
    try {
      final currentSettings = await getSettingsUseCase.execute();
      if (currentSettings != null && currentSettings.myDutyGroup != value) {
        AppLogger.i(
            'ScheduleController: My duty group changed, saving settings');
        final updatedSettings = currentSettings.copyWith(
          myDutyGroup: value,
        );
        await saveSettingsUseCase.execute(updatedSettings);
      } else {
        AppLogger.d(
            'ScheduleController: My duty group unchanged, skipping save');
      }
    } catch (e, stackTrace) {
      AppLogger.e(
          'ScheduleController: Error saving my duty group', e, stackTrace);
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

      // Always merge schedules to preserve selectedDay schedules, even when no new schedules are loaded
      // Merge new schedules with existing ones instead of replacing them
      // This ensures that schedules for selected days remain available when navigating between months
      final existingSchedules = _schedules
          .where((schedule) => schedule.configName != configName)
          .toList();

      // Remove duplicates by using a map with date+configName as key
      final scheduleMap = <String, Schedule>{};

      // Add existing schedules
      for (final schedule in existingSchedules) {
        final key =
            '${schedule.date.toIso8601String()}_${schedule.configName}_${schedule.dutyGroupId}';
        scheduleMap[key] = schedule;
      }

      // Add new schedules (will overwrite duplicates)
      for (final schedule in newSchedules) {
        final key =
            '${schedule.date.toIso8601String()}_${schedule.configName}_${schedule.dutyGroupId}';
        scheduleMap[key] = schedule;
      }

      // Also preserve schedules for the selected day if it exists (add AFTER new schedules to ensure they're not overwritten)
      if (_selectedDay != null) {
        final selectedDaySchedules = _schedules.where((schedule) {
          final isSelectedDay = schedule.date.year == _selectedDay!.year &&
              schedule.date.month == _selectedDay!.month &&
              schedule.date.day == _selectedDay!.day;
          final isActiveConfig = schedule.configName == configName;
          return isSelectedDay && isActiveConfig;
        }).toList();

        // Add selected day schedules to the map (with higher priority - added after new schedules)
        for (final schedule in selectedDaySchedules) {
          final key =
              '${schedule.date.toIso8601String()}_${schedule.configName}_${schedule.dutyGroupId}';
          scheduleMap[key] = schedule;
        }

        if (selectedDaySchedules.isNotEmpty) {
          AppLogger.i(
              'ScheduleController: Preserving ${selectedDaySchedules.length} schedules for selected day ${_selectedDay!.toIso8601String()}');
        }
      }

      _schedules = scheduleMap.values.toList();

      // Clean up old schedules to prevent memory issues (disabled for now)
      // _cleanupOldSchedules();

      AppLogger.i(
          'ScheduleController: Merged schedules - existing: ${existingSchedules.length}, new: ${newSchedules.length}, total: ${_schedules.length}');
      AppLogger.i(
          'ScheduleController: Schedules for active config after merge: ${_schedules.where((s) => s.configName == configName).length}');
      notifyListeners();

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

      // If no schedules for this day, load them for the entire month plus 3 months before and after
      // This ensures that out-days are covered
      if (!hasSchedulesForDay) {
        // Load schedules for the entire current month plus 3 months before and after
        final startDate = DateTime(day.year, day.month - 3, 1);
        final endDate =
            DateTime(day.year, day.month + 4, 0); // Last day of 3 months after

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

  Future<void> goToToday() async {
    final now = DateTime.now();

    // Set both selected and focused day to today
    _selectedDay = now;
    _focusedDay = now;

    // Notify listeners immediately
    notifyListeners();

    // Load schedules for today's month ±3 months
    final startDate = DateTime(now.year, now.month - 3, 1);
    final endDate = DateTime(now.year, now.month + 4, 0);

    AppLogger.i(
        'ScheduleController: goToToday - Loading schedules for range: ${startDate.toIso8601String()} to ${endDate.toIso8601String()}');

    await loadSchedulesForRange(startDate, endDate);
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
      // Don't automatically change selectedDay when loading schedules for a new month
      // The selectedDay should only change when the user explicitly selects a day
      // This preserves the user's selection across month navigation

      // Load focused month ±2 months to cover all visible days
      final DateTime startDate =
          DateTime(focusedDay.year, focusedDay.month - 2, 1);
      final DateTime endDate =
          DateTime(focusedDay.year, focusedDay.month + 3, 0);

      // Ensure selectedDay schedules are loaded if they're not in the cache
      if (_selectedDay != null && _activeConfig != null) {
        final hasSelectedDaySchedules = _schedules.any((schedule) {
          return schedule.date.year == _selectedDay!.year &&
              schedule.date.month == _selectedDay!.month &&
              schedule.date.day == _selectedDay!.day &&
              schedule.configName == _activeConfig!.name;
        });

        if (!hasSelectedDaySchedules) {
          AppLogger.i(
              'ScheduleController: Selected day schedules not in cache, loading them separately');

          // Load schedules for the selected day's month ±3 months
          final selectedDayStartDate =
              DateTime(_selectedDay!.year, _selectedDay!.month - 3, 1);
          final selectedDayEndDate =
              DateTime(_selectedDay!.year, _selectedDay!.month + 4, 0);

          await loadSchedulesForRange(selectedDayStartDate, selectedDayEndDate);
        }
      }

      AppLogger.i(
          'ScheduleController: Loading schedules for range: ${startDate.toIso8601String()} to ${endDate.toIso8601String()}');

      // Ensure we have a consistent view of the active config
      final activeConfig = _activeConfig;

      if (activeConfig == null) {
        AppLogger.w(
            'ScheduleController: _loadSchedulesForCurrentMonth - No active config available, attempting to load schedules anyway');

        // Try to load schedules without an active config to see what's available
        await loadSchedulesForRange(startDate, endDate);

        // If we loaded some schedules, try to determine the active config
        if (_schedules.isNotEmpty) {
          final configCounts = <String, int>{};
          for (final schedule in _schedules) {
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
            // Find the config object and set it as active
            try {
              final configToSet = _configs
                  .firstWhere((config) => config.name == mostUsedConfig);
              _activeConfig = configToSet;
              AppLogger.i(
                  'ScheduleController: Auto-selected active config: ${configToSet.name}');
              notifyListeners();
            } catch (e) {
              AppLogger.w(
                  'ScheduleController: Could not find config object for: $mostUsedConfig');
            }
          }
        }

        return;
      }

      // Load schedules for the normal range
      await loadSchedulesForRange(startDate, endDate);

      // Don't load selected day separately - it's already in the cache from previous navigation
      // The selectedDay schedules are preserved during the merge process

      AppLogger.i(
          'ScheduleController: Loaded ${_schedules.length} schedules for current month');

      // Check if we have schedules for the focused month and selected day
      final schedulesForFocusedMonth = _schedules.where((schedule) {
        return schedule.date.year == focusedDay.year &&
            schedule.date.month == focusedDay.month &&
            schedule.configName == activeConfig.name;
      }).toList();

      final schedulesForSelectedDay = _selectedDay != null
          ? _schedules.where((schedule) {
              return schedule.date.year == _selectedDay!.year &&
                  schedule.date.month == _selectedDay!.month &&
                  schedule.date.day == _selectedDay!.day &&
                  schedule.configName == activeConfig.name;
            }).toList()
          : <Schedule>[];

      AppLogger.i(
          'ScheduleController: Found ${schedulesForFocusedMonth.length} schedules for focused month ${focusedDay.year}-${focusedDay.month} for config ${activeConfig.name}');
      AppLogger.i(
          'ScheduleController: Found ${schedulesForSelectedDay.length} schedules for selected day ${_selectedDay?.toIso8601String()} for config ${activeConfig.name}');

      // If no schedules were loaded for the focused month, try to generate them
      // Note: selectedDay schedules should already exist if the day is selected
      if (schedulesForFocusedMonth.isEmpty) {
        AppLogger.w(
            'ScheduleController: Missing schedules for focused month, attempting to generate them');

        // Preserve selectedDay schedules before generation
        final selectedDaySchedules = _selectedDay != null
            ? _schedules.where((schedule) {
                return schedule.date.year == _selectedDay!.year &&
                    schedule.date.month == _selectedDay!.month &&
                    schedule.date.day == _selectedDay!.day &&
                    schedule.configName == activeConfig.name;
              }).toList()
            : <Schedule>[];

        // Generate schedules for the normal range only
        await generateSchedules(startDate, endDate);

        // Restore selectedDay schedules after generation
        if (selectedDaySchedules.isNotEmpty) {
          AppLogger.i(
              'ScheduleController: Restoring ${selectedDaySchedules.length} selectedDay schedules after generation');

          // Add selectedDay schedules back to the cache
          for (final schedule in selectedDaySchedules) {
            final key =
                '${schedule.date.toIso8601String()}_${schedule.configName}_${schedule.dutyGroupId}';
            final scheduleMap = <String, Schedule>{};

            // Add all existing schedules
            for (final existingSchedule in _schedules) {
              final existingKey =
                  '${existingSchedule.date.toIso8601String()}_${existingSchedule.configName}_${existingSchedule.dutyGroupId}';
              scheduleMap[existingKey] = existingSchedule;
            }

            // Add selectedDay schedules (will overwrite duplicates)
            scheduleMap[key] = schedule;

            _schedules = scheduleMap.values.toList();
          }
        }

        // After generating, check again if we have schedules for the focused month
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
    // Don't refresh schedules - filtering should only affect display, not data loading
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

      // Load all settings once and reuse them
      final settings = await getSettingsUseCase.execute();

      // Load active config from settings
      await _loadActiveConfig(settings);

      // Load preferred duty group from settings
      await _loadMyDutyGroup(settings);

      // Load selected and focused day from settings
      await _loadSelectedAndFocusedDay(settings);

      // Load calendar format from settings
      await _loadCalendarFormat(settings);

      // Only load schedules if we have an active config (not during first setup)
      if (_activeConfig != null) {
        AppLogger.i(
            'ScheduleController: Active config found, loading schedules for current month');
        // Load schedules for current month ±3 months as fallback
        final now = DateTime.now();
        final startDate = DateTime(now.year, now.month - 3, 1);
        final endDate = DateTime(now.year, now.month + 4, 0);
        await loadSchedulesForRange(startDate, endDate);
      } else {
        AppLogger.i(
            'ScheduleController: No active config found, skipping schedule loading (first setup)');
      }
    } catch (e, stackTrace) {
      _error = 'Failed to load configs';
      AppLogger.e('ScheduleController: Error loading configs', e, stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadActiveConfig([Settings? settings]) async {
    try {
      final currentSettings = settings ?? await getSettingsUseCase.execute();
      final configName = currentSettings?.activeConfigName;

      if (currentSettings != null &&
          configName != null &&
          configName.isNotEmpty) {
        // Try to find the active config by name
        try {
          final activeConfig = _configs.firstWhere(
            (config) => config.name == configName,
          );
          _activeConfig = activeConfig;
          AppLogger.i(
              'ScheduleController: Loaded active config from settings: ${activeConfig.name}');
          notifyListeners();
          return;
        } catch (e) {
          // If config not found, fallback to first config only if we have settings
          if (_configs.isNotEmpty) {
            _activeConfig = _configs.first;
            // Save this as the active config
            await _saveActiveConfig(_activeConfig!.name);
            AppLogger.i(
                'ScheduleController: Config not found in settings, using first config: ${_activeConfig!.name}');
            notifyListeners();
            return;
          }
        }
      } else {
        // No settings or no active config name - this is likely first setup
        // Don't automatically set a config, let the user choose
        AppLogger.i(
            'ScheduleController: No active config in settings, waiting for user selection (first setup)');
        _activeConfig = null;
        notifyListeners();
        return;
      }
    } catch (e, stackTrace) {
      AppLogger.e(
          'ScheduleController: Error loading active config', e, stackTrace);
      // Don't set a fallback config on error during first setup
      _activeConfig = null;
      notifyListeners();
    }
  }

  Future<void> _loadMyDutyGroup([Settings? settings]) async {
    try {
      final currentSettings = settings ?? await getSettingsUseCase.execute();
      if (currentSettings != null && currentSettings.myDutyGroup != null) {
        _myDutyGroup = currentSettings.myDutyGroup;
        notifyListeners();
      }
    } catch (e, stackTrace) {
      AppLogger.e(
          'ScheduleController: Error loading my duty group', e, stackTrace);
    }
  }

  Future<void> _loadSelectedAndFocusedDay([Settings? settings]) async {
    try {
      // Always use current date for selected and focused day
      final now = DateTime.now();
      _selectedDay = now;
      _focusedDay = now;
      notifyListeners();
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

  Future<void> _loadCalendarFormat([Settings? settings]) async {
    try {
      final currentSettings = settings ?? await getSettingsUseCase.execute();
      if (currentSettings != null) {
        _calendarFormat = currentSettings.calendarFormat;
        // Migrate old format if necessary
        await _migrateCalendarFormatIfNeeded(currentSettings);
      }
    } catch (e, stackTrace) {
      AppLogger.e(
          'ScheduleController: Error loading calendar format', e, stackTrace);
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
      await _validateMyDutyGroup();

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

  Future<void> _validateMyDutyGroup() async {
    if (_myDutyGroup != null && _activeConfig != null) {
      final availableGroups =
          _activeConfig!.dutyGroups.map((group) => group.name).toList();
      if (!availableGroups.contains(_myDutyGroup)) {
        // My duty group is not available in new config, reset it
        _myDutyGroup = null;
        await _saveMyDutyGroup(null);
        notifyListeners();
      }
    }
  }

  Future<void> _saveActiveConfig(String configName) async {
    try {
      final currentSettings = await getSettingsUseCase.execute();
      if (currentSettings != null &&
          currentSettings.activeConfigName != configName) {
        AppLogger.i(
            'ScheduleController: Active config changed, saving settings');
        final updatedSettings = currentSettings.copyWith(
          activeConfigName: configName,
        );
        await saveSettingsUseCase.execute(updatedSettings);
      } else {
        AppLogger.d(
            'ScheduleController: Active config unchanged, skipping save');
      }
    } catch (e, stackTrace) {
      AppLogger.e(
          'ScheduleController: Error saving active config', e, stackTrace);
    }
  }

  Future<void> _migrateCalendarFormatIfNeeded(Settings settings) async {
    try {
      // Check if the calendar format was saved with the old toString() method
      // If so, we need to migrate it to use the name property
      final currentSettings = await getSettingsUseCase.execute();
      if (currentSettings != null) {
        // Only save if the format actually changed or needs migration
        if (currentSettings.calendarFormat != _calendarFormat) {
          AppLogger.i(
              'ScheduleController: Calendar format changed, saving settings');
          await _saveCalendarFormat();
        } else {
          AppLogger.d(
              'ScheduleController: Calendar format unchanged, skipping save');
        }
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
      if (settings != null && settings.calendarFormat != _calendarFormat) {
        AppLogger.i(
            'ScheduleController: Calendar format changed, saving settings');
        final updatedSettings = settings.copyWith(
          calendarFormat: _calendarFormat,
        );
        await saveSettingsUseCase.execute(updatedSettings);
      } else {
        AppLogger.d(
            'ScheduleController: Calendar format unchanged, skipping save');
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

      final generatedSchedules = await generateSchedulesUseCase.execute(
        configName: configName,
        startDate: startDate,
        endDate: endDate,
      );

      // Merge generated schedules with existing ones
      final existingSchedules = _schedules
          .where((schedule) => schedule.configName != configName)
          .toList();

      // Remove duplicates by using a map with date+configName as key
      final scheduleMap = <String, Schedule>{};

      // Add existing schedules
      for (final schedule in existingSchedules) {
        final key =
            '${schedule.date.toIso8601String()}_${schedule.configName}_${schedule.dutyGroupId}';
        scheduleMap[key] = schedule;
      }

      // Add generated schedules (will overwrite duplicates)
      for (final schedule in generatedSchedules) {
        final key =
            '${schedule.date.toIso8601String()}_${schedule.configName}_${schedule.dutyGroupId}';
        scheduleMap[key] = schedule;
      }

      _schedules = scheduleMap.values.toList();

      AppLogger.i(
          'ScheduleController: Merged generated schedules - existing: ${existingSchedules.length}, generated: ${generatedSchedules.length}, total: ${_schedules.length}');
      AppLogger.i(
          'ScheduleController: Schedules for active config after merge: ${_schedules.where((s) => s.configName == configName).length}');
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
        // Use the same range as _loadSchedulesForCurrentMonth (±3 months)
        final startDate =
            DateTime(_selectedDay!.year, _selectedDay!.month - 3, 1);
        final endDate =
            DateTime(_selectedDay!.year, _selectedDay!.month + 4, 0);
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
    } else if (_focusedDay != null) {
      // If we have a focused day but no active config, still try to load schedules
      await _loadSchedulesForCurrentMonth(_focusedDay!);
    } else if (_activeConfig != null) {
      // If we have an active config but no focused day, use current date
      final now = DateTime.now();
      await _loadSchedulesForCurrentMonth(now);
    } else {
      // If we have neither, use current date and try to load anyway
      final now = DateTime.now();
      await _loadSchedulesForCurrentMonth(now);
    }
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
      AppLogger.i(
          'ScheduleController: Current configs count: ${_configs.length}');
      AppLogger.i(
          'ScheduleController: Current active config: ${_activeConfig?.name}');

      final settings = await getSettingsUseCase.execute();
      final configName = settings?.activeConfigName;

      AppLogger.i(
          'ScheduleController: Active config name from settings: $configName');

      if (configName != null && configName.isNotEmpty && _configs.isNotEmpty) {
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
      } else if (_configs.isNotEmpty) {
        // If no active config name in settings but we have configs, use the first one
        if (_activeConfig == null || !_configs.contains(_activeConfig)) {
          AppLogger.i(
              'ScheduleController: No active config in settings, using first available config: ${_configs.first.name}');
          _activeConfig = _configs.first;
          notifyListeners();
        }
      } else {
        AppLogger.w(
            'ScheduleController: No configs available to set as active');
        AppLogger.w(
            'ScheduleController: Configs list is empty, skipping active config refresh');
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

      // Store current state before refreshing
      final previousActiveConfig = _activeConfig?.name;
      final previousFocusedDay = _focusedDay;
      final previousSelectedDay = _selectedDay;

      // Refresh active config from settings to ensure consistency
      await _refreshActiveConfigFromSettings();

      // Load preferred duty group from settings to ensure consistency
      await _loadMyDutyGroup();

      // Check if any relevant settings have changed
      final activeConfigChanged = previousActiveConfig != _activeConfig?.name;
      final focusedDayChanged = previousFocusedDay?.year != _focusedDay?.year ||
          previousFocusedDay?.month != _focusedDay?.month ||
          previousFocusedDay?.day != _focusedDay?.day;
      final selectedDayChanged =
          previousSelectedDay?.year != _selectedDay?.year ||
              previousSelectedDay?.month != _selectedDay?.month ||
              previousSelectedDay?.day != _selectedDay?.day;

      // Only reload schedules if relevant settings have changed
      final relevantSettingsChanged =
          activeConfigChanged || focusedDayChanged || selectedDayChanged;

      if (relevantSettingsChanged) {
        AppLogger.i(
            'ScheduleController: Relevant settings changed, reloading schedules');
        AppLogger.i(
            'ScheduleController: Changes - activeConfig: $activeConfigChanged, focusedDay: $focusedDayChanged, selectedDay: $selectedDayChanged');

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
      } else {
        AppLogger.i(
            'ScheduleController: No relevant settings changed, skipping schedule reload');
        // Still notify listeners for UI updates (e.g., preferred duty group changes)
        notifyListeners();
      }

      AppLogger.i('ScheduleController: Refresh after settings close completed');
    } catch (e, stackTrace) {
      AppLogger.e('ScheduleController: Error refreshing after settings close',
          e, stackTrace);
    }
  }

  /// Get settings cache statistics for debugging
  Map<String, dynamic> getSettingsCacheStatistics() {
    return SettingsCache.cacheStatistics;
  }
}
