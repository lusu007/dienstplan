// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Schedule {
  DateTime get date;
  String get service;
  String get dutyGroupId;
  String get dutyTypeId;
  String get dutyGroupName;
  String get configName;
  bool get isAllDay;

  /// Create a copy of Schedule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ScheduleCopyWith<Schedule> get copyWith =>
      _$ScheduleCopyWithImpl<Schedule>(this as Schedule, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Schedule &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.service, service) || other.service == service) &&
            (identical(other.dutyGroupId, dutyGroupId) ||
                other.dutyGroupId == dutyGroupId) &&
            (identical(other.dutyTypeId, dutyTypeId) ||
                other.dutyTypeId == dutyTypeId) &&
            (identical(other.dutyGroupName, dutyGroupName) ||
                other.dutyGroupName == dutyGroupName) &&
            (identical(other.configName, configName) ||
                other.configName == configName) &&
            (identical(other.isAllDay, isAllDay) ||
                other.isAllDay == isAllDay));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    date,
    service,
    dutyGroupId,
    dutyTypeId,
    dutyGroupName,
    configName,
    isAllDay,
  );

  @override
  String toString() {
    return 'Schedule(date: $date, service: $service, dutyGroupId: $dutyGroupId, dutyTypeId: $dutyTypeId, dutyGroupName: $dutyGroupName, configName: $configName, isAllDay: $isAllDay)';
  }
}

/// @nodoc
abstract mixin class $ScheduleCopyWith<$Res> {
  factory $ScheduleCopyWith(Schedule value, $Res Function(Schedule) _then) =
      _$ScheduleCopyWithImpl;
  @useResult
  $Res call({
    DateTime date,
    String service,
    String dutyGroupId,
    String dutyTypeId,
    String dutyGroupName,
    String configName,
    bool isAllDay,
  });
}

/// @nodoc
class _$ScheduleCopyWithImpl<$Res> implements $ScheduleCopyWith<$Res> {
  _$ScheduleCopyWithImpl(this._self, this._then);

  final Schedule _self;
  final $Res Function(Schedule) _then;

