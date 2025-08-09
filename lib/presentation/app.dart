import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/core/routing/app_router.dart';
// import 'package:dienstplan/core/services/controller_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
// import 'package:dienstplan/data/services/language_service.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter();
    _initializeControllers();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  void _initializeControllers() {
    // Controllers are managed via Riverpod now
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ref.watch(appThemeProvider);
    final ThemeMode mode = ref.watch(themeModeProvider);
    final AsyncValue<Locale> localeAsync = ref.watch(currentLocaleProvider);
    return localeAsync.when(
      loading: () => _buildMaterialApp(
          theme: theme, mode: mode, locale: const Locale('de')),
      error: (e, st) => _buildMaterialApp(
          theme: theme, mode: mode, locale: const Locale('de')),
      data: (locale) =>
          _buildMaterialApp(theme: theme, mode: mode, locale: locale),
    );
  }

  Widget _buildMaterialApp(
      {required ThemeData theme,
      required ThemeMode mode,
      required Locale locale}) {
    return MaterialApp.router(
      title: 'Dienstplan',
      theme: theme,
      themeMode: mode,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      routerDelegate: _appRouter.delegate(
          navigatorObservers: () => <NavigatorObserver>[AutoRouteObserver()]),
      routeInformationParser: _appRouter.defaultRouteParser(),
    );
  }
}
