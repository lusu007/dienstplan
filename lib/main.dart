import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:dienstplan/l10n/app_localizations.dart';
import 'package:dienstplan/screens/calendar_screen.dart';
import 'package:dienstplan/screens/first_time_setup_screen.dart';
import 'package:dienstplan/providers/schedule_provider.dart';
import 'package:dienstplan/services/schedule_config_service.dart';
import 'package:dienstplan/services/language_service.dart';
import 'package:dienstplan/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dienstplan/services/database_service.dart';
import 'package:dienstplan/services/sentry_service.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logger first
  await AppLogger.initialize();
  AppLogger.i('Starting Dienstplan application');

  final prefs = await SharedPreferences.getInstance();
  final databaseService = DatabaseService();
  final scheduleConfigService = ScheduleConfigService(prefs);
  final languageService = LanguageService();
  final sentryService = SentryService();

  await databaseService.init();
  await scheduleConfigService.initialize();
  await languageService.initialize();
  await sentryService.initialize();

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
      child: MyApp(
        scheduleConfigService: scheduleConfigService,
        languageService: languageService,
        sentryService: sentryService,
      ),
    )),
  );
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

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
      final scheduleConfigService = context.read<ScheduleConfigService>();
      await scheduleConfigService.initialize();
      final isSetupCompleted = scheduleConfigService.isSetupCompleted;
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
      return const FirstTimeSetupScreen();
    }

    return const CalendarScreen();
  }
}

class MyApp extends StatefulWidget {
  final ScheduleConfigService scheduleConfigService;
  final LanguageService languageService;
  final SentryService sentryService;

  const MyApp({
    super.key,
    required this.scheduleConfigService,
    required this.languageService,
    required this.sentryService,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ScheduleProvider _scheduleProvider;

  @override
  void initState() {
    super.initState();
    _initializeScheduleProvider();
  }

  Future<void> _initializeScheduleProvider() async {
    _scheduleProvider = ScheduleProvider(widget.scheduleConfigService);
    await _scheduleProvider.initialize();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _scheduleProvider),
        ChangeNotifierProvider(create: (_) => widget.scheduleConfigService),
        ChangeNotifierProvider(create: (_) => widget.languageService),
        ChangeNotifierProvider(create: (_) => widget.sentryService),
      ],
      child: Consumer<LanguageService>(
        builder: (context, languageService, _) {
          return MaterialApp(
            title: 'Dienstplan',
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
            locale: languageService.currentLocale,
            home: const AppInitializer(),
          );
        },
      ),
    );
  }
}
