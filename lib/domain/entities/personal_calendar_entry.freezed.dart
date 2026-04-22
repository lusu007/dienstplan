// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'personal_calendar_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PersonalCalendarEntry {
  String get id;
  PersonalCalendarEntryKind get kind;
  String get title;
  String? get notes;
  DateTime get date;
  bool get isAllDay;
  int? get startMinutesFromMidnight;
  int? get endMinutesFromMidnight;
  String get dutyGroupName;
  int get createdAtMs;
  int get updatedAtMs;

  /// Create a copy of PersonalCalendarEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PersonalCalendarEntryCopyWith<PersonalCalendarEntry> get copyWith =>
      _$PersonalCalendarEntryCopyWithImpl<PersonalCalendarEntry>(
        this as PersonalCalendarEntry,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PersonalCalendarEntry &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.kind, kind) || other.kind == kind) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.isAllDay, isAllDay) ||
                other.isAllDay == isAllDay) &&
            (identical(
                  other.startMinutesFromMidnight,
                  startMinutesFromMidnight,
                ) ||
                other.startMinutesFromMidnight == startMinutesFromMidnight) &&
            (identical(other.endMinutesFromMidnight, endMinutesFromMidnight) ||
                other.endMinutesFromMidnight == endMinutesFromMidnight) &&
            (identical(other.dutyGroupName, dutyGroupName) ||
                other.dutyGroupName == dutyGroupName) &&
            (identical(other.createdAtMs, createdAtMs) ||
                other.createdAtMs == createdAtMs) &&
            (identical(other.updatedAtMs, updatedAtMs) ||
                other.updatedAtMs == updatedAtMs));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    kind,
    title,
    notes,
    date,
    isAllDay,
    startMinutesFromMidnight,
    endMinutesFromMidnight,
    dutyGroupName,
    createdAtMs,
    updatedAtMs,
  );

  @override
  String toString() {
    return 'PersonalCalendarEntry(id: $id, kind: $kind, title: $title, notes: $notes, date: $date, isAllDay: $isAllDay, startMinutesFromMidnight: $startMinutesFromMidnight, endMinutesFromMidnight: $endMinutesFromMidnight, dutyGroupName: $dutyGroupName, createdAtMs: $createdAtMs, updatedAtMs: $updatedAtMs)';
  }
}

/// @nodoc
abstract mixin class $PersonalCalendarEntryCopyWith<$Res> {
  factory $PersonalCalendarEntryCopyWith(
    PersonalCalendarEntry value,
    $Res Function(PersonalCalendarEntry) _then,
  ) = _$PersonalCalendarEntryCopyWithImpl;
  @useResult
  $Res call({
    String id,
    PersonalCalendarEntryKind kind,
    String title,
    String? notes,
    DateTime date,
    bool isAllDay,
    int? startMinutesFromMidnight,
    int? endMinutesFromMidnight,
    String dutyGroupName,
    int createdAtMs,
    int updatedAtMs,
  });
}

