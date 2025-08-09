import 'package:flutter/foundation.dart';
import 'package:dienstplan/domain/failures/failure.dart';

/// Lightweight Result/Either type for domain returns
@immutable
class Result<T> {
  final T? _value;
  final Failure? _failure;

  const Result._(this._value, this._failure);

  bool get isSuccess => _failure == null;
  bool get isFailure => _failure != null;

  T get value {
    if (_value == null) throw StateError('Result has no value');
    return _value;
  }

  Failure get failure {
    if (_failure == null) throw StateError('Result has no failure');
    return _failure;
  }

  static Result<T> success<T>(T value) => Result._(value, null);
  static Result<T> createFailure<T>(Failure failure) => Result._(null, failure);
}
