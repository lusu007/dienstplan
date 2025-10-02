// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_data_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ScheduleDataNotifier)
const scheduleDataProvider = ScheduleDataNotifierProvider._();

final class ScheduleDataNotifierProvider
    extends $AsyncNotifierProvider<ScheduleDataNotifier, ScheduleDataUiState> {
  const ScheduleDataNotifierProvider._()
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
    r'c55293b8dd0a1720f9e864493e82d4753745be1d';

abstract class _$ScheduleDataNotifier
    extends $AsyncNotifier<ScheduleDataUiState> {
  FutureOr<ScheduleDataUiState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
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
    element.handleValue(ref, created);
  }
}
