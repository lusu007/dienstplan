// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calendar_ui_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CalendarUiState {
  bool get isLoading;
  String? get error;
  DateTime? get selectedDay;
  DateTime? get focusedDay;
  CalendarFormat? get calendarFormat;

  /// Create a copy of CalendarUiState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CalendarUiStateCopyWith<CalendarUiState> get copyWith =>
      _$CalendarUiStateCopyWithImpl<CalendarUiState>(
        this as CalendarUiState,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CalendarUiState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.selectedDay, selectedDay) ||
                other.selectedDay == selectedDay) &&
            (identical(other.focusedDay, focusedDay) ||
                other.focusedDay == focusedDay) &&
            (identical(other.calendarFormat, calendarFormat) ||
                other.calendarFormat == calendarFormat));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    isLoading,
    error,
    selectedDay,
    focusedDay,
    calendarFormat,
  );

  @override
  String toString() {
    return 'CalendarUiState(isLoading: $isLoading, error: $error, selectedDay: $selectedDay, focusedDay: $focusedDay, calendarFormat: $calendarFormat)';
  }
}

/// @nodoc
abstract mixin class $CalendarUiStateCopyWith<$Res> {
  factory $CalendarUiStateCopyWith(
    CalendarUiState value,
    $Res Function(CalendarUiState) _then,
  ) = _$CalendarUiStateCopyWithImpl;
  @useResult
  $Res call({
    bool isLoading,
    String? error,
    DateTime? selectedDay,
    DateTime? focusedDay,
    CalendarFormat? calendarFormat,
  });
}

/// @nodoc
class _$CalendarUiStateCopyWithImpl<$Res>
    implements $CalendarUiStateCopyWith<$Res> {
  _$CalendarUiStateCopyWithImpl(this._self, this._then);

  final CalendarUiState _self;
  final $Res Function(CalendarUiState) _then;

  /// Create a copy of CalendarUiState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? selectedDay = freezed,
    Object? focusedDay = freezed,
    Object? calendarFormat = freezed,
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
        selectedDay: freezed == selectedDay
            ? _self.selectedDay
            : selectedDay // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        focusedDay: freezed == focusedDay
            ? _self.focusedDay
            : focusedDay // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        calendarFormat: freezed == calendarFormat
            ? _self.calendarFormat
            : calendarFormat // ignore: cast_nullable_to_non_nullable
                  as CalendarFormat?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [CalendarUiState].
extension CalendarUiStatePatterns on CalendarUiState {
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
    TResult Function(_CalendarUiState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CalendarUiState() when $default != null:
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
    TResult Function(_CalendarUiState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CalendarUiState():
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
    TResult? Function(_CalendarUiState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CalendarUiState() when $default != null:
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
      DateTime? selectedDay,
      DateTime? focusedDay,
      CalendarFormat? calendarFormat,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CalendarUiState() when $default != null:
        return $default(
          _that.isLoading,
          _that.error,
          _that.selectedDay,
          _that.focusedDay,
          _that.calendarFormat,
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
      DateTime? selectedDay,
      DateTime? focusedDay,
      CalendarFormat? calendarFormat,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CalendarUiState():
        return $default(
          _that.isLoading,
          _that.error,
          _that.selectedDay,
          _that.focusedDay,
          _that.calendarFormat,
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
      DateTime? selectedDay,
      DateTime? focusedDay,
      CalendarFormat? calendarFormat,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CalendarUiState() when $default != null:
        return $default(
          _that.isLoading,
          _that.error,
          _that.selectedDay,
          _that.focusedDay,
          _that.calendarFormat,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc

class _CalendarUiState extends CalendarUiState {
  const _CalendarUiState({
    required this.isLoading,
    this.error,
    this.selectedDay,
    this.focusedDay,
    this.calendarFormat,
  }) : super._();

  @override
  final bool isLoading;
  @override
  final String? error;
  @override
  final DateTime? selectedDay;
  @override
  final DateTime? focusedDay;
  @override
  final CalendarFormat? calendarFormat;

  /// Create a copy of CalendarUiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CalendarUiStateCopyWith<_CalendarUiState> get copyWith =>
      __$CalendarUiStateCopyWithImpl<_CalendarUiState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CalendarUiState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.selectedDay, selectedDay) ||
                other.selectedDay == selectedDay) &&
            (identical(other.focusedDay, focusedDay) ||
                other.focusedDay == focusedDay) &&
            (identical(other.calendarFormat, calendarFormat) ||
                other.calendarFormat == calendarFormat));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    isLoading,
    error,
    selectedDay,
    focusedDay,
    calendarFormat,
  );

  @override
  String toString() {
    return 'CalendarUiState(isLoading: $isLoading, error: $error, selectedDay: $selectedDay, focusedDay: $focusedDay, calendarFormat: $calendarFormat)';
  }
}

/// @nodoc
abstract mixin class _$CalendarUiStateCopyWith<$Res>
    implements $CalendarUiStateCopyWith<$Res> {
  factory _$CalendarUiStateCopyWith(
    _CalendarUiState value,
    $Res Function(_CalendarUiState) _then,
  ) = __$CalendarUiStateCopyWithImpl;
  @override
  @useResult
  $Res call({
    bool isLoading,
    String? error,
    DateTime? selectedDay,
    DateTime? focusedDay,
    CalendarFormat? calendarFormat,
  });
}

/// @nodoc
class __$CalendarUiStateCopyWithImpl<$Res>
    implements _$CalendarUiStateCopyWith<$Res> {
  __$CalendarUiStateCopyWithImpl(this._self, this._then);

  final _CalendarUiState _self;
  final $Res Function(_CalendarUiState) _then;

  /// Create a copy of CalendarUiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? selectedDay = freezed,
    Object? focusedDay = freezed,
    Object? calendarFormat = freezed,
  }) {
    return _then(
      _CalendarUiState(
        isLoading: null == isLoading
            ? _self.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _self.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        selectedDay: freezed == selectedDay
            ? _self.selectedDay
            : selectedDay // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        focusedDay: freezed == focusedDay
            ? _self.focusedDay
            : focusedDay // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        calendarFormat: freezed == calendarFormat
            ? _self.calendarFormat
            : calendarFormat // ignore: cast_nullable_to_non_nullable
                  as CalendarFormat?,
      ),
    );
  }
}
