// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'partner_ui_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PartnerUiState {
  bool get isLoading;
  String? get error;
  String? get partnerConfigName;
  String? get partnerDutyGroup;
  int? get partnerAccentColorValue;
  int? get myAccentColorValue;

  /// Create a copy of PartnerUiState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PartnerUiStateCopyWith<PartnerUiState> get copyWith =>
      _$PartnerUiStateCopyWithImpl<PartnerUiState>(
        this as PartnerUiState,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PartnerUiState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.partnerConfigName, partnerConfigName) ||
                other.partnerConfigName == partnerConfigName) &&
            (identical(other.partnerDutyGroup, partnerDutyGroup) ||
                other.partnerDutyGroup == partnerDutyGroup) &&
            (identical(
                  other.partnerAccentColorValue,
                  partnerAccentColorValue,
                ) ||
                other.partnerAccentColorValue == partnerAccentColorValue) &&
            (identical(other.myAccentColorValue, myAccentColorValue) ||
                other.myAccentColorValue == myAccentColorValue));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    isLoading,
    error,
    partnerConfigName,
    partnerDutyGroup,
    partnerAccentColorValue,
    myAccentColorValue,
  );

  @override
  String toString() {
    return 'PartnerUiState(isLoading: $isLoading, error: $error, partnerConfigName: $partnerConfigName, partnerDutyGroup: $partnerDutyGroup, partnerAccentColorValue: $partnerAccentColorValue, myAccentColorValue: $myAccentColorValue)';
  }
}

/// @nodoc
abstract mixin class $PartnerUiStateCopyWith<$Res> {
  factory $PartnerUiStateCopyWith(
    PartnerUiState value,
    $Res Function(PartnerUiState) _then,
  ) = _$PartnerUiStateCopyWithImpl;
  @useResult
  $Res call({
    bool isLoading,
    String? error,
    String? partnerConfigName,
    String? partnerDutyGroup,
    int? partnerAccentColorValue,
    int? myAccentColorValue,
  });
}

