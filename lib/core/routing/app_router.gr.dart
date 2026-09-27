// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AboutScreen]
class AboutRoute extends PageRouteInfo<void> {
  const AboutRoute({List<PageRouteInfo>? children})
    : super(AboutRoute.name, initialChildren: children);

  static const String name = 'AboutRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AboutScreen();
    },
  );
}

/// generated route for
/// [AppInitializerWidget]
class AppInitializerRoute extends PageRouteInfo<void> {
  const AppInitializerRoute({List<PageRouteInfo>? children})
    : super(AppInitializerRoute.name, initialChildren: children);

  static const String name = 'AppInitializerRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AppInitializerWidget();
    },
  );
}

/// generated route for
/// [CalendarScreen]
class CalendarRoute extends PageRouteInfo<void> {
  const CalendarRoute({List<PageRouteInfo>? children})
    : super(CalendarRoute.name, initialChildren: children);

  static const String name = 'CalendarRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CalendarScreen();
    },
  );
}

/// generated route for
/// [DebugScreen]
class DebugRoute extends PageRouteInfo<DebugRouteArgs> {
  DebugRoute({
    Key? key,
    DebugPackageInfoLoader? loadPackageInfo,
    DebugScheduleFilesLoader? loadScheduleFiles,
    DebugSentryTestSender? sendTestSentry,
    List<PageRouteInfo>? children,
  }) : super(
         DebugRoute.name,
         args: DebugRouteArgs(
           key: key,
           loadPackageInfo: loadPackageInfo,
           loadScheduleFiles: loadScheduleFiles,
           sendTestSentry: sendTestSentry,
         ),
         initialChildren: children,
       );

  static const String name = 'DebugRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DebugRouteArgs>(
        orElse: () => const DebugRouteArgs(),
      );
      return DebugScreen(
        key: args.key,
        loadPackageInfo: args.loadPackageInfo,
        loadScheduleFiles: args.loadScheduleFiles,
        sendTestSentry: args.sendTestSentry,
      );
    },
  );
}

class DebugRouteArgs {
  const DebugRouteArgs({
    this.key,
    this.loadPackageInfo,
    this.loadScheduleFiles,
    this.sendTestSentry,
  });

  final Key? key;

  final DebugPackageInfoLoader? loadPackageInfo;

  final DebugScheduleFilesLoader? loadScheduleFiles;

  final DebugSentryTestSender? sendTestSentry;

  @override
  String toString() {
    return 'DebugRouteArgs{key: $key, loadPackageInfo: $loadPackageInfo, loadScheduleFiles: $loadScheduleFiles, sendTestSentry: $sendTestSentry}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DebugRouteArgs) return false;
    return key == other.key &&
        loadPackageInfo == other.loadPackageInfo &&
        loadScheduleFiles == other.loadScheduleFiles &&
        sendTestSentry == other.sendTestSentry;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      loadPackageInfo.hashCode ^
      loadScheduleFiles.hashCode ^
      sendTestSentry.hashCode;
}

/// generated route for
/// [DisclaimerScreen]
class DisclaimerRoute extends PageRouteInfo<void> {
  const DisclaimerRoute({List<PageRouteInfo>? children})
    : super(DisclaimerRoute.name, initialChildren: children);

  static const String name = 'DisclaimerRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DisclaimerScreen();
    },
  );
}

/// generated route for
/// [PrivacyPolicyScreen]
class PrivacyPolicyRoute extends PageRouteInfo<void> {
  const PrivacyPolicyRoute({List<PageRouteInfo>? children})
    : super(PrivacyPolicyRoute.name, initialChildren: children);

  static const String name = 'PrivacyPolicyRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PrivacyPolicyScreen();
    },
  );
}

/// generated route for
/// [SettingsCategoryScreen]
class SettingsCategoryRoute extends PageRouteInfo<SettingsCategoryRouteArgs> {
  SettingsCategoryRoute({
    Key? key,
    required String category,
    List<PageRouteInfo>? children,
  }) : super(
         SettingsCategoryRoute.name,
         args: SettingsCategoryRouteArgs(key: key, category: category),
         rawPathParams: {'category': category},
         initialChildren: children,
       );

  static const String name = 'SettingsCategoryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<SettingsCategoryRouteArgs>(
        orElse: () => SettingsCategoryRouteArgs(
          category: pathParams.getString('category'),
        ),
      );
      return SettingsCategoryScreen(key: args.key, category: args.category);
    },
  );
}

class SettingsCategoryRouteArgs {
  const SettingsCategoryRouteArgs({this.key, required this.category});

  final Key? key;

  final String category;

  @override
  String toString() {
    return 'SettingsCategoryRouteArgs{key: $key, category: $category}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SettingsCategoryRouteArgs) return false;
    return key == other.key && category == other.category;
  }

  @override
  int get hashCode => key.hashCode ^ category.hashCode;
}

/// generated route for
/// [SettingsScreen]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsScreen();
    },
  );
}

/// generated route for
/// [SetupScreen]
class SetupRoute extends PageRouteInfo<void> {
  const SetupRoute({List<PageRouteInfo>? children})
    : super(SetupRoute.name, initialChildren: children);

  static const String name = 'SetupRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SetupScreen();
    },
  );
}
