import 'package:auto_route/auto_route.dart';
import 'package:dienstplan/presentation/widgets/common/settings_page_transition.dart';
import 'package:flutter/widgets.dart' show Key;
import 'package:dienstplan/presentation/screens/app_initializer_widget.dart';
import 'package:dienstplan/presentation/screens/calendar_screen.dart';
import 'package:dienstplan/presentation/screens/settings_screen.dart';
import 'package:dienstplan/presentation/screens/settings_category_screen.dart';
import 'package:dienstplan/presentation/screens/about_screen.dart';
import 'package:dienstplan/presentation/screens/privacy_policy_screen.dart';
import 'package:dienstplan/presentation/screens/disclaimer_screen.dart';
import 'package:dienstplan/presentation/screens/debug_screen.dart';
import 'package:dienstplan/presentation/screens/setup_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends RootStackRouter {
  AppRouter({super.navigatorKey});

  @override
  List<AutoRoute> get routes => <AutoRoute>[
    AutoRoute(page: AppInitializerRoute.page, path: '/', initial: true),
    AutoRoute(page: CalendarRoute.page, path: '/calendar'),
    // All destinations in the settings hierarchy share the same opaque
    // backdrop and directed foreground motion.
    _settingsRoute(SettingsRoute.page, '/settings'),
    _settingsRoute(SettingsCategoryRoute.page, '/settings/:category'),
    _settingsRoute(AboutRoute.page, '/about'),
    _settingsRoute(PrivacyPolicyRoute.page, '/privacy'),
    _settingsRoute(DisclaimerRoute.page, '/disclaimer'),
    _settingsRoute(DebugRoute.page, '/debug'),
    AutoRoute(page: SetupRoute.page, path: '/setup'),
  ];

  CustomRoute _settingsRoute(PageInfo page, String path) => CustomRoute(
    page: page,
    path: path,
    transitionsBuilder: SettingsPageTransition.buildTransition,
    // Make the page opaque immediately; its foreground enters over 270 ms.
    duration: Duration.zero,
    reverseDuration: path == '/settings'
        ? Duration.zero
        : const Duration(milliseconds: 270),
    enablePredictiveBackGesture: true,
    predictiveBackPageTransitionsBuilder:
        SettingsPageTransition.buildTransition,
  );
}
