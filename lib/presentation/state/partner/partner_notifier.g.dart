// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partner_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PartnerNotifier)
final partnerProvider = PartnerNotifierProvider._();

final class PartnerNotifierProvider
    extends $AsyncNotifierProvider<PartnerNotifier, PartnerUiState> {
  PartnerNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'partnerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$partnerNotifierHash();

  @$internal
  @override
  PartnerNotifier create() => PartnerNotifier();
}

String _$partnerNotifierHash() => r'deb1720f92800a538a541158b0d901d1bdb68df1';

abstract class _$PartnerNotifier extends $AsyncNotifier<PartnerUiState> {
  FutureOr<PartnerUiState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PartnerUiState>, PartnerUiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PartnerUiState>, PartnerUiState>,
              AsyncValue<PartnerUiState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
