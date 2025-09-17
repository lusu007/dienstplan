import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dienstplan/presentation/state/settings/settings_ui_state.dart';
import 'package:dienstplan/domain/use_cases/get_settings_use_case.dart';
import 'package:dienstplan/domain/use_cases/save_settings_use_case.dart';
import 'package:dienstplan/domain/use_cases/reset_settings_use_case.dart';
import 'package:dienstplan/domain/entities/settings.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/state/schedule_data/schedule_data_notifier.dart';
import 'dart:async';
part 'settings_notifier.g.dart';

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  GetSettingsUseCase? _getSettingsUseCase;
  SaveSettingsUseCase? _saveSettingsUseCase;
  ResetSettingsUseCase? _resetSettingsUseCase;

  @override
  Future<SettingsUiState> build() async {
    _getSettingsUseCase ??= await ref.read(getSettingsUseCaseProvider.future);
    _saveSettingsUseCase ??= await ref.read(saveSettingsUseCaseProvider.future);
    _resetSettingsUseCase ??= await ref.read(
      resetSettingsUseCaseProvider.future,
    );
    final loaded = await _load();
    return loaded;
  }

  Future<SettingsUiState> _load() async {
    state = const AsyncLoading();
    try {
      final settings = await _getSettingsUseCase!.execute();
      return SettingsUiState(
        isLoading: false,
        language: settings?.language,
        calendarFormat: settings?.calendarFormat,
        activeConfigName: settings?.activeConfigName,
        myDutyGroup: settings?.myDutyGroup,
        themePreference: settings?.themePreference ?? ThemePreference.system,
        partnerConfigName: settings?.partnerConfigName,
        partnerDutyGroup: settings?.partnerDutyGroup,
        partnerAccentColorValue: settings?.partnerAccentColorValue,
        myAccentColorValue: settings?.myAccentColorValue,
        holidayAccentColorValue: settings?.holidayAccentColorValue,
      );
    } catch (e) {
      return SettingsUiState.initial().copyWith(
        error: 'Failed to load settings',
      );
    }
  }

  Future<void> setLanguage(String language) async {
    final current = state.value ?? SettingsUiState.initial();
    state = AsyncData(current.copyWith(language: language));
    final existing = await _getSettingsUseCase!.execute();
    if (existing != null) {
      await _saveSettings(existing.copyWith(language: language));
    } else {
      // Create new settings with the language if none exist
      final newSettings = Settings(
        calendarFormat: CalendarFormat.month,
        language: language,
        themePreference: ThemePreference.system,
        schoolHolidayStateCode: null,
        showSchoolHolidays: null,
      );
      await _saveSettings(newSettings);
    }
  }

  Future<void> setThemePreference(ThemePreference preference) async {
    final current = state.value ?? SettingsUiState.initial();
    // Update UI immediately
    state = AsyncData(current.copyWith(themePreference: preference));

    // Save in background without blocking UI
    unawaited(_saveThemePreferenceInBackground(preference));
  }

  Future<void> _saveThemePreferenceInBackground(
    ThemePreference preference,
  ) async {
    try {
      final existing = await _getSettingsUseCase!.execute();
      if (existing != null) {
        await _saveSettings(existing.copyWith(themePreference: preference));
      } else {
        // Create new settings with the theme preference if none exist
        final newSettings = Settings(
          calendarFormat: CalendarFormat.month,
          themePreference: preference,
        );
        await _saveSettings(newSettings);
      }
    } catch (e) {
      // Silently handle errors for background saves
      // The UI state is already updated, so we don't need to revert
    }
  }

  Future<void> setCalendarFormat(CalendarFormat format) async {
    final current = state.value ?? SettingsUiState.initial();
    state = AsyncData(current.copyWith(calendarFormat: format));
    final existing = await _getSettingsUseCase!.execute();
    if (existing != null) {
      await _saveSettings(existing.copyWith(calendarFormat: format));
    } else {
      // Create new settings with the calendar format if none exist
      final newSettings = Settings(
        calendarFormat: format,
        themePreference: ThemePreference.system,
      );
      await _saveSettings(newSettings);
    }
    // Update schedule notifier calendar format without full invalidation
    final scheduleNotifier = ref.read(scheduleCoordinatorProvider.notifier);
    await scheduleNotifier.updateCalendarFormatOnly(format);
  }

  Future<void> setActiveConfigName(String name) async {
    final current = state.value ?? SettingsUiState.initial();
    state = AsyncData(current.copyWith(activeConfigName: name));
    final existing = await _getSettingsUseCase!.execute();
    if (existing != null) {
      await _saveSettings(existing.copyWith(activeConfigName: name));
    } else {
      // Create new settings with the active config if none exist
      final newSettings = Settings(
        calendarFormat: CalendarFormat.month,
        activeConfigName: name,
        themePreference: ThemePreference.system,
        schoolHolidayStateCode: null,
        showSchoolHolidays: null,
      );
      await _saveSettings(newSettings);
    }
  }

  Future<void> setMyDutyGroup(String? group) async {
    final current = state.value ?? SettingsUiState.initial();
    state = AsyncData(current.copyWith(myDutyGroup: group));
    final existing = await _getSettingsUseCase!.execute();
    if (existing != null) {
      await _saveSettings(existing.copyWith(myDutyGroup: group));
    } else {
      // Create new settings with the duty group if none exist
      final newSettings = Settings(
        calendarFormat: CalendarFormat.month,
        myDutyGroup: group,
        themePreference: ThemePreference.system,
        schoolHolidayStateCode: null,
        showSchoolHolidays: null,
      );
      await _saveSettings(newSettings);
    }
  }

  Future<void> reset() async {
    try {
      await _resetSettingsUseCase!.execute();
      // Ensure all theme consumers recompute after reset
      ref.invalidate(themeModeProvider);
      state = AsyncData(await _load());
    } catch (_) {
      final current = state.value ?? SettingsUiState.initial();
      state = AsyncData(current.copyWith(error: 'Failed to reset settings'));
    }
  }

  Future<void> setHolidayAccentColor(int? colorValue) async {
    final current = state.value ?? SettingsUiState.initial();
    state = AsyncData(current.copyWith(holidayAccentColorValue: colorValue));
    final existing = await _getSettingsUseCase!.execute();
    if (existing != null) {
      await _saveSettings(
        existing.copyWith(holidayAccentColorValue: colorValue),
      );
    } else {
      // Create new settings with the holiday accent color if none exist
      final newSettings = Settings(
        calendarFormat: CalendarFormat.month,
        holidayAccentColorValue: colorValue,
        themePreference: ThemePreference.system,
        schoolHolidayStateCode: null,
        showSchoolHolidays: null,
      );
      await _saveSettings(newSettings);
    }

    // Refresh the schedule data provider and coordinator to update the holiday color in the calendar
    // Do this after the settings are saved
    try {
      // Force refresh the schedule data provider to get the updated holiday color
      final _ = await ref.refresh(scheduleDataProvider.future);
      // Also refresh the coordinator to ensure the calendar updates
      ref.invalidate(scheduleCoordinatorProvider);
    } catch (e) {
      // If refresh fails, fall back to invalidation
      ref.invalidate(scheduleDataProvider);
      ref.invalidate(scheduleCoordinatorProvider);
    }
  }

  Future<void> _saveSettings(Settings settings) async {
    try {
      await _saveSettingsUseCase!.execute(settings);
    } catch (_) {
      final current = state.value ?? SettingsUiState.initial();
      state = AsyncData(current.copyWith(error: 'Failed to save settings'));
    }
  }
}
