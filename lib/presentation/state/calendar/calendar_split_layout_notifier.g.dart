// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_split_layout_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CalendarSplitLayout)
final calendarSplitLayoutProvider = CalendarSplitLayoutProvider._();

final class CalendarSplitLayoutProvider
    extends $NotifierProvider<CalendarSplitLayout, bool> {
  CalendarSplitLayoutProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'calendarSplitLayoutProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$calendarSplitLayoutHash();

  @$internal
  @override
  CalendarSplitLayout create() => CalendarSplitLayout();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$calendarSplitLayoutHash() =>
    r'd2a0aa81d07efa1c429ce10fc75ce127645d7705';

abstract class _$CalendarSplitLayout extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
