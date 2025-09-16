// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ConfigNotifier)
const configProvider = ConfigNotifierProvider._();

final class ConfigNotifierProvider
    extends $AsyncNotifierProvider<ConfigNotifier, ConfigUiState> {
  const ConfigNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'configProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$configNotifierHash();

  @$internal
  @override
  ConfigNotifier create() => ConfigNotifier();
}

String _$configNotifierHash() => r'838770dc04ec0c0f95a6170d84cb2674745b5851';

abstract class _$ConfigNotifier extends $AsyncNotifier<ConfigUiState> {
  FutureOr<ConfigUiState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<ConfigUiState>, ConfigUiState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<ConfigUiState>, ConfigUiState>,
        AsyncValue<ConfigUiState>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
