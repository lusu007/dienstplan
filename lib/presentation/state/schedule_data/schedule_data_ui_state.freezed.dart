// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule_data_ui_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ScheduleDataUiState {
  bool get isLoading;
  String? get error;
  List<Schedule> get schedules;
  String? get activeConfigName;
  String? get preferredDutyGroup;
  String? get selectedDutyGroup;
  int? get holidayAccentColorValue;

  /// Create a copy of ScheduleDataUiState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ScheduleDataUiStateCopyWith<ScheduleDataUiState> get copyWith =>
      _$ScheduleDataUiStateCopyWithImpl<ScheduleDataUiState>(
        this as ScheduleDataUiState,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ScheduleDataUiState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality().equals(other.schedules, schedules) &&
            (identical(other.activeConfigName, activeConfigName) ||
                other.activeConfigName == activeConfigName) &&
            (identical(other.preferredDutyGroup, preferredDutyGroup) ||
                other.preferredDutyGroup == preferredDutyGroup) &&
            (identical(other.selectedDutyGroup, selectedDutyGroup) ||
                other.selectedDutyGroup == selectedDutyGroup) &&
            (identical(
                  other.holidayAccentColorValue,
                  holidayAccentColorValue,
                ) ||
                other.holidayAccentColorValue == holidayAccentColorValue));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    isLoading,
    error,
    const DeepCollectionEquality().hash(schedules),
    activeConfigName,
    preferredDutyGroup,
    selectedDutyGroup,
    holidayAccentColorValue,
  );

  @override
  String toString() {
    return 'ScheduleDataUiState(isLoading: $isLoading, error: $error, schedules: $schedules, activeConfigName: $activeConfigName, preferredDutyGroup: $preferredDutyGroup, selectedDutyGroup: $selectedDutyGroup, holidayAccentColorValue: $holidayAccentColorValue)';
  }
}

/// @nodoc
abstract mixin class $ScheduleDataUiStateCopyWith<$Res> {
  factory $ScheduleDataUiStateCopyWith(
    ScheduleDataUiState value,
    $Res Function(ScheduleDataUiState) _then,
  ) = _$ScheduleDataUiStateCopyWithImpl;
  @useResult
  $Res call({
    bool isLoading,
    String? error,
    List<Schedule> schedules,
    String? activeConfigName,
    String? preferredDutyGroup,
    String? selectedDutyGroup,
    int? holidayAccentColorValue,
  });
}

