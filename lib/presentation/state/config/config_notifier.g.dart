// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ConfigNotifier)
final configProvider = ConfigNotifierProvider._();

final class ConfigNotifierProvider
    extends $AsyncNotifierProvider<ConfigNotifier, ConfigUiState> {
  ConfigNotifierProvider._()
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

String _$configNotifierHash() => r'4a48220890b237ba89a3c0389a25ce80d2fccfd3';

abstract class _$ConfigNotifier extends $AsyncNotifier<ConfigUiState> {
  FutureOr<ConfigUiState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ConfigUiState>, ConfigUiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ConfigUiState>, ConfigUiState>,
              AsyncValue<ConfigUiState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
