import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/presentation/screens/calendar_screen.dart';
import 'package:dienstplan/presentation/screens/setup_screen.dart';
import 'package:dienstplan/core/utils/logger.dart';

class AppInitializerWidget extends ConsumerStatefulWidget {
  final RouteObserver<ModalRoute<void>> routeObserver;

  const AppInitializerWidget({super.key, required this.routeObserver});

  @override
  ConsumerState<AppInitializerWidget> createState() =>
      _AppInitializerWidgetState();
}

class _AppInitializerWidgetState extends ConsumerState<AppInitializerWidget> {
  _AppInitializerWidgetState();

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsNotifierProvider);
    return settingsAsync.when(
      data: (state) {
        final isSetupCompleted = (state.activeConfigName != null &&
            state.activeConfigName!.isNotEmpty);
        AppLogger.i('Setup completed: $isSetupCompleted');
        return isSetupCompleted
            ? CalendarScreen(routeObserver: widget.routeObserver)
            : const SetupScreen();
      },
      loading: () {
        // Default to setup screen while deciding; previous behavior showed setup first
        return const SetupScreen();
      },
      error: (err, st) {
        AppLogger.e('Error checking initial setup', err, st);
        return const SetupScreen();
      },
    );
  }
}
