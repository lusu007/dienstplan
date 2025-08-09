import 'dart:async';
import 'dart:io';

import 'package:dienstplan/domain/failures/failure.dart';

class ExceptionMapper {
  const ExceptionMapper();

  Failure mapToFailure(Object error, [StackTrace? stackTrace]) {
    if (error is Failure) return error;
    if (error is TimeoutException) {
      return TimeoutFailure(
        technicalMessage: 'Operation timed out',
        cause: error,
        stackTrace: stackTrace,
        userMessageKey: 'errorTimeout',
      );
    }
    if (error is SocketException || error is HttpException) {
      return NetworkFailure(
        technicalMessage: 'Network error: $error',
        cause: error,
        stackTrace: stackTrace,
        userMessageKey: 'errorNetwork',
      );
    }
    if (error is FileSystemException) {
      return StorageFailure(
        technicalMessage: 'Storage error: $error',
        cause: error,
        stackTrace: stackTrace,
        userMessageKey: 'errorStorage',
      );
    }
    if (error is FormatException) {
      return SerializationFailure(
        technicalMessage: 'Serialization error: ${error.message}',
        cause: error,
        stackTrace: stackTrace,
        userMessageKey: 'errorSerialization',
      );
    }
    if (error is ArgumentError || error is StateError) {
      return ValidationFailure(
        technicalMessage: 'Validation error: $error',
        cause: error,
        stackTrace: stackTrace,
        userMessageKey: 'errorValidation',
      );
    }
    return UnknownFailure(
      technicalMessage: 'Unknown error: $error',
      cause: error,
      stackTrace: stackTrace,
      userMessageKey: 'errorUnknown',
    );
  }
}
