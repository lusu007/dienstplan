import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/screens/app_initializer_widget.dart';
import 'package:dienstplan/core/services/controller_service.dart';
import 'package:dienstplan/data/services/language_service.dart';
import 'package:dienstplan/data/services/database_service.dart';
import 'package:get_it/get_it.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  LanguageService? _languageService;
  final RouteObserver<ModalRoute<void>> _routeObserver =
      RouteObserver<ModalRoute<void>>();

  // Global navigator key for showing dialogs
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  // Queue for migration messages
  final List<String> _migrationMessageQueue = [];
  bool _isShowingSnackbar = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupMigrationSnackbar();
  }

  void _initializeControllers() {
    // Initialize controllers in background without blocking the UI
    ControllerService.initializeControllers();

    GetIt.instance.getAsync<LanguageService>().then((service) {
      _languageService = service;
      // Update UI when language service is ready
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _setupMigrationSnackbar() {
    // Set up the migration snackbar callback
    DatabaseService.setMigrationDialogCallback(_queueMigrationSnackbar);
  }

  void _queueMigrationSnackbar(String message) {
    _migrationMessageQueue.add(message);
    _processMigrationQueue();
  }

  void _processMigrationQueue() {
    if (_migrationMessageQueue.isEmpty || _isShowingSnackbar) {
      return;
    }

    // Wait for the app to be fully initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted && _migrationMessageQueue.isNotEmpty) {
          _showNextMigrationSnackbar();
        }
      });
    });
  }

  void _showNextMigrationSnackbar() {
    if (_migrationMessageQueue.isEmpty || _isShowingSnackbar) {
      return;
    }

    _isShowingSnackbar = true;
    final message = _migrationMessageQueue.removeAt(0);

    // Show snackbar instead of dialog
    ScaffoldMessenger.of(_navigatorKey.currentContext!).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            ScaffoldMessenger.of(_navigatorKey.currentContext!)
                .hideCurrentSnackBar();
          },
        ),
      ),
    );

    // Reset flag after a delay
    Future.delayed(const Duration(seconds: 5), () {
      _isShowingSnackbar = false;
      // Process next message in queue
      _processMigrationQueue();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _languageService ?? LanguageService(),
      builder: (context, child) {
        final locale = _languageService?.currentLocale ?? const Locale('de');

        return MaterialApp(
          title: 'Dienstplan',
          navigatorKey: _navigatorKey,
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
          locale: locale,
          home: AppInitializerWidget(routeObserver: _routeObserver),
        );
      },
    );
  }
}
