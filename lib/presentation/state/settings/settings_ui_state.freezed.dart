// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_ui_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SettingsUiState {
  bool get isLoading;
  String? get error;
  String? get language;
  String? get activeConfigName;
  String? get myDutyGroup;
  ThemePreference? get themePreference;
  String? get partnerConfigName;
  String? get partnerDutyGroup;
  int? get partnerAccentColorValue;
  int? get myAccentColorValue;
  int? get holidayAccentColorValue;
  bool? get showOtherDutyGroupsInCompactList;

  /// Create a copy of SettingsUiState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SettingsUiStateCopyWith<SettingsUiState> get copyWith =>
      _$SettingsUiStateCopyWithImpl<SettingsUiState>(
        this as SettingsUiState,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    final _this = this as SettingsUiState;
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SettingsUiState &&
            (identical(other.isLoading, _this.isLoading) ||
                other.isLoading == _this.isLoading) &&
            (identical(other.error, _this.error) ||
                other.error == _this.error) &&
            (identical(other.language, _this.language) ||
                other.language == _this.language) &&
            (identical(other.activeConfigName, _this.activeConfigName) ||
                other.activeConfigName == _this.activeConfigName) &&
            (identical(other.myDutyGroup, _this.myDutyGroup) ||
                other.myDutyGroup == _this.myDutyGroup) &&
            (identical(other.themePreference, _this.themePreference) ||
                other.themePreference == _this.themePreference) &&
            (identical(other.partnerConfigName, _this.partnerConfigName) ||
                other.partnerConfigName == _this.partnerConfigName) &&
            (identical(other.partnerDutyGroup, _this.partnerDutyGroup) ||
                other.partnerDutyGroup == _this.partnerDutyGroup) &&
            (identical(
                  other.partnerAccentColorValue,
                  _this.partnerAccentColorValue,
                ) ||
                other.partnerAccentColorValue ==
                    _this.partnerAccentColorValue) &&
            (identical(other.myAccentColorValue, _this.myAccentColorValue) ||
                other.myAccentColorValue == _this.myAccentColorValue) &&
            (identical(
                  other.holidayAccentColorValue,
                  _this.holidayAccentColorValue,
                ) ||
                other.holidayAccentColorValue ==
                    _this.holidayAccentColorValue) &&
            (identical(
                  other.showOtherDutyGroupsInCompactList,
                  _this.showOtherDutyGroupsInCompactList,
                ) ||
                other.showOtherDutyGroupsInCompactList ==
                    _this.showOtherDutyGroupsInCompactList));
  }

  @override
  int get hashCode {
    final _this = this as SettingsUiState;
    return Object.hash(
      runtimeType,
      _this.isLoading,
      _this.error,
      _this.language,
      _this.activeConfigName,
      _this.myDutyGroup,
      _this.themePreference,
      _this.partnerConfigName,
      _this.partnerDutyGroup,
      _this.partnerAccentColorValue,
      _this.myAccentColorValue,
      _this.holidayAccentColorValue,
      _this.showOtherDutyGroupsInCompactList,
    );
  }

  @override
  String toString() {
    final _this = this as SettingsUiState;
    return 'SettingsUiState(isLoading: ${_this.isLoading}, error: ${_this.error}, language: ${_this.language}, activeConfigName: ${_this.activeConfigName}, myDutyGroup: ${_this.myDutyGroup}, themePreference: ${_this.themePreference}, partnerConfigName: ${_this.partnerConfigName}, partnerDutyGroup: ${_this.partnerDutyGroup}, partnerAccentColorValue: ${_this.partnerAccentColorValue}, myAccentColorValue: ${_this.myAccentColorValue}, holidayAccentColorValue: ${_this.holidayAccentColorValue}, showOtherDutyGroupsInCompactList: ${_this.showOtherDutyGroupsInCompactList})';
  }
}

/// @nodoc
abstract mixin class $SettingsUiStateCopyWith<$Res> {
  factory $SettingsUiStateCopyWith(
    SettingsUiState value,
    $Res Function(SettingsUiState) _then,
  ) = _$SettingsUiStateCopyWithImpl;
  @useResult
  $Res call({
    bool isLoading,
    String? error,
    String? language,
    String? activeConfigName,
    String? myDutyGroup,
    ThemePreference? themePreference,
    String? partnerConfigName,
    String? partnerDutyGroup,
    int? partnerAccentColorValue,
    int? myAccentColorValue,
    int? holidayAccentColorValue,
    bool? showOtherDutyGroupsInCompactList,
  });
}

