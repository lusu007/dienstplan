// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'german_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GermanState {
  String get code;
  String get name;
  String get fullName;
  String? get apiId;

  /// Create a copy of GermanState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GermanStateCopyWith<GermanState> get copyWith =>
      _$GermanStateCopyWithImpl<GermanState>(this as GermanState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GermanState &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.apiId, apiId) || other.apiId == apiId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, code, name, fullName, apiId);

  @override
  String toString() {
    return 'GermanState(code: $code, name: $name, fullName: $fullName, apiId: $apiId)';
  }
}

/// @nodoc
abstract mixin class $GermanStateCopyWith<$Res> {
  factory $GermanStateCopyWith(
    GermanState value,
    $Res Function(GermanState) _then,
  ) = _$GermanStateCopyWithImpl;
  @useResult
  $Res call({String code, String name, String fullName, String? apiId});
}

/// @nodoc
class _$GermanStateCopyWithImpl<$Res> implements $GermanStateCopyWith<$Res> {
  _$GermanStateCopyWithImpl(this._self, this._then);

  final GermanState _self;
  final $Res Function(GermanState) _then;

  /// Create a copy of GermanState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? name = null,
    Object? fullName = null,
    Object? apiId = freezed,
  }) {
    return _then(
      _self.copyWith(
        code: null == code
            ? _self.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _self.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        fullName: null == fullName
            ? _self.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
                  as String,
        apiId: freezed == apiId
            ? _self.apiId
            : apiId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [GermanState].
extension GermanStatePatterns on GermanState {
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
    TResult Function(_GermanState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GermanState() when $default != null:
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
    TResult Function(_GermanState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GermanState():
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
    TResult? Function(_GermanState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GermanState() when $default != null:
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
    TResult Function(String code, String name, String fullName, String? apiId)?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GermanState() when $default != null:
        return $default(_that.code, _that.name, _that.fullName, _that.apiId);
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
    TResult Function(String code, String name, String fullName, String? apiId)
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GermanState():
        return $default(_that.code, _that.name, _that.fullName, _that.apiId);
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
    TResult? Function(String code, String name, String fullName, String? apiId)?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GermanState() when $default != null:
        return $default(_that.code, _that.name, _that.fullName, _that.apiId);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _GermanState extends GermanState {
  const _GermanState({
    required this.code,
    required this.name,
    required this.fullName,
    this.apiId,
  }) : super._();

  @override
  final String code;
  @override
  final String name;
  @override
  final String fullName;
  @override
  final String? apiId;

  /// Create a copy of GermanState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GermanStateCopyWith<_GermanState> get copyWith =>
      __$GermanStateCopyWithImpl<_GermanState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GermanState &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.apiId, apiId) || other.apiId == apiId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, code, name, fullName, apiId);

  @override
  String toString() {
    return 'GermanState(code: $code, name: $name, fullName: $fullName, apiId: $apiId)';
  }
}

/// @nodoc
abstract mixin class _$GermanStateCopyWith<$Res>
    implements $GermanStateCopyWith<$Res> {
  factory _$GermanStateCopyWith(
    _GermanState value,
    $Res Function(_GermanState) _then,
  ) = __$GermanStateCopyWithImpl;
  @override
  @useResult
  $Res call({String code, String name, String fullName, String? apiId});
}

/// @nodoc
class __$GermanStateCopyWithImpl<$Res> implements _$GermanStateCopyWith<$Res> {
  __$GermanStateCopyWithImpl(this._self, this._then);

  final _GermanState _self;
  final $Res Function(_GermanState) _then;

  /// Create a copy of GermanState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? code = null,
    Object? name = null,
    Object? fullName = null,
    Object? apiId = freezed,
  }) {
    return _then(
      _GermanState(
        code: null == code
            ? _self.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _self.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        fullName: null == fullName
            ? _self.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
                  as String,
        apiId: freezed == apiId
            ? _self.apiId
            : apiId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}
