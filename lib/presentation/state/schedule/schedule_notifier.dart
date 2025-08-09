import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_ui_state.dart';
import 'package:dienstplan/domain/use_cases/get_schedules_use_case.dart';
import 'package:dienstplan/domain/use_cases/generate_schedules_use_case.dart';
import 'package:dienstplan/domain/use_cases/get_configs_use_case.dart';
import 'package:dienstplan/domain/use_cases/set_active_config_use_case.dart';
import 'package:dienstplan/domain/use_cases/get_settings_use_case.dart';
import 'package:dienstplan/domain/use_cases/save_settings_use_case.dart';

import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/domain/entities/schedule.dart';

class ScheduleNotifier extends AsyncNotifier<ScheduleUiState> {
  GetSchedulesUseCase? _getSchedulesUseCase;
  GenerateSchedulesUseCase? _generateSchedulesUseCase;
  GetConfigsUseCase? _getConfigsUseCase;
  SetActiveConfigUseCase? _setActiveConfigUseCase;
  GetSettingsUseCase? _getSettingsUseCase;
  SaveSettingsUseCase? _saveSettingsUseCase;

  @override
  Future<ScheduleUiState> build() async {
    _getSchedulesUseCase ??=
        await GetIt.instance.getAsync<GetSchedulesUseCase>();
    _generateSchedulesUseCase ??=
        await GetIt.instance.getAsync<GenerateSchedulesUseCase>();
    _getConfigsUseCase ??= await GetIt.instance.getAsync<GetConfigsUseCase>();
    _setActiveConfigUseCase ??=
        await GetIt.instance.getAsync<SetActiveConfigUseCase>();
    _getSettingsUseCase ??= await GetIt.instance.getAsync<GetSettingsUseCase>();
    _saveSettingsUseCase ??=
        await GetIt.instance.getAsync<SaveSettingsUseCase>();
    return await _initialize();
  }

  Future<ScheduleUiState> _initialize() async {
    state = const AsyncLoading();
    try {
      final now = DateTime.now();
      final settings = await _getSettingsUseCase!.execute();
      final configs = await _getConfigsUseCase!.execute();
      final activeName = settings?.activeConfigName ??
          (configs.isNotEmpty ? configs.first.name : null);
      final format = settings?.calendarFormat ?? CalendarFormat.month;
      final selected = now;
      final focused = now;
      List<Schedule> schedules = [];
      if (activeName != null) {
        // Load initial range: current month ±3
        final DateTime start = DateTime(now.year, now.month - 3, 1);
        final DateTime end = DateTime(now.year, now.month + 4, 0);
        schedules = await _getSchedulesUseCase!.executeForDateRange(
          startDate: start,
          endDate: end,
          configName: activeName,
        );
        // Ensure prev/curr/next of current month have valid schedules for active config
        final List<DateTime> monthsToEnsure = <DateTime>[
          DateTime(now.year, now.month - 1, 1),
          DateTime(now.year, now.month, 1),
          DateTime(now.year, now.month + 1, 1),
        ];
        final List<Schedule> initialGeneratedSchedules = <Schedule>[];
        for (final DateTime month in monthsToEnsure) {
          final DateTime monthEnd = DateTime(month.year, month.month + 1, 0);
          if (!_hasValidSchedulesForMonth(schedules, month, activeName)) {
            // Generate missing month for active config
            final List<Schedule> generated =
                await _generateSchedulesUseCase!.execute(
              configName: activeName,
              startDate: month,
              endDate: monthEnd,
            );
            initialGeneratedSchedules.addAll(generated);
          }
        }
        if (initialGeneratedSchedules.isNotEmpty) {
          schedules =
              <Schedule>{...schedules, ...initialGeneratedSchedules}.toList();
        }
      }
      return ScheduleUiState(
        isLoading: false,
        error: null,
        selectedDay: selected,
        focusedDay: focused,
        calendarFormat: format,
        schedules: schedules,
        activeConfigName: activeName,
        preferredDutyGroup: settings?.myDutyGroup,
        dutyGroups: _extractDutyGroups(configs, activeName),
        configs: configs,
        activeConfig: configs.firstWhere(
          (c) => c.name == activeName,
          orElse: () => configs.isNotEmpty ? configs.first : configs.first,
        ),
      );
    } catch (e) {
      return ScheduleUiState.initial()
          .copyWith(error: 'Failed to load schedules');
    }
  }