/// @nodoc
class _$SettingsUiStateCopyWithImpl<$Res>
    implements $SettingsUiStateCopyWith<$Res> {
  _$SettingsUiStateCopyWithImpl(this._self, this._then);

  final SettingsUiState _self;
  final $Res Function(SettingsUiState) _then;

  /// Create a copy of SettingsUiState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? language = freezed,
    Object? activeConfigName = freezed,
    Object? myDutyGroup = freezed,
    Object? themePreference = freezed,
    Object? partnerConfigName = freezed,
    Object? partnerDutyGroup = freezed,
    Object? partnerAccentColorValue = freezed,
    Object? myAccentColorValue = freezed,
    Object? holidayAccentColorValue = freezed,
    Object? showOtherDutyGroupsInCompactList = freezed,
  }) {
    return _then(
      SettingsUiState(
        isLoading: null == isLoading
            ? _self.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _self.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        language: freezed == language
            ? _self.language
            : language // ignore: cast_nullable_to_non_nullable
                  as String?,
        activeConfigName: freezed == activeConfigName
            ? _self.activeConfigName
            : activeConfigName // ignore: cast_nullable_to_non_nullable
                  as String?,
        myDutyGroup: freezed == myDutyGroup
            ? _self.myDutyGroup
            : myDutyGroup // ignore: cast_nullable_to_non_nullable
                  as String?,
        themePreference: freezed == themePreference
            ? _self.themePreference
            : themePreference // ignore: cast_nullable_to_non_nullable
                  as ThemePreference?,
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
        holidayAccentColorValue: freezed == holidayAccentColorValue
            ? _self.holidayAccentColorValue
            : holidayAccentColorValue // ignore: cast_nullable_to_non_nullable
                  as int?,
        showOtherDutyGroupsInCompactList:
            freezed == showOtherDutyGroupsInCompactList
            ? _self.showOtherDutyGroupsInCompactList
            : showOtherDutyGroupsInCompactList // ignore: cast_nullable_to_non_nullable
                  as bool?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [SettingsUiState].
extension SettingsUiStatePatterns on SettingsUiState {
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
    TResult Function(_SettingsUiState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SettingsUiState() when $default != null:
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
    TResult Function(_SettingsUiState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SettingsUiState():
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
    TResult? Function(_SettingsUiState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SettingsUiState() when $default != null:
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
      String? language,
      String? activeConfigName,
      String? myDutyGroup,
      ThemePreference? themePreference,
      String? partnerConfigName,
      String? partnerDutyGroup,
      int? partnerAccentColorValue,
      int? myAccentColorValue,
      int? holidayAccentColorValue,
      bool? showOtherDutyGroupsInCompactList,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SettingsUiState() when $default != null:
        return $default(
          _that.isLoading,
          _that.error,
          _that.language,
          _that.activeConfigName,
          _that.myDutyGroup,
          _that.themePreference,
          _that.partnerConfigName,
          _that.partnerDutyGroup,
          _that.partnerAccentColorValue,
          _that.myAccentColorValue,
          _that.holidayAccentColorValue,
          _that.showOtherDutyGroupsInCompactList,
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
      String? language,
      String? activeConfigName,
      String? myDutyGroup,
      ThemePreference? themePreference,
      String? partnerConfigName,
      String? partnerDutyGroup,
      int? partnerAccentColorValue,
      int? myAccentColorValue,
      int? holidayAccentColorValue,
      bool? showOtherDutyGroupsInCompactList,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SettingsUiState():
        return $default(
          _that.isLoading,
          _that.error,
          _that.language,
          _that.activeConfigName,
          _that.myDutyGroup,
          _that.themePreference,
          _that.partnerConfigName,
          _that.partnerDutyGroup,
          _that.partnerAccentColorValue,
          _that.myAccentColorValue,
          _that.holidayAccentColorValue,
          _that.showOtherDutyGroupsInCompactList,
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
      String? language,
      String? activeConfigName,
      String? myDutyGroup,
      ThemePreference? themePreference,
      String? partnerConfigName,
      String? partnerDutyGroup,
      int? partnerAccentColorValue,
      int? myAccentColorValue,
      int? holidayAccentColorValue,
      bool? showOtherDutyGroupsInCompactList,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SettingsUiState() when $default != null:
        return $default(
          _that.isLoading,
          _that.error,
          _that.language,
          _that.activeConfigName,
          _that.myDutyGroup,
          _that.themePreference,
          _that.partnerConfigName,
          _that.partnerDutyGroup,
          _that.partnerAccentColorValue,
          _that.myAccentColorValue,
          _that.holidayAccentColorValue,
          _that.showOtherDutyGroupsInCompactList,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc

class _SettingsUiState extends SettingsUiState {
  const _SettingsUiState({
    required this.isLoading,
    this.error,
    this.language,
    this.activeConfigName,
    this.myDutyGroup,
    this.themePreference,
    this.partnerConfigName,
    this.partnerDutyGroup,
    this.partnerAccentColorValue,
    this.myAccentColorValue,
    this.holidayAccentColorValue,
    this.showOtherDutyGroupsInCompactList,
  }) : super._();

  @override
  final bool isLoading;
  @override
  final String? error;
  @override
  final String? language;
  @override
  final String? activeConfigName;
  @override
  final String? myDutyGroup;
  @override
  final ThemePreference? themePreference;
  @override
  final String? partnerConfigName;
  @override
  final String? partnerDutyGroup;
  @override
  final int? partnerAccentColorValue;
  @override
  final int? myAccentColorValue;
  @override
  final int? holidayAccentColorValue;
  @override
  final bool? showOtherDutyGroupsInCompactList;

  /// Create a copy of SettingsUiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SettingsUiStateCopyWith<_SettingsUiState> get copyWith =>
      __$SettingsUiStateCopyWithImpl<_SettingsUiState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SettingsUiState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.activeConfigName, activeConfigName) ||
                other.activeConfigName == activeConfigName) &&
            (identical(other.myDutyGroup, myDutyGroup) ||
                other.myDutyGroup == myDutyGroup) &&
            (identical(other.themePreference, themePreference) ||
                other.themePreference == themePreference) &&
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
                other.myAccentColorValue == myAccentColorValue) &&
            (identical(
                  other.holidayAccentColorValue,
                  holidayAccentColorValue,
                ) ||
                other.holidayAccentColorValue == holidayAccentColorValue) &&
            (identical(
                  other.showOtherDutyGroupsInCompactList,
                  showOtherDutyGroupsInCompactList,
                ) ||
                other.showOtherDutyGroupsInCompactList ==
                    showOtherDutyGroupsInCompactList));
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      isLoading,
      error,
      language,
      activeConfigName,
      myDutyGroup,
      themePreference,
      partnerConfigName,
      partnerDutyGroup,
      partnerAccentColorValue,
      myAccentColorValue,
      holidayAccentColorValue,
      showOtherDutyGroupsInCompactList,
    );
  }

  @override
  String toString() {
    return 'SettingsUiState(isLoading: $isLoading, error: $error, language: $language, activeConfigName: $activeConfigName, myDutyGroup: $myDutyGroup, themePreference: $themePreference, partnerConfigName: $partnerConfigName, partnerDutyGroup: $partnerDutyGroup, partnerAccentColorValue: $partnerAccentColorValue, myAccentColorValue: $myAccentColorValue, holidayAccentColorValue: $holidayAccentColorValue, showOtherDutyGroupsInCompactList: $showOtherDutyGroupsInCompactList)';
  }
}

/// @nodoc
abstract mixin class _$SettingsUiStateCopyWith<$Res>
    implements $SettingsUiStateCopyWith<$Res> {
  factory _$SettingsUiStateCopyWith(
    _SettingsUiState value,
    $Res Function(_SettingsUiState) _then,
  ) = __$SettingsUiStateCopyWithImpl;
  @override
  @useResult
  $Res call({
    bool isLoading,
    String? error,
    String? language,
    String? activeConfigName,
    String? myDutyGroup,
    ThemePreference? themePreference,
    String? partnerConfigName,
    String? partnerDutyGroup,
    int? partnerAccentColorValue,
    int? myAccentColorValue,
    int? holidayAccentColorValue,
    bool? showOtherDutyGroupsInCompactList,
  });
}

/// @nodoc
class __$SettingsUiStateCopyWithImpl<$Res>
    implements _$SettingsUiStateCopyWith<$Res> {
  __$SettingsUiStateCopyWithImpl(this._self, this._then);

  final _SettingsUiState _self;
  final $Res Function(_SettingsUiState) _then;

  /// Create a copy of SettingsUiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? language = freezed,
    Object? activeConfigName = freezed,
    Object? myDutyGroup = freezed,
    Object? themePreference = freezed,
    Object? partnerConfigName = freezed,
    Object? partnerDutyGroup = freezed,
    Object? partnerAccentColorValue = freezed,
    Object? myAccentColorValue = freezed,
    Object? holidayAccentColorValue = freezed,
    Object? showOtherDutyGroupsInCompactList = freezed,
  }) {
    return _then(
      _SettingsUiState(
        isLoading: null == isLoading
            ? _self.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _self.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        language: freezed == language
            ? _self.language
            : language // ignore: cast_nullable_to_non_nullable
                  as String?,
        activeConfigName: freezed == activeConfigName
            ? _self.activeConfigName
            : activeConfigName // ignore: cast_nullable_to_non_nullable
                  as String?,
        myDutyGroup: freezed == myDutyGroup
            ? _self.myDutyGroup
            : myDutyGroup // ignore: cast_nullable_to_non_nullable
                  as String?,
        themePreference: freezed == themePreference
            ? _self.themePreference
            : themePreference // ignore: cast_nullable_to_non_nullable
                  as ThemePreference?,
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
        holidayAccentColorValue: freezed == holidayAccentColorValue
            ? _self.holidayAccentColorValue
            : holidayAccentColorValue // ignore: cast_nullable_to_non_nullable
                  as int?,
        showOtherDutyGroupsInCompactList:
            freezed == showOtherDutyGroupsInCompactList
            ? _self.showOtherDutyGroupsInCompactList
            : showOtherDutyGroupsInCompactList // ignore: cast_nullable_to_non_nullable
                  as bool?,
      ),
    );
  }
}
