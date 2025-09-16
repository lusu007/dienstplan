// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setup_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SetupNotifier)
const setupProvider = SetupNotifierProvider._();

final class SetupNotifierProvider
    extends $AsyncNotifierProvider<SetupNotifier, SetupUiState> {
  const SetupNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'setupProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$setupNotifierHash();

  @$internal
  @override
  SetupNotifier create() => SetupNotifier();
}

String _$setupNotifierHash() => r'cdc348fad527f94f4b0c566e3772a0d2aeba55ba';

abstract class _$SetupNotifier extends $AsyncNotifier<SetupUiState> {
  FutureOr<SetupUiState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<SetupUiState>, SetupUiState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<SetupUiState>, SetupUiState>,
        AsyncValue<SetupUiState>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
