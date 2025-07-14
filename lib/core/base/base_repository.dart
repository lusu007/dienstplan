import 'package:dienstplan/core/utils/logger.dart';

abstract class BaseRepository<T> {
  final String repositoryName;

  BaseRepository(this.repositoryName);

  /// Get all entities
  Future<List<T>> getAll();

  /// Get entity by ID
  Future<T?> getById(String id);

  /// Save entity
  Future<void> save(T entity);

  /// Save multiple entities
  Future<void> saveAll(List<T> entities);

  /// Delete entity by ID
  Future<void> delete(String id);

  /// Clear all entities
  Future<void> clear();

  /// Check if repository has data
  Future<bool> hasData();

  /// Log repository operation
  void logOperation(String operation, [dynamic data]) {
    AppLogger.d('$repositoryName: $operation ${data != null ? '- $data' : ''}');
  }

  /// Log repository error
  void logError(String operation, dynamic error, dynamic stackTrace) {
    AppLogger.e('$repositoryName: Error in $operation', error, stackTrace);
  }
}
