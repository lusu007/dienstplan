// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(ScheduleNotifier)
const scheduleNotifierProvider = ScheduleNotifierProvider._();

final class ScheduleNotifierProvider
    extends $AsyncNotifierProvider<ScheduleNotifier, ScheduleUiState> {
  const ScheduleNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'scheduleNotifierProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$scheduleNotifierHash();

  @$internal
  @override
  ScheduleNotifier create() => ScheduleNotifier();
}

String _$scheduleNotifierHash() => r'cf450dfecb026abc9677d3a78e44816c6f9f0901';

abstract class _$ScheduleNotifier extends $AsyncNotifier<ScheduleUiState> {
  FutureOr<ScheduleUiState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<ScheduleUiState>, ScheduleUiState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<ScheduleUiState>, ScheduleUiState>,
        AsyncValue<ScheduleUiState>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
