import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dienstplan/presentation/state/settings/settings_ui_state.dart';
import 'package:dienstplan/domain/use_cases/get_settings_use_case.dart';
import 'package:dienstplan/domain/use_cases/save_settings_use_case.dart';
import 'package:dienstplan/domain/use_cases/reset_settings_use_case.dart';
import 'package:dienstplan/domain/entities/settings.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
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
    _resetSettingsUseCase ??=
        await ref.read(resetSettingsUseCaseProvider.future);
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
      );
    } catch (e) {
      return SettingsUiState.initial()
          .copyWith(error: 'Failed to load settings');
    }
  }

  Future<void> setLanguage(String language) async {
    final current = state.valueOrNull ?? SettingsUiState.initial();
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
      );
      await _saveSettings(newSettings);
    }
  }

  Future<void> setThemePreference(ThemePreference preference) async {
    final current = state.valueOrNull ?? SettingsUiState.initial();
    // Update UI immediately
    state = AsyncData(current.copyWith(themePreference: preference));

    // Save in background without blocking UI
    unawaited(_saveThemePreferenceInBackground(preference));
  }

  Future<void> _saveThemePreferenceInBackground(
      ThemePreference preference) async {
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
    final current = state.valueOrNull ?? SettingsUiState.initial();
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
  }

  Future<void> setActiveConfigName(String name) async {
    final current = state.valueOrNull ?? SettingsUiState.initial();
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
      );
      await _saveSettings(newSettings);
    }
  }

  Future<void> setMyDutyGroup(String? group) async {
    final current = state.valueOrNull ?? SettingsUiState.initial();
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
      );
      await _saveSettings(newSettings);
    }
  }

  Future<void> reset() async {
    state = const AsyncLoading();
    try {
      await _resetSettingsUseCase!.execute();
      // Ensure all theme consumers recompute after reset
      ref.invalidate(themeModeProvider);
      state = AsyncData(await _load());
    } catch (_) {
      final current = state.valueOrNull ?? SettingsUiState.initial();
      state = AsyncData(current.copyWith(error: 'Failed to reset settings'));
    }
  }

  Future<void> _saveSettings(Settings settings) async {
    try {
      await _saveSettingsUseCase!.execute(settings);
    } catch (_) {
      final current = state.valueOrNull ?? SettingsUiState.initial();
      state = AsyncData(current.copyWith(error: 'Failed to save settings'));
    }
  }
}
