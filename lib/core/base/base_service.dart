import 'package:dienstplan/core/utils/logger.dart';

abstract class BaseService {
  final String serviceName;
  bool _isInitialized = false;

  BaseService(this.serviceName);

  bool get isInitialized => _isInitialized;

  /// Initialize the service
  Future<void> initialize() async {
    try {
      AppLogger.i('$serviceName: Initializing service');
      await performInitialization();
      _isInitialized = true;
      AppLogger.i('$serviceName: Service initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.e('$serviceName: Error initializing service', e, stackTrace);
      rethrow;
    }
  }

  /// Perform the actual initialization logic
  Future<void> performInitialization();

  /// Dispose the service
  Future<void> dispose() async {
    try {
      AppLogger.i('$serviceName: Disposing service');
      await performDisposal();
      _isInitialized = false;
      AppLogger.i('$serviceName: Service disposed successfully');
    } catch (e, stackTrace) {
      AppLogger.e('$serviceName: Error disposing service', e, stackTrace);
      rethrow;
    }
  }

  /// Perform the actual disposal logic
  Future<void> performDisposal();

  /// Check if service is ready for use
  void ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
          '$serviceName: Service not initialized. Call initialize() first.');
    }
  }
}