  List<String> _extractDutyGroups(
      List<DutyScheduleConfig> configs, String? activeName) {
    if (activeName == null) {
      return const <String>[];
    }
    DutyScheduleConfig? config;
    for (final c in configs) {
      if (c.name == activeName) {
        config = c;
        break;
      }
    }
    if (config == null) {
      return const <String>[];
    }
    return config.dutyGroups.map((g) => g.name).toList(growable: false);
  }

  bool _hasValidSchedulesForMonth(
      List<Schedule> schedules, DateTime monthStart, String activeConfigName) {
    final DateTime monthEnd =
        DateTime(monthStart.year, monthStart.month + 1, 0);

    for (final Schedule s in schedules) {
      final bool inMonth =
          s.date.isAfter(monthStart.subtract(const Duration(days: 1))) &&
              s.date.isBefore(monthEnd.add(const Duration(days: 1)));
      if (inMonth &&
          s.configName == activeConfigName &&
          s.dutyTypeId.isNotEmpty &&
          s.dutyTypeId != '-') {
        return true;
      }
    }
    return false;
  }

  Future<void> setFocusedDay(DateTime day) async {
    final current = state.valueOrNull ?? ScheduleUiState.initial();

    // Set loading state while fetching new schedules
    state = AsyncData(current.copyWith(isLoading: true, focusedDay: day));

    // Load range around new month for active config
    final activeName = current.activeConfigName;
    if (activeName != null && activeName.isNotEmpty) {
      try {
        // Calculate range for focused month ±3
        final focusedStart = DateTime(day.year, day.month - 3, 1);
        final focusedEnd = DateTime(day.year, day.month + 4, 0);

        // Calculate range for selected day ±3 (if exists)
        final selectedDay = current.selectedDay;
        DateTime start = focusedStart;
        DateTime end = focusedEnd;

        if (selectedDay != null) {
          final selectedStart =
              DateTime(selectedDay.year, selectedDay.month - 3, 1);
          final selectedEnd =
              DateTime(selectedDay.year, selectedDay.month + 4, 0);

          // Combine both ranges (take earliest start and latest end)
          start = focusedStart.isBefore(selectedStart)
              ? focusedStart
              : selectedStart;
          end = focusedEnd.isAfter(selectedEnd) ? focusedEnd : selectedEnd;
        }

        // First try to load existing schedules
        var allSchedules = await _getSchedulesUseCase!.executeForDateRange(
          startDate: start,
          endDate: end,
          configName: activeName,
        );

        // Check if we need to generate schedules for the focused month specifically
        final focusedMonthStart = DateTime(day.year, day.month, 1);

        // Ensure focused, previous and next months exist (generate only when empty or without valid items for active config)
        Future<void> ensureMonthGenerated(
            DateTime monthStart, String activeConfigName) async {
          final DateTime monthEnd =
              DateTime(monthStart.year, monthStart.month + 1, 0);

          // Check if month actually has schedules in UI state (not just allSchedules)
          final currentStateSchedules = current.schedules
              .where((s) =>
                  s.date.year == monthStart.year &&
                  s.date.month == monthStart.month &&
                  s.configName == activeConfigName &&
                  s.dutyTypeId.isNotEmpty &&
                  s.dutyTypeId != '-')
              .length;

          // Generate if UI state is missing schedules (regardless of allSchedules)
          if (currentStateSchedules == 0) {
            final List<Schedule> generated =
                await _generateSchedulesUseCase!.execute(
              configName: activeConfigName,
              startDate: monthStart,
              endDate: monthEnd,
            );
            allSchedules.addAll(generated);
          }
        }

        // Generate current month and 3 months into the future in parallel using isolate
        await Future.wait([
          ensureMonthGenerated(focusedMonthStart, activeName),
          ensureMonthGenerated(
              DateTime(day.year, day.month + 1, 1), activeName),
          ensureMonthGenerated(
              DateTime(day.year, day.month + 2, 1), activeName),
          ensureMonthGenerated(
              DateTime(day.year, day.month + 3, 1), activeName),
        ]);

        // Update state with new schedules and clear loading
        // Merge with existing schedules to avoid losing data
        final existingSchedules = current.schedules.toList();
        final mergedSchedules = <Schedule>[];

        // Add existing schedules that are not in the new range
        for (final existing in existingSchedules) {
          final isInNewRange =
              existing.date.isAfter(start.subtract(const Duration(days: 1))) &&
                  existing.date.isBefore(end.add(const Duration(days: 1)));
          if (!isInNewRange) {
            mergedSchedules.add(existing);
          }
        }

        // Add new schedules, avoiding duplicates
        for (final newSchedule in allSchedules) {
          final exists = mergedSchedules.any((s) =>
              s.date.year == newSchedule.date.year &&
              s.date.month == newSchedule.date.month &&
              s.date.day == newSchedule.date.day &&
              s.dutyGroupName == newSchedule.dutyGroupName);
          if (!exists) {
            mergedSchedules.add(newSchedule);
          }
        }

        // Update state with new schedules
        final newState = current.copyWith(
          schedules: mergedSchedules,
          focusedDay: day,
          isLoading: false,
        );
        state = AsyncData(newState);
      } catch (e) {
        // Handle error and clear loading state
        state = AsyncData(current.copyWith(
          error: 'Failed to load schedules for ${day.year}-${day.month}',
          isLoading: false,
        ));
      }
    } else {
      // No active config, just update focused day
      state = AsyncData(current.copyWith(
        focusedDay: day,
        isLoading: false,
      ));
    }
  }

