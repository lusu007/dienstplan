import 'package:flutter/foundation.dart';

/// Failure codes to categorize errors across layers
enum FailureCode {
  validation,
  notFound,
  conflict,
  unauthorized,
  forbidden,
  network,
  timeout,
  storage,
  serialization,
  cancellation,
  unknown,
}

/// Base domain failure object to unify error handling across layers
@immutable
abstract class Failure {
  final FailureCode code;
  final String technicalMessage;
  final Object? cause;
  final StackTrace? stackTrace;

  /// Optional localization key for end-user friendly message
  final String? userMessageKey;

  /// Optional arguments for localization key
  final Map<String, String>? userMessageArgs;

  const Failure({
    required this.code,
    required this.technicalMessage,
    this.cause,
    this.stackTrace,
    this.userMessageKey,
    this.userMessageArgs,
  });

  @override
  String toString() =>
      'Failure(code: $code, technicalMessage: $technicalMessage, cause: $cause)';
}

class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.technicalMessage,
    super.cause,
    super.stackTrace,
    super.userMessageKey,
    super.userMessageArgs,
  }) : super(code: FailureCode.validation);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({
    required super.technicalMessage,
    super.cause,
    super.stackTrace,
    super.userMessageKey,
    super.userMessageArgs,
  }) : super(code: FailureCode.notFound);
}

class ConflictFailure extends Failure {
  const ConflictFailure({
    required super.technicalMessage,
    super.cause,
    super.stackTrace,
    super.userMessageKey,
    super.userMessageArgs,
  }) : super(code: FailureCode.conflict);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    required super.technicalMessage,
    super.cause,
    super.stackTrace,
    super.userMessageKey,
    super.userMessageArgs,
  }) : super(code: FailureCode.unauthorized);
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure({
    required super.technicalMessage,
    super.cause,
    super.stackTrace,
    super.userMessageKey,
    super.userMessageArgs,
  }) : super(code: FailureCode.forbidden);
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.technicalMessage,
    super.cause,
    super.stackTrace,
    super.userMessageKey,
    super.userMessageArgs,
  }) : super(code: FailureCode.network);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({
    required super.technicalMessage,
    super.cause,
    super.stackTrace,
    super.userMessageKey,
    super.userMessageArgs,
  }) : super(code: FailureCode.timeout);
}

class StorageFailure extends Failure {
  const StorageFailure({
    required super.technicalMessage,
    super.cause,
    super.stackTrace,
    super.userMessageKey,
    super.userMessageArgs,
  }) : super(code: FailureCode.storage);
}

class SerializationFailure extends Failure {
  const SerializationFailure({
    required super.technicalMessage,
    super.cause,
    super.stackTrace,
    super.userMessageKey,
    super.userMessageArgs,
  }) : super(code: FailureCode.serialization);
}

class CancellationFailure extends Failure {
  const CancellationFailure({
    required super.technicalMessage,
    super.cause,
    super.stackTrace,
    super.userMessageKey,
    super.userMessageArgs,
  }) : super(code: FailureCode.cancellation);
}

class UnknownFailure extends Failure {
  const UnknownFailure({
    required super.technicalMessage,
    super.cause,
    super.stackTrace,
    super.userMessageKey,
    super.userMessageArgs,
  }) : super(code: FailureCode.unknown);
}
