// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_coordinator_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ScheduleCoordinatorNotifier)
const scheduleCoordinatorProvider = ScheduleCoordinatorNotifierProvider._();

final class ScheduleCoordinatorNotifierProvider extends $AsyncNotifierProvider<
    ScheduleCoordinatorNotifier, ScheduleUiState> {
  const ScheduleCoordinatorNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'scheduleCoordinatorProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$scheduleCoordinatorNotifierHash();

  @$internal
  @override
  ScheduleCoordinatorNotifier create() => ScheduleCoordinatorNotifier();
}

String _$scheduleCoordinatorNotifierHash() =>
    r'1ac6b1c20d0fb799141c2c4a9c2d8f85283433d1';

abstract class _$ScheduleCoordinatorNotifier
    extends $AsyncNotifier<ScheduleUiState> {
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
