// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school_holidays_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SchoolHolidaysNotifier)
const schoolHolidaysProvider = SchoolHolidaysNotifierProvider._();

final class SchoolHolidaysNotifierProvider
    extends
        $AsyncNotifierProvider<SchoolHolidaysNotifier, SchoolHolidaysUiState> {
  const SchoolHolidaysNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'schoolHolidaysProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$schoolHolidaysNotifierHash();

  @$internal
  @override
  SchoolHolidaysNotifier create() => SchoolHolidaysNotifier();
}

String _$schoolHolidaysNotifierHash() =>
    r'6d7fb882905f0cfb0bd3000736ad662b55af014b';

abstract class _$SchoolHolidaysNotifier
    extends $AsyncNotifier<SchoolHolidaysUiState> {
  FutureOr<SchoolHolidaysUiState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<AsyncValue<SchoolHolidaysUiState>, SchoolHolidaysUiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<SchoolHolidaysUiState>,
                SchoolHolidaysUiState
              >,
              AsyncValue<SchoolHolidaysUiState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
