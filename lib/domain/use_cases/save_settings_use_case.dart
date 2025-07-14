import 'package:dienstplan/domain/entities/settings.dart';
import 'package:dienstplan/domain/repositories/settings_repository.dart';
import 'package:dienstplan/core/utils/logger.dart';

class SaveSettingsUseCase {
  final SettingsRepository _settingsRepository;

  SaveSettingsUseCase(this._settingsRepository);

  Future<void> execute(Settings settings) async {
    try {
      AppLogger.i('SaveSettingsUseCase: Executing save settings: $settings');

      // Business logic: Validate settings
      _validateSettings(settings);

      await _settingsRepository.saveSettings(settings);
      AppLogger.i('SaveSettingsUseCase: Settings saved successfully');
    } catch (e, stackTrace) {
      AppLogger.e('SaveSettingsUseCase: Error saving settings', e, stackTrace);
      rethrow;
    }
  }

  void _validateSettings(Settings settings) {
    // Business logic: Validate settings before saving

    // Validate that focused day and selected day are not in the distant past/future
    final now = DateTime.now();
    final maxDateDifference = Duration(days: 365 * 10); // 10 years

    if (settings.focusedDay.difference(now).abs() > maxDateDifference) {
      throw ArgumentError('Focused day is too far from current date');
    }

    if (settings.selectedDay.difference(now).abs() > maxDateDifference) {
      throw ArgumentError('Selected day is too far from current date');
    }

    AppLogger.d('SaveSettingsUseCase: Settings validation passed');
  }
}
