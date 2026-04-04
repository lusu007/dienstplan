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
    r'ea404a5bf1508e9ec5b105a0c18f7690e87bb800';

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
