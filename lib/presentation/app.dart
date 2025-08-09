import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/core/routing/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';

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
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ref.watch(appThemeProvider);
    // Build dark theme locally with pinned primary color (blue)
    final ColorScheme darkScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF005B8C),
      brightness: Brightness.dark,
    ).copyWith(primary: const Color(0xFF005B8C));
    final ThemeData darkTheme = ThemeData(
      colorScheme: darkScheme,
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
    );
    final AsyncValue<ThemeMode> modeAsync = ref.watch(themeModeProvider);
    final AsyncValue<Locale> localeAsync = ref.watch(currentLocaleProvider);
    // Combine async values with fallbacks
    final ThemeMode mode = modeAsync.maybeWhen(
      data: (m) => m,
      orElse: () => ThemeMode.system,
    );
    final Locale locale = localeAsync.maybeWhen(
      data: (l) => l,
      orElse: () => const Locale('de'),
    );
    return _buildMaterialApp(
        theme: theme, darkTheme: darkTheme, mode: mode, locale: locale);
  }

  Widget _buildMaterialApp(
      {required ThemeData theme,
      required ThemeData darkTheme,
      required ThemeMode mode,
      required Locale locale}) {
    return MaterialApp.router(
      title: 'Dienstplan',
      theme: theme,
      darkTheme: darkTheme,
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
