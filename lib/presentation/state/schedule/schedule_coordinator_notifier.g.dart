// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_coordinator_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ScheduleCoordinatorNotifier)
final scheduleCoordinatorProvider = ScheduleCoordinatorNotifierProvider._();

final class ScheduleCoordinatorNotifierProvider
    extends
        $AsyncNotifierProvider<ScheduleCoordinatorNotifier, ScheduleUiState> {
  ScheduleCoordinatorNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scheduleCoordinatorProvider',
        isAutoDispose: false,
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
    r'b58628d24accb6619489bd6ddbabb375abc3856a';

abstract class _$ScheduleCoordinatorNotifier
    extends $AsyncNotifier<ScheduleUiState> {
  FutureOr<ScheduleUiState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ScheduleUiState>, ScheduleUiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ScheduleUiState>, ScheduleUiState>,
              AsyncValue<ScheduleUiState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
