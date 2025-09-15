import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dienstplan/presentation/state/partner/partner_ui_state.dart';
import 'package:dienstplan/domain/use_cases/get_settings_use_case.dart';
import 'package:dienstplan/domain/use_cases/save_settings_use_case.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';

part 'partner_notifier.g.dart';

@riverpod
class PartnerNotifier extends _$PartnerNotifier {
  GetSettingsUseCase? _getSettingsUseCase;
  SaveSettingsUseCase? _saveSettingsUseCase;

  @override
  Future<PartnerUiState> build() async {
    _getSettingsUseCase ??= await ref.read(getSettingsUseCaseProvider.future);
    _saveSettingsUseCase ??= await ref.read(saveSettingsUseCaseProvider.future);
    return await _initialize();
  }

  Future<PartnerUiState> _initialize() async {
    try {
      final settingsResult = await _getSettingsUseCase!.executeSafe();
      final settings = settingsResult.isSuccess ? settingsResult.value : null;

      return PartnerUiState(
        isLoading: false,
        error: null,
        partnerConfigName: settings?.partnerConfigName,
        partnerDutyGroup: settings?.partnerDutyGroup,
        partnerAccentColorValue: settings?.partnerAccentColorValue,
        myAccentColorValue: settings?.myAccentColorValue,
      );
    } catch (e) {
      return PartnerUiState.initial().copyWith(
        error: 'Failed to initialize partner settings',
      );
    }
  }

  Future<void> setPartnerConfigName(String? configName) async {
    final current = await future;
    state = AsyncData(current.copyWith(isLoading: true));

    try {
      final settingsResult = await _getSettingsUseCase!.executeSafe();
      final existing = settingsResult.isSuccess ? settingsResult.value : null;

      if (existing != null) {
        final updated = existing.copyWith(partnerConfigName: configName);
        await _saveSettingsUseCase!.executeSafe(updated);
      }

      state = AsyncData(current.copyWith(
        partnerConfigName: configName,
        isLoading: false,
      ));
    } catch (e) {
      state = AsyncData(current.copyWith(
        error: 'Failed to save partner config name',
        isLoading: false,
      ));
    }
  }

  Future<void> setPartnerDutyGroup(String? dutyGroup) async {
    final current = await future;
    state = AsyncData(current.copyWith(isLoading: true));

    try {
      final settingsResult = await _getSettingsUseCase!.executeSafe();
      final existing = settingsResult.isSuccess ? settingsResult.value : null;

      if (existing != null) {
        final updated = existing.copyWith(partnerDutyGroup: dutyGroup);
        await _saveSettingsUseCase!.executeSafe(updated);
      }

      state = AsyncData(current.copyWith(
        partnerDutyGroup: dutyGroup,
        isLoading: false,
      ));
    } catch (e) {
      state = AsyncData(current.copyWith(
        error: 'Failed to save partner duty group',
        isLoading: false,
      ));
    }
  }

  Future<void> setPartnerAccentColor(int? colorValue) async {
    final current = await future;
    state = AsyncData(current.copyWith(isLoading: true));

    try {
      final settingsResult = await _getSettingsUseCase!.executeSafe();
      final existing = settingsResult.isSuccess ? settingsResult.value : null;

      if (existing != null) {
        final updated = existing.copyWith(partnerAccentColorValue: colorValue);
        await _saveSettingsUseCase!.executeSafe(updated);
      }

      state = AsyncData(current.copyWith(
        partnerAccentColorValue: colorValue,
        isLoading: false,
      ));
    } catch (e) {
      state = AsyncData(current.copyWith(
        error: 'Failed to save partner accent color',
        isLoading: false,
      ));
    }
  }

  Future<void> setMyAccentColor(int? colorValue) async {
    final current = await future;
    state = AsyncData(current.copyWith(isLoading: true));

    try {
      final settingsResult = await _getSettingsUseCase!.executeSafe();
      final existing = settingsResult.isSuccess ? settingsResult.value : null;

      if (existing != null) {
        final updated = existing.copyWith(myAccentColorValue: colorValue);
        await _saveSettingsUseCase!.executeSafe(updated);
      }

      state = AsyncData(current.copyWith(
        myAccentColorValue: colorValue,
        isLoading: false,
      ));
    } catch (e) {
      state = AsyncData(current.copyWith(
        error: 'Failed to save my accent color',
        isLoading: false,
      ));
    }
  }

  Future<void> clearError() async {
    final current = await future;
    state = AsyncData(current.copyWith(error: null));
  }
}
