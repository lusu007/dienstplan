// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_data_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ScheduleDataNotifier)
final scheduleDataProvider = ScheduleDataNotifierProvider._();

final class ScheduleDataNotifierProvider
    extends $AsyncNotifierProvider<ScheduleDataNotifier, ScheduleDataUiState> {
  ScheduleDataNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scheduleDataProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scheduleDataNotifierHash();

  @$internal
  @override
  ScheduleDataNotifier create() => ScheduleDataNotifier();
}

String _$scheduleDataNotifierHash() =>
    r'94261a57e53c2f787c6e7a0add434a51c36a7523';

abstract class _$ScheduleDataNotifier
    extends $AsyncNotifier<ScheduleDataUiState> {
  FutureOr<ScheduleDataUiState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<ScheduleDataUiState>, ScheduleDataUiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ScheduleDataUiState>, ScheduleDataUiState>,
              AsyncValue<ScheduleDataUiState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
