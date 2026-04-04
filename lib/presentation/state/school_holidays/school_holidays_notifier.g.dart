// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school_holidays_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SchoolHolidaysNotifier)
final schoolHolidaysProvider = SchoolHolidaysNotifierProvider._();

final class SchoolHolidaysNotifierProvider
    extends
        $AsyncNotifierProvider<SchoolHolidaysNotifier, SchoolHolidaysUiState> {
  SchoolHolidaysNotifierProvider._()
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
    r'1aadbe306156e79e267c8e0a3c108a931a2f1616';

abstract class _$SchoolHolidaysNotifier
    extends $AsyncNotifier<SchoolHolidaysUiState> {
  FutureOr<SchoolHolidaysUiState> build();
  @$mustCallSuper
  @override
  void runBuild() {
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
    element.handleCreate(ref, build);
  }
}