  Future<void> setSelectedDay(DateTime? day) async {
    final current = state.valueOrNull ?? ScheduleUiState.initial();
    state = AsyncData(current.copyWith(selectedDay: day));

    // If a day is selected and we have an active config, ensure its schedules are loaded
    if (day != null) {
      final activeName = current.activeConfigName;
      if (activeName != null && activeName.isNotEmpty) {
        final currentSchedules = current.schedules;
        final hasSelectedDaySchedules = currentSchedules.any((s) =>
            s.date.year == day.year &&
            s.date.month == day.month &&
            s.date.day == day.day);

        // If selected day schedules are not loaded, load them
        if (!hasSelectedDaySchedules) {
          try {
            // Load selected day ±3 range
            final start = DateTime(day.year, day.month - 3, 1);
            final end = DateTime(day.year, day.month + 4, 0);

            // First try to load existing schedules
            List<Schedule> newSchedules =
                await _getSchedulesUseCase!.executeForDateRange(
              startDate: start,
              endDate: end,
              configName: activeName,
            );

            // Ensure selected day is present; if not, generate month data
            final monthStart = DateTime(day.year, day.month, 1);
            final monthEnd = DateTime(day.year, day.month + 1, 0);
            final hasSelectedInLoaded = newSchedules.any((s) =>
                s.date.year == day.year &&
                s.date.month == day.month &&
                s.date.day == day.day);

            if (newSchedules.isEmpty || !hasSelectedInLoaded) {
              final generated = await _generateSchedulesUseCase!.execute(
                configName: activeName,
                startDate: monthStart,
                endDate: monthEnd,
              );
              newSchedules = [...newSchedules, ...generated];
            }

            // Merge with existing schedules, avoiding duplicates
            final existingSchedules = currentSchedules.toList();
            for (final schedule in newSchedules) {
              final exists = existingSchedules.any((s) =>
                  s.date.year == schedule.date.year &&
                  s.date.month == schedule.date.month &&
                  s.date.day == schedule.date.day &&
                  s.dutyGroupName == schedule.dutyGroupName);
              if (!exists) {
                existingSchedules.add(schedule);
              }
            }

            state = AsyncData(
              (state.valueOrNull ?? current).copyWith(
                schedules: existingSchedules,
                selectedDay: day,
              ),
            );
          } catch (e) {
            // Handle error but don't break the UI
            state = AsyncData(
              (state.valueOrNull ?? current).copyWith(
                error: 'Failed to load schedules for selected day',
                selectedDay: day,
              ),
            );
          }
        }
      }
    }
  }