  /// Create a copy of Schedule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? service = null,
    Object? dutyGroupId = null,
    Object? dutyTypeId = null,
    Object? dutyGroupName = null,
    Object? configName = null,
    Object? isAllDay = null,
  }) {
    return _then(
      _self.copyWith(
        date: null == date
            ? _self.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        service: null == service
            ? _self.service
            : service // ignore: cast_nullable_to_non_nullable
                  as String,
        dutyGroupId: null == dutyGroupId
            ? _self.dutyGroupId
            : dutyGroupId // ignore: cast_nullable_to_non_nullable
                  as String,
        dutyTypeId: null == dutyTypeId
            ? _self.dutyTypeId
            : dutyTypeId // ignore: cast_nullable_to_non_nullable
                  as String,
        dutyGroupName: null == dutyGroupName
            ? _self.dutyGroupName
            : dutyGroupName // ignore: cast_nullable_to_non_nullable
                  as String,
        configName: null == configName
            ? _self.configName
            : configName // ignore: cast_nullable_to_non_nullable
                  as String,
        isAllDay: null == isAllDay
            ? _self.isAllDay
            : isAllDay // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [Schedule].
extension SchedulePatterns on Schedule {
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
    TResult Function(_Schedule value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Schedule() when $default != null:
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
    TResult Function(_Schedule value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Schedule():
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
    TResult? Function(_Schedule value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Schedule() when $default != null:
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
      DateTime date,
      String service,
      String dutyGroupId,
      String dutyTypeId,
      String dutyGroupName,
      String configName,
      bool isAllDay,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Schedule() when $default != null:
        return $default(
          _that.date,
          _that.service,
          _that.dutyGroupId,
          _that.dutyTypeId,
          _that.dutyGroupName,
          _that.configName,
          _that.isAllDay,
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
      DateTime date,
      String service,
      String dutyGroupId,
      String dutyTypeId,
      String dutyGroupName,
      String configName,
      bool isAllDay,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Schedule():
        return $default(
          _that.date,
          _that.service,
          _that.dutyGroupId,
          _that.dutyTypeId,
          _that.dutyGroupName,
          _that.configName,
          _that.isAllDay,
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
      DateTime date,
      String service,
      String dutyGroupId,
      String dutyTypeId,
      String dutyGroupName,
      String configName,
      bool isAllDay,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Schedule() when $default != null:
        return $default(
          _that.date,
          _that.service,
          _that.dutyGroupId,
          _that.dutyTypeId,
          _that.dutyGroupName,
          _that.configName,
          _that.isAllDay,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Schedule extends Schedule {
  const _Schedule({
    required this.date,
    required this.service,
    required this.dutyGroupId,
    required this.dutyTypeId,
    required this.dutyGroupName,
    required this.configName,
    this.isAllDay = false,
  }) : super._();

  @override
  final DateTime date;
  @override
  final String service;
  @override
  final String dutyGroupId;
  @override
  final String dutyTypeId;
  @override
  final String dutyGroupName;
  @override
  final String configName;
  @override
  @JsonKey()
  final bool isAllDay;

  /// Create a copy of Schedule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ScheduleCopyWith<_Schedule> get copyWith =>
      __$ScheduleCopyWithImpl<_Schedule>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Schedule &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.service, service) || other.service == service) &&
            (identical(other.dutyGroupId, dutyGroupId) ||
                other.dutyGroupId == dutyGroupId) &&
            (identical(other.dutyTypeId, dutyTypeId) ||
                other.dutyTypeId == dutyTypeId) &&
            (identical(other.dutyGroupName, dutyGroupName) ||
                other.dutyGroupName == dutyGroupName) &&
            (identical(other.configName, configName) ||
                other.configName == configName) &&
            (identical(other.isAllDay, isAllDay) ||
                other.isAllDay == isAllDay));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    date,
    service,
    dutyGroupId,
    dutyTypeId,
    dutyGroupName,
    configName,
    isAllDay,
  );

  @override
  String toString() {
    return 'Schedule(date: $date, service: $service, dutyGroupId: $dutyGroupId, dutyTypeId: $dutyTypeId, dutyGroupName: $dutyGroupName, configName: $configName, isAllDay: $isAllDay)';
  }
}

/// @nodoc
abstract mixin class _$ScheduleCopyWith<$Res>
    implements $ScheduleCopyWith<$Res> {
  factory _$ScheduleCopyWith(_Schedule value, $Res Function(_Schedule) _then) =
      __$ScheduleCopyWithImpl;
  @override
  @useResult
  $Res call({
    DateTime date,
    String service,
    String dutyGroupId,
    String dutyTypeId,
    String dutyGroupName,
    String configName,
    bool isAllDay,
  });
}

/// @nodoc
class __$ScheduleCopyWithImpl<$Res> implements _$ScheduleCopyWith<$Res> {
  __$ScheduleCopyWithImpl(this._self, this._then);

  final _Schedule _self;
  final $Res Function(_Schedule) _then;

  /// Create a copy of Schedule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? date = null,
    Object? service = null,
    Object? dutyGroupId = null,
    Object? dutyTypeId = null,
    Object? dutyGroupName = null,
    Object? configName = null,
    Object? isAllDay = null,
  }) {
    return _then(
      _Schedule(
        date: null == date
            ? _self.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        service: null == service
            ? _self.service
            : service // ignore: cast_nullable_to_non_nullable
                  as String,
        dutyGroupId: null == dutyGroupId
            ? _self.dutyGroupId
            : dutyGroupId // ignore: cast_nullable_to_non_nullable
                  as String,
        dutyTypeId: null == dutyTypeId
            ? _self.dutyTypeId
            : dutyTypeId // ignore: cast_nullable_to_non_nullable
                  as String,
        dutyGroupName: null == dutyGroupName
            ? _self.dutyGroupName
            : dutyGroupName // ignore: cast_nullable_to_non_nullable
                  as String,
        configName: null == configName
            ? _self.configName
            : configName // ignore: cast_nullable_to_non_nullable
                  as String,
        isAllDay: null == isAllDay
            ? _self.isAllDay
            : isAllDay // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}
