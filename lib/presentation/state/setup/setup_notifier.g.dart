// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setup_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SetupNotifier)
final setupProvider = SetupNotifierProvider._();

final class SetupNotifierProvider
    extends $AsyncNotifierProvider<SetupNotifier, SetupUiState> {
  SetupNotifierProvider._()
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

String _$setupNotifierHash() => r'74b63b60f5067f57de261bc510c2b2fae99a902c';

abstract class _$SetupNotifier extends $AsyncNotifier<SetupUiState> {
  FutureOr<SetupUiState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<SetupUiState>, SetupUiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SetupUiState>, SetupUiState>,
              AsyncValue<SetupUiState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