  Future<void> setCalendarFormat(CalendarFormat format) async {
    final current = state.valueOrNull ?? ScheduleUiState.initial();
    state = AsyncData(current.copyWith(calendarFormat: format));
    final existing = await _getSettingsUseCase!.execute();
    if (existing != null) {
      await _saveSettingsUseCase!
          .execute(existing.copyWith(calendarFormat: format));
    }
  }

  Future<void> setActiveConfig(DutyScheduleConfig config) async {
    final current = state.valueOrNull ?? ScheduleUiState.initial();
    state = AsyncData(current.copyWith(isLoading: true));
    try {
      await _setActiveConfigUseCase!.execute(config.name);
      final updated = current.copyWith(
        isLoading: false,
        activeConfigName: config.name,
        dutyGroups: config.dutyGroups.map((g) => g.name).toList(),
        activeConfig: config,
      );
      state = AsyncData(updated);

      // Load schedules for the new config
      final now = DateTime.now();
      final start = DateTime(now.year, now.month - 3, 1);
      final end = DateTime(now.year, now.month + 4, 0);

      // First try to load existing schedules
      List<Schedule> schedules =
          await _getSchedulesUseCase!.executeForDateRange(
        startDate: start,
        endDate: end,
        configName: config.name,
      );

      // If no schedules found, generate them
      if (schedules.isEmpty) {
        schedules = await _generateSchedulesUseCase!.execute(
          configName: config.name,
          startDate: start,
          endDate: end,
        );
      }

      state = AsyncData(updated.copyWith(schedules: schedules));

      // Save settings
      final existing = await _getSettingsUseCase!.execute();
      if (existing != null) {
        await _saveSettingsUseCase!.execute(
          existing.copyWith(activeConfigName: config.name),
        );
      }
    } catch (_) {
      state = AsyncData(current.copyWith(error: 'Failed to set active config'));
    }
  }

  Future<void> setPreferredDutyGroup(String? group) async {
    final current = state.valueOrNull ?? ScheduleUiState.initial();
    state = AsyncData(current.copyWith(preferredDutyGroup: group));
    final existing = await _getSettingsUseCase!.execute();
    if (existing != null) {
      await _saveSettingsUseCase!
          .execute(existing.copyWith(myDutyGroup: group));
    }
  }

  void setSelectedDutyGroup(String? group) {
    final current = state.valueOrNull ?? ScheduleUiState.initial();
    state = AsyncData(current.copyWith(selectedDutyGroup: group));
  }

  Future<void> goToToday() async {
    final now = DateTime.now();

    // Set loading state
    final current = state.valueOrNull ?? ScheduleUiState.initial();
    state = AsyncData(current.copyWith(isLoading: true));

    try {
      // Set selected day to today
      await setSelectedDay(DateTime(now.year, now.month, now.day));

      // Set focused day to current month
      await setFocusedDay(DateTime(now.year, now.month, 1));

      // Clear loading state
      state =
          AsyncData((state.valueOrNull ?? current).copyWith(isLoading: false));
    } catch (e) {
      // Handle error and clear loading state
      state = AsyncData(current.copyWith(
        error: 'Failed to go to today',
        isLoading: false,
      ));
    }
  }
}

final scheduleNotifierProvider =
    AsyncNotifierProvider<ScheduleNotifier, ScheduleUiState>(
  ScheduleNotifier.new,
);
