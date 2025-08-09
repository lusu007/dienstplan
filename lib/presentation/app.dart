import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/screens/app_initializer_widget.dart';
// import 'package:dienstplan/core/services/controller_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/data/services/language_service.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final RouteObserver<ModalRoute<void>> _routeObserver =
      RouteObserver<ModalRoute<void>>();

  // Global navigator key for showing dialogs
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  void _initializeControllers() {
    // Controllers are managed via Riverpod now
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<LanguageService> languageAsync =
        ref.watch(languageServiceProvider);
    return languageAsync.when(
      loading: () => MaterialApp(
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
        locale: const Locale('de'),
        home: AppInitializerWidget(routeObserver: _routeObserver),
      ),
      error: (e, st) => MaterialApp(
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
        locale: const Locale('de'),
        home: AppInitializerWidget(routeObserver: _routeObserver),
      ),
      data: (languageService) => ListenableBuilder(
        listenable: languageService,
        builder: (context, child) {
          final locale = languageService.currentLocale;
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
      ),
    );
  }
}
