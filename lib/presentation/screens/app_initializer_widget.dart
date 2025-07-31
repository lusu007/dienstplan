import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:dienstplan/presentation/controllers/settings_controller.dart';
import 'package:dienstplan/presentation/screens/calendar_screen.dart';
import 'package:dienstplan/presentation/screens/setup_screen.dart';
import 'package:dienstplan/core/utils/logger.dart';

class AppInitializerWidget extends StatefulWidget {
  final RouteObserver<ModalRoute<void>> routeObserver;

  const AppInitializerWidget({super.key, required this.routeObserver});

  @override
  State<AppInitializerWidget> createState() => _AppInitializerWidgetState();
}

class _AppInitializerWidgetState extends State<AppInitializerWidget> {
  bool _needsSetup = true; // Default to setup screen

  @override
  void initState() {
    super.initState();
    _checkInitialSetup();
  }

  Future<void> _checkInitialSetup() async {
    try {
      AppLogger.i('Checking initial setup');
      final settingsController =
          await GetIt.instance.getAsync<SettingsController>();

      // Check if settings are already loaded, if not wait for them
      if (settingsController.settings == null) {
        AppLogger.i('Settings not loaded yet, waiting for initialization');
        // Wait a bit for the controller service to finish initialization
        await Future.delayed(const Duration(milliseconds: 100));

        // Try to load settings again
        await settingsController.loadSettings();
      }

      // Check if setup is completed by looking for an active config
      final settings = settingsController.settings;
      final isSetupCompleted = settings != null &&
          settings.activeConfigName != null &&
          settings.activeConfigName!.isNotEmpty;

      AppLogger.i('Setup completed: $isSetupCompleted');
      AppLogger.i('Active config name: ${settings?.activeConfigName}');
      AppLogger.i('Settings object: ${settings?.toString()}');

      if (mounted) {
        setState(() {
          _needsSetup = !isSetupCompleted;
        });
      }
      AppLogger.i('Setup needed: $_needsSetup');
    } catch (e, stackTrace) {
      AppLogger.e('Error checking initial setup', e, stackTrace);
      if (mounted) {
        setState(() {
          _needsSetup = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show setup screen by default, will update if setup is completed
    if (_needsSetup) {
      return const SetupScreen();
    }

    return CalendarScreen(routeObserver: widget.routeObserver);
  }
}
