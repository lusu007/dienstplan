import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dienstplan/presentation/state/schedule_data/schedule_data_ui_state.dart';
import 'package:dienstplan/domain/use_cases/get_schedules_use_case.dart';
import 'package:dienstplan/domain/use_cases/generate_schedules_use_case.dart';
import 'package:dienstplan/domain/use_cases/ensure_month_schedules_use_case.dart';
import 'package:dienstplan/domain/use_cases/get_settings_use_case.dart';
import 'package:dienstplan/domain/use_cases/save_settings_use_case.dart';
import 'package:dienstplan/domain/policies/date_range_policy.dart';
import 'package:dienstplan/domain/services/schedule_merge_service.dart';
import 'package:dienstplan/domain/value_objects/date_range.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/domain/failures/failure.dart';
import 'package:dienstplan/domain/entities/schedule.dart';

part 'schedule_data_notifier.g.dart';

@riverpod
class ScheduleDataNotifier extends _$ScheduleDataNotifier {
  GetSchedulesUseCase? _getSchedulesUseCase;
  GenerateSchedulesUseCase? _generateSchedulesUseCase;
  EnsureMonthSchedulesUseCase? _ensureMonthSchedulesUseCase;
  GetSettingsUseCase? _getSettingsUseCase;
  SaveSettingsUseCase? _saveSettingsUseCase;
  DateRangePolicy? _dateRangePolicy;
  ScheduleMergeService? _scheduleMergeService;

  @override
  Future<ScheduleDataUiState> build() async {
    _getSchedulesUseCase ??= await ref.read(getSchedulesUseCaseProvider.future);
    _generateSchedulesUseCase ??= await ref.read(
      generateSchedulesUseCaseProvider.future,
    );
    _ensureMonthSchedulesUseCase ??= await ref.read(
      ensureMonthSchedulesUseCaseProvider.future,
    );
    _getSettingsUseCase ??= await ref.read(getSettingsUseCaseProvider.future);
    _saveSettingsUseCase ??= await ref.read(saveSettingsUseCaseProvider.future);
    _dateRangePolicy ??= ref.read(dateRangePolicyProvider);
    _scheduleMergeService ??= ref.read(scheduleMergeServiceProvider);
    return await _initialize();
  }

  Future<ScheduleDataUiState> _initialize() async {
    try {
      final settingsResult = await _getSettingsUseCase!.executeSafe();
      final settings = settingsResult.isSuccess ? settingsResult.value : null;

      final activeConfigName = settings?.activeConfigName;
      final preferredDutyGroup = settings?.myDutyGroup;

      List<Schedule> schedules = [];
      if (activeConfigName != null) {
        final DateTime now = DateTime.now();
        final DateRange initialRange = _dateRangePolicy!.computeInitialRange(
          now,
        );

        final schedulesResult = await _getSchedulesUseCase!
            .executeForDateRangeSafe(
              startDate: initialRange.start,
              endDate: initialRange.end,
              configName: activeConfigName,
            );

        if (schedulesResult.isSuccess) {
          schedules = schedulesResult.value;
        } else {
          final message = await _presentFailure(schedulesResult.failure);
          return ScheduleDataUiState(
            isLoading: false,
            error: message,
            schedules: const <Schedule>[],
            activeConfigName: activeConfigName,
            preferredDutyGroup: preferredDutyGroup,
          );
        }
      }

      return ScheduleDataUiState(
        isLoading: false,
        error: null,
        schedules: schedules,
        activeConfigName: activeConfigName ?? '',
        preferredDutyGroup: preferredDutyGroup ?? '',
      );
    } catch (e) {
      return ScheduleDataUiState.initial().copyWith(
        error: 'Failed to initialize schedule data',
      );
    }
  }

  Future<void> loadSchedulesForDateRange({
    required DateTime startDate,
    required DateTime endDate,
    required String configName,
  }) async {
    final current = await future;
    state = AsyncData(current.copyWith(isLoading: true));

    try {
      final schedulesResult = await _getSchedulesUseCase!
          .executeForDateRangeSafe(
            startDate: startDate,
            endDate: endDate,
            configName: configName,
          );

      if (schedulesResult.isSuccess) {
        final newSchedules = schedulesResult.value;
        // Create a date range for the incoming schedules
        final incomingDates = newSchedules.map((s) => s.date).toList();
        final minDate = incomingDates.reduce((a, b) => a.isBefore(b) ? a : b);
        final maxDate = incomingDates.reduce((a, b) => a.isAfter(b) ? a : b);
        final range = DateRange(start: minDate, end: maxDate);

        final mergedSchedules = _scheduleMergeService!.mergeOutsideRange(
          existing: current.schedules,
          incoming: newSchedules,
          range: range,
        );

        state = AsyncData(
          current.copyWith(
            schedules: mergedSchedules,
            activeConfigName: configName,
            isLoading: false,
          ),
        );
      } else {
        final message = await _presentFailure(schedulesResult.failure);
        state = AsyncData(current.copyWith(error: message, isLoading: false));
      }
    } catch (e) {
      state = AsyncData(
        current.copyWith(error: 'Failed to load schedules', isLoading: false),
      );
    }
  }

  Future<void> generateSchedulesForMonth({
    required DateTime month,
    required String configName,
  }) async {
    final current = await future;
    state = AsyncData(current.copyWith(isLoading: true));

    try {
      await _generateSchedulesUseCase!.execute(
        startDate: DateTime(month.year, month.month, 1),
        endDate: DateTime(month.year, month.month + 1, 0),
        configName: configName,
      );

      // Reload schedules for the month
      final startDate = DateTime(month.year, month.month, 1);
      final endDate = DateTime(month.year, month.month + 1, 0);

      await loadSchedulesForDateRange(
        startDate: startDate,
        endDate: endDate,
        configName: configName,
      );
    } catch (e) {
      state = AsyncData(
        current.copyWith(
          error: 'Failed to generate schedules',
          isLoading: false,
        ),
      );
    }
  }

  Future<void> ensureMonthSchedules({
    required DateTime month,
    required String configName,
  }) async {
    final current = await future;

    try {
      await _ensureMonthSchedulesUseCase!.execute(
        monthStart: month,
        configName: configName,
      );

      // Reload schedules for the month
      final startDate = DateTime(month.year, month.month, 1);
      final endDate = DateTime(month.year, month.month + 1, 0);

      await loadSchedulesForDateRange(
        startDate: startDate,
        endDate: endDate,
        configName: configName,
      );
    } catch (e) {
      state = AsyncData(
        current.copyWith(error: 'Failed to ensure month schedules'),
      );
    }
  }

  Future<void> setSelectedDutyGroup(String dutyGroup) async {
    final current = await future;
    state = AsyncData(current.copyWith(selectedDutyGroup: dutyGroup));
  }

  Future<void> clearError() async {
    final current = await future;
    state = AsyncData(current.copyWith(error: null));
  }

  Future<String> _presentFailure(Failure failure) async {
    // This would need to be implemented based on your failure presentation logic
    // For now, return a simple error message
    return 'An error occurred: ${failure.toString()}';
  }
}
