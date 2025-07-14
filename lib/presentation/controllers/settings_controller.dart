import 'package:flutter/foundation.dart';
import 'package:dienstplan/domain/entities/settings.dart';
import 'package:dienstplan/domain/use_cases/get_settings_use_case.dart';
import 'package:dienstplan/domain/use_cases/save_settings_use_case.dart';
import 'package:dienstplan/domain/use_cases/reset_settings_use_case.dart';
import 'package:dienstplan/core/utils/logger.dart';

class SettingsController extends ChangeNotifier {
  final GetSettingsUseCase getSettingsUseCase;
  final SaveSettingsUseCase saveSettingsUseCase;
  final ResetSettingsUseCase resetSettingsUseCase;

  Settings? _settings;
  bool _isLoading = false;
  String? _error;
  String? _language;

  SettingsController({
    required this.getSettingsUseCase,
    required this.saveSettingsUseCase,
    required this.resetSettingsUseCase,
  });

  Settings? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get language => _language;

  Future<void> loadSettings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _settings = await getSettingsUseCase.execute();
      _language = _settings?.language;
    } catch (e, stackTrace) {
      _error = 'Failed to load settings';
      AppLogger.e('SettingsController: Error loading settings', e, stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setLanguage(String language) async {
    _language = language;
    notifyListeners();
    if (_settings != null) {
      final updated = _settings!.copyWith(language: language);
      await saveSettings(updated);
    }
  }

  Future<void> saveSettings(Settings settings) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await saveSettingsUseCase.execute(settings);
      _settings = settings;
    } catch (e, stackTrace) {
      _error = 'Failed to save settings';
      AppLogger.e('SettingsController: Error saving settings', e, stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetSettings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await resetSettingsUseCase.execute();
      await loadSettings();
    } catch (e, stackTrace) {
      _error = 'Failed to reset settings';
      AppLogger.e(
          'SettingsController: Error resetting settings', e, stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
