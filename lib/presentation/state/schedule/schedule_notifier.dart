import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_ui_state.dart';
import 'package:dienstplan/domain/use_cases/get_schedules_use_case.dart';
import 'package:dienstplan/domain/use_cases/generate_schedules_use_case.dart';
import 'package:dienstplan/domain/use_cases/ensure_month_schedules_use_case.dart';
import 'package:dienstplan/domain/policies/date_range_policy.dart';
import 'package:dienstplan/domain/services/schedule_merge_service.dart';
import 'package:dienstplan/domain/value_objects/date_range.dart';
import 'package:dienstplan/domain/use_cases/get_configs_use_case.dart';
import 'package:dienstplan/domain/use_cases/set_active_config_use_case.dart';
import 'package:dienstplan/domain/use_cases/get_settings_use_case.dart';
import 'package:dienstplan/domain/use_cases/save_settings_use_case.dart';

import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
part 'schedule_notifier.g.dart';

@Riverpod(keepAlive: true)
class ScheduleNotifier extends _$ScheduleNotifier {
  GetSchedulesUseCase? _getSchedulesUseCase;
  GenerateSchedulesUseCase? _generateSchedulesUseCase;
  GetConfigsUseCase? _getConfigsUseCase;
  SetActiveConfigUseCase? _setActiveConfigUseCase;
  GetSettingsUseCase? _getSettingsUseCase;
  SaveSettingsUseCase? _saveSettingsUseCase;
  EnsureMonthSchedulesUseCase? _ensureMonthSchedulesUseCase;
  DateRangePolicy? _dateRangePolicy;
  ScheduleMergeService? _scheduleMergeService;

  @override
  Future<ScheduleUiState> build() async {
    _getSchedulesUseCase ??= await ref.read(getSchedulesUseCaseProvider.future);
    _generateSchedulesUseCase ??=
        await ref.read(generateSchedulesUseCaseProvider.future);
    _getConfigsUseCase ??= await ref.read(getConfigsUseCaseProvider.future);
    _setActiveConfigUseCase ??=
        await ref.read(setActiveConfigUseCaseProvider.future);
    _getSettingsUseCase ??= await ref.read(getSettingsUseCaseProvider.future);
    _saveSettingsUseCase ??= await ref.read(saveSettingsUseCaseProvider.future);
    _ensureMonthSchedulesUseCase ??=
        await ref.read(ensureMonthSchedulesUseCaseProvider.future);
    _dateRangePolicy ??= ref.read(dateRangePolicyProvider);
    _scheduleMergeService ??= ref.read(scheduleMergeServiceProvider);
    return await _initialize();
  }

