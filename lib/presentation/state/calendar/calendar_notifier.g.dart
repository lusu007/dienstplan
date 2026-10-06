// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CalendarNotifier)
final calendarProvider = CalendarNotifierProvider._();

final class CalendarNotifierProvider
    extends $AsyncNotifierProvider<CalendarNotifier, CalendarUiState> {
  CalendarNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'calendarProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$calendarNotifierHash();

  @$internal
  @override
  CalendarNotifier create() => CalendarNotifier();
}

String _$calendarNotifierHash() => r'92fa6f2f604d3a937d690d63bf747cc93090571d';

abstract class _$CalendarNotifier extends $AsyncNotifier<CalendarUiState> {
  FutureOr<CalendarUiState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<CalendarUiState>, CalendarUiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CalendarUiState>, CalendarUiState>,
              AsyncValue<CalendarUiState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
