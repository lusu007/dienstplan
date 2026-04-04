import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dienstplan/domain/entities/settings.dart';
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
      if (!ref.mounted) {
        return PartnerUiState.initial();
      }
      final settingsResult = await _getSettingsUseCase!.execute();
      final settings = settingsResult.valueIfSuccess;

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
    await _persistPartnerField(
      errorMessage: 'Failed to save partner config name',
      patchSettings: (Settings existing) =>
          existing.copyWith(partnerConfigName: configName),
      buildSuccessState: (PartnerUiState current) =>
          current.copyWith(partnerConfigName: configName, isLoading: false),
    );
  }

  Future<void> setPartnerDutyGroup(String? dutyGroup) async {
    await _persistPartnerField(
      errorMessage: 'Failed to save partner duty group',
      patchSettings: (Settings existing) =>
          existing.copyWith(partnerDutyGroup: dutyGroup),
      buildSuccessState: (PartnerUiState current) =>
          current.copyWith(partnerDutyGroup: dutyGroup, isLoading: false),
    );
  }

  Future<void> setPartnerAccentColor(int? colorValue) async {
    await _persistPartnerField(
      errorMessage: 'Failed to save partner accent color',
      patchSettings: (Settings existing) =>
          existing.copyWith(partnerAccentColorValue: colorValue),
      buildSuccessState: (PartnerUiState current) => current.copyWith(
        partnerAccentColorValue: colorValue,
        isLoading: false,
      ),
    );
  }

  Future<void> setMyAccentColor(int? colorValue) async {
    await _persistPartnerField(
      errorMessage: 'Failed to save my accent color',
      patchSettings: (Settings existing) =>
          existing.copyWith(myAccentColorValue: colorValue),
      buildSuccessState: (PartnerUiState current) =>
          current.copyWith(myAccentColorValue: colorValue, isLoading: false),
    );
  }

  Future<void> _persistPartnerField({
    required String errorMessage,
    required Settings Function(Settings existing) patchSettings,
    required PartnerUiState Function(PartnerUiState current) buildSuccessState,
  }) async {
    final PartnerUiState current = await future;
    if (!ref.mounted) {
      return;
    }
    state = AsyncData(current.copyWith(isLoading: true));

    try {
      if (!ref.mounted) {
        return;
      }
      final settingsResult = await _getSettingsUseCase!.execute();
      final Settings? existing = settingsResult.valueIfSuccess;

      if (existing != null) {
        final Settings updated = patchSettings(existing);
        await _saveSettingsUseCase!.execute(updated);
      }

      if (!ref.mounted) {
        return;
      }
      state = AsyncData(buildSuccessState(current));
    } catch (e) {
      if (!ref.mounted) {
        return;
      }
      state = AsyncData(
        current.copyWith(error: errorMessage, isLoading: false),
      );
    }
  }

  Future<void> clearError() async {
    final current = await future;
    if (!ref.mounted) {
      return;
    }
    state = AsyncData(current.copyWith(error: null));
  }
}
