import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_ui_state.dart';
import 'package:dienstplan/domain/use_cases/get_schedules_use_case.dart';
import 'package:dienstplan/domain/use_cases/generate_schedules_use_case.dart';
import 'package:dienstplan/domain/use_cases/ensure_month_schedules_use_case.dart';
import 'package:dienstplan/domain/policies/date_range_policy.dart';
import 'package:dienstplan/domain/services/schedule_merge_service.dart';
import 'package:dienstplan/domain/services/config_query_service.dart';
import 'package:dienstplan/domain/value_objects/date_range.dart';
import 'package:dienstplan/domain/use_cases/get_configs_use_case.dart';
import 'package:dienstplan/domain/use_cases/set_active_config_use_case.dart';
import 'package:dienstplan/domain/use_cases/get_settings_use_case.dart';
import 'package:dienstplan/domain/use_cases/save_settings_use_case.dart';
import 'package:dienstplan/core/constants/schedule_constants.dart';
import 'package:dienstplan/core/errors/failure_presenter.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/domain/failures/failure.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:flutter/material.dart';

import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
part 'schedule_notifier.g.dart';

@riverpod
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
  ConfigQueryService? _configQueryService;

  @override
  Future<ScheduleUiState> build() async {
    _getSchedulesUseCase ??= await ref.read(getSchedulesUseCaseProvider.future);
    _generateSchedulesUseCase ??= await ref.read(
      generateSchedulesUseCaseProvider.future,
    );
    _getConfigsUseCase ??= await ref.read(getConfigsUseCaseProvider.future);
    _setActiveConfigUseCase ??= await ref.read(
      setActiveConfigUseCaseProvider.future,
    );
    _getSettingsUseCase ??= await ref.read(getSettingsUseCaseProvider.future);
    _saveSettingsUseCase ??= await ref.read(saveSettingsUseCaseProvider.future);
    _ensureMonthSchedulesUseCase ??= await ref.read(
      ensureMonthSchedulesUseCaseProvider.future,
    );
    _dateRangePolicy ??= ref.read(dateRangePolicyProvider);
    _scheduleMergeService ??= ref.read(scheduleMergeServiceProvider);
    _configQueryService ??= ref.read(configQueryServiceProvider);
    return await _initialize();
  }

  Future<ScheduleUiState> _initialize() async {
    state = const AsyncLoading();
    try {
      final DateTime now = DateTime.now();
      final settingsResult = await _getSettingsUseCase!.executeSafe();
      final settings = settingsResult.isSuccess ? settingsResult.value : null;
      final configs = await _getConfigsUseCase!.execute();
      final activeName =
          settings?.activeConfigName ??
          (configs.isNotEmpty ? configs.first.name : null);
      final format = settings?.calendarFormat ?? CalendarFormat.month;
      final selected = now;
      final focused = now;
      List<Schedule> schedules = [];
      if (activeName != null) {
        final DateRange initialRange = _dateRangePolicy!.computeInitialRange(
          now,
        );
        final schedulesResult = await _getSchedulesUseCase!
            .executeForDateRangeSafe(
              startDate: initialRange.start,
              endDate: initialRange.end,
              configName: activeName,
            );
        if (schedulesResult.isFailure) {
          final message = await _presentFailure(schedulesResult.failure);
          return ScheduleUiState(
            isLoading: false,
            error: message,
            selectedDay: selected,
            focusedDay: focused,
            calendarFormat: format,
            schedules: const <Schedule>[],
            activeConfigName: activeName,
            preferredDutyGroup: settings?.myDutyGroup,
            dutyGroups: _configQueryService!.extractDutyGroups(
              configs,
              activeName,
            ),
            configs: configs,
            activeConfig: configs.isNotEmpty ? configs.first : null,
            partnerConfigName: settings?.partnerConfigName,
            partnerDutyGroup: settings?.partnerDutyGroup,
            partnerAccentColorValue: settings?.partnerAccentColorValue,
            myAccentColorValue: settings?.myAccentColorValue,
          );
        }
        schedules = schedulesResult.value;
        final List<DateTime> monthsToEnsure = <DateTime>[
          for (
            int i = -kInitialEnsureMonthsRadius;
            i <= kInitialEnsureMonthsRadius;
            i++
          )
            DateTime(now.year, now.month + i, 1),
        ];
        final List<Future<List<Schedule>>> ensureFutures =
            <Future<List<Schedule>>>[
              for (final DateTime monthStart in monthsToEnsure)
                _ensureMonthSchedulesUseCase!.execute(
                  configName: activeName,
                  monthStart: monthStart,
                ),
            ];
        final List<List<Schedule>> ensuredChunks = await Future.wait(
          ensureFutures,
        );
        final List<Schedule> ensured = <Schedule>[
          for (final List<Schedule> chunk in ensuredChunks) ...chunk,
        ];
        if (ensured.isNotEmpty) {
          schedules = _scheduleMergeService!.deduplicate(<Schedule>[
            ...schedules,
            ...ensured,
          ]);
        }

        // Load partner config schedules if configured
        final String? partnerConfig = settings?.partnerConfigName;
        if (partnerConfig != null && partnerConfig.isNotEmpty) {
          final partnerResult = await _getSchedulesUseCase!
              .executeForDateRangeSafe(
                startDate: initialRange.start,
                endDate: initialRange.end,
                configName: partnerConfig,
              );
          if (partnerResult.isSuccess) {
            schedules = _scheduleMergeService!.deduplicate(<Schedule>[
              ...schedules,
              ...partnerResult.value,
            ]);
          }
          // Ensure partner months too
          final List<Future<List<Schedule>>> ensurePartnerFutures =
              <Future<List<Schedule>>>[
                for (final DateTime monthStart in monthsToEnsure)
                  _ensureMonthSchedulesUseCase!.execute(
                    configName: partnerConfig,
                    monthStart: monthStart,
                  ),
              ];
          final List<List<Schedule>> ensuredPartnerChunks = await Future.wait(
            ensurePartnerFutures,
          );
          final List<Schedule> ensuredPartner = <Schedule>[
            for (final List<Schedule> chunk in ensuredPartnerChunks) ...chunk,
          ];
          if (ensuredPartner.isNotEmpty) {
            schedules = _scheduleMergeService!.deduplicate(<Schedule>[
              ...schedules,
              ...ensuredPartner,
            ]);
          }
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
        dutyGroups: _configQueryService!.extractDutyGroups(configs, activeName),
        configs: configs,
        activeConfig: _configQueryService!.selectActiveConfig(
          configs,
          activeName,
        ),
        partnerConfigName: settings?.partnerConfigName,
        partnerDutyGroup: settings?.partnerDutyGroup,
        partnerAccentColorValue: settings?.partnerAccentColorValue,
        myAccentColorValue: settings?.myAccentColorValue,
      );
    } catch (e) {
      return ScheduleUiState.initial().copyWith(
        error: 'Failed to load schedules',
      );
    }
  }

  Future<void> _ensureActiveConfigInState() async {
    final ScheduleUiState current = state.value ?? ScheduleUiState.initial();
    final String? existingActive = current.activeConfigName;
    if (existingActive != null && existingActive.isNotEmpty) {
      return;
    }
    try {
      final settingsResult = await _getSettingsUseCase!.executeSafe();
      final settings = settingsResult.isSuccess ? settingsResult.value : null;
      final configs = await _getConfigsUseCase!.execute();
      final String? activeName =
          settings?.activeConfigName ??
          (configs.isNotEmpty ? configs.first.name : null);
      if (activeName != null && activeName.isNotEmpty) {
        final updated = (state.value ?? current).copyWith(
          activeConfigName: activeName,
          activeConfig: _configQueryService!.selectActiveConfig(
            configs,
            activeName,
          ),
          dutyGroups: _configQueryService!.extractDutyGroups(
            configs,
            activeName,
          ),
        );
        state = AsyncData(updated);
      }
    } catch (_) {
      // Ignore; active config will be set later
    }
  }

  // Validation moved into use case

  /// Loads schedules for an expanded date range when user scrolls beyond current data
  Future<void> loadSchedulesForExpandedRange({
    required DateTimeRange currentRange,
    required DateTime targetDate,
    required String configName,
  }) async {
    final current = state.value ?? ScheduleUiState.initial();
    if (!ref.mounted) return;

    // Check if we already have data for the target date
    final hasDataForTarget = current.schedules.any(
      (schedule) =>
          schedule.date.year == targetDate.year &&
          schedule.date.month == targetDate.month &&
          schedule.configName == configName,
    );

    if (hasDataForTarget) return; // Already have data, no need to load

    try {
      // Calculate the expanded range needed
      final DateRange expandedRange = _dateRangePolicy!.computeExpandedRange(
        currentRange,
        targetDate,
      );

      // Load schedules for the expanded range
      final schedulesResult = await _getSchedulesUseCase!
          .executeForDateRangeSafe(
            startDate: expandedRange.start,
            endDate: expandedRange.end,
            configName: configName,
          );

      if (!ref.mounted) return;

      if (schedulesResult.isSuccess) {
        final newSchedules = schedulesResult.value;

        // Merge with existing schedules
        final List<Schedule> existingSchedules = current.schedules.toList();
        final List<Schedule> mergedSchedules = _scheduleMergeService!
            .mergeOutsideRange(
              existing: existingSchedules,
              incoming: newSchedules,
              range: DateRange(
                start: expandedRange.start,
                end: expandedRange.end,
              ),
            );

        state = AsyncData(
          current.copyWith(schedules: mergedSchedules, isLoading: false),
        );
      }
    } catch (e) {
      AppLogger.e('ScheduleNotifier: Error loading expanded range', e);
      // Don't update state on error for background loading
    }
  }

  Future<void> setFocusedDay(DateTime day, {bool shouldLoad = true}) async {
    final current = state.value ?? ScheduleUiState.initial();

    if (!shouldLoad) {
      state = AsyncData(current.copyWith(focusedDay: day));
      return;
    }

    // Set loading state while fetching new schedules
    state = AsyncData(current.copyWith(isLoading: true, focusedDay: day));

    // Load range around new month for active config
    final activeName = current.activeConfigName;
    if (activeName != null && activeName.isNotEmpty) {
      try {
        final DateRange focusedRange = _dateRangePolicy!.computeFocusedRange(
          day,
        );

        // Calculate range for selected day ±3 (if exists)
        final selectedDay = current.selectedDay;
        DateRange combinedRange = focusedRange;

        if (selectedDay != null) {
          final DateRange selectedRange = _dateRangePolicy!
              .computeSelectedRange(selectedDay);
          combinedRange = DateRange.union(focusedRange, selectedRange);
        }

        // First try to load existing schedules (safe)
        final initialResult = await _getSchedulesUseCase!
            .executeForDateRangeSafe(
              startDate: combinedRange.start,
              endDate: combinedRange.end,
              configName: activeName,
            );
        if (initialResult.isFailure) {
          final message = await _presentFailure(initialResult.failure);
          state = AsyncData(current.copyWith(isLoading: false, error: message));
          return;
        }
        final List<Schedule> allSchedules = <Schedule>[...initialResult.value];

        // Also load partner config schedules for the same range
        final String? partnerConfig =
            (state.value ?? current).partnerConfigName;
        if (partnerConfig != null && partnerConfig.isNotEmpty) {
          final partnerResult = await _getSchedulesUseCase!
              .executeForDateRangeSafe(
                startDate: combinedRange.start,
                endDate: combinedRange.end,
                configName: partnerConfig,
              );
          if (partnerResult.isSuccess) {
            allSchedules.addAll(partnerResult.value);
          }
        }

        // Ensure focused, previous and next months exist (generate only when empty or without valid items for active config)
        Future<void> ensureMonthGenerated(DateTime monthStart) async {
          final List<Schedule> ensured = await _ensureMonthSchedulesUseCase!
              .execute(configName: activeName, monthStart: monthStart);
          allSchedules.addAll(ensured);
        }

        // Generate focused month and next N months in parallel using isolate
        await Future.wait(<Future<void>>[
          for (int i = 0; i <= kMonthsPrefetchRadius; i++)
            ensureMonthGenerated(DateTime(day.year, day.month + i, 1)),
        ]);

        // Ensure partner months as well
        if (partnerConfig != null && partnerConfig.isNotEmpty) {
          Future<void> ensurePartnerMonthGenerated(DateTime monthStart) async {
            final List<Schedule> ensured = await _ensureMonthSchedulesUseCase!
                .execute(configName: partnerConfig, monthStart: monthStart);
            allSchedules.addAll(ensured);
          }

          await Future.wait(<Future<void>>[
            for (int i = 0; i <= kMonthsPrefetchRadius; i++)
              ensurePartnerMonthGenerated(DateTime(day.year, day.month + i, 1)),
          ]);
        }

        // Update state with new schedules and clear loading
        // Merge with existing schedules to avoid losing data
        final List<Schedule> existingSchedules = current.schedules.toList();
        final List<Schedule> mergedSchedules = _scheduleMergeService!
            .mergeOutsideRange(
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
        state = AsyncData(
          current.copyWith(
            error: 'Failed to load schedules for ${day.year}-${day.month}',
            isLoading: false,
          ),
        );
      }
    } else {
      // No active config, just update focused day
      state = AsyncData(current.copyWith(focusedDay: day, isLoading: false));
    }
  }

  Future<void> setSelectedDay(DateTime? day) async {
    final current = state.value ?? ScheduleUiState.initial();
    state = AsyncData(current.copyWith(selectedDay: day));

    // If a day is selected and we have an active config, ensure its schedules are loaded
    if (day != null) {
      final activeName = current.activeConfigName;
      if (activeName != null && activeName.isNotEmpty) {
        final currentSchedules = current.schedules;
        final hasSelectedDaySchedules = currentSchedules.any(
          (s) =>
              s.date.year == day.year &&
              s.date.month == day.month &&
              s.date.day == day.day,
        );

        // If selected day schedules are not loaded, load them
        if (!hasSelectedDaySchedules) {
          try {
            final DateRange selectedRange = _dateRangePolicy!
                .computeSelectedRange(day);

            // First try to load existing schedules (safe)
            final selectedResult = await _getSchedulesUseCase!
                .executeForDateRangeSafe(
                  startDate: selectedRange.start,
                  endDate: selectedRange.end,
                  configName: activeName,
                );
            if (selectedResult.isFailure) {
              final message = await _presentFailure(selectedResult.failure);
              state = AsyncData(
                (state.value ?? current).copyWith(
                  error: message,
                  selectedDay: day,
                ),
              );
              return;
            }
            List<Schedule> newSchedules = selectedResult.value;

            // Also load partner schedules for selected range
            final String? partnerConfig =
                (state.value ?? current).partnerConfigName;
            if (partnerConfig != null && partnerConfig.isNotEmpty) {
              final partnerResult = await _getSchedulesUseCase!
                  .executeForDateRangeSafe(
                    startDate: selectedRange.start,
                    endDate: selectedRange.end,
                    configName: partnerConfig,
                  );
              if (partnerResult.isSuccess) {
                newSchedules = <Schedule>[
                  ...newSchedules,
                  ...partnerResult.value,
                ];
              }
            }

            // Ensure selected day is present; if not, generate month data
            final DateTime monthStart = DateTime(day.year, day.month, 1);
            final hasSelectedInLoaded = newSchedules.any(
              (s) =>
                  s.date.year == day.year &&
                  s.date.month == day.month &&
                  s.date.day == day.day,
            );

            if (newSchedules.isEmpty || !hasSelectedInLoaded) {
              final List<Schedule> ensured = await _ensureMonthSchedulesUseCase!
                  .execute(configName: activeName, monthStart: monthStart);
              newSchedules = <Schedule>[...newSchedules, ...ensured];
              // Ensure partner month as well
              final String? partnerConfig =
                  (state.value ?? current).partnerConfigName;
              if (partnerConfig != null && partnerConfig.isNotEmpty) {
                final List<Schedule> ensuredPartner =
                    await _ensureMonthSchedulesUseCase!.execute(
                      configName: partnerConfig,
                      monthStart: monthStart,
                    );
                newSchedules = <Schedule>[...newSchedules, ...ensuredPartner];
              }
            }

            final List<Schedule> existingSchedules = currentSchedules.toList();
            final DateRange mergeRange = selectedRange;
            final List<Schedule> merged = _scheduleMergeService!
                .mergeOutsideRange(
                  existing: existingSchedules,
                  incoming: newSchedules,
                  range: mergeRange,
                );

            state = AsyncData(
              (state.value ?? current).copyWith(
                schedules: merged,
                selectedDay: day,
              ),
            );
          } catch (e) {
            // Handle error but don't break the UI
            state = AsyncData(
              (state.value ?? current).copyWith(
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
    final current = state.value ?? ScheduleUiState.initial();
    state = AsyncData(current.copyWith(calendarFormat: format));
    final settingsResult = await _getSettingsUseCase!.executeSafe();
    final existing = settingsResult.isSuccess ? settingsResult.value : null;
    if (existing != null) {
      await _saveSettingsUseCase!.executeSafe(
        existing.copyWith(calendarFormat: format),
      );
    }
  }

  Future<void> updateCalendarFormatOnly(CalendarFormat format) async {
    final current = state.value ?? ScheduleUiState.initial();
    state = AsyncData(current.copyWith(calendarFormat: format));
  }

  Future<void> setActiveConfig(DutyScheduleConfig config) async {
    final current = state.value ?? ScheduleUiState.initial();
    state = AsyncData(current.copyWith(isLoading: true));
    try {
      final setResult = await _setActiveConfigUseCase!.executeSafe(config.name);
      if (setResult.isFailure) {
        final message = await _presentFailure(setResult.failure);
        state = AsyncData(current.copyWith(isLoading: false, error: message));
        return;
      }
      final updated = current.copyWith(
        isLoading: false,
        activeConfigName: config.name,
        dutyGroups: _configQueryService!.extractDutyGroups(<DutyScheduleConfig>[
          config,
        ], config.name),
        activeConfig: config,
      );
      state = AsyncData(updated);

      // Load schedules for the new config
      final DateTime now = DateTime.now();
      final DateRange range = _dateRangePolicy!.computeInitialRange(now);

      // First try to load existing schedules (safe)
      final schedulesResult = await _getSchedulesUseCase!
          .executeForDateRangeSafe(
            startDate: range.start,
            endDate: range.end,
            configName: config.name,
          );
      List<Schedule> schedules = <Schedule>[];
      if (schedulesResult.isSuccess) {
        schedules = schedulesResult.value;
      } else {
        final message = await _presentFailure(schedulesResult.failure);
        state = AsyncData(current.copyWith(isLoading: false, error: message));
        return;
      }

      // If no schedules found, generate them
      if (schedules.isEmpty) {
        schedules = await _generateSchedulesUseCase!.execute(
          configName: config.name,
          startDate: range.start,
          endDate: range.end,
        );
      }

      state = AsyncData(updated.copyWith(schedules: schedules));

      // Save settings (safe)
      final settingsResult = await _getSettingsUseCase!.executeSafe();
      final existing = settingsResult.isSuccess ? settingsResult.value : null;
      if (existing != null) {
        final saveResult = await _saveSettingsUseCase!.executeSafe(
          existing.copyWith(activeConfigName: config.name),
        );
        if (saveResult.isFailure) {
          final message = await _presentFailure(saveResult.failure);
          state = AsyncData(current.copyWith(isLoading: false, error: message));
          return;
        }
      }
    } catch (_) {
      state = AsyncData(current.copyWith(error: 'Failed to set active config'));
    }
  }

  Future<void> setPreferredDutyGroup(String? group) async {
    final current = state.value ?? ScheduleUiState.initial();
    state = AsyncData(current.copyWith(preferredDutyGroup: group));
    final settingsResult = await _getSettingsUseCase!.executeSafe();
    final existing = settingsResult.isSuccess ? settingsResult.value : null;
    if (existing != null) {
      await _saveSettingsUseCase!.executeSafe(
        existing.copyWith(myDutyGroup: group),
      );
    }
  }

  Future<void> setPartnerConfigName(
    String? configName, {
    bool silent = false,
  }) async {
    final current = state.value ?? ScheduleUiState.initial();
    final bool isClearing = (configName == null || configName.isEmpty);
    state = AsyncData(
      current.copyWith(
        partnerConfigName: configName,
        partnerDutyGroup: isClearing ? null : current.partnerDutyGroup,
      ),
    );
    final settingsResult = await _getSettingsUseCase!.executeSafe();
    final existing = settingsResult.isSuccess ? settingsResult.value : null;
    if (existing != null) {
      final updated = existing.copyWith(
        partnerConfigName: configName,
        partnerDutyGroup: isClearing ? null : existing.partnerDutyGroup,
      );
      await _saveSettingsUseCase!.executeSafe(updated);
    }
    if (silent) {
      // Only update settings and state fields; avoid heavy loads
      return;
    }
    // Sequence strictly: 1) ensure active selected day, 2) ensure active focused range, 3) ensure partner focused range
    final DateTime dayToEnsure =
        (state.value?.selectedDay ?? current.selectedDay) ??
        (state.value?.focusedDay ?? current.focusedDay) ??
        DateTime.now();
    await _ensureActiveConfigInState();
    await ensureActiveDay(dayToEnsure);
    // Trigger immediate rebuild
    state = AsyncData((state.value ?? current).copyWith());
    // Optionally bump focused day to force visible cell rebuilds
    final DateTime? focused = (state.value ?? current).focusedDay;
    if (focused != null) {
      await setFocusedDay(focused);
    }
    await _ensureActiveDataForFocusedRange();
    await _ensurePartnerDataForFocusedRange();
  }

  Future<void> setPartnerDutyGroup(String? group, {bool silent = false}) async {
    final current = state.value ?? ScheduleUiState.initial();
    state = AsyncData(current.copyWith(partnerDutyGroup: group));
    final settingsResult = await _getSettingsUseCase!.executeSafe();
    final existing = settingsResult.isSuccess ? settingsResult.value : null;
    if (existing != null) {
      await _saveSettingsUseCase!.executeSafe(
        existing.copyWith(partnerDutyGroup: group),
      );
    }
    if (silent) {
      // Only update settings and state fields; avoid heavy loads
      return;
    }
    // Sequence strictly: 1) ensure active selected day, 2) ensure active focused range, 3) ensure partner focused range
    final DateTime dayToEnsure =
        (state.value?.selectedDay ?? current.selectedDay) ??
        (state.value?.focusedDay ?? current.focusedDay) ??
        DateTime.now();
    await _ensureActiveConfigInState();
    await ensureActiveDay(dayToEnsure);
    // Trigger immediate rebuild
    state = AsyncData((state.value ?? current).copyWith());
    // Optionally bump focused day to force visible cell rebuilds
    final DateTime? focused = (state.value ?? current).focusedDay;
    if (focused != null) {
      await setFocusedDay(focused);
    }
    await _ensureActiveDataForFocusedRange();
    await _ensurePartnerDataForFocusedRange();
  }

  Future<void> setPartnerAccentColor(int? colorValue) async {
    final current = state.value ?? ScheduleUiState.initial();
    state = AsyncData(current.copyWith(partnerAccentColorValue: colorValue));
    final settingsResult = await _getSettingsUseCase!.executeSafe();
    final existing = settingsResult.isSuccess ? settingsResult.value : null;
    if (existing != null) {
      await _saveSettingsUseCase!.executeSafe(
        existing.copyWith(partnerAccentColorValue: colorValue),
      );
    }
  }

  Future<void> setMyAccentColor(int? colorValue) async {
    final current = state.value ?? ScheduleUiState.initial();
    state = AsyncData(current.copyWith(myAccentColorValue: colorValue));
    final settingsResult = await _getSettingsUseCase!.executeSafe();
    final existing = settingsResult.isSuccess ? settingsResult.value : null;
    if (existing != null) {
      await _saveSettingsUseCase!.executeSafe(
        existing.copyWith(myAccentColorValue: colorValue),
      );
    }
  }

  Future<void> applyPartnerSelectionChanges() async {
    final ScheduleUiState current = state.value ?? ScheduleUiState.initial();
    await _ensureActiveConfigInState();
    final DateTime dayToEnsure =
        (state.value?.selectedDay ?? current.selectedDay) ??
        (state.value?.focusedDay ?? current.focusedDay) ??
        DateTime.now();
    await ensureActiveDay(dayToEnsure);
    state = AsyncData((state.value ?? current).copyWith());
    final DateTime? focused = (state.value ?? current).focusedDay;
    if (focused != null) {
      await setFocusedDay(focused, shouldLoad: false);
    }
    await _ensureActiveDataForFocusedRange();
    await _ensurePartnerDataForFocusedRange();
  }

  Future<void> _ensurePartnerDataForFocusedRange() async {
    final current = state.value ?? ScheduleUiState.initial();
    final String? partnerConfig = current.partnerConfigName;
    if (partnerConfig == null || partnerConfig.isEmpty) return;

    try {
      final DateTime focused = current.focusedDay ?? DateTime.now();
      final DateRange focusedRange = _dateRangePolicy!.computeFocusedRange(
        focused,
      );
      final DateTime? selected = current.selectedDay;
      DateRange combinedRange = focusedRange;
      if (selected != null) {
        final DateRange selectedRange = _dateRangePolicy!.computeSelectedRange(
          selected,
        );
        combinedRange = DateRange.union(focusedRange, selectedRange);
      }

      // Load partner schedules for combined range
      final partnerResult = await _getSchedulesUseCase!.executeForDateRangeSafe(
        startDate: combinedRange.start,
        endDate: combinedRange.end,
        configName: partnerConfig,
      );
      if (partnerResult.isFailure) return;

      // Also ensure partner months around the focused period so data exists
      final List<Schedule> allPartner = <Schedule>[...partnerResult.value];
      Future<void> ensurePartnerMonth(DateTime monthStart) async {
        final List<Schedule> ensured = await _ensureMonthSchedulesUseCase!
            .execute(configName: partnerConfig, monthStart: monthStart);
        if (ensured.isNotEmpty) {
          allPartner.addAll(ensured);
        }
      }

      await Future.wait(<Future<void>>[
        for (int i = 0; i <= kMonthsPrefetchRadius; i++)
          ensurePartnerMonth(DateTime(focused.year, focused.month + i, 1)),
      ]);

      final List<Schedule> existingNow =
          (state.value?.schedules ?? current.schedules).toList();
      final List<Schedule> merged = _scheduleMergeService!
          .mergeReplacingConfigInRange(
            existing: existingNow,
            incoming: allPartner,
            range: combinedRange,
            replaceConfigName: partnerConfig,
          );

      state = AsyncData((state.value ?? current).copyWith(schedules: merged));
    } catch (_) {
      // Silent fail; UI remains functional
    }
  }

  Future<void> _ensureActiveDataForFocusedRange() async {
    final current = state.value ?? ScheduleUiState.initial();
    final String? activeName = current.activeConfigName;
    if (activeName == null || activeName.isEmpty) return;

    try {
      final DateTime focused = current.focusedDay ?? DateTime.now();
      final DateRange focusedRange = _dateRangePolicy!.computeFocusedRange(
        focused,
      );
      final DateTime? selected = current.selectedDay;
      DateRange combinedRange = focusedRange;
      if (selected != null) {
        final DateRange selectedRange = _dateRangePolicy!.computeSelectedRange(
          selected,
        );
        combinedRange = DateRange.union(focusedRange, selectedRange);
      }

      final activeResult = await _getSchedulesUseCase!.executeForDateRangeSafe(
        startDate: combinedRange.start,
        endDate: combinedRange.end,
        configName: activeName,
      );
      if (activeResult.isFailure) return;

      final List<Schedule> allActive = <Schedule>[...activeResult.value];
      Future<void> ensureActiveMonth(DateTime monthStart) async {
        final List<Schedule> ensured = await _ensureMonthSchedulesUseCase!
            .execute(configName: activeName, monthStart: monthStart);
        if (ensured.isNotEmpty) {
          allActive.addAll(ensured);
        }
      }

      await Future.wait(<Future<void>>[
        for (int i = 0; i <= kMonthsPrefetchRadius; i++)
          ensureActiveMonth(DateTime(focused.year, focused.month + i, 1)),
      ]);

      final List<Schedule> existingNow =
          (state.value?.schedules ?? current.schedules).toList();
      final List<Schedule> merged = _scheduleMergeService!
          .mergeReplacingConfigInRange(
            existing: existingNow,
            incoming: allActive,
            range: combinedRange,
            replaceConfigName: activeName,
          );

      state = AsyncData((state.value ?? current).copyWith(schedules: merged));
    } catch (_) {
      // Silent fail; UI remains functional
    }
  }

  Future<void> ensureActiveDay(DateTime day) async {
    final current = state.value ?? ScheduleUiState.initial();
    await _ensureActiveConfigInState();
    final String? activeName = (state.value ?? current).activeConfigName;
    if (activeName == null || activeName.isEmpty) return;

    // If we already have any schedule for that day and active config, skip
    final bool hasDay = current.schedules.any(
      (s) =>
          s.configName == activeName &&
          s.date.year == day.year &&
          s.date.month == day.month &&
          s.date.day == day.day,
    );
    if (hasDay) return;

    try {
      final DateRange selectedRange = _dateRangePolicy!.computeSelectedRange(
        day,
      );
      final result = await _getSchedulesUseCase!.executeForDateRangeSafe(
        startDate: selectedRange.start,
        endDate: selectedRange.end,
        configName: activeName,
      );
      if (result.isFailure) return;

      List<Schedule> incoming = result.value;

      // If still missing that day, ensure the month
      final bool hasInIncoming = incoming.any(
        (s) =>
            s.date.year == day.year &&
            s.date.month == day.month &&
            s.date.day == day.day,
      );
      if (!hasInIncoming) {
        final List<Schedule> ensured = await _ensureMonthSchedulesUseCase!
            .execute(
              configName: activeName,
              monthStart: DateTime(day.year, day.month, 1),
            );
        incoming = <Schedule>[...incoming, ...ensured];
      }

      final List<Schedule> merged = _scheduleMergeService!
          .mergeReplacingConfigInRange(
            existing: (state.value?.schedules ?? current.schedules).toList(),
            incoming: incoming,
            range: selectedRange,
            replaceConfigName: activeName,
          );
      state = AsyncData((state.value ?? current).copyWith(schedules: merged));
    } catch (_) {
      // ignore errors
    }
  }

  void setSelectedDutyGroup(String? group) {
    final current = state.value ?? ScheduleUiState.initial();
    state = AsyncData(current.copyWith(selectedDutyGroup: group));
  }

  Future<String> _presentFailure(Failure failure) async {
    final languageService = await ref.read(languageServiceProvider.future);
    final l10n = lookupAppLocalizations(languageService.currentLocale);
    return const FailurePresenter().present(failure, l10n);
  }

  Future<void> goToToday() async {
    final now = DateTime.now();

    // Set loading state
    final current = state.value ?? ScheduleUiState.initial();
    state = AsyncData(current.copyWith(isLoading: true));

    try {
      // Set selected day to today
      await setSelectedDay(DateTime(now.year, now.month, now.day));

      // Set focused day to current month
      await setFocusedDay(DateTime(now.year, now.month, 1));

      // Clear loading state
      state = AsyncData((state.value ?? current).copyWith(isLoading: false));
    } catch (e) {
      // Handle error and clear loading state
      state = AsyncData(
        current.copyWith(error: 'Failed to go to today', isLoading: false),
      );
    }
  }
}
