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
import 'package:dienstplan/data/services/notification_service.dart';

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
    _configureSystemUI();

    // Process any pending notifications once the UI is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationServiceProvider).processPendingNotifications();
      _setOrientationBasedOnScreenSize();
    });
  }

  void _setOrientationBasedOnScreenSize() {
    final MediaQueryData? mediaQuery = MediaQuery.maybeOf(context);
    final double screenWidth = mediaQuery?.size.width ?? 0.0;

    // Use 600dp as the breakpoint between phones and tablets/foldables
    // This follows Material Design guidelines for responsive layouts
    if (mediaQuery == null || screenWidth < 600) {
      // Phones or unknown: Lock to portrait only
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    } else {
      // Tablets/foldables: Allow all orientations
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  void _configureSystemUI() {
    // Configure system UI overlay style to handle navigation bar properly
    // Note: Status bar icon brightness will be handled dynamically by the theme
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        // Status bar configuration
        statusBarColor: Colors.transparent,
        // Navigation bar configuration
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );

    // Enable edge-to-edge display for Android 12+ compatibility
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
    final settingsState = ref.watch(settingsProvider);
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
        locale: locale,
      );
    }

    final domain.ThemePreference? uiThemePref =
        settingsState.value?.themePreference;

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
    final ThemeMode mode = uiThemePref != null
        ? deriveFromPref(uiThemePref)
        : ThemeMode.light;

    final Locale locale = localeAsync.maybeWhen(
      data: (l) => l,
      orElse: () => const Locale('de'),
    );
    return _buildMaterialApp(
      theme: theme,
      darkTheme: darkTheme,
      mode: mode,
      locale: locale,
    );
  }

  Widget _buildMaterialApp({
    required ThemeData theme,
    required ThemeData darkTheme,
    required ThemeMode mode,
    required Locale locale,
  }) {
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
        navigatorObservers: () => <NavigatorObserver>[AutoRouteObserver()],
      ),
      routeInformationParser: _appRouter.defaultRouteParser(),
      scaffoldMessengerKey: NotificationService.scaffoldMessengerKey,
    );
  }
}