  Future<ScheduleUiState> _initialize() async {
    state = const AsyncLoading();
    try {
      final DateTime now = DateTime.now();
      final settings = await _getSettingsUseCase!.execute();
      final configs = await _getConfigsUseCase!.execute();
      final activeName = settings?.activeConfigName ??
          (configs.isNotEmpty ? configs.first.name : null);
      final format = settings?.calendarFormat ?? CalendarFormat.month;
      final selected = now;
      final focused = now;
      List<Schedule> schedules = [];
      if (activeName != null) {
        final DateRange initialRange =
            _dateRangePolicy!.computeInitialRange(now);
        schedules = await _getSchedulesUseCase!.executeForDateRange(
          startDate: initialRange.start,
          endDate: initialRange.end,
          configName: activeName,
        );
        final List<DateTime> monthsToEnsure = <DateTime>[
          DateTime(now.year, now.month - 1, 1),
          DateTime(now.year, now.month, 1),
          DateTime(now.year, now.month + 1, 1),
        ];
        final List<Schedule> ensured = <Schedule>[];
        for (final DateTime monthStart in monthsToEnsure) {
          final List<Schedule> ensuredMonth =
              await _ensureMonthSchedulesUseCase!.execute(
            configName: activeName,
            monthStart: monthStart,
          );
          ensured.addAll(ensuredMonth);
        }
        if (ensured.isNotEmpty) {
          schedules = _scheduleMergeService!
              .deduplicate(<Schedule>[...schedules, ...ensured]);
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

  // Validation moved into use case

  Future<void> setFocusedDay(DateTime day) async {
    final current = state.valueOrNull ?? ScheduleUiState.initial();

    // Set loading state while fetching new schedules
    state = AsyncData(current.copyWith(isLoading: true, focusedDay: day));

    // Load range around new month for active config
    final activeName = current.activeConfigName;
    if (activeName != null && activeName.isNotEmpty) {
      try {
        final DateRange focusedRange =
            _dateRangePolicy!.computeFocusedRange(day);

        // Calculate range for selected day ±3 (if exists)
        final selectedDay = current.selectedDay;
        DateRange combinedRange = focusedRange;

        if (selectedDay != null) {
          final DateRange selectedRange =
              _dateRangePolicy!.computeSelectedRange(selectedDay);
          combinedRange = DateRange.union(focusedRange, selectedRange);
        }

        // First try to load existing schedules
        final initialSchedules =
            await _getSchedulesUseCase!.executeForDateRange(
          startDate: combinedRange.start,
          endDate: combinedRange.end,
          configName: activeName,
        );
        final List<Schedule> allSchedules = <Schedule>[...initialSchedules];

        // Check if we need to generate schedules for the focused month specifically
        final focusedMonthStart = DateTime(day.year, day.month, 1);

        // Ensure focused, previous and next months exist (generate only when empty or without valid items for active config)
        Future<void> ensureMonthGenerated(DateTime monthStart) async {
          final List<Schedule> ensured =
              await _ensureMonthSchedulesUseCase!.execute(
            configName: activeName,
            monthStart: monthStart,
          );
          allSchedules.addAll(ensured);
        }

        // Generate current month and 3 months into the future in parallel using isolate
        await Future.wait(<Future<void>>[
          ensureMonthGenerated(focusedMonthStart),
          ensureMonthGenerated(DateTime(day.year, day.month + 1, 1)),
          ensureMonthGenerated(DateTime(day.year, day.month + 2, 1)),
          ensureMonthGenerated(DateTime(day.year, day.month + 3, 1)),
        ]);

        // Update state with new schedules and clear loading
        // Merge with existing schedules to avoid losing data
        final List<Schedule> existingSchedules = current.schedules.toList();
        final List<Schedule> mergedSchedules =
            _scheduleMergeService!.mergeOutsideRange(
          existing: existingSchedules,
          incoming: allSchedules,
          range: combinedRange,
        );

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
            final DateRange selectedRange =
                _dateRangePolicy!.computeSelectedRange(day);

            // First try to load existing schedules
            List<Schedule> newSchedules =
                await _getSchedulesUseCase!.executeForDateRange(
              startDate: selectedRange.start,
              endDate: selectedRange.end,
              configName: activeName,
            );

            // Ensure selected day is present; if not, generate month data
            final DateTime monthStart = DateTime(day.year, day.month, 1);
            final hasSelectedInLoaded = newSchedules.any((s) =>
                s.date.year == day.year &&
                s.date.month == day.month &&
                s.date.day == day.day);

            if (newSchedules.isEmpty || !hasSelectedInLoaded) {
              final List<Schedule> ensured =
                  await _ensureMonthSchedulesUseCase!.execute(
                configName: activeName,
                monthStart: monthStart,
              );
              newSchedules = <Schedule>[...newSchedules, ...ensured];
            }

            final List<Schedule> existingSchedules = currentSchedules.toList();
            final DateRange mergeRange = selectedRange;
            final List<Schedule> merged =
                _scheduleMergeService!.mergeOutsideRange(
              existing: existingSchedules,
              incoming: newSchedules,
              range: mergeRange,
            );

            state = AsyncData(
              (state.valueOrNull ?? current).copyWith(
                schedules: merged,
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
      final DateTime now = DateTime.now();
      final DateRange range = _dateRangePolicy!.computeInitialRange(now);

      // First try to load existing schedules
      List<Schedule> schedules =
          await _getSchedulesUseCase!.executeForDateRange(
        startDate: range.start,
        endDate: range.end,
        configName: config.name,
      );

      // If no schedules found, generate them
      if (schedules.isEmpty) {
        schedules = await _generateSchedulesUseCase!.execute(
          configName: config.name,
          startDate: range.start,
          endDate: range.end,
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
