import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_ui_state.freezed.dart';

@freezed
abstract class PartnerUiState with _$PartnerUiState {
  const factory PartnerUiState({
    required bool isLoading,
    String? error,
    String? partnerConfigName,
    String? partnerDutyGroup,
    int? partnerAccentColorValue,
    int? myAccentColorValue,
  }) = _PartnerUiState;

  const PartnerUiState._();

  factory PartnerUiState.initial() => const PartnerUiState(
    isLoading: false,
    partnerConfigName: null,
    partnerDutyGroup: null,
    partnerAccentColorValue: null,
    myAccentColorValue: null,
  );
}
