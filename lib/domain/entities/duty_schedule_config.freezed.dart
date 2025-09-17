// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'duty_schedule_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DutyScheduleConfig {
  String get version;
  Meta get meta;
  Map<String, DutyType> get dutyTypes;
  List<String> get dutyTypeOrder;
  Map<String, Rhythm> get rhythms;
  List<DutyGroup> get dutyGroups;

  /// Create a copy of DutyScheduleConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DutyScheduleConfigCopyWith<DutyScheduleConfig> get copyWith =>
      _$DutyScheduleConfigCopyWithImpl<DutyScheduleConfig>(
        this as DutyScheduleConfig,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DutyScheduleConfig &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.meta, meta) || other.meta == meta) &&
            const DeepCollectionEquality().equals(other.dutyTypes, dutyTypes) &&
            const DeepCollectionEquality().equals(
              other.dutyTypeOrder,
              dutyTypeOrder,
            ) &&
            const DeepCollectionEquality().equals(other.rhythms, rhythms) &&
            const DeepCollectionEquality().equals(
              other.dutyGroups,
              dutyGroups,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    version,
    meta,
    const DeepCollectionEquality().hash(dutyTypes),
    const DeepCollectionEquality().hash(dutyTypeOrder),
    const DeepCollectionEquality().hash(rhythms),
    const DeepCollectionEquality().hash(dutyGroups),
  );

  @override
  String toString() {
    return 'DutyScheduleConfig(version: $version, meta: $meta, dutyTypes: $dutyTypes, dutyTypeOrder: $dutyTypeOrder, rhythms: $rhythms, dutyGroups: $dutyGroups)';
  }
}

/// @nodoc
abstract mixin class $DutyScheduleConfigCopyWith<$Res> {
  factory $DutyScheduleConfigCopyWith(
    DutyScheduleConfig value,
    $Res Function(DutyScheduleConfig) _then,
  ) = _$DutyScheduleConfigCopyWithImpl;
  @useResult
  $Res call({
    String version,
    Meta meta,
    Map<String, DutyType> dutyTypes,
    List<String> dutyTypeOrder,
    Map<String, Rhythm> rhythms,
    List<DutyGroup> dutyGroups,
  });

  $MetaCopyWith<$Res> get meta;
}

/// @nodoc
class _$DutyScheduleConfigCopyWithImpl<$Res>
    implements $DutyScheduleConfigCopyWith<$Res> {
  _$DutyScheduleConfigCopyWithImpl(this._self, this._then);

  final DutyScheduleConfig _self;
  final $Res Function(DutyScheduleConfig) _then;

  /// Create a copy of DutyScheduleConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? version = null,
    Object? meta = null,
    Object? dutyTypes = null,
    Object? dutyTypeOrder = null,
    Object? rhythms = null,
    Object? dutyGroups = null,
  }) {
    return _then(
      _self.copyWith(
        version: null == version
            ? _self.version
            : version // ignore: cast_nullable_to_non_nullable
                  as String,
        meta: null == meta
            ? _self.meta
            : meta // ignore: cast_nullable_to_non_nullable
                  as Meta,
        dutyTypes: null == dutyTypes
            ? _self.dutyTypes
            : dutyTypes // ignore: cast_nullable_to_non_nullable
                  as Map<String, DutyType>,
        dutyTypeOrder: null == dutyTypeOrder
            ? _self.dutyTypeOrder
            : dutyTypeOrder // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        rhythms: null == rhythms
            ? _self.rhythms
            : rhythms // ignore: cast_nullable_to_non_nullable
                  as Map<String, Rhythm>,
        dutyGroups: null == dutyGroups
            ? _self.dutyGroups
            : dutyGroups // ignore: cast_nullable_to_non_nullable
                  as List<DutyGroup>,
      ),
    );
  }

  /// Create a copy of DutyScheduleConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MetaCopyWith<$Res> get meta {
    return $MetaCopyWith<$Res>(_self.meta, (value) {
      return _then(_self.copyWith(meta: value));
    });
  }
}

