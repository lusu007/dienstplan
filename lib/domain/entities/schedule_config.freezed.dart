// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ScheduleConfig {
  ScheduleMeta get meta;
  List<ScheduleService> get services;
  String get version;

  /// Create a copy of ScheduleConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ScheduleConfigCopyWith<ScheduleConfig> get copyWith =>
      _$ScheduleConfigCopyWithImpl<ScheduleConfig>(
        this as ScheduleConfig,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ScheduleConfig &&
            (identical(other.meta, meta) || other.meta == meta) &&
            const DeepCollectionEquality().equals(other.services, services) &&
            (identical(other.version, version) || other.version == version));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    meta,
    const DeepCollectionEquality().hash(services),
    version,
  );

  @override
  String toString() {
    return 'ScheduleConfig(meta: $meta, services: $services, version: $version)';
  }
}

/// @nodoc
abstract mixin class $ScheduleConfigCopyWith<$Res> {
  factory $ScheduleConfigCopyWith(
    ScheduleConfig value,
    $Res Function(ScheduleConfig) _then,
  ) = _$ScheduleConfigCopyWithImpl;
  @useResult
  $Res call({
    ScheduleMeta meta,
    List<ScheduleService> services,
    String version,
  });

  $ScheduleMetaCopyWith<$Res> get meta;
}

