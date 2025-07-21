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
      await settingsController.loadSettings();
      // For now, assume setup is completed if settings are loaded successfully
      final isSetupCompleted = settingsController.settings != null;
      AppLogger.i('Setup completed: $isSetupCompleted');
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