/// Adds pattern-matching-related methods to [DutyScheduleConfig].
extension DutyScheduleConfigPatterns on DutyScheduleConfig {
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
    TResult Function(_DutyScheduleConfig value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DutyScheduleConfig() when $default != null:
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
    TResult Function(_DutyScheduleConfig value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DutyScheduleConfig():
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
    TResult? Function(_DutyScheduleConfig value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DutyScheduleConfig() when $default != null:
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
      String version,
      Meta meta,
      Map<String, DutyType> dutyTypes,
      List<String> dutyTypeOrder,
      Map<String, Rhythm> rhythms,
      List<DutyGroup> dutyGroups,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DutyScheduleConfig() when $default != null:
        return $default(
          _that.version,
          _that.meta,
          _that.dutyTypes,
          _that.dutyTypeOrder,
          _that.rhythms,
          _that.dutyGroups,
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
      String version,
      Meta meta,
      Map<String, DutyType> dutyTypes,
      List<String> dutyTypeOrder,
      Map<String, Rhythm> rhythms,
      List<DutyGroup> dutyGroups,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DutyScheduleConfig():
        return $default(
          _that.version,
          _that.meta,
          _that.dutyTypes,
          _that.dutyTypeOrder,
          _that.rhythms,
          _that.dutyGroups,
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
      String version,
      Meta meta,
      Map<String, DutyType> dutyTypes,
      List<String> dutyTypeOrder,
      Map<String, Rhythm> rhythms,
      List<DutyGroup> dutyGroups,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DutyScheduleConfig() when $default != null:
        return $default(
          _that.version,
          _that.meta,
          _that.dutyTypes,
          _that.dutyTypeOrder,
          _that.rhythms,
          _that.dutyGroups,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc

class _DutyScheduleConfig extends DutyScheduleConfig {
  const _DutyScheduleConfig({
    required this.version,
    required this.meta,
    required final Map<String, DutyType> dutyTypes,
    required final List<String> dutyTypeOrder,
    required final Map<String, Rhythm> rhythms,
    required final List<DutyGroup> dutyGroups,
  }) : _dutyTypes = dutyTypes,
       _dutyTypeOrder = dutyTypeOrder,
       _rhythms = rhythms,
       _dutyGroups = dutyGroups,
       super._();

  @override
  final String version;
  @override
  final Meta meta;
  final Map<String, DutyType> _dutyTypes;
  @override
  Map<String, DutyType> get dutyTypes {
    if (_dutyTypes is EqualUnmodifiableMapView) return _dutyTypes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_dutyTypes);
  }

  final List<String> _dutyTypeOrder;
  @override
  List<String> get dutyTypeOrder {
    if (_dutyTypeOrder is EqualUnmodifiableListView) return _dutyTypeOrder;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dutyTypeOrder);
  }

  final Map<String, Rhythm> _rhythms;
  @override
  Map<String, Rhythm> get rhythms {
    if (_rhythms is EqualUnmodifiableMapView) return _rhythms;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_rhythms);
  }

  final List<DutyGroup> _dutyGroups;
  @override
  List<DutyGroup> get dutyGroups {
    if (_dutyGroups is EqualUnmodifiableListView) return _dutyGroups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dutyGroups);
  }

  /// Create a copy of DutyScheduleConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DutyScheduleConfigCopyWith<_DutyScheduleConfig> get copyWith =>
      __$DutyScheduleConfigCopyWithImpl<_DutyScheduleConfig>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DutyScheduleConfig &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.meta, meta) || other.meta == meta) &&
            const DeepCollectionEquality().equals(
              other._dutyTypes,
              _dutyTypes,
            ) &&
            const DeepCollectionEquality().equals(
              other._dutyTypeOrder,
              _dutyTypeOrder,
            ) &&
            const DeepCollectionEquality().equals(other._rhythms, _rhythms) &&
            const DeepCollectionEquality().equals(
              other._dutyGroups,
              _dutyGroups,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    version,
    meta,
    const DeepCollectionEquality().hash(_dutyTypes),
    const DeepCollectionEquality().hash(_dutyTypeOrder),
    const DeepCollectionEquality().hash(_rhythms),
    const DeepCollectionEquality().hash(_dutyGroups),
  );

  @override
  String toString() {
    return 'DutyScheduleConfig(version: $version, meta: $meta, dutyTypes: $dutyTypes, dutyTypeOrder: $dutyTypeOrder, rhythms: $rhythms, dutyGroups: $dutyGroups)';
  }
}

/// @nodoc
abstract mixin class _$DutyScheduleConfigCopyWith<$Res>
    implements $DutyScheduleConfigCopyWith<$Res> {
  factory _$DutyScheduleConfigCopyWith(
    _DutyScheduleConfig value,
    $Res Function(_DutyScheduleConfig) _then,
  ) = __$DutyScheduleConfigCopyWithImpl;
  @override
  @useResult
  $Res call({
    String version,
    Meta meta,
    Map<String, DutyType> dutyTypes,
    List<String> dutyTypeOrder,
    Map<String, Rhythm> rhythms,
    List<DutyGroup> dutyGroups,
  });

  @override
  $MetaCopyWith<$Res> get meta;
}

/// @nodoc
class __$DutyScheduleConfigCopyWithImpl<$Res>
    implements _$DutyScheduleConfigCopyWith<$Res> {
  __$DutyScheduleConfigCopyWithImpl(this._self, this._then);

  final _DutyScheduleConfig _self;
  final $Res Function(_DutyScheduleConfig) _then;

  /// Create a copy of DutyScheduleConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? version = null,
    Object? meta = null,
    Object? dutyTypes = null,
    Object? dutyTypeOrder = null,
    Object? rhythms = null,
    Object? dutyGroups = null,
  }) {
    return _then(
      _DutyScheduleConfig(
        version: null == version
            ? _self.version
            : version // ignore: cast_nullable_to_non_nullable
                  as String,
        meta: null == meta
            ? _self.meta
            : meta // ignore: cast_nullable_to_non_nullable
                  as Meta,
        dutyTypes: null == dutyTypes
            ? _self._dutyTypes
            : dutyTypes // ignore: cast_nullable_to_non_nullable
                  as Map<String, DutyType>,
        dutyTypeOrder: null == dutyTypeOrder
            ? _self._dutyTypeOrder
            : dutyTypeOrder // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        rhythms: null == rhythms
            ? _self._rhythms
            : rhythms // ignore: cast_nullable_to_non_nullable
                  as Map<String, Rhythm>,
        dutyGroups: null == dutyGroups
            ? _self._dutyGroups
            : dutyGroups // ignore: cast_nullable_to_non_nullable
                  as List<DutyGroup>,
      ),
    );
  }

  /// Create a copy of DutyScheduleConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MetaCopyWith<$Res> get meta {
    return $MetaCopyWith<$Res>(_self.meta, (value) {
      return _then(_self.copyWith(meta: value));
    });
  }
}
