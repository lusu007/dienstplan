// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ScheduleNotifier)
const scheduleProvider = ScheduleNotifierProvider._();

final class ScheduleNotifierProvider
    extends $AsyncNotifierProvider<ScheduleNotifier, ScheduleUiState> {
  const ScheduleNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scheduleProvider',
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

String _$scheduleNotifierHash() => r'1fdc76dc1cde634a95f08deda1d20a7cb64dfa09';

abstract class _$ScheduleNotifier extends $AsyncNotifier<ScheduleUiState> {
  FutureOr<ScheduleUiState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<ScheduleUiState>, ScheduleUiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ScheduleUiState>, ScheduleUiState>,
              AsyncValue<ScheduleUiState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
