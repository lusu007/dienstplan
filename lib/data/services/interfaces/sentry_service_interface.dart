abstract class SentryServiceInterface {
  bool get isEnabled;
  bool get isReplayEnabled;

  Future<void> initialize();
  Future<void> setEnabled(bool enabled);
  Future<void> setReplayEnabled(bool enabled);
  Future<void> captureException(dynamic exception, dynamic stackTrace);
  Future<void> captureMessage(String message);
}
