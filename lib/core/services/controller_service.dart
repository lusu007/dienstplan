import 'package:get_it/get_it.dart';
import 'package:dienstplan/presentation/controllers/schedule_controller.dart';
import 'package:dienstplan/presentation/controllers/settings_controller.dart';
import 'package:dienstplan/data/services/language_service.dart';

class ControllerService {
  static Future<void> initializeControllers() async {
    await Future.wait([
      _initializeScheduleController(),
      _initializeSettingsController(),
      _initializeLanguageService(),
    ]);
  }

  static Future<void> _initializeScheduleController() async {
    final controller = await GetIt.instance.getAsync<ScheduleController>();
    controller.loadConfigs();
    controller.loadSchedules(DateTime.now());
  }

  static Future<void> _initializeSettingsController() async {
    final controller = await GetIt.instance.getAsync<SettingsController>();
    await controller.loadSettings();
  }

  static Future<void> _initializeLanguageService() async {
    await GetIt.instance.getAsync<LanguageService>();
  }
}
