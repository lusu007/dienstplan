// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setup_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(SetupNotifier)
const setupNotifierProvider = SetupNotifierProvider._();

final class SetupNotifierProvider
    extends $AsyncNotifierProvider<SetupNotifier, SetupUiState> {
  const SetupNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'setupNotifierProvider',
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

String _$setupNotifierHash() => r'adb000cd68e81ade10c4a48d52a378355120b3c2';

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

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
