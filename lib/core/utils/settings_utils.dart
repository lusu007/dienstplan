/// Utilities related to settings domain logic.
class SettingsUtils {
  SettingsUtils._();

  /// Selects which activeConfigName should be persisted when saving settings
  /// while considering the current coordinator/settings UI state and existing settings.
  static String? selectActiveConfigNameToPersist({
    required String? currentActiveConfigName,
    required String? existingActiveConfigName,
  }) {
    if (currentActiveConfigName != null && currentActiveConfigName.isNotEmpty) {
      return currentActiveConfigName;
    }
    return existingActiveConfigName;
  }
}
