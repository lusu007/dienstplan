import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dienstplan/presentation/state/settings/settings_ui_state.dart';
import 'package:dienstplan/domain/use_cases/get_settings_use_case.dart';
import 'package:dienstplan/domain/use_cases/save_settings_use_case.dart';
import 'package:dienstplan/domain/use_cases/reset_settings_use_case.dart';
import 'package:dienstplan/domain/entities/settings.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/domain/failures/result.dart';
import 'package:dienstplan/core/cache/settings_cache.dart';
import 'package:dienstplan/core/utils/settings_utils.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/state/schedule_data/schedule_data_notifier.dart';
import 'package:dienstplan/core/utils/logger.dart';
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
      final Result<Settings?> loadedResult = await _getSettingsUseCase!
          .execute();
      if (loadedResult.isFailure) {
        return SettingsUiState.initial().copyWith(
          error: 'Failed to load settings',
        );
      }
      final Settings? settings = loadedResult.valueIfSuccess;
      return SettingsUiState(
        isLoading: false,
        language: settings?.language,
        activeConfigName: settings?.activeConfigName,
        myDutyGroup: settings?.myDutyGroup,
        themePreference: settings?.themePreference ?? ThemePreference.system,
        partnerConfigName: settings?.partnerConfigName,
        partnerDutyGroup: settings?.partnerDutyGroup,
        partnerAccentColorValue: settings?.partnerAccentColorValue,
        myAccentColorValue: settings?.myAccentColorValue,
        holidayAccentColorValue: settings?.holidayAccentColorValue,
      );
    } catch (_) {
      return SettingsUiState.initial().copyWith(
        error: 'Failed to load settings',
      );
    }
  }

  void _invalidateSettingsReadPath() {
    ref.invalidate(getSettingsUseCaseProvider);
    SettingsCache.clearCache();
  }

  /// Upsert persisted settings, invalidate read path; set UI error on failure.
  Future<bool> _upsertPersisted(
    Settings Function(Settings? current) build, {
    void Function()? afterSuccess,
  }) async {
    try {
      final Result<void> upsertResult = await _saveSettingsUseCase!.upsert(
        build,
      );
      if (upsertResult.isFailure) {
        final ui = state.value ?? SettingsUiState.initial();
        state = AsyncData(ui.copyWith(error: 'Failed to save settings'));
        return false;
      }
      _invalidateSettingsReadPath();
      afterSuccess?.call();
      return true;
    } catch (_) {
      final ui = state.value ?? SettingsUiState.initial();
      state = AsyncData(ui.copyWith(error: 'Failed to save settings'));
      return false;
    }
  }

  Future<void> setLanguage(String language) async {
    final current = state.value ?? SettingsUiState.initial();
    state = AsyncData(current.copyWith(language: language));
    await _upsertPersisted(
      (Settings? c) => c != null
          ? c.copyWith(language: language)
          : Settings.withDefaults(language: language),
    );
  }

  Future<void> setThemePreference(ThemePreference preference) async {
    final current = state.value ?? SettingsUiState.initial();
    state = AsyncData(current.copyWith(themePreference: preference));
    unawaited(_saveThemePreferenceInBackground(preference));
  }

  Future<void> _saveThemePreferenceInBackground(
    ThemePreference preference,
  ) async {
    try {
      final Result<void> upsertResult = await _saveSettingsUseCase!.upsert(
        (Settings? c) => c != null
            ? c.copyWith(themePreference: preference)
            : Settings.withDefaults(themePreference: preference),
      );
      if (upsertResult.isFailure) {
        return;
      }
      ref.invalidate(getSettingsUseCaseProvider);
    } catch (e) {
      AppLogger.d(
        'SettingsNotifier: Best-effort save themePreference skipped '
        '(preference=$preference, error=$e)',
      );
    }
  }

  Future<void> setActiveConfigName(String name) async {
    final current = state.value ?? SettingsUiState.initial();
    state = AsyncData(current.copyWith(activeConfigName: name));
    await _upsertPersisted(
      (Settings? c) => c != null
          ? c.copyWith(activeConfigName: name)
          : Settings.withDefaults(activeConfigName: name),
    );
  }

  Future<void> setMyDutyGroup(String? group) async {
    final current = state.value ?? SettingsUiState.initial();
    state = AsyncData(current.copyWith(myDutyGroup: group));
    final ok = await _upsertPersisted(
      (Settings? c) {
        if (c != null) {
          return c.copyWith(
            myDutyGroup: group,
            activeConfigName: SettingsUtils.selectActiveConfigNameToPersist(
              currentActiveConfigName: current.activeConfigName,
              existingActiveConfigName: c.activeConfigName,
            ),
          );
        }
        return Settings.withDefaults(myDutyGroup: group);
      },
      afterSuccess: () {
        ref.read(scheduleDataProvider.notifier).invalidateCache();
        ref.invalidate(scheduleDataProvider);
      },
    );
    if (!ok) {
      return;
    }
  }

  Future<void> reset() async {
    try {
      final Result<void> resetResult = await _resetSettingsUseCase!.execute();
      if (resetResult.isFailure) {
        final current = state.value ?? SettingsUiState.initial();
        state = AsyncData(current.copyWith(error: 'Failed to reset settings'));
        return;
      }
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
    final ok = await _upsertPersisted(
      (Settings? c) => c != null
          ? c.copyWith(holidayAccentColorValue: colorValue)
          : Settings.withDefaults(holidayAccentColorValue: colorValue),
    );
    if (!ok) {
      return;
    }
    try {
      ref.read(scheduleDataProvider.notifier).invalidateCache();
      ref.invalidate(scheduleCoordinatorProvider);
    } catch (e) {
      ref.invalidate(scheduleDataProvider);
      ref.invalidate(scheduleCoordinatorProvider);
    }
  }
}
