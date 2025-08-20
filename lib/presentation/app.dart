import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/core/routing/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/domain/entities/settings.dart' as domain;

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
    _configureSystemUI();
  }

  void _configureSystemUI() {
    // Configure system UI overlay style to handle navigation bar properly
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        // Status bar configuration
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        // Navigation bar configuration
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
    
    // Enable edge-to-edge display
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ref.watch(appThemeProvider);
    final ThemeData darkTheme = ref.watch(appDarkThemeProvider);

    // Use settings notifier directly for immediate theme resolution
    final settingsState = ref.watch(settingsNotifierProvider);
    final AsyncValue<Locale> localeAsync = ref.watch(currentLocaleProvider);

    // Handle loading state gracefully
    if (settingsState.isLoading) {
      // Show loading with light theme to prevent dark mode flash
      final Locale locale = localeAsync.maybeWhen(
        data: (l) => l,
        orElse: () => const Locale('de'),
      );
      return _buildMaterialApp(
          theme: theme,
          darkTheme: darkTheme,
          mode: ThemeMode.light,
          locale: locale);
    }

    final domain.ThemePreference? uiThemePref =
        settingsState.valueOrNull?.themePreference;

    // Determine theme mode with immediate fallback to light mode
    ThemeMode deriveFromPref(domain.ThemePreference pref) {
      switch (pref) {
        case domain.ThemePreference.light:
          return ThemeMode.light;
        case domain.ThemePreference.dark:
          return ThemeMode.dark;
        case domain.ThemePreference.system:
          return ThemeMode.system;
      }
    }

    // Use settings preference if available, otherwise default to light mode
    // This prevents the dark mode flash on startup
    final ThemeMode mode =
        uiThemePref != null ? deriveFromPref(uiThemePref) : ThemeMode.light;

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