/// @nodoc
class _$PartnerUiStateCopyWithImpl<$Res>
    implements $PartnerUiStateCopyWith<$Res> {
  _$PartnerUiStateCopyWithImpl(this._self, this._then);

  final PartnerUiState _self;
  final $Res Function(PartnerUiState) _then;

  /// Create a copy of PartnerUiState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? partnerConfigName = freezed,
    Object? partnerDutyGroup = freezed,
    Object? partnerAccentColorValue = freezed,
    Object? myAccentColorValue = freezed,
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
        partnerConfigName: freezed == partnerConfigName
            ? _self.partnerConfigName
            : partnerConfigName // ignore: cast_nullable_to_non_nullable
                  as String?,
        partnerDutyGroup: freezed == partnerDutyGroup
            ? _self.partnerDutyGroup
            : partnerDutyGroup // ignore: cast_nullable_to_non_nullable
                  as String?,
        partnerAccentColorValue: freezed == partnerAccentColorValue
            ? _self.partnerAccentColorValue
            : partnerAccentColorValue // ignore: cast_nullable_to_non_nullable
                  as int?,
        myAccentColorValue: freezed == myAccentColorValue
            ? _self.myAccentColorValue
            : myAccentColorValue // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [PartnerUiState].
extension PartnerUiStatePatterns on PartnerUiState {
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
    TResult Function(_PartnerUiState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PartnerUiState() when $default != null:
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
    TResult Function(_PartnerUiState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PartnerUiState():
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
    TResult? Function(_PartnerUiState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PartnerUiState() when $default != null:
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
      String? partnerConfigName,
      String? partnerDutyGroup,
      int? partnerAccentColorValue,
      int? myAccentColorValue,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PartnerUiState() when $default != null:
        return $default(
          _that.isLoading,
          _that.error,
          _that.partnerConfigName,
          _that.partnerDutyGroup,
          _that.partnerAccentColorValue,
          _that.myAccentColorValue,
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
      String? partnerConfigName,
      String? partnerDutyGroup,
      int? partnerAccentColorValue,
      int? myAccentColorValue,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PartnerUiState():
        return $default(
          _that.isLoading,
          _that.error,
          _that.partnerConfigName,
          _that.partnerDutyGroup,
          _that.partnerAccentColorValue,
          _that.myAccentColorValue,
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
      String? partnerConfigName,
      String? partnerDutyGroup,
      int? partnerAccentColorValue,
      int? myAccentColorValue,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PartnerUiState() when $default != null:
        return $default(
          _that.isLoading,
          _that.error,
          _that.partnerConfigName,
          _that.partnerDutyGroup,
          _that.partnerAccentColorValue,
          _that.myAccentColorValue,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc

class _PartnerUiState extends PartnerUiState {
  const _PartnerUiState({
    required this.isLoading,
    this.error,
    this.partnerConfigName,
    this.partnerDutyGroup,
    this.partnerAccentColorValue,
    this.myAccentColorValue,
  }) : super._();

  @override
  final bool isLoading;
  @override
  final String? error;
  @override
  final String? partnerConfigName;
  @override
  final String? partnerDutyGroup;
  @override
  final int? partnerAccentColorValue;
  @override
  final int? myAccentColorValue;

  /// Create a copy of PartnerUiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PartnerUiStateCopyWith<_PartnerUiState> get copyWith =>
      __$PartnerUiStateCopyWithImpl<_PartnerUiState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PartnerUiState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.partnerConfigName, partnerConfigName) ||
                other.partnerConfigName == partnerConfigName) &&
            (identical(other.partnerDutyGroup, partnerDutyGroup) ||
                other.partnerDutyGroup == partnerDutyGroup) &&
            (identical(
                  other.partnerAccentColorValue,
                  partnerAccentColorValue,
                ) ||
                other.partnerAccentColorValue == partnerAccentColorValue) &&
            (identical(other.myAccentColorValue, myAccentColorValue) ||
                other.myAccentColorValue == myAccentColorValue));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    isLoading,
    error,
    partnerConfigName,
    partnerDutyGroup,
    partnerAccentColorValue,
    myAccentColorValue,
  );

  @override
  String toString() {
    return 'PartnerUiState(isLoading: $isLoading, error: $error, partnerConfigName: $partnerConfigName, partnerDutyGroup: $partnerDutyGroup, partnerAccentColorValue: $partnerAccentColorValue, myAccentColorValue: $myAccentColorValue)';
  }
}

/// @nodoc
abstract mixin class _$PartnerUiStateCopyWith<$Res>
    implements $PartnerUiStateCopyWith<$Res> {
  factory _$PartnerUiStateCopyWith(
    _PartnerUiState value,
    $Res Function(_PartnerUiState) _then,
  ) = __$PartnerUiStateCopyWithImpl;
  @override
  @useResult
  $Res call({
    bool isLoading,
    String? error,
    String? partnerConfigName,
    String? partnerDutyGroup,
    int? partnerAccentColorValue,
    int? myAccentColorValue,
  });
}

/// @nodoc
class __$PartnerUiStateCopyWithImpl<$Res>
    implements _$PartnerUiStateCopyWith<$Res> {
  __$PartnerUiStateCopyWithImpl(this._self, this._then);

  final _PartnerUiState _self;
  final $Res Function(_PartnerUiState) _then;

  /// Create a copy of PartnerUiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? partnerConfigName = freezed,
    Object? partnerDutyGroup = freezed,
    Object? partnerAccentColorValue = freezed,
    Object? myAccentColorValue = freezed,
  }) {
    return _then(
      _PartnerUiState(
        isLoading: null == isLoading
            ? _self.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _self.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        partnerConfigName: freezed == partnerConfigName
            ? _self.partnerConfigName
            : partnerConfigName // ignore: cast_nullable_to_non_nullable
                  as String?,
        partnerDutyGroup: freezed == partnerDutyGroup
            ? _self.partnerDutyGroup
            : partnerDutyGroup // ignore: cast_nullable_to_non_nullable
                  as String?,
        partnerAccentColorValue: freezed == partnerAccentColorValue
            ? _self.partnerAccentColorValue
            : partnerAccentColorValue // ignore: cast_nullable_to_non_nullable
                  as int?,
        myAccentColorValue: freezed == myAccentColorValue
            ? _self.myAccentColorValue
            : myAccentColorValue // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}
