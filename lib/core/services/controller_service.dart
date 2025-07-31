import 'package:get_it/get_it.dart';
import 'package:dienstplan/presentation/controllers/schedule_controller.dart';
import 'package:dienstplan/presentation/controllers/settings_controller.dart';
import 'package:dienstplan/data/services/language_service.dart';
import 'package:dienstplan/core/cache/settings_cache.dart';

class ControllerService {
  static Future<void> initializeControllers() async {
    await Future.wait([
      _initializeSettingsController(),
      _initializeLanguageService(),
    ]);

    // Initialize schedule controller after settings are loaded
    await _initializeScheduleController();

    // End startup phase to switch to normal cache validity
    SettingsCache.endStartupPhase();
  }

  static Future<void> _initializeScheduleController() async {
    final controller = await GetIt.instance.getAsync<ScheduleController>();
    // Only load configs, which will also load schedules for the current month
    await controller.loadConfigs();
  }

  static Future<void> _initializeSettingsController() async {
    final controller = await GetIt.instance.getAsync<SettingsController>();
    await controller.loadSettings();
  }

  static Future<void> _initializeLanguageService() async {
    await GetIt.instance.getAsync<LanguageService>();
  }
}
