// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CalendarNotifier)
const calendarProvider = CalendarNotifierProvider._();

final class CalendarNotifierProvider
    extends $AsyncNotifierProvider<CalendarNotifier, CalendarUiState> {
  const CalendarNotifierProvider._()
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

String _$calendarNotifierHash() => r'670348dff523c32e6fb2ad34dd0b86463396461d';

abstract class _$CalendarNotifier extends $AsyncNotifier<CalendarUiState> {
  FutureOr<CalendarUiState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<CalendarUiState>, CalendarUiState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<CalendarUiState>, CalendarUiState>,
        AsyncValue<CalendarUiState>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
