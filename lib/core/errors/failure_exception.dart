import 'package:dienstplan/domain/failures/failure.dart';

/// Exception wrapper to bubble Failures through throw/catch when needed
class FailureException implements Exception {
  final Failure failure;
  const FailureException(this.failure);

  @override
  String toString() => 'FailureException($failure)';
}
