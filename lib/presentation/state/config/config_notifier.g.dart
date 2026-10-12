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

String _$configNotifierHash() => r'ccf725677100f51c72e79bb7a381a59749794395';

abstract class _$ConfigNotifier extends $AsyncNotifier<ConfigUiState> {
  FutureOr<ConfigUiState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ConfigUiState>, ConfigUiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ConfigUiState>, ConfigUiState>,
              AsyncValue<ConfigUiState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
