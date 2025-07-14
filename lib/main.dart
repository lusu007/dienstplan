import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/screens/calendar_screen.dart';
import 'package:dienstplan/presentation/screens/setup_screen.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/core/di/injection_container.dart';
import 'package:dienstplan/presentation/controllers/schedule_controller.dart';
import 'package:dienstplan/presentation/controllers/settings_controller.dart';
import 'package:dienstplan/data/services/language_service.dart';
import 'package:dienstplan/data/services/sentry_service.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:get_it/get_it.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await InjectionContainer.init();

  // Initialize logger first
  await AppLogger.initialize();
  AppLogger.i('Starting Dienstplan application');

  // Get services from DI container and ensure they're initialized
  final sentryService = await GetIt.instance.getAsync<SentryService>();

  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://26cd4b7f0d4f1cf36308a96994e7a23a@o4509656380801024.ingest.de.sentry.io/4509656382701648';

      // Apply configuration based on service settings
      if (sentryService.isEnabled) {
        options.tracesSampleRate = 1.0;
        options.profilesSampleRate = 1.0;

        // Only enable replay if both Sentry and replay are enabled
        if (sentryService.isReplayEnabled) {
          options.replay.sessionSampleRate = 1.0;
          options.replay.onErrorSampleRate = 1.0;
        } else {
          options.replay.sessionSampleRate = 0.0;
          options.replay.onErrorSampleRate = 0.0;
        }
      } else {
        // Disable Sentry by setting sample rates to 0
        options.tracesSampleRate = 0.0;
        options.profilesSampleRate = 0.0;
        options.replay.sessionSampleRate = 0.0;
        options.replay.onErrorSampleRate = 0.0;
      }
    },
    appRunner: () => runApp(SentryWidget(
      child: const MyApp(),
    )),
  );
}

class AppInitializer extends StatefulWidget {
  final RouteObserver<ModalRoute<void>> routeObserver;

  const AppInitializer({super.key, required this.routeObserver});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoading = true;
  bool _needsSetup = false;

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
      setState(() {
        _isLoading = false;
        _needsSetup = !isSetupCompleted;
      });
      AppLogger.i('Setup needed: $_needsSetup');
    } catch (e, stackTrace) {
      AppLogger.e('Error checking initial setup', e, stackTrace);
      setState(() {
        _isLoading = false;
        _needsSetup = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_needsSetup) {
      return const SetupScreen();
    }

    return CalendarScreen(routeObserver: widget.routeObserver);
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ScheduleController? _scheduleController;
  SettingsController? _settingsController;
  LanguageService? _languageService;
  bool _isInitialized = false;
  final RouteObserver<ModalRoute<void>> _routeObserver =
      RouteObserver<ModalRoute<void>>();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  Future<void> _initializeControllers() async {
    _scheduleController = await GetIt.instance.getAsync<ScheduleController>();
    _settingsController = await GetIt.instance.getAsync<SettingsController>();
    _languageService = await GetIt.instance.getAsync<LanguageService>();

    // Ensure all settings data is loaded during app startup
    await _scheduleController!.loadConfigs();
    await _scheduleController!.loadSchedules(DateTime.now());
    await _settingsController!.loadSettings();

    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return ListenableBuilder(
      listenable: _languageService!,
      builder: (context, child) {
        return MaterialApp(
          title: 'Dienstplan',
          navigatorObservers: [_routeObserver],
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF005B8C),
              primary: const Color(0xFF005B8C),
            ),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF005B8C),
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              iconTheme: IconThemeData(color: Colors.white),
            ),
          ),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: _languageService!.currentLocale,
          home: AppInitializer(routeObserver: _routeObserver),
        );
      },
    );
  }
}