/// @nodoc
class _$ScheduleConfigCopyWithImpl<$Res>
    implements $ScheduleConfigCopyWith<$Res> {
  _$ScheduleConfigCopyWithImpl(this._self, this._then);

  final ScheduleConfig _self;
  final $Res Function(ScheduleConfig) _then;

  /// Create a copy of ScheduleConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? meta = null,
    Object? services = null,
    Object? version = null,
  }) {
    return _then(
      _self.copyWith(
        meta: null == meta
            ? _self.meta
            : meta // ignore: cast_nullable_to_non_nullable
                  as ScheduleMeta,
        services: null == services
            ? _self.services
            : services // ignore: cast_nullable_to_non_nullable
                  as List<ScheduleService>,
        version: null == version
            ? _self.version
            : version // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }

  /// Create a copy of ScheduleConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScheduleMetaCopyWith<$Res> get meta {
    return $ScheduleMetaCopyWith<$Res>(_self.meta, (value) {
      return _then(_self.copyWith(meta: value));
    });
  }
}

/// Adds pattern-matching-related methods to [ScheduleConfig].
extension ScheduleConfigPatterns on ScheduleConfig {
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
    TResult Function(_ScheduleConfig value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ScheduleConfig() when $default != null:
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
    TResult Function(_ScheduleConfig value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleConfig():
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
    TResult? Function(_ScheduleConfig value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleConfig() when $default != null:
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
      ScheduleMeta meta,
      List<ScheduleService> services,
      String version,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ScheduleConfig() when $default != null:
        return $default(_that.meta, _that.services, _that.version);
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
      ScheduleMeta meta,
      List<ScheduleService> services,
      String version,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleConfig():
        return $default(_that.meta, _that.services, _that.version);
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
      ScheduleMeta meta,
      List<ScheduleService> services,
      String version,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleConfig() when $default != null:
        return $default(_that.meta, _that.services, _that.version);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ScheduleConfig extends ScheduleConfig {
  const _ScheduleConfig({
    required this.meta,
    required final List<ScheduleService> services,
    required this.version,
  }) : _services = services,
       super._();

  @override
  final ScheduleMeta meta;
  final List<ScheduleService> _services;
  @override
  List<ScheduleService> get services {
    if (_services is EqualUnmodifiableListView) return _services;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_services);
  }

  @override
  final String version;

  /// Create a copy of ScheduleConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ScheduleConfigCopyWith<_ScheduleConfig> get copyWith =>
      __$ScheduleConfigCopyWithImpl<_ScheduleConfig>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ScheduleConfig &&
            (identical(other.meta, meta) || other.meta == meta) &&
            const DeepCollectionEquality().equals(other._services, _services) &&
            (identical(other.version, version) || other.version == version));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    meta,
    const DeepCollectionEquality().hash(_services),
    version,
  );

  @override
  String toString() {
    return 'ScheduleConfig(meta: $meta, services: $services, version: $version)';
  }
}

/// @nodoc
abstract mixin class _$ScheduleConfigCopyWith<$Res>
    implements $ScheduleConfigCopyWith<$Res> {
  factory _$ScheduleConfigCopyWith(
    _ScheduleConfig value,
    $Res Function(_ScheduleConfig) _then,
  ) = __$ScheduleConfigCopyWithImpl;
  @override
  @useResult
  $Res call({
    ScheduleMeta meta,
    List<ScheduleService> services,
    String version,
  });

  @override
  $ScheduleMetaCopyWith<$Res> get meta;
}

/// @nodoc
class __$ScheduleConfigCopyWithImpl<$Res>
    implements _$ScheduleConfigCopyWith<$Res> {
  __$ScheduleConfigCopyWithImpl(this._self, this._then);

  final _ScheduleConfig _self;
  final $Res Function(_ScheduleConfig) _then;

  /// Create a copy of ScheduleConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? meta = null,
    Object? services = null,
    Object? version = null,
  }) {
    return _then(
      _ScheduleConfig(
        meta: null == meta
            ? _self.meta
            : meta // ignore: cast_nullable_to_non_nullable
                  as ScheduleMeta,
        services: null == services
            ? _self._services
            : services // ignore: cast_nullable_to_non_nullable
                  as List<ScheduleService>,
        version: null == version
            ? _self.version
            : version // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }

  /// Create a copy of ScheduleConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScheduleMetaCopyWith<$Res> get meta {
    return $ScheduleMetaCopyWith<$Res>(_self.meta, (value) {
      return _then(_self.copyWith(meta: value));
    });
  }
}

/// @nodoc
mixin _$ScheduleMeta {
  String get name;
  String get description;

  /// Create a copy of ScheduleMeta
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ScheduleMetaCopyWith<ScheduleMeta> get copyWith =>
      _$ScheduleMetaCopyWithImpl<ScheduleMeta>(
        this as ScheduleMeta,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ScheduleMeta &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @override
  int get hashCode => Object.hash(runtimeType, name, description);

  @override
  String toString() {
    return 'ScheduleMeta(name: $name, description: $description)';
  }
}

/// @nodoc
abstract mixin class $ScheduleMetaCopyWith<$Res> {
  factory $ScheduleMetaCopyWith(
    ScheduleMeta value,
    $Res Function(ScheduleMeta) _then,
  ) = _$ScheduleMetaCopyWithImpl;
  @useResult
  $Res call({String name, String description});
}

/// @nodoc
class _$ScheduleMetaCopyWithImpl<$Res> implements $ScheduleMetaCopyWith<$Res> {
  _$ScheduleMetaCopyWithImpl(this._self, this._then);

  final ScheduleMeta _self;
  final $Res Function(ScheduleMeta) _then;

  /// Create a copy of ScheduleMeta
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? description = null}) {
    return _then(
      _self.copyWith(
        name: null == name
            ? _self.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _self.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [ScheduleMeta].
extension ScheduleMetaPatterns on ScheduleMeta {
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
    TResult Function(_ScheduleMeta value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ScheduleMeta() when $default != null:
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
    TResult Function(_ScheduleMeta value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleMeta():
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
    TResult? Function(_ScheduleMeta value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleMeta() when $default != null:
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
    TResult Function(String name, String description)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ScheduleMeta() when $default != null:
        return $default(_that.name, _that.description);
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
    TResult Function(String name, String description) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleMeta():
        return $default(_that.name, _that.description);
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
    TResult? Function(String name, String description)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleMeta() when $default != null:
        return $default(_that.name, _that.description);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ScheduleMeta extends ScheduleMeta {
  const _ScheduleMeta({required this.name, required this.description})
    : super._();

  @override
  final String name;
  @override
  final String description;

  /// Create a copy of ScheduleMeta
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ScheduleMetaCopyWith<_ScheduleMeta> get copyWith =>
      __$ScheduleMetaCopyWithImpl<_ScheduleMeta>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ScheduleMeta &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @override
  int get hashCode => Object.hash(runtimeType, name, description);

  @override
  String toString() {
    return 'ScheduleMeta(name: $name, description: $description)';
  }
}

/// @nodoc
abstract mixin class _$ScheduleMetaCopyWith<$Res>
    implements $ScheduleMetaCopyWith<$Res> {
  factory _$ScheduleMetaCopyWith(
    _ScheduleMeta value,
    $Res Function(_ScheduleMeta) _then,
  ) = __$ScheduleMetaCopyWithImpl;
  @override
  @useResult
  $Res call({String name, String description});
}

/// @nodoc
class __$ScheduleMetaCopyWithImpl<$Res>
    implements _$ScheduleMetaCopyWith<$Res> {
  __$ScheduleMetaCopyWithImpl(this._self, this._then);

  final _ScheduleMeta _self;
  final $Res Function(_ScheduleMeta) _then;

  /// Create a copy of ScheduleMeta
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({Object? name = null, Object? description = null}) {
    return _then(
      _ScheduleMeta(
        name: null == name
            ? _self.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _self.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
mixin _$ScheduleService {
  String get name;
  List<String> get persons;

  /// Create a copy of ScheduleService
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ScheduleServiceCopyWith<ScheduleService> get copyWith =>
      _$ScheduleServiceCopyWithImpl<ScheduleService>(
        this as ScheduleService,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ScheduleService &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other.persons, persons));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    const DeepCollectionEquality().hash(persons),
  );

  @override
  String toString() {
    return 'ScheduleService(name: $name, persons: $persons)';
  }
}

/// @nodoc
abstract mixin class $ScheduleServiceCopyWith<$Res> {
  factory $ScheduleServiceCopyWith(
    ScheduleService value,
    $Res Function(ScheduleService) _then,
  ) = _$ScheduleServiceCopyWithImpl;
  @useResult
  $Res call({String name, List<String> persons});
}

/// @nodoc
class _$ScheduleServiceCopyWithImpl<$Res>
    implements $ScheduleServiceCopyWith<$Res> {
  _$ScheduleServiceCopyWithImpl(this._self, this._then);

  final ScheduleService _self;
  final $Res Function(ScheduleService) _then;

  /// Create a copy of ScheduleService
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? persons = null}) {
    return _then(
      _self.copyWith(
        name: null == name
            ? _self.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        persons: null == persons
            ? _self.persons
            : persons // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [ScheduleService].
extension ScheduleServicePatterns on ScheduleService {
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
    TResult Function(_ScheduleService value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ScheduleService() when $default != null:
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
    TResult Function(_ScheduleService value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleService():
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
    TResult? Function(_ScheduleService value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleService() when $default != null:
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
    TResult Function(String name, List<String> persons)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ScheduleService() when $default != null:
        return $default(_that.name, _that.persons);
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
    TResult Function(String name, List<String> persons) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleService():
        return $default(_that.name, _that.persons);
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
    TResult? Function(String name, List<String> persons)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleService() when $default != null:
        return $default(_that.name, _that.persons);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ScheduleService extends ScheduleService {
  const _ScheduleService({
    required this.name,
    required final List<String> persons,
  }) : _persons = persons,
       super._();

  @override
  final String name;
  final List<String> _persons;
  @override
  List<String> get persons {
    if (_persons is EqualUnmodifiableListView) return _persons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_persons);
  }

  /// Create a copy of ScheduleService
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ScheduleServiceCopyWith<_ScheduleService> get copyWith =>
      __$ScheduleServiceCopyWithImpl<_ScheduleService>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ScheduleService &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other._persons, _persons));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    const DeepCollectionEquality().hash(_persons),
  );

  @override
  String toString() {
    return 'ScheduleService(name: $name, persons: $persons)';
  }
}

/// @nodoc
abstract mixin class _$ScheduleServiceCopyWith<$Res>
    implements $ScheduleServiceCopyWith<$Res> {
  factory _$ScheduleServiceCopyWith(
    _ScheduleService value,
    $Res Function(_ScheduleService) _then,
  ) = __$ScheduleServiceCopyWithImpl;
  @override
  @useResult
  $Res call({String name, List<String> persons});
}

/// @nodoc
class __$ScheduleServiceCopyWithImpl<$Res>
    implements _$ScheduleServiceCopyWith<$Res> {
  __$ScheduleServiceCopyWithImpl(this._self, this._then);

  final _ScheduleService _self;
  final $Res Function(_ScheduleService) _then;

  /// Create a copy of ScheduleService
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({Object? name = null, Object? persons = null}) {
    return _then(
      _ScheduleService(
        name: null == name
            ? _self.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        persons: null == persons
            ? _self._persons
            : persons // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}
