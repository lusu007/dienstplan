import 'package:auto_route/auto_route.dart';
import 'package:dienstplan/presentation/screens/app_initializer_widget.dart';
import 'package:dienstplan/presentation/screens/calendar_screen.dart';
import 'package:dienstplan/presentation/screens/settings_screen.dart';
import 'package:dienstplan/presentation/screens/about_screen.dart';
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
    AutoRoute(page: SettingsRoute.page, path: '/settings'),
    AutoRoute(page: AboutRoute.page, path: '/about'),
    AutoRoute(page: DebugRoute.page, path: '/debug'),
    AutoRoute(page: SetupRoute.page, path: '/setup'),
  ];
}