/// @nodoc
class _$ScheduleDataUiStateCopyWithImpl<$Res>
    implements $ScheduleDataUiStateCopyWith<$Res> {
  _$ScheduleDataUiStateCopyWithImpl(this._self, this._then);

  final ScheduleDataUiState _self;
  final $Res Function(ScheduleDataUiState) _then;

  /// Create a copy of ScheduleDataUiState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? schedules = null,
    Object? activeConfigName = freezed,
    Object? preferredDutyGroup = freezed,
    Object? selectedDutyGroup = freezed,
    Object? holidayAccentColorValue = freezed,
  }) {
    return _then(
      _self.copyWith(
        isLoading: null == isLoading
            ? _self.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _self.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        schedules: null == schedules
            ? _self.schedules
            : schedules // ignore: cast_nullable_to_non_nullable
                  as List<Schedule>,
        activeConfigName: freezed == activeConfigName
            ? _self.activeConfigName
            : activeConfigName // ignore: cast_nullable_to_non_nullable
                  as String?,
        preferredDutyGroup: freezed == preferredDutyGroup
            ? _self.preferredDutyGroup
            : preferredDutyGroup // ignore: cast_nullable_to_non_nullable
                  as String?,
        selectedDutyGroup: freezed == selectedDutyGroup
            ? _self.selectedDutyGroup
            : selectedDutyGroup // ignore: cast_nullable_to_non_nullable
                  as String?,
        holidayAccentColorValue: freezed == holidayAccentColorValue
            ? _self.holidayAccentColorValue
            : holidayAccentColorValue // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [ScheduleDataUiState].
extension ScheduleDataUiStatePatterns on ScheduleDataUiState {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ScheduleDataUiState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ScheduleDataUiState() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ScheduleDataUiState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleDataUiState():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ScheduleDataUiState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleDataUiState() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
      bool isLoading,
      String? error,
      List<Schedule> schedules,
      String? activeConfigName,
      String? preferredDutyGroup,
      String? selectedDutyGroup,
      int? holidayAccentColorValue,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ScheduleDataUiState() when $default != null:
        return $default(
          _that.isLoading,
          _that.error,
          _that.schedules,
          _that.activeConfigName,
          _that.preferredDutyGroup,
          _that.selectedDutyGroup,
          _that.holidayAccentColorValue,
        );
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
      bool isLoading,
      String? error,
      List<Schedule> schedules,
      String? activeConfigName,
      String? preferredDutyGroup,
      String? selectedDutyGroup,
      int? holidayAccentColorValue,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleDataUiState():
        return $default(
          _that.isLoading,
          _that.error,
          _that.schedules,
          _that.activeConfigName,
          _that.preferredDutyGroup,
          _that.selectedDutyGroup,
          _that.holidayAccentColorValue,
        );
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
      bool isLoading,
      String? error,
      List<Schedule> schedules,
      String? activeConfigName,
      String? preferredDutyGroup,
      String? selectedDutyGroup,
      int? holidayAccentColorValue,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleDataUiState() when $default != null:
        return $default(
          _that.isLoading,
          _that.error,
          _that.schedules,
          _that.activeConfigName,
          _that.preferredDutyGroup,
          _that.selectedDutyGroup,
          _that.holidayAccentColorValue,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ScheduleDataUiState extends ScheduleDataUiState {
  const _ScheduleDataUiState({
    required this.isLoading,
    this.error,
    final List<Schedule> schedules = const <Schedule>[],
    this.activeConfigName,
    this.preferredDutyGroup,
    this.selectedDutyGroup,
    this.holidayAccentColorValue,
  }) : _schedules = schedules,
       super._();

  @override
  final bool isLoading;
  @override
  final String? error;
  final List<Schedule> _schedules;
  @override
  @JsonKey()
  List<Schedule> get schedules {
    if (_schedules is EqualUnmodifiableListView) return _schedules;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_schedules);
  }

  @override
  final String? activeConfigName;
  @override
  final String? preferredDutyGroup;
  @override
  final String? selectedDutyGroup;
  @override
  final int? holidayAccentColorValue;

  /// Create a copy of ScheduleDataUiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ScheduleDataUiStateCopyWith<_ScheduleDataUiState> get copyWith =>
      __$ScheduleDataUiStateCopyWithImpl<_ScheduleDataUiState>(
        this,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ScheduleDataUiState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality().equals(
              other._schedules,
              _schedules,
            ) &&
            (identical(other.activeConfigName, activeConfigName) ||
                other.activeConfigName == activeConfigName) &&
            (identical(other.preferredDutyGroup, preferredDutyGroup) ||
                other.preferredDutyGroup == preferredDutyGroup) &&
            (identical(other.selectedDutyGroup, selectedDutyGroup) ||
                other.selectedDutyGroup == selectedDutyGroup) &&
            (identical(
                  other.holidayAccentColorValue,
                  holidayAccentColorValue,
                ) ||
                other.holidayAccentColorValue == holidayAccentColorValue));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    isLoading,
    error,
    const DeepCollectionEquality().hash(_schedules),
    activeConfigName,
    preferredDutyGroup,
    selectedDutyGroup,
    holidayAccentColorValue,
  );

  @override
  String toString() {
    return 'ScheduleDataUiState(isLoading: $isLoading, error: $error, schedules: $schedules, activeConfigName: $activeConfigName, preferredDutyGroup: $preferredDutyGroup, selectedDutyGroup: $selectedDutyGroup, holidayAccentColorValue: $holidayAccentColorValue)';
  }
}

/// @nodoc
abstract mixin class _$ScheduleDataUiStateCopyWith<$Res>
    implements $ScheduleDataUiStateCopyWith<$Res> {
  factory _$ScheduleDataUiStateCopyWith(
    _ScheduleDataUiState value,
    $Res Function(_ScheduleDataUiState) _then,
  ) = __$ScheduleDataUiStateCopyWithImpl;
  @override
  @useResult
  $Res call({
    bool isLoading,
    String? error,
    List<Schedule> schedules,
    String? activeConfigName,
    String? preferredDutyGroup,
    String? selectedDutyGroup,
    int? holidayAccentColorValue,
  });
}

/// @nodoc
class __$ScheduleDataUiStateCopyWithImpl<$Res>
    implements _$ScheduleDataUiStateCopyWith<$Res> {
  __$ScheduleDataUiStateCopyWithImpl(this._self, this._then);

  final _ScheduleDataUiState _self;
  final $Res Function(_ScheduleDataUiState) _then;

  /// Create a copy of ScheduleDataUiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? schedules = null,
    Object? activeConfigName = freezed,
    Object? preferredDutyGroup = freezed,
    Object? selectedDutyGroup = freezed,
    Object? holidayAccentColorValue = freezed,
  }) {
    return _then(
      _ScheduleDataUiState(
        isLoading: null == isLoading
            ? _self.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _self.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        schedules: null == schedules
            ? _self._schedules
            : schedules // ignore: cast_nullable_to_non_nullable
                  as List<Schedule>,
        activeConfigName: freezed == activeConfigName
            ? _self.activeConfigName
            : activeConfigName // ignore: cast_nullable_to_non_nullable
                  as String?,
        preferredDutyGroup: freezed == preferredDutyGroup
            ? _self.preferredDutyGroup
            : preferredDutyGroup // ignore: cast_nullable_to_non_nullable
                  as String?,
        selectedDutyGroup: freezed == selectedDutyGroup
            ? _self.selectedDutyGroup
            : selectedDutyGroup // ignore: cast_nullable_to_non_nullable
                  as String?,
        holidayAccentColorValue: freezed == holidayAccentColorValue
            ? _self.holidayAccentColorValue
            : holidayAccentColorValue // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}
