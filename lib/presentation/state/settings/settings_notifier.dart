import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/presentation/state/settings/settings_ui_state.dart';
import 'package:dienstplan/domain/use_cases/get_settings_use_case.dart';
import 'package:dienstplan/domain/use_cases/save_settings_use_case.dart';
import 'package:dienstplan/domain/use_cases/reset_settings_use_case.dart';
import 'package:dienstplan/domain/entities/settings.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:get_it/get_it.dart';

class SettingsNotifier extends AsyncNotifier<SettingsUiState> {
  GetSettingsUseCase? _getSettingsUseCase;
  SaveSettingsUseCase? _saveSettingsUseCase;
  ResetSettingsUseCase? _resetSettingsUseCase;

  @override
  Future<SettingsUiState> build() async {
    _getSettingsUseCase ??= await GetIt.instance.getAsync<GetSettingsUseCase>();
    _saveSettingsUseCase ??=
        await GetIt.instance.getAsync<SaveSettingsUseCase>();
    _resetSettingsUseCase ??=
        await GetIt.instance.getAsync<ResetSettingsUseCase>();
    final loaded = await _load();
    return loaded;
  }

  Future<SettingsUiState> _load() async {
    final current = state.valueOrNull ?? SettingsUiState.initial();
    state = const AsyncLoading();
    try {
      final settings = await _getSettingsUseCase!.execute();
      return SettingsUiState(
        isLoading: false,
        language: settings?.language,
        calendarFormat: settings?.calendarFormat,
        activeConfigName: settings?.activeConfigName,
        myDutyGroup: settings?.myDutyGroup,
      );
    } catch (e) {
      return current.copyWith(
          isLoading: false, error: 'Failed to load settings');
    }
  }

  Future<void> setLanguage(String language) async {
    final current = state.valueOrNull ?? SettingsUiState.initial();
    state = AsyncData(current.copyWith(language: language));
    final existing = await _getSettingsUseCase!.execute();
    if (existing != null) {
      await _saveSettings(existing.copyWith(language: language));
    }
  }

  Future<void> setCalendarFormat(CalendarFormat format) async {
    final current = state.valueOrNull ?? SettingsUiState.initial();
    state = AsyncData(current.copyWith(calendarFormat: format));
    final existing = await _getSettingsUseCase!.execute();
    if (existing != null) {
      await _saveSettings(existing.copyWith(calendarFormat: format));
    }
  }

  Future<void> setActiveConfigName(String name) async {
    final current = state.valueOrNull ?? SettingsUiState.initial();
    state = AsyncData(current.copyWith(activeConfigName: name));
    final existing = await _getSettingsUseCase!.execute();
    if (existing != null) {
      await _saveSettings(existing.copyWith(activeConfigName: name));
    }
  }

  Future<void> setMyDutyGroup(String? group) async {
    final current = state.valueOrNull ?? SettingsUiState.initial();
    state = AsyncData(current.copyWith(myDutyGroup: group));
    final existing = await _getSettingsUseCase!.execute();
    if (existing != null) {
      await _saveSettings(existing.copyWith(myDutyGroup: group));
    }
  }

  Future<void> reset() async {
    state = const AsyncLoading();
    try {
      await _resetSettingsUseCase!.execute();
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

final settingsNotifierProvider =
    AsyncNotifierProvider<SettingsNotifier, SettingsUiState>(
  SettingsNotifier.new,
);