/// @nodoc
class _$PersonalCalendarEntryCopyWithImpl<$Res>
    implements $PersonalCalendarEntryCopyWith<$Res> {
  _$PersonalCalendarEntryCopyWithImpl(this._self, this._then);

  final PersonalCalendarEntry _self;
  final $Res Function(PersonalCalendarEntry) _then;

  /// Create a copy of PersonalCalendarEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? kind = null,
    Object? title = null,
    Object? notes = freezed,
    Object? date = null,
    Object? isAllDay = null,
    Object? startMinutesFromMidnight = freezed,
    Object? endMinutesFromMidnight = freezed,
    Object? dutyGroupName = null,
    Object? createdAtMs = null,
    Object? updatedAtMs = null,
  }) {
    return _then(
      _self.copyWith(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        kind: null == kind
            ? _self.kind
            : kind // ignore: cast_nullable_to_non_nullable
                  as PersonalCalendarEntryKind,
        title: null == title
            ? _self.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        notes: freezed == notes
            ? _self.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        date: null == date
            ? _self.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        isAllDay: null == isAllDay
            ? _self.isAllDay
            : isAllDay // ignore: cast_nullable_to_non_nullable
                  as bool,
        startMinutesFromMidnight: freezed == startMinutesFromMidnight
            ? _self.startMinutesFromMidnight
            : startMinutesFromMidnight // ignore: cast_nullable_to_non_nullable
                  as int?,
        endMinutesFromMidnight: freezed == endMinutesFromMidnight
            ? _self.endMinutesFromMidnight
            : endMinutesFromMidnight // ignore: cast_nullable_to_non_nullable
                  as int?,
        dutyGroupName: null == dutyGroupName
            ? _self.dutyGroupName
            : dutyGroupName // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAtMs: null == createdAtMs
            ? _self.createdAtMs
            : createdAtMs // ignore: cast_nullable_to_non_nullable
                  as int,
        updatedAtMs: null == updatedAtMs
            ? _self.updatedAtMs
            : updatedAtMs // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [PersonalCalendarEntry].
extension PersonalCalendarEntryPatterns on PersonalCalendarEntry {
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
    TResult Function(_PersonalCalendarEntry value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PersonalCalendarEntry() when $default != null:
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
    TResult Function(_PersonalCalendarEntry value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PersonalCalendarEntry():
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
    TResult? Function(_PersonalCalendarEntry value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PersonalCalendarEntry() when $default != null:
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
      String id,
      PersonalCalendarEntryKind kind,
      String title,
      String? notes,
      DateTime date,
      bool isAllDay,
      int? startMinutesFromMidnight,
      int? endMinutesFromMidnight,
      String dutyGroupName,
      int createdAtMs,
      int updatedAtMs,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PersonalCalendarEntry() when $default != null:
        return $default(
          _that.id,
          _that.kind,
          _that.title,
          _that.notes,
          _that.date,
          _that.isAllDay,
          _that.startMinutesFromMidnight,
          _that.endMinutesFromMidnight,
          _that.dutyGroupName,
          _that.createdAtMs,
          _that.updatedAtMs,
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
      String id,
      PersonalCalendarEntryKind kind,
      String title,
      String? notes,
      DateTime date,
      bool isAllDay,
      int? startMinutesFromMidnight,
      int? endMinutesFromMidnight,
      String dutyGroupName,
      int createdAtMs,
      int updatedAtMs,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PersonalCalendarEntry():
        return $default(
          _that.id,
          _that.kind,
          _that.title,
          _that.notes,
          _that.date,
          _that.isAllDay,
          _that.startMinutesFromMidnight,
          _that.endMinutesFromMidnight,
          _that.dutyGroupName,
          _that.createdAtMs,
          _that.updatedAtMs,
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
      String id,
      PersonalCalendarEntryKind kind,
      String title,
      String? notes,
      DateTime date,
      bool isAllDay,
      int? startMinutesFromMidnight,
      int? endMinutesFromMidnight,
      String dutyGroupName,
      int createdAtMs,
      int updatedAtMs,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PersonalCalendarEntry() when $default != null:
        return $default(
          _that.id,
          _that.kind,
          _that.title,
          _that.notes,
          _that.date,
          _that.isAllDay,
          _that.startMinutesFromMidnight,
          _that.endMinutesFromMidnight,
          _that.dutyGroupName,
          _that.createdAtMs,
          _that.updatedAtMs,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc

class _PersonalCalendarEntry implements PersonalCalendarEntry {
  const _PersonalCalendarEntry({
    required this.id,
    required this.kind,
    required this.title,
    this.notes,
    required this.date,
    required this.isAllDay,
    this.startMinutesFromMidnight,
    this.endMinutesFromMidnight,
    required this.dutyGroupName,
    required this.createdAtMs,
    required this.updatedAtMs,
  });

  @override
  final String id;
  @override
  final PersonalCalendarEntryKind kind;
  @override
  final String title;
  @override
  final String? notes;
  @override
  final DateTime date;
  @override
  final bool isAllDay;
  @override
  final int? startMinutesFromMidnight;
  @override
  final int? endMinutesFromMidnight;
  @override
  final String dutyGroupName;
  @override
  final int createdAtMs;
  @override
  final int updatedAtMs;

  /// Create a copy of PersonalCalendarEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PersonalCalendarEntryCopyWith<_PersonalCalendarEntry> get copyWith =>
      __$PersonalCalendarEntryCopyWithImpl<_PersonalCalendarEntry>(
        this,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PersonalCalendarEntry &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.kind, kind) || other.kind == kind) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.isAllDay, isAllDay) ||
                other.isAllDay == isAllDay) &&
            (identical(
                  other.startMinutesFromMidnight,
                  startMinutesFromMidnight,
                ) ||
                other.startMinutesFromMidnight == startMinutesFromMidnight) &&
            (identical(other.endMinutesFromMidnight, endMinutesFromMidnight) ||
                other.endMinutesFromMidnight == endMinutesFromMidnight) &&
            (identical(other.dutyGroupName, dutyGroupName) ||
                other.dutyGroupName == dutyGroupName) &&
            (identical(other.createdAtMs, createdAtMs) ||
                other.createdAtMs == createdAtMs) &&
            (identical(other.updatedAtMs, updatedAtMs) ||
                other.updatedAtMs == updatedAtMs));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    kind,
    title,
    notes,
    date,
    isAllDay,
    startMinutesFromMidnight,
    endMinutesFromMidnight,
    dutyGroupName,
    createdAtMs,
    updatedAtMs,
  );

  @override
  String toString() {
    return 'PersonalCalendarEntry(id: $id, kind: $kind, title: $title, notes: $notes, date: $date, isAllDay: $isAllDay, startMinutesFromMidnight: $startMinutesFromMidnight, endMinutesFromMidnight: $endMinutesFromMidnight, dutyGroupName: $dutyGroupName, createdAtMs: $createdAtMs, updatedAtMs: $updatedAtMs)';
  }
}

/// @nodoc
abstract mixin class _$PersonalCalendarEntryCopyWith<$Res>
    implements $PersonalCalendarEntryCopyWith<$Res> {
  factory _$PersonalCalendarEntryCopyWith(
    _PersonalCalendarEntry value,
    $Res Function(_PersonalCalendarEntry) _then,
  ) = __$PersonalCalendarEntryCopyWithImpl;
  @override
  @useResult
  $Res call({
    String id,
    PersonalCalendarEntryKind kind,
    String title,
    String? notes,
    DateTime date,
    bool isAllDay,
    int? startMinutesFromMidnight,
    int? endMinutesFromMidnight,
    String dutyGroupName,
    int createdAtMs,
    int updatedAtMs,
  });
}

/// @nodoc
class __$PersonalCalendarEntryCopyWithImpl<$Res>
    implements _$PersonalCalendarEntryCopyWith<$Res> {
  __$PersonalCalendarEntryCopyWithImpl(this._self, this._then);

  final _PersonalCalendarEntry _self;
  final $Res Function(_PersonalCalendarEntry) _then;

  /// Create a copy of PersonalCalendarEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? kind = null,
    Object? title = null,
    Object? notes = freezed,
    Object? date = null,
    Object? isAllDay = null,
    Object? startMinutesFromMidnight = freezed,
    Object? endMinutesFromMidnight = freezed,
    Object? dutyGroupName = null,
    Object? createdAtMs = null,
    Object? updatedAtMs = null,
  }) {
    return _then(
      _PersonalCalendarEntry(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        kind: null == kind
            ? _self.kind
            : kind // ignore: cast_nullable_to_non_nullable
                  as PersonalCalendarEntryKind,
        title: null == title
            ? _self.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        notes: freezed == notes
            ? _self.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        date: null == date
            ? _self.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        isAllDay: null == isAllDay
            ? _self.isAllDay
            : isAllDay // ignore: cast_nullable_to_non_nullable
                  as bool,
        startMinutesFromMidnight: freezed == startMinutesFromMidnight
            ? _self.startMinutesFromMidnight
            : startMinutesFromMidnight // ignore: cast_nullable_to_non_nullable
                  as int?,
        endMinutesFromMidnight: freezed == endMinutesFromMidnight
            ? _self.endMinutesFromMidnight
            : endMinutesFromMidnight // ignore: cast_nullable_to_non_nullable
                  as int?,
        dutyGroupName: null == dutyGroupName
            ? _self.dutyGroupName
            : dutyGroupName // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAtMs: null == createdAtMs
            ? _self.createdAtMs
            : createdAtMs // ignore: cast_nullable_to_non_nullable
                  as int,
        updatedAtMs: null == updatedAtMs
            ? _self.updatedAtMs
            : updatedAtMs // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}
