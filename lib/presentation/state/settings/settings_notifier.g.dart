// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(SettingsNotifier)
const settingsNotifierProvider = SettingsNotifierProvider._();

final class SettingsNotifierProvider
    extends $AsyncNotifierProvider<SettingsNotifier, SettingsUiState> {
  const SettingsNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'settingsNotifierProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$settingsNotifierHash();

  @$internal
  @override
  SettingsNotifier create() => SettingsNotifier();
}

String _$settingsNotifierHash() => r'6778ba7df13ce4cf96364ef71af18cdae055c2ee';

abstract class _$SettingsNotifier extends $AsyncNotifier<SettingsUiState> {
  FutureOr<SettingsUiState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<SettingsUiState>, SettingsUiState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<SettingsUiState>, SettingsUiState>,
        AsyncValue<SettingsUiState>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
